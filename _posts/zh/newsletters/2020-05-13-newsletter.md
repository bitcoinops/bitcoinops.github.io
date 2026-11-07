---
title: 'Bitcoin Optech Newsletter #97'
permalink: /zh/newsletters/2020/05/13/
name: 2020-05-13-newsletter-zh
slug: 2020-05-13-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 介绍了一个提议：让 taproot 签名对已花费的 scriptPubKey 额外作出承诺。此外还有我们的常设栏目：Bitcoin Core PR 审查俱乐部会议摘要、发布与候选发布列表，以及热门比特币基础设施软件中值得注意的变更。

## 行动项

*本周无。*

## 新闻

- **<!--request-for-an-additional-taproot-signature-commitment-->****请求 taproot 签名作出额外承诺：** 比特币专家之间此前讨论过的一个想法[^increase-quote]，是允许硬件钱包自动签署任何能证明会增加用户余额的交易。这样硬件钱包就能轻松自动参与 [coinjoin][topic coinjoin] 交易或 LN 支付路由。

  然而，几年前 Greg Sanders [描述][sanders safe automation]了一种攻击，可以骗过硬件钱包，让它以为余额在增加，实际却在减少。攻击者会构造一笔未签名交易，花费硬件钱包的两个输入、产生两个输出——一个输出付给钱包，金额比两个输入中较大的那个略多；另一个输出付给攻击者。攻击者先请求对第一个输入签名（但不说明第二个输入也属于该钱包）；钱包在确认付回自己的输出大于该输入后，会签署这个输入。接着，攻击者假称这是完全另一笔交易，请求对第二个输入签名，钱包在再次确认有输出大于输入后，又把第二个输入也签了。最后，攻击者把两个签名放进最终交易并广播，从钱包里偷走资金。Sanders 在描述该问题时也提出了一个可能的解决方案，但它要求钱包知道交易中每个被花费的前序输出的 scriptPubKey。

  ![使用假 coinjoin 欺骗硬件钱包导致资金损失的示意图](/img/posts/2020-05-fake-coinjoin-trick-hardware-wallet.dot.png)

  上周，Andrew Kozlik 在 Bitcoin-Dev 邮件列表上[发帖][kozlik spk commit]，请求 [taproot][topic taproot] 签名直接承诺每个输入所花费的前序输出的 scriptPubKey。通过承诺交易全部输入的 outpoint，这种承诺其实已经间接存在[^outpoint-txid-spk]，但若在交易摘要中直接作出，[部分签名比特币交易][topic psbt]（PSBT）就能无需信任地向签名者提供该交易中所有被花费的 scriptPubKey 副本。PSBT 里的这些 scriptPubKey 不需要任何信任，因为只要其中任何一个缺失或被篡改，签名者对 scriptPubKey 的承诺就会失效，整笔交易也随之无效。这样一来，硬件钱包就能采用 Sanders 在 2017 年描述的方案，而无需信任外部程序提供正确的 scriptPubKey 副本。

## Bitcoin Core PR 审查俱乐部

_在这个月度栏目中，我们总结最近一次 [Bitcoin Core PR 审查俱乐部][Bitcoin Core PR Review Club]会议的内容，挑选其中一些重要的问题与回答。点击下面的问题，可以看到会议中相关回答的摘要。_

