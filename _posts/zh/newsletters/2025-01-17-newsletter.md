---
title: 'Bitcoin Optech Newsletter #337'
permalink: /zh/newsletters/2025/01/17/
name: 2025-01-17-newsletter-zh
slug: 2025-01-17-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报总结了关于使用可交易的 ecash 份额奖励矿池矿工的持续讨论，并描述了一个新提案，该提案用于实现 DLC 的链下决议。此外还包括我们的常规板块，宣布新版本和候选版本，以及描述流行比特币基础设施软件的重要更新。

## 新闻

- **<!--continued-discussion-about-rewarding-pool-miners-with-tradeable-ecash-shares-->****关于使用可交易 ecash 份额奖励矿池矿工的持续讨论：**
  自从我们[之前的总结][news304 ecashtides]以来，在 Delving Bitcoin 论坛上关于用 ecash 就[矿池矿工][topic pooled mining]所提交的每个份额而付费的[讨论][ecash tides]仍在继续。此前，Matt Corallo [询问][corallo whyecash]为什么矿池要实现额外的代码和账务来处理可交易的 ecash 份额，而他们完全可以使用普通的 ecash 铸币厂（或通过闪电网络）来支付矿工。David Caseria [回复][caseria pplns]说，在某些 _pay per last N shares_ ([PPLNS][topic pplns]) 方案中，例如 [TIDES][recap291 tides]，矿工可能需要等待矿池找到几个区块，这可能需要几天或几周的时间，对于一个小矿池来说。相反，拥有 ecash 份额的矿工可以立即在开放市场上出售它们（而不向矿池或任何第三方透露有关其身份的任何信息，甚至不透露他们在挖矿时使用的任何临时身份）。

  Caseria 还指出，现有的矿池在支持全额支付每股（[FPPS][topic fpps]）方案时面临财务挑战，在该方案中，矿工在创建份额时按照整个区块奖励（区块补贴加交易费）的比例获得支付。他没有详细说明，但我们理解问题在于手续费的波动性迫使矿池保持大量储备。例如，如果一个矿池矿工控制 1% 的算力，并在一个包含约 1,000 BTC 手续费和 3 BTC 补贴的模板上创建份额，矿池将亏欠他们 10 BTC。然而，如果矿池没有挖到那个区块，而当矿工们确实挖到一个区块时，手续费回落到区块奖励的一小部分，矿池可能总共只有 3 BTC 可以在所有矿工之间分配，这就迫使它从储备中支付。如果这种情况发生太多次，矿池的储备将耗尽，最终破产。矿池通过各种方式解决这个问题，包括使用[实际手续费代理][news304 fpps proxy]。

  开发者 vnprc [描述][vnprc ehash]了他正在[构建][hashpool]的解决方案，该方案专注于在 PPLNS 支付方案中收到的 ecash 份额。他认为这对于启动新矿池特别有用：目前，第一个加入矿池的矿工承受着与单独挖矿相同的高波动性，所以通常只有现有的大型矿工或愿意租用大量算力的人才能启动矿池。然而，通过 PPLNS ecash 份额，vnprc 认为矿池可以作为更大矿池的客户来启动，这样即使是加入新矿池的第一个矿工也会比单独挖矿获得更低的波动性。中间矿池可以出售它赚取的 ecash 份额来为其选择的任何支付方案提供资金。一旦中间矿池获得了大量算力，它也将在与大型矿池就创建适合其矿工的替代区块模板进行谈判时获得更多筹码。

