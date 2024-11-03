---
title: 'Bitcoin Optech Newsletter #295'
permalink: /zh/newsletters/2024/03/27/
name: 2024-03-27-newsletter-zh
slug: 2024-03-27-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报宣布了一个会影响 Bitcoin Core 和相关节点的带宽消耗型攻击的披露，介绍了多项针对 “交易手续费资助（transaction fee sponsorship）” 想法的提升，还总结了关于使用实时交易池数据来优化 Bitcoin Core 手续费预估特性的讨论。此外是我们的常规部分：来自 Bitcoin Stack Exchange 的精选问答、软件新版本和候选版本的发行公告，以及热门比特币基础设施项目的重大变更。

## 新闻

- **<!--disclosure-of-free-relay-attack-->免费转发攻击的披露**：Bitcoin-Dev 邮件组中[公布][todd free relay]了一种旨在浪费节点带宽的攻击。简而言之，Mallory 将一笔交易的两个版本分别广播给 Alice 和 Bob。交易经过专门的设计，因此 Bob 不会把广播给 Alice 的交易当成一笔 [RBF 替代交易][topic rbf]，Alice 也不会把广播给 Bob 的版本当成手续费替代交易。然后，Mallory 给 Alice 发送一笔替代交易，Alice 会接受这笔交易，但 Bob 不会。当 Alice 给 Bob 转发这笔替换交易时，他们双方的带宽消耗了，但 Bob 会拒绝这笔交易，因此，转发的带宽就被浪费掉了（这就是所谓的 “[免费转发][topic free relay]”）。Mallory 可以一直重复这种把戏，直到其中一笔交易得到确认，而每一轮中，都可以看到 Alice 先接受这笔交易、然后花费给 Bob、然后 Bob 拒绝它。当 Bob 这样的对等节点有多个时，就可以放大对 Alice 的攻击效果：Mallory 可以并行发送多笔这样专门构造的交易，然后让 Alice 浪费带宽向他们转发交易。

    当这样的交易的某些版本最终会确认时，Mallory 的攻击能力受到其愿意支付的手续费量级的限制，不过，攻击描述指出，如果 Mallory 本身就计划发送交易，那这种攻击就几乎是零成本的。那么可被浪费的带宽数量上限就由 Bitcoin Core 现有的交易转发限制决定，虽然并行多次执行这样的攻击可以拖慢正当未确认交易的传播。

    这份描述也提到另一种广为人知的节点带宽浪费攻击，就是一个用户广播一组大体积的交易，然后跟矿工串通、创建一个区块、块内包含与这些被转发的交易相冲突的相对较小的交易。举个例子，一笔体积为 29000 vbyte 的交易，可以从每个参与转发的全节点的交易池中移除大约 200 MB 的交易。这份描述声称，这种可以浪费带宽的攻击存在，意味着有意允许一定数量的免费转发是合理的，例如因为启用了 “手续费率替换” 这样的提议（详见 [周报 #288][news288 rbfr]）。

- **<!--transaction-fee-sponsorship-improvements-->交易费资助提议的优化**：Martin Habovštiak在 Bitcoin-Dev 邮件组中[提出][habovstiak boost]了一个想法，允许一笔交易提高另一笔无关交易的确认优先级。Fabian Jahr [指出][jahr boost]其中的基本想法看起来非常类似于 “[交易手续费资助][topic fee sponsorship]” 提议，那是 Jeremy Rubin 在 2020 年提出的（见[周报 #116][news116 sponsor]）。在 Rubin 的原本提议中，*资助交易* 通过使用一个零价值的输出脚本承诺到 *被加速的交易*，因此一笔资助要花费 42 vbyte，在此基础上每多一笔资助就要多花 32 字节。而在 Habovštiak 的版本中，资助交易使用 taproot [annex][topic annex] 来承诺被加速的交易，因此一笔资助只需要花费 8 vbyte，每多一次资助也只需花费 8 vbyte。

    在了解到 Habovštiak 的想法之后，David Harding 在 Delving Bitcoin 中[公开][harding sponsor]了他和 Rubin 在一月开发出来的效率优化措施。资助交易使用签名的承诺消息来承诺被加速交易，这永远不会在链上显示出来，所以一次承诺不会占用任何区块空间。为了允许这种操作，在区块中，资助交易必须紧跟在被加速交易后面；在[交易包转发][topic package relay]消息中也是如此；使得全节点验证者可以在验证资助交易时推断被加速交易的 txid。

    至于一个区块内可能有多笔资助交易、每一笔都承诺了一部分相同被加速交易的情形，就不能只让一系列被加速的交易出现在资助交易的前面，这是做不到完全可推断的。Harding 介绍了一种简单的替代方法，只需为每一笔被加速的交易使用 0.5 vbyte；Anthony Towns 在此基础上提出了一种[优化][towns sponsor]，不会让一个加速占用超过 0.5 vbyte，而且在绝大多数情况下会比这还要节省。

    Habovštiak 和 Harding 都指出了外包的潜力：任何计划广播交易的人（或者拥有未确认交易、准备使用 [RBF][topic rbf] 来更新交易版本的人）都可以提升费率及加速另一部交易，代价只是微不足道的（每个加速） 0.5 vbyte 或更少；相比之下，0.5 vbyte 是单笔一个输入、两个输出的 P2TR 交易的体积的 0.3%。不幸的是，他们也都警告，没有便利的方式能够免信任地为第三方支付加速费用；不过，Habovštiak 指出，任何通过闪电网络付款的人都可以收到[支付证据][topic proof of payment]，所以有可能在遭受欺诈时作证。

    Towns 进一步指出，资助交易跟现在提议的 “[族群交易池][topic cluster mempool]” 设计似乎是兼容的，最高效的资助交易设计只对交易有效性缓存提出了一些微小的挑战，而且用一张表展示了多种当前和提议阶段的手续费追加技术所消耗的相对区块空间，作为结论。每笔加速只占用 0.5 vbyte 甚至更少，这样最高效的资助形式仅仅次于使用 RBF 的最理想情形以及[在协议外][topic out-of-band fees]给矿工支付费用（链上额外占用体积是 0.0 vbyte）。因为手续费资助允许通道的手续费追加，几乎就跟在协议外给矿工支付一样高，这也许能解决对依赖于 “[外生手续费][topic fee sourcing]” 的协议的一个重大顾虑。

    在本刊出刊之前，[讨论还在继续][daftuar sponsor]，Suhas Daftuar 表示担心资助设计可能引入一些在族群交易池设计中不容易解决的问题，而这些问题可能会给不需要资助的交易带来问题；这暗示着资助（如果真的能加入比特币的话）应该仅对那些选择性开启的交易可用。

- **<!--mempoolbased-feerate-estimation-->基于交易池的手续费估计**：Abubakar Sadiq Ismail 在 Delving Bitcoin 论坛中[提出][ismail fees]了使用来自节点本地交易池的信息来优化 Bitcoin Core 的[手续费率估计][topic fee estimation]的想法。当前，Bitcoin Core 通过记录每一笔交易到达交易池的区块高度、其被确认的区块高度、其费率，来产生估计。在所有信息都知晓时，到达时间（高度）与确认时间（高度）的差值会被用来更新一个表示一系列费率的桶（bucket）的指数加权移动平均值。举个例子，一笔交易如果经过 100 个区块才得到确认，其手续费率是 1.1 聪/vbyte，那么它会被合并到 1 聪/vbyte 的桶的平均值中。

    这种方法的一个优势是抵御操纵：所有交易都必须既得到转发（从而对所有矿工开放）、又得到确认（不能违反任何共识规则）。而劣势则是，它仅在新区块到来时才更新一次，可能远远落后于其它使用实时交易池信息的估计。

    Ismail 采纳了之前关于将交易池数据整合到费率估计的[讨论][bitcoin core #27995]，写了一些预备代码，还运行了一项分析，显示当前的算法与新算法的比较（不包含一些安全性检查）。对该主题的一个[回复][harding fees]也链接了之前由 Kalle Alm 做的同主题[研究][alm fees]，将讨论引向交易池信息是否应该既能调高估计值、又能调低估计值，还是应该只用于调低估计值。两者皆可的好处在于它整体上让估计变得更加有用；而只能用来调低估计值（同时仅使用当前基于确认速度的算法来调高估计值）的好处是更能低于操纵和正反馈循环。

    截至本刊撰写之时，讨论还在继续。

## 来自 Bitcoin Stack Exchange 的精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者们找寻疑问解答的首选之地，也是他们有闲暇时会帮助好奇和困惑用户的地方。在这个月度栏目中，我们挑出了自上次出刊以来出现的一些高票问题和答案。*


{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aa
nswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--what-are-the-risks-of-running-a-presegwit-node-0121-->运行未激活隔离见证升级的节点软件（0.12.1 版）会有什么风险？]({{bse}}122211) Michael Folkson、Vojtěch Strnad 和 Murch 列举了个人用户运行 Bitcoin Core 0.12.1 版本软件的缺点，包括收到无效交易和区块的更高风险、在重复花费攻击面前更加脆弱、更依赖于其它节点来运行更新后的共识验证、更慢的区块验证速度、缺失许多性功能优化、无法使用 “[致密区块中继][topic compact block relay]”、不转发现在占比约为 95% 的未确认交易、[手续费估计][topic fee estimation]更不准确，以及，留有在过去的更新中修复的安全问题。0.12.1 版本的钱包用户也会错过围绕 [miniscript][topic miniscript]、[描述符][topic descriptors]钱包的开发，以及由[隔离见证][topic segwit]、[taproot][topic taproot] 和 [Schnorr 签名][topic schnorr signatures]带来的手续费节省和额外的脚本能耐。如果人们现在转而广泛采用 Bitcoin Core 0.12.1，对比特币网络的影响可能有：无效区块被网络接受的概率（以及相应的区块重组风险）升高、因为旁支区块增多而加重挖矿中心化趋势，运行该版本的矿工的挖矿收益也会降低。

- [<!--when-is-opreturn-cheaper-than-opfalse-opif-->OP_RETURN 会比 OP_FALSE OP_IF 方案更便宜吗？]({{bse}}122321) Vojtěch Strnad 细数了基于 `OP_RETURN` 的数据嵌入方案与基于 `OP_FALSE OP_IF` 的方案的开销，结论是 “`OP_RETURN` 更加便宜，少了 143 字节”。

- [<!--why-does-bip340-use-secp256k1-->为什么 BIP-340 会使用 secp256k1 曲线？]({{bse}}122268) Pieter Wuille 解释了为 [BIP340][] Schnorr 签名选择 secp256k1 曲线而不是 Ed25519 曲线的推理，并指出，“复用现有的公钥派生基础设施” 以及 “不改变安全性假设” 是其中的理由。

- [<!--what-criteria-does-bitcoin-core-use-to-create-block-templates-->Bitcoin Core 使用什么条件来创建区块模板？]({{bse}}122216) Murch 解释 Bitcoin Core 当前为候选区块挑选交易的基于 “祖先交易集合费率” 的算法，还提到了[族群交易池][topic cluster mempool]相关的正在开展的工作，这些工作提供了多种多样的优化。

- [<!--how-does-the-initialblockdownload-field-in-the-getblockchaininfo-rpc-work-->initialblockdownload 字段在 getblockchaininfo RPC 中是如何工作的？]({{bse}}122169) Pieter Wuille 指出，在节点启动之后，`initialblockdownload` 变成假值要满足两个条件：

  1. “当前使用的链拥有至少跟软件硬编码的常量一样高的累积工作量证明”
  2. “当前使用的链的最新区块的时间戳在本地时间的 24 小时以内”

## 新版本和候选版本

*热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Bitcoin Core 26.1rc2][] 是这个主流全节点实现的一个维护版本的候选发布。

- [Bitcoin Core 27.0rc1][] 是这个主流全节点实现的下一个大版本的候选发布。“[推荐测试主题][bcc testing]” 页面提供了一份简要的说明；并且[Bitcoin Core PR Review Club][]还计划在今天（3 月 27 日）的 UTC 时间 15:00 举行一次专门用于测试的的回忆。

## 重大的代码和说明书变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Bitcoin Core #28950][] 更新了 `sumbitpackage` RPC，现可提供 `maxfeerate` 和 `maxburnamount` 参数；如果所提供的交易包的聚合费率高于这个指定的最大值、或者向一个带有众所周知模板的不可花费输出发送了超过指定数额的价值，会导致调用终止、以失败结束。

- [LND #8418][] 开始轮询其连接到的比特币协议客户端、获得其对等全节点的 %#060%# `feefilter` 数值。这个 `feefilter` 消息允许一个节点告知其所连接的对等节点，自己愿意转发的交易的手续费率下限。LND 将使用这个信息来避免发送太低费率的交易。只有来自出站对等节点的 `feefilter` 数值会被使用，因为这些是用户节点自身选择连接的对等节点，比起被动接受连入的入站节点，更不可能被攻击者控制。

- [LDK #2756][] 添加了在其消息中包含一个 “[蹦床路由][topic trampoline payments]” 包裹的支持。这并不能为使用蹦床路由或者提供蹦床路由服务提供完整的支持，但它会让其它使用 LDK 的代码更容易实现完整支持。

- [LDK #2935][] 开始支持向 “[盲化路径][topic rv routing]” 发送 “[Keysend 支付][topic spontaneous payments]”。Keysend 支付是无条件的支付，不需要闪电发票就能发起。盲化路径一般会在发票中编码，所以一般不会跟 Keysend 相结合，但如果一个闪电网络服务商（LSP）或者其它节点希望为某一个接收者提供一个通用的发票，但又不希望揭晓这个接收者的节点 ID，这样的结合就是有用的。

- [LDK #2419][] 为处理 “[交互式交易构造][topic dual funding]” 添加了一个状态机；这种交互流程是双向注资通道和 “[通道拼接][topic splicing]” 技术所依赖的。

- [Rust Bitcoin #2549][] 为了处理相对[时间锁][topic timelocks]而对 API 作了多项变更。

- [BTCPay Server #5852][] 为 [PSBTs][topic psbt] 添加了扫描 BBQr 动态 QR 码的支持（详见[周报 #281][news281 bbqr]）。


{% include references.md %}
{% include linkers/issues.md v=2 issues="28950,8418,2756,2935,2419,2549,5852,27995" %}
[bitcoin core 26.1rc2]: https://bitcoincore.org/bin/bitcoin-core-26.1/
[Bitcoin Core 27.0rc1]: https://bitcoincore.org/bin/bitcoin-core-27.0/test.rc1/
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/27.0-Release-Candidate-Testing-Guide
[news281 bbqr]: /zh/newsletters/2023/12/13/#bbqr
[todd free relay]: https://gnusha.org/pi/bitcoindev/Zfg%2F6IZyA%2FiInyMx@petertodd.org/
[news288 rbfr]: /zh/newsletters/2024/02/07/#proposal-for-replace-by-feerate-to-escape-pinning
[habovstiak boost]: https://gnusha.org/pi/bitcoindev/CALkkCJZWBTmWX_K0+ERTs2_r0w8nVK1uN44u-sz5Hbb-SbjVYw@mail.gmail.com/
[jahr boost]: https://gnusha.org/pi/bitcoindev/45ghFIBR0JCc4INUWdZcZV6ibkcoofy4MoQP_rQnjcA4YYaznwtzSIP98QvIOjtcnIdRQRt3jCTB419zFa7ZNnorT8Xz--CH4ccFCDv9tv4=@protonmail.com/
[harding sponsor]: https://delvingbitcoin.org/t/improving-transaction-sponsor-blockspace-efficiency/696
[news116 sponsor]: /en/newsletters/2020/09/23/#transaction-fee-sponsorship
[towns sponsor]: https://delvingbitcoin.org/t/improving-transaction-sponsor-blockspace-efficiency/696/5
[ismail fees]: https://delvingbitcoin.org/t/mempool-based-fee-estimation-on-bitcoin-core/703
[harding fees]: https://delvingbitcoin.org/t/mempool-based-fee-estimation-on-bitcoin-core/703/2
[alm fees]: https://scalingbitcoin.org/stanford2017/Day2/Scaling-2017-Optimizing-fee-estimation-via-the-mempool-state.pdf
[daftuar sponsor]: https://delvingbitcoin.org/t/improving-transaction-sponsor-blockspace-efficiency/696/6
