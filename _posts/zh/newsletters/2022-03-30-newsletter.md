---
title: 'Bitcoin Optech Newsletter #193'
permalink: /zh/newsletters/2022/03/30/
name: 2022-03-30-newsletter-zh
slug: 2022-03-30-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 介绍了一项提议：Bitcoin Core 允许在其内存池中替换交易见证，并总结了有关更新 LN gossip 协议的持续讨论。此外，我们的常规栏目还包括 Bitcoin Stack Exchange 精选问答、新版本和候选版本的公告，以及对热门比特币基础设施项目值得注意的变更描述。

## 新闻

- **<!--transaction-witness-replacement-->****交易见证替换：**
  Larry Ruane 在 [Bitcoin-Dev 邮件列表][ruane witrep]上征求意见，讨论是否允许用见证更小（因此 wtxid 不同）但 txid 相同的交易来替换原有交易。Ruane 想了解目前是否已有应用会创建见证大小可能变化的交易（例如从 [taproot][topic taproot] 脚本路径支出切换到密钥路径支出），而其他交易细节（例如输出地址或金额）保持不变。

  如果现有或拟议中的应用能够从见证替换中获益，Ruane 还希望了解见证需要缩小多少才应允许替换。要求缩小幅度越大，可被替换的交易就越少——从而在最坏情况下限制攻击者浪费节点带宽。但如果要求过高，也会阻止应用通过见证替换获得较小或中等程度的节省。

- **<!--continued-discussion-about-updated-ln-gossip-protocol-->****关于更新 LN gossip 协议的持续讨论：**
  正如 [Newsletter #188][news188 gossip] 所报道，LN 协议开发者正在讨论如何修订用来播报可用支付通道信息的 LN gossip 协议。本周出现了两个活跃的讨论线程：

  - **<!--major-update-->***重大更新：*
    在对 Rusty Russell 上月提出的[重大更新方案][russell gossip2]的[回应][osuntokun gossip1.1]中，Olaoluwa Osuntokun 多次表达了对该方案中一项内容的担忧——它会在链上资金与特定 LN 通道之间引入可信否认。这一特性也会让非 LN 用户更容易宣称某些并不存在的通道存在，从而削弱付款方在网络中找到有效路径并向收款节点付款的能力。

  - **<!--minor-update-->***小幅更新：*
    Osuntokun 提出了另一份[更小范围的更新提案][osuntokun gossip2]，主要目的是支持基于 taproot 的通道。该提案使用 [MuSig2][topic musig]，通过单个签名即可证明与四个公钥（两个节点标识公钥、两个通道支出公钥）相关的授权，并可能要求通道建立交易可使用 MuSig2 进行支出。

    他还建议在通道公告消息中增加一条 SPV 部分默克尔分支证明，用于证明通道建立交易已被纳入某个区块，从而使轻客户端无需下载包含该交易的整个区块就能验证其存在。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找答案的首选之地之一——当我们有空时也会在那里帮助求助用户。在这一月度专栏中，我们精选自上次更新以来得票最高的一些问答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--what-are-the-advantages-or-disadvantages-to-address-reuse-->**[地址重用的优缺点是什么？]({{bse}}112955)
  RedGrittyBrick 与 Pieter Wuille 列举了地址重用的弊端，包括隐私影响以及关于公钥暴露的可争议问题。Wuille 补充指出，虽然生成新地址没有额外的经济成本，但会增加钱包软件、备份和可用性方面的复杂度。

- **<!--what-is-a-block-relay-only-connection-and-what-is-it-used-for-->**[什么是仅区块中继连接，它有何用途？]({{bse}}112828)
  用户 vnprc 将仅区块中继连接描述为只转发区块信息而不转发交易或潜在对等节点网络地址的连接。这类连接通过增加确定比特币网络拓扑图难度来帮助抵御分区（亦称为 [eclipse][topic eclipse attacks]）攻击。vnprc 还介绍了锚定连接——一种节点重启后仍会保持的仅区块中继连接，可进一步抵抗 eclipse 攻击。

- **<!--is-timestamping-needed-for-anything-except-difficulty-adjustment-->**[除了难度调整之外，时间戳还有其他用途吗？]({{bse}}112929)
  Pieter Wuille 解释了区块头 `nTime` 时间戳字段的限制（必须大于 [Median Time Past (MTP)][news146 mtp]，且不得超过未来两小时），并指出区块时间戳用于[难度][wiki difficulty]计算和交易 [timelocks][topic timelocks]。

- **<!--how-are-attempts-to-spend-from-a-timelocked-utxo-rejected-->**[尝试花费带 timelock 的 UTXO 时是如何被拒绝的？]({{bse}}112989)
  Pieter Wuille 区分了通过交易字段 `nLockTime` 进行的锁定时间与通过 Script 的 [`OP_CHECKLOCKTIMEVERIFY`][BIP65] 操作码强制的 timelock。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选版本。请考虑升级至新版本，或帮助测试候选版本。*

- [BDK 0.17.0][BDK 0.17.0]
  这是用于构建比特币钱包的库的新版本。此次改进使钱包即便离线也更容易派生地址。

- [Bitcoin Core 23.0 RC2][Bitcoin Core 23.0 RC2]
  这是这一主流全节点软件下一主要版本的候选发布。[草案发行说明][bcc23 rn]列出了多项改进，鼓励高级用户与系统管理员在最终发布前进行[测试][test guide]。

- [LND 0.14.3-beta.rc1][LND 0.14.3-beta.rc1]
  这一候选版本为这款流行的 LN 节点软件带来了数个错误修复。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]项目中的值得注意变更。*

