---
title: 'Bitcoin Optech Newsletter #285'
permalink: /zh/newsletters/2024/01/17/
name: 2024-01-17-newsletter-zh
slug: 2024-01-17-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报披露了过去影响 Core Lightning 的一个漏洞，宣布了两个新的软分叉提案，概述族群交易池提案，转发了关于交易压缩的更新规范和实现的信息，并总结了关于非零临时锚点中矿工可提取价值（MEV）的讨论。此外，还包括我们的常规部分：新版本发布公告，以及介绍流行的比特币基础软件的显著变化。

## 新闻

- **披露以往 Core Lightning 中的漏洞：** Matt Morehouse 使用 Delving Bitcoin 宣布了他之前尽责披露的一个漏洞。该漏洞影响 Core Lightning 23.02 至 23.05.2 版本。最近的 23.08 及更高版本不受影响。

    新漏洞是 Morehouse 在跟进之前虚假注资工作时发现的，他也负责任地披露了这一工作（见[周报 #266][news266 lnbugs]）。在重新测试已实施虚假资金修复的节点时，他触发了一个[竞争条件][race condition]，导致 CLN 在大约 30 秒的时间内崩溃。如果闪电网络节点离线，它就无法抵御恶意或已损坏的交易对手，从而使用户的资金面临风险。分析表明，CLN 已经修复了最初的虚假注资漏洞，但在漏洞披露前无法安全地将其包含在测试中，导致随后合并的插件引入了可被利用的竞争条件。Morehouse 披露漏洞后，CLN 快速合并了一个补丁，以防止该竞争条件导致节点崩溃。

    如需了解更多信息，建议阅读 Morehouse [完整披露][morehouse full]的精彩博文。

- **提议新的 LNHANCE 组合软分叉：** Brandon Black 在 Delving Bitcoin 上[发布][black lnhance]了关于软分叉的详细信息，该软分叉结合了之前的 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV) 和 [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] (CSFS) 提议，以及一个新的 `OP_INTERNALKEY` 提议。该 `OP_INTERNALKEY` 提议将 [taproot 内部密钥][taproot internal key]放在堆栈上。脚本的作者必须知道内部密钥，才能向输出付款，因此他们可以直接在脚本中加入内部密钥。不过，`OP_INTERNALKEY` 是 CTV 的原作者 Jeremy Rubin [之前提议][rubin templating]的简化版本，通过允许从脚本解释器中检索密钥的值，可以节省几个 vbytes，并有可能使脚本更具可重用性。

    在该主题中，Black 和其他人描述了这种共识变化组合将启用的一些协议： [LN-Symmetry][topic eltoo]（eltoo）、[Ark][topic ark] 式的 [joinpool][topic joinpools]、缩减签名的 [DLC][topic dlc]、无预签交易的[保险柜][topic vaults]，以及隐含的提案所描述的其他优点，如 CTV 式拥塞控制和 CSFS 式的签名委托。

    截至本文撰写之时，技术讨论仅限于请求该组合提案将支持哪些协议。

- **<!--proposal-for-64-bit-arithmetic-soft-fork-->关于 64 位算术软分叉的提议：** Chris Stewart 在 Delving Bitcoin 上[发布][stewart 64]了一份 [BIP 草案][bip 64]，以在未来的软分叉中实现比特币的 64 位算术运算。比特币[目前][script wiki]只允许 32 位运算（使用有符号整数，因此不能使用超过 31 位的数）。在任何需要对输出中支付的聪的数量进行运算的结构中，支持 64 位值将特别有用，因为这是用 64 位整数指定的。例如，[joinpool][topic joinpools] 退出协议将受益于金额自省（参见第 [166][news166 tluv] 期和第 [283][news283 exits] 期周报）。

  截至本文撰写时，讨论主要集中在提案的细节上，例如如何对整数值进行编码、使用哪种 [taproot][topic taproot] 升级功能，以及创建一套新的算术 opcode 是否比升级现有的更可取。

