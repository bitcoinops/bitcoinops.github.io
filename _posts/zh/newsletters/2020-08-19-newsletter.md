---
title: 'Bitcoin Optech Newsletter #111'
permalink: /zh/newsletters/2020/08/19/
name: 2020-08-19-newsletter-zh
slug: 2020-08-19-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了对 BIP340 关于 Schnorr 签名规范的可能更新，以及一项新提议的 BIP，它规范了比特币节点如何以向前兼容的方式处理 P2P 协议特性协商。此外，还包括我们常规的服务和客户端软件的显著更改、发布与候选发布以及流行比特币基础设施软件的更改。

## 行动项

*本周无。*

## 新闻

- **<!--proposed-uniform-tiebreaker-in-schnorr-signatures-->****提议在 Schnorr 签名中采用统一的优先选择规则：** 比特币中使用的[椭圆曲线密码学][elliptic curve cryptography]需要识别椭圆曲线 (EC) 上的点。这可以通过使用 32 字节的 X 坐标和 32 字节的 Y 坐标来明确标识。然而，如果已知某点的 X 坐标，则可以计算其 Y 坐标的两个可能位置。此小差异可以通过提供一个额外的比特数据来指示使用哪一个 Y 坐标，或者通过使用一种称为“优先选择”的方法，为每个 X 坐标自动选择一个 Y 坐标。

  比特币的 [BIP340][BIP340] 规范目前在公钥和签名中使用了一种优先选择方法，以尽量减少标识公钥中的 EC 点和签名所需的数据量。早期，BIP340 在公钥和签名的点上都使用基于 Y 坐标平方性的优先选择算法。最近，这一规范被更改为在公钥上使用基于坐标偶数性的不同算法，因为该算法被认为更容易实现，适合现有的公钥生成软件（见 Newsletter [#83][news83 tiebreaker] 和 [#96][news96 bip340 update]）。

  本周，Pieter Wuille 在 Bitcoin-Dev 邮件列表中[发布][wuille tiebreaker]了一项更新 BIP340 的暂定提议，以便公钥和签名都使用偶数性算法。此前认为，平方性算法在签名验证过程中计算速度更快，有助于提升全节点的运行速度，但 Peter Dettman 在 libsecp256k1 中提出的一个具有显著性能提升的[最近 PR][libsecp256k1 #767] 使得开发者对这一观点产生了怀疑，并揭示出先前有利于平方性算法的基准测试并未公平地比较这两种优先选择方法。现在看来，这两种方法在性能上应大致相等。

  几位回复者表示，尽管他们已在代码中实现了这两种优先选择方法，但他们更愿意看到规范改为仅使用偶数性方法。其他有意见的人也被鼓励在邮件列表线程中发表意见。

- **<!--proposed-bip-for-p2p-protocol-feature-negotiation-->****提议的 P2P 协议特性协商 BIP：** Suhas Daftuar [发布][daftuar negotiation]了一个建议，提出为成为 [BIP339][BIP339] 一部分的 P2P 特性协商方法创建一个[单独的 BIP][bip-negotiation]（见 [Newsletter #87][news87 negotiation]）。协议更改很简单：当节点从新连接的对等方接收到 P2P `version` 消息时，节点应忽略任何无法理解的消息，直到从该对等方接收到 `verack` 消息。这些消息（如新的 BIP339 `wtxidrelay` 消息）可能表明远程对等方支持的功能。

  这种行为已在比特币核心的一个未发布开发版本中实现。如果其他实现的维护者或其他任何人反对此更改，请在邮件列表线程中回复。

## 服务和客户端软件的更改

*在此每月特刊中，我们会关注比特币钱包和服务的有趣更新。*

- **<!--crypto-garage-announces-p2p-derivatives-beta-application-on-bitcoin-->****Crypto Garage 宣布在比特币上推出 P2P 衍生品测试应用：** 在一篇[博客文章][cg p2p derivatives blog]中，Crypto Garage 概述了一款用于在比特币 regtest 和 testnet 上进行 P2P [DLC 基础][dlcs]衍生品的测试应用。该应用允许指定金融协议并在协议双方之间创建相应的资金锁定交易。在合约到期时，价格预言机提供用于支出协议中对应金额的签名的结束交易。

- **<!--specter-desktop-adds-batching-->****Specter Desktop 添加批量处理功能：** 作为比特币核心的硬件钱包多签 GUI，[Specter Desktop][specter github]  增加了将交易发送给多个接收方的功能。

- **<!--lightning-labs-releases-lightning-terminal-->****Lightning Labs 发布 Lightning Terminal：** [Lightning Terminal][lightning terminal blog] 是一个基于浏览器的视觉化工具，用于 LN 通道管理，最初专注于 [Lightning Loop][news39 lightning loop announced]。

- **<!--wasabi-adds-support-for-payjoin-->****Wasabi 增加对 PayJoin 的支持：** [Wasabi 1.1.12][Wasabi 1.1.12] 增加了对 [BIP78][BIP78] PayJoin 规范的支持，该规范也可以通过 Tor 工作。

- **<!--bluewallet-for-desktop-alpha-announced-->****BlueWallet 公布桌面端 Alpha 版：** BlueWallet 公布了适用于 macOS 的[桌面 Alpha 版本][bluewallet desktop]，其支持 bech32、硬件钱包、PSBTs、观察地址等功能的闪电网络和比特币钱包。

- **<!--bitcoinissafe-com-lists-bitcoin-software-marked-as-malicious-by-antivirus-products-->****BitcoinIsSafe.com 列出了被杀毒软件标记为恶意软件的比特币软件：** 网站 [bitcoinissafe.com][bitcoinissafe.com] 跟踪比特币软件在流行的杀毒产品中的检测率，包括 Bitcoin Core、Electrum 和 Wasabi。该网站还提供了通知杀毒厂商关于潜在误报的联系方式。

## 发布与候选发布

*流行比特币基础设施项目的新发布和候选发布。请考虑升级到新发布版本或帮助测试候选版本。*

- [LND 0.11.0-beta.rc4][lnd 0.11.0-beta] 是此项目下一个重要版本的候选版本。它允许接受[大通道][topic large channels]（默认情况下关闭），并包含对后端功能的诸多改进，可能引起高级用户的兴趣（请参阅[发布说明][lnd 0.11.0-beta]）。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]中值得注意的更改。*

- [Bitcoin Core #19658][] 修改了 `getnodeaddresses` RPC，当指定地址数量为 `0` 时可以返回所有已知地址。此前，由于内部实现的特殊性，返回的地址数量存在上限。

- [Bitcoin Core #18654][] 添加了一个新的 `psbtbumpfee` RPC，该 RPC 接收一个当前在本地节点内存池中的交易的 txid 并创建一个[PSBT][topic psbt]，从而增加其手续费率（可以是自动数量或通过参数指定的数量）。其他 RPC 或外部工具随后可以签署并完成该 PSBT。

  现有的 `bumpfee` RPC 先前已为观察钱包创建 PSBT 手续费增加（见 [Newsletter #80][news80 bumpfee]）。该行为现已被弃用，并将打印消息通知这些用户使用 `psbtbumpfee`。对于常规含钥钱包，`bumpfee` 仍然会创建、签署并广播手续费增加交易。此更改使 `bumpfee` 更加一致，因为先前的观察钱包行为创建 PSBT 的同时不能包括签署或广播步骤。

- [Bitcoin Core #19070][] 允许 Bitcoin Core 广告其对[致密区块过滤器][topic compact block filters]的支持（启用 `peerblockfilters` 和 `blockfilterindex` 配置选项时生效，默认情况下禁用）。这将允许如 [DNS 种子节点][DNS seeders]之类的服务告知轻量客户端提供过滤器的节点 IP 地址。此 PR 是一系列补丁中的最后一个，已在 Bitcoin Core 中启用 [BIP157][] 和 [BIP158][] 支持。

- [Bitcoin Core #15937][] 更新了 `createwallet`、`loadwallet` 和 `unloadwallet` RPC，以提供 `load_on_startup` 选项，从而可以将钱包名称添加到启动时自动加载钱包的列表中（或者，如果该选项设置为 false，则从该列表中移除钱包名称）。预计未来的 PR 将允许 GUI 添加或移除同一列表中的钱包名称。

- [C-Lightning #3830][] 添加了对[锚定输出][topic anchor outputs]的实验性支持，这既可以在正常情况下减少链上交易费用，又可以在必要时增加安全费用。此初始实现仅在 C-Lightning 以启用实验性功能编译时可用。

- [LND #4521][] 更新了其用于向发票中添加路由提示的方法。先前的方法没有考虑[多路径支付][topic multipath payments]，因此如果您尝试生成的发票金额大于当前任意通道的金额，则不会包含路由提示。新方法包括更多提示，并随机化提示的顺序，以减少单个通道流动性耗尽的可能性。

{% include references.md %}
{% include linkers/issues.md issues="767,19658,18654,19070,3830,4521,15937" %}

[lnd 0.11.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.11.0-beta.rc4
[elliptic curve cryptography]: https://en.wikipedia.org/wiki/Elliptic_curve_cryptography
[news83 tiebreaker]: /zh/newsletters/2020/02/05/#alternative-x-only-pubkey-tiebreaker
[news96 bip340 update]: /zh/newsletters/2020/05/06/#bips-893
[wuille tiebreaker]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-August/018081.html
[daftuar negotiation]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-August/018084.html
[bip-negotiation]: https://github.com/sdaftuar/bips/blob/2020-08-generalized-feature-negotiation/bip-p2p-feature-negotiation.mediawiki
[news87 negotiation]: /zh/newsletters/2020/03/04/#improving-feature-negotiation-between-full-nodes-at-startup
[news80 bumpfee]: /zh/newsletters/2020/01/15/#bitcoin-core-16373
[dns seeders]: https://btcinformation.org/en/glossary/dns-seed
[specter github]: https://github.com/cryptoadvance/specter-desktop
[cg p2p derivatives blog]:https://medium.com/@cryptogarage/announcing-the-global-launch-of-p2p-derivatives-beta-application-7ecc02fa02a1
[dlcs]: https://adiabat.github.io/dlc.pdf
[Wasabi 1.1.12]: https://github.com/zkSNACKs/WalletWasabi/releases/tag/v1.1.12
[bluewallet desktop]: https://bluewallet.io/desktop-bitcoin-wallet/
[bitcoinissafe.com]: https://bitcoinissafe.com/
[lightning terminal blog]: https://lightning.engineering/posts/2020-08-04-lightning-terminal/
[news39 lightning loop announced]: /zh/newsletters/2019/03/26/#loop-announced
[hwi]: https://github.com/bitcoin-core/HWI
