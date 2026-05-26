---
title: 'Bitcoin Optech 周报 #401'
permalink: /zh/newsletters/2026/04/17/
name: 2026-04-17-newsletter-zh
slug: 2026-04-17-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报介绍了关于在闪电网络节点中使用嵌套 MuSig2 的一种构想，并总结了一个对 secp256k1 模标量乘法进行形式化验证的项目。此外还包括我们的常规栏目：近期服务和客户端软件的更新、新版本和候选版本的公告，以及流行比特币基础设施软件的重要变更摘要。

## 新闻

- **<!--discussion-of-using-nested-musig2-in-the-lightning-network-->****关于在闪电网络中使用嵌套 MuSig2 的讨论：** ZmnSCPxj 在 Delving Bitcoin 上[发帖][kofn post del]，讨论利用一篇近期[论文][nmusig2 paper]中所说的嵌套 MuSig2，来创建 k-of-n 多签名闪电网络节点的构想。

  根据 ZmnSCPxj 的说法，闪电网络中对 k-of-n 签名方案的需求，源于大额持币者希望将其流动性提供给网络以换取手续费收益。这些大额持币者可能需要对资金安全性具有更强的保障，而单个密钥未必能提供这种保障。相反，只要被攻破的密钥少于 k 个，k-of-n 方案就能提供所需的安全性。

  目前，BOLTs 规范并不允许以安全的方式实现 k-of-n 多签名方案，主要障碍在于撤销密钥。按照 BOLTs 的定义，撤销密钥使用 shachain 创建，而 shachain 由于自身特性，并不适合与 k-of-n 多签名方案配合使用。

  ZmnSCPxj 提议修改 BOLTs 规范：节点可通过在 `globalfeatures` 和 `localfeatures` 中同时发送一对新的特性比特 `no_more_shachains`，将是否对通道参与方的撤销密钥执行 shachain 验证变为可选。奇数位表示该节点不会对对手方执行 shachain 验证，但仍会提供符合 shachain 规则的撤销密钥，以保持与旧式节点的兼容性。偶数位表示该节点既不会验证，也不会提供符合 shachain 规则的撤销密钥。按照 ZmnSCPxj 的定义，前一种比特将由网关节点使用，这类节点把网络的其余部分与带有偶数位的 k-of-n 节点连接起来。

  最后，ZmnSCPxj 强调，这项提议带来了一个重大的权衡，即撤销密钥的存储需求。实际上，节点将需要存储单独的撤销密钥，而不是使用紧凑的 shachain 表示方式，这会使所需的磁盘空间大约增加到原来的三倍。

- **<!--formal-verification-of-secp256k1-modular-scalar-multiplication-->****对 secp256k1 模标量乘法的形式化验证：** Remix7531 在 Bitcoin-Dev 邮件列表上[发帖][topic secp formalization]，介绍对 secp256k1 模标量乘法进行形式化验证的工作。该项目表明，对 bitcoin-core/secp256k1 的一个子集进行形式化验证是切实可行的。

  在 [secp256k1-scalar-fv-test 代码库][secp verification codebase]中，Remix7531 直接采用该库中的真实 C 代码，并借助 Rocq 和 Verified Software Toolchain（VST），证明这些代码相对于一个形式化数学规范是正确的。使用 Rocq 进行形式化可以证明不存在内存错误、代码满足规范，并且能够终止。

  他计划把现有的标量乘法证明移植到 RefinedC 上，以便在同一份经过验证的代码上直接比较这两种框架。另外，在验证工作方面，下一个目标是用于多标量乘法的 Pippenger 算法；该算法被用于签名的批量验证。

## 服务和客户端软件的变更

*在这个每月栏目中，我们会重点介绍比特币钱包和服务中值得关注的更新。*

- **<!--coldcard-6-5-0-adds-musig2-and-miniscript-->****Coldcard 6.5.0 添加 MuSig2 和 miniscript：** Coldcard [6.5.0][coldcard 6.5.0] 增加了对 [MuSig2][topic musig] 签名的支持、[BIP322][] 储备证明功能，以及更多 [miniscript][topic miniscript] 和 [taproot][topic taproot] 特性，包括最多支持八个脚本树叶子的 [tapscript][topic tapscript]。

