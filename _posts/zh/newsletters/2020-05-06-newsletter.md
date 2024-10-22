---
title: 'Bitcoin Optech Newsletter #96'
permalink: /zh/newsletters/2020/05/06/
name: 2020-05-06-newsletter-zh
slug: 2020-05-06-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 链接到了一次关于使用增强版 QR 码来传递大额交易的讨论，包含了 Suredbits 提供的关于构建高可用性闪电网络节点的现场报告，并简要总结了几场最近转录的演讲和对话。此外，还包含了我们常规的发布、候选发布以及流行的比特币基础设施软件中值得注意的代码更改部分。

## 行动项

<!-- $$\frac{50}{2^{\lfloor height/210000 \rfloor}}$$ -->

{:.center style="font-size: 1.5em"}
![Happy halving!](/img/posts/2020-05-halving.png)

## 新闻

- **<!--qr-codes-for-large-transactions-->****大额交易的 QR 码：** QR 码的实际容量上限约为 3 KB，这足以容纳典型的用户交易，但远不足以容纳用户通常可以发送的最大交易。Riccardo Casatta 和 Christopher Allen 分别在 Bitcoin-Dev 邮件列表中发帖（[1][casatta qr]，[2][allen qr]），请求讨论以期望规范化一种方法，用于以视觉方式传递[部分签名比特币交易（PSBTs）][topic psbt]以及其他潜在的大型数据块，涉及比特币钱包的交互。请参见 Specter DIY 仓库中的[先前讨论][qr old]，并在 Airgapped Signing 仓库中[继续讨论][qr new]。

## 实地报告：在企业环境中运行闪电网络节点

{% include articles/zh/suredbits-enterprise-ln.md %}

## 最近转录的演讲和对话

*[Bitcoin Transcripts][] 是一个收录比特币技术演讲和讨论的转录库。在这个新的 <!-- TODO: remove "new" next month --> 每月特辑中，我们重点介绍了上个月的部分转录内容。*

- **<!--simplicity-next-generation-smart-contracting-->****Simplicity—下一代智能合约** Adam Back 在 Blockstream 的一个网络研讨会上介绍了 Simplicity，这是一种下一代的低级比特币脚本替代方案，专注于可证明的安全性和表达能力。Back 讨论了如果今天在比特币中启用 Simplicity，开发者可以如何实现诸如 [SIGHASH_NOINPUT][topic sighash_anyprevout] 之类的新功能，而不必进行软分叉。他还展示了一个[演示][simplicity demo]，展示了当前使用 Simplicity 可以实现的功能。（[转录][simplicity xs]，[视频][simplicity vid]，[幻灯片][simplicity slides]）

- **<!--attacking-bitcoin-core-->****攻击 Bitcoin Core** Amiti Uttarwar 在 LA BitDevs 上发表了演讲。Uttarwar 讨论了如何根据五个目标来评估对比特币对等层的更改：可靠性、及时性、可访问性、隐私性和可升级性。她讨论了网络分区和 [eclipse 攻击][topic eclipse attacks]的危险性，并解释了为什么仅限区块中继的连接和锚节点是有效的缓解措施。（[转录][attacking xs]，[视频][attacking vid]）

- **<!--lnd-v0-10-->****LND v0.10** Laolu Osuntokun、Joost Jager 和 Oliver Gugger 在 Reckless VR 上进行了虚拟现实演讲。Osuntokun 介绍了 LND 最新版本中的 Tor 和 RPC 增强功能，以及一种新的通道功能[锚输出][topic anchor outputs]，该功能解决了提前数月估算链上费用的挑战。Jager 讨论了[多路径支付][topic multipath payments]的挑战，包括拆分算法、当支付的分片在不同时间到达时的处理，以及处理多路径支付失败的策略。Gugger 最后讨论了使用[部分签名比特币交易（PSBT）][topic psbt]进行通道资金筹集以及使其成为可能的通道抽象化工作。（[转录][lnd10 xs]，[视频][lnd10 vid]）

- **<!--grokking-bitcoin-->****掌握比特币** Kalle Rosenbaum 参加了一次比特币开发者见面会，并在 London Bitcoin Devs 上发表了演讲。见面会的讨论重点是比特币技术教育的作用、[BIP32][] HD 钱包和软分叉升级。在演讲中，Rosenbaum 使用其书中的内容讨论了 2017 年的 SegWit 升级如何解决了交易延展性和二次哈希的问题。（[见面会转录][grok xs2]，[演讲转录][grok xs1]，[演讲视频][grok vid]，[演讲幻灯片][grok slides]）

## 发布与候选发布

*流行的比特币基础设施项目的新版本发布与候选发布。请考虑升级到新版本或帮助测试候选发布。*

- [C-Lightning 0.8.2][c-lightning 0.8.2] 是一个新版本发布，增加了支持打开任意大小的通道（使用 `--large-channels` 配置参数），提供了一个接收[自发支付][topic spontaneous payments]的 keysend 插件，并包含其他一些新功能和错误修复。此外，建议无论是新手还是有经验的用户都阅读该项目的新 [FAQ][cl faq]。

- [LND 0.10.0-beta][lnd 0.10.0-beta] 是一个主要版本发布，增加了发送[多路径支付][topic multipath payments]、通过[部分签名比特币交易（PSBT）][topic psbt]使用外部钱包进行通道资金筹集的支持、创建大于 0.043 BTC 的发票的能力，以及其他几个新功能和错误修复。此外，用户可能希望阅读新的[操作安全文档][lnd op safety]。

