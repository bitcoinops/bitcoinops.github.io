---
title: 'Bitcoin Optech Newsletter #166'
permalink: /zh/newsletters/2021/09/15/
name: 2021-09-15-newsletter-zh
slug: 2021-09-15-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本期 Newsletter 描述了一个新的契约操作码提案，并总结了在 signet 上实施定期重组（reorg）的反馈请求。同时包含我们关于如何为 taproot 激活做准备的常规章节、新版本发布列表以及主流比特币基础设施软件的更新说明。

## 新闻

- **<!--covenant-opcode-proposal-->****契约操作码提案：** Anthony Towns 在 Bitcoin-Dev 邮件列表发布了关于新契约操作码的[概述][towns overview]，以及更[技术细节][towns detailed]的说明，描述该操作码（及其他 tapscript 变更）的工作原理。

  简而言之，新操作码 `OP_TAPLEAF_UPDATE_VERIFY`（TLUV）会获取被花费的 taproot 输入信息，根据 tapscript 描述的修改规则，要求结果必须与输出中对应位置的 scriptPubKey 等效。这使得 TLUV 能够约束比特币的支出路径（即[契约][topic covenants]的定义），类似于其他提案如 [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack]（CSFS）和 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]（CTV）。其独特之处在于允许 tapscript 创建者进行以下修改：

  - **<!--internal-key-tweak-->****内部密钥调整：** 每个 taproot 地址都承诺一个可用于直接签名的内部密钥。要使用 tapscript（包括 TLUV），需公开当前内部密钥。TLUV 允许指定对该密钥的调整。例如，若内部密钥是 `A+B+C` 的聚合密钥，可通过 `-C` 调整移除密钥 C，或通过 `X` 调整添加密钥 X。TLUV 会计算调整后的内部密钥，并确保输出支付到该密钥。

    Towns 在邮件中描述了一个强大用例：更高效地创建 [joinpool][] —— 一个由多个用户共享的 UTXO，每个用户控制部分资金且无需在链上公开所有权信息（也不暴露所有者数量）。若所有成员联合签名，他们可以进行高度可互换的交易。若存在分歧，每个成员可通过交易随时退出（仅需支付链上交易费）。

    当前使用预签名交易也可创建 joinpool，但若希望每个成员能独立退出而不依赖他人协作，则需要指数级增长的签名数量。CTV 存在类似问题，退出可能需创建影响其他用户的多笔交易。而 TLUV 允许单个成员随时退出，无需预签名且不影响其他用户（仅需公开该成员已退出）。

  - **<!--merkle-tree-tweak-->****默克尔树调整：** taproot 地址也可承诺 tapscript 树的默克尔根。TLUV 允许脚本指定如何修改默克尔树。例如，可移除当前执行的节点（如成员退出 joinpool），或替换为支付不同 tapscript 的节点。TLUV 会计算调整后的默克尔根，并确保输出支付到该根。

    Towns 的邮件描述了如何利用此功能实现 Bryan Bishop 2019 年的[保险库][topic vaults]设计（参见 [Newsletter #59][news59 vaults]）。Alice 创建两对密钥：热钱包（低安全性）和冷钱包（高安全性）。冷钱包密钥作为 taproot 内部密钥，可随时花费资金。热钱包密钥结合 TLUV 仅允许将资金花费到包含时间延迟的默克尔树修改（延迟后热钱包密钥才能发起二次支出）。

    这意味着 Alice 可用热密钥发起资金支出，但需创建链上交易并等待时间延迟（如 1 天）完成后才能真正转账。若他人盗用热密钥发起支出，Alice 可用冷密钥将资金转移至安全地址。

  - **<!--amount-introspection-->****金额自省：** 除 TLUV 外，新增第二个操作码将输入及其对应输出的比特币金额推送到脚本执行栈，允许通过数学和比较操作码限制可支出金额。

    在 joinpool 场景中，这可确保退出成员仅能提取自身资金。在保险库场景中，可设置周期性提款限额（如每日 1 BTC）。

  截至撰稿时，该提案仍在邮件列表接收初步反馈。我们将在未来 Newsletter 中总结值得注意的评论。

- **<!--signet-reorg-discussion-->****Signet 重组讨论：** 开发者 0xB10C 在 Bitcoin-Dev 邮件列表[发布][b10c post]关于在 [signet][topic signet] 实施定期区块链重组（reorg）的提案。将被重组的区块会在版本字段的某一位发出信号，使不希望跟踪重组者能忽略这些区块。重组将定期发生（约每日三次），并遵循两种模拟主网可能重组模式的方案。

  0xB10C 已收到多条反馈。我们鼓励对测试 signet 重组（或希望避免重组）的读者参与讨论。

## 准备 Taproot #13：备份与安全方案

*关于开发者和服务提供商如何为即将在区块高度 {{site.trb}} 激活的 taproot 做准备的[系列][series preparing for taproot]文章。*

{% include specials/taproot/zh/12-backups.md %}

## 发布与候选发布

*主流比特币基础设施项目的新版本和候选版本。请考虑升级或协助测试。*

- [Bitcoin Core 22.0][bitcoin core 22.0] 是该全节点实现及其关联钱包软件的新主版本。主要变更包括支持 [I2P][topic anonymity networks] 连接、移除对 [Tor v2][topic anonymity networks] 的支持，以及增强硬件钱包支持。注意该版本的验证步骤已变更（参见 [Newsletter #162][news162 core verification]）。

- [BTCPay Server 1.2.3][] 修复了三个被负责任披露的跨站脚本（XSS）漏洞。

- [Bitcoin Core 0.21.2rc2][bitcoin core 0.21.2] 是维护版本的候选发布，包含多个错误修复和小幅改进。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]的显著变更。*

- [Bitcoin Core #22079][] 为 [ZMQ 接口][ZMQ interface]添加 IPv6 支持。

- [C-Lightning #4599][] 实现了 [BOLTs #843][] 描述的快速关闭手续费协商协议。我们曾在[上周 Newsletter][news165 bolts847] 描述该协议，但对其替代的旧协议描述[存在误差][russell tweet]。旧协议需基于试错的费率协商，且不允许设置高于当前承诺交易的手续费率。这在[锚定输出][topic anchor outputs]场景下不合理（低费率承诺交易设计为可追加手续费）。新协议允许支付更高费用，并在可能时使用更高效的区间协商。[Eclair #1768][] 也于本周合并实现该协议。

- [Eclair #1930][] 允许其路径查找算法使用非默认实验参数集。可通过自动分配部分流量或 API 手动执行。各参数集的指标单独记录，用于优化最佳参数。

- [Eclair #1936][] 允许禁用节点 Tor 洋葱服务地址的公开，以保护地址隐私。

- [LND #5356][] 新增 `BatchChannelOpen` RPC，支持在单笔[批量支付][topic payment batching]交易中向不同节点开通多个通道。

- [BTCPay Server #2830][] 新增支持创建启用 [taproot][topic taproot] 的钱包，可收发单签 P2TR 支付（已在 [signet][topic signet] 测试）。合并的 [#2837][btcpay server #2837] 在钱包设置中列出 P2TR 地址支持，但在区块 {{site.trb}} 前暂不可选。

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
