---
title: 'Bitcoin Optech Newsletter #273'
permalink: /zh/newsletters/2023/10/18/
name: 2023-10-18-newsletter-zh
slug: 2023-10-18-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的新闻简单提及了最近一项影响闪电网络用户的安全披露，介绍了一篇关于根据任意程序的运行结果进行支付的论文，并公告了一份为 MuSig2 增设 PSBT 字段的 BIP 提议。此外就是我们的常规栏目：客户端和服务的优化总结、新版本和候选版本公告，以及热门的比特币基础设施软件的重大变更简介。

## 新闻

- **<!--security-disclosure-of-issue-affecting-ln-->影响闪电网络的安全问题披露**：Antoine Riard 在 Bitcoin-Dev 和 Lightning-Dev 邮件组中[发帖][riard cve]，完整披露了一项他曾经[尽责披露][topic responsible disclosures]给比特币协议以及多个热门的闪电节点实现的开发者的安全问题。Core Lightning、Eclair、LDK 和 LND 的最新版本都已经包含了让攻击更难实现的缓解措施，虽然这些措施无法完全消除最根本的顾虑。

    此次披露是在 Optech 的新闻部分的惯例截止时间之后发生的，所以我们只能在本栏目中提供上述链接。我们会在下周的新闻栏目中按照惯例提供一份总结。{% assign timestamp="1:09" %}

- **<!--payments-contingent-on-arbitrary-computation-->根据任意计算的结果支付**：Robin Linus 在 Bitcoin-Dev 邮件组中[发帖][linus post]，列出了一份他撰写的关于 *BitVM* 的[论文][linus paper]；BitVM 组合了许多方法，允许比特币支付给一个成功证明某个任意程序成功执行的结果的人。重要的是，这在当前的比特币上就能够实现 —— 不需要共识变更。

    再提供一些背景。比特币的一个众所周知的特性是要求某人来满足一个程序表达式（叫做 “*脚本（script）*”），以花费跟这个脚本相关联的比特币。举个例子，一个包含了某个公钥的脚本仅能被相关的私钥所创建的、承诺到一笔花费交易的签名满足。脚本必须使用比特币的语言（称为 “ *Script* ”）来编写，以便由共识来强制执行。但是 Script 的灵活性是被有意限制的。

    Linus 的论文绕开某一些限制。如果 Alice 相信 Bob 会在程序不正确运行时采取行动，但不希望在别的事情上信任他，她可以将资金存放到一棵 [taproot][topic taproot] 脚本树上，这个脚本树将允许 Bob 在能够证明 Alice 错误地运行了某个（任意灵活的）程序时取走其中的资金。如果 Alice 正确地运行了承诺，那么她就可以花费这笔资金，即便 Bob 尝试阻止她，也不可能成功。

    为了使用一个任意程序，这个程序必须被打散成非常基本的单元（[与非门][NAND gate]），并且需要为每一个门制作一个承诺。这需要双方在链下交换非常多的数据，甚至可能一个非常基础的任意程序就需要交换几个 GB 的数据 —— 但在 Bob 认同 Alice 正确运行了程序的时候，Alice 和 Bob 只需在链上使用一笔交易，就可以结算。而在 Bob 不认可的时候，他需要在非常少的几笔链上交易中证明 Alice 的错误。如果这套装置是在 Alice 和 Bob 之间的支付通道中执行的，那么多个程序可以并行执行，当然也可以串行执行，而不会产生链上足迹，除了通道建立、合作关闭或者强制关闭（Bob 尝试证明 Alice 没有按照任意程序的逻辑正确地执行）以外。

    在 Alice 和 Bob 是天然对手的时候，BitVM 可以免信任地应用，比如，他们可以把钱交给一个输出，然后让这个输出支付给双方的一局象棋比赛的赢家。然后，他们可以使用两个（几乎一摸一样）的任意程序，两个都以相同的行棋步骤的任何集合作为输入。一个会在 Alice 胜出时返回 True，而另一个会在 Bob 胜出时返回 True。然后，一方会发布一条链上交易，声称自己这方的程序会输出 True（也就是自己赢了比赛），而另一方要么接受（愿赌服输），要么证明对手在欺诈（如果成功，将能追回资金）。在 Alice 和 Bob 不是天然对手的时候，Alice 也许可以激励 Bob 来验证计算的正确性，例如，向 Bob 承诺只需要他能证明自己没有正确运行计算，就把钱给他。

    这个想法在邮件组、 Twitter 和多个关注比特币的播客中收到了大量的讨论，我们预期未来的几周乃至几个月，讨论会继续发酵。{% assign timestamp="8:15" %}

- **<!--proposed-bip-for-musig2-fields-in-psbts-->提议为 PSBT 加入 MuSig2 字段的 BIP**：Andrew Chow 在 Bitcoin-Dev 邮件组中[发帖][chow mpsbt]了一份[BIP 草案][mpsbt-bip]，部分基于 Sanket Kanjalkar [之前的工作][kanjalkar mpsbt]，要求在 [PSBTs][topic psbt] 的所有版本中添加几个字段，以放置 “公钥、公开 nonce 值，以及使用 [MuSig2][topic musig] 产生的碎片签名”。

    Anthony Towns [询问][towns mpsbt] 这个 BIP 提议是否也会为 “[适配器签名][topic adaptor signatures]” 添加字段，但后续的讨论暗示，这可能需要一个单独的 BIP 来定义。{% assign timestamp="26:44" %}

