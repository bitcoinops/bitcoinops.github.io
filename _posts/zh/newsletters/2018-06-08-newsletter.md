---
title: 'Bitcoin Optech Newsletter #0'
permalink: /zh/newsletters/2018/06/08/
name: 2018-06-08-newsletter-zh
slug: 2018-06-08-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
version: 1
excerpt: >
  Optech Newsletter 试运行，包括有关 `OP_CODESEPARATOR` 操作码、BetterHash 挖矿协议以及 BIP157/158 紧凑区块过滤器的新闻。
---

**本刊 2018 年 6 月 8 日这一期，是 Optech Newsletter 的试刊。**

*覆盖 6 月 1 日（上周五）至 6 月 7 日（本周四）的比特币技术新闻。*

## 摘要

Bitcoin Core 即将发布一个新的维护版本，其中包含中继策略的调整。网络哈希率（hash rate）正在快速上升，因此现在可能是发送低费率交易的好时机。钱包提供商或许应在 [BIP174][BIP174] 提案完全实施前先行研究。面向点对点（P2P）轻客户端的过滤器（filters）正受到热烈讨论；私钥序列化（private key serialization）方式，以及矿池与矿工通信方式的变更提案正在征求反馈；此外，Bitcoin Core 合并了一项优化，使默克尔树（merkle trees）的构建速度最多提升约 7 倍。

[BIP174]: https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki

## 关键行动项

- **<!--check-for-use-of-the-codeseparator-opcode-->****检查 `CodeSeparator` 操作码的使用情况：** 预计在未来一周左右发布的 Bitcoin Core 0.16.1 版，将[不再中继][standardness_rules]使用该操作码的传统（非 segwit）交易。据 Bitcoin Core 贡献者所知，目前没有人使用这个操作码；但如果你的组织正在使用或计划使用，应立即[联系协议开发者][contact_dev]或 Optech 团队成员，告知此事。最终，这个操作码可能会通过软分叉从比特币协议中移除（针对传统交易）。

[contact_dev]: https://bitcoincore.org/en/contact/
[standardness_rules]: https://github.com/bitcoin/bitcoin/pull/11423

- **<!--test-release-candidates-rc-for-bitcoin-core-version-0-16-1-->****[Bitcoin Core 0.16.1 测试候选版本][rc]。** RC1 已发布，RC2 可能很快就会推出。此版本包含对矿工尤其重要的错误修复。对付款方兼收款方和 API 提供商而言没有重大变更，但他们也可能从这些修复中受益。

[rc]: https://bitcoincore.org/bin/bitcoin-core-0.16.1/

## 仪表盘更新

- **<!--hash-rate-increases-->****哈希率上升：** 本周挖矿难度提高了近 15%，短期平均网络哈希率显示仍在持续增长。这意味着出块频率高于正常水平；只要这一趋势延续，手续费就可能维持在低位。这是[合并交易输出][consolidate]或发送低费率交易的好时机。

[consolidate]: https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#Consolidation

- **<!--very-low-fee-transactions-->****极低手续费交易：** 在采用非默认交易接受策略的节点上，出现了大量手续费低于每 vbyte 10 nBTC 的交易（默认策略会拒绝低于 10 nBTC/vbyte 的交易）。这可能说明有钱包配置错误、支付的手续费过低；也可能说明部分付款方认为这是节省手续费的有效策略。值得试验：这些极低手续费能否用于整合及其他对时间不敏感的钱包内转账。

## 新闻

- **<!--bip174-bip174-discussion-and-review-ongoing-->****[BIP174][BIP174] 的讨论与审查仍在进行：** 该 BIP 定义了一种标准化格式，让钱包能够可靠地共享未签名与部分签名交易的相关信息。它预计会在 Bitcoin Core 中实现，也可能被其他钱包采用，从而使软件钱包、硬件钱包和离线（冷）钱包能够方便地互相协作，覆盖单签与多重签名交易。该 BIP 有潜力成为行业标准，因此建议所有主要钱包提供商研究其规范。

    [BIP174 的提议实现][PR12136]此前已被列入 Bitcoin Core 的[高优先级审查队列][high priority]，本周引发了大量讨论：至少发现了一个 bug，也有协议开发者建议将提案的部分内容拆分。

[BIP174]: https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki
[PR12136]: https://github.com/bitcoin/bitcoin/pull/12136
[high priority]: https://github.com/bitcoin/bitcoin/projects/8

