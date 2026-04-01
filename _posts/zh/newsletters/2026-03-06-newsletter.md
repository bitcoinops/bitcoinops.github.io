---
title: 'Bitcoin Optech Newsletter #395'
permalink: /zh/newsletters/2026/03/06/
name: 2026-03-06-newsletter-zh
slug: 2026-03-06-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报描述了一项跨不同 Ark 实现验证 VTXO 的标准，并链接到一份旨在扩展区块头 `nVersion` 字段中矿工可用 nonce 空间的 BIP 草案。此外还包括我们的常规栏目：关于共识变更的讨论、新版本和候选版本的公告，以及流行比特币基础设施软件的重大变更介绍。

## 新闻

- **<!--a-standard-for-stateless-vtxo-verification-->****无状态 VTXO 验证标准：** Jgmcalpine 在 Delving Bitcoin 上[发帖][vpack del]介绍了他的 V-PACK 提案，这是一项无状态的 [VTXO][topic ark] 验证标准，旨在提供一种在 Ark 生态系统中独立验证和可视化 VTXO 的机制。目标是开发一个能够在嵌入式环境（如硬件钱包）中运行的精简验证器，以便审计链下状态并维护单方面退出所需数据的独立备份。

  V-PACK 具体通过检查默克尔路径是否指向有效的链上锚点以及交易原像是否与签名匹配，来验证单方面退出路径的存在。然而，Second CEO Steven Roose 指出，路径排他性（即验证 Ark 服务提供商（ASP）未引入后门）未被检查，Jgmcalpine 回应说该议题将在路线图中被赋予最高优先级。

  由于 Ark 各实现之间存在显著差异（具体指 Arkade 和 Bark），V-PACK 提出了一种最小可行 VTXO（MVV）模式，允许将实现的"方言"转换为通用中立格式，而无需嵌入式环境导入特定实现的全部代码库。

  V-PACK 的实现 [libvpack-rs][vpack gh] 已开源，并提供了一个用于可视化 VTXO 的[在线工具][vpack tool]供测试使用。

- **<!--draft-bip-for-expanded-nversion-nonce-space-for-miners-->****扩展矿工 `nVersion` nonce 空间的 BIP 草案：** Matt Corallo 在 Bitcoin-Dev 邮件列表上[发帖][mailing list nversion]介绍了一份 BIP 草案，旨在将 `nVersion` 中矿工可用的 nonce 空间从 16 位增加到 24 位。这将为 “只知区块头的挖矿（header-only mining）” 提供更多可能的候选区块，而无需每秒多次滚动 `nTime`；该 BIP 也将取代 [BIP320][BIP 320]。

  该变更的动机是 BIP320 此前将 `nVersion` 的 16 位定义为额外的 nonce 空间，但事实证明，挖矿设备已经开始使用 `nTime` 中的 7 位作为额外的 nonce 空间。鉴于额外的 `nVersion` 位用于软分叉信号的实用性有限，该 BIP 草案建议将其中一些信号位改为扩展 `nVersion` 的额外 nonce 空间。

  其背后的理由是，为 ASIC 提供额外的 nonce 空间以便在无需控制器提供新工作的情况下滚动，可以简化 ASIC 设计；而且在 `nVersion` 中这样做优于在 `nTime` 中进行，因为后者可能会扭曲区块时间戳。

## 共识变更

_关于提议和讨论变更比特币共识规则的月度部分。_

- **<!--extensions-to-standard-tooling-for-templatehash-csfs-ik-support-->****在标准工具中支持 TEMPLATEHASH-CSFS-IK 的扩展：** Antoine Poinsot 在 Bitcoin-Dev 邮件列表上[撰文][ap ml thikcs]介绍了他将 [taproot 原生的 `OP_TEMPLATEHASH` 软分叉提案][news365 thikcs]集成到 [miniscript][topic miniscript] 和 [PSBT][topic psbt] 中的前期工作。

  新操作码需要重新审视 miniscript 的属性，因为它们打破了签名和交易承诺总是一起完成的假设。这项工作还凸显了 Script 栈结构的局限性，因为在与 miniscript 一起使用时，每个 `OP_CHECKSIGFROMSTACK` 之前都需要一个 `OP_SWAP`，除非对类型系统做进一步修改。由于 `OP_CHECKSIGFROMSTACK` 接受 3 个参数，且消息或密钥（甚至两者都）可能由其他脚本片段计算得出，因此在大多数情况下，都不存在明显更优的参数顺序能够避免 `OP_SWAP`。

  PSBT 所需的修改更为简单，主要是为每个输出添加一个字段，将 `OP_TEMPLATEHASH` 承诺映射到完整交易，以供签名者验证。

