---
title: 'Bitcoin Optech Newsletter #196'
permalink: /zh/newsletters/2022/04/20/
name: 2022-04-20-newsletter-zh
slug: 2022-04-20-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周 Newsletter 总结了关于在 Bitcoin 中允许量子安全密钥交换的讨论，并包含我们常规的栏目，介绍服务和客户端软件、发布与候选发布以及热门比特币基础设施软件中值得注意的变更。

## 新闻

- **<!--quantum-safe-key-exchange-->****量子安全密钥交换：** Erik Aronesty 在 Bitcoin-Dev 邮件列表上发起了关于[量子抗性][topic quantum resistance]——即在快速量子计算机（QC）被研发出来的情况下仍保持 Bitcoin 安全——的[讨论帖][aronesty qc]。据预测，快速 QC 能够在不知道原始私钥的情况下生成与比特币公钥对应的签名，使得拥有快速 QC 的人可以花掉属于他人的钱。很少有安全研究人员认为快速 QC 是短期威胁，但任何能在不显著影响 Bitcoin 现有用途的前提下消除这一隐患的方法，或许都值得考虑。

  Aronesty 建议允许用户把款项支付到由量子安全算法保护的公钥——同时或许再用现有风格的 Bitcoin 公钥为这些比特币提供一层保护，这样一来，必须在两种密钥算法中都找到可利用的问题，才可能因密码学密钥失效而盗走比特币。这需要一次软分叉共识变更，并且鉴于量子安全的见证数据比 Bitcoin 当前使用的 ECDSA 和 [schnorr 签名][topic schnorr signatures]见证数据更大，最坏情况下可能减少每个区块中可容纳的有效交易数量。

  Lloyd Fournier 则[建议][fournier qc]开发一种标准化方案，使 taproot 输出能够除了其常规 schnorr 公钥之外，还承诺量子安全公钥。量子安全公钥目前可能无法被花费，但如果 Bitcoin 用户开始更加担心即将到来的快速 QC，他们可以选择通过软分叉添加一项要求使用量子安全支出路径的共识变更。Fournier 还建议将问题和可能的解决方案[记录][qc issue]在 [BitcoinProblems.org][] 上，供当前和未来的研究人员及开发者参考。

## 服务和客户端软件的变更

*在本月栏目中，我们重点介绍 Bitcoin 钱包与服务的一些有趣更新。*

- **<!--bitcoin-com-adds-segwit-sends-->****Bitcoin.com 新增 segwit 发送：** 在 Bitcoin.com 钱包的一次[近期更新][bitcoin.com segwit]中，现已支持向原生 segwit（[bech32][topic bech32]）地址发送比特币。

- **<!--kraken-adds-lightning-support-->****Kraken 新增 Lightning 支持：** Kraken 使用 LND，已经[支持][kraken lightning]通过闪电网络进行最高 0.1 BTC 的充值和提现。

- **<!--cash-app-adds-lightning-receive-support-->****Cash App 新增 Lightning 收款支持：** 在此前新增[闪电网络发送功能][news183 cash app ln send]之后，Cash App 现已上线让用户通过闪电网络收款的能力。Cash App 的 LN 功能基于 [Lightning Development Kit (LDK)][ldk website]。

- **<!--bitpay-adds-lightning-receive-support-->****BitPay 新增 Lightning 收款支持：** 支付处理商 BitPay [宣布][bitpay lightning]其商户可接受 LN 支付。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [LND 0.14.3-beta][LND 0.14.3-beta] 是该热门 LN 节点软件的一个版本，包含若干缺陷修复。

- [Bitcoin Core 23.0 RC5][Bitcoin Core 23.0 RC5] 是这一主流全节点软件下一主要版本的候选发布。[发布说明草案][bcc23 rn]列出了多项改进，鼓励高级用户和系统管理员在最终发布前进行[测试][test guide]。

- [Core Lightning 0.11.0rc3][Core Lightning 0.11.0rc3] 是该热门 LN 节点软件下一主要版本的候选发布。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]中的值得注意的变更。*

- [LND #5810][LND #5810] 实现了对支付元数据的发送支持。如果发票中包含支付元数据，发送方会把该数据编码成一条 TLV 记录发给接收方。这是朝着解锁[无状态发票][topic stateless invoices]迈出的又一步：有了无状态发票，接收方无需存储曾展示给潜在发送方的发票，等支付尝试到达时再重新生成即可。

- [LND #6212][LND #6212] 若接受某个 HTLC 可能导致通道必须在链上立即关闭或在很短时间内关闭，就会阻止该 HTLC 经 HTLC 拦截器发送给外部进程。当 HTLC 的过期时间接近最近看到的区块时，就可能出现这种情况。

- [LND #6024][LND #6024] 新增 `time_pref` 寻路参数，可用于调整以下两种通道之间的取舍：一种被认为更可能转发支付（更快），另一种收取的手续费更低。

- [LND #6385][LND #6385] 移除了在构造新支付时使用最初 LN 协议洋葱支付格式的选项，现在要求用户创建 TLV 风格的洋葱格式。TLV 洋葱格式于 2019 年加入协议（参见 [Newsletter #55][news55 tlv]），并在所有 LN 软件中作为默认格式已有两年多。其他 LN 软件也在做类似的变更以弃用旧的洋葱格式支持，例如 [Newsletter #158][news158 cl4646] 中报道的 Core Lightning 更新。


{% include references.md %}
{% include linkers/issues.md v=2 issues="5810,6212,6024,6385" %}
[bitcoin core 23.0 rc5]: https://bitcoincore.org/bin/bitcoin-core-23.0/
[bcc23 rn]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/23.0-Release-Notes-draft
[test guide]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/23.0-Release-Candidate-Testing-Guide
[lnd 0.14.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.14.3-beta
[core lightning 0.11.0rc3]: https://github.com/ElementsProject/lightning/releases/tag/v0.11.0rc3
[aronesty qc]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020209.html
[fournier qc]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020214.html
[qc issue]: https://github.com/bitcoin-problems/bitcoin-problems.github.io/issues/4
[bitcoinproblems.org]: https://bitcoinproblems.org/
[news55 tlv]: /zh/newsletters/2019/07/17/#bolts-607
[news158 cl4646]: /zh/newsletters/2021/07/21/#c-lightning-4646
[bitcoin.com segwit]: https://support.bitcoin.com/en/articles/3919131-can-i-send-to-a-bc1-address
[kraken lightning]: https://blog.kraken.com/post/13502/kraken-now-supports-instant-lightning-network-btc-transactions/
[news183 cash app ln send]: /zh/newsletters/2022/01/19/#cash-app-adds-lightning-support
[ldk website]: https://lightningdevkit.org/
[bitpay lightning]: https://bitpay.com/blog/bitpay-supports-lightning-network-payments/
