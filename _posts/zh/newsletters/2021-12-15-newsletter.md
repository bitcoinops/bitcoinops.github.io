---
title: 'Bitcoin Optech Newsletter #179'
permalink: /zh/newsletters/2021/12/15/
name: 2021-12-15-newsletter-zh
slug: 2021-12-15-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周 Newsletter 描述了一项提案：允许在某些情况下中继带零值输出的交易；并总结了关于为 LN 采用 PTLC 做准备的讨论。此外还包含我们的常规栏目：服务和客户端软件的变更、Bitcoin Stack Exchange 的热门问答，以及主流比特币基础设施软件的值得注意的变更。

## 新闻

- **<!--adding-a-special-exception-for-certain-uneconomical-outputs-->****为特定不经济输出添加例外规则：** 自我们在 [Newsletter #162][news162 unec] 描述以来，Jeremy Rubin 在 Bitcoin-Dev 邮件列表[重新发起讨论][rubin unec]，提议允许交易创建价值低于[粉尘限制][topic uneconomical outputs]的输出。粉尘限制是一项交易中继策略，节点用它来劝阻用户创建那些花起来在经济上不划算的 UTXO。UTXO 在被花费之前至少需要由部分全节点存储，有时还需要能被快速检索到，因此允许*不经济输出*存在，可能会平白无故地制造问题。

  不过，零值输出在[子为父付（CPFP）][topic cpfp]手续费追加中可能确有用处：此时被追加手续费的那笔交易，其资金没有任何一部分可以被花费，用于追加手续费的资金必须全部来自其他 UTXO，例如在 [eltoo][topic eltoo] 中就是如此。Ruben Somsen 也[举例][somsen unec]说明了零值输出对空间链（一种单向锚定侧链）的用处。

  截至本文撰写时，讨论尚未形成明确结论。

- **<!--preparing-ln-for-ptlcs-->****为 LN 采用 PTLC 做准备：** Bastien Teinturier 在 Lightning-Dev 邮件列表发起[讨论][teinturier post]，提议对 LN 通信协议做[最小的必要改动][ln docs 16]，使节点可以开始升级到使用 [PTLC][topic ptlc]。PTLC 比目前使用的 [HTLC][topic htlc] 更具隐私性，占用的区块空间也更少。

  Teinturier 试图整理出一组改动，使其可以与拟议的 `option_simplified_update` [协议变更][bolts #867]（见 [Newsletter #120][news120 opt_simp_update]）同时实施。次要目标是让通信协议兼容 [Newsletter #152][news152 ff] 中描述的基于快进（fast forwards）的 PTLC 协议。这样，节点就可以分阶段升级：先升级到使用 HTLC 的 `option_simplified_update`，再升级到 PTLC，最后升级到快进。

## 服务和客户端软件的变更

*在本月栏目中，我们重点介绍 Bitcoin 钱包与服务的一些有趣更新。*

- **<!--simple-bitcoin-wallet-adds-taproot-sends-->****Simple Bitcoin Wallet 新增 Taproot 发送功能：**
  SBW [2.4.22 版本][sbw 2.4.22] 支持发送至 Taproot 地址。

- **<!--trezor-suite-supports-taproot-->****Trezor Suite 支持 Taproot：**
  [Trezor 公告][trezor taproot blog]称 Trezor Suite 的 21.12.2 版本已支持 [taproot][topic taproot]。用户下载最新的客户端和固件后，可以创建一个新的 taproot 账户。

- **<!--bluewallet-adds-taproot-sends-->****BlueWallet 新增 Taproot 发送功能：**
  BlueWallet [v6.2.14][bluewallet 6.2.14] 新增对 Taproot 地址的发送支持。

- **<!--cash-app-adds-taproot-sends-->****Cash App 新增 Taproot 发送功能：**
  自 [2021 年 12 月 1 日][cash app bech32m]起，Cash App 用户可以发送到 [bech32m][topic bech32] 地址。

- **<!--swan-adds-taproot-sends-->****Swan 新增 Taproot 发送功能：**
  Swan [公告][swan taproot tweet]支持 Taproot 提现（发送）。

- **<!--wallet-of-satoshi-adds-taproot-sends-->****Wallet of Satoshi 新增 Taproot 发送功能：**
  移动端比特币与闪电钱包 [Wallet of Satoshi][wallet of satoshi website] [宣布][wallet of satoshi tweet]支持 Taproot 发送。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们有点空闲时帮助好奇或困惑用户的地方。在本月栏目中，我们精选自上次更新以来得票最高的一些问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--what-is-the-script-assembly-and-execution-in-p2tr-spend-spend-from-taproot-->**[P2TR 花费（从 Taproot 花费）中的脚本汇编和执行是怎样的？]({{bse}}111098)
  Pieter Wuille 详细解析了一个简化的 [BIP341][] 示例，涵盖构建 Taproot 输出、密钥路径花费、脚本路径花费及验证流程。

- **<!--how-can-i-find-samples-for-p2tr-transactions-on-mainnet-->**[如何在主网查找 P2TR 交易样本？]({{bse}}110995)
  Murch 提供[区块浏览器][topic block explorers]链接，包括：首笔 P2TR 交易、首个包含脚本路径和密钥路径输入的交易、首笔含多密钥路径输入的交易、首个 2-of-2 多重签名脚本路径花费，以及新 [Tapscript][topic tapscript] 操作码 `OP_CHECKSIGADD` 的首次使用。

- **<!--does-a-miner-adding-transactions-to-a-block-while-mining-reset-the-block-s-pow-->**[矿工在挖矿时添加交易会重置区块的工作量证明吗？]({{bse}}110903)
  Pieter Wuille 解释挖矿是[无进展的][oconnor blog]：每一次为求解区块而进行的哈希尝试，都与此前已经完成的工作无关，即使有人在这段时间向正在挖的区块里加入了新交易也是如此。

- **<!--can-schnorr-aggregate-signatures-be-nested-inside-other-schnorr-aggregate-signatures-->**[Schnorr 聚合签名可以嵌套在其他 Schnorr 聚合签名中吗？]({{bse}}110862)
  Pieter Wuille 描述了用 [schnorr 签名][topic schnorr signatures] 做密钥聚合的可行性：在这种方案中，“密钥可以分层聚合，而签名者无需了解自己‘侄辈’密钥的信息”。他指出 [MuSig2][topic musig] 在设计上就兼容嵌套，也可以针对这一用例加以修改，不过目前还没有安全性证明。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo] 和 [闪电网络规范（BOLTs）][bolts repo] 的值得注意的变更。*

- [Bitcoin Core #23716][] 在 Bitcoin Core 的测试代码中新增了一个用原生 Python 实现的 RIPEMD-160。这样 Bitcoin Core 就不再使用 Python `hashlib` 库中的 RIPEMD-160 函数——该函数封装的是 OpenSSL 的 RIPEMD-160 实现。较新版本的 OpenSSL 默认不再提供 RIPEMD-160 支持，需要单独启用。

- [Bitcoin Core #20295][] 新增 `getblockfrompeer` RPC，允许手动向指定的对等节点请求某个特定区块。其预期用途是获取陈旧的链尖（stale chaintip），用于分叉监控和研究。

- [Bitcoin Core #14707][] 更新了多个 RPC，使其也计入通过矿工 币基交易输出获得的比特币。这些 RPC 新增了 `include_immature_coinbase` 选项，用于切换是否包含尚未成熟的 币基交易（成熟即达到 100 个确认，按共识规则这是它们最早可以被花费的时候）。

- [Bitcoin Core #23486][] 更新 `decodescript` RPC，只有当某个脚本能够分别用于 P2SH 或 P2WSH 时，才返回该脚本对应的 P2SH 或 P2WSH 地址。

- [BOLTs #940][] 弃用了在 `node_announcements` 中公告和解析 Tor v2 洋葱地址的做法。同样在本周合并的 [Rust-Lightning #1204][] 更新了该实现，使其遵循这一更新后的规范。

- [BOLTs #918][] 移除了 `ping` 消息的速率限制。`ping` 消息主要用于检查与对等节点的连接是否仍然存活。在这次合并之前，`ping` 消息最多每 30 秒发送一次。对许多节点来说，通过 `ping` 更频繁地发送心跳消息有助于保证较高的服务质量。由于其他闪电网络消息都不受速率限制，`ping` 消息这条 30 秒的限制也随之取消。

- [BOLTs #906][] 为 [Newsletter #165][news165 channel_type] 中描述的 `channel_type` 功能新增了一个功能位。增加这个功能位之后，未来的节点就更容易只选择那些理解这项新功能的节点。

## 假期发布安排

节日快乐！本期是我们今年最后一期常规 Newsletter。下周我们将发布年度回顾特刊，并于 1 月 5 日（周三）恢复常规发布。

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
