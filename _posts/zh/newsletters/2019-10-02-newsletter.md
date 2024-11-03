---
title: 'Bitcoin Optech Newsletter #66'
permalink: /zh/newsletters/2019/10/02/
name: 2019-10-02-newsletter-zh
slug: 2019-10-02-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 提到了一项提议中的 BIP，它将允许节点实现 Erlay 交易转发协议，宣布了此前影响闪电网络实现的漏洞的全部披露，链接到了最近一次 Optech 关于 Schnorr 和 Taproot 研讨会的记录，并包含了一份关于比特币交易所 BTSE 使用的一些技术的实地报告，这些技术旨在节省区块链空间的同时确保用户存款的安全。我们还描述了多个流行的比特币基础设施项目的一些值得注意的变更。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

*本周没有行动项。*

## 新闻

- **<!--draft-bip-for-enabling-erlay-compatibility-->****支持 Erlay 兼容性的草案 BIP：**Gleb Naumenko（Erlay 的联合作者）在 Bitcoin-Dev 邮件列表上[发布][reconcil post]一份关于通过集合对账实现交易转发的草案 [BIP][bip-reconcil]。目前，比特币节点向每个对等节点发送所有新看到的交易 ID（txid），导致每个节点接收到大量重复的 txid 通知。这对于拥有数万个节点和每天数十万笔交易的比特币网络来说，带来了较低的带宽效率。另一种方式是，如之前[描述][erlay paper]的那样，基于 minisketch 的集合对账允许节点发送一组短 txid 的 *sketch*，接收节点可以将其与已经知道的短 txid 结合起来，恢复那些尚未看到的 txid。sketch 的大小大致等于需要恢复的短 txid 的预期大小，从而减少了 txid 通知的带宽。Erlay 是一个建议如何使用这种机制，以实现带宽效率和网络健壮性最佳平衡的提案。该草案 BIP 描述了基于 minisketch 的集合对账在节点之间的提议实现，为 Erlay 的实施奠定了基础。我们鼓励有反馈的任何人通过私人渠道或邮件列表与 BIP 作者联系。

- **<!--full-disclosure-of-fixed-vulnerabilities-affecting-multiple-ln-implementations-->****多种 LN 实现的已修复漏洞的全面披露：**几周前，C-Lightning、Eclair 和 LND 的开发者宣布了他们各自实现中之前发现的一个未公开问题，该问题已在最近的发布中得到修复。当时，他们强烈建议用户进行升级（Optech [转达][optech ln warning]这一信息），并承诺将在未来进行全面披露。现在，漏洞发现者和 C-Lightning 开发者 Rusty Russell 通过一封[电子邮件][russell disclosure]，以及 LND 开发者 Olaoluwa Osuntokun 和 Conner Fromknecht 在一篇[博客文章][lnd stay safe]中，完成了这项披露。

  简而言之，该问题似乎是这些实现没有确认通道打开交易是否支付了正确的脚本、金额或两者。因此，这些实现会在通道内接受支付，但之后无法在链上确认这些支付，从而导致可能被欺诈。截至撰写本文时，Optech 尚未收到任何报告表明该问题在上个月警告之前被利用。现在该问题已披露，已提交了一个[拉取请求][BOLTS #676]来更新规范，以说明需要进行此检查。

- **<!--optech-taproot-and-schnorr-workshop-->****Optech Taproot 和 Schnorr 研讨会：**上周，Optech 在旧金山和纽约市举办了研讨会，向开发者讲授了 Schnorr 签名方案及其他拟议中的 [Taproot][bip-taproot] 软分叉部分。我们感谢 Bryan Bishop 提供了纽约市研讨会的优秀[记录][workshop transcript]。我们正在准备视频及其他教育材料，并将在不久的将来通过博客文章发布。

## 实地报告：BTSE 交易所使用的比特币技术

{% include articles/zh/dong-btse-operation.md %}

## 值得注意的代码和文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo] 的值得注意的变更。*

- [Bitcoin Core #15558][] 更改了 Bitcoin Core 通常查询的 DNS 种子数量。DNS 种子是由知名贡献者托管的服务器，它们返回正在监听的对等节点的 IP 地址（接受传入连接的节点）。新启动的节点查询 DNS 种子以找到一组初始的对等节点；然后这些对等节点告诉该节点其他可能的对等节点，节点将此信息保存到磁盘以备后用（包括重启后）。理想情况下，节点只会在首次启动时查询 DNS 种子。但实际上，如果节点在随后的启动中没有迅速得到保存的对等节点的响应，它们也可能再次查询。

  此合并导致 Bitcoin Core 每次只查询三个 DNS 种子，而不是全部查询。三个种子应该足以确保节点连接到至少一个诚实的对等节点（比特币安全的一个要求），但查询的种子数量少到可以防止每个种子通过直接 DNS 解析获知查询节点。要查询的种子是从硬编码到 Bitcoin Core 中的列表中随机选择的。

- [LND #3523][] 允许用户更新他们将在特定打开通道或所有打开通道中接受的 HTLC 的最大 millisat 值。

- [LND #3505][] 将发票限制为 7,092 字节，这是可以适应单个二维码的最大大小。更大的发票可能会导致分配大量内存。例如，补丁作者测试的 1.7 MB 发票导致大约 38.0 MB 的内存分配。

- [Eclair #1097][] 开始从资金公钥派生通道密钥，使 Eclair 能够使用 [Newsletter #31][dlp footnote] 中描述的数据丢失保护（DLP）方案，即使所有数据都丢失。这确实需要用户回忆起他们打开通道的节点并找到通道 ID（对于公共通道，这些是公开信息）。这仅适用于更新到实现此更改版本的软件后打开的新通道；旧通道不受影响。*(注意：该条目之前错误地声称此合并 PR 使 Eclair 能够增加 DLP 支持。实际上，Eclair 已经有了 DLP 支持，此 PR 改变了通道密钥的派生方式，使即使所有数据丢失时该支持也有用。Optech 感谢 Fabrice Drouin 报告我们的错误。)*

- [C-Lightning #3057][] 使得 C-Lightning 可以使用 postgres 作为其数据库管理器。

- [C-Lightning #3064][] 实现了 [Newsletter #63][ln daily updates] 中描述的更改，减少了 C-Lightning 节点转发其他节点的通道更新公告的频率。这样可以减少节点使用的 gossip 带宽。

{% include linkers/issues.md issues="15558,3523,3505,1097,3057,3064,676" %}
[lnd stay safe]: https://blog.lightning.engineering/security/2019/09/27/cve-2019-12999.html
[dlp footnote]: /zh/newsletters/2019/01/29/#fn:fn-data-loss-protect
[ln daily updates]: /zh/newsletters/2019/09/11/#request-for-comments-on-limiting-ln-gossip-updates-to-once-per-day
[bip-reconcil]: https://github.com/naumenkogs/bips/blob/bip-reconcil/bip-reconcil.mediawiki
[reconcil post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-September/017323.html
[erlay paper]: /zh/newsletters/2019/06/05/#erlay-proposed
[optech ln warning]: /zh/newsletters/2019/09/04/#upgrade-ln-implementations
[workshop transcript]: http://diyhpl.us/wiki/transcripts/bitcoinops/schnorr-taproot-workshop-2019/notes/
[russell disclosure]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-September/002174.html
[erlay]: https://arxiv.org/pdf/1905.10518.pdf
