---
title: 'Bitcoin Optech 周报#345'
permalink: /zh/newsletters/2025/03/14/
name: 2025-03-14-newsletter-zh
slug: 2025-03-14-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报分析了典型全节点的 P2P 网络流量情况，总结了闪电网络路径查找的研究成果，并介绍了一种创建概率支付的新方法。此外还有我们的常规部分：其中包括 Bitcoin Core PR 审核俱乐部会议的总结、新版本和候选版本的公告，以及对热门比特币基础设施项目的重大变更介绍。

## 新闻

- **<!--p2p-traffic-analysis-->P2P 网络流量分析：** 开发者 Virtu 在 Delving Bitcoin 论坛[发布][virtu traffic]了他的节点在四种不同模式下的网络流量分析：初始区块下载（IBD）、非监听（仅出站连接）、非归档（已修剪）监听和归档监听模式。虽然他单个节点的结果可能并不具有普遍代表性，但我们发现他的几个发现很有意思：

  - *<!--high-block-traffic-as-an-archival-listening-node-->归档监听节点的高区块流量：* 当作为非修剪的监听节点运行时，Virtu 的节点每小时向其他节点提供了数 GB 的区块数据。许多区块是较旧的区块，被入站连接请求用于执行初始区块下载。

  - *<!--high-inv-traffic-as-a-non-archival-listener-->非归档监听节点的高 inv 消息流量：* 在启用旧区块服务之前，节点总流量的约 20% 是 `inv` 消息。[Erlay][topic erlay] 技术可能会显著减少这 20% 的开销，这相当于每天约 100MB 的数据量。

  - *<!--bulk-of-inbound-peers-appear-to-be-spy-nodes-->大部分入站对等节点似乎是监视节点：* “有趣的是，大部分入站对等节点与我的节点之间只交换了约 1MB 的流量，这个数值太低了（以我的出站连接流量为基准），不足以构成正常连接。这些节点只是完成 P2P 握手，礼貌地回复 ping 消息，除此之外，它们只是吸收我们的 `inv` 消息。”

  Virtu 的帖子包含了更多见解和多个图表，直观展示了他的节点经历的流量情况。

- **<!--research-into- single-path-ln-pathfinding-->单路径闪电网络路径查找研究：** Sindura Saraswathi 在 Delving Bitcoin 论坛[发布][saraswathi path]了她与 Christian Kümmerle 合作进行的[研究][sk path]，关于在闪电网络节点之间寻找最佳单一支付路径。她的帖子描述了 Core Lightning、Eclair、LDK 和 LND 当前使用的策略。研究者使用八个经过修改和未修改的闪电网络节点在模拟网络环境（基于实际网络的快照）中测试路径查找算法，评估的标准包括最高成功率、最低费用比率（最低成本）、最短总时间锁定（最坏情况的等待时间）和最短路径（最不可能导致支付卡住）。结果显示没有一种算法在所有情况下都优于其他算法，Saraswathi 建议实现提供更好的权重函数，让用户能够根据不同支付场景选择自己偏好的权衡（例如，对于小额面对面购买可能优先考虑高成功率，而对于几周后才到期的大额月度账单，可能更偏好低费用比率）。她还指出，“虽然超出了本研究的范围，但我们注意到本研究获得的见解也与[多路径支付][topic multipath payments]路径查找算法的未来改进相关。”

