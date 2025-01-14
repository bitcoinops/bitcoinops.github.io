---
title: 'Bitcoin Optech Newsletter #154'
permalink: /zh/newsletters/2021/06/23/
name: 2021-06-23-newsletter-zh
slug: 2021-06-23-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 介绍了一个允许所有交易进行 RBF（Replace-by-Fee）的提案，并带来了新系列文章“为 taproot 做准备”的首篇。此外，我们也照例介绍了对客户端和服务端的更新、新软件版本与候选发布，以及常用比特币基础设施项目的值得注意的变更内容。

## 新闻

- **<!--allowing-transaction-replacement-by-default-->****允许默认进行交易替换：** 目前，大多数比特币全节点都被认为实现了 [BIP125][] 中的选择性 RBF（[Replace By Fee][topic rbf]），这允许未确认交易在节点的内存池中被其他支付更高手续费的版本所替换——但前提是交易创建者在原始交易中设置了相应信号。最初提出此种选择性机制是因为希望进行交易替换（例如用于手续费提升或[批量支付添加][additive payment batching]）的人，与反对者（因为交易替换会让诈骗使用未确认交易的商家变得更容易）之间存在分歧。

  五年多时间过去后，似乎目前很少商家在将未确认交易视为最终交易，而且尚不清楚这些商家中有多少真的在检查 BIP125 的选择性信号并对其区别对待。如果没人依赖 BIP125 信号，那么默认允许所有交易都可被替换，或许能带来以下好处：

  - **<!--simplifying-analysis-->****简化对预签名交易协议的分析**
    （例如用于闪电网络和[保险库][topic vaults]等）——其中，利用 RBF 来提高手续费的设想，必须考虑到恶意对手方可以阻止在原始交易中设置 BIP125 信号。如果任何交易都能被替换，则无需担心这一点。

  - **<!--reducing-transaction-analysis-opportunity-->****减少交易分析机会**
    因为开启 RBF 的交易与未开启 RBF 的交易在链上表现不同。目前大多数钱包要么一致地选择开启，要么一致地选择不开启；这种差异为监控公司提供了分辨谁拥有哪些比特币的线索。假如所有交易都可替换，就无需再设置 BIP125 信号了。

  本周，Antoine Riard 在 Bitcoin-Dev 邮件列表[发布][riard rbf]了一项提案，最终可能让 Bitcoin Core 无视 BIP125 选择性信号来支持所有交易的 RBF 功能。该想法在首次交易中继研讨会[会议][trw meeting]上也进行了讨论。与会者提及了 Bitcoin Core [PR #10823][bitcoin core #10823] 作为一种替代方案——它允许任何交易被替换，但仅限在交易已在节点内存池中存在一定时长（最初提议 6 小时，后也有人建议 72 小时）之后。

  无论选择哪种方法，当讨论扩大到允许替换未设置 BIP125 信号的交易时，都需要考虑目前依赖 BIP125 行为的商家意见。Optech 也鼓励所有此类商家在邮件列表上发表看法。

## 对服务和客户端软件的更改

*在本月度栏目中，我们聚焦介绍比特币钱包和服务的有趣动态。*

- **<!--trezor-suite-adds-rbf-support-->****Trezor Suite 添加 RBF 支持：**
  Trezor 的钱包软件 Trezor Suite 在 21.2.2 版本中[添加了对 RBF 的支持][trezor rbf]。RBF 默认开启，并已在部分 Trezor 硬件设备中得到支持。

- **<!--lightning-labs-announces-terminal-web-->****Lightning Labs 宣布 Terminal Web：**
  在一篇[博客][lightning labs terminal web blog]中，Lightning Labs 介绍了他们的基于 Web 的闪电网络节点评分仪表盘 [Terminal Web][terminal web]。

- **<!--specter-v1-4-0-released-->****Specter v1.4.0 发布：**
  [Specter v.1.4.0][specter v1.4.0] 中增加了一个使用 BIP125 选择性 [RBF][topic rbf] “[取消”交易][specter 1197]的功能。

- **<!--phoenix-adds-lnurl-pay-->****Phoenix 增加 LNURL-pay：**
  ACINQ 的移动钱包 [Phoenix][phoenix wallet] 在 [v1.4.12 版本][phoenix 1.4.12]中添加了对 [LNURL-pay][lnurl-pay github] 协议的支持。

- **<!--joinmarket-v0-8-3-released-->****JoinMarket v0.8.3 发布：**
  [JoinMarket v0.8.3][joinmarket v0.8.3] 新增了为找零地址自定义设置的功能，以及与 Electrum 兼容的隔离见证 `signmessage` 实现。

## 为 taproot 做准备 #1：支持 Bech32m 的转账功能

*这是一个每周更新的[系列][series preparing for taproot]的第一篇，讲述开发者和服务提供商如何为预定在区块高度
{{site.trb}} 激活的 taproot 做准备。*

{% include specials/taproot/zh/00-bech32m.md %}

## 发布与候选发布

*适用于常用比特币基础设施项目的新版本与候选发布版本。请考虑升级到新版本，或协助测试候选发布版本。*

- [LND 0.13.0-beta][]
  这是一次主要版本更新，通过将 [anchor outputs][topic anchor outputs] 设为默认承诺交易格式来改进手续费管理，新增了对修剪过的比特币完整节点的支持，允许使用原子多路径支付（Atomic MultiPath，简称 [AMP][topic multipath payments]）进行接收与发送，并进一步提升了 [PSBT][topic psbt] 功能。此外还包含其他多项改进与错误修复。

## 值得注意的代码和文档更改

*以下是本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]中的值得注意的更改：*

