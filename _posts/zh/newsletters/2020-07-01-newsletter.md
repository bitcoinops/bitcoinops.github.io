---
title: 'Bitcoin Optech Newsletter #104'
permalink: /zh/newsletters/2020/07/01/
name: 2020-07-01-newsletter-zh
slug: 2020-07-01-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了一场关于 HTLC 相关挖矿激励的讨论，并给出了一则公告的链接：有人提议提供存储与中继预签名交易的服务。我们还照例收录了最近转录的演讲与对话、新版本与候选发布，以及热门比特币基础设施项目的值得注意的变更。

## 行动项

*本周无。*

## 新闻

- **<!--discussion-of-htlc-mining-incentives-->****HTLC 挖矿激励的讨论：** Itay Tsabary、Matan Yechieli、Ittay Eyal [在 Bitcoin-Dev 邮件列表中发布][tye post]了他们撰写的[论文][tye paper]。他们认为，理性的矿工应当愿意运行一个修改过的 Bitcoin 节点，让用户可以用一笔受时间锁约束、在未来某个时间点之前无法确认的交易来贿赂它。有了这笔贿赂，只要贿赂支付给矿工的费率明显高于它所要拦下的任何交易，矿工就不会确认那些本可立即被打包、却与贿赂相冲突的交易。

  如果这一理论成立，它会影响哈希时间锁定合约（HTLC）：这类合约可由一方（Alice）用原像立即结算，也可由另一方（Bob）在超时后结算。按作者的说法，如果 Bob 看到 Alice 用原像花费了该 HTLC，他就应当向矿工发送一笔与之冲突的超时结算交易，其费率要明显高于 Alice 的原像结算交易——即便矿工无法立即打包 Bob 的交易，这也等于贿赂矿工无视 Alice 的交易，等待确认他的替代交易。这样 Bob 就能偷走本应属于 Alice 的资金。HTLC 目前用于 LN、原子交换以及其他多种合约协议。

  论文作者提出了一个他们称为相互确保摧毁 HTLC（MAD-HTLC）的方案。该方案要求 Bob 提供一笔哈希锁定的保证金，使他在发送超时结算时必须揭示自己的原像。如果 Alice 和 Bob 都揭示了各自的原像，矿工就能同时拿走支付/退款金额和保证金抵押物，从而打消 Bob 靠贿赂矿工实施盗窃的动机。

  这种方法的缺点在于：它要求 Bob 动用更多抵押品，抬高了使用 HTLC 的成本；并且相比传统 HTLC，MAD-HTLC 在链上结算时会占用更多区块链空间，同样抬高成本。邮件列表的讨论中还有人[指出][harding mad miner]，当提供保证金一方的对手方本身是矿工时（例如 Alice 是矿工），MAD-HTLC 也可能存在自身的被盗问题。

  ZmnSCPxj [指出][zmnscpxj scorched earth]，其实已经存在一种机制能让 Alice 遏制 Bob 实施这次盗窃：Alice 可以采取[焦土政策][scorched earth]，把自己所有合法资金都花在手续费上，让 Bob 拿不到这些钱。理论上，这应当足以让 Bob 连尝试都不敢尝试。讨论中还[提到][nadahalli post]了 Majid Khabbazian、Tejaswi Nadahalli 和 Roger Wattenhofer 的另一篇[论文][knw paper]，该论文表明（除其他结论外）：只有在几乎所有矿工都改用这种接受贿赂的软件之后，该攻击在正常条件下才会变得特别有效。

  就短期、或许还有中期而言，对于那些接收方能在时间锁到期前很早就揭示原像的 HTLC，这种攻击似乎并不构成重大威胁。但长期来看，这是一个激励相容性问题，协议开发者可能要放在心上。

- **<!--proposed-service-for-storing-relaying-and-broadcasting-presigned-transactions-->****提案：存储、中继与广播预签名交易的服务：** Jacob Swambo 向 Bitcoin-Dev 邮件列表发出[征求意见][swambo rfc]，希望创建一套软件和协议，让应用能把预签名交易存放在第三方服务处，以便日后广播。该软件或许还能根据特定条件是否满足，来判断何时广播这些交易。这对[保险库][topic vaults]、[瞭望塔][topic watchtowers] 之类的软件可能有用。Swambo 请任何对这个想法感兴趣的人——尤其是想在自己协议中使用它的人——与他联系。

## 最近转录的演讲与对话

*[Bitcoin Transcripts][] 汇集了比特币技术演讲与讨论的转录稿。在这个月度栏目中，我们挑选上个月的部分转录稿加以介绍。*

