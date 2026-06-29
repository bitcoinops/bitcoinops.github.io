---
title: 'Bitcoin Optech 周报 #407'
permalink: /zh/newsletters/2026/05/29/
name: 2026-05-29-newsletter-zh
slug: 2026-05-29-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报披露了一项负责任公开的漏洞：远程对等节点可利用它使 Core Lightning 节点崩溃；此外还链接到近期 Bitcoin Core 开发者会议的文字记录。此外还包括我们的常规栏目：新版本和候选版本的公告，以及流行比特币基础设施软件的重大变更介绍。

## 新闻

- **<!--core-lightning-assertion-dos-disclosure-->****Core Lightning 断言型 DoS 漏洞披露：** Chandra Pratap 在 Delving Bitcoin 上[发帖][cln dos delving]，披露了一项在 Summer of Bitcoin 2025 实习期间发现的拒绝服务漏洞。该漏洞影响接受入站通道的 Core Lightning 节点。

  在通道开启握手期间，远程对等节点会发送一条消息，其中包含拟议注资交易的 txid。Core Lightning 会执行一个断言检查，要求该 txid 非零。当某个对等节点发送一个全零 txid 时，断言会失败并导致节点崩溃。由于任何对等节点都可以发起通道开启握手并发送这一恶意消息，这就允许远程攻击者可靠地使任何接受入站通道的脆弱节点崩溃。

  该漏洞通过模糊测试发现，并已进行[负责任披露][topic responsible disclosures]。在报告时，Rusty Russell 恰好正在独立处理另一个崩溃 bug，而他的修复也顺带解决了这个漏洞。该漏洞已在 [Core Lightning 26.04][news402 cln2604] 中修复。

