---
title: 'Bitcoin Optech Newsletter #179'
permalink: /zh/newsletters/2021/12/15/
name: 2021-12-15-newsletter-zh
slug: 2021-12-15-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周 Newsletter 描述了一项允许在某些情况下中继零值输出交易的提案，并总结了关于为闪电网络采用 PTLC 做准备的讨论。此外还包含我们的常规栏目：服务和客户端软件的更改、Bitcoin Stack Exchange 的热门问答，以及主流比特币基础设施软件的值得注意的变更。

## 新闻

- ​**<!--adding-a-special-exception-for-certain-uneconomical-outputs-->****为特定不经济输出添加例外规则：​** 自我们在 [Newsletter #162][news162 unec] 描述以来，Jeremy Rubin 在 Bitcoin-Dev 邮件列表[重新发起讨论][rubin unec]，提议允许创建低于[粉尘限制][topic uneconomical outputs]的交易输出。粉尘限制是中继节点用于阻止用户创建经济上不合理 UTXO 的交易中继策略。UTXO 需要至少由部分全节点存储至花费前，某些情况下还需快速检索能力，因此允许*不经济输出*可能无端引发问题。

  然而，零值输出在 [CPFP（Child-Pays-For-Parent）][topic cpfp] 手续费追加场景中有潜在用途——当被追加交易的所有资金均无法花费时（如 [eltoo][topic eltoo] 协议），所有手续费资金需来自独立 UTXO。Ruben Somsen 也[举例][somsen unec]说明零值输出对空间链（一种单向锚定侧链）的实用性。

  截至本文撰写时，讨论尚未形成明确结论。

- ​**<!--preparing-ln-for-ptlcs-->****为闪电网络采用 PTLC 做准备：​** Bastien Teinturier 在 Lightning-Dev 邮件列表发起[讨论][teinturier post]，提议对闪电网络通信协议进行[最小化修改][ln docs 16]以支持节点升级使用 [PTLC][topic ptlc]。PTLC 相较当前使用的 [HTLC][topic htlc] 具备更强隐私性且占用更少区块空间。

  Teinturier 试图使这些修改与拟议的 `option_simplified_update` [协议变更][bolts #867]（参见 [Newsletter #120][news120 opt_simp_update]）同步实施。次要目标是使通信协议兼容 [Newsletter #152][news152 ff] 描述的基于快进机制的 PTLC 协议，这将支持节点分阶段升级：先采用带 HTLC 的 `option_simplified_update`，再升级至 PTLC，最后实现快进功能。

## 服务和客户端软件的更改

*本月我们重点介绍比特币钱包和服务的趣味更新。*

- ​**<!--simple-bitcoin-wallet-adds-taproot-sends-->****Simple Bitcoin Wallet 新增 Taproot 发送功能：​**
  SBW [2.4.22 版本][sbw 2.4.22] 支持发送至 Taproot 地址。

- ​**<!--trezor-suite-supports-taproot-->****Trezor Suite 支持 Taproot：​**
  [Trezor 公告][trezor taproot blog]称 21.12.2 版本已支持 [Taproot][topic taproot]。用户升级客户端和固件后可创建新的 Taproot 账户。

- ​**<!--bluewallet-adds-taproot-sends-->****BlueWallet 新增 Taproot 发送功能：​**
  BlueWallet [v6.2.14][bluewallet 6.2.14] 新增对 Taproot 地址的发送支持。

- ​**<!--cash-app-adds-taproot-sends-->****Cash App 新增 Taproot 发送功能：​**
  自 [2021 年 12 月 1 日][cash app bech32m]起，用户可发送至 [bech32m][topic bech32] 地址。

- ​**<!--swan-adds-taproot-sends-->****Swan 新增 Taproot 发送功能：​**
  Swan [公告][swan taproot tweet]支持 Taproot 提现（发送）。

- ​**<!--wallet-of-satoshi-adds-taproot-sends-->****Wallet of Satoshi 新增 Taproot 发送功能：​**
  移动端比特币与闪电钱包 [Wallet of Satoshi][wallet of satoshi website] [宣布][wallet of satoshi tweet]支持 Taproot 发送。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题解答的首选地——也是我们为好奇或困惑用户提供帮助的去处。本月我们精选自上次更新后的高票问答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- ​**<!--what-is-the-script-assembly-and-execution-in-p2tr-spend-spend-from-taproot-->**[P2TR 花费（从 Taproot 花费）中的脚本汇编和执行是怎样的？]({{bse}}111098)
  Pieter Wuille 详细解析了一个简化的 [BIP341][] 示例，涵盖构建 Taproot 输出、密钥路径花费、脚本路径花费及验证流程。

- ​**<!--how-can-i-find-samples-for-p2tr-transactions-on-mainnet-->**[如何在主网查找 P2TR 交易样本？]({{bse}}110995)
  Murch 提供[区块浏览器][topic block explorers]链接，包括：首笔 P2TR 交易、首个包含脚本路径和密钥路径输入的交易、首笔含多密钥路径输入的交易、首个 2-of-2 多签脚本路径花费，以及新 [Tapscript][topic tapscript] 操作码 `OP_CHECKSIGADD` 的首次使用。

- ​**<!--does-a-miner-adding-transactions-to-a-block-while-mining-reset-the-block-s-pow-->**[矿工在挖矿时添加交易会重置区块的工作量证明吗？]({{bse}}110903)
  Pieter Wuille 解释挖矿具有[无进展性][oconnor blog]，每次哈希尝试都是独立的，即便当前挖矿区块中添加了新交易。

- ​**<!--can-schnorr-aggregate-signatures-be-nested-inside-other-schnorr-aggregate-signatures-->**[Schnorr 聚合签名可以嵌套在其他 Schnorr 聚合签名中吗？]({{bse}}110862)
  Pieter Wuille 探讨了使用 [Schnorr 签名][topic schnorr signatures]实现密钥分层聚合的可行性，指出 [MuSig2][topic musig] 设计兼容嵌套使用，但需注意尚无安全性证明。

## 值得注意的代码和文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo] 和 [闪电网络规范（BOLTs）][bolts repo] 的值得注意变更。*

- [Bitcoin Core #23716][] 在测试代码中新增原生 Python 实现的 RIPEMD-160，不再依赖 OpenSSL 实现。新版 OpenSSL 默认不再提供 RIPEMD-160 支持。

- [Bitcoin Core #20295][] 新增 `getblockfrompeer` RPC，支持手动从指定节点请求特定区块，用于分叉监控和研究。

- [Bitcoin Core #14707][] 更新多个 RPC 以包含矿工 coinbase 输出，新增 `include_immature_coinbase` 选项控制是否包含未成熟（未达 100 确认）的 coinbase 交易。

- [Bitcoin Core #23486][] 优化 `decodescript` RPC，仅在脚本适用时返回 P2SH/P2WSH 地址。

- [BOLTs #940][] 弃用 `node_announcement` 中 Tor v2 地址的声明与解析。[Rust-Lightning #1204][] 同步实现此变更。

- [BOLTs #918][] 移除 `ping` 消息的速率限制，支持更频繁的心跳检测以提升服务质量。

- [BOLTs #906][] 新增 `channel_type` 功能位（参见[第 165 期周报][news165 channel_type]），便于未来节点筛选支持此特性的对等节点。

## 假期发布安排

节日快乐！本期是本年度的最后一期常规周报。下周我们将发布年度特刊，并于 1 月 5 日恢复常规发布。

{% include references.md %}
{% include linkers/issues.md issues="867,23716,20295,14707,23486,940,906,1204,918" %}
[news162 unec]: /zh/newsletters/2021/08/18/#dust-limit-discussion
[rubin unec]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-December/019635.html
[somsen unec]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-December/019637.html
[teinturier post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-December/003377.html
[ln docs 16]: https://github.com/t-bast/lightning-docs/pull/16
[news120 opt_simp_update]: /zh/newsletters/2020/10/21/#simplified-htlc-negotiation
[news152 ff]: /zh/newsletters/2021/06/09/#receiving-ln-payments-with-a-mostly-offline-private-key
[news165 channel_type]: /zh/newsletters/2021/09/08/#bolts-880
[sbw 2.4.22]: https://github.com/btcontract/wallet/releases/tag/2.4.22
[bluewallet 6.2.14]: https://github.com/BlueWallet/BlueWallet/releases/tag/v6.2.14
[cash app bech32m]: https://cash.app/help/us/en-us/20211114-bitcoin-taproot-upgrade
[trezor taproot blog]: https://blog.trezor.io/trezor-suite-and-firmware-updates-december-2021-d1e74c3ea283
[swan taproot tweet]: https://twitter.com/SwanBitcoin/status/1468318386916663298
[wallet of satoshi website]: https://www.walletofsatoshi.com/
[wallet of satoshi tweet]: https://twitter.com/walletofsatoshi/status/1459782761472872451
[oconnor blog]: http://r6.ca/blog/20180225T160548Z.html
