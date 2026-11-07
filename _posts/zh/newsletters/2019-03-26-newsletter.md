---
title: 'Bitcoin Optech Newsletter #39'
permalink: /zh/newsletters/2019/03/26/
name: 2019-03-26-newsletter-zh
slug: 2019-03-26-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 介绍了一项加密 P2P 通信的提议，并介绍了 Lightning Loop——一个把比特币从 LN 通道取出、转入链上交易的工具与服务。此外还包括 bech32 采用情况的相关资源链接、Bitcoin Stack Exchange 上热门问答的摘要，以及热门比特币基础设施项目中值得注意的代码变更列表。

{% include references.md %}

## 行动项

- **<!--help-test-bitcoin-core-0-18-0-rc2-->****帮助测试 Bitcoin Core 0.18.0 RC2：**Bitcoin Core 下一个主要版本的第二个候选版本（RC）已经[发布][0.18.0]。计划在生产环境中运行新版 Bitcoin Core 的组织和有经验的用户仍需参与测试。请通过[这个问题][Bitcoin Core #15555]报告反馈。

## 新闻

- **<!--version-2-p2p-transport-proposal-->****版本 2 P2P 传输提议：**Jonas Schnelli 向 Bitcoin-Dev 邮件列表提交了一份[提议的 BIP][v2 transport]，其中规定了用于加密对等节点之间流量的算法。它还规定了对协议消息构造方式的其他几处细微改动，例如允许对等节点使用节省带宽的短标识符，以及取消消息上基于 SHA256 的校验和——因为基于 [AEAD][] 的加密方案已经保护了数据完整性。该提案意在取代 [BIP151][]，其中还附有 Bitcoin Core 示例实现与若干基准测试的链接。此前关于 P2P 协议加密的讨论，参见 [Newsletter #10][]。

- **<!--loop-announced-->****Loop 发布：**Lightning Labs [宣布][loop announced]了一个新工具与服务，用来促成*潜艇交换（submarine swap）*——即用 HTLC 把链下比特币原子交换为链上比特币。本质上，Alice 向 Bob 发送一笔 LN 付款，这笔付款由只有 Alice 知道的秘密加以保障，使 Bob 无法领取。随后 Bob 创建一笔链上付款，Alice 只要揭示该秘密就能花费它。Alice 等这笔付款获得足够多的确认后，再把它花费到自己选择的任意地址——同时也就揭示了这个秘密。Bob 看到 Alice 的链上交易，用其中揭示的秘密领取 Alice 先前发送给他的 LN 付款。如果 Alice 始终不揭示秘密，这笔链上付款就带有一个退款条件，允许 Bob 在时间锁过期后把钱收回自己手中。

  这一过程大部分是无须信任的，因此只要软件（以及操作它的人）行为正确，任何一方都没有机会从对方那里偷钱。例外是最初那笔链上交易的创建，以及 Bob 可能还需要创建一笔退款交易：如果无须信任的交换没有发生，Bob 为这两笔交易支付的链上手续费将得不到任何补偿。根据 [Loop 文档][loop documentation]，他们的实现会让 Alice 在这一无须信任的交换之前，先通过 LN 向 Bob 发送一笔小额的可信付款，既表示善意，也保证这笔操作最终不会让 Bob 亏钱。

  通过让 Alice 和 Bob 在继续使用现有通道的同时交换链上与链下资金，Loop 帮助用户把通道开得更久，甚至让人设想通道可以一直开着。

- **<!--square-crypto-developer-group-announced-->****Square Crypto 开发者团队成立：**Square 的 CEO [在 Twitter 上宣布][sqcrypto announced]，他们正在组建一个团队，聘用若干为开源比特币项目做贡献的人，既包括开发者，也包括一位设计师。申请方式见其公告。（注意：Square 也是 Optech 的赞助成员。）

## Bech32 发送支持

*第 2 周，共 24 周。从现在到 2019 年 8 月 24 日 segwit 软分叉锁定满两周年，Optech Newsletter 每周都会包含这一栏目，提供信息帮助开发者和组织实现 bech32 发送支持——也就是能够向原生 segwit 地址付款。你[不需要自己实现 segwit][bech32 series]，但你付款的对象却能享受到 segwit 带来的种种好处。*

{% include specials/bech32/zh/02-stats.md %}

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们有点空闲时帮助好奇或困惑用户的地方。在本月栏目中，我们精选自上次更新以来得票最高的一些问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--multiple-questions-about-ln-transport-security-->**多个关于 LN 传输安全的问题：Rene Pickhardt 提出了几个关于 LN 消息通信所用加密的问题，例如[为什么消息长度要加密？]({{bse}}85259)和 [ChaCha20-Poly1305 有什么特别之处？]({{bse}}84953)。结合那份为比特币 P2P 加密传输协议提出的 BIP 来看，这些回答可能格外有意思——该提案计划采用同样的密码算法。

- **<!--multiple-questions-about-schnorr-based-signatures-->**多个关于 Schnorr 签名的问题：Pickhard 还提出了几个关于 [BIP-Schnorr][]、[Taproot][] 以及让这些特性可用于比特币交易的计划的提问。参见 [Schnorr 是否允许每个区块只有一个签名？]({{bse}}85213)和 [MuSig 的安全性是否与当前比特币多重签名相同？]({{bse}}85101)。

- **<!--how-were-the-parameters-for-the-secp256k1-curve-chosen-->**[secp256k1 曲线参数是如何选择的？]({{bse}}85387)这是比特币所用的椭圆曲线。有些曲线参数对安全性至关重要，因此了解这些参数是否选择得当很有用。另一些参数对安全性影响不大，但它们的来历可能仍然有趣。Gregory Maxwell 在回答中给出他迄今了解到的历史，解释了为何这些仍未解决的问题不影响安全性，以及为何我们可能永远无法进一步了解某些曲线参数的由来。

- **<!--what-addresses-should-i-support-when-developing-a-wallet-->**[开发钱包时我应该支持哪些地址？]({{bse}}84978)一位开发者问：他应该同时支持 P2PKH (`1foo...`) 地址和 P2SH 包装的 segwit (`3bar...`) 地址，还是只提供 P2SH 地址也没问题。Andrew Chow 回答说，只用 P2SH 地址就够了。Gregory Maxwell 进一步补充说，如果开发者确实决定显示两个地址，更好的组合是 P2SH 包装的 segwit 地址加上一个原生 segwit（bech32）地址 (`bc1baz...`)。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和[比特币改进提案（BIPs）][bips repo] 中值得注意的变更。*

- [Bitcoin Core #10973][] 让 Bitcoin Core 的内置钱包组件通过一个定义良好的接口访问区块链信息，而不是直接调用节点组件上的函数和变量。此更新没有用户可见的变化，但这次合并值得注意：它是一系列基础性重构中的最后一项，这些重构应当能让日后的改动轻松实现节点与钱包/GUI 分进程运行（参见 [Bitcoin Core #10102][] 了解其中一种思路），同时提升 Bitcoin Core 代码库的模块化程度，并支持更有针对性的组件测试。除了为日后的重大变更奠定基础，这个 PR 值得一提还因为它开放了一年半以上，收到近 200 条代码审查评论和回复，并经历了 150 多次更新与变基（rebase）。Optech 感谢该 PR 的作者 Russell Yanofsky，为他坚持推动这个 PR 最终合并所付出的非凡努力。

- [Bitcoin Core #15617][] 不再发送 `addr` 消息去传播那些当前位于本节点封禁列表中的对等节点的 IP 地址。这可以防止你的节点把它认定有滥用行为的对等节点告知其他节点。

- [Bitcoin Core #13541][] 修改了 `sendrawtransaction` RPC，把 `allowhighfees` 参数替换为 `maxfeerate` 参数。旧参数若设为 true，即使总手续费超过 `maxtxfee` 配置选项（默认：0.1 BTC）所设的金额，交易仍会被发送。新参数接受一个费率；如果交易的费率高于给定值，就会拒绝该交易（无论 `maxtxfee` 如何设置）。如果没有提供该值，则只有当总手续费低于 `maxtxfee` 时才会发送交易。

- [LND #2765][] 更改了 LN 节点应对通道违约（企图盗取资金）的方式。以前一旦检测到有人企图违约，节点会创建一笔违约补救交易，收取该通道相关的全部资金。但用户开始使用瞭望塔后，瞭望塔创建的违约补救交易可能并没有包含所有可追回的资金。（这并不意味着瞭望塔有恶意：你的节点可能只是没机会告诉瞭望塔它接受的最新承诺。）这个 PR 更新了生成违约补救交易的逻辑，使其只收取此前违约补救交易尚未收取的那部分资金，从而把瞭望塔漏收的资金追回来。

- [LND #2691][] 把恢复期间的默认地址前瞻值从 250 提高到 2,500。这个值指的是钱包在为你的资金重新扫描区块链时，从 HD 种子派生出的密钥数量。以前，如果你的节点发出超过 250 个地址或公钥而其中没有一个被使用，节点在第一次重新扫描时就找不到你的完整余额，需要你再发起更多次扫描。现在，你得先发出超过 2,500 个地址，才可能需要重复扫描。这个 PR 的早期版本想把这个值设为 25,000，但有人担心这会显著拖慢使用 BIP158 Neutrino 实现的重新扫描，因此该值被调低，直到有证据表明人们确实需要这么高的值为止。（注意：用 BIP158 过滤器核对地址本身非常快；问题在于任何匹配都需要下载并扫描对应的区块——即使只是误报匹配。你核对的地址越多，预期出现的误报就越多，于是扫描变得更慢，也更占带宽。）

- [C-Lightning #2470][] 修改了最近加入的 `setchannelfee` RPC，以便可以传入“all”而不是某个特定节点的 ID，从而为所有通道设置路由手续费。

- [Eclair #826][] 更新 Eclair 以兼容 Bitcoin Core 0.17 和即将发布的 0.18，取消对 0.16 的支持。

{% include linkers/issues.md issues="10973,15617,13541,2765,2691,2470,826,15555,10102" %}
[0.18.0]: https://bitcoincore.org/bin/bitcoin-core-0.18.0/
[aead]: https://en.wikipedia.org/wiki/Authenticated_encryption
[loop announced]: https://blog.lightning.engineering/posts/2019/03/20/loop.html
[loop documentation]: https://github.com/lightninglabs/loop/blob/master/docs/architecture.md
[sqcrypto announced]: https://twitter.com/jack/status/1108487911802966017
[taproot]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-January/015614.html
[v2 transport]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-March/016806.html
[bech32 series]: /zh/bech32-sending-support/
[newsletter #10]: /zh/newsletters/2018/08/28/#pr-opened-for-initial-bip151-support
