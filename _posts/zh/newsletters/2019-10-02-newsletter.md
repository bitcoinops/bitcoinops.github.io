---
title: 'Bitcoin Optech Newsletter #66'
permalink: /zh/newsletters/2019/10/02/
name: 2019-10-02-newsletter-zh
slug: 2019-10-02-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 提到一份拟议的 BIP，它允许节点实现 Erlay 交易中继协议；宣布全面披露曾影响旧版 LN 实现的若干漏洞；给出最近一次 Optech schnorr 与 taproot 工作坊的文字记录链接；并附上一篇实地报告，介绍比特币交易所 BTSE 为节省区块链空间、同时保障用户存款安全所采用的若干技术。我们还会介绍热门比特币基础设施项目的多项值得注意的变更。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

*本周没有行动项。*

## 新闻

- **<!--draft-bip-for-enabling-erlay-compatibility-->****支持 Erlay 兼容性的 BIP 草案：**Erlay 的共同作者 Gleb Naumenko 在 Bitcoin-Dev 邮件列表上[发布][reconcil post]了一份[关于通过集合对账实现交易中继的 BIP 草案][bip-reconcil]。目前，比特币节点会把所有新看到的交易 txid 发给每一个对等节点，结果每个节点都会收到大量重复的 txid 通告。对比特币网络数以万计的节点和每天几十万笔交易来说，这种做法在带宽上相当不划算。另一种做法如之前[介绍][erlay paper]的那样：基于 minisketch 的集合对账让节点发送一组短 txid 的 *sketch*，接收方将其与自己已知的短 txid 组合，就能还原出尚未见过的那些短 txid。sketch 的大小大致等于预期需要还原的短 txid 的大小，从而减少通告 txid 占用的带宽。Erlay 就是这样一项提案：它提出如何利用该机制，在带宽效率和网络健壮性之间取得最佳平衡。这份 BIP 草案描述了节点之间基于 minisketch 的集合对账的拟议实现，为 Erlay 的落地打下基础。欢迎任何有意见的人私下或通过邮件列表联系 BIP 作者。

- **<!--full-disclosure-of-fixed-vulnerabilities-affecting-multiple-ln-implementations-->****影响多个 LN 实现的已修复漏洞全面披露：**几周前，C-Lightning、Eclair 和 LND 的开发者分别宣布，他们在各自的实现中此前发现了一个未公开的问题，并已在最近的版本中修复。当时他们强烈建议用户升级（Optech [转达][optech ln warning]了这一信息），并承诺日后全面披露。现在这项工作已经完成：漏洞发现者、C-Lightning 开发者 Rusty Russell 发出一封[邮件][russell disclosure]，LND 开发者 Olaoluwa Osuntokun 与 Conner Fromknecht 则发表了一篇[博客文章][lnd stay safe]。

  简而言之，问题似乎是这些实现没有检查通道开启交易是否付给了正确的脚本、正确的金额，还是两者都正确。因此，这些实现会在通道内接受付款，事后却无法让这笔付款在链上得到确认，从而可能被欺诈。截至本文写作时，Optech 尚未听说任何报告表明该问题在上个月的警告之前被利用过。既然问题已经披露，已有一份 [PR][BOLTS #676] 提出更新规范，说明需要做这项检查。

- **<!--optech-taproot-and-schnorr-workshop-->****Optech taproot 与 schnorr 工作坊：**上周，Optech 在旧金山和纽约分别举办工作坊，向开发者讲解 schnorr 签名方案以及拟议中 [taproot][bip-taproot] 软分叉的其他内容。我们感谢 Bryan Bishop 为纽约工作坊整理了出色的[文字记录][workshop transcript]。我们正在准备视频和其他教学材料，不久后将通过一篇博客文章发布。

## 实地报告：BTSE 交易所使用的比特币技术

{% include articles/zh/dong-btse-operation.md %}

## 值得注意的代码和文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo] 的值得注意的变更。*

- [Bitcoin Core #15558][] 更改了 Bitcoin Core 通常查询的 DNS 种子数量。DNS 种子是由知名贡献者托管的服务器，会返回正在监听的对等节点（接受传入连接的对等节点）的 IP 地址。新启动的节点查询 DNS 种子，以获得一批初始对等节点；随后这些对等节点再告诉它其他可能的对等节点，节点会把这些信息存到磁盘上供日后使用（包括重启之后）。理想情况下，节点一辈子只会查询一次 DNS 种子——即首次启动时。但实际上，如果后续启动时它从已保存的对等节点中挑出的那些都没有及时响应，它也可能再次查询。

  这次合并使 Bitcoin Core 每次只查询三个 DNS 种子，而不是全部。三个种子的来源多样性足以确保节点至少连接到一个诚实的对等节点（这是比特币安全性的要求），而数量又足够少：如果节点采用直接 DNS 解析，并非每个种子都会因此知道是哪个节点在查询。要查询哪几个种子，从硬编码在 Bitcoin Core 中的列表里随机选取。

- [LND #3523][] 允许用户更新自己在某个已开通通道中、或在全部已开通通道中所能接受的 HTLC 最大 millisat 值。

- [LND #3505][] 把发票大小限制在 7,092 字节，也就是能放进单个二维码的最大尺寸。更大的发票可能导致分配大量内存。例如补丁作者测试的一张 1.7 MB 发票，就带来了约 38.0 MB 的内存分配。

- [Eclair #1097][] 开始从资金公钥派生通道密钥，使得即便所有数据都已丢失，Eclair 也能使用 [Newsletter #31][dlp footnote] 中描述的数据丢失保护（DLP）方案。不过这确实要求用户记得自己当初是与哪个节点开的通道，并找到通道 ID（对公开通道而言，通道 ID 是公开信息）。该改动只适用于升级到包含此项改动的软件版本之后新开的通道，旧通道不受影响。*(注意：本条目的上一版错误地声称这个已合并的 PR 能为 Eclair 加上 DLP 支持。实际上 Eclair 早已支持 DLP，这个 PR 改变的是通道密钥的派生方式，从而让该支持在所有数据丢失时也能派上用场。Optech 感谢 Fabrice Drouin 指出我们的错误。)*

- [C-Lightning #3057][] 让 C-Lightning 可以使用 postgres 作为其数据库管理器。

- [C-Lightning #3064][] 实现了 [Newsletter #63][ln daily updates] 中所述的改动，降低了 C-Lightning 节点中继其他节点通道更新通告的频率。这能减少节点消耗的 gossip 带宽。

{% include linkers/issues.md issues="15558,3523,3505,1097,3057,3064,676" %}
[lnd stay safe]: https://blog.lightning.engineering/security/2019/09/27/cve-2019-12999.html
[dlp footnote]: /zh/newsletters/2019/01/29/#fn:fn-data-loss-protect
[ln daily updates]: /zh/newsletters/2019/09/11/#request-for-comments-on-limiting-ln-gossip-updates-to-once-per-day
[bip-reconcil]: https://github.com/naumenkogs/bips/blob/bip-reconcil/bip-reconcil.mediawiki
[reconcil post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-September/017323.html
[erlay paper]: /zh/newsletters/2019/06/05/#erlay-proposed
[optech ln warning]: /zh/newsletters/2019/09/04/#upgrade-ln-implementations
[workshop transcript]: http://diyhpl.us/wiki/transcripts/bitcoinops/schnorr-taproot-workshop-2019/notes/
[russell disclosure]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-September/002174.html
[erlay]: https://arxiv.org/pdf/1905.10518.pdf
