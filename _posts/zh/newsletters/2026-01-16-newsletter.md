---
title: 'Bitcoin Optech Newsletter #388'
permalink: /zh/newsletters/2026/01/16/
name: 2026-01-16-newsletter-zh
slug: 2026-01-16-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报链接了关于在 Bitcoin Core 中的增量突变测试的讨论，还宣布了一种新的 BIP 流程的部署。此外是我们的常规栏目：软件的新版本和候选版本的发行公告，热门的比特币基础设施项目的重大变更介绍。

## 新闻

- **<!--an-overview-of-incremental-mutation-testing-in-bitcoin-core-->** **Bitcoin Core 的增量突变测试概述**：Bruno Garcia 在 Delving Bitcoin 论坛中[公开][mutant post]了他近期在提升 Bitcoin Core 的突变测试（[mutation testing][news320 mutant]）中的工作。突变测试是一种技术，让开发者可以通过有意向代码库添加系统性的 bug 来评估他们已有的测试项目的有效性。如果测试不通过，就认为这种突变被 “杀死了”，表明已有的测试项目能够捕捉到这个错误；否则，就认为这种突变 “幸存了”，也就是现有的测试项目还有缺陷。

  突变测试已经提供了重要的结果，引致一些 PR 被开启来解决一些报告出来的突变。然而，这个过程是资源密集型的，要花费超过 30 个小时才能在整个代码库的一部分中完成。这就是 Gercia 当前致力于增量突变测试（incremental mutation testing）的原因：这种技术会渐进地应用突变测试，仅仅关注自上一次分析以来代码库中改变的部分。虽然这种更快，也还是要花费很长时间。

  因此，Gercia 正在跟随 Google 的[一篇论文][mutant google]的指引、提升 Bitcoin Core 的增量突变测试的效率。论他的方法基于以下原理：

  - 避免坏的突变，比如那些语法上不同于源程序、但语义上相同的突变。这意味着不管输入是什么样的，它们的动作都是一样的。
  - 收集来自开发者的反馈来精炼突变的生成，以理解在哪些地方突变测试提供的结果用处不大。
  - 仅报告有限数量的存活图标（根据 Google 的研究，是 7 个），以避免让可能是低信息量的突变压倒开发者。

  Garcia 在 8 个不同的 PR 上测试了他的方法，正在收集反馈和解决突变的建议变更。

  最后，Garcia 请求 Bitcoin Core 的贡献者们在希望运行突变测试的 PR 中通知他，并在知晓突变之后报告反馈。

