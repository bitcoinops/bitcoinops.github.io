---
title: 'Bitcoin Optech Newsletter #38'
permalink: /zh/newsletters/2019/03/19/
name: 2019-03-19-newsletter-zh
slug: 2019-03-19-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 介绍了从 Bitcoin Core 中移除 BIP61 拒绝消息这一计划的最新进展，链接了关于 SIGHASH_NOINPUT_UNSAFE 的进一步讨论，分析了 Esplora 区块链浏览器中的一些新功能，提供了更新后的节点封禁列表的相关信息，并链接了最近 MIT Bitcoin Club Expo 上演讲的视频。此外，本刊还新增了一个每周专栏，介绍 bech32 发送支持的采用情况，并一如既往地列出了热门比特币基础设施项目中值得注意的变更。

{% include references.md %}

## 行动项

- **<!--help-test-bitcoin-core-0-18-0-rc2-->****帮助测试 Bitcoin Core 0.18.0 RC2：** 下一个 Bitcoin Core 主要版本的第二个候选版本（RC）已经[发布][0.18.0]。计划在生产环境中运行新版 Bitcoin Core 的组织和有经验的用户仍需参与测试。请通过[这个问题][Bitcoin Core #15555]报告反馈。

## 新闻

- **<!--bip61-reject-messages-->****BIP61 拒绝消息：** 正如[上周的 Newsletter][Newsletter #37]中所总结的那样，一些开发者抱怨即将发布的 Bitcoin Core 0.18.0 默认禁用了 [BIP61][] 拒绝消息，尤其是相关通知直到计划发布前不久才发出。Bitcoin Core 开发者[讨论][core dev irc]了这个问题，并决定在 0.18.0 版本中默认重新启用 BIP61，但在发布说明中将其描述为已弃用。他们计划在 0.19.0 版本（预计 2019 年 10 月左右）中默认禁用它，并可能在那时或稍后将其移除。

- **<!--mailing-list-move-->****邮件列表迁移：** 正如各个列表上宣布的那样，[bitcoin-dev][bdev mv] 和 [lightning-dev][ldev mv] 邮件列表将在不久的将来迁移到 [Groups.io][] 讨论托管服务。在迁移完成之前，这两个列表仍可在现有地址正常使用；迁移完成后，订阅者应会收到通知。如果你不希望 Groups.io 获知你的订阅信息，应立即退订这两个列表。此时你无需创建 groups.io 账户。

- **<!--more-discussion-about-sighash-noinput-unsafe-->****关于 SIGHASH_NOINPUT_UNSAFE 的更多讨论：** Anthony Towns 发起了另一个[讨论帖][noinput thread]，讨论如何确保提议的 noinput sighash 模式难以被误用，以免造成资金损失。Noinput 可以为 LN 提供一种替代的链上执行层，更适合多方参与的通道，最终让相同的区块空间能打开更多通道。Towns 描述了一个相当可信的最坏情况：如果不能确保 noinput 的安全性，其他有价值的协议特性也可能难以被采用。为避免这种情况，他提出了对早前输出标签想法的改进（见 [Newsletter #34][]），以及一个新方案——要求每笔带有使用 noinput 的签名的交易，还必须包含一个不使用 noinput 的签名。这将防止第三方利用 noinput 交易执行重放攻击，但也意味着无法采用 taproot 最高效的用法，因此使用 noinput 时交易体积会适度增大。

- **<!--esplora-updated-->****Esplora 更新：** Nadav Ivgi [宣布][ivgi twitter]更新了这个开源区块链浏览器。（参见我们对其最初发布的[报道][Newsletter #25]。）未确认交易现在会显示在当前网络条件下预计需要多久才能确认；如果交易支付的手续费超过了快速确认所需的数额，则给出超额支付警告。也许更值得注意的是，已确认和未确认交易的详情页都会分析该交易使用或省略了哪些特性与反特性。例如：是否使用 segwit、地址重用、输出精度不一致、匹配[不必要输入启发式][uih2]、输入/输出脚本类型不一致，以及无找零交易。

  看到这些新变化后，Ryan Havar [在 Reddit 上提出担忧][havar reddit]，认为隐私警告可能存在很高的误报率，随后在 Esplora 的 GitHub 上就这一问题[开了一个 issue][havar github]。为回应这些担忧，Ivgi 与几位 Bitcoin Core 开发者发起了[对话][esplora convo]。关注隐私的人值得一读，其中涉及的话题包括：

  - Gregory Maxwell 和 Pieter Wuille 认为，自 2009 年 Bitcoin 0.1 发布以来，Bitcoin Core 就一直偶尔会匹配不必要输入启发式 2（UIH2），而且在较新的版本中频率还在上升，这使得该启发式在区分商业服务与终端用户钱包时，不如当初设想的那么有用。

  - Bitcoin Core 在过去两个版本中对选币（coin selection）的更新，使其能频繁生成没有找零输出的交易。这类交易比带找零的交易更高效，也更有利于隐私，但 Esplora 目前把它们标为红色、显示成泄露隐私的交易，因为它们同时也符合用户使用“最大发送”功能、把全部比特币从一个钱包转到另一个钱包或交易所的模式。

  - Maxwell 建议，隐私分析可以增加一项有用的功能：识别出用户在同一地址收到多个 UTXO、却只在一笔交易中花掉其中一部分的情况。这样一来，后来花费这些 UTXO 的交易就能与更早的那笔交易关联起来，从而破坏隐私。

  总的来说，看到开发者构建工具来帮助人们发现自家软件或自身行为中的缺陷，是件好事；但用户会怎样使用这个工具，同样值得考虑。正如 Wuille 在对话接近尾声时所说：“我很高兴现在有一个像样的区块浏览器，可以在外面调试东西，但我担心人们会把它当成真正的生产工具。我知道人们会用区块浏览器，一个能提供准确信息的区块浏览器总比一个把一切都搞混的强。但我们真的不该鼓励使用[它]。如果这个隐私检测功能让人出于类似游戏化的感觉——‘哦，看看我这笔交易表现如何？！’——去查遍自己所有的交易，那大概弊大于利。……区块浏览器最该放的一句话是：‘警告：在区块浏览器上查询你自己的地址，会把你的隐私泄露给网站运营者’。”

- **<!--spy-node-ban-list-updated-->****间谍节点封禁列表更新：** 一些 IP 地址正在发起各种攻击，目的很可能是在监控交易传播，从而试图判断哪些节点发出了哪些交易。为帮助节点运营者拒绝来自这些 IP 地址的连接，Gregory Maxwell 维护了一份封禁列表，可以导入 Bitcoin Core 及兼容节点。完全没必要使用这份中心化列表——你的完全去中心化节点会尝试连接足够多样的对等节点，理应至少建立一条诚实的连接——但使用这份封禁列表可以减少你把流量浪费在间谍节点和其他不良行为者上。该列表有两种格式：一种供命令行配合 [bitcoin-cli][banlist cli] 使用，另一种可以直接粘贴到 [Bitcoin Core GUI][banlist gui] 的调试控制台。黑名单中的 IP 地址会被封禁一年，且 Bitcoin Core 在重启后仍会记住这些封禁，因此你只需导入一次。注意：有用户报告，在某些平台上封禁列表可能超出 GUI 的最大缓冲区大小，需要每次约 250 条分批粘贴，才能加载完整列表。

- **<!--mit-bitcoin-club-2019-expo-videos-available-->****MIT Bitcoin Club 2019 Expo 视频已发布：** 两周前博览会上的一系列演讲已被拆分单条[视频][mit vids]上传到 YouTube。我们听说许多演讲都非常精彩，不妨浏览播放列表，找找你感兴趣的话题。

## Bech32 发送支持

*第 1 周，共 24 周*

{% include specials/bech32/zh/01-intro.md %}

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和[比特币改进提案（BIPs）][bips repo] 中值得注意的变更。*

- [LND #2022][] 允许创建“挂起发票（hold invoice）”。这是标准的闪电网络发票，但在收到付款时处理方式不同。接收方不会立即返回付款原像来领取已支付的资金，而是会一直延迟到支付时间锁允许的最大时限。这样接收方就能在确认资金可用之后再决定接受还是拒绝付款。例如，Alice 可以在网站上自动生成挂起发票，但等到客户真的付款后才去库存中查找所需商品。如果她无法发货，就有机会取消这笔付款。该 PR 的主要描述中还给出了其他用例。

- [LND #2618][] 实现了初始版本瞭望塔（watchtower）客户端所需的大部分代码，该客户端允许 LND 节点与私有瞭望塔配对，并向其发送加密的状态备份。随后瞭望塔可以监控区块链上是否有人试图违反通道合约，并提交违约补救（正义）交易，防止诚实一方损失资金。关于实现服务端瞭望塔改动的提交，参见我们此前各期 Newsletter 的“值得注意的代码变更”栏目：[#7][newsletter #7]、[#19][newsletter #19]、[#22][newsletter #22] 和 [#30][newsletter #30]。

- [C-Lightning #2342][] 添加了一个新的 `setchannelfee` RPC，允许用户单独设置每个通道的费率。

{% include linkers/issues.md issues="2022,2618,2342,15555" %}
[esplora convo]: http://www.erisian.com.au/bitcoin-core-dev/log-2019-03-08.html#l-53
[havar github]: https://github.com/Blockstream/esplora/issues/51
[mit vids]: https://www.youtube.com/user/MITBitcoinClub/videos
[0.18.0]: https://bitcoincore.org/bin/bitcoin-core-0.18.0/
[noinput thread]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-March/016766.html
[ivgi twitter]: https://twitter.com/shesek/status/1103320174936109057
[uih2]: https://gist.github.com/AdamISZ/4551b947789d3216bacfcb7af25e029e#gistcomment-2796539
[havar reddit]: https://old.reddit.com/r/Bitcoin/comments/ay1b0e/new_update_for_blockstreaminfo_is_out_fee_privacy/ehy77cn/
[banlist cli]: https://people.xiph.org/~greg/banlist.cli.txt
[banlist gui]: https://people.xiph.org/~greg/banlist.gui.txt
[core dev irc]: http://www.erisian.com.au/meetbot/bitcoin-core-dev/2019/bitcoin-core-dev.2019-03-14-19.00.log.html#l-53
[ldev mv]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-March/001915.html
[bdev mv]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-March/016785.html
[groups.io]: https://groups.io/
[newsletter #37]: /zh/newsletters/2019/03/12/#removal-of-bip61-p2p-reject-messages
[newsletter #34]: /zh/newsletters/2019/02/19/#discussion-about-tagging-outputs-to-enable-restricted-features-on-spending
[newsletter #25]: /zh/newsletters/2018/12/11/#modern-block-explorer-open-sourced
[newsletter #7]: /zh/newsletters/2018/08/07/#lnd-1543
[newsletter #19]: /zh/newsletters/2018/10/30/#lnd-1535-1512
[newsletter #22]: /zh/newsletters/2018/11/20/#lnd-2124
[newsletter #30]: /zh/newsletters/2019/01/22/#lnd-2448
