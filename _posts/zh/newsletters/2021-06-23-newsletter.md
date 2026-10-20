---
title: 'Bitcoin Optech Newsletter #154'
permalink: /zh/newsletters/2021/06/23/
name: 2021-06-23-newsletter-zh
slug: 2021-06-23-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 介绍了一个允许所有交易进行 RBF（Replace-by-Fee）的提案，并带来了新系列文章“为 taproot 做准备”的首篇。此外，我们也照例介绍了客户端和服务端的更新、新软件版本与候选发布，以及热门比特币基础设施项目的值得注意的变更。

## 新闻

- **<!--allowing-transaction-replacement-by-default-->****允许默认进行交易替换：** 如今几乎所有比特币全节点都被认为实现了 [BIP125][] 中自愿启用的手续费替换（[RBF][topic rbf]），这允许未确认交易在节点的内存池中被支付更高手续费的其他版本所替换——但前提是交易创建者在原始交易中设置了相应信号。这种自愿启用机制当年是作为一种折中提出的：一方希望允许交易替换（例如用于手续费追加或[批量添加][additive payment batching]），另一方则反对，因为允许替换会让构建欺诈工具变得更容易，而这些工具专门欺骗那些把未确认交易当作最终交易的商家。

  五年多过去了，如今似乎已经很少有商家把未确认交易当作最终交易，而这些商家中究竟有多少真的在检查 BIP125 的自愿启用信号并区别对待，也无从得知。如果没人依赖 BIP125 信号，那么让每笔交易都可被替换或许能带来一些好处，例如：

  - **<!--simplifying-analysis-->****简化对预签名交易协议的分析**
    （例如闪电网络和[保险库][topic vaults]）——在这些协议中，利用 RBF 追加手续费的设想必须考虑到：恶意对手方有能力阻止设置 BIP125 信号。如果每笔交易都能被替换，就不必担心这一点了。

  - **<!--reducing-transaction-analysis-opportunity-->****减少交易分析的机会**
    因为选择性启用 RBF 的交易在链上看起来与未启用的交易不同。由于大多数钱包要么一直启用、要么一直不启用，这就给监控公司提供了线索，供它们在识别谁拥有哪些比特币时使用。如果每笔交易都可替换，就无需再设置 BIP125 信号了。

  本周，Antoine Riard 在 Bitcoin-Dev 邮件列表[发布][riard rbf]了一项提案，希望最终修改 Bitcoin Core 的代码，让所有交易都能使用 RBF，而不管它们是否设置了 BIP125 自愿启用信号。这一想法在首次交易中继工作坊[会议][trw meeting]上也被讨论过。一些与会者提到 Bitcoin Core [PR #10823][bitcoin core #10823] 是另一种做法——它允许任何交易被替换，但只限于该交易已在节点内存池中停留了一定时间之后（最初提议 6 小时，后来有人建议 72 小时）。

  Riard 的邮件和与会者都指出，任何要替换不含 BIP125 自愿启用信号的交易的提案，都需要征求目前依赖 BIP125 行为的商家的意见。Optech 鼓励这类商家在邮件列表的讨论帖中回应。

## 服务和客户端软件的变更

*在本月栏目中，我们重点介绍 Bitcoin 钱包与服务的一些有趣更新。*

- **<!--trezor-suite-adds-rbf-support-->****Trezor Suite 添加 RBF 支持：**
  Trezor 的钱包软件 Trezor Suite 在 21.2.2 版本中[添加了对 RBF 的支持][trezor rbf]。RBF 默认开启，Trezor 的部分硬件设备也支持该功能。

- **<!--lightning-labs-announces-terminal-web-->****Lightning Labs 宣布 Terminal Web：**
  在最近一篇[博客文章][lightning labs terminal web blog]中，Lightning Labs 介绍了他们基于 Web 的闪电网络节点评分仪表盘 [Terminal Web][terminal web]。

- **<!--specter-v1-4-0-released-->****Specter v1.4.0 发布：**
  [Specter v.1.4.0][specter v1.4.0] 新增了一项功能：使用 BIP125 自愿启用的[手续费替换（RBF）][topic rbf]来[“取消”一笔交易][specter 1197]。

- **<!--phoenix-adds-lnurl-pay-->****Phoenix 增加 LNURL-pay：**
  ACINQ 的移动钱包 [Phoenix][phoenix wallet] 在 [v1.4.12 版本][phoenix 1.4.12]中添加了对 [LNURL-pay][lnurl-pay github] 协议的支持。

- **<!--joinmarket-v0-8-3-released-->****JoinMarket v0.8.3 发布：**
  [JoinMarket v0.8.3][joinmarket v0.8.3] 新增了自定义找零地址的功能，以及与 Electrum 兼容的隔离见证 `signmessage` 实现。

## 准备 Taproot #1：Bech32m 发送支持

*这是一个每周更新的[系列][series preparing for taproot]的第一篇，讲述开发者和服务提供商如何为预定在区块高度
{{site.trb}} 激活的 taproot 做准备。*

{% include specials/taproot/zh/00-bech32m.md %}

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [LND 0.13.0-beta][]
  这是一次主要版本更新，通过把 [锚定输出][topic anchor outputs] 设为默认承诺交易格式来改进费率管理，增加了对使用修剪过的比特币全节点的支持，允许使用原子多路径支付（Atomic MultiPath，简称 [AMP][topic multipath payments]）接收和发送付款，并增强了 LND 的[部分签名比特币交易（PSBT）][topic psbt]功能。此外还包含其他多项改进与错误修复。

## 值得注意的代码与文档变更

*以下是本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]的值得注意的变更：*