[在最后一次区块写入后刷新撤销文件][review club #17994] 是 Karl-Johan Alm 的一个 PR（[#17994][Bitcoin Core #17994]），它改变了 _撤销文件_ 刷入磁盘的方式。当更新 UTXO 集以反映新区块中的交易时，节点会创建撤销文件；如果该区块之后在重组中被移除，撤销文件中的数据可以把 UTXO 集恢复到之前的状态，从而抵消最初处理该区块所产生的影响。

大部分讨论围绕基本概念和这个错误修复的细节展开：

{% include functions/details-list.md
  q0="<!--data-loss-->现有的错误是否会导致数据丢失（并可能导致共识失败）？"
  a0="不会。[该错误][Bitcoin Core #17890] 可能造成磁盘空间浪费，但不会导致数据丢失。"
  a0link="https://bitcoincore.reviews/17994.html#l-33"

  q1="<!--undo-data-->在没有所有前置区块的情况下，是否可以创建一个区块的撤销数据？"
  a1="不能。创建一个区块的撤销数据需要在连接该区块时的 UTXO 集。为此，我们需要验证并连接所有前置区块。"
  a1link="https://bitcoincore.reviews/17994.html#l-43"

  q2="<!--modify-undo-->我们是否会在写入磁盘后修改区块或撤销数据？"
  a2="通常不会。区块和撤销数据都是只写的。一旦写入磁盘，它们就不会再被修改。修剪节点可能会在足够多的新区块将其掩埋之后删除区块和撤销数据。"
  a2link="https://bitcoincore.reviews/17994.html#l-79"

  q3="<!--undo-order-->撤销数据是按照与区块数据相同的顺序写入磁盘的吗？"
  a3="不是。区块数据按照接收的顺序写入（由于我们在初始同步期间并行获取区块，这可能不是按高度顺序），而撤销数据按照区块连接的顺序写入。然而，撤销数据总是出现在与区块所在的 `blk*` 文件对应的 `rev*` 文件中。"
  a3link="https://bitcoincore.reviews/17994.html#l-103"

  q4="<!--space-allocation-->区块和撤销文件中的空间是如何分配的？为什么？"
  a4="区块文件按 16 MB 为单位预先分配空间，撤销文件按 1 MB 为单位。这样做是为了减少文件系统碎片。"
  a4link="https://bitcoincore.reviews/17994.html#l-122"

  q5="这个 PR 改变了什么？"
  a5="在这个 PR 中，撤销文件会在文件中编号最高的区块被连接时就最终确定并刷入磁盘，而不是等到相应的区块文件被刷新时才刷入。"
  a5link="https://bitcoincore.reviews/17994.html#l-204"
%}

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [Eclair 0.4][] 是一个新的大版本发布，升级了 Eclair 的主要依赖，增加了对最新版 Bitcoin Core 的支持，并弃用了 Eclair Node GUI（建议用户改用 [Phoenix][] 或 [Eclair Mobile][]）。

- [C-Lightning 0.8.2.1][] 是一个新的维护版本，修复了 C-Lightning 与 Eclair 之间在大通道（“wumbo channels”）上的不兼容问题。详情请参见所附的发布说明。

- [Bitcoin Core 0.20.0rc1][bitcoin core 0.20.0] 是 Bitcoin Core 下一个大版本的候选发布。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中值得注意的变更。*

*注意：以下提到的 Bitcoin Core 提交针对其主开发分支，因此这些变更很可能要到 0.21 版才会发布，也就是在即将发布的 0.20 版发布约六个月之后。*

- [Bitcoin Core #16224][] 把 GUI 中所有已翻译的错误消息同时以本地语言和英语显示。这有助于用户寻求帮助，并快速向开发者描述问题。此外，写入调试日志的现在也是英文版错误消息，同样是为了让开发者更容易理解问题并提供帮助。

- [C-Lightning #3659][] 改为让 `channeld` 创建惩罚交易，因为它掌握着关于此前承诺交易的足够信息。随着这项变更，C-Lightning 现在支持瞭望塔（watchtower），例如 [Talaia 的 The Eye of Satoshi 瞭望塔][talaia]。未来可能的[扩展][CL future]包括：把 HTLC 交易也纳入瞭望塔结算，以及为瞭望塔插件启用之前创建的承诺生成惩罚交易。

- [Rust-Lightning #539][] 增加了对 `option_static_remotekey` 通道的支持，并要求连接的对等节点也支持该功能。如果你这边发生数据丢失，该功能允许你的通道对手方向一个在通道打开时约定的未调整密钥付款，从而关闭通道，并让你的钱包能够花掉自己的资金。该功能的更多细节参见 Newsletter [#67][news67 static_remotekey]。

- [LND #4139][] 扩展了 `gettransactions` 和 `listsweeps` RPC，允许传入起始和结束区块高度，从而只取回在该区块范围内确认的交易。结束高度填 `-1` 时，还可以把未确认交易一并列出。

## 脚注

[^increase-quote]:
    “你让钱包一直连着电脑，这台电脑运行一个只读的闪电网络钱包，然后与硬件钱包通信，为那些严格增加你通道余额的交易获取签名。”——摘自 Stephan Snigirev 一场关于硬件钱包的演讲的粗略[转录稿][snigirev ref]，由 Bryan Bishop 转录

[^outpoint-txid-spk]:
    在现有的 [BIP341][] [taproot][topic taproot] 规范中，每个输入都会承诺该交易中所有输入的 outpoint。outpoint 是被花费输出的 txid 与输出索引（vout）。txid 则是对包含该输出的交易中大部分内容做哈希得到的结果。因此，对 outpoint 的承诺就是对 txid 的承诺，而 txid 又是对前序输出（包括该输出的 scriptPubKey）的承诺。

{% include references.md %}
{% include linkers/issues.md issues="16224,3659,539,4139,17994,17890" %}
[bitcoin core 0.20.0]: https://bitcoincore.org/bin/bitcoin-core-0.20.0
[c-lightning 0.8.2.1]: https://github.com/ElementsProject/lightning/releases/tag/v0.8.2.1
[eclair 0.4]: https://github.com/ACINQ/eclair/releases/tag/v0.4
[phoenix]: https://phoenix.acinq.co/
[eclair mobile]: https://github.com/ACINQ/eclair-mobile
[sanders safe automation]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2017-August/014843.html
[kozlik spk commit]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-April/017801.html
[snigirev ref]: https://diyhpl.us/wiki/transcripts/austin-bitcoin-developers/2019-06-29-hardware-wallets/
[talaia]: https://twitter.com/sr_gi/status/1258830271148961795
[CL future]: https://github.com/ElementsProject/lightning/issues/3724
[news67 static_remotekey]: /zh/newsletters/2019/10/09/#bolts-642
