---
title: 'Bitcoin Optech Newsletter #104'
permalink: /zh/newsletters/2020/07/01/
name: 2020-07-01-newsletter-zh
slug: 2020-07-01-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了一个关于 HTLC 挖矿激励的讨论，并链接到一个关于提议的服务公告，该服务用于存储和中继预签名交易。此外，还包括我们常规部分的最近转录的演讲和对话、新版本和候选发布、以及流行的比特币基础设施项目的值得注意的更改。

## 行动项

*本周无。*

## 新闻

- **<!--discussion-of-htlc-mining-incentives-->****HTLC 挖矿激励的讨论：** Itay Tsabary、Matan Yechieli、Ittay Eyal [在 Bitcoin-Dev 邮件列表中发布][tye post]了他们撰写的[论文][tye paper]。他们认为理性的矿工应当运行一个修改过的 Bitcoin 节点，允许用户通过一个时间锁定的交易来贿赂矿工，该交易在未来的某个时间点之前不能被确认。作为这种贿赂的结果，只要贿赂支付的费用率足够高，矿工就不会确认与贿赂冲突且能够立即被挖到的其他交易。

  如果这一理论准确，那么它将影响 Hash TimeLock 合约（HTLC），在其中一方（Alice）可以使用前置图立即结算，而另一方（Bob）则可以在超时后结算。据作者称，如果 Bob 看到 Alice 使用前置图花费了 HTLC，他应该向矿工发送一个冲突的超时结算交易，并且其费用率要足够高于 Alice 的前置图结算，即使矿工不能立即包含 Bob 的交易，这也会贿赂矿工忽略 Alice 的交易而等待确认他的替代交易。这使得 Bob 可以窃取原本应归 Alice 的资金。HTLC 目前在闪电网络、原子交换和其他多种合约协议中使用。

  论文的作者提出了一种称为互保摧毁 HTLC（MAD-HTLCs）的解决方案。这需要 Bob 提供一个哈希锁定的保证金，使得当他发送超时结算时需要揭示他自己的前置图。如果 Alice 和 Bob 都揭示了各自的前置图，矿工将能够获得支付/退款金额和保证金抵押物，从而破坏 Bob 通过贿赂矿工试图窃取的激励。

  这种方法的缺点是它要求 Bob 使用更多的抵押品，从而增加了使用 HTLC 的成本，并且在链上结算 MAD-HTLC 时使用了更多的区块链空间，也提高了成本。此外，在邮件列表讨论中，有人[声称][harding mad miner]，当担保用户的对手方是矿工时（例如 Alice 是矿工），MAD-HTLCs 可能存在自己的盗窃问题。

  ZmnSCPxj [指出][zmnscpxj scorched earth]，Alice 已经有一个机制可以阻止 Bob 尝试盗窃：Alice 可以采取[焦土政策][scorched earth]，即将她所有合法的资金用于支付手续费，以防止 Bob 获取它们。理论上，这应该能够阻止 Bob 尝试盗窃。此外，在讨论中还[提到][nadahalli post]了由 Majid Khabbazian、Tejaswi Nadahalli 和 Roger Wattenhofer 撰写的另一篇[论文][knw paper]，该论文显示（除其他事项外），在正常情况下，几乎所有的矿工都需要切换到提议的接受贿赂的软件，这种攻击才会变得特别有效。

  从短期和可能的中期来看，这种攻击似乎对那些接收者在超时之前很好地解决其前置图的 HTLC 不会构成重大威胁。从长期来看，这是一个协议开发者可能需要记住的激励兼容性问题。

- **<!--proposed-service-for-storing-relaying-and-broadcasting-presigned-transactions-->****提议的存储、中继和广播预签名交易的服务：** Jacob Swambo 向 Bitcoin-Dev 邮件列表发送了一个[评论请求][swambo rfc]，讨论创建一个软件和协议，允许应用程序与第三方服务存储预签名交易以便稍后广播。该软件还可以根据满足某些条件来决定何时广播这些交易。这对于诸如[保险库][topic vaults]和[瞭望塔][topic watchtowers]等软件可能很有用。Swambo 邀请任何对此想法感兴趣的人，特别是希望在其协议中使用该想法的人与他联系。

