---
title: 'Bitcoin Optech Newsletter #150'
permalink: /zh/newsletters/2021/05/26/
name: 2021-05-26-newsletter-zh
slug: 2021-05-26-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 宣布了多个 IRC 频道的网络迁移，并庆祝 Optech 的第 150 期 Newsletter。同时也包含我们常规的 Bitcoin Stack Exchange 热门问答栏目、新软件版本及候选发布版本，以及对常用比特币基础设施项目的值得注意的变更内容。

## 新闻

- **<!--irc-channels-moving-to-libera-chat-->****IRC 频道迁移至 Libera.Chat：**在每周的 Bitcoin Core 开发者会议中，[bccdev meeting libera] 决定 5 月 27 日（周四）的会议将是最后一次在 Freenode 网络上举行的会议。机器人、日志记录和其他基础设施、今后会议以及一般讨论都将迁移至 [Libera.Chat][] 网络上的 `#bitcoin-core-dev` 频道。就在发布本 Newsletter 前不久，Freenode 管理员的操作似乎导致此次迁移被迫提前至周三早晨（UTC 时间）。与 Bitcoin 和闪电网络（LN）相关的其他几个频道也在迁移。要查找各频道当前所在的网络，请参阅 Bitcoin Wiki 上的 [IRC 频道列表][list of IRC channels]。如果你运营的频道正在迁移但没有 Wiki 帐号来更新该列表，请在 Libera 上的 `#bitcoin-wiki` 频道告知编辑人员。

## 庆祝 Optech Newsletter #150
*作者：[John Newbery][]，Optech 创始人*

这是我们面向 Bitcoin 技术社区撰写的第 150 期常规 Optech 每周 Newsletter。自 2018 年 6 月以来，我们几乎每周都会整理并发布比特币和闪电网络开发中最重要事件的摘要，只有在圣诞节假期附近会暂停一次短暂的更新。

Optech 建立之初的目标非常简单：帮助比特币企业采纳能够使比特币扩容的技术，并关注比特币开源社区中发生的卓越技术工作。虽然三年前我们无法完全预见这些工作的形态，但我们始终相信这一使命，并以此指导我们所做的工作。自 2018 年 6 月以来，我们：

