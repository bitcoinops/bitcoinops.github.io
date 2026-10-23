---
title: 'Bitcoin Optech Newsletter #128'
permalink: /zh/newsletters/2020/12/16/
name: 2020-12-16-newsletter-zh
slug: 2020-12-16-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了对 LN 静态备份的两个改进建议，并链接了一个关于新版本 PSBT 的提案。此外，还包括我们常规的栏目：服务和客户端软件的变更摘要、Bitcoin Stack Exchange 的热门问答、新版本与候选发布，以及热门比特币基础设施项目的值得注意的变更。

## 行动项

*本周无。*

## 新闻

- **<!--proposed-improvements-to-static-ln-backups-->****LN 静态备份的改进建议：** 凡是在支付通道（包括 LN 目前使用的通道）中收款的人，都需要跟踪通道的最新状态——即关闭通道并在链上拿到属于自己那份通道资金所需的全部细节。不幸的是，计算机经常会丢数据，而通道状态可能在磁盘损坏前几毫秒刚刚发生变化，这时定期备份也帮不上什么忙。

  LN 一直以来对这类问题有一定的健壮性：如果你的节点离线，你的通道对手方最终会关闭通道，以便能重新动用他们的资金。这会把你的资金发送到 LN 钱包的链上部分，希望你已用普通的 [BIP32][] 种子备份过它。这种方式应该相当安全：LN 的常规惩罚机制会促使你的对手方以最新状态关闭通道——如果他们使用旧状态，他们可能会失去通道中的所有资金。

  上述方法的缺点在于，你必须等对手方判定你不会再回来。如果你备份了通道的一些静态信息（例如对等节点的 ID），在丢失数据后重新连接到该对等节点，并请求对方立即关闭通道，就可以免去这段等待。这样做确实可能表明你丢了数据，因此对手方可能会以旧状态关闭通道——但如果他们这么做，而你仍保留着旧数据，你可以惩罚他们。

  本周，Lloyd Fournier 在 Lightning-Dev 邮件列表中发起了两个讨论帖，探讨如何改进上述机制：

  - **<!--fast-recovery-without-backups-->****无需备份的快速恢复：** 支持资金快速恢复的按通道静态备份，要求你每打开一个新通道就创建一份新备份。如果没有备份，你唯一的选择就是等待通道对手方自行决定关闭通道。Fournier 则[提出][really static backups]了一种确定性密钥派生方法，让节点可以遍历公开的 LN 节点列表，把自己从 HD 钱包派生出的私钥信息与每个节点主公钥的信息结合起来，判断自己是否与该节点有过通道。这种备份策略只适用于与公开节点打开的通道，而这类通道预计是普通用户最常见的通道类型。

  - **<!--covert-request-for-mutual-close-->****隐蔽地请求互相关闭：** 现有的通道关闭机制要求你的对手方广播其单方面承诺交易。更好的做法是使用互相关闭交易——它占用的链上空间更少、需要支付的手续费更低，在链上无法被识别为 LN 通道，而且允许双方立即动用资金。然而，互相关闭交易不包含任何惩罚机制，因此如果你请求关闭通道，而对手方给了你一笔不准确的互相关闭交易，你就没有办法惩罚他们。在正常协议中这不是问题——你直接广播最新状态即可；但如果你已经丢失了状态，就无从补救。

    Fournier 提出了一个[解决方案][oblivious mutual close]，使用一种称为[不经意传输][oblivious transfer]的密码学原语：它让对手方以加密形式把互相关闭交易发给你，而你可以选择使用它（关闭通道），或证明自己无法解密（让对方可以安全地继续在通道中接收支付）。如果你每次重连时都走这个流程，那么在对方提供完你恢复所需的全部信息之前，你都不会暴露自己丢失了数据。

