---
title: 'Bitcoin Optech Newsletter #374'
permalink: /zh/newsletters/2025/10/03/
name: 2025-10-03-newsletter-zh
slug: 2025-10-03-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

## 新闻

*在我们 Optech 关注的[信息源][optech sources]中，本周没有发现重要的新闻。*

## 改变共识

*在这个月度栏目中，我们总结关于变更比特币的共识规则的提议和讨论。*

- **<!--draft-bips-for-script-restoration-->** **Script Restoration 草案 BIP**：Rusty Russell 在 Bitcoin-Dev 邮件组中列出了关于在一个新的 [tapscript][topic tapscript] 版本中复原 Script 的能耐的提议的[总结][rr0]，以及描述其实现步骤的四个 BIP（[1][rr1]、[2][rr2]、[3][rr3]、[4][rr4]）。Russell 曾经[演讲][rr atx]和[撰写][rr blog]过这些想法。简单来说，这个提议旨在为比特币恢复加强过的可编程性（包含[限制条款][topic covenants]功能），同时避免范围相对更狭窄的一些提议所需面对的权衡。

  - *<!--varops-budget-for-script-runtime-constraint-->脚本运行时的变长操作码预算限制*：[第一个 BIP][rr1] 是非常完整的，提议为几乎所有的 Script 操作分配一个代价度量，这种度量类似于隔离见证（SegWit）中的 “签名操作预算（sigops budget）”。对于 Script 中的几乎所有操作，这个代价都基于在运行这个操作的粗糙实现时写入该节点的内存（RAM）中的字节数量。与签名操作预算不同，在这里，每一个操作码的代价都取决于其输入的体积 —— 这正是提案名字（“变长操作码（varops）”  ）的由来。使用这种统一的代价模型，许多当前用于保护节点不至于过量执行 Script 验证的限制，可以提升到实用的脚本无法触及或几乎无法触及的高度。

  - *<!--restoration-of-disabled-script-functionality-tapscript-v2-->* *恢复曾被禁用的 Script 功能（tapscript v2）*：[第二个 BIP][rr2] 也是非常完整的（除了缺少一个参考实现），详细描述了要恢复的在 2010 年从 Script 中[移除][misc changes]的操作码（当时是为了保护比特币网络免于过量的 Script 验证）。使用前述的变长操作码预算机制，所有这些操作码（或者它们的升级版本）都可以恢复，限制可以提高，而且数字可以使用任意长度。

  - *<!--optx-->* *OP_TX*：[第三个 BIP][rr3] 提出了一种新的通用内省操作码 `OP_TX`，它允许调用者在堆栈中获得来自交易的几乎任何一段（或多段）信息。通过提供直接访问花费交易的方法，这个操作码启用了 `OP_TEMPLATEHASH`（或 [`OP_CHECKTEMPLATEVERIFY`][topic op_checktemplateverify]）这样的操作码可以实现的任何限制条款功能。

  - *<!--new-opcodes-for-tapscript-v2-->* *为 tapscript v2 提议的新操作码*：[第四个 BIP][rr4] 提出了新的操作码，以完善比特币自启动以来缺失或者不需要的功能。比如说，添加操作 taptree 和 taproot 输出的功能，在比特币启动的时候是不必要的，但在复原 Script 的世界中，同时拥有这些功能就是有意义的。Brandon Black [指出][bb1] 提议中的操作码有所缺失，因此无法完全构造 taproot 输出。其中两个被提议的操作码似乎需要专门的 BIP：`OP_MULTI` 和 `OP_SEGMENT` 。

  `OP_MULTI` 会改变后续操作码的行为，从而在超过其标准数量的堆栈对象上操作，启用了（比如说）加总多个对象的功能。这就不需要在 Script 中使用循环结构，也不需要使用 `OP_VAULT` 风格的推迟检查，而依然能启用价值流控制以及类似逻辑。

  `OP_SEGMENT`（如果有的话）会改变 `OP_SUCCESS` 的行为，使得不是只要出现 `OP_SUCCESS` 就会整个脚本通过，而是只有一个片段的脚本会通过（格式是脚本开头、`OP_SEGMENT` 、...，结束）。这使得脚本可以使用一个必要的前缀（也包括 `OP_SEGMENT`）以及一个不受信任的后缀。

## 新版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级新版本或帮助候选版本。*

- [Bitcoin Core 30.0rc2][] 是这个全验证节点软件的下一个主要版本的候选发行。请看这份 “[版本 30 候选发行测试指南][bcc30 testing]”。

- [bdk-wallet 2.2.0][] 是这个用于开发钱包应用的库的次要发行版，它引入了一项新特性，在应用一项更新时返回事件；一个新测试单元，用于测试持久性；还优化了文档。

- [LND v0.20.0-beta.rc1][] 是这个热门的闪电节点实现的新版本的候选发行，它引入了多项 bug 修复、在重启时可以持久保留的节点公告设定、一种新的 `noopAdd` [HTLC][topic htlc] 类型、支持在 [BOLT11][] 发票中加入 [P2TR][topic taproot] 备用地址，以及一个实验性的 `XFindBaseLocalChanAlia` 端点，还有其它变更。

## 重大的代码和说明书变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Bitcoin Core #33229][] 为进程间通信（IPC）（详见[周报 #369][news369 ipc]）实现了自动化的多线程挑选，从而允许用户在已经传递了 IPC 参数或者以及设置了 IPC 配置选项时，跳过指定 `-m` 启动选项。这一变更简化了 Bitcoin Core 与外部的 [Stratum v2][topic pooled mining] 挖矿服务的集成，后者会创建、管理和提交区块模板。

