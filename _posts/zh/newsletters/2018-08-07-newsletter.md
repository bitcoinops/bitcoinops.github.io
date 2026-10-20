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

- **<!--optech-has-begun-->**Optech 已开始筹划首次欧洲工作坊，预计于 11 月在巴黎举行。如果有会员公司认为自己能够参加，并且有感兴趣讨论的议题，请[给 Optech 发邮件][optech email]。关于工作坊的更多信息将在几周内公布。

## 仪表盘项
{% assign img1_label = "Transactions signaling opt-in RBF, August 2017 - August 2018" %}
- **<!--fees-remain-very-low-->**交易[手续费仍然非常低][fee metrics]：只要能接受等待 10 个或更多区块确认，就完全可以按默认的最低费率支付。现在是[合并 UTXO][consolidate info]的好时机。

- **<!--adoption-of-opt-in-rbf-->**选择性的手续费替换（opt-in RBF）采用率仍然相当低，但过去一年有了实质性增长，占交易总量的比例[从 1.5% 升至 5.7%][rbf data]。此数据来自 Optech 的 beta 仪表盘，我们鼓励大家试用并向我们反馈！

  ![{{img1_label}}](/img/posts/rbf.png)
  *{{img1_label}},
  source: [Optech dashboard][rbf data]*

## 新闻

- **<!--discussion-of-arbitrary-contracts-over-ln-->****关于通过 LN 执行任意合约的讨论：**上周，Lightning Network (LN) 开发邮件列表上的一个[讨论帖][contract thread]描述了在支付通道中执行任意比特币合约的基本原则。它不再要求有一个独立合约求值为 True 才算有效交易，而是把完全相同的合约嵌入 LN 支付中，该合约必须返回 true，通道内的支付交易才有效。任意合约中的其他内容以及 LN 支付本身都可以保持不变，只有少数特定例外，这些例外在知识渊博的匿名研究者 ZmnSCPxj 发起的这个讨论帖中有所讨论。

- **<!--library-announced-for-bls-signatures-->****宣布 BLS 签名库：**知名开发者 Bram Cohen [宣布][bls announce]了一个“初稿（但功能完备）的库，用于在 [MuSig][] 构造的基础上实现 [BLS 签名][BLS signatures]”。这些签名具备 [Newsletter #3 专题新闻][#3 schnorr] 中所述的 schnorr 签名的大部分优点，同时还支持非交互式签名聚合。签名聚合能减少区块链中的签名数据量（幅度可能非常大），从而提升可扩展性；也可以通过实现非交互式 coinjoin 技术来增强隐私，例如 [Mimblewimble 论文][Mimblewimble
  paper]中描述的那些技术。

  BLS 签名确实有三个缺点，正因如此，大多数比特币协议开发者短期内都把重点放在 schnorr 签名上。第一，目前还没有已知方法能像验证 schnorr 签名那样快速地验证 BLS 签名——而签名验证速度对网络可扩展性同样重要。第二，要证明 BLS 签名是安全的，需要对方案中某个部分的安全性做出额外假设，而证明比特币当前的方案（ECDSA）或拟议的基于 schnorr 的方案安全时并不需要这个假设。最后，BLS 签名问世的时间只有 schnorr 签名的一半左右，使用也更不普遍，据信获得的专家审查也不及 schnorr 签名。

  尽管如此，这个开源库还是为开发者提供了一条便捷途径，可以开始试验 BLS 签名，甚至开始在安全性要求不必像比特币网络那么高的应用中使用它们。

## 值得注意的提交

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo] 和 [C-lightning][core lightning repo] 中值得注意的提交。*

- [Bitcoin Core #13697][]：Pieter Wuille 在 [Newsletter #5][] 中提到的 PR 已经合并，它为即将发布的 0.17 版 RPC `scantxoutset` 增加了对[输出脚本描述符][output script descriptors]的支持。描述符为软件提供了一种完整的方式，用来指明你想查找哪些输出脚本；预计今后它还会逐步扩展到 Bitcoin Core API 的其他部分，例如 [importprivkey][rpc importprivkey]、[importaddress][rpc importaddress]、[importpubkey][rpc importpubkey]、[importmulti][rpc importmulti] 和 [importwallet][rpc importwallet]。

- [Bitcoin Core #13799][]：在第一期 Optech Newsletter 发布之前，曾合并过一个 PR：只要配置文件或启动参数中出现 Bitcoin Core 无法识别的选项，Bitcoin Core 就会故意在启动时中止。这极大简化了拼写错误等常见错误的排查——但也让用户无法在 bitcoin.conf 中放入适用于 `bitcoin-cli` 等客户端的选项。这个新 PR 取消了启动中止，只产生一条警告。客户端兼容机制可能会在未来的版本中实现，届时将恢复启动中止。

- [LND #1579][]：此更新使主要后端接口（如 bitcoind、btcd 和 neutrino SPV）与 btcd 全节点、btcwallet 和 Neutrino 轻钱包中实现的最新（希望也是最终）版本的 [BIP158][] 紧凑区块过滤器兼容。这些过滤器让客户端可以判断某个区块是否可能包含影响其钱包的交易，类似 [BIP37][] 布隆过滤器，但对服务器高效得多（因为无需重新扫描旧区块），同时也为客户端带来更多隐私，因为它们不会直接向服务器透露自己对哪些交易感兴趣。

- [LND #1543][]：此 PR 继续推进创建 LN 瞭望塔（watchtower）的工作，这类瞭望塔可以监控针对通道的盗取企图，并广播用户预先签名的违约补救交易，从而帮助轻客户端和其他不在线的程序。这个 PR 具体增加了由密码学家 Conner Fromknecht 设计的瞭望塔版本 0 编码和加密方法。

- [C-lightning 55d450ff][]：当转发费超过支付金额的一定比例时，C-lightning 会拒绝转发这笔支付。然而当转发金额很小时——例如在 [Satoshis.Place][] 上以每像素 10 nBTC 的价格只买几个像素——这条规则总会被触发，因为最低费用下限始终占很高的比例（例如支付 10 nBTC、最低费用为 10 nBTC，就是 100% 的费用）。此 PR 新增了一条规则：转发费不超过 50 nBTC 的支付可以放行，无论其费用比例是多少；同时新增一个选项，让用户可以自定义该上限。

{% include references.md %}
{% include linkers/issues.md issues="13697,13799,1579,1543" %}

[Newsletter #5]: /zh/newsletters/2018/07/24/
[bls announce]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016273.html
[#3 schnorr]: /zh/newsletters/2018/07/10/#特别新闻schnorr-签名提议-bip
[musig]: https://blockstream.com/2018/01/23/musig-key-aggregation-schnorr-signatures.html
[bls signatures]: https://en.wikipedia.org/wiki/Boneh%E2%80%93Lynn%E2%80%93Shacham
[mimblewimble paper]: https://scalingbitcoin.org/papers/mimblewimble.txt
[c-lightning 55d450ff]: https://github.com/ElementsProject/lightning/commit/55d450ff00ce80b01c5c64c072a47fea42657673
[satoshis.place]: https://satoshis.place/
[contract thread]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-August/001383.html
[fee metrics]: https://statoshi.info/dashboard/db/fee-estimates
[consolidate info]: https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#Consolidation
[rbf data]: https://dashboard.bitcoinops.org/d/ZsCio4Dmz/rbf-signalling?orgId=1&from=now-1y&to=now
[output script descriptors]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
