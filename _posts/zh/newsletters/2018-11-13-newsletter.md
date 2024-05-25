---
title: "Bitcoin Optech Newsletter #21"
permalink: /zh/newsletters/2018/11/13/
name: 2018-11-13-newsletter-zh
slug: 2018-11-13-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了几个在 Lightning-Dev 邮件列表上的讨论，提出了开发新工具的建议，这些工具可能对一些用户有帮助，并提供了最近在 Chaincode Lightning Applications 实习期间的一些演讲的总结和链接。还描述了几个值得注意的流行比特币基础设施项目中的代码更改。

## 行动项

本周无。

## 新闻

- **<!--ln-developer-summit-and-mailing-list-activity-->****LN 开发者峰会和邮件列表活动：** 在闪电网络协议开发者计划的会议之前、期间和之后，Lightning-Dev 邮件列表出现了大量的新提议和关于早期提议的讨论。以下是一些亮点：

  - **<!--advertising-node-liquidity-->****广告节点流动性：** Lisa Neigut [提议][neigut liquidity] 允许 LN 节点广告他们愿意提供收入容量以换取一定水平的费用。商家需要他们的支付通道具有收入容量，以便能够从客户那里接收安全的链下支付——目前的替代方案是要求一些客户等待几次链上确认以打开新通道，或与其他商家手动安排通道流动性。虽然解决这个问题对 LN 的商家采用非常有利，但它确实提出了一些技术挑战，讨论参与者试图在这个线程中和一个[相关线程][zmn liquidity]中解决这些问题。

  - **<!--making-path-probing-more-convenient-->****使路径探测更方便：** Anthony Towns [提议][probe cancel] 一种方法，允许路径上的所有节点忘记一个小额支付，如果路径上的一个节点离线。这在节点主动探测其可用支付路径以确定哪些路径最快和最可靠时，可以减少路由失败情况下所需的资源。

- **<!--opportunity-available-for-providing-utility-functions-outside-of-bitcoin-core-->****提供 Bitcoin Core 之外的实用功能的机会：** Bitcoin Core 的 RPC 接口目前提供了超过 100 种方法，并且经常有提议增加更多实用功能，这些功能不需要访问节点或钱包的内部状态。在上周的开发者 IRC [会议][core dev meeting]中，项目成员重申了他们的承诺，不会为可以在 Bitcoin Core 之外轻松完成并且与正常用户工作流程无关的事情提供任何新的实用功能。这将有助于项目专注于其主要目标。

  这确实为独立开发者或其他第三方创建一个单独的项目提供了一个很好的机会，这个项目可以是一个库、本地程序或 RPC 接口，它提供了与 Bitcoin Core 一起工作的稳定接口，甚至可以为不运行节点的用户提供一些 Bitcoin Core 已经支持的实用功能。在会议期间和[会议之后][core dev log]，讨论了一些实现此类工具的想法。

## 闪电网络应用实习视频

