---
title: 'Bitcoin Optech Newsletter #103'
permalink: /zh/newsletters/2020/06/24/
name: 2020-06-24-newsletter-zh
slug: 2020-06-24-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了一种新披露的、针对 LN 用户的手续费勒索攻击，链接了关于 LN 原子性所受攻击的后续讨论，并提醒大家在多方协议中基于 RIPEMD160 的地址存在碰撞攻击风险。我们还照例收录了 Bitcoin Stack Exchange 的热门问答、本周发布的版本与候选版本列表，以及热门比特币基础设施项目的值得注意的变更。

## 行动项

*本周无。*

## 新闻

- **<!--ln-fee-ransom-attack-->****LN 手续费勒索攻击：** René Pickhardt 向 Lightning-Dev 邮件列表[公开披露][pickhardt post]了一个漏洞，而他大约一年前曾私下向各 LN 实现的维护者披露过该漏洞。在当前的 LN 协议中，每次更新通道状态时，发起开通通道的一方必须承诺支付单方面关闭交易的链上交易手续费。支付手续费的一方还可以选择所用的费率——但对手方的安全性也取决于该费率是否合适。这意味着如果对手方认为所选费率相对当前市场状况已经过低，他们随时可以关闭通道。为了避免这种不必要的关闭，[BOLT2][] 给出了一个例子：支付手续费的一方选择比最低合理估计高五倍的费率——高到足以让对手方满意，即使对手方用的是另一套费率估计算法。

  BOLT2 还允许通道同时路由最多 483 笔支付，每笔支付需要一个 43 vbyte 的 P2WSH 输出，共计约 20,000 vbyte 的数据需要相对快速地添加到链上——这意味着可能要支付高费率。如果这个费率比实际必要的高出五倍，在当前比特币价格下，交易手续费很容易就超过 100 美元。此外，如果承诺交易得到确认，这些 HTLC 还需要结算（同样要用对时间敏感、可能需要高费率的交易）。如果受害者正是将这些支付向外路由的一方，他们还得为追回每笔支付额外支付交易手续费，这可能让攻击对他们的成本变成两到三倍。

  手续费支付给矿工，因此执行这种攻击没有直接动机；但如果攻击者能迅速联系到受害者，就可能提出以链下方式结算 HTLC 来换取赎金，从而让攻击者获利。

  Pickhardt 在邮件结尾给出了几种解决该问题的思路，但他认为没有一个完全令人满意。最初在 Eclair 中实现、后来在 C-Lightning 中实现的缓解措施（参见 [Newsletter #59][news59 cl30]）是让 LN 节点限制待处理支付的数量，使交易保持较小、总手续费保持较低。另一项正在开发中的缓解措施是[锚定输出][topic anchor outputs]，它允许在关闭通道时再选择费率——从而无需为了防止通道被过早关闭而高估手续费。邮件中还提到其他几种思路，但 Pickhardt 希望读者认真思考这个问题，并提出其他可能的解决方案。

- **<!--continued-discussion-about-ln-atomicity-attack-->****关于 LN 原子性攻击的后续讨论：** Bastien Teinturier 在 Lightning-Dev 邮件列表上[发帖][teinturier post]，附了一份[详细文档][teinturier gist]的链接，其中介绍了 LN 承诺协议、它的弱点以及针对这些弱点提出的改进方案。这份文档写清了理解 [Newsletter #95][news95 ln attack] 所述 LN 原子性攻击以及几种拟议缓解措施所需的一切背景。文档行文清晰，把此前讨论中零散的几条线索串联了起来，促使人们重新评估若干早先提出的方案，包括对“替代锚点提案”有效性的担忧，以及一项[建议流程][zmn procedure]：用 [pay-for-signature][] 无脚本脚本（scriptless script），无需信任地向第三方支付完成适配器签名所需的最终签名。

- **<!--reminder-about-collision-attack-risks-on-two-party-ecdsa-->****关于两方 ECDSA 碰撞攻击风险的提醒：** 密码学家 Jonas Nick 回复了 Bitcoin-Dev 邮件列表中关于某个 CoinSwap 实现提案的[讨论帖][news100 coinswap]，提醒开发者：使用 160 位 RIPEMD160 哈希的 P2PKH、P2WPKH 和 P2SH 地址容易受到碰撞攻击，当多方用朴素协议协作创建地址时，这类攻击会把安全性降至 80 位（参见我们对传统 P2SH 地址中这一弱点的[描述][address security]）。虽然过去这只对使用 P2SH 多重签名的用户构成隐患，但 CoinSwap 这类场景同样适用——那里提议两个用户可以共享一个 P2PKH 或 P2WPKH 地址。这个问题可以避免，但要求两方 ECDSA 协议在设计上额外加入一道承诺流程；Nick 指出，有些两方 ECDSA 协议及其实现已经这样做了。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们有点空闲时帮助好奇或困惑用户的地方。在本月栏目中，我们精选自上次更新以来得票最高的一些问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--why-was-the-current-formula-that-calculates-target-from-nbits-chosen-->**[为什么选择了当前从 'nBits' 计算 'target' 的公式？]({{bse}}96298) Ravi Patel 询问为什么没有选择一个更简单的公式来从 'nBits' 计算难度目标。Andrew Chow 深入讲解了这个公式的若干细节、它的历史，甚至引用了 Bitcoin 0.1.5 版本中的示例代码。

- **<!--does-bitcoin-really-need-timestamps-->**[比特币真的需要时间戳吗？]({{bse}}96185) Pieter Wuille 解释了如果不参考区块链之外的时钟时间来限制区块速率，运行全节点可能会更昂贵，同时还难以保持低孤块率并防止勾结攻击。

- **<!--in-a-fee-overpayment-attack-why-can-t-compromised-software-provide-fake-previous-transactions-corresponding-to-fake-inputs-->**[在手续费超额支付攻击中，为什么被攻破的软件不能提供与假输入对应的假之前交易？]({{bse}}96309) 关于针对含多个输入的 segwit 交易的[手续费超额支付攻击][news101 fee overpayment attack]，justinmoon 询问：该攻击的补救措施要求为各输入提供前序交易的副本，那为什么恶意软件不能用伪造的前序交易来绕过它？由于提供的任何前序交易，其哈希都必须与所花费输入所引用的前序交易哈希一致，因此这种攻击并不可行。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [LND 0.10.2-beta.rc2][lnd 0.10.2-beta] 这个 LND 维护版本的候选版本现已可供测试。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络 BOLT 规范][bolts repo]中的值得注意的变更。*

- [Bitcoin Core #19260][] 在本地节点不接受布隆过滤器时（通过 [BIP111][] `NODE_BLOOM` 服务标志对外声明），断开那些发送 [BIP37][] `filterclear` 消息的对等节点。此前曾[提议][Bitcoin Core #8709]，处于初始区块链下载（IBD）阶段的节点可以注册为非中继对等节点，以免在下载大量区块期间接收近期交易。等同步完成后，它们可以发送 `filterclear` 消息，切换到接收中继交易。不过最近又[提议][Bitcoin Core #19204]改用 [BIP133][] `feefilter` 消息来实现这一点。这样，非布隆节点就完全不需要支持 `filterclear` 消息，因此本 PR 移除了该功能。

- [Bitcoin Core #19133][] 添加了一个 bitcoin-cli `-generate` 参数（注意前面的连字符），用来替代已从 Bitcoin Core [0.19.0.1 版本][core version] 中移除的 `generate` RPC。新实现避免了钱包与其他组件之间不必要的依赖。为这个旧 RPC 提供客户端别名便于手动测试，也让更新[失效的文档][broken docs] 变得更容易。

- [Bitcoin Core #18027][] 为 GUI 的 *文件* 菜单添加了两个处理部分签名比特币交易（[PSBT][topic psbt]）的选项：*从文件加载 PSBT* 和 *从剪贴板加载 PSBT*。点击其中一个选项并加载 PSBT 后，会弹出一个对话框，让你在钱包持有相应密钥时签名一个未完成的 PSBT、广播一个已完成的 PSBT，或复制、保存该 PSBT 以便用 [HWI][] 等其他工具处理。结合近期其他与 PSBT 相关的 GUI 变更（参见 Newsletter [#74][news74 psbtgui] 和 [#82][news82 psbtgui]）以及 [HWI 自带的 GUI][hwi gui]，这是首次可以完全不使用任何 RPC，就在 Bitcoin Core 中跑通基于 PSBT 的流程。

  ![Bitcoin Core GUI 中 PSBT 对话框的截图](/img/posts/2020-06-psbt-dialog.png)

- [Bitcoin Core #16377][] 更新了 `walletcreatefundedpsbt` 和 `fundrawtransaction` 两个 RPC。这些 RPC 通常让钱包自动选择在未签名交易中花费哪些 UTXO，但也允许用户指定自己希望在交易中花费的一个或多个 UTXO。以前，如果用户选定的 UTXO 不足以支付交易的全部输出，钱包会自动再选一些 UTXO 来花费。但如果用户是手动挑 UTXO，可能有某种理由不愿多花其他 UTXO，因此现在只要用户手动指定了 UTXO，这些 RPC 默认就会失败。可以用这两个 RPC 新增的 `add_inputs` 参数覆盖这一默认行为。

- [Eclair #1461][] 新增了几个 API 端点，把请求转发给 Bitcoin Core RPC，用来中继该程序的钱包余额及其他信息。目标是让 Eclair 更容易与 [Ride The Lightning][] 节点管理仪表盘集成。

- [Bitcoin Core #19071][] 新增了文档，说明开发者如何为新的实验性 [Bitcoin Core GUI 仓库][Bitcoin Core GUI
  repository] 做贡献。与 GUI 相关的拉取请求应提交到这个新仓库，而该仓库会通过 Linux 内核项目所用的 *monotree* 开发模型，与[主仓库][bitcoin/bitcoin] 双向同步。这次拆分没有用户直接可见的变化——用户仍会从 Bitcoin Core 官方打包版本中获得 GUI，或在主仓库源码中用 `--with-gui` 构建时获得 GUI。

  ![monorepo 与 monotree 对比示意图](/img/posts/2020-06-monorepo-vs-monotree.png)

  这次拆分是一项实验，旨在弄清：为不同子系统使用不同仓库，是否有助于关注某个子系统的人专注于项目中对应的那部分。例如，使用 GitHub 的 *Watch Repository* 功能的人，关注 Bitcoin Core GUI 仓库时每天收到的 issue 和 PR 状态更新会比关注主仓库少，因而更容易监控项目。反过来，关注主项目的开发者未必都对 GUI 感兴趣，他们也不必再收到相关通知。最好的情况下，希望这种更集中的关注能加快开发，进而引发为其他子系统创建 monotree 仓库的讨论。最坏的情况下，有人担心拆分可能拖慢开发——但若果真如此，这项实验可以随时终止，开发也能回到使用单一仓库（*monorepo*）的方式。

{% include references.md %}
{% include linkers/issues.md issues="19260,19133,18027,16377,1461,19071,19204,8709" %}
[lnd 0.10.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.10.2-beta.rc2
[ride the lightning]: https://github.com/Ride-The-Lightning/RTL
[pickhardt post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-June/002735.html
[bolt5 calc]: https://github.com/lightningnetwork/lightning-rfc/blob/master/05-onchain.md#penalty-transactions-weight-calculation
[news59 cl30]: /zh/newsletters/2019/08/14/#c-lightning-2858
[teinturier post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-June/002739.html
[teinturier gist]: https://gist.github.com/t-bast/22320336e0816ca5578fdca4ad824d12
[news95 ln attack]: /zh/newsletters/2020/04/29/#new-attack-against-ln-payment-atomicity
[pay-for-signature]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-July/002077.html
[zmn procedure]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-June/002744.html
[nick collision]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-June/017986.html
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
