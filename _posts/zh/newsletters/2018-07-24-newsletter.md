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

本期 Newsletter 介绍一种用于描述输出脚本的新语言，汇报 Bitcoin Core 对部分签名比特币交易的支持进展，并带来另外几项值得注意的 Bitcoin Core 合并消息。

## 行动项

- **<!--bitcoin-core-0-16-2rc2-->**[Bitcoin Core 0.16.2RC2][] 已发布供测试，为即将推出的维护版本做准备，该版本将包含错误修复和向后移植（backport）。十分感谢社区参与测试。请注意，由于发布过程中发现元数据问题，本次没有 RC1。

## 仪表盘项

- 交易手续费比上周此时更低。只要能等待 12 个或更多区块确认，就完全可以按默认的最低费率付费。现在正是[合并 UTXO][consolidate UTXOs]的好时机。

- **<!--native-segwit-outputs-->**[原生隔离见证输出][p2shinfo bech32]的数量此前一直稳步增长，但本周下降了约 400,000 个（80%），可能是因为某家交易所做了 UTXO 合并。每小时新增原生隔离见证输出的平均数仍保持相对稳定，说明采用程度没有明显下降。

## 新闻

- **<!--bitcoin-optech-publicly-announced-->****Bitcoin Optech 公开亮相：** [Bitcoin Magazine][announce bmag]、[Coindesk][announce cdesk] 以及其他几家媒体都对我们做了很好的报道。若没有创始赞助商和会员公司的支持，这一切都不可能实现。谢谢大家！

- **<!--first-optech-workshop-held-in-san-francisco-->****首次 Optech 工作坊在旧金山举行：** 正如[此前预告][workshop announce]，我们上周在旧金山举办了第一场工作坊。来自湾区公司和开源项目的 14 名工程师到场，我们就选币（coin selection）、手续费替换（RBF）和子为父付（CPFP）展开了充分讨论。感谢 Square 提供场地，感谢 Coinbase 协助组织。

  如果你在会员公司工作，对今后的 Optech 活动（无论是地点、场地、日期、形式、主题还是其他方面）有任何要求或建议，请联系我们。我们就是为会员公司服务的！

- **<!--coin-selection-rpc-unlikely-->****选币 RPC 恐怕不会推出：** 在 Bitcoin Core 的[每周会议][bcc meeting 7/19]上，Andrew Chow 提出可以新增一个 RPC：用户传入自己想创建的交易的相关信息（包括可用输入列表），由该 RPC 返回 Bitcoin Core 钱包的选币算法会选中哪些输入。

    与会者大多反对提供这一功能，认为做成库更合适，并指出 Bitcoin Core 近期持续进行的选币代码封装工作，会让日后开发第三方库更容易。其中一个具体的反对理由是，这可能会拖慢 Bitcoin Core 钱包直接用户的开发节奏；正如 Gregory Maxwell 所说，“为选币维持稳定接口的压力会对项目有害。…… 我不想听到有人说‘我们不能实现隐私特性 X，因为它会破坏选币的接口’。”

