---
title: 'Bitcoin Optech Newsletter #31'
permalink: /zh/newsletters/2019/01/29/
name: 2019-01-29-newsletter-zh
slug: 2019-01-29-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了一篇讨论隐私改进提案 payjoin 的帖子，链接到 Bitcoin Stack Exchange 上得票最高的一些问答，并介绍热门比特币基础设施项目在又一个繁忙的一周里值得注意的提交。

## 行动项

本周无。

## 新闻

- **<!--post-about-bip79-p2ep-payjoin-->****关于 BIP79（P2EP/payjoin）的帖子：** Joinmarket 开发者 Adam（waxwing） Gibson 向 Bitcoin-Dev 邮件列表发送了一篇[帖子][payjoin post]，介绍了 [BIP79][] 中所述 Pay-to-EndPoint（P2EP）提案的简化版本。该提案允许链上付款人除自己的输入之外，再加入一个由收款方提供的输入，从而使区块链分析师无法合理地假定所有输入都来自同一人。即使实际使用该功能的人相当少，也可能显著降低区块链分析的可靠性。详情请参阅 [Newsletter #27][payjoin summary]。

  Gibson 的建议主要是依据他在 Joinmarket 开发版中实现类似 P2EP 协议的经验，以及 Samourai Wallet 开发者提供的反馈，对该提案作出修改。后者也实现了该协议的一个变体，目前仍处于开发者测试阶段。目标是让这两个钱包（以及其他许多钱包）都采用同一协议，并让 BTCPay 等支付处理器也支持它。这些建议相当简单：

  - 为协议设定版本号，使付款客户端与收款服务器能够协商双方各自支持的协议特性
  - **<!--payjoin-->**把协议更名为 *payjoin*，因为目前很多人还不太确定该怎么称呼它
  - **<!--bip174-->**用 [BIP174][] 部分签名比特币交易（PSBT）在客户端与服务器之间传递交易和签名数据
  - 规定交易应采用一组简短的最佳实践交易特性，并避免看起来奇怪的选币方式，好让 payjoin 交易与普通交易混在一起，给区块链分析师制造最大程度的混淆

## Bitcoin Stack Exchange 精选问答

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一——也是我们抽出一点空闲时间帮助好奇或困惑用户的地方。在这个月度栏目中，我们精选自上次更新以来得票最高的一些问答。上个月为给年终特刊腾出空间，本节暂停了一期，因此本次更新同时收录 12 月和 1 月的条目。*

- **<!--how-should-an-ln-node-decide-which-channels-to-open-->**[LN 节点应该如何决定开通哪些通道？]({{bse}}83362) LN 协议开发者兼教育者 Rene Pickhardt 介绍了一些可用于帮助开通高产出通道的标准。他还链接到一些有趣讨论，内容涉及用 LND 的自动巡航功能和自研的 C-Lightning 插件来自动选择通道。

- **<!--if-i-generate-20-million-bitcoin-addresses-an-hour-how-long-until-i-find-a-collision-->**[如果我每小时生成 2000 万个比特币地址，需要多久才能找到一个碰撞？]({{bse}}83818)
  一位用户用一台 32 核、128 GB 内存的计算机生成了数量惊人的地址，他想知道要多久才会创建出两个私钥不同却完全相同的地址。Pieter Wuille 的回答及后续评论介绍了其中涉及的数学原理，算出了所需时间——答案以宇宙年龄的倍数给出——最后打消了提问者攻破比特币的希望：他指出，提问者的方法几乎肯定只会在提问者自己的地址之间找到碰撞，其他用户不受影响。

- **<!--what-s-the-hold-up-implementing-bip156-dandelion-in-bitcoin-core-->**[BIP156 Dandelion 在 Bitcoin Core 中为何迟迟未能实现？]({{bse}}81503)
  Dandelion 是一种[提议的方法][BIP156]，用于在新交易创建之初进行中继，使他人更难确定创建该交易的钱包的网络地址。Bitcoin Core 开发者 Suhas Daftuar 的回答介绍了开发关键中继协议时会遇到的一些挑战，并解释了为什么像 Dandelion 这样概念上很简单的想法，在安全实现上可能反而比其他同样能改进系统的想法（例如 [BIP151][] 加密或 [libminisketch][] 高效中继）需要更多工作。

- **<!--how-to-use-bip174-psbts-with-a-cold-wallet-and-watching-only-wallet-->**[如何在冷钱包和只读钱包中使用 BIP174 PSBT？]({{bse}}83070)
  设置两份 Bitcoin Core 副本很容易：一份放在离线计算机上作为冷钱包保存私钥，另一份放在联网计算机上监视钱包余额并广播交易。但实际要怎样用 [BIP174][] 部分签名比特币交易（PSBT）通过这两个钱包花钱呢？BIP174 作者 Andrew Chow 作了解释。

- **<!--why-relay-transactions-from-node-to-node-why-not-send-them-to-miners-directly-->**[为什么要从节点到节点中继交易——为什么不直接发送给矿工？]({{bse}}83054)
  如果每个人都把交易直接发给矿工，节点只负责分发区块，比特币网络似乎能省下大量带宽。Pieter Wuille 解释了为什么这对隐私和网络健康都不利，以及为什么这样做其实也省不了多少带宽。

- **<!--why-should-miners-hashing-arbitrary-nonces-inspire-trust-in-transaction-security-->**[为什么矿工对任意随机数做哈希，能让人信任交易的安全性？]({{bse}}83951)
  如果把比特币的工作量证明描述成一场简单的猜数游戏，听起来并不怎么有说服力。但 Bitcoin Stack Exchange 排名前 30 的专家之一 Chytrik 的回答提供了一个简单的类比，抓住了工作量证明的本质，也说明了它如何帮助保障比特币交易的安全。

Optech 还祝贺并感谢 Pieter Wuille，他本月成为 [Bitcoin Stack Exchange 史上得票最高的贡献者][top bse]。

## 值得注意的代码变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo] 和 [libsecp256k1][libsecp256k1 repo] 中值得注意的代码变更。*

- [Bitcoin Core #14955][] 把所用的随机数生成器（RNG）从 OpenSSL 换成 Bitcoin Core 自己的实现，不过 Bitcoin Core 采集的 RNG 输出仍会传给 OpenSSL，程序需要强随机性时再从 OpenSSL 读回。这使 Bitcoin Core 朝着不再依赖 OpenSSL 又靠近了一步，因为该依赖过去曾引发安全问题。对于担心此变更安全性的任何人，PR 描述和代码变更都作了非常详尽的说明。

- [Bitcoin Core #14353][] 添加了一个新的 REST 调用 `/rest/blockhashbyheight/`，用于按高度（即创世区块之后有多少个区块）从当前最佳区块链中获取区块。

- [Bitcoin Core #15193][] 将 `whitelistforcerelay` 配置选项默认设为关闭。启用该选项后，节点会中继来自其手动加入白名单的对等方和客户端的交易，即使这些交易违反节点策略或共识规则。这可能使中继节点自身、而非发起节点或客户端被其对等方封禁，因此最好默认关闭。开发者还希望使用此功能的人[联系][contact core]他们，以便确认这并非一个无人使用、将来应当弃用的选项。

- [LND #2314][] 添加了一个链通知子服务器，使服务能够收到最佳区块链发生变化时的通知——例如收到新区块、交易得到确认，以及某个输入是否已被花费。

- [LND #2405][] 允许把多种不同的自动巡航启发式方法合并成每个候选节点的一个总分。分数越高，就意味着向该节点开通通道后，你的节点连通性越有可能得到提升（具体取决于各项特征）。

- [LND #2350][] 为自动巡航添加了一个 `query` 选项，它接受一份 LN 节点列表，并返回这些节点的分数，表示它们有多适合作为开通通道的对象。

- [LND #2460][] 在通道更新中添加了对 `max_htlc` 字段的支持。该特性让轻客户端和修剪节点无需在区块链上查找某通道的开通交易，就能得知属于远端节点的通道的最大路由容量——归档全节点可以做到这一点，轻客户端和修剪节点却做不到（至少不容易做到）。现在 LND 节点会直接公布这一信息，这不仅方便了轻客户端和修剪节点，还允许 LN 节点在只想路由较小额支付时，把该值设为低于其上限。将来，这还可帮助支持多路径支付——把一笔支付拆成若干部分，使支付总额可以超过所用到的最小通道的容量。

- [LND #2370][] 添加了一个新的子系统，每当有新通道被打开或关闭时都会更新 `channel.backup` 文件。备份过该文件的用户可以运行一条恢复命令：它会先连接各通道的远端对等方并启动 [BOLT2][] 中规定的数据丢失保护协议，然后尝试按每个通道最近一次已结算的状态将其关闭[^fn-data-loss-protect]。备份会使用 LND 主密钥链中的密钥加密，而该密钥本身应使用你自己选定的强口令加密。

- [C-Lightning #2283][] 重新启用了 [BOLT2][] 的 `option_data_loss_protect` 字段[^fn-data-loss-protect]。该字段在 12 月曾被默认禁用（参见 [Newsletter #26][] 的代码变更部分）。

- [Eclair #784][] 用可用余额最低、但仍足以支持该笔支付的通道来发送支付。这样可把高余额通道中的资金留给以后可能出现的大额支付。（最终，如果网络采用多路径支付，就无需再保留至少一条余额大于你要发送的最大单笔支付的通道了。）

## 脚注

[^fn-data-loss-protect]:
    [BOLT2][] 的最后一段描述了 `option_data_loss_protect` 选项。其基本思路是：某个节点可能已经丢失了部分状态，它可以促使对等方发起通道关闭。由于对等方仍掌握最新状态，它应当用该状态关闭通道，让两个节点都能取回各自最新的余额。

    这种方法确实有风险——对等方可能猜到出了问题，并试图用旧状态关闭通道，从而窃取过时节点的资金。但 LN 的惩罚机制在很大程度上减轻了这一风险：如果过时节点的备份中确实存有该旧状态的撤销信息，它就能创建一笔违约补救交易（正义交易），从该通道中没收说谎对等方的全部资金。正因如此，使用 `option_data_loss_protect` 机制的对等方在收到过时节点的消息时，有动力用最新状态诚实地关闭通道。


{% include references.md %}
{% include linkers/issues.md issues="14955,14353,15193,2314,2405,2350,2460,2370,2283,784" %}
[top bse]: https://bitcoin.stackexchange.com/users?tab=Reputation&filter=all
[payjoin summary]: /zh/newsletters/2018/12/28/#七月
[payjoin post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-January/016625.html
[contact core]: https://bitcoincore.org/en/contact/
[newsletter #26]: /zh/newsletters/2018/12/18/#c-lightning-2155