- **<!--magical-bitcoin-->****Magical Bitcoin：** Alekos Filini 在 LA BitDevs 上介绍了 [Magical Bitcoin][magical bitcoin]，这是一套正在开发的、面向链上钱包开发者的工具与库。他解释说，选币逻辑和交易签名逻辑目前在多个项目中不得不反复重写多次，而 Magical Bitcoin 旨在用模块化、可扩展且经过同行评审的组件解决这个问题。更长远的目标是提供一个构建原生钱包并与现有项目集成的平台。Filini 演示了现有功能，包括一个能把 Policy 编译为 [Miniscript][topic miniscript] 的演练场以及一些基础的可视化。该软件用 Rust 编写，并利用了 rust-miniscript 库和开源的 Esplora 区块浏览器。（[转录][mb ts]、[视频][mb vid]）

- **<!--watchtowers-and-bolt13-->****瞭望塔和 BOLT13：** Sergi Delgado 出现在 [Potzblitz][] 节目中讨论了[瞭望塔][topic watchtowers]开发的最新进展以及提议的瞭望塔协议规范。他探讨了设计瞭望塔时在隐私要求、可访问性、存储和收取的手续费之间的各种权衡。Delgado 正在 Talaia Labs 开发名为 [The Eye of Satoshi][teos] 的瞭望塔实现，该项目旨在符合提议的 BOLT13（参见 [Newsletter #75][news75 watchtower bolt]）。Delgado 还强调，除 LN 之外，瞭望塔在比特币[保险库][topic vaults]设计、状态链（statechain）和原子交换等多种场景中也正变得愈发关键。（[转录][watchtowers ts]、[视频][watchtowers vid]、[幻灯片][watchtowers slides]）

- **<!--coinswap-->****Coinswap：** Aviv Milner 在 Wasabi Research Club 上介绍了 coinswap。他解释了“隐蔽性”（covertness）这一属性，以及 Chris Belcher 的 coinswap 提案（参见 [Newsletter #100][news100 coinswap]）如何以其他隐私方案（如 [coinjoin][topic coinjoin]）无法做到的方式提供隐蔽性。Milner 还讲解了路由 coinswap 的动机，即解决这样一个顾虑：无意中与区块链监控公司之类的对手方做了一笔 coinswap。（[转录][coinswap ts]、[视频][coinswap vid]）

- **<!--schnorr-signatures-and-multisignatures-->****Schnorr 签名和多重签名：** [BIP340][] 的共同作者 Tim Ruffing、Pieter Wuille 和 Jonas Nick 在 London Bitcoin Devs 会议上讨论了 [Schnorr 签名][topic schnorr signatures]的规范。讨论涵盖了在比特币中实现 Schnorr 签名的早期想法以及共同作者认为社区在考虑未来软分叉部署时应该关注的问题。Wuille 提到，他最关心的是 Schnorr 的采用方式以及基于它构建的内容。第二天，Tim Ruffing 介绍了使用 Schnorr 签名的多重签名和门限签名方案的挑战（参见 [Newsletter #68][news68 ruffing]）。他与合作者一起在研究一种设想中的 [MuSig][topic musig] 签名方案，只需两轮交互而非三轮，且不依赖零知识证明，这将大大简化某些门限签名与多重签名的签署流程。（[会议转录][socratic ts]、[会议视频][socratic vid]、[演讲转录][ruffing ts]、[演讲视频][ruffing vid]、[演讲幻灯片][ruffing slides]）

- **<!--sydney-meetup-discussion-->****悉尼聚会讨论：** 多位比特币与 LN 开发者参加了这次悉尼聚会，讨论了多个话题。Ruben Somsen 简短介绍了简洁原子交换（SAS）（参见 [Newsletter #98][news98 sas]），以及它与 Chris Belcher 的 coinswap 提案的对比。另一个话题是 Bitcoin Core 依赖 DNS 种子寻找初始对等节点，这是否构成针对新启动节点的潜在攻击向量，以及 Matt Corallo 和 Antoine Riard 在允许[替代传输方式][Bitcoin Core #18988] 方面的工作如何帮助缓解部分风险。最后，Lloyd Fournier 讲述了他拿自己的 Rust 玩具实现 secp256k1（secp256kfun）做实验，如何促成了实际 secp256k1 库 ECDSA 签名代码中的一处小[修复][libsecp256k1 #732]。为鼓励坦诚讨论，转录稿做了匿名化处理。（[转录][sydney ts]）

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [硬件钱包接口（HWI） 1.1.2][hwi 1.1.2]：此版本新增了处理带已序列化前序 segwit 交易的 [PSBT][topic psbt] 的能力。为应对[手续费超额支付攻击][news101 fee overpayment]，目前已有多个硬件钱包要求或建议这样做。

- [LND 0.10.2-beta.rc4][lnd 0.10.2-beta]：这一 LND 维护版本的候选版本现已可供测试，其中包含多项错误修复，包括一项与备份创建相关的重要修复。

- [LND 0.10.3-beta.rc1][lnd 0.10.3-beta]：这个候选版本与 0.10.2 的 RC 相互独立，除包含 0.10.2 中的错误修复外，还包含一次包重构。详情请参见 LND 开发者 Olaoluwa Osuntokun 的邮件列表[帖子][osuntokun rcs]。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口][hwi]、[比特币改进提案（BIPs）][bips repo]和[闪电网络 BOLT 规范][bolts repo]中的值得注意的变更。*

- [Bitcoin Core #19305][] 为代码库即将从 C++11 标准过渡到 C++17 补充了发布说明。计划在 0.21 版本中引入 C++17 兼容（[预计][Bitcoin Core #18947] 在 2020 年底），并在 0.22 版本中不再兼容 C++11（预计 2021 年中）。虽然这一变化不会影响大多数用户，但计划在较旧系统上构建 0.22 版本的人，最好对照 [C++ 编译器支持矩阵][cpp compiler support] 检查自家工具链的标准支持情况。

- [Bitcoin Core #11413][] 更新了 `bumpfee`、`fundrawtransaction`、`sendmany`、`sendtoaddress` 和 `walletcreatefundedpsbt` 这几个 RPC，允许手动指定新建或更新交易要用的费率。默认情况下，这些命令仍使用 Bitcoin Core 内置手续费估算得出的自动费率；若估算数据不足，则使用后备费率。关于如何使用更新后的 RPC，详见[提议的发布说明][bcc11413rn]。尽管这个改动不影响任何主要系统，该 PR 却开放了近三年——是迄今合并进 Bitcoin Core 的 PR 中耗时第二长的一个。我们感谢作者 Kalle Alm 以及所有其他参与者的坚持。

- [Eclair #1466][] 缩短了在对等节点于 HTLC 待定期间失去响应时，Eclair 节点等待多久才关闭通道的时间。为防止支付永远卡住，每个 HTLC 都带有时间锁。时间锁一旦到期，发送方就可以收回 HTLC 中的资金。为防止发送方撤回中间方已支付给下一跳的资金，当发送方失去响应时，中间方必须在链上结算该待定 HTLC。此 PR 扩大了 Eclair 的安全窗口——现在它会在 HTLC 超时前 24 个区块广播链上交易，而以前是提前 6 个区块。

- [LND #4018][] 新增了延迟转发支付（HTLC）的能力，让外部进程可以审查该支付，并决定取消还是继续转发。这类似于[挂起发票][topic hold invoices]，但它适用于路由给节点对等方的支付，而非节点自身收到的支付。PR 中描述了若干用例——例如一种思路是挂起一笔 HTLC，检测到它的下一跳离线（比如是个移动节点）后，向该节点发送通知让它重启，然后继续中继这笔 HTLC。

- [LND #4106][] 增加了 `getrecoveryinfo` RPC，它返回有关从备份恢复的进度的信息。

- [BIPs #933][] 加入了 [BIP339][] 规范：使用见证交易标识符（wtxid）来公告交易中继。目前，节点用交易的 txid 向对等节点公告新的未确认交易，而 txid 是对交易传统字段的哈希。segwit 交易中启用的新字段并不包含在 txid 里，这是为了消除第三方与对手方交易的可延展性所必需的。然而，Peter Todd 在 2016 年 6 月审查 segwit 时[注意到][todd relay malleability]，按 txid 公告交易会使得节点可以在中继前修改 segwit 字段。这不能直接用来偷钱，但确实让中继节点能把一笔有效交易改成无效或不可接受的交易，而 txid 保持不变。

  在 Todd 发现这一问题之前，它确实是个麻烦：Bitcoin Core 会记录近期见过的无效交易的 txid，并拒绝再次下载这些交易。这意味着一个恶意节点只要向对等节点发送某一笔有效 segwit 交易的变异版本，就能阻止这些对等节点从其他任何对等节点下载该交易。任意审查交易——哪怕只发生在中继层面——本身就非常糟糕，而对 LN 这类对时间敏感的协议，后果尤其严重。

  在 Todd 分析之时，segwit 已临近发布，因此实现了一个[快速修复][Bitcoin Core #8312]：它阻止 Bitcoin Core 缓存那些因恶意节点可注入的见证相关错误而失败的 segwit 交易的拒绝状态。这消除了该问题，但代价是 Bitcoin Core 遇到因意外失误而无效的 segwit 交易时，会占用比实际需要更多的带宽。它也可能让[交易包中继][topic package relay]之类新中继协议的开发变得更复杂。

  该问题的长期解法是：公告交易时应使用一个承诺整笔交易（既包括传统字段，也包括新的 segwit 字段）的哈希。wtxid 正是这样的哈希，而且协议本来就需要用它来构造每个区块 币基交易中的见证默克尔根。这个新 BIP 提议更新 P2P 协议中用于公告新交易的 `inv` 消息和用于请求交易的 `getdata` 消息，让两者都能使用 wtxid。这样，如果某笔交易的 wtxid 与此前判定为无效或不可接受的交易相同，节点就能跳过重复下载。

  BIP339 提案还加入了 [Newsletter #87][news87 negotiation] 中所述、新启动节点之间的附加功能协商。另见 Bitcoin Core 的[提议实现][Bitcoin Core #18044]。

- [BIPs #923][] 加入了 [BIP78][] 规范，对应最早在 BTCPay 中实现的 [payjoin][topic payjoin]（付款合并）协议版本（参见 [Newsletter #94][news94 btcpayjoin]）。payjoin 允许付款方和收款方都向同一笔交易添加 UTXO，从而削弱第三方区块链监控公司的一个假设：在同一笔交易中被花费的一组 UTXO 都属于同一个人。BIP78 基于 Bustapay 这一 payjoin 变体的 [BIP79][] 规范（参见 [Newsletter #13][news13 bustapay]），但有几处值得注意的差异，包括对 [BIP21][] `bitcoin:` URI 的不同扩展方式、使用 PSBT，以及一些旨在增强隐私的附加要求。已有多个程序支持该协议，还有几个正在添加支持。此 BIP 的 PR 引发了大量讨论，对任何关心该主题的人都可能是有用的参考材料。

- [BIPs #550][] 修订了 [BIP8][]——它是基于版本位（versionbits）的软分叉部署方案 [BIP9][] 的替代选择。此前，BIP8 允许用与 BIP9 相同的参数、通过矿工信号来激活软分叉，但要求在信号期结束时必须激活，即使矿工仍未发出准备遵循新共识规则的信号。这可以用来压过那些阻挠分叉激活的矿工，但也可能导致执行了该分叉新共识规则的节点与未执行的节点之间出现区块链分裂。

  BIP8 相对上一版的主要变化是：现在起初可以不要求强制锁定（mandatory lock-in）就使用它。各实现可以在首次部署由 BIP8 激活的软分叉之后，再选择承诺锁定。BIP8 规定在强制锁定高度之后的一段时间内仍需信令，这会让没有强制锁定的部署也与强制锁定节点在同一时间开始执行新规则；最好的情况下，整个经济体系能同步开始执行新规则。

{% include references.md %}
{% include linkers/issues.md issues="1466,19305,11413,4018,4106,933,923,550,8312,18044,18988,732,18947" %}
[lnd 0.10.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.10.2-beta.rc4
[lnd 0.10.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.10.3-beta.rc1
[hwi 1.1.2]: https://github.com/bitcoin-core/HWI/releases/tag/1.1.2
[tye post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-June/017997.html
[tye paper]: https://arxiv.org/abs/2006.12031
[harding mad miner]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-June/018010.html
[zmnscpxj scorched earth]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-June/017998.html
[scorched earth]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2013-May/002632.html
[harding myopic]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-June/018009.html
[news101 fee overpayment]: /zh/newsletters/2020/06/10/#fee-overpayment-attack-on-multi-input-segwit-transactions
[bcc11413rn]: https://github.com/kallewoof/bitcoin/blob/25dac9fa65243ca8db02df22f484039c08114401/doc/release-notes-11413.md
[todd relay malleability]: https://petertodd.org/2016/segwit-consensus-critical-code-review#peer-to-peer-networking
[news94 btcpayjoin]: /zh/newsletters/2020/04/22/#btcpay-adds-support-for-sending-and-receiving-payjoined-payments
[news13 bustapay]: /zh/newsletters/2018/09/18/#bustapay-discussion
[swambo rfc]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-June/017996.html
[news87 negotiation]: /zh/newsletters/2020/03/04/#improving-feature-negotiation-between-full-nodes-at-startup
[knw paper]: https://eprint.iacr.org/2020/774
[nadahalli post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-June/018015.html
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
