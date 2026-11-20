---
title: 'Bitcoin Optech Newsletter #155'
permalink: /zh/newsletters/2021/06/30/
name: 2021-06-30-newsletter-zh
slug: 2021-06-30-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 概要介绍了两个关于钱包支持 taproot 的提案 BIP，并且包含我们常规的栏目：Bitcoin Stack Exchange 精选问答、如何为 taproot 做准备，以及热门比特币基础设施项目的值得注意的变更。

## 新闻

- **<!--psbt-extensions-for-taproot-->****PSBT 扩展以支持 taproot：**Andrew Chow 在 Bitcoin-Dev 邮件列表上[发布][chow taproot
  psbt]了一份[提案 BIP][bip-taproot-psbt]，为[部分签名比特币交易（PSBT）][topic psbt]定义了一些新字段，用于花费或创建 taproot 输出。这些字段同时扩展了最初的版本 0 PSBT 和提议中的版本 2 PSBT（参见 [Newsletter #128][news128 psbt2]），密钥路径（keypath）和脚本路径（scriptpath）两种花费方式都受支持。

  该提案还建议，PSBT 中的 P2TR 输入可以省略之前交易的副本，因为 taproot 修正了针对 v0 segwit 输入的手续费超额支付攻击（参见 [Newsletter #101][news101 fee overpayment attack]）。

- **<!--key-derivation-path-for-single-sig-p2tr-->****单签名 P2TR 的密钥派生路径：**Andrew Chow 还向 Bitcoin-Dev 邮件列表[发布][chow taproot path]了第二份[提案 BIP][bip-taproot-bip44]，建议为创建单签名 taproot 地址的钱包采用一个 [BIP32][] 派生路径。Chow 指出，此 BIP 与用于 P2SH 包装的 P2WPKH 地址的 [BIP49][] 以及用于原生 P2WPKH 地址的 [BIP84][] 十分相似。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们有点空闲时帮助好奇或困惑用户的地方。在本月栏目中，我们精选自上次更新以来得票最高的一些问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--what-are-the-downsides-to-enabling-potentially-suboptimal-or-unused-opcodes-in-a-future-soft-fork-->**[在未来软分叉中启用可能次优或未使用的 opcode 有哪些弊端？]({{bse}}106851)
  G. Maxwell 概述了启用任何会影响共识的 opcode 所要考虑的诸多因素，包括：

  * 前期及持续维护成本

  * 对使用该 opcode 的用户以及整个网络带来的潜在风险

  * 额外的复杂性会成为定制或重新实现节点软件的障碍

  * 部分或低效的特性会挤占将来更好替代方案的空间

  * 意外形成反常激励

- **<!--why-does-blockwide-signature-aggregation-prevent-adaptor-signatures-->**[为什么区块范围内的签名聚合会阻止适配器签名？]({{bse}}107196)
  Pieter Wuille 解释了为什么跨输入签名聚合会妨碍[适配器签名][topic adaptor signatures]或无脚本脚本（scriptless scripts）等技术，他指出：“在区块范围的签名聚合下，整个区块只有一个签名。这个签名根本没有余地同时向多个独立当事方揭示多个独立的秘密。”

- **<!--should-the-bitcoin-core-wallet-or-any-wallet-prevent-users-from-sending-funds-to-a-taproot-address-pre-activation-->**[Bitcoin Core 钱包（或任意钱包）是否应该阻止用户在激活前将资金发送到 Taproot 地址？]({{bse}}107186)
  Murch 阐述了为什么钱包软件应该允许用户向未来任何 BIP173 segwit 输出类型发送资金。把提供可花费地址的责任交给收款方，整个生态就能利用 [bech32/bech32m][topic bech32] 的前向兼容性，立即用上新的输出类型。

- **<!--why-are-the-witnesses-segregated-with-schnorr-signatures-->**[为什么 schnorr 签名仍然使用隔离见证？]({{bse}}106930)
  Dalit Sairio 问道，既然 [schnorr 签名][topic schnorr signatures]并不像 ECDSA 签名那样存在同样的可延展性问题，为什么它们仍然要被隔离出去？Darosior 指出，可延展性只是隔离见证带来的诸多好处之一。Pieter Wuille 补充说，签名可延展性只是更广泛的脚本可延展性的一部分。

- **<!--possible-amount-of-signatures-with-musig-->**[MuSig 可以支持多少个签名者？]({{bse}}106929)
  Nickler 解释道，对于 [MuSig][topic musig] 和 MuSig2，签名者的数量在实践中几乎是无限的；他还提到，[自己的基准测试][nickler musig]在笔记本电脑上跑 100 万个签名者大约需要 130 秒。

- **<!--support-for-p2wsh-wrapped-p2tr-addresses-->**[对 P2WSH 包装的 P2TR 地址的支持？]({{bse}}106706)
  除了 [BIP341][bip341 p2sh footnote] 提到的碰撞安全问题之外，jnewbery 还指出多出一种输出类型所带来的隐私问题，以及鉴于 bech32 已在生态中广泛采用，包装式 taproot 输出是否确有需要仍然值得商榷。

## 准备 Taproot #2：Taproot 对单签名是否有意义？

*每周一篇的[系列][series preparing for taproot]文章，讲述开发者和服务提供商如何为即将到来的、在区块高度 {{site.trb}} 处激活的 taproot 做好准备。*

{% include specials/taproot/zh/01-single-sig.md %}

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]的值得注意的变更：*

- [Bitcoin Core #22154][] 加入了一些代码，让用户在 taproot 于区块 {{site.trb}} 激活之后，可以生成用于 P2TR 脚本的 [bech32m][topic bech32] 地址，例如调用 `getnewaddress "" bech32m`。如果 taproot 激活后某笔交易包含任何 bech32m 地址，描述符钱包也会使用一个 P2TR 找零输出。该功能仅适用于带有 taproot 描述符的钱包（参见 [Newsletter #152][news152 p2tr descriptors]）。

- [Bitcoin Core #22166][] 增加了从输出推断 taproot `tr()` 描述符的支持，补齐了对 taproot 描述符的基本支持。描述符推断用于在 `listunspent` 等 RPC 调用中返回更准确的信息。

- [Bitcoin Core #20966][] 更改了封禁列表存档文件的名称和格式，从 `banlist.dat`（基于序列化的 P2P 协议 `addr` 消息）改为 `banlist.json`。文件格式的更新让新列表能保存 Tor v3 以及其他网络中地址位宽超过 128 位的对等节点的封禁条目——而原始的 `addr` 消息最多只能容纳 128 位宽的地址。

- [Bitcoin Core #21056][] 为 `bitcoin-cli` 新增了一个 `-rpcwaittimeout` 参数。现有的 `-rpcwait` 参数会把发送命令（RPC 调用）推迟到 `bitcoind` 服务启动之后；新参数则会在指定的秒数之后停止等待并返回错误。

- [C-Lightning #4606][] 允许创建金额超过约 0.043 BTC 的发票。这是继 LND 的类似改动（参见 [Newsletter #93][news93 lnd4075]）以及下一项中描述的规范修改之后做出的。

- [BOLTs #877][] 移除了协议层面针对单笔付款金额的限制，这一限制最初是为了避免实现中的 bug 造成重大损失而引入的。在此之前，`option_support_large_channel` 已于 2020 年得到广泛实现，该选项在启用时会移除*每条通道*的金额限制。关于这两种限制的更多细节，参见[大额通道][topic large channels]专题。

{% include references.md %}
{% include linkers/issues.md issues="22154,22166,20966,21056,4606,877" %}
[news128 psbt2]: /zh/newsletters/2020/12/16/#new-psbt-version-proposed
[news101 fee overpayment attack]: /zh/newsletters/2020/06/10/#fee-overpayment-attack-on-multi-input-segwit-transactions
[chow taproot psbt]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-June/019095.html
[bip-taproot-psbt]: https://github.com/achow101/bips/blob/taproot-psbt/bip-taproot-psbt.mediawiki
[chow taproot path]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-June/019096.html
[bip-taproot-bip44]: https://github.com/achow101/bips/blob/taproot-bip44/bip-taproot-bip44.mediawiki
[news93 lnd4075]: /zh/newsletters/2020/04/15/#lnd-4075
[news152 p2tr descriptors]: /zh/newsletters/2021/06/09/#bitcoin-core-22051
[nickler musig]: https://github.com/jonasnick/musig-benchmark
[bip341 p2sh footnote]: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki#cite_note-3
[series preparing for taproot]: /zh/preparing-for-taproot/
