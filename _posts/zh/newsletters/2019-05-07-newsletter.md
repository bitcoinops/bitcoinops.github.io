---
title: 'Bitcoin Optech Newsletter #45'
permalink: /zh/newsletters/2019/05/07/
name: 2019-05-07-newsletter-zh
slug: 2019-05-07-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 重点介绍了最近发布的 Bitcoin Core 0.18.0 中的一些变更，简要提及两份提案中的 BIP，说明了 bech32 地址为何能与预期的协议改进向前兼容，并总结了热门比特币基础设施项目中值得注意的变更。

{% include references.md %}

## 行动项

- **<!--consider-upgrading-to-bitcoin-core-0-18-0-->****考虑升级到 Bitcoin Core 0.18.0：** 上周发布的 Bitcoin Core 最新版本带来了新功能、性能改进与错误修复。详情见下文的*新闻*栏目。

## 新闻

- **<!--bitcoin-core-0-18-0-released-->****Bitcoin Core 0.18.0 发布：** 这个新的主要版本包含若干重要的新功能，以及许多次要功能和错误修复。该项目的[发布说明][0.18 notes]描述了所有值得注意的变更，还列出了 119 位通过已合并 PR 为本版本做出贡献的人。我们认为本刊读者可能特别感兴趣的功能包括：

  - **<!--more-psbt-tools-and-refinements-->***更丰富的 PSBT 工具与改进：* 前一个主要版本 0.17 引入了对 [BIP174][] 部分签名比特币交易（PSBT）的支持，旨在帮助多个程序或设备协作创建和签名交易，例如多重签名钱包、硬件钱包和冷钱包。0.18 版本在此基础上做了多处错误修复和改进，包括三个新的 RPC：`joinpsbts` 用于合并多个 PSBT；`analyzepsbt` 告诉用户接下来需要对 PSBT 做什么；`utxoupdatepsbt` 用于从节点的 UTXO 集向 PSBT 补充必要信息。此外，0.17 版本发布说明中的 PSBT 部分已移入一份[单独的文档][PSBT documentation]，并扩充以涵盖 0.18 新增的功能。

  - **<!--initial-rpc-support-for-output-script-descriptors-->***对输出脚本描述符的初步 RPC 支持：* 比特币软件需要一种方法，找出区块链上所有向用户钱包付款的交易。如果钱包只支持一种 scriptPubKey 格式，这很容易——例如对 P2PKH，钱包只需对每个公钥做哈希，再查找是否有 scriptPubKey 等于 `0x76a9[钱包公钥的 hash160]88ac`。但 Bitcoin Core 的内置钱包目前支持多种不同的 scriptPubKey 格式——P2PK、P2PKH、P2WPKH、裸多重签名、P2SH 承诺和 P2WSH 承诺。这带来了灵活性和向后兼容性，代价却是可扩展性不佳：钱包要耗费 CPU 时间去扫描那些又老又少见的脚本，而大多数用户根本用不到它们。

    [输出脚本描述符][Output script descriptors]是 Pieter Wuille 开发的一种新语言，用于简洁地描述 scriptPubKey，让钱包确切知道该扫描什么。最终目标是让 Bitcoin Core 的钱包持有一份描述其全部脚本的简单描述符列表——对大多数用户来说，这个列表可能短到只有一个描述符，同时又为未来的升级和高级用例（包括多重签名和硬件签名）保留足够的灵活性；朝这一目标推进的工作见 PR [#15487][Bitcoin Core #15487] 和 [#15764][Bitcoin Core #15764]。不过，为了让用户和项目开发者在钱包发生根本性改动之前先积累使用描述符的经验，0.18 版本更新了现有 RPC，并新增了处理描述符的 RPC。获得描述符支持的现有 RPC 包括 `scantxoutset`、`importmulti`、`getaddressinfo` 和 `listunspent`；新增的 RPC 包括 `deriveaddresses` 和 `getdescriptorinfo`。

  - **<!--basic-hardware-signer-support-through-independent-tool-->***通过独立工具提供基本的硬件签名支持：* [硬件钱包交互][HWI]（HWI）工具虽然与 0.18 分开单独发布，但仍属于 Bitcoin Core 项目。它让习惯命令行的用户可以把 Bitcoin Core 与几种流行的硬件钱包配合使用。在内部，该工具大量使用 PSBT 和输出脚本描述符，因此可以与支持这些接口的其他钱包集成（例如 [Wasabi 钱包的实验性支持][wasabi hwi]）。把 HWI 更直接地集成进 Bitcoin Core 主要工具、以及为它构建图形界面的工作，已经启动。

  - **<!--new-wallet-tool-->***新增的钱包工具：* 除了 `bitcoind` 和其他比特币程序之外，还多了一个 `bitcoin-wallet` 工具。这个命令行工具目前只允许用户创建新钱包，或对现有钱包做一些基本检查，但计划在后续版本中为它添加更多功能。

  - **<!--new-architecture-and-new-ubuntu-snap-package-->***新架构与新的 Ubuntu Snap 包：* 这是首个为 RISC-V CPU 架构的 Linux 提供[预编译二进制文件][bitcoincore.org download]的版本。对于 Ubuntu 及兼容系统的用户，此版本还提供了 [Snap 包][Snap package]，取代了此前各版本中用于升级的 PPA。RISC-V 与 Snap 两种包中的二进制文件都是确定性构建的，并由多位 Bitcoin Core 贡献者[签名][gitian sigs]。

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

  - **<!--numerous-testing-and-quality-assurance-qa-changes-->***大量测试与质量保证（QA）变更：* [发布说明][0.18 notes]列出了 Bitcoin Core 发布经理认为重要的所有与 0.18 相关的 PR，分为十二类。尽管重要性的判定和分类标准都带有一定主观性，PR 数量也未必与投入的工作量成正比，但我们认为有一点值得注意：发布说明中“测试与 QA”一栏列出的 PR 数量，是其他任何类别的两倍以上。我们不常在本刊中谈及测试——除非出了问题，测试很少成为新闻——所以想借此机会提醒读者：测试始终是 Bitcoin Core 开发中活跃而重要的一部分。

  - **<!--plan-to-switch-to-bech32-receiving-addresses-by-default-->***计划默认改用 bech32 接收地址：* 如 [Newsletter #40][] 的*新闻*栏目所述，发布说明宣布项目打算在下一个主要版本（0.19，[预计 2019 年 11 月左右发布][0.19 release schedule]）或再下一个版本（预计约一年后）中默认改用 bech32 发送地址。目前的目标是较近的那个日期。

- **<!--proposal-for-support-of-schnorr-signatures-and-taproot-script-commitments-->****关于支持 Schnorr 签名与 Taproot 脚本承诺的提案：** Pieter Wuille 向 Bitcoin-Dev 邮件列表[发帖][tap post]，提出了一份使用 Schnorr 签名的 [Taproot BIP 提案][taproot]，以及一份 [Tapscript BIP 提案][tapscript]——后者是比特币现行 Script 语言的一个小变体，用于配合 Taproot 的花费条件。此外还提供了这两份提案的[参考实现][tap ref]，用大约 520 行代码实现了全部共识变更（不含将加入 [libsecp256k1][] 库的 Schnorr 签名相关改动；详情参见此前发布的 [bip-schnorr][]）。

  这两份提案公布得太晚，我们来不及在本期 Newsletter 中给出详细描述——不过我们确实调整了本期的一些其他文字，以反映提案的发布。我们计划下周做完整报道。

## Bech32 发送支持

*第 8 周，共 24 周。在 2019 年 8 月 24 日 segwit 软分叉锁定满两周年之前，Optech Newsletter 每周都会包含这一栏目，提供信息帮助开发者和组织实现 bech32 发送支持——也就是能够向原生 segwit 地址付款。你[不需要自己实现 segwit][bech32 series]，但你付款的对象却能享受到 segwit 带来的种种好处。*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/zh/08-upgradability.md %}

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和[比特币改进提案（BIPs）][bips repo] 中值得注意的变更。*

- [Bitcoin Core #15323][] 更新了 `getmempoolinfo` RPC 和 `/rest/mempool/info.json` REST 端点，使它们返回 `loaded` 字段：若已保存的内存池已从磁盘完整加载，该字段为 *true*；若仍在加载，则为 *false*。

- [Bitcoin Core #15141][] 把“因对等节点发送无效数据而将其封禁”的代码从验证代码移到了网络管理代码中。具体来说，当网络代码把新数据交给验证代码、而验证代码判定其无效时，验证代码还会返回无效的原因。网络代码可以据此判断：发送该数据的对等节点应当被封禁、受到其他惩罚，还是完全不予惩罚（例如它发送无效数据，只是因为运行的节点版本早于某次软分叉，并不知道新规则）。这既让系统各层代码之间的分工更清晰，也为日后改进对等节点处理逻辑打好了基础，使其能依据多种标准更聪明地决定是否封禁节点。

{% comment %}<!-- This was direct pushed (no PR): https://github.com/lightningd/plugins/commit/187c66a9b1412edced3c51cb53ba568f245a5614 -->{% endcomment %}

- **<!--c-lightning-plugin-repository-->**[C-Lightning 插件库][C-Lightning plugin repository]新增了一个[自动巡航（autopilot）][cl autopilot]插件，可以帮助用户挑选一个或多个通道开通，以便开始发送闪电网络支付。该插件基于早先提交给 C-Lightning 主代码库的 [PR][C-Lightning #1888]。

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
[tap post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-May/016914.html
[taproot]: https://github.com/sipa/bips/blob/bip-schnorr/bip-taproot.mediawiki
[tapscript]: https://github.com/sipa/bips/blob/bip-schnorr/bip-tapscript.mediawiki
[tap ref]: https://github.com/sipa/bitcoin/commits/taproot
[bech32 series]: /zh/bech32-sending-support/
[newsletter #40]: /zh/newsletters/2019/04/02/#bitcoin-core-schedules-switch-to-default-bech32-receiving-addresses
[output script descriptors]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
[hwi]: https://github.com/bitcoin-core/HWI
