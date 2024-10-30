---
title: 'Bitcoin Optech Newsletter #107'
permalink: /zh/newsletters/2020/07/22/
name: 2020-07-22-newsletter-zh
slug: 2020-07-22-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 链接了几个关于激活 Taproot 的讨论，并总结了对 BIP173 Bech32 地址提议的更新。此外，还包括我们常规的服务和客户端软件的有趣更改、发布与候选发布以及流行的比特币基础设施软件的值得注意的更改。

## 行动项

*本周无。*

## 新闻

- **<!--taproot-activation-discussions-->****Taproot 激活讨论：** 本周启动或继续了几个关于选择激活 [Taproot][topic taproot] 方法的讨论。

  - **<!--new-irc-room-->****新的 IRC 聊天室：** Steve Lee 在 Bitcoin-Dev 邮件列表中[发布][lee irc]了一则公告，宣布在 [Freenode][] 网络上开设一个新的 `##taproot-activation` IRC 聊天室。该频道是[有记录的][irc log]，并在第一周内吸引了数十位参与者的积极讨论。

  - **<!--mailing-list-thread-->****邮件列表讨论：** Anthony Towns [发布][towns post]了一份总结，介绍了最近更新的 [BIP8][] 激活方法（参见 [Newsletter #104][news104 bip8]），以及他自己提出的新的 [bip-decthresh][] 激活提案（基于 Matt Corallo 在一月份关于“现代软分叉激活”[帖子][msfa]的内容，参见 [Newsletter #80][news80 activation]）。这种递减阈值的想法的一个有趣特性是，在最终激活期内，需要信号支持新软分叉规则的网络算力比例将逐渐减少，允许矿工以可能低至 60% 的矿工支持度而不是第一个激活期内的 95% 来完成激活。

- **<!--bech32-address-updates-->****Bech32 地址更新：** Russell O'Connor 在 Bitcoin-Dev 邮件列表中[回复][oconnor post]了 Pieter Wuille 的一篇 11 月份的帖子（参见 [Newsletter #77][news77 bech32]），讨论了修改 [BIP173][] 以仅允许长度为 20 或 32 字节的见证程序，以最小化用户由于输入错误而导致比特币不可恢复地发送到错误地址的风险。O'Connor 提出了一个反提案，建议允许见证程序长度比下一个最短地址多五个字符，直到见证程序的共识限制长度。该反提案未在邮件列表中引起讨论，但一份更新 BIP173 的[PR][BIPs #945] 收到了几条评论。截至本文撰写时，尚未就使用何种长度限制达成结论。

## 服务和客户端软件的更改

*在本月的特色内容中，我们重点介绍了比特币钱包和服务的有趣更新。*

- **<!--electrum-adds-lightning-network-and-psbt-support-->****Electrum 增加了闪电网络和 PSBT 支持：**
  [Electrum 4.0.1][electrum release notes] 的 LN 支持包括本地和远程[瞭望塔][topic watchtowers]功能以及通过 Electrum Technologies 中央服务器进行的潜水交换。Electrum 还将其部分交易格式替换为 PSBT。

- **<!--lily-wallet-initial-release-->****Lily Wallet 初始发布：**
  [Lily Wallet][lily wallet site] 宣布其多账户桌面多签保险库应用程序的 v0.0.1-beta 版本初始发布。Lily Wallet 创建 2-of-3 Bech32 地址，并使用 [HWI][topic hwi]、HD 钱包和 PSBT 进行交易。

- **<!--zap-0-7-0-beta-released-->****Zap 0.7.0 Beta 发布：** [Zap 0.7.0 Beta][zap 0.7.0] 增加了[自发支付][topic spontaneous payments]、[支付探测][news30 probing]、[多路径支付][topic multipath payments]和[保留发票][topic hold invoices]。

- **<!--btcpay-server-1-0-5-0-implements-various-standards-->****BTCPay Server 1.0.5.0 实现了多个标准：**
  [BTCPay Server 1.0.5.0][btcpay 1.0.5.0] 增加了 [BIP78][]、[BIP21][] 以及额外的 [PSBT][topic psbt] 支持。

## 发布与候选发布

*热门比特币基础设施项目的新发布与候选发布。请考虑升级到新版本或帮助测试候选版本。*

- [LND 0.10.4][] 是一个修复 Windows 备份问题的小版本更新。

- [C-Lightning 0.9.0rc2][C-Lightning 0.9.0] 是即将发布的主要版本的候选版本。它增加了对更新的 `pay` 命令和新的 `keysend` RPC 的支持，这些内容在本 Newsletter 的*值得注意的代码更改*部分进行了描述，此外还包括其他一些值得注意的更改和多个错误修复。

## 值得注意的代码和文档更改

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的更改。*

- [Bitcoin Core #19109][] 进一步改进了[交易来源隐私][transaction origin wiki]。在 [Bitcoin Core #18861][bitcoin 18861 newsletter] 的基础上，此补丁为每个节点增加了一个滚动布隆过滤器，用于跟踪哪些交易最近被宣布给该节点。当某个节点请求一个交易时，此升级会在满足请求并中继该交易之前检查过滤器，以防止间谍节点获知我们内存池的确切内容或交易接收的精确时间。

- [Bitcoin Core #16525][] 更新了多个 RPC 以返回作为无符号整数的交易版本号，而不是有符号整数。早期版本的比特币将版本号解释为有符号整数（并且[一些][35e79ee733fad376e76d16d1f10088273c2f4c2eaba1374a837378a88e530005]区块链上的交易确实设定了负数版本号），但引入 [BIP68][] nSequence 强制执行版本号为 2 或更高的交易时规定，它将匹配对交易 nVersion 字段的无符号整数转换。预计任何未来使用交易版本的软分叉都会指定相同的规则，因此 RPC 应始终返回交易版本的无符号整数。

- [C-Lightning #3809][] 增加了对 C-Lightning 有效发送[多路径支付][topic multipath payments]的支持——将支付拆分为多个部分，每部分通过不同路径路由。简而言之，C-Lightning 使用的算法将支付拆分为大约 0.0001 BTC 的部分（每部分的金额会随机波动 ±10%）。如果发送的任何部分失败，则将该部分大致一分为二（同样 ±10%）并重新发送。此外，该 PR 还增加了一个 `disable-mpp` 配置选项，以防止发送任何多路径支付；相同名称的参数也被添加到 `pay` 命令中，用于禁用特定尝试的多路径支付。

- [C-Lightning #3825][] 修改了[最近合并][news105 cl3775]（但尚未发布）的 `reserveinputs` RPC，使其不再生成新的 [PSBT][topic psbt]。取而代之的是，引入了一个新的 `fundpsbt` RPC 来创建新的 PSBT。现在，可以将现有的 PSBT 传递给 `reserveinputs`，以防止 PSBT 的 UTXO 输入在指定区块高度之前（默认 72 个区块，大约 12 小时）或守护进程运行期间被用于其他交易。或者，`fundpsbt` 在创建交易时默认保留选择的 UTXO。

- [C-Lightning #3826][] 完成了一系列修改 C-Lightning 用于发送支付的逻辑的 PR。这些更改大部分对用户是透明的，但如果出现问题，从现在起可以通过新的 `legacypay` 命令使用旧逻辑。任何从现在开始使用 `pay` 命令的用户都将使用新逻辑。

- [C-Lightning #3792][] 增加了一个新的 `keysend` RPC 用于发送[自发支付][topic spontaneous payments]。这个新的 RPC 与 [Newsletter #94][news94 keysend] 中描述的 `keysend` 插件不同，后者允许 C-Lightning *接收* 自发支付。

- [LND #4429][] 增加了一个 `--protocol.wumbo` 配置选项，并默认启用。当本地节点和远程对等节点都支持时，该选项允许开启[大额通道][topic large channels]，即通道的总价值超过 0.16 BTC。

{% include references.md %}
{% include linkers/issues.md issues="19109,16525,3809,3825,3826,3792,4429,945" %}
[C-Lightning 0.9.0]: https://github.com/ElementsProject/lightning/releases/tag/v0.9.0rc2
[LND 0.10.4]: https://github.com/lightningnetwork/lnd/releases/tag/v0.10.4-beta
[bitcoin 18861 newsletter]: /zh/newsletters/2020/05/27/#bitcoin-core-18861
[transaction origin wiki]: https://en.bitcoin.it/wiki/Privacy#Traffic_analysis
[news105 cl3775]: /zh/newsletters/2020/07/08/#c-lightning-3775
[35e79ee733fad376e76d16d1f10088273c2f4c2eaba1374a837378a88e530005]: https://blockstream.info/tx/35e79ee733fad376e76d16d1f10088273c2f4c2eaba1374a837378a88e530005
[lee irc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-July/018042.html
[irc log]: http://gnusha.org/taproot-activation/
[news104 bip8]: /zh/newsletters/2020/07/01/#bips-550
[bip-decthresh]: https://github.com/ajtowns/bips/blob/202007-activation-dec-thresh/bip-decthresh.mediawiki
[msfa]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017547.html
[news80 activation]: /zh/newsletters/2020/01/15/#discussion-of-soft-fork-activation-mechanisms
[oconnor post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-July/018048.html
[news77 bech32]: /zh/newsletters/2019/12/18/#review-bech32-action-plan
[news94 keysend]: /zh/newsletters/2020/04/22/#c-lightning-3611
[freenode]: https://freenode.net/
[towns post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-July/018043.html
[electrum release notes]: https://github.com/spesmilo/electrum/blob/4.0.1/RELEASE-NOTES
[lily wallet site]: http://lily.kevinmulcrone.com/
[news30 probing]: /zh/newsletters/2019/01/22/#eclair-762
[zap 0.7.0]: https://github.com/LN-Zap/zap-desktop/releases/tag/v0.7.0-beta
[btcpay 1.0.5.0]: https://blog.btcpayserver.org/btcpay-server-1-0-5-0/
[hwi]: https://github.com/bitcoin-core/HWI
