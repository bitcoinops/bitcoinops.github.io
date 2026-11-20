---
title: 'Bitcoin Optech Newsletter #53'
permalink: /zh/newsletters/2019/07/03/
name: 2019-07-03-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
slug: 2019-07-03-newsletter-zh
---
本周的 Newsletter 宣布 C-Lightning 发布新版本，简要介绍几个与 LN 相关的提案，并照例奉上 bech32 发送支持与热门比特币基础设施项目值得注意的变更两个常规章节。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

*本周无。*

## 仪表盘项

- **<!--mempool-variability-->****内存池波动性：** 在过去的一周中，由各种节点[跟踪][johoe stats]的内存池大小从接近 100,000 笔交易波动到不到 1,000 笔交易。由于大多数手续费估算算法都滞后于内存池状态的变化，内存池大小的剧烈波动可能让卡住的交易或手续费付多了的交易比平时更多。交易所这类高频付款方不妨自行监控内存池状态（例如调用 Bitcoin Core 的 `getmempoolinfo` RPC），以便按当下的内存池状况调整费率。

## 新闻

- **<!--lnd-0-7-0-beta-released-->****LND 0.7.0-beta 版本发布：** 这个[新主版本][lnd 0.7]是第一个包含[瞭望塔实现][watchtower docs]的版本，该功能允许第三方帮助保护离线用户的通道资金。该版本还包括错误修复、支付跟踪 API 的改进以及更快的初始同步。建议升级。

- **<!--c-lightning-0-7-1-released-->****C-Lightning 0.7.1 版本发布：** 这个[新版本][cl 0.7.1]包含新插件与 RPC，并对通道 gossip 协议的处理做了大量改进，从而降低内存与带宽占用。建议升级。

- **<!--stuckless-payments-->****不会卡住的支付：** Hiroki Gondo [提议][stuckless]了另一种跨 LN 通道路由支付的方式，用两步协议来释放付款。第一阶段，资金通过 HTLC 转移，而这些 HTLC 锁定在一个收款人尚不知道的原像（preimage）上。等收款人确认资金已可动用，付款人才放出收款人领钱所需的原像信息。这种方法的优势在于，它允许付款人在最后一刻阻止支付成功，从而可以单方面取消卡住的支付，甚至可以同时通过多条路由发送同一笔支付，看哪条最先成功（然后取消较慢的那些）。这一提案需要对当前的 LN 协议进行重大修订，因此开发人员需要考虑将其作为未来的升级内容。

- **<!--standardized-atomic-data-delivery-following-ln-payments-->****LN 支付后标准化原子数据传输：** Nadav Kohen 在 Lightning-Dev 邮件列表中[发布][atomic data payments]了一份提案，为“通过 LN 付费后交付数据”提供一种标准化方式，这种办法已经在 Alex Bosworth 的 [Y'alls][] 网站上使用。数据将由支付请求的原像加密，这样在支付前可以将加密的数据交给买家。买家随后发送支付，商家通过释放原像接受支付，然后买家使用原像解密数据。该系统仍然需要买家信任商家，因为商家可能会交付加密的垃圾数据而不是实际的数据（即，这一提案不像[零知识条件支付][zkcp]那样无需信任），但提议的协议可以允许买家在支付仍在处理时开始下载数据。

- **<!--lightning-loop-supports-user-loop-ins-->****Lightning Loop 支持用户 loop-in 操作：** 正如 [Newsletter #39][] 中所描述，[Lightning Loop][] 使用*潜艇交换（submarine swap）*，让用户能把 LN 支付通道里的比特币换成普通链上交易中的比特币，称为 *loop out*。这无需打开或关闭任何通道。系统的[更新][loop-in]现在允许用户执行相反的操作：将普通链上 UTXO 中的比特币交换为其 LN 通道中的比特币，称为 *loop in*。除了一方退出交换时另一方得付手续费之外，loop in 和 loop out 都是无需信任的。有了新的 loop in 功能，LN 用户不用依赖托管服务，就能方便地给已经耗尽的通道补充资金。Loop 软件兼容近期版本的 LND。

## Bech32 发送支持

*这是 [bech32 系列][bech32 series] 24 周中的第 16 周，该系列讲的是如何让你付款的对象享受到 segwit 的全部好处。*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/zh/16-checklist.md %}

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和[比特币改进提案（BIPs）][bips repo]中的值得注意的变更。*

- [C-Lightning #2767][] 禁用了在 [Newsletter #51][] 的*代码变更*部分中描述的 `listtransactions` RPC。该 RPC 目前有多个问题尚待解决，因此在 0.7.1 版本中被禁用。开发人员计划在发布后不久重新启用该功能。

- [Eclair #962][] 添加了一个 `balances` 方法，用于打印每个通道的余额。

{% include linkers/issues.md issues="962,2767" %}
[bech32 series]: /zh/bech32-sending-support/
[lnd rc]: https://github.com/LightningNetwork/lnd/releases
[johoe stats]: https://jochen-hoenicke.de/queue/#0,24h
[stuckless]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-June/002029.html
[zkcp]: https://bitcoincore.org/en/2016/02/26/zero-knowledge-contingent-payments-announcement/
[lightning loop]: https://github.com/lightninglabs/loop
[loop-in]: https://blog.lightning.engineering/announcement/2019/06/25/loop-in.html
[atomic data payments]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-June/002035.html
[Y'alls]: https://www.yalls.org
[lnd 0.7]: https://github.com/lightningnetwork/lnd/releases/tag/v0.7.0-beta
[cl 0.7.1]: https://github.com/ElementsProject/lightning/releases/tag/v0.7.1
[watchtower docs]: https://github.com/lightningnetwork/lnd/blob/master/docs/watchtower.md
[newsletter #39]: /zh/newsletters/2019/03/26/#loop-announced
[newsletter #51]: /zh/newsletters/2019/06/19/#c-lightning-2696
