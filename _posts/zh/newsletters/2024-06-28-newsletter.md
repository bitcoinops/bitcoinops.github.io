---
title: 'Bitcoin Optech Newsletter #309'
permalink: /zh/newsletters/2024/06/28/
name: 2024-06-28-newsletter-zh
slug: 2024-06-28-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报总结了关于估算闪电网络支付可行性的研究。还包括我们常规的部分，描述了 Bitcoin Stack Exchange 上的热门问题和答案，宣布了新版本和候选版本，以及总结了流行的比特币基础设施项目的显著变化。

## 新闻

- **<!--estimating-the-likelihood-that-an-ln-payment-is-feasible-->估算 LN 支付的可行性:** René Pickhardt [发布][pickhardt feasible1]了一篇关于在已知通道最大容量但不知道其当前余额分布的情况下来估算 LN 支付可行性的文章。例如，Alice 与 Bob 有一个通道，而 Bob 与 Carol 有一个通道。Alice 知道 Bob-Carol 通道的容量，但不知道其中有多少余额由 Bob 控制，有多少由 Carol 控制。

Pickhardt 指出，某些财富分布在支付网络中是不可能的。例如，Carol 在她与 Bob 的通道中无法收到超过该通道容量的钱。当排除了所有不可能的分布情况后，可以认为所有剩余的财富分布发生的可能性相同。这可以用于生成支付可行性的指标。

例如，如果 Alice 想向 Carol 发送 1 BTC 支付，而唯一可以通过的通道是 Alice-Bob 和 Bob-Carol，那么我们可以查看 Alice-Bob 通道和 Bob-Carol 通道中允许该支付成功的财富分布百分比。如果 Alice-Bob 通道的容量为几个 BTC，大多数可能的财富分布都将允许支付成功。如果 Bob-Carol 通道的容量仅刚刚超过 1 BTC，那么大多数可能的财富分布将无法使得支付成功。这可以用于计算从 Alice 到 Carol 的 1 BTC 支付的整体可行性。

可行性指标清楚地表明，许多看似可能的 LN 支付在实际中不会成功。它还提供了一个有用的比较基础。在一个[回复][pickhardt feasible2]中，Pickhardt 描述了钱包和商业软件如何使用可行性指标自动为用户做出一些智能决策。

## 来自 Bitcoin Stack Exchange 的精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 的贡献者们寻找答案的首选之地，也是他们有闲暇时会给好奇和困惑的用户帮忙的地方。在这个月度栏目中，我们会列举自上次出刊以来出现的一些高票的问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aa
nswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--how-is-the-progress-of-initial-block-download-ibd-calculated-->如何计算初始区块下载（IBD）的进度？]({{bse}}123350)
  Pieter Wuille 指出 Bitcoin Core 的 `GuessVerificationProgress` 函数，并解释了使用硬编码的统计数据估计的链上总交易量。这些统计数据会在每次主要版本中进行更新。

- [<!--what-is-progress-increase-per-hour-during-synchronization-->同步期间的“每小时进度增加”是什么？]({{bse}}123279)
  Pieter Wuille 澄清了每小时进度增加是每小时同步的区块链百分比，而不是进度率的增加。他还指出了进度不恒定且可能变化的原因。

- [<!--should-an-even-y-coordinate-be-enforced-after-every-key-tweak-operation-or-only-at-the-end-->在每次密钥调整操作后，还是仅在最后强制要求偶数 Y 坐标？]({{bse}}119485)
  Pieter Wuille 同意在何时执行密钥取反操作以强制要求 [x-only 公钥][topic X-only public keys]在很大程度上是一个理念问题，同时指出了不同协议中的优缺点。

- [<!--signet-mobile-phone-wallets-->Signet 手机钱包？]({{bse}}123045)
  Murch 列出了四个兼容 [signet][topic signet] 的移动钱包应用程序：Nunchuk、Lava、Envoy 和 Xverse。

- [<!--what-block-had-the-most-transaction-fees-why-->哪个区块的交易手续费最多？为什么？]({{bse}}7582)
  Murch 发现区块 409,008 的比特币计费最高（由于缺少找零输出导致的 291.533 BTC 手续费），而区块 818,087 的美元计费最高（$3,189,221.5 美元，推测同样是由于缺少找零输出导致）。

