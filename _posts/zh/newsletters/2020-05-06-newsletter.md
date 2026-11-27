---
title: 'Bitcoin Optech Newsletter #96'
permalink: /zh/newsletters/2020/05/06/
name: 2020-05-06-newsletter-zh
slug: 2020-05-06-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 链接到一场关于用增强版 QR 码传递大型交易的讨论，收录了 Suredbits 关于在企业环境中构建高可用性 LN 节点的实地报告，并简要总结了几场最近转录的演讲与对话。此外还有我们的常设栏目：发布与候选发布，以及热门比特币基础设施软件中值得注意的代码变更。

## 行动项

<!-- $$\frac{50}{2^{\lfloor height/210000 \rfloor}}$$ -->

{:.center style="font-size: 1.5em"}
![Happy halving!](/img/posts/2020-05-halving.png)

## 新闻

- **<!--qr-codes-for-large-transactions-->****大型交易的 QR 码：** QR 码实际最多只能容纳约 3 KB 的数据，这足以容纳典型的用户交易，却远不足以容纳用户通常能发送的体积最大的交易。Riccardo Casatta 和 Christopher Allen 分别向 Bitcoin-Dev 邮件列表发帖（[1][casatta qr]，[2][allen qr]），请求就此展开讨论，希望能最终将一种方法标准化：用可视方式传递[部分签名比特币交易][topic psbt]（PSBT）以及比特币钱包交互中其他可能很大的数据块。请参见 Specter DIY 仓库中的[先前讨论][qr old]，并在 Airgapped Signing 仓库中[继续讨论][qr new]。

## 实地报告：在企业环境中运行 LN 节点

{% include articles/zh/suredbits-enterprise-ln.md %}

## 最近转录的演讲与对话

*[Bitcoin Transcripts][] 是比特币技术演讲与讨论转录稿的汇集地。在这个新的 <!-- TODO: remove "new" next month --> 月度栏目中，我们挑选上个月的部分转录内容重点介绍。*

- **<!--simplicity-next-generation-smart-contracting-->****Simplicity—下一代智能合约** Adam Back 在 Blockstream 的一场线上讲座（webinar）中介绍了 Simplicity，这是一种下一代的低级比特币脚本替代方案，专注于可证明的安全性和表达能力。Back 讨论了如果今天在比特币中启用 Simplicity，开发者可以如何实现诸如 [SIGHASH_NOINPUT][topic sighash_anyprevout] 之类的新功能，而不必进行软分叉。他还给出一段[演示][simplicity demo]，展示现在用 Simplicity 能做什么。（[转录][simplicity xs]，[视频][simplicity vid]，[幻灯片][simplicity slides]）

- **<!--attacking-bitcoin-core-->****攻击 Bitcoin Core** Amiti Uttarwar 在 LA BitDevs 上做了演讲。Uttarwar 讨论了应当按五个目标来评估对比特币点对点层的变更：可靠性、及时性、可访问性、隐私性和可升级性。她讨论了网络分区和 [日食攻击][topic eclipse attacks]的危险，随后解释了为什么仅中继区块的连接和锚节点是有效的缓解措施。（[转录][attacking xs]，[视频][attacking vid]）

- **<!--lnd-v0-10-->****LND v0.10** Laolu Osuntokun、Joost Jager 和 Oliver Gugger 在 Reckless VR 上以虚拟现实的形式做了演讲。Osuntokun 介绍了 LND 最新版本中 Tor 和 RPC 方面的增强，以及一种新的通道功能[锚定输出][topic anchor outputs]（anchor outputs）——它解决了提前数月估算链上手续费的难题。Jager 讨论了[多路径支付][topic multipath payments]的挑战，包括拆分算法、支付分片在不同时间到达时的处理，以及应对多路径支付失败的策略。Gugger 最后讲了用[部分签名比特币交易（PSBT）][topic psbt]为通道注资，以及让这一点成为可能的通道抽象化工作。（[转录][lnd10 xs]，[视频][lnd10 vid]）

