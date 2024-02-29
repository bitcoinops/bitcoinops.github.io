---
title: 'Bitcoin Optech Newsletter #289'
permalink: /zh/newsletters/2024/02/14/
name: 2024-02-14-newsletter-zh
slug: 2024-02-14-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报总结了关于 “族群交易池” 部署之后的转发强化措施的讨论，介绍了关于 2023 年 LN 类型的锚点输出的拓扑和规模的研究成果，宣布了 Bitcoin-Dev 邮件组的新主机，还鼓励读者通过表达对自由软件贡献者的感谢来庆祝 “我爱自由软件日”。此外是我们的常规栏目：一次 Bitcoin Core 审核俱乐部会议的总结，还介绍了热门的比特币基础设施软件的重大变更。

## 新闻

- **<!--ideas-for-relay-enhancements-after-cluster-mempool-is-deployed-->族群交易池部署之后可用的转发强化措施**：Gregory Sanders 在 Delving Bitcoin 论坛[发帖][sanders future]分享了在[族群交易池][topic cluster mempool]完全实现、测试和部署之后，让单体交易可以自选特定交易池规则的几种想法。优化建立在 “[v3 交易转发][topic v3 transaction relay]” 特性的基础上，放宽了一部分可能不再需要的规则，并加入了一笔交易（或者一个[交易包][topic package relay]）必须支付让它们可能在接下来一到两个区块内被挖出的手续费率的条件。

