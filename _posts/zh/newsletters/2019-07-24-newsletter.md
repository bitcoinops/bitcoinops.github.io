---
title: 'Bitcoin Optech Newsletter #56'
permalink: /zh/newsletters/2019/07/24/
name: 2019-07-24-newsletter-zh
slug: 2019-07-24-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了 signet 的进展以及一个关于闪电网络 (LN) 上即时路由的新想法。此外，还包括我们关于 Bech32 发送支持的常规部分，以及对流行的比特币基础设施项目的重要变更的总结。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- **<!--help-test-bitcoin-core-0-18-1-release-candidates-->****帮助测试 Bitcoin Core 0.18.1 候选版本：** 这个即将发布的维护版本修复了几个影响某些 RPC 命令的错误，并在某些情况下导致不必要的高 CPU 使用率。我们鼓励生产环境的用户测试当前的[候选版本][core rc]，以确保其按预期运行。

## 新闻

- **<!--progress-on-signet-->****signet 的进展：** signet 是一个测试网替代品，有效区块由一个受信任的权威机构签名。该权威机构通常会生成一系列规则区块，但偶尔也会生成导致区块链重组的分叉。这避免了在测试网中常遇到的问题，例如过快的区块生成、过慢的区块生成以及涉及数千个区块的重组。在我们之前在 [Newsletter #37] 中的报告之后，signet 的作者已经创建了一个实现，并在一个[wiki 页面][signet wiki]上进行了文档化，还打开了一个[拉取请求][Bitcoin Core #16411]，提议在 Bitcoin Core 中添加对 signet 的支持，并在 Bitcoin-Dev 邮件列表中发布了一个[BIP 草案][signet bip post]。该提议的实现还使团队能够轻松创建自己的独立 signet 以进行专门的组测试，例如 signet 作者 Kalle Alm 报告称，“已经有人在一个应用了 [bip-taproot][] 补丁的 signet 上进行工作。” signet 有望使开发人员更容易在多用户环境中测试他们的应用程序，因此我们鼓励所有当前的测试网用户和任何其他对 signet 感兴趣的人审查上述代码和文档，以确保 signet 能满足您的需求。

- **<!--additional-just-in-time-jit-ln-routing-discussion-->****进一步的即时 (JIT) 闪电网络路由讨论：** 在两周前的 [Newsletter][Newsletter #54] 中描述的 JIT 讨论中，贡献者 ZmnSCPxj 解释了为什么在许多情况下路由节点需要零费用的重新平衡操作，以使 JIT 路由具有激励兼容性。本周，他在 C-Lightning 邮件列表中[发布了][jit with fee]一个建议，说明节点如何可以在不那么激励兼容的情况下，仍然在执行付费重新平衡时防止滥用。节点将跟踪它们从每个通道赚取的路由费，并花费最多相同数量的资金用于重新平衡。这将确保不诚实的通道对手方无法窃取比它已经允许其诚实的对手方通过路由费获取的更多资金。

## Bech32 发送支持

*关于使您支付的对象能够访问 SegWit 的所有好处的[系列][bech32 series]的第 19 周，共 24 周。*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/zh/19-real-fees.md %}

## 值得注意的代码和文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo] 和 [Lightning BOLTs][bolts repo] 中的值得注意的变更。*

- [Bitcoin Core #15891][] 更改了在 regtest 模式下使用时的节点默认设置，以执行与主网相同的标准交易规则。这些规则决定了节点将转发哪些交易并接受到内存池中。此更改应使开发人员更容易根据默认策略测试他们的自定义交易。任何需要旧行为（转发和接受任何共识有效交易）的人可以使用 `acceptnonstdtxn` 配置参数。

- [Bitcoin Core #16152][] 默认禁用 [BIP37][] 的布隆过滤器支持。此功能允许轻量级钱包从其地址列表中创建一个[布隆过滤器][bloom filter]，将该过滤器发送到节点，要求节点扫描历史区块或新的传入交易，并仅返回与过滤器匹配的那些交易。这使得轻量级客户端仅接收它感兴趣的交易（以及可能的少量额外的误报匹配），从而减少了带宽需求。然而，它也意味着客户端可以要求全节点一遍又一遍地扫描和重新扫描整个历史区块链，而无需为客户端付出任何代价——这为 DoS 攻击创造了一个向量。

  出于这个原因和其他原因（包括[隐私问题][filter privacy]），许多 Bitcoin Core 贡献者多年来一直希望禁用此功能。早期的努力包括添加一个 [BIP111][] 服务标志，指示节点是否支持布隆过滤器，以便客户端可以找到支持的节点，并添加一个 `peerbloomfilters` 配置选项，允许节点用户在担心 DoS 攻击的情况下禁用布隆过滤器。此外，自从 SegWit 激活后，布隆过滤器支持从未更新以检查新见证字段的内容，这使得它对 SegWit 钱包的作用不如它本来可能的那么有用。

  通过此拉取请求 #16152，布隆过滤器配置选项现在默认关闭。仍然希望提供布隆过滤器的用户可以重新启用它。更值得注意的是，许多节点在新版本发布后会继续运行旧版本多年，因此预计使用布隆过滤器的钱包开发人员在 Bitcoin Core 0.19 发布后（[预计][Bitcoin Core #15940] 在 2019 年末）有一些时间找到替代的数据来源。

- [Bitcoin Core #15681][] 为防止 CPU 和内存浪费的 DoS 攻击，添加了 Bitcoin Core 包限制规则的例外情况。之前，如果内存池中的某个交易有 25 个后代，或者它及其所有后代的大小超过 101,000 vbytes，那么任何新接收的交易（也是后代）都会被忽略。现在，只要它是一个直接后代（子交易），并且子交易的大小不超过 10,000 vbytes，则允许一个额外的后代。这使得双方合约协议（如 LN）可以使每个参与者都有一个他们可以立即使用的输出，用于 CPFP（子支付父）费用提升，而不会让一个恶意的参与者填满整个包，从而阻止另一个参与者使用他们的输出。该提案之前曾在 Bitcoin-Dev 邮件列表中[讨论过][carve-out]（参见 [Newsletter #24][]）。

- [C-Lightning #2816][] 添加了对 signet 网络测试的支持（见上文 *新闻* 部分中对 signet 的描述）。

## 脚注

{% include linkers/issues.md issues="15891,16152,15681,16411,15940,2816" %}
[bech32 series]: /zh/bech32-sending-support/
[bloom filter]: https://en.wikipedia.org/wiki/Bloom_filter
[filter privacy]: https://jonasnick.github.io/blog/2015/02/12/privacy-in-bitcoinj/
[carve-out]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-November/016518.html
[core rc]: https://bitcoincore.org/bin/bitcoin-core-0.18.1/
[signet wiki]: https://en.bitcoin.it/wiki/Signet
[signet bip post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-July/017123.html
[jit with fee]: https://lists.ozlabs.org/pipermail/c-lightning/2019-July/000160.html
[newsletter #54]: /zh/newsletters/2019/07/10/#brainstorming-just-in-time-routing-and-free-channel-rebalancing
[newsletter #24]: /zh/newsletters/2018/12/04/#cpfp-carve-out
