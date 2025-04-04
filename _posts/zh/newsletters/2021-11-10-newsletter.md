---
title: 'Bitcoin Optech Newsletter #174'
permalink: /zh/newsletters/2021/11/10/
name: 2021-11-10-newsletter-zh
slug: 2021-11-10-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周 Newsletter 总结了一篇关于如何将谨慎日志合约（DLC）与闪电网络通道整合的帖子、近期闪电网络开发者会议的详细总结链接，并描述了关于如何对致密区块过滤器进行额外验证的想法。此外还包括常规栏目：Bitcoin Core PR 审查俱乐部会议总结、关于准备 taproot 激活的最终专栏、新版本与候选版本描述，以及热门基础设施软件的重大变更列表。

## 新闻

- ​**<!--dlcs-over-ln-->****闪电网络上实现 DLC：** Thibaut Le Guilly 在 DLC-Dev 邮件列表上发起了一个[讨论][leguilly thread]，主题是将[谨慎日志合约（DLCs）][topic dlc]与闪电网络（LN）整合。初始帖子描述了几种在直接 LN 对等节点（例如共同运营通道的 Alice 和 Bob）之间的交易中嵌入 DLC 的可能方案。帖子还讨论了在通过 LN 网络路由的 DLC 中创建所面临的挑战。*

