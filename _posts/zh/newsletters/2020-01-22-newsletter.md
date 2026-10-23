---
title: 'Bitcoin Optech Newsletter #81'
permalink: /zh/newsletters/2020/01/22/
name: 2020-01-22-newsletter-zh
slug: 2020-01-22-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 请求帮助测试 LND 下一个主要版本的预发布版，征集对一种在 Chaumian coinjoin 混币过程中顺带发送支付的方法的评审意见，链接到一份仍在制定中的谨慎日志合约（DLC）协议规范，并照常带来关于热门服务、客户端软件和基础设施项目值得注意的变更的栏目。

## 行动项

- **<!--help-test-lnd-0-9-0-beta-rc3-->****帮助测试 LND 0.9.0-beta-rc3：** LND 下一个主要版本的这一[预发布版][lnd 0.9.0-beta]带来了多项新功能与错误修复。我们鼓励有经验的用户帮助测试软件，以便在正式发布前发现并修复问题。

## 新闻

- **<!--new-coinjoin-mixing-technique-proposed-->****新的 coinjoin 混币技术提案：** Max Hillebrand 在 Bitcoin-Dev 邮件列表上发起了一个关于 *Wormhole* 的[讨论帖][wormhole thread]，该方法是在一次 [Wasabi 设计讨论][wasabi design discussion]中产生的，用于在 Chaumian coinjoin 中顺带发送支付。在匿名集允许的限度内，该协议甚至连付款方都无法得知收款方的比特币地址。开发者 ZmnSCPxj [指出][zmn note]，该技术与 [tumblebit][] 类似，后者提供无需信任的 Chaumian 支付服务。Hillebrand 正在征集对该设计的反馈，希望将来能看到它被实现。

- **<!--protocol-specification-for-discreet-log-contracts-dlcs-->****谨慎日志合约（DLC）的协议规范：** [DLCs][] 是一种合约协议：两方或多方约定，根据由预言机（或多个预言机）确定的某一事件结果来交换资金。事件发生后，预言机会以数字签名形式发布对事件结果的承诺，胜出的一方可以用这个签名领取资金。预言机不需要知道合约的条款（甚至不需要知道存在合约）。该合约的形式可以像 LN 交易的链上部分，也可以在 LN 通道内执行。这使得 DLC 比其他已知的基于预言机的合约方法更隐私、更高效，而且可以说更安全，因为预言机若对虚假结果作出承诺，就会留下明确的欺诈证据。

  本周 Chris Stewart [宣布][stewart dlc]，几位开发者正在制定一份使用 DLC 的规范，目标是做出一种可互操作的设计，供不同软件（包括 LN 实现）之间使用。当前规范见他们的[仓库][dlcspecs]。对 DLC 感兴趣的读者也可以看看[无脚本脚本][scriptless scripts examples]仓库，其中记录了数字签名方案在合约协议中的其他巧妙应用。

## 服务和客户端软件的变更

*在本月栏目中，我们重点介绍 Bitcoin 钱包与服务的一些有趣更新。*

- **<!--river-financial-utilizing-variety-of-bitcoin-tech-->****River Financial 使用多种比特币技术：** 在一个 [Twitter 推文串][river twitter thread]中，River Financial 概述了他们默认使用的[部分签名比特币交易][topic psbt]（PSBT）、[输出脚本描述符][topic descriptors]、LN 和[原生 segwit 地址][topic bech32]。

- **<!--wasabi-notes-rbf-on-incoming-transactions-->****Wasabi 在入账交易中标注 RBF：** Wasabi 的入账交易通知现在会[标注 RBF 信号][wasabi rbf notification]，并说明该交易是否为替代交易。为了增强隐私，Wasabi 还会随机对 2% 的交易[发出 RBF 信号][wasabi rbf signaling]。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络 BOLT][bolts repo] 中值得注意的变更。*

- [Bitcoin Core #17843][] 帮助消除了一处不一致：在启用了[避免地址重用][news52 #13756]的钱包中，`listunspent` 与 `getbalances` 两个 RPC 判断地址是否被重复使用的方式不同。在修复之前，这个问题可能导致 `getbalances` RPC 多报可动用资金。

- [Eclair #1247][] 修复了 [Newsletter #72][news72 sphinx] 中描述的 Sphinx 隐私泄露问题——路由节点可能推断出返回源节点的路径长度的下界。

- [Eclair #1283][] 允许[多路径支付][topic multipath payments]（MPP）经过未公开的通道，这是 eclair-mobile 能够发起 MPP 支付的必要条件。

- [LND #3900][] 允许付款方在支付时附带自定义数据记录。使用 `lncli` 时，用户可以用 `--data` 标志传入记录 ID 和十六进制数据，例如 `65536=c0deba11ad`。目前自定义记录的一个用途是 [WhatSat][] 程序，它通过 LN 路由私信。 <!-- source: "custom record sending" in https://github.com/joostjager/whatsat/commit/7c172ff8a63e56ec52005028b0f0d6b0a88867ec -->

{% include references.md %}
{% include linkers/issues.md issues="17843,1247,1283,3900" %}
[lnd 0.9.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.9.0-beta-rc3
[wormhole thread]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017585.html
[wasabi design discussion]: https://github.com/zkSNACKs/Meta/issues/49
[tumblebit]: https://eprint.iacr.org/2016/575.pdf
[zmn note]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017587.html
[dlcs]: https://adiabat.github.io/dlc.pdf
[stewart dlc]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017563.html
[dlcspecs]: https://github.com/discreetlogcontracts/dlcspecs/
[scriptless scripts examples]: https://github.com/ElementsProject/scriptless-scripts
[whatsat]: https://github.com/joostjager/whatsat
[news72 sphinx]: /zh/newsletters/2019/11/13/#possible-privacy-leak-in-the-ln-onion-format
[river twitter thread]: https://twitter.com/philipglazman/status/1216849483184476165
[wasabi rbf notification]: /en/matrix/
[wasabi rbf signaling]: https://github.com/zkSNACKs/WalletWasabi/pull/2405
[news52 #13756]: /zh/newsletters/2019/06/26/#bitcoin-core-13756
