---
title: 'Bitcoin Optech Newsletter #379'
permalink: /zh/newsletters/2025/11/07/
name: 2025-11-07-newsletter-zh
slug: 2025-11-07-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报分享了一份关于 OpenSSL 和 libsecp256k1 库历史性能对比的分析。此外是我们的常规部分：关于共识变更的讨论描述、宣布软件的新版本和候选版本、热门比特币基础设施软件的显著更新总结。

## 新闻

- **<!--comparing-performance-of-ecdsa-signature-validation-in-openssl-vs-libsecp256k1-->****对比 OpenSSL 与 libsecp256k1 的 ECDSA 签名验证性能**：Sebastian Falbesoner 在 Delving Bitcoin 论坛[发布][sebastion delving]了一份关于过去十年间 OpenSSL 和 libsecp256k1 的 ECDSA 签名验证性能对比的分析。他提到，Bitcoin Core 从 OpenSSL 切换到 libsecp256k1 将迎来 10 周年纪念日。他设想了一个假设情况，即 Bitcoin Core 从未进行过这次切换。

  在切换时，libsecp256k1 的速度就比 OpenSSL 快 2.5 到 5.5 倍。但 OpenSSL 可能在这些年中有所改进，因此值得测试它在过去十年中的表现如何。

  测试方法包括三个步骤（解析压缩公钥、解析 DER 编码的签名、验证 ECDSA 签名），可以使用两个库中的函数进行测试。使用伪随机密钥对列表进行了基准测试。他在三台不同的机器上运行了基准测试并提供了柱状图。图表显示，多年来 libsecp256k1 有了显著改进。从 bc-0.19 到 bc-0.20 改进了约 28%，从 bc-0.20 到 bc-22.0 又改进了约 30%，而 OpenSSL 保持不变。

  Sebastian 总结道，在比特币生态系统之外，secp256k1 曲线并不那么重要，也不算是一等公民，不投入大量工作来改进它是合理的。他还鼓励读者尝试重现他的结果，并报告他的方法中存在的任何问题或发现的差异。[源代码][libsecp benchmark code]可在 GitHub 上获得。

## 共识变更

_关于提议和讨论变更比特币共识规则的月度部分。_

