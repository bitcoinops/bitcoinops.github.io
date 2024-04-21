---
title: 'Bitcoin Optech Newsletter #296'
permalink: /zh/newsletters/2024/04/03/
name: 2024-04-03-newsletter-zh
slug: 2024-04-03-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报总结了有关新的共识清理软分叉的讨论，并宣布计划在本周末之前选择更多的 BIP 编辑。此外，还包括我们的常规部分：其中包括新版本的公告以及对热门比特币基础设施项目的重大变更介绍。

## 新闻

- **<!--Revisiting-consensus-cleanup-->重新审视共识清理：** Antoine Poinsot 在 Delving Bitcoin 上[发布了][poinsot cleanup]关于重新审视 Matt Corallo 在 2019 年提出的[共识清理][topic consensus cleanup]提议的文章(见[周报 #36][news36 cleanup])。他首先试图量化该提议可能修复的几个问题的最坏情况，包括：能够创建在现代笔记本电脑上需要超过 3 分钟来验证，而在树莓派 Pi4 上需要 90 分钟来验证的区块；矿工以大约一个月的准备时间来发动[时间扭曲攻击][topic time warp]，就可以窃取区块补贴并使闪电网络（LN）不安全；能够欺骗轻节点接受虚假交易([CVE-2017-12842][topic cves])并混淆全节点拒绝有效区块(见[周报 #37][news37 trees])。

  除了 Corallo 在最初共识清理中提出的上述问题外，Poinsot 还建议解决剩余的[重复交易][topic duplicate transactions]问题，该问题将在区块 1,983,702 时开始影响全节点(并且已经影响了 testnet 节点)。

  上述所有问题都有技术上简单的解决方案，并可以通过软分叉进行部署。之前提出的解决慢速验证区块的方案曾有一些争议，因为理论上可能会使一些已被使用的预签名交易脚本无效，这可能违反了[防止被充公][topic accidental confiscation]的开发政策(见[周报 #37][news37 confiscation])。我们没有发现这种脚本的任何实际使用，无论是在共识清理初版提议提出以前的 10 年中，还是在之后的 5 年中；尽管在预签名交易被广播之前，某些类型的使用是无法检测到的。

  为了解决这一问题，Poinsot 提出，更新后的共识规则只适用于在特定区块高度之后创建的交易输出。早于该高度创建的任何输出仍然可以根据旧规则进行支付。

- **<!--Choosing-new-BIP-editors-->选择新的 BIP 编辑：** Mark "Murch" Erhardt 继续关于添加新 BIP 编辑的[帖子][erhardt bip editors]，建议每个人在周五（4 月 5 日）结束之前表达“他们支持和反对任何候选人的论点”。如果任何候选人获得广泛支持，这些候选人可以在下周一（4月8日）作为新编辑加入库。

    在撰写本文时，讨论正在进行中，我们将尽最大努力在下周的周报中报告结果。

## 版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Bitcoin Core 26.1][] 是网络主要全节点实现的维护版本。其[版本说明][26.1 rn]描述了几个错误修复。

- [Bitcoin Core 27.0rc1][] 是网络主要全节点实现的下一个主要版本的候选版本。鼓励测试人员审核[推荐测试主题列表][bcc testing]。

- [HWI 3.0.0-rc1][] 是此软件包下一版本的候选版本，为多个不同的硬件签名设备提供通用接口。

## 重大的代码和文档变更

_本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。_

*注意：下面提到的对 Bitcoin Core 的提交适用于其主开发分支，因此这些更改可能要到即将发布的版本 27 发布后大约六个月才会发布。*

- [Bitcoin Core #27307][] 开始跟踪交易池中与属于 Bitcoin Core 内置钱包的交易相冲突的交易的 txid。这包括交易池中与钱包交易的祖先交易冲突的交易。如果冲突交易得到确认，则钱包交易将无法包含在该区块链上，因此了解冲突非常有用。现在，在钱包交易上调用`gettransaction` 时，冲突的交易池交易会显示在新的 `mempoolconflicts` 字段中。对于冲突于交易池的交易，其输入可以重新使用而无需手动放弃该冲突交易，并且重新使用的输入会计入钱包的余额。

- [Bitcoin Core #29242][] 引入了实用函数来比较两个[费率表][sdaftuar incentive compatibility]，并评估用最多两笔交易替换族群的激励兼容性。这些函数为使用最多 2 个交易的族群，包括 “[确认之前拓扑受限 (TRUC) 交易][TRUC BIP draft] (也称为[v3 交易][topic v3 transaction relay])” 的[交易包][topic package relay]进行[手续费替换][topic rbf]奠定了基础。

- [Core Lightning #7094][] 使用 Core Lightning 新的弃用系统（见[周报 #288][news288 cln deprecation]）删除了以前已被弃用的多个功能。

- [BDK #1351][] 对 BDK 解释 `stop_gap` 参数的方式进行了几项更改，该参数控制其 [gap limit][topic gap limits] 行为。其中一项更改特别试图与其他钱包的行为相匹配，在 `stop_gap` 限制为 10 时，BDK 会不断生成新地址以扫描交易，直到连续的 10 个地址都没有发现匹配的交易为止。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="27307,29242,7094,1351" %}
[bitcoin core 26.1]: https://bitcoincore.org/bin/bitcoin-core-26.1/
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/27.0-Release-Candidate-Testing-Guide
[Bitcoin Core 27.0rc1]: https://bitcoincore.org/bin/bitcoin-core-27.0/test.rc1/
[poinsot cleanup]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710
[news36 cleanup]: /en/newsletters/2019/03/05/#cleanup-soft-fork-proposal
[news37 confiscation]: /en/newsletters/2019/03/12/#cleanup-soft-fork-proposal-discussion
[erhardt bip editors]: https://gnusha.org/pi/bitcoindev/52a0d792-d99f-4360-ba34-0b12de183fef@murch.one/
[sdaftuar incentive compatibility]: https://delvingbitcoin.org/t/mempool-incentive-compatibility/553
[TRUC BIP draft]: https://github.com/bitcoin/bips/pull/1541
[news288 cln deprecation]: /zh/newsletters/2024/02/07/#core-lightning-6936
[26.1 rn]: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-26.1.md
[HWI 3.0.0-rc1]: https://github.com/bitcoin-core/HWI/releases/tag/3.0.0-rc.1
[news37 trees]: /en/newsletters/2019/03/12/#bitcoin-core-vulnerability-disclosure
