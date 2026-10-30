---
title: 'Bitcoin Optech Newsletter #69'
permalink: /zh/newsletters/2019/10/23/
name: 2019-10-23-newsletter-zh
slug: 2019-10-23-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 请求协助测试 C-Lightning 与 Bitcoin Core 的候选发布版本，邀请众人参与对 taproot 提案的结构化评审，重点介绍两个比特币钱包的更新，并介绍热门比特币基础设施项目的若干值得注意的变更。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- **<!--help-test-release-candidates-->****帮助测试候选版本：** 鼓励有经验的用户帮助测试即将发布的 [Bitcoin Core 0.19.0][Bitcoin Core 0.19.0] 和 [C-Lightning 0.7.3][c-lightning 0.7.3] 的最新候选版本。

## 新闻

- **<!--taproot-review-->****taproot 评审：** 从 11 月第一周开始，几位比特币贡献者将主持一系列每周会议，带着大家走一遍对拟议中 [bip-schnorr][]、[bip-taproot][] 与 [bip-tapscript][] 各项改动的评审。欢迎所有开发者、学者以及其他有技术经验的人参加。预期投入为连续七周、每周四小时：每周一小时集体会议，其余三小时用于你独立评审这些提案。除评审外，还鼓励开发者自愿做一个概念验证，展示如何把 schnorr 或 taproot 集成进现有软件，或者演示这些提案带来了哪些新功能或改进功能。这有助于实现者发现当前提案中存在的缺陷或次优要求，而只读文档的人可能察觉不到这些。

  评审的最终目标，是让参与者对这些提案获得足够的技术熟悉度，从而能够明确表态支持、主张修改，或者清楚地说明提案为何不应被纳入比特币共识规则。向比特币添加新共识规则必须慎之又慎——只要还有人的比特币依赖这些规则，它就无法被安全地撤销——因此，在提案付诸实施之前、在请用户考虑升级全节点以执行新规则之前，让大量技术审查者检查提案有无缺陷，符合每一位用户的利益。无论通过这种有组织的评审还是其他方式，Optech 都强烈鼓励所有有技术能力的比特币用户投入时间评审 taproot 这一组提案。

  有意参与的人应尽快 [RSVP][tr rsvp]，以便组织者估算总参与人数并开始组建学习小组。要注册或了解更多信息，请参阅 [Taproot Review][tr] 仓库。

## 服务和客户端软件的变更

*在本月栏目中，我们重点介绍 Bitcoin 钱包与服务的一些有趣更新。*

- **<!--electrum-lightning-support-->****Electrum 支持闪电网络：** 在本月的一系列[提交][electrum commits]中，Electrum 已把对闪电网络的支持合并进主分支。Thomas Voegtlin 的一份题为 [Electrum 中的闪电网络实现][electrum lightning presentation]的演示幻灯片提供了一些背景信息和截图。

- **<!--blockstream-green-tor-support-->****Blockstream Green Tor 支持：** Blockstream Green 钱包的 3.2.4 版本为 iOS 和 Android [增加了内置的 Tor 支持][blockstream green tor article]。尽管之前的 Android 版本支持 Tor，但它需要一个单独的应用程序，而现在 Android 和 iOS 版本都已捆绑了 Tor 支持。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo] 和 [闪电网络规范（BOLTs）][bolts repo] 中值得注意的变更。*

- [C-Lightning #3150][] 新增了 `signmessage` 和 `checkmessage` 两个 RPC。前者对一条消息签名，持有你 LN 节点公钥的人可以验证该签名。后者用于验证来自另一节点的签名消息：既可以用用户提供的公钥来验证，也可以确认该消息是由某个已知 LN 节点的公钥签名的（例如 `listnodes` RPC 返回的节点集合中的某个节点）。

- [LND #3595][] 把默认的最大 CLTV 到期时间从 1,008 个区块（约 1 周）提高到 2,016 个区块（约两周）。这是新付款被付款方回收之前，最多可以被挂起多久。LND 最近曾试图把 CLTV delta（即支付路径上每个路由节点必须等待、之后才能取走自己那份付款的最小区块数）从 144 个区块降到 40 个区块（参见 [Newsletter #40][lnd cltv delta]），从而把这个上限维持在 1,008 个区块，但较旧的 LND 节点和某些其他实现仍以 144 作为默认值。如果每一跳都要求 144 的 delta，那么新的 2,016 上限就意味着最长路由路径约为 14 跳。

- [LND #3597][] 撤销了 [Newsletter #64][lnd3485] 中描述的迁移策略，即 LND 最多只能从上一个主要版本升级。撤销该策略的 PR 写道：“此前更严格的策略给打包 lnd 的应用程序造成了很大负担，它们不得不部署专门的代码来处理某些升级路径。此外，大家还意识到该策略对移动端部署的伤害最大，因为用户习惯跳过版本，使得在不显著影响最终用户的前提下，很难应付更严格的升级策略。”

{% include linkers/issues.md issues="3595,3597,3150" %}
[bitcoin core 0.19.0]: https://bitcoincore.org/bin/bitcoin-core-0.19.0/
[blockstream green tor article]: https://bitcoinmagazine.com/articles/blockstream-green-wallet-adds-early-access-tor-integration
[c-lightning 0.7.3]: https://github.com/ElementsProject/lightning/releases/tag/v0.7.3rc3
[electrum commits]: https://github.com/spesmilo/electrum/commits/master
[electrum lightning presentation]: https://www.electrum.org/talks/lightning/presentation.html#slide1
[lnd cltv delta]: /zh/newsletters/2019/04/02/#lnd-2759
[lnd3485]: /zh/newsletters/2019/09/18/#lnd-3485
[tr]: https://github.com/ajtowns/taproot-review
[tr rsvp]: https://forms.gle/iiPaphTcYC5AZZKC8
