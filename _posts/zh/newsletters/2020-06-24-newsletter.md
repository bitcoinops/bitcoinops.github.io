---
title: 'Bitcoin Optech Newsletter #103'
permalink: /zh/newsletters/2020/06/24/
name: 2020-06-24-newsletter-zh
slug: 2020-06-24-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了一种新发布的针对 LN 用户的手续费勒索攻击，链接了关于 LN 原子性攻击的后续讨论，并分享了关于在多方协议中使用 RIPEMD160 哈希的地址上发生碰撞攻击的提醒。此外，还包括我们常规部分中来自 Bitcoin Stack Exchange 的热门问答、本周发布的版本与候选版本列表以及对流行比特币基础设施项目的显著更改。

## 行动项

*本周无。*

## 新闻

- **<!--ln-fee-ransom-attack-->****LN 手续费勒索攻击：** René Pickhardt 向 Lightning-Dev 邮件列表[公开披露][pickhardt post]了一个他几乎在一年前私下向 LN 实现维护者披露的漏洞。在当前的 LN 协议中，每次更新通道状态时，发起开通通道的一方必须承诺支付单方面关闭交易的链上交易手续费。支付手续费的一方还可以选择使用的手续费率——但对手方的安全性也取决于选择的手续费率是否合适。这意味着如果对手方认为所选手续费率在当前市场条件下过低，他们可以随时关闭通道。为了避免这种不必要的关闭，[BOLT2][] 给出了一个例子，即支付手续费的一方选择比最低合理估计高五倍的手续费率——足够高以满足对手方的要求，即使他们使用的是不同的手续费估算法。

  BOLT2 还允许通道同时路由最多 483 笔支付，每笔支付需要一个 43 vbyte 的 P2WSH 输出，总共大约 20,000 vbyte 的数据需要相对较快地添加到链上——这意味着可能需要支付较高的手续费率。如果该手续费率比实际必要的高出五倍，那么在当前比特币价格下，支付的费用可能轻易超过 100 美元。此外，如果承诺交易被确认，那么 HTLC 也需要结算（同样使用时间敏感的交易，可能需要支付较高的手续费率）。如果受害者是负责向外路由这些支付的一方，他们将需要支付额外的交易手续费来恢复每笔支付，这可能使得攻击的成本增加两到三倍。

  手续费是支付给矿工的，因此没有直接动机去执行这种攻击，但如果攻击者能快速联系到受害者，那么他们可能会提议以一种离链方式结算 HTLC，以换取赎金，从而让攻击者获利。

  Pickhardt 在他的邮件中总结了几种解决这个问题的想法，但他认为都不完全令人满意。最初在 Eclair 中实现的缓解措施，后来在 C-Lightning 中实现（参见 [Newsletter #59][news59 cl30]）是限制 LN 节点的待处理支付数量，以保持交易量小并降低总费用。另一种正在开发的缓解措施是[锚定输出][topic anchor outputs]，这允许在关闭通道时选择手续费率——无需为了防止过早关闭通道而高估手续费。还提到了几种其他想法，但 Pickhardt 邀请读者思考这个问题并提出任何其他可能的解决方案。

- **<!--continued-discussion-about-ln-atomicity-attack-->****关于 LN 原子性攻击的后续讨论：** Bastien Teinturier 在 Lightning-Dev 邮件列表中[发布][teinturier post]了一份链接到 LN 承诺协议、其弱点及解决这些弱点的提案的[详细描述][teinturier gist]。该文档教导读者了解所有必要知识，以理解 [Newsletter #95][news95 ln attack] 中描述的 LN 原子性攻击以及几种提议的缓解措施。该文档清晰的写作将之前讨论中零散的几条线索串联起来，导致对几种先前提出的解决方案进行了重新评估，包括对“替代锚定提案”的有效性的担忧以及使用[无脚本支付签名][pay-for-signature]方案无信任地向第三方支付完成适配器签名所需的最终签名的[建议程序][zmn procedure]。

- **<!--reminder-about-collision-attack-risks-on-two-party-ecdsa-->****关于两方 ECDSA 碰撞攻击风险的提醒：** 密码学家 Jonas Nick 在 Bitcoin-Dev 邮件列表中回复了关于提议的 CoinSwap 实现的[讨论帖][news100 coinswap]，提醒开发者 P2PKH、P2WPKH 和 P2SH 地址使用的 160 位 RIPEMD160 哈希在多个方合作创建地址时使用简单协议时容易受到碰撞攻击，这会将其安全性降低到 80 位（参见我们关于传统 P2SH 地址的[安全性描述][address security]）。虽然这以前只对使用 P2SH 多签的用户构成威胁，但在如 CoinSwap 的上下文中，它同样适用于两个用户共享 P2PKH 或 P2WPKH 地址的情境。可以避免此问题，但需要将额外的承诺程序设计到两方 ECDSA 协议中，Nick 指出有些两方 ECDSA 协议和实现已经包含了这一点。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选之一——或者当我们有空时，也会帮助好奇或困惑的用户。在这个月度专题中，我们挑选了自上次更新以来发布的一些高票问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--why-was-the-current-formula-that-calculates-target-from-nbits-chosen-->**[为什么选择了当前从 'nBits' 计算 'target' 的公式？]({{bse}}96298) Ravi Patel 询问为什么没有选择一个更简单的公式来计算 'nBits' 的难度目标。Andrew Chow 详细讨论了这个公式、其历史，甚至引用了 Bitcoin 0.1.5 版本的示例代码。

- **<!--does-bitcoin-really-need-timestamps-->**[比特币真的需要时间戳吗？]({{bse}}96185) Pieter Wuille 解释了如果不参考区块链之外的时钟时间来限制区块速率，运行全节点可能会更昂贵，同时还难以保持低孤块率并防止勾结攻击。

- **<!--in-a-fee-overpayment-attack-why-can-t-compromised-software-provide-fake-previous-transactions-corresponding-to-fake-inputs-->**[在手续费超额支付攻击中，为什么被攻破的软件不能提供与假输入对应的假之前交易？]({{bse}}96309) 关于一个[手续费超额支付攻击][news101 fee overpayment attack]对含有多个输入的 segwit 交易的攻击，justinmoon 询问为什么此攻击的补救措施要求提供用于输入的之前交易的副本，而这不容易受到恶意软件提供假之前交易的攻击。由于提供的任何之前交易都必须有一个与支出输入的之前交易哈希匹配的哈希，因此这样的攻击是不可行的。

## 发布与候选发布

*流行比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [LND 0.10.2-beta.rc2][lnd 0.10.2-beta] 这个 LND 维护版本的候选版本现已可供测试。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的显著更改。*

- [Bitcoin Core #19260][] 断开发送 [BIP37][] `filterclear` 消息的对等节点连接，如果本地节点未接受布隆过滤器（如通过 [BIP111][] `NODE_BLOOM` 服务标志所广告的那样）。之前曾[提出][Bitcoin Core #8709]，处于初始区块链下载 (IBD) 的节点可以注册为非中继对等节点，以避免在下载大量区块时接收近期交易。当它们完成同步时，可以通过发送 `filterclear` 消息来切换到接收中继交易。然而，最近[提出][Bitcoin Core #19204]，可以使用 [BIP133][] `feefilter` 消息来代替。这消除了非布隆节点支持 `filterclear` 消息的任何需求，因此此 PR 删除了该功能。

- [Bitcoin Core #19133][] 添加了一个 bitcoin-cli `-generate` 参数（注意前导破折号），以替代已从 Bitcoin Core [0.19.0.1 版本][core version] 中删除的 `generate` RPC。新的实现避免了钱包和其他组件之间不必要的依赖。为以前的 RPC 提供客户端别名对手动测试很有用，并且使更新[破损的文档][broken docs]变得更容易。

- [Bitcoin Core #18027][] 为 GUI 的 *文件* 菜单增加了两个选项来处理部分签名的比特币交易（[PSBTs][topic psbt]）：*从文件加载 PSBT* 和 *从剪贴板加载 PSBT*。当点击其中一个选项并加载 PSBT 时，会提供一个对话框，允许用户在此钱包拥有其密钥时签署一个未完成的 PSBT，广播一个已完成的 PSBT，或复制或保存 PSBT 以便使用其他工具（如 [HWI][]）处理。结合其他最近的 PSBT 相关 GUI 更改（参见 Newsletters [#74][news74 psbtgui] 和 [#82][news82 psbtgui]）以及 [HWI 自己的 GUI][hwi gui]，这使得首次可以在不使用任何 RPC 的情况下在 Bitcoin Core 中使用基于 PSBT 的流程。

  ![Bitcoin Core GUI 中 PSBT 对话框的截图](/img/posts/2020-06-psbt-dialog.png)

- [Bitcoin Core #16377][] 更新了 `walletcreatefundedpsbt` 和 `fundrawtransaction` RPC。这些 RPC 通常使用钱包来自动选择要在未签名交易中花费的 UTXO，但它们也允许用户指定他们想要在该交易中花费的一个或多个 UTXO。以前，如果用户选择的 UTXO 不足以支付交易的所有输出，钱包会自动选择更多的 UTXO 来花费。但是，如果用户是手动选择 UTXO，他们可能有某种原因不希望花费额外的 UTXO，因此现在默认情况下，如果用户手动选择了任何 UTXO，这些 RPC 将会失败。可以使用这两个 RPC 中的新 `add_inputs` 参数来覆盖此默认设置。

- [Eclair #1461][] 增加了几个 API 端点，用于转发 Bitcoin Core RPC 以中继该程序的钱包余额和其他信息。其目标是使 Eclair 更容易与 [Ride The Lightning][] 节点管理仪表盘集成。

- [Bitcoin Core #19071][] 增加了描述开发人员如何为新的和实验性的 [Bitcoin Core GUI 仓库][bitcoin core gui repo]贡献代码的文档。与 GUI 相关的拉取请求应该提交到这个新仓库，该仓库将使用与 Linux 内核项目相同的 *monotree* 开发模型与[主仓库][bitcoin/bitcoin] 双向同步。用户不会从这次拆分中直接看到任何变化——他们仍然会在官方打包的 Bitcoin Core 版本中或在主仓库源代码中使用 `--with-gui` 构建时获得 GUI。

  ![单一仓库与多子系统仓库的对比图](/img/posts/2020-06-monorepo-vs-monotree.png)

  这次拆分是一个实验，旨在确定使用不同的仓库来处理不同的子系统是否有助于对某一特定子系统感兴趣的人专注于项目的那一部分。例如，使用 GitHub 的 *Watch Repository* 功能的某人，将在关注 Bitcoin Core GUI 仓库时每天收到更少的 issue 和 PR 状态更新，从而更容易监控项目。相反，关注主项目的开发人员可能并不都对 GUI 感兴趣，因此他们将不再需要接收有关 GUI 的通知。在最好的情况下，希望这种改进的关注度可以加快开发速度，这可能会导致关于为其他子系统创建多子系统仓库的讨论。在最坏的情况下，人们担心拆分可能会减慢开发速度——但如果发生这种情况，实验可以轻松终止，开发可以恢复到使用单一仓库（*monorepo*）。


{% include references.md %}
{% include linkers/issues.md issues="19260,19133,18027,16377,1461,19071,19204,8709" %}
[lnd 0.10.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.10.2-beta.rc2
[ride the lightning]: https://github.com/Ride-The-Lightning/RTL
[pickhardt post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-June/002735.html
[bolt5 calc]: https://github.com/lightningnetwork/lightning-rfc/blob/master/05-onchain.md#penalty-transactions-weight-calculation
[news59 cl30]: /zh/newsletters/2019/08/14/#c-lightning-2858
[teinturier post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-June/002739.html
[teinturier gist]: https://gist.github.com/t-bast/22320336e0816ca5578fdca4ad824d12
[news95 ln attack]: /zh/newsletters/2020/04/29/#new-attack-against-ln-payment-atomicity
[pay-for-signature]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-July/002077.html
[zmn procedure]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-June/002744.html
[nick collision]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-June/017986.html
[news100 coinswap]: /zh/newsletters/2020/06/03/#design-for-a-coinswap-implementation
[address security]: /zh/bech32-sending-support/#地址安全性
[news74 psbtgui]: /zh/newsletters/2019/11/27/#bitcoin-core-16944
[news82 psbtgui]: /zh/newsletters/2020/01/29/#bitcoin-core-17492
[hwi gui]: https://github.com/bitcoin-core/HWI/pull/291
[bitcoin core gui repository]: https://github.com/bitcoin-core/gui
[bitcoin/bitcoin]: https://github.com/bitcoin/bitcoin
[news101 fee overpayment attack]: /zh/newsletters/2020/06/10/#fee-overpayment-attack-on-multi-input-segwit-transactions
[core version]: https://bitcoin.org/en/release/v0.19.0.1
[broken docs]: https://btcinformation.org/en/developer-examples#regtest-mode
[hwi]: https://github.com/bitcoin-core/HWI
