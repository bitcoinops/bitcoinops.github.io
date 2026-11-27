---
title: 'Bitcoin Optech Newsletter #16: Scaling Bitcoin Special'
permalink: /zh/newsletters/2018/10/09/
name: 2018-10-09-newsletter-zh
slug: 2018-10-09-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本期 Newsletter 完全由几篇值得注意的演讲摘要组成，这些演讲是上周末在 Scaling Bitcoin 工作坊上发表的；因为我们通常的行动项、新闻和值得注意的代码变更这几个部分几乎没有什么可报告的。我们希望下周恢复通常的格式。

## 工作坊摘要：Scaling Bitcoin V (东京 2018)

第五届 Scaling Bitcoin 会议于上周六和周日在日本东京举行。下面几节简要概述了我们认为是本期 Newsletter 读者最感兴趣的一些演讲。同时我们也推荐观看工作坊组织者提供的整套[视频][videos]，或阅读 Bryan Bishop 提供的[文字记录][transcripts]。

为方便起见，每个摘要末尾都会直接给出发言视频和文字记录（以及论文，如果有的话）的链接。以下按演讲在工作坊日程中出现的顺序排列。

**警告：** 以下摘要可能含有错误，因为许多演讲所涉主题远远超出了摘要作者的专业领域。

### 调整比特币的区块补贴

*Anthony (AJ) Towns 的研究*

此次演讲做了一次思辨性探讨：比特币为安全付出的代价是否超过了必要——以及如果我们断定它确实付得太多，能做些什么。演讲者明确表示，他只想探讨这些问题并给出可能的答案，既不认为真的存在问题，也不主张任何解决方案。

如果比特币用户群确实认为自己为安全付出的代价过高，演讲就提出了几种方案：随着安全性的提升，短期内减少补贴的发放量——但仍确保补贴总额不超过 2100 万个比特币——从而可能让补贴维持得比目前预期的长久得多。

虽然演讲并未围绕某个具体提案，但它评估了一个示例提案：每当网络的工作量证明安全性翻倍（以出块难度衡量），就把补贴减少 20%。

*[视频][vid subsidy]，[文本记录][tx subsidy]*

### 前向区块：不通过硬分叉实现链上容量增加

*Mark Friedenbach 的研究*

一种广为人知的、通过软分叉增加比特币区块大小的方法是扩展区块——这是一种对尚未升级到该软分叉的节点不可见的数据结构，因此不受这些节点对区块大小的历史上限约束。单看这一点，它并不是增加区块大小的理想方法，因为不让旧节点看到扩展区块中的交易，也就使它们无法对这些交易执行任何其他共识规则——例如防止恶意用户花掉他人的比特币，或防止其创造出超过 2100 万比特币补贴计划所允许数量的比特币的规则。

不过，要提高每分钟加入区块链的数据量，并不一定得增大区块大小——提高出块频率（缩短平均出块间隔）同样可以提升容量。一种操纵比特币难度调整算法的手法——称为时间扭曲攻击——在专家中广为人知，并且已在针对比特币测试网的演示攻击、以及针对山寨币的真实攻击中被成功使用。（注：尽管比特币在技术上确实易受这种攻击，但它会是一种缓慢的攻击，用户群有充足的时间做出反应。）单看这一点，提高出块频率同样不是增加容量的理想方式，因为更短的出块间隔会放大拥有大量算力的矿工的效率优势，因此很可能加剧挖矿中心化。[^freq-pow-waste]

这次演讲或许恰好推翻了“两个错误凑不成一个正确”的说法：它描述了一种新颖的方法，把扩展区块与时间扭曲攻击结合起来，让升级节点和旧节点获得相同的容量提升、并验证完全相同的交易，同时还略微降低了挖矿中心化风险。升级节点将验证一个或多个提供额外区块空间的扩展区块（称为“前向区块”，forward blocks），这些区块的平均出块间隔为 15 分钟，有助于降低中心化；但升级节点还会限制传统区块（legacy blocks）中的时间戳，以确保一个永久性（但幅度有限）的时间扭曲攻击能提高传统区块的出块频率，足以让这些区块包含此前出现在前向区块中的相同交易。