## 最近转录的演讲和对话

*[Bitcoin Transcripts][] 是技术性比特币演讲和讨论的转录内容的家园。在这个月度特色部分中，我们重点介绍了上个月的一些精选转录内容。*

-**<!--magical-bitcoin-->** **Magical Bitcoin：** Alekos Filini 在 LA BitDevs 会议上介绍了 [Magical Bitcoin][mb ts]，这是一个正在开发的面向链上钱包开发者的工具和库集。他解释了目前的币选择逻辑和交易签名逻辑需要在多个项目中多次重写的问题，Magical Bitcoin 旨在通过模块化、可扩展和同行评审的组件来解决这一问题。长期的目标是提供一个构建原生钱包并与现有项目集成的平台。Filini 展示了当前的功能，包括一个带有 Policy 到 [Miniscript][topic miniscript] 编译器的游乐场和一些基本的可视化功能。它使用 Rust 编写，并利用了 rust-miniscript 库和开源的 Esplora 区块浏览器。([视频][mb vid])

- **<!--watchtowers-and-bolt13-->****瞭望塔和 BOLT13：** Sergi Delgado 出现在 [Potzblitz][] 节目中讨论了[瞭望塔][topic watchtowers]开发的最新进展以及提议的瞭望塔协议规范。他探讨了设计瞭望塔时在隐私要求、可访问性、存储和收取的费用之间的各种权衡。Delgado 正在 Talaia Labs 开发名为 [The Eye of Satoshi][teos] 的瞭望塔实现，该项目旨在符合提议的 BOLT13（参见 [Newsletter #75][news75 watchtower bolt]）。Delgado 还强调了瞭望塔在多种场景中变得越来越重要，如比特币[保险库][topic vaults]设计、状态链和原子交换，以及闪电网络。([视频][watchtowers vid], [幻灯片][watchtowers slides])

- **<!--coinswap-->****Coinswap：** Aviv Milner 在 Wasabi Research Club 上介绍了 coinswap。他解释了隐蔽性属性，以及 Chris Belcher 的 coinswap 提案（参见 [Newsletter #100][news100 coinswap]）如何以其他隐私方案（如 [Coinjoin][topic coinjoin]）无法做到的方式提供隐蔽性。Milner 还讨论了 coinswap 路由的动机，即解决无意中进入与链上监控公司等对手的 coinswap 的担忧。([视频][coinswap vid])

- **<!--schnorr-signatures-and-multisignatures-->****Schnorr 签名和多重签名：** [BIP340][] 的共同作者 Tim Ruffing、Pieter Wuille 和 Jonas Nick 在 London Bitcoin Devs 会议上讨论了 [Schnorr 签名][topic schnorr signatures]的规范。讨论涵盖了在比特币中实现 Schnorr 签名的早期想法以及共同作者认为社区在考虑未来软分叉部署时应该关注的问题。Wuille 提到，他最关心的是 Schnorr 的采用方式以及基于它构建的内容。第二天，Tim Ruffing 介绍了使用 Schnorr 签名的多重签名和门限签名方案的挑战（参见 [Newsletter #68][news68 ruffing]）。他与合作者一起在研究一个投机性的 [MuSig][topic musig] 签名方案，该方案仅需要两轮交互，而不是三轮交互，不依赖零知识证明，从而大大简化了一些门限和多重签名的签名工作流程。([会议视频][socratic vid], [演讲幻灯片][ruffing slides])

- **<!--sydney-meetup-discussion-->****悉尼聚会讨论：** 多位比特币和闪电网络开发者加入了此次悉尼聚会，讨论了各种话题。Ruben Somsen 简短介绍了简明原子交换（SAS）（参见 [Newsletter #98][news98 sas]）以及其与 Chris Belcher 的 coinswap 提案的对比。另一个话题是 Bitcoin Core 依赖 DNS 种子来寻找初始节点，是否会成为对新启动节点的潜在攻击向量，以及 Matt Corallo 和 Antoine Riard 在允许[替代传输][Bitcoin Core #18988]方面的工作如何有助于减轻一些风险。最后，Lloyd Fournier 讨论了他用 secp256k1 的 Rust 玩具实现（secp256kfun）进行实验时如何在实际的 secp256k1 库的 ECDSA 签名代码中做了一个小[修复][libsecp256k1 #732]。为了鼓励开放讨论，转录内容进行了匿名化。([转录][sydney ts])

## 发布与候选发布

*流行的比特币基础设施项目的新发布和候选发布。请考虑升级到新版本或帮助测试候选发布。*

- [Hardware Wallet Interface (HWI) 1.1.2][hwi 1.1.2]：此版本增加了对带有序列化的之前 segwit 交易的 [PSBTs][topic psbt] 的支持，这是为了应对[手续费超额支付攻击][news101 fee overpayment]，现在被多个硬件钱包所需要或建议。

- [LND 0.10.2-beta.rc4][lnd 0.10.2-beta]：此候选版本是 LND 维护版本的最新测试版，包含了多个错误修复，其中包括与备份创建相关的重要修复。

- [LND 0.10.3-beta.rc1][lnd 0.10.3-beta]：这个候选版本独立于 0.10.2 版本，包含了 0.10.2 中的错误修复以及一个包重构。详情请参见 LND 开发者 Olaoluwa Osuntokun 的邮件列表[帖子][osuntokun rcs]。

## 值得注意的代码和文档更改

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface][hwi]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的更改。*

- [Bitcoin Core #19305][] 为即将从 C++11 标准过渡到 C++17 的代码库添加了发布说明。计划在 0.21 版本中添加 C++17 兼容性（[预计][Bitcoin Core #18947] 于 2020 年底），并在 0.22 版本中打破 C++11 兼容性（预计 2021 年中期）。虽然这次变化不会影响大多数用户，但那些计划在较旧系统上构建 0.22 版本的人可能需要检查其工具链的标准支持是否符合 [C++ 编译器支持矩阵][cpp compiler support]。

- [Bitcoin Core #11413][] 更新了 `bumpfee`、`fundrawtransaction`、`sendmany`、`sendtoaddress` 和 `walletcreatefundedpsbt` RPC，以允许手动指定新创建或更新的交易所使用的费用率。默认情况下，这些命令仍然使用 Bitcoin Core 内置交易费用估算得出的自动费用率，或者在估算数据不足时使用的备用费用率。有关如何使用更新后的 RPC 的详细信息，请参见[提议的发布说明][bcc11413rn]。尽管此更改并未影响任何主要系统，但该拉取请求开放了近三年——成为 Bitcoin Core 中合并的第二长拉取请求。我们感谢作者 Kalle Alm 及所有其他参与者的坚持不懈。

- [Eclair #1466][] 减少了当一个节点在 HTLC 待定期间变得无响应时，Eclair 节点等待关闭通道的时间。为了防止支付永远卡住，每个 HTLC 都包含一个时间锁。如果时间锁过期，则发送方可以收回 HTLC 中的资金。为了防止发送方撤回一个中间方已经支付给下一跳的资金，如果发送方变得无响应，中间方必须在链上结算待定的 HTLC。此拉取请求增加了 Eclair 的安全窗口——它现在将在 HTLC 超时之前的 24 个区块广播链上交易，而不是之前的 6 个区块。

- [LND #4018][] 增加了延迟转发付款（HTLC）的功能，允许一个外部进程审查它并决定是否取消或继续转发。这类似于[保持发票][topic hold invoices]，但它适用于路由到节点的同行的付款，而不是节点本身接收的付款。拉取请求中描述了几个用例——例如，一个想法是持有一个 HTLC，检测到它的下一跳节点离线（例如，一个移动节点），向该节点发送通知以重新启动它，然后继续中继 HTLC。

- [LND #4106][] 增加了 `getrecoveryinfo` RPC，它返回有关从备份恢复的进度的信息。

- [BIPs #933][] 添加了 [BIP339][] 规范，用于使用见证交易标识符（wtxids）进行交易中继公告。目前，节点通过交易的 txid 来向其对等节点宣布新的未确认交易，该 txid 是交易的传统字段的哈希。然而，segwit 交易中使用的新字段并未包含在 txid 中，这是为了消除第三方和对手方交易的可篡改性。然而，在 2016 年 6 月对 segwit 的审查中，Peter Todd [注意到][todd relay malleability]，通过其 txid 宣布交易可能允许节点在中继交易之前修改 segwit 字段。这不能直接用于窃取资金，但确实允许中继节点将一个有效的交易变异为无效或不可接受的交易，而不更改其 txid。

  在 Todd 分析的时候，这个问题很严重：Bitcoin Core 会跟踪它最近看到的无效交易的 txid，并拒绝再次下载它们。这意味着一个恶意节点可以通过向其对等节点发送一个变异版本的交易来阻止它们从其他对等节点下载一个有效的 segwit 交易。任意的交易中继级别的审查本身就很糟糕——但它对诸如闪电网络等时间敏感的协议有特别严重的后果。

  在 Todd 的分析时，segwit 接近发布，因此实施了一个[快速修复][Bitcoin Core #8312]，该修复阻止 Bitcoin Core 缓存由于恶意节点可以注入的见证相关错误而失败的 segwit 交易的拒绝状态。这消除了问题，但意味着 Bitcoin Core 在遇到由于意外错误而无效的 segwit 交易时会使用比必要更多的带宽。它也可能使诸如[包中继][topic package relay]等新中继协议的开发变得复杂。

  该问题的长期解决方案是，交易应使用一个承诺整个交易（包括传统字段和新的 segwit 字段）的哈希进行宣布。wtxids 正是这样做的，并且在协议中已经用于在每个区块的 coinbase 交易中构建见证默克尔树。这个新的 BIP 提议更新 P2P 协议的 `inv` 消息（用于宣布新交易）和 `getdata` 消息（用于请求交易），以允许它们使用 wtxids。这将使节点能够跳过重新下载一个与先前发现无效或不可接受的交易具有相同 wtxid 的交易。

  BIP339 提案还增加了在 [Newsletter #87][news87 negotiation] 中描述的刚启动节点之间的附加功能协商。另请参阅 [Bitcoin Core #18044] 中的提议实现。

- [BIPs #923][] 添加了 [BIP78][] 规范，这是最初在 BTCPay 中实现的[支付合并][topic payjoin]协议的版本（参见 [Newsletter #94][news94 btcpayjoin]）。支付合并允许付款方和收款方都在交易中添加 UTXO。这减少了第三方链上监控公司所做的假设的可靠性，即在同一交易中消费的所有 UTXO 都由同一个人接收。BIP78 基于 Bustapay 变体的 [BIP79][] 规范（参见 [Newsletter #13][news13 bustapay]），但包含几个值得注意的差异，包括对 [BIP21][] `bitcoin:` URI 的不同扩展、使用 PSBT 以及一些旨在增强隐私的附加要求。几个程序已经支持该协议，还有几个程序正在添加支持。此 BIP 的拉取请求受到了广泛讨论，可能为对该主题感兴趣的任何人提供有用的参考资料。

- [BIPs #550][] 修订了基于版本位的软分叉部署的 [BIP8][] 替代方案 [BIP9][]。BIP8 之前允许使用与 BIP9 相同的参数通过矿工信号激活软分叉，但要求在信号期结束时即使矿工仍未信号表明准备遵循新的共识规则，也必须激活软分叉。这可以用来覆盖阻碍分叉激活的矿工，但也可能导致那些没有执行新共识规则的节点与那些执行新共识规则的节点之间的区块链分叉。

  从之前的版本到现在，BIP8 的主要变化是，它现在可以在最初的部署中不需要强制锁定。实现可以选择在其最初的 BIP8 激活的软分叉部署之后承诺锁定。BIP8 规定在强制锁定高度之后的一个时间段内进行信号，这将触发即使没有强制锁定的部署也在与强制锁定节点相同的时间开始执行新规则；在最佳情况下，这允许整个经济同步开始执行新规则。

{% include references.md %}
{% include linkers/issues.md issues="1466,19305,11413,4018,4106,933,923,550,8312,18044,18988,732,18947" %}
[lnd 0.10.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.10.2-beta.rc4
[lnd 0.10.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.10.3-beta.rc1
[hwi 1.1.2]: https://github.com/bitcoin-core/HWI/releases/tag/1.1.2
[tye post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-June/017997.html
[tye paper]: https://arxiv.org/abs/2006.12031
[harding mad miner]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-June/018010.html
[zmnscpxj scorched earth]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-June/017998.html
[scorched earth]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2013-May/002632.html
[harding myopic]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-June/018009.html
[news101 fee overpayment]: /zh/newsletters/2020/06/10/#fee-overpayment-attack-on-multi-input-segwit-transactions
[bcc11413rn]: https://github.com/kallewoof/bitcoin/blob/25dac9fa65243ca8db02df22f484039c08114401/doc/release-notes-11413.md
[todd relay malleability]: https://petertodd.org/2016/segwit-consensus-critical-code-review#peer-to-peer-networking
[news94 btcpayjoin]: /zh/newsletters/2020/04/22/#btcpay-adds-support-for-sending-and-receiving-payjoined-payments
[news13 bustapay]: /zh/newsletters/2018/09/18/#bustapay-discussion
[swambo rfc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-June/017996.html
[news87 negotiation]: /zh/newsletters/2020/03/04/#improving-feature-negotiation-between-full-nodes-at-startup
[knw paper]: https://eprint.iacr.org/2020/774
[nadahalli post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-June/018015.html
[osuntokun rcs]: https://groups.google.com/a/lightning.engineering/forum/#!topic/lnd/jgd1ZC9T5n4
[mb ts]: https://diyhpl.us/wiki/transcripts/la-bitdevs/2020-05-21-alekos-filini-magical-bitcoin/
[mb vid]: https://www.youtube.com/watch?v=QVhC2DOIl7I
[watchtowers ts]: https://diyhpl.us/wiki/transcripts/lightning-hack-day/2020-05-24-sergi-delgado-watchtowers/
[watchtowers vid]: https://www.youtube.com/watch?v=Vkq9CVxMclE
[watchtowers slides]: https://srgi.me/resources/slides/Potzblitz!2020-Watchtowers.pdf
[coinswap ts]: https://diyhpl.us/wiki/transcripts/wasabi-research-club/2020-06-15-coinswap/
[coinswap vid]: https://www.youtube.com/watch?v=Pqz7_Eqw9jM
[socratic ts]: https://diyhpl.us/wiki/transcripts/london-bitcoin-devs/2020-06-16-socratic-seminar-bip-schnorr/
[ruffing ts]: https://diyhpl.us/wiki/transcripts/london-bitcoin-devs/2020-06-17-tim-ruffing-schnorr-multisig/
[socratic vid]: https://www.youtube.com/watch?v=uE3lLsf38O4
[ruffing vid]: https://www.youtube.com/watch?v=8Op0Glp9Eoo
[ruffing slides]: https://slides.com/real-or-random/taproot-and-schnorr-multisig
[sydney ts]: https://diyhpl.us/wiki/transcripts/sydney-bitcoin-meetup/2020-06-23-socratic-seminar/
[magical bitcoin]: https://magicalbitcoin.org/
[news75 watchtower bolt]: /zh/newsletters/2019/12/04/#proposed-watchtower-bolt
[news98 sas]: /zh/newsletters/2020/05/20/#two-transaction-cross-chain-atomic-swap-or-same-chain-coinswap
[teos]: https://github.com/talaia-labs/python-teos
[news74 wagner]: /zh/newsletters/2019/11/27/#schnorr-taproot-updates
[news100 coinswap]: /zh/newsletters/2020/06/03/#design-for-a-coinswap-implementation
[potzblitz]: https://www.youtube.com/playlist?list=PLwgam6YBS0-jk1TlXD7QXDjTYJh-eJn_X
[news68 ruffing]: /zh/newsletters/2019/10/16/#the-quest-for-practical-threshold-schnorr-signatures
[cpp compiler support]: https://en.cppreference.com/w/cpp/compiler_support#C.2B.2B17_features
[hwi]: https://github.com/bitcoin-core/HWI
