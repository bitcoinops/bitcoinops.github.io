---
title: 'Bitcoin Optech Newsletter #320'
permalink: /zh/newsletters/2024/09/13/
name: 2024-09-13-newsletter-zh
slug: 2024-09-13-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报宣布了一个新的 Bitcoin Core 测试工具，并简要描述了一个基于 DLC 的贷款合约。此外还有我们的常规部分：其中包括 Bitcoin Core PR 审核俱乐部会议的总结、新版本和候选版本的公告，以及对热门比特币基础设施项目的重大变更介绍。

## 新闻

- **<!--mutation-testing-for-bitcoin-core-->****Bitcoin Core 的突变测试：** Bruno Garcia 在 Delving Bitcoin 上[发帖][garcia announce]宣布了一款[工具][mutation-core]，该工具会自动修改（突变）PR 或 commit 中更改的代码，以确定这些突变是否导致现有测试失败。任何时候对代码的随机更改未产生失败结果时，这表明测试覆盖率可能不完整。Garcia 的自动突变工具忽略了代码注释和其他不会预期产生变化的代码行。

- **<!--dlc-based-loan-contract-execution-->****执行基于 DLC 的贷款合约：** Shehzan Maredia 在 Delving Bitcoin 上[发帖][maredia post]，宣布了 [Lava Loans][Lava Loans]，这是一种使用 [DLC][topic dlc] 谕言机进行价格发现的比特币抵押贷款合约。例如，Alice 向 Bob 提供 100,000 美元的贷款，条件是 Bob 必须在存款地址中保有至少 200,000 美元 的 BTC。由 Alice 和 Bob 都信任的谕言机定期发布签名，以承诺当前的 BTC/USD 价格。如果 Bob 的 BTC 抵押品低于约定金额，Alice 可以根据谕言机签名的最高价格扣押价值 100,000 美元的 BTC。或者，Bob 可以在链上提供他已偿还贷款的证明（形式为 Alice 透露的哈希原像）以取回他的抵押品。如果双方不合作或一方变得无响应，还可以有其他解决方案。与任何 DLC 一样，谕言机无法得知合约的详细信息，甚至不知道其价格信息正在合约中使用。

## Bitcoin Core PR 审核俱乐部

*在这个月度部分，我们总结了最近一次 [Bitcoin Core PR 审核俱乐部会议][Bitcoin Core PR Review Club]会议。*

[Bitcoin Core 28.0 候选版本的测试][review club v28-rc-testing]不是一次审核特定 PR 的审核俱乐部的会议，而是一次集体测试活动。

在每次 [Bitcoin Core 主要版本发布][major Bitcoin Core release]之前，社区的广泛测试被认为是至关重要的。因此，一位志愿者会为[候选版本][release candidate]编写测试指南，以便尽可能多的人能够高效地测试，而不必独立确认新内容或更改或改造测试这些特性或修改的各种设置步骤。

测试可能很困难，因为当遇到意外行为时，通常不清楚是由于实际错误还是测试人员犯了错误。报告不是真正错误的问题会浪费开发人员的时间。为减轻这些问题并促进测试工作，针对特定候选版本会举办 Review Club 会议，此次为 28.0rc1。

[28.0 候选版本的测试指南][28.0 testing]由 rkrux 编写，他还主持了审核俱乐部会议。

与会者还被鼓励通过阅读 [28.0 版本说明][28.0 release notes] 获得测试灵感。

