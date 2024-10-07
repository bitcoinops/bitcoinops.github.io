---
title: 'Bitcoin Optech Newsletter #82'
permalink: /zh/newsletters/2020/01/29/
name: 2020-01-29-newsletter-zh
slug: 2020-01-29-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 宣布了 LND 0.9.0-beta 的发布，邀请大家帮助测试一个 Bitcoin Core 维护版本的候选版本，描述了一个打破 UTXO 与未公布的闪电网络通道之间关联性的提议，并总结了一项对提议中的 `SIGHASH_ANYPREVOUTANYSCRIPT` 签名哈希的修改，这可能简化基于 eltoo 的支付通道的支付管理。此外，还包括我们常规的 Bitcoin Stack Exchange 精选问答和对流行比特币基础设施与文档项目的显著变更的总结。

## 行动项

- **<!--upgrade-to-lnd-0-9-0-beta-->****升级到 LND 0.9.0-beta：** 这个新的主要版本[发布][lnd 0.9.0-beta]带来了对访问控制列表机制（“macaroons”）的改进，支持接收[多路径支付][topic multipath payments]，支持在加密洋葱消息中发送额外数据（参见 [Newsletter #81][news81 lnd3900]），原生再平衡支持（参见 [Newsletter #74][news74 lnd3739]），支持请求通道关闭输出支付到指定地址（例如你的硬件钱包；参见 [Newsletter #76][news76 lnd3655]），以及许多其他功能和错误修复。

- **<!--help-test-bitcoin-core-0-19-1rc1-->****帮助测试 Bitcoin Core 0.19.1rc1：** 即将发布的维护[版本][bitcoin core 0.19.1]包含若干错误修复。鼓励有经验的用户帮助测试是否存在任何回归或其他意外行为。

## 新闻

- **<!--breaking-the-link-between-utxos-and-unannounced-channels-->****打破 UTXO 与未公布通道之间的关联性：** Bastien Teinturier 在 Lightning-Dev 邮件列表中[发布][teinturier post]关于更改发送到未公布通道的 [BOLT11][] 发票中添加的数据的提议——这些未公布的通道并未在闪电网络中宣传，通常也不为其他用户路由支付。该提议将从发票中移除可用于识别通道存款 UTXO 的信息，取而代之的是一个一次性使用的每发票密钥对和一个从密钥对派生的秘密，该秘密作为洋葱加密支付的一部分进行路由。这需要支付方和能够路由至未公布通道的对等方的特殊支持，但路由路径上的其他节点无需更改其实现。Teinturier 请求对此提议的反馈，包括任何关于如何消除支付中包含加密秘密需求的建议。

- **<!--layered-commitments-with-eltoo-->****基于 eltoo 的分层承诺：** Anthony Towns [描述了][towns layered commitments]对其先前 [anyprevout 提议][bip-anyprevout]（[SIGHASH_NOINPUT][topic sighash_anyprevout] 的变体）的一项潜在修改，这可能简化基于 [eltoo][topic eltoo] 的闪电网络通道。目前的提议中，基于 eltoo 的闪电网络实现需要确保它们不会接受退款超时时间早于支付单方面关闭延迟的支付，否则支付方节点可能在接收方节点有机会使用其适配器签名（“点锁”）合法地索取支付之前收回其支付。这与当前风格的闪电网络支付不同，后者的超时和延迟可以独立选择。

  为了让 eltoo 实现类似的超时和延迟参数独立性，Towns 提议从使用 `SIGHASH_ANYPREVOUTANYSCRIPT` 签名哈希（sighash）标志创建的签名中移除 [BIP341][] 对输入值（`sha_amounts`）的承诺。这也需要对 eltoo 中使用的脚本进行更改，包括利用 [tapscript 的][topic tapscript] `OP_CODESEPARATOR` 操作码的变体。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者们寻找问题答案的首选地之一——或者当我们有一些空闲时间时，我们也会帮助好奇或困惑的用户。在这一月度特色栏目中，我们重点介绍自上次更新以来发布的部分高票问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--how-is-op-checktemplateverify-a-scaling-solution-->**[OP_CHECKTEMPLATEVERIFY 如何作为扩展解决方案？]({{bse}}92755) Confused_Coder 解释了提议的新操作码 `OP_CHECKTEMPLATEVERIFY` 如何通过将多个支付封装到一个输出中并在费用较低时再展开为多个输出来[延迟使用区块空间][news48 output commitments]。

- **<!--why-was-the-bip32-fingerprint-used-for-bip174-psbt-->**[为什么在 BIP174 PSBT 中使用了 BIP32 指纹？]({{bse}}92848) Andrew Chow 描述了为什么在 BIP174 [PSBT][topic psbt] 规范中选择使用 BIP32 指纹而不是完整哈希，即从硬件钱包中获取完整公钥 hash160 的不现实性。

- **<!--how-is-the-size-of-a-bitcoin-transaction-calculatedd-->**[比特币交易的大小是如何计算的？]({{bse}}92689) 用户 Septem151 提供了一个详细的步骤说明，按每个字段列出了如何计算隔离见证和非隔离见证交易的权重单位（vbytes）。

## 值得注意的代码和文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]中的显著变更。*

- [Bitcoin Core #17492][] 使得 Bitcoin Core 图形用户界面在用户尝试为仅观察钱包中的交易提升费用时，将部分签名的比特币交易（[PSBT][topic psbt]）放入剪贴板中。用户随后可以将 PSBT 粘贴到另一个程序（如 [HWI][topic hwi]）中进行签名。

- [C-Lightning #3376][] 增加了重试逻辑，以应对支付方和接收方在区块高度上暂时不一致的情况。PR 中讨论了是否应修改[规范][BOLT4] 以简化实现，但指出导致该情况的规范更改[关闭了隐私泄露][bolt4 privacy leak]。

- [LND #3809][] 为 `BumpFee` RPC 添加了 `force` 参数，使其能够在创建交易时包含非经济性 UTXO，这扩展了 [Newsletter #79][news79 lnd3814] 中描述的更改。非经济性 UTXO 是指花费成本高于其包含的价值的 UTXO——如果 LN 协议中采纳了提议的[锚点输出][topic anchor outputs] 费用提升方法，那么 LND 就必须能够花费这些 UTXO。

- [BIPs #875][] 将 [BIP119][] 分配给 `OP_CHECKTEMPLATEVERIFY` 提案。如果该提案被采纳，用户将能够创建仅能由特定交易或一组交易支出的 UTXO，从而提供一种[契约][topic covenants] 类型的功能。这在临时将支付保留在链下但需要确保最终接收方支付不会被撤销或更改的协议中非常有用。

- [BIPs #876][] 为三项提案分配了 BIP 编号，分别对应于 schnorr-taproot-tapscript 提案的各个部分：

  - [BIP340][] 分配给“用于 secp256k1 的 Schnorr 签名”，描述了一种与比特币使用的 secp256k1 [椭圆曲线][elliptic curve]兼容的签名方案。该签名方案与批量验证以及类似 [MuSig][topic musig] 的密钥和签名聚合方案兼容。Schnorr 签名可用于以下两个 BIP（341 和 342）。更多信息，请参阅 BIP 或 [schnorr 签名][topic schnorr signatures]。

  - [BIP341][] 分配给“Taproot：SegWit 版本 1 支出规则”，描述了一项软分叉提案的一部分，允许用户支付 schnorr 风格的公钥，该公钥可以通过 schnorr 风格的签名或证明该密钥提交给一个 merkle 树中的特定脚本（以及证明脚本条件得到满足）进行支出。详细信息请参阅 BIP 或 [taproot][topic taproot]。

  - [BIP342][] 分配给“Taproot 脚本的验证”，描述了结合 taproot（*tapscript*）使用的脚本的评估规则。tapscript 中几乎所有操作与传统的比特币脚本相同，但有一些不同之处。对于升级到 tapscript 的现有用户，最显著的变化是所有检查签名的操作码（例如 `OP_CHECKSIG`）都使用 schnorr 公钥和签名；另一个值得注意的是，`OP_CHECKMULTISIG` 已被移除；脚本作者可以使用新的 `OP_CHECKSIGADD` 操作码或重新设计他们的脚本。还有一些其他的新规则会影响用户或很少使用的功能。此外，tapscript 包括了几项新特性，旨在使其脚本语言的未来软分叉升级更加容易。详细信息请参阅 BIP 或 [tapscript][topic tapscript]。

  {% comment %}<!--
  $ git log --oneline --no-merges  802520e...9cf4038 | wc -l
  163

  $ git shortlog -s  802520e...9cf4038 | wc -l
  30  ## devrandom and Orfeas Litos each appear twice, so 28
  -->{% endcomment %}

  许多合并到 BIPs 仓库的更改包括来自多个不同贡献者的贡献，但这次合并的贡献者比我们之前看到的任何一次都多：它包括来自 28 个不同人员的内容和编辑，共 163 次提交，并感谢了若干其他命名贡献者、其构建基础的先前工作作者以及众多“[结构化评审]的参与者”。

- [BOLTs #697][] 修改了 [BOLT4][] 中描述的 Sphinx 数据包构建方式，以修复可能导致目标节点发现回到源节点路径长度的隐私泄露。有关泄露的详细信息，请参见 [Newsletter #72][news72 leak]。Optech 跟踪的所有三个实现也都更新了其代码以修复该泄露：[C-Lightning][news72 cl3246]、[Eclair][news81 eclair1247] 和 [LND-Onion][] 库。<!-- LND 洋葱 PR 在 Newsletter #72 的新闻项目中提到，我们已经链接到，因此在上方直接链接到 PR -->

- [BOLTs #705][] 为 [BOLT1][] 消息类型 32768-65535 分配了实验性和应用程序特定的消息类型。它还为实现者提供了指南，包括建议任何从该范围中分配消息类型的人将他们使用的编号发布到 [BOLTs issue #716][bolts #716] 以防止冲突。

{% include references.md %}
{% include linkers/issues.md issues="17492,3376,3809,875,876,697,705,716" %}
[lnd 0.9.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.9.0-beta
[bitcoin core 0.19.1]: https://bitcoincore.org/bin/bitcoin-core-0.19.1/
[structured reviews]: https://github.com/ajtowns/taproot-review
[news72 leak]: /zh/newsletters/2019/11/13/#possible-privacy-leak-in-the-ln-onion-format
[news72 cl3246]: /zh/newsletters/2019/11/13/#c-lightning-3246
[news81 eclair1247]: /zh/newsletters/2020/01/22/#eclair-1247
[lnd-onion]: https://github.com/lightningnetwork/lightning-onion/pull/40
[news81 lnd3900]: /zh/newsletters/2020/01/22/#lnd-3900
[news74 lnd3739]: /zh/newsletters/2019/11/27/#lnd-3739
[news76 lnd3655]: /zh/newsletters/2019/12/11/#lnd-3655
[news79 lnd3814]: /zh/newsletters/2020/01/08/#lnd-3814
[teinturier post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-January/002435.html
[towns layered commitments]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-January/002448.html
[elliptic curve]: https://en.bitcoin.it/wiki/Secp256k1
[news48 output commitments]: /zh/newsletters/2019/05/29/#提议的交易输出承诺
[bolt4 privacy leak]: /zh/newsletters/2019/08/28/#bolts-608
