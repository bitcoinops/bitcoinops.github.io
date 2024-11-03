---
title: 'Bitcoin Optech Newsletter #68'
permalink: /zh/newsletters/2019/10/16/
name: 2019-10-16-newsletter-zh
slug: 2019-10-16-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 宣布了最新的 LND 版本发布、请求对 Bitcoin Core 和 C-Lightning 发布候选版本的测试，传达了关于 Taproot 提案的更新，描述了对默认闪电网络（LN）路由费用的增加提议，并总结了近期加密经济系统峰会上的三场演讲。此外，还包括我们定期更新的值得注意的比特币基础设施项目的变更内容。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- **<!--upgrade-lnd-to-version-0-8-0-beta-->****将 LND 升级到 0.8.0-beta 版本：**[LND 的最新版本][lnd 0.8.0-beta]使用了更具扩展性的包格式、提高了备份的安全性、增加了守望塔客户端的集成、使路由更有可能成功，并包含许多其他新功能和漏洞修复。

- **<!--upgrade-to-eclair-0-3-2-->****将 Eclair 升级到 0.3.2 版本：**[Eclair 的最新版本][eclair 0.3.2]改进了备份功能，使同步 gossip 数据更加节省带宽（尤其是针对非路由节点，如移动设备上的节点），并包含许多其他新功能和漏洞修复。

- **<!--review-rcs-->****审查 RCs：**两个流行的比特币基础设施项目已经发布了下一版本软件的发布候选版本（RCs）。我们鼓励开发者和有经验的用户帮助测试这些 RCs，以便在公开发布之前发现并修复任何问题：

  - [Bitcoin Core 0.19.0rc1][bitcoin core 0.19.0]
  - [C-Lightning 0.7.3-rc2][c-lightning 0.7.3]

## 新闻

