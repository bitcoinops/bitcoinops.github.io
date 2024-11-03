---
title: 'Bitcoin Optech Newsletter #308'
permalink: /zh/newsletters/2024/06/21/
name: 2024-06-21-newsletter-zh
slug: 2024-06-21-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报宣布了影响旧版本 LND 的漏洞披露，并总结了关于 PSBT 用于静默支付的持续讨论。此外还包括我们的常规部分：其中包括服务和客户端软件的最新变更，新版本和候选版本的公告，以及对热门比特币基础设施项目的重大变更介绍。

## 新闻

- **<!--Disclosure-of-vulnerability-affecting-old-versions-of-LND-->影响旧版本 LND 的漏洞纰漏：** Matt Morehouse 在 Delving Bitcoin 上[发布了][morehouse onion]一则关于影响 LND 0.17.0 之前版本的漏洞披露。LN 通过洋葱加密的包传递支付指令和[洋葱消息][topic onion messages]，这些包包含多个加密的有效负载。每个有效负载以其长度为前缀，[自 2019 年以来][news58 variable onions]，支付的有效负载[允许]的大小最大为 1300 字节。后来引入的洋葱消息，最大可以达到 32,768 字节。然而，有效负载大小前缀使用的数据类型允许指示的大小最大为 2<sup>64</sup> 字节。

  LND 接受的有效负载指示大小最大为 4GB，并在进一步处理有效负载之前分配相应的内存。这足以耗尽某些 LND 节点的内存，导致它们崩溃或被操作系统终止，并且可以通过发送多个这种方式构造的洋葱包来使得具有更多内存的节点崩溃。崩溃的 LN 节点无法发送可能必要的、用于保护其资金的时间敏感型交易，因此可能导致资金被盗。

  该漏洞通过将最大内存分配减少到 65,536 字节得以修复。

  运行 LND 节点的任何人都应该升级到 0.17.0 或以上版本。始终建议升级到最新版本（撰写本文时为0.18.0）。

- **<!--Continued-discussion-of-PSBTs-for-silent-payments-->关于静默支付的 PSBT 的持续讨论：** 一些开发者一直在讨论使用 [PSBT] 协调发送[静默支付][topic silent payments] 的支持。自我们[上次总结][news304 sp-psbt]以来，讨论集中在使用一种技术上，其中每个签名者生成一个 _ECDH 份额_ 和一个紧凑的证明，证明他们正确生成了他们的份额。这些份额被添加到 PSBT 的输入部分。当收到所有签名者的份额时，它们与接收者的静默支付扫描密钥结合，生成放在输出脚本中的实际密钥（如果在同一交易中进行多次静默支付，则生成多个输出脚本中的多个密钥）。

  在知道交易的输出脚本后，每个签名者重新处理 PSBT 以添加他们的签名。这导致了完整的 PSBT 签名需要两轮(除了其他协议如 [MuSig2][topic musig]所需的任何其他轮次)。但是，如果整个交易只有一个签名者（例如，PSBT 被发送到一个单一的硬件签名设备），签名过程可以在一轮内完成。

  在撰写本文时，所有活跃参与讨论的人似乎大致同意这种方法，尽管关于边缘情况的讨论仍在继续。

## 服务和客户端软件变更

*在这个月度栏目中，我们会标出比特币钱包和服务的有趣更新。*

- **<!--Casa-adds-descriptor-support-->Casa 增加了描述符支持：**
  在一篇[博客文章][casa blog]中，多重签名服务提供商 Casa 宣布支持[输出脚本描述符][topic descriptors]。

- **<!--Specter-DIY-v1.9.0-released-->Specter-DIY v1.9.0 发布：**
  [v1.9.0][specter-diy v1.9.0] 版本增加了对 taproot [miniscript][topic miniscript] 和 [BIP85][] 应用程序的支持，以及其他更改。

- **<!--Constant-time-analysis-tool-cargo-checkct-announced-->恒定时间分析工具 cargo-checkct 公布：**
  一篇 Ledger [的博客文章][ledger cargo-checkct blog]公布了 [cargo-checkct][cargo-checkct github]，这是一种评估 Rust 加密库是否以恒定时间运行以避免[时序旁路攻击][topic side channels]的工具。

- **<!--Jade-adds-miniscript-support-->Jade 增加了 miniscript 支持：**
  Jade 硬件签名设备固件[现在支持][jade tweet] miniscript。

- **<!--Ark-implementation-announced-->Ark 实现端发布：**
  Ark Labs [发布了][ark labs blog]一些围绕 [Ark 协议][topic ark]的举措，包括 [Ark 实现][ark github]和[开发者资源][ark developer hub]。

- **<!--Volt-Wallet-beta-announced-->Volt Wallet 测试版发布：**
  [Volt Wallet][volt github] 支持描述符、[taproot][topic taproot]、[PSBT][topic psbt] 和其他 BIP，以及闪电网络。

- **<!--Joinstr-adds-electrum-support-->Joinstr 增加了 electrum 支持：**
  [Coinjoin][topic coinjoin] 软件 [joinstr][news214 joinstr] 增加了一个 [electrum 插件][joinstr blog]。

