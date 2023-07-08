---
title: 'Bitcoin Optech Newsletter #257'
permalink: /zh/newsletters/2023/06/28/
name: 2023-06-28-newsletter-zh
slug: 2023-06-28-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报总结了一种防止 coinjoin 交易钉死攻击的方法，并描述了一种吸引人们为被期待的共识变更投机的提议。此外，还有我们关于交易池规则的限定系列，以及我们的常规部分：其中包括来自 Bitcoin Stack Exchange 的热门问题和答案、新版本和发布候选版本的公告以及流行的比特币基础设施软件的变更。

## 新闻

- **<!--preventing-coinjoin-pinning-with-v3-transaction-relay-->使用 v3 交易中继防止 coinjoin 交易钉死攻击：** Greg Sanders 在 Bitcoin-Dev 邮件列表中为提议的 [v3 交易中继规则][topic v3 transaction relay] [发帖][sanders v3cj]，描述了如何创建一个不容易受到[交易钉死][topic transaction pinning]攻击的 [coinjoin][topic coinjoin] 风格的多方交易。交易钉死的具体问题是，coinjoin 中的一个参与者可以用他们在交易中的输入创建一个冲突的交易，从而阻止 coinjoin 交易得到确认。

    Sanders 提出 coinjoin 风格的交易可以避免这个问题。这是通过让每个参与者最初将比特币花费到一个只能由所有参与者的签名或者在时间锁过期后只能由参与者自己花费的脚本来实现。另一种办法是，对于一个协调好的 coinjoin 交易，协调者和参与者必须一起签名（或者在时间锁过期后，参与者单独签名）。

    在时间锁过期之前，参与者必须让其他方或协调者共同签名所有冲突的交易。而这是不太可能的，除非该签名对所有参与者都有利（例如[手续费替换][topic rbf]）。 {% assign timestamp="16:08" %}

- **<!--speculatively-using-hoped-for-consensus-changes-->投机性地使用期望的共识变化：** Robin Linus 在 Bitcoin-Dev 邮件列表上[发布][linus spec]了一个关于将资金花费到一个在很长一段时间内（例如 20 年）无法执行的脚本片段的想法。如果根据当前共识规则解释该脚本片段，它将允许矿工在 20 年后取回支付给它的所有资金。然而，该片段中的一些设计使得共识规则的升级将会赋予该片段不同的含义。Linus 举了一个例子，如果在比特币中添加了 `OP_ZKP_VERIFY` 操作码，将允许任何提供具有特定哈希的程序的零知识证明（ZKP）的人取回资金。

    这将允许人们今天支付 BTC 到其中一个脚本，并使用该花费的证明来在[侧链][topic sidechains]或另一条链上获得等值的 BTC，称为 _单向锚定_。另一条链上的 BTC 在脚本时间锁过期前的 20 年里可被反复花费。然后，这条链上的 BTC 的当前所有者可以生成一个零知识证明来证明他们拥有它，并使用该证明在比特币主网上提取锁定的存款，从而实现 _双向锚定_。通过精心设计的验证程序，取款将变得简单和灵活，从而允许同质化的取款。

    作者指出，任何从这种构造中受益的人（例如，在另一条链上接收 BTC 的人）基本上是在赌比特币的共识规则将会改变（例如，添加`OP_ZKP_VERIFY`）。这会激励他们来拥护这种改变，但过渡激励一些用户来改变系统可能会使另一些用户感到强迫。截止编写本文时，该想法在邮件列表里还没有收到任何讨论。 {% assign timestamp="1:33" %}

## 等待确认 #7：网络资源

_这是一个关于交易转发、交易池纳入以及挖矿选择的限定周刊[系列][policy series] —— 解释了为什么 Bitcoin Core 设置了比共识规则更严格的交易池规则，以及钱包可以如何更高效地使用这些交易池规则。_

