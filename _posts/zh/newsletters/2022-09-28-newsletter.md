---
title: 'Bitcoin Optech Newsletter #219'
permalink: /zh/newsletters/2022/09/28/
name: 2022-09-28-newsletter-zh
slug: 2022-09-28-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报介绍了一个让闪电网络可以广告按容量定价的手续费率的提议，并公布了一个致力于在 signet 上测试主要协议变更的 Bitcoin Core 软件分叉。

## 新闻

- **<!--ln-fee-ratecards-->闪电网络手续费费率卡**：Lisa Neigut 在 Lightning-Dev 邮件组中[发帖][neigut ratecards]列出了一个 *手续费费率卡* 提议，可以让一个节点为转发交易的手续费广告 4 个分段手续费率。举个例子，如果一笔转发交易将让通道只剩下 25% 的出账容量可用，那么它将需要按比例支付比让通道剩下 75% 的出账容量的交易更高的手续费。

    开发者 ZmnSCPxj [介绍][zmnscpxj ratecards]了一种简单的方法来使用费率卡，“你可以通过在相同的两个节点间使用 4 条相互独立的通道、每条通道的费率都不同来模拟费率卡的效果。如果最低手续费的路径失败了，你只需尝试另一条路径，可能需要更多跳但实质手续费会更低；又或者，你可以付出更高的手续费来尝试相同的通道。”

    这个提议也允许负费率。举个例子，一个通道可以在拥有超过 75% 的出账容量时补贴通过它转发的交易，按千分之一的比例为支付增加价值。商家可以使用负费率来激励其它用户恢复经常用于接收支付的通道的入账容量。

    Neigut 指出，一些节点已经在根据通道的容量调整手续费率，而费率卡将为节点运营者提供更高效率的手段向网络表达他们的意图，而不必频繁通过闪电网络的 gossip 网络来广告新的手续费率。

- **<!--bitcoin-implementation-designed-for-testing-soft-forks-on-signet-->专门用于在 signet 上测试软分叉的比特币实现**：Anthony Towns 在 Bitcoin-Dev 邮件组中[发帖][towns bi]了他正在开发的一个 Bitcoin Core 的软件分叉，该软件将仅运行在默认的 [signet][topic signet]（使用签名来出块的测试网络）上，并且会执行拥有高质量详述和实现的软分叉提议。这应该会让用户更容易实验被提议的变更，包括直接比较一种变更跟另一种相似的变更（例如，比较 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] 和 [SIGHASH_ANYPREVOUT][topic sighash_anyprevout]）。Towns 还计划加入为交易转发策略提议的重大变更（例如 “[交易包转发][topic package relay]”）。

    Towns 正在为这种测试实现（叫做 “[Bitcoin Inquisition][]”）的想法寻求建设性批评，并为向其添加第一组软分叉的 [PR][bi prs] 寻找评审员。

## Bitcoin Stack Exchange 网站的精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者们有疑问时寻找答案的首选站点之一，也是他们在有闲暇时会帮助好奇和困惑用户的地方。在这个月度栏目中，我们会提出上次出刊以来的高票问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--is-it-possible-to-determine-whether-an-hd-wallet-was-used-to-create-a-given-transaction-->能不能确定某一个 HD 钱包是否创建了某一笔交易？]({{bse}}115311) Piter Wuille 指出，虽然无法确定一个 UTXO 是否用到了某一个 [ HD 钱包][topic bip32]来创建，但其它的链上数据可以用来辨识用到的钱包软件，包括交易输入的类型、输出的类型、输入和输出的顺序、[选币算法][topic coin selection] 以及[时间锁][topic timelocks]的使用。
- [<!--why-is-there-a-5day-gap-between-the-genesis-block-and-block-1-->为什么创世区块与 1 号区块之间有 5 天的间隔？]({{bse}}115344) Murch 指出，这个时间线上的间隔可能有多种解释，一是创世区块设置了一个比较高的难度目标，或是中本聪把区块的时间戳写得比较靠前，也有可能是[最初的比特币软件][github jrubin annotated]等待对等节点连入才开始挖矿。
- [<!--is-it-possible-to-set-rbf-as-alwayson-in-bitcoind-->有没有办法在 bitcoind 中始终打开 RBF？]({{bse}}115360) Michael Folkson 和 Murch 解释了 ` walletrbf ` 配置选项，并列举了一系列相关的变更，包括在 GUI 中默认开启 [RBF][topic rbf]，在 RPC 中默认使用 RBF，以及使用 [`mempoolfullrbf`][news208 mempoolfullrbf] 来允许交易池内未使用信号位标记的交易被替换。
- [<!--why-would-i-need-to-ban-peer-nodes-on-the-bitcoin-network-->什么时候我 会需要禁用比特币网络中的对等节点呢？]({{bse}}115183) 用户 RedGrittyBrick 没有从 “[反激励对等节点][bitcoin 23.x banman]” 的角度考虑，而是认为，节点运营者可以使用 [`setban`][setban rpc] RPC 手动拉黑一个对等节点，比如说在该对等节点行为不轨、可能怀有恶意或从事监视、是云服务供应商网络的一份子，等等原因的时候。

