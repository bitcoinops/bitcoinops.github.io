---
title: 'Bitcoin Optech Newsletter #97'
permalink: /zh/newsletters/2020/05/13/
name: 2020-05-13-newsletter-zh
slug: 2020-05-13-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了一个提议，即 Taproot 签名对已花费的 scriptPubKeys 进行额外承诺，并包含了我们常规部分的内容：Bitcoin Core PR 审查俱乐部会议摘要、发布和候选发布的列表，以及对流行的比特币基础设施软件中值得注意的更改的描述。

## 行动项

*本周无。*

## 新闻

- **<!--request-for-an-additional-taproot-signature-commitment-->****对 Taproot 签名进行额外的承诺请求：** 之前在比特币专家之间讨论过的一个想法[^increase-quote]是允许硬件钱包自动签署任何可以明确增加用户余额的交易。这可以使硬件钱包轻松自动参与 [coinjoin][topic coinjoin] 交易或闪电网络支付路由。

  然而，几年前，Greg Sanders [描述][sanders safe automation]了一种攻击，可以用来欺骗硬件钱包，使其认为余额在增加，实际上是在减少。攻击者会创建一个未签名的交易，花费硬件钱包的两个输入到两个输出——一个输出向钱包支付比两个输入中较大的一个略多的金额，另一个输出则支付给攻击者。攻击者会请求对第一个输入进行签名（而不透露第二个输入属于钱包）；在验证支付回钱包的输出大于输入后，钱包会签署该输入。然后，攻击者假装这是一个完全不同的交易，再次请求对第二个输入进行签名，使钱包在再次验证输出大于输入后，也签署第二个输入。最后，攻击者将两个签名放入最终交易并广播，从而窃取钱包中的资金。Sanders 在描述该问题时还描述了一种潜在的解决方案，但它要求钱包了解交易中每个之前输出所对应的 scriptPubKeys。

  ![使用假 coinjoin 欺骗硬件钱包导致资金损失的示意图](/img/posts/2020-05-fake-coinjoin-trick-hardware-wallet.dot.png)

  上周，Andrew Kozlik 在 Bitcoin-Dev 邮件列表上[发布][kozlik spk commit]了一个请求，要求 [taproot][topic taproot] 签名直接承诺每个输入之前输出的 scriptPubKey。通过承诺所有交易输入的 outpoint，这种承诺已经间接存在[^outpoint-txid-spk]，但将其直接纳入交易摘要将允许[部分签名比特币交易][topic psbt] (PSBT) 无需信任地向签名者提供交易中所花费的所有 scriptPubKeys 的副本。如果缺少或篡改任何 scriptPubKey，签名者对 scriptPubKey 的承诺将无效，从而使交易无效。这将使硬件钱包能够使用 Sanders 在 2017 年描述的解决方案，而无需信任外部程序来提供正确的 scriptPubKeys 副本。

## Bitcoin Core PR 审查俱乐部

_在这个每月的部分中，我们总结了一次最近的 [Bitcoin Core PR 审查俱乐部][Bitcoin Core PR Review Club]会议，重点介绍了一些重要的问题和答案。点击下方的问题以查看会议中答案的摘要。_

