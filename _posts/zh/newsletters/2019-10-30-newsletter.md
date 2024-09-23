---
title: 'Bitcoin Optech Newsletter #70'
permalink: /zh/newsletters/2019/10/30/
name: 2019-10-30-newsletter-zh
slug: 2019-10-30-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 公布了最新的 C-Lightning 版本，邀请大家帮助测试 Bitcoin Core 的候选版本，描述了使用 CPFP carve-out 简化闪电网络（LN）承诺的讨论，并总结了 Bitcoin Stack Exchange 上几条获得高票的问题和答案。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- **<!--upgrade-to-c-lightning-0-7-3-->****升级到 C-Lightning 0.7.3：**这个最新的[版本][c-lightning 0.7.3] 增加了对 PostgreSQL 后端的支持，允许在关闭通道时将资金直接发送到特定地址，并允许在 `lightningd` 未运行时加密保管你的 HD 钱包种子——此外还有许多其他功能和多个漏洞修复。

- **<!--help-test-bitcoin-core-release-candidate-->****帮助测试 Bitcoin Core 候选版本：**鼓励有经验的用户帮助测试即将发布的 [Bitcoin Core][Bitcoin Core 0.19.0] 版本的最新候选版本。

## 新闻

- **<!--ln-simplified-commitments-->****LN 简化承诺：**在两个独立的讨论中，LND 的开发者讨论了他们实现简化承诺的工作，这种 LN 结算交易只支付最小的链上交易费用，并包含两个额外的输出（分别对应双方）。该想法是允许任一方在交易广播时选择他们希望支付的交易费用，这可以通过他们个人输出使用子支付父（CPFP）费用提升来完成。尽管这一点过去已经讨论过，但由于易受攻击，一直没有实施，而这一漏洞有望在即将发布的 Bitcoin Core 版本 0.19.0 中通过 CPFP carve-out 的加入得到解决（参见 [Newsletter #56][pr15681]）。

  在第一个讨论中，Johan Halseth 发表了一封[电子邮件][halseth carve-out]，提出放宽内存池规则以进一步简化承诺。对此有多个反对意见，认为稍微的改变不会有效，过大的改动则会让网络面临浪费带宽攻击的风险。然而，这场讨论（以及由 Jeremy Rubin 在 #bitcoin-core-dev IRC 频道发起的另一场[讨论][rubin justification]）揭示了许多开发者希望更好地理解现有规则及其可能改进的需求。一个来自 Suhas Daftuar 演讲的良好大纲现已转化为[维基页面][daftuar duo]。

  在第二个讨论中，Joost Jager [重新开始][anchor thread]了由 Rusty Russell 启动的旧线程，提出了简化承诺的规范（参见 [Newsletter #23][opt_simplified]）。基于即将发布的 carve-out 功能以及 LN 中的其他进展，Jager 提出了一些建议，包括：使用“锚定输出”作为计划使用 CPFP 消费的输出名称；使用另一组公钥来分担冷钱包和热钱包的职责；以及使用静态密钥来简化备份恢复。他随后向闪电网络规范库提交了一个[拉取请求][BOLTs #688]，以将简化承诺加入 LN 协议规范。

- **<!--publication-of-videos-and-study-material-from-schnorr-taproot-workshop-->****发布 Schnorr/Taproot 研讨会的视频和学习材料：**Optech 发布了一篇[博客文章][taproot workshop]，其中包含了链接至视频、Jupyter notebooks、GitHub 代码库和上个月在旧金山和纽约举行的 Schnorr 和 Taproot 研讨会产生的更多信息。这些材料解释了这两个提案的基础知识，指导学习者实际使用它们，并描述了如何优化利用它们为比特币带来的新功能的策略。

  我们鼓励对未来可能加入比特币的这些功能感兴趣的开发者学习这些材料，尤其是参与 [Taproot 评审][taproot review]的开发者，参见[上周的 Newsletter][tr]。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者在遇到问题时首先查找答案的地方之一——或者当我们有一些空闲时间时，也会帮助那些充满好奇或感到困惑的用户。在这个每月专题中，我们会重点介绍自上次更新以来发布的几条获得高票的问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--why-does-hashing-public-keys-not-actually-provide-any-quantum-resistance-->**[为什么对公钥进行哈希并不能真正提供量子抗性？]({{bse}}91049)
  Andrew Chow 列出了关于公钥和量子抗性的几个考虑因素，包括：在消费时需要暴露公钥、大量比特币处于已知公钥的输出中，以及由于目前没有将公钥视为秘密，公钥在交易之外暴露的多种方式。

- **<!--will-schnorr-multi-signatures-completely-replace-ecdsa-->**[Schnorr 多重签名是否会完全取代 ECDSA？]({{bse}}90855)
  Ugam Kamat 解释了 Schnorr 签名在 Segwit v1 中的拟议增加并不会消除对 ECDSA 的需求。ECDSA 仍然需要用于消费非 Segwit 以及 Segwit v0 的输出。

- **<!--why-doesn-t-rbf-include-restrictions-on-the-outputs-->**[为什么 RBF 没有对输出进行限制？]({{bse}}90858)
  Andrew Chow 讨论了 [BIP125][] 可选替代费用（RBF）的设计选择，并将其与首次见到安全替代费用（FSS-RBF）方法进行了比较。Chow 指出了 FSS-RBF 的缺点，但也警告不要接受任何未确认的交易。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中值得注意的变更。*

- [Bitcoin Core #17165][] 移除了对 [BIP70][] 支付协议的支持。此更改仅在主开发分支中完成，可能要等到大约六个月后发布的 0.20 版本中才会生效。BIP70 在 [0.18.0 版本][core 0.18.0] 中已变为可选项，并将在即将发布的 0.19.0 版本中默认禁用；有关更多信息，请参见 [Newsletter #19][pr14451]。

  这是 Bitcoin Core 中最后一个依赖 OpenSSL 的重要功能，而另一个[拉取请求][Bitcoin Core #17265] 已经开启，旨在彻底移除该依赖关系。OpenSSL 曾是 Bitcoin Core 中多个漏洞的来源（例如 [Heartbleed][] 和 [非严格签名编码漏洞][ber]），过去五年多的时间里，已经投入了大量精力来消除它作为依赖项的使用。


{% include linkers/issues.md issues="17165,17265,688" %}
[bitcoin core 0.19.0]: https://bitcoincore.org/bin/bitcoin-core-0.19.0/
[c-lightning 0.7.3]: https://github.com/ElementsProject/lightning/releases/tag/v0.7.3
[tr]: https://github.com/ajtowns/taproot-review
[tr rsvp]: https://forms.gle/iiPaphTcYC5AZZKC8
[core 0.18.0]: https://bitcoincore.org/en/releases/0.18.0/#build-system-changes
[pr14451]: /zh/newsletters/2018/10/30/#bitcoin-core-14451
[heartbleed]: https://bitcoin.org/en/alert/2014-04-11-heartbleed
[ber]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2015-July/009697.html
[pr15681]: /zh/newsletters/2019/07/24/#bitcoin-core-15681
[opt_simplified]: /zh/newsletters/2018/11/27/#simplified-fee-bumping-for-ln
[anchor thread]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-October/002249.html
[halseth carve-out]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-October/002240.html
[daftuar duo]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/Mempool-and-mining
[rubin justification]: http://www.erisian.com.au/bitcoin-core-dev/log-2019-10-24.html#l-660
[taproot workshop]: /zh/schnorr-taproot-workshop/
[taproot review]: https://github.com/ajtowns/taproot-review
[tr]: /zh/newsletters/2019/10/23/#taproot-review
