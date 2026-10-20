---
title: 'Bitcoin Optech 周报 #415'
permalink: /zh/newsletters/2026/07/24/
name: 2026-07-24-newsletter-zh
slug: 2026-07-24-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报介绍了一份关于 BIP340 签名全聚合的 BIP 草案。此外还包括我们的常规栏目：介绍服务和客户端软件的近期变化，宣布新版本和候选版本，并总结流行比特币基础设施软件的重要变更。

## 新闻

- **<!--draft-bip-for-full-aggregation-of-bip340-signatures-->****BIP340 签名全聚合的 BIP 草案：** Fabian Jahr 在 Bitcoin-Dev 邮件列表上[发帖][aggr ml]，介绍了一份新的 BIP 草案，用于实现 [BIP340][] [schnorr 签名][topic schnorr signatures]的全聚合。这份草案把 DahLIAS 聚合签名方案（见[周报 #351][news351 dahlias]）标准化；该方案描述了一套流程，可以把一组签名合并成单个聚合签名，而且无论签名者有多少，合并后的大小都只有 64 字节。不过，这套协议是交互式的，需要所有签名者相互配合，还需要引入一个不受信任的协调器来降低通信复杂度。协调器这一角色可以由参与流程的任何一位签名者担任。

  整个流程分为两轮：

  1. 每位签名者先计算出一个私密 nonce（`secnonce`）和一个公开 nonce（`pubnonce`），以此开启签名会话。签名者把 `pubnonce` 发给协调器，协调器将它们聚合成 `aggnonce`，再连同其他一些信息一起发回给各位签名者。

  2. 每位签名者使用自己的私钥、`secnonce`、待签名的消息，以及协调器提供的信息，计算出一个局部签名。随后各方把局部签名发给协调器，由协调器把它们聚合成单个 64 字节的签名。

  Jahr 表示，这项提案的可能应用之一是[跨输入签名聚合（CISA）][topic cisa]——一项比特币共识变更，能够缩小多输入交易的体积，进而降低其链上手续费。不过作者特别说明，共识变更本身不在这份 BIP 的范围之内。

  这份草案目前被称为 BIP459，正在 [BIPs #2210][] 中讨论，并向社区征求反馈。

## 服务和客户端软件的变更

*在这个每月栏目中，我们会重点介绍比特币钱包和服务的有趣更新。*

- **<!--wasabi-wallet-2-8-0-released-->****Wasabi Wallet 2.8.0 发布：** Wasabi Wallet [2.8.0][wasabi 2.8.0] 改为直接从 P2P 网络下载[致密区块过滤器][topic compact block filters]，不再需要此前必需的中心化后端服务器。这一版本还增加了在 [coinjoin][topic coinjoin] 中直接向收款方付款的能力、对[低于 1 sat/vbyte 的费率][topic default minimum transaction relay feerates]的支持，以及[支付批处理][topic payment batching]等功能。

- **<!--coinswap-v0-2-2-released-->****Coinswap v0.2.2 发布：** Coinswap [v0.2.2][coinswap v0.2.2] 为其 [coinswap][topic coinswap] 协议实现（见[周报 #338][news338 coinswap]）增加了多交易互换、可否认性证明，以及市场功能方面的改进。该版本还修复了一次安全审计所发现的问题；这次审计使用的是 Loupe —— Spiral 开源的 AI 驱动安全扫描器。

- **<!--go-secp256k1-library-announced-->****Go secp256k1 库发布：** Allocz [宣布][secp256k1 go delving]推出一个 [Go 库][secp256k1 go]：启用 C 互操作时它使用 [libsecp256k1][libsecp256k1 repo] 绑定，否则回退到纯 Go 实现，从而保留 Go 的交叉编译能力。作者报告称，相比纯 Go 实现，ECDSA 和 [schnorr 签名][topic schnorr signatures]的验证耗时下降了 70%。

- **<!--asmap-dashboard-announced-->****ASMap 仪表盘发布：** Joris Strakeljahn [宣布][asmap delving]推出一个 [ASMap 仪表盘][asmap dashboard]，用来追踪 [ASMap 数据][github asmap-data]历次发布的变化（见[周报 #394][news394 asmap]），包括相邻两次发布之间有多少地址空间在运营商之间发生转移，以及随着数据老化，每次发布对实际观测到的比特币节点的覆盖程度如何。

- **<!--wavelength-alpha-released-->****Wavelength alpha 版发布：** Lightning Labs [宣布][wavelength blog]推出 Wavelength 的 alpha 版本；这是一套工具包，用于为应用程序添加自托管的支付能力。它可以支付和接收 BOLT11 闪电网络发票，并借助一个类 [Ark][topic ark] 的结算层批量处理链下转账，用户无需自己管理通道。alpha 版已在 [signet][topic signet] 和 testnet 上提供。

## 版本和候选版本

_流行比特币基础设施项目的新版本和候选版本。请考虑升级到新版本，或帮助测试候选版本。_

- [Core Lightning v26.06.6][] 是这一闪电网络节点实现的维护版本。它更新了内置 `pyln-proto` 库所依赖的 `coincurve`，以修复 Python 构建环境的问题；并新增了一项检查，拒绝任何复用现有通道注资输出点的通道。

- [Bitcoin Inquisition 29.4][] 是这一 [signet][topic signet] 全节点的新版本，该节点专为试验提议中的软分叉和其他重大协议变更而设计。这一版本基于 Bitcoin Core 29.4，在原有的实验性激活软分叉提案集合之外，新增了对 [BIP446][]（`OP_TEMPLATEHASH`）的激活；`OP_TEMPLATEHASH` 是一个提议中的 [tapscript][topic tapscript] 操作码，作用是把花费交易的哈希值推入栈中（见[周报 #365][news365 templatehash]）。

## 重大的代码和文档变更

_以下是来自 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期重大变更。_

- [Bitcoin Core #35215][] 加快了内存中 UTXO 缓存（`CCoinsMap`）的查找速度：它把用于哈希 `COutPoint` 键的 `SipHash-2-4` 换成了一个更快的、专门定制的 [SipHash][] 变体 `SipHasher13UJ`。每一枚币都通过一个由 txid 和输出编号组合而成的键来查找，而每次查找都要把这个键送进哈希函数。`SipHash-2-4` 会把一枚币的 32 字节 txid 拆成四个 64 位分片分别处理，因此哈希一个输出点要跑 14 轮内部运算。`SipHasher13UJ` 则以一次 256 位的步骤读入整个 txid，轮数也更少，把这个数字降到了五轮。作者报告称，在独立基准测试中哈希吞吐量大约提升到原来的两倍，在一次 chainstate 重新索引中耗时减少了约 5%。

- [Bitcoin Core #35766][] 让节点在首次连接来自 DNS 种子节点和编译时内置的固定种子节点的地址时，默认启用 [BIP324][] [v2 P2P 传输][topic v2 p2p transport]。BIP324 的实验性支持随 Bitcoin Core 26.0 发布，并从 27.0 起默认启用。由于这两种种子节点机制提供的地址不带服务标志，Bitcoin Core 此前把这类对等节点一律当作只支持 v1，于是节点最早建立的那批自动连接从来不会尝试加密传输。新增的 `SeedsAssumedServiceFlags()` 函数现在会为这些地址假定 `NODE_P2P_V2`。如果这一假定对某个对等节点并不成立，节点直接用 v1 重连即可。而通过 `-seednode` 选项建立的连接以及地址获取过程，本来就已经默认尝试 v2。

- [BIPs #2075][] 澄清了 [BIP174][] 中关于 [PSBT][topic psbt] 如何合并的表述。原规范断言，合并各自独立更新过的 PSBT 无条件与顺序无关；但这一点只有在各参与方添加的字段互不相同时才成立。当两份 PSBT 含有同一个键、取值却不同时，合并器既可以任选其中一个取值，也可以拒绝合并；因此规范现在补充说明：这种情况下的结果不满足交换律。

- [BIPs #2204][] 更新了 Great Script Restoration 的两份规范草案 [BIP440][] 和 [BIP441][]（见[周报 #400][news400 gsr]）。它引入了 `wordspan` 记法——把一个栈元素的字节长度向上取整到下一个八字节边界；并重做了大量操作开销公式，使得以 64 位字为单位处理数据的操作按 `wordspan` 计费，而按确切字节工作的操作仍按 `length` 计费。这次更新还修正了 `OP_RIGHT` 的定义，并澄清了其他若干操作码的开销与范围检查。

- [Core Lightning #8935][] 修复了一个漏洞；该漏洞可能导致节点反复对一笔交易做 [RBF][topic rbf]，哪怕替换交易早已确认。CLN 把待处理交易存放在一个以原始 txid 为键的 `outgoing_tx_map` 中；每出现一个手续费更高的版本，它就替换掉其中的交易对象，却不更改键。每区块执行一次的 `rebroadcast_txs()` 循环用那个陈旧的原始 txid 来检查确认状态，而这个 txid 从未被打包，于是即便最新的交易早已确认，循环仍会不断触发重播和替换逻辑。由于 txid 同时充当哈希表的键、无法原地更新，该循环现在改为每次迭代都重新计算当前交易的 txid，并用它来做确认检查。

- [Core Lightning #9324][] 修复了 `Renepay`（见[周报 #263][news263 renepay]）自 v26.04 起出现的一处回归；该回归构造出的 [HTLC][topic htlc]，其 CLTV 到期高度比应有的值多出了大约相当于当前区块高度的量。Renepay 的路由数据本已把当前区块高度计入每一跳的 CLTV 值，但 `route_sendpay_request()` 在把路由传给 `sendpay` 时又加了一次区块高度，使到期高度大约翻倍。转发节点随后可能以 `expiry_too_far` 拒绝这个洋葱包。

- [libsecp256k1 #1765][] 新增了一个可选的 `silentpayments` 模块，实现 [BIP352][] [静默支付][topic silent payments]所定义的椭圆曲线运算。对发送方而言，其中一个函数会把发送方各输入的私钥、交易中最小的那个输出点，以及接收方公布的扫描公钥和花费公钥组合起来，推导出这笔交易应当支付到的输出密钥。对接收方而言，全节点扫描会侦测出交易的哪些输出属于接收方，并返回花费这些输出所需的 tweak；整个过程只需要接收方的扫描私钥和花费公钥，因此花费私钥可以始终保持离线。另有一组独立的函数负责管理标签（label）——这是 [BIP352][] 的一项可选功能，可以让接收方推导出自己地址的多个可区分变体，从而区分开不同的收款，并标记出自己的找零。轻客户端的扫描支持则推迟到后续 PR 实现。

- [Rust Bitcoin #6317][] 更新了它的[致密区块中继][topic compact block relay]解码逻辑，按 [BIP152][] 的要求，拒绝布尔通告字段不严格等于 `0` 或 `1` 的 `sendcmpct` 消息。此前 Rust Bitcoin 用“非零即真”的方式解码该字段，任何非零值都会被当作真（也就是高带宽模式）。这个 PR 与 Bitcoin Core 中对应的加固措施（见[周报 #412][news412 sendcmpct]）保持一致。

- [BTCPay Server #7457][] 增加了以 [BIP329][] JSON Lines 格式导入[钱包标签][topic wallet labels]的能力，与已有的导出功能相配套。此前迁移到另一台服务器时，标签实际上会全部丢失，而 Sparrow、Envoy 这类支持 BIP329 的钱包所产生的标签文件更是根本无法加载。导入器会读取该格式的 `tx`、`addr` 和 `output` 记录，把它们映射到 BTCPay 的交易、地址和 UTXO 对象上，并跳过任何无法应用的记录。

- [BLIPs #71][] 为 [BLIP32][] 增加了 `dnssec_error` 响应。BLIP32 这一协议通过在闪电网络洋葱消息中承载 DNSSEC 查询与证明，来解析 [BIP353][] 人类可读的支付名称（见[周报 #306][news306 blip32]）。此前该协议只定义了 `dnssec_query` 和 `dnssec_proof`，因此无法应答的解析器没有标准化的办法把这一情况告知请求方，请求方只能一直等下去。新增的末跳 TLV（类型 `65550`）会回显被查询的 `domain_name`，并包含一个 `definitely_unresolvable` 布尔值：遇到 NXDOMAIN 或未签名域名这类终局性失败时，解析器应当设置它；而遇到其他可能只是暂时性的失败时，则不应设置。

{% include snippets/recap-ad.md when="2026-07-28 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2210,35215,35766,8935,9324,1765,6317,7457,2075,2204,71" %}

[aggr ml]: https://groups.google.com/g/bitcoindev/c/TF5mPfy58RQ/m/vAk1Mfg2AwAJ
[news351 dahlias]: /zh/newsletters/2025/04/25/#interactive-aggregate-signatures-compatible-with-secp256k1
[wavelength blog]: https://lightning.engineering/posts/2026-07-21-wavelength-launch/
[wasabi 2.8.0]: https://github.com/WalletWasabi/WalletWasabi/releases/tag/v2.8.0
[coinswap v0.2.2]: https://github.com/citadel-tech/coinswap/releases/tag/v0.2.2
[news338 coinswap]: /zh/newsletters/2025/01/24/#coinswap-v010-released
[secp256k1 go delving]: https://delvingbitcoin.org/t/a-faster-go-golang-secp256k1-library/2658
[secp256k1 go]: https://github.com/allocz/secp256k1
[asmap delving]: https://delvingbitcoin.org/t/asmap-dashboard-tracking-the-asmap-data-history-against-the-observed-network/2652
[asmap dashboard]: https://jorisstrakeljahn.github.io/asmap-dashboard/
[github asmap-data]: https://github.com/bitcoin/bitcoin/blob/master/doc/asmap-data.md
[news394 asmap]: /zh/newsletters/2026/02/27/#bitcoin-core-28792
[news263 renepay]: /zh/newsletters/2023/08/09/#core-lightning-6376
[news412 sendcmpct]: /zh/newsletters/2026/07/03/#bitcoin-core-35550
[news400 gsr]: /zh/newsletters/2026/04/10/#bips-2118
[news306 blip32]: /zh/newsletters/2024/06/07/#blips-32
[news365 templatehash]: /zh/newsletters/2025/08/01/#taproot-native-op-templatehash-proposal
[SipHash]: https://en.wikipedia.org/wiki/SipHash
[Core Lightning v26.06.6]: https://github.com/ElementsProject/lightning/releases/tag/v26.06.6
[Bitcoin Inquisition 29.4]: https://github.com/bitcoin-inquisition/bitcoin/releases/tag/v29.4-inq
