---
title: 'Bitcoin Optech Newsletter #48'
permalink: /zh/newsletters/2019/05/29/
name: 2019-05-29-newsletter-zh
slug: 2019-05-29-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 介绍新提出的 `OP_CHECKOUTPUTSHASHVERIFY` 操作码，梳理围绕 Taproot 的持续讨论，并给出一段讲解如何应对比特币交易手续费上涨的视频。常规章节照旧包括：bech32 发送支持、Bitcoin Stack Exchange 上得票最高的问答，以及热门比特币基础设施项目中的值得注意的变更。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}
{% include specials/2019-exec-briefing/zh/fees.md %}

## 行动项

*本周无。*

## 新闻

- **<!--proposed-new-opcode-for-transaction-output-commitments-->****提议的新交易输出承诺操作码：** Jeremy Rubin 在 Bitcoin-Dev 邮件列表中发帖提议，通过软分叉引入 `OP_CHECKOUTPUTSHASHVERIFY` 操作码，让比特币地址可以要求花费它的交易必须包含某一组特定的输出。这实现了一种受限形式的比特币契约（covenant），在某些场景下能减少需要上链的数据量，从而可能降低成本或改善隐私。详情请见本期 Newsletter 的[提案专节][special section about the proposal]。

- **<!--continued-discussion-about-bip-taproot-and-bip-tapscript-->****关于 bip-taproot 和 bip-tapscript 的持续讨论：** 本周 Bitcoin-Dev 邮件列表上的两条评论特别值得注意：

  - **<!--final-stack-empty-->***最终堆栈为空：* 在传统脚本、segwit 脚本和提议的 [bip-tapscript][] 脚本中，只要脚本里恰好有一个*真*值元素，脚本就算执行成功。Russell O'Connor [提出][emptystack1]了他此前已经[提过][emptystack0]的一个观点，并请求趁这次机会要求 tapscript 只有以空堆栈结束时才算执行成功。Pieter Wuille [回复][emptystack reply]说，他在 [miniscript][] 上的工作（见 [Newsletter #32][]）表明，对 miniscript 会生成的那部分脚本而言，这一语义变化最多只能省下 0.25 vbytes。另外，虽然这一改动或许能让手写脚本的人省点事，但它有些风险：迄今为止每一份 Script 开发指南都教导说，脚本结束时堆栈上必须留下一个*真*值。Wuille 总结道：“所以总体而言，这感觉像是一件有边际成本、收益也最多只是边际的事情。”

  - **<!--move-the-oddness-byte-->***挪动奇偶位字节：* 比特币公钥最自然的表示方式是 X、Y 坐标对，比特币早期使用的[未压缩公钥][uncompressed public keys]就是这样。然而，由于有效公钥必须落在椭圆曲线上，给定任意 X 坐标，按曲线公式总能找到两个有效的 Y 坐标（一奇一偶）。在压缩密钥格式中，第一个字节里有一位用来指明 Y 坐标是奇数还是偶数，其后 32 字节编码 X 坐标。提议的 bip-taproot 沿用了这一惯例，用 33 字节编码 taproot 输出密钥。

    本周，John Newbery [建议][smaller v1 spk]想办法不要把这个字节放进 scriptPubKey。Wuille 认为这可能有用，并将尝试实现一种变体，把这个位并入 taproot 见证数据。这样创建一笔 taproot 输出就能省下 1 vbyte（与目前的 P2WSH 相同）。

- **<!--presentation-a-return-to-fees-->****演讲：重谈手续费：** 本月早些时候的纽约区块链周期间，Bitcoin Optech 贡献者 Mike Schmidt 在 Optech 首场面向高管的简报会上做了关于比特币交易手续费的演讲。他演讲的[视频][vid return to fees]现已上线。{{return-to-fees-zh}}

## 提议的交易输出承诺

[提议的][bip-coshv] `OP_CHECKOUTPUTSHASHVERIFY` 操作码让一个 Taproot 地址可以承诺一个或多个 tapscript，要求花费它们的交易必须包含某一组输出——这种技术在合约协议研究者口中称为*契约（covenant）*。这个提议操作码最主要的卖点是：可以趁现在（手续费可能较高时）先确认一笔小交易，再由这笔交易无需信任地保证，一组人将在日后手续费较低时收到各自真正的付款。对那些已经用上[支付批处理][topic payment batching]之类技术的组织来说，这能让它们应付手续费骤涨时省钱得多。

