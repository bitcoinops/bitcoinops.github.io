---
title: 'Bitcoin Optech Newsletter #129: 2020 Year-in-Review Special'
permalink: /zh/newsletters/2020/12/23/
name: 2020-12-23-newsletter-zh
slug: 2020-12-23-newsletter-zh
type: newsletter
layout: newsletter
lang: zh

excerpt: >
  本期特别版 Optech Newsletter 总结了 2020 年间比特币领域的显著发展。
---
{{page.excerpt}} 这是我们对 [2018][2018 summary] 和 [2019][2019 summary] 总结的后续内容。

正如我们在之前的年度总结中所做的那样，我们必须为即将阅读的内容先致歉。有太多人为维护和改进比特币技术付出了努力，而我们不可能全部记录下来。他们的基础研究、代码审查、错误修复、测试编写、行政工作及其他不被注意的活动可能未被提及，但绝非不被认可。如果你在 2020 年为比特币做出了贡献，请接受我们最深切的感谢。

## 目录

* 一月
  * [DLC 规范、实现及应用](#dlc)
* 二月
  * [LN 大额通道](#large-channels)
  * [LN 双向资金和交互式资金](#dual-interactive-funding)
  * [LN 隐藏路径](#blinded-paths)
* 三月
  * [抗外泄签名](#exfiltration-resistance)
* 四月
  * [Payjoin](#payjoin)
  * [LN PTLCs 和其他基于密码学的改进](#ptlcs)
  * [BIP85 密钥链](#bip85)
  * [保险库](#vaults)
* 五月
  * [交易来源隐私](#transaction-origin-privacy)
  * [简洁原子互换](#succinct-atomic-swaps-sas)
  * [Coinswap 实现](#coinswap-implementation)
  * [致密区块过滤器](#compact-block-filters)
* 六月
  * [多输入 segwit 交易的超额支付攻击](#overpayment-attack-on-multi-input-segwit-transactions)
  * [LN 支付原子性攻击](#ln-payment-atomicity-attack)
  * [快速 LN 蚕食攻击](#fast-ln-eclipse-attacks)
  * [LN 手续费赎金攻击](#ln-fee-ransom)
  * [HTLC 挖矿激励](#concern-about-htlc-mining-incentives)
  * [库存超出内存的拒绝服务攻击](#inventory-out-of-memory-denial-of-service-attack-invdos)
  * [WabiSabi 协调的任意输出金额 coinjoin](#wabisabi)
* 七月
  * [WTXID 交易公告](#wtxid-announcements)
* 八月
  * [Signet 测试网](#signet)
  * [LN 锚定输出](#anchor-outputs)
* 九月
  * [更快的签名验证](#glv-endomorphism)
  * [专利联盟](#patent-alliance)
* 十月
  * [LN 拦截攻击](#jamming)
  * [LND 安全披露](#lnd-disclosures)
  * [通用签名消息](#generic-signmessage)
  * [MuSig2](#musig2)
  * [版本 2 的地址消息](#addrv2)
* 十一月
  * [闪电池的入通道市场](#lightning-pool)
* 十二月
  * [LN 报价](#ln-offers)
* 特色总结
    * [Taproot、Tapscript 和 Schnorr 签名](#taproot)
    * [流行基础设施项目的重要版本](#releases)
    * [Bitcoin Optech](#optech)

## 一月

{:#dlc}
一些开发者开始[研究][news81 dlc]使用[离散对数合约（DLC）][dlc spec]的[规范][dlc spec]，使其可以在不同软件之间使用。DLC 是一种合约协议，允许两个或多个参与者根据某一事件的结果交换资金，该事件的结果由预言机（或多个预言机）决定。在事件发生后，预言机会发布对事件结果的承诺，获胜方可以使用该承诺索取资金。预言机无需知道合约的条款（甚至无需知道合约的存在）。这种合约可以与许多其他比特币交易区分不开，或者可以在 LN 通道内执行。与其他已知的基于预言机的合约方法相比，DLC 更加私密和高效，而且可以说更安全，因为如果预言机提交了虚假的结果，将会生成明确的欺诈证据。截至年底，共有四种兼容的 DLC 实现，一个用于提供和接受基于 DLC 的点对点衍生品的[应用程序][crypto garage p2p deriv]，以及若干用户[报告][dlc election bet]在主网上使用 DLC 进行交易。

## 二月

{:#large-channels}
在 LN 的[首次公开演讲][dryja poon sf devs]五年后，一些早期的临时协议决定被重新审视。最直接的变化是 LN 规范在二月[更新][news86 bolts596]，允许用户选择不受 2016 年制定的[最大通道和支付金额限制][topic large channels]的约束。

{:#dual-interactive-funding}
另一个早期的决定是通过单一资助者开通所有通道以简化协议。这种方式降低了协议复杂性，但阻止通道资助者在花费自己的资金之前接收任何付款——这给商户加入 LN 带来了障碍。解决此问题的一个提议是双向资助通道，通道的创建者和其对方都向通道中投入一定资金。Lisa Neigut 开发了一个[双向资助协议][bolts #524]，但（正如预期）它很复杂。二月，她发起了一场[讨论][news83 interactive funding]，提出一种对现有单一资助者标准的渐进改进，允许以交互方式构建资助交易。与当前的情况不同，现在一方提出开通通道，另一方要么接受要么拒绝，两方节点可以交换关于各自偏好的信息，并协商开通一个双方都满意的通道。

{:#blinded-paths}
LN 经常讨论的实现集合路由的计划取得了新进展，这在[2018 年 LN 规范会议][rv routing]上被列为优先事项。一种实现等效隐私的新方法由 Bastien Teinturier 在二月[描述][news85 blinded paths]，基于他此前提出的隐私增强建议。这种新方法被称为*隐藏路径*，后来在 [C-Lightning][news92 cl3600] 中作为实验性功能实现。

## 三月

{:#exfiltration-resistance}
硬件钱包可能用来从用户那里窃取比特币的一种方法是通过其创建的交易签名泄露钱包私钥的信息。三月，[Stepan Snigirev][news87 exfiltration]、[Pieter Wuille][news88 exfiltration] 以及其他几位开发者讨论了针对比特币当前的 ECDSA 签名系统和提议的 [Schnorr 签名][topic schnorr signatures]系统解决该问题的可能方案。

<div markdown="1" class="callout" id="taproot">

### 2020 年总结<br>Taproot、Tapscript 和 Schnorr 签名

几乎整个 2020 年，每个月都与提议的 [Taproot][topic taproot] 软分叉 ([BIP341][]) 相关的开发取得了显著进展，同时也引入了对 [Schnorr 签名][topic schnorr signatures] ([BIP340][]) 和 [Tapscript][topic tapscript] ([BIP342][]) 的支持。这些改进将使单签名脚本、多签名脚本和复杂合约的用户能够使用相同的承诺形式，从而增强隐私性和比特币的可替代性。支付者将享受更低的费用，并能够以与单签名用户相同的效率、低费用和大的匿名集解决许多多签名脚本和复杂合约。Taproot 和 Schnorr 也为未来的潜在升级奠定了基础，这些升级可能进一步改善效率、隐私性和可替代性，例如签名聚合、[SIGHASH_ANYPREVOUT][topic sighash_anyprevout] 和[脚本语言变更][topic simplicity]。

本节将这些开发的总结集中到一个叙述中，希望比单独描述每个月的事件更易于理解。

{:#activation-mechanisms}
2020 年 1 月，关于软分叉激活机制的讨论开始，Matt Corallo [提议][news80 msfa]采用一种谨慎且耐心的方式来解决不同利益相关者之间的分歧。其他开发者专注于 [BIP8][] 提案，希望能够快速绕过 2016 和 2017 年 Segwit 激活因程序问题而延迟的类型。关于使用何种具体激活机制的讨论贯穿全年，讨论在[专用 IRC 频道][##taproot-activation]及其他地方进行，其中包括对机制设计的[开发者调查][news122 devsurvey]和对矿工的[支持调查][news125 miner survey]。

2 月，BIP340 规范中 Schnorr 签名用于派生公钥和签名的算法在全年内进行了多次更新。这些[更改][news87 bip340 update]主要是[小型优化][news111 uniform tiebreaker]，它们来自于在 [libsecp256k1][] 及其实验分支 [libsecp256k1-zkp][] 中[实现][news113 bip340 update]和[测试][news96 bip340 update]提案的[经验][news83 alt tiebreaker]。同样在 2 月，Lloyd Fournier [扩展了][news87 taproot generic group] Andrew Poelstra 针对 Taproot 的先前安全性证明。

3 月，Bitcoin Core 在未引入分叉的情况下[小心地更改了][news89 op_if]其共识代码，以移除在解析 `OP_IF` 和相关流程控制操作码中的效率问题。目前，这种效率问题尚未被利用导致问题，但 Taproot 提议的扩展功能可能使攻击者利用此问题创建需要大量计算验证的区块。

尽管公众对 Taproot 的关注主要集中在它对比特币共识规则的更改，但 Taproot 的积极贡献只有在钱包开发者能够安全使用时才能实现。4 月及全年内，[几次][news87 bip340 update1]对 BIP340 的更新[修改了][news87 bip340 update]关于[如何][news96 bip340 nonce update]生成公钥和签名随机数的[建议][news91 bip340 powerdiff]。这些更改可能仅对密码学家直接有趣，但比特币历史中有许多因钱包开发者未充分理解其实现的密码学协议而导致资金丢失的例子。希望 BIP340 中经验丰富的密码学家的建议能避免未来出现此类问题。

5 月，针对硬件钱包自动签署交易的安全隐患（即[所有权盲化攻击][news97 additional commitment]）的讨论重新开始。理想情况下，硬件钱包可以提供一种模式，自动签署能够增加钱包余额的交易，如 Maker Coinjoins 和 LN [拼接][topic splicing]。不幸的是，只有在明确知道哪些输入是自己的情况下才安全，否则攻击者可能诱使你签署一笔看似只有一个输入的交易，再诱使你签署另一版本交易，这两个交易中的输入实际上不同，最终组合这些输入生成一笔支付给攻击者的实际交易。提议通过 Taproot 增加一种额外的输入承诺方式，与 [PSBT][topic psbt] 提供的数据结合，确保硬件钱包在有足够数据识别所有输入时才生成有效签名。这一提案后来被[接受][news101 additional commitment]到 BIP341。

![通过伪造 Coinjoin 欺骗硬件钱包丢失资金的示例](/img/posts/2020-05-fake-coinjoin-trick-hardware-wallet.dot.png)

7 月，再次讨论了一个已知问题——[bech32 地址格式][topic bech32]在防止用户将资金发送到无法消费的地址方面效果不如预期。尽管这对当前 bech32 地址用户没有实质影响，但可能对计划中的 Taproot 地址产生问题，因为少量字符的添加或删除可能导致资金丢失。去年提议简单地将当前 Segwit v0 地址的保护扩展到 Segwit v1（Taproot）地址，但这会减少未来升级的灵活性。[今年][news107 bech32 fives]，在更多[研究][news127 bech32m research]和[辩论][news119 bech32 discussion]后，开发者似乎达成共识，即 Taproot 和未来基于 Segwit 的脚本升级应使用对原始 [BIP173][] bech32 地址的一个小调整的新地址格式。新格式将解决该缺陷并提供其他优点。

9 月，[BIP340][] 中 Schnorr 签名验证和单方签名功能的代码被[合并][news115 bip340 merge]到 libsecp256k1 并很快成为 Bitcoin Core 的一部分。这使得 10 月能够[合并][news120 taproot merge] Taproot、Schnorr 和 Tapscript 的验证代码。新代码包含约 700 行与共识相关的更改（不包括注释和空白为 500 行）以及 2,100 行测试。超过 30 人直接审查了该 PR 及相关更改，还有许多人参与了基础研究、BIPs、libsecp256k1 中的相关代码及系统其他部分的开发和审查。这些新软分叉规则目前仅用于 [Signet 测试网][topic signet]和 Bitcoin Core 的私有测试模式（“regtest”）；需要激活后才能在比特币主网上使用。

许多为 Taproot 做出贡献的开发者在接下来的一年中专注于 Bitcoin Core 0.21.0 的发布，意图让后续的小版本发布（可能是 0.21.1）包含可以在接收到适当的激活信号时开始执行 Taproot 规则的代码。

</div>

## 四月

{:#payjoin}
基于 2018 年 [Pay-to-EndPoint 提案][news8 p2ep]的 [Payjoin][topic payjoin] 协议在四月得到了重大推动，因为其一个版本被[添加][news94 btcpay payjoin]到 BTCPay 自托管支付处理系统中。Payjoin 为用户提供了一种方便的方式，通过创建交易来削弱[假设][common ownership heuristic]（即交易的所有输入由同一人拥有），从而提升自身隐私和网络中其他用户的隐私。BTCPay 的 Payjoin 版本随后被[规范化][news104 bips923]为 [BIP78][]，并被[其他程序][news116 payjoin joinmarket]添加支持。

{:#ptlcs}
LN 的一个广泛期望的改进是将支付安全机制从哈希时间锁定合约（[HTLC][topic htlc]）切换到点时间锁定合约（[PTLC][topic ptlc]），以增强对多种监控方法的隐私保护。然而，理想的多方 PTLC 构建在比特币现有的 [ECDSA 签名方案][ecdsa]中实施起来相当具有挑战性（尽管使用 [Schnorr 签名][topic schnorr signatures]会更容易）。年初，Lloyd Fournier 分发了一篇[论文][fournier otves]，通过将签名适配器的核心锁定和信息交换特性从其多方签名的用途中分离，描述了一种易于使用的基于比特币脚本的多签替代方案。在四月的一个黑客马拉松中，几位开发者[实现了][news92 ecdsa adaptor]这个协议在流行的 libsecp256k1 库的一个分支上的粗略实现。随后，在九月，Fournier 提出了一种[新方法][news113 witasym]来[构建][news119 witasym update] LN 承诺交易，进一步提高了无需等待比特币更改即可实现 PTLC 的实用性。十二月，他又提出了[两种新方法][news128 fancy static]来增强 LN 备份的鲁棒性，再次通过巧妙使用密码学为用户问题提供了实际解决方案。

{:#bip85}
四月，Ethan Kosakovsky 在 Bitcoin-Dev 邮件列表中[发布][news93 super keychain]了一项提议，使用一个 [BIP32][] 分层确定性（HD）密钥链来创建可用于不同场景的子 HD 密钥链的种子。这可能解决了许多钱包不支持导入扩展私钥（xprvs）的问题——它们仅允许导入 HD 种子或转化为种子的前置数据（如 [BIP39][] 或 SLIP39 种子词）。该提案允许用户通过一个超级密钥链的种子备份多个钱包。该提案后来被[采纳][news102 bip85]为 [BIP85][]，并在 ColdCard 硬件钱包的最近版本中实现。

{:#vaults}
四月，有关[保险库][topic vaults]的两个公告发布。保险库是一种[契约][topic covenants]，当有人试图花费契约的资金时会发出警告，给予契约所有者阻止未经授权支出的时间。Bryan Bishop 公布了一个基于他去年[提议][news59 bishop idea]的[保险库原型][news94 bishop vault]。Kevin Loaec 和 Antoine Poinsot 宣布了他们自己的项目 [Revault][news95 revault]，该项目[专注于][news100 revault arch]使用保险库模型存储多用户共享资金，并采用多签安全性。Jeremy Rubin 还宣布了一种用于构建有状态智能合约的[新高级编程语言][news109 sapio]，其基于提议的 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] 操作码，这可以使保险库的创建和管理变得更加容易。

## 五月

{:#transaction-origin-privacy}
比特币核心项目在五月及随后几个月合并了多个 PR，改进了[交易来源隐私][tx origin wiki]，不仅对比特币核心钱包用户有益，也惠及其他系统的用户。[Bitcoin Core #18038][] 开始[跟踪][news96 bcc18038]至少一个对等节点是否接受了本地生成的交易，从而大幅减少比特币核心重新广播其自身交易的频率，使得监控节点更难确定交易的来源节点。PRs [#18861][Bitcoin Core #18861] 和 [#19109][Bitcoin Core #19109] 能够通过仅对被通知过交易的对等节点的请求进行[回复][news107 bcc19109]，[阻止某种主动扫描][news99 bcc18861]，进一步减少第三方确定交易来源节点的能力。PRs [#14582][Bitcoin Core #14582] 和 [#19743][Bitcoin Core #19743] 使钱包能够[自动尝试][news112 bcc14582]在不增加费用的情况下消除[地址重用][topic output linking]的关联（或者允许用户指定为消除这些关联愿意支付的最大额外费用）。

五月底和六月初，Coinswap 的两个重要发展引起了关注。Coinswap 是一种无需信任的协议，它允许两个或多个用户创建看似普通支付的交易，但实际上交换了彼此的币。这不仅提高了 Coinswap 用户的隐私，也增强了所有比特币用户的隐私，因为任何看似支付的操作都可能是 Coinswap。

- **<!--succinct-atomic-swaps-sas-->****简洁原子互换 (SAS)：** Ruben Somsen 撰写了一篇文章并制作了一个视频，描述了一种[使用仅两笔交易的互换流程][news98 sas]的无需信任协议。相比早期的 Coinswap 设计，该协议有多个优势：需要更少的区块空间，节省交易费用，只需要在跨链互换的一个链上强制使用时间锁定，不依赖任何新的安全假设或比特币共识更改。如果采用 Taproot，互换可以变得更私密且高效。

- **<!--coinswap-implementation-->****Coinswap 实现：** Chris Belcher [发布][belcher coinswap1]了一个全面 Coinswap 实现的设计。他的[初步帖子][coinswap design]包括 Coinswap 概念的历史，建议如何将 Coinswap 所需的多签条件伪装成更常见的交易类型，提出使用流动性市场（类似于 JoinMarket 已采用的模式），描述了减少因金额关联或监控参与者而造成的隐私损失的拆分和路由技术，建议将 Coinswap 与 [Payjoin][topic payjoin] 结合，以及讨论了系统的部分后端需求。此外，他将 Coinswap 与其他隐私技术（如 LN、[Coinjoin][topic coinjoin]、Payjoin 和 Payswap）进行了比较。该提案获得了[大量][belcher coinswap2]的[专家讨论][belcher coinswap3]，并整合了一些建议到协议中。截至十二月，Belcher 的原型软件已经在测试网[创建了 Coinswap][belcher dec8 tweet]，展示了其强大的不可关联性。

{:#compact-block-filters}
从比特币早期开始，开发具有 SPV 安全性的轻量级客户端的挑战之一是找到一种方法，使客户端能够下载影响其钱包的交易，而不会让提供交易的第三方服务器追踪钱包的接收和支出历史。[BIP37][]-样式的[布隆过滤器][topic transaction bloom filtering]是最初的尝试，但钱包使用它们的方式最终仅提供了[极小的隐私保护][nick filter privacy]，并对服务它们的全节点构成了[拒绝服务风险][bitcoin core #16152]。2016 年 5 月，一位匿名开发者在 Bitcoin-Dev 邮件列表中提出了使用[每个区块单个布隆过滤器][bfd post]的替代方案。这一想法很快被[完善][maxwell gcs]、[实现][neutrino]并[规范化][bip157 spec discussion]，形成了 [BIP157][] 和 [BIP158][] 关于[致密区块过滤器][topic compact block filters]的规范。这可以显著改善轻量级客户端的隐私，尽管与当前流行的方法相比，它确实增加了它们的带宽、CPU 和内存需求。对于全节点来说，其拒绝服务风险降低到简单的带宽耗尽攻击，这些节点可以通过带宽节流选项来应对。尽管该协议的服务器端在 2018 年已被[btcd][btcd #1180] 合并并在同时期为 Bitcoin Core 提出，2020 年它的 P2P 部分逐步被[合并][news98 bcc18877]到 Bitcoin Core 中，[从五月][news100 bcc19010]到[八月][news111 bcc19070]完成，最终实现了通过仅启用两个配置选项，节点操作员即可选择创建和提供致密区块过滤器的功能。

<div markdown="1" class="callout" id="releases">

### 2020 年总结<br>流行基础设施项目的主要版本发布

- [LND 0.9.0-beta][] 于 1 月发布，改进了访问控制列表机制（“macaroons”），新增了接收[多路径支付][topic multipath payments]的支持，增加了通过加密洋葱消息发送附加数据的功能，并允许请求通道关闭时输出支付到指定地址（例如硬件钱包）。

- [LND 0.10.0-beta][] 于 5 月发布，新增了发送多路径支付的支持，允许通过 [PSBTs][topic psbt] 使用外部钱包为通道提供资金，并开始支持创建超过 0.043 BTC 的[大额发票][topic large channels]。

- [Eclair 0.4][] 于 5 月发布，与最新版本的 Bitcoin Core 兼容，并停止支持 Eclair Node GUI（建议用户改用 Phoenix 或 Eclair Mobile）。

- [Bitcoin Core 0.20.0][] 于 6 月发布，默认将 RPC 用户地址设置为 bech32 格式，允许为不同用户和应用程序配置 RPC 权限，并在 GUI 中新增了一些生成 PSBT 的基础支持。

- [C-Lightning 0.9.0][] 于 8 月发布，更新了 `pay` 命令，并新增了一个通过 LN 发送消息的 RPC。

- [LND 0.11.0-beta][] 于 8 月发布，允许接收[大额通道][topic large channels]。

</div>

## 六月

六月是漏洞发现和讨论的特别活跃月份，尽管许多问题更早被发现或在之后才完全披露。其中包括以下显著漏洞：

- **<!--overpayment-attack-on-multi-input-segwit-transactions-->**[多输入 segwit 交易的超额支付攻击：][attack overpay segwit] 6 月，Trezor 宣布 Saleem Rashid 发现了 segwit 在防止手续费超额支付攻击方面的弱点。手续费超额支付攻击是比特币原始交易格式中的一个已知问题，其中签名未对输入的金额作出承诺，从而使攻击者可以欺骗专用签名设备（如硬件钱包）花费比预期更多的钱。Segwit 尝试通过让每个签名承诺其所使用的输入金额来消除这一问题。然而，Rashid 重新发现了一个由 Gregory Sanders 在 2017 年首次报告的问题，即至少两个输入的特殊构造交易可以绕过该限制，只要用户可以被诱骗签署两个或更多看似相同的交易版本。尽管一些开发者认为这是个小问题，但一些硬件钱包制造商仍发布了新固件，通过对 segwit 交易使用与防止传统交易超额支付相同的保护措施来修复这一问题。

  ![手续费超额支付攻击示意图](/img/posts/2020-06-fee-overpayment-attack.dot.png)

- **<!--ln-payment-atomicity-attack-->**[LN 支付原子性攻击：][attack ln atomicity] LN 开发者在实施[锚定输出][topic anchor outputs]协议时发现了一个新漏洞：恶意对手方可以通过低费用率和[交易固定][topic transaction pinning]技术延迟交易或其费用提升交易的确认，导致 HTLC 的超时到期，使攻击者能够追回支付给诚实对手方的资金。尽管提出了多个解决方案（包括对 LN 协议的更改、第三方市场以及[软分叉共识更改][rubin fee sponsorship]），但尚未有解决方案获得显著进展。

- **<!--fast-ln-eclipse-attacks-->**[快速 LN 蚕食攻击：][attack time dilation] Gleb Naumenko 和 Antoine Riard 在 6 月发表了一篇论文，显示蚕食攻击可以在短至两小时内从 LN 节点窃取资金。作者建议实现更多方法以避免蚕食攻击，今年 Bitcoin Core 项目在这方面取得了积极进展。

- **<!--ln-fee-ransom-->**[LN 手续费赎金攻击：][attack ln fee ransom] René Pickhardt 向 Lightning-Dev 邮件列表公开披露了一个漏洞：恶意通道对手方可以发起最多 483 笔 HTLC 支付，然后关闭通道，产生一个占整个区块约 2% 的链上交易，手续费需要由诚实节点支付。多个 LN 节点已实施简单的缓解措施，[锚定输出][topic anchor outputs]的使用也被认为有助于缓解问题，但尚未提出全面解决方案。

- **<!--concern-about-htlc-mining-incentives-->**[关于 HTLC 挖矿激励的担忧：][attack htlc incentives] 两篇关于 HTLC 线下贿赂的论文在 6 月底和 7 月初被讨论。HTLC 是 LN 支付、跨链原子互换及其他无需信任的交换协议中使用的合约。这些论文探讨了支付用户可能通过贿赂矿工来获取秘密数据而不确认交易的问题，尽管理论上有已知的缓解方法，但实际使用需要支付额外费用，因此仍需继续研究更好的解决方案。

- **<!--inventory-out-of-memory-denial-of-service-attack-invdos-->**[库存内存耗尽拒绝服务攻击（InvDoS）：][attack invdos] 这一攻击最初于 2018 年被发现，影响了 Bcoin 和 Bitcoin Core 节点，当时已被负责任披露并修复。然而，2020 年 6 月发现该攻击同样适用于 Btcd 节点。攻击者通过发送包含几乎最大允许交易哈希数的新交易公告（`inv` 消息）泛洪受害者节点，导致节点内存耗尽并崩溃。Btcd 修复了该问题并为用户提供了升级时间，之后漏洞被公开披露。

{:#wabisabi}
6 月也有一些好消息，Wasabi coinjoin 实现的研究团队[宣布][news102 wasabi]了一种名为 WabiSabi 的协议，该协议应能实现无需信任的服务器协调 coinjoin，且支持任意输出金额。这使得使用协调的 coinjoin 发送支付变得更容易，无论是参与者之间还是向非参与者支付。Wasabi 开发者在接下来的一年中持续致力于该协议的实现。

## 七月

{:#wtxid-announcements}
7 月，[BIP339][] 规范的 wtxid 交易公告被[合并][bips933]。历史上，节点通过基于交易哈希的标识符（txid）宣布新未确认交易的可用性，用于中继，但在 2016 年审查提议的 segwit 代码时，Peter Todd [发现][todd segwit review]，恶意节点可以通过使交易的见证数据无效来让网络上的其他节点忽略无辜用户的交易，而见证数据并不是 txid 的一部分。当时，一个[快速修复][Bitcoin Core #8312]被实施，但存在一些小问题。开发者意识到，尽管有一定[复杂性][bcc19569]，最佳解决方案是使用其见证 txid（wtxid）来宣布新交易。BIP339 被添加到 BIPs 仓库后的一个月内，wtxid 公告被[合并][bcc18044]到 Bitcoin Core 中。虽然对用户似乎影响不大，但 wtxid 公告简化了未来升级的开发，例如[包中继][topic package relay]。

## 八月

{:#signet}
经过[一年多][bips900][bips983][default signet discussion]的开发，包括多次基于反馈的修改，[BIP325][] 规范的 [signet][topic signet] 的[最后一次重大修订][bips947]在 8 月初被合并。Signet 是一种允许开发者创建公共测试网络的协议，同时也是主要公共 signet 的名称。与现有的公共测试网络（testnet）不同，signet 区块必须由受信任方签名。这避免了因测试网络使用比特币的经济驱动共识机制（工作量证明）而导致的破坏和其他问题，因为测试网币没有价值。启用 signet 的能力最终在 9 月被[添加][bcc18267]到 Bitcoin Core 中。

{:#anchor-outputs}
在 Matt Corallo [首次提出][news24 cpfp carve out] [CPFP carve-out 机制][topic cpfp carve out]近两年后，LN 规范被[更新][news112 bolts688]以允许创建使用 carve-out 提升安全性的[锚定输出][topic anchor outputs]。锚定输出允许多方交易即使在一方尝试使用[交易固定][topic transaction pinning]攻击阻止费用提升时也能进行费用提升。在对抗条件下能够提升费用的能力，使 LN 节点可以在不担心未来费用率上升的情况下接受链下交易。如果后来需要广播该链下交易，节点可以在广播时选择适当的费用率。这简化了 LN 协议并提高了其多个方面的安全性。

<div markdown="1" class="callout" id="optech">

### 2020 年总结<br>Bitcoin Optech

在 Optech 成立的第三年，新增了 10 家成员公司<!-- Veriphi, SwanBitcoin, YellowCardIO, Xbtogroup, Bitonic, Fidelity Center for Applied Technology, AndgoInc, BTSEcom, EdgeWallet, Bitbank_inc -->，我们在伦敦举办了一场 [Taproot 工作坊][taproot workshop]，发布了 51 期每周 Newsletter<!-- 78 to 129 -->，在我们的[话题索引][topics index]中新增了 20 个页面，向我们的[兼容性索引][compatibility index]中添加了多个新钱包和服务，并发布了几篇关于比特币扩展技术的[博客文章][optech blog posts]。

</div>

## 九月

{:#glv-endomorphism}
在 [2011 年的一篇论坛帖子][finney glv]中，比特币早期贡献者 Hal Finney 描述了一种由 Gallant、Lambert 和 Vanstone 提出的 GLV 方法，该方法可以减少验证比特币交易签名所需的昂贵计算次数。Finney 编写了一个概念验证实现，据称其将签名验证速度提高了约 25%。不幸的是，该算法受到[美国专利 7,110,538][U.S.  Patent 7,110,538] 的限制，因此无论是 Finney 的实现还是 Pieter Wuille 的后续实现都未分发给用户。9 月 25 日，[该专利过期][news117 patent]。一个月内，该代码被[合并][news120 glv]到 Bitcoin Core 中。对于默认设置的用户，这种速度提升在同步新节点的最后部分或节点离线一段时间后验证区块时最为明显。Finney 于 2014 年去世，但我们依然感激他在推广密码学技术方面所做的二十年努力。

{:#patent-alliance}
Square [宣布][copa announced]成立加密货币开放专利联盟（COPA），以协调与加密货币技术相关的专利池。成员允许任何人自由使用他们的专利，并以此换取在面对专利侵权者时使用专利池中的专利的权利。截至撰写本文时，该联盟已有 [18 个成员][copa membership]，包括 ARK.io、Bithyve、Blockchain Commons、Blockstack、Blockstream、Carnes Validadas、Cloudeya Ltd.、Coinbase、Foundation Devices、Horizontal Systems、Kraken、Mercury Cash、Protocol Labs、Request Network、SatoshiLabs、Square、Transparent Systems 和 VerifyChain。

## 十月

{:#jamming}
10 月，LN 开发者关于解决最早在 2015 年[描述][russell loop]的拦截问题及相关问题的讨论显著增加。LN 节点可以通过 20 个或更多跳跃的路径将支付路由到自身。这使得一个拥有 1 BTC 的攻击者可以暂时锁定其他用户超过 20 BTC 的资金。数小时后，攻击者可以取消支付并完全退还手续费，从而几乎免费实施攻击。另一个相关问题是攻击者通过一系列通道发送 483 笔小额支付（483 是通道可能容纳的最大未结支付数量）。在这种情况下，一个拥有两个各有 483 个插槽的通道的攻击者可以阻塞超过 10,000 个诚实连接插槽——同样无需支付任何费用。[多种解决方案][news120 upfront]被讨论，包括支付路径上的每个节点的*前向手续费*、[支付跳跃的每个节点的后向手续费][news86 backwards upfront]、[前向和后向费用的组合][news122 bidir fees]、[嵌套增量路由][news119 nested routing]和[保真度债券][news126 routing fibonds]。然而，没有任何一种方法获得广泛接受，因此问题仍未解决。

{:.center}
![LN 流动性和 HTLC 拦截攻击示意图](/img/posts/2020-12-ln-jamming-attacks.png)

{:#lnd-disclosures}
10 月，两项针对 LND 的资金窃取攻击（由 Antoine Riard 于 4 月发现并报告）被[完全披露][news121 riard disclosures]。一种情况下，LND 可能被诱骗接受无效数据；另一种情况下，可能被诱骗披露秘密数据。得益于 Riard 的负责任披露和 LND 团队的响应，尚未发现任何用户因此丢失资金。LN 规范针对[两个问题][news123 high-s][news124 htlc release]进行了更新，以帮助新实现避免这些问题。

{:#generic-signmessage}
在初始 Segwit 提案引入五年后，其激活三年后，仍没有通用的方法使用与 P2WPKH 或 P2SH-P2WPKH 地址对应的密钥创建和验证纯文本消息签名。更普遍的问题是：也没有一种广泛支持的方式处理 P2SH、P2WSH 和 P2SH-P2WSH 地址的消息签名——更不用说 Taproot 地址的前向兼容方法了。[BIP322][] 提出了一个[通用消息签名][topic generic signmessage]功能以解决所有这些问题，但未能获得足够关注。今年看到该提案的进一步[反馈请求][news88 signmessage rfh]、[简化尝试][news91 signmessage simplification]，以及 10 月对其核心机制的几乎[完全替代][news118 signmessage update proposal]。[新机制][news121 signmessage update bip]通过允许对*虚拟交易*签名（看似真实交易但根据比特币共识规则无效）使消息签名潜在地与大量现有软件和硬件钱包以及 [PSBT][topic psbt] 数据格式兼容。希望这一改进能推动通用消息签名的采用。

{:#musig2}
Jonas Nick、Tim Ruffing 和 Yannick Seurin 在 10 月[发布了][news120 musig2] MuSig2 论文，描述了 MuSig 签名方案的一种新变体，该变体具有两轮签名协议且无需零知识证明。此外，第一轮（随机数交换）可以在密钥设置阶段完成，非交互式签名变体可能对冷存储和链下合约协议（如 LN）特别有用。

{:#addrv2}
同样在 10 月，Bitcoin Core 成为第一个[合并][bcc19954]版本 2 `addr` 消息实现的项目。`addr` 消息广播潜在对等方的网络地址，使全节点能够在无集中协调的情况下发现新对等方。原始比特币 `addr` 消息被设计为容纳 128 位 IPv6 地址，也可以包含编码的 IPv4 地址和版本 2 Tor 洋葱地址。Tor 项目在近 15 年的生产中弃用了版本 2 洋葱服务，并将在 2021 年 7 月停止支持。新的版本 3 洋葱地址为 256 位，因此无法与原始 `addr` 消息一起使用。[BIP155][] 对 `addr` 消息的升级为 Tor 地址提供了更大的容量，同时也支持其他需要更大地址的匿名网络。

## 十一月

{:#lightning-pool}
正如二月份部分提到的，目前 LN 网络面临的一个挑战是用户和商家需要具有入站容量的通道，以便通过 LN 接收资金。一种完全去中心化的解决方案可能是前面描述的双向资助通道。然而，11 月，Lightning Labs 采取了不同的路线，[宣布][news123 lightning pool]推出新的 Lightning Pool 市场，用于购买入站 LN 通道。一些现有节点运营商已经提供入站通道服务，或免费或付费，但 Lightning Pool 可能通过其集中协调的市场使这项服务更加标准化和具有竞争力。这项服务也可能在双向资助通道可用时升级以与之配合使用。

## 十二月

{:#ln-offers}
去年，Rusty Russell 发布了一份关于 LN *报价*（offers）的[提议规范][bolt12 draft]的初稿，该功能允许支付节点通过洋葱路由的 LN 网络向接收节点请求发票。虽然现有的 [BOLT11][] 提供了发票协议，但它不允许支付方和接收方节点之间进行协议级的协商。报价功能将使节点能够传递附加信息，并自动化当前需要人工干预或额外工具的支付步骤。例如，报价功能可以允许 LN 节点通过让支付方节点每月向接收方节点请求新发票来管理定期支付或捐赠。2020 年 12 月，Russell 在 C-Lightning 上实现报价功能的一系列提交中的第一个被[合并][news128 offers]。

## 结论

总结过去一年的事件让我们感到欣慰的是，所有的进展都已完全实现。上述总结中并未包含比特币未来将会实现的承诺——它仅列出了过去 12 个月中取得的实际成就。2020 年，比特币的贡献者们有很多值得骄傲的地方。我们迫不及待想看看他们在 2021 年会为我们带来什么。

*Optech Newsletter 将于 1 月 6 日恢复其常规的周三发布时间表。*

{% include references.md %}
{% include linkers/issues.md issues="8312,524,18038,18861,19109,14582,19743,16152" %}
[2018 summary]: /zh/newsletters/2018/12/28/
[2019 summary]: /zh/newsletters/2019/12/28/
[`addr` message]: https://btcinformation.org/en/developer-reference#addr
[atomicity attack discussion]: /zh/newsletters/2020/06/24/#continued-discussion-about-ln-atomicity-attack
[attack htlc incentives]: /zh/newsletters/2020/07/01/#discussion-of-htlc-mining-incentives
[attack invdos]: /zh/newsletters/2020/09/16/#inventory-out-of-memory-denial-of-service-attack-invdos
[attack ln atomicity]: /zh/newsletters/2020/04/29/#new-attack-against-ln-payment-atomicity
[attack ln fee ransom]: /zh/newsletters/2020/06/24/#ln-fee-ransom-attack
[attack overpay segwit]: /zh/newsletters/2020/06/10/#fee-overpayment-attack-on-multi-input-segwit-transactions
[attack time dilation]: /zh/newsletters/2020/06/10/#time-dilation-attacks-against-ln
[bcc18044]: /zh/newsletters/2020/07/29/#bitcoin-core-18044
[bcc18267]: /zh/newsletters/2020/09/30/#bitcoin-core-18267
[bcc19569]: /zh/newsletters/2020/08/05/#bitcoin-core-19569
[bcc19954]: /zh/newsletters/2020/10/14/#bitcoin-core-19954
[belcher coinswap1]: /zh/newsletters/2020/06/03/#design-for-a-coinswap-implementation
[belcher coinswap2]: /zh/newsletters/2020/08/26/#discussion-about-routed-coinswaps
[belcher coinswap3]: /zh/newsletters/2020/09/09/#continued-coinswap-discussion
[belcher dec8 tweet]: https://twitter.com/chris_belcher_/status/1336322923800322049
[bfd post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2016-May/012636.html
[bip157 spec discussion]: /zh/newsletters/2018/06/08/#bip157-bip157-bip158-bip158-lightweight-client-filters
[bips900]: /zh/newsletters/2020/05/06/#bips-900
[bips933]: /zh/newsletters/2020/07/01/#bips-933
[bips947]: /zh/newsletters/2020/08/05/#bips-947
[bips983]: /zh/newsletters/2020/09/09/#bips-983
[bitcoin core 0.20.0]: /zh/newsletters/2020/06/10/#bitcoin-core-0-20-0
[bolt12 draft]: https://github.com/rustyrussell/lightning-rfc/blob/guilt/offers/12-offer-encoding.md
[btcd #1180]: https://github.com/btcsuite/btcd/pull/1180
[cl3870]: /zh/newsletters/2020/09/16/#c-lightning-3870
[cl4068]: /zh/newsletters/2020/09/30/#c-lightning-4068
[c-lightning 0.9.0]: /zh/newsletters/2020/08/05/#c-lightning-0-9-0
[coinswap design]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-May/017898.html
[common ownership heuristic]: https://en.bitcoin.it/wiki/Common-input-ownership_heuristic
[compatibility index]: /zh/compatibility/
[copa announced]: /zh/newsletters/2020/09/16/#crypto-open-patent-alliance
[copa membership]: /zh/newsletters/2020/12/09/#cryptocurrency-open-patent-alliance-copa-gains-new-members
[crypto garage p2p deriv]: /zh/newsletters/2020/08/19/#crypto-garage-announces-p2p-derivatives-beta-application-on-bitcoin
[default signet discussion]: /zh/newsletters/2020/09/02/#default-signet-discussion
[discreet log contracts]: https://adiabat.github.io/dlc.pdf
[dlc election bet]: https://suredbits.com/settlement-of-election-dlc/
[dlc spec]: https://github.com/discreetlogcontracts/dlcspecs/
[dryja poon sf devs]: https://lightning.network/lightning-network.pdf
[ecdsa]: https://en.wikipedia.org/wiki/Elliptic_Curve_Digital_Signature_Algorithm
[eclair 0.4]: /zh/newsletters/2020/05/13/#eclair-0-4
[finney glv]: https://bitcointalk.org/index.php?topic=3238.msg45565#msg45565
[fournier otves]: https://github.com/LLFourn/one-time-VES/blob/master/main.pdf
[joinmarket]: https://github.com/JoinMarket-Org/joinmarket-clientserver
[libsecp256k1]: https://github.com/bitcoin-core/secp256k1
[libsecp256k1-zkp]: https://github.com/ElementsProject/secp256k1-zkp
[lnd 0.10.0-beta]: /zh/newsletters/2020/05/06/#lnd-0-10-0-beta
[lnd 0.11.0-beta]: /zh/newsletters/2020/08/26/#lnd-0-11-0-beta
[lnd 0.9.0-beta]: /zh/newsletters/2020/01/29/#upgrade-to-lnd-0-9-0-beta
[maxwell gcs]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2016-May/012637.html
[musig2 paper]: /zh/newsletters/2020/10/21/#musig2-paper-published
[neutrino]: https://github.com/lightninglabs/neutrino
[news100 bcc19010]: /zh/newsletters/2020/06/03/#bitcoin-core-19010
[news100 revault arch]: /zh/newsletters/2020/06/03/#the-revault-multiparty-vault-architecture
[news101 additional commitment]: /zh/newsletters/2020/06/10/#bips-920
[news102 bip85]: /zh/newsletters/2020/06/17/#bips-910
[news102 wasabi]: /zh/newsletters/2020/06/17/#wabisabi-coordinated-coinjoins-with-arbitrary-output-values
[news104 bips923]: /zh/newsletters/2020/07/01/#bips-923
[news107 bcc19109]: /zh/newsletters/2020/07/22/#bitcoin-core-19109
[news107 bech32 fives]: /zh/newsletters/2020/07/22/#bech32-address-updates
[news109 sapio]: /zh/newsletters/2020/08/05/#sapio
[news111 bcc19070]: /zh/newsletters/2020/08/19/#bitcoin-core-19070
[news111 uniform tiebreaker]: /zh/newsletters/2020/08/19/#proposed-uniform-tiebreaker-in-schnorr-signatures
[news112 bcc14582]: /zh/newsletters/2020/08/26/#bitcoin-core-14582
[news112 bolts688]: /zh/newsletters/2020/08/26/#bolts-688
[news113 bip340 update]: /zh/newsletters/2020/09/02/#bips-982
[news113 witasym]: /zh/newsletters/2020/09/02/#witness-asymmetric-payment-channels
[news115 bip340 merge]: /zh/newsletters/2020/09/16/#libsecp256k1-558
[news116 payjoin joinmarket]: /zh/newsletters/2020/09/23/#joinmarket-0-7-0-adds-bip78-psbt
[news117 patent]: /zh/newsletters/2020/09/30/#us-patent-7-110-538-has-expired
[news118 signmessage update proposal]: /zh/newsletters/2020/10/07/#alternative-to-bip322-generic-signmessage
[news119 bech32 discussion]: /zh/newsletters/2020/10/14/#bech32-addresses-for-taproot
[news119 nested routing]: /zh/newsletters/2020/10/14/#incremental-routing
[news119 witasym update]: /zh/newsletters/2020/10/14/#updated-witness-asymmetric-payment-channel-proposal
[news120 glv]: /zh/newsletters/2020/10/21/#libsecp256k1-830
[news120 musig2]: /zh/newsletters/2020/10/21/#musig2-paper-published
[news120 taproot merge]: /zh/newsletters/2020/10/21/#bitcoin-core-19953
[news120 upfront]: /zh/newsletters/2020/10/21/#more-ln-upfront-fees-discussion
[news121 riard disclosures]: /zh/newsletters/2020/10/28/#full-disclosures-of-recent-lnd-vulnerabilities
[news121 signmessage update bip]: /zh/newsletters/2020/10/28/#bips-1003
[news122 bidir fees]: /zh/newsletters/2020/11/04/#bi-directional-upfront-fees-for-ln
[news122 devsurvey]: /zh/newsletters/2020/11/04/#taproot-activation-survey-results
[news123 high-s]: /zh/newsletters/2020/11/11/#bolts-807
[news123 lightning pool]: /zh/newsletters/2020/11/11/#incoming-channel-marketplace
[news124 htlc release]: /zh/newsletters/2020/11/18/#bolts-808
[news125 miner survey]: /zh/newsletters/2020/11/25/#website-listing-miner-support-for-taproot-activation
[news126 routing fibonds]: /zh/newsletters/2020/12/02/#fidelity-bonds-for-ln-routing
[news127 bech32m research]: /zh/newsletters/2020/12/09/#bech32-addresses-for-taproot-and-beyond
[news128 fancy static]: /zh/newsletters/2020/12/16/#proposed-improvements-to-static-ln-backups
[news128 offers]: /zh/newsletters/2020/12/16/#c-lightning-4255
[news24 cpfp carve out]: /zh/newsletters/2018/12/04/#cpfp-carve-out
[news59 bishop idea]: /zh/newsletters/2019/08/14/#bitcoin-vaults-without-covenants
[news80 msfa]: /zh/newsletters/2020/01/15/#discussion-of-soft-fork-activation-mechanisms
[news81 dlc]: /zh/newsletters/2020/01/22/#protocol-specification-for-discreet-log-contracts-dlcs
[news83 alt tiebreaker]: /zh/newsletters/2020/02/05/#alternative-x-only-pubkey-tiebreaker
[news83 interactive funding]: /zh/newsletters/2020/02/05/#interactive-construction-of-ln-funding-transactions
[news85 blinded paths]: /zh/newsletters/2020/02/19/#decoy-nodes-and-lightweight-rendez-vous-routing
[news86 backwards upfront]: /zh/newsletters/2020/02/26/#reverse-up-front-payments
[news86 bolts596]: /zh/newsletters/2020/02/26/#bolts-596
[news86 large channels]: /zh/newsletters/2020/02/26/#bolts-596
[news87 bip340 update1]: /zh/newsletters/2020/03/04/#bips-886
[news87 bip340 update]: /zh/newsletters/2020/03/04/#updates-to-bip340-schnorr-keys-and-signatures
[news87 exfiltration]: /zh/newsletters/2020/03/04/#proposal-to-standardize-an-exfiltration-resistant-nonce-protocol
[news87 taproot generic group]: /zh/newsletters/2020/03/04/#taproot-in-the-generic-group-model
[news88 exfiltration]: /zh/newsletters/2020/03/11/#exfiltration-resistant-nonce-protocols
[news88 signmessage rfh]: /zh/newsletters/2020/03/11/#bip322-generic-signmessage-progress-or-perish
[news89 op_if]: /zh/newsletters/2020/03/18/#bitcoin-core-16902
[news8 p2ep]: /zh/newsletters/2018/08/14/#pay-to-end-point-p2ep-idea-proposed
[news91 bip340 powerdiff]: /zh/newsletters/2020/04/01/#mitigating-differential-power-analysis-in-schnorr-signatures
[news91 signmessage simplification]: /zh/newsletters/2020/04/01/#proposed-update-to-bip322-generic-signmessage
[news92 cl3600]: /zh/newsletters/2020/04/08/#c-lightning-3600
[news92 ecdsa adaptor]: /zh/newsletters/2020/04/08/#work-on-ptlcs-for-ln-using-simplified-ecdsa-adaptor-signatures
[news93 super keychain]: /zh/newsletters/2020/04/15/#proposal-for-using-one-bip32-keychain-to-seed-multiple-child-keychains
[news94 bishop vault]: /zh/newsletters/2020/04/22/#vaults-prototype
[news94 btcpay payjoin]: /zh/newsletters/2020/04/22/#btcpay-adds-support-for-sending-and-receiving-payjoined-payments
[news95 revault]: /zh/newsletters/2020/04/29/#multiparty-vault-architecture
[news96 bcc18038]: /zh/newsletters/2020/05/06/#bitcoin-core-18038
[news96 bip340 nonce update]: /zh/newsletters/2020/05/06/#bips-893
[news96 bip340 update]: /zh/newsletters/2020/05/06/#bips-893
[news97 additional commitment]: /zh/newsletters/2020/05/13/#request-for-an-additional-taproot-signature-commitment
[news98 bcc18877]: /zh/newsletters/2020/05/20/#bitcoin-core-18877
[news98 sas]: /zh/newsletters/2020/05/20/#two-transaction-cross-chain-atomic-swap-or-same-chain-coinswap
[news99 bcc18861]: /zh/newsletters/2020/05/27/#bitcoin-core-18861
[nick filter privacy]: https://jonasnick.github.io/blog/2015/02/12/privacy-in-bitcoinj/
[optech blog posts]: /zh/blog/
[rubin fee sponsorship]: /zh/newsletters/2020/09/23/#transaction-fee-sponsorship
[russell loop]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2015-August/000135.html
[rv routing]: /zh/newsletters/2018/11/20/#hidden-destinations
[somsen sas post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-May/017846.html
[somsen sas video]: https://www.youtube.com/watch?v=TlCxpdNScCA
[##taproot-activation]: /zh/newsletters/2020/07/22/#taproot-activation-discussions
[taproot workshop]: /zh/workshops/#taproot-workshop
[todd segwit review]: https://petertodd.org/2016/segwit-consensus-critical-code-review#peer-to-peer-networking
[topics index]: /en/topics/
[tx origin wiki]: https://en.bitcoin.it/wiki/Privacy#Traffic_analysis
[u.s. patent 7,110,538]: https://patents.google.com/patent/US7110538B2/en
