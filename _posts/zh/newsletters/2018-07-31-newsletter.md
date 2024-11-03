---
title: 'Bitcoin Optech Newsletter #6'
permalink: /zh/newsletters/2018/07/31/
name: 2018-07-31-newsletter-zh
slug: 2018-07-31-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 包括常规的仪表盘和行动项，开发人员 Anthony Towns 关于 Xapo 合并 400 万个 UTXO 的特写文章，有关比特币脚本系统可能升级的新闻，一些在比特币堆栈交换上高票问题和回答的链接，以及 Bitcoin Core、Lightning Network Daemon (LND) 和 C-lightning 项目的开发分支中的一些值得注意的提交。

## 行动项

- **<!--bitcoin-core-0-16-2-released-->****发布 Bitcoin Core 0.16.2**：一个小版本，带来了错误修复和小改进。如果您使用 [abandontransaction][rpc abandontransaction] 或 [verifytxoutproof][rpc verifytxoutproof] RPC，您应该特别考虑升级。否则，我们建议您查看[发布说明][bitcoin core 0.16.2]了解可能影响您操作的其他变化，并在方便时升级。

## 仪表盘项

- **<!--fees-still-low-->****费用仍然低**：在周日结束的 2016 区块重新目标周期中，哈希率增加了超过14%，使区块间平均时间为 8 分 41 秒。这有助于吸收过去一周价格投机带来的交易量增加。紧随难度重新目标之后，区块间平均时间恢复为 10 分钟。

  随着我们从正常的周末交易低迷过渡到新的一周，估计的交易费用可能会迅速增加。我们建议在靠近周末时再发送大量低费用交易（如合并），那时交易量开始再次下降。

## 实地报告：Xapo 合并 400 万个 UTXO