- **<!--new-psbt-version-proposed-->****新版本 PSBT 的提案：** [BIP174][] 这一[部分签名比特币交易（PSBT）][topic psbt]规范的作者 Andrew Chow [提出][psbt2]了 PSBT 的一个新版本。新版本会包含若干不向后兼容的特性，不过在很大程度上会与当前的版本 0 PSBT 相同。

## 服务和客户端软件的变更

*在本月栏目中，我们重点介绍 Bitcoin 钱包与服务的一些有趣更新。*

- **<!--bitcoin-wallet-tracker-adds-descriptor-support-->****Bitcoin Wallet Tracker 添加输出脚本描述符支持：** Bitcoin Wallet Tracker 的 [0.2.0 版本][bwt 0.2.0] 增加了对追踪[输出脚本描述符][topic descriptors]的支持，并引入了 [libbwt][libbwt github]，一个允许基于 Electrum 的钱包轻松支持 Bitcoin Core 全节点的库。

- **<!--joinmarket-now-defaults-to-native-segwit-addresses-->****JoinMarket 现在默认使用原生 segwit 地址：** 尽管 JoinMarket 从 0.5.1 开始支持 segwit，但 [0.8.0 版本][joinmarket 0.8.0] 现在默认使用 bech32 原生 segwit 地址进行 [coinjoin][topic coinjoin]。

- **<!--bisq-adds-segwit-for-trade-transactions-->****Bisq 为交易添加 segwit 支持：** 在此前[为存款和提现添加 bech32 支持][news120 bisq segwit]的基础上，[Bisq v1.5.0][bisq bech32 blog] 让交易过程中的交易也支持 segwit，并实现了手续费优化。

- **<!--psbt-toolkit-v0-1-2-released-->****PSBT Toolkit v0.1.2 发布：** [PSBT Toolkit][psbt toolkit github] 是一款“旨在为你提供一个友好的图形界面，让你能够进行 PSBT 交互”的软件，其 0.1.2 版本带来了多项改进。

- **<!--sparrow-adds-replace-by-fee-->****Sparrow 添加手续费替换（RBF）支持：** [Sparrow 0.9.8][sparrow 0.9.8] 添加了 [手续费替换（RBF）][topic rbf]功能，并支持 [HWI][topic hwi] 1.2.1。

- **<!--ledger-live-adds-bitcoin-core-full-node-support-->****Ledger Live 添加 Bitcoin Core 全节点支持：** Ledger Live 使用开源的 [Ledger SatStack][satstack github] 应用程序，现在可以[连接到比特币全节点][ledger full node]以更私密的方式发送交易和提供余额，而无需使用 Ledger 的[区块浏览器][topic block explorers]。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们有点空闲时帮助好奇或困惑用户的地方。在本月栏目中，我们精选自上次更新以来得票最高的一些问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--what-is-the-difference-between-native-segwit-and-bech32-->**[“原生 segwit” 和 “bech32” 有什么区别？]({{bse}}100434)： Murch 解释说，bech32 是用于编码原生 segwit v0 见证程序的方法；它等同于用于传统比特币地址的 base58check 编码。同样的 bech32 编码也被用于其他目的，例如 LN 发票。bech32 原本计划用于以后版本的 segwit 见证程序，但人们发现了一个[长度扩展变异][news78 bech32 mutability]问题，这使得必须为支付到 taproot（P2TR）的 segwit v1 见证程序改用一种修改后的 bech32 地址格式，这种格式可能称为 “bech32m”。

- **<!--what-makes-cross-input-signature-aggregation-complicated-to-implement-->**[是什么让跨输入签名聚合的实现变得复杂？]({{bse}}100216)： Michael Folkson 引用了一篇 AJ Towns 发在 Bitcoin 开发邮件列表的[帖子][aj signature aggregation]，解释了在比特币中实现跨输入签名聚合的挑战。