- **<!--grokking-bitcoin-->****Grokking Bitcoin** Kalle Rosenbaum 参加了一场比特币开发者聚会，并在 London Bitcoin Devs 上做了演讲。聚会的讨论集中在比特币技术教育的作用、[BIP32][] HD 钱包和软分叉升级。演讲部分，Rosenbaum 用他书中的内容讲解了 2017 年的 segwit 升级如何解决交易可延展性和二次哈希问题。（[聚会转录][grok xs2]，[演讲转录][grok xs1]，[演讲视频][grok vid]，[演讲幻灯片][grok slides]）

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [C-Lightning 0.8.2][c-lightning 0.8.2] 是一个新版本，增加了打开任意大小通道的支持（使用 `--large-channels` 配置参数），提供了用于接收[自发支付][topic spontaneous payments]的 keysend 插件，还包含其他一些新功能和错误修复。此外，无论新手还是有经验的用户，都建议读一读项目新增的 [FAQ][cl faq]。

- [LND 0.10.0-beta][lnd 0.10.0-beta] 是一个大版本发布，增加了发送[多路径支付][topic multipath payments]、用[部分签名比特币交易（PSBT）][topic psbt]通过外部钱包为通道注资、创建大于 0.043 BTC 的发票等能力，还包含其他若干新功能和错误修复。此外，用户不妨读一读新增的[操作安全文档][lnd op safety]。

