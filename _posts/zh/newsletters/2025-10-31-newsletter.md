---
title: 'Bitcoin Optech Newsletter #378'
permalink: /zh/newsletters/2025/10/31/
name: 2025-10-31-newsletter-zh
slug: 2025-10-31-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报公布了影响旧版本 Bitcoin Core 全节点的四个漏洞。此外还包括我们的常规部分：总结了 Bitcoin Stack Exchange 的热门问题和答案、新版本和候选版本的公告，以及对热门比特币基础设施软件的重大变更介绍。

## 新闻

- **<!--disclosure-of-four-low-severity-vulnerabilities-in-bitcoin-core-->****Bitcoin Core 四个低严重性漏洞的披露：**
  Antoine Poinsot 最近在 Bitcoin-Dev 邮件列表上[发布][poinsot disc]了四个 Bitcoin Core 安全公告，涉及在 Bitcoin Core 30.0 中修复的低严重性漏洞。根据[披露政策][disc pol]（参见[周报 #306][news306 disclosures]），低严重性漏洞在包含修复的主要版本发布两周后披露。披露的四个漏洞如下：

  * [<!--disk-filling-from-spoofed-self-connections-->通过欺骗自连接填充磁盘空间][CVE-2025-54604]：此漏洞允许攻击者通过伪造自连接来填满受害者节点的磁盘空间。该漏洞于 2022 年 3 月由 Niklas Gögge [负责地披露][topic responsible disclosures]。Eugene Siegel 和 Niklas Gögge 于 2025 年 7 月合并了缓解措施。

  * [<!--disk-filling-from-invalid-blocks-->通过无效区块填充磁盘空间][CVE-2025-54605]：此漏洞允许攻击者通过重复发送无效区块来填满受害者节点的磁盘空间。此漏洞于 2022 年 5 月由 Niklas Gögge 负责披露，并于 2025 年 3 月由 Eugene Siegel 独立发现。Eugene Siegel 和 Niklas Gögge 于 2025 年 7 月合并了缓解措施。

  * [<!--highly-unlikely-remote-crash-on-32-bit-systems-->32 位系统上极不可能的远程崩溃][CVE-2025-46597]：此漏洞可能导致节点在接收到病态区块时在罕见边缘情况下崩溃。此漏洞于 2025 年 4 月由 Pieter Wuille 负责披露。Antoine Poinsot 于 2025 年 6 月实施并合并了缓解措施。

  * [<!--cpu-dos-from-unconfirmed-transaction-processing-->未确认交易处理导致的 CPU DoS][CVE-2025-46598]：此漏洞会在处理未确认交易时导致资源耗尽。此漏洞于 2025 年 4 月由 Antoine Poinsot 在邮件列表上报告。Pieter Wuille、Anthony Towns 和 Antoine Poinsot 于 2025 年 8 月实施并合并了缓解措施。

  前三个漏洞的补丁也包含在 Bitcoin Core 29.1 及后续的次要版本中。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选之地，也是我们有闲暇时会给好奇和困惑的用户帮忙的地方。在这个月度栏目中，我们会列举自上次出刊以来出现的一些高票的问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--why-was-datacarriersize-redefined-in-2022-and-why-was-the-2023-proposal-to-expand-it-not-merged-->为什么 -datacarriersize 在 2022 年被重新定义，为什么 2023 年扩展它的提议没有被合并？]({{bse}}128027)
  Pieter Wuille 提供了 Bitcoin Core 的 `-datacarriersize` 选项在 `OP_RETURN` 输出方面范围的历史概述。

- [<!--what-is-the-smallest-valid-transaction-that-can-be-included-in-a-block-->可以包含在区块中的最小有效交易是什么？]({{bse}}129137)
  Vojtěch Strnad 列举了构成最小可能有效比特币交易的最少字段和大小。

- [<!--why-does-bitcoin-core-continue-to-give-witness-data-a-discount-even-when-it-is-used-for-inscriptions-->为什么 Bitcoin Core 即使在见证数据用于铭文时也继续给予见证数据折扣？]({{bse}}128028)
  Pieter Wuille 解释了 segwit 见证数据折扣的理论依据，并强调 Bitcoin Core 软件实施了比特币当前的共识规则。

- [<!--the-ever-growing-bitcoin-blockchain-size-->不断增长的比特币区块链大小？]({{bse}}128048)
  Murch 指出了当前 UTXO 集的大小、修剪节点和全节点的存储要求，并指出了比特币区块链当前的增长率。

