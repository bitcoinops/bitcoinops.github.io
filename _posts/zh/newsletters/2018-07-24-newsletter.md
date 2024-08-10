---
title: 'Bitcoin Optech Newsletter #5'
permalink: /zh/newsletters/2018/07/24/
name: 2018-07-24-newsletter-zh
slug: 2018-07-24-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
version: 1
---

本周的新闻简报包括关于描述输出脚本的新语言的信息、Bitcoin Core 对部分签名比特币交易支持的更新以及其他几项值得注意的 Bitcoin Core 合并的新闻。

## 行动项

- **<!--bitcoin-core-0-16-2rc2-->**[Bitcoin Core 0.16.2RC2][] 发布测试，为即将发布的维护版本做准备，该版本将提供错误修复和后端移植。非常感谢社区测试。注意，由于在发布过程中检测到元数据问题，因此没有 RC1。

## 仪表盘项

- 交易费用比上周这个时候低。任何能够等待 12 个或更多区块确认的人都可以合理支付默认的最低费率。这是[合并 UTXO][consolidate UTXOs]的好时机。

- **<!--native-segwit-outputs-->**[原生隔离见证输出][p2shinfo bech32]的数量一直在稳步增加，但本周下降了大约 400,000（80%），可能是由于某个交易所的 UTXO 合并。每小时创建的新本地隔离见证输出的平均数量保持相对恒定，表明采用率没有明显下降。

## 新闻

- **<!--bitcoin-optech-publicly-announced-->****Bitcoin Optech 公开宣布：** 我们在 [Bitcoin Magazine][announce bmag]、[Coindesk][announce cdesk] 和其他几个出版物中获得了很好的报道。没有我们的创始赞助商和会员公司的支持，这是不可能实现的。谢谢你们！

- **<!--first-optech-workshop-held-in-san-francisco-->****在旧金山举行的首次 Optech 工作坊：** 正如[之前宣布][workshop announce]，我们上周在旧金山举行了我们的第一次工作坊。有 14 名来自湾区公司和开源项目的工程师参加，我们就币选择（coin selection）、RBF（replace-by-fee）和 CPFP（child-pays-for-parent）进行了很好的讨论。感谢 Square 提供场地，Coinbase 协助组织。

  如果你在会员公司工作，并对未来的 Optech 活动（地点、场地、日期、格式、主题或其他任何内容）有任何要求或建议，请联系我们。我们在这里帮助我们的会员公司！

- **<!--coin-selection-rpc-unlikely-->****不太可能有币选择 RPC：** 在 Bitcoin Core 的 [每周会议][bcc meeting 7/19]中，Andrew Chow 提出创建一个 RPC 的可能性，该 RPC 会允许用户传入他们想要创建的交易的信息，包括可用输入的列表，并返回哪些输入将被 Bitcoin Core 钱包的币选择算法选择的列表。

    会议参与者大多反对提供此功能，建议最好是作为一个库，而且 Bitcoin Core 最近以及持续进行的封装其币选择代码的工作将简化以后第三方库的开发。特别反对的一个理由是，它可能会减缓 Bitcoin Core 钱包直接用户的开发速度；正如 Gregory Maxwell 所说，“对币选择保持稳定接口的压力对项目是有害的。[...] 我不想听到‘我们不能实现隐私特性 X，因为它会破坏币选择接口’。”