*[视频][vid forward blocks]，[文本记录][tx forward blocks]，[论文][paper forward blocks]*

### 压缩多重签名以减小区块链大小

*Dan Boneh、Manu Drijvers 和 Gregory Neven 的研究*

这次演讲介绍了一种替代 [MuSig 论文][MuSig paper] 所述 Schnorr 签名方案的方案，它使用[基于配对的密码学][pairing-based cryptography]，具体而言是 [Boneh-Lynn-Shacham（BLS）签名方案][bls sigs] 的一个改编版本。尽管基于配对的方案要比比特币当前的 ECDSA 方案和拟议的 Schnorr 方案多引入一个基础安全假设，但作者给出的证据表明，他们的方案通常能产生更小的签名，支持非交互式签名聚合，并且能够证明签名者集合中究竟哪些成员实际参与了阈值签名的生成（即 k-of-m 签名者，例如 2-of-3 多重签名）。

*[视频][vid bls msig]，[文本记录][tx bls msig]，[论文（预印本）][paper bls msig]*

### 累加器：一种可扩展的替代默克尔树的方案

*Benedikt Bünz、Benjamin Fisch 和 Dan Boneh 的研究*

在比特币和其他加密货币中，对信息集合（例如交易或 UTXO）的可扩展承诺通常用默克尔树实现：要证明某个元素属于该集合，只需生成一个证明，其大小和验证成本对含 *n* 个元素的集合而言大致为 *log2(n)*。

这次演讲介绍了一种基于 RSA 累加器的替代方法，它带来一些潜在好处：无论集合中有多少元素，证明的大小都是固定的；向累加器添加或删除元素可以高效批处理（例如每个区块只更新一次）。

*[视频][vid accumulators]，[文本记录][tx accumulators]*

### 多方 ECDSA 用于无脚本的闪电网络支付通道

*Conner Fromknecht 的研究*

闪电网络所用的可路由支付通道，目前依赖 Script 语言中的多个操作码，并由比特币共识规则强制执行。Andrew Poelstra 此前关于[无脚本脚本][scriptless scripts transcript]的工作[表明][ln scriptless scripts]，目前用到的一些乃至全部操作码，都可以替换为由通道参与者在私下（链下）创建的 Schnorr 公钥和签名。共识规则仍会要求花费交易携带一个引用已知公钥的有效签名，但其他与安全相关的信息都不会出现在链上，从而降低数据占用和手续费，提升隐私性与可替代性，并有可能提升安全性。

比特币目前尚不支持 Schnorr 签名，也还没有提出完整的设计（不过这样的提案可能为时不远），因此这次演讲介绍了支付通道无脚本脚本的一个部分实现的概念验证结果，该实现与比特币当前的 ECDSA 密钥和签名兼容。脚本和见证数据的大小都实现了可观的节省——这既增加了单个区块中能打开或关闭的通道数量，也降低了闪电网络支付通道用户支付的交易手续费。

*[视频][vid scriptless ecdsa]，[文本记录][tx scriptless ecdsa]*

## 讨论：比特币脚本的演变

一个围绕该主题的两小时讨论小组提到了对比特币 Script 语言的各种提议变更——数量太多，即便只做摘要也无法在此一一列出。不过，有几项变更被认为如果社区愿意采纳，理论上可以在 2019 年实现：

- **<!--schnorr-signature-scheme-->****Schnorr 签名方案：** 一种可选启用的功能，即在任何情况下都能提供更小的签名、更快的验证速度；对协作式多重签名而言，公钥和签名数据大幅缩小；与无脚本脚本的兼容也更容易。参见 Pieter Wuille 的[提议 BIP][schnorr pre-bip]。

