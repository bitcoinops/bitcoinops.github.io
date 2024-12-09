---
title: 'Bitcoin Optech Newsletter #128'
permalink: /zh/newsletters/2020/12/16/
name: 2020-12-16-newsletter-zh
slug: 2020-12-16-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了对 LN 静态备份的两个改进建议，并链接了一个关于新版本 PSBT 的提案。此外，还包括我们常规的部分内容，如服务和客户端软件的更改摘要、Bitcoin Stack Exchange 的热门问答、新版本和候选发布，以及流行的比特币基础设施项目的值得注意的更改。

## 行动项

*本周无。*

## 新闻

- **<!--proposed-improvements-to-static-ln-backups-->****LN 静态备份的改进建议：** 在支付通道中接收资金的任何人，包括目前 LN 使用的通道，都需要跟踪通道的最新状态——即能够关闭通道并在链上接收正确资金份额的所有详细信息。不幸的是，计算机经常会丢失数据，而定期备份无法解决这一问题，因为通道状态可能会在磁盘驱动器损坏的几毫秒前发生变化。

  LN 一直以来为此类问题提供了一定的鲁棒性：如果你的节点离线，你的通道对方最终会关闭通道以便他们可以再次开始使用资金。这将把你的资金发送到 LN 钱包的链上部分，希望你已经用正常的 [BIP32][] 种子备份了它。这种方式应该相对安全：LN 的常规惩罚机制鼓励你的对方以最新状态关闭通道——如果他们使用旧状态，他们可能会失去通道中的所有资金。

  这种方法的缺点是你必须等待对方确定你不会重新上线。如果你备份了一些关于通道的静态信息（例如你的对等方的 ID），在丢失数据后重新连接到对等方，并请求对方立即关闭通道，这种等待可以被消除。这的确可能表明你已经丢失数据，因此你的对等方可能会以旧状态关闭通道——但如果他们尝试这么做，而你仍然拥有旧数据，你可以对他们进行惩罚。

  本周，Lloyd Fournier 在 Lightning-Dev 邮件列表中发起了两个关于改进上述机制的讨论：

  - **<!--fast-recovery-without-backups-->****无需备份的快速恢复：** 支持资金快速恢复的静态单通道备份需要在每次打开新通道时创建新备份。如果你未能备份，唯一的选择是等待通道对方自行决定关闭通道。Fournier 提出了一个[建议][really static backups]，使用一种确定性密钥派生方法，允许节点搜索公共 LN 节点列表，将从 HD 钱包派生的私钥信息与每个节点的主公钥信息结合，确定是否与该节点有通道。这种备份策略仅适用于与公共节点打开的通道，这被认为是普通用户最常见的通道类型。

  - **<!--covert-request-for-mutual-close-->****隐秘请求相互关闭：** 现有的通道关闭机制要求通道对方广播他们的单方面承诺交易。更好的方法是使用相互关闭交易——这种方式占用的链上空间更少、费用更低，在链上无法识别为 LN 通道交易，并允许双方立即使用其资金。然而，相互关闭交易不包含任何惩罚机制，因此如果你请求关闭通道，而你的对方给出了一个不准确的相互关闭交易，你无法惩罚他们。在正常协议中，这不是问题——你只需广播最新状态，但如果你丢失了状态，则无法补救。

    Fournier 提出了一个[解决方案][oblivious mutual close]，使用一种称为[模糊传输][oblivious transfer]的密码学原语，允许对方向你发送加密的相互关闭交易，使得你可以使用它（关闭通道）或证明你无法解密它（允许他们安全地继续在通道中接受支付）。如果每次重新连接时使用此过程，你在获得恢复所需的所有信息之前不会向他们表明你丢失了任何数据。

- **<!--new-psbt-version-proposed-->****提出新版本 PSBT 的提案：** [BIP174][] 的作者 Andrew Chow，[提出][psbt2] 了一个新版本的部分签名的比特币交易（PSBT）的建议，新版本包含几个不向后兼容的功能，但大体上与当前版本 0 的 PSBT 相似。