- [Bitcoin Core #33446][] 修复了一个 bug ，该 bug 是在添加 `target` 字段到 `getblock` 和 `getblockheader` 命令的响应体时引入的（详见[周报 #339][news339 target]）。如今它不再总是不正确低返回链顶端的难度目标，而是返回所请求区块的难度目标。

- [LDK #3838][] 为 “[JIT 通道][topic jit channels]” 添加了 `client_trusts_lsp` 模式，如 [BLIP52][]（LSPS2）所指定的（详见[周报 #335][news335 blip]）。在这种新模式中，参与的闪电网络服务商（LSP）不会广播链上注资交易，直到收款方揭晓领取 [HTLC][topic htlc] 所需的原像（才会广播）。

- [LDK #4098][] 为[拼接][topic splicing]交易的 `channel_reestablish` 流更新了 `next_funding` TLV 的实现，以跟 [BOLTs #1289][] 所提议的规范变更保持一致。这个 PR 延续了[周报 #371][news371 splicing]所述的在 `channel_reestablish` 上的工作。

- [LDK #4106][] 修复了一个竞争进入条件：当一个 LSP 代表一笔[异步支付][topic async payments]的收款方持有一个 [HTLC][topic htlc] 时，因为无法定位收款方而无法释放这个 HTLC 。当这个LSP 在把这个 HTLC 从预先解码（pre-decode）的图移动到 `pending_intercepted_htlcs` 图之前、收到了 `release_held_htlc` [洋葱消息][topic onion messages] 时（详见周报 [#372][news372 async] 和 [#373][news373 async]），就会出现这种竞争进入。LDK 现在会检查两个图（而不是仅仅检查后者），来保证发现这个 HTLC 并恰当低释放。

- [LDK #4096][] 将每个对等节点的出站（outbound）[gossip][topic channel announcements] 消息队列从 24 条消息的限制改为 128 KB 的体积限制。如果某一个对等节点的消息队列的总字节数已经超过了这个校址，那么要转发给这个对等节点的新 gossip 消息就会被跳过，直到队列缩减。这一新的限制显著减少了遗漏的转发，而且非常有用，因为消息的体积并不是恒定的。

- [LND #10133][]添加了实验性的 `XFindBaseLocalChanAlias` RPC 端点，它将为指定的一个 SCID 昵称返回一个基础 SCID（详见[周报 #203][news203 alias]）。这个 PR 也将昵称管理器拓展成了持久化的反向映射，一旦昵称创建，就启用了新的端点。

- [BDK #2029][] 引入了 `CanonicalView` 结构体，它会在一个钱包的 `TxGraph` 上执行一个一次性的规范化（canonicalization）（以给定的链顶端为最新状态）。这个快照会给所有后续的查询提供帮助，消除在每一次调用时重新规范化的需要。要求规范化的方法现在有 `CanonicalView` 的对等体，而采用可能出错的 `ChainOracle` 的 `TxGraph` 方法被移除了。周报 [#335][news335 txgraph] 和 [#346][news346 txgraph] 详述了 BDK 以往在规范化上的工作。

- [BIPs #1911][] 将 [BIP21][] 标记为可被 [BIP321][] 替代，并将 [BIP321][] 的状态从 `Draft`（草案）更新为 `Proposed`（提议成型）。[BIP321][] 提出了一种前卫的 URI 方案来描述比特币支付指令，详见 [周报 #352][news352 bip321]。


{% include references.md %}
{% include linkers/issues.md v=2 issues="33229,33446,3838,4098,4106,4096,10133,2029,1911,1289" %}
[rr0]: https://gnusha.org/pi/bitcoindev/877bxknwk6.fsf@rustcorp.com.au/
[rr1]: https://gnusha.org/pi/bitcoindev/874isonniq.fsf@rustcorp.com.au/
[rr2]: https://gnusha.org/pi/bitcoindev/871pnsnnhh.fsf@rustcorp.com.au/
[rr3]: https://gnusha.org/pi/bitcoindev/87y0q0m8vz.fsf@rustcorp.com.au/
[rr4]: https://gnusha.org/pi/bitcoindev/87tt0om8uz.fsf@rustcorp.com.au/
[rr atx]: https://www.youtube.com/watch?v=rSp8918HLnA
[rr blog]: https://rusty.ozlabs.org/2024/01/19/the-great-opcode-restoration.html
[bb1]: https://gnusha.org/pi/bitcoindev/aNsORZGVc-1_-z1W@console/
[misc changes]: https://github.com/bitcoin/bitcoin/commit/6ac7f9f144757f5f1a049c059351b978f83d1476
[bitcoin core 30.0rc2]: https://bitcoincore.org/bin/bitcoin-core-30.0/
[bcc30 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/30.0-Release-Candidate-Testing-Guide/
[bdk-wallet 2.2.0]: https://github.com/bitcoindevkit/bdk_wallet/releases/tag/wallet-2.2.0
[LND v0.20.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.0-beta.rc1
[news369 ipc]: /zh/newsletters/2025/08/29/#bitcoin-core-31802
[news339 target]: /zh/newsletters/2025/01/31/#bitcoin-core-31583
[news335 blip]: /zh/newsletters/2025/01/03/#blips-54
[news371 splicing]: /zh/newsletters/2025/09/12/#ldk-3886
[news372 async]: /zh/newsletters/2025/09/19/#ldk-4045
[news373 async]: /zh/newsletters/2025/09/26/#ldk-4046
[news203 alias]: /en/newsletters/2022/06/08/#bolts-910
[news335 txgraph]: /zh/newsletters/2025/01/03/#bdk-1670
[news346 txgraph]: /zh/newsletters/2025/03/21/#bdk-1839
[news352 bip321]: /zh/newsletters/2025/05/02/#bips-1555