- **<!--sighash-noinput-unsafe-->****SIGHASH_NOINPUT_UNSAFE：** 无需显式指明要花费哪个输出，就能构造花费交易。这样可以借助 [Eltoo 协议][Eltoo protocol] 创建更高效的支付通道，而该协议还让每个通道都能轻松支持多达 150 个参与者。参见 [BIP118][]。

- **<!--op-checksigfromstack-->****OP_CHECKSIGFROMSTACK：** 可以创建契约（covenant），限制某个币能花费到哪些输出。例如，你可以为冷钱包的支出设置一周的强制超时。在超时期间，你只能把币花回自己的冷钱包；但如果你等到超时结束，就可以把币花到任意地址。这意味着，如果有人偷走了你冷钱包私钥的副本，你可以用这套机制，在超时期间把币退回冷钱包，从而阻止对方花掉你的比特币。（有人指出，一些开发者出于可替代性考虑，反对启用这种操作码的最简单形式，不过其他做法可能更容易被接受。）

- **<!--fixing-the-time-warp-bug-->****修复时间扭曲漏洞：** 目前，控制多数算力的一组矿工可以操纵比特币的难度调整算法，从而在不提高总算力的情况下，稳定地每十分钟产出不止一个区块。至少有一个简单的提案，可以在不破坏旧软件或矿机的前提下减少可操纵的空间。参见近期 Bitcoin-Dev 邮件列表上的[邮件讨论][bitcoin-dev timewarp]。

- **<!--explicit-fees-->****显式手续费：** 目前在比特币中，手续费是由所有输入价值之和与所有输出价值之和的差额隐含表示的。不过，交易也可以改为显式承诺手续费，并让其中一个输出的金额等于输入价值总和减去显式手续费与其他所有输出之和后的差额。这或许有助于奖励代表离线用户广播违约补救交易的闪电网络瞭望塔（watchtower），也可能对整组交易的手续费追加（fee bumping）有用。

然而，讨论小组的一位成员认为：“对软分叉最熟悉的那批人，恰恰不太可能提出软分叉并写出会被采纳的软件。人们会反对任何新增的东西，尤其是考虑到最近的 [CVE][CVE-2018-17144]。接下来 6 个月里，人们会明显更加保守。要再过 6 个月，人们才会开始考虑这件事。我认为明年不会有任何新的软分叉。”

*(无视频)，[文本记录][tx script]*

## 特别感谢

我们感谢 Andrew Poelstra、Anthony Towns、Bryan Bishop 和 Pieter Wuille 就本期 Newsletter 的内容提供建议或回答问题。任何残余错误完全是本刊作者的责任。

## 脚注

[^freq-pow-waste]:
    当矿工在链尖创建一个新区块时，他可以立刻着手下一个区块——但其他所有矿工在收到这个新块之前仍在处理旧块，也就是说，他们在这段短暂时间里的工作量证明被浪费了（既没有增强网络安全，也没有给矿工带来经济回报）。算力更多的矿工平均产出更多区块，因此更频繁地抢到领先优势，被浪费的工作量证明也更少。

    对两个分处地球两端、条件完全对等的矿工来说，彼此之间实际能达到的最小网络延迟约为 0.2 秒；这意味着一个远离大多数其他矿工的小矿工，在平均 600.0 秒（十分钟）的出块间隔里，可能只有 599.8 秒是有效产出的。0.2/600.0 的效率损失（0.03%）大概可以接受，但如果提高出块频率，效率损失也会随之增加：每分钟一个区块时为 0.33%；每六秒一个区块时为 3.33%。

    小矿工可以搬到离其他矿工更近的地方来提高效率，甚至通过与它们合并彻底消除效率损失；但这正是比特币必须避免的挖矿中心化——如果我们不希望矿工能够轻易审查哪些交易被打包进区块的话。

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
[bitcoin-dev timewarp]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016316.html
[ln scriptless scripts]: https://lists.launchpad.net/mimblewimble/msg00086.html
[cve-2018-17144]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2018-17144
