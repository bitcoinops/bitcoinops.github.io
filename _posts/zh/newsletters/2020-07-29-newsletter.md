---
title: 'Bitcoin Optech Newsletter #108'
permalink: /zh/newsletters/2020/07/29/
name: 2020-07-29-newsletter-zh
slug: 2020-07-29-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 介绍了一项提案：不新开通道也能升级 LN 通道承诺交易的格式；此外还收录了 River Financial 关于用 PSBT 与描述符构建钱包软件的一线实践报告。我们还照例收录了 Bitcoin Stack Exchange 精选问答、最近的发布与候选发布，以及热门比特币基础设施项目的值得注意的变更。

## 行动项

*本周无。*

## 新闻

- **<!--upgrading-channel-commitment-formats-->****升级通道承诺格式：** Olaoluwa Osuntokun 本周在 Lightning-Dev 邮件列表上[发帖][osuntokun upgrade]，建议对 LN 规范做一项扩展：让已有通道的两个对等节点可以协商改用另一种格式的新承诺交易。承诺交易用于让 LN 节点把当前通道状态发布到链上，但现有协议只允许节点通过新开通道来升级到新的承诺格式。Osuntokun 的提案让节点可以向对等节点示意自己想切换格式。若对等节点同意，两个节点就把现有通道状态迁移到新格式，此后一直使用新格式。

  所有讨论的参与者似乎都支持这一基本想法。Bastien Teinturier [建议][teinturier simple]，最简单的方式是仅允许在通道没有待处理支付（HTLC）的情况下切换承诺格式——这意味着节点需要暂停在特定通道内发送或中继支付以进行升级。

  ZmnSCPxj [指出][zmnscpxj re-funding]，同样的基本思路大体上可以用于在链下更新注资交易，例如在 [taproot][topic taproot] 和 [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] 落地之后，就可以使用基于 [eltoo][topic eltoo] 的通道承诺。在 ZmnSCPxj 的设想中，现有注资交易的输出会付给一笔新的注资交易，而后者保持在链下。如果通道以双方共同关闭告终，原注资交易的输出就付给最终的通道余额；否则，链下的次级注资交易可以发布到链上，并按相应的单边关闭协议了结通道。

## 实地报告：在 River 使用描述符与 PSBT

{% include articles/zh/river-descriptors-psbt.md %}

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们有点空闲时帮助好奇或困惑用户的地方。在本月栏目中，我们精选自上次更新以来得票最高的一些问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--what-are-leaf-versions-in-taproot-->**[Taproot 中的“叶版本”是什么？]({{bse}}97104)
  Michael Folkson 和 Pieter Wuille 解释说，taproot 树的每个叶节点都承诺一个叶版本和一个脚本。这个叶版本可用于升级，并指定只适用于该叶节点的脚本语义。

- **<!--what-are-the-different-upgradability-features-in-the-bip-taproot-bip341-proposal-->**[BIP-Taproot (BIP341) 提案中有哪些不同的可升级特性？]({{bse}}96951)
  Michael Folkson 回答了 Twitter 上的一个问题，说明 taproot 可以通过哪些不同方式实现可升级，包括用于脚本语义的叶版本、为将来功能重新利用操作码、公钥类型，以及用来放入新字段的 annex。

- **<!--is-there-an-active-list-of-bips-currently-open-->**[是否有一个当前开放的 BIP 列表？]({{bse}}97043)
  Pieter Wuille 描述了以往用来激活软分叉的各种方法，并指出 Bitcoin Core 目前虽没有未激活的软分叉，但确实在讨论 taproot 的激活方式。Pieter 还回答了一个关于矿工信号支持的[类似问题][stack exchange miner signaling]。

