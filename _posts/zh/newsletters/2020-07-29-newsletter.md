---
title: 'Bitcoin Optech Newsletter #108'
permalink: /zh/newsletters/2020/07/29/
name: 2020-07-29-newsletter-zh
slug: 2020-07-29-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了一项允许在不新开通道的情况下升级 LN 通道承诺交易格式的提案，并包括 River Financial 使用 PSBT 和描述符构建钱包软件的现场报告。还包括了我们常规的栏目：Bitcoin Stack Exchange 精选问答、最近的发布与候选发布以及对流行比特币基础设施项目的值得注意的更改。

## 行动项

*本周无。*

## 新闻

- **<!--upgrading-channel-commitment-formats-->****升级通道承诺格式：** Olaoluwa Osuntokun 本周在 Lightning-Dev 邮件列表中[发布][osuntokun upgrade]了一项建议，提出对 LN 规范进行扩展，允许拥有现有通道的两方协商采用不同格式的新的承诺交易。承诺交易用于允许 LN 节点在链上发布当前的通道状态，但现有协议仅允许节点通过新开通道来升级到新的承诺格式。Osuntokun 的提案允许一个节点向其对等节点发送信号，表示希望切换格式。如果对等节点同意，两个节点将把现有通道状态移植到新格式中，并在未来使用新格式。

  所有讨论的参与者似乎都支持这一基本想法。Bastien Teinturier [建议][teinturier simple]，最简单的方式是仅允许在通道没有待处理支付（HTLC）的情况下切换承诺格式——这意味着节点需要暂停在特定通道内发送或中继支付以进行升级。

  ZmnSCPxj [指出][zmnscpxj re-funding]，同样的基本思路可以用于在链下更新资金交易，例如在实现 [taproot][topic taproot] 和 [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] 的情况下，允许使用基于 [Eltoo][topic eltoo] 的通道承诺。在 ZmnSCPxj 的提案中，现有资金交易的输出将支付给一个新的资金交易，该交易保持在链下。如果通道以双边关闭终止，原始资金交易的输出将支付给最终的通道余额；否则，链下的次级资金交易可以发布到链上，并可以使用适当的单边关闭协议解决通道。

## 现场报告：在 River 中使用 Descriptors 和 PSBT

{% include articles/zh/river-descriptors-psbt.md %}

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找答案的首选之地之一——或者在我们有空时帮助那些好奇或困惑的用户。在这个月度专题中，我们精选了一些自上次更新以来获得最高投票的问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--what-are-leaf-versions-in-taproot-->**[Taproot 中的“叶版本”是什么？]({{bse}}97104)
  Michael Folkson 和 Pieter Wuille 解释说，Taproot 树的每个叶节点都承诺一个叶版本和一个脚本。这个叶版本可以用于可升级性，并指定只适用于该叶节点的脚本语义。

- **<!--what-are-the-different-upgradability-features-in-the-bip-taproot-bip341-proposal-->**[BIP-Taproot (BIP341) 提案中的不同可升级性特征是什么？]({{bse}}96951)
  Michael Folkson 回答了来自 Twitter 的一个关于 Taproot 如何实现可升级性的不同方式的问题，包括叶版本用于脚本语义、重新利用操作码以实现未来功能、密钥类型以及用于新字段的附加部分。

- **<!--is-there-an-active-list-of-bips-currently-open-->**[是否有一个当前开放的 BIP 列表？]({{bse}}97043)
  Pieter Wuille 描述了以前用于激活软分叉的各种方法，并指出虽然 Bitcoin Core 目前没有未激活的软分叉，但正在讨论 Taproot 的激活方法。Pieter 还回答了一个[类似的问题][stack exchange miner signaling]，涉及矿工信号支持。