- [C-Lightning #5078][C-Lightning #5078]
  该变更使节点能够更高效地使用与同一对等节点建立的多条通道，包括在路由消息指定的通道不可用或效果不佳时，改用同一对等节点的其他通道来转发付款。

- [C-Lightning #5103][C-Lightning #5103]
  新增 `setchannel` 命令，可设置特定通道的路由费率、最小付款金额和最大付款金额。此命令取代已弃用的 `setchannelfee`。

- [C-Lightning #5058][C-Lightning #5058]
  移除了对原始固定长度洋葱数据格式的支持，该格式也在 [BOLTs #962][BOLTs #962] 中被提议从 LN 规范中删除。可变长度格式在近三年前已被[加入规范][bolts #619]。BOLTs #962 PR 中提到的网络扫描结果显示，在超过 17,000 个公开节点中，只有 5 个节点仍未支持该格式。

- [LND #5476][LND #5476]
  更新了 `GetTransactions` 与 `SubscribeTransactions` RPC 结果，新增关于输出的详细信息，包括支付金额与脚本，以及该地址（脚本）是否属于内部钱包。

- [LND #6232][LND #6232]
  新增一项配置，可要求所有 [HTLCs][topic htlc] 都由注册在 HTLC 拦截器挂钩上的插件处理。这确保在 HTLC 拦截器有机会注册之前，不会接受或拒绝任何 HTLC。HTLC 拦截器允许调用外部程序来检查 HTLC（付款）并决定是否接受或拒绝。


{% include references.md %}
{% include linkers/issues.md v=1 issues="5078,5103,5058,962,619,5476,6232" %}
[bitcoin core 23.0 rc2]: https://bitcoincore.org/bin/bitcoin-core-23.0/
[bdk 0.17.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.17.0
[lnd 0.14.3-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.14.3-beta.rc1
[bcc23 rn]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/23.0-Release-Notes-draft
[ruane witrep]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-March/020167.html
[osuntokun gossip2]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-March/003526.html
[osuntokun gossip1.1]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-March/003527.html
[news188 gossip]: /zh/newsletters/2022/02/23/#updated-ln-gossip-proposal
[russell gossip2]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-February/003470.html
[test guide]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/23.0-Release-Candidate-Testing-Guide
[wiki difficulty]: https://en.bitcoin.it/wiki/Difficulty
[news146 mtp]: /zh/newsletters/2021/04/28/#what-are-the-different-contexts-where-mtp-is-used-in-bitcoin
