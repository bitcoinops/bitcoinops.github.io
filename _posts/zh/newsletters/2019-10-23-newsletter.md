---
title: 'Bitcoin Optech Newsletter #69'
permalink: /zh/newsletters/2019/10/23/
name: 2019-10-23-newsletter-zh
slug: 2019-10-23-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 请求测试 C-Lightning 和 Bitcoin Core 的候选版本，邀请参与对 taproot 提案的结构化评审，重点介绍了两个比特币钱包的更新，并描述了一些比特币基础设施项目的值得注意的更改。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- **<!--help-test-release-candidates-->****帮助测试候选版本：** 鼓励有经验的用户帮助测试即将发布的 [Bitcoin Core 0.19.0][Bitcoin Core 0.19.0] 和 [C-Lightning 0.7.3][c-lightning 0.7.3] 的最新候选版本。

## 新闻

- **<!--taproot-review-->****Taproot 评审：** 从 11 月的第一周开始，几位比特币贡献者将主持一系列每周会议，帮助大家审查提议的 [bip-schnorr][]、[bip-taproot][] 和 [bip-tapscript][] 的变更。欢迎所有开发者、学者和任何具有技术经验的人参与。预期的时间投入为每周四小时，包含一小时的集体会议和三小时的独立评审工作。除了评审外，还鼓励开发者可选地实现概念验证，展示如何将 schnorr 或 taproot 集成到现有软件中，或展示这些提案使得哪些新功能或改进成为可能。

  这将帮助实施者发现当前提案中可能被仅阅读文档的人忽略的缺陷或次优要求。评审的最终目标是使参与者能够获得足够的技术熟悉度，以支持这些提案、倡导对提案进行修改，或者清楚地解释为什么这些提案不应被纳入比特币共识规则。向比特币中添加新的共识规则是一件需要谨慎处理的事情——因为只要有人持有依赖这些规则的比特币，它就无法安全地撤销——因此，技术审查者在提案实施和用户被要求考虑升级他们的全节点以执行新规则之前，审查这些提案中的潜在缺陷符合每个用户的利益。无论通过这种有组织的评审，还是以其他方式，Optech 强烈鼓励所有具有技术能力的比特币用户投入时间审查 taproot 提案。

  有意参与的人应尽快 [RSVP][tr rsvp]，以便组织者估算总参与人数并开始组建学习小组。要注册或了解更多信息，请参阅 [Taproot Review][tr] 仓库。

## 服务和客户端软件的更改

*在本月特色中，我们重点介绍了比特币钱包和服务的有趣更新。*

- **<!--electrum-lightning-support-->****Electrum 闪电网络支持：** 在本月的一系列[提交][electrum commits]中，Electrum 已将对闪电网络的支持合并到主分支。Thomas Voegtlin 的一份题为 [Electrum 中的闪电实现][electrum lightning presentation]的演示文稿提供了一些背景信息和截图。

- **<!--blockstream-green-tor-support-->****Blockstream Green Tor 支持：** Blockstream Green 钱包的 3.2.4 版本为 iOS 和 Android [增加了内置的 Tor 支持][blockstream green tor article]。尽管之前的 Android 版本支持 Tor，但它需要一个单独的应用程序，而现在 Android 和 iOS 版本都已捆绑了 Tor 支持。

## 值得注意的代码和文档更改

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo] 和 [闪电网络规范][bolts repo] 的一些值得注意的更改。*

- [C-Lightning #3150][] 添加了新的 `signmessage` 和 `checkmessage` RPC。第一个 RPC 将签署一条消息，该消息可以由拥有您闪电网络节点公钥的人进行验证。第二个 RPC 将使用用户提供的公钥或通过确认消息由任何已知的闪电网络节点（例如，通过 `listnodes` RPC 返回的节点集中的节点）签名，来验证另一节点的签名消息。

- [LND #3595][] 将默认的最大 CLTV 过期时间从 1,008 个区块（约 1 周）提高到 2,016 个区块（约两周）。这是新支付在被其支付方回收前可以被挂起的最长时间。LND 最近试图通过将 CLTV delta（每个路由节点沿支付路径收到特定付款所需的最小区块数）从 144 个区块减少到 40 个区块（参见 [Newsletter #40][lnd cltv delta]）来保持此值为 1,008 个区块，但旧版 LND 节点和某些其他实现仍然默认使用 144。如果每一跳都要求 144 的 delta，那么新的 2,016 最大过期时间使得最大路由路径长度大约为 14 跳。

- [LND #3597][] 还原了 [Newsletter #64][lnd3485] 中描述的迁移策略，LND 只能从最多一个主要版本向后升级。还原 PR 中提到：“之前更严格的策略给打包 lnd 的应用程序带来了很大的负担，它们不得不部署特殊代码来处理某些升级路径。此外，这一策略被认为对移动部署造成了最大的伤害，因为用户通常会跳过版本，这使得更严格的升级策略难以管理，而不会极大地影响最终用户。”

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
