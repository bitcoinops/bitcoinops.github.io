---
title: 'Bitcoin Optech Newsletter #56'
permalink: /zh/newsletters/2019/07/24/
name: 2019-07-24-newsletter-zh
slug: 2019-07-24-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 介绍了 signet 的进展，以及一个在 LN 上做即时路由的想法。此外，还包括我们常规的 bech32 发送支持部分，以及流行比特币基础设施项目中值得注意的变更。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- **<!--help-test-bitcoin-core-0-18-1-release-candidates-->****帮助测试 Bitcoin Core 0.18.1 候选版本：** 这个即将发布的维护版本修复了几个错误，这些错误影响了部分 RPC 命令，并在某些情况下导致 CPU 使用率不必要地升高。我们鼓励生产环境用户测试当前的[候选版本][core rc]，以确保其按预期运行。

## 新闻

- **<!--progress-on-signet-->****signet 的进展：** signet 是一种测试网的替代方案，其有效区块由一个受信任的权威机构签名。该权威机构通常会按稳定节奏产出一系列区块，但偶尔也会产生分叉，导致区块链重组。这样就避免了测试网上常见的问题，例如出块过快、出块过慢，以及涉及数千个区块的重组。在我们此前于 [Newsletter #37] 报道 signet 之后，其作者已写出一个实现，并在[wiki 页面][signet wiki]上做了文档说明，还提交了一个[拉取请求][Bitcoin Core #16411]，提议在 Bitcoin Core 中加入对 signet 的支持，同时向 Bitcoin-Dev 邮件列表提交了一份[BIP 草案][signet bip post]。该提案中的实现还让团队可以轻松创建自己的独立 signet，用于专门的团体测试。例如 signet 作者 Kalle Alm 提到：“已经有人在做一个叠加了 [bip-taproot][] 补丁的 signet。” signet 有望大大方便开发者在一个多用户环境中测试自己的应用，因此我们鼓励所有当前使用测试网的用户以及其他对 signet 感兴趣的人审阅上述代码和文档，确认 signet 能满足你的需求。

- **<!--additional-just-in-time-jit-ln-routing-discussion-->****进一步的即时（JIT）LN 路由讨论：** 在两周前 [Newsletter][Newsletter #54] 所介绍的 JIT 讨论中，贡献者 ZmnSCPxj 解释了为什么在许多情况下，路由节点需要零手续费的再平衡操作，JIT 路由才具备激励兼容性。本周，他在 C-Lightning 邮件列表上[发布][jit with fee]了一项建议，说明节点在为 JIT 路由进行有偿再平衡时，如何可以放宽激励兼容性的要求，同时仍然防止滥用。节点会记录自己从每个通道赚到多少路由手续费，再平衡时最多花掉同等金额。这样一来，不诚实的通道对手方最多只能拿走它此前已让诚实对等节点赚到的那部分路由手续费，无法多拿。

## Bech32 发送支持

*这是共 24 周的[系列][bech32 series]中的第 19 周，目的是让你支付的对象也能获得隔离见证的全部好处。*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/zh/19-real-fees.md %}

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo] 中的值得注意的变更。*

- [Bitcoin Core #15891][] 更改了使用 regtest 模式时的节点默认设置，使其执行与主网相同的标准交易规则。这些规则决定了节点中继并接受哪些交易进入内存池。这项更改应能让开发者更容易按默认策略测试自己的自定义交易。任何需要旧行为（中继并接受任何共识有效的交易）的人可以使用 `acceptnonstdtxn` 配置参数。

- [Bitcoin Core #16152][] 默认禁用 [BIP37][] 的布隆过滤器支持。此功能允许轻量级钱包从其地址列表中创建一个[布隆过滤器][bloom filter]，将该过滤器发送到节点，要求节点扫描历史区块或新的传入交易，并仅返回与过滤器匹配的那些交易。这使得轻量级客户端仅接收它感兴趣的交易（以及可能的少量额外的误报匹配），从而减少了带宽需求。然而，这也意味着客户端可以让全节点一遍又一遍地扫描和重新扫描整条历史区块链，而客户端无需付出任何代价——这就为 DoS 攻击提供了途径。

  出于这个原因以及其他原因（包括[隐私问题][filter privacy]），许多 Bitcoin Core 贡献者多年来一直希望禁用该功能。此前的努力包括：加入一个 [BIP111][] 服务标志，用来表示节点是否支持布隆过滤器，以便客户端找到支持的节点；以及加入 `peerbloomfilters` 配置选项，让担心 DoS 攻击的节点用户可以禁用布隆过滤器。此外，隔离见证激活后，布隆过滤器支持从未更新去检查新的见证字段内容，因此对隔离见证钱包来说，它没能发挥出本可以有的作用。

  在 PR #16152 中，布隆过滤器配置选项现在默认设为关闭。仍希望提供布隆过滤器的用户可以重新启用它。更值得注意的是，许多节点在新版本可用之后仍会继续运行旧版本好几年，因此预计使用布隆过滤器的钱包开发者在 Bitcoin Core 0.19 发布后（[预计][Bitcoin Core #15940]在 2019 年末发布）还有一段时间可以寻找替代的数据来源。

- [Bitcoin Core #15681][] 为 Bitcoin Core 中用于防止耗费 CPU 和内存的 DoS 攻击的交易包限制规则增加了一项例外。此前，如果内存池中的一笔交易有 25 个后代，或者它及其全部后代的大小超过 101,000 vbytes，那么任何新收到的、同样属于其后代的交易都会被忽略。现在会额外允许一个后代，前提是它是直接后代（子交易），且该子交易的大小不超过 10,000 vbytes。这样一来，像 LN 这样的两方合约协议就能给每个参与者一个可以立即花费的输出，用于子为父付（CPFP）手续费追加，同时又不会让某个恶意参与者塞满整个交易包，从而阻止另一个参与者花费自己的输出。该提案此前在 Bitcoin-Dev 邮件列表中[讨论过][carve-out]（参见 [Newsletter #24][]）。

- [C-Lightning #2816][] 新增了在 signet 网络上进行测试的支持（见上文 *新闻* 部分中对 signet 的描述）。

## 脚注

{% include linkers/issues.md issues="15891,16152,15681,16411,15940,2816" %}
[bech32 series]: /zh/bech32-sending-support/
[bloom filter]: https://en.wikipedia.org/wiki/Bloom_filter
[filter privacy]: https://jonasnick.github.io/blog/2015/02/12/privacy-in-bitcoinj/
[carve-out]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-November/016518.html
[core rc]: https://bitcoincore.org/bin/bitcoin-core-0.18.1/
[signet wiki]: https://en.bitcoin.it/wiki/Signet
[signet bip post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-July/017123.html
[jit with fee]: https://lists.ozlabs.org/pipermail/c-lightning/2019-July/000160.html
[newsletter #54]: /zh/newsletters/2019/07/10/#brainstorming-just-in-time-routing-and-free-channel-rebalancing
[newsletter #24]: /zh/newsletters/2018/12/04/#cpfp-carve-out
