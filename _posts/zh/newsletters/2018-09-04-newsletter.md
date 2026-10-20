---
title: 'Bitcoin Optech Newsletter #11'
permalink: /zh/newsletters/2018/09/04/
name: 2018-09-04-newsletter-zh
slug: 2018-09-04-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周 Newsletter 包括请帮助测试 Bitcoin Core 下一版本发布候选版本的提醒、关于 Optech 新公共仪表盘开发情况的信息、Bitcoin-Dev 邮件列表上两场讨论的摘要，以及比特币基础设施项目中值得注意的提交。

## 行动项

- **<!--allocate-time-to-test-bitcoin-core-0-17rc2-->****安排时间测试 Bitcoin Core 0.17 RC2：** Bitcoin Core 已经上传了 0.17 候选版本（RC）2 的[二进制文件][bcc 0.17]。我们非常欢迎你参与测试，这有助于保证最终版本的质量。

## 仪表盘项

- **<!--optech-dashboard-->****Optech 仪表盘：** Marcin Jachymiak 在[博客文章][dashboard post]中介绍了他今年夏天实习期间为 Optech 开发的实时仪表盘，不仅概述了仪表盘能为你提供哪些信息，还说明了他是如何构建的，方便任何想独立复现这些数据、或用自己完整节点扩展仪表盘的人参考。

    Optech 团队的其他成员感谢 Marcin 的专注工作和敏锐洞察，并祝他在接下来的一年里一切顺利。

## 新闻

- **<!--discussion-of-resetting-testnet-->****关于重置测试网的讨论：** 比特币的第一个公共测试网于 2010 年末推出；几个月后它被重置为 testnet2；2012 年中又再次重置为当前的 testnet3。如今 testnet3 已有超过 140 万个区块，在存档节点上占用超过 20 GB 磁盘空间。Bitcoin-Dev 邮件列表上发起了一场[讨论][testnet reset]，主题是再次重置测试网，以便为实验提供一个更小的链。除了讨论拥有一条大型测试链供实验是否可取之外，还有人[建议][signed testnet]未来的测试网可以改用签名区块（signed blocks）而非工作量证明（proof of work），让链的运行比当前的 testnet3 更可预测——后者容易出现剧烈的哈希率波动。这样也能方便地组织测试网灾难演练，例如大规模链重组。

- **<!--proposed-sighash-updates-->****sighash 更新建议：** 在签名交易之前，比特币钱包会先计算未签名交易及其他一些数据的密码学哈希，然后不直接签名交易，而是对这个哈希签名。自 Bitcoin 0.1 的原始实现以来，钱包可以在签名前把未签名交易的某些部分从哈希中排除，这样其他人（例如多方合约中的其他参与方）就能修改交易的这些部分。

    在 [BIP143][] 中，隔离见证保留了 Bitcoin 0.1 的全部 sighash 标志，但对钱包纳入哈希的数据做了小幅（但有用）的调整，使矿工更难对其他矿工发起 DoS 攻击，也让硬件钱包这类算力有限的设备更容易保护用户资金。本周，BIP143 的合著者 Johnson Lau [提出][sighash changes]了一些 sighash 标志的修改建议，包括新增标志；这些改动可以利用隔离见证提供的见证脚本更新机制，以软分叉方式实现。

    {% comment %}<!-- for reference: numbers in following paragraph
    correspond to the numbered bullet points in Lau's email -->{%
    endcomment %}

    如果这些更改被采纳，比较显著的优点包括：让硬件钱包更容易安全地参与 coinjoin 式交易<!--#1-->以及其他智能合约<!--#2-->；多方交易中的任意一方都可能更容易地进行手续费追加（fee bumping）<!--#6-->；防止复杂智能合约的对手方和第三方在 DoS 攻击中膨胀多方交易的体积，从而拉低交易的手续费优先级。<!--#8-->

## 值得注意的提交

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo] 和 [C-lightning][core lightning repo] 中值得注意的提交。提醒：Bitcoin Core 的新合并都进入主开发分支，不太可能成为即将发布的 0.17 版本的一部分——你大概要等到约六个月后的 0.18 版本。*

{% comment %}<!-- LND only had three merges this week, none of them exciting IMO -harding -->{% endcomment %}

- [Bitcoin Core #12952][]：内置账户系统被弃用已有几个大版本，并在即将发布的 0.17 中默认禁用；现在它已从主开发分支移除。账户系统于 2010 年末加入，目的是让早期的比特币交易所能在 Bitcoin Core 中管理用户账户，但它缺少许多真正生产系统所需的特性（例如原子化的数据库更新），还经常让用户困惑，因此稳妥地移除它已经成为几年来的目标。

- [Bitcoin Core #13987][]：当 Bitcoin Core 收到一笔每 vbyte 手续费低于自身最低费率的交易时，就会忽略它。[BIP133][]（在 Bitcoin Core 0.13.0 中实现）允许节点把自己的最低费率告知对等节点，这样对等节点就不会浪费带宽发送会被忽略的交易。此 PR 现在通过新增的 `minfeefilter` 值，在 [getpeerinfo][rpc getpeerinfo] RPC 中为每个对等节点提供这一信息，让你可以轻松查出对等节点正在使用的最低费率。

- [C-Lightning #1887][]：现在你可以给 `feerate` 参数传入“urgent”、“normal” 或 “slow”，让 lightningd 为你的链上交易计算一个目标费率。或者，你也可以用这个参数手动指定想要使用的特定费率。

{% include references.md %}
{% include linkers/issues.md issues="12952,13987,1887" %}

[bcc 0.17]: https://bitcoincore.org/bin/bitcoin-core-0.17.0/
[dashboard post]: /zh/dashboard-announcement/
[testnet reset]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016337.html
[signed testnet]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016348.html
[sighash changes]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016345.html
