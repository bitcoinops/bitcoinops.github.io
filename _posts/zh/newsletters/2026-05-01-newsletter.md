---
title: 'Bitcoin Optech 周报 #403'
permalink: /zh/newsletters/2026/05/01/
name: 2026-05-01-newsletter-zh
slug: 2026-05-01-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报介绍了一项将二进制 fuse 过滤器用作致密区块过滤器中 GCS 替代方案的研究。此外还包括我们的常规栏目：总结关于修改比特币共识规则的提案与讨论，公告新版本和候选版本，以及介绍流行比特币基础设施软件的重要变更。

## 新闻

- **<!--binary-fuse-filters-as-an-alternative-to-bip158s-gcs-->****作为 BIP158 的 GCS 替代方案的二进制 fuse 过滤器：** Csaba Purszki 在 Delving Bitcoin 上[发帖][bin fuse del]，介绍了他关于寻找更优替代方案的研究，用于取代 [BIP158][] 所定义、供[致密区块过滤器][topic compact block filters]使用的 Golomb-Rice 编码集合（GCS）。

  据 Purszki 介绍，一个合适的替代方案是二进制 fuse 过滤器；它属于用于近似集合成员关系判断的一类概率型数据结构。具体来说，他研究的是其中的 16 位变体 Fuse16。这类算法的主要特点是查询时间可以达到 O(1)（作为对照，GCS 为 O(N)），因此能够降低查询过滤器所需的 CPU 算力。此外，这些过滤器能够保证零假阴性，而假阳性率则等于 `1/2^k`，其中 `k` 是比特数。

  Purszki 给出了这项研究的初步结果，将当前 GCS 的性能与二进制 fuse 过滤器进行了比较。测试覆盖了 10 种不同的钱包使用场景（从 24 个脚本到 480 个脚本不等），在两种不同 CPU（桌面级 x86_64 和 ARM）上，对主网的 5 万个区块运行过滤器。结果显示，二进制 fuse 过滤器在 ARM 上可根据不同钱包场景实现 6 倍到 45 倍的加速，在桌面平台上可实现 9 倍到 80 倍的加速，代价只是带宽略有增加，增幅为 0% 到 3%。关于测试方法和完整结果，可参阅 [Purszki 的网站][bin fuse web]。

  Kyoto 开发者 Robert Netzke 还评论了这类过滤器与 GCS 在假阳性率上的差异，以及该算法中可能出现的失败情形。

## 修改共识

_本月栏目，总结关于修改比特币共识规则的提案和讨论。_

- **<!--postquantum-hd-wallets-with-fallback-sphincs-keys-->****带有后备 SPHINCS 密钥的后量子 HD 钱包：** Conduition 在 Bitcoin-Dev 邮件列表上[发帖][c ml pq bip32]，描述了一种与 [BIP32][] 兼容的[后量子][topic quantum resistance] [层级确定性钱包][topic bip32]设计，并为其加入后备的 [SPHINCS][news383 sphincs] 密钥。该设计替换了 BIP32 的子密钥派生函数，使其在生成 [secp256k1][secp256k1] 密钥的同时，也生成 SPHINCS 密钥。由于 SPHINCS 密钥内部缺乏代数关系，非 hardened 子密钥会与其父密钥和同级密钥共享同一组 SPHINCS 密钥。因此，钱包需要在使用 SPHINCS 密钥花费的脚本中插入一个随机数（nonce）（或 secp256k1 密钥），以保留与 BIP32 钱包等价的隐私性。

  这一设计选择的一个好处是，代价高昂的完整 SPHINCS 密钥派生可以延后到第一次非 hardened 派生步骤时再执行，并可将结果缓存起来，供该步骤以下的所有非 hardened 密钥复用。该钱包设计计划与 [BIP360][] 的 P2MR 输出以及未来的 `OP_CHECKSPHINCS`（或类似操作码）结合，以支持迁移到抗量子的钱包。Conduition 还提出，这种钱包结构未来也许可以与成本更低的后量子签名算法结合，而在这些算法被证明不安全时，则由 SPHINCS 充当可靠的后备方案。

- **<!--discussion-of-a-postquantum-output-type-->****关于一种后量子输出类型的讨论：** Antoine Poinsot 在 Bitcoin-Dev 邮件列表上[撰文][ap ml pqout]，为一种朴素的后量子输出类型进行辩护（不同于 [P2TR][topic taproot] 风格的输出类型，后者允许通过后续软分叉来禁用易受量子攻击的密钥花费）。其论点的核心在于：是否、以及何时适合禁用易受量子攻击的花费，这一决策应当与“让用户能按自身意愿迁移到后量子密码学”分开处理。在后续讨论中，参与者同意两件事：一是把后量子签名加入 [tapscript][topic tapscript]，二是增加一种朴素的后量子输出类型。若干开放问题仍未解决，包括是否以及在多大程度上激励迁移，以及何时、是否应禁用易受量子攻击的签名。

