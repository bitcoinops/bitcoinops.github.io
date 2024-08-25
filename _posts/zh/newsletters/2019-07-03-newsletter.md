---
title: 'Bitcoin Optech Newsletter #53'
permalink: /zh/newsletters/2019/07/03/
name: 2019-07-03-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
slug: 2019-07-03-newsletter-zh
---
本周的 Newsletter 宣布了最新的 C-Lightning 版本发布，简要描述了几个与闪电网络（LN）相关的提案，并提供了我们常规的关于 Bech32 发送支持和比特币基础设施项目重要变更的部分。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

*本周无。*

## 仪表盘项

- **<!--mempool-variability-->****内存池波动性：** 在过去的一周中，由各种节点[跟踪][johoe stats]的内存池大小从接近 100,000 笔交易波动到不到 1,000 笔交易。由于大多数手续费估算算法会滞后于内存池状态的变化，内存池大小的高度波动可能会导致比平时更多的交易卡住或交易支付过高。高频支付者如交易所可能希望自行监控内存池状态（例如使用 Bitcoin Core 的 `getmempoolinfo` RPC）以根据当前的内存池条件调整他们的手续费率。

## 新闻

- **<!--lnd-0-7-0-beta-released-->****LND 0.7.0-beta 版本发布：** 这个[新主版本][lnd 0.7]是第一个包含[哨兵节点实现][watchtower docs]的版本，该功能允许第三方帮助保护离线用户的通道资金。该版本还包括错误修复、支付跟踪 API 的改进以及更快的初始同步。建议升级。

- **<!--c-lightning-0-7-1-released-->****C-Lightning 0.7.1 版本发布：** 这个[新版本][cl 0.7.1]包含了新的插件和 RPC 以及多个改进的通道 gossip 协议处理方式，从而减少了内存和带宽的使用。建议升级。

- **<!--stuckless-payments-->****无阻支付：** Hiroki Gondo [提议][stuckless]了一种通过两步协议在 LN 通道上进行支付的新方式。在第一阶段，资金通过锁定在收款人未知的预映像（preimage）的 HTLC 进行转移。当收款人确认资金可用时，付款人会释放收款人需要的预映像信息以领取资金。这种方法的优势在于，它允许付款人在最后一刻阻止支付成功，从而单方面取消卡住的支付，甚至可以尝试通过多个路径同时发送同一笔支付，以查看哪个路径最先成功（在取消较慢的支付之前）。这一提案需要对当前的 LN 协议进行重大修订，因此开发人员需要考虑将其作为未来的升级内容。

- **<!--standardized-atomic-data-delivery-following-ln-payments-->****LN 支付后标准化原子数据传输：** Nadav Kohen 在 Lightning-Dev 邮件列表中[发布][atomic data payments]了一份提案，旨在标准化通过 LN 支付后交付数据的方式，这种方式已经在 Alex Bosworth 的 [Y'alls][] 网站上使用。数据将由支付请求的预映像加密，这样在支付前可以将加密的数据交给买家。买家随后发送支付，商家通过释放预映像接受支付，然后买家使用预映像解密数据。该系统仍然需要买家信任商家，因为商家可能会交付加密的垃圾数据而不是实际的数据（即，这一提案不像[零知识条件支付][zkcp]那样无需信任），但提议的协议可以允许买家在支付仍在处理时开始下载数据。

- **<!--lightning-loop-supports-user-loop-ins-->****Lightning Loop 支持用户 loop-in 操作：** 正如 [Newsletter #39][] 中所描述，[Lightning Loop][] 使用*潜水交换*允许用户将 LN 支付通道中的比特币交换为普通链上交易中的比特币，称为 *loop out*。这无需打开或关闭任何通道。系统的[更新][loop-in]现在允许用户执行相反的操作：将普通链上 UTXO 中的比特币交换为其 LN 通道中的比特币，称为 *loop in*。除了需要其中一方支付交易费以防另一方退出交换外，loop in 和 loop out 都是无需信任的。有了新的 loop in 功能，LN 用户可以方便地为其耗尽的通道重新注资，而无需使用托管服务。Loop 软件与 LND 的最新版本兼容。

## Bech32 发送支持

*这是关于让您支付的对象享受所有 segwit 优势的[系列][bech32 series]的第 16 周，共 24 周。*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/zh/16-checklist.md %}

## 值得注意的代码和文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和 [Bitcoin Improvement Proposals (BIPs)][bips repo] 中的值得注意的变更。*

- [C-Lightning #2767][] 禁用了在 [Newsletter #51][] 的*代码变更*部分中描述的 `listtransactions` RPC。该 RPC 目前有多个问题尚待解决，因此在 0.7.1 版本中被禁用。开发人员计划在发布后不久重新启用该功能。

- [Eclair #962][] 添加了一个 `balances` 方法，用于打印每个通道的余额。

{% include linkers/issues.md issues="962,2767" %}
[bech32 series]: /zh/bech32-sending-support/
[lnd rc]: https://github.com/LightningNetwork/lnd/releases
[johoe stats]: https://jochen-hoenicke.de/queue/#0,24h
[stuckless]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-June/002029.html
[zkcp]: https://bitcoincore.org/en/2016/02/26/zero-knowledge-contingent-payments-announcement/
[lightning loop]: https://github.com/lightninglabs/loop
[loop-in]: https://blog.lightning.engineering/announcement/2019/06/25/loop-in.html
[atomic data payments]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-June/002035.html
[Y'alls]: https://www.yalls.org
[lnd 0.7]: https://github.com/lightningnetwork/lnd/releases/tag/v0.7.0-beta
[cl 0.7.1]: https://github.com/ElementsProject/lightning/releases/tag/v0.7.1
[watchtower docs]: https://github.com/lightningnetwork/lnd/blob/master/docs/watchtower.md
[newsletter #39]: /zh/newsletters/2019/03/26/#loop-announced
[newsletter #51]: /zh/newsletters/2019/06/19/#c-lightning-2696