本次审核俱乐部涵盖了[testnet4][topic testnet]([Bitcoin Core #29775][])的引入、[TRUC (v3) 交易][topic v3 transaction relay] ([Bitcoin Core #28948][])、[包 RBF][topic rbf] ([Bitcoin Core #28984][]) 和冲突交易池交易 ([Bitcoin Core #27307][])。指南中提到的其他主题但未在会议上讨论的内容包括：默认启用 `mempoolfullrbf` ([Bitcoin Core #30493][])、[`PayToAnchor`][topic ephemeral anchors] 花费 ([Bitcoin Core #30352][])和新的 `dumptxoutset` 格式 ([Bitcoin Core #29347][])。

## 版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [LND v0.18.3-beta][] 是这个热门的 LN 节点实现的一个小错误修复版本。

- [BDK 1.0.0-beta.2][] 是这个用于构建钱包和其他比特币应用程序的库的候选版本。原始的 `bdk` Rust crate 已更名为 `bdk_wallet`，底层模块已被提取为独立的，包括：`bdk_chain`、 `bdk_electrum`、 `bdk_esplora`和 `bdk_bitcoind_rpc`。`bdk_wallet` crate “是第一个提供稳定 1.0.0 API 的版本。”

- [Bitcoin Core 28.0rc1][] 是这个主要全节点实现的下一个版本的候选版本。提供了[测试指南][bcc testing]。

## 重大的代码和文档变更

_本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。_

_请注意，下面提到的对 Bitcoin Core 的提交适用于其主开发分支，因此这些更改可能要等到即将发布的 28 版本发布约六个月后才会发布。_

- [Bitcoin Core #30509][] 给 `bitcoin-node` 添加了 `-ipcbind` 选项，以允许其他进程通过 Unix 套接字连接并控制节点。与即将到来的 [Bitcoin Core #30510][] PR 配合使用，这将允许外部 [Stratum v2][topic pooled mining] 挖矿服务创建、管理和提交区块模板。这是 Bitcoin Core [多进程项目][multiprocess project]的一部分。见周报[#99][news99 multi]和[#147][news147 multi]。

- [Bitcoin Core #29605][] 更改了节点发现机制，优先从本地地址管理器中发现对等节点，而不是从种子节点中获取，以减少种子节点对对等节点选择的影响，并减少不必要的信息共享。默认情况下，种子节点是 DNS 种子节点无法访问时的备份（在主网中非常少见）；但是，测试网络或定制节点的用户可以手动添加种子节点，以查找类似配置的节点。在此 PR 之前，添加一个种子节点意味着在节点几乎每次启动时都会被询问新的地址，这可能使其影响对等节点的选择，并且只推荐与其共享数据的对等节点。借助此 PR，只有在地址管理器为空或在一段时间内没有成功获取地址时，种子节点才会以随机顺序被添加到地址获取队列中。有关种子节点的更多信息，见周报[#301][news301 seednode]。

{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30509,29605,30510,29775,28948,28984,27307,30493,30352,29347" %}
[LND v0.18.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.3-beta
[BDK 1.0.0-beta.2]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.2
[bitcoin core 28.0rc1]: https://bitcoincore.org/bin/bitcoin-core-28.0/
[garcia announce]: https://delvingbitcoin.org/t/mutation-core-a-mutation-testing-tool-for-bitcoin-core/1119
[mutation-core]: https://github.com/brunoerg/mutation-core
[maredia post]: https://delvingbitcoin.org/t/lava-loans-trust-minimized-bitcoin-secured-loans/1112
[lava loans]: https://github.com/lava-xyz/loans-paper/blob/960b91af83513f6a17d87904457e7a9e786b21e0/loans_v2.pdf
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Candidate-Testing-Guide
[news99 multi]: /en/newsletters/2020/05/27/#bitcoin-core-18677
[news147 multi]: /en/newsletters/2021/05/05/#bitcoin-core-19160
[multiprocess project]: https://github.com/ryanofsky/bitcoin/blob/pr/ipc/doc/design/multiprocess.md
[news301 seednode]: /zh/newsletters/2024/05/08/#bitcoin-core-28016
[review club v28-rc-testing]: https://bitcoincore.reviews/v28-rc-testing
[major bitcoin core release]: https://bitcoincore.org/en/lifecycle/#major-releases
[28.0 release notes]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Notes-Draft
[release candidate]: https://bitcoincore.org/en/lifecycle/#versioning
[28.0 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Candidate-Testing-Guide