- **<!--probabilistic-payments-using-different-hash-functions-as-as-xor-function-->使用不同哈希函数作为异或函数的概率支付：** Robin Linus 在关于[概率支付][topic probabilistic payments]的 Delving Bitcoin 讨论中[回复][linus pp]了一个概念简单的脚本，允许双方各自承诺任意数量的熵值，之后可以揭示并进行异或运算，产生一个用于确定哪一方接收支付的值。使用（并稍微扩展）Linus 在帖子中的例子：

  * Alice 私下选择值 `1 0 0` 以及一个单独的随机数。Bob 私下选择值 `1 1 0` 以及另一个单独的随机数。

  * 双方依次对其随机数进行哈希处理，其值中的数字决定使用哪个哈希函数。当栈顶的值为 `0` 时，使用 `HASH160` 操作码；当值为 `1` 时，使用 `SHA256` 操作码。在 Alice 的情况下，她执行 `sha256(hash160(hash160(alice_nonce)))`；在 Bob 的情况下，他执行 `sha256(sha256(hash160(bob_nonce)))`。这为双方各自生成一个承诺，他们互相发送这些承诺，但不透露各自的值或随机数。

  * 承诺共享后，他们创建一个链上注资交易，其脚本将使用 `OP_IF` 验证输入，在不同的哈希函数之间选择，并允许其中一方领取付款。例如，如果他们两个异或值的总和为 0 或 1，Alice 收到资金；如果是 2 或 3，Bob 收到资金。合约还可能包含一个超时条款和一个节省空间的相互协议条款。

  * 在注资交易确认到足够深度后，Alice 和 Bob 向对方披露各自的值和随机数。`1 0 0` 和 `1 1 0` 的异或结果是 `0 1 0`，总和为 `1`，因此 Alice 可以领取付款。

## Bitcoin Core PR 审核俱乐部

*在这个月度部分，我们总结了 [Bitcoin Core PR 审核俱乐部][Bitcoin Core PR Review Club]会议，重点介绍了一些重要的问题和答案。单击下面的问题以查看会议答案的总结。*

