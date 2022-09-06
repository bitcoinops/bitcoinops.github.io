---
title: 'Bitcoin Optech Newsletter #215'
permalink: /zh/newsletters/2022/08/31/
name: 2022-08-31-newsletter-zh
slug: 2022-08-31-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报介绍了一个钱包标签导出格式的标准化提案，并包含了我们的常规栏目：Bitcoin StackExchange 网站的精选问答总结；软件的新版本和候选版本清单；热门的比特币基础设施软件的重大变更介绍。

## 新闻

- **<!--wallet-label-export-format-->钱包标签导出格式**：Craig Raw 在 Bitcoin-Dev 邮件组中[发帖][raw interchange]提出了一份 BIP，用于标准化钱包地址和交易的标签在导出后的格式。理论上，一种标准化的导出格式将允许使用相同的 [BIP32][topic bip32] 账户层级的两个钱包软件打开彼此的备份，并且不仅能复原资金控制权，还能复原用户为这些交易手动键入的所有信息。

    考虑到之前让使用 BIP32 的钱包彼此兼容的挑战，也许更容易实现的用途是让交易的历史更容易从钱包软件中导出并用在其它程序中，比如用于会计。

    开发者 Clark Moody 和 Pavol Rusnak [各自][moody slip15]回复了一份对 [SLIP15][SLIP15] 的[引用][rusnak slip15]，该引用介绍了由 Trezor 钱包品牌开发的开放导出标准。Craig Raw [指出][raw slip15]了自己的提议在目标上与 SLIP 15 似乎能够提供的东西的多个重大区别。人们也讨论了设计上的其它许多方面。截至本周报撰写之时，这样的讨论仍在发生。

