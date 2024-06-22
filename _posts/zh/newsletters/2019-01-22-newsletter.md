---
title: 'Bitcoin Optech Newsletter #30'
permalink: /zh/newsletters/2019/01/22/
name: 2019-01-22-newsletter-zh
slug: 2019-01-22-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了一个提议的 LN 特性，以允许进行自发支付，并提供了我们迄今为止最长的值得注意的流行 Bitcoin 基础设施项目代码更改列表。

## 新闻

- **<!--pr-opened-for-spontaneous-ln-payments-->****为自发 LN 支付打开的 PR：**LN 协议开发者 Olaoluwa Osuntokun 打开了一个[拉取请求][spontaneous payments]，允许一个 LN 节点在未先收到发票的情况下向另一个节点发送支付。这利用了 LN 类似 Tor 的洋葱路由，允许付款人选择一个预影像，将其加密以便只有接收者的节点可以解密，然后像正常情况一样使用预影像的哈希在 LN 上路由支付。当支付到达接收者时，他们解密预影像并将其披露给路由节点以索取支付。

  自发支付在用户只想进行临时支付跟踪的情况下很有帮助，例如你从一个交易所发起 10 mBTC 的提现，要么在几分钟内你的余额中显示 10 mBTC，要么联系支持。或者你只需发布你的节点信息，用户可以在不需要先获取发票的情况下向你发送捐赠。对于特定支付的跟踪，用户仍应继续生成可以与特定订单或其他预期支付唯一关联的发票。

  截至本文撰写时，Osuntokun 的 LND 拉取请求仍标记为进行中，因此我们还不知道该功能何时会普遍提供给 LND 用户，或者其他 LN 实现是否也会以兼容的方式提供相同功能。

## Optech 建议

如果你更喜欢听音频而不是阅读每周的 Optech Newsletter，World Crypto Network 的 Max Hillebrand 已经录制了迄今为止所有 Newsletter 的录音，总共提供了超过 6 小时的 Bitcoin 技术新闻。可以在 [YouTube][wcn optech playlist] 上获得音频和视频，也可以通过 [iTunes][wcn itunes] 和 [acast][wcn acast] 仅获得音频。Optech 感谢 Max 自愿进行录音并且表现得很好。我们鼓励所有更愿意以视频或音频形式接收 Newsletter 的人关注 Max 以获取未来的录音。

## 值得注意的代码更改

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo] 和 [libsecp256k1][libsecp256k1 repo] 中值得注意的代码更改。*

- [Bitcoin Core #14941][] 使 `unloadwallet` RPC 变为同步。它现在不会返回，直到指定的钱包完成卸载。

- [Bitcoin Core #14982][] 添加了一个新的 `getrpcinfo` RPC，提供有关 RPC 接口的信息。目前它返回一个 `active_commands` 数组，列出所有尚未返回的 RPC。

- [LND #2448][] 添加了一个独立的监视塔，允许其“与客户端协商会话，接受活动会话的状态更新，监视链中的匹配已知违约提示的违规行为，[并且]代表塔客户端发布重建的正义交易”。这是初始监视塔实现的最后一个部分之一，可以帮助保护离线的 LN 节点免于资金被盗——这是使 LN 成熟到足以供普遍使用的重要功能之一。

- [LND #2439][] 添加了监视塔的默认策略，例如允许塔在单个会话中处理最多 1,024 个来自客户端的更新，允许监视塔在保护通道时获得通道容量的 1% 的奖励，以及设置正义交易（违约补救交易）的默认链上费率。

- [LND #2198][] 为 `sendcoins` RPC 提供了一个新的 `sweepall` 参数，该参数将钱包中的所有比特币发送到指定地址，而用户无需手动指定金额。

- [C-Lightning #2232][] 扩展了 `listpeers` 命令，新增了 `funding_allocation_msat` 字段，返回每个节点最初放入通道的金额。

- [C-Lightning #2234][] 扩展了 `listchannels` RPC，使其接受一个用于按节点 ID 过滤的 `source` 参数。同一个拉取请求还使 `invoice` RPC 在你没有公共通道时，包括私有通道的路由提示，除非你也将新的 `exposeprivatechannels` 参数设置为 false。路由提示建议了部分路由路径给付款人，以便他们可以通过先前不知道的节点发送支付。

- [C-Lightning #2249][] 再次在 C-Lightning 上启用插件，但文档中添加了一条注释，指示 API 仍然“处于积极开发中”。

- [C-Lightning #2215][] 添加了一个 libplugin 库，为插件提供了一个 C 语言 API。

- [C-Lightning #2237][] 使插件能够为某些事件注册钩子，这些事件可以更改主进程处理这些事件的方式。代码中给出的一个例子是一个插件，在完成关于支付的重要信息的备份之前，防止 LN 节点承诺支付。

- [Eclair #762][] 添加了有限探测。LN 中的探测是向一个节点发送无效支付并等待其返回错误。如果节点不返回错误，这可能意味着它或某个沿支付路径的其他节点处于离线状态，无法处理支付。由于探测是一个无法兑现的无效支付，发送节点可以立即将其视为超时支付，无风险损失。此次 Eclair 更新仅允许探测节点的直接对等方——Eclair 已打开通道的节点。

{% include references.md %}
{% include linkers/issues.md issues="14941,14982,2448,2439,2198,2232,2234,2249,2215,2237,762" %}
[spontaneous payments]: https://github.com/lightningnetwork/lnd/pull/2455
[wcn optech playlist]: https://www.youtube.com/playlist?list=PLPj3KCksGbSY9pV6EI5zkHcut5UTCs1cp
[wcn itunes]: https://itunes.apple.com/us/podcast/the-world-crypto-network-podcast/id825708806
[wcn acast]: https://play.acast.com/s/world-crypto-network