---
title: 'Bitcoin Optech Newsletter #139'
permalink: /zh/newsletters/2021/03/10/
name: 2021-03-10-newsletter-zh
slug: 2021-03-10-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了关于 taproot 激活方法的持续讨论，并链接到一项工作：记录已经构建在 taproot 之上的现有软件。此外还包括我们的固定栏目：一场 Bitcoin Core PR 审查俱乐部会议的摘要、发布与候选发布的公告，以及热门比特币基础设施项目的值得注意的变更说明。

## 新闻

- **<!--taproot-activation-discussion-->****Taproot 激活讨论：** 前几周的讨论中，不同群体分别反对 [BIP8][] `LockinOnTimeout=true` (`LOT=true`) 或 `LOT=false`。因此，本周邮件列表上的大部分讨论集中在其他激活机制上。一些提议包括：

  - **<!--user-activated-soft-fork-uasf-->***用户激活软分叉（UASF）：* 一项正在[讨论][uasf discussion]中的计划：在 Bitcoin Core 的一个软件分支中实现 BIP8 `LOT=true`，要求矿工在 2022 年 7 月（这也是各方普遍提议的期限）之前对激活 taproot 表态，同时也允许矿工更早激活。

  - **<!--flag-day-->***固定生效日（flag day）：* 几项提案（[1][flag day corallo]、[2][flag day belcher]）主张在节点中写死一个距今约 18 个月（如提案所述）的特定区块高度或时间点，届时激活 taproot。激活不需要矿工表态，矿工表态也无法让激活提前。Anthony Towns 编写了一份[草案实现][bitcoin core #21378]。

  - **<!--decreasing-threshold-->***递减阈值：* 几项提案（[1][decthresh guidi]、[2][decthresh luaces]）主张随时间推移逐步减少所需的表态区块数量——在新共识规则锁定之前，必须有这么多区块表态已准备好执行 taproot。另请参见 Anthony Towns 去年在 [Newsletter #107][news107 decthresh] 中描述的提案。

  - **<!--a-configurable-lot-->***可配置的 `LOT`：* 除了此前讨论过的把 BIP8 的 `LOT` 值变成配置选项的提案（见 [Newsletter #137][news137 bip8conf]），还有人[发布][rubin invalidateblock]了初步代码，演示如何通过调用 RPC 命令的外部脚本强制执行 `LOT=true`。此外还有[新写的][towns anti-lot]代码，展示担心 `LOT=true` 会造成区块链不稳定的节点运营者可以如何抵制它。

  - **<!--a-short-duration-attempt-at-miner-activation-->***短期矿工激活尝试：* 一份[更新的提案][harding speedy]主张给矿工大约三个月的时间来锁定 taproot，计时从实现激活逻辑的全节点发布后不久开始。如果这次尝试失败，就会鼓励社区转向其他激活方法。如果尝试成功，taproot 激活前仍会有数月延迟，以便经济中的大多数参与者升级节点。该提案有两份草案实现，分别[基于 Bitcoin Core 现有的 BIP9 代码][bitcoin core #21377]和[基于此前提议的 BIP8 实现][bitcoin core #21392]，由 Anthony Towns 和 Andrew Chow 各自编写。

  这些提案似乎都不太可能成为几乎所有人的首选，但看起来有很多人[愿意接受][folkson gist]以 *Speedy Trial* 为名的短期尝试。对此仍有一些顾虑，包括：

  - **<!--could-be-co-opted-for-mandatory-activation-->***可能被借用于强制激活：* 尽管该提案明确鼓励在矿工未能及时充分表态支持 taproot 时尝试其他激活方式，但仍有人[担忧][corallo not speedy enough]它可能被一群寻求快速强制激活的用户所借用，不过[有人指出][##taproot-activation log 3/5]，此前没有任何群体表示过想在如此危险地短的时限内尝试强制激活。

  - **<!--using-time-based-or-height-based-parameters-->***使用基于时间还是区块高度的参数：* 该提案讨论了用时间戳（基于前 11 个区块的中值时间）还是区块高度来设置 `start`、`timeout` 和 `minimum_activation` 参数各自的取舍。使用时间戳会得到最小、最易审查的 Bitcoin Core 补丁；使用区块高度则会带来更好的可预测性（对矿工尤其如此），并能与采用 BIP8 的其他尝试兼容。

  - **<!--myopic-->***短视（myopic）：* 有人[担忧][russell concern]该提案过于关注短期。正如在 IRC 上[总结][irc speedy]的那样：“Speedy Trial 为（很可能发生的）矿工激活 taproot 做好了充分准备，但对于 segwit 未能及时激活的教训，它没有做任何制度化的工作。借助 taproot 激活，我们有机会为未来的激活树立一个模板，明确开发者、矿工、商家、投资者和最终用户在激活可能演进的各种情形下的角色与责任，而不只是最好的结果；特别是要让比特币经济用户所扮演的最终仲裁者角色得以实现并固定下来。今后再定义只会更难：因为我们只会在已经陷入危机时才这么做，而且比特币的增长意味着未来的共识需要在更大规模上达成，难度也会更高。”  <!-- statement written by me trying to summarize Rusty Russell's concerns, then revised by him -->

  - **<!--speed-->***速度（Speed）：* 该提案基于 ##taproot-activation IRC 频道的初步讨论，建议给矿工约三个月的时间锁定 taproot，并从开始统计表态的时间点起等待固定的六个月（若锁定成功）再激活。有人希望时限略短一些，也有人希望略长一些。

  我们将继续跟踪围绕各种提案的讨论，并在未来的 Newsletter 中总结任何重要进展。

- **<!--documenting-the-intention-to-use-and-build-upon-taproot-->****记录使用并构建于 taproot 之上的意愿：** 在关于激活方法的讨论中，Chris Belcher [指出][flag day belcher]，在围绕激活 segwit 的辩论期间，人们曾汇编过一份很长的软件清单，其开发者都表示打算实现 segwit。他建议可以创建一份类似的清单，为后世记录 taproot 获得了多少支持。这样一来，无论 taproot 最终以何种方式激活，都能清楚地表明它得到了经济中很大一部分参与者的支持。

  Jeremy Rubin 在 Bitcoin-Dev 邮件列表上[发帖][rubin building]，给出了一个相关的 [wiki 页面][taproot uses] 链接，开发者可以在上面发布自己基于 taproot 新提议特性构建的项目链接。这可以让人确信：taproot 提供的正是人们真正想要的解决方案，而且其设计方式能确保这些特性会被实际使用。

## Bitcoin Core PR 审查俱乐部

*在这个每月栏目中，我们总结最近一次 [Bitcoin Core PR 审查俱乐部][Bitcoin Core PR Review Club]会议，重点介绍其中的一些重要问题和答案。点击下面的问题，即可查看会议中答案的摘要。*

[Erlay：带宽高效的交易中继协议][review club #18261]是 Gleb Naumenko 提出的一个 PR（[#18261][Bitcoin Core #18261]），提议在 Bitcoin Core 中实现 [BIP330][]。

审查俱乐部的讨论集中在采用 [Erlay][topic erlay] 所涉及的取舍、实现和潜在的新攻击向量上。在后续的会议中，审查俱乐部讨论了 [Minisketch][topic minisketch]：这是一个实现 PinSketch *集合对账*（set reconciliation）算法的[库][minisketch]，也是 Erlay 中高效中继协议的基础。

{% include functions/details-list.md
  q0="**<!--q0-->**什么是 Erlay？"
  a0="一种新的交易中继方法，结合了*泛洪*与*集合对账*（当前的交易中继只依赖泛洪），可提升带宽效率、可扩展性和网络安全性。这一思路在 2019 年的论文 *[Bandwidth-Efficient Transaction Relay for Bitcoin][erlay paper]* 中提出，并在 [BIP330][] 中给出规范。"

  q1="**<!--q1-->**Erlay 带来哪些优势？"
  a1="[*交易中继占用的带宽更少*][erlay 1]，这部分约占运行一个节点所需带宽的一半；以及 [*对等节点连接的可扩展性*][erlay 2]，使网络更能抵御分区攻击，也让 [*单个节点更能抵御日食攻击*][erlay 3]。"

  q2="**<!--q2-->**Erlay 有哪些取舍？"
  a2="交易传播延迟会略有增加。据估计，Erlay 会把未确认交易在所有节点间中继所需的时间从 3.15 秒增加到 5.75 秒，而这相比约 10 分钟的整体交易处理时间只占很小一部分。另一个取舍是代码与计算复杂度的增加。"
  a2link="https://bitcoincore.reviews/18261#l-94"

  q3="**<!--q3-->**为什么 Erlay 引入的集合对账能比泛洪更好地扩展？"
  a3="在泛洪式交易传播中，每个节点都会把自己收到的每笔交易通告给所有对等节点，带宽效率低且冗余度高。网络连通性越好，这种情况就越严重，而连通性本身对网络的成长与安全本该是有利的。Erlay 减少了通过低效泛洪发送的交易数据，改用更高效的集合对账，从而提升可扩展性。"

  q4="**<!--q4-->**对现有点对点消息类型的发送频率会有何变化？"
  a4="在 Erlay 中，`inv` 消息的发送频率将降低；`getdata` 和 `tx` 消息的发送频率不变。"
  a4link="https://bitcoincore.reviews/18261#l-140"

  q5="**<!--q5-->**两个节点将如何就使用 Erlay 的集合对账功能达成一致？"
  a5="通过在 version-verack 握手阶段交换一个新的 `sendrecon` 点对点消息来实现。"
  a5link="https://bitcoincore.reviews/18261#l-212"
%}

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [Eclair 0.5.1][] 是该 LN 节点的最新版本，包含启动速度的提升、同步网络图时带宽消耗的降低，以及为支持[锚定输出][topic anchor outputs]做准备的一系列小改进。

- [HWI 2.0.0RC2][hwi 2.0.0] 是 HWI 下一个主要版本的候选发布。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]中值得注意的变更。*

- [Bitcoin Core #20685][] 通过 [I2P SAM 协议][I2P SAM protocol]增加了对 I2P 隐私网络的支持。这一特性[长期有人请求][Bitcoin Core #2091]，直到最近加入 [addr v2][topic addr v2] 之后才得以实现。面向希望运行 I2P 的节点运营者的文档仍在编写中，不过 [Bitcoin Stack Exchange 的一则问答][i2p b.se]提供了一些入门提示。

- [C-Lightning #4407][] 更新了 `listpeers` RPC，新增若干字段，提供每个通道当前单方面关闭交易的信息，包括其手续费（既有总手续费，也有费率形式）。

- [Rust-Lightning #646][] 增加了为支付寻找多条路径的能力，从而为将来添加[多路径支付][topic multipath payments]支持创造了条件。

- [BOLTs #839][] 为注资交易新增了超时建议，以便在注资交易未能确认时节省资金手续费，并为通道的出资方和受资方提供更强的保证。新建议提出：出资方应承诺确保注资交易在 2016 个区块内确认；若注资交易未能在 2016 个区块内确认，受资方应忘记这个待定通道。

- [BTCPay Server #2181][] 在以 QR 码形式展示 [BIP21][bip21] URI 时把 bech32 地址转为大写。这样得到的 QR 码[密度更低][bech32 uppercase qr]，因为大写子串的编码效率更高。在做出这一更改之前，曾对钱包与 BIP21 URI 方案的兼容性做过一次广泛[调查][btcpay uri survey]。

{% include references.md %}
{% include linkers/issues.md issues="20685,4407,646,839,2181,21378,21377,21392,2091,18261" %}
[uasf discussion]: http://gnusha.org/uasf/2021-03-02.log
[flag day corallo]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-February/018495.html
[flag day belcher]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018538.html
[decthresh guidi]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-February/018476.html
[decthresh luaces]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018587.html
[rubin invalidateblock]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018514.html
[towns anti-lot]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018512.html
[harding speedy]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018583.html
[irc speedy]: http://gnusha.org/taproot-activation/2021-03-08.log
[folkson gist]: https://gist.github.com/michaelfolkson/92899f27f1ab30aa2ebee82314f8fe7f
[corallo not speedy enough]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018596.html
[##taproot-activation log 3/5]: http://gnusha.org/taproot-activation/2021-03-06.log
[rubin building]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018604.html
[taproot uses]: https://en.bitcoin.it/wiki/Taproot_Uses
[news107 decthresh]: /zh/newsletters/2020/07/22/#mailing-list-thread
[news137 bip8conf]: /zh/newsletters/2021/02/24/#taproot-activation-discussion
[eclair 0.5.1]: https://github.com/ACINQ/eclair/releases/tag/v0.5.1
[hwi 2.0.0]: https://github.com/bitcoin-core/HWI/releases/tag/2.0.0-rc.2
[russell concern]: https://twitter.com/rusty_twit/status/1368325392591822848
[btcpay uri survey]: https://github.com/btcpayserver/btcpayserver/issues/2110
[bech32 uppercase qr]: /zh/bech32-sending-support/#使用-bech32-地址创建更高效的二维码
[bip21]: https://github.com/bitcoin/bips/blob/master/bip-0021.mediawiki
[I2P wiki]: https://en.wikipedia.org/wiki/I2P
[I2P SAM protocol]: https://geti2p.net/en/docs/api/samv3
[i2p b.se]: https://bitcoin.stackexchange.com/questions/103402/how-can-i-use-bitcoin-core-with-the-anonymous-network-protocol-i2p
[erlay paper]: https://arxiv.org/abs/1905.10518
[erlay 1]: https://bitcoincore.reviews/18261#l-94
[erlay 2]: https://bitcoincore.reviews/18261#l-97
[erlay 3]: https://bitcoincore.reviews/18261#l-99
[minisketch]: https://github.com/sipa/minisketch
