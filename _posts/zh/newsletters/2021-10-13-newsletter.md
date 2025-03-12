---
title: 'Bitcoin Optech Newsletter #170'
permalink: /zh/newsletters/2021/10/13/
name: 2021-10-13-newsletter-zh
slug: 2021-10-13-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报描述了近期多个闪电网络实现中修复的一个漏洞，并总结了一个利用 taproot 功能升级闪电网络协议带来多重优势的提案。此外还包括我们的常规栏目：Bitcoin Core PR 审查俱乐部会议摘要、taproot 准备信息、新软件版本发布与候选版本公告，以及热门比特币基础设施软件的显著变更摘要。

## 新闻

- ​**<!--ln-spend-to-fees-cve-->****闪电网络手续费支出漏洞 CVE：**
  上周，Antoine Riard 在 Lightning-Dev 邮件列表[发布][riard cve]了针对多个程序的 CVE 公告。比特币用户一直被建议不要创建[不经济的输出][topic uneconomical outputs]，即花费其价值的相当部分来支出。然而，闪电网络允许用户发送链上不经济的小额支付。在这些情况下，支付或路由节点会为承诺交易超额支付矿工手续费，如果承诺交易被广播（在大多数情况下不应发生），这部分资金将捐赠给矿工。

  Riard 报告称，闪电网络实现允许将不经济限额设置为通道价值的 20% 或更高，因此五次或更少的支付就可能将通道的全部价值捐赠给矿工。虽然向矿工损失资金是闪电网络小额支付机制的基本风险，但五次支付就可能导致通道价值全部损失的风险显然被认为过高。

  Riard 的邮件中描述了多种缓解措施，包括让闪电网络节点直接拒绝路由可能导致其资金超额捐赠给矿工手续费的支付。实施此措施可能会降低节点同时路由多个链上不经济小额支付的能力，尽管尚不清楚是否会在实际中引发问题。所有受影响的闪电网络实现均已发布或即将发布包含至少一种缓解措施的版本。