- **<!--could-we-skip-the-taproot-soft-fork-and-instead-use-simplicity-to-write-the-equivalent-of-taproot-scripts-->**[我们能否跳过 Taproot 软分叉，而使用 Simplicity 编写等效的 Taproot 脚本？]({{bse}}97049)
  Michael Folkson 引用 Pieter Wuille，概述了 [Simplicity][news96 simplicity] 的当前状态，并指出将 Simplicity 作为叶版本集成到 Taproot 中将是更可取的。

## 发布与候选发布

*流行的比特币基础设施项目的新发布和候选发布。请考虑升级到新版本或帮助测试候选发布。*

- [C-Lightning 0.9.0rc3][C-Lightning 0.9.0] 是即将到来的一个主要版本的候选发布。它增加了对更新的 `pay` 命令和新的 `keysend` RPC 的支持，这些内容在[上周的 Newsletter][news107 notable] *值得注意的代码更改*部分中有所描述。还包括其他多个值得注意的更改和多个错误修复。

- [Bitcoin Core 0.20.1rc1][Bitcoin Core 0.20.1] 是即将到来的维护版本的候选发布。除了错误修复和由这些修复引起的一些 RPC 行为更改外，计划中的发布还提供了与 [HWI][topic HWI] 最新版本的兼容性，并支持为[多付费用攻击][fee overpayment attack]发布的硬件钱包固件。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的更改。*

