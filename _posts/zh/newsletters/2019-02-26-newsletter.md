---
title: 'Bitcoin Optech Newsletter #35'
permalink: /zh/newsletters/2019/02/26/
name: 2019-02-26-newsletter-zh
slug: 2019-02-26-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了一个实现 BIP-Schnorr 兼容签名的 libsecp256k1 分支的可用性，列出了 Bitcoin Stack Exchange 二月的热门问题和答案，并描述了流行的 Bitcoin 基础设施项目中的值得注意的合并。

## 行动项

本周无。

## 新闻

- **<!--schnorr-ready-fork-of-libsecp256k1-available-->****Schnorr 准备就绪的 libsecp256k1 分支可用：**Blockstream 的密码学家 Andrew Poelstra [宣布][schnorr libsecp256k1-zkp]，用于 [Elements Project][]（如 [Liquid][]）侧链的 [libsecp256k1-zkp][] 库现在支持多种配置的 [BIP-Schnorr][] 兼容签名：

  - **<!--basic-single-pubkeys-and-signatures-->**基本的单一公钥和签名。这些的使用与 Bitcoin 当前的 ECDSA 算法几乎相同，尽管签名序列化后大约少了八个字节，并且可以批量高效验证。

  - [MuSig][] 多方签名。链上，它们看起来与单一公钥和签名相同，但公钥和签名是通过多步骤协议由一组私钥生成的。而当前 Bitcoin Script 使用的 multisig 需要 *n* 个公钥和 *k* 个签名以实现 k-of-n multisig 安全性，MuSig 可以仅用一个公钥和一个签名提供相同的安全性——减少了区块链空间，提高了验证效率，增加了隐私，并允许比 Bitcoin Script 当前字节大小和签名操作限制支持的更大签名者集合。但它有两个缺点：隐私的增加也破坏了可证明的责任制——无法知道创建签名的特定授权签名者子集是谁——并且多步骤协议需要特别小心地管理秘密 nonce 以避免意外泄露私钥。为解决第二个问题，Poelstra 的帖子详细介绍了 libsecp256k1-zkp 如何尝试最小化 nonce 相关故障的风险，并预示未来可能有更好的解决方案。

  - **<!--adapter-signatures-for-scriptless-scripts-->**用于无脚本脚本的适配器签名。使用多步骤协议，Alice 可以向 Bob 证明她的最终签名将揭示一个满足某个特定条件的值。例如，该值可以是另一个允许 Bob 自己索取某个其他支付（如原子交换或闪电网络支付承诺）的签名。对于 Alice 和 Bob 之外的所有人来说，该签名只是另一个没有特殊意义的有效签名。这通常可以通过消除链上包含特殊数据的需要（例如当前在原子交换和闪电网络支付承诺中使用的哈希和哈希锁）来提高链上部分协议的隐私性和效率。

  更新的库本身并未使这些功能在侧链上可用，但它确实提供了生成和验证签名所需的代码——允许开发人员构建将 Schnorr 基于系统投入生产所需的工具。希望这些代码将获得更多审查并被移植到上游 [libsecp256k1][libsecp256k1 repo] 库中以最终用于 Bitcoin Core 相关的软分叉提案。欲了解更多信息，请阅读[博客文章][schnorr libsecp256k1-zkp]或[开发者文档][schnorr docs]。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选之一——或者当我们有一些空闲时间帮助好奇或困惑的用户时也会去那里。在这个月度专题中，我们重点介绍自上次更新以来的一些顶级投票问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--why-does-bip44-have-internal-and-external-addresses-->**[为什么 BIP44 有内部和外部地址？]({{bse}}84594)外部地址是你提供给其他人以便他们付款的地址；内部地址是你在自己的交易中用于接收找零的地址。Pieter Wuille 解释道，[BIP32][]，基于 [BIP44][]，鼓励使用不同的派生路径来区分这些密钥，以防你需要向审计员证明你收到了多少钱，但不想让他们知道你花了多少钱（或剩下了多少钱）。通过给审计员仅提供外部地址的扩展公钥（xpub），他可以跟踪你的收款，但仍无法通过找零地址直接获取你的支出或当前余额的任何信息。

- **<!--taproot-and-scriptless-scripts-both-use-schnorr-but-how-are-they-different-->**[Taproot 和无脚本脚本都使用 Schnorr，但它们有什么不同？]({{bse}}84086)在不同的答案中，Gregory Maxwell 和 Andrew Chow 各自描述了这两种基于 Schnorr 签名提案的区别。还包括适配器签名的描述，适配器签名可用于增强无信任合约协议的效率和隐私性。

- **<!--how-much-of-block-propagation-time-is-used-in-verification-->**[区块传播时间有多少用于验证？]({{bse}}84045)Gregory Maxwell 解释说，对于正常情况，这可能接近 0% 而不是 1%，但对于特意构造以耗时验证的最坏情况区块，它可能会大得多。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和 [Bitcoin Improvement Proposals (BIPs)][bips repo] 中值得注意的更改。*

- **<!--bitcoin-core-15348-->**[Bitcoin Core #15348][] 添加了一个[生产力提示][productivity hints]文档，描述了开发人员发现的提高效率的工具和技术。尽管有些是特定于 Bitcoin Core 和 C++ 开发的，但其他的更广泛适用于任何使用 git 或 GitHub 的开发人员。

- [C-Lightning #2343][] 将项目现有文档以更好的格式提供在 [ReadTheDocs.io][cl rtd] 上。

- [C-Lightning #2353][]、[#2360][C-Lightning #2360] 和 [#2365][C-Lightning #2365] 更新了各种 RPC，现在接受带有“btc”、“sat”或“msat”后缀的值以指示值的单位。“btc”值允许最多 11 个小数位，“sat”值允许最多 3 个小数位，但在两种情况下，最后三位必须为零用于链上操作，因为比特币协议不支持额外的精度。其他 RPC 返回的新字段以 `_msat` 结尾，始终包含 millisatoshi 值。还进行了几项内部 API 更改。

- [C-Lightning #2380][] 要求交易至少有一个确认才能让钱包默认尝试花费其比特币。这解决了一个问题，即钱包会尝试花费自己的未确认找零输出，但这些支付有时会因为先前支付确认速度慢而卡住。几个与支付相关的 RPC 接受一个 `minconf` 参数，默认为 `1`，但可以设置为 `0` 以继续旧行为，或者如果需要可以设置为更高值。

- [Eclair #821][] 改进了用于帮助找到发送支付的良好路径的启发式方法。


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
