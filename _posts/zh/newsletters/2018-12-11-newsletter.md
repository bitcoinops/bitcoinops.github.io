---
title: "Bitcoin Optech Newsletter #25"
permalink: /zh/newsletters/2018/12/11/
name: 2018-12-11-newsletter-zh
slug: 2018-12-11-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 建议你帮助测试 Bitcoin Core 维护版本的候选发布，给出了一个现代区块浏览器的链接（其代码已经开源），并简要介绍了一项建议：让签名哈希可以选择性地承诺交易大小。文中还描述了过去一周热门基础设施项目中值得注意的代码变更。

## 行动项

- **<!--help-test-bitcoin-core-0-17-1rc1-->****帮助测试 Bitcoin Core 0.17.1RC1：** 这个[维护版本][maintenance release]的第一个候选发布已经[上传][V0.17.1rc1]。我们非常欢迎企业和个人用户测试守护进程和 GUI，这有助于确保发布质量达到最高。

## 新闻

- **<!--modern-block-explorer-open-sourced-->****现代化的区块浏览器已开源：** 在最近[宣布][explorer announce]新的区块浏览器网站之后，Blockstream 宣布了其后端和前端代码的[开源发布][explorer code announce]。该代码支持比特币主网、比特币测试网和 Liquid 侧链。

  尽管区块浏览器自 2010 年以来一直是比特币 Web 应用的主要组成部分，但我们要指出：区块浏览器要在全部区块链数据上维护多个索引，这种做法本身的可扩展性就很差——随着区块链增长，其成本会越来越高——因此通常不建议构建依赖自建区块浏览器的软件或服务。信任别人的区块浏览器（当自行索引数据变得太昂贵时，这是常见的节约成本措施）会给比特币软件引入第三方信任，加剧中心化，并降低隐私。如果可能，构建软件和服务时最好不要依赖区块浏览器带来的那种快速、随意的搜索。

  话虽如此，与早先的开源替代方案（如 BitPay Insight）相比，新的开源区块浏览器似乎相当高效。它还包含现代功能（例如 bech32 地址支持）和非常好看的默认主题。

- **<!--sighash-options-for-covering-transaction-weight-->****覆盖交易权重的签名哈希选项：** 作为 [Newsletter #23][newsletter #23] *新闻*部分所描述的签名哈希讨论的一部分，Russell O'Connor [提出][weight sighash]：交易签名应当可以选择承诺交易的权重（大小）。这可以缓解某些高级脚本被认为存在的一个问题：对手方或第三方可能向交易中添加额外数据，降低其费率，使其更晚确认。

## 值得注意的代码变更

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-lightning][core lightning repo] 和 [libsecp256k1][libsecp256k1 repo] 中值得注意的代码变更。*

- [LND #2007][] 新增了 `MaxBackoff` 配置选项，可以更改节点放弃重连某个持久对等节点之前的最长等待时间。在达到这个上限之前，仍然沿用现行的指数退避（exponential backoff）算法。

- [LND #2006][] 使自动巡航（autopilot）推荐引擎更容易与其他推荐引擎配合使用。现有方法只返回一个列表，列出系统建议与之建立新通道的对等节点。新方法允许指定要考虑哪些数据，并返回由算法评分的节点列表（评分越高越好）。其他推荐引擎可以返回自己的带评分推荐，用户（或其软件）可以决定如何汇总或以其他方式使用这些评分，最终决定向哪些节点发起通道打开尝试。

- [C-Lightning #2123][] 新增 `check` RPC，用于在不执行调用的前提下检查该调用的参数是否有效。

- [C-Lightning #2127][] 新增 `--plugin-dir` 配置选项，会加载指定目录中的插件。该参数可以多次传入，以指定不同目录。`--plugin` 选项还可以加载单个插件。

- [C-Lightning #2121][] 允许插件添加新的 JSON-RPC 方法。对用户来说，这些方法与内置方法没有区别，也会出现在 `help` RPC 返回的受支持方法列表中。

- [C-Lightning #2147][] 在 `fundchannel` RPC 中新增 `announce` 参数，允许把通道标记为私有，也就是不在网络上公开宣布。通道默认为公开。

{% include references.md %}
{% include linkers/issues.md issues="2007,2006,2123,2127,2121,2147" %}

[V0.17.1rc1]: https://bitcoincore.org/bin/bitcoin-core-0.17.1/
[maintenance release]: https://bitcoincore.org/en/lifecycle/#maintenance-releases
[explorer announce]: https://blockstream.com/2018/11/06/explorer-launch/
[explorer code announce]: https://blockstream.com/2018/12/06/esplora-source-announcement/
[weight sighash]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-December/016534.html
[newsletter #23]: /zh/newsletters/2018/11/27/#sighash-updates
