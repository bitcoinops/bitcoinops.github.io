---
title: 'Bitcoin Optech Newsletter #376'
permalink: /zh/newsletters/2025/10/17/
name: 2025-10-17-newsletter-zh
slug: 2025-10-17-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报分享了关于节点共享其当前区块模板提案的更新，并总结了一篇概述无需限制条款的资金库构造的论文。还包括我们的常规部分，公布新版本和候选版本，并描述流行的比特币基础设施软件的值得注意的更改。

## 新闻

- **<!--continued-discussion-of-block-template-sharing-->****区块模板共享的持续讨论：** 关于全节点对等节点偶尔使用[致密区块][topic compact block relay]编码相互发送其下一个区块的当前模板的提案，相关[讨论][towns tempshare]仍在继续（参见周报 [#366][news366 block template sharing] 和 [#368][news368 bts]）。反馈主要围绕在隐私和节点指纹识别问题方面。作者决定将当前草案移至 [Bitcoin Inquisition Numbers and Names Authority][binana repo]（BINANA）仓库，以解决这些问题并完善文档。该草案被赋予代码 [BIN-2025-0002][bin]。

- **<!--b-ssl-a-secure-bitcoin-signing-layer-->****B-SSL 安全比特币签名层：** Francesco Madonna 在 Delving Bitcoin 上[发布][francesco post]了一个概念，这是一个使用 [taproot][topic taproot]、[`OP_CHECKSEQUENCEVERIFY`][op_csv] 和 [`OP_CHECKLOCKTIMEVERIFY`][op_cltv] 的无需限制条款的[资金库][topic vaults]模型。在帖子中，他提到它使用现有的比特币原语，这很重要，因为大多数资金库提案都需要软分叉。

  在该设计中，有三种不同的支出路径：

  1. 用于正常操作的快速路径，其中可选的便利服务（CS）可以强制执行所选的延迟。

  2. 由托管人 B 提供的一年回退路径。

  3. 在失踪或继承事件情况下的三年托管路径。

  有 6 个不同的密钥 A、A₁、B、B₁、C 和 CS，其中 B₁ 和 C 由托管人持有，仅在恢复路径中同时使用。

  这种设置创建了一个环境，用户可以锁定他们的资金，并相当确信他们委托资金的托管人不会窃取。虽然这不像[限制条款][topic covenants]那样限制资金可以转移到哪里，但这种设置确实为带有托管人的自我托管提供了一个更有弹性的方案。在帖子中，Francesco 呼吁读者在任何人尝试实施这个想法之前审查和讨论[白皮书][bssl whitepaper]。

## 发布与候选发布

_流行的比特币基础设施项目的新发布和候选发布。请考虑升级到新版本或帮助测试候选发布。_

- [Bitcoin Core 30.0][] 是网络主要全节点的最新版本发布。其[发布说明][notes30]描述了几项重大改进，包括标准交易中传统 sigops 的新 2500 上限、多个数据载体（OP_RETURN）输出现在成为标准、默认 `datacarriersize` 增加到 100,000、默认[最低中继手续费率][topic default minimum transaction relay feerates]和增量中继手续费率为 0.1sat/vb、默认最低区块手续费率为 0.001sat/vb、改进的交易孤儿 DoS 保护、新的 `bitcoin` CLI 工具、用于 [Stratum v2][topic pooled mining] 集成的实验性进程间通信（IPC）挖矿接口、`coinstatsindex` 的新实现、默认启用 `natpmp` 选项、移除对传统钱包的支持以支持[描述符][topic descriptors]钱包、以及支持花费和创建 [TRUC][topic v3 transaction relay] 交易，还有许多其他更新。

- [Bitcoin Core 29.2][] 是一个次要版本，包含针对 P2P、交易池、RPC、CI、文档和其他问题的多个错误修复。更多详细信息请参见[发布说明][notes29.2]。

- [LDK 0.1.6][] 是这个用于构建支持闪电网络应用程序的流行库的发布版本，包含与 DoS 和资金盗窃相关的安全漏洞补丁、性能改进以及多个错误修复。

## 值得注意的代码和文档更改

_[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 中值得注意的近期更改。_

- [Eclair #3184][] 通过在重新连接时重新发送 `shutdown` 消息来改进协作关闭流程，当断开连接前已经发送过一次时，如 [BOLT2][] 中所规定。对于[简单 taproot 通道][topic simple taproot channels]，Eclair 为重新发送生成新的关闭 nonce 并存储它，允许节点稍后生成有效的 `closing_sig`。

- [Core Lightning #8597][] 防止了当直接对等节点在 CLN 通过 `sendonion` 或 `injectpaymentonion` 发送格式错误的[洋葱消息][topic onion messages]后返回 `failmsg` 响应时发生的崩溃。现在，CLN 将其视为普通的首跳失败并返回干净的错误，而不是崩溃。以前，它将其视为来自更下游的加密 `failonion`。

- [LDK #4117][] 引入了使用 `static_remote_key` 的 `remote_key` 的可选确定性派生。这允许用户在强制关闭的情况下仅使用备份助记词恢复资金。以前，`remote_key` 依赖于每个通道的随机性，需要通道状态来恢复资金。这个新方案对新通道是可选的，但在[拼接][topic splicing]现有通道时自动应用。

- [LDK #4077][] 添加了 `SplicePending` 和 `SpliceFailed` 事件，前者在[拼接][topic splicing]注资交易被协商、广播并被双方锁定后发出（除非是 [RBF][topic rbf] 的情况）。后者事件在拼接因 `interactive-tx` 失败、`tx_abort` 消息、通道关闭或在[静默][topic channel commitment upgrades]状态下断开连接/重新加载而在锁定之前中止时发出。

- [LDK #4154][] 更新了原像链上监控的处理，以确保仅为支付哈希与检索到的原像匹配的 [HTLC][topic htlc] 创建索取交易。以前，LDK 尝试索取任何可索取的 HTLC（过期的和已知原像的），如果对手方首先超时另一个 HTLC，这会冒着创建无效索取交易和潜在资金损失的风险。

{% include snippets/recap-ad.md when="2025-10-21 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3184,8597,4117,4077,4154" %}
[francesco post]: https://delvingbitcoin.org/t/concept-review-b-ssl-bitcoin-secure-signing-layer-covenant-free-vault-model-using-taproot-csv-and-cltv/2047
[op_cltv]: https://github.com/bitcoin/bips/blob/master/bip-0065.mediawiki
[op_csv]: https://github.com/bitcoin/bips/blob/master/bip-0112.mediawiki
[bssl whitepaper]: https://github.com/ilghan/bssl-whitepaper/blob/main/B-SSL_WP_Oct_11_2025.pdf
[towns tempshare]: https://delvingbitcoin.org/t/sharing-block-templates/1906/13
[news366 block template sharing]: /zh/newsletters/2025/08/08/#peer-block-template-sharing-to-mitigate-problems-with-divergent-mempool-policies
[binana repo]: https://github.com/bitcoin-inquisition/binana
[bin]: https://github.com/bitcoin-inquisition/binana/blob/master/2025/BIN-2025-0002.md
[news368 bts]: /zh/newsletters/2025/08/22/#draft-bip-for-block-template-sharing
[Bitcoin Core 30.0]: https://bitcoincore.org/bin/bitcoin-core-30.0/
[notes30]: https://bitcoincore.org/en/releases/30.0/
[Bitcoin Core 29.2]: https://bitcoincore.org/bin/bitcoin-core-29.2/
[notes29.2]: https://bitcoincore.org/en/releases/29.2/
[LDK 0.1.6]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.6