---
title: "Bitcoin Optech Newsletter #22"
permalink: /zh/newsletters/2018/11/20/
name: 2018-11-20-newsletter-zh
slug: 2018-11-20-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 “wumbo-sized” Newsletter 提供了关于比特币哈希率与其他币种分叉相关的说明，总结了几个已接受的闪电网络协议 1.1 版本规范的目标，并列出了几个值得注意的比特币基础设施项目中的提交。

## 行动项

- **<!--monitor-feerates-->****监控手续费率：** 由于与比特币现金相关的活动，可以使用与比特币相同的矿机，比特币区块的出现频率可能会低于预期，从而提高手续费率并导致其他影响。然而，这些情况可能会突然逆转，提供一个快速出块和低手续费的时期。请参阅下方的新闻部分，了解比特币业务的更多信息和推荐操作。

## 特性新闻：闪电网络协议 1.1 目标

LN 协议开发人员上周末在阿德莱德[会面][rusty wrapup]，确定了将要采用的闪电网络协议规范 1.1 的变化。共有 30 项提案在高层次上被接受——这意味着每个提案的完整规范尚未完全定义或达成一致——但新的功能的[基本纲要][ln1.1 outline]已可用。会议的一些亮点包括：

- **<!--multi-path-payments-->****多路径支付：** 当前通过 LN 进行支付的常规方式是使用单一路径。Alice 通过她与 Bob 的通道以及 Bob 与 Charlie 的通道支付给 Charlie。这种方式对于每个参与者都有足够容量的小额支付效果很好。但是，如果 Alice 有 10 个开放通道，每个通道包含她总热钱包余额的最多 10%，那么 Alice 一次只能花费最多 10% 的资金。

  多路径支付提供了这个问题的解决方案：如果 Alice 想发送 15% 的资金，她可以通过与 Bob 的通道发送 7.5% 给 Charlie，并通过与 Dan（也有与 Charlie 的通道）的通道发送 7.5%。虽然部分支付是通过不同的路径路由的，但它们可以各自承诺使用 Alice 发送单路径支付所使用的相同哈希。如果 Charlie 在合理时间内收到多个支付，且总额达到或超过预期金额，他可以通过揭示所有哈希使用的单个预映像来保证收到所有支付。这重用了当前用于单路径支付的相同的已证明安全机制，因此不会引入任何新的安全假设。如果路径中的某个其他方具有足够的通道容量，将部分支付合并并沿着路径的其余部分转发单个支付，同样的机制也适用。

  有关更多信息，请参阅以下的 Lightning-Dev 线程，这些线程通常称这个功能为原子多路径支付（AMP）：[一个带有单独哈希/预映像的早期提案][roasbeef amp]、[类似当前受欢迎的提案][zmn base amp]、[一个可能过于乐观的提案][pickhardt local amp]。

