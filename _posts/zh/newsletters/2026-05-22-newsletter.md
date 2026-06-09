---
title: 'Bitcoin Optech 周报 #406'
permalink: /zh/newsletters/2026/05/22/
name: 2026-05-22-newsletter-zh
slug: 2026-05-22-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报链接到一则关于 BIP322 通用消息签名格式更新的讨论，并介绍了一个利用 TCP 打洞帮助位于 NAT 后方的比特币节点接受入站连接的想法。此外还包括我们的常规栏目：介绍服务和客户端软件的近期变化，并总结流行比特币基础设施软件的重要变更。

## 新闻

- **<!--significant-updates-to-bip322-generic-signed-message-format-->****BIP322：通用消息签名格式的重要更新：** Oliver Gugger 在 Bitcoin-Dev 邮件列表上[发帖][guggero bip322 ml]，介绍了他关于如何补全 [BIP322][topic generic signmessage] 的一些想法。Gugger 此前一直在 btcd 中实现相关支持，因此注意到该提案仍有若干悬而未决的问题和空白。他为该提案提出了三项主要修订：

  * 为三种签名变体加入人类可读的前缀。

  * 在“Proof of Funds”变体中加入 UTXO 信息。

  * 支持基于 PSBT 的消息签名。

  在经过一些讨论并吸收了关于 PSBT 构造方式的反馈之后，BIP322 的更新版本已经发布（见[周报 #405][news405 bip322]）。Gugger 还将 BIP322 的状态推进为 Complete，表示该规范现在已被视为稳定并可供实现。更新发布后，社区也再次注意到 Coldcard 早在 3 月就已[推出][cc 322]了对 BIP322 的支持。

  之前已经支持旧版 [BIP322][] 的项目，应检查自己与更新后规范的兼容性；这次更新引入了破坏兼容性的变更，包括新的人类可读前缀，以及修订后的资金证明签名格式。

- **<!--tcp-hole-punching-for-bitcoin-nodes-behind-nats-->****为位于 NAT 后方的比特币节点使用 TCP 打洞：** 0xB10C 在 Delving Bitcoin 上[发帖][hole punch del]，提出了一个想法，希望让更多位于家用路由器 NAT 后方的节点能够接受入站连接。这个初步构想源于一项观察：自 [Bitcoin Core v30.0][] 起默认启用 `-natpmp=1`，并未像预期那样提高住宅 ISP 环境中可达节点的数量。

  这一想法利用了“打洞”技术：在某些类型的 NAT 后方，它允许两个主机在不通过服务器中继流量的情况下直接建立连接。其过程如下：两个都不可达的主机 Alice 和 Bob 通过第三方交换各自的公网端点信息（即 IP 地址和端口），然后同时向对方发起连接。这样会在各自的 NAT 中创建映射，使双方能够完成握手并建立连接。由于这里提议的方法工作在 TCP 之上，而 TCP 要求节点之间精确同步，因此它相比使用 UDP 的类似技术会有更高的失败率。

  0xB10C 提到了多种基于比特币 P2P 协议实现该想法的路径。第一类路径需要一个桥接方，也就是所谓的 rendezvous server，使 Alice 和 Bob 能够交换端点信息。这个服务器既可以提供一种撮合服务，让不可达主机对外提供自己的连接槽位；也可以在自己没有空余入站槽位、原本需要驱逐某个连接时，改为把现有连接中的一个移交给另一对等节点。他还描述了一种可直接在 [Tor/I2P][topic anonymity networks] 下执行打洞的方法，从而绕过建立连接所需的第三方服务器。在这种方法中，Alice 会先开始监听一个专用的 Tor/I2P 端点，Bob 则连接到该端点并启动打洞流程。

  该提案目前尚未正式成形，仍有许多问题没有答案。0xB10C 征求社区反馈，并邀请大家讨论多个开放点，例如如何对打洞连接分类、TCP 打洞的可靠性、可能的攻击方式，以及实现所需的工作量。

## 服务和客户端软件的变更

_在这个每月栏目中，我们会重点介绍比特币钱包和服务的有趣更新。_

- **Ibis Wallet 宣布发布：** [Ibis Wallet][ibis wallet] 是一款基于 BDK 的 Android 钱包，支持 coin control、[RBF][topic rbf] 与 [CPFP][topic cpfp] 手续费管理、多签名、通过二维码集成硬件签名设备、[silent payments][topic silent payments]，以及 [Tor][topic anonymity networks] 集成。它还支持可选的第二层，包括 Spark、Liquid，以及未来的 [Ark][topic ark]。

- **LDK Server 宣布发布：** Spiral 宣布推出 [LDK Server][ldk server]，这是一个面向支付处理商和钱包提供商、基于 LDK Node 构建且以 API 为先的闪电网络节点守护进程。它提供 gRPC 接口、一个嵌入式的基于 BDK 的钱包，以及一个供 AI 代理与节点交互的 Model Context Protocol（MCP）服务器。

- **Mempool.space v3.3.0 发布：** Mempool [v3.3.0][mempool v3.3.0] 增加了 [taproot][topic taproot] 脚本树可视化、更新后的 [PSBT][topic psbt] 预览、[手续费估算][topic fee estimation]改进、[临时锚点][topic ephemeral anchors]支持、陈旧区块比较、sighash 图标，以及默克尔证明 API 等功能。

- **peer-observer P2P 监控工具：** 0xB10C 在一篇文章中[概述][peer-observer delving]了其 [peer-observer][peer-observer site] 平台所使用的一些开源组件，其中包括从 Bitcoin Core 节点中通过 IPC、日志、P2P 和 RPC 数据源提取事件的基础设施。他还介绍了围绕归档、异常检测和告警工具的持续开发工作。

## 重大代码和文档变更

_以下是来自 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案 (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期重大变更。_

- [Bitcoin Core #29136][] 添加了一个 `addhdkey` RPC，用于导入指定的 [BIP32][] 扩展私钥；如果未指定，则生成一个，同时不会立即用它来生成任何输出脚本。这样，钱包就可以为未来使用（例如某个多签名脚本）存储一个签名密钥，而不必马上从中生成地址。该 PR 还新增了一种 `unused(KEY)` [描述符][topic descriptors]类型，`listdescriptors` 会返回它，从而可将所存储的密钥包含进钱包备份中。

- [Bitcoin Core #34893][] 更新了 `combinepsbt` RPC，使其在合并 [PSBT][topic psbt] 时保留 [BIP174][] 的专有字段（见[周报 #72][news72 psbt]和[#181][news181 psbt]）。此前，`combinepsbt` 会悄悄丢弃这些专有字段，从而导致应用专用的 PSBT 元数据丢失。`decodepsbt` RPC 则早已能够正确解析、序列化并显示这些字段。

- [Bitcoin Core #34860][] 从 `CreateNewBlock()` 方法中移除了 `include_dummy_extranonce` 选项（见[周报 #392][news392 mining]）。现在，Bitcoin Core 在创建高度 0 到 16 的区块时，总会在内部 coinbase 的 scriptSig 中附加虚拟填充；这是因为仅靠 [BIP34][] 的高度编码，长度不足以满足共识对 scriptSig 最小长度的要求。不过，这些填充不会被包含到通过 Mining IPC 接口暴露给连接中的 [Stratum V2][topic pooled mining] 客户端的 `CoinbaseTx` 结构体 `scriptSigPrefix` 字段中（见[周报 #310][news310 ipc]和[#388][news388 ipc]）。

- [Bitcoin Core #31298][] 更新了 `combinerawtransaction` RPC：如果输入的是互不相关的交易，它现在会直接拒绝，而不是像以前那样静默返回第一笔交易，也不报告这些交易无法合并。Bitcoin Core 现在会去除每笔交易输入中的 scriptSig 和 witness，比较所得未签名交易的哈希值；如果不匹配，就返回错误。

- [Bitcoin Core #28802][] 为 Bitcoin Core 的 CLI 参数解析器 `ArgsManager` 添加了对命令专属选项的支持。现在，各个命令可以声明哪些选项适用于自己，从而让 `ArgsManager` 在对应命令的帮助输出下列出这些选项，并自动拒绝无效的命令—选项组合。该 PR 已将这一机制应用到 `bitcoin-wallet` 的 `-dumpfile` 选项（见[周报 #32][news32 dump]）：这个选项现在只为 `dump` 和 `createfromdump` 命令注册。

- [Eclair #3298][] 更新了其内部的 [RBF][topic rbf] 逻辑，以遵循新的 [BOLT2][] 手续费率上调规则；该规则旨在确保在低手续费率下仍符合 [BIP125][] 的替换规则。Eclair 不再只套用此前 25/24 的手续费率乘数，而是改为取两者中较大者：该乘数，或额外增加 25 sat/kw。这与[周报 #400][news400 rbf]记述的 LDK 行为，以及[周报 #404][news404 rbf]介绍的 BOLT 规范更新保持一致。

- [LDK #4575][] 添加了一个 `splice_in_inputs` API，允许用户在将资金[拼接][topic splicing]进入通道时手动选择 UTXO。所选 UTXO 会被全部花费，其数值在扣除手续费后全部加入通道，且不会创建找零输出。这补充了现有基于金额的 splice-in 流程：在那种流程中，调用方指定要加入的金额，再由钱包选择输入。不过，这两种输入选择流程不能在同一笔注资贡献中混用。

- [LND #10814][] 移除了已弃用的 `SendPayment`、`SendPaymentSync`、`SendToRoute`、`SendToRouteSync` 和 `TrackPayment` 端点；这些端点原定于 0.21 版本中移除（见[周报 #340][news340 lnd]）。调用方应改用它们的 V2 替代项：`SendPaymentV2`、`SendToRouteV2` 和 `TrackPaymentV2`。该 PR 还移除了已弃用的单通道 `outgoing_chan_id` 字段，要求调用方改用多通道 `outgoing_chan_ids` 字段（见[周报 #33][news33 lnd]）。

- [Rust Bitcoin #6191][] 添加了对 `sendtxrcncl` P2P 消息的编码与解码支持；该消息用于 [Erlay][topic erlay] 的交易 reconciliation。Bitcoin Core 早先已将对该消息的支持加入，作为 Erlay 支持的早期组成部分（见[周报 #223][news223 erlay]）。不过，完整的 Erlay 交易 reconciliation 目前仍未实现。

- [BLIPs #42][] 添加了 [BLIP42][]，这是一个关于 [BOLT12][] 联系人的规范。由于 [BOLT12 要约][topic offers]可被重复用作静态闪电网络支付指令，钱包可以把这些要约存储为联系人。该 BLIP 定义了可选的 `invoice_request` 字段，付款方在向联系人发起对外支付时可包含这些字段，例如联系人密钥、付款方自己的要约，或一个 [BIP353][] 名称。这使收款方能够识别来自已知联系人的付款、添加新联系人，并在无需额外交互的情况下把资金发回付款方。

{% include snippets/recap-ad.md when="2026-05-26 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29136,34893,34860,31298,28802,3298,4575,10814,6191,42" %}
[ibis wallet]: https://github.com/aeonBTC/IbisWallet
[ldk server]: https://github.com/lightningdevkit/ldk-server
[mempool v3.3.0]: https://github.com/mempool/mempool/releases/tag/v3.3.0
[peer-observer delving]: https://delvingbitcoin.org/t/peer-observer-a-tool-and-infrastructure-for-monitoring-the-bitcoin-p2p-network-for-attacks-and-anomalies/1988/4
[peer-observer site]: https://public.peer.observer/
[news72 psbt]: /zh/newsletters/2019/11/13/#bips-849
[news181 psbt]: /zh/newsletters/2022/01/05/#bitcoin-core-17034
[news392 mining]: /zh/newsletters/2026/02/13/#bitcoin-core-32420
[news310 ipc]: /zh/newsletters/2024/07/05/#bitcoin-core-30200
[news388 ipc]: /zh/newsletters/2026/01/16/#bitcoin-core-33819
[news32 dump]: /zh/newsletters/2019/02/05/#bitcoin-core-13926
[news400 rbf]: /zh/newsletters/2026/04/10/#ldk-4494
[news404 rbf]: /en/newsletters/2026/05/08/#bolts-1327
[news340 lnd]: /zh/newsletters/2025/02/07/#lnd-9456
[news33 lnd]: /zh/newsletters/2019/02/12/#lnd-2572
[news223 erlay]: /zh/newsletters/2022/10/26/#bitcoin-core-23443
[hole punch del]: https://delvingbitcoin.org/t/tcp-hole-punching-for-bitcoin-nodes-behind-home-nats/2497
[Bitcoin Core v30.0]: https://bitcoincore.org/en/releases/30.0/
[guggero bip322 ml]: https://groups.google.com/g/bitcoindev/c/qd6BNz9gxCk/m/k1fHq4RKAQAJ
[cc 322]: https://blog.coinkite.com/bip322-wif/
[news405 bip322]: /en/newsletters/2026/05/15/#bips-2141
