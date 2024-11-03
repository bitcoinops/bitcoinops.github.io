---
title: 'Bitcoin Optech Newsletter #7'
permalink: /zh/newsletters/2018/08/07/
name: 2018-08-07-newsletter-zh
slug: 2018-08-07-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 包括常规的仪表盘和行动项，一个关于通过闪电网络进行通用比特币合约讨论的链接，一个最近宣布的用于增强可扩展性的 BLS 签名库的简要描述，以及来自 Bitcoin Core、LND 和 C-Lightning 项目的一些值得注意的提交。

## 行动项

- **<!--optech-has-begun-->**Optech 已开始计划其首次欧洲工作坊，预计将于 11 月在巴黎举行。如果任何认为他们将能够参加的会员公司对讨论的主题感兴趣，请[给 Optech 发送电子邮件][optech email]。关于工作坊的更多信息将在几周内发布。

## 仪表盘项
{% assign img1_label = "Transactions signaling opt-in RBF, August 2017 - August 2018" %}
- **<!--fees-remain-very-low-->**交易[费用仍旧非常低][fee metrics]：任何能等待 10 个或更多区块确认的人都可以合理支付默认的最低费率。这是[合并 UTXO][consolidate info]的好时机。

- **<!--adoption-of-opt-in-rbf-->**选择加入 RBF 的采用率仍然相当低，但在过去一年中有实质性增长，从 [1.5% 增长到 5.7% 的交易][rbf data]。此数据来源于 Optech 的 beta 仪表盘，我们鼓励人们尝试并向我们提供反馈！

  ![{{img1_label}}](/img/posts/rbf.png)
  *{{img1_label}},
  source: [Optech dashboard][rbf data]*

## 新闻

- **<!--discussion-of-arbitrary-contracts-over-ln-->****关于通过 LN 进行任意合约的讨论：**上周 Lightning Network (LN) 开发邮件列表上的一个[帖子][contract thread]描述了在支付通道中执行任意比特币合约的基本原则。与独立的合约相比，该合约解析为 True 以成为有效交易，完全相同的合约被包含在 LN 支付中，并且必须返回 true 以使通道内支付交易有效。任意合约中的所有其他内容以及 LN 支付可以保持不变，具体例外在知识渊博的匿名研究员 ZmnSCPxj 启动的这个帖子中进行了讨论。

- **<!--library-announced-for-bls-signatures-->****宣布用于 BLS 签名的库：**著名开发者 Bram Cohen [宣布][bls announce]了一个“初版（但功能完备的）用于基于 [MuSig][] 构造的 [BLS 签名][BLS signatures]库”。这些签名提供了与 [Newsletter #3 特别新闻][#3 schnorr] 中描述的 Schnorr 签名相同的大部分好处，但也允许非交互式签名聚合，这可以通过减少区块链中的签名数据量（可能是非常大的百分比）来提高可扩展性，并通过实施非交互式 CoinJoin 技术（如 [Mimblewimble 论文][Mimblewimble
  paper]中描述的那样）来增强隐私。

  BLS 签名确实有三个缺点，这导致大多数比特币协议开发人员短期内专注于 Schnorr 签名。第一个是没有已知方法可以像验证 Schnorr 签名那样快速验证它们——签名验证速度对于网络可扩展性也很重要。其次，为了证明 BLS 签名的安全性，需要对方案的一部分安全性做出额外的假设，而这对于证明比特币当前的方案（ECDSA）或提议的基于 Schnorr 的方案的安全性并不需要。最后，BLS 签名只存在 Schnorr 签名大约一半的时间，使用得更少，并且据信没有接受到与 Schnorr 签名相同数量的专家审查。

  尽管如此，这个开源库为开发人员提供了一个方便的方式来开始尝试 BLS 签名，甚至可以开始在不需要像比特币网络那样安全的应用程序中使用它们。

## 值得注意的提交

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo] 和 [C-lightning][core lightning repo] 中值得注意的提交。*

