---
title: 'Bitcoin Optech Newsletter #392'
permalink: /zh/newsletters/2026/02/13/
name: 2026-02-13-newsletter-zh
slug: 2026-02-13-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报总结了关于改善最坏情况下静默支付扫描性能的讨论，并描述了一种在单个密钥中实现多种花费条件的想法。此外还包括我们的常规栏目：新版本和候选版本的公告，以及流行比特币基础设施软件的重大变更介绍。

## 新闻

- **<!--proposal-to-limit-the-number-of-per-group-silent-payment-recipients-->****限制每组静默支付接收方数量的提案**：Sebastian Falbesoner 在 Bitcoin-Dev 邮件列表上[发帖][kmax mailing list]介绍了一种针对[静默支付][topic silent payments]接收方的理论攻击的发现和缓解方案。该攻击发生在攻击者构造一笔包含大量 taproot 输出（根据当前共识规则，每个区块最多 23255 个输出）且全部指向同一实体的交易时。如果不限制组大小，处理将需要数分钟而非数十秒。

  这促使了一项缓解措施的提出：添加一个新参数 `K_max`，限制单笔交易中每组接收方的数量。理论上，这一变更不向后兼容，但实际上，对于足够高的 `K_max` 值，现有的静默支付钱包都不会受到影响。Falbesoner 提议将 `K_max` 设为 1000。

  Falbesoner 正在征求对该限制提案的反馈或疑虑。他还指出，大多数静默支付钱包开发者已被通知并了解该问题。

- **<!--blisk-boolean-circuit-logic-integrated-into-the-single-key-->****BLISK：集成布尔电路逻辑到单一密钥**：Oleksandr Kurbatov 在 Delving Bitcoin 上[发帖][blisk del]介绍了 BLISK，一种旨在使用布尔逻辑表达复杂授权策略的协议。BLISK 试图解决当前花费策略的局限性。例如，[MuSig2][topic musig] 等协议虽然高效且保护隐私，但只能表达基数（k-of-n），无法识别"谁"可以花费。

  BLISK 创建一个简单的 AND/OR 布尔电路，将逻辑门映射到成熟的密码学技术。具体来说，AND 门通过应用 n-of-n 多重签名设置获得，其中每个参与者必须贡献一个有效签名。另一方面，OR 门通过利用密钥协商协议（如 [ECDH][ecdh wiki]）获得，其中任何参与者都可以使用自己的私钥和其他参与者的公钥派生共享秘密。它还应用[非交互式零知识证明][nizk wiki]使电路求解可验证并防止作弊。BLISK 将电路解析为单个签名验证密钥。这意味着只需针对一个公钥验证一个 [Schnorr][topic schnorr signatures] 签名。

  BLISK 相对于其他方案的另一个重要优势是消除了生成新密钥对的需要。实际上，它允许将现有密钥连接到特定的签名实例。

  Kurbatov 提供了该协议的[概念验证][blisk gh]，但他表示该框架尚未达到生产成熟度。

## 版本发布和候选版本

_热门比特币基础设施项目的新版本发布和候选版本。请考虑升级到新版本或帮助测试候选版本。_

