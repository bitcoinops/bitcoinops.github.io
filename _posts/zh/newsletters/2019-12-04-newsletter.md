---
title: 'Bitcoin Optech Newsletter #75'
permalink: /zh/newsletters/2019/12/04/
name: 2019-12-04-newsletter-zh
slug: 2019-12-04-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 介绍了关于 schnorr 和 taproot 提案的近期讨论，提到一个原先叫作 `OP_CHECKOUTPUTSHASHVERIFY` 和 `OP_SECURETHEBAG` 的提案最近有了更新，给出一个旨在标准化 LN 瞭望塔的提案的链接，并总结了热门比特币基础设施项目的值得注意的变更。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

*本周无行动项。*

## 新闻

- **<!--continued-schnorr-taproot-discussion-->****持续的 schnorr/taproot 讨论：** 本周，Russell O'Connor 在 Bitcoin-Dev 邮件列表上发起了一个[讨论帖][oconnor checksig pos]，延续[此前的一项讨论][wuille safer sighashes]：让签名承诺它所对应的、预期会验证该签名的操作码的位置（例如操作码 `OP_CHECKSIG`、`OP_CHECKSIGVERIFY`，或 [tapscript 的][topic tapscript]新操作码 `OP_CHECKSIGADD`）。O'Connor 认为，对那些使用带多个分支的脚本的人而言，这种承诺提供了额外保护——这类脚本允许用多个不同用户的签名以多种方式满足。没有这层保护，Mallory 就可能请 Bob 为分支 *A* 签名，而实际上把该签名用在分支 *B* 中。现有的操作码 `OP_CODESEPARATOR` 有助于应对这类情况，但它不太为人所知，因此直接解决这个顾虑可以提高安全性，还可能免去在 tapscript 中包含 `OP_CODESEPARATOR` 的必要。

  在几位参与者进行了一些[IRC 讨论][irc checksig pos]之后，Anthony Towns [回复][towns checksig pos]提出了一个替代方案：容易受该问题影响的脚本，应把各分支拆成多个 taproot 叶子，每个叶子只包含一个代码分支。tapscript 签名已经承诺了所执行的脚本，因此对一个脚本有效的签名无法用在另一个脚本中。Towns 还解释了为什么只承诺位置可能仍不足以防范签名被挪用到别处。他确实描述了一种自认为能提供更强保护的方法，但认为与直接在 tapscript 中保留 `OP_CODESEPARATOR` 相比，这种做法并不特别有用。

  {:#composable-musig}
  在另一个与 schnorr 相关的话题中，ZmnSCPxj 写了一篇[文章][zmn composable musig]，讨论在存在子组的情况下安全使用 [MuSig][] 签名聚合协议的难点。例如，ZmnSCPxj 的 [nodelets 提案][nodelets proposal]提出，Alice 和 Bob 可以借助各自密钥的聚合 (A, B) 共同控制同一个 LN 节点中的资金。他们的联合节点随后同样用 MuSig 聚合，向 Charlie 的节点开一个通道，即 ((A, B), C)。然而，ZmnSCPxj 解释了为什么按[上周 Newsletter][news74 taproot updates] 中所述的 Wagner 算法，这样做可能并不安全。文中还介绍了几种试图绕开该问题的替代方案。

- **<!--op-checktemplateverify-ctv-->****`OP_CHECKTEMPLATEVERIFY` (CTV)：** 作为 [Newsletter #48][news48 coshv] 中描述的 `OP_CHECKOUTPUTSHASHVERIFY`（COSHV）和 [Newsletter #49][news49 stb] 中提到的 `OP_SECURETHEBAG` 的后继者，这个由 Jeremy Rubin [提出][ctv post]的新操作码可以让脚本确保其资金只能由一组指定的子交易花费。除了改名之外，Rubin 还为[提议的 BIP][bip-ctv] 补充了更多细节，并计划在 2020 年头几个月举办一次审查工作坊（如果你有兴趣参加，请填写[此表单][ctv workshop]）。

  在邮件列表中，Russell O'Connor [重申][oconnor state variable]了他此前的一项[担忧][oconnor suggested amendments]：CTV 会以对比特币脚本而言异常的顺序从堆栈中取数据。Rubin 之所以加入这一设计，是为了防止创建递归[契约][topic covenants]——这类脚本条件不仅作用于有限的一批后代交易，还会永久作用于从某个脚本派生出的所有花费。例如，付款方可以把一组币的未来收款方限制为仅仅三个地址——任何支付给其他地址的行为都会被禁止。O'Connor 的担忧似乎集中在：CTV 的这种怪异行为让比特币脚本的语义更难建模——这正是他此前研究过、也与他仍在推进的 [Simplicity][] 脚本语言工作相关的领域。

  在 IRC 上，Gregory Maxwell 和 Jeremy Rubin [讨论][irc ctv]了 CTV 的多个方面，尤其关注如何让这个拟议操作码在高级设计中更易使用，同时又不让它在已提出的简单[拥堵控制交易][congestion controlled transactions]和[支付池][payment pools]场景中变得更难使用。他们还讨论了是否真有必要阻止人们创建递归契约，对话中可能还[暗指][covenant allusion]了 Maxwell 在 2013 年发起的一个[讨论帖][coincovenants]，主题是被误导的人可能用递归契约做出哪些糟糕的事。

- **<!--proposed-watchtower-bolt-->****提议的瞭望塔 BOLT：** Sergi Delgado Segura 向 Lightning-Dev 邮件列表[发布][watchtower protocol]了他和 Patrick McCorry 一直在编写的一份 BOLT 草案。[瞭望塔][topic watchtowers]是代表可能离线的 LN 节点广播惩罚交易的服务，可挽回那些因旧通道状态被确认上链而本会损失的资金。这份拟议规范的目标是让所有 LN 实现都能与任何瞭望塔互操作，而不是每种 LN 实现都得配一套自己的瞭望塔实现。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中值得注意的变更。*

- [C-Lightning #3259][] 增加了对支付密钥的实验性支持；支付密钥在 [BOLTs #643][] 中被提出，是实现[多路径支付][topic multipath payments] 所需的一部分。支付密钥由收款方生成，并写入其 [BOLT11][] 发票。付款方会把该密钥放进自己这笔支付中、用收款方密钥加密的那一部分里。收款方只有在收到的支付包含该密钥时，才会接受对应发票的付款，从而防止其他节点借此探测收款方是否还在等待有更多支付发往某个用过的支付哈希。

- [C-Lightning #3268][] 把默认网络从测试网改为主网。它还新增了一个配置选项 `include`，用于包含指定文件中给出的任何配置指令。


{% include linkers/issues.md issues="3259,643,3268" %}
[news48 coshv]: /zh/newsletters/2019/05/29/#proposed-new-opcode-for-transaction-output-commitments
[news49 stb]: /zh/newsletters/2019/06/05/#coshv-proposal-replaced
[oconnor checksig pos]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-November/017495.html
[wuille safer sighashes]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-November/016508.html
[irc checksig pos]: http://www.erisian.com.au/taproot-bip-review/log-2019-11-28.html#l-65
[towns checksig pos]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-November/017497.html
[zmn composable musig]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-November/017493.html
[nodelets proposal]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-October/002236.html
[news74 taproot updates]: /zh/newsletters/2019/11/27/#schnorr-taproot-updates
[ctv post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-November/017494.html
[bip-ctv]: https://github.com/JeremyRubin/bips/blob/ctv/bip-ctv.mediawiki
[ctv workshop]: https://forms.gle/pkevHNj2pXH9MGee9
[oconnor state variable]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-November/017496.html
[oconnor suggested amendments]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-May/016973.html
[irc ctv]: https://freenode.irclog.whitequark.org/bitcoin-wizards/2019-11-28#25861123;
[congestion controlled transactions]: https://github.com/JeremyRubin/bips/blob/ctv/bip-ctv.mediawiki#Congestion_Controlled_Transactions
[payment pools]: https://freenode.irclog.whitequark.org/bitcoin-wizards/2019-05-21#1558427254-1558427441;
[watchtower protocol]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-November/002350.html
[coincovenants]: https://bitcointalk.org/index.php?topic=278122.0
[simplicity]: https://blockstream.com/simplicity.pdf
[covenant allusion]: https://freenode.irclog.whitequark.org/bitcoin-wizards/2019-11-28#25861296
[musig]: https://eprint.iacr.org/2018/068
