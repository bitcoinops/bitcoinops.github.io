---
title: 'Bitcoin Optech Newsletter #391'
permalink: /zh/newsletters/2026/02/06/
name: 2026-02-06-newsletter-zh
slug: 2026-02-06-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报链接了一项关于常数时间并行化 UTXO 数据库的工作，总结了一种新的用于编写比特币脚本的高级语言，并介绍了一种减轻粉尘攻击的想法。此外还包括我们的常规栏目：关于比特币共识规则变更的讨论摘要、新版本和候选版本的公告，以及流行比特币基础设施软件的重大变更介绍。

## 新闻

- **<!--a-constant-time-parallelized-utxo-database-->****常数时间并行化 UTXO 数据库**：Toby Sharp 在 Delving Bitcoin 上[发布][hornet del]了关于他最新项目的文章 —— 一个名为 "Hornet UTXO(1)" 的自定义高度并行化 UTXO 数据库，支持常数时间查询。这是 [Hornet Node][hornet website] 的一个新增组件，Hornet Node 是一个实验性的比特币客户端，专注于提供比特币共识规则的最小可执行规范。该新数据库意图通过无锁、高并发的架构来改善初始化区块下载（IBD）。

  代码使用现代 C++23 编写，无外部依赖。为优化速度，选用了排序数组和 [LSM 树][lsmt wiki]，而非[哈希映射][hash map wiki]。追加、查询和获取等操作可并发执行，区块在到达时以乱序处理，数据依赖关系会自动解决。代码尚未公开。

  Sharp 提供了一项基准测试来评估其软件的能力。对于重新验证整条主网链，Bitcoin Core v30 耗时 167 分钟（不包含脚本和签名验证），而 Hornet UTXO(1) 仅需 15 分钟完成验证。测试在一台 32 核计算机上进行，配备 128GB 内存和 1TB 存储。

  在随后的讨论中，其他开发者建议 Sharp 将其性能与 [libbitcoin][libbitcoin gh] 进行对比，后者以提供非常高效的 IBD 而闻名。

- **<!--bithoven-a-formally-verified-imperative-language-for-bitcoin-script-->****Bithoven：一种经过形式化验证的比特币脚本命令式语言**：Hyunhum Cho 在 Delving Bitcoin 上[撰文][delving hc bithoven]介绍了他在 Bithoven 上的[工作][arxiv hc bithoven]，这是 [miniscript][topic miniscript] 的一种替代方案。与 miniscript 使用谓词语言（predicate languate）来表达锁定脚本的可能满足条件不同，Bithoven 使用更熟悉的 C 系语法，以 `if`、`else`、`verify` 和 `return` 作为其主要操作。编译器负责所有的栈管理，并提供与 miniscript 编译器类似的保证 —— 所有路径都要求至少一个签名等。与 miniscript 类似，它可以针对不同的脚本版本生成代码。

- **<!--discussion-of-dust-attack-mitigations-->****粉尘攻击缓解方案的讨论**：Bubb1es 在 Delving Bitcoin 上[发帖][dust attacks del]讨论了一种在链上钱包中处理 "[粉尘攻击][topic output linking]" 的方法。此处说的粉尘攻击是指攻击者向所有他想了解的匿名地址发送粉尘 UTXO，希望其中一些会与不相关的 UTXO 一起被无意中花费。

  目前_大多数_钱包处理此问题的方法是在钱包客户端中给攻击粉尘 UTXO 打上粉尘标签，从而阻止其被花费。但如果用户未来从密钥恢复钱包，新的钱包客户端可能不知道这些 UTXO 已被标记，从而"解锁"粉尘 UTXO 使其可被花费。Bubb1es 建议另一种方式来防止粉尘 UTXO 攻击：创建一笔使用粉尘 UTXO 全部金额的交易，发送给一个 `OP_RETURN` 输出使其可证明不可花费。这在 Bitcoin Core v30.0 引入更低的最低中继手续费率（0.1 sats/vbyte）后成为可能。

  他随后列出了以这种方式处理粉尘 UTXO 的钱包实现的几个风险：

  * 如果只有少数钱包实现此功能，会产生指纹识别问题。

  * 如果多个粉尘 UTXO 同时广播，可能会产生关联性。

  * 如果手续费率上升，可能需要重新广播。

  * 在多重签名和硬件签名设置中，为粉尘 UTXO 签名可能令人困惑。

  AJ Towns 提到可被转发的交易体积下限为 65 字节，并解释了使用 ANYONECANPAY|ALL 配合 3 字节的 OP_RETURN 会更加高效。

  Bubb1es 随后提供了一个实验性工具 [ddust][ddust tool] 来演示具体操作方式。

## 共识变更

_本月栏目总结了关于比特币共识规则变更的提案和讨论。_

