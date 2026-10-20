---
title: 'Bitcoin Optech Newsletter #400'
permalink: /zh/newsletters/2026/04/10/
name: 2026-04-10-newsletter-zh
slug: 2026-04-10-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报包括我们的常规栏目：总结一次 Bitcoin Core PR 审议俱乐部会议，以及介绍流行比特币基础设施项目的重大变更。

## 新闻

*在我们 Optech 关注的[信息源][sources]中，本周没有发现重要的新闻。*

## Bitcoin Core PR 审议俱乐部

*在这个月度栏目中，我们总结一次最近的 [Bitcoin Core PR 审议俱乐部][Bitcoin Core PR Review Club]会议。*

[测试 Bitcoin Core 31.0 候选发行版][review club v31-rc-testing]是一次没有审核特定 PR 的审议俱乐部会议，而是一次集体测试活动。

在每次 [Bitcoin Core 主要版本][major bitcoin core release]发布之前，社区的广泛测试被视为必不可少。因此，会有一位志愿者为候选发行版编写测试指南，以便尽可能多的人能够高效地进行测试，而无需独立确认发行版中有哪些新内容或变更，也不必重新发明测试这些特性或变更的各种准备步骤。

测试可能颇具难度，因为当遇到非预期行为时，往往不确定这是一个实际的 bug 还是测试者自身的操作失误。向开发者报告并非真正的 bug，是对开发者时间的浪费。为了缓解这些问题并推动测试工作，审议俱乐部会为特定的候选发行版举办会议。

