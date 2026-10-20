---
title: 'Bitcoin Optech Newsletter #163'
permalink: /zh/newsletters/2021/08/25/
name: 2021-08-25-newsletter-zh
slug: 2021-08-25-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了关于把 LN 通道基础手续费设为零的讨论，并包含我们的常规栏目：Bitcoin Stack Exchange 的热门问答、如何为 Taproot 做准备、新版本与候选版本，以及热门比特币基础设施项目值得注意的变更。

## 新闻

- **<!--zero-base-fee-ln-discussion-->****零基础手续费 LN 讨论：** 在闪电网络协议中，付款方可以自行决定向每个帮助成功把支付路由到最终目的地的节点支付多少手续费。而路由节点则可以选择拒绝任何未提供足够手续费的支付尝试。要让这种分工成立，路由节点需要告知付款方自己期望的手续费，因此 [BOLT7][] 让路由节点可以公布两个与手续费有关的参数：`fee_base_msat`（基础手续费）和 `fee_proportional_millionths`（按比例手续费）。

  René Pickhardt 和 Stefan Richter [最近的一篇论文][pickhardt richter paper]提出了一种新的寻路方法，付款方可用它把手续费降到最低，同时减少成功发出支付所需的尝试次数（此外还有其他好处）。但在今天的网络上部署该方法，会遇到两个与 LN 基础手续费和[多路径支付][topic multipath payments]有关的问题：

  - **<!--more-splits-more-fees-->****拆分越多，手续费越多：** 试比较一笔单路径支付和一笔金额相同、走两条等效路径的支付：两者的按比例手续费总额相同（因为支付总额相同），但双路径支付的基础手续费总额会是两倍（因为它经过的跳数是两倍）。若有 `x` 条等效路径，基础手续费就会是原来的 `x` 倍。这让使用多路径支付的代价更高，从而不利于采用多路径的技术，例如论文所提出的方法。

  {% comment %}<!-- 论文中的解释难以理解，因此以下描述刻意写得平实，以免出错。 -->{% endcomment %}

  - **<!--computational-difficulties-->****计算上的困难：** 如论文第 2.3 节所述，存在基础手续费时，所提出的寻路算法无法轻易算出路径和支付拆分。长期来看，或许能从算法上解决这个问题，但对实现该算法的人来说，最简单的办法莫过于取消基础手续费。

  在[播客][honigdachs podcast]和 [Twitter][zbf tweet] 上，论文作者建议：只要节点运营者把基础手续费设为零，无需对 LN 协议做任何即时改动，也能解决这个问题。他们还建议运营者可以立刻开始这样做，尽管他们的成果目前还无法在生产环境中部署。这引发了 LN 开发者在 Twitter 上的多场讨论，Anthony Towns 用一篇[帖子][towns post]推动讨论转移到 Lightning-Dev 邮件列表。

  Towns 赞成把基础手续费设为零，并指出这样做既有利于多路径拆分，也能让节点运营者更容易优化唯一剩下的手续费参数——按比例手续费。

  Matt Corallo [回复][corallo post]表示担忧：为路由支付而创建 [HTLC][topic htlc]，会给节点带来若干与支付金额无关的固定负担。基础手续费让节点可以要求为这些成本获得补偿。Towns 则反驳说，无论支付成功与否，这些成本基本相同，而 LN 节点只有在支付成功时才能拿到报酬。如果节点在某些情况下愿意无偿承担这些成本，为什么不能在所有情况下都接受呢？不过，同样的说法也适用于按比例手续费，讨论因此延伸到[预付手续费][topic channel jamming attacks]——它可以让节点即使支付失败也能获得补偿。

  Towns 还提出，即使没有基础手续费，节点也能确保自己拿到最低限度的手续费，办法就是干脆拒绝路由低于某一金额的支付。例如，一个当前基础手续费为 1 sat 的节点，只要把按比例手续费设为 0.1%、最低金额设为 1,000 sat，就能保证至少收到这么多。这会抑制微支付，但 LN 节点本来就能在不使用 HTLC 的情况下处理小额支付，这消除了一部分固定成本，也可能让纯按比例收费更合适，不过这一点仍有争议。

  在讨论后段，Olaoluwa Osuntokun [强调][osuntokun post]了此前提出的一个观点：目前并没有明确的需求，要节点运营者现在就为一个还没人准备好在生产环境中使用的寻路算法改动参数。他和 Corallo 希望进一步研究开发，看看能否让该算法（或基于不同原理的类似算法）在基础手续费非零时也表现几乎同样好。

  截至本文撰写时，讨论没有得出明确结论。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们有点空闲时帮助好奇或困惑用户的地方。在本月栏目中，我们精选自上次更新以来得票最高的一些问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--why-does-bitcoin-core-support-a-transaction-index-but-not-an-address-index-->**[为什么 Bitcoin Core 支持交易索引但不支持地址索引？]({{bse}}107619)
  Andrew Chow 解释了 Bitcoin Core 交易索引在验证交易中的历史意义（后来被 [UTXO 数据库][bitcoin core #1677] 取代），并列举了反对为 Bitcoin Core 添加地址索引功能的理由，包括维护开销、缺乏有说服力的用例，以及这类索引超出了 Bitcoin Core 项目的范围。

- **<!--is-the-mempool-p2p-message-reliable-->**[`mempool` P2P 消息可靠吗？]({{bse}}108229)
  Claris 和 Pieter Wuille 介绍了 [`mempool`][mempool message] P2P 消息的由来。该消息最初在 [BIP35][] 中引入，用于把节点的内存池内容暴露给 SPV 对等节点；后来改为经由 [BIP37][] 的[布隆过滤器][topic transaction bloom filtering]访问，而这些过滤器如今已[默认禁用][news74 bip37 default]。可以用 `-whitelist=mempool` 和 `-whitebind=mempool` 配置选项，为个别对等节点开放对 `mempool` 请求的支持。

- **<!--what-is-sighash-anyprevoutanyscript-->**[什么是 SIGHASH_ANYPREVOUTANYSCRIPT？]({{bse}}107797)
  Michael Folkson 总结了 Christian Decker 对 [BIP118][] 所提议[签名哈希（sighash）][wiki sighash]的比较。`SIGHASH_ANYPREVOUT` 会承诺 `scriptPubKey`，但放弃对具体某个 UTXO 的承诺。而 `SIGHASH_ANYPREVOUTANYSCRIPT` 还放弃了对输入金额和具体 `scriptPubKey` 的承诺，后者正是支持 [eltoo][topic eltoo] 所必需的。


- **<!--will-ln-liquidity-advertisements-and-dual-funding-allow-for-third-party-purchased-liquidity-sidecar-channels-->**[闪电网络的流动性广告和双向资助是否允许第三方购买流动性（“侧车通道”）？]({{bse}}107786)
  David A. Harding 指出，虽然目前尚不支持，但借助[流动性广告][topic liquidity advertisements]和[双向资助][topic Dual funding]通道来购买第三方流动性是可行的。他总结了 Lisa Neigut 针对链上的部分签名比特币交易（PSBT）工作流和链下工作流提出的构想。

- **<!--are-there-risks-to-using-the-same-private-key-for-both-ecdsa-and-schnorr-signatures-->**[对 ECDSA 和 Schnorr 签名使用同一私钥有风险吗？]({{bse}}107924)
  Pieter Wuille 指出，虽然目前尚无已知的跨 [schnorr][topic schnorr signatures] 与 ECDSA 的密钥重用攻击，但“为了保持在可证明安全的范围内，建议确保 ECDSA 密钥与 Schnorr 密钥使用不同的硬化派生步骤。”

## 准备 Taproot #10：PTLCs

*一周一期的[系列文章][series preparing for taproot]，介绍开发者和服务提供商如何为 Taproot 即将在区块高度 {{site.trb}} 激活做好准备。*

{% include specials/taproot/zh/09-ptlcs.md %}

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [Rust-Lightning 0.0.100][] 是一个新版本，支持发送和接收 [keysend 支付][topic spontaneous payments]，并让节点更容易跟踪成功路由的支付、记录从中赚取的手续费收入。

- [Bitcoin Core 22.0rc2][bitcoin core 22.0] 是该全节点实现及其配套钱包和其他软件下一个主要版本的候选版本。这个新版本的主要变更包括：支持 [I2P][topic anonymity networks] 连接、移除对 [Tor 版本 2][topic anonymity networks] 连接的支持，以及加强对硬件钱包的支持。

- [Bitcoin Core 0.21.2rc1][bitcoin core 0.21.2] 是 Bitcoin Core 一个维护版本的候选版本，包含多项错误修复和若干小改进。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]的值得注意的变更。*

