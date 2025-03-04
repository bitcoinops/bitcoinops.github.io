---
title: 'Bitcoin Optech Newsletter #342'
permalink: /zh/newsletters/2025/02/21/
name: 2025-02-21-newsletter-zh
slug: 2025-02-21-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报描述了一个想法，允许移动钱包在无需额外 UTXO 的情况下结算闪电网络（LN）通道，并总结了关于为 LN 寻路增加服务质量（QoS）标志的持续讨论。此外，我们还包括了常规部分：客户端、服务以及对热门比特币基础设施项目的重大变更介绍。

## 新闻

- **<!--allowing-mobile-wallets-to-settle-channels-without-extra-utxos-->****允许移动钱包在无需额外 UTXO 的情况下结算通道：**
  Bastien Teinturier 在 Delving Bitcoin 论坛上[发布了][teinturier mobileclose]关于 LN 通道的 [v3 承诺交易][topic v3 commitments]的一种可选变体，该变体允许移动钱包在所有可能发生盗窃的情况下使用通道内的资金来结算通道。他们不需要保留链上 UTXO 来支付关闭费用。

  Teinturier 首先概述了需要移动钱包广播交易的四种情况：

  1. 他们的对等节点广播了一个已撤销的承诺交易，例如，对等节点试图窃取资金。在这种情况下，移动钱包立即获得了花费通道所有资金的能力，允许它使用这些资金来支付费用。

  2. 移动钱包已发送了尚未结算的付款。在这种情况下，盗窃是不可能的，因为他们的远程对等节点只能通过提供 [HTLC][topic htlc] 原像（即，证明最终接收者已收到付款）来认领付款。由于盗窃不可能发生，移动钱包可以花时间寻找 UTXO 来支付关闭费用。

  3. 没有待处理的付款，但远程对等节点无响应。同样，这里盗窃是不可能的，所以移动钱包可以慢慢关闭。

  4. 移动钱包正在接收 HTLC。在这种情况下，远程对等节点可以接受 HTLC 原像（允许它从上游节点认领资金），但不更新已结算的通道余额并撤销 HTLC。在这种情况下，移动钱包必须在相对较少的区块内强制关闭通道。这是帖子其余部分讨论的情况。

  Teinturier 建议让远程对等节点为支付给移动钱包的每个 HTLC 签署两个不同版本：一个根据零费用承诺的默认策略的零费用版本，和一个按当前能快速确认的费率支付费用的版本。费用从支付给移动钱包的 HTLC 价值中扣除，所以远程对等节点提供这个选项不需要任何成本，而移动钱包有动机只在真正必要时使用它。Teinturier 确实[指出][teinturier mobileclose2]远程对等节点支付过多费用存在一些安全考虑，但他预计这些问题很容易解决。

