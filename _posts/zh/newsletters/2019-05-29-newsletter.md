---
title: 'Bitcoin Optech Newsletter #48'
permalink: /zh/newsletters/2019/05/29/
name: 2019-05-29-newsletter-zh
slug: 2019-05-29-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了新提议的 `OP_CHECKOUTPUTSHASHVERIFY` 操作码，涵盖了对 Taproot 的持续讨论，并链接到关于处理比特币交易费增加的视频演示。此外，我们的常规栏目还包括 Bech32 发送支持、最高投票的 Bitcoin Stack Exchange 问答以及流行比特币基础设施项目的显著变化。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}
{% include specials/2019-exec-briefing/zh/fees.md %}

## 行动项

*本周无。*

## 新闻

- **<!--proposed-new-opcode-for-transaction-output-commitments-->****提议的新交易输出承诺操作码：** Jeremy Rubin 在 Bitcoin-Dev 邮件列表中发布了一项提议，建议通过软分叉引入 `OP_CHECKOUTPUTSHASHVERIFY` 操作码，该操作码允许比特币地址要求花费该地址的交易包含一组特定的输出。这使得比特币契约的一种受限制形式成为可能，可以在某些情况下减少需要上链的数据量，从而可能降低成本或改善隐私。详情请参见本 Newsletter 的[提案特别部分][special section about the proposal]。

- **<!--continued-discussion-about-bip-taproot-and-bip-tapscript-->****关于 bip-taproot 和 bip-tapscript 的持续讨论：** 本周 Bitcoin-Dev 邮件列表中的两条评论显得特别值得注意：

  - **<!--final-stack-empty-->***最终堆栈为空：* 在传统、segwit 和提议的 [bip-tapscript][] 脚本中，如果脚本仅包含一个*真*值元素，则脚本评估成功。Russell O'Connor [提出][emptystack1]了他之前[提出过][emptystack0]的一个观点，并请求利用这个机会要求 tapscript 仅在以空堆栈结束时才评估成功。Pieter Wuille [回复][emptystack reply]说，他在 [miniscript][] 上的工作（参见 [Newsletter #32][]）表明，对于 miniscript 将创建的脚本子集，这种语义变化最多将节省 0.25 vbytes。此外，虽然这种变化可能简化手工编写脚本的开发，但它有一定的风险，因为迄今为止所有的 Script 开发指南都教导脚本必须在堆栈上终止时有一个*真*值。Wuille 总结道：“所以总体来说，这看起来像是有边际成本，但也最多只有边际收益的事情。”

  - **<!--move-the-oddness-byte-->***移动奇数字节：* 比特币公钥最自然的表示方式是使用 X、Y 坐标对，就像比特币早期使用[未压缩公钥][uncompressed public keys]一样。然而，由于有效的公钥必须位于椭圆曲线上，因此可以根据曲线公式为任何给定的 X 坐标找到两个有效的 Y 坐标（一个奇数，一个偶数）。在压缩密钥格式中，第一个字节包含一个位，用于指定 Y 坐标是奇数还是偶数，然后是 32 字节用于编码 X 坐标。提议的 bip-taproot 遵循这一惯例，使用 33 字节编码 taproot 输出密钥。

    本周，John Newbery [建议][smaller v1 spk]我们使用某种方法避免在 scriptPubKey 中放置此字节。Wuille 同意这可能有用，并将尝试实现一种变体，其中该位将作为 taproot 见证数据的一部分。这将减少创建一个 taproot 输出的成本一个 vbyte（使其与当前的 P2WSH 相同）。

- **<!--presentation-a-return-to-fees-->****演讲：重返费用：** 本月早些时候在纽约区块链周期间，Bitcoin Optech 贡献者 Mike Schmidt 在 Optech 的首次高管简报会上做了关于比特币交易费用的演讲。[他演讲的视频][vid return to fees]现已上线。{{return-to-fees-zh}}

## 提议的交易输出承诺

