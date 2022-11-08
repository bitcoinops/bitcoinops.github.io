---
title: 'Bitcoin Optech Newsletter #223'
permalink: /zh/newsletters/2022/10/26/
name: 2022-10-26-newsletter-zh
slug: 2022-10-26-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报总结了关于启用完全 RBF 交易池策略的持续讨论，并为一场 CoreDev.tech 会议的多个讨论的转录稿提供了概述，还介绍了一份为闪电网络这样的合约协议涉及临时锚定输出的提议。此外还有我们的常规栏目：来自 Bitcoin Stack Exchange 的热门问题，软件的新版本和候选版本，热门比特币基础设施软件的重大变更。

## 新闻

- **<!--continued-discussion-about-full-rbf-->关于全面 RBF 的持续讨论**：在[上一周的周报][news222 rbf]，我们总结了在 Bitcoin-Dev 邮件组中发生的关于纳入一个新的 `mempoolfullrbf` 选项的讨论，这个选项可能会给许多接受零确认交易（“zero conf”）作为支付手段的企业带来问题。讨论在本周继续，既发生在邮件组中，也发生在 #bitcoin-core-dev IRC 频道中。讨论的重点包括：

  - *<!--free-option-problem-->免费期权问题*：Sergej Kotliar [警告][kotliar free option]说，他认为所有类型的交易替换手段都有一个最大的问题：它们创建了一种免费的美式期权。举个例子，客户 Alice 希望从商家 Bob 处购买一些小工具。Bob 给了 Alice 一张 1 BTC 的发票，此时的比特币美元汇率为 20,000 USD/BTC。Alice 在一笔较低费率的交易中给 Bob 发送了 1 BTC。这笔交易一直没有确认，直到汇率变成了 25000 USD/BTC，意思是现在 Alice 多付了 5000 美元。这时候，她非常理性地选择替换掉这笔交易，换成一笔把多余的 BTC 转回给子集的交易，这本质上是取消了原来的交易。但是，要是汇率变成了对 Alice 有利的情形（例如，变成了 15000 USD/BTC），Bob 没法取消 Alice 的交易，所以他没有办法在正常的链上比特币交易流中行使相同的期权；这就产生了一种不对称的汇率风险。相比之下，如果不能使用交易替换手段，那么 Alice 和 Bob 将承担相同的汇率风险。

    Kotliar 提到，因为 [BIP125][] 选择性 [RBF][topic rbf]，这个问题在今天已经存在了，但他认为全面 RBF（full-RBF）会让事情变得更加严重。

    Greg Sanders 和 Jeremy Rubin [分别][rubin cpfp]在邮件中[回复][sanders cpfp]指出，商家 Bob 可以使用 [CPFP][topic cpfp]（“子为父偿”）来激励矿工快点确认 Alice 原来那一笔交易，尤其是网络启用了[package relay][topic package relay]（“交易包转发”）特性的话。

    Antoine Riard [指出][riard free option]，相同的风险也存在于闪电网络中，因为 Alice 可以一直拖着，拖到不能再拖时才支付给商家 Bob，所以她可以等待汇率改变。不过，在这种情况下，如果 Bob 注意到汇率发生了很大的变化，他可以命令自己的节点拒绝接受这笔支付，将资金返回给 Alice。

  - *<!--bitcoin-core-not-in-charge-of-network-->Bitcoin Core 并没有掌控整个网络*：Gloria Zhao 在 IRC 讨论中[写道][zhao no control]：“我认为，无论我们选择了什么，都应该向用户充分说明：Core 不能决定全面 RBF 的去留。我们可以回滚 [25353][bitcoin core #25353]，但全面 RBF 可能依然会落地 ……。”

    在会议之后，Zhao 也为当前的局面作了一份详细的 [说明][zhao overview]。

  - *<!--no-removal-means-the-problem-could-happen-->不移除就意味着可能出问题*：在 IRC 讨论中，Anthony Towns [重复][towns uncoordinated]了他在上周提出的观点，“如果我们不从 24.0 中移除 `mempoolfullrbf`，我们就要准备面对不协调的部署。”

    Greg Sanders [表示怀疑][sanders doubt]，“问题在于，会有超过 5% 的人启用吗？我认为不会。”Towns [回复][towns uasf]道，“[UASF][topic soft fork activation] `uacomment` 表明，可能几周内就会有大约 11% 的人启用。”

  - *<!--should-be-an-option-->应该允许选择*：Martin Zumsande 在 IRC 讨论中[说][zumsande option]，“我认为，如果大量的节点运营者和矿工都想要某一个交易池策略，那么开发者有责任出面解释 “为什么你现在还不能用这个”。开发者可以，也应该（通过设置默认值）给出建议，但向充分知情的用户提供选择绝对没错。”

  截至本期通讯撰写之时，还没有出现明确的正式决定。`mempoolfullrbf` 选项依然包含在即将到来的 Bitcoin Core 24.0 的候选版本中。并且，Optech 建议，任何依赖于零确认交易的服务都应该仔细地评估风险。也许你可以从阅读[上周的周报][news222 rbf]中链接的邮件开始。

- **<!--coredevtech-transcripts-->CoreDev.tech 记录稿**：在亚特兰大比特币大会（TabConf）之前，大约 40 位开发者出现在了 CoreDev.tech 活动中。Bryan Bishop 已经提供了活动中大概半数的会议的记录稿。重要的讨论包括：

  - [<!--transport-encryption-->流量加密][p2p encryption]：关于[版本 2 的流量加密协议][topic v2 p2p transport]提案（见[周报 #222][news222 bip324]）的最近升级的一场对话。这套协议将使网络的监听者更难发现一笔交易由哪个 IP 地址发起，而且提升了在诚实节点间侦测和抵抗中间人攻击的能力。

    这场讨论涵盖了多项协议设计上的考量，如果你想理解协议作者为什么要作出某些决定，你可以读读这份记录稿。讨论还探究了当前的协议与更早的 [countersign][topic countersign]（“会签”）身份验证协议的关系。

  - [<!--fees-->手续费][fee chat]：一场关于交易手续费的过去、现在和未来的广泛讨论。话题包括为什么区块几乎总是满的而交易池不是、还需要多久我们才能发展出一个可观的手续费市场从而不再需要[担心][topic fee sniping]比特币的长期生存，以及，如果我们认为问题确实存在，可以采取什么样的解决方案。

  - [FROST][]：一个关于 FROST 门限签名协议的演讲。这份记录稿还记录了几个非常棒的密码学设计选择的技术问题，对任何有志于学习 FROST 和广义密码学协议设计的人都值得一读。亦可读 TabConf 的 [ROAST][] 主题演讲的记录稿，这是比特币的另一种门限签名方案。

  - [GitHub][github chat]：关于把 Bitcoin Core 项目的 git 记录从 Github 迁移到另一种 Issue 和 PR 管理解决方案的讨论，也考虑了继续使用 Github 的好处。

  - [在 BIP 中使用可证明的规范][hacspec chat]：关于在 BIP 中使用 [hacspec][] 详述语言来证明详述正确性的部分讨论。亦可见 TabConf 的一场相关演讲的[记录稿][hacspec preso]。

  - [交易包转发与 v3 版本的交易转发][package relay chat]：这场演讲介绍了启用[交易包转发][topic package relay]特性并使用新的交易转发方法，从而消除特定情形下的[钉死攻击][topic transaction pinning]的多种提议。

  - [Stratum v2][stratum v2 chat]：这场讨论从宣布一个新的实现 Stratum v2 矿池协议的开源项目开始。Stratum v2 作出的提升包括带身份验证的连接、个体矿工（即本地拥有挖矿设备的人）可以选择挖掘哪些交易（而不是由矿池来选择）。除了许多其它好处，讨论还提到，允许个体矿工选择自己的区块模板，对于担心政府强制 要求/限制 纳入哪些交易的矿池可能求之不得，就像 [Tornado Cash][] 事件所体现的一样。大部分讨论都围绕着 Bitcoin Core 需要作哪些变更才能原生支持 Stratum v2。亦可见 TabConf 的关于 [Braidpool][braidpool chat]（一种去中心化的矿池协议）的记录稿。

  - [<!--Merging-->代码合并][merging chat]讨论了帮助 Bitcoin Core 项目中的代码得到审核的各种策略，虽然许多建议也适用于其它项目。其中的想法包括：

    - 把大的变更分成多个小的 PR。

    - 让审核者更容易理解代码的终极目标。这意味着，所有 RP 都需要附带写明动机描述。对于正在逐步推进的变更，使用跟踪 issue、项目看板，并通过使用重构后的代码来激励重构，以实现所追求的目标。

    - 为长期运营的项目生产概要的解释，描述项目诞生的背景、当前的进展、将采取什么办法来实现结果，以及它能给用户带来的好处。

    - 跟那些对同一个项目或者代码子系统感兴趣的人形成工作团队。

- **<!--ephemeral-anchors-->临时的锚点输出**：Greg Sander 跟进了关于 v3 交易转发功能的讨论（见[周报#220][news220 ephemeral]），在 Bitcoin-Dev 邮件组中[发帖][sanders ephemeral]提出了一种新型的 “[锚点输出][topic anchor outputs]”。v3 版本的交易可以不支付手续费、只包含一个支付给 `OP_TRUE` 脚本的输出；这样的脚本允许任何人在子交易中花费它而不违反共识规则。这笔未确认的零手续费父交易，只有在它是一个交易包的一部分且交易包内包含了花费该 OP_TRUE 输出的子交易时，才会被 Bitcoin Core 转发和挖出。这只会影响 Bitcoin Core 的交易池策略，不需要改变网络的共识。

  Greg Sander 称该提议的优点包括：它不再需要使用一个区块的相对时间锁（在脚本代码后加上 `1 OP_CSV`）来防止[交易钉死][topic transaction pinning]，同时任何人都可以为这笔父交易追加手续费（类似于更早的 “[手续费捐赠][topic fee sponsorship]” 软分叉提议）。

  Jeremy Rubin [表示][rubin ephemeral]支持这个提议，但也指出，无法使用 v3 交易的合约就无法使用这套方法。多位开发者讨论了这个概念，截至本刊撰写之时，他们所有人似乎都认为这很有吸引力。

## Bitcoin Stack Exchange 的精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者们有疑问时寻找答案的首选之一 —— 也是我们有闲暇时会帮助好奇和困惑的用户的地方。在这个月刊中，我们会列出自上次出刊以来一些高票的问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--why-would-someone-use-a-1of1-multisig-->为什么有人会使用 1-of-1 的多签名？]({{bse}}115443) Vojtěch Strnad 询问为什么有人会同通过 P2WPKH 使用 1-of-1 的多签名，因为 P2WPKH 明明更便宜而且匿名集更大。Murch 列出了许多资料，证明了至少有一个实体，在过去几年中花费了几百万个 1-of-1 的 UTXO，但动机不明。

- [<!--why-would-a-transaction-have-a-locktime-in-the-year-1987-->为什么这笔交易的锁定时间是 1987 年？]({{bse}}115549) 1440000bytes 指出，来自 Christian Decker 的一个评论引用了 BOLT 3 闪电网络规范的[节选][bolt 3 commitment]，该规范将时间锁字段解释为 “高 8 位是 0x20，低 24 位是模糊化的承诺交易号的低 24 位”。

- [<!--what-is-the-size-limit-on-the-utxo-set-if-any-->有没有对 UTXO 集体积的限制？]({{bse}}115439) Pieter Wuille 回答了，共识上没有对 UTXO 集体积的限制，但 UTXO 集的增长率受到区块体积的限制，因为区块的体积限制了单个区块内可以创建的 UTXO 的数量。在一个[相关回答][se murch utxo calcs]中，Murch 估计，为地球上的每个人创建一个 UTXO 需要大约 11 年。

- [<!--why-is-blockmaxweight-set-to-3996000-by-default-->为什么 `-blockmaxweight` 默认设成 399 6000？]({{bse}}115499) Vojtěch Strnad 指出，Bitcoin Core 中的 `-blockmaxweight` 参数默认设置是 399 6000，小于隔离见证的 400 0000 重量单位（WU）。Pieter Wuille 解释道，这个差值允许矿工加入比区块模板创建的默认 coinbase 交易体积更大的 coinbase 交易。

- [<!--can-a-miner-open-a-lightning-channel-with-a-coinbase-output-->矿工可以使用 coinbase 交易的输出来开启闪电通道吗？]({{bse}}115588) Murch 指出，一个矿工如果想使用自己的 coinbase 交易的输出来创建一条闪电通道，那么通道的开关时延就要加入 coinbase 交易的成熟期，而且，需要持续不断地沟通通道开启事宜，因为 coinbase 交易的哈希值在挖矿期间是不断变化的。

- [<!--what-is-the-history-on-how-previous-soft-forks-were-tested-prior-to-being-considered-for-activation-->之前的软分叉在被考虑激活之前，是如何做测试的？]({{bse}}115434) Michael Folkson 引用了来自 Anthony Towns 的[最近的一份邮件][aj soft fork testing]，该帖子介绍了围绕 P2SH、CLTV、CSV、隔离见证，[taproot][topic taproot] 和 [Drivechain][topic sidechains] 提议的测试。

## 新版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [LDK 0.0.112][] 是这个帮助开发闪电网络应用的库的新版本。

- [Bitcoin Core 24.0 RC2][] 是这个最广泛使用的全节点软件的下一个版本的候选。这里还有一份[测试指南][bcc testing]。

  **<!--warning-->警告**：这一版软件包含了 `mempoolfullrbf` 配置选项；许多协议和应用开发者认为可能对商家服务造成影响；详见本周和上周的周报。Optech 建议任何可能受影响的服务都评估一下这份请求意见稿，并参与公开讨论。

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo] 和 [Lightning BOLTs][bolts repo]。*

- [Bitcoin Core #23443][] 加入了一种新的 P2P 协议消息 `sendtxrcncl`（发送交易），允许节点告知对等节点自己支持 [erlay][topic erlay] 协议。这个 PR 只加入了 erlay 协议的第一部分 —— 要加入其它部分才能实际用上。

- [Eclair #2463][] 和 [#2461][eclair #2461] 升级了 Eclair 的[交互式双向注资协议][topic dual funding]实现，要求注资交易的每一笔输入都选择使用 [RBF][topic rbf] 并且同时是经过确认的（即，花费一个已经在区块链上的输出）。这些变更保证了可以使用 RBF，而且不会有任何一方提供的手续费被用来帮助对手的前序交易确认。

{% include references.md %}
{% include linkers/issues.md v=2 issues="23443,2463,2461,25353" %}
[bitcoin core 24.0 rc2]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[ldk 0.0.112]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.112
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/24.0-Release-Candidate-Testing-Guide
[news222 rbf]: /zh/newsletters/2022/10/19/#transaction-replacement-option
[kotliar free option]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021056.html
[sanders cpfp]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021060.html
[rubin cpfp]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021059.html
[riard free option]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021067.html
[zhao no control]: https://www.erisian.com.au/bitcoin-core-dev/log-2022-10-20.html#l-440
[towns uncoordinated]: https://www.erisian.com.au/bitcoin-core-dev/log-2022-10-20.html#l-488
[sanders doubt]: https://www.erisian.com.au/bitcoin-core-dev/log-2022-10-20.html#l-490
[towns uasf]: https://www.erisian.com.au/bitcoin-core-dev/log-2022-10-20.html#l-492
[zumsande option]: https://www.erisian.com.au/bitcoin-core-dev/log-2022-10-20.html#l-493
[coredev xs]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/
[p2p encryption]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-10-p2p-encryption/
[news222 bip324]: /zh/newsletters/2022/10/19/#bip324
[fee chat]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-11-fee-market/
[frost]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-11-frost/
[roast]: https://diyhpl.us/wiki/transcripts/tabconf/2022/roast/
[github chat]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-11-github/
[hacspec chat]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-11-hac-spec/
[hacspec]: https://hacspec.github.io/
[hacspec preso]: https://diyhpl.us/wiki/transcripts/tabconf/2022/hac-spec/
[package relay chat]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-11-package-relay/
[stratum v2 chat]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-11-stratum-v2/
[tornado cash]: https://www.coincenter.org/analysis-what-is-and-what-is-not-a-sanctionable-entity-in-the-tornado-cash-case/
[braidpool chat]: https://diyhpl.us/wiki/transcripts/tabconf/2022/braidpool/
[merging chat]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-12-merging/
[news220 ephemeral]: /zh/newsletters/2022/10/05/#ephemeral-dust
[sanders ephemeral]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021036.html
[rubin ephemeral]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021041.html
[zhao overview]: https://github.com/glozow/bitcoin-notes/blob/full-rbf/full-rbf.md
[bolt 3 commitment]: https://github.com/lightning/bolts/blob/316882fcc5c8b4cf9d798dfc73049075aa89d3e9/03-transactions.md#commitment-transaction
[se murch utxo calcs]: https://bitcoin.stackexchange.com/questions/111234/how-many-useable-utxos-are-possible-with-btc-inside-them/115451#115451
[aj soft fork testing]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/020964.html