在看这个新操作码本身之前，我们先花点时间看看，用现有的比特币交易功能可以怎样实现类似的效果。

Alice 想付钱给十个人，但眼下交易手续费很高，她既不想发十笔独立交易，也不想用支付批处理把这些收款方各自的输出塞进一笔交易里。她想的是：无需信任地承诺日后付款，而现在不必为十个输出支付上链手续费。于是 Alice 向每个收款方索取一个公钥，构造一笔未签名、未广播的*准备*交易，用 10-of-10 多重签名脚本付给这些公钥。接着她再构造一笔子交易，从多重签名输出花到她最初想创建的 10 个输出上。我们把这笔子交易称为*分发*交易。她请所有收款方为这笔分发交易签名，并确保每人都拿到其他所有人的签名，然后自己签名并广播那笔准备交易。

![一个准备交易支付预签名的分发交易](/img/posts/2019-05-tx-tree-1.png)

当准备交易获得合理数量的确认时，Alice 就无法收回对 10 个收款方的付款了。只要每个收款方有一份分发交易及其他人的签名，就没有办法让任何收款方骗取其他收款方的付款。因此，即使实际上支付收款方的分发交易尚未广播或确认，这些付款也由已确认的准备交易保障。在任何时候，任何想花钱的收款方都可以广播分发交易并等待确认。