- **<!--shrincs-324-byte-stateful-post-quantum-signatures-with-static-backups-->****SHRINCS：324 字节有状态后量子签名，支持静态备份**：继[面向比特币后量子未来的基于哈希的签名][news386 jn hash]之后，Jonas Nick 在 Delving Bitcoin 上[详细介绍][delving jn shrings]了一种具有潜在有用特性的基于哈希的[抗量子][topic quantum resistance]签名算法，可用于比特币。

  论文讨论了有状态的和无状态的哈希签名之间的取舍，其中有状态签名可以显著降低开销，但代价是复杂的备份方案。SHRINCS 提供了一种折衷方案：在 密钥 + 状态 的完整性可以确定时使用有状态签名，但如果对状态的有效性存在疑虑，则以更高成本回退到无状态签名。

  SHRINCS 选择的两种方案是用于无状态签名的 SPHINCS+ 和用于有状态签名的 Unbalanced XMSS。发布在输出脚本中的公钥是有状态和无状态密钥的哈希值。由于这些基于哈希函数的签名方案在验证过程中会返回签名公钥，签名者需要同时提供签名以及未使用的公钥，验证者检查返回的公钥与提供的公钥的哈希是否与锁定脚本中指定的密钥一致。选择 Unbalanced XMSS 方案是为了优化只需要较少签名的密钥的使用场景。

- **<!--addressing-remaining-points-on-bip54-->****解决 BIP54 的剩余讨论点**：Antoine Poinsot [撰文][ml ap gcc]讨论了[共识清理软分叉][topic consensus cleanup]的剩余讨论点。

  首先讨论的是强制将 coinbase 交易的 `nLockTime` 设置为区块高度减一的提案。讨论的核心在于这一变更是否会不必要地限制矿机使用该字段作为额外 nonce 的能力，因为未来的矿工可能会耗尽现有 version、timestamp 和 nonce 字段中的 nonce 空间。多位发帖者指出 `nLockTime` 字段已经具有共识强制的语义，因此不是额外 nonce 轮替的首选候选字段。讨论者们提出了多种扩大 nonce 空间的方案，包括额外的 version 位和单独的 `OP_RETURN` 输出。

  另一个讨论的变更是使剥离了见证字节后长为 64 字节的交易在共识中无效。此类交易也受到默认中继策略的限制，但共识变更将保护 SPV（或其他类似的）轻客户端免受某些攻击。多位发帖者质疑这一变更是否值得，因为存在其他缓解措施，而且它会为某些类型的交易（例如某些协议的 [CPFP][topic cpfp]）引入一个可能令人意外的有效性间隙。

- **<!--falcon-post-quantum-signature-scheme-proposal-->****Falcon 后量子签名方案提案**：Giulio Golinelli 在邮件列表上[发帖][ml gg falcon]提出了一个在比特币中启用 Falcon 签名验证的分叉方案。Falcon 算法基于格密码学，正在寻求作为后量子签名算法的 FIPS 标准化。它在链上所需空间约为 ECDSA 签名的 20 倍，但验证速度约为两倍。这使其成为迄今为止为比特币提出的最小的后量子签名方案之一。

  Conduition 指出了 Falcon 算法的一些限制，特别是实现常数时间签名的困难。其他人讨论了比特币的后量子签名算法是否应该在设计时考虑未来的 STARK/SNARK 亲和性。

  注意：虽然邮件列表帖子将其描述为软分叉，但它似乎是在 P2WPKH 验证路径中以 flag-day 析取方式实现的，这将是一个硬分叉。要为该算法开发软分叉客户端还需要进一步的工作。

- **<!--slh-dsa-verification-can-compete-with-ecc-->****SLH-DSA 验证可与 ECC 竞争**：Conduition [撰文][ml cond slh-dsa]介绍了他将后量子的 SLH-DSA 签名的验证算法实现与 libsecp256k1 进行基准测试的持续工作。他的结果表明，SLH-DSA 验证在常见情况下可以与 [schnorr][topic schnorr signatures] 验证竞争。

## 版本发布和候选版本

_热门比特币基础设施项目的新版本发布和候选版本。请考虑升级到新版本或帮助测试候选版本。_

- [LDK 0.1.9][] 和 [0.2.1][ldk 0.2.1] 是这个用于构建闪电网络应用的热门库的维护版本。两者都修复了当存在未确认交易时 `ElectrumSyncClient` 无法同步的 bug。0.2.1 版本还修复了当对等节点不支持[拼接][topic splicing]时 `splice_channel` 未能立即失败的问题，将 `AttributionData` 结构体设为公开，并包含了其他若干 bug 修复。

## 重大代码和文档变更