- [Bitcoin Core 29.3][] 是前一个主要版本系列的维护版本，包含多项钱包迁移修复（见[周报 #387][news387 wallet]）、一个按输入的 sighash 中间状态缓存以减少遗留脚本中二次哈希的影响（见[周报 #367][news367 sighash]），以及移除对共识无效交易的对等节点惩罚（见[周报 #367][news367 discourage]）。详情请参阅[发行说明][bcc29.3 rn]。

- [LDK 0.2.2][] 是这个用于构建闪电网络应用的库的维护版本。它将 `SplicePrototype` 特性标志更新为生产特性位（63），修复了异步 `ChannelMonitorUpdate` 持久化操作在重启后可能挂起并导致强制关闭通道的问题，并修复了接收来自对等节点的无效拼接消息时发生的调试断言失败。

- [HWI 3.2.0][] 是这个为多种硬件签名设备提供通用接口的软件包的新版本。新版本添加了对 Jade Plus 和 BitBox02 Nova 设备的支持、[testnet4][topic testnet]、Jade 的原生 [PSBT][topic psbt] 签名，以及 [BIP373][] 中指定的 [MuSig2][topic musig] PSBT 字段。

- [Bitcoin Inquisition 29.2][] 是这个用于实验提议的软分叉和其他重大协议变更的 [signet][topic signet] 全节点版本。基于 Bitcoin Core 29.3r2，此版本实现了 [BIP54][]（[共识清理][topic consensus cleanup]）提案并禁用了 [testnet4][topic testnet]。

## 重大代码和文档变更

_以下是来自 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案 (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期重大变更。_

- [Bitcoin Core #32420][] 更新了 Mining IPC 接口（见[周报 #310][news310 mining]），不再在 coinbase `scriptSig` 中包含虚拟的 `extraNonce`。`CreateNewBlock()` 添加了新的 `include_dummy_extranonce` 选项，IPC 代码路径将其设置为 `false`。[Stratum v2][topic pooled mining] 客户端现在只收到 `scriptSig` 中共识要求的 [BIP34][] 区块高度，不再需要剥离或忽略额外数据。

- [Core Lightning #8772][] 移除了对旧版洋葱支付格式的支持。虽然 CLN 在 2022 年就停止创建旧版洋葱（见[周报 #193][news193 legacy]），但在 v24.05 中添加了一个转换层来处理旧版 LND 生成的少量旧版洋葱。自 LND v0.18.3 以来这些已不再被创建，因此不再需要支持。旧版格式在 2022 年已从 BOLTs 规范中移除（见[周报 #220][news220 bolts]）。

- [LND #10507][] 在 `GetInfo` RPC 响应中添加了一个新的 `wallet_synced` 布尔字段，指示钱包是否已完成追赶到当前链尖。与现有的 `synced_to_chain` 布尔字段不同，这个新字段不要求通道图路由器（验证[通道公告][topic channel announcements]）或 blockbeat 调度器（协调区块驱动事件的子系统）同步后才返回 true。

- [LDK #4387][] 将[拼接][topic splicing]特性标志从临时位 155 切换到生产位 63。LDK v0.2 使用了位 155，而 Eclair 也将该位用于自定义的、Phoenix 特定的拼接实现，该实现早于当前草案规范且与之不兼容。这导致 Eclair 节点在连接到 LDK 节点时尝试使用其协议进行拼接，造成反序列化失败和重连。

- [LDK #4355][] 添加了对[拼接][topic splicing]和[双向注资][topic dual funding]通道协商期间交换的承诺签名的异步签名支持。当接收到 `EcdsaChannelSigner::sign_counterparty_commitment` 时，异步签名器立即返回，并在签名准备就绪后通过 `ChannelManager::signer_unblocked` 回调。双向注资通道仍需要额外工作才能完全支持异步签名。

- [LDK #4354][] 通过将配置选项 `negotiate_anchors_zero_fee_htlc_tx` 默认设置为 true，使具有[锚点输出][topic anchor outputs]的通道成为默认选项。自动通道接受已被移除，因此所有入站通道请求必须手动接受。这确保钱包拥有足够的链上资金来支付强制关闭时的手续费。

- [LDK #4303][] 修复了两个在 `ChannelManager` 重启后 [HTLC][topic htlc] 可能被重复转发的 bug：一个是出站 HTLC 仍在保持单元（内部队列）中但被遗漏，另一个是 HTLC 已经被转发、结算并从出站通道中移除，但入站侧的保持单元中仍有其解析记录。此 PR 还在入站 HTLC 洋葱被不可撤销地转发后对其进行修剪。

- [HWI #784][] 添加了 [MuSig2][topic musig] 字段的 [PSBT][topic psbt] 序列化和反序列化支持，包括参与者公钥、公共 nonce 和输入与输出的部分签名，如 [BIP327][] 中所指定。

- [BIPs #2092][] 为 [BIP434][] 中的 `feature` 消息分配了一个单字节的 [v2 P2P 传输][topic v2 p2p transport]消息类型 ID，并为 [BIP324][] 添加了一个辅助文件，用于跟踪跨 BIP 的单字节 ID 分配以帮助开发者避免冲突。该文件还记录了 [Utreexo][topic utreexo] 在 BIP183 中提议的分配。

- [BIPs #2004][] 添加了 [BIP89][]，用于链码委托（见[周报 #364][news364 delegation]），这是一种协作托管技术，其中受委托方对委托方隐瞒 [BIP32][] 链码，仅向委托方分享足够的信息以生成签名，而不会泄露哪些地址收到了资金。

- [BIPs #2017][] 添加了 [BIP110][]，规定了缩减数据临时软分叉（RDTS），一项在共识层面临时限制携带数据的交易字段约一年的提案。该规则将使超过 34 字节的 scriptPubKey 无效（除了最多 83 字节的 OP_RETURN）、超过 256 字节的 pushdata 和见证栈元素、未定义见证版本的花费、[taproot][topic taproot] 附件、超过 257 字节的控制块、`OP_SUCCESS` 操作码，以及 [tapscript][topic tapscript] 中的 `OP_IF`/`OP_NOTIF`。花费激活前创建的 UTXO 的输入可获豁免。激活使用修改版的 [BIP9][] 部署，矿工信号阈值降低至 55%，并在约 2026 年 9 月强制锁定。参见[周报 #379][news379 rdts]了解此提案的早期报道。

- [Bitcoin Inquisition #99][] 在 [signet][topic signet] 上添加了 [BIP54][] [共识清理][topic consensus cleanup]软分叉规则的实现。四项实施的缓解措施包括：限制每笔交易可能执行的遗留 sigop 数量、使用两小时宽限期防止时间扭曲攻击（加上防止负难度调整间隔）、强制将 coinbase 交易时间锁定到区块高度，以及使 64 字节交易无效。

{% include snippets/recap-ad.md when="2026-02-17 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32420,8772,10507,4387,4355,4354,4303,784,2092,2004,2017,99" %}
[kmax mailing list]: https://groups.google.com/g/bitcoindev/c/tgcAQVqvzVg
[blisk del]: https://delvingbitcoin.org/t/blisk-boolean-circuit-logic-integrated-into-the-single-key/2217
[ecdh wiki]: https://zh.wikipedia.org/wiki/%E6%A9%A2%E5%9C%93%E6%9B%B2%E7%B7%9A%E8%BF%AA%E8%8F%B2-%E8%B5%AB%E7%88%BE%E6%9B%BC%E9%87%91%E9%91%B0%E4%BA%A4%E6%8F%9B
[nizk wiki]: https://zh.wikipedia.org/wiki/%E9%9B%B6%E7%9F%A5%E8%AF%86%E8%AF%81%E6%98%8E
[blisk gh]: https://github.com/zero-art-rs/blisk
[Bitcoin Core 29.3]: https://bitcoincore.org/bin/bitcoin-core-29.3/
[bcc29.3 rn]: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-29.3.md
[Bitcoin Inquisition 29.2]: https://github.com/bitcoin-inquisition/bitcoin/releases/tag/v29.2-inq
[HWI 3.2.0]: https://github.com/bitcoin-core/HWI/releases/tag/3.2.0
[LDK 0.2.2]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.2.2
[news387 wallet]: /zh/newsletters/2026/01/09/#bitcoin-core-wallet-migration-bug
[news367 sighash]: /zh/newsletters/2025/08/15/#bitcoin-core-32473
[news367 discourage]: /zh/newsletters/2025/08/15/#bitcoin-core-33050
[news310 mining]: /zh/newsletters/2024/07/05/#bitcoin-core-30200
[news193 legacy]: /zh/newsletters/2022/03/30/#c-lightning-5058
[news220 bolts]: /zh/newsletters/2022/10/05/#bolts-962
[news364 delegation]: /zh/newsletters/2025/07/25/#chain-code-withholding-for-multisig-scripts
[news379 rdts]: /zh/newsletters/2025/11/07/#temporary-soft-fork-to-reduce-data
[BIP89]: https://github.com/bitcoin/bips/blob/master/bip-0089.mediawiki