- **<!--bip157-bip157-bip158-bip158-lightweight-client-filters-->****[BIP157][BIP157]/[BIP158][BIP158] 轻客户端过滤器：** 这两份 BIP 允许节点为链上每个区块创建交易数据的紧凑索引，再把该索引的副本分发给提出请求的轻客户端。客户端随后可在不泄露查询内容的前提下，判断某个区块是否可能包含自己的交易。

    本周，邮件列表就“究竟应索引哪些数据”展开了[大量讨论][BIP158 discussion]。这大概不会直接影响大多数大型收款方兼付款方与 API 服务，但任何计划基于 P2P 网络协议发布钱包的提供商，都应研究这两份 BIP。

    本周合并的 Bitcoin Core PR [#13243][PR 13243]，正是把该功能引入 Bitcoin Core 的工作之一。

[BIP157]: https://github.com/bitcoin/bips/blob/master/bip-0157.mediawiki
[BIP158]: https://github.com/bitcoin/bips/blob/master/bip-0158.mediawiki
[BIP158 discussion]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-June/016057.html
[PR 13243]: https://github.com/bitcoin/bitcoin/pull/13243

- **<!--proposed-bip-bech32-keys-for-private-key-hd-wallet-serialization-->****[私钥与 HD 钱包序列化的提议 BIP][bech32 keys]：** 目前，私钥通常采用与传统比特币地址相同的编码传输；HD 钱包的扩展密钥和种子则使用相同格式、十六进制或助记词传输。这项新提案允许改用原生 segwit 地址所用的 bech32 格式。

    [讨论][bech32 keys discussion]集中在两点：是直接采用 bech32 标准，还是采用其修改版——后者更能抵御转录错误和数据丢失。计划接收或分发密钥材料的服务，可参与该规范的审查。

[bech32 keys]: https://gist.github.com/jonasschnelli/68a2a5a5a5b796dc9992f432e794d719
[bech32 keys discussion]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-June/016065.html

- **<!--betterhash-mining-protocol-betterhash-spec-->****[BetterHash 挖矿协议][BetterHash spec]：** 该协议拟取代 Stratum——目前矿池几乎普遍用它向个体矿工分配任务。提案声称能为矿池运营方提供更好的安全性，并允许个体矿工自行选择打包哪些交易，从而提升比特币的抗审查性，也可能让使用该协议的矿工更高效。该协议由 [FIBRE 网络][FIBRE] 的开发者和运营者推动，几乎所有矿工都使用该网络。

    该协议已在半公开状态下开发了一段时间，现开始公开征求意见。计划销售或运营挖矿设备的组织，以及任何希望修改比特币共识规则的团体或个人，都应研究该协议，以便协议未来能与这些修改保持向前兼容。该提案在邮件列表上尚未引起太多[讨论][BetterHash discussion]。

[BetterHash spec]: https://github.com/TheBlueMatt/bips/blob/betterhash/bip-XXXX.mediawiki
[FIBRE]: http://bitcoinfibre.org/
[BetterHash discussion]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-June/016077.html

## 比特币提交历史上的今天……

- **<!--n-2017-->****2017 年：** Andrew Chow 提交了 [ec6902d][commitec6902d]，为移除“安全模式”功能的最后几部分铺平了道路——这项令人困惑的功能，是比特币 0.3.x 在[数值溢出事件][value overflow]之后加入的。

[commitec6902d]: https://github.com/bitcoin/bitcoin/commit/ec6902d0ea2bbe75179684fc71849d5e34647a14
[value overflow]: https://en.bitcoin.it/wiki/Value_overflow_incident

- **<!--n-2016-->****2016 年：** Luke Dashjr 的 PR [#7935][PR7953] 被合并，为 GetBlockTemplate RPC 调用增加了对 [BIP9][BIP9] 版本位（versionbits）的支持，使矿工能对未来软分叉发出支持信号——例如激活 [BIP141][BIP141] 隔离见证的那次软分叉。

[PR7953]: https://github.com/bitcoin/bitcoin/pull/7935
[BIP9]: https://github.com/bitcoin/bips/blob/master/bip-0009.mediawiki
[BIP141]: https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki

- **<!--n-2015-->****2015 年：** Gavin Andresen 提交了 [65b94545][commit65b94545]，完善了节点判定“自己可能已不再从最佳区块链接收区块”的标准。

[commit65b94545]: https://github.com/bitcoin/bitcoin/commit/65b94545036ae6e38e79e9c7166a3ba1ddb83f66

- **<!--n-2014-->****2014 年：** Cozz Lovan 提交了 [95a93836][commit95a93836]，移除了 GUI 中的一段遗留逻辑——它假定任何低于 0.01 BTC 的手续费都算低手续费。

[commit95a93836]: https://github.com/bitcoin/bitcoin/commit/95a93836d8ab3e5f2412503dfafdf54db4f8c1ee

- **<!--n-2013-->****2013 年：** Wladimir van der Laan 提交了 [3e9c8ba][commit3e9c8ba]，修复了一个与数据目录相关的 bug。

[commit3e9c8ba]: https://github.com/bitcoin/bitcoin/commit/3e9c8bab54371364f8e70c3b44e732c593b43a76

- **<!--n-2012-->****2012 年：** Luke Dashjr 提交了若干与启用 IPv6 支持相关的提交（例如 [9655d73][commit9655d73]）。

[commit9655d73]: https://github.com/bitcoin/bitcoin/commit/9655d73f49cd4da189ddb2ed708c26dc4cb3babe

- **<!--n-2011-2010-2009-->****2011 年、2010 年、2009 年：** 6 月 8 日没有提交。