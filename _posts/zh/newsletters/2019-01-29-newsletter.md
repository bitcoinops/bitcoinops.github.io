---
title: 'Bitcoin Optech Newsletter #31'
permalink: /zh/newsletters/2019/01/29/
name: 2019-01-29-newsletter-zh
slug: 2019-01-29-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了有关改进隐私性的 Payjoin 提案的帖子，链接到了 Bitcoin Stack Exchange 上最受欢迎的问题和答案，并描述了另一个备受关注的项目在流行的比特币基础设施项目中进行的一周繁忙的值得注意的提交。

## 行动项

本周无。

## 新闻

- **<!--post-about-bip79-p2ep-payjoin-->****关于 BIP79（P2EP/payjoin）的帖子：** Joinmarket 开发者 Adam（waxwing） Gibson 在比特币开发者邮件列表上发送了一篇[帖子][payjoin post]，介绍了在 [BIP79][] 中描述的 Pay-to-EndPoint（P2EP）提案的简化版本。 该提案允许在链上支出者在自己的输入中包括接收交易的人的输入，从而防止区块链分析师能够合理地假设所有输入都来自同一个人。 即使只有相当少的人使用该功能，这也可能使区块链分析变得不那么可靠。详情请参阅[Newsletter #27][payjoin summary]。

  Gibson 的建议主要集中在修改该提案，根据他在 Joinmarket 的开发版本中实现类似 P2EP 协议的经验，以及他从 Samourai Wallet 的开发人员那里收到的反馈。 后者也实现了一个变体的协议，仍在开发者测试中。 目标是尝试让两个钱包（以及许多其他钱包）使用相同的协议，并且也得到像 BTCPay 这样的支付处理器的支持。 这些建议非常简单：

  - 版本化协议，以便支出客户端和接收服务器可以协商他们支持的协议功能
  - **<!--payjoin-->**将协议重命名为 *payjoin*，因为现在许多人对该名称并不太确定
  - **<!--bip174-->**使用[BIP174][]部分签名的比特币交易（PSBT）在客户端和服务器之间传递交易和签名数据
  - 指定交易应使用一组短列表的最佳实践交易功能，并避免看起来奇怪的货币选择，以便 payjoin 交易与正常交易融为一体，并为区块链分析师创造最大的困惑。

## Bitcoin Stack Exchange 精选问答

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找答案的首要地点之一——或者当我们有一些空闲时间来帮助好奇或困惑的用户时。 在这个月度功能中，我们突出了自上次更新以来得到的一些最受欢迎的问题和答案。 上个月省略了本节以为我们年终特别活动腾出了空间，因此此次更新包括了从 12 月到 1 月的条目。*

- **<!--how-should-an-ln-node-decide-which-channels-to-open-->**[LN 节点应该如何决定开放哪些通道？]({{bse}}83362) LN 协议开发人员和教育者 Rene Pickhardt 描述了一些可以帮助开放生产性通道的标准。 他还链接到一些关于使用 LND 的自动驾驶功能和他自己的 C-Lightning 插件来自动选择通道的有趣讨论。

- **<!--if-i-generate-20-million-bitcoin-addresses-an-hour-how-long-until-i-find-a-collision-->**[如果我每小时生成 2000 万个比特币地址，那么我需要多长时间才能找到一个冲突？]({{bse}}83818)
  一位用户使用具有 32 个核心和 128 GB 内存的计算机生成了惊人数量的地址，想知道他要多久才能创建两个具有不同私钥的相同地址。 Pieter Wuille 的答案及其后续评论描述了所涉及的数学原理，计算了需要多长时间——以宇宙年龄的倍数给出的答案——最后扫碎了提问者打破比特币的希望，指出提问者的方法几乎肯定只会在提问者自己的地址之间找到冲突，而不会影响其他用户。

- **<!--what-s-the-hold-up-implementing-bip156-dandelion-in-bitcoin-core-->**[BIP156 Dandelion 在 Bitcoin Core 中实现的障碍是什么？]({{bse}}81503)
  Dandelion 是一个[提议的方法][BIP156]，用于最初中继新创建的交易，可以使更难确定创建交易的钱包的网络地址。 Bitcoin Core 开发人员 Suhas Daftuar 的答案描述了开发者面临的关键中继协议的挑战，以及为什么即使是概念上简单的想法（例如[Dandelion][BIP151]或[libminisketch][]高效中继）可能也需要更多的工作来安全地实现，而不是其他可能也能改进系统的想法。

- **<!--how-to-use-bip174-psbts-with-a-cold-wallet-and-watching-only-wallet-->**[如何在冷钱包和只读钱包中使用 BIP174 PSBTs？]({{bse}}83070)
  可以在离线计算机上作为冷钱包存储私钥的 Bitcoin Core 的两个副本之一，并在联网计算机上监视钱包余额并广播交易。 但是，你如何使用[BIP174][]部分签名的比特币交易（PSBTs）来使用这两个钱包花费钱？ BIP174 作者 Andrew Chow 解释道。

- **<!--why-relay-transactions-from-node-to-node-why-not-send-them-to-miners-directly-->**[为什么要从节点到节点中继交易——为什么不直接发送给矿工？]({{bse}}83054)
  如果每个人只是将他们的交易直接发送给矿工，然后节点只分发块，那么比特币网络可以使用的带宽将会大大减少。 Pieter Wuille 解释了为什么这对于隐私和网络健康是不利的，以及为什么这甚至不会节省太多带宽。

- **<!--why-should-miners-hashing-arbitrary-nonces-inspire-trust-in-transaction-security-->**[为什么矿工哈希任意的随机数会激发交易安全的信任？]({{bse}}83951)
  当将比特币的工作证明描述为一个简单的猜测游戏时，听起来并不令人信服，但来自 Bitcoin Stack Exchange 的前 30 名专家之一 Chytrik 的答案提供了一个简单的类比，捕捉了工作证明的本质以及它是如何帮助确保比特币交易安全的。

Optech 还祝贺并感谢 Pieter Wuille，他本月成为 [Bitcoin Stack Exchange 的历史最高票贡献者][top bse]。

## 值得注意的代码更改

*本周的重要代码更改包括 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo] 和 [libsecp256k1][libsecp256k1 repo]。*

