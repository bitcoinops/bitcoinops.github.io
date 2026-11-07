---
title: "Bitcoin Optech Newsletter #22"
permalink: /zh/newsletters/2018/11/20/
name: 2018-11-20-newsletter-zh
slug: 2018-11-20-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周这份“超大号（wumbo-sized）”的 Newsletter 说明了比特币哈希率与其他币种分叉之间的关联，总结了闪电网络协议规范 1.1 版（Lightning Network protocol 1.1）若干已获接受的目标，并列出热门比特币基础设施项目中若干值得注意的提交。

## 行动项

- **<!--monitor-feerates-->****监控费率（feerate）：** 由于与比特币现金（Bitcoin Cash）相关的活动——比特币现金可以使用与比特币相同的矿机——比特币的出块可能比预期更稀疏，从而推高费率并造成其他影响。不过，这些情况也可能突然反转，带来一段快速出块、低费率的时期。请参阅下方的新闻部分，了解面向比特币企业的更多信息与建议措施。

## 特性新闻：闪电网络协议 1.1 目标

LN 协议开发人员上周末在阿德莱德[会面][rusty wrapup]，确定了即将发布的闪电网络协议规范 1.1 将采用哪些变更。共有 30 项提案在总体方向上获得接受——这意味着每个提案的完整规范未必已经定义或达成一致——但新功能的[基本纲要][ln1.1 outline]已经公布。会议的部分亮点包括：

- **<!--multi-path-payments-->****多路径支付：** 目前通过 LN 支付，常规做法是走单一路径。Alice 经由她与 Bob 的通道、以及 Bob 与 Charlie 的通道付给 Charlie。只要每个参与者的容量足以支持这笔支付，这种方式对小额支付就很有效。但如果 Alice 有 10 个开放通道，每个通道最多只占她热钱包总余额的 10%，那么采用这种机制时，Alice 一次最多只能花掉 10% 的资金。

  多路径支付可以解决这个问题：如果 Alice 想发送 15% 的资金，她可以经由与 Bob 的通道发送 7.5% 给 Charlie，再经由与 Dan 的通道发送 7.5%（Dan 也有一条通往 Charlie 的通道）。虽然这些部分支付走的是不同路径，但它们可以各自锁定同一个哈希——也就是 Alice 若走单路径支付会使用的那个哈希。如果 Charlie 在一段合理时间内收到多笔支付，且总额达到或超过预期金额，他只要揭示所有哈希共用的同一个原像，就能确保收到全部款项。这沿用了当前单路径支付已经在用、且经过验证的安全机制，因此不引入任何新的安全假设。如果路径中某个拥有足够通道容量的其他参与方先把这些部分支付汇聚起来，再沿剩余路径向 Charlie 转发成一笔支付，这套机制同样成立。

  有关更多信息，请参阅以下 Lightning-Dev 邮件列表讨论帖，它们通常把这个功能称为原子多路径支付（Atomic Multi-path Payments，AMP）：[一个使用独立哈希/原像的早期提案][roasbeef amp]、[类似当前较受青睐方案的提案][zmn base amp]、[一个可能过于乐观的提案][pickhardt local amp]。

