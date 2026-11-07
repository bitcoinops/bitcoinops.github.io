---
title: 'Bitcoin Optech Newsletter #193'
permalink: /zh/newsletters/2022/03/30/
name: 2022-03-30-newsletter-zh
slug: 2022-03-30-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 介绍了一项提议：让 Bitcoin Core 允许在内存池中替换交易的见证，并总结了围绕更新 LN gossip 协议的持续讨论。此外，我们的常规栏目还包括 Bitcoin Stack Exchange 精选问答、新版本与候选版本的公告，以及对热门比特币基础设施项目中值得注意的变更的描述。

## 新闻

- **<!--transaction-witness-replacement-->****交易见证替换：**
  Larry Ruane 在 [Bitcoin-Dev 邮件列表][ruane witrep]上征求意见，讨论是否允许用见证更小（因此 wtxid 不同）但 txid 相同的交易来替换原有交易。Ruane 想了解目前是否已有应用会创建见证大小可能变化的交易（例如从 [taproot][topic taproot] 脚本路径支出切换到密钥路径支出），而其他交易细节（例如输出地址或金额）保持不变。

  如果现有或拟议中的应用能够从见证替换中获益，Ruane 还想听取意见：见证需要缩小多少才应允许替换。要求的缩小幅度越大，可被替换的交易就越少——从而在最坏情况下限制攻击者可浪费的节点带宽。但要求更大的缩小幅度，也会让应用无法通过见证替换获得较小或中等程度的节省。

- **<!--continued-discussion-about-updated-ln-gossip-protocol-->****关于更新 LN gossip 协议的持续讨论：**
  正如 [Newsletter #188][news188 gossip] 所报道，LN 协议开发者正在讨论如何修订用来播报可用支付通道信息的 LN gossip 协议。本周出现了两个活跃的讨论帖：

  - **<!--major-update-->***重大更新：*
    在对 Rusty Russell 上月提出的[重大更新方案][russell gossip2]的[回应][osuntokun gossip1.1]中，Olaoluwa Osuntokun 多次表达了对该方案中一项内容的担忧——该内容会在链上资金与某个具体 LN 通道之间引入合理推诿（plausible deniability）。这一特性也会让非 LN 用户更容易宣称某些实际可能并不存在的通道存在，从而削弱付款方在网络中找到一条通往收款节点的可用路径的能力。

  - **<!--minor-update-->***小幅更新：*
    Osuntokun 另行[发帖][osuntokun gossip2]，提出了一个规模小得多的 gossip 协议更新提案，主要目的是支持基于 taproot 的通道。该提案使用 [MuSig2][topic musig]，让单个签名即可证明与所涉四个公钥（两个节点标识密钥、两个通道支出密钥）相关的授权，并且很可能要求通道建立交易可用 MuSig2 花费。

    他还建议在通道公告消息中增加一条 SPV 部分默克尔分支证明，用于证明通道建立交易已被纳入某个区块，从而使轻客户端无需下载包含该交易的整个区块就能验证其存在。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们有点空闲时帮助好奇或困惑用户的地方。在本月栏目中，我们精选自上次更新以来得票最高的一些问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--what-are-the-advantages-or-disadvantages-to-address-reuse-->**[地址重用的优缺点是什么？]({{bse}}112955)
  RedGrittyBrick 与 Pieter Wuille 列举了地址重用的弊端，包括隐私影响以及关于公钥暴露的可争议问题。Wuille 补充指出，虽然生成新地址没有额外的经济成本，但会增加钱包软件、备份和可用性方面的复杂度。

- **<!--what-is-a-block-relay-only-connection-and-what-is-it-used-for-->**[什么是仅区块中继连接，它有何用途？]({{bse}}112828)
  用户 vnprc 将仅区块中继连接描述为只中继区块信息、而不中继交易或潜在对等节点网络地址的对等节点。这类连接通过提高确定比特币网络拓扑图的难度，帮助抵御分区攻击（又称 [eclipse][topic eclipse attacks] 攻击）。vnprc 还介绍了锚定连接——一种节点重启后仍会保持的仅区块中继连接，可进一步抵抗 日食攻击。

- **<!--is-timestamping-needed-for-anything-except-difficulty-adjustment-->**[除了难度调整之外，时间戳还有其他用途吗？]({{bse}}112929)
  Pieter Wuille 解释了区块头 `nTime` 时间戳字段的限制（必须大于 [Median Time Past (MTP)][news146 mtp]，且不得超过未来两小时），并指出区块时间戳用于[难度][wiki difficulty]计算和交易[时间锁][topic timelocks]。

- **<!--how-are-attempts-to-spend-from-a-timelocked-utxo-rejected-->**[对带有时间锁的 UTXO 的花费尝试是如何被拒绝的？]({{bse}}112989)
  Pieter Wuille 区分了通过交易的 `nLockTime` 字段实现的锁定时间，与通过 Script 的 [`OP_CHECKLOCKTIMEVERIFY`][BIP65] 操作码强制执行的时间锁。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [BDK 0.17.0][BDK 0.17.0] 是用于构建比特币钱包的这个库的一个新版本。此版本的改进应能让钱包即便离线也更容易派生地址。

- [Bitcoin Core 23.0 RC2][Bitcoin Core 23.0 RC2] 是这一主流全节点软件下一主要版本的候选发布。[发布说明草案][bcc23 rn]列出了多项改进，鼓励高级用户与系统管理员在最终发布前进行[测试][test guide]。

- [LND 0.14.3-beta.rc1][LND 0.14.3-beta.rc1] 是这款流行 LN 节点软件的一个候选发布版本，包含若干缺陷修复。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]中值得注意的变更。*

- [C-Lightning #5078][C-Lightning #5078] 让节点能够有效利用与同一对等节点之间的多条通道，包括在另一条通道是更好选择时，把支付路由到与路由消息中指定的通道不同的通道（但对等节点相同）。

- [C-Lightning #5103][C-Lightning #5103] 新增 `setchannel` 命令，可配置特定通道的路由费率、最小支付金额和最大支付金额。该命令取代了 `setchannelfee` 命令，后者现已弃用。

- [C-Lightning #5058][C-Lightning #5058] 移除了对原始固定长度洋葱数据格式的支持，[BOLTs #962][BOLTs #962] 也提议从 LN 规范中删除该格式。升级后的可变长度格式在近三年前已[加入规范][bolts #619]，而 BOLTs #962 PR 中提到的网络扫描结果显示，在超过 17,000 个公开公告的节点中，除 5 个之外全都支持该格式。

- [LND #5476][LND #5476] 更新了 `GetTransactions` 与 `SubscribeTransactions` 这两个 RPC 的返回结果，新增关于所创建输出的详细信息，包括支付的金额与脚本，以及该地址（脚本）是否属于内部钱包。

- [LND #6232][LND #6232] 新增一项配置项，可要求所有 [HTLC][topic htlc] 都由注册在 HTLC 拦截器钩子上的插件处理。这确保在 HTLC 拦截器有机会注册之前，不会有任何 HTLC 被接受或拒绝。HTLC 拦截器允许调用外部程序来检查某个 HTLC（支付），并判断应当接受还是拒绝。


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
