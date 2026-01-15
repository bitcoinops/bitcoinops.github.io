---
title: 'Bitcoin Optech Newsletter #386'
permalink: /zh/newsletters/2026/01/02/
name: 2026-01-02-newsletter-zh
slug: 2026-01-02-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周周报概述了一种采用盲化版 MuSig2 的类 vault（保管库）方案，并介绍了一项让比特币客户端能够就新的 P2P 特性宣布并协商是否支持的提案。此外还包括我们的常规部分：总结与共识变更相关的讨论、新版本和候选版本的公告，以及对热门比特币基础设施软件的重大变更总结。

## 新闻

- **<!--building-a-vault-using-blinded-co-signers-->使用盲化共同签名者构建保管库：** Johan T. Halseth
  在 Delving Bitcoin 上[发布][halseth post]了一个使用盲化共签者的类[保管库][topic vaults]方案的原型。不同于传统的共签设置，该方案使用 [MuSig2][topic musig] 的[盲化版本][blinded musig]，以确保签名者对其参与签名的资金了解尽可能少。为避免签名者不得不对提交给他们的内容“盲签”，该方案在签名请求中附带零知识证明，证明该交易满足预先设定的策略要求（此处为[时间锁][topic timelocks]）。

  Halseth 提供了一张方案流程图，展示了四笔将被预签名的交易：初始存入交易、恢复交易、出库（unvault）交易以及出库恢复交易。在进行出库（unvault）时，共签者将要求提供零知识证明，以证明其所签的交易已正确设置相对时间锁。这从而确保在发生未授权的出库（unvault）时，用户或瞭望塔仍有时间将资金扫走/转走。

  Halseth 还提供了一个可用于 regtest 和 signet 的[原型实现][halseth prototype]。

- **<!--peer-feature-negotiation-->对等节点特性协商：** Anthony Towns 在 Bitcoin-Dev 邮件列表上[发布][peer neg ml]了一项新 [BIP][towns bip] 的提案，计划定义一种 P2P 消息，让对等节点能够宣布并协商对新特性的支持。这个想法与 2020 年的[一个旧方案][feature negotiation ml]类似，并将惠及多种拟议中的 P2P 用例，包括 Towns 关于[模板共享][news366 template]的工作。

  历史上，P2P 协议的变更主要依赖上调版本号来表明对新特性的支持，从而确保对等节点只与兼容节点进行协商。然而，这种做法会在不同客户端实现之间引入不必要的协调成本，尤其是对那些并不需要全网普遍采用的特性而言。

  该 BIP 提议将 [BIP339][] 的机制进行泛化：在 [pre-verack][verack] 阶段引入一种单一、可复用的 P2P 消息，用于宣布并协商未来的 P2P 升级。这样可以降低协调成本，实现无需许可的可扩展性，防止网络分区，并最大化与不同客户端实现的兼容性。

## 共识变更

_在这个月度栏目，总结关于变更比特币共识规则的提案和讨论。_

- **<!--year-2106-timestamp-overflow-uint64-migration-->2106 年时间戳溢出：迁移到 uint64：** Asher Haim 在 Bitcoin-Dev 邮件列表上[发文][ah ml uint64 ts]，呼吁比特币开发者尽快采取行动，为区块时间戳从 uint32 迁移到 uint64 做准备。Haim 解释了为何需要尽早行动：可能会在比想象中更早的时间出现期限跨越 2106 年、并引用比特币的长期金融合约。这还不是一个以 BIP 形式提出的具体提案；围绕时间锁以及比特币生态的其他部分，仍有大量细节需要进一步敲定与完善。2024 年 1 月的 [BitBlend][bb 2024] 提案提供了一种可能的具体解决思路。

