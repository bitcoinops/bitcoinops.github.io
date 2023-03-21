---
title: 'Bitcoin Optech Newsletter #242'
permalink: /zh/newsletters/2023/03/15/
name: 2023-03-15-newsletter-zh
slug: 2023-03-15-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报转发了测试 Utreexo 的服务位的公告，链接到几个新的软件版本和候选版本，并描述了一项被合并的 Bitcoin Core 拉取请求。

## 新闻

- **<!--service-bit-for-utreexo-->Utreexo 的服务位：** Calvin Kim 在 Bitcoin-Dev 邮件列表中[发帖][kim utreexo]，介绍了一款目前在 signet 和 testnet 上进行试验的软件。该软件将使用 P2P 协议的第 24 号服务比特位。该试验性软件为 [Utreexo][topic utreexo] 提供支持。Utreexo 是一种可使那些不存储 UTXO 集合副本的节点也能对交易进行完整验证的协议，与现代 Bitcoin Core 完整节点相比最多可节省 5 GB 的磁盘空间（同时没有降低任何安全性）。Utreexo 节点在收到一笔未确认交易（或者一个充满已确认交易的区块）时需要接收额外数据，因此该服务比特位将帮助节点找到能够这类提供额外数据的节点。

## 版本和候选版本

*热门的比特币基础设施项目的新版本与候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Core Lightning v23.02.2][]是这个闪电网络节点软件的维护版本。它恢复了导致其他软件出现问题的 `pay` RPC 变更；此外包括了其他几项变更。

- 密码学库的 [Libsecp256k1 0.3.0][]。它包括一个 ABI 非兼容性的 API 变更。

- [LND v0.16.0-beta.rc3][] 是这个流行的闪电网络实现的新的主要版本的候选版本。

## 重大的文档和代码变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo] 和 [Lightning BOLTs][bolts repo]。*

- [Bitcoin Core #25740][] 允许使用 [assumeUTXO][topic assumeutxo] 的节点可以验证最优区块链上的所有区块和交易，直到到达 assumeUTXO 状态声明它已生成的区块，同时从该区块开始构建 UTXO 集合（链状态）。如果该链状态等于节点首次启动时下载的 assumeUTXO 状态，则该状态已完全验证。与任何其他完整节点一样，该节点已验证最优区块链上的每个区块，只是验证顺序与标准节点不同。下次节点启动时，用于执行旧块验证的特殊链状态将被删除，从而释放磁盘空间。 [assumeUTXO 项目][assumeUTXO project] 的其他部分仍然需要在合并后才能使用。

{% include references.md %}
{% include linkers/issues.md v=2 issues="25740" %}
[lnd v0.16.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.0-beta.rc3
[libsecp256k1 0.3.0]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.3.0
[core lightning v23.02.2]: https://github.com/ElementsProject/lightning/releases/tag/v23.02.2
[kim utreexo]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-March/021515.html
[assumeutxo project]: https://github.com/bitcoin/bitcoin/projects/11