- **<!--frigate-1-4-0-released-->****Frigate 1.4.0 发布：** Frigate [v1.4.0][frigate blog] 是一个用于扫描[静默支付][topic silent payments]的实验性 Electrum 服务器（见[周报 #389][news389 frigate]）。它现在结合使用 UltrafastSecp256k1 库与现代 GPU 计算，将扫描数月区块所需的时间从一小时缩短到了半秒。

- **<!--bitcoin-backbone-updates-->****Bitcoin Backbone 更新：** Bitcoin Backbone [发布][backbone ml 1]了多项[更新][backbone ml 2]，增加了 [BIP152][] [致密区块][topic compact block relay]支持、交易和地址管理改进，以及多进程接口的基础工作（见[周报 #368][news368 backbone]）。该公告还提出了 Bitcoin Kernel API 的扩展，用于独立的区块头验证和交易验证。

- **<!--utreexod-0-5-released-->****Utreexod 0.5 发布：** Utreexod [v0.5][utreexod blog] 引入了使用 [SwiftSync][news349 swiftsync] 的 IBD；SwiftSync 使用密码学聚合，无需在 IBD 期间下载和验证 accumulator 包含性证明，并将 Compact State Nodes 在 IBD 期间额外下载的数据量从 1.4 TB 降低到约 200 GB；如果通过证明缓存，还可能进一步降低。

- **<!--floresta-0-9-0-released-->****Floresta 0.9.0 发布：** Floresta [v0.9.0][floresta v0.9.0] 使其 P2P 网络与用于 UTXO 证明交换的 [BIP183][news366 utreexo bips] 保持一致，并用 Bitcoin Kernel 取代 libbitcoinconsensus，使脚本验证速度提升约 15 倍，此外还有其他多项变更。

## 版本发布和候选版本

_热门比特币基础设施项目的新版本发布和候选版本。请考虑升级到新版本或帮助测试候选版本。_

- [Bitcoin Core 31.0rc4][] 是主流全节点实现下一个主要版本的候选发布。[测试指南][bcc31 testing]已提供。

- [Core Lightning 26.04rc3][] 是这个流行闪电网络节点下一个主要版本的最新候选发布，延续了早期候选版本中的拼接更新和 bug 修复。

## 重大代码和文档变更

_以下是来自 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案 (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期重大变更。_

- [Bitcoin Core #34401][] 扩展了此前加入 `libbitcoinkernel` C API 的 `btck_BlockHeader` 支持（见周报 [#380][news380 kernel] 和 [#390][news390 header]），新增了一种将区块头序列化为其标准字节编码的方法。这使得使用该 C API 的外部程序可以存储、传输或比较序列化后的区块头，而无需单独编写序列化代码。

- [Bitcoin Core #35032][] 在使用 `sendrawtransaction` RPC 的 `privatebroadcast` 选项（见[周报 #388][news388 private]）时，不再把学到的网络地址存入 Bitcoin Core 的对等节点地址管理器 `addrman` 中。`privatebroadcast` 选项允许用户通过短时存在的 [Tor][topic anonymity networks] 或 I2P 连接，或通过 Tor 代理向 IPv4/IPv6 对等节点广播交易。

- [Core Lightning #9021][] 在拼接协议合并进 BOLTs 规范后（见[周报 #398][news398 splicing]），通过将[拼接][topic splicing]从实验状态中移除，使其默认启用。

- [Core Lightning #9046][] 将 [keysend 支付][topic spontaneous payments]的假定 `final_cltv_expiry`（即最后一跳的 [CLTV 到期差值][topic cltv expiry delta]）从 22 个区块提高到 42 个区块，以与 LDK 的取值保持一致，并恢复互操作性。

- [LDK #4515][] 将[零手续费承诺交易][topic v3 commitments]通道（见[周报 #371][news371 0fc]）从实验性特性比特切换到正式特性比特。零手续费承诺交易通道用一个共享的 [Pay-to-Anchor (P2A)][topic ephemeral anchors] 输出取代了两个[锚点输出][topic anchor outputs]，其金额上限为 240 sats。

- [LDK #4558][] 将接收方一侧针对不完整[多路径支付][topic multipath payments]的现有超时机制，应用到 [keysend 支付][topic spontaneous payments]上。此前，不完整的 keysend MPP 可能会一直保持待处理状态，直到 CLTV 到期，从而占用 [HTLC][topic htlc] 槽位，而不是在正常超时时间后失败并回退。

- [LND #9985][] 为正式版[简单 taproot 通道][topic simple taproot channels]增加了端到端支持，使用独立的承诺类型 `SIMPLE_TAPROOT_FINAL` 和正式特性比特 80/81。正式版采用优化后的 [tapscript][topic tapscript]，优先使用 `OP_CHECKSIGVERIFY` 而不是 `OP_CHECKSIG`+`OP_DROP`，并在 `revoke_and_ack` 中新增了基于注资交易 txid 的映射式 nonce 处理，为未来的[拼接][topic splicing]打下基础。

- [BTCPay Server #7250][] 增加了对 [LUD-21][] 的支持，引入了一个名为 `verify` 的可选、无需身份鉴别的端点，使外部服务能够验证通过 [LNURL-pay][topic lnurl] 创建的 [BOLT11][] 发票是否已经结算。

- [BIPs #2089][] 发布了 [BIP376][]。该提案为 [PSBTv2][topic psbt] 定义了新的每个输入字段，用于携带签名和花费[静默支付][topic silent payments]输出所需的 [BIP352][] tweak 数据，此外还定义了一个可选的花费密钥 [BIP32][topic bip32] 派生字段，以兼容 BIP352 的 33 字节花费密钥。这与 [BIP375][] 形成互补；后者规定了如何使用 PSBT 创建静默支付输出（见[周报 #337][news337 bip375]）。

{% include snippets/recap-ad.md when="2026-04-21 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="34401,35032,9021,9046,4515,4558,9985,7250,2089" %}

[coldcard 6.5.0]: https://coldcard.com/docs/upgrade/#edge-version-650xqx-musig2-miniscript-and-taproot-support
[frigate blog]: https://damus.io/nevent1qqsrg3xsjwpt4d9g05rqy4vkzx5ysdffm40qtxntfr47y3annnfwpzgpp4mhxue69uhkummn9ekx7mqpz3mhxue69uhkummnw3ezummcw3ezuer9wcq3samnwvaz7tmjv4kxz7fwwdhx7un59eek7cmfv9kqz9rhwden5te0wfjkccte9ejxzmt4wvhxjmczyzl85553k5ew3wgc7twfs9yffz3n60sd5pmc346pdaemf363fuywvqcyqqqqqqgmgu9ev
[news389 frigate]: /zh/newsletters/2026/01/23/#electrum-server-for-testing-silent-payments-electrum
[news368 backbone]: /zh/newsletters/2025/08/22/#bitcoin-core-kernelbased-node-announced
[backbone ml 1]: https://groups.google.com/g/bitcoindev/c/D6nhUXx7Gnw/m/q1Bx4vAeAgAJ
[backbone ml 2]: https://groups.google.com/g/bitcoindev/c/ViIOYc76CjU/m/cFOAYKHJAgAJ
[news349 swiftsync]: /zh/newsletters/2025/04/11/#swiftsync-speedup-for-initial-block-download-swiftsync
[utreexod blog]: https://delvingbitcoin.org/t/new-utreexo-releases/2371
[floresta v0.9.0]: https://www.getfloresta.org/blog/release-v0.9.0
[news366 utreexo bips]: /zh/newsletters/2025/08/08/#draft-bips-proposed-for-utreexo
[kofn post del]: https://delvingbitcoin.org/t/towards-a-k-of-n-lightning-network-node/2395
[nmusig2 paper]: https://eprint.iacr.org/2026/223
[bitcoin core 31.0rc4]: https://bitcoincore.org/bin/bitcoin-core-31.0/test.rc4/
[bcc31 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/31.0-Release-Candidate-Testing-Guide
[Core Lightning 26.04rc3]: https://github.com/ElementsProject/lightning/releases/tag/v26.04rc3
[news380 kernel]: /zh/newsletters/2025/11/14/#bitcoin-core-30595
[news390 header]: /zh/newsletters/2026/01/30/#bitcoin-core-33822
[news388 private]: /zh/newsletters/2026/01/16/#bitcoin-core-29415
[news398 splicing]: /zh/newsletters/2026/03/27/#bolts-1160
[news371 0fc]: /zh/newsletters/2025/09/12/#ldk-4053
[news337 bip375]: /zh/newsletters/2025/01/17/#bips-1687
[BIP376]: https://github.com/bitcoin/bips/blob/master/bip-0376.mediawiki
[LUD-21]: https://github.com/lnurl/luds/blob/luds/21.md
[topic secp formalization]: https://groups.google.com/g/bitcoindev/c/l7AdGAKd1Oo
[secp verification codebase]: https://github.com/remix7531/secp256k1-scalar-fv-test
