---
title: 'Bitcoin Optech Newsletter #362'
permalink: /zh/newsletters/2025/07/11/
name: 2025-07-11-newsletter-zh
slug: 2025-07-11-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的新闻部分简述了一个新的库，允许输出脚本描述符被压缩、用在 QR 码中。此外是我们的常规栏目：Bitcoin Core PR 审核俱乐部会议的总结、软件的新版本和候选版本的发行公告、热门的比特币基础设施软件的重大变更介绍。

## 新闻

- **<!--compressed-descriptors-->压缩的描述符**：Josh Doman 在 Delving Bitcoin 中[宣布][dorman descom]了他编写的一个[库][descriptor-codec]，可以将[输出脚本描述符][topic descriptors]编码成一种二进制格式、将体积缩小 40%。这可能是非常有用的，如果我们想用 QR 码来备份描述符的话。他的帖子详细介绍了编码的细节，并提到了他计划将这种压缩方案整合到自己的描述符加密备份库中（详见 [周报 #358][news358 descencrypt]）。

## Bitcoin Core RP 审核俱乐部

*在这个阅读栏目中，我们总结最近一期 [Bitcoin Core PR 审核俱乐部][Bitcoin Core PR Review Club]会议，并突出一些重要的问题和回答。点击问题描述可见到会议上答案的总结。*

[增强 TxOrphanage 拒绝服务限制][review club 31829] 是由 [glozow][gh glozow] 提出的一项 PR，改变 `TxOrphanage` 的驱逐逻辑，以保证为每个对等节点保留了能够解决至少 1 个最大体积交易包的资源。这些新的保证显著优化了 “[相机的 1 父 1 子交易包转发][1p1c relay]” 特性，尤其是在敌意条件下（但不限于此）。

这个 PR 修改了现有的全局孤儿交易限制，并引入新的逐对等节点限制。两者的结合防止了过量的内存使用和计算资源耗尽。这个 PR 也用一种计算各对等节点 DoS 分数的算法取代了随机驱逐算法。

*注意：自该次审核俱乐部会议以来，这项 PR 又发生了[少量重大的变更][review club 31829 changes]，其中最重要的是使用一种延迟分数限制，而不是宣告次数限制。*

{% include functions/details-list.md
  q0="<!--why-is-the-current-txorphanage-global-maximum-size-limit-of-100-transactions-with-random-eviction-problematic-->当前的 100 笔交易的 TxOrphanage 全局体积限制和随机驱逐算法有什么缺点？"
  a0="它让一个恶意的对等节点可以用孤儿交易冲垮一个节点，最终导致受害者节点处来自其它对等节点的所有合法交易都被驱逐。这种攻击可被用来阻止相机的 1 父 1 子交易转发，因为子交易无法长时间保存在孤儿交易池。"
  a0link="https://bitcoincore.reviews/31829#l-12"
  q1="<!--how-does-the-new-eviction-algorithm-work-at-a-high-level-->总体上，这种新的驱逐算法是如何工作的？"
  a1="驱逐不再是随机的。该算法会基于一种 “DoS 分数” 来瞄准 “行为最恶劣” 的对等节点，然后驱逐来自该对等节点的最早的交易宣告。这保护了来自行为良好的对等节点的交易的子交易，使之不受恶劣的对等节点影响。"
  a1link="https://bitcoincore.reviews/31829#l-19"
  q2="<!--why-is-it-desirable-to-allow-peers-to-exceed-their-individual-limits-while-the-global-limits-are-not-reached-->为什么在还没有达到全局上限的时候，允许对等节点超出自己的局部限制是可取的？"
  a2="对等节点可能仅仅因为自己乐于助人（正在广播有用的交易，比如 CPFP）而使用更多资源。"
  a2link="https://bitcoincore.reviews/31829#l-25"
  q3="<!--the-new-algorithm-evicts-announcements-instead-of-transactions-what-is-the-difference-and-why-does-it-matter-->新算法驱逐的对象是宣告消息而不是交易。这有什么区别？这个区别何以重要？"
  a3="宣告消息包含了一对信息：一笔交易和发送它的对等节点。因为驱逐的是宣告消息，恶意的对等节点就无法影响由诚实节点发来的交易。"
  a3link="https://bitcoincore.reviews/31829#l-34"
  q4="<!--what-is-a-peer-s-dos-score-and-how-is-it-calculated-->什么是对等节点的 “DoS 分数”，如何计算这个分数？"
  a4="一个对等节点的 DoS 分数是它的 “内存分数” 和 “CPU 分数” 中的最大值。内存分数是用掉的内存数量除以为之保留的内存数量；CPU 分数则是实际宣告的消息数量除以宣告消息的数量限制。使用一个单一的合并分数，可以将驱逐逻辑简化为单个循环，瞄准那些最激进地超过某一个限制的对等节点。"
  a4link="https://bitcoincore.reviews/31829#l-133"
%}

## 新版本和候选版本

*热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本，或帮助测试候选版本。*

- [LND v0.19.2-beta.rc2][] 是这个热门的闪电网络节点实现的一个维护版本的候选发行。

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Core Lightning #8377][] 收紧了 [BOLT11][] 发票的解析要求：让支付发送者不要支付缺失了[支付秘密][topic payment secrets]和强制字段（比如 `p`支付哈希值、`h`描述哈希值、`s`秘密值）的数值长度不正确的发票。这些变化跟近期的协议变更保持一致（详见周报 [#350][news350 bolts] 和 [#358][news358 bolts]）。

- [BDK #1957][] 为交易历史、默克尔证据以及区块头请求引入了 RPC 批量处理，以优化使用一个 Electrum 后端时完全扫码和同步的性能。这个 PR 也添加了锚点缓存以跳过同步期间对“简单支付验证（SPV）” 的重新验证。使用样本数据，作者观察到，在完全扫描期间，使用 RPC 调用批处理使性能表现从 8.14 秒上升到 2.59 秒；而在同步期间使用缓存使性能表现从 1.37 秒上升到 0.85 秒。

- [BIPs #1888][] 从 [BIP380][] 中移除了 `H` 作为硬化路径标记，只留下一贯使用的 `h` 和替代性的 `'` 。最近的周报 [#360][news360 bip380] 已经指出，出于清晰，语法曾经允许这三种标记，但因为很少（甚至没有）描述符实现真的支持（Bitcoin Core 和 rust-miniscript 都不支持），所以规范收紧为禁止它。

{% include references.md %}
{% include linkers/issues.md v=2 issues="8377,1957,1888" %}
[LND v0.19.2-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.2-beta.rc2
[news358 descencrypt]: /zh/newsletters/2025/06/13/#descriptor-encryption-library
[dorman descom]: https://delvingbitcoin.org/t/a-rust-library-to-encode-descriptors-with-a-30-40-size-reduction/1804
[descriptor-codec]: https://github.com/joshdoman/descriptor-codec
[news350 bolts]: /zh/newsletters/2025/04/18/#bolts-1242
[news358 bolts]: /zh/newsletters/2025/06/13/#bolts-1243
[news312 spv]: /zh/newsletters/2024/07/19/#bdk-1489
[news360 bip380]: /zh/newsletters/2025/06/27/#bips-1803
[review club 31829]: https://bitcoincore.reviews/31829
[gh glozow]: https://github.com/glozow
[review club 31829 changes]: https://github.com/bitcoin/bitcoin/pull/31829#issuecomment-3046495307
[1p1c relay]: /zh/bitcoin-core-28-wallet-integration-guide/#一父一子交易1p1c中继
