---
title: 'Bitcoin Optech Newsletter #329'
permalink: /zh/newsletters/2024/11/15/
name: 2024-11-15-newsletter-zh
slug: 2024-11-15-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报总结了一种新的链下支付解决协议，并链接了几篇关于 LN（闪电网络）支付可能面临的 IP 层追踪与审查的论文。此外，还包括了一些新版本与候选版本（包括 BTCPay Server 的安全性关键更新）的公告，以及对热门比特币基础设施项目的重大变更介绍。

##  新闻

- **<!--mad-based-offchain-payment-resolution-opr-protocol-->****基于 MAD 的链下支付解决协议 (OPR)：** John Law 在 Delving Bitcoin 的[发帖][law opr]中描述了一种小额支付协议，该协议要求双方为一笔保证金共同出资，并且任何一方都可以随时有效地销毁保证金。这种机制的核心是创造一种“互相确保毁灭”（Mutually Assured Destruction，MAD）的威慑，促使双方努力满足对方需求，否则将面临保证金损失的风险。

  这种方法与理想的免信任协议不同。在免信任协议中，如果发生协议违约，只有违约方会损失资金。然而，在实际应用中，像 LN 这样的免信任协议通常要求守约方支付链上交易费用，以从违约中恢复资金。Law 利用这一事实提出了一些 MAD 协议的潜在优势：

  - 在资金销毁的情况下，MAD 协议所需的链上空间比通过链上执行免信任合约要少，从而提高了可扩展性。

  - MAD 协议基于交易对手的“绥靖政策”而非全网共识，可以实现极短的到期时间，例如仅为几秒甚至不到一秒，而不是至少几个区块。Law 举了一个例子，保证付款在不到 10 秒的时间内解决（成功或失败），而 LN 的支付在最糟情况下可能需要长达两周才能结算。

  - 在双方通信长时间中断的情况下，MAD 协议无需任何一方将数据上链（因为双方都被激励避免这么做，否则会损失保证金）。相比之下，在 [LN-Penalty][topic ln-penalty] 协议中，如果通信中断，通道中的未完成 [HTLC][topic htlc] 必须在截止时间前链上结算。

    Law 强调，这使得 OPR 在[通道工厂][topic channel factories]、[超时树][topic timeout trees]或其他嵌套结构中表现更高效，因为这些结构希望嵌套部分尽可能保持链下操作。

  Matt Morehouse [回复][morehouse opr]称，这种基于绥靖政策的机制可能导致缓慢盗窃。例如，Mallory 声称 Bob 在某项操作中失败，损失的价值是保证金的 5%；Bob 不确定是否失败，但支付 Mallory 5% 比冒失去 50% 保证金的风险更有利，于是妥协。Mallory 不断重复这一过程。这种问题因典型的通信网络中难以证明过错的情况而加剧。如果 Mallory 和 Bob 因通信中断而发生失败，他们可能互相指责，最终导致 MAD。此外，Morehouse 指出，OPR 协议要求用户为保证金存储更多资金，这可能降低用户体验（UX）————例如，当前的 [BOLT2][] _通道储备_ 机制已经让用户感到困惑，因为它限制了用户只能使用通道余额的 99%。

  截至撰写时，讨论仍在进行中。

- **<!--papers-about-ip-layer-censorship-of-ln-payments-->****关于 LN 支付在 IP 层审查的论文：** Charmaine Ndolo 在 Delving Bitcoin 上[总结了][ndolo censor][两篇][atv revelio]关于 LN 支付隐私性降低及潜在审查的最新[论文][nt censor]。这些论文指出，包含 LN 协议消息的 TCP/IP 数据包的元数据（例如数据包数量和总数据量）可以轻松推断出这些消息的负载类型(如新的 [HTLC][topic htlc])。如果攻击者控制了一个包含多个节点的网络，他可能观察到消息在节点间的传递。如果攻击者同时控制了其中一个 LN 节点，则可以获取有关传递消息的一些信息(例如支付金额或消息类型为[洋葱消息][topic onion messages])。这可能被用于选择性地阻止某些支付成功，甚至阻止支付快速失败——从而防止立即重试，并可能迫使通道链上关闭。

  截至撰写时，此讨论尚未有回复。

## 版本和候选版本

_热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。_

- [BTCPay Server 2.0.3][] 和 [1.13.7][btcpay server 1.13.7]是维护版本，包括针对某些插件和功能的用户的安全关键修复。有关详细信息，请参阅链接的发行说明。

## 重大的代码和文档变更

_本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。_

- [Bitcoin Core #30592][]移除了允许用户禁用[全面手续费替换（Full RBF）][topic rbf]并恢复为选择性手续费替换的 `mempoolfullrbf` 设置选项。由于全面手续费替换已被广泛采用，禁用它已无实际意义，因此此选项被移除。全面手续费替换最近已被默认启用(见周报 [#315][news315 fullrbf])。

- [Bitcoin Core #30930][] 为 `netinfo` 命令新增了一个“节点服务”列以及一个 `outonly` 过滤选项，以仅显示外向连接。“节点服务”列列出了每个节点支持的服务，包括：完整区块链数据(n)、[布隆过滤器][topic transaction bloom filtering] (b)、[segwit][topic segwit] (w)、[致密过滤器][topic compact block filters](c)、限制到最近 288 个区块的区块链数据 (l)、[版本2 p2p 传输协议][topic v2 p2p transport] (2)。此外，还对帮助文档进行了更新。

- [LDK #3283][]通过实现 [BIP353][]，为基于 DNS 的人类可读比特币支付指令（解析为 [BOLT12][] [要约][topic offers]并符合 [BLIP32][]规范）添加了支持。新增了一个 `pay_for_offer_from_human_readable_name` 方法到 `ChannelManager`，允许用户直接向人类可读名称（HRN）发起支付。该 PR 还引入了一个`AwaitingOffer` 支付状态以处理待决支付，并新增了一个 `lightning-dns-resolver` crate 用于处理 [BLIP32][] 查询。有关此前工作的详细信息，见周报 [#324][news324 blip32]。

- [LND #7762][] 更新了多个 `lncli` 命令，使其返回状态消息而非空响应，以更清晰地表明命令已成功执行。受影响的命令包括：`wallet releaseoutput`、`wallet accounts import-pubkey`、`wallet labeltx`、`sendcustom`、`connect`、`disconnect`、`stop`、`deletepayments`、`abandonchannel`、`restorechanbackup` 和 `verifychanbackup`。

{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30592,30930,3283,7762" %}
[law opr]: https://delvingbitcoin.org/t/a-fast-scalable-protocol-for-resolving-lightning-payments/1233
[morehouse opr]: https://delvingbitcoin.org/t/a-fast-scalable-protocol-for-resolving-lightning-payments/1233/2
[ndolo censor]: https://delvingbitcoin.org/t/research-paper-on-ln-payment-censorship/1248
[atv revelio]: https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=10190502
[nt censor]: https://drops.dagstuhl.de/storage/00lipics/lipics-vol316-aft2024/LIPIcs.AFT.2024.12/LIPIcs.AFT.2024.12.pdf
[btcpay server 2.0.3]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.0.3
[btcpay server 1.13.7]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.13.7
[news315 fullrbf]: /zh/newsletters/2024/08/09/#bitcoin-core-30493
[news324 blip32]: /zh/newsletters/2024/10/11/#ldk-3179
