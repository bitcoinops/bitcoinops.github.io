---
title: 'Bitcoin Optech Newsletter #68'
permalink: /zh/newsletters/2019/10/16/
name: 2019-10-16-newsletter-zh
slug: 2019-10-16-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 宣布 LND 发布最新版本，请求协助测试 Bitcoin Core 与 C-Lightning 的候选发布版本，转达 taproot 提案的最新进展，介绍一项提高 LN 默认路由手续费的提议，并总结近期加密经济系统峰会上的三场演讲。此外还有例行的热门比特币基础设施项目值得注意的变更。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- **<!--upgrade-lnd-to-version-0-8-0-beta-->****将 LND 升级到 0.8.0-beta 版本：**[LND 的最新版本][lnd 0.8.0-beta]采用了更易扩展的数据包格式，提升了备份安全性，加强了瞭望塔客户端集成，使路由更容易成功，并包含许多其他新功能和错误修复。

- **<!--upgrade-to-eclair-0-3-2-->****将 Eclair 升级到 0.3.2 版本：**[Eclair 的最新版本][eclair 0.3.2]改进了备份，同步 gossip 数据时更省带宽（对非路由节点尤其如此，例如移动设备上的节点），并包含许多其他新功能和错误修复。

- **<!--review-rcs-->****审查候选发布版本：**两个热门比特币基础设施项目已经为下一个版本发布了候选发布版本（RC）。我们鼓励开发者和有经验的用户协助测试这些 RC，以便在正式公开发布前发现并修复问题：

  - [Bitcoin Core 0.19.0rc1][bitcoin core 0.19.0]
  - [C-Lightning 0.7.3-rc2][c-lightning 0.7.3]

## 新闻

