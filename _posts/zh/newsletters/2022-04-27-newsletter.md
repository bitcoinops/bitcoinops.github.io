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

## News

- **<!--discussion-about-activating-ctv-->****关于激活 CTV 的讨论：**
  Jeremy Rubin [发帖][rubin ctv-st]到 Bitcoin-Dev 邮件列表，介绍了他计划发布的一款软件。该软件允许矿工开始表示他们是否打算执行提议中的 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]（CTV）操作码所定义的 [BIP119][] 规则。如果在接下来的若干个 2,016 个区块（约两周）的难度调整周期中，有 90% 的区块给出积极信号，那么任何运行 Rubin 软件的用户将从 11 月初左右开始自行强制执行 CTV 的规则。

  Rubin 详细阐述了他认为比特币用户如今可能希望激活 CTV 的多项理由，例如：

  - **<!--consistency-->***一致性：* CTV 拥有稳定的规范与实现
  - **<!--popularity-->***普及度：* 社区内不少知名个人与机构支持 CTV
  - **<!--viability-->***可行性：* 目前尚无意见认为 CTV 会破坏比特币任何重要且被广泛期望的属性
  - **<!--desirability-->***需求性：* CTV 能提供用户需要的功能，例如基于[契约][topic covenants]的[保险库][topic vaults]

  在邮件列表中，十余位开发者回复了 Rubin 的邮件或在其他线程中讨论。我们无法完整概述所有值得注意的回复，以下摘录的是部分颇具启发性的观点：

  - **<!--analyzed-->**Anthony Towns [分析][towns ctv signet]了 CTV [Signet 测试网][topic signet]上的交易。几乎所有交易似乎均由同一套软件（[Sapio][Sapio]）构建，这可能意味着公众对 CTV 的探索仍然有限。他进一步指出，引入新的共识规则会给所有比特币用户带来风险——即便是那些不打算使用该新功能的人——因此有必要向不采用者提供公开的证据，证明该功能“对他人来说足够有价值，足以抵偿这些风险”。在这篇帖子之后，又有[更多实验][fiatjaf vault]在 CTV Signet 上进行。

  - **<!--argued-->**Matt Corallo 也[提出][corallo ctv cost]，改变共识规则会为所有人带来显著成本，因此我们只有在确信某项提议能提供最大价值时才应当尝试软分叉。就契约而言，Corallo 希望看到“最灵活、最有用，并且最好是私密”的设计。他[随后表示][corallo not clear]：“就我所见，目前还不清楚 CTV 是否真的一个优秀的选项。”

  - **<!--noted-->**Russell O'Connor 在 #bitcoin-wizards IRC 中[指出][oconnor wizards]，使用 CTV 的某些方式无法通过现有比特币地址格式（如 base58check、[Bech32][topic bech32] 或 bech32m）表达。以 *裸脚本*（直接出现在 scriptPubKey 中的脚本）方式使用 CTV 将要求钱包开发者仅在其内部交易中使用裸 CTV，或者编写专用工具来传递通常包含于地址中的信息。另一种选择是，钱包若想在某些场景下使用 CTV（例如 [保险库][topic vaults]），可以先接收至承诺未来使用裸 CTV 的 P2TR 地址。
    O'Connor 关于地址限制的讨论被 Towns [提及][towns bare]于邮件列表。O'Connor 又[回复][oconnor bare]了更多细节，并指出如果裸 CTV 不包含在 BIP119 规范内，他会提倡一种更简单、更易组合（更容易与其他操作码结合以构建有用脚本）的不同设计——尽管他更偏好更通用的 `OP_TXHASH` 设计（见 [Newsletter #185][news185 txhash]）。Rubin [回应][rubin bare]了数点反驳意见。

  - **<!--relayed-->**David Harding [转述][harding transitory]了一个担忧：CTV 也许在长期内不会被广泛使用，要么是因为其应用场景未能实现，要么是因为其他契约构造可以更好地满足主流需求。这将使未来的共识代码开发者不得不永久维护 CTV 代码，并分析其与后续提议共识变更的潜在交互。Harding 建议暂时向比特币中加入 CTV，为期五年，在此期间收集实际使用数据，然后自动禁用 CTV，除非五年后的比特币用户决定值得保留。没有回应者支持此方案，多数人认为其成本过高或收益过低。同时有人指出，未来若想完全验证 CTV 处于激活状态期间产生的区块，仍然需要 CTV 校验代码，因此即便五年后禁用该操作码，也可能仍需永久维护其代码。

  - **<!--requested-->**Antoine “Darosior” Poinsot [请求][darosior apo]就激活略经修改的 [BIP118][] `SIGHASH_ANYPREVOUT`（[APO][topic sighash_anyprevout]）而非 CTV，或至少先于 CTV 激活 APO，征求意见。该修改版本的 APO 可模拟 CTV 的能力，但在某些应用中成本更高。激活 APO 还将使其可用于其最初设想的用途——为 LN 引入拟议中的 [Eltoo][topic eltoo] 层，借此实现更高效且（有人认为）更安全的通道状态更新。

  - **<!--suggested-->**James O'Beirne [提出][obeirne benchmark]，他基于 CTV 的 [simple vault][] 设计可作为评估不同契约方案的基准，因为它简单，并且在他看来若能投入生产使用，能够显著提升许多比特币用户的安全性。Darosior 首个接受此挑战，将 simple vault 代码[移植][darosior vault]到了 `SIGHASH_ANYPREVOUT` 的实现上。

  截至本文撰写时，邮件列表上的讨论仍十分活跃。关于 CTV 与契约技术的有趣对话还出现在 Twitter、IRC、Telegram 等多个渠道。我们鼓励这些讨论的参与者将任何重要见解分享到 Bitcoin-Dev 邮件列表。

  在上述讨论之后，Jeremy Rubin [宣布][rubin path forward]他不会立即发布可让 CTV 激活的软件二进制版本，而是将评估收到的反馈，并与其他 CTV 支持者合作，可能提出修订后的激活计划。Optech 将在之后的 Newsletter 中继续跟进该话题。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是许多 Optech 贡献者寻找答案的首选之地；当我们有空时，也会在此帮助有疑问的用户。在本月专栏中，我们汇总了自上次更新以来收到高票的部分问答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--how-was-the-generator-point-g-chosen-in-the-secp256k1-curve-->**[secp256k1 曲线中的生成元点 G 是如何选取的？]({{bse}}113116)
  Pieter Wuille 提到，虽然关于常数[生成元点 G][se 29904] 的确切选取缘由并未公开，但其具备的一个不寻常属性或许能暗示其构造方式。

- **<!--what-is-the-maximum-realistic-p2p-message-payload-size-->**[P2P 消息有效载荷的最大、现实尺寸是多少？]({{bse}}113059)
  0xb10c 询问是否存在大小为 `MAX_SIZE`（32 MB）的有效 [P2P 消息][p2p messages]。Pieter Wuille 解释说，`MAX_PROTOCOL_MESSAGE_LENGTH`（4 MB，[segwit 调整][Bitcoin Core #8149]将其从 [2 MB][Bitcoin Core #5843] 增至 4 MB）才是真正限制入站消息大小，以防范拒绝服务攻击。

- **<!--is-there-evidence-for-lack-of-stale-blocks-->**[有没有证据表明“陈旧区块”数量减少？]({{bse}}113413)
  Lightlike 引用了 [KIT statistics][] 网站上一张历史区块传播时间图，并指出[致密区块中继][topic compact block relay]（[BIP152][]，最初实现在 [#8068][Bitcoin Core #8068] 中）是导致[陈旧区块][se 5866]频率随时间下降的因素之一。

  {:.center}
  ![区块传播延迟历史图](/img/posts/2022-04-block-propagation-delay.png)

- **<!--does-a-coinbase-transaction-s-input-field-have-a-vout-field-->**[coinbase 交易的输入字段是否包含 VOUT？]({{bse}}113392)
  Pieter Wuille 概述了 coinbase 交易输入的要求：前序输出哈希必须为 `0000000000000000000000000000000000000000000000000000000000000000`，前序输出索引必须为 `ffffffff`，`scriptSig` 长度必须在 2–100 字节之间，并且自 [BIP34][] 起 `scriptSig` 还必须以区块高度开头。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选版本。请考虑升级到新版或帮助测试候选版本。*

- [Bitcoin Core 23.0][] 是这一主流全节点软件的下一主要版本。[发行说明][bcc23 rn]罗列了多项改进，包括：对新钱包默认启用[描述符][topic descriptors]钱包；描述符钱包现已轻松支持使用 [taproot][topic taproot] 的 [bech32m][topic bech32] 地址收款。

- [Core Lightning 0.11.0][] 是这一热门闪电网络节点软件的下一个主要版本。除其他功能与修复外，新版本支持与同一对等节点建立多条活动通道，并支持支付[无状态发票][topic stateless invoices]。

- [Rust-Bitcoin 0.28][] 为该比特币库的最新版本。最显著的变化是加入对 taproot 的支持，并改进了相关 API（例如 [PSBTs][topic psbt]）。更多改进与修复详见[发行说明][rb28 rn]。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]中的值得注意的变更。*

- [LND #5157][] 新增 `--addpeer` 启动选项，可在启动时与指定节点建立对等连接。

- [LND #6414][] 在启用的情况下开始在节点公告中声明对 keysend [自发支付][topic spontaneous payments]的支持。LND 自 2019 年起便已支持 keysend，但最初并无法让节点宣告自身支持。其他 LN 节点软件在节点公告中已添加此功能，此次合并的拉取请求让 LND 与之保持一致。


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
