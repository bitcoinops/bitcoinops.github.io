---
title: 'Bitcoin Optech Newsletter #228'
permalink: /zh/newsletters/2022/11/30/
name: 2022-11-30-newsletter-zh
slug: 2022-11-30-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报描述了一项使用信誉凭证代币来减轻对闪电网络阻塞攻击的提议。此外还包括我们的常规部分，其中包含新软件版本和候选版本的公告，以及热门比特币基础设施软件的重大变更的总结。

## 新闻
Reputation credentials proposal to mitigate LN jamming attacks
- **<!--reputation-credentials-proposal-to-mitigate-ln-jamming-attacks-->减轻闪电网络阻塞攻击的信誉凭证提案：**
  Antoine Riard 在 Lightning-Dev 邮件列表中[发表了][riard credentials]一个[提案][riard proposal]，介绍了一个新的基于凭证的信誉系统，以帮助防止攻击者临时性地阻塞支付（[HTLC][topic htlc])的时隙或价值来阻止诚实用户发送付款——这个问题被称为[通道阻塞攻击][topic channel jamming attacks]。

    在当今的闪电网络中，支付者要选择一条从他们的节点到达接收节点的路径，中间会跨越由独立转发节点运营的多个通道。他们要创建一组无需信任的指令，描述每个转发节点接下来应该在哪里中继支付，并加密这些指令以便每个节点只接收完成其工作所需的最少信息。

    Riard 建议每个转发节点应当只接受那些包含一个或多个先前由该转发节点发布的凭证代币的中继指令。凭据会包括一个[盲签名][blind signature]，防止转发节点直接确定哪个节点获发了凭据（防止转发节点学习花费者的网络身份）。尽管 Riard 建议了以下几种分发方法，但每个节点都可以根据自己的策略发布凭证：

    - *<!--upfront-payments-->预付款：*如果 Alice 的节点想通过 Bob 的节点转发付款，她的节点要首先使用闪电网络从 Bob 那里购买凭证。

    - *<!--previous-success-->先前的成功：*如果 Alice 通过 Bob 的节点发送的付款被最终接收者成功接受，Bob 的节点可以将凭证代币返回给 Alice 的节点——甚至返回比之前使用的更多的代币，允许 Alice 的节点未来通过 Bob 的节点来发送更多的价值。

    - *UTXO 所有权证明或其他替代方案：*虽然对于 Riard 的最初提议来说并不是必需的，但一些转发节点可能会试验性地向证明他们拥有比特币 UTXO 的每个人提供凭证。相较于较新或更低价值的 UTXO，这个过程可能会使用修饰符会将更多的凭证代币给予较旧或更高价值的 UTXO。每个转发节点自行选择如何分发其凭证代币时，任何其他标准均可使用。

    [周报 #226][news226 jam]中描述的部分基于本地声誉的提案的联合作者 Clara Shikhelman，在回复中[询问][shikelman credentials]证书代币是否可以在用户之间转移以及这是否会导致创建代币市场。她还询问了他们将如何使用支出节点不知道接收节点的完整路径的[盲化路径][topic rv routing]。

    Riard [回复][riard double spend]说，因为任何转账都需要信任，所以很难重新分配凭证代币并为它们创建市场。例如，如果 Bob 的节点向 Alice 颁发了一个新凭证，然后 Alice 试图将凭证卖给 Carol。那么即使 Carol 付了钱，Alice 也无法通过去信任化的方式证明她自己不会尝试使用该代币。

    对于盲化路径，[似乎][harding paths]接收者可以在不引发次生漏洞的情况下以加密形式提供任何必要的凭证。

    在相关的 [PR][bolts #1043] 中有更多对该提案的反馈。

## 新版本和候选版本

*热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [LND 0.15.5-beta.rc2][] 是 LND 维护版本的候选版本。根据其计划的发行说明，它仅包含小 bug 修复。

- [Core Lightning 22.11rc3][] 是 CLN 下一个主要版本的候选发布版本。尽管 CLN 版本继续使用[语义化版本命名][semantic versioning]，但该版本将是第一个使用新版本编号方案的版本。

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo] 和 [Lightning BOLTs][bolts repo]。*

- [Core Lightning #5727][] 开始弃用数值的 JSON 请求 ID，而使用字符串类型的 ID。已添加[文档][cln json ids]，描述字符串 ID 的好处以及如何充分利用它们的创建和解释。

- [Eclair #2499][] 允许在使用 [BOLT12 要约][topic offers]请求付款时指定要使用的盲化路径。该路径可能包括指向用户节点的路径加上经过它的附加跳数。经过该节点的跳数不会被使用，但它们会使花费者更难确定接收者距路径中的最后一个非盲化转发节点有多少跳。

- [LND #7122][] 增加了对 `lncli` 处理二进制 [PSBT][topic psbt] 文件的支持。[BIP174][] 指定 PSBT 可以在文件中编码为纯文本 Base64 或二进制文件。此前，LND 已经支持以纯文本或从文件中导入 Base64 编码的 PSBT。

- [LDK #1852][] 接受通道对手方提议的费率增加，即便该费率目前不足以安全地保持该通道开放。即使新的费率并不完全安全，它的更高价值意味着它比节点以前所拥有的更安全，所以最好接受它而不是尝试用现有的较低费率来关闭通道。未来对 LDK 的更改可能会关闭费率过低的通道，并且研究像[包中继（package relay）][topic package relay]这样的提案可能会使[锚点输出（anchor outputs）][topic anchor outputs]或类似的技术具备足够的适应能力以消除对当前问题的担忧费率。

- [Libsecp256k1 #993][] 在默认构建选项中包括了 extrakeys（与 x-only 公钥一起使用的函数）、[ECDH][] 和 [schnorr 签名][topic schnorr signatures]的模块。用于从签名重建公钥的模块仍不会被默认构建，“因为我们不建议为新协议使用 ECDSA 恢复。特别是，该恢复 API 容易被滥用：它会导致调用者忘记检查公钥（验证函数总是返回 1）。”

{% include references.md %}
{% include linkers/issues.md v=2 issues="5727,2499,7122,1852,993,1043" %}
[bitcoin core 24.0]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[bcc 24.0 rn]: https://github.com/bitcoin/bitcoin/blob/0ee1cfe94a1b735edc2581a05c4b12f8340ff609/doc/release-notes.md
[news222 rbf]: /zh/newsletters/2022/10/19/#transaction-replacement-option
[news223 rbf]: /zh/newsletters/2022/10/26/#continued-discussion-about-full-rbf
[news224 rbf]: /zh/newsletters/2022/11/02/#mempool-consistency
[lnd 0.15.5-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.5-beta.rc2
[core lightning 22.11rc3]: https://github.com/ElementsProject/lightning/releases/tag/v22.11rc3
[cln json ids]: https://github.com/rustyrussell/lightning/blob/a25c5d14fe986b67178988e6ebb79610672cc829/doc/lightningd-rpc.7.md#json-ids
[riard credentials]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-November/003754.html
[riard proposal]: https://github.com/lightning/bolts/blob/80214c83190836c4f7699af9e8920769607f1a00/www-reputation-credentials-protocol.md
[blind signature]: https://en.wikipedia.org/wiki/Blind_signature
[news226 jam]: /zh/newsletters/2022/11/16/#paper-about-channel-jamming-attacks
[shikelman credentials]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-November/003755.html
[riard double spend]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-November/003765.html
[harding paths]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-November/003767.html
[ecdh]: https://en.wikipedia.org/wiki/Elliptic-curve_Diffie%E2%80%93Hellman
[semantic versioning]: https://semver.org/spec/v2.0.0.html