- [Bitcoin Core #21365][]
  为钱包在[花费 taproot][topic taproot] 时创建签名提供了支持，包括仅使用 P2TR 公钥的键路径签名，以及使用 [tapscript][topic tapscript] 的脚本路径签名。钱包也可为基于 taproot 的 [PSBT][topic psbt] 进行签名，但前提是钱包已具备全部键路径或脚本路径所需的信息。与此相关的另一个合并的拉取请求 [#22156][bitcoin core #22156] 仅在 taproot 激活（主网上是区块高度 {{site.trb}}）后允许导入这些键路径和脚本路径信息；对于已经启用 taproot 的测试网络，则可立即使用该导入功能。

- [Bitcoin Core #22144][]
  随机化了在消息处理线程中服务各节点的顺序。该线程负责解析和处理来自各节点的 P2P 消息，并向这些节点发送消息。此前，消息处理线程会按照节点连接先后顺序轮流服务各节点。现在，每次循环时为节点分配服务顺序都将是随机的，从而避免了基于固定服务顺序可能导致的潜在安全弱点或可利用之处，同时仍确保每个节点服务频次相同（在每次循环中服务一次）。

- [Bitcoin Core #21261][]
  简化了将更多网络纳入入站连接保护的流程，随后也将 [I2P][] 列入了受保护网络。多样化保护（常被称作 eviction protection）可使具有特定特征的节点在 Bitcoin Core 剔除高延迟连接时依然保持连接。保留通过匿名网络连接的节点对同时想隐藏网络身份和在常规 IP 之外接收区块的用户而言都非常重要，从而能防范某些[日蚀攻击][topic eclipse attacks]的形式。

- [Rust Bitcoin #601][]
  为解析 [bech32m][topic bech32] 地址提供了支持，并强制要求对 v1 及后续版本的原生 segwit 地址使用 bech32m 而非 bech32 进行编码。

- [BTCPay Server #2450][]
  当用户选择启用热钱包接收付款时，默认会生成具有 [payjoin][topic payjoin] 功能的兼容发票。*创建钱包*界面上的一个按钮允许用户取消此默认设置。

- [BTCPay Server #2559][]
  增加了一个独立的界面，引导用户选择如何为其钱包支出交易进行签名。对于热钱包，服务器可直接签名；但若密钥储存在其他地方，该界面会以更直观的图形方式指导用户选择不同的签名方式，例如：输入恢复助记词、使用硬件签名设备，或生成 PSBT 文件以在可签名的钱包中进行操作。

{% include references.md %}
{% include linkers/issues.md issues="10823,21365,22156,22144,21261,601,2450,2559" %}
[LND 0.13.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.13.0-beta.rc5
[trw meeting]: https://gist.githubusercontent.com/ariard/5f28dffe82ddad763b346a2344092ba4/raw/2a8e0d4ff431a225a970d0128aa78616df6b6382/meeting-logs
[additive payment batching]: /zh/cardcoins-rbf-batching/
[riard rbf]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-June/019074.html
[i2p]: https://en.wikipedia.org/wiki/I2P
[phoenix wallet]: https://phoenix.acinq.co/
[phoenix 1.4.12]: https://github.com/ACINQ/phoenix/releases/tag/v1.4.12
[lnurl-pay github]: https://github.com/fiatjaf/lnurl-rfc/blob/master/lnurl-pay.md
[joinmarket v0.8.3]: https://github.com/JoinMarket-Org/joinmarket-clientserver/releases/tag/v0.8.3
[specter v1.4.0]: https://github.com/cryptoadvance/specter-desktop/releases/tag/v1.4.0
[specter 1197]: https://github.com/cryptoadvance/specter-desktop/pull/1197
[terminal web]: https://terminal.lightning.engineering/
[lightning labs terminal web blog]: https://lightning.engineering/posts/2021-05-11-terminal-web/
[trezor rbf]: https://wiki.trezor.io/Replace-by-fee_(RBF)
