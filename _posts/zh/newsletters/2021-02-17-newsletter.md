---
title: 'Bitcoin Optech Newsletter #136'
permalink: /zh/newsletters/2021/02/17/
name: 2021-02-17-newsletter-zh
slug: 2021-02-17-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 介绍了一种用于生成和验证交易签名的新型常数时间算法的研发过程，提到了一项停止处理未请求交易的提案，总结了一份关于设置多重签名钱包的 BIP 草案，分享了在闪电网络（LN）上实现托管的讨论中的见解，链接到有关双向预付 LN 费用的新一轮讨论，并提到了一种用于降低恶意硬件钱包风险的新协议。本期同样包含我们的固定栏目：客户端与服务更新的新闻、新软件版本与候选发布的公告，以及热门比特币基础设施软件中值得注意的变更的说明。

## 新闻

- **<!--faster-signature-operations-->****更快的签名操作：** Russell O'Connor 和 Andrew Poelstra 发布了一篇[博客文章][safegcd bounds]，宣布实现了一种算法，可将 Bitcoin Core 的签名验证速度提升 15%。它还能把生成签名所需的时间缩短 25%，同时仍采用常数时间算法，从而降低侧信道数据泄露的风险。对设备资源有限的硬件钱包开发者来说，这可能尤其值得关注。

  该博客文章介绍了这一新算法的研发历程：算法由 Daniel J. Bernstein 和 Bo-Yin Yang 提出；Peter Dettman 将其实现于 libsecp256k1（见 [Newsletter #111][news111 secp767]）；Pieter Wuille 提出了一种新颖且对 CPU 高效的方法，用来计算该算法在常数时间内达成目标所需的最大步数；Gregory Maxwell 给出了 Bernstein 与 Yang 算法的变体，效率更高；O'Connor 和 Poelstra 则在 Coq 证明助手中实现了 Wuille 的界限验证程序，以帮助确保其正确性。Dettman 为 libsecp256k1 编写的原始实现，已随 Wuille 的这些新进展更新为 [PR #831][libsecp256k1 #831]。

- **<!--proposal-to-stop-processing-unsolicited-transactions-->****停止处理未请求交易的提案：** 通常，节点会通过在 P2P 协议的 `inv` 消息中收到新交易的公告。如果节点对该交易感兴趣（例如它此前没有从其他对等节点收到过这笔交易），就会用 `getdata` 消息请求该交易，广播方则在 `tx` 消息中回复交易。然而近十年来，一些轻客户端和其他软件跳过了 `inv` 和 `getdata` 两步，直接发送未请求的 `tx` 消息（[示例][bitcoinj unsolicited]）。

  本周，Antoine Riard 在 Bitcoin-Dev 邮件列表上[发布][riard post]了一项提案，建议停止处理这类未请求的 `tx` 消息。正如 [Bitcoin Core PR][Bitcoin Core #20277] 中所讨论的，这能让节点更好地控制何时接收和处理交易，也为其提供了一种额外手段，用来限制那些发送验证成本高昂交易的对等节点所造成的影响。Riard 提议，这一更改最早可能在 Bitcoin Core 的下一个主要版本 22.0 中实施。

  这种做法的缺点是，所有当前发送未请求 `tx` 消息的客户端都将无法发送交易，除非它们在最后几批 0.21.x 或更早版本的 Bitcoin Core 节点（以及其他行为类似的比特币实现）退出网络之前完成升级。旧版本彻底退出网络通常需要数年时间，因此应该有足够的时间完成客户端升级。我们鼓励受影响客户端的开发者阅读该提案，并考虑发表意见。

- **<!--securely-setting-up-multisig-wallets-->****安全地设置多重签名（multisig）钱包：** Hugo Nguyen 在 Bitcoin-Dev 邮件列表上[发布][nguyen post]了一份 BIP 草案，说明钱包（尤其是硬件钱包）如何安全地交换必要信息，从而成为某个多重签名钱包的签名者。需要交换的信息包括要使用的脚本模板（例如要求 2-of-3 密钥签名的 P2WSH），以及每个签名者在其计划用于签名的密钥路径上的 [BIP32][] 扩展公钥（xpub）。

  简言之，在 Nguyen 的提案中（该提案是与几家硬件钱包厂商通信后形成的），由协调员选择脚本模板并生成一个私有的加密与认证凭据，以此启动多重签名的联合过程。这些参数会共享给各成员钱包，成员钱包选择合适的密钥路径，并返回自己的 xpub 以及用对应私钥生成的签名。每个钱包都会把 {identifying_parameters, key_path, xpub, signature} 这一集合加密后返回给协调员。协调员随后将它们组合成一个[输出脚本描述符][topic descriptors]，加密后传回每个成员钱包；成员钱包确认其中包含自己的 xpub，然后把这个描述符保存为自己愿意签名的脚本模板。

  该提案在邮件列表上引发了大量讨论，并计划做出一些更改。我们将持续关注讨论，在提案逐渐成熟、接近实现时报告重要进展。

- **<!--escrow-over-ln-->****在 LN 上实现托管：** 一年多以前，Lightning-Dev 邮件列表上曾[开始][zmn escrow1]讨论为 LN 创建非托管的链上托管，本周这一话题又[重新引发讨论][aragoneses escrow]。讨论中尤其值得注意的是 ZmnSCPxj 的[帖子][zmn escrow2]，该帖子利用[德摩根定律][De Morgan's laws]处理布尔命题，大幅简化了托管的构造——[或许][kohen escrow]也能简化许多其他基于 LN 的合约——代价是要求卖方在收到付款之前先缴纳保证金。ZmnSCPxj 的想法需要升级 LN 以使用 [PTLC][topic ptlc]，而目前预计这要等到 [taproot][topic taproot] 激活之后。

- **<!--renewed-discussion-about-bidirectional-upfront-ln-fees-->****关于双向预付 LN 费用的新一轮讨论：** Joost Jager [重新启动][jager hold fees]了 Lightning-Dev 邮件列表上关于新增 LN 服务费的讨论：当付款方和收款方占用通道有限的资金额度（“流动性”）和并发支付能力（“HTLC slots”）时，按其占用时间收费。Jager 在之前的提案（见 [Newsletter #122][news122 bidir]）基础上，把固定费用扩展为与支付处理时长成比例的费用（“持有费”）。该提案引发了适度的讨论，其中一个[担忧][zmn hold fee privacy]是会削弱发送方/接收方的隐私。其背后的根本问题[为人所知][russell loop]已有五年，并已被反复深入讨论，因此我们预计讨论还会继续。

- **<!--anti-exfiltration-->****防止外泄：** Andrew Poelstra 和 Jonas Nick 发布了一篇[博客文章][anti-exfil]，介绍一种正在为 Shift Crypto [BitBox02][] 和 Blockstream [Jade][] 硬件钱包实施的安全技术。其目标是让硬件钱包和控制它的计算机都能确信：用于生成签名的 nonce 确实是一个无法猜到的值。这可以防止恶意硬件钱包固件生成固件作者已知的 nonce——否则作者可以把该 nonce 与链上找到的该设备某一笔交易签名结合，推导出私钥，进而花费这些密钥控制的其他比特币。文章介绍了所采用的技术，该技术在近一年前一个讨论此主题的邮件列表帖子中曾被提及（见 Newsletter [#87][news87 exfil] 和 [#88][news88 exfil]）。

## 服务和客户端软件的变更

*在本月栏目中，我们重点介绍 Bitcoin 钱包与服务的一些有趣更新。*

- **<!--blockstream-announces-lnsync-->****Blockstream 宣布 LNsync：**
  [LNsync][blockstream blog lnsync] 允许离线一段时间的闪电钱包快速下载 LN 拓扑的最新更新，以便以最优路径把支付路由到目的地。开源插件 [historian][github historian] 为 C-Lightning 用户提供了这一功能。

- **<!--rust-light-client-nakamoto-released-->****Rust 轻客户端 Nakamoto 发布：**
  Alexis Sellier 发布了 [Nakamoto][nakamoto blog]，这是一个“用 Rust 实现的高保证比特币轻客户端，专注于低资源占用、模块化和安全性”，基于[紧凑区块过滤器][topic compact block filters]。

- **<!--blockstream-satellite-broadcasting-ln-data-and-bitcoin-core-source-->****Blockstream Satellite 广播 LN 数据和 Bitcoin Core 源码：**
  Blockstream 的卫星除广播比特币区块链数据外，现在还提供 [Bitcoin Core 源代码][blockstream satellite bitcoin code]、为卫星优化的比特币分支代码（[Bitcoin Satellite][github bitcoin satellite]），以及 [LN gossip 数据][blockstream satellite ln data]。

- **<!--blockstream-green-implements-csv-->****Blockstream Green 实现 CSV：**
  Green Wallet 此前使用 nLockTime 作为钱包恢复机制，要求用户在每笔交易后从 Blockstream 接收包含预签名交易的备份邮件，才能恢复资金。通过[实现基于 `OP_CHECKSEQUENCEVERIFY`（CSV）的恢复机制][blockstream green csv]，钱包现在无需针对每笔交易的备份文件，也无需为钱包关联电子邮箱地址即可恢复。

- **<!--muun-2-0-released-->****Muun 2.0 发布：**
  比特币与闪电网络移动钱包 Muun 的 [2.0 版本][muun 2.0 blog]包含多重签名和钱包恢复功能，同时还开源了 Android 与 iOS 移动应用。

- **<!--joinmarket-0-8-1-released-->****Joinmarket 0.8.1 发布：**
  [0.8.1 版本][joinmarket 0.8.1]增加了对外部创建的[部分签名比特币交易（PSBT）][topic psbt]的支持，支持 [signet][topic signet]，并修复了对 [BIP21][] URI 中大写地址的支持（见 [Newsletter #127][news127 bech32 casing]）。JoinMarket 基于终端的 UI [JoininBox][github joininbox] 也已更新，以支持 0.8.1。

- **<!--vbtc-allows-withdrawals-via-ln-and-segwit-batches-->****VBTC 允许通过 LN 和 segwit 批量提款：**
  越南交易所 VBTC 在最近[启用闪电提款][vbtc blog lightning]后，又[添加了批量 segwit 提款选项][vbtc blog segwit]。这种带激励的 segwit 批量提款每周执行一次，时间选在内存池出现大量交易积压的可能性较低的时段。

- **<!--bitcoin-dev-kit-v0-3-0-released-->****Bitcoin Dev Kit v0.3.0 发布：**
  Rust 钱包库 Bitcoin Dev Kit 宣布了其 [v0.3.0 版本][bdk 0.3.0 blog]，其中包括把 CLI 拆分到独立的仓库。此前的 [BDK v0.2.0][bdk 0.2.0 blog] 版本增加了分支限界（BnB）选币、[输出脚本描述符][topic descriptors]模板（包括最近新增的 `sortedmulti`）等功能。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [LND 0.12.1-beta.rc1][] 是 LND 一个维护版本的候选发布。它修复了一个可能导致通道意外关闭的边缘情况，以及一个可能让某些支付无谓失败的 bug，此外还有一些小改进和错误修复。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]中值得注意的变更。*

- [Bitcoin Core #20944][] 向 `getmempoolinfo` RPC 和 `mempool/info` REST 端点返回的对象添加了一个新的 `total_fee` 字段。`total_fee` 表示内存池（mempool）中当前所有交易的手续费总和。

- [LND #4909][] 添加了新的 `getmccfg` 和 `setmccfg` RPC，用它们可以分别获取和临时更改 LND 的*mission control* 子系统中的设置，而无需重启守护进程。mission control 会利用以往支付尝试的信息，为后续支付尝试选择更优的路由。

- [Rust-Lightning #787][] 确保只有当发送错误消息的对等节点就是该通道的交易对手时，才会因为错误消息而关闭通道。此前，恶意对等节点只要知道通道 ID，就可能强制关闭任何通道。

- [BTCPay Server #2164][] 重新设计了钱包设置向导，引导用户设置 BTCPay 的内部钱包，并可选地将其与用户自己的远程软件或硬件钱包集成。这是 BTCPay 界面后续一系列重新设计工作的开端。

- [HWI #443][] 增加了对用 BitBox02 硬件钱包签署多重签名输入的支持。

- [Bitcoin Core #19145][] 扩展了 `gettxoutsetinfo` RPC 的 `hash_type` 选项，使其接受新的 `muhash` 参数；该参数会生成当前区块高度上 UTXO 集合的 [MuHash3072][] 摘要。这是对 UTXO 集合默认 SHA256 摘要的一种替代方案。以这种方式运行时，MuHash 要处理的数据量与 SHA256 函数相同，因此预计 `gettxoutsetinfo` RPC 的性能不会明显变化——而在较慢的单板计算机上，这个 RPC 可能需要几分钟才能返回。不过，向此前已算出的 MuHash 对象中添加或删除元素相对廉价，因此预计未来的 PR 能快速计算每个区块的 UTXO 集合 MuHash 摘要，把这些摘要存进一个简单的数据库，并在需要时几乎立即以摘要形式返回。这也有利于 [AssumeUTXO][topic assumeutxo] 项目，因为该项目依赖用户能够在选定的历史区块高度上比较 UTXO 集合哈希。

- [C-Lightning #4364][] 更改了向通道伙伴通报问题的方式，把现有的错误消息区分为真正的*错误*和仅属*警告*的两类。当前的 [BOLT1][] 规范要求任何错误都必须导致通道关闭（尽管这一点似乎并未普遍实现），但一项[提议的规范更新][bolts #834]引入了警告消息类型，从而可以做出更灵活的响应。感兴趣的人也可以阅读 Carla Kirk-Cohen 本周在 Lightning-Dev 邮件列表上发表的[帖子][kirk-cohen post]，其中讨论了扩展的错误消息描述；她将这一话题描述为“相关，但与软警告错误并不直接相关”。


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
