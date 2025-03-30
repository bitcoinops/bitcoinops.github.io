---
title: 'Bitcoin Optech Newsletter #176'
permalink: /zh/newsletters/2021/11/24/
name: 2021-11-24-newsletter-zh
slug: 2021-11-24-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周Newsletter 探讨如何让闪电网络用户在手续费与支付可靠性之间进行权衡，并包含常规的 Bitcoin Stack Exchange 精选问答、新版本发布与候选版本，以及热门比特币基础设施软件的重要更新。


## 新闻

- ​**<!--n1-->****闪电网络可靠性 vs 手续费参数化：**
  Joost Jager 在 Lightning-Dev 邮件列表发起[讨论][jager params]，探讨如何让用户在支付速度（更高手续费）与成本节省（更长时间等待）之间做出选择。讨论焦点之一是如何将用户连续性的偏好与路径算法返回的离散多因素路由相关联。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找技术解答的首选平台。本节精选近月高票问答：*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [为何签名时 nonce 必须不可关联？]({{bse}}110811)
  Pieter Wuille 数学推导了三种可能泄露私钥信息的情形：使用相同 nonce、已知偏移量的 nonce、已知因子的 nonce。他列举了三种安全 nonce 生成方法、两种不安全方法，并指出存在大量既未被证实安全也未证实不安全的中间态技术。

- [2 字节见证程序有何意义？]({{bse}}110660)
  围绕 [BIP141][] 对见证程序 2-40 字节的要求，Kalle Rosenbaum 探讨了 2 字节长度的潜在用例场景。

- [P2TR 的 xpriv/xpub 类型是什么？]({{bse}}110733)
  Andrew Chow 指出，随着脚本复杂度提升和关注点分离需求，Taproot 没有等效的 xpub/ypub/zpub 类型。他建议"使用 xpriv/xpub 并附加 Taproot 标识信息（例如通过 `tr()` 描述符）"。

## 发布与候选发布

*新版本发布与候选版本：*

- [LND 0.14.0-beta][] 正式版包含：增强[日蚀攻击][topic eclipse attacks]防护（参见[Newsletter #164][news164 ping]），远程数据库支持（[Newsletter #157][news157 db]），快速路径发现（[Newsletter #170][news170 path]），Lightning Pool 改进（[Newsletter #172][news172 pool]），可复用 [AMP][topic amp] 发票（[Newsletter #173][news173 amp]），其他多项功能优化与错误修复。

## 重要代码与文档变更

*本周重要代码变更涉及 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]。*

- [C-Lightning #4890][] 新增钱包备份 SQLite 数据库配置功能，运行时数据将同步至主数据库和备份文件。[详细文档][c-lightning backups] 已同步更新。

- [Rust-Lightning #1173][] 新增 `accept_inbound_channels` 配置项，允许节点拒绝新建入站通道（默认值为 true）。

- [Rust-Lightning #1166][] 优化默认路由评分算法，对 HTLC 金额超过通道容量 1/8 的通道施加惩罚。惩罚力度随金额接近容量上限线性增加。

{% include references.md %}
{% include linkers/issues.md issues="4890,1173,1166" %}
[lnd 0.14.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.14.0-beta
[news164 ping]: /zh/newsletters/2021/09/01/#lnd-5621
[news157 db]: /zh/newsletters/2021/07/14/#lnd-5447
[news170 path]: /zh/newsletters/2021/10/13/#lnd-5642
[news172 pool]: /zh/newsletters/2021/10/27/#lnd-5709
[news173 amp]: /zh/newsletters/2021/11/03/#lnd-5803
[jager params]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-November/003342.html
[c-lightning backups]: https://github.com/ElementsProject/lightning/blob/163d3a9203922a0493cf6038493bd4b5e078d987/doc/BACKUP.md#sqlite3---walletmainbackup-and-remote-nfs-mount
