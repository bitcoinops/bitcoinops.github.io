---
title: 'Bitcoin Optech Newsletter #226'
permalink: /zh/newsletters/2022/11/16/
name: 2022-11-16-newsletter-zh
slug: 2022-11-16-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报描述了一项在比特币上启用通用智能合约的提案，并总结了一篇关于解决闪电网络通道阻塞攻击的论文。还包括我们的常规部分，其中描述了服务和客户端软件的变化、新版本和候选版本的公告，以及热门比特币基础设施软件的重大变更的总结。

## 新闻

- **<!--general-smart-contracts-in-bitcoin-via-covenants-->通过契约实现的比特币通用智能合约：** Salvatore Ingala 在 Bitcoin-Dev 邮件列表中[发布了][ingala matt]一种新型[限制性条款][topic covenants] 的提案（需要软分叉），允许使用[默克尔树][merkle trees]创建可以将状态从一个链上交易传输到另一个链上交易的智能合约。以 Ingala 的帖子为例，两个用户可以在国际象棋游戏中下注，其中合约可以保存游戏规则，状态可以保存棋盘上所有棋子的位置，并且可以更新状态通过每个链上交易。当然，一个设计精细的合约将允许游戏在链下进行，只有游戏结束时的结算交易被放在链上（或者如果游戏是在例如支付通道的另一个链下结构中玩，那么甚至可能留在链下）。

    Ingala 解释了这项工作如何帮助设计[支付池（joinpools）][topic joinpools]、optimistic rollups（参见[周报 #222][news222 rollup]）和其他有状态的构建。

- **<!--paper-about-channel-jamming-attacks-->关于通道阻塞攻击的论文：** Clara Shikhelman 和 Sergei Tikhomirov 在 Lightning-Dev 邮件列表中[发布了][st unjam post]一篇关于[通道阻塞攻击][topic channel jamming attacks]解决方案[论文][st unjam paper]的摘要。这类攻击最早在 2015 年就有介绍，可以使大量通道长时间无法使用，而攻击者的成本可以忽略不计。

    作者将阻塞攻击分为两种类型。第一种是*缓慢阻塞*，即通道的有限时隙或用于支付转发的资金长时间不可用——合法的支付很少发生这种情况。第二种是*快速阻塞*，其中时隙和资金仅被短暂阻塞——这种情况经常发生在正常支付中，因此可能使快速阻塞攻击更难防范。

    他们提议了两种解决方案：

    - *<!--unconditional-fees-->无条件手续费*（与之前周报中描述的*预付手续费*相同），即使付款未能到达收款方，也会向转发节点支付一定数量的费用。作者建议既有独立于付款金额的*基本*预付手续费，也有随付款金额增加而*按比例*收取的手续费。这两个单独的手续费分别解决了 HTLC 时隙阻塞和流动性阻塞。手续费可以是非常小的，因为它们只是为了防止快速阻塞。这类攻击需要频繁重新发送虚假付款，每笔付款都需要支付额外的预付费用，从而增加攻击者的成本。

    - *<!--local-reputation-with-forwarding-->包含转发信息的本地声誉*，每个节点都会保留有关其每个对方节点的统计信息，包括其转发付款的等待时间和收取的转发费用等相关信息。如果一个节点的每笔费用的时间很高，可认为这个节点是高风险的，只允许那个节点使用有限数量的本地节点的时隙和资金；否则，可认为对方节点是低风险的。

        当一个节点从它认为是低风险的节点接收到转发的支付时，它会检查该节点是否也将支付标记为低风险。如果上游转发节点和支付都是低风险的，则可允许该支付使用任何可用的时隙和资金。

    该论文在邮件列表上有一些讨论，特别是提出的本地信誉方法获得了称赞。

## 服务与客户端软件变更

*在这个月度专题中，我们重点介绍比特币钱包和服务的有意思的更新。*

- **Sparrow 1.7.0 发布：**
  [Sparrow 1.7.0][sparrow 1.7.0] 添加了支持基于 [Replace-By-Fee (RBF)][topic rbf] 实现的交易取消功能以及其他更新。

- **Blixt 钱包添加了对 taproot 的支持：**
  [Blixt Wallet v0.6.0][blixt v0.6.0] 添加了对 [taproot][topic taproot] 地址的发送和接收的支持。

- **Spectre-DIY v1.8.0 发布：**
  [Spectre-DIY v1.8.0][Specter-DIY v1.8.0] 现在支持[可重现构建（reproducible build）][topic reproducible builds]和 [taproot][topic taproot] keypath 花费。

- **Trezor Suite 添加选币控制功能：**
  在[最近的博文][trezor coin control]中，Trezor 宣布Trezor Suite 现在支持[选币控制][topic coin selection]功能。

- **Strike 添加了 taproot 发送支持：**
  Strike 的钱包现在允许发送到 [bech32m][topic bech32] 地址。

- **Kollider 交易所上线，支持闪电网络：**
  Kollider [公布了][kollider launch] 具有闪电网络存取功能的交易所以及一款基于浏览器的闪电网络钱包。

## 新版本和候选版本

*热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Bitcoin Core 24.0 RC4][] 是网络中使用最广泛的全节点实现的下一版本的候选版本。[测试指南][bcc testing]已可用。

  **<!--warning-->警告：**这一版软件包含了 `mempoolfullrbf` 配置选项。一些协议和应用程序开发人员认为该配置选项可能会导致商户服务出现问题，如周报 [#222][news222 rbf] 和 [#223][news223 rbf] 中所述。它也可能导致如[周报 #224][news224 rbf]所描述的交易中继问题。

- [LND 0.15.5-beta.rc1][] 是 LND 维护发布的候选版本。根据其计划发行说明，该版本仅包含一些小 bug 修复。

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo] 和 [Lightning BOLTs][bolts repo]。*

