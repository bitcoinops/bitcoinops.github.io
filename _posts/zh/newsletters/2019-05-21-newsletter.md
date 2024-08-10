---
title: 'Bitcoin Optech Newsletter #47'
permalink: /zh/newsletters/2019/05/21/
name: 2019-05-21-newsletter-zh
slug: 2019-05-21-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了 bip-anyprevout 软分叉提案，总结了 Magical Crypto Friends 会议上的一些技术演讲，并包含了我们关于 bech32 发送支持和值得注意的比特币基础设施项目变更的常规部分。

{% include references.md %}

## 行动项

*本周无。*

## 新闻

- **<!--proposed-anyprevout-sighash-modes-->****提议的 anyprevout 签名哈希模式：** 两周前，Anthony Towns 在 Bitcoin-Dev 和 Lightning-Dev 邮件列表上[发布了][email bip-anyprevout]一个提议的 BIP 供大家考虑。这个想法，[bip-anyprevout][]，提供了两种新的签名哈希（sighash）模式，使签名能够对所花费资金的详细信息进行更少的承诺，而不是默认的 [bip-taproot][] 和 [bip-tapscript][] sighash 模式。这使得之前由 [BIP118][] 描述的功能得以实现，并进行了一些修改，使其能够与 Taproot 一起工作，并降低误用的风险。其中一种新的 sighash 模式与 LN 的 [Eltoo][] 层直接兼容，只需对 Taproot 进行修改并添加一个*陪护签名*（稍后描述）。另一种 sighash 模式比 Eltoo 所需的更多数据进行承诺，这可能使其在 Eltoo 中的非典型承诺或其他协议中有用。

  该提案相对于 BIP118 noinput 的一个显著优势是，它可以使用 Taproot 协作消费，允许 LN 通道或其他合同协议的两个或多个参与方在不透露任何合同条款（包括使用 anyprevout）的情况下选择性地花费他们的资金。

  为了快速了解 anyprevout，我们在基于 Eltoo 的两方 LN 通道的背景下考虑它。提醒一下，Eltoo 的关键特性是通道中的每次余额变更（状态更新）都可以由*任何*后续状态更新来花费，因此不像当前的基于惩罚的 LN 通道那样存在将旧状态发布到区块链上的风险。Eltoo 称这种能力为*重新绑定*，BIP118 提议通过允许签名跳过对支出交易输入部分的承诺来实现重新绑定——允许任何人修改交易的该部分，以绑定他们知道的任何后续状态。

  bip-anyprevout 定义的 `SIGHASH_ANYPREVOUTANYSCRIPT` 模式（任何先前输出，任何脚本）与 BIP118 noinput 类似，但有以下更改。要使用 anyprevoutanyscript，比较签名的公钥需要使用特殊前缀（0x00 或 0x01；不要与 [bip-taproot 的][bip-taproot]输出密钥使用相同前缀混淆）。此外，正在评估的脚本需要至少包含一个不使用 anyprevoutanyscript 或稍后描述的其他新 sighash 模式的签名。这个非 anyprevout 签名称为*陪护签名*，因为在合理的假设下，它可以防止 anyprevout 签名被误用。（参见 [Newsletter #34][] 了解关于重放问题的详细信息。）使用正确的前缀和陪护签名，anyprevoutanyscript 允许签名跳过对输出标识符（输出点）、先前输出的 scriptPubKey 和执行的 taproot 叶哈希（tapleaf）的承诺。签名承诺的交易摘要仍然包括有关前置输出的一些详细信息，例如其比特币值。

  此外，bip-anyprevout 还定义了另一种 sighash 模式：`SIGHASH_ANYPREVOUT`，它也需要相同的特殊公钥前缀和陪护签名，但它在签名中包含前置输出的 scriptPubKey 和 tapleaf 哈希。虽然 anyprevoutanyscript 允许 Eltoo 式重新绑定，其中任何后续状态可以绑定到任何早期状态（但早期状态不能绑定到后续状态），但在替代协议（以及 Eltoo 协议中的某些时间点）中，参与者可能希望确保状态 *n* 只能绑定到状态 *n-1*，而不是任何其他状态。

  该提案已经开始在邮件列表上[接收反馈][anyprevout list]，因此我们将在后续的 Newsletter 中提供总结任何重要讨论的更新。

- **<!--talks-of-technical-interest-at-magical-crypto-friends-conference-->****Magical Crypto Friends 会议上的技术兴趣演讲：** Bryan Bishop 提供了 MCF 会议上约十二场演讲和小组讨论的[文字记录][mcf transcripts]，会议组织者也上传了大部分[视频][mcf vids]。虽然这些演讲中只有一场描述了任何具体的新进展，但其中几场讨论了诸如保密交易、taproot、schnorr 和其他与比特币相关的技术的细节和影响。我们发现以下演讲特别有趣：

  - **<!--talk-->**Andrew Poelstra 关于加密货币中使用的加密技术的[演讲][mcf andytoshi]。特别是，他关注了构建系统的困难，这些系统中*每个*方面都需要正确完成才能抵御攻击。

  - **<!--panel-->**Rodolfo Novak、Elaine Ou、Adam Back 和 Richard Myers 关于在没有直接访问互联网的情况下使用比特币的[小组讨论][mcf nonet]。讨论主题包括基于卫星的区块传播、网状网络、业余无线电和物理传输数据（sneakernets），以及它们如何使比特币对于当前用户更加稳健，对于网络访问有限的地区用户更加可访问。我们发现关于比特币数据中继安全性的附带讨论特别有趣——简而言之，比特币协议已经设计为无信任地接受来自随机节点的数据，因此非网络中继不一定会改变信任模型。

  - **<!--conversation-->**Will O'Beirne、Lisa Neigut、Alex Bosworth 之间在 Leigh Cuen 主持下关于 LN 未来的[对话][mcf future ln]，主要讨论了当前开发工作围绕 LN 1.1 规范的短期和中期结论。这个讨论中没有任何炒作的说法，只是简单描述了 LN 预计将如何改进，以使用户和企业更容易采用。

## Bech32 发送支持

*在 [bech32 系列][bech32 series]中，关于允许您支付的人访问 segwit 的所有好处的第 10 周。*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/zh/10-snooze-lose.md %}

