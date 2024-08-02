---
title: 'Bitcoin Optech Newsletter #16: Scaling Bitcoin Special'
permalink: /zh/newsletters/2018/10/09/
name: 2018-10-09-newsletter-zh
slug: 2018-10-09-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的 Newsletter 完全由上周末在 Scaling Bitcoin 工作坊上发表的几个值得注意的演讲摘要组成，因为在我们通常的行动项、新闻和值得注意的代码变更部分几乎没有什么可报告的。我们希望下周回归我们通常的格式。

## 工作坊摘要：Scaling Bitcoin V (东京 2018)

第五届 Scaling Bitcoin 会议于上周六和周日在日本东京举行。在下面的部分中，我们提供了一些我们认为本期 Newsletter 读者可能最感兴趣的演讲的简要概述，但我们也推荐观看由工作坊组织者提供的一整套[视频][videos]，或阅读 Bryan Bishop 提供的[文本记录][transcripts]。

为方便起见，在每个摘要的末尾，我们直接链接到其视频和文本记录（如果有的话）。以下按照工作坊日程中的出现顺序列出演讲。

**警告：** 以下摘要可能包含错误，因为许多演讲描述的主题远远超出了摘要作者的专业知识。

### 调整比特币的区块补贴

*Anthony (AJ) Towns 的研究*

此次演讲对比特币是否为安全支付了过多的费用进行了智力探究——如果我们认为确实支付过多，我们能做些什么。演讲者明确表示，他有兴趣考虑这些问题并提供可能的答案，但他既没有表明存在问题，也没有主张任何解决方案。

如果比特币用户群认为他们为安全支付了过多的费用，演讲提出了短期内减少补贴金额的选项，随着安全性的增加——但仍确保总共不超过 2100 万个比特币的补贴——可能允许补贴比目前预期的持续更长时间。

虽然演讲不是关于一个具体的提议，但它评估的一个示例提议是每当网络的工作量证明安全性翻倍时（通过区块创建难度衡量），就将补贴减少20%。

*[视频][vid subsidy], [文本记录][tx subsidy]*

### 前向区块：不通过硬分叉实现链上容量增加

*Mark Friedenbach 的研究*

增加比特币区块大小的一种众所周知的软分叉方法是扩展区块——一种对未升级到软分叉的节点不可见的数据结构，因此不受它们对区块大小的历史限制。就其本身而言，这是一种增加区块大小的不受欢迎的方法，因为阻止旧节点看到扩展区块中的交易，也阻止它们能够强制执行对这些交易的任何其他共识规则——例如阻止恶意用户花费其他用户的比特币或创建超过 2100 万比特币发行计划允许的比特币数量的规则。

然而，增加区块大小并不是增加每分钟可以添加到区块链上的数据量的唯一方法——通过增加区块的频率（减少区块之间的平均时间）也可以增加容量。一种操纵比特币难度调整算法的方法——称为时间扭曲攻击——在专家中众所周知，并已在针对比特币测试网的演示攻击和针对山寨币的真实攻击中成功使用。（注：尽管技术上比特币容易受到此攻击，但这将是一种缓慢的攻击，将给用户群提供大量的响应时间。）就其本身而言，增加区块频率也是增加容量的一种不受欢迎的方法，因为较短的区块间隔增加了拥有大量哈希率的矿工的有效性，因此可能会增加挖矿集中的风险。[^freq-pow-waste]

也许是为了反驳“两个错误不能使一件事变得正确”，这次演讲描述了一种将扩展区块和时间扭曲攻击结合起来的新颖方法，允许升级节点和旧节点获得相同的容量增加并验证所有相同的交易，同时略微降低挖矿集中风险。升级节点将验证一个或多个提供额外区块空间的扩展区块（称为“前向区块”，forward blocks），这些区块以降低集中化风险的 15 分钟平均间隔为特点，但升级节点也将限制传统区块中的时间戳，以确保永久性（但有限的）时间扭曲攻击增加了传统区块的频率，足以允许它们包含之前出现在前向区块中的相同交易。

*[视频][vid forward blocks]，[文本记录][tx forward blocks]，[论文][paper forward blocks]*

### 压缩多签名以减小区块链大小

*Dan Boneh、Manu Drijvers 和 Gregory Neven 的研究*