- **<!--overview-of-cluster-mempool-proposal-->族群交易池提案概览：** Suhas Daftuar 在 Delving Bitcoin 上[发布][daftuar cluster]了一份关于[集群交易池][topic cluster mempool]提案的概览。Optech 在[第 280 期周报][news280 cluster]中尝试过总结族群交易池的讨论现状，但我们强烈建议阅读 Daftuar 的这份概述。他是该提案的设计者之一。有一个我们之前没有报道过的细节引起了我们的注意：

  - *CPFP carve out 需要移除：* [2019][news56 carveout] 年添加到 Bitcoin Core 的 CPFP [carve out][topic cpfp carve out] 交易池策略试图解决 CPFP 版本的[交易钉死攻击][topic transaction pinning]，即交易对手攻击者利用 Bitcoin Core 对相关交易数量和大小的限制，推迟对属于诚实对等节点的子交易进行处理。Carve out 允许一个交易略微超出这种限制。在族群交易池中，相关交易被放置在一个族群中，限制适用于每个族群，而不是每笔交易。在这种策略下，除非我们限制网络上中继的交易之间允许的关系远远超出当前的限制，否则没有已知的方法来确保一个族群最多只能包含一个 carve out。拥有多个 carve out 的族群可能会大大超出其限制，这时就需要针对这些更高的限制来设计协议。这将满足 carve out 用户的需求，但却限制了普通交易广播者的行为——这是不可取的。

    针对 carve out 交易和族群交易池之间的不兼容性提出的解决方案是 [v3 交易中继][topic v3 transaction relay]，这将允许 v1 和 v2 交易的普通用户继续以所有历史上的典型方式使用它们，但也允许闪电网络等合约协议的用户选择加入 v3 交易，强制执行一组受限的交易间关系（_拓扑_）。受限制的拓扑结构可减轻交易钉死攻击，并可与[临时锚点][topic ephemeral anchors]等近乎随时可用的 carve out 交易替代品相结合。

  重要的是，对 Bitcoin Core 的交易池管理算法进行重大修改时，要考虑到人们现在使用比特币的所有方式，或者在不久的将来可能的使用方式，我们鼓励开发挖矿软件、钱包或合约协议的开发者阅读 Daftuar 的描述，并就任何不清楚或可能对比特币软件如何与族群交易池互动产生不利影响的地方提出问题。