## 值得注意的代码和文档更改

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和 [Bitcoin Improvement Proposals (BIPs)][bips repo] 中的值得注意的更改。*

- [Bitcoin Core #15006][] 扩展了 `createwallet` RPC，增加了一个新的 `passphrase` 参数，允许默认加密创建新钱包。现有钱包仍然可以通过 `encryptwallet` RPC 转换为加密。

- [Bitcoin Core #15870][] 更改了 `importwallet`、`importpubkey`、`importaddress` 和 `importprivkey` RPC 与修剪的交互方式。之前如果启用了修剪，它们会失败。然而，修剪可以配置为手动操作（`prune=1`）或设置为大于当前区块链大小的值（例如 `prune=450000`），从而提供启用修剪但所有区块可能仍然存在的情况。通过此合并，只有当区块确实因修剪而丢失时，这些调用才会失败。或者，用户可以调用 `importmulti` RPC，只要数据的创建时间（时间戳）在尚未修剪的区块范围内，它将允许导入任何密钥或其他数据，即使区块已被修剪。

- [Bitcoin Core #14802][] 通过使用 chainstate 撤销数据将 `getblockstats` RPC 的速度提高了 100 多倍（由 Optech 测量）——这是在区块链重组期间用于回滚分类账到以前状态的数据。这也消除了 RPC 对交易索引（txindex）的依赖。

- [Bitcoin Core #14047][] 和 [Bitcoin Core #15512][] 添加了加密 [v2 传输协议][v2 transport protocol]所需的功能，描述见 [Newsletter #39][]。这只是所需整体更改的一小部分；详情请参阅主要 [PR #14032][Bitcoin Core #14032]。

- [C-Lightning #2631][] 扩展了 pylightning 实用程序，增加了三个新方法：`autoclean` 配置自动删除过期发票（默认在过期一天后删除）。`check` 确定命令是否有效而不运行它。`setchannelfee` 允许设置路由付款的费用，可以是添加到任何路由付款的基础费用，也可以是按付款金额比例应用的百分比费用。

- [C-Lightning #2627][] 扩展了 pylightning，增加了 `deleteinvoice` 方法，删除指定时间之前过期的所有发票。


{% include linkers/issues.md issues="15006,15870,14802,14047,2631,2627,15512,14032" %}
[mcf transcripts]: https://diyhpl.us/wiki/transcripts/magicalcryptoconference/2019/
[v2 transport protocol]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-March/016806.html
[anyprevout list]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-May/001992.html
[mcf vids]: https://www.youtube.com/playlist?list=PLWqtMh0tDnEGBHDS8CalOpkVZhlIgRlAC
[mcf andytoshi]: https://diyhpl.us/wiki/transcripts/magicalcryptoconference/2019/crypto-in-cryptocurrency/
[mcf nonet]: https://diyhpl.us/wiki/transcripts/magicalcryptoconference/2019/bitcoin-without-internet/
[mcf future ln]: https://diyhpl.us/wiki/transcripts/magicalcryptoconference/2019/ln-present-and-future-panel/
[email bip-anyprevout]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-May/016929.html
[bech32 series]: /zh/bech32-sending-support/
[newsletter #34]: /zh/newsletters/2019/02/19/#discussion-about-tagging-outputs-to-enable-restricted-features-on-spending
[newsletter #39]: /zh/newsletters/2019/03/26/#version-2-p2p-transport-proposal
[eltoo]: https://blockstream.com/eltoo.pdf