- [<!--i-read-that-op-templatehash-is-a-variant-of-op-ctv-how-do-they-differ-->我读到 OP_TEMPLATEHASH 是 OP_CTV 的变体。它们有何不同？]({{bse}}128097)
  Rearden 对比了 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] 和最近提议的 `OP_TEMPLATEHASH` 提议（参见[周报 #365][news365 op_templatehash]）在能力、效率、兼容性和哈希字段方面的差异。

## 新版本和候选版本

*热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [LND 0.20.0-beta.rc1][] 是这个热门闪电网络节点的候选版本。一个将受益于测试的改进是修复过早钱包重新扫描的问题，在下面的重大代码变更部分有描述。更多详情请参见[版本说明][LND notes]。

- [Eclair 0.13.1][] 是这个闪电网络节点实现的次要版本。此版本包含数据库变更，为移除前[锚点输出][topic anchor outputs]通道做准备。您需要先运行 v0.13.0 版本，以将通道数据迁移到最新的内部编码。

## 重大的代码和文档变更

*本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals（BIPs）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Bitcoin Core #29640][] 为具有相同工作量的竞争链上的区块在启动时重新初始化 `nSequenceId` 值：属于之前已知最佳链的区块为 0，所有其他加载的区块为 1。这解决了 Bitcoin Core 无法在两个竞争链之间进行平局决胜的问题，因为 `nSequenceId` 值在重启后不会持久化。

- [Core Lightning #8400][] 为所有新节点默认引入了新的 [BIP39][] 助记词备份格式用于 `hsm_secret`，可选密码短语，同时在现有节点上保持对传统 32 字节 `hsm_secrets` 的支持。`Hsmtool` 也更新为支持基于助记词和传统密钥。为钱包引入了新的标准 [taproot][topic taproot] 派生格式。

- [Eclair #3173][] 移除了对不使用[锚点输出][topic anchor outputs]或 [taproot][topic taproot] 的传统通道的支持，也称为 `static_remotekey` 或 `default` 通道。用户应在升级到版本 0.13 或 0.13.1 之前关闭任何剩余的传统通道。

- [LND #10280][] 现在会等待区块头同步后再启动链通知器（参见[周报 #31][news31 chain]）以重新扫描链上的钱包交易。这解决了在创建新钱包时，LND 会在区块头仍在同步时触发过早重新扫描的问题。这主要影响 [Neutrino 后端][topic compact block filters]。

- [BIPs #2006][] 更新了 [BIP3][] 的规范（参见[周报 #344][news344 bip3]），添加了关于原创性和质量的指导，特别建议作者避免使用 AI/LLM 生成内容，并鼓励主动披露 AI/LLM 使用情况。

- [BIPs #1975][] 更新了 [BIP155][]，该 BIP 规定了比特币 P2P 网络协议中 `addr` 消息的新版本 [addr v2][topic addr v2]，添加了 [Tor v2][topic anonymity networks] 不再运行的说明。

{% include snippets/recap-ad.md when="2025-11-04 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29640,8400,3173,10280,5516,2006,1975" %}

[poinsot disc]: https://groups.google.com/g/bitcoindev/c/sBpCgS_yGws
[disc pol]: https://bitcoincore.org/en/security-advisories/
[news306 disclosures]: /zh/newsletters/2024/06/07/#upcoming-disclosure-of-vulnerabilities-affecting-old-versions-of-bitcoin-core
[CVE-2025-54604]: https://bitcoincore.org/en/2025/10/24/disclose-cve-2025-54604/
[CVE-2025-54605]: https://bitcoincore.org/en/2025/10/24/disclose-cve-2025-54605/
[CVE-2025-46597]: https://bitcoincore.org/en/2025/10/24/disclose-cve-2025-46597/
[CVE-2025-46598]: https://bitcoincore.org/en/2025/10/24/disclose-cve-2025-46598/
[LND 0.20.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.0-beta.rc2
[LND notes]: https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/release-notes-0.20.0.md
[Eclair 0.13.1]: https://github.com/ACINQ/eclair/releases/tag/v0.13.1
[news31 chain]: /zh/newsletters/2019/01/29/#lnd-2314
[news344 bip3]: /zh/newsletters/2025/03/07/#bips-1712
[news365 op_templatehash]: /zh/newsletters/2025/08/01/#taproot-native-op-templatehash-proposal