## 新版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本，或帮助测试候选版本。*

- [Core Lightning 0.12.1][] 是一个维护性版本，包含了多个 bug 修复。
- [Bitcoin Core 24.0 RC1][] 是这个网络中最常用的全节点实现的下一个版本的第一个候选版本。

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo] 和 [Lightning BOLTs][bolts repo]。*

- [Bitcoin Core #26116][] 让 ` importmulti ` RPC 可以导入一个仅供观察（watch-only）的对象，即使钱包的私钥被加密了也没有关系。这匹配了旧的 ` importaddress ` PRC 的动作。

- [Core Lightning #5594][] 作了多项变更，包括加入和更新多个 API，以允许 ` autoclean ` 插件删除旧发票、支付和转发过的支付。

- [Core Lightning #5315][] 允许用户为通道选择专门的 *通道预留数额*。预留数额是一个节点在通道对等节点支付和转发支付时不允许对方使用的保留资金（译者注：即不允许对等节点花光自己的通道余额）。如果对等节点日后试图欺诈，这个诚实的节点就可以拿走这些保留的资金。Core Lightning 默认预留通道余额的 1%，从而惩罚任何尝试欺诈的对等节点。

    这个已经合并的 PR 允许用户为具体的一条通道减少预留数额，包括减少到零。虽然这样做可能很危险 —— 预留数额越低，对方欺诈的惩罚就越小 —— 但在特定情况下可能是有用的。最显著的场景是，将预留数额设置为零可以让对方花光所有的余额、清空自己的通道。

- [Rust Bitcoin #1258][] 加入了一种比较两个时间锁的方法，可以确定满足一者是否就满足另一者。如代码的注释所述，“一个时间锁只有在 n 个区块被挖出之后，或者 n 秒之后才能解锁。如果你有两个锁定时间（使用相同的单位），那么更大的的时间锁被满足就意味着（从数学意义上来说）小的哪个也会被满足。这个函数可以用来检查一个时间锁跟其它多个锁的差异，例如，过滤出无法被满足的时间锁。也可以用来移除同一个脚本的同一个分支中的重复 ` OP_CHECKTIMEVERIFY ` 操作（移除较小的那个）。”

{% include references.md %}
{% include linkers/issues.md v=2 issues="26116,5594,5315,1258" %}
[bitcoin core 24.0 rc1]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[Core Lightning 0.12.1]: https://github.com/ElementsProject/lightning/releases/tag/v0.12.1
[bitcoin inquisition]: https://github.com/bitcoin-inquisition/bitcoin/
[bi prs]: https://github.com/bitcoin-inquisition/bitcoin/pulls
[neigut ratecards]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-September/003685.html
[zmnscpxj ratecards]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-September/003688.html
[towns bi]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-September/020921.html
[github jrubin annotated]: https://github.com/JeremyRubin/satoshis-version/blob/master/src/main.cpp#L2255
[news208 mempoolfullrbf]: /en/newsletters/2022/07/13/#bitcoin-core-25353
[bitcoin 23.x banman]: https://github.com/bitcoin/bitcoin/blob/23.x/src/banman.h#L28
[setban rpc]: https://github.com/bitcoin/bitcoin/blob/97f865bb76a9c9e8e42e4ee1227615c9c30889a6/src/rpc/net.cpp#L675
