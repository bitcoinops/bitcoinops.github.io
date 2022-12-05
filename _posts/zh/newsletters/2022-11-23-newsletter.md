---
title: 'Bitcoin Optech Newsletter #227'
permalink: /zh/newsletters/2022/11/23/
name: 2022-11-23-newsletter-zh
slug: 2022-11-23-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报包含了我们的常规栏目：来自 Bitcoin Stack Exchange 网站的精选问答、软件的新版本和候选版本介绍，还有热门比特币基础设施项目的重大变更总结。

## 新闻

本周的 Bitcoin-Dev 和 Lightning-Dev 邮件组中没有重大新闻。

## 来自 Bitcoin Stack Exchange 的精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 的贡献者们有疑问时寻找答案的首选之地，也是我们有闲暇时会帮助好奇和困惑的用户的地方。在这个月度栏目中，我们会列出自上次出刊以来的高票问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--did-the-p2sh-bip0016-make-some-bitcoin-unspendable-->BIP-0016 是否让某些 P2SH 变得无法花费？]({{bse}}115803) 用户 bca-0353f40e 列出了 6 个带有 P2SH 脚本格式 `OP_HASH160 OP_DATA_20 [hash_value] OP_EQUAL` 但早于 [BIP16][] 的激活就存在的输出。其中一个已经在激活前的旧规则下花费掉，而且 P2SH 的激活代码还专门为那一个区块[设置了一条例外规则][p2sh activation exception]。除了这个例外，激活的范围覆盖到了创世区块，所以剩余的 UTXO 将需要满足 BIP16 的规则才能花费。

- [<!--what-software-was-used-to-make-p2pk-transactions-->什么软件曾经使用过 P2PK 交易？]({{bse}}115962) Pieter Wuille 指出，P2PK 输出曾被最早的比特币软件用在 coinbase 交易中，以及用在 “[给 IP 地址支付][wiki p2ip]” 中。

- [<!--why-are-both-txid-and-wtxid-sent-to-peers-->为什么 txid 和 wtxid 都要发送给对等节点？]({{bse}}115907) Pieter Wuille 引用 [BIP339][] 并解释道，虽然 wtxid 更适合转发（因为其它某些原因的熔融性），一些对等节点不支持相对较新 wtxid 标识符，而（因为向后兼容性）txid 受到更老的 BIP339 激活之前的软件的支持。

- [<!--how-do-i-create-a-taproot-multisig-address-->如何创建一个 taproot 多签名地址？]({{bse}}115700) Pieter Wuille 指出，Bitcoin Core 现有的 [multisig][topic multisignature] RPC（比如 `createmultisig` 和 `addmultisigaddress`） 将仅支持传统钱包；从 Bitcoin Core 24.0 开始，用户将能使用[描述符][topic descriptors]和 RPC（比如 `deriveaddresses` 和 `importdescriptors` ）以及新的  `multi_a` 描述符来创建兼容 [taproot][topic taproot] 的多签名脚本。

- [<!--is-it-possible-to-skip-initial-block-download-ibd-on-pruned-node-->在剪枝节点上可以跳过初次区块下载流程吗？]({{bse}}116030) Pieter Wuille 指出，虽然当前的 Bitcoin Core 还不支持，但 [assumeutxo][topic assumeutxo] 项目将允许使用一种新的冷启动模式，节点可以下载 UTXO 集并使用一个硬编码的哈希值来验证它们。

## 新版本和候选版本

*热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [LND 0.15.5-beta.rc2][] 是 LND 的一个维护版本的候选版本。根据其发行计划书，仅包含少量 bug 修复。

- [Core Lightning 22.11rc2][] 是 CLN 的下一个大版本的候选版本。也是使用新版本号方案的第一个版本，不过 CLN 版本会继续使用[带有语义的版本号][semantic versioning]。

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo] 和 [Bitcoin Core #25730][]。*

- [Bitcoin Core #25730][] 更新了 `listunspent` RPC，使用一个参数可在结果中显示所有尚未成熟的 coinbase 输出 —— 即被包括在某个区块的 coinbase 交易中，但还未经过 100 个区块的输出。

- [LND #7082][] 更新了没有包括请求数量的发票的创建方法，已允许包含路由提醒；这样的路由提醒可帮助发送者找到通往接收者的路径。

- [LDK #1413][] 移除了最初的定长洋葱数据格式的支持。升级后的变长格式已经在三年多以前添加到了规范中，并且对旧版本的支持已经从规范（见[周报 #220][news220 bolts962]）、Core Lightning（[周报 #193][news193 cln5058]）、LND（[周报 #196][news196 lnd6385]）和 Eclair（[周报 #217][news217 eclair2190]）中移除。

- [HWI #637][] 为 Ledger 设备的比特币相关固件的一个重大计划升级添加了支持。未包含在本次 PR 中，但在 PR 描述中提到作为未来工作的，是策略管理工作，见[周报 #200][news200 policy]。

{% include references.md %}
{% include linkers/issues.md v=2 issues="25730,7082,1413,637" %}
[bitcoin core 24.0]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[bcc 24.0 rn]: https://github.com/bitcoin/bitcoin/blob/0ee1cfe94a1b735edc2581a05c4b12f8340ff609/doc/release-notes.md
[news222 rbf]: /zh/newsletters/2022/10/19/#transaction-replacement-option
[news223 rbf]: /zh/newsletters/2022/10/26/#continued-discussion-about-full-rbf-rbf
[news224 rbf]: /zh/newsletters/2022/11/02/#mempool-consistency
[lnd 0.15.5-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.5-beta.rc2
[core lightning 22.11rc2]: https://github.com/ElementsProject/lightning/releases/tag/v22.11rc2
[news220 bolts962]: /zh/newsletters/2022/10/05/#bolts-962
[news217 eclair2190]: /zh/newsletters/2022/09/14/#eclair-2190
[news193 cln5058]: /en/newsletters/2022/03/30/#c-lightning-5058
[news196 lnd6385]: /en/newsletters/2022/04/20/#lnd-6385
[news200 policy]: /en/newsletters/2022/05/18/#adapting-miniscript-and-output-script-descriptors-for-hardware-signing-devices
[semantic versioning]: https://semver.org/spec/v2.0.0.html
[wiki p2ip]: https://en.bitcoin.it/wiki/IP_transaction
[p2sh activation exception]: https://github.com/bitcoin/bitcoin/commit/ce650182f4d9847423202789856e6e5f499151f8
