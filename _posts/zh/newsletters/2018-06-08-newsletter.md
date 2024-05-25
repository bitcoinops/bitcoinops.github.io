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

**这份来自 2018 年 6 月 8 日的 Newsletter，是 Optech Newsletter 的预览版。**

*从上周五到本周四，即 6 月 1 日至 6 月 7 日，有关比特币的技术新闻。*

## 摘要

一个新的 Bitcoin Core 维护版本即将发布，其中包含一个转发策略的变更，哈希率（hash rate）迅速增加，因此现在可能是发送低费用交易的好时机，钱包提供商可能想要调查一下即将完全实施的 [BIP174][BIP174] 提案，针对点对点（P2P）轻客户端的过滤器（filters）正在受到重点讨论，请求对私钥序列化（private key serialization）变更以及挖矿池与其哈希者通信方式的提案提供反馈，Bitcoin Core 合并了一项优化，可以使默克尔树（merkle trees）的构建速度提高大约 7 倍。

[BIP174]: https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki

## 关键行动项

- **<!--check-for-use-of-the-codeseparator-opcode-->****检查 `CodeSeparator` 操作码的使用情况：** 预计在下周左右发布的 Bitcoin Core 0.16.1 版将[不再转发][standardness_rules]使用此操作码的传统（非隔离见证（segwit））交易。据 Bitcoin Core 贡献者所知，没有人使用这个操作码，但如果您的组织使用它或计划使用它，您应该立即[联系协议开发者][contact_dev]或 Optech 团队成员，尽快告知他们此事。最终，通过软分叉（soft fork），这个操作码可能会从比特币协议中删除，以用于传统交易。

[contact_dev]: https://bitcoincore.org/en/contact/
[standardness_rules]: https://github.com/bitcoin/bitcoin/pull/11423

- **<!--test-release-candidates-rc-for-bitcoin-core-version-0-16-1-->****[Bitcoin Core version 0.16.1 测试候选版本][rc] 。** RC1 现已可用；RC2 很可能很快就会发布。此版本将包含对矿工尤其重要的错误修复。对于支付者-接收者和 API 提供商没有重大变化，但他们可能会从错误修复中受益。

[rc]: https://bitcoincore.org/bin/bitcoin-core-0.16.1/

## 仪表盘更新

- **<!--hash-rate-increases-->****哈希率增加：** 本周挖矿难度增加了近 15%，短期平均网络哈希率显示持续增长。这意味着区块产生的频率比正常情况更高，只要这一趋势持续，交易费用可能会保持较低水平。这是[合并交易输出][consolidate]或发送低费用交易的好时机。

[consolidate]: https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#Consolidation

- **<!--very-low-fee-transactions-->****非常低费用的交易：** 在具有非默认交易接受策略的节点上观察到支付低于 10 nBTC/vbyte 的非常低费用的交易数量增加（默认策略是拒绝支付低于 10 nBTC/vbyte 的交易）。这可能表明配置错误的钱包支付了过低的费用，或者表明一些支付者认为这是节省费用的可行策略。值得尝试以确定这些极低的费用是否可以用于合并和其他非时间敏感的钱包内转账。

## 新闻

- **<!--bip174-bip174-discussion-and-review-ongoing-->****[BIP174][BIP174] 讨论和审查正在进行中：** 该 BIP 创建了一个标准化格式，供钱包可靠地共享与未签名和部分签名交易相关的信息。这预计将在 Bitcoin Core 中实现，并且也可能在其他钱包中实现，从而使软件钱包、硬件钱包和离线（冷）钱包能够轻松相互交互，用于单签名和多签名交易。此 BIP 有潜力成为行业标准，因此鼓励所有主要钱包提供商调查规范。

    [BIP174 的提议实现][PR12136]先前已被添加到 Bitcoin Core 的[高优先级审查队列][high priority]中，并在本周收到了重要讨论，至少发现了一个错误，一位协议开发者建议可以将提案的部分内容拆分。

[BIP174]: https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki
[PR12136]: https://github.com/bitcoin/bitcoin/pull/12136
[high priority]: https://github.com/bitcoin/bitcoin/projects/8

