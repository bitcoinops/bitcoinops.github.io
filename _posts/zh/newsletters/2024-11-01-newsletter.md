---
title: 'Bitcoin Optech Newsletter #327'
permalink: /zh/newsletters/2024/11/01/
name: 2024-11-01-newsletter-zh
slug: 2024-11-01-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的新闻部分介绍了一项关于超时树通道工厂的提议，还总结了一份关于离散对数等价证明的 BIP 草案（可在生成静默支付时使用）。此外是我们的常规栏目：软件新版本和候选版本的发行公告，以及热门的比特币基础设施软件上发生的重大变更的介绍。

## 新闻

- **<!--timeout-tree-channel-factories-->超时树通道工厂**：ZmnSCPxj 在 Delving Bitcoin 论坛中[发布][zmnscpxj post1]了一种叫做 “SuperScalar” 的多层 “[通道工厂][topic channel factories]” 设计，并与 Optech 的贡献者专门[讨论][deepdive]了它。这一设计的一个目标是提供一种可以由单个供应商轻松实现的构造、无需等待需要广泛共识的大型协议变更得到部署。举例来说，一个发行了钱包软件的闪电网络服务商（LSP）就可以让用户更便宜地开启通道、获得入账流动性，而无需牺牲闪电网络的免信任性。

  整个构造基于一棵 “超时树”：*注资交易* 会将资金交给一棵预先定义的子交易所构成的树、这些子交易最终会在链下将资金分配许多独立的支付通道。在一个可配置的超时时间（例如一个月）之后，这棵超时树的部分参与者会丧失他们还放在这棵树上的所有资金 —— 这会激励他们在到期之前取回资金或需要其它的保管方式，并且也鼓励他们使用便宜的链下机制，而不是将树的一部分发布到链上。在以往介绍的超时树构造中（见[周报 #270][news270 timeout trees]），用户的资金会在超时后编程服务供应商的财产，但 ZmnSCPxj 逆转了这个特性，让服务供应商的资金在超时后变成用户的财产 —— 从而将让交易得到确认的负担转移到服务供应商身上（而不是由终端用户承担）。

  这种超时树要求每一个参与者都贡献一个签名。这避免了共识变更的需要，但限制了一个工厂可行的用户数量上限，因为众所周知的 “[多签名人的协调问题][news270 coordination]”。

  超时树的绝大部分叶子是链下的注资交易，为今天常用的通道类型（[LN-Penalty][]）提供资金，也允许部分复用现有的管理闪电通道的代码。参与一条通道的两个对手方是一个终端用户和一个 LSP（也就是创建超时树的 LSP）。树的部分叶子也可以是由 LSP 排他性控制的，可以用来再平衡资金。

  在树根和叶子之间是 “[双工微支付通道][topic duplex micropayment channels]”。不像 LN-Penalty 通道，双工通道允许超过两方安全地分享资金；只不过，相比 LN-Penalty 可以实质上无限次更新，双工通道只允许相对较少的状态更新次数。这些中间的双工通道用来让 LSP 能够与两个终端用户再平衡资金；这些再平衡能够安全地以链下的速度完成，所以在一个用户要收取一笔入账支付时，即使原本在树上的通道没有那么多的容量，也可以近乎即时地完成（通道流动性的调整以及收取支付）。

  在[后续一篇帖子][zmnscpxj post2]，ZmnSCPxj 介绍了将双工通道替换成一种 “[Spillman 式][spillman channel]”（单向）未支付通道的想法。在合作情形中，其链上花费会更加高效；但在非合作情形中，其链上花费会更低效。

  本提议获得了少量的讨论。作者表示，这项提议的一个弱点在于其技术复杂性，因为使用了多种不同的通道，再加上通道工厂设计内在的管理额外链下状态的挑战。不过，这项提议也有一个优势：任何一个团队都可以自己实现它，然后跟标准的闪电网络互操作，无需对闪电网络协议作许多变更。

- **<!--draft-bip-for-dleq-proofs-->****DLEQ 证明的 BIP 草案**：Andrew Toth 在 Bitcoin-Dev 邮件组中[公开][toth dleq]了一项 BIP 草案，并链接了一个用于在比特币所用的椭圆曲线（secp256k1）上生成和验证 “[离散对数相等][topic dleq]（DLEQ）” 证明的[实现][dleq imp]。DLEQ 证据允许一方证明自己知道一个秘密值，而无需揭晓关于这个秘密值的任何信息，例如其对应的公钥。在过去，这曾被用来允许某人证明自己拥有一个 UTXO，而不揭晓这个 UTXO（见周报 [#83][news83 podle] 和 [#131][news131 podle]）。

  这份 BIP 的动机是支持使用多个独立的签名人来创建 “[静默支付][topic silent payments]”。如果一个签名人说了谎或者是恶意的，那么可能弄丢资金。而 DLEQ 证据允许每个签名人都证明自己正确签名了，且无需向其它签名人揭晓自己的私钥。[周报 #308][news308 sp] 曾介绍相关的讨论。

  这项提议收到了来自 Adam Gibson 的[回复][gibson dleq]，他曾为 [coinjoin][topic coinjoin] 实现 JoinMarket 开发出了一个 DLEQ 证明系统。他建议了多项变更，可以让这个 BIP 版本的 DLEQ 更加灵活，可以用在静默支付以外的场景中。

## 新版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [BTCPay Server 2.0.0][] 是这个自托管的支付处理软件的最新版本。它的新特性包括 “更强的本地化、侧边栏导航、更好的引导流程、更好的品牌挑选、支持可拔插的费率信息源”，等等。这次升级包括了许多破坏式变更和收据库迁移；建议在升级前先阅读他们的[更新公告][btcpay post]。

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Bitcoin Core #31130][] 抛弃了对 `miniupnp` 的依赖，从而移除了对 “通用即插即用（UPnP）” 互联网网关设备（IGD）的支持。该依赖库有一系列的安全漏洞史，并且已经被默认禁用（详见周报 [#310][news310 upnp]）。取而代之的是一个带有 “网络地址翻译-端口匹配协议（NAT-PMP）” 后备的 “端口控制协议（PCP）” 实现（详见周报 [#323][news323 pcp]），这让节点无需手动配置就可以被触达，且移除了跟 `miniupnp` 依赖库相关的安全性风险。

- [LDK #3007][] 为 `OutboundTrampolinePayload` 枚举类型添加了两种新的变体 `BlindedForward` 和 `BlindedReceive`，以在 “[蹦床路由][topic trampoline payments]” 中添加对 “[盲化路径][topic rv routing]” 的支持，作为实现 [BOLT12][] [offer][topic offers] 协议的基础。

- [BIPs #1676][] 将 [BIP85][] 的状态更新为 “完成（final）”，因为它已被广泛部署，并且越过了引入破坏式变更的时间点。这项更新是在最近的一次破坏式变更被合并然后又被撤回之后提出的（详见周报 [#324][news324 bip85]）。

{% include references.md %}
{% include linkers/issues.md v=2 issues="31130,3007,1676" %}
[news83 podle]: /zh/newsletters/2020/02/05/#podle
[news131 podle]: /en/newsletters/2021/01/13/#ln-dual-funding-anti-utxo-probing
[news308 sp]: /zh/newsletters/2024/06/21/#continued-discussion-of-psbts-for-silent-payments-psbt
[zmnscpxj post1]: https://delvingbitcoin.org/t/superscalar-laddered-timeout-tree-structured-decker-wattenhofer-factories/1143
[deepdive]: /en/podcast/2024/10/31/
[news270 timeout trees]: /zh/newsletters/2023/09/27/#using-covenants-to-improve-ln-scalability
[zmnscpxj post2]: https://delvingbitcoin.org/t/superscalar-laddered-timeout-tree-structured-decker-wattenhofer-factories/1143/16
[spillman channel]: https://en.bitcoin.it/wiki/Payment_channels#Spillman-style_payment_channels
[toth dleq]: https://mailing-list.bitcoindevs.xyz/bitcoindev/b0f40eab-42f3-4153-8083-b455fbd17e19n@googlegroups.com/
[dleq imp]: https://github.com/BlockstreamResearch/secp256k1-zkp/blob/master/src/modules/ecdsa_adaptor/dleq_impl.h
[gibson dleq]: https://mailing-list.bitcoindevs.xyz/bitcoindev/77ad84ed-2ff8-4929-b8da-d940c95d18a7n@googlegroups.com/
[news270 coordination]: /zh/newsletters/2023/09/27/#using-covenants-to-improve-ln-scalability
[ln-penalty]: https://en.bitcoin.it/wiki/Payment_channels#Poon-Dryja_payment_channels
[btcpay post]: https://blog.btcpayserver.org/btcpay-server-2-0/
[btcpay server 2.0.0]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.0.0
[news310 upnp]: /zh/newsletters/2024/07/05/#remote-code-execution-due-to-bug-in-miniupnpc-miniupnpc
[news323 pcp]: /zh/newsletters/2024/10/04/#bitcoin-core-30043
[news324 bip85]: /zh/newsletters/2024/10/11/#bips-1674
