---
title: "Bitcoin Optech Newsletter #25"
permalink: /zh/newsletters/2018/12/11/
name: 2018-12-11-newsletter-zh
slug: 2018-12-11-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的 Newsletter 建议帮助测试比特币核心维护版本的候选版本，并提供了一个现代化的区块浏览器的链接，该浏览器的代码已经开源，并简要描述了建议使用签名哈希来选择性地覆盖交易大小。还描述了过去一周内对流行基础设施项目所做的重要代码更改。

## 行动项

- **<!--help-test-bitcoin-core-0-17-1rc1-->****帮助测试比特币核心 0.17.1RC1：** [维护版本][maintenance release]的第一个候选版本已经[上传][V0.17.1rc1]。非常感谢企业和个人用户对守护进程和 GUI 的测试，这有助于确保发布的最高质量。

## 新闻

- **<!--modern-block-explorer-open-sourced-->****现代化的区块浏览器已开源：** 在最近[宣布][explorer announce]新的区块浏览器网站之后，Blockstream 宣布了其后端和前端代码的[开源发布][explorer code announce]。该代码支持比特币主网、比特币测试网和 Liquid 侧链。

  尽管区块浏览器自 2010 年以来一直是比特币 Web 应用的主要组成部分，但我们注意到区块浏览器使用的方法，即在所有区块链数据上维护多个索引，本质上具有较差的可扩展性特征---随着区块链的增长，其成本会随着时间的推移而增加---因此通常不建议构建依赖自己的区块浏览器的软件或服务。信任别人的区块浏览器（当自行索引数据变得太昂贵时，这是常见的节约成本措施）会在比特币软件中引入第三方信任，增加集中化，并降低隐私。如果可能的话，最好以不需要区块浏览器所提供的快速和任意搜索的方式构建软件和服务。

  话虽如此，新的开源区块浏览器似乎比早期的开源替代方案（如 BitPay Insight）要高效得多。它还包括现代功能（如 bech32 地址支持）和非常好看的默认主题。

- **<!--sighash-options-for-covering-transaction-weight-->****覆盖交易权重的签名哈希选项：** 作为*新闻*部分中描述的签名哈希讨论的一部分，Russell O'Connor [提出][weight sighash]应该有一种选择性的能力，可以让交易签名承诺交易的权重（大小）。这可以缓解一些高级脚本可能存在的问题，其中对手或第三方可能会向交易中添加额外数据，降低其费率，并可能使其确认时间更长。

## 值得注意的代码更改

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-lightning][core lightning repo] 和 [libsecp256k1][libsecp256k1 repo] 中的值得注意的代码更改。*

- [LND #2007][] 添加了一个新的 `MaxBackoff` 配置选项，允许更改节点在放弃尝试重新连接其持久对等点之前等待的最长时间。直到达到最大值之前，将使用相同的当前指数回退算法。

- [LND #2006][] 使使用自动驾驶建议引擎与备用建议引擎更容易。当前方法仅返回建议与其建立新通道的对等方的列表。新方法允许指定要考虑的数据，并返回算法评分的节点列表（评分较高者更好）。备用建议引擎可以返回其自己的得分建议，用户（或其软件）可以决定如何聚合或以其他方式使用分数来实际决定哪些节点应接收通道打开尝试。

- [C-Lightning #2123][] 添加了一个新的 `check` RPC，用于检查 RPC 调用是否使用有效的参数，而不运行调用。

- [C-Lightning #2127][] 添加了一个新的 `--plugin-dir` 配置选项，将加载指定目录中的插件。该参数可以多次传递以用于不同的目录。`--plugin` 选项还允许加载单个插件。

- [C-Lightning #2121][] 允许插件添加新的 JSON-RPC 方法。对于用户来说，这些方法看起来与内置方法没有区别，包括在由`help` RPC 返回的支持方法列表中出现。

- [C-Lightning #2147][] 在`fundchannel` RPC 中添加了一个新的 `announce` 参数，允许将通道标记为私有，这意味着它不会在网络上公开宣布。通道的默认值是公开的。

{% include references.md %}
{% include linkers/issues.md issues="2007,2006,2123,2127,2121,2147" %}

[V0.17.1rc1]: https://bitcoincore.org/bin/bitcoin-core-0.17.1/
[maintenance release]: https://bitcoincore.org/en/lifecycle/#maintenance-releases
[explorer announce]: https://blockstream.com/2018/11/06/explorer-launch/
[explorer code announce]: https://blockstream.com/2018/12/06/esplora-source-announcement/
[weight sighash]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-December/016534.html
[newsletter #23]: /zh/newsletters/2018/11/27/#sighash-updates