- [Bitcoin Core #18044][] 添加了对见证 txid (wtxid) 交易库存公告 (`inv`) 和请求 (`getdata`) 的支持，如 BIP339 中所述（见 [Newsletter #104][news104 bip339]）。在此合并之前，所有比特币节点通过交易的 txid 向其对等节点公告新的未确认交易。然而，txid 并不承诺 segwit 交易中的见证数据，因此下载了无效或不需要的 segwit 交易的节点无法安全地假设任何具有相同 txid 的交易也是无效或不需要的。这意味着节点可能会浪费带宽，从每个公告该交易的对等节点重复下载相同的错误交易。

  到目前为止，这还没有成为问题——诚实的对等节点通常不会公告他们自己不接受的交易，所以只有想要浪费其上传带宽的破坏性对等节点才会宣传无效或不需要的交易。然而，如今的一种不需要的交易是 v1 segwit UTXO 的支出——BIP341 [taproot][topic taproot] 规范计划使用的支出类型。如果 taproot 激活，这意味着较新的支持 taproot 的节点将向较旧的未支持 taproot 的节点公告 taproot 支出。每次这些未支持 taproot 的节点收到一个 taproot 支出交易时，它都会下载该交易，发现它使用了 v1 segwit，然后将其丢弃。这可能会非常浪费网络带宽，对较旧的未支持 taproot 的节点和较新的支持 taproot 的节点都是如此。这同样适用于其他提议的网络中继策略更改。

  在此合并的 PR 中实现的解决方案是通过 wtxid 来公告交易——这包括对 segwit 交易的见证数据的承诺。Bitcoin Core 中的 taproot 实现（见 [PR #17977][Bitcoin Core #17977]）然后只能通过 wtxid 来中继交易，以防止较新的节点意外向较旧的节点发送垃圾信息。

  然而，在此 PR 合并到 Bitcoin Core 的主开发分支后，在每周的 Bitcoin Core 开发会议期间，关于 taproot 对 wtxid 中继的软依赖是否会使得 taproot 回移到当前的 Bitcoin Core 0.20.x 分支变得更复杂的问题进行了[讨论][meeting xscript]。在会议期间和随后的讨论中提到了四个选项：

  1. **回移 wtxid：**如果有 0.20.x taproot 版本，wtxid 中继和 taproot 都将回移。John Newbery 已经创建了一个 [wtxid 中继回移][wtxid relay backport]。

  2. **不回移 wtxid：**只回移 taproot，并接受交易公告将比平常使用更多带宽，直到所有人都升级到使用 wtxid 的节点。

  3. **不中继 taproot：**只回移 taproot，但不启用回移节点上 taproot 交易的中继。这防止了立即的带宽浪费，但可能会使得 taproot 支出交易更难到达矿工，并且会降低 [BIP152][] 致密区块的速度和效率。较差的致密区块性能可能会暂时增加矿工创建的孤块数量（尤其是因为[公共 FIBRE 网络][public FIBRE network]最近已关闭）。

  4. **不回移任何内容：**不回移 wtxid 中继或 taproot——让 taproot 等待 Bitcoin Core 0.21 发布后的某个时间，预计在 2020 年 12 月发布。

  尚未就选择哪一个选项达成明确结论。

- [Bitcoin Core #19473][] 添加了 `networkactive` 作为命令行启动和配置文件选项。设置此选项可以启用或禁用所有 P2P 网络活动。节点启动后，可以使用现有的 `setnetworkactive` RPC 或 GUI 中的网络活动按钮来切换网络活动。

- [Eclair #1485][] 添加了对使用与 LND（见 [Newsletter #30][news30 spont]）和 C-Lightning（见 Newsletter [#94][news94 keysend plugin] 和 [#107][news107 keysend rpc]）中先前实现的相同 keysend 协议的[自发支付][topic spontaneous payments]的支持。该合并的 PR 支持接收自发支付（标记为捐赠）和使用新的 `sendWithPreimage` 方法发送支付。

- [Eclair #1484][] 添加了对[锚定输出][topic anchor outputs]承诺交易更改的低级支持。尚未添加的是更高级别的支持，使得 Eclair 能够与对等节点协商使用锚定输出，但这个早期步骤通过了所有[建议的测试向量][BOLTs #688 eclair tests]。

- [LND #4455][] 启用了基于 PSBT 的安全批量通道开启。之前，批次中的每次成功通道协商都会过早地广播包含所有通道资金输出的整个交易。这意味着后续的通道协商失败可能导致资金卡住。这个合并的 PR 引入了 `openchannel` 命令的 `--no_publish` 标志，该标志可用于延迟交易广播，直到批次中的最后一个通道。

{% include references.md %}
{% include linkers/issues.md issues="19473,18044,17977,18947,1485,1484,4455" %}
[C-Lightning 0.9.0]: https://github.com/ElementsProject/lightning/releases/tag/v0.9.0rc3
[Bitcoin Core 0.20.1]: https://bitcoincore.org/bin/bitcoin-core-0.20.1/
[fee overpayment attack]: /zh/newsletters/2020/06/10/#fee-overpayment-attack-on-multi-input-segwit-transactions
[osuntokun upgrade]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-July/002763.html
[teinturier simple]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-July/002764.html
[zmnscpxj re-funding]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-July/002765.html
[news104 bip339]: /zh/newsletters/2020/07/01/#bips-933
[news30 spont]: /zh/newsletters/2019/01/22/#pr-opened-for-spontaneous-ln-payments
[news94 keysend plugin]: /zh/newsletters/2020/04/22/#c-lightning-3611
[news107 keysend rpc]: /zh/newsletters/2020/07/22/#c-lightning-3792
[meeting xscript]: http://www.erisian.com.au/meetbot/bitcoin-core-dev/2020/bitcoin-core-dev.2020-07-23-19.00.log.html#l-63
[news107 notable]: /zh/newsletters/2020/07/22/#值得注意的代码和文档更改
[bolts #688 eclair tests]: https://github.com/lightningnetwork/lightning-rfc/pull/688#issuecomment-656737250
[public fibre network]: http://bitcoinfibre.org/public-network.html
[wtxid relay backport]: https://github.com/bitcoin/bitcoin/pull/19606
[stack exchange miner signaling]: https://bitcoin.stackexchange.com/questions/97041/how-does-a-miner-put-his-vote-for-certain-bip/97047#97047
[news96 simplicity]: /zh/newsletters/2020/05/06/#simplicity-next-generation-smart-contracting
[hwi]: https://github.com/bitcoin-core/HWI