- **<!--relax-bip54-timestamp-restriction-for-2106-soft-fork-->为 2106 软分叉放宽 BIP54 的时间戳限制：** Josh Doman 在 Bitcoin-Dev [邮件列表][jd ml bip54 ts]和 [Delving Bitcoin][jd delving bip54 ts] 上发帖，询问是否值得修改[共识清理][topic consensus cleanup]提案，使其对异常的区块时间戳行为更宽容，从而为解决 2106 区块时间戳溢出问题保留软分叉方案的可能性。ZmnSCPxj 早在 2021 年就[提出过][zman ml ts2106]类似的想法。两个论坛的讨论都聚焦于：在有充分工程理由选择硬分叉的情况下，为了避免硬分叉而做出让步是否值得。Greg Maxwell [写道][gm delving bip54]，以这种方式放宽限制，可能会让 [BIP54][] 旨在修复的[时间扭曲][topic time warp]攻击重新变得可行；仅这一风险就可能足以成为不应放宽限制的理由。

- **<!--understanding-and-mitigating-a-ctv-footgun-->理解并缓解 CTV 的“脚枪”问题：** Chris Stewart 在 Delving Bitcoin 上[发帖][cs delving ctv]讨论了 [`OP_CHECKTEMPLATEVERIFY`（CTV）][topic op_checktemplateverify] 的一个“脚枪”（footgun）问题。具体来说，如果有人创建一个输出，支付到某个无条件要求特定单输入 CTV 哈希的 `scriptPubKey`，但该输出金额小于该 CTV 哈希所承诺的各输出金额总和，那么生成的这个输出将永久不可花费。他提出，CTV 用户可让其所有 CTV 哈希都承诺至少 2 个输入，以缓解这一风险。如此一来，总能构造出一个额外输入，从而使这类输出仍可被花费。

  Greg Sanders 回复指出了这种方法的一些局限性；1440000bytes 提到，这种问题只会出现在下一笔交易模板被无条件强制执行的情况下。Greg Maxwell 认为，这恰恰说明应避免整类“交易模板[限制条款][topic covenants]”类别的方案。Brandon Black 指出，在收款地址上使用 CTV 的确是一种风险较高的应用设计；将 CTV 与另一个操作码（如 [`OP_CHECKCONTRACTVERIFY`][topic matt]（[BIP443][]））结合，可能可以实现更安全的应用。

- **<!--ctv-activation-meeting-->CTV 激活会议：** 开发者 1440000bytes [主持][fd0 ml ctv]了一场 CTV（[BIP119][]）激活[会议][ctv notes1]。与会者一致认为，CTV 激活客户端应当使用保守参数（即更长的信号期与激活期），并采用 [BIP9][]。截至撰写本文时，邮件列表上的其他开发者尚未对此发表意见。

- **<!--op-checkconsolidation-to-enable-cheaper-consolidations-->用 `OP_CHECKCONSOLIDATION` 实现更低成本的归集：** billymcbip [提出][bmb delving cc]了一个专门为归集优化的操作码。`OP_CHECKCONSOLIDATION`（CC）当且仅当它在某个输入上执行、且该输入的 `scriptPubKey` 与同一笔交易中更早的某个输入的 `scriptPubKey` 相同，才会求值为 1。大量讨论围绕着这一要求展开：使用相同 `scriptPubKey` 会鼓励地址复用，从而损害隐私。Brandon Black 提议用 `OP_CHECKCONTRACTVERIFY`（[BIP443][]）实现类似功能（但在字节效率上不如 CC）。该提案与 Tadge Dryja 早先关于 `OP_CHECKINPUTVERIFY` 的[工作][news379 civ]相似，但在字节上显著更高效、泛化程度更低。

- **<!--hash-based-signatures-for-bitcoins-post-quantum-future-->面向比特币后量子未来的基于哈希的签名：** Mikhail Kudinov 和 Jonas Nick 在 Bitcoin-Dev 邮件列表上[发帖][mk ml hash]，介绍他们评估将基于哈希的签名用于比特币的工作。他们的研究发现，相较于当前标准化方案，签名大小存在显著的优化空间；但并未找到可替代 [BIP32][]、[BIP327][] 或 [FROST][news315 frost] 的可行方案。多位开发者参与讨论，围绕这项工作、其他[后量子签名][topic quantum resistance]机制以及比特币未来可能的发展路径展开交流。

  讨论中也涉及：比较新的签名验证机制时，更适合用“每字节 CPU 周期”还是“每签名 CPU 周期”作为衡量指标。如果新的签名验证仍受现有权重上限及相关乘数（multipliers）约束，从而限制支付吞吐量，那么按“每字节”比较似乎更贴切；而如果新签名会引入其自身的独立限制，使后量子比特币的支付吞吐量能更接近当前水平，那么按“每签名”比较可能更合适。