- [Bitcoin Core #14955][] 将随机数生成器（RNG）从 OpenSSL 切换到 Bitcoin Core 的自己实现，尽管 Bitcoin Core 收集的 RNG 输出被提供给 OpenSSL，然后在程序需要强随机性时读取。 这使得 Bitcoin Core 更接近不再依赖 OpenSSL，因为该依赖在过去曾导致安全问题。 对于担心此更改的安全性的任何人，PR 描述和代码更改都非常好地记录了。

- [Bitcoin Core #14353][] 添加了一个新的 REST 调用 `/rest/blockhashbyheight/`，用于根据其高度（创世块之后的多少个块）获取当前最佳区块链中的块。

- [Bitcoin Core #15193][] 将 `whitelistforcerelay` 配置选项默认关闭。 当启用时，此选项会导致节点中继来自其手动白名单的对等方和客户端的交易，即使这些交易违反节点策略或共识规则。 这可能导致中继节点而不是原始节点或客户端被其对等方禁止，因此最好默认关闭此选项。 开发人员还要求使用此功能的任何人[联系][contact core]他们，以便他们知道这不是一个未使用的应该在将来废弃的选项。

- [LND #2314][] 添加了一个链通知器子服务器，允许服务接收关于最佳区块链更改的通知——例如何时接收到新的块、何时交易被确认，以及输入是否已经花费。

- [LND #2405][] 允许将不同的自动驾驶启发式方法组合成每个可以连接到的节点的单个分数。 分数越高，预期将打开到该节点的通道将增加你的节点的连接性（根据各种特征）。

- [LND #2350][] 为自动驾驶添加了一个 `query` 选项，该选项接受 LN 节点列表，并返回这些节点的分数，指示它们对于向它们打开通道而言有多好。

- [LND #2460][] 在通道更新中添加了对 `max_htlc` 字段的支持。 此功能允许轻量级客户端和修剪节点了解属于远程节点的通道的最大路由容量，而无需在区块链上查找该通道的开放事务——虽然存档完整节点可以做到这一点，但轻量级客户端和修剪节点无法（至少不容易）做到这一点。 现在，LND 节点直接广告这些信息，这不仅有助于轻量级客户端和修剪节点，还允许 LN 节点指定低于其最大值的值，如果他们只想要路由较小的支付。 将来，这还可能有助于支持多路径支付——将支付分成部分，以便总支付金额可以大于使用的最小通道的容量。

- [LND #2370][] 添加了一个新的子系统，每次打开或关闭新通道时都会更新一个 `channel.backup` 文件。 备份此文件的用户可以运行恢复命令，该命令将尝试将每个通道以其最近的已解决状态关闭，之后连接到该通道的远程对等方并启动[BOLT2][]中指定的数据丢失保护协议[^fn-data-loss-protect]。 备份使用您的主 LND 密钥链中的密钥进行加密，该密钥本身应使用您选择的强密码进行加密。

- [C-Lightning #2283][] 在 12 月份默认关闭后，重新启用了[BOLT2][] `option_data_loss_protect` 字段[^fn-data-loss-protect]。 （请参阅[Newsletter #26][]的代码更改部分。）

- [Eclair #784][] 使用具有最低可用余额的通道发送付款。 这将高价值通道中的价值保留给稍后可能出现的更大的付款。 （最终，如果网络采用多路径支付，则需要至少保留一个具有大于要发送的最大付款的余额的通道。）

## 脚注

[^fn-data-loss-protect]:
    [BOLT2][] 的最后一段描述了 `option_data_loss_protect` 选项。基本思想是一个节点可能丢失了部分状态，可以鼓励其对等节点发起通道关闭。由于对等节点仍然拥有最新状态，它应该使用该状态关闭通道，并允许两个节点接收其最新余额。

    这种方法确实存在风险——对等节点可能猜测出某些问题并尝试通过使用旧状态关闭通道来窃取过时节点的资金。但在很大程度上，LN 的惩罚机制减轻了这一风险：如果过时节点在其备份中有旧状态的撤销，它可以创建一个违约补救交易（正义交易），从该通道中没收所有说谎对等节点的资金。由于这一风险，使用 `option_data_loss_protect` 机制的对等节点在听到过时节点时，有动力用最新状态诚实地关闭通道。


{% include references.md %}
{% include linkers/issues.md issues="14955,14353,15193,2314,2405,2350,2460,2370,2283,784" %}
[top bse]: https://bitcoin.stackexchange.com/users?tab=Reputation&filter=all
[payjoin summary]: /zh/newsletters/2018/12/28/#七月
[payjoin post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-January/016625.html
[contact core]: https://bitcoincore.org/en/contact/
[newsletter #26]: /zh/newsletters/2018/12/18/#c-lightning-2155
