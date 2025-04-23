---
title: 'Bitcoin Optech Newsletter #184'
permalink: /zh/newsletters/2022/01/26/
name: 2022-01-26-newsletter-zh
slug: 2022-01-26-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周 Newsletter 介绍了一项扩展 PSBT 以支持 Pay-to-Contract 协议输出消费字段的提案，并包含常规栏目——Bitcoin Stack Exchange 热门问答精选和主流比特币基础设施项目的显著变更。"


## 新闻

- ​**​<!--psbt-extension-for-p2c-fields-->​**​**​PSBT 的 P2C 字段扩展提案：​** Maxim Orlovsky [提议][orlovsky p2c] 新增一个比特币改进提案（BIP），为 [PSBTs][topic psbt] 添加可选字段以支持消费通过 [Pay-to-Contract][topic p2c]（P2C）协议创建的输出，如 [Newsletter #37][news37 psbt p2c] 所述。P2C 允许支付方与接收方就合约文本（或其他内容）达成一致，并生成一个对该文本进行承诺的公钥。支付方随后可证明该支付确实承诺了特定文本，且该承诺的生成在计算上不可行于接收方未配合的情况。简而言之，支付方可向法庭或公众证明其支付用途。

  然而，接收方后续在构建消费资金的签名时，除了使用其密钥（通常为 [HD 密钥链][topic bip32] 的一部分）外，还需要合约的哈希值。Orlovsky 的提案允许在 PSBT 中添加该哈希值，从而使签名钱包或硬件设备能够生成有效签名。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找答案的首选之地——也是我们在空闲时帮助好奇或困惑用户的去处。在本栏目中，我们将重点介绍自上期更新以来获得高票的问题与答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- ​**​<!--is-it-possible-to-convert-a-taproot-address-into-a-v0-native-segwit-address-->​**[是否可以将 Taproot 地址转换为 v0 原生隔离见证地址？]({{bse}}111440)
  某交易所因不支持 Taproot，将用户的 P2TR（原生隔离见证 v1）提现地址更改为 P2WSH（原生隔离见证 v0）地址。用户询问是否可提取该 v0 输出中的比特币。Pieter Wuille 指出，由于用户需找到哈希值与 P2TR 地址公钥匹配的脚本（这在计算上不可行），这些比特币无法被提取。

- ​**​<!--was-bitcoin-0-3-7-actually-a-hard-fork-->​**[Bitcoin 0.3.7 版本是否实际导致了硬分叉？]({{bse}}111673)
  BA20D731B5806B1D 用户询问为何 Bitcoin 0.3.7 版本被归类为硬分叉。Antoine Poinsot 通过示例 `scriptPubKey` 和 `scriptSig` 值说明，在修复 [0.3.7][bitcoin 0.3.7 github] 版本中分离 `scriptSig` 与 `scriptPubKey` 验证的漏洞后，原本无效的签名可能变为有效。

- ​**​<!--what-is-signature-grinding-->​**[什么是签名研磨（signature grinding）？]({{bse}}111660)
  Murch 解释称，ECDSA 签名研磨是指反复签名直至获得 r 值处于范围下半部分的签名，基于比特币的 ECDSA 序列化格式，此类签名的长度可减少 1 字节（32 字节 vs 33 字节）。较小的签名可降低手续费，且已知的 32 字节长度有助于更精确的费用估算。

- ​**​<!--how-is-network-conflict-avoided-between-chains-->​**[如何避免链间网络冲突？]({{bse}}111967)
  Murch 说明节点如何通过 P2P [消息结构][wiki message structure] 中定义的魔数（magic numbers）识别对等节点是否处于同一网络（主网、测试网、signet）。

- ​**​<!--how-many-bips-were-adopted-in-the-standard-client-in-2021-->​**[2021 年有多少 BIP 被标准客户端采纳？]({{bse}}111901)
  Pieter Wuille 提供了比特币核心的 [BIPs 文档][bitcoin bips doc] 链接，该文档记录了比特币核心已实现的 BIP。


## 值得注意的代码与文档变更

*以下为 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo] 的显著变更。*

- [Eclair #2134][] 默认启用[锚定输出][topic anchor outputs]，允许在广播时若手续费率过低，可通过 [CPFP][topic cpfp] 对承诺交易进行手续费追加。由于锚定输出式手续费追加依赖 CPFP，用户需在 `bitcoind` 钱包中预留 UTXO。

- [Eclair #2113][] 新增手续费自动追加管理功能。包括按交易确认时效性分级、逐区块重新评估交易以决定是否追加手续费、根据网络手续费率调整交易手续费率，以及在必要时添加输入以提升手续费率。该拉取请求还呼吁改进 [Bitcoin Core #23201][] 的钱包 API，以减少如 Eclair 等外部程序所需的额外钱包管理操作。

- [Eclair #2133][] 开始默认转发 [洋葱消息][topic onion messages]。通过 [Newsletter #181][news181 onion] 提及的速率限制机制，防止对闪电网络协议该实验性功能的滥用。

- [BTCPay Server #3083][] 允许管理员通过 [LNURL 认证][LNURL authentication]（也可在非闪电网络软件中实现）登录 BTCPay 实例。

- [BIPs #1270][] 澄清了 [PSBT][topic psbt] 规范中关于签名字段有效值的定义。此前 Rust Bitcoin 的[更新][news183 rust-btc psbt]引入了对签名字段的严格解析，引发关于 PSBT 签名字段是否允许占位符或仅接受有效签名的讨论。最终确定 PSBT 应仅包含有效签名。

- [BOLTs #917][] 扩展了 [BOLT1][] 定义的 `init` 消息功能，允许节点告知连接的对等节点其正在使用的 IPv4 或 IPv6 地址。由于 [NAT][] 后的对等节点无法获知自身 IP 地址，此功能可在地址变更时帮助节点更新其向网络宣告的 IP 地址。

{% include references.md %}
{% include linkers/issues.md issues="2134,2113,23201,2133,3083,1270,917" %}
[orlovsky p2c]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019761.html
[news181 onion]: /zh/newsletters/2022/01/05/#eclair-2099
[lnurl authentication]: https://github.com/fiatjaf/lnurl-rfc/blob/legacy/lnurl-auth.md
[nat]: https://en.wikipedia.org/wiki/Network_address_translation
[news37 psbt p2c]: /zh/newsletters/2019/03/12/#extension-fields-to-partially-signed-bitcoin-transactions-psbts
[bitcoin 0.3.7 github]: https://github.com/bitcoin/bitcoin/commit/6ff5f718b6a67797b2b3bab8905d607ad216ee21#diff-8458adcedc17d046942185cb709ff5c3L1135
[wiki message structure]: https://en.bitcoin.it/wiki/Protocol_documentation#Message_structure
[bitcoin bips doc]: https://github.com/bitcoin/bitcoin/blob/master/doc/bips.md
[news183 rust-btc psbt]:/zh/newsletters/2022/01/19/#rust-bitcoin-669
