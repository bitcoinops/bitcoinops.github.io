---
title: 'Bitcoin Optech Newsletter #29'
permalink: /zh/newsletters/2019/01/15/
name: 2019-01-15-newsletter-zh
slug: 2019-01-15-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 宣布了 C-Lightning 的安全升级，描述了一篇关于意外泄露私钥的钱包的论文及额外研究，并列出了一些流行的比特币基础设施项目中值得注意的代码更改。

## 行动项

- **<!--upgrade-to-c-lightning-0-6-3-->****升级到 C-Lightning 0.6.3：** 这个[版本][cl 0.6.3]修复了一个可以用来使 C-Lightning 节点崩溃并可能窃取资金的远程 DoS 漏洞。详情请参阅下文的*值得注意的代码更改*部分。此版本还包括其他不太严重的错误修复和新功能。

## 新闻

- **<!--weak-signature-nonces-discovered-->****发现弱签名随机数：** 研究人员 Joachim Breitner 和 Nadia Heninger 的一篇预印本[论文][weak nonces]描述了他们如何通过寻找使用小于 256 位预期熵的随机数生成的签名发现了数百个比特币私钥。Gregory Maxwell 的独立[代码考古][gmaxwell bitcore]表明，主要罪魁祸首可能是 BitPay Bitcore 软件，该软件在 2014 年 7 月左右引入了一个漏洞，并在大约一个月后发布了修复程序。（注意：BitPay Bitcore 与 Bitcoin Core 无关。）从那时起，该漏洞传播到依赖 Bitcore 的软件如 BitPay Copay。论文中发现的约 97% 的错误签名与 Maxwell 的 Copay 假设兼容，并且该论文为其余 3% 的签名提供了合理的解释，这表明只要用户不继续使用通过早期漏洞程序花费比特币的地址，现代钱包的用户可能是安全的。

  如果你曾使用受影响版本的 Bitcore（0.1.28 到 0.1.35）、Copay（0.4.1 到 0.4.3）或其他易受攻击的软件，你应该创建一个新钱包文件，将所有资金从旧钱包文件发送到新钱包中的地址，并停止使用以前的钱包文件。在设计签署比特币交易的软件时，你应该优先使用生成签名随机数的同行评审实现，如实现了 [RFC6979][] 的 [libsecp256k1][]。

  论文作者使用的快速分析方法利用了进行地址重用的用户，但即使是没有重用的地址的密钥，如果随机数生成有偏或太小，也容易受到攻击。这可以通过对多次使用的密钥使用相同的方法（例如，用于 Replace-By-Fee）或简单地使用[大步小步算法][baby-step giant-step]或[Pollard 的 Rho][Pollard's Rho]方法进行暴力破解来实现。

## 值得注意的代码更改

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo] 和 [libsecp256k1][libsecp256k1 repo] 中值得注意的代码更改。*

- [Bitcoin Core #15039][] 如果节点看到的最近区块的时间戳早于 8 小时，将禁用基于 nLockTime 的反手续费狙击（anti-fee-sniping）。反手续费狙击试图平衡诚实矿工简单扩展区块链和不诚实矿工创建链分叉以从诚实矿工那里窃取手续费的优势。然而，当使用反手续费狙击时，离线一段时间的节点不知道链顶端的区块是什么，因此它们可以离线创建多个交易，所有这些交易都会使用相同的非常旧的 nLockTime 值，在区块链分析中将这些交易链接在一起。此合并通过在节点离线时间过长时禁用该功能来修复此问题。

- [C-Lightning #2214][] 修复了一个可能导致资金损失的远程崩溃漏洞。**建议所有用户升级到 0.6.3 以修复此问题。**

  该漏洞允许对等方通过尝试让你接受比你的节点允许的时间锁更短的支付来使你的 C-Lightning 节点崩溃。如果崩溃的节点长时间关闭，如果攻击者之前与该节点打开了通道，则可能被攻击者窃取。不过需要注意的是，攻击者必须冒着自己的资金进行攻击，因此节点可以假装离线以从任何攻击者那里获取资金——这被认为是足以阻止大多数攻击的风险。

- [C-Lightning #2230][] 更新了 `listpeers` RPC 的“channel”输出，以包含一个 `private` 标志，指示通道是否正在向对等方宣布。

- [C-Lightning #2244][] 默认禁用插件，但添加了一个配置选项 `--enable-plugins` 以在启动时启用它们。插件可能会在未来的版本中默认重新启用，当整个插件 API 实现完成时。

- [Eclair #797][] 更改了计算支付路径的方式。以前，路径是从支付方到接收方计算的；现在它们是从接收方到支付方计算的。这修复了节点误算手续费的问题。


{% include references.md %}
{% include linkers/issues.md issues="15039,2214,2230,2244,797" %}
[gmaxwell bitcore]: https://bitcoin.stackexchange.com/questions/83559/what-is-the-origin-of-insecure-64-bit-nonces-in-signatures-in-the-bitcoin-chain/
[weak nonces]: https://eprint.iacr.org/2019/023.pdf
[RFC6979]: https://tools.ietf.org/html/rfc6979
[cl 0.6.3]: https://github.com/ElementsProject/lightning/releases/tag/v0.6.3
[baby-step giant-step]: https://en.wikipedia.org/wiki/Baby-step_giant-step
[pollard's rho]: https://en.wikipedia.org/wiki/Pollard%27s_rho_algorithm