- [<!--bitcoin-cli-listtransactions-fee-amount-is-way-off-why-->bitcoin-cli listtransactions 的手续费金额为什么偏差很大？]({{bse}}123391)
  Ava Chow 指出这种差异发生在 Bitcoin Core 的钱包不知道交易中的其中一个输入但知道其他输入的情况下，例如问题中给出的 [payjoin][topic payjoin] 交易。她继续指出“钱包不应该返回手续费，因为它不能准确确定手续费”。

- [<!--did-uncompressed-public-keys-use-the-04-prefix-before-compressed-public-keys-were-used-->未压缩的公钥在使用压缩公钥之前是否使用了“04”前缀？]({{bse}}123252)
  Pieter Wuille 解释说，历史上签名验证是通过 OpenSSL 库完成的，该库允许未压缩（“04”前缀）、压缩（“02”和“03”前缀）和混合（“06”和“07”前缀）公钥。

- [<!--what-happens-if-an-htlcs-value-is-below-the-dust-limit-->如果 HTLC 的值低于尘埃限制会发生什么？]({{bse}}123393) Antoine Poinsot 指出，LN 承诺交易中的任何输出都可能低于[粉尘限制][topic uneconomical outputs]，这将导致这些输出中的聪被用于手续费（参见[修剪 HTLC][topic trimmed htlc]）。

- [<!--how-does-subtractfeefrom-work-->subtractfeefrom 如何工作？]({{bse}}123262) Murch 概述了 Bitcoin Core 中的[钱币选择][topic coin selection]在使用可选的 `subtractfeefrom` 时的工作方式。他还指出，使用 `subtractfeefromoutput` 在找到无找零交易时会导致几个错误。

- [<!--what-s-the-difference-between-the-3-index-directories-blocks-index-bitcoin-indexes-and-chainstate-->“blocks/index/”，“bitcoin/indexes” 和 “chainstate” 三个索引目录之间有什么区别？]({{bse}}123364)
  Ava Chow 列出了一些 Bitcoin Core 中的数据目录：

  - `blocks/index`，包含区块索引的 LevelDB 数据库
  - `chainstate/`，包含 UTXO 集的 LevelDB 数据库
  - `indexes/`，包含 txindex、coinstatsindex 和 blockfilterindex 可选索引

## 版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [LND v0.18.1-beta][] 是一个小版本，修复了在使用旧版本（v0.24.2 之前）的 btcd 后端尝试广播交易后处理错误时出现的[问题][lnd #8862]。

- [Bitcoin Core 26.2rc1][] 是 Bitcoin Core 旧版系列的维护版本候选版本。

## 显著的代码和文档更改

_本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。_