- **<!--first-use-of-output-script-descriptors-->****首次使用输出脚本描述符：** Pieter Wuille 已向 Bitcoin Core 提交 PR [#13697][Bitcoin Core #13697]，实现了他的[输出脚本描述符][output script
  descriptors]（Output Script Descriptors）语言，用于描述钱包应当监控哪些输出脚本（scriptPubKeys）。这个 PR 目前只用于最近新增的 [`scantxoutset`][Bitcoin Core #12196] RPC，但 Wuille 的最终目标是在 API 的其他地方也用上这门新语言，并“彻底消除导入脚本和密钥的必要，让钱包就只是这些描述符再加上相关元数据的列表”。

- **<!--bip174-partially-signed-bitcoin-transaction-psbt-support-mergedd-->****合并 BIP174 部分签名比特币交易（PSBT）支持：** 此次合并提供了标准化的格式，供多个钱包传递待签名交易的信息，从而使热钱包能从冷钱包或硬件钱包取得签名、多重签名交易可由多个钱包共同签名，多个钱包也能协作构造多方交易，例如 coinjoin。本次合并新增了几个 RPC：`walletprocesspsbt`、`walletcreatefundedpsbt`、`decodepsbt`、`combinepsbt`、`finalizepsbt`、`createpsbt` 和 `convertpsbt`。完整说明见 PR [#13557][Bitcoin Core #13557]。

## 值得注意的 Bitcoin Core 合并

*不包括之前新闻部分讨论过的内容。*


{% comment %}
git log --merges b25a4c2284babdf1e8cf0ec3b1402200dd25f33f..07ce278455757fb46dab95fb9b97a3f6b1b84faf
{% endcomment %}

- **<!--bitcoin-core-9662-->**[Bitcoin Core #9662][]：现在可以创建禁用私钥的新钱包。这主要面向那些只想把自己的钱包与另一个保管私钥的程序或硬件钱包配合使用的用户。对希望使用 Bitcoin Core 功能（例如选币）的公司同样有用：先创建一个钱包，导入自己的地址（但不导入私钥），再执行任何想要的操作，例如调用 [`fundrawtransaction`][rpc fundrawtransaction] RPC。

- **<!--bitcoin-core-12196-->**[Bitcoin Core #12196][]：新增 `scantxoutset` RPC 方法，可在可花费的比特币集合（UTXO）中搜索与某个地址、公钥、私钥或 HD 密钥路径匹配的条目。其主要预期用途是“资金归集”，即找出与旧钱包匹配的交易，并把资金转移到新钱包。尽管这个 RPC 几乎肯定会进入 Bitcoin Core 0.17，但它很可能会被标记为实验性功能，以便后续版本自由调整其 API。该 API 预计还会更新以支持输出脚本描述符，这项工作计划在 0.17 之前完成。

- **<!--bitcoin-core-13604-->**[Bitcoin Core #13604][]：在 32 位 ARM 系统上，现在除了 bitcoind 之外还会默认构建 Bitcoin-Qt，而且今后发布版本时，应当会由 BitcoinCore.org 随该系统的其他二进制文件一起默认分发。64 位 ARM 上的 Bitcoin-Qt 目前仍默认不受支持。

- **<!--bitcoin-core-13298-->**[Bitcoin Core #13298][]：节点现在会在随机延迟之后，同时向所有入站对等节点发送新交易的公告（[invs][inv]）。此前，中本聪在比特币软件中[加入了这样一项机制][rand delay]：对每个对等节点分别等待一段不同的随机延迟再发送公告，让交易在网络中的传播带有一定不可预测性，使间谍节点无法认定自己最先收到某笔交易的那个对等节点很可能就是该交易的创建者。

    然而后来的调查者发现，运行多个间谍节点的人可以对每个节点建立多条连接，从而提高自己最先收到某笔交易的概率，让间谍又能猜出是哪个节点创建了这笔交易。本次合并的改进在于：建立多条连接的间谍，所能获得的信息不会比只有一条连接的间谍更多。出站连接（由节点自身按既定规则选择）仍沿用旧行为，以保证交易传播依然不可预测。

    这一改动可能略微增加交易传播延迟，不过在 PR 下评论的开发者认为影响很小。它也可能让带宽使用不再随时间均匀分布。但从理论上讲，如果间谍节点觉得建立多条连接不再有用，升级后节点的入站连接数反而可能减少，从而减少整体浪费的带宽。

- **<!--bitcoin-core-13652-->**[Bitcoin Core #13652][]：[`abandontransaction`][rpc abandontransaction] RPC 已修复，现在会放弃全部后代交易，而不只是直接子交易。

## 下期预告

下期 Newsletter 将刊登 Xapo 开发者 Anthony Towns 的实地报告，讲述他们如何合并约 400 万个 UTXO，为未来可能的手续费上涨做准备。

我们非常欢迎会员公司为本刊投稿。如果你想分享自己在采用更好的比特币技术方面的经验，请联系我们！

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
