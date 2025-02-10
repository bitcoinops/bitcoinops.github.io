---
title: 'Bitcoin Optech Newsletter #339'
permalink: /zh/newsletters/2025/01/31/
name: 2025-01-31-newsletter-zh
slug: 2025-01-31-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报描述了一个影响旧版本 LDK 的漏洞，介绍了最初于 2023 年发布的一个漏洞（替代循环攻击）的新披露，并总结了关于致密区块重建统计数据的新讨论。还包括我们的常规部分：Bitcoin Stack Exchange 的精选问答的总结、新版本和候选版本的公告，以及对热门比特币基础设施项目的重大变更介绍。

## 新闻

- **<!--vulnerability-in-ldk-claim-processing-->****LDK 认领过程中的漏洞：** Matt Morehouse 在 Delving Bitcoin 上[发布了][morehouse ldkclaim]一篇帖子，披露了一个影响 LDK 的漏洞，他[负责任地公开了][topic responsible disclosures]该漏洞，并在 LDK 版本 0.1 中修复了该漏洞。当一个通道在存在多个待处理[HTLCs][topic htlc]的情况下被单方面关闭时，LDK 会尝试在同一笔交易中尽可能解决尽多的 HTLC，以节省交易费用。然而，如果通道对方能够首先确认其中任何一个批量处理的 HTLC，这将与批量交易发生_冲突_并使其无效。在这种情况下，LDK 会正确地创建一个更新后的批量交易，将冲突移除。不幸的是，如果对方的交易与多个单独的批次发生冲突，LDK 会错误地只更新第一个批次，剩余的批次将无法确认。

  节点必须在截止日期之前处理其 HTLC，否则对手方可能会窃取他们的资金。[时间锁][topic timelocks]阻止对手方在双方各自的截止日期之前花费 HTLC。大多数旧版本的 LDK 会将这些 HTLC 放入单独的批次中，并确保在对方能够确认冲突的交易之前确认该批次，从而确保没有资金会被盗走。对于那些没有允许资金被盗，但对方可以立即处理的 HTLC，存在对方可能会使资金被卡住的风险。Morehouse 写道，可以通过“升级到 LDK 版本 0.1 并重放导致锁定的承诺和 HTLC 交易序列来修复此问题”。

  然而，候选版本 LDK 0.1-beta 更改了其逻辑(见[周报#335][news335 ldk3340])，并开始将所有类型的 HTLC 一起批量处理，这可能允许攻击者使用带有时间锁的 HTLC 创建冲突。如果该 HTLC 的处理在时间锁定到期后仍然被卡住，则可能发生资金被盗的情况。升级到 LDK 0.1 的正式版本也修复了此类漏洞。

  Morehouse 的帖子提供了更多细节，并讨论了防止未来发生类似根本原因漏洞的可能方法。

- **<!--replacement-cycling-attacks-with-miner-exploitation-->替代循环攻击与被矿工利用：** Antoine Riard 在 Bitcoin-Dev 邮件列表上[发布了][riard minecycle]一个额外的漏洞，可能与他在 2023 年最初公开披露的[替代循环攻击][topic replacement cycling]相关(见[周报#274][news274 cycle])。简而言之：

  1. Bob 广播一笔支付给 Mallory（以及可能其他人的）交易。

  2. Mallory [钉死了][topic transaction pinning] Bob 的交易。

  3. Bob 没意识到自己被钉死，并进行费用提升(使用 [RBF][topic rbf] 或者 [CPFP][topic cpfp])。

  4. 由于 Bob 的原始交易被钉死，他的费用提升并没有传播出去。然而，Mallory 以某种方式收到了这笔费用提升。步骤 3 和 4 可能会多次重复，从而大大增加 Bob 的费用。

  5. Mallory 挖出 Bob 的最高费用提升，因为没有其他人尝试挖出这笔交易（因为它没有传播）。这使得 Mallory 能够赚取比其他矿工更多的费用。

  6. 现在，Mallory 可以使用替代循环攻击将她的交易钉死移到另一笔交易，并重复该攻击（可能涉及不同的受害者），无需分配额外的资金，从而使攻击在经济上更加高效。

  我们认为该漏洞并不构成重大风险。利用该漏洞需要特定的条件，这些条件可能是稀有的，而且如果攻击者对网络条件的判断不准确，可能会导致他们亏损。如果攻击者定期利用该漏洞，我们认为社区成员通过构建和使用[区块监测工具][miningpool.observer]会发现这种行为。

- **<!--updated-stats-on-compact-block-reconstruction-->关于致密区块重建的更新统计：** 继之前的讨论后(见[周报#315][news315 cb])，开发者 0xB10C 在 Delving Bitcoin 上[发布了][b10c cb]更新的统计数据，展示了他的 Bitcoin Core 节点在执行[致密区块][topic compact block relay]重建时需要请求额外交易的频率。当一个节点收到致密区块时，节点必须请求该块在其交易池尚未拥有的交易(或其_扩展池_，这是一个旨在帮助致密区块重建的特殊预留池)。这显著地减慢了块传播速度，并导致了矿工的集中化。

  0xB10C 发现，随着交易池的大小增加，请求频率显著上升。几位开发者讨论了可能的原因，初步数据表明，缺失的交易是孤儿交易——即父交易未知的子交易，Bitcoin Core 仅暂时存储它们，以防其父交易在短时间内到达。近期合并到 Bitcoin Core 的改进(见[周报#338][news338 orphan])能够更好地跟踪和请求孤儿交易的父交易，可能有助于改善这种情况。

  开发者们还讨论了其他可能的解决方案。由于攻击者可以免费创建孤儿交易，节点不可能长时间保存这些交易，但可能可以将更多的孤儿交易和其他被逐出的交易在扩展池中保存更长时间。讨论在写作时尚未得出结论。

## Bitcoin Stack Exchange 的精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 的贡献者们寻找答案的首选之地，也是他们有闲暇时会给好奇和困惑的用户帮忙的地方。在这个月度栏目中，我们会列举自上次出刊以来出现的一些高票的问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--who-uses-or-wants-to-use-psbtv2-bip370-->谁使用或想要使用 PSBTv2（BIP370）？]({{bse}}125384)
  除了在 Bitcoin-Dev 邮件列表上发布(见[周报#338][news338 psbtv2])，Sjors Provoost 还在 Bitcoin Stack Exchange 上发布了帖子，寻找[PSBTv2][topic psbt]的用户和潜在用户。对[BIP370][]感兴趣的 Optech 读者可以回复该问题或邮件列表帖子。

- [<!--in-the-bitcoin-s-block-genesis-which-parts-can-be-filled-arbitrarily-->在比特币创世区块中，哪些部分可以随意填写？]({{bse}}125274)
  Pieter Wuille 指出，比特币[创世区块][mempool genesis block]的任何字段都不受常规区块验证规则的限制，他说：“这些字段字面上可以包含任何内容。它看起来像一个正常的区块，但它并不需要是这样。”

- [<!--lightning-force-close-detection-->闪电网络强制关闭交易的检测]({{bse}}122504)
  Sanket1729 和 Antoine Poinsot 讨论了 mempool.space [区块浏览器][topic block explorers]如何利用 [`nLockTime`][topic timelocks] 和 `nSequence` 字段来判断一笔交易是否是闪电网络强制关闭交易。

- [<!--is-a-segwit-formatted-transaction-with-all-inputs-of-non-witness-program-type-valid-->一个所有输入都属于非见证程序类型的隔离见证格式交易有效吗？]({{bse}}125240)
  Pieter Wuille 区分了[BIP141][]与[BIP144][]，前者规定了与 SegWit 共识变化和 wtxid 计算相关的结构和有效性，后者规定了用于传输 SegWit 交易的序列化格式。

- [<!--p2tr-security-question-->P2TR 安全性问题]({{bse}}125334)
  Pieter Wuille 引用了 [BIP341][] 中指定 [taproot][topic taproot] 的内容，以解释为什么公钥直接包含在输出中，以及有关量子计算相关的考虑。

- [<!--what-exactly-is-being-done-today-to-make-bitcoin-quantum-safe-->今天在做什么来让比特币变得“量子安全”？]({{bse}}125171)
  Murch 评论了量子能力的当前状态、最近的[后量子签名方案][topic quantum resistance]，以及提议的[QuBit - Pay to Quantum Resistant Hash][BIPs #1670] BIP。

- [<!--what-are-the-harmful-effects-of-a-shorter-inter-block-time-->较短的区块间时间会带来什么有害影响？]({{bse}}125318)
  Pieter Wuille 强调了一个由于区块传播时间而产生的优势，它被传递给刚刚找到区块的矿工，这种优势在更短的区块时间下会被放大，以及该优势可能带来的影响。

- [<!--could-proof-of-work-be-used-to-replace-policy-rules-->工作量证明是否可以用来替代交易池规则？]({{bse}}124931)
  Jgmontoya 想知道，如果将工作量证明附加到非标准交易上，是否可以实现与交易池规则相似的[节点资源保护][policy series]目标。Antoine Poinsot 指出，交易池规则除了保护节点资源之外，还有其他目标，包括高效的区块模板构建、阻止某些交易类型，以及保护[软分叉][topic soft fork activation]升级挂钩。

- [<!--how-does-musig-work-in-real-bitcoin-scenarios-->MuSig 如何在真实的比特币场景中工作？]({{bse}}125030)
  Pieter Wuille 阐述了不同版本的 [MuSig][topic musig] 之间的区别，提到 MuSig1 的交互式聚合签名（IAS）变种及其与[跨输入签名聚合（CISA）][topic cisa]的相互作用，并在回答关于规范的低层次问题之前提到了[门限签名][topic threshold signature]。

- [<!--how-does-the-blocksxor-switch-that-obfuscates-the-blocks-dat-files-work-->-blocksxor 开关如何使 blocks.dat 文件混淆？]({{bse}}125055)
  Vojtěch Strnad 描述了用于混淆 Bitcoin Core 区块数据文件的 `-blocksxor` 选项(见[周报#316][news316 xor])。

- [<!--how-does-the-related-key-attack-on-schnorr-signatures-work-->关联密钥攻击如何作用于 Schnorr 签名？]({{bse}}125328)
  Pieter Wuille 回答说：“当受害者选择一个关联密钥且攻击者知道该关系时，攻击就会发生”，并且关联密钥是非常常见的。

## 版本和候选版本

_热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。_

- [LDK v0.1.1][] 是该热门库的安全版本用于构建支持 LN（闪电网络）的应用程序。攻击者如果愿意牺牲至少 1% 的通道资金，就可以诱骗受害者关闭其他不相关的通道，这可能会导致受害者不必要地花费交易手续费。发现该漏洞的 Matt Morehouse 已在 Delving Bitcoin 上[发布了][morehouse ldk-dos]相关信息；Optech 将在下周的周报中提供更详细的总结。此次版本还包括 API 更新和错误修复。

## 重大的代码和文档变更

_本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition
repo] 和 [BINANAs][binana repo]。_

- [Bitcoin Core #31376][] 扩展了一项检查机制，以防止矿工创建利用 [时间扭曲漏洞（timewarp bug）][topic time warp]的区块模板，此检查机制现在适用于所有网络，而不仅仅是[testnet4][topic testnet]。此更改是为未来可能进行的 软分叉（soft fork）做准备，该软分叉将永久修复时间扭曲漏洞。

- [Bitcoin Core #31583][] 更新了 `getmininginfo`、`getblock`、`getblockheader`、`getblockchaininfo` 和 `getchainstates` RPC 命令，使其现在返回 `nBits` 字段（区块难度目标的紧凑表示）和 `target` 字段。此外，`getmininginfo` 现在新增了一个 `next` 对象，该对象包含下一个区块的高度、`nBits`、难度（difficulty）和目标（target）。为了计算和获取 target，此 PR 引入了 `DeriveTarget()` 和 `GetTarget()` 辅助函数。这些更改对于 [Stratum V2][topic pooled mining]的实现非常有用。

- [Bitcoin Core #31590][] 重构了 `GetPrivKey()` 方法，以便在检索[描述符][topic descriptors]中[x-only 公钥][topic x-only public keys]的私钥时，同时检查公钥的两个奇偶位（parity bit）值。在此之前，如果存储的公钥没有正确的奇偶位，则无法检索到相应的私钥，也无法对交易进行签名。

- [Eclair #2982][] 引入了 `lock-utxos-during-funding` 配置设置，允许[流动性广告][topic liquidity advertisements]卖家缓解一种流动性滥用攻击，这种攻击可能会导致诚实用户长时间无法使用自己的 UTXO。该设置的默认值为 true，即在注资过程中 UTXO 会被锁定，这可能使其容易受到滥用。如果设置为 false，则禁用 UTXO 锁定，可以完全防止此类攻击，但可能会对诚实的对等方产生负面影响。此外，该 PR 还添加了可配置的超时机制，如果对等方变得无响应，则会自动中止流入的通道。

- [BDK #1614][] 增加了对 [BIP158][] 规范的[致密区块过滤器（compact block filters）][topic compact block filters]的支持，用于下载已确认的交易。具体实现方式是向 `bdk_bitcoind_rpc` 添加一个 BIP158 模块，同时引入了一个新的 `FilterIter` 类型，该类型可用于检索包含与给定脚本公钥（script pubkeys）相关交易的区块。

- [BOLTs #1110][] 合并了[对等存储协议][topic peer storage]的规范，该协议允许节点存储最多 64kB 的加密数据块，以供请求存储的对等方使用，并可对此服务收取费用。此协议已在 Core Lightning (见周报[#238][news238 peer]) 和 Eclair (见周报[#335][news335 peer])中实现。


{% include references.md %}
{% include linkers/issues.md v=2 issues="31376,31583,31590,2982,1614,1110,1670" %}
[morehouse ldkclaim]: https://delvingbitcoin.org/t/disclosure-ldk-invalid-claims-liquidity-griefing/1400
[news335 ldk3340]: /zh/newsletters/2025/01/03/#ldk-3340
[riard minecycle]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CALZpt+EnDUtfty3X=u2-2c5Q53Guc6aRdx0Z4D75D50ZXjsu2A@mail.gmail.com/
[miningpool.observer]: https://miningpool.observer/template-and-block
[b10c cb]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/5
[news315 cb]: /zh/newsletters/2024/08/09/#statistics-on-compact-block-reconstruction
[news338 orphan]: /zh/newsletters/2025/01/24/#bitcoin-core-31397
[news274 cycle]: /zh/newsletters/2023/10/25/#replacement-cycling-vulnerability-against-htlcs-htlcs
[ldk v0.1.1]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.1
[morehouse ldk-dos]: https://delvingbitcoin.org/t/disclosure-ldk-duplicate-htlc-force-close-griefing/1410
[news281 griefing]: /zh/newsletters/2023/12/13/#discussion-about-griefing-liquidity-ads
[news238 peer]: /zh/newsletters/2023/02/15/#core-lightning-5361
[news335 peer]: /zh/newsletters/2025/01/03/#eclair-2888
[news338 psbtv2]: /zh/newsletters/2025/01/24/#psbtv2-integration-testing
[mempool genesis block]: https://mempool.space/block/000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f
[policy series]: /zh/blog/waiting-for-confirmation/#用于保护节点资源的规则
[news316 xor]: /zh/newsletters/2024/08/16/#bitcoin-core-28052
