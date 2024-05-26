---
title: 'Bitcoin Optech Newsletter #8'
permalink: /zh/newsletters/2018/08/14/
name: 2018-08-14-newsletter-zh
slug: 2018-08-14-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 包括常规的仪表盘和行动项，关于允许安全和匿名负责任地披露漏洞的重要性的新闻、一种可能的新支付协议可以在不需要任何共识规则变更的情况下改善比特币的隐私性、从每笔交易签名的大小中减少一个字节、对 P2P 网络协议的新限制以及降低最低交易转发费用——还有来自 Bitcoin Core、LND 和 C-Lightning 项目的一些值得注意的提交。

## 行动项

- **<!--check-your-responsible-disclosure-process-->****检查你的负责任披露流程：**尤其重要的是，研究人员能够安全（例如，使用 PGP）和匿名（例如，使用 Tor）报告漏洞。请参阅下面的新闻部分，了解有关之前负责任披露 Bitcoin Cash 加密货币中的共识失败漏洞的详细信息，该漏洞本可被用于从交易所窃取资金——即使是那些要求多次确认存款交易的交易所——以及建议的最佳披露实践。

- **<!--check-software-using-the-p2p-protocol-getblocks-or-getheaders-messages-->****检查使用 P2P 协议 `getblocks` 或 `getheaders` 消息的软件：**如果你使用自定义软件请求使用这些消息之一的区块，请确保它们的请求不超过 101 个定位器。所有流行的开源软件已经过测试，但如果你有使用 P2P 协议的内部软件，可能需要测试它。详情请参阅新闻部分。

## 仪表盘项

{% assign img1_label = "Transactions per block, 25-block moving average, July 14, 2018 - August 13, 2018" %}

- **<!--fees-remain-very-low-->**交易[费用仍旧非常低][fee metrics]：任何能等待 10 个或更多区块确认的人都可以合理支付默认的最低费率。这是一个[合并 UTXO][consolidate info]的好时机。

- **<!--btc-hash-rate-->**估计的 [BTC 哈希率][btc hash rate]在 8 月 10 日短暂触及 60 EH/s，7 天平均值为 48 EH/s。

- **<!--the-number-of-transactions-in-each-block-->**每个区块中的交易数量。这个指标在某种程度上是周期性的，每天大约在 13:00 到 17:00 UTC 期间有峰值。下图显示了每个区块交易数量的 25 区块移动平均值。它来自我们鼓励人们尝试并向我们提供反馈的 [Optech beta dashboard][periodic txn data]。

	![{{img1_label}}](/img/posts/transactions-spikes.png)
	*{{img1_label}},
	source: [Optech dashboard][periodic txn data]*

## 新闻

- **<!--how-to-help-security-researchers-->****如何帮助安全研究人员：** Bitcoin Core 开发者及 Digital Currency Initiative (DCI) 成员 Cory Fields [披露][fields post]，他曾作为匿名来源，揭示了一个可能破坏 Bitcoin Cash 共识的重大漏洞。在尝试报告漏洞的过程中遇到了挫折之后，他请求与加密货币相关的项目更容易地让安全研究人员提交安全的匿名漏洞报告，并且 DCI 成员 Neha Narula 也提出了[一些建议][narula recs]，这些建议主要针对加密货币维护者，但也可能对使用加密货币的组织有用。

    Optech 鼓励我们的会员公司（以及任何阅读本通讯的人）考虑匿名研究人员向您的团队报告关键错误的难易程度。测试您流程的一个简单方法可以是指派您团队的一名成员安装 Tor 并尝试仅使用他们能够在您的网站上轻松找到的关于您的操作的信息来安全提交报告。如果您提供 Bug 赏金，您可能还希望明确表示，对于最初报告 PGP 签名披露的任何人，您都会提供相同级别的奖励，前提是您稍后从他们那里收集可能需要的任何合法遵从信息。