_以下是来自 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案 (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期重大变更。_

- [Bitcoin Core #33604][] 修正了 [assumeUTXO][topic assumeutxo] 节点的行为。在后台验证期间，节点会避免从其最佳链中不包含快照区块的对等节点下载区块，因为节点缺少处理潜在重组所需的撤销数据（undo data）。然而，在后台验证完成后，这一限制仍然不必要地持续存在，尽管此时节点已经能够处理重组。节点现在仅在后台验证进行期间才应用此限制。

- [Bitcoin Core #34358][] 修复了通过 `removeprunedfunds` RPC 移除交易时出现的钱包 bug。此前，移除一笔交易会再次将其所有输入标记为可以花费，即使钱包中包含一笔同样花费了相同 UTXO 的冲突交易。

- [Core Lightning #8824][] 为寻路插件 `askrene`（见[周报 #316][news316 askrene]）添加了一个 `auto.include_fees` 层，从支付金额中扣除路由手续费，也就是由接收方承担手续费。

- [Eclair #3244][] 添加了两个事件：`PaymentNotRelayed` —— 当支付无法中继到下一个节点（可能由于流动性不足）时触发，以及 `OutgoingHtlcNotAdded` —— 当 [HTLC][topic htlc] 无法添加到特定通道时触发。这些事件帮助节点运营者构建流动性分配的启发式规则，但该 PR 指出不应由单个事件触发分配。

- [LDK #4263][] 为 `pay_for_bolt11_invoice` API 添加了可选的 `custom_tlvs` 参数，使调用者能够在支付洋葱中嵌入任意元数据。以往，虽然底层端点 `send_payment` 已经允许在 [BOLT11][] 支付中使用自定义类型-长度-值（[TLVs][]），但在高级端点上并未正确暴露。

- [LDK #4300][] 添加了对通用 [HTLC][topic htlc] 拦截的支持，建立在为[异步支付][topic async payments]添加的 HTLC 驻留（HTLC holding）机制之上，并扩展了之前仅拦截发往虚假 SCID 的 HTLC 的能力（见[周报 #230][news230 intercept]）。新实现使用可配置的比特字段来拦截发往以下目标的 HTLC：拦截 SCID（与之前相同）、离线私有通道（对需要唤醒休眠客户端的 LSP 有用）、在线私有通道、公共通道和未知 SCID。这为支持 LSPS5（见[周报 #365][news365 lsps5]的客户端实现）和其他 LSP 用例奠定了基础。

- [LND #10473][] 使 `SendOnion` RPC（见[周报 #386][news386 sendonion]）完全幂等（idempotent），使客户端能够在网络故障后安全地重试请求，而不会有重复支付的风险。如果具有相同 `attempt_id` 的请求已被处理，该 RPC 将返回 `DUPLICATE_HTLC` 错误。

- [Rust Bitcoin #5493][] 添加了在兼容的 ARM 架构上使用硬件优化的 SHA256 操作的功能。基准测试表明，对于大区块，哈希速度约提升五倍。这补充了 x86 架构上现有的 SHA256 加速功能（见[周报 #265][news265 x86sha]）。

{% include snippets/recap-ad.md when="2026-02-10 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33604,34358,8824,3244,4263,4300,10473,5493" %}

[news386 jn hash]: /zh/newsletters/2026/01/02/#hash-based-signatures-for-bitcoins-post-quantum-future
[delving jn shrings]: https://delvingbitcoin.org/t/shrincs-324-byte-stateful-post-quantum-signatures-with-static-backups/2158
[ml ap gcc]: https://groups.google.com/g/bitcoindev/c/6TTlDwP2OQg
[delving hc bithoven]: https://delvingbitcoin.org/t/bithoven-a-formally-verified-imperative-smart-contract-language-for-bitcoin/2189
[arxiv hc bithoven]: https://arxiv.org/abs/2601.01436
[ml gg falcon]: https://groups.google.com/g/bitcoindev/c/PsClmK4Em1E
[ml cond slh-dsa]: https://groups.google.com/g/bitcoindev/c/8UFkEvfyLwE
[hornet del]: https://delvingbitcoin.org/t/hornet-utxo-1-a-custom-constant-time-highly-parallel-utxo-database/2201
[hornet website]: https://hornetnode.org/overview.html
[lsmt wiki]: https://zh.wikipedia.org/wiki/%E6%97%A5%E5%BF%97%E7%BB%93%E6%9E%84%E5%90%88%E5%B9%B6%E6%A0%91
[hash map wiki]: https://zh.wikipedia.org/wiki/%E5%93%88%E5%B8%8C%E8%A1%A8
[libbitcoin gh]: https://github.com/libbitcoin
[dust attacks del]: https://delvingbitcoin.org/t/disposing-of-dust-attack-utxos/2215
[ddust tool]: https://github.com/bubb1es71/ddust
[LDK 0.1.9]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.9
[ldk 0.2.1]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.2.1
[news316 askrene]: /zh/newsletters/2024/08/16/#core-lightning-7517
[TLVs]: https://github.com/lightning/bolts/blob/master/01-messaging.md#type-length-value-format
[news230 intercept]: /zh/newsletters/2022/12/14/#ldk-1835
[news365 lsps5]: /zh/newsletters/2025/08/01/#ldk-3662
[news386 sendonion]: /zh/newsletters/2026/01/02/#lnd-9489
[news265 x86sha]: /zh/newsletters/2023/08/23/#rust-bitcoin-1962
