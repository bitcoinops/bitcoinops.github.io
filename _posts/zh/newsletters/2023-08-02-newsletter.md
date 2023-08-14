---
title: 'Bitcoin Optech Newsletter #262'
permalink: /zh/newsletters/2023/08/02/
name: 2023-08-02-newsletter-zh
slug: 2023-08-02-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报链接到最近的 LN 规范会议的文字记录，并总结了有关 MuSig2 盲签名安全性的主题。此外还有我们的常规部分：新版本和候选版本的描述，以及对热门比特币基础设施项目的重大代码变更介绍。

## 新闻

- **定期的 LN 规范会议记录：** Carla Kirk-Cohen 在 Lightning-Dev 邮件列表上[发布了][kc scripts]通知，宣布最近几次讨论 LN 规范变更的视频会议已经被记录下来。这些记录现在可在 Bitcoin Transcripts 上[获得][btcscripts spec]。在相关新闻中，正如在面对面 LN 开发者会议中几周前讨论的那样，[Libera.chat][] 网络上的 `#lightning-dev` IRC 聊天室已经看到了与 LN 相关的讨论的大量新活动。{% assign timestamp="1:13" %}

- **MuSig2 盲签名的安全性：** Tom Trevethan 在 Bitcoin-Dev 邮件列表中[发帖][trevethan blind]，请求对计划成为 [statechains][topic statechains] 部署一部分的加密协议进行评审。目标是部署一项服务，该服务将使用自己的私钥创建 [MuSig2][topic musig] 部分签名，而不需要获得有关签名内容或者其部分签名使用方式的任何知识。盲签名者只需报告它用特定私钥创建了多少个签名。

    邮件组里的讨论检查了与特定问题相关的各种构造以及[更为普遍的 Schnorr 盲签名][generalized blind schnorr]的陷阱。还提到了 Ruben Somsen 一年前提及的有关 1996 年的盲化 [Diffie-Hellman (DH) 密钥交换][dhke]协议的[要点][somsen gist]，该协议可用于盲化的 ecash。[Lucre][] 和 [Minicash][] 是此方案之前与比特币无关的实现，而 [Cashu][] 是 Minicash 相关的实现，并集成了比特币和 LN 的支持。任何对密码学感兴趣的人可能会发现该主题对密码学技术的讨论很有趣。{% assign timestamp="5:07" %}

## 版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [BTCPay Server 1.11.1][] 是该自托管支付处理器的最新版本。1.11.x 系列版本包括发票报告的改进，结账过程的额外升级以及销售点服务终端的新功能。{% assign timestamp="24:30" %}

## 重大的代码和文档变更

*本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo] 和
[Bitcoin Inquisition][bitcoin inquisition repo]。*

