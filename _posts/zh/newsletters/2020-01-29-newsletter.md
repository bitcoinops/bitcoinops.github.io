---
title: 'Bitcoin Optech Newsletter #82'
permalink: /zh/newsletters/2020/01/29/
name: 2020-01-29-newsletter-zh
slug: 2020-01-29-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 宣布 LND 0.9.0-beta 发布，请求大家帮助测试一个 Bitcoin Core 维护版本的候选发布版，介绍一项切断 UTXO 与未公布 LN 通道之间关联性的提议，并总结针对提议中的 `SIGHASH_ANYPREVOUTANYSCRIPT` 签名哈希的一处修改——这处修改可能简化基于 eltoo 的支付通道中的支付管理。此外还有常规的 Bitcoin Stack Exchange 精选问答栏目，以及热门比特币基础设施与文档项目值得注意的变更的栏目。

## 行动项

- **<!--upgrade-to-lnd-0-9-0-beta-->****升级到 LND 0.9.0-beta：** 这个新的主要版本[发布][lnd 0.9.0-beta]改进了访问控制列表机制（“macaroons”），支持接收[多路径支付][topic multipath payments]，可以在加密的洋葱消息中发送额外数据（参见 [Newsletter #81][news81 lnd3900]），原生支持再平衡（参见 [Newsletter #74][news74 lnd3739]），可以要求把关闭通道时的输出支付到指定地址（例如你的硬件钱包，参见 [Newsletter #76][news76 lnd3655]），此外还有许多其他功能和错误修复。

- **<!--help-test-bitcoin-core-0-19-1rc1-->****帮助测试 Bitcoin Core 0.19.1rc1：** 这个即将发布的维护[版本][bitcoin core 0.19.1]包含若干错误修复。我们鼓励有经验的用户帮助测试是否存在回归或其他意外行为。

## 新闻

- **<!--breaking-the-link-between-utxos-and-unannounced-channels-->****切断 UTXO 与未公布通道之间的关联：** Bastien Teinturier 在 Lightning-Dev 邮件列表上[发帖][teinturier post]，讨论修改发往未公布通道的 [BOLT11][] 发票中所添加的数据——所谓未公布通道，是指没有向 LN 网络公布的通道，通常也不为其他用户路由支付。提议的改动会从发票中移除可用于识别该通道存款 UTXO 的信息，换成每张发票一个一次性的密钥对，以及一个由该密钥对派生、随洋葱加密的支付一起路由的秘密。这需要付款方以及能够路由到该未公布通道的对等节点提供特殊支持，但路由路径上的其他节点无需改动实现。Teinturier 就此提案征集反馈，包括任何能免去在支付中携带加密秘密的办法。

- **<!--layered-commitments-with-eltoo-->****eltoo 的分层承诺：** Anthony Towns [描述][towns layered commitments]了对他先前 [anyprevout 提议][bip-anyprevout]（[SIGHASH_NOINPUT][topic sighash_anyprevout] 的一种变体）的一处可能修改，可以简化基于 [eltoo][topic eltoo] 的 LN 通道。按照当前的提案，基于 eltoo 的 LN 实现必须确保不接受退款超时早于该支付单方关闭延迟的支付，否则付款节点可能在收款节点有机会用其适配器签名（“点锁”）合法领取支付之前，就把这笔支付收回。当前的 LN 支付没有这个限制：超时和延迟可以独立选择。

  为了让 eltoo 也能让超时与延迟参数相互独立，Towns 提议在使用 `SIGHASH_ANYPREVOUTANYSCRIPT` 签名哈希（sighash）标志创建的签名中，去掉 [BIP341][] 对输入金额（`sha_amounts`）的承诺。这还需要改动 eltoo 所用的脚本，包括使用 [tapscript][topic tapscript] 中 `OP_CODESEPARATOR` 操作码的变体。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们有点空闲时帮助好奇或困惑用户的地方。在本月栏目中，我们精选自上次更新以来得票最高的一些问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--how-is-op-checktemplateverify-a-scaling-solution-->**[OP_CHECKTEMPLATEVERIFY 如何成为一种扩容方案？]({{bse}}92755) Confused_Coder 解释了提议的新操作码 `OP_CHECKTEMPLATEVERIFY` 如何把多笔支付封装到一个输出中、之后再展开为多个输出，从而帮助[把区块空间的使用推迟到手续费更低的时候][news48 output commitments]。

- **<!--why-was-the-bip32-fingerprint-used-for-bip174-psbt-->**[为什么 BIP174 PSBT 中使用的是 BIP32 指纹？]({{bse}}92848) Andrew Chow 解释了为什么 BIP174 [PSBT][topic psbt] 规范中通篇选用 BIP32 指纹而不是完整哈希，原因是从硬件钱包取得完整的公钥 hash160 并不现实。

- **<!--how-is-the-size-of-a-bitcoin-transaction-calculatedd-->**[比特币交易的体积是如何计算的？]({{bse}}92689) 用户 Septem151 按字段逐一给出了详细说明，介绍 segwit 与非 segwit 交易的权重单位（vbyte）是如何计算出来的。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络 BOLT][bolts repo] 中值得注意的变更。*

