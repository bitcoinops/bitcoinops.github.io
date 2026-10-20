---
title: 'Bitcoin Optech Newsletter #86'
permalink: /zh/newsletters/2020/02/26/
name: 2020-02-26-newsletter-zh
slug: 2020-02-26-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 公布了 2020 年 Chaincode 驻留项目，描述了闪电网络（LN）上的两项路由改进提案，总结了斯坦福区块链会议上的三场精彩演讲，链接了一些 Bitcoin Stack Exchange 上的热门问答，并列出了热门比特币基础设施软件的若干值得注意的变更。

## 行动项

- **<!--apply-to-the-chaincode-residency-->****申请 Chaincode 驻留项目：** Chaincode Labs [宣布][residency announcement]其[第五期驻留项目][residency]将于今年 6 月在纽约举行。该项目包含两个系列的研讨会与讨论，分别涵盖比特币协议和闪电网络协议开发。有兴趣为开源项目做贡献的开发者可以[申请][residency apply]比特币系列或 LN 系列，也可以两个系列都申请。我们欢迎各种背景的申请者，Chaincode 将视需要承担差旅与住宿费用。

*注意：发布与候选发布的列表已移至[独立章节][release rc section]。*

## 新闻

- **<!--reverse-up-front-payments-->****反向预付手续费：** 如 [Newsletter #72][news72 upfront] 所述，LN 开发者一直在寻找一种方法，即便 LN 支付（HTLC）最终被拒绝，也能为路由该支付收取少量手续费。这样可以抑制那些有意消耗带宽和流动性、最终却无需付出代价就失败的支付。本周，Joost Jager [提出][jager up-front]了一种新方案：预付手续费由 HTLC 的收款方沿支付路径反向支付给付款方。例如，如果一笔支付从 Alice 经 Bob 发往 Carol，那么 Alice 会从 Bob 那里收到一小笔手续费，Bob 会从 Carol 那里收到一小笔手续费。手续费与 HTLC 保持待处理状态的时间成正比，从而激励节点快速路由或拒绝 HTLC，并确保[挂起发票][topic hold invoices]的使用者（例如 Carol）为路由节点（如 Bob）占用的路由资金付费。

  多位回复者似乎认可这一想法，并开始讨论它可能的实现方式以及需要克服的技术挑战。

- **<!--ln-direct-messages-->****LN 直接消息：** Rusty Russell [提议][russell dm]允许 LN 节点在不使用 LN 支付机制的情况下，在彼此之间路由加密消息。这可以用一个更简单的协议替代目前借助支付传递消息的做法（如 [Whatsat][]），而更简单的协议也更便于在其上构建其他功能（例如 [Newsletter #72][news72 offers] 中描述的 *offers* 概念）。Russell 的提案最初规定使用与 LN 支付（HTLC）相同的往返洋葱路由，但开发者 ZmnSCPxj [建议][zmn circular]让消息发送者指定从自己的节点到消息接收方、再回到发送者的完整路径。例如，如果 Alice 想与 Carol 通信，她可能会选择如下路径：

  ```
  Alice → Bob → Carol → Dan → Alice
  ```

  这种循环路由可以让监控更加困难，并消除路由节点必须存储返回路径的开销，从而使协议对路由节点无状态。截至本文写作时，讨论仍在进行，重点在于增强隐私性并防止该机制被滥用于发送垃圾信息。

## 2020 斯坦福区块链会议值得注意的演讲

斯坦福区块链研究中心上周举办了年度[斯坦福区块链会议][sbc]。会议为期三天，共进行了 30 多场演讲。我们总结了三场我们认为 Optech Newsletter 读者会特别感兴趣的演讲。

我们感谢会议组织者筹备会议议程并在线提供演讲视频（[第一天][day 1]、[第二天][day 2]、[第三天][day 3]），也感谢 Bryan Bishop 提供[演讲记录][transcripts]。

- **<!--an-axiomatic-approach-to-block-rewards-->****区块奖励的公理化方法：** Tim Roughgarden 介绍了他与 Xi Chen、Christos Papadimitriou 的合作研究：从[机制设计][mechanism design]理论的角度分析比特币的区块奖励分配规则（[演讲记录][axiomatic txt]、[视频][axiomatic vid]、[论文][axiomatic paper]）。

  Roughgarden 在演讲开场介绍了 _机制设计_ 这一概念，这是更为人熟知的 _博弈论_ 的逆向形式。博弈论描述游戏规则，然后推理这些规则会导致什么均衡和行为。相反，机制设计从预期结果出发，试图设计出能产生该结果的游戏规则。Roughgarden 问道：“如果我们有一个区块链协议空间的数学描述，并且我们可以选择我们最喜欢的目标函数并找到一个最佳协议，岂不是很好？”随后，Roughgarden 提出了在设计区块链奖励机制时希望实现的三条“公理”：

  1. _Sybil 抵抗_：
     任何矿工都不应通过将其公开身份拆分为多个部分来增加其奖励。

  2. _合谋抵抗_：
     任何矿工群体都不应通过将其独立身份合并为一个统一身份来增加其奖励。

  3. _匿名性_：
     奖励分配不应依赖于矿工的公开身份，如果矿工的算力被重新排列，则奖励也应以相同的方式重新排列。

  该论文随后给出了一个形式化证明，表明满足这些公理的唯一奖励机制是按比例机制（即每个矿工按其算力比例获得奖励）。该论文只讨论创建单个区块的相关理论，因此没有考虑[自私挖矿][selfish mining]这类更长期的策略。

  对熟悉比特币的人来说，这一结果可能显而易见，但这种形式化处理显得新颖，并且可能是探索矿工更复杂行为（如长期策略和矿池行为）的良好基础。

- **<!--boomerang-redundancy-improves-latency-and-throughput-in-payment-channel-networks-->****Boomerang：冗余改善支付通道网络的延迟与吞吐量：** Joachim Neu 介绍了他与 Vivek Bagaria 和 David Tse 合作的研究，旨在减少在比特币闪电网络等支付通道网络中使用[原子多路径支付][topic multipath payments]时的延迟，并防止流动性被锁定（[演讲记录][boomerang txt]、[视频][boomerang vid]、[论文][boomerang paper]）。

  多路径支付存在“等待最后一个”的_掉队者问题_。这一分布式计算中的概念描述的是：如果目标依赖于 n 项任务，那么该目标必须等待所有 n 项任务中最慢的一项完成。在多路径支付的背景下，这意味着如果付款方想支付 0.05 BTC、并把它拆成五个 0.01 BTC 的部分，那么只有当所有这些组成部分都完成时，支付才能完成。这导致支付延迟很高、路由流动性下降，尤其是在一个或多个部分失败并需要重试时。

  解决掉队者问题的常见方法是引入冗余。在上述例子中，这意味着付款方进行七次 0.01 BTC 的部分支付，收款方认领其中最先成功路由的五个。问题于是变成如何防止收款方认领全部七个部分，从而造成 0.02 BTC 的超额支付。

  Neu 等人提出了一种称为 _boomerang_ 合约的新方案。收款方选择各支付部分对应的原像（preimage），将其作为[公开可验证秘密共享][pvss]方案中的份额。在上述例子中，只要拿到七个支付原像中的六个就能重构秘密。接着，付款方构造七个支付部分，但每个部分都附带一个反向（boomerang）条件：如果付款方掌握完整的秘密，该条件会把全部金额付还给付款方。如果收款方只认领五个或更少的支付部分，付款方就永远无法获知完整的秘密，boomerang 条款也就无法触发；但如果收款方作弊、认领六个或更多部分，付款方就能触发合约中的 boomerang 条款，此时收款方无法兑付任何支付部分。

  论文还描述了如何在比特币中基于 schnorr 签名方案、使用[适配器签名][adaptor signatures]实现 boomerang 合约。Neu 还指出，也可以基于 ECDSA 创建适配器签名，因此 boomerang 合约理论上如今就能在比特币中实现。

- **<!--remote-side-channel-attacks-on-anonymous-transactions-->****匿名交易的远程侧信道攻击：** Florian Tramer 介绍了他与 Dan Boneh 和 Kenneth G. Paterson 的研究，该研究涉及对 Monero 和 Zcash 中用户隐私的时间侧信道和流量分析攻击（[演讲记录][side-channel txt]、[视频][side-channel vid]、[论文][side-channel paper]）。

  Monero 和 Zcash 是以隐私为重点的加密货币，它们使用密码学技术（Monero 用[环签名][ring signatures]和[bulletproofs][]，Zcash 用[zk-SNARKs][]）在公共账本上隐藏交易中的发送方身份、接收方身份和金额。Tramer 等人证明，即使这些密码学构造是正确的，实现细节仍可能让身份和金额信息泄露给网络上的对手。

  当 Monero 或 Zcash 节点从点对点网络接收到一笔交易时，该交易会被交给节点的钱包，由钱包判断这笔交易是否属于它。如果交易确实属于该钱包，钱包就必须额外进行计算，以解密交易中的数据和金额；如果钱包在进行这些额外计算时暂停了节点的点对点活动，攻击者就可以利用[时间攻击][timing attack]发现哪些交易属于哪个节点。论文作者证明，这些时间攻击可以远程实施（通过伦敦到苏黎世的广域网连接），而且类似的时间攻击也可能揭示 Zcash 交易中的金额。

  论文中的攻击不适用于 Bitcoin Core：Bitcoin Core 钱包处理自身交易与其他交易的计算量差异极小（不涉及高级密码学），并且自 v0.16 起，钱包操作已与点对点行为异步处理（参见 [Bitcoin Core #10286][]）。不过，论文中的观察足够普遍，值得任何在比特币上构建系统的人关注，即让钱包或应用的处理影响点对点行为可能泄露信息。

相关：Optech Newsletter 曾在 [Newsletter #32][news46 sbc] 中总结去年斯坦福区块链会议上的部分演讲。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们有点空闲时帮助好奇或困惑用户的地方。在本月栏目中，我们精选自上次更新以来得票最高的一些问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{%
endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--what-s-the-relationship-between-slip39-and-bip39-->**[SLIP39 和 BIP39 之间的关系是什么？]({{bse}}93413) 用户 Thalis K. 区分了 BIP39（比特币改进提案），一种用于生成助记词并将其转换为确定性钱包种子的规范，以及 SLIP39（Satoshi Labs 改进提案），一种使用 Shamir 秘密共享方案（SSSS）将秘密拆分成多个部分的方案。

- **<!--how-is-the-bitcoin-difficulty-granularity-encoded-->**[比特币难度的粒度是如何编码的？]({{bse}}92990) 用户 zndtoshi 想知道，既然增加区块头哈希中的前导零会指数级提高难度，挖矿难度又如何能做到如此精细的调整。Murch 解释了 `nBits`，以及*难度*与*目标*阈值之间的关系，并链接到了[详细示例和图表][stack exchange harding target answer]。

- **<!--could-taproot-create-larger-security-risks-or-hinder-future-protocol-adjustments-re-quantum-threats-->**[Taproot 会带来更大的安全风险，还是会阻碍未来针对量子威胁的协议调整？]({{bse}}93047) Pieter Wuille 回答了一些关于 schnorr、taproot 及其与后量子密码学（PQC）关系的问题。他进一步解释说，某些零知识证明系统或许可以做到抗量子。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [Bitcoin Core 0.19.1][]（候选发布版本）

- [LND 0.9.1][]（候选发布版本）

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络 BOLT 规范][bolts repo]中的值得注意的变更。*

- [Bitcoin Core #13339][] 允许将钱包名称作为参数传递给用户提供的 `walletnotify` 交易通知脚本。此前，只有 txid 会传递给 `walletnotify` 脚本，这使得在多钱包模式下运行的用户难以确定哪个钱包收到了入账交易。此更改是增强[多钱包支持][multi-wallet support]的持续努力的一部分。该更改目前不支持 Windows 系统。

- [Eclair #1325][] 允许 `SendToRoute` 端点接受路由提示，从而帮助付款节点找到通往收款节点的路径。

- [BOLTs #682][] 允许 `init` 消息包含一个 `networks` 字段，里面填写节点所关心的网络标识符（链哈希），这可能有助于防止某个网络（例如 testnet）的节点连接到另一个网络（例如 mainnet）的节点。

- [BOLTs #596][] 更新 [BOLT2][]，允许 LN 节点宣告愿意接受超过此前约 0.17 BTC 上限的通道开启。这是“wumbo”提案的功能之一，另一个功能是能够在通道中发送更大额的支付。详情参见 [Newsletter #22][news22 wumbo]。

## 致谢

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