- [Bitcoin Core 0.20.0rc1][bitcoin core 0.20.0] 是 Bitcoin Core 下一个大版本的候选发布。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Rust-Lightning][rust-lightning repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中值得注意的变更。*

*注意：以下提到的 Bitcoin Core 提交针对其主开发分支，因此这些变更很可能要到 0.21 版才会发布，也就是在即将发布的 0.20 版之后约六个月。*

- [Bitcoin Core #16528][] 允许 `createwallet` RPC 创建一种钱包：它使用[输出脚本描述符][topic descriptors]，只推导该钱包接收支付时实际用到的那些 scriptPubKey。相比旧式钱包的扫描方式，这是重大改进——旧式钱包要为钱包里的每个公钥都推导该钱包支持的每一种脚本类型，才能发现收款；这一做法可追溯到最早的 Bitcoin 0.1 版本，当时就已支持向 P2PK 和 P2PKH 的 scriptPubKey 收款。描述符钱包应当更高效（无需扫描不用的脚本类型）、更容易升级到新的脚本类型（例如 [taproot][topic taproot]），也更便于配合外部工具使用（例如多重签名钱包，或通过[部分签名比特币交易][topic psbt]与 [HWI][topic hwi] 兼容的硬件钱包）。

  默认情况下，描述符钱包使用 BIPs [44][BIP44]、[49][BIP49] 和 [84][BIP84] 所规定的常见 [BIP32][] HD 钱包路径，而不是旧式 Bitcoin Core HD 钱包所用的非标准化全硬化（fully hardened）路径。有一些钱包 RPC 在描述符钱包下不可用，原因要么是它们对描述符没有意义，要么是开发者还在让它们适配新的边界情况。该 PR 在 0.21 开发周期早期就已合并，加上决定把描述符钱包设为非默认选项，新功能在预期发布之前有六个月时间走向成熟。

- [Bitcoin Core #18038][] 降低了钱包重发交易的频率（从大约 30 分钟一次降到大约一天一次），从而提高交易初次广播时的隐私性。以前，监视网络的实体可能在同一节点的这些重发时段里多次看到同一笔交易的广播，进而断定该钱包就是发起者。减少钱包的重发尝试后，交易发起者被识别出来的可能性就更低了。

  为确保新交易即使没有钱包频繁地不加区分地重发也能到达网络，此 PR 还在内存池中增加了一种*未广播*（unbroadcast）交易。未广播交易是指已通过钱包或 RPC 在本地提交、但尚未成功中继给网络中对等节点的交易。这类交易会留在内存池中，每 10–15 分钟重新广播一次，直到某个对等节点发来针对该交易的 `getdata` P2P 消息把交易取走。

- [BIPs #893][] 对 [BIP340][] 中 [schnorr][topic schnorr signatures] 公钥与签名的规范做了多项变更，[BIP341][] 的 [taproot][topic taproot] 规范也做了相关变更。主要变更包括：

  - **<!--alternative-x-only-pubkey-tiebreaker-->***x-only 公钥的替代决胜规则：* 当只知道公钥的 x 坐标时，这改变了该选用公钥的哪个变体，此前已讨论过（参见 [Newsletter #83][news83 alt tiebreaker]）。

  - **<!--updated-nonce-generation-recommendations-->***更新随机数生成建议：* 生成签名随机数的推荐方法已更新，以防出现特定实现中的漏洞（参见 Newsletter [#83][news83 precomputed] 和 [#91][news91 power analysis] 的先前讨论）。

  - **<!--updated-tagged-hashes-->***更新带标签的哈希：* schnorr 签名中加在哈希函数输入前面的标签（tag）已更新，目的是刻意破坏与旧草案规范的兼容性。否则，为旧代码编写的库有时会生成在新代码下有效的签名，有时又不会，从而造成混乱。这一点也在 [Newsletter #83][news83 alt tiebreaker] 中提过。

- [BIPs #903][] 简化了 [BIP322][] 中[通用签名消息][topic generic signmessage]的规范，与此前的提议一致（参见 [Newsletter #91][news91 bip322 update]），主要删除了那些允许在同一份证明中为多个脚本（地址）签署同一条消息的细节。

- [BIPs #900][] 更新了 [BIP325][] 中 [signet][topic signet] 的规范，使所有 signet 使用同一个硬编码的创世区块（区块 0），同时让不同的 signet 可以通过各自的[网络魔数][network magic]（network magic，即消息起始字节）加以区分。在更新后的协议中，消息起始字节是网络挑战脚本（用于判定某个区块的签名是否有效的脚本）哈希摘要的前四个字节。这项变更的动机是简化一类应用的开发：它们想使用多个 signet，却必须调用为其支持的网络硬编码了创世区块的库。

{% include references.md %}
{% include linkers/issues.md issues="16528,18038,893,903,900" %}
[bitcoin core 0.20.0]: https://bitcoincore.org/bin/bitcoin-core-0.20.0
[lnd 0.10.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.10.0-beta
[c-lightning 0.8.2]: https://github.com/ElementsProject/lightning/releases/tag/v0.8.2
[news83 alttiebreaker]: /zh/newsletters/2020/02/05/#alternative-x-only-pubkey-tiebreaker
[dorier signet]: https://github.com/bitcoin/bitcoin/pull/16411#issuecomment-577999888
[cl faq]: https://github.com/ElementsProject/lightning/blob/master/doc/FAQ.md
[news91 bip322 update]: /zh/newsletters/2020/04/01/#proposed-update-to-bip322-generic-signmessage
[casatta qr]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-April/017794.html
[allen qr]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-April/017795.html
[qr old]: https://github.com/cryptoadvance/specter-diy/issues/57
[qr new]: https://github.com/BlockchainCommons/AirgappedSigning/issues/4
[lnd op safety]: https://github.com/lightningnetwork/lnd/blob/master/docs/safety.md
[news83 alt tiebreaker]: /zh/newsletters/2020/02/05/#alternative-x-only-pubkey-tiebreaker
[news83 precomputed]: /zh/newsletters/2020/02/05/#safety-concerns-related-to-precomputed-public-keys-used-with-schnorr-signatures
[news91 power analysis]: /zh/newsletters/2020/04/01/#mitigating-differential-power-analysis-in-schnorr-signatures
[network magic]: https://btcinformation.org/en/glossary/start-string
[bitcoin transcripts]: https://twitter.com/btctranscripts
[simplicity demo]: https://asciinema.org/a/rhIsJBixoB3k8yuFQQr2UGAQN
[simplicity xs]: https://diyhpl.us/wiki/transcripts/blockstream-webinars/2020-04-08-adam-back-simplicity/
[simplicity vid]: https://www.youtube.com/watch?v=RZNCk-nyx_A
[simplicity slides]: https://docsend.com/view/svs27jr
[attacking xs]: https://diyhpl.us/wiki/transcripts/la-bitdevs/2020-04-16-amiti-uttarwar-attacking-bitcoin-core/
[attacking vid]: https://www.youtube.com/watch?v=8TaY730YlMg
[lnd10 xs]: https://diyhpl.us/wiki/transcripts/vr-bitcoin/2020-04-18-laolu-joost-oliver-lnd0.10/
[lnd10 vid]: https://www.youtube.com/watch?v=h34fUGuDjMg
[grok xs1]: https://diyhpl.us/wiki/transcripts/london-bitcoin-devs/2020-04-29-kalle-rosenbaum-grokking-bitcoin/
[grok vid]: https://www.youtube.com/watch?v=6tHnYyaw0qw
[grok slides]: http://rosenbaum.se/ldnbitcoindev/drawing.sozi.html
[grok xs2]: https://diyhpl.us/wiki/transcripts/london-bitcoin-devs/2020-04-22-socratic-seminar/
