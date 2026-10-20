---
title: 'Bitcoin Optech Newsletter #70'
permalink: /zh/newsletters/2019/10/30/
name: 2019-10-30-newsletter-zh
slug: 2019-10-30-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 公布了最新的 C-Lightning 版本，邀请大家帮助测试 Bitcoin Core 的候选版本，描述了使用 CPFP 豁免（carve-out） 简化闪电网络（LN）承诺的讨论，并总结了 Bitcoin Stack Exchange 上几条获得高票的问题和答案。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- **<!--upgrade-to-c-lightning-0-7-3-->****升级到 C-Lightning 0.7.3：**这个最新的[版本][c-lightning 0.7.3] 增加了对 PostgreSQL 后端的支持，允许在关闭通道时将资金直接发送到特定地址，并允许你在 `lightningd` 未运行时让 HD 钱包种子保持加密——此外还有许多其他功能，以及若干错误修复。

- **<!--help-test-bitcoin-core-release-candidate-->****帮助测试 Bitcoin Core 候选版本：**我们鼓励有经验的用户帮助测试即将发布的 [Bitcoin Core][Bitcoin Core 0.19.0] 的最新候选版本。

## 新闻

- **<!--ln-simplified-commitments-->****LN 简化承诺：**在两个不同的讨论帖中，LND 的开发者讨论了他们实现简化承诺的工作。这种 LN 结算交易只支付最低限度的链上手续费，并包含两个额外的输出（双方各一个）。其思路是让任一方都能在交易广播时选择自己想要支付的手续费，具体做法是从自己的输出发起子为父付（CPFP）手续费追加。尽管过去已经讨论过这一点，但该方案容易受到一种攻击；随着 CPFP 豁免 被纳入即将发布的 Bitcoin Core 0.19.0 版本，这种攻击有望得到解决（参见 [Newsletter #56][pr15681]）。

  在第一个讨论帖中，Johan Halseth 发表了一封[电子邮件][halseth carve-out]，提出放宽内存池策略，以便进一步简化承诺。这招致了几条反对意见：小幅改动不会有效果，而改动过大又会让网络面临被浪费带宽攻击的风险。不过，这场讨论（以及 Jeremy Rubin 在 #bitcoin-core-dev IRC 频道另外发起的[讨论][rubin justification]）表明，许多开发者希望更好地理解现行规则，以及这些规则可以如何改进。Suhas Daftuar 曾就此主题做过一次演讲，其提纲现已整理成[维基页面][daftuar duo]。

  在第二个讨论帖中，Joost Jager [重启][anchor thread]了 Rusty Russell 发起的一个旧讨论帖，其中提出了简化承诺的规范提案（参见 [Newsletter #23][opt_simplified]）。基于即将推出的 CPFP 豁免功能以及 LN 的其他进展，Jager 提出了若干建议，包括：把准备通过 CPFP 花费的输出命名为“锚定输出”；为锚点使用另一组公钥，以便在冷钱包和热钱包之间划分职责；以及使用静态密钥来简化备份恢复。他随后向 BOLTs 仓库提交了一个[拉取请求][BOLTs #688]，把简化承诺加入 LN 协议规范。

- **<!--publication-of-videos-and-study-material-from-schnorr-taproot-workshop-->****发布 Schnorr/Taproot 工作坊的视频和学习材料：**Optech 发布了一篇[博客文章][taproot workshop]，其中包含指向视频、Jupyter notebook、GitHub 仓库的链接，以及上个月在旧金山和纽约市举办的 schnorr 与 taproot 工作坊产出的更多资料。这些材料讲解了两个提案的基本原理，带领学习者实际动手使用它们，并介绍了如何充分利用它们为比特币新增功能的策略。

  我们鼓励所有关心这些未来可能加入比特币的功能的开发者阅读这些学习材料，尤其是参与 [taproot 审查][taproot review] 的开发者——该审查在[上周的 Newsletter][tr] 中介绍过。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们有点空闲时帮助好奇或困惑用户的地方。在本月栏目中，我们精选自上次更新以来得票最高的一些问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--why-does-hashing-public-keys-not-actually-provide-any-quantum-resistance-->**[为什么对公钥进行哈希并不能真正提供量子抗性？]({{bse}}91049)
  Andrew Chow 列出了关于公钥与量子抗性的几点考虑，包括：花费时必须公开公钥、大量比特币存放在公钥已知的输出中，以及由于目前并不把公钥当作秘密，公钥会在交易之外的多种场合暴露。

- **<!--will-schnorr-multi-signatures-completely-replace-ecdsa-->**[Schnorr 多重签名是否会完全取代 ECDSA？]({{bse}}90855)
  Ugam Kamat 解释了在 segwit v1 中拟议引入 schnorr 签名并不会消除对 ECDSA 的需求：花费非 segwit 输出以及 segwit v0 输出仍然需要 ECDSA。

- **<!--why-doesn-t-rbf-include-restrictions-on-the-outputs-->**[为什么 RBF 没有对输出进行限制？]({{bse}}90858)
  Andrew Chow 探讨了 [BIP125][] 自愿启用的手续费替换（RBF）中的一些设计选择，并将其与首次所见安全的手续费替换（FSS-RBF）方案作了比较。Chow 指出了 FSS-RBF 的缺点，但也提醒不要接受任何未确认的交易。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中值得注意的变更。*

- [Bitcoin Core #17165][] 移除了对 [BIP70][] 支付协议的支持。这一变更目前仅在主开发分支上完成，可能要到预计约六个月后发布的 0.20 版本才会正式发布。BIP70 在 [0.18.0 版本][core 0.18.0] 中已变为可选项，并将在即将发布的 0.19.0 版本中默认禁用；有关更多信息，请参见 [Newsletter #19][pr14451]。

  这是 Bitcoin Core 中最后一个依赖 OpenSSL 的重要功能，此外还有一个[拉取请求][Bitcoin Core #17265] 已提交，目标是彻底移除这项依赖。OpenSSL 曾是 Bitcoin Core 中多个漏洞的来源（例如 [Heartbleed][] 和 [非严格签名编码][ber]），过去五年多来，大家已经投入了大量精力来摆脱这项依赖。


{% include linkers/issues.md issues="17165,17265,688" %}
[bitcoin core 0.19.0]: https://bitcoincore.org/bin/bitcoin-core-0.19.0/
[c-lightning 0.7.3]: https://github.com/ElementsProject/lightning/releases/tag/v0.7.3
[tr]: https://github.com/ajtowns/taproot-review
[tr rsvp]: https://forms.gle/iiPaphTcYC5AZZKC8
[core 0.18.0]: https://bitcoincore.org/en/releases/0.18.0/#build-system-changes
[pr14451]: /zh/newsletters/2018/10/30/#bitcoin-core-14451
[heartbleed]: https://bitcoin.org/en/alert/2014-04-11-heartbleed
[ber]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2015-July/009697.html
[pr15681]: /zh/newsletters/2019/07/24/#bitcoin-core-15681
[opt_simplified]: /zh/newsletters/2018/11/27/#simplified-fee-bumping-for-ln
[anchor thread]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-October/002249.html
[halseth carve-out]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-October/002240.html
[daftuar duo]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/Mempool-and-mining
[rubin justification]: http://www.erisian.com.au/bitcoin-core-dev/log-2019-10-24.html#l-660
[taproot workshop]: /zh/schnorr-taproot-workshop/
[taproot review]: https://github.com/ajtowns/taproot-review
[tr]: /zh/newsletters/2019/10/23/#taproot-review