这项技术让付款方和收款方能在手续费高的时候先把一组付款锁定下来，等手续费降了再真正分发给各人。按本文写作时 Bitcoin Core 的手续费估算，任何人只要愿意等上一周让交易确认（就像上面那笔分发交易），都能省下一大笔手续费。我们就以上面的例子、在这个背景下算一算。为了让后文与 Taproot 的对比更公平，我们假设采用了某种形式的密钥与签名聚合，例如 [MuSig][]，或（理论上）多方 ECDSA（见 [Newsletter #18][]）。

{% assign p2wpkh = "A transaction spending one P2WPKH input to two P2WPKH outputs" %}
{% assign batched11 = "A transaction spending one P2WPKH input to eleven P2WPKH outputs, or 9*(8+1+22) more bytes than the two-output P2WPKH transaction" %}
{% assign batched10 = "A transaction spending one P2WPKH input to ten P2WPKH outputs, or 8*(8+1+22) more bytes than the two-output P2WPKH transaction" %}

|                     | 独立付款              | 批量付款              | 现在承诺，以后分发        |
|---------------------|-----------------------|-----------------------|-----------------------|
| 即时（高费率）交易  | 10x<abbr title="{{p2wpkh}}">141 vbytes</abbr> | 1x<abbr title="{{batched11}}">420 vbytes</abbr> | 1x<abbr title="{{p2wpkh}}">141 vbytes</abbr> |
| 0.00142112 BTC/KvB 时的成本 | 0.00204641 BTC         | 0.00059687 BTC         | 0.00020037 BTC         |
| 延迟（低费率）交易  | ---                   | ---                   | 1x<abbr title="{{batched10}}">389 vbytes</abbr> |
| 0.00001014 BTC/KvB 时的成本 | ---                   | ---                   | 0.00000394 BTC         |
| 总 vbytes          | 1,410                 | 420                   | 530                   |
| 总成本             | 0.00204641 BTC         | 0.00059687 BTC         | 0.00020431 BTC         |
| **与前一列相比的节省** | ---                   | **71%**               | **66%**               |

可以看到，这种无需信任的延迟付款比支付批处理省 66%，比逐笔单独付款省 90%。要注意，在费率分化更明显的时期，或者收款方超过十个时，节省幅度还会更大。

### CheckOutputsHashVerify

提议的软分叉会新增一个操作码 `OP_CHECKOUTPUTSHASHVERIFY`（作者把它缩写为 `OP_COSHV`，多出来的那个 *S* 是这么来的）。这个操作码连同一段哈希摘要可以放进 tapleaf 脚本，从而成为某个 Taproot 地址的条件之一。花费该地址时，如果执行到了 COSHV，那么只有花费交易的输出哈希摘要与 COSHV 从脚本中读到的摘要一致，这笔交易才有效。

对比上面的例子，Alice 依然要向每个参与者索取一个公钥（例如 Taproot 地址[^taproot-pubkeys]）。和之前一样，她会构造 10 个输出，各自付给一位收款方——但她不必把这些输出拼成某一笔具体的分发交易。她只需把这十个输出放在一起做哈希，再用得到的摘要创建一个包含 COSHV 的 tapleaf 脚本。在这个 Taproot 承诺里，这就是唯一的 tapleaf。Alice 还可以用参与者的公钥构造 taproot 内部密钥，让他们能够协作花费这笔钱，而不必暴露 Taproot 脚本路径。

![一个准备交易支付 COSHV 输出，该输出扩展为分发交易](/img/posts/2019-05-tx-tree-2.png)

接下来，Alice 会把这十个输出的副本发给每一位收款方，好让各人验证：Alice 的准备交易在获得适当确认后，确实保障了自己的付款。日后想支取这笔钱时，任何一位收款方都能构造一笔包含这些已承诺输出的分发交易。与上一小节的例子不同，他们无需预先签名任何东西，因此彼此之间也用不着交互。更进一步，为了让收款方能验证准备交易并最终花掉自己的钱，Alice 需要发给他们的那些信息，完全可以走现有的异步通信途径，例如电子邮件或云盘。这意味着 Alice 创建并发送准备交易时，收款方不必在线。

去掉“必须交互”这一要求，是这个提案的一大亮点。设想上面那个例子里 Alice 是一家交易所：交互式的协议要求她从每位参与者提交提款申请的那一刻起，让这十个人一直在线、一直连着她的服务，直到交互结束——而且他们每个人都得用支持这种子交易签名协议的钱包。而用 COSHV 的非交互形式，只需要他们提供一个比特币地址和一个电子邮件地址（或任何其他能接收已承诺输出的协议地址）。

### 反馈和激活

截至本文写作时，该提案在 Bitcoin-Dev 邮件列表上收到了 30 多条回复。各方提出的疑虑包括：

- **<!--not-flexible-enough-->****不够灵活：** Matt Corallo [表示][coshv flex]：“我们需要一个更灵活的方案，能提供比这更多的功能，否则就可能出现这种情况：我们好不容易把它加进去，等人们要求更好的方案时又得把整套工作重来一遍。”

- **<!--not-generic-enough-->****不够通用：** Russell O'Connor 建议，COSHV 和 `SIGHASH_ANYPREVOUT`（见[上周的 Newsletter][Newsletter #47]）都可以用 `OP_CAT` 加 `OP_CHECKSIGFROMSTACK` 两个操作码来替代。这两个操作码目前已在 [ElementsProject.org][] 的侧链（例如 [Liquid][blockstream liquid]）中实现。`OP_CAT` 把两个字符串拼接成一个字符串；`OP_CHECKSIGFROMSTACK` 则把堆栈上的签名与堆栈上的其他数据作比对，而不是与包含该签名的交易作比对。有了拼接，脚本就可以内置消息的若干片段，这些片段在花费时与见证元素拼合起来，构成一条完整消息，再交给 `OP_CHECKSIGFROMSTACK` 验证。

  由于被验证的消息可以是一笔比特币交易——包括付款方正想发出的那笔交易的部分副本——这些操作让脚本能对交易数据作判断，而不必直接读取正在求值的交易。作为对比，COSHV 看的是输出的哈希，anyprevout 看的是交易中所有其他签名。

  cat/checksigfromstack 方案一个可能很严重的缺点是：脚本更大、见证元素更多，就需要更大的见证来容纳。O'Connor 指出，一旦明确有相当多的用户通过通用模板用上了这些功能，他不介意再换成更简洁的实现（如 COSHV 和 anyprevout）。

- **<!--not-safe-enough-->****不够安全：** Johnson Lau 指出，COSHV 允许类似 [BIP118][] noinput 的签名重放，而 [bip-anyprevout][] 正是费尽力气要消除这一风险。

Rubin 等人对每一条疑虑至少都给出了初步回应。我们预计讨论还会继续，届时会在今后几周里汇报任何重大进展。

[COSHV 的提议 BIP][bip-coshv] 建议它可以与 bip-taproot 一起激活（如果用户愿意的话）。由于 bip-taproot 本身仍在讨论中，我们不建议大家指望两者会捆绑激活。未来的讨论与实现测试会说明，每个提案是否已经足够成熟、足够有吸引力、也足够受用户支持，从而值得加入比特币。

总体而言，COSHV 似乎提供了一种简单（但巧妙）的办法，让输出可以承诺自己的资金最终能被送到哪里。下周的 Newsletter 中，我们会看看 COSHV 还有哪些用法能提升效率、隐私或两者兼得。

## Bech32 发送支持

*这是 [bech32 系列][bech32 series] 24 周中的第 11 周，该系列讲的是如何让你付款的对象享受到 segwit 的全部好处。*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption wiki page for changes -->{% endcomment %}

{% include specials/bech32/zh/11-only-bech32.md %}

**更正 Newsletter #46：** 我们关于 bech32 QR 码的部分错误地声称，带有附加参数的 BIP21 URI 中使用的 bech32 地址不能使用 QR 大写字母数字模式。Nadav Ivgi 亲切地[通知我们][ivgi tweet]，QR 码可以混合模式。我们已更新[该段落][updated qr paragraph]，补上了正确的说法和更多细节，并新增了一组 QR 码示例。

*如果你在 Optech 的 Newsletter 或其他文档中发现任何错误，请发[电子邮件][optech email]、[推文][optech twitter]给我们，或通过其他方式联系我们的[贡献者][optech contributors]。*

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们有点空闲时帮助好奇或困惑用户的地方。在本月栏目中，我们精选自上次更新以来得票最高的一些问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{%
endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--what-are-the-limitations-for-amortizing-the-interactive-session-setup-of-musig-->**[MuSig 交互会话设置的摊销限制是什么？]({{bse}}87605)
  Richard Myers 想为低带宽系统优化交互式设置流程，用户 nickler 则强调 nonce 绝不能重用，否则私钥可能泄露。nickler 还给出了几种办法，帮助 Myers 达成目标。

- **<!--on-chain-cost-of-segwit-version-1-versus-version-0-->**[链上成本：Segwit 版本 1 与版本 0 的比较？]({{bse}}87697)
  用户 Wapac 想知道 segwit v0 与 v1 在交易重量上的差别，尤其是针对比较简单的单密钥交易。Andrew Chow 给出了字节级的细节，并得出结论：花费 v1 输出总是更便宜，而创建 v0 输出可能更便宜。不过 Andrew 指出，发送方通常没多少选择权决定自己付给哪类输出，所以即便是单密钥交易，用户可能也更青睐 v1。Wapac 也写了一个带汇总表的回答。

- **<!--does-v1-segwit-include-v0-->**[v1 Segwit 包含 v0 吗？]({{bse}}87612) Pieter Wuille 表示不行：在 [v1 花费][bip-tapscript]里不能用 [v0 脚本][BIP141]。他进一步解释说，原因在于要满足 v1 背后的某些目标，就必然与 v0 脚本的某些特性不兼容。

- **<!--fee-negotiations-in-lightning-->**[闪电网络中的手续费协商。]({{bse}}87586) Mark H 以一笔四跳的 LN 支付为例，说明了手续费是如何协商的。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和[比特币改进提案（BIPs）][bips repo]中的值得注意的变更。*

- [LND #3098][] 增加了守护进程等待由远程对等节点启动的通道注资交易确认的最大块数，从 288 块（两天）增加到 2,016 块（两周）。这让有耐心的用户可以少付交易手续费。

- [C-Lightning #2647][] 指定了一个默认的插件目录，即使未指定 `--plugin` 或 `--plugin-dir` 配置参数，也会从该目录自动加载插件。目前这是闪电守护进程配置目录中的 `plugins` 目录。

- [C-Lightning #2650][] 新增一个插件钩子，在远程对等节点尝试与本地节点开通道时触发。这让插件可以在通道开启之前拒绝该请求，或执行其他操作。

- [Eclair #952][] 新增 `sendtoroute` 方法，允许用户手动指定一笔支付最初经由哪条通道路由。这让他们可以决定让哪些通道的资金被抽干。

- [Eclair #965][] 允许用户在创建发票时指定原像（preimage）。这可服务于那些需要安全生成不可猜测发票标识符的系统，例如[原子交换][atomic swap]，或把一组合约条款与 nonce 一起用于 [pay-to-contract 格式][p2c]。

## 新出版计划

从本周开始，Optech Newsletter 将改为每周三发布，而不是每周二。这将给我们额外的一个工作日来审查和编辑 Newsletter 草稿。

## 特别感谢

我们感谢 Jeremy Rubin 和 Anthony Towns 审阅本期 Newsletter 草稿，并向我们讲解输出树这一构想。还要感谢 Pieter Wuille 帮我们弄清用 MuSig 聚合密钥与签名时究竟哪些环节需要交互。本期 Newsletter 正式版本中的任何错误，都由作者负责。

## 脚注

[^legacy-cleanstack]:
    Segwit v0（P2WSH）和 Tapscript 提案要求最终堆栈中只有一个*真*元素，脚本才算成功。这称为*清洁堆栈（cleanstack）*规则。而裸输出和 P2SH 输出的传统脚本允许堆栈里有多个元素，只要脚本结束时栈顶元素为*真*，就算成功。不过，不满足清洁堆栈的传统交易不会被 Bitcoin Core 的默认内存池策略中继，也不会被打包。清洁堆栈规则有助于减少交易可延展性：只要在 scriptSig 或见证中增加或删除多余元素，交易的费率就会改变，（对传统交易而言）txid 也会变。

[^taproot-pubkeys]:
    提议的 Taproot 地址格式（v1 segwit 地址）直接在地址中包含一个公钥，因此任何拥有一组 Taproot 地址的人都可以使用它们创建一个聚合公钥。然而，一些用户可能会使用没有人拥有（或能合理生成）相应私钥的公钥来创建 Taproot 地址。因此，任何创建聚合公钥的人可能不应该假设 Taproot 地址本身就是公钥，应该收集单独的公钥。此外，最好不要在比特币的多个地方重用同一个公钥。为了简化对 COSHV 的描述，我们在本 Newsletter 的示例中省略了收集公钥的额外步骤。在你实现从本期 Newsletter 或互联网上任何其他地方读到的协议之前，请考虑先咨询一位比特币专家。

{% include linkers/issues.md issues="3098,2647,2650,952,965" %}
[channel factories]: https://www.tik.ee.ethz.ch/file/a20a865ce40d40c8f942cf206a7cba96/Scalable_Funding_Of_Blockchain_Micropayment_Networks.pdf
[p2c]: https://arxiv.org/abs/1212.3257
[atomic swap]: https://en.bitcoin.it/wiki/Atomic_swap
[emptystack1]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-May/016935.html
[emptystack0]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-December/016558.html
[emptystack reply]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-May/016947.html
[elliptic curve]: https://en.wikipedia.org/wiki/Elliptic_curve
[smaller v1 spk]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-May/016943.html
[vid return to fees]: https://www.youtube.com/watch?v=ihUQ4C42KUk
[coshv flex]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-May/016936.html
[elementsproject.org]: https://elementsproject.org/
[blockstream liquid]: https://blockstream.com/liquid/
[catenates]: https://en.wiktionary.org/wiki/catenate
[uncompressed public keys]: https://btcinformation.org/en/developer-guide#public-key-formats
[ivgi tweet]: https://twitter.com/shesek/status/1131733590235131905
[updated qr paragraph]: /zh/bech32-sending-support/#qrcode-edit
[optech twitter]: https://twitter.com/bitcoinoptech
[optech contributors]: /en/about/#contributors
[special section about the proposal]: #提议的交易输出承诺
[bech32 series]: /zh/bech32-sending-support/
[newsletter #32]: /zh/newsletters/2019/02/05/#miniscript
[newsletter #18]: /zh/newsletters/2018/10/23/#two-papers-published-on-fast-multiparty-ecdsa
[newsletter #47]: /zh/newsletters/2019/05/21/#proposed-anyprevout-sighash-modes
[musig]: https://eprint.iacr.org/2018/068
[miniscript]: /en/topics/miniscript/
