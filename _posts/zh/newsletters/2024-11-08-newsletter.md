---
title: 'Bitcoin Optech Newsletter #328'
permalink: /zh/newsletters/2024/11/08/
name: 2024-11-08-newsletter-zh
slug: 2024-11-08-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的新闻部分介绍了一项影响旧版本 Bitcoin Core 的漏洞，此外是我们的常规栏目：最近一次 Bitcoin Core PR 审核俱乐部会议的总结；软件的新版本和候选版本发行公告；以及热门的比特币基础设施软件的重大变更介绍。

## 新闻

- **<!--disclosure-of-a-vulnerability-affecting-bitcoin-core-versions-before-251-->****影响 25.1 以前版本的 Bitcoin Core 的漏洞披露：**Antoine Poinsot 在 Bitcoin-Dev 邮件组中[公开][poinsot stall] Bitcoin Core 采用新的披露策略（详见[周报 #306][news306 disclosure]）以前发现的最后一个漏洞。这份[详尽的漏洞报告][stall vuln]指出，25.0 以及更早版本的 Bitcoin Core 都容易收到一项不恰当的 P2P 协议回应的影响，该回应会让一个节点延迟重新请求区块，最高时延可达 10 分钟。解决方案是让区块 “可以从最多 3 个高带宽的致密区块对等节点处并行请求，并且其中一个必须是出站连接。”25.1 开始的版本修复了这个漏洞。

## Bitcoin Core PR 审核俱乐部

*在这个月度栏目中，我们总结了最近的一次 [Bitcoin Core PR 审核俱乐部][Bitcoin Core PR Review Club] 会议，列出了一些重要的问题和回复。点击问题描述可看到会议上出现的答案的总结。*

“[临时粉尘][review club 30239]” 是一项由 [instagibbs][gh instagibbs] 提出的 PR，该 PR 将带有临时粉尘输出的交易定义为标准交易，提升了带密钥以及无密钥的锚点输出（后者即 [P2A][topic ephemeral anchors]）的有用性。这跟多种链下合约方案都有关系，包括被闪电网络、[Ark][topic ark]、超时树和其他使用大规模预签名树或其他大规模 N 方智能合约所用的方案。

改变临时粉尘输出的交易池规则后，带有一个 [粉尘][topic uneconomical outputs] 输出的零手续费交易也可以进入交易池，只要节点知道有一笔有效的[支付手续费的子交易][topic cpfp]会立即花费这个粉尘输出。

{% include functions/details-list.md
  q0="<!--is-dust-restricted-by-consensus-policy-both-->粉尘输出的限制来自共识规则吗？还是来自交易池规则？还是两者都有？"
  a0="粉尘输出仅收到来自个节点交易池规则的限制，不受来自共识规则的限制。"
  a0link="https://bitcoincore.reviews/30239#l-27"

  q1="<!--how-can-dust-be-problematic-->什么时候粉尘输出会带来问题？"
  a1="粉尘输出（也叫不经济的输出）指的是其自身价值尚不足以偿付花费它所需的手续费的输出。因为它们是可以花费的，所以无法从 UTXO 集中修剪。因为花费它们是不经济的，所以通常不会被花费，这就造成了 UTXO 集规模的膨胀。不过，这些 UTXO 依然可能会出于其自身经济价值以外的经济激励而被花费，比如 “[锚点输出][topic anchor outputs]” 就是这样子的。"
  a1link="https://bitcoincore.reviews/30239#l-40"

  q2="<!--why-is-the-term-ephemeral-significant-what-are-the-proposed-rules-specific-to-ephemeral-dust-->“临时” 这个词有何意义？为临时粉尘提议的规则具体是什么样的？"
  a2="“临时” 一词就暗示着按照初衷，这些粉尘输出会被迅速花掉。临时粉尘规则要求父交易是零手续费的，而且只有一笔花费该粉尘输出的子交易。"
  a2link="https://bitcoincore.reviews/30239#l-50"

  q3="<!--why-is-it-important-to-impose-a-fee-restriction-->为什么要施加手续费上的约束？"
  a3="关键目标是防止粉尘输出被确认且不被花费。当父交易是零手续费的，矿工就没有激励单独挖出父交易而不挖出子交易。因为临时粉尘是一项交易池规则，而不是一项共识规则，经济激励扮演着重要角色。"
  a3link="https://bitcoincore.reviews/30239#l-56"

  q4="<!--how-are-1p1c-relay-and-truc-transactions-relevant-to-ephemeral-dust-->一父一子交易中继和 TRUC 交易跟临时粉尘的关系是什么样的？"
  a4="因为临时粉尘交易是零手续费的，所以它无法单独中继，因此 “[一父一子交易中继（1P1C）][28.0 integration guide]” 就成了必要。“TRUC（v3）交易” 限制为只有一笔未确认的父交易，因此与临时粉尘的要求兼容。TRUC 是当前唯一一种能让费率低于 [`minrelaytxfee`][topic default minimum transaction relay feerates] 的交易进入交易池的方法。"
  a4link="https://bitcoincore.reviews/30239#l-59"

%}

## 新版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Bitcoin Core 27.2][] 是包含 bug 修复的旧版本系列的维护式更新。如果你不会很快升级到最新版本（[28.0][]），请考虑至少升级到这个新的维护版本。

- [Libsecp256k1 0.6.0][] 是这个比特币相关的密码学操作库的新版本。“本次发行添加了 [MuSig2][topic musig] 模块，加入了一个稳健得多的方法来从堆栈中清除秘密值，并移除了未被使用的 `secp256k1_scratch_space` 函数。”

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [LDK #3360][] 添加了一种重广播操作，在一个公开通道确认的一周之后，每 6 个区块重新广播一次 `channel_announcement`。这消除了对对等节点的重广播依赖，并保证了通道在网络中总是可见。

- [LDK #3207][] 支持在[异步支付][topic async payments]的[洋葱消息][topic onion messages]中包含发票请求，在作为一个总是在线的发送者给静态的 [BOLT12][topic offers] 发票支付的时候。这在周报 [#321][news321 invreq] 中介绍的 PR 中是缺失的。重试时也会像在支付洋葱中一样包含发票请求，详见周报 [#321][news321 retry]。

{% assign timestamp="18:45" %}

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 15:30" %}

{% include snippets/recap-ad.md when=four_days_after_posting %}

{% include references.md %}

{% include linkers/issues.md v=2 issues="3360,3207" %}
[news306 disclosure]: /en/newsletters/2024/06/07/#upcoming-disclosure-of-vulnerabilities-affecting-old-versions-of-bitcoin-core
[stall vuln]: https://bitcoincore.org/en/2024/11/05/cb-stall-hindering-propagation/
[poinsot stall]: https://mailing-list.bitcoindevs.xyz/bitcoindev/uJpfg8UeMOfVUATG4YRiGmyz5MALtZq68FCBXA6PT-BNstodivpqQfDxD1JAv5Qny_vuNr-A1m8jIDNHQLhAQt8hj8Ee9OT6ZFE5Z16O97A=@protonmail.com/
[bitcoin core 27.2]: https://bitcoincore.org/en/2024/11/04/release-27.2/
[28.0]: https://bitcoincore.org/en/2024/10/02/release-28.0/
[libsecp256k1 0.6.0]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.6.0
[news321 invreq]: /zh/newsletters/2024/09/20/#ldk-3140
[news321 retry]: /zh/newsletters/2024/09/20/#ldk-3010
[review club 30239]: https://bitcoincore.reviews/30239
[gh instagibbs]: https://github.com/instagibbs
[28.0 integration guide]: /zh/bitcoin-core-28-wallet-integration-guide/