- [Bitcoin Core #17492][] 让 Bitcoin Core 的图形界面在用户尝试为仅观察钱包中的交易追加手续费时，把一笔部分签名比特币交易（[PSBT][topic psbt]）放进剪贴板。随后用户可以把这笔 PSBT 粘贴到另一个程序（例如 [HWI][topic hwi]）中签名。

- [C-Lightning #3376][] 增加了重试逻辑，用来应对付款方和收款方在区块高度上暂时不一致的情况。PR 中讨论过是否要修改[规范][BOLT4]来简化实现，但也有人指出，正是导致这一情况的规范改动[堵上了一个隐私泄露][bolt4 privacy leak]。

- [LND #3809][] 给 `BumpFee` RPC 增加了 `force` 参数，使其在构造交易时可以纳入不经济的 UTXO，这是对 [Newsletter #79][news79 lnd3814] 所述改动的延伸。不经济的 UTXO 是指花费成本高于其自身价值的 UTXO——如果 LN 协议采纳了提议的[锚定输出][topic anchor outputs]手续费追加方式，LND 就必须能花掉这类 UTXO。

- [BIPs #875][] 把 [BIP119][] 分配给 `OP_CHECKTEMPLATEVERIFY` 提案。如果该提案被采纳，用户将能创建只能由某笔特定交易或某组交易花费的 UTXO，从而提供一种[契约][topic covenants]。这对那些暂时把支付留在链下、却又需要向最终收款方保证支付给他们的输出实际上无法被撤销或更改的协议很有用。

- [BIPs #876][] 为 schnorr-taproot-tapscript 提案的三个部分各分配了一个 BIP 编号：

  - [BIP340][] 分配给“用于 secp256k1 的 Schnorr 签名”，其中描述了一种与比特币所用的 secp256k1 [椭圆曲线][elliptic curve]兼容的签名方案。该签名可兼容批量验证，也兼容 [MuSig][topic musig] 之类的密钥与签名聚合方案。Schnorr 签名在接下来的两个 BIP（341 和 342）中可供使用。更多信息请参阅该 BIP 或 [schnorr 签名][topic schnorr signatures]页面。

  - [BIP341][] 分配给“Taproot：SegWit 版本 1 的花费规则”，其中描述了某项软分叉提案的一部分，让用户可以向 schnorr 风格的公钥付款；花费这类输出时，既可以提供 schnorr 风格的签名，也可以提供该密钥通过 merkle 树承诺到某个特定脚本的证明（外加该脚本条件已满足的证明）。详情请参阅该 BIP 或 [taproot][topic taproot] 页面。

  - [BIP342][] 分配给“Taproot 脚本的验证”，其中描述了与 taproot 配合使用的脚本（*tapscript*）的求值规则。tapscript 中几乎所有操作都与旧版 Bitcoin Script 相同，但有少数不同。对于要升级到 tapscript 的现有用户，最重大的变化是所有检查签名的操作码（例如 `OP_CHECKSIG`）都改用 schnorr 公钥和签名；另一点值得注意的是 `OP_CHECKMULTISIG` 已被移除，脚本作者可以改用新的 `OP_CHECKSIGADD` 操作码，或者重新设计脚本。还有少数新规则影响用户或很少被使用的功能。此外，tapscript 还包含若干新特性，目的是让今后对其脚本语言做软分叉升级更容易。详情请参阅该 BIP 或 [tapscript][topic tapscript] 页面。

  {% comment %}<!--
  $ git log --oneline --no-merges  802520e...9cf4038 | wc -l
  163

  $ git shortlog -s  802520e...9cf4038 | wc -l
  30  ## devrandom and Orfeas Litos each appear twice, so 28
  -->{% endcomment %}

  BIPs 仓库的许多次合并都汇集了多位不同人士的贡献，但这次合并的贡献者比我们以往见过的任何一次都多：它包含 28 位不同人士提供的内容和编辑，共 163 个提交；其致谢部分还感谢了另外几位具名贡献者、它所基于的先前工作的作者，以及众多“[结构化评审]的参与者”。

- [BOLTs #697][] 修改了 [BOLT4][] 中描述的 sphinx 数据包构造方式，修复一个隐私泄露：目标节点可能由此发现返回源节点路径的长度。有关该泄露的细节请参见 [Newsletter #72][news72 leak]。Optech 跟踪的三个实现也都更新了代码来修复该泄露：[C-Lightning][news72 cl3246]、[Eclair][news81 eclair1247] 以及 [LND-Onion][] 库。<!-- LND 洋葱 PR 在 Newsletter #72 的新闻项目中提到，我们已经链接到，因此在上方直接链接到 PR -->

- [BOLTs #705][] 把 [BOLT1][] 中 32768–65535 这段消息类型分配给实验性消息和应用专用消息。它还给出了供实现者参考的指导原则，其中包括建议任何从该范围给自己分配消息类型的人，把所用的编号发布到 [BOLTs issue #716][bolts #716] 上以免冲突。

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
[teinturier post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-January/002435.html
[towns layered commitments]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-January/002448.html
[elliptic curve]: https://en.bitcoin.it/wiki/Secp256k1
[news48 output commitments]: /zh/newsletters/2019/05/29/#提议的交易输出承诺
[bolt4 privacy leak]: /zh/newsletters/2019/08/28/#bolts-608
