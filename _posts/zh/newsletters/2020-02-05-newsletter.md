---
title: 'Bitcoin Optech Newsletter #83'
permalink: /zh/newsletters/2020/02/05/
name: 2020-02-05-newsletter-zh
slug: 2020-02-05-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 宣布 Eclair 0.3.3 发布，请求协助测试 Bitcoin Core 的一个维护版本，链接到一个用于试验 taproot 与 tapscript 的新工具，总结关于用预计算公钥安全生成 schnorr 签名的讨论，并介绍一项交互式构建 LN 注资交易的提案。此外还有关于热门比特币基础设施项目值得注意的变更的常规栏目。

## 行动项

- **<!--upgrade-to-eclair-0-3-3-->****升级到 Eclair 0.3.3：** 这一新版本支持[多路径支付][topic multipath payments]，eclair-core 支持确定性构建（详见下方的 [PR 说明][eclair1295]），对[蹦床支付][topic trampoline payments]提供实验性支持，此外还有一些小改进和错误修复。

- **<!--help-test-bitcoin-core-0-19-1rc1-->****协助测试 Bitcoin Core 0.19.1rc1：** 即将发布的维护[版本][bitcoin core 0.19.1]包含若干错误修复。我们鼓励有经验的用户帮助测试是否存在回归或其他意外行为。

## 新闻

- **<!--taproot-and-tapscript-experimentation-tool-->****taproot 与 tapscript 试验工具：** Karl-Johan Alm 在 Bitcoin-Dev 邮件列表上[发帖][alm btcdeb]，介绍他的 [btcdeb][] 工具的一个实验性分支：它支持用名为 `tap` 的命令行工具创建和执行 [taproot][topic taproot] 与 [tapscript][topic tapscript] 输出。更多信息见他写的详细[教程][tap tutorial]。

{% comment %}<!-- Timeline:
1/26 15:29 gmaxwell
https://github.com/bitcoin-core/secp258k1/pull/558#discussion_r371027220
"shouldn't this present an interface that takes the pubkey as an
argument,"

1/26 16:05 jonasnick
"Note that in that case we'll need to add the pubkey as extradata to the
deterministic nonce function, otherwise calling sign with the wrong
public key may leak the secret key through an (invalid) signature."

1/27 18:36 #secp256k1
[6:36:02 pm] <gmaxwell> but it's not really a problem in ed25519 because the only thing it does with the public key is stuffs it into the e hash, and presumably it stuffs the same data into the nonce hash?  (if it doesn't they're pants on head stupid and should be shot)
[...]
[6:37:49 pm] <gmaxwell> okay the ed25519 people should be shot, it's an input to e and not an input to their nonce function
[6:38:02 pm] <gmaxwell> (I just checked)

1/28 01:49 https://moderncrypto.org/mail-archive/curves/2020/001012.html
-->{% endcomment %}