- **<!--bitcoin-core-developer-meeting-transcripts-->****Bitcoin Core 开发者会议文字记录：** 多位 Bitcoin Core 开发者在 5 月线下会面，会议的文字记录现已[发布][coredev 2026-05]。议题包括 [SwiftSync][coredev swiftsync]、[后族群交易池][coredev post-cluster]、[Erlay 重新设计][coredev erlay]、[交易包中继][coredev pkg relay]、[静默支付][coredev silent payments]、[TCP hole punching][coredev tcp holepunch]（见[周报 #406][news406 tcp holepunch]）、[私有广播][coredev private broadcast]、[现代密码学库][coredev modern crypto] 和[变异测试][coredev mutation testing]等。

## 版本发布和候选版本

_热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。_

- [Eclair v0.14.0][] 是这个流行闪电网络节点实现的最新版本。它包含[拼接][topic splicing]、[简单 taproot 通道][topic simple taproot channels]和[零手续费承诺][topic v3 commitments]的最终版本，移除了对非[锚点输出][topic anchor outputs]通道的支持，并增加了用于流动性和路由优化的实验性对等节点评分功能。

- [Core Lightning 26.06rc2][] 是这个流行闪电网络节点下一个主要版本的候选发布，包含新的 `graceful`、`sendamount` 和 `xkeysend` RPC，开始弃用 `pay` 并转向 `xpay`，并增加了 [BOLT12][topic offers] payer-proof RPC 支持。

## 重大代码和文档变更

_以下是来自 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案 (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期重大变更。_

- [Bitcoin Core #33966][] 重构了 Mining IPC 接口对挖矿区块模板选项的处理方式（见[周报 #310][news310 mining]和[#323][news323 mining]）。此前，启动时的挖矿选项（如 `blockmaxweight`、`blockreservedweight` 和 `blockmintxfee`）与 IPC 挖矿客户端在运行时传入的选项是分开处理的。现在，这些选项会被解析到一个共享的 `BlockCreateOptions` 对象中，并在创建或更新区块模板时进行合并。对于无效组合——例如保留区块权重大于最大区块权重——现在会直接拒绝，而不是悄悄调整到合法范围。

- [Bitcoin Core #34917][] 停止在钱包交易 RPC `listtransactions`、`listsinceblock` 和 `gettransaction` 中返回已弃用的 `bip125-replaceable` 字段，不过用户仍可通过 `-deprecatedrpc=bip125` 选项请求该字段。该 PR 还弃用了 `-walletrbf` 启动选项；现在它会发出警告，并计划在下一个版本中移除。关于此前移除与 [RBF][topic rbf] 相关字段的工作，见[周报 #403][news403 rbf]。

- [Bitcoin Core #35017][] 更新了[交易包][topic package relay]提交流程，以防止在发生意外验证失败后，后续交易仍留在交易池中。在交易包提交期间，交易会按顺序处理，因此后面的交易可以花费先前已加入交易池的交易。此前，如果某笔交易在较晚阶段的验证检查（例如共识脚本检查）中失败，Bitcoin Core 只会移除该笔交易。现在，它还会移除该交易包中所有后续交易，从而防止父交易被移除后，其子交易仍留在交易池中。

- [BIPs #1944][] 添加了 [BIP449][]，这是一个关于 `OP_TWEAKADD` 的软分叉草案提案。`OP_TWEAKADD` 是一个 [tapscript][topic tapscript] 操作码，用于计算 tweak 后的 x-only 公钥（见[周报 #370][news370 tweak]）。给定一个 32 字节的 x-only 公钥和一个 32 字节的标量 tweak，该操作码会把 `P + tG` 对应的 x-only 公钥压入栈中。这将允许脚本直接验证密钥 tweak 关系，从而实现诸如 tweak-reveal 脚本、签名顺序证明以及[签名委托][topic signer delegation]协议等构造。

- [BIPs #2108][] 添加了 [BIP450][]，即 Formosa，这是一份将与 [BIP39][] 兼容的钱包熵编码为故事式助记词短语的草案规范。Formosa 不再使用随机的 BIP39 单词，而是使用按主题定义的词表来编码熵，从而生成简短、结构化的句子。这些“故事”可以被解码回原始熵，并在派生种子之前转换为标准 BIP39 助记词，因此保持了与 BIP39 的兼容性。

- [Eclair #3192][] 为[零手续费承诺][topic v3 commitments]（0FC）通道增加了实验性支持，跟进了[周报 #404][news404 0fc]中介绍的规范。该特性默认关闭，可通过 `eclair.features.zero_fee_commitments = optional` 启用。

- [LDK #4584][] 将 `payment_metadata` 映射添加到 [BOLT12][topic offers] 的盲化消息和支付路径上下文中。这为通过[盲化路径][topic rv routing]携带接收方元数据并在收到支付时恢复它们提供了基础设施，类似于 [BOLT11][] 的 `payment_metadata`。目前仍不支持构建带有 metadata 的要约。这些 metadata 被存储为从数值键到字节数组的映射，从而允许将多个彼此独立的数据项附加到同一笔支付上。

- [LDK #4628][] 开始在创建入站支付时加密 [BOLT11][] `payment_metadata`，建立在[周报 #405][news405 metadata]介绍的 metadata 承诺机制之上。在验证支付之后，LDK 会解密 metadata，使应用能够在不将其暴露给付款人、也无需自行实现加密的情况下访问发票元数据。

- [LND #10552][] 为基于 [Neutrino][topic compact block filters] 的 LND 节点增加了快速初始同步功能：在恢复正常 P2P 同步之前，允许它们先从本地文件或 HTTP(S) 来源导入预构建的比特币区块头和致密区块过滤器。新的 `neutrino.blockheaderssource` 和 `neutrino.filterheaderssource` 选项必须一同配置。导入的区块头会在本地验证，之后 Neutrino 再从网络对等节点获取导入链尖之后的区块头。

- [LND #10820][] 防止 LND 在开启公开通道时隐式选择[简单 taproot 通道][topic simple taproot channels]，因为 taproot [通道公告][topic channel announcements] 目前尚未得到支持。此前，如果双方对等节点都广告支持该通道类型，LND 可能会选中它，随后又拒绝开启。现在，简单 taproot 通道必须被显式请求；而隐式协商仍可选择 legacy、static remote key 或[锚点][topic anchor outputs]通道类型。该 PR 还更新了 `lncli openchannel --channel_type=taproot`，使其选择生产用的简单 taproot 通道类型。

{% include snippets/recap-ad.md when="2026-06-02 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33966,34917,35017,3192,4584,4628,10552,10820,2108,1944" %}
[cln dos delving]: https://delvingbitcoin.org/t/vulnerability-disclosure-assertion-dos-in-core-lightning/2507
[news402 cln2604]: /zh/newsletters/2026/04/24/#core-lightning-26-04
[coredev 2026-05]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05
[coredev swiftsync]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/swiftsync
[coredev post-cluster]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/post-cluster-mempool
[coredev erlay]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/erlay-redesign
[coredev pkg relay]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/package-relay
[coredev silent payments]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/silent-payments
[coredev tcp holepunch]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/tcp-holepunch
[news406 tcp holepunch]: /zh/newsletters/2026/05/22/#tcp-hole-punching-for-bitcoin-nodes-behind-nats
[coredev private broadcast]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/private-broadcast
[coredev modern crypto]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/modern-crypto-library
[coredev mutation testing]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/mutation-testing
[Eclair v0.14.0]: https://github.com/ACINQ/eclair/releases/tag/v0.14.0
[Core Lightning 26.06rc2]: https://github.com/ElementsProject/lightning/releases/tag/v26.06rc2
[news310 mining]: /zh/newsletters/2024/07/05/#bitcoin-core-30200
[news323 mining]: /zh/newsletters/2024/10/04/#bitcoin-core-30510
[news403 rbf]: /zh/newsletters/2026/05/01/#bitcoin-core-34911
[news404 0fc]: /zh/newsletters/2026/05/08/#bolts-1228
[news405 metadata]: /zh/newsletters/2026/05/15/#ldk-4528
[news370 tweak]: /zh/newsletters/2025/09/05/#draft-bip-for-op-tweakadd