- **<!--taproot-update-->****Taproot 更新：**Pieter Wuille 向 Bitcoin-Dev 邮件列表发送了一封[邮件][taproot update]，总结了该提案的近期变化。变化包括：

  * 使用 32 字节的公钥代替 33 字节的公钥（在 [Newsletter #59][32 byte pubkey] 中提到）。

  * 不支持 P2SH 封装的 Taproot 地址（在 [#65][p2sh-wrapped taproot] 中提到）。

  * 签名哈希数据中的交易输入位置从 16 位索引改为 32 位。

  * 在 [bip-schnorr][] 中现在使用标记哈希。此前仅在 [bip-taproot][] 和 [bip-tapscript][] 中使用。

  * 从 [bip-tapscript][] 中移除了 10,000 字节和 201 非推送操作码的限制（在 [#65][tapscript resource limits] 中提到）。

  * Merkle 树的最大深度从 32 层增加到 128 层。

  Wuille 的邮件和更新的 BIPs 为这些决定提供了合理解释，并链接了之前关于这些决定的讨论。

- **<!--proposed-default-ln-fee-increase-->****提议的默认 LN 费用增加：**Rusty Russell 提议将节点使用的默认通道内费用从 1,000 millisatoshis (msat) 加 1 百万分之一 (ppm) 增加到 5,000 msat 加 500 ppm。他指出当前的默认值没有太多空间让用户降低费用，并且许多当前收取更高费用的节点表明用户对费用不太敏感。他的邮件提供了一张估算表，显示在 BTC/USD 汇率为 10,000 美元时，转移不同金额的旧费用和新费用的对比：

  | 金额 |  之前       | 之后         |
  |------|-------------|--------------|
  | 0.1美分 |  0.0100001美分 |  0.05005美分 |
  | 1美分   |  0.010001美分  |  0.0505美分  |
  | 10美分  |  0.01001美分   |  0.055美分   |
  | $1      |  0.0101美分    |  0.1美分     |
  | $10     |  0.011美分     |  0.55美分    |
  | $100    |  0.02美分      |  5.05美分    |
  | $1000   |  0.11美分      |  50.05美分   |

  C-Lightning 的共同维护者 ZmnSCPxj 和 Eclair 的维护者 Pierre-Marie Padiou 对该提案表示支持。LND 的维护者 Olaoluwa Osuntokun 则认为该提案的推理存在多个缺陷，主张应“教育潜在的路由节点运营者关于最佳实践，提供分析工具[...]，并让市场参与者自行确定合理的稳定费用水平”。截至撰写时，关于该主题的讨论仍在继续。

- **<!--conference-summary-cryptoeconomic-systems-summit-->****会议总结：加密经济系统峰会：**上周末在麻省理工学院举办的这个会议涵盖了确保加密货币既有用又安全的各种话题。视频现已由 [DCI 的 YouTube 频道][css vids]提供，[多场演讲的文字稿][css ts]也由 Bryan Bishop 等人提供。在已[记录的演讲][css ts]中，我们认为以下三个主题可能对本 Newsletter 的读者特别具有技术意义：

  - **<!--everything-is-broken-->***一切都已破碎*，由 Cory Fields 主讲（[文字稿][fields ts]，[视频][fields vid]），该演讲描述了比特币不仅受到自身软件漏洞的威胁，还受到其依赖的库、操作系统甚至硬件引入的漏洞的威胁。Fields 回顾了另一重要开源项目 Mozilla Firefox 十年前的情况，当时某些类型的漏洞数量众多，Firefox 项目通过启动一项新编程语言（Rust）的开发，试图从根本上消除这些问题。最后，Fields 邀请观众思考我们现在可以启动哪些措施，能在未来十年内帮助从根本上消除比特币用户和开发者当前需要担心的一些问题。

  - **<!--near-misses-what-could-have-gone-wrong-->***近距离错过：可能出错的地方*，由 Ethan Heilman 主讲（[文字稿][heilman ts]，[视频][heilman vid]），回顾了比特币历史上的五个问题，这些问题可能导致用户资金或用户信心的重大损失。在总结之后，Heilman 邀请观众思考当前比特币软件中可能出现的最糟糕失败情况，或者如果其中一个已遭遇的问题被攻击者充分利用，可能会发生什么。我们建议尝试这种练习：它显然会强调比特币中仍然存在的风险，但也可能帮助突出比特币比你最初预期的更安全的方式。

  - **<!--the-quest-for-practical-threshold-schnorr-signatures-->***追求实用的门限 Schnorr 签名*，由 Tim Ruffing 主讲（[文字稿][ruffing ts]，[视频][ruffing vid]），描述了演讲者和他的同事们在寻找一种安全、紧凑、实用且灵活的门限 Schnorr 签名方案方面的研究。Ruffing 首先描述了广义门限签名和多重签名的区别。门限签名允许一组中的一个子集签名（例如 k-of-n）；多重签名是门限签名的一个特殊情况，整个组签名（n-of-n）。像 MuSig（参见 [Newsletter #35][musig libsecp256k1-zkp]）和 [MSDL][] 协议提供了与 [bip-schnorr][] 兼容的多重签名，但针对部分签名者的门限签名尚未得到同样程度的解决。

    作为一个未解决问题的例子，Ruffing 指出，现有的基于离散对数问题（DLP）的门限签名方案的安全性证明假设大多数潜在签名者是诚实的。因此，2-of-3 的安排是安全的，因为最坏的情况是一个不诚实的签名者（这少于多数）。在 6-of-9 的安排中，你希望该方案能防范最多五个不诚实的签名者——但五个签名者将构成多数，破坏安全性证明中的预期。

    另一个潜在问题是，之前描述的协议期望每个参与者都能与其他所有参与者进行安全可靠的通信。能够窃听或操纵通信的人可能能够恢复最终的私钥，允许他们签署任何他们想要的支出。这似乎是可以解决的，但提出的解决方案尚无安全性证明。

    Ruffing 最后列出了他希望在基于 Schnorr 的门限签名方案中看到的功能清单，其中包括几个扩展目标。

## 值得注意的代码和文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的变更。*

- [Bitcoin Core #15437][] 移除了对 [BIP61][] P2P 协议 `reject` 消息的支持。这些消息之前在 Bitcoin Core 0.18.0（2019 年 5 月）[宣布][bip61 release note]被弃用，并将在即将发布的 0.19.0 版本中默认禁用。此变更属于主开发分支的一部分，预计将在 0.20.0 版本中发布，距最初宣布弃用已有一年多时间，这在 [Newsletter #13][pr14054] 中有所涉及，并在 [Newsletter #37][bip61 discussion] 和 [Newsletter #38][bip61 decision] 中进行了跟进。

- [Bitcoin Core #17056][] 添加了一个 `sortedmulti` [输出脚本描述符][output script descriptor]，使用 [BIP67][] 中描述的字典顺序对提供的公钥进行排序。这使得可以为需要使用 BIP67 的钱包导入基于 xpub 的描述符，例如在多重签名模式下的 Coldcard 硬件钱包。

- [LND #3561][] 添加了一个新的通道验证包，统一了验证通道的逻辑，无论通道打开数据是从第三方对等方接收，还是从本地比特币节点这样的第一方数据源接收。这有助于解决 LND 中最近影响多个 LN 实现的漏洞的根本原因（参见 [Newsletter #66][lnd vulns]）。

- [C-Lightning #3129][] 添加了一个新的启动选项 `--encrypted-hsm`，该选项将提示用户提供一个密码短语，该密码短语将用于加密 HD 钱包的种子（如果当前未加密）或解密它（如果已加密）。

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
[taproot update]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-October/017378.html
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
