---
title: 'Bitcoin Optech Newsletter #86'
permalink: /zh/newsletters/2020/02/26/
name: 2020-02-26-newsletter-zh
slug: 2020-02-26-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 公布了 2020 年 Chaincode 实习项目，描述了闪电网络（LN）中的两项路由改进提案，总结了斯坦福区块链会议上的三场精彩演讲，链接了一些 Bitcoin Stack Exchange 上的热门问答，并列出了几个比特币基础设施软件的重要更新。

## 行动项

- **<!--apply-to-the-chaincode-residency-->****申请 Chaincode 实习项目：** Chaincode Labs [宣布][residency announcement]其[第五期实习项目][residency]将于今年 6 月在纽约举行。该项目包括两个研讨会和讨论系列，涵盖比特币和闪电网络协议开发。对开源项目做出贡献感兴趣的开发者可以[申请][residency apply]比特币系列、LN 系列或同时申请这两个系列。欢迎各类背景的申请者，Chaincode 将根据需要承担差旅和住宿费用。

*注意：发布版和候选发布版列表已移至[独立部分][release rc section]。*

## 新闻

- **<!--reverse-up-front-payments-->****反向预付费机制：** 如 [Newsletter #72][news72 upfront] 所述，LN 开发者一直在寻找一种方法，即使 LN 支付（HTLC）被拒绝，也能收取少量路由费用。这样可以阻止那些消耗带宽和流动性但最终无成本失败的支付。本周，Joost Jager [提出][jager up-front]一种新方案，即从 HTLC 的接收者向支付发送者反向支付预付费。例如，如果一笔支付从 Alice 到 Bob 再到 Carol，那么 Alice 将从 Bob 那里收到一小笔费用，而 Bob 将从 Carol 那里收到一小笔费用。费用将与 HTLC 保持未决状态的时间成正比，从而激励快速路由或拒绝 HTLC，并确保使用[保留发票][topic hold invoices]（例如 Carol）的用户向路由节点（如 Bob）支付占用的路由资本。

  多位响应者对此提案表示赞同，并开始讨论其可能的实现方式以及需要克服的技术挑战。

- **<!--ln-direct-messages-->****LN 直接消息：** Rusty Russell [提议][russell dm]允许 LN 节点在不使用 LN 支付机制的情况下，在节点之间路由加密消息。这可以替代当前通过支付机制传递消息的方法（如 [Whatsat][]），从而简化协议，使其更易于构建其他功能（例如在 [Newsletter #72][news72 offers] 中描述的 *offers* 概念）。Russell 的提案最初规定使用与 LN 支付（HTLC）相同的往返洋葱路由，但开发者 ZmnSCPxj [建议][zmn circular]让消息发送者指定从其节点到消息接收者并返回发送者的完整路径。例如，如果 Alice 想与 Carol 通信，她可能会选择如下路径：

  ```
  Alice → Bob → Carol → Dan → Alice
  ```

  这种循环路由可以使监控更加困难，并减少路由节点存储返回路径的负担，使协议在路由节点上保持无状态。讨论仍在进行中，重点在于增强隐私性并防止该机制被滥用用于垃圾信息。

## 2020 斯坦福区块链会议的值得注意的演讲

斯坦福区块链研究中心上周举办了年度[斯坦福区块链会议][sbc]。会议为期三天，共进行了 30 多场演讲。我们总结了三场可能对 Optech Newsletter 读者特别感兴趣的演讲。

我们感谢会议组织者策划了这一活动，并在线提供了演讲视频（[第一天][day 1], [第二天][day 2], [第三天][day 3]），以及 Bryan Bishop 提供的[演讲记录][transcripts]。

- **<!--an-axiomatic-approach-to-block-rewards-->****区块奖励的公理化方法：** Tim Roughgarden 介绍了他与 Xi Chen 和 Christos Papadimitriou 共同进行的关于从[机制设计][mechanism design]理论角度分析比特币区块奖励分配规则的研究。([演讲记录][axiomatic txt], [视频][axiomatic vid], [论文][axiomatic paper]).

  Roughgarden 在演讲开场介绍了 _机制设计_ 这一概念，这是更为人熟知的 _博弈论_ 的逆向形式。博弈论描述游戏规则，然后推理这些规则会导致什么均衡和行为。相反，机制设计从预期结果出发，试图设计出能产生该结果的游戏规则。Roughgarden 问道：“如果我们有一个区块链协议空间的数学描述，并且我们可以选择我们最喜欢的目标函数并找到一个最佳协议，岂不是很好？”随后，Roughgarden 提出了在设计区块链奖励机制时希望实现的三条“公理”：

  1. _Sybil 抵抗_：
     任何矿工都不应通过将其公开身份拆分为多个部分来增加其奖励。

  2. _合谋抵抗_：
     任何矿工群体都不应通过将其独立身份合并为一个统一身份来增加其奖励。

  3. _匿名性_：
     奖励分配不应依赖于矿工的公开身份，如果矿工的算力被重新排列，则奖励也应以相同的方式重新排列。

  该论文随后提供了一个正式证明，表明满足这些公理的唯一奖励机制是按比例机制（即每个矿工根据其算力比例获得奖励）。该论文仅涉及单个区块创建的理论，并未考虑更长期的策略，如[自私挖矿][selfish mining]。

  对熟悉比特币的人来说，这一结果可能显而易见，但这种形式化处理显得新颖，并且可能是探索矿工更复杂行为（如长期策略和矿池行为）的良好基础。

- **<!--boomerang-redundancy-improves-latency-and-throughput-in-payment-channel-networks-->****Boomerang：冗余提升支付通道网络中的延迟和吞吐量：** Joachim Neu 介绍了他与 Vivek Bagaria 和 David Tse 合作的研究，旨在减少在比特币闪电网络等支付通道网络中使用[原子多路径支付][topic multipath payments]时的延迟，并防止流动性锁定。([演讲记录][boomerang txt], [视频][boomerang vid], [论文][boomerang paper]).

  多路径支付存在“等待最后一个”的_滞后问题_。这一分布式计算中的概念描述了，如果目标依赖于 n 项任务，那么该目标必须等待所有 n 项任务中最慢的一项完成。在多路径支付的背景下，这意味着如果支付者希望分五个部分支付 0.05 BTC，那么只有当所有这些部分都完成时，支付才能完成。这导致支付的高延迟以及路由流动性的减少，特别是在一个或多个部分失败并需要重试时。

  解决滞后问题的常见方法是引入冗余。在上述例子中，这意味着支付者进行七次 0.01 BTC 的部分支付，接收者接受首先成功路由的五个部分。问题变成了如何防止接收者接受全部七个部分，从而导致超额支付 0.02 BTC。

  Neu 等人提出了一种称为 _boomerang_ 合约的新方案。接收者选择支付部分的预映像作为[公开可验证秘密共享][pvss]方案中的份额。在上述例子中，可以从七个支付预映像中的六个重构秘密。然后，支付者构造七个支付部分，但每个部分都与一个反向（boomerang）条件相关联，如果支付者知道完整的秘密，则支付者可以取回全部金额。如果接收者仅接受五个或更少的支付部分，则支付者永远无法得知完整的秘密，boomerang 条款无法执行；但如果接收者作弊并接受六个或更多的部分，则支付者可以启动合约的 boomerang 条款，接收者无法赎回任何支付部分。

  论文还描述了在比特币中使用[适配器签名][adaptor signatures]基于 Schnorr 签名方案实现 boomerang 合约的方法。Neu 还指出，可以在 ECDSA 上创建适配器签名，因此 boomerang 合约理论上可以在当前的比特币中实现。

- **<!--remote-side-channel-attacks-on-anonymous-transactions-->****匿名交易的远程侧信道攻击：** Florian Tramer 介绍了他与 Dan Boneh 和 Kenneth G. Paterson 的研究，该研究涉及对 Monero 和 Zcash 中用户隐私的时间侧信道和流量分析攻击。([演讲记录][side-channel txt], [视频][side-channel vid], [论文][side-channel paper]).

  Monero 和 Zcash 是以隐私为重点的加密货币，它们使用加密技术（Monero 的[环签名][ring signatures]和[bulletproofs][]，Zcash 的[zk-SNARKs][]）来隐藏交易中发送者、接收者身份和交易金额。Tramer 等人展示，即使这些加密结构是正确的，具体实现细节也可能导致

身份和金额信息泄露给网络上的对手。

  当 Monero 或 Zcash 节点从点对点网络接收到一笔交易时，该交易会被传递到节点的钱包中以确定该交易是否属于该钱包。如果交易属于钱包，则钱包必须进行额外的计算以解密交易中的数据和金额，并且如果钱包在进行额外计算时暂停了节点的点对点活动，则攻击者可以利用[时间攻击][timing attack]来发现哪些交易与哪些节点相关联。研究者展示了这些时间攻击可以远程实施（通过从伦敦到苏黎世的广域网连接），并且可能通过类似的时间攻击来揭示 Zcash 交易中的金额。

  论文中的攻击不适用于 Bitcoin Core，因为 Bitcoin Core 钱包对自身交易和其他交易进行的计算差异很小（不涉及高级加密），并且自 v0.16 以来，钱包操作与点对点行为是异步处理的（参见 [Bitcoin Core #10286][]）。然而，论文中的观察足够普遍，对任何在比特币上实现系统的人都有借鉴意义，即允许钱包或应用处理影响点对点行为可能会泄露信息。

相关内容：Optech Newsletter 在 [Newsletter #32][news46 sbc] 中总结了去年的斯坦福区块链会议上的部分演讲。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选地之一——或者在闲暇时帮助好奇或困惑的用户。在这个月度专题中，我们精选了一些自上次更新以来发布的最高票问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{%
endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--what-s-the-relationship-between-slip39-and-bip39-->**[SLIP39 和 BIP39 之间的关系是什么？]({{bse}}93413) 用户 Thalis K. 区分了 BIP39（比特币改进提案），一种用于生成助记词并将其转换为确定性钱包种子的规范，以及 SLIP39（Satoshi Labs 改进提案），一种使用 Shamir 密钥共享方案（SSSS）将秘密拆分成多个部分的方案。

- **<!--how-is-the-bitcoin-difficulty-granularity-encoded-->**[比特币难度的精细度是如何编码的？]({{bse}}92990) 用户 zndtoshi 想知道在增加区块头哈希中的零数量会指数性地提高难度的情况下，挖矿难度如何实现如此精细的调整。Murch 解释了 `nBits`，以及*难度*与*目标*阈值之间的关系，并链接到了[详细示例和图表][stack exchange harding target answer]。

- **<!--could-taproot-create-larger-security-risks-or-hinder-future-protocol-adjustments-re-quantum-threats-->**[Taproot 会否带来更大的安全风险或阻碍应对量子威胁的未来协议调整？]({{bse}}93047) Pieter Wuille 回答了一些关于 Schnorr、Taproot 及其与后量子密码学（PQC）关系的问题。他进一步解释了一些零知识证明系统可能可以做到量子抗性。

## 发布与候选发布

*流行比特币基础设施的新发布与候选发布版本。请考虑升级到新版本或帮助测试候选发布版本。*

- [Bitcoin Core 0.19.1][] (候选发布版本)

- [LND 0.9.1][] (候选发布版本)

## 值得注意的代码和文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的更改。*

- [Bitcoin Core #13339][] 允许将钱包名称作为参数传递给用户提供的 `walletnotify` 交易通知脚本。此前，只有 txid 会传递给 `walletnotify` 脚本，这使得在多钱包模式下运行的用户难以确定哪个钱包收到了入账交易。此更改是增强[多钱包支持][multi-wallet support]的持续努力的一部分。该更改目前不支持 Windows 系统。

- [Eclair #1325][] 允许 `SendToRoute` 端点接受路由提示，从而帮助支付节点找到到接收节点的路径。

- [BOLTs #682][] 允许 `init` 消息包含一个 `networks` 字段，其中包含节点感兴趣的网络的标识符（链哈希），这可能有助于防止不同网络（例如 testnet 和 mainnet）的节点相互连接。

- [BOLTs #596][] 更新了 [BOLT2][]，允许 LN 节点宣传它们愿意接受超过此前约 0.17 BTC 最大值的通道开启。这是“wumbo”提案的功能之一，另一个功能是能够在通道中发送更大额的支付。详情参见 [Newsletter #22][news22 wumbo]。

## 鸣谢

我们感谢 Joachim Neu 和 Tim Roughgarden 对本期 Newsletter 斯坦福区块链会议演讲总结草稿的审阅。文中任何剩余的错误由 Newsletter 作者负责。

{% include references.md %}
{% include linkers/issues.md issues="1325,886,682,596,13339,10286" %}
[residency]: https://residency.chaincode.com
[residency announcement]: https://medium.com/@ChaincodeLabs/chaincode-summer-residency-2020-e80811834fa8
[residency apply]: https://residency.chaincode.com/#apply
[side-channel txt]: https://diyhpl.us/wiki/transcripts/stanford-blockchain-conference/2020/linking-anonymous-transactions/
[side-channel vid]: https://youtu.be/JhZUItnyQ0k?t=7706
[side-channel paper]: https://crypto.stanford.edu/timings/paper.pdf
[news46 sbc]: /zh/newsletters/2019/02/05/#斯坦福区块链会议上的值得注意的演讲
[axiomatic txt]: https://diyhpl.us/wiki/transcripts/stanford-blockchain-conference/2020/block-rewards/
[axiomatic vid]: https://youtu.be/BXLcKQ6fLsU?t=8545
[axiomatic paper]: https://arxiv.org/pdf/1909.10645.pdf
[boomerang txt]: https://diyhpl.us/wiki/transcripts/stanford-blockchain-conference/2020/boomerang/
[boomerang vid]: https://youtu.be/cNyB-MJdI20?t=6530
[boomerang paper]: https://arxiv.org/pdf/1910.01834.pdf
[sbc]: https://cbr.stanford.edu/sbc20/
[transcripts]: https://diyhpl.us/wiki/transcripts/stanford-blockchain-conference/2020/
[day 1]: https://www.youtube.com/watch?v=JhZUItnyQ0k
[day 2]: https://www.youtube.com/watch?v=BXLcKQ6fLsU
[day 3]: https://www.youtube.com/watch?v=cNyB-MJdI20
[bitcoin core 0.19.1]: https://bitcoincore.org/bin/bitcoin-core-0.19.1/
[sipa nonce updates]: https://github.com/sipa/bips/pull/198
[lnd 0.9.1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.9.1-beta.rc1
[release rc section]: #发布与候选发布
[news72 upfront]: /zh/newsletters/2019/11/13/#ln-up-front-payments
[jager up-front]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-February/002547.html
[russell dm]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-February/002552.html
[whatsat]: https://github.com/joostjager/whatsat
[news72 offers]: /zh/newsletters/2019/11/13/#proposed-bolt-for-ln-offers
[news83 nonce safety]: /zh/newsletters/2020/02/05/#safety-concerns-related-to-precomputed-public-keys-used-with-schnorr-signatures
[news22 wumbo]: /zh/newsletters/2018/11/20/#wumbo
[multi-wallet support]: https://github.com/bitcoin/bitcoin/projects/2#card-31911994
[stack exchange harding target answer]: https://bitcoin.stackexchange.com/questions/23912/how-is-the-target-section-of-a-block-header-calculated/36228#36228
[mechanism design]: https://en.wikipedia.org/wiki/Mechanism_design
[selfish mining]: https://www.cs.cornell.edu/~ie53/publications/btcProcFC.pdf
[pvss]: https://en.wikipedia.org/wiki/Publicly_Verifiable_Secret_Sharing
[adaptor signatures]: https://download.wpsoftware.net/bitcoin/wizardry/mw-slides/2018-05-18-l2/slides.pdf
[ring signatures]: https://en.wikipedia.org/wiki/Ring_signature
[bulletproofs]: https://eprint.iacr.org/2017/1066.pdf
[zk-SNARKs]: https://en.wikipedia.org/wiki/Non-interactive_zero-knowledge_proof
[timing attack]: https://en.wikipedia.org/wiki/Timing_attack
[zmn circular]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-February/002555.html