- [Core Lightning #5681][] 添加了在服务器端过滤 RPC 的 JSON 输出的功能。在服务器端进行过滤可在使用带宽受限的远程连接时，避免发送不需要的数据。将来，一些 RPC 可能能够避免计算过滤后的数据，从而可以更快地返回。该过滤功能不能保证对所有 RPC 有效，尤其是那些由插件提供的。当过滤功能不可用时，将返回未过滤的完整输出。有关详细信息，请参阅附带[文档][cln filter doc]。

- [Core Lightning #5698][] 更新了实验性开发者模式，以允许接收任何大小的通过洋葱包装的错误消息。 BOLT2 目前建议使用 256 字节的错误，但它并不禁止更长的错误消息；并且 [BOLTs #1021][] 已打开，以鼓励使用基于闪电网络当前的类型-长度-值 (TLV) 语义编码的 1024 字节错误消息。

- [Core Lightning #5647][] 添加了 reckless 插件管理器。插件管理器可从 `lightningd/plugins` 代码库中按照名称安装 CLN 插件。插件管理器会自动安装依赖项并验证。它还可用于启用和禁用插件以及将插件状态持久化在配置文件中。

- [LDK #1796][] 更新 `Confirm::get_relevant_txids()`，不仅返回 txid，还返回包含这些引用交易的区块的哈希值。这使得更高层级的应用程序更容易确定发生了一个可能改变了交易确认深度的区块链重组。如果给定 txid 的区块哈希发生了变化，则发生了重组。

- [BOLTs #1031][] 允许支付者在使用[简化的多路径支付][topic multipath payments]时向接收者支付的金额略高于请求的金额。在选择的支付路径使用具有最小可路由数量的通道的情况下，这可能是必需的。例如，Alice 想将总的 900 sat 分成两部分，但她选择的两条路径都需要 500 sat 的最低数量。此规范修改后，她现在可以发送两笔 500 sat 的付款，选择多付总共 100 sat 以使用她所首选的路径。

{% include references.md %}
{% include linkers/issues.md v=2 issues="5681,5698,5647,1796,1031,1021" %}
[bitcoin core 24.0 rc4]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[lnd 0.15.5-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.5-beta.rc1
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/24.0-Release-Candidate-Testing-Guide
[news222 rbf]: /zh/newsletters/2022/10/19/#transaction-replacement-option
[news223 rbf]: /zh/newsletters/2022/10/26/#continued-discussion-about-full-rbf-rbf
[news224 rbf]: /zh/newsletters/2022/11/02/#mempool-consistency
[cln filter doc]: https://github.com/rustyrussell/lightning/blob/a6f38a2c1a47c5497178c199691047320f2c55bc/doc/lightningd-rpc.7.md#field-filtering
[ingala matt]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-November/021182.html
[merkle trees]: https://en.wikipedia.org/wiki/Merkle_tree
[news222 rollup]: /zh/newsletters/2022/10/19/#rollup
[st unjam post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-November/003740.html
[st unjam paper]: https://raw.githubusercontent.com/s-tikhomirov/ln-jamming-simulator/master/unjamming-lightning.pdf
[sparrow 1.7.0]: https://github.com/sparrowwallet/sparrow/releases/tag/1.7.0
[blixt v0.6.0]: https://github.com/hsjoberg/blixt-wallet/releases/tag/v0.6.0
[Specter-DIY v1.8.0]: https://github.com/cryptoadvance/specter-diy/releases/tag/v1.8.0
[trezor coin control]: https://blog.trezor.io/coin-control-in-trezor-suite-92f3455fd706
[kollider launch]: https://blog.kollider.xyz/announcing-kolliders-launch/