- **<!--first-use-of-output-script-descriptors-->****首次使用输出脚本描述符：** Pieter Wuille 已经向 Bitcoin Core 提交了 PR [#13697][Bitcoin Core #13697]，实现了他的[输出脚本描述符][output script
  descriptors]（Output Script Descriptors）语言，用于描述钱包应该监控哪些输出脚本（scriptPubKeys）。这个特定的 PR 仅适用于最近添加的 [`scantxoutset`][Bitcoin Core #12196] RPC，但 Wuille 的最终目标是在 API 中的其他地方使用这种新语言，并“消除完全导入脚本和密钥的需要，而是使钱包仅仅是这些描述符及相关元数据的列表”。

- **<!--bip174-partially-signed-bitcoin-transaction-psbt-support-mergedd-->****合并 BIP174 部分签名比特币交易（PSBT）支持：**提供标准化格式，多个钱包可以用来传递需要签名的交易信息，以便热钱包可以从冷钱包或硬件钱包获取签名，多签名交易可以由多个钱包签名，并且多个钱包可以协作创建多方交易，如 CoinJoins。此合并增加了几个 RPC：`walletprocesspsbt`、`walletcreatefundedpsbt`、`decodepsbt`、`combinepsbt`、`finalizepsbt`、`createpsbt` 和 `convertpsbt`。完整描述请见 PR [#13557][Bitcoin Core #13557]。

## 值得注意的 Bitcoin Core 合并

*不包括之前新闻部分讨论过的内容。*


{% comment %}
git log --merges b25a4c2284babdf1e8cf0ec3b1402200dd25f33f..07ce278455757fb46dab95fb9b97a3f6b1b84faf
{% endcomment %}

- **<!--bitcoin-core-9662-->**[Bitcoin Core #9662][]：现在可以创建禁用私钥的新钱包。这主要是为了那些想要专门结合其他程序或储存私钥的硬件钱包使用的用户。这对于想要使用 Bitcoin Core 功能（如币选择）的公司也很有用，他们可以创建钱包，导入他们的地址（但不是私钥），然后执行他们想要的任何操作，例如使用 [`fundrawtransaction`][rpc fundrawtransaction] RPC。

- **<!--bitcoin-core-12196-->**[Bitcoin Core #12196][]：新的 `scantxoutset` RPC 方法允许搜索匹配地址、公钥、私钥或 HD 密钥路径的可支配比特币（UTXOs）。这个功能的主要预期用途是“资金清扫”，其中找到匹配旧钱包的交易并将其转移到新钱包中。尽管这个RPC几乎肯定会包含在 Bitcoin Core 0.17 中，但它很可能会被标记为实验性，以便在后续版本中自由更改其 API。这个 API 可能会更新以支持输出脚本描述符，计划在 0.17 之前实现。

- **<!--bitcoin-core-13604-->**[Bitcoin Core #13604][]：在 32 位 ARM 系统上，默认情况下现在除了 bitcoind 之外还会构建 Bitcoin-Qt，并且应该与该系统的其他二进制文件一起默认分发到未来的发行版中。对于 64 位 ARM 系统，默认不支持 Bitcoin-Qt。

- **<!--bitcoin-core-13298-->**[Bitcoin Core #13298][]：节点现在在随机延迟之后同时向所有传入的对等方发送所有新交易的公告（[invs][inv]）。以前，中本聪在比特币（软件）中[添加一个特性][rand delay]，对每个对等方等待一个不同的随机延迟之后再发送公告，以便交易在网络中的传播有些不可预测，防止间谍节点能够假设他们从中收到交易的第一个对等方很可能是创建该交易的对等方。

    然而，后来的调查者意识到，通过对每个节点进行多次连接的方式操作多个间谍节点的人，可以增加他们首次接收给定交易的机会，使间谍再次猜测哪个节点创建了交易。这次合并通过防止进行多次连接的间谍接收到比只有一个连接的间谍更多的信息来改善情况。由节点本身使用某些规则选择的外部连接继续使用旧的行为，以便交易继续不可预测地传播。

    这一更改可能会略微增加交易传播延迟，尽管对 PR 进行评论的开发者认为影响将是最小的。它也可能导致带宽使用不再随时间均匀分布。然而，从理论上讲，如果间谍节点不再发现进行多次连接是有用的，这可能最终减少升级节点的传入连接数量，减少整体浪费的带宽。

- **<!--bitcoin-core-13652-->**[Bitcoin Core #13652][]：[`abandontransaction`][rpc abandontransaction] RPC 已被修复以放弃所有后代交易，而不仅是子交易。

## 即将到来的亮点

下周的新闻简报将特别报道来自 Xapo 的开发人员 Anthony Towns 的实地报告，讲述他们如何整合大约 400 万个 UTXO 以预备潜在的未来费用增加。

我们非常欢迎会员公司对新闻简报的贡献。如果您想分享在实现更好的比特币技术方面的经验，请与我们联系！

[bcc meeting 7/19]: https://bitcoincore.org/en/meetings/2018/07/19/
[rand delay]: https://github.com/bitcoin/bitcoin/commit/22f721dbf23cf5ce9e3ded9bcfb65a3894cc0f8c#diff-118fcbaaba162ba17933c7893247df3aR718
[p2shinfo bech32]: https://p2sh.info/dashboard/db/bech32-statistics?orgId=1
[consolidate utxos]: https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#Consolidation
[Bitcoin Core 0.16.2rc2]: https://bitcoincore.org/bin/bitcoin-core-0.16.2/test.rc2/
[announce bmag]: https://bitcoinmagazine.com/articles/chaincode-devs-google-alumni-create-industry-group-help-bitcoin-scale/
[announce cdesk]: https://www.coindesk.com/bitcoins-biggest-startups-are-backing-a-new-effort-to-keep-fees-low/
[inv]: https://bitcoin.org/en/developer-reference#inv
[workshop announce]: /en/newsletters/2018/06/26/#first-optech-workshop
[output script descriptors]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md

{% include references.md %}
{% include linkers/issues.md issues="13697,13557,12196,9662,12196,13604,13298,13652" %}
