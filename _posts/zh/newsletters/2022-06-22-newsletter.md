---
title: 'Bitcoin Optech Newsletter #205'
permalink: /zh/newsletters/2022/06/22/
name: 2022-06-22-newsletter-zh
slug: 2022-06-22-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了 Bitcoin Core 的提议选项（即使对于未选用 BIP125 的交易也可以更轻松地启用交易替换）、有关 Hertzbleed 侧信道漏洞信息的链接、有关时间戳系统设计的讨论结论的总结，并检视了使用比特币 UTXO 的新的防女巫攻击的协议。还包括我们的常规部分，其中描述了比特币客户端和服务中有意思的新功能、新版本和候选版本的公告，以及流行的比特币基础设施软件中值得注意的变更的汇总介绍。

## 新闻

- **<!--policy-limits-->完全交易费替换：** 已开启[两个][bitcoin core #25353] pull [requests][bitcoin core #25373] 以支持 Bitcoin Core 的完全交易费替换（[RBF][topic rbf]）这个默认关闭的选项。如果启用，该节点的内存池中的任何未确认交易都可以被该交易的替代版本所替换，该替代版本的交易会支付更高的费用（同时考虑其他规则）。

  目前，Bitcoin Core 仅在要替换的交易版本启用了信号位时才允许 RBF，如 [BIP125][] 中所定义。这给多方合约协议带来了挑战，例如 LN 和 [DLCs][topic dlc]，其中一方有时可能会从交易中删除 BIP125 信号，以防止其他参与方使用交易替换。这可能会导致延迟，在最坏的情况下，可能会导致依赖及时确认的协议（例如 [HTLCs][topic htlc]）中的资金损失。

  [其中一个 PR][bitcoin core #25353] 很快得到了开发者的大力支持。因为它只添加了启用完全 RBF 的能力——但默认情况下不启用它——它不会改变比特币核心当前的默认行为。从长远来看，一些开发人员可能会提倡默认启用完全 RBF，因此本周在 Bitcoin-Dev 邮件列表上[开始][rbf Discussion]了一个讨论线，以给服务、应用程序和替代完整节点的开发人员一个机会来提出反对提供完整 RBF 选项的意见，并可能最终默认启用它。

- **Hertzbleed：** 一个最近[披露][hertzbleed]的安全漏洞影响许多（可能是所有）主流的笔记本电脑、台式机和服务器 CPU 处理器。当这些私钥被用于为比特币交易创建签名（或执行其他类似的操作），该漏洞可能会使攻击者发现私钥。这种攻击值得注意的方面是它可能会影响签名生成代码，而这些代码原本专门被编写为始终使用相同类型和数量的 CPU 操作，以防止向攻击者泄露信息。

  利用该漏洞需要攻击者测量 CPU 芯片的功耗或测量部分签名操作的持续时间。理想情况下，对于攻击者来说，他们将能够在用户使用相同的私钥创建许多签名时进行测量。因此，该漏洞更有可能影响常用的热钱包，例如托管服务和 LN 路由节点使用的热钱包，以及[地址重用][topic output linking]的情况。在安全环境中使用的大部分或完全离线的钱包将更能抵抗攻击。

  在撰写本文时，尚未完全清楚该漏洞对比特币用户的严重性。我们知道今天的许多钱包，包括几种流行的硬件签名设备，都在使用容易受到功率和时序分析的签名生成代码，因此对于这些用户来说，可能没法改变任何事情。对于有着更高安全规范的用户，开发人员可能会实施额外的保护措施。如果您对您使用的软件有任何疑问或疑虑，请通过适当的支持渠道（例如用于许多免费和开源软件比特币项目的 [Bitcoin Stack Exchange][]）联系其开发人员。

- **<!--timestamping-design-->时间戳设计：** Bitcoin-Dev 邮件列表上关于基于比特币的 [Open Timestamps][]（OTS）系统设计的旷日持久的辩论似乎在本周有了[结论][poelstra timestamping]。争论的根源看起来是因为存在着两种不同的时间戳系统设计：

    - *加盖时间戳的存在证明（TSPoE）：*一个比特币交易承诺了一个哈希摘要，而该哈希摘要承诺了一个文档。当交易在区块中得到确认时，承诺的创建者可以向第三方证明该文件在新建此区块时存在。值得注意的是，每个时间戳交易可以完全独立于其他时间戳交易，这意味着可以多次为同一个文档加上时间戳，而时间戳之间没有联系。

    - *事件排序 (EO)：*一系列以特定方式相互关联的交易，每个交易都以允许系统中任何用户查看所有承诺的方式承诺了文档。对于在该系统下被加盖两次或多次时间戳的任何文档，都可以确定它第一次加盖时间戳的时间。

  由 OTS 实现的 TSPoE 系统本质上是非常高效的。它使用相同数量的全局存储空间为无限数量的文档添加时间戳，因为每个请求时间戳的人都会负责存储他们的时间戳证明。该系统还具有概念和实现都简单的优点。

  EO 系统要求所有完整参与者存储对每个文档的承诺。这可能会降低效率并增加复杂性。该设计的权衡是它确实允许参与者验证文档何时首次发布到系统。

  上文中的讨论并未引发任何系统已公布的修改或提案，例如： Open Timestamps 或交易赞助（讨论的原始主题，请参阅 [Newsletter #116][news116 Sponsorship]）。这似乎的确让一些讨论参与者感到意外，因为他们每个人都可能对“时间戳”所隐含的内容有不同的观念。

- **新的 RIDDLE 防女巫攻击方法：** Adam “Waxwing” Gibson 在 Bitcoin-Dev 邮件列表[发布了][gibson riddle post]一个使用比特币 UTXO 集并可提供相当好的隐私的[防女巫攻击][sybil]的[提案][gibson riddle gist]。用户可以生成一个 UTXO 的列表，其中一个 UTXO 属于该用户，其余的属于其他用户。该用户之后创建一个签名。该签名可被证明是来自列表中的一个 UTXO 的所有者，但不知道是哪个所有者所创建的。

  一个恶意用户可以生成许多这样的证明，但在用尽可选的证明之前只能生成有限数量的证明，从而限制了他们过度消耗稀缺网络资源的能力。恶意用户也可以尽可能长时间地使用一个 UTXO，然后花费它来获得一个新的 UTXO，但这会产生交易费用。这种高成本也会阻止滥用。服务可以通过限制用户可选择的 UTXO 来进一步限制女巫攻击。例如，一项服务可能只接受价值 1 BTC 且一年未使用的 UTXO 的签名。

  Gibson 提议成员证明可以有两种形式：全局证明和局部证明。全局证明将在验证者之间共享，因此在理想条件下，用户只能在全局上下文中为每个 UTXO 创建一个证明。例如，用户将只能为每个有一年之久且价值 1 BTC 的 UTXO 注册一个账户。

  局部上下文将特定于单个验证者（或一组关联的验证者，例如去中心化交易所的验证者）。例如，用户可以使用 UTXO 访问服务 A 上的 API，然后在服务 B 上重用这个 UTXO。

  此外，高价值的 UTXO 可以被视为多个价值较低的 UTXO，因此一个 10 BTC 的 UTXO 可以允许用户在全局上下文中注册 10 个不同服务的不同账户，每个账户需要 1 BTC 的资金。

  尽管 RIDDLE 协议确实提供了优于其他防女巫攻击机制的隐私优势，但 Gibson 警告说，使用该系统的信息可以与其他可用信息相结合，从而可能减弱用户的隐私。他写道，“这种系统不可能提供牢不可破的隐私保证。如果保护真正签名的 utxo 的位置是事关生死的，那么绝对不要使用这样的系统！”

  在 Lightning-Dev 邮件列表中，开发者 ZmnSCPxj [建议][zmnscpxj riddle] RIDDLE 可能是将闪电网络的防女巫攻击机制从基于 UTXO 的通道标识符中剥离的一个可选方案。在 [taproot][topic taproot] 和[签名聚合][topic musig]的时代，该通道标识符不必要地揭示了哪些链上交易是闪电网络通道打开和相互关闭的交易。

## 服务和客户端软件的变更

*在这个月度专题中，我们重点介绍比特币钱包和服务的有意思的变更。*

- **Zeus 添加了对 Taproot 的支持：**
  [Zeus v0.6.5-rc1][] 添加了对 LND v0.15+ 后端的 [taproot][topic taproot] 发送和接收的支持。

- **Wasabi 钱包 2.0 发布：**
  这个[混币][topic coinjoin]软件的[发布][wasabi 2.0]实现了 [WabiSabi 协议][news194 wabisabi]以及其他改进。

- **Sparrow 添加 Taproot 硬件签名：**
  通过升级到 [HWI 2.1.0][]，Sparrow [1.6.4][sparrow 1.6.4] 添加了对某些硬件签名设备的 Taproot 签名支持。

## 软件的新版本和候选版本

*流行比特币基础设施项目的新版本和候选版本。请考虑升级到最新版本或帮助测试候选版本。*

- [LND 0.15.0-beta.rc6][] 是这个流行的 LN 节点的下一个主要版本的候选版本。

- [LDK 0.0.108][] 和 0.0.107 版本除提供了允许移动客户端从服务器同步网络路由信息 （*gossip*） 的代码以外，还增加了对[大通道][topic large channels]和 [zero-conf 通道][topic zero-conf channels]的支持，以及其他功能和错误修复。

- [BDK 0.19.0][] 通过[描述符][topic descriptors]、[PSBTs][topic psbt] 和其他子系统增加了对 [taproot][topic taproot] 的实验性支持。它还增加了一个新的[选币算法][topic coin selection]。

## 重大代码及文档变更

*本周内，[Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo] 和 [Lightning BOLTs][bolts repo] 出现的重大变更。*

- [Bitcoin Core GUI #602][] 将 GUI 更改的配置写入一个无头守护程序（`bitcoind`）也会加载的文件中，因此无论用户如何启动 Bitcoin Core，都会使用更改后的配置。

- [Eclair #2224][] 添加了对短通道标识符 (scid) 别名和 [zero-conf 通道][topic zero-conf channels]类型的支持。scid 的别名可以提高隐私性，还可以让节点在一个通道被充分确认之前轻松引用它。zero-conf 通道允许两个节点在得到充分确认之前同意使用通道来路由支付，这在一定的约束条件下是安全的。

- [HWI #611][] 添加了对 BitBox02 硬件签名设备 [bech32m 地址][topic bech32]的单签名支持。

{% include references.md %}
{% include linkers/issues.md v=2 issues="602,2224,611,25353,25373" %}
[lnd 0.15.0-beta.rc6]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.0-beta.rc6
[ldk 0.0.108]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.108
[bdk 0.19.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.19.0
[rbf discussion]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-June/020557.html
[hertzbleed]: https://www.hertzbleed.com/
[news116 sponsorship]: /en/newsletters/2020/09/23/#transaction-fee-sponsorship
[poelstra timestamping]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-June/020569.html
[gibson riddle post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-June/020555.html
[gibson riddle gist]: https://gist.github.com/AdamISZ/51349418be08be22aa2b4b469e3be92f
[bitcoin stack exchange]: https://bitcoin.stackexchange.com/
[open timestamps]: https://opentimestamps.org/
[sybil]: https://en.wikipedia.org/wiki/Sybil_attack
[zmnscpxj riddle]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-June/003607.html
[Zeus v0.6.5-rc1]: https://github.com/ZeusLN/zeus/releases/tag/v0.6.5-rc1
[wasabi 2.0]: https://github.com/zkSNACKs/WalletWasabi/releases/tag/v2.0.0.0
[news194 wabisabi]: /en/newsletters/2022/04/06/#wabisabi-alternative-to-payjoin
[HWI 2.1.0]: /en/newsletters/2022/03/23/#hwi-2-1-0-rc-1
[sparrow 1.6.4]: https://github.com/sparrowwallet/sparrow/releases/tag/1.6.4