{% include specials/policy/zh/07-network-resources.md %} {% assign timestamp="24:46" %}

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se]是 Optech 贡献者寻找问题答案或者是我们在空闲时间来帮助好奇或困惑用户的首要场所之一。在这个月度专题中，我们重点介绍了自上次更新以来发布的一些投票最高的问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--why-do-bitcoin-nodes-accept-blocks-that-have-so-many-excluded-transactions-->为什么比特币节点会接受有很多被排除交易的区块？]({{bse}}118707)
  用户 commstark 想知道，为什么节点会从矿工那里接受排除了许多交易的区块 —— 根据该节点自身的[区块模板][reference getblocktemplate]，这些交易预计会包含在区块内。有各种[工具][miningpool observer]可以[显示][mempool space]预期区块与实际区块的对比。Pieter Wuille 指出，不同节点的[交易池][waiting for confirmation 1]会因为交易的传播而出现差异；无法实现一种强制指定区块内容的共识规则。 {% assign timestamp="57:38" %}

- [<!--why-does-everyone-say-that-soft-forks-restrict-the-existing-ruleset-->为什么每个人都说软分叉限制了现有的规则集？]({{bse}}118642)
  Pieter Wuille 用在 [taproot][topic taproot] 和 [segwit][topic segwit] 软分叉[激活][topic soft fork activation]期间添加的规则作为收紧共识规则的例子：

  - taproot 添加了 `OP_1 <32 bytes>`（taproot）输出遵守 taproot 共识规则的要求。
  - segwit 添加了 `OP_{0..16} <2..40 bytes>`（segwit）输出的花费必须遵守 segwit 共识规则的要求，并且还要求 segwit 前的输出有一个空的见证数据。 {% assign timestamp="1:05:28" %}

- [<!--why-is-the-default-ln-channel-limit-set-to-16777215-sats-->为什么默认的闪电网络通道限制设置为 16777215 sats？]({{bse}}118709)
  Vojtěch Strnad 解释了 2^24 satoshi 限制的历史和大（wumbo）通道的动机，并指出 Optech 的 “[大通道][topic large channels]“ 主题页面有更多信息。 {% assign timestamp="1:07:47" %}

- [<!--why-does-bitcoin-core-use-ancestor-score-instead-of-just-ancestor-fee-rate-to-select-transactions?-->为什么 Bitcoin Core 使用祖先分数而不仅仅使用祖先费率来选择交易？]({{bse}}118611)
  Sdaftuar 解释了该原因是性能优化：因为挖矿区块模板交易选择算法同时使用了祖先费率和祖先分数（参见[等待确认＃2：激励措施][waiting for confirmation 2]）。 {% assign timestamp="1:10:28" %}

- [<!--how-does-lightning-multipart-payments-MPP-protocol-define-the-amounts-per-part-->闪电多部分支付（MPP）协议如何定义每个部分的金额？]（{{bse}}117405）
  Rene Pickhardt 指出了[多路径支付][topic multipath payments]没有在协议中规定或由算法来选择每部分大小，同时给出了一些相关的支付拆分的研究。 {% assign timestamp="1:14:15" %}

## 版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [BTCPay Server 1.10.3][]是该自托管服务支付处理软件的最新版本。请参阅他们的[博客文章][btcpay 1.10]，了解 1.10 分支中的主要功能。 {% assign timestamp="1:16:08" %}

## 重大的代码和文档变更：

*本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]和[Bitcoin Inquisition][bitcoin inquisition repo]。*

