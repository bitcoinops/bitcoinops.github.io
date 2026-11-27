---
title: "Bitcoin Optech Newsletter #21"
permalink: /zh/newsletters/2018/11/13/
name: 2018-11-13-newsletter-zh
slug: 2018-11-13-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 梳理了 Lightning-Dev 邮件列表上的几个讨论，指出一个开发新工具的机会（一些用户会觉得这类工具有用），并提供了最近 Chaincode 闪电网络应用驻留项目（residency）上部分演讲的摘要和链接。此外还介绍了若干热门比特币基础设施项目中值得注意的代码变更。

## 行动项

本周无。

## 新闻

- **<!--ln-developer-summit-and-mailing-list-activity-->****LN 开发者峰会和邮件列表活动：** 在闪电网络协议开发者计划召开的会议之前、期间和之后，[Lightning-Dev 邮件列表][lightning-dev mailing list]上涌现了大量新提议，以及对早先提议的讨论。以下是一些亮点：

  - **<!--advertising-node-liquidity-->****公开宣传节点流动性：** Lisa Neigut [提议][neigut liquidity]让 LN 节点可以公开声明自己愿意提供入站容量（incoming capacity），以换取一定水平的手续费。商家需要支付通道具备入站容量，才能从客户那里接收安全的链下支付——目前仅有的替代办法，要么是让部分客户等待若干个链上确认以开立新通道，要么是与其他商家手工安排通道流动性。尽管解决这个问题对 LN 的商家采用极为有利，但它确实带来了一些技术挑战，讨论参与者正试图在这个讨论帖和另一个[相关讨论帖][zmn liquidity]中解决这些问题。

  - **<!--making-path-probing-more-convenient-->****让路径探测更方便：** Anthony Towns [提议][probe cancel]一种方法：当路径上某个节点离线时，让该路径上的所有节点都忘掉一笔小额支付。对于会主动探测其可用支付路径、以找出最快最可靠发送路径的节点来说，这可以减少路由失败时所需的资源。

- **<!--opportunity-available-for-providing-utility-functions-outside-of-bitcoin-core-->****在 Bitcoin Core 之外提供工具函数的机会：** Bitcoin Core 的 RPC 接口目前提供 100 多个方法，并经常有人提议再增加一些工具函数，用于那些不需要访问节点或钱包内部状态的事情。在上周的开发者 IRC [会议][core dev meeting]中，项目成员重申了他们的立场：凡是完全可以在 Bitcoin Core 之外轻松完成、且与普通用户的工作流程无关的事情，就不会为其新增任何工具函数。这有助于项目专注于其主要目标。

  这确实给独立开发者或其他第三方提供了一个好机会：可以另建一个项目，提供库、本地程序或 RPC 接口，为那些能与 Bitcoin Core 配合良好的工具函数提供稳定的调用接口；这个项目甚至可以提供一些 Bitcoin Core 已经支持、但面向不运行节点的用户的工具函数。会议期间和[会议之后][core dev log]，都讨论了一些实现这类工具的想法。

## 闪电网络应用驻留项目视频

如之前 [Newsletter #19][newsletter #19] 中所述，Chaincode Labs 最近举办了一个为期五天、面向闪电网络应用开发的[驻留项目][residency program]，其中包含该领域专家的演讲。[演讲][presentations]与[驻留者演示][resident demos]的视频现已发布到网上，专家演讲的幻灯片也一并发布。以下演讲可能对会员特别有吸引力：

- **<!--the-lightning-protocol-an-application-developers-perspective-->**[**闪电协议——应用开发者的视角**][bosworth video] - [Alex Bosworth][bosworth]，Lightning Labs 的基础设施负责人，全面概述了闪电协议，讲解了全部 [BOLTs][]，以及它们与在协议之上构建应用的开发者有何关系。对于想把闪电网络集成进产品或服务的开发者来说，这个演讲应该很有用。

- **<!--lightning-bitcoin-->**[**闪电 ≈ 比特币**][decker video] - [Christian Decker][decker]，Blockstream 的核心技术工程师，描述了比特币支付与闪电支付之间的异同，并指出链上交易比链下交易更合适的场景（反之亦然）。他最后总结了 2018 年 11 月闪电协议会议上可能提出的一些增强方案。

- **<!--integrating-lightning-into-bitrefill-->**[**将闪电网络集成到 Bitrefill**][camarena video] - [Justin Camarena][camarena]，bitrefill 的基础设施工程师，解释了 bitrefill 如何将闪电支付集成到其网店中。Bitrefill 是最早开始接受主网闪电支付的比特币商家之一，Justin 展示了他们如何把闪电网络接入自身基础设施，以及过程中遇到并克服了哪些挑战。如果你只想大致了解 bitrefill 使用闪电网络的经验，[Sergej Kotliar 在 Building on Bitcoin 上的演讲][kotliar BoB]同样值得一看，该演讲在 [Newsletter #3][newsletter #3] 中也介绍过。

- **<!--zap-ux-design-and-product-approach-->**[**Zap——用户体验、设计与产品思路**][mallers video] - [Jack Mallers][mallers]，Zap 的创始人，讲述了他对产品设计和用户体验的看法。闪电网络有潜力解决许多与使用比特币相关的用户体验问题，但也带来了它自身的一些用户体验挑战。Jack 讲述了他如何在 Zap 中考虑用户体验、构建产品时遇到哪些用户体验挑战，以及他如何解决这些问题。

## 值得注意的代码变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-lightning][core lightning repo] 和 [libsecp256k1][libsecp256k1 repo] 中值得注意的代码变更。*

- [Bitcoin Core #14410][] 在 [getaddressinfo][rpc getaddressinfo] RPC 中添加了一个 `ischange` 字段，用于指示钱包是否将该地址用在找零输出中。

- [Bitcoin Core #14060][] 让 [ZeroMQ][]（ZMQ）接口为某个客户端排队缓存的最大消息数变得可配置。默认的高水位标记（HWM）允许最多排队 1,000 条消息，超出后部分消息会被丢弃。把下列配置选项之一设置为期望的排队消息上限，即可选定新的 HWM（设为 `0` 则队列上限不受限制）：`zmqpubhashtxhwm`、`zmqpubhashblockhwm`、`zmqpubrawblockhwm` 和 `zmqpubrawtxhwm`。队列越大，程序占用的内存越多。

- [LND #1782][] 在 `getinfo` RPC 中添加了一个 `num_inactive_channels` 字段，显示节点的非活动通道数（类似于现有的待处理和活动通道计数）。

- [LND #1944][] 在 `sendtoroute` RPC 中添加了一个 `pub_key` 字段，因此 LND 不需要从外部来源获取公钥。这允许通过未列在公共网络上的私有通道路由支付。

{% include references.md %}
{% include linkers/issues.md issues="14410,14060,1782,1944" %}

[lightning-dev mailing list]: https://gnusha.org/url/https://lists.linuxfoundation.org/mailman/listinfo/lightning-dev
[neigut liquidity]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001532.html
[zmn liquidity]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001555.html
[walletless opens]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001539.html
[eltoo protocol]: https://blockstream.com/eltoo.pdf
[probe cancel]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001554.html
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
[erlay]: https://arxiv.org/pdf/1905.10518.pdf