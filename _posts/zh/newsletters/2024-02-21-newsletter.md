---
title: 'Bitcoin Optech Newsletter #290'
permalink: /zh/newsletters/2024/02/21/
name: 2024-02-21-newsletter-zh
slug: 2024-02-21-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报描述了提供基于 DNS 的人类可读的比特币支付说明的提案，总结了一篇关于交易池激励兼容性想法的文章，链接到讨论 Cashu 和其他 ecash 系统设计的帖子，简要介绍了关于比特币脚本中 64 位算术的持续讨论（包括之前提出的操作码的规范），并概述了一个改进的可重复的 ASMap 的创建过程。此外还有我们的常规部分：描述客户端和服务的更新、新版本和候选版本的公告，以及对热门比特币基础设施项目的重大变更介绍。

## 新闻

- **<!--DNS-based-human-readable-Bitcoin-payment-->基于 DNS 的人类可读比特币支付指南：** 在之前的讨论之后(见[周报 #278][news278 dns])，Matt Corallo 向 Delving Bitcoin [发布了][corallo dns]一份[草案 BIP][dns bip]，该草案将允许像 `example@example.com` 这样的字符串解析为 DNS 地址，例如 `example.user._bitcoin-payment.example.com`，这将返回包含 [BIP21][] URI 的 [DNSSEC][]签名的 TXT 记录，例如 `bitcoin:bc1qexampleaddress0123456`。BIP21 URI 可以扩展以支持多种协议(见 [BIP70 支付协议][topic bip70 payment protocol])；例如，以下 TXT 记录可能指示一个 [bech32m][topic bech32] 地址以供简单的链上钱包备用，一个[静默支付][topic silent payments]地址供支持该协议的链上钱包使用，以及由 LN 启用的钱包使用的[要约][topic offers]：
  ```text
  bitcoin:bc1qexampleaddress0123456?sp=sp1qexampleaddressforsilentpayments0123456&b12=lno1qexampleblindedpathforanoffer...
  ```

  受支持的支付协议的具体细节并未在草案 BIP 中定义。Corallo 有另外两个草案，一份 [BOLT][dns bolt] 和一份 [BLIP][dns BLIP]，用于描述与闪电网络节点相关的细节。BOLT 允许域名所有者设置诸如 `*.user._bitcoin-payment.example.com` 这样的通配符记录，它将解析为包含 `omlookup` ([洋葱消息][topic onion messages]查找)参数和指向特定闪电网络节点的[盲化路径][topic rv routing]的 BIP21 URI。想要向 `example@example.com` 发出付款的人，将把接收方部分(`example`)传递给该闪电网络节点，以允许多用户节点正确处理付款。BLIP 描述了一种选项，允许任何 LN 节点通过闪电网络通信协议安全地解析任何其他节点的付款说明。

  在撰写本文时，有关该提案的大多数讨论都可以在 [BIP 库的 PR][bips #1551] 中找到。一个建议是使用 HTTPS 解决方案，该解决方案可能更容易被许多 Web 开发人员访问，但需要额外的依赖项；Corallo 说他不会改变规范的这一部分，但他确实写了一个[小型库][dnssec-prover]并带有一个[演示网站][dns demo]，这为 Web 开发人员完成了所有工作。另一个建议是使用现有的 [OpenAlias][] 基于DNS的支付地址解析系统，这已经受到一些比特币软件（如Electrum）的支持。第三个被广泛讨论的主题是地址应该如何显示，例如 `example@example.com`，`@example@example.com`，`example$example.com` 等。

- **<!--Thinking-about-mempool-incentive-compatibility-->思考交易池激励兼容性：** Suhas Daftuar 在 Delving Bitcoin 上[发布了][daftuar incentive]一些关于全节点可以使用哪些标准来选择接受哪些交易到他们的交易池、中继到其他节点以及最大化收益的见解。这篇文章从第一性原理出发，一直探讨到当前前沿研究，其描述通俗易懂，任何对 Bitcoin Core 交易中继规则设计感兴趣的人应该都能读懂。我们发现最有趣的一些见解包括：

  - *<!--pure-replace-by-feerate-doesn-t-guarantee-incentive-compatibility-->纯费率替换并不能保证激励兼容性：*
    似乎用支付较高费率的交易[替换][topic rbf]支付较低费率的交易对矿工来说应该是绝对有利的。Daftuar 却用一个[简单的例子][daftuar feerate rule]说明为什么情况并非总是如此。关于纯费率替换的之前讨论，见[周报 #288][news288 rbfr]。

  - *<!--miners-with-different-hashrates-have-different-priorities-->拥有不同算力的矿工有不同的优先级：* 如果拥有总网络算力的1％的矿工在挖掘下一个区块时不在其区块模板中包含某一笔交易，则仅有 1％ 的机会挖出再下一个区块来包含这笔交易。这强烈鼓励小型矿工尽可能多地收取费用，即使这意味着将大大减少了未来区块矿工（可能包括自己）可获取的手续费。

    相比之下，一个占总网络算力 25% 的矿工，如果放弃在下一区块中包含某个交易，那么他有 25% 的概率立即挖出后继区块来包含该笔交易。这个庞大的矿工会被激励去避免现在收取一些费用，如果这样做可能会显著地增加未来可获取的费用。

    Daftuar 给出了两笔冲突交易的[例子][daftuar incompatible]。较小的交易支付更高的费率，较大的交易支付更多绝对手续费。如果在交易中没有很多与较大交易的费率接近的交易，则包含该交易的区块将比包含较小（更高费率）交易的区块向矿工支付更多的费用。然而，如果交易池中有许多与较大交易具有相似费率的交易，网络总算力份额较小的矿工可能会被激励去挖出较小（更高费率）的版本以获取更多的手续费，但总算力份额较大的矿工可能会被激励等待直到挖出较大（更低费率）的版本时获利（或者直到支付者对等待感到厌倦并创建一个更高费率的版本）。不同矿工的不同激励可能意味着没有普遍适用的激励兼容策略。

  - *寻找无法抵御 DoS 攻击但具有激励兼容性的行为将是有用的：*
    Daftuar 描述了 Bitcoin Core 项目如何尝试[实施][mempool series]既激励兼容又抵抗拒绝服务（DoS）攻击的规则策略。但他指出，“一个有趣且有价值的研究领域将是确定是否存在无法抗拒 DoS 攻击的激励兼容行为可以部署到整个网络上（如果存在的话，并对其进行特性描述）。如果是这样，这种行为可能会激励用户直接连接到矿工，这对双方可能是互惠的，但对整体网络上的挖矿去中心化是有害的。[...]了解这些情况也可能有助于我们设计出既具有激励兼容性又能抵御DoS 攻击的协议，让我们知道在什么范围内是可能实现的。”

- **<!--Cashu-and-other-ecash-system-design-discussion-->Cashu 和其他 ecash 系统设计讨论：** 几周前，开发者 Thunderbiscuit 在 Delving Bitcoin 上[发布了][thunderbiscuit ecash]关于 [Chaumian ecash][]系统背后的[盲签名方案][blind signature scheme]的描述，该系统在 [Cashu][]中使用，以 satoshis 作为余额单位，允许使用比特币和 LN 进行货币发送和接收。开发者 Moonsettler 和 Zmnscpxj 本周的回复讨论了盲签名简化版本的一些限制，以及备选协议可能提供的额外好处。讨论完全是理论性的，但我们认为对于对 ecash 系统感兴趣的人来说可能会很有趣。

- **<!--Continued-discussion-about-64-bit-arithmetic-and-OP_INOUT_AMOUNT-opcode-->关于 64 位算术和 `OP_INOUT_AMOUNT` 操作码的持续讨论：**
  一些开发人员在[持续讨论][64bit discuss]可以向比特币添加 64 位算术运算 (见[周报 #285][news285 64bit])的未来可能软分叉。自我们之前提到以来，大多数讨论都集中在如何在脚本中编码 64 位值，主要区别在于是使用最小化链上数据的格式还是最简单的编程操作格式。还讨论了是使用有符号整数还是只允许无符号整数(给不了解这个话题的读者们解释一下，有符号整数包含了自身所用的_符号_(正号或负号)，无符号整数只允许表示零和正数；似乎一位自称为先进比特币创新者的人也需要这个解释呢)。此外，还考虑了是否允许对更大的数字进行操作，可能高达 4160 位 (这与当前比特币堆栈元素的大小限制 520 字节相匹配)。

  本周，Chris Stewart 为一个新的[讨论主题][stewart inout]创建了一个[BIP 草案][bip inout]，这是最初作为 `OP_TAPLEAF_UPDATE_VERIFY` 的一部分提出的一个操作码(见 [周报 #166][news166 tluv])。操作码 `OP_INOUT_AMOUNT` 将当前输入的值(即其正在花费的输出的值)和具有与此输入相同索引的交易中输出的值推送到堆栈上。例如，如果交易的第一个输入值为 4 百万 sats，第二个输入值为 3 百万 sats，第一个输出支付 2 百万 sats，第二个输出支付 1 百万 sats，那么作为求值第二个输入的一部分执行的 `OP_INOUT_AMOUNT` 会将 `3_000_000 1_000_000` (如果我们正确理解 BIP 草案，编码为一个 64 位小端无符号整数，例如 `0xc0c62d0000000000 0x40420f0000000000`)放入堆栈。如果将操作码添加到比特币中作为软分叉，那么合约将更容易验证输入和输出金额是否在合约预期范围内，例如，用户仅从 [joinpool][topic joinpools] 中提取了应得的金额。

- **<!--Improved-reproducible-ASMap-creation-process-->改进的可重复的 ASMap 创建过程：** Fabian Jahr 在 Delving Bitcoin 上[发布了][jahr asmap]关于在创建[自治系统][autonomous systems] (ASMap)方面进展的帖子，每个 ASMap 控制着互联网大部分区域的路由。Bitcoin Core 目前试图与来自全局命名空间各个子网的对等节点保持连接，以便攻击者需要获取每个子网的 IP 地址才能执行对节点的最简单类型的[日蚀攻击][topic eclipse attacks]。然而，一些 ISP 和托管服务商控制多个子网的 IP 地址，削弱了这种保护措施。ASMap 项目旨在向 Bitcoin Coin 提供关于哪些 ISP 直接控制哪些IP 地址的大致信息(见周报[#52][news52 asmap]和[#83][news83 asmap])。该项目面临的主要挑战是允许多个贡献者以可重复的方式创建地图，从而允许独立验证其内容在创建时是否准确。

    在本周的帖子中，Jahr 描述了他说的工具和技术，“发现在 5 人以上的小组中，大多数参与者会有相同的结果。[...]这个过程可以由任何人发起，与 Core 的 PR 非常相似。 具有匹配结果的参与者可以被解释为 ACKs。如果有人在结果中看到一些奇怪的东西，或者他们根本没有得到匹配，他们可以要求共享原始数据以进一步调查。”

    如果该过程最终被发现是可以接受的（也许有额外的改进），那么未来版本的 Bitcoin Core 可能会附带 ASMaps，并默认启用该功能，从而提高对日蚀攻击的抵抗力。

## 服务和客户端软件变更

*在这个月度栏目中，我们会标出比特币钱包和服务的有趣更新。*

- **多方协调协议 NWC 发布：**
  [Nostr 钱包连接（NWC）][nwc blog] 是一个协调协议，用于促进涉及多方的交互使用情况中的通信。虽然 NWC 最初的重点是闪电网络，但交互协议如 [joinpools][topic joinpools]，[Ark][topic ark]，[DLCs][topic dlc] 或者[多重签名][topic multisignature]方案最终也可能受益于该协议。

- **Mutiny 钱包 v0.5.7 发布：**
  [Mutiny 钱包][mutiny github] 新版本增加了对 [payjoin][topic payjoin] 的支持，并对 NWC 和 LSP 功能进行了改进。

- **GroupHug 交易批处理服务：**
  [GroupHug][grouphug github] 是一个使用 [PSBT][topic psbt]的[批处理][scaling payment batching]服务，但有一定的[限制][grouphug blog]。

- **Boltz 宣布了 taproot swap：**
  非托管交换交易所 Boltz [宣布了][boltz blog]升级其原子交换协议，以使用 [taproot][topic taproot]，[schnorr 签名][topic schnorr signatures] 和 [MuSig2][topic musig]。

## 版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Core Lightning 24.02rc1][] 是此热门的 LN 节点下一个主要版本的候选版本。

## 重大的代码和文档变更

_本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。_

- [Bitcoin Core #27877][] 使用新的[选币][topic coin selection]策略 CoinGrinder (见[周报 #283][news283 coingrinder])更新了 Bitcoin Core 的钱包。该策略旨在在预估费率高于其长期基准时使用，使得允许钱包现在创建小额交易(结果可能需要在以后创建更大的交易，希望那时候费率较低)。

- [BOLTs #851][] 在 LN 规范中增加了对[双向注资][topic dual funding]支持的功能，同时支持交互式交易构建协议。交互式构建允许两个节点交换偏好和 UTXO 详细信息，从而使它们能够共同构建一笔注资交易。双向注资允许一笔交易包含来自任意一方或双方的输入。例如，Alice 可能想要与 Bob 建立一个通道。在这个规范改变之前，Alice 必须为通道提供所有资金。现在，当使用支持双向注资的实现时，Alice 可以与 Bob 建立通道，他提供所有资金，或者他们各自向初始的通道状态注入资金。这可以与实验性的[流动性广告协议（liquidity ads）][topic liquidity advertisements]结合使用，该协议尚未包含在规范中。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1551,27877,851" %}
[news283 coingrinder]: /zh/newsletters/2024/01/03/#new-coin-selection-strategies
[news52 asmap]: /en/newsletters/2019/06/26/#differentiating-peers-based-on-asn-instead-of-address-prefix
[news83 asmap]: /en/newsletters/2020/02/05/#bitcoin-core-16702
[jahr asmap]: https://delvingbitcoin.org/t/asmap-creation-process/548
[autonomous systems]: https://en.wikipedia.org/wiki/Autonomous_system_(Internet)
[daftuar feerate rule]: https://delvingbitcoin.org/t/mempool-incentive-compatibility/553#feerate-rule-9
[news288 rbfr]: /zh/newsletters/2024/02/07/#proposal-for-replace-by-feerate-to-escape-pinning
[daftuar incompatible]: https://delvingbitcoin.org/t/mempool-incentive-compatibility/553#using-feerate-diagrams-as-an-rbf-policy-tool-13
[daftuar incentive]: https://delvingbitcoin.org/t/mempool-incentive-compatibility/553
[news285 64bit]: /zh/newsletters/2024/01/17/#proposal-for-64-bit-arithmetic-soft-fork-64
[dnssec]: https://en.wikipedia.org/wiki/Domain_Name_System_Security_Extensions
[corallo dns]: https://delvingbitcoin.org/t/human-readable-bitcoin-payment-instructions/542/
[dns bip]: https://github.com/TheBlueMatt/bips/blob/d46a29ff4b4ac27210bc81474ae18e4802141324/bip-XXXX.mediawiki
[dns bolt]: https://github.com/lightning/bolts/pull/1136
[dns blip]: https://github.com/lightning/blips/pull/32
[dnssec-prover]: https://github.com/TheBlueMatt/dnssec-prover
[dns demo]: http://http-dns-prover.as397444.net/
[news278 dns]: /zh/newsletters/2023/11/22/#offers-compatible-ln-addresses
[news166 tluv]: /en/newsletters/2021/09/15/#amount-introspection
[64bit discuss]: https://delvingbitcoin.org/t/64-bit-arithmetic-soft-fork/397
[stewart inout]: https://delvingbitcoin.org/t/op-inout-amount/549
[thunderbiscuit ecash]: https://delvingbitcoin.org/t/building-intuition-for-the-cashu-blind-signature-scheme/506
[blind signature scheme]: https://en.wikipedia.org/wiki/Blind_signature
[chaumian ecash]: https://en.wikipedia.org/wiki/Ecash
[openalias]: https://openalias.org/
[cashu]: https://github.com/cashubtc/nuts
[bip inout]: https://github.com/Christewart/bips/blob/92c108136a0400b3a2fd66ea6c291ec317ee4a01/bip-op-inout-amount.mediawiki
[mempool series]: /zh/blog/waiting-for-confirmation/
[Core Lightning 24.02rc1]: https://github.com/ElementsProject/lightning/releases/tag/v24.02rc1
[nwc blog]: https://blog.getalby.com/scaling-bitcoin-apps/
[mutiny github]: https://github.com/MutinyWallet/mutiny-web
[grouphug blog]: https://peachbitcoin.com/blog/group-hug/
[grouphug github]: https://github.com/Peach2Peach/groupHug
[boltz blog]: https://blog.boltz.exchange/p/introducing-taproot-swaps-putting