- **<!--Bitkit-v1.0.1-released-->Bitkit v1.0.1 发布：**
  Bitkit [宣布][bitkit blog]其自我托管的比特币和闪电移动应用已脱离测试版，可在移动应用商店下载。

- **<!--Civkit-alpha-announced-->Civkit alpha 版发布：**
  [Civkit][civkit tweet] 是一个建立在 nostr 和闪电网络上的 P2P 交易市场。

## 版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Bitcoin Core 26.2rc1][] 是一个维护版本的候选版本，适用于无法升级到最新[27.1 版本][bcc 27.1]的用户

## 重大的代码和文档变更

_本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、
[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。_

- [Bitcoin Core #29325][] 开始将交易版本存储为无符号整数。自比特币 0.1 的原始版本以来，它们一直存储为有符号整数。[BIP68][] 软分叉开始将其视为无符号整数，但至少一个公开的比特币重新实现无法产生相同的动作，产生了共识故障的可能（见[周报 #286][news286 btcd]）。通过始终以无符号整数存储和使用交易版本，希望基于阅读 Bitcoin Core 代码的任何未来比特币实现都能使用正确的类型。

- [Eclair #2867][] 定义了一种新的 `EncodedNodeId` 类型，用于[盲化路径][topic rv routing]中的移动钱包。这允许钱包提供商收到通知，下一个节点是移动设备，从而使他们能够考虑特定于移动设备的条件。

- [LND #8730][] 引入了一个 RPC 命令 `lncli wallet estimatefee` ，它接收以确认目标作为输入，并返回链上交易的[费用估算][topic fee estimation]，以 sat/kw（sats/每千单位重量）和 sat/vbyte 为单位。

- [LDK #3098][] 更新了 LDK 的快速 Gossip 同步(RGS)到 v2，v2 通过增加了序列化结构中的附加字段扩展了 v1。这些新字段包括一个字节，以指示默认节点特征的数量、节点特征数组以及在每个节点公钥之后的补充特征或套接字地址信息。此更新与提议的 [BOLT7][] gossip 更新（同样称为 gossip v2）不同。

- [LDK #3078][] 添加了对 [BOLT12][topic offers] 发票异步支付的支持：一旦设置了配置选项 `manually_handle_bolt12_invoices`，则在接收发票时生成 `InvoiceReceived` 事件。在 `ChannelManager` 上公开一个新命令 `send_payment_for_bolt12_invoice` 以支付发票。这可以允许代码在决定是付款还是拒绝发票之前评估发票。

- [LDK #3082][] 通过添加编码和解析接口以及构建方法来构建 BOLT12 静态发票以响应来自[要约（offer）][topic offers] 的 `InvoiceRequest`，来支持 BOLT12 静态发票（可复用支付请求）。

- [LDK #3103][] 开始在基准测试中使用基于实际支付路径频繁[探测][topic payment probes]的性能评分器。希望这能导致更现实的测试基准。

- [LDK #3037][] 开始强制关闭其费率陈旧且过低的通道。LDK 持续跟踪其[估算器][topic fee estimation]在过去一天内返回的最低可接受费率。在每个区块，LDK 将关闭任何支付的费率低于过去一天最低费率的通道。目标是“确保通道费率始终足以在需要强制关闭时确认我们的承诺交易。”

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2867,8730,3098,3078,3082,3103,3037,29325" %}
[news304 sp-psbt]: /zh/newsletters/2024/05/24/#discussion-about-psbts-for-silent-payments-psbt
[news58 variable onions]: /en/newsletters/2019/08/07/#bolts-619
[morehouse onion]: https://delvingbitcoin.org/t/dos-disclosure-lnd-onion-bomb/979
[bcc 27.1]: /zh/newsletters/2024/06/14/#bitcoin-core-27-1
[bitcoin core 26.2rc1]: https://bitcoincore.org/bin/bitcoin-core-26.2/
[news286 btcd]: /zh/newsletters/2024/01/24/#disclosure-of-fixed-consensus-failure-in-btcd-btcd
[casa blog]: https://blog.casa.io/introducing-wallet-descriptors/
[specter-diy v1.9.0]: https://github.com/cryptoadvance/specter-diy/releases/tag/v1.9.0
[cargo-checkct github]: https://github.com/Ledger-Donjon/cargo-checkct
[ledger cargo-checkct blog]: https://www.ledger.com/blog-cargo-checkct-our-home-made-tool-guarding-against-timing-attacks-is-now-open-source
[jade tweet]: https://x.com/BlockstreamJade/status/1790587478287814859
[ark labs blog]: https://blog.arklabs.to/introducing-ark-labs-a-new-venture-to-bring-seamless-and-scalable-payments-to-bitcoin-811388c0001b
[ark github]: https://github.com/ark-network/ark/
[ark developer hub]: https://arkdev.info/docs/
[volt github]: https://github.com/Zero-1729/volt
[news214 joinstr]: /zh/newsletters/2022/08/24/#coinjoin-joinstr
[joinstr blog]: https://uncensoredtech.substack.com/p/tutorial-electrum-plugin-for-joinstr
[bitkit blog]: https://blog.bitkit.to/synonym-officially-launches-the-bitkit-wallet-on-app-stores-9de547708d4e
[civkit tweet]: https://x.com/gregory_nico/status/1800818359946154471
