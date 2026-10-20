---
title: 'Bitcoin Optech 周报 #409'
permalink: /zh/newsletters/2026/06/12/
name: 2026-06-12-newsletter-zh
slug: 2026-06-12-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报介绍了一份草案 BIP，提议用一个后继测试网络取代 testnet4 测试网络。此外还包括我们的常规栏目：宣布新版本与候选版本，并总结流行比特币基础设施软件的重要代码变更。

## 新闻

- **<!--draft-bip-for-testnet5-->****testnet5 的草案 BIP：** Pol Espinasa 在 Bitcoin-Dev 邮件列表上[发帖][testnet5 ml]，发布了一份[草案 BIP][testnet5 BIP]，由他与 Fabian Jahr 共同起草，提议用 testnet5 取代 [testnet4][topic testnet]。
  该提案的动机，是 testnet4 的可靠性较低；而这一问题源于难度例外规则持续被利用（也称“20 分钟规则”）。该规则允许 CPU 矿工在前一个区块出块 20 分钟后，以难度 `1` 挖出新区块，从而产生“区块风暴”：也就是在短时间内挖出大量低难度区块（见[周报 #311][news311 block storm]）。

  这份草案 BIP 提议删除难度例外规则，使 testnet 的行为尽可能贴近主网。testnet5 除了两项改动之外，将遵循与主网相同的共识规则：从区块 `1` 开始激活 [BIP54][]（[共识清理软分叉][topic consensus cleanup]），并将工作量证明目标值的最大上限设为 `0x1a0fffff`（比 testnet4 的最大目标值更低，也就是最小难度更高）。

  Espinasa 邀请其他开发者对该提案提出反馈。邮件列表线程中的讨论主要围绕几个问题展开：是给 testnet4 打补丁还是另起一个新网络、testnet 代币被预挖的可能性，以及新网络应采用怎样的最小难度才最合适。

## 版本和候选版本

_流行比特币基础设施项目的新版本和候选版本。请考虑升级到新版本，或帮助测试候选版本。_

- [LND 0.21.0-beta][] 是这一流行 LN 节点实现的下一个主要版本发布。它新增了基础的[洋葱消息][topic onion messages]转发、可用于生产环境的简单 [Taproot][topic taproot] 通道，并支持使用 [RBF][topic rbf] 进行合作关闭，还增加了通道关闭的重组保护、基于 [Neutrino][topic compact block filters] 的节点的更快初始同步、一个可选的原生 SQL 支付存储迁移，以及多项漏洞修复。

- [Core Lightning 26.06.1][] 是这一流行 LN 节点当前主版本的维护版本。它修复了运行 `make install` 后 `bwatch` 插件注册失败的问题。

## 重大的代码和文档变更

_以下是来自 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期重大变更。_

- [Bitcoin Core #35410][] 修复了一个漏洞：它可能导致一次[私密交易广播][topic transaction origin privacy]重试直接连接到某个 IPv4 或 IPv6 对等节点，而不是通过 [Tor 或 I2P][topic anonymity networks]。当 `sendrawtransaction` 与 `-privatebroadcast=1` 一起使用时（见[周报 #388][news388 private broadcast]），Bitcoin Core 会强制通过 Tor 或 I2P 代理来建立交易广播连接。如果其中一条连接尝试使用 [BIP324][] v2 传输但失败，就会回退并重试 v1 传输。此前，在那些平时会直接建立 IPv4/IPv6 连接的节点上，这次重试可能会忘记私密广播所要求的代理覆盖设置。现在，这个代理覆盖设置会被保存下来，并在从 v2 回退到 v1 的重新连接过程中继续沿用。

- [Bitcoin Core #34779][] 实现了 [BIP323][]，将区块头 `nVersion` 的第 5 位到第 28 位保留为矿工可用的额外 nonce 空间（见[周报 #405][news405 bip323]）。此前，这些比特位属于 [BIP9][] 版本位告警逻辑的监控范围，用于检测未知软分叉信号。Bitcoin Core 现在会把 [BIP323][] 保留的这些比特位排除在该告警逻辑之外，避免矿工在使用它们进行 nonce 滚动时触发未知软分叉告警。

- [Bitcoin Core #32150][] 重写了[分支定界法][branch-and-bound] [coin selection][topic coin selection]算法，以避免回溯搜索树中那些只会重新产生等价输入集合的部分。新搜索过程不再反复回溯并重新测试相同的选择前缀，而是会跟踪下一个要尝试的 UTXO，剪掉无法达到目标值的分支，直接跳到下一个有意义的候选项，并跳过那些具有相同有效值、但重复或浪费更多手续费的 UTXO。这样一来，钱包就能把迭代预算用于更多彼此不同的候选选择。

- [LDK #4647][] 停止在 [BOLT12][topic offers] 的[盲化消息路径][topic rv routing]中使用远端引介节点，以避免与 LND 可选启用的[洋葱消息][topic onion messages]支持不兼容；后者可能会接收来自非通道对等节点的消息，但不会转发这些消息。LDK 现在改为使用已公布的接收者自身作为引介点，这提高了互操作性，但会降低接收者的隐私性。

- [BTCPay Server #7218][] 为 BTC 多签名钱包增加了一个带引导的设置流程。商店所有者可以选择签名策略，邀请商店用户手动提交签名者密钥或通过 BTCPay Server Vault 提交，检查生成的地址，并在收集到所需密钥后创建钱包。

- [BIPs #2186][] 更新了 [BIP77][]，规定 [payjoin v2][topic payjoin] 接收者应如何回复兼容 [BIP78][] 的发送者。[BIP77][] 的常规回复路径，会使用发送者提供的一把回复密钥来加密提议的 [PSBT][topic psbt]，并将其投递到一个由发送者派生出的回复邮箱中；但 [BIP78][] 发送者并不提供回复密钥。作为替代，接收者会把经过 base64 编码的提议 PSBT 写回接收者自己的邮箱，而发送者此前正是把原始 PSBT 发布在这个邮箱里。接收者使用一个经过 OHTTP 封装的 PUT 请求，将其提交给目录服务器。该更新记录了实现中已经在使用的这一条向后兼容的回复路径。

{% include snippets/recap-ad.md when="2026-06-16 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="35410,34779,32150,4647,7218,2186" %}

[testnet5 ml]: https://groups.google.com/g/bitcoindev/c/kGUMTxOvdJA/m/Eyx5FxQeAAAJ
[testnet5 BIP]: https://github.com/bitcoin/bips/pull/2196
[news311 block storm]: /zh/newsletters/2024/07/12/#how-does-the-20-min-exception-rule-work-in-testnet-3-how-does-this-lead-to-the-block-storm-bug-testnet-3-20
[LND 0.21.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.21.0-beta
[Core Lightning 26.06.1]: https://github.com/ElementsProject/lightning/releases/tag/v26.06.1
[news388 private broadcast]: /zh/newsletters/2026/01/16/#bitcoin-core-29415
[news405 bip323]: /zh/newsletters/2026/05/15/#bips-2116
[branch-and-bound]: https://zh.wikipedia.org/wiki/分支定界