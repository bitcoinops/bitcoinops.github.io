---
title: 'Bitcoin Optech Newsletter #38'
permalink: /zh/newsletters/2019/03/19/
name: 2019-03-19-newsletter-zh
slug: 2019-03-19-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 更新了计划从 Bitcoin Core 中移除 BIP61 拒绝消息的进展，链接了关于 SIGHASH_NOINPUT_UNSAFE 的进一步讨论，分析了 Esplora 区块链浏览器中的一些新功能，提供了有关更新节点封禁列表的信息，并链接了最近 MIT Bitcoin Club Expo 会议的视频。此外，还提供了一个关于 bech32 发送支持的新每周专栏，以及受欢迎的比特币基础设施项目中的一些值得注意的变化列表。

{% include references.md %}

## 行动项

- **<!--help-test-bitcoin-core-0-18-0-rc2-->****帮助测试 Bitcoin Core 0.18.0 RC2：** 下一个 Bitcoin Core 主要版本的第二个候选版本 (RC) 已经[发布][0.18.0]。组织和有经验的用户计划在生产环境中运行新的 Bitcoin Core 版本，仍然需要进行测试。请使用[这个问题][Bitcoin Core #15555]反馈测试结果。

## 新闻

- **<!--bip61-reject-messages-->****BIP61 拒绝消息：** 正如[上周的 Newsletter][Newsletter #37]中所总结的那样，一些开发者抱怨在即将到来的 Bitcoin Core 0.18.0 版本中默认禁用了 [BIP61][] 拒绝消息，特别是因为这个通知在计划发布前不久才发布。Bitcoin Core 开发者[讨论][core dev irc]了这个问题，并决定在 0.18.0 版本中默认重新启用 BIP61，但在发布说明中将其描述为已弃用。他们计划在 0.19.0 版本（预计 2019 年 10 月左右）中默认禁用它，并可能在那时或稍后将其移除。

- **<!--mailing-list-move-->****邮件列表迁移：** 正如每个列表中宣布的那样，[bitcoin-dev][bdev mv] 和 [lightning-dev][ldev mv] 邮件列表将很快迁移到 [Groups.io][] 讨论托管服务。列表将在当前地址继续操作，直到迁移完成，届时订阅者应会收到通知。如果您不希望 Groups.io 了解您的订阅信息，您应该立即取消订阅这些列表。此时您无需创建 groups.io 账户。

- **<!--more-discussion-about-sighash-noinput-unsafe-->****关于 SIGHASH_NOINPUT_UNSAFE 的更多讨论：** Anthony Towns 开始了另一个[讨论][noinput thread]，讨论如何确保提议的 noinput sighash 模式在使用中不容易导致资金损失。Noinput 可以为 LN 启用一个适用于多参与者通道的替代链上执行层，最终允许在相同的区块空间内打开更多的通道。Towns 描述了一个合理的最坏情况，如果不能确保 noinput 的安全性，可能会影响其他有价值协议特性的采用。为避免这种情况，他提出了对早期输出标签想法的改进（见 [Newsletter #34][]），以及一个新替代方案，要求每个使用 noinput 签名的交易还必须包含一个不使用 noinput 签名的签名。这将防止第三方对 noinput 交易进行重放攻击，但这意味着不能使用 taproot 的最高效方式，从而导致使用 noinput 时交易大小适度增加。

- **<!--esplora-updated-->****Esplora 更新：** Nadav Ivgi [宣布][ivgi twitter]更新了这个开源区块链浏览器。（参见我们对其最初发布的 [Newsletter #25][] 报道。）未确认交易现在显示了在当前网络条件下确认所需的时间估算，或如果支付超过必要的费用则会有过度支付警告。也许更值得注意的是，已确认和未确认交易的详细视图提供了交易中使用或省略的功能和反功能的分析。例如：使用 segwit、地址重用、不一致的输出精度、匹配一个[不必要输入启发式][uih2]、不一致的输入/输出脚本类型，以及无找零交易。

  看到新变化后，Ryan Havar 在 [Reddit 上提出了担忧][havar reddit]，认为可能存在高比例的错误隐私警告，导致他在 Esplora 的 GitHub 上[提出了问题][havar github]。为解决这些担忧，Ivgi 开始了与几位 Bitcoin Core 开发者的[对话][esplora convo]。隐私倡导者可能希望查看这次对话，涵盖的主题包括：

  - Gregory Maxwell 和 Pieter Wuille 认为自 2009 年 Bitcoin 0.1 发布以来，Bitcoin Core 可能偶尔会匹配不必要输入启发式 2 (UIH2)，最近的发布中频率越来越高，使得这种启发式不再如假设的那样有用来区分商业服务和终端用户钱包。

  - Bitcoin Core 在过去两个版本中的硬币选择更新允许其频繁生成没有找零输出的交易。这些交易比有找零的交易更高效且更隐私，但 Esplora 当前将其显示为红色，认为这些交易泄露隐私，因为它们也匹配用户使用“最大发送”功能将所有比特币从一个钱包发送到另一个钱包或交易所的模式。

  - Maxwell 建议隐私分析的一个有用补充是识别用户控制的多个 UTXO 接收至同一地址但仅发送一部分 UTXO 的交易。这种行为使得可能将后来花费这些 UTXO 的交易与早期交易连接起来，破坏隐私。

  总的来说，看到开发者构建帮助人们识别其软件或行为缺陷的工具是件好事，但考虑用户如何与工具交互也很重要。正如 Wuille 在对话接近尾声时所说：“我非常高兴现在有一个可以用于调试的体面浏览器，但我担心让它听起来像是一个实际的生产工具。我知道人们会使用浏览器，一个提供良好信息的浏览器比一个混淆所有内容的浏览器好。但我们真的不应该鼓励使用[它]。如果这个隐私检测功能导致人们出于游戏化的感觉‘哦，让我们看看我的交易在这里表现如何？！’，这可能是一个净负面。[...]区块浏览器上最重要的提示是‘警告：在区块浏览器上查找自己的地址会将您的隐私泄露给网站运营者’。”

- **<!--spy-node-ban-list-updated-->****间谍节点封禁列表更新：** 一些 IP 地址正在执行各种攻击，可能旨在监控交易传播，以尝试确定哪个节点发起了哪些交易。为帮助节点操作员拒绝这些 IP 地址的连接，Gregory Maxwell 维护了一个可以导入 Bitcoin Core 和兼容节点的封禁列表。完全没有必要使用这个集中式列表——您的完全去中心化节点将尝试连接到足够多样的节点，以确保至少建立一个诚实的连接——但使用这个封禁列表可能会减少浪费在间谍节点和其他不良行为者上的流量。该列表有两种格式，一种用于命令行与 [bitcoin-cli][banlist cli] 一起使用，另一种可以粘贴到 [Bitcoin Core GUI][banlist gui] 的调试控制台。被列入黑名单的 IP 地址被封禁一年，Bitcoin Core 在重启之间会记住这些封禁，因此您只需导入一次该列表。注意：一些用户报告说封禁列表可能超过某些平台上 GUI 的最大缓冲区大小，需要分批大约 250 条目粘贴，以便加载整个列表。

- **<!--mit-bitcoin-club-2019-expo-videos-available-->****MIT Bitcoin Club 2019 Expo 视频可用：** 两周前博览会的一系列演讲已被分割成单独的[视频][mit vids]并上传到 YouTube。我们听说许多演讲都非常精彩，因此请考虑浏览播放列表，寻找您感兴趣的主题。

## Bech32 发送支持

*第 1 周，共 24 周*

{% include specials/bech32/zh/01-intro.md %}

## 值得注意的代码和文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和 [比特币改进提案 (BIPs)][bips repo] 中值得注意的变化。*

- [LND #2022][] 允许创建“挂起发票”。这些是标准的闪电网络发票，但在收到付款时会以不同的方式处理。接收方不会立即返回付款前映像以领取已支付的资金，而是会延迟直到支付时间锁允许的最大时间。这使得接收方可以在知道资金可用后接受或拒绝付款。例如，Alice 可以在她的网站上自动生成挂起发票，但等到客户实际支付后再搜索其库存以找到请求的商品。如果她无法交付，这将给她一个取消付款的机会。拉取请求的主要描述中提供了其他示例用例。

- [LND #2618][] 实现了大部分代码，支持初始版本的 watchtower 客户端，该客户端允许 LND 节点与私人 watchtower 配对并向其发送加密状态备份。watchtower 然后可以监控区块链是否有尝试的通道合约违规并提交违反补救（正义）交易，防止诚实方资金损失。请参见我们以前 Newsletter 中 notable code changes 部分的覆盖提交服务器端 watchtower 更改的提交：[#7][newsletter #7]、[#19][newsletter #19]、[#22][newsletter #22] 和 [#30][newsletter #30]。

- [C-Lightning #2342][] 添加了一个新的 `setchannelfee` RPC，允许用户单独设置每个通道的费率。

{% include linkers/issues.md issues="2022,2618,2342,15555" %}
[esplora convo]: http://www.erisian.com.au/bitcoin-core-dev/log-2019-03-08.html#l-53
[havar github]: https://github.com/Blockstream/esplora/issues/51
[mit vids]: https://www.youtube.com/user/MITBitcoinClub/videos
[0.18.0]: https://bitcoincore.org/bin/bitcoin-core-0.18.0/
[noinput thread]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-March/016766.html
[ivgi twitter]: https://twitter.com/shesek/status/1103320174936109057
[uih2]: https://gist.github.com/AdamISZ/4551b947789d3216bacfcb7af25e029e#gistcomment-2796539
[havar reddit]: https://old.reddit.com/r/Bitcoin/comments/ay1b0e/new_update_for_blockstreaminfo_is_out_fee_privacy/ehy77cn/
[banlist cli]: https://people.xiph.org/~greg/banlist.cli.txt
[banlist gui]: https://people.xiph.org/~greg/banlist.gui.txt
[core dev irc]: http://www.erisian.com.au/meetbot/bitcoin-core-dev/2019/bitcoin-core-dev.2019-03-14-19.00.log.html#l-53
[ldev mv]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-March/001915.html
[bdev mv]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-March/016785.html
[groups.io]: https://groups.io/
[newsletter #37]: /zh/newsletters/2019/03/12/#removal-of-bip61-p2p-reject-messages
[newsletter #34]: /zh/newsletters/2019/02/19/#discussion-about-tagging-outputs-to-enable-restricted-features-on-spending
[newsletter #25]: /zh/newsletters/2018/12/11/#modern-block-explorer-open-sourced
[newsletter #7]: /zh/newsletters/2018/08/07/#lnd-1543
[newsletter #19]: /zh/newsletters/2018/10/30/#lnd-1535-1512
[newsletter #22]: /zh/newsletters/2018/11/20/#lnd-2124
[newsletter #30]: /zh/newsletters/2019/01/22/#lnd-2448
