---
title: 'Bitcoin Optech Newsletter #32'
permalink: /zh/newsletters/2019/02/05/
name: 2019-02-05-newsletter-zh
slug: 2019-02-05-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 包含 2019 年 Chaincode 驻留项目的公告，概述了斯坦福区块链会议上的几场演讲，并照例列出热门比特币基础设施项目中值得注意的代码变更。

## 行动项

- **<!--apply-to-the-chaincode-residency-->****申请 Chaincode 驻留项目：** Bitcoin Optech 鼓励任何有兴趣花一个夏天为开源比特币与闪电网络项目做贡献的工程师申请 Chaincode 驻留项目。驻留项目的完整细节见下方*新闻*部分。

## 新闻

- **<!--chaincode-residency-2019-->****Chaincode 驻留 2019：** Chaincode Labs 开始接受其[第四次驻留项目][residency]的申请，该项目将于 2019 年夏季在纽约举行。该项目把为期 3 周、涵盖比特币与闪电网络协议开发的研讨会和讨论系列，与为期两个月的实践结合起来：在资深协议开发者指导下，参与一个开源比特币或闪电网络项目。已确认的[演讲者和导师][residency speakers]名单中，包括一些比特币和闪电网络最多产的贡献者。我们在 [Newsletter #21][] 中报道过上一期 Chaincode 驻留（专注于闪电网络应用）。

  Chaincode 正在邀请希望为开源比特币和闪电网络协议项目做贡献的开发者[申请驻留项目][residency apply]。欢迎各种背景的申请者，Chaincode 将承担旅行和住宿费用，并提供生活津贴。

[residency]: https://residency.chaincode.com
[residency speakers]: https://residency.chaincode.com/#mentors
[residency apply]: https://residency.chaincode.com/#apply

## 斯坦福区块链会议上值得注意的演讲

该年度会议的[第三版][sbc]（以前称为 BPASE）在三天内包含二十多场演讲。从比特币的角度看，我们觉得以下主题特别有趣；不过我们也鼓励想深入了解的人查看 Bryan Bishop 提供的[文字记录][transcripts]或组织者提供的视频（[第一天][day 1]、[第二天][day 2]、[第三天][day 3]）。

- **<!--accumulators-for-blockchains-->****区块链的累加器**，由 Benedikt Bünz 主讲（[文字记录][accumulators txt]，[视频][accumulators vid]）。比特币全节点维护一份账本（即 UTXO 集），存储当前每一组可花费比特币的所有权信息。目前，该账本包含超过 5000 万条记录，占用约 3 GB 磁盘空间。这样，节点收到交易后就能确认被花费的比特币确实存在于 UTXO 集中，取回这些比特币的所有权信息，并用交易中提供的签名和其他见证数据验证这些信息。

  但是，如果我们同时要求付款方在交易中提供一份所有权信息副本，以及一份证明这些信息确实在 UTXO 集中的密码学证明，会怎样？这样一来，我们就不必保存整个集合，只需保存一个承诺——它对应一个我们确知准确的集合，并且可以被准确的证明引用。RSA 累加器是构造这种承诺及其相关证明的思路之一（还有其他若干思路）。使用累加器后，节点需要存到磁盘上的 UTXO 承诺，相比完整状态会小得多。交易会因为需要附带所有权数据和“属于当前 UTXO 集”的证明而变大，但增幅并不大（以当前的典型交易估算，每个输入约 70 字节的所有权信息，外加一份可聚合到每个区块约 325 字节的证明）。

  还有一些因素影响累加器是否适合这项任务，包括：它在密码学中尚属较新的工具；需要经过充分研究的可信设置，或一个更新颖的无需信任设置；并且由于累加器验证比使用默克尔树的替代方案慢约 100 倍，可能使区块验证比现行系统更耗时。与 2018 年 Scaling Bitcoin 大会上这个演讲的早期版本相比，此次有一项新进展：演讲者描述了实际验证可能获得的显著提速。

  总之，RSA 累加器仍是一个有趣的研究方向，目标是降低全节点在存储和快速访问 UTXO 集方面的要求。在 UTXO 集还相对较小、访问也快的时候，这或许并不特别重要，但它可以让那些会改变人们使用 UTXO 集方式的举措更容易落地。例如：

  - **<!--if-accumulator-based-proofs-->**如果基于累加器的证明真能快速验证，它们就可以允许 UTXO 集规模大幅增长（比如因为区块大小增加），同时仍能保证矿工足够快地验证交易输入，从而尽量减少使用间谍挖矿或产生陈旧区块。

  - **<!--software-that-uses-->**有些软件会为新启动的节点使用可信的 UTXO 集，以避免下载并验证完整区块链带来的开销和延迟（某些软件[已经提供][btcpay utxo]该选项）。这类软件可以把数 GB 的 UTXO 集换成一个小一百万倍的累加器，从而进一步降低这些开销和延迟。

  热心的实验者应当可以在不改变任何共识规则的前提下，探索在比特币中使用累加器，就像 Tadge Dryja 一直在做的、基于默克尔树的类似系统 [Utreexo][] 那样。

- **<!--miniscript-->****Miniscript**，由 Pieter Wuille 主讲（[文字记录][miniscript txt]，[视频][miniscript vid]，[幻灯片][miniscript slides]）。想象你有一个比特币脚本：在你最后一次动用这些比特币满一年之后，它把比特币的控制权交给你的律师，以备他需要把它们分给你的继承人。这样的脚本很容易写。但如果有人随后请你加入一份 3-of-4 多重签名合约，而你会是持有其中部分资金的一方，情况又如何？要把你现有的策略嵌入他们这份通用多重签名合约，并确保没有破坏任何东西，有多难？这就是演讲者提出的问题，他的答案是：可组合的策略语言 *miniscript*。

  Miniscript 是完整的比特币 Script 语言的一个子集，只关注少数几类特性，例如*签名*、*时间*和*哈希*，以及用于组合它们的运算符，例如*与*、*或*和*阈值*。它紧凑、易读，并能编译成实现给定策略的最高效脚本。对于操作符合其语法的现有脚本，它还能反向还原成策略，便于审查。按设计，它采用的词汇与 Wuille 一直在 Bitcoin Core 中实现的[输出脚本描述符][output script descriptors]相似；它还能帮助 [BIP174][] PSBT 工作流中的更新方或终结方判断下一个该由谁签名，或者最终确定脚本所需的数据是否已全部收到。

  回到引言里提出的问题，我们可以把这个示例个人花费策略定义为：要么由你提供自己压缩公钥的签名 `pk(C)`，要么由你的律师先等待一年 `time(<seconds>)`，再提供他自己压缩公钥的签名。我们用不对称的“或” `aor` 把这两个分支组合起来，以减少走第一个分支时所需的见证数据。

  ```
  aor(pk(C),and(time(31536000),pk(C)))
  ```

  我们可以类似地使用压缩公钥 (`C`) 定义通用 3-of-4 多重签名策略：

  ```
  multi(3,C,C,C,C)
  ```

  一个功能等价、但灵活性更高的策略会使用阈值操作：

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

  Miniscript 的最后一个好处是：它应能让今天编写的策略自动转换成一种结构，从而最充分地利用 MAST、taproot 或其他可能的比特币协议升级。这意味着，随着比特币协议演进，投入时间编写策略的用户或开发者不必为了在新技术的环境中继续使用它而重做工作。

  演讲者提供了一个交互式的 Javascript [miniscript 编译器演示][miniscript demo]；他和合作者还计划很快以开源方式发布一个 Rust 语言版本的编译器。

- **<!--probabilistic-bitcoin-soft-forks-sporks-->****概率性比特币软分叉（sporks）**，由 Jeremy Rubin 主讲（[文字记录][spork txt]，[视频][spork vid]）。到 2017 年 3 月，几乎所有比特币节点都已准备好开始强制执行 segwit 软分叉，但矿工似乎不愿意发出激活信号。这造成了混乱：矿工有权否决协议升级吗？如果有，segwit 是不是就没戏了？如果没有，用户又该如何推翻矿工的决定？最终局面得以化解，但那是一场许多人不愿再重演的混乱。

  演讲者把问题的根源归结为：矿工可以零成本地拖延激活。他提出了一个解决方案：用区块头哈希中剩余的随机性来决定某个区块是否发出激活信号。例如，我们会选定一个目标，使每 26,000 个区块头哈希中只有 1 个能够匹配。平均每六个月才会产生一个符合该目标的区块，但没人知道确切时间（约 10% 的情况会在 3 周内出现，另有 10% 的情况要等一年多）。

  矿工无法决定自己的区块是否发出激活信号，但可以决定是否发布该区块。如果自己的区块发出了激活信号，矿工可以选择不发布：他会损失该区块的收入，但至少能成功阻止分叉激活，直到下一个信号区块产生（也许就在明天，也许要两年之后）。这确实给了矿工阻止变更的机会，但代价是牺牲真实收入。演讲末尾还给出了该方法的一些变体，各自的取舍不同。

  这个想法还需要针对潜在问题做分析，但它确实为 [BIP9][] 式的矿工激活软分叉（MASF）和 [BIP8][] 式的用户激活软分叉（UASF）提供了一个有趣的替代方案。

  演讲结尾，他还宣布下一届 Scaling Bitcoin 大会和 EdgeDev++ 培训课程将于 2019 年晚些时候在以色列特拉维夫举行。

## 值得注意的代码变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo] 和 [libsecp256k1][libsecp256k1 repo] 中值得注意的代码变更。*

- [Bitcoin Core #14929][] 允许那些因行为不当（例如发送无效数据）而被你的节点自动断开连接的对等方，在你还有空闲入站连接槽位时重新连接你的节点。如果槽位被占满，这些行为不当的节点会被断开，以便为没有不良记录的节点腾出位置（除非该行为不当节点以其他方式帮助了你的节点，例如它连接的正是你其他对等方很少的互联网区域）。此前，Bitcoin Core 会封禁行为不当对等方的 IP 地址一段时间（默认 1 天）；拥有多个 IP 地址的攻击者很容易绕过这一限制。这个方案让这些对等方有机会发挥用处，同时仍优先考虑可能更有帮助的对等方。如果你手动封禁了某个对等方（例如使用 `setban` RPC），来自该对等方的连接仍会被拒绝。

- [Bitcoin Core #13926][] 在 Bitcoin Core 提供的可执行文件中新增了 `bitcoin-wallet` 工具。该工具无需使用 RPC，也不访问网络，目前就能创建新的钱包文件，或显示现有钱包的一些基本信息，例如钱包是否加密、是否使用 HD 种子、包含多少交易，以及有多少地址簿条目。这对那些持有尚未同步到最新链尖的钱包文件的人很有帮助：他们可以先快速检查钱包是否有值得关注的内容，再决定是否执行耗时的重新扫描来导入它。开发者计划今后为该工具增加更多功能。

- [Bitcoin Core #15159][] 更改了 `getrawtransaction` RPC，现在默认只返回内存池（mempool）中的交易。如果你启用了可选的交易索引（txindex），它也会返回已确认的交易。在此更改之前，即使没有启用 txindex，只要某笔已确认交易的输出尚未全部花费，它也会返回该交易。之前这种行为让用户很困惑：该调用对某些已确认交易有效，对另一些却无效，有时原本能用的交易会突然失效。这项更改让 RPC 的行为更一致（当然，内存池在各节点之间并不相同，也会随时间变化）。

- [LND #2538][] 把广播网络中公开节点信息的默认间隔从 30 秒延长到 90 秒。网络规模已经变得极其庞大，为此需要节省带宽，代价是减慢了信息在网络中的传播速度。除此之外，LN 协议开发者还在准备更节省带宽的 gossip 协议变更，不过降低更新频率同样能在那里省下带宽。（另请参阅 [C-Lightning #2297][]：本周修复了一个 bug，某些节点因收到的 gossip 数据量过大而遇到了该问题。）

- [LND #2554][] 弃用 `IncorrectHtlcAmount` 洋葱错误，转而采用 `UnknownPaymentHash` 错误，后者现在会带上失败支付的金额。LND 仍会处理旧错误代码，但不再生成它。

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
[newsletter #21]: /zh/newsletters/2018/11/13/#闪电网络应用驻留项目视频
[newsletter #31]: /zh/newsletters/2019/01/29/#c-lightning-2283
[output script descriptors]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