## 服务和客户端软件的更改

*在这一月度特色中，我们重点介绍比特币钱包和服务的有趣更新。*

- **<!--bitcoin-wallet-tracker-adds-descriptor-support-->****Bitcoin Wallet Tracker 添加描述符支持：** Bitcoin Wallet Tracker 的 [0.2.0 版本][bwt 0.2.0] 增加了对追踪[输出脚本描述符][topic descriptors]的支持，并引入了 [libbwt][libbwt github]，一个允许基于 Electrum 的钱包轻松支持 Bitcoin Core 全节点的库。

- **<!--joinmarket-now-defaults-to-native-segwit-addresses-->****JoinMarket 现在默认使用原生 segwit 地址：** 尽管 JoinMarket 从 0.5.1 开始支持 segwit，但 [0.8.0 版本][joinmarket 0.8.0] 现在默认使用 Bech32 原生 segwit 地址进行 [coinjoins][topic coinjoin]。

- **<!--bisq-adds-segwit-for-trade-transactions-->****Bisq 为交易添加 segwit 支持：** 在此前[为存款和提现添加 Bech32 支持][news120 bisq segwit]的基础上，[Bisq v1.5.0][bisq bech32 blog] 添加了交易中的 segwit 支持，并实现了费用优化。

- **<!--psbt-toolkit-v0-1-2-released-->****PSBT Toolkit v0.1.2 发布：** [PSBT Toolkit][psbt toolkit github] 软件旨在提供一个友好的图形界面，用于 PSBT 交互，0.1.2 版本发布了各种改进。

- **<!--sparrow-adds-replace-by-fee-->****Sparrow 添加 Replace-By-Fee 支持：** [Sparrow 0.9.8][sparrow 0.9.8] 添加了 [Replace-By-Fee (RBF)][topic rbf] 功能并支持 [HWI][topic hwi] 1.2.1。

- **<!--ledger-live-adds-bitcoin-core-full-node-support-->****Ledger Live 添加 Bitcoin Core 全节点支持：** Ledger Live 使用开源的 [Ledger SatStack][satstack github] 应用程序，现在可以[连接到比特币全节点][ledger full node]以更私密的方式发送交易和提供余额，而无需使用 Ledger 的[区块浏览器][topic block explorers]。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找答案的首选之一——或者当我们有空时，也会帮助好奇或困惑的用户。在这一月度特色中，我们精选自上次更新以来发布的一些高票问答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--what-is-the-difference-between-native-segwit-and-bech32-->**[“原生 segwit” 和 “bech32” 有什么区别？]({{bse}}100434)： Murch 解释了 bech32 是用于编码原生 segwit v0 见证程序的方法；它等同于用于传统比特币地址的 base58check 编码。同样的 bech32 编码也被用于其他目的，例如 LN 发票。虽然 bech32 本来计划用于以后版本的 segwit 见证程序，但发现了一个[长度扩展变异][news78 bech32 mutability]问题，需要使用一种修改后的 bech32 地址格式，可能称为 “bech32m”，用于支付到 Taproot (P2TR) segwit v1 见证程序。

- **<!--what-makes-cross-input-signature-aggregation-complicated-to-implement-->**[是什么让跨输入签名聚合实现变得复杂？]({{bse}}100216)： Michael Folkson 引用了一篇 AJ Towns 的 Bitcoin 开发邮件列表[帖子][aj signature aggregation]，解释了在比特币中实现跨输入签名聚合的挑战。

- **<!--how-do-bip8-and-bip9-differ-how-are-they-alike-->**[BIP8 和 BIP9 有何不同，又有哪些相似之处？]({{bse}}100490)： Murch 概述了一些不同的激活方法：早期的软分叉使用区块版本的激活方法，BIP9 的支持多提案的激活方法，以及 BIP8 的区块高度和锁定调整以改进 BIP9。

## 发布与候选发布

*流行比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或协助测试候选版本。*

