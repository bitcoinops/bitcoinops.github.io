---
title: 'Bitcoin Optech Newsletter #164'
permalink: /zh/newsletters/2021/09/01/
name: 2021-09-01-newsletter-zh
slug: 2021-09-01-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周 Newsletter 介绍了一个基于网页的 PSBT 解码与修改工具，并链接了一篇关于基于 eltoo 的闪电网络支付通道的博客文章及概念验证实现。同时还包含关于准备 Taproot 的常规内容、新软件候选版本公告，以及主流比特币基础设施项目值得注意的变更摘要。

## 新闻

- **<!--bip174-org-->****BIP174.org:** Alekos Filini 在 Bitcoin-Dev 邮件列表[发帖][filini bip174.org]，介绍了他与 Daniela Brozzoni 共同创建的[网站][bip174.org]。该网站可把[部分签名比特币交易（PSBT）][topic psbt]解码成人类可读的字段列表，字段内容可以编辑并重新编码为序列化的 PSBT，从而帮助开发者快速为自己的 BIP174 实现编写测试。Christopher Allen [回复][allen qr174]建议该工具还支持生成二维码（标准二维码，或用于处理超过 3 KB 的 PSBT 的替代方案，参见 [Newsletter #96][news96 qr codes]）。

- **<!--eltoo-example-channel-->****Eltoo 示例通道：** Richard Myers 此前基于 AJ Towns 的 [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] 实现（参见 [Newsletter #63][news63 eltoo]），用 Bitcoin Core 的集成测试做出了一个 [eltoo][topic eltoo] 通道的示例。正如他在 Bitcoin-Dev 邮件列表上[提到][myers list]的那样，他现在还写了一篇[详细的博客文章][myers blog]，描述 eltoo 通道可以使用的交易；配合他的集成测试，任何对 eltoo 感兴趣的人都能开始上手实验。文中还描述了若干可能的 eltoo 改进方向，供有意深入研究的人参考。

## 准备 Taproot #11：使用 Taproot 的闪电网络

*关于开发者和服务提供商如何为即将在区块高度 {{site.trb}} 激活的 Taproot 做准备的[系列文章][series preparing for taproot]。*

{% include specials/taproot/zh/10-ln-with-taproot.md %}

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [Bitcoin Core 22.0rc3][bitcoin core 22.0] 是该全节点实现及其配套钱包和其他软件下一个主要版本的候选版本。这个新版本的主要变更包括：支持 [I2P][topic anonymity networks] 连接、移除对 [Tor v2][topic anonymity networks] 的支持，以及加强对硬件钱包的支持。

- [Bitcoin Core 0.21.2rc2][bitcoin core 0.21.2] 是 Bitcoin Core 一个维护版本的候选版本，包含多项错误修复和若干小改进。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]的值得注意的变更。*

- [Bitcoin Core GUI #384][] 在“封禁节点表”中新增了复制某个对等节点 IP/子网掩码的右键菜单项。这让 GUI 用户更容易分享封禁列表中的单个地址。

  ![GUI 复制 IP/子网掩码的右键菜单选项截图](/img/posts/2021-09-gui-copy-banned-peer.png)

- [C-Lightning #4674][] 新增 `datastore`、`deldatastore` 和 `listdatastore` 命令，供插件在 C-Lightning 数据库中存储和管理数据。同时还附上了说明各命令语义的手册页。

- [LND #5410][] 允许节点直接连接那些没有运行在 [Tor][topic anonymity networks] 之后的服务，从而把只能通过 Tor 连通、以及只能通过明文网络连通的两部分网络桥接起来。

- [LND #5621][] 把工作量最大区块的区块头放进 [ping 消息][lightning ping]的 `ignored` 字段。对等节点可以用这份信息额外校验：自己对区块链的视图是最新的，并且没有被[日食攻击][topic eclipse attacks]隔离在整个比特币网络之外。未来的工作可以利用这一数据源提醒用户，或自动采取恢复措施。

## 脚注

{% include references.md %}
{% include linkers/issues.md issues="384,4674,5410,5621" %}
[bitcoin core 22.0]: https://bitcoincore.org/bin/bitcoin-core-22.0/
[bitcoin core 0.21.2]: https://bitcoincore.org/bin/bitcoin-core-0.21.2/
[pickhardt richter paper]: https://arxiv.org/abs/2107.05322
[news96 qr codes]: /zh/newsletters/2020/05/06/#qr-codes-for-large-transactions
[bip174.org]: https://bip174.org/
[news63 eltoo]: /zh/newsletters/2019/09/11/#eltoo-sample-implementation-and-discussion
[filini bip174.org]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-August/019355.html
[allen qr174]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-August/019356.html
[myers list]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-August/019342.html
[myers blog]: https://yakshaver.org/2021/07/26/first.html
[lightning ping]: https://github.com/lightningnetwork/lightning-rfc/blob/master/01-messaging.md#the-ping-and-pong-messages
[series preparing for taproot]: /zh/preparing-for-taproot/
