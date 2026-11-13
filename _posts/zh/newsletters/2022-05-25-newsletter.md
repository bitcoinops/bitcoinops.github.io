---
title: 'Bitcoin Optech Newsletter #201'
permalink: /zh/newsletters/2022/05/25/
name: 2022-05-25-newsletter-zh
slug: 2022-05-25-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周 Newsletter 总结了一份关于包中继的 BIP 草案，并概述了 Bitcoin 契约设计中与矿工可提取价值（MEV）相关的一项担忧。此外还包括本刊的固定栏目：Bitcoin Stack Exchange 精选问答、最新发布与候选发布公告，以及热门比特币基础设施软件的值得注意的变更介绍。

## 新闻

- **<!--package-relay-proposal-->****包中继提案：** Gloria Zhao [发布][zhao package]了一份关于[包中继][topic package relay]的 BIP 草案。该特性可以显著提升 [CPFP 手续费追加（fee bumping）][topic cpfp] 的可靠性，确保子交易能够贡献手续费来帮助父交易获得确认。包括 LN 在内的若干合约协议已经依赖可靠的 CPFP 手续费追加，因此包中继将改善它们的安全性和可用性。该草案提议在比特币 P2P 协议中新增四条消息：

  - `sendpackages`：允许两个对端协商各自支持的包接受特性。

  - `getpckgtxns`：请求之前已作为某个包的一部分公告的交易。

  - `pckgtxns`：提供属于某个包的交易。

  - `pckginfo1`：提供一个交易包的信息，包括交易数量、每笔交易的标识符（wtxid）、交易的总大小（weight）以及总手续费。包的费率可通过手续费除以 weight 计算得到。

  此外，现有的 `inv` 与 `getdata` 消息新增了一种清单（inv）类型 `MSG_PCKG1`。节点可以用它告诉对端自己愿意发送某笔交易的 `pckginfo1`，对端随后可据此请求该交易的 `pckginfo1`。

  借助这些消息，节点可通过 `inv(MSG_PCKG1)` 告诉对端其可能希望接收某笔交易的 `pckginfo1`，例如该交易是低费率未确认父交易的高费率子交易，而对端原本可能会忽略它。只要对端请求了 `pckginfo1`，就能利用消息中的信息判断自己是否真的对该包感兴趣，并获知验证这个高费率子交易需要下载哪些交易的 wtxid。具体交易可以用 `getpckgtxns` 消息请求，并在 `pckgtxns` 消息中收到。

  虽然 [BIP 草案][bip-package-relay]仅聚焦协议本身，Zhao 的邮件提供了更多背景，简要描述了被认定为不足的替代设计，并链接到一份含更多细节的[演示文稿][zhao preso]。

- **<!--miner-extractable-value-discussion-->****矿工可提取价值讨论：** 开发者 /dev/fd0 [发布][fd0 ctv9]了第九次关于 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]（CTV）的 IRC 会议摘要。在该会议讨论的若干主题中，Jeremy Rubin 列举了他听到的人们对递归[契约][topic covenants]（CTV 本身并不启用递归契约）表达的几项担忧。其中之一是，递归契约会创造出远超简单交易选择算法（例如 Bitcoin Core 提供的算法）所能获得的矿工可提取价值（MEV）。

  在使用公开链上交易协议的以太坊及相关协议中，MEV 已成为一个突出问题——矿工可以抢先执行交易。例如，假设下一区块中有如下两笔未确认交易：

  * Alice 以 1 ETH 的价格将资产 *x* 卖给 Bob
  * Bob 以 2 ETH 的价格将 *x* 卖给 Carol（Bob 获利 1 ETH）

  <br>如果这两笔交换通过公开链上协议完成，矿工就能绕过 Bob，示例如下：

  * Alice 以 1 ETH 的价格将资产 *x* 卖给矿工 Mallory
  * 矿工 Mallory 以 2 ETH 的价格将 *x* 卖给 Carol（Mallory 获利 1 ETH，Bob 一无所获）

  <br>这不仅对 Bob 是个问题，也给网络带来好几个问题。首先，矿工需要寻找 MEV 机会。在上面的简单例子中这很容易，但更复杂的机会只能靠计算密集的算法发现。一定计算量所能找到的价值，与各矿工的算力无关，因此两名矿工联合起来，就能把捕获 MEV 所需的计算花费减半——这种规模经济会鼓励挖矿中心化，也可能让网络更容易遭受交易审查。BitMex Research 的一份 [报告][bitmex flashbots] 称，在报告撰写之时，90% 的以太坊算力都在使用一家撮合此类 MEV 交易的集中化服务。为了取得最大收益，该服务可以被改造成阻止矿工打包竞争交易；如果 100% 的矿工都在使用它（或者使用它的矿工超过 50%，并且允许它进行区块链重组），它实际上就获得了审查交易的能力。

  第二个问题是，即便 Mallory 打包了包含 1 ETH MEV 的区块，其他矿工仍可重挖区块以将该 MEV 据为己有。这种重新挖矿的压力加剧了[手续费狙击][topic fee sniping]，在最严重的情况下会令确认分数失去判断交易终局性的意义，从而削弱工作量证明保护网络的能力。

  比特币采用 UTXO 而非以太坊式账户体系，使得那些特别易受 MEV 影响的协议更难实现。然而在 CTV 会议上，Jeremy Rubin 指出递归契约可更轻松地在比特币 UTXO 之上实现账户系统，从而增加 MEV 在未来比特币协议设计中成为重大问题的可能性。

  针对 /dev/fd0 的邮件列表摘要，开发者 ZmnSCPxj 建议我们仅采纳鼓励链上隐私最大化的机制。隐私可以让矿工无法获取执行 MEV 所需的信息。截至本期 Newsletter 撰写时，邮件列表上尚未出现后续评论，但从 Twitter 等处的讨论可以看出，开发者越来越多地在比特币协议设计中考虑 MEV 的影响。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们有点空闲时帮助好奇或困惑用户的地方。在本月栏目中，我们精选自上次更新以来得票最高的一些问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--how-much-entropy-is-lost-alphabetising-your-mnemonics-->**[将助记词按字母序排列会损失多少熵？]({{bse}}113432)
  HansBKK 想知道如果把 12 或 24 词的种子按字母序排序，会损失多少熵。Pieter Wuille 通过可能性数量、熵值、暴力破解所需的平均猜测次数等多项指标，分别分析了 12 词和 24 词的情况，还提到了词语重复方面需要注意的地方。

