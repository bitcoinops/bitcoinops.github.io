---
title: 'Bitcoin Optech Newsletter #107'
permalink: /zh/newsletters/2020/07/22/
name: 2020-07-22-newsletter-zh
slug: 2020-07-22-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 链接了几场关于激活 taproot 的讨论，并总结了对 BIP173 bech32 地址的一项拟议更新。我们还照例收录了服务与客户端软件的有趣更新、发布与候选发布，以及热门比特币基础设施软件的值得注意的变更。

## 行动项

*本周无。*

## 新闻

- **<!--taproot-activation-discussions-->****Taproot 激活讨论：** 本周有多场讨论启动或延续，主题是如何选择激活 [taproot][topic taproot] 的方法。

  - **<!--new-irc-room-->****新的 IRC 聊天室：** Steve Lee 向 Bitcoin-Dev 邮件列表[发帖][lee irc]，宣布在 [Freenode][] 网络上新开一个 `##taproot-activation` IRC 聊天室。该频道有公开的[聊天记录][irc log]，第一周内就有数十位参与者贡献了大量讨论。

  - **<!--mailing-list-thread-->****邮件列表讨论帖：** Anthony Towns [发帖][towns post]，总结了最近更新的 [BIP8][] 激活方法（参见 [Newsletter #104][news104 bip8]），也总结了他自己新提出的 [bip-decthresh][] 激活提案（基于 Matt Corallo 一月份关于“现代软分叉激活”的[帖子][msfa]，参见 [Newsletter #80][news80 activation]）。递减阈值这一思路的有趣之处在于：在最终激活期内，需要用以信号表示准备执行新软分叉规则的网络算力比例会逐步下降，于是可能只需低至 60% 的矿工支持就能完成矿工激活，而不必像第一个激活期那样需要 95% 的矿工支持。

- **<!--bech32-address-updates-->****Bech32 地址更新：** Russell O'Connor 在 Bitcoin-Dev 邮件列表上[回复][oconnor post]了 Pieter Wuille 去年 11 月的一篇帖子（参见 [Newsletter #77][news77 bech32]），议题是修改 [BIP173][]，只允许 20 或 32 字节的见证程序，以尽量降低用户因笔误而把比特币不可挽回地发送到错误地址的风险。O'Connor 提出反提案：只要某个见证程序的地址比次短的地址多五个字符，就可以允许，上限是共识规定的见证程序长度限制。该反提案在邮件列表上没有引起讨论，但一份更新 BIP173 的 [PR][BIPs #945] 收到了若干评论。截至本文撰写时，对于应采用何种长度限制，尚未得出结论。

## 服务和客户端软件的变更

*在本月栏目中，我们重点介绍 Bitcoin 钱包与服务的一些有趣更新。*

- **<!--electrum-adds-lightning-network-and-psbt-support-->****Electrum 新增闪电网络与 PSBT 支持：**
  [Electrum 4.0.1][electrum release notes] 的 LN 支持包括本地与远程[瞭望塔][topic watchtowers] 功能，以及借助 Electrum Technologies 中心服务器实现的潜艇交换（submarine swap）。Electrum 还把它原有的部分交易格式换成了 PSBT。

- **<!--lily-wallet-initial-release-->****Lily Wallet 首次发布：**
  [Lily Wallet][lily wallet site] 宣布其多账户桌面多重签名保险库应用发布首个 v0.0.1-beta 版本。Lily Wallet 会创建 2-of-3 bech32 地址，并使用 [HWI][topic hwi]、HD 钱包和 PSBT 完成交易。

- **<!--zap-0-7-0-beta-released-->****Zap 0.7.0 Beta 发布：** [Zap 0.7.0 Beta][zap 0.7.0] 新增了[自发支付][topic spontaneous payments]、[支付探测][news30 probing]、[多路径支付][topic multipath payments] 和[挂起发票][topic hold invoices]。

- **<!--btcpay-server-1-0-5-0-implements-various-standards-->****BTCPay Server 1.0.5.0 实现了多个标准：**
  [BTCPay Server 1.0.5.0][btcpay 1.0.5.0] 增加了 [BIP78][]、[BIP21][] 以及额外的 [PSBT][topic psbt] 支持。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [LND 0.10.4][] 是一个小版本发布，修复了影响 Windows 上备份的 bug。

- [C-Lightning 0.9.0rc2][C-Lightning 0.9.0] 是一个即将到来的大版本的候选发布。它新增了对本 Newsletter 的*值得注意的代码变更*部分所述更新版 `pay` 命令和新 `keysend` RPC 的支持，此外还包含若干其他值得注意的变更和多项错误修复。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi]、[比特币改进提案（BIPs）][bips repo]和[闪电网络 BOLT 规范][bolts repo]中的值得注意的变更。*

- [Bitcoin Core #19109][] 进一步改进了[交易来源隐私][transaction origin wiki]。在 [Bitcoin Core #18861][bitcoin 18861 newsletter] 的基础上，这个补丁为每个对等节点增加了一个滚动布隆过滤器，用来记录最近向该对等节点公告过哪些交易。当某个对等节点请求某笔交易时，该改进会先检查这个过滤器，再满足请求并中继交易，从而防止间谍节点得知我们内存池的确切内容，或某笔交易被收到的精确时间。

- [Bitcoin Core #16525][] 更新了多个 RPC，把交易版本号作为无符号整数返回，而不再作为有符号整数返回。早期版本的比特币把版本号当作有符号整数解释（链上[有些][35e79ee733fad376e76d16d1f10088273c2f4c2eaba1374a837378a88e530005] 交易确实设过负数版本号），但 [BIP68][] 为版本号 2 及以上的交易引入 nSequence 强制规则时规定，比较时应先把交易的 nVersion 字段转换为无符号整数。预计未来任何用到交易版本号的软分叉都会规定同样的规则，因此 RPC 一律返回无符号的交易版本号是合理的。

- [C-Lightning #3809][] 为 C-Lightning 增加了有效发送[多路径支付][topic multipath payments] 的能力——这种支付被拆成若干部分，每部分走不同路径。简单说，C-Lightning 采用的算法把一笔支付拆成若干约 0.0001 BTC 的份额（每份金额随机浮动 ±10%）。任何已发送的份额若失败，就把该份额大致对半再拆成两份（同样 ±10%），然后把这两份都重发。该 PR 还新增了 `disable-mpp` 配置选项，用于禁止发送任何多路径支付；`pay` 命令也加了同名参数，用于在这一次尝试中禁用多路径支付。

- [C-Lightning #3825][] 修改了[最近合并][news105 cl3775]（但从未发布）的 `reserveinputs` RPC，使其不再生成新的 [PSBT][topic psbt]。取而代之，新增 `fundpsbt` RPC 来创建新的 PSBT。现在可以把已有的 PSBT 传给 `reserveinputs`，使该 PSBT 的 UTXO 输入在指定区块高度之前（默认从现在起 72 个区块，约 12 小时）或守护进程运行期间，不会被用于其他交易。另一种做法是让 `fundpsbt` 在创建交易时默认预留选中的 UTXO。

- [C-Lightning #3826][] 完成了一系列修改 C-Lightning 支付发送逻辑的 PR。其中大部分改动对用户应当不可见，但万一出问题，可以用新增的 `legacypay` 命令走 `pay` 命令原有的旧逻辑。从现在起，任何使用 `pay` 命令的人都在使用新逻辑。

- [C-Lightning #3792][] 增加了一个新的 `keysend` RPC 用于发送[自发支付][topic spontaneous payments]。这个新的 RPC 与 [Newsletter #94][news94 keysend] 中描述的 `keysend` 插件不同，后者允许 C-Lightning *接收* 自发支付。

- [LND #4429][] 新增 `--protocol.wumbo` 配置选项，并默认启用。当本地节点与远程对等节点都支持时，该选项允许开启[大额通道][topic large channels]，即总价值超过 0.16 BTC 的通道。

{% include references.md %}
{% include linkers/issues.md issues="19109,16525,3809,3825,3826,3792,4429,945" %}
[C-Lightning 0.9.0]: https://github.com/ElementsProject/lightning/releases/tag/v0.9.0rc2
[LND 0.10.4]: https://github.com/lightningnetwork/lnd/releases/tag/v0.10.4-beta
[bitcoin 18861 newsletter]: /zh/newsletters/2020/05/27/#bitcoin-core-18861
[transaction origin wiki]: https://en.bitcoin.it/wiki/Privacy#Traffic_analysis
[news105 cl3775]: /zh/newsletters/2020/07/08/#c-lightning-3775
[35e79ee733fad376e76d16d1f10088273c2f4c2eaba1374a837378a88e530005]: https://blockstream.info/tx/35e79ee733fad376e76d16d1f10088273c2f4c2eaba1374a837378a88e530005
[lee irc]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-July/018042.html
[irc log]: http://gnusha.org/taproot-activation/
[news104 bip8]: /zh/newsletters/2020/07/01/#bips-550
[bip-decthresh]: https://github.com/ajtowns/bips/blob/202007-activation-dec-thresh/bip-decthresh.mediawiki
[msfa]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017547.html
[news80 activation]: /zh/newsletters/2020/01/15/#discussion-of-soft-fork-activation-mechanisms
[oconnor post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-July/018048.html
[news77 bech32]: /zh/newsletters/2019/12/18/#review-bech32-action-plan
[news94 keysend]: /zh/newsletters/2020/04/22/#c-lightning-3611
[freenode]: https://freenode.net/
[towns post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-July/018043.html
[electrum release notes]: https://github.com/spesmilo/electrum/blob/4.0.1/RELEASE-NOTES
[lily wallet site]: http://lily.kevinmulcrone.com/
[news30 probing]: /zh/newsletters/2019/01/22/#eclair-762
[zap 0.7.0]: https://github.com/LN-Zap/zap-desktop/releases/tag/v0.7.0-beta
[btcpay 1.0.5.0]: https://blog.btcpayserver.org/btcpay-server-1-0-5-0/
[hwi]: https://github.com/bitcoin-core/HWI
