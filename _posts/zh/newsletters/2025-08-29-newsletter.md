---
title: 'Bitcoin Optech Newsletter #369'
permalink: /zh/newsletters/2025/08/29/
name: 2025-08-29-newsletter-zh
slug: 2025-08-29-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报分享了关于比特币和闪电网络实现差分模糊测试的更新，并链接到一篇关于用于可问责计算合约的混淆锁的新论文。此外还包括我们的常规部分：总结了 Bitcoin Stack Exchange 的热门问题和答案、新版本和候选版本的公告，以及对热门比特币基础设施软件的重大变更介绍。

## 新闻

- **<!--update-on-differential-fuzzing-of-bitcoin-and-ln-implementations-->比特币和闪电网络实现差异化模糊测试的更新：** Bruno Garcia 在 Delving Bitcoin 上[发布][garcia fuzz]了关于 [bitcoinfuzz][] 最近进展和成就的描述，这是一个用于对基于比特币的软件和库进行[模糊测试][fuzz testing]的库和相关数据。成就包括发现了“btcd、rust-bitcoin、rust-miniscript、Embit、Bitcoin Core、Core Lightning [和] LND 等项目中的超过 35 个错误”。发现的闪电网络实现之间的差异不仅揭示了错误，还推动了对闪电网络规范的澄清。鼓励比特币项目的开发者调查使其软件成为 bitcoinfuzz 支持的目标。

