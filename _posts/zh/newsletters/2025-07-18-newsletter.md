title: 'Bitcoin Optech Newsletter #363'
permalink: /zh/newsletters/2025/07/18/
name: 2025-07-18-newsletter-zh
slug: 2025-07-18-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报包括我们的常规部分：总结了服务和客户端软件的更新、新版本和候选版本的公告，以及对热门比特币基础设施软件的重大变更介绍。

## 新闻

_本周在我们的[来源][sources]中没有发现重大新闻。_

## 服务和客户端软件变更

*在这个月度专题中，我们会重点介绍比特币钱包和服务的有趣更新。*

- **<!--floresta-v0-8-0-released-->****Floresta v0.8.0 发布：**
  [Floresta v0.8.0][floresta v0.8.0] 版本的这个 [Utreexo][topic utreexo] 节点增加了对 [P2P 传输协议第 2 版 (BIP324)][topic v2 p2p transport]、[testnet4][topic testnet] 的支持，增强了指标和监控功能，以及其他功能和错误修复。

- **<!--rgb-v0-12-announced-->****RGB v0.12 发布：**
  RGB v0.12 [博客文章][rgb blog] 宣布发布了 RGB 的共识层，用于比特币测试网和主网上的 RGB [客户端验证][topic client-side validation] 智能合约。

- **<!--frost-signing-device-available-->****FROST 签名设备可用：**
  [Frostsnap][frostsnap website] 签名设备支持使用 FROST 协议的 k-of-n [阈值签名][topic threshold signature]，在链上只需一个签名。

- **<!--gemini-adds-taproot-support-->****Gemini 增加 taproot 支持：**
  Gemini 交易所和 Gemini 托管服务增加了对发送（提款）到 [taproot][topic taproot] 地址的支持。

- **<!--electrum-4-6-0-released-->****Electrum 4.6.0 发布：**
  [Electrum 4.6.0][electrum 4.6.0] 增加了对[潜水艇互换][topic submarine swaps] 的支持，使用 nostr 进行发现。

## 新版本和候选版本

*热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [LND v0.19.2-beta][] 是这个热门闪电网络节点的维护版本。它“包含重要的错误修复和性能改进”。

## 重大的代码和文档变更

*本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals（BIPs）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Bitcoin Core #32604][] 对无条件写入磁盘的日志（如 `LogPrintf`、`LogInfo`、`LogWarning` 和 `LogError`）进行了速率限制，通过给每个源代码位置每小时 1 MB 的配额来减轻磁盘填充攻击。当任何源代码位置被抑制时，所有日志行前面都会加上星号 (*)。控制台输出、带有显式类别参数的日志以及初始区块下载 (IBD) 的 `UpdateTip` 消息不受速率限制。当配额重置时，Core 会打印被丢弃的字节数。

- [Bitcoin Core #32618][] 移除了 `include_watchonly` 选项及其变体，以及所有钱包 RPC 中的 `iswatchonly` 字段，因为[描述符][topic descriptors]钱包不支持混合使用只读和可花费描述符。以前，用户可以将只读地址或脚本导入到传统支出钱包中。然而，传统钱包现在已被移除。

- [Bitcoin Core #31553][] 通过引入 `TxGraph::Trim()` 函数，为[族群交易池][topic cluster mempool]项目添加了区块重组处理功能。当重组将先前确认的交易重新引入交易池，且结果组合的族群超过族群数量或权重策略限制时，`Trim()` 会构建一个按费率排序、尊重依赖关系的基本线性化。如果添加交易会违反限制，则该交易及其所有后代都会被丢弃。

- [Core Lightning #7725][] 添加了一个轻量级 JavaScript 日志查看器，可在浏览器中加载 CLN 日志文件，并允许用户按守护进程、类型、通道或正则表达式过滤消息。这个工具在提高开发人员和节点运营者的调试体验的同时，最小化了存储库维护开销。

- [Eclair #2716][] 为 [HTLC 背书][topic htlc endorsement] 实现了一个本地对等节点声誉系统，该系统跟踪每个入账对等节点赚取的路由费用与基于所使用的流动性和 [HTLC][topic htlc] 槽位应该赚取的费用。成功的支付会得到完美分数，失败的支付会降低分数，而超过配置阈值仍处于待处理状态的 HTLC 会受到严重惩罚。在转发时，节点会在 `update_add_htlc` 背书 TLV 中包含其当前对等节点分数（参见周报 [#315][news315 htlc]）。运营者可以在配置中调整声誉衰减（`half-life`）、卡住支付阈值（`max-relay-duration`）、卡住 HTLC 的惩罚权重（`pending-multiplier`），或者完全禁用声誉系统。这个 PR 主要是收集数据以改进[通道阻塞攻击][topic channel jamming attacks]研究，尚未实施惩罚措施。

- [LDK #3628][] 实现了[异步支付][topic async payments]的服务器端逻辑，允许 LSP 节点代表经常离线的接收者提供 [BOLT12][topic offers] 静态发票。LSP 节点可以接受来自接收者的 `ServeStaticInvoice` 消息，存储提供的静态发票，并通过搜索并通过[盲路径][topic rv routing]返回缓存的发票来响应付款人的发票请求。

- [LDK #3890][] 改变了其路径查找算法中的路由评分方式，考虑总成本除以通道金额限制（每可用容量 sat 的成本），而不是仅考虑原始总成本。这使选择偏向于更高容量的路由，并减少了过度的 [MPP][topic multipath payments] 分片，从而提高了支付成功率。尽管这一变化过度惩罚了小通道，但与之前的过度分片相比，这种权衡是更可取的。

- [LND #10001][] 在生产环境中启用了 “通道静默（quiescence）” 协议（参见周报 [#332][news332 quiescence]），并添加了一个新的配置值 `--htlcswitch.quiescencetimeout`，该值指定通道可以保持静默状态的最大持续时间。该值确保依赖的协议，如[动态承诺][topic channel commitment upgrades]，在超时期限内完成。默认值为 60 秒，最小值为 30 秒。

{% include snippets/recap-ad.md when="2025-07-22 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32604,32618,31553,7725,2716,3628,3890,10001" %}
[LND v0.19.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.2-beta
[sources]: /en/internal/sources/
[floresta v0.8.0]: https://github.com/vinteumorg/Floresta/releases/tag/v0.8.0
[rgb blog]: https://rgb.tech/blog/release-v0-12-consensus/
[frostsnap website]: https://frostsnap.com/
[electrum 4.6.0]: https://github.com/spesmilo/electrum/releases/tag/4.6.0
[news315 htlc]: /zh/newsletters/2024/08/09/#eclair-2884
[news332 quiescence]: /zh/newsletters/2024/12/06/#lnd-8270