[更严格地内部处理无效区块][review club 31405]是由 [mzumsande][gh mzumsande] 提出的 PR，它通过在区块被标记为无效时立即更新两个“非共识关键且计算成本高”的验证字段，从而提高了这些字段的正确性。在此 PR 之前，这些更新被延迟到后续事件以最小化资源使用。然而，自 [Bitcoin Core #25717][] 以来，攻击者需要投入更多工作才能利用这一点。

具体来说，这个 PR 确保 `ChainstateManager` 的 `m_best_header` 始终指向已知非有效的最大区块工作量头部，并且区块的 `BLOCK_FAILED_CHILD` `nStatus` 始终正确。

{% include functions/details-list.md
  q0="<!--which-purpose-s-does-chainstatemanager-m-best-header-serve-->`ChainstateManager::m_best_header` 有什么用途？"
  a0="`m_best_header` 代表节点迄今为止看到的最大工作量证明头部，它尚未被节点无效化，但也不能保证有效。它有许多用途，但主要用途是作为节点可以推进其最佳链的目标。其他用途包括提供当前时间的估计，以及在向对等节点请求缺失头部时估计最佳链的高度。更完整的概述可以在约 6 年前的 PR 请求 [Bitcoin Core #16974][] 中找到。"
  a0link="https://bitcoincore.reviews/31405#l-36"

  q1="<!--prior-to-this-pr-which-of-these-statements-are-true-if-any-1-a-cblockindex-with-an-invalid-predecessor-will-always-have-a-block-failed-child-nstatus-2-a-cblockindex-with-a-valid-predecessor-will-never-have-a-block-failed-child-nstatus-->在此 PR 之前，以下哪些陈述是正确的（如果有）？
  1）具有无效前置区块的 `CBlockIndex` 将始终具有 `BLOCK_FAILED_CHILD` `nStatus`。
  2）具有有效前置区块的 `CBlockIndex` 将永远不会具有 `BLOCK_FAILED_CHILD` `nStatus`"
  a1="陈述 1）是错误的，这正是此 PR 直接解决的问题。在此 PR 之前，`AcceptBlock()` 会将无效区块标记为无效，但出于性能考虑不会立即将其后代更新为无效。审核俱乐部参与者无法想到陈述 2）为假的情况。"
  a1link="https://bitcoincore.reviews/31405#l-68"

  q2="<!--one-of-the-goals-of-this-pr-is-to-ensure-m-best-header-and-the-nstatus-of-successors-of-an-invalid-block-are-always-correctly-set-which-functions-are-directly-responsible-for-updating-these-values-->此 PR 的目标之一是确保 `m_best_header` 和无效区块的后继者的 `nStatus` 始终正确设置。哪些函数直接负责更新这些值？"
  a2="`SetBlockFailureFlags()` 负责更新 `nStatus`。在正常操作中，`m_best_header` 最常通过 `AddToBlockIndex()` 中的输出参数设置，但也可以通过 `RecalculateBestHeader()` 计算和设置。"
  a2link="https://bitcoincore.reviews/31405#l-110"

  q3="<!--most-of-the-logic-in-commit-4100495-validation-in-invalidateblock-calculate-m-best-header-right-away-implements-finding-the-new-best-header-what-prevents-us-from-just-using-recalculatebestheader-here-->commit `4100495` 里的 `validation: in invalidateblock, calculate m_best_header right away` 中的大部分逻辑实现了查找新的最佳头部。是什么阻止我们在这里直接使用 `RecalculateBestHeader()`？"
  a3="`RecalculateBestHeader()` 遍历整个 `m_block_index`，这是一个计算成本高昂的操作。commit `4100495` 通过缓存并迭代一组具有高工作量证明头部的候选者来优化这一点。"
  a3link="https://bitcoincore.reviews/31405#l-114"

  q4="<!--would-we-still-need-the-cand-invalid-descendants-cache-if-we-were-able-to-iterate-forwards-i-e-away-from-the-genesis-block-over-the-block-tree-what-would-be-the-pros-and-cons-of-such-an-approach-compared-to-the-one-taken-in-this-pr-->如果我们能够在区块树上向前迭代（即远离创世区块），我们是否仍然需要 `cand_invalid_descendants` 缓存？与此 PR 采用的方法相比，这种方法的优缺点是什么？"
  a4="如果 `CBlockIndex` 对象持有对其所有后代的引用，我们就不需要遍历整个 `m_block_index` 来使后代无效，因此也不需要 `cand_invalid_descendants` 缓存。然而，这种方法有显著的缺点。首先，它会增加每个 `CBlockIndex` 对象的内存占用，它需要为整个 `m_block_index` 保持在内存中。其次，迭代逻辑仍然不简单，因为虽然每个 `CBlockIndex` 只有一个祖先，但它可能没有或有多个后代。"
  a4link="https://bitcoincore.reviews/31405#l-136"
%}

## 版本和候选版本

_热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。_

- [Eclair v0.12.0][] 是这个闪电网络节点的一个重要版本。它“增加了创建和管理 [BOLT12][] 报价的支持，以及支持 [手续费替换（RBF）][topic rbf] 的新通道关闭协议。[它]还增加了为对等节点存储少量数据支持的（[对等存储][topic peer storage]）”，以及其他改进和错误修复。发行说明提到，几个主要依赖项已更新，要求用户在部署新版本的 Eclair 之前进行这些更新。

## 重要的代码和文档变更

_本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIP][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]_

