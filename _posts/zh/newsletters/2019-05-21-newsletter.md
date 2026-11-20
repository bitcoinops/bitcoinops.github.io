---
title: 'Bitcoin Optech Newsletter #47'
permalink: /zh/newsletters/2019/05/21/
name: 2019-05-21-newsletter-zh
slug: 2019-05-21-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 介绍 bip-anyprevout 软分叉提案，概述 Magical Crypto Friends 会议上几场技术演讲的内容，并照例奉上 bech32 发送支持与热门比特币基础设施项目值得注意的变更两个常规章节。

{% include references.md %}

## 行动项

*本周无。*

## 新闻

- **<!--proposed-anyprevout-sighash-modes-->****提议的 anyprevout 签名哈希模式：** 两周前，Anthony Towns 在 Bitcoin-Dev 和 Lightning-Dev 邮件列表上[发帖][email bip-anyprevout]，提出一份 BIP 供大家讨论。这个想法就是 [bip-anyprevout][]：它提供两种新的签名哈希（sighash）模式，让签名承诺的、关于所花费资金的细节比 [bip-taproot][] 和 [bip-tapscript][] 默认的 sighash 模式更少。这样，[BIP118][] 此前描述的功能就能以改良后的形式实现，既能与 Taproot 配合，又降低了意外误用的风险。两种新模式中的第一种与为 LN 提出的 [Eltoo][] 层直接兼容，只需为适配 Taproot 稍作修改，再加一个*陪护签名（chaperone signature）*（后文介绍）。第二种 sighash 模式承诺的数据比 Eltoo 所需的更多，因此它可能适用于 Eltoo 中那些非典型的承诺，也可能用于其他协议。

  相比 BIP118 noinput，这个提案的一个显著优势是它能用上 Taproot 的协作花费，让 LN 通道或其他合约协议的两方或多方可以选择花掉自己的资金，而不泄露任何合约条款（包括“曾经用过 anyprevout”这一事实）。

  为了快速了解 anyprevout，我们以基于 Eltoo 的两方 LN 通道为例。提醒一下，Eltoo 的关键特性是通道中每一次余额变更（状态更新）都能被*任何*更晚的状态更新花掉，因此不存在当前这种基于惩罚的 LN 通道里把旧状态发布到区块链上的风险。Eltoo 把这种能力称为*重新绑定（rebinding）*，BIP118 则提议让签名跳过对花费交易输入部分的承诺来实现重新绑定——这样任何人都能改动交易的这一部分，把自己知道的任一更晚状态绑定上去。

  bip-anyprevout 定义的 `SIGHASH_ANYPREVOUTANYSCRIPT` 模式（任意前序输出、任意脚本）与 BIP118 noinput 类似，但有下述改动。要用 anyprevoutanyscript，用来与签名比对的那个公钥必须带上特殊前缀（0x00 或 0x01；别把它与 [bip-taproot 的][bip-taproot]输出密钥搞混——后者在另一种场景下也用了相同的前缀）。此外，正在求值的脚本中至少要有一个签名不使用 anyprevoutanyscript，也不使用后面要讲的另一种新 sighash 模式。这个非 anyprevout 的签名称为*陪护签名*，因为在合理的假设下，它能防止 anyprevout 签名被误用。（关于重放问题的细节，见 [Newsletter #34][]。）有了正确的前缀和陪护签名，anyprevoutanyscript 就能让签名跳过对所花费输出的标识（即 outpoint）、该前序输出的 scriptPubKey，以及实际执行的 taproot 叶子哈希（tapleaf）的承诺。签名承诺的交易摘要中仍然包含前序输出的一些细节，例如它的比特币金额。

  此外，bip-anyprevout 还定义了另一种 sighash 模式 `SIGHASH_ANYPREVOUT`：它同样要求特殊公钥前缀和陪护签名，但会把前序输出的 scriptPubKey 和 tapleaf 哈希纳入签名承诺的范围。anyprevoutanyscript 允许 Eltoo 式的重新绑定，即任何更晚状态都能绑定到任何更早状态（但更早状态不能绑定到更晚状态）；而可能存在一些其他协议（以及 Eltoo 协议中的某些时段），参与者希望确保状态 *n* 只能绑定到状态 *n-1*，不能绑定到其他任何状态。

  该提案已开始在邮件列表上[收到反馈][anyprevout list]，此后我们会用后续的 Newsletter 总结其中任何重要讨论。

- **<!--talks-of-technical-interest-at-magical-crypto-friends-conference-->****Magical Crypto Friends 会议上值得关注的技术演讲：** Bryan Bishop 整理了上上个周末 MCF 会议上约十几场演讲和小组讨论的[文字记录][mcf transcripts]，会议组织者也上传了大部分[视频][mcf vids]。虽然只有一场演讲谈到了具体的新进展，但其中几场确实讨论了保密交易、taproot、schnorr 等技术以及其他与比特币相关的构想的细节和影响。我们觉得以下这些演讲格外有趣：

  - **<!--talk-->**Andrew Poelstra 关于加密货币所用密码学的[演讲][mcf andytoshi]。他特别谈到，要构建一个系统有多难——系统里*每一个*环节都必须做对，才能抵御攻击。

  - **<!--panel-->**Rodolfo Novak、Elaine Ou、Adam Back 和 Richard Myers 关于在不直接接入互联网的情况下使用比特币的[小组讨论][mcf nonet]。讨论的话题包括卫星区块传播、网状网络、业余无线电，以及靠人工携带数据（sneakernet），还有这些方式如何让比特币对现有用户更稳健、对网络接入受限地区的用户更可用。其中一段关于比特币数据中继安全性的插话，我们觉得特别有意思——简而言之，比特币协议本就设计成无需信任地接受来自随机对等节点的数据，所以不经过互联网的中继方式未必会改变信任模型。

  - **<!--conversation-->**Will O'Beirne、Lisa Neigut、Alex Bosworth 在 Leigh Cuen 主持下关于 LN 未来的[对话][mcf future ln]，主要谈的是围绕 LN 1.1 规范的当前开发工作在中短期内会有什么结果。这场讨论没有夸大其词，只是平实地描述了 LN 预计会如何改进，好让用户和企业更容易采用。

## Bech32 发送支持

*这是 [bech32 系列][bech32 series] 24 周中的第 10 周，该系列讲的是如何让你付款的对象享受到 segwit 的全部好处。*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/zh/10-snooze-lose.md %}

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和[比特币改进提案（BIPs）][bips repo]中的值得注意的变更。*

