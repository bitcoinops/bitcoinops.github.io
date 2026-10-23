---
title: 'Bitcoin Optech Newsletter #130'
permalink: /zh/newsletters/2021/01/06/
name: 2021-01-06-newsletter-zh
slug: 2021-01-06-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了对 BIP322 通用消息签名提案的更新建议，并链接了 LN 蹦床路由的规范。此外，还包括发布与候选发布的公告，以及热门比特币基础设施软件的值得注意的变更。

## 新闻

- **<!--proposed-updates-to-generic-signmessage-->****通用消息签名提案的更新建议：** Andrew Poelstra [发布][poelstra post]了对 [BIP322][] 通用消息签名提案的部分重写。这次重写主要是澄清签名和验证流程，但现在也允许未实现整套检查的钱包，对使用自己看不懂的脚本的签名返回“结果不确定”状态。例如，一位想快速实现通用消息签名的开发者，可以选择只为 P2PKH、P2WPKH 和 P2SH-P2WPKH 脚本实现签名验证，这已覆盖当前和历史输出中的很大一部分。对于其他情况，钱包可以返回“结果不确定”，并可以引导用户使用更全面的验证工具。

- **<!--trampoline-routing-->****蹦床路由：** Bastien Teinturier 向 Lightning-Dev 邮件列表[发布][teinturier post]了一份关于[蹦床路由][topic trampoline payments]的新[规范][tramp spec]，让付款方无需计算自己节点与收款方节点之间的路由。付款方改为把钱路由到一个附近的蹦床节点，由它计算路由的下一段——把钱送到收款方，或送到下一个蹦床节点。这对使用轻量级 LN 客户端的付款方尤其有用：这类客户端经常离线，或因其他原因无法跟踪网络 gossip 来自行计算路由。

  Teinturier 指出，ACINQ 一直在为其 Phoenix 钱包用户运行一个单跳（single-bounce）蹦床节点。这带来了找到合适路由的好处，但正如一篇[博客文章][acinq post]所述，这也意味着 ACINQ 能看到其所有用户支付的目的地。这个问题的解决方案，是允许路由节点对外宣告自己能够接受洋葱包裹的蹦床路由：付款方 Alice 先把钱发给一个蹦床节点（例如 ACINQ 的节点），然后可能再发给其他蹦床节点，最后到达收款节点。这样，任何单个蹦床节点都无法同时得知付款方和收款方的节点标识符。提议的规范将提供一种标准化方式来实现这一点。

  Teinturier 认为：“代码改动非常合理，因为它重用了每个 LN 实现中已有的许多组件，也没有引入新的假设。”

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [Eclair 0.5.0][] 是一个新的主要版本，增加了对可扩展集群模式（参见 [Newsletter #128][news128 akka]）、区块链看门狗（[Newsletter #123][news123 watchdog]）和额外插件钩子的支持，此外还有众多其他功能和错误修复。

- [Bitcoin Core 0.21.0rc5][Bitcoin Core 0.21.0] 是该全节点实现及其配套钱包等软件的下一个主要版本的候选发布。截至本文撰写时，这个最新的候选发布尚未上传，但我们希望它能在发布后不久上线。

- [LND 0.12.0-beta.rc3][LND 0.12.0-beta] 是该 LN 节点下一个主要版本的最新候选发布。它让[锚定输出][topic anchor outputs]成为承诺交易的默认配置，并在其[瞭望塔][topic watchtowers]实现中加入对锚定输出的支持，从而降低成本、提高安全性。该版本还增加了创建和签署[部分签名比特币交易（PSBT）][topic psbt]的通用支持，并包含若干错误修复。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[比特币改进提案 (BIPs)][bips repo]和[闪电网络规范 (BOLTs)][bolts repo]中值得注意的变更。*

- **<!--bitcoin-core-19137-adds-dump-and-createfromdump-commands-to-wallet-tool-->**[Bitcoin Core #19137][] 为 [`wallet-tool`][news45 wallet-tool] 添加了 `dump` 和 `createfromdump` 命令，使用户可以将钱包记录写入转储文件，并随后从该转储文件恢复钱包。这些命令不仅对测试有用，也是[从传统钱包迁移][achow101 legacy timeline]工作的一部分。

- **<!--bitcoin-core-20365-updates-the-bitcoin-wallet-tool-->**[Bitcoin Core #20365][] 更新了 `bitcoin-wallet` 工具的 `create` 命令，增加了一个 `-descriptors` 标志，用于创建 [基于 sqlite 的描述符钱包][news120 sqlite]，类似守护进程的 [createwallet RPC][news96 createwallet]。

- **<!--bitcoin-core-20599-updates-message-handling-code-->**[Bitcoin Core #20599][] 更新了消息处理代码，使其可以处理在对等节点发送 `verack` 消息之前收到的 `sendheaders` 和 `sendcmpct` 消息。`sendheaders`（[BIP130][]）和 `sendcmpct`（[BIP152][]）的规范并未要求这些消息必须在 `verack` 消息之后发送，最初的实现（[Bitcoin Core #7129][] 和 [Bitcoin Core #8068][]）也允许在 `verack` 之前接收和处理这些消息。后来的一个 PR（[Bitcoin Core #9720][]）让 Bitcoin Core 不再处理在 `verack` 之前收到的这些消息。本次 PR 恢复了最初的行为。

- [Bitcoin Core #18772][] 更新了 `getblock` RPC，当使用 `verbosity=2` 参数时，返回一个新的 `fee` 字段，其中包含区块中每笔交易的总手续费。这依赖于节点存储的额外区块撤销数据，用于处理区块链重组。撤销数据与其他区块交易数据分开存储，启用修剪的节点可能会在删除其他数据之前删除撤销数据，因此修剪节点有时可能返回不包含 `fee` 字段的结果。

- [Bitcoin Core GUI #162][] 为 GUI 的 Peers 窗口添加了一个新的可排序网络列，并在对等详情区域添加了一个新的网络行。在这两处，GUI 会向用户显示对等方通过的网络类型：IPv4、IPv6 或 Onion，并具有显示两个潜在未来扩展项（I2P 和 CJDNS）的能力。该 PR 还将 NodeId 和 Node/Service 列标题重命名为 Peer Id 和 Address。

- [C-Lightning #4207][] 添加了关于备份节点数据的广泛 [新文档][cl doc/backup.md]。

- [Eclair #1639][] 默认启用了 [BOLT3][] 的 `option_static_remotekey`，允许 Eclair 满足通道对等节点的请求，把支付始终发往同一个公钥。这使得远程对等节点即使丢失了一些通道状态，也能轻松在链上找到并花费这些支付。该 PR 的描述指出，Eclair 开发者现在启用这个选项，是因为 LND 的 0.12.0-beta 版本将使其成为强制要求。

- [Rust Bitcoin #499][] 增加了对两个全局 [PSBT][topic psbt] 字段的支持，这两个字段是在 [BIP174][] 最初发布之后才规定的：

  1. 扩展公钥字段，可让签名钱包检测找零（见 [Newsletter #55][news55 psbt xpub]）

  2. 版本号字段，有助于识别 PSBT 规范中不向后兼容的变更（见 [Newsletter #72][news72 psbt version]）

  这是 [#473][Rust Bitcoin #473] 所述更大努力中最后几项改动之一，目的是让 Rust Bitcoin 的 PSBT 实现与当前规范保持一致。

{% include references.md %}
{% include linkers/issues.md issues="19137,20365,20651,20660,20616,20599,20624,18772,162,4207,4256,4257,1639,1630,499,7129,8068,9720,473" %}
[bitcoin core 0.21.0]: https://bitcoincore.org/bin/bitcoin-core-0.21.0/
[lnd 0.12.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.12.0-beta.rc3
[eclair 0.5.0]: https://github.com/ACINQ/eclair/releases/tag/v0.5.0
[cl doc/backup.md]: https://github.com/ElementsProject/lightning/blob/master/doc/BACKUP.md
[poelstra post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-December/018313.html
[teinturier post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-December/002928.html
[tramp spec]: https://github.com/lightningnetwork/lightning-rfc/pull/829
[acinq post]: https://medium.com/@ACINQ/phoenix-wallet-part-4-trampoline-payments-fb1befd027c8
[news128 akka]: /zh/newsletters/2020/12/16/#eclair-1566
[news123 watchdog]: /zh/newsletters/2020/11/11/#eclair-1545
[news55 psbt xpub]: /zh/newsletters/2019/07/17/#bips-784
[news72 psbt version]: /zh/newsletters/2019/11/13/#bips-849
[news45 wallet-tool]: /zh/newsletters/2019/05/07/#new-wallet-tool
[achow101 legacy timeline]: https://github.com/bitcoin/bitcoin/issues/20160
[news96 createwallet]: /zh/newsletters/2020/05/06/#bitcoin-core-16528
[news120 sqlite]: /zh/newsletters/2020/10/21/#bitcoin-core-19077
