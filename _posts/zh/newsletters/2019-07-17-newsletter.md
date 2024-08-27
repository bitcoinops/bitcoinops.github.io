---
title: 'Bitcoin Optech Newsletter #55'
permalink: /zh/newsletters/2019/07/17/
name: 2019-07-17-newsletter-zh
slug: 2019-07-17-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了关于更新 LN gossip 协议的提案。此外，还包括了我们常规的 bech32 发送支持和流行的比特币基础设施项目中的值得注意的变化。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

*本周无行动项。*

## 新闻

- **<!--gossip-update-proposal-->****Gossip 更新提案：** Rusty Russell 提出了一个[简短提案][v2 gossip proposal]，旨在更新 LN 节点用来宣布其可用于支付路由的通道及其当前支持的功能的 gossip 协议。值得注意的是，该提案通过两种机制显著减少了消息的字节大小：schnorr 签名和可选消息扩展。基于 [bip-schnorr][] 的 Schnorr 签名相比于 DER 编码的 ECDSA 签名，因其更高效的编码节省了一些字节，但在 gossip 改进提案中，最显著的节省来自于使用 [MuSig][] 聚合通道公告的两个签名为单个签名。使用类型-长度-值（TLV）记录的可选消息扩展允许在使用协议默认值时省略不必要的细节（关于 TLV 的更多信息，请参见下文*值得注意的代码和文档变更*部分）。

## Bech32 发送支持

*第 24 周中的第 18 周，这一[系列][bech32 series]旨在帮助您支付的对象享受 segwit 的所有优势。*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/zh/18-support-issues.md %}

## 值得注意的代码和文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo] 和 [闪电 BOLTs][bolts repo] 中的值得注意的变化。*

- [Bitcoin Core #15277][] 允许 Linux 版本的 Bitcoin Core 使用 [GNU Guix][]（发音为“geeks”）进行确定性编译。这相比目前仍然支持的基于 [Gitian][] 的机制所需设置要少得多，因此希望能促使更多用户能够独立验证发布的二进制文件仅来自于 Bitcoin Core 源代码及其依赖项。此外，Guix 需要的构建环境依赖项更少，并且正在进行的工作旨在从根本上消除它对典型构建工具链中任何预编译二进制文件的需求，这些都使得构建系统更容易审计。总的来说，这应当减少用户对 Bitcoin Core 开发者以及用于构建 Bitcoin Core 的软件的信任需求。尽管该合并的拉取请求目前只构建 Linux 二进制文件，但预计很快会支持 Windows 和 macOS。有关更多信息，请参阅 PR 作者 Carl Dong 最近在 Breaking Bitcoin 会议上的演讲（[视频][guix vid]，[文字记录][guix transcript]）。

- [BOLTs #607][] 扩展了 LN 规范，允许数据包包含以*类型*标识其用途的记录，后跟消息的*长度*和记录的*值*，称为 TLV 记录。由于每条消息都以类型和长度开头，LN 节点可以忽略那些它们不理解的记录类型，例如规范中的可选部分（这些部分可能比节点更新）或仅由节点子集使用的实验记录，这些记录尚未成为规范的一部分。现有的 LN 记录尚未转换为 TLV 格式，但后续添加的可选记录预计将使用此格式。Optech 监控的所有 LN 实现目前都在其开发分支上支持 TLV。

- [BIPs #784][] 更新了 [BIP174][] 部分签名的比特币交易（PSBTs），在全局部分中加入了 [BIP32][] 扩展公钥（xpub）字段。新部分“变更检测”描述了签名钱包如何使用此新字段来识别哪些输出属于该钱包（无论是单独使用还是作为使用多重签名的一组钱包的一部分）。这一规范修改的想法之前在 Bitcoin-Dev 邮件列表中进行了讨论，如 [Newsletter #46][] 所述。

{% include linkers/issues.md issues="607,16237,784,15277" %}
[bech32 series]: /zh/bech32-sending-support/
[v2 gossip proposal]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-July/002065.html
[Gitian]: https://github.com/devrandom/gitian-builder
[GNU Guix]: https://www.gnu.org/software/guix/
[guix vid]: https://www.youtube.com/watch?v=DKOG0BQMmmg&feature=youtu.be&t=19828
[guix transcript]: http://diyhpl.us/wiki/transcripts/breaking-bitcoin/2019/bitcoin-build-system/
[newsletter #46]: /zh/newsletters/2019/05/14/#addition-of-derivation-paths-to-bip174-psbts
[musig]: https://eprint.iacr.org/2018/068