这次演讲描述了 [MuSig 论文][MuSig paper] 中描述的 Schnorr 签名方案的一种替代方案，该方案利用了[基于配对的密码学][pairing-based cryptography]，具体来说是 [Boneh-Lynn-Shacham (BLS) 签名方案][bls sigs] 的一个改编。尽管基于配对的方案需要比比特币当前的 ECDSA 方案和提议的 Schnorr 方案更多的基本安全假设，但作者提出了证据表明，他们的方案通常会产生更小的签名，允许非交互式签名聚合，并使得可能证明集合中的哪些签名者实际上一起工作来创建阈值签名（例如，k-of-m 签名者，例如 2-of-3 多签）。

*[视频][vid bls msig]，[文本记录][tx bls msig]，[论文（预印本）][paper bls msig]*

### 累加器：一种可扩展的替代默克尔树的方案

*Benedikt Bünz、Benjamin Fisch 和 Dan Boneh 的研究*

在比特币和其他加密货币中，通常使用默克尔树对信息集合（如交易或 UTXOs）进行可扩展的承诺，默克尔树允许通过生成一个大小和验证成本大约为 *log2(n)* 的证明来证明一个元素是集合的成员，其中 *n* 是集合中元素的数量。

这次演讲描述了一种基于 RSA 累加器的替代方法，提供了潜在的好处：无论集合中有多少元素，证明的大小都是恒定的，而且从累加器中添加或删除元素可以高效地批处理（例如，每个区块进行一次更新）。

*[视频][vid accumulators]，[文本记录][tx accumulators]*

### 多方 ECDSA 用于无脚本的闪电网络支付通道

*Conner Fromknecht 的研究*

闪电网络使用的可路由支付通道目前使用来自 Script 语言的多个操作码，这些操作码受到比特币共识规则的强制执行。Andrew Poelstra 之前关于[无脚本脚本][scriptless scripts transcript]的工作[表明][ln scriptless scripts]，目前使用的一些或所有操作码都可以被 Schnorr 公钥和签名替代，这些公钥和签名将在支付通道的参与者之间私下（offchain）创建。共识规则仍然要求花费交易具有引用已知公钥的有效签名，但所有其他与安全相关的信息都不会出现在链上，从而减少了数据消耗和费用，提高了隐私和可替代性，可能还提高了安全性。

比特币目前不支持 Schnorr 签名，也没有提出完整的设计（尽管这样的提案可能不远了），因此这次演讲描述了与比特币当前的 ECDSA 密钥和签名兼容的支付通道无脚本脚本的部分实现的概念验证结果。在脚本和见证数据的大小上取得了一些令人印象深刻的节省——这些节省增加了可以在一个区块中打开或关闭的通道的数量，并减少了闪电网络支付通道用户支付的交易费用。

*[视频][vid scriptless ecdsa]，[文本记录][tx scriptless ecdsa]*

## 讨论：比特币脚本的演变

一个专注于此主题的两小时讨论小组提到了对比特币 Script 语言的大量提议变更——太多了，以至于即使是摘要也无法在这里提及。然而，有几个变更被提及，如果社区愿意采纳，理论上可能在 2019 年实现：

- **<!--schnorr-signature-scheme-->****Schnorr 签名方案：** 一种可选功能，在所有情况下都提供更小的签名，更快的验证，合作多签的公钥和签名数据大大减小，以及与无脚本脚本的更容易兼容。参见 Pieter Wuille 的[提议 BIP][schnorr pre-bip]。

- **<!--sighash-noinput-unsafe-->****SIGHASH_NOINPUT_UNSAFE：** 创建花费而不显式引用您想要花费的输出的能力。允许使用[Eltoo 协议][Eltoo protocol]创建更高效的支付通道，该协议还使每个通道易于支持多达 150 个参与者。参见 [BIP118][]。

- **<!--op-checksigfromstack-->****OP_CHECKSIGFROMSTACK：** 可以创建限制特定币可支付的输出契约。例如，您可以对冷钱包的支出设置一个为期一周的强制超时。在超时期间，您只能将币再次支付回您的冷钱包。但如果您等待超时期过去，您可以将币支付给任何任意地址。这意味着，如果有人窃取了您的冷钱包私钥副本，您可以使用这种机制来防止他们在超时期间通过将币返回到您的冷钱包来消费您的比特币。（有人指出，一些开发者出于可替代性原因反对启用这种操作码的最简单形式，尽管替代方法可能更可接受。）

- **<!--fixing-the-time-warp-bug-->****修复时间扭曲漏洞：** 控制大多数哈希率的一组矿工目前可以操纵比特币的难度调整算法，让他们在不增加总哈希率的情况下持续每十分钟创建一个区块。至少有一个简单的提议，不破坏旧软件或矿机的情况下，减少操纵的可能性。参见近期在 Bitcoin-Dev 邮件列表上的[电子邮件讨论][bitcoin-dev timewarp]。

