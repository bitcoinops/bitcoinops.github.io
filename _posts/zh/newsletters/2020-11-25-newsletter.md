---
title: 'Bitcoin Optech Newsletter #125'
permalink: /zh/newsletters/2020/11/25/
name: 2020-11-25-newsletter-zh
slug: 2020-11-25-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 链接了一个跟踪矿工对 taproot 激活支持情况的网站，介绍了一个新成立的、资助比特币研究与开发的组织，并包含我们的常规栏目：Bitcoin Stack Exchange 的热门问题与回答、发布与候选发布的公告，以及热门比特币基础设施软件的值得注意的变更。

## 行动项

*本周无。*

## 新闻

- **<!--website-listing-miner-support-for-taproot-activation-->****列出矿工对 taproot 激活支持情况的网站：** 比特币矿池 [Poolin][] 创建了一个[网站][taprootactivation.com]，用于帮助跟踪矿工对激活 [taproot][topic taproot]（包括 [schnorr 签名][topic schnorr signatures] 和 [tapscript][topic tapscript]）的支持。截至本文写作时，网站上列出的所有矿池——它们合计占当前网络算力的一半以上——都表示将支持激活。如果这也代表了其余矿池的意见，那么在 taproot 的实现发布并被适量用户采用之后，完成激活应该不难。有关该网站创建的更多信息，请参阅 Bitcoin Magazine 的[文章][btcmag ta.com]。

- **<!--new-research-and-development-organization-announced-->****新的研究与开发组织成立：** [Brink][] 是一个新组织，致力于对比特币贡献者提供“资助、教育和指导”，本周在 Twitter 上[公布][brink tweet]。该组织正在招募两类申请者：一类是[奖学金项目][brink fellowship]，帮助较新的贡献者进入全职比特币开发；另一类是[资助项目][brink grant]，为已有建树的贡献者提供资金。（注：Brink 由 Optech 的贡献者创立，并获得 John Pfeffer 和 Wences Casares 的初始资助，他们也为 Optech 提供了初始资助。）

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们有点空闲时帮助好奇或困惑用户的地方。在本月栏目中，我们精选自上次更新以来得票最高的一些问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--what-is-fuzz-testing-->**[什么是模糊测试？]({{bse}}99955) Michael Folkson 概述了[模糊测试][fuzzing wikipedia]：一种向 Bitcoin Core 之类的程序输入各种畸形数据、以发现缺陷的技术。

- **<!--adding-instead-of-concatenating-hashes-in-merkle-trees-->**[在 Merkle 树中用加法代替哈希拼接]({{bse}}100098) Pieter Wuille 详细梳理了这样一个想法涉及的诸多问题：在 Merkle 树中用加法之类的运算来合并哈希，取代比特币目前使用的拼接。

- **<!--how-will-the-migration-tool-from-a-bitcoin-core-legacy-wallet-to-a-descriptor-wallet-work-->**[从 Bitcoin Core 旧版钱包迁移到输出脚本描述符钱包的工具将如何工作？]({{bse}}99624) Michael Folkson 概述了把现有旧版钱包迁移到[输出脚本描述符][topic descriptors]钱包的工具可能如何工作。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [C-Lightning 0.9.2][C-Lightning 0.9.2] 是 C-Lightning 下一个维护版本的正式发布。除了其他新功能和错误修复之外，它还包含“新的 CLI 级通知、更好的通道状态报告，以及稳定的插件挂钩调用顺序”。发布说明确实提醒：本版本生成的[部分签名比特币交易（PSBT）][topic psbt]会被某些旧版本的 Bitcoin Core（0.20.0 及更早版本）拒绝；这是为防范可能的[手续费超额支付攻击][fee overpayment attack]，而对 [PSBT 规范][news109 bips948] 和 [Bitcoin Core][news105 core19215] 所做改动带来的结果。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[比特币改进提案 (BIPs)][bips repo]和[闪电网络规范][bolts repo]中值得注意的变更。*

*注：下面提到的部分 Bitcoin Core 提交针对的是其开发分支，因此这些变更很可能要到 0.22 版本才会发布，而 0.22 大约在即将发布的 0.21 版本之后六个月推出。*

- [Bitcoin Core #20305][] 开始把 RPC 的费率单位从 BTC/kvB（每 1,000 vbyte 的 BTC）转向 sat/vB（每 vbyte 的聪）。具体做法是为 `sendtoaddress`、`sendmany`、`fundrawtransaction`、`walletcreatefundedpsbt` 这几个 RPC 以及实验性的[新][news116 send] `send` RPC 引入以 sat/vB 计价的 `fee_rate` 参数/选项。此外，`bumpfee` RPC 的 `fee_rate` 选项也从 BTC/kB 改为 sat/vB。请注意，后者属于不向后兼容的 API 变更，但影响应该相对[温和][feerate change benign]。`fundrawtransaction` 和 `walletcreatefundedpsbt` 这两个 RPC 中旧的 `feeRate` 选项仍然保留，用于以 BTC/kvB 设定费率；预计它很快会被弃用，以免造成混淆。

  该 PR 还移除了尚未发布的、通过重载 `conf_target` 和 `estimate_mode` 参数来传入显式费率的能力（参见 [Newsletter #104][news104 PR11413]），把这些 RPC 的费率错误信息单位从 BTC/kB 改为 sat/vB（其他位置则从 BTC/kB 改为 BTC/kvB），并更新了 `send` 和 `sendtoaddress` 的 RPC 示例，帮助用户创建带显式费率的交易。

- [Bitcoin Core #20145][] 添加了一个 `getcoins.py` 脚本，可用于从 [signet][topic signet] 水龙头领取测试币。

- [Bitcoin Core #20223][] 移除了 0.21.0 之后各大版本号开头的 `0`。这意味着 Bitcoin Core 的下一个版本将是 0.21.0；随后几个月内的增量版本（其中可能包括一个 [taproot][topic taproot] 版本）将是 0.21.1 至 0.21.x；再下一个大版本将是 22.0（预计 2021 年中期发布）。

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