- **<!--taproot-update-->****taproot 更新：**Pieter Wuille 向 Bitcoin-Dev 邮件列表发送了一封[邮件][taproot update]，概述该提案近期的改动。改动包括：

  * 使用 32 字节公钥，而非 33 字节公钥（在 [Newsletter #59][32 byte pubkey] 中提到）。

  * 不支持 P2SH 包装的 taproot 地址（在 [#65][p2sh-wrapped taproot] 中提到）。

  * 签名哈希数据中的交易输入位置改用 32 位，而非 16 位索引。

  * [bip-schnorr][] 现在也使用带标签的哈希。此前只有 [bip-taproot][] 和 [bip-tapscript][] 使用。

  * [bip-tapscript][] 取消了 10,000 字节与 201 次非推送操作码的限制（在 [#65][tapscript resource limits] 中提到）。

  * Merkle 树的最大深度从 32 层增加到 128 层。

  Wuille 的邮件以及更新后的各份 BIP 为上述每项决定给出了理由，并附有相关既往讨论的链接。

- **<!--proposed-default-ln-fee-increase-->****提议提高 LN 默认手续费：**Rusty Russell 提议提高节点使用的默认通道内手续费，从 1,000 millisatoshis（msat）加 1 百万分之一（ppm）提高到 5,000 msat 加 500 ppm。他指出，目前的默认值留给用户下调手续费的空间不多；而那些收取更高手续费的节点颇受欢迎，说明许多用户眼下对费率并不敏感。他在邮件中附了一张表，按 1 BTC 兑 10,000 美元估算不同转账金额在改动前后的成本：

  | 金额 |  之前       | 之后         |
  |------|-------------|--------------|
  | 0.1美分 |  0.0100001美分 |  0.05005美分 |
  | 1美分   |  0.010001美分  |  0.0505美分  |
  | 10美分  |  0.01001美分   |  0.055美分   |
  | $1      |  0.0101美分    |  0.1美分     |
  | $10     |  0.011美分     |  0.55美分    |
  | $100    |  0.02美分      |  5.05美分    |
  | $1000   |  0.11美分      |  50.05美分   |

  C-Lightning 共同维护者 ZmnSCPxj 和 Eclair 维护者 Pierre-Marie Padiou 表示支持该提议。LND 维护者 Olaoluwa Osuntokun 则认为该提议的推理存在多处缺陷，主张应“教育潜在的路由节点运营者遵循最佳实践，提供分析工具[...]，并把定价交给市场参与者，让他们自行收敛到稳定状态下经济上合理的手续费水平”。截至本文写作时，相关讨论仍在继续。

- **<!--conference-summary-cryptoeconomic-systems-summit-->****会议总结：加密经济系统峰会：**上周末在麻省理工学院校园举行的这场会议，涵盖了让加密货币既有用又安全的各种话题。视频现已在 [DCI 的 YouTube 频道][css vids]上提供，其中多场演讲由 Bryan Bishop 等人[转录][css ts]成文字。在已转录的那部分演讲中，我们认为以下三个主题可能对本 Newsletter 的读者有特别的技术价值：

  - **<!--everything-is-broken-->***一切皆已破碎*，Cory Fields 主讲（[文字稿][fields ts]，[视频][fields vid]）。这场演讲指出，比特币面临的威胁不仅来自自身的软件缺陷，也来自它所依赖的库、操作系统乃至硬件中被引入的缺陷。随后 Fields 回顾了另一大开源项目 Mozilla Firefox 的历史：当时某些类别的缺陷大量出现，而该项目颇有远见，十年前就开始开发一门新编程语言（Rust），希望借助它更强的自动保证，从类别上消除其中一些问题。最后，Fields 请听众思考：我们现在可以发起哪些行动，能在未来十年里帮助从类别上消除比特币用户和开发者眼下仍需担心的某些问题。

  - **<!--near-misses-what-could-have-gone-wrong-->***险情回顾：本可能出什么问题*，Ethan Heilman 主讲（[文字稿][heilman ts]，[视频][heilman vid]）。他梳理了比特币历史上五个险些造成用户资金或用户信心重大损失的问题。梳理之后，Heilman 请听众设想：今天比特币若发生最坏的软件故障会是什么样子；或者，如果此前遇到的某个问题被攻击者利用到极致，结果会怎样。我们建议大家也做做这个练习：它固然会凸显比特币中依然存在的危险，但也可能让你看清比特币在某些方面比你最初以为的更安全。

  - **<!--the-quest-for-practical-threshold-schnorr-signatures-->***寻找实用的门限 schnorr 签名*，Tim Ruffing 主讲（[文字稿][ruffing ts]，[视频][ruffing vid]），介绍讲者及其同事为寻找一种安全、紧凑、实用且灵活的门限 schnorr 签名方案所做的研究。Ruffing 首先区分了一般化的门限签名与多重签名这一特例：门限签名允许一组签名者中的一个子集签名（例如 k-of-n），多重签名则是门限签名的特例，要求全组签名（n-of-n）。MuSig（参见 [Newsletter #35][musig libsecp256k1-zkp]）和 [MSDL][] 等协议提供了与 [bip-schnorr][] 兼容的多重签名，但供签名者子集使用的门限签名，尚未解决到同等程度。

    作为未决问题的一个例子，Ruffing 指出，现有的基于离散对数问题（DLP）的门限签名方案，其安全性证明都假设多数潜在签名者是诚实的。因此 2-of-3 的配置是安全的，因为你所设想的最坏情况只有一个不诚实的签名者（少于多数）。而在 6-of-9 的配置中，你希望该方案能抵御多达五个不诚实的签名者——可五个签名者已经构成多数，这就动摇了安全性证明所依赖的前提。

    另一个潜在问题是，此前描述的协议都假定每个参与者都有一种安全可靠的方式与其他所有参与者通信。能够窃听或操纵通信的人，可能据此还原出最终的私钥，从而随意签署任何一笔支出。这个问题看似可以解决，但所提出的方案目前还没有安全性证明。

    Ruffing 最后列了一份清单，说明他希望基于 schnorr 的门限签名方案具备哪些特性，其中还包括若干进取目标。

## 值得注意的代码和文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的变更。*

- [Bitcoin Core #15437][] 移除了对 [BIP61][] P2P 协议 `reject` 消息的支持。这些消息此前已在 Bitcoin Core 0.18.0（2019 年 5 月）的发布说明中被[宣布][bip61 release note]弃用，并将在即将发布的 0.19.0 中默认禁用。这项移除改动位于主开发分支，预计随 0.20.0 发布——距 [Newsletter #13][pr14054] 首次报道弃用已有一年多，后续进展见 [Newsletter #37][bip61 discussion] 和 [Newsletter #38][bip61 decision]。

- [Bitcoin Core #17056][] 新增了一个 `sortedmulti` [输出脚本描述符][output script descriptor]，按 [BIP67][] 所述字典序对它接收到的公钥排序。这样就能为要求使用 BIP67 的钱包导入基于 xpub 的描述符，例如多重签名模式下的 Coldcard 硬件钱包。

- [LND #3561][] 新增了一个通道验证包，把验证通道的逻辑统一起来：无论通道开启数据来自第三方对等节点，还是来自本地比特币节点这类第一方数据源，都走同一套逻辑。这有助于从根源上解决 LND 中导致近期多个 LN 实现受影响的那批漏洞（参见 [Newsletter #66][lnd vulns]）。

- [C-Lightning #3129][] 新增了一个启动选项 `--encrypted-hsm`，会提示用户输入密码短语，用于加密 HD 钱包的种子（若当前未加密）或解密该种子（若已加密）。

{% include linkers/issues.md issues="15437,17056,3561,1165,3129" %}
[lnd repo doc]: https://github.com/lightningnetwork/lnd/blob/master/build/release/README.md
[bitcoin core 0.19.0]: https://bitcoincore.org/bin/bitcoin-core-0.19.0/
[lnd 0.8.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.8.0-beta
[c-lightning 0.7.3]: https://github.com/ElementsProject/lightning/releases/tag/v0.7.3rc2
[32 byte pubkey]: /zh/newsletters/2019/08/14/#proposed-change-to-schnorr-pubkeys
[p2sh-wrapped taproot]: /zh/newsletters/2019/09/25/#comment-if-you-expect-to-need-p2sh-wrapped-taproot-addresses
[tapscript resource limits]: /zh/newsletters/2019/09/25/#tapscript-resource-limits
[musig libsecp256k1-zkp]: /zh/newsletters/2019/02/26/#musig
[MSDL]: https://eprint.iacr.org/2018/483.pdf
[pr14054]: /zh/newsletters/2018/09/18/#bitcoin-core-14054
[bip61 release note]: https://bitcoincore.org/en/releases/0.18.0/#deprecated-p2p-messages
[bip61 discussion]: /zh/newsletters/2019/03/12/#removal-of-bip61-p2p-reject-messages
[bip61 decision]: /zh/newsletters/2019/03/19/#bip61-reject-messages
[lnd vulns]: /zh/newsletters/2019/10/02/#full-disclosure-of-fixed-vulnerabilities-affecting-multiple-ln-implementations
[taproot update]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-October/017378.html
[fields ts]: https://diyhpl.us/wiki/transcripts/cryptoeconomic-systems/2019/everything-is-broken/
[fields vid]: https://www.youtube.com/watch?v=UDbl-2gk7n0
[heilman ts]: https://diyhpl.us/wiki/transcripts/cryptoeconomic-systems/2019/near-misses/
[heilman vid]: https://www.youtube.com/watch?v=VAlq7vt0eIE
[ruffing ts]: https://diyhpl.us/wiki/transcripts/cryptoeconomic-systems/2019/threshold-schnorr-signatures/
[ruffing vid]: https://www.youtube.com/watch?v=Wy5jpgmmqAg
[css ts]: https://diyhpl.us/wiki/transcripts/cryptoeconomic-systems/2019/
[css vids]: https://www.youtube.com/channel/UCJkYmuzqAnIKn3NPg5lc0Wg/videos
[eclair 0.3.2]: https://github.com/ACINQ/eclair/releases/tag/v0.3.2
[output script descriptor]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