## Bitcoin Stack Exchange 网站的问答精选

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者们有疑问时寻找答案的首选之地 —— 也是我们有闲暇时会帮助好奇和困惑用户的地方。在这个每月一次的栏目中，我们挑出了自上一次栏目出刊以来的一些高票问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--why-isnt-it-possible-to-add-an-opreturn-commitment-or-some-arbitrary-script-inside-a-taproot-script-path-with-a-descriptor-->为什么不可以使用描述符在一个 taproot 脚本路径中添加一个 OP_RETURN 承诺（或者其它任意脚本）？]({{bse}}114948) Antoine Poinsot 解释道，现在 Bitcoin Core 中的[脚本描述符][topic descriptors]已经拓展到使用[miniscript][topic miniscript]，预计在 Bitcoin Core 0.24 版本时就会发布。虽然最初的 miniscript 特性只支持 segwit v0，但最终对 [tapscript][topic tapscript] 和 “[部分描述符][Bitcoin Core #24114]” 的支持将使我们能够在 tapscript 中添加承诺，无需完全依靠 `raw()` 描述符。

- [<!--why-does-bitcoin-core-rebroadcast-transactions-->为什么 Bitcoin Core 会重新广播交易？]({{bse}}114973) Amir reza Riahi 好奇为什么 Bitcoin Core 钱包模块会重新广播交易，为什么期间存在延迟。Pieter Wuille 指出，点对点网络缺乏交易传播的保证，所以重广播功能是有必要的；而且，将重广播的责任从钱包模块移交到交易池模块的工作已经完成了。对重广播功能有兴趣的读者可以看 [2022 年 8 月 24 日][prreview 25768] 、[2021 年 4 月 7 日][prreview 21061] 和 [2019 年 11 月 27 日][prreview 16698] 各期周报的 PR 审核俱乐部栏目。

- [<!--when-did-bitcoin-core-deprecate-the-mining-function-->什么使用 Bitcoin Core 开始放弃挖矿功能？]({{bse}}114687) Pieter Wuille 为 Bitcoin Core 在过去几年的挖矿相关特性提供了一个历史性的回顾。

- [<!--utxo-spendable-by-me-or-deposit-to-exchange-after-5-years-->有无办法让一个 UTXO 可以被我花费，同时在 5 年后可以被任何人存入我的交易所地址？]({{bse}}114901)  Stickies-v 提供了关于比特币脚本操作符、加入 [MAST][topic mast] 的 [taproot][topic taproot] 升级如何优化花费条件的隐私性和经济性的概述，并指出因为比特币脚本缺乏 “[限制条款（cvenants）][topic covenants]”，所以题主想要的特性光靠脚本是无法实现的。Vojtěch Strnad 指出，预先签名的交易可以帮助实现这样的花费条件。

- [<!--what-was-the-bug-for-the-bitcoin-value-overflow-in-2010-->比特币在 2010 年的数值溢出漏洞是什么样的？]({{bse}}114694) Andrew Chow 总结了[数值溢出漏洞][value overflow bug]及其多种通货膨胀效果：产生数额更大的输出，还会导致交易费错误计算。

## 新版本和候选版本

*比特币的流行基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [LND 0.15.1-beta][] 是一个 “包含对[零确认通道][topic zero-conf channels]、scid[昵称][aliases]的支持，并在所有地方切换到使用 [taproot] [topic taproot] 地址” 的新版本。

## 重大代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo] 和 [Lightning BOLTs][bolts repo]。*

- [Bitcoin Core #23202][Bitcoin Core #23202] 拓展了 `psbtbumpfee` RPC 方法，使之可以创建一个 [PSBT][topic psbt] 来为某一笔交易追加手续费，即使这笔交易的某些输出并不属于这个钱包。这个 PSBT 可以分享给能够签名的钱包。

- [Eclair #2275][Eclair #2275] 为[双向注资][topic dual funding]的闪电通道启动交易添加了追加手续费的功能。这个 PR 指出，有了这个 PR，“Eclair 就算是完全支持双向注资通道了！”虽然该 PR 还提到，双向注资是默认禁用的，而且[跟 Core Lightning 的交叉兼容性测试][news143 cln df]要在未来才加入。

- [Eclair #2387][Eclair #2387] 添加了对 [signet][topic signet] 的支持。

- [LDK #1652][LDK #1652] 升级了对[洋葱消息][topic onion messages]的支持，使之能发送 *回复路径（reply paths）*，并在收到这样的消息时解码。洋葱消息协议并不要求转发一条洋葱消息的节点跟踪关于这条消息的任何信息，这意味着，要是一个节点希望自己的洋葱消息得到回复，就需要为接收方提供发送回复的路径的提示。

- [HWI #627][HWI #627] 支持使用 BitBox02 硬件签名设备利用密钥路径花费 [P2TR][topic taproot] 输出。

- [BDK #718][BDK #718] 开始在钱包创建好签名之后立即验证 ECDSA 签名和 [schnorr][topic schnorr signatures] 签名。这是 [BIP340][BIP340] 的一条建议（见[周报 #87][news87 verify]），在[周报 # 83][news83 verify] 中得到了讨论，已经在 Bitcoin Core 中实现了（见[周报 #175][news175 verify]）。

- [BDK #705][BDK #705] 和 [#722][bdk #722] 给使用 BDK 库的软件提供了 Electrum 和 Esplora 服务可用的方法，来访问额外的服务器端。

{% include references.md %}
{% include linkers/issues.md v=2 issues="23202,2275,2387,1652,627,718,705,722,24114" %}
[lnd 0.15.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.1-beta
[news175 verify]: /en/newsletters/2021/11/17/#bitcoin-core-22934
[news87 verify]: /en/newsletters/2020/03/04/#bips-886
[news83 verify]: /en/newsletters/2020/02/05/#safety-concerns-related-to-precomputed-public-keys-used-with-schnorr-signatures
[raw interchange]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-August/020887.html
[moody slip15]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-August/020888.html
[rusnak slip15]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-August/020892.html
[raw slip15]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-August/020893.html
[aliases]: /zh/newsletters/2022/07/13/#lnd-5955
[slip15]: https://github.com/satoshilabs/slips/blob/master/slip-0015.md
[news143 cln df]: /en/newsletters/2021/04/07/#c-lightning-0-10-0
[prreview 25768]: https://bitcoincore.reviews/25768
[prreview 21061]: https://bitcoincore.reviews/21061
[prreview 16698]: https://bitcoincore.reviews/16698
[value overflow bug]: /en/topics/soft-fork-activation/#fix-value-overflow-bug-august-2010
