---
title: 'Bitcoin Optech Newsletter #340'
permalink: /zh/newsletters/2025/02/07/
name: 2025-02-07-newsletter-zh
slug: 2025-02-07-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报宣布了一个影响 LDK 的已修复漏洞，总结了关于零知识方式传播闪电网络通道公告的讨论，描述了可应用于寻找最优族群线性化的先前研究的发现，提供了 Erlay 协议开发的最新进展，探讨了实现闪电网络临时锚点的不同脚本之间的权衡，转述了一个无需共识变更就能以保护隐私的方式模拟 `OP_RAND` 操作码的提议，并指向了关于降低最低交易费率的新讨论。

## 新闻

- **<!--channel-force-closure-vulnerability-in-ldk-->****LDK 中的通道强制关闭漏洞：** Matt Morehouse 在 Delving Bitcoin 上[发帖][morehouse forceclose]宣布了一个影响 LDK 的漏洞，他[负责任地披露][topic responsible disclosures]了这个漏洞，并且该漏洞在 LDK 版本 0.1.1 中得到修复。与 Morehouse 最近披露的另一个 LDK 漏洞类似（参见[简报 #339][news339 ldkvuln]），LDK 代码中的一个循环在处理异常情况时首次就终止了，导致无法处理同样问题的后续出现。在这种情况下，可能导致 LDK 无法在开放的通道中结算待处理的 [HTLCs][topic htlc]，最终导致诚实的对手方被迫关闭通道以便在链上结算 HTLC。

  这可能不会导致直接的资金被盗，但可能导致受害者向已关闭的通道支付费用，并降低受害者赚取转发费用的能力。

  Morehouse 这篇精彩的帖子详细介绍了这个问题，并建议如何避免未来出现同样原因导致的漏洞。

- **<!--zero-knowledge-gossip-for-ln-channel-announcements-->****闪电网络通道公告的零知识证明：** Johan Halseth 在 Delving Bitcoin 上[发帖][halseth zkgoss]，提出了对提议的 1.75 [通道公告][topic channel announcements]协议的扩展，该扩展允许其他节点验证通道是否由注资交易支持，防止多种廉价的 DoS 攻击，但不会泄露哪个 UTXO 是注资交易——从而增强隐私。Halseth 的扩展建立在他之前的研究基础上（参见[周报 #321][news321 zkgoss]），该研究使用 [utreexo][topic utreexo] 和零知识（ZK）证明系统。它将应用于基于 [MuSig2][topic musig] 的[简单 taproot 通道][topic simple taproot channels]。

  讨论集中在 Halseth 的想法、继续使用非私密的 gossip 以及生成 ZK 证明的替代方法之间的权衡。关注点包括确保所有闪电网络节点能够快速验证证明，以及由于所有闪电网络节点都需要实现它而导致的证明和验证系统的复杂性。

  在撰写本总结时，讨论仍在继续。

- **<!--discovery-of-previous-research-for-finding-optimal-cluster-linearization-->****发现用于寻找最优族群线性化的先前研究：** Stefan Richter 在 Delving Bitcoin 上[发帖][richter cluster]，介绍了他发现的一篇 1989 年的研究论文，该论文提出了一个已经证明的算法，可以有效地找到一组交易中费率最高的子集，如果该子集包含在区块中，将在拓扑上有效。他还找到了几个类似问题的 [C++ 实现][mincut impl]，“这些实现在实践中应该更快”。

  之前关于[族群交易池][topic cluster mempool]的工作集中在让各种线性化的比较过程变得容易和快速，以便可以使用最好的线性化。这将允许使用快速算法来立即对一个族群进行线性化，而更慢但更优的算法可以在空闲 CPU 周期上运行。然而，如果 1989 年的_最大比率闭包问题_算法或该问题的其他算法能够运行得足够快，它就可以在所有时间周期上一直使用。但是，即使它运行相对较慢，它仍然可以作为在空闲 CPU 周期上运行的算法。

  Pieter Wuille [回复][wuille cluster]表示对此感到兴奋并提出了多个后续问题。他还[描述][wuille sp cl]了族群交易池工作组正在开发的一个新的族群线性化算法，该算法基于与 Dongning Guo 和 Aviv Zohar 在 Bitcoin Research Week 期间的讨论。它将问题转换为可以使用[线性规划][linear programming]解决的问题，似乎速度快、易于实现，并产生最优线性化——如果它能终止的话。然而，需要证明它确实会终止（并且在合理的时间内）。

  虽然与比特币没有直接关系，但我们发现 Richter [描述][richter deepseek]他如何使用 DeepSeek 推理 LLM 找到 1989 年的论文很有趣。

  在撰写本总结时，讨论仍在继续，正在探索该问题领域的其他论文。Richter 写道，“看来我们的问题，或者说，它的广义解决方案，被称为_源汇单调参数最小割_，在地图简化的多边形聚合和计算机视觉的其他主题中有应用。”

- **<!--erlay-update-->****Erlay 更新：** Sergi Delgado 在 Delving Bitcoin 上发布了多个帖子，介绍了他过去一年在实现 [Erlay][topic erlay] 方面的工作。他首先介绍了现有交易转发（称为 _fanout_）的工作方式以及 Erlay 提议如何改变这一点。他指出，即使在每个节点都支持 Erlay 的网络中，仍然有发生一些 fanout 的预期，因为 “fanout 更高效且比设置重新同步快得多，前提是接收节点不知道正在公告的交易”。

  使用 fanout 和重新同步需要选择何时使用每种方法以及与哪些对等节点一起使用它们，因此他的研究重点是做出最佳选择：

  - [<!--filtering-based-on-transaction-knowledge-->基于交易知识的过滤][sd1] 检查节点是否应该将其对等节点包含在其计划中以 fanout 交易，即使它知道该对等节点已经拥有该交易。例如，我们的节点有十个对等节点；其中三个对等节点已经向我们宣布了交易。如果我们想随机选择三个对等节点进一步 fanout 该交易，我们应该从所有十个对等节点中选择还是只从七个未向我们宣布交易的对等节点中选择？令人惊讶的是，模拟结果表明 “两种选择之间没有显著差异”。Delgado 探索了这个令人惊讶的结果，并得出结论，所有对等节点都应该被考虑（即不应进行过滤）。

  - [<!--when-to-select-fanout-candidate-peers-->何时选择 fanout 候选对等节点][sd2] 检查节点何时应该选择接收 fanout 交易的对等节点（其余对等节点使用 Erlay 重新同步）。考虑两种选择：在节点验证新交易并将其排队进行转发后不久，以及在交易需要转发时（节点不会立即转发交易：它们等待一小段时间以使网络拓扑难以探测和猜测哪个节点发起交易，从而防止对隐私不利的窥探）。同样，模拟结果表明 “没有实质性差异”，尽管 “结果可能会在部分 [Erlay] 支持的网络中有所不同 [...]”。

  - [<!--how-many-peers-should-receive-a-fanout-->多少个对等节点应该接收一个 fanout？][sd3] 检查 fanout 率。较高的比率加速交易传播，但会减少带宽节省。除了测试 fanout 率外，Delgado 还测试了增加出站对等节点的数量，因为这是采用 Erlay 的目标之一。模拟结果显示，当前 Erlay 方法将带宽减少了大约 35%，使用当前出站对等节点限制（8 个对等节点），以及使用 12 个出站对等节点时减少了 45%。但是，交易延迟增加了大约 240%。该帖子还介绍了许多其他权衡。除了对选择当前参数有用的结果以外，Delgado 还指出它们将对评估可能能够做出更好权衡的替代 fanout 算法有用。

  - [<!--defining-the-fanout-rate-based-on-how-a-transaction-was-received-->基于交易接收方法定义 fanout 率][sd4] 检查 fanout 率是否应该根据交易是首先通过 fanout 还是重新同步接收而进行调整。进一步，如果应该调整，应该使用什么调整后的费率？这个想法是，fanout 在新的交易开始通过网络转发时更快、更高效，但它会在交易已经到达大多数节点后导致带宽浪费。没有节点可以直接确定有多少其他节点已经看到交易，但如果首先发送交易的对等节点使用 fanout 而不是等待下一个计划的重新同步，那么交易更有可能在传播的早期阶段。此数据可用于适度增加节点自己的 fanout 率，以帮助它更快传播。Delgado 模拟了这个想法，并找到了一个修改后的 fanout 比率。相较于使用相同的 fanout 率用于所有交易的控制组的结果，该比率将传播时间减少了 18%，而带宽增加仅增加了 6.5%。

- **<!--tradeoffs-in-ln-ephemeral-anchor-scripts-->闪电网络临时锚点脚本之间的权衡：** Bastien Teinturier 在 Delving Bitcoin 上[发帖][teinturier ephanc]，询问应该使用哪个[临时锚点][topic ephemeral anchors] 脚本作为基于 [TRUC][topic v3 transaction relay] 的 LN 承诺交易的输出之一来替代现有的[锚点输出][topic anchor outputs]。使用的脚本决定了谁可以给承诺交易来进行 [CPFP 费用追加][topic cpfp]（以及在什么条件下可以追加）。他提出了四个选项：

  - *<!--use-a-pay-to-anchor-p2a-script-->**使用 pay-to-anchor (P2A) 脚本：* 这具有最小的链上大小，但意味着所有[修剪的 HTLC][topic trimmed htlc] 价值可能都会流向矿工（就像现在这样）。

  - *<!--use-a-single-participant-keyed-anchor-->**使用单参与者密钥锚点：* 这可能允许一些超额修剪的 HTLC 价值被参与者取走，只要他自愿接受等待几个区块后才能够花费他们关闭通道的资金。尝试强制关闭通道的一方必定要等待这个时间。而且，不论哪一方，如果要将手续费支付的工作委托给第三方，都等于允许该第三方偷盗自己在通道中的所有资金。如果你和对手方都竞争去取回超额价值，它可能最终会流向矿工。

  - *<!--use-a-shared-key-anchor-->**使用共享密钥锚点：* 这也允许恢复修剪的 HTLC 值并允许委托，但任何接收委托的人都可以与你和你的对手方竞争，来取走额外价值。同样，在竞争情况下，所有额外价值都可能去矿工。

  - *<!--use-a-dual-keyed-anchor-->**使用双密钥锚点：* 这允许每个参与者取走修剪的 HTLC 值，而无需等待额外区块即可花费。然而，它不允许委托。通道的双方仍然可以相互竞争。

  在帖子回复中，Gregory Sanders [注意到][sanders ephanc]，不同的方案可以在不同时间使用。例如，P2A 可以在没有修剪的 HTLC 时使用，而一个密钥锚可以在其他时间使用。如果修剪的值高于[粉尘阈值][topic uneconomical outputs]，则可以将该值添加到 LN 承诺交易中，而不是锚点输出。此外，他警告说，这可能会带来“新的奇怪事情，[一个]对手方可能会被诱惑将修剪的金额提高并自己拿走”。David Harding 在[后来的帖子][harding ephanc]中扩展了这一主题。

  Antoine Riard [警告][riard ephanc]不要使用 P2A，因为这可能会鼓励矿工去进行[交易钉死][topic transaction pinning]（见[周报 #339][news339 pincycle]）。

  在撰写本总结时，讨论仍在进行中。

- **<!--emulating-op-rand-->****模拟 OP_RAND：** Oleksandr Kurbatov 在 Delving Bitcoin 上[发帖][kurbatov rand]，提出了一种允许双方签订一种合约的交互式协议；该合约将以双方都无法预测的方式支付，实际上等同于随机。以前在比特币上的 _概率支付_ [工作][dryja pp]使用了高级脚本，但 Kurbatov 的方法使用了专门构建的公钥，允许获胜者花费合同资金。这更私密，可能更加灵活。

  Optech 无法彻底地分析协议，但我们没有发现任何明显的缺陷。我们希望看到该想法的进一步讨论——概率支付有多个应用，包括允许用户在链上发送金额，这些金额在其他情况下将是[不经济的][topic uneconomical outputs]，例如用于[修剪的 HTLC][topic trimmed htlc]。

- **<!--discussion-about-lowering-the-minimum-transaction-relay-feerate-->关于降低最低交易费率的讨论：** Greg Tonoski 在 Bitcoin-Dev 邮件列表上[发帖][tonoski minrelay]，关于降低 [默认最低交易转发费率][topic default minimum transaction relay feerates]，这是一个已经讨论过多次（并且 Optech 总结过）的话题，从 2018 年开始，最近一次在 2022 年（见[周报 #212][news212 relay]）。值得注意的是，最近披露的漏洞（见[周报 #324][news324 largeinv]）确实揭示了一个潜在问题，该问题可能会影响过去降低设置的用户和矿工。如果有重大进一步讨论，Optech 将提供更新。

## 改变共识

_总结关于改变比特币共识规则的提议和讨论内容的月度栏目。_

- **<!--updates-to-cleanup-soft-fork-proposal-->共识清理软分叉提议的更新：** Antoine Poinsot 在 Delving Bitcoin 线程上发布了多个帖子，关于 [共识清理软分叉][topic consensus cleanup] 建议参数更改：

  - [<!--introduce-legacy-input-sigops-limit-->引入旧输入 sigops 限制][ap1]：在一个私有的讨论贴中，Poinsot 和几个其他贡献者尝试在 regtest 模式下，利用古旧（segwit 前）交易验证的已知问题，生成需要花费尽可能长时间来验证的区块。经过研究，他发现“在 2019 年最初提议的[缓解措施][ccbip]下，[最坏的区块]也可以适配为有效的”。这导致他提出不同的缓解措施：将旧交易中的单交易最大签名操作数（sigops）限制为 2,500。每个 `OP_CHECKSIG` 执行算作一个 sigop，每个 `OP_CHECKMULTISIG` 可以算作最多 20 sigops（取决于使用的公共密钥数量）。他的分析表明，这将将最坏情况下的验证时间减少 97.5%。

    对于任何此类更改，存在因新规则导致[意外没收][topic accidental confiscation]的风险，因为新规则会使以前签署的交易无效。如果您知道有人需要旧交易超过 2,500 个单签名操作或超过 2,125 个密钥用于多签名操作[^2kmultisig]，请通知 Poinsot 或其他协议开发人员。

  - [<!--increase-timewarp-grace-period-to-2-hours-->将时间扭曲宽容期增加到 2 小时][ap2]：以前，清理提议不允许新难度周期中的第一个区块具有比前一个块早于超过 600 秒的块头时间。这意味着恒定数量的哈希率不能使用[时间扭曲][topic time warp]漏洞来更快地生成区块。

    Poinsot 现在接受使用 7,200 秒（2 小时）宽容期的设计。这是 Sjors Provoost 最初建议的。尽管这会让 50% 以上的网络哈希率控制者即便在实际哈希率保持不变或增加的情况下，可以很耐心地使用时间扭曲攻击在几个月内降低难度，但这种方法不太可能会导致矿工意外地产生一个无效区块。因为这攻击将是一个公开可见的攻击，网络将有几个月的时间做出反应。在帖子中，Poinsot 总结了以前的论点（可参考[周报 #335][news335 cc]中我们更简要的总结），并总结为“除了对增加宽容期的论证较弱之外，这样做[并不会]禁止犯错误”。

    在专门讨论扩展宽容期的讨论帖中，开发人员 Zawy 和 Pieter Wuille [讨论][wuille erlang]，600 秒宽容期，这似乎允许缓慢降低难度到其最小值，实际上足以防止更多的小难度降低。具体来说，他们研究了比特币的 off-by-one 难度调整 bug，以及 [erlang][] 分布对准确重新调整难度的影响的对称性。Zawy 简洁地得出结论，“并不是 Erlang 和 ‘2015 漏洞’ 的调整不需要，而是 600 秒前的前一个区块不是 600 秒的谎言，而是一个 1200 秒的谎言，因为我们期望它之后 600 秒的一个时间戳”。

  - [<!--duplicate-transaction-fix-->重复交易修复][ap3]：作为对矿工反馈的关于共识解决方案可能对[重复交易][topic duplicate transactions]问题产生的潜在负面影响（见[周报 #332][news332 cleanup]）响应的跟进，Poinsot 选择了特定解决方案，包括在清理提议中：要求前一个区块的高度包含在每个 coinbase 交易的锁定时间字段中。这有两个优势：它允许从区块中提取已提交的区块高度，而无需解析脚本，并允许[创建][harding duplocktime]一个紧凑的 SHA256 基于区块高度的证明（在最坏情况下大约 700 字节，远小于现在不需要高级证明系统的最坏情况 1 MB 的证据）。

  这不会影响常规用户，但最终将要求矿工更新他们使用的软件以生成 coinbase 交易。如果任何矿工对提案有任何担忧，请联系 Poinsot 或其他协议开发人员。

  Poinsot 还在 Bitcoin-Dev 邮件列表上[发帖][ap4]，介绍他在工作和提案当前状态的概要更新。

- **<!--request-for-a-covenant-design-supporting-braidpool-->****请求一个支持 Braidpool 的限制条款设计：** Bob McElrath 在 Delving Bitcoin 上[发帖][mcelrath braidcov]，请求 Delving Bitcoin 上正在开发[限制条款][topic covenants]设计的开发者考虑他们喜好的提案或新提案，可以如何有助于创建高效的去中心化[矿池][topic pooled mining]。Braidpool 的当前原型设计使用联邦签名者，其中签名者根据他们对哈希率的贡献接收[门限签名][topic threshold signature]共享。这允许大多数矿工（或多个矿工的多数）从较小的矿工那里窃取支付。McElrath 更喜欢使用一个限制条款，确保每个矿工能够按其贡献的比例从矿池中提取资金。他提供了明确的需求列表，也欢迎证明该想法不可行。

  截至撰写本文时，尚未收到回复。

- **<!--deterministic-transaction-selection-from-a-committed-mempool-->从已提交交易池中确定性交易选择：** 2024 年四月的讨论帖在本月重新获得关注。以前，Bob McElrath [发帖][mcelrath dtx]，关于让矿工承诺他们交易池中的交易，然后只允许他们在区块中包含从以前承诺中确定性选择的交易。他看到了两种可适用情况：

  * _对所有矿工：_ 矿工往往是大型企业实体，需要遵守法律、法规和风险管理建议，而这将消除“交易选择风险和责任”。

  * _对本地单个池：_ 这具有全局确定性算法的大部分优势，但不需要任何共识更改来实现。此外，它可以在参与同一个去中心化[矿池][topic pooled mining]的对等节点之间节省大量带宽，例如 Braidpool，因为算法确定了 _候选区块_ 必须包含的交易，从而为该块制作的任何 _份额_ 都不需要向对等节点明确提供任何交易数据。

  Anthony Towns [描述][towns dtx]了全局共识变化选项的几个潜在问题：任何对交易选择的变更都可能需要共识更改（可能是硬分叉），并且任何创建非标准交易的人都可能无法再让交易挖出，除非直接与矿工合作。近年产生的无需共识变更的交易池规则更新包括：[TRUC][topic v3 transaction relay]、新的 [RBF][topic rbf] 策略和[临时锚点][topic ephemeral anchors]。Towns 链接到了一个[众所周知的情况][bitcoin core #26348]，其中数百万美元的价值意外地卡在非标准脚本中，需要一个合作的矿工才能够将其从中取出。

  其余讨论集中在为 Braidpool 构想的本地方法。没有反对意见，在下一个话题中关于难度调整算法（见本节下一项）的讨论显示了它如何特别有用，对于创建区块速度远高于比特币的池，交易选择的确定性将显著减少带宽、延迟和验证成本。

- **<!--fast-difficulty-adjustment-algorithm-for-a-dag-blockchain-->****用于 DAG 区块链的快速难度调整算法：** 开发人员 Zawy [发帖][zawy daadag]，关于用于有向无环图（DAG）类型区块链的挖矿[难度调整算法][topic daa]（DAA）。该算法 [设计][bp pow] 用于 Braidpool 的节点共识（不是全局比特币共识），然而讨论多次触及全局共识方面。

  在比特币区块链中，每个区块都会承诺到一个父块；多个子块可能承诺给同一个父块，但在一个节点上只有其中一个将被认为是 _最佳区块链_ 上的有效区块。在 DAG 区块链中，每个区块可能承诺给一个或多个父块，并且可能具有零个或多个子块（即承诺给它的区块）；DAG 的最佳区块链可能会认为同一代的多个区块都是有效的。

  ![DAG 区块链的插图](/img/posts/2025-02-dag-blockchain.dot.png)

  被提议的难度调整算法瞄准最后看到的 100 个有效区块中的平均父块数量。如果父块数量增加，算法会增加难度；如果父块数量减少，难度会降低。将平均两个父块作为目标，根据 Zawy 的说法，给出了最快的共识。与比特币的 DAA 不同，该提议不需要知道任何时间；然而，它确实需要对等节点忽略到达时间比同一代中的其他区块晚得多的块。由于不可能对延迟实现共识，因此，最终偏好选择具有更多 PoW 的 DAG，而不是具有较少 PoW 的 DAG；DAA 的开发者 Bob McElrath [分析][mcelrath daa-latency]了问题和可能的缓解。

  Pieter Wuille [评论][wuille prior]，该提议似乎类似于 2012 年 Andrew Miller 的想法；Zawy 表示[同意][zawy prior]，同时 McElrath [会][mcelrath prior]更新他的论文及引用。Sjors Provoost [讨论了][provoost dag] Bitcoin Core 当前架构中处理 DAG 链的复杂性，但注意到使用 libbitcoin 和高效使用 [utreexo][topic utreexo] 可能会更容易。Zawy 大量地[模拟][zawy sim]了协议并表明他正在为协议的变体进行额外模拟，以找到最佳的权衡组合。

  该讨论的最后一个帖子是在我们总结前的一个月写的，但我们期待 Zawy 和 Braidpool 开发者继续分析和实现协议。

## 发布和发布候选

_热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试旧版本。_

- [BDK Wallet 1.1.0][] 是一个用于构建比特币应用程序的库的发布。它默认使用 v2 版本交易（通过允许 BDK 交易与必须使用 v2 交易的其他钱包混合来提高隐私性，见[周报 #337][news337 bdk]）。它还添加了对[致密区过滤器][topic compact block filters]的支持（见[周报 #339][news339 bdk-cpf]），以及“各种错误修复和改进”。

- [LND v0.18.5-beta.rc1][] 是一个针对此流行 LN 节点实现次要版本的发布候选。

## 值得注意的代码和文档更改

_以下是 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]、[闪电 BOLTs][bolts repo]、[闪电 BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的重要更新。_

- [Bitcoin Core #21590][] 为 MuHash3072 实现了基于 safegcd 的[模逆元][modularinversion]算法（见周报 [#131][news131 muhash] 和 [#136][news136 gcd]），基于 libsecp256k1 的实现，同时添加了对 32 位和 64 位架构的支持，并专门针对特定模数。基准结果显示，x86_64 上的近似 100 倍性能改进，将 MuHash 的计算从 5.8 ms 减少到 57 μs，为更高效的状态验证铺平了道路。

- [Eclair #2983][] 修改了重新连接时的路由表同步，仅与节点头部的对等节点（由共享通道容量确定）同步[通道公告][topic channel announcements]，以减少网络开销。此外，同步白名单的默认行为（见周报 [#62][news62 whitelist]）已更新：要禁用与非白名单对等节点的同步，用户现在必须将 `router.sync.peer-limit` 设置为 0（默认值为 5）。

- [Eclair #2968][] 为公开通道添加了对[通道拼接][topic splicing]的支持。一旦拼接交易在双方确认并锁定后，节点交换公告签名，然后广播一个 `channel_announcement` 消息到网络。最近，Eclair 添加了对第三方拼接作为先决条件的跟踪，以进行此操作（见周报 [#337][news337 splicing]）。此 PR 还禁止在私有通道上使用 `short_channel_id` 进行路由，而是优先使用 `scid_alias` 以确保通道 UTXO 不会被揭示。

- [LDK #3556][] 改进了 [HTLC][topic htlc] 处理，在 HTLC 等待上游链上声明确认即将到期之前，主动回传失败。以前，节点会延迟额外三个区块的时间再回传 HTLC
 失败，为声明留有时间来确认。然而，这种延迟会带来通道强制关闭的风险。此外，删除了 `historical_inbound_htlc_fulfills` 字段以清理通道状态，并引入了一个新的 `SentHTLCId` 以消除来自重复 HTLC ID 的冲突。

- [LND #9456][] 为 `SendToRoute`、`SendToRouteSync`、`SendPayment` 和 `SendPaymentSync` 端点添加了废弃警告，为即将发布的下一个版本（0.21）做准备。鼓励用户迁移到新的 v2 方法 `SendToRouteV2`、`SendPaymentV2`、`TrackPaymentV2`。

{% include snippets/recap-ad.md when="2025-02-11 15:30" %}

## 脚注

[^2kmultisig]:
    在 P2SH 和提议的输入 sigop 计数中，超过 16 个公钥的 `OP_CHECKMULTISIG` 被算作 20 sigops，因此，如果有人使用 125 次 `OP_CHECKMULTISIG`，每次 17 个密钥，将被算作 2,500 sigops。

{% include references.md %}
{% include linkers/issues.md v=2 issues="21590,2983,2968,3556,9456,26348" %}
[dryja pp]: https://docs.google.com/presentation/d/1G4xchDGcO37DJ2lPC_XYyZIUkJc2khnLrCaZXgvDN0U/mobilepresent?pli=1#slide=id.g85f425098_0_219
[morehouse forceclose]: https://delvingbitcoin.org/t/disclosure-ldk-duplicate-htlc-force-close-griefing/1410
[news339 ldkvuln]: /zh/newsletters/2025/01/31/#vulnerability-in-ldk-claim-processing
[halseth zkgoss]: https://delvingbitcoin.org/t/zk-gossip-for-lightning-channel-announcements/1407
[news321 zkgoss]: /zh/newsletters/2024/09/20/#proving-utxo-set-inclusion-in-zero-knowledge
[richter cluster]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303/9
[mincut impl]: https://github.com/jonas-sauer/MonotoneParametricMinCut
[wuille cluster]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303/10
[linear programming]: https://zh.wikipedia.org/wiki/%E7%BA%BF%E6%80%A7%E8%A7%84%E5%88%92
[wuille sp cl]: https://delvingbitcoin.org/t/spanning-forest-cluster-linearization/1419
[richter deepseek]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303/15
[delgado erlay]: https://delvingbitcoin.org/t/erlay-overview-and-current-approach/1415
[sd1]: https://delvingbitcoin.org/t/erlay-filter-fanout-candidates-based-on-transaction-knowledge/1416
[sd2]: https://delvingbitcoin.org/t/erlay-select-fanout-candidates-at-relay-time-instead-of-at-relay-scheduling-time/1418
[sd3]: https://delvingbitcoin.org/t/erlay-find-acceptable-target-number-of-peers-to-fanout-to/1420
[teinturier ephanc]: https://delvingbitcoin.org/t/which-ephemeral-anchor-script-should-lightning-use/1412
[sanders ephanc]: https://delvingbitcoin.org/t/which-ephemeral-anchor-script-should-lightning-use/1412/2
[harding ephanc]: https://delvingbitcoin.org/t/which-ephemeral-anchor-script-should-lightning-use/1412/4
[riard ephanc]: https://delvingbitcoin.org/t/which-ephemeral-anchor-script-should-lightning-use/1412/3
[news339 pincycle]: /zh/newsletters/2025/01/31/#replacement-cycling-attacks-with-miner-exploitation
[kurbatov rand]: https://delvingbitcoin.org/t/emulating-op-rand/1409
[tonoski minrelay]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAMHHROxVo_7ZRFy+nq_2YzyeYNO1ijR_r7d89bmBWv4f4wb9=g@mail.gmail.com/
[news324 largeinv]: /zh/newsletters/2024/10/11/#dos-from-large-inventory-sets
[news212 relay]: /zh/newsletters/2022/08/10/#lowering-the-default-minimum-transaction-relay-feerate
[ap1]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/64
[ap2]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/66
[mcelrath braidcov]: https://delvingbitcoin.org/t/challenge-covenants-for-braidpool/1370/1
[news332 cleanup]: /zh/newsletters/2024/12/06/#continued-discussion-about-consensus-cleanup-soft-fork-proposal
[harding duplocktime]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/26
[corallo duplocktime]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/25
[ap3]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/65
[mcelrath dtx]: https://delvingbitcoin.org/t/deterministic-tx-selection-for-censorship-resistance/842/
[towns dtx]: https://delvingbitcoin.org/t/deterministic-tx-selection-for-censorship-resistance/842/7
[bp pow]: https://github.com/braidpool/braidpool/blob/6bc7785c7ee61ea1379ae971ecf8ebca1f976332/docs/braid_consensus.md#difficulty-adjustment
[miller stale]: https://bitcointalk.org/index.php?topic=98314.msg1075701#msg1075701
[mcelrath daa-latency]: https://delvingbitcoin.org/t/fastest-possible-pow-via-simple-dag/1331/12
[zawy prior]: https://delvingbitcoin.org/t/fastest-possible-pow-via-simple-dag/1331/9
[mcelrath prior]: https://delvingbitcoin.org/t/fastest-possible-pow-via-simple-dag/1331/8
[zawy sim]: https://delvingbitcoin.org/t/fastest-possible-pow-via-simple-dag/1331/10
[zawy daadag]: https://delvingbitcoin.org/t/fastest-possible-pow-via-simple-dag/1331
[wuille prior]: https://delvingbitcoin.org/t/fastest-possible-pow-via-simple-dag/1331/6
[provoost dag]: https://delvingbitcoin.org/t/fastest-possible-pow-via-simple-dag/1331/13
[ccbip]: https://github.com/TheBlueMatt/bips/blob/7f9670b643b7c943a0cc6d2197d3eabe661050c2/bip-XXXX.mediawiki#specification
[news36 cc]: /zh/newsletters/2019/03/05/#prevent-use-of-op-codeseparator-and-findanddelete-in-legacy-transactions
[news335 cc]: /zh/newsletters/2025/01/03/#consensus-cleanup-timewarp-grace-period
[wuille erlang]: https://delvingbitcoin.org/t/timewarp-attack-600-second-grace-period/1326/28?u=harding
[erlang]: https://zh.wikipedia.org/wiki/%E7%88%B1%E5%B0%94%E6%9C%97%E5%88%86%E5%B8%83
[sd4]: https://delvingbitcoin.org/t/erlay-define-fanout-rate-based-on-the-transaction-reception-method/1422
[news136 gcd]: /zh/newsletters/2021/02/17/#faster-signature-operations
[news337 bdk]: /zh/newsletters/2025/01/17/#bdk-1789
[news339 bdk-cpf]: /zh/newsletters/2025/01/31/#bdk-1614
[bdk wallet 1.1.0]: https://github.com/bitcoindevkit/bdk/releases/tag/wallet-1.1.0
[lnd v0.18.5-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.5-beta.rc1
[ap4]: https://mailing-list.bitcoindevs.xyz/bitcoindev/jiyMlvTX8BnG71f75SqChQZxyhZDQ65kldcugeIDJVJsvK4hadCO3GT46xFc7_cUlWdmOCG0B_WIz0HAO5ZugqYTuX5qxnNLRBn3MopuATI=@protonmail.com/
[modularinversion]: https://en.wikipedia.org/wiki/Modular_multiplicative_inverse
[news131 muhash]: /zh/newsletters/2021/01/13/#bitcoin-core-19055
[news62 whitelist]: /zh/newsletters/2019/09/04/#eclair-954
[news337 splicing]: /zh/newsletters/2025/01/17/#eclair-2936
