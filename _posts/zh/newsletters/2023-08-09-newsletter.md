---
title: 'Bitcoin Optech Newsletter #263'
permalink: /zh/newsletters/2023/08/09/
name: 2023-08-09-newsletter-zh
slug: 2023-08-09-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报警告了关于在使用 Libbitcoin 的比特币浏览器（bx）工具中的严重漏洞，总结了有关拒绝服务保护设计的讨论，宣布了开始测试和收集有关 HTLC 背书的数据，并描述了对 Bitcoin Core 交易中继策略的两个建议性更改。此外还包括我们的常规部分，其中包括 Bitcoin Core PR 审核俱乐部会议摘要、新版本和发布候选版本的公告，以及对流行的比特币基础设施软件的重要变更的描述。

## 行动事项

- **Libbitcoin Bitcoin 浏览器的严重漏洞：** 如果你曾使用 `bx seed` 命令来创建[BIP32][topic BIP32]种子、[BIP39][] 助记词、私钥或其他安全内容，请考虑立即将所有资金转移到另一个安全地址。有关详细信息，请参阅下面的新闻部分。{% assign timestamp="1:25" %}

## 新闻

- **拒绝服务（DoS）保护设计理念：**Anthony Towns 在 Lightning-Dev 邮件列表中[发帖][towns dos]，来回应最近闪电网络开发者会议记录中的[通道堵塞][topic channel jamming attacks]攻击部分的内容（参见[周报 #261][news261 jamming]）。会议记录中提到：“能够阻止攻击者的成本对一个诚实的用户来说是不合理的，而诚实的用户能够接受的成本又太低以至于无法阻止攻击者。”

  Towns 提出了一个替代方案，不是试图通过高定价来阻挡攻击者，而是使攻击者和诚实用户支付的成本反映出提供服务的节点运营商所支付的基本成本。这样，一个能够获得合理回报的节点运营商可以同时吸引攻击者和诚实用户。提供服务给诚实用户，即使攻击者开始使用这些服务，也将继续获得合理的回报。如果攻击者试图通过消耗大量节点资源使节点无法为诚实用户提供服务，则会激励——节点将得到更高的收入——提供这些资源的节点来扩大他们提供的资源。

  作为该方案如何运作的建议，Towns 翻出了几年前的一个想法（参见[周报 #86][news86 hold fees]），即转发承诺费和反向保留费的组合。支付成功后，在收取常规费用的同时也将收取该组合费用。在一个 HTLC 从支付者 Alice 传播到中继节点 Bob 的时候，Alice 将支付一笔小额的转发承诺费用；Bob 的费用部分将对应于他处理 HTLC 的成本（如带宽）。在接受 HTLC 后的某个时间点，Bob 将负责定期向 Alice 支付一笔小额的反向保持费用，直到 HTLC 得到结算；无论支付最终是接受还是取消了，这都将补偿她因延迟而产生的损失。如果 Bob 在收到付款后立即将其转发给 Carol，Bob 将支付给 Carol 相较他从 Alice 处收到的金额略少的转发承诺费用，而这个差额就是他实际获得的补偿金额，而 Carol 将向 Bob 提供略大的反向保持费用（同样，这个差额就是对他的补偿）。只要没有转发节点或接收者延迟 HTLC，与正常成功费用相比，唯一的额外成本就是小额的转发承诺费用。但是，如果接收方或任何中继节点延迟付款，他们最终将负责支付所有上游节点的反向保留费用。

  Clara Shikhelman [回复][shikhelman dos]说，一段时间内支付的反向保留费用很容易超过节点在同等资本和同等时间内从成功费用中获得的金额。这将诱使恶意节点滥用该机制来从其对手方获得费用。她描述了像 Towns 所描绘的机制可能面临的一些挑战，而 Towns 则以反驳和总结进行了回复：“我认为如果人们感兴趣的话，基于货币的 DoS 防御仍然有可能会是一个富有成果的研究领域，尽管当前的实现工作集中在基于声誉的方法上。” {% assign timestamp="12:00" %}

- **HTLC 背书测试和数据收集：** Carla Kirk-Cohen 和 Clara Shikhelman 在 Lightning-Dev 邮件列表上[发布][kcs endorsement]了一篇文章，宣布与 Eclair、Core Lightning 和 LND 相关的开发人员正在实现 [HTLC 背书][topic htlc endorsement]协议的部分内容，以开始收集与之相关的数据。为了帮助这一过程，他们提出了一组对测试节点有用的、为研究人员收集的数据。其中许多字段的数据被有意地随机化了，以防止泄露那些可能损害支付者和接收者隐私的信息。他们计划进行多个阶段的测试，并概述了参与节点在不同阶段的行为。{% assign timestamp="18:41" %}

- **对 Bitcoin Core 默认中继策略的建议更改：** Peter Todd 在 Bitcoin-Dev 邮件列表上发起了两个讨论主题。这些主题是关于他开启的、旨在修改 Bitcoin Core 的默认中继策略的 PR。{% assign timestamp="28:04" %}

  - *<!--full-rbf-by-default-->默认启用完全手续费替换：* [第一个讨论主题][todd rbf]和 [PR][bitcoin core #28132] 提议在未来的 Bitcoin Core 版本中将[全面手续费替换][topic rbf]设为默认。默认情况下，Bitcoin Core 目前只会转发和接受未确认交易的替换，前提是被替换的交易包含了 [BIP125][] 信号，表示可选择性的替换（而且原始交易和替换交易都遵循了其他一些规则）。这称为“选择性手续费替换”（_opt-in RBF_）。配置选项`-mempoolfullrbf` 允许节点运营者选择接受任何未确认交易的替换，即使它没有包含 BIP125 信号，称为“完全手续费替换”（_full RBF_）（参见[周报 #208][news208 rbf]）。Peter Todd 的提议将使完全手续费替换成为默认设置。但允许节点运营者更改其设置来启用选择性手续费替换。

      Peter Todd 认为这种修改是有必要的，因为（根据他已经引起[质疑][towns rbf]的测算）有相当大比例的挖矿算力正在明显地遵循完全手续费替换规则，并且有足够多的中继节点启用了完全手续费替换，以允许矿工接收到没有信号的替换交易。他还表示，他不知道目前有哪些在运行的业务会把还未确认的链上交易当作具备终局性支付而接收。

  - *移除对 `OP_RETURN` 输出的特定限制：* [第二个讨论主题][todd opr]和 [PR][bitcoin core #28130] 建议移除Bitcoin Core 对具有以 `OP_RETURN` 操作码开头的输出脚本（即一个_OP_RETURN输出_）的交易的特定限制。目前，Bitcoin Core （默认情况下）不会中继或接受任何具有多个 `OP_RETURN` 输出或输出脚本超过 83 字节（相当于 80 字节的任意数据）的`OP_RETURN` 输出的交易进入其交易池。

      允许中继和默认可挖携带了少量数据的 `OP_RETURN` 输出的动机是之前人们将数据存储在其他类型的输出中。这些输出必须存储在 UTXO 集中，而且通常是永久性的。`OP_RETURN` 输出不需要存储在 UTXO 集中，因此问题不大。再然后，一些人开始在交易见证脚本中存储大量数据。

      该 PR 将默认允许任意数量的 `OP_RETURN` 输出以及一个 `OP_RETURN` 输出中有任意数量的数据，只要交易遵守 Bitcoin Core 其他的中继策略（例如，交易的总大小小于 100,000 vbytes）。截至本文撰写时，对该 PR 的意见不一，一些开发人员认为该宽松政策会增加存储在区块链上的非金融数据的数量，
      而其他人则认为目前也有其他能添加数据到区块链的方法，所以没有理由阻止人们使用 `OP_RETURN` 输出。

- **Libbitcoin 比特币浏览器安全披露：**几位安全研究人员调查了最近 Libbitcoin 用户丢失比特币的情况，发现该程序的比特币浏览器（bx）工具的 `seed` 命令只生成了大约 40 亿个不同的独特数值。假设攻击者认为这些值会被用来创建私钥或特定派生路径（例如遵循 BIP39）的钱包，他们可以在一天内使用一台普通商用计算机搜索所有可能的钱包，从而能窃取与这些私钥或钱包相关的任何资金。2023 年 7 月 12 日发生了一起可能属于此类盗窃的事件，据称损失了近 30 个比特币（当时的价值大约为 $850,000 美金）。

    几个类似于此种可能导致资金损失的过程在_《精通比特币》_一书中有所描述；在比特币浏览器的[文档主页][bx home]以及比特币浏览器文档的其他许多地方（例如[1][bx1]、[2][bx2]、[3][bx3]）也有描述。除了 `seed` 命令的[在线文档][seed doc]之外，比特币浏览器文档没有明确警告说上述过程不安全。

    Optech 的建议是，如果你认为自己可能使用了 `bx seed` 来生成钱包或地址，请查阅[披露页面][milksad]，并可能使用他们提供的服务来测试易受攻击的种子的哈希值。如果你曾使用的过程与攻击者所发现的相同, 你的比特币很可能已经被盗取了——但是如果你在过程中使用了一种变体，你可能仍然有机会将你的比特币转移到安全的地方。如果你用的钱包或其他软件可能使用到了 Libbitcoin，请告知开发人员有关这个漏洞，并要求他们进行调查。

    我们感谢研究人员在 [CVE-2023-39910][] 的[尽责披露][topic responsible disclosures]方面所做出的重大努力。{% assign timestamp="1:25" %}

## Bitcoin Core PR 审核俱乐部

*在这个月度部分，我们总结了最近的 [Bitcoin Core PR 审核俱乐部][Bitcoin Core PR Review Club]会议，重点介绍了一些重要的问题和答案。单击下面的问题以查看会议答案的总结。*

[静默支付：实现 BIP352][review club 28122] 是由 josibake 提交的一个 PR。它迈出了向 Bitcoin Core 钱包添加[静默支付][topic silent payments]的第一步。这个 PR 只实现 [BIP352][] 的逻辑，并不包括对钱包的变更。{% assign timestamp="53:57" %}

{% include functions/details-list.md
  q0="为什么这个 PR 添加了一个自定义的 ECDH 哈希函数，而不是使用 `secp256k1` 提供的默认函数？"
  a0="实际上，我们 _不_ 想对 ECDH 结果进行哈希处理；自定义函数阻止对 ECDH 操作结果默认应用 `sha256`。当交易的创建者无法控制所有输入时，这是必需的。在 ECDH 期间不对结果进行哈希运算可使得各个参与者仅使用其私钥进行 ECDH，然后一起传递部分 ECDH 结果。然后可以对这些部分 ECDH 结果进行汇总，并执行协议的其余部分（包括使用计数器进行哈希等）。"
  a0link="https://bitcoincore.reviews/28122#l-126"

  q1="这个 PR 添加了用于编码和解码静默支付地址的函数。为什么我们不能只将静默支付地址作为 `CTxDestination` 的一个新的变体来添加，并使用现有的编码器类和解码器函数呢？"
  a1="静默支付地址实际上不会编码特定的输出脚本；它不是一个 `scriptPubKey`。相反，它编码了用于派生实际输出脚本的公钥。该输出脚本还取决于你的沉默支付交易的输入。也就是说，静默支付地址不会给你一个要发送到的 `scriptPubKey`（这是传统地址的作用），而是给你一个可以进行 ECDH 的公钥，然后协议规定如何将该共享秘密转换为接收方能够检测并在此后可花费的 `scriptPubKey`。"
  a1link="https://bitcoincore.reviews/28122#l-153"

  q2="[BIP352][] 提到了版本控制和向前兼容性。什么是向前兼容性，为什么它很重要？"
  a2="它允许（例如）v0 钱包解码并发送到 v1（以及 v2 等）静默支付地址（即使钱包无法生成 v1 地址）。这一点很重要，这样钱包在有新版本时不需要立即升级（否则就失去所有功能）。"
  a2link="https://bitcoincore.reviews/28122#l-170"

  q3="如果新版本想要有意破坏兼容性怎么办？"
  a3="v31 保留给可能破坏兼容性的升级。"
  a3link="https://bitcoincore.reviews/28122#l-186"

  q4="为什么只分配一个破坏兼容性的版本号（v31）是可以接受的？"
  a4="我们可以推迟定义破坏性版本 _之后_ 的版本应如何处理的新规则，直到当需要处理的时候。"
  a4link="https://bitcoincore.reviews/28122#l-188"

  q5="在 `DecodeSilentAddress` 中，有一个对版本和数据大小的检查。这个检查是做什么的，为什么很重要？"
  a5="如果新版本向地址添加了更多数据，我们需要一种方法来获取仅向前兼容的部分。也就是，我们必须限制自己解析前 66 个字节（v0 格式）。这对于向前兼容性非常重要。"
  a5link="https://bitcoincore.reviews/28122#l-194"

  q6="新的静默支付代码位于 `src/wallet/silentpayments.cpp` 目录下。这个位置合适吗？你能想到在钱包环境之外我们要使用静默支付代码的用例吗？"
  a6="想实现一个无钱包服务器，从而代表一个更轻的静默支付钱包来检测静默支付（或进行相关计算），并不理想。可以想象一种使用情况，即全节点给交易的调整数据编制索引，并将其存储在索引中以供轻客户端查询，或通过一个类似 [BIP158][] 的过滤器来提供该数据。但是，在此类用例出现前，将代码放在 `src/wallet` 可以有更好的代码组织结构。"
  a6link="https://bitcoincore.reviews/28122#l-205"

  q7="在 PR 中，`Recipient` 类使用两个私钥进行初始化，即花费密钥和扫描密钥。扫描时是否需要这两个密钥？"
  a7="不需要，只需要扫描密钥。在将来可能会实现无需花费密钥的静默支付扫描功能。"
  a7link="https://bitcoincore.reviews/28122#l-217"
%}

## 版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [BDK 0.28.1][] 是这个流行的构建钱包应用程序的库的一个版本。它包含了错误修订并增加了一个为[描述符钱包][topic descriptors] 中 [P2TR][topic taproot] 使用 [BIP86][] 派生路径的模板。{% assign timestamp="1:12:41" %}

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo] 和 [Bitcoin Inquisition][bitcoin inquisition repo]。*

- [Bitcoin Core #27746][] 简化了区块存储和链状态对象之间的关系。它将是否将区块存储到硬盘的决策移至与当前链状态无关的验证逻辑中。是否将区块存储到硬盘的决策与不需要任何 UTXO 状态的验证规则有关。以前，Bitcoin Core 使用特定链状态的启发式方法来防止 DoS 攻击，但是通过 [assumeUTXO][topic assumeutxo]和两个共存的链状态的可能性，这种方法已经改变，以实现所提议的分离。{% assign timestamp="1:13:06" %}

- [Core Lightning #6376][] 和 [#6475][core lightning #6475] 实现了一个名为 `renepay` 的插件。该插件使用 Pickhardt 支付来构建最佳的[多路径支付][topic multipath payments]（参见 [周报 #192][news192 pp]）。Pickhardt 支付假设每个通道的流动性在流向上随机分布在 0 到满容量之间。较大的支付金额可能会导致失败，因为某条路径可能无法提供足够的流动性；而将支付拆分为多份也可能会导致失败，因为每个单独的路径都有失败的可能性。支付被建模为在闪电网络中的流量（flow），来在支付份数和每份金额之间找到平衡。使用这种方法，Pickhardt 支付找到满足容量和余额约束条件的最佳流量，同时将成功的可能性最大化。来自未完成支付尝试的响应会用来更新所有相关通道的假定流动性分布，减少未能转发的通道，同时还考虑成功暂存的金额。由于在流量计算中加入 [BOLT7][] 基础费用将具有计算上的困难（参见[周报 #163][news163 base]），使用`renepay`进行支付计划的节点将过高估计具有非零基础费用的通道的相对费用。用于传递支付的洋葱数据包使用实际费用。{% assign timestamp="1:15:51" %}

- [Core Lightning #6466][] 和 [#6473][core lightning #6473] 增加了对在 [BIP93][] 中指定的 [codex32][topic codex32] 格式中备份和恢复钱包的[主密钥][topic BIP32]的支持。 {% assign timestamp="1:27:13" %}

- [Core Lightning #6253][] 和 [#5675][core lightning #5675]添加了对[通道拼接][topic splicing]的草案规范 [BOLTs #863][] 的实验性实现。当通道的双方都支持拼接时，它们可以通过在链上进行交易将资金拼入通道，或者通过在链上花费资金将其从通道中拼出。这两种操作都不需要关闭通道，它们可以继续发送、接收或转发支付，同时等待拼入的资金在链上拼接交易得到足够多确认后变得可用。通道拼接的一个关键优点是，启用了闪电网络的钱包可以将他们的大部分资金放在链下，并在被请求时才从该余额里创建一笔链上的支出。这样可以使得钱包只展示一个余额数字，而不用分为链下和链上资金。{% assign timestamp="1:29:13" %}

- [Rust Bitcoin #1945][] 修改了项目的政策，规定了对于一个用于重构的 PR，在合并之前需要进行多少次审查。对于其他在进行重构或者小改动时遇到困难的项目，如果希望将这些改动与其他 PR 一样高标准地进行审查，可以考虑研究 Rust Bitcoin 的新政策。{% assign timestamp="1:30:01" %}

- [BOLTs #759][] 为闪电网络规范添加了对[洋葱消息][topic onion messages]的支持。洋葱消息允许在网络中发送单向消息。与支付（HTLC）一样，这些消息使用洋葱加密，以便每个转发节点只知道它从哪个对等节点接收到消息，以及下一个应该接收消息的对等节点。消息内容也被加密，以便只有最终接收者可以阅读它。转发 HTLC 是双向的，其中承诺向下流向接收者，而用于索要支付的原像则向上流向支出者。与此不同的是，洋葱消息的单向特性意味着，转发节点在消息转发后不需要存储任何关于它们的信息，尽管一些拟议的拒绝服务保护机制确实依赖于在每个对等节点上保留少量的聚合信息（参见[周报 #207][news207 onion]）。原始发送方可以通过在其消息中包含返回路径来实现双向通信。洋葱消息使用几个月前在闪电网络规范中添加的[盲化路径][topic rv routing]（参见[周报 #245][news245 blinded]）。洋葱消息本身被用于正在开发中的[要约协议（offers protocol）][topic offers]。{% assign timestamp="1:32:21" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="27746,6376,6475,6466,6473,6253,5675,863,1945,759,28132,28130" %}
[news245 blinded]: /zh/newsletters/2023/04/05/#bolts-765
[towns dos]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-July/004020.html
[news86 hold fees]: /en/newsletters/2020/02/26/#reverse-up-front-payments
[shikhelman dos]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-July/004033.html
[towns dos2]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004035.html
[kcs endorsement]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004034.html
[todd rbf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-July/021823.html
[towns rbf]: https://github.com/bitcoin/bitcoin/pull/28132#issuecomment-1657669845
[news207 onion]: /zh/newsletters/2022/07/06/#onion-message-rate-limiting
[news261 jamming]: /zh/newsletters/2023/07/26/#channel-jamming-mitigation-proposals
[todd opr]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021840.html
[CVE-2023-39910]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2023-39910
[milksad]: https://milksad.info/
[mb milksad]: https://github.com/bitcoinbook/bitcoinbook/commit/76c5ba8000d6de20b4adaf802329b501a5d5d1db#diff-7a291d80bf434822f6a737f3e564be6a67432e2f3f12669cf0469aedf56849bbR126-R134
[bx home]: https://web.archive.org/web/20230319035342/https://github.com/libbitcoin/libbitcoin-explorer/wiki
[bx1]: https://web.archive.org/web/20210122102649/https://github.com/libbitcoin/libbitcoin-explorer/wiki/How-to-Receive-Bitcoin
[bx2]: https://web.archive.org/web/20210122102714/https://github.com/libbitcoin/libbitcoin-explorer/wiki/bx-mnemonic-new
[bx3]: https://web.archive.org/web/20210506162634/https://github.com/libbitcoin/libbitcoin-explorer/wiki/bx-hd-new
[seed doc]: https://web.archive.org/web/20210122102710/https://github.com/libbitcoin/libbitcoin-explorer/wiki/bx-seed
[news208 rbf]: /zh/newsletters/2022/07/13/#bitcoin-core-25353
[bdk 0.28.1]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.28.1
[review club 28122]: https://bitcoincore.reviews/28122
[bip352]: https://github.com/bitcoin/bips/pull/1458
[bip158]: https://github.com/bitcoin/bips/blob/master/bip-0158.mediawiki
[news192 pp]: /en/newsletters/2022/03/23/#payment-delivery-algorithm-update
[news163 base]: /en/newsletters/2021/08/25/#zero-base-fee-ln-discussion