- **<!--explicit-fees-->****明确费用：** 目前在比特币中，费用是通过聚合输入的价值和聚合输出的价值之间的差异来隐含的。然而，交易也可以另外明确承诺费用，并允许其中一个输出设置为聚合输入的价值与明确费用加上所有其他输出的和之间的差值。这可能有助于奖励代表离线用户发送违约补救交易的闪电网络哨兵，或者对费用提升的集团交易有用。

然而，讨论小组的一位成员认为，“唯一对软分叉感到舒适的人不太可能提出软分叉并产生被采纳的软件。人们将反对增加任何东西，尤其是考虑到最近的 [CVE][CVE-2018-17144]。未来 6 个月人们将会更加保守。再过 6 个月人们才会开始考虑它。我认为我们明年不会有任何新的软分叉。”

*(无视频)，[文本记录][tx script]*

## 特别感谢

我们感谢 Andrew Poelstra、Anthony Towns、Bryan Bishop 和 Pieter Wuille 提供了与本通讯内容相关的建议或回答问题。任何剩余的错误完全是通讯作者的责任。

## 脚注

[^freq-pow-waste]:
    当矿工在链的顶端创建一个新区块时，他可以立即开始工作在下一个区块上——但是每个其他矿工仍然在处理旧的区块，直到他们接收到新区块，这意味着在这段短暂的时间内他们的工作量证明是被浪费的（既没有增加网络安全性也没有为矿工提供财务补偿）。拥有更多哈希率的矿工平均产生更多的区块，因此他们更频繁地获得领先优势，他们的工作量证明浪费较少。

    对于两个世界两端的完全公平的矿工来说，他们之间的最小实际网络延迟大约是 0.2 秒，这意味着远离大多数其他矿工的小型矿工在 600.0 秒（十分钟）的平均区块时间里可能只有 599.8 秒是生产效率的。0.2/600.0 的效率损失（0.03%）可能是可以接受的，但如果增加了区块频率，效率损失也会增加：每分钟一个区块时，效率损失将是 0.33%；每六秒一个区块时，3.33%。

    小型矿工可以通过移动到其他矿工更近的地方来提高他们的效率，甚至通过与他们合并完全消除效率损失，但这是比特币中必须避免的挖矿集中化，如果我们想防止矿工能够轻易地审查哪些交易被包含在区块中。

{% include references.md %}

[videos]: https://tokyo2018.scalingbitcoin.org/#remote-participation
[transcripts]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/
[vid subsidy]: https://youtu.be/y8hJ0VTPE34?t=39
[tx subsidy]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/playing-with-fire-adjusting-bitcoin-block-subsidy/
[vid forward blocks]: https://youtu.be/y8hJ0VTPE34?t=3744
[tx forward blocks]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/forward-blocks/
[paper forward blocks]: http://freico.in/forward-blocks-scalingbitcoin-paper.pdf
[vid bls msig]: https://youtu.be/IMzLa9B1_3E?t=29
[tx bls msig]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/compact-multi-signatures-for-smaller-blockchains/
[paper bls msig]: https://eprint.iacr.org/2018/483.pdf
[vid accumulators]: https://youtu.be/IMzLa9B1_3E?t=3522
[tx accumulators]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/accumulators/
[vid scriptless ecdsa]: https://youtu.be/3mJURLD2XS8?t=3624
[tx scriptless ecdsa]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/scriptless-ecdsa/
[tx script]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/bitcoin-script/
[musig paper]: https://eprint.iacr.org/2018/068
[schnorr pre-bip]: https://github.com/sipa/bips/blob/bip-schnorr/bip-schnorr.mediawiki
[pairing-based cryptography]: https://en.wikipedia.org/wiki/Pairing-based_cryptography
[bls sigs]: https://en.wikipedia.org/wiki/Boneh%E2%80%93Lynn%E2%80%93Shacham
[scriptless scripts transcript]: https://scalingbitcoin.org/transcript/stanford2017/using-the-chain-for-what-chains-are-good-for
[eltoo protocol]: https://blockstream.com/2018/04/30/eltoo-next-lightning.html
[bitcoin-dev timewarp]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016316.html
[ln scriptless scripts]: https://lists.launchpad.net/mimblewimble/msg00086.html
[cve-2018-17144]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2018-17144
