---
title: 'Bitcoin Optech Newsletter #115'
permalink: /zh/newsletters/2020/09/16/
name: 2020-09-16-newsletter-zh
slug: 2020-09-16-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 建议检查是否存在易受 InvDoS 攻击的节点，简要介绍了该攻击，总结了针对 LN 通道的另一种攻击，并链接到 Crypto Open Patent Alliance 的公告。此外，还包括我们常规的栏目：发布与候选发布，以及热门比特币基础设施项目的值得注意的变更。

## 行动项

- **<!--check-for-nodes-vulnerable-to-the-invdos-attack-->****检查是否存在易受 InvDoS 攻击的节点：** 本周披露的一项攻击影响多个旧版本的全节点软件（包括一些山寨币）。根据[论文][invdos paper]，受影响的比特币软件包括“Bitcoin Core v0.16.0、Bitcoin Core v0.16.1、Bitcoin Knots v0.16.0、bcoin 截至 v1.0.0-pre 的所有 beta 版本，[以及] btcd 截至 v0.20.1-beta 的所有版本”。Bitcoin Core、Bitcoin Knots、bcoin 和 btcd 的最新发布版本均已包含修复。详情请见下文的*新闻*部分。

## 新闻

- **<!--inventory-out-of-memory-denial-of-service-attack-invdos-->****库存内存耗尽拒绝服务攻击（InvDoS）：** Braydon Fuller 和 Javed Khan 向 Bitcoin-Dev 邮件列表[发布][invdos post]了一项他们此前已向多个比特币及比特币衍生全节点的维护者披露过的攻击（[网站][invdos site]、[论文][invdos paper]、[CVE-2018-17145][]）。该攻击利用的是比特币节点用来向对等节点通告新交易（或其他数据）哈希值的 `inv`（inventory，库存）消息。正常情况下，对等节点收到一份库存后，会检查自己是否已有该哈希对应的交易，然后请求任何此前未见过交易的完整副本。而在攻击中，攻击者会向受害者灌入数量过大的 `inv` 消息，每条消息几乎都塞满允许的最大交易哈希数量。当排队的库存过多时，受害节点的内存就会被耗尽并崩溃。

  受影响程序中有几个本来就有代码限制应排队的库存数量，但研究人员能够绕过这些保护。作为一个只会让节点崩溃的缺陷，它无法被直接用来从受影响节点窃取资金。不过，它可以被用来实施[日食攻击][topic eclipse attacks]，而这类攻击最终可能窃取资金——尽管没有迹象表明该攻击曾被公开使用。

  建议所有用户升级到所用全节点软件的最新发布版本，或查看[网站][invdos site]上列出的易受影响版本与已修复版本。

