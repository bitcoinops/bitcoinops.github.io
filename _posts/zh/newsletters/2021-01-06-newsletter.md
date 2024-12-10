---
title: 'Bitcoin Optech Newsletter #130'
permalink: /zh/newsletters/2021/01/06/
name: 2021-01-06-newsletter-zh
slug: 2021-01-06-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了对 BIP322 通用消息签名提案的更新建议，并链接了 LN 蹦床路由的规范。此外，还包括发布版本、候选发布版本的公告，以及流行比特币基础设施软件的显著更改总结。

## 新闻

- **<!--proposed-updates-to-generic-signmessage-->****通用签名消息提案的更新建议：** Andrew Poelstra [发布][poelstra post]了对 [BIP322][] 通用消息签名提案的部分重写。这次重写主要是澄清签名和验证过程，同时允许未实现完整检查集的钱包对使用未知脚本的签名返回“结果不确定”状态。例如，开发者可以选择仅实现 P2PKH、P2WPKH 和 P2SH-P2WPKH 脚本的签名验证，这涵盖了大部分当前和历史输出。对于其他脚本，钱包可以返回“结果不确定”，并可能指引用户使用更全面的验证工具。

- **<!--trampoline-routing-->****蹦床路由：** Bastien Teinturier 向 Lightning-Dev 邮件列表[发布][teinturier post]了一个新的[规范][tramp spec]，描述了[蹦床路由][topic trampoline payments]，使支付方无需计算其节点与接收方节点之间的路径。相反，支付方将资金路由到一个邻近的蹦床节点，由该节点计算路径的下一部分——将资金转移到接收方或下一个蹦床节点。这对轻量级 LN 客户端的支付方特别有用，这些客户端通常离线或无法跟踪网络 gossip 以自行计算路径。

  Teinturier 指出，ACINQ 已经为其 Phoenix 钱包用户运行了一个单跳蹦床节点。这提供了路径查找的好处，但正如其[博客文章][acinq post]所述，这意味着 ACINQ 可以看到所有用户支付的目标地址。为解决这一问题，路由节点可以宣传其支持接收洋葱包裹的蹦床路由，支付方 Alice 首先将资金发送到一个蹦床节点（例如 ACINQ 的节点），然后可能发送到其他蹦床节点，最终到达接收方节点。这防止任何单个蹦床节点得知支付方和接收方的节点标识符。提议的规范提供了一种标准化的方式实现这一目标。

  Teinturier 认为“代码变更非常合理，因为它重用了每个闪电实现中已有的许多组件，并未引入新的假设。”

## 发布与候选发布版本

*流行比特币基础设施项目的新版本和候选发布版本。请考虑升级到新版本或帮助测试候选发布版本。*

- [Eclair 0.5.0][] 是一个新主要版本，增加了对可扩展集群模式（参见 [Newsletter #128][news128 akka]）、区块链监视器（[Newsletter #123][news123 watchdog]）和额外插件钩子的支持，以及许多其他功能和错误修复。

- [Bitcoin Core 0.21.0rc5][Bitcoin Core 0.21.0] 是此完整节点实现及其关联钱包和其他软件的下一个主要版本的候选发布版本。截至撰写本文时，该最新候选版本尚未上传，但我们希望它会在发布后不久上线。

- [LND 0.12.0-beta.rc3][LND 0.12.0-beta] 是此 LN 节点下一个主要版本的最新候选发布版本。它将[锚定输出][topic anchor outputs]设为承诺交易的默认设置，并在其[瞭望塔][topic watchtowers]实现中增加了对锚定输出的支持，从而降低成本并提高安全性。此版本还增加了创建和签名 [PSBT][topic psbt] 的通用支持，并包括若干错误修复。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[比特币改进提案 (BIPs)][bips repo]和[闪电网络规范 (BOLTs)][bolts repo] 中的值得注意的更改：*
- **<!--bitcoin-core-19137-adds-dump-and-createfromdump-commands-to-wallet-tool-->**[Bitcoin Core #19137][] 为 [`wallet-tool`][news45 wallet-tool] 添加了 `dump` 和 `createfromdump` 命令，使用户可以将钱包记录写入转储文件，并随后从该转储文件中恢复钱包。这些命令不仅对测试有用，还可作为 [从传统钱包迁移][achow101 legacy timeline] 的一部分。

- **<!--bitcoin-core-20365-updates-the-bitcoin-wallet-tool-->**[Bitcoin Core #20365][] 更新了 `bitcoin-wallet` 工具的 `create` 命令，增加了一个 `-descriptors` 标志，用于创建 [基于 sqlite 的描述符钱包][news120 sqlite]，类似于守护进程的 [createwallet RPC][news96 createwallet]。

- **<!--bitcoin-core-20599-updates-message-handling-code-->**[Bitcoin Core #20599][] 更新了消息处理代码，使其可以在对等方发送 `verack` 消息之前处理接收到的 `sendheaders` 和 `sendcmpct` 消息。`sendheaders`（[BIP130][]）和 `sendcmpct`（[BIP152][]）的规范并未要求这些消息必须在 `verack` 消息之后发送，而原始实现（[Bitcoin Core #7129][] 和 [Bitcoin Core #8068][]）允许在 `verack` 消息之前接收和处理这些消息。后来的一次 PR（[Bitcoin Core #9720][]）阻止了 Bitcoin Core 在 `verack` 消息之前处理这些消息。本次 PR 恢复了原始行为。

- [Bitcoin Core #18772][] 更新了 `getblock` RPC，当使用 `verbosity=2` 参数时，返回一个新的 `fee` 字段，其中包含区块中每笔交易的总手续费。这依赖于节点存储的额外区块撤销数据，用于处理区块链重组。撤销数据与其他区块交易数据分开存储，启用修剪的节点可能会在删除其他数据之前删除撤销数据，因此修剪节点有时可能返回不包含 `fee` 字段的结果。

- [Bitcoin Core GUI #162][] 为 GUI 的 Peers 窗口添加了一个新的可排序网络列，并在对等详情区域添加了一个新的网络行。在这两处，GUI 会向用户显示对等方通过的网络类型：IPv4、IPv6 或 Onion，并具有显示两个潜在未来扩展项（I2P 和 CJDNS）的能力。该 PR 还将 NodeId 和 Node/Service 列标题重命名为 Peer Id 和 Address。

- [C-Lightning #4207][] 添加了关于备份节点数据的广泛 [新文档][cl doc/backup.md]。

- [Eclair #1639][] 默认启用了 [BOLT3][] 的 `option_static_remotekey`，允许 Eclair 遵循通道对等方的请求，将支付始终发送到同一个公钥。这使得远程对等方即使丢失了一些通道状态，也能轻松定位并在链上使用这些支付。PR 描述指出，Eclair 开发者现在启用此选项是因为 LND 的 0.12.0-beta 版本将使其成为强制项。

- [Rust Bitcoin #499][] 增加了对 [BIP174][] 最初发布后指定的两个全局 [PSBT][topic psbt] 字段的支持：

  1. 扩展公钥字段，用于启用签名钱包的找零检测（见 [Newsletter #55][news55 psbt xpub]）

  2. 版本号字段，用于帮助识别 PSBT 规范的向后不兼容更改（见 [Newsletter #72][news72 psbt version]）

  这是在 [#473][Rust Bitcoin #473] 中详细描述的大型工作之一，旨在使 Rust Bitcoin 的 PSBT 实现与当前规范保持一致。

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
