---
title: 'Bitcoin Optech Newsletter #39'
permalink: /zh/newsletters/2019/03/26/
name: 2019-03-26-newsletter-zh
slug: 2019-03-26-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 链接到一个加密 P2P 通信的提议，并介绍了 Lightning Loop，一个用于从 LN 通道中提取比特币到链上交易的工具和服务。还包括有关 bech32 采用的资源链接、Bitcoin Stack Exchange 上流行问题和答案的摘要以及流行的比特币基础设施项目中的值得注意的代码更改列表。

{% include references.md %}

## 行动项

- **<!--help-test-bitcoin-core-0-18-0-rc2-->****帮助测试 Bitcoin Core 0.18.0 RC2：**下一个主要版本的 Bitcoin Core 的第二个候选版本（RC）已经[发布][0.18.0]。计划运行新版本 Bitcoin Core 的组织和有经验的用户仍然需要进行测试。使用[此问题][Bitcoin Core #15555]报告反馈。

## 新闻

- **<!--version-2-p2p-transport-proposal-->****版本 2 P2P 传输提议：**Jonas Schnelli 向 Bitcoin-Dev 邮件列表发送了一个[提议的 BIP][v2 transport]，该 BIP 指定了用于加密节点间流量的算法。它还指定了一些协议消息创建的其他小变化，如允许节点使用节省带宽的短标识符以及消除消息上的 SHA256 基础校验和，因为 [AEAD][] 基础的加密方案保护了数据完整性。该提议旨在替代 [BIP151][]，并包含链接到 Bitcoin Core 的示例实现和一些基准测试。参见 [Newsletter #10][] 了解先前关于 P2P 协议加密的讨论。

- **<!--loop-announced-->****Loop 宣布：**Lightning Labs [宣布][loop announced]了一个新工具和服务，以促进*潜艇交换*、基于 HTLC 的链下比特币和链上比特币的原子交换。本质上，Alice 通过 LN 付款给 Bob，并通过她知道的一个秘密来保障付款，防止 Bob 领取它。然后 Bob 创建一个 Alice 可以通过揭示秘密来使用的链上付款。Alice 等待付款收到足够数量的确认后，花费它到她选择的任意地址——在此过程中揭示秘密。Bob 看到 Alice 的链上交易，并使用其揭示的秘密来领取 Alice 早些时候发送给他的 LN 付款。如果 Alice 没有揭示秘密，链上付款包含一个退款条件，允许 Bob 在时间锁过期后将其返还给自己。

  大部分过程是无信任的，所以只要软件操作（并且被操作）正确，任何一方都没有机会从对方那里偷窃。例外情况是创建初始的链上交易和 Bob 可能需要创建的退款交易：如果无信任交换没有发生，Bob 将不会获得任何这两个交易所需的链上交易费用的补偿。根据 [Loop 文档][loop documentation]，他们的实现让 Alice 预先通过 LN 向 Bob 发送一个小额信任付款，作为善意和保证操作不会让 Bob 损失钱财。

  通过允许 Alice 和 Bob 交换链上和链下资金，同时继续使用他们现有的通道，Loop 帮助用户保持他们的通道开放更长时间，并使他们可能无限期地保持开放。

- **<!--square-crypto-developer-group-announced-->****Square Crypto 开发者团队宣布：**Square 的 CEO [在 Twitter 上宣布][sqcrypto announced]他们正在组建一个团队，雇佣几位贡献于开源比特币项目的开发者和一位设计师。参见他们的公告了解申请说明。（注意：Square 也是 Optech 的赞助成员。）

## Bech32 发送支持

*第 2 周，共 24 周。从现在到 2019 年 8 月 24 日 segwit 软分叉锁定的第二个周年纪念日，Optech Newsletter 将包含这一每周部分，提供信息以帮助开发者和组织实现 bech32 发送支持——支付本地 segwit 地址的能力。这[不要求实现 segwit][bech32 series]本身，但它确实允许你支付的对象访问 segwit 的所有多个好处。*

{% include specials/bech32/zh/02-stats.md %}

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选地之一——或者当我们有一些空闲时间来帮助好奇或困惑的用户时。在这个月度特写中，我们突出自上次更新以来的一些最高投票问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--multiple-questions-about-ln-transport-security-->**多个关于 LN 传输安全的问题：Rene Pickhardt 提出了几个关于用于通信 LN 消息的加密的问题，例如[为什么消息长度被加密？]({{bse}}85259)和[ChaCha20-Poly1305 有什么特别之处？]({{bse}}84953)。这些问题的答案在比特币 P2P 加密传输协议的提议 BIP 的背景下可能特别有趣，该协议计划使用相同的密码。

- **<!--multiple-questions-about-schnorr-based-signatures-->**多个关于 Schnorr 签名的问题：Pickhard 还提出了几个关于 [BIP-Schnorr][]、[Taproot][] 和使这些功能在比特币交易中可用的计划的问题。参见 [Schnorr 是否允许每个区块一个签名？]({{bse}}85213)和 [MuSig 的安全性是否与当前的比特币多签相同？]({{bse}}85101)。

- **<!--how-were-the-parameters-for-the-secp256k1-curve-chosen-->**[secp256k1 曲线参数是如何选择的？]({{bse}}85387)这是比特币中使用的椭圆曲线。一些曲线参数在安全性中起着重要作用，因此了解这些参数是否被明智地选择是很有用的。其他参数对安全性影响不大，但它们的历史可能仍然很有趣。在他的回答中，Gregory Maxwell 提供了他迄今为止所了解的历史、对为什么仍然未解决的问题不影响安全性的解释以及为什么我们可能永远无法了解某些曲线参数起源的更多信息。

- **<!--what-addresses-should-i-support-when-developing-a-wallet-->**[开发钱包时我应该支持哪些地址？]({{bse}}84978)一个开发者问他是否应该支持 P2PKH (`1foo...`) 地址和 P2SH 包装的 segwit (`3bar...`) 地址，还是仅提供 P2SH 地址是安全的。Andrew Chow 回答说，仅 P2SH 地址就足够了。Gregory Maxwell 补充说，如果开发者决定显示两个地址，一个更好的组合将是 P2SH 包装的 segwit 地址和本地 segwit（bech32）地址 (`bc1baz...`)。

## 值得注意的代码和文档更改

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和 [Bitcoin Improvement Proposals (BIPs)][bips repo] 中的值得注意的更改。*

- [Bitcoin Core #10973][] 使 Bitcoin Core 的内置钱包组件通过一个定义明确的接口访问区块链信息，而不是直接访问节点组件上的函数和变量。此更新没有与用户相关的可见变化，但该合并值得注意，因为它是最后一组基础重构中的一部分，这些重构应使未来的更改能够让节点和钱包/GUI 在单独的进程中运行变得容易（参见 [Bitcoin Core #10102][] 了解一种方法），以及改进 Bitcoin Core 代码库的模块化并允许更有针对性的组件测试。除了为未来的重大变化奠定基础外，这个 PR 因为开放了一年半以上，收到了将近 200 条代码审查评论和回复，并且需要超过 150 次更新和重建而值得注意。Optech 感谢 PR 作者 Russell Yanofsky 在看到此 PR 合并方面所做的惊人奉献。

- [Bitcoin Core #15617][] 省略发送包含节点当前在其封禁列表中的节点的 IP 地址的 `addr` 消息。这防止你的节点告诉其他节点它发现的被认为是滥用的节点。

- [Bitcoin Core #13541][] 修改了 `sendrawtransaction` RPC，将 `allowhighfees` 参数替换为 `maxfeerate` 参数。早期的参数如果设置为 true，即使总费用超过 `maxtxfee` 配置选项（默认：0.1 BTC）设置的金额也会发送交易。新参数接受一个费用率，如果其费用率高于提供的值，将拒绝交易（无论 `maxtxfee` 的设置如何）。如果没有提供值，它将仅在费用低于 `maxtxfee` 总额时发送交易。

- [LND #2765][] 更改了 LN 节点响应通道违规（企图盗窃）的方式。以前，如果检测到企图违规，节点会创建一个违约补救交易以收取与该通道相关的所有资金。但是，当用户开始使用瞭望塔时，瞭望塔可能会创建一个违约补救交易，但不包括所有可能的资金。（这并不意味着瞭望塔是恶意的：你的节点可能只是没有机会告诉瞭望塔它接受的最新承诺。）这个 PR 更新了用于生成违约补救交易的逻辑，使其仅收取未被先前的违约补救交易收取的资金，允许恢复瞭望塔未收取的任何资金。

- [LND #2691][] 在恢复期间将默认的地址预见值从 250 增加到 2,500。这是在为你的资金重新扫描区块链时钱包使用的从 HD 种子派生的密钥数量。以前，如果你的节点给出了超过 250 个地址或公钥而没有使用它们，你的节点不会在第一次重新扫描中找到你的完整余额，需要你启动额外的尝试。现在，你需要给出超过 2,500 个地址，重新扫描可能变得必要。这个 PR 的早期版本希望将这个值设置为 25,000，但有人担心这会显著减慢使用 BIP158 Neutrino 实现的重新扫描，因此在显示人们需要这么高的值之前减少了该值。（注意：检查 BIP158 过滤器的地址本身非常快；问题是任何匹配都需要下载和扫描相关的区块——即使是误报匹配。你检查的地址越多，预期的误报越多，因此扫描变得更慢并需要更多带宽。）

- [C-Lightning #2470][] 修改了最近添加的 `setchannelfee` RPC，以便可以传递“all”而不是特定节点的 ID 以设置所有通道的路由费用。

- [Eclair #826][] 更新 Eclair 以兼容 Bitcoin Core 0.17 和即将发布的 0.18，取消对 0.16 的支持。

{% include linkers/issues.md issues="10973,15617,13541,2765,2691,2470,826,15555,10102" %}
[0.18.0]: https://bitcoincore.org/bin/bitcoin-core-0.18.0/
[aead]: https://en.wikipedia.org/wiki/Authenticated_encryption
[loop announced]: https://blog.lightning.engineering/posts/2019/03/20/loop.html
[loop documentation]: https://github.com/lightninglabs/loop/blob/master/docs/architecture.md
[sqcrypto announced]: https://twitter.com/jack/status/1108487911802966017
[taproot]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-January/015614.html
[v2 transport]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-March/016806.html
[bech32 series]: /zh/bech32-sending-support/
[newsletter #10]: /zh/newsletters/2018/08/28//#pr-opened-for-initial-bip151-support