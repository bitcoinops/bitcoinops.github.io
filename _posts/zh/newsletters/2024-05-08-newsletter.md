---
title: 'Bitcoin Optech Newsletter #301'
permalink: /zh/newsletters/2024/05/08/
name: 2024-05-08-newsletter-zh
slug: 2024-05-08-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的新闻环节介绍了一种使用 lamport 签名来保护交易（且不需要共识变更）的想法。此外是我们的常规栏目：Bitcoin Core PR 审核俱乐部总结、软件的新版本和候选版本的发行公告，以及热门比特币基础设施软件的变更。

## 新闻

- **<!--consensusenforced-lamport-signatures-on-top-of-ecdsa-signatures-->在 ECDSA 签名上实现共识强制执行的 lamport 签名**：Ethan Hilman 在 Bitcoin-Dev 邮件组中[提出][heilman lamport]了一种要求一笔交易得到一个[lamport 签名][lamport signature]才能生效的方法。这可以让 P2SH 和 P2WSH 输出获得[量子抗性][topic quantum resistance]，并且，[根据][poelstra lamport1] Andrew Poelstra 的说法，它使得 “体积限制成了比特币现在无法实现限制条款（covenant）的唯一原因”。我们将整个协议总结如下，但为了保持叙述的简洁，我们会省去一些安全警告，所以请不要依据这份总结来实现任何东西。

  Lamport 公钥由两个哈希摘要列表组成。Lamport 签名由选定的哈希值的原像组成。在签名者和验证者之间共享的一个程序可以将揭晓的原像解读为指令。举例来说，Bob 希望验证 Alice 签署了 0 到 31 （按二进制来说，就是 00000 与 11111）之间的某个数字。Alice 用两组随机数字创建了一个 lamport 私钥：

  ```
  private_zeroes = [random(), random(), random(), random(), random()]
  private_ones   = [random(), random(), random(), random(), random()]
  ```

  她哈希每一个随机数字，就创建出了自己的 lamport 公钥：

  ```
  public_zeroes = [hash(private_zeroes[0]), ..., hash(private_zeroes[4])]
  public_ones   = [hash(private_ones[0]), ..., hash(private_ones[4])]
  ```

  她把公钥交给 Bob。日后，她想可验证地传递数字 21 给 Bob，于是给他发送下列原像：

  ```
  private_ones[0]
  private_zeroes[1]
  private_ones[2]
  private_zeroes[3]
  private_ones[4]
  ```

  用二进制来说，这是 10101。Bob 验证每一个原像都与他之间收到的公钥相匹配，这就向他保证了，只有知道这些原像的人（Alice）才能创建这条消息 “21”。

  至于 ECDSA 签名，比特币使用 [DER 编码标准][der encoding]，它会省去签名两个部分开头的零字节（0x00）。对随机数值来说，0x00 字节出现的概率是 1/256，所以比特币的签名自然有不同的长度。但因为 R 值出现 0x00 开头的概率高达 1/2（详见 [low-r grinding][topic low-r grinding]），这种长度的偏移会进一步放大；但是，在理论上，可以将这种偏离缩减到一笔交易短一个字节的概率是 1/256。

  即便一台非常快的量子计算机允许攻击者在不知晓一个私钥的前提下创建其签名，DER 编码的 ECDSA 签名依然会有不同的长度，而且依然需要承诺包含它的交易，而这样的交易依然需要包含必要的数据来生效，例如哈希值的原像。

  因此，P2SH 赎回脚本可以检查一个承诺了交易的 ECDSA 签名以及一个承诺了 ECDSA 签名实际长度的 lamport 签名。举例来说：

  ```
  OP_DUP <pubkey> OP_CHECKSIGVERIFY OP_SIZE <size> OP_EQUAL
  OP_IF
    # We now know the size is equal to <size> bytes
    OP_SHA256 <digest_x> OP_CHECKEQUALVERIFY
  OP_ELSE
    # We now know the size is greater than or less than <size> bytes
    OP_SHA256 <digest_y> OP_CHECKEQUALVERIFY
  OP_ENDIF
  ```

  要满足这段脚本，花费者需要提供一个 ECDSA 签名。这个签名会被复制并加以验证；如果签名无效，脚本求值就失败、退出。在一个后量子世界中，一个攻击者也许可以通过这个检查，从而让脚本求值继续。但随后，脚本就会度量签名副本的长度。如果其长度等于 `<size>`，花费者必须揭晓 `<digest_x>`（哈希摘要 x）的原像。这个 `<size>` 可以设为短于常见情形 1 字节，其自然概率是每 256 个签名出现 1 次。否则，在常见情形或者提供长度膨胀的签名时，花费者必须揭晓 `<digest_y>` 的原像。如果不能为签名的实际长度揭晓对应的原像，脚本也会失败、退出。

  因此，即使 ECDSA 完全被攻破，攻击者也无法花费被这样的脚本锁定的比特币，除非攻击者也知道对应的 lamport 私钥。就其自身而言，这也没什么大不了的：因为 P2SH 和 P2WSH [已经拥有][news141 key hiding]了这种基础特性，在脚本自身的原像保持私密的时候（创建输出时仅会暴露脚本的哈希值）。而且，一旦 lamport 签名暴露，攻击者就可以复用它，然后把原签名换成相同长度的伪造 ECDSA 签名。这可能要求攻击者多番尝试生成符合要求的签名（“研磨”），即执行诚实用户不需要执行的额外操作。

  而攻击者需要研磨的次数会随着成对的 ECDSA 签名和 lamport 签名的数量增加而呈指数上升。不幸的是，因为 ECDSA 签名长度改变的天然概率只有 1/256，所以这种非常直接的实现方式将需要很多很多的签名才能获得实用的安全性。Heilman [介绍][heilman lamport2]了一种更高效的机制。这种机制依然会超出 P2SH 的共识限制，但我们认为，在 P2WSH 的更高限制下，它应该差不多能用。

  此外，拥有快速量子计算机或足够强大的传统计算机的单个攻击者会发现，短的 ECDSA nonce 值将让他们很容易能够从没有预料到 nonce 过短的人那里盗窃资金。因为 nonce 的最短长度是已知的，所以这种攻击是可以避免的 —— 只是，因为 nonce 值的私密形式不会暴露，所以任何尝试避免这种攻击的人都将无法花费自己的比特币，直到快速的量子计算机被发明。

  Lamport 签名的验证非常类似于提议中的 [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] 操作码。两者的共性是，需要验证的数据、一个公钥以及一个签名，被置于堆栈中；仅在签名既应合公钥、又承诺了堆栈中的数据时，运算才成功。Andrew Poelstra [介绍][poelstra lamport2] 了这种技巧如何能结合 [BitVM][topic acc] 式的操作来创建一个[限制条款][topic covenants]，虽然他警告，这几乎一定会打破至少一个体积限制共识规则。