- **<!--continued-discussion-about-an-ln-quality-of-service-flag-->****关于 LN 服务质量标志的持续讨论：** Joost Jager 在 Delving Bitcoin 上[发布][jager lnqos]继续讨论关于在 LN 协议中添加服务质量（QoS）标志，以允许节点表明它们的某个通道具有高可用性（HA）————能够以 100% 的可靠性转发指定金额的付款（见[周报 #239][news239 qos]）。如果支付者选择了 HA 通道，而付款在该通道失败，那么支付者将通过永远不再使用该通道来惩罚运营者。自上次讨论以来，Jager 提出了节点级别的信号（可能只是通过在节点的文本别名中附加“HA”），指出协议当前的错误消息不能保证检测到付款失败的通道，并建议这不是可以完全选择性地出示和使用的东西 —— 如果是，就不需要广泛的一致 —— 因此即使很少有支付和转发节点最终使用它，也应该为兼容性而指定它。

  Matt Corallo [回复][corallo lnqos]说，LN 寻路目前运行良好，并链接到一个[详细文档][ldk path]描述 LDK 的寻路方法，该方法扩展了 René Pickhardt 和 Stefan Richter 最初描述的方法（见[周报 #163][news163 pr paper]和[周报 #270][news270 ldk2534]中的[两个条目][news270 ldk2547]）。然而，他担心 QoS 标志会鼓励未来的软件实现不那么可靠的寻路，而只是倾向于仅使用 HA 通道。在这种情况下，大型节点可以与其大型对等节点签署协议，在通道耗尽时临时使用基于信任的流动性，但依赖于无信任通道的较小节点将不得不使用昂贵的[即时再平衡][topic jit routing]，这将使它们的通道利润减少（如果他们承担成本）或不那么受欢迎（如果他们将成本转嫁给支付者）。

  Jager 和 Corallo 继续讨论，但没有达成明确的解决方案。

## 服务和客户端软件的变更

*在这个月度栏目中，我们会标出比特币钱包和服务的有趣更新。*

- **<!--ark-wallet-sdk-released-->****Ark 钱包 SDK 发布：**
  [Ark 钱包 SDK][ark sdk github] 是一个 TypeScript 库，用于构建同时支持链上比特币和 [Ark][topic ark] 协议的钱包，支持 [testnet][topic testnet]、[signet][topic signet]、[Mutinynet][new252 mutinynet] 和主网（目前不推荐）。

- **<!--zaprite-adds-btcpay-server-support-->****Zaprite 添加 BTCPay Server 支持：**
  比特币和闪电支付集成商 [Zaprite][zaprite website] 将 BTCPay Server 添加到其支持的钱包连接列表中。

- **<!--iris-wallet-desktop-released-->****Iris 钱包桌面版发布：**
  [Iris 钱包][iris github] 支持使用 [RGB][topic client-side validation] 协议发送、接收和发行资产。

- **<!--sparrow-2-1-0-released-->****Sparrow 2.1.0 发布：**
  Sparrow [2.1.0 版本][sparrow 2.1.0] 用 [Lark][news333 lark] 替换了之前的 [HWI][topic hwi] 实现，并添加了 [PSBTv2][topic psbt] 支持，以及其他更新。

- **<!--scure-btc-signer-1-6-0-released-->****Scure-btc-signer 1.6.0 发布：**
  [Scure-btc-signer][scure-btc-signer github] 的 [1.6.0][scure-btc-signer 1.6.0] 版本添加了对版本 3（[TRUC][topic v3 transaction relay]）交易和[支付到锚点（P2A）][topic ephemeral anchors]的支持。Scure-btc-signer 是 [scure][scure website] 库套件的一部分。

- **Py-bitcoinkernel alpha：**
  [Py-bitcoinkernel][py-bitcoinkernel github] 是一个 Python 库，用于与 [libbitcoinkernel][Bitcoin Core #27587] 交互，后者是一个[封装 Bitcoin Core 验证逻辑][kernel blog]的库。

- **<!--rust-bitcoinkernel-library-->****Rust-bitcoinkernel 库：**
  [Rust-bitcoinkernel][rust-bitcoinkernel github] 是一个实验性的 Rust 库，用于使用 libbitcoinkernel 读取区块数据并验证交易输出和区块。

- **<!--bip32-cbip32-library-->****BIP32 cbip32 库：**
  [cbip32 库][cbip32 library] 使用 libsecp256k1 和 libsodium 在 C 中实现 [BIP32][]。

- **<!--lightning-loop-moves-to-musig2-->****Lightning Loop 转向 MuSig2：**
  Lightning Loop 的 Swap 服务现在使用 [MuSig2][topic musig]，如[最近的博客文章][loop blog]中所述。

## 重大的代码和文档变更

_本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案 (BIPs)][bips repo]、[闪电 BOLTs][bolts repo]、[闪电 BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的最近重要变更。_

- [Bitcoin Core #27432][] 引入了一个 Python 脚本，将由 `dumptxoutset` RPC 命令生成的紧凑序列化 UTXO 集（专为 [AssumeUTXO][topic assumeutxo] 快照设计）转换为 SQLite3 数据库。虽然考虑过扩展 `dumptxoutset` RPC 本身以输出 SQLite3 数据库，但由于增加的维护负担，最终被拒绝。该脚本不添加额外的依赖项，生成的数据库大小约为紧凑序列化 UTXO 集的两倍。

- [Bitcoin Core #30529][] 修复了对否定选项如 `noseednode`、`nobind`、`nowhitebind`、`norpcbind`、`norpcallowip`、`norpcwhitelist`、`notest`、`noasmap`、`norpcwallet`、`noonlynet` 和 `noexternalip` 的处理，使其按预期行为。以前，否定这些选项会导致令人困惑且没有得到文档说明的副作用，但现在它只是清除指定的设置以恢复默认行为。

- [Bitcoin Core #31384][] 解决了一个问题，即为区块头、交易计数和 coinbase 交易保留的 4000 权重单位（WU）被无意中应用了两次，将最大区块模板大小不必要地减少了 4000 WU 至 3992000 WU（见周报 [#336][news336 weightbug]）。此修复将保留的权重合并为单个实例，并引入了一个新的 `-blockreservedweight` 启动选项，允许用户自定义保留的权重。添加了安全检查，确保保留的权重设置为 2000 WU 到 4000000 WU 之间的值，否则 Bitcoin Core 将无法启动。

- [Core Lightning #8059][] 在 `xpay` 插件上实现了对[多路径支付][topic multipath payments]（MPP）的抑制（见周报 [#330][news330 xpay]），当支付不支持此功能的 [BOLT11][] 发票时。同样的逻辑将扩展到 [BOLT12][topic offers] 要约，但必须等到下一个版本，因为这个 PR 还启用了向插件广告 BOLT12 功能，明确允许使用 MPP 支付 BOLT12 要约。

- [Core Lightning #7985][] 通过启用依靠[盲路径][topic rv routing]路由并将 renepay 内部使用的 `sendpay` RPC 命令替换为 `sendonion` 方法，在 `renepay` 插件中添加了支付 [BOLT12][topic offers] 要约的支持（见周报 [#263][news263 renepay]）。

- [Core Lightning #7887][] 添加了对处理新的 [BIP353][] 字段的支持，用于人类可读名称（HRN）解析，以符合最新的 BOLTs 更新（见周报 [#290][news290 hrn] 和 [#333][news333 hrn]）。该 PR 还向发票添加了 `invreq_bip_353_name` 字段，对传入的 BIP353 名称字段实施了限制，并允许用户在 `fetchinvoice` RPC 上指定 BIP353 名称，以及措辞变更。

- [Eclair #2967][] 添加了对 [BOLTs #1205][] 中指定的 `option_simple_close` 协议的支持。这种简化的互相关闭协议是[简单 taproot 通道][topic simple taproot channels]的先决条件，因为它使节点能够在 `shutdown`、`closing_complete` 和 `closing_sig` 阶段安全地交换随机数，这是花费 [MuSig2][topic musig] 通道输出所必需的。

- [Eclair #2979][] 添加了一个验证步骤，以确认节点支持唤醒通知（参见周报 [#319][news319 wakeup]），然后再启动唤醒流程来中继[蹦床支付][topic trampoline payments]。对于标准通道支付，这种检查是不必要的，因为 [BOLT11][] 或 [BOLT12][topic offers] 发票已经表明支持唤醒通知。

- [Eclair #3002][] 引入了一个次要机制来处理区块及其确认的交易以触发监视，以增加安全性。这在通道被花费但花费交易尚未在交易池中检测到时特别有用。虽然 ZMQ `rawtx` 主题处理这个问题，但它可能不可靠，并且在使用远程 `bitcoind` 实例时可能会静默丢弃事件。每当发现新区块时，次要系统会获取最后 N 个区块（默认为 6 个）并重新处理其交易。

- [LDK #3575][] 实现了[对等存储][topic peer storage]协议作为一项功能，允许节点分发和存储通道对等方的备份。它引入了两种新的消息类型，`PeerStorageMessage` 和 `PeerStorageRetrievalMessage`，以及它们各自的处理程序，以启用节点之间这些备份的交换。对等数据在 `ChannelManager` 中的 `PeerState` 内持久存储。

- [LDK #3562][] 引入了一个新的评分器（见周报 [#308][news308 scorer]），它合并了基于从外部源频繁[探测][topic payment probes]实际支付路径的评分基准。这允许轻节点，通常对网络有有限的视图，通过合并外部数据（如闪电服务提供商（LSP）提供的分数）来提高支付成功率。外部分数可以与本地分数结合或覆盖本地分数。

- [BOLTs #1205][] 合并了 `option_simple_close` 协议，这是[简单 taproot 通道][topic simple taproot channels]所需的互相关闭协议的简化变体。对 [BOLT2][] 和 [BOLT3][] 进行了更改。

{% include references.md %}
{% include linkers/issues.md v=2 issues="27432,30529,31384,8059,7985,7887,2967,2979,3002,3575,3562,1205,27587" %}
[news239 qos]: /zh/newsletters/2023/02/22/#ln-quality-of-service-flag
[news163 pr paper]: /zh/newsletters/2021/08/25/#zero-base-fee-ln-discussion
[news270 ldk2547]: /zh/newsletters/2023/09/27/#ldk-2547
[news270 ldk2534]: /zh/newsletters/2023/09/27/#ldk-2534
[teinturier mobileclose]: https://delvingbitcoin.org/t/zero-fee-commitments-for-mobile-wallets/1453
[teinturier mobileclose2]: https://delvingbitcoin.org/t/zero-fee-commitments-for-mobile-wallets/1453/3
[jager lnqos]: https://delvingbitcoin.org/t/highly-available-lightning-channels-revisited-route-or-out/1438
[corallo lnqos]: https://delvingbitcoin.org/t/highly-available-lightning-channels-revisited-route-or-out/1438/4
[ldk path]: https://lightningdevkit.org/blog/ldk-pathfinding/
[news330 xpay]: /zh/newsletters/2024/11/22/#core-lightning-7799
[news263 renepay]: /zh/newsletters/2023/08/09/#core-lightning-6376
[news290 hrn]: /zh/newsletters/2024/02/21/#dns-based-human-readable-bitcoin-payment-dns
[news333 hrn]: /zh/newsletters/2024/12/13/#bolts-1180
[news319 wakeup]: /zh/newsletters/2024/09/06/#eclair-2865
[news308 scorer]: /zh/newsletters/2024/06/21/#ldk-3103
[news336 weightbug]: /zh/newsletters/2025/01/10/#investigating-pool-behavior-before-before-a-bitcoin-core-bug
[ark sdk github]: https://github.com/arklabshq/wallet-sdk
[new252 mutinynet]: /zh/newsletters/2023/05/24/#mutinynet-announces-new-signet-for-testing-mutinynet-signet
[zaprite website]: https://zaprite.com
[iris github]: https://github.com/RGB-Tools/iris-wallet-desktop
[sparrow 2.1.0]: https://github.com/sparrowwallet/sparrow/releases/tag/2.1.0
[news333 lark]: /zh/newsletters/2024/12/13/#java-based-hwi-released
[scure-btc-signer github]: https://github.com/paulmillr/scure-btc-signer
[scure-btc-signer 1.6.0]: https://github.com/paulmillr/scure-btc-signer/releases
[scure website]: https://paulmillr.com/noble/#scure
[py-bitcoinkernel github]: https://github.com/stickies-v/py-bitcoinkernel
[rust-bitcoinkernel github]: https://github.com/TheCharlatan/rust-bitcoinkernel
[kernel blog]: https://thecharlatan.ch/Kernel/
[cbip32 library]: https://github.com/jamesob/cbip32
[loop blog]: https://lightning.engineering/posts/2025-02-13-loop-musig2/
