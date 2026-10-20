---
title: 'Bitcoin Optech Newsletter #393'
permalink: /zh/newsletters/2026/02/20/
name: 2026-02-20-newsletter-zh
slug: 2026-02-20-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报总结了关于近期 OP_RETURN 使用情况的讨论，并介绍了一种无需共识变更即可强制执行类似限制条款的花费条件的协议。此外还包括我们的常规栏目：介绍服务和客户端软件的近期更新、宣布新版本和候选版本，以及总结热门比特币基础设施软件的重大变更。

## 新闻

- **<!--recent-op_return-output-statistics-->近期 OP_RETURN 输出统计：** Anthony Towns 在 [Delving][post op_return stats] 上发帖，总结了 Bitcoin Core v30.0 于 10 月 10 日发布以来的 OP_RETURN 统计数据。该版本对 OP_RETURN 输出的交易池策略限制进行了修改，允许一笔交易包含多个 OP_RETURN 输出，并允许 OP_RETURN 输出中携带最多 100kB 的数据。他查看的区块范围为高度 915800 到 936000，结果如下：

  * 24,362,310 笔带有 OP_RETURN 输出的交易

  * 61 笔带有多个 OP_RETURN 输出的交易

  * 396 笔 OP_RETURN 输出脚本总大小超过 83 字节的交易

  * 这段期间 OP_RETURN 输出脚本数据总量为 473,815,552 字节（其中大型 OP_RETURN 占 0.44%）

  * 34,283 笔交易将 sats 销毁到 OP_RETURN 输出中，总计销毁 1,463,488 sats

  * 949,003 笔交易的 OP_RETURN 数据在 43 到 83 字节之间，23,412,911 笔交易的 OP_RETURN 数据不超过 42 字节

  Towns 还附上了一张图表，展示了这 396 笔大型 OP_RETURN 交易的数据大小分布。其中 50% 的交易，其 OP_RETURN 数据不到 210 字节；另有 10% 的交易，其 OP_RETURN 数据超过 10KB。

  他后来又补充说，Murch 随后在 X 上发布了[类似的分析][murch twitter]以及一个 OP_RETURN 统计[仪表板][murch dashboard]，而 orangesurf 则发布了一份面向交易池研究的 OP_RETURN [报告][orangesurf report]。

- **<!--bitcoin-pipes-v2-->Bitcoin PIPEs v2：** Misha Komarov 在 Delving Bitcoin 上[发帖][pipes del]介绍了 Bitcoin PIPEs，这是一种无需共识变更或乐观挑战机制，即可强制执行花费条件的协议。

  比特币协议基于一种极简的交易验证模型，其核心是验证被花费的 UTXO 是否由有效的数字签名授权。因此，Bitcoin PIPEs 不依赖比特币脚本来表达花费条件，而是对“能否生成有效签名”这一点增加前置条件。换句话说，私钥会以密码学方式被锁定在一个预先设定的条件之后；只有当条件满足时，私钥才会被揭示，从而生成有效签名。比特币协议本身只需验证一个 [schnorr 签名][topic schnorr signatures]，而所有条件逻辑都在链下处理。

  在形式化层面，Bitcoin PIPEs 包含两个主要阶段：

  * *设置*：生成一个标准的比特币密钥对 `(sk, pk)`。然后使用见证加密，将 `sk` 加密在一条关于花费条件的声明之后。

  * *签名*：为这条声明提供见证 `w`。如果 `w` 有效，`sk` 就会被揭示，从而可以生成 schnorr 签名；否则，从计算上恢复 `sk` 将不可行。

  据 Komarov 介绍，Bitcoin PIPEs 可以复现[限制条款][topic covenants]的语义。特别是，[Bitcoin PIPEs v2][pipes v2 paper] 专注于一组受限的花费条件，用来强制执行二元限制条款。这个模型自然涵盖了许多结果只有二元取值的有用条件，例如提供有效的零知识证明、满足退出条件，或存在欺诈证明。归根结底，它只回答一个问题：“条件满足了，还是没有？”

  最后，Komarov 提供了几个实际示例，说明如何用 PIPEs 取代新操作码，以及如何用它改进 [BitVM][topic acc] 协议中的乐观验证流程。

## 服务和客户端软件变更

*在这个月度栏目中，我们重点介绍比特币钱包和服务的有趣更新。*

