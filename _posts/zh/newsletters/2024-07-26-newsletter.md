---
title: 'Bitcoin Optech Newsletter #313'
permalink: /zh/newsletters/2024/07/26/
name: 2024-07-26-newsletter-zh
slug: 2024-07-26-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的新闻部分总结了一场关于 Bitcoin Core 中的 “免费转发” 行为以及手续费追究法升级的广泛讨论。此外是我们的常规部分：来自 Bitcoin Stack Exchange 的热门问题和答案，软件新版本和候选版本的公告，还有热门的比特币基础设施项目的重大升级介绍。

## 新闻

- **<!--varied-discussion-of-free-relay-and-fee-bumping-upgrades-->关于免费转发和手续费追加法更新的广泛讨论**：Peter Todd 在 Bitcoin-Dev 邮件组中[发帖][todd fr-rbf]列出了他此前[尽责披露][topic responsible disclosures]给 Bitcoin Core 开发者的免费转发攻击总结。这引出了覆盖多个问题和拟议优化的纠缠讨论。部分议题总结如下：

  - *<!--free-relay-attacks-->免费转发攻击*：[免费转发][topic free relay]指的是一个全节点帮助转发未确认的交易时，其交易池内的手续费收益增幅低于节点转发交易的费率门槛值（默认是 1 聪/vbyte）。免费转发通常会消耗一些内存，所以技术上来说不是免费的，但这个代价远远低于诚实用户为转发支付的代价。

    免费转发允许攻击者大大增加参与交易转发全节点的带宽使用量，这可能会减少转发节点的数量。如果独立运营的转发节点的数量变得太少，交易者等于是直接把交易提交给矿工，这就跟 “[暗中支付手续费][topic out-of-band fees]” 一样会带来中心化风险。

    Todd 介绍的供给利用了矿工与用户的交易池规则差异。许多矿工倾向于开启 [full-RBF][topic rbf]，但 Bitcoin Core 并不默认开启（见[周报 #263][news263 full-rbf]）。这允许攻击者制作一笔交易的不同版本，使它们在 full-RBF 的矿工和非 full-RBF 的转发节点处得到不同待遇。转发节点可能最终会转发一笔交易的多个版本，但这些版本的确认机会都很小，这就浪费了带宽。

    免费转发攻击不能让攻击者偷盗其他用户的资金，虽然一次突然的或长期持续的攻击可能会被用来分裂网络、让其它类型的攻击更容易发动。就我们所知，破坏性的免费转发攻击还没有出现过。

  - *<!--free-relay-and-replacebyfeerate-->免费转发与手续费率替换*：Peter Todd 之前提出过两种形式的 “手续费率替换（RBFR）”；详见[周报 #288][news288 rbfr]。对 RBFR 的一种批评是，它会带来免费转发。而相似量级的免费转发已经可以通过他本周介绍的攻击发送，因此他主张，对免费转发的顾虑不应阻塞添加一种可以缓解[交易钉死攻击][topic transaction pinning]的有用特性。

    一个[回复][harding rbfr fundamental]指出，因 RBFR 而成为可能的免费转发是根植于 RBFR 的设计的，而 Bitcoin Core 设计中的其它免费转发问题是可以缓解的。Todd [不同意][todd unsolvable]。

  - *<!--truc-utility-->* *TRUC 的用途*：Peter Todd 声称 “确认前拓扑受限的（[TRUC][topic v3 transaction relay]）” 交易是一个 “糟糕的提议”。他此前批评过这个协议（详见[周报 #283][news283 truc pin]）并具体批评 TRUC 的规范 [BIP431][] 利用对免费转发的顾虑来支持 TRUC、反对他的 RBFR 提议。

    然而，BIP431 也出于别的理由反对 RBFR 的版本，例如 Todd 的一次性 RBFR，依赖于替代交易支付了足够高的手续费、使自身能成为接下来几个区块中最利于挖掘的交易之一，也就是进入交易池最顶部。Todd 和其他人都同意，在 Bitcoin Core 开始实现 “[族群交易池][topic cluster mempool]” 之后，这会被变得简单很多，但 Todd 依旧建议使用当前即可用的其它方法。TRUC 不需要关于交易池顶部区域的信息，所以不依赖于族群交易池或替代方案。

    这种角度的批评的长篇形式在[周报 #288][news288 rbfr] 中得到了总结，而后续研究（总结见[周报 #290][news290 rbf]）表明，不管什么交易替换规则，想要总是作出能够提升挖矿利得的选择有多么难。相比于 RBFR，TRUC 并不改变 Bitcoin Core 的替换规则（除了总是允许考虑 TRUC 交易的替换交易），所以它应该不会让任何现有的替换交易激励兼容性问题恶化。

  - *<!--path-to-cluster-mempool-->通往族群交易池的路径*：如[周报 #285][news285 cluster cpfp-co] 所属，[族群交易池][topic cluster mempool]提议需要禁用 [CPFP carve-out][topic cpfp carve out]（CPFP-CO），而这是当前闪电通道的 “[锚点输出][topic anchor outputs]” 用来保护支付通道内的大额资金的方法。在结合 “[交易包转发][topic package relay]”（具体来说是交易包的手续费替换）时，一次性的 RBFR 也许可以替代 CPFP-CO，而不要求闪电通道软件作任何变更（只要它们已经会不断 RBF 以为花费锚点输出的交易追加手续费）。但是，一次性的 RBFR 依赖于从别的东西（比如族群交易池）那里了解交易池顶部曲语的手续费率，所以 RBFR 和族群交易池将需要跟族群交易池（或替代方法）同时部署，以确定交易池顶部的费率。

    相比之下，TRUC 也提供了一种到 CPFP-CO 的替代，不过这是一个可选的特性。所有的闪电通道软件都需要升级到支持 TRUC、所有现存的通道都需要执行一次 “[通道承诺交易形式升级][topic channel commitment upgrades]”。这可能会花费大量时间，而且直到有强烈证据表明所有闪电网络用户都已经升级之前，都无法禁用 CPFP-CO。在 CPFP-CO 禁用之前，族群交易池无法安全地广泛部署。

    如之前的 Optech 周报 [周报 #286][news286 imbued]、[周报 #287][news287 sibling] 和 [周报 #289][news289 imbued] 所述，TRUC 缓慢采用与族群交易池迫切需要之间的矛盾可以通过 “*渗透式 TRUC*” 来解决，该提议的想法是在锚点闪电通道上自动应用 TRUC 和 “[亲属交易驱逐][topic kindred rbf]”。多位闪电网络开发者和渗透式 TRUC 提议的贡献者[表示][teinurier hacky]，他们[倾向于][daftuar prefer not]避免这个结果 —— 显式升级到 TRUC 在许多方面都更好，而且闪电网络开发者开发通道升级机制还有其它理由 —— 不过，如果族群交易池的开发进度超过了闪电通道升级机制的进度，也许渗透式 TRUC 会被再次考虑。

    虽然渗透式 TRUC 和主动式 TRUC 的广泛采用都可以禁用 CPFP-CO，并因此让族群交易池的部署成为可能，但两种 TRUC 都不依赖于族群交易池，也不依赖于其它计算交易激励兼容性的新方法。这让 TRUC 比 RBFR 更容易在独立于族群交易池的情境下分析。

  截至本刊撰写之时，邮件组中的讨论还在继续。

## Bitcoin Stack Exchange 的精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者们寻找疑惑解答的首选之地 —— 也是他们有闲暇时会帮助好奇和困惑用户的地方。在这个月度栏目中，我们会举出自上次出刊以来出现的一些高票的问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--why-is-restructure-of-mempool-required-with-cluster-mempool-->为什么要使用族群交易池结构重新构造交易池？]({{bse}}123682) Murch 解释了 Bitcoin Core 当前的交易池数据结构中的问题、族群交易池结构如何解决这些问题，以及[族群交易池][topic cluster mempool]可以如何部署到 Bitcoin Core 中。

- [<!--defaultmaxpeerconnections-for-bitcoin-core-is-125-or-130-->Bitcoin Core 的默认最大对等节点连接数量是 125 还是 130？]({{bse}}123645) Lightlike 澄清了虽然自动的对等节点连接的数量上限是 125 个，节点运营者可以另外手动添加最多 8 个连接。

- [<!--why-do-protocol-developers-work-on-maximizing-miner-revenue-->为什么协议开发者要开发最大化矿工收益的交易池策略？]({{bse}}123679) David A. Harding 列出了可以预测哪笔交易会进入下一个区块的几个优势（通过假设矿工会最大化手续费收益），他指出：“这让花费者可以估计合理的手续费率，让志愿服务的转发节点可以用最少的带宽和内存来提供服务，并且让小体量的分散矿工可以赚到跟大体量的矿工相当的手续费收益。”

- [<!--is-there-an-economic-incentive-to-use-p2wsh-over-p2tr-->会有 P2WSH 的经济性会有超过 P2TR 的情况吗？]({{bse}}123500) Vojtěch Strnad 指出，虽然在某些用法下 P2WSH 输出可能比 P2TR 输出更便宜，但在 P2WSH 的绝大部分用法（比如多签名和闪电通道）中，使用 [taproot][topic taproot] 来隐藏未使用的脚本路径以及使用 [schnorr 签名][topic schnorr signatures] 的公钥聚合方案（比如 [MuSig2][topic musig] 和 FROST）可以获得更便宜的手续费。

- [<!--how-many-blocks-per-second-can-sustainably-be-created-using-a-time-warp-attack-->使用时间扭曲攻击的时候，可以持续以何种速度创建区块？]({{bse}}123698) Murch 计算得出，在 “[时间扭曲攻击][topic time warp]” 的环境下，“攻击者可以维持每秒产生 6 个区块的速度而不会导致难度提高。”

- [<!--pkh-nested-in-tr-is-allowed-->可以在 tr() 中嵌入 pkh() 吗？]({{bse}}123568) Pieter Wuille 指出，根据 [BIP386][]“tr() 输出脚本描述符”，在 `tr()` 中嵌入 `pkh()` 并非有效的描述符，但在 [BIP379][]“Miniscirpt” 下，这样的构造是可以允许的，所以具体要看应用开发者决定遵循那一个 BIP。

- [<!--can-a-block-more-than-a-week-old-be-considered-a-valid-chain-tip-->时间戳是一周以前的区块可以被当作有效的链顶端吗？]({{bse}}123671) Murch 的结论是，这样的链顶端也可以被认为是有效的，但只要链顶端的时间戳停留在节点本地时间的 24 小时以前，节点就会保持在 “初始化区块下载” 的状态下。

- [<!--sighashanyonecanpay-mediated-tx-modification-->SIGHASH_ANYONECANPAY 接入交易的修改]({{bse}}123429) Murch 解释了在链上众筹中使用 `SIGHASH_ALL | SIGHASH_ANYONECANPAY` 的挑战，以及 [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] 可以带来什么帮助。

- [<!--why-does-rbf-rule-3-exist-->为什么 RBF 规则#3 会存在？]({{bse}}123595) Antoine Poinsot 确认 [RBF][topic rbf] 规则 #4（替代交易必须支付超过原版交易绝对手续费的额外手续费）比规则 #3（替代交易支付的绝对手续费应大于等于被替代的原版交易的手续费之和）更强，并指出，在文档中出现两条相似的规则是因为代码中的两种独立检查。

## 新版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [BDK 1.0.0-beta.1][] 是“具备稳定 1.0.0 API 的 `bkd_wallet` 第一个 beta 版本” 的一个候选版本。

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Bitcoin Core #30320][] 升级了 “[assumeUTXO][topic assumeutxo]” 的动作，以避免加载并非当前最佳区块头 `m_best_header` 的上游的快照，并转为常规同步模式。如果该快照后续又因为链重组而成为最佳区块头的上游，则 assumeUTXO 快照加载会恢复。

- [Bitcoin Core #29523][] 为交易注资 RPC 命令 `fundrawtransaction` 、`walletcreatefundedpsbt` 和`send` 添加了一个 `max_tx_weight` 选项。这保证了最终交易的重量不会超过指定的限制，对未来的 [RBF][topic rbf] 尝试或具体的交易协议可能有好处。如果不设，则 `MAX_STANDARD_TX_WEIGHT`  的 40 0000 重量单位（10 0000 vbyte）会被用作默认值。

- [Core Lightning #7461][] 开始支持节点自我申领和自我支付 [BOLT12 offers][topic offers] 和发票，这可能会简化在后台调用 CLN 的账户管理代码，如[周报 #262][cln self-pay] 所述。这项 PR 也允许节点支付一个发票，即使节点自身正是相关[盲化路径][topic rv routing]的末端。此外，未公开（没有[unannounced channels][topic unannounced channels]）的节点现在可以通过自动添加一条盲化路径来创建 offer，只需将盲化路径的最后一跳设为某个通道对等节点即可。

- [Eclair #2881][] 移除了对新进入（incoming）的 `static_remote_key` 通道的支持，同时维持对现有此类通道以及新的此类发出（outgoing）通道的支持。节点应该转向使用[锚点输出][topic anchor outputs]，因为进入的 `static_remote_key` 新通道被认为是过时的了。


{% include references.md %}
{% include linkers/issues.md v=2 issues="30320,29523,7461,2881" %}
[BDK 1.0.0-beta.1]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.1
[news263 full-rbf]: /zh/newsletters/2023/08/09/#full-rbf-by-default
[news288 rbfr]: /zh/newsletters/2024/02/07/#proposal-for-replace-by-feerate-to-escape-pinning
[news283 truc pin]: /zh/newsletters/2024/01/03/#v3-transaction-pinning-costs-v3
[news288 rbfr]: /zh/newsletters/2024/02/07/#proposal-for-replace-by-feerate-to-escape-pinning
[news290 rbf]: /zh/newsletters/2024/02/21/#pure-replace-by-feerate-doesn-t-guarantee-incentive-compatibility
[news285 cluster cpfp-co]: /zh/newsletters/2024/01/17/#cpfp-carve-out
[news286 imbued]: /zh/newsletters/2024/01/24/#imbued-v3-logic-v3
[news287 sibling]: /zh/newsletters/2024/01/31/#kindred-replace-by-fee
[news289 imbued]: /zh/newsletters/2024/02/14/#what-would-have-happened-if-v3-semantics-had-been-applied-to-anchor-outputs-a-year-ago-v3
[todd fr-rbf]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Zpk7EYgmlgPP3Y9D@petertodd.org/
[harding rbfr fundamental]: https://mailing-list.bitcoindevs.xyz/bitcoindev/d57a02a84e756dbda03161c9034b9231@dtrt.org/
[todd unsolvable]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Zp1utYduhnWf4oA4@petertodd.org/
[teinurier hacky]: https://github.com/bitcoin/bitcoin/issues/29319#issuecomment-1968709925
[daftuar prefer not]: https://github.com/bitcoin/bitcoin/issues/29319#issuecomment-1968709925
[cln self-pay]: /zh/newsletters/2023/08/02/#core-lightning-6399
