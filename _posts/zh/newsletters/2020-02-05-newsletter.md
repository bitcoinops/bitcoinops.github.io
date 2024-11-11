---
title: 'Bitcoin Optech Newsletter #83'
permalink: /zh/newsletters/2020/02/05/
name: 2020-02-05-newsletter-zh
slug: 2020-02-05-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 宣布了 Eclair 0.3.3 的发布，请求协助测试 Bitcoin Core 的维护版本，链接到一个用于试验 taproot 和 tapscript 的新工具，总结了关于使用预计算公钥安全生成 schnorr 签名的讨论，并描述了一个关于交互式构建 LN 资金交易的提案。此外，还包括我们定期更新的值得注意的比特币基础设施项目的变化。

## 行动项

- **<!--upgrade-to-eclair-0-3-3-->****升级到 Eclair 0.3.3：** 此次新版本包括对[多路径支付][topic multipath payments]的支持、eclair-core 的确定性构建（详见下方的 [PR 说明][eclair1295]）、对[蹦床支付][topic trampoline payments]的实验性支持，以及各种小的改进和漏洞修复。

- **<!--help-test-bitcoin-core-0-19-1rc1-->****协助测试 Bitcoin Core 0.19.1rc1：** 即将发布的维护[版本][bitcoin core 0.19.1] 包含几个错误修复。鼓励有经验的用户帮助测试，以防止回归或其他意外行为。

## 新闻

- **<!--taproot-and-tapscript-experimentation-tool-->****Taproot 和 tapscript 试验工具：** Karl-Johan Alm 在 Bitcoin-Dev 列表中[发布][alm btcdeb]了他的 [btcdeb][] 工具的实验性分支，支持使用名为 `tap` 的命令行工具创建和执行 [taproot][topic taproot] 和 [tapscript][topic tapscript] 输出。更多信息请参阅他的详细[教程][tap tutorial]。

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