- **<!--how-do-bip8-and-bip9-differ-how-are-they-alike-->**[BIP8 和 BIP9 有何不同，又有哪些相似之处？]({{bse}}100490)： Murch 概述了几种不同的激活方法：利用区块版本的早期软分叉激活、BIP9 支持多提案的激活方法，以及 BIP8 在区块高度和锁定（lock-in）方面对 BIP9 的调整。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [Bitcoin Core 0.21.0rc3][Bitcoin Core 0.21.0] 是该全节点实现及其配套钱包等软件的下一个主要版本的候选发布。请注意，macOS 版本的[签名二进制文件][macos signed]因代码签名工具问题而无法运行。[未签名版本][macos unsigned]（仍可用 PGP [验证][pgp verification]）如果用右键（或按住 Control 键）单击的上下文菜单打开，应该可以运行。开发者正在努力修复此问题，以用于后续的候选发布和最终版本。

- [LND 0.12.0-beta.rc1][LND 0.12.0-beta] 是该 LN 节点下一个主要版本的第一个候选发布。它使[锚定输出][topic anchor outputs]成为承诺交易的默认配置，并在其[瞭望塔][topic watchtowers]实现中加入了对锚定输出的支持，从而降低成本、提高安全性；同时还增加了对创建和签署 [PSBT][topic psbt] 的通用支持。此外还包含若干错误修复。

