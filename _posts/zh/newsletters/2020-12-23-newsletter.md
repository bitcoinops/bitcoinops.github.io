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
  * [LN 双向资助与交互式资助](#dual-interactive-funding)
  * [LN 盲化路径](#blinded-paths)
* 三月
  * [抗外泄签名](#exfiltration-resistance)
* 四月
  * [Payjoin](#payjoin)
  * [LN PTLC 与其他基于密码学的改进](#ptlcs)
  * [BIP85 密钥链](#bip85)
  * [保险库](#vaults)
* 五月
  * [交易来源隐私](#transaction-origin-privacy)
  * [简洁原子互换（SAS）](#succinct-atomic-swaps-sas)
  * [Coinswap 实现](#coinswap-implementation)
  * [紧凑区块过滤器](#compact-block-filters)
* 六月
  * [多输入 segwit 交易的超额支付攻击](#overpayment-attack-on-multi-input-segwit-transactions)
  * [LN 支付原子性攻击](#ln-payment-atomicity-attack)
  * [针对 LN 的快速日食攻击](#fast-ln-eclipse-attacks)
  * [LN 手续费勒索攻击](#ln-fee-ransom)
  * [HTLC 挖矿激励](#concern-about-htlc-mining-incentives)
  * [库存内存耗尽拒绝服务攻击（InvDoS）](#inventory-out-of-memory-denial-of-service-attack-invdos)
  * [WabiSabi 协调的任意输出金额 coinjoin](#wabisabi)
* 七月
  * [WTXID 交易公告](#wtxid-announcements)
* 八月
  * [signet](#signet)
  * [LN 锚定输出](#anchor-outputs)
* 九月
  * [更快的签名验证](#glv-endomorphism)
  * [专利联盟](#patent-alliance)
* 十月
  * [LN 通道堵塞攻击](#jamming)
  * [LND 安全披露](#lnd-disclosures)
  * [通用消息签名](#generic-signmessage)
  * [MuSig2](#musig2)
  * [版本 2 的地址消息](#addrv2)
* 十一月
  * [Lightning Pool 的入站通道市场](#lightning-pool)
* 十二月
  * [LN offers](#ln-offers)
* 精选总结
    * [taproot、tapscript 和 schnorr 签名](#taproot)
    * [热门基础设施项目的重要发布](#releases)
    * [Bitcoin Optech](#optech)

## 一月

{:#dlc}
一些开发者开始[着手][news81 dlc]制定一份[规范][dlc spec]，以便在不同软件之间使用[谨慎日志合约][discreet log contracts]（DLC）。DLC 是一种合约协议，两个或多个参与方约定根据某个事件的结果交换资金，而该结果由预言机（或多个预言机）确定。事件发生后，预言机会发布对事件结果的承诺，获胜方可以使用它来索取资金。预言机无需知道合约的条款（甚至无需知道合约的存在）。这种合约可以与许多其他比特币交易难以区分，也可以在 LN 通道内执行。这使得 DLC 比其他已知的基于预言机的合约方式更私密、更高效，而且可以说更安全，因为预言机若对虚假结果作出承诺，就会留下明确的欺诈证据。到年底时，已有四种相互兼容的 DLC 实现、一个用于提供和接受基于 DLC 的点对点衍生品的[应用程序][crypto garage p2p deriv]，以及若干[报告][dlc election bet]自己在主网交易中使用过 DLC 的用户。

## 二月

{:#large-channels}
在 LN 的[首次公开演讲][dryja poon sf devs]五年后，一些当初只为临时采用的早期协议决定被重新审视。最直接的变化是 LN 规范在二月[更新][news86 bolts596]，允许用户选择退出 2016 年制定的[最大通道和支付金额限制][topic large channels]。

{:#dual-interactive-funding}
另一个被重新审视的早期决定是：为了保持协议简单，让所有通道都由单一出资方开通。这会降低协议复杂性，但也使通道出资方在花掉一部分自己的资金之前无法接收任何付款——这种处境给商户加入 LN 造成了障碍。解决该问题的一个提案是双向资助通道：通道创建者和其对手方都向通道投入一定资金。Lisa Neigut 已经为双向资助开发了一份[协议][bolts #524]，但（正如预期）它很复杂。二月，她发起了一场[讨论][news83 interactive funding]，提出对现有单出资方标准做一项渐进式改进，允许以交互方式构建注资交易。目前的做法是一方提议开通通道，另一方只能接受或拒绝；相比之下，双方所属的节点可以交换各自的偏好信息，协商开通一个双方都满意的通道。

{:#blinded-paths}
为 LN 实现会合路由（rendez-vous routing）的计划——它曾在[2018 年 LN 规范会议][rv routing]上被列为优先事项——也取得了新进展。二月，Bastien Teinturier 基于他此前提出的隐私增强方案，[描述][news85 blinded paths]了一种实现同等隐私的新方法。这种新方法被称为*盲化路径*，后来在 [C-Lightning][news92 cl3600] 中作为实验性功能实现。

## 三月

{:#exfiltration-resistance}
硬件钱包可能用来从用户那里窃取比特币的一种方法，是通过其创建的交易签名泄露钱包私钥的信息。三月，[Stepan Snigirev][news87 exfiltration]、[Pieter Wuille][news88 exfiltration] 以及其他几人讨论了针对比特币当前的 ECDSA 签名系统和提议的 [schnorr 签名][topic schnorr signatures]系统解决该问题的可能方案。

<div markdown="1" class="callout" id="taproot">

### 2020 年总结<br>taproot、tapscript 和 schnorr 签名

2020 年几乎每个月，提议中的 [taproot][topic taproot] 软分叉（[BIP341][]）都有值得注意的进展；该软分叉同时引入了对 [schnorr 签名][topic schnorr signatures]（[BIP340][]）和 [tapscript][topic tapscript]（[BIP342][]）的支持。这些改进合在一起，将使单签名脚本、多重签名脚本和复杂合约的用户都能使用外观完全相同的承诺，从而增强隐私并提升所有比特币的可替代性。付款方将享受更低的手续费和更高的效率，并且能以与单签名用户相同的效率、同样低的手续费和同样大的匿名集，来使用许多多重签名脚本和复杂合约。taproot 和 schnorr 还为未来可能的升级奠定了基础，这些升级或许能进一步提升效率、隐私和可替代性，例如签名聚合、[SIGHASH_ANYPREVOUT][topic sighash_anyprevout] 和[脚本语言变更][topic simplicity]。

本节把有关这些进展的总结汇成一条叙事，希望比按月份逐条描述事件更容易理解。

{:#activation-mechanisms}
一月，关于软分叉激活机制的讨论开场，Matt Corallo [提议][news80 msfa]用一种谨慎而耐心的方式来处理不同利益相关方之间的分歧。其他开发者则聚焦于 [BIP8][] 提案，希望能够快速绕过那类曾在 2016 和 2017 年拖延 segwit 激活的程序性问题。关于究竟该采用哪种激活机制的讨论贯穿全年，在[专用 IRC 频道][##taproot-activation]及其他地方进行，期间既有关于机制设计的[开发者调查][news122 devsurvey]，也有关于矿工对 taproot 支持情况的[矿工调查][news125 miner survey]。

二月出现了全年若干次更新中的第一次，这些更新针对 BIP340 schnorr 签名规范中用于派生公钥和签名的算法。这些[变更][news87 bip340 update]中[大多数][news83 alt tiebreaker]都是[小型][news111 uniform tiebreaker]优化，是人们在 [libsecp256k1][] 及其实验性分叉 [libsecp256k1-zkp][] 中实现和测试该提案时，从[经验][news113 bip340 update]中[发现][news96 bip340 update]的。同样在二月，Lloyd Fournier [扩展][news87 taproot generic group]了 Andrew Poelstra 此前为 taproot 给出的安全性证明。

三月，Bitcoin Core 在没有引入分叉的前提下[小心地改动][news89 op_if]了自己的共识代码，以消除 `OP_IF` 及相关流程控制操作码解析中的一处低效。目前这处低效还无法被利用来制造问题，但为 tapscript 提议的扩展能力本会使攻击者有可能利用这处低效，创建出需要大量计算才能验证的区块。

尽管公众对 taproot 的关注大多集中在它对比特币共识规则的改变上，但除非钱包开发者能够安全地使用它，否则 taproot 不会带来正面贡献。四月以及全年之中，BIP340 有[若干次][news87 bip340 update1]更新[修改][news87 bip340 update]了关于开发者[如何][news96 bip340 nonce update]生成公钥和签名随机数的[建议][news91 bip340 powerdiff]。这些改动可能只对密码学家有直接的吸引力，但比特币历史上有很多人因为钱包开发者没有完全理解自己实现的密码学协议而损失资金的例子。希望 BIP340 中经验丰富的密码学家给出的建议，能帮助在未来避免这类问题。

五月，关于“盲化所有权攻击”的[讨论][news97 additional commitment]重新活跃起来——这种攻击使得用硬件钱包自动签署交易变得危险。理想情况下，硬件钱包可以提供一种模式，自动签署保证能增加钱包余额的交易，例如 maker coinjoin 和 LN [拼接][topic splicing]。可惜，只有在你确知哪些输入属于自己时，签署交易才是安全的——否则攻击者可能先诱使你签署一笔看起来只包含你一个输入的交易，再诱使你签署同一笔交易的另一个版本（同样看起来只有一个输入，但实际是另一个输入），最后把这两个不同输入的签名合并成真正的交易，把你的钱付给攻击者。这通常不是风险，因为如今大多数人只用自己的硬件钱包签署输入全部属于自己的交易；但对于 coinjoin、LN 拼接和其他协议，其他用户可能会部分或完全控制某些输入。有人提议让 taproot 提供一种额外的输入承诺方式，与 [PSBT][topic psbt] 中提供的数据配合使用，确保硬件钱包只有在掌握足够数据、能识别全部输入时才会生成有效签名。这一提案后来被[接受][news101 additional commitment]进 BIP341。

![通过伪造 coinjoin 欺骗硬件钱包丢失资金的示意图](/img/posts/2020-05-fake-coinjoin-trick-hardware-wallet.dot.png)

七月，人们再次讨论了一个早已知道的问题——[bech32 地址格式][topic bech32]在防止用户把资金发送到无法花费的地址方面，效果不如预期。这对当前使用 bech32 地址的人没有实际影响，但对计划中的 taproot 地址可能是个问题：增加或删除少量字符就可能导致资金损失。去年有人提议直接把当前 segwit v0 地址的保护措施扩展到 segwit v1（taproot）地址，但那样会降低未来升级的灵活性。[今年][news107 bech32 fives]，经过更多[研究][news127 bech32m research]和[辩论][news119 bech32 discussion]，开发者之间似乎达成了共识：taproot 以及未来基于 segwit 的脚本升级应使用一种新地址格式，它是对原始 [BIP173][] bech32 地址的小幅调整。新格式将弥补这一缺陷，并提供其他一些不错的特性。

九月，[BIP340][] 中实现 schnorr 签名验证和单方签名功能的代码被[合并][news115 bip340 merge]进 libsecp256k1，并很快成为 Bitcoin Core 的一部分。这使得十月能够接着[合并][news120 taproot merge] taproot、schnorr 和 tapscript 的验证代码。这些代码包含约 700 行与共识相关的改动（不计注释和空白为 500 行）和 2,100 行测试。超过 30 人直接审查了这个 PR 及相关改动，还有许多人参与了底层研究、BIP、libsecp256k1 中的相关代码以及系统其他部分的开发和审查。这些新软分叉规则目前只用于 [signet][topic signet] 和 Bitcoin Core 的私有测试模式（“regtest”）；它们需要先被激活，才能在比特币主网上使用。

许多 taproot 贡献者在今年余下的时间里专注于 Bitcoin Core 0.21.0 的发布，目的是让随后的一个小版本（可能是 0.21.1）包含这样的代码：在收到适当的激活信号时，即可开始执行 taproot 的规则。

</div>

## 四月

{:#payjoin}
基于 2018 年 [Pay-to-EndPoint 提案][news8 p2ep]的 [payjoin][topic payjoin] 协议在四月迎来了重大推动：它的一个版本被[加入][news94 btcpay payjoin] BTCPay 自托管支付处理系统。payjoin 为用户提供了一种便捷方式，通过创建交易来削弱“同一笔交易的所有输入属于同一个人”这一[假设][common ownership heuristic]，从而提升自己以及网络其他用户的隐私。BTCPay 的 payjoin 版本随后被[写成规范][news104 bips923]，即 [BIP78][]，并被[其他程序][news116 payjoin joinmarket]加入支持。

{:#ptlcs}
LN 一项广受期待的改进，是把支付安全机制从 [HTLC][topic htlc] 换成 [PTLC][topic ptlc]，从而让付款方和收款方在面对各种监控手段时获得更好的隐私。一个难点在于，理想的多方 PTLC 构造用比特币现有的 [ECDSA 签名方案][ecdsa]实现起来颇具挑战（不过改用 [schnorr 签名][topic schnorr signatures]会更容易）。今年年初，Lloyd Fournier 散发了一篇[论文][fournier otves]，通过把签名适配器核心的锁定特性与信息交换特性，从其依赖多方签名的部分中剥离出来，描述了如何改用普通的、基于 Bitcoin Script 的多重签名这一简便做法。在四月的一次黑客马拉松中，几位开发者在这个很受欢迎的 libsecp256k1 库的一个分叉上做出了该协议的[粗略实现][news92 ecdsa adaptor]。随后在九月，Fournier 又提出了一种[新方式][news113 witasym]来[构建][news119 witasym update] LN 承诺交易，从而无需等待比特币做出改动就能提升 PTLC 的实用性。十二月，他还提出了[两种新方法][news128 fancy static]来增强 LN 备份的健壮性，再次通过巧妙地运用密码学，为用户的实际问题提供了可行的解决方案。

{:#bip85}
四月，Ethan Kosakovsky 在 Bitcoin-Dev 邮件列表中[发布][news93 super keychain]了一项提案：用一个 [BIP32][] 分层确定性（HD）密钥链，为可用于不同场景的子 HD 密钥链创建种子。这或许能解决许多钱包不支持导入扩展私钥（xprv）的问题——它们只允许导入 HD 种子或会被转换成种子的一些前驱数据（如 [BIP39][] 或 SLIP39 种子词）。该提案让拥有多个钱包的用户只需用超级密钥链的种子就能备份所有这些钱包。这一提案后来[成为][news102 bip85] [BIP85][]，并在 ColdCard 硬件钱包的近期版本中实现。

{:#vaults}
四月，出现了两个关于[保险库][topic vaults]的公告。保险库是一种称为[契约][topic covenants]的合约，当有人试图花费契约中的资金时会发出警告，从而给契约所有者留出阻止未授权花费的时间。Bryan Bishop 公布了一个基于他去年[构想][news59 bishop idea]的[保险库原型][news94 bishop vault]。Kevin Loaec 和 Antoine Poinsot 公布了自己的项目 [Revault][news95 revault]，它[专注于][news100 revault arch]用保险库模型、以多重签名安全性来存储多个用户共享的资金。Jeremy Rubin 还公布了一门[新的高级编程语言][news109 sapio]，用于借助提议的 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] 操作码构建有状态的智能合约，这可以让保险库的创建和管理更容易。

## 五月

{:#transaction-origin-privacy}
Bitcoin Core 项目在五月及随后几个月合并了多个 PR，改善了[交易来源隐私][tx origin wiki]，既有利于 Bitcoin Core 钱包用户，也有利于其他系统的用户。[Bitcoin Core #18038][] 开始[跟踪][news96 bcc18038]是否有至少一个对等节点接受了本地生成的交易，这让钱包能够大幅降低 Bitcoin Core 重新广播自己交易的频率，也使监控节点更难判断是哪个节点发起了这笔交易。PR [#18861][Bitcoin Core #18861] 和 [#19109][Bitcoin Core #19109] 只对“节点曾告知过该交易”的对等节点发来的交易请求作出[回应][news107 bcc19109]，从而[阻止了监控节点的一种主动扫描][news99 bcc18861]，进一步削弱第三方判断哪个节点最先广播交易的能力。PR [#14582][Bitcoin Core #14582] 和 [#19743][Bitcoin Core #19743] 让钱包能够[自动尝试][news112 bcc14582]在不给用户增加任何额外手续费的情况下消除[地址重用][topic output linking]带来的关联（或者允许用户指定自己为消除这类关联最多愿意多付多少手续费）。

五月底和六月初，coinswap 出现了两项重要进展。Coinswap 是一种无需信任的协议，让两个或更多用户创建看起来像普通支付的交易，实际上却在彼此之间互换币。这不仅改善了 coinswap 用户的隐私，也改善了所有比特币用户的隐私，因为任何看起来像支付的交易，也可能其实是一次 coinswap。

- **<!--succinct-atomic-swaps-sas-->****简洁原子互换（SAS）：** Ruben Somsen 写了一篇文章并制作了视频，描述一种只用两笔交易就完成无需信任的币互换的[流程][news98 sas]。相比早期的 coinswap 设计，该协议有几个优势：占用的区块空间更少，节省交易手续费，在跨链互换中只需要其中一条链上由共识强制的时间锁，而且不依赖任何新的安全假设或比特币共识变更。如果 taproot 被采用，互换还能变得更私密、更高效。

- **<!--coinswap-implementation-->****Coinswap 实现：** Chris Belcher [发布][belcher coinswap1]了一份功能完整的 coinswap 实现设计。他的[初步帖子][coinswap design]包括 coinswap 构想的历史，提出了把 coinswap 所需的多重签名条件伪装成更常见交易类型的办法，建议使用流动性市场（类似 JoinMarket 已有的做法），描述了通过拆分和路由技术来减少因金额关联或参与者窥探造成的隐私损失，建议把 coinswap 与 [payjoin][topic payjoin] 结合，并讨论了该系统的部分后端需求。此外，他还把 coinswap 与使用 LN、[coinjoin][topic coinjoin]、payjoin、payswap 等其他隐私技术做了比较。该提案引来了[大量][belcher coinswap2][专家讨论][belcher coinswap3]，其中一些建议被整合进协议。到十二月，Belcher 的原型软件已经在测试网上[创建 coinswap][belcher dec8 tweet]，表明它们极难被关联。

{:#compact-block-filters}
从比特币早期开始，开发具有 SPV 安全性的轻量级客户端时的一大挑战就是：如何让客户端下载影响自己钱包的交易，同时又不让提供这些交易的第三方服务器有能力追踪该钱包的收款和支出历史。最初的尝试是 [BIP37][] 风格的[布隆过滤器][topic transaction bloom filtering]，但钱包的使用方式最终只带来[极有限的隐私][nick filter privacy]，还给为它们服务的全节点制造了[拒绝服务风险][bitcoin core #16152]。2016 年 5 月，一位匿名开发者向 Bitcoin-Dev 邮件列表提议了另一种构造：[每区块一个布隆过滤器][bfd post]，供所有钱包共同使用。这个想法很快被[完善][maxwell gcs]、[实现][neutrino]并[写成规范][bip157 spec discussion]，最终成为[紧凑区块过滤器][topic compact block filters]的 [BIP157][] 和 [BIP158][] 规范。这能显著改善轻量级客户端的隐私，尽管相比当前流行的方法，它确实会增加带宽、CPU 和内存需求。对全节点而言，它把拒绝服务风险降到简单的带宽耗尽攻击，而节点已经可以用带宽限速选项来应对。虽然服务器端部分早在 2018 年就已在 [btcd][btcd #1180] 中合并，并且大约同一时期也被提议加入 Bitcoin Core，但直到 2020 年，该协议的 P2P 部分才[分阶段][news98 bcc18877]合并进 Bitcoin Core，[从五月][news100 bcc19010]持续到[八月][news111 bcc19070]，最终让节点运营者只需启用两个配置选项，就能选择创建并提供紧凑区块过滤器。

<div markdown="1" class="callout" id="releases">

### 2020 年总结<br>热门基础设施项目的重要发布

- [LND 0.9.0-beta][] 于 1 月发布，改进了访问控制列表机制（“macaroons”），增加了接收[多路径支付][topic multipath payments]的支持，增加了在加密洋葱消息中发送附加数据的能力，并允许在请求关闭通道时让输出支付到指定地址（例如你的硬件钱包）。

- [LND 0.10.0-beta][] 于 5 月发布，增加了发送多路径支付的支持，允许通过 [PSBT][topic psbt] 用外部钱包为通道注资，并开始支持创建超过 0.043 BTC 的[大额发票][topic large channels]。

- [Eclair 0.4][] 于 5 月发布，增加了与最新版 Bitcoin Core 的兼容性，并弃用了 Eclair Node GUI（建议用户改用 Phoenix 或 Eclair Mobile）。

- [Bitcoin Core 0.20.0][] 于 6 月发布，开始为 RPC 用户默认使用 bech32 地址，允许为不同用户和应用程序配置 RPC 权限，并在 GUI 中增加了一些生成 PSBT 的基础支持。

- [C-Lightning 0.9.0][] 于 8 月发布，提供了更新后的 `pay` 命令，以及一个通过 LN 发送消息的 RPC。

- [LND 0.11.0-beta][] 于 8 月发布，允许接收[大额通道][topic large channels]。

</div>

## 六月

六月是漏洞发现和讨论格外活跃的一个月，尽管许多问题更早被发现、或更晚才完全披露。值得注意的漏洞包括：

- **<!--overpayment-attack-on-multi-input-segwit-transactions-->**[多输入 segwit 交易的超额支付攻击：][attack overpay segwit] 六月，Trezor 宣布 Saleem Rashid 发现了 segwit 在防止手续费超额支付攻击方面的一个弱点。手续费超额支付攻击是比特币原始交易格式中一个众所周知的弱点：签名并不承诺输入的价值，攻击者因此可以诱骗专用签名设备（如硬件钱包）花掉比预期更多的钱。segwit 试图让每个签名都承诺其所花费输入的金额，以此消除这个问题。然而，Rashid 重新发现了一个此前由 Gregory Sanders 在 2017 年发现并报告的问题：只要用户能被诱骗签署同一笔交易的两个或更多看似相同的版本，一笔至少有两个输入的特殊构造交易就能绕过这一限制。一些开发者认为这是个小问题——如果能让用户签两次，那也能让他向收款方付两次钱，同样会损失资金。尽管如此，几家硬件钱包制造商还是发布了新固件，对 segwit 交易施加了他们此前成功用来防止传统交易手续费超额支付的同一套保护。在某些情况下，例如 ColdCard 钱包，这项安全改进是以不破坏现有流程的方式实现的。在另一些硬件钱包里，该实现破坏了与现有工作流程的兼容性，迫使 [BIP174][] 的 PSBT 规范以及 Electrum、Bitcoin Core、HWI 等软件做出更新。

  ![手续费超额支付攻击示意图](/img/posts/2020-06-fee-overpayment-attack.dot.png)

- **<!--ln-payment-atomicity-attack-->**[LN 支付原子性攻击：][attack ln atomicity] LN 开发者一直致力于实现[锚定输出][topic anchor outputs]协议，以消除交易费率快速上涨带来的风险；在推进过程中，该协议的关键贡献者之一 Matt Corallo 发现它会引入一个新的漏洞。恶意对手方可以尝试用较低的费率结算一笔 LN 支付（[HTLC][topic htlc]），并配合一种[交易钉住][topic transaction pinning]手法，使这笔交易或对它的手续费追加无法很快得到确认。确认被延迟会让 HTLC 的超时到期，攻击者因此能拿回自己付给诚实对手方的资金。人们[提出了][atomicity attack discussion]多种解决方案，从修改 LN 协议，到第三方市场，再到[软分叉共识变更][rubin fee sponsorship]，但目前还没有哪一种获得显著支持。

- **<!--fast-ln-eclipse-attacks-->**[针对 LN 的快速日食攻击：][attack time dilation] 从 Satoshi Nakamoto 到今天的比特币协议专家都清楚，一个与所有诚实对等节点隔离的节点可能被骗去接受无法花费的比特币，这类问题有时被称为[日食攻击][topic eclipse attacks]。六月，Gleb Naumenko 和 Antoine Riard 发表了一篇论文，说明日食攻击在短短两小时内就能从 LN 节点窃取资金——不过要从连接着自己全验证节点的 LN 节点窃取，则需要更长时间。作者建议实现更多防范日食攻击的方法，而今年 Bitcoin Core 项目在这方面确实取得了几项积极进展。

- **<!--ln-fee-ransom-->**[LN 手续费勒索攻击：][attack ln fee ransom] René Pickhardt 向 Lightning-Dev 邮件列表公开披露了一个漏洞，而他大约一年前已私下报告给 LN 各实现的维护者。恶意通道对手方可以在一个 LN 通道中发起最多 483 笔支付（HTLC），然后关闭通道，产生一笔约占整个区块 2% 大小的链上交易，而它所需的手续费要由诚实节点支付。几个 LN 节点已实现简单的缓解措施，使用[锚定输出][topic anchor outputs]预计也会有帮助，但至今还没有人提出全面的解决方案。

- **<!--concern-about-htlc-mining-incentives-->**[关于 HTLC 挖矿激励的担忧：][attack htlc incentives] 六月下旬和七月上旬，人们讨论了两篇关于带外 HTLC 贿赂的论文。[HTLC][topic htlc] 是用于保障 LN 支付、跨链原子互换以及其他若干无需信任交换协议的合约。它的运作方式是：给收款用户一段时间，在这段时间里他拥有凭公开一段秘密数据来领取支付的独占权利；时间到期后，付款用户可以取回这笔支付。这两篇论文考察了这样一种风险：付款用户可以贿赂矿工，让矿工公开那段秘密数据，却不确认包含该数据的交易，从而使时间锁过期——这样付款方既拿回了钱，又仍然知道了秘密。开发者 ZmnSCPxj 提醒研究者注意一种应当能防止此类问题的已知机制，他曾帮助在 C-Lightning 中[实现][cl3870]该机制。这个办法在理论上可行，但使用它会花费用户的金钱，因此仍鼓励研究更好的解决方案。

- **<!--inventory-out-of-memory-denial-of-service-attack-invdos-->**[库存内存耗尽拒绝服务攻击（InvDoS）：][attack invdos] 这一攻击最初于 2018 年被发现，影响 Bcoin 和 Bitcoin Core 全节点，当时已得到负责任的披露和修复；2020 年 6 月人们重新评估它，发现它同样适用于 Btcd 全节点。攻击者可以向受害节点灌入大量新交易公告（`inv` 消息），每条消息几乎都包含允许的最大数量交易哈希。当这类公告排队过多时，受害节点的内存就会耗尽并崩溃。在 Btcd 修复该问题、并留出时间让用户升级之后，这个漏洞被公开披露。

{:#wabisabi}
六月也有一些好消息：研究 Wasabi coinjoin 实现的一个团队[宣布][news102 wasabi]了一种名为 WabiSabi 的协议，它应当能让无需信任的、由服务器协调的 coinjoin 支持任意输出金额。这让使用协调式 coinjoin 发送支付变得更容易，无论是在 coinjoin 参与者之间，还是向非参与者付款。Wasabi 开发者在今年余下的时间里一直在推进该协议的实现。

## 七月

{:#wtxid-announcements}
七月，关于 wtxid 交易公告的 [BIP339][] 规范被[合并][bips933]。过去，节点用交易基于哈希的标识符（txid）来宣布有新未确认交易可供中继；但在 2016 年审查提议的 segwit 代码时，Peter Todd [发现][todd segwit review]，恶意节点可以通过使交易中不属于其 txid 的见证数据失效，让网络上的其他节点忽略一位无辜用户的交易。当时实现了一个[快速修复][Bitcoin Core #8312]，但它有一些小缺点，开发者知道最好的解决方案——尽管有其[复杂性][bcc19569]——是用见证 txid（wtxid）来宣布新交易。BIP339 被加入 BIPs 仓库后不到一个月，wtxid 公告就被[合并][bcc18044]进 Bitcoin Core。虽然这看似只是个小问题、对用户也没有明显影响，但 wtxid 公告简化了人们所期待的那些升级的开发，例如[交易包中继][topic package relay]。

## 八月

{:#signet}
经过[一年多][bips900][bips983]的[开发][default signet discussion]（其间还有多次由反馈驱动的改动），[BIP325][] 中 [signet][topic signet] 规范的[最后一次重大修订][bips947]在八月初被合并。signet 既是一种让开发者创建公共测试网络的协议，也是那个主要公共 signet 的名字。与比特币现有的公共测试网络（testnet）不同，signet 的区块必须由受信任的一方签名。这避免了破坏行为以及其他问题——那些问题之所以出现，是因为 testnet 即便测试币没有价值，也仍然使用比特币基于经济激励的共识收敛机制（工作量证明）。可选择启用 signet 的能力最终在九月被[加入][bcc18267] Bitcoin Core。

{:#anchor-outputs}
在 Matt Corallo [首次提出][news24 cpfp carve out] [CPFP 豁免（carve-out）机制][topic cpfp carve out]将近两年后，LN 规范被[更新][news112 bolts688]，允许创建利用 carve-out 来保障安全的[锚定输出][topic anchor outputs]。锚定输出使得即使某一方试图用[交易钉住][topic transaction pinning]攻击来阻止手续费追加，多方交易仍能进行手续费追加。在对抗环境下也能追加手续费的能力，让 LN 节点可以接受链下交易，而不必担心未来费率上涨。如果之后需要广播那笔链下交易，节点可以在广播时为其选择合适的费率。这简化了 LN 协议，并改善了其安全性的多个方面。

<div markdown="1" class="callout" id="optech">

### 2020 年总结<br>Bitcoin Optech

在 Optech 成立的第三年，新增了 10 家成员公司<!-- Veriphi, SwanBitcoin, YellowCardIO, Xbtogroup, Bitonic, Fidelity Center for Applied Technology, AndgoInc, BTSEcom, EdgeWallet, Bitbank_inc -->，我们在伦敦举办了一场 [Taproot 工作坊][taproot workshop]，发布了 51 期每周 Newsletter<!-- 78 to 129 -->，在我们的[话题索引][topics index]中新增了 20 个页面，向我们的[兼容性索引][compatibility index]中添加了多个新钱包和服务，并发布了几篇关于比特币扩展技术的[博客文章][optech blog posts]。

</div>

## 九月

{:#glv-endomorphism}
在 [2011 年的一篇论坛帖子][finney glv]中，比特币早期贡献者 Hal Finney 描述了一种由 Gallant、Lambert 和 Vanstone 提出的 GLV 方法，用以减少验证比特币交易签名所需的昂贵计算次数。Finney 写了一个概念验证实现，声称它把签名验证速度提高了约 25%。不幸的是，该算法受[美国专利 7,110,538][U.S.  Patent 7,110,538]的束缚，因此无论是 Finney 的实现，还是 Pieter Wuille 后来的实现，都没有分发给用户。9 月 25 日，[该专利到期][news117 patent]。不到一个月，相关代码就被[合并][news120 glv]进 Bitcoin Core。对使用默认设置的用户来说，这种速度提升在同步新节点的最后阶段，或节点离线一段时间后验证区块时最为明显。Finney 已于 2014 年去世，但我们依然感激他为让密码学技术被广泛使用所做的二十年工作。

{:#patent-alliance}
Square [宣布][copa announced]成立加密货币开放专利联盟（COPA），以协调与加密货币技术相关的专利汇集。成员允许任何人自由使用他们的专利，作为交换，他们获得使用专利池中的专利来抵御专利攻击者的能力。截至本文撰写时，该联盟已有 [18 个成员][copa membership]：ARK.io、Bithyve、Blockchain Commons、Blockstack、Blockstream、Carnes Validadas、Cloudeya Ltd.、Coinbase、Foundation Devices、Horizontal Systems、Kraken、Mercury Cash、Protocol Labs、Request Network、SatoshiLabs、Square、Transparent Systems 和 VerifyChain。

## 十月

{:#jamming}
十月，LN 开发者围绕解决[最早在 2015 年描述][russell loop]的堵塞问题以及相关问题的讨论明显增多。LN 节点可以让一笔支付经由 20 跳或更多跳的路径路由给自己。这让拥有 1 BTC 的攻击者可以暂时锁住其他用户 20 BTC 甚至更多的资金。锁住别人的钱几个小时后，攻击者可以取消这笔支付，并拿回全部手续费，使这种攻击基本上是免费的。另一个相关的问题是：攻击者通过一连串通道发送 483 笔小额支付，而 483 是一个通道最多能容纳的待处理支付数。在这种情况下，拥有两个各含 483 个槽位的通道的攻击者可以堵住超过 10,000 个诚实连接槽位——同样不必支付任何手续费。人们讨论了[多种][news120 upfront]可能的解决方案，包括由付款方支付给路径上每个节点的*前向预付手续费*、由每一跳支付给上一跳的[后向预付手续费][news86 backwards upfront]、[前向与后向手续费的组合][news122 bidir fees]、[嵌套增量路由][news119 nested routing]，以及[忠诚债券][news126 routing fibonds]。遗憾的是，讨论过的这些方法都没有获得广泛认可，问题至今仍未解决。

{:.center}
![LN 流动性与 HTLC 堵塞攻击示意图](/img/posts/2020-12-ln-jamming-attacks.png)

{:#lnd-disclosures}
十月，Antoine Riard 在四月发现并报告的两项针对 LND 的窃取资金攻击被[完全披露][news121 riard disclosures]。在一种情况下，LND 可能被骗去接受无效数据；在另一种情况下，它可能被骗去泄露秘密数据。得益于 Riard 的负责任披露和 LND 团队的响应，我们不知道有哪位用户因此损失了资金。LN 规范针对[这两][news123 high-s][个问题][news124 htlc release]都做了更新，以帮助新实现避开它们。

{:#generic-signmessage}
在最初的 segwit 提案提出五年多、其激活三年之后，仍然没有一种通用方式来创建和验证用 P2WPKH 或 P2SH-P2WPKH 地址对应密钥签名的纯文本消息。这个问题更普遍地存在：对 P2SH、P2WSH 和 P2SH-P2WSH 地址也没有广泛支持的消息处理方式——也没有一种能适用于 taproot 地址的前向兼容方式。旨在提供[通用消息签名][topic generic signmessage]功能的 [BIP322][] 提案试图解决上述所有问题，但一直没能获得多少支持。今年，它的倡导者再次[征求反馈][news88 signmessage rfh]，提出了一个[简化方案][news91 signmessage simplification]，并在十月对其核心机制做了几乎[彻底的替换][news118 signmessage update proposal]。[新机制][news121 signmessage update bip]允许签署*虚拟交易*——它们看起来像真实交易，但按比特币共识规则无效，因此可以安全签署——从而使消息签名有可能兼容大量现有软件、硬件钱包以及 [PSBT][topic psbt] 数据格式。希望这项改进能让通用消息签名开始被采用。

{:#musig2}
十月，Jonas Nick、Tim Ruffing 和 Yannick Seurin [发表][news120 musig2]了 MuSig2 论文，描述了 [MuSig][topic musig] 签名方案的一种新变体，其签名协议只有两轮，且不需要零知识证明。更进一步，借助一种非交互式签名变体，第一轮（随机数交换）可以在密钥设置阶段完成，这对冷存储和 LN 这类链下合约协议可能特别有用。

{:#addrv2}
同样在十月，Bitcoin Core 成为第一个[合并][bcc19954][版本 2 `addr` 消息][topic addr v2]实现的项目。`addr` 消息广播潜在对等节点的网络地址，让全节点无需任何中心化协调就能发现新对等节点。最初的比特币 `addr` 消息设计用来容纳 128 位 IPv6 地址，这也让它能包含经过编码的 IPv4 地址和版本 2 Tor 洋葱地址。在生产环境中运行近 15 年后，Tor 项目弃用了版本 2 洋葱服务，并将在 2021 年 7 月停止支持。较新的版本 3 洋葱地址是 256 位，因此无法用于原始的 `addr` 消息。[BIP155][] 对 `addr` 消息的升级为 Tor 地址提供了更大容量，也让需要更大地址的其他匿名网络成为可能。

## 十一月

{:#lightning-pool}
正如二月部分提到的，当前 LN 网络面临的一个挑战是：用户和商户需要具有入站容量的通道，才能通过 LN 收款。一个完全去中心化的解决方案可能是前面介绍过的双向资助通道。不过，Lightning Labs 在十一月走了另一条路，[宣布][news123 lightning pool]推出新的 Lightning Pool 市场，用于购买入站 LN 通道。一些现有节点运营者已经在提供入站通道，有的免费、有的收费，而 Lightning Pool 或许能借助其集中协调的市场，让这项服务更加标准化、更具竞争性。等双向资助通道可用后，它也有可能升级为与之配合使用。

## 十二月

{:#ln-offers}
去年，Rusty Russell 发布了一份关于 LN *offers* 的[提议规范][bolt12 draft]初稿。借助 offers，付款节点可以通过洋葱路由的 LN 网络向收款节点请求发票。现有的 [BOLT11][] 虽然提供了发票协议，但不允许付款方和收款方节点之间进行任何协议层面的协商。offers 将使节点能够传递附加信息，并把目前需要人工干预或额外工具的支付步骤自动化。例如，offers 可以让 LN 节点通过让付款方节点每月向收款方节点请求一张新发票，来管理周期性支付或捐赠。2020 年 12 月，Russell 为 C-Lightning 实现 offers 的一系列提交中的第一个被[合并][news128 offers]。

## 总结

总结过去一年的事件，我们最喜欢的一点是：每一点进步都已经切实实现。上面的总结并不包含关于比特币未来会做什么的承诺——它只列出过去 12 个月里真正取得的成就。2020 年，比特币的贡献者们有许多值得骄傲的地方。我们迫不及待想看看他们在 2021 年为我们准备了什么。

*Optech Newsletter 将于 1 月 6 日恢复常规的周三发布安排。*

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
[compatibility index]: /en/compatibility/
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
