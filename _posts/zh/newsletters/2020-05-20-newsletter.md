---
title: 'Bitcoin Optech Newsletter #98'
permalink: /zh/newsletters/2020/05/20/
name: 2020-05-20-newsletter-zh
slug: 2020-05-20-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 转达了一项请求：就修改 BIP341 taproot 交易摘要的提议征集意见；并简要总结了关于一种新的、更简洁的原子交换协议的讨论。此外还有我们的常设栏目：服务和客户端软件的变更、新版本与候选发布，以及热门比特币基础设施软件中值得注意的变更。

## 行动项

- **<!--evaluate-proposed-changes-to-bip341-taproot-transaction-digest-->****评估提议的 BIP341 taproot 交易摘要变更：** 正如[上周的 Newsletter][news97 spk commit] 所述，有人请求 [taproot][topic taproot] 签名对交易中花费的所有 UTXO 的 scriptPubKey 额外作出承诺。Anthony Towns [建议][towns suggestion]了可以如何为这一变更更新 [BIP341][]，Pieter Wuille 也[征询][wuille rfc]是否有人反对。如果你对提议的交易摘要修订有任何疑问或顾虑，我们建议回复邮件列表，或直接联系 BIP341 的作者。

## 新闻

- **<!--two-transaction-cross-chain-atomic-swap-or-same-chain-coinswap-->****双交易跨链原子交换或同链 coinswap：** Ruben Somsen [在邮件列表中发帖][somsen post]并[录制了视频][somsen video]，描述了一种只需两笔交易即可完成无需信任的币交换的做法，称为简洁原子交换（Succinct Atomic Swaps，SAS）。[此前的标准协议][nolan swap]要用四笔交易。Somsen 的 SAS 协议让每一方都持有可随时花费的币——但若对手方企图窃取，可能需要在很短时间内把它们花掉（类似 LN 通道需要被监控）。此外，花费这些币所需的密钥不会存放在用户的 [BIP32][] 分层确定性（HD）钱包里，因此可能需要额外备份。

  该协议的优点在于：它比现有协议占用更少的区块空间；节省交易手续费（一方面因为占用区块空间更少，另一方面因为结算交易可能不那么紧迫）；在跨链交换中只在其中一条链上需要共识强制的时间锁；而且不依赖任何新的安全假设，也不需要对比特币共识做变更。如果 taproot 被采用，这类交换还能更私密、更高效。

  在评论该协议时，Lloyd Fournier [指出][fournier elegance]该协议一个使用三笔交易的简化版本颇具“优雅”。Dmitry Petukhov [发帖][petukhov tla+]介绍了自己用 [TLA<sup>+</sup> 形式化规范语言][tla+ lang]为该协议编写的[规范][sas tla+ spec]，用以帮助检验协议的正确性。

## 服务和客户端软件的变更

*在本月栏目中，我们重点介绍 Bitcoin 钱包与服务的一些有趣更新。*

- **<!--lightning-based-messenger-application-juggernaut-launches-->****基于闪电网络的消息应用 Juggernaut 发布：** 在宣布 Juggernaut 首个版本的[博客文章][juggernaut blog]中，John Cantrell 介绍了其消息和钱包功能如何基于 [keysend 支付][topic spontaneous payments]构建。

- **<!--lightning-loop-using-multipath-payments-->****Lightning Loop 使用多路径支付：** Lightning Labs 的最新[升级][lightning loop mpp blog]现在使用[多路径支付][topic multipath payments]把链上资金转换为 LN 通道内的资金。

- **<!--blockstream-satellite-2-0-supports-initial-block-download-->****Blockstream 卫星 2.0 支持初始区块下载：** Blockstream [概述了 2.0 版本的升级内容][blockstream satellite v2 blog]，包括扩大亚太地区覆盖、增加带宽，以及更新协议，使全节点仅靠卫星信号即可完成初始同步。

- **<!--breez-wallet-enables-spontaneous-payments-->****Breez 钱包支持自发支付：** Breez 钱包的 [0.9 版][breez 0.9]增加了向支持 keysend 的闪电节点发送自发支付的功能。

- **<!--copay-enables-cpfp-for-incoming-transactions-->****Copay 为入账交易启用 CPFP：** 9.3.0 版增加了让用户[用子为父付（CPFP）][copay cpfp]加速一笔入账交易的功能。该功能只有在钱包观察到这笔交易四小时仍未确认后才会启用。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [Bitcoin Core 0.20.0rc2][bitcoin core 0.20.0] 是 Bitcoin Core 下一个大版本的最新候选发布。相比第一个候选发布，它[包含][Bitcoin Core #18973]了若干错误修复和改进。

- [LND 0.10.1-beta.rc1][] 是 LND 下一个维护版本的首个候选发布。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中值得注意的变更。*

*注意：以下提到的 Bitcoin Core 提交针对其 master 开发分支，因此这些变更很可能要到 0.21 版才会发布，也就是在即将发布的 0.20 版之后约六个月。*

- [Bitcoin Core #18877][] 是支持在 P2P 网络上提供[紧凑区块过滤器][topic compact block filters]的第一步，该功能按 [BIP157][] 的规定实现。节点只要用 `-blockfilterindex` 配置参数启用了紧凑区块过滤器索引，现在就能响应 `getcfcheckpt` 请求，返回 `cfcheckpt` 紧凑区块过滤器检查点响应。`getcfheaders` 和 `getcfilters` 消息尚不支持，节点也不会在 version 消息中用 `NODE_COMPACT_FILTERS` 宣告支持 BIP157。

  该功能默认禁用，可通过 `-peerblockfilters` 配置参数启用。

- [Bitcoin Core #18894][] 修复了一个 UI 错误，它影响在 GUI 中同时使用多钱包模式和手动选币（coin control）的用户。该错误在 Bitcoin Core 0.18 的发布说明中被列为[已知问题][coin control bug]。该修复已包含在上一节链接的 Bitcoin Core 0.20 第二个候选发布中。

- [Bitcoin Core #18808][] 让 Bitcoin Core 忽略任何指定了未知数据类型的 P2P 协议 `getdata` 请求。新逻辑还会忽略那些请求了当前连接本不该发送的数据类型的请求，例如在仅中继区块的连接上请求交易。

- [C-Lightning #3614][] 添加了一种名为 `coin_movements` 的新通知类型，由已定稿的账本更新触发。订阅这些通知的客户端会收到已最终解决的 HTLC 和已确认比特币交易的更新，从而能基于自己的 C-Lightning 节点构建一份资金流动的规范账本。详情请参阅其[文档][coin_movement]。

- [Eclair #1395][] 更新了 Eclair 的路由查找方式，把通道余额纳入考虑，并改用 [Yen 算法][Yen's algorithm]。PR 说明称“新算法总能找到更多、也更便宜的路径。路径前缀也更加多样化，这同样是好事（对 MPP 尤其如此）。……而且在我这台机器上，新代码始终快 25%（在查找 3 条路径时）。”

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