- **<!--hourglass-v2-update-->****Hourglass V2 更新：** Mike Casey 在 Bitcoin-Dev 邮件列表上[发帖][mk ml hourglass]更新了 [Hourglass 协议][bip draft hourglass2]，旨在减轻[量子][topic quantum resistance]攻击对某些已经弄丢的钱币的市场影响。该早期提案的讨论见[此处][hb ml hourglass]。该软分叉将限制单个区块最多只能花费 1 个 P2PK 锁定的输出、花费数额不能超过 1 BTC。这些具体数值虽有一定随意性，但对响应者而言似乎代表了此类限制的合理谢林点。支持该变更的响应者关注的是大量比特币被量子攻击者出售的潜在经济后果。反对者则认为，持有用于解锁比特币的私钥，是协议识别所有权的唯一方式，即使面对底层密码学安全性被突破的情况，协议也不应对币的所有权或移动施加额外限制。

- **<!--algorithm-agility-for-bitcoin-->****比特币的算法敏捷性：** Ethan Heilman 在 Bitcoin-Dev 邮件列表上[撰文][eh ml agility]讨论了比特币对 [RFC7696 密码学算法敏捷性][rfc7696]的潜在需求。Heilman 提议在 [BIP360][] P2MR 脚本中提供一种密码学算法，该算法不用于当前花费，而是作为备用方案，在当前基于 secp256k1 的签名算法（或之后的某个主要算法）变得不安全时，衔接不同的主要签名算法。核心思想是，如果比特币同时支持两种签名算法，那么未来任何一种被破解时的风险都不会像当前关于 secp256k1 潜在量子威胁的讨论那样严峻。

  其他开发者讨论了各种在 Heilman 设定的 75 年时间范围内不太可能被破解的潜在备用签名算法。

  还讨论了一个问题：是 BIP360 P2MR 更可取，还是更类似 [P2TR][topic taproot] 但可以选择在以后通过软分叉禁用密钥路径花费的方案更好。在 P2MR 中，所有花费都是脚本花费，从默克尔叶子中选择较低成本的主要签名机制或较高成本的备用方案。在 P2TR 变体中，主要签名类型是较低成本的密钥路径花费，直到因密码学被破解而被禁用，只有备用方案需要是默克尔叶子。Heilman 认为冷存储用户会偏好 P2MR，而热钱包可以根据需要快速切换到新的输出类型，这使得密钥路径花费加脚本备用签名算法对两种主要用户类型都没有吸引力。

- **<!--the-limitations-of-cryptographic-agility-in-bitcoin-->****比特币密码学敏捷性的局限：** Pieter Wuille 在 Bitcoin-Dev 邮件列表上[撰文][pw ml agility]讨论了前一条提到的密码学敏捷性的局限性。具体来说，由于比特币和所有货币一样建立在信念之上，如果比特币的所有权由多个密码学系统保障，每种方案的支持者都希望其方案被普遍采用，而且——更重要的是——不希望其他方案被使用，因为那会削弱所有权安全的基本不变量。Wuille 认为，从长远来看，旧的签名方案将需要作为从一种方案迁移到另一种方案的一部分而被禁用。

  Heilman [提出][eh ml agility2]，由于为算法敏捷性而提议的辅助签名方案比当前方案（以及未来的主要方案）成本高得多，它将保持备用状态，仅在主要方案被证明充分弱化时用于迁移，从而避免在每次迁移到新的主要方案后都需要禁用辅助方案。

  John Light 持与 Wuille [相反的观点][jl ml agility]，他认为，对比特币所有权模型的共同信念而言，禁用旧的签名方案（哪怕它不安全）所带来的威胁，比攻击者能够取走这些仍旧由不安全的方案保护的钱币还要大。本质上他认为，比特币所有权模型最重要的方面是每个锁定脚本从创建到花费期间的效力不可磨灭性。

  Conduition [反驳][c ml agility]了 Wuille 的前提条件，展示了（得益于 Script 的灵活性）用户可以要求来自多种签名方案的签名来解锁其币。这使用户能够表达比更广泛的安全假设，多于导致 Wuille 得出 “不安全方案需要被禁用” 和 “每种方案的用户都希望几乎没人使用其他方案” 结论的那些。

  讨论在一些澄清中继续，但对于比特币如何在实践中从一种密码系统迁移到另一种 —— 无论是为了应对量子攻击者还是其他原因 —— 尚未得出确定的结论。