- **<!--updated-specification-and-implementation-of-bitcoin-transaction-compression-->比特币交易压缩的最新规范和实现：**
  Tom Briar 在 Bitcoin-Dev 邮件列表中[发布][briar compress]了压缩比特币交易的最新[规范草案][compress spec]和[建议实现][bitcoin core #28134]。较小的数据量对于交易通过带宽受限的媒介，如卫星或隐写术（如将交易编码在一个位图图像中）进行转发更为实用。有关我们对原始提案的描述，请参阅[第 267 期周报][news267 compress]。Briar 描述了显著的变化：“不再在 nLocktime 费工夫了，而使用所有压缩输入都会用到的相对区块高度，并使用了第二种变长整数”。

- **非零值的临时锚点中矿工可提取价值（MEV）的讨论：**
  Gregory Sanders 在 Delving Bitcoin 上[发帖][sanders mev]，讨论对包含超过 0 聪的[临时锚点][topic ephemeral anchors]输出的一些顾虑。一个临时锚点支付给一个任何人都可以花费的标准输出脚本。

  使用临时锚点的一种方法是让锚点的输出金额为零。这种方法是合理的，因为策略规则要求锚点输出必须有子交易支出。然而，在当前的闪电网络协议中，当一方想要创建一个[不经济][topic uneconomical outputs]的 HTLC 时，支付金额反而会被用来超量支付承诺交易的链上费用；这就是所谓的_修剪 HTLC_。如果 HTLC 修剪是在使用临时锚点的承诺交易中进行的，那么矿工只挖出承诺交易、而不挖出花费临时锚点输出的子交易，可能是有利可图的。一旦承诺交易得到确认，任何人都没有激励再去花费零金额的临时锚点输出，这意味着它将永远消耗全节点 UTXO 集的空间，这是一个不希望得到的结果。

  一个建议的替代方案是将修剪后的 HTLC 金额放入临时锚点输出的价值中。这样就可以激励来同时确认承诺交易和临时锚点输出的花费。Sanders 在他的文章中分析了这种可能性，发现这会产生几个安全问题。这些问题可以通过矿工分析交易、确定何时自己花费临时锚点输出更有利可图，并创建必要的交易来解决。这是一种[矿工可提取价值][news201 mev]（MEV）。此外，还有几种替代解决方案提出：

  - *<!--only-relaying-transactions-that-are-fully-miner-incentive-compatible-->只转发完全符合矿工激励机制的交易：*
    如果有人试图以不给矿工带来最大收益的方式花费临时锚点，那么这笔交易将不会被 Bitcoin Core 转发。

  - *<!--burn-trimmed-value-->燃烧修剪值：* 不再将修剪 HTLC 的金额转化为费用，而是将其花费到 `OP_RETURN` 输出中，使其永久不可花费，从而销毁这些聪。只有当包含修剪 HTLC 的承诺交易被置于链上时，才会发生这种情况；通常情况下，修剪 HTLC 会在链外解决，其价值会成功地从一方转移到另一方。

  - *<!--ensure-mev-transactions-propagate-easily-->确保 MEV 交易可以轻松传播：* 与其让矿工运行特殊代码使其价值最大化，不如确保使其价值最大化的交易在网络中轻松传播。这样，任何人都可以运行 MEV 代码，并将结果转发给矿工，从而确保所有矿工和中继节点都能获得同一组交易。

  在编写本报告时，尚未得出明确的结论。

## 新版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [LDK 0.0.119][] 是该库的新版本，用于构建支持闪电网络的应用程序。该版本添加了多个新功能，包括接收多跳[盲化路径][topic rv routing]付款，以及多个错误修复和其他改进。

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo] 和 [Bitcoin Inquisition][bitcoin inquisition repo]。*