## 版本和候选版本

_热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。_

- [BTCPay Server 2.3.0][] 是这个热门自托管支付解决方案的一个新版本，它将“订阅（Subscriptions）”功能（参见[周报 #379][news379
  btcpay]）加入了用户界面和 API，改进了支付请求，并包含多项其他功能与错误修复。

## 重大的代码和文档变更

*本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals（BIPs）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Bitcoin Core #33657][] 引入了一个新的 REST 端点 `/rest/blockpart/<BLOCKHASH>.bin?offset=X&size=Y`，它会返回区块的某个字节范围。这让 Electrs 等外部索引器可以只抓取特定交易，而无需下载整个区块。

- [Bitcoin Core #32414][] 在重新索引期间新增了定期将 UTXO 缓存刷写到磁盘的机制，作为现有 IBD 期间刷写机制的补充。此前只会在到达链尖时刷写，因此如果在重新索引过程中崩溃、且设置了较大的 `dbcache`，可能会丢失大量进度。

- [Bitcoin Core #32545][] 用一种“生成森林（spanning-forest）线性化”算法替换了先前引入的族群线性化算法（参见[周报 #314][news314 cluster]），该新算法旨在更高效地处理更复杂的族群。对历史交易池数据的测试表明，新算法可以在几十微秒内线性化所有观察到的、最多 64 笔交易的族群。这是[族群交易池][topic cluster mempool]项目的一部分。

- [Bitcoin Core #33892][] 放宽了中继策略：允许机会性的“一父一子（1p1c）”[交易包中继][topic package relay]，即使父交易的费率低于最低中继费率、且父交易并非 [TRUC][topic v3 transaction relay]，只要该交易包的整体费率超过节点当前的最低中继费率，并且子交易没有其他费率低于最低值的祖先交易，就可以中继。此前为简化对交易池修剪的推理，这一能力被限制为仅对 TRUC 交易适用；但在有了[族群交易池][topic cluster mempool]之后，这已不再是顾虑。

- [Core Lightning #8784][] 为 `xpay` RPC 命令（参见[周报 #330][news330 xpay]）增加了 `payer_note` 字段，使付款方在请求发票时可以提供付款说明。`fetchinvoice` 命令已经有类似的 `payer_note` 字段，因此该 PR 将其加入到 `xpay`，并将该值一路传递到后续处理流程中。

- [LND #9489][] 与 [#10049][lnd #10049] 引入了一个实验性的 `switchrpc` gRPC 子系统，包含 `BuildOnion`、`SendOnion` 和 `TrackOnion` 等 RPC，使外部控制器能够负责寻路与支付生命周期管理，同时仍使用 LND 来转发 [HTLC][topic htlc]。该服务器端实现的编译被隐藏在非默认的 `switchrpc` 构建 tag 之后。[LND #10049][] 具体加入了外部尝试（attempt）跟踪所需的存储基础，为未来实现幂等版本打下基础。目前，为避免资金损失，一次只允许一个实体通过 switch 派发尝试才是安全的。

- [BIPs #2051][] 对 [BIP3][] 规范做出了多项修改：撤销了最近加入的反对使用 LLM 的指导（参见[周报 #378][news378
  bips2006]）、扩展了参考实现的格式、增加了变更日志，并做出其他若干改进与澄清。

- [BOLTs #1299][] 更新了 [BOLT3][] 规范，移除了一个含糊的说明：在支付给对手方的 `to_remote` 输出中使用基于 per-commitment point 的`localpubkey`。在 `option_static_remotekey` 选项下，这不再成立，因为 `to_remote` 输出预计要使用接收方的静态 `payment_basepoint`，以便在不依赖 per-commitment point 的情况下实现资金恢复。

- [BOLTs #1305][] 更新了 [BOLT11][] 规范，澄清 `n` 字段（收款方节点的 33 字节公钥）并非必填。这修正了先前一处将其描述为必填的表述。

{% include snippets/recap-ad.md when="2026-01-06 17:30" %}
{% include references.md %} {% include linkers/issues.md v=2 issues="33657,32414,32545,33892,8784,9489,10049,2051,1299,1305" %}
[news315 frost]: /zh/newsletters/2024/08/09/#proposed-bip-for-scriptless-threshold-signatures
[mk ml hash]: https://groups.google.com/g/bitcoindev/c/gOfL5ag_bDU/m/0YuwSQ29CgAJ
[fd0 ml ctv]: https://groups.google.com/d/msgid/bitcoindev/CALiT-Zr9JnLcohdUQRufM42OwROcOh76fA1xjtqUkY5%3Dotqfwg%40mail.gmail.com
[ctv notes1]: https://ctv-activation.github.io/meeting/18dec2025.html
[news379 civ]: /zh/newsletters/2025/11/07/#post-quantum-signature-aggregation
[bmb delving cc]: https://delvingbitcoin.org/t/op-cc-a-simple-introspection-opcode-to-enable-cheaper-consolidations/2177
[cs delving ctv]: https://delvingbitcoin.org/t/understanding-and-mitigating-a-op-ctv-footgun-the-unsatisfiable-utxo/1809
[bb 2024]: https://bitblend2106.github.io/bitcoin/BitBlend2106.pdf
[ah ml uint64 ts]: https://groups.google.com/g/bitcoindev/c/PHZEIRb04RY/m/ryatIL5RCwAJ
[jd ml bip54 ts]: https://groups.google.com/g/bitcoindev/c/L4Eu9bA5iBw/m/jo9RzS-HAQAJ
[jd delving bip54 ts]: https://delvingbitcoin.org/t/modifying-bip54-to-support-future-ntime-soft-fork/2163
[zman ml ts2106]: https://gnusha.org/pi/bitcoindev/eAo_By_Oe44ra6anVBlZg2UbfKfzhZ1b1vtaF0NuIjdJcB_niagHBS-SoU2qcLzjDj8Kuo67O_FnBSuIgskAi2_fCsLE6_d4SwWq9skHuQI=@protonmail.com/
[gm delving bip54]: https://delvingbitcoin.org/t/modifying-bip54-to-support-future-ntime-soft-fork/2163/6
[halseth post]: https://delvingbitcoin.org/t/building-a-vault-using-blinded-co-signers/2141
[halseth prototype]: https://github.com/halseth/blind-vault
[blinded musig]: https://github.com/halseth/ephemeral-signing-service/blob/main/doc/general.md
[peer neg ml]: https://groups.google.com/g/bitcoindev/c/DFXtbUdCNZE
[news366 template]: /zh/newsletters/2025/08/08/#peer-block-template-sharing-to-mitigate-problems-with-divergent-mempool-policies
[feature negotiation ml]: https://gnusha.org/pi/bitcoindev/CAFp6fsE=HPFUMFhyuZkroBO_QJ-dUWNJqCPg9=fMJ3Jqnu1hnw@mail.gmail.com/
[towns bip]: https://github.com/ajtowns/bips/blob/202512-p2p-feature/bip-peer-feature-negotiation.md
[verack]:https://developer.bitcoin.org/reference/p2p_networking.html#verack
[BTCPay Server 2.3.0]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.3.0
[news379 btcpay]: /zh/newsletters/2025/11/07/#btcpay-server-6922
[news314 cluster]: /zh/newsletters/2024/08/02/#bitcoin-core-30126
[news330 xpay]: /zh/newsletters/2024/11/22/#core-lightning-7799
[lnd #10049]: https://github.com/lightningnetwork/lnd/pull/10049
[news378 bips2006]: /zh/newsletters/2025/10/31/#bips-2006
