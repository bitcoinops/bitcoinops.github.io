---
title: 'Bitcoin Optech Newsletter #325'
permalink: /zh/newsletters/2024/10/18/
name: 2024-10-18-newsletter-zh
slug: 2024-10-18-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报回顾了最近闪电网络开发者会议的一些讨论。还包括我们的常规部分，描述了流行的客户端和服务的变化，宣布了新版本和候选版本，以及总结了比特币基础设施软件的重要变更。

## 新闻

- **<!--ln-summit-2024-notes-->2024 闪电网络峰会笔记：** Olaoluwa Osuntokun 在 Delving Bitcoin 上[发布][osuntokun summary]了他最近参加的闪电网络开发者会议的[笔记][osuntokun notes]（包括额外的评论）。讨论的一些主题包括：

  - **<!--version-3-commitment-transactions-->****V3 承诺交易：** 开发者讨论了如何使用[新的 P2P 功能][bcc28 guide]，包括 [TRUC][topic v3 transaction relay] 交易和 [P2A][topic ephemeral anchors] 输出，以提高闪电网络承诺交易的安全性，这些交易可以用于单方面关闭通道。讨论集中在各种设计的权衡上。

  - **PTLCs：** 尽管已被提议作为闪电网络的隐私升级很久，也可能用于其他方面，如[无阻塞交易][topic redundant overpayments]等，最近对[PTLC][topic ptlc] 各种可能实现的优缺点权衡的研究才刚刚得到讨论（详见[周报 #268](news268 ptlc)）。其中特别关注的一点是[适配器签名][topic adaptor signatures]的构造（例如使用脚本化多重签名与无脚本的 [MuSig2][topic musig]）及其对承诺协议的影响（见下一项）。

  - **<!--state-update-protocol-->状态更新协议：** 讨论了一项提案，将闪电网络当前的状态更新协议从允许任何一方在任何时候提出更新，改为每次只允许一方提出更新（参见周报 [#120][news120 simcom] 和[#261][news261 simcom]）。允许双方提出更新可能导致双方同时提出更新。这种情况很难推演，并可能导致意料外的通道强制关闭。替代方案是一次只由一方来负责，例如，最初只允许 Alice 提出状态更新；如果她没有要提出的更新，她可以告诉 Bob 让他来负责。当 Bob 完成提出更新时，他就可以将控制权转回给 Alice。这简化了对协议的推演，消除了因同时提议而导致的问题，并进一步使非控制方容易拒绝任何不想要的提议。新的基于回合的协议也将与基于 MuSig2 的签名适配器配合得很好。

  - **SuperScalar：** 一个为终端用户提出的[通道工厂][topic channel factories]构造的开发者介绍了该提案并征求反馈。Optech 将在未来的周报中发布关于 [SuperScalar][zmnscpxj superscalar] 的更详细描述。

  - **<!--gossip-upgrade-->****Gossip 升级：** 开发者讨论了对[闪电网络 gossip 协议][topic channel announcements]的升级。最迫切需要这些升级的是用于支持新类型的注资交易，例如[简单 taproot 通道][topic simple taproot channels]，但也可能增加对其他功能的支持。已讨论的一个新功能是让通道公告消息包含 SPV 证明（或对 SPV 证明的承诺），以允许轻量级客户端验证资金交易（或赞助交易）在某个时点被包含在区块中。

  - **<!--research-on-fundamental-delivery-limits-->****对基本传递限制的研究：** 介绍了关于由于网络限制（例如，通道容量不足）而无法成功的支付流的研究；参见[周报 #309][news309 feasible]。如果闪电网络支付不可行，支付者和接收者总是可以使用链上支付。然而，链上支付的速率受到最大区块重量的限制，因此可以通过将最大链上速率除以闪电支付受阻的概率，来计算比特币和闪电网络系统组合的最大吞吐量（每秒支付次数）。使用这个粗略的指标，要达到每秒约 47,000 次支付的最大值，支付受阻的概率必须低于 0.29%。会议上讨论了两种降低受阻概率的技术：(1) 涉及两个以上参与方的虚拟或实际通道。因为更多参与方意味着更多的转发资金，而更多的转发资金增加了可行支付的概率；(2) 信用通道。其中相互信任的各方可以在彼此之间转发支付，而无需在链上强制执行这些支付——所有其他用户仍然接收无信任支付。

  Osuntokun 鼓励其他参与者在帖子中发表修正或扩展内容。

## 服务和客户端软件的变更

*在这个月度栏目中，我们重点介绍比特币钱包和服务的有趣更新。*

- **<!--coinbase-adds-taproot-send-support-->****Coinbase 增加 taproot 发送支持：**
  Coinbase 交易所[现在支持][coinbase post]用户提现（发送）到 taproot [bech32m][topic bech32] 地址。

- **<!--dana-wallet-released-->****Dana 钱包发布：**
  [Dana 钱包][dana wallet github]是一个专注于捐赠用例的[静默支付][topic silent payments]钱包。开发者建议使用 [signet][topic signet]，并且还运行了一个 signet [水龙头][dana wallet faucet]。

- **<!--kyoto-bip157-158-light-client-released-->****Kyoto BIP157/158 轻客户端发布：**
  [Kyoto][kyoto github] 是一个使用[致密区块过滤器][topic compact block filters]的 Rust 轻客户端，供钱包开发者使用。

- **<!--dlc-markets-launches-on-mainnet-->****DLC Markets 在主网上线：**
  这款基于 [DLC][topic dlc] 的平台[宣布][dlc markets blog]其非托管交易服务已在主网上可用。

- **<!--ashigaru-wallet-announced-->****Ashigaru 钱包公布：**
  Ashigaru 是 Samourai 钱包项目的一个 fork。[公告][ashigaru blog]列出了对[批量支付][scaling payment batching]、[RBF][topic rbf] 支持和[费用估算][topic fee estimation]的改进。

- **<!--datum-protocol-announced-->****DATUM 协议宣布：**
  类似于 Stratum v2 协议，[DATUM 挖矿协议][datum docs]在[矿池挖矿][topic pooled mining]设定中，允许矿工构建候选区块。

- **<!--bark-ark-implementation-announced-->****Bark Ark 实现宣布：**
  Second 团队[宣布][bark blog]了 [Ark][topic ark] 协议的 [Bark][bark codeberg] 实现，并[演示][bark demo]了主网上的实时 Ark 交易。

- **<!--phoenix-v2-4-0-and-phoenixd-v0-4-0-released-->****Phoenix v2.4.0 和 phoenixd v0.4.0 发布：**
  [Phoenix v2.4.0][phoenix v2.4.0] 和 [phoenixd v0.4.0][] 版本增加了对 [BLIP36][blip36] 即时资金提案和其他流动性功能的支持（参见 [播客 #323][pod323 eclair]）。

## 发布和候选发布

*热门比特币基础设施项目的新版本和候选发布版本。请考虑升级到新版本或帮助测试候选版本。*

- [BDK 1.0.0-beta.5][] 是这个用于构建钱包和其他带有比特币功能的应用程序的库的发布候选版本（RC）。这个最新的 RC “默认启用 RBF，并更新 bdk_esplora 客户端以重试因费率限制而失败的服务器请求。`bdk_electrum` crate 现在还提供了 use-openssl 功能。”

## 重要代码和文档变更

_本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。_

- [Bitcoin Core #30955][] 为 `Mining` 接口引入了两个新方法（参见周报 [#310][news310 mining]），符合 [Stratum V2][topic pooled mining] 的要求。`submitSolution()` 方法允许矿工更高效地提交区块的解，其中只需要 nonce、时间戳、版本字段和 coinbase 交易，而不是整个区块。此外，引入了 `getCoinbaseMerklePath()` 来构造 `NewTemplate` 消息中所需的 merkle 路径字段。这个 PR 还恢复了之前在 [Bitcoin Core #13191][] 中被移除的 `BlockMerkleBranch`。

- [Eclair #2927][] 为空中加油注资（on-the-fly，参见周报 [#323][news323 fly]）添加了推荐费率的强制执行。实现方法是拒绝那些使用低于推荐值的费率的 `open_channel2` 和 `splice_init` 消息。

- [Eclair #2922][] 不再支持没有通道静止的[通道拼接][topic splicing]（参见周报 [#309][news309 quiescence]），以符合 [BOLTs #1160][] 中提出的最新拼接协议。该协议要求节点在拼接期间使用静止协议。之前的实现允许在一个相对非正式的机制下进行拼接，只要承诺交易已经是静止的，就可以处理拼接请求（也即是通道静止的一个“低配版”）。

- [LDK #3235][] 为 `ChannelForceClosed` 事件添加了 `last_local_balance_msats` 字段。该字段给出了节点在通道被强制关闭之前的本地余额（以 msats 为单位），允许用户知道由于四舍五入而损失了多少 msats。

- [LND #8183][] 在[静态通道备份][topic static channel backups]（SCB）文件的 `chanbackup.Single` 结构中添加了可选的 `CloseTxInputs` 字段，用于存储生成强制关闭交易所需的输入。这允许用户在对等方离线时使用 `chantools scbforceclose` 命令手动检索资金，作为最终恢复选项。然而，用户应该格外小心，因为如果通道在备份创建后已更新，这个功能可能导致资金损失。此外，PR 引入了 `ManualUpdate` 方法，该方法将在 LND 关闭时更新通道备份。

- [Rust Bitcoin #3450][] 添加了 v3 作为交易版本的新变体。这是跟随了 Bitcoin Core 将[确认前拓扑限制 (TRUC)][topic v3 transaction relay] 交易作为标准的脚本（参见周报 [#307][news307 truc]）。

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30955,2927,2922,3235,8183,3450,13191,1160" %}
[BDK 1.0.0-beta.5]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.5
[osuntokun summary]: https://delvingbitcoin.org/t/ln-summit-2024-notes-summary-commentary/1198
[osuntokun notes]: https://docs.google.com/document/d/1erQfnZjjfRBSSwo_QWiKiCZP5UQ-MR53ZWs4zIAVcqs/edit?tab=t.0#heading=h.chk08ds793ll
[news268 ptlc]: /zh/newsletters/2023/09/13/#ptlc-ln
[news120 simcom]: /en/newsletters/2020/10/21/#simplified-htlc-negotiation
[news261 simcom]: /zh/newsletters/2023/07/26/#simplified-commitments
[zmnscpxj superscalar]: https://delvingbitcoin.org/t/superscalar-laddered-timeout-tree-structured-decker-wattenhofer-factories/1143
[news309 feasible]: /zh/newsletters/2024/06/28/#estimating-the-likelihood-that-an-ln-payment-is-feasible-ln
[bcc28 guide]: /zh/bitcoin-core-28-wallet-integration-guide/
[coinbase post]: https://x.com/CoinbaseAssets/status/1843712761391399318
[dana wallet github]: https://github.com/cygnet3/danawallet
[dana wallet faucet]: https://silentpayments.dev/
[saving satoshi editor]: https://script.savingsatoshi.com/
[kyoto github]: https://github.com/rustaceanrob/kyoto
[dlc markets blog]: https://blog.dlcmarkets.com/dlc-markets-reshaping-bitcoin-trading/
[ashigaru blog]: https://ashigaru.rs/news/release-wallet-v1-0-0/
[datum docs]: https://ocean.xyz/docs/datum
[bark blog]: https://blog.second.tech/ark-on-bitcoin-is-here/
[bark codeberg]: https://codeberg.org/ark-bitcoin/bark
[bark demo]: https://blog.second.tech/demoing-the-first-ark-transactions-on-bitcoin-mainnet/
[phoenix v2.4.0]: https://github.com/ACINQ/phoenix/releases/tag/android-v2.4.0
[phoenixd v0.4.0]: https://github.com/ACINQ/phoenixd/releases/tag/v0.4.0
[blip36]: https://github.com/lightning/blips/pull/36
[pod323 eclair]: /en/podcast/2024/10/08/#eclair-2848-transcript
[news310 mining]:/zh/newsletters/2024/07/05/#bitcoin-core-30200
[news323 fees]: /zh/newsletters/2024/10/04/#eclair-2860
[news323 fly]: /zh/newsletters/2024/10/04/#eclair-2861
[news309 quiescence]:/zh/newsletters/2024/06/28/#bolts-869
[news307 truc]: /zh/newsletters/2024/06/14/#bitcoin-core-29496
