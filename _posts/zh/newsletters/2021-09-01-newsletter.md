---
title: 'Bitcoin Optech Newsletter #164'
permalink: /zh/newsletters/2021/09/01/
name: 2021-09-01-newsletter-zh
slug: 2021-09-01-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周 Newsletter 介绍了一个基于网络端的 PSBT 解码与修改工具,并链接了一篇关于基于 eltoo 的闪电网络支付通道的博客文章及概念验证实现。同时包含关于准备 Taproot 的常规信息、新软件候选版本公告以及主流比特币基础设施项目的重要变更摘要。

## 新闻

- **<!--bip174-org-->****BIP174.org:** Alekos Filini 在比特币开发邮件列表[发帖][filini bip174.org]介绍了其与 Daniela Brozzoni 共同创建的[网站][bip174.org],该网站可将[部分签名的比特币交易(PSBT)][topic psbt]解码为人类可读的字段列表。字段内容可被编辑并重新编码为序列化的 PSBT,帮助开发者快速测试其 BIP174 实现。Christopher Allen [建议][allen qr174]该工具应支持生成二维码(标准码或用于处理超过 3 KB PSBT 的替代方案,参见 [Newsletter #96][news96 qr codes])。

- **<!--eltoo-example-channel-->****Eltoo 示例通道:** Richard Myers 此前已基于 AJ Towns [SIGHASH_ANYPREVOUT][topic sighash_anyprevout]实现(参见 [Newsletter #63][news63 eltoo])在比特币核心集成测试中完成 [eltoo][topic eltoo] 通道的示例版本。其在比特币开发邮件列表[提及][myers list]的[详细博客文章][myers blog]描述了 eltoo 通道可能使用的交易结构,结合集成测试代码,允许任何感兴趣者开始实验 eltoo 协议。文中还描述了多个改进方向供进一步研究。

## 准备 Taproot #11：使用 Taproot 的闪电网络

*关于开发者和服务提供商如何为即将在区块高度 {{site.trb}} 激活的 Taproot 做准备的[系列文章][series preparing for taproot]。*

{% include specials/taproot/zh/10-ln-with-taproot.md %}

## 发布与候选发布

*主流比特币基础设施项目的新版本与候选发布。请考虑升级至新版本或协助测试候选版本。*

- [Bitcoin Core 22.0rc3][bitcoin core 22.0] 是此全节点实现及其关联钱包等软件的下一主要版本候选。该版本主要变更包括支持 [I2P][topic anonymity networks] 连接、移除对 [Tor v2][topic anonymity networks] 的支持,以及增强硬件钱包兼容性。

- [Bitcoin Core 0.21.2rc2][bitcoin core 0.21.2] 是比特币核心维护版本的候选发布。包含多个错误修复与小改进。

## 重要代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口(HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案(BIPs)][bips repo]和[闪电网络规范(BOLTs)][bolts repo]的重要变更。*

- [Bitcoin Core GUI #384][] 新增在"封禁节点表"中复制 IP/子网掩码的右键菜单选项。该功能让 GUI 用户更方便地分享封禁列表中的地址。

  ![GUI 复制 IP/子网掩码的右键菜单选项截图](/img/posts/2021-09-gui-copy-banned-peer.png)

- [C-Lightning #4674][] 新增 `datastore`、`deldatastore` 和 `listdatastore` 命令,供插件在数据库中存储和管理数据。同时更新了各命令语义的手册页。

- [LND #5410][] 允许节点建立与非 [Tor][topic anonymity networks] 服务的直连,桥接仅限 Tor 和仅限明文网络的网络段。

- [LND #5621][] 在 [ping 消息][lightning ping]的`ignored`字段中包含最高工作量区块头信息。对端节点可利用此数据进行额外验证,确保其区块链视图处于最新状态且未遭受[日蚀攻击][topic eclipse attacks]。未来工作可将此数据源用于用户提醒或自动恢复机制。

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
