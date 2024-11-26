---
title: 'Bitcoin Optech Newsletter #98'
permalink: /zh/newsletters/2020/05/20/
name: 2020-05-20-newsletter-zh
slug: 2020-05-20-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 传达了关于提议修改 BIP341 Taproot 交易摘要的评论请求，并简要总结了关于一种新的、更简洁的原子交换协议的讨论。此外，还包括我们的常规部分，描述了服务和客户端软件的更改、新版本和候选发布，以及流行的比特币基础设施软件的显著变化。

## 行动项

- **<!--evaluate-proposed-changes-to-bip341-taproot-transaction-digest-->****评估提议的 BIP341 Taproot 交易摘要更改：** 正如[上周的 Newsletter][news97 spk commit] 中所描述的那样，有人请求 [taproot][topic taproot] 签名对交易中花费的所有 UTXO 的 scriptPubKeys 进行额外的承诺。Anthony Towns [建议][towns suggestion]如何为这一更改更新 [BIP341][]，并且 Pieter Wuille [询问][wuille rfc]是否有人对此有任何反对意见。如果您对提议的交易摘要修订有任何疑问或担忧，我们建议回复邮件列表或直接联系 BIP341 的作者。

## 新闻

- **<!--two-transaction-cross-chain-atomic-swap-or-same-chain-coinswap-->****双交易跨链原子交换或同链 coinswap：** Ruben Somsen [在邮件列表中发布][somsen post]并[创建了一个视频][somsen video]，描述了一种无需信任的仅使用两笔交易进行币种交换的过程，称为简洁原子交换（Succinct Atomic Swaps，简称 SAS）。[之前的标准协议][nolan swap]使用了四笔交易。Somsen 的 SAS 协议使每一方都持有可以随时花费的币种——但如果对方企图盗窃，可能需要在短时间内进行花费（类似于闪电网络中的通道需要进行监控）。此外，用于花费这些币种的密钥不会包含在用户的 [BIP32][] 分层确定性（HD）钱包中，因此可能需要额外的备份。

  该协议的优势在于，它比现有协议占用更少的区块空间、节省了交易费用（既通过减少区块空间的占用，又通过可能减少结算交易的紧迫性），它仅在跨链交换的一条链上需要共识强制执行的时间锁，并且它不依赖于任何新的安全假设或比特币共识更改。如果 Taproot 被采用，交换可以变得更加私密和高效。

  在对该协议的评论中，Lloyd Fournier [指出][fournier elegance]了该协议的简化版本的“优雅性”，该版本使用了三笔交易。Dmitry Petukhov [发布][petukhov tla+]了一份使用 [TLA<sup>+</sup> 形式化规范语言][tla+ lang]编写的[规范][sas tla+ spec]，以帮助测试该协议的正确性。

## 服务和客户端软件的更改

*在这个每月的特色部分中，我们重点介绍了比特币钱包和服务的有趣更新。*

- **<!--lightning-based-messenger-application-juggernaut-launches-->****基于闪电网络的消息应用 Juggernaut 启动：** 在一篇[博客文章][juggernaut blog]中，John Cantrell 宣布了 Juggernaut 的首个版本，描述了其消息和钱包功能如何使用 [keysend 支付][topic spontaneous payments]构建。

- **<!--lightning-loop-using-multipath-payments-->****Lightning Loop 使用多路径支付：** 来自 Lightning Labs 的最新[升级][lightning loop mpp blog]现在使用[多路径支付][topic multipath payments]将链上资金转换为闪电网络通道中的资金。

- **<!--blockstream-satellite-2-0-supports-initial-block-download-->****Blockstream 卫星 2.0 支持初始区块下载：** Blockstream [概述了 2.0 版本的升级][blockstream satellite v2 blog]，包括扩展的亚太地区覆盖、额外的带宽和更新的协议，使得完整节点可以仅使用卫星数据完成初始同步。

- **<!--breez-wallet-enables-spontaneous-payments-->****Breez 钱包支持即时支付：** Breez 钱包的 [0.9 版][breez 0.9]增加了向支持 keysend 的闪电节点发送即时支付的功能。

- **<!--copay-enables-cpfp-for-incoming-transactions-->****Copay 支持 CPFP 以加速接收交易：** 9.3.0 版本增加了用户[使用子支付父（CPFP）][copay cpfp] 加速接收交易的功能。该功能仅在钱包观察到交易保持未确认四小时后启用。

## 发布与候选发布

*热门比特币基础设施项目的新发布版本和候选发布。请考虑升级到新版本或帮助测试候选版本。*