- **<!--could-we-skip-the-taproot-soft-fork-and-instead-use-simplicity-to-write-the-equivalent-of-taproot-scripts-->**[我们能否跳过 Taproot 软分叉，改用 Simplicity 编写等效的 taproot 脚本？]({{bse}}97049)
  Michael Folkson 引用 Pieter Wuille 的话，概述了 [Simplicity][news96 simplicity] 的现状，并指出把 Simplicity 作为一种叶版本集成进 taproot 会更可取。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [C-Lightning 0.9.0rc3][C-Lightning 0.9.0] 是一个即将到来的大版本的候选发布。它新增了对[上周 Newsletter][news107 notable] 的*值得注意的代码变更*部分所述更新版 `pay` 命令和新 `keysend` RPC 的支持。此外还包含若干其他值得注意的变更和多项错误修复。

- [Bitcoin Core 0.20.1rc1][Bitcoin Core 0.20.1] 是一个即将到来的维护版本的候选发布。除了错误修复以及这些修复带来的一些 RPC 行为变化之外，计划发布的版本还兼容较新版本的 [HWI][topic HWI]，并能用上 HWI 对为应对[手续费超额支付攻击][fee overpayment attack] 而发布的硬件钱包固件的支持。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi]、[比特币改进提案（BIPs）][bips repo]和[闪电网络 BOLT 规范][bolts repo]中的值得注意的变更。*

