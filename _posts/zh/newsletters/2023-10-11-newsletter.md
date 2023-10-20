---
title: 'Bitcoin Optech Newsletter #272'
permalink: /zh/newsletters/2023/10/11/
name: 2023-10-11-newsletter-zh
slug: 2023-10-11-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报链接到了一个关于已提议的 `OP_TXHASH` 操作码的规范，并包含了我们常规的章节，总结了 Bitcoin Core PR 审核俱乐部会议的内容，链接到了新的发布和发布候选版本，并描述了一些热门比特币基础设施项目的重要变更。


## 新闻

- **提议的 `OP_TXHASH` 操作码的规范**：Steven Roose 在 Bitcoin-Dev 邮件列表中为新的 `OP_TXHASH` 操作码[发布][roose txhash]了一份 [BIP 草案][bips #1500]。这个操作码的想法之前已经讨论过（参见[周报 #185][news185 txhash]），但这是该想法的首个规范。除了具体描述操作码的工作方式外，它还考虑了防范一些潜在的缺点，比如全节点在每次调用操作码时可能需要对数兆字节的数据进行哈希运算。Roose 的草案中还包含了一个示例实现。{% assign timestamp="1:42" %}

## Bitcoin Core PR 审核俱乐部

*在这个月度部分，我们总结了 [Bitcoin Core PR 审核俱乐部][Bitcoin Core PR Review Club]会议，重点介绍了一些重要的问题和答案。单击下面的问题以查看会议答案的总结。*

[util: 类型安全的交易标识符][review club 28107] 是由 Niklas Gögge (dergoegge) 提交的一个 PR，通过为 `txid` 和 `wtxid` 引入独立的类型来提高类型安全性，而不是两者都由 `uint256`（一个 256 位的整数，可以包含 SHA256 哈希）表示。其中 `txid` 表示交易标识符或哈希但不包括隔离见证数据，`wtxid` 与前者相同并包含见证数据。这个 PR 不应该产生任何操作效果；它的目的是防止将一种类型的交易 ID 用于本应使用另一种类型的编程错误。这类错误应在编译期检测出来。

为了将干扰最小化并方便审查，这些新类型最初将仅在代码的一个区域（交易“孤儿院”）中使用；将来的 PR 会把这些新类型使用在代码库的其他区域。{% assign timestamp="18:36" %}

{% include functions/details-list.md
  q0="一个交易的标识符是类型安全的意思是什么？为什么这个会很重要或有帮助？有什么缺点吗？"
  a0="一个交易标识符有两种含义（`txid` 或 `wtxid`），类型安全是指标识符不能以错误的含义使用的属性。也就是说，`txid` 不能在期望 `wtxid` 的地方使用，反之亦然，并且这是由编译器的标准类型检查强制执行的。"
  a0link="https://bitcoincore.reviews/28107#l-38"

  q1="是否应该让新的类类型 `Txid` 和 `Wtxid`  _包含_ （封装） `uint256`，而非从 `uint256` _继承_？有哪些权衡？"
  a1="这些类可以这样做，但会导致更多的代码变动（需要修改更多行的源代码）。"
  a1link="https://bitcoincore.reviews/28107#l-39"

  q2="为什么在编译时强制执行类型比在运行时更好？"
  a2="开发人员在编码过程中就可以快速发现错误，而不是依赖于编写大量的测试套件来捕捉运行时错误（这些测试可能仍然会漏掉一些错误）。然而，测试仍然是有用的，因为类型安全无法阻止一开始就用错了交易 ID 的类型。"
  a2link="https://bitcoincore.reviews/28107#l-67"

  q3="概念上，在编写需要引用交易的新代码时，何时应该使用 `txid`，何时应该使用 `wtxid`？你能指出代码中使用其中一个而非可能非常糟糕的另一个的示例吗？"
  a3="一般来说，更倾向于使用 `wtxid`，因为它承诺整个交易。一个重要的例外是每个输入对应输出（UTXO）的 `prevout` 引用，必须通过 `txid` 指定交易。需要使用其中一个而不是另一个的示例在[这里][wtxid example]给出（有关更多信息，请参见[周报#104][news104 wtxid]）。"
  a3link="https://bitcoincore.reviews/28107#l-85"

  q4="<!--in-which-concrete-way-s-could-using-transaction-identifier-instead-of-uint256-help-find-existing-bugs-or-prevent-the-introduction-of-new-ones-on-the-other-hand-could-this-change-introduce-new-bugs-->使用 `transaction_identifier` 而不是 `uint256` 有哪些具体方式可以帮助找到现有的错误或防止引入新错误？另一方面，这个改变会引发新故障吗？"
  a4="没有这个 PR 时，接收一个 `uint256` 参数（例如一个区块 ID 哈希）的函数也可以被传入一个 `txid`。有了这个 PR，这样做就会引发一个编译期错误。"
  a4link="https://bitcoincore.reviews/28107#l-128"

  q5="[`GenTxid`][GenTxid] 类已经存在。它目前是如何强制保证类型正确性的，以及它与此 PR 中的方法有何不同？"
  a5="这个类包括一个哈希和一个指示该哈希是 `wtxid` 还是 `txid` 的标志，所以它仍然是一个单一类型而不是两个不同的类型。这允许类型检查，但必须显式编程。更重要的是，这只能在运行时而不是编译时完成。它符合以下常见用例的需要，即输入可以是这两种标识符的任一种。因此，这个 PR 不会移除 `GenTxid`。一个未来更好的替代类型可能会是 `std::variant<Txid, Wtxid>`。"
  a5link="https://bitcoincore.reviews/28107#l-161"

  q6="<!--how-is-transaction-identifier-able-to-subclass-uint256-given-that-in-c-integers-are-types-and-not-classes-->`transaction_identifier` 是如何成为 `uint256` 的子类的？在 C++ 中，整数是一个类型而不是类吗"
  a6="因为 `uint256` 本身是一个类，而不是内置类型（C++ 的最大的内置整数类型是 64 位）。"
  a6link="https://bitcoincore.reviews/28107#l-194"

  q7="`uint256` 在其他方面与 `uint64_t` 等类型的行为相同吗？"
  a7="有不同，`uint256` 不允许进行算术运算，因为这对哈希（`uint256` 的主要用途）来说没有意义。这个名称有误导性；它实际上只是一个 256 位的数据块（blob）。而 `arith_uint256` 允许进行算术运算（例如，在 PoW 计算中使用）。"
  a7link="https://bitcoincore.reviews/28107#l-203"

  q8="<!--why-does-transaction-identifier-subclass-uint256-instead-of-being-a-completely-new-type-->为什么 `transaction_identifier` 是 `uint256` 的子类而不是完全新的类型？"
  a8="这样可以让我们使用显式和隐式转换，使得期待交易 ID 是 `uint256` 类型的代码保持不变。除非有一个合适的时机来重构以使用新的、更严格的 `Txid` 或 `Wtxid` 类型。"
  a8link="https://bitcoincore.reviews/28107#l-219"
%}

## 版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [LDK 0.0.117][] 是这个用于构建闪电网络应用的代码库的一个发布版本。它包含了对前一个版本中的[锚点输出][topic anchor outputs]功能相关的安全漏洞修复。此版本还改进了寻路功能，改进了对[瞭望塔][topic watchtowers]的支持，启用了对新通道的[批量][topic payment batching]充值，此外还有一些其他功能和错误修订。 {% assign timestamp="27:33" %}

- [BDK 0.29.0][] 是这个用于构建钱包应用程序的代码库的一个发布版本。它更新了依赖项并修复了一个（可能很少见的）错误，该错误影响了钱包接收多于一笔矿工 coinbase 交易输出的情况。 {% assign timestamp="28:35" %}

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo] 和 [Bitcoin Inquisition][bitcoin inquisition repo]。*

