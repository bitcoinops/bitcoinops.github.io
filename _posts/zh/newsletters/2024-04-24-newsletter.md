---
title: 'Bitcoin Optech Newsletter #299'
permalink: /zh/newsletters/2024/04/24/
name: 2024-04-24-newsletter-zh
slug: 2024-04-24-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报描述了一项提案，即在具有多个不同交易池规则的网络中中继弱块以提高致密区块性能，宣布增加了五名 BIP 编辑。此外，还有我们的常规部分：其中包括从 Bitcoin Stack Exchange 精选的问题和答案、新版本和候选版本的公告，以及对热门比特币基础设施项目的重大变更介绍。

## 新闻

- **<!--Weak-blocks-proof--of-concept-implementation-->弱块概念验证实现：** Greg Sanders 在 Delving Bitcoin 上[发文][sanders weak]，介绍了使用弱块来改善[致密区块中继][topic compact block relay]的做法，特别是在存在交易中继和挖矿规则分歧较多的情况下。弱块是一个区块的工作量证明（PoW）不足以成为区块链上的下一个区块，但在其他方面结构有效且交易集合有效。矿工会根据弱块所需 PoW（与正常区块所需 PoW）的比例来产生弱块；例如，矿工平均每产生一个满足 PoW 的区块，就会产生 9 个 需要 10% PoW 的弱块。

  矿工无法预知何时会产生弱块。他们尝试的每个候选区块都有相同的机会达到满足 PoW，但有些候选会最终变成弱块。产生弱块的唯一方式就是执行与产生满足 PoW 区块所需的完全相同的工作，这意味着弱块准确反映了矿工当时试图挖掘的交易。例如，将无效交易包含在弱块中的唯一方式是冒险创建同样包含该无效交易的满足 PoW 区块————这种无效区块将被全节点拒绝，且矿工将无法获得任何区块奖励。当然，如果矿工不想公开自己试图挖掘的交易，可以选择不广播自己的弱块。

  产生 10% PoW 弱块的困难很高，而且用无效交易产生弱块的成本很高，因此弱块对那些试图浪费大量节点带宽、CPU 和内存的拒绝服务攻击具有很强的抵御能力。

  由于弱块只是工作量证明略有不足的普通区块，因此它们的大小与普通区块相同。十多年前首次提出中继弱块时，这意味着中继 10% 的弱块会使节点用于区块中继的带宽增加 10 倍。然而，很多年前 Bitcoin Core 就开始使用致密区块中继，它用简短的标识符来替换区块中的交易，从而允许接收节点只请求其尚未看到的任何交易。这通常可以减少中继一个区块所需的带宽超过 99%。Sanders 指出，这对于弱块也同样有效。

  对于满足 PoW 的区块，致密区块中继不仅节省了带宽，还有助于加快新区块的传播。需要发送的数据（完整交易）越少，剩余数据就可以发送得越快。新区块的快速传播对挖矿去中心化很重要：找到新区块的矿工可以立即开始在该区块之上工作，而其他矿工只有在接收到新区块后才能开始在其之上工作。这可能会给大型矿池带来优势，从而产生一种非故意的利己挖矿攻击 (见[周报 #244][news244 selfish])。在引入致密区块中继之前，这个问题很普遍，导致了矿业向大型矿池集中并使用了引发大问题的技术，例如导致[2015 年 7月链分叉][July 2015 chain forks]的间谍挖矿。

  当节点接收到的新区块主要包含它已经看到的交易时，致密区块中继才能节省带宽和加快区块传播。但是，Sanders 指出，当今有些矿工正在创建包含许多未在节点之间中继的交易的区块，从而降低了致密区块中继的优势，并使网络面临着引入紧凑区块中继之前存在的问题。他提出了弱块中继作为解决方案：

  - 创建弱块（例如 10% PoW 弱块）的矿工会将其轻松中继到节点。所谓轻松是指这种中继会像中继新的未确认交易等普通 P2P 网络流量那样处理，而不是像中继新区块那样作为高优先级流量。

  - 节点将轻松接受这些弱块并对它们进行验证。PoW 验证是不费吹灰之力的，所以会立即执行；然后，弱块会暂时存储在内存中，同时被验证其中的交易。任何来自弱块并通过了 Bitcoin Core 的规则的新交易都将被添加到交易池。任何未通过的交易都将存储在特殊的缓存中，类似于 Bitcoin Core 用于临时存储无法添加到交易池的交易的现有缓存（例如，孤儿交易缓存）。

  - 后来收到的额外弱块可以更新交易池和缓存。

  - 当使用致密区块中继接收新的满足 PoW 区块时，它可以与来自交易池和弱块缓存的交易一起使用，从而最大限度地减少对额外中继时间和带宽的需求。这可以使具有许多不同节点和矿工规则的网络继续从致密区块中受益。

  此外，Sanders 指出了之前关于弱块(见[周报 #173][news173 weak]) 的讨论，讨论了如何利用弱块来帮助解决[交易钉死攻击][topic transaction pinning]并改善[手续费估算][topic fee estimation]。之前也曾在关于通过 Nostr 协议中继交易(见[周报 #253][news253 weak])的讨论中提及了弱块中继的使用。

  Sanders 已经写了一个“基础的[概念验证][sanders poc]，并进行了一些轻量级测试来展示这个想法的总体思路”。关于这个想法的讨论在写作时还在进行中。

- **<!--BIP-editors-update-->BIP 编辑更新：** 经过公开讨论 (见周报 [#292][news292 bips]、[#296][news296 bips]和[#297][news297 bips])，以下贡献者已被[推举为][chow editors] BIP 编辑：Bryan "Kanzure" Bishop、Jon Atack、Mark "Murch" Erhardt、Olaoluwa "Roasbeef" Osuntokun 和 Ruben Somsen。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 的贡献者们寻找答案的首选之地，也是它们有闲暇时会给好奇和困惑的用户帮忙的地方。在这个月度栏目中，我们会列举自上次出刊以来出现的一些高票的问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aa
nswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [“off by one” 的难度调整漏洞到底在哪里？]({{bse}}20597)
  Antoine Poinsot 解释了比特币难度重新调整计算中的 “off by one” 错误，该错误使得[时间扭曲攻击][topic time warp]成为可能，而[共识清理][topic consensus cleanup]提案旨在解决这个问题(见[周报 #296][news296 cc])。

- [从开发者的角度来看，P2TR 与使用操作码的 P2PKH 有何不同？]({{bse}}122548)
  Murch 得出结论，为示例 P2PKH 输出脚本提供的比特币脚本将是非标准的，比 P2TR 更昂贵，但在共识上是有效的。

- [替代交易是否比其前身交易和非 RBF 交易的大小更大？]({{bse}}122473)
  Vojtěch Strnad 指出，[RBF][topic rbf] 信号交易的大小与非信号交易相同，并列举了替代交易可能比被替代的原始交易大小相同、更大或更小的情景。

- [<!--are-bitcoin-signatures-still-vulnerable-to-nonce-reuse-->比特币签名是否仍然容易受到随机数复用攻击？]({{bse}}122621)
  Pieter Wuille 确认，包括其[多重签名变体][topic multisignature]在内的 ECDSA 和 [schnorr][topic schnorr signatures] 签名方案都容易受到[随机数复用][taproot nonces]攻击的影响。

- [<!--how-do-miners-manually-add-transactions-to-a-block-template-->矿工如何手动将交易添加到区块模板中？]({{bse}}122725)
  Ava Chow 概述了矿工可以用来将交易包含在区块中的不同方法，否则这些交易不会包含在 Bitcoin Core 的
  `getblocktemplate` 中：

  * 使用 `sendrawtransaction` 将该交易包含在矿工的交易池中，然后使用 `prioritisetransaction` 调整该交易的[感知绝对手续费][prioritisetransaction fee_delta]。

  * 使用经过修改的 `getblocktemplate` 实现或单独的区块构建软件。

## 版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [LND v0.17.5-beta][] 是一个维护版本，使 LND 与 Bitcoin Core 27.x 兼容。

  正如向 LND 开发人员[报告的][lnd #8571]那样，旧版本的 LND 依赖于旧版本的 [btcd][]，该版本旨在将其最大费率设置为 1000 万 sat/kB（相当于 0.1 BTC/kB）。但是，Bitcoin Core 接受的是 BTC/kvB 的费率，因此最高费率实际上被设置为 1000 万 BTC/kvB。Bitcoin Core 27.0 包括一个 [PR][bitcoin core #29434]，将最高费率限制为 1 BTC/kvB，以防止出现某些问题，并假设任何设置更高值的人都可能犯错误（如果他们真的想要更高的最大值，他们可以简单地将参数设置为 0 以禁用检查）。在这种情况下，LND（通过 btcd）确实犯了一个错误，但对 Bitcoin Core 的修改阻止了 LND 能够发送链上交易，这对于有时需要发送时间敏感交易的 LN 节点来说可能是危险的。此维护版本正确地将最大值设置为 0.1 BTC/kvB，使 LND 与新版本的 Bitcoin Core 兼容。

## 重大的代码和文档变更

_本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。_

- [Bitcoin Core #29850][] 将单个 DNS 种子接受的最大 IP 地址数限制为每次查询 32 个。通过 UDP 查询 DNS 时，最大数据包大小将数量限制为 33 个，但通过 TCP 查询的替代 DNS 现在可以返回更多的结果。新节点连接到多个 DNS 种子以构建一组 IP 地址。然后，TA 们随机选择其中一些 IP 地址并作为对等节点与 TA 们连接。如果新节点从 TA 连接的每个种子中获得大致相同数量的 IP 地址，那么 TA 选择的所有对等节点都不太可能来自同一个种子节点，这有助于确保 TA 对网络有不同的视角，并且不容易受到[日蚀攻击][topic eclipse attacks]。

  但是，如果一个种子返回的 IP 地址数量比任何其他种子多得多，则新节点很有可能随机选择一组全部来自该种子的 IP 地址。如果种子是恶意的，则可以允许 TA 将新节点与诚实网络隔离开来。[测试表明][bitcoin core #16070]，当时所有种子返回的结果都不超过 50 个，即使允许的最大值为 256 个。此合并的 PR 将最大数量减少到与种子节点当前返回的数量相似的数量。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="8571,29434,29850,16070" %}
[sanders weak]: https://delvingbitcoin.org/t/second-look-at-weak-blocks/805
[news173 weak]: /en/newsletters/2021/11/03/#feerate-communication
[news253 weak]: /zh/newsletters/2023/05/31/#nostr
[sanders poc]: https://github.com/instagibbs/bitcoin/commits/2024-03-weakblocks_poc/
[july 2015 chain forks]: https://en.bitcoin.it/wiki/July_2015_chain_forks
[selfish mining attack]: https://bitcointalk.org/index.php?topic=324413.msg3476697#msg3476697
[news244 selfish]: /zh/newsletters/2023/03/29/#bitcoin-core-27278
[btcd]: https://github.com/btcsuite/btcd/pull/2142
[chow editors]: https://gnusha.org/pi/bitcoindev/CAMHHROw9mZJRnTbUo76PdqwJU==YJMvd9Qrst+nmyypaedYZgg@mail.gmail.com/T/#m654f52c426bd5696d88668b3bff25197846e14af
[news292 bips]: /zh/newsletters/2024/03/06/#discussion-about-adding-more-bip-editors-bip
[news296 bips]: /zh/newsletters/2024/04/03/#choosing-new-bip-editors-bip
[news297 bips]: /zh/newsletters/2024/04/10/#bip2
[LND v0.17.5-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.5-beta
[news296 cc]: /zh/newsletters/2024/04/03/#revisiting-consensus-cleanup
[prioritisetransaction fee_delta]: https://developer.bitcoin.org/reference/rpc/prioritisetransaction.html#argument-3-fee-delta
[taproot nonces]: /en/preparing-for-taproot/#multisignature-nonces
