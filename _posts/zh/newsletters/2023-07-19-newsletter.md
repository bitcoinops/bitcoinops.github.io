---
title: 'Bitcoin Optech Newsletter #260'
permalink: /zh/newsletters/2023/07/19/
name: 2023-07-19-newsletter-zh
slug: 2023-07-19-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报包括我们关于交易池政策周报限定系列的最后一篇文章，以及我们常规的部分，描述了客户端、服务和流行的比特币基础设施软件的重要变化。

## 新闻

_本周在 Bitcoin-Dev 或 Lightning-Dev 邮件列表中没有发现重要的新闻。_

## 等待确认 #10：参与其中

_我们周报限定[系列][policy series]的最后一篇文章，关于交易中继、交易池包含和挖矿交易选择——包括为什么 Bitcoin Core 的政策比共识允许的更为严格，以及钱包如何最有效地使用该政策。_

{% include specials/policy/zh/10-get-involved.md %} {% assign timestamp="2:01" %}

## 服务和客户端软件的变更

*在这个月度栏目中，我们会标出比特币钱包和服务的有趣更新。*

- **<!--wallet-10101-beta-testing-pooling-funds-between-ln-and-dlcs-->10101 钱包 beta 版本测试在 LN 和 DLC 之间汇集资金：**
  10101 宣布了一个使用 LDK 和 BDK 构建的[钱包][10101 github]，允许用户使用 [DLC][topic dlc]在[链下合约][10101 blog2]中非托管地交易衍生品。这个钱包还可以用于发送、接收和转发闪电网络支付。DLC 依赖于使用[适配器签名][topic adaptor signatures]进行价格[认证][10101 blog1]的预言机。{% assign timestamp="14:56" %}

- **LDK 节点公布：**
  LDK 团队[公布][ldk blog]了 LDK 节点[v0.1.0][LDK Node v0.1.0]。LDK 节点是一个闪电网络节点 Rust 库，它使用 LDK 和 BDK 库，让开发人员能够快速设置自托管的闪电节点，同时可为不同的用例提供高度的可定制化。{% assign timestamp="17:14" %}

- **Payjoin SDK 公布：**
  [Payjoin 开发工具包（PDK）][PDK github]已[公布][PDK blog]。它是一个实现 [BIP78][] 的 Rust 库，可用于想要集成 [payjoin][topic payjoin] 功能的钱包和服务中。{% assign timestamp="20:09" %}

- **验证闪电签名者（VLS）beta 版公布：**
  VLS 允许将闪电节点与控制其资金的密钥相分离。使用 VLS 运行的闪电节点将签名请求推送到远程签名设备，而非使用本地密钥。[beta 版本][VLS gitlab]支持 CLN 和 LDK、一层和二层验证规则、备份/恢复功能，并提供了参考实现。[博客文章][VLS blog]的公告还号召社区进行测试、功能请求并提供反馈。{% assign timestamp="25:27" %}

- **BitGo 增加了对 MuSig2 的支持：**
  BitGo [宣布][bitgo blog]支持 [BIP327][]（[MuSig2][topic musig]）。同时他们指出与其他支持的地址类型相比，该类型的费用更低，隐私性更强。{% assign timestamp="37:42" %}

- **Peach 增加了对 RBF 的支持：**
  服务点对点交易的 [Peach Bitcoin][peach website]的移动端应用[宣布][peach tweet]支持[手续费替换（RBF）][topic rbf]。{% assign timestamp="44:34" %}

- **Phoenix 钱包增加了拼接支持：**
  ACINQ [宣布][acinq blog]他们对 Phoenix 移动端闪电钱包的下一个版本进行了测试。该钱包支持单个动态通道，使用[拼接（splicing）][topic splicing]和类似于 [swap-in-potentiam][news233 sip] 技术的机制进行重新平衡（参见[Podcast #259][pod259 phoenix]）。{% assign timestamp="46:34" %}

- **<!--mining-development-kit-call-for-feedback-->挖矿开发工具包征求反馈：**
  挖矿开发工具包（MDK）团队[发布][MDK blog]了他们在比特币挖矿系统硬件、软件和固件研发方面的最新进展情况。这篇文章呼吁社区就使用案例、范围和方法提供反馈。{% assign timestamp="49:27" %}

- **<!--binance-adds-lightning-support-->币安开始支持闪电网络：**
  币安[宣布][binance blog]支持使用闪电网络进行发送（提现）和接收（充值）。{% assign timestamp="51:33" %}

- **Nunchuk 增加 CPFP 支持：**
  Nunchuk[宣布][nunchuk blog]支持[子为父偿（CPFP）][topic cpfp]，为交易的发送方和接收方提供提升手续费的功能。{% assign timestamp="53:35" %}

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo] 和 [Bitcoin Inquisition][bitcoin inquisition repo]。*