- [Bitcoin Core #22541][] 新增了 `restorewallet` RPC 命令，可用于加载钱包备份。`restorewallet` 与现有的 `backupwallet` 命令互补，后者用于导出当前已加载钱包的副本。请注意，`backupwallet` 和 `restorewallet` 替代了更早的 `dumpwallet` 和 `importwallet` RPC，后者使用单独的文件。与此同时，[Bitcoin Core #22523][] 全面更新了备份与恢复钱包的文档。

- [LND #5442][] 允许在向 [PSBT][topic psbt] 添加输入时不添加任何新输出，这在创建[子为父付（CPFP）手续费追加][topic cpfp]时很有用。

- [Rust-Lightning #1011][] 增加了对尚未合并的 [BOLTs #847][] 的支持，该提案允许一对通道对等节点协商共同关闭交易应支付多少手续费。在当前协议中，只会发送一个手续费数值，另一方必须接受或拒绝这个确切的数值。

- [BOLTs #887][] 更新了 [BOLT11][]，要求付款方在付款时必须指定[支付密钥][topic payment secrets]，无论收款方的 `payment_secret` 功能位是否启用。收款方应验证支付密钥，以防止简化多路径支付中的探测攻击。此前，我们介绍的四个 LN 实现都已实现了这一验证。

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
[series preparing for taproot]: /zh/preparing-for-taproot/
