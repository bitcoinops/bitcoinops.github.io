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
本期 Newsletter 包括关于最低手续费和即将发布的 Bitcoin Core 版本的新闻与行动项，关于 Schnorr 签名提案的特别专题，以及上周在里斯本举行的 Building on Bitcoin 会议的综述。

## 行动项

- **<!--bitcoin-core-minimum-relay-fee-->**Bitcoin Core 的最低中继手续费可能会在下一个主要版本中降低。请确保你的软件没有那种危险的假设，以为 1 satoshi/vbyte 就是可能的最低下限。更多信息参见下面的*新闻*部分。

- **<!--ensure-your-software-->**确保你用于计算动态手续费交易大小的软件能准确计算签名大小，或者至少按比特币签名为 72 字节的最坏情况来假设。更多信息参见下面的*新闻*部分。

- **<!--as-previous-newsletters-->**正如前几期 Newsletter 所预告的，比特币警报私钥已经[公开][alert released]，同时披露了影响 Bitcoin Core 0.12.0 及更早版本的漏洞。山寨币也可能受影响。如果你尚未检查自己的基础设施中是否有受影响的服务，建议现在就动手。详情参见 [Newsletter #1][newsletter #1]。

[alert released]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-July/016189.html
[newsletter #1]: /zh/newsletters/2018/06/26/

## 仪表盘项

- **<!--transaction-fees-remain-very-low-->****交易手续费仍然很低：** 截至本文撰写时，预计 2 个或更多区块后确认的费率估算仍大致处于 Bitcoin Core 默认的最低中继手续费水平。这是[合并输入][consolidate inputs]的好时机。

[consolidate inputs]: https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#Consolidation

- **<!--block-production-recovery-->****出块恢复：** 上周有消息称中国的洪水影响了矿工运营，此后比特币出块似乎已恢复到约每 10 分钟一个区块的预期水平。

## 特别新闻：Schnorr 签名提议 BIP

Pieter Wuille 在比特币开发邮件列表上[发帖][schnorr post]，提交了一份基于 Schnorr 的[签名格式草案规范][schnorr draft]。该规范的目标是，在着手实际软分叉之前，先让所有人就比特币上的 Schnorr 签名应该是什么样子达成一致，因此这份 BIP 并没有提出具体的新操作码、隔离见证的见证标志、软分叉激活方式，也没有提出把这套变更纳入比特币共识规则所需的任何其他内容。不过，如果这种签名格式最终成为比特币所采用的 Schnorr 签名形式，我们仍然可以说清它将带来哪些好处：

[schnorr post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-July/016203.html
[schnorr draft]: https://github.com/sipa/bips/blob/bip-schnorr/bip-schnorr.mediawiki

1. 与现有的比特币私钥和公钥完全兼容，也就是说，现有的 HD 钱包升级后无需生成新的恢复种子。

2. 签名体积大约缩小 10%，随着 Schnorr 被采用，区块链容量会略有提升。

3. 签名可批量验证，验证一个满是 Schnorr 签名的区块时，速度约为逐个验证的 2 倍。这主要影响初次同步的节点，或离线后追赶进度的节点。

4. 在多重签名场景下可实现完全压缩并显著改善隐私，但需要参与者交互：不限数量的参与者都能用自己的公钥和签名组合出单个 33 字节公钥和 64 字节签名，从而以与单签相同的效率实现安全的多重签名，并因多重签名看起来与单签无异而提升隐私。不过，该方案要求参与多重签名的各个钱包在创建公钥和签名时进行多轮交互。

5. 更多以隐私为重点的用例。例如提升闪电网络的隐私，实现更私密的原子交换（既可在两条链都支持 Schnorr 时跨链进行，也可在同一链上作为混币协议的一部分），以及完全[私密的签名预言机][dlc]（这类服务等待现实中某件事发生，比如哪支球队捧起世界杯，然后给出一个对结果作出承诺的签名，例如让 Alice 和 Bob 在链上或闪电网络通道中结算赌约）。上述许多用例与使用现有比特币脚本的替代方案相比，也提高了效率。

[dlc]: https://adiabat.github.io/dlc.pdf

这份 BIP 提案没有涵盖的一点，是同一笔交易中多个输入之间的签名聚合方法。这是一项人们期待的特性，它能让合并交易、coinjoin 以及其他多输入交易比现在高效得多。但正如提案作者所指出的：“随着改进比特币脚本执行的想法层出不穷（MAST、Taproot、Graftroot、新的 sighash 模式、多重签名方案……），要做的事情实在太多，无法一次全部完成。由于聚合确实与所有其他事情相互影响，推迟处理似乎是更好的选择。”（[来源][pwuille comment]）

[pwuille comment]: https://www.reddit.com/r/Bitcoin/comments/8wmj5b/pieter_wuille_submits_schnorr_signatures_bip/e1wwriq/

## 新闻

- **<!--discussion-min-fee-discussion-about-minimum-relay-fee-->****关于最低中继手续费的[讨论][min fee discussion]：** 几年前，比特币价格还只有现在美元价格的一小部分时，Bitcoin Core 把最低中继手续费定为 1 satoshi/byte（现在按 vbyte 计）。随着价格上涨和其他网络变化，几位开发者讨论了降低最低中继手续费。Gregory Maxwell 计划向 Bitcoin Core 提交一个 PR，可能把该值大致减半（确切数值尚未确定）。

    这可能被纳入 Bitcoin Core 的下一个主要版本。若果真如此，一旦该变更得到充分部署，你或许就能创建更便宜的合并交易。但这也意味着，如果你不升级那些用于检测未确认交易的节点，除非修改默认设置，它们可能看不到费率较低的未确认交易。这会影响你向用户展示的信息。这些节点仍能在有效区块中看到全部已确认交易。

    请注意，要把 Bitcoin Core 的最低中继手续费降到默认值以下，需要修改两个设置。下面列出的是 Bitcoin Core 0.16.1 中这两个设置及其默认值；要降低该值，需把两者改成同一个值，但要注意，降得太低（比如低于默认值的 1/10）会让你暴露在浪费带宽的攻击之下，也会降低你节点的 BIP152 紧凑区块效率。

    ```
    minrelaytxfee=0.00001000
    incrementalrelayfee=0.00001000
    ```

    如果你的组织开发面向最终用户的软件，最好确保它能处理手续费设置低于 1 satoshi/byte 的交易，也能应对低于该值的费率估算。如需了解最低中继手续费的更多信息，请联系 Optech。

[min fee discussion]: http://www.erisian.com.au/meetbot/bitcoin-core-dev/2018/bitcoin-core-dev.2018-07-05-19.22.log.html#l-24

- **<!--unrelayable-transactions-->****无法中继的交易**：至少有两家主要服务被认定创建了费率低于当前最低值的交易，原因是对比特币签名的最大尺寸（72 字节）存在误解。比特币签名的大小并不固定：随机生成的签名中有一半是 72 字节，略少于一半是 71 字节，余下少量是 70 字节或更小。

    据推测，某些软件的开发者随意看了某个随机选取的签名，发现它是 71 字节，就以为所有签名都是 71 字节。然而当软件实际生成 72 字节的签名时，交易的真实大小就会比估算值每个签名多出 1 字节，导致每字节实际支付的手续费略低于预期。

    在费率估算较高时，这并未造成大问题；但如今费率估算已接近 Bitcoin Core 默认的 1 satoshi/byte 最低中继手续费，任何费率略低于该值的交易都可能无法中继给矿工，从而长期停留在未确认状态。

    建议各组织检查自己的软件，确保至少按签名长度为 72 字节的最坏情况来假设。

- **<!--upcoming-bitcoin-core-0-17-feature-freeze-->****即将到来的 Bitcoin Core 0.17 功能冻结**：下周开发者[计划][#12624]停止为下一个 Bitcoin Core 主要版本合并新功能。已有功能将进一步测试并补充文档，翻译会更新，发布流程的其他环节也将依次进行。如果你的组织在接下来六个月内会依赖某项功能，现在可能是确保它进入 0.17 的最后机会。尚未合并但有望加入 Bitcoin Core 0.17.0 的功能包括：

    - <!--scantxoutsetp-->`scantxoutset` RPC，允许在 UTXO 集合中搜索地址或脚本。它面向地址归集等用途，例如找出你拥有的资金，并归集到你现有的某个钱包中。

    - **<!--bip174-->**[BIP174][] 部分签名比特币交易（PSBT）支持，这是一种在钱包之间交换比特币交易信息的协议，便于多重签名钱包、热/冷钱包、coinjoin 及其他协作钱包之间更好地互操作。

    - **<!--delayed-transaction-sending-by-network-group-->**[按网络组延迟发送交易][#13298]，这项提案有望让间谍节点更难判断哪个客户端最先广播了一笔交易（从而推断它可能是付款方）。

[#12624]: https://github.com/bitcoin/bitcoin/issues/12624
[BIP174]: https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki
[#13298]: https://github.com/bitcoin/bitcoin/issues/13298

- **<!--efficient-reimplementation-of-electrum-server-->****Electrum 服务器的高效重新实现**：本周比特币开发邮件列表上的一则公告称，用 Rust 重写的 Electrum 服务器比 Python 版本高效得多。Optech 未做任何测试，无法确认这一说法，但 Electrum 服务器已知被多家比特币企业使用，既有内部自用，也有代客户托管的，因此本刊的部分读者或许值得进一步了解。

## Building on Bitcoin

[**Building on Bitcoin**][bob website] 是上周在里斯本举行的一场比特币技术会议。会议参加者众多，既有比特币协议开发者，也有应用工程师。会议的[视频][bob video]已经可以观看，比特币开发者 Bryan Bishop（kanzure）还整理了几份[会议记录][bob transcripts]。

[bob website]: https://building-on-bitcoin.com/
[bob video]: https://www.youtube.com/watch?v=XORDEX-RrAI
[bob transcripts]: http://diyhpl.us/wiki/transcripts/building-on-bitcoin/2018/

以下演讲可能对 Optech 会员公司特别有参考价值：

- **<!--merchant-adoption-->**[**商家采用**][bitrefill video] - Bitrefill 的 CEO [Sergej Kotliar][sergej] 以个人视角回顾了去年年底手续费市场的暴涨、比特币与闪电网络支付中重要的用户体验考量，以及 Bitrefill 集成闪电网络的经验。这次演讲之所以引人入胜，是因为 Sergej 分享了真实的实测数据，以及他在手续费、扩容和闪电网络方面的第一手经验。

[bitrefill video]: https://www.youtube.com/watch?v=Cpid31c6HZc&feature=youtu.be&t=8m49s
[sergej]: https://twitter.com/ziggamon

- **<!--designing-lighning-wallets-for-the-bitcoin-users-->**[**为比特币用户设计闪电钱包**][lightning ux video] - [Patrícia Estevão][patricia] 发表演讲，谈的是把比特币钱包扩展到支持闪电网络支付时需要考虑的用户体验。对于任何刚开始把闪电网络支付集成到现有比特币产品中的企业，这次演讲都值得一听。

[lightning ux video]: https://www.youtube.com/watch?v=XORDEX-RrAI&feature=youtu.be&t=6042
[patricia]: https://twitter.com/patestevao

- **<!--blind-signatures-in-sciptless-scripts-->**[**无脚本脚本中的盲签名**][blind signatures video] - [Jonas Nick][jonas] 介绍了如何以 Schnorr 签名为基础实现盲币交换（服务器无法把这些币关联起来），以及在比特币或闪电网络上兑换“ecash 代币”等。这场演讲呈现了关于无脚本脚本能力的前沿思考，其中提出的想法距离能在比特币上实现还有很长的路要走。不过，看看 Schnorr 签名被引入比特币后会解锁哪些新应用，仍然很有意思。

[blind signatures video]: https://www.youtube.com/watch?v=XORDEX-RrAI&feature=youtu.be&t=25479
[jonas]: https://twitter.com/n1ckler

- **<!--ln-story-->**[**闪电网络的故事**][ln video] - [Fabrice Drouin][fabrice] 梳理了闪电网络的发展历程。对于任何计划集成并使用闪电网络支付的人来说，这些背景知识都很有价值。

[ln video]: https://www.youtube.com/watch?time_continue=2881&v=Cpid31c6HZc
[fabrice]: https://twitter.com/acinq_co

- **<!--coinjoinxt-and-other-techniques-for-deniable-transfers-->**[**CoinJoinXT …… 以及其他可否认转账的技术**][coinjoin video] - [Adam Gibson][adam] 讨论了 CoinJoinXT，这是一种通过混合支付、打断交易图谱分析来提升比特币隐私的方法。许多钱包都计划实现某种形式的 coinjoin，因此比特币工程师至少应熟悉其高层概念。

[coinjoin video]: https://www.youtube.com/watch?v=XORDEX-RrAI&feature=youtu.be&t=23359
[adam]: https://twitter.com/waxwing__