## 服务和客户端软件的改变

*在这个月度栏目中，我们将列举比特币钱包和服务的有趣升级*。

- **<!--bip329-python-library-released-->BIP-329 Python 库发布**：[BIP-329 Python 库][BIP-329 Python Library] 是一组工具，可以阅读、撰写、加密和解密兼容 [BIP329][] 的钱包标签文件。{% assign timestamp="29:10" %}

- **<!--ln-testing-tool-doppler-announced-->闪电网络测试工具 Doppler 推出**：刚刚[宣布][doppler announced]，[Doppler][] 支持使用一种 “域名专属语言（DSL）” 来定义比特币和闪电节点的网络拓扑以及 链上/链下 的支付活动，以同时测试 LND、CLN 和 Eclair 实现。{% assign timestamp="30:19" %}

- **<!--coldcard-mk4-v520-released-->Coldcard Mk4 v5.2.0 发布**：这个固件[升级][coldcard blog]包含对 [BIP370][] 版本 2 [PSBTs][topic psbt] 的支持，对 [BIP39][] 的额外支持，以及多项有关种子词的功能。{% assign timestamp="31:54" %}

- **<!--tapleaf-circuits-a-bitvm-demo-->Tapleaf circuits：一个 BitVM 样品**：[Tapleaf circuits][] 是使用本周新闻栏目所述的 BitVM 方法实现 Bristol 电路的一个概念验证实现。{% assign timestamp="32:27" %}

- **<!--samourai-wallet-09998i-released-->Samourai 钱包 0.99.98i 发布**：这个 [0.99.98i][samourai blog] 版本包含了额外的 PSBT、UTXO 标签和批量发送特性支持。{% assign timestamp="34:24" %}

- **<!--krux-signing-device-firmware-->Krux：签名设备固件**：[Krux][krux github] 是一个开源的固件项目，致力于开发使用商用硬件的硬件签名器。{% assign timestamp="35:12" %}

## 新版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本，或者帮助测试候选版本。*

- [Bitcoin Core 24.2rc2][] 和 [Bitcoin Core 25.1rc1][] 是 Bitcoin Core 的维护版本的候选版本。{% assign timestamp="36:06" %}

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo] 和 [Bitcoin Inquisition][bitcoin inquisition repo]。*

- [Bitcoin Core #27255][] 将 [miniscript][topic miniscript] 移植成 [tapscript][topic tapscript]。这个代码变更让 P2TR [输出描述符][topic descriptors] 也可以使用 miniscript，添加了观察和签名 “TapMiniscript 描述符” 的支持。以前，miniscript 仅能用在 P2WSH 输出描述符中。这个 PR 的作者指出，引入了一个新的、专属于 P2TR 描述符的 `multi_a` 片段，以匹配 `multi` 在 P2WSH 描述符中的语义。这个 PR 的讨论也指出，大量的工作都花费在正确地跟踪 tapscript 所改变的资源花费限制上。{% assign timestamp="38:07" %}

- [Eclair #2703][] 会在节点的余额较低，可能需要拒绝转发支付的时候，劝阻花费者通过这个节点来转发支付。这是通过让节点广告自己调低了的 HTLC 数额上限来实现的。防止支付被拒绝可以提升花费者的体验，并帮助避免节点被寻路系统惩罚（该系统会对近期转发支付失败的节点降低评级）。{% assign timestamp="45:54" %}

- [LND #7267][] 现在可以对 “[盲化路径][topic rv routing]” 创建路由，这让 LND 离完全支持盲化支付又近了许多。{% assign timestamp="47:06" %}

- [BDK #1041][] 加入了一个模块，用于使用 Bitcoin Core 的 RPC 接口、获得关于区块链的数据。{% assign timestamp="47:39" %}


{% include references.md %}
{% include linkers/issues.md v=2 issues="27255,2703,7267,1041" %}
[linus post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/021984.html
[linus paper]: https://bitvm.org/bitvm.pdf
[nand gate]: https://en.wikipedia.org/wiki/NAND_gate
[Bitcoin Core 24.2rc2]: https://bitcoincore.org/bin/bitcoin-core-24.2/
[Bitcoin Core 25.1rc1]: https://bitcoincore.org/bin/bitcoin-core-25.1/
[riard cve]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/021999.html
[mpsbt-bip]: https://github.com/achow101/bips/blob/musig2-psbt/bip-musig2-psbt.mediawiki
[kanjalkar mpsbt]: https://gist.github.com/sanket1729/4b525c6049f4d9e034d27368c49f28a6
[chow mpsbt]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/021988.html
[towns mpsbt]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/021991.html
[BIP-329 Python Library]: https://github.com/Labelbase/python-bip329
[Doppler]: https://github.com/tee8z/doppler
[doppler announced]: https://twitter.com/voltage_cloud/status/1712171748144070863
[coldcard blog]: https://blog.coinkite.com/5.2.0-seed-vault/
[Tapleaf circuits]: https://github.com/supertestnet/tapleaf-circuits
[samourai blog]: https://blog.samourai.is/wallet-update-0-99-98i/
[krux github]: https://github.com/selfcustody/krux