- [Bitcoin Core #26467][]允许用户指定交易的哪个输出是在 `bumpfee` 中的找零输出。在创建[替换交易][topic rbf]时，钱包会从此输出中扣除价值以增加费用。默认情况下，钱包会尝试自动检测找零输出，如果失败则创建一个新的输出。{% assign timestamp="25:31" %}

- [Core Lightning #6378][]和[#6449][core lightning #6449]将会把一个链下转发来的 [HTLC][topic htlc]标记为失败，如果当节点无法（或由于费用成本而不愿意）使相应的链上 HTLC 超时时。例如，Alice 的节点将一个有效期为 20 个区块的 HTLC 转发到 Bob 的节点，Bob 的节点将具有相同支付哈希的 HTLC 转发到 Carol 的节点，有效期为 10 个区块。随后，Bob 和 Carol 之间的通道在链上被强制关闭。

    10 个区块到期后，会出现一种不常见的情况：Bob 的节点要么使用退款条件进行花费，但交易未确认；要么他决定，由于要求退款所产生的费用高于交易价值而不会进行花费。在此 PR 之前，Bob 的节点不会在链下取消从 Alice 收到的 HTLC，因为这可以让 Alice 保留她转发给 Bob 的钱，并让 Carol 领取 Bob 转发给自己的钱，从而使 Bob 来承担此 HTLC 的损失。

    然而，在 Alice 向 Bob 提供的 HTLC 的 20 个区块到期后，Alice 可以强制关闭通道以尝试接收她转发给 Bob 金额的退款，并且 Alice 的软件可能会自动执行此操作以防止她可能损失其上游的节点转发的钱。但是，如果她强行关闭通道，她最终可能会陷入与 Bob 相同的境地：她要么无法申请退款，要么不尝试退款，因为经济上不可行。这意味着 Alice 和 Bob 之间的有用通道被关闭，对他们任何一个都没有好处。对于 Alice 上游的任何一方，此问题可能会重复多次，从而导致一连串不必要的通道关闭。

    此 PR 中实施的解决方案是：Bob 在合理的时间内等待申请退款，如果没有发生，则他在链下取消从 Alice 收到的 HTLC以允许他们的通道继续运行，即使意味着他可能会损失 HTLC 的金额。{% assign timestamp="27:19" %}

- [Core Lightning #6399][]添加了对 `pay` 命令的支持，用于支付本地节点创建的发票。这可以简化在后台调用 CLN 的软件的帐户管理代码，正如最近的[邮件列表主题][fiatjaf custodial]中所讨论的那样。{% assign timestamp="33:03" %}

- [Core Lightning #6389][]添加了一个可选的 CLNRest 服务，“一个基于 Python 的轻量级 Core Lightning 插件，可将 RPC 调用转换为 REST 服务。通过生成 REST API 端点，它可以在幕后执行 Core Lightning 的 RPC 方法并提供 JSON 格式的响应”。有关详细信息，请参阅[文档][clnrest doc]。{% assign timestamp="35:48" %}

- [Core Lightning #6403][]和[#6437][core lightning #6437]将 runes 授权和身份验证机制从 CLN 的 commando 插件(见[周报#210][news210 commando])移至其核心功能中，允许其他插件使用它们；创建、销毁和重命名 runes 相关的几个命令也已更新。（译者注：runes 是 CLN 定制的简化版 macaroons 协议。）{% assign timestamp="37:37" %}

- [Core Lightning #6398][]使用新的 `ignorefeelimits` 选项扩展了 `setchannel` RPC，该选项将忽略通道的最低链上费用限制，允许远程通道对手方将费用设置为低于本地节点允许的最低费用。这可以帮助解决另一个 LN 节点实现中的潜在错误，或者可以被用来消除部分可信通道作为问题根源的费用争用问题。{% assign timestamp="39:52" %}

- [Core Lightning #5492][]添加了“用户级静态定义跟踪点(USDT)”以及使用它们的方法。这些允许用户探测其节点的内部操作以进行调试，而在不使用跟踪点时不会引入任何显著的开销。有关之前将 USDT 支持纳入 Bitcoin Core 的信息，见[周报#133][news133 usdt]。{% assign timestamp="45:52" %}

- [Eclair #2680][]添加了对[BOLTs #863][]中提出的[通道拼接协议][topic splicing]所需的静止协商协议的支持。静止协议防止共享通道的两个节点相互发送任何新的[HTLCs][topic htlc]，直到某个操作完成为止，例如就拼接参数达成一致并合作签署链上拼接输入或拼接输出的交易。在拼接协商和签名期间收到的 HTLC 可能会使之前的协商和签名无效，因此更简单的是，只需暂停 HTLC 中继以完成拼接交易所必需的共同签名的几次网络往返通信。Eclair 已经支持通道拼接，但这一变化使其更易于支持其他节点软件可能使用的通道拼接协议。{% assign timestamp="51:42" %}

- [LND #7820][]将 `BatchOpenChannel` RPC 可用的所有字段添加到非批处理的 `OpenChannel` RPC 中，但除了 `funding_shim` (批量打开不需要)和 `fundmax` (打开多个通道时不能为一个通道提供所有余额)。{% assign timestamp="53:57" %}

- [LND #7516][]使用新的 `utxo` 参数扩展了 `OpenChannel` RPC，该参数允许从钱包中指定一个或多个 UTXO，这些 UTXO 用于为新通道提供资金。{% assign timestamp="54:57" %}

- [BTCPay Server #5155][]在后台添加了一个报告页面，可提供支付和链上钱包报告、导出到 CSV 的能力，并且可以通过插件来扩展。{% assign timestamp="57:26" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="863,26467,6378,6449,6399,6389,6403,6437,6398,5492,2680,7820,7516,5155" %}
[clnrest doc]: https://github.com/rustyrussell/lightning/blob/02c2d8a9e3b450ce172e8bc50c855ac2a16f5cac/plugins/clnrest/README.md
[news133 usdt]: /en/newsletters/2021/01/27/#bitcoin-core-19866
[kc scripts]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-July/004025.html
[btcscripts spec]: https://btctranscripts.com/lightning-specification/
[libera.chat]: https://libera.chat/
[trevethan blind]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-July/021792.html
[generalized blind schnorr]: https://gist.github.com/moonsettler/05f5948291ba8dba63a3985b786233bb
[somsen gist]: https://gist.github.com/RubenSomsen/be7a4760dd4596d06963d67baf140406
[lucre]: https://github.com/benlaurie/lucre
[minicash]: https://github.com/phyro/minicash
[cashu]: https://github.com/cashubtc/cashu
[fiatjaf custodial]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-July/004008.html
[news210 commando]: /zh/newsletters/2022/07/27/#core-lightning-5370
[dhke]: https://zh.wikipedia.org/wiki/%E8%BF%AA%E8%8F%B2-%E8%B5%AB%E7%88%BE%E6%9B%BC%E5%AF%86%E9%91%B0%E4%BA%A4%E6%8F%9B
[btcpay server 1.11.1]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.11.1