- ​**<!--ln-summit-2021-notes-->****2021 年闪电网络峰会纪要：** Olaoluwa Osuntokun [发布][osuntokun summary]了近期苏黎世线上线下混合举行的闪电网络开发者会议的详尽总结。纪要内容包括关于在 LN 中使用 [taproot][topic taproot] 的讨论，涉及 [PTLCs][topic ptlc]、用于[多签][topic multisignature]的 [MuSig2][topic musig] 以及 [eltoo][topic eltoo]；将规范讨论从 IRC 迁移至视频会议；当前 BOLTs 规范模型的变更；洋葱消息与[报价][topic offers]；无卡支付（见[周报 #53][news53 stuckless]）；[通道阻塞攻击][topic channel jamming attacks]及多种缓解措施；以及[蹦床路由][topic trampoline payments]。*

- ​**<!--additional-compact-block-filter-verification-->****致密区块过滤器的额外验证：** [Neutrino][] 轻客户端包含了一种启发式方法，用于检测[致密区块过滤器][topic compact block filters]是否可能包含错误数据。该方法曾错误地报告了一个包含 taproot 交易的测试网区块的正确过滤器存在问题。该问题已在 Neutrino 源代码中[修复][neutrino #234]，其他致密区块过滤器实现不受影响。但 Olaoluwa Osuntokun 在 [Bitcoin-Dev][bd cbf thread] 和 [LND-Dev][ld cbf thread] 邮件列表上发起讨论，提出了未来可能的改进方向：*

  - ​**<!--new-filters-->****新型过滤器：** 创建额外的可选过滤器类型，允许轻客户端搜索其他类型的数据。

  - ​**<!--new-p2p-protocol-message-->****新增 P2P 协议消息：** 添加新的 P2P 协议消息以获取区块撤销数据。区块撤销数据包含每个区块输入所花费的先前输出（及相关信息），结合区块数据可完整验证过滤器的生成过程。在节点间数据不一致时，撤销数据本身可被[验证][harding undo verification]。

  - ​**<!--multi-block-filters-->****多区块过滤器：** 进一步减少轻客户端需下载的数据量。

  - ​**<!--committed-block-filters-->****承诺的区块过滤器：** 要求矿工对其区块的过滤器进行承诺，减少轻客户端需下载的数据量以监测不同节点提供的过滤器差异。

## Bitcoin Core PR 审查俱乐部

*在本月栏目中，我们总结近期一次 [Bitcoin Core PR 审查俱乐部][Bitcoin Core PR Review Club]会议，重点呈现部分重要问答。点击下方问题查看会议讨论摘要。*

[添加 `ChainstateManager::ProcessTransaction`][review club #23173] 是 John Newbery 提出的拉取请求，旨在新增 `ChainstateManager::ProcessTransaction()` 接口函数，负责将交易作为候选加入内存池并执行内存池一致性检查。审查俱乐部讨论了当前向内存池添加交易的接口。

{% include functions/details-list.md
  q0="​**<!--q0-->**什么是 `cs_main`？为何如此命名？"
  a0="`cs_main` 是一个互斥锁，用于同步多线程对验证状态的访问。实际上，它也保护了非验证数据（包括 P2P 逻辑使用的数据）。多位贡献者希望减少 `cs_main` 的使用范围。该变量在验证功能位于 main.cpp 文件时命名，前缀 `cs` 代表临界区（critical section）。"
  a0link="https://bitcoincore.reviews/23173#l-45"

  q1="​**<!--q1-->**当前哪些组件调用 `AcceptToMemoryPool`？哪些调用来自外部客户端代码，哪些来自验证内部？"
  a1="排除测试中的调用，共有四个调用点：
  1. 节点启动时，从 mempool.dat [加载][atmp disk] 交易并调用 ATMP 重新验证交易以恢复内存池内容。此为内部验证调用。
  2. 从 P2P 网络接收的交易通过 ATMP [验证并提交][atmp p2p] 至内存池。此调用源自验证外部的组件。
  3. 重组期间，断开区块中存在但未包含在新链尖的交易通过 ATMP [重新提交][atmp reorg] 至内存池。此为内部验证调用。
  4. RPC（如 `sendrawtransaction`）和钱包（如 `sendtoaddress`）等客户端通过 [`BroadcastTransaction()`][atmp client] 调用 ATMP 提交交易。`testmempoolaccept` RPC 也会调用 ATMP 并设置 `test_accept` 为 `true`。这些属于外部组件的调用。"
  a1link="https://bitcoincore.reviews/23173#l-80"

  q2="​**<!--q2-->**`CTxMemPool::check()` 的作用是什么？调用该函数是谁的职责？"
  a2="`CTxMemPool::check()` 检查所有交易输入是否对应可用 UTXO，并执行内存池内部一致性检查。例如，统计每笔交易的祖先和后裔数量以确保缓存的 `ancestorsize`、`ancestorcount` 等值准确。当前 ATMP 调用者需负责在之后调用 `check()`。但与会者认为应由 `ChainstateManager` 负责执行其内部一致性检查。"
  a2link="https://bitcoincore.reviews/23173#l-122"

  q3="​**<!--n3-->**`bypass_limits` 参数的作用是什么？在哪些情况下 ATMP 会设置该参数为 true？"
  a3="当 `bypass_limits` 为 true 时，内存池最大容量和最低费率限制将被忽略。例如，若内存池已满且动态最低费率为 3 sat/vB，单笔 1 sat/vB 费率的交易仍可能被接受。在[重组][atmp bypass limits]期间会以 `bypass_limits` 调用 ATMP；这些交易可能单独费率低但后裔费率高。重新加入内存池的交易总大小限制为 `MAX_DISCONNECTED_TX_POOL_SIZE`（20 MB）。"
  a3link="https://bitcoincore.reviews/23173#l-132"
%}

## 准备 Taproot #21：感谢！

*关于开发者和服务提供商如何为区块高度 {{site.trb}} 激活 taproot 做准备的系列[文章][series preparing for taproot]的最终篇。*

{% include specials/taproot/zh/21-thanks.md %}

## 发布与候选发布

*热门比特币基础设施项目的新版本发布。请考虑升级至新版本或协助测试候选版本。*

- [BTCPay Server 1.3.3][] 是一个包含关键安全补丁的版本（此前一天另有发布），修复共享服务器上同时共享 LN 节点的实例问题。还包括次要功能和其他错误修复。

- [Rust-Lightning 0.0.103][] 新增 `InvoicePayer` API，支持在部分路径失败时重试支付。

- [C-Lightning 0.10.2][] 修复了[不经济输出安全问题][news170 unec bug]，缩小了数据库体积，并提升了 `pay` 命令的有效性（见 [Decker 推文][decker tweet]）。

- [LND 0.13.4-beta][] 是维护版本，修复了上述 *新闻* 部分描述的 Neutrino 问题。发布说明指出：“若在生产环境使用 Neutrino，强烈建议在 taproot 激活前升级至此版本以确保节点持续同步。”

- [LND 0.14.0-beta.rc3][] 是候选版本，包含额外的[日蚀攻击][topic eclipse attacks]防护（见[周报 #164][news164 ping]）、远程数据库支持（[周报 #157][news157 db]）、更快路径查找（[周报 #170][news170 path]）、Lightning Pool 用户改进（[周报 #172][news172 pool]）以及可重复使用的 [AMP][topic amp] 发票（[周报 #173][news173 amp]）等多项功能与错误修复。

## 值得注意的代码和文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]的显著变更。*

- [Rust-Lightning #1078][] 新增 [BOLTs #880][news165 bolts-880] 定义的 `channel_type` 协商功能（[BOLTs #906][] 提出的功能位暂未实现）。BOLTs #880 是[锚定输出][topic anchor outputs]的必需项，也可能支持[零确认通道][news156 zcc]。

- [Rust-Lightning #1144][] 在路由评分逻辑中新增惩罚机制。在支付重试间对失败通道施加惩罚，以向路径查找算法提示潜在故障通道。

- [BIPs #1215][] 对 [BIP119][] 中的 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] 提案进行多项更新：
  * 指定使用类似 taproot 的[快速试验][news139 speedy trial]激活方式部署该软分叉。
  * 记录使用非标签化 SHA256 哈希的缘由。
  * 增加 OP_CHECKTEMPLATEVERIFY 与 [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] 提案的对比。
  * 说明 OP_CHECKTEMPLATEVERIFY 与其他潜在未来共识变更的交互。

{% include references.md %}
{% include linkers/issues.md issues="1078,1144,1215,880,906,23173" %}
[c-lightning 0.10.2]: https://github.com/ElementsProject/lightning/releases/tag/v0.10.2
[decker tweet]: https://twitter.com/Snyke/status/1452260691939938312
[news170 unec bug]: /zh/newsletters/2021/10/13/#ln-spend-to-fees-cve
[btcpay server 1.3.3]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.3.3
[rust-lightning 0.0.103]: https://github.com/rust-bitcoin/rust-lightning/releases/tag/v0.0.103
[lnd 0.14.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.14.0-beta.rc3
[leguilly thread]: https://mailmanlists.org/pipermail/dlc-dev/2021-November/000091.html
[osuntokun summary]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-November/003336.html
[news53 stuckless]: /zh/newsletters/2019/07/03/#stuckless-payments
[neutrino]: https://github.com/lightninglabs/neutrino
[neutrino #234]: https://github.com/lightninglabs/neutrino/pull/234
[bd cbf thread]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-November/019589.html
[ld cbf thread]: https://groups.google.com/a/lightning.engineering/g/lnd/c/CE2EslTiqW4/m/CSV3mL5JBQAJ
[harding undo verification]: https://groups.google.com/a/lightning.engineering/g/lnd/c/CE2EslTiqW4/m/O0_kQF7mBQAJ
[news164 ping]: /zh/newsletters/2021/09/01/#lnd-5621
[news165 bolts-880]: /zh/newsletters/2021/09/08/#bolts-880
[news157 db]: /zh/newsletters/2021/07/14/#lnd-5447
[news170 path]: /zh/newsletters/2021/10/13/#lnd-5642
[news172 pool]: /zh/newsletters/2021/10/27/#lnd-5709
[news173 amp]: /zh/newsletters/2021/11/03/#lnd-5803
[news156 zcc]: /zh/newsletters/2021/07/07/#zero-conf-channel-opens
[lnd 0.13.4-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.13.4-beta
[news139 speedy trial]: /zh/newsletters/2021/03/10/#a-short-duration-attempt-at-miner-activation
[atmp disk]: https://github.com/bitcoin/bitcoin/blob/23ae7931be50376fa6bda692c641a3d2538556ee/src/validation.cpp#L4489-L4490
[atmp p2p]: https://github.com/bitcoin/bitcoin/blob/23ae7931be50376fa6bda692c641a3d2538556ee/src/net_processing.cpp#L3262
[atmp reorg]: https://github.com/bitcoin/bitcoin/blob/23ae7931be50376fa6bda692c641a3d2538556ee/src/validation.cpp#L352-L354
[atmp client]: https://github.com/bitcoin/bitcoin/blob/23ae7931be50376fa6bda692c641a3d2538556ee/src/node/transaction.cpp#L73-L83
[atmp bypass limits]: https://github.com/bitcoin/bitcoin/blob/f87e07c6fe321f0fb97703c82c0e4122f800589f/src/validation.cpp#L353
[series preparing for taproot]: /zh/preparing-for-taproot/
