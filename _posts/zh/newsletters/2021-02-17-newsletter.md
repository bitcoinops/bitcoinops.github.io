---
title: 'Bitcoin Optech Newsletter #136'
permalink: /zh/newsletters/2021/02/17/
name: 2021-02-17-newsletter-zh
slug: 2021-02-17-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了一个用于生成和验证交易签名的新常数时间算法的发展，提到了停止处理未请求交易的提案，总结了一个用于设置 multisig 钱包的提议 BIP，分享了关于在闪电网络（LN）上管理托管的讨论见解，链接到关于双向预付 LN 费用的重新讨论，并提到了一个用于减轻恶意硬件钱包风险的新协议。还包括我们定期的部分，内容涵盖更新的客户端和服务的新闻、新软件发布和候选发布的公告，以及对流行比特币基础设施软件中值得注意的更改的描述。

## 新闻

- **<!--faster-signature-operations-->****更快的签名操作：** Russell O'Connor 和 Andrew Poelstra 发布了一篇[博客文章][safegcd bounds]，宣布实现了一种算法，可以将 Bitcoin Core 的签名验证速度提升 15%。它还可以在生成签名的时间上减少 25%，同时使用一种常数时间算法，降低侧信道数据泄漏的风险，这可能特别引起硬件钱包开发者的兴趣，因为他们的设备资源有限。

  该博客文章描述了 Daniel J. Bernstein 和 Bo-Yin Yang 开发的新算法，Peter Dettman 为 libsecp256k1 实现的版本（在 [Newsletter #111][news111 secp767] 中提到），Pieter Wuille 用于计算算法在常数时间内达到目标所需的最大步骤数的创新且高效的 CPU 方法，Gregory Maxwell 对 Bernstein 和 Yang 算法的变体，效率更高，以及 O'Connor 和 Poelstra 在 Coq 证明助手中实现的 Wuille 的界限验证程序，以帮助确保其正确性。Dettman 为 libsecp256k1 的原始实现已根据 Wuille 的最新发展进行了更新，见[PR #831][libsecp256k1 #831]。

- **<!--proposal-to-stop-processing-unsolicited-transactions-->****停止处理未请求交易的提案：** 通常节点期望在 P2P 协议的 `inv` 消息中接收新交易的公告。如果节点对该交易感兴趣（例如，它之前没有从其他对等方接收到过），它会使用 `getdata` 消息请求该交易，广播者会在 `tx` 消息中回复交易。然而，近十年来，一些轻客户端和其他软件跳过了 `inv` 和 `getdata` 步骤，直接发送未请求的 `tx` 消息（[示例][bitcoinj unsolicited]）。

  本周，Antoine Riard [在 Bitcoin-Dev 邮件列表][riard post]上发布了一项提案，建议停止处理此类未请求的 `tx` 消息。正如在 [Bitcoin Core PR][Bitcoin Core #20277] 中讨论的，这将使节点更好地控制何时接收和处理交易，为限制发送昂贵待验证交易的对等方的影响提供了额外的方法。Riard 建议这一更改可能在下一个主要版本 Bitcoin Core 22.0 中实施。

  这种方法的缺点是，所有当前发送未请求 `tx` 消息的客户端将无法发送交易，除非它们在 Bitcoin Core 的最后几个 0.21.x 或更早版本离开网络之前升级（或其他以类似方式行事的比特币实现）。旧版本完全离开网络通常需要几年时间，因此应有足够的时间完成客户端升级。我们鼓励受影响客户端的开发者阅读提案并考虑发表评论。

- **<!--securely-setting-up-multisig-wallets-->****安全设置 multisig 钱包：** Hugo Nguyen [在 Bitcoin-Dev 邮件列表][nguyen post]上发布了一份 BIP 草案，描述了钱包，特别是硬件钱包，如何安全地交换成为 multisig 钱包签名者所需的信息。需要交换的信息包括要使用的脚本模板（例如，要求 2-of-3 密钥签名的 P2WSH）以及每个签名者在计划用于签名的密钥路径上的 [BIP32][] 扩展公钥（xpub）。

  简而言之，Nguyen 的提案（与几家硬件钱包制造商通信开发）由协调员发起 multisig 联邦过程，选择脚本模板并生成私有加密和认证凭证。这些参数与成员钱包共享，成员钱包选择适当的密钥路径并返回其 xpub 以及其对应私钥生成的签名。{identifying_parameters, key_path, xpub, signature} 集合被加密并由每个钱包返回给协调员。协调员随后将它们组合成一个[输出文本描述符][topic descriptors]，该描述符被加密并返回给每个成员钱包，成员钱包验证其 xpub 是否包含其中，然后将描述符存储为他们愿意签名的脚本模板。

  该提案在邮件列表上引起了大量讨论，并计划进行一些更改。我们将监控讨论，以便在提案成熟并接近实施时获取重要更新。

- **<!--escrow-over-ln-->****在 LN 上的托管：** 一年前在 Lightning-Dev 邮件列表上关于创建非托管链上托管的讨论[开始][zmn escrow1]，本周看到[重新讨论][aragoneses escrow]。讨论中的一个特别突出的是 ZmnSCPxj 的[帖子][zmn escrow2]，该帖子使用[德摩根定律][De Morgan's laws]来大大简化托管的构建——以及[可能][kohen escrow]许多其他基于 LN 的合同——代价是要求卖方在收到付款之前发布保证金。ZmnSCPxj 的想法需要升级 LN 使用 [PTLCs][topic ptlc]，预计不会在 [Taproot][topic taproot] 激活之前。

- **<!--renewed-discussion-about-bidirectional-upfront-ln-fees-->****关于双向预付 LN 费用的重新讨论：** Joost Jager [重新启动][jager hold fees] Lightning-Dev 邮件列表上关于添加 LN 服务费用的讨论，该费用向支付者和接收者收取他们使用频道有限资金（“流动性”）和并发支付能力（“HTLC slots”）所消耗的时间的费用。Jager 基于之前的提案（见 [Newsletter #122][news122 bidir]），将其固定费用扩展为与支付处理持续时间成比例的费用（“持有费用”）。该提案引起了适度的讨论，其中一个[担忧][zmn hold fee privacy]是减少发送者/接收者的隐私。这里的基本问题已经[已知][russell loop]五年，并多次深入讨论，因此我们预计讨论将继续。

- **<!--anti-exfiltration-->****防止数据外泄：** Andrew Poelstra 和 Jonas Nick 发布了一篇[博客文章][anti-exfil]，介绍了一种正在为 Shift Crypto [BitBox02][] 和 Blockstream [Jade][] 硬件钱包实施的安全技术。目标是让硬件钱包和控制它的计算机都能确保用于生成签名的随机数实际上是不可猜测的值。这防止了恶意硬件钱包固件生成固件作者已知的随机数，固件作者可以将其与链上找到的设备交易签名之一结合起来，以推导其私钥，从而允许他们支配这些密钥控制的任何其他比特币。该文章描述了所使用的技术，该技术之前在关于此主题的邮件列表讨论中提到过（见 Newsletters [#87][news87 exfil] 和 [#88][news88 exfil]）。

## 服务和客户端软件的更改

*在这个月度特辑中，我们重点介绍比特币钱包和服务的有趣更新。*

- **<!--blockstream-announces-lnsync-->****Blockstream 宣布 LNsync：**
  [LNsync][blockstream blog lnsync] 允许离线一段时间的闪电钱包快速下载 LN 拓扑的最新更新，以便最佳地将支付路由到其目的地。一个开源插件，[historian][github historian]，为 C-Lightning 用户提供了此功能。

- **<!--rust-light-client-nakamoto-released-->****Rust 轻客户端 Nakamoto 发布：**
  Alexis Sellier 发布了 [Nakamoto][nakamoto blog]，一个“用 Rust 实现的高保证比特币轻客户端，专注于低资源利用、模块化和安全”，基于 [致密区块过滤器][topic compact block filters]。

- **<!--blockstream-satellite-broadcasting-ln-data-and-bitcoin-core-source-->****Blockstream 卫星广播 LN 数据和 Bitcoin Core 源码：**
  Blockstream 的卫星，除了广播比特币区块链数据外，现在还包括 [Bitcoin Core 源代码][blockstream satellite bitcoin code]、为卫星优化的比特币分叉代码（[Bitcoin 卫星][github bitcoin satellite]），以及 [LN gossip 数据][blockstream satellite ln data]。

- **<!--blockstream-green-implements-csv-->****Blockstream Green 实现 CSV：**
  Green Wallet 之前使用 nLockTime 作为钱包恢复机制，要求用户在每笔交易后从 Blockstream 接收包含预签名交易的备份电子邮件以恢复资金。通过[实现 `OP_CHECKSEQUENCEVERIFY` (CSV) 恢复机制][blockstream green csv]，钱包现在可以在不需要特定交易的备份文件或与钱包关联电子邮件地址的情况下恢复。

- **<!--muun-2-0-released-->****Muun 2.0 发布：**
  移动比特币和闪电钱包 Muun 的[2.0 版本][muun 2.0 blog]包括 multisig、钱包恢复功能，并开源了 Android 和 iOS 移动应用。

- **<!--joinmarket-0-8-1-released-->****Joinmarket 0.8.1 发布：**
  [0.8.1 版本][joinmarket 0.8.1]包含对外部创建的 [PSBT][topic psbt] 的额外支持，支持 [signet][topic signet]，以及修复了 [BIP21][] URI 的大写地址支持（见 [Newsletter #127][news127 bech32 casing]）。JoinMarket 的基于终端的 UI，[JoininBox][github joininbox]，也更新以支持 0.8.1。

- **<!--vbtc-allows-withdrawals-via-ln-and-segwit-batches-->****VBTC 允许通过 LN 和 segwit 批量提款：**
  越南交易所 VBTC 在最近[启用闪电提款][vbtc blog lightning]后，[添加了批量 segwit 提款选项][vbtc blog segwit]。有激励的 segwit 批量提款每周进行一次，目标是在内存池不太可能有大量交易积压的时间进行。

- **<!--bitcoin-dev-kit-v0-3-0-released-->****Bitcoin Dev Kit v0.3.0 发布：**
  Rust 钱包库 Bitcoin Dev Kit 宣布了其 [0.3.0 版本][bdk 0.3.0 blog]，包括将 CLI 分离到其自己的仓库。最近的 [BDK v0.2.0][bdk 0.2.0 blog] 版本增加了分支限界（BnB）币选择、[描述符][topic descriptors] 模板（包括最近添加的 `sortedmulti`）等。

## 发布与候选发布

*流行比特币基础设施项目的新发布和候选发布。请考虑升级到新版本或帮助测试候选发布。*

- [LND 0.12.1-beta.rc1][] 是 LND 维护版本的候选发布。它修复了一个可能导致意外通道关闭的边缘情况和一个可能导致某些支付不必要失败的错误，以及一些其他的小改进和错误修复。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]中的值得注意的更改。*

- [Bitcoin Core #20944][] 向 `getmempoolinfo` RPC 和 `mempool/info` REST 端点返回的对象添加了一个新的 `total_fee` 字段。`total_fee` 表示 mempool 中当前所有交易的交易费总和。

- [LND #4909][] 添加了新的 `getmccfg` 和 `setmccfg` RPC，可以分别检索和临时更改 LND 的*mission control* 子系统中的设置，而无需重新启动守护进程。Mission control 使用有关过去支付尝试的信息来选择更好的后续支付尝试路线。

- [Rust-Lightning #787][] 确保仅在发送错误消息的对等方是通道的对手方时，因错误消息导致的通道关闭才会发生。之前，恶意对等方如果知道通道 ID，就可能强制关闭任何通道。

- [BTCPay Server #2164][] 重新设计了钱包设置向导，引导用户设置 BTCPay 的内部钱包，并可选择与用户自己的远程软件或硬件钱包集成。这是 BTCPay 界面其他重新设计工作的开始。

- [HWI #443][] 增加了对 BitBox02 硬件钱包签名 multisig 输入的支持。

- [Bitcoin Core #19145][] 扩展了 `gettxoutsetinfo` RPC 的 `hash_type` 选项，接受一个新的 `muhash` 参数，该参数将生成当前区块高度的 UTXO 集合的 [MuHash3072][] 摘要。这是生成 UTXO 集合默认 SHA256 摘要的替代方法。以这种方式运行时，MuHash 必须处理与 SHA256 函数相同的数据量，因此 `gettxoutsetinfo` RPC 的性能预计不会有显著变化，该 RPC 在慢速单板计算机上可能需要几分钟才能返回。然而，之前计算的 MuHash 对象可以相对便宜地添加或删除元素，因此预计未来的 PR 将快速计算每个区块 UTXO 集合的 MuHash 摘要，将这些摘要保存在一个简单的数据库中，并允许几乎即时按需返回它们的摘要形式。这还将惠及依赖于用户能够在选定的过去区块高度上比较 UTXO 集合哈希的 [AssumeUTXO][topic assumeutxo] 项目。

- [C-Lightning #4364][] 更改了其通知通道伙伴问题的方式，将现有错误消息分为真正的*错误*和仅为*警告*。当前的 [BOLT1][] 规范要求任何错误都导致通道关闭（尽管这似乎并未普遍实施），但一个[提议的规范更新][bolts #834]引入了警告消息类型，可以允许更灵活的响应。任何感兴趣的人也可能希望阅读 Carla Kirk-Cohen 本周在 Lightning-Dev 邮件列表上的[帖子][kirk-cohen post]，讨论扩展错误消息描述，这是她描述为“相关，但与软警告错误不直接相关的”主题。


{% include references.md %}
{% include linkers/issues.md issues="20944,4909,787,2164,443,19145,4364,834,831,20277" %}
[LND 0.12.1-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.12.1-beta.rc1
[safegcd bounds]: https://medium.com/blockstream/a-formal-proof-of-safegcd-bounds-695e1735a348
[bitcoinj unsolicited]: https://github.com/bitcoinj/bitcoinj/blob/7d2d8d7792ec5f4ce07ff82980b4e723993221e8/core/src/main/java/org/bitcoinj/core/TransactionBroadcast.java#L145
[de morgan's laws]: https://en.wikipedia.org/wiki/De_Morgan's_laws
[btcmag demo]: https://bitcoinmagazine.com/articles/good-griefing-a-lingering-vulnerability-on-lightning-network-that-still-needs-fixing
[anti-exfil]: https://medium.com/blockstream/anti-exfil-stopping-key-exfiltration-589f02facc2e
[news111 secp767]: /zh/newsletters/2020/08/19/#proposed-uniform-tiebreaker-in-schnorr-signatures
[riard post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-February/018391.html
[nguyen post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-February/018385.html
[zmn escrow1]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-June/002028.html
[aragoneses escrow]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-February/002948.html
[zmn escrow2]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-February/002955.html
[kohen escrow]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-February/002970.html
[jager hold fees]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-February/002958.html
[news122 bidir]: /zh/newsletters/2020/11/04/#bi-directional-upfront-fees-for-ln
[zmn hold fee privacy]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-February/002967.html
[russell loop]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2015-August/000135.html
[bitbox02]: https://shiftcrypto.ch/bitbox02/
[jade]: https://blockstream.com/jade/
[news87 exfil]: /zh/newsletters/2020/03/04/#proposal-to-standardize-an-exfiltration-resistant-nonce-protocol
[news88 exfil]: /zh/newsletters/2020/03/11/#exfiltration-resistant-nonce-protocols
[muhash3072]: /zh/newsletters/2021/01/13/#bitcoin-core-19055
[kirk-cohen post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-February/002964.html
[blockstream blog lnsync]: https://blockstream.com/2021/01/22/en-lnsync-getting-your-lightning-node-up-to-speed-quickly/
[github historian]: https://github.com/lightningd/plugins/tree/master/historian
[nakamoto blog]: https://cloudhead.io/nakamoto/
[blockstream satellite bitcoin code]: https://blockstream.com/2021/02/02/en-blockstream-provides-backup-satellite-broadcast-for-bitcoin-core-source-code/
[github bitcoin satellite]: https://github.com/Blockstream/bitcoinsatellite
[blockstream satellite ln data]: https://blockstream.com/2021/01/29/en-new-blockstream-satellite-updates/
[blockstream green csv]: https://blockstream.com/2021/01/25/en-blockstream-green-bitcoin-wallets-now-using-checksequenceverify-timelocks/
[muun 2.0 blog]: https://medium.com/muunwallet/announcing-muun-2-0-d61b0844dc0a
[joinmarket 0.8.1]: https://github.com/JoinMarket-Org/joinmarket-clientserver/blob/master/docs/release-notes/release-notes-0.8.1.md
[news127 bech32 casing]: /zh/newsletters/2020/12/09/#thwarted-upgrade-to-uppercase-bech32-qr-codes
[github joininbox]: https://github.com/openoms/joininbox
[vbtc blog segwit]: https://blog.vbtc.exchange/2021/batched-segwit-withdrawals-tutorial-5
[vbtc blog lightning]: https://blog.vbtc.exchange/2020/how-to-withdraw-bitcoin-lightning-network-tutorial-3
[bdk 0.3.0 blog]: https://bitcoindevkit.org/blog/2021/01/release-v0.3.0/
[bdk 0.2.0 blog]: https://bitcoindevkit.org/blog/2020/12/release-v0.2.0/