- **<!--pay-to-end-point-p2ep-idea-proposed-->****提出 Pay-to-End-Point (P2EP) 的想法：** zkSNACKs 的 [Adam Ficsor][nopara73 p2ep] (nopara73) 和 Blockstream 的 [Matthew Haywood][blockstream p2ep] 的博客帖子描述了一种新的想法，用于在不对共识协议进行任何更改的情况下，提高比特币用户的隐私。基本想法是，支付者在尝试进行支付时联系接收者控制的服务器（类似于 [BIP70][] 支付协议），提供一个正常的已签名交易作为支付意愿的证明，然后与接收者一起获得执行多个 CoinJoin 风格交易的必要信息。如果使用了 CoinJoin 风格的交易之一，这可以混淆区块链分析公司，使其误认为接收者添加到交易中的输入是支付者的输入，或者（如果 P2EP 得到广泛使用）只是使区块链分析通常变得不那么可靠。

    如果讨论持续积极并且达成了具体提议，几个注重隐私的钱包正考虑添加对 P2EP 支付的支持，并且 [BTCPay Server](https://github.com/btcpayserver/btcpayserver) 正在考虑添加对 P2EP 接收的支持。

- **<!--bitcoin-core-wallet-to-begin-only-creating-low-r-signatures-->****Bitcoin Core 钱包开始只创建低 R 值签名：**用于编码比特币签名的 DER 格式要求在签名中额外添加一个字节，仅用于指示签名的 R 值是否位于比特币所用椭圆曲线的上半部。R 值是随机派生的，因此所有签名中有一半会有这个额外的字节。

    本周合并的 Bitcoin Core PR [#13666][Bitcoin Core #13666] 为每笔交易生成多个签名（如果必要），使用递增的随机数直到找到一个不需要这个额外字节的低 R 值签名。通过这样做，Bitcoin Core 交易将每两个签名节省一个字节（平均）。如果所有钱包都这样做，它可以节省每个典型满区块几千 byte（或最多几千 vbyte），每天增加区块链容量几千笔交易。代价是 Bitcoin Core 生成平均签名的时间将增加一倍，并且生成签名的熵（随机性）减少 1 位，但这两者都不重要。如果没有其他钱包采用此更改，它还可能使 Bitcoin Core 创建的交易更容易被识别。

    注意，这种变化不以任何方式影响其他软件（除了其他钱包可以使用额外的区块链容量）。这纯粹是内置于 Bitcoin Core 钱包的功能，而不是协议将强制执行的内容。

- **<!--lowering-minimum-relay-fees-in-two-steps-->****两步降低最低转发费：**如 [Newsletter #3][news3 lower relay] 中提到，Bitcoin Core 开发人员正在[考虑][Bitcoin Core #13922] 降低交易的最低转发费。因为这一变化同时影响钱包、中继节点和矿工——但因为他们不都按相同的时间表更新——评估和测试变化比只改变几个变量要困难得多。

    目前讨论的计划是先降低中继节点和矿工的默认费用，等待看看它是否获得足够的采用，以便当前低于默认费用的交易能被挖出，然后在以后的版本中降低钱包使用的最低费用。我们将在未来的新闻简报中发布有关您的组织如何帮助使用和鼓励采用更低的最低中继费用的更新。

- **<!--p2p-protocol-change-to-restrict-locators-->****P2P 协议更改以限制定位器：**[getblocks][p2p getblocks] 和 [getheaders][p2p getheaders] 消息允许节点通过发送已知区块的列表来请求关于尚未看到的区块的信息。接收节点使用列表来找到两个节点共有的最后一个区块，并发送后续区块的信息。

    根据 Gregory Maxwell 在 bitcoin-dev 邮件列表上发布的一封[电子邮件][bd locators]，Bitcoin Talk 用户 Coinr8d 担心请求节点可能向接收节点发送多达 32 MiB 的区块哈希，导致接收节点花费大量 I/O 寻找它没有的区块。然而，Maxwell 的测试并未发现这是一个重大问题。尽管如此，Maxwell 提议限制这些消息中允许的定位器数量。Libbitcoin 开发人员 Eric Voskuil 表示他的软件已经在执行限制，并且他知道一个程序（BitcoinJ）略微超过了 Maxwell 提议的限制。

    随后合并的 PR [Bitcoin Core #13907][] 由 Maxwell 设置限制，以等于 BitcoinJ 请求的最大数量。如果您知道使用 `getblocks` 或 `getheaders` P2P 消息请求超过 101 个元素的软件，请发帖到 bitcoin-dev 邮件列表或联系 Optech 的某个人。

- **<!--schnorr-bip-discussion-->Schnorr BIP 讨论：**上周在 bitcoin-dev 邮件列表上，关于生成 Schnorr 签名的算法的[讨论][schnorr discuss]在没有需要对提议的 BIP 进行任何更改的情况下得到解决。这可能增加了人们对所提议的 BIP 参数选择明智的信心。

## 值得注意的提交

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo] 和 [C-lightning][core lightning repo] 中的显著提交。不包括上文描述的 Bitcoin Core #13907 或 #13666。注意：本周所有三个项目的大部分更改似乎是对其自动化测试代码的改进；我们没有在这份简报中描述这些改进，但我们确信用户和开发者非常欣赏这项工作。*

- [Bitcoin Core #13925][]：增加 Bitcoin Core 内部数据库可以使用的文件描述符的最大数量，这可以允许更多的文件描述符被用于网络连接。如果你修改了 Bitcoin Core 以接受超过 117 个进来的连接，在升级过了这个合并之后，你可能会看到连接数量的进一步增加。（注意：我们不建议增加默认值，除非你有特殊需求。）

- [LND #1644][]：用户输入的以 satoshis per vbyte（每虚拟字节的聪）为单位的费用现在会自动转换为使用[协议][BOLT2]中定义的 satoshis per kiloweight（每千虚拟字节的聪）。

- [C-Lightning #1811][]：一个支付节点在未在过去30秒内从另一个节点收到消息之前，将不再向该节点发送 HTLC 承诺（支付）。如果需要，它会在发送承诺之前先 ping 接收节点。这有助于支付节点在支付过程中更早地中止支付，如果该支付由于网络中断而注定失败的话。

  同时包括对重新连接断开的节点的代码进行各种中等程度的改进，包括指数退避和重连时间模糊处理。

{% include references.md %}
{% include linkers/issues.md issues="13922,13907,13925,1644,13666,1811" %}

[news3 lower relay]: /zh/newsletters/2018/07/10/
[BOLT2]: https://github.com/lightningnetwork/lightning-rfc/blob/master/02-peer-protocol.md
[fields post]: https://medium.com/mit-media-lab-digital-currency-initiative/http-coryfields-com-cash-48a99b85aad4
[narula recs]: https://medium.com/mit-media-lab-digital-currency-initiative/reducing-the-risk-of-catastrophic-cryptocurrency-bugs-dcdd493c7569
[nopara73 p2ep]: https://medium.com/@nopara73/pay-to-endpoint-56eb05d3cac6
[blockstream p2ep]: https://blockstream.com/2018/08/08/improving-privacy-using-pay-to-endpoint.html
[p2p getblocks]: https://bitcoin.org/en/developer-reference#getblocks
[p2p getheaders]: https://bitcoin.org/en/developer-reference#getheaders
[bd locators]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016285.html
[schnorr discuss]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016278.html
[fee metrics]: https://statoshi.info/dashboard/db/fee-estimates
[consolidate info]: https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#Consolidation
[btc hash rate]: https://fork.lol/pow/hashrate
[periodic txn data]: https://dashboard.bitcoinops.org/d/K7C9p0vmz/btc-number-of-txns-total-fee-per-block-volume?panelId=4&fullscreen&orgId=1