- **<!--proposal-to-embed-postquantum-keys-in-tapscript-without-consensus-changes-->****在无需修改共识规则的情况下将后量子密钥嵌入 tapscript 的提案：** Daniel Buchner 向 Bitcoin-Dev 邮件列表[发送][db ml minpqc]了一项提案，描述了一条潜在路径，可以启用灵活的后量子钱包设计，而无需完整规定签名验证参数。由于 [BIP342][] 的签名检查操作码会将所有非 32 字节密钥视为未知密钥类型，并在签名非空时一律判定为有效，因此其他长度的密钥（在演示案例中是带有一个初始标签字节的密钥）今天就可以在脚本中使用，只要这些脚本保持保密，或者它们除了不明密钥之外还额外要求一个安全的 [BIP340][] 签名即可。

  如果 Buchner 的提案未来实现标准化，钱包就可以从现在开始构建包含各种后量子密钥类型的脚本，同时继续使用易受量子攻击的密钥来花费资金，直到某次软分叉启用可安全使用后量子密钥的花费方式。与许多量子迁移提案一样，这个方案只有在严格防止密钥重用的前提下，才能在面对量子对手时保留安全性。Buchner 正在征求对此提案的反馈。

- **<!--bip54-demonstration-of-slow-blocks-on-signet-->****BIP54 开发者在 signet 上演示慢验证区块：** Antoine Poinsot 在 Delving Bitcoin 上[撰文][ap delving slowblocks]，介绍了一次关于 [BIP54][]（[共识清理][topic consensus cleanup]）所防止的那类“验证速度很慢的区块”的演示。演示在一天之内分三次进行：在最流行的比特币 [signet][topic signet] 上签出一批慢验证区块，随后再将其重组出去，以便在不永久拖慢 signet 初始区块下载的前提下，测试这类区块的传播和验证行为。世界各地许多人都观察到这些慢区块到达自己的节点，并记录了其验证与传播表现。正如预期，验证速度慢的区块在网络中的传播显著更慢，且在各个节点上完成完整验证所需的时间也明显长于普通区块。需要指出的是，这些演示区块距离 BIP54 所要防止的最坏情形还差得很远。

- **<!--postquantum-bip86-recovery-using-zkstark-proofs-of-bip32-seeds-->****使用 BIP32 种子 zk-STARK 证明实现后量子 BIP86 恢复：** Olaoluwa Osuntokun（roasbeef）在 Bitcoin-Dev 邮件列表上[发帖][oo ml pqrecovery]，介绍了他的项目：演示由 [BIP32][] 派生密钥保护、易受量子攻击的钱币如何可以通过 zk-STARK 来恢复。这种在应对具备密码学意义的量子计算机而禁用 [secp256k1][secp256k1] 时可以恢复钱币控制权的机制，一直有人讨论，但从未被完整演示出来。Osuntokun 做出了一个完整可运行的证明器和验证器实现，并给出了基准测试结果，显示至少从可行性上说，这种方法确实可以用于恢复资金。原始实现有意未作优化，随后多位开发者提出了多项优化建议，能同时降低生成证明和验证证明的成本。

## 版本发布和候选版本

_热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。_

- [Core Lightning 26.04.1][] 是一个维护版本，包含 [gossip][topic channel announcements] 协议修复，以及针对那些在该主要版本发布后立即遇到问题的环境所做的构建系统修复。

- [BTCPay Server 2.3.8][] 是这个自托管支付解决方案的一个小版本更新，包含订阅和 POS 机功能更新、对 LUD21 [LNURL-pay][topic lnurl] 的支持、一个用于管理订阅商品的额外 API 接口，以及其他修复与改进。

- [BTCPay Server 2.3.9][] 是一个维护版本，修复了插件崩溃后的服务器恢复问题，以及 v2.3.8 中引入的一个 xpub 解析问题。

## 重大代码和文档变更

