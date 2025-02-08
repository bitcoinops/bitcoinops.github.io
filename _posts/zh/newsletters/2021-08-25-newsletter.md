---
title: 'Bitcoin Optech Newsletter #163'
permalink: /zh/newsletters/2021/08/25/
name: 2021-08-25-newsletter-zh
slug: 2021-08-25-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了关于将闪电网络（LN）通道基本费用设为零的讨论，并包含我们定期更新的内容，包括来自 Bitcoin Stack Exchange 的热门问答、如何为 Taproot 做准备、新发布和候选发布版本，以及流行比特币基础设施项目的值得注意的更改。

## 新闻

- **<!--zero-base-fee-ln-discussion-->****零基本费用 LN 讨论：** 在闪电网络协议中，支付方可以自行决定向每个成功路由付款的节点支付多少费用。而路由节点则可以选择拒绝任何未提供足够费用的支付请求。为了使这种责任划分有效，路由节点需要向支付方传达其期望的费用。因此，[BOLT7][] 允许路由节点公布两个与费用相关的参数：`fee_base_msat`（基本费用）和 `fee_proportional_millionths`（按比例费用）。

  由 René Pickhardt 和 Stefan Richter 撰写的[一篇近期论文][pickhardt richter paper]提出了一种新的路径查找技术，该技术可以帮助支付方最小化费用，并减少成功发送付款所需的尝试次数（以及其他优势）。然而，在当前网络上部署该技术会遇到两个与 LN 基本费用和[多路径支付][topic multipath payments]相关的问题：

  - **<!--more-splits-more-fees-->****更多的拆分，更多的费用：** 比较单路径支付与相同金额的双路径支付：两者支付的总按比例费用相同（因为总支付金额相同），但双路径支付的总基本费用将是单路径支付的两倍（因为使用了两倍的跳数）。如果使用 `x` 条等效路径，则基本费用将是 `x` 倍。这使得多路径支付的成本更高，从而对依赖多路径支付的技术（如该论文提出的方法）产生了不利影响。

  {% comment %}<!-- 论文中的解释难以理解，因此以下描述经过简化以避免错误。 -->{% endcomment %}

  - **<!--computational-difficulties-->****计算上的困难：** 论文的第 2.3 节描述了所提出的路径查找算法在存在基本费用时难以计算路径和支付拆分。从长期来看，可能可以通过算法解决这个问题，但对该算法的实现者而言，最简单的解决方案就是取消基本费用。

  在[播客][honigdachs podcast]和[Twitter][zbf tweet]上，该论文作者建议，如果节点运营者将其基本费用设为零，即使无需立即更改 LN 协议，也可以解决这个问题。他们进一步建议，尽管其研究成果尚未在生产环境中部署，但运营者可以立即开始这样做。这引发了 LN 开发者在 Twitter 上的多次讨论，Anthony Towns 将讨论迁移到 Lightning-Dev 邮件列表，并发表了一篇[帖子][towns post]。

  Towns 支持用户将基本费用设为零，认为这不仅有助于多路径拆分，还能让节点运营者更容易优化唯一剩下的费用参数，即按比例费用。

  Matt Corallo [回复][corallo post]表示担忧，认为用于路由支付的 [HTLC][topic htlc] 会给节点带来若干成本，而这些成本与支付金额无关。基本费用允许节点确保这些成本得到补偿。然而，Towns 反驳称，无论支付是否成功，这些成本基本相同，而 LN 节点仅在支付成功时才能获得报酬。如果节点在某些情况下愿意承担这些成本而不获得补偿，为什么不能在所有情况下都接受呢？不过，这同样适用于按比例费用，因此讨论进一步涉及到[预付费][topic channel jamming attacks]，这种方式可以让节点即使在支付失败的情况下也能获得补偿。

  Towns 还提出，即使没有基本费用，节点仍然可以确保自己获得最低费用，例如简单地拒绝路由低于某个金额的支付。例如，一个当前基本费用为 1 sat 的节点可以通过设定 0.1% 的按比例费用和 1,000 sat 的最低支付金额来确保至少获得 1 sat。虽然这会抑制微支付，但 LN 节点已经能够在不使用 HTLC 的情况下处理小额支付，从而消除一些固定成本，并可能使纯按比例费用更合理，但这一点仍在讨论之中。

  在后续讨论中，Olaoluwa Osuntokun [强调][osuntokun post]了一个早前提出的观点，即目前并没有迫切需要节点运营者调整参数，以支持一个尚未准备好在生产环境中使用的新路径查找算法。他和 Corallo 希望进一步研究和开发，看看该算法（或基于不同原理的类似算法）是否能在基本费用非零的情况下同样良好地运行。

  截至撰写本文时，该讨论尚未达成明确结论。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选平台之一——或者当我们有空时，会帮助好奇或困惑的用户。在本月的特色内容中，我们重点介绍自上次更新以来发布的一些高票问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--why-does-bitcoin-core-support-a-transaction-index-but-not-an-address-index-->**[为什么 Bitcoin Core 支持交易索引但不支持地址索引？]({{bse}}107619)
  Andrew Chow 解释了 Bitcoin Core 交易索引在验证交易中的历史重要性（目前已被 [UTXO 数据库][bitcoin core #1677] 取代），并概述了 Bitcoin Core 不增加地址索引功能的理由，包括维护成本、缺乏令人信服的用例，以及此类索引超出了 Bitcoin Core 项目的范围。

- **<!--is-the-mempool-p2p-message-reliable-->**[`mempool` P2P 消息可靠吗？]({{bse}}108229)
  Claris 和 Pieter Wuille 解释了 [`mempool`][mempool message] P2P 消息的历史。该消息最初在 [BIP35][] 中引入，以便 SPV 端点访问节点的内存池内容，后来又被纳入 [BIP37][] 的[布隆过滤器][topic transaction bloom filtering]。目前，布隆过滤器已[默认禁用][news74 bip37 default]。可以使用 `-whitelist=mempool` 和 `-whitebind=mempool` 配置选项为特定对等节点启用 `mempool` 请求支持。

- **<!--what-is-sighash-anyprevoutanyscript-->**[什么是 SIGHASH_ANYPREVOUTANYSCRIPT？]({{bse}}107797)
  Michael Folkson 总结了 Christian Decker 对 [BIP118][] 提议的[签名哈希（sighash）][wiki sighash]的比较。其中，`SIGHASH_ANYPREVOUT` 仅对 `scriptPubKey` 进行承诺，但放弃对特定 UTXO 的承诺。而 `SIGHASH_ANYPREVOUTANYSCRIPT` 还放弃了对输入金额以及特定 `scriptPubKey` 的承诺，后者对于支持 [eltoo][topic eltoo] 至关重要。


- **<!--will-ln-liquidity-advertisements-and-dual-funding-allow-for-third-party-purchased-liquidity-sidecar-channels-->**[闪电网络的流动性广告和 dual funding 是否允许第三方购买的流动性（“副车道通道”）？]({{bse}}107786)
  David A. Harding 指出，虽然目前不支持，但使用[流动性广告][topic liquidity advertisements]和 [dual funding][topic Dual funding] 通道购买第三方流动性是可能的。他总结了 Lisa Neigut 对链上 PSBT 工作流和链下工作流的构想。

- **<!--are-there-risks-to-using-the-same-private-key-for-both-ecdsa-and-schnorr-signatures-->**[使用相同的私钥进行 ECDSA 和 Schnorr 签名有风险吗？]({{bse}}107924)
  Pieter Wuille 指出，虽然目前没有已知的跨 [schnorr][topic schnorr signatures] 和 ECDSA 的密钥重用攻击，但“为了保持在可证明的安全范围内，建议确保 ECDSA 密钥和 Schnorr 密钥使用不同的硬化派生步骤。”

## 准备 Taproot #10：PTLCs

*一周一期的[系列文章][series preparing for taproot]，介绍开发者和服务提供商如何为 Taproot 即将在区块高度 {{site.trb}} 激活做好准备。*

{% include specials/taproot/zh/09-ptlcs.md %}

## 发布与候选发布

*流行的比特币基础设施项目的新发布和候选发布版本。请考虑升级到新版本或帮助测试候选版本。*

- [Rust-Lightning 0.0.100][]：此新版本支持发送和接收 [keysend 支付][topic spontaneous payments]，并使节点更容易跟踪成功路由的支付以及记录从中获得的费用收入。

- [Bitcoin Core 22.0rc2][bitcoin core 22.0]：Bitcoin Core 的下一个主要版本的候选发布，包含支持 [I2P][topic anonymity networks] 连接、移除对 [Tor 版本 2][topic anonymity networks] 连接的支持，以及增强的硬件钱包支持。

- [Bitcoin Core 0.21.2rc1][bitcoin core 0.21.2]：Bitcoin Core 的维护版本候选发布，包含若干错误修复和小型改进。

# 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案 (BIPs)][bips repo]和[闪电网络规范 (BOLTs)][bolts repo]中的一些值得注意的变化。*

- [Bitcoin Core #22541][] 添加了一个新的 `restorewallet` RPC 命令，可用于加载钱包备份。`restorewallet` 补充了现有的 `backupwallet` 命令，后者用于导出当前加载的钱包的副本。请注意，`backupwallet` 和 `restorewallet` 是旧版 `dumpwallet` 和 `importwallet` RPC 的替代方案，后者使用单独的文件。此工作伴随对 [Bitcoin Core #22523][] 的文档进行了全面更新，涵盖了备份和恢复钱包的相关内容。

- [LND #5442][] 允许向 [PSBT][topic psbt] 添加输入，而无需添加任何新的输出，这对于创建 [CPFP 手续费提升][topic cpfp]非常有用。

- [Rust-Lightning #1011][] 增加了对尚未合并的 [BOLTs #847][] 的支持，该提案允许两个通道对等方协商共同关闭交易应支付的费用。在当前协议中，仅发送一个费用，另一方必须接受或拒绝该费用。

- [BOLTs #887][] 更新了 [BOLT11][]，要求支付方在进行支付时必须指定[支付密钥][topic payment secrets]，无论接收方是否启用了 `payment_secret` 功能位。接收方应验证支付密钥，以防止在简化的多路径支付中出现探测攻击。这个验证已在我们涵盖的所有四个闪电网络实现中得以实现。

{% include references.md %}
{% include linkers/issues.md issues="22541,5442,1011,847,887,22523,1677" %}
[bitcoin core 22.0]: https://bitcoincore.org/bin/bitcoin-core-22.0/
[bitcoin core 0.21.2]: https://bitcoincore.org/bin/bitcoin-core-0.21.2/
[rust-lightning 0.0.100]: https://github.com/rust-bitcoin/rust-lightning/releases/tag/v0.0.100
[pickhardt richter paper]: https://arxiv.org/abs/2107.05322
[towns post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-August/003174.html
[corallo post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-August/003179.html
[osuntokun post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-August/003187.html
[honigdachs podcast]: https://coinspondent.de/2021/07/11/honigdachs-62-pickhardt-payments/
[zbf tweet]: https://twitter.com/renepickhardt/status/1414895869078523910
[mempool message]: https://developer.bitcoin.org/reference/p2p_networking.html#mempool
[news74 bip37 default]: /zh/newsletters/2019/11/27/#deprecated-or-removed-features
[wiki sighash]: https://en.bitcoin.it/wiki/Contract#SIGHASH_flags