- **<!--bip157-bip157-bip158-bip158-lightweight-client-filters-->****[BIP157][BIP157]/[BIP158][BIP158] 轻客户端过滤器：** 这些 BIP 允许节点为链上的每个区块创建交易数据的紧凑索引，然后将该索引的副本分发给请求它们的轻客户端。客户端随后可以私下确定区块是否可能包含客户端的任何交易。

    本周在邮件列表上[大量讨论][BIP158 discussion]应该索引哪些数据。这可能不会直接影响大多数大额接收者-支付者和 API 服务，但任何计划使用点对点网络协议发布钱包的提供商可能会想要审查 BIP。

    本周合并到 Bitcoin Core 的 PR [#13243][PR 13243] 是将此功能带到 Bitcoin Core 的努力的一部分。

[BIP157]: https://github.com/bitcoin/bips/blob/master/bip-0157.mediawiki
[BIP158]: https://github.com/bitcoin/bips/blob/master/bip-0158.mediawiki
[BIP158 discussion]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-June/016057.html
[PR 13243]: https://github.com/bitcoin/bitcoin/pull/13243

- **<!--proposed-bip-bech32-keys-for-private-key-hd-wallet-serialization-->****[私钥和 HD 钱包序列化的提议 BIP][bech32 keys]：** 当前私钥通常使用与传统比特币地址相同的编码进行传输，HD 钱包扩展密钥和种子使用相同的格式、十六进制或助记词传输。这项新提议将允许使用用于原生隔离见证（SegWit）地址的 bech32 格式。

    [讨论][bech32 keys discussion]集中在是否使用完全的 bech32 标准或其修改版，后者在抗录入和数据丢失错误方面更为强大。计划接受或分发密钥材料的服务可能希望贡献审查规范。

[bech32 keys]: https://gist.github.com/jonasschnelli/68a2a5a5a5b796dc9992f432e794d719
[bech32 keys discussion]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-June/016065.html

- **<!--betterhash-mining-protocol-betterhash-spec-->****[BetterHash 挖矿协议][BetterHash spec]：** 一种拟替代当前几乎普遍用于挖矿池分配工作给个别矿工的 Stratum 挖矿协议的方案。该提议声称为矿池运营商提供更好的安全性，并允许个别矿工选择他们在区块中包含的交易，增加比特币的审查抵抗力，同时也可能使使用该协议的矿工更有效率。该协议由 [FIBRE 网络][FIBRE] 的开发者和运营者提倡，几乎所有的矿工都使用该网络。

    该协议已经在半私密的开发中一段时间，现在开始分发以征求公众意见。鼓励计划销售或运营挖矿设备的组织审查该协议，以及任何希望对比特币共识规则进行更改的团体或个人，以便协议可能与这些更改向前兼容。该提议尚未进行多少[在列表上的讨论][BetterHash discussion]。

[BetterHash spec]: https://github.com/TheBlueMatt/bips/blob/betterhash/bip-XXXX.mediawiki
[FIBRE]: http://bitcoinfibre.org/
[BetterHash discussion]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-June/016077.html

## 比特币提交历史上的今天...

- **<!--n-2017-->****2017 年：** Andrew Chow 作者的提交 [ec6902d][commitec6902d]，为移除加入到比特币 0.3.x 版本之后，由于[值溢出事件][value overflow]而添加的令人困惑的“安全模式”功能的最后部分铺平了道路。

[commitec6902d]: https://github.com/bitcoin/bitcoin/commit/ec6902d0ea2bbe75179684fc71849d5e34647a14
[value overflow]: https://en.bitcoin.it/wiki/Value_overflow_incident

- **<!--n-2016-->****2016 年：** Luke Dashjr 的 PR [#7935][PR7953] 被合并，为 GetBlockTemplate RPC 调用添加了对 [BIP9][BIP9] 版本位（versionbits）的支持，允许矿工为未来的软分叉，如激活 [BIP141][BIP141] 隔离见证的软分叉发出支持信号。

[PR7953]: https://github.com/bitcoin/bitcoin/pull/7935
[BIP9]: https://github.com/bitcoin/bips/blob/master/bip-0009.mediawiki
[BIP141]: https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki

- **<!--n-2015-->****2015 年：** Gavin Andresen 授权提交 [65b94545][commit65b94545] 以完善节点用来检测它可能不再从最佳区块链接收区块的标准。

[commit65b94545]: https://github.com/bitcoin/bitcoin/commit/65b94545036ae6e38e79e9c7166a3ba1ddb83f66

- **<!--n-2014-->****2014 年：** Cozz Lovan 授权提交 [95a93836][commit95a93836] 移除了 GUI 的一个遗留部分，该部分假设任何低于 0.01 BTC 的交易费都是低交易费。

[commit95a93836]: https://github.com/bitcoin/bitcoin/commit/95a93836d8ab3e5f2412503dfafdf54db4f8c1ee

- **<!--n-2013-->****2013 年：** Wladimir van der Laan 授权提交 [3e9c8ba][commit3e9c8ba] 修复了一个与数据目录相关的错误。

[commit3e9c8ba]: https://github.com/bitcoin/bitcoin/commit/3e9c8bab54371364f8e70c3b44e732c593b43a76

- **<!--n-2012-->****2012 年：** Luke Dashjr 授权几个提交（例如 [9655d73][commit9655d73]）关于启用 IPv6 支持。

[commit9655d73]: https://github.com/bitcoin/bitcoin/commit/9655d73f49cd4da189ddb2ed708c26dc4cb3babe

- **<!--n-2011-2010-2009-->****2011 年、2010 年、2009 年：** 6 月 8 日没有提交。