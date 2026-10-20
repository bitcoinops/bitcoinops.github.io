---
title: 'Bitcoin Optech Newsletter #176'
permalink: /zh/newsletters/2021/11/24/
name: 2021-11-24-newsletter-zh
slug: 2021-11-24-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周 Newsletter 链接到一场讨论：如何让 LN 用户在支付更高手续费与获得更高支付可靠性之间做出选择。此外还包括常规栏目：Bitcoin Stack Exchange 精选问答、新版本与候选发布，以及热门比特币基础设施软件的值得注意的变更。

## 新闻

- **<!--ln-reliability-versus-fee-parameterization-->****LN 可靠性与手续费参数化：**
  Joost Jager 在 Lightning-Dev 邮件列表发起[讨论][jager params]，探讨如何最好地让用户自己选择：是多付手续费以更快完成支付，还是多等一段时间以省钱。讨论中提到的挑战之一是：用户的偏好在一条连续的谱上取值，而寻路算法返回的路由是离散且多因素的，要如何把两者对应起来。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们有点空闲时帮助好奇或困惑用户的地方。在本月栏目中，我们精选自上次更新以来得票最高的一些问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--why-is-it-important-that-nonces-when-signing-not-be-related-->**[为何签名时 nonce 必须不可关联？]({{bse}}110811)
  Pieter Wuille 用数学方式分析了用同一公钥签名两次时私钥信息如何泄露，并分别讨论了三种情形：使用同一个 nonce、使用已知偏移量的 nonce、使用已知因子的 nonce。他还列举了三种在实际中无法被利用的 nonce 生成方法、两种已被攻破的方法，并指出这中间还存在大量既未被证明安全、也未被攻破的方法。

- **<!--how-could-a-2-byte-witness-program-make-sense-->**[2 字节见证程序有何意义？]({{bse}}110660)
  围绕 [BIP141][] 对见证程序 2-40 字节的要求，Kalle Rosenbaum 探讨了 2 字节长度的潜在用例场景。

- **<!--what-is-the-xpriv-xpub-type-for-p2tr-->**[P2TR 的 xpriv/xpub 类型是什么？]({{bse}}110733)
  Andrew Chow 指出，随着脚本越来越多样、越来越复杂并被更广泛地使用，加上关注点分离的考虑，taproot 并没有与 xpub/ypub/zpub 对应的类型。他建议“在使用 xpriv/xpub 的同时，附加一些额外信息来指明要创建的脚本是 taproot（例如使用 `tr()` 描述符）”。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [LND 0.14.0-beta][] 是一个正式版本，除许多其他功能与错误修复外，还包含额外的[日食攻击][topic eclipse attacks]防护（见 [Newsletter #164][news164 ping]）、远程数据库支持（[Newsletter #157][news157 db]）、更快的寻路（[Newsletter #170][news170 path]）、Lightning Pool 用户体验改进（[Newsletter #172][news172 pool]），以及可重复使用的 [AMP][topic amp] 发票（[Newsletter #173][news173 amp]）。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo] 的值得注意的变更。*

- [C-Lightning #4890][] 允许用户为钱包配置一个备份 sqlite 数据库文件。运行期间，所有数据都会在主 sqlite 文件和备份文件之间复制。该功能还附带了[详尽的文档][c-lightning backups]。

- [Rust-Lightning #1173][] 新增 `accept_inbound_channels` 配置项，可用于阻止节点接受新的入站通道。该选项默认为 true。

- [Rust-Lightning #1166][] 改进默认路由评分逻辑：当支付的 HTLC 金额将超过通道容量的 1/8 时，对该通道施加惩罚。随着支付金额接近通道容量，惩罚线性增加。

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
