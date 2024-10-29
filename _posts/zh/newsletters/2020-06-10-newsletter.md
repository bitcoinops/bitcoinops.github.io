---
title: 'Bitcoin Optech Newsletter #101'
permalink: /zh/newsletters/2020/06/10/
name: 2020-06-10-newsletter-zh
slug: 2020-06-10-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 链接了一篇关于利用比特币软件的 eclipse 攻击窃取闪电网络（LN）通道资金的博客文章和论文，并描述了影响硬件钱包的手续费超额支付攻击的历史与影响。此外，还包括我们定期的 Bitcoin Core PR 审查俱乐部会议总结、近期软件发布的描述，以及对受欢迎的比特币基础设施项目的最新更改总结。

## 行动项

- **<!--check-hardware-wallet-compatibility-->****检查硬件钱包兼容性：** 如果您的软件或流程允许使用硬件钱包来花费 segwit 输入，请检查您的系统是否仍与钱包的最新固件更新兼容。例如，[Trezor 的最新固件][trezor update]需要与其交互的软件进行升级，以继续处理 segwit 输入；[Ledger 的最新固件][ledger update]在处理来自未更新软件的 segwit 输入时将显示警告。其他硬件钱包可能在未来发布类似的更新；请联系制造商了解他们的计划。有关此更改的动机，请参阅下文中的手续费超额支付攻击的新闻项。

## 新闻