- ​**<!--multiple-proposed-ln-improvements-->****多项闪电网络改进提案：**
  Anthony Towns 在 Lightning-Dev 邮件列表[发布][towns proposal]了一份包含示例代码的详细提案，描述了如何减少支付延迟、提升备份弹性，并允许在签名密钥离线时接收闪电网络支付。该提案提供了与 [eltoo][topic eltoo] 类似的部分优势，但无需 [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] 软分叉或其他共识变更，仅需利用将在区块高度 {{site.trb}} 激活的 taproot 软分叉。因此，该提案可在闪电网络开发者完成实现和测试后立即部署。主要功能包括：

  - ​**<!--reduced-payment-latency-->**​**降低支付延迟：​**​ 支付处理所需的非支付特定细节可由通道双方提前交换，允许节点通过简单发送支付及其签名即可发起或路由支付。关键路径上无需往返通信，使支付能以接近节点间底层链路的速度传播网络。支付失败时的退款流程较慢，但不会比现有方案更慢。此功能是对开发者 ZmnSCPxj 先前提案（参见 [Newsletter #152][news152 ff]）的扩展，他本周也基于与 Towns 的线下讨论[撰写][zmnscpxj name drop]了相关文章。

  - ​**<!--improved-backup-resiliency-->**​**增强备份弹性：​**​ 当前闪电网络要求通道双方及其使用的[瞭望塔][topic watchtowers]存储通道所有历史状态信息以防盗窃尝试。Towns 的提案通过确定性派生生成大部分通道状态信息，并在每笔交易中编码状态编号以支持必要信息的恢复（某些情况下需少量暴力计算）。这使得节点可在通道创建时备份所有密钥相关信息，其他所需信息可从区块链（盗窃发生时）或通道对手方（节点数据丢失时）获取。

  - ​​**<!--receiving-payments-with-an-offline-key-->****离线密钥接收支付：​**​ 闪电网络中发送或路由支付需在线密钥，但当前协议也要求接收支付时密钥在线。基于 ZmnSCPxj 先前提出的思路（[Newsletter #152][news152 ff] 亦有提及）和 Lloyd Fournier 的改进，接收节点只需在开通通道、关闭通道或再平衡通道时使密钥在线即可接收支付，从而提升商户节点的安全性。

  该提案还将提供[已知][zmnscpxj taproot ln]的隐私与效率优势，即通过升级闪电网络使用 taproot 和 [PTLCs][topic ptlc]。该提案在邮件列表引发热烈讨论，截至撰稿时讨论仍在进行。

## Bitcoin Core PR 审查俱乐部

*本栏目每月汇总近期 [Bitcoin Core PR 审查俱乐部][Bitcoin Core PR Review Club]会议内容，精选重要问答。点击问题可查看会议答案摘要。*

[将 RBF 逻辑提取至 policy/rbf][review club #22675] 是 Gloria Zhao 提出的拉取请求，旨在将 Bitcoin Core 的[手续费替换（RBF）][topic rbf]逻辑提取为独立工具函数。

{% include functions/details-list.md

  q0="​**<!--q0-->**内存池的高层设计目标是什么？"
  a0="内存池旨在为矿工节点和非矿工节点保留最具激励兼容性的交易候选。然而，DoS 防护（例如防止用户利用 P2P 网络广播永远无法确认的交易）与矿工激励（最大化内存池中前 1 个区块容量交易的联合手续费）存在根本冲突。设计目标是明确此类冲突的发生场景并尽量降低其影响。"
  a0link="https://bitcoincore.reviews/22675#l-86"

  q1="​**<!--q1-->**将 RBF 逻辑提取为独立函数有何优势？"
  a1="将逻辑拆分为小函数便于单元测试，并可在包内存池接受和[包中继][topic package relay]实现中复用。"
  a1link="https://bitcoincore.reviews/22675#l-24"

  q2="​**<!--q2-->**根据 [BIP125][] 规则 #2，为何替换交易不能引入新未确认输入？"
  a2="若允许替换交易添加新的未确认输入，即使费率提升，交易的祖先费率也可能降低。矿工基于祖先费率选择交易打包入块，因此若允许新增输入，替换交易的挖矿吸引力可能低于原交易。"
  a2link="https://bitcoincore.reviews/22675#l-52"

  q3="​**<!--q3-->**BIP125 规则 #4 中「支付自身带宽」是何含义？为何不直接允许更高费率的替换？"
  a3="「支付自身带宽」指手续费需包含覆盖替换交易最低中继费用的额外金额。若无此规则，恶意攻击者可反复以 1 satoshi 递增手续费，消耗不成比例的内存池计算资源和网络带宽。"
  a3link="https://bitcoincore.reviews/22675#l-117"

  q4="​**<!--q4-->**手续费替换逻辑关注内存池策略。为何[此逻辑][transaction spends its outputs]返回替换交易因共识规则失败而非策略规则？"
  a4="该逻辑捕获替换交易正在花费其替换的原交易的情况。由于原交易和替换交易无法同时确认，此类替换交易永远无法进入区块链，因此属于共识无效。"
  a4link="https://bitcoincore.reviews/22675#l-40"

%}

## 准备 Taproot #17：合作永远是可行选项吗？

*关于开发者和服务提供商如何为区块高度 {{site.trb}} 激活的 taproot 做准备的[系列][series preparing for taproot]周更。*

{% include specials/taproot/zh/17-keypath-universality.md %}

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选版本。请考虑升级至新版本或协助测试候选版本。*

- [Eclair 0.6.2][] 新版本修复了上文*新闻*章节描述的漏洞，并新增功能及修复其他错误，详见[发布说明][eclair rn]。

## 显著代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]的显著变更。*

- [Bitcoin Core #20487][] 新增 `-sandbox` 配置选项，用于启用实验性系统调用沙盒。沙盒激活时，若 Bitcoin Core 调用非允许列表中的系统调用，内核将终止其运行。该模式目前仅支持 x86_64 架构，主要用于测试特定线程使用的系统调用。

- [Bitcoin Core #17211][] 更新钱包的 `fundrawtransaction`、`walletcreatefundedpsbt` 和 `send` RPC 方法，允许交易花费未被钱包拥有的输出。

  此前，钱包因无法预估花费非自有输出所需的输入大小，故无法估算手续费。此 PR 允许通过 `solving_data` 参数提供被花费输出的公钥、序列化 scriptPubKey 或[描述符][topic descriptors]，使钱包能估算输入大小及相应手续费。

- [Bitcoin Core #22340][] 区块挖出后通过 p2p 网络广播，最终传递至全网节点。传统区块中继方式有两种：传统中继和 [BIP152][] 式[致密区块中继][topic compact block relay]。

  使用 `-blocksonly` 启动的节点为降低带宽消耗不接收公开节点的交易中继，通常内存池为空。因此致密区块对此类节点无益，仍需下载完整区块。但无论高低带宽模式，`cmpctblock` 消息的中继都会给 blocks-only 节点带来带宽开销，因其平均体积远大于等效的区块头或 `inv` 通告。

  如 [Newsletter #165][PR review club 22340] 所述，此 PR 通过阻止 blocks-only 节点发起高带宽区块中继连接并禁用 `sendcmpct(1)` 发送，使其使用传统中继下载新区块。同时 blocks-only 节点不再通过 `getdata(CMPCT)` 请求致密区块。

- [Bitcoin Core #23123][] 移除了 `-rescan` 启动选项，用户可改用 `rescan` RPC。

- [Eclair #1980][] 将在使用[锚定输出][topic anchor outputs]时接受本地全节点动态最低中继手续费以上的承诺交易。

- [LND #5363][] 允许跳过 LND 内部的 [PSBT][topic psbt] 最终化步骤，支持使用其他软件完成最终化与广播。此操作若意外修改交易 txid 可能导致资金损失，但提供了替代工作流。

- [LND #5642][] 新增内存中的通道图缓存以加速路径查找。此前路径查找需耗时数据库查询，据 PR 作者测试速度提升超 10 倍。

  低内存用户可通过 `routing.strictgraphpruning=true` 参数缩减缓存内存占用。

- [LND #5770][] 向 LND 子系统提供更多不经济输出信息，以支持上文*新闻*章节所述闪电网络 CVE 的缓解措施。

{% include references.md %}
{% include linkers/issues.md issues="20487,17211,22340,23123,1980,5363,5642,5770,22675" %}
[riard cve]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-October/003257.html
[zmnscpxj name drop]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-October/003265.html
[news152 ff]: /zh/newsletters/2021/06/09/#receiving-ln-payments-with-a-mostly-offline-private-key
[towns proposal]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-October/003278.html
[zmnscpxj taproot ln]: /zh/preparing-for-taproot/#使用-taproot-的闪电网络
[eclair 0.6.2]: https://github.com/ACINQ/eclair/releases/tag/v0.6.2
[eclair rn]: https://github.com/ACINQ/eclair/blob/master/docs/release-notes/eclair-v0.6.2.md
[transaction spends its outputs]: https://github.com/bitcoin/bitcoin/blob/0ed5ad102/src/validation.cpp#L774
[PR review club 22340]: /zh/newsletters/2021/09/08/#bitcoin-core-pr-审查俱乐部
[series preparing for taproot]: /zh/preparing-for-taproot/
