---
title: 'Bitcoin Optech Newsletter #100'
permalink: /zh/newsletters/2020/06/03/
name: 2020-06-03-newsletter-zh
slug: 2020-06-03-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了一个 coinswap 实现的设计方案，介绍了一种让轻量钱包直接向用户自己的节点请求信息的新中间件，并重点介绍两个交易大小计算器。此外还有我们的常设栏目：几场最近转录的演讲介绍、新版本与候选发布，以及热门比特币基础设施软件中值得注意的变更。最后还有一个特别章节，庆祝 Newsletter 第 100 期的出版。

## 行动项

*本周无。*

## 新闻

- **<!--design-for-a-coinswap-implementation-->****coinswap 实现设计：** Chris Belcher [发布][belcher coinswap]了一个功能齐全的 coinswap 实现设计。Coinswap 是一种协议，它允许两个用户创建一对看起来像普通支付但实际上交换他们各自的币的交易。这不仅提高了 coinswap 用户的隐私，也提升了所有比特币用户的隐私，因为任何看起来像支付的行为都可能实际上是一次 coinswap。

  Belcher 的帖子回顾了 coinswap 这一构想的历史，建议把 coinswap 所需的多重签名条件伪装成更常见的交易类型，提议借助流动性市场（JoinMarket 已经在这么做），介绍了通过分割与路由技术来减少因金额关联或参与者窥探造成的隐私损失，提到简洁原子交换等替代性 coinswap 协议（见 [Newsletter #98][news98 sas]），建议把 coinswap 与 [payjoin][topic payjoin] 结合起来，并讨论了该系统的一些后端需求。此外，他还把 coinswap 与其他隐私技术作了比较，例如使用闪电网络、[coinjoin][topic coinjoin]、payjoin 和 [payswap][zmn payswap]。

  Belcher 长期以来一直在为比特币创建和维护隐私增强类开源软件，例如 [JoinMarket][] 和 [Electrum Personal Server][eps]，这让他邮件结语中的话格外有分量：“我打算把这个 CoinSwap 软件做出来。它将几乎完全去中心化，所有人都可以免费使用。”

- **<!--new-node-to-wallet-middleware-->****新的节点到钱包中间件：** Nadav Ivgi [宣布][ivgi bwt] Bitcoin Wallet Tracker（BWT）进入 alpha 版本。这个程序通过标准 RPC 接口与 Bitcoin Core 的钱包交互，用其中的数据构建轻量钱包所需的附加索引，再通过 Electrum 服务器协议和 BWT 自有的[功能丰富的 HTTP API][bwt api] 提供这些数据。与 Electrum Personal Server 类似，这让偏爱轻量钱包界面（如 Electrum）的用户可以从自己的全验证节点获取区块和交易数据，从而获得额外安全性。这种方案不会带来明显的额外开销：BWT 的附加索引只存在内存中，而且在[许多情况下][bwt pruning]也能配合修剪节点工作，因此把 `bitcoind` 与 `bwt` 搭配部署只需几 GB 磁盘空间。

  Ivgi 还提供了一个[插件][bwt plugin]，可简化 BWT 与 Electrum 客户端的配置；此外，BWT 也许还能用于其他支持 Electrum 服务器协议的钱包，例如 [Edge][]、[Blue Wallet][]、[Eclair mobile][] 和 [Phoenix][]。

  BWT 的 HTTP 协议还支持 Electrum 服务器协议之外的更多功能，例如在与 HD 钱包以及 [部分签名比特币交易（PSBT）][topic psbt] 这类钱包协作工具交互时有用的密钥来源信息。他在邮件中还提到，未来版本的 BWT 可能会支持[输出脚本描述符][topic descriptors]，让钱包能够生成和使用自身脚本模板的标准化描述。

- **<!--transaction-size-calculators-->****交易大小计算器：** Jameson Lopp 在 Bitcoin-Dev 邮件列表上[发帖][lopp size]，给出了他自己开发的[交易大小计算器][lopp calc]以及 Optech 开发的一个类似[计算器][optech calc]的链接。两个工具都不自称完备或没有 bug，但对于想快速比较不同类型交易大小的开发者来说，两者应当都有用处。

## 最近转录的演讲与对话

*[Bitcoin Transcripts][] 是比特币技术演讲与讨论转录稿的汇集地。在这个月度栏目中，我们挑选上个月的部分转录内容重点介绍。*

- **<!--ln-backups-->****闪电网络备份：** Christian Decker 在 Potzblitz 上介绍了闪电网络备份的最新状况。他先讨论了 Eclair、LND 等其他实现的做法，然后解释了 C-Lightning 为什么采用同步的数据库日志插件。接着，他讲到了闪电网络备份为何比链上备份更复杂、把 [SIGHASH_NOINPUT][topic sighash_anyprevout] 或 `SIGHASH_ANYPREVOUT` 加入比特币以启用基于 [eltoo][topic eltoo] 的支付通道的前景，以及闪电网络协议目前的模块化程度。（[转录][decker xs]，[视频][decker vid]）

- **<!--payjoin-p2ep-->****Payjoin/P2EP：** Adam Gibson 在伦敦 BitDevs 主持了一场关于 [payjoin][topic payjoin] 的讨论。payjoin 是一种让付款方和收款方都为交易提供输入的协议，它打破了[常见的输入所有权假设][common input ownership assumption]以及子集和（subset sum）分析，从而同时改善付款方和收款方的隐私。Gibson 梳理了这一构想的历史，介绍了 JoinMarket 和 Samourai 中已有的 payjoin 实现，随后剖析了 BTCPay Server 最近实现的细节。最后他概述了钱包可能被指纹识别的几种途径，例如所需的签名数量、使用的时间锁，以及是否设置了自愿启用的手续费替换（[RBF][topic rbf]）标志。（[转录][gibson xs]，[视频][gibson vid]）

- **<!--lsat-your-ticket-aboard-the-lightning-native-web-->****LSAT——登上闪电原生网络的门票：** Oliver Gugger 在 Reckless VR 以虚拟现实形式介绍了闪电服务认证令牌（LSAT）。LSAT 是一份结合 HTTP、macaroon 和闪电网络的协议规范提案，旨在承担 HTTP 402 Payment Required 响应码的职能。Gugger 讲解了认证流程，以及 macaroon 在化名用户认证中的作用。问答环节聚焦于 LSAT 的使用场景及其好处，例如增强用户隐私、改善注册体验。（[转录](https://diyhpl.us/wiki/transcripts/vr-bitcoin/2020-05-16-oliver-gugger-lsat/)，[视频](https://www.youtube.com/watch?v=IW08RJUpzw0)）

- **<!--sydney-meetup-discussion-->****悉尼聚会讨论：** 若干比特币和闪电网络开发者参加了这次悉尼聚会，讨论的话题包括：让数百万 LN 客户端接入的可扩展性问题、把 Rust 代码集成进 Bitcoin Core、C-Lightning 中的双向资助，以及未来的软分叉激活机制。会上分别回顾了 Linux 内核开发史和 segwit 激活史，以寻找线索：Rust 语言是否应当、以及何时引入 Bitcoin Core，未来激活 [taproot][topic taproot] 等提议软分叉又该采用何种具体机制。转录稿经过匿名化处理，以便鼓励坦诚讨论。（[转录][sydney xs]）

- **<!--the-revault-multiparty-vault-architecture-->****Revault 多方保险库架构：** Kevin Loaec 和 Antoine Poinsot 在伦敦 Bitcoin Devs 上展示了他们的保险库设计 *Revault*。他们介绍了一些具体细节，例如该设计依赖协同签名服务器，以及它与其他需要删除密钥、预先确定支出金额或两者兼有的保险库设计相比如何。在他们演讲的前一周，已有一场范围更广的讨论，主题涉及保险库、[契约][topic covenants] 和 `OP_CHECKTEMPLATEVERIFY`（`OP_CTV`），其中包括 `OP_CTV` 各种用例的优点，以及将其软分叉进比特币的一条可能路径。另一些讨论则聚焦于 Bitcoin Core 当前的内存池策略现状，以及这种策略如何造成[交易钉住][topic transaction pinning]之类的难题，进而影响保险库设计和闪电网络协议的安全性。（[聚会转录][london xs]，[演讲转录][revault xs]，[聚会视频][london vid]，[演讲视频][revault vid]）

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- **Bitcoin Core 0.20.0** 已打上标签，很可能会在本期 Newsletter 发布前后正式发布。我们会在下一期 Newsletter 中更详细地介绍这个新的大版本。

- [LND 0.10.1-beta.rc3][] 是 LND 下一个维护版本的最新候选发布。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中值得注意的变更。*

*注意：以下提到的 Bitcoin Core 提交针对其 master 开发分支，因此这些变更很可能要到 0.21 版才会发布，也就是在即将发布的 0.20 版发布约六个月之后。*

- [Bitcoin Core #19010][] 和 [Bitcoin Core #19044][] 分别是[一组共五个 PR][Bitcoin Core #18876] 中的第三步和第四步，目标是支持在 P2P 网络上提供[紧凑区块过滤器][topic compact block filters]，具体规定见 [BIP157][]。第一步已在 [Newsletter #98][news98 bitcoin core 18877] 中介绍。

  经过这些变更，用 `-blockfilterindex` 配置参数启用了紧凑区块过滤器索引的节点，现在可以响应 `getcfcheckpt`、`getcfheaders` 和 `getcfilters` 请求，返回相应的 `cfcheckpt`、`cfheaders` 和 `cfilters` 响应。节点目前尚未在 version 消息中用 `NODE_COMPACT_FILTERS` 宣告支持 BIP157。最后一步 [Bitcoin Core #19070][] 在撰写本文时仍在审查中，它将让节点能够宣告自己可以提供紧凑区块过滤器服务。该功能默认关闭，可通过 `-peerblockfilters` 配置参数启用。

- [Bitcoin Core #16939][] 改变了 Bitcoin Core 在查询 DNS 种子以获取潜在对等节点 IP 地址之前的等待时长。以前，如果节点数据库里已有对等节点的 IP 地址，它会先尝试打开若干连接，并等 11 秒看能否连上，然后再去请求新地址。现在，如果数据库中的 IP 地址超过 1,000 个（对于在线超过几小时的节点来说很常见），它会等最长 5 分钟再去查询。这提高了重启后的节点完全依靠 P2P 地址发现、而不依赖中心化 DNS 种子的可能性。

- [LND #4228][] 新增了一条钱包命令 `labeltx`，用于给过去的链上交易打标签。这是 [LND #4213][] 工作的延续，后者允许在发送支付时设置标签。标签属于私人的钱包元数据，帮助用户记住自己付给了谁、买了什么；标签不属于链上交易，也不会分享给其他用户。

## 值此 Optech Newsletter 第 100 期之际

> “我有些惊讶，居然没有人开始每周撰写关于研究和开发活动的总结。总结最近的工作是一项有价值的任务，其他人只需通过阅读邮件列表并将多个想法汇总即可从事这项工作。”
>
> {:.right}
> ---Bryan Bishop, [2015 年 8 月 19 日][bishop summaries]

在 Bishop 发表上述评论近五年之后，我们仍然坚信，每周撰写研发活动摘要这项工作是很有价值的，无论是对开源的比特币开发社区，还是对众多依赖该社区成果的企业。但在我们制作这份 Newsletter 的两年里，我们也发现，做摘要并不像我们最初以为的那样快、那样简单。因此，我们想借此机会感谢那些每周慷慨拿出大量宝贵时间、让这份 Newsletter 得以问世的人：[Adam Jonas][]、[Carl Dong][]、[David A. Harding][]、[John Newbery][]、[Jon Atack][]、[Mike Schmidt][] 和 [Steve Lee][]。

我们还要感谢那些经验丰富的比特币与 LN 贡献者，他们在过去两年里就某些复杂话题给予我们特别帮助，或为 Newsletter 提供实地报告和其他额外内容。

要每周发布高质量的 Newsletter，并努力完成 Optech [使命][about page]的其他方面，离不开会员公司的资金支持。感谢他们始终致力于改善比特币用户、开发者与企业之间的沟通。

{:.center style="font-size: 1.5em"}
![感谢我们的会员！](/img/posts/2020-06-members.png)

我们也永远感谢创始赞助人 [Wences Casares][]、[John Pfeffer][] 和 [Alex Morcos][] <!-- same order as on About page -->，以及 [Chaincode Labs][]、[Square Crypto][] 等组织——它们允许并鼓励员工利用工作时间参与 Optech。

{% include references.md %}
{% include linkers/issues.md issues="19010,16939,4228,19044,18876,19070,4213" %}
[bitcoin core 0.20.0]: https://bitcoincore.org/bin/bitcoin-core-0.20.0
[lnd 0.10.1-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.10.1-beta.rc3
[bishop summaries]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2015-August/010488.html
[news98 sas]: /zh/newsletters/2020/05/20/#two-transaction-cross-chain-atomic-swap-or-same-chain-coinswap
[belcher coinswap]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-May/017898.html
[zmn payswap]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017595.html
[joinmarket]: https://github.com/JoinMarket-Org/joinmarket-clientserver
[eps]: https://github.com/chris-belcher/electrum-personal-server
[lopp size]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-May/017905.html
[lopp calc]: https://jlopp.github.io/bitcoin-transaction-size-calculator/
[optech calc]: /en/tools/calc-size/
[about page]: /en/about/
[ivgi bwt]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-May/017906.html
[bwt api]: https://github.com/shesek/bwt#http-api
[bwt plugin]: https://github.com/shesek/bwt#electrum-plugin
[edge]: https://edge.app/
[blue wallet]: https://bluewallet.io/
[eclair mobile]: https://github.com/ACINQ/eclair-mobile
[phoenix]: https://phoenix.acinq.co/
[Adam Jonas]: https://github.com/adamjonas
[Carl Dong]: https://github.com/dongcarl
[David A. Harding]: https://github.com/harding
[John Newbery]: https://github.com/jnewbery
[Jon Atack]: https://github.com/jonatack
[Mike Schmidt]: https://github.com/bitschmidty
[Steve Lee]: https://github.com/moneyball
[Wences Casares]: https://en.wikipedia.org/wiki/Wences_Casares
[John Pfeffer]: https://twitter.com/jlppfeffer
[Alex Morcos]: https://twitter.com/morcosa
[Chaincode Labs]: https://chaincode.com/
[bwt pruning]: https://github.com/shesek/bwt#pruning
[Square Crypto]: https://twitter.com/sqcrypto
[decker xs]: https://diyhpl.us/wiki/transcripts/lightning-hack-day/2020-05-03-christian-decker-lightning-backups/
[decker vid]: https://www.youtube.com/watch?v=kGQF3wtzr04
[gibson xs]: https://diyhpl.us/wiki/transcripts/london-bitcoin-devs/2020-05-05-socratic-seminar-payjoins/
[gibson vid]: https://www.youtube.com/watch?v=hX86rKyNB8I
[gugger xs]: https://diyhpl.us/wiki/transcripts/vr-bitcoin/2020-05-16-oliver-gugger-lsat/
[gugger vid]: https://www.youtube.com/watch?v=IW08RJUpzw0
[sydney xs]: https://diyhpl.us/wiki/transcripts/sydney-bitcoin-meetup/2020-05-19-socratic-seminar/
[london xs]: https://diyhpl.us/wiki/transcripts/london-bitcoin-devs/2020-05-19-socratic-seminar-vaults/
[revault xs]: https://diyhpl.us/wiki/transcripts/london-bitcoin-devs/2020-05-26-kevin-loaec-antoine-poinsot-revault/
[london vid]: https://www.youtube.com/watch?v=34jMGiCAmQM
[revault vid]: https://www.youtube.com/watch?v=7CE4aiFxh10
[common input ownership assumption]: https://en.bitcoin.it/wiki/Common-input-ownership_heuristic
[news98 bitcoin core 18877]: /zh/newsletters/2020/05/20/#bitcoin-core-18877
