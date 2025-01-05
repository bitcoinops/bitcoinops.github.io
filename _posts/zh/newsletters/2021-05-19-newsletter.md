---
title: 'Bitcoin Optech Newsletter #149'
permalink: /zh/newsletters/2021/05/19/
name: 2021-05-19-newsletter-zh
slug: 2021-05-19-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 提供了先前提出的交易中继可靠性研讨会和 CVE-2021-31876 的更新。此外，还包括我们的常规栏目，描述了服务和客户端软件的更新、新的发布和候选发布，以及对流行的比特币基础设施软件值得注意的更改。

## 新闻

- **<!--relay-reliability-workshop-scheduled-->****中继可靠性研讨会安排：**
  如 [Newsletter #146][news146 workshop] 中提到的，Antoine Riard 将主持基于 IRC 的会议，讨论如何使未确认的交易中继对合约协议（如闪电网络（LN）、coinswaps 和 DLCs）更加可靠。会议时间表如下：

  - 6 月 15 日，19:00--20:30 UTC：关于 L2 协议链上安全设计的指导方针；跨层安全披露的协调；完整 RBF（Replace By Fee）提案

  - 6 月 22 日（同一时间）：通用的二层手续费提升原语（例如包中继）

  - 6 月 29 日（同一时间）：预留用于额外讨论

- **<!--cve-2021-31876-bip125-implementation-discrepancy-follow-up-->****CVE-2021-31876 BIP125 实现差异的后续跟进：**
  在 [上周的 Newsletter][news148 cve] 发布后，关于 [BIP125][] 可选 Replace-by-Fee（RBF（Replace By Fee）[topic rbf]）与 Bitcoin Core 实现之间差异的讨论进一步展开。Olaoluwa Osuntokun [确认][btcd #1719] `btcd` 全节点按规范实现了 BIP125，这意味着它确实允许基于继承信号的子交易被替换。Ruben Somsen [指出][somsen note]，空间链（spacechains）的一种假设变体，这是一种单向锚定的[侧链][topic sidechains]，将会受到该问题的影响。另一方面，Antoine “Darosior” Poinsot [提到][poinsot mention] Revault [保险库][topic vaults]架构不会受到影响。

## 服务和客户端软件的更改

*在本月的专题中，我们重点介绍了比特币钱包和服务的有趣更新。*

- **<!--blockchain-com-supports-segwit-->****Blockchain.com 支持 SegWit：** Blockchain.com 钱包的 [v4.49.1][blockchain v4.49.1] 版本新增了创建支持原生 SegWit 发送和接收的钱包的功能。

- **<!--sparrow-1-4-0-released-->****Sparrow 1.4.0 发布：** [Sparrow 1.4.0][sparrow 1.4.0] 新增了从交易列表屏幕创建[部分签名的比特币交易（CPFP）][topic cpfp]的功能，用户在选择硬币时可以自定义手续费金额，以及各种其他改进。

- **<!--electrum-4-1-0-enhances-lightning-features-->****Electrum 4.1.0 增强了闪电网络功能：** [Electrum 4.1.0][electrum 4.1.0] 新增了[蹦床支付][topic trampoline payments]、[多路径支付][topic multipath payments]、通道备份和其他闪电网络功能。此外，此版本的 Electrum 支持 [bech32m][topic bech32]。

- **<!--bluewallet-v6-1-0-released-->****BlueWallet v6.1.0 发布：** BlueWallet 的 [v6.1.0 release][bluewallet v6.1.0] 新增了 Tor 支持、[SLIP39][news86 slip39] 支持，以及在 HD 仅观察钱包中使用 [PSBTs][topic psbt] 的功能。

## 发布与候选发布

*针对热门比特币基础设施项目的新发布版本或候选版本。请考虑升级至新版本或协助测试候选版本。*

- [LND 0.13.0-beta.rc2][LND 0.13.0-beta] 是一个候选发布版本，新增了对使用修剪后的比特币全节点的支持，允许使用原子多路径（Atomic MultiPath）（[AMP][topic multipath payments]）接收和发送支付，并增强了其 [PSBT][topic psbt] 功能，以及其他改进和错误修复。

## 值得注意的代码和文档更改

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo] 中值得注意的更改。*

- [Bitcoin Core #21462][Bitcoin Core #21462] 增加了用于证明 Guix 构建输出的工具，并验证这些证明与其他人的证明。此更改之后，Windows 和 macOS 的代码签名将成为 Guix 构建与 Gitian 构建功能等同性之前的唯一缺失部分。

- [Bitcoin Core GUI #280][Bitcoin Core GUI #280] 防止在错误对话框中显示无效的比特币地址，消除了在看似官方的对话框中显示任意消息的可能性。现在仅显示简单的“无效地址”错误。（参见 PR 中的前后对比截图。）

- [Bitcoin Core #21359][Bitcoin Core #21359] 更新了 `fundrawtransaction`、`send` 和 `walletcreatefundedpsbt` RPC，新增了 `include_unsafe` 参数，用于在交易中花费其他用户创建的未确认 UTXO。这允许使用 [CPFP][topic cpfp] 提升交易手续费，是由一位在 Eclair LN 节点中实现[锚定输出][topic anchor outputs]的开发者添加的。此选项应仅在必要时使用，因为其他用户创建的未确认交易可能会被替换，从而可能阻止任何子交易被确认。

- [LND #5291][LND #5291] 改进了 LND 确保 [PSBTs][topic psbt] 用于资助交易仅花费 SegWit UTXO 的方式。闪电网络要求 SegWit UTXO 以防止 txid 可变性导致退款交易无法花费。LND 之前通过检查 PSBT 中的 `WitnessUtxo` 字段来验证，但该字段对于 SegWit UTXO 来说是技术上可选的，因此一些 PSBT 创建者不会提供它。更新后的代码将使用提供的值（如果存在），否则将扫描 UTXO 集以获取必要的信息。

- [LND #5274][LND #5274] 将节点为允许 [CPFP][topic cpfp] 提升[锚定输出][topic anchor outputs]手续费所保留的最大资金量限制为每通道金额的十倍。对于拥有大量通道的节点，这限制了它们的资本需求。如果它们需要关闭超过 10 个通道，可以使用关闭一个通道收到的资金来关闭下一个通道，形成多米诺效应。

- [LND #5256][LND #5256] 允许从文件中读取钱包密码。这主要用于基于容器的设置，其中密码已经存储在文件中，因此直接使用该文件不会带来额外的安全问题。

- [LND #5253][LND #5253] 为高层 LND RPC 命令（如 `SendPayment`、`AddInvoice` 和 `SubscribeInvoice`）新增了对 [Atomic Multipath Payment (AMP)][topic multipath payments] 发票的支持。AMP 发票目前是 LND 独有的功能，仅接受设置了 AMP 功能位以及 AMP 负载的 HTLC。这扩展了之前的工作 [news147 lndamp]，通过为 `SendPayment` RPC 提供手动指定的支付参数来启用 AMP 的使用。

- [Libsecp256k1 #850][Libsecp256k1 #850] 新增了 `secp256k1_ec_pubkey_cmp` 方法，该方法比较两个公钥并返回其中一个是否比另一个更早排序（或返回它们相等）。此方法被提议用于 [BIP67][] 密钥排序，特别是用于 `sortedmulti` [描述符][topic descriptors]的输出脚本描述符。

{% include references.md %}
{% include linkers/issues.md issues="21462,280,21359,5291,5274,5256,5253,850" %}
[LND 0.13.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.13.0-beta.rc2
[news146 workshop]: /zh/newsletters/2021/04/28/#call-for-topics-in-layer-crossing-workshop
[news147 lndamp]: /zh/newsletters/2021/05/05/#lnd-5159
[news148 cve]: /zh/newsletters/2021/05/12/#cve-2021-31876-discrepancy-between-bip125-and-bitcoin-core-implementation
[btcd #1719]: https://github.com/btcsuite/btcd/pull/1719
[somsen note]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-May/018921.html
[poinsot mention]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-May/018906.html
[blockchain v4.49.1]: https://github.com/blockchain/blockchain-wallet-v4-frontend/releases/tag/v4.49.1
[sparrow 1.4.0]: https://github.com/sparrowwallet/sparrow/releases/tag/1.4.0
[bluewallet v6.1.0]: https://github.com/BlueWallet/BlueWallet/releases/tag/v6.1.0
[news86 slip39]: /zh/newsletters/2020/02/26/#what-s-the-relationship-between-slip39-and-bip39
[electrum 4.1.0]: https://github.com/spesmilo/electrum/blob/4.1.0/RELEASE-NOTES
