---
title: 'Bitcoin Optech Newsletter #225'
permalink: /zh/newsletters/2022/11/09/
name: 2022-11-09-newsletter-zh
slug: 2022-11-09-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报总结了源于在 Bitcoin Core 中增加可启用 “全面 RBF” 交易池策略的持续讨论，并介绍了一个影响 BTCD、LND 等软件的 bug。此外，还有我们的常规栏目：Bitcoin Core PR 审核俱乐部会议的总结、软件的新版本和候选版本介绍，以及热门比特币基础设施软件的重大变更概述。

## 新闻

- **<!--continued-discussion-about-enabling-fullrbf-->关于支持全面 RBF 的持续争论**：前面几期已经提到 —— 用户、服务供应商和 Bitcoin Core 开发者，一直在评估为 Bitcoin Core 开发分支和 24.0 版本的候选版本加入  ` mempoollfullrbf ` 配置选项的影响。前几期周报已经总结了赞成和反对这个[全面 RBF][topic rbf]选项的许多意见（[1][news222 rbf]、[2][news223 rbf]、[3][news224 rbf]）。本周，Suhas Daftuar 在 Bitcoin-Dev 邮件组中[发帖][daftuar rbf]，“主张我们应该继续维护一种转发策略 —— 拒绝不使用（由 BIP125 定义） RBF 信号的交易的替换版本，而且，还应该从 Bitcoin Core 的最新候选版本中移除 `mempoolfullrbf` 标签，并且不再计划发行带有这个标签的软件，除非（或者说直到）网络的环境改变。”他写道：

  - *<!--optin-rbf-already-available-->选择性 RBF 已经可用了*：任何希望享受到 BRF 好处的人，都可以使用 [BIP125][] 所描述的机制有选择地启用。只有出于某些理由无法使用选择性 RBF 的用户，才应该获得全面 RBF 的服务。

  - *<!--full-rbf-doesnt-fix-anything-that-isnt-broken-in-other-ways-->全面 RBF 所修复的东西也可以用别的方式打破*：已经有人[指出][riard funny games]了一种情形：多方协议的某一些用户可以拒绝其他用户使用选择性 RBF。但 Daftuar 指出，这样的协议应对其它便宜的甚至免费的攻击也很脆弱，全面 RBF 实际上无能为力。

  - *<!--full-rbf-takes-away-options-->全面 RBF 剥夺了选择*：“缺乏其它【全面 RBF 可以修复的问题】的例子，对我来说，全面 RBF 没有为 RBF 的用户解决任何问题，他们本来可以自由选择是否给自己的交易使用 BIP125 的 RBF 策略。从这个角度来说，‘启用全面 RBF’ 才是从用户手中剥夺选择，因为他们本可以让自己的交易进入一个不可替换的策略中。”

  - *<!--offering-nonreplacement-doesn’t-introduce-any-issues-for-full-nodes-->提供不可替换的特性并没有为全节点带来任何问题*：实际上，这简化了对一长串的交易的处理。

  - *<!--determining-incentive-compatibility-isn’t-always-straightforward-->有时候并不容易确定激励兼容性*：Daftuar 使用了 v3 交易转发提议（详见[周报 #220][news220 v3tx]）作为一个例子：
  
    > 设想几年后有人提议给软件加入一个 “disable_v3_transaction_enforcement” 的标签，让用户可以决定关闭这些限制性的策略，并对 v3 交易和 v2 交易一视同仁，而且使用的理由可以跟今天为全面 RBF 辩护的理由完全相同 【……】
    >
    > 【那】将颠覆 v3 交易的闪电网络应用场景【……】我们不应该让用户能够禁用这个策略，因为只要这个策略是可选的，而且对那些想要它的有用，为特定的应用制定一套更严密的规则就没有伤害任何人。加入一种可以绕过这些规则的方法只是尝试打破其他人的应用，而不是增加新的应用。我们不应该拿 “激励兼容性” 当作一个大棒，打破那些看起来可以工作而且不会伤害别的用户的代孙希。
    >
    > 我认为现在全面 RBF 正是这种情形。
  
  在邮件的结尾，Daftuar 给那些依然想在 Bitcoin Core 中加入 `mempoolfullrbf` 选项的人提出了三个问题：
  
  1. “全面 RBF 除了打破零确认交易的商业实践之外，还提供了什么好处吗？如果有，在哪里？”
  2. “给所有的交易强制实施 BIP125 的 RBF 规则合理吗？如果这些规则本身并不一定是激励兼容的呢？”
  3. “如果未来某人想提议一种命令行选项，打破 v3 交易转发规则，而且使用的是跟当前走向全面 RBF 相同的利用，有没有什么理论能反对 TA 呢？”
  
  截至本文撰写之时，邮件组中还没有人回答 Daftuar 的问题，虽然在 Daftuar 对 Bitcoin Core 提交的移除  `mempoolfullrbf` 配置选项的 [PR][bitcoin core #26438] 中出现了两个恢复。后来 Daftuar [关闭][26438 close]了这个 PR。
  
- **<!--block-parsing-bug-affecting-multiple-software-->区块解析的 bug 影响了多个软件**：[周报 #222][news222 bug] 报道过，似乎一个会影响 BTCD 全节点和 LND 闪电节点的严重 bug 被意外触发了，导致这些软件的用户处在风险之中。不过升级版软件很快就发布了。在 bug 触发之后，很快 Anthony Towns 就[发现][towns find]了第二个相关的 bug，是只能由矿工触发的 bug。Towns 把这个 bug 报告给了 BTCD 和 LND 的带头维护者  Olaoluwa Osuntokun，后者准备了一个补丁，准备在软件的下一次常规升级中加入。在安全修复中加入其它变更，可以隐藏漏洞被修复的事情，并减少用户被爆破的可能。Towns 和 Osuntokun 都负责任地保守了这个漏洞的秘密，等待这个修复可以部署的时机。

  不幸的是，第二个相关 bug 被人自己重新发现了，TA 找到了一个矿工来触发。这个新 bug 又一次影响了 BTCD 和 LND，但同时也影响了至少[两个其它][liquid and rust bitcoin vulns]项目和服务。所有受影响的系统的用户都应该立即升级。我们重复在周前提出的建议：任何使用比特币软件的人，都应该留心软件的开发团队发出的安全通知。

  在本次周报出版之时，Optech 已经添加了一个特殊的主题页面，列出了我们在 Optech 周报总结过的、[负责任地披露了安全漏洞的杰出人物][topic responsible disclosures]的名字。可能会有一些披露不在列表中，因为它们尚未公开。我们同样感谢所有的提议和 PR 的审核员，他们防范了安全漏洞变成实际发行的软件。

## Bitcoin Core PR 审核俱乐部

*在这个每月一度的栏目中，我们会总结最近一次[Bitcoin Core PR 审核俱乐部][Bitcoin Core PR Review Club]会议的内容，列出一些重要问题和答案。点击下文的问题描述，可以看到会议答案的总结。*

“[Relax MIN_STANDARD_TX_NONWITNESS_SIZE to 65 non-witness bytes][review club 26265]” 是 instagibbs 提出的一项 PR，放松了交易池对排除了见证数据的交易（non-witness transaction）的体积限制。它允许交易的体积小到 65 字节，替代了当前的要求交易至少为 85 字节的策略（见[周报 #222][news222 min relay size]）。

在审核俱乐部会议结束后，这个 PR 被关闭了，大家改为考虑 [#26398][bitcoin core #26398]，后者通过 *仅* 禁用只有 64 字节的交易，进一步地放松了交易池策略。会议也讨论了这两种稍有不同的策略的优点。

{% include functions/details-list.md
  q0="为什么要限制（交易池接受的）交易最小体积为 82 字节？有什么样的攻击呢？"

  a0="这个 82 字节的下限是由 PR [#11423][bitcoin core #11423] 在 2018 年引入的。82 字节本身是最小的标准支付交易的体积。这个 PR 被说成是对标准性规则的一次清理。但事实上，它是为了让 64 字节的交易变成非标准交易，因为 64 字节的交易可以对 SPV 客户端发起 “[欺骗支付攻击][spoof payment attack]”（让客户端以为他们收到了支付，但实际上并没有）。这种攻击的实质是让 SPV 客户端认为一笔 64 字节的交易是交易默克尔树上的一个内部节点，这样的节点恰好是 64 字节的。"

  a0link="https://bitcoincore.reviews/26265#l-35"

  q1="一位参与者提问，有必要秘密地修复这样的漏洞吗？发动这样的攻击可能非常昂贵（大概在 100 万美元量级），同时人们不太可能在处理这样大额的支付时使用 SPV 客户端。"

  a1="一些人同意这种看法，但一位参与者指出我们的直觉可能是错的。"

  a1link="https://bitcoincore.reviews/26265#l-66"

  q2="什么是 “排除了见证数据的部分”？为什么我们要在意交易带不带有见证数据呢？"

  a2="这是因为，作为隔离见证升级的一部分，交易在参与默克尔根的计算时，本身就是不包含见证数据的。攻击需要恶意交易在默克尔树根值的计算中是 64 字节（这样它看起来才会像一个内部节点），因此我们要看排除了见证数据的部分。"

  a2link="https://bitcoincore.reviews/26265#l-62"

  q3="为什么这个策略可以帮助防止这种攻击？"

  a3="因为默克尔树的内部节点只能是 64 字节长，只要不是这个长度的交易，就不会跟默克尔树的内部节点搞混。"

  a3link="https://bitcoincore.reviews/26265#l-84"

  q4="这种攻击界面是不是被完全消除了？"

  a4="改变标准交易的规则只能防止 64 字节的交易被交易池接受和转发，但这样的交易在共识上依然是有效的，所以依然可以挖出。因此，这样的攻击依然是有可能发动的，只不过需要矿工的帮忙。"

  a4link="https://bitcoincore.reviews/26265#l-84"

  q5="为什么我们要把交易的体积下限改为 65 字节？只是为了掩盖 CVE（通用漏洞披露）的话，这是不必的。"

  a5="因为小于 82 字节的交易也有合理的用途。已经提过的一个例子是把全部的父输出都当成手续费的 “[子为父偿(CPFP)][topic cpfp]” 交易（这样的交易只有一个输入，和一个空的  `OP_RETURN` 输出。"

  a5link="https://bitcoincore.reviews/26265#l-100"

  q6="不允许小于 65 字节的交易，和禁止刚好等于 64 字节的交易，这两种方法哪个好一点？这两种方法各有什么样的影响？"

  a6="经过一番关于字节计算的讨论之后，人们同意一笔有效但不标准的交易可以小到 60 字节：除去见证数据，一个原生隔离见证输入是 41 字节 + 10 字节的交易头 + 8 字节的数值 + 1 字节的 `OP_TURE` 或者 `OP_RETURN` 输出 = 60 字节"

  a6link="https://bitcoincore.reviews/26265#l-124"
%}

## 新版本和候选版本

*热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Rust Bitcoin 0.28.2][] 是一个小版本，修复了一个可以 “导致特定某些交易 以及/或者 区块无法反序列化” 的 bug。“目前未观察到任何公链上存在这样的交易。”

- [Bitcoin Core 24.0 RC3][] 是这个最被广泛使用的全节点实现的下一个版本的候选。附带一份[测试指南][bcc testing]。

  **警告**：这个候选版本包含了  `mempoolfullrbf` 配置选项；如本期周报和 [#222][news222 rbf]、[#223][news223 rbf] 所述，多个协议和应用的开发者认为这会给商家服务造成问题。它也可能导致交易转发出现问题（如 [Newsletter #224][news224 rbf] 所述）。Optech 鼓励所有可能会受影响的服务评估这个版本并参与公开讨论。

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo] 和 [Lightning BOLTs][bolts repo]。*

- [Bitcoin Core #26419][] 为验证接口的日志加入了语境，可以详细说明为什么一笔交易会从交易池中移除。
- [Eclair #2404][] 添加了对 “短通道识别符（Short Channel IDentifirer，SCID）” 昵称和 “[零确认通道][topic zero-conf channels]” 的支持（即使通道状态的承诺没有使用 “[锚点输出][topic anchor outputs]”）。
- [Eclair #2468][] 实现了 [BOLTs #1032][]，允许一笔支付（[HTLC][topic HTLC]）的最终接收方接受比自己所请求的更大的数额，而且可以使用比自己所要求的更长的超期时间。以前，使用 Eclair 的接收方遵守 [BOLT4][] 的要求：数额和超期时间都严格等于他们所要求的，但这种精确性意味着一个转发节点可以通过改变稍微改变数值和时间来打探下一跳是否为最终收款方。
- [Eclair #2469][] 延长了它要求最后一个转发节点给予下一跳来结算支付的时间。转发节点不应该知道自己就是最后一个转发节点 —— TA 不应该知道下一跳就是支付的最终收款人。额外的结算时间案例是下一跳可能是一个转发节点而不是最终收款人。这个特性的 PR 描述指出，Core Lightning 和 LDK 已经实现了这种行为。也可以参照上一条关于 Eclair #2468 的介绍。
- [Eclair #2362][] 加入了对 `dont_forward` 标签的支持，用于通道更新（channel update）（来自  [BOLTs #999][]）。通道更新会改变一条通道的参数，而且通常会发送 gossip 消息以通知网络中的其它节点、告知如何使用本通道，但如果一次通道升级消息包含了这个标签，就不会转发给其它节点。
- [Eclair #2441][] 允许 Eclair 开始接收任意体积的、洋葱封装的报错消息。[BOLT2][] 当前建议使用 256 字节的报错消息，但并不禁止使用更长的报错消息；而 [BOLTs #1021][] 现正鼓励使用 1024 字节的报错消息、并使用闪电网络当前的 “类型-长度-数值（TLV）” 语义学来编码。
- [LND #7100][] 更新了 LND 以使用最新版本的 BTCD（作为一个库），修复了上文 *新闻* 部分介绍的区块解析 bug。
- [LDK #1761][] 为发送支付的方法增加了一个 `PaymentID` 参数，调用者可用来防止发送多笔相同的支付。此外，当前的 LDK 可能会不断尝试重新发送一笔支付，而不是像以前那样在继续几个区块的重复失败后停止尝试； `abandon_payemnt` 方法可以用来防止进一步的重发。 
- [LDK #1743][] 提供了一种新的 `ChannelReady` 事件，当一个通道准备好投入使用时，就会触发。值得指出的是，这个事件可以在通道收到一定数量的区块确认后触发，也可以立即触发（在使用[零确认通道][topic zero-conf channels]的时候）。
- [BTCPay Server #4157][] 为一个新版本的结账接口加入了可选的支持。详见这个 PR 的截图和视频预览。
- [BOLTs #1032][] 允许一笔支付（[HTLC][topic HTLC]）的最终接收方接受比自己所请求的更大的数额，而且可以使用比自己所要求的更长的超期时间。这让转发节点更难通过稍微改变支付的参数来确定下一跳是不是支付的接收者。见 Eclair #2468 的描述以了解更多。

{% include references.md %}
{% include linkers/issues.md v=2 issues="26438,26419,5674,2404,2468,2469,2362,2441,7100,1761,1743,4157,1032,1021,999,26398,11423" %}

[bitcoin core 24.0 rc3]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[rust bitcoin 0.28.2]: https://github.com/rust-bitcoin/rust-bitcoin/releases/tag/0.28.2
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/24.0-Release-Candidate-Testing-Guide
[news222 rbf]: /zh/newsletters/2022/10/19/#transaction-replacement-option
[news223 rbf]: /zh/newsletters/2022/10/26/#continued-discussion-about-full-rbf-rbf
[news224 rbf]: /zh/newsletters/2022/11/02/#mempool-consistency
[daftuar rbf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021135.html
[riard funny games]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-May/003033.html
[news220 v3tx]: /zh/newsletters/2022/10/05/#ln-penalty
[news222 bug]: /zh/newsletters/2022/10/19/#btcd-lnd
[liquid and rust bitcoin vulns]: https://twitter.com/Liquid_BTC/status/1587499305664913413
[spoof payment attack]: /en/topics/cve/#CVE-2017-12842
[towns find]: https://twitter.com/roasbeef/status/1587481219981508608
[26438 close]: https://github.com/bitcoin/bitcoin/pull/26438#issuecomment-1307715677
[review club 26265]: https://bitcoincore.reviews/26265
[news222 min relay size]: /zh/newsletters/2022/10/19/#minimum-relayable-transaction-size
