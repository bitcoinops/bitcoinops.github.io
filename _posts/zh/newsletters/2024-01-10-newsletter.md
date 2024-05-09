---
title: 'Bitcoin Optech Newsletter #284'
permalink: /zh/newsletters/2024/01/10/
name: 2024-01-10-newsletter-zh
slug: 2024-01-10-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报总结了有关 LN 锚点和 v3 交易中继提案的讨论内容，并宣布了 LN-Symmetry 的研究实现。此外，还包括了常规部分，其中包括对 Bitcoin Core PR 审核俱乐部会议的总结，以及对热门比特币基础设施软件的重大变化的描述。

## 新闻

- **<!--discussion-about-ln-anchors-and-v3-transaction-relay-proposal-->关于 LN 锚点和 v3 交易中继提案的讨论：**
  Antoine Poinsot 在 Delving Bitcoin 上[发帖][poinsot v3]，以促进关于 [v3 交易中继策略][topic v3 transaction relay]和[临时锚点][topic ephemeral anchors]的讨论。这个主题似乎是由 Peter Todd 在他的博客上[发表][todd v3]关于 v3 中继策略的批评而激发的。我们任意地将讨论分成几个部分:

  - **<!--frequent-use-of-exogenous-fees-may-risk-mining-decentralization-->频繁使用外生费用可能会危及挖矿的去中心化：**
    比特币协议的理想版本应该按照矿工的算力比例奖励每个矿工。交易中支付的隐式手续费保留了这一属性：拥有 10% 总算力的矿工有 10% 的机会获取下一个区块的费用，而拥有 1% 算力的矿工则有 1% 的机会。在交易之外并且直接支付给某个矿工的手续费，叫做[协议外的手续费][topic out-of-band fees]，违反了这一属性：一个支付给控制超过 55% 算力的矿工的系统，在 6 个区块内<!-- 1 - (1 - 0.55)**6 -->有 99% 的机会确认交易，很可能导致很少的动力向拥有 1% 或更少算力的小矿工支付费用。如果小矿工获得的报酬比大矿工相对更少，矿业将自然地中心化，这将减少为了审查交易（不让交易得到确认）而需要攻陷的实体的数量。

    活跃使用的协议，例如：[带有锚点输出的 LN 承诺交易 (LN-Anchors)][topic anchor outputs]、[谨慎日志合约][dlc cpfp]和[客户端验证][topic client-side validation]，允许它们至少有一部分链上交易通过_外生性的_方式支付费用，这意味着交易核心支付的费用可以通过使用一个或多个独立的 UTXO 来增加。例如，在 LN-Anchors 中，承诺交易包括一个输出，用于每个参与方使用[子为父偿（CPFP）][topic cpfp]增加费用 (子交易花费额外的 UTXO)。还有，使用 `SIGHASH_SINGLE|SIGHASH_ANYONECANPAY` 部分签名的 HTLC-Success 和 HTLC-Failure 交易(HTLC-X 交易)，它们可以聚合到一个交易中，至少有一个额外的输入来支付费用（额外的输入是单独的 UTXO）。

    对专注于使用 [P2TR][topic taproot] 和提议的临时锚点的 LN 的思想实验版本，Peter Todd 认为其对外生费用的依赖明显激励了协议外费用。特别是，没有待处理付款 ([HTLCs][topic htlc]) 的通道的单方面关闭将允许接受协议外费用的大矿工在一个区块中包含两倍于只接受通过 CPFP 追加协议内费用的较小矿工可以包含的关闭交易数量。大型矿工可以通过为使用协议外支付的用户提供适度折扣来鼓励这种做法并获利。Peter Todd 称这是对去中心化的威胁。

    该帖子确实建议了协议中一些使用外生费用的情况是可以接受的，因此可能担心的是预期使用频率以及使用它们和协议外支付之间相对大小的差异。换句话说，频繁发生的零等待单方关闭（开销占比100%）可能会被认为是比更少见的有 20 个待处理 HTLC 的单方关闭具有更大的风险，后者的开销不到 10%。

  - **<!--implications-of-exogenous-fees-on-safety-scalability-and-costs-->外生费用对安全性、可扩展性和成本的影响：**
    Peter Todd 的帖子还指出，现有的设计，比如 [LN-Anchors（LN 锚点）][topic anchor outputs]和未来使用[临时锚点][topic ephemeral anchors]的设计都要求每个用户在他们的钱包中保留一个额外的 UTXO，用于必要的费用提升。由于创建 UTXO 会消耗区块空间，因此理论上可以将比特币协议的最大独立用户数量减少一半或更多。这也意味着用户无法安全地将其全部钱包余额分配给其 LN 通道，从而恶化了 LN 用户体验。最后，使用 [CPFP 费用提升][topic cpfp]或将额外的输入附加到交易中以外生方式支付费用，比直接从交易的输入支付费用（内生费用）需要更多的区块空间，也需要支付更多的交易费用，因此即使其他问题并非关注的焦点，从理论上讲也更昂贵。

  - **<!--ephemeral-anchors-introduce-a-new-pinning-attack-->临时锚点引入了一种新的钉死攻击：** 正如[上周周报][news283 pinning]所描述的，Peter Todd 描述了一种针对使用临时锚点的小型钉死攻击。对于没有待处理付款（HTLC）的承诺交易，一个无特权的攻击者可能会制造这样一种情况，即诚实用户可能需要支付 1.5 倍到 3.7 倍的费用才能获得他们预期的费率。然而，如果诚实用户选择[耐心等待][harding pinning]而不是花费额外费用，攻击者最终将支付诚实用户的部分或全部费用。鉴于零待处理承诺交易没有任何时间锁依赖的紧迫性，许多诚实的用户可能会选择耐心等待，并以攻击者的费用来确认他们的交易。当使用 HTLC 时，攻击也有效，但诚实用户摆脱它的成本更低，并且仍然可能导致攻击者损失资金。

  - **<!--an-alternative-use-endogenous-fees-with-presigned-incremental-rbf-bumps-->替代方法：使用预签名的递增的 RBF 内生费用：**
    Peter Todd 建议并分析了一种替代方法，即以不同的费率签署每个承诺交易的多个版本。例如，他建议签署 50 个不同版本的 LN-Penalty 承诺交易，费率从 10 sats/vbyte 开始，每个版本增加 10%，直到签署支付 1,000 sats/vbyte 的交易。对于没有待处理支付 （HTLC） 的承诺交易，他的分析表明签名时间约为 5 毫秒。然而，对于附加到承诺事务的每个 HTLC，签名数量将增加 50 个，签名时间将增加 5 毫秒。Bastien Teinturier 链接到了他关于类似方法[之前的讨论][bolts #1036]。

    尽管这个想法在某些情况下可能有效，但 Peter Todd 的帖子指出，带有预签名的递增提升的内生费用并不是在所有情况下都是对外生费用令人满意的替代。当包含多个 HTLC 的预签名承诺交易所需的延迟乘以典型支付路径上的多个跳时，[延迟][harding delays]很容易超过一秒，至少在理论上会延长到一分钟以上。Peter Todd 指出，如果提议的 [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] 操作码（APO）可用，延迟可以减少到大致恒定的时间。

    即使延迟是固定的 5 毫秒，[也有可能][harding stuckless]导致使用内生费用的转发节点赚取的转发费用比使用外生费用的节点少，因为 LN 支付者预期会产生[冗余的超额支付][topic redundant overpayments]，这将经济地奖励更快的转发，即使差异只有毫秒级别。

    HTLC-Success 和 HTLC-Timeout 交易（HTLC-X 交易）使用相同的内生费用也将是一个额外的挑战。即使有 APO，这在朴素的情况下意味着要创建 <i>n<sup>2</sup></i> 个签名，尽管 Peter Todd 指出，通过假设 HTLC-X 交易将支付与承诺交易相似的费率，可以减少签名的数量。

    <!-- Using our tx-calc, 1-in, 22-out for 20 HTLC is 1014 vbytes;
         BOLT3 "expected weights" gives worst-case HTLC-X weight of 705
         = 176.25 vbytes, times 20 is 3525, plus 1014 is 4539. Multiply
         everything by 1,000 s/vb to get total sats -->

    关于内生费用是否会导致过量资本被预留用于费用的[争论][teinturier fees]仍悬而未决。例如，如果 Alice 签署从 10 s/vb 到 1,000 s/vb 的费用变体，她必须基于对手方 Bob 可能会把 1,000 s/vb 的变体放在链上的可能性做出决定，即使她自己不会支付那个费率。这意味着她不能接受 Bob 的付款，因为他花掉了他所需的 1,000 s/vb 变体的钱。例如，有 20 个HTLC 的承诺交易将使 100 万 sats 暂时无法使用（在撰写本文时为 450 美元）。如果 HTLC-X 交易也使用内生费用，则 20 个 HTLC 暂时无法支出的金额将接近 450万 sats（2,050美元）。相比之下，如果期望 Bob 外生性地支付费用，那么 Alice 就不需要为了她的安全去减少通道的容量。

  - **<!--overall-conclusions-->总体结论：** 在撰写本文时，讨论仍在继续。Peter Todd 总结说：“由于上述提及的矿工去中心化风险，现有的锚点输出的使用应该被逐步淘汰；不应该在新的协议或 Bitcoin Core 中添加新的锚点输出支持”。LN 开发人员 Rusty Russell [发帖][russell inline]谈及在新协议中使用更有效的外生费用形式以最大限度地减少对协议外费用的担忧。在 Delving Bitcoin 帖子中，其他 LN、v3 交易和临时锚点的开发人员对锚点的有用性进行了辩护，他们似乎可能会继续研究与 v3 相关的协议。如果发生任何重大变化，我们将在未来的周报中提供更新。

- **<!--ln-symmetry-research-implementation-->LN-Symmetry 研究实现：** Gregory Sanders 在 Delving Bitcoin 上[发布了][sanders lns]他使用 Core Lightning 的软件分支对 [LN-Symmetry][topic eltoo] 协议（最初称为eltoo）进行的[概念验证实现][poc lns]。LN-Symmetry 提供双向支付通道，保证能够在链上发布最新的通道状态，而无需进行惩罚交易。然而，它们需要允许子交易从父交易的任何可能版本中支付，这只有通过类似 [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] 的软分叉协议更改才能实现。Sanders 提供了他工作中的几个亮点：

  - *<!--simplicity-->简单性：* LN-Symmetry 是一种比目前使用的 LN-Penalty/[LN-Anchors（LN-锚点）][topic anchor outputs]协议简单得多的协议。

  - *<!--pinning-->交易钉死：* “[交易钉死][topic transaction pinning]很难避免”。Sander 在这个问题上的担忧而付出的工作给了他洞察力和灵感，曾让他在[包中继][topic package relay]和广受赞誉的[临时锚点][topic ephemeral anchors]提议中作出贡献。

  - *CTV：* “[CTV][topic op_checktemplateverify] (通过仿真)[...]允许非常简单的“快速转发”，如果广泛采用，可能会减少支付时间。”

  - *<!--penalties-->惩罚：* 惩罚似乎确实没有必要。这是 LN-Symmetry 的希望，但有些人认为仍然需要惩罚协议来阻止恶意交易对手试图盗窃。对惩罚的支持大大增加了协议的复杂性，并且需要保留一些通道资金来支付惩罚，所以如果它们对安全性不是必需的，最好避免支持它们。

  - *<!--expiry-deltas-->到期时间差值：* LN-Symmetry 需要比预期更长的 HTLC 到期时间差。当 Alice 将 HTLC 转发给 Bob 时，她会给他一定值的区块数，以使用原像来领取其资金；该时间到期后，她可以收回资金。当 Bob 进一步将 HTLC 转发给 Carol 时，他给了她较少的区块数，在此期间她必须展示原像。这两个到期之间的差值就是 _HTLC 到期时间差值_。Sanders 发现，到期时间差需要足够长，以防止交易对手在承诺轮次中途中止协议时受益。

  Sanders 目前正在致力于改进 Bitcoin Core 的交易池和中继策略，这将使未来部署 LN-Symmetry 和其他协议变得更加容易。

## Bitcoin Core PR 审核俱乐部

*在这个月度部分，我们总结了最近的 [Bitcoin Core PR 审核俱乐部][bitcoin core pr review club]会议，重点介绍了一些重要的问题和答案。单击下面的问题以查看会议答案的总结。*

[Nuke 时间调整(attempt 2)][review club 28956] 是 Niklas Gögge 提出的 PR，它修改了与区块时间戳相关的区块有效性检查。粗略地说，如果一个区块的时间戳（包含在其区块头中）在过去或将来太远，节点会拒绝该区块并视为无效。请注意，如果该区块由于其时间戳在将来太远而无效，它可以在以后变得有效（尽管链可能已经移动）。

{% include functions/details-list.md
  q0="<!--is-it-necessary-for-block-headers-to-have-a-timestamp-if-so-why-->区块头是否必要有时间戳？如果是，为什么？"
  a0="是的，时间戳用于难度调整和验证交易时间锁。"
  a0link="https://bitcoincore.reviews/28956#l-39"

  q1="<!--what-is-the-difference-between-median-time-past-mtp-and-network-adjusted-time-which-of-these-are-relevant-to-the-pr-->过去中位时间（MTP）和网络调整时间之间有什么区别？其中哪些与 PR 相关？"
  a1="MTP 是最近 11 个区块的中位时间，是区块时间戳有效性的下限。网络调整时间的计算方法是我们自己的节点的时间加上我们的时间与随机选择的 199 个出站对等节点之间的偏移量的中位数。（此中位数可以为负数）。网络调整时间加上 2 小时是最大有效区块时间戳。只有网络调整的时间与此 PR 相关。"
  a1link="https://bitcoincore.reviews/28956#l-67"

  q2="<!--why-are-these-times-conceptually-very-different-->为什么这些时间在概念上非常不同？"
  a2="MTP 是为同步到同一链的所有节点唯一定义的；在时间上有共识。网络调整后的时间可能因节点而异。"
  a2link="https://bitcoincore.reviews/28956#l-74"

  q3="<!--why-don-t-we-just-use-mtp-for-everything-and-scrap-network-adjusted-time-->为什么我们不直接完全使用 MTP 来替代网络调整时间呢？"
  a3="MTP 用作区块时间戳有效性的下限，但不能用作上限，因为未来的区块时间戳是未知的。"
  a3link="https://bitcoincore.reviews/28956#l-77"

  q4="<!--why-are-limits-enforced-on-how-far-off-a-block-header-s-timestamp-is-allowed-to-be-from-the-node-s-internal-clock-and-since-we-don-t-require-exact-agreement-on-time-can-these-limits-be-made-more-strict-->为什么对允许区块头的时间戳与节点内部时钟的\“相差\” 进行限制？既然我们不需要时间的精确一致，这些限制能否更加严格？"
  a4="区块时间戳范围受到限制，因此恶意节点操纵难度调整和时间锁的能力受到限制。这类攻击称为时间扭曲攻击。有效范围可以在一定程度上更严格，但过于严格可能会导致暂时的链分裂，因为某些节点可能会拒绝其他节点接受的区块。时间戳并不需要准确无误，但长期来看需要跟踪实际时间。"
  a4link="https://bitcoincore.reviews/28956#l-82"

  q5="<!--before-this-pr-why-would-an-attacker-try-to-manipulate-a-node-s-network-adjusted-time-->在此 PR 之前，为什么攻击者会试图操纵节点的网络调整时间？"
  a5="如果该节点是一个矿工，攻击者可能会试图让其挖出的区块被网络拒绝，或者让其不接受有效的区块，从而使其在旧的区块链上浪费算力（这两种情况都会给竞争对手矿工带来优势）；或者让被攻击的节点跟随错误的区块链；或者导致一个时间锁交易在本该被挖出的时间内没有被挖出；或者对闪电网络进行[时间膨胀攻击][time dilation attack]。"
  a5link="https://bitcoincore.reviews/28956#l-89"

  q6="<!--prior-to-this-pr-how-could-an-attacker-try-to-manipulate-a-node-s-network-adjusted-time-which-network-message-s-would-they-use-->在此 PR 之前，攻击者如何尝试操纵节点的网络调整时间？他们将使用哪种网络消息？"
  a6="攻击者需要从他们控制的多个对等节点向我们发送操纵了时间戳的版本消息。他们需要我们向他们的节点建立超过 50% 的出站连接，这很困难，但比完全遮蔽节点要容易得多。"
  a6link="https://bitcoincore.reviews/28956#l-100"

  q7="<!--this-pr-uses-the-node-s-local-clock-as-the-upper-bound-block-validation-time-rather-than-network-adjusted-time-can-we-be-sure-that-this-reduces-esoteric-attack-surfaces-rather-than-increasing-them-->这个 PR 使用节点的本地时钟作为区块验证时间的上限，而不是网络调整时间。我们能确定这减少了这鲜有人知的攻击面，而不是增加了它们吗?"
  a7="没有明确的结论，针对攻击者是否更容易影响节点的对等集或其内部时钟（例如使用恶意软件或 NTP 伪造）。但是大多数参与者都认为这个 PR 是一种改进。"
  a7link="https://bitcoincore.reviews/28956#l-102"

  q8="<!--does-this-pr-change-consensus-behavior-if-so-is-this-a-soft-fork-a-hard-fork-or-neither-why-->这个 PR 会改变共识行为吗？如果是这样，这是软分叉、硬分叉，还是两者都不是？为什么？"
  a8="因为共识规则不能考虑来自区块链之外的数据（比如每个节点自己的时钟），所以这个 PR 不能被认为是共识变更；这只是网络接受规则的更改。但这并不意味着它是可选的；制定一些策略规则来限制区块的时间戳在未来可以走多远，这对网络安全[至关重要][se timestamp accecptance]。"
  a8link="https://bitcoincore.reviews/28956#l-141"

  q9="<!--which-operations-were-relying-on-network-adjusted-time-prior-to-this-pr-->在此 PR 之前，哪些操作依赖于网络调整的时间？"
  a9="[`TestBlockValidity`][TestBlockValidity function]、[`CreateNewBlock`][CreateNewBlock function] (矿工用于构建区块模板) 和 [`CanDirectFetch`][CanDirectFetch function] (用于 P2P 层)。这些用途的多样性表明，PR 不仅影响区块有效性，还有其他含义，我们需要验证。"
  a9link="https://bitcoincore.reviews/28956#l-197"
%}

## 重大的代码和文档变更

*本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo] 和 [Bitcoin Inquisition][bitcoin inquisition repo]。*

