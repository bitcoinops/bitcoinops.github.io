---
title: 'Bitcoin Optech Newsletter #3'
permalink: /zh/newsletters/2018/07/10/
name: 2018-07-10-newsletter-zh
slug: 2018-07-10-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
version: 1
---
本周的 Newsletter 包括有关最低费用和即将发布的 Bitcoin Core 版本的新闻和行动项，关于 Schnorr 签名提案的特别专题，以及最近在里斯本举行的 Building on Bitcoin 会议记录。

## 行动项

- **<!--bitcoin-core-minimum-relay-fee-->**在下一个主要版本中，Bitcoin Optech 的最小中继费用可能会降低。确保您的软件不会假设 1 satoshi/vbyte 是不安全的最低可能底线。有关更多信息，请参见下面的*新闻*部分。

- **<!--ensure-your-software-->**确保您用于计算动态费用交易大小的软件能够准确计算签名大小，或者至少使用比特币签名为 72 字节的最坏情况假设。有关更多信息，请参见下面的*新闻*部分。

- **<!--as-previous-newsletters-->**如之前的 Newsletter 所宣布的那样，比特币警报密钥已经[发布][alert released]，同时披露了影响 Bitcoin Core 0.12.0 及更早版本的漏洞。Altcoins 可能也会受到影响。如果您还没有检查您的基础设施以了解受影响的服务，建议您现在就这样做。有关更多详细信息，请查看 [Newsletter #1][newsletter #1]。

[alert released]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-July/016189.html
[newsletter #1]: /zh/newsletters/2018/06/26/

## 仪表盘项

- **<!--transaction-fees-remain-very-low-->****交易费用仍然非常低**：截至目前，对于未来 2 个或更多区块的确认的费用估算大约保持在 Bitcoin Core 默认最低中继费用的水平。这是一个[合并输入][consolidate inputs]的好时机。

[consolidate inputs]: https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#Consolidation

- **<!--block-production-recovery-->****区块生产恢复**：继上周关于中国洪水影响矿工运营的新闻之后，比特币区块生产似乎已恢复到大约每 10 分钟一个区块的预期水平。

## 特别新闻：Schnorr 签名提议 BIP

Pieter Wuille 在比特币开发者邮件列表中[发帖][schnorr post]，提交了一个基于 Schnorr 的[签名格式草案规范][schnorr draft]。该规范的目标是在实际软分叉开始之前，就比特币上的 Schnorr 签名的外观达成共识，因此 BIP 并未提出特定的新操作码、隔离见证标志、软分叉激活方法或其他任何将此变更纳入比特币共识规则所必需的内容。然而，如果这种签名格式成为比特币采用的 Schnorr 签名形式，我们可以说这种签名格式将提供：

[schnorr post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-July/016203.html
[schnorr draft]: https://github.com/sipa/bips/blob/bip-schnorr/bip-schnorr.mediawiki

1. 与现有的比特币私钥和公钥完全兼容，意味着现有的 HD 钱包升级不需要生成新的恢复种子。

2. 由于采用 Schnorr，签名大约减小 10%，稍微增加区块链容量。

3. 签名的批量验证提升大约 2 倍速，相比逐个验证一个全是  Schnorr 签名的区块。这主要影响从头同步或离线后的节点赶上。

4. 在使用多签的情况下，能完全压缩并显著改善隐私，但需要交互：不限数量的参与者可以使用其各自的公钥和签名的组合，创建一个 33 字节的公钥和 64 字节的签名，使用与单签同等效率的安全多签，并通过使多签看起来像单签来增加他们的隐私。然而，该方案要求参与多签的钱包在创建公钥和签名时进行多步骤交互。

5. 额外的关注隐私的使用情况。示例包括为闪电网络增加隐私、更私人的原子交换（不论是两个链都支持 Schnorr 的跨链，还是在同一链上作为币混合协议的一部分）、和完全[私人签名预言机][dlc]（等待现实生活中的某件事发生的服务，比如哪个团队赢得了世界杯，然后提供一个承诺该结果的签名，例如允许 Alice 和 Bob 在链上或在闪电网络通道中解决赌注）。许多这些案例与当前使用比特币脚本的替代方案相比，也提高了效率。

[dlc]: https://adiabat.github.io/dlc.pdf

在 BIP 提案中未提及的一点是在同一笔交易中多个输入的签名聚合方法。这是一个想要的特性，它可以使合并交易、coinjoin 以及其他高输入交易比现在更加高效。但是，正如提案的作者所指出的，“随着如此多改进比特币脚本执行的想法的出现（MAST、Taproot、Graftroot、新 sighash 模式、多签名方案等），一次性把所有事情做完实在是太多了。由于聚合确实与所有其他事情相互作用，似乎选择稍后再追求更好。”（[来源][pwuille comment]）

[pwuille comment]: https://www.reddit.com/r/Bitcoin/comments/8wmj5b/pieter_wuille_submits_schnorr_signatures_bip/e1wwriq/

## 新闻

- **<!--discussion-min-fee-discussion-about-minimum-relay-fee-->****[讨论][min fee discussion]最低中继费用**：几年前，当比特币价格仅是其当前美元计价的一小部分时，Bitcoin Core 将最低中继费用设定为 1 satoshi/byte（现在为每 vbyte）。随着价格的上涨和其他网络变化，几位开发者讨论了降低最低中继费用的可能性。Gregory Maxwell 正计划向 Bitcoin Core 提交一个 pull request，该请求可能会将此值大致减半（尽管确切金额尚未确定）。

    这可能会包含在 Bitcoin Core 的下个主要版本中。如果是这样，这意味着一旦变更得到完全部署，您可能能够创建更便宜的合并交易。然而，这也意味着，如果您不升级用于检测未确认交易的任何节点，除非您更改默认设置，否则它们可能不会看到具有低费率的未确认交易。这可能会影响您向用户展示的信息。那些节点仍然会在有效区块中看到所有已确认的交易。

    请注意，要在 Bitcoin Core 中将最低中继费用降低到其默认值以下，您需要更改两个设置。下面显示的是 Bitcoin Core 0.16.1 中具有默认值的两个设置；要降低这些值，请将它们都更改为相同的值，但请注意，将它们降低太多（可能低于默认值的 1/10）会使您面临浪费带宽的攻击，并降低您的节点的 BIP152 致密区块效率。

    ```
    minrelaytxfee=0.00001000
    incrementalrelayfee=0.00001000
    ```

    如果您的组织生产用户端软件，您可能希望确保它可以与费用设置为 1 satoshi/byte 以下的交易和估算费用一起工作。如果您需要有关最低中继费用的更多信息，请联系 Optech。

[min fee discussion]: http://www.erisian.com.au/meetbot/bitcoin-core-dev/2018/bitcoin-core-dev.2018-07-05-19.22.log.html#l-24

- **<!--unrelayable-transactions-->****无法中继的交易**：至少有两个主要服务因为误解比特币签名的最大体积为 72 字节而创建了低于当前最低费率的交易。比特币签名的大小是可变的，所有随机生成的签名中有一半是 72 字节，略少于一半是 71 字节，小部分剩余的是 70 字节或更小。

    可以猜测，一些软件的开发者随机选择了一个签名，看到它是 71 字节，并假设所有签名都将是 71 字节。然而，当软件生成一个 72 字节的签名时，这使得交易的实际大小每个签名比估计的大小大一个字节，导致按字节支付的费用略低于预期。

    当估算费用较高时，这并没有引起重大问题，但现在估算费用接近 Bitcoin Core 默认的最低中继费用 1 satoshi/byte，任何略低于该费用的交易可能都不会被中继到矿工那里，因此无限期地保持未确认状态。

    建议组织检查其软件以确保它至少做出了签名为 72 字节的最坏情况假设。

- **<!--upcoming-bitcoin-core-0-17-feature-freeze-->****即将到来的 Bitcoin Core 0.17 功能冻结**：下周开发者[计划][#12624]停止合并下一个 Bitcoin Core 主要版本的新功能。已有的功能将进一步测试和记录，更新翻译，并遵循其他发布过程的部分。如果您的组织在接下来的六个月内将依赖某项功能，现在可能是确保它成为 0.17 一部分的最后机会。尚未合并但可能添加到 Bitcoin Core 0.17.0的功能包括：

    - <!--scantxoutsetp-->`scantxoutset` RPC，允许搜索 UTXO 以查找地址或脚本。旨在用于地址扫描，例如找到您拥有的资金并将它们归入您当前的一个钱包中。

    - **<!--bip174-->**[BIP174][] 支持部分签名比特币交易，一种用于在钱包之间交换有关比特币交易信息的协议，以促进多签钱包、热/冷钱包、coinjoins 和其他合作钱包之间的更好互操作性。

    - **<!--delayed-transaction-sending-by-network-group-->**[按网络组延迟发送交易][#13298]，提议希望这将使监控节点更难确定哪个客户端首先广播交易（表明它可能是支出者）。

[#12624]: https://github.com/bitcoin/bitcoin/issues/12624
[BIP174]: https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki
[#13298]: https://github.com/bitcoin/bitcoin/issues/13298

- **<!--efficient-reimplementation-of-electrum-server-->****Electrum 服务器的高效重新实现**：本周在比特币开发者邮件列表中的一项公告中声称，基于 Rust 的 Electrum 服务器重新实现比 Python 版本更高效。Optech 没有对此进行任何测试，因此无法确认，但已知 Electrum 服务器被多个比特币企业内部使用并代表其客户托管，因此本期 Newsletter 的一些读者可能希望调查。

## Building on Bitcoin

[**Building on Bitcoin**][bob website] 是一次在上周于里斯本举行的比特币技术会议。会议吸引了许多比特币协议开发者和应用工程师参加。会议的[视频][bob video]已经可以观看，比特币开发者 Bryan Bishop (kanzure) 还提供了几份[会议记录][bob transcripts]。

[bob website]: https://building-on-bitcoin.com/
[bob video]: https://www.youtube.com/watch?v=XORDEX-RrAI
[bob transcripts]: http://diyhpl.us/wiki/transcripts/building-on-bitcoin/2018/

Bitcoin Optech 公司可能对以下演讲特别感兴趣：

- **<!--merchant-adoption-->**[**商家采纳**][bitrefill video] - Bitrefill 的 CEO [Sergej Kotliar][sergej] 讲述了去年年底费用市场的飙升、比特币和闪电网络支付的重要用户体验考虑因素，以及 Bitrefill 在集成闪电网络方面的经验。这次演讲因 Sergej 分享的实际经验数据和他对费用、扩容和闪电网络的第一手经验而引人入胜。

[bitrefill video]: https://www.youtube.com/watch?v=Cpid31c6HZc&feature=youtu.be&t=8m49s
[sergej]: https://twitter.com/ziggamon

- **<!--designing-lighning-wallets-for-the-bitcoin-users-->**[**为比特币用户设计闪电钱包**][lightning ux video] - [Patrícia Estevão][patricia] 做了一个关于在扩展比特币钱包以支持闪电网络支付时的用户体验考虑的演讲。对于任何开始将闪电网络支付集成到现有比特币产品中的企业来说，这都是一个有趣的话题。

[lightning ux video]: https://www.youtube.com/watch?v=XORDEX-RrAI&feature=youtu.be&t=6042
[patricia]: https://twitter.com/patestevao

- **<!--blind-signatures-in-sciptless-scripts-->**[**无脚本脚本的盲签名**][blind signatures video] - [Jonas Nick][jonas] 讲述了如何使用 Schnorr 签名作为进行盲币交换（其中服务器不能链接到币）或在比特币或闪电网络上交换“ecash 代币”等的基础。这次演讲展示了关于无脚本脚本可能性的前沿思考，所介绍的想法距离在比特币上实现还有很长的路要走。然而，看到通过采用比特币中的 Schnorr 签名将解锁的一些新应用程序是很有趣的。

[blind signatures video]: https://www.youtube.com/watch?v=XORDEX-RrAI&feature=youtu.be&t=25479
[jonas]: https://twitter.com/n1ckler

- **<!--ln-story-->**[**闪电网络的故事**][ln video] - [Fabrice Drouin][fabrice] 展示了闪电网络开发的历史。对于任何计划集成和使用闪电网络支付的人来说，这都是一段非常有趣的背景知识。

[ln video]: https://www.youtube.com/watch?time_continue=2881&v=Cpid31c6HZc
[fabrice]: https://twitter.com/acinq_co

- **<!--coinjoinxt-and-other-techniques-for-deniable-transfers-->**[**CoinJoinXT ... 以及其他可否认转账的技术**][coinjoin video] - [Adam Gibson][adam] 讨论了 CoinJoinXT，这是一种通过混合支付和打破交易图分析来提高比特币隐私的方法。许多钱包计划实施某种形式的 CoinJoin，因此比特币工程师至少应该熟悉高层次的概念。

[coinjoin video]: https://www.youtube.com/watch?v=XORDEX-RrAI&feature=youtu.be&t=23359
[adam]: https://twitter.com/waxwing__
