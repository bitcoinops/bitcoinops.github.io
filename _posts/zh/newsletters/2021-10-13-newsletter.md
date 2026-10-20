---
title: 'Bitcoin Optech Newsletter #170'
permalink: /zh/newsletters/2021/10/13/
name: 2021-10-13-newsletter-zh
slug: 2021-10-13-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本期 Newsletter 描述了近期在多个 LN 实现中修复的一个漏洞，并总结了一个提案：利用 taproot 的特性升级 LN 协议，从而带来多重好处。此外还包括我们的常规栏目：Bitcoin Core PR 审查俱乐部会议摘要、taproot 准备信息、新软件版本与候选发布公告，以及主流比特币基础设施软件的值得注意的变更说明。

## 新闻

- **<!--ln-spend-to-fees-cve-->****闪电网络手续费支出漏洞 CVE：**
  上周，Antoine Riard 在 Lightning-Dev 邮件列表[发布][riard cve]了针对多个程序的 CVE 公告。比特币用户一直都被告诫不要创建[不经济的输出][topic uneconomical outputs]——花费这类输出会消耗其价值的相当一部分。然而，闪电网络允许用户发送在链上不经济的小额支付。在这些情况下，付款方或路由节点会为承诺交易多付一点矿工手续费，这部分小额资金实际上就等于捐给了矿工——前提是这笔承诺交易被发布出来（大多数情况下本不该发生）。

  Riard 报告称，LN 实现允许把不经济限额设为通道价值的 20% 或更高，因此五笔或更少的支付就足以让整条通道的价值都变成给矿工的捐赠。向矿工损失价值是 LN 小额支付机制固有的风险，但仅仅五笔支付就可能让通道的全部价值面临损失，这显然被认为过分了。

  Riard 的邮件中描述了多种缓解措施，包括让 LN 节点直接拒绝路由那些可能把自身超过一定数量的资金当作矿工手续费捐出去的支付。实施这一措施可能会削弱节点同时路由多笔链上不经济小额支付的能力，尽管尚不清楚实践中是否会引发问题。Optech 跟踪的所有受影响的 LN 实现都已发布或即将发布版本，至少实现其中一种缓解措施。