- **<!--garbled-locks-for-accountable-computing-contracts-->用于可问责计算合约的混淆锁：** Liam Eagen 在 Bitcoin-Dev 邮件列表上[发布][eagen glock]了关于他撰写的一篇[论文][eagen paper]，该论文描述了一种基于[混淆电路][garbled circuits]创建[可问责计算合约][topic acc]的新机制。这与最近其他将混淆电路用于 BitVM 的独立工作类似（但不同）（参见[周报 #359][news359 delbrag]）。Eagen 的帖子自称“（在他看来）第一个实用的混淆锁，其欺诈证明是单个签名，与 BitVM2 相比，链上数据减少了超过 550 倍”。截至撰写本文时，他的帖子尚未收到任何公开回复。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选之地，也是我们有闲暇时会给好奇和困惑的用户帮忙的地方。在这个月度栏目中，我们会列举自上次出刊以来出现的一些高票的问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--is-it-possible-to-recover-a-private-key-from-an-aggregate-public-key-under-strong-assumptions-->是否可能在强假设下从聚合公钥中恢复私钥？]({{bse}}127723)
  Pieter Wuille 解释了围绕 [MuSig2][topic musig] 无脚本[多重签名][topic multisignature]的当前和理论安全假设。

- [<!--are-all-taproot-addresses-vulnerable-to-quantum-computing-->所有 taproot 地址都容易受到量子计算攻击吗？]({{bse}}127660)
  Hugo Nguyen 和 Murch 指出，即使是构造为仅使用脚本路径支出的 [taproot][topic taproot] 输出也容易受到[量子][topic quantum resistance]攻击。Murch 继续指出“有趣的是，生成输出脚本的一方能够证明内部密钥是 NUMS 点，从而证明发生了量子解密。”

- [<!--why-cant-we-set-the-chainstate-obfuscation-key-->为什么我们不能设置链状态混淆密钥？]({{bse}}127814)
  Ava Chow 强调，混淆 `blocksdir` 磁盘内容的密钥（参见[周报 #339][news339 blocksxor]）与混淆 `chainstate` 内容的密钥不同（参见 [Bitcoin Core #6650][]）。

- [<!--is-it-possible-to-revoke-a-spending-branch-after-a-block-height-->是否可能在区块高度后撤销支出分支？]({{bse}}127683)
  Antoine Poinsot 指向[之前的答案]({{bse}}122224)，确认过期支出条件或“反向时间锁”是不可能的，甚至可能不是理想的。

- [<!--configure-bitcoin-core-to-use-onion-nodes-in-addition-to-ipv4-and-ipv6-nodes-->配置 Bitcoin Core 除了使用 IPv4 和 IPv6 节点外还使用洋葱节点？]({{bse}}127727)
  Pieter Wuille 澄清设置 `onion` 配置选项仅适用于出站对等连接。他继续概述了如何为入站连接配置 [Tor][topic anonymity networks] 和 `bitcoind`。

## 新版本和候选版本

*热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Bitcoin Core 29.1rc2][] 是主流全节点软件维护版本的候选版本。

- [Core Lightning v25.09rc4][] 是这个热门闪电网络节点实现新主要版本的候选版本。

## 重大的代码和文档变更

*本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals（BIPs）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Bitcoin Core #31802][] 默认启用进程间通信（IPC）（`ENABLE_IPC`），在除 Windows 外的所有系统上将 `bitcoin-node` 和 `bitcoin-gui` 多进程二进制文件添加到发布构建中。这允许创建、管理和提交区块模板的外部 [Stratum v2][topic pooled mining] 挖矿服务在不需要自定义构建的情况下试验多进程布局。有关多进程项目和 `bitcoin-node` 二进制文件的更多背景信息，请参见周报 [#99][news99 ipc]、[#147][news147 ipc]、[#320][news320 ipc]、[#323][news323 ipc]。

- [LDK #3979][] 添加了拼接输出支持，使 LDK 节点既能发起拼接输出交易，也能接受来自对手方的请求。这完成了 LDK 的[通道拼接][topic splicing]实现，因为 [LDK #3736][] 已经添加了拼接输入支持。此 PR 添加了一个涵盖输入和输出场景的 `SpliceContribution` 枚举，并确保拼接输出交易的输出值在考虑费用和储备要求后不超过用户的通道余额。

- [LND #10102][] 添加了 `gossip.ban-threshold` 选项（默认为 100，0 为禁用该特性），允许用户配置禁用发来无效[gossip][topic channel announcements]消息的对等节点的分数阈值。对等节点禁止系统之前已引入并在[周报 #319][news319 ban]中介绍。此 PR 还解决了一个问题，即解决了响应积压 gossip 查询请求时发送了不必要的节点和[通道公告][topic channel announcements]消息的问题。

- [Rust Bitcoin #4907][] 通过向 `Script` 和 `ScriptBuf` 添加新的通用标签参数 `T` 来引入脚本标记，并定义了类型别名 `ScriptPubKey`、`ScriptSig`、`RedeemScript`、`WitnessScript` 和 `TapScript`，这些别名由密封的 `Tag` 特征支持，用于编译时角色安全。

{% include references.md %}
{% include linkers/issues.md v=2 issues="31802,3979,10102,4907,6650,3736" %}
[bitcoin core 29.1rc2]: https://bitcoincore.org/bin/bitcoin-core-29.1/
[core lightning v25.09rc4]: https://github.com/ElementsProject/lightning/releases/tag/v25.09rc4
[garcia fuzz]: https://delvingbitcoin.org/t/the-state-of-bitcoinfuzz/1946
[bitcoinfuzz]: https://github.com/bitcoinfuzz
[fuzz testing]: https://zh.wikipedia.org/wiki/%E6%A8%A1%E7%B3%8A%E6%B5%8B%E8%AF%95
[eagen glock]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Aq_-LHZtVdSN5nODCryicX2u_X1yAQYurf9UDZXDILq6s4grUOYienc4HH2xFnAohA69I_BzgRCSKdW9OSVlSU9d1HYZLrK7MS_7wdNsLmo=@protonmail.com/
[eagen paper]: https://eprint.iacr.org/2025/1485
[garbled circuits]: https://en.wikipedia.org/wiki/Garbled_circuit
[news359 delbrag]: /zh/newsletters/2025/06/20/#improvements-to-bitvmstyle-contracts
[news339 blocksxor]: /zh/newsletters/2025/01/31/#how-does-the-blocksxor-switch-that-obfuscates-the-blocks-dat-files-work-blocksxor-blocks-dat
[news99 ipc]: /zh/newsletters/2020/05/27/#bitcoin-core-18677
[news147 ipc]: /zh/newsletters/2021/05/05/#bitcoin-core-19160
[news320 ipc]: /zh/newsletters/2024/09/13/#bitcoin-core-30509
[news323 ipc]: /zh/newsletters/2024/10/04/#bitcoin-core-30510
[news319 ban]: /zh/newsletters/2024/09/06/#lnd-9009