- [Bitcoin Core 0.20.0rc1][bitcoin core 0.20.0] 是下一个 Bitcoin Core 主要版本的候选发布。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Rust-Lightning][rust-lightning repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的更改。*

*注意：以下提到的 Bitcoin Core 提交适用于其主开发分支，因此这些更改可能要到 0.21 版本才会发布，约在即将发布的 0.20 版本之后六个月。*

- [Bitcoin Core #16528][] 允许 `createwallet` RPC 创建一个使用[输出脚本描述符][topic descriptors]来推导钱包用于接收支付的特定 scriptPubKey 的钱包。这比旧钱包扫描所有类型脚本的方式有了重大改进，旧钱包需要为每个公钥推导钱包处理的每种脚本类型——这一技术可以追溯到最初的 Bitcoin 0.1 版本支持接收 P2PK 和 P2PKH scriptPubKey。描述符钱包应该更高效（因为它们不需要扫描未使用的脚本类型）、更容易升级到新类型的脚本（例如 [taproot][topic taproot]），并且更容易与外部工具一起使用（例如通过[部分签名比特币交易][topic psbt]支持的多重签名钱包或 [HWI][topic hwi] 兼容的硬件钱包）。

  默认情况下，描述符钱包使用 BIPs [44][BIP44]、[49][BIP49] 和 [84][BIP84] 指定的流行 [BIP32][] HD 钱包路径，而不是旧 Bitcoin Core HD 钱包中使用的非标准的全加密路径。由于描述符的一些特性或开发人员仍在适应新的边缘情况，某些钱包 RPC 无法与描述符钱包一起使用。该 PR 在 0.21 开发周期的早期合并，并决定将描述符钱包设为非默认选项，这将使新功能在预期发布前有六个月的成熟时间。

- [Bitcoin Core #18038][] 通过减少钱包尝试重新发送交易的频率（从大约 30 分钟到大约一天一次）来提高最初广播交易的隐私性。以前，监控网络的实体可能会在这些重新发送期间看到同一交易的多次广播，并得出钱包是发起者的结论。通过减少钱包重新发送尝试的频率，交易的发起者被识别的机会更少。

  为确保新交易即使在没有钱包频繁不加选择的重新广播的情况下也能到达网络，此 PR 还增加了一种在内存池中 _未广播_ 的交易。未广播的交易是通过钱包或 RPC 本地提交但尚未成功中继到网络节点的交易。这些未广播的交易将保留在内存池中，并每 10-15 分钟重新广播一次，直到某个节点通过发送 `getdata` P2P 消息来获取该交易。

- [BIPs #893][] 对 [BIP340][] 规范的 [schnorr][topic schnorr signatures] 公钥和签名进行了多项更改，并对 [BIP341][] 的 [taproot][topic taproot] 规范进行了相关更改。主要更改包括：

  - **<!--alternative-x-only-pubkey-tiebreaker-->***x-only 公钥的替代决策规则：* 这改变了当仅知道公钥的 x 坐标时使用的公钥变体，如之前讨论的那样（参见 [Newsletter #83][news83 alt tiebreaker]）。

  - **<!--updated-nonce-generation-recommendations-->***更新的随机数生成建议：* 建议用于生成签名随机数的方法已更新，以防止特定实现的漏洞（参见 Newsletter [#83][news83 precomputed] 和 [#91][news91 power analysis] 的先前讨论）。

  - **<!--updated-tagged-hashes-->***更新的标记哈希：* 为 schnorr 签名前缀到哈希函数输入的标签已更新，以故意破坏与旧草案规范的兼容性。否则，为旧代码编写的库可能有时会生成在新代码下有效的签名，有时又不会，从而导致混淆。这也在 [Newsletter #83][news83 alt tiebreaker] 中提到。

- [BIPs #903][] 简化了 [BIP322][] 规范的[通用签名消息][topic generic signmessage]，如先前提议的那样（参见 [Newsletter #91][news91 bip322 update]），此更改主要是删除允许在同一证明中为多个脚本（地址）签名的详细信息。

- [BIPs #900][] 更新了 [BIP325][] 规范的 [signet][topic signet]，使所有 signet 使用相同的硬编码创世区块（区块 0），但独立的 signet 可以通过其[网络魔法值][network magic]（消息开始字节）区分。根据更新后的协议，消息开始字节是网络的挑战脚本（用于确定区块是否具有有效签名的脚本）哈希摘要的前四个字节。更改的动机是简化希望使用多个 signet 的应用程序的开发，这些应用程序需要调用硬编码支持网络创世区块的库。

{% include references.md %}
{% include linkers/issues.md issues="16528,18038,893,903,900" %}
[bitcoin core 0.20.0]: https://bitcoincore.org/bin/bitcoin-core-0.20.0
[lnd 0.10.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.10.0-beta
[c-lightning 0.8.2]: https://github.com/ElementsProject/lightning/releases/tag/v0.8.2
[news83 alttiebreaker]: /zh/newsletters/2020/02/05/#alternative-x-only-pubkey-tiebreaker
[dorier signet]: https://github.com/bitcoin/bitcoin/pull/16411#issuecomment-577999888
[cl faq]: https://github.com/ElementsProject/lightning/blob/master/doc/FAQ.md
[news91 bip322 update]: /en/newsletters/2020/04/01/#proposed-update-to-bip322-generic-signmessage
[casatta qr]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-April/017794.html
[allen qr]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-April/017795.html
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
