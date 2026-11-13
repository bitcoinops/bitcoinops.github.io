---
title: 'Bitcoin Optech Newsletter #73'
permalink: /zh/newsletters/2019/11/20/
name: 2019-11-20-newsletter-zh
slug: 2019-11-20-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 宣布 LND 发布了一个新的小版本，指出开发邮件列表出现了停机，介绍了比特币服务和客户端软件的一些最新动态，并总结了热门比特币基础设施项目的近期变更。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- **<!--upgrade-to-lnd-0-8-1-beta-->****升级到 LND 0.8.1-beta：**这个[版本][lnd 0.8.1-beta]修复了几个小错误并增加了对即将发布的 Bitcoin Core 0.19 版本的兼容性。

## 新闻

- **<!--mailing-list-downtime-->****邮件列表停机：**上周，由于一次事先未通知的服务器迁移，Bitcoin-Dev 和 Lightning-Dev 两个邮件列表都经历了[停机][bishop migration]。截至本文撰写时，两个列表都已恢复正常。

## 服务和客户端软件的变更

*在本月栏目中，我们重点介绍 Bitcoin 钱包与服务的一些有趣更新。*

- **<!--bitfinex-bech32-send-support-->****Bitfinex 支持 bech32 发送：**在最近的一篇[博客文章][bitfinex bech32 blog]中，Bitfinex 宣布其交易所支持发送到原生 bech32 地址。虽然 Bitfinex 用户以前可以使用 P2SH 封装的 segwit 地址，但现在可以从交易所提现到原生 segwit 地址。

- **<!--wasabi-includes-bitcoin-core-node-->****Wasabi 内置 Bitcoin Core 节点：**作为持续整合 Bitcoin Core 的一部分，Wasabi 合并了一项功能，可以在 Wasabi 界面内一键[运行 Bitcoin Core 节点][wasabi bitcoin core bundle]。Bitcoin Core 二进制文件随 Wasabi 安装包一同分发，并由 Wasabi 维护者做 PGP 验证。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案 (BIPs)][bips repo] 和 [Lightning BOLTs][bolts repo] 中值得注意的变更。*

- [Bitcoin Core #17437][] 更新了 `gettransaction`、`listtransactions` 和 `listsinceblock` RPC，让返回值包含每笔返回交易所在区块的高度。

- [C-Lightning #3223][] 更新了 `listpeers` RPC，以显示通道关闭时将会支付到的地址。

- [C-Lightning #3186][] 添加了一个名为 `hsmtool` 的新工具，它将与 C-Lightning 的其他二进制文件一同构建。该工具可以加密或解密你的 C-Lightning 钱包，还能打印关于你的承诺交易的私密信息。

- [Eclair #1209][] 添加了对创建和解密草案版[蹦床支付][topic trampoline payments]洋葱格式的支持。这是为后续 PR 做准备，那些 PR 将加入实际路由蹦床支付的能力。

- [Eclair #1153][] 添加了对[多路径支付][topic multipath payments]的实验性支持，允许把一笔支付拆成两部分或多部分，经由不同路由发送，从而让开有多个通道的用户能够从每个通道中花出资金。预计随着其他 LN 软件陆续完成各自的多路径支付实现，以及随着关于拆分与路由算法性能的真实数据不断积累，这段代码可能还需要调整。

{% include linkers/issues.md issues="16442,3649,17437,3223,3186,1209,1153,17449" %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}
[lnd 0.8.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.8.1-beta
[bishop migration]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-November/002335.html
[bitfinex bech32 blog]: https://www.bitfinex.com/posts/427
[wasabi bitcoin core bundle]: https://github.com/zkSNACKs/WalletWasabi/pull/2495