- **<!--what-would-have-happened-if-v3-semantics-had-been-applied-to-anchor-outputs-a-year-ago-->如果 v3 语义在一年前就应用到了锚点输出上，那会怎么样？**Suhas Daftuar 在 Delving Bitcoin [分享][daftuar retrospective]了他对自动在[锚点类型][topic anchor outputs]的闪电通道承诺交易和手续费追加交易上应用 [v3 交易转发策略][topic v3 transaction relay]的研究（可在[周报 #286][news286 imbued] 了解其背后的 “渗透 v3 逻辑”）。简而言之，他记录了 2023 年的 1 4124 笔看起来像是花费锚点输出的交易。在这些交易中：

    * 大约 94%<!-- (14124 - 856) / 14124 -->会在 v3 规则下成功。

    * 大约 2.1%<!-- 302/14124 --> 有超过一个父交易（例如，是尝试批量处理 [CPFP][topic cpfp] 花费）。一些闪电钱包会在短时间内关闭超过一条通道时这样做，以提高效率。这些钱包需要禁用这种行为，如果锚点类型的输出要渗透 v3 特性的话。

    * 大约 1.8%<!-- 251/14124 --> 并不是其父交易的第一个子交易。使用渗透 v3 提议，第二个子交易可以在一个[交易包][topic package relay]中替代第一个子交易（详见[周报 #287][news287 kindred]）。

    * 大约 1.2%<!-- 175/14124 --> 似乎是承诺交易的孙交易，也即，花费了花费锚点输出的交易。闪电钱包可能会出于许多原因而这样做，从按顺序关闭多条通道，到使用锚点关闭通道交易的找零输出来开启新通道。如果锚点类型的输出要渗透 v3 特性，闪电钱包将不能再使用这种行为。

    * 大约 1.2%<!-- 173 / 14124 --> 从未被挖出，也无法进一步分析。

    * 大约 0.1%<!-- 19/14124 --> 花费了一个无关的未确认输出，导致锚点花费交易拥有不止一个父交易（不被 v3 允许）。开发者 Bastien Teinturier 认为，这可能是 Eclair 客户端的做法，并指出，在最新的代码中，Eclair 已经自动解决了这种情况。

    * 小于 0.1%<!-- 10/14124 --> 是超过 1000 vbyte 的。这也是闪电钱包需要改变的行为。Daftuar 的进一步分析表明，几乎所有的锚点花费交易都小于 500 vbyte，一定程度上表明 v3 的体积限制进一步缩小。更小的体积限制，将让防守方只需更小的代价就能克服针对一笔锚点花费花费交易的[钉死攻击][topic transaction pinning]，但也会进一步减少闪电钱包可以添加的、用来贡献手续费的输入的数量。Teinturier [说][teinturier better]，“将 1000 vbyte 的限制进一步缩小是很诱人的，但过往的数据只显示了诚实的尝试（待处理的 HTLC 很少），因为我们还没有看到任何对网络的广泛攻击，所以很难说什么数值会 ‘更好’。”

    虽然我们预期该主题还会有额外的讨论和研究，我们从该研究中得出的印象是，在 Bitcoin Core 可以安全地将锚点花费交易按照 v3 交易来处理之前，闪电钱包为了更好地适应 v3 语义而需要改变的部分很少。

- **<!--bitcoindev-mailing-list-move-->Bitcoin-Dev 邮件组迁移**：协议开发讨论的邮件组现在放在了一个新的服务器上，具有一个新的电子邮件地址。如果你希望继续接收帖子，你需要重新订阅。其中的细节请参阅 Bryan Bishop 写的《[邮件组迁移][migration email]》。要了解以往关于迁移的讨论，请看周报 [#276][news276 ml] 和 [#288][news288 ml]。


- **<!--i-love-free-software-day-->我爱自由软件日**：每年的 2 月 14 日，[FSF][] 和 [FSFE][] 这样的组织都会鼓励自由和开源软件（FOSS）的用户 “向所有维护和为自由软件贡献的人高喊 ‘谢谢你！’”。即使你在 2 月 14 日之后才读到本刊，我们依然鼓励拨出片刻，向你最喜欢的比特币 FOSS 项目的贡献者们表示感谢。

## Bitcoin Core 审核俱乐部

*在这个月度栏目中，我们总结最新一期 [Bitcoin Core PR 审核俱乐部][Bitcoin Core PR Review Club] 会议，列出一些重要的问题和回答。点击问题描述，可以见到会上答案的总结。*

“[为 `submitpackage` 添加 `maxfeerate` 和 `maxburnamount` 参数][review club 28950]” 是由 Greg Sanders（GitHub 用户 instagibbs）提出的一项 PR，为 `submitpackage` RPC 添加了已经在针对单交易的 RPC `sendrawtransaction` 和 `testmempoolaccept` 中出现的功能。这个 PR 是更大的 “[交易包转发][topic package relay]” 项目的一部分。具体来说，这个 PR 允许一个交易包的发送者指定参数（就如 PR 的名字所示），这些参数可用于对所请求的交易包中的交易进行安全检查，以防止意外的资金损失。审核俱乐部会议由 Abubakar Sadiq Ismail（GitHub 用户 ismaelsadeeq）主持。

{% include functions/details-list.md
  q0="<!--why-is-it-important-to-perform-these-checks-on-submitted-packages-->为什么要对提交过来的交易包执行这样的检查？"
  a0="这可以帮助用户确保，放在交易包中的交易拥有跟以单体形式提交的交易相同的安全保证。"
  a0link="https://bitcoincore.reviews/28950#l-27"

  q1="<!--are-there-other-important-checks-apart-from-maxburnamount-and-maxfeerate-that-should-be-performed-on-packages-before-they-are-accepted-to-the-mempool-->除了 `maxburnamout` 和 `maxfeerate`，是否还有其它重要的检查，应该在一个交易包被交易池接受之前执行？"
  a1="有的。两个例子是基础手续费检查以及最大标准交易体积。但这是两种低成本的检查，所以可以在早期执行并很快传出错误。"
  a1link="https://bitcoincore.reviews/28950#l-33"

  q2="<!--the-options-maxburnamount-and-maxfeerate-can-prevent-a-transaction-from-entering-the-mempool-and-being-relayed-can-we-consider-these-options-as-policy-rules-why-or-why-not-->`maxburnamount` 和 `maxfeerate` 可以阻止一笔交易进入交易池并被转发。我们可以将这些选项视为一种交易池规则吗？为什么呢？"
  a2="它确实是一种交易池规则；因为这些检查不是应用在已挖出的区块中的交易上的（所以它不是共识规则）。但它们不会影响对等节点之间的交易转发，只会影响在本地通过 RPC 来提交的交易。"
  a2link="https://bitcoincore.reviews/28950#l-47"

  q3="<!--why-do-we-validate-maxfeerate-against-the-modified-feerate-instead-of-the-base-fee-rate-->为什么我们要用 “修饰后费率（modified fee rate）” 来验证 maxfeerate，而不是使用 “基本费率（base fee rate）” 呢？"
  a3="（更早的会议 [24152][review club 24152]、[24538][review club 24538] 和 [27501][review club 27501] 介绍了修饰后费率与基础费率的不同。大部分参与者都认为应该使用基础手续费，而不是修饰后手续费，因为 `sendrawtransaction` 和 `testmempoolaccept` 本身是使用基础手续费的，如果使用相同的标准，会有更好的一致性。但可能在现实中不会有什么差异，因为 `prioritiseansaction`（让修饰后手续费与基础手续费产生差别的因素）基本上只会被矿工使用。"
  a3link="https://bitcoincore.reviews/28950#l-69"

  q4="<!--we-validate-maxfeerate-against-the-modified-feerate-of-individual-package-transactions-not-package-feerate-when-can-this-be-inaccurate-->我们使用包内单笔交易的修饰后费率来验证 maxfeerate，而不是交易包的费率。这在什么时候会不准确吗？"
  a4="在交易包内的一笔子交易会因为自身的修饰后费率超过 `maxfeerate` 而被拒绝、但整个交易包的费率并不超过这个数值时，就会不准确。"
  a4link="https://bitcoincore.reviews/28950#l-84"

  q5="<!--given-that-possible-inaccuracy-why-not-check-maxfeerate-against-package-feerate-instead-->如果有不准确的情形，为什么不用交易包费率来检查 `maxfeerate` 呢？"
  a5="因为这可能会产生另一种不准确。假设交易 A 没有手续费，而交易 B 是为其追加手续费的交易。A 和 B 的体积都很大，所以没有任何一笔的费率超过 `maxfeerate`。"
  a5link="https://bitcoincore.reviews/28950#l-108"

  q6="<!--why-can-t-maxfeerate-be-checked-immediately-after-decoding-like-maxburnamount-is-->为什么 `maxfeerate` 不能在解码之后立即检查，就像 `maxburnamount` 那样？"
  a6="因为，众所周知，交易的输入不会显式地声明输入的数额，只能在查找到父输出之后才能知道。手续费率的计算需要知道手续费，而这又需要知道输入的数额。"
  a6link="https://bitcoincore.reviews/28950#l-141"

  q7="<!--how-does-the-maxfeerate-check-in-testmempoolaccept-rpc-differ-from-submitpackage-rpc-why-can-t-they-be-the-same-->`testmempoolaccept` RPC 中的 `maxfeerate` 与 `submitpackage` RPC 中的检查有何不同？为什么不能是一样的？"
  a7="`submitpackage` 使用了修饰后费率，而 `testmempoolaccept` 使用基础费率，这个前面已经解释了。此外，手续费率检查是在 `testaccept` 交易包处理之后完成的，因为交易要在处理之后才会添加到交易池中并被广播，所以我们可以安全地检查 `maxfeerate` 并返回合适的错误消息。而在 `submitpackage` 中不能采用相同的办法，因为交易包内的交易可能已经被交易池接受了、广播到对等节点了，所以有些检查是多余的。"
  a7link="https://bitcoincore.reviews/28950#l-153"
%}

## 重大的代码和文档变更

*本周出现重点变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Bitcoin Core #28948][] 添加了对 [v3 交易转发][topic v3 transaction relay]的支持（但并不启用），从而允许任何没有未确认父交易的 v3 交易在当前的交易接受规则下进入交易池。v3 交易可以用 [CPFP 追加手续费][topic cpfp]，但是子交易不能超过 1000 vbyte。每一个 v3 父交易在交易池中只能有一个待确认的子交易，而每一个 v3 子交易也只能拥有一个未确认的父交易。无论是父交易还是子交易，都允许[手续费替换][topic rbf]。这套规则仅应用在 Bitcoin Core 的转发策略中；在共识层面，v3 交易的验证规则与 [BIP68][] 所定义的 v2 交易是一样的。新的这套规则旨在帮助闪电通道这样的合约式协议保证预先签名的交易总能快速以尽可能少的额外手续费确认，躲避[交易钉死攻击][topic transaction pinning]。

- [Core Lightning #6785][] 让比特币上使用的通道默认采用[锚点类型][topic anchor outputs]。非锚点类型的通道依然可以用在兼容 Elements 的[侧链][topic sidechains]上。

- [Eclair #2818][] 检测一些现有的未确认交易极不可能得到确认的情况，以尽可能不遗漏 Eclair 钱包认定自身可以安全地花费的输入的数量。Eclair 使用 Bitcoin Core 的钱包模块来管理自身用于链上花费（包括用来追加手续费的交易）的 UTXO。当一个由该钱包控制的 UTXO 用作某一笔交易的一个输入时，Bitcoin Core 钱包不会自动创建其它不相关的交易来使用这个输入。然而，如果该交易因为其中的另一个输入被重复花费而变得无法确认，Bitcoin Core 钱包会自动允许该 UTXO 被用在另一笔交易中。不幸的是，如果一笔交易的父交易因为冲突交易被确认而变得不可确认，Bitcoin Core 钱包当前不会自动允许该交易的 UTXO 被花费。Eclair 可以独立地检测父交易的重复话费交易，然后命令 Bitcoin Core 的钱包[抛弃][rpc abandontransaction] Eclair 更早的花费尝试，以解除 UTXO 的锁定、使之可以再次花费。

- [Eclair #2816][] 允许节点运营者选择自己愿意花费在[Eclair #2816][]中以让承诺交易得到确认最大数额。以前，Eclair 允许花费 5% 的通道价值，但对于高价值的通道来说，这个数额可能太大了。Eclair 现在的默认值是由其手续费估算器所建议的最大手续费率，封顶是 1 0000 聪的绝对值。Eclair 还将支付不超过由于 [HTLCs][topic htlc] 即将到期而处在风险之中的数额，这可能会超过 1 0000 聪。

- [LND #8338][] 添加了用于合作式关闭通道的一种新协议的初步功能（见[周报 #261][news261 close] 和 [BOLTs #1096][]）。

- [LDK #2856][] 更新了 LDK 的 “[路由盲化][topic rv routing]” 实现，以确保接收者有足够多的区块可以申领一笔支付。这基于 [BOLTs #1131][] 中的路由盲化规范的一次更新。

- [Rust Bitcoin #2451][] 移除了一个 HD 派生路径必须以 `m` 开头的要求。在 [BIP32][] 中，字符 `m` 是一个表示主私钥的变量。而在仅仅指代一条路径时，`m` 是不必要的，甚至在一些语境下是错误的。

{% include references.md %}
{% include linkers/issues.md v=2 issues="28948,6785,2818,2816,8338,2856,2442,2451,1131,1096" %}
[fsfe]: https://fsfe.org/activities/ilovefs/index.en.html
[fsf]: https://www.fsf.org/blogs/community/i-love-free-software-day-is-here-share-your-love-software-and-a-video
[sanders future]: https://delvingbitcoin.org/t/v3-and-some-possible-futures/523
[news261 close]: /zh/newsletters/2023/07/26/#simplified-ln-closing-protocol
[teinturier better]: https://delvingbitcoin.org/t/v3-transaction-policy-for-anti-pinning/340/37
[daftuar retrospective]: https://delvingbitcoin.org/t/analysis-of-attempting-to-imbue-ln-commitment-transaction-spends-with-v3-semantics/527/
[news286 imbued]: /zh/newsletters/2024/01/24/#imbued-v3-logic-v3
[news287 kindred]: /zh/newsletters/2024/01/31/#kindred-replace-by-fee
[migration email]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2024-February/022327.html
[news276 ml]: /zh/newsletters/2023/11/08/#mailing-list-hosting
[news288 ml]: /zh/newsletters/2024/02/07/#bitcoin-dev
[review club 28950]: https://bitcoincore.reviews/28950
[review club 24152]: https://bitcoincore.reviews/24152
[review club 24538]: https://bitcoincore.reviews/24538
[review club 27501]: https://bitcoincore.reviews/27501
