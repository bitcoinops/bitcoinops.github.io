---
title: 'Bitcoin Optech Newsletter #322'
permalink: /zh/newsletters/2024/09/27/
name: 2024-09-27-newsletter-zh
slug: 2024-09-27-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的新闻环节介绍了一个影响旧版本 Bitcoin Core 软件的漏洞（已经修复），还介绍了通道阻塞混合缓解措施的更新，还总结了一篇关于更高效更私密的客户端验证技术的论文，以及一项更新 BIP 流程的提议。此外是我们的常规栏目：Bitcoin Stack Exchange 上的热门问题和回答，软件的新版本和候选版本公告，比特币基础设施软件的重大更新介绍。

## 新闻

- **<!--disclosure-of-vulnerability-affecting-bitcoin-core-versions-before-2401-->****影响 24.0.1 以前版本的 Bitcoin Core 的漏洞披露**：Antoine Poinsot 在 Bitcoin-Dev 邮件组中[公开][poinsot headers]了一项影响部分 Bitcoin Core 软件版本的漏洞，这些版本的设计使用年限最迟至 2023 年 12 月。这是先前漏洞披露行动的后续（详见 [#310][news310 bcc] 和 [#314][news314 bcc]）。

  此次新披露讨论了一种人们早已知晓的可让 Bitcoin Core 全节点宕机的方法：向全节点发送一长串的区块头，而区块头会被保存在内存中。每个区块头是 80 字节，如果没有任何保护措施，这些区块头可以使用协议许可的最低工作量证明难度 —— 从而攻击者用最新的 ASIC 挖矿机器可以在一秒内制造出几百万个这样的区块头。Bitcoin Core 在许多年前就添加了保护措施，这些措施是在早期版本中添加区块链检查点的连带效果：这阻止了攻击者用最低难度创建区块头链、迫使他们执行大量工作量证明计算（如果他们将这些计算用在创建有效区块中，就可以获得挖矿奖励）。

  然而，最后一个检查点是在 10 年前添加的，而且 Bitcoin Core 开发者们一直不愿意创建新的检查点，因为这样做会给人一种错误的印象，以为比特币交易的终局性最终还是依赖于创建检查点的开发者。随着挖矿设备的进步以及全网哈希率的提升，创建虚假区块头联通的代价已经降低。因为代价降低，研究员 David Jaenson 和 Braydon Fuller 独立地向 Bitcoin Core 开发者[尽责披露][topic responsible disclosures]了这种攻击。开发者们的回复是这种攻击早已为人所知，并在 2019 年鼓励 Fuller 公开[发表][fuller dos]他的[论文][fuller paper]。

  在 2022 年，攻击的代价进一步降低，一群开发者开始开发一种不使用检查点的解决方案。Bitcoin Core PR #25717（详见[周报 #216][news216 checkpoints]）就是这些工作的结果。后来，Niklas Gögge 发现了 #25717 逻辑中的一个 bug，并开启了 [PR #26355][bitcoin core #26355] 来修复它。两项 PR 都已经被合并，Bitcoin Core 24.0.1 发布时已带上了这个修复措施。

- **<!--hybrid-jamming-mitigation-testing-and-changes-->通道阻塞混合缓解措施的测试和变更**：Carla Kirk-Cohen 在 Delving Bitcoin 论坛中[公布][kc jam]了多种击败“[通道阻塞攻击][topic channel jamming attacks]” 缓解措施实现的尝试，这些措施最初由 Clara Shikhelman 和 Sergei Tikhomirov 提出 。混合型缓解措施包括了 “[HTLC 背书][topic htlc endorsement]” 和小规模的 “预付手续费”（无条件支付，无论支付是否成功）的结合。

  多位开发者被要求尝试[堵塞一条通道达一个小时][kc attackathon]，而 Kirk-Cohen 和 Shikhelman 会扩大任何看起来有希望的攻击。绝大部分攻击者都失败了：要么攻击者花费的代价超过了另一种已知的攻击，要么被攻击的节点在此过程中收入比模拟网络中的常规路由还要高。

  成功的一种攻击叫作 “[沉船攻击][sink attack]”，“意在通过在网络中创建 更短/更便宜 的路径、并破坏经过这些通道的支付来降低沿路所有节点的声誉，进而降低目标节点的对等节点的声誉”。为解决这种攻击，Kirk-Cohen 和 Shikhelman 为 HTLC 背书考虑的因素引入了 “[双向声誉][bidirectional reputation]”。当 Bob 收到来自 Alice 的支付、要转发给 Carol 时（例如，`A -> B -> C`），Bob 既会考虑 Alice 会不会快速结算转发中的 HTLC（就像原来的 HTLC 背书一样），也会考虑 Carol 会不会快速结算自己转发过去的 HTLC（这是新的部分）。现在，当 Bob 收到来自 Alice 的一个已得到背书的 HTLC 时：

  - 如果 Bob 认为 Alice 和 Carol 都是可靠的，他会转发并向 Carol 背书这个 HTLC 。
  - 如果 Bob 认为只有 Alice 是可靠的，他就不会转发这个得到背书的 HTLC。他会立即拒绝，让错误回传给最初的支付者，从而支付者可以尝试另一条路径。
  - 如果 Bob 认为只有 Carol 是可靠的，他将在容量富余时接受来自 Alice 的背书 HTLC，但在转发给 Carol 时不会给出背书。

  给定提议的这项变更， Kirk-Cohen 和 Shikhelman 正在计划额外的实验，以检验它是否能按预期起作用。他们也额外链接了 Jim Posen 在 2018 年5 月的[邮件][posen bidir]，作为解决该问题的早期平行探索的一个例子：该邮件介绍了一种防止阻塞攻击（那时候还叫 “loop 攻击”）的双向声誉系统。

- **<!--shielded-clientside-validation-csv-->****暗影客户端验证（Shielded CSV）**：Jonas Nick、Liam Eagen 和 Robin Linus 在 Bitcoin-Dev 邮件组中[发帖][nel post]介绍了一篇关于一种新的 “客户端验证（[client-side validation][topic client-side validation]）” 协议的[论文][nel paper]。客户端验证技术让 token 的转移可以受到比特币的工作量证明的保护，而无需公开揭晓关于这些 token 及其转移情形的任何信息。客户端验证是 [RGB][topic client-side validation] 和 [Taproot Assets][topic client-side validation] 这样的协议的关键元素。

  现有协议的一个缺点在于，需要被接收 token 的客户端验证的数据的数量，在最坏的情形下，是跟这种 token 以及每一种相关 token 的每一次转移的历史一样大的。换句话说，如果一组 token 的转移频率跟比特币一样，那么客户端将需要验证大致跟整个比特币区块链一样大的历史。除了转移这些数据的带宽开销以及验证这些数据的 CPU 开销，转移完整的历史也会削弱以往的 token 接收者的隐私性。相比之下，暗影 CSV 协议使用零知识证明技术，从而验证的资源开销可以固定下来，而且无需揭晓以往的转移。

  现有协议的另一个缺点在于，一种 token 的每一次转移都需要在比特币交易中包含数据。而暗影 CSV 允许多笔转移合并在同一个 64 字节的状态更新中。这让一个新的比特币区块就可以确认几千次 token 转移 —— 只需这个区块确认一笔带有额外 64 字节数据推入操作的比特币交易。

  这篇论文细节很多。我们发现尤为有趣的是：（1）使用 [BitVM][topic acc]，让比特币可以免信任可以从主链上桥接到一种暗影 CSV 协议中（并跳转回来），而无需共识变更；（2）对账户模式的使用（第 2 章）；（3）对区块链重组对账户模式和 token 转移影响的讨论（也是第 2 章）；（4）关于对未确认交易的依赖的讨论（章节 5.2）；以及（5）可能的插件的列表（附录 A）。

- **<!--draft-of-updated-bip-process-->****更新 BIP 流程的草案**：Mark "Murch" Erhardt 在 Bitcoin-Dev 邮件组中[宣布][erhardt post]一个介绍 BIP 库更新流程的 BIP 草案的[合并请求权限][erhardt pr]已打开。欢迎任何感兴趣的人审核该草案并留下评论。如果社区认为该草案的最终版本是可以接受的，那么 BIP 的编辑们将开始使用这个流程。

## Bitcoin Stack Exchange 的精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者们寻找疑惑解答的首选之地 —— 也是他们有闲暇时会帮助好奇和困惑的用户的地方。在这个月度栏目中，我们会列出自上一次出刊以来出现的高票问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--what-specific-verifications-are-done-on-a-fresh-bitcoin-tx-and-in-what-order-->对一笔新的比特币交易，会以什么顺序执行哪些验证？]({{bse}}124221) Murch 枚举了 Bitcoin Core 对一笔新交易执行的有效性检查（在其被提交到交易池的时候），包括在 `CheckTransaction`、`PreChecks`、` AcceptSingleTransaction` 以及相关函数中的检查。

- [<!--why-is-my-bitcoin-directory-larger-than-my-pruning-data-limit-setting-->为什么我的比特币目录的体积会超过我的 prune 限制体积？]({{bse}}124197) Pieter Wuille 指出，虽然 “剪枝”（`prune`）选项会限制 Bitcoin Core 的区块链数据的体积，链状态（chainstate）、索引（indexes）、交易池备份、钱包文件和其它文件不会受到 `prune` 选项的限制，其体积增长是独立的。

- [<!--what-do-i-need-to-have-set-up-to-have-getblocktemplate-work-->我要确定哪些东西才能让 `getblocktemplate` 工作？]({{bse}}124142) 用户 CoinZwischenzug 也问了一个[<!--related-question-->相关问题]({{bse}}124160)：如何计算为一个区块计算默克尔根以及 coinbase 交易。对这两个问题的回答（来自 Vojtěch Strnad、RedGrittyBrick 和 Pieter Wuille）都类似地指向了：虽然 Bitcoin Core 的 `getblocktemplate` 可以构造候选的交易区块和区块头信息，但在非测试网络上挖矿时，coinbase 交易是由挖矿软件或者 “[矿池][topic pooled mining]” 软件创建的。

- [<!--can-a-silent-payment-address-body-be-brute-forced-->静默支付地址的主体可以被暴力搜索出来吗？]({{bse}}124207) Josie 引用 [BIP352][]，列出了派生一个 “[静默支付][topic silent payments]” 地址的步骤，结论是使用暴力搜索来攻破静默支付的隐私性得益是不切实际的。

- [<!--why-does-a-tx-fail-testmempoolaccept-bip125-replacement-but-is-accepted-by-submitpackage-->为什么一个无法通过 `testmempoolaccept` 的 BIP125 替代交易可以被 `submitpackage` 接受呢？]({{bse}}124269) Ava Chow 指出，`testmempoolaccept` 只会孤立地评估一笔交易，因此，来自 Bitcoin Core 28.0 [测试手册][bcc testing rbf] 的 [RBF][topic rbf] 案例会被拒绝。然而，因为 [`submitpackage`][news272 submitpackage] 会同时评估案例中的父交易和子交易（作为一个[交易包][topic package relay]），所以父交易和子交易都会被接受。

- [<!--how-does-the-ban-score-algorithm-calculate-a-ban-score-for-a-peer-->断连评分算法如何给一个对等节点打分？]({{bse}}117227) Brunoerg 引用了 [Bitcoin Core #29575][new309 ban score] —— 该 PR 调整了对特定不轨行为的评分 —— 然后按列表给出了答案。

## 新版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [BDK 1.0.0-beta.4][] 是这个用户开发钱包和其它比特币嵌入式应用的库的候选版本。最初的 `bdk` Rust 库已经重命名为 `bdk_wallet`，而更底层的模块已经抽取成了独立的库，包括 `bdk_chain`、`bdk_electrum`、`bdk_esplora`，以及 `bdk_bitcoind_rpc` 。`bdk_wallet` 库 “是第一个能够提供稳定的 1.0.0 API 的版本。”

- [Bitcoin Core 28.0rc2][] 是这个主流的比特币全节点实现的下一个主要版本的候选发布。有一个附带的[测试手册][bcc testing]。

## 重大的代码和文档变更

_本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。_

- [Eclair #2909][] 为 `createinvoice` RPC 命令添加了一个 `privateChannelIDs` 参数，用于为 BOLT11 发票添加[私密通道][topic unannounced channels]路由提示。这修复了阻止一个只有私密通道的节点接收支付的故障。为避免泄露通道的输出点，应使用 `scid_alias` 。

- [LND #9095][] 和 [LND #9072][] 为发票 [HTLC][topic htlc] 修饰符、“辅助通道（auxiliary channel）” 的开启和关闭操作加入了变更，还为 RPC/CLI 集成了定制化数据，作为定制通道措施的一部分，以强化 LND 对 [taproot assets][topic client-side validation] 协议的支持。这一 PR 允许定制化的资产专属数据进入 PRC 命令，并支持通过命令行接口来管理辅助通道。

- [LND #8044][] 添加了新的消息类型 `announcement_signatures_2`、`channel_announcement_2` 和 `channel_update_2`，以支持新的 v1.75 gossip 协议（详见[周报 #261][news261 v1.75]），以允许节点[公布][topic channel announcements]和验证 [taproot 通道][topic simple taproot channels]。此外，现有的消息类型，例如 `channel_ready` 和 `gossip_timestamp_range`，也加入了一些修改，以提升 taproot 通道 gossip 的效率和安全性。

{% include references.md %}
{% include linkers/issues.md v=2 issues="26355,2909,9095,9072,8044" %}
[BDK 1.0.0-beta.4]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.4
[bitcoin core 28.0rc2]: https://bitcoincore.org/bin/bitcoin-core-28.0/
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Candidate-Testing-Guide
[news216 checkpoints]: /zh/newsletters/2022/09/07/#bitcoin-core-25717
[poinsot headers]: https://mailing-list.bitcoindevs.xyz/bitcoindev/WhFGS_EOQtdGWTKD1oqSujp1GW-v_ZUJemlNePPGaGBgzpmu6ThpqLwJpUVei85OiMu_xxjEzt_SeOWY7547C72BVISLENOd_qrdCwPajgk=@protonmail.com/
[fuller dos]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-October/017354.html
[fuller paper]: https://bcoin.io/papers/bitcoin-chain-expansion.pdf
[posen bidir]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-May/001232.html
[erhardt post]: https://mailing-list.bitcoindevs.xyz/bitcoindev/82a37738-a17b-4a8c-9651-9e241118a363@murch.one/
[erhardt pr]: https://github.com/murchandamus/bips/pull/2
[news310 bcc]: /zh/newsletters/2024/07/05/#disclosure-of-vulnerabilities-affecting-bitcoin-core-versions-before-0210-0-21-0-bitcoin-core
[news314 bcc]: /zh/newsletters/2024/08/02/#disclosure-of-vulnerabilities-affecting-bitcoin-core-versions-before-22-0-bitcoin-core-22-0
[kc jam]: https://delvingbitcoin.org/t/hybrid-jamming-mitigation-results-and-updates/1147/
[kc attackathon]: https://github.com/carlaKC/attackathon
[sink attack]: https://delvingbitcoin.org/t/hybrid-jamming-mitigation-results-and-updates/1147#p-3212-manipulation-sink-attack-9
[bidirectional reputation]: https://delvingbitcoin.org/t/hybrid-jamming-mitigation-results-and-updates/1147#p-3212-bidirectional-reputation-10
[nel post]: https://mailing-list.bitcoindevs.xyz/bitcoindev/b0afc5f2-4dcc-469d-b952-03eeac6e7d1b@gmail.com/
[nel paper]: https://github.com/ShieldedCSV/ShieldedCSV/releases/latest/download/shieldedcsv.pdf
[news261 v1.75]: /zh/newsletters/2023/07/26/#updated-channel-announcements
[bcc testing rbf]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Candidate-Testing-Guide#3-package-rbf
[news272 submitpackage]: /zh/newsletters/2023/10/11/#bitcoin-core-27609
[new309 ban score]: /zh/newsletters/2024/06/28/#bitcoin-core-29575
