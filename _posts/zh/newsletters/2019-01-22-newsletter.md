---
title: 'Bitcoin Optech Newsletter #30'
permalink: /zh/newsletters/2019/01/22/
name: 2019-01-22-newsletter-zh
slug: 2019-01-22-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 介绍一项提议中的 LN 特性，它允许发起自发支付；同时给出我们迄今最长的一份清单，收录热门 Bitcoin 基础设施项目中值得注意的代码变更。

## 新闻

- **<!--pr-opened-for-spontaneous-ln-payments-->****自发 LN 支付的 PR 已提交：** LN 协议开发者 Olaoluwa Osuntokun 提交了一个[拉取请求][spontaneous payments]，允许 LN 节点在未先收到发票的情况下向另一个节点付款。这利用了 LN 类似 Tor 的洋葱路由：付款人先选定一个原像，将其加密到只有接收方节点才能解密，再像平常一样用该原像的哈希在 LN 上路由这笔支付。支付到达接收方后，接收方解密原像，并将其披露给路由节点，以领取这笔支付。

  当用户只是想做临时性的支付跟踪时，自发支付很有用。例如，你从交易所发起 10 mBTC 的提现，要么几分钟内余额里就出现这 10 mBTC，要么就得去联系客服。又或者，你只需公布自己的节点信息，用户无需先取得发票就能给你捐款。若要跟踪特定支付，用户仍应继续生成发票，并把发票与特定订单或其他预期付款唯一关联起来。

  截至本文撰写时，Osuntokun 的 LND 拉取请求仍标记为进行中。因此我们还不知道该功能何时会向 LND 用户普遍提供，也不知道其他 LN 实现是否也会以兼容的方式提供同一功能。

## Optech 建议

如果你更喜欢听音频而不是阅读每周的 Optech Newsletter，World Crypto Network 的 Max Hillebrand 已录制了迄今为止每一期的朗读版，合计提供超过 6 小时的 Bitcoin 技术新闻。音频和视频可在 [YouTube][wcn optech playlist] 上获取，纯音频还可通过 [iTunes][wcn itunes] 和 [acast][wcn acast] 以播客形式收听。Optech 感谢 Max 自愿承担朗读工作，并且录得如此出色。我们鼓励所有更愿意以视频或音频形式接收 Newsletter 的读者关注 Max，以收听今后的朗读。

## 值得注意的代码变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo] 和 [libsecp256k1][libsecp256k1 repo] 中值得注意的代码变更。*

- [Bitcoin Core #14941][] 使 `unloadwallet` RPC 变为同步。现在，在指定钱包完成卸载之前，该调用不会返回。

- [Bitcoin Core #14982][] 添加了一个新的 `getrpcinfo` RPC，提供有关 RPC 接口的信息。目前它返回一个 `active_commands` 数组，列出所有尚未返回的 RPC。

- [LND #2448][] 添加了一个独立的瞭望塔（watchtower），使其能够“与客户端协商会话，接受活动会话的状态更新，监视链上是否有与已知违约线索相符的违约行为，[并且]代表瞭望塔的客户端广播重建的正义交易”。这是初始瞭望塔实现的最后几个部分之一，可帮助保护离线 LN 节点的资金不被盗走——这是让 LN 足够成熟、可以普遍使用的重要功能之一。

- [LND #2439][] 添加了瞭望塔的默认策略，例如允许瞭望塔在单个会话中处理最多 1,024 条来自客户端的更新；如果瞭望塔最终守护了该通道，可获得通道容量 1% 的奖励；此外还设置正义交易（违约补救交易）的默认链上费率。

- [LND #2198][] 为 `sendcoins` RPC 新增了一个 `sweepall` 参数，该参数会把钱包中的所有比特币都发送到指定地址，用户无需手动指定金额。

- [C-Lightning #2232][] 扩展了 `listpeers` 命令，新增 `funding_allocation_msat` 字段，返回每个对等方最初放入通道的金额。

- [C-Lightning #2234][] 扩展了 `listchannels` RPC，使其接受一个按节点 ID 过滤的 `source` 参数。同一个拉取请求还让 `invoice` RPC 在你没有公共通道时包含私有通道的路由提示，除非你把新增的 `exposeprivatechannels` 参数也设为 false。路由提示会向付款人建议路由路径的一部分，以便他们能通过此前并不知道的节点发送支付。

- [C-Lightning #2249][] 再次在 C-Lightning 上默认启用插件，但在其文档中添加了一条说明，指出该 API 仍“处于积极开发中”。

- [C-Lightning #2215][] 添加了一个 libplugin 库，为插件提供 C 语言 API。

- [C-Lightning #2237][] 让插件能够为特定事件注册钩子，从而改变主进程处理这些事件的方式。代码中给出的例子是：某个插件会在完成某笔支付重要信息的备份之前，阻止 LN 节点提交该笔支付。

- [Eclair #762][] 添加了有限度的探测。LN 中的探测是指向某个节点发送一笔无效支付，并等待它返回错误。如果该节点不返回错误，很可能意味着它自身或支付路径上的某个其他节点处于离线状态，无法处理支付。由于探测本身是一笔永远无法兑现的无效支付，发送节点可以立即把它当作超时支付处理，且没有损失风险。此次 Eclair 的更新只允许探测某节点的直接对等方，即与 Eclair 有已打开通道的节点。

{% include references.md %}
{% include linkers/issues.md issues="14941,14982,2448,2439,2198,2232,2234,2249,2215,2237,762" %}
[spontaneous payments]: https://github.com/lightningnetwork/lnd/pull/2455
[wcn optech playlist]: https://www.youtube.com/playlist?list=PLPj3KCksGbSY9pV6EI5zkHcut5UTCs1cp
[wcn itunes]: https://itunes.apple.com/us/podcast/the-world-crypto-network-podcast/id825708806
[wcn acast]: https://play.acast.com/s/world-crypto-network