- [Bitcoin Core 0.20.0rc2][bitcoin core 0.20.0] 是下一个主要版本 Bitcoin Core 的最新候选发布版本。它[包含][Bitcoin Core #18973]自第一个候选发布版本以来的若干错误修复和改进。

- [LND 0.10.1-beta.rc1][] 是下一个 LND 维护版本的首个候选发布版本。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的更改。*

*注意：以下提到的对 Bitcoin Core 的提交适用于其 master 开发分支，因此这些更改可能要等到 0.21 版本发布，预计在即将发布的 0.20 版本之后大约六个月。*

- [Bitcoin Core #18877][] 是支持在 P2P 网络上提供[致密区块过滤器][topic compact block filters]的第一步，按照 [BIP157][] 的规定。启用了致密区块过滤器索引的节点可以通过 `-blockfilterindex` 配置参数响应 `getcfcheckpt` 请求，并返回 `cfcheckpt` 致密区块过滤器检查点响应。`getcfheaders` 和 `getcfilters` 消息尚不支持，并且节点不会在其版本消息中通过 `NODE_COMPACT_FILTERS` 广告支持 BIP157。

  该功能默认禁用，可以通过 `-peerblockfilters` 配置参数启用。

- [Bitcoin Core #18894][] 修复了一个 UI 错误，该错误影响了在 GUI 中同时使用多钱包模式和手动币控制的用户。该错误在 Bitcoin Core 0.18 版本说明中被描述为一个[已知问题][coin control bug]。此修复包含在上节中链接的第二个 Bitcoin Core 0.20 候选发布版本中。

- [Bitcoin Core #18808][] 使 Bitcoin Core 忽略任何指定未知数据类型的 P2P 协议 `getdata` 请求。新逻辑还将忽略请求在当前连接上不期望发送的数据类型的请求，例如在仅块中继连接上请求交易的请求。

- [C-Lightning #3614][] 添加了一种名为 `coin_movements` 的新通知类型，由最终的分类账更新触发。订阅这些通知的客户端将收到已确定解决的 HTLC 和已确认的比特币交易的更新，从而允许它们通过其 C-Lightning 节点构建币种移动的规范分类账。详情请参阅其[文档][coin_movement]。

- [Eclair #1395][] 更新了 Eclair 使用的路径寻路，以考虑通道余额并使用 [Yen 算法][Yen's algorithm]。PR 说明称“新算法一致地找到更多且更便宜的路径。路径前缀更加多样化，这也很好（特别是对于 MPP）。[...]并且在我的机器上，新代码的一致性能提升了 25%（当查找 3 条路径时）。”

{% include references.md %}
{% include linkers/issues.md issues="18877,18894,3614,18808,1395,18973,18962" %}
[bitcoin core 0.20.0]: https://bitcoincore.org/bin/bitcoin-core-0.20.0
[lnd 0.10.1-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.10.1-beta.rc1
[coin control bug]: https://bitcoincore.org/en/releases/0.18.0/#wallet-gui
[yen's algorithm]: https://en.wikipedia.org/wiki/Yen's_algorithm
[getheaders]: https://btcinformation.org/en/developer-reference#getheaders
[headers]: https://btcinformation.org/en/developer-reference#headers
[headers first sync]: https://btcinformation.org/en/developer-guide#headers-first
[news97 spk commit]: /zh/newsletters/2020/05/13/#request-for-an-additional-taproot-signature-commitment
[towns suggestion]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-May/017813.html
[wuille rfc]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-May/017849.html
[somsen post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-May/017846.html
[somsen video]: https://www.youtube.com/watch?v=TlCxpdNScCA
[petukhov tla+]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-May/017866.html
[tla+ lang]: https://en.wikipedia.org/wiki/TLA%2B
[sas tla+ spec]: https://github.com/dgpv/SASwap_TLAplus_spec
[fournier elegance]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-May/017851.html
[nolan swap]: https://bitcointalk.org/index.php?topic=193281.msg2224949#msg2224949
[juggernaut blog]: https://medium.com/@johncantrell97/announcing-juggernaut-5bda48d34a18
[lightning loop mpp blog]: https://lightning.engineering/posts/2020-05-13-loop-mpp/
[blockstream satellite v2 blog]: https://blockstream.com/2020/05/04/en-announcing-blockstream-satellite-2/
[breez 0.9]: https://github.com/breez/breezmobile/releases/tag/0.9.keysend
[copay cpfp]: https://github.com/bitpay/copay/pull/10746
[coin_movement]: https://github.com/niftynei/lightning/blob/bc803006351a079596b086465246626d3d5e4828/doc/PLUGINS.md#coin_movement