- **<!--safety-concerns-related-to-precomputed-public-keys-used-with-schnorr-signatures-->****与 schnorr 签名结合使用的预计算公钥的安全性问题：** [libsecp256k1 PR #558][libsecp256k1 #558] 提议为 Bitcoin Core 及其他一些比特币程序使用的 libsecp256k1 库添加与 [BIP340][] 兼容的 [schnorr 签名][topic schnorr signatures] 创建和验证功能。由于 BIP340 要求签名需要提交将用于验证签名的公钥，目前的提议签名函数使用私钥来推导出所需的公钥。Gregory Maxwell [指出][gmaxwell pubkey]，生成签名的程序通常已经知道合适的公钥，因此该函数可以通过接受公钥作为参数来节省 CPU 时间。

  Jonas Nick [回应][nick nonce]，这种方法是合理的，但为了安全起见，需要在创建确定性随机数时将公钥包含在数据中。否则，如果攻击者能够获取同一个私钥针对不同公钥生成的两个签名，而所有其他数据保持不变，就可能会无意中重用随机数，攻击者因此可以推导出你的私钥并窃取你的比特币。关于解决这个问题的讨论将在[另一个问题][nonce issue]中继续。

  另外，随着大家意识到接受未经验证的公钥的实现可能导致重用随机数的情况，Gregory Maxwell 在一个专门讨论 [ed25519][] 实现（也使用 schnorr 签名变体）的邮件列表上[发帖][curves post] 提醒风险。Ed25519 的联合作者 Daniel Bernstein 回应称，“针对故障的标准防御措施是签名者验证每个签名。” 这可以检测到提供的公钥无效，而像 Bitcoin Core 这样的钱包在生成签名时确实会执行这种检查，即使是当前使用的 ECDSA 签名算法。然而，这种方法的计算开销可能对许多应用程序不可接受，并且依然存在不熟悉的开发者不知道执行这一步的风险，因此，似乎更倾向于使用 Jonas Nick 的建议（由 Maxwell 转述），即在生成确定性随机数的数据中包含公钥。

  到目前为止，由于此问题尚未对 BIP340 进行任何直接修改，但包括在确定性随机数算法中包含公钥的提议正在讨论中。

- **<!--alternative-x-only-pubkey-tiebreaker-->****替代的仅 x 公钥平衡算法：** 在讨论上述问题时，Pieter Wuille [提出][pubkey pr]，通过更改从私钥推导公钥时选择使用哪种公钥变体的算法（当仅已知密钥的 x 坐标时），可以稍微加快公钥的推导（请参阅关于 32 字节公钥的[Newsletter #59][news59 32bpk]中的先前讨论）。由于这是一个重要的变更，该提议还修改了生成签名部分所使用的标记哈希。

  这个更改尚未在邮件列表中公布，可能是因为开发者们正在评估其他可能同时实施的更改，以解决向签名函数提供预计算公钥的安全性问题。

- **<!--interactive-construction-of-ln-funding-transactions-->****LN 资金交易的交互式构建：** 在当前的 LN 协议中，开设新通道的链上交易完全由单方创建。这虽然简单，但缺点是通道中的支付最初只能单向流动——从资助通道的一方流向另一方。Lisa Neigut 一直在开发一个双重资助[协议][bolts #524]，允许双方共同出资开设通道，这对于创建可以双向支付的通道尤其有用，从而改善网络的流动性。

  然而，双重资助提案较为复杂，因此 Neigut 本周在 Lightning-Dev 邮件列表中发起了一个[讨论][neigut thread]，希望将新协议的一个方面单独拆分出来：LN 节点协同构建资金交易的能力。这一特性之前被描述为提高安全性（参见 [Newsletter #78][news78 dual-funding]），而 Neigut 指出，该协作机制还可以支持相关的工作，如批量关闭（同时关闭多个通道）和 [splicing][topic splicing]（在不影响通道中其他资金可支配性的情况下向通道中添加或移除资金）。对 Neigut 提案的回复包括：

  * 一个建议是将 nLockTime 字段的值设置为最近或即将到来的区块高度，以实现反手续费抢先机制，这有助于阻止区块链重组，并帮助资金交易与已经实施反手续费抢先机制的钱包（包括 LND 的 sweeping 模式，参见 [Newsletter #18][news18 lnd afs]）混合。

  * 更广泛的建议是使用与其他协作交易创建系统（如 [coinjoin][topic coinjoin] 软件）相同的一组交易自由参数值（如 nVersion、nSequence、nLockTime、输入排序和输出排序）。这可以避免明显地表明某个 LN 资金交易正在创建（特别是在采用 [taproot][topic taproot] 的情况下，因为相互关闭的 LN 交易可以表现得像单签名支出）。

  * {:#psbt-interaction} 一个建议是使用 [BIP174][] 部分签名的比特币交易（[PSBTs][topic psbt]）来传达提议的交易细节。然而，Neigut 回应称，她认为 PSBT 对于两个对等节点之间的交易协作来说“有些过重”。

  * {:#podle} 关于如何避免探测攻击的子讨论，其中 Mallory 开始与 Bob 开设一个双重资助通道的过程，但在她获取到 Bob 的某个 UTXO 的身份后便中止。通过在资金交易完成前中止，Mallory 可以无需成本地了解哪个网络身份（节点）拥有哪个 UTXO。

    其中一个解决方案是要求发起开通通道的一方（例如 Mallory）在准备好花费状态下提供她的 UTXO，以使得探测行为具有一定的成本（如交易费用）。这种方法的缺点是，所提出的构建方式在区块链分析中易于识别，使得何时开设双重资助通道变得容易判断。

    另一个提议是使用 [PoDLE][]，它最初由 Gregory Maxwell 建议并为 JoinMarket 开发。这种协议允许发起方（如 Mallory）以一种防止任何人识别该 UTXO 的方式提交 UTXO。参与方（如 Bob）在整个网络上（例如 JoinMarket 网络）发布这一承诺，以防止 Mallory 在使用该 UTXO 时与其他用户建立会话。然后 Bob 要求 Mallory 确认她的 UTXO，如果这是一个有效的并且与她的承诺匹配的 UTXO，Bob 便向 Mallory 公开他的 UTXO，从而他们可以继续协议（例如 coinjoin）。如果 Mallory 在协议完成前中止，先前发布在网络上的承诺将阻止她与其他用户建立新会话，从而无法学习他们的 UTXO。Mallory 唯一的选择是从自己转账给自己以生成新的 UTXO——这一过程会花费她的资金，从而限制了她窥探用户的能力。（注意，PoDLE 在 JoinMarket 中的实现默认允许 Mallory 最多重试三次，因此不会因偶尔的意外失败（如网络连接中断）而惩罚诚实用户。）该想法是将此协议适用于 LN，以防止攻击者得知 LN 用户控制的可用 UTXO。

## 值得注意的代码和文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]的值得注意的变化。*

- [Bitcoin Core #16702][] 允许 Bitcoin Core 基于自主系统编号（ASN）而不是 IP 地址前缀选择节点。基于 ASN 区分节点可能使得某些 [eclipse 攻击][topic eclipse attacks]（如 [Erebus 攻击][erebus]）更难成功。此新特性默认关闭——要使用基于 ASN 的对等选择，用户必须提供 ASN 表文件，可以使用 [asmap][] 生成。未来的版本可能包括由 Bitcoin Core 开发者生成和审核的 ASN 表文件。详情请参阅我们对 #bitcoin-core-dev IRC 讨论的[总结][asn peer selection]。

- [Bitcoin Core #17951][] 保持一个滚动的布隆过滤器，用于记录最近区块中确认的交易。当一个节点的对等节点广播一笔交易时，节点会检查该交易的 txid 是否与过滤器匹配。如果匹配，节点会跳过下载该交易（因为它已经被确认）。这取代了之前的方法，该方法会因重复下载已确认的交易（即使其输出已经被花费）而浪费带宽。

- [C-Lightning #3315][] 添加了一个 `dev-sendcustommsg` RPC 和 `custommsg` 插件钩子，允许节点向其任何对等节点发送自定义网络协议消息。此功能仅能用于 C-Lightning 守护进程内部未处理的消息，并且仅限于类型为奇数的消息（遵循 [it's ok to be odd][] 规则）。注意：该功能不应与通过网络路由在洋葱加密支付中发送聊天消息的应用程序（如 [WhatSat][]）混淆；此合并的 PR 仅允许向节点的直接对等方发送协议消息。

- [Eclair #1295][] 允许 eclair-core 模块进行确定性构建。有关构建的详细信息，请参阅他们的[文档][eclair deterministic doc]。ACINQ 还宣布他们计划让 Eclair Mobile 和 Phoenix 等其他软件支持可重复构建。<!-- source: https://github.com/ACINQ/eclair/releases/tag/v0.3.3 -->

- [Eclair #1287][] 为数据库添加了字段，以改进对[多路径支付][topic multipath payments]和[蹦床支付][topic trampoline payments]相关费用的跟踪。

- [Eclair #1278][] 允许用户在连接到一个作为 Tor 隐藏服务运行的 Electrum 风格区块链数据服务器时，跳过使用 SSL，因为 Tor 本身提供了认证和加密。

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