- [Bitcoin Core #27596][bitcoin core #27596] 完成了 [assumeutxo][topic assumeutxo] 项目的第一阶段，包括了同时使用一个假定有效（assumedvalid）对链状态进行快照和在后台进行完整验证同步所必需的所有余下变更。它通过 RPC（`loadtxoutset`）使 UTXO 快照可加载，并在链参数（chainparams）中添加了 `assumeutxo` 参数。

    尽管该功能集在[激活][bitcoin core #28553]前在主链上都不可用，但这个合并标志着到达了多年努力的顶点。该项目[在 2018 年提出][assumeutxo core dev]并[在 2019 年正式确定][assumeutxo 2019 mailing list]，将显著改善首次接入网络的新的全节点的用户体验。后续合并包括 [Bitcoin Core #28590][bitcoin core #28590]、[#28562][bitcoin core #28562]和[#28589][bitcoin core #28589]。 {% assign timestamp="29:32" %}

- [Bitcoin Core #28331][]、[#28588][bitcoin core #28588]、[#28577][bitcoin core #28577] 和 [GUI #754][bitcoin core gui #754] 增加了 [BIP324][] 所定义的[版本 2 加密 P2P 传输][topic v2 p2p transport]。该功能目前默认禁用，但可以使用 `-v2transport` 选项启用。

    加密传输有助于提高比特币用户的隐私，防止被动观察者（如 ISP）直接决定节点将哪些交易中继给其对等节点。还可以使用加密传输通过比较会话标识符来阻止主动的中间人观察者。未来，添加其他[功能][topic countersign]可能会使一个轻量级客户端通过 P2P 加密连接安全地连接到一个可信节点变得更加方便。 {% assign timestamp="30:38" %}

- [Bitcoin Core #27609][] 在非 regtest 网络上提供了 `submitpackage` RPC。用户可以使用此 RPC 将单笔交易与其未确认的多笔父交易一起提交。在这些父交易中，没有任何一笔花费了另一笔的输出。子交易可以用于给低于节点动态交易池最低费率的父交易进行 CPFP（子为父偿）。然而，在尚未支持[包中继][topic package relay]的情况下，这些交易可能不一定能传播到网络上的其他节点。 {% assign timestamp="33:08" %}

- [Bitcoin Core GUI #764][] 在 GUI 中删除了创建传统钱包的功能。创建传统钱包的功能将被移除；在未来的 Bitcoin Core 版本中，所有新创建的钱包都将是基于[描述符][topic descriptors]的。 {% assign timestamp="34:55" %}

- [Core Lightning #6676][] 添加了一个新的 `addpsbtoutput` RPC，用于向 [PSBT][topic psbt] 添加一个输出，以便节点的钱包在链上接收资金。 {% assign timestamp="36:29" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="27596,28590,28562,28589,28331,28588,28577,28553,754,27609,764,6676,1500" %}
[roose txhash]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-September/021975.html
[news185 txhash]: /en/newsletters/2022/02/02/#composable-alternatives-to-ctv-and-apo
[ldk 0.0.117]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.117
[bdk 0.29.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.29.0
[review club 28107]: https://bitcoincore.reviews/28107
[wtxid example]: https://github.com/bitcoin/bitcoin/blob/3cd02806ecd2edd08236ede554f1685866625757/src/net_processing.cpp#L4334
[GenTxid]: https://github.com/bitcoin/bitcoin/blob/dcfbf3c2107c3cb9d343ebfa0eee78278dea8d66/src/primitives/transaction.h#L425
[news104 wtxid]: /en/newsletters/2020/07/01/#bips-933
[assumeutxo core dev]: https://btctranscripts.com/bitcoin-core-dev-tech/2018-03/2018-03-07-priorities/#:~:text=“Assume%20UTXO”
[assumeutxo 2019 mailing list]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-April/016825.html