[31.0 候选发行版测试指南][31.0 testing]由 [svanstaa][gh svanstaa] 编写（详见[播客 #397][pod397 v31rc1]），他也主持了本次审议俱乐部会议。

与会者还被鼓励通过阅读 [31.0 版本说明][31.0 release notes]来获取测试思路。

该测试指南涵盖了[族群交易池][topic cluster mempool]（包括新的 RPC 和族群限制，详见[周报 #382][news382 bc33629]）、私密广播（详见[周报 #388][news388 bc29415]）、更新后的 `getblock` RPC（新增 `coinbase_tx` 字段，详见[周报 #394][news394 bc34512]）、新的 `txospenderindex`（追踪哪笔交易花费了每个输出，详见[周报 #394][news394 bc24539]）、增大的默认 `-dbcache` 大小（详见[周报 #396][news396 bc34692]）、嵌入式 ASMap 数据（详见[周报 #394][news394 bc28792]）以及新的 REST API `blockpart` 端点（详见[周报 #386][news386 bc33657]）。

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Bitcoin Core #33908][] 向 `libbitcoinkernel` 的 C 语言 API（详见[周报 #380][news380 kernel]）中添加了 `btck_check_block_context_free` 接口，用于对候选区块进行不依赖上下文的检查：区块大小/重量限制、coinbase 规则，以及不依赖链状态、区块索引或 UTXO 集的逐交易检查。调用者可以选择性地在此端点中启用工作量证明验证和默克尔根验证。

- [Eclair #3283][] 在 `findroute`、`findroutetonode` 和 `findroutebetweennodes` 等用于路径查找的端点的完整格式响应中，添加了一个 `fee` 字段（以毫聪为单位）。该字段提供了路由的总[转发手续费][topic inbound forwarding fees]，使调用者无需手动计算。

- [LDK #4529][] 使运营者能够在配置通道容量中处于传输状态的入站 [HTLC][topic htlc] 总值百分比时，为已公告通道和[未公告通道][topic unannounced channels]设置不同的限制。默认值现在是已公告通道为 25%，未公告通道为 100%。

- [LDK #4494][] 更新了其内部的[手续费替换][topic rbf]逻辑，以确保在低费率情况下符合 [BIP125][] 的替换规则。LDK 现在不再仅应用 [BOLT2][] 中规定的 25/24 费率乘数，而是取两者中较大的值：该乘数或额外的 25 sat/kwu。相关的规范澄清正在 [BOLTs #1327][] 中讨论。

- [LND #10666][] 添加了 `DeleteForwardingHistory` RPC 和 `lncli deletefwdhistory` 命令，使运营者能够选择性地删除早于指定截止时间戳的转发事件。一个最短时间保护机制（一小时）可防止意外删除近期数据。此特性使路由节点能够删除历史转发记录，而无需重置数据库或使节点离线。

- [BIPs #2099][] 发布了 [BIP393][]，该规范定义了一种可选的输出脚本[描述符][topic descriptors]注解语法，使钱包能够存储恢复提示，例如用于加速钱包扫描（包括[静默支付][topic silent payments]扫描）的生日区块高度。详见[周报 #394][news394 bip393] 对该 BIP 的初始报道及更多细节。

- [BIPs #2118][] 将 [BIP440][] 和 [BIP441][] 作为草案 BIP 发布在 Great Script Restoration（或 Grand Script Renaissance）系列中（详见[周报 #399][news399 bips]）。[BIP440][] 提出了用于脚本运行时约束的变长操作码预算（Varops Budget）（详见[周报 #374][news374 varops]）；[BIP441][] 描述了一个新的 [tapscript][topic tapscript] 版本，用于恢复 2010 年被禁用的操作码，如 [OP_CAT][topic op_cat]（详见[周报 #374][news374 tapscript]），并根据 BIP440 引入的变长操作码预算来限制脚本评估成本。

- [BIPs #2134][] 更新了 [BIP352][]（[静默支付][topic silent payments]），警告钱包开发者不要让策略过滤（例如针对[粉尘][topic uneconomical outputs]的过滤）影响到在找到匹配后是否继续扫描。将被过滤掉的输出视为没有匹配，可能导致钱包过早停止扫描，从而遗漏同一发送者的后续输出。

{% include references.md %}
{% include linkers/issues.md v=2 issues="33908,3283,4529,4494,10666,2099,2118,2134,1327" %}
[sources]: /en/internal/sources/
[news380 kernel]: /zh/newsletters/2025/11/14/#bitcoin-core-30595
[news394 bip393]: /zh/newsletters/2026/02/27/#draft-bip-for-output-script-descriptor-annotations-bip
[news399 bips]: /zh/newsletters/2026/04/03/#varops-budget-and-tapscript-leaf-0xc2-aka-script-restoration-are-bips-440-and-441
[news374 varops]: /zh/newsletters/2025/10/03/#varops-budget-for-script-runtime-constraint
[news374 tapscript]: /zh/newsletters/2025/10/03/#restoration-of-disabled-script-functionality-tapscript-v2
[BIP393]: https://github.com/bitcoin/bips/blob/master/bip-0393.mediawiki
[BIP440]: https://github.com/bitcoin/bips/blob/master/bip-0440.mediawiki
[BIP441]: https://github.com/bitcoin/bips/blob/master/bip-0441.mediawiki
[review club v31-rc-testing]: https://bitcoincore.reviews/v31-rc-testing
[major bitcoin core release]: https://bitcoincore.org/en/lifecycle/#versioning
[31.0 release notes]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/31.0-Release-Notes-Draft
[31.0 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/31.0-Release-Candidate-Testing-Guide
[gh svanstaa]: https://github.com/svanstaa
[pod397 v31rc1]: /en/podcast/2026/03/24/#bitcoin-core-31-0rc1-transcript
[news382 bc33629]: /zh/newsletters/2025/11/28/#bitcoin-core-33629
[news388 bc29415]: /zh/newsletters/2026/01/16/#bitcoin-core-29415
[news394 bc34512]: /zh/newsletters/2026/02/27/#bitcoin-core-34512
[news394 bc24539]: /zh/newsletters/2026/02/27/#bitcoin-core-24539
[news396 bc34692]: /zh/newsletters/2026/03/13/#bitcoin-core-34692
[news394 bc28792]: /zh/newsletters/2026/02/27/#bitcoin-core-28792
[news386 bc33657]: /zh/newsletters/2026/01/02/#bitcoin-core-33657