- [Bitcoin Core #15006][] 为 `createwallet` RPC 增加新的 `passphrase` 参数，支持在创建钱包时就默认加密。已有钱包仍可通过 `encryptwallet` RPC 转成加密钱包。

- [Bitcoin Core #15870][] 更改了 `importwallet`、`importpubkey`、`importaddress` 和 `importprivkey` 这几个 RPC 与修剪的交互方式。以前只要启用了修剪，这些调用就会失败。然而区块修剪可以配置成手动模式（`prune=1`），也可以设成大于当前区块链大小的值（例如 `prune=450000`），于是会出现“启用了修剪、但所有区块其实都还在”的情况。此次合并后，只有当区块确实因修剪而缺失时，这些调用才会失败。另一种办法是改用 `importmulti` RPC：只要数据的创建时间（时间戳）落在尚未被修剪的区块范围内，即使区块已被修剪，它也能导入任意密钥或其他数据。

- [Bitcoin Core #14802][] 利用 chainstate 撤销数据把 `getblockstats` RPC 提速 100 倍以上（由 Optech 实测）——这种数据用于在区块链重组期间把账本回滚到先前状态。此举还去掉了该 RPC 对交易索引（txindex）的依赖。

- [Bitcoin Core #14047][] 和 [Bitcoin Core #15512][] 加入了加密 [v2 传输协议][v2 transport protocol]所需的功能，该协议介绍见 [Newsletter #39][]。这只是所需全部改动的一小部分；更多细节见主 [PR #14032][Bitcoin Core #14032]。

- [C-Lightning #2631][] 为 pylightning 工具新增三个方法：`autoclean` 用于配置自动删除过期发票（默认在过期一天后删除）；`check` 用于判断某条命令是否有效而不实际执行；`setchannelfee` 用于设置转发支付的手续费，可以是加在每笔转发支付上的基础手续费，也可以是按支付金额比例收取的百分比手续费。

- [C-Lightning #2627][] 为 pylightning 新增 `deleteinvoice` 方法，用于删除在指定时间之前过期的所有发票。


{% include linkers/issues.md issues="15006,15870,14802,14047,2631,2627,15512,14032" %}
[mcf transcripts]: https://diyhpl.us/wiki/transcripts/magicalcryptoconference/2019/
[v2 transport protocol]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-March/016806.html
[anyprevout list]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-May/001992.html
[mcf vids]: https://www.youtube.com/playlist?list=PLWqtMh0tDnEGBHDS8CalOpkVZhlIgRlAC
[mcf andytoshi]: https://diyhpl.us/wiki/transcripts/magicalcryptoconference/2019/crypto-in-cryptocurrency/
[mcf nonet]: https://diyhpl.us/wiki/transcripts/magicalcryptoconference/2019/bitcoin-without-internet/
[mcf future ln]: https://diyhpl.us/wiki/transcripts/magicalcryptoconference/2019/ln-present-and-future-panel/
[email bip-anyprevout]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-May/016929.html
[bech32 series]: /zh/bech32-sending-support/
[newsletter #34]: /zh/newsletters/2019/02/19/#discussion-about-tagging-outputs-to-enable-restricted-features-on-spending
[newsletter #39]: /zh/newsletters/2019/03/26/#version-2-p2p-transport-proposal
[eltoo]: https://blockstream.com/eltoo.pdf
