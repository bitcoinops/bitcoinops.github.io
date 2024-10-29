---
title: 'Bitcoin Optech Newsletter #100'
permalink: /zh/newsletters/2020/06/03/
name: 2020-06-03-newsletter-zh
slug: 2020-06-03-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了一个关于 coinswap 实现的设计提案，介绍了一种新的中间件，允许轻量钱包直接从用户的节点请求信息，并重点介绍了两个交易大小计算器。此外，还包括我们常规部分的几篇最近转录的演讲描述、新的发布和候选发布版本，以及对流行比特币基础设施软件的显著更改的总结。特别的最后一节，庆祝了第 100 期 Newsletter 的发布。

## 行动项

*本周无。*

## 新闻

- **<!--design-for-a-coinswap-implementation-->****coinswap 实现设计：** Chris Belcher [发布][belcher coinswap]了一个功能齐全的 coinswap 实现设计。Coinswap 是一种协议，它允许两个用户创建一对看起来像普通支付但实际上交换他们各自币的交易。这不仅提高了 coinswap 用户的隐私，也提升了所有比特币用户的隐私，因为任何看起来像支付的行为都可能实际上是一次 coinswap。

  Belcher 的帖子总结了 coinswap 概念的历史，建议将 coinswap 所需的多重签名条件伪装成更常见的交易类型，提议使用市场提供流动性（类似于 JoinMarket 所做的），描述了通过分割和路由技术减少因金额关联或监控参与者带来的隐私损失，提到了其他替代的 coinswap 协议，如简洁的原子交换（详见 [Newsletter #98][news98 sas]），建议将 coinswap 与 [payjoin][topic payjoin] 结合，并讨论了一些系统的后台需求。此外，他还将 coinswap 与其他隐私技术进行了比较，如使用闪电网络、[coinjoin][topic coinjoin]、payjoin 和 [payswap][zmn payswap]。

  Belcher 在创建和维护比特币的隐私增强开源软件方面有丰富的经验，如 [JoinMarket][] 和 [Electrum Personal Server][eps]，这给了他邮件结论中的话特别的分量：“我打算创建这个 CoinSwap 软件。它将几乎完全去中心化，并免费供所有人使用。”

- **<!--new-node-to-wallet-middleware-->****新的节点到钱包的中间件：** Nadav Ivgi [宣布][ivgi bwt]了 Bitcoin Wallet Tracker (BWT) 的 alpha 版本，这是一个通过标准 RPC 接口与 Bitcoin Core 的钱包交互的程序，使用这些数据构建轻量钱包所需的附加索引，然后通过 Electrum 服务器协议和 BWT 自有的[广泛的基于 HTTP 的 API][bwt api] 提供这些数据。类似于 Electrum Personal Server，这允许更喜欢轻量钱包界面（如 Electrum）的用户从自己的完整验证节点检索区块和交易数据，以增强安全性。BWT 的方法没有显著的开销：其附加索引仅存储在内存中，并且在[许多情况下][bwt pruning]可以与修剪节点一起工作，使得 `bitcoind` 和 `bwt` 的组合设置仅使用几 GB 的磁盘空间。

  Ivgi 还提供了一个[插件][bwt plugin]，简化了 BWT 与 Electrum 客户端的设置，并且可能还可以将 BWT 用于其他支持 Electrum 服务器协议的钱包，如 [Edge][]、[Blue Wallet][]、[Eclair mobile][] 和 [Phoenix][]。

  BWT 的 HTTP 协议支持 Electrum 服务器协议之外的其他功能，如对与 HD 钱包交互和钱包协作工具（如 [PSBT][topic psbt]）有用的密钥来源信息。他的邮件还提到，未来版本的 BWT 可能会支持[输出脚本描述符][topic descriptors]，允许钱包生成和使用其脚本模板的标准化描述。

- **<!--transaction-size-calculators-->****交易大小计算器：** Jameson Lopp [在邮件列表中发布][lopp size]了他开发的一个[交易大小计算器][lopp calc]的链接以及 Optech 开发的一个类似的[计算器][optech calc]。两个工具都不声称是完整或无错误的，但对于希望快速比较不同类型交易大小的开发者来说，这两个工具都应当是有用的。

## 最近转录的演讲和对话

*[Bitcoin Transcripts][] 是一个存放技术性比特币演讲和讨论的转录内容的站点。在这一月度特刊中，我们将重点介绍上个月的一些精选转录内容。*

- **<!--ln-backups-->****闪电网络备份：** Christian Decker 在 Potzblitz 上介绍了闪电网络备份的最新状态。他讨论了其他实现（如 Eclair 和 LND）的做法，然后解释了为什么 C-Lightning 使用同步数据库日志插件。接着，他描述了为什么闪电网络备份比链上备份更复杂，添加 [SIGHASH_NOINPUT][topic sighash_anyprevout] 或 `SIGHASH_ANYPREVOUT` 到比特币以启用[eltoo 支付通道][topic eltoo]的前景，以及当前闪电网络协议的模块化特性。([转录][decker xs]，[视频][decker vid])

- **<!--payjoin-p2ep-->****Payjoin/P2EP：** Adam Gibson 在伦敦 BitDevs 主持了一场关于 [payjoin][topic payjoin] 的讨论，Payjoin 是一种协议，允许支付的发送方和接收方共同提供交易的输入。这打破了[常见的输入所有权假设][common input ownership assumption]和子集和分析，提高了发送方和接收方的隐私。Gibson 回顾了这一概念的历史，并描述了 JoinMarket 和 Samourai 中的现有实现，随后审视了 BTCPay Server 的最新实现细节。他最后概述了钱包可以被指纹识别的几种不同方式，如所需的签名数量、使用的时间锁定以及是否设置了选择性 Replace-By-Fee（[RBF][topic rbf]）标志。([转录][gibson xs]，[视频][gibson vid])

- **<!--lsat-your-ticket-aboard-the-lightning-native-web-->****LSAT——通往闪电原生网络的门票：** Oliver Gugger 在 Reckless VR 的虚拟现实中展示了闪电服务认证令牌（LSAT）。LSAT 是一个结合了 HTTP、macaroons 和闪电网络的协议规范提案，旨在实现 HTTP 402 Payment Required 响应码的用途。Gugger 描述了认证流程以及 macaroons 在伪匿名用户认证中的角色。问答环节重点讨论了使用 LSAT 的用例以及增强用户隐私和改善注册体验的优势。([转录](https://diyhpl.us/wiki/transcripts/vr-bitcoin/2020-05-16-oliver-gugger-lsat/)，[视频](https://www.youtube.com/watch?v=IW08RJUpzw0))

- **<!--sydney-meetup-discussion-->****悉尼聚会讨论：** 许多比特币和闪电网络开发者参加了这次悉尼聚会，讨论了包括：接纳数百万闪电网络客户端的扩展性问题、Rust 代码集成到 Bitcoin Core 中、C-Lightning 中的双重资助以及未来软分叉激活机制等主题。为获取对将 Rust 语言引入 Bitcoin Core 的确切机制和未来激活提议软分叉（如 [taproot][topic taproot]）的启示，还探讨了 Linux 内核开发的历史和 segwit 激活的历史。转录内容已匿名化，以鼓励开放讨论。([转录][sydney xs])

- **<!--the-revault-multiparty-vault-architecture-->****Revault 多方金库架构：** Kevin Loaec 和 Antoine Poinsot 在伦敦 Bitcoin Devs 上展示了他们的金库设计 *Revault*。他们概述了具体细节，如其对共同签名服务器的依赖以及与其他需要密钥删除、预期支出金额或两者兼有的金库设计的比较。他们的演示之前一周进行了更广泛的讨论，讨论了金库、[covenants][topic covenants] 和 `OP_CHECKTEMPLATEVERIFY` (`OP_CTV`)。内容包括 `OP_CTV` 在不同用例中的优劣以及其可能的软分叉路径。额外讨论的内容集中于 Bitcoin Core 当前的内存池策略状态及其如何带来诸如[交易固定][topic transaction pinning]等挑战，这些挑战会影响金库设计和闪电网络协议的安全性。([聚会转录][london xs]，[演示转录][revault xs]，[聚会视频][london vid]，[演示视频][revault vid])

## 发布与候选发布

*流行比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- **Bitcoin Core 0.20.0** 已经标记，并可能会在本 Newsletter 发布的同时发布。我们将在下期 Newsletter 中详细描述这一新的主要版本。

- [LND 0.10.1-beta.rc3][] 是 LND 下一个维护版本的最新候选发布版本。

## 值得注意的代码和文档更改

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]的显著更改。*

*注意：以下提到的 Bitcoin Core 提交适用于其主开发分支，因此这些更改可能不会在即将发布的 0.20 版本中发布，而可能会在大约六个月后发布的 0.21 版本中。*

- [Bitcoin Core #19010][] 和 [Bitcoin Core #19044][] 分别是[一系列五个拉取请求][Bitcoin Core #18876]中的第三和第四步，旨在支持在 P2P 网络上提供[致密区块过滤器][topic compact block filters]，如 [BIP157][] 中所定义的。第一步已在 [Newsletter #98][news98 bitcoin core 18877] 中介绍。

  通过这些更改，启用了 `-blockfilterindex` 配置参数的节点现在可以响应 `getcfcheckpt`、`getcfheaders` 和 `getcfilters` 请求，并返回相应的 `cfcheckpt`、`cfheaders` 和 `cfilters` 响应。节点尚未在其版本消息中使用 `NODE_COMPACT_FILTERS` 广告支持 BIP157。最后一步，[Bitcoin Core #19070][]，在撰写本文时正在审查中，将允许节点发出致密区块过滤器的服务能力信号。该功能默认关闭，可以通过 `-peerblockfilters` 配置参数启用。

- [Bitcoin Core #16939][] 更改了 Bitcoin Core 直到查询 DNS 种子以获取潜在对等方 IP 地址的等待时间。以前，如果节点的数据库中有对等方的 IP 地址，它将尝试打开多个连接，并等待 11 秒来成功连接，然后再请求新地址。现在，如果数据库中有超过 1,000 个 IP 地址（对于在线超过几小时的节点，这很常见），它将在查询之前等待最长 5 分钟。这提高了重启节点完全使用 P2P 地址发现而不依赖于集中式 DNS 种子的机会。

- [LND #4228][] 添加了一个新的钱包命令 `labeltx`，用于为过去的链上交易添加标签。这是对 [LND #4213][] 工作的延续，后者允许在发送付款时设置标签。标签是个人钱包元数据，帮助用户记住他们支付给谁和购买了什么；标签不是链上交易的一部分，也不会与其他用户共享。

## 值此 Optech Newsletter 第 100 期之际

> “我有些惊讶，居然没有人开始每周撰写关于研究和开发活动的总结。总结最近的工作是一项有价值的任务，其他人只需通过阅读邮件列表并将多个想法汇总即可从事这项工作。”
>
> {:.right}
> ---Bryan Bishop, [2015 年 8 月 19 日][bishop summaries]

在 Bishop 发表上述评论后近五年，我们仍然坚信，每周撰写关于研究和开发活动的总结是一项对开源比特币开发社区和依赖社区工作的众多企业都很有价值的任务。但在我们过去两年中制作这份 Newsletter 的过程中，我们也发现，总结并不像我们最初预期的那样快和简单。因此，我们希望借此机会感谢那些通过每周慷慨贡献他们宝贵时间，使这份 Newsletter 成为可能的人们：[Adam Jonas][]、[Carl Dong][]、[David A. Harding][]、[John Newbery][]、[Jon Atack][]、[Mike Schmidt][] 和 [Steve Lee][]。

此外，我们感谢那些经验丰富的比特币和闪电网络贡献者，他们在某些复杂主题上特别帮助了我们，或者在过去两年中为 Newsletter 提供了实地报告和其他额外内容。

发布高质量的每周 Newsletter 并努力实现 Optech 的[使命][about page]，离不开我们会员公司的财务支持。我们感谢他们在改进比特币用户、开发者和企业之间的沟通方面持续的承诺。

{:.center style="font-size: 1.5em"}
![感谢我们的会员！](/img/posts/2020-06-members.png)

我们也始终感谢我们的创始赞助人 [Wences Casares][]、[John Pfeffer][] 和 [Alex Morcos][] <!-- same order as on About page --> 以及像 [Chaincode Labs][] 和 [Square Crypto][] 这样的组织，他们允许并鼓励其员工在工作时间内为 Optech 做出贡献。

{% include references.md %}
{% include linkers/issues.md issues="19010,16939,4228,19044,18876,19070,4213" %}
[bitcoin core 0.20.0]: https://bitcoincore.org/bin/bitcoin-core-0.20.0
[lnd 0.10.1-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.10.1-beta.rc3
[bishop summaries]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2015-August/010488.html
[news98 sas]: /zh/newsletters/2020/05/20/#two-transaction-cross-chain-atomic-swap-or-same-chain-coinswap
[belcher coinswap]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-May/017898.html
[zmn payswap]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017595.html
[joinmarket]: https://github.com/JoinMarket-Org/joinmarket-clientserver
[eps]: https://github.com/chris-belcher/electrum-personal-server
[lopp size]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-May/017905.html
[lopp calc]: https://jlopp.github.io/bitcoin-transaction-size-calculator/
[optech calc]: /en/tools/calc-size/
[about page]: /en/about/
[ivgi bwt]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-May/017906.html
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
