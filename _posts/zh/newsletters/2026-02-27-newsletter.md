---
title: 'Bitcoin Optech Newsletter #394'
permalink: /zh/newsletters/2026/02/27/
name: 2026-02-27-newsletter-zh
slug: 2026-02-27-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报介绍了一项为输出脚本描述符附加补充信息的 BIP 草案。此外还包括我们的常规栏目：总结 Bitcoin Stack Exchange 的热门问题和答案、新版本和候选版本的公告，以及介绍热门比特币基础设施软件的近期变更。

## 新闻

- **<!--draft-bip-for-output-script-descriptor-annotations-->输出脚本描述符注解的 BIP 草案：** Craig Raw 在 Bitcoin-Dev 邮件列表上[发帖][annot ml]，介绍了一个新的 BIP 构想，以回应围绕 BIP392 的讨论中出现的反馈（见[周报 #387][news387 sp]）。据 Raw 介绍，诸如以区块高度表示的钱包生日之类的元数据，可以让[静默支付][topic silent payments]扫描更加高效。然而，这类元数据在技术上并非确定输出脚本所必需的，因此被认为不适合包含在[描述符][topic descriptors]中。

  Raw 的 BIP 提议以注解的形式提供这些有用的元数据，将其表示为键/值对，并使用类似 URL 查询串的分隔符直接附加到描述符字符串之后。带注解的描述符将如下所示：`SCRIPT?key=value&key=value#CHECKSUM`。值得注意的是，字符 `?`、`&` 和 `=` 已在 [BIP380][] 中定义，因此校验和算法无需更新。

  在[草案 BIP][annot draft]中，Raw 还定义了三个初始注解键，专门用于提高静默支付资金的扫描效率：

  * 区块高度 `bh`：钱包首次收到资金的区块高度；

  * 间隙限制 `gl`：停止之前要派生的未使用地址数量；

  * 最大标签 `ml`：静默支付钱包要扫描的最大标签索引。

  最后，Raw 指出，这些注解不应被用于通用的钱包备份流程，而只应用于在不改变描述符所生成脚本的前提下，提高资金恢复效率。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选之地，也是我们有闲暇时会给好奇和困惑的用户帮忙的地方。在这个月度栏目中，我们会列举自上次出刊以来出现的一些高票的问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [比特币 BIP324 v2 P2P 传输是否可与随机流量区分？]({{bse}}130500)
  Pieter Wuille 指出，[BIP324][] 的 [v2 加密传输][topic v2 p2p transport]协议支持流量模式整形，尽管目前还没有已知软件实现这一功能。他总结道：“当前的实现仅能抵御涉及已发送字节模式的协议签名，而无法抵御基于流量模式的签名。”

- [如果矿工只广播区块头却从不提供区块会怎样？]({{bse}}130456)
  用户 bigjosh 概述了矿工在 P2P 网络上收到区块头、但尚未收到区块内容时可能采取的行为：在该区块之上挖一个空区块。Pieter Wuille 澄清说，实际上许多矿工是通过监控其他矿池分发给矿工的工作来获知新区块头的，这种技术被称为间谍挖矿（spy mining）。

## 新版本和候选版本

_热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。_

- [Bitcoin Core 28.4rc1][] 是之前一个主要版本系列的维护版本候选版本。其主要内容是钱包迁移修复，以及移除一个不可靠的 DNS 种子。

- [Rust Bitcoin 0.33.0-beta][] 是这个用于处理比特币数据结构的库的 beta 版本。这是一次包含 300 多个提交的大型更新，引入了新的 `bitcoin-consensus-encoding` crate，加入了 P2P 网络消息编码 trait，在解码时拒绝包含重复输入或输出总额超过 `MAX_MONEY` 的交易，并提升了所有子 crate 的主版本号。

## 重大代码和文档变更

*本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals（BIPs）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Bitcoin Core #34568][] 对 Mining IPC 接口进行了多项破坏性变更（见[周报 #310][news310 mining]）。它移除了已弃用的方法 `getCoinbaseRawTx()`、`getCoinbaseCommitment()` 和 `getWitnessCommitmentIndex()`（见[周报 #388][news388 mining]），为 `createNewBlock` 和 `checkBlock` 添加了 `context` 参数，从而使它们可以在单独的线程上运行，而不会阻塞 [Cap'n Proto][capn proto] 事件循环，并在 schema 中声明了默认选项值。`Init.makeMining` 的版本号也被提升，以便旧客户端收到明确的错误，而不是静默地误解新 schema。这里的线程变更是下面介绍的冷却功能的前提。

- [Bitcoin Core #34184][] 为 Mining IPC 接口的 `createNewBlock()` 方法添加了一个可选的冷却期。启用后，该方法在返回区块模板之前，总是会等待初始区块下载（IBD）完成，并等待链尖追上最新状态。这可以防止 [Stratum v2][topic pooled mining] 客户端在启动时被迅速过时的模板淹没。该 PR 还添加了新的 `interrupt()` 方法，使 IPC 客户端能够干净地中止被阻塞的 `createNewBlock()` 或 `waitTipChanged()` 调用。

- [Bitcoin Core #24539][] 添加了新的 `-txospenderindex` 选项，用来维护一个索引，记录每个已确认输出是被哪笔交易花费的。启用后，`gettxspendingprevout` RPC 除了现有的交易池查找外，还会返回已确认交易的 `spendingtxid` 和 `blockhash`。该 RPC 还增加了两个新的可选参数：`mempool_only` 会在索引可用时依然将查找限制在交易池中，`return_spending_tx` 则返回完整的花费交易。该索引不需要 `-txindex`，但与修剪模式不兼容。这对闪电网络和其他需要追踪花费交易链条的二层协议特别有用。

- [Bitcoin Core #34329][] 添加了两个用于管理私有交易广播的新 RPC（见[周报 #388][news388 private]）：`getprivatebroadcastinfo` 返回当前私有广播队列中的交易信息，包括选定的对等节点地址以及每次广播发送的时间；`abortprivatebroadcast` 则取消某笔特定交易的广播及其尚未完成的连接。

- [Bitcoin Core #28792][] 完成了嵌入式 ASMap 系列 PR，将 ASMap 数据直接打包进 Bitcoin Core 二进制文件中，使启用 `-asmap` 的用户不再需要单独获取数据文件。移除构建选项 `WITH_EMBEDDED_ASMAP` 则可以排除这部分数据。ASMap 通过在自治系统之间多样化对等节点连接来提高对[日蚀攻击][topic eclipse attacks]的抵抗力（见[周报 #52][news52 asmap] 和 [#290][news290 asmap]）。这一功能默认仍然关闭；用户仍需显式指定 `-asmap` 才能启用它。一份新的[文档文件][github asmap-data]概述了获取这份数据并将其纳入 Bitcoin Core 发布版本的流程。

- [Bitcoin Core #32138][] 移除了 `settxfee` RPC 和 `-paytxfee` 启动选项，这些选项曾允许用户为所有交易设置静态费率。两者已在 Bitcoin Core 30.0 中弃用（见[周报 #349][news349 settxfee]）。用户应改为依赖[手续费估算][topic fee estimation]或为每笔交易单独设置费率。

- [Bitcoin Core #34512][] 在 `getblock` RPC 响应的详细级别 1 及以上添加了 `coinbase_tx` 字段，其中包含 coinbase 交易的 `version`、`locktime`、`sequence`、`coinbase` 脚本和 `witness` 数据。为了保持响应紧凑，输出被有意省略。此前，若要访问 coinbase 的这些属性，必须使用详细级别 2，而这会解码区块中的每一笔交易。这对于监控 [BIP54][]（[共识清理][topic consensus cleanup]）对 coinbase locktime 的要求，或根据 coinbase 脚本识别矿池，都很有帮助。

- [Core Lightning #8490][] 添加了新的 `payment-fronting-node` 配置选项，用来指定一个或多个节点，始终作为入站支付的入口点。设置后，[BOLT11][] 发票中的路由提示，以及 [BOLT12][topic offers] 要约、发票和发票请求中的[盲化路径][topic rv routing]引入点，都将只使用这些指定的前置节点来构造。此前，CLN 会自动从节点的通道对等方中进行选择，这可能导致不同发票暴露出不同的对等方。该选项既可以全局设置，也可以按要约单独覆盖。

- [Eclair #3250][] 允许 `OpenChannelInterceptor` 在本地节点开启通道时，如果未显式设置 `channel_type`，就自动选择一个。此前，自动创建通道的流程，例如由 LSP 向客户端开启通道，如果没有提供类型就会失败。当前默认优先选择[锚点通道][topic anchor outputs]；预计[简单 taproot 通道][topic simple taproot channels]会在后续 PR 中获得更高优先级。

- [LDK #4373][] 添加了对发送[多路径支付][topic multipath payments]的支持，允许本地节点只支付发票总额的一部分。`RecipientOnionFields` 中新增的 `total_mpp_amount_msat` 字段，允许声明一个大于本节点发送金额的 MPP 总额，从而使多个钱包或节点可以各自贡献一部分支付，协作支付同一张发票。接收者会从所有参与贡献的节点收集 HTLC，并在全额到账后领取这笔支付。对 [BOLT12][topic offers] 的支持则留待后续实现。

- [BDK #2081][] 为 `SpkTxOutIndex` 和 `KeychainTxOutIndex` 添加了 `spent_txouts()` 和 `created_txouts()` 方法；给定一笔交易，它们会返回该交易花费了哪些被追踪的输出，以及创建了哪些新的被追踪输出。这使钱包可以轻松确定其所关心的交易涉及哪些地址和金额。

{% include references.md %}
{% include linkers/issues.md v=2 issues="34568,34184,24539,34329,28792,32138,34512,8490,3250,4373,2081" %}

[annot ml]: https://groups.google.com/g/bitcoindev/c/ozjr1lF3Rkc
[news387 sp]: /zh/newsletters/2026/01/09/#draft-bip-for-silent-payment-descriptors
[annot draft]: https://github.com/craigraw/bips/blob/descriptorannotations/bip-descriptorannotations.mediawiki
[news310 mining]: /zh/newsletters/2024/07/05/#bitcoin-core-30200
[news388 mining]: /zh/newsletters/2026/01/16/#bitcoin-core-33819
[news388 private]: /zh/newsletters/2026/01/16/#bitcoin-core-29415
[capn proto]: https://capnproto.org/
[news52 asmap]: /zh/newsletters/2019/06/26/#differentiating-peers-based-on-asn-instead-of-address-prefix
[news290 asmap]: /zh/newsletters/2024/02/21/#improved-reproducible-asmap-creation-process-asmap
[github asmap-data]: https://github.com/bitcoin/bitcoin/blob/master/doc/asmap-data.md
[news349 settxfee]: /zh/newsletters/2025/04/04/#bitcoin-core-31278
[Bitcoin Core 28.4rc1]: https://bitcoincore.org/bin/bitcoin-core-28.4/test.rc1/
[Rust Bitcoin 0.33.0-beta]: https://github.com/rust-bitcoin/rust-bitcoin/releases/tag/bitcoin-0.33.0-beta
