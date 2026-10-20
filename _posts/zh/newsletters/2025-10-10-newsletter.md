---
title: 'Bitcoin Optech Newsletter #375'
permalink: /zh/newsletters/2025/10/10/
name: 2025-10-10-newsletter-zh
slug: 2025-10-10-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报描述了关于阈值签名在可用性和安全性之间权衡的研究，总结了一种将嵌套阈值签名转换为单层签名组的方法，并探讨了在限制性规则集下可以在 UTXO 集中嵌入数据的程度。此外还包括我们的常规部分：总结 Bitcoin Core PR 审核俱乐部会议、新版本和候选版本的公告，以及对热门比特币基础设施项目的重大变更的介绍。

## 新闻

- **<!--optimal-threshold-signatures-->最优阈值签名：** Sindura Saraswathi 在 Delving Bitcoin 上[发布][sindura post]了由她和 Korok Ray 共同撰写的研究，关于确定[多重签名][topic multisignature]方案的最优阈值。在这项研究中，探讨了可用性和安全性的参数，以及它们的关系以及如何影响用户应该选择的阈值。通过定义 p(τ) 和 q(τ) 并将它们组合成闭式解，他们绘制了安全性和可用性之间的差距图表。

  Saraswathi 还探讨了降级[阈值签名][topic threshold signature]的使用，其中早期阶段使用更高的阈值，在后期阶段逐渐下降。这意味着随着时间的推移，攻击者获得更多访问权限来获取资金。她还表示，使用 [taproot][topic taproot]，可能通过 taptree 和更复杂的合约（包括[时间锁][topic timelocks]和多重签名）解锁这些新的可能性。

