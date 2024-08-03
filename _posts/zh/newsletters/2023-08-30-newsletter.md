---
title: 'Bitcoin Optech Newsletter #266'
permalink: /zh/newsletters/2023/08/30/
name: 2023-08-30-newsletter-zh
slug: 2023-08-30-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报包括了一项老的闪电网络实现中漏洞的尽责披露的公告，总结了对提议的限制条款的操作码进行混合的建议；此外还包括我们的常规内容内容以及 Bitcoin Stack Exchange 中的精选问答、新软件发布和候选发布的公告，以及热门比特币基础设施项目的重大变更的汇总。

## 新闻

- **<!--disclosure-of-past-ln-vulnerability-related-to-fake-funding-->此前与假充值相关的闪电网络漏洞的信息披露：** Matt Morehouse [发布][morehouse dos]到 Lighting-Dev 邮件列表中，总结了他之前[尽责披露][topic responsible disclosures]的漏洞。该漏洞现在在所有流行的闪电网络实现的最新版本中都已经解决。为理解该漏洞，我们假设 Bob 运行了一个闪电网络节点。他收到 Mallory 节点的请求，要求打开一个新的通道。他们会经历通道开启的过程，但停在需要 Mallory 广播通道充值交易的阶段。为了以后使用该通道，Bob 需要存储与之相关的一些状态，并开始扫描能让交易得到足够多确认的新区块。如果 Mallory 再也不广播该交易，就会浪费掉 Bob 的存储和扫描资源。而如果 Mallory 重复这个过程数千次或数百万次，可能会浪费 Bob 的资源，以至于他的闪电网络节点无法执行任何其他操作，包括需要及时执行的防止资金损失的操作。

    在 Morehouse 对自己的节点进行测试时，他成功地对 Core Lightning、Eclair、LDK 和 LND 造成了重大问题，其中包括（在我们看来）可能导致许多节点损失资金的两种情况。Morehouse 的[完整描述][morehouse post]给出了解决该问题的 PR 的链接（其中包括在周报 [#237][news237 dos] 和 [#240][news240 dos] 中介绍过的 PR），并列出了解决该漏洞的闪电网络版本：

    - Core Lightning 23.02
    - Eclair 0.9.0
    - LDK 0.0.114
    - LND 0.16.0

    邮件列表和 [IRC][stateless funding] 上有一些后续讨论。{% assign timestamp="21:11" %}

- **使用 `TXHASH` 和 `CSFS` 的限制条款混合：**Brandon Black 在 Bitcoin-Dev 邮件列表上[发布][black mashup]了一版 `OP_TXHASH` 的提案（参见[周报 #185][news185 txhash]）。该版本结合了 [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack]可以提供大部分 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]（CTV）和 [SIGHASH_ANYPREVOUT][topic sighash_anyprevout]（APO）的功能。而且相较于这些单个的提案，该版本并不会增加太多额外的链上成本。尽管该提案只依赖自身，但创建它的部分动机是为了“阐明我们把 CTV 和 APO 单独或放在一起的思考，并潜在地推动共识向着未来比特币可以有……神奇用途的路径上发展”。

    该提案在邮件列表中收到了一些讨论。Delving Bitcoin 论坛上有一些[后续修订][delv mashup]和讨论。{% assign timestamp="1:30" %}

## Bitcoin Stack Exchange 的精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 的贡献者们寻找答案的首选之地，也是它们有闲暇时会给好奇和困惑的用户帮忙的地方。在这个月度栏目中，我们会列举自上次出刊以来出现的一些高票的问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [从 P2WPKH 切换到 P2TR 是否有经济上的激励？]({{bse}}119301)
  在比较 P2WPKH 和 [P2TR][topic taproot] 输出类型的交易输入和输出的权重时，Murch 历数了常见的钱包使用模式。他总结道：“总体而言，使用 P2TR
  来替代 P2WPKH，你可以节省高达 15.4% 的交易费用。如果你发出的小额支付比收到的要多得多，坚持使用 P2WPKH 可能可以节省最多 1.5% 的费用。” {% assign timestamp="34:44" %}

- [BIP324 加密数据包结构是什么？]({{bse}}119369)
  Pieter Wuille 概述了在 [BIP324][] 中[第 2 版 P2P 传输][topic v2 p2p transport]的网络数据包结构。该结构的进展跟踪记录在 [Bitcoin Core #27634][]中。{% assign timestamp="37:31" %}

- [<!--what-is-the-false-positive-rate-for-compact-block-filters-->致密区块过滤器的假阳性误报率是多少？]({{bse}}119142)
  Murch 从 [BIP158][] 的 [区块过滤器][bip158 filters]的参数选择段落中进行了回答。该内容指出[致密区块过滤器][topic compact block filters]的假阳性误报率为 1/784931。对于一个监控约 1000 个输出脚本的钱包相当于每 8 周出现 1 个块。{% assign timestamp="39:23" %}

- [MATT 提案包含哪些操作码？]({{bse}}119239)
  Salvatoshi 解释了他的 Merkleize All The Things（[MATT][merkle.fun]）提案（参见周报 [#226][news226 matt]、[#249][news249 matt] 和 [#254][news254 matt]），包括其当前提议的操作码：[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]、OP_CHECKCONTRACTVERIFY 和 [OP_CAT][]。 {% assign timestamp="40:27" %}

- [<!--is-there-a-well-defined-last-bitcoin-block-->是否有比特币最后区块的明确定义？]({{bse}}119223)
  RedGrittyBrick 和 Pieter Wuille 指出，虽然没有区块高度限制，但当前的共识规则不允许新区块超出 2106 年比特币的无符号 32 位时间戳限制。交易  [nLockTime][topic timelocks] 值有着相同的[时间戳限制][timestamp limit]({{bse}}110666)。{% assign timestamp="41:40" %}

- [为什么矿工在 coinbase 交易中设置锁定时间？]({{bse}}110474)
  Bordalix 回答了一个长期存在的问题，即矿工似乎使用 coinbase 交易的锁定时间字段来传达某些信息。一个矿池操作员解释说他们“重新定义了这 4 个字节来保持 stratum 会话数据，以便更快地重连”，并在后续[详细说明了该方案][twitter satofishi]。{% assign timestamp="46:10" %}

- [为什么 Bitcoin Core 在执行 Schnorr 签名时不使用辅助随机性？]({{bse}}119042)
  Matthew Leon 问为什么 [BIP340][] 建议在生成 [schnorr 签名][topic schnorr signatures]的 nonce 时使用辅助随机性
  以防止[侧信道][topic side channels]攻击，然而 Bitcoin Core 在其实现中不提供辅助随机性。Andrew Chow 回答说，当前的实现仍然是安全的，也没有 PR 来实现该建议。{% assign timestamp="47:40" %}

## 发布和发布候选版本

*流行的比特币基础设施项目的新发布和发布候选版本。请考虑升级到新版本或帮助测试发布候选版本。*

- [Core Lightning 23.08][] 是这个流行的闪电网络节点实现的最新主要版本。新功能包括在不重新启动节点的情况下更改多个节点配置设置的能力、支持 [Codex32][topic codex32] 格式的[种子][topic bip32]的备份和恢复、一个用于改进支付路径查找的新实验性插件、对[通道拼接][topic splicing]的实验性支持、支付给本地生成的发票的能力，以及许多其他新功能和错误修复。{% assign timestamp="49:21" %}

- [LND v0.17.0-beta.rc1][] 是这个流行的闪电网络节点实现的下一个主要版本的候选发布版本。这个发布版本计划引入一个重要的实验性新功能，支持“简单 taproot 通道”，如 LND PR＃7904 的 _显著变化_ 章节中所述。该功能可能需要更多测试。{% assign timestamp="50:24" %}

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo] 和 [Bitcoin Inquisition][bitcoin inquisition repo]*。

- [Bitcoin Core #27460][] 添加了一个新的 `importmempool` RPC。该 RPC 将加载一个 `mempool.dat` 文件，并尝试将其中加载的交易添加到节点的交易池中。{% assign timestamp="51:16" %}

- [LDK #2248][] 提供了一个内置系统，LDK 的下游项目可以用其来跟踪在 gossip 消息中引用的 UTXO。处理 gossip 消息的闪电网络节点只能接受和 UTXO 相关联的密钥所签名的消息，否则它们可能会被迫处理和转发垃圾消息，或者尝试通过不存在的通道转发支付（尝试将始终失败）。新内置的 `UtxoSource` 可用于连接到本地 Bitcoin Core 的闪电网络节点。{% assign timestamp="53:43" %}

- [LDK #2337][] 使得更加容易地使用 LDK 来构建[瞭望塔][topic watchtowers]。瞭望塔是独立于用户钱包运行，但可以接收来自用户节点的加密闪电网络惩罚交易。瞭望塔可以从新区块中的每笔交易中提取信息，并使用该信息尝试解密先前接收到的加密数据。如果解密成功，瞭望塔可以广播解密后的惩罚交易。当用户不在线时，可以保护用户免受对方发布已撤销的通道状态的影响。{% assign timestamp="55:00" %}

- [LDK #2411][] 和 [#2412][ldk #2412] 添加了一个为[盲化支付][topic rv routing]构建支付路径的 API。这些 PRs 帮助将 LDK 的[洋葱消息][topic onion messages]的代码（其中使用了盲化路径）与盲化路径本身分离开。[#2413][ldk #2413] 中的一项跟进实际上将添加对盲化路径的支持。{% assign timestamp="1:00:16" %}

- [LDK #2507][] 添加了对另一个实现中长期存在并会导致通道非必要的强制关闭问题的变通解决方法。{% assign timestamp="1:04:46" %}

- [LDK #2478][] 添加了一个事件，用于在结算此前转发过的 [HTLC][topic htlc] 时提供信息。该事件可提供这个 HTLC 的相关信息，包括它来自哪个通道、HTLC 的金额以及从中收取的手续费金额。{% assign timestamp="1:07:22" %}

- [LND #7904][] 添加了对“简单 taproot 通道”的实验性支持，允许闪电网络的充值和承诺交易使用 [P2TR][topic taproot]，并支持当双方合作时使用无脚本[多签][topic multisignature]签署的 [MuSig2][topic musig]。这减少了交易的重量，并在通道合作关闭时提高了隐私。LND 继续只使用 [HTLCs][topic htlc]，允许从 taproot 通道开始的支付继续通过其他不支持 taproot 通道的闪电网络节点进行转发。{% assign timestamp="1:09:07" %}

  <!-- The following linked PRs have titles "1/x", "2/x", etc.  I've
  listed them in that order rather than by PR number -->
  这个 PR 包含了之前合并到的 134 个提交。从以下 PR 的 staging 分支合并：[#7332][lnd #7332]、[#7333][lnd #7333]、[#7331][lnd #7331]、[#7340][lnd #7340]、[#7344][lnd #7344]、[#7345][lnd #7345]、[#7346][lnd #7346]、[#7347][lnd #7347] 和 [#7472][lnd #7472]。


{% include references.md %}
{% include linkers/issues.md v=2 issues="27460,2466,2248,2337,2411,2412,2413,2507,2478,7904,7332,7333,7331,7340,7344,7345,7346,7347,7472,27634" %}
[LND v0.17.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.0-beta.rc1
[core lightning 23.08]: https://github.com/ElementsProject/lightning/releases/tag/v23.08
[delv mashup]: https://delvingbitcoin.org/t/combined-ctv-apo-into-minimal-txhash-csfs/60/6
[morehouse dos]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004064.html
[morehouse post]: https://morehouse.github.io/lightning/fake-channel-dos/
[news237 dos]: /zh/newsletters/2023/02/08/#core-lightning-5849
[news240 dos]: /zh/newsletters/2023/03/01/#ldk-1988
[black mashup]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021907.html
[news185 txhash]: /en/newsletters/2022/02/02/#composable-alternatives-to-ctv-and-apo
[stateless funding]: https://gnusha.org/lightning-dev/2023-08-27.log
[bip158 filters]: https://github.com/bitcoin/bips/blob/master/bip-0158.mediawiki#block-filters
[merkle.fun]: https://merkle.fun/
[news254 matt]: /zh/newsletters/2023/06/07/#matt-ctv-joinpools
[news249 matt]: /zh/newsletters/2023/05/03/#mattbased-vaults-matt
[news226 matt]: /zh/newsletters/2022/11/16/#general-smart-contracts-in-bitcoin-via-covenants
[twitter satofishi]: https://twitter.com/satofishi/status/1693537663985361038
