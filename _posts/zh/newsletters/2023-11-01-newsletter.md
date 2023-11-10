---
title: 'Bitcoin Optech Newsletter #275'
permalink: /zh/newsletters/2023/11/01/
name: 2023-11-01-newsletter-zh
slug: 2023-11-01-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报跟进了近期关于比特币脚本语言提议变更的几次讨论。此外还包括了我们的常规部分，热门的比特币基础设施软件的新版本公告和重大变更简介。

## 新闻

- **<!--continued-discussion-about-scripting-changes-->脚本语言变更的持续讨论：**Bitcoin-Dev 邮件组里有一些针对我们此前报道过的讨论的回复。

    - *<!--covenants-research-->限制条款研究：* Anthony Towns [回复][towns cov]了一个由 Rusty Russell 撰写的、我们在[上周][news274 cov]提到过的[帖子][Russell Cov]。Towns 将 Russell 的方法与其他方法进行了比较，特别是基于[限制条款][topic covenants]的保管库，发现新方法并不吸引人。在之后的[回复][russell cov2]中，Russell 指出保险库有不同的设计，并且保险库在根本上不比其他交易类型更理想，意思是对于保险库用户来说，优化并不是关键。他认为 [BIP345][] 的保险库方法更适合于一个地址格式，而不是一组操作码；按照我们的理解，这意思是 BIP345 作为一个只为单一功能所设计的模板（就像 P2WPKH）更合理，如果设计了一组操作码但只实现了单一功能，则以后其它脚本可能会以意想不到方式跟它交互 。

      Towns 也考虑将 Russell 的方法用于普遍意义下的实验，并发现它在这种情况下“更有趣 [...] 但仍然相当受限”。他提醒读者他此前提议过的一种 Lisp 风格的替代比特币脚本的方法（参见[周报 ＃191][news191 lisp]），并且展示了它如何在见证数据求值期间的交易内省方面带来更大的灵活性与能力。他提供了他的测试代码链接，并指出了一些他编写的玩具级样例。Russell 回答说：“我仍然认为还需要大量的优化才能真正替代 Bitcoin Script。因为大部分有意思的例子都是当前不可能实现的，所以很难将我们当前受限的脚本与替代方案进行比较。”

      Towns 和 Russell 还简要讨论了以下内容：[OP_CHECKSIGFROMSTACK][topic op_checksigfromstack]，具体来说，它能允许来自预言机的经过认证的数据直接放置在求值堆栈上。

    - *OP_CAT 提案：* 一些人回复了 Ethan Heilman 的有关公告 [OP_CAT][] 提议 BIP 的[帖子][heilman cat]。我们在上周的周报里也[提到过][news274 cat]该提议。

      几则回复提到了对 `OP_CAT` 是否将会受到堆栈元素大小的 520 字节的过度限制的担忧。此后，Peter Todd [描述了][todd 520]一种在未来的软分叉中提升限额而无需任何额外 `OP_SUCESSx` 操作码的方法。不足之处是在提升前，脚本中所有使用 `OP_CAT` 的地方需要在其中包含一小部分额外的现存操作码。

      在 Anthony Towns 对 Russell 的限制条款研究的回复之前，James O'Beirne 在一篇类似的[帖子][o'beirne vault]中指出过使用 `OP_CAT` 来实现保险库的明显局限。他特别指出了 `OP_CAT` 与 BIP345 风格的保险库相比缺少了一些功能。


{% assign timestamp="0:40" %}

## 新版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本，或者帮助测试候选版本。*

- [LDK 0.0.118][] 是这个用于构建启用闪电网络应用程序的代码库的最新发布版本。它包括对 [offers][topic offers] 协议的部分实验性支持，以及其他新功能和错误修复。{% assign timestamp="14:57" %}

- [Rust Bitcoin 0.31.1][] 是这个用于处理比特币数据的代码库的最新发布。请查看[发布说明][rb rn]来了解该发布的一系列新功能和错误修订。{% assign timestamp="17:35" %}

_注意：_ 在我们上一期的周报中提到的 Bitcoin Core 26.0rc1 已经打标签，但由于 Apple 的一项变更使得无法在 macOS 上生成可复现的二进制文件，因此二进制文件尚未上传。Bitcoin Core 开发人员正努力在第二版的发布候选中解决。

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo] 和 [Bitcoin Inquisition][bitcoin inquisition repo]。*