提议的 [opcode `OP_CHECKOUTPUTSHASHVERIFY`][bip-coshv] 允许 Taproot 地址承诺一个或多个 tapscripts，这些 tapscripts 要求花费它们的交易包含一组特定的输出，这种技术在合同协议研究者中称为*契约*。该提议的操作码的主要好处是允许在当前费用较高时确认一笔小交易，并信任地保证一组人在未来费用较低时收到实际付款。对于已经实施了诸如[支付批处理][topic payment batching]等技术以应对突然费用激增的组织来说，这可以使其更加经济。

在我们仔细研究这个新的操作码本身之前，先来看看如何使用当前的比特币交易功能实现类似的事情。

Alice 想支付给十个人，但当前的交易费用很高，所以她不想发送十笔单独的交易，甚至不想使用支付批处理来发送包含每个接收者输出的一笔交易。相反，她希望在不必为现在的十个输出支付上链费用的情况下，信任地承诺在未来支付给他们。因此，Alice 向每个接收者索要一个公钥，并创建一个未签名和未广播的*设置*交易，该交易使用 10-of-10 多重签名脚本支付这些公钥。然后她创建一个子交易，从多重签名输出支付给她最初想创建的 10 个输出。我们称这个子交易为*分配*交易。她要求所有接收者签署这个分配交易，并确保每个人都收到其他所有人的签名，然后她自己签署并广播设置交易。

![一个设置交易支付预签名的分配交易](/img/posts/2019-05-tx-tree-1.png)

当设置交易获得合理数量的确认时，Alice 就无法收回对 10 个接收者的付款了。只要每个接收者有一份分配交易及其他人的签名，就没有办法让任何接收者骗取其他接收者的付款。因此，即使实际上支付接收者的分配交易尚未广播或确认，这些付款也由已确认的设置交易保障。在任何时候，任何想花钱的接收者都可以广播分配交易并等待确认。

