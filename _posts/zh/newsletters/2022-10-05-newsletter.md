---
title: 'Bitcoin Optech Newsletter #220'
permalink: /zh/newsletters/2022/10/05/
name: 2022-10-05-newsletter-zh
slug: 2022-10-05-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报描述了一项新的关于选择交易中继策略的提案，并总结了帮助闪电网络通道保持平衡的研究。还包括我们的常规部分，罗列了新的软件版本和候选版本，以及流行的比特币基础设施项目的重要变更。

## 新闻

- **为 LN-penalty 设计的新交易中继策略的提议：**Gloria Zhao 在比特币开发邮件列表中[发表][zhao tx3]了一个提议，允许交易选择一组修改后的交易中继策略。任何将其版本参数设置为 `3` 的交易将会：

    * 在未被支付更高费率和更高总费用的交易所确认时可替换（当前主要的 [RBF][topic rbf] 规则）

    * 只要它仍未得到确认，就要求它的所有后续交易也是 v3 的交易。违反此规则的后续交易将默认不被中继或挖矿

    * 如果其任何先前未确认的 v3 交易已经在交易池中（或在一个包含此交易的[包][topic package relay]中）有任何其他的后续交易，则该交易会被拒绝

    * 如果其任何 v3 先前交易是未被确认的，则要求该交易大小为 1,000 vbytes 或更小

    随该提议中继规则而来的是对之前提议的包中继规则的简化（参见[周报 #167][news167 packages]）。

    v3 中继和更新的包中继规则一起旨在允许闪电网络承诺交易仅包含最低费用（甚至可能为零费用），并由子交易支付其实际费用，同时防止[钉死][topic transaction pinning]。几乎所有闪电网络节点都已经使用了这样的机制，[锚点输出][topic anchor outputs]，但提议的升级应该使确认承诺交易更简单、更健壮。

    Greg Sanders [回复][sanders tx3]了两点建议：

    - *<!--ephemeral-dust-->短暂粉尘：* 如果任何支付零价值（或其他*不经济*）输出的交易是花费该粉尘输出的包的一部分，则该交易应当豁免[粉尘策略][topic uneconomical outputs]。

    - *标准 OP_TRUE：* 形成一个完全由 `OP_TRUE` 组成的输出的交易应该被默认转发。这样的输出可以被任何人使用——它没有安全性。这使得闪电网络通道的任何一方（甚至第三方）都可以轻松地对花费 `OP_TRUE` 输出的交易提高手续费。无需将数据放入堆栈即可使用 `OP_TRUE` 输出，使得这种花费十分节省成本。

    这些都不需要与实现 v3 交易的中继同时完成，但该讨论的一些回复者似乎倾向于支持所有提议的变更。

- **<!--ln-flow-control-->闪电网络流量控制：** Rene Pickhardt 在 Lightning-Dev 邮件列表中[发布][pickhardt ml valve]了一份他使用 `htlc_maximum_msat` 参数作为流量控制阀执行的[近期研究][pickhardt bitmex valve]的摘要。正如先前在 BOLT7 中的[定义][bolt7 htlc_max]，`htlc_maximum_msat` 是节点为单个支付部分在特定通道中可转发到下一跳的最大值（[HTLC][topic htlc]）。Pickhardt 解决了通道流经一个方向上的价值比在另一个方向上更多的问题——在最终离开通道时在过度使用的那个方向上没有足够的资金来转账。他建议可以通过限制过度使用方向的最大值来保持通道平衡。例如，如果一个通道开始时允许在任一方向转发 1,000 聪，但在通道变得不平衡时，则尝试将过度使用的方向上的单次转发支付的最大金额降低到 800。Pickhardt 的研究提供了几个代码片段，可用于计算实际适当的 `htlc_maximum_msat` 值。

    在一封[单独的电子邮件][pickhardt ratecards]中，Pickhardt 还建议，此前*手续费费率卡*的想法（参见 [上周的周报][news219 ratecards]）可以改为*单次转发最大金额的费率卡*，即支付者在发送小额付款时收取较低费率、发送大额付款时则收取较高费率。与最初的费率卡提议不同，它们将是绝对金额，而不是通道当前余额的相对金额。Anthony Towns [描述][towns ratecards]了最初的费率卡想法将面临的几个挑战对于基于可调整 `htlc_maximum_msat` 的流量控制来说不会再是问题。

    ZmnSCPxj [批评][zmnscpxj Valve]了这个想法的几个方面，包括注意到支付者仍然可以通过较低的最高费率通道发送相同金额。只需将整个付款分成额外的小额部分，就会导致它再次变得不平衡。Towns 建议可以通过费率限制来解决这个问题。

    在编写本摘要时，讨论似乎仍在进行中，但随着节点运营商开始试验其通道的 `htlc_maximum_msat` 参数，我们可以期待在接下来的几周至几个月内获得一些新的见解。

## 新版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本，或帮助测试候选版本。*

- [Bitcoin Core 24.0 RC1][] 是网络中使用最广泛的一个全节点实现的下一个版本的首个候选发布版本。[测试指南][bcc testing]已可用。

## 重大代码及文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo] 和 [Lightning BOLTs][bolts repo]。*

- [Eclair #2435][] 添加了在使用 [trampoline 中继][topic trampoline payments] 时对基本形式的`异步支付`的可选支持。如[周报 #171][news171 async] 中所述，异步支付将允许向离线节点（例如移动端钱包）付款，而不需要信任第三方。异步支付的理想机制取决于 [PTLCs][topic ptlc]，但一种部分实现只需要第三方延迟转发资金，直到离线节点重新上线。Trampoline 节点可以提供这种延迟，因此该 PR 利用它们来支持对异步支付的试验。

- [BOLTs #962][] 从规范中删除了对原始固定长度洋葱数据格式的支持。升级后的可变长度格式是在三年前添加到规范中的，提交消息中提到的测试结果表明几乎没有人再使用旧格式了。

- [BIPs #1370][] 修订 [BIP330][]（[Erlay][topic erlay] 用于基于协商的交易发布）以反映当前提议的实现。变更包括：

  - 移除被截断的交易 ID 以支持仅使用交易 wtxid。这也意味着节点可以使用现有的 `inv` 和 `getdata` 消息，因此 `invtx` 和 `gettx` 消息已被移除。

  - 将 `sendrecon` 重命名为 `sendtxrcncl`，`reqreconcil` 重命名为 `reqrecon`，`reqbisec` 重命名为 `reqsketchtext`。

  - 使用 `sendtxrcncl` 为协商支持增加详细信息。

- [BIPs #1367][] 通过尽可能多地引用 BIP [340][bip340] 和 [341][bip341] 来简化 [BIP118][] 对 [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] 的描述。

- [BIPs #1349][] 添加了名为“隐私支付”的 [BIP351][]，描述了一种受 [BIP47][bip47] 和[静默支付][topic silent payments]启发的密码学协议。该 BIP 引入了一种新的支付代码格式，参与者在其公钥旁指定支持的输出类型。与 BIP47 类似，发送者根据接收者的支付代码使用通知交易与接收者建立共享秘密。然后，发送者可以向从共享秘密中派生出的唯一地址发送多笔付款，接收者可以使用来自通知交易的信息来花费这些付款。在 BIP47 有多个发送者在对每个接收者复用相同通知地址的情况下，该提案使用标记有搜索密钥 `PP` 的 OP_RETURN 输出和特定于发送者-接收者对的通知代码来引起接收者的注意并建立共享秘密以提高隐私。

- [BIPs #1293][] 添加了 [BIP372][] 标题为“为 PSBT 调整向合约付款的字段”。此 BIP 提出了一个标准，用于包含额外的 [PSBT][topic psbt] 字段，这些字段为签名设备提供参与 [向合约付款][topic p2c]协议所需的合同承诺数据（参见 [周报 #184][news184 psbt]）。

- [BIPs #1364][] 为 [drivechain][topic sidechains] 的 [BIP300][] 规范的文本添加了额外的细节。[BIP301][] 中执行 drivechain 盲合并挖矿规则的相关规范也进行了更新。

{% include references.md %}
{% include linkers/issues.md v=2 issues="2435,962,1370,1367,1349,1293,1364" %}
[bitcoin core 24.0 rc1]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[bolt7 htlc_max]: https://github.com/lightning/bolts/blob/48fed66e26b80031d898c6492434fa9926237d64/07-routing-gossip.md#requirements-3
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/24.0-Release-Candidate-Testing-Guide
[zhao tx3]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-September/020937.html
[news167 packages]: /en/newsletters/2021/09/22/#package-mempool-acceptance-and-package-rbf
[sanders tx3]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-September/020938.html
[pickhardt ml valve]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-September/003686.html
[pickhardt bitmex valve]: https://blog.bitmex.com/the-power-of-htlc_maximum_msat-as-a-control-valve-for-better-flow-control-improved-reliability-and-lower-expected-payment-failure-rates-on-the-lightning-network/
[pickhardt ratecards]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-September/003696.html
[news219 ratecards]: /zh/newsletters/2022/09/28/#ln-fee-ratecards
[towns ratecards]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-September/003695.html
[zmnscpxj valve]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-September/003703.html
[news171 async]: /en/newsletters/2021/10/20/#paying-offline-ln-nodes
[news184 psbt]: /en/newsletters/2022/01/26/#psbt-extension-for-p2c-fields