- **<!--dual-funded-channels-->****双向资金通道：** 当前实现的一个不错的功能是，只有通道的一方需要最初承诺任何资金。例如，Alice 使用她的钱打开与 Bob 的 0.1 BTC 通道，Bob 没有任何资金。这使得用户很容易接受新的传入通道，但这也意味着通道最初只能单向使用——Alice 可以支付给 Bob 或通过 Bob 路由支付，但 Alice 无法从 Bob 或包含 Bob 的任何路由路径接收支付，直到 Alice 向 Bob 发送了一些钱。这创造了一个引导问题：如果 Alice 想通过 LN 接收支付，她必须让人们向她的节点打开新通道——这需要他们支付链上交易费并等待可能需要数小时的链上确认。

  这个问题的一个解决方案是允许双向资金通道。Alice 同意将 0.1 BTC 放入与 Bob 的通道，如果 Bob 同意用他自己的 0.1 BTC 开通通道。这可能会花费 Bob 一些钱——即链上交易费和一段时间内资金的机会成本——但 Bob 也有机会通过任何发送给 Alice 的支付赚取 LN 路由费用。

  双向资金的基本实现可能很简单（LN 节点已经处理双向支付），但创建一个可以奖励像 Bob 这样的资本提供者的激励机制仍在讨论中。有关更多信息，请参阅以下线程：[1][neigut liquidity]、[2][zmn liquidity]、[3][zmn dual rbf]。另请参阅 [Newsletter #21][] 中*广告节点流动性*部分。

- **<!--splicing-->****拼接：** 目前无法增加通道的最大余额或将一些通道资金链上发送给另一个人而不关闭整个通道并在相同方之间开设另一个通道。关闭一个通道并开设另一个通道需要完全停止双方之间的所有支付，直到关闭和重新开通交易的适当数量的链上确认收到为止。

  拼接提供了一个解决方案，双方合作创建一个链上交易来添加或减少通道中的资金。当添加资金（拼接进来）时，通道中先前的资金可以在新的资金确认时继续链下使用而不中断。当链上花费资金（拼接出去）时，剩余的资金也可以在链下继续使用而不中断，而链上收款人看到的与正常交易没有区别。这允许钱包用户界面将通道内资金作为可用于链上交易支出的总余额的一部分，使用户无需手动管理链下和链上余额。<span id="multipath-splicing-ux">结合多路径支付，允许来自多个通道的资金在支付中混合，这极大地简化了支出：用户只需点击链接，查看发票，然后点击*支付*——让钱包自动使用其可用余额进行链上支付或使用任意数量路径的链下支付。</span>

  有关更多信息，请参阅以下线程：[1][zmn splicing cut-through]、[2][pickhardt bolt splicing]、[3][russell splicing]。另请参阅 [Newsletter #17][] 中关于*通道拼接*的新闻项目。

- **<!--wumbo-->****Wumbo：** 通过早期 LN 实现的协议，目前每个通道的容量默认限制约为 0.168 BTC（定义时约 40 美元；目前约 750 美元）。[这是为了][russell why limit]帮助防止用户将太多资金投入未经过验证的软件。

  几年后，LN 已经显著成熟，一些参与者希望表明他们愿意打开更高价值的通道。1.1 规范提案将允许这些参与者设置一个名为“wumbo”（巨型）的位，以表示他们愿意接受更大的通道和更大的通道内支付。

  有关更多信息，请参阅以下线程：[1][zmn describing wumbo]、[2][zmn global wumbo]。语言学参考，名称 wumbo 来自《海绵宝宝》卡通中的[一段][youtube wumbo]，其中“M”被解释为代表迷你，翻转为“W”，并重新定义为代表 wumbo。

- **<!--hidden-destinations-->****隐藏目的地：** LN 支付当前使用类似于将数据发送到 Tor 退出节点的洋葱方法路由支付。Alice 最终想支付给 Zed，所以她通过 Bob、Charlene 和 Dan 找到了一条路径。为了防止中介了解路径上的其他内容（例如 Charlene 只知道 Bob 和 Dan），Alice 对路径的每一步进行加密，以便每个接收者只能看到下一步。当 Zed 最终收到支付时，他可以简单地将成功的预映像返回给 Dan，Dan 再返回给 Charlene，依此类推回到 Alice。

  然而，Tor 还有一种隐藏服务模式，其中发送者和接收者各自选择路径的一部分，使他们都无法确定数据包的确切来源或去向——提供显著改善的隐私。这项 LN 提案镜像了这种模式。Alice 仍然会选择 Bob、Charlene 和 Dan，但 Zed 可以通过选择 Edmond、Fran 和 George 来防止 Alice 了解他的路由。Zed 向 Alice 提供关于如何找到 Edmond 的信息——但关于 Fran、George 和 Zed 自己节点的信息是加密的，因此 Alice 无法看到。这可以让隐藏通道——当前多个 LN 实现的功能——即使在路由任意支付时也保持隐藏。

  这个功能也称为会合路由。有关更多信息，请参阅 LN 协议文档 Wiki 上的[描述][lnrfc rz]。另请参阅以下邮件列表线程：[1][cjp rz]、[2][zmn rz]、[3][zmn rz packetswitch]。

尽管在峰会上进行了讨论，提议的 1.1 目标并未直接涉及帮助保护当前离线用户通道的*哨兵*、帮助用户打开初始支付通道的*自动驾驶仪*或允许私钥保持离线而在线组件仅完成支付接受的*确定性预映像生成*。这些是可以建立在协议之上的服务，因此目前不需要实施之间的协调。

## 新闻

{% comment %}<!-- 45 分钟区块的数学计算：
exp(-45/9) # 45 分钟区块，9 分钟平均间隔
exp(-45/12) # 45 分钟区块，12 分钟平均间隔

独立事件的方差是平均值的平方，因此长时间区块变得更常见的速率比平均区块时间的增加快。

-->{% endcomment %}

- **<!--slowed-block-production-increased-fees-->****减缓的区块生产、增加的手续费：** 如广泛报道所述，一些矿工和矿池正在为比特币现金的竞争分叉生产区块，而他们可能通过为比特币创建区块赚取更多收入。这可能是导致比特币难度在 UTC 时间周五结束的重定目标期间大约减少 7% 的原因，并且可能意味着比特币哈希率和难度在未知时间内的额外下降。对比特币业务的相关影响包括：

  - **<!--slower-confirmation-times-->***更慢的确认时间：* 块与块之间的平均时间可能适度增加到 11 或 12 分钟，长时间等待区块的可能性在相对百分比上显著增加（例如，历史上典型的 9 分钟平均区块间隔，约 0.7% 的区块超过 45 分钟；12 分钟间隔为 2.3% 超过 45 分钟）。建议：比特币用户已经熟悉偶尔的长时间延迟，因此可能不需要采取任何行动。

  - **<!--possibly-increased-fees-->***可能增加的手续费：* 找到区块的时间越长，交易空间越少，这可能导致手续费增加。偶尔的长时间等待区块也倾向于创建突然的手续费尖峰，这可能持续数小时。建议：确保你的手续费估算正常工作，并考虑准备任何你愿意使用的手续费减少措施，例如支付批处理。

  - **<!--increased-revenues-for-profit-maximizing-miners-->***利润最大化矿工的收入增加：* 矿工不仅从增加的手续费中获利，每次比特币的难度下调时，比特币矿工的挖矿变得更有利可图（其他条件不变）。建议：计算重新激活稍旧矿机和超频当前矿机的收益。随着最近价格的下跌，这可能意味着你不需要关闭本来会变得不盈利的矿机。

  - **<!--possible-sudden-end-->***可能的突然结束：* 可能有一大批生产比特币现金区块的意识形态矿工会同时回到挖掘最有利可图的链。结合任何过去的难度下降，这可能会产生一系列比特币区块，区块间的平均时间比正常情况更短。这可能会清除任何中等积压，并使手续费下降到最低。建议：考虑准备在手续费降到最低时执行手续费减少的[输入整合][input consolidations]。

- **<!--lightning-protocol-discussion-->****闪电协议讨论：** 过去一周有超过 75 封电子邮件发布到 Lightning-Dev 邮件列表，占过去 365 天列表流量的近 10%。许多线程继续在协议开发者峰会上开始的对话。如果你对闪电协议开发感兴趣，建议阅读本月的每个[线程][ln threads]。

- **<!--lnd-enters-release-cycle-for-version-0-5-1-->****LND 进入 0.5.1 版本的发布周期：** LND 实现的经验丰富的用户可能希望测试此预发布版本，以帮助在最终发布此维护更新前发现任何最后时刻的问题。

## Optech 新闻

- **<!--second-optech-workshop-held-in-paris-->****第二次 Optech 研讨会在巴黎举行：** 如 [Newsletter #12][] 中所宣布，我们上周在巴黎举行了第二次研讨会。来自比特币公司和开源项目的 24 名工程师参加了会议，我们就钱包描述符、部分签名比特币交易（PSBTs）、闪电集成、taproot、硬币选择和手续费提高进行了精彩的讨论。非常感谢 Ledger 的主办和协助组织。

  如果你在会员公司工作并对未来的 Optech 活动有任何请求或建议（如地点、场地、日期、形式、主题或其他任何内容），请[联系我们][optech email]。我们在这里帮助我们的会员公司！

## 值得注意的代码更改

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-lightning][core lightning repo] 和 [libsecp256k1][libsecp256k1 repo] 中值得注意的代码更改。*

- [C-Lightning #2075][] 增加了对插件的支持。正如其[文档][cl plugin]所描述，“插件是扩展 c-lightning 提供的功能的简单而强大的方式。它们是由主要的 `lightningd` 守护进程启动的子进程，可以以各种方式与 `lightningd` 交互。”目前，插件可以向主进程添加命令行选项，但计划允许它们添加新的 JSON-RPC 命令、接收事件和插入由主进程调用的钩子代码。作为示例，C-Lightning 提供了一个用 Python 编写的 `helloworld` 插件。

- [Bitcoin Core #14411][] [listtransactions][rpc listtransactions] RPC 部分恢复了其过滤参数，使得可以检索发送到具有特定标签的地址或脚本的交易列表。此更改已回溯到 0.17 分支，预计将在下一个维护版本中发布。

- [LND #2124][] 增加了哨兵支持的另一重要部分，特别是检测攻击者已在线尝试从哨兵用户之一窃取的能力。哨兵可以使用来自链上交易的信息解密受害者先前提供的违约补救交易，以同时否定攻击并通过认领攻击者在通道中合法拥有的任何资金来惩罚攻击者。在当前实现中，哨兵通过收到恢复资金的一部分来补偿其勤勉的监控。这次合并是 PRs [#1535][LND #1535] 和 [#1512][LND #1512] 的扩展，这些 PRs 在 [Newsletter #19][] 中进行了描述，是使 LN 更安全的重要一步。

## 特别感谢

我们感谢 Christian Decker、practicalswift 和 René Pickhardt 提供的建议或回答与本新闻相关的问题。所有剩余错误完全是新闻作者的责任。


{% include references.md %}
{% include linkers/issues.md issues="2075,14411,2124,1535,1512,14441" %}

[ln threads]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/thread.html
[roasbeef amp]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-February/000993.html
[zmn base amp]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001577.html
[pickhardt local amp]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001626.html
[neigut liquidity]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001532.html
[zmn liquidity]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001555.html
[zmn dual rbf]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001631.html
[zmn splicing cut-through]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-April/001153.html
[pickhardt bolt splicing]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-June/001322.html
[russell splicing]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-October/001434.html
[russell why limit]: https://medium.com/@rusty_lightning/bitcoin-lightning-faq-why-the-0-042-bitcoin-limit-2eb48b703f3
[youtube wumbo]: https://www.youtube.com/watch?v=--hsVknT1c0
[zmn describing wumbo]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001596.html
[zmn global wumbo]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001576.html
[cjp rz]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001498.html
[zmn rz]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001547.html
[zmn rz packetswitch]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001553.html
[cl plugin]: https://github.com/ElementsProject/lightning/blob/master/doc/PLUGINS.md
[rusty wrapup]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001569.html
[ln1.1 outline]: https://github.com/lightningnetwork/lightning-rfc/wiki/Lightning-Specification-1.1-Proposal-States
[input consolidations]: https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#Consolidation
[lnrfc rz]: https://github.com/lightningnetwork/lightning-rfc/wiki/Rendez-vous-mechanism-on-top-of-Sphinx
[newsletter #21]: /zh/newsletters/2018/11/13/#advertising-node-liquidity
[newsletter #17]: /zh/newsletters/2018/10/16/#proposal-for-lightning-network-payment-channel-splicing
[newsletter #12]: /zh/newsletters/2018/09/11/#workshop
[newsletter #19]: /zh/newsletters/2018/10/30/#lnd-1535-1512