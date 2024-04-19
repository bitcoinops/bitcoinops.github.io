---
title: 'Bitcoin Optech Newsletter #274'
permalink: /zh/newsletters/2023/10/25/
name: 2023-10-25-newsletter-zh
slug: 2023-10-25-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报描述了针对 LN 和其他系统中使用的 HTLCs 的替代交易循环攻击，检视了为攻击部署的缓解措施，并总结了其他几项缓解措施提议。此外，还描述了一个影响 Bitcoin Core RPC 的显著漏洞，对比特币脚本进行最小更改的限制条款的研究，以及针对 `OP_CAT` 操作码的拟提议 BIP。周报还包括我们的月度栏目，其中包含来自 Bitcoin Stack Exchange 的热门问题和答案的总结。
本周的周报描述了针对 LN 和其他系统中使用的 HTLCs 的替代交易循环攻击，检视了为攻击部署的缓解措施，并总结了其他几项缓解措施提议。此外，还描述了一个影响 Bitcoin Core RPC 的显著漏洞，对比特币脚本进行最小更改的限制条款的研究，以及针对 `OP_CAT` 操作码的拟提议 BIP。周报还包括我们的月度栏目，其中包含来自 Bitcoin Stack Exchange 的热门问题和答案的总结。

{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

## 新闻

- **<!--replacement-cycling-vulnerability-against-htlcs-->对 HTLCs 的替代交易循环攻击：** 正如[上周周报][news274 cycle]中简要提到的，Antoine Riard 在 Bitcoin-Dev 和 Lightning-Dev 邮件列表中[发帖][riard cycle1]，公开了一个[已经过尽责披露][topic responsible disclosures]的、影响所有 LN 实现的漏洞。自披露以来，各实现已经更新以包括该攻击的缓解措施，我们强烈建议升级到你首选的 LN 软件的最新版本。只有转发支付的节点会受到影响；发起和接收支付的用户不会受到影响。

  我们已将对这个此故事的描述分成三个独立的新闻项目：对漏洞的描述(本项目)、迄今为止由各种 LN 实现部署的缓解措施的描述以及邮件列表上提出的额外缓解措施和解决方案的总结。

  背景知识：可以使用[交易替换][topic rbf]从节点交易池中删除一个多输入交易的一个或多个输入。举一个简单的例子，与 Riard 的原始描述[略有不同]({{bse}}120200)，Mallory 广播一个具有两个输入的交易，该交易分别花费输出 _A_ 和 _B_。然后，她用只花费输出 _B_ 的单输入替代版本替换该交易。替换后，输入 _A_ 及其包含的数据从处理替换的任何节点交易池中被删除。

  尽管常规钱包这样做不安全[^rbf-warning]，但如果 Mallory 想从节点交易池中移除一个输入，她可以利用这个漏洞来实现。

  具体而言，如果 Mallory 与 Bob 共同控制一个输出，她可以等待 Bob 先花费该输出，再用包含其他输入的自己的花费替换 Bob 的花费，然后用不再花费他们共享输出的交易替换她的花费。这是一个_替代交易循环_。矿工仍将从 Mallory 收取交易费，但极有可能 Bob 和 Mallory 的输出花费都不会在 Bob 广播他的花费时得到确认。

  这一点在 LN 和其他几个协议的情况下很重要，因为某些交易需要在特定时间窗口内发生，以确保转发支付的用户不会损失金钱。例如，Mallory 使用她的一个节点(我们称之为 _MalloryA_) 将支付转发给 Bob，Bob 将该支付转发给 Mallory 的另一个节点 (_MalloryB_)。MalloryB 应该向 Bob 提供一个 _原像_ 以允许他从 MalloryA 接受转发的支付，或者 MalloryB 应该在某个时间之前取消（撤销）她从 Bob 那里收到的转发支付。相反，MalloryB 在指定时间内什么也没做，Bob 被迫关闭通道并广播一个交易，该交易将转发的支付花费给自己。该花费应及时确认，允许 Bob 取消（撤销）他从 MalloryA 那里收到的支付，这使每个人的余额恢复到尝试转发之前的金额（除了用于关闭和结算 Bob-MalloryB 通道的任何交易费用）。

  或者，当 Bob 关闭通道并尝试将转发的支付找给自己时，MalloryB 可以用包含原像的自己的花费替换 Bob 的花费。如果该交易及时确认，Bob 将掌握原像并能够从 MalloryA 领取转发的付款，从而使 Bob 满意。

  然而，如果 MalloryB 用包含原像的自己的花费替换 Bob 的花费，之后她很快删除该输入，那么 Bob 的花费或 MalloryB 的原像就不可能出现在区块链中。这将阻止 Bob 从 MalloryB 那里收回钱。没有原像，免信任的 LN 协议阻止 Bob 领取来自 MalloryA 的转发付款，所以他给她一笔退款。此时，MalloryB 获得包含原像的花费确认，允许她向 Bob 索取转发的付款。这意味着，如果转发金额为 _x_ ，则 MalloryA 支付零，MalloryB 收到 _x_，Bob 损失 _x_ (不包括各种费用)。

  为了使攻击有利可图，MalloryB 必须与 Bob 共享一个通道，但 MalloryA 可以位于通往 Bob 的转发路径上的任何位置。例如：

  ```
  MalloryA -> X -> Y -> Z -> Bob -> MalloryB
  ```

  替代交易循环对 LN 节点的影响类似于现有的[交易钉死攻击][topic transaction pinning]。然而，像[v3 交易中继][topic v3 transaction relay]这样的技术旨在防止 LN 和类似协议的钉死攻击，但并不能防止替代交易循环。{% assign timestamp="1:40" %}

- **LN 节点中用于替代交易循环的已部署缓解措施：** 正如 Antoine Riard 所[描述的][riard cycle1]，LN 实现已经部署了几项缓解措施。

    - **<!--frequent-rebroadcasting-->频繁重新广播：** 在一个中继节点的交易池中，如果 Bob 的花费被 Mallory 的花费替换，然后 Mallory 的输入被 Mallory 的第二次替换移除之后，该中继节点将立即再次接受 Bob 的花费。Bob 所需要做的就是重新广播他的花费，除了他已经愿意支付的交易费用外，这不会给他带来任何开支。

      在替代交易循环的私下披露之前，LN 实现只偶尔重新广播其交易（每个块一次或更少）。通常，广播和重新广播交易存在[隐私代价][topic
      transaction origin privacy]，它可能使第三方更容易将 Bob 的链上 LN 活动与其 IP 地址相关联。尽管当前很少有公共 LN 转发节点试图隐藏这一点。现在，Core Lightning、Eclair、LDK 和 LND 都将更频繁地重新广播。

      在 Bob 每次重新广播之后，Mallory 可以使用相同的技术再次替换他的交易。但是，BIP 125 替换规则将要求 Mallory 为每次替换支付额外的交易费用，这意味着 Bob 的每次重新广播都会降低 Mallory 成功攻击的获利能力。

      由此可推出一个粗略的公式，用于计算节点应该接受的 HTLC 的最大金额。如果攻击者为每轮替代交易循环将需要支付的费用为 _x_，防御者拥有的区块数量为 _y_，以及防御者每个区块平均将进行的有效重新广播次数为 _z_，那么一个 HTLC 在略低于 `x*y*z` 的值时可能相当安全。

    - **更长的 CLTV 到期差：** 当 Bob 从 MalloryA 接受 HTLC 时，他同意允许她在某些区块（比如200个区块）之后索取链上退款。当 Bob 向 MalloryB 提供一个相同价值的 HTLC 时，她允许他在较少的区块（比如100个区块）之后索取退款。这些到期条件使用 `OP_CHECKLOCKTIMEVERIFY` (CLTV) 操作码编写，因此它们之间的差值称为 _CLTV 到期差_。

      CLTV 到期差越长，如果支付失败，支付的原发起方将需要等待的时间来收回资金就越长，因此支付方倾向于通过具有较短差值的通道路由支付。然而，差值越长，诸如 Bob 之类的转发节点响应[交易钉死][topic transaction pinning]和大规模关闭通道等问题的时间也越长，这也是事实。这些相互矛盾的利益导致了 LN 软件中默认差值的频繁调整(见周报 [#40][news40 delta]、[#95][news95 delta]、[#109][news109 delta]、[#112][news112 delta]、[#142][news142 delta]、[#248][news248 delta]和[#255][news255 delta])。

      在交易替代循环的情况下，更长的 CLTV 到期差为 Bob 提供了更多轮重新广播，根据上述重新广播缓解描述中提到的粗略公式，这提高了攻击的成本。

      此外，每当 Bob 的重新广播花费交易位于矿工的交易池中时，就有可能该矿工将其包含在被挖矿的区块样板中，致使攻击失败。在 Mallory 最初用她的原像替换它之前，她的原像也可能被挖掘出来，同样导致攻击失败。如果每轮循环导致这两笔交易在矿工交易池中停留一定的时间，那么 Bob 的每次重新广播都会将该时间乘以一定的次数。 CLTV 到期差值会进一步乘以那个时间。

      例如，即使这些交易普遍在矿工的交易池中只花费每个块的 1% 的时间，如果 CLTV 到期差值为仅 70 个区块，攻击也有约 50% 的可能性会失败。使用 Riard 电子邮件中列出的不同 LN 实现的当前默认 CLTV 到期差数字，下图显示了在假设预期的 HTLC 花费交易位于矿工交易池中的时间分别为0.1%、1% 或 5% 的情况下，Mallory 的攻击失败（并且她失去了任何她在替换交易上花费的钱）的概率。作为参考，给定 600 秒的平均出块时间，这些百分比对应于每 10 分钟仅 0.6 秒、6 秒和 30 秒。

      ![Plot of probability attack will fail within x blocks](/img/posts/2023-10-cltv-expiry-delta-cycling.png)

    - **<!--mempool-scanning-->交易池扫描：** HTLC 的设计目的是激励 Mallory 在 Bob 可以申领退款之前使她的原像确认到区块链中。这对 Bob 来说很方便：区块链可广泛使用且限制大小，因此 Bob 可以轻松找到影响他的任何原像。如果系统按预期工作，那么 Bob 可以从区块链中获取一切其所需的信息以实现 LN 上的免信任操作。

     不幸的是，替代交易循环意味着 Mallory 可能不再有动力在 Bob 的退款可以申领之前确认她的交易。然而，为了启动替代交易循环，Mallory 仍需要向矿工交易池短暂披露她的原像，以便替换 Bob 的花费。如果 Bob 运行一个中继全节点，Mallory 的原像交易可能会在网络中传播到 Bob 的节点。接着，如果 Bob 在他需要向 MalloryA 退款之前检测到原像，则攻击被击败，Mallory 失去所有她为攻击而准备的资金。

      交易池扫描并不完美————无法保证 Mallory 的替换交易会传播到 Bob 那里。然而，Bob 重新广播他的交易次数越多（见重新广播缓解措施）以及 Mallory 需要将她的原像隐藏得越久（见CLTV到期差值缓解措施），原像交易及时进入 Bob 的交易池的可能性就越大，以便他挫败攻击。

      Eclair 和 LND 当前已实现了交易池扫描，在用作转发节点时启用。

    - **<!--discussion-of-mitigation-effectiveness-->讨论缓解措施的有效性：** Riard 的最初公告说：“我认为替代交易循环攻击对于高级攻击者来说仍然可行”。 Matt Corallo [写道][corallo cycle1]，“已部署的缓解措施预计无法解决此问题；甚至可以说，除了公关声明，它们什么也不是”。 Olaoluwa Osuntokun [辩论说][osuntokun cycle1]，“[在我看来]，这是一个相当脆弱的攻击，它需要：每个节点的设置，极其精确的时机和执行，所有交易的非确认叠加，以及整个网络的瞬时传播”。

      我们在 Optech 认为，重申这种攻击只影响转发节点非常重要。转发节点是一个连接到始终在线的互联网服务的比特币热钱包———是一种在任何时候都有可能因一个漏洞而失去全部资金的部署类型。任何评估替代交易循环对运行 LN 转发节点的风险状况的影响的人都应该在已经可以容忍其风险背景的情况下考虑它。当然，值得寻找其他方法来降低这种风险，正如我们的下一个新闻项目中所讨论的。

- **<!--proposed-additional-mitigations-for-replacement-cycling-->针对替代交易循环的拟议的额外缓解措施：** 在撰写本文时，Bitcoin-Dev 和 Lightning-Dev 邮件列表对替代交易循环攻击的披露作出了 40 多个独立的回复。建议的回应包括以下内容：

    - **<!--incrementing-fees-towards-scorched-earth-->增加费用以达到毁灭效果：** Antoine Riard 关于攻击的[论文][riard cycle paper]以及 [Ziggie][ziggie cycle] 和 [Matt Morehouse][morehouse cycle]的邮件列表文章建议，防御者（例如 Bob）不应仅仅重新广播退款花费，还应该开始广播相互冲突的另类花费，并随着截止日期临近而不断增加手续费，与上游攻击者（例如，MalloryA）竞争。

      BIP125 规则要求下游攻击者（例如 MalloryB）为针对 Bob 的花费的每个替代交易支付更高的费用，这意味着如果 Mallory 成功，Bob 可以进一步降低攻击的盈利能力。考虑我们在 _重新广播缓解措施_ 部分描述的粗略的 `x*y*z` 公式。如果某些重新广播的 _x_ 成本增加，则攻击者的总成本增加，HTLC 的最大安全值也更高。

      Riard 在他的论文中认为，这些成本可能是不对称的，特别是在典型费用增加的时期，攻击者可能能够将其交易从矿工交易池中驱逐出去。在邮件列表上，他还[认为][riard cycle2]攻击者可以通过一种[批处理支付][topic payment batching]方式在多个受害者之间传播他的攻击，略微提高其效力。

      Matt Corallo [指出][corallo cycle2]，与仅重新广播相比，这种方法的主要缺点是，即使 Bob 击败攻击者，Bob 也会损失部分 HTLC 价值（或者可能全部）。理论上讲，攻击者不会挑战他认为会使用同归于尽策略的防御者，因此 Bob 实际上永远不需要支付越来越高的费率。这是否会在比特币网络上的实践中被证明是真实的，还有待验证。

    - **<!--automatic-retrying-of-past-transactions-->过去交易的自动重试：** Corallo [建议][corallo cycle1]，“解决此问题的唯一方法是矿工保留他们见过的交易历史记录，并在此类攻击之后尝试再次处理这些交易。” Bastien Teinturier [回复说][teinturier cycle]，“我同意 Matt，更基本的工作可能需要在比特币层面发生，以允许 L2 协议对这类攻击更具弹性”。Riard 也[说了][riard cycle3]类似的话，“可持续的修复[只能]发生在基础层，例如添加所有见过的交易的内存密集型历史记录”。

    - **<!--presigned-fee-bumps-->预签名的费用提升：** Peter Todd [认为][todd cycle1]，“预签名交易的正确方法是预签名足够多*不同的*交易，以满足所有合理的费用提升需求。[...] B->C 交易被卡住没有任何理由。”(原文加粗。)

      这可能是这样的：对于 Bob 和 MalloryB 之间的 HTLC，Bob 为 MalloryB 以不同的费率支付相同的原像花费并提供十个不同的签名。请注意，这并不要求 MalloryB 在签名时向 Bob 披露原像。同时，MalloryB 针对相同的退款花费以不同的费率向 Bob 提供了十个不同的签名。这可以在退款之前完成。使用的费率可能是（以 sats/vbyte 为单位）：1、2、4、8、16、32、64、128、256、512、1024，这应该涵盖了可预见的未来的任何情形。

      如果 MalloryB 的原像花费是预先确定的，那么她唯一能做的替代就是从一种费率提高到更高的费率。她无法向原像花费添加新的输入，如果没有这种能力，她将无法启动替代交易循环。

    - **OP_EXPIRE：** 在一个单独的帖子中，但引用了替代交易循环帖子中的内容，Peter Todd[提出了][todd expire1]几个共识更改，以启用一个 `OP_EXPIRE` 操作码，如果交易的脚本执行了 `OP_EXPIRE`，则交易在指定的块高之后无效。这可用于使 Mallory 的 HTLC 的原像仅在 Bob 的退款条件变为可花费之前可用。这可以防止 Mallory 替换 Bob 的退款交易，使 Mallory 无法执行替代交易循环攻击。`OP_EXPIRE` 也可解决针对 HTLCs 的[交易钉死攻击][topic transaction pinning]。

      `OP_EXPIRE` 的主要缺点是它需要对共识进行更改才能启用，并需要对中继和交易池规则进行更改，以避免某些问题，例如被用来浪费节点带宽。

      对提案的答复[提出了][harding expire]一种较轻微的方法来实现与 `OP_EXPIRE` 相同的一些目标，但不需要任何共识或中继规则更改。然而，Peter Todd [认为][todd expire2]，这并不能阻止替代交易循环攻击。

    Optech 希望继续讨论该主题，并将在未来的周报中总结任何值得注意的进展。

- **<!--bitcoin-utxo-set-summary-hash-replacement-->Bitcoin UTXO set summary hash replacement:** Fabian Jahr 在 Bitcoin-Dev 邮件列表中[发帖][jahr hash_serialized_2]，声称发现 Bitcoin Core 在计算当前 UTXO 集的哈希值时存在一个错误。该哈希值没有承诺每个 UTXO 的高度和 coinbase 信息，这些信息是执行 100 个区块 coinbase 的成熟规则和 [BIP68][] 相对时间锁所需的信息。所有这些信息仍然存储在已从头开始同步的节点的数据库中（所有当前 Bitcoin Core 节点），并且仍然用于强制执行，因此此错误不会影响任何已知的已发布软件。但是，Bitcoin Core 下一个主要版本计划的实验性 [assumeUTXO][topic assumeutxo] 特性将允许用户共享他们的 UTXO 数据库。不完整的承诺意味着修改后的数据库可能与经过验证的数据库具有相同的哈希值，这可能为 assumeUTXO 用户打开一个狭窄的攻击窗口。

  如果你知道任何使用 `hash_serialized_2` 字段的软件，请将问题通知其作者，并鼓励他们阅读 Jahr 的电子邮件，以了解为解决该错误而对 Bitcoin Core 的下一个主要版本所做的更改。{% assign timestamp="24:21" %}

- **<!--research-into-generic-covenants-with-minimal-script-language-changes-->对脚本语言更改最小的通用限制条款的研究：**
  Rusty Russell 在 Bitcoin-Dev 中[发布了][russell scripts]一个链接，链接指向他所进行的一些[研究][russell scripts blog]，研究使用一些新的简单操作码，以允许被一个交易执行的一个脚本可以检查在同一笔交易中被支付的输出脚本，这是一种强大的 _内省_ 形式。执行对输出脚本（及其所承诺的内容）的内省能力允许实现[限制条款][topic covenants]。他的一些重要发现包括：

  - *<!--simple-->简单：* 使用三个新操作码，加上几个先前提出的限制条款操作码中的任何一个 (例如 [OP_TX][news187 op_tx])，可以完全内省一个单一输出脚本和其[taproot][topic taproot]承诺。每个新的操作码都易于理解，并且易于实现。

  - *<!--fairly-concise-->相当简洁：* Russell 的示例使用约 30 vbytes 执行合理的内省（不包括要被强制执行的脚本的大小）。

  - *对 OP_SUCCESS 的改变会有好处：* [tapscript][topic tapscript] 的 [BIP342][]规范指定了几个 `OP_SUCCESSx` 操作码，使得包含这些操作码的任何脚本都会始终成功，允许未来软分叉将条件附加到这些操作码上（使它们的行为类似于常规操作码）。然而，这种行为使得使用允许包含任意脚本部分的限制条款来实现内省是不安全的。例如，Alice可能想创建一个限制条款，如果她首先在一个[保险柜][topic vaults]通知交易中花费她的资金，并等待一些区块的数量来允许一个冻结交易来阻止该花费，则允许将她的资金花费到任意地址。然而，如果目标地址包含一个 `OP_SUCCESSx` 操作码，任何人都能够窃取她的钱。Russell 在他的研究中提出了两个可能的解决方案。

  该研究收到了一些讨论，Russell 表示他正在编写一篇关于输出金额内省的后续文章。{% assign timestamp="40:02" %}

- **<!--proposed-bip-for-op-cat-->OP_CAT 的拟议 BIP：** Ethan Heilman 在 Bitcoin-Dev 邮件列表中[发布了][heilman cat]一个[拟议的 BIP][op_cat bip]，以向 tapscript 添加 [OP_CAT][] 操作码。操作码将采用堆栈顶部的两个元素，并将它们联结成一个元素。他链接到几个论述 `OP_CAT` 本身将为脚本添加的功能的描述。他建议的参考实现只有 13 行代码（不包括空格）。

    该提案得到了适度的讨论，其中大部分集中在 tapscript 中的限制上，这些限制可能会影响启用 `OP_CAT` 的有用性和最坏情况下的成本（以及是否应该更改这些限制中的任何一个）。 {% assign timestamp="45:38" %}

## Bitcoin Stack Exchange 的精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 的贡献者们寻找答案的首选之地，也是它们有闲暇时会给好奇和困惑的用户帮忙的地方。在这个月度栏目中，我们会列举自上次出刊以来出现的一些高票的问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}

- [Branch 和 Bound 钱币选择算法如何工作？]({{bse}}119919)
  Murch 总结了他对[钱币选择][topic coin selection]的[Branch and Bound 算法][branch and bound paper]的研究工作，该算法“搜索产生无找零交易的浪费最少的输入集”。{% assign timestamp="52:17" %}

- [<!--why-is-each-transaction-broadcast-twice-in-the-bitcoin-network-->为什么每笔交易在比特币网络中广播两次？]({{bse}}119819)
  Antoine Poinsot 回应了中本聪（Satoshi）早期的邮件列表帖子，该帖子指出“每笔交易必须广播两次”。Poinsot 澄清说，虽然当时交易被广播了两次（一次在交易中继期间，一次在区块中继期间），但随后添加的 [BIP152][] [致密区块中继][topic compact block relay]意味着交易数据只需要向对等节点广播一次。{% assign timestamp="54:29" %}

- [为什么在比特币中禁用了 OP_MUL 和 OP_DIV ？]({{bse}}119785)
  Antoine Poinsot 指出，除[其他操作码][github disable opcodes]以外，`OP_MUL` and `OP_DIV` 可能是因为在禁用的前几周发现了 ["1 RETURN"]({{bse}}38037) 和 [OP_LSHIFT crash][CVE-2010-5137]崩溃错误。{% assign timestamp="56:57" %}

- [为什么 hashSequence 和 hashPrevouts 是分开计算的？]({{bse}}119832)
  Pieter Wuille 解释说，通过将待签名的交易哈希数据拆分为先前的输出和序列，整笔交易无论使用什么类型的 sighash，都可以使用这些哈希值一次性计算出来。{% assign timestamp="58:56" %}

- [为什么 Miniscript 为哈希原像比较添加额外的大小检查? ]({{bse}}119892)
  Antoine Poinsot 指出 [miniscript][topic miniscript] 中的哈希原像大小受到限制，以避免非标准比特币交易、避免共识无效的跨链原子互换，并确保能够精确计算见证成本。 {% assign timestamp="59:52" %}

- [<!--how-can-the-next-block-fee-be-less-than-the-mempool-purging-fee-rate-->如何让下一个区块的费用低于交易池清除费用？]({{bse}}120015)
  用户 Steven 引用 mempool.space 仪表板显示，默认交易池清除费率为 1.51sat/vb，同时预估下一个区块打包交易费率为 1.49sat/vb。Glozow 概述了可能的解释，即全满的交易池导致被驱逐的交易增加了节点交易池的最小费率 (通过 `-incrementalRelayFee`)，但在交易池中留下了一些更低费率的交易，这些交易不需要被驱逐来保持最大交易池大小。

  她还将[祖先评分][waiting for confirmation 2]与后代评分之间用于交易池驱逐的不对称性提及为另一种可能的解释，并链接到一个与[集群交易池][topic cluster
  mempool]相关的[问题][Bitcoin Core #27677]，该问题解释了这种不对称性和潜在的新方法。{% assign timestamp="1:00:51" %}

## 版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Bitcoin Core 25.1][] 是一个维护版本，主要包含错误修复。它是当前推荐的 Bitcoin Core版本。{% assign timestamp="1:12:00" %}

- [Bitcoin Core 24.2][] 是一个维护版本，主要包含错误修复。建议仍在使用 24.0 或 24.1 但目前无法或不愿升级到 25.1 的任何人使用。 {% assign timestamp="1:12:00" %}

- [Bitcoin Core 26.0rc1][] 是主要全节点实现的下一个主要版本的候选版本。在撰写本文时，需验证的测试二进制文件尚未发布，尽管我们预计它们将在周报发布后不久在上述 URL 上发布。主要版本的先前候选版本在[Bitcoin Core 开发者维基][Bitcoin Core developer wiki] 都有测试指南，并召开了专门讨论测试的[Bitcoin Core PR 审核俱乐部][Bitcoin Core PR Review Club]会议。我们鼓励有兴趣的读者定期检查这些资源是否可用于新的候选版本。{% assign timestamp="1:14:23" %}

## 重大的代码和文档变更 ：

_由于本周新闻量较大，以及我们主要撰稿人时间上的限制，我们无法审核上周的代码更改。我们将把它们作为下周周报的一部分。_

## 补充说明

[^rbf-warning]:
    此处描述的替代交易循环攻击基于替代交易，其中包含的输入少于它所替代的原始交易。这是钱包作者通常被警告要避免的行为。例如，_精通比特币，第三版_ 书中说：

    > 当创建同一交易的多个替代版本时，你必须非常小心。你必须确保所有版本的交易都相互冲突。如果它们不是全部冲突，则可能同时确认多个独立的交易，导致您向接收方多次支付。例如:
    >
    > - 交易版本 0 包含输入 A。
    >
    > - 交易版本 1 包含输入 A 和 B(例如,你不得不添加输入 B 来支付额外的费用)。
    >
    > - 交易版本 2 包含输入 B 和 C(例如,你不得不添加输入 C 来支付额外的费用，但 C 足够大，以至于你不再需要输入 A)。
    >
    > 在上述场景中，保存交易版本 0 的任何矿工都能够确认交易的版本 0 和版本 2。如果两个版本向相同的接收方支付，他们将被支付两次(而矿工将从两笔独立的交易中收取交易费用)。
    >
    > 避免这个问题的一个简单方法是确保替代交易始终包含与交易的前一个版本相同的所有输入。

{% include references.md %}
{% include linkers/issues.md v=2 issues="27677" %}
[news274 cycle]: /zh/newsletters/2023/10/18/#security-disclosure-of-issue-affecting-ln
[riard cycle1]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/021999.html
[corallo cycle1]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022015.html
[osuntokun cycle1]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022044.html
[riard cycle paper]: https://github.com/ariard/mempool-research/blob/2023-10-replacement-paper/replacement-cycling.pdf
[ziggie cycle]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022005.html
[morehouse cycle]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022024.html
[riard cycle2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022029.html
[corallo cycle2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022025.html
[teinturier cycle]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022022.html
[riard cycle3]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022032.html
[todd cycle1]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022033.html
[todd expire1]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022042.html
[harding expire]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022050.html
[todd expire2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022051.html
[hash_serialized_2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022038.html
[russell scripts]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022031.html
[russell scripts blog]: https://rusty.ozlabs.org/2023/10/20/examining-scriptpubkey-in-script.html
[news187 op_tx]: /en/newsletters/2022/02/16/#simplified-alternative-to-op-txhash
[heilman cat]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022049.html
[op_cat bip]: https://github.com/EthanHeilman/op_cat_draft/blob/main/cat.mediawiki
[jahr hash_serialized_2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022038.html
[Bitcoin Core 25.1]: https://bitcoincore.org/bin/bitcoin-core-25.1/
[Bitcoin Core 24.2]: https://bitcoincore.org/bin/bitcoin-core-24.2/
[Bitcoin Core 26.0rc1]: https://bitcoincore.org/bin/bitcoin-core-26.0/
[news40 delta]: /en/newsletters/2019/04/02/#lnd-2759
[news95 delta]: /en/newsletters/2020/04/29/#new-attack-against-ln-payment-atomicity
[news109 delta]: /en/newsletters/2020/08/05/#lnd-4488
[news112 delta]: /en/newsletters/2020/08/26/#bolts-785
[news142 delta]: /en/newsletters/2021/03/31/#rust-lightning-849
[news248 delta]: /zh/newsletters/2023/04/26/#lnd-v0-16-1-beta
[news255 delta]: /zh/newsletters/2023/06/14/#eclair-2677
[bitcoin core developer wiki]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki
[bitcoin core pr review club]: https://bitcoincore.reviews/#upcoming-meetings
[branch and bound paper]: https://murch.one/erhardt2016coinselection.pdf
[github disable opcodes]: https://github.com/bitcoin/bitcoin/commit/4bd188c4383d6e614e18f79dc337fbabe8464c82#diff-27496895958ca30c47bbb873299a2ad7a7ea1003a9faa96b317250e3b7aa1fefR94
[CVE-2010-5137]: https://en.bitcoin.it/wiki/Common_Vulnerabilities_and_Exposures#CVE-2010-5137
[waiting for confirmation 2]: /zh/blog/waiting-for-confirmation/#激励兼容