- **<!--multiple-discussions-about-restricting-data-->****关于限制数据的多个讨论**：多个对话探讨了在共识中改变各种字段限制的想法：

  * *<!--limiting-scriptpubkeys-to-520-bytes-->**将 scriptPubkeys 限制为 520 字节*：PortlandHODL 在 Bitcoin-Dev 邮件列表[发布][ph 520spk post]了一项提议，寻求在共识规则中将 `scriptPubKey` 大小限制为 520 字节。与 BIP54 [共识清理][topic consensus cleanup]类似，这将限制传统脚本在边缘情况下的最大区块验证成本。它还将使得无法使用 `OP_RETURN` 创建更大的连续数据段。对该想法的反馈中有一些反对意见，认为与 BIP54（也限制最大区块验证成本）相比，这一变更对于较旧的预签名协议会有更大的没收（confiscation）范围，并且它会关闭某些潜在的[软分叉升级][topic soft fork activation]路径（尤其是围绕[量子抗性][topic quantum resistance]方面）。

  * *<!--temporary-soft-fork-to-reduce-data-->**临时软分叉以减少数据*：Dathon Ohm 提交了一个 BIPs [拉取请求][BIPs #2017]并在 Bitcoin-Dev 邮件列表[发布][do post]了一项提议，临时限制比特币交易用于编码数据的方式。虽然该软分叉被描述为[临时性的][topic transitory soft forks]，但邮件列表和拉取请求中的讨论对所提议变更的大量没收范围持批评态度。此外，虽然临时软分叉是可能的，但围绕临时软分叉何时到期的任何争议都会将这个到期时间变成有争议的硬分叉。Peter Todd [展示][pt post tx]了这种方法的局限性，他将提议的 BIP 文本编码成一笔比特币交易，该交易在提议的共识规则下是有效的。

- **<!--post-quantum-signature-aggregation-->****后量子签名聚合**：Tadge Dryja 在 Bitcoin-Dev 邮件列表[发布][td post civ]了一项关于 `OP_CHECKINPUTVERIFY`（`OP_CIV`）操作码的提议，该操作码使锁定脚本能够承诺在同一交易中花费的特定 UTXO。这使得一组相关的 UTXO 可以通过单个授权签名进行花费，效果类似于[跨输入签名聚合][topic cisa]。这种方法比单独的 ECDSA 或 [BIP340][] 签名更昂贵，但在使用数千字节大小的后量子签名时可以节省大量交易 vbytes。`OP_CIV` 还可以用于 [BitVM][topic acc] 等协议中的通用同辈间输入检查。其他提议（如 `OP_CHECKCONTRACTVERIFY`）可以通过承诺同辈间 `scriptPubKeys` 来实现类似的签名共享方案，但具有不同（可能更差）的权衡。

- **<!--native-stark-proof-verification-in-bitcoin-script-->****比特币脚本中的原生 STARK 证明验证**：Abdelhamid Bakhta 在 Delving Bitcoin 论坛[发布][abdel delving]了一项关于新的 [tapscript][topic tapscript] 操作码 `OP_STARK_VERIFY` 的详细提议，该操作码将在比特币脚本中启用特定变体的 STARK 证明验证。这将使得能够在比特币中嵌入任意计算的证明。所提议的操作码不会将证明绑定到任何比特币特定的数据，因此证明仅仅是验证它们自己嵌入的任何计算的证明。这些证明可以使用其他签名方法链接到特定的比特币交易。该帖子讨论了各种用例，例如[有效性 rollups][news222 validity rollups]。

- **<!--bip54-implementation-and-test-vectors-->****BIP54 实现和测试向量**：Antoine Poinsot 在 Bitcoin-Dev 邮件列表[发布][ap bip54 post]了关于他在 [BIP54][] 上的[共识清理][topic consensus cleanup]工作的更新（详见[周报 #348][news348 bip54]）。他提交了 [Bitcoin Inquisition #99][binq bip54 pr]，实现了 BIP54 共识规则。该 PR 包含针对四种缓解措施中每一种的单元测试，可用于为该提议生成测试向量。此外，它包含用于签名操作（sigop）计数逻辑的模糊测试工具和在现实情况下模拟缓解措施行为的功能测试，包括历史违规情况。此外，还开发了一个[自定义矿工][bip54 miner]来生成测试向量所需的完整区块头的链条，以降低对主网区块的需求，例如时间戳和 coinbase 限制。最后，他提交了 [BIPs #2015][]，将生成的测试向量添加到 BIP54。

## 新版本和候选版本

_热门比特币基础设施软件的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。_

- [Core Lightning 25.09.2][] 是这个流行的闪电网络节点当前主要版本的维护版本，包含与 `bookkeeper` 和 `xpay` 相关的多项 bug 修复，其中一些在下面的代码和文档变更部分中有总结。

- [LND 0.20.0-beta.rc3][] 是这个流行的闪电网络节点的候选版本。一项值得测试的改进是对钱包过早重新扫描的修复。

## 重大的代码和文档变更

_本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。_

- [Bitcoin Core #31645][] 将默认的 `dbbatchsize` 配置从 16 MB 增加到 32 MB。此选项决定了在 IBD 或 [assumeUTXO][topic assumeutxo] 快照之后，用于将缓存在内存中的 UTXO 集（由 `dbcache` 设置）刷新到磁盘的批处理大小。此更新主要有利于 HDD 和低端系统。例如，作者报告在具有 500 的 `dbcache` 的树莓派上，刷新时间改进了 30%。用户可以根据需要覆盖默认设置。

- [Core Lightning #8636][] 添加了一个 `askrene-timeout` 配置（默认 10 秒），使 `getroutes` 在达到截止时间后失败。当 `maxparts` 设置为较低值时，`askrene`（参见[周报 #316][news316 askrene]）可能会在容量不足的路由上进入重试循环。此 PR 在该场景下禁用瓶颈路由以确保向前推进。

- [Core Lightning #8639][] 更新了 `bcli`，在与 `bitcoin-cli` 接口时使用 `-stdin`，以避免操作系统相关的 `argv`（命令行参数）大小限制。此更新解决了阻止用户构建大型交易（例如，具有 700 个输入的 [PSBTs][topic psbt]）的问题。还对大型交易的性能进行了其他改进。

- [Core Lightning #8635][] 更新了付款状态管理，在使用 `xpay`（参见[周报 #330][news330 xpay]）或 `injectpaymentonion` 时，只有在创建了出站 [HTLC][topic htlc] 之后才将付款部分标记为待处理。以前，付款部分首先被标记为待处理，如果随后 HTLC 创建失败，该项目可能会在 `listpays` 或 `listsendpays` 中永久保持待处理状态。

- [Eclair #3209][] 添加了一个检查，以确保路由手续费率值不能为负数。以前，设置此值会触发通道强制关闭。

- [Eclair #3206][] 在签名开始但在交换签名之前中止[流动性广告][topic liquidity advertisements]购买时，立即使持有的入站 [HTLC][topic htlc] 失败。以前，Eclair 不会处理这种边缘情况，只会在 HTLC 到期前不久使其失败，不必要地占用发送者的资金。此更改的动机是非恶意移动钱包断开连接并中止的情况。

- [Eclair #3210][] 更新了其权重估算，假设为 73 字节的 DER 编码签名（参见[周报 #6][news6 der]），与 [BOLT3][] 规范以及其他实现（如 LDK）保持一致。这确保了同样假设此大小的对等节点永远不会因手续费支付不足而拒绝来自 Eclair 的 `interactive-tx` 尝试。Eclair 从不生成这些非标准签名。

- [LDK #4140][] 修复了节点重启时出站[异步付款][topic async payments]的过早强制关闭。以前，当一个经常离线的节点重新上线并且出站 [HTLC][topic htlc] 超过其 [CLTV 到期][topic cltv expiry delta] `LATENCY_GRACE_PERIOD_BLOCKS`（3 个区块）时，LDK 会立即强制关闭，在节点可以重新连接并允许对等节点使 HTLC 失败之前。在这种情况下，由于节点不是在竞争认领入站 HTLC，LDK 在 HTLC 的 CLTV 到期后添加了 4,032 个区块的宽限期，然后才强制关闭。

- [LDK #4168][] 删除了 `read_event` 上的标志，该标志发出暂停对等节点消息读取的信号。这使得 `send_data` 成为暂停/恢复信号的唯一真实来源。这修复了一个竞态条件，其中节点可能在 `send_data` 已经恢复读取后从 `read_event` 收到延迟的暂停信号。延迟的暂停会使读取无限期地被禁用，直到节点再次向该对等节点发送消息。

- [Rust Bitcoin #5116][] 更新了 `compute_merkle_root` 和 `compute_witness_root` 的响应，当交易列表包含相邻重复项时返回 `None`。这可以防止变异的[默克尔根漏洞][topic merkle tree vulnerabilities]，CVE 2012-2459，其中具有重复交易的无效区块可以与有效区块共享相同的默克尔根（和区块哈希），导致 Rust Bitcoin 混淆并拒绝两者。此解决方案受到 Bitcoin Core 中类似方案的启发。

- [BTCPay Server #6922][] 引入了 `Subscriptions`（订阅），商家可以通过它定义定期付款方案和计划，并通过结账流程引导用户。该系统跟踪每个订阅者的信用余额，在每个计费周期中扣除。包含一个订阅者门户，用户可以在其中升级或降级计划、查看其信用、历史记录和收据。商家可以设置电子邮件提醒，以在付款即将到期时通知用户。虽然这不会引入自动收费，但计划中的 [Nostr Wallet Connect (NWC)][news290 nwc] 集成可以使某些钱包实现这一点。

{% include snippets/recap-ad.md when="2025-11-11 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2015,2017,31645,8636,8639,8635,3209,3206,3210,4140,4168,5116,6922" %}
[sebastion delving]: https://delvingbitcoin.org/t/comparing-the-performance-of-ecdsa-signature-validation-in-openssl-vs-libsecp256k1-over-the-last-decade/2087
[libsecp benchmark code]: https://github.com/theStack/secp256k1-plugbench
[ph 520spk post]: https://gnusha.org/pi/bitcoindev/6f6b570f-7f9d-40c0-a771-378eb2c0c701n@googlegroups.com/
[do post]: https://gnusha.org/pi/bitcoindev/AWiF9dIo9yjUF9RAs_NLwYdGK11BF8C8oEArR6Cys-rbcZ8_qs3RoJURqK3CqwCCWM_zwGFn5n3RECW_j5hGS01ntGzPLptqcOyOejunYsU=@proton.me/
[pt post tx]: https://gnusha.org/pi/bitcoindev/aP6gYSnte7J86g0p@petertodd.org/
[td post civ]: https://gnusha.org/pi/bitcoindev/05195086-ee52-472c-962d-0df2e0b9dca2n@googlegroups.com/
[abdel delving]: https://delvingbitcoin.org/t/proposal-op-stark-verify-native-stark-proof-verification-in-bitcoin-script/2056
[news222 validity rollups]: /zh/newsletters/2022/10/19/#rollup
[ap bip54 post]: https://groups.google.com/g/bitcoindev/c/1XEtmIS_XRc
[news348 bip54]: /zh/newsletters/2025/04/04/#draft-bip-published-for-consensus-cleanup
[binq bip54 pr]: https://github.com/bitcoin-inquisition/bitcoin/pull/99
[bip54 miner]: https://github.com/darosior/bitcoin/commits/bip54_miner/
[LND 0.20.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.0-beta.rc3
[Core Lightning 25.09.2]: https://github.com/ElementsProject/lightning/releases/tag/v25.09.2
[news316 askrene]: /zh/newsletters/2024/08/16/#core-lightning-7517
[news330 xpay]: /zh/newsletters/2024/11/22/#core-lightning-7799
[news6 der]: /zh/newsletters/2018/07/31/#the-maximum-size-of-a-bitcoin-der-encoded-signature-is
[news290 nwc]: /zh/newsletters/2024/02/21/#nwc
