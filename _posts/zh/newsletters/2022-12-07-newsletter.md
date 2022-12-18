---
title: 'Bitcoin Optech Newsletter #229'
permalink: /zh/newsletters/2022/12/07/
name: 2022-12-07-newsletter-zh
slug: 2022-12-07-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报介绍了一种 “临时锚点输出” 的实现，并包含了我们的常规栏目：Bitcoin Core PR 审核俱乐部的总结、软件的新版本和候选版本消息、流行比特币基础设施项目的重大变更简介。

## 新闻

- **<!--ephemeral-anchors-implementation-->临时锚点输出实现**：Greg Sanders 在 Bitcoin-Dev 邮件组中[发帖][sanders ephemeral]称他实现了他的 “临时锚点输出”（详见[周报 #223][news223 anchors]）。“[锚点输出][topic anchor outputs]” 是一种已经存在的技术，凭借 Bitcoin Core 的 “[CPFP carve outs][topic cpfp carve out]” 策略得以实现，并且已经用在闪电网络中，以保证参与一个合约的双方都能使用 “[CPFP][topic cpfp]（子为父偿）” 方法为该合约相关的交易追加手续费。锚点输出有一些缺点 —— 其中一些是很根本的（详见[周报 #224][news224 anchors]）—— 另一些则是可以克服的。

  临时锚点输出基于 [v3 交易转发提议][topic v3 transaction relay]，该提议允许版本号为 3 的交易包含一个零价值的输出、支付给本质上就是 `OP_TURE` 的脚本；该输出允许网络中的任何人使用可花费的 UTXO 为该交易使用 CPFP 追加手续费。这笔用于追加手续费的子交易自身可以被其他人使用可花费的 UTXO 以 RBF 模式追加手续费。结合 v3 交易转发提议的其它部分，人们希望这可以消除一切针对时间敏感型合约协议交易的 “[交易钉死攻击][topic transaction pinning]” 所引发的交易池策略方面的困扰。

  此外，因为任何人都可以为带有临时锚点的交易追加手续费，这种输出可以用在超过两个参与者参与的合约协议中。现有的 Bitcoin Core 的 carve out 规则仅对两个参与者的合约才能可靠工作；而[此前提高参与者数量的尝试][bitcoin core #18725]需要为参与者数量设置任意上限。

  Sander 的临时锚点[实现][bitcoin core #26403]使得我们可以围绕之前由 v3 交易的作者实现的其它转发行为开始测试 v3 交易的整个概念。

## Bitcoin Core PR 审核俱乐部

*在这个月度栏目中，我们会总结最新一期[Bitcoin Core PR 审核俱乐部][Bitcoin Core PR Review Club]会议的内容，提炼出一些重要的问题和答案。点击问题描述可以看到会议对该问题的答案的总结。*

“[追加未确认祖先交易的手续费到目标费率][review club 26152]” 是由 Xekyo（在三月）和 glozow 提出的一项 PR，提升了钱包模块在选用未确认的 UTXO 作为输入时候的手续费估计的准确性。没有这项 PR 的时候，如果被用作输入的一些未确认的交易本身手续费率，低于正在构造的交易的手续费率，则整体手续费率将太低。这个 PR 通过“加速”手续费较低的来源交易、使其手续费达到跟新交易的目标相同的水平，解决了这个问题。

注意，即使没有这项 PR，选币的流程也会尝试避免花费低手续费的未确认交易。这个 PR 仅在无法避免的时候有所帮助。

事实证明，调整手续费以兼顾祖先交易的过程类似于选择打包哪些交易的过程，所以这个 PR 增加了一个类，名为 `MiniMiner`。

这个 PR 的[审核][review club 26152]持续了两[周][review club 26152-2]。

{% include functions/details-list.md
  q0="<!--what-problem-does-this-pr-address-->这个 PR 解决了什么问题？"
  a0="钱包的手续费估计方法没有考虑到交易可能需要为所有未确认的祖先交易支付手续费 —— 它们的手续费率可能低于目标手续费率。"
  a0link="https://bitcoincore.reviews/26152#l-30"

  q1="<!--what-does-a-transaction-s-cluster-consist-of-->一笔交易的 “族” 由什么组成？"
  a1="交易的族由其自身以及所有 “相关联” 的交易组成，包括其所有的祖先以及所有的后代，但也包括其兄弟姐妹和堂表兄弟，即，共享同一祖先交易，但并不是其祖先也不是其后代的交易。"
  a1link="https://bitcoincore.reviews/26152#l-72"

  q2="<!--this-pr-introduces-miniminer-which-duplicates-some-of-the-actual-miner-s-algorithms-would-it-have-been-better-to-unify-these-two-implementations-through-refactoring-->这个 PR 引入了 `MiniMiner` 方法，它复制了一部分的矿工算法；通过重构来统一这两种实现会更好吗？"
  a2="我们只需要对一族交易操作，不需要对整个交易池操作，而且不需要应用 `BlockAssembler` 中的任何一项检查。而且还建议在不设交易池锁的条件下运行计算。我们也需要改变区块组装器，不过这是为了跟踪追加的手续费，而不是为了建立区块模板；必要的重构代码量跟重写的代码量是相同的。"
  a2link="https://bitcoincore.reviews/26152#l-94"

  q3="<!--why-does-the-miniminer-require-an-entire-cluster-why-can-t-it-just-use-the-union-of-each-transaction-s-ancestor-sets-->为什么 `MiniMiner` 需要一整个交易族？为什么不能只使用每个交易的祖先集合的并集呢？"
  a3="有一些祖先交易可能已经得到了其它某一些后代交易的偿付，因此它们不需要进一步追加。所以，我们需要在我们的计算中包含其它的后代。"
  a3link="https://bitcoincore.reviews/26152#l-129"

  q4="<!--if-transaction-x-has-a-higher-ancestor-feerate-than-independent-transaction-y-is-it-possible-for-a-miner-to-prioritize-y-over-x-that-is-mine-y-before-x-->如果交易 X 有一个祖先交易，其手续费率比单体交易 Y 更高，矿工有没有可能优先打包 Y 而不是 X（就是先考虑 Y，再考虑 X）？"
  a4="当然，如果 Y 的某个低手续费的祖先有另一个高手续费的后代的话，这时候 Y 不必为这些祖先 “偿付”。Y 的祖先集会更新，以排除这些交易，因为它们有增加 Y 的祖先交易的手续费率的效果。"
  a4link="https://bitcoincore.reviews/26152#l-169"

  q5="<!--can-calculatebumpfees-overestimate-underestimate-both-or-neither-by-how-much-->`CalculateBumpFees()` 有没有可能会估计过高、过低？都会还是都不会？偏离多少呢？"
  a5="如果选用了两个具有重叠的祖先的输入的话，它会过高估计所需的手续费率，因为每个输入都为其祖先追加了手续费（不会考虑到它们有共同的祖先）。参与者们断定不可能低估需要追加的手续费。"
  a5link="https://bitcoincore.reviews/26152#l-194"

  q6="<!--the-miniminer-is-given-a-list-of-utxos-outpoints-that-the-wallet-might-be-interested-in-spending-given-an-outpoint-what-are-its-five-possible-states-->`MiniMiner` 会被输入一个钱包可能想花费的 UTXO（输出点）的列表。给定一个输出点，它有哪些可能的状态？"
  a6="它有五种状态：（1）已确认且未花费的；（2）已确认，但已经被交易池中的交易用作输入；（3）未确认（还在交易池中）且未花费；（4）未确认，但已经被交易池中的交易花费掉；（5）是一笔我们从未收到过的交易的输出点。"
  a6link="https://bitcoincore.reviews/26152-2#l-21"

  q7="<!--what-approach-is-taken-in-the-bump-unconfirmed-parent-txs-to-target-feerate-commit-->“追加未确认祖先交易的手续费到目标费率” 提交采用了什么方法？"
  a7="这次提交是主要行为改变的 PR。我们使用 `MiniMiner` 来计算每个 UTXO 需要追加的手续费（为对应的祖先交易追加手续费到目标费率而需投入的价值），并从其实际价值中减去这部分。然后我们就运行选币算法，跟原来一样。"
  a7link="https://bitcoincore.reviews/26152-2#l-100"

  q8="<!--how-does-the-pr-handle-spending-unconfirmed-utxos-with-overlapping-ancestry-->那么这个 PR 又如何处理花费拥有重叠的祖先的未确认 UTXO 的问题呢？"
  a8="在选好要花费的币之后，我们会对每一个选币算法的结果运行 `MiniMiner` 算法的一个变种，以获得准确的需要追加的价值。如果我们因为存在共有的祖先而过度追加手续费，我们可以通过提高找零输出的价值来降低手续费（如果有的话），或者如果没有找零输出，我们可以增设一个找零输出。"
  a8link="https://bitcoincore.reviews/26152-2#l-111"
%}

## 新版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [BTCPay Server 1.7.1][] 是比特币最流行的用户自主托管的支付处理软件的最新版本。

- [Core Lightning 22.11][] 是 CLN 的下一个大版本。它也是第一个使用新的版本编号方案 [^semver] 的版本。包括多项新特性（包括新的插件管理器），修复了多项 bug。

- [LND 0.15.5-beta][] 是 LND 的一个维护版本。根据发布声明，它仅包含了几项较小的 bug 修复。

- [BDK 0.25.0][] 是这个用于构建钱包软件的库的新版本。

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo] 和 [Lightning BOLTs][bolts repo]。*

- [Bitcoin Core #19762][] 升级了 RPC 接口（以及，相应的 `bitcoin-cli`），以允许同时使用带命名的参数和位置参数。这一变更将允许用户不必注明每个参数的命名，就能直接使用。PR 的描述页提供了案例，演示了这个方法的增强便利性，以及为 `bitcoin-cli` 高频用户准备的一个有用的 shell 缩写。

- [Core Lightning #5722][] 添加了关于如何使用 GPRC 接口插件的[文档][grpc doc]。

- [Eclair #2513][] 升级了它使用 Bitcoin Core 钱包的方法，以保证总是将找零发送到 P2WPKH 输出中。这是 [Bitcoin Core #23789][] 的成果（见[周报 #181][news181 bcc23789]） ，该 PR 解决了新的输出类型（例如 [taproot][topic taproot]）的采用者的一项有关隐私性的困扰。以前，如果用户将钱包默认地址类型设为 taproot 的钱包，那么钱包（在支付时）也会创建 taproot 类型的找零输出。如果他们给非 taproot 用户支付，第三方很容易就能断定哪个输出是支付（非 taproot 的输出），哪个输出是找零（taproot 的输出）。在这一变更之后，Bitcoin Core 会默认尝试给找零输出使用跟支付输出相同的类型，例如，给原生 segwit 输出支付，则找零输出也会是原生 segwit 类型的。

    但是，闪电网络要求使用特定的输出类型。例如，一个 P2PKH 输出不能用来开启闪电通道。因此，搭配 Bitcoin Core 的 Eclair 用户需要保证他们不会生成不兼容闪电网络的找零输出。

- [Rust Bitcoin #1415][] 开始使用 “[Kani Rust 验证器][Kani Rust Verifier]”，来证明 Rust Bitcoin 代码的一些特性。这补充了对代码执行的其它持续集成测试，例如模糊测试（fuzzing）。

- [BTCPay Server #4238][] 为 BTCPay 的 Greenfield API 添加了一种发票退款端口；Greenfield API 是一种更新的 API，有别于最初的 BTC-inspired API。

## 脚注

[^semver]:
    本周报的前一版声称 Coin Lightning 使用了“[带语义的版本号][semantic versioning]” 方案，而且新版本在未来会继续使用这种方案。Rusty Russell [解释了][rusty semver]为什么 CLN 不能完全遵守这个方案。感谢 Matt Whitlock 提醒我们这个错误。


{% include references.md %}

{% include linkers/issues.md v=2 issues="19762,5722,2513,1415,4238,18725,26403,23789" %}
[lnd 0.15.5-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.5-beta
[core lightning 22.11]: https://github.com/ElementsProject/lightning/releases/tag/v22.11
[btcpay server 1.7.1]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.7.1
[bdk 0.25.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.25.0
[semantic versioning]: https://semver.org/spec/v2.0.0.html
[grpc doc]: https://github.com/cdecker/lightning/blob/20bc743840bf5d948efbf62d32a21a00ed233e31/plugins/grpc-plugin/README.md
[news181 bcc23789]: /en/newsletters/2022/01/05/#bitcoin-core-23789
[kani rust verifier]: https://github.com/model-checking/kani
[news223 anchors]: /zh/newsletters/2022/10/26/#ephemeral-anchors
[news224 anchors]: /zh/newsletters/2022/11/02/#anchor-outputs-workaround
[news220 v3tx]: zh/newsletters/2022/10/05/#ln-penalty
[sanders ephemeral]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-November/021222.html
[review club 26152]: https://bitcoincore.reviews/26152
[review club 26152-2]: https://bitcoincore.reviews/26152-2
[rusty semver]: https://github.com/ElementsProject/lightning/issues/5716#issuecomment-1322745630
