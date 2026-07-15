---
title: 'Bitcoin Optech 周报 #412'
permalink: /zh/newsletters/2026/07/03/
name: 2026-07-03-newsletter-zh
slug: 2026-07-03-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报包括我们的常规栏目：总结关于修改比特币共识规则的讨论，宣布新版本和候选版本，以及介绍流行比特币基础设施软件的重要代码变更。

## 新闻

*本周我们在所有[信息来源][sources]中都没有发现重要新闻。*

## 共识变更

_每月栏目，总结关于修改比特币共识规则的提议和讨论。_

- **<!--benchmarking-slh-dsa-stark-aggregation-->****SLH-DSA STARK 聚合的基准测试：** Remix7531 在 Bitcoin-Dev 邮件列表上[发帖][rs ml starkbench]，公布了他把大量 [SPHINCS][news383 sphincs] 签名验证聚合进单个 STARK 证明中的基准测试结果。这延续了 Ethan Heilman 早先提出的[方案][eh ml starkagg]：使用 STARK 来扩展[后量子][topic quantum resistance]区块。在这套基准测试中（构建于 RISC Zero 的 zkVM 之上），证明时间大致随签名数量线性增长（在 RTX 5090 上约为每个签名 3.1 秒）；证明大小则次线性增长（从 1 个签名时的 218 KiB 增长到 512 个签名时的 454 KiB，而原始签名总大小约为 3.8 MiB）；验证时间则基本保持在 12 到 15 毫秒之间，与批量大小无关。若要在单个 GPU 上为整块区块生成证明，仍然需要数小时；但 Remix 认为，使用专用 AIR 电路（即为签名验证专门定制多项式约束，而不是使用这里的通用 zkVM）、对交易池进行预处理，以及使用多 GPU 生成证明，都可能改善这一点。这些基准测试使用的还是标准版 SPHINCS，而不是更紧凑、为比特币优化的 [SPHINCS+][news386 jn hash] 变体。

- **<!--bird-of-prey-2-bop-2-non-malleable-schnorr-and-pq-signatures-->****Bird of Prey 2（BoP-2）不可熔融的 schnorr 和后量子签名：** Pieter Wuille 在 Delving Bitcoin 上[发帖][pw delving bop2]，介绍了一篇 EuroCrypt 2026 论文；该论文研究如何从一种类 [schnorr][topic schnorr signatures]方案和任意一种[后量子][topic quantum resistance]签名方案中，构造出混合的强不可伪造签名方案。若只是简单地把两种方案的签名拼接起来，那么只要至少有一种方案仍然安全，整体签名就仍然不可伪造；但这种构造并不具备强不可伪造性。如果其中任意一种方案失效，攻击者就可以替换该方案对应的局部签名，而整体签名仍然有效。论文中的 BoP-2 构造通过让 schnorr 签名在其挑战哈希值中承诺后量子签名，避免了这一问题。

  Adam Gibson 和 Conduition 讨论了在 [segwit][topic segwit] 之后，强不可伪造性是否仍然重要，因为见证数据已经不会影响 txid。Wuille 解释说，问题在于：一旦量子攻击或经典攻击使其中某个方案失效，任何人都可能熔融这个已失效方案所对应的签名部分。Conduition 将这种构造与 Boris Nagaev 的节省空间的混合哈希式设计作了比较（见下文关于格签名的条目），并得出结论：BoP-2 看起来是更强的统一混合方案候选。不过，Wuille 和 Conduition 都质疑：既然单独的 [BIP360][]（[P2MR][news393 p2mr]）树叶，或简单的脚本组合，也能达到类似效果，那么统一混合方案是否值得引入这份复杂性。

- **<!--lattice-based-signatures-->****基于格的签名：** Nikita Karetnikov 在 Delving Bitcoin 上[发帖][nk delving lattice]，并将内容[交叉发布][nk ml lattice]到 Bitcoin-Dev 邮件列表，讨论了一篇 Blockstream 的[博客文章][bs blog lattice]；该文比较了后量子签名的不同家族，并指出基于格的方案在大小和功能性方面似乎更有优势。他因此询问：为什么比特币的后量子研究工作至今主要集中在基于哈希的签名上。

  Conduition 在[回复][c ml lattice]中表示，基于哈希的签名对比特币仍然很有吸引力，因为它的安全假设更弱、实现更简单、验证更快，而且适合作为长期后备方案。Mikhail Kudinov 指出，虽然粗略地说，基于格的签名往往需要浮点计算，但 Falcon 的浮点运算可以用整数来模拟。Conduition 和 Jesse Posner 还讨论了：是否确实有必要采用统一的 schnorr+格混合方案，还是说用独立的 [BIP360][]（P2MR）树叶也能取得类似安全性。另一方面，Boris Nagaev 描述了把混合签名视为一种单一构造、而不是多个签名方案简单拼接之后可以节省的空间，因为它们很可能可以共享某些必需的随机化参数，等等。

