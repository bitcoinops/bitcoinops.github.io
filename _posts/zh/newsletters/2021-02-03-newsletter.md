---
title: 'Bitcoin Optech Newsletter #134'
permalink: /zh/newsletters/2021/02/03/
name: 2021-02-03-newsletter-zh
slug: 2021-02-03-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 链接到一篇关于 taproot 激活后对脚本语言进行小改动如何实现更高合约灵活性的博客文章，并包含我们的定期部分，介绍流行比特币基础设施项目的值得注意的更改。

## 新闻

- **<!--replicating-op-checksigfromstack-with-bip340-and-op-cat-->****使用 BIP340 和 `OP_CAT` 复制 `OP_CHECKSIGFROMSTACK`：** Andrew Poelstra 撰写了一篇关于在 Bitcoin 上使用提议的 [BIP340][] 规范的 [schnorr 签名][topic schnorr signatures] 和曾在 Bitcoin 中存在至 2010 年中期（且经常被提及为重新引入候选者）的 [OP_CAT][] 操作码来实现 [ElementsProject.org][] 上的 [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] (`OP_CSFS`) 操作码功能的[博客文章][poelstra 340cat]。在 Bitcoin 上启用类似 CSFS 的行为将允许创建[契约][topic covenants]和其他高级合约，而无需预先签名支出交易，可能会减少复杂性和需要存储的数据量。该文章以系列后续文章的预告结束（链接由我们添加）：

> “在我们接下来的文章中，我们将讨论如何使用辅助输入来模拟 [SIGHASH_NOINPUT][topic sighash_anyprevout] 并为闪电网络通道启用恒定大小的备份，以及如何使用“价值切换”来构建[保险库][topic vaults]。在我们的最后一篇文章中，我们将讨论 [Miniscript][topic miniscript] 的临时扩展，以及如何以可维护的方式为这些构造开发软件。”

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo] 中的值得注意的更改。*

- [Bitcoin Core #20226][] 为钱包添加了一个新的 `listdescriptors` RPC 方法。[PR #16528][news96 descriptor wallets]，包含在最近的 [0.21.0 软件发布][news132 bitcoin core v0.21]中，增加了对 [descriptor][topic descriptors] 钱包的支持。这个新的 RPC 方法列出了所有导入到 descriptor 钱包中的描述符。

- [Bitcoin Core GUI #163][] 用 *连接类型* 替换了 GUI 对等详情区域中的 *方向* 字段，该字段显示了连接的方向和类型。欲了解更多信息，将光标悬停在连接类型字段名称上即可看到下方显示的工具提示。

  {:.center}
  ![GUI 对等详情连接类型示意图](/img/posts/2021-02-gui-peer-connection-type.png)

- [HWI #430][] 允许 `displayaddress` 命令在 Trezor One 上显示用于多重签名地址的 [BIP32][] 扩展公钥（xpubs）。

- [HWI #415][] 更新了 `getkeypool` 和 `displayaddress` 命令，将 `--sh_wpkh` 和 `--wpkh` 选项替换为 `--addr-type` 选项，该选项接受地址类型作为参数，例如 `--addr-type sh_wpkh`。

{% include references.md %}
{% include linkers/issues.md issues="16528,20226,163,430,415" %}
[btcpay server 1.0.6.8]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.0.6.8
[poelstra 340cat]: https://medium.com/blockstream/cat-and-schnorr-tricks-i-faf1b59bd298
[news96 descriptor wallets]: /zh/newsletters/2020/05/06/#bitcoin-core-16528
[news132 bitcoin core v0.21]: /zh/newsletters/2021/01/20/#bitcoin-core-0-21-0
