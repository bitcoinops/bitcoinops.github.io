---
title: 'Bitcoin Optech Newsletter #183'
permalink: /zh/newsletters/2022/01/19/
name: 2022-01-19-newsletter-zh
slug: 2022-01-19-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周 Newsletter 分享了比特币开发者法律辩护基金的公告，总结了近期关于 `OP_CHECKTEMPLATEVERIFY` 软分叉提案的讨论。同时包含常规栏目：近期服务和客户端软件的更新描述，以及主流比特币基础设施软件的值得注意变更摘要。

## 新闻

- ​**​<!--bitcoin-and-ln-legal-defense-fund-->​**​​**​比特币与闪电网络法律辩护基金：​**​ Jack Dorsey、Alex Morcos 和 Martin White 在 Bitcoin-Dev 邮件列表[发布][dmw legal]公告，宣布为从事比特币、闪电网络及相关技术开发的开发者设立法律辩护基金。该基金"是一个非营利实体，旨在减少阻碍软件开发者积极参与比特币及相关项目开发的诉讼困扰"。

- ​**​<!--op-checktemplateverify-discussion-->​**​​**​OP_CHECKTEMPLATEVERIFY 讨论：​**​ 本周在 Bitcoin-Dev 邮件列表和 IRC 会议中讨论了为比特币添加 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV) 操作码的软分叉提案。

  - ​**​<!--mailing-list-discussion-->​***邮件列表讨论：* Peter Todd [提出][todd ctv]了对该提案的多个担忧，包括该功能几乎不会让所有比特币用户受益（他认为此前添加功能的软分叉都做到了这点）、可能产生新的拒绝服务攻击向量，以及许多 CTV 的拟议用例定义不明确且（或许）过于复杂而难以实际广泛部署。

    CTV 作者 Jeremy Rubin [引用][rubin ctv reply]了更新代码和改进文档，可能解决了有关 DoS 攻击的担忧。他还指出至少有两个钱包（其中一个被广泛使用）计划使用 CTV 提供的至少一项功能。截至本文撰写时，尚不确定 Rubin 的回复是否已实质性地消除了 Peter Todd 的疑虑。

  - ​**​<!--irc-meeting-->​***IRC 会议：* 如 [Newsletter #181][news181 ctv meets] 所预告，Rubin 还主持了系列会议中的首场 CTV 讨论会议。[会议记录][log ##ctv-bip-review]和 Rubin 提供的[总结][rubin meeting summary]已公开。部分参会者明确支持该提案，但另一些参与者表达了技术性质疑，部分质疑点与 Peter Todd 此前的邮件观点相似。下次会议计划更深入地探讨 CTV 的某些应用案例，这可能有助于验证该提案是否确实能为大量比特币用户提供具有吸引力的实用场景。

## 服务和客户端软件的更改

*本栏目每月重点介绍比特币钱包和服务的趣味更新。*

- ​**​<!--cash-app-adds-lightning-support-->​**​**​Cash App 添加闪电网络支持：​**​
  Cash App 新增支持通过闪电网络发送支付。

- ​**​<!--lnp-node-opens-first-mainnet-channel-->​**​**​LNP Node 开通首个主网通道：​**​
  新型闪电网络节点软件 [LNP Node][lnp node github] 开通了[首个闪电网络通道][lnp tweet]。该软件采用 Rust 语言编写，支持闪电网络及名为"Bifrost"的扩展协议集，旨在为未来闪电网络升级和上层协议提供支持。

- ​**​<!--samourai-adds-taproot-support-->​**​**​Samourai 支持 Taproot：​**​
  Samourai [v0.99.98][samourai v0.99.98] 和 Samourai [Dojo v1.13.0][samourai dojo v1.13.0]（通过 [bitcoinjs-lib][bitcoinjs-lib github] 库）新增支持 P2TR 的 [bech32m][topic bech32] 地址。

- ​**​<!--block-explorer-mempool-v2-3-0-released-->​**​**​区块浏览器 Mempool v2.3.0 发布：​**​
  Mempool [v2.3.0][mempool v2.3.0] 及 [mempool.space][mempool.space] 网站新增版本与锁定时间数据、十六进制交易广播功能、"花费 Taproot 输出的交易标签"等改进。

## 值得注意的代码和文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案 (BIPs)][bips repo]和[闪电网络规范 (BOLTs)][bolts repo]的值得注意变更。*

- [Eclair #2063][] 新增支持 [BOLTs #912][] 中新增的 `option_payment_metadata` 发票字段（参见 [Newsletter #182][news182 bolts912]），允许 Eclair 创建的发票包含加密支付元数据。理解该新字段的支付方将在路由支付时携带其有效载荷，使 Eclair 能够解密数据并利用其重构接收支付所需的全部信息。未来若所有支付方都支持此功能，将可实现[无状态发票][topic stateless invoices]，使 Eclair 无需在收到支付前在数据库中存储任何关键发票信息，从而消除存储浪费并防范发票创建拒绝服务攻击。

- [LDK #1013][] 新增支持创建和处理 [BOLTs #950][] 引入的警告消息（参见 [Newsletter #182][news182 warning msgs]）。

- [LND #6006][] 移除了当用户仅需签名交易时 LND 必须连接全节点或 Neutrino 轻客户端的限制，使得 LND 的签名功能可在未直连互联网的设备上运行。

- [Rust Bitcoin #590][] 进行了 API 不兼容变更，简化了将同一 [HD 密钥材料][topic bip32]同时用于 ECDSA 签名和 [schnorr 签名][topic schnorr signatures]的操作（注：应用应为不同签名算法使用不同 HD 密钥路径，参见 [Newsletter #157][news157 p4tr bip32]）。[Rust Bitcoin #591][] 延续了相关改进工作。

- [Rust Bitcoin #669][] 扩展其 [PSBT][topic psbt] 代码，新增用于存储部分签名信息的数据类型（指使交易生效所需但自身不足以完成的签名）。此前签名仅以原始字节存储，新数据类型便于对部分签名执行额外操作。拉取请求讨论包含关于签名者是否应在 PSBT 中放置空字节向量（["nulldummy"][bip147]）的[有趣评论][poelstra nulldummy]。

{% include references.md %}
{% include linkers/issues.md v=1 issues="2063,912,1013,6006,590,591,669,950" %}
[poelstra nulldummy]: https://github.com/rust-bitcoin/rust-bitcoin/pull/669#issuecomment-1008021007
[dmw legal]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019741.html
[todd ctv]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019738.html
[rubin ctv reply]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019739.html
[rubin meeting summary]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019744.html
[news181 ctv meets]: /zh/newsletters/2022/01/05/#bip119-ctv-review-workshops
[news182 bolts912]: /zh/newsletters/2022/01/12/#bolts-912
[news157 p4tr bip32]: /zh/newsletters/2021/07/14/#use-a-new-bip32-key-derivation-path
[log ##ctv-bip-review]: https://gnusha.org/ctv-bip-review/2022-01-11.log
[lnp node github]: https://github.com/LNP-BP/lnp-node
[lnp tweet]: https://twitter.com/dr_orlovsky/status/1473768786750750733
[samourai v0.99.98]: https://docs.samourai.io/en/wallet/releases#v09998
[samourai dojo v1.13.0]: https://code.samourai.io/dojo/samourai-dojo/-/blob/develop/RELEASES.md#samourai-dojo-v1130
[bitcoinjs-lib github]: https://github.com/bitcoinjs/bitcoinjs-lib
[mempool v2.3.0]: https://github.com/mempool/mempool/releases/tag/v2.3.0
[mempool.space]: https://mempool.space/
[news182 warning msgs]: /zh/newsletters/2022/01/12/#bolts-950