- [Bitcoin Core #28685][] 修复了在计算 UTXO 集合哈希时的一个错误。该错误在[之前的周报][news274 hash bug]中提到过。该版本包含对 `gettxoutsetinfo` RPC 的一项非兼容变更，用 `hash_serialized_3` 替换了以前的 `hash_serialized_2` 并包含修正后的哈希。 {% assign timestamp="21:24" %}

- [Bitcoin Core #28651][] 允许 [miniscript][topic miniscript] 更加准确估计需要包含在见证结构中的最大字节数，以便花费一个 [taproot][topic taproot] 输出。准确性的提高将有助于防止 Bitcoin Core 多付手续费。 {% assign timestamp="22:34" %}

- [Bitcoin Core #28565][] 基于 [#27511][Bitcoin Core #27511] 构建，增加了一个返回对等节点地址数量的 `getaddrmaninfo` RPC。返回结果包括新的（“new”）和重试的（“tried”），并按网络类型（IPv4、IPv6、Tor、I2P、CJDNS）进行分段。请参见[周报 #237][news237 pr review] 和[播客 #237][pod237 pr review] 来了解这个分段背后的动机。 {% assign timestamp="24:57" %}

- [LND #7828][] 开始要求对等节点在合理的时间内响应其 LN 协议的 `ping` 消息，否则将被断开连接。这有助于确保连接保持活跃（减少死连接导致支付中断并触发不希望的通道强制关闭的概率）。闪电网络的 ping pong 还有许多其他好处：它们可以帮助掩盖网络流量，让网络观察者更难追踪支付（因为支付、ping 和 pong 都是加密的）；它们会触发更频繁的 [BOLT1][] 中所述的加密密钥轮换；而 LND 专门使用 `pong` 消息来防止[日蚀攻击][topic eclipse attacks]（参见[周报 #164][news164 pong]）。 {% assign timestamp="31:01" %}

- [LDK #2660][] 给予调用者更多灵活性，可为链上交易选择的不同费率。这些选项包括绝对最低费用、需要超过一天时间确认的低费率、普通优先级和高优先级。 {% assign timestamp="33:14" %}

- [BOLTs #1086][] 规定：如果创建一个转发 [HTLC][topic htlc] 请求的指令需要本地节点等待超过 2,016 个区块才能申请退款，应该拒绝（退款） HTLC 并返回一个 `expiry_too_far` 错误。降低此设置的数值可以减少节点在任何形式的[通道钉死攻击][topic channel jamming attacks]或长时间的[暂缓兑付发票][topic hold invoices]的最坏情况下而损失的资金。提高设置数值，可实现付款在相同的最大 HTLC 过期时间差设定（HTLC delta setting）下在更多通道上进行转发（或者在相同数量的跳数时允许更高的最大 HTLC 过期时间差设定），可以提高对一些特定攻击的抗性，例如[上周的周报][news274 cycling]中描述的替换循环攻击。 {% assign timestamp="35:02" %}

<div markdown="1" class="callout">
## 想了解更多？

想了解更多本周报中提到的内容，请加入我们每周的比特币 Optech 回顾的 [Twitter Space][@bitcoinoptech]，时间为每周四 15:00 UTC（即周报发布后的一天）。讨论内容会被录制下来，也将在我们的[播客][podcast]页面上提供。

</div>

{% include references.md %}
{% include linkers/issues.md v=2 issues="28685,28651,28565,7828,2660,1086,27511" %}
[news164 pong]: /en/newsletters/2021/09/01/#lnd-5621
[towns cov]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022099.html
[russell cov]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022031.html
[news274 cov]: /zh/newsletters/2023/10/25/#research-into-generic-covenants-with-minimal-script-language-changes
[russell cov2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022103.html
[news191 lisp]: /en/newsletters/2022/03/16/#using-chia-lisp
[heilman cat]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022049.html
[news274 cat]: /zh/newsletters/2023/10/25/#proposed-bip-for-op-cat-op-cat-bip
[todd 520]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022094.html
[o'beirne vault]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022092.html
[Bitcoin Core 26.0rc1]: https://bitcoincore.org/bin/bitcoin-core-26.0/
[bitcoin core developer wiki]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki
[bitcoin core pr review club]: https://bitcoincore.reviews/#upcoming-meetings
[news274 cycling]: /zh/newsletters/2023/10/25/#replacement-cycling-vulnerability-against-htlcs-htlcs
[ldk 0.0.118]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.118
[rust bitcoin 0.31.1]: https://github.com/rust-bitcoin/rust-bitcoin/releases/tag/bitcoin-0.31.0
[rb rn]: https://github.com/rust-bitcoin/rust-bitcoin/blob/master/bitcoin/CHANGELOG.md#0311---2023-10-18
[news274 hash bug]: /zh/newsletters/2023/10/25/#bitcoin-utxo-set-summary-hash-replacement-bitcoin-utxo-set-summary-hash-replacement
[news237 pr review]: /zh/newsletters/2023/02/08/#bitcoin-core-pr-审核俱乐部
[pod237 pr review]: /en/podcast/2023/02/09/#bitcoin-core-pr-review-club-transcript