- **<!--public-key-recovery-for-p2mr-ec-leaves-->****P2MR EC 树叶的公钥恢复：** starius 在 Delving Bitcoin 上[发帖][st delving recover]，提议为 [BIP360][]（P2MR）增加一种可恢复的椭圆曲线（EC）密钥树叶类型。这个想法是：从 [schnorr][topic schnorr signatures] 签名中恢复 EC 公钥。在 P2MR 默克尔树中，被承诺的是公钥而不是脚本，同时会修改 schnorr 签名的挑战值，让它纳入默克尔根和控制区块，而不是纳入公钥本身。由于默克尔根和控制区块在签名时和验证时都是已知的，因此无需知道公钥就能验证签名；随后，还可以通过控制区块来验证该公钥确实包含在默克尔根中。使用这项技术后，一个深度为 1 的 schnorr 树叶见证可从 135 字节缩小到 100 字节，介于 [P2TR][topic taproot] 密钥花费和 [P2WPKH][topic segwit] 花费的大小之间，但代价是放弃 [BIP340][] 批量验证。starius 和 Conduition 解释说，把控制区块纳入挑战值，可以防止当多个此类树叶共享一棵树时出现相关密钥攻击。Pieter Wuille 对这一构造作出了积极评价。Anthony Towns、Pieter Wuille 和 Conduition 还讨论了它对 [BIP32][topic bip32] 派生、批量验证折扣，以及与 Conduition 提出的深度为零树禁令之间的相互影响（深度为零的可恢复树叶可以在没有后量子后备路径的情况下，实现与 [P2TR][topic taproot] 接近的见证大小）。starius 解释说，由于这会改变见证解析规则，因此应当在激活之前把它并入 BIP360。

- **<!--aligning-privacy-incentives-in-p2mr-->****在 P2MR 中对齐隐私激励：** Conduition 在 Bitcoin-Dev 邮件列表上[发帖][c ml p2mrdepth]，提议修改 [BIP360][]（P2MR）：要求每个 P2MR 控制区块都至少包含一个 32 字节的默克尔认证路径（也就是禁止深度为零的脚本树）。深度为零的树，会让某些只需要单一路径脚本的协议在 P2MR 中比在 [P2TR][topic taproot] 中更高效，从而形成一种反常激励：促使人们跳过合作签名路径，也让某些合约协议更容易在链上被识别出来。

  Antoine Poinsot 认同这可以解决隐私顾虑，但他仍然更倾向于使用 [P2TRv2][news403 pqout] 进行大规模迁移，因为典型的单密钥 P2MR 花费大约比 P2TRv2 高 15%（如果采用上文提到的密钥恢复技术，这个差距可能会缩小）。Pieter Wuille 认为，相比长期的后量子效率，量子攻击发生前的采用激励更重要，而 P2TRv2 更能把迁移成本降到最低。他还指出，只有当用户可以依赖未来某次软分叉来禁用 P2MR 内部的椭圆曲线路径时，P2MR 才说得通。Conduition 预测，无论采用哪种设计，自愿迁移率都可能同样偏低；并提到一种即将到来的、针对常见椭圆曲线花费的见证大小优化（见下一条）。Hayashi [建议][h ml p2mrdepth]，还可以对 P2MR 的 schnorr 树叶额外给予见证折扣，以进一步缩小成本差距。