- **<!--bip-process-updated-->** **BIP 流程更新**：在超过[两个月][bip3 motion to activate]的邮件组[讨论][bip3 follow-up to motion]以及另一轮[修订][bips #2051]之后，显然在本周，BIP3 已经实现了粗略共识。BIP3 在本周三部署之后，就将替代 BIP2，成为 BIP 流程的指引。虽然 BIP 流程的大部分并未改变，BIP3 也引入了多项简化和提升。

  除了其它变更，评论系统也被抛弃了；BIP 的状态从 9 种（草稿、拟议、激活、敲定、拒绝、延期、撤回、替代和过时）缩减为 4 种（草稿、完成、部署和关闭）；序言头的格式更新了；“标准跟踪（Standards Track）” 类型被替换成了 “规范（Specification）” 类型；还有一些先前要求 BIP 编辑作出判断的要求被重新分配给了 BIP 作者或读者。

  [所有变更的概述][bip2to3]可以在 BIP3 中找到。

## 新版本和候选版本

*热门比特币基础项目的新版本和候选版本。请考虑升级到新版本，或帮助测试候选版本。*

- [Bitcoin Core 30.2][] 是一个维护版本，修复了一个在迁移一个未命名传统格式钱包时可能意外删除整个 `wallets` 目录的 bug（详见周报 [#387][news387 wallet]）。还包含少量其它提升和修复，详见其[发行公告][release notes]。
- [BTCPay Server 2.3.3][] 是这种自主托管的支付解决方案的一个次要发行版，通过 `Greenfield` API 引入了冷钱包交易支持（详见下文），移除了基于 CoinGecko 交易所的汇率信息，还修复了多项 bug 。

## 重要的代码和说明书变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Bitcoin Core #33819][] 在 `Mining` 接口（详见[周报 #310][news310 mining]）中加入了一种新的 `getCoinbaseTX()` 方法，它会返回一个结构体，其中包含了客户端构造一笔 coinbase 交易所需的所有字段。现有的 `getCoinbaseTx()` 会返回一笔序列化之后的模型交易，客户端必须自己解析和操作，已经被重命名为 `getCoinbaseRawTx()`，并且跟 `getCoinbaseCommitment()` 和 `getWitnessCommitmentIndex()` 一起被弃用。
- [Bitcoin Core #29415][] 加入了一种新的 `privatebroadcast` 布尔选项，可以在使用 `sendrawtransaction` RPC 时，通过短期的 [Tor][topic anonymity networks] 或 I2P 连接广播交易，或通过 Tor 代理转发给 IPv4/IPv6 对等节点。这种方法通过隐藏 IP 地址并为每一笔交易使用单独的连接来防止可关联性，保护了交易发起人的隐私。
- [Core Lightning #8830][] 向 `hsmtool` 用法（详见 [周报 #73][news73 hsmtool]）添加了一个 `getsecret` 命令，以取代现有的 `getsecretcodex` 命令，并额外支持复原在 v25.12 引入变更（详见 [周报 #383][news383 bip39]）之后创建的节点。这种新的命令，会为新节点的一个给定的 `hsm_secret` 文件输出 [BIP39][] 助记种子词，同时保留为传统节点输出 `Codex32` 字符串的功能。`recover` 插件更新为接受助记词。
- [Eclair #3233][] 开始在 ###37### 和 testnet 4 上使用配置好的默认费率，当 Bitcoin Core 因为区块数据不足而无法估计手续费率时。默认的费率会更新，以更好地匹配当前的价格。
- [Eclair #3237][] 重新开发了通道生命周期事件，以跟 “通道拼接（[splicing][topic splicing]）” 兼容并与 “零确认通道（[zero-conf][topic zero-conf channels]）” 保持一致：加入了 `channel-confirmed`，它表明注资交易或拼接交易已经被确认；加入了 `channel-ready`，它表明通道已经准备好支付；移除了 `channel-opened`。
- [LDK #4232][] 添加了对实验性的 `accountable` 信号的支持，以取代 “[HTLC 背书][topic htlc endorsement]”，如 [BLIPs #67][] 和 [BOLTs #1280][] 所提议的。LDK 现在会给自己的支付以及转发中的未设置信号的支付设置零值的 accountable 信号，并复制进入支付的 accountable 数值（如果有的话）到转出支付中。这跟随了 Eclair 和 LND 中的类似变化（详见[周报 #387][news387 accountable]）。
- [LND #10296][] 添加了一个 `inputs` 字段到 `EstimateFee` RPC 命令请求中，从而允许用户为一笔使用具体输入的交易获得[手续费估计][topic fee estimation]，而不是让钱包自动挑选它们。
- [BTCPay Server #7068][] 通过 `Greenfield` API 添加了对冷钱包交易的支持，该 API 允许用户生成未签名的 [PSBTs][topic psbt] 以及通过一个新的端点来广播外部签名的交易。这一特性在自动化环境中提供了更好的安全性，并允许建立满足更高合规要求的装置。
- [BIPs #1982][] 添加了 [BIP433][] 来指定 [Pay-to-Anchor (P2A)][topic ephemeral anchors] 标准输出类型，并让花费这种输出类型的交易变成标准交易。

{% include references.md %}
{% include linkers/issues.md v=2 issues="33819,29415,8830,3233,3237,4232,67,1280,10296,7068,1982,2051" %}
[mutant post]: https://delvingbitcoin.org/t/incremental-mutation-testing-in-the-bitcoin-core/2197
[news320 mutant]:/zh/newsletters/2024/09/13/#mutation-testing-for-bitcoin-core
[mutant google]: https://research.google/pubs/state-of-mutation-testing-at-google/
[Bitcoin Core 30.2]: https://bitcoincore.org/bin/bitcoin-core-30.2/
[release notes]: https://bitcoincore.org/en/releases/30.2/
[BTCPay Server 2.3.3]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.3.3
[news387 wallet]: /zh/newsletters/2026/01/09/#bitcoin-core-34156
[news310 mining]: /zh/newsletters/2024/07/05/#bitcoin-core-30200
[news73 hsmtool]: /en/newsletters/2019/11/20/#c-lightning-3186
[news383 bip39]: /zh/newsletters/2025/12/05/#core-lightning-v25-12
[news387 accountable]: /zh/newsletters/2026/01/09/#eclair-3217
[bip2to3]: https://github.com/bitcoin/bips/blob/master/bip-0003.md#changes-from-bip2
[bip3 motion to activate]: https://gnusha.org/pi/bitcoindev/205b3532-ccc1-4b2f-964f-264fc6e0e70b@murch.one/
[bip3 follow-up to motion]: https://gnusha.org/pi/bitcoindev/1d76a085-deff-4df2-8a82-f8bd984fac27@murch.one/