_以下是来自 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案 (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期重大变更。_

- [Bitcoin Core #33671][] 为 `getbalances` RPC 添加了一个 `nonmempool` 字段（见[周报 #46][news46 getbalances]），用于表示钱包中那些已被交易花费、但这些交易既未确认、也不在节点交易池中的 UTXO；例如未广播交易、非标准交易、被驱逐的交易，或者属于过长待确认交易链条的交易。此前，余额分桶可能会遗漏这些“飞行中”花费所对应的金额，尽管钱包仍然记录着这些交易，因此 `getbalances` 不能完整反映钱包对这些资金的记账方式。这个 PR 将这部分金额计入其所属的常规 `mine` 分桶中，并通过 `nonmempool` 进行偏移，从而使各字段求和后仍等于钱包的总余额，同时也明确暴露出与交易池状态不一致的部分。

- [Bitcoin Core #34885][] 为 `libbitcoinkernel` 的 C API 添加了 `btck_block_tree_entry_get_ancestor()`（见[周报 #380][news380 kernel]），可用于获取某一区块在其所在链分支上、指定高度处的祖先区块。调用方若需要从一个陈旧或分叉的链尖构造区块定位器，就不必再通过重复调用 `btck_block_tree_entry_get_previous()` 一次次向后遍历，而可以直接请求所需高度的祖先。

- [Bitcoin Core #33920][] 添加了一个 `exportasmap` RPC，可将节点在构建时嵌入的 ASMap 数据导出到文件中（见[周报 #394][news394 asmap]）。这使用户能够借助 `contrib/asmap-tool.py` 等工具检查、验证和分析这些数据。

- [Bitcoin Core #34911][] 从若干交易池 RPC 响应中移除了与已弃用 [RBF][topic rbf] 相关的布尔字段，除非用户通过 `deprecatedrpc` 配置选项显式请求它们。`getmempoolinfo` RPC 默认不再返回 `fullrbf` 字段，因为 full-RBF 行为自 Bitcoin Core 28.0 起就已成为默认设置，而 `mempoolfullrbf` 选项也已在 Bitcoin Core 29.0 中移除。`getrawmempool`、`getmempoolentry`、`getmempoolancestors` 和 `getmempooldescendants` RPC 也默认不再返回 [BIP125][] 中描述的已弃用 `bip125-replaceable` 字段。

- [BIPs #1548][] 添加了 [BIP391][]，它定义了 Binary Output Descriptors（BOD）规范：一种高效的容器格式，用于存放[输出脚本描述符][topic descriptors]，其基础是类似 [PSBT][topic psbt] 风格的键值映射。这个 BIP 当前状态为 closed，并将 [BIP393][] 列为拟议替代方案，同时指出 [BIP391][] 已在 [BIP393][] 提出一种处理描述符注解等钱包元数据的替代方法后被撤回（见[周报 #400][news400 bip393]）。

- [HWI #831][] 添加了对 Ledger Nano Gen5 硬件签名设备的支持。

- [BDK #2188][] 开始在缓存或使用从 Electrum 服务器返回的交易之前，验证该交易是否与请求的 txid 相匹配。此前，服务器可以对 `fetch_tx()` 请求返回任意交易数据及一个不同的 txid，而 BDK 会照单全收。

- [BDK #2115][] 通过为 `ToBlockHash` trait 添加一个可选的 `prev_blockhash()` 方法，让 `CheckPoint` 具备了“感知前一区块哈希值”的能力。这使 BDK 能够在载荷中包含前一区块哈希值信息时（例如区块头），验证相邻检查点是否正确连接。这也防止 `merge_chains()` 将一个在高度 0 上相冲突的检查点，当作普通重组来处理并据此替换链。现在，如果两条检查点链在创世区块上不一致，合并就会失败。关于 `CheckPoint` 的先前工作，请参见[周报 #372][news372 checkpoint]和[#390][news390 checkpoint]。

{% include snippets/recap-ad.md when="2026-05-05 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33671,34885,33920,34911,831,2188,2115,1548" %}
[c ml pq bip32]: https://groups.google.com/g/bitcoindev/c/5tLKm8RsrZ0
[news383 sphincs]: /zh/newsletters/2025/12/05/#lh-dsa-post-quantum-signature-optimizations
[secp256k1]: https://en.bitcoin.it/wiki/Secp256k1
[ap ml pqout]: https://groups.google.com/g/bitcoindev/c/JA3kDl8AmQg
[db ml minpqc]: https://groups.google.com/g/bitcoindev/c/jn7COyeHtW0
[ap delving slowblocks]: https://delvingbitcoin.org/t/consensus-cleanup-demo-of-slow-blocks-on-signet/2367
[oo ml pqrecovery]: https://groups.google.com/g/bitcoindev/c/Q06piCEJhkI
[bin fuse del]: https://delvingbitcoin.org/t/binary-fuse-filters-as-an-alternative-to-bip-158-gcs/2428
[bin fuse web]: https://purszki.github.io/bitcoin_research_01/
[BTCPay Server 2.3.8]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.3.8
[BTCPay Server 2.3.9]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.3.9
[Core Lightning 26.04.1]: https://github.com/ElementsProject/lightning/releases/tag/v26.04.1
[LUD-21]: https://github.com/lnurl/luds/blob/luds/21.md
[news372 checkpoint]: /zh/newsletters/2025/09/19/#bdk-1582
[news380 kernel]: /zh/newsletters/2025/11/14/#bitcoin-core-30595
[news390 checkpoint]: /zh/newsletters/2026/01/30/#bdk-2037
[news394 asmap]: /zh/newsletters/2026/02/27/#bitcoin-core-28792
[news400 bip393]: /zh/newsletters/2026/04/10/#bips-2099
[news46 getbalances]: /zh/newsletters/2019/05/14/#bitcoin-core-15930
