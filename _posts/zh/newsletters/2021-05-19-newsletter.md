---
title: 'Bitcoin Optech Newsletter #149'
permalink: /zh/newsletters/2021/05/19/
name: 2021-05-19-newsletter-zh
slug: 2021-05-19-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 提供此前提出的交易中继可靠性工作坊和 CVE-2021-31876 的最新进展。此外还包括我们的固定栏目：服务和客户端软件更新、新版本与候选发布，以及热门比特币基础设施软件值得注意的代码与文档变更。

## 新闻

- **<!--relay-reliability-workshop-scheduled-->****中继可靠性工作坊日程：**
  如 [Newsletter #146][news146 workshop] 中所提到的，Antoine Riard 将主持若干基于 IRC 的会议，讨论如何让未确认交易的中继对闪电网络（LN）、币互换（coinswap）、谨慎日志合约（DLC）等合约协议更加可靠。日程如下：

  - 6 月 15 日 19:00--20:30 UTC：关于 L2 协议链上安全设计的准则；跨层安全披露的协调；完全 RBF 提案

  - 6 月 22 日（同一时间）：通用的二层手续费追加原语（例如交易包中继）

  - 6 月 29 日（同一时间）：留作补充讨论

- **<!--cve-2021-31876-bip125-implementation-discrepancy-follow-up-->****CVE-2021-31876 中 BIP125 实现差异的后续：**
  在[上周的 Newsletter][news148 cve] 发布后，围绕 [BIP125][] 选择性手续费替换（[RBF][topic rbf]）与 Bitcoin Core 实现之间差异的讨论还在继续。Olaoluwa Osuntokun [确认][btcd #1719] `btcd` 全节点按规范实现了 BIP125，也就是说它确实允许子交易基于继承来的信号被替换。Ruben Somsen [指出][somsen note]，空间链（spacechains）——一种单向锚定的[侧链][topic sidechains]——的某个假设变体会受该问题影响。另一方面，Antoine “Darosior” Poinsot [提到][poinsot mention]，Revault 的[保险库][topic vaults]架构不会受影响。

## 服务和客户端软件的变更

*在本月栏目中，我们重点介绍 Bitcoin 钱包与服务的一些有趣更新。*

- **<!--blockchain-com-supports-segwit-->****Blockchain.com 支持 segwit：** Blockchain.com 钱包的 [v4.49.1][blockchain v4.49.1] 版本新增了创建支持原生 segwit 收发功能的钱包的能力。

- **<!--sparrow-1-4-0-released-->****Sparrow 1.4.0 发布：** [Sparrow 1.4.0][sparrow 1.4.0] 新增了从交易列表页面创建[子为父付（CPFP）][topic cpfp]交易的功能，在选币过程中可自定义手续费金额，以及各种其他改进。

- **<!--electrum-4-1-0-enhances-lightning-features-->****Electrum 4.1.0 增强闪电网络功能：** [Electrum 4.1.0][electrum 4.1.0] 新增了[蹦床支付][topic trampoline payments]、[多路径支付][topic multipath payments]、通道备份和其他闪电网络功能。此外，该版本还支持 [bech32m][topic bech32]。

- **<!--bluewallet-v6-1-0-released-->****BlueWallet v6.1.0 发布：** BlueWallet 的 [v6.1.0 版本][bluewallet v6.1.0] 新增了 Tor 支持、[SLIP39][news86 slip39] 支持，以及配合 HD 只读钱包使用[部分签名比特币交易（PSBT）][topic psbt]的功能。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [LND 0.13.0-beta.rc2][LND 0.13.0-beta] 是一个候选发布，新增了对使用已修剪的比特币全节点的支持，允许使用原子多路径支付（[AMP][topic multipath payments]）收发支付，并增强了 [PSBT][topic psbt] 相关能力，此外还有其他改进和错误修复。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo] 中值得注意的变更。*

- [Bitcoin Core #21462][Bitcoin Core #21462] 增加了对 Guix 构建产物进行证明（attestation）的工具，并可将这些证明与他人的证明相互验证。在此之后，Windows 和 macOS 的代码签名仍是 Guix 构建在与 Gitian 构建达到功能对等之前的唯一缺口。

- [Bitcoin Core GUI #280][Bitcoin Core GUI #280] 防止在错误对话框中显示无效的比特币地址，消除了在看似官方的对话框中显示任意消息的可能性。现在仅显示简单的“无效地址”错误。（参见 PR 中的前后对比截图。）

- [Bitcoin Core #21359][Bitcoin Core #21359] 为 `fundrawtransaction`、`send` 和 `walletcreatefundedpsbt` RPC 增加了新参数 `include_unsafe`，可用于在交易中花费其他用户创建的未确认 UTXO。这让用户可以用 [CPFP][topic cpfp] 为一笔交易追加手续费；这个功能正是一位在 Eclair 中实现[锚定输出][topic anchor outputs]的开发者为此而添加的。该选项应仅在必要时使用，因为其他用户创建的未确认交易可能被替换，从而导致任何子交易都无法确认。

- [LND #5291][LND #5291] 改进了 LND 确保用于注资交易的 [PSBTs][topic psbt] 只花费 segwit UTXO 的方式。LN 需要 segwit UTXO，以防 txid 可延展性使退款交易无法花费。LND 此前通过查找 PSBT 中的 `WitnessUtxo` 字段来做这项检查，但该字段对 segwit UTXO 而言在技术上属于可选字段，因此有些 PSBT 创建者并不提供它。更新后的代码会在该字段存在时使用它，不存在时则扫描 UTXO 集以获取所需信息。

- [LND #5274][LND #5274] 把节点为对[锚定输出][topic anchor outputs]做 [CPFP][topic cpfp] 手续费追加而预留的资金上限，限制为每通道金额的十倍。对于通道数量很多的节点，这限制了其资金需求。如果需要关闭的通道超过 10 个，它们可以用关闭一个通道收回的资金去关闭下一个通道，形成多米诺效应。

- [LND #5256][LND #5256] 允许从文件中读取钱包密码短语。这主要针对基于容器的部署——密码短语本就存放在文件里，直接使用该文件不会带来额外的安全问题。

- [LND #5253][LND #5253] 为 `SendPayment`、`AddInvoice`、`SubscribeInvoice` 等高层次 LND RPC 命令增加了对[原子多路径支付（AMP）][topic multipath payments]发票的支持。AMP 发票目前是 LND 独有的功能，只接受既设置了 AMP 功能位、又带有 AMP 负载的 HTLC。这扩展了[此前的工作][news147 lndamp]——那项工作通过向 `SendPayment` RPC 手动指定支付参数来启用 AMP。

- [Libsecp256k1 #850][Libsecp256k1 #850] 新增了 `secp256k1_ec_pubkey_cmp` 方法，它比较两个公钥，返回两者中哪一个排序在前（或返回两者相等）。提出这个方法是供 [BIP67][] 的密钥排序使用，尤其是 `sortedmulti` [输出脚本描述符（descriptor）][topic descriptors] 所用的场景。

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
