---
title: 'Bitcoin Optech Newsletter #210'
permalink: /zh/newsletters/2022/07/27/
name: 2022-07-27-newsletter-zh
slug: 2022-07-27-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报描述了为非历史地址创建签名消息的 BIP 提议，并总结了关于可证的燃烧少量比特币以防护拒绝服务攻击的讨论。此外还有我们的常规部分，其中包含来自 Bitcoin Stack Exchange 的热门问题和答案、新版本和候选版本的公告，以及流行的比特币基础设施软件的重大变更总结。

## 新闻

- **<!--multiformat-single-sig-message-signing-->多格式单签名消息签名：**Bitcoin Core 和许多其他钱包长期以来一直支持密钥对一个 P2PKH 地址的任意消息进行签名和验证。而 Bitcoin Core 不支持对任何其他地址类型的任意消息进行签名或验证，包括单签名 P2SH-P2WPKH、原生 P2WPKH 和 P2TR 输出的地址。先前可以与任意脚本一起使用的、提供[完全通用的消息签名][topic generic signmessage]的 [BIP322][] 提议，尚未[被合并][bitcoin core #24058]到 Bitcoin Core 或被添加到任何其他我们所知的流行钱包。

    本周，Ali Sherief [提议][sherief gsm]用于 P2WPKH 的相同消息签名算法也可用于其他输出类型。对于验证，程序（如果需要）应当推断如何去派生密钥并用地址类型来验证签名。例如，当提供带有 20 字节数据元素的 [bech32][topic bech32] 地址时，假设它用于 P2WPKH 输出。

    开发人员 Peter Gray [指出][gray cc] ColdCard 钱包已经以这种方式创建签名。开发人员 Craig Raw [表示][raw sparrow] Sparrow Wallet 钱包可以验证它们，并且还遵循了 [BIP137][] 验证规则以及在 Electrum 中实现的一组略有不同的规则。

    Sherief 正计划编写一个 BIP 来详细说明该行为。

- **<!--proof-of-micro-burn-->微销毁的证明：**一些开发人员[讨论了][pomb]链上交易的用例和设计。该设计是按照一个小的增量来销毁比特币（“燃烧”比特币）作为资源消耗的证明。如果要展开 Ruben Somsen 的[讨论主题帖][somsen hashcash]中的一个示例用例，该思路是允许 100 个用户在他们的电子邮件中附加一个证明 1 美元比特币已被烧毁的证据，以提供反垃圾邮件的一种防护。这个思路最初也被描述为 [hashcash][] 的一种有益效果。

    上述讨论涉及到了几种使用默克尔树解决方案。然而一位受访者认为所涉及的少量销毁，可能会让参与者信任（或部分信任）中心化第三方成为避免不必要复杂性的一种合理方法。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案或是当我们有一些空闲时间来帮助好奇或困惑的用户时的首选地之一。在这个月度专题中，我们重点介绍了自上次更新以来发布的一些投票率最高的问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--why-do-invalid-signatures-in-op-checksigadd-not-push-to-the-stack-->为什么 `OP_CHECKSIGADD` 中的无效签名不推入堆栈？]({{bse}}114446)
  Chris Stewart 询问为什么“如果发现无效签名，解释器会执行失败而不是继续”。Pieter Wuille 解释说，这种行为在 BIP340-342 中定义，旨在支持将来对 [schnorr 签名][topic schnorr signatures]进行批量验证。 Andrew Chow 给出了该行为的另一个原因，指出这种方法也减轻了某些延展性问题。

- [<!--what-are-packages-in-bitcoin-core-and-what-is-their-use-case-->Bitcoin Core 中的包是什么，它们的用例是什么？]({{bse}}114305)Antoine Poinsot 解释了[交易包][bitcoin docs packages]（一组相关交易），它们与[交易包中继][topic package relay] 的关系，以及最近的[交易包中继 BIP 提议][news201 package relay]。

- [<!--how-much-blockspace-would-it-take-to-spend-the-complete-utxo-set-->使用掉完整的 UTXO 集需要多少区块空间？]({{bse}}114043)Murch 探讨了整合所有现有 UTXO 的假设场景。他计算了每种输出类型的区块空间，并得出结论该过程需要大约 11,500 个块。