- [Core Lightning #6303][] 添加了一个新的 `setconfig` RPC，允许在不重新启动守护进程的情况下更改一些配置选项。 {% assign timestamp="1:21:14" %}

- [Eclair #2701][] 开始记录通道对手提供的 [HTLC][topic htlc] 到达的时间和被结算的时间。这样可以从节点的角度来跟踪 HTLC 等待的时间。如果有很多 HTLC 或者有一些高价值的 HTLC 在长时间内等待，这可能表明当前有[通道堵塞攻击][topic channel jamming attacks]在发生。跟踪 HTLC 的持续时间有助于检测甚至缓解此类攻击。 {% assign timestamp="1:22:21" %}

- [Eclair #2696][] 更改了 Eclair 用户配置选用费率的方式。以前，用户可以用 _区块目标_ 来指定要使用的费率，例如 “6” 表示 Eclair 将尝试在六个区块内确认交易。现在，Eclair 可接受“慢速”、“中速”和“快速”，并使用常量或区块目标将其转换为具体的费率。 {% assign timestamp="1:25:03" %}

- [LND #7710][] 添加了插件（或守护程序本身）检索先前收到 HTLC 数据的能力。这对于[盲化路由][topic rv routing]是必要的，并且可能被使用在各种[通道阻塞][topic channel jamming attacks]对策以及其他未来功能的构想中。 {% assign timestamp="1:26:51" %}

- [LDK #2368][] 允许接受由对等节点使用[锚点输出][topic anchor outputs]创建的新通道，但需要控制程序来刻意选择接受每个新通道。这样做是因为正确结算锚点通道可能需要用户可访问一个或多个具有足够价值的未花费交易输出（UTXO）。LDK 作为一个无法知道用户钱包所控制的非闪电网络 UTXO 的库，使用此提示给控制程序一个机会来验证它是否具有必要的 UTXO。 {% assign timestamp="1:27:43" %}

- [LDK #2367][]使普通 API 用户可访问[锚点通道][topic anchor outputs]。 {% assign timestamp="1:33:34" %}

- [LDK #2319][]允许对等节点创建一个 HTLC，该 HTLC 承诺支付的金额少于原始花费者应支付的金额，从而使对等节点能够保留差额作为自己的额外费用。这对于创建 [JIT 通道][topic jit channels]非常有用 —— 当一个对等节点接收到一个 HTLC，但该 HTLC 的实际接受方还没有通道的时候。对等节点创建一个资金通道的链上交易，并在该通道内承诺 HTLC —— 但是在创建该链上交易时会产生额外的交易费用。如果接收方接受新通道并及时结算 HTLC，对等节点将通过收取额外费用来获得报酬。 {% assign timestamp="1:34:40" %}

- [LDK #2120][] 添加了支持寻找通向使用[盲化路径][topic rv routing]接收方的路径。 {% assign timestamp="1:37:09" %}

- [LDK #2089][] 添加了一个事件处理器，使钱包可以容易地提高任何需要在链上结算的 [HTLC][topic htlc] 的费用。 {% assign timestamp="1:38:12" %}

- [LDK #2077][] 重构了大量代码，以便以后更容易添加对[双重充值通道][topic dual funding]的支持。 {% assign timestamp="1:39:08" %}

- [Libsecp256k1 #1129][] 实现了 [ElligatorSwift][ElligatorSwift paper] 技术，引入了一种 64 字节的公钥编码，该编码与随机数据在计算上无法区分。`ellswift` 模块提供了在新格式中编码和解码公钥的函数，以及便利的函数来生成新的均匀分布的随机密钥并执行基于 ellswift 编码的椭圆曲线 Diffie-Hellman 密钥交换（ECDH）。基于 ellswift 的 ECDH 是为了用于在[第 2 版的 P2P 加密传输][topic v2 p2p transport]协议（[BIP324][]）中建立连接。 {% assign timestamp="1:40:37" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="6303,2701,2696,7710,2368,2367,2319,2120,2089,2077,1129" %}
[policy series]: /zh/blog/waiting-for-confirmation/
[sanders v3cj]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021780.html
[linus spec]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021781.html
[BTCPay Server 1.10.3]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.10.3
[btcpay 1.10]: https://blog.btcpayserver.org/btcpay-server-1-10-0/
[miningpool observer]: https://miningpool.observer/template-and-block
[mempool space]: https://mempool.space/graphs/mining/block-health
[waiting for confirmation 1]: /zh/blog/waiting-for-confirmation/#为什么节点需要一个交易池
[reference getblocktemplate]: https://developer.bitcoin.org/reference/rpc/getblocktemplate.html
[waiting for confirmation 2]: /zh/blog/waiting-for-confirmation/#激励兼容
[ElligatorSwift paper]: https://eprint.iacr.org/2022/759