- [Bitcoin Core #29575][] 简化了对等节点不当行为评分系统，只使用两个增量：100 分（导致立即断开连接和阻止）和 0 分（允许的行为）。大多数类型的不当行为是可以避免的，并已被提升到 100 分，而两种诚实且正常运行的节点在某些情况下可能会执行的行为被减少到 0 分。这个 PR 还删除了只考虑包含最多八个区块头的 P2P `headers` 消息作为可能的新区块 [BIP130][] 公告的启发式方法。Bitcoin Core 现在将所有不连接到节点已知区块树的 `headers` 消息视为潜在的新区块公告，并请求任何缺失的区块。

- [Bitcoin Core #28984][] 添加了对一个有限版本的[手续费替换(Replace-By-Fee)][topic rbf] 的支持，支持族群大小为 2 （一个父，一个子）的[交易包][topic package relay]，包括在确认前拓扑受限(Topologically Restricted Until Confirmation，[TRUC][topic v3 transaction relay])的交易（即 v3 交易）。这些族群只能替换相同或更小的现有族群。参见[周报 #296][news296 packagerbf] 了解相关背景。

- [Core Lightning #7388][] 移除了创建非零手续费[锚点输出(anchor-style)][topic anchor outputs] 通道的能力，以符合 2021 年 BOLT 规范的更改（参见[周报 #165][news165 anchors]），同时保持对现有通道的支持。Core Lightning 是唯一完全添加此功能的实现，并且仅在实验模式下；后来发现它并不安全（参见[周报 #115][news115 anchors]）并被零手续费锚点通道取代。其他更新包括拒绝包含 `scid` 和 `node` 的 `encrypted_recipient_data`，解析添加到洋葱规范中的 LaTeX 格式，以及周报 [#259][news259 bolts] 和 [#305][news305 bolts] 中提到的其他 BOLT 规范更改。

- [LND #8734][] 改进了用户中断 `lncli estimateroutefee` RPC 命令时的支付路线估算中止过程，使支付循环可感知到客户端支付流的上下文。以前，中断此命令会导致服务器不必要地继续使用[支付探针][topic payment probes]路线。参见[周报 #293][news293 routefee] 中对该命令的引用。

- [LDK #3127][] 实现了非严格转发，以提高支付可靠性，如 [BOLT4][] 中所规定的，允许 [HTLC][topic htlc] 通过指定在洋葱消息中 `short_channel_id` 之外的通道转发给对等节点。该实现会选择可通过 HTLC 中有最少出站流动性的通道，以最大化后续 HTLC 成功的概率。

- [Rust Bitcoin #2794][] 通过向 `ScriptHash` 和 `WScriptHash` 添加易错构造函数，限制 P2SH 的赎回脚本上限为 520 字节、P2WSH 的见证脚本上限为 10,000 字节。

- [BDK #1395][] 移除了对 `rand` 显式和隐式的使用依赖，改用了 `rand-core` 以简化依赖，避免 `thread_rng` 和 `getrandom` 的附加复杂性，并通过允许用户传递自己的随机数生成器（RNG）提供更大的灵活性。

- [BIPs #1620][] 和 [BIPs #1622][] 增加了 [BIP352][] 规范中有关[静默支付][topic silent payments]的变更内容。在 `secp256k1` 库中实现静默支付的 PR 讨论中，建议 [BIP352][] 添加边角案例的处理。具体来说，处理发送和扫描的无效私钥/公钥和：（对发送方）私钥和为零会失败，（对接收方）公钥和是无穷远处的点也会失败。在 #1622 中，BIP352 被更改为在密钥聚合之后计算 `input_hash`，而不是之前，以减少冗余，并使过程对于发送方和接收方更清晰。

- [BOLTs #869][] 在 BOLT2 上引入了新的通道静止协议，旨在通过确保[协议升级][topic channel commitment upgrades]和支付通道的重大变化过程中有一个稳定的通道状态，使这些变更过程更安全、更高效。该协议引入了一种新消息类型 `stfu`（SomeThing Fundamental is Underway），只有在协商 `option_quiesce` 时才可以发送。发送 `stfu` 后，发送方停止所有更新消息。接收方应停止发送更新并尽可能响应 `stfu`，以便通道完全静止。参见周报 [#152][news152 quiescence] 和 [#262][news262 quiescence]。

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29575,28984,7388,8734,3127,2794,1395,1620,1622,869,8862" %}
[bitcoin core 26.2rc1]: https://bitcoincore.org/bin/bitcoin-core-26.2/
[pickhardt feasible1]: https://delvingbitcoin.org/t/estimating-likelihood-for-lightning-payments-to-be-in-feasible/973
[pickhardt feasible2]: https://delvingbitcoin.org/t/estimating-likelihood-for-lightning-payments-to-be-in-feasible/973/4
[lnd v0.18.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.1-beta
[news296 packagerbf]: /zh/newsletters/2024/04/03/#bitcoin-core-29242
[news259 bolts]: /zh/newsletters/2024/05/31/#bolts-1092
[news305 bolts]: /zh/newsletters/2023/07/12/#ln
[news293 routefee]: /zh/newsletters/2024/03/13/#lnd-8136
[news152 quiescence]: /en/newsletters/2021/06/09/#c-lightning-4532
[news262 quiescence]:/zh/newsletters/2023/08/02/#eclair-2680
[news115 anchors]: /en/newsletters/2020/09/16/#stealing-onchain-fees-from-ln-htlcs
[news165 anchors]: /en/newsletters/2021/09/08/#bolts-824