- [Bitcoin Core #29058][] 是默认激活[第 2 版 P2P 传输（BIP324）][topic v2 p2p transport]的准备步骤。如果启用了 `-v2transport`，此补丁为 `-connect`、`-addnode` 和 `-seednode` 配置参数添加了 v2transport 支持。如果对等节点不支持 v2，则使用 v1 重新连接。 此外，此更新还在 `netinfo` 对等节点连接 `bitcoin-cli` 面板上添加了一列显示传输协议版本的内容。

- [Bitcoin Core #29200][] 允许 [I2P 网络支持][topic anonymity networks]使用 “ECIES-X25519 和 ElGamal（分别为 4 型和 0 型）加密连接。这允许连接到任一类型的 I2P 对等节点，首选其中更新、更快的 ECIES-X25519”。

- [Bitcoin Core #28890][] 删除了之前被废弃的 `-rpcserialversion` 配置参数（参见[周报 #269][news269 rpc]）。该选项是在向 v0 segwit 过渡期间引入的，目的是允许旧版程序继续以剥离格式（不含任何 segwit 字段）访问区块和交易。目前，所有程序都应更新以处理 segwit 交易，不再需要该选项。

- [Eclair #2808][] 更新了 `open` 命令，增加了一个 `--fundingFeeBudgetSatoshis` 参数，用于定义节点为打开通道而愿意支付的链上费用上限，默认设置为向通道支付的金额的 0.1% 。如果可能，Eclair 会尽量支付较低的费用，但必要时也会支付预算内的最高金额。`rbfopen` 命令也进行了更新，以接受相同的参数，该参数定义了 [RBF 费用提升][topic rbf]的最大金额。

- [LND #8188][] 添加了几个新的 RPC，用于快速获取调试信息，用公钥为其加密，并根据私钥进行解密。正如 PR 中解释的那样：“我们的想法是在 GitHub issue 模板中发布一个公钥，并要求用户运行 `lncli encryptdebugpackage` 命令，然后将加密的输出文件上传到 GitHub issue，为我们提供调试用户问题时通常需要的信息。”

- [LND #8096][] 添加了 “手续费峰值缓冲”。在当前的闪电网络协议中，通道注资方负责支付直接包含在承诺交易和预签的 HTLC-Success 和 HTLC-Timeout 交易（HTLC-X 交易）中的任何链上手续费。如果通道注资方资金不足并且费率上升，注资方可能会因为没有足够的资金支付手续费而无法接受新的付款——尽管如果付款结算，新的付款会增加注资方的余额。为避免此类通道注资问题，[BOLT2][]（几年前在 [BOLTs #740][] 中添加）中的一项建议提出，注资方应自愿保留额外的资金储备，以确保即使在费用增加的情况下也能收到额外的付款。LND 现在实施了这一解决方案，Core Lightning 和 Eclair 也实施了这一解决方案（见第 [85][news85 stuck] 期和第 [89][news89 stuck] 期周报）。

- [LND #8095][] 和 [#8142][lnd #8142] 代码库的部分内容添加了处理[盲化路径][topic rv routing]的附加逻辑。这是正在进行中的让 LND 全面支持盲化路径工作的一部分。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28134,29058,29200,28890,2808,8188,8096,8095,8142,740" %}
[morehouse delving]: https://delvingbitcoin.org/t/dos-disclosure-channel-open-race-in-cln/385
[morehouse blog]: https://morehouse.github.io/lightning/cln-channel-open-race/
[news266 dos]: /zh/newsletters/2023/08/30/#disclosure-of-past-ln-vulnerability-related-to-fake-funding
[script wiki]: https://en.bitcoin.it/wiki/Script#Arithmetic
[news166 tluv]: /en/newsletters/2021/09/15/#amount-introspection
[news283 exits]: /zh/newsletters/2024/01/03/#pool-exit-payment-batching-with-delegation-using-fraud-proofs
[daftuar cluster]: https://delvingbitcoin.org/t/an-overview-of-the-cluster-mempool-proposal/393/
[news280 cluster]: /zh/newsletters/2023/12/06/#cluster-mempool-discussion
[news267 compress]: /zh/newsletters/2023/09/06/#bitcoin-transaction-compression
[briar compress]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2024-January/022274.html
[compress spec]: https://github.com/bitcoin/bitcoin/blob/7e8511c1a8229736d58bd904595815636f410aa8/doc/compressed_transactions.md
[news201 mev]: /en/newsletters/2022/05/25/#miner-extractable-value-discussion
[news266 lnbugs]: /zh/newsletters/2023/08/30/#disclosure-of-past-ln-vulnerability-related-to-fake-funding
[race condition]: https://zh.wikipedia.org/wiki/%E7%AB%B6%E7%88%AD%E5%8D%B1%E5%AE%B3
[morehouse full]: https://morehouse.github.io/lightning/cln-channel-open-race/
[black lnhance]: https://delvingbitcoin.org/t/lnhance-bips-and-implementation/376/
[stewart 64]: https://delvingbitcoin.org/t/64-bit-arithmetic-soft-fork/397/
[daftuar cluster]: https://delvingbitcoin.org/t/an-overview-of-the-cluster-mempool-proposal/393/
[sanders mev]: https://delvingbitcoin.org/t/ephemeral-anchors-and-mev/383/
[bip 64]: https://github.com/bitcoin/bips/pull/1538
[taproot internal key]: /en/newsletters/2019/05/14/#complex-spending-with-taproot
[news56 carveout]: /en/newsletters/2019/07/24/#bitcoin-core-15681
[news269 rpc]: /zh/newsletters/2023/09/20/#bitcoin-core-28448
[news85 stuck]: /en/newsletters/2020/02/19/#c-lightning-3500
[news89 stuck]: /en/newsletters/2020/03/18/#eclair-1319
[ldk 0.0.119]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.119
[rubin templating]: https://freenode.irclog.whitequark.org/bitcoin-wizards/2019-05-24#24661606;