- **<!--safety-concerns-related-to-precomputed-public-keys-used-with-schnorr-signatures-->****与 schnorr 签名配合使用预计算公钥的安全隐患：** [libsecp256k1 PR #558][libsecp256k1 #558] 提议为 libsecp256k1 库添加与 [BIP340][] 兼容的 [schnorr 签名][topic schnorr signatures]创建与验证功能，Bitcoin Core 及其他几个比特币程序都用这个库。由于 BIP340 要求签名对将用于验证该签名的公钥作出承诺，目前提议的签名函数是拿私钥去推导所需的公钥。Gregory Maxwell [指出][gmaxwell pubkey]，生成签名的程序通常本来就知道对应的公钥，所以让这个函数接受公钥作为参数可以省下 CPU 时间。

  Jonas Nick [回应][nick nonce]说这个思路合理，但要做得安全，就必须把公钥一并纳入生成确定性 nonce 所用的数据。否则，如果攻击者能拿到同一把私钥针对两个不同公钥生成的两份签名，而其他数据都相同，你就在不知不觉中重复使用了同一个 nonce，攻击者便能推导出你的私钥、偷走你的比特币。如何解决这个问题的讨论在[另一个 issue][nonce issue]中继续。

  另外，随着大家逐渐看清：接受公钥却不验证其有效性的实现，可能会产生被重复使用的 nonce，Gregory Maxwell 便在一个专门讨论 [ed25519][] 实现（同样使用 schnorr 签名的一种变体）的邮件列表上[发帖][curves post]，提醒这一风险。Ed25519 的共同作者 Daniel Bernstein 回复说：“应对故障的标准做法，是让签名者验证每一个签名。”这能发现传进来的公钥无效；而 Bitcoin Core 等一些钱包对于自己生成的任何签名确实都会做这项检查——即便用的是当前使用的 ECDSA 签名算法也是如此。然而，这种做法的计算开销对许多应用来说可能无法接受，而且仍然存在经验不足的开发者不知道要做这一步的风险。因此，看起来更好的做法还是采纳 Jonas Nick 的建议（由 Maxwell 转述）：把公钥纳入生成确定性 nonce 所用的数据。

  到目前为止，这个问题还没有直接导致 BIP340 出现任何改动，但诸如把公钥纳入确定性 nonce 算法之类的提议改动正在讨论中。

- **<!--alternative-x-only-pubkey-tiebreaker-->****x-only 公钥的另一种裁决方案：** 在讨论上述问题时，Pieter Wuille [提议][pubkey pr]略微加快从私钥推导公钥的过程：当只知道密钥的 x 坐标时，需要选出使用哪个公钥变体，他改的就是这个选择算法（参见此前关于 32 字节公钥的讨论：[Newsletter #59][news59 32bpk]）。由于这是一项重要改动，该提议还改动了用于生成签名中一部分内容的标记哈希（tagged hash）。

  这一改动尚未在邮件列表上公布，可能是因为开发者正在评估：为了处理向签名函数提供预计算公钥的安全问题，他们还想同时做哪些其他改动。

- **<!--interactive-construction-of-ln-funding-transactions-->****LN 注资交易的交互式构建：** 在当前的 LN 协议中，开设新通道的那笔链上交易完全由一方独自创建。这样做的好处是简单，坏处是通道里的支付一开始只能单向流动——从出资开通道的一方流向另一方。Lisa Neigut 一直在做一项双向资助[协议][bolts #524]，让双方都能为开通道出资，这对创建一开始就能双向支付的通道特别有用，也能改善整个网络的流动性。

  不过双向资助提案相当复杂，所以 Neigut 本周在 Lightning-Dev 邮件列表上另起了一个[讨论帖][neigut thread]，想把新协议中的一个方面单独拆出来：LN 节点协作构建注资交易的能力。此前这一特性被描述为能提升安全性（参见 [Newsletter #78][news78 dual-funding]），Neigut 还指出，这种协作机制也能支撑相关的工作，比如批量关闭（同时相互关闭多个通道）和[拼接][topic splicing]（在不影响通道内其他既有资金可花费性的前提下，把资金移入或移出通道）。对 Neigut 提案的回复包括：

  * 一个建议是把 nLockTime 字段的值设为最近或即将到来的区块高度，以实现反手续费狙击（anti-fee sniping）——这有助于抑制区块链重组，也能让注资交易与已经实现反手续费狙击的其他钱包（包括 LND 的 sweeping 模式，参见 [Newsletter #18][news18 lnd afs]）混在一起而不易区分。

  * 更宽泛地说，建议与其他的协作式交易创建系统（例如 [coinjoin][topic coinjoin] 软件）为交易中的自由参数（如 nVersion、nSequence、nLockTime、输入排序和输出排序）采用一套统一的取值。这样可以避免留下明显迹象，让人看出正在创建 LN 注资交易（尤其是在采纳 [taproot][topic taproot] 之后，因为 LN 的相互关闭交易看起来可以像单签花费）。

  * {:#psbt-interaction} 建议用 [BIP174][] 部分签名比特币交易（[PSBT][topic psbt]）来传递提议的交易细节。不过 Neigut 回应说，她认为 PSBT 对于两个对等节点之间的交易协作来说“有点太重了”。

  * {:#podle} 一段子讨论：如何避免被探测——Mallory 与 Bob 开始开设一个双向资助通道，但在得知 Bob 某个 UTXO 的身份后就中止。只要在注资交易完成前中止，Mallory 就能零成本地弄清哪个网络身份（节点）拥有哪些 UTXO。

    修复这一点的一个提议，是要求提出开通道的那一方（例如 Mallory）提供处于随时可花费状态的 UTXO，这样探测就得付出金钱代价（例如交易手续费）。这种做法的缺点是，它提议的构造在区块链分析中很容易识别，别人一眼就能判断出某个双向资助通道是什么时候开的。

    另一个提议是使用 [PoDLE][]，它最初是依据 Gregory Maxwell 的建议为 JoinMarket 开发的。该协议允许 Mallory 这样的发起方以一种任何人都无法识别出该 UTXO 的方式对某个 UTXO 作出承诺。Bob 这样的参与方会把该承诺发布到整个网络（例如 JoinMarket 网络）上，这样在 Mallory 使用这个特定 UTXO 期间，就不会有别人再来跟她建立会话。随后 Bob 要求 Mallory 指明她的 UTXO，如果那确实是一个有效且与她的承诺相符的 UTXO，Bob 就把自己的 UTXO 透露给 Mallory，双方继续走协议（例如一次 coinjoin）。如果 Mallory 在完成前中止协议，此前发布到网络上的承诺会让她无法再与其他任何用户开启新会话，也就无法得知他们的 UTXO。Mallory 唯一的选择是把币从自己花给自己，以生成新的 UTXO——这个过程要花钱，从而限制了她刺探用户的能力。（不过要注意，PoDLE 在 JoinMarket 中的实现默认允许 Mallory 重试最多三次，以免诚实用户因偶尔的意外失败——比如网络连接中断——而受罚。）这个想法是把该协议改造用于 LN，防止攻击者得知哪些可用 UTXO 由 LN 用户掌控。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络 BOLT][bolts repo] 中值得注意的变更。*

- [Bitcoin Core #16702][] 允许 Bitcoin Core 按自治系统编号（ASN）而不是 IP 地址前缀来选择对等节点。按 ASN 区分对等节点，可以让对手更难成功实施某些 [日食攻击][topic eclipse attacks]（例如 [Erebus 攻击][erebus]）。这项新特性默认关闭——要使用基于 ASN 的对等节点选择，用户必须提供一份 ASN 表文件，可以用 [asmap][] 生成。将来的版本可能附带由 Bitcoin Core 开发者生成并审核的 ASN 表文件。更多细节见我们对 #bitcoin-core-dev 中一次 IRC 讨论的[总结][asn peer selection]。

- [Bitcoin Core #17951][] 维护一个滚动布隆过滤器，记录最近区块中确认的交易。当某个对等节点向节点宣告一笔交易时，节点会用该交易的 txid 到过滤器里比对。如果命中，节点就跳过下载该交易（因为它已经被确认过了）。这取代了此前判断是否下载某笔交易的机制；旧机制在某笔已确认交易的输出已被花掉时，仍会重复下载这笔交易，白白浪费带宽。

- [C-Lightning #3315][] 新增了 `dev-sendcustommsg` RPC 和 `custommsg` 插件钩子，允许一个节点向其任意一个对等节点发送自定义网络协议消息。该功能只能用于 C-Lightning 守护进程内部尚未处理的消息，而且只能用于类型编号为奇数的消息（遵循 [it's ok to be odd][] 规则）。注意：不要把这个功能与 [WhatSat][] 这类应用程序混淆——后者是在洋葱加密的支付内部沿网络路由发送聊天消息；此次合并的 PR 只允许向节点的直接对等节点发送协议消息。

- [Eclair #1295][] 让 eclair-core 模块可以确定性构建。构建细节见他们的[文档][eclair deterministic doc]。ACINQ 还宣布，他们打算让 Eclair Mobile 和 Phoenix 等其他软件也支持可重复构建。<!-- source: https://github.com/ACINQ/eclair/releases/tag/v0.3.3 -->

- [Eclair #1287][] 为数据库添加了一些字段，以便更好地跟踪[多路径支付][topic multipath payments]和[蹦床支付][topic trampoline payments]相关的支出。

- [Eclair #1278][] 允许用户在连接以 Tor 隐藏服务方式运行的 Electrum 风格区块链数据服务器时跳过 SSL，因为 Tor 本身就提供了认证和加密。

## 致谢与编辑

感谢 Adam Gibson 审阅了 PoDLE 部分的草稿。已发布文本中的任何错误均由 Newsletter 作者负责。部分文本根据 Pieter Wuille 的建议在发布后添加，以明确在发布签名前验证生成的签名的权衡。

{% include references.md %}
{% include linkers/issues.md issues="558,524,16702,17951,3315,1295,1287,1278" %}
[bitcoin core 0.19.1]: https://bitcoincore.org/bin/bitcoin-core-0.19.1/
[it's ok to be odd]: https://github.com/lightningnetwork/lightning-rfc/blob/master/01-messaging.md#lightning-message-format
[whatsat]: https://github.com/joostjager/whatsat
[news59 32bpk]: /zh/newsletters/2019/08/14/#proposed-change-to-schnorr-pubkeys
[news78 dual-funding]: /zh/newsletters/2019/12/28/#ln-cve
[news18 lnd afs]: /zh/newsletters/2018/10/23/#lnd-1978
[eclair deterministic doc]: https://github.com/ACINQ/eclair/blob/master/BUILD.md#build
[eclair1295]: #eclair-1295
[alm btcdeb]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017600.html
[btcdeb]: https://github.com/kallewoof/btcdeb/tree/taproot
[tap tutorial]: https://github.com/kallewoof/btcdeb/blob/taproot/doc/tapscript-example-with-tap.md
[gmaxwell pubkey]: https://github.com/bitcoin-core/secp256k1/pull/558#discussion_r371027220
[nick nonce]: https://github.com/bitcoin-core/secp256k1/pull/558#discussion_r371029200
[nonce issue]: https://github.com/sipa/bips/issues/190
[pubkey pr]: https://github.com/sipa/bips/pull/192
[curves post]: https://moderncrypto.org/mail-archive/curves/2020/001012.html
[ed25519]: https://en.wikipedia.org/wiki/EdDSA
[neigut thread]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-January/002466.html
[podle]: https://joinmarket.me/blog/blog/poodle/
[asmap]: https://github.com/sipa/asmap
[asn peer selection]: /zh/newsletters/2019/06/26/#differentiating-peers-based-on-asn-instead-of-address-prefix
[erebus]: https://erebus-attack.comp.nus.edu.sg/