- [Bitcoin Core #13697][]：Pieter Wuille 在 [Newsletter #5][] 中提到的这个 PR 已被合并，它为即将发布的 0.17 RPC `scantxoutset` 添加了[输出脚本描述符][output script descriptors]支持。这些描述符为软件提供了一种全面的方式来描述你想要找到的输出脚本，预计将随时间适应 Bitcoin Core API 的其他部分，如 [importprivkey][rpc importprivkey]、[importaddress][rpc importaddress]、[importpubkey][rpc importpubkey]、[importmulti][rpc importmulti] 和 [importwallet][rpc importwallet]。

- [Bitcoin Core #13799][]：在第一份 Optech 新闻简报发布之前，一个 PR 被合并，其内容是如果配置文件或启动参数包含 Bitcoin Core 无法识别的选项，会故意导致 Bitcoin Core 在启动时中止。这极大地简化了调试常见错误（如拼写错误）的流程——但它也阻止用户在他们的 bitcoin.conf 中放入适用于 `bitcoin-cli` 等客户端的选项。这个新 PR 移除了启动中止，只会产生警告。可能在未来的版本中，将实现一个客户端兼容机制，并恢复启动中止。

- [LND #1579][]：此更新将主要后端接口（如 bitcoind、btcd 和 neutrino SPV）与 [BIP158][] 致密区块过滤器的最新（希望是最终）版本兼容，该版本在 btcd 全节点、btcwallet 和 Neutrino 轻钱包中实现。这些过滤器允许客户端确定一个区块是否可能包含影响其钱包的交易，类似于 [BIP37][] 布隆过滤器，但对服务器来说更高效（因为它们不需要重新扫描旧区块），并且为客户端提供了额外的隐私，因为它们不直接向服务器提供任何有关他们感兴趣的交易的信息。

- [LND #1543][]：此 PR 继续朝着创建 LN 看守塔的方向努力，这些看守塔可以通过监控试图盗取频道并广播用户预签名的违约补救交易来协助轻客户端和其他不在线的程序。这个特定的 PR 由密码学家 Conner Fromknecht 添加了看守塔版本 0 的编码和加密方法。

- [C-lightning 55d450ff][]：C-lightning 拒绝转发当转发费用超过支付的一定百分比时的支付。然而，当转发的金额非常小，例如在 [Satoshis.Place][] 上仅购买几个像素，每个像素 10 nBTC 时，由于最低费用总是占很高的百分比（例如，支付 10 nBTC 的最低费用为 10 nBTC 就是 100% 的费用），这条规则总是被触发。此 PR 提供了一条新规则，允许转发费用高达 50 nBTC 的支付无视其费率百分比通过，并添加了一个选项，以便用户可以自定义该值。

{% include references.md %}
{% include linkers/issues.md issues="13697,13799,1579,1543" %}

[Newsletter #5]: /zh/newsletters/2018/07/24/
[bls announce]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016273.html
[#3 schnorr]: /zh/newsletters/2018/07/10/#特别新闻schnorr-签名提议-bip
[musig]: https://blockstream.com/2018/01/23/musig-key-aggregation-schnorr-signatures.html
[bls signatures]: https://en.wikipedia.org/wiki/Boneh%E2%80%93Lynn%E2%80%93Shacham
[mimblewimble paper]: https://scalingbitcoin.org/papers/mimblewimble.txt
[c-lightning 55d450ff]: https://github.com/ElementsProject/lightning/commit/55d450ff00ce80b01c5c64c072a47fea42657673
[satoshis.place]: https://satoshis.place/
[contract thread]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-August/001383.html
[fee metrics]: https://statoshi.info/dashboard/db/fee-estimates
[consolidate info]: https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#Consolidation
[rbf data]: https://dashboard.bitcoinops.org/d/ZsCio4Dmz/rbf-signalling?orgId=1&from=now-1y&to=now
[output script descriptors]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