- [Bitcoin Core 0.21.0rc3][Bitcoin Core 0.21.0] 是此全节点实现及其关联钱包和其他软件的下一个主要版本的候选版本。请注意，macOS 版本的[签名二进制文件][macos signed]由于代码签名工具问题无法运行。[未签名版本][macos unsigned]（仍然可以用 [PGP 验证][pgp verification]）应该可以通过右键单击（或按住 Control 单击）上下文菜单运行。开发者正在努力解决此问题以供未来的候选版本和最终版本使用。

- [LND 0.12.0-beta.rc1][LND 0.12.0-beta] 是此 LN 节点下一个主要版本的第一个候选版本。默认为承诺交易[锚定输出][topic anchor outputs]，并在其[瞭望塔][topic watchtowers]实现中支持这些功能，降低成本并提高安全性，并增加了对创建和签署 [PSBT][topic psbt] 的通用支持。此外，还包含一些错误修复。

- **<!--n-->**Bitcoin Core 0.20.2rc1 和 0.19.2rc1 预计将在本 Newsletter 发布后[上线][bitcoincore.org/bin]。它们包含若干错误修复，例如 [Newsletter #110][news110 bcc19620] 中描述的一项改进，将防止它们重新下载未来无法理解的 taproot 交易。

## 值得注意的代码和文档更改

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]的值得注意的更改。*