[在最后的区块写入后刷新撤销文件][review club #17994] 是由 Karl-Johan Alm 提出的一个 PR ([#17994][Bitcoin Core #17994])，它改变了 _撤销文件_ 刷新到磁盘的方式。当 UTXO 集在新区块的交易反映后更新时，会创建撤销文件；如果在重组过程中该区块被删除，撤销文件包含将 UTXO 集恢复到之前状态的更改，从而撤销最初处理区块的效果。

大部分讨论围绕基本概念和错误修复的细节展开：

{% include functions/details-list.md
  q0="现有的错误是否会导致数据丢失（并可能导致共识失败）？"
  a0="不会。[该错误][Bitcoin Core #17890] 可能会导致磁盘空间的不必要使用，但不会导致数据丢失。"
  a0link="https://bitcoincore.reviews/17994.html#l-33"

  q1="在没有所有前置区块的情况下，是否可以创建一个区块的撤销数据？"
  a1="不能。创建一个区块的撤销数据需要在连接该区块时的 UTXO 集。为此，我们需要验证并连接所有前置区块。"
  a1link="https://bitcoincore.reviews/17994.html#l-43"

  q2="我们是否会在写入磁盘后修改区块或撤销数据？"
  a2="通常不会。区块和撤销数据是只写的。一旦它们被写入磁盘，就不会被修改。修剪节点可能会在足够多的新区块埋藏之后删除区块和撤销数据。"
  a2link="https://bitcoincore.reviews/17994.html#l-79"

  q3="撤销数据是按照与区块数据相同的顺序写入磁盘的吗？"
  a3="不是。区块数据按照接收的顺序写入（由于我们在初始同步期间并行获取区块，这可能不是按高度顺序），而撤销数据按照区块连接的顺序写入。然而，撤销数据总是出现在与区块所在的 `blk*` 文件对应的 `rev*` 文件中。"
  a3link="https://bitcoincore.reviews/17994.html#l-103"

  q4="区块和撤销文件中的空间是如何分配的？为什么？"
  a4="文件中的空间是以 16MB 的块大小预分配的，而撤销文件的空间则是 1MB。这是为了减少文件系统碎片化。"
  a4link="https://bitcoincore.reviews/17994.html#l-122"

  q5="这个 PR 改变了什么？"
  a5="在这个 PR 中，当文件中最高的区块已连接时，撤销文件将被最终确定并刷新到磁盘，而不是在相应的区块文件被刷新时。"
  a5link="https://bitcoincore.reviews/17994.html#l-204"
%}

## 发布与候选发布

*流行的比特币基础设施项目的新发布和候选发布。请考虑升级到新版本或帮助测试候选版本。*

- [Eclair 0.4][] 是一个新的主要版本发布，升级了 Eclair 的主要依赖项，添加了对最新版本 Bitcoin Core 的支持，并弃用了 Eclair Node GUI（鼓励用户运行 [Phoenix][] 或 [Eclair Mobile][]）。

- [C-Lightning 0.8.2.1][] 是一个新的维护版本，修复了 C-Lightning 和 Eclair 之间在大通道（“wumbo channels”）方面的不兼容问题。详情请参见链接的发布说明。

- [Bitcoin Core 0.20.0rc1][bitcoin core 0.20.0] 是 Bitcoin Core 下一个主要版本的候选发布。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的更改。*

*注意：以下提到的 Bitcoin Core 提交适用于其主开发分支，因此这些更改可能要到即将发布的 0.20 版本后的大约六个月后才会发布到 0.21 版本中。*

- [Bitcoin Core #16224][] 显示了 GUI 中所有翻译的错误信息，同时显示为本地语言和英语。这可以帮助用户寻求帮助并快速向开发者描述问题。此外，错误信息的英文版本现在会被写入调试日志，以便开发人员更轻松地理解问题并提供帮助。

- [C-Lightning #3659][] 让 `channeld` 创建惩罚交易，因为它拥有足够的信息来处理以前的承诺交易。随着这一更改，C-Lightning 现在支持瞭望塔，例如 [Talaia 的 The Eye of Satoshi 瞭望塔][talaia]。未来可能的[扩展][CL future]包括为瞭望塔结算添加 HTLC 交易，并为瞭望塔插件激活前创建的承诺生成惩罚交易。

- [Rust-Lightning #539][] 添加了对 `option_static_remotekey` 通道的支持，并要求连接的节点支持此功能。在发生数据丢失的情况下，该功能允许通道对方支付在通道打开时约定的未调整密钥，从而关闭通道并允许您的钱包花费资金。详见 Newsletter [#67][news67 static_remotekey] 以获取此功能的更多信息。

- [LND #4139][] 扩展了 `gettransactions` 和 `listsweeps` RPC，允许传递起始和结束区块高度，仅检索在该区块范围内确认的交易。结束高度为 `-1` 的值可用于列出未确认的交易。

## 脚注

[^increase-quote]:
    “你将钱包连接到计算机，然后连接的计算机运行一个只读的闪电网络钱包，然后与硬件钱包通信，对严格增加你通道余额的交易进行签名。” ——摘自 Stephan Snigirev 关于硬件钱包的演讲的粗略[记录][snigirev ref]；记录者：Bryan Bishop

[^outpoint-txid-spk]:
    在现有的 [BIP341][] 规范中，[taproot][topic taproot] 的每个输入都承诺了交易中包含的每个输入的 outpoint。Outpoint 是被花费输出的 txid 和输出索引（vout）。Txid 是包含该输出的大部分交易部分的哈希值。因此，对 outpoint 的承诺即是对 txid 的承诺，而 txid 又是对先前输出（包括输出的 scriptPubKey）的承诺。

{% include references.md %}
{% include linkers/issues.md issues="16224,3659,539,4139,17994,17890" %}
[bitcoin core 0.20.0]: https://bitcoincore.org/bin/bitcoin-core-0.20.0
[c-lightning 0.8.2.1]: https://github.com/ElementsProject/lightning/releases/tag/v0.8.2.1
[eclair 0.4]: https://github.com/ACINQ/eclair/releases/tag/v0.4
[phoenix]: https://phoenix.acinq.co/
[eclair mobile]: https://github.com/ACINQ/eclair-mobile
[sanders safe automation]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2017-August/014843.html
[kozlik spk commit]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-April/017801.html
[snigirev ref]: https://diyhpl.us/wiki/transcripts/austin-bitcoin-developers/2019-06-29-hardware-wallets/
[talaia]: https://twitter.com/sr_gi/status/1258830271148961795
[CL future]: https://github.com/ElementsProject/lightning/issues/3724
[news67 static_remotekey]: /zh/newsletters/2019/10/09/#bolts-642
