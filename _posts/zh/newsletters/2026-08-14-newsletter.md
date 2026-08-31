---
title: 'Bitcoin Optech 周报 #418'
permalink: /zh/newsletters/2026/08/14/
name: 2026-08-14-newsletter-zh
slug: 2026-08-14-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报介绍了一项提议中的合约协议，用于缓解闪电网络的通道阻塞；报道了可供测试的 Bitcoin Core 静态二进制文件；并总结了一项变更：把 Bitcoin Core 中按对等节点分别施加的交易速率限制，改为全局性的做法。此外还包括我们的常规栏目：宣布新版本和候选版本，并介绍流行比特币基础设施软件的重大变更。

## 新闻

- **<!--conditional-message-transfer-contract-to-solve-jamming-->****用条件式消息传递合约解决阻塞问题：** Antoine Riard 在 Delving Bitcoin 上[发帖][chan jam del]，提出了一种缓解闪电网络[通道阻塞][topic channel jamming attacks]的新思路。阻塞是一种拒绝服务攻击：攻击者发出 [HTLC][topic htlc] 或 [PTLC][topic PTLC]，然后一直扣住不结算，从而把一条路由沿途的通道流动性占住，而自己不必付出任何代价。Riard 的提案让扣住不放这件事变得昂贵——按支付被扣留的时长收取一笔与之成正比的扣留费，把一种目前免费的攻击变成需要付出成本的攻击。

  这套机制叫做条件式消息传递合约（conditional message transfer contract，CMTC），它是一种 Bitcoin Script 构造，能让通道的两个交易对手方在事后证明：某条特定消息（例如支付原像）是否在某个给定区块高度之前在双方之间传递过；Riard 把区块高度当作一个通用时钟来使用。双方会商定一个时间窗口，并为窗口内的每一个时间点分配一个适配器点，这样扣留费就可以按照消息实际送达的时刻来结算。这份合约提供三条结算路径：

  - 消息传递成功：原像从 Bob 传给 Alice 并得到密码学上的确认，双方按送达时间分配这笔扣留费。

  - 活跃性挑战：如果 Alice 离线、无法会签，Bob 可以退出合约，取回被锁定的资金，但要扣除一笔均衡罚金。

  - 消息传递失败：如果 Bob 离线，或者由于其他原因未能传递消息，Alice 可以退出并取回扣留费。

  Riard 指出，这套方案还需要进一步分析，既包括其密码学上的正确性，也包括其激励机制；此外，这一思路（或它的某种扩展）能否解决比特币中其他类型的问题，目前仍是一个开放问题。