* 发布了 150 篇 [Newsletters][]、多篇[博客 posts][blog posts] 和实地报告，以及一篇 [Bech32 系列][bech32]专题报道，并推出了一个 [Taproot 互动式研讨会][interactive taproot workshop]。整体而言，我们已发布了约 25 万字内容——足以印制大约 700 页纸。<!-- wc _posts/en/newsletters/*md _posts/en/*md
  _includes/articles/*md _includes/specials/2019-exec-briefing/*md
  _includes/specials/bech32/*md-->

* 邮件订阅用户达到了 4,100 人，Twitter 关注者接近 11,000 人。

* 已有社区成员开始将部分 Newsletter 翻译成[日文版本][Japanese]和[西班牙语版本][Spanish]。

* 创建并维护了 [topics index][]，集中记录比特币和闪电网络提案与改进的演进脉络，供读者追踪了解。

这些 Newsletter 凝聚了许多贡献者的努力。首当其冲的是 [Dave Harding][]，他撰写了我们大部分的内容。用 “多产” 来形容 Dave 也显得不足——在比特币生态系统中各种各样的研究和开发工作中，他每周都能产出简明、清晰的概览。我们很幸运能够拥有这样一位兼具广博知识、敬业精神和谦逊品格的记录者。Dave 在 Optech 及其他项目中撰写的海量内容，已成为现有和未来比特币参与者都能受益的巨大资产。

此外，我们还有其他 Optech 成员在幕后支持：[Mike Schmidt][] 撰写了常规的 Bitcoin Stack Exchange 精选问答及“值得注意的”比特币软件和基础设施变更摘要，并保证 Newsletter 能准时发送到每位订阅者的收件箱。[Jon Atack][] 贡献了关于 Bitcoin Core PR 审查俱乐部的常规总结。除了 Mike 和 Jon，[Carl Dong][]、[Adam Jonas][]、[Mark Erhardt][] 和我也会在需要时提供 PR 总结，并审阅每期 Newsletter，以尽量确保我们输出的内容准确而清晰。

特别感谢 [Shigeyuki Azuchi][] 将我们的 Newsletter 翻译成日语，以及 [Akio Nakamura][] 也参与了日文材料的翻译和审校。

还要感谢比特币社区中的所有成员——人数之多已无法在此一一列出——他们审阅了我们的 Newsletter、帮助我们理解各种概念，并在我们出错时通过 issue 和拉取请求（pull request）提醒我们改进。

所有这些工作都得益于我们慷慨的[支持者][supporters]，主要是我们的[创始赞助商][founding sponsors]——Wences Casares、John Pfeffer 和 Alex Morcos。

最后，感谢各位读者。我们非常高兴能成为这个社区的一员并为这个生态系统做出贡献。得知这份资源对如此多的人具有价值，并收到读者的反馈，让我们感到非常欣慰。如果你也想参与或对我们的改进提出建议，欢迎随时通过 [info@bitcoinops.org][info] 与我们联系。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案时最先访问的地方之一——或是在我们有空时回答有兴趣或困惑的用户问题的地方。以下是我们本月精选的一些高赞问答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--why-are-there-more-than-two-transaction-outputs-in-a-coinbase-transaction-->**[为什么在一个 coinbase 交易中会有两个以上的交易输出？]({{bse}}105831)
  Andrew Chow 解释了在 coinbase 交易中常见的几个输出：

  * 单笔矿工区块奖励付款

  * 多笔付款，例如矿池向矿工支付报酬

  * [BIP141][bip141 commitment] 的 `OP_RETURN` 见证承诺

  * 额外的 `OP_RETURN` 承诺，例如 [merge mining][se 273 merge mining] 以及其他协议

- **<!--fundrawtransaction-what-is-it-->**[fundrawtransaction - 这是什么?]({{bse}}105811)
  Pieter Wuille 通过四个示例展示了如何使用 `fundrawtransaction` RPC 来发送比特币。

- **<!--what-previously-existing-technologies-made-bitcoin-possible-->**[Bitcoin 的诞生基于哪些既有技术？]({{bse}}106000)
  Murch 根据 [Bitcoin's Academic Pedigree paper][bitcoins academic pedigree paper] 总结了组成 Bitcoin 的现有技术要素。这些技术包括链接式时间戳/可验证日志、拜占庭容错、工作量证明（proof of work）、数字现金以及公钥用作身份。

- **<!--how-can-i-follow-the-progress-of-miner-signaling-for-taproot-activation-->**[如何跟进矿工对 Taproot 激活的信号进度？]({{bse}}105853)
  除了可访问 Hampus Sjöberg 的 [https://taproot.watch][taproot watch website] 网站，Bitcoin Core 用户也可以使用 `getblockchaininfo` 获取已信号区块的数量，并通过 `getblock` 的 versionhex 字段（包含信号版本位）观察信号情况。

## 发布与候选发布

*适用于常用比特币基础设施项目的新版本与候选发布版本。请考虑升级到新版本，或参与测试候选发布版本。*

- [Eclair 0.6.0][]
  这是一个新版本，包含若干提高用户安全性和隐私性的改进。同时也提供了与未来可能使用 [taproot][topic taproot] 地址的软件的兼容性。

- [LND 0.13.0-beta.rc3][LND 0.13.0-beta]
  这是一个候选发布版本，新增了对修剪过的比特币全节点的支持，允许使用原子多路径支付（Atomic MultiPath，简称 [AMP][topic multipath payments]）接收和发送付款，并增强了其 [PSBT][topic psbt] 功能，还包含其他改进及修复。

## 值得注意的代码和文档更改

*以下是本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]中的值得注意的更改：*

- [Bitcoin Core #21843][]
  为 `getnodeaddresses` RPC 添加了一个名为 `network` 的参数。当将该参数设置为所支持的网络类型（如 `ipv4`、`ipv6`、`onion` 或 `i2p`）时，`getnodeaddresses` 将只返回该网络上已知的地址；如果不指定 `network` 参数，则会返回所有网络上已知的地址。

- [Eclair #1810][]
  强制节点必须声明并遵守 `payment_secret` 功能位。这个功能位可以阻止[对收款方进行去匿名化的攻击][payment secrets recipient deanon]，并进一步防御[不正确的图像揭示][CVE-2020-26896]所涉及的不当散列值泄漏。该功能已被主流实现所支持，并在 [LND][LND paysec] 和 [Rust-Lightning][RL paysec] 中要求对支付启用此功能。

- [Eclair #1774][]
  在 Java 内置的 `SecureRandom()` [CSPRNG][] 函数之外增加了一个较弱随机数来源。将此较弱随机数进行哈希，然后将其摘要与主随机数源生成的结果进行异或，这样即便将来 `SecureRandom()` 被发现存在某些可预测性漏洞，Eclair 依然有机会保留足够的熵，以确保其密码操作不会被利用。

- [BIPs #1089][]
  为之前在邮件列表上[讨论][spigler independent]过的提案分配了 [BIP87][] 编号。该提案旨在为多签钱包定义一组标准化的 [BIP32][] 路径，不论其多签参数、所使用的地址类型或其他脚本细节如何。该提案鼓励用户将这些细节存储在[输出脚本描述符][topic descriptors]（descriptor）中，从而避免钱包要针对各种多签变体（如 [BIP45][BIP45] 和 `m/48'` 标准）重复实现多个标准，或因新的多签脚本变体而产生新的标准。尽管使用描述符意味着需要备份更多的数据，但相比传统多签钱包要备份每个参与方的扩展公钥（xpub）而言，多签描述符中关于脚本模板和描述符校验和的信息只占用极少的额外空间。

- [BIPs #1025][]
  为在 [Newsletter #105][news105 path templates] 中介绍过的路径模板分配了 [BIP88][] 编号。路径模板可用于简明地说明钱包应支持哪些 BIP32 派生路径。由于路径模板较为紧凑，用户在备份种子时也能轻松把模板备份进去，从而避免因遗失模板而导致资金丢失。该提案的另一特性是可以在模板中为路径派生设定限制（例如在某个路径上最多只派生 50,000 个密钥），使得恢复过程可以扫描所有可能的密钥，从而有效避免 HD 钱包中的 gap 限制问题。

- [BIPs #1097][]
  为在 [Newsletter #136][news136 bsms] 中介绍的 Bitcoin Secure Multisig Setup（BSMS）分配了 [BIP129][] 编号，该规范详细说明了钱包（尤其是硬件签名设备）应如何安全地交换信息以共同构建多签钱包。这些信息包括要使用的脚本模板（例如要求 2-of-3 签名的 P2WSH）以及每个签名者将在指定密钥路径上使用的 [BIP32][] 扩展公钥（xpub）。该协议通过一个协调器来收集必要信息并创建输出脚本描述符，随后每个签名者分别验证该描述符，以确保其正确包含自己的密钥。

{% include references.md %}
{% include linkers/issues.md issues="21843,1810,1774,1089,1025,1097" %}
[LND 0.13.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.13.0-beta.rc3
[news105 path templates]: /zh/newsletters/2020/07/08/#proposed-bip-for-bip32-path-templates
[news136 bsms]: /zh/newsletters/2021/02/17/#securely-setting-up-multisig-wallets
[csprng]: https://en.wikipedia.org/wiki/Cryptographically-secure_pseudorandom_number_generator
[eclair 0.6.0]: https://github.com/ACINQ/eclair/releases/tag/v0.6.0
[bccdev meeting libera]: http://www.erisian.com.au/bitcoin-core-dev/log-2021-05-20.html#l-582
[libera.chat]: https://libera.chat/
[list of IRC channels]: https://en.bitcoin.it/wiki/IRC_channels
[spigler independent]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018630.html
[john newbery]: https://twitter.com/jfnewbery
[newsletters]: /zh/newsletters/
[blog posts]: /zh/blog/
[bech32]: /zh/bech32-sending-support/
[interactive taproot workshop]: /zh/schnorr-taproot-workshop/
[japanese]: /ja/publications/
[spanish]: /es/publications/
[topics index]: /en/topics/
[dave harding]: https://dtrt.org/
[mike schmidt]: https://twitter.com/bitschmidty
[jon atack]: https://twitter.com/jonatack
[carl dong]: https://twitter.com/carl_dong
[adam jonas]: https://twitter.com/adamcjonas
[mark erhardt]: https://twitter.com/murchandamus
[shigeyuki azuchi]: https://github.com/azuchi
[akio nakamura]: https://github.com/AkioNak
[supporters]: /#supporters
[founding sponsors]: /en/about/#founding-sponsors
[info]: mailto:info@bitcoinops.org
[bip141 commitment]: https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki#commitment-structure
[se 273 merge mining]: https://bitcoin.stackexchange.com/questions/273/how-does-merged-mining-work
[bitcoins academic pedigree paper]: https://queue.acm.org/detail.cfm?id=3136559
[taproot watch website]: https://taproot.watch
[CVE-2020-26896]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-26896
[payment secrets recipient deanon]: /zh/newsletters/2019/12/04/#c-lightning-3259
[LND paysec]: /zh/newsletters/2020/12/02/#lnd-4752
[RL paysec]: /zh/newsletters/2021/05/05/#rust-lightning-893
