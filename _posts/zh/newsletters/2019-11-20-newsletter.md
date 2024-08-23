---
title: 'Bitcoin Optech Newsletter #73'
permalink: /zh/newsletters/2019/11/20/
name: 2019-11-20-newsletter-zh
slug: 2019-11-20-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 公布了 LND 的一个新的小版本发布，指出了开发邮件列表的停机时间，描述了比特币服务和客户端的一些最新更新，并总结了流行的比特币基础设施项目的近期变化。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- **<!--upgrade-to-lnd-0-8-1-beta-->****升级到 LND 0.8.1-beta：**这个[版本][lnd 0.8.1-beta]修复了几个小错误并增加了对即将发布的 Bitcoin Core 0.19 版本的兼容性。

## 新闻

- **<!--mailing-list-downtime-->****邮件列表停机时间：**上周，由于未宣布的服务器迁移，Bitcoin-Dev 和 Lightning-Dev 邮件列表都经历了[停机][bishop migration]。截至本文撰写时，这两个列表均已恢复正常功能。

## 服务和客户端软件的变化

*在这个月度特辑中，我们重点介绍了比特币钱包和服务的有趣更新。*

- **<!--bitfinex-bech32-send-support-->****Bitfinex 支持 bech32 发送：**在最近的一篇[博客文章][bitfinex bech32 blog]中，Bitfinex 宣布其交易所支持发送到原生 bech32 地址。虽然 Bitfinex 用户以前可以使用 P2SH-wrapped segwit 地址，但现在他们可以从交易所提取到原生 segwit 地址。

- **<!--wasabi-includes-bitcoin-core-node-->****Wasabi 包含 Bitcoin Core 节点：**作为整合 Bitcoin Core 的持续努力的一部分，Wasabi 已经合并了一键[支持在 Wasabi 界面中运行 Bitcoin Core 节点][wasabi bitcoin core bundle]。Bitcoin Core 二进制文件与 Wasabi 下载捆绑在一起，并由 Wasabi 维护人员通过 PGP 验证。

## 值得注意的代码和文档变化

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案 (BIPs)][bips repo] 和 [Lightning BOLTs][bolts repo] 中的值得注意的变化。*

- [Bitcoin Core #17437][] 更新了 `gettransaction`、`listtransactions` 和 `listsinceblock` RPC，以包含每个返回交易所包含的区块高度。

- [C-Lightning #3223][] 更新了 `listpeers` RPC，以显示如果通道关闭，将支付的地址。

- [C-Lightning #3186][] 添加了一个名为 `hsmtool` 的新实用程序，将与 C-Lightning 的其他二进制文件一起构建。该工具可以加密或解密您的 C-Lightning 钱包，以及打印有关您的承诺交易的私人信息。

- [Eclair #1209][] 添加了对创建和解密草案[蹦床支付][topic trampoline payments]洋葱格式的支持。这是为了准备后续的 PR，这些 PR 将添加对实际路由蹦床支付的支持。

- [Eclair #1153][] 添加了对[多路径支付][topic multipath payments]的实验性支持，允许将支付分成两部分或多部分，可以通过不同的路径发送，使具有多个开放通道的用户能够从每个通道中支出资金。预计随着其他 LN 软件完成自己的多路径支付实现，并随着获取有关分割和路由算法性能的实际数据，这段代码可能需要进行调整。

{% include linkers/issues.md issues="16442,3649,17437,3223,3186,1209,1153,17449" %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}
[lnd 0.8.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.8.1-beta
[bishop migration]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-November/002335.html
[bitfinex bech32 blog]: https://www.bitfinex.com/posts/427
[wasabi bitcoin core bundle]: https://github.com/zkSNACKs/WalletWasabi/pull/2495
