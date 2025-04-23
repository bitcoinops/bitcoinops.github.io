---
title: 'Bitcoin Optech Newsletter #125'
permalink: /zh/newsletters/2020/11/25/
name: 2020-11-25-newsletter-zh
slug: 2020-11-25-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 链接了一个用于跟踪矿工对 Taproot 激活支持的网站，宣布了一个新的资助比特币研究和开发的组织，并包括我们常规的栏目，涵盖来自 Bitcoin Stack Exchange 的热门问题和答案、版本发布和候选版本的公告，以及值得注意的流行比特币基础设施软件的更改。

## 行动项

*本周无。*

## 新闻

- **<!--website-listing-miner-support-for-taproot-activation-->****列出矿工对 Taproot 激活支持情况的网站：** 比特币矿池 [Poolin][] 创建了一个[网站][taprootactivation.com]，用于帮助跟踪矿工对激活 [Taproot][topic taproot]（包括 [Schnorr 签名][topic schnorr signatures] 和 [Tapscript][topic tapscript]）的支持。截至撰写本文时，网站列出的所有矿池——它们代表了当前网络算力的一半以上——均表示支持激活。如果这反映了其余矿池的意见，那么在 Taproot 的实现发布并被适量用户采用后，激活应该会比较容易完成。有关该网站创建的更多信息，请参阅 Bitcoin Magazine 的[文章][btcmag ta.com]。

- **<!--new-research-and-development-organization-announced-->****宣布新的研究和开发组织：** [Brink][]，一个用于“资助、教育和指导”比特币贡献者的新组织，本周在 Twitter 上[宣布][brink tweet]。该组织正在为其[奖学金项目][brink fellowship]招募申请者，以帮助新的贡献者全职从事比特币开发，以及为其[资助项目][brink grant]提供资金以支持成熟的贡献者。（注：Brink 由 Optech 的贡献者创立，并获得了 John Pfeffer 和 Wences Casares 的初始资助，他们也为 Optech 提供了初始资助。）

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选之一——或者当我们有空时，也会帮助有疑问的用户。在本月的专题中，我们重点介绍了自上次更新以来发布的一些高票问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--what-is-fuzz-testing-->**[什么是模糊测试？]({{bse}}99955) Michael Folkson 概述了[模糊测试][fuzzing wikipedia]，一种向类似 Bitcoin Core 的程序提供各种格式错误的输入以发现漏洞的技术。

- **<!--adding-instead-of-concatenating-hashes-in-merkle-trees-->**[在 Merkle 树中使用加法而不是串联哈希]({{bse}}100098) Pieter Wuille 详细分析了关于在 Merkle 树中使用加法替代目前比特币所采用的串联操作时需要考虑的各种问题。

- **<!--how-will-the-migration-tool-from-a-bitcoin-core-legacy-wallet-to-a-descriptor-wallet-work-->**[从 Bitcoin Core 传统钱包迁移到描述符钱包的工具如何工作？]({{bse}}99624) Michael Folkson 概述了将现有传统钱包迁移到[描述符][topic descriptors]钱包的工具可能如何工作。

## 发布与候选发布

*针对流行比特币基础设施项目的新版本和候选版本发布。请考虑升级到新版本或协助测试候选版本。*

- [C-Lightning 0.9.2][C-Lightning 0.9.2] 发布了 C-Lightning 的下一个维护版本。它包含“新的 CLI 级通知、更好的通道状态报告以及稳定的插件钩子调用顺序”，此外还有其他新功能和漏洞修复。发布说明提醒，本版本生成的 [PSBT][topic psbt] 会被某些旧版本的 Bitcoin Core（0.20.0 及更早版本）拒绝；这是为防范可能的 [手续费超额支付攻击][fee overpayment attack] 而对 [PSBT 规范][news109 bips948] 和 [Bitcoin Core][news105 core19215] 进行更改的结果。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[比特币改进提案 (BIPs)][bips repo]和[闪电网络规范][bolts repo]中值得注意的更改。*

*注：以下提到的 Bitcoin Core 提交中的一些更改适用于其开发分支，因此这些更改可能要等到 0.21 版本发布约六个月后才会发布到 0.22 版本中。*

- [Bitcoin Core #20305][] 开始将 RPC 费率单位从每 1,000 字节的 BTC（BTC/kvB）转换为每虚拟字节的聪（sat/vB）。该更改通过引入一个 `fee_rate` 参数/选项（以 sat/vB 为单位）应用于 `sendtoaddress`、`sendmany`、`fundrawtransaction` 和 `walletcreatefundedpsbt` RPC，以及实验性的[新][news116 send] `send` RPC。此外，`bumpfee` RPC 的 `fee_rate` 选项也从 BTC/kB 更改为 sat/vB。用户被警告，后者是一个破坏性 API 更改，但应该是相对 [温和的][feerate change benign]。RPC 中的旧版 `feeRate` 选项（适用于 `fundrawtransaction` 和 `walletcreatefundedpsbt`）仍然存在，但预计很快会被弃用以避免混淆。

  此 PR 还移除了通过重载 `conf_target` 和 `estimate_mode` 参数传递显式费率的未发布功能（参见 [Newsletter #104][news104 PR11413]），将这些 RPC 的费率错误消息单位从 BTC/kB 更新为 sat/vB（其他地方从 BTC/kB 更新为 BTC/kvB），并更新了 `send` 和 `sendtoaddress` RPC 示例以帮助用户创建具有显式费率的交易。

- [Bitcoin Core #20145][] 添加了一个 `getcoins.py` 脚本，可用于从 [signet][topic signet] 的水龙头请求测试币。

- [Bitcoin Core #20223][] 从 Bitcoin Core 的版本号中移除了主版本号前的 `0`。这意味着 Bitcoin Core 的下一个版本将是 0.21.0；后续数月内的增量版本（可能包括 [Taproot][topic taproot] 的版本）将是 0.21.1 到 0.21.x；而下一个主要版本将是 22.0（预计于 2021 年中期发布）。

{% include references.md %}
{% include linkers/issues.md issues="20305,20145,611,20426,20223" %}
[C-Lightning 0.9.2]: https://github.com/ElementsProject/lightning/releases/tag/v0.9.2
[poolin]: https://www.poolin.com/
[taprootactivation.com]: https://taprootactivation.com/
[btcmag ta.com]: https://bitcoinmagazine.com/articles/poolin-launches-initiative-to-activate-taproot-encouraging-other-mining-pools-to-join
[fee overpayment attack]: /zh/newsletters/2020/06/10/#fee-overpayment-attack-on-multi-input-segwit-transactions
[news105 core19215]: /zh/newsletters/2020/07/08/#bitcoin-core-19215
[news109 bips948]: /zh/newsletters/2020/08/05/#bips-948
[news116 send]: /zh/newsletters/2020/09/23/#bitcoin-core-16378
[feerate change benign]: https://github.com/bitcoin/bitcoin/pull/20305#discussion_r520231413
[news104 PR11413]: /zh/newsletters/2020/07/01/#bitcoin-core-11413
[brink]: https://brink.dev/
[brink tweet]: https://twitter.com/bitcoinbrink/status/1331205950032764928
[brink fellowship]: https://brink.dev/programs#fellowships
[brink grant]: https://brink.dev/programs#grants
[fuzzing wikipedia]: https://en.wikipedia.org/wiki/Fuzzing
