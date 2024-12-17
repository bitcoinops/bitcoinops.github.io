---
title: 'Bitcoin Optech Newsletter #139'
permalink: /zh/newsletters/2021/03/10/
name: 2021-03-10-newsletter-zh
slug: 2021-03-10-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了关于提议的 taproot 激活方法的持续讨论，并链接到一个记录现有基于 taproot 的软件构建工作的尝试。还包括我们定期的部分内容，涵盖了 Bitcoin Core PR 审查俱乐部会议的总结、新的发布与候选发布的公告，以及对流行比特币基础设施项目的值得注意更改的描述。

## 新闻

- **<!--taproot-activation-discussion-->****Taproot 激活讨论：** 前几周的讨论中，不同群体分别反对 [BIP8][] `LockinOnTimeout=true` (`LOT=true`) 或 `LOT=false`。因此，本周邮件列表上的大部分讨论集中在其他激活机制上。一些提议包括：

  - **<!--user-activated-soft-fork-uasf-->***用户激活软分叉（UASF）：* 正在[讨论][uasf discussion]的计划是在一个 Bitcoin Core 的软件分叉中实施 BIP8 `LOT=true`，要求矿工在 2022 年 7 月（如广泛提议的）之前为 taproot 激活进行信号，但也允许矿工更早地激活。

  - **<!--flag-day-->***特定区块高度（flag day）：* 几个提案（[1][flag day corallo]、[2][flag day belcher]）主张在大约 18 个月后（如提议）在节点中编程一个特定区块高度或时间点来激活 taproot。矿工信号并非激活所必须，也无法导致更早的激活。Anthony Towns 编写了一个[草案实现][bitcoin core #21378]。

  - **<!--decreasing-threshold-->***阈值逐渐递减：* 几个提案（[1][decthresh guidi]、[2][decthresh luaces]）主张随着时间的推移逐渐减少在新共识规则锁定之前需要矿工为 taproot 执行进行信号的区块数量。另请参见 Anthony Towns 去年在 [Newsletter #107][news107 decthresh] 中描述的提案。

  - **<!--a-configurable-lot-->***可配置的 `LOT`：* 除了先前讨论过的将 BIP8 的 `LOT` 值作为配置选项的提议（见 [Newsletter #137][news137 bip8conf]），还[发布][rubin invalidateblock]了演示如何通过调用 RPC 命令的外部脚本来强制执行 `LOT=true` 的初步代码。此外，还[创建][towns anti-lot]了代码展示节点运营者如何在担心 `LOT=true` 会造成区块链不稳定的情况下反对它。

  - **<!--a-short-duration-attempt-at-miner-activation-->***短期矿工激活尝试：* [更新的提案][harding speedy]给矿工大约三个月的时间来锁定 taproot，从实现激活逻辑的全节点发布后不久开始计时。如果尝试失败，社区将被鼓励转向其他激活方法。如果尝试成功，仍将有数月的延迟期以便大多数经济体升级他们的节点。该提案的草案实现有[基于 Bitcoin Core 现有 BIP9 代码的版本][bitcoin core #21377]和[基于之前提议的 BIP8 实现的版本][bitcoin core #21392]，分别由 Anthony Towns 和 Andrew Chow 编写。

  尽管似乎没有任何提案会成为几乎所有人的首选，但看起来有许多人[愿意接受][folkson gist]在“Speedy Trial”名义下的短期尝试方法。对此仍有一些顾虑，包括：

  - **<!--could-be-co-opted-for-mandatory-activation-->***可能被强制激活所利用：* 尽管该提案明确鼓励在矿工未能快速足够地信号支持 taproot 时使用其他激活尝试，但有[担忧][corallo not speedy enough]这可能被某些用户群体利用来快速强制激活，尽管[有人指出][##taproot-activation log 3/5]此前没有群体曾表示想在如此危险的短时间内尝试强制激活。

  - **<!--using-time-based-or-height-based-parameters-->***使用基于时间还是区块高度的参数：* 该提案描述了使用时间戳（基于前 11 个区块的中值时间）还是区块高度来设置 `start`、`timeout` 和 `minimum_activation` 参数的权衡。使用时间戳将产生最小且最易审查的对 Bitcoin Core 的补丁。使用高度则提供更多可预测性，尤其对矿工而言，并与使用 BIP8 的其他尝试兼容。

  - **<!--myopic-->***短视（myopic）：* 有[担忧][russell concern]认为该提案过于关注短期。正如在 IRC 中[总结][irc speedy]的：“Speedy Trial 为（矿工激活 taproot 的）可能情况做好了充分准备，但并未将 Segwit 激活不及时的经验教训进行制度化。我们有机会在 taproot 激活中为未来的激活创建一个模板，明确开发者、矿工、商家、投资者和最终用户在各种激活路径下的角色与责任，尤其是在启用和确立比特币经济用户作为最终仲裁者的角色上。如果现在不定义，将来只会更困难，因为我们只有在危机中才会去做，并且随着比特币的增长，将来达成共识将需要在更大规模上进行，更加困难。”

  - **<!--speed-->***速度（Speed）：* 基于对 ##taproot-activation IRC 频道的初步讨论，该提案建议给矿工约三个月的时间来锁定 taproot，并从开始度量信号的时间点起等待固定的六个月（如果锁定成功）再激活。一些人希望时间稍短或稍长。

  我们将继续跟踪各种提案的讨论，并在未来的 Newsletter 中总结任何重要进展。

- **<!--documenting-the-intention-to-use-and-build-upon-taproot-->****记录使用与构建在 taproot 之上的软件意愿：** 在关于激活方法的讨论中，Chris Belcher [指出][flag day belcher]，在为 Segwit 激活进行辩论期间，人们曾收集过一个大型列表，列出表示打算实现 Segwit 的软件开发者。他建议可以创建一个类似的列表来记录对 taproot 的支持程度，从而表明无论 taproot 最终如何被激活，它都是被大量经济参与者所期望的。

  Jeremy Rubin [在 Bitcoin-Dev 邮件列表发帖][rubin building]链接了一个相关的[wiki 页面][taproot uses]，开发者可以在上面发布其基于 taproot 的新功能构建的项目链接。这可为 taproot 确保提供实际需求的解决方案，并表明其特性设计是会被实际使用的。

## Bitcoin Core PR 审查俱乐部

*在本月度部分中，我们总结了最近的 [Bitcoin Core PR 审查俱乐部][Bitcoin Core PR Review Club]会议，突出一些重要的问题和答案。点击下面的问题可查看会议中答案的摘要。*

[Erlay：带宽高效的交易中继协议][review club #18261]是 Gleb Naumenko 的一个 PR（[#18261][Bitcoin Core #18261]），提议在 Bitcoin Core 中实现 [BIP330][]。

审查俱乐部讨论集中在采用 [Erlay][topic erlay] 所涉及的权衡、实现和潜在的新攻击向量上。在后续的会议中，审查俱乐部讨论了 [Minisketch][topic minisketch]，这是一个实现 PinSketch “集合同步（set reconciliation）”算法的[库][minisketch]，是 Erlay 中高效中继协议的基础。

{% include functions/details-list.md
  q0=**<!--q0-->**"什么是 Erlay？"
  a0="一种基于 *泛洪* 与 *集合对账* 相结合的新型交易中继方法（当前的交易中继仅依赖泛洪），可提高带宽效率、可扩展性和网络安全性。该理念在 2019 年的论文 *[Bandwidth-Efficient Transaction Relay for Bitcoin][erlay paper]* 中提出，并在 [比特币改进提案（BIPs）330][BIP330] 中进行了规范。"

  q1=**<!--q1-->**"Erlay 带来哪些优势？"
  a1="[*交易中继的带宽使用量降低*][erlay 1]，约占节点运行所需带宽的一半；以及 [*节点连接数量的可扩展性*][erlay 2]，从而使网络对分区攻击更具韧性，并使 [*单个节点更能抵御 Eclipse 攻击*][erlay 3]。"

  q2=**<!--q2-->**"Erlay 的一些权衡点是什么？"
  a2="交易传播延迟的边际增加。据估计，Erlay 会将未确认交易在所有节点间中继的时间从约 3.15 秒增至约 5.75 秒，但这相比整体约 10 分钟的交易处理时间仅是很小的一部分。另一个权衡点是额外的代码与计算复杂度。"
  a2link="https://bitcoincore.reviews/18261#l-94"

  q3=**<!--q3-->**"为何 Erlay 引入的集合对账比泛洪更易扩展？"
  a3="通过泛洪进行的交易传播中，每个节点都会向其所有对等节点通告其收到的每笔交易，这导致带宽效率低下且冗余度高。当网络连接性提升后，此问题会愈加明显，而改善网络连接本应有利于网络的增长与安全性。Erlay 通过减少低效泛洪发送的交易数据，并以更高效的集合对账方式替代，从而提高可扩展性。"

  q4=**<!--q4-->**"对现有点对点消息类型的发送频率会有何变化？"
  a4="在 Erlay 中，`inv` 消息的发送频率将降低；`getdata` 和 `tx` 消息的发送频率不变。"
  a4link="https://bitcoincore.reviews/18261#l-140"

  q5=**<!--q5-->**"两个节点将如何就使用 Erlay 的集合对账功能达成一致？"
  a5="通过在 version-verack 握手阶段交换一个新的 `sendrecon` 点对点消息来实现。"
  a5link="https://bitcoincore.reviews/18261#l-212"
%}

## 发布与候选发布

*流行比特币基础设施项目的新发布和候选发布。请考虑升级到新版本或帮助测试候选发布。*

- [Eclair 0.5.1][] 是该闪电网络节点的最新版本，包含了启动速度的提升、在同步网络图时降低带宽消耗，以及为支持[锚定输出][topic anchor outputs]做准备的一系列小改进。

- [HWI 2.0.0RC2][hwi 2.0.0] 是 HWI 下一个主要版本的发布候选版本。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo] 中的值得注意的更改。*

- [Bitcoin Core #20685][] 通过使用 [I2P SAM 协议][I2P SAM protocol]增加了对 I2P 隐私网络的支持。这项特性[长期以来一直被请求][Bitcoin Core #2091]，直到最近 [addr v2][topic addr v2] 的加入才得以实现。尽管为运行 I2P 的节点运营者编写的文档仍在创建中，但 [Bitcoin Stack Exchange 的问答][i2p b.se]提供了一些入门提示。

- [C-Lightning #4407][] 更新了 `listpeers` RPC，增加了新的字段，提供每个通道当前单边关闭交易的信息，包括其手续费（无论是总手续费还是手续费率）。

- [Rust-Lightning #646][] 增加了为支付寻找多条路径的能力，从而在将来可能支持[多路径支付（multipath payments）][topic multipath payments]。

- [BOLTs #839][] 为资金交易设定超时时间的建议，旨在当资助资金的交易确认失败时节省资金费，并为出资方和受资方提供更强有力的保证。新建议建议出资方承诺确保资金交易在 2016 个区块内确认，如果资金交易在 2016 个区块内未确认，受资方应忘记该待定通道。

- [BTCPay Server #2181][] 在以 QR 码形式展示 [BIP21][bip21] URI 时将 bech32 地址大写。这使得 QR 码[密度更低][bech32 uppercase qr]，因为大写子串可以更高效地编码。在此更改之前，进行了广泛的[BIP21 URI 兼容性调查][btcpay uri survey]。

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