- **<!--second-releases-hark-based-ark-software-->Second 发布基于 hArk 的 Ark 软件：**
  Second 的 [Ark][topic ark] 库在 [0.1.0-beta.6][second 0.1.0 beta6] 版本中更新为使用 hArk（hash-lock Ark）。这一新协议消除了用户在轮次期间必须同步交互的要求，但也带来了它自身的一组权衡。该版本还包含多项其他更新，其中包括破坏性变更。

- **<!--amboss-announces-railsx-->Amboss 宣布 RailsX：**
  [RailsX 公告][amboss blog] 介绍了一个使用闪电网络和 [Taproot Assets][topic client-side validation] 来支持互换及其他多种金融服务的平台。

- **<!--nunchuk-adds-silent-payment-support-->Nunchuk 添加静默支付支持：**
  Nunchuk [宣布][nunchuk post] 支持向[静默支付][topic silent payments]地址付款。

- **<!--electrum-adds-submarine-swap-features-->Electrum 添加潜水艇互换功能：**
  [Electrum 4.7.0][electrum release notes] 允许用户使用其闪电网络余额进行链上支付（见[潜水艇互换][topic submarine swaps]），此外还包含其他功能和修复。

- **<!--sigbash-v2-announced-->Sigbash v2 发布：**
  [Sigbash v2][sigbash post] 现使用 [MuSig2][topic musig]、WebAssembly（WASM）和零知识证明，以实现更好的共签服务隐私保护。更多背景可参见我们此前关于 Sigbash 的[报道][news298 sigbash]。

## 新版本和候选版本

_热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。_

- [BTCPay Server 2.3.5][] 是这个自托管支付解决方案的小版本更新，添加了仪表板上的多币种钱包余额小组件、自定义结账文本框和新的汇率提供方，并包含若干 bug 修复。

- [LND 0.20.1-beta][] 是这个热门闪电网络节点实现的维护版本，加入了 gossip 消息处理的 panic 恢复机制，改进了重组保护，加入了用于检测 LSP 的启发式规则，并修复了多个 bug 和竞态条件。

## 重大代码和文档变更

*本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals（BIPs）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Bitcoin Core #33965][] 修复了一个 bug：`-blockreservedweight` 启动配置（见[周报 #342][news342 weight]）可能会静默覆盖 Mining IPC 客户端设置的 `block_reserved_weight` 值（见[周报 #310][news310 mining]）。现在，当 IPC 调用方设置后者时，它就会优先生效。对于从未设置该值的 RPC 调用方，启动配置 `-blockreservedweight` 则始终生效。此 PR 还对 IPC 调用方强制执行 `MINIMUM_BLOCK_RESERVED_WEIGHT`，防止他们设置低于该值的数值。

