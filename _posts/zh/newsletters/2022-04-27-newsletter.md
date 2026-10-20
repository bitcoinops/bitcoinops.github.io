---
title: 'Bitcoin Optech Newsletter #197'
permalink: /zh/newsletters/2022/04/27/
name: 2022-04-27-newsletter-zh
slug: 2022-04-27-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了关于激活 `OP_CHECKTEMPLATEVERIFY` 的讨论，并照例收录了 Bitcoin Stack Exchange 精选问答、最新的软件发布与候选发布，以及热门比特币基础设施软件的近期变更。

## 新闻

- **<!--discussion-about-activating-ctv-->****关于激活 CTV 的讨论：**
  Jeremy Rubin 在 Bitcoin-Dev 邮件列表上[发帖][rubin ctv-st]，说明了他计划发布的一款软件。该软件允许矿工开始通过信号表明自己是否打算执行 [BIP119][] 中为拟议的 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]（CTV）操作码所定的规则。如果在接下来几个 2,016 个区块（两周）的难度调整周期中的任意一个里，有 90% 的区块发出积极信号，那么任何使用 Rubin 软件的用户将从 11 月初左右开始自行强制执行 CTV 的规则。

  Rubin 详细阐述了多项理由，说明他认为比特币用户如今可能希望激活 CTV，例如：

  - **<!--consistency-->***一致性：* CTV 拥有稳定的规范与实现

  - **<!--popularity-->***普及度：* 比特币社区内不少知名个人与机构支持 CTV

  - **<!--viability-->***可行性：* 目前似乎没有反对意见认为 CTV 违反了比特币任何备受重视的特性

  - **<!--desirability-->***需求性：* CTV 能提供用户想要的功能，例如基于[契约][topic covenants]的[保险库][topic vaults]

  在邮件列表上，有十几个人作了回复，或直接回复 Rubin 的邮件，或在其他讨论帖中讨论。我们无法完整概述所有值得注意的回复，以下摘录的是其中一些我们觉得特别有意思的观点：

  - **<!--analyzed-->**Anthony Towns [分析][towns ctv signet]了 CTV [signet][topic signet] 上的交易。几乎所有交易看起来都是用同一套软件（[Sapio][Sapio]）构建的，这可能说明公众对 CTV 的探索还比较有限。他进一步指出，修改共识规则以新增功能会给所有比特币用户带来风险——即便是那些不打算使用该新功能的人——因此有必要向不采用者提供公开证据，证明该功能“对他人来说足够有价值，足以抵偿这些风险”。在这篇帖子之后，又有[更多实验][fiatjaf vault]在 CTV signet 上进行。

  - **<!--argued-->**Matt Corallo 也[主张][corallo ctv cost]，改变共识规则会给每个人带来显著成本，因此只有在确信某项提议能带来一次变更所能提供的最大价值时，我们才应当尝试软分叉。就契约而言，Corallo 希望看到“最灵活、最有用，并且最好是私密”的设计。他[随后表示][corallo not clear]：“就我所见，目前还不清楚 CTV 是否真的是一个好选项。”

  - **<!--noted-->**Russell O'Connor 在 #bitcoin-wizards IRC 中[指出][oconnor wizards]，提议的 CTV 使用方式中有一种无法用现有的比特币地址格式（如 base58check、[bech32][topic bech32] 或 bech32m）来表达。这种通过 *裸脚本*（直接出现在 scriptPubKey 中的脚本）来使用 CTV 的方式，将要求钱包开发者只在自家内部交易中使用裸 CTV，或者编写专用工具来传递通常包含在地址中的信息。另一种做法是，想在某些应用（例如 [保险库][topic vaults]）中使用 CTV 的钱包，可以把款项收到一个承诺日后使用裸 CTV 的 P2TR 地址上。

    Towns 在邮件列表中[提到][towns bare]了 O'Connor 关于地址限制的讨论。O'Connor [回复][oconnor bare]了更多细节，并指出如果对裸 CTV 的支持不属于 BIP119 对 CTV 的规范内容，他会主张采用另一种更简单、也更易组合（更容易与其他操作码结合以构建有用的脚本）的设计——不过除此之外，他更偏好更通用的 `OP_TXHASH` 设计（见 [Newsletter #185][news185 txhash]）。Rubin [回应][rubin bare]了数点反驳意见。

  - **<!--relayed-->**David Harding [转述][harding transitory]了一个担忧：CTV 也许在长期内得不到多少使用，要么是因为其用途未能显现，要么是因为其他契约构造能更好地满足主流需求。这将使未来的共识代码开发者不得不永久维护 CTV 代码，并分析其与后来提出的共识变更之间的潜在交互。Harding 建议暂时把 CTV 加入比特币，为期五年，在此期间收集人们如何使用它的数据，然后自动禁用它——除非五年后的比特币用户认为值得保留。没有回应者支持这一方案，多数人认为其成本过高或收益过低。也有人指出，未来任何人若要完整验证 CTV 处于激活状态期间产生的区块，仍然需要 CTV 校验代码，因此即便五年后禁用了该操作码，CTV 代码也可能需要永久维护。

  - **<!--requested-->**Antoine “Darosior” Poinsot [征求][darosior apo]意见：是否改为激活略经修改的 [BIP118][] `SIGHASH_ANYPREVOUT`（[APO][topic sighash_anyprevout]），而不用 CTV，或至少先于 CTV 激活。该修改版本的 APO 可以模拟 CTV 的能力，但在某些应用中成本更高。激活 APO 还能让它可用于最初设想的用途——为 LN 启用拟议中的 [Eltoo][topic eltoo] 层，从而实现更高效、且可以说更安全的 LN 通道状态更新。

  - **<!--suggested-->**James O'Beirne [提出][obeirne benchmark]，他基于 CTV 的 [simple vault][] 设计可作为评估不同契约方案的基准，因为它简单，而且据他估计，若能投入生产使用，它可以显著提升许多比特币用户的安全性。Darosior 第一个接受了这个挑战，把 simple vault 代码从 CTV [移植][darosior vault]到 `SIGHASH_ANYPREVOUT` 的一种实现上。

  截至本文撰写时，邮件列表上的讨论仍十分活跃。关于 CTV 与契约技术的有趣对话还出现在 Twitter、IRC、Telegram 等多个渠道。我们鼓励这些讨论的参与者将任何重要见解分享到 Bitcoin-Dev 邮件列表。

  在上述讨论之后，Jeremy Rubin [宣布][rubin path forward]他不会立即发布可让 CTV 激活的软件二进制版本，而是将评估收到的反馈，并与其他 CTV 支持者合作，可能提出修订后的激活计划。Optech 将在之后的 Newsletter 中继续跟进该话题。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们有点空闲时帮助好奇或困惑用户的地方。在本月栏目中，我们精选自上次更新以来得票最高的一些问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--how-was-the-generator-point-g-chosen-in-the-secp256k1-curve-->**[secp256k1 曲线中的生成元点 G 是如何选取的？]({{bse}}113116)
  Pieter Wuille 提到，虽然关于常数[生成元点 G][se 29904] 的确切选取缘由并未公开，但其具备的一个不寻常属性或许能暗示其构造方式。

- **<!--what-is-the-maximum-realistic-p2p-message-payload-size-->**[P2P 消息有效载荷的最大、现实尺寸是多少？]({{bse}}113059)
  0xb10c 询问是否存在大小为 `MAX_SIZE`（32 MB）的有效 [P2P 消息][p2p messages]。Pieter Wuille 解释说，`MAX_PROTOCOL_MESSAGE_LENGTH`（4 MB，即[该协议常量][bitcoin protocol 4mb]，在 [segwit 的改动][Bitcoin Core #8149] 中从 [2 MB][Bitcoin Core #5843] 提高而来）才是真正限制入站消息大小、以防拒绝服务攻击的机制。

- **<!--is-there-evidence-for-lack-of-stale-blocks-->**[有没有证据表明陈旧区块很少？]({{bse}}113413)
  Lightlike 引用了 [KIT statistics][] 网站上一张历史区块传播时间图，并指出[紧凑区块中继][topic compact block relay]（[BIP152][]，最初实现在 [#8068][Bitcoin Core #8068] 中）是导致[陈旧区块][se 5866]频率随时间下降的因素之一。

  {:.center}
  ![区块传播延迟历史图](/img/posts/2022-04-block-propagation-delay.png)

- **<!--does-a-coinbase-transaction-s-input-field-have-a-vout-field-->**[币基交易的输入字段是否包含 VOUT？]({{bse}}113392)
  Pieter Wuille 概述了 币基交易输入的要求：前序输出哈希必须为 `0000000000000000000000000000000000000000000000000000000000000000`，前序输出索引必须为 `ffffffff`，`scriptSig` 长度必须在 2–100 字节之间，并且自 [BIP34][] 起 `scriptSig` 还必须以区块高度开头。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [Bitcoin Core 23.0][] 是这一主流全节点软件的下一主要版本。[发布说明][bcc23 rn]罗列了多项改进，包括：对新钱包默认启用[描述符][topic descriptors]钱包；描述符钱包现已能轻松支持用 [taproot][topic taproot] 的 [bech32m][topic bech32] 地址收款。

- [Core Lightning 0.11.0][] 是这一热门 LN 节点软件下一主要版本的发布。除了其他功能与缺陷修复外，新版本还支持与同一对等节点建立多条活动通道，并支持支付[无状态发票][topic stateless invoices]。

- [Rust Bitcoin 0.28][] 是该比特币库的最新版本。最显著的变化是增加了对 taproot 的支持，并改进了相关 API（例如 [PSBT][topic psbt]）。其他改进与缺陷修复详见[发布说明][rb28 rn]。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]中的值得注意的变更。*

- [LND #5157][] 新增 `--addpeer` 启动选项，可在启动时与指定节点建立对等连接。

- [LND #6414][] 在启用该功能时，开始在自己的节点公告中声明支持 keysend [自发支付][topic spontaneous payments]。LND 自 2019 年起就已支持 keysend，但最初的部署方式并没有让节点宣告自己支持该功能。其他 LN 节点软件中的 keysend 实现会在节点公告中声明支持，此次合并的 PR 让 LND 也照此办理。


{% include references.md %}
{% include linkers/issues.md v=2 issues="5157,6414,5843,8149,8068" %}
[bitcoin core 23.0]: https://bitcoincore.org/bin/bitcoin-core-23.0/
[bcc23 rn]: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-23.0.md
[core lightning 0.11.0]: https://github.com/ElementsProject/lightning/releases/tag/v0.11.0.1
[rust-bitcoin 0.28]: https://github.com/rust-bitcoin/rust-bitcoin/releases/tag/0.28.0
[rb28 rn]: https://github.com/rust-bitcoin/rust-bitcoin/blob/master/CHANGELOG.md#028---2022-04-20-the-taproot-release
[rubin ctv-st]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020233.html
[towns ctv signet]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020234.html
[sapio]: https://learn.sapio-lang.org/
[corallo ctv cost]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020263.html
[corallo not clear]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020289.html
[oconnor wizards]: https://gnusha.org/bitcoin-wizards/2022-04-19.log
[towns bare]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020245.html
[oconnor bare]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020256.html
[rubin bare]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020260.html
[harding transitory]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020242.html
[darosior apo]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020276.html
[obeirne benchmark]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020280.html
[simple vault]: https://github.com/jamesob/simple-ctv-vault
[news185 txhash]: /zh/newsletters/2022/02/02/#composable-alternatives-to-ctv-and-apo
[fiatjaf vault]: https://twitter.com/fiatjaf/status/1517836181240782850
[rubin path forward]: https://twitter.com/JeremyRubin/status/1518477022439247872
[darosior vault]: https://twitter.com/darosior/status/1518961471702642689
[se 29904]: https://bitcoin.stackexchange.com/questions/29904/
[p2p messages]: https://developer.bitcoin.org/reference/p2p_networking.html#data-messages
[bitcoin protocol 4mb]: https://github.com/bitcoin/bitcoin/commit/2b1f6f9ccf36f1e0a2c9d99154e1642f796d7c2b
[KIT statistics]: https://www.dsn.kastel.kit.edu/bitcoin/index.html
[se 5866]: https://bitcoin.stackexchange.com/a/5866/87121
