---
title: 'Bitcoin Optech Newsletter #29'
permalink: /zh/newsletters/2019/01/15/
name: 2019-01-15-newsletter-zh
slug: 2019-01-15-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 宣布了 C-Lightning 的安全升级，介绍了一篇关于意外泄露私钥的钱包的论文以及后续研究，并列出了一些热门比特币基础设施项目中值得注意的代码变更。

## 行动项

- **<!--upgrade-to-c-lightning-0-6-3-->****升级到 C-Lightning 0.6.3：** 这个[版本][cl 0.6.3]修复了一个远程 DoS 漏洞，攻击者可以利用它让 C-Lightning 节点崩溃，并可能窃取资金。详情请参阅下文的*值得注意的代码变更*部分。此版本还包括其他不太严重的错误修复和新功能。

## 新闻

- **<!--weak-signature-nonces-discovered-->****发现弱签名随机数：** 研究人员 Joachim Breitner 和 Nadia Heninger 的一篇预印本[论文][weak nonces]描述了他们的发现过程：寻找那些用熵低于预期 256 位的随机数生成的签名，由此恢复了数百个比特币私钥。Gregory Maxwell 独立的[代码考古][gmaxwell bitcore]表明，主要元凶很可能是 BitPay Bitcore 软件，它在 2014 年 7 月左右引入了一个错误，并在大约一个月后发布了修复。（注意：BitPay Bitcore 与 Bitcoin Core 无关。）该错误随后传播到依赖 Bitcore 的软件，例如 BitPay Copay。论文中发现的有问题的签名约有 97% 与 Maxwell 的 Copay 假设相符，论文也对其余 3% 的签名给出了大部分合理的解释。这说明现代钱包的用户大概是安全的，前提是他们不再继续使用那些曾用早期有漏洞的程序花费过其中比特币的地址。

  如果你曾使用受影响版本的 Bitcore（0.1.28 到 0.1.35）、Copay（0.4.1 到 0.4.3）或其他有漏洞的软件，就应该新建一个钱包文件，把旧钱包文件里的全部资金发送到新钱包中的地址，并停止使用原来的钱包文件。在设计签署比特币交易的软件时，你应优先选用经过同行评审、能确定性生成签名随机数的实现，例如实现了 [RFC6979][] 的 [libsecp256k1][]。

  论文作者采用的快速分析方法，利用的是那些重复使用地址的用户；但即使地址没有被重复使用，只要随机数生成有偏或过小，其密钥同样会遭到攻击。攻击方式既可以是对于多次使用过的密钥沿用同样的方法（例如用于手续费替换（RBF）），也可以直接用[大步小步算法][baby-step giant-step]或 [Pollard's Rho 算法][Pollard's Rho]暴力破解。

## 值得注意的代码变更

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo] 和 [libsecp256k1][libsecp256k1 repo] 中值得注意的代码变更。*

- [Bitcoin Core #15039][] 当节点所见最近一个区块的时间戳已是 8 小时或更早之前时，就禁用基于 nLockTime 的反手续费狙击（anti-fee-sniping）。反手续费狙击试图拉平两类矿工之间的优势：诚实矿工只是延长区块链，而不诚实矿工会制造链分叉，试图从诚实矿工那里窃取手续费。然而，使用反手续费狙击时，离线一段时间的节点不知道链顶端的区块是哪一个，因此它们可能离线创建多笔交易，而这些交易都会使用同一个非常旧的 nLockTime 值，在区块链分析中把它们联系在一起。这次合并通过在节点离线过久时禁用该功能解决了这个问题。

- [C-Lightning #2214][] 修复了一个可导致资金损失的远程崩溃漏洞。**建议所有用户升级到 0.6.3 以修复此问题。**

  该漏洞允许对等节点让你接受一笔时间锁小于你节点所允许值的支付，从而使你的 C-Lightning 节点崩溃。如果崩溃的节点长时间保持关闭状态，那么此前与该节点开过通道的攻击者就有可能从它那里偷走资金。不过要注意，攻击者必须拿自己的资金去冒险才能发起攻击，因此节点可以假装离线，反过来拿走攻击者的资金——人们希望这样的风险足以让大多数攻击者望而却步。

- [C-Lightning #2230][] 更新了 `listpeers` RPC 的“channel”输出，新增 `private` 标志，用来表明该通道是否正在向对等节点公开宣布。

- [C-Lightning #2244][] 默认禁用插件，但新增了配置选项 `--enable-plugins`，可在启动时启用插件。等到整个插件 API 都实现之后，未来的版本可能会重新默认启用插件。

- [Eclair #797][] 改变了支付路径的计算方式。以前路径是从付款方算到收款方，现在则从收款方算到付款方。这修复了节点算错手续费的问题。


{% include references.md %}
{% include linkers/issues.md issues="15039,2214,2230,2244,797" %}
[gmaxwell bitcore]: https://bitcoin.stackexchange.com/questions/83559/what-is-the-origin-of-insecure-64-bit-nonces-in-signatures-in-the-bitcoin-chain/
[weak nonces]: https://eprint.iacr.org/2019/023.pdf
[RFC6979]: https://tools.ietf.org/html/rfc6979
[cl 0.6.3]: https://github.com/ElementsProject/lightning/releases/tag/v0.6.3
[baby-step giant-step]: https://en.wikipedia.org/wiki/Baby-step_giant-step
[pollard's rho]: https://en.wikipedia.org/wiki/Pollard%27s_rho_algorithm