- [Eclair #3248][] 在转发 [HTLC][topic htlc] 时开始优先使用私有通道而非公共通道（如果两者都可用）。这使更多流动性保留在对网络可见的公共通道中。当两个通道具有相同的可见性时，Eclair 现在优先选择余额较小的通道。

- [Eclair #3246][] 为多个内部事件添加了新字段：`TransactionPublished` 将单一的 `miningFee` 字段拆分为 `localMiningFee` 和 `remoteMiningFee`，增加了一个计算得出的 `feerate`，以及一个可选的 `LiquidityAds.PurchaseBasicInfo`，用来将交易关联到一笔[流动性购买][topic liquidity advertisements]。通道生命周期事件现在也包含 `commitmentFormat`，用于描述通道类型，而 `PaymentRelayed` 则增加了 `relayFee` 字段。

- [LDK #4335][] 添加了对使用 [BOLT12 要约][topic offers]的幻影节点支付的初步支持（见[周报 #188][news188 phantom]）。在 [BOLT11][] 版本中，发票包含指向一个并不存在的“幻影”节点的路由提示，而每条路径的最后一跳则是一个可以使用[无状态发票][topic stateless invoices]接收支付的真实节点。在 [BOLT12][] 中，要约只需包含多条终止于各个参与节点的[盲化路径][topic rv routing]。当前实现允许多个节点响应发票请求，但最终生成的发票只能支付给作出响应的节点。

- [LDK #4318][] 从 `ChannelHandshakeLimits` 结构体中移除了 `max_funding_satoshis` 字段，有效地消除了 [wumbo][topic large channels] 之前的默认通道大小限制。LDK 已经默认通过 `option_support_large_channels` 特性标志宣告支持[大通道][topic large channels]，这可能会与之前的设置冲突，向对等节点错误地发出支持信号。想要限制风险的用户可以使用手动通道接受流程。

- [LND #10542][] 扩展了图数据库层以支持 gossip v1.75（见周报 [#261][news261 gossip] 和 [#326][news326 gossip]）。LND 现在可以存储和检索[简单 taproot 通道][topic simple taproot channels]的[通道公告][topic channel announcements]。gossip v1.75 在网络层面仍处于禁用状态，等待验证和 gossiper 子系统完成。

- [BIPs #1670][] 发布了 [BIP360][]，它规定了 Pay-to-Merkle-Root（P2MR）这一新的输出类型。它的工作方式类似于 [P2TR][topic taproot]，但移除了密钥路径花费。P2MR 输出能够抵抗密码学相关量子计算机（CRQC）的长期暴露攻击，因为它们直接承诺的是脚本树的默克尔根，也就是一个 SHA256 哈希，而不是公钥。不过，若要防御短期暴露攻击，例如在交易尚未确认时恢复私钥，仍然需要单独的[后量子][topic quantum resistance]签名提案。参见[周报 #344][news344 p2qrh]，了解该提案以 P2QRH 为名时的早期报道；以及[周报 #385][news385 bip360]，了解它以 P2TSH 为名时的报道。

- [BOLTs #1236][] 更新了[双向注资][topic dual funding]规范，允许任一节点在通道建立期间发送 `tx_init_rbf`，从而实际上允许双方都能对注资交易[追加手续费][topic rbf]。此前，只有通道发起方可以这样做。此变更使双向注资与[拼接][topic splicing]保持一致，因为在拼接中，任一方本来就可以发起 RBF。该 PR 还增加了一项要求：`tx_init_rbf` 和 `tx_ack_rbf` 的发送方都必须重用前一次尝试中的至少一个输入，以确保新交易会双花所有先前的尝试。

- [BOLTs #1289][] 更改了在双向注资和拼接使用的交互式交易协议中，重连时 `commitment_signed` 的重传方式。此前，`commitment_signed` 在重连时总是被重传，即使对等方已经收到了它。现在，`channel_reestablish` 包含一个显式位域，让节点仅在仍需要时才请求 `commitment_signed`。这避免了不必要的重传，这对未来的[简单 taproot 通道][topic simple taproot channels]尤其重要，因为重传将需要由于 nonce 变更而进行完整的 [MuSig2][topic musig] 签名轮次。

{% include snippets/recap-ad.md when="2026-02-24 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33965,3248,3246,4335,4318,10542,1670,1236,1289" %}

[post op_return stats]: https://delvingbitcoin.org/t/recent-op-return-output-statistics/2248
[pipes del]: https://delvingbitcoin.org/t/bitcoin-pipes-v2/2249
[pipes v2 paper]: https://eprint.iacr.org/2026/186
[second 0.1.0 beta6]: https://docs.second.tech/changelog/changelog/#010-beta6
[amboss blog]: https://amboss.tech/blog/railsx-first-lightning-native-dex
[nunchuk post]: https://x.com/nunchuk_io/status/2021588854969414119
[electrum release notes]: https://github.com/spesmilo/electrum/blob/master/RELEASE-NOTES
[news298 sigbash]: /zh/newsletters/2024/04/17/#key-agent-sigbash-launches-sigbash
[sigbash post]: https://x.com/arbedout/status/2020885323778044259
[BTCPay Server 2.3.5]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.3.5
[LND 0.20.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.1-beta
[news342 weight]: /zh/newsletters/2025/02/21/#bitcoin-core-31384
[news310 mining]: /zh/newsletters/2024/07/05/#bitcoin-core-30200
[news188 phantom]: /zh/newsletters/2022/02/23/#ldk-1199
[news261 gossip]: /zh/newsletters/2023/07/26/#updated-channel-announcements
[news326 gossip]: /zh/newsletters/2024/10/25/#updates-to-the-version-1-75-channel-announcements-proposal-1-75
[news344 p2qrh]: /zh/newsletters/2025/03/07/#update-on-bip360-paytoquantumresistanthash-p2qrh
[news385 bip360]: /zh/newsletters/2025/12/19/#quantum
[murch dashboard]: https://dune.com/murchandamus/opreturn-counts
[murch twitter]: https://x.com/murchandamus/status/2022930707820269670
[orangesurf report]: https://research.mempool.space/opreturn-report/