## Bitcoin Core PR 审核俱乐部

*在这个月度栏目中，我们总结最近一次 [Bitcoin Core PR 审核俱乐部][Bitcoin Core PR Review Club] 会议的内容，着重总结一些重要的问题和回答。点击问题描述，可见会上回答的总结。*

“[使用 wtxid 来索引 TxOrphanage，允许交易具有相同 txid][review club 30000]” 是由 Gloriz Zhao (Github glozow) 提出的一项 PR，允许多笔具有相同 `txid` 的交易同时存在于 `TxOrphanage` （孤儿交易池）中，并通过 `wtxid` 而非 `txid` 来索引它们。

这项 PR 让 [Bitcoin Core #28970][] 所引入的投机 1 父 1 子[交易包接纳][topic package relay]变得更加健壮。

{% include functions/details-list.md
  q0="<!--why-would-we-want-to-allow-multiple-transactions-with-the-same-txid-to-exist-in-the-txorphanage-at-the-same-time-what-kind-of-situation-does-this-prevent-->为什么我们要允许多笔具有相同 `txid` 的交易同时存在于 `TxOrphanage` 中？这避免了什么情况？"
  a0="从定义上来说，孤儿交易的见证数据是无法验证的，因为我们不知道其父交易。当多笔具有相同 txid（但不同 wtxid）的交易进入，我们会因此无法验证哪个版本是正确版本。通过允许它们并行存在于 TxOrphanage 中，攻击者就无法发送一个不正确的、熔铸过的版本，来阻止接收正确的版本。"
  a0link="https://bitcoincore.reviews/30000#l-11"

  q1="<!--what-are-some-examples-of-same-txid-different-witness-orphans-->有没有什么 txid 相同但见证不同的孤儿交易的例子？"
  a1="具备无效签名（因此本身无效）或者更大见证（但手续费相同，因此费率更低）的同内容交易。"
  a1link="https://bitcoincore.reviews/30000#l-67"

  q2="<!--let-s-consider-the-effects-of-only-allowing-1-entry-per-txid-what-happens-if-a-malicious-peer-sends-us-a-mutated-version-of-the-orphan-transaction-where-the-parent-is-not-low-feerate-what-needs-to-happen-for-us-to-end-up-accepting-this-child-to-mempool-there-are-multiple-answers-->我们来考虑一下一个 txid 只允许一条交易的影响。假设一个恶意的对等节点给我们发送了一笔孤儿交易的变异版本，但其父交易的手续费并不太低，那会怎么样？为了最终接纳这个子交易进入交易池，要经过哪些流程？（出现了多种答案）"
  a2="当一个变异子交易进入了孤儿交易池，而一个有效且非低手续费率的父交易进入，那么父交易会被接纳到交易池中，然后变异子交易会因无法通过验证而从孤儿交易池中移除。"
  a2link="https://bitcoincore.reviews/30000#l-52"

  q3="<!--let-s-consider-the-effects-if-we-have-a-1-parent-1-child-1p1c-package-where-the-parent-is-low-feerate-and-must-be-submitted-with-its-child-what-needs-to-happen-for-us-to-end-up-accepting-the-correct-parent-child-package-to-mempool-->再考虑我们 1 父 1 子交易包的情形（父交易的手续费率太低，因此必须跟子交易一起提交）。为了最终接纳这个正确的父子交易包进入交易池，要经过哪些流程？"
  a3="因为父交易的费率太低，所以它光凭自身就无法被交易池接纳了。不过，自 [Bitcoin Core #28970][]，开始，可以投机接纳一个 1 父 1 子交易包，如果该子交易刚好在孤儿交易池中的话。如果这个孤儿子交易是变异的，那么父交易会被交易池拒绝，然后这个孤儿交易也会从列表中移除。"
  a3link="https://bitcoincore.reviews/30000#l-60"

  q4="<!--instead-of-allowing-multiple-transactions-with-the-same-txid-where-we-are-obviously-wasting-some-space-on-a-version-we-will-not-accept-should-we-allow-a-transaction-to-replace-an-existing-entry-in-the-txorphanage-what-would-be-the-requirements-for-replacement-->我们是否不该允许多笔交易具有相同的 txid（这意味着我们显然会浪费一些空间在我们不会接受的交易版本上），而是允许一笔交易替代 TxOrphanage 中已经存在的交易？替换要满足什么条件？"
  a4="似乎没有很好的准则能判定是否应允许一笔交易替换现存的另一笔。可以探索的一条潜在道路是只允许替换来自同一个对等节点的重复交易。"
  a4link="https://bitcoincore.reviews/30000#l-80"
%}

## 新版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版版或帮助测试候选版本。*

- [Libsecp256k1 v0.5.0][] 是这个用来执行比特币相关的密码学操作的库的新版本。它加快了密钥生成和签名的速度（详见 [上周周报][news300 secp]），并缩减了编译后的体积，“我们预期嵌入式用户尤其能够从中受益”。也添加了一个用来排序公钥的函数。

- [LND v0.18.0-beta.rc1][]  是这个热门闪电节点实现的下一个大版本的候选版本。

## 显著的代码和文档变更

*本周出现显著变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Bitcoin Core #28970][] 和 [#30012][bitcoin core #30012] 添加了对不需要任何 P2P 协议变更的受限形式 1 父 1 子[交易包转发][topic package relay]的支持。设想 Alice 交易池中有一笔父交易，该交易的手续费率低于 Alice 任一对等节点的 [BIP133][] 费率过滤器设定的值，因为 Alice 知道这些对等节点不会接受，因此就不会想转发这笔交易。该父交易也有一笔子交易，其手续费率高到让父子的综合费率高于过滤器的值。那么，Alice 和她的对等节点执行如下流程：

  * Alice 将子交易转发给对等节点。

  * 对等节点发现还不知道该交易的父交易，所以将该交易放到 *孤儿交易池* 中。10 多年以来的所有版本的 Bitcoin Core 都有一个孤儿交易池，会暂时存储少量在父交易之前到达的子交易。这弥补了一个事实所带来的影响：在 P2P 网络中，有时候交易会不按顺序到达。

  * 稍后，Alice 转发父交易给这个对等节点。

  * 在合并这个 PR 之前，这个对等节点会注意到，这笔父交易的费率太低了，因此拒绝接受；现在，它会给父交易求值，并从孤儿交易池中移除子交易。在这个 PR 之后，这个对等节点会注意到，这笔父交易还有一个子交易在孤儿交易池中，然后求出这两笔交易的综合手续费率，如果这个费率高出其地板值，就会让它们进入交易池（否则，根据该节点本地的交易池策略，这两笔交易都不会被接受）。

  已知的是，这种机制可被攻击者攻破。Bitcoin Core 的孤儿交易池是一个循环缓冲池，所有对等节点都可以向其中添加内容，所以希望阻止这种交易包转发的攻击者可以用许多孤儿交易来轰炸目标节点，让实际支付手续费的子交易在父交易到达之前被驱逐。一项[后续 PR][bitcoin core #27742]可能会给每个对等节点一个独占的孤儿交易池空间，以消除这种顾虑。本期周报的 *Bitcoin PR 审核俱乐部* 的内容，介绍了另一个相关的 PR。额外的优化所要求的 P2P 协议变更可见 [BIP331][]。

- [Bitcoin Core #28016][] 将在轮询 DNS 种子服务端之前等待所有种子节点轮询完成。用户可以同时配置种子节点和 DNS 种子服务端。种子节点是一个常规的比特币全节点；Bitcoin Core 可以向种子节点开启一个 TCP 连接，请求一个潜在对等节点的网络地址列表，然后关闭连接。而 DNS 种子服务端会通过 DNS 返回潜在对等节点的 IP 地址，从而允许这些信息在 DNS 网络中传播和缓存，这样 DNS 种子服务端的所有人就无法知道请求这些信息的客户端的 IP 地址。默认情况下，Bitcoin Core 会尝试连接到已知 IP 地址的对等节点；如果未能连接成功，就轮询 DNS 种子服务端；如果不能触达任何 DNS 种子服务端，它就联系一组硬编码的种子节点。用户可以自设一组种子节点。

  在这项 PR 之前，如果用户配置了轮询种子节点，并保持了使用 DNS 种子服务端的默认配置，节点会并行联系这两类节点，哪种连接更快，就能主导节点的对等连接尝试。给定 DNS 的低开销以及轮询结果可能已被一个物理上临近用户的服务端缓存，DNS 常常会胜出。在这次 PR 之后，种子节点将被赋予优先级，因为我们相信设定了非默认 `seednode` 选项的用户将更看重这个选项的结果，而不是默认选项的结果。

- [Bitcoin Core #29623][] 制作了多项优化，以在节点的本地时间与已连接的对等节点相差 10 分钟以上时提醒节点用户。时钟有偏差的节点可能会临时拒绝有效区块，这可能会导致多项可能有严重后果的安全问题。这是从共识代码中移除 “网络调整时间” 概念的后续工作（详见[周报 #288][news288 time]）。

## 纠误

验证 ECDSA 签名之上的 lamport 签名的案例脚本最初使用了 `OP_CHECKSIG`，但在出版之后更新成了使用 `OP_CHECKSIGVERIFY`；我们感谢 Antoine Poinsot 指出这个错误。


{% include references.md %}
{% include linkers/issues.md v=2 issues="30012,28016,29623,27742,28970" %}
[lnd v0.18.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.0-beta.rc1
[libsecp256k1 v0.5.0]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.5.0
[heilman lamport]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAEM=y+XyW8wNOekw13C5jDMzQ-dOJpQrBC+qR8-uDot25tM=XA@mail.gmail.com/
[lamport signature]: https://en.wikipedia.org/wiki/Lamport_signature
[poelstra lamport1]: https://mailing-list.bitcoindevs.xyz/bitcoindev/ZjD-dMMGxoGNgzIg@camus/
[der encoding]: https://en.wikipedia.org/wiki/X.690#DER_encoding
[heilman lamport2]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAEM=y+UnxB2vKQpJAa-z-qGZQfpR1ZeW3UyuFFZ6_WTWFYGfjw@mail.gmail.com/
[poelstra lamport2]: https://gnusha.org/pi/bitcoindev/Zjo72iTDYjwwsXW3@camus/T/#m9c4d5836e54ed241c887bcbf3892f800b9659ee2
[news300 secp]: /zh/newsletters/2024/05/01/#libsecp256k1-1058
[news288 time]: /zh/newsletters/2024/02/07/#bitcoin-core-28956
[news141 key hiding]: /en/newsletters/2021/03/24/#p2pkh-hides-keys
[review club 30000]: https://bitcoincore.reviews/30000
