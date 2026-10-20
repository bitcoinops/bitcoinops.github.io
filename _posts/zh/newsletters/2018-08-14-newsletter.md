---
title: 'Bitcoin Optech Newsletter #8'
permalink: /zh/newsletters/2018/08/14/
name: 2018-08-14-newsletter-zh
slug: 2018-08-14-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 包括常规的仪表盘和行动项、关于允许安全且匿名地负责任披露漏洞为何重要的新闻、一种无需任何共识规则变更即可改善比特币隐私的潜在新支付协议、把每笔交易签名的大小削减一个字节、对 P2P 网络协议的新限制，以及降低最低交易中继费——此外还有来自 Bitcoin Core、LND 和 C-Lightning 项目的一些值得注意的提交。

## 行动项

- **<!--check-your-responsible-disclosure-process-->****检查你的负责任披露流程：**研究者能够安全（例如使用 PGP）且匿名（例如使用 Tor）地报告漏洞，这一点尤其重要。请参阅下面的新闻部分，那里有链接介绍此前对 Bitcoin Cash 加密货币中一个共识失效漏洞的负责任披露详情——该漏洞本可被用来从交易所盗取资金，即便是那些要求存款交易多次确认的交易所也不例外——还有关于如何让披露更简便的最佳实践建议。

- **<!--check-software-using-the-p2p-protocol-getblocks-or-getheaders-messages-->****检查使用 P2P 协议 `getblocks` 或 `getheaders` 消息的软件：**如果你使用的自定义软件会通过这两种消息之一请求区块，请确保它的请求中定位器不超过 101 个。所有流行的开源软件都已测试过，但如果你有使用 P2P 协议的自研软件，可能需要自行测试。详情请参阅新闻部分。

## 仪表盘项

{% assign img1_label = "Transactions per block, 25-block moving average, July 14, 2018 - August 13, 2018" %}

- **<!--fees-remain-very-low-->**交易[手续费仍然非常低][fee metrics]：只要能接受等待 10 个或更多区块确认，就完全可以按默认的最低费率支付。现在是[合并 UTXO][consolidate info]的好时机。

- **<!--btc-hash-rate-->**预估的 [BTC 哈希率][btc hash rate]在 8 月 10 日一度触及 60 EH/s，7 天平均值为 48 EH/s。

- **<!--the-number-of-transactions-in-each-block-->**每个区块中的交易数量。这个指标带有某种周期性，每天大约在 13:00 到 17:00 UTC 之间出现峰值。下图展示的是每区块交易数量的 25 个区块移动平均值。数据来自 Optech 的 [beta 仪表盘][periodic txn data]，我们鼓励大家试用并提供反馈。

	![{{img1_label}}](/img/posts/transactions-spikes.png)
	*{{img1_label}},
	source: [Optech dashboard][periodic txn data]*

## 新闻

- **<!--how-to-help-security-researchers-->****如何帮助安全研究人员：**Bitcoin Core 开发者、Digital Currency Initiative (DCI) 成员 Cory Fields [披露][fields post]，他就是此前披露 Bitcoin Cash 加密货币中一个可能破坏共识的漏洞的匿名来源。在报告漏洞的过程屡屡受挫之后，他请求加密货币相关项目让安全研究人员更容易向项目提交安全、匿名的漏洞报告；同为 DCI 成员的 Neha Narula 随后提出了[一些建议][narula recs]，这些建议主要面向加密货币维护者，但也可能对使用加密货币的组织有用。

    Optech 鼓励我们的会员公司（以及任何阅读本刊的人）想一想：一名匿名研究者向你的团队报告严重漏洞会有多容易。一个简单的测试方法是，指派团队中的一名成员安装 Tor，然后仅凭能在你网站上轻松找到的信息，尝试安全地提交一份报告。如果你提供漏洞赏金，可能还希望明确说明：对于最初以 PGP 签名方式报告漏洞的人，你会给予同等水平的奖励，前提是你事后能向其收集合规所需的信息。