- [Bitcoin Core #21365][]
  让钱包可以为 [taproot][topic taproot] 花费创建签名——既包括只用 P2TR 公钥的键路径花费，也包括使用 [tapscript][topic tapscript] 的脚本路径花费。钱包还能为花费 taproot 输出的 [PSBT][topic psbt] 签名，但前提是钱包已具备所需的全部键路径或脚本路径信息。另一个有些关系的已合并 PR [#22156][bitcoin core #22156] 只允许在 taproot 激活之后导入这些键路径和脚本路径信息（主网上是区块 {{site.trb}}；而在已经启用 taproot 的测试网络上，现在就可以导入）。

- [Bitcoin Core #22144][]
  把消息处理线程中服务各对等节点的顺序随机化。该线程负责解析和处理来自对等节点的 P2P 消息，并向这些节点发送消息。此前，消息处理线程会按各节点连接最初建立的顺序轮流服务每个节点。该 PR 修改了这一逻辑：在消息处理循环的每一轮中，服务节点的顺序都是随机的。节点的服务频率保持不变（每轮为每个节点服务一次），但那些依赖确定服务顺序的弱点或攻击手法由此被避开。

- [Bitcoin Core #21261][]
  让把入站连接保护扩展到更多网络变得更容易，并借助这一框架把 [I2P][] 加入了受保护网络之列。多样化保护（常被称作 eviction protection）能让少数具有所需特征的对等节点，在 Bitcoin Core 剔除高延迟连接时仍保持连接。保留少量与匿名网络上对等节点的连接非常可取：一来交易创建者可以借助这些网络隐藏自己的网络身份，二来除常规互联网协议之外还能通过这些网络接收区块，可以防止某些类型的[日食攻击][topic eclipse attacks]。

- [Rust Bitcoin #601][]
  增加了对解析 [bech32m][topic bech32] 地址的支持，并要求 v1 及更高版本的原生 segwit 地址必须用 bech32m 编码，而不是 bech32。

- [BTCPay Server #2450][]
  当用户选择用热钱包接收付款时，默认改为生成与 [payjoin][topic payjoin] 兼容的发票。*创建钱包*界面上的一个按钮允许用户取消这一默认设置。

- [BTCPay Server #2559][]
  新增了一个独立界面，引导用户选择如何为从钱包花费的交易签名。对于热钱包，服务器直接签名即可；而对于密钥存储在其他地方的钱包，现在有一个美观且信息充分的图形界面，引导用户在各种签名方式中做出选择，例如输入恢复助记词、使用硬件签名设备，或生成 PSBT 以便传输到签名钱包。

{% include references.md %}
{% include linkers/issues.md issues="10823,21365,22156,22144,21261,601,2450,2559" %}
[LND 0.13.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.13.0-beta.rc5
[trw meeting]: https://gist.githubusercontent.com/ariard/5f28dffe82ddad763b346a2344092ba4/raw/2a8e0d4ff431a225a970d0128aa78616df6b6382/meeting-logs
[additive payment batching]: /zh/cardcoins-rbf-batching/
[riard rbf]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-June/019074.html
[i2p]: https://en.wikipedia.org/wiki/I2P
[phoenix wallet]: https://phoenix.acinq.co/
[phoenix 1.4.12]: https://github.com/ACINQ/phoenix/releases/tag/v1.4.12
[lnurl-pay github]: https://github.com/fiatjaf/lnurl-rfc/blob/master/lnurl-pay.md
[joinmarket v0.8.3]: https://github.com/JoinMarket-Org/joinmarket-clientserver/releases/tag/v0.8.3
[specter v1.4.0]: https://github.com/cryptoadvance/specter-desktop/releases/tag/v1.4.0
[specter 1197]: https://github.com/cryptoadvance/specter-desktop/pull/1197
[terminal web]: https://terminal.lightning.engineering/
[lightning labs terminal web blog]: https://lightning.engineering/posts/2021-05-11-terminal-web/
[trezor rbf]: https://wiki.trezor.io/Replace-by-fee_(RBF)
[series preparing for taproot]: /zh/preparing-for-taproot/