- [Bitcoin Core #18044][] 增加了对以见证 txid（wtxid）进行交易清单公告（`inv`）和交易请求（`getdata`）的支持，如 BIP339 所述（见 [Newsletter #104][news104 bip339]）。在这次合并之前，所有比特币节点都用交易的 txid 向对等节点公告新的未确认交易。但 txid 并不承诺 segwit 交易的见证数据，因此一个下载到无效或不受欢迎的 segwit 交易的节点，无法安全地认定具有同一 txid 的交易也是无效或不受欢迎的。这意味着节点可能白费带宽，从每个公告该交易的对等节点反复下载同一笔坏交易。

  到目前为止这还不成问题——诚实的对等节点通常不会公告自己也不会接受的交易，所以要宣传无效或不受欢迎的交易，只有那种想浪费自己上传带宽的捣乱节点。不过，如今有一类不受欢迎的交易，就是花费 v1 segwit UTXO 的交易——也就是 [BIP341][] 中 [taproot][topic taproot] 规范打算使用的那类花费。如果 taproot 激活，就意味着较新的、懂 taproot 的节点会向较旧的、不懂 taproot 的节点公告 taproot 花费。每当这类不懂 taproot 的节点收到一笔 taproot 花费交易，它都会下载下来，发现其使用 v1 segwit，然后把它丢掉。这对新旧两类节点来说都可能严重浪费网络带宽。同样的问题也适用于其他拟议的网络中继策略变更。

  这个已合并 PR 采用的方案是按 wtxid 公告交易——wtxid 包含了对 segwit 交易见证数据的承诺。这样，Bitcoin Core 中的 taproot 实现（见 [PR #17977][Bitcoin Core #17977]）就可以只按 wtxid 中继交易，避免新节点无意间给旧节点制造流量负担。

  不过，这个 PR 合并进 Bitcoin Core 主开发分支后，每周的 Bitcoin Core 开发会议曾[讨论][meeting xscript]：taproot 对 wtxid 中继的这种软依赖，是否会让 taproot 向后移植到 Bitcoin Core 当前 0.20.x 分支变得更麻烦。会上及后续讨论提到了四种做法：

  1. **向后移植 wtxid：**如果会有 0.20.x 的 taproot 版本，就把 wtxid 中继和 taproot 一并向后移植。John Newbery 已经做了 [wtxid 中继的向后移植][wtxid relay backport]。

  2. **不向后移植 wtxid：**只向后移植 taproot，并接受在所有人都升级到使用 wtxid 的节点之前，交易公告会比平常多耗带宽。

  3. {:#dont-relay-taproot} **不中继 taproot：**只向后移植 taproot，但不在向后移植的节点上启用 taproot 交易的中继。这避免了眼前的带宽浪费，但可能让 taproot 花费交易更难到达矿工，也会降低 [BIP152][] 紧凑区块的速度和效率。紧凑区块性能变差，可能暂时增加矿工产生的孤块数量（尤其因为[公共 FIBRE 网络][public FIBRE network] 最近已关停）。

  4. **什么都不向后移植：**wtxid 中继和 taproot 都不向后移植——等 Bitcoin Core 0.21 发布之后再说，0.21 大致[预计][Bitcoin Core #18947] 在 2020 年 12 月发布。

  至于该选哪一种，目前尚未形成明确结论。

- [Bitcoin Core #19473][] 添加了 `networkactive` 作为命令行启动和配置文件选项。设置此选项可以启用或禁用所有 P2P 网络活动。节点启动后，可以使用现有的 `setnetworkactive` RPC 或 GUI 中的网络活动按钮来切换网络活动。

- [Eclair #1485][] 增加了对[自发支付][topic spontaneous payments] 的支持，采用与 LND（见 [Newsletter #30][news30 spont]）和 C-Lightning（见 Newsletter [#94][news94 keysend plugin] 和 [#107][news107 keysend rpc]）此前实现的相同的 keysend 协议。这个已合并的 PR 既能接收自发支付（标记为捐赠），也能用新的 `sendWithPreimage` 方法发送支付。

- [Eclair #1484][] 为[锚定输出][topic anchor outputs] 所需的承诺交易改动提供了底层支持。更高层的支持——让 Eclair 能与对等节点协商使用锚定输出——尚未加入，但这个早期步骤已通过全部[提议的测试向量][BOLTs #688 eclair tests]。

- [LND #4455][] 让基于 PSBT 的批量开启通道变得安全。此前，批次中每成功协商一个通道，就会提前广播包含全部通道资金输出的整笔交易。这意味着后续通道协商一旦失败，就可能让资金卡住。这个已合并的 PR 为 `openchannel` 命令引入了 `--no_publish` 标志，可以用它把交易广播推迟到批次中最后一个通道完成之时。

{% include references.md %}
{% include linkers/issues.md issues="19473,18044,17977,18947,1485,1484,4455" %}
[C-Lightning 0.9.0]: https://github.com/ElementsProject/lightning/releases/tag/v0.9.0rc3
[Bitcoin Core 0.20.1]: https://bitcoincore.org/bin/bitcoin-core-0.20.1/
[fee overpayment attack]: /zh/newsletters/2020/06/10/#fee-overpayment-attack-on-multi-input-segwit-transactions
[osuntokun upgrade]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-July/002763.html
[teinturier simple]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-July/002764.html
[zmnscpxj re-funding]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-July/002765.html
[news104 bip339]: /zh/newsletters/2020/07/01/#bips-933
[news30 spont]: /zh/newsletters/2019/01/22/#pr-opened-for-spontaneous-ln-payments
[news94 keysend plugin]: /zh/newsletters/2020/04/22/#c-lightning-3611
[news107 keysend rpc]: /zh/newsletters/2020/07/22/#c-lightning-3792
[meeting xscript]: http://www.erisian.com.au/meetbot/bitcoin-core-dev/2020/bitcoin-core-dev.2020-07-23-19.00.log.html#l-63
[news107 notable]: /zh/newsletters/2020/07/22/#值得注意的代码与文档变更
[bolts #688 eclair tests]: https://github.com/lightningnetwork/lightning-rfc/pull/688#issuecomment-656737250
[public fibre network]: http://bitcoinfibre.org/public-network.html
[wtxid relay backport]: https://github.com/bitcoin/bitcoin/pull/19606
[stack exchange miner signaling]: https://bitcoin.stackexchange.com/questions/97041/how-does-a-miner-put-his-vote-for-certain-bip/97047#97047
[news96 simplicity]: /zh/newsletters/2020/05/06/#simplicity-next-generation-smart-contracting
[hwi]: https://github.com/bitcoin-core/HWI