- [Bitcoin Core #27411][] 防止节点向位于其他网络（如普通的IPv4或IPv6）上的对等节点公告其 Tor 或 I2P 地址，并且不会将其地址从非[匿名网络][topic anonymity networks]公告给 Tor 和 I2P 上的对等节点。这有助于防止有人将节点的常规网络地址与该节点在匿名网络上的地址关联起来。目前，CJDNS 与 Tor 和 I2P 的处理方式不同，尽管这可能会在将来发生变化。{% assign timestamp="54:57" %}

- [Core Lightning #6347][] 为插件添加用通配符 `*` 来订阅每个事件通知的能力。{% assign timestamp="58:07" %}

- [Core Lightning #6035][] 添加了请求使用 [bech32m][topic bech32] 地址接收存款到一个 [P2TR][topic taproot] 输出脚本的能力。交易的找零现在也将默认发送到一个 P2TR 输出。{% assign timestamp="1:00:47" %}

- [LND #7768][] 实现了 BOLTs [#1032][bolts #1032] 和 [#1063][bolts #1063]（参见[周报 #225][news225 bolts1032]），允许最终接收方（HTLC）接受比他们所请求的金额更多、过期时间更久的付款。以前，基于 LND 的接收方遵守了 [BOLT4][] 的要求，即金额和到期时间差正好等于他们请求的数额，但如此精确意味着转发节点可以稍微更改任一数值来探测下一个跳点是否为最终接收者。{% assign timestamp="1:02:28" %}

- [Libsecp256k1 #1313][]开始使用 GCC 和 Clang 编译器的开发快照进行自动测试。这也许能检查出变更会否导致 libsepc256k1 特定代码的运行时间浮动。运行时长不固定的代码与私钥和 nonce 一起使用可能导致[侧信道攻击][topic side channels]。请参阅[周报＃246][news246 secp]来了解可能发生这种情况的一个例子，以及[周报＃251][news251 secp]来了解另一个例子和计划进行此类测试的一个公告。{% assign timestamp="1:05:33" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="27411,6347,6035,7768,1032,1063,1313" %}
[policy series]: /zh/blog/waiting-for-confirmation/
[news225 bolts1032]: /zh/newsletters/2022/11/09/#bolts-1032
[news246 secp]: /zh/newsletters/2023/04/12/#libsecp256k1-0-3-1
[news251 secp]: /zh/newsletters/2023/05/17/#libsecp256k1-0-3-2
[10101 github]: https://github.com/get10101/10101
[10101 blog1]: https://10101.finance/blog/dlc-to-lightning-part-1/
[10101 blog2]: https://10101.finance/blog/dlc-to-lightning-part-2
[LDK Node v0.1.0]: https://github.com/lightningdevkit/ldk-node/releases/tag/v0.1.0
[LDK blog]: https://lightningdevkit.org/blog/announcing-ldk-node
[PDK github]: https://github.com/payjoin/rust-payjoin
[PDK blog]: https://payjoindevkit.org/blog/pdk-an-sdk-for-payjoin-transactions/
[VLS gitlab]: https://gitlab.com/lightning-signer/validating-lightning-signer/-/releases/v0.9.1
[VLS blog]: https://vls.tech/posts/vls-beta/
[bitgo blog]: https://blog.bitgo.com/save-fees-with-musig2-at-bitgo-3248d690f573
[peach website]: https://peachbitcoin.com/
[peach tweet]: https://twitter.com/peachbitcoin/status/1676955956905902081
[acinq blog]: https://acinq.co/blog/phoenix-splicing-update
[news233 sip]: /zh/newsletters/2023/01/11/#noninteractive-ln-channel-open-commitments
[MDK blog]: https://www.mining.build/update-on-the-mining-development-kit/
[binance blog]: https://www.binance.com/en/support/announcement/binance-completes-integration-of-bitcoin-btc-on-lightning-network-opens-deposits-and-withdrawals-eefbfae2c0ae472d9e1e36f1a30bf340
[nunchuk blog]: https://nunchuk.io/blog/cpfp
[pod259 phoenix]: /en/podcast/2023/07/13/#phoenix
