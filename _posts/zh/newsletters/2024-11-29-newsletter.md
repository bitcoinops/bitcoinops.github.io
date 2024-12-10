---
title: 'Bitcoin Optech Newsletter #331'
permalink: /zh/newsletters/2024/11/29/
name: 2024-11-29-newsletter-zh
slug: 2024-11-29-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报总结了多项近期发生的关于为比特币脚本编程设计一种 Lisp 方言的讨论。此外是我们的常规栏目：Bitcoin Stack Exchange 上的热门问题和回答；软件的新版本和候选版本的公告；还有热门的比特币基础设施项目的重大变更总结。

## 新闻

- **<!--lisp-dialect-for-bitcoin-scripting-->用于比特币脚本编程的 Lisp 方言**：Anthony Towns 发布了多篇帖子，讲述他为比特币创造一种 Lisp 方言的连续[工作][topic bll]；这种编程语言可以通过软分叉添加到比特币中。

  - *bll, symbll, bllsh*：Towns [表示][towns bllsh1]，他花了很长时间来思考来自 Chia Lisp 开发者 Art Yerkes 关于保证高层代码（程序员的惯常编程形式）与低层代码（实际被计算机运行的形式，通常由编译器从高层代码中创建出来）良好映射的建议。他决定选择了一种类似于 [miniscript][topic miniscript] 的方法，即 “将高层语言处理为低层语言的友好变种（就像 miniscript 是 script 的友好变种）”。这产生了两种语言和一种工具：

    - *<!--basic-bitcoin-lisp-language-bll-->* *基本的比特币 Lisp 语言（bll）* 是可以通过一次软分叉添加到比特币中的低层语言。Towns 说，bll 类似于他最后一次更新之后的 BTC Lisp 语言（详见[周报 #294][news294 btclisp]）。
    - *<!--symbolic-bll-symbll-->* *Symbolic bll（symbll）* 是可以转化成 bll 的高级语言。这种语言对已经熟悉函数式编程的人来说相对简单。
    - *<!--bll-shell-bllsh-->* *Bll shell（bllsh）* 是一个 [REPL][]，让用户可以测试 bll 和 symbll 语言的脚本、将 symbll 代码编译为 bll，并且可以在执行代码时调试。

  - *<!--implementing-quantumsafe-signatures-in-symbll-versus-gsr-->* *对比 symbll 和 GSR，实现量子安全的签名*：Towns [引用][towns wots]了一条来自 Jonas Nick 的 [ Twitter 帖子][nick wots]，讲的是使用现有的操作码以及由 Rusty Russell 提出的 *伟大脚本复兴*（GSR）[提议][russell gsr]所定义的操作码来实现 “Winterniz 一次性签名（WOTS+）”。然后，Towns 对比了使用 symbll 在 bllsh 中实现 WOTS 的情形。这样做减少了需要发布到链上的数据，至少 83%，甚至可能超过 95%。这也让使用[量子安全的签名][topic quantum resistance]的代价仅仅比 P2WPKH 输出大 30 倍。
  - *<!--flexible-coin-earmarks-->灵活的专项资金标记*：Towns 还[介绍][towns earmarks]了一种与 symbll 兼容（可能还兼容 [Simplicity][topic simplicity]）的通用构造，允许一个 UTXO 为各个花费条件指定具体的花费数额。如果一个花费条件得到了满足，那么相关的数额就可以花出去，而这个 UTXO 中剩余的价值会回到带有剩余花费条件的一个新的 UTXO 中。也可以设置一个可以花费整个 UTXO 的条件；举个例子，这可以用来让达成一致的所有参与者共同更新花费条卷毛。这是一种灵活的[限制条款][topic covenants]机制，类似于 Towns 曾经的 `OP_TAP_LEAF_UPDATE_VERIFY`（TLUV）提议（详见[周报 #166][news166 tluv]），但 Towns 也[曾经表示][towns badcov]，他认为 “限制条款” 这个术语 “并不准确，也没有用”。
    
    Towns 提供了可以运用这些 *灵活专项资金标记* 的多个例子，包括提高闪电通道（也包括基于 [LN-Symmetry][topic eltoo] 的通道）的安全性和有用性、可以替代 [BIP345][] 的[保险柜][topic vaults]合约，以及曾被设想可以使用 TLUV 的 “[支付池][topic joinpools]” 的近似版本、但避免了原提议的 [x-only 公钥][topic x-only public keys]问题。

## 精选的 Bitcoin Stack Exchange 问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者们寻找疑惑解答的首选之地，也是他们有闲暇时会帮助好奇和困惑的用户的地方。在这个月度栏目中，我们会列举自上次出刊以来出现的受欢迎问题和问答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--how-does-colliderscript-improve-bitcoin-and-what-features-does-it-enable-->ColliderScript 如何强化比特币，它启用了什么特性？]({{bse}}124690) Victor Kolobov 列举了 ColliderScript（详见[周报 #330][news330 cs] 和[播客 #330][pod330 cs]）的可能用途，包括[限制条款][topic covenants]、[保险柜][topic vaults]、模仿 [CSFS][topic op_checksigfromstack]，以及 “有效性 rollup”（详见[周报 #222][news222 validity rollups]），虽然 Victor 也指出，这样的交易具有高昂的计算成本。

- [<!--why-do-standardness-rules-limit-transaction-weight-->为么标准化交易规则要限制交易的重量？]({{bse}}124636) Murch 提供了支持和反对 Bitcoin Core 的标准化交易重量限制的理由，并概述了何以对更大体积交易的经济需求会削弱网络主流[交易池规则][policy series]的有效性。

- [<!--is-the-scriptsig-spending-an-paytoanchor-output-expected-to-always-be-empty-->花费 PayToAnchor 输出的脚本签名预计总会是空的吗？]({{bse}}124615) Pieter Wuille 指出，因为 [支付到锚点（P2A）][topic ephemeral anchors] 输出的[构造方式][news326 p2a]，它们必须遵守隔离见证的花费条件，包括使用空的脚本签名（scriptSig）。

- [<!--what-happens-to-the-unused-p2a-outputs-->没有人使用的 P2A 输出最后会怎么样？]({{bse}}124617) Instabibbs 指出，未被使用的 P2A 输出最终会在区块确认费率下降到足够低的时候被清走（汇总），也即从 UTXO 集中移除。他继续引用了最近被合并的 “[临时粉尘][news330 ed]” PR，该 PR 允许一笔零手续费的交易携带一个价值低于粉尘输出门槛的输出，前提是一笔[子交易][topic cpfp]会立即花掉这个粉尘输出。

- [<!--why-doesnt-bitcoins-pow-algorithm-use-a-chain-of-lowerdifficulty-hashes-->为什么比特币的 PoW 算法不使用多个低难度的哈希值？]({{bse}}124777) Pieter Wuille 和 Vojtěch Strnad 描述了如果比特币挖矿使用这种机制、从而打破了 “无过程性（progress-free）”，就会造成挖矿中心化压力。

- [<!--clarification-on-false-value-in-script-->在脚本中如何得到否值？]({{bse}}124673) Pieter Wuille 详细说明了在 Bitcoin Script 会得出否值（false）的三个数值：空数组、0x00 字节的数组，以及一个由 0x00 字节组成且由 0x80 结尾的数组。他指出，所有其他数值都会被真值（true）。

- [<!--what-is-this-strange-microtransaction-in-my-wallet-->为什么我的钱包中会出现奇怪的小额交易？]({{bse}}124744) Vojtěch Strnad 解释了一种地址下毒攻击的原理以及缓解这种攻击的办法。

- [<!--are-there-any-utxos-that-can-not-be-spent-->是否存在无法被花费的 UTXO？]({{bse}}124865) Pieter Wuille 提供了两个无法被花费的输出的例子（与是否能打破密码学假设无关）：`OP_RETURN` 输出，以及脚本公钥（scriptPubKey）长于 10000 字节的输出。

- [<!--why-was-bip34-not-implemented-via-the-coinbase-txs-locktime-or-nsequence-->为什么 BIP34 不使用 coinbase 交易的 locktime 或者 nSequence 字段来实现？]({{bse}}75987) Antoine Poisnot 关注到了这个旧问题，并指出，coinbase 交易的 `nLockTime` 数值不能设置成当前的区块高度，因为这表示直到当前区块，都还处于这笔交易的[锁定事件][topic timelocks]，因此在该区块内包含这笔交易是 *无效的*。

## 新版本和候选版本

*热门比特币基础设施软件的新版本和候选版本。请考虑升级到新版本，或帮助测试旧版本。*

- [Core Lightning 24.11rc2][] 是这个热门的闪电节点实现的下一个主要版本的候选发行。
- [BDK 0.30.0][] 是这个用于开发钱包和其他比特币嵌入应用的库的新版本。该版本包含了多个微小的 bug 修复，并为预期升级到该库的 1.0 版本作好了准备。
- [LND 0.18.4-beta.rc1][] 是这个热门闪电节点实现的一个小版本的候选发行。

## 重大的代码和文档变更

*本周出现重大变更的有：[BDK 0.30.0][]、[LND 0.18.4-beta.rc1][]、[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Bitcoin Core #31122][] 为交易池实现了一种 `changeset` 结构，允许节点在交易池当前状态下计算一组提议变更会产生的影响。举个例子，检查接受一笔交易或一个交易包会不会违反 祖先交易/后代交易/[TRUC][topic v3 transaction relay] 限制，或确定一笔 [RBF][topic RBF] 手续费追加交易是否会改善交易池的状态。这个 PR 是 “[cluster mempool][topic cluster mempool]” 项目的一部分。
- [Core Lightning #7852][] 通过重新引入一个描述字段，为 `pyln-client`（一种 Python 客户端库）恢复了与 24.08 以前版本的后向兼容性。
- [Core Lightning #7740][] 通过提供一项抽象了 “最低费用路径（MCF）” 复杂性的 API，优化了 `askrene` 插件的 MCF 解决器（详见[Newsletter #316][news316 askrene]）；该 API 可以更容易低集成新增加的基于图的路径计算算法。解决器会从用跟 `renepay` 一样的通道费用函数线性化（详见[Newsletter #263][news263 renepay]），这会提高寻路的可靠性，并为定制化的单位（微聪以外的单位）提供了支持，还可以为大额支付实现更大的可扩展性。这一 PR 添加了`simple_feasibleflow`、`get_augmenting_flow`、`augment_flow` 和 `node_balance` 方法来提高路径计算的效率。
- [Core Lightning #7719][] 为 “[通道拼接][topic splicing]” 操作实现了跟 Eclair 客户端的兼容性，允许拼接在这两种实现间执行。这一 PR 引入了多项并更，以跟 Eclair 保持一致，包括支持远端注资密钥轮换、为 commitment-signed 消息添加 `batch_size` 字段、防止超过交易包体积限制的前序注资交易传输、从消息中移除区块哈希值，以及动态调整预设的注资输出余额。
- [Eclair #2935][] 为节点运营者添加了一项通知，在通道对手发起强制关闭时会触发。
- [LDK #3137][] 开始支持接受对等节点发起的[双向注资通道][topic dual funding]，虽然还不支持注资和创建这样的通道。如果 `manually_accept_inbound_channels` 设为否，则会自动接受通道；不过，`ChannelManager::accept_inbound_channel()` 函数允许手动接受。引入一个新的字段 `channel_negotiation_type`，以区分双向注资通道和非双向注资通道的创建请求。尚不支持[零确认][topic zero-conf channels]的双向注资通道和注资交易的 [RBF][topic rbf] 手续费追加。
- [LND #8337][] 引入了 `protofsm` 包，一种可复用的框架，用于在 LND 中创建事件驱动协议的有限状态机（FSMs）。开发人员不必再编写样板文件代码来处理状态、转换和事件，可以直接定义状态、触发事件以及状态转换规则，而 `State` 接口会封装动作、处理事件并确定终局状态，同时后台连接器会处理副作用，比如广播交易和发送对等节点消息。



{% include references.md %}
{% include linkers/issues.md v=2 issues="31122,7852,7740,7719,2935,3137,8337" %}
[news294 btclisp]: /zh/newsletters/2024/03/20/#btc-lisp
[russell gsr]: https://github.com/rustyrussell/bips/pull/1
[towns bllsh1]: https://delvingbitcoin.org/t/debuggable-lisp-scripts/1224
[repl]: https://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop
[towns wots]: https://delvingbitcoin.org/t/winternitz-one-time-signatures-contrasting-between-lisp-and-script/1255
[nick wots]: https://x.com/n1ckler/status/1854552545084977320
[towns earmarks]: https://delvingbitcoin.org/t/flexible-coin-earmarks/1275
[news166 tluv]: /en/newsletters/2021/09/15/#covenant-opcode-proposal
[towns badcov]: https://gnusha.org/pi/bitcoindev/20220719044458.GA26986@erisian.com.au/
[core lightning 24.11rc2]: https://github.com/ElementsProject/lightning/releases/tag/v24.11rc2
[bdk 0.30.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.30.0
[lnd 0.18.4-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.4-beta.rc1
[news316 askrene]: /zh/newsletters/2024/08/16/#core-lightning-7517
[news263 renepay]: /zh/newsletters/2023/08/09/#core-lightning-6376
[news330 cs]: /zh/newsletters/2024/11/22/#covenants-based-on-grinding-rather-than-consensus-changes
[pod330 cs]: /en/podcast/2024/11/26/#covenants-based-on-grinding-rather-than-consensus-changes
[news222 validity rollups]: /zh/newsletters/2022/10/19/#rollup
[policy series]: /zh/blog/waiting-for-confirmation/
[news326 p2a]: /zh/newsletters/2024/10/25/#how-was-the-structure-of-pay-to-anchor-decided-p2a
[news330 ed]: /zh/newsletters/2024/11/22/#bitcoin-core-30239