- [LND #8308][] 将 `min_final_cltv_expiry_delta` 从 9 提高到 18，这是 BOLT 02 对终端付款的建议。此值会影响未提供 `min_final_cltv_expiry` 参数的外部发票。如上周的周报[所述][cln hotfix]，此更改修复了 CLN 在使用默认值 18 时停止包含参数后发现的互操作性问题。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1036,8308" %}
[poinsot v3]: https://delvingbitcoin.org/t/v3-transaction-policy-for-anti-pinning/340
[todd v3]: https://petertodd.org/2023/v3-transactions-review
[dlc cpfp]: https://github.com/discreetlogcontracts/dlcspecs/blob/master/Non-Interactive-Protocol.md
[news283 pinning]: /zh/newsletters/2024/01/03/#v3-transaction-pinning-costs-v3
[harding pinning]: https://delvingbitcoin.org/t/v3-transaction-policy-for-anti-pinning/340/22
[harding delays]: https://delvingbitcoin.org/t/v3-transaction-policy-for-anti-pinning/340/6
[harding stuckless]: https://delvingbitcoin.org/t/v3-transaction-policy-for-anti-pinning/340/5
[teinturier fees]: https://github.com/bitcoin/bitcoin/pull/28948#issuecomment-1873793179
[russell inline]: https://rusty.ozlabs.org/2024/01/08/txhash-tx-stacking.html
[sanders lns]: https://delvingbitcoin.org/t/ln-symmetry-project-recap/359
[poc lns]: https://github.com/instagibbs/lightning/tree/eltoo_support
[cln hotfix]: /zh/newsletters/2024/01/03/#core-lightning-6957
[review club 28956]: https://bitcoincore.reviews/28956
[time dilation attack]: /en/newsletters/2020/06/10/#time-dilation-attacks-against-ln
[se timestamp accecptance]: https://bitcoin.stackexchange.com/a/121251/97099
[TestBlockValidity function]: https://github.com/bitcoin/bitcoin/blob/063a8b83875997068b3eb506b5f30f2691d18052/src/validation.cpp#L4228
[CreateNewBlock function]: https://github.com/bitcoin/bitcoin/blob/063a8b83875997068b3eb506b5f30f2691d18052/src/node/miner.cpp#L106
[CanDirectFetch function]: https://github.com/bitcoin/bitcoin/blob/063a8b83875997068b3eb506b5f30f2691d18052/src/net_processing.cpp#L1314