- [Bitcoin Core #31407][] 通过更新 `detached-sig-create.sh` 脚本，增加了对 macOS 应用程序包和二进制文件公证的支持。该脚本现在还能签署独立的 macOS 和 Windows 二进制文件。最近更新的 [signapple][] 工具被用于执行这些任务。

- [Eclair #3027][] 在生成 [BOLT12][topic offers] 要约时，通过引入 `routeBlindingPaths` 函数为[盲路径][topic rv routing]添加了路径查找功能，该函数使用仅支持盲路径的节点计算从选定的发起节点到接收节点的路径。然后将盲路径包含在发票中。

- [Eclair #3007][] 在 `channel_reestablish` 消息中添加了 `last_funding_locked` TLV 参数，以改善断开连接后通道[拼接][topic splicing]期间对等节点之间的同步。它修复了一个竞态条件，即节点在接收到 `channel_reestablish` 后但在 `splice_locked` 之前发送 `channel_update`，这对常规通道无害，但可能会扰乱需要对等节点之间交换随机数的[简单 Taproot 通道][topic simple taproot channels]。

- [Eclair #2976][] 通过引入 `createoffer` 命令，增加了无需额外插件创建[要约][topic offers]的支持，该命令接受描述、金额、以秒为单位的过期时间、发行者和 `blindedPathsFirstNodeId` 的可选参数，以定义[盲路径][topic rv routing]的发起节点。此外，这个 PR 引入了 `disableoffer` 和 `listoffers` 命令来管理现有报价。

- [LDK #3608][] 重新定义了 `CLTV_CLAIM_BUFFER`，使其代表确认交易所需的预期最大区块数的两倍，适应[锚点][topic anchor outputs]通道，其中 [HTLC][topic htlc] 认领交易被 1 个区块的 `OP_CHECKSEQUENCEVERIFY` (CSV) [时间锁][topic timelocks]延迟。之前，它被设置为单个最大确认期，这对于预锚点通道足够，在这些通道中，HTLC 认领交易与承诺交易一起广播。新增了 `MAX_BLOCKS_FOR_CONF` 常量作为基础值。

- [LDK #3624][] 通过对基础注资密钥应用标量调整以获取通道的 2-2 [多重签名][topic multisignature]密钥，实现了在成功进行通道[拼接][topic splicing]后的注资密钥的轮换。这允许节点从同一密钥派生额外的密钥。调整计算遵循 [BOLT3][] 规范，但用拼接资金 txid 替换 `per_commitment_point` 以确保唯一性，并使用 `revocation_basepoint` 限制派生仅限于通道参与者。

- [LDK #3016][] 通过引入 `xtest` 宏，增加了对外部项目运行功能测试和替换签名者等组件的支持。它包括一个 `MutGlobal` 实用程序和一个 `DynSigner` 结构来支持动态测试组件如签名者，在 `_externalize_tests` 特性标志下公开这些测试，并提供一个 `TestSignerFactory` 用于创建动态签名者。

- [LDK #3629][] 改进了无法归因或解释的远程失败的日志记录，以提供对这些边缘情况的更多可见性。这个 PR 修改了 `onion_utils.rs` 以记录可能扰乱发送者操作的不可归因失败，并引入了一个 `decrypt_failure_onion_error_packet` 函数用于解密处理。它还修复了一个错误，即使用有效基于哈希的消息认证码 (HMAC) 的不可读失败未正确归因于节点。这可能与允许支付者避免使用宣传[高可用性][news342 qos]但转发支付却失败的节点有关。

- [BDK #1838][] 通过向 `SyncRequest` 和 `FullScanRequest` 添加强制性的 `sync_time`，将此 `sync_time` 应用为未确认交易的 `seen_at` 属性，同时允许非规范（参见周报 [#335][news335 noncanonical]）交易排除 `seen_at` 时间戳，改进了全扫描和同步流程的清晰度。它将 `TxUpdate::seen_ats` 更新为 (Txid, u64) 的 `HashSet`，以支持每个交易的多个 `seen_at` 时间戳，并将 `TxGraph` 更改为非详尽，以及其他变更。

{% include snippets/recap-ad.md when="2025-03-18 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31407,3027,3007,2976,3608,3624,3016,3629,1838,16974,25717" %}
[virtu traffic]: https://delvingbitcoin.org/t/bitcoin-node-p2p-traffic-analysis/1490/
[saraswathi path]: https://delvingbitcoin.org/t/an-exposition-of-pathfinding-strategies-within-lightning-network-clients/1500
[sk path]: https://arxiv.org/pdf/2410.13784
[linus pp]: https://delvingbitcoin.org/t/emulating-op-rand/1409/10
[eclair v0.12.0]: https://github.com/ACINQ/eclair/releases/tag/v0.12.0
[review club 31405]: https://bitcoincore.reviews/31405
[gh mzumsande]: https://github.com/mzumsande
[signapple]: https://github.com/achow101/signapple
[news335 noncanonical]: /zh/newsletters/2025/01/03/#bdk-1670
[news342 qos]: /zh/newsletters/2025/02/21/#continued-discussion-about-an-ln-quality-of-service-flag
