---
title: 'Bitcoin Optech Newsletter #55'
permalink: /zh/newsletters/2019/07/17/
name: 2019-07-17-newsletter-zh
slug: 2019-07-17-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了关于更新 LN gossip 协议的一项提案。此外，还包括我们常规的 bech32 发送支持部分，以及流行比特币基础设施项目中值得注意的变更。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

*本周无行动项。*

## 新闻

- **<!--gossip-update-proposal-->****Gossip 更新提案：** Rusty Russell 提出了一个[简短提案][v2 gossip proposal]，用于更新 LN 节点公布其有哪些通道可路由支付、以及这些通道当前支持哪些能力的 gossip 协议。最值得注意的是，该提案通过两种机制显著减小了消息的字节数：schnorr 签名和可选消息扩展。基于 [bip-schnorr][] 的 schnorr 签名与 DER 编码的 ECDSA 签名相比，编码更高效，因此能省下几个字节；但在这个 gossip 改进提案中，省得最多的是用 [MuSig][] 把通道公告的两个签名聚合为一个签名。使用类型-长度-值（Type-Length-Value，TLV）记录的可选消息扩展，则可以在沿用协议默认值时省略不必要的细节（关于 TLV 的更多信息，请参见下文*值得注意的代码与文档变更*部分）。

## Bech32 发送支持

*这是共 24 周的[系列][bech32 series]中的第 18 周，目的是让你支付的对象也能获得隔离见证的全部好处。*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/zh/18-support-issues.md %}

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo] 中值得注意的变更。*

- [Bitcoin Core #15277][] 让 Linux 版本的 Bitcoin Core 可以用 [GNU Guix][]（读作“geeks”）进行确定性编译。相比目前仍受支持的、基于 [Gitian][] 的机制，这种方式所需的配置少得多，因此有望让更多用户可以独立验证：发布的二进制文件只源自 Bitcoin Core 源代码及其依赖项。此外，Guix 需要的构建环境依赖项更少，而且正在进行的工作目标是从典型构建工具链中基本上消除它对任何预编译二进制文件的依赖，这两点都让构建系统更容易审计。总的来说，这应当减少用户需要对 Bitcoin Core 开发者、以及用于构建 Bitcoin Core 的软件所给予的信任。尽管这个已合并的 PR 只构建 Linux 二进制文件，但预计之后会支持 Windows 和 macOS。更多信息请参阅该 PR 作者 Carl Dong 最近在 Breaking Bitcoin 会议上的演讲（[视频][guix vid]，[文字记录][guix transcript]）。

- [BOLTs #607][] 扩展了 LN 规范，允许数据包包含一种记录：以标识用途的*类型*开头，后跟消息的*长度*和记录的*值*，称为 TLV 记录。由于每条消息都以类型和长度开头，LN 节点可以忽略类型自己不理解的记录，例如规范中比节点更新的可选部分，或只有部分节点在用的实验性记录（因此这些记录还不属于规范）。现有的 LN 记录尚未改为使用 TLV，但后续新增的可选记录预计会采用这种格式。Optech 监控的所有 LN 实现目前至少在其开发分支上支持 TLV。

- [BIPs #784][] 更新了 [BIP174][] 部分签名比特币交易（PSBT），在全局部分中加入 [BIP32][] 扩展公钥（xpub）字段。该 BIP 新增的“找零检测”一节描述了签名钱包如何使用这个新字段来识别哪些输出属于该钱包（是完全属于该钱包，还是属于使用多重签名的一组钱包的一部分）。这一规范修改的想法之前在 Bitcoin-Dev 邮件列表中讨论过，如 [Newsletter #46][] 所述。

{% include linkers/issues.md issues="607,16237,784,15277" %}
[bech32 series]: /zh/bech32-sending-support/
[v2 gossip proposal]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-July/002065.html
[Gitian]: https://github.com/devrandom/gitian-builder
[GNU Guix]: https://www.gnu.org/software/guix/
[guix vid]: https://www.youtube.com/watch?v=DKOG0BQMmmg&feature=youtu.be&t=19828
[guix transcript]: http://diyhpl.us/wiki/transcripts/breaking-bitcoin/2019/bitcoin-build-system/
[newsletter #46]: /zh/newsletters/2019/05/14/#addition-of-derivation-paths-to-bip174-psbts
[musig]: https://eprint.iacr.org/2018/068
