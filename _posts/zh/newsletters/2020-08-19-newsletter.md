---
title: 'Bitcoin Optech Newsletter #111'
permalink: /zh/newsletters/2020/08/19/
name: 2020-08-19-newsletter-zh
slug: 2020-08-19-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了 BIP340 关于 schnorr 签名规范可能做出的更新，以及一项新提议的 BIP，它规范了比特币节点应如何以向前兼容的方式处理 P2P 协议特性协商。此外，还包括我们常规的栏目：服务和客户端软件的值得注意的变更、发布与候选发布，以及热门比特币基础设施软件的变更。

## 行动项

*本周无。*

## 新闻

- **<!--proposed-uniform-tiebreaker-in-schnorr-signatures-->****提议在 schnorr 签名中采用统一的决胜规则：** 比特币中使用的[椭圆曲线密码学][elliptic curve cryptography]需要识别椭圆曲线（EC）上的点。这可以通过使用 32 字节的 X 坐标和 32 字节的 Y 坐标来无歧义地标识。然而，如果已知某点的 X 坐标，你就能算出其 Y 坐标的两个可能位置。这个小小的歧义可以这样消除：要么额外提供一个比特的数据，指明两个坐标中该用哪一个；要么使用一种称为*决胜规则*的方法，为每个 X 坐标自动选定其中一个 Y 坐标。

  比特币的 [BIP340][BIP340] 对 schnorr 签名的规范目前采用一种决胜规则，以尽量减少标识公钥与签名中 EC 点所需的数据量。早期，BIP340 对公钥中的点和签名中的点都采用基于 Y 坐标平方性的决胜算法。最近这一规范作了更改：公钥改用基于坐标偶数性的另一种算法，因为人们认为，对现有那些生成公钥的软件来说，该算法更容易实现（见 Newsletter [#83][news83 tiebreaker] 和 [#96][news96 bip340 update]）。

  本周，Pieter Wuille 在 Bitcoin-Dev 邮件列表中[发布][wuille tiebreaker]了一项更新 BIP340 的暂定提议，使公钥和签名都改用偶数性算法。此前人们认为，平方性算法在签名验证过程中计算更快，有助于加快全节点，但 Peter Dettman 向 libsecp256k1 提交的一个带来显著性能提升的[新 PR][libsecp256k1 #767] 使开发者对这一看法产生了怀疑，并揭示出先前偏向平方性算法的基准测试并未真正公平地比较这两种决胜方法。现在看来，两种方法在性能上应大致相当。

  有几位回复者表示，尽管他们已经在代码中实现了这两种决胜方法，但他们更希望看到规范改为只使用偶数性方法。其他有意见的人也被鼓励去邮件列表讨论帖中回复。

- **<!--proposed-bip-for-p2p-protocol-feature-negotiation-->****提议的 P2P 协议特性协商 BIP：** Suhas Daftuar [发布][daftuar negotiation]了一项建议，提议为已成为 [BIP339][BIP339] 一部分的 P2P 特性协商方法单独创建一个 [BIP][bip-negotiation]（见 [Newsletter #87][news87 negotiation]）。协议更改很简单：当节点从新连接的对等节点收到 P2P `version` 消息时，节点应忽略任何自己无法理解的消息，直到从该对等节点收到 `verack` 消息为止。这些消息（例如 BIP339 新增的 `wtxidrelay` 消息）可能表明远程对等节点支持哪些特性。

  这一行为已在 Bitcoin Core 一个尚未发布的开发版本中实现。如果其他实现的维护者或其他任何人反对这一更改，请在邮件列表讨论帖中回复。

## 服务和客户端软件的变更

*在本月栏目中，我们重点介绍 Bitcoin 钱包与服务的一些有趣更新。*

- **<!--crypto-garage-announces-p2p-derivatives-beta-application-on-bitcoin-->****Crypto Garage 宣布在比特币上推出 P2P 衍生品测试版应用：** 在一篇[博客文章][cg p2p derivatives blog]中，Crypto Garage 介绍了一款在比特币 regtest 和 testnet 上进行基于 [谨慎日志合约（DLC）][dlcs] 的 P2P 衍生品交易的测试版应用。该应用允许指定一份金融协议，并在协议双方之间创建相应的资金锁定交易。合约到期时，价格预言机会为结算交易提供签名，该结算交易花费与协议相对应的金额。

- **<!--specter-desktop-adds-batching-->****Specter Desktop 增加批处理功能：** [Specter Desktop][specter github] 是面向 Bitcoin Core 的、以硬件钱包多重签名为主的图形界面，它增加了向多个接收方发送交易的功能。

- **<!--lightning-labs-releases-lightning-terminal-->****Lightning Labs 发布 Lightning Terminal：** [Lightning Terminal][lightning terminal blog] 是一个基于浏览器的可视化工具，用于 LN 通道管理，最初侧重于 [Lightning Loop][news39 lightning loop announced]。

- **<!--wasabi-adds-support-for-payjoin-->****Wasabi 增加对 payjoin 的支持：** [Wasabi 1.1.12][Wasabi 1.1.12] 增加了对 [BIP78][BIP78] payjoin 规范的支持，该规范同样可以通过 Tor 工作。

- **<!--bluewallet-for-desktop-alpha-announced-->****BlueWallet 公布桌面版 Alpha：** BlueWallet 公布了其闪电网络与比特币钱包的 macOS [桌面 Alpha 版][bluewallet desktop]，该钱包支持 bech32、硬件钱包、PSBT、仅观察地址等。

- **<!--bitcoinissafe-com-lists-bitcoin-software-marked-as-malicious-by-antivirus-products-->****BitcoinIsSafe.com 列出了被杀毒软件标记为恶意软件的比特币软件：** 网站 [bitcoinissafe.com][bitcoinissafe.com] 跟踪比特币软件在流行的杀毒产品中的检测率，包括 Bitcoin Core、Electrum 和 Wasabi。该网站还提供了通知杀毒厂商关于潜在误报的联系方式。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [LND 0.11.0-beta.rc4][lnd 0.11.0-beta] 是该项目下一个主要版本的候选发布版本。它允许接受[大通道][topic large channels]（该功能默认关闭），并包含许多后端功能改进，高级用户可能会感兴趣（请参阅[发布说明][lnd 0.11.0-beta]）。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]中值得注意的更改。*

- [Bitcoin Core #19658][] 修改了 `getnodeaddresses` RPC，当指定要获取的地址数量为 `0` 时，允许返回所有已知地址。此前返回的地址数量存在上限，主要是因为内部实现的特殊之处。

- [Bitcoin Core #18654][] 添加了一个新的 `psbtbumpfee` RPC，它接收一个当前位于本地节点内存池中的交易的 txid，并创建一个[PSBT][topic psbt]，以提高该交易的费率（可以自动计算金额，也可以通过参数指定金额）。其他 RPC 或外部工具随后可以签署并完成该 PSBT。

  现有的 `bumpfee` RPC 此前会为仅观察钱包创建 PSBT 形式的手续费追加（见 [Newsletter #80][news80 bumpfee]）。这一行为现已被弃用，并将打印消息提示这些用户改用 `psbtbumpfee`。对常规的含私钥钱包使用 `bumpfee`，仍会创建、签署并广播手续费追加交易。这一更改让 `bumpfee` 更加一致，因为它先前针对仅观察钱包创建 PSBT 的行为无法包含签署或广播步骤。

- [Bitcoin Core #19070][] 允许 Bitcoin Core 在对等节点间宣告自己支持[紧凑区块过滤器][topic compact block filters]——前提是已启用 `peerblockfilters` 和 `blockfilterindex` 配置选项（默认禁用）。这将允许 [DNS 种子节点][DNS seeders]之类的服务把提供过滤器的节点 IP 地址告知轻量客户端。这个 PR 是让 Bitcoin Core 支持 [BIP157][] 和 [BIP158][] 的一系列补丁中的最后一个。

- [Bitcoin Core #15937][] 更新了 `createwallet`、`loadwallet` 和 `unloadwallet` RPC，以提供 `load_on_startup` 选项，从而可以将钱包名称添加到启动时自动加载钱包的列表中（或者，如果该选项设置为 false，则从该列表中移除钱包名称）。预计未来的 PR 将允许 GUI 添加或移除同一列表中的钱包名称。

- [C-Lightning #3830][] 增加了对使用[锚定输出][topic anchor outputs]的实验性支持，这既能在正常情况下降低链上交易手续费，也能在出于安全需要时提高手续费。这一初始实现仅在编译 C-Lightning 时启用实验性功能才可用。

- [LND #4521][] 更新了它向发票添加路由提示的方法。先前的方法没有考虑[多路径支付][topic multipath payments]，因此如果你尝试生成的发票金额大于你当前任一通道的容量，就不会包含路由提示。新方法会包含更多提示，并打乱这些提示的顺序，从而降低单个通道流动性耗尽的可能性。

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