- [<!--does-an-uneconomical-output-need-to-be-kept-in-the-utxo-set-->不经济的输出是否需要保留在 UTXO 集中？]({{bse}}114493)Stickies-v 指出，虽然从 UTXO 集中删除了确信不可用的 UTXO，包括 `OP_RETURN` 或大于脚本最大体积的脚本，但如果这些输出被花费，删除 [不经济的输出][topic uneconomical outputs]可能会导致问题，包括 Pieter Wuille 指出的硬分叉。

- [<!--is-there-code-in-libsecp256k1-that-should-be-moved-to-the-bitcoin-core-codebase-->libsecp256k1 中是否有代码应该移动到 Bitcoin Core 代码库？]({{bse}}114467)与其他将 Bitcoin Core 代码库各部分模块化的努力类似，例如 [libbitcoinkernel][libbitcoinkernel project] 或[进程分离][devwiki process separation]，Pieter Wuille 指出了 [libsecp256k1][] 项目的明确责任区域：任何涉及对私钥或公钥的操作。

- [<!--mining-stale-low-difficulty-blocks-as-a-dos-attack-->挖历史低难度区块的 DoS 攻击]({{bse}}114241) Andrew Chow 解释说 [assumevalid][assumevalid notes] 以及最近的 [`nMinimumChainWork`][Bitcoin Core #9053] 有助于过滤掉低难度链攻击。

## 软件的新版本和候选版本

*流行比特币基础设施项目的新版本和候选版本。请考虑升级到最新版本或帮助测试候选版本。*

- [BTCPay Server 1.6.3][] 为这个流行的自托管支付处理器添加了新功能、改进和错误修复。

- [LDK 0.0.110][] 向该库添加了多种新功能（许多在此前的周报中介绍过）用于构建启用闪电网络的应用程序。

## 重大代码及文档变更

*本周内，[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo] 和 [Lightning BOLTs][bolts repo] 出现的重大变更。*

- [Bitcoin Core #25351][] 确保在将地址、密钥或描述符导入钱包后，后续的重新扫描不仅会扫描区块链，还会评估内存池中的交易是否与该钱包相关。

- [Core Lightning #5370][] 重新实现了 `commando` 插件，并使其成为 CLN 内置的一部分。Commando 允许节点使用闪电网络消息接收来自授权节点的命令。节点使用 *runes*。进行授权。这是一种基于 [macaroons][] 简化版本的自定义 CLN 协议。尽管 Commando 现在已内置到 CLN 中，但它只有在用户创建 rune 身份验证令牌时才可操作。更多信息，请参阅 CLN 的 [commando][] 和 [commando-rune][] 手册。

- [BOLTs #1001][] 建议，广播了更改其支付转发策略的节点继续接受使用旧策略收到的付款约 10 分钟。这可以防止由于发送方不知道最近的策略更新而导致的付款失败。有关采用此类规则的实现示例，请参见 [周报 #169][news169 cln4806]。

{% include references.md %}
{% include linkers/issues.md v=2 issues="25351,5370,1001,24058,9053" %}
[BTCPay Server 1.6.3]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.6.3
[LDK 0.0.110]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.110
[commando]: https://github.com/rustyrussell/lightning/blob/2e13b72f55080be07ea68de77976eb990a043f5d/doc/lightning-commando.7.md
[commando-rune]: https://github.com/rustyrussell/lightning/blob/2e13b72f55080be07ea68de77976eb990a043f5d/doc/lightning-commando-rune.7.md
[news169 cln4806]: /en/newsletters/2021/10/06/#c-lightning-4806
[sherief gsm]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020759.html
[gray cc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020762.html
[raw sparrow]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020766.html
[pomb]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020745.html
[hashcash]: https://en.wikipedia.org/wiki/Hashcash
[somsen hashcash]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020746.html
[macaroons]: https://en.wikipedia.org/wiki/Macaroons_(computer_science)
[bitcoin docs packages]: https://github.com/bitcoin/bitcoin/blob/53b1a2426c58f709b5cc0281ef67c0d29fc78a93/doc/policy/packages.md#definitions
[news201 package relay]: /en/newsletters/2022/05/25/#package-relay-proposal
[libbitcoinkernel project]: https://github.com/bitcoin/bitcoin/issues/24303
[devwiki process separation]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/Process-Separation
[assumevalid notes]: https://bitcoincore.org/en/2017/03/08/release-0.14.0/#assumed-valid-blocks