- [Bitcoin Core #20564][] 对比特币核心信号支持 `addrv2` 消息（[BIP155][]）的方式进行了两项更改：
  - **<!--protocol-version-->***协议版本：* Bitcoin Core 仅与信号表明其使用 P2P 版本 70016 或更高版本的节点协商 `addrv2` 消息支持。此限制并非 BIP155 所要求，但发布测试表明，如果它们收到任何未知消息（包括 `sendaddrv2`），某些其他实现会断开与 Bitcoin Core 的连接。未来版本可能会恢复此更改，因此建议其他实现随时容忍连接中的未知 P2P 消息。
  - **<!--updated-bip-->***更新的 BIP：* `sendaddrv2` 消息现在将在 `version` 和 `verack` 消息之间发送，符合 BIP155 最新版本的要求。有关该 BIP 更改的更多信息，请参见 [BIPs #1043](#bips-1043)。

    此 PR 已在 [最新 V0.21 候选版本][Bitcoin Core 0.21.0] 中通过 [Bitcoin Core #20612][] 回溯应用。

- [Bitcoin Core #19776][] 更新了 `getpeerinfo` RPC，增加了两个新字段。`bip152_hb_to` 表明我们请求对等方通过发送 [BIP152][] 致密区块以高带宽模式（HB）中继新块，而无需等待请求特定区块。`bip152_hb_from` 表明对等方请求我们成为他们的高带宽对等方。默认情况下，每个节点选择[最多 3 个][hb peers]高带宽致密区块对等方。（尽管名称中有“高带宽”，与传统区块中继相比，高带宽模式并不消耗太多带宽；其优化用于新区块的快速中继，只是比 BIP152 的低带宽模式使用更多带宽。）

- [Bitcoin Core #19858][] 添加了一种寻找高质量对等方的新方法，旨在使 [eclipse 攻击][topic eclipse attacks]更难实现。它平均每五分钟打开一个出站连接，与一个新对等方同步区块头。如果对等方告诉节点关于新区块的信息，节点断开与现有仅区块中继对等方的连接，并将连接槽分配给新对等方；否则，新对等方被断开。只要节点知道至少一个其他诚实节点的 IP 地址，这种对等方轮换应该会增加持续分区攻击的成本，因为节点应该始终最终找到具有最多工作量的有效链。增加的轮换和安全性会略微减少网络中的打开侦听插槽数量，但预计它将通过更频繁的连接为整个网络建立桥梁，增加网络图的边缘，并提供更大的整体分区攻击安全性。

- [Bitcoin Core #18766][] 禁用在启用 `blocksonly` 配置选项时获取费用估算的能力。此带宽节省选项停止 Bitcoin Core 请求和中继未确认交易。然而，Bitcoin Core 的费用估算也依赖于跟踪交易需要多长时间才能确认。此前，当启用 `blocksonly` 时，Bitcoin Core 停止更新其估算值，但继续返回已生成的估算值，导致估算值越来越过时。此更改后，当启用 `blocksonly` 模式时，它将不返回任何估算值。

- [C-Lightning #4255][] 是一系列拉取请求中的第一个，用于*报价*的初始版本——即通过 LN 请求和接收发票的能力。一个常见的使用场景是商户生成一个二维码，客户扫描二维码，客户的 LN 节点通过 LN 将二维码中的一些详细信息（如订单 ID 号）发送给商户的节点，商户的节点通过 LN 返回一个发票，发票显示给用户（用户同意支付），然后完成支付。尽管目前使用 [BOLT11][] 发票已经可以实现此用例，但在尝试支付之前允许发送和接收节点直接通信提供了更多灵活性。这还支持 BOLT11 的一次性哈希锁无法实现的功能，例如订阅和捐赠的定期支付。有关更多信息，请参阅 [BOLT12 草案][BOLT12 draft]。

- [Eclair #1566][] 将所有连接处理逻辑抽象到一个前端节点中，该节点可以跨多个主机分布，以实现生产部署的高可用性。这些前端节点还以分布式方式处理 CPU/带宽密集型的 [BOLT7][] 消息，例如路由表相关的 gossip 和同步请求，提高了大型节点部署（如 ACINQ）的可扩展性。对于希望部署此更改的读者，可以使用 AWS Beanstalk 捆绑包，并且作者建议使用 AWS Secrets Manager 存储节点的私钥，此主题已在 [SuredBits 实地报告][suredbits] 中讨论。

- [Eclair #1610][] 允许在打开新通道时覆盖默认的中继费用，使用新的 `feeBaseMsat` 和 `feeProportionalMillionths` 选项。

- [LND #4779][] 允许节点声明尚未在使用[锚定输出][topic anchor outputs]的通道关闭时解决的支付（HTLC）。

- [BIPs #1043][] 更改了 [BIP155][] 的支持协商方式。此前，BIP 规定节点在从对等方接收到 `verack` 消息后发送 `sendaddrv2` 消息以表明支持 BIP155。现在，BIP 规定节点必须在连接建立时更早发送 `sendaddrv2` 消息，即在发送 `version` 和 `verack` 消息之间。此更改与 [BIP339][] 的 [wtxid 中继][wtxid relay]支持协商一致，也与今年早些时候向邮件列表提交的[特性协商][feature negotiation]通用方法一致。

  John Newbery 在 Bitcoin-dev 邮件列表上发布了[对 BIP155 自 2019 年 2 月提议以来所有更改的总结][jnewbery bip155]。

- [BOLTs #803][] 更新了 [BOLT5][]，为防止[交易固定][topic transaction pinning]攻击提出了建议。最近的[锚定输出][topic anchor outputs]对 LN 规范的更新允许在通道单方面关闭时结算的多个支付（HTLC）在同一交易中完成。然而，潜在问题在于其中一些输出可能支付给你的通道对方，使他们能够固定交易并阻止批处理中其他 HTLC 在其时间锁到期前确认。建议是在有足够时间时允许批量处理 HTLC 以实现最大效率，但在时间锁接近到期时将每个 HTLC 分成单独的交易，以避免固定问题。

## 更正

[Newsletter #87][news87 negotiation] 错误地声称“旧版本的 Bitcoin Core 如果某些消息未按特定顺序出现，将终止新连接”。我们提到了一个误解，即从 Bitcoin 0.2.9（2010 年 5 月）引入的 `version` 消息需要紧接 `verack` 消息。Optech 贡献者对 Bitcoin Core 旧版本的代码审查和测试未证实这一声明，我们已在原文中添加了更正。对此错误表示歉意。

## 假期出版计划

节日快乐！本期是我们今年最后一份常规 Newsletter。下周我们将发布年度特别回顾版。常规发布将于 1 月 6 日（周三）恢复。

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