## 版本发布和候选版本

_热门比特币基础设施项目的新版本发布和候选版本。请考虑升级到新版本或帮助测试候选版本。_

- [Bitcoin Core 28.4rc1][] 是前一个主要版本系列的维护版本的候选发布。主要包含钱包迁移修复和移除一个不可靠的 DNS 种子。

## 重大代码和文档变更

_以下是来自 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案 (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期重大变更。_

- [Bitcoin Core #33616][] 在区块重组期间、已确认的交易重新进入交易池时，跳过[临时粉尘][topic ephemeral anchors]花费检查（`CheckEphemeralSpends`）。此前，这些交易会因中继策略而被拒绝，因为它们是作为单独交易而非交易包重新进入交易池的。这延续了 [Bitcoin Core #33504][]（见[周报 #375][news375 truc]）的相同模式，后者出于同样原因在重组期间跳过了 [TRUC][topic v3 transaction relay] 拓扑检查。

- [Bitcoin Core #34616][] 为生成森林（spanning-forest）[族群线性化][topic cluster mempool]（SFL）算法（见[周报 #386][news386 sfl]）引入了更精确的成本模型，通过使用成本限制来约束搜索每个族群最优线性化所花费的 CPU 时间。先前的模型仅跟踪一种内部操作，导致报告的成本与实际花费的 CPU 时间之间相关性较差。新模型跟踪多种内部操作，权重根据不同硬件的基准测试校准，提供了更接近实际时间的近似值。

- [Eclair #3256][] 添加了一个新的 `ChannelFundingCreated` 事件，在注资或[拼接][topic splicing]交易被签名并准备好发布时触发。这对于单方注资的通道特别有用，因为非注资方没有机会事先验证输入，可能希望在通道确认前强制关闭。

- [Eclair #3258][] 添加了一个 `ValidateInteractiveTxPlugin` trait，使插件能够在签名前检查并拒绝远程对等节点在交互式交易中的输入和输出。这适用于[双向注资][topic dual funding]通道开启和[拼接][topic splicing]，在这些场景中双方都参与交易构建。

- [Eclair #3255][] 修复了 [Eclair #3250][]（见[周报 #394][news394 eclair3250]）中引入的自动通道类型选择，使其不再在公开通道中包含 `scid_alias`。根据 BOLTs 规范，`scid_alias` 仅允许用于[非公开通道][topic unannounced channels]。

- [LDK #4402][] 修复了 HTLC 认领计时器，使其使用实际的 HTLC CLTV 到期值而非洋葱载荷中的值。对于[蹦床][topic trampoline payments]支付中节点同时是蹦床跳板和最终接收方的情况，实际的 HTLC 到期值高于洋葱指定的值，因为外层蹦床路由添加了自己的 [CLTV 增量][topic cltv expiry delta]。使用洋葱值会导致节点设置比必要更紧的认领截止时间。

- [LND #10604][] 为 LND 的出站支付数据库添加了 SQL 后端（SQLite 或 Postgres），作为现有 bbolt 键值（KV）存储的替代方案。这个合并 PR 整合了多个子 PR，其中值得注意的有：[#10153][LND #10153] 引入了一个抽象的支付存储接口，[#9147][LND #9147] 实现了 SQL 模式和核心后端，[#10485][LND #10485] 添加了实验性的 KV 到 SQL 数据迁移。[周报 #169][news169 lnd-sql]记述 LND 添加了对 PostgreSQL 的支持；[周报 #237][news237 lnd-sql]记述 LND 添加了对 SQLite 的支持。

- [BIPs #1699][] 发布了 [BIP442][]，定义了 `OP_PAIRCOMMIT`，这是一个新的 [tapscript][topic tapscript] 操作码，从栈中弹出两个元素并推入它们的带标签 SHA256 哈希值。这提供了多对象承诺功能，类似于 [OP_CAT][topic op_cat] 所能实现的，但避免了启用递归型[限制条款][topic covenants]。`OP_PAIRCOMMIT` 是 [LNHANCE][news383 lnhance] 软分叉提案的一部分，与 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]（[BIP119][]）、[OP_CHECKSIGFROMSTACK][topic op_checksigfromstack]（[BIP348][]）和 OP_INTERNALKEY（[BIP349][]）一同组成 LNHANCE 。初始提案见[周报 #330][news330 paircommit]。

- [BIPs #2106][] 更新了 [BIP352][]（[静默支付][topic silent payments]），引入了每组接收方数量上限 `K_max` = 2323，以缓解由恶意交易制造的最坏情况下的扫描时间（见[周报 #392][news392 kmax]）。该限制为单笔交易中每个接收方组扫描器必须检查的输出数量设定了上限。该值最初提议为 1000，但后来增加到 2323，以匹配标准大小（100 kvB）交易中可容纳的最大 [P2TR][topic taproot] 输出数量，并规避对静默支付交易的指纹识别。

- [BIPs #2068][] 发布了 [BIP128][]，定义了一种标准的 JSON 格式用于存储时间锁恢复计划。恢复计划由两笔预签名交易组成，用于在所有者失去钱包访问权限时恢复资金：一笔警报交易将钱包的 UTXO 归集到单个地址，一笔恢复交易在 2–388 天的相对[时间锁][topic timelocks]后将这些资金转移到备用钱包。如果警报交易被过早广播，所有者可以直接从警报地址花费来使恢复交易无效。

- [BOLTs #1301][] 更新规范，建议为[锚点][topic anchor outputs]通道设置更高的 `dust_limit_satoshis`。使用 `option_anchors` 时，预签名的 HTLC 交易手续费为零，因此其成本不再计入粉尘计算。这意味着通过粉尘检查的 HTLC 输出在链上认领时可能仍然是[不经济的][topic uneconomical outputs]，因为花费它们需要第二阶段交易，其手续费可能超过这个输出的价值。规范现在建议节点设置的粉尘限制应考虑这些第二阶段交易的成本，并且节点应接受对等节点设置的高于 Bitcoin Core 标准粉尘阈值的值。

{% include snippets/recap-ad.md when="2026-03-10 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33616,33504,34616,3256,3258,3255,3250,4402,10604,10153,9147,10485,1699,2106,2068,1301" %}

[vpack del]: https://delvingbitcoin.org/t/stateless-vtxo-verification-decoupling-custody-from-implementation-specific-stacks/2267
[vpack gh]: https://github.com/jgmcalpine/libvpack-rs
[vpack tool]: https://www.vtxopack.org/
[ap ml thikcs]: https://groups.google.com/g/bitcoindev/c/xur01RZM_Zs
[news365 thikcs]: /zh/newsletters/2025/08/01/#taproot-native-op-templatehash-proposal
[mk ml hourglass]: https://groups.google.com/g/bitcoindev/c/0E1UyyQIUA0
[bip draft hourglass2]: https://github.com/cryptoquick/bips/blob/hourglass-v2/bip-hourglass-v2.mediawiki
[hb ml hourglass]: https://groups.google.com/g/bitcoindev/c/zmg3U117aNc
[eh ml agility]: https://groups.google.com/g/bitcoindev/c/7jkVS1K9WLo
[rfc7696]: https://datatracker.ietf.org/doc/html/rfc7696
[pw ml agility]: https://groups.google.com/g/bitcoindev/c/O6l3GUvyO7A
[eh ml agility2]: https://groups.google.com/g/bitcoindev/c/O6l3GUvyO7A/m/OXmZ-PnVAwAJ
[jl ml agility]: https://groups.google.com/g/bitcoindev/c/O6l3GUvyO7A/m/5GnsttP2AwAJ
[c ml agility]: https://groups.google.com/g/bitcoindev/c/O6l3GUvyO7A/m/5y9GkeXVBAAJ
[news375 truc]: /zh/newsletters/2025/10/10/#bitcoin-core-33504
[news386 sfl]: /zh/newsletters/2026/01/02/#bitcoin-core-32545
[news394 eclair3250]: /zh/newsletters/2026/02/27/#eclair-3250
[news169 lnd-sql]: /zh/newsletters/2021/10/06/#lnd-5366
[news237 lnd-sql]: /zh/newsletters/2023/02/08/#lnd-7252
[news330 paircommit]: /zh/newsletters/2024/11/22/#update-to-lnhance-proposal
[news383 lnhance]: /zh/newsletters/2025/12/05/#lnhance-soft-fork
[news392 kmax]: /zh/newsletters/2026/02/13/#proposal-to-limit-the-number-of-per-group-silent-payment-recipients
[Bitcoin Core 28.4rc1]: https://bitcoincore.org/bin/bitcoin-core-28.4/test.rc1/
[mailing list nversion]: https://groups.google.com/g/bitcoindev/c/fCfbi8hy-AE
[BIP 320]: https://github.com/bitcoin/bips/blob/master/bip-0320.mediawiki
