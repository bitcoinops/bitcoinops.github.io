---
title: 'Bitcoin Optech Newsletter #358'
permalink: /zh/newsletters/2025/06/13/
name: 2025-06-13-newsletter-zh
slug: 2025-06-13-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报描述了如何计算自私挖矿的危险阈值，总结了一个关于防止过滤高手续费率交易的想法，寻求对 BIP390 `musig()` 描述符的拟议变更的反馈，并宣布了一个用于加密描述符的新库。此外还包括我们的常规栏目：Bitcoin Core PR 审查俱乐部的总结、新版本和候选版本的公告，以及对热门比特币基础设施项目近期变更的描述。

## 新闻

- **<!--calculating-the-selfish-mining-danger-threshold-->计算自私挖矿的危险阈值：** Antoine Poinsot 在 Delving Bitcoin 上[发帖][poinsot selfish]，扩展了 2013 年[论文][es selfish]中的数学内容。该论文使[自私挖矿攻击][topic selfish mining]得以命名（尽管该攻击在 2010 年就[被描述过][bytecoin selfish]）。Antoine 还提供了一个简化的挖矿和区块传播[模拟器][darosior/miningsimulation]，允许对该攻击进行实验。他专注于重现 2013 年论文的一个结论：控制总网络算力 33% 的不诚实矿工（或联系紧密的矿工卡特尔），在没有额外优势的情况下，可以在长期基础上比总计控制 67% 算力的其他单打独斗的矿工获得边际更高的利润。这是通过 33% 矿工选择性地延迟宣布其发现的一些新区块来实现的。随着不诚实矿工的算力增加到 33% 以上，它变得更加有利可图，直到超过 50% 算力，其可以阻止竞争对手在最佳区块链上留下任何新区块。

  我们没有仔细审查 Poinsot 的帖子，但他的方法对我们来说似乎是合理的，我们建议任何有兴趣验证数学或更好地理解它的人阅读。

