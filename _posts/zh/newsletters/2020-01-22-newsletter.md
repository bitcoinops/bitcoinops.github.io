---
title: 'Bitcoin Optech Newsletter #81'
permalink: /zh/newsletters/2020/01/22/
name: 2020-01-22-newsletter-zh
slug: 2020-01-22-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 请求帮助测试 LND 下一主要版本的预发布版本，寻求对将支付作为 Chaumian CoinJoin 混合的一部分的方法进行审查，链接到离散日志合约（DLC）协议规范的工作进展，并包含我们定期更新的关于流行服务、客户端软件和基础设施项目的显著变化。

## 行动项

- **<!--help-test-lnd-0-9-0-beta-rc3-->****帮助测试 LND 0.9.0-beta-rc3：** 该[预发布版本][lnd 0.9.0-beta]是 LND 下一主要版本，带来了多个新功能和错误修复。鼓励有经验的用户帮助测试软件，以便在正式发布前识别并修复任何问题。

## 新闻

- **<!--new-coinjoin-mixing-technique-proposed-->****提出新的 CoinJoin 混合技术：** Max Hillebrand 在 Bitcoin-Dev 邮件列表上发起了一个关于 *Wormhole* 的[讨论线程][wormhole thread]，该方法是在 [Wasabi 设计讨论][wasabi design discussion]中开发的，旨在将支付作为 Chaumian CoinJoin 的一部分进行发送。该协议甚至可以防止发送者在匿名集内得知接收者的比特币地址。开发者 ZmnSCPxj [指出][zmn note]该技术与 [tumblebit][] 类似，后者提供了一种无需信任的 Chaumian 支付服务。Hillebrand 正在寻求对该设计的反馈，希望未来能够实现该技术。

- **<!--protocol-specification-for-discreet-log-contracts-dlcs-->****离散日志合约（DLC）协议规范：** [DLCs][] 是一种合同协议，允许两方或多方根据由预言机（或多个预言机）确定的事件结果来交换资金。在事件发生后，预言机会以数字签名的形式发布对事件结果的承诺，胜出方可以使用该签名来领取资金。预言机不需要知道合同的条款（甚至不知道存在合同）。该合同可以类似于链上闪电网络（LN）交易的一部分，或者在 LN 通道内执行。这使得 DLCs 比其他已知的基于预言机的合同方法更加隐私和高效，且安全性更高，因为如果预言机发布虚假结果，将产生明确的欺诈证据。

  本周 Chris Stewart [宣布][stewart dlc]，几位开发者正在致力于制定使用 DLC 的规范，目标是创建一个可互操作的设计，以供不同的软件（包括 LN 实现）使用。请参阅他们的[代码库][dlcspecs]获取当前的规范。对 DLCs 感兴趣的读者也可以查看[无脚本脚本][scriptless scripts examples]代码库，该库记录了数字签名方案在合同协议中的其他巧妙应用。

## 服务和客户端软件的更改

*在此月度栏目中，我们重点介绍比特币钱包和服务的有趣更新。*

- **<!--river-financial-utilizing-variety-of-bitcoin-tech-->****River Financial 使用多种比特币技术：** 在一个 [Twitter 线程][river twitter thread]中，River Financial 概述了他们默认使用的 [PSBT][topic psbt]、[脚本描述符][topic descriptors]、闪电网络（LN）和[原生 Segwit 地址][topic bech32]。

- **<!--wasabi-notes-rbf-on-incoming-transactions-->****Wasabi 在入账交易中标注 RBF：** Wasabi 的入账交易通知现在会[标注 RBF 信号][wasabi rbf notification]以及该交易是否为替代交易。为了增强隐私，Wasabi 还随机地在 2% 的交易中[发送 RBF 信号][wasabi rbf signaling]。

## 值得注意的代码和文档更改

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的显著变化。*

- [Bitcoin Core #17843][] 帮助解决了在使用[避免地址重用][news52 #13756]的钱包中 `listunspent` 和 `getbalances` RPC 如何确定地址重用的差异。在解决之前，该问题可能导致 `getbalances` RPC 过高地报告可用于支出的资金。

- [Eclair #1247][] 修复了 [Newsletter #72][news72 sphinx] 中描述的 Sphinx 隐私泄露问题，路由节点可能推断出到源节点路径的下界。

- [Eclair #1283][] 允许[多路径支付][topic multipath payments]（MPP）穿越未公布的通道，这是 eclair-mobile 能够进行 MPP 支付所必需的功能。

- [LND #3900][] 允许支付者在支付时发送自定义数据记录。使用 `lncli`，用户可以通过 `--data` 标志传递记录 ID 和十六进制数据，例如 `65536=c0deba11ad`。目前自定义记录的一个用途是 [WhatSat][] 程序，该程序通过闪电网络路由私人消息。 <!-- source: "custom record sending" in https://github.com/joostjager/whatsat/commit/7c172ff8a63e56ec52005028b0f0d6b0a88867ec -->

{% include references.md %}
{% include linkers/issues.md issues="17843,1247,1283,3900" %}
[lnd 0.9.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.9.0-beta-rc3
[wormhole thread]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017585.html
[wasabi design discussion]: https://github.com/zkSNACKs/Meta/issues/49
[tumblebit]: https://eprint.iacr.org/2016/575.pdf
[zmn note]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017587.html
[dlcs]: https://adiabat.github.io/dlc.pdf
[stewart dlc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017563.html
[dlcspecs]: https://github.com/discreetlogcontracts/dlcspecs/
[scriptless scripts examples]: https://github.com/ElementsProject/scriptless-scripts
[whatsat]: https://github.com/joostjager/whatsat
[news72 sphinx]: /zh/newsletters/2019/11/13/#possible-privacy-leak-in-the-ln-onion-format
[river twitter thread]: https://twitter.com/philipglazman/status/1216849483184476165
[wasabi rbf notification]: /en/compatibility/wasabi/#receive-notification
[wasabi rbf signaling]: https://github.com/zkSNACKs/WalletWasabi/pull/2405
[news52 #13756]: /zh/newsletters/2019/06/26/#bitcoin-core-13756
