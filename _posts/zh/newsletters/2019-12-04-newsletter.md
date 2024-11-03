---
title: 'Bitcoin Optech Newsletter #75'
permalink: /zh/newsletters/2019/12/04/
name: 2019-12-04-newsletter-zh
slug: 2019-12-04-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了关于 schnorr 和 taproot 提案的近期讨论，提到了之前称为 `OP_CHECKOUTPUTSHASHVERIFY` 和 `OP_SECURETHEBAG` 的提案的更新，链接了一个关于标准化 LN 瞭望塔的提案，并总结了比特币基础设施项目中值得注意的变化。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

*本周无行动项。*

## 新闻

- **<!--continued-schnorr-taproot-discussion-->****持续的 schnorr/taproot 讨论：** 本周，Russell O'Connor 在 Bitcoin-Dev 邮件列表上发起了一个[线程][oconnor checksig pos]，继续讨论[之前的讨论][wuille safer sighashes]，即签名应承诺要执行该签名的操作码的位置（例如，操作码 `OP_CHECKSIG`、`OP_CHECKSIGVERIFY` 或 [tapscript 的][topic tapscript] 新操作码 `OP_CHECKSIGADD`）。O'Connor 认为，这种承诺为那些使用具有多个分支的脚本并允许通过多个用户签名以不同方式满足脚本的用户提供了额外的保护。如果没有这种保护，Mallory 可能会要求 Bob 为分支 A 签名，而实际上 Mallory 会在分支 B 中使用该签名。现有的操作码 `OP_CODESEPARATOR` 有助于解决这种情况，但它并不为人所知，因此直接解决这个问题可以提高安全性，并可能消除在 tapscript 中使用 `OP_CODESEPARATOR` 的必要性。

  在一些[IRC 讨论][irc checksig pos]之后，Anthony Towns 提出了一个[替代建议][towns checksig pos]：容易受到此问题影响的脚本应将其分支分离为多个 taproot 叶子，每个叶子仅包含一个代码分支。Tapscript 签名已经承诺要执行的脚本，因此一个脚本的有效签名无法用于另一个脚本。Towns 还描述了为什么仅承诺位置可能无法保证防止重新定位签名。尽管他描述了一种他认为可以提供更好保护的方法，但他认为与继续在 tapscript 中保留 `OP_CODESEPARATOR` 相比，它并不特别有用。

  {:#composable-musig}
  在另一个与 schnorr 相关的话题中，ZmnSCPxj 撰写了一篇[文章][zmn composable musig]，讨论了在子组中安全使用 [MuSig][] 签名聚合协议的挑战。例如，ZmnSCPxj 的[节点提案][nodelets proposal]建议 Alice 和 Bob 可以通过聚合他们的密钥 (A, B) 共同控制一个 LN 节点。他们的联合节点可以通过 MuSig 聚合与 Charlie 的节点打开通道，即 ((A, B), C)。然而，ZmnSCPxj 解释了为什么根据[上周的 Newsletter][news74 taproot updates] 中提到的 Wagner 算法，这可能是不安全的。此外，还描述了几种试图解决此问题的替代方案。

- **<!--op-checktemplateverify-ctv-->****`OP_CHECKTEMPLATEVERIFY` (CTV)：** `OP_CHECKOUTPUTSHASHVERIFY` (COSHV) 的继任者在 [Newsletter #48][news48 coshv] 中描述，`OP_SECURETHEBAG` 在 [Newsletter #49][news49 stb] 中提到。这个新的操作码由 Jeremy Rubin [提出][ctv post]，允许脚本确保其资金只能通过指定的一组子交易花费。除了名称的更改，Rubin 还在[提议的 BIP][bip-ctv] 中添加了更多细节，并计划在 2020 年的头几个月举行一个审查研讨会（如果你有兴趣参加，请填写[此表格][ctv workshop]）。

  在邮件列表中，Russell O'Connor [重申][oconnor state variable] 了他之前对 CTV 的[担忧][oconnor suggested amendments]，即 CTV 从堆栈中以比特币脚本的异常顺序提取数据。Rubin 添加了这一点以防止创建递归的[契约][topic covenants]——这些脚本条件不仅适用于有限数量的后代交易，还会永久适用于从特定脚本派生的所有交易。例如，支出者可以将未来接收者限制为三个地址中的任何一个，向任何其他地址支付将被禁止。O'Connor 的担忧似乎集中在 CTV 的这种异常行为使得比特币脚本的语义更难建模，而 O'Connor 之前的工作与此相关，他目前仍在继续研究 [Simplicity][] 脚本语言。

  在 IRC 中，Gregory Maxwell 和 Jeremy Rubin [讨论][irc ctv]了 CTV 的几个方面，尤其是如何使提议的操作码在高级设计中更易于使用，同时不影响它在已经提出的简单[拥堵控制交易][congestion controlled transactions]和[支付池][payment pools]中的使用。他们还讨论了是否真的有必要阻止人们创建递归契约，可能在对话中[暗指][covenant allusion] Gregory Maxwell 在 2013 年发起的一个关于人们可能误用递归契约的[线程][coincovenants]。

- **<!--proposed-watchtower-bolt-->****提议的瞭望塔 BOLT：** Sergi Delgado Segura 向 Lightning-Dev 邮件列表[发布][watchtower protocol]了他和 Patrick McCorry 正在编写的瞭望塔草案 BOLT。[瞭望塔][topic watchtowers]是为可能离线的 LN 节点广播惩罚交易的服务，帮助这些节点找回由于旧的通道状态被确认而可能丢失的资金。提议的规范目标是允许所有 LN 实现与任何瞭望塔互操作，而不是每个 LN 实现都使用不同的瞭望塔实现。

## 值得注意的代码和文档更改

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的更改。*

- [C-Lightning #3259][] 增加了对支付密钥的实验性支持，支付密钥在 [BOLTs #643][] 中被提议，作为启用[多路径支付][topic multipath payments] 的一部分。支付密钥由接收者生成并包含在他们的 [BOLT11][] 发票中。支出者在支付时将此密钥包含在加密给接收者密钥的部分中。接收者只有在收到的支付包含密钥时才会接受该发票的支付，从而防止其他节点探测接收者是否正在等待对先前使用过的支付哈希进行额外支付。

- [C-Lightning #3268][] 将默认网络从比特币测试网更改为比特币主网。它还添加了一个新的配置选项 `include`，该选项会包含指定文件中的任何配置指令。


{% include linkers/issues.md issues="3259,643,3268" %}
[news48 coshv]: /zh/newsletters/2019/05/29/#proposed-new-opcode-for-transaction-output-commitments
[news49 stb]: /zh/newsletters/2019/06/05/#coshv-proposal-replaced
[oconnor checksig pos]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-November/017495.html
[wuille safer sighashes]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-November/016508.html
[irc checksig pos]: http://www.erisian.com.au/taproot-bip-review/log-2019-11-28.html#l-65
[towns checksig pos]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-November/017497.html
[zmn composable musig]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-November/017493.html
[nodelets proposal]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-October/002236.html
[news74 taproot updates]: /zh/newsletters/2019/11/27/#schnorr-taproot-updates
[ctv post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-November/017494.html
[bip-ctv]: https://github.com/JeremyRubin/bips/blob/ctv/bip-ctv.mediawiki
[ctv workshop]: https://forms.gle/pkevHNj2pXH9MGee9
[oconnor state variable]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-November/017496.html
[oconnor suggested amendments]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-May/016973.html
[irc ctv]: https://freenode.irclog.whitequark.org/bitcoin-wizards/2019-11-28#25861123;
[congestion controlled transactions]: https://github.com/JeremyRubin/bips/blob/ctv/bip-ctv.mediawiki#Congestion_Controlled_Transactions
[payment pools]: https://freenode.irclog.whitequark.org/bitcoin-wizards/2019-05-21#1558427254-1558427441;
[watchtower protocol]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-November/002350.html
[coincovenants]: https://bitcointalk.org/index.php?topic=278122.0
[simplicity]: https://blockstream.com/simplicity.pdf
[covenant allusion]: https://freenode.irclog.whitequark.org/bitcoin-wizards/2019-11-28#25861296
[musig]: https://eprint.iacr.org/2018/068