- **<!--static-bitcoin-core-binaries-available-for-testing-->****可供测试的 Bitcoin Core 静态二进制文件：** Michael Ford（fanquake）在 Bitcoin-Dev 邮件列表上[发帖][fanquake static ml]，宣布推出 Bitcoin Core 发布版静态二进制文件的测试构建；这些构建使用的是项目现有的 [Guix][topic reproducible builds] 基础设施。目前已提供 x86_64 和 aarch64 架构 Linux 上 `bitcoind` 及其他命令行工具的测试二进制文件，后续还计划支持更多平台。`bitcoin-qt` 这个图形界面二进制文件保持不变。

  Bitcoin Core 目前的 Linux 发布版二进制文件采用动态链接：它们包含了自身所需的大部分代码，但仍依赖用户操作系统提供的 C 库（glibc）以及若干相关库。这些库在程序每次启动时都要被定位并加载，而这种依赖带来了一些风险。这类二进制文件只能在提供了兼容 glibc（目前要求 2.31 或更新版本）的系统上运行；它们的行为会随宿主机的库而变化；而且，可复现构建能让用户验证的只是二进制文件本身，节点实际执行的一部分代码却落在它之外。静态二进制文件则把所需的全部代码都包含在内，因此同一个经过验证的可执行文件，在几乎任何 Linux 系统上都会以相同的方式运行——包括较老的发行版、像 Alpine Linux 这种基于另一种 C 库构建的发行版，以及完全不附带系统库的极简容器镜像。新的二进制文件仍然是位置无关可执行文件，保留了当前发布版所具备的 ASLR 漏洞利用缓解措施，而体积也只大了约 1 MB。

  这篇邮件列表帖子延续了 [Bitcoin Core #25573][] 中历时数年的工作；该 PR 由 Ford 在 2022 年开启。要取得进展，需要对 GCC 编译器和 glibc 本身作出修改，其中包括修复 glibc 的名称解析代码——这历来是静态链接 glibc 的主要隐患。针对 Guix 构建流程的一些准备性改动（见 [Bitcoin Core #35537][]）已经合并，主 PR 则仍在审阅当中，尚未合入。我们鼓励在 Linux 上运行 Bitcoin Core 的读者试用这些[测试二进制文件][static test bins]，并把遇到的任何问题（或者成功的情况）反馈到邮件列表或该 PR 上。

- **<!--replacing-per-peer-transaction-rate-limiting-with-global-rate-limits-->****用全局速率限制取代按对等节点分别施加的交易速率限制：** Anthony Towns 在 Delving Bitcoin 上[发帖][peer queue del]，宣布 [Bitcoin Core #34628][] 已经合并；该 PR 把按对等节点分别施加的交易速率限制，改成了全局性的做法。

  节点会为每一个对等节点维护一个队列，存放打算发给该对等节点的交易公告，这个队列叫做 `m_tx_inventory_to_send`；节点按祖先费率对这些公告排序，并优先发送其中最好的那些。为了限制带宽占用，同时增加探测中继拓扑的难度，节点对每个对等节点每秒最多只公告大约 7 笔交易。在平常时候，这个速率足以把队列排空；但交易的突然涌入，可能让队列被填满的速度超过这一限制所允许的排空速度。由于节点每发出一次公告都要对这个不断变长的队列重新排序，这可能消耗过多 CPU，形成一条拒绝服务（DoS）攻击途径；[周报 #324][news324 dos]此前介绍过这个问题。

  Towns 的 PR 用一个全局速率限制取代了按对等节点分别施加的限制，具体做法是使用两个令牌桶，分别按数量（交易笔数）和大小（序列化后的见证大小）来计量公告总量。如果容量足够，收到的交易就会立即中继出去；否则它会被加入一个统一的全局积压队列，该队列按费率和[族群交易池][topic cluster mempool]规则排序。从这个积压队列中选出的交易，随后会被放进一个很小的、按对等节点划分的队列，用于隐私方面的批处理。只对一个共享的积压队列排序，而不是为每个对等节点各排一个队列，这就避免了对每个对等节点反复排序——正是这一点让原设计成了一条 DoS 攻击途径。

## 版本和候选版本

_流行比特币基础设施项目的新版本和候选版本。请考虑升级到新版本，或帮助测试候选版本。_

- [BTCPay Server 2.4.2][] 是一个安全版本，修复了一个影响 2.4.2 之前所有版本的严重漏洞。未经认证的远程攻击者可以获取 LND 节点的 `.macaroon` 凭据文件，并借此控制该节点、转走资金。项目方[报告称][btcpay 2.4.2 advisory]，该漏洞已被实际利用，并已发生资金失窃。使用 LND 的 BTCPay Server 运营者应立即升级到 2.4.2 和 LND 0.21.1，审查自己的节点是否有未授权活动，并轮换 macaroon 凭据——因为攻击者可能已经拿到了它们。BTCPay Server 的链上钱包，以及使用其他闪电网络实现的部署，不受这一特定风险影响。

- [LND v0.21.2-beta][] 是这一流行闪电网络节点实现的维护版本。它修复了两处数据库迁移失败，限制了通道图同步期间的内存占用，并修复了影响洋葱消息、RBF 合作关闭、发票更新、[盲化][topic rv routing]支付转发和 [HTLC][topic htlc] 结算的若干 bug。

- [LND v0.20.3-beta][] 是 LND 0.20 发布分支的维护版本。它回溯移植了若干同样包含在 0.21.2-beta 中的修复，包括对通道图同步期间内存占用的限制，以及针对合作关闭、发票更新、盲化支付转发和 HTLC 结算的修复。

## 重大的代码和文档变更

_以下是来自 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期重大变更。_

- [Bitcoin Core #35493][] 修复了一个错误告警：在导入已经含有全部所需私钥的 [MuSig2][topic musig] [描述符][topic descriptors]（见[周报 #366][news366 musig descriptors]）时，Bitcoin Core 会提示私钥缺失。此前，`importdescriptors` RPC 会为展开描述符所产生的每一个公钥检查是否有对应的私钥，其中也包括 MuSig 聚合密钥——而这个密钥并没有独立的私钥。于是，一个已经含有全部参与方私钥的描述符，可能被报告为不完整。现在，完整性检查会把 MuSig 参与方密钥考虑在内，因此完整的描述符导入时不再告警，而确实缺少参与方私钥的描述符仍会触发告警。

- [Core Lightning #9150][] 引入了 `impressions`，这是一种新的流动性信息类型，用于记录通过某条通道成功完成的支付，并让 `askrene` RPC 命令（见[周报 #316][news316 askrene]）能够据此调整自己的流动性估计，供后续的路由尝试使用。此外，`getroutes` RPC 命令也作了更新，会在路由失败时给出更具体的错误信息，例如源节点资金不足，或者目标节点入账容量不足。同时，这个 PR 还把以其他货币计价的 [BOLT12 要约][topic offers]所生成的发票，默认限制为 10 分钟过期，以应对汇率波动。

- [BIPs #2248][] 更新了 [BIP3][]，把 Luke Dashjr 从 BIP 编辑名单中移除；此前 Bitcoin-Dev 邮件列表上有过相关[讨论][luke removal ml]。关于编辑人选此前的报道，见[周报 #299][news299 bip editors]。

- [BIPs #2225][] 和 [#2245][bips #2245] 在 [BIP110][]（见[周报 #412][news412 bip110]）激活尝试失败之后，对其作了更新。[#2245][bips #2245] 把它的状态改为 Closed。[#2225][bips #2225] 则把 [BIP433][] 中那条要求[支付到锚点（P2A）][topic ephemeral anchors]花费必须携带空见证栈的策略规则，提升为一项共识要求。

- [Eclair #3346][] 修复了一处崩溃，并对链上处理和通道处理作了若干改进。现在，它会先验证解密出的支付失败消息是否对应支付路由中一个有效的中间位置，然后才把它们当作路由信息使用，从而防止来自收款方的畸形或恶意构造的失败消息触发越界访问、进而让支付生命周期 actor 崩溃。此外，当它从 Bitcoin Core 收到无法归类的错误消息时，会开始重试链上交易广播，而不是可能就此放弃一笔时间敏感的交易。在使用 [CPFP][topic cpfp] 为对等节点的[零手续费承诺交易][topic v3 commitments]提升手续费时，它现在会把父交易和子交易合起来的完整[交易包][topic package relay]重量都算进去，而不是只算父交易的重量。最后，Eclair 在发送 `channel_ready` 时，现在会使用真正得到确认的那次注资 [RBF][topic rbf] 尝试所对应的 [MuSig2][topic musig] nonce，而不是想当然地认为最近一次 RBF 尝试就是被确认的那一次。

- [Eclair #3341][] 为将来中继一类 `channel_update` [gossip 消息][topic channel announcements]做好了准备——这类消息会用到 [BOLT7][] 中目前尚未定义的 `message_flags` 或 `channel_flags`。此前，如果 Eclair 收到一条更新，其中某个未知的标志位被置为 1，它会丢弃这个值，并在转发该更新时把该位编码为 0。这就改动了已签名的消息，使其签名失效。现在，Eclair 在解码和重新编码 `channel_update` 消息时会保留未知的标志值，从而让 Eclair 节点能够中继那些含有它尚不理解的标志的更新。

- [LND #11019][] 修复了旧版合作关闭状态机中的一处数据竞争；当 link goroutine（负责追踪通道的 HTLC 和承诺交易状态）与 peer goroutine（负责处理来自远端对等节点的关闭消息）并发推进时，就可能发生这种竞争。现在，link 不再自行推进关闭流程，而是在通道完成清空（待处理的 HTLC 已排干）时通知该 peer 的通道管理器，从而确保关闭状态机的所有状态转换都在单个 goroutine 上运行。这个 PR 还确保：即便双方并未协商过前置关闭脚本（见[周报 #76][news76 upfront]），RBF 合作关闭路径（见[周报 #347][news347 rbf coop]）也会检查对等节点的交付脚本是否存在、且使用的是一种被接受的输出类型。

- [LND #11023][] 修改了 `update_fee` 的处理方式，使其符合 [BOLT2][] 的可替换状态模型，并防止多余的、尚未提交的手续费更新把更新日志撑大。如果在上一次手续费更新被纳入任何一方的承诺交易之前，又来了一次新的更新，LND 现在会就地替换掉之前的手续费值。这个 PR 还把通道邮箱限制为最多 1,000 条排队消息、4 MiB 的序列化数据。如果某条消息无法被接受，LND 会断开该对等节点，而不是丢弃这条消息、继而乱序处理后续消息。这样一来，重连之后就能恢复有序的通道状态。

- [Libsecp256k1 #1904][] 加强了启动自检，针对的是那些自行提供 SHA256 压缩函数的应用程序（见[周报 #396][news396 sha256]）。此前，自检只对一条 63 字节的消息做哈希，这能发现总体上就不正确的实现，却发现不了那些在处理多个分组、非对齐输入，或初始状态以外的 SHA256 状态时才出错的实现。新的测试使用了不同的消息长度和输入对齐方式。一旦所提供的压缩函数得出的结果与预期的 SHA256 结果不符，它就会拒绝该函数，从而让有缺陷的实现在初始化阶段就被发现，而不是在之后产生错误的结果。

- [HWI #839][] 修复了若干 [PSBT][topic psbt] 解析和交易重建方面的问题；这些问题是在补齐 [BIP174][] 和 [BIP370][] 的完整测试向量集时暴露出来的。现在，从 PSBTv2 重建交易时，HWI 会应用计算得出的[时间锁][topic timelock]，而不是把它留作零；并且在某个输入省略了 `PSBT_IN_SEQUENCE` 时，使用规定的最终序列值（0xffffffff）。对于 PSBTv0，[HWI][topic hwi] 会拒绝仅属于 v2 的输入和输出字段，并严格按照非见证序列化格式来解析全局未签名交易，同时又能正确地把空的未签名交易识别为存在。这个 PR 还会验证必需的、基于高度和基于时间的时间锁是否落在各自规定的范围内，并为 BIP370 的时间锁判定增加了测试。

{% include snippets/recap-ad.md when="2026-08-18 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="25573,35537,34628,35493,9150,2248,2225,2245,3346,3341,11019,11023,1904,839" %}

[chan jam del]: https://delvingbitcoin.org/t/conditional-message-transfer-contract-to-solve-jamming/2772
[fanquake static ml]: https://groups.google.com/g/bitcoindev/c/UgGHs-_YGvw
[static test bins]: https://github.com/fanquake/bitcoin/releases/tag/static_bitcoind_ff01e5af948d
[peer queue del]: https://delvingbitcoin.org/t/transaction-rate-limiting/2744
[news324 dos]: /zh/newsletters/2024/10/11/#dos-from-large-inventory-sets
[luke removal ml]: https://groups.google.com/g/bitcoindev/c/knbv3MFwlvU
[topic timelock]: /en/topics/timelocks/
[BTCPay Server 2.4.2]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.4.2
[btcpay 2.4.2 advisory]: https://blog.btcpayserver.org/security-advisory-btcpay-server-2-4-2/
[LND v0.21.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.21.2-beta
[LND v0.20.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.3-beta
[news366 musig descriptors]: /zh/newsletters/2025/08/08/#bitcoin-core-31244
[news316 askrene]: /zh/newsletters/2024/08/16/#core-lightning-7517
[news299 bip editors]: /zh/newsletters/2024/04/24/#bip-editors-update-bip
[news412 bip110]: /zh/newsletters/2026/07/03/#bips-2201
[news347 rbf coop]: /zh/newsletters/2025/03/28/#lnd-8453
[news76 upfront]: /zh/newsletters/2019/12/11/#lnd-3655
[news396 sha256]: /zh/newsletters/2026/03/13/#libsecp256k1-1777