- **<!--taproot-signing-with-psbt-how-to-determine-signing-method-->**[使用 PSBT 进行 Taproot 签名：如何确定签名方式？]({{bse}}113489)
  Guggero 列出了在 taproot 中提供有效 [schnorr 签名][topic schnorr signatures]的三种方式：带有 [BIP86][] 承诺的 keypath 支付、带脚本树根承诺的 keypath 支付，以及 scriptpath 支付。Andrew Chow 确认了 Guggero 对每种签名方式在 [PSBT][topic psbt] 中标识方法的概述。

- **<!--how-would-faster-blocks-cause-mining-centralization-->**[更快区块会如何导致挖矿中心化？]({{bse}}113505)
  Murch 解释了更短出块时间如何导致更频繁的重组，以及在区块传播延迟的背景下，这如何使大型矿工受益。

- **<!--what-does-waste-metric-mean-in-the-context-of-coin-selection-->**[在选币上下文中，“浪费指标”是什么意思？]({{bse}}113622)
  Murch 说明，在花费时，Bitcoin Core 使用[浪费指标][news165 waste]这一启发式方法，衡量“当前费率下该输入集合的手续费，与在假设的长期费率下花费同一组输入的手续费相比如何”。该指标用于评估分支限界（BnB）、单次随机抽取（SRD）与背包算法产生的[选币][topic coin selection]方案。

- **<!--why-isn-t-op-checkmultisig-compatible-with-batch-verification-of-schnorr-signatures-->**[为什么 `OP_CHECKMULTISIG` 不兼容 schnorr 签名的批量验证？]({{bse}}113816)
  Pieter Wuille 指出，由于 [`OP_CHECKMULTISIG`][wiki op_checkmultisig] 并未指明哪份签名对应哪些公钥，它与批量验证不兼容，这也[促使][bip342 fn4] BIP342 引入新的 `OP_CHECKSIGADD` 操作码。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [Core Lightning 0.11.1][] 是一个错误修复版本，解决了导致单边通道关闭交易被不必要广播的问题，以及导致 C-Lightning 节点崩溃的另一问题。

- [LND 0.15.0-beta.rc3][] 是这一流行 LN 节点下一个主要版本的候选发布。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]的值得注意的变更。*

- [Bitcoin Core #20799][]
  移除了对版本 1 [紧凑区块中继][topic compact block relay]的支持；版本 1 曾让向不支持 segwit 的对端中继区块和交易变得更快、更节省带宽。版本 2 仍然启用，可向支持 segwit 的对端进行快速高效的中继。

- [LND #6529][]
  新增 `constrainmacaroon` 命令，可用于限制已经创建的 macaroon（认证令牌）的权限。此前若要改变权限，必须重新创建一个 macaroon。

- [LND #6524][]
  把 LND 的 aezeed 备份方案版本号从 0 提升到 1。这会告诉未来从 aezeed 备份恢复资金的软件，应当扫描钱包收到的 [taproot][topic taproot] 输出。

## 特别感谢

除常规 Newsletter 贡献者外，我们特别感谢 Jeremy Rubin 本周就 MEV 话题提供的额外细节。如有错误或遗漏，仍由我们自行负责。


{% include references.md %}
{% include linkers/issues.md v=2 issues="20799,6529,6524" %}
[lnd 0.15.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.0-beta.rc3
[Core Lightning 0.11.1]: https://github.com/ElementsProject/lightning/releases/tag/v0.11.1
[zhao package]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-May/020493.html
[bip-package-relay]: https://github.com/bitcoin/bips/pull/1324
[zhao preso]: https://docs.google.com/presentation/d/1B__KlZO1VzxJGx-0DYChlWawaEmGJ9EGApEzrHqZpQc/edit#slide=id.p
[fd0 ctv9]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-May/020501.html
[ctv9]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-May/020501.html
[bitmex flashbots]: https://blog.bitmex.com/flashbots/
[news165 waste]: /zh/newsletters/2021/09/08/#bitcoin-core-22009
[wiki op_checkmultisig]: https://en.bitcoin.it/wiki/OP_CHECKMULTISIG
[bip342 fn4]: https://github.com/bitcoin/bips/blob/master/bip-0342.mediawiki#cite_note-4
