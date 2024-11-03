---
title: 'Bitcoin Optech Newsletter #234'
permalink: /zh/newsletters/2023/01/18/
name: 2023-01-18-newsletter-zh
slug: 2023-01-18-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报描述了一个新的专用于保险库的操作码提议。此外还有我们的常规部分：其中包括客户端和服务有意思的更新的汇总、软件的新版本和候选版本的总结以及热门的比特币基础设施项目的重大变更介绍。

## 新闻

- **专用于保险库（vault）的操作码提案：** James O'Beirne 在比特币开发邮件列表中[发表][obeirne op_vault]了一个[提案][obeirne paper]：通过软分叉添加两个新操作码：`OP_VAULT` 和 `OP_UNVAULT`。

  * `OP_VAULT` 将接受三个参数，包括对高度信任的支出路径的承诺、[延迟期][topic timelocks]，以及对不太可信的支出路径的承诺。

  * `OP_UNVAULT` 也将接受三个参数。当用于 O'Beirne 设想的保险库时，这三个参数会是：对高度信任的支出路径的相同承诺、相同的延迟期以及对包含在之后交易中的一个或多个输出的承诺。

  为创建一个[保险库][topic vaults]，Alice 选择了一个高度信任的支出路径，例如一个需要她访问多个单独的签名设备或存储在不同位置的冷钱包的多签。她还选择了一条不太可信的支出路径，例如来自她常用热钱包的单签。最后，她选择了使用与 [BIP68][] 相同的数据类型指定的延迟期，这允许指定短至几分钟，长到大约一年的时间。选择参数后，Alice 创建了一个普通的比特币地址，用于将资金接收到她的保险库，该地址承诺到一个使用 `OP_VAULT` 的脚本。

  为了将之前收到的资金支出到她的保险库地址，Alice 将首先确定她最终想要支付的输出（例如，向 Bob 发送付款并将任何找零返回到她的保险库）。在典型的用法中，Alice 会满足她不太信任的支出路径的条件，例如提供来自她的热钱包的签名，以创建一个将所有保管的资金支付到单一输出的交易。该输出包含 `OP_UNVAULT`，其参数与高度信任的支出路径和延迟相同。第三个参数是对 Alice 最终想要支付的输出的承诺。Alice 完成构建交易——包括使用[费用赞助][topic fee sponsorship]、一种[锚点输出][topic anchor outputs]或其他机制的附加费用。

  Alice 广播她的交易，然后它被包含在一个区块中。这使任何人都可以观察到正在进行的解锁尝试。Alice 的软件检测到这是她的保险库资金的支出，并验证确认交易的 `OP_UNVAULT` 输出的第三个参数与 Alice 之前创建的承诺完全匹配。假设它匹配，Alice 现在等待延迟期结束，之后便可以广播一笔从 `OP_UNVAULT` UTXO 花费的交易到她之前承诺的输出（例如 Bob 和找零输出）。Alice 将成功使用她不太可信的路径成功花费的资金，例如仅使用她的热钱包。

  然而，试想一下 Alice 的软件看到了确认的解托管（unvaulting）尝试但没有识别它。在这种情况下，她的软件有机会在延迟期间冻结资金。它创建了一个交易，将 `OP_UNVAULT` 输出花费到高度信任的地址。这属于先前承诺的内容。只要此冻结交易在延迟期结束之前得到确认，Alice 的资金就不会受到她不太信任的支出路径的影响。在资金转移到 Alice 非常信任的支出路径后，Alice 可以随时通过满足该路径的条件（例如使用她的冷钱包）来花费它们。

  除了提出新的操作码之外，O'Beirne 还描述了保险库的动机并分析了其他保险库提案，包括那些现在可以在比特币上使用预签名交易的提案，以及那些将依赖于其他[限制条款][topic covenants]软分叉的提议。`OP_VAULT` 提议的几个优点包括：

  - *<!--smaller-witnesses-->较小的见证人：*灵活的限制条款提议，例如那些使用提议的 [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack]，将要求见证解托管交易的那笔交易包含大量数据的副本。而这些数据原本已存在于该交易的其他地方，因此这种方式会使这些交易的大小和费用成本增大。`OP_VAULT` 需要更少的脚本和见证数据才能包含在链上。

  - *<!--fewer-steps-for-spending-->更少的支出步骤：*当前基于预签名交易的那些不太灵活的限制条款提议和保险库需要将资金提取到预先指定的地址，然后才能将其发送到最终目的地。此类提议通常还要求每个接收到的输出与其他接收到的输出在单独的交易中花费，因此无法使用[批量支付][topic
    payment
    batching]。这增加了涉及的交易数量，这也增加了支出的规模和成本。

    在通常情况下，`OP_VAULT` 在花费单个输出时需要更少的交易。它还支持在花费或冻结多个输出时进行批处理，从而可能节省大量空间并允许保险库在需要合并其输出以确保安全之前接收更多交易。

  在讨论这个想法时，Greg Sanders 提出了（如[O'Beirne 所总结的][obeirne scripthash]）一个稍微不同的结构，“例如，可允许在保险库生命周期中的所有输出都是 [P2TR][topic taproot]，它会隐藏保险库的操作——这会是一个非常好的特性”。

  另外，Anthony Towns [指出][towns op_vault]该提案允许保险库用户随时冻结他们的资金，只需将资金花费到高度信任的支出路径的地址，并允许用户之后解冻他们的资金。这对保险库的所有者有利，因为他们不需要访问任何特别安全的密钥物品（例如冷钱包）来阻止盗窃企图。但是，任何获悉该地址的第三方也可以冻结用户的资金（尽管他们必须为此支付交易费用），给用户带来不便。鉴于许多轻量级钱包会向第三方披露其地址以定位其链上交易，建立在这些钱包上的保险库可能会无意中让第三方有能力给保险库用户带来不便。 Towns 提出了一种冻结条件的替代结构，需要提供额外的非隐私信息才能启动冻结，既保留了该计划的好处，又降低了钱包不必要地赋予第三方冻结资金能力并给用户带来不便的风险。 Towns 还建议一个对批处理支持的可能改进并考虑 taproot 支持。

  一些回复还提到 `OP_UNVAULT` 可以提供 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]（CTV）提议的许多功能，包括之前在 [Newsletter #185][news185 ctv-dlc] 中描述的 [DLC][topic dlc] 的好处，尽管这比直接使用 CTV 的链上成本更高。

  截至撰写本文时，讨论仍在进行中。

## 服务与客户端软件变更

*在这个月度专题中，我们重点介绍比特币钱包和服务的有意思的更新。*

- **Kraken 宣布支持发送到 taproot 地址：**
  在最近的[博文][kraken bech32m]中，Kraken 宣布他们支持提现（发送）到 [bech32m][topic bech32] 地址。

- **Whirlpool coinjoin rust 客户端库公布：**
  [Samourai Whirlpool 客户端][whirlpool rust client] 是一个用于与 Whirlpool [coinjoin][topic coinjoin] 平台交互的 rust 库。

- **Ledger 支持 miniscript：**
  如[先前][ledger miniscript]公告，Ledger 的硬件签名设备的比特币固件 v2.1.0 版本支持[miniscript][topic miniscript]。

- **Liana 钱包发布：**
  第一版的 Liana 钱包已[公告][liana blog]。该钱包支持带有[时间锁][topic timelocks] 恢复密钥的单签钱包。该项目的未来计划包括实施 [taproot][topic taproot]、多签钱包和时间衰减的多签等功能。

- **Electrum 4.3.3 发布：**
  [Electrum 4.3.3][electrum 4.3.3] 包含对闪电网络、[PSBTs][topic psbt]、硬件签名者和构建系统的改进。

## 新版本与候选版本

*热门的比特币基础设施项目的新版本与候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [HWI 2.2.0][] 发布，允许软件钱包与硬件签名设备交互。它增加了对 [P2TR][topic taproot] keypath 花费的支持，使用 BitBox02 硬件签名设备以及其他功能和错误修复。

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]和 [Lightning BOLTs][bolts repo]。*

- [Core Lightning #5751][] 弃用了对创建新的封装 P2SH 隔离见证地址的支持。

- [BIPs #1378][] 为 [v2 加密 P2P 传输协议][topic v2 p2p transport] 添加 [BIP324][]。

{% include references.md %}
{% include linkers/issues.md v=2 issues="5751,1378" %}
[hwi 2.2.0]: https://github.com/bitcoin-core/HWI/releases/tag/2.2.0
[obeirne op_vault]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-January/021318.html
[obeirne paper]: https://jameso.be/vaults.pdf
[obeirne scripthash]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-January/021329.html
[news185 ctv-dlc]: /en/newsletters/2022/02/02/#improving-dlc-efficiency-by-changing-script
[towns op_vault]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-January/021328.html
[kraken bech32m]: https://blog.kraken.com/post/16740/bitcoin-taproot-address-now-supported-on-kraken/
[whirlpool rust client]: https://github.com/straylight-orbit/whirlpool-client-rs
[ledger miniscript]: https://blog.ledger.com/miniscript-is-coming/
[liana blog]: https://wizardsardine.com/blog/liana-announcement/
[electrum 4.3.3]: https://github.com/spesmilo/electrum/blob/4.3.3/RELEASE-NOTES
