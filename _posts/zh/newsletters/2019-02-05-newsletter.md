---
title: 'Bitcoin Optech Newsletter #32'
permalink: /zh/newsletters/2019/02/05/
name: 2019-02-05-newsletter-zh
slug: 2019-02-05-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 包括 2019 年 Chaincode 实习项目的公告，总结了斯坦福区块链会议上的一些演讲，并提供了流行的比特币基础设施项目中值得注意的代码更改列表。

## 行动项

- **<!--apply-to-the-chaincode-residency-->****申请 Chaincode 实习：** Bitcoin Optech 鼓励任何有兴趣在夏季贡献开源比特币和闪电网络项目的工程师申请 Chaincode 实习。实习的完整细节在下面的 *新闻* 部分中。

## 新闻

- **<!--chaincode-residency-2019-->****Chaincode 实习 2019：** Chaincode Labs 开始接受其[第四次实习项目][residency]的申请，该项目将于 2019 年夏季在纽约举行。该项目结合了为期 3 周的比特币和闪电网络协议开发的研讨会和讨论系列，以及在有经验的协议开发者指导下，花费两个月时间进行一个开源比特币或闪电网络项目的工作。已确认的[演讲者和导师][residency speakers]列表包括比特币和闪电网络最活跃的贡献者。上一期 Chaincode 实习（专注于闪电网络应用）在 [Newsletter #21][] 中进行了报道。

  Chaincode 正在邀请希望为开源比特币和闪电网络协议项目做出贡献的开发者[申请实习][residency apply]。欢迎各个背景的申请者，Chaincode 将承担旅行和住宿费用，并提供生活费用津贴。

[residency]: https://residency.chaincode.com
[residency speakers]: https://residency.chaincode.com/#mentors
[residency apply]: https://residency.chaincode.com/#apply

## 斯坦福区块链会议上的值得注意的演讲

该年度会议的[第三版][sbc]（以前称为 BPASE）在三天内包括了二十多个演讲。从比特币的角度来看，我们发现以下主题特别有趣，尽管我们鼓励任何想要了解更多信息的人查看 Bryan Bishop 提供的[转录][transcripts]或组织者提供的视频（[第一天][day 1]、[第二天][day 2]、[第三天][day 3]）。

- **<!--accumulators-for-blockchains-->****区块链的累加器** 由 Benedikt Bünz 介绍（[转录][accumulators txt]，[视频][accumulators vid]）。比特币全节点维护一个账本（称为 UTXO 集），它存储每个当前可支配的比特币组的所有权信息。目前，该账本包含超过 5000 万条记录，占用约 3GB 的磁盘空间。这使得接收交易的节点可以确保被花费的比特币存在于 UTXO 集中，检索这些比特币的所有权信息，并根据交易中提供的签名和其他见证数据验证该信息。

  但是，如果我们要求花费者在其交易中提供所有权信息的副本以及证明该信息实际上在 UTXO 集中的密码学证明会怎样？在这种情况下，我们不需要存储整个集合，只需要存储一个我们知道准确的集合的承诺，并可以通过准确的证明引用该集合。RSA 累加器是创建该承诺及其相关证明的一种方法（还有其他几种方法）。使用累加器，节点在磁盘上存储的 UTXO 承诺的大小将远小于整个状态。交易的大小会增加，因为需要提供所有权数据和证明它们是当前 UTXO 集的一部分，但大小增加是适中的（假设当前典型交易，每个输入大约 70 字节的所有权信息加上可以汇总到每个区块约 325 字节的证明）。

  其他因素影响累加器的适用性，包括它们对密码学相对较新，需要一个经过充分研究的可信设置或一个更新奇的不可信设置，并且可能使区块验证时间比当前系统长，因为累加器验证比使用默克尔树的替代系统慢约 100 倍。在与 2018 年比特币扩容会议上的先前演讲版本相比，新进展中，演讲者描述了对实际验证的潜在重大加速。

  总之，RSA 累加器仍然是一个有趣的研究领域，旨在减少全节点存储和快速访问 UTXO 集的要求。目前，当 UTXO 集相对较小且速度快时，这可能并不特别重要，但它可能使支持改变人们使用 UTXO 集的举措变得更容易。例如：

  - **<!--if-accumulator-based-proofs-->**如果基于累加器的证明确实能够快速验证，它们可以允许 UTXO 集大小显著增加（可能由于区块大小增加），同时确保矿工可以快速验证交易输入，以最大限度地减少使用间谍挖矿或生产陈旧区块的情况。

  - **<!--software-that-uses-->**使用可信 UTXO 集的新启动节点的软件可以通过替换多千兆字节的 UTXO 集为小百万倍的累加器，进一步减少这些成本和延迟，从而避免下载和验证完整区块链的成本和延迟（某些软件[已经提供][btcpay utxo]该选项）。

  积极的实验者应能够在不改变任何共识规则的情况下探索比特币中使用累加器的方法，例如 Tadge Dryja 使用基于默克尔树的类似 [Utreexo][] 系统。

- **<!--miniscript-->****Miniscript** 由 Pieter Wuille 介绍（[转录][miniscript txt]，[视频][miniscript vid]，[幻灯片][miniscript slides]）。想象一下，你有一个比特币脚本，它在你最后一次移动比特币后的一年时间里将你的比特币控制权交给你的律师，以防他需要将其分配给你的继承人。这是一个容易编写的脚本。但如果有人然后要求你加入一个 3-of-4 多重签名合同，你将成为持有一些资金的一方。你将如何将现有的策略插入他们的通用多重签名合同中并确保没有破坏任何东西？这是演讲者提出的问题，他的答案是可组合的策略语言 *miniscript*。

  Miniscript 是比特币脚本语言的一个子集，专注于几个特性，例如*签名*、*时间*和*哈希*，以及用于组合它们的运算符，例如*和*、*或*或*阈值*。它紧凑、易读，并将编译为实现给定策略的最有效脚本。从与其操作兼容的现有脚本中，它还将其反向转换为策略以便于审查。根据设计，它使用类似于 Wuille 在比特币核心中实现的[输出脚本描述符][output script descriptors]的词汇，并且它可以帮助在 [BIP174][] PSBT 工作流中确定下一个需要签名的人或是否已收到最终脚本的所有数据。

  看一下引言段落中提出的问题，我们可以将示例个人支出策略定义为你提供压缩公钥的签名 `pk(C)`，或者你的律师等待一年 `time(<秒>)`，然后提供他自己的压缩公钥签名。我们用不对称的“或” `aor` 来组合这些分支，以减少遵循第一个分支时所需的见证数据。

  ```
  aor(pk(C),and(time(31536000),pk(C)))
  ```

  我们可以类似地使用压缩公钥 (`C`) 定义通用 3-of-4 多重签名策略：

  ```
  multi(3,C,C,C,C)
  ```

  一个功能上等效的策略，允许更多的灵活性，将使用阈值操作：

  ```
  thres(3,pk(C),pk(C),pk(C),pk(C))
  ```

  这使你只需将其中一个公钥替换为你的个人策略：

  ```
  thres(3,pk(C),pk(C),pk(C),aor(pk(C),and(time(31536000),pk(C))))
  ```

  编译后的结果是以下脚本：

  ```
  [pk] CHECKSIG SWAP [pk] CHECKSIG ADD SWAP [pk] CHECKSIG ADD
  TOALTSTACK IF [pk] CHECKSIGVERIFY 0x8033e101 CHECKSEQUENCEVERIFY
  0NOTEQUAL ELSE [pk] CHECKSIG ENDIF FROMALTSTACK ADD 3 EQUAL
  ```

  Miniscript 的一个最终优势是，它应允许今天编写的策略自动翻译为最佳使用 MAST、taproot 或其他可能的比特币协议升级的结构。这意味着，随着比特币协议的进步，用户或开发人员不需要重新做工，以便继续使用新的技术。

  演讲者提供了一个交互式的 Javascript [miniscript 编译器演示][miniscript demo]，他和他的合作者还计划很快发布一个 Rust 语言版本的编译器作为开源。

- **<!--probabilistic-bitcoin-soft-forks-sporks-->****概率比特币软分叉 (sporks)** 由 Jeremy Rubin 介绍（[转录][spork txt]，[视频][spork vid]）。到 2017 年 3 月，几乎所有比特币节点都准备开始执行 segwit 软分叉，但矿工似乎不愿意发送激活信号。这造成了混乱：矿工是否有权否决协议升级？如果他们有，segwit 是否死了？如果没有，用户该怎么办以推翻他们？最终情况得以解决，但这是一个许多人不愿重复的混乱局面。

演讲者将问题的根本原因确定为矿工能够无代价地延迟激活。他提出了一个解决方案：使用区块头哈希中剩余的随机性来确定区块是否发出激活信号。例如，我们会选择一个目标，只有 26000 个哈希中有 1 个匹配。平均每六个月会生成一个匹配该目标的区块，但没人确切知道何时（大约 10% 的时间在 3 周内，但另一个 10% 的时间需要超过一年）。

矿工无法控制其区块是否发出激活信号，但他们可以控制是否发布该区块。拒绝发布其信号激活区块的矿工将失去该区块的收入，但至少在下一个信号区块生成之前（可能是明天，也可能是两年后）成功阻止分叉激活。这给矿工一个真正阻止变化的机会，但只能通过牺牲实际收入。演讲结束时建议了一些不同权衡的方法的变体。

该想法需要分析可能的问题，但它确实为 [BIP9][] 样式的矿工激活软分叉 (MASFs) 和 [BIP8][] 样式的用户激活软分叉 (UASFs) 提供了一个有趣的替代方案。

在演讲的结尾，该演讲者还宣布下一届比特币扩容会议和 EdgeDev++ 培训课程将于 2019 年晚些时候在以色列特拉维夫举行。

## 值得注意的代码更改

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo] 和 [libsecp256k1][libsecp256k1 repo] 中值得注意的代码更改。*

