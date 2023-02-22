---
title: 'Bitcoin Optech Newsletter #238'
permalink: /zh/newsletters/2023/02/15/
name: 2023-02-15-newsletter-zh
slug: 2023-02-15-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报摘要了在比特币区块链上存储数据的持续讨论，描述了针对某些类型的多方协议的一种假设费用稀释攻击，并描述了如何将 tapscript 签名承诺用于同一棵树的不同部分。此外还有我们的常规部分：其中包含服务和客户端更新的汇总、新版本和候选版本软件的总结，以及对热门比特币基础设施项目的重大变更介绍。 我们还为专注于比特币技术文档和讨论的新搜索引擎提供了我们罕见的一次建议。

## 新闻

- **有关区块链数据储存的持续讨论:** 本周 Bitcoin-Dev 邮件列表上的几个消息列持续讨论了有关在区块链中存储数据的问题。

    - *币的链下染色:* Anthony Towns [发布了][towns color] 对当前用于为某些交易输出分配特殊含义的一种协议的总结，是一类通常被称为“币的染色”的技术。他还总结了一个相关协议，用于在比特币交易中存储编码的二进制数据并将其与特定被染色的币相关联。 在总结了当前的情况后，他描述了一种使用[nostr][] 消息传输协议存储数据并将其与可以在比特币交易中传输的被染色的币的相关联的方法。这带来几个好处：

      - *降低成本:* 链下存储的数据无需支付交易费用。

      - *隐私:* 两个人可以交换一枚被染色的币，而其他任何人都不知道这枚币所引用的数据。

      - *创建不需要交易:* 数据可以与现有的UTXO相关联；无需创建新的 UTXO。

      - *抗审查:* 如果数据和被染色的币之间的关联并不广为人知，那么被染色的币的转移与任何其他链上的比特币支付一样具有抗审查性。

      对于抗审查方面，Towns 认为“被染色的比特币在很大程度上是不可避免的并只是必须处理的事情，而不是我们应该花时间试图预防/避免的事情。” 他将被染色的币可能比同质化比特币更有价值的想法与比特币根据交易权重而不是转移的价值收取交易费用的运作方式进行了比较，得出的结论是他认为这种想法不一定会导致严重的激励失调。

    - *在标准交易中增加允许的 `OP_RETURN` 空间 :*
      Christopher Allen [提问][allen op_return], 是否使用 `OP_RETURN` 或交易的见证数据将任意数据放入交易输出中更好？ 在经过一番讨论后，几位参与者 ([1][todd or], [2][o'connor or], [3][poelstra or]) 指出，他们赞成放宽默认交易中继和挖矿策略，从而允许 `OP_RETURN` 输出存储超过 83 字节的任意数据。 他们详细论述了目前正在使用其他存储大量数据的方法，并且使用 `OP_RETURN` 不会造成额外的损失。
      

- **多方协议中的费用稀释:** Yuval Kogman 在 Bitcoin-Dev 邮件列表上
  [发布了][kogman dilution] 邮件列表上发布了针对某些多方协议的攻击描述。尽管[曾经描述过][riard dilution]这种攻击，但 Kogman 的帖子引起了人们对攻击的重新关注。想象一下，Mallory 和 Bob 各自贡献一个输入给一项具有预期大小和费用的联合交易，这意味着可以预期的费率。Bob 为他的输入提供了预期大小的见证，但 Mallory 提供了比预期大得多的见证。这有效地降低了交易的费用。 在邮件列表中讨论了这方面的几个含义：

    - Mallory 让 Bob 支付她的费用：如果 Mallory 有一些不可告人的动机在区块链中包含一个大的见证，例如，她想要添加任意的数据，她可以使用Bob的部分费用来完成。例如，Bob 想创建一个 1,000 vbyte 的交易，费用为 10,000 satoshi，话费 10 sat/vbyte以便快速确认。Mallory 用 Bob 没有预料到的 9,000 vbytes 数据填充交易，将其费率降低到 1 sat/vbyte。虽然 Bob 在这两种情况下支付相同的绝对费用，但他没有得到他想要的（快速确认）而 Mallory 得到 价值 9,000 sat 的数据被添加到区块链中，她没有付出任何代价。

    - Mallory 能减慢确认速度：费率较低的交易可能会确认得更慢。在时间敏感的协议中，这可能会给 Bob 带来严重的问题。 在其他情况下，Bob 可能需要增加交易费用，这将花费他额外的钱。

  Kogman 在他的帖子中描述了几种缓解措施，尽管它们都涉及到权衡与取舍。  在[第二篇文章中][kogman dilution2], 他指出，他还没有发现当前部署有任何易受攻击的协议。

- **Tapscript 签名的可锻性:** 在上述关于费用稀释的讨论中，开发人员 Russell O'Connor [指出][o'connor tsm] 一个 [tapscript][topic
  tapscript] 的签名可以应用于放置在taproot 树中任何其他地方的 tapscript 的副本中。例如，相同的 tapscript A 被放置在taproot树中的两个不同位置。 要使用更深层次的替代方案，需要在支出交易的见证数据中放置一个额外的 32 字节哈希。

    ```text
      *
     / \
    A   *
       / \
      A   B
    ```

   这意味着，即使 Mallory 在 Bob 提供自己的签名之前为 Bob 提供了她的 tapscript 花费的有效见证，Mallory 仍然有可能广播具有更大见证的交易的替代版本。 Bob 只能通过从 Mallory 收到她的 tapscripts 树的完整副本来防止这个问题。

   在未来比特币软分叉升级的背景下, Anthony Towns 向用于测试 [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] (APO) 的比特币 Inquisition 存储库提出了一个[议题][bitcoin inquisition #19], 以考虑让 APO 提交额外数据以防止该扩展用户出现这类议题。

## 服务和客户端软件变更

*在这个月度专题中，我们重点介绍比特币钱包和服务的有意思的更新。*

- **Liana 钱包添加多重签名:**
  [Liana][news234 liana] 的 [0.2 版本][liana 0.2] 添加了使用
  [描述符][topic descriptors]的多重签名支持。

- **Sparrow 钱包 1.7.2 发布:**
  Sparrow的 [1.7.2 版本][sparrow 1.7.2] 添加了 [taproot][topic taproot] 支持, [BIP329][] 导入和导出功能 (请参阅[周报 #235][news235 bip329]), 以及对硬件签名设备的额外支持。

- **Bitcoinex 库添加了对 schnorr 的支持:**
  [Bitcoinex][bitcoinex github] 是一个用于 Elixir 函数式编程语言的比特币实用程序库。

- **Libwally 0.8.8 发布:**
  [Libwally 0.8.8][] 添加了 [BIP340][] 标记哈希支持, 额外的 sighash 支持包括 [BIP118][] ([SIGHASH_ANYPREVOUT][topic SIGHASH_ANYPREVOUT]), 以及额外的 [miniscript][topic miniscript], 描述符和 [PSBT][topic psbt] 函数。

## Optech 推荐

[BitcoinSearch.xyz][] 是最近推出的比特币技术文档和讨论的搜索引擎。它被用来快速找到本周报中链接的几个来源，与我们之前使用的其他更费力的方法相比有了很大的改进。欢迎对其[代码][bitcoinsearch repos]做出贡献。

## 版本和候选版本

*热门的比特币基础设施项目的新版本与候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Core Lightning 23.02rc2][] 是这个热门的 LN 实现方案的新维护版本的候选版本。

- [BTCPay Server 1.7.11][] 是新版本。 自我们介绍的上一个版本 (1.7.1) 以来，添加了几个新功能，并修复了许多错误并进行了改进。 尤其值得注意的是，与插件和第三方集成相关的几个方面已发生变化，添加了从旧版 MySQL 和 SQLite 迁移的路径，并修复了跨站点脚本漏洞。

- [BDK 0.27.0][] 对用于构建比特币钱包和应用程序进行了库的更新。

## 重大的代码和文档更新

*本周出现重大变更的有 [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Core Lightning #5361][] 添加了对对等存储备份的实验性支持。 正如 [周报 #147][news147 backups] 中最后提到的，这允许一个节点为其对等节点存储一个小的加密备份文件。如果对等方稍后需要重新连接，可能是在丢失数据之后，它可以请求备份文件。对等点可以使用从其钱包种子派生的密钥来解密文件，并使用内容来恢复其所有通道的最新状态。这可以看作是 [静态通道备份][topic static channel backups] 的增强形式. 合并后的 PR 添加了对创建、存储和检索加密备份的支持。如 PR 中所述，该功能尚未完全被指明或被其他 LN 实现方案所采用。

- [Core Lightning #5670][] 和 [#5956][core lightning #5956] 根据最近基于对 [规范][bolts
  #851] 的更改和互操作性测试人员的评论，对其 [双重出资][topic dual funding] 的实施方案进行了各种更新。此外，还添加了一个`upgradewallet` RPC ，用以将以 P2SH 包裹的输出中的所有资金转移到本地的隔离见证输出中，这是交互式通道打开所必需的。

- [Core Lightning #5697][] 添加了一个将签署 [BOLT11][] 发票的`signinvoice` RPC。 以前，CLN 只有在拥有 [哈希时间锁合约][topic HTLC] 的哈希原像时才会签署发票，以确保CLN能够要求对发票的付款。此 RPC 可以覆盖这种行为，例如，它可以现在用于发送发票，稍后使用插件从另一个程序检索原像。使用此 RPC 的任何人都应该意识到，任何事先知道用于您的节点的付款原像的第三方都可以在付款到达之前领取付款。这不仅会偷走您的钱，而且因为您在发票上签名，还会生成非常有说服力的证据证明您已收到付款（这种证据非常有说服力，以至于许多 LN 开发人员将其称为付款证明)。


- [Core Lightning #5960][] 添加了一个包含联系地址和PGP 密钥的 [安全策略][cln security.md]。

- [LND #7171][] 升级了 `signrpc` RPC <!--sic--> 以支持
   [MuSig2][topic musig] 的最新[草案 BIP][musig draft bip].  RPC 现在创建链接到 MuSig2 协议版本号的会话，以便会话中的所有操作都将使用正确的协议。[周报#222][news222 musig2] 中提到了旧版本 MuSig2 协议的安全问题。

- [LDK #2002][] 添加了对自动重新发送最初未成功的 [自动付款][topic spontaneous payments] 的功能。

- [BTCPay Server #4600][] 更新其 [payjoin][topic payjoin] 的实现方案的[硬币选择][topic coin selection] 以尽量避免创建具有不必要输入的交易，特别是在包含多个输入的交易中输入大于任何输出的输入。这不会发生在常规的单一支付者、单一接收者支付中：最大的输入将为支付输出提供足够的支付，并且不会添加额外的输入。这个 PR 的部分灵感来自一篇分析 payjoin 的文章[paper analyzing payjoins][]。

{% include references.md %}
{% include linkers/issues.md v=2 issues="5361,5670,5956,851,5697,5960,7171,2002,4541,4600" %}
[news147 backups]: /en/newsletters/2021/05/05/#closing-lost-channels-with-only-a-bip32-seed
[cln security.md]: https://github.com/ElementsProject/lightning/blob/master/SECURITY.md
[news222 musig2]: /en/newsletters/2022/10/19/#musig2-security-vulnerability
[musig draft bip]: https://github.com/jonasnick/bips/blob/musig2/bip-musig2.mediawiki
[paper analyzing payjoins]: https://eprint.iacr.org/2022/589.pdf
[bitcoinsearch repos]: https://github.com/bitcoinsearch
[towns color]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021396.html
[nostr]: https://github.com/nostr-protocol/nostr
[allen op_return]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021387.html
[todd or]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021435.html
[o'connor or]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021439.html
[poelstra or]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021438.html
[kogman dilution]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021444.html
[riard dilution]: https://gist.github.com/ariard/7e509bf2c81ea8049fd0c67978c521af#witness-malleability
[kogman dilution2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021459.html
[o'connor tsm]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021452.html
[bitcoin inquisition #19]: https://github.com/bitcoin-inquisition/bitcoin/issues/19
[bitcoinsearch.xyz]: https://bitcoinsearch.xyz/
[core lightning 23.02rc2]: https://github.com/ElementsProject/lightning/releases/tag/v23.02rc2
[BTCPay Server 1.7.11]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.7.11
[bdk 0.27.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.27.0
[news234 liana]: /en/newsletters/2023/01/18/#liana-wallet-released
[liana 0.2]: https://github.com/wizardsardine/liana/releases/tag/0.2
[sparrow 1.7.2]: https://github.com/sparrowwallet/sparrow/releases/tag/1.7.2
[news235 bip329]: /en/newsletters/2023/01/25/#bips-1383
[bitcoinex github]: https://github.com/RiverFinancial/bitcoinex
[libwally 0.8.8]: https://github.com/ElementsProject/libwally-core/releases/tag/release_0.8.8
