---
title: 'Bitcoin Optech Newsletter #343'
permalink: /zh/newsletters/2025/02/28/
name: 2025-02-28-newsletter-zh
slug: 2025-02-28-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报总结了一篇关于让全节点忽略未经请求而转发过来的交易的文章。此外还包括我们的常规部分，其中有来自比特币 Stack Exchange 的热门问题和答案，新版本和候选版本的公告，以及对流行的比特币基础设施软件的重要变更摘要。

## 新闻

- **<!--ignoring-unsolicited-transactions-->忽略未经请求的交易：** Antoine Riard 在 Bitcoin-Dev 邮件列表[发布][riard unsol]了两个草案 BIP，这些 BIP 将允许节点表明它将不再接受未通过 `inv` 消息请求的 `tx` 消息，即所谓的_未经请求的交易_。Riard 之前在 2021 年提出了这一总体想法（参见[周报 #136][news136 unsol]）。第一个提议的 BIP 添加了一种机制，允许节点表明其交易转发能力和偏好；第二个提议的 BIP 使用该信号机制表明节点将忽略未经请求的交易。

  该提案有几个小优势，正如在 [Bitcoin Core 拉取请求][bitcoin core #30572]中讨论的那样，但它与一些较旧的轻量级客户端的设计相冲突，可能会阻止该软件的用户能够广播他们的交易，因此可能需要谨慎部署。尽管 Riard 已经开启了上述拉取请求，但他后来关闭了它，表示他计划基于 libbitcoinkernel 开发自己的全节点实现。他还表示，该提案可能有助于解决他最近披露的一些攻击（参见[周报 #332][news332 txcen]）。

## 来自 Bitcoin Stack Exchange 的精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找答案的首选场所之一，也是我们有空闲时间时帮助好奇或困惑用户的地方。在这个月度专栏中，我们会突出显示自上次更新以来发布的一些投票最高的问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!what-s-the-rationale-for-how-the-loadtxsoutset-rpc-is-set-up-->loadtxsoutset RPC 的设置原理是什么？]({{bse}}125627)
  Pieter Wuille 解释了为什么 [assumeUTXO][topic assumeUTXO] 表示 UTXO 集的值是硬编码在软件中的（绑定了区块高度），未来分发 assumeUTXO 快照的方式，以及与仅复制 Bitcoin Core 内部数据存储相比 assumeUTXO 的好处。

- [<!--are-there-classes-of-pinning-attacks-that-rbf-rule-3-makes-impossible-->有哪些类型的交易钉死攻击是 RBF 规则 #3 使其不可能发生的？]({{bse}}125461)
  Murch 指出 [RBF][topic rbf] 规则 #3 并非旨在防止[交易钉死][topic transaction pinning]攻击，并简要介绍了 Bitcoin Core 的[替换政策][bitcoin core replacements]。

- [<!--unexpected-locktime-values-->意外的锁定时间值]({{bse}}125562)
  用户 polespinasa 列出了 Bitcoin Core 设置特定 [nLockTime][topic timelocks] 值的不同原因：设为 `block_height` 以避免[手续费狙击][topic fee sniping]，10% 的时间将其设为小于区块高度的随机值以增加隐私，或者在区块链不是最新时设为 0。

- [<!--why-is-it-necessary-to-reveal-a-bit-in-a-script-path-spend-and-check-that-it-matches-the-parity-of-the-y-coordinate-of-q-->为什么在脚本路径花费中需要揭示一个比特并检查它是否与 Q 的 Y 坐标的奇偶性匹配？]({{bse}}125502)
  Pieter Wuille 详细阐述了 [BIP341 的原理][bip341 rationale]，即在 [taproot][topic taproot] 脚本路径花费期间保留 Y 坐标奇偶性检查，以允许未来可能添加批量验证功能。

- [<!--why-does-bitcoin-core-use-checkpoints-and-not-the-assumevalid-block-->为什么 Bitcoin Core 使用检查点而不是 assumevalid 区块？]({{bse}}125626)
  Pieter Wuille 详细介绍了 Bitcoin Core 中检查点的历史及其作用，并指向了一个关于[移除检查点][Bitcoin Core #31649]的开放 PR 和讨论。

- [<!--how-does-bitcoin-core-handle-long-reorgs-->Bitcoin Core 如何处理长链重组？]({{bse}}105525)
  Pieter Wuille 概述了 Bitcoin Core 如何处理区块链重组，并指出在较大重组中的一个区别是“不会执行将交易重新添加回交易池的操作”。

- [<!--what-is-the-definition-of-discard-feerate-->丢弃手续费率的定义是什么？]({{bse}}125623)
  Murch 将丢弃手续费率定义为丢弃找零的最大手续费率，并总结了计算丢弃手续费率的代码为“1000 区块目标手续费率，如果超出 3-10 ṩ/vB 的范围则裁剪到该范围内”。

- [<!--policy-to-miniscript-compiler-->从花费条款到 miniscript 的编译器]({{bse}}125406)
  Brunoerg 指出 Liana 钱包使用 miniscript 的 policy（花费条款）语言，并指向 [sipa/miniscript][miniscript github] 和 [rust-miniscript][rust-miniscript github] 库作为条款编译器的例子。

## 新版本和候选版本

_流行的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。_

- [Core Lightning 25.02rc3][] 是这个流行的闪电网络节点下一个主要版本的候选版本。

## 重要代码和文档变更

_以下是[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 中最近的重要变更。_

- [Core Lightning #8116][] 改变了通道关闭协商中断的处理方式，即使不需要也会重试该过程。这修复了一个问题，即当节点错过对等节点的 `CLOSING_SIGNED` 消息时，重新连接时会出错并广播单方面关闭交易。同时，已处于 `CLOSINGD_COMPLETE` 状态的对等节点已广播了双方同意的关闭交易，可能导致两个交易之间的竞争。此修复允许重新协商继续进行，直到双方同意的关闭交易得到确认。

- [Core Lightning #8095][] 为 `setconfig` 命令（参见周报 [#257][news257 setconfig]）添加了 `transient` 标志；引入了临时启用的动态配置变量，而不修改配置文件。这些更改在重启时会被恢复。

- [Core Lightning #7772][] 向 `chanbackup` 插件添加了 `commitment_revocation` 钩子，每当收到新的撤销密钥时更新 `emergency.recover` 文件（参见周报 [#324][news324 emergency]）。这使用户能够在使用 `emergency.recover` 清扫资金时，如果对等节点发布了过时的已撤销状态，则广播惩罚交易。此 PR 扩展了[静态通道备份][topic static channel backups] SCB 格式，并更新了 `chanbackup` 插件以序列化新旧两种格式。

- [Core Lightning #8094][] 为 `xpay` 插件（参见周报 [#330][news330 xpay]）引入了运行时可配置的 `xpay-slow-mode` 变量，该变量会延迟返回成功或失败，直到[多路径支付][topic multipath payments]（MPP）的所有部分都得到解决。没有此设置，即使某些 [HTLC][topic htlc] 仍在等待中，也可能返回失败状态。如果用户重试并从另一个节点成功支付了发票，而等待中的 HTLC 也被结算，则可能发生超额支付。

- [Eclair #2993][] 使接收方能够支付与支付路径的[盲化][topic rv routing]部分相关的手续费，而发送方则支付非盲化部分的手续费。之前，发送方支付所有手续费，这可能使他们推断并可能揭示出路径。

- [LND #9491][] 添加了在有活跃 [HTLC][topic htlc] 时使用 `lncli closechannel` 命令进行协作通道关闭的支持。启动后，LND 将暂停通道以防止创建新的 HTLC，并等待所有现有 HTLC 解决后再开始协商过程。用户必须设置 `no_wait` 参数才能启用此行为；否则，错误消息将提示他们指定它。此 PR 还确保在启动协作通道关闭时，`max_fee_rate` 设置对双方都强制执行；之前，它只应用于远程方。

{% include snippets/recap-ad.md when="2025-03-04 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30572,8116,8095,7772,8094,2993,9491,31649" %}
[riard unsol]: https://mailing-list.bitcoindevs.xyz/bitcoindev/e98ec3a3-b88b-4616-8f46-58353703d206n@googlegroups.com/
[news136 unsol]: /zh/newsletters/2021/02/17/#proposal-to-stop-processing-unsolicited-transactions
[news332 txcen]: /zh/newsletters/2024/12/06/#transaction-censorship-vulnerability
[Core Lightning 25.02rc3]: https://github.com/ElementsProject/lightning/releases/tag/v25.02rc3
[news257 setconfig]: /zh/newsletters/2023/06/28/#core-lightning-6303
[news324 emergency]: /zh/newsletters/2024/10/11/#core-lightning-7539
[news330 xpay]: /zh/newsletters/2024/11/22/#core-lightning-7799
[bitcoin core replacements]: https://github.com/bitcoin/bitcoin/blob/master/doc/policy/mempool-replacements.md#current-replace-by-fee-policy
[bip341 rationale]: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki#cite_note-10
[miniscript github]: https://github.com/sipa/miniscript
[rust-miniscript github]: https://github.com/rust-bitcoin/rust-miniscript