- **<!--flattening-certain-nested-threshold-signatures-->扁平化某些嵌套阈值签名：** ZmnSCPxj 在 Delving Bitcoin 上[发布][zmnscpxj flat]了关于如何避免在某些尚未被证明安全的情况下使用嵌套 [schnorr 签名][topic schnorr signatures]的描述。例如，Alice 可能想要与由 Bob、Carol 和 Dan 组成的团体签订合约。任何交易都必须得到 Alice 和 Bob、Carol、Dan 中至少两人的批准。理论上，这可以通过[多重签名][topic multisignature]（例如 [MuSig][topic musig]）来完成，其中 Alice 提供一个部分签名，[阈值签名][topic threshold signature]（例如 FROST）用于从 Bob、Carol 和 Dan 生成部分签名。然而，ZmnSCPxj 写道“目前，我们没有证明 FROST-in-MuSig 是安全的”。相反，ZmnSCPxj 指出这个例子可以仅使用阈值签名来满足：Alice 被给予多个份额————以足以让她阻止法定人数，但不足以让她单方面签名；其他签名者每人被给予一个份额。

  描述的用途包括多运营商状态链、想要使用多个签名设备的闪电网络用户，以及 ZmnSCPxj 的 LSP 增强[冗余超额支付][topic redundant overpayments]提案（参见[周报 #372][news372 lspover]）。

- **<!--theoretical-limitations-on-embedding-data-in-the-utxo-set-->在 UTXO 集中嵌入数据的理论限制：** Adam "Waxwing" Gibson 在邮件列表上开始了一个[讨论][gibson embed]，关于在比特币交易的限制性规则集下可以在 UTXO 集中嵌入数据的程度。Gibson 描述为“令人震惊的糟糕”的主要新规则是要求每个 [P2TR][topic taproot] 输出都必须伴有一个签名来证明该输出可以被花费。Gibson 试图证明只有三种方式可以规避该规则以允许任意数据伪装成公钥：

  1. 比特币版本的 [schnorr 签名][topic schnorr signatures]被破坏，例如基于错误的假设。这显然目前不是情况。

  2. 通过穷举筛选公钥可以嵌入少量任意数据（即生成许多不同的私钥，为每个私钥推导相应的公钥，并丢弃所有公钥不包含以可提取方式编码的所需任意数据的私钥）。要以这种方式在 UTXO 集中包含 _n_ 位任意数据，需要大约 2<sup>n</sup> 次暴力操作，这对于超过几十位（每个输出几个字节）是不切实际的。

  3. 使用可以被第三方轻易计算的私钥，这是一种“泄露私钥”的形式。

  在第三种情况下，泄露私钥可能允许第三方花费输出，从而将输出从 UTXO 集中移除。然而，该帖子的几个回复指出了在像比特币这样的复杂系统中可能规避这种情况的方法。Anthony Towns 的[回复][towns embed]补充说，“一旦你以有趣的方式使系统可编程，我认为你几乎立即获得数据可嵌入性，然后只是在最优编码率与你的交易可识别程度之间进行权衡的问题。强制数据以降低效率为代价隐藏只会使其他系统用户可用的资源减少，这在任何方面都不像是胜利。

## Bitcoin Core PR 审核俱乐部

*在这个月度栏目中，我们总结最近的 [Bitcoin Core PR Review Club][] 会议，重点介绍一些重要的问题和答案。点击下面的问题查看会议答案的总结。*

[Compact block harness][review club 33300] 是 [Crypt-iQ][gh crypt-iq] 的 PR，通过为[致密区块中继][topic compact block relay]逻辑添加测试工具来增加[模糊测试][fuzz readme]覆盖率。模糊测试是一种向代码提供准随机输入以发现错误和意外行为的测试技术。

该 PR 还引入了一个新的仅测试 `-fuzzcopydatadir` 启动选项，以提高测试工具的运行时性能。


{% include functions/details-list.md
  q0="<!--the-fuzz-test-sends-sendcmpct-messages-with-high-bandwidth-randomly-set-how-many-high-bandwidth-peers-are-allowed-and-does-the-fuzz-harness-test-this-limit-more-generally-why-would-a-peer-choose-to-be-high-or-low-bandwidth-->模糊测试发送随机设置 `high_bandwidth` 的 `SENDCMPCT` 消息。允许多少个高带宽对等节点，模糊工具是否测试此限制？更一般地说，为什么对等节点会选择高带宽或低带宽？"
  a0="对于高带宽对等节点，致密区块在验证完成之前就被转发而无需公告。这大大提高了区块传播速度。为了减少带宽开销，节点只选择最多 3 个对等节点以高带宽模式发送致密区块。这种模式没有被 `cmpctblock` 模糊目标专门测试。"
  a0link="https://bitcoincore.reviews/33300#l-66"
  q1="<!--look-at-create-block-in-the-harness-how-many-transactions-do-the-generated-blocks-contain-and-where-do-they-come-from-what-compact-block-scenarios-might-be-missed-with-only-a-few-transactions-in-a-block-->查看工具中的 `create_block`。生成的区块包含多少交易，它们来自哪里？只有区块中几个交易可能会错过哪些致密区块场景？"
  a1="生成的区块包含 1-3 个交易：一个 coinbase 交易（始终存在）、可选的来自交易池的交易，以及可选的非交易池交易。由于区块限制为少量交易，一些场景可能被遗漏，例如测试短 ID 冲突处理，这在许多交易时变得更有可能。审核俱乐部参与者建议增加交易计数以改善覆盖率。"
  a1link="https://bitcoincore.reviews/33300#l-132"
  q2="<!--commit-ed813c4-review-club-ed813c4-sorts-m-dirty-blockindex-by-block-hash-instead-of-pointer-address-what-non-determinism-does-this-fix-the-author-notes-q1-note-this-slows-production-code-for-no-production-benefit-why-can-t-enablefuzzdeterminism-code-enablefuzzdeterminism-be-used-here-how-do-you-think-this-non-determinism-should-be-best-handled-if-not-the-way-the-pr-currently-does-->提交 [ed813c4][review-club ed813c4] 按区块哈希而不是指针地址对 `m_dirty_blockindex` 进行排序。这修复了什么非确定性？作者[注意到][q1 note]这减慢了生产代码而没有生产效益。为什么这里不能使用 [`EnableFuzzDeterminism()`][code enablefuzzdeterminism]？你认为这种非确定性应该如何最好地处理（如果不是 PR 当前的方式）？"
  a2="`m_dirty_blockindex` 集合按指针内存地址排序，这在运行之间不同，导致非确定性行为。修复通过使用区块哈希而不是指针地址提供确定性排序顺序。像 `EnableFuzzDeterminism()` 这样的运行时解决方案不能使用，因为 `std::set` 的比较器是其类型的编译时属性，不能在运行时切换。因为这种非确定性影响执行路径，它误导模糊器对每次插入集合的代码覆盖率分析。PR 作者建议 [afl-fuzz 白皮书][afl fuzz] 作为关于模糊测试中覆盖率反馈如何工作的推荐进一步阅读。"
  a2link="https://bitcoincore.reviews/33300#l-147"%}

## 版本和候选版本

*热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Bitcoin Inquisition 29.1][] 是这个为实验提议的软分叉和其他主要协议变更而设计的 [signet][topic signet] 全节点的发布版本。它包括 Bitcoin Core 29.1 中引入的新[最低中继费用默认值][topic default minimum transaction relay feerates]（0.1 sat/vb）、Bitcoin Core 30.0 中预期的更大 `datacarrier` 限制、对 `OP_INTERNALKEY` 的支持（参见周报 [#285][news285 internal] 和 [#332][news332 internal]），以及支持新软分叉的新内部基础设施。

## 重大的代码和文档变更

*本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Bitcoin Core #33453][] 取消了对 `datacarrier` 和 `datacarriersize` 配置选项的弃用，因为许多用户希望继续使用这些选项，弃用计划不明确，移除弃用的负面影响很小。关于此主题的更多背景，请参见周报 [#352][news352 data] 和 [#358][news358 data]。

- [Bitcoin Core #33504][] 在区块重组期间跳过 [TRUC][topic v3 transaction relay] 检查的执行，即使确认的交易重新进入交易池时违反 TRUC 拓扑约束。以前，执行这些检查会错误地排除许多交易。

- [Core Lightning #8563][] 延迟删除旧的 [HTLC][topic htlc]，直到节点重启，而不是在通道关闭和遗忘时删除它们。这通过避免暂停所有其他 CLN 进程的不必要暂停来提高性能。此 PR 还更新了 `listhtlcs` RPC 以排除来自已关闭通道的 HTLC。

- [Core Lightning #8523][] 移除了之前在 `decode` RPC 和 `onion_message_recv` 钩子上弃用和禁用的 `blinding` 字段，因为它已被 `first_path_key` 替换。`experimental-quiesce` 和 `experimental-offers` 选项也被移除，因为这些功能现在是默认的。

- [Core Lightning #8398][] 向实验性的 [BOLT12][]循环[要约][topic offers]添加了 `cancelrecurringinvoice` RPC 命令，允许付款方向接收方发出信号停止期待来自该系列的进一步发票请求。还进行了几项其他更新以与 [BOLTs #1240][] 中的最新规范变更保持一致。

- [LDK #4120][] 在[通道拼接][topic splicing]协商在签名阶段之前失败时清除交互式资金状态，如果对等节点断开连接或发送 `tx_abort`，允许干净地重试拼接。如果在对等节点开始交换 `tx_signatures` 后收到 `tx_abort`，LDK 将其视为协议错误并关闭通道。

- [LND #10254][] 弃用对 [Tor][topic anonymity networks] v2 洋葱服务的支持，这将在下一个 0.21.0 版本中被移除。配置选项 `tor.v2` 现在被隐藏；用户应该使用 Tor v3。


{% include snippets/recap-ad.md when="2025-10-14 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33453,33504,8563,8523,8398,4120,10254,1240" %}
[sindura post]: https://delvingbitcoin.org/t/optimal-threshold-signatures-in-bitcoin/2023
[Bitcoin Inquisition 29.1]: https://github.com/bitcoin-inquisition/bitcoin/releases/tag/v29.1-inq
[news285 internal]: /zh/newsletters/2024/01/17/#lnhance
[news332 internal]: /zh/newsletters/2024/12/06/#bips-1534
[news352 data]: /zh/newsletters/2025/05/02/#increasing-or-removing-bitcoin-core-s-op-return-size-limit
[news358 data]: /zh/newsletters/2025/06/13/#bitcoin-core-32406
[review club 33300]: https://bitcoincore.reviews/33300
[gh crypt-iq]: https://github.com/crypt-iq
[fuzz readme]: https://github.com/bitcoin/bitcoin/blob/master/doc/fuzzing.md
[review-club ed813c4]: https://github.com/bitcoin-core-review-club/bitcoin/commit/ed813c48f826d083becf93c741b483774c850c86
[q1 note]: https://github.com/bitcoin/bitcoin/pull/33300#issuecomment-3308381089
[code enablefuzzdeterminism]: https://github.com/bitcoin/bitcoin/blob/acc7f2a433b131597124ba0fbbe9952c4d36a872/src/util/check.h#L34
[afl fuzz]: https://lcamtuf.coredump.cx/afl/technical_details.txt
[zmnscpxj flat]: https://delvingbitcoin.org/t/flattening-nested-2-of-2-of-a-1-of-1-and-a-k-of-n/2018
[news372 lspover]: /zh/newsletters/2025/09/19/#lsp-funded-redundant-overpayments
[gibson embed]: https://gnusha.org/pi/bitcoindev/0f6c92cc-e922-4d9f-9fdf-69384dcc4086n@googlegroups.com/
[towns embed]: https://gnusha.org/pi/bitcoindev/aOXyvGaKfe7bqTXv@erisian.com.au/
