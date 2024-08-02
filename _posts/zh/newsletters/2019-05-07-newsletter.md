---
title: 'Bitcoin Optech Newsletter #45'
permalink: /zh/newsletters/2019/05/07/
name: 2019-05-07-newsletter-zh
slug: 2019-05-07-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 突出了最近发布的 Bitcoin Core 0.18.0 的一些变化，简要提及了两个提议的 BIPs，描述了 bech32 地址与预期协议改进的前向兼容性，并总结了流行的比特币基础设施项目中的值得注意的变化。

{% include references.md %}

## 行动项

- **<!--consider-upgrading-to-bitcoin-core-0-18-0-->****考虑升级到 Bitcoin Core 0.18.0：** 上周发布的最新版本 Bitcoin Core 带来了新功能、性能改进和错误修复。有关更多详细信息，请参见下面的 *新闻* 部分。

## 新闻

- **<!--bitcoin-core-0-18-0-released-->****Bitcoin Core 0.18.0 发布：** 这个新的主要版本包含了几个重要的新功能以及许多次要功能和错误修复。该项目的[发布说明][0.18 notes]描述了所有值得注意的变化以及119名合并 PR 的贡献者的名单。我们认为 Newsletter 的读者可能特别感兴趣的一些功能包括：

  - **<!--more-psbt-tools-and-refinements-->***更多的 PSBT 工具和改进：* 前一个主要版本 0.17 引入了对 [BIP174][] 部分签名比特币交易 (PSBTs) 的支持，旨在帮助多个程序或设备协作创建和签署交易，例如多重签名钱包、硬件钱包和冷钱包。0.18 版本在此基础上进行了多个错误修复和改进，包括三个新的 RPC：`joinpsbts` 用于合并多个 PSBT；`analyzepsbt` 告诉用户接下来需要对 PSBT 进行的操作；以及 `utxoupdatepsbt` 用于从节点的 UTXO 集中添加必要信息到 PSBT。此外，0.17 版本发布说明中的 PSBT 部分已被放置在一个[单独的文档][PSBT documentation]中，并扩展以涵盖 0.18 中添加的新功能。

  - **<!--initial-rpc-support-for-output-script-descriptors-->***初步 RPC 支持输出脚本描述符：* 比特币软件需要一种方法来找到区块链上支付给用户钱包的所有交易。如果钱包只支持一种 scriptPubKey 格式——例如，对于 P2PKH，钱包会哈希每个公钥并查找支付给 `0x76a9[钱包公钥的 hash160]88ac` 的任何 scriptPubKey，这很容易。但 Bitcoin Core 的内置钱包目前支持多种不同的 scriptPubKey 格式——P2PK、P2PKH、P2WPKH、裸多重签名、P2SH 承诺和 P2WSH 承诺。这提供了灵活性和向后兼容性，但也带来了较差的可扩展性：钱包在扫描旧的或罕见的脚本时消耗了 CPU 时间，而大多数用户从未使用过这些脚本。

    [输出脚本描述符][Output script descriptors]是 Pieter Wuille 开发的一种新语言，用于简洁地描述 scriptPubKeys 以便钱包准确知道应该扫描什么。最终目标是让 Bitcoin Core 的钱包包含一个描述所有脚本的简单描述符列表——对于大多数用户来说，这个列表可能只有一个描述符，但支持未来升级和高级用例（包括多重签名和硬件签名）的广泛灵活性；请参见 PR [#15487][Bitcoin Core #15487] 和 [#15764][Bitcoin Core #15764] 以了解实现此目标的工作。然而，为了让用户和项目开发人员在对钱包进行根本性更改之前积累使用描述符的经验，0.18 版本更新了现有 RPC 并添加了新的 RPC 来处理描述符。带有描述符支持的现有 RPC 包括 `scantxoutset`、`importmulti`、`getaddressinfo` 和 `listunspent`。新的 RPC 包括 `deriveaddresses` 和 `getdescriptorinfo`。

  - **<!--basic-hardware-signer-support-through-independent-tool-->***通过独立工具提供基本的硬件签名支持：* 虽然与 0.18 分开发布，但仍然是 Bitcoin Core 项目的一部分，[硬件钱包交互][HWI](HWI)工具允许熟悉命令行的用户使用 Bitcoin Core 与几种流行的硬件钱包一起工作。内部，该工具大量使用 PSBT 和输出脚本描述符，使其可以与支持这些接口的其他钱包（例如 [Wasabi 钱包的实验性支持][wasabi hwi]）集成。已经开始了将 HWI 更直接地与主要的 Bitcoin Core 工具集成并为其构建图形界面的工作。

  - **<!--new-wallet-tool-->***新钱包工具：* 在 `bitcoind` 和其他比特币程序旁边是一个新的 `bitcoin-wallet` 工具。这个命令行工具目前仅允许用户创建新钱包或对现有钱包进行一些基本检查，但计划在后续版本中为该工具添加更多功能。

  - **<!--new-architecture-and-new-ubuntu-snap-package-->***新架构和新的 Ubuntu Snap 包：* 这是第一个为 RISC-V CPU 架构的 Linux 提供[预编译二进制文件][bitcoincore.org download]的版本。对于 Ubuntu 和兼容系统的用户，此版本还提供了一个 [Snap 包][Snap package]，取代了以前版本中更新的 PPA。这些 RISC-V 和 Snap 包都包括由多个 Bitcoin Core 贡献者[确定性构建和签名][gitian sigs]的二进制文件。

    {% comment %}<!--
    152 Tests and QA
    74 Docs
    65 wallet
    55 RPCs and other APIs
    51 GUI
    47 Build system
    43 Misc
    17 p2p and network code
    13 Platform support
    9 block and tx handling
    1 mining
    1 consensus
    -->{% endcomment %}

  - **<!--numerous-testing-and-quality-assurance-qa-changes-->***大量的测试和质量保证 (QA) 更改：* [发布说明][0.18 notes]列出了 Bitcoin Core 发布经理认为重要的与 0.18 相关的所有 PR，分为十二类。尽管重要性和分类标准有些任意，并且 PR 数量不一定与所做工作的量相关，但我们认为值得注意的是，发布说明中的“测试和 QA”部分的 PR 数量是其他任何类别的两倍以上。我们不常在这个 Newsletter 中写测试内容——测试很少成为新闻，除非出现问题——所以我们想借此机会提醒读者，测试仍然是 Bitcoin Core 开发的一个活跃且重要的部分。

  - **<!--plan-to-switch-to-bech32-receiving-addresses-by-default-->***计划默认切换到 bech32 接收地址：* 如 [Newsletter #40][] 的*新闻*部分所述，发布说明宣布项目计划在下一个主要版本（0.19，[预计在2019年11月左右发布][0.19 release schedule]）或之后的版本（预计约一年后发布）中默认切换到 bech32 发送地址。较早的日期是当前目标。

- **<!--proposal-for-support-of-schnorr-signatures-and-taproot-script-commitments-->****Schnorr 签名和 Taproot 脚本承诺支持的提案：** Pieter Wuille [发布][tap post]了一个使用 Schnorr 签名的 [Taproot BIP 提案][taproot]和一个用于 Taproot 限制的 [Tapscript BIP 提案][tapscript]。还提供了一个[参考实现][tap ref]，它在大约 520 行代码中（不包括将添加到 [libsecp256k1][] 库中的与 Schnorr 签名相关的更改；请参阅之前发布的 [bip-schnorr][] 以获取更多信息）进行了所有共识更改。

  提案发布的时间太晚，无法让我们在本期 Newsletter 中提供详细描述，尽管我们确实修改了本期 Newsletter 中的其他一些文字以反映提案的发布。我们计划在下周提供完整的报道。

## Bech32 发送支持

*第 8 周，共 24 周。在 2019 年 8 月 24 日 segwit 软分叉锁定的第二周年纪念日之前，Optech Newsletter 将包含这个每周部分，提供帮助开发者和组织实现 bech32 发送支持——支付本机 segwit 地址的能力的信息。这[不需要你自己实现 segwit][bech32 series]，但它确实允许你支付的人访问 segwit 的所有好处。*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/zh/08-upgradability.md %}

## 值得注意的代码和文档更改

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和[比特币改进提案（BIPs）][bips repo]中的值得注意的变化。*

- [Bitcoin Core #15323][] 更新了 `getmempoolinfo` RPC 和 `/rest/mempool/info.json` REST 端点，使它们返回一个 `loaded` 字段，如果保存的内存池已从磁盘完全加载，则为 *true*，如果仍在加载，则为 *false*。

- [Bitcoin Core #15141][] 将对发送无效数据的节点进行禁止的代码从验证代码移到了网络管理代码中。具体来说，当网络代码将新数据传递给验证代码时，验证代码返回无效，它还会返回无效的原因。网络代码可以使用这个原因来确定发送数据的节点是否应被禁止、其他惩罚，或不受惩罚（例如，该节点发送无效数据是因为它运行的是软分叉之前的节点版本，因此不知道新规则）。这不仅在系统代码的层之间创建了更清晰的划分，还为未来改进节点处理代码做好了准备，使其可以根据多种标准更智能地禁止节点。

{% comment %}<!-- This was direct pushed (no PR): https://github.com/lightningd/plugins/commit/187c66a9b1412edced3c51cb53ba568f245a5614 -->{% endcomment %}

- **<!--c-lightning-plugin-repository-->**[C-Lightning 插件库][C-Lightning plugin repository]接收了一个[自动驾驶][cl autopilot]插件，该插件可以帮助用户选择一个或多个通道以开始发送闪电网络支付。该插件基于之前对主 C-Lightning 代码库的 [PR][C-Lightning #1888]。

{% include linkers/issues.md issues="15487,15764,15323,15141,1888" %}
[0.18.0]: https://bitcoincore.org/bin/bitcoin-core-0.18.0/
[snap package]: https://snapcraft.io/bitcoin-core
[0.19 release schedule]: https://github.com/bitcoin/bitcoin/issues/15940
[c-lightning plugin repository]: https://github.com/lightningd/plugins
[cl autopilot]: https://github.com/lightningd/plugins/tree/master/autopilot
[0.18 notes]: https://bitcoincore.org/en/releases/0.18.0/
[psbt documentation]: https://github.com/bitcoin/bitcoin/blob/master/doc/psbt.md
[bitcoincore.org download]: https://bitcoincore.org/en/download/
[gitian sigs]: https://github.com/bitcoin-core/gitian.sigs
[wasabi hwi]: https://github.com/zkSNACKs/WalletWasabi/pull/1341
[tap post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-May/016914.html
[taproot]: https://github.com/sipa/bips/blob/bip-schnorr/bip-taproot.mediawiki
[tapscript]: https://github.com/sipa/bips/blob/bip-schnorr/bip-tapscript.mediawiki
[tap ref]: https://github.com/sipa/bitcoin/commits/taproot
[bech32 series]: /zh/bech32-sending-support/
[newsletter #40]: /zh/newsletters/2019/04/02/#bitcoin-core-schedules-switch-to-default-bech32-receiving-addresses
[output script descriptors]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
[hwi]: https://github.com/bitcoin-core/HWI