- **<!--multiple-proposed-ln-improvements-->****多项 LN 改进提案：**
  Anthony Towns 在 Lightning-Dev 邮件列表[发布][towns proposal]了一份带有示例代码的详细提案，描述了如何降低支付延迟、提升备份弹性，并允许在签名密钥离线时接收 LN 支付。该提案提供了 [eltoo][topic eltoo] 的部分相同好处，但不需要 [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] 软分叉，也不需要 taproot 软分叉（将于区块高度 {{site.trb}} 激活）之外的任何其他共识变更。因此，只要 LN 开发者完成实现与测试，它就可以立刻部署。来看其主要特性：

  - **<!--reduced-payment-latency-->****降低支付延迟：** 处理一笔支付所必需、但不涉及该支付具体内容的一些细节，可以由通道双方提前交换；这样节点只要把支付本身和针对该支付的签名发给通道对方，就能发起或路由该笔支付。关键路径上无需往返通信，使支付能以接近 LN 节点之间底层链路速度的速度在网络中传播。若支付失败需要退款，速度会更慢，但不会比这次变更之前更慢。该特性扩展了开发者 ZmnSCPxj 先前提过的想法（参见 [Newsletter #152][news152 ff]），他本周还基于与 Towns 的一些私下讨论[写了][zmnscpxj name drop]一篇相关文章。

  - **<!--improved-backup-resiliency-->****提升备份弹性：** 目前 LN 要求通道双方以及它们使用的任何[瞭望塔][topic watchtowers]都保存通道每一个历史状态的信息，以防有人尝试盗取资金。Towns 的提案对通道状态的多数信息采用确定性派生，并在每笔交易中编码一个状态编号，以便恢复所需信息（某些情况下需要少量暴力尝试）。这使得节点在通道创建时就能备份它所需的全部密钥相关信息。其他任何所需信息，都应能从区块链（在发生盗取尝试时）或从通道对方（在节点丢失自己的数据时）取得。

  - **<!--receiving-payments-with-an-offline-key-->****用离线密钥接收支付：** 在 LN 中，发送或路由支付从根本上需要一个在线（热）密钥，但当前协议还要求接收支付时密钥也必须在线。这一思路基于 Lloyd Fournier 对 ZmnSCPxj 前述想法的改编（[Newsletter #152][news152 ff] 也有介绍）：接收节点只在开通通道、关闭通道或再平衡通道时才需要把密钥上线。这可能改善商户节点的安全性。

  该提案还会带来更为人熟知的隐私与效率优势，即把 LN 升级为使用 taproot 和 [PTLCs][topic ptlc]。这个想法在邮件列表上讨论得很充分，截至撰稿时讨论仍在进行。

## Bitcoin Core PR 审查俱乐部

*本栏目每月汇总近期 [Bitcoin Core PR 审查俱乐部][Bitcoin Core PR Review Club]会议内容，精选重要问答。点击问题可查看会议答案摘要。*

[将 RBF 逻辑提取至 policy/rbf][review club #22675] 是 Gloria Zhao 提出的拉取请求，旨在将 Bitcoin Core 的[手续费替换（RBF）][topic rbf]逻辑提取为独立工具函数。

{% include functions/details-list.md

  q0="**<!--q0-->**内存池的高层设计目标是什么？"
  a0="内存池旨在保留最符合挖矿激励的交易候选，即使是非矿工节点也是如此。然而，DoS 防护（例如防止人们利用 P2P 网络广播永远无法确认的交易）与矿工激励（最大化内存池中价值相当于最靠前 1 个区块的交易的联合手续费）之间存在根本冲突。设计目标就是明确这种冲突出现在哪里，并设法将其影响降到最低。"
  a0link="https://bitcoincore.reviews/22675#l-86"

  q1="**<!--q1-->**将 RBF 逻辑提取为独立函数有何好处？"
  a1="把逻辑拆分成更小的函数，便于更好地做单元测试，也便于在交易包的内存池接受和[交易包中继][topic package relay]的实现中复用这些逻辑。"
  a1link="https://bitcoincore.reviews/22675#l-24"

  q2="**<!--q2-->**在 [BIP125][] 规则 #2 中，为什么替换交易不引入任何新的未确认输入这一点很重要？"
  a2="若允许替换交易添加新的未确认输入，即使费率提升，交易的祖先费率也可能降低。矿工基于祖先费率选择交易打包入块，因此若允许新增输入，替换交易的挖矿吸引力可能低于原交易。"
  a2link="https://bitcoincore.reviews/22675#l-52"

  q3="**<!--q3-->**BIP125 规则 #4 中“支付自身带宽”是何含义？为何不干脆允许任何费率更高的替换？"
  a3="“支付自身带宽”指手续费需包含覆盖替换交易最低中继费用的额外金额。若无此规则，恶意攻击者可反复以 1 satoshi 递增手续费，消耗不成比例的内存池计算资源和网络带宽。"
  a3link="https://bitcoincore.reviews/22675#l-117"

  q4="**<!--q4-->**手续费替换逻辑关注内存池策略。为何[此逻辑][transaction spends its outputs]返回替换交易因共识规则失败而非策略规则？"
  a4="该逻辑捕获替换交易正在花费其替换的原交易的情况。由于原交易和替换交易无法同时确认，此类替换交易永远无法进入区块链，因此属于共识无效。"
  a4link="https://bitcoincore.reviews/22675#l-40"

%}

## 准备 Taproot #17：合作永远是可行选项吗？

*关于开发者和服务提供商如何为区块高度 {{site.trb}} 激活的 taproot 做准备的[系列][series preparing for taproot]周更。*

{% include specials/taproot/zh/17-keypath-universality.md %}

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [Eclair 0.6.2][] 新版本修复了上文*新闻*章节描述的漏洞，并新增功能及修复其他错误，详见[发布说明][eclair rn]。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]的值得注意的变更。*

- [Bitcoin Core #20487][] 新增 `-sandbox` 配置选项，用于启用实验性的系统调用（syscall）沙盒。沙盒启用后，若 Bitcoin Core 发起不在逐进程允许列表中的系统调用，内核就会终止它。该模式目前仅在 x86_64 上可用，主要用途是测试特定线程正在使用哪些系统调用。

- [Bitcoin Core #17211][] 更新钱包的 `fundrawtransaction`、`walletcreatefundedpsbt` 和 `send` RPC 方法，使交易中被花费的输出不必全部归该钱包所有。

  此前，钱包无法估算花费自己不拥有的输出所需的手续费，因为它不知道该输出对应输入的大小。这个 PR 让这些 RPC 方法接受一个 `solving_data` 参数：只要提供被花费输出的公钥、序列化后的 scriptPubKey 或[输出脚本描述符（descriptor）][topic descriptors]，钱包就能估算花费这些输出所需输入的大小（以及相应的手续费）。

- [Bitcoin Core #22340][] 区块挖出后会广播到 p2p 网络，最终中继给网络上的所有节点。历来有两种中继区块的方法：传统中继与 [BIP152][] 式的[紧凑区块中继][topic compact block relay]。

  以 `-blocksonly` 设置启动的节点不接收来自公开节点中继的交易，以此降低带宽消耗，因此其内存池通常是空的。所以紧凑区块对这类节点没有好处，因为它总是得下载完整区块。然而无论在高带宽还是低带宽模式下，`cmpctblock` 消息都会被中继，这给 blocks-only 节点带来了带宽开销，因为该消息平均比等效的区块头或 `inv` 通告大好几倍。

  如 [Newsletter #165][PR review club 22340] 所述，此 PR 通过阻止 blocks-only 节点发起高带宽的区块中继连接、并禁止发送 `sendcmpct(1)`，让这类节点改用传统中继来下载新区块。此外，blocks-only 节点不再用 `getdata(CMPCT)` 请求紧凑区块。

- [Bitcoin Core #23123][] 移除了 `-rescan` 启动选项，用户可改用 `rescan` RPC。

- [Eclair #1980][] 在使用[锚定输出][topic anchor outputs]时，将接受以任何高于本地全节点动态最低中继费率的费率创建的承诺交易。

- [LND #5363][] 允许跳过 LND 内部的[部分签名比特币交易（PSBT）][topic psbt]最终化步骤，让 PSBT 可以用其他软件完成最终化并广播。如果交易的 txid 被意外改变，这可能导致资金损失，但它确实提供了另一种工作流程。

- [LND #5642][] 现在会在内存中保留一份通道图缓存，以加速寻路操作。此前寻路需要进行代价高昂的数据库查询，据 PR 作者测量，这些查询比使用缓存慢 10 倍以上。

  在低内存系统上运行 LND 的用户，可以用 `routing.strictgraphpruning=true` 标志更激进地清除僵尸通道，从而减小这个新缓存的内存占用。

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