这种技术允许付款人和接收人锁定一组付款在高费用期间，然后仅在费用较低时分配实际付款。根据撰写本文时的 Bitcoin Core 费用估算，任何有耐心等待一周交易确认的人（如上面的分配交易）都可以大幅节省费用。让我们在这个上下文中看看上面的例子。为了使后面的与 Taproot 的比较更公平，我们假设使用了一种形式的密钥和签名聚合，例如 [MuSig][] 或（理论上）多方 ECDSA（参见 [Newsletter #18][]）。

{% assign p2wpkh = "A transaction spending one P2WPKH input to two P2WPKH outputs" %}
{% assign batched11 = "A transaction spending one P2WPKH input to eleven P2WPKH outputs, or 9*(8+1+22) more bytes than the two-output P2WPKH transaction" %}
{% assign batched10 = "A transaction spending one P2WPKH input to ten P2WPKH outputs, or 8*(8+1+22) more bytes than the two-output P2WPKH transaction" %}

|                     | 独立付款              | 批量付款              | 现在承诺，以后分配        |
|---------------------|-----------------------|-----------------------|-----------------------|
| 即时（高费用）交易  | 10x<abbr title="{{p2wpkh}}">141 vbytes</abbr> | 1x<abbr title="{{batched11}}">420 vbytes</abbr> | 1x<abbr title="{{p2wpkh}}">141 vbytes</abbr> |
| 费用（0.00142112 BTC/KvB） | 0.00204641 BTC         | 0.00059687 BTC         | 0.00020037 BTC         |
| 延迟（低费用）交易  | ---                   | ---                   | 1x<abbr title="{{batched10}}">389 vbytes</abbr> |
| 费用（0.00001014 BTC/KvB） | ---                   | ---                   | 0.00000394 BTC         |
| 总 vbytes          | 1,410                 | 420                   | 530                   |
| 总费用             | 0.00204641 BTC         | 0.00059687 BTC         | 0.00020431 BTC         |
| **与前一列相比的节省** | ---                   | **71%**               | **66%**               |

我们看到这种类型的无需信任延迟付款比支付批处理节省了 66%，比单独发送付款节省了 90%。请注意，在费用分层更大或接收者超过十个的情况下，节省可能会更大。

### CheckOutputsHashVerify

提议的软分叉将添加一个新的操作码，`OP_CHECKOUTPUTSHASHVERIFY`（作者缩写为 `OP_COSHV`，多了一个 *S*）。该操作码和一个哈希摘要可以包含在 tapleaf 脚本中，使其成为 Taproot 地址的一个条件。当该地址被花费时，如果执行了 COSHV，只有当花费交易的输出哈希摘要与 COSHV 从脚本中读取的哈希摘要匹配时，该交易才有效。

与上面的例子相比，Alice 将再次向每个参与者索要一个公钥（例如 Taproot 地址[^taproot-pubkeys]）。与以前类似，她将创建 10 个支付给接收者的输出——但她不需要将这些输出形成特定的分配交易。相反，她只需将这十个输出一起哈希，并使用生成的摘要创建一个包含 COSHV 的 tapleaf 脚本。这将是这个 Taproot 承诺中的唯一 tapleaf。Alice 还可以使用参与者的公钥形成 taproot 内部密钥，以允许他们在不揭示 Taproot 脚本路径的情况下共同花费资金。

![一个设置交易支付 COSHV 输出，该输出扩展为分配交易](/img/posts/2019-05-tx-tree-2.png)

然后，Alice 将每个接收者的十个输出副本发送给他们，以便他们能够验证 Alice 的设置交易在适当确认后保证他们的付款。当他们后来想要花费该付款时，他们中的任何一个都可以创建包含承诺输出的分配交易。与前一小节的例子不同，他们不需要预先签署任何东西，因此不需要彼此互动。更好的是，Alice 需要发送给他们的信息，可以通过现有的异步通信方法（如电子邮件或云驱动器）发送给他们，以便他们验证设置交易并最终花费他们的钱。这意味着在 Alice 创建并发送她的设置交易时，接收者不需要在线。

这种不需要互动的消除是提案的一个特别亮点。如果我们设想 Alice 是一个交易所的例子，交互形式的协议将要求她从每个参与者提交提款请求的那一刻起，让这十个参与者保持在线并连接到她的服务，直到互动完成——并且他们都需要使用兼容这种子交易签名协议的钱包。使用 COSHV 的非交互形式只需要他们提交一个比特币地址和一个电子邮件地址（或某个其他协议地址以接收承诺输出）。

### 反馈和激活

截至撰写本文时，该提案在 Bitcoin-Dev 邮件列表中收到了 30 多条回复。提出的关注点包括：

- **<!--not-flexible-enough-->****不够灵活：** Matt Corallo [表示][coshv flex]，“我们需要有一个提供更多功能的灵活解决方案，而不仅仅是这个，否则当人们要求更好的解决方案时，我们可能会再次经历所有的努力。”

- **<!--not-generic-enough-->****不够通用：** Russell O'Connor 建议 COSHV 和 `SIGHASH_ANYPREVOUT`（在[上周的 Newsletter][Newsletter #47] 中描述）都可以使用 `OP_CAT` 操作码和 `OP_CHECKSIGFROMSTACK` 操作码来替代。这两个操作码目前在 [ElementsProject.org][] 侧链（如 [Liquid][blockstream liquid]）中实现。`OP_CAT` 操作码将两个字符串连接成一个字符串，`OP_CHECKSIGFROMSTACK` 操作码将堆栈上的签名与堆栈上的其他数据进行比较，而不是与包含签名的交易进行比较。连接允许脚本包括消息的各个部分，这些部分在花费时与见证元素组合，以形成可以使用 `OP_CHECKSIGFROMSTACK` 验证的完整消息。

  由于验证的消息可以是比特币交易——包括发起者试图发送的交易的部分副本——这些操作允许脚本评估交易数据，而不必直接读取正在评估的交易。相比之下，COSHV 查看输出的哈希，anyprevout 查看交易中的所有其他签名。

  cat/checksigfromstack 方法的一个潜在主要缺点是它需要更大的见证来容纳更大的脚本及其所有见证元素。O'Connor 指出，一旦明确有大量用户通过通用模板使用这些功能，他不介意切换到更简洁的实现（如 COSHV 和 anyprevout）。

- **<!--not-safe-enough-->****不够安全：** Johnson Lau 指出，COSHV 允许类似于 [BIP118][] noinput 的签名重放，这是一种 [bip-anyprevout][] 采取措施消除的风险。

Rubin 和其他人提供了至少初步的回应以应对这些关注点。我们预计讨论将继续进行，因此我们将在未来几周内报告任何重大进展。

[COSHV 的提议 BIP][bip-coshv] 表示它可以与 bip-taproot 一起激活（如果用户愿意）。由于 bip-taproot 本身仍在讨论中，我们不建议任何人期待双重激活。未来的讨论和实施测试将揭示每个提案是否足够成熟、足够受欢迎以及是否足够受到用户支持以加入比特币。

总体而言，COSHV 似乎提供了一种简单（但聪明）的方法来允许输出承诺其资金最终可以发送到的位置。在下周的 Newsletter 中，我们将探讨 COSHV 可以用来提高效率、隐私或两者的方法。

## Bech32 发送支持

*第 24 周中的第 11 周 [系列][bech32 series]，关于允许你支付的人访问 segwit 的所有好处。*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption wiki page for changes -->{% endcomment %}

{% include specials/bech32/zh/11-only-bech32.md %}

**更正 Newsletter #46：** 我们关于 bech32 QR 码的部分错误地声称，带有附加参数的 BIP21 URI 中使用的 bech32 地址不能使用 QR 大写字母数字模式。Nadav Ivgi 亲切地[通知我们][ivgi tweet]，QR 码可以混合模式。我们已更新[该段落][updated qr paragraph]，包括正确的信息、一些附加细节和一组附加的 QR 码示例。

*如果您在 Optech 的 Newsletter 或其他文档中发现任何错误，请发送[电子邮件][optech email]、[推文][optech twitter]或以其他方式联系我们的[贡献者][optech contributors]。*

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选之一——或者在我们有空闲时间时帮助好奇或困惑的用户。在这个月度特辑中，我们重点介绍了自上次更新以来投票最高的一些问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{%
endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--what-are-the-limitations-for-amortizing-the-interactive-session-setup-of-musig-->**[MuSig 交互会话设置的摊销限制是什么？]({{bse}}87605)
  Richard Myers 正在尝试为低带宽系统优化交互设置，但用户 nickler 强调不应重用 nonce，否则私钥可能泄露。Nickler 继续提供了实现 Myers 目标的建议。

- **<!--on-chain-cost-of-segwit-version-1-versus-version-0-->**[链上成本：Segwit 版本 1 与版本 0 的比较？]({{bse}}87697)
  用户 Wapac 请求比较 segwit v0 和 v1 之间的交易重量，特别是相对简单的单密钥交易。Andrew Chow 提供了字节级细节，并得出结论，v1 总是更便宜的花费，而 v0 在创建输出时可能更便宜。然而，Andrew 指出，发送方通常在选择要发送到的输出类型时没有太多选择，因此用户可能更倾向于 v1，即使对于单密钥交易也是如此。Wapac 还提供了一个显示摘要表的答案。

- **<!--does-v1-segwit-include-v0-->**[v1 Segwit 包含 v0 吗？]({{bse}}87612) Pieter Wuille 表示不可以，您不能在 [v1 花费][bip-tapscript]中使用 [v0 脚本][BIP141]。他详细说明，为了实现 v1 的一些目标，这导致与 v0 脚本的某些方面不兼容。

- **<!--fee-negotiations-in-lightning-->**[闪电网络中的费用谈判。]({{bse}}87586) Mark H 描述了在一个四跳 LN 支付的示例中，如何进行费用谈判。

## 值得注意的代码和文档更改

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和 [比特币改进提案（BIPs）][bips repo] 中的显著变化。*

- [LND #3098][] 增加了守护进程等待由远程对等节点启动的通道资金交易确认的最大块数，从 288 块（两天）增加到 2,016 块（两周）。这允许有耐心的用户支付更低的交易费用。

- [C-Lightning #2647][] 指定了一个默认的插件目录，即使未指定 `--plugin` 或 `--plugin-dir` 配置参数，也会从该目录自动加载插件。目前这是闪电守护进程配置目录中的 `plugins` 目录。

- [C-Lightning #2650][] 添加了一个新的插件挂钩，当远程对等节点尝试与本地节点打开通道时触发。这样插件可以在通道打开之前拒绝通道打开或执行其他操作。

- [Eclair #952][] 添加了一个 `sendtoroute` 方法，允许用户手动选择初始路由付款的通道。这可以让他们选择哪些通道的资金被耗尽。

- [Eclair #965][] 允许用户在创建发票时指定 preimage。这可以用于安全生成不可猜测的发票标识符的系统，例如[原子交换][atomic swap]或一组合同条款与 [pay-to-contract 格式][p2c] 中的 nonce 结合使用。

## 新出版计划

从本周开始，Optech Newsletter 将改为每周三发布，而不是每周二。这将给我们额外的一个工作日来审查和编辑 Newsletter 草稿。

## 特别感谢

我们感谢 Jeremy Rubin 和 Anthony Towns 对本 Newsletter 草稿的审查，包括向我们描述输出树的想法。我们还感谢 Pieter Wuille 帮助我们更好地理解使用 MuSig 聚合密钥和签名时的互动要求。本 Newsletter 发布版本中的任何错误均为作者的责任。

## 脚注

[^legacy-cleanstack]:
    Segwit v0（P2WSH）和 Tapscript 提案要求最终堆栈仅包含一个*真*元素才能成功。这称为*清洁堆栈*规则。裸输出和 P2SH 输出的传统脚本允许堆栈包含多个项目，并在堆栈顶部项目为*真*时成功。然而，不具有清洁堆栈的传统交易将不会被 Bitcoin Core 的默认内存池策略中继或挖掘。清洁堆栈规则有助于减少交易的可塑性，因为对 scriptSig 或见证的任何额外或删除操作都会改变交易的费用率以及（对于传统交易）其 txid。

[^taproot-pubkeys]:
    提议的 Taproot 地址格式（v1 segwit 地址）直接在地址中包含一个公钥，因此任何拥有一组 Taproot 地址的人都可以使用它们创建一个聚合公钥。然而，一些用户可能会使用没有人拥有（或能合理生成）相应私钥的公钥来创建 Taproot 地址。因此，任何创建聚合公钥的人可能不应该假设 Taproot 地址本身就是公钥，应该收集单独的公钥。此外，最好不要在比特币的多个地方重用同一个公钥。为了简化对 COSHV 的描述，我们在本 Newsletter 的示例中省略了收集公钥的额外步骤。在您实现从本 Newsletter 或互联网上任何其他地方读到的协议之前，请考虑咨询比特币专家。

{% include linkers/issues.md issues="3098,2647,2650,952,965" %}
[channel factories]: https://www.tik.ee.ethz.ch/file/a20a865ce40d40c8f942cf206a7cba96/Scalable_Funding_Of_Blockchain_Micropayment_Networks.pdf
[p2c]: https://arxiv.org/abs/1212.3257
[atomic swap]: https://en.bitcoin.it/wiki/Atomic_swap
[emptystack1]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-May/016935.html
[emptystack0]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-December/016558.html
[emptystack reply]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-May/016947.html
[elliptic curve]: https://en.wikipedia.org/wiki/Elliptic_curve
[smaller v1 spk]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-May/016943.html
[vid return to fees]: https://www.youtube.com/watch?v=ihUQ4C42KUk
[coshv flex]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-May/016936.html
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
