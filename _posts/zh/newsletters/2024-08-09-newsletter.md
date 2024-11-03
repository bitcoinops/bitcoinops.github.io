---
title: 'Bitcoin Optech Newsletter #315'
permalink: /zh/newsletters/2024/08/09/
name: 2024-08-09-newsletter-zh
slug: 2024-08-09-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报公布了“Dark Skippy”快速种子外泄攻击，概述了对扣块攻击及其解决方案的讨论，分享了有关致密区块重建的统计数据，描述了针对带支付到锚点输出的交易的替换循环攻击，提到了一项规范 FROST 的门限签名的新的 BIP，并传达了一个改进 Elftrace 的公告，该改进允许其利用两个提议的软分叉对零知识证明进行适机验证。

## 新闻

- **<!--faster-seed-exfiltration-attack-->更快的种子外泄攻击**：Lloyd Fournier、Nick Farrow 和 Robin Linus 宣布了 [Dark Skippy][]，这是一种改进的从比特币签名设备中窃取密钥的方法，他们此前已经[负责任地披露][topic responsible disclosures]给大约 15 个不同的硬件签名设备供应商。_密钥外泄_ 是指交易签名代码故意制作出可以泄露关于底层密钥材料（例如私钥或 [BIP32 HD 钱包种子][topic bip32]）的信息的签名。一旦攻击者获取到用户的种子，他们可以随时窃取用户的任何资金（包括在导致外泄的交易中所花费的资金，如果攻击者迅速采取行动的话）。

  作者提到，他们所知道的先前最优的密钥外泄攻击需要几十个签名才能外泄一个 BIP32 种子。而通过 Dark Skippy，他们现在能够在两个签名中外泄一个种子，这两个签名都可能属于单个交易的两个输入，这意味着从用户首次尝试花费资金的那一刻起，他们的所有资金都可能处于危险之中。

  密钥外泄可由任何生成签名的逻辑使用，包括软件钱包——不过，通常预期的是，（如果有恶意）软件钱包将直接通过互联网将其种子传输给攻击者。外泄主要被认为是对没有直接连接到互联网的硬件签名设备的风险。一个逻辑被破坏的设备，无论是通过其固件还是硬件逻辑，现在都可以快速外泄种子，即使设备从未连接到计算机（例如，所有数据都是通过 NFC、SD 卡或 QR 码传输的）。

  实现[防外泄签名][topic exfiltration-resistant signing]的方法已经讨论过（包括在[周报 #87][news87 anti-exfil] 中），并且我们知道有两个硬件签名设备已经实现了这种方法（参见[周报#136][news136 anti-exfil]）。该部署方法确实需要与硬件签名设备进行一轮额外的通信。与标准单签名相比，这可能是一个缺点，尽管如果用户习惯于其他需要额外轮次通信的签名类型（例如[无脚本多签][topic multisignature]），这一缺点可能不那么明显。目前还已知有提供不同权衡的其他防外泄签名方法，尽管据我们所知，没有任何一种在比特币硬件签名设备中得到实现。

  Optech 建议任何使用硬件签名设备来保护大量资金的人要防止硬件或固件被破坏，无论是通过使用防外泄签名还是通过使用多个独立设备（例如带有脚本或无脚本多重签名或门限签名的设备）。

- **<!--block-withholding-attacks-and-potential-solutions-->扣块攻击及其可能的解决方案**：Anthony Towns 在 Bitcoin-Dev 邮件列表中[发布][towns withholding]了有关[扣块攻击][topic block withholding]、与此相关的 _无效份额_ 攻击及其可能的解决方案的讨论，其中包括禁用 [Stratum v2][topic pooled mining] 的客户端工作选择以及不经意份额。

  矿池矿工通过提交被称为 _份额_ 的工作单位以获得报酬，每个份额都是一个包含一定数量工作量证明（PoW）的 _候选区块_。预期这些份额中的一部分将包含足够的 PoW，使得其候选区块有资格被包含在最多工作量证明的区块链中。例如，如果份额 PoW 目标是有效区块 PoW 目标的 1/1000，矿池预期平均每生产一个有效区块支付 1000 份份额。经典的扣块攻击发生在矿池里的矿工不提交产生有效区块的 1/1000 份额，但提交了其他 999 份无效区块的份额。这使得矿工可以获得 99.9% 的工作报酬，但阻止矿池从该矿工处获得任何收入。

  Stratum v2 包含一个可选模式，矿池可以启用该模式以允许矿工在其候选区块中包含与矿池建议挖掘的不同的交易。矿池中的矿工甚至可以尝试挖矿池没有的交易。这可能会使矿池验证矿工的份额变得代价昂贵：每份份额可以包含多达数兆字节的矿池以前从未见过的交易，而且所有这些交易都可以设计为需要长时间来验证。这可能很容易挤爆矿池的基础设施，影响其接受诚实用户份额的能力。

  矿池可以通过仅验证份额 PoW、跳过交易验证来避免这个问题，但这使得矿池矿工 100% 的时间都可以通过提交无效份额来获得报酬，这比经典的扣块攻击的 99.9% 还要更差一些。

  这促使矿池要么禁止客户端交易选择，要么要求矿池矿工使用长期的公共身份（例如通过政府签发的文件验证的姓名），以便可以禁止不良行为者。

  Towns 提出的一个解决方案是矿池提供多个区块模板，允许每个矿工选择他们喜欢的模板。这类似于 [Ocean Pool][] 当前使用的系统。基于矿池创建模板提交的份额可以快速验证，并且所需带宽最小化。这可以防止支付 100% 的无效份额攻击，但无法帮助解决大约 99.9% 的扣块攻击。

  为了解决扣块攻击，Towns 修改了 Meni Rosenfeld 在 2011 年[首次提出][rosenfeld pool]的想法，描述了一种概念上简单的硬分叉，防止矿池矿工知道任何特定份额是否具有足够的 PoW 成为有效区块，从而使其成为 _不经意份额_。无法区分有效区块 PoW 和份额 PoW 的攻击者只能以攻击者自己丧失份额收入的同等比例来剥夺矿池的有效区块收入。这种方法有一些缺点：

  - *<!--spv-visible-hard-fork-->轻客户端可见的硬分叉*：所有硬分叉提案都要求所有全节点升级。然而，许多提案（例如简单的区块大小增加提案，如 [BIP103][]）不要求使用 _简化支付验证_（SPV）的轻客户端升级。该提案改变了区块头字段的解释方式，因此还需要所有轻客户端升级。Towns 确实提供了一个不一定需要轻客户端升级的替代方案，但这会显著降低其安全性。

  - *<!--requires-pool-miners-to-use-a-private-template-from-the-pool-->要求矿池矿工使用来自矿池的私有模板*：不仅需要模板来防止 100% 的无效份额攻击，矿池还需要在接收到使用该模板生成的所有份额之前将模板保密。矿池可以利用这一点诱骗矿工为他们反对的交易生成 PoW。然而，过期的模板可以发布以进行审计。大多数现代矿池每隔几秒钟生成一个新模板，因此可以在接近实时的情况下进行审计，防止恶意矿池对其矿工进行超过数秒以上的欺骗。

  Towns 最后描述了修复扣块攻击的两个动机：它对小型矿池的影响大于大型矿池，并且几乎不花任何成本就能攻击允许匿名矿工的矿池，而要求矿工进行身份验证的矿池可以禁止已知攻击者。修复扣块攻击有助于比特币挖矿变得更加匿名和去中心化。

- **<!--statistics-on-compact-block-reconstruction-->致密区块重建的统计数据**：开发者 0xB10C 在 Delving Bitcoin [发布][0xb10c compact]了关于 [致密区块][topic compact block relay] 重建的可靠性的帖子。自从该功能在 2016 年 Bitcoin Core 0.13.0 中添加以来，许多中继全节点一直在使用 [BIP152][] 致密区块中继。致密区块中继允许两个已经共享了一些未确认交易的节点在这些交易被包含在新区块中时，使用对这些交易的简短引用，而不是重新传输整个交易。这显著减少了带宽，也因此减少了延迟，使新块传播得更快。

  更快的区块传播减少了意外区块链分叉的数量。更少的分叉减少了对工作量证明（PoW）的浪费，并减少了有利于大型矿池而非小型矿池的 _区块竞争_ 数量，帮助比特币变得更加安全和去中心化。

  然而，有时新区块中包含节点以前未见过的交易。在这种情况下，接收致密区块的节点通常需要向发送节点请求这些交易，然后等待对方响应。这会减慢区块传播速度。在节点拥有区块中的所有交易之前，无法验证或中继该区块。这增加了意外区块链分叉的频率，降低了 PoW 安全性，并增加了中心化压力。

  因此，监控致密区块提供的所有信息是否足以立即验证新块而无需请求额外交易非常有用，这称为 _成功重建_。Gregory Maxwell 最近[报告][maxwell reconstruct]称，运行 Bitcoin Core 且使用默认设置的节点成功重建率有所下降，尤其是与启用了 `mempoolfullrbf` 配置设置的节点相比。

  本周，开发者 0xB10C 发布的帖子总结了他使用自己的节点并启用不同设置观察到的成功重建次数，其中一些数据可以追溯到大约六个月前。有关启用 `mempoolfullrbf` 的最新数据仅追溯到大约一周前，但与 Maxwell 的报告一致。这促使人们考虑[请求合并][bitcoin core #30493]将 `mempoolfullrbf` 作为 Bitcoin Core 未来版本的默认设置。

- **<!--replacement-cycle-attack-against-pay-to-anchor-->针对支付到锚点的替换循环攻击**：Peter Todd 在 Bitcoin-Dev 邮件列表中[发布][todd cycle]了有关支付到锚点 (P2A) 输出类型的帖子，该类型是[临时锚点][topic ephemeral anchors] 提案的一部分。P2A 是一种交易输出，任何人都可以花费。这在 [CPFP][topic cpfp] 手续费提升中非常有用——特别是在 LN 这样的多方协议中。然而，LN 中的 CPFP 手续费提升目前容易受到对手方执行的[替换循环攻击][topic replacement cycling] 的影响，恶意对手方执行一个两步过程。首先，他们使用对手方版本替换诚实用户版本的交易。然后，他们用与任何用户版本交易无关的交易替换该替换交易。当 LN 通道中有未完成的 [HTLCs][topic htlc] 时，成功的替换循环可能允许对手方从诚实方那里窃取资金。

  使用 LN 当前的[锚点输出][topic anchor outputs]通道类型，只有对手方可以执行替换循环攻击。然而，Todd 指出，由于 P2A 允许任何人花费输出，任何人都可以对使用它的交易执行替换循环攻击。不过，只有对手方可以从攻击中获得经济利益，因此第三方没有直接动机攻击 P2A 输出。在攻击者计划以高于诚实用户的 P2A 支出费率广播他们自己的交易并成功完成替换循环而没有中间状态被矿工确认的情况下，攻击可以是免费的。LN 节点中现有部署的针对替换循环攻击的缓解措施（参见[周报 #274][news274 cycle mitigate]）在防止 P2A 替换循环时同样有效。

- **<!--proposed-bip-for-scriptless-threshold-signatures-->****提议的脚本门限签名 BIP**：Sivaram Dhakshinamoorthy 在 Bitcoin-Dev 邮件列表中[发布][dhakshinamoorthy frost]了帖子，宣布提供了一项为比特币实现[无脚本门限签名][topic threshold signature]的[提议 BIP][frost sign bip]。这允许一组已经执行了设置程序的签名者（例如使用 [ChillDKG][news312 chilldkg]）安全地创建只需动态子集的签名。签名在链上无法区分是由单签用户还是无脚本多重签名用户创建的，从而提高了隐私和可替代性。

- **<!--optimistic-verification-of-zero-knowledge-proofs-using-cat-matt-and-elftrace-->****使用 CAT、MATT 和 Elftrace 对零知识证明进行乐观验证**：Johan T. Halseth 在 Delving Bitcoin [发布][halseth zkelf]了帖子，宣布他的工具 [Elftrace][] 现在可以验证零知识（ZK）证明。为了使此功能在链上可用，必须激活已提议的 [OP_CAT][topic op_cat] 和 [MATT][topic acc] 软分叉。

## Bitcoin Core PR 审核俱乐部

*在这个月度部分，我们总结了 [Bitcoin Core PR 审核俱乐部][Bitcoin Core PR Review Club]会议，重点介绍了一些重要的问题和答案。单击下面的问题以查看会议答案的总结。*


[添加 PayToAnchor(P2A)，OP_1 <0x4e73>，作为标准输出脚本花费][review club 30352] 是 [instagibbs](https://github.com/instagibbs) 提出的一个 PR，引入了一种新的 `TxoutType::ANCHOR` 输出脚本类型。锚点输出具有 `OP_1 <0x4e73>` 输出脚本（结果为 [`bc1pfeessrawgf`][mempool bc1pfeessrawgf] 地址）。使这些输出标准化有助于创建和中继从锚点输出花费的交易。

{% include functions/details-list.md
  q0="<!--before-txouttype-anchor-is-defined-in-this-pr-what-txouttype-would-a-scriptpubkey-op-1-0x4e73-be-classified-as-->在此 PR 定义 `TxoutType::ANCHOR` 之前，`scriptPubKey` `OP_1 <0x4e73>` 将被归类为哪种 `TxoutType`？"
  a0="因为它由一个 1 字节推送操作码（`OP_1`）和一个 2 字节数据推送（`0x4e73`）组成，它是一个有效的 v1 见证输出。因为它不是 32 字节，所以它不符合 `WITNESS_V1_TAPROOT` 的要求，因此默认为 `TxoutType::WITNESS_UNKNOWN`。"
  a0link="https://bitcoincore.reviews/30352#l-18"

  q1="<!--based-on-the-answer-to-the-previous-question-would-it-be-standard-to-create-this-output-type-what-about-to-spend-it-hint-how-do-isstandard-gh-isstandard-and-areinputsstandard-gh-areinputsstandard-treat-this-type-->基于前一个问题的答案，创建这种输出类型会是标准的吗？花费它呢？（提示：[`IsStandard`][gh isstandard] 和 [`AreInputsStandard`][gh areinputsstandard]如何处理这种类型？）"
  a1="因为 `IsStandard`（用于检查输出）只考虑 `TxoutType::NONSTANDARD` 为非标准的情况，因此创建它是标准的。因为 `AreInputsStandard` 认为花费来自 `TxoutType::WITNESS_UNKNOWN` 的交易为非标准，因此花费它不是标准的。"
  a1link="https://bitcoincore.reviews/30352#l-24"

  q2="<!--before-this-pr-with-default-settings-which-output-types-can-be-created-in-a-standard-transaction-is-that-the-same-as-the-script-types-that-can-be-spent-in-a-standard-transaction-->在此 PR 之前，默认设置下的标准交易中可以 _创建_ 哪些输出类型？这与可以在标准交易中 _花费_ 的脚本类型相同吗？"
  a2="所有定义的 `TxoutType` 除了 `TxoutType::NONSTANDARD` 之外都可以创建。所有定义的 `TxoutType` 除了 `TxoutType::NONSTANDARD` 和 `TxoutType::WITNESS_UNKNOWN` 之外都可以被花费（尽管 `TxoutType::NULL_DATA` 无法花费）。"
  a2link="https://bitcoincore.reviews/30352#l-42"

  q3="<!--define-anchor-output-without-mentioning-lightning-network-transactions-try-to-be-more-general-->在不提及闪电网络交易的情况下，（尽量尝试更通用地）定义 _锚点输出_。"
  a3="锚点输出是一个预签名交易中创建的额外输出，用于在广播时通过 CPFP 添加费用。有关更多信息，请参见[锚点输出主题][topic anchor outputs]。"
  a3link="https://bitcoincore.reviews/30352#l-48"

  q4="<!--why-does-the-size-of-the-output-script-of-an-anchor-output-matter-->为什么锚点输出的输出脚本大小很重要？"
  a4="大的输出脚本增加了中继和优先处理交易的成本。"
  a4link="https://bitcoincore.reviews/30352#l-66"

  q5="<!--how-many-virtual-bytes-are-needed-to-create-and-spend-a-p2a-output-->创建和花费一个 P2A 输出需要多少虚拟字节？"
  a5="创建 P2A 输出需要 13 个虚拟字节。花费它需要 41 个虚拟字节。"
  a5link="https://bitcoincore.reviews/30352#l-120"

  q6="<!--the-3rd-commit-adds-gh-30352-3rd-commit-if-prevscript-ispaytoanchor-return-false-to-iswitnessstandard-what-does-this-do-and-why-is-it-needed-->第 3 个提交里给 `IsWitnessStandard` [添加了][gh 30352 3rd commit] `if (prevScript.IsPayToAnchor()) return false`。这有什么作用，为什么需要它？"
  a6="它确保锚点输出只能在没有见证数据的情况下花费。这可以防止攻击者将诚实的花费交易添加见证数据，然后以更高的绝对费用但较低的费率传播它。这会迫使诚实用户支付越来越高的费用来替换它。"
  a6link="https://bitcoincore.reviews/30352#l-154"
%}

## 版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Libsecp256k1 0.5.1][] 是比特币相关加密函数库的一个小版本更新。它将签名的预计算表的默认大小更改为与 Bitcoin Core 的默认值一致，并添加了用于 ElligatorSwift 密钥交换的示例代码（该协议用于[版本 2 加密 P2P 传输][topic v2 p2p transport]）。

- [BDK 1.0.0-beta.1][] 是构建钱包和其他比特币应用程序的库的候选版本。原始的 `bdk` Rust crate 已更名为 `bdk_wallet`，底层模块已提取到各自的 crate 中，包括 `bdk_chain`、`bdk_electrum`、`bdk_esplora` 和 `bdk_bitcoind_rpc`。`bdk_wallet` crate “是第一个提供稳定的 1.0.0 API 的版本”。

## 重大的代码和文档变更

_本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。_

- [Bitcoin Core #30493][] 将[完全 RBF][topic rbf]设置为默认启用，同时允许节点操作员恢复到选择性 RBF。完全 RBF 允许替换任何未确认交易，无论是否用 [BIP125][bip125 github] 标记。自 2022 年 7 月以来， Bitcoin Core 就有此选项（参见周报 [#208][news208 fullrbf]），但之前默认禁用。关于将完全 RBF 设置为默认值的讨论，见周报 [#263][news263 fullrbf]。

- [Bitcoin Core #30285][] 项目添加了两个关键[族群线性化][wuille cluster]算法：`MergeLinearizations` 用于合并两个现有线性化，`PostLinearize` 通过额外处理来改进线性化。此 PR 建立在上周周报 [#314][news314 cluster] 中讨论的工作基础上。

- [Bitcoin Core #30352][] 引入了新的输出类型 Pay-To-Anchor (P2A)，并使其支出标准化。此输出类型无密钥（允许任何人花费），并且支持 [CPFP][topic cpfp] 费用提升的紧凑锚点，且抵抗 txid 熔融性（参见周报 [#277][news277 p2a]）。结合 [TRUC][topic v3 transaction relay] 交易，这推进了[临时锚点][topic ephemeral anchors]的实现，以替换基于 [CPFP carve-out][topic cpfp carve out]中继规则的 LN [锚点输出][topic anchor outputs]。

- [Bitcoin Core #29775][] 添加了 `testnet4` 配置项，将网络设置为 [testnet4][topic testnet]，如 [BIP94][] 中所规定。Testnet4 修复了 testnet3 的多个问题（参见周报 [#306][news306 testnet]）。现有的 Bitcoin Core `testnet` 配置选项使用 testnet3 仍可用，但预计将在后续版本中弃用并删除。

- [Core Lightning #7476][] 更新到了最新提议的 [BOLT12 规范](https://github.com/lightning/bolts/pull/798)，添加了在 [offer][topic offers] 和发票请求中拒绝零长度[盲化路径][topic rv routing]的功能。此外，它还允许盲化路径的 offer 缺失 `offer_issuer_id`。在这种情况下，签署发票所用的密钥将用作最终盲路径密钥，因为可以安全地假设 offer 发行者有此密钥。

- [Eclair #2884][] 实现了 [BLIP4][]，成为首个部分缓解网络上[通道拥塞攻击][topic channel jamming attacks]的 LN 实现。此 PR 启用了传入背书值的可选中继，中继节点自己基于入站对等方的声誉来决定是否应在将 [HTLC][topic htlc] 转发到下一跳时包含背书。如果网络广泛采用，背书的 HTLC 可能会优先获得稀缺的网络资源，如流动性和 HTLC 插槽。此实现建立在周报 [#257][news257 eclair] 中讨论的 Eclair 先前工作之上。

- [LND #8952][] 重构了 `lnwallet` 中的 `channel` 组件，以使用类型化的 `List`，这是实现动态承诺系列 PR 的一部分，一种[通道承诺升级][topic channel commitment upgrades]。

- [LND #8735][] 添加了使用 `-blind` 标志在 `addinvoice` 命令中生成具有[盲化路径][topic rv routing]的发票的功能。它还允许支付这些发票。请注意，这仅针对 [BOLT11][] 发票实现，因为 LND 尚未实现 [BOLT12][topic offers]。[LND #8764][] 扩展了先前的 PR，允许在支付发票时使用多个盲化路径，特别是在执行多路径支付 ([MPP][topic multipath payments])时。

- [BIPs #1601][] 合并了 [BIP94][]，引入 testnet4，这是一个新的 [testnet][topic testnet] 版本，包括旨在防止易于执行的网络攻击的共识规则改进。Testnet4 中从创世区块开始启用了之前所有的主网软分叉，并且默认使用的端口为 `48333`。有关 testnet4 如何修复导致 testnet3 行为问题的详细信息，请参见周报 [#306][news306 testnet4] 和 [#311][news311 testnet4]。

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30493,30285,30352,30562,7476,2884,8952,8735,8764,1601,29775" %}
[BDK 1.0.0-beta.1]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.1
[libsecp256k1 0.5.1]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.5.1
[news274 cycle mitigate]: /zh/newsletters/2023/10/25/#ln
[dark skippy]: https://darkskippy.com/
[news87 anti-exfil]: /en/newsletters/2020/03/04/#proposal-to-standardize-an-exfiltration-resistant-nonce-protocol
[news136 anti-exfil]: /en/newsletters/2021/02/17/#anti-exfiltration
[towns withholding]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Zp%2FGADXa8J146Qqn@erisian.com.au/
[0xb10c compact]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052
[maxwell reconstruct]: https://github.com/bitcoin/bitcoin/pull/30493#issuecomment-2260918779
[todd cycle]: https://mailing-list.bitcoindevs.xyz/bitcoindev/ZqyQtNEOZVgTRw2N@petertodd.org/
[dhakshinamoorthy frost]: https://mailing-list.bitcoindevs.xyz/bitcoindev/740e2584-5b6c-47f6-832e-76928bf613efn@googlegroups.com/
[frost sign bip]: https://github.com/siv2r/bip-frost-signing
[halseth zkelf]: https://delvingbitcoin.org/t/optimistic-zk-verification-using-matt/1050
[ocean pool]: https://ocean.xyz/blocktemplate
[rosenfeld pool]: https://bitcoil.co.il/pool_analysis.pdf
[elftrace]: https://github.com/halseth/elftrace
[news306 testnet]: /zh/newsletters/2024/06/07/#bip-and-experimental-implementation-of-testnet4
[news312 chilldkg]: /zh/newsletters/2024/07/19/#distributed-key-generation-protocol-for-frost
[bip125 github]: https://github.com/bitcoin/bips/blob/master/bip-0125.mediawiki
[news208 fullrbf]: /zh/newsletters/2022/07/13/#bitcoin-core-25353
[news263 fullrbf]: /zh/newsletters/2023/08/09/#full-rbf-by-default
[wuille cluster]: https://delvingbitcoin.org/t/introduction-to-cluster-linearization/1032
[news314 cluster]: /zh/newsletters/2024/08/02/#bitcoin-core-30126
[bolt12 spec]: https://github.com/lightning/bolts/pull/798
[news257 eclair]: /zh/newsletters/2023/06/28/#eclair-2701
[news306 testnet4]: /zh/newsletters/2024/06/07/#bip-and-experimental-implementation-of-testnet4
[news311 testnet4]: /zh/newsletters/2024/07/12/#bitcoin-core-pr-审核俱乐部
[news277 p2a]: /zh/newsletters/2023/11/15/#eliminating-malleability-from-ephemeral-anchor-spends
[review club 30352]: https://bitcoincore.reviews/30352
[gh instagibbs]: https://github.com/instagibbs
[mempool bc1pfeessrawgf]: https://mempool.space/address/bc1pfeessrawgf
[gh isstandard]: https://github.com/bitcoin/bitcoin/blob/fa0b5d68823b69f4861b002bbfac2fd36ed46356/src/policy/policy.cpp#L7
[gh areinputsstandard]: https://github.com/bitcoin/bitcoin/blob/fa0b5d68823b69f4861b002bbfac2fd36ed46356/src/policy/policy.cpp#L177
[gh 30352 3rd commit]: https://github.com/bitcoin-core-review-club/bitcoin/commit/ccad5a5728c8916f8cec09e838839775a6026293#diff-ea6d307faa4ec9dfa5abcf6858bc19603079f2b8e110e1d62da4df98f4bdb9c0R228-R232
