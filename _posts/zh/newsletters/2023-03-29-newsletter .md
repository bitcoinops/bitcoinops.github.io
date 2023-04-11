---
title: 'Bitcoin Optech Newsletter #244'
permalink: /zh/newsletters/2023/03/29/
name: 2023-03-29-newsletter
slug: 2023-03-29-newsletter
type: newsletter
layout: newsletter
lang: zh
---
本周的周报描述了一项使用可调惩罚来提高闪电网络资金效率的提议。还包括我们的常规部分，其中包含来自 Bitcoin Stack Exchange 的热门问题和答案的总结、新版本和候选版本的公告，以及对热门的比特币基础设施软件的重大变更介绍。

{% assign S0 = "_S<sub>0</sub>_" %}
{% assign S1 = "_S<sub>1</sub>_" %}

## 新闻

- **使用多方通道和通道工厂防止资金滞留：**
  John Law 向 Lightning-Dev 邮件列表 [发布了][law stranded post] 他撰写的 [论文][law stranded paper] 的总结。他描述了始终可用的节点如何继续使用他们的资金转发付款，即使它们与当前不可用的节点（例如移动端闪电钱包的用户）共享一个通道。这需要使用多方通道，这与他之前描述的通道工厂设计很好地结合在一起。他还重申了 [通道工厂][topic channel factories] 的一个已知好处，即允许通道在链下再平衡，这也能更好地利用通道资金。他在文中描述了如何使用他之前对闪电网络 _可调惩罚_ 层创新的两个好处。我们将总结可调惩罚，展示它们如何用于多方通道和通道工厂，然后在上下文中解释 Law 的新成果。

    Alice 和 Bob 创建（但不立即签署）一笔交易，他们每人花费 50M sats（总共 100M）到一个 _出资输出_，该输出需要他们双方的合作才能花费。在下图中，我们将已确认的交易显示为阴影。

    {:.center}
    ![Alice and Bob create the funding transaction](/img/posts/2023-03-tunable-funding.dot.png)

    他们每个人还使用他们单独控制的不同输出来创建（但不广播）两个 _状态交易_，每人一个交易。每个状态交易的第一个输出花费很小的金额（比如 1000 sat）作为一个带有时间锁的链下 _承诺交易_ 的输入。相对时间锁会阻止每个承诺交易在链上确认的资格，直到其父状态交易在链上确认的一定时间后。两个承诺交易中的每一个均由相互冲突的出资输出提供资金（这意味着最终只能确认其中一个承诺交易）。所有子交易创建后，创建出资输出的交易可以被签署和广播。

    {:.center}
    ![Alice and Bob create their commitment transactions](/img/posts/2023-03-tunable-commitment.dot.png)

    每个承诺交易都支付给通道的当前状态。对于初始状态 ({{S0}})，50M sats 被退还给每个 Alice 和 Bob（为简单起见，我们忽略交易费用）。Alice 或 Bob 可以通过发布他们自己的状态交易版本来启动单方面关闭通道的流程；在强制延迟之后，他们可以发布相应的承诺交易。例如，Alice 发布了她的状态交易和她的承诺交易（支付给她和 Bob）；到那时，Bob 就可以永远不花费他的状态交易，而是可以在以后的任何时间花费用于创建状态交易的钱。

    {:.center}
    ![Alice spends honestly from the channel](/img/posts/2023-03-tunable-honest-spend.dot.png)

    在初始状态下单方面关闭通道还有另外两种选择。首先，Alice 和 Bob 可以随时通过花费出资交易输出来合作关闭通道（与当前闪电网络协议中所做的相同）。第二，他们可以更新状态——例如，将 Alice 的余额增加 10M sat 并将 Bob 的余额减少相同数量。状态 {{S1}} 看起来与状态 ({{S0}})非常相似，但为了实现更新，先前的状态被每一方撤销，并为另一方提供一个见证[^keychain]，该见证用于为前状态 ({{S0}}) 花费他们各自状态交易的第一个输出。任何一方都不能使用对方的见证，因为 {{S0}} 状态交易本身还不包含见证，因此无法广播。

    由于有多个可用状态，可能会意外或故意关闭处于过时状态的通道。例如，Bob 可能会尝试关闭处于状态 {{S0}} 的通道，那里他有额外的 10M sats。为此，Bob 为 {{S0}} 签署并广播他的状态交易。由于承诺交易的时间锁，Bob 无法立即采取任何进一步的行动。在等待期间，Alice 检测到这种广播过期状态的尝试，并使用 Bob 之前给她的见证来花费他的状态交易的第一个输出，支付部分或全部罚款金额作为交易费用。由于该输出与 Bob 稍后需要广播花费给他额外 10M sat 的承诺交易的输出相同，因此如果 Alice 创建的交易得到确认，他将无法领取这些资金。在 Bob 被封锁的情况下，Alice 是唯一可以单方面在链上发布最新状态的人；或者，Alice 和 Bob 仍然可以随时合作来执行通道关闭。

    {:.center}
    ![Bob attempts to spend dishonestly from the channel but is blocked by Alice](/img/posts/2023-03-tunable-dishonest-spend.dot.png)

    如果 Bob 注意到 Alice 试图从他过期的状态交易中花费，他可以尝试与 Alice 进行手续费替换 (RBF) 竞标战，但在这种情况下，惩罚金额 _可调整_ 就显得尤其强大：惩罚金额可能微不足道（例如 1K sats，在我们的示例中），它可能等于所涉金额（10M sats）或者它甚至可能大于通道的整个价值。该决定完全取决于 Alice 和 Bob 在更新通道状态时相互协商。

    可调整惩罚协议，Tunable-Penalty Protocol (TPP) 的另一个优点是罚款金额完全由将过期状态交易提交上链的用户支付。它不使用共享资金交易中的任何比特币。这允许两个以上的用户安全地共享一个 TPP 通道；例如，我们可以想象 Alice、Bob、Carol 和 Dan 都共享一个通道。他们每个人都有由他们自己的状态交易来出资的承诺交易：

    {:.center}
    ![A channel between Alice, Bob, Carol, and Dan](/img/posts/2023-03-tunable-multiparty.dot.png)

    他们可以将其作为多方通道进行操作，要求每个状态可被每一方都撤销。或者，他们可以将联合出资交易用作通道工厂，在成对或多个用户之间创建多个通道。在 Law 去年描述 TP。的这种影响之前 (见 [周报 #230][news230 tp])，通常认为，在比特币上实际实施通道工厂需要像 [eltoo][topic eltoo] 这样的机制，而这需要像[SIGHASH_ANYPREVOUT][topic sighash_anyprevout] 一样进行共识改变。TPP 不需要改变共识。为了使下图简单，我们只说明了在一个由四个参与者组成的工厂中创建的单个通道；通道参与者需要管理的状态数量等于工厂中的参与者数量，尽管 Law [之前描述了][law factories] 一种具有单一状态但单方面关闭成本更高的替代结构。

    {:.center}
    ![A channel between Alice and Bob created from a factory by Alice, Bob, Carol, and Dan](/img/posts/2023-03-tunable-factory.dot.png)

    在其 [原始论文][channel factories paper] 中描述的通道工厂的一个优势是工厂内的各方可以合作重新平衡他们的通道，而无需创建任何链上交易。例如，如果工厂由 Alice、Bob、Carol 和 Dan 组成。通过更新链下工厂状态，Alice 和 Bob 组成的通道的总价值可以减少至 Carol 和 Dan 组成通道总价值增加相同的数量。Law 的基于 TPP 的工厂提供了同样的好处。

    本周 Law 指出，能够提供多方通道（TPP 可能实现）的工厂还有一个额外的优势：即使在一个通道参与者离线时也可以使用资金。例如，假设 Alice 和 Bob 拥有几乎始终可用于转发支付的专用 LN 节点，但 Carol 和 Dan 是节点经常不可用的临时用户。在一个原始形式的通道工厂中，Alice 有一个与 Carol 的通道 ({A,C}) 和一个与 Dan ({A,D}) 的通道。她不能在这些通道中使用她的任何资金，当 Carol 和 Dan 不可用时。Bob 的通道也有同样的问题（{B,C} 和 {B,D}）。

    在基于 TPP 的工厂中，Alice、Bob 和 Carol 可以一起打开一个多方通道，要求他们三人合作更新通道状态。该通道中承诺交易的一个输出支付给 Carol，但另一个输出只有在 Alice 和 Bob 合作时才能花费。当 Carol 不可用时，Alice 和 Bob 可以合作更改他俩的链下联合输出的余额分配，如果他们有其他的 LN 通道，则允许他们发起或转发 LN 支付。如果 Alice 长时间不可用，他们中的任何一个都可以单方面将通道上链。如果 Alice 和 Bob 与 Dan 共享一个频道，也会享受到同样的好处。

    这允许 Alice 和 Bob 即使在 Carol 和 Dan 不可用时也可以继续赚取路由费用，从而防止这些通道看起来没有效率。重新平衡链下通道的能力（没有链上费用）也可以减少 Alice 和 Bob 将他们的资金在通道工厂中保存更长时间的不利因素。这些好处加起来可能会减少链上交易的数量，增加比特币网络的总支付能力，并降低通过 LN 转发支付的成本。

    在撰写本文时，可调整的惩罚和 Law 关于使用它们的各种建议还没有得到太多的公开讨论。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首批场所之一，也是我们有空闲时间帮助好奇或困惑用户的地方。在这个月度专题中，我们重点介绍自上次更新以来发布的一些投票最多的问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [为什么 taproot 部署没有埋设在 Bitcoin Core 中?]({{bse}}117569) Andrew Chow 解释了 taproot 软分叉 [部署][topic soft fork activation] 没有像 [其他升级][bitcoin buried deployments] 那样被 [埋设][BIP90] 的逻辑依据。

- [区块头中的版本字段有什么限制？]({{bse}}117530) Murch 注意到更多 [区块][explorer block 779960] 被 [overt ASICBoost][topic ASICBoost] 开采出来，他列出了对版本字段的限制，并介绍了 [区块头版本字段][FCAT block header blog] 的示例。

- [交易数据和交易ID之间有什么关系？]({{bse}}117453) Pieter Wuille 解释了 `txid` 标识符所涵盖的遗留交易序列化格式，`hash` 和 `wtxid` 标识符所涵盖的见证扩展序列化格式，并在 [单独的回答中][se117577] 指出 `hash` 标识符将涵盖假设的额外交易数据。

- [我可以向其他对等节点请求交易消息吗？]({{bse}}117546) 用户 RedGrittyBrick 指出一些资源，解释了Bitcoin Core 的 P2P 层不支持来自对等节点的任意交易请求的关于 [性能][wiki getdata] 和 [隐私][Bitcoin Core #18861] 的原因。

- [Eltoo：第一个 UTXO 的相对锁定时间是否设置了通道的生命周期？]({{bse}}117468) Murch 确认了问题的示例，基于 [eltoo][topic eltoo] 构建的 LN 通道具有有限的生命周期，但指出 [eltoo 白皮书][] 中的缓解措施可以防止超时过期。

## 版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Rust Bitcoin 0.30.0][] 是该库的最新版本，用于使用与比特币相关的数据结构。[发布说明][rb rn] 提到了 [一个新网址][rust-bitcoin.org] 和大量 API 变更。

- [LND v0.16.0-beta.rc5][] 是这个热门的 LN 实现的新主版本的候选版本。

- [BDK 1.0.0-alpha.0][] 是 [上周周报][news243 bdk] 中描述的 BDK 主要变化的测试版本。鼓励下游项目的开发人员开始集成测试。

## 重大的代码和文档变更

*本周出现重大变更的有 [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], 和
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #27278][] 默认情况下在收到新块的标头时开始记录，除非该节点处于初始块下载（IBD）中。这是受到多个节点运营商的 [启发][obeirne selfish]，运营商注意到三个区块彼此非常接近，后两个区块将第一个区块从最佳区块链中重组出来。为清楚起见，我们将第一个块称为_A_，将替换它的块称为 _A'_，将最后一个块称为 _B_。

  这可能表明区块 A' 和 B 是由同一个矿工创建的，他故意延迟广播，直到它们导致另一个矿工的区块变得陈旧，从而否认该矿工通常从 A 那里获得的区块奖励——一种被称为自私挖矿的攻击。这种情况也可能是巧合或意外的自私挖矿。然而，开发人员在调查期间 [提出][sanders requests]的一种可能性是，时间可能实际上并不像他们看起来那么接近——有可能 Bitcoin Core 在收到 B 之前没有请求 A'，因为 A' 本身不足以触发重组。

  记录接收区块头的时间意味着，如果将来重复这种情况，即使节点没有选择立即下载它，节点运营商也可以确定他们的节点何时首次了解 A' 的存在。此记录可能会为每个块添加最多两新行（尽管未来的 PR 可能会将其减少到一行），这被认为是一个足够小的额外开销，可以帮助检测自私挖矿攻击和与关键块中继相关的其他问题。

- [Bitcoin Core #26531][] 添加了跟踪点，用于使用在以前的 PR 中实现的 Extended Berkeley Packet Filter (eBPF) 来监控影响内存池的事件 (见 [周报 #133][news133 usdt])。还添加了一个脚本，用于使用跟踪点实时监控交易池统计数据和活动。

- [Core Lightning #5898][] 将其对 [libwally][] 的依赖更新为最新的版本 (见 [周报 #238][news238 libwally])，这使得增加对 [taproot][topic taproot] 的支持，支持版本2 [PSBT][topic psbt] ( [见周报 #128][news128 psbt2])，并影响了对 Elements 形式侧链上的 LN 的支持。

- [Core Lightning #5986][] 更新了以 msat 格式返回值的 RPC，不再将字符串“msat”作为结果的一部分。相反，所有返回值都是整数。这完成了几个版本前开始的弃用，见 [周报 #206][news206 msat]。

- [Eclair #2616][] 添加了对机会性 [零配置通道][topic zero-conf channels] 的支持---如果远程节点在预期的确认次数之前发送了 `channel_ready` 消息，Eclair 将验证出资交易是否完全由本地节点创建（因此远程节点无法确认冲突交易）然后将允许通道使用。

- [LDK #2024][] 开始包括已开放但还不成熟而尚未公开宣布的通道的路由提示，例如 [零配置通道][topic zero-conf channels]。

- [Rust Bitcoin #1737][] 添加了一个 [安全报告政策][rb sec]。

- [BTCPay Server #4608][] 允许插件在 BTCPay 用户界面中将其功能公开为应用程序。

- [BIPs #1425][] 将 [BIP93][] 分配给 codex32 方案，使用 Shamir 的 Secret Sharing Scheme (SSSS) 算法，一种校验和32字符字母表，对 BIP32 恢复种子进行编码，如 [周报 #239][news239 codex32]所述。

- [Bitcoin Inquisition #22][] 添加了一个 `-annexcarrier` 运行时选项，允许将 0 到 126 字节的数据推送到 taproot 输入的附件字段。PR 的作者计划使用该功能让人们开始使用 Core Lightning 的分支在 [eltoo][topic eltoo] 上试验 signet。

## 注脚

[^keychain]:
    描述 witness 是什么对于这个高级概念并不重要，但一些提议的好处确实取决于细节。最初的 [Tunable Penalties][] 协议描述建议释放用于生成签名的私钥以从承诺交易中进行花费。可以按顺序生成私钥，任何知道一个密钥的人也可以派生任何后来的密钥（但不是任何较早的密钥）。这意味着每次 Alice 撤销后来的状态时，她都可以给 Bob 一个较早的密钥，Bob 可以使用该密钥来导出任何后来的密钥（对于较早的状态）。例如：

      | Channel state | Key state |
      | 0     | MAX |
      | 1     | MAX - 1 |
      | 2     | MAX - 2 |
      | x     | MAX - x |
      | MAX   | 0 |

    这允许 Bob 将他需要从过时状态交易中花费的所有信息存储在非常小的恒定空间量 (根据我们的计算小于 100 字节)。这些信息也可以很容易地与 [瞭望塔][topic watchtowers] 共享 (不需要信任，因为过时状态交易的任何成功支出都会阻止过时的承诺交易在链上发布。因为过时状态交易中涉及的资金完全属于违反协议的一方，将有关支出的信息外包给它没有安全风险)。

{% include references.md %}
{% include linkers/issues.md v=2 issues="27278,26531,5898,5986,2616,2024,1737,4608,1425,22,18861" %}
[lnd v0.16.0-beta.rc5]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.0-beta.rc5
[bdk 1.0.0-alpha.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-alpha.0
[rust bitcoin 0.30.0]: https://github.com/rust-bitcoin/rust-bitcoin/releases/tag/bitcoin-0.30.0
[news230 tp]: /zh/newsletters/2022/12/14/#factory-optimized-ln-protocol-proposal
[channel factories paper]: https://tik-old.ee.ethz.ch/file//a20a865ce40d40c8f942cf206a7cba96/Scalable_Funding_Of_Blockchain_Micropayment_Networks%20(1).pdf
[law factories]: https://raw.githubusercontent.com/JohnLaw2/ln-efficient-factories/main/efficientfactories10.pdf
[news206 msat]: /en/newsletters/2022/06/29/#core-lightning-5306
[rb sec]: https://github.com/rust-bitcoin/rust-bitcoin/blob/master/SECURITY.md
[news239 codex32]: /zh/newsletters/2023/02/22/#proposed-bip-for-codex32-seed-encoding-scheme
[law stranded post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-March/003886.html
[law stranded paper]: https://github.com/JohnLaw2/ln-hierarchical-channels
[obeirne selfish]: https://twitter.com/jamesob/status/1637198454899220485
[sanders requests]: https://twitter.com/theinstagibbs/status/1637235436849442817
[news133 usdt]: /en/newsletters/2021/01/27/#bitcoin-core-19866
[libwally]: https://github.com/ElementsProject/libwally-core
[news128 psbt2]: /en/newsletters/2020/12/16/#new-psbt-version-proposed
[tunable penalties]: https://github.com/JohnLaw2/ln-tunable-penalties
[news238 libwally]: /zh/newsletters/2023/02/15/#libwally-0-8-8-released
[rust-bitcoin.org]: https://rust-bitcoin.org/
[rb rn]: https://github.com/rust-bitcoin/rust-bitcoin/blob/master/bitcoin/CHANGELOG.md#030---2023-03-21-the-first-crate-smashing-release
[news243 bdk]: /zh/newsletters/2023/03/22/#bdk-793
[bitcoin buried deployments]: https://github.com/bitcoin/bitcoin/blob/master/src/consensus/params.h#L19
[explorer block 779960]: https://blockstream.info/block/00000000000000000003a337a676b0101f3f7ef7dcbc01debb69f85c6da04dcf?expand
[FCAT block header blog]: https://medium.com/fcats-blockchain-incubator/understanding-the-bitcoin-blockchain-header-a2b0db06b515#b9ba
[se117577]: https://bitcoin.stackexchange.com/a/117577/87121
[wiki getdata]: https://en.bitcoin.it/wiki/Protocol_documentation#getdata
[eltoo whitepaper]: https://blockstream.com/eltoo.pdf#page=15