- **<!--time-dilation-attacks-against-ln-->****针对闪电网络的时间膨胀攻击：** Gleb Naumenko 和 Antoine Riard 在 Bitcoin-Dev 邮件列表中发布了他们撰写的一篇[博客文章][td blog]的总结，该文章本身总结了他们撰写的[论文][td paper]，关于使用 [eclipse 攻击][topic eclipse attacks]窃取 LN 通道资金的研究。这一分析扩展了 Riard 在 [Newsletter #77][news77 eclipse] 中描述的内容。简而言之，攻击者控制了 LN 节点与比特币 P2P 网络的所有连接，并延迟了新区块公告的传播。当受害者的区块链视图与公共共识视图差距足够大时，攻击者会以一个过期状态关闭与受害者的通道，从而获得比最新状态更多的支付。eclipse 攻击用于防止受害者在争议期结束前看到这些关闭交易，并使攻击者将非法收益提取到完全受其控制的地址。

  论文描述了一种能够在短短两小时内窃取轻量客户端资金的攻击。由于目前提供数据给轻量 LN 客户端的服务器和节点非常少，攻击者可能很容易创建足够多的 sybil 来执行攻击。针对本地比特币完整验证节点支持的 LN 节点的攻击则需要更长时间——通常仍然是几小时之内，并且可能需要创建更多的 sybil。作者指出，这些攻击可能也适用于其他时间敏感的合约协议。解决此问题的一般方法是提高 eclipse 攻击的抵抗能力，其中一个具体的改进建议是允许节点选择加入[替代传输协议][Bitcoin Core #18988]。

- **<!--fee-overpayment-attack-on-multi-input-segwit-transactions-->****针对多输入 segwit 交易的手续费超额支付攻击：** 比特币交易支付的手续费是所花费的 UTXO 金额与创建的 UTXO 金额之间的差额。交易明确声明了创建的 UTXO 金额，但所花费的 UTXO 金额只能通过查找创建这些 UTXO 的先前交易来确定。花费交易仅承诺其要花费的 UTXO 的 txid 和位置，这要求计算手续费的其他软件要么查找每个 UTXO 的先前交易，要么维护一个已验证的 UTXO 数据库。

  硬件钱包不维护一个 UTXO 集，因此对于它们来说，唯一无需信任的方法来确定支付了多少手续费是获取每个传统 UTXO 的先前交易的副本，哈希先前的交易以确保其 txid 与 UTXO 引用匹配，并使用现已验证的 UTXO 金额进行手续费计算。在最糟糕的情况下，传统交易的大小可能接近一兆字节，而花费交易可能引用成千上万的先前交易，因此金额验证可能需要资源有限的硬件钱包处理千兆字节的数据。

  [BIP143][] segwit v0 中的几个改进之一试图通过让[签名承诺所花费的 UTXO 金额][bip143 motivation]来消除这一负担。这意味着，任何承诺错误金额的签名将是无效的，Bitcoin Core 和[硬件钱包][palatinus impatient]的开发者都认为这将允许签名者安全地接受来自不受信任软件的金额。

  不幸的是，签名单个 UTXO 金额被证明是不够的。在 2017 年，Greg Sanders [描述][sanders attack]了一种攻击，该攻击可以用来诱骗用户大幅度地超额支付交易手续费。攻击者控制连接硬件钱包的桌面或移动软件，等待用户发起付款。然后，受损软件创建两个变体的交易，分别花费用户硬件钱包控制的两个 segwit UTXO。第一个交易中，受损软件低估了一个 UTXO 的金额，这将导致硬件钱包低估相应的交易手续费。第二个交易中，受损软件低估了第二个 UTXO 的金额，这同样导致硬件钱包低估第二个交易的手续费。

  受损软件将第一个交易发送到硬件钱包，用户检查金额、接收地址和计算的交易手续费。用户授权签名，并将签名后的交易返回给受损软件。由于其中一个签名承诺了错误的 UTXO 金额，第一个交易根据 BIP143 是无效的。受损软件随后声称交易无法广播并要求用户重新签名，但实际上它并未重新发送第一个交易，而是发送了第二个交易。基于硬件钱包显示的信息（金额、接收人和手续费），第二个交易看起来与第一个交易相同，因此用户很可能会再次授权签名。第二个交易也因一个签名承诺了错误金额而根据 BIP143 无效。然而，每个交易都有一个有效的签名，受损软件可以利用这两个有效的签名合成一个有效的超额支付手续费的交易。

  ![手续费超额支付攻击示意图](/img/posts/2020-06-fee-overpayment-attack.dot.png)

  最糟糕的情况下，攻击会提示用户为一个控制 n 个 UTXO 的钱包签名 n 次，从而导致除合法支付金额外的所有钱包资金都被用来支付手续费。

  类似于 Sanders 2017 年邮件中描述的另一种攻击（参见 [Newsletter #97][news97 spk commit]），此攻击仅影响*无状态签名器*，如依赖外部系统告知其所控制 UTXO 的硬件钱包。联网钱包会跟踪其收到的 UTXO 金额，因此不会为错误的 UTXO 金额签名，从而不受此攻击的影响。当然，联网钱包也可能受到其他攻击，因此硬件钱包可以增强用户安全性。

  上周，Trezor [宣布][trezor post]，Saleem Rashid 在大约三个月前重新发现了这一漏洞。作为响应，Trezor 更新了其固件，要求对 segwit UTXO 也提供先前交易的副本，类似于对传统 UTXO 的要求。这导致与若干接口 Trezor 设备的钱包失去兼容性，无论是直接还是通过 [HWI][topic hwi]（参见 [HWI #340][]）。对于有完整先前交易副本或能够获取它们的钱包，恢复兼容性仅需要更新钱包代码。而对于那些可能不存储支付给钱包的完整先前交易副本的钱包，可能需要重新设计钱包以存储这些数据，并重新扫描区块链中的过去交易。创建或更新[部分签名的比特币交易][topic psbt] (PSBT)的软件需要[升级][Bitcoin Core #19215]以将完整的先前交易副本包含在 PSBT 中。对于存储在受限介质中的 PSBT（例如，QR 码，参见 [Newsletter #96][news96 qr]），数据大小的显著增加可能需要放弃协议或切换到更高容量的介质。

  Ledger 也做了类似的更改，但他们的[支持文章][ledger update]表示，仅在没有完整先前交易副本时显示警告。尽管要求提供先前交易最大限度地提高了用户针对该攻击的安全性，但也有一些观点支持允许硬件钱包继续使用 segwit 的签署 UTXO 值而不是破坏现有软件或花费额外资源来进行类似传统的值验证：

  - **<!--attack-already-well-known-for-three-years-->****该攻击已众所周知三年：** Sanders 在几乎三年前公开描述了此攻击，并且在[邮件列表][lau sighash2]、[BIPs][bip341 all amounts] 以及 Newsletter [#11][news11 sighash] 和 [#46][news46 digest changes] 中等其他讨论中也被提到或暗示过。据[认为][wuille minimal impact]，“大家都觉得应对起来太难，且影响不大。” 获得硬件钱包控制软件的攻击者可能更有可能执行其他攻击，例如直接支付给攻击者的[地址替换攻击][hw security]，而不是超额支付交易手续费。

  - **<!--double-signing-can-also-lead-to-spending-twice-->****双重签名也可能导致双重支付：** 该攻击依赖于使用受损软件让硬件钱包用户授权两笔稍有不同的交易（每笔交易有两个输入），这些交易看起来对用户来说完全相同。然而，受损软件同样可以向用户显示两笔完全不同的交易（每笔花费一个不同的输入），从而导致向同一接收人支付两次。这两种攻击对用户来说是无法区分的，但手续费超额支付攻击的修复并不能修复[双重支付攻击][maxwell spend twice]。

  - **<!--multisig-setups-may-require-multiple-compromises-->****多重签名设置可能需要多重破坏：** 针对由多重硬件钱包保护的多重签名资金进行攻击，必须诱骗达到最低门槛（例如，“2-of-3” 多重签名）所需的每个签名者都签署相同的两个交易变体。对于包含知道其签署 UTXO 值的在线钱包的门槛（例如，基于策略的远程签名器），攻击仅在该在线钱包也被破坏的情况下有效。

  该攻击的长期解决方案是更改交易摘要，使每个签名承诺所有所花费 UTXO 的值。如果受损软件谎报任何 UTXO 金额，则签名无效。这一方案由 Johnson Lau 于 2018 年[提出][lau sighash2]（参见 [Newsletter #11][news11 sighash]），并从其最早的公开草案开始被包含在 [taproot][topic taproot] 的 [BIP341][] 规范中（参见 [Newsletter #46][news46 digest changes]）。如果 taproot 被采用，那么对无状态签名器（如硬件钱包）来说，签署 taproot UTXO 将变得更安全，而无需评估先前交易。然而，这仍然无法解决双重支付攻击，这是由于大多数硬件钱包的[无状态设计][wuille stateless] 所导致的，它们无法在内部跟踪自己的交易历史。

## Bitcoin Core PR 审查俱乐部

_在本月度栏目中，我们总结了一次最近的 [Bitcoin Core PR 审查俱乐部][Bitcoin Core PR Review Club]会议，重点介绍了一些重要的问题和答案。点击下面的问题可查看会议中答案的摘要。_

[连接驱逐逻辑测试][review club #16756]是 Martin Zumsande 提交的一个 PR ([#16756][Bitcoin Core #16756])，它为 Bitcoin 网络的对等节点驱逐逻辑的部分内容添加了缺失的测试覆盖。该测试验证了那些转发交易和区块并迅速响应的入站对等节点不受驱逐影响。

讨论围绕 Bitcoin Core 中的驱逐逻辑和入站对等连接的保护展开：

{% include functions/details-list.md
  q0="当 Bitcoin Core 节点的入站连接达到限制时会发生什么？"
  a0="当节点连接已满时，节点通过终止现有的入站对等节点的连接来响应新入站对等节点的连接。这被称为“驱逐”。"

  q1="为什么 Bitcoin Core 驱逐对等节点而不是不再接受新的入站连接？"
  a1="目标是不断选择行为良好的对等节点，这些对等节点来自不同的网络，并迅速转发区块——并防止恶意方垄断连接插槽。最早连接的对等节点不一定是最好的，因此需要驱逐机制。"
  a1link="https://bitcoincore.reviews/16756#l-41"

  q2="为什么 Bitcoin Core 保护选定的对等节点免于驱逐？"
  a2="我们希望保留那些已被证明有用的连接，并增加恶意方驱逐和占据所有入站连接的难度。因此，根据难以伪造的多种不同特征保护一小部分对等节点。为了分区节点，攻击者必须在所有特征上同时表现得优于诚实的对等节点。"
  a2link="https://github.com/bitcoin-core-review-club/bitcoin/blob/pr16756/src/net.cpp#L846"

  q3="描述 Bitcoin Core 中入站对等节点驱逐的算法。"
  a3="选择所有入站对等节点，除了在 `NO BAN` 列表上或已安排断开连接的节点。然后，根据各自适用的困难且难以伪造的特征，移除（保护）最好的对等节点：网络组、最低的最小 ping 时间、最近发送的交易和区块、所需的服务标志和长期连接。从剩余的对等节点中，选择一个从连接最多的网络组中驱逐。"
  a3link="https://github.com/bitcoin-core-review-club/bitcoin/blob/pr16756/src/net.cpp#L851"
%}

## 发布与候选发布

*热门比特币基础设施项目的最新发布和候选发布。请考虑升级到新版本或帮助测试候选版本。*

- [Bitcoin Core 0.20.0][] 是该原始比特币项目的最新主要版本。本版本最值得注意的用户可见改进包括 RPC 用户的默认 [Bech32][topic bech32] 地址（GUI 从 0.19 版本开始默认使用 Bech32），为不同用户和应用配置 RPC 权限的功能（参见 [Newsletter #77][news77 rpcwhitelist]），在 GUI 中生成 PSBT 的一些基础支持（[#74][news74 psbtgui] 和 [#82][news82 psbtgui]），以及向[输出脚本描述符][topic descriptors]语言中添加的 `sortedmulti`，使得从按字典顺序排序的密钥生成多重签名地址更容易，例如 Coldcard 的原生多重签名支持（[#68][news68 sortedmulti]）。

  此外，代码还进行了许多不太明显的改进，以消除 bug、增强安全性并为未来的更改做准备。一个备受关注的前瞻性变化是新增了一个 `asmap` 配置设置，允许使用单独下载的数据库来提高 Bitcoin Core 在不同网络组之间多样化连接的能力，从而增强对 [eclipse 攻击][topic eclipse attacks]（例如 [Erebus 攻击][Erebus attack]）的抵抗力（参见 [Newsletter #83][news83 asmap]）。然而，该功能的作者之一[指出][wuille asmap]，“目前它是高度实验性的，并且如何推进这一进程尚不明确。收集和编译 ASN [自治服务编号]数据非常复杂，并且涉及信任问题。”

  有关所有更改的更多信息，以及超过 100 名为这一新版本做出贡献的人的列表，请参阅项目的[发布说明][core20 rn]。

- [LND 0.10.1-beta][] 是这一受欢迎的 LN 节点软件的一个新次要版本。发布说明未宣布重大新功能，但提到了几个 bug 修复、“一个新的干运行迁移模式，以在永久应用迁移前测试迁移”，以及对路由子服务器中通道选择/限制的改进。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的更改。*

- [Eclair #1440][] 使得可以使用 API 一次更新多个通道。最初提出的建议是帮助节点操作员通过批量更新其通道的中继费率来适应动态的链上费用市场，该改进还支持批量关闭和强制关闭。

- [Eclair #1141][] 添加了对 `option_static_remotekey` 通道的支持。在 LN 节点数据丢失的情况下，该功能允许通道对手方将当前余额支付给在初始通道打开期间约定的未经修改的密钥，关闭通道并允许节点钱包正常使用其资金。有关此功能的更多详细信息，请参阅 [Newsletter #67][news67 static_remotekey]。

- [LND #4251][] 使其 REST 接口支持的非流消息列表与 gRPC 接口一致。之前，REST 接口仅支持其中一部分消息（具体来说是 `Lightning` 子服务器的消息）。此 PR 将由 [LND #4141][] 跟进，后者通过 WebSockets 支持流式响应，使得 REST 接口与 gRPC 接口完全一致。

- [BIPs #920][] 更新了 [BIP341][] 中的 [taproot][topic taproot] 规范，要求签名直接承诺所有所花费 UTXO 的 scriptPubKeys。这使得硬件钱包更安全地参与 [coinjoins][topic coinjoin] 和其他协作生成的交易变得更容易。详情请参阅 [Newsletter #97][news97 spk commit] 中的描述。

## 特别感谢

我们感谢 Pieter Wuille 帮助研究手续费超额支付攻击的历史。感谢 Antoine Riard 提供有关时间膨胀攻击论文的附加信息。任何错误或遗漏均由 Newsletter 作者负责。

{% include references.md %}
{% include linkers/issues.md issues="1440,4251,920,1141,18988,19215,4141,16756" %}
[bitcoin core 0.20.0]: https://bitcoincore.org/bin/bitcoin-core-0.20.0
[lnd 0.10.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.10.1-beta
[news97 spk commit]: /zh/newsletters/2020/05/13/#request-for-an-additional-taproot-signature-commitment
[news77 eclipse]: /zh/newsletters/2019/12/18/#discussion-of-eclipse-attacks-on-ln-nodes
[hw security]: https://en.bitcoin.it/wiki/Hardware_wallet#Security_risks
[towns benefits]: https://bitcoincore.org/en/2016/01/26/segwit-benefits/#signing-of-input-values
[palatinus inpatient]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2016-October/013248.html
[news11 sighash]: /zh/newsletters/2018/09/04/#proposed-sighash-updates
[naumenko td]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-June/017920.html
[td blog]: https://discrete-blog.github.io/time-dilation/
[td paper]: https://arxiv.org/abs/2006.01418
[lau sighash2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016345.html
[maxwell spend twice]: http://www.erisian.com.au/bitcoin-core-dev/log-2020-06-05.html#l-352
[bip143 motivation]: https://github.com/bitcoin/bips/blob/master/bip-0143.mediawiki#motivation
[sanders attack]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2017-August/014843.html
[news97 spk commit]: /zh/newsletters/2020/05/13/#request-for-an-additional-taproot-signature-commitment
[trezor post]: https://blog.trezor.io/details-of-firmware-updates-for-trezor-one-version-1-9-1-and-trezor-model-t-version-2-3-1-1eba8f60f2dd
[bip341 all amounts]: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki#cite_note-17
[news96 qr]: /zh/newsletters/2020/05/06/#qr-codes-for-large-transactions
[news46 digest changes]: /zh/newsletters/2019/05/14/#digest-changes
[wuille asmap]: https://twitter.com/pwuille/status/1268296477584965634
[news77 rpcwhitelist]: /zh/newsletters/2019/12/18/#bitcoin-core-12763
[news74 psbtgui]: /zh/newsletters/2019/11/27/#bitcoin-core-16944
[news82 psbtgui]: /zh/newsletters/2020/01/29/#bitcoin-core-17492
[news68 sortedmulti]: /zh/newsletters/2019/10/16/#bitcoin-core-17056
[news83 asmap]: /zh/newsletters/2020/02/05/#bitcoin-core-16702
[core20 rn]: https://bitcoincore.org/en/releases/0.20.0/
[news67 static_remotekey]: /en/newsletters/2019/10/09/#bolts-642
[trezor update]: https://blog.trezor.io/latest-firmware-updates-correct-possible-segwit-transaction-vulnerability-266df0d2860
[ledger update]: https://support.ledger.com/hc/en-us/articles/360014191540
[erebus attack]: https://erebus-attack.comp.nus.edu.sg/
[wuille minimal impact]: http://www.erisian.com.au/bitcoin-core-dev/log-2020-06-04.html#l-613
[wuille stateless]: http://www.erisian.com.au/bitcoin-core-dev/log-2020-06-05.html#l-395
[hwi #340]: https://github.com/bitcoin-core/HWI/pull/340
