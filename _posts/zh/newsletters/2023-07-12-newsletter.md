---
title: 'Bitcoin Optech Newsletter #259'
permalink: /zh/newsletters/2023/07/12/
name: 2023-07-12-newsletter-zh
slug: 2023-07-12-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报描述了一项提案，旨在从 LN 规范中删除已经不再适用于较新节点的详细信息，还包括我们关于交易池规则每周限定系列中的倒数第二个条目，此外还有我们的常规部分，其中包括 Bitcoin Core PR 审核俱乐部会议的总结、新版本和候选版本的公告，以及对热门比特币基础设施项目的重大变更介绍。

## 新闻

- **LN 规范整理提案：** Rusty Russell 向 Lightning-Dev 邮件列表[发布了][russell clean up]一个 [PR][bolts #1092] 链接，提议移除一些较新的 LN 实现已不再支持的功能，并假设其他功能将永远被支持。就该提议所涉及的更改，Russell 还提供了他所进行的公共节点特征的调查结果。其结果表明，几乎所有节点都支持以下功能：

  - *<!--variable-sized-onion-messages-->可变大小的洋葱消息：* 在2019年成为规范的一部分(见[周报 #58][news58 bolts619])，大约与规范更新为使用类型-长度-值（TLV）字段同时提出。这取代了加密洋葱路由的原始格式，该格式要求每一跳使用固定长度的消息，并将跳数限制为20。可变大小的格式使得向特定跳中继任意数据变得更加容易，唯一的缺点是整体消息大小需保持不变，因此发送的数据量的任何增加都会减少最大跳数。

  - *<!--gossip-queries-->Gossip 查询：* 在2018年成为规范的一部分(见 [BOLTs #392][])。这允许一个节点仅向其对等节点请求网络上其他节点发送的 Gossip 消息的子集。例如，一个节点可能只请求最近的 Gossip 更新，忽略旧的更新以节省带宽和减少处理时间。

  - *<!--data-loss-protection-->数据丢失保护：* 在2017年成为规范的一部分(见 [BOLTs #240][])。使用此功能的节点在重新连接时发送有关其最新通道状态的信息。这可能允许节点检测到它已丢失数据，并鼓励未丢失数据的节点以最新状态关闭通道。有关更多详细信息，请参见[周报 #31][news31 data loss]。

  - *<!--static-remote-party-keys-->静态远端方密钥：* 在2019年成为规范的一部分(见[周报 #67][news67 bolts642])，这使节点可以请求每个通道更新都将非 [HTLC][topic htlc] 资金发送到该节点指定的同一地址。以前，每次通道更新都会使用不同的地址。更改之后，选择加入此协议并丢失数据的节点最终将至少能在所选地址回收部分资金，例如节点的[层级式确定性钱包（HD wallet）][topic bip32]地址。

  对整理提案 PR 的初步回复都是积极的。

## 等待确认 #9：规则提案

_关于交易转发、交易池接纳和挖矿交易选择的限定[周刊][policy series]————解释了为什么 Bitcoin Core 的交易池规则比共识规则更严格，以及钱包可以如何更高效地利用这些规则。_

{% include specials/policy/zh/09-proposals.md %}

## Bitcoin Core PR 审核俱乐部

*在这个月度部分，我们总结了最近的 [Bitcoin Core PR 审核俱乐部][Bitcoin Core PR Review Club]会议，重点介绍了一些重要的问题和答案。单击下面的问题以查看会议答案的总结。*

[停止中继非交易池交易][review club 27625]是 Marco Falke（MarcoFalke）提出的 PR，它通过删除 `mapRelay` 这种内存数据结构来简化 Bitcoin Core 客户端，该数据结构可能导致高内存消耗，且不再被需要，或者说益处微不足道。此数据结构包含可能处于或者不处于交易池中的交易，有时也被用于回复对等节点的 [`getdata`][wiki getdata] 请求。
{% include functions/details-list.md
  q0="<!--what-are-the-reasons-to-remove-maprelay-->移除 `mapRelay` 有哪些原因？"
  a0="此数据结构的内存消耗是没有限制的。虽然通常它不会使用太多内存，但当任何数据结构的大小由外部实体（对等节点）的行为决定并且没有最大值限制时，这就会成为一个问题，因为这可能会导致 DoS 漏洞。"
  a0link="https://bitcoincore.reviews/27625#l-19"

  q1="<!--why-is-the-memory-usage-of-maprelay-hard-to-determine-->为什么 `mapRelay` 的内存使用情况很难确定？"
  a1=" `mapRelay` 中的每个条目都是交易(`CTransaction`)的共享指针，可能还有另一个指针在交易池中。相对于单个指针，对同一对象的第二个指针使用的额外空间非常小。如果从交易池中移除了共享交易，则其所有空间都归属于 `mapRelay` 的条目。因此，`mapRelay` 的内存使用量不仅取决于交易的数量和它们各自的大小，还取决于有多少交易不再在交易池中，这是很难预测的。"
  a1link="https://bitcoincore.reviews/27625#l-33"

  q2="<!--what-problem-is-solved-by-introducing-m-most-recent-block-txs-this-is-a-list-of-only-the-transactions-in-the-most-recently-received-block-->引入 `m_most_recent_block_txs` 解决了什么问题?(这是最近接收的区块中仅包含交易的列表。)"
  a2="没有它，由于 `mapRelay` 已不再可用，我们将无法向请求它们的对等节点提供最新区块中刚刚挖出的交易，因为我们已将这些交易从交易池中删除。"
  a2link="https://bitcoincore.reviews/27625#l-45"

  q3="<!--do-you-think-it-is-necessary-to-introduce-m-most-recent-block-txs-as-opposed-to-just-removing-maprelay-without-any-replacement-->你是否认为引入 `m_most_recent_block_txs` 是必要的，而不能仅删除 `mapRelay` 而不提供任何替代措施？"
  a3="在该问题上，审查俱乐部的参与者有不同意见。有人认为，使用 `m_most_recent_block_txs` 可以提高区块传播速度，因为如果我们的对等节点还没有接收到我们刚刚接收到的区块，我们节点提供其交易的能力可以帮助对等节点完成[致密区块][topic compact block relay]下载。另一个意见是，在出现链分叉的情况下可能会有所帮助；如果我们的对等节点所认定的链顶端与我们所认为的不同，则该交易可能不会作为区块的一部分得到传播。"
  a3link="https://bitcoincore.reviews/27625#l-54"

  q4="<!--what-are-the-memory-requirements-for-m-most-recent-block-txs-compared-to-maprelay-->`m_most_recent_block_txs` 相对于 `mapRelay` 而言，对内存的要求是多少？"
  a4="`m_most_recent_block_txs` 中的条目数受限于区块中的交易数。但是，其内存需求甚至比该交易数更少，因为 `m_most_recent_block_txs` 条目是共享指针（指向交易），它们也已经被 `m_most_recent_block` 指向。"
  a4link="https://bitcoincore.reviews/27625#l-65"

  q5="<!--are-there-scenarios-in-which-transactions-would-be-made-available-for-a-shorter-or-longer-time-than-before-as-a-result-of-this-change-->由于这次变化，交易留存在交易池中的时间是否可能比以前更短或更长？"
  a5="当距离上一块区块的时间超过15分钟时，时间更长 (这是条目保留在 `mapRelay` 中的时间)，否则更短。鉴于选择15分钟的时间相对任意，这种方式似乎是可以接受的。但是，这种更改可能会在链分叉超过一个区块深度（这种情况非常罕见）时减少交易的可用性，因为我们不再保留那些非最佳链上独有的交易。"
  a5link="https://bitcoincore.reviews/27625#l-70"
%}

## 版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [LND v0.16.4-beta][] 是这个 LN 节点软件的一个维护版本，修复了可能影响某些用户的内存泄漏问题。

## 重大的代码和文档变更

*本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo] 和
[Bitcoin Inquisition][bitcoin inquisition repo]。*

- [Bitcoin Core #27869][] 在加载传统钱包时发出弃用警告，这是继[Bitcoin Core #20160][]中所概述的持续努力，旨在帮助用户从传统钱包迁移至 [描述符][topic descriptors]钱包，正如在周报[#125][news125 descriptor wallets]、[#172][news172 descriptor wallets]和[#230][news230 descriptor wallets]中所提到的。

{% include references.md %}
{% include linkers/issues.md v=2 issues="1092,392,240,20160,27869" %}
[news58 bolts619]: /en/newsletters/2019/08/07/#bolts-619
[policy series]: /en/blog/waiting-for-confirmation/
[news31 data loss]: /en/newsletters/2019/01/29/#fn:fn-data-loss-protect
[news67 bolts642]: /en/newsletters/2019/10/09/#bolts-642
[lnd v0.16.4-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.4-beta
[russell clean up]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/004001.html
[review club 27625]: https://bitcoincore.reviews/27625
[wiki getdata]: https://en.bitcoin.it/wiki/Protocol_documentation#getdata
[news125 descriptor wallets]: /en/newsletters/2020/11/25/#how-will-the-migration-tool-from-a-bitcoin-core-legacy-wallet-to-a-descriptor-wallet-work
[news172 descriptor wallets]: /en/newsletters/2021/10/27/#bitcoin-core-23002
[news230 descriptor wallets]: /zh/newsletters/2022/12/14/#with-legacy-wallets-deprecated-will-bitcoin-core-be-able-to-sign-messages-for-an-address-bitcoin-core