*由 [Xapo][] 的 Bitcoin Core 开发人员 [Anthony Towns](https://twitter.com/ajtowns) 编写*

{% include articles/zh/towns-xapo-consolidation.md hlevel='###' %}

## 新闻

- **<!--improvements-in-the-bitcoin-scripting-language-by-pieter-wuille-->****Pieter Wuille 的“比特币脚本语言改进”**：上周的一次演讲，概述了比特币可能的几项近期改进。我们强烈建议观看[视频][sfdev video]，查看[幻灯片][sipa slides]，或阅读 Bryan Bishop 的[字幕][kanzure transcript]（附有参考文献）——但如果您太忙了，这里是 Wuille 的结论：“我的初步重点是 Schnorr 签名和 taproot。之所以关注这一点，是因为能够使合作情况下的任何输入和输出看起来都相同，对于脚本执行的工作方式来说是一个巨大的胜利。

    “Schnorr 对此是必需的，因为没有它，我们无法将多方编码为单个密钥。在其中包含多个分支是一个相对简单的更改。

    “如果您看一下这些事情对共识规则的影响所必需的共识变化，它实际上非常小，代码仅数十行。看起来很多复杂性在于解释这些东西为何有用以及如何使用它们，而不是在于对共识规则的影响。

    “像聚合这样的事情，我认为，在我们探索脚本语言结构改进的各种选项之后，一旦明确了结构应该是什么，就可以实施，因为我们可能会从部署中了解到这些东西在实践中是如何使用的。这就是我和许多合作者正在研究的内容，我们希望不久就能提出一些建议，这就是我的演讲结束。”

[sfdev video]: https://www.youtube.com/watch?v=YSUVRj8iznU
[sipa slides]: https://prezi.com/view/YkJwE7LYJzAzJw9g1bWV/
[kanzure transcript]: http://diyhpl.us/wiki/transcripts/sf-bitcoin-meetup/2018-07-09-taproot-schnorr-signatures-and-sighash-noinput-oh-my/

## Bitcoin Stack Exchange 精选问答

{% comment %}<!--
https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer
-->{% endcomment %}

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选之一——或者当我们有一些空闲时间帮助回答其他人的问题时。在这个新的月度特色栏目中，我们突出展示了过去一个月中一些得票最多的问题和答案。*

- **<!--schnorr-versus-ecdsa-->**[Schnorr 与 ECDSA 的对比][bse 77235]：在这个回答中，比特币协议开发者 Pieter Wuille 解释了 Schnorr 签名方案相对于比特币当前的 ECDSA 签名方案的一些主要优势。

- **<!--why-does-hd-key-derivation-stop-working-after-a-certain-index-in-bip44-wallets-->**[为什么 BIP44 钱包中的 HD 密钥派生在某个索引后停止工作？][bse 76998]：一个测试他的钱包的开发者发现，发送到低编号密钥索引的支付按预期工作，但发送到高编号索引的支付从未出现在他的钱包中。Viktor T. 的回答揭示了原因。

- **<!--the-maximum-size-of-a-bitcoin-der-encoded-signature-is-->**[比特币 DER 编码签名的最大尺寸是...][bse 77191]：在这个回答中，Pieter Wuille 提供了计算比特币签名大小的数学公式。如 [Newsletter #3][] 所述，使用常规钱包的最大尺寸是 72 字节——但 Wuille 解释了如何创建带有 73 字节签名的非标准交易，以及为什么你可能认为你看到了 74 或甚至 75 字节的签名。

- **<!--if-you-can-use-almost-any-opcode-in-p2sh-why-can-t-you-use-them-in-scriptpubkeys-->**[如果你可以在 P2SH 中使用几乎任何操作码，为什么不能在 scriptPubKeys 中使用它们？][bse 76541]：在这个回答中，比特币技术作家 David A. Harding 解释了比特币早期版本为什么将可以发送的交易类型限制为“标准交易”，以及为什么即使现在通过 P2SH 和 segwit P2WSH 几乎所有操作码都可用于标准使用，大多数这些限制仍然存在。

[Newsletter #3]: /zh/newsletters/2018/07/10/

## 值得注意的提交

*快速查看在各种开源比特币项目中最近合并和提交的情况。*

- **<!--bitcoin-core-12257-->**[Bitcoin Core #12257][]：如果你用可选标志 `-avoidpartialspends` 启动 Bitcoin Core，每当其中任何一个被花费时，钱包将默认花费接收到同一地址的所有输出。这可以防止同一地址的两个输出在不同的交易中被花费，这是地址重用降低隐私的常见方式。缺点是它可能使交易比最小需要的要大。使用 Bitcoin Core 内置钱包的比特币业务，如果不需要额外的隐私，可能仍然希望在低费用时切换此标志以自动合并相关输入。

- **<!--lnd-1617-->**[LND #1617][]：更新链上交易的大小估计，以防止交易意外支付过低的费用并卡住。[此提交][lnd ee2f2573c1b1b33288d05ba59a1e8ef9e8fb621c] 对任何想知道当前协议产生的交易（和交易的部分）大小的人可能都很有趣。

- **<!--lnd-1531-->**[LND #1531][]：守护进程不再在内存池中寻找花费——它等待它们首先被确认为区块的一部分。这允许相同的代码在像 Bitcoin Core 和 btcd 这样的完整节点以及没有访问未确认交易的 [BIP157][] 基础轻量级客户端上工作。这是正在进行的努力的一部分，以帮助没有完整节点的人使用 LN。

- **<!--c-lightning-->**在几次提交中，[C-lightning][core lightning repo] 开发人员几乎完成了从在 `gossipd` 中处理与对等方相关的功能到在 `channeld` 或 `connectd` 中处理它们的过渡。

- **<!--c-lightning-has-improved-->**C-lightning 改进了其秘密处理，以便秘密和签名始终由与网络直接连接的系统部分之外的单独守护进程生成和存储。

{% include references.md %}
{% include linkers/issues.md issues="1617,1531,12257" %}

{% assign bse = "https://bitcoin.stackexchange.com/a/" %}
[bse 77235]: {{bse}}77235
[bse 76998]: {{bse}}76998
[bse 77191]: {{bse}}77191
[bse 76541]: {{bse}}76541

[lnd ee2f2573c1b1b33288d05ba59a1e8ef9e8fb621c]: https://github.com/lightningnetwork/lnd/commit/ee2f2573c1b1b33288d05ba59a1e8ef9e8fb621c