- **<!--offchain-dlcs-->****链下 DLC：** 开发者 conduition 在 DLC-dev 邮件列表中[发布][conduition offchain]了一个合约协议，该协议允许双方签署的资金交易的链下支出来创建多个 [DLC][topic dlc]。在链下 DLC 结算后（例如，获得所有必需的谕言机签名），双方可以签署新的链下支出，根据合约解决方案重新分配资金。然后第三种替代支出可以将资金分配给新的 DLC。

  Kulpreet Singh 和 Philipp Hoenisch 的回复链接到了这个基本想法的先前研究和开发，包括允许同一资金池用于链下 DLC 和闪电网络的方法（参见周报 [#174][news174 dlc-ln] 和 [#260][news260 dlc]）。来自 conduition 的[回复][conduition offchain2]描述了他的提案与先前提案的主要区别。

## 发布和候选发布

_流行的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。_

- [LDK v0.1][] 是这个用于构建闪电网络钱包和应用程序的库的里程碑发布版本。新功能包括“支持 LSPS 通道开启协商协议的双方，[...]包括支持 [BIP353] 人类可读名称解析，并在解决单个通道强制关闭时的多个 HTLC 时[减少]链上手续费成本。”

## 重要代码和文档更新

_以下是 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]、[闪电 BOLTs][bolts repo]、[闪电 BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的重要更新。_

- [Eclair #2936][] 引入了 12 个区块的延迟，在资金输出被花费后才将通道标记为关闭，以允许[拼接][topic splicing]更新的传播（参见周报 [#214][news214 splicing] 和 Eclair 开发者对其[动机][tbast splice]的描述）。已花费的通道暂时被跟踪在新的 `spentChannels` 映射中，它们要么在 12 个区块后被移除，要么作为拼接的通道被更新。当发生接合时，父通道的短通道标识符（SCID）、容量和余额界限会更新，而不是创建新通道。

- [Rust Bitcoin #3792][] 增加了编码和解码 [BIP324][] 的 [v2 P2P 传输][topic v2 P2P transport]消息的能力（参见周报 [#306][news306 v2]）。这是通过添加一个 `V2NetworkMessage` 结构体实现的，该结构体包装了原始的 `NetworkMessage` 枚举并提供 v2 编码和解码。

- [BDK #1789][] 将默认交易版本从 1 更新为 2 以提高钱包隐私性。在此之前，BDK 钱包更容易被识别，因为网络上只有 15% 使用版本 1。此外，版本 2 是未来实现 [BIP326][] 基于 nSequence 的[防费用狙击][topic fee sniping]机制用于 [taproot][topic taproot] 交易所必需的。

- [BIPs #1687][] 合并了 [BIP375][]，用于指定使用 [PSBT][topic psbt] 发送[静默支付][topic silent payments]。如果有多个独立签名者，需要 [DLEQ][topic dleq] 证明，以允许所有签名者向共同签名者证明他们的签名没有错误花费资金，而无需透露他们的私钥（参见[周报 #335][news335 dleq] 和[回顾 #327][recap327 dleq]）。

- [BIPs #1396] 更新了 [BIP78] 的 [payjoin][topic payjoin] 规范，使其与 [BIP174] 的 [PSBT][topic psbt] 规范保持一致，解决了之前的冲突。在 BIP78 中，此前即便是发送者需要 UTXO 数据，接收者也会在使用完输入后删除该 UTXO 数据。通过此更新，现在将会保留 UTXO 数据。

{% include snippets/recap-ad.md when="2025-01-21 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3792,1789,1687,1396,2936" %}
[ldk v0.1]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1
[news174 dlc-ln]: /en/newsletters/2021/11/10/#dlcs-over-ln
[news260 dlc]: /zh/newsletters/2023/07/19/#wallet-10101-beta-testing-pooling-funds-between-ln-and-dlcs-10101-beta-ln-dlc
[ecash tides]: https://delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870
[news304 ecashtides]: /zh/newsletters/2024/05/24/#challenges-in-rewarding-pool-miners
[corallo whyecash]: https://delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870/27
[caseria pplns]: https://delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870/29
[recap291 tides]: /en/podcast/2024/02/29/#how-does-ocean-s-tides-payout-scheme-work-transcript
[vnprc ehash]: https://delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870/32
[hashpool]: https://github.com/vnprc/hashpool
[conduition offchain]: https://mailmanlists.org/pipermail/dlc-dev/2025-January/000186.html
[news304 fpps proxy]: /zh/newsletters/2024/05/24/#pay-per-share-pps-pps
[tbast splice]: https://github.com/ACINQ/eclair/pull/2936#issuecomment-2595930679
[conduition offchain2]: https://mailmanlists.org/pipermail/dlc-dev/2025-January/000189.html
[news214 splicing]: /zh/newsletters/2022/08/24/#bolts-1004
[news306 v2]: /zh/newsletters/2024/06/07/#rust-bitcoin-2644
[news335 dleq]: /zh/newsletters/2025/01/03/#bips-1689
[recap327 dleq]: /en/podcast/2024/11/05/#draft-bip-for-dleq-proofs
