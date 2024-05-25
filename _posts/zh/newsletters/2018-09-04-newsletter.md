---
title: 'Bitcoin Optech Newsletter #11'
permalink: /zh/newsletters/2018/09/04/
name: 2018-09-04-newsletter-zh
slug: 2018-09-04-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周 Newsletter 包括请帮助测试 Bitcoin Core 下一个版本的候选发布版本的提醒、关于 Optech 新公共仪表盘开发的信息、两个在 Bitcoin-Dev邮件列表上的讨论摘要以及比特币基础设施项目值得注意的提交。

## 行动项

- **<!--allocate-time-to-test-bitcoin-core-0-17rc2-->****分配时间测试 Bitcoin Core 0.17RC2：** Bitcoin Core 已经上传了 0.17RC2 的[二进制文件][bcc 0.17]。测试非常受欢迎，可以帮助确保最终发布版本的质量。

## 仪表盘项

- **<!--optech-dashboard-->****Optech 仪表盘：** Marcin Jachymiak 在[博客文章][dashboard post]中介绍了他在今年夏天的实习期间为 Optech 开发的实时仪表盘，不仅提供了仪表盘为您提供的信息概览，还描述了他的构建过程，以便任何希望独立复制数据或使用自己的完整节点扩展仪表盘的人。

    Optech 团队的其他成员感谢 Marcin 的专心工作和敏锐的洞察力，并祝他在未来的一年中一切顺利。

## 新闻

- **<!--discussion-of-resetting-testnet-->****关于重置测试网的讨论：** 比特币的第一个公共测试网于 2010 年末引入；几个月后，它被重置为 testnet2；并于 2012 年中再次重置为当前的 testnet3。如今，testnet3 拥有超过 140 万个区块，并在存档节点上消耗超过 20GB 的磁盘空间。在 Bitcoin-Dev 邮件列表上开始了一场关于再次重置测试网以提供一个更小的链进行实验的[讨论][testnet reset]。除了讨论是否有必要拥有一个大的测试链供实验之外，还有人[建议][signed testnet]未来的测试网可能会想使用签名区块（signed blocks）而不是工作量证明（proof of work）来使链的运作比当前的 testnet3 更加可预测，后者容易受到疯狂的哈希率波动的影响。这也将允许轻松管理测试网的灾难演练，如大型链重组。

- **<!--proposed-sighash-updates-->****建议的 sighash 更新：** 在签名交易之前，比特币钱包会创建未签名交易和一些其他数据的加密哈希。然后，钱包不是直接签名交易，而是签名该哈希。自原始 Bitcoin 0.1 实现以来，钱包被允许在签名前从哈希中移除某些部分的未签名交易，这允许这些部分的交易由其他人更改，如多方合约中的其他参与者。

    在 [BIP143][] 中，隔离见证保留了所有原始 Bitcoin 0.1 的 sighash 标志，但对包含在哈希中的钱包数据进行了一些小的（但有用的）更改，这使得矿工更难对其他矿工进行 DoS 攻击，并使得如硬件钱包这样的低功耗设备更容易保护用户资金。本周，BIP143 的合著者 Johnson Lau [发布][sighash changes]一些对 sighash 标志的建议更改，包括新的标志，这些可以作为软分叉使用隔离见证提供的见证脚本更新机制来实现。

    {% comment %}<!-- for reference: numbers in following paragraph
    correspond to the numbered bullet points in Lau's email -->{%
    endcomment %}

    如果这些更改被采纳，一些显著的优点包括：使硬件钱包更容易安全地参与 CoinJoin 式交易<!--#1-->以及其他智能合约<!--#2-->，潜在地通过多方交易中的任何单独一方更容易地增加费用<!--#6-->，并防止复杂智能合约的对手方和第三方通过 DoS 攻击增加多方交易的大小，从而降低交易的费用优先级。<!--#8-->

## 值得注意的提交

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo] 和 [C-lightning][core lightning repo] 中的值得注意的提交。提醒：新合并到 Bitcoin Core 的代码是提交到其主开发分支的，不太可能成为即将发布的 0.17 版本的一部分——你可能需要等到大约六个月后的 0.18 版本。*

{% comment %}<!-- 本周 LND 只有三次合并，个人觉得都不太激动人心 -harding -->{% endcomment %}

- [Bitcoin Core #12952][]：在经过几个主要版本的弃用并且在即将发布的 0.17 版本中默认禁用后，Bitcoin Core 的内置账户系统已从主开发分支中移除。账户系统于 2010 年末添加，以允许早期的比特币交易所在 Bitcoin Core 中管理其用户账户，但它缺少许多真正生产系统所需的特性（如原子数据库更新），并且经常让用户感到困惑，因此逐步移除它已经是几年来的一个目标。

- [Bitcoin Core #13987][]：当 Bitcoin Core 收到一个每 vbyte 费用低于其最低费率的交易时，它会忽略该交易。[BIP133][]（在 Bitcoin Core 0.13.0 中实现）允许节点告知其对等节点其最低费率，以便那些对等节点不会浪费带宽发送将被忽略的交易。此 PR 现在为 [getpeerinfo][rpc getpeerinfo] RPC 中的每个对等节点提供了该信息，使用新的 `minfeefilter` 值，允许您轻松发现您的对等节点正在使用的最小费率。

- [C-Lightning #1887][] 现在允许您请求 lightningd 为您的链上交易计算一个费率目标，通过传递 "urgent"、"normal" 或 "slow" 给 `feerate` 参数。或者，您也可以使用此参数手动指定您想要使用的特定费率。

{% include references.md %}
{% include linkers/issues.md issues="12952,13987,1887" %}

[bcc 0.17]: https://bitcoincore.org/bin/bitcoin-core-0.17.0/
[dashboard post]: /zh/dashboard-announcement/
[testnet reset]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016337.html
[signed testnet]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016348.html
[sighash changes]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016345.html
