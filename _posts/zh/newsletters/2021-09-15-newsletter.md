---
title: 'Bitcoin Optech Newsletter #166'
permalink: /zh/newsletters/2021/09/15/
name: 2021-09-15-newsletter-zh
slug: 2021-09-15-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本期 Newsletter 描述了一个新的契约操作码提案，并总结了在 signet 上实施定期重组（reorg）的反馈请求。同时包含我们关于如何为 taproot 激活做准备的常规章节、新版本与候选发布列表，以及主流比特币基础设施软件的介绍。

## 新闻

- **<!--covenant-opcode-proposal-->****契约操作码提案：** Anthony Towns 在 Bitcoin-Dev 邮件列表发布了关于契约操作码构想的[概述][towns overview]，以及一篇更[技术细节][towns detailed]的帖子，描述该操作码（及其他 tapscript 变更）将如何工作。

  简而言之，新操作码 `OP_TAPLEAF_UPDATE_VERIFY`（TLUV）会获取正在被花费的 taproot 输入的信息，按 tapscript 的描述对其做出修改，并要求修改结果与输入端同一位置的输出中的 scriptPubKey 等效。这使得 TLUV 能够约束这些比特币可以被花费到哪里（即[契约][topic covenants]的定义），类似于其他提案如 [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack]（CSFS）和 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]（CTV）。与以往提案的不同之处在于，它允许 tapscript 的创建者做出以下修改：

  - **<!--internal-key-tweak-->****内部密钥调整：** 每个 taproot 地址都承诺一个内部密钥，只用签名即可花费。要使用 tapscript（包括 TLUV），需公开当前内部密钥。TLUV 允许指定一个要加到该密钥上的调整值。例如，若内部密钥是 `A+B+C` 的聚合密钥，可通过 `-C` 调整移除密钥 C，或通过 `X` 调整添加密钥 X。TLUV 会计算调整后的内部密钥，并确保同一位置的输出正是支付给该密钥。

    Towns 在邮件中描述了一个强大用例：更高效地创建 [joinpool][] —— 一个由多个用户共享的 UTXO，每个用户控制部分资金且无需在链上公开所有权信息（也不暴露所有者数量）。若池中所有成员共同签名，他们就能以高度可互换的交易花费资金。若出现分歧，每个池成员都可以用一笔交易带走自己的全部资金退出该池（扣除一笔链上交易费）。

    当前使用预签名交易也可创建 joinpool，但若希望每个成员能独立退出而不依赖他人协作，则需要指数级增长的签名数量。CTV 存在类似问题：退出可能需创建影响多个其他用户的多笔交易。而 TLUV 允许任何单个成员随时退出，无需预签名且不影响其他用户（仅需公开该成员已退出）。

  - **<!--merkle-tree-tweak-->****默克尔树调整：** taproot 地址也可承诺一棵 tapscript 树的默克尔根，而执行 TLUV 操作码的正是交易输入中的某个 tapscript。TLUV 允许该脚本指定默克尔树的这一部分应如何修改。例如，可移除当前执行的节点（tapleaf，如成员退出 joinpool），或将其替换为一个支付不同 tapscript 的 tapleaf。TLUV 会计算调整后的默克尔根，并确保同一位置的输出正是支付给该根。

    Towns 的邮件描述了如何利用此功能实现 Bryan Bishop 2019 年的[保险库][topic vaults]设计（参见 [Newsletter #59][news59 vaults]）。Alice 创建两对密钥：一对用于安全性较低的热钱包，一对用于安全性较高的冷钱包。冷钱包密钥成为 taproot 内部密钥，可随时花费资金。热钱包密钥与 TLUV 配合使用时，只允许把资金花费到默克尔树的一种修改结果上，该修改包含一段延时，延时之后才能再用热钱包密钥发起第二次花费。

    这意味着 Alice 可以用热密钥发起一笔花费其全部资金的交易，但她必须为此创建一笔链上交易，然后等延时（例如 1 天）结束后，才能真正把资金花费到任意地址。如果有别人在用 Alice 的热密钥启动这一花费流程，Alice 可以用冷密钥把资金转到安全地址。

  - **<!--amount-introspection-->****金额自省：** 除 TLUV 外，新增第二个操作码将输入及其对应输出的比特币金额推送到脚本执行栈，允许通过数学和比较操作码限制可支出金额。

    在 joinpool 场景中，这可确保退出成员仅能提取自身资金。在保险库场景中，可设置周期性提款限额（如每日 1 BTC）。

  截至撰稿时，该提案仍在邮件列表接收初步反馈。我们将在未来 Newsletter 中总结值得注意的评论。

- **<!--signet-reorg-discussion-->****Signet 重组讨论：** 开发者 0xB10C 在 Bitcoin-Dev 邮件列表[发布][b10c post]了一项提案，提议在 [signet][topic signet] 上定期进行区块链重组（reorg）。最终会被重组的区块会在版本字段的某一位上发出信号，使任何不希望跟踪重组的人都能忽略这些区块。重组会定期发生，大约每天三次，并采用两种不同的模式，分别模拟主网上可能出现的重组情形。

  截至撰稿时，0xB10C 已收到若干评论。我们鼓励任何有兴趣在 signet 上测试重组（或希望避开重组）的人阅读相关讨论并考虑参与。

## 准备 Taproot #13：备份与安全方案

*本[系列][series preparing for taproot]每周一篇，讨论开发者和服务提供商如何为 taproot 即将在区块高度 {{site.trb}} 激活做好准备。*

{% include specials/taproot/zh/12-backups.md %}

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [Bitcoin Core 22.0][bitcoin core 22.0] 正式发布，这是该全节点实现及其配套钱包等软件的下一个主版本。这个新版本的主要变更包括支持 [I2P][topic anonymity networks] 连接、移除对 [Tor v2][topic anonymity networks] 连接的支持，以及增强对硬件钱包的支持。注意该版本的发布验证说明已变更，详见 [Newsletter #162][news162 core verification]。

- [BTCPay Server 1.2.3][] 是一个版本发布，修复了三个经负责任披露的跨站脚本（XSS）漏洞。

- [Bitcoin Core 0.21.2rc2][bitcoin core 0.21.2] 是 Bitcoin Core 维护版本的候选发布，包含多个错误修复和小幅改进。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]的值得注意的变更。*

- [Bitcoin Core #22079][] 为 [ZMQ 接口][ZMQ interface]添加 IPv6 支持。

- [C-Lightning #4599][] 实现了 [BOLTs #843][] 描述的快速关闭手续费协商协议。我们曾在[上周 Newsletter][news165 bolts847] 描述该协议，但对其所替代的既有协议描述[有误][russell tweet]。旧协议需要就共同关闭交易使用何种费率进行反复试错的协商，并且不允许设置高于当前承诺交易费率的费率。这在[锚定输出][topic anchor outputs]场景下并不合理——低费率的承诺交易一旦被使用，本就设计为可以追加手续费。新协议允许支付更高的手续费，并在可能时使用更高效的区间协商。[Eclair #1768][] 也于本周合并，同样实现了该协议。

- [Eclair #1930][] 允许其寻路算法使用非默认的实验参数集。这既可以自动对一定比例的流量执行，也可以通过 API 手动执行。每个实验参数集的指标会单独记录，可用于优化出最佳的寻路参数。

- [Eclair #1936][] 允许禁用节点 Tor 洋葱服务地址的公开，适用于用户希望对该地址保密的场景。

- [LND #5356][] 新增 `BatchChannelOpen` RPC，支持在同一笔[批量支付][topic payment batching]的链上交易中向不同节点开通多个通道。

- [BTCPay Server #2830][] 新增支持创建启用 [taproot][topic taproot] 的钱包，可收发单签 P2TR 支付（已在 [signet][topic signet] 测试）。另一个已合并的 PR [#2837][btcpay server #2837] 在钱包设置中列出 P2TR 地址支持，但在区块 {{site.trb}} 之前不可选。

{% include references.md %}
{% include linkers/issues.md issues="22079,4599,1930,1936,5356,2830,843,1768,2837" %}
[bitcoin core 22.0]: https://bitcoincore.org/bin/bitcoin-core-22.0/
[bitcoin core 0.21.2]: https://bitcoincore.org/bin/bitcoin-core-0.21.2/
[btcpay server 1.2.3]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.2.3
[towns overview]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-September/019419.html
[towns detailed]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-September/019420.html
[joinpool]: https://gist.github.com/harding/a30864d0315a0cebd7de3732f5bd88f0
[news59 vaults]: /zh/newsletters/2019/08/14/#bitcoin-vaults-without-covenants
[b10c post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-September/019413.html
[news165 bolts847]: /zh/newsletters/2021/09/08/#bolts-847
[russell tweet]: https://twitter.com/rusty_twit/status/1435758634995105792
[news162 core verification]: /zh/newsletters/2021/08/18/#bitcoin-core-22642
[zmq interface]: https://github.com/bitcoin/bitcoin/blob/40a9037a1b5d990637d7f5009fc0c39628ed2c05/doc/zmq.md
[series preparing for taproot]: /zh/preparing-for-taproot/