如之前在 [newsletter #19][] 中报道，Chaincode Labs 最近举办了为期五天的[实习项目][residency program]，以开发闪电网络上的应用程序，包括来自该领域专家的演讲。[演讲][presentations]的视频和[实习演示][resident demos]视频现已在线发布，以及专家演讲的幻灯片。以下演讲可能特别引起成员的兴趣：

- **<!--the-lightning-protocol-an-application-developers-perspective-->**[**闪电协议 - 应用开发者的视角**][bosworth video] - [Alex Bosworth][bosworth]，闪电实验室的基础设施负责人，全面概述了闪电协议，解释了所有的 [BOLTs][]，以及它们对在协议之上构建的开发者的相关性。这个演讲对任何想将闪电网络集成到产品或服务中的开发者都应该是有用的。

- **<!--lightning-bitcoin-->**[**闪电 ≈ 比特币**][decker video] - [Christian Decker][decker]，Blockstream 的核心技术工程师，描述了比特币和闪电支付之间的相似性和差异，强调了链上交易比链下交易更合适的情况（反之亦然）。他最后总结了可能在 2018 年 11 月闪电协议会议上提出的增强功能。

- **<!--integrating-lightning-into-bitrefill-->**[**将闪电网络集成到 Bitrefill**][camarena video] - [Justin Camarena][camarena]，bitrefill 的基础设施工程师，解释了 bitrefill 如何将闪电支付集成到他们的商店。Bitrefill 是最早开始接受主网闪电支付的比特币商家之一，Justin 向我们展示了他们如何将闪电集成到他们的基础设施中，以及他们在过程中遇到并克服的挑战。对于那些对 bitrefill 闪电网络经验的高层次概述感兴趣的人，可以参考 [Sergej Kotliar 在 Building on Bitcoin 上的演讲][kotliar BoB]，该演讲在 [newsletter #3][] 中也有所涉及。

- **<!--zap-ux-design-and-product-approach-->**[**Zap - 用户体验、设计和产品方法**][mallers video] - [Jack Mallers][mallers]，Zap 的创始人，解释了他的产品设计和用户体验方法。闪电网络可能解决了与使用比特币相关的许多用户体验问题，但也带来了自身的一些用户体验挑战。Jack 解释了他在 Zap 中如何考虑用户体验、他在构建产品时遇到的用户体验挑战以及他如何解决这些问题。

## 值得注意的代码更改

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-lightning][core lightning repo] 和 [libsecp256k1][libsecp256k1 repo] 中值得注意的代码更改。*

- [Bitcoin Core #14410][] 在 [getaddressinfo][rpc getaddressinfo] RPC 中添加了一个 `ischange` 字段，指示钱包是否在找零输出中使用该地址。

- [Bitcoin Core #14060][] 使可配置的最大消息数 [ZeroMQ][] (ZMQ) 接口将为客户端排队。默认的高水位标记（HWM）允许最多 1,000 条消息排队，然后才会丢弃某些消息。可以通过将以下配置选项之一设置为所需的最大排队消息数来选择新的 HWM（或通过将其设置为 `0` 来使最大队列大小无限制）：`zmqpubhashtxhwm`、`zmqpubhashblockhwm`、`zmqpubrawblockhwm` 和 `zmqpubrawtxhwm`。队列大小越大，程序使用的内存越多。

- [LND #1782][] 在 `getinfo` RPC 中添加了一个 `num_inactive_channels` 字段，显示节点的非活动通道数（类似于现有的待处理和活动通道计数）。

- [LND #1944][] 在 `sendtoroute` RPC 中添加了一个 `pub_key` 字段，因此 LND 不需要从外部来源获取公钥。这允许通过未列在公共网络上的私有通道路由支付。

{% include references.md %}
{% include linkers/issues.md issues="14410,14060,1782,1944" %}

[lightning-dev mailing list]: https://lists.linuxfoundation.org/mailman/listinfo/lightning-dev
[neigut liquidity]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001532.html
[zmn liquidity]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001555.html
[walletless opens]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001539.html
[eltoo protocol]: https://blockstream.com/eltoo.pdf
[probe cancel]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001554.html
[core dev meeting]: http://www.erisian.com.au/meetbot/bitcoin-core-dev/2018/bitcoin-core-dev.2018-11-08-19.00.log.html#l-49
[core dev log]: http://www.erisian.com.au/bitcoin-core-dev/log-2018-11-08.html#l-668
[zeromq]: http://zeromq.org/
[residency program]: https://lightningresidency.com
[presentations]: https://lightningresidency.com/#videos
[resident demos]: https://www.youtube.com/playlist?list=PLpLH33TRghT2jmuP9YQRo-e8gk969Q2F_
[bosworth video]: https://www.youtube.com/watch?v=1R5DNUcCYRg&list=PLpLH33TRghT1SbxinAsNDS6L7RkAjC8ME&index=6&t=0s
[bosworth]: https://twitter.com/alexbosworth
[BOLTs]: https://github.com/lightningnetwork/lightning-rfc
[decker video]: https://www.youtube.com/watch?v=8lMLo-7yF5k&list=PLpLH33TRghT1SbxinAsNDS6L7RkAjC8ME&index=5&t=0s
[decker]: https://twitter.com/Snyke
[camarena video]: https://www.youtube.com/watch?v=RZtx6ZMLDrQ&list=PLpLH33TRghT1SbxinAsNDS6L7RkAjC8ME&index=12&t=0s
[camarena]: https://twitter.com/juscamarena
[kotliar BoB]: https://www.youtube.com/watch?v=Cpid31c6HZc&feature=youtu.be&t=8m49s
[mallers video]: https://www.youtube.com/watch?v=R0C83h-ZM-4&list=PLpLH33TRghT1SbxinAsNDS6L7RkAjC8ME&index=17&t=0s
[mallers]: https://twitter.com/JackMallers
[newsletter #19]: /zh/newsletters/2018/10/30/#lightning-residency-and-hackday
[newsletter #3]: /zh/newsletters/2018/07/10/#merchant-adoption