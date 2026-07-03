---
title: 'Bitcoin Optech Newsletter #410'
permalink: /zh/newsletters/2026/06/19/
name: 2026-06-19-newsletter-zh
slug: 2026-06-19-newsletter-zh
layout: newsletter
lang: zh
---
本周的周报总结了关于钱包移除其所创建交易中的 opt-in 手续费替换信号的讨论。此外还包括我们的常规栏目：介绍服务和客户端软件的近期变化，并总结流行比特币基础设施软件的重大变更。

## 新闻

- **<!--discussion-of-removing-rbf-signaling-from-wallet-transactions-->****关于从钱包交易中移除 RBF 信号的讨论：** rkrux 在 Bitcoin-Dev 邮件列表上[发帖][bip125 ml]，提议钱包停止在它们创建的交易中发送 [opt-in RBF][topic rbf] 信号。根据 [BIP125][]，当一笔交易至少有一个输入将 `nSequence` 设为低于 `MAX-1`（其中 `MAX` 为 `0xffffffff`）时，该交易就会发出可替换信号。自 full RBF 成为默认行为（见[周报 #315][news315 fullrbf]）且 `mempoolfullrbf` 退出选项被移除（见[周报 #329][news329 fullrbf]）之后，这个信号就不再影响一笔交易是否能够被替换。使用 Bitcoin Core 默认策略的节点，无论交易的 `nSequence` 取值如何，都会替换任何交易。如今，这一信号主要用于给创建该交易的钱包做指纹识别，因此帖子主张钱包应收敛到一个统一的取值。

  rkrux 打开了 [Bitcoin Core #35405][]，希望让 Bitcoin Core 钱包默认停止发信号，使用 `nSequence = MAX-1`，并向其他钱包作者询问可以标准化为哪个取值。Murch 和 Electrum Wallet 贡献者 SomberNight 指出，`MAX-2` 已经是主流取值：根据 [mainnet-observer][bip125 graph]，约 75% 的交易使用这一取值，而几乎所有 Electrum Wallet 交易也都如此。由于目前多数交易仍在发信号，如果 Bitcoin Core 转而使用不发信号的 `MAX-1`，反而会使其交易更容易被识别出来，而不是融入整体，因此两人都主张应当改为收敛到 `MAX-2`。rkrux 在收到这一反馈后关闭了该 PR。

## 服务和客户端软件的变化

*在这个月度专题中，我们重点介绍比特币钱包和服务的有趣更新。*

- **<!--sparrow-wallet-2-5-0-adds-silent-payments-receiving-->****Sparrow Wallet 2.5.0 增加静默支付接收支持：** Sparrow [2.5.0][sparrow 2.5.0] 添加了[静默支付][topic silent payments]接收钱包支持，包括隔离网络的硬件钱包签名器，这建立在 2.3.0 中加入的发送支持之上（见[周报 #377][news377 sparrow]）。

- **<!--bark-live-on-bitcoin-mainnet-->****Bark 在比特币主网上线：** Second [宣布][bark mainnet]，其 [Ark][topic ark] 协议实现 Bark 已开始在比特币主网上运行，同时还提供了一个公开 Ark 服务器、Bark SDK 以及面向开发者的 `barkd` 守护进程。Bark 此前已在 signet 上推出（见[周报 #346][news346 bark]）。

- **<!--arke-ark-wallet-announced-->****Arké Ark 钱包发布：** [Arké][arke] 是一款原生 iOS 钱包，集成了 [Ark][topic ark] 协议、链上（[BDK][bdk repo]）支付和闪电网络支付，并将这三层的交易展示在统一的历史记录中。它目前运行在 signet 上，主网上线仍在推进中。

- **<!--noah-ark-wallet-announced-->****Noah Ark 钱包发布：** [Noah][noah] 是一款跨平台移动钱包，基于 [Ark][topic ark] 协议，支持闪电网络，并采用最小化信任的设计。目前处于 beta 阶段。

- **<!--alby-hub-v1-23-0-released-->****Alby Hub v1.23.0 发布：** Alby Hub [v1.23.0][alby hub v1.23.0] 增加了[即时通道][topic jit channels]，可自动开启以接收入站支付；还添加了实验性的 [Ark][topic ark] 支付后端，以及其他多项改进。

- **<!--joinmarket-ng-0-32-0-released-->****JoinMarket NG 0.32.0 发布：** JoinMarket-NG 是该 [coinjoin][topic coinjoin] 实现的一个社区维护分叉版本，它[发布][joinmarket 0.32.0]了对 [Neutrino][topic compact block filters] 后端的交易池支持，使 taker 能够验证 maker 的广播，此外还包括若干 fidelity bond 和可靠性方面的改进。

## 重大代码和文档变更

_以下是来自 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期重大变更。_

- [Bitcoin Core #35221][] 增加了对 [BIP434][] 对等节点特性协商框架的支持（见[周报 #386][news386 bip434]和[#390][news390 bip434]）。它增加了一条 `feature` P2P 消息，可在 `version` 和 `verack` 之间交换，用于广播可选的对等节点特性，并将 P2P 协议版本号提升到 `70017`。Bitcoin Core 当前实现了协商机制，会忽略未知但合法的特性 ID；而对于发送格式错误 `feature` 消息、在 `verack` 之后发送该消息，或在未协商兼容协议版本的情况下发送该消息的对等节点，则会断开连接。它目前尚未广播任何具体的可选特性。

- [Bitcoin Core #35254][] 在使用之后会从内存中抹除更多的密钥派生材料。`CHMAC_SHA256` 和 `CHMAC_SHA512` 现在会清理其临时 `rkey` 与内部哈希 `temp` 栈缓冲区，这些缓冲区可能包含由 [BIP32][topic bip32] 链码或 [BIP324][topic v2 p2p transport] HKDF 密钥材料派生出的数据。`ChainCode` 的类型也已从 `uint256` typedef 改为带有 `memory_cleanse()` 析构函数的类型，从而在扩展密钥和局部变量中的 [BIP32][] 链码对象被销毁时，将它们从内存中抹除。

- [Bitcoin Core #35498][] 修复了 `FetchBlock` RPC 路径中的一个竞争条件：当向一个正在断开的对等节点请求区块时，`FetchBlock` 可能在锁定 `cs_main` 之前先获得一个有效的对等节点引用，但对等节点清理过程可能在 `BlockRequested()` 记录请求之前移除该对等节点的 `CNodeState`，从而导致断言失败。修复方案是在查找对等节点之前先锁定 `cs_main`，确保在区块请求被注册时，该对等节点状态不会被移除。

- [Eclair #3318][] 修复了一个[拼接][topic splicing]重连边缘情形：Eclair 可能会在未发送 `splice_locked` 的情况下，更新本地对新锁定的拼接注资交易的状态。这种情况可能发生在 Eclair 发送 `channel_reestablish` 之后、但在收到对方的 `channel_reestablish` 之前，从而使双方在“哪些注资状态需要 `commit_sig` 消息”这一点上不同步，并导致强制关闭。现在，Eclair 会在重连期间处理注资锁定事件，并在需要时发送 `splice_locked`。

- [LND #10789][] 为实现 [BOLT12 要约][topic offers] 奠定了基础：增加了一个与守护进程无关的 `bolt12` codec 包，其中包含一个 `Offer` 消息类型以及配套的 `lnwire` TLV 基础设施。这个新 codec 会在编码前验证消息，在低层解码时保持宽松，以便进行诊断和模糊测试，并保留未知的已签名范围 TLV，从而使 `offer_id` 在解码和重新编码前后保持稳定。

- [Rust Bitcoin #6321][] 加强了[隔离见证][topic segwit] witness 的解码逻辑，以防止攻击者控制的元素数量导致过度的内存分配。此前，只需少量输入字节，就可以声称存在一个很大的 witness 栈，并迫使系统为 witness 索引空间分配约 16 MB 内存。新的解码器会将收到的 witness 字节追加到其内容缓冲区中，并在 `end()` 阶段于 witness 数据解码完成后再构建元素索引，从而移除了旧的批量分配路径。

- [LDK #4685][] 将用于 [BOLT12][topic offers] 发票验证的 nonce 重新移回到发票请求或退款的付款人 metadata 中。此前之所以移除该 nonce，是因为它也被保存在[盲化回复路径][topic rv routing]的 `OffersContext` 中，但那会导致发票验证依赖于发票请求或退款本身之外的状态，这与即将到来的 [BOLT12][] [支付证明][topic proof of payment]（见[周报 #405][news405 proof]）不兼容。现在，出站要约和退款的回复路径上下文只会保存预期的 `PaymentId`，并将其与从收到的发票付款人 metadata 中恢复出的 payment ID 进行比对。

{% include snippets/recap-ad.md when="2026-06-23 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="35405,35221,35254,35498,3318,10789,6321,4685" %}

[bip125 ml]: https://groups.google.com/g/bitcoindev/c/C7zNIk8llew/m/YAdpwe33AgAJ
[bip125 graph]: https://mainnet.observer/charts/transactions-signaling-explicit-rbf/
[news315 fullrbf]: /zh/newsletters/2024/08/09/#bitcoin-core-30493
[news329 fullrbf]: /zh/newsletters/2024/11/15/#bitcoin-core-30592
[sparrow 2.5.0]: https://github.com/sparrowwallet/sparrow/releases/tag/2.5.0
[news377 sparrow]: /zh/newsletters/2025/10/24/#sparrow-2-3-0-released
[bark mainnet]: https://blog.second.tech/bark-now-on-bitcoin-mainnet/
[arke]: https://github.com/GBKS/arke
[noah]: https://github.com/smolcars/noah
[news346 bark]: /zh/newsletters/2025/03/21/#bark-launches-on-signet
[alby hub v1.23.0]: https://github.com/getAlby/hub/releases/tag/v1.23.0
[joinmarket 0.32.0]: https://github.com/joinmarket-ng/joinmarket-ng/releases/tag/0.32.0
[news386 bip434]: /zh/newsletters/2026/01/02/#peer-feature-negotiation
[news390 bip434]: /zh/newsletters/2026/01/30/#bips-2076
[news405 proof]: /zh/newsletters/2026/05/15/#core-lightning-9116
