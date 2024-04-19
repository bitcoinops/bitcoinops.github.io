---
title: 'Bitcoin Optech Newsletter #239'
permalink: /zh/newsletters/2023/02/22/
name: 2023-02-22-newsletter-zh
slug: 2023-02-22-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报包括提议的 `OP_VAULT` 操作码的 BIP 草案的链接，总结了关于允许闪电网络节点在其通道上设置服务质量标志的讨论，转发了对闪电网络邻居节点评估标准反馈的请求，并描述了一个为种子备份和恢复方案 BIP 草案，可以在没有电子设备的情况下可靠地执行。此外还包括我们的常规部分，其中包含 Bitcoin StackExchange 中热门问答的摘要、新版本和候选版本的公告，以及对流行的比特币基础设施软件的显著变化的描述。

## 新闻

- **OP_VAULT 的 BIP 草案：** James O'Beirne 在 Bitcoin-Dev 邮件列表中[发布][obeirne op_vault]了一个指向他之前提出的 `OP_VAULT` 操作码的 [BIP 草案][bip op_vault]的链接（参见 [Newsletter #234][news234 vault]）。他还宣布，他将尝试将代码合并到 Bitcoin Inquisition 中，该项目用于测试对比特币共识和网络协议规则的大的提议变更。

- **<!--ln-quality-of-service-flag-->闪电网络服务质量标志：**Joost Jager 在 Lightning-Dev 邮件列表中[发布了][jager qos]一项允许节点发出通道“高度可用”信号的提案，表明其运营商相信它能够无故障地转发付款。如果它确实未能转发付款，则支付者可能会选择在很长一段时间内不使用该节点进行未来的付款——这比付款人可能使用没有宣传高可用性的节点的时间长很多。想最快完成支付（而不是低费用）的支付者会优先选择由自认高可用节点组成的支付路径。

    Christian Decker 的[回复][decker qos]对信誉系统中的问题进行了出色的总结，包括自认信誉的案例。他担心的一个问题是，一般的支付者不会向任何足够近的地方发送付款，以在大型网络的支付通道中频繁遇到相同的节点。如果重复的业务无论如何都很少，那么暂时不提供重复业务的威胁可能就不会有效。

    Antoine Riard [提醒][riard boomerang] 参与者关于加速支付的一种替代方法——带恢复的超额支付。以前被描述为回旋镖支付（参见[Newsletter #86][news86 boomerang]）和可退款的超额支付（参见[Newsletter #192][news192 pp]），支付者会将他们的付款金额加上一些额外的钱，将其分成几个[部分][topic multipath payments]并通过各种路线来发送。当到达的部分足以支付发票费用时，收款人就收下这些部分，并拒绝之后到达的任何额外部分（与额外资金）。这要求想要快速支付的支付者在他们的通道中有一些额外的资金，即使支付者选择的某些路径失败，它也能起作用。这降低了对支付者要能容易地找到高度可用通道的要求。这种方法的挑战是要建立一种机制，防止接收者保留任何到达的多支付的款项。

- **<!--feedback-requested-on-ln-good-neighbor-scoring-->对闪电网络良好邻居评分的请求反馈：**Carla Kirk-Cohen 和 Clara Shikhelman 在 Lightning-Dev 邮件列表中[发布][ckc-cs reputation]，请求节点对推荐参数进行反馈，这些参数用于判断其通道对手方是否是一个转发付款的良好来源。他们提出了几个判断标准，并为每个标准推荐了默认参数，但正在寻求对所做选择的反馈。

    如果一个节点确定它的一个相连节点是一个好邻居，并且该邻居将转发的支付标记为由它背书，则该节点可以为该支付提供比它提供不合格支付更多的资源访问权限。节点也可以在将支付转发到下一个通道时背书支付。正如 Shikhelman 之前与人合著的一篇论文中所述（参见 [Newsletter #226][news226 jam]），这是减轻[通道阻塞攻击][topic channel jamming attacks]提案的一部分。

- **为 Codex32 种子编码方案提议的 BIP：**Russell O'Connor 和 Andrew Poelstra（使用他们名字的变位词）[提出][op codex32]一个新的用于备份和恢复 [BIP32][] 种子方案的 BIP。类似于 [SLIP39][]，它可以选择允许使用 [Shamir 的秘密共享方案][Shamir's Secret Sharing Scheme]（SSSS）创建多个分片，要求一起使用可配置数量的分片来恢复种子。获得少于阈值份额的攻击者将对种子一无所知。与使用词表的 BIP39、Electrum、Aezeed 和 SLIP39 恢复代码不同，Codex32 使用与 [bech32][topic bech32] 地址相同的字母表。BIP 草案中的一个示例：

    ```text
    ms12namea320zyxwvutsrqpnmlkjhgfedcaxrpp870hkkqrm
    ```

    Codex32 相对于所有现有方案的主要优势在于，所有操作都可以仅使用笔、纸、说明书和剪纸来执行。这包括生成编码种子（此处可以使用骰子）、使用校验和保护种子、生成校验和共享、验证校验和以及恢复种子。我们发现能够手动验证种子或分片备份的校验和的想法是一个特别有力的概念。用户验证单个种子备份的唯一当前方法是将其输入可信计算设备并查看它是否导出预期的公钥——但确定该设备是否可信的过程通常并不简单。更糟糕的是，为了验证现有 SSSS 分片的完整性（例如在 SLIP39 中），用户必须将他们想要验证的每个分片与足够多的其他分片放在一起以达到阈值，然后将它们输入可信计算设备。这意味着验证分片完整性首先否定了拥有分片的一大好处——通过将信息分发到多个地方或多个人来保证信息安全的能力。借助 Codex32，用户可以仅使用纸、笔、一些印刷材料和几分钟的时间，定期单独验证每个分片的完整性。

    邮件列表上的讨论主要集中在 Codex32 和 SLIP39 之间的差异上，后者已经在生产中使用了几年。我们建议任何对 Codex32 感兴趣的人研究其[网站][codex32 website]或观看其作者的[视频][codex32 video]。通过 BIP 草案，提案作者希望看到钱包开始增加对使用 Codex32 编码种子的支持。

## Bitcoin Stack Exchange 网站的精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 的贡献者们寻找答案的首选之地，也是他们在有闲暇时会帮助好奇和困惑用户的地方。在这个月度栏目中，我们会举出自上次出刊以来的一些高赞问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--why-is-witness-data-downloaded-during-ibd-in-prune-mode-->为什么剪枝模式会在 IBD 期间下载见证数据？]({{bse}}117057)
  Pieter Wuille 指出，对于以[剪枝模式][prune mode]运行的节点，“见证数据同时是（a）在假设有效点之前和（b）被充分掩埋以超过剪枝点，拥有它确实没有什么好处”。目前有一个开启的[草案 PR][Bitcoin Core #27050]来解决这个问题以及一个 [PR 审核俱乐部][pr review 27050] 来跟踪提议变更。

- [<!--can-bitcoin-s-p2p-network-relay-compressed-data-->比特币的 P2P 网络可以转发压缩数据吗？]({{bse}}116999)
  Pieter Wuille 给出了两个关于压缩的邮件列表讨论的链接（一个关于 [区块头同步的专门压缩][specialized compression for headers sync]、一个关于[基于 LZO 的通用压缩][general LZO-based compression]）并指出 Blockstream Satellite 使用自定义交易压缩方案。

- [<!--how-does-one-become-a-dns-seed-for-bitcoin-core-->如何成为 Bitcoin Core 的 DNS 种子？]({{bse}}116931)
  用户 Paro 解释了想要成为可给新节点提供具有初始对方节点的 [DNS 种子][news66 dns seed]的要求。

- [<!--where-can-i-learn-about-open-research-topics-in-bitcoin-->我在哪里可以了解比特币的开放研究课题？]({{bse}}116898)
  Michael Folkson 提供了多种资源，包括 [Chaincode Labs Research][] 和 [Bitcoin Problems][] 等。

- [<!--what-is-the-maximum-size-transaction-that-will-be-relayed-by-bitcoin-nodes-using-the-default-configuration-->使用默认配置，比特币节点可中继的交易最大是多少？]({{bse}}117277)
  Pieter Wuille 说明了 Bitcoin Core 的 400,000 [weight unit][] 的标准策略规则，并指出该数值目前不可配置，同时解释了该限制可带来的好处，包括 DoS 保护。

- [<!--understanding-how-ordinals-work-with-in-bitcoin-what-is-exactly-stored-on-the-blockchain-->了解序数如何在比特币中使用。区块链上到底存储了什么？]({{bse}}117018)
  Vojtěch Strnad 解释澄清了 Ordinals Inscriptions 并不使用 `OP_RETURN`，而是使用类似于以下的 `OP_PUSHDATAx` 操作码将数据嵌入到未执行的脚本分支中：

  ```
  OP_0
  OP_IF
  <data pushes>
  OP_ENDIF
  ```

- [<!--why-doesn-t-the-protocol-allow-unconfirmed-transactions-to-expire-at-a-given-height-->为什么协议不允许未确认的交易在指定的高度上过期？]({{bse}}116926)
  Larry Ruane 引用了中本聪来解释为什么交易指定过期高度是一个看似有用，但不严谨的能力。过期高度是指，一个交易在这个区块高度之后如果还未被矿工打包，则不再有效（因此不再会被打包）。

## 版本和候选版本

*热门的比特币基础设施项目的新版本与候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [BDK 0.27.1][] 是一个安全更新，用于修复“有时 [...] 在将大字符串输入进 SQLite 的 printf 函数时导致数组边界溢出”的漏洞。只有使用 BDK 的可选 SQLite 数据库功能的软件才需要更新。有关更多详细信息，请参阅[漏洞报告][RUSTSEC-2022-0090]。

- [Core Lightning 23.02rc3][] 是这个流行的闪电网络实现的新维护版本的候选发布版本。

## 重大的文档和代码变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo] 和 [Lightning BOLTs][bolts repo]。*

- [Bitcoin Core #24149][] 添加了对基于 P2WSH 基于 [miniscript][topic miniscript] 的 [输出描述符][topic descriptors]的签名支持。如果所有必要的原像和密钥都可用并且符合时间锁，Bitcoin Core 将能够签署任何 miniscript 描述符输入。 Bitcoin Core 钱包中仍然缺少完整的 Miniscript 支持的一些功能：钱包在签名之前无法估计某些描述符的输入权重，并且在某些边界案例下还无法签署 [PSBTs][topic PSBT]。对 P2TR 输出的 Miniscript 支持也仍在等待中。

- [Bitcoin Core #25344][] 更新了 `bumpfee` 和 `psbtbumpfee` 以创建[手续费替换][topic rbf]（RBF）的手续费追加。该更新允许为替换交易指定输出。替换可能包含与被替换交易不同的一组输出。这可用于添加新输出（例如，用于迭代[支付批处理][topic payment batching]）或删除输出（例如，用于尝试取消未确认的支付）。

- [Eclair #2596][] 限制节点尝试打开[双方充值][topic dual funding] 通道的次数 [RBF] [topic rbf]，可以在节点不接受任何尝试更新前，给打开通道交易追加费用。这是因为节点需要存储有关打开通道的交易的所有可能版本的数据，所以允许无限制的费用追加可能会有问题。通常情况下，在实践中，可以产生的费用追加的数量是由每次替换所需要支付的额外交易费用限制的。然而，双方充值协议预期一个节点要存储它无法完全验证的那些费用追加，这意味着攻击者可以创建无限数量的无效费用追加交易，这些交易永远不会确认也不会付出任何交易手续费。

- [Eclair #2595][] 继续该项目在添加[通道拼接][topic splicing]支持上的工作，更新了在这种情况下用于构建交易的函数。

- [Eclair #2479][] 在以下流程中添加了对支付[要约][topic offers] 的支持：用户收到要约，告诉 Eclair 付款；Eclair 使用要约从接收方获取发票，验证发票包含所预期的参数，并根据该发票进行支付。

- [LND #5988][] 添加了一个新的可选概率估计器来寻找支付路径。它一部分上是基于之前的寻路研究（参见 [Newsletter #192][news192 pp]），也参考了其他方法。

- [Rust Bitcoin #1636][] 添加了一个 `predict_weight()` 函数。函数的输入是交易构建的模板；输出是交易的预期权重。这对于费用管理特别有用：要确定需要将哪些输入添加到交易中，需要知道费用金额，但要确定费用金额，需要知道交易的规模。该函数可以提供合理的大小估计，而无需实际构建候选交易。

{% include references.md %}
{% include linkers/issues.md v=2 issues="24149,25344,2596,2595,2479,5988,1636,27050" %}
[core lightning 23.02rc3]: https://github.com/ElementsProject/lightning/releases/tag/v23.02rc3
[news226 jam]: /zh/newsletters/2022/11/16/#paper-about-channel-jamming-attacks
[news86 boomerang]: /en/newsletters/2020/02/26/#boomerang-redundancy-improves-latency-and-throughput-in-payment-channel-networks
[news92 overpayments]: /en/newsletters/2022/03/23/#payment-delivery-algorithm-update
[codex32 website]: https://secretcodex32.com/
[codex32 video]: https://www.youtube.com/watch?v=kf48oPoiHX0
[news192 pp]: /en/newsletters/2022/03/23/#payment-delivery-algorithm-update
[obeirne op_vault]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021465.html
[bip op_vault]: https://github.com/jamesob/bips/blob/jamesob-23-02-opvault/bip-vaults.mediawiki
[news234 vault]: /zh/newsletters/2023/01/18/#vault
[jager qos]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-February/003842.html
[decker qos]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-February/003844.html
[riard boomerang]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-February/003852.html
[ckc-cs reputation]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-February/003857.html
[slip39]: https://github.com/satoshilabs/slips/blob/master/slip-0039.md
[shamir's secret sharing scheme]: https://en.wikipedia.org/wiki/Shamir%27s_secret_sharing
[op codex32]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021469.html
[RUSTSEC-2022-0090]: https://rustsec.org/advisories/RUSTSEC-2022-0090
[bdk 0.27.1]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.27.1
[prune mode]: https://bitcoin.org/en/full-node#reduce-storage
[pr review 27050]: https://bitcoincore.reviews/27050
[specialized compression for headers sync]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-March/015851.html
[general LZO-based compression]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2015-November/011837.html
[news66 dns seed]: /en/newsletters/2019/10/02/#bitcoin-core-15558
[Chaincode Labs Research]: https://research.chaincode.com/research-intro/
[Bitcoin Problems]: https://bitcoinproblems.org/
[weight unit]: https://en.bitcoin.it/wiki/Weight_units
