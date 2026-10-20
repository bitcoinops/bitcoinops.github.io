---
title: 'Bitcoin Optech Newsletter #185'
permalink: /zh/newsletters/2022/02/02/
name: 2022-02-02-newsletter-zh
slug: 2022-02-02-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周 Newsletter 介绍了一份分析，讨论提议中的 `OP_CHECKTEMPLATEVERIFY`（CTV）操作码对谨慎日志合约（DLC）的影响；并总结了关于改用其他方式修改 tapscript 来启用 CTV 与 `SIGHASH_ANYPREVOUT` 的讨论。此外，还照例包含新版本发布公告，以及流行比特币基础设施软件的值得注意的变更。

## 新闻

- **<!--improving-dlc-efficiency-by-changing-script-->****通过修改脚本提高 DLC 效率：**
  Lloyd Fournier 在 DLC-Dev 和 Bitcoin-Dev 邮件列表[发帖][fournier ctv dlc]，说明提议中的 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]（CTV）操作码如何能够大幅减少创建某些 DLC 所需的签名数量，并减少其他一些操作的数量。

  简而言之，对于合约的每一种可能终态——例如 Alice 获得 1 BTC、Bob 获得 2 BTC——现有的 DLC 需要为该状态创建一个独立的[签名适配器][topic adaptor signatures]。许多合约会定义大量可能的终态，例如关于未来比特币价格的合约，将价格四舍五入到最接近的美元，并且即便是相对短期的合约也需要覆盖数千美元的价格范围。这就要求参与方创建、交换并存储数千个部分签名。

  Fournier 建议，使用 CTV 在一个 [tapleaf][topic tapscript] 中生成这成千上万种可能状态，该 tapleaf 承诺了要放到链上的输出。CTV 用哈希来承诺输出，因此各方可以快速、按需地自行计算所有可能状态的哈希，从而将计算量、数据交换和数据存储降到最低。虽然仍会用到一些签名，但数量已大大减少。对于使用多个预言机（例如汇率合约的多个价格数据源）的合约而言，还可以进一步简化，所需的数据量也更少。

  Jonas Nick [指出][nick apo dlc]，使用提议中的 [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] 签名哈希模式也可以实现类似的优化（我们补充，接下来新闻条目中介绍的替代方案同样可行）。

- **<!--composable-alternatives-to-ctv-and-apo-->****可组合的 CTV 和 APO 替代方案：**
  Russell O'Connor 在 Bitcoin-Dev 邮件列表[发帖][oconnor txhash]，提出通过软分叉为比特币 [Tapscript][topic tapscript] 语言新增两个操作码的想法。tapscript 可以使用新的 `OP_TXHASH` 操作码指定应将一笔花费交易的哪些部分序列化并哈希，然后把哈希摘要压入求值栈，供后续操作码使用。新的 [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack]（CSFS）操作码（此前已有提议）允许 tapscript 指定一个公钥，并要求对栈上的特定数据——例如 `OP_TXHASH` 计算出的交易摘要——提供对应的签名。

  O'Connor 解释了这两个操作码如何能够模拟早先的两项软分叉提案，[SIGHASH_ANYPREVOUT][topic sighash_anyprevout]（APO，见 [BIP118][]）和 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]（CTV，见 [BIP119][]）。在某些场景下，这种模拟可能不如直接使用 CTV 或 APO 高效，但 `OP_TXHASH` 与 `OP_CSFS` 可以保持 Tapscript 语言的简洁，并为未来脚本编写者提供更大的灵活性，尤其是在与诸如 [OP_CAT][] 等其他简单 tapscript 扩展结合使用时。

  在一则[回复][towns pop_sigdata]中，Anthony Towns 提出了使用其他替代操作码的类似思路。

  截至撰写本文时，相关讨论仍在积极进行中。我们预计将在后续 Newsletter 中再次关注该主题。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [BTCPay Server 1.4.2][] 是新的 1.4.x 系列中的最新发布版本，改进了登录认证并包含若干[用户界面改进][btcpay ui blog]。

- [BDK 0.16.0][] 发布，带来若干错误修复和小幅改进。

- [Eclair 0.7.0][] 是一个新的主要版本，新增对[锚定输出][topic anchor outputs]、中继[洋葱消息][topic onion messages]，以及在生产环境中使用 PostgreSQL 数据库的支持。

- [LND 0.14.2-beta.rc1][lnd 0.14.2-beta] 是维护版本的候选发布，包含若干错误修复和少量改进。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]中的值得注意的变更。*

- [Bitcoin Core #23201][] 通过允许钱包用户指定最大权重而非求解数据，改进了使用外部输入为交易提供资金的能力（此前见 [Newsletter #170][news170 external inputs]）。这使得应用能够使用 `fundrawtransaction`、`send` 和 `walletfundpsbt` RPC 对包含非标准输出（如 [HTLCs][topic htlc]）的交易进行手续费追加，而这也是 [Newsletter #184][news184 eclair auto bump] 中描述的 LN 客户端的一项需求。

- [Eclair #2141][] 改进了自动手续费追加机制（此前见 [Newsletter #184][news184 eclair auto bump]）：当钱包中的 UTXO 所剩不多时，它会选择更激进的确认目标。在这种情况下，让手续费追加交易尽快确认至关重要，以便在出现更多强制关闭时保住钱包的 UTXO 数量。关于 Eclair 所用的锚定输出式手续费追加的更多细节见[此处][topic anchor outputs]。

- [BTCPay Server #3341][] 允许用户在通过 LN 请求退款时配置 [BOLT11][] 到期时间，不再固定为之前的 30 天默认值。

{% include references.md %}
{% include linkers/issues.md issues="23201,2141,3341" %}
[btcpay server 1.4.2]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.4.2
[bdk 0.16.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.16.0
[eclair 0.7.0]: https://github.com/ACINQ/eclair/releases/tag/v0.7.0
[lnd 0.14.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.14.2-beta.rc1
[btcpay ui blog]: https://blog.btcpayserver.org/btcpay-server-1-4-0/
[fournier ctv dlc]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019808.html
[nick apo dlc]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019812.html
[oconnor txhash]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019813.html
[towns pop_sigdata]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019819.html
[news184 eclair auto bump]: /zh/newsletters/2022/01/26/#eclair-2113
[news170 external inputs]: /zh/newsletters/2021/10/13/#bitcoin-core-17211
