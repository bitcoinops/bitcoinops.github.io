---
title: 'Bitcoin Optech Newsletter #347'
permalink: /zh/newsletters/2025/03/28/
name: 2025-03-28-newsletter-zh
slug: 2025-03-28-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的新闻部分介绍了一项允许闪电通道基于可燃烧的输出支持预付和驻留手续费的提议，还总结了关于 testnet3 和 testnet4 的讨论（包括一项硬分叉提议），还宣布了一项开始转发包含 taproot 附言 的特定交易的计划。此外是我们的常规部分：来自 Bitcoin Stack Exchange 的精选问题和回答、软件的新版本和候选版本的发行公告，还有热门比特币基础设施软件的重大变更介绍。

## 新闻

- **<!--ln-upfront-and-hold-fees-using-burnable-outputs-->使用可燃烧的输出实现闪电通道的预付手续费和驻留手续费**：John Law 在 Delving Bitcoin 论坛中[公开][law fees]了他所撰写的一份协议[论文][law fee paper]的总结；凭借这份协议，节点可以向转发的支付收取另外两种类型的手续费。一种称作 “预付手续费（*upfront fee*）”，由源头支付者支付，用于补偿临时占用一个 HTLC 卡槽（*HTLC slot*）而给转发节点造成的负担（HTLC 卡槽是为强制执行 [HTLCs][topic htlc] 而对并发数量设置的限制之一）。另一种称作 “驻留手续费（*hold fee*）”，由任何会推迟 HTLC 的结算的节点支付；这种手续费的数量会随着时延的增加而增加，在 HTLC 过期的时间点会达到最大数值。他的帖子和论文引用了以往多项关于预付手续费和驻留手续费的讨论，例如 Optech 在各期新闻部分总结的：[#86][news86 reverse upfront]、[#119][news119 trusted upfront]、[#120][news120 upfront]、[#122][news122 bi-directional]、[#136][news136 more fee] 和 [#263][news263 dos philosophy]。

  这份协议建立在 Law 的 “链下支付解决（offchain payment resolution，OPR）” 协议（详见 [周报 #329][news329 opr]）基础上。OPR 协议要求通道的双方都分配 100% 数量的资金（总计是 200%）到一个可燃烧的输出（*burnable output*）中，任何一方都可以单方面摧毁这些资金。而在新协议中，这些风险资金就是预付手续费加上最大的驻留手续费。如果双方都满意于对方正确地遵守了协议，例如所有的手续费都正确支付了，那就从他们链下支付的未来版本中移除相关的可燃烧的输出。如果任何 一方不满意，那就可以关闭通道、销毁那个可燃烧的输出。虽然这时候不满意的一方也会损失资金，但对方也是如此，这就阻止了任何一方从违反协议中受益。

  Law 表示，这也是 “[通道阻塞攻击][topic channel jamming attacks]” 的一种解决方案。通道阻塞攻击是闪电网络协议的一个弱点，[已被发现近十年了][russell loop]，这个弱点让攻击者可以几乎不必付出任何代价，就阻止一个受害者节点使用自己部分甚至全部资金。在一个[回复][harding fee]中，有人指出，驻留手续费的加入可能也会让 “驻留型发票（[hold invoices][topic hold invoices]）” 对整个网络变得更加可持续。

- **<!--discussion-of-testnets-3-and-4-->** **关于 testnet 3 和 testnet 4**：Sjors Provoost 在 Bitcoin-Dev 邮件组中[发帖][provoost testnet3]询问是否有人还在使用 testnet 3，毕竟 testnet 4 已经运行了大约 6 个月了（详见[周报 #315][news315 testnet4]）。Andres Schildbach [回复][schildbach testnet3] 称希望在他的热门的钱包的测试网版本中继续使用 testnet 3 至少 1 年。Olaoluwa Osuntokun [指出][osuntokun testnet3]，testnet 3 最近已经变得比 testnet 4 可靠得多。他附上来自 [Fork.Observer][] 网站的关于两个测试网的区块树截图来证明自己的观点。下面是我们自己的截图，显示了撰文之时 testnet 4 的状态：

  ![Fork Monitor showing the tree of blocks on testnet4 on 2025-03-25](/img/posts/2025-03-fork-monitor-testnet3.png)

  在 Osuntokun 的帖子之后，Aotoine Poinsot 开设了一个[独立的帖子][poinsot testnet4]来关注 testnet 4 的问题。他声称 tesenet 4 的问题是难度重设规则的结果。这个规则只存在于测试网上，允许一个区块亿最低难度成为有效区块，如果其区块头时间比父区块的时间晚 20 分钟以上的话。Provoost 给出了关于这个问题的更多[细节][provoost testnet4]。Poinsot 提议在 testnet 4 上执行一次硬分叉来移除这个规则。Mark Erhardt [建议][erhardt testnet4]了执行日期：2026 年 1 月 8 日。

- **<!--plan-to-relay-certain-taproot-annexes-->转发特定 taproot 附言的计划**：Peter Todd 在 Bitcoin-Dev 邮件组中[宣布][todd annex]了他升级自己的基于 Bitcoin Core 的节点 Libre Relay 的计划：开始转发包含 taproot 附言（[annexes][topic annex]）的交易，只要这些附言遵循下列规则：

  * *<!--0x00-prefix-->* *以 0x00 为前缀*：“所有非空的附言都必须以字节 0x00 开始，以区分自身与【未来的】共识相关的附言。”
  * *<!--all-or-nothing-->全有或全无*：“所有输入都必须有一段附言。这保证了使用附言是选择性加入的，可以阻止多方协议中的[交易钉死攻击][topic transaction pinning]。”

  这一计划基于 2023 年由 Joost Jager 提出的 [PR][bitcoin core #27926]，该 PR 又基于 Jager 在更早的时候开启的一项讨论（详见 [周报 #255][news255 annex]）。用 Jager 的话来说，这份 PR 也 “限制了无结构的附言数据不能超过 256 字节【...】一定程度上也保护了在多方交易中使用附言的参与者，避免附言的膨胀。”Todd 的版本并不包含这条规则，他认为 “选择性加入使用附言的规则就足够了”。如果还不够，他提出了一项额外的转发规则变更，可以防止对手方钉死攻击。

  截至本刊撰写之时，在当前的邮件组帖子中，还没有人说明自己准备如何使用附言。

## Bitcoin Stack Exchange 的精选问答

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--why-is-the-witness-commitment-optional-->为什么对区块中的见证数据的承诺只是可选加入的？]({{bse}}125948) Pieter Wuille 和 Antoine Poinsot 介绍了 [BIP30][] “重合交易的处理”、[BIP34][] “v2 版本区块，在 Coinbase 交易中标注区块高度” 、“[共识清理][topic consensus cleanup]” 提议围绕 [702 problem]983 的考虑，以及强制使用见证承诺可以如何解决这个问题。

- [<!--can-all-consensus-valid-64-byte-transactions-be-third-party-malleated-to-change-their-size-->所有在共识上有效的 64 字节长的交易都可以被（第三方）熔融以至于改变其体积吗？]({{bse}}125971) Sjors Provoost 解释了，如果[共识清理][topic consensus cleanup]软分叉得到激活，那么熔融任何[64 字节长的交易][news27 64tx]都会变成共识上无效的。Vojtěch Strnad 主张并不是所有的 64 字节长的交易都可以被第三方熔融，但如果这样的交易带有不安全的（可被任何人花费）或者可证不可花费的输出（例如 `OP_RETURN` 输出）时，就一定可被熔融。

- [<!--how-long-does-it-take-for-a-transaction-to-propagate-through-the-network-->一笔交易要花多长时间才能传遍网络？]({{bse}}125776) Sr_gi 指出，单个节点无法度量出一笔交易在整个网络中的传播时间，必须使用分布在网络中的多个节点。他也指出，由 KIT（卡尔斯鲁厄理工学院）的 “去中心化系统与网络服务研究小组” 运行的一个[网站][dsn kit]度量了交易传播时间（以及其它指标），研究结果显示：“一笔交易要花大概 7 秒的时间来传遍 50% 的网络，要花 17 秒钟才能传遍 90% 的网络。”

- [<!--utility-of-longterm-fee-estimation-->长期手续费估计的用途]({{bse}}124227) Abubakar Sadiq Ismail 在寻找来自项目、协议以及依赖于长期手续费估计的用户对他在[手续费估计][topic fee estimation]上的工作的反馈。

- [<!--why-are-two-anchor-outputs-are-used-in-the-ln-->为什么在闪电通道中要使用两个锚点输出？]({{bse}}125883) Instabibbs 提供了在当前的闪电网络中使用 “[锚点输出][topic anchor outputs]” 的历史背景，并指出：因为 [Bitcoin Core 28.0 引入的交易池规则变更][28.0 wallet guide]，闪电网络规范已经有升级到 “[v3 版承诺交易][topic v3 commitments]” 的计划。

- [<!--why-are-there-no-bips-in-the-2xx-range-->为什么没有编号为 “2xx” 的 BIP？]({{bse}}125914) Michael Folkson 指出，BIP 的从 200 到 299 的编号空间一定程度上是保留给跟闪电网络相关的 BIP 的。

- [<!--why-doesnt-bech32-use-the-character-b-->为什么 Bech32 编码不使用小写字母 “b”？]({{bse}}125902) Bordalix 回复说，大写字母 “B” 和数字 “8” 是 [bech32 和 bech32m][topic bech32] 地址编码中不使用 “B” 的理由。他还提供了关于 bech32 的额外知识。

- [<!--bech32-error-detection-and-correction-reference-implementation-->Bech32 错误检测和纠正的参考实现]({{bse}}125961) Pieter Wuille 指出，在地址编码中出现的错误不超过 4 个时，bech32 是可以侦测出来的；而且它还可以纠正不超过两个字符的替换错误。

- [<!--how-to-safely-spendburn-dust-->如何安全地 花费/烧掉 粉尘输出？]({{bse}}125702) Murch 列出了在为现有的钱包清理[粉尘输出][topic uneconomical outputs]输出时要考虑的事情。

- [<!--how-is-the-refund-transaction-in-asymmetric-revocable-commitments-constructed-->在构造好的非对称可撤销承诺交易中，退款交易是什么样的？]({{bse}}125905) Biel Castellarnau 历数了来自《精通比特币》一书的承诺交易的例子。

- [<!--which-applications-use-zmq-with-bitcoin-core-->什么应用在使用 Bitcoin Core 的 ZMQ 服务？]({{bse}}125920) Sjors Provoost 正在寻找 Bitcoin Core 的 ZMQ 服务的用户，希望研究 [IPC][news320 ipc] 是否能取代这些用法。

## 新版本和候选版本

*热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Bitcoin Core 29.0rc2][] 是这种网络主流全节点实现的下一个主要版本的候选发行。请阅读《[29 版本测试指南][bcc29 testing guide]》。

- [LND 0.19.0-beta.rc1][] 是这个流行的闪电节点实现的候选发行。可能需要测试的主要提升之一是新的基于 RBF 的手续费追加法，用在合作式关闭场景中，详情见下文的重大代码变更章节。

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Bitcoin Core #31603][] 更新了 `ParsePubkeyInner` 解析器，以拒绝开头或结尾有空格的公钥，从而让解析动作与 [rust-miniscript][rust miniscript] 项目一致。由于描述符校验和的保护，以往应该也无法意外加入空格。现在，`getdescriptorinfo` 和 `importdescriptors` RPC 命令会传出错误，如果一个[descriptor][topic descriptors]中的公钥包含这样的空格的话。

- [Eclair #3044][] 出于抵御链重组的通道安全性考虑，将默认的最小确认数要求从 6 提高到 8 。该 PR 也取消了该数值基于通道注资数量的缩放，因为通道容量可能在 “[通道拼接][topic splicing]” 期间剧烈改变，所以说服节点接收一个更小的确认数量会让大量资金处在风险之中。

- [Eclair #3026][] 为使用 [Pay-to-Taproot (P2TR)][topic taproot] 地址的 Bitcoin Core 钱包添加支持（包括由 Eclair 管理的观察钱包），作为实现 “[简单 taproot 通道][topic simple taproot channels]” 的基础。一些手动关闭交易依然要求使用 P2WPKH 脚本，即使正在使用 P2TR 钱包。

- [LDK #3649][]  通过加入必要的字段，增加了使用 [BOLT12 offers][topic offers] 给闪电网络服务商（LSPs）支付的功能。以往，只能使用 [BOLT11][] 和链上支付选项。这也是 [BLIPs #59][] 的提议。

- [LDK #3665][] 将 [BOLT11][] 发票的体积限制从 1023 字节提高到 7089 字节，以跟 LND 的限制保持一致；这个数值基于可以放进一个 QR 码中的最大字节数。该 PR 的作者说，跟 BOLT 11 发票的编码兼容的 QR 码实际上最多只能承载 4296 个字符，但 LDK 还是选择了 7089 这个数值，因为 “系统层面的一致性可能是更重要的。”

- [LND #8453][]、[#9559][lnd #9559]、[#9575][lnd #9575]、[#9568][lnd #9568] 和 [LND #9610][] 引入了一种基于 [BOLTs #1205][] 的 [RBF][topic rbf] 合作关闭流程（详见[周报 #342][news342 closev2]） ，这种流程让任何一方都能使用自己的通道资金来提高手续费率。以往，一方有时候必须说服对手方追加手续费，这常常会失败。若要启用这一特性，需要设置 `protocol.rbf-coop-close` 的配置标签。

- [BIPs #1792][] 更新了 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] 的规范 [BIP119][]。具体来说，修改了措辞从而使之更加清晰、移除了激活逻辑、将 “Eltoo” 重命名为 “[LN-Symmetry][topic eltoo]”，还增加了新的[限制条款][topic covenants]提议和使用 `OP_CTV` 的项目（比如[Ark][topic ark]）的引用。

- [BIPs #1782][] 修订了 [BIP94][] 的规范部分的格式，变得更加清晰易读；该 BIP 列举了 [testnet4][topic testnet] 的共识规则。

{% include references.md %}
{% include linkers/issues.md v=2 issues="31603,3044,3026,3649,3665,9610,1792,1782,27926,8453,9559,9575,9568,1205,59" %}
[bitcoin core 29.0rc2]: https://bitcoincore.org/bin/bitcoin-core-29.0/
[bcc29 testing guide]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/29.0-Release-Candidate-Testing-Guide
[lnd 0.19.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc1
[news255 annex]: /zh/newsletters/2023/06/14/#discussion-about-the-taproot-annex-taproot-annex
[news315 testnet4]: /zh/newsletters/2024/08/09/#bitcoin-core-29775
[fork.observer]: https://fork.observer/
[law fees]: https://delvingbitcoin.org/t/fee-based-spam-prevention-for-lightning/1524/
[law fee paper]: https://github.com/JohnLaw2/ln-spam-prevention
[news329 opr]: /zh/newsletters/2024/11/15/#mad-based-offchain-payment-resolution-opr-protocol
[harding fee]: https://delvingbitcoin.org/t/fee-based-spam-prevention-for-lightning/1524/4
[provoost testnet3]: https://mailing-list.bitcoindevs.xyz/bitcoindev/9FAA7EEC-BD22-491E-B21B-732AEA15F556@sprovoost.nl/
[schildbach testnet3]: https://mailing-list.bitcoindevs.xyz/bitcoindev/7c28f8e9-d221-4633-8b71-53b4db07fa78@schildbach.de/
[osuntokun testnet3]: https://groups.google.com/g/bitcoindev/c/jYBlh24OB-Y/m/vbensqcZAwAJ
[poinsot testnet4]: https://mailing-list.bitcoindevs.xyz/bitcoindev/hU75DurC5XToqizyA-vOKmVtmzd3uZGDKOyXuE_ogE6eQ8tPCrvX__S08fG_nrW5CjH6IUx7EPrq8KwM5KFy9ltbFBJZQCHR2ThoimRbMqU=@protonmail.com/
[provoost testnet4]: https://mailing-list.bitcoindevs.xyz/bitcoindev/2064B7F4-B23A-44B0-A361-0EC4187D8E71@sprovoost.nl/
[erhardt testnet4]: https://mailing-list.bitcoindevs.xyz/bitcoindev/7c6800f0-7b77-4aca-a4f9-2506a2410b29@murch.one/
[todd annex]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Z9tg-NbTNnYciSOh@petertodd.org/
[russell loop]: https://diyhpl.us/~bryan/irc/bitcoin/bitcoin-dev/linuxfoundation-pipermail/lightning-dev/2015-August/000135.txt
[news263 dos philosophy]: /zh/newsletters/2023/08/09/#dos
[news136 more fee]: /zh/newsletters/2021/02/17/#renewed-discussion-about-bidirectional-upfront-ln-fees
[news122 bi-directional]: /zh/newsletters/2020/11/04/#bi-directional-upfront-fees-for-ln
[news86 reverse upfront]: /zh/newsletters/2020/02/26/#reverse-up-front-payments
[news119 trusted upfront]: /zh/newsletters/2020/10/14/#trusted-upfront-payment
[news120 upfront]: /zh/newsletters/2020/10/21/#more-ln-upfront-fees-discussion
[news342 closev2]: /zh/newsletters/2025/02/21/#bolts-1205
[rust miniscript]: https://github.com/rust-bitcoin/rust-miniscript
[dsn kit]: https://www.dsn.kastel.kit.edu/bitcoin/#propdelaytx
[28.0 wallet guide]: /zh/bitcoin-core-28-wallet-integration-guide/
[news320 ipc]: /zh/newsletters/2024/09/13/#bitcoin-core-30509
[news27 64tx]: /zh/newsletters/2018/12/28/#cve-2017-12842