- **<!--n-->**Bitcoin Core 0.20.2rc1 和 0.19.2rc1 预计将在本 Newsletter 发布后[上线][bitcoincore.org/bin]。它们包含若干错误修复，例如 [Newsletter #110][news110 bcc19620] 中描述的一项改进，可防止它们反复下载自己尚不理解的未来 taproot 交易。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中值得注意的变更。*

- [Bitcoin Core #20564][] 对 Bitcoin Core 声明支持 `addrv2` 消息（[BIP155][]）的方式做了两处变更：
  - **<!--protocol-version-->***协议版本：* Bitcoin Core 只与声明使用 P2P 版本 70016 或更高的对等节点协商 `addrv2` 消息支持。BIP155 并不要求这一限制，但发布测试表明，某些其他实现在收到任何未知消息（包括 `sendaddrv2`）时，会断开与 Bitcoin Core 的连接。Bitcoin Core 的未来版本可能会回退此变更，因此建议其他实现随时容忍连接中出现的未知 P2P 消息。
  - **<!--updated-bip-->***更新的 BIP：* `sendaddrv2` 消息现在将在 `version` 和 `verack` 消息之间发送，符合 BIP155 最新版本的要求。关于该 BIP 这一变更的更多信息，请参见下方的 [BIPs #1043](#bips-1043)。

    此 PR 已通过 [Bitcoin Core #20612][] 向后移植（backport）到[最新的 V0.21 候选发布][Bitcoin Core 0.21.0]中。

- [Bitcoin Core #19776][] 为 `getpeerinfo` RPC 增加了两个新字段。`bip152_hb_to` 表明我们请求了对等节点以高带宽模式（HB）向我们中继新区块：无需先询问我们是否需要该特定区块，对方就会直接发送 [BIP152][] 紧凑区块。`bip152_hb_from` 表明对等节点请求我们成为其高带宽对等节点之一。默认情况下，每个节点会选择[最多 3 个][hb peers]高带宽紧凑区块对等节点。（尽管名字里有“高带宽”，与遗留的区块中继相比，高带宽模式其实并不怎么消耗带宽；它为快速中继新区块所做的优化，只是比 BIP152 的低带宽模式用得多一些而已。）

- [Bitcoin Core #19858][] 添加了一种寻找高质量对等节点的新方法，目标是让[日食攻击][topic eclipse attacks]更难实施。它平均每五分钟向一个新对等节点建立一个出站连接，并与其同步区块头。如果该对等节点告诉节点有新区块，节点就会断开一个现有的仅中继区块的对等节点，并把该连接槽位让给新对等节点；否则就丢弃这个新对等节点。只要节点知道至少一个其他诚实节点的 IP 地址，这种对等节点轮换就应该会提高攻击者对其维持分区攻击的成本，因为节点应该总能最终找到工作量最多的有效链。这种轮换和安全性的提升会略微减少网络中开放监听套接字的数量，但预计它会通过更频繁的连接把整个网络连接起来，为网络图增加边，并在总体上提供更强的抵御分区攻击的安全性。

- [Bitcoin Core #18766][] 使得在使用 `blocksonly` 配置选项时无法获取手续费估算。这个节省带宽的选项会让 Bitcoin Core 不再请求和中继未确认交易。然而，Bitcoin Core 的手续费估算还依赖于跟踪交易需要多久才能确认。此前，启用 `blocksonly` 时，Bitcoin Core 会停止更新估算值，但继续返回已经生成的估算值，导致估算值越来越过时。此次变更后，启用 `blocksonly` 模式时它将完全不返回任何估算值。

- [C-Lightning #4255][] 是系列拉取请求中的第一个，目标是 *offers* 的初始版本——即通过 LN 请求和接收发票的能力。一个常见的使用场景是：商户生成二维码，客户扫描该二维码，客户的 LN 节点通过 LN 把二维码中的一些细节（如订单 ID）发送给商户的节点，商户的节点（同样通过 LN）返回一张发票，发票展示给用户（用户同意支付），随后完成支付。尽管今天用 [BOLT11][] 发票已经能实现这个用例，但付款方与收款方的节点能在尝试支付前直接通信，带来了大得多的灵活性。它还支持 BOLT11 的一次性哈希锁无法实现的功能，例如订阅和捐赠的周期性支付。更多信息请参阅 [BOLT12 草案][BOLT12 draft]。

- [Eclair #1566][] 把所有连接处理逻辑抽象到一个前端节点中，该节点可以分布到多台主机上，以便生产部署实现高可用性。这些前端节点还以分布式方式处理 CPU/带宽密集型的 [BOLT7][] 消息，例如与路由表相关的 gossip 和同步请求，从而提升了 ACINQ 这类大型节点部署的可扩展性。对于希望部署此变更的读者，已有 AWS Beanstalk 捆绑包可用，作者建议使用 AWS Secrets Manager 存储节点私钥——这个话题此前在 [SuredBits 实地报告][suredbits] 中讨论过。

- [Eclair #1610][] 允许在打开新通道时，用新的 `feeBaseMsat` 和 `feeProportionalMillionths` 选项覆盖默认的中继手续费。

- [LND #4779][] 允许节点领取在使用[锚定输出][topic anchor outputs]的通道关闭时尚未结算的支付（HTLC）。

- [BIPs #1043][] 更改了 [BIP155][] 支持在对等节点之间的协商方式。此前，BIP 规定节点应在收到对等节点的 `verack` 消息后发送 `sendaddrv2` 消息来声明支持 BIP155。现在，BIP 规定节点必须在建立连接时更早发送 `sendaddrv2` 消息，即在发送 `version` 和 `verack` 消息之间。这与 [BIP339][] 协商 [wtxid 中继][wtxid relay]支持的方式一致，也与今年早些时候提交到邮件列表的[特性协商][feature negotiation]通用方法一致。

  John Newbery 在 Bitcoin-dev 邮件列表上发布了[对 BIP155 自 2019 年 2 月提出以来所有变更的总结][jnewbery bip155]。

- [BOLTs #803][] 更新了 [BOLT5][]，为防止[交易钉住][topic transaction pinning]攻击提出了建议。最近 LN 规范对[锚定输出][topic anchor outputs]的更新，允许在通道被单方面关闭时仍处于待处理状态的多个支付（HTLC）都在同一笔交易中结算。潜在的问题是，其中一些输出可能支付给你的通道对手方，使他们能够钉住这笔交易，阻止批次中的其他 HTLC 在其时间锁到期前确认。建议的做法是：时间充裕时允许把 HTLC 批量处理以获得最大效率，而在时间锁即将到期时把每个 HTLC 拆成单独的交易，这样钉住就不再是问题。

## 更正

[Newsletter #87][news87 negotiation] 错误地声称“旧版本的 Bitcoin Core 如果某些消息未按特定顺序出现，将终止新连接”。我们当时依据的是一种看法：`version` 消息之后必须紧接着 Bitcoin 0.2.9（2010 年 5 月）引入的 `verack` 消息。Optech 贡献者随后对 Bitcoin Core 旧版本所做的代码审查和测试并未证实这一说法，我们已经对原文添加了更正。对此错误深表歉意。

## 假期发布计划

节日快乐！本期是我们今年最后一期常规 Newsletter。下周我们将发布年度特别回顾版。常规发布将于 1 月 6 日（周三）恢复。

{% include references.md %}
{% include linkers/issues.md issues="20564,20612,19776,19858,18766,4255,1566,1610,1608,1043,803,4779" %}
[bitcoin core 0.21.0]: https://bitcoincore.org/bin/bitcoin-core-0.21.0/
[lnd 0.12.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.12.0-beta.rc1
[news87 negotiation]: /zh/newsletters/2020/03/04/#improving-feature-negotiation-between-full-nodes-at-startup
[bolt12 draft]: https://github.com/rustyrussell/lightning-rfc/blob/guilt/offers/12-offer-encoding.md
[news115 fee stealing]: /zh/newsletters/2020/09/16/#stealing-onchain-fees-from-ln-htlcs
[really static backups]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-December/002911.html
[oblivious mutual close]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-December/002912.html
[psbt2]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-December/018300.html
[oblivious transfer]: https://en.wikipedia.org/wiki/Oblivious_transfer
[macos signed]: https://bitcoincore.org/bin/bitcoin-core-0.21.0/test.rc3/bitcoin-0.21.0rc3-osx.dmg
[macos unsigned]: https://bitcoincore.org/bin/bitcoin-core-0.21.0/test.rc3/bitcoin-0.21.0rc3-osx64.tar.gz
[pgp verification]: https://bitcoincore.org/en/download/#verify-your-download
[bitcoincore.org/bin]: https://bitcoincore.org/bin/
[news110 bcc19620]: /zh/newsletters/2020/08/12/#bitcoin-core-19620
[wtxid relay]: /zh/newsletters/2020/07/29/#bitcoin-core-18044
[feature negotiation]: /zh/newsletters/2020/03/04/#improving-feature-negotiation-between-full-nodes-at-startup
[jnewbery bip155]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-December/018301.html
[bwt 0.2.0]: https://github.com/shesek/bwt/releases/tag/v0.2.0
[libbwt github]: https://github.com/shesek/bwt/blob/master/doc/libbwt.md
[joinmarket 0.8.0]: https://github.com/JoinMarket-Org/joinmarket-clientserver/blob/master/docs/release-notes/release-notes-0.8.0.md
[news120 bisq segwit]: /zh/newsletters/2020/10/21/#bisq-supports-bech32
[bisq bech32 blog]: https://bisq.network/blog/bisq-v1.5.0-highlights/
[psbt toolkit github]: https://github.com/benthecarman/PSBT-Toolkit
[ledger full node]: https://support.ledger.com/hc/en-us/articles/360017551659-Setting-up-your-Bitcoin-full-node
[sparrow 0.9.8]: https://github.com/sparrowwallet/sparrow/releases/tag/0.9.8
[satstack github]: https://github.com/LedgerHQ/satstack
[news78 bech32 mutability]: /zh/newsletters/2019/12/28/#bech32-mutability
[aj signature aggregation]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-March/015838.html
[bip152]: https://github.com/bitcoin/bips/blob/master/bip-0152.mediawiki
[hb peers]: https://github.com/bitcoin/bitcoin/blob/b316dcb758e3dbd302fbb5941a1b5b0ef5f1f207/src/net_processing.cpp#L552
[suredbits]: /zh/suredbits-enterprise-ln/
