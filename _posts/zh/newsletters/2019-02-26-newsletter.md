---
title: 'Bitcoin Optech Newsletter #35'
permalink: /zh/newsletters/2019/02/26/
name: 2019-02-26-newsletter-zh
slug: 2019-02-26-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 介绍了一个已可用的 libsecp256k1 分支，它实现了 BIP-Schnorr 兼容签名；列出了 Bitcoin Stack Exchange 二月的精选问答；并介绍热门 Bitcoin 基础设施项目中值得注意的合并。

## 行动项

本周无。

## 新闻

- **<!--schnorr-ready-fork-of-libsecp256k1-available-->****支持 Schnorr 的 libsecp256k1 分支现已可用：**Blockstream 密码学家 Andrew Poelstra [宣布][schnorr libsecp256k1-zkp]：[Elements Project][] 侧链（例如 [Liquid][]）所用的 [libsecp256k1-zkp][] 库，现已在多种配置下支持 [BIP-Schnorr][] 兼容签名：

  - **<!--basic-single-pubkeys-and-signatures-->**基本的单一公钥和签名。用法与 Bitcoin 当前的 ECDSA 算法几乎相同，只是签名序列化后大约少占八个字节，而且可以高效地批量验证。

  - [MuSig][] 多方签名。在链上，它看起来与单一公钥和签名没有区别，但公钥和签名是由一组私钥通过多步骤协议生成的。相比之下，用当前 Bitcoin Script 实现 k-of-n 多重签名（multisig）需要 *n* 个公钥和 *k* 个签名，而 MuSig 只用一个公钥和一个签名就能提供同样的安全性——节省区块链空间、提升验证效率、增强隐私，还能支持比 Bitcoin Script 现有字节大小限制和签名操作限制所允许的规模大得多的签名者集合。但它有两个缺点：隐私性的提升同时也破坏了可追责性——无法知道究竟是哪几位获授权的签名者参与签署；而多步骤协议需要格外小心地管理秘密 nonce，以免意外泄露私钥。针对第二个问题，Poelstra 的帖子详细说明了 libsecp256k1-zkp 如何尽量减少 nonce 相关故障的风险，并暗示未来可能有更好的解决方案。

  - **<!--adapter-signatures-for-scriptless-scripts-->**用于无脚本脚本（scriptless scripts）的适配器签名。借助一套多步骤协议，Alice 可以向 Bob 证明：她用于花费某笔支付的最终签名，会向他揭示一个能满足某个指定条件的值。例如，这个值可以是另一个签名，让 Bob 得以自己领取另一笔支付，比如原子交换或 LN 支付承诺。对于 Alice 和 Bob 之外的其他人来说，该签名只是一个普通的有效签名，没有任何特殊含义。这通常能消除在链上携带特殊数据的需要（例如目前原子交换和 LN 支付承诺中对哈希和哈希锁的使用），从而提高协议链上部分的隐私性与效率。

  更新的库本身并不会让这些功能在侧链上可用，但它确实提供了可以完成签名生成与验证的代码，让开发者能够构建把基于 Schnorr 的系统投入生产所需的工具。希望这些代码能获得更多审查，并被移植到上游的 [libsecp256k1][libsecp256k1 repo] 库中，最终用于 Bitcoin Core 上相关的软分叉提案。欲了解更多信息，请阅读[博客文章][schnorr libsecp256k1-zkp]或[开发者文档][schnorr docs]。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们有点空闲时帮助好奇或困惑用户的地方。在本月栏目中，我们精选自上次更新以来得票最高的一些问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--why-does-bip44-have-internal-and-external-addresses-->**[为什么 BIP44 有内部和外部地址？]({{bse}}84594)外部地址是你提供给其他人以便他们付款的地址；内部地址是你在自己的交易中用于接收找零的地址。Pieter Wuille 解释说，[BIP44][] 所基于的 [BIP32][] 建议为这两类密钥使用不同的派生路径，以备你需要向审计员证明自己收到了多少钱、却不必透露花了多少（或还剩多少）时使用。只把外部地址的扩展公钥（xpub）交给审计员，他就能跟踪你的收款，但仍无法通过找零地址直接得到关于你支出或当前余额的任何信息。

- **<!--taproot-and-scriptless-scripts-both-use-schnorr-but-how-are-they-different-->**[Taproot 和无脚本脚本都使用 Schnorr，但它们有什么不同？]({{bse}}84086)在各自独立的回答中，Gregory Maxwell 和 Andrew Chow 分别说明了这两种基于 Schnorr 签名的拟议用途有何区别。其中还介绍了适配器签名，它可用于提升免信任合约协议的效率与隐私性。

- **<!--how-much-of-block-propagation-time-is-used-in-verification-->**[区块传播时间有多少用于验证？]({{bse}}84045)Gregory Maxwell 解释说，对于正常情况，这可能接近 0% 而不是 1%，但对于特意构造以耗时验证的最坏情况区块，它可能会大得多。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和[比特币改进提案（BIPs）][bips repo]中值得注意的变更。*

- **<!--bitcoin-core-15348-->**[Bitcoin Core #15348][] 新增了一份[效率提示][productivity hints]文档，介绍开发者们总结出的提高效率的工具和技巧。其中一些只适用于 Bitcoin Core 和 C++ 开发，另一些则对任何用 git 或 GitHub 做开发的人都普遍适用。

- [C-Lightning #2343][] 在 [ReadTheDocs.io][cl rtd] 上以更友好的格式提供项目现有文档。

- [C-Lightning #2353][]、[#2360][C-Lightning #2360] 和 [#2365][C-Lightning #2365] 更新了多个 RPC，现在接受带“btc”、“sat”或“msat”后缀的数值，以标明数值单位。“btc”最多允许 11 位小数，“sat”最多允许 3 位小数；但在这两种情况下，对于比特币协议不支持额外精度的链上操作，末三位必须为零。其他 RPC 则返回以 `_msat` 结尾的新字段，其值始终以 millisatoshi 为单位。此外还做了几处内部 API 更改。

- [C-Lightning #2380][] 默认要求交易至少有一次确认之后，钱包才会尝试花费这笔比特币。这解决了一个问题：钱包会去花费自己尚未确认的找零输出，而这些支付有时因为前面的支付迟迟得不到确认而卡住。几个与支付相关的 RPC 接受一个 `minconf` 参数，默认值为 `1`，但可以设为 `0` 以延续旧行为，也可以根据需要设为更大的值。

- [Eclair #821][] 改进了用于寻找合适支付路径的启发式算法。


{% include references.md %}
{% include linkers/issues.md issues="15348,2419,2343,2353,2360,2365,2380,821" %}
[schnorr libsecp256k1-zkp]: https://blockstream.com/2019/02/18/musig-a-new-multisignature-standard/
[libsecp256k1-zkp]: https://github.com/ElementsProject/secp256k1-zkp
[cl rtd]: https://lightning.readthedocs.io/
[elements project]: https://elementsproject.org/
[liquid]: https://blockstream.com/liquid/
[schnorr docs]: https://github.com/ElementsProject/secp256k1-zkp/blob/secp256k1-zkp/src/modules/musig/musig.md
[productivity hints]: https://github.com/bitcoin/bitcoin/blob/master/doc/productivity.md
[musig]: https://eprint.iacr.org/2018/068
