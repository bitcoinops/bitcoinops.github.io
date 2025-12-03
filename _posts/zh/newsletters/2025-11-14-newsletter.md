---
title: 'Bitcoin Optech Newsletter #380'
permalink: /zh/newsletters/2025/11/14/
name: 2025-11-14-newsletter-zh
slug: 2025-11-14-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报包含了我们的常规栏目：软件的新版本和候选版本发行公告，热门的比特币基础设施软件的显著变更说明。

## 新闻

*在我们 Optech 关注的[信息源][optech sources]中，本周没有发现重大新闻。*

## 新版本和候选版本

*热门的比特币基础设施软件的新版本和候选版本。请考虑升级到新版本或者帮助测试候选版本。*

- [LND 0.20.0-beta.rc4][] 是这个热门的闪电节点实现的新版本的候选发行版，它引入了多项 bug 修复、一种新的 `noopAdd` [HTLC][topic htlc] 类型、支持在 BOLT11 发票中加入 [P2TR][topic taproot] 备用地址，以及许多 RPC 和 `licli` 增量和提升。详见这个[发行说明][release notes]。

## 重大的代码和说明书变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Bitcoin Core #30595][] 加入了一个 C 语言头文件（header），作为 `libbitcoinkernel` 的一个 API（应用程序接口）（详见周报 [#191][news191 lib]、[#198][news198 lib]、[#367][news367 lib]），让外部项目可以通过一个可复用的 C 语言库与 Bitcoin Core 的区块验证和链状态逻辑交互。当前，这还限制在对区块的操作上，而且特性与现在已经停止的 `libbitcoin-consensus` 相同（详见[周报 #288][news288 lib]）。`libbitcoinkernel` 的用途包括替代性的节点实现、Electrum 服务端的索引构造器、[静默支付][topic silent payments]扫描器、区块分析工具、脚本验证加速器，等等。

- [Bitcoin Core #33443][] 减少了打断重新索引（reindex）的重启之后重放区块时的过量日志。现在，它为全部被处理的区块发布一条日志消息、每处理 10000 个区块增加发布一条消息；不会再每处理一个区块就发布一条日志。

- [Core Lightning #8656][] 让 [P2TR][topic taproot] 成为使用 `newaddr` 端点又不指定地址类型时候默认返回的地址类型（取代了 P2WPKH）。

- [Core Lightning #8671][] 向 `htlc_accepted` 钩子添加了一个 `invoice_msat` 字段，允许插件在支付检查期间覆写实质性的发票金额。具体来说，它使用 [HTLC][topic htlc] 的金额（当这个金额与发票的金额不同时）。这在闪电网络服务商（LSP）向转发的 HTLC 收取手续费时有用。

- [LDK #4204][] 让对等节点可以放弃一次[通道拼接][topic splicing]而不必强制关闭通道，只要还没有交换签名。以前，通道拼接协商期间的任何 `tx_abort` 消息都会不必要地出发强制关闭；现在，只有签名已经交换之后，`tx_abort` 才会触发强制关闭。

- [BIPs #2022][] 更新了 [BIP3][]（详见 [周报 #344][news344 bip3]）来说明 BIP 编号是如何赋予的。“一个编号仅能在一个 BIP 编辑通过 PR 公开宣布之后，才能被认为已经赋予。” 社交媒体上的公告和编辑内部笔记中的临时条目，都不构成赋予。

{% include references.md %}
{% include linkers/issues.md v=2 issues="30595,33443,8656,8671,4204,2022" %}
[LND 0.20.0-beta.rc4]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.0-beta.rc4
[release notes]: https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/release-notes-0.20.0.md
[news191 lib]: /zh/newsletters/2022/03/16/#bitcoin-core-24304
[news198 lib]: /zh/newsletters/2022/05/04/#bitcoin-core-24322
[news367 lib]: /zh/newsletters/2025/08/15/#bitcoin-core-33077
[news288 lib]: /zh/newsletters/2024/02/07/#bitcoin-core-29189
[news344 bip3]: /zh/newsletters/2025/03/07/#bips-1712