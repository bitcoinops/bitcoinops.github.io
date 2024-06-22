---
title: 'Bitcoin Optech Newsletter #303'
permalink: /zh/newsletters/2024/05/17/
name: 2024-05-17-newsletter-zh
slug: 2024-05-17-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报总结了一种可用于闪电网络通道公告和其他多种需要女巫抗性的协调协议的匿名使用令牌的新方案，链接到了有关新的 BIP39 种子短语分割方案的讨论，公布了一种用于验证交互式合约协议中的任意程序执行是否成功的 BitVM 替代方案，并转发了有关更新 BIP 流程的建议。

## 新闻

- **<!--Anonymous-usage-tokens-->匿名使用令牌：** Adam Gibson 在 Delving Bitcoin 上[发布][gibson autct]了他开发的一个方案，该方案允许任何可以 [keypath 花费][topic taproot]一个 UTXO 的人在不透露是哪个 UTXO 的情况下证明他们可以花费它。这是继 Gibson 之前开发的抗女巫机制 [PoDLE][news85 podle]（用于 Joinmarket 的 [coinjoin][topic coinjoin] 实现）和 [RIDDLE][news205 riddle] 之后的又一成果。

  他介绍的用途之一是公告闪电网络通道。每个闪电网络节点都会向其他闪电网络节点公布自己的通道，这样它们就能在网络中找到路由资金的路径。大部分通道信息都存储在内存中，而且公告经常被转播，以确保尽可能多的节点都能收到。如果攻击者可以低成本地发布虚假通道，那么除了干扰这个寻路机制外，还可能让诚实节点浪费大量的内存和带宽。如今，闪电网络节点只接受由属于有效 UTXO 的密钥签名的公告。<!-- 忽略这段描述的细节，因为当前的闪电网络协议仅要求 P2WSH 的 UTXO -->这就要求通道注资者指出他们共同拥有的特定 UTXO，这可能会将这些资金与他们过去或未来创建的其他链上交易关联起来（或导致有人做出不准确的关联）。

  Gibson 的方案被称为 “匿名使用令牌曲线树（autct）”，通道共有人可以在不透露其 UTXO 的情况下签名。没有 UTXO 的攻击者无法创建有效的签名。拥有 UTXO 的攻击者可以创建有效的签名，但他们必须在 UTXO 中保留与目标闪电网络节点在通道中需要保留的一样多的资金，从而限制了任何攻击的最坏情况。有关将[通道公告][topic channel announcements]与特定 UTXO 分离的讨论，请参阅[周报 #261][news261 lngossip]。

  Gibson 还介绍了 autct 的其他几种使用方法。实现这种隐私性的基本机制——环形签名早已为人所知，但吉布森使用了一种新的密码学构造（[曲线树][curve trees]），使证明更加紧凑，验证速度更快。他还让每个证明私密地承诺所使用的密钥，这样单个 UTXO 就不能被用来创建无限数量的有效签名。

  除了发布[代码][autct repo]，Gibson 还发布了一个用于概念验证的[论坛][hodlboard]。论坛在注册时需要提供一个 autct 证明，这样就提供了一个其中的每个人都确信是比特币持有者，但无需提供任何可识别出自身或其持有比特币信息的环境。

- **<!--bip39-seed-phrase-splitting-->****BIP39 种子短语分割：**Rama Gan 在 Bitcoin-Dev 邮件列表中[发布][gan penlock]了他们开发的[一套工具][penlock website]的链接，这套工具可以在不使用任何电子计算设备（除了打印说明和模板）的情况下生成和拆分 [BIP39][] 种子词组。这与 [codex32][topic codex32] 类似，但其操作的 BIP39 种子词与当前几乎所有的硬件签名设备和许多软件钱包兼容。

  codex32 的联合作者 Andrew Poelstra 在[回复][poelstra penlock1]中提出了一些意见和建议。在我们没有尝试这两种方案的情况下（每种方案都需要几个小时），我们并不清楚两者间明确的权衡之处。不过，这两种方案似乎都提供了相同的基本功能：离线安全生成种子的指令；使用 [Shamir 秘密共享][sss]将种子分割成多个分片的能力；将分片重组为原始种子的能力；以及验证分片和原始种子的校验和的能力，从而让用户在原始数据仍可恢复时及早发现数据损坏。

- **<!--alternative-to-bitvm-->****BitVM 的替代方案：** Sergio Demian Lerner 和几位合著者在 Bitcoin-Dev 邮件列表中[发布][lerner bitvmx]了一个新的虚拟 CPU 架构，该架构部分基于 [BitVM][topic acc] 背后的思想。他们的项目 BitVMX 的目标是能够有效地证明任何程序的正确执行，这些程序可以编译成在成熟的 CPU 架构（如 [RISC-V][]）上运行。与 BitVM 一样，BitVMX 不需要任何共识变更，但需要一个或多个指定方充当可信验证者。这意味着交互式地参与在合约协议中的多个用户可以阻止任何一方（或多方）从合约中取款，除非该方成功执行合约指定的任意程序。

  Lerner 链接到一篇关于 BitVMX 的[论文][bitvmx paper]，该论文将 BitVMX 与最初的 BitVM（见[周报 #273][news273 bitvm]）进行了比较，并链接到最初的 BitVM 开发人员提供的后续项目较为有限的详情信息。随附的[网站][bitvmx website]以不太技术的形式提供了更多信息。

- **<!--continued-discussion-about-updating-bip2-->****关于更新 BIP2 的持续讨论：** Mark "Murch" Erhardt [继续][erhardt bip2]在 Bitcoin-Dev 邮件列表上讨论更新 [BIP2][]，这是目前描述比特币改进提案（BIP）流程的文件。他在邮件中描述了几个问题，提出了其中许多问题的解决方案，并征求对他的这些建议的反馈以及对余下问题的解决方案。有关之前更新 BIP2 的讨论，请参阅[周报 #297][news297 bip2]。

## 版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [LND v0.18.0-beta.rc2][] 是这个流行的闪电网络节点实现的下一个主要版本的候选发布版。

## 重大的代码和文档变更

_本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。_

- [Core Lightning #7190][] 在 [HTLC][topic htlc] 时间锁计算中增加了一个额外的偏移量（称为 `chainlag`）。这允许 HTLC 以当前区块高度为目标，而不是闪电网络节点处理过的最近区块（其同步高度）。这使得节点可以在区块链同步过程中安全地发送付款。

- [LDK #2973][] 实现了对 `OnionMessenger` 的支持，以代表离线的对等节点来拦截[洋葱消息][topic onion messages]。它会在拦截信息和对等节点恢复在线状态可转发洋葱消息时生成事件。用户应维护一个_允许列表_，以便只存储相关对等节点的信息。这是通过 `held_htlc_available` [BOLTs #989][] 来支持[异步支付][topic async payments]的垫脚石。在这类协议中，Alice 想通过 Bob 向 Carol 付款，但 Alice 不知道 Carol 是否在线。Alice 向 Bob 发送一条洋葱消息；Bob 保留消息，直到 Carol 在线；Carol 打开消息，消息告诉她向 Alice（或 Alice 的闪电服务提供商）请求付款；Carol 请求付款，Alice 按照正常方式发送付款。

- [LDK #2907][] 扩展了 `OnionMessage` 的处理功能，以接受一个可选的 `Responder` 的输入，并返回一个 `ResponseInstructions` 对象，指明对消息的响应该如何处理。这一变更启用了异步洋葱消息响应，并为更复杂的响应机制（如[异步支付][topic async payments]可能需要的机制）打开了大门。

- [BDK #1403][] 更新了 `bdk_electrum` crate，以使用 [BDK #1413][] 中引入的新的同步/全扫描结构、[BDK #1369][] 中的可查询 `CheckPoint` 链表以及 [BDK #1373][] 中的 `Arc` 指针中可低成本克隆的交易。这一改动提高了使用 Electrum 式服务器扫描交易数据的钱包的性能。现在还可以选择获取 `TxOut`，以便对从外部钱包接收的交易进行手续费计算。

- [BIPs #1458][] 增加了 [BIP352][]。该 BIP 提出了[静默支付][topic silent payments]，这是一种可重复使用的支付地址协议，每次使用时都会生成一个唯一的链上地址。该 BIP 草案在[周报 #255][news255 bip352] 中首次讨论。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when="2024-05-21 14:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="7190,2973,2907,1403,1458,989,1413,1369,1373" %}
[lnd v0.18.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.0-beta.rc2
[gibson autct]: https://delvingbitcoin.org/t/anonymous-usage-tokens-from-curve-trees-or-autct/862/
[news261 lngossip]: /zh/newsletters/2023/07/26/#updated-channel-announcements
[news205 riddle]: /zh/newsletters/2022/06/22/#riddle
[news85 podle]: /en/newsletters/2020/02/19/#using-podle-in-ln
[curve trees]: https://eprint.iacr.org/2022/756
[autct repo]: https://github.com/AdamISZ/aut-ct
[hodlboard]: https://hodlboard.org/
[gan penlock]: https://mailing-list.bitcoindevs.xyz/bitcoindev/9bt6npqSdpuYOcaDySZDvBOwXVq_v70FBnIseMT6AXNZ4V9HylyubEaGU0S8K5TMckXTcUqQIv-FN-QLIZjj8hJbzfB9ja9S8gxKTaQ2FfM=@proton.me/
[penlock website]: https://beta.penlock.io/
[poelstra penlock1]: https://mailing-list.bitcoindevs.xyz/bitcoindev/ZkIYXs7PgbjazVFk@camus/
[sss]: https://en.m.wikipedia.org/wiki/Shamir%27s_secret_sharing
[lerner bitvmx]: https://mailing-list.bitcoindevs.xyz/bitcoindev/5189939b-baaf-4366-92a7-3f3334a742fdn@googlegroups.com/
[risc-v]: https://zh.wikipedia.org/wiki/RISC-V
[bitvmx paper]: https://bitvmx.org/files/bitvmx-whitepaper.pdf
[news273 bitvm]: /zh/newsletters/2023/10/18/#payments-contingent-on-arbitrary-computation
[bitvmx website]: https://bitvmx.org/
[erhardt bip2]: https://mailing-list.bitcoindevs.xyz/bitcoindev/0bc47189-f9a6-400b-823c-442974c848d5@murch.one/
[news297 bip2]: /zh/newsletters/2024/04/10/#bip2
[news255 bip352]: /zh/newsletters/2023/06/14/#draft-bip-for-silent-payments-bip