- [Bitcoin Core #14929][] 允许你的节点自动断开的因不良行为（例如发送无效数据）而断开的对等节点，如果你有未使用的传入连接槽，则可以重新连接到你的节点。如果你的槽位满了，则断开不良行为节点以为没有问题记录的节点腾出空间（除非不良行为节点以其他方式帮助你的节点，例如连接到你没有许多其他对等节点的互联网部分）。此前，比特币核心对不良行为对等节点的 IP 地址进行了禁令一段时间（默认 1 天）；这很容易被具有多个 IP 地址的攻击者绕过。该解决方案给这些对等节点一个机会成为有用的对等节点，但优先考虑潜在更有帮助的对等节点。如果你手动禁用了对等节点，例如使用 `setban` RPC，仍将拒绝来自该对等节点的连接。

- [Bitcoin Core #13926][] 添加了一个新的 `bitcoin-wallet` 工具到比特币核心提供的可执行文件中。无需使用 RPC 或任何网络访问，该工具目前可以创建一个新的钱包文件或显示现有钱包的一些基本信息，例如钱包是否加密，是否使用 HD 种子，包含多少交易，和有多少地址簿条目。这帮助那些拥有尚未同步到最近链顶的钱包文件的人；他们可以快速检查钱包是否有趣，然后进行必要的长时间重新扫描以导入它。开发人员计划在未来为该工具添加更多功能。

- [Bitcoin Core #15159][] 更改了 `getrawtransaction` RPC，现在默认情况下仅返回 mempool 中的交易。如果你启用了可选的交易索引（txindex），它还会返回已确认的交易。在此更改之前，即使你没有启用 txindex，如果已确认的交易尚未花费其所有输出，它也会返回已确认的交易。此之前的行为令用户困惑：调用在某些已确认交易上有效，但在其他交易上无效，有时之前有效的交易会突然停止工作。此更改使 RPC 行为更加一致（当然，mempools 在节点之间有所不同并随时间变化）。

- [LND #2538][] 将发送有关网络上存在的公共节点的更新的默认时间从 30 秒增加到 90 秒。这减慢了网络的传播速度，网络已经大大增加，以节省带宽。与此 PR 分开，LN 协议开发人员正在准备更节省带宽的 gossip 协议更改，尽管较低的更新频率仍将节省带宽。（另请参阅 [C-Lightning #2297][]，以修复本周某些节点由于接收到的大量 gossip 而遇到的错误。）

- [LND #2554][] 弃用 `IncorrectHtlcAmount` 洋葱错误，转而使用现在包含失败付款金额的 `UnknownPaymentHash` 错误。LND 仍将处理旧错误代码，但不再生成它。

- [LND #2500][] 断开不支持数据丢失保护（DLP）协议的对等节点。这确保了 LND 的新备份格式将可用。有关新备份协议和现有 DLP 协议的信息，请参阅[上周 Newsletter][Newsletter #31] 的*值得注意的提交*部分和脚注。


{% include references.md %}
{% include linkers/issues.md issues="2500,2554,15159,13926,2538,14929,2297" %}
[accumulators txt]: http://diyhpl.us/wiki/transcripts/stanford-blockchain-conference/2019/accumulators/
[accumulators vid]: https://youtu.be/XckwEw8FyEA?t=20295
[miniscript txt]: http://diyhpl.us/wiki/transcripts/stanford-blockchain-conference/2019/miniscript/
[miniscript vid]: https://youtu.be/sQOfnsW6PTY?t=22539
[miniscript slides]: https://prezi.com/view/KH7AXjnse7glXNoqCxPH/
[miniscript demo]: http://bitcoin.sipa.be/miniscript/miniscript.html
[spork txt]: http://diyhpl.us/wiki/transcripts/stanford-blockchain-conference/2019/spork-probabilistic-bitcoin-soft-forks/
[spork vid]: https://youtu.be/sQOfnsW6PTY?t=29762
[sbc]: https://cyber.stanford.edu/sbc19
[transcripts]: http://diyhpl.us/wiki/transcripts/stanford-blockchain-conference/2019/
[day 1]: https://www.youtube.com/watch?v=XckwEw8FyEA
[day 2]: https://www.youtube.com/watch?v=sQOfnsW6PTY
[day 3]: https://www.youtube.com/watch?v=U5fEvfAFs_o
[utreexo]: https://dci.mit.edu/research/2018/11/28/utreexo-a-dynamic-accumulator-for-bitcoin-state-a-description-of-research-by-thaddeus-dryja
[btcpay utxo]: https://github.com/btcpayserver/btcpayserver-docker/tree/master/contrib/FastSync
[newsletter #21]: /zh/newsletters/2018/11/13/#闪电网络应用实习视频
[newsletter #31]: /zh/newsletters/2019/01/29/#c-lightning-2283
[output script descriptors]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