- **<!--stealing-onchain-fees-from-ln-htlcs-->****从 LN HTLC 中窃取链上手续费：** Antoine Riard 向 Lightning-Dev 邮件列表[发布][riard post]了 LN 规范近期一次更新中存在的潜在漏洞（见 [Newsletter #112][news112 bolts688]）。按更新后的规范进行 LN 支付时，每个远程方在为自己那一半 2-of-2 多重签名脚本签名时会附带一个[标志][sighash]。这个标志即 `SIGHASH_SINGLE|SIGHASH_ANYONECANPAY`，它允许把该笔支付（即 HTLC）放进一笔还包含其他输入和输出的交易中。这一设计是为了把多个 HTLC 打包进同一笔交易，该交易另有一个额外输入用来支付所需的额外手续费，以及一个可选的额外输出，用来收回支付这些额外手续费后剩余的资金。这样一来，就可以等到这些 HTLC 需要确认时再决定付多少费率。

  {:.center}
  ![使用手续费追加输入和找零输出花费 HTLC](/img/posts/2020-09-htlc-fee-bumping.dot.png)

  然而，Riard 指出，规范中早先那种为 HTLC 承诺可变费率的机制仍然可用。这可以让攻击者为多个 HTLC 承诺高额手续费，然后构造一笔交易，把这些 HTLC 与仅仅一个额外输出组合起来，该输出索取一部分原本要用作手续费的资金。Riard 的邮件描述了如何把这一基本手法用于更复杂的攻击，以最大化窃取金额。

  {:.center}
  ![用找零输出从多付手续费的 HTLC 中窃取手续费](/img/posts/2020-09-htlc-fee-stealing.dot.png)

  人们提出了几种解决方案，其中最简单的可能是让 HTLC 只支付最低的中继手续费——所需的额外手续费由广播这些 HTLC 的一方补齐。目前还没有任何 LN 实现默认采用这项近期的规范更新，因此只有那些试用过与[锚定输出][topic anchor outputs]相关的实验性选项的用户可能受到影响。

- **<!--crypto-open-patent-alliance-->****Crypto Open Patent Alliance：** Square [宣布][square tweet]成立一个[组织][copa]，以协调加密货币技术相关专利的共享。成员允许任何人自由使用其专利，作为交换，成员便能在遭到专利攻击时动用池中的专利进行防御。除 Square 之外，Blockstream 也[宣布][blockstream tweet]加入这一专利池。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [C-Lightning 0.9.1][C-Lightning 0.9.1] 是一个新版本，包含许多新功能与缺陷修复，其中包括下文*值得注意的变更*部分描述的所有新能力。详情请参阅该项目的[发布说明][cl 0.9.1 rn]。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]中值得注意的更改。*