- **<!--pay-to-end-point-p2ep-idea-proposed-->****提出 Pay-to-End-Point (P2EP) 的构想：**zkSNACKs 的 [Adam Ficsor][nopara73 p2ep]（nopara73）和 Blockstream 的 [Matthew Haywood][blockstream p2ep] 分别在博客文章中描述了一个新构想：无需对共识协议做任何改动，就能改善比特币用户的隐私。基本做法是：付款方在发起支付时联系由收款方控制的服务器（类似 [BIP70][] 支付协议），提交一笔正常的已签名交易，作为愿意付款的证明，然后收到与收款方执行多笔 coinjoin 式交易所必需的信息。如果最终采用其中一笔 coinjoin 式交易，就能误导区块链分析公司，使其把收款方加入交易的某个输入误认为属于付款方；或者（如果 P2EP 被广泛使用）让区块链分析整体上变得不那么可靠。

    如果讨论继续朝积极方向发展并达成具体提案，若干注重隐私的钱包正考虑支持 P2EP 支付，[BTCPay Server](https://github.com/btcpayserver/btcpayserver) 也在考虑支持 P2EP 收款。

- **<!--bitcoin-core-wallet-to-begin-only-creating-low-r-signatures-->****Bitcoin Core 钱包将只生成低 R 值签名：**用于编码比特币签名的 DER 格式，在签名的 R 值位于比特币所用椭圆曲线上半部时，需要额外多用一个字节来标记。R 值是随机产生的，因此有一半的签名会带上这个额外字节。

    本周合并的 Bitcoin Core PR [#13666][Bitcoin Core #13666] 会为每笔交易生成多个签名（如有必要），不断递增 nonce，直到找到不需要这个额外字节的低 R 值签名。这样，Bitcoin Core 的交易平均每两个签名就能省下一个字节。如果所有钱包都这样做，每个典型的满区块最多可节省几千字节（约两千 vbyte），每天最多可为区块链增加几千笔交易的容量。代价是 Bitcoin Core 生成一个普通签名所需的时间会翻倍，而且生成签名的熵（随机性）会减少 1 位——这两点都无关紧要。如果其他钱包不跟进这项改动，它还可能让 Bitcoin Core 创建的交易更容易被识别。

    请注意，这项改动不会以任何方式影响其他软件（除了其他钱包可以享用多出来的区块链容量）。它纯粹是 Bitcoin Core 钱包内置的功能，而不是协议会强制执行的内容。

- **<!--lowering-minimum-relay-fees-in-two-steps-->****分两步降低最低中继费：**如 [Newsletter #3][news3 lower relay] 中提到的，Bitcoin Core 开发者正在[考虑][Bitcoin Core #13922]降低交易的最低中继费。由于这一改动会同时影响钱包、中继节点和矿工，而它们又不会按同一时间表升级，因此评估和测试这项改动的难度，远超仅仅改动几个变量时所预想的程度。

    目前讨论中的方案是：先降低中继节点和矿工使用的默认费率，观察采用率是否足够高、让目前低于默认费率的交易也能被打包，然后在后续版本中降低钱包使用的最低费率。关于你的组织可以如何帮助使用并推动更低的最低中继费被采纳，我们将在本刊后续各期中持续更新。

- **<!--p2p-protocol-change-to-restrict-locators-->****P2P 协议变更——限制定位器：**[getblocks][p2p getblocks] 和 [getheaders][p2p getheaders] 消息允许节点通过发送已知区块的列表来请求关于尚未看到的区块的信息。接收节点使用列表来找到两个节点共有的最后一个区块，并发送后续区块的信息。

    根据 Gregory Maxwell 在 bitcoin-dev 邮件列表上发布的一封[电子邮件][bd locators]，Bitcoin Talk 用户 Coinr8d 担心请求节点可能向接收节点发送多达 32 MiB 的区块哈希，导致接收节点花费大量 I/O 寻找它没有的区块。然而，Maxwell 的测试并未发现这是一个重大问题。尽管如此，Maxwell 提议限制这些消息中允许的定位器数量。Libbitcoin 开发人员 Eric Voskuil 表示他的软件已经在执行限制，并且他知道一个程序（BitcoinJ）略微超过了 Maxwell 提议的限制。

    随后，由 Maxwell 提交并合并的 PR [Bitcoin Core #13907][] 把上限定为与 BitcoinJ 请求的最大数量相同。如果你发现有软件通过 `getblocks` 或 `getheaders` P2P 消息请求超过 101 个元素，请发帖到 bitcoin-dev 邮件列表，或联系 Optech 的成员。

- **<!--schnorr-bip-discussion-->Schnorr BIP 讨论：**上周，bitcoin-dev 邮件列表上专家之间关于 schnorr 签名生成算法的[讨论][schnorr discuss]最终无需修改所提议的 BIP 便得出定论。这或许能增强人们对所提议 BIP 参数选择得当的信心。

## 值得注意的提交

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo] 和 [C-lightning][core lightning repo] 中值得注意的提交。不包括上文描述的 Bitcoin Core #13907 或 #13666。注意：本周这三个项目的大部分改动似乎都是对自动化测试代码的改进；本刊没有介绍这些改进，但我们相信用户和开发者都非常感激这项工作。*

- [Bitcoin Core #13925][]：提高 Bitcoin Core 内部数据库可使用的文件描述符数量上限，从而可以让更多文件描述符用于网络连接。如果你修改过 Bitcoin Core，使其接受的入站连接超过 117 个，那么在升级到包含此合并的版本后，可能会看到连接数进一步增加。（注意：除非有特殊需求，我们不建议提高默认值。）

- [LND #1644][]：用户以 satoshis per vbyte（每 vbyte 的聪数）输入的费率，现在会自动换算为[协议][BOLT2]中定义的 satoshis per kiloweight（1,000 vbytes）。

- [C-Lightning #1811][]：支付节点如果最近 30 秒内没有收到某个节点的消息，就不再向该节点发送 HTLC 承诺交易（支付）。如有必要，它会在发送承诺交易之前先 ping 收款节点。这样，如果某笔支付因网络中断注定失败，支付节点就能更早地中止它。

  此外还包含对重连已断开对等节点的代码的多项中等幅度改进，其中包括指数退避和重连时间的随机抖动（fuzzing）。

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
[bd locators]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016285.html
[schnorr discuss]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016278.html
[fee metrics]: https://statoshi.info/dashboard/db/fee-estimates
[consolidate info]: https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#Consolidation
[btc hash rate]: https://fork.lol/pow/hashrate
[periodic txn data]: https://dashboard.bitcoinops.org/d/K7C9p0vmz/btc-number-of-txns-total-fee-per-block-volume?panelId=4&fullscreen&orgId=1