- **<!--relay-censorship-resistance-through-top-mempool-set-reconciliation-->通过头部交易池集合协调实现中继的抗审查性：** Peter Todd 在 Bitcoin-Dev 邮件列表中[发布][todd feerec]了一个机制，该机制将允许节点断开过滤高手续费率交易的对等节点。该机制依赖于[族群交易池][topic cluster mempool]和集合协调机制，如 [erlay][topic erlay] 使用的机制。节点将使用[族群交易池][topic cluster mempool]来计算其最有利可图的未确认交易集合，这些交易可以适合（例如）8,000,000 权重单位（最大 8 MB）。节点的每个对等节点也会计算其前 8 MWU 的未确认交易。使用高效的算法，如 [minisketch][topic minisketch]，节点将与其每个对等节点协调其交易集合。这样做时，它将确切地了解每个对等节点在其交易池顶部拥有哪些交易。然后节点将定期断开与平均交易池利润最低的对等节点。

  通过断开利润最低的对等节点，节点最终会找到最不可能过滤掉高手续费率交易的对等节点。Todd 提到，他希望在与族群交易池支持合并到 Bitcoin Core 后在其实现上继续工作。他将这个想法归功于 Gregory Maxwell 和其他人；Optech 在[周报 #9][news9 reconcile]中首次提到了该基本想法。

- **<!--updating-bip390-to-allow-duplicate-participant-keys-in-musig-expressions-->****更新 BIP390 以允许在 `musig()` 表达式中重复参与者密钥：** Ava Chow 在 Bitcoin-Dev 邮件列表中[发布][chow dupsig]询问是否有人反对更新 [BIP390][] 以允许[输出脚本描述符][topic descriptors]中的 `musig()` 表达式包含同一参与者公钥多次。这将简化实现，并且 [BIP327][] 的 [MuSig2][topic musig] 规范明确允许。截至本文撰写时，没有人反对，Chow 已经打开了一个[拉取请求][bips #1867]来更改 BIP390 规范。

- **<!--descriptor-encryption-library-->描述符加密库：** Josh Doman 在 Delving Bitcoin 上[发布][doman descrypt]宣布了他构建的一个库，该库将[输出脚本描述符][topic descriptors]或 [miniscript][topic miniscript] 的敏感部分加密到其中包含的公钥。他描述了解密所需的信息：

  > - 如果你的钱包需要 2-of-3 密钥来花费，它将需要恰好 2-of-3 密钥来解密。
  >
  > - 如果你的钱包使用复杂的 miniscript 策略，如“要么 2 个密钥，要么（时间锁和另一个密钥）”，加密遵循相同的结构，就好像所有时间锁和哈希锁都满足一样。

  这与[周报 #351][news351 salvacrypt]中讨论的加密描述符备份方案不同，在该方案中，了解描述符中包含的任何公钥都允许解密描述符。Doman 认为，他的方案为加密描述符备份到公共或半公共源（如区块链）的情况提供了更好的隐私性。

## Bitcoin Core PR 审查俱乐部

*在这个月度栏目中，我们总结最近的 [Bitcoin Core PR 审查俱乐部][Bitcoin Core PR Review
Club]会议，高亮了一些重要的问题和答案。点击下面的问题查看会议中答案的摘要。*

[分离 UTXO 集合访问与验证函数][review club 32317]是由 [TheCharlatan][gh thecharlatan] 提出的 PR，它允许通过仅传递所需的 UTXO 来调用验证函数，而不是要求完整的 UTXO 集合。这是 [`bitcoinkernel` 项目][Bitcoin Core #27587]的一部分，是使库对不实现 UTXO 集合的完整节点实现（如 [Utreexo][topic utreexo] 或 [SwiftSync][somsen swiftsync] 节点（参见[周报 #349][news349 swiftsync]））更可用的重要步骤。

在前 4 个提交中，此 PR 通过要求调用者首先获取他们需要的 `Coin`s 或 `CTxOut`s 并将这些传递给验证函数，而不是让验证函数直接访问 UTXO 集合，减少了交易验证函数与 UTXO 集合之间的耦合。

在后续提交中，通过将需要 UTXO 集合交互的剩余逻辑分离到单独的 `SpendBlock()` 方法中，完全移除了 `ConnectBlock()` 对 UTXO 集合的依赖。

{% include functions/details-list.md
  q0="<!--why-is-carving-out-the-new-spendblock-function-from-connectblock-helpful-for-this-pr-how-would-you-compare-the-purpose-of-the-two-functions-->为什么从 `ConnectBlock()` 中分离出新的 `SpendBlock()` 函数对这个 PR 有帮助？你会如何比较这两个函数的用途？"
  a0="`ConnectBlock()` 函数最初执行区块验证和 UTXO 集合修改。这次重构分离了这些职责：`ConnectBlock()` 现在只负责不需要 UTXO 集合的验证逻辑，而新的 `SpendBlock()` 函数处理所有 UTXO 集合交互。这允许调用者使用 `ConnectBlock()` 在没有 UTXO 集合的情况下进行区块验证。"
  a0link="https://bitcoincore.reviews/32317#l-37"

  q1="<!--do-you-see-another-benefit-of-this-decoupling-besides-allowing-kernel-usage-without-a-utxo-set-->除了允许在没有 UTXO 集合的情况下使用内核之外，你看到这种解耦的另一个好处吗？"
  a1="除了为没有 UTXO 集合的项目启用内核使用外，这种解耦使代码更容易独立测试和更简单维护。一位审查者还指出，移除对 UTXO 集合访问的需求为并行验证区块打开了大门，这是 SwiftSync 的重要功能。"
  a1link="https://bitcoincore.reviews/32317#l-64"

  q2="<!--spendblock-takes-a-cblock-block-cblockindex-pindex-and-uint256-block-hash-parameter-all-referencing-the-block-being-spent-why-do-we-need-3-parameters-to-do-that-->`SpendBlock()` 接受 `CBlock block`、`CBlockIndex pindex` 和 `uint256 block_hash` 参数，都引用被花费的区块。为什么我们需要 3 个参数来做这件事？"
  a2="验证代码是性能关键的，它影响重要参数，如区块传播速度。从 `CBlock` 或 `CBlockIndex` 计算区块哈希不是免费的，因为该值没有被缓存。因此，作者决定通过传递已经计算的 `block_hash` 作为单独参数来优先考虑性能。类似地，`pindex` 可以从区块索引获取，但这将涉及额外的映射查找，这不是严格必要的。
  <br>_注意：作者后来[改变了][32317 updated approach]方法，移除了 `block_hash` 性能优化。_"
  a2link="https://bitcoincore.reviews/32317#l-97"

  q3="<!--the-first-commits-in-this-pr-refactor-ccoinsviewcache-out-of-the-function-signature-of-a-couple-of-validation-functions-does-ccoinsviewcache-hold-the-entire-utxo-set-why-is-that-not-a-problem-does-this-pr-change-that-behaviour-->此 PR 中的前几个提交将 `CCoinsViewCache` 从几个验证函数的函数签名中重构出来。`CCoinsViewCache` 是否持有整个 UTXO 集合？为什么这（不）是一个问题？这个 PR 是否改变了这种行为？"
  a3="`CCoinsViewCache` 不持有整个 UTXO 集合；它是一个内存缓存，位于 `CCoinsViewDB` 前面，后者在磁盘上存储完整的 UTXO 集合。如果请求的币不在缓存中，就必须从磁盘获取。此 PR 本身不改变这种缓存行为。通过从函数签名中移除 `CCoinsViewCache`，它使 UTXO 依赖变得明确，要求调用者在调用验证函数之前获取币。"
  a3link="https://bitcoincore.reviews/32317#l-116"
%}

## 发布和候选版本

*热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Core Lightning 25.05rc1][] 是这个热门闪电网络节点实现的下一个主要版本的候选版本。

- [LND 0.19.1-beta][] 是这个热门闪电网络节点实现的维护版本。它[包含][lnd rn]多个错误修复。

## 显著的代码和文档变更

*[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案 (BIPs)][bips repo]、[闪电网络 BOLTs][bolts repo]、[闪电网络 BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期显著变更。*

- [Bitcoin Core #32406][] 取消了 `OP_RETURN` 输出大小限制（标准性规则），将默认 `-datacarriersize` 设置从 83 字节提高到 100,000 字节（最大交易大小限制）。`-datacarrier` 和 `-datacarriersize` 选项仍然存在，但被标记为已弃用，预计在未确定的未来版本中被移除。此外，此 PR 还取消了一笔交易只允许一个 OP_RETURN 输出的转发限制，现在交易中的所有此类输出共享同一个大小限制。有关此变更的更多关联内容，请参见[周报 #352][news352 opreturn]。

- [LDK #3793][] 添加了一个新的 `start_batch` 消息，向对等节点发出信号，将接下来的 `n`（`batch_size`）个消息作为单个逻辑单元处理。它还更新了 `PeerManager` 以在[拼接][topic splicing]期间依赖于此来处理 `commitment_signed` 消息，而不是向批次中的每个消息添加 TLV 和 `batch_size` 字段。这是尝试允许额外的闪电网络协议消息被批处理，而不仅仅是 `commitment_signed` 消息（它是闪电网络规范中定义的唯一批处理）。

- [LDK #3792][] 引入了对 [v3 承诺交易][topic v3 commitments]（参见[周报 #325][news325 v3]）的初始支持，这些交易依赖于 [TRUC 交易][topic v3 transaction relay] 和[临时锚点][topic ephemeral anchors]；此特性需要在启动时设置测试标签才能动用。节点现在拒绝任何设置非零手续费率的 `open_channel` 提议，确保它自己永远不会发起这样的通道，并停止自动接受 v3 通道以首先为后续手续费追加保留 UTXO。该 PR 还将每通道 [HTLC][topic htlc] 限制从 483 降低到 114，因为 TRUC 交易必须保持在 10 kvB 以下。

- [LND #9127][] 为 `lncli addinvoice` 命令添加了 `--blinded_path_incoming_channel_list` 选项，允许接收者嵌入一个或多个（用于多跳）首选通道 ID，供付款人尝试在[盲路径][topic rv routing]上转发。

- [LND #9858][] 开始为 [RBF][topic rbf] 合作式关闭流程（参见[周报 #347][news347 rbf]）发出生产功能位 61 信号，以正确启用与 Eclair 的互操作性。它保留了暂存位 161 以维持与测试该功能的节点的互操作性。

- [BOLTs #1243][] 更新了 [BOLT11][] 规范，指出如果强制字段（如 p（支付哈希）、h（描述哈希）或 s（秘密））长度不正确，读取者（发送者）不得支付发票。以前，节点可以忽略这个问题。此 PR 还在示例部分添加了一个注释：规范不强制执行 [Low R 签名][topic low-r grinding]，尽管它可以节省一个字节的空间。

{% include snippets/recap-ad.md when="2025-06-17 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32406,3793,3792,9127,1867,9858,1243,27587" %}
[Core Lightning 25.05rc1]: https://github.com/ElementsProject/lightning/releases/tag/v25.05rc1
[lnd 0.19.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.1-beta
[poinsot selfish]: https://delvingbitcoin.org/t/where-does-the-33-33-threshold-for-selfish-mining-come-from/1757
[bytecoin selfish]: https://bitcointalk.org/index.php?topic=2227.msg30083#msg30083
[darosior/miningsimulation]: https://github.com/darosior/miningsimulation
[todd feerec]: https://mailing-list.bitcoindevs.xyz/bitcoindev/aDWfDI03I-Rakopb@petertodd.org/
[news9 reconcile]: /zh/newsletters/2018/08/21/#bandwidth-efficient-set-reconciliation-protocol-for-transactions
[chow dupsig]: https://mailing-list.bitcoindevs.xyz/bitcoindev/08dbeffd-64ec-4ade-b297-6d2cbeb5401c@achow101.com/
[doman descrypt]: https://delvingbitcoin.org/t/rust-descriptor-encrypt-encrypt-any-descriptor-such-that-only-authorized-spenders-can-decrypt/1750/
[news351 salvacrypt]: /zh/newsletters/2025/04/25/#standardized-backup-for-wallet-descriptors
[es selfish]: https://arxiv.org/pdf/1311.0243
[lnd rn]: https://github.com/lightningnetwork/lnd/blob/v0.19.1-beta/docs/release-notes/release-notes-0.19.1.md
[news352 opreturn]: /zh/newsletters/2025/05/02/#increasing-or-removing-bitcoin-core-s-op-return-size-limit
[news325 v3]: /zh/newsletters/2024/10/18/#version-3-commitment-transactions
[news347 rbf]: /zh/newsletters/2025/03/28/#lnd-8453
[review club 32317]: https://bitcoincore.reviews/32317
[gh thecharlatan]: https://github.com/TheCharlatan
[somsen swiftsync]: https://gist.github.com/RubenSomsen/a61a37d14182ccd78760e477c78133cd
[32317 updated approach]: https://github.com/bitcoin/bitcoin/pull/32317#issuecomment-2883841466
[news349 swiftsync]: /zh/newsletters/2025/04/11/#swiftsync-speedup-for-initial-block-download-swiftsync