- **<!--dual-funded-channels-->****双向资助通道（dual funding）：** 当前实现有一个很好的特性：只需通道中的一方在初始时投入资金。例如，Alice 用她的 0.1 BTC 开通与 Bob 的通道，Bob 一分钱也不出。这让用户可以很轻松地接受新的入站通道，但也意味着通道在初始阶段只能单向使用——Alice 可以付给 Bob，也可以经由 Bob 路由支付，但除非 Alice 已经给 Bob 转过钱，否则她无法从 Bob 或任何包含 Bob 的路由路径收款。这就造成一个冷启动问题：Alice 若想通过 LN 收款，就必须让别人向她的节点开新通道——对方需要支付链上交易手续费，还要等待可能长达数小时的链上确认。

  针对这个问题，一个被提出的解决方案是允许双向资助通道。Alice 同意把 0.1 BTC 放入与 Bob 的通道，前提是 Bob 也同意拿出自己的 0.1 BTC 来开通这条通道。这可能需要 Bob 付出代价——即链上交易手续费，以及资金在一段时间内被占用的机会成本——但 Bob 也能获得机会，从任何发给 Alice 的支付中赚取 LN 路由手续费。

  双向资助的基本实现大概很简单（LN 节点本来就能处理双向支付），但如何设计一种能回报 Bob 这类资金提供者的激励机制，仍在讨论中。有关更多信息，请参阅以下讨论帖：[1][neigut liquidity]、[2][zmn liquidity]、[3][zmn dual rbf]。另请参阅 [Newsletter #21][] 中*公开宣传节点流动性*一节。

- **<!--splicing-->****拼接（splicing）：** 目前，若想提高通道的最大余额，或把通道中的部分资金发到链上给别人，都必须关闭整个通道，再在同一对参与方之间开一条新通道。而关闭一条通道再开另一条，意味着双方之间的所有支付要完全停止，直到关闭并重开的那笔交易获得足够数量的链上确认为止。

  拼接给出的办法是：双方合作创建一笔链上交易，向通道增加资金或从通道扣除资金。增加资金（拼接进来，splicing in）时，通道原有的资金可以在新资金等待确认期间继续用于链下支付，不会中断。把资金花到链上（拼接出去，splicing out）时，剩余资金同样可以继续用于链下支付而不中断，链上收款方看到的与一笔普通交易没有任何区别。这样，钱包界面就可以把通道内资金算作链上交易可用的总余额的一部分，用户不必再分别手动管理链下余额和链上余额。<span id="multipath-splicing-ux">再结合允许多个通道的资金在支付中混合使用的多路径支付，花钱这件事就被极大地简化了：用户只需点击一个链接、核对发票、点击*支付*——钱包会自动动用其可用余额，用于链上支付，或用任意数量的路径完成链下支付。</span>

  有关更多信息，请参阅以下讨论帖：[1][zmn splicing cut-through]、[2][pickhardt bolt splicing]、[3][russell splicing]。另请参阅 [Newsletter #17][] 中关于*通道拼接*的新闻条目。

- **<!--wumbo-->****Wumbo：** 经早期 LN 实现方约定，目前每个通道的容量默认上限约为 0.168 BTC（定义时约合 40 美元；目前约合 750 美元）。[这样限制][russell why limit]是为了防止用户把过多资金投入尚未经过检验的软件。

  几年过去，LN 已显著成熟，一些参与者希望表明自己愿意开更高价值的通道。1.1 规范提案将允许这类参与者设置一个名为“wumbo”（巨型）的位，以表示他们愿意接受更大的通道和更大的通道内支付。

  有关更多信息，请参阅以下讨论帖：[1][zmn describing wumbo]、[2][zmn global wumbo]。从词源上看，wumbo 这个名字似乎来自《海绵宝宝》动画中的[一段情节][youtube wumbo]：“M”被解释为 Mini（迷你）的缩写，倒过来变成“W”，再重新定义为 wumbo。

- **<!--hidden-destinations-->****隐藏目的地：** 目前 LN 支付采用类似向 Tor 出口节点发送数据的洋葱方法进行路由。Alice 最终想付给 Zed，于是她找到一条经由 Bob、Charlene 和 Dan 通往 Zed 的路径。为了让中间节点除了自己转接的那两条通道之外什么都学不到（例如 Charlene 只知道 Bob 和 Dan），Alice 对路径的每一段都加密，使每个接收方只能看到下一段。当 Zed 最终收到支付时，他只需把表示成功的原像返回给 Dan，Dan 再返回给 Charlene，如此一路回到 Alice。

  不过，Tor 还有一种隐藏服务模式：发送方和接收方各自选择路径的一部分，使双方都无法确定数据包究竟从哪里来、到哪里去，隐私因此显著改善。这套 LN 提案就沿用了这种模式。Alice 仍然会选择 Bob、Charlene 和 Dan，但 Zed 可以通过选择 Edmond、Fran 和 George，让 Alice 无法得知他那一段路由。Zed 会把如何找到 Edmond 的信息告诉 Alice——但关于 Fran、George 以及 Zed 自己节点的信息都是加密的，Alice 看不到。这样，隐藏通道（目前多个 LN 实现已支持的功能）即使在为任意付款人路由支付时也能保持隐藏。

  这个功能也叫会合路由（rendez-vous routing）。有关更多信息，请参阅 LN 协议文档 Wiki 上的[描述][lnrfc rz]。另请参阅以下邮件列表讨论帖：[1][cjp rz]、[2][zmn rz]、[3][zmn rz packetswitch]。

尽管峰会上也讨论过，但这份 1.1 目标提案并未直接涉及以下几类服务：为当前离线用户保护通道的*瞭望塔（watchtower）*、帮助用户开通首批支付通道的*自动巡航（autopilot）*，以及让私钥保持离线、由在线组件代为完成收款确认的*确定性原像生成*。这些服务都可以构建在协议之上，因此目前并不需要各实现之间进行协调。

## 新闻

{% comment %}<!-- 45 分钟区块的数学计算：
exp(-45/9) # 45 分钟区块，9 分钟平均间隔
exp(-45/12) # 45 分钟区块，12 分钟平均间隔

独立事件的方差是平均值的平方，因此长时间区块变得更常见的速率比平均区块时间的增加快。

-->{% endcomment %}

- **<!--slowed-block-production-increased-fees-->****出块放缓、手续费上升：** 如广泛报道的那样，一些矿工和矿池正在为比特币现金的几个相互竞争的分叉出块，而他们本可以为比特币出块、赚取更高的收入。这很可能就是比特币难度在截至周五（UTC）的那个难度调整周期内下降约 7% 的原因，并且可能意味着比特币哈希率和难度还会继续下降，持续时间未知。对比特币企业而言，相关影响包括：

  - **<!--slower-confirmation-times-->***确认变慢：* 出块间隔的平均值可能略微上升到 11 或 12 分钟，而出现长时间等不到区块的概率，其相对百分比会显著上升（例如，历史上平均出块间隔典型为 9 分钟时，约 0.7% 的区块要等 45 分钟以上；若间隔为 12 分钟，这一比例则是 2.3%）。建议：比特币用户早已习惯偶尔的长延迟，因此多半无需采取行动。

  - **<!--possibly-increased-fees-->***手续费可能上升：* 找到区块的时间变长，意味着单位时间内可容纳的交易更少，这可能导致手续费上涨。偶尔的长时间等块也容易造成手续费突然飙升，并在之后持续数小时。建议：确认你的手续费估算工作正常，并考虑准备好你愿意采用的手续费削减措施，例如支付批处理（payment batching）。

  - **<!--increased-revenues-for-profit-maximizing-miners-->***追求利润最大化的矿工收入增加：* 矿工不仅从上涨的手续费中获利；每当比特币难度向下调整，比特币挖矿也会变得更有利可图（其他条件不变）。建议：算一算重新启用稍旧的矿机、以及给现有矿机超频的账。考虑到最近的价格下跌，这反而可能意味着，你本来要关掉的那台不赚钱的矿机现在不必关了。

  - **<!--possible-sudden-end-->***可能突然结束：* 有可能出现的情况是，一大批出于理念为比特币现金出块的矿工，几乎同时全部转回挖最有利可图的那条链。叠加此前的难度下降，这可能带来一连串出块间隔短于正常水平的比特币区块。这很可能清空此前中等规模的积压，让手续费回落到默认的最低值。建议：可以考虑做好准备，一旦手续费降到最低，就执行能降低手续费的[输入整合][input consolidations]。

- **<!--lightning-protocol-discussion-->****闪电协议讨论：** 过去一周，Lightning-Dev 邮件列表收到超过 75 封邮件，几乎相当于该列表过去 365 天总流量的 10%。许多讨论帖都在延续协议开发者峰会上的讨论。如果你对闪电协议开发感兴趣，建议阅读本月[各个讨论帖][ln threads]。

- **<!--lnd-enters-release-cycle-for-version-0-5-1-->****LND 进入 0.5.1 版本的发布周期：** 经验丰富的 LND 实现用户或许愿意测试这个预发布版本，以便在这次维护更新的最终版本发布前，帮忙找出任何最后一刻才暴露的问题。

## Optech 新闻

- **<!--second-optech-workshop-held-in-paris-->****第二届 Optech 工作坊在巴黎举行：** 正如 [Newsletter #12][] 所预告的，我们上周在巴黎举办了第二届工作坊。来自比特币公司和开源项目的 24 名工程师到场参加，我们就钱包描述符、部分签名比特币交易（PSBT）、闪电网络集成、taproot、选币（coin selection）和手续费追加（fee bumping）展开了热烈讨论。非常感谢 Ledger 提供场地并协助组织。

  如果你在会员公司工作，并对未来的 Optech 活动有任何请求或建议（例如地点、场地、日期、形式、主题，或其他任何方面），请[联系我们][optech email]。我们随时为会员公司服务！

## 值得注意的代码变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-lightning][core lightning repo] 和 [libsecp256k1][libsecp256k1 repo] 中值得注意的代码变更。*

- [C-Lightning #2075][] 增加了对插件的支持。正如其[文档][cl plugin]所描述的：“插件是一种简单而强大的方式，可以扩展 c-lightning 提供的功能。插件是由 `lightningd` 主守护进程启动的子进程，能以多种方式与 `lightningd` 交互。”目前，插件可以为主进程添加命令行选项，但计划允许它们添加新的 JSON-RPC 命令、接收事件，以及插入由主进程中钩子调用的代码。C-Lightning 附带了一个用 Python 编写的 `helloworld` 插件作为示例。

- [Bitcoin Core #14411][] [listtransactions][rpc listtransactions] RPC 部分恢复了过滤参数，使得可以检索发送给带有特定标签的地址或脚本的交易列表。该改动已以 [PR #14441][Bitcoin Core #14441] 的形式向后移植到 0.17 分支，预计将在下一个维护版本中发布。

- [LND #2124][] 增加了瞭望塔支持的另一关键部分，具体来说，是能够检测出攻击者已在链上试图从瞭望塔的某个用户那里盗取资金。瞭望塔可以利用这笔链上交易中的信息，解密受害者此前提供的违约补救交易，从而既挫败攻击，又通过取走攻击者在通道中合法拥有的全部资金来惩罚攻击者。在当前实现中，瞭望塔会分得追回资金的一部分，作为其勤勉监控的报酬。这次合并是对 [Newsletter #19][] 中介绍过的 PR [#1535][LND #1535] 和 [#1512][LND #1512] 的扩展，也是让 LN 对普通用户更安全的重要一步。

## 特别感谢

我们感谢 Christian Decker、practicalswift 和 René Pickhardt 为本期内容提供建议或回答问题。其余错误一概由本期作者负责。


{% include references.md %}
{% include linkers/issues.md issues="2075,14411,2124,1535,1512,14441" %}

[ln threads]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/thread.html
[roasbeef amp]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-February/000993.html
[zmn base amp]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001577.html
[pickhardt local amp]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001626.html
[neigut liquidity]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001532.html
[zmn liquidity]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001555.html
[zmn dual rbf]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001631.html
[zmn splicing cut-through]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-April/001153.html
[pickhardt bolt splicing]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-June/001322.html
[russell splicing]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-October/001434.html
[russell why limit]: https://medium.com/@rusty_lightning/bitcoin-lightning-faq-why-the-0-042-bitcoin-limit-2eb48b703f3
[youtube wumbo]: https://www.youtube.com/watch?v=--hsVknT1c0
[zmn describing wumbo]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001596.html
[zmn global wumbo]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001576.html
[cjp rz]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001498.html
[zmn rz]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001547.html
[zmn rz packetswitch]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001553.html
[cl plugin]: https://github.com/ElementsProject/lightning/blob/master/doc/PLUGINS.md
[rusty wrapup]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001569.html
[ln1.1 outline]: https://github.com/lightningnetwork/lightning-rfc/wiki/Lightning-Specification-1.1-Proposal-States
[input consolidations]: https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#Consolidation
[lnrfc rz]: https://github.com/lightningnetwork/lightning-rfc/wiki/Rendez-vous-mechanism-on-top-of-Sphinx
[newsletter #21]: /zh/newsletters/2018/11/13/#advertising-node-liquidity
[newsletter #17]: /zh/newsletters/2018/10/16/#proposal-for-lightning-network-payment-channel-splicing
[newsletter #12]: /zh/newsletters/2018/09/11/#workshop
[newsletter #19]: /zh/newsletters/2018/10/30/#lnd-1535-1512