- **<!--prohibit-merkle-internal-node-preimages-that-encode-minimal-64-byte-transactions-->****禁止编码最小 64 字节交易的默克尔内部节点原像：** Jeremy Rubin 在 Bitcoin-Dev 邮件列表上[发帖][jr ml merkle64]，给出了一份 BIP 草案，作为[共识清理][topic consensus cleanup]（[BIP54][]）规则的替代方案。后者会让剥离见证后大小为 64 字节的交易在共识层面无效。Rubin 的规则并不禁止这类交易本身，而是让所有交易默克尔树中只要包含一个内部节点原像、且其字节布局与最小的一输入一输出剥离见证交易相同的区块无效。这样做针对的是同一类[默克尔树漏洞][topic merkle tree vulnerabilities]，只是作用位置在内部节点边界上，同时还能保留那些可能有用的 64 字节交易（见[周报 #408][news408 64byte]）。SPV 验证器需要拒绝那些分支原像与禁用模式相匹配的证明。该草案还包含矿工的恢复指引（重新排序或移除有问题的交易），并指出意外触犯规则的情况应当很少见。

  多个回复者更喜欢 BIP54 那种更简单的、直接禁止 64 字节交易的做法。Antoine Poinsot 认为，任何承载价值的系统本来就会正确验证这些交易，因此 Rubin 所强调的区别在实践中意义不大。Matt Corallo 指出，这将要求矿工修改他们的区块构建软件，否则就有产出无效区块的风险。Murch 指出，相比让每个节点在区块验证期间检查成千上万个哈希值，偶尔额外增加一个字节的填充，负担要小得多。Sjors Provoost 则建议，把更干净的修复方案留到未来更改区块头格式时再处理。

- **<!--triggering-ec-disabling-with-a-nums-point-spend-or-hashrate-majority-->****通过 NUMS 点花费或算力多数触发禁用 EC：** Pieter Wuille 在 Bitcoin-Dev 邮件列表上[撰文][pw ml p2xx]，讨论如何把未来预期中的“在新的[后量子][topic quantum resistance]输出类型中禁用椭圆曲线（EC）花费路径”写入规则，例如 [BIP360][]（P2MR）和 [P2TRv2][news403 pqout]。如果没有由共识强制执行的触发条件，用户就不会确信 EC 花费路径真的会被禁用，这会削弱那些在初期允许廉价 EC 花费的新输出类型所承诺的抗量子能力。

  Wuille 提议把两种机制与引入这些输出类型的软分叉一并部署：其一是 tripwire（P2XX-T），即只要任意一次成功的 `<NUMS> OP_CHECKSIG` 花费证明 secp256k1 已被攻破，就会在新输出类型中禁用 EC 路径，从而对 EC 可用期设置一个不带没收性质的上界；其二是 miner lockdown（P2XX-ML），允许算力多数通过一次单独发信号、且激活窗口极长的软分叉，触发同样的禁用效果。Boris Nagaev 支持 tripwire，但担心在发生大规模经典盗窃之后，miner lockdown 可能出现误报。Sjors Provoost 建议使用很长的延迟期，并让用户迁回 [P2TR][topic taproot]，作为补救措施。Conduition 支持 tripwire，并指出相关证明不必真的上链挖出；他还警告说，过早触发 miner lockdown 可能会受到手续费激励。Wuille 澄清说，禁用措施必须覆盖该输出类型中的所有 EC 用法（而不只是密钥路径），而且混合签名应使用专门的操作码，而不是任意脚本组合，这样才能在禁用 EC 之后仍然保证可花费性。

## 版本和候选版本

_流行比特币基础设施项目的新版本和候选版本。请考虑升级到新版本，或帮助测试候选版本。_

- [Bitcoin Core 31.1rc1][] 是这一主导型全节点实现维护版本的候选版本。它修复了 `-privatebroadcast` 中一个可能破坏[交易来源隐私][topic transaction origin privacy]的 IP 地址泄漏问题（见[周报 #409][news409 privatebroadcast]），并包含针对 chainstate 压缩、钱包迁移、输入大小估算、[MuSig2][topic musig] 密钥聚合，以及 [v2 P2P 传输][topic v2 p2p transport]重新连接期间代理处理的修复。

- [Bitcoin Core 30.3rc1][] 是这一主导型全节点实现维护版本的候选版本。它修复了一个 chainstate 数据库问题；该问题可能导致正常运行期间出现过多的磁盘读写。此外，它还包含钱包、[PSBT][topic psbt]、[miniscript][topic miniscript]、网络、构建、测试和文档方面的修复。

- [Bitcoin Core 29.4rc1][] 是这一主导型全节点实现维护版本的候选版本。它修复了与 30.3rc1 相同的 chainstate 数据库重写问题，并包含经过挑选的验证、钱包、构建、测试、文档、CI 和兼容性修复。

- [Core Lightning v26.06.2][] 是一个维护版本，修复了 `cln-currencyrate` 在未安装 TLS 根证书的最小化操作系统和 Docker 环境中的问题。

- [LND v0.20.2-beta.rc1][] 是这一流行 LN 节点实现维护版本的候选版本。它修复了一个 DNS 回退 panic 和一个链上 forward-interceptor 结算漏洞，并加入了下文“重要代码变更”栏目提到的、对最终一跳 [HTLC][topic htlc] CLTV 过期值的校验。

- [LND v0.21.1-beta][] 是这一流行 LN 节点实现的维护版本。它修复了新建启用 Tor 的节点在创建 [Tor][topic anonymity networks] v3 onion service 时的问题、一个 DNS 回退 panic，以及一个链上 forward-interceptor 结算漏洞，并进一步收紧了对最终一跳 HTLC CLTV 过期值的校验。

- [LDK v0.2.4][] 是这个用于构建支持 LN 的钱包和应用程序的库的维护版本。它修复了 v0.2.3 中的一个回归问题；此前该问题提高了 `lightning` crate 所支持的最低 Rust 版本。现在，这个 crate 又可以使用 `rustc` 1.63 编译了。

## 重大的代码和文档变更

_以下是来自 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期重大变更。_

- [Bitcoin Core #35266][] 为 `migratewallet` RPC 增加了一个 `load_wallet` 参数（默认为 true），允许把旧式钱包迁移为[描述符][topic descriptors]钱包后，不立即加载迁移后的钱包。这有助于用户在一个已修剪节点上迁移旧式钱包：如果该节点的链状态已经被修剪到钱包生日区块之前，那么加载迁移后钱包会需要不可用的区块数据，而迁移过程本身并不需要这些数据。

- [Bitcoin Core #35550][] 更新了[致密区块中继][topic compact block relay]协商逻辑，拒绝 `sendcmpct` 消息中“是否通告”这个布尔字段不是精确 `0` 或 `1` 的情况，正如 [BIP152][] 所要求的那样。此前，Bitcoin Core 会直接把该字段解码成 C++ 的 `bool`，导致任何非零值都会被当作 true 接受。现在，这个 PR 会把该字段按整数读取，并把大于 1 的值视为对等节点的不当行为，从而断开该对等节点的连接。

- [Bitcoin Core #35610][] 为 `bitcoin-util` 增加了一个 `netmagic` 命令，用于打印所选链在 Bitcoin P2P 消息中使用的四字节网络标识符，其中也包括自定义 [signet][topic signet]。这个命令对拟议中的 multi-signet datadir 支持很有用：在该设计中，自定义 signet 会被存放在以其网络标识符为后缀的数据目录中。这样，脚本就能在启动 `bitcoind` 之前先选中正确目录。

- [BIPs #2196][] 新增了 [BIP95][]，这是 [testnet5][topic testnet] 的一份草案规范；它是一种计划取代 testnet4 的新测试网络（见[周报 #409][news409 testnet5]）。testnet4 具有一个难度例外规则，允许在长时间间隔之后出现最低难度区块。然而，这个例外一直被持续利用，导致频繁而规模较小的重组，使该网络难以用于测试。testnet5 删除了这一例外，把最低难度提高到约 1,048,561，并从区块 1 开始强制执行 [BIP54][] [共识清理][topic consensus cleanup]规则。该草案还规定了消息起始字节 `0x46495645`（`FIVE`）以及默认 P2P 端口 `18335`，不过其创世区块数值目前仍是占位符。

- [BIPs #2165][] 更新了 [BIP52][]，即[光学工作量证明][news181 bip52]提案，把它的状态从 Draft 改为 Closed。BIP52 曾提出一次硬分叉，声称可以把挖矿成本从电力和运营转移到专用光学挖矿设备上。在多年没有进展、且近期也未能成功联系到作者之后，该提案被关闭。

- [BIPs #2201][] 将 [BIP110][]（Reduced Data Temporary Softfork 提案）的状态推进到 Complete（见[周报 #392][news392 bip110]）。这次更新强调，激活前创建的 UTXO 会被祖父化，因此在部署期间仍可按旧规则花费。它还增加了参考实现的测试覆盖以及交易级别的测试向量。此外，更新还澄清了在 [tapscript][topic tapscript] 树叶中临时禁止执行 `OP_IF` 和 `OP_NOTIF` 的影响：现有 UTXO 不受影响，但新的、使用这些操作码的构造就需要改用其他方案，比如独立树叶。

- [LND #10900][] 增加了一个 `WalletKit.SubmitPackage` RPC 和一个 `lncli wallet submitpackage` 命令，用于把一个 1p1c[交易包][topic package relay]提交给 LND 的区块链后端。对于 bitcoind 后端，LND 会把该交易包转发给 Bitcoin Core 的 `submitpackage` RPC，从而允许一个零手续费的 [v3 交易中继][topic v3 transaction relay]父交易，连同其[临时锚点][topic ephemeral anchors]以及一个付手续费的 [CPFP][topic cpfp] 子交易一起被接收。其他后端则不提供同样的交易包提交能力：btcd 会返回 unimplemented，而 neutrino 会逐笔广播这些交易。

- [LND #10927][] 收紧了对最终一跳 [HTLC][topic htlc] 的 CLTV 过期值校验。此前，最终一跳 HTLC 可以指定一个远远晚于接收者策略所允许值的过期高度，从而即便中继用的 CLTV 差值已经受到限制，仍然会把流动性占用过长时间。LND 现在会用 `incorrect_or_unknown_payment_details` 拒绝那些超出接收者 CLTV 策略范围的最终 HTLC，还会校验相关配置边界；如果通道在决定是否使用原像在链上领取 HTLC 之前就被强制关闭，也会应用同样的检查。

- [LDK #4748][] 和 [#4751][ldk #4751] 修复了两个与延迟消息有关的[拼接][topic splicing]状态机边界情形。[LDK #4748][] 修复了这样一种情况：延迟到达的 splice `tx_signatures`，可能会在一个无关的、由 [HTLC][topic htlc] 原像触发的通道监视器更新尚待处理时到达，导致 LDK 错误地阻塞拼接流程的完成。现在，只有当待处理的监视器更新正是那个必须先被持久化的、与拼接相关的更新时，LDK 才会等待。[#4751][ldk #4751] 则修复了另一种情况：当本地用户已经取消自己的注资贡献之后，对等节点仍可能发送一个仍在飞行中的 splice `commitment_signed`，从而导致 LDK 去验证一个过时拼接注资交易的签名，并可能错误地强制关闭其实仍然有效的通道。LDK 现在会检查 `commitment_signed` 中可选的 `funding_txid`，并忽略那些针对过时拼接注资交易的签名。

{% include snippets/recap-ad.md when="2026-07-07 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2165,2196,2201,35266,35550,35610,10900,10927,4748,4751" %}

[rs ml starkbench]: https://groups.google.com/g/bitcoindev/c/0IdqdnlC4Og
[eh ml starkagg]: https://groups.google.com/g/bitcoindev/c/wKizvPUfO7w
[pw delving bop2]: https://delvingbitcoin.org/t/bird-of-prey-2-non-malleable-schnorr-pq-signatures/2514
[c ml p2mrdepth]: https://groups.google.com/g/bitcoindev/c/p8AVEmAtWdA
[h ml p2mrdepth]: https://groups.google.com/g/bitcoindev/c/p8AVEmAtWdA/m/D3hERI8wCwAJ
[st delving recover]: https://delvingbitcoin.org/t/public-key-recovery-for-ec-leaves-in-p2mr-bip-360/2603
[nk ml lattice]: https://groups.google.com/g/bitcoindev/c/nMO4hyEm5qc
[nk delving lattice]: https://delvingbitcoin.org/t/pqc-lattice-based-signatures/2522
[c ml lattice]: https://groups.google.com/g/bitcoindev/c/nMO4hyEm5qc/m/XFpCuylPCQAJ
[bs blog lattice]: https://blog.blockstream.com/schnorr-but-with-vectors-lattice-based-signatures-explained/
[jr ml merkle64]: https://groups.google.com/g/bitcoindev/c/ZVDEzxG6Sq8
[pw ml p2xx]: https://groups.google.com/g/bitcoindev/c/aWYtPLVPZ3U
[news383 sphincs]: /zh/newsletters/2025/12/05/#lh-dsa-post-quantum-signature-optimizations
[news386 jn hash]: /zh/newsletters/2026/01/02/#hash-based-signatures-for-bitcoins-post-quantum-future
[news393 p2mr]: /zh/newsletters/2026/02/20/#bips-1670
[news403 pqout]: /zh/newsletters/2026/05/01/#discussion-of-a-postquantum-output-type
[news408 64byte]: /zh/newsletters/2026/06/05/#bip54-64-byte-transactions-and-potential-legitimate-uses
[Core Lightning v26.06.2]: https://github.com/ElementsProject/lightning/releases/tag/v26.06.2
[LND v0.20.2-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.2-beta.rc1
[LND v0.21.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.21.1-beta
[LDK v0.2.4]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.2.4
[Bitcoin Core 31.1rc1]: https://bitcoincore.org/bin/bitcoin-core-31.1/test.rc1/
[Bitcoin Core 30.3rc1]: https://bitcoincore.org/bin/bitcoin-core-30.3/test.rc1/
[Bitcoin Core 29.4rc1]: https://bitcoincore.org/bin/bitcoin-core-29.4/test.rc1/
[news181 bip52]: /zh/newsletters/2022/01/05/#bips-1126
[news392 bip110]: /zh/newsletters/2026/02/13/#bips-2017
[news409 testnet5]: /zh/newsletters/2026/06/12/#draft-bip-for-testnet5
[news409 privatebroadcast]: /zh/newsletters/2026/06/12/#bitcoin-core-35410
[sources]: /en/internal/sources/