- [C-Lightning #4020][] 增加了一个新的 `channel_state_changed` 通知钩子，每次通道状态更改时（例如从“正常”操作状态变为“关闭中”）都会触发该通知。

- [C-Lightning #3812][] 添加了 `multiwithdraw` RPC，允许向多个地址发送链上资金，实现[支付批处理][topic payment batching]。

- [C-Lightning #3763][] 添加了 `multifundchannel` RPC，可以用一笔包含多个输出的存款交易同时资助多个通道。得益于支付批处理的效率优势，这能节省 75% 甚至更多的手续费。作为实验，这一新功能曾被[用来][russell tweet]在一笔[单笔交易][russell tx]中，向测试网上所有正常运行且公开列出的 LN 节点各开一个通道。

- [C-Lightning #3973][] 增加了双向资助通道的接收方支持。双向资助通道中，两个参与方均出资，而不仅仅是单一发起方出资（参见 Newsletters [#22][news22 dual] 和 [#83][news83 dual]）。发起方的初始实现仍在开发中，相关规范变更的[草案][neigut interactive funding]已公布。

- [C-Lightning #3870][] 为惩罚交易实现了一种*焦土*（scorched earth）手续费追加机制。如果远程对等节点广播旧的通道状态，本地节点可以用对应的撤销密钥创建一笔惩罚交易，花掉不合规对等节点所主张的全部资金。为了避开这一点，对等节点可能试图贿赂矿工忽略诚实节点的惩罚交易。采用焦土策略时，诚实节点会对自己的惩罚交易做手续费追加，把它的全部价值都付作手续费——从而确保不合规对等节点无法从其未遂的盗窃中获利。理论上，如果窃贼知道自己无法从攻击中获利，就不会去尝试。这个 PR 似乎是受 Lightning-Dev 邮件列表七月份一场讨论的[启发][C-Lightning #3832]，见 [Newsletter #104][news104 scorched earth]。

  C-Lightning 采用的焦土策略实现，是定期对惩罚交易做手续费追加，最终用一笔把全部价值都付作手续费的交易替换它。其他实现类似策略的人或许该看看这段代码，了解它如何处理一些细微的潜在问题，例如最小交易大小（见 [Newsletter #99][news99 min]），以及 Bitcoin Core 一年多前对最大手续费 API 所做的一项更改（见 [Newsletter #39][news39 maxfeerate]）。

- [LND #4310][] 添加了使用 `lncli` 创建和使用配置文件的功能。配置文件会将保存的参数自动应用到所有连接中，非常适合那些始终使用相同的非默认参数或连接到多个服务器的用户。例如，用户可以创建一个配置文件，然后用 `lncli -p test getinfo` 即可，而不必调用 `lncli --rpcserver=10019 --network=regtest getinfo`。此外，该 PR 还允许选择把 LND 的认证凭证（“macaroons”）加密后存放在配置文件中。

- [LND #4558][] 更新了 LND 现有的[锚定输出][topic anchor outputs]实现，使其符合三周前合并的最新版规范（见 [Newsletter #112][news112 bolts688]）。它还把锚定输出从实验性功能集合中移除，并计划在 LND 的下一个主要版本中默认启用。

- [Rust-Lightning #618][] 添加了对 rust-lightning 的 C/C++ 绑定支持。这为创建其他语言（如 Swift、Java、Kotlin 和 JavaScript）的 API 提供了框架。相比 JSON 或 RPC 等替代方法，该方法具有更高的性能和内存效率，这对移动和资源受限环境尤为重要。更多详情请参见[绑定文档][bindings readme]。

- [Libsecp256k1 #558][] 实现了 secp256k1 椭圆曲线上的 [schnorr 签名][topic schnorr signatures]验证和单方签名，其标准由 [BIP340][] 规定。相比比特币现有的 ECDSA 签名，schnorr 签名依赖的安全假设更少、不可延展，并允许使用简单得多的密钥聚合方案，例如 [MuSig][topic musig]。schnorr 签名也是 [taproot][topic taproot] 的关键组成部分，taproot 用聚合的 schnorr 签名来实现“所有人都同意”的密钥路径花费。用密钥路径花费 taproot 输出，既能更好地保护花费条件的隐私，也能减小签名大小。Bitcoin Core 也相应地[更新][Bitcoin Core #19944]了其内部的 libsecp256k1 代码树，以纳入这一更改。

{% include references.md %}
{% include linkers/issues.md issues="4020,3812,3763,3973,3870,3832,4310,4558,618,558,19944" %}
[C-Lightning 0.9.1]: https://github.com/ElementsProject/lightning/releases/tag/v0.9.1rc2
[cl 0.9.1 rn]: https://github.com/ElementsProject/lightning/blob/817a7533d16263a63f50df7557a60479622d15d6/CHANGELOG.md#091---2020-09-15-the-antiguan-btc-maximalist-society
[russell tweet]: https://twitter.com/rusty_twit/status/1304581535849275393
[russell tx]: https://blockstream.info/testnet/tx/cde8bedfec5e683298bb67116f0f33a4d6384b7947a889b226301bf28bab035c
[news112 bolts688]: /zh/newsletters/2020/08/26/#bolts-688
[news22 dual]: /zh/newsletters/2018/11/20/#dual-funded-channels
[news83 dual]: /zh/newsletters/2020/02/05/#interactive-construction-of-ln-funding-transactions
[news99 min]: /zh/newsletters/2020/05/27/#minimum-transaction-size-discussion
[news39 maxfeerate]: /zh/newsletters/2019/03/26/#bitcoin-core-13541
[invdos paper]: https://invdos.net/paper/CVE-2018-17145.pdf
[invdos post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-September/018164.html
[invdos site]: https://invdos.net/
[cve-2018-17145]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2018-17145
[riard post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-September/002796.html
[square tweet]: https://twitter.com/sqcrypto/status/1304087270736236544
[copa]: https://open-patent.org/
[blockstream tweet]: https://twitter.com/Blockstream/status/1304529416131940352
[neigut interactive funding]: https://github.com/niftynei/lightning-rfc/pull/1
[news104 scorched earth]: /zh/newsletters/2020/07/01/#discussion-of-htlc-mining-incentives
[sighash]: https://btcinformation.org/en/developer-guide#signature-hash-types
[bindings readme]: https://github.com/rust-bitcoin/rust-lightning/tree/main/lightning-c-bindings
[hwi]: https://github.com/bitcoin-core/HWI
