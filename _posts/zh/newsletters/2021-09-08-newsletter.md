---
title: 'Bitcoin Optech Newsletter #165'
permalink: /zh/newsletters/2021/09/08/
name: 2021-09-08-newsletter-zh
slug: 2021-09-08-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了一个关于比特币相关 MIME 类型的提案，并总结了一篇关于新型去中心化矿池设计的论文。还包括我们定期的板块，包括 Bitcoin Core PR 审查俱乐部会议总结、如何为 Taproot 做准备、新发布和发布候选版本，以及对流行比特币基础设施项目的重要更改。

## 新闻

- **<!--bitcoin-related-mime-types-->****比特币相关 MIME 类型：** Peter Gray [在 Bitcoin-Dev 邮件列表中发布][gray mime]了关于为 [PSBTs][topic psbt]、二进制格式的原始交易和 [BIP21][] URI 注册 MIME 类型的提案。Andrew Chow [解释道][chow mime]，他曾尝试为 PSBT 注册 MIME 类型，但他的申请被拒绝。他认为，注册 MIME 类型将需要编写 [IETF][] 规范（RFC），这可能需要大量工作才能将其转变为正式文件。Gray [建议][gray bip]，不如创建一个 BIP 来定义比特币应用程序使用的非正式 MIME 类型。

- **<!--braidpool-a-p2pool-alternative-->****Braidpool，P2Pool 替代方案：** [P2Pool][] 自 2011 年以来一直用于去中心化的基于池的比特币挖矿。一篇新的[论文][braidpool paper]被[发布][pool2win post]到 Bitcoin-Dev 邮件列表中，描述了几个已知的缺陷，并提出了一个替代的去中心化矿池设计，具有两个显著改进：通过使用支付通道并尽量减少对第三方的信任，更有效地利用区块空间进行支付；以及提高了矿池成员之间对更高延迟连接的容忍度。

## Bitcoin Core PR 审查俱乐部

*在这一月度板块中，我们总结了最近一次 [Bitcoin Core PR 审查俱乐部][Bitcoin Core PR Review Club]会议，重点讨论了其中的一些重要问题和答案。点击以下问题以查看会议中的答案摘要。*

[使用传统中继以下载块，仅在块模式下][review club #22340] 是 Niklas Gögge 提交的 PR，目的是让设置 `-blocksonly` 配置选项的节点始终使用传统区块中继下载区块。审查俱乐部比较了传统区块下载与 [BIP152][] 风格的[致密区块][topic compact block relay]下载，并讨论了为什么仅区块模式的节点不会从后者中受益。

{% include functions/details-list.md

  q0="**<!--q0-->**传统区块中继使用的消息序列是什么？"
  a0="运行 v0.10 及以上版本的节点使用[先头同步][headers first pr]：节点首先接收来自其对等节点的 `headers` 消息，其中包含区块头。在验证区块头之后，节点通过向宣布该区块的对等节点发送 `getdata(MSG_BLOCK, blockhash)` 消息来请求完整区块，然后对等节点回应 `block` 消息，包含完整区块。"
  a0link="https://bitcoincore.reviews/22340#l-49"

  q1="**<!--q1-->**BIP152 低带宽致密区块中继使用的消息序列是什么？"
  a1="对等节点通过在连接开始时发送 `sendcmpct` 来表示希望使用致密区块中继。低带宽致密区块中继与传统区块中继非常相似：在处理完区块头之后，节点通过发送 `getdata(MSG_CMPCT_BLOCK, blockhash)` 请求对等节点发送致密区块，并收到 `cmpctblock` 消息作为响应。节点可以使用致密区块短 ID 在其内存池和附加交易缓存中查找区块交易。如果有任何交易仍然未知，节点可以使用 `getblocktxn` 请求对等节点发送 `blocktxn` 消息。"
  a1link="https://bitcoincore.reviews/22340#l-56"

  q2="**<!--q2-->**BIP152 高带宽致密区块中继使用的消息序列是什么？"
  a2="节点在建立连接时，可以通过发送带有 `hb_mode` 设置为 1 的 `sendcmpct` 请求高带宽致密区块。这意味着对等节点可以直接发送 `cmpctblock`，而不必首先发送区块头或等待 `getdata` 请求。如果需要，节点可以像低带宽致密区块中继一样，通过 `getblocktxn` 和 `blocktxn` 请求下载任何未知的区块交易。"
  a2link="https://bitcoincore.reviews/22340#l-59"

  q3="**<!--q3-->**为什么致密区块中继会浪费仅区块模式节点的带宽？浪费了多少带宽？"
  a3="致密区块中继减少了有内存池的节点的带宽使用，因为它们不需要重新下载大部分区块交易。然而，处于仅区块模式的节点不参与交易中继，通常内存池为空，这意味着它们仍然需要下载所有交易。短 ID、`getblocktxn` 和 `blocktxn` 的开销[大约浪费了每个区块 38kB 的带宽][aj calculations]，并且 `getblocktxn` 和 `blocktxn` 消息的额外往返也增加了下载区块的时间。"
  a3link="https://bitcoincore.reviews/22340#l-82"

  q4="**<!--q4-->**仅区块模式的节点是否保留内存池？"
  a4="虽然仅区块模式的节点不参与交易中继，但它们仍然有内存池，并且该内存池可能包含几个不同原因的交易。例如，如果节点以前在正常模式下运行，然后重新启动到仅区块模式，内存池会在重新启动后被保存。另外，任何通过钱包和客户端接口提交的交易都会使用内存池进行验证和中继。"
  a4link="https://bitcoincore.reviews/22340#l-97"

  q5="**<!--q5-->**仅区块模式和仅区块中继模式有什么区别？这些更改是否也应该应用于仅区块中继连接？"
  a5="仅区块模式是节点的设置，而仅区块中继是对等连接的属性。当节点在仅区块模式下启动时，节点会在版本握手中向所有对等节点发送 `fRelay=false`，并断开发送任何与交易相关消息的对等节点。无论是否处于仅区块模式，节点可能有仅区块中继连接，这些连接会忽略传入的交易和地址消息。因此，仅区块中继连接的存在与节点的内存池内容和从致密区块消息重建区块的能力无关，因此这些更改不应应用于仅区块中继连接。"
  a5link="https://bitcoincore.reviews/22340#l-111"
%}

## 准备 Taproot #12：使用 Taproot 的保险库

*关于开发者和服务提供商如何为即将激活的 Taproot 做准备的每周[系列][series preparing for taproot]。*

{% include specials/taproot/zh/11-vaults-with-taproot.md %}

## 发布与发布候选版本

*比特币基础设施流行项目的新发布和发布候选版本。请考虑升级到新版本或帮助测试发布候选版本。*

- [Bitcoin Core 22.0rc3][bitcoin core 22.0] 是下一版本的发布候选版本，包含此全节点实现及其相关钱包和其他软件。新版本的主要更改包括支持 [I2P][topic anonymity networks] 连接，移除对[版本 2 Tor][topic anonymity networks] 连接的支持，以及增强对硬件钱包的支持。

- [Bitcoin Core 0.21.2rc2][bitcoin core 0.21.2] 是 Bitcoin Core 的维护版本发布候选版本，包含若干错误修复和小的改进。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范(BOLTs)][bolts repo] 中的重要更改。*

- [Bitcoin Core #22009][] 更新了钱包，始终运行分支限界（BnB）和背包算法进行[币选择][topic coin selection]，然后使用新的*浪费分数*启发式方法来比较结果的成本效益，选择最佳结果。以前，如果找到了没有找零的 BnB 结果，总是优先选择。

  浪费分数启发式方法假设每个输入最终必须以 10 sat/vB 的费率花费，并且找零输出是可以避免的。输入的评分为其当前费率和基准费率之间的差异，低费率花费的输入会扣除浪费分数，高费率花费的输入会增加浪费分数。找零输出始终会增加浪费分数，增加的部分包括找零输出创建的成本以及未来花费该输出的成本。

  在一个在不同费率下花费的钱包中，这种方法将把一些输入消费转移到较低的费率，从而减少整体钱包操作成本。基准费率将决定合并型和节俭型币选择行为的分界线，可以通过新的选项 `-consolidatefeerate` 来配置。随后，PR [Bitcoin Core #17526][] 提议增加一种基于单次随机抽取的第三种币选择算法。

- [Eclair #1907][] 更新了它使用区块链看门狗来防止 [eclipse 攻击][topic eclipse attacks]的方式（参见 [Newsletter #123][news123 eclair watchdogs]）。当 Tor 可用时，Eclair 现在使用它来联系看门狗（如果可能的话，使用本地 onion 端点）。这应使得上游攻击者更难仅选择性地审查看门狗提供者。

- [Eclair #1910][] 更新了它使用 Bitcoin Core 的 ZMQ 消息接口来提高学习新块的可靠性。其他使用 ZMQ 进行区块发现的人可能希望调查这些更改。

- [BIPs #1143][] 引入了 BIPs 380-386，规范了[输出脚本描述符][topic descriptors]。输出脚本描述符是一种简单的语言，包含了所有必要的信息，允许钱包或其他程序跟踪发送到或从特定脚本或一组相关脚本中花费的支付。 [BIP380][] 描述了该方法的哲学、结构、共享表达式和校验和。其余的 BIPs 规范了每个描述符函数本身，按以下类别分类：非 SegWit（[BIP381][]）、SegWit（[BIP382][]）、多签（[BIP383][]）、组合输出（[BIP384][]）、原始脚本和地址（[BIP385][]）以及树形（[BIP386][]）描述符。

- [BOLTs #847][] 允许两个通道对等方协商在共同关闭交易中应支付的费用。以前，只有一个费用被发送，另一方必须接受或拒绝该费用。 *[编辑：请参见下周的 Newsletter 获取[更准确][news166 fee negotiation] 的描述。]*

- [BOLTs #880][] 在 `openchannel` 和 `acceptchannel` 消息中添加了 `channel_type` 字段，允许发送方明确请求不同于节点广告功能位所隐含的通道功能。此向后兼容更改已在 [Eclair #1867][]、[LND #5669][] 实现，并正在作为 [C-Lightning #4616][] 合并。

- [BOLTs #824][] 对[锚定输出][topic anchor outputs]通道状态承诺协议进行了轻微调整。在早期协议中，预签名的 HTLC 支出可以包括费用，但这开启了在 [Newsletter #115][news115 anchor fees] 中描述的费用窃取攻击向量。在这个替代协议中，所有预签名的 HTLC 支出都使用零费用，因此无法窃取费用。

## 脚注

{% include references.md %}
{% include linkers/issues.md issues="22009,1907,1910,1143,847,880,824,1867,5669,4616,22340,17526" %}
[bitcoin core 22.0]: https://bitcoincore.org/bin/bitcoin-core-22.0/
[bitcoin core 0.21.2]: https://bitcoincore.org/bin/bitcoin-core-0.21.2/
[news115 anchor fees]: /zh/newsletters/2020/09/16/#stealing-onchain-fees-from-ln-htlcs
[news123 eclair watchdogs]: /zh/newsletters/2020/11/11/#eclair-1545
[p2pool]: https://bitcointalk.org/index.php?topic=18313.0
[gray mime]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-August/019385.html
[iana]: https://en.wikipedia.org/wiki/Internet_Assigned_Numbers_Authority
[chow mime]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-August/019386.html
[ietf]: https://en.wikipedia.org/wiki/Internet_Engineering_Task_Force
[gray bip]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-September/019390.html
[braidpool paper]: https://github.com/pool2win/braidpool/raw/main/proposal/proposal.pdf
[pool2win post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-August/019371.html
[aj calculations]: https://github.com/bitcoin/bitcoin/pull/22340#issuecomment-872723147
[headers first pr]: https://github.com/bitcoin/bitcoin/pull/4468
[news166 fee negotiation]: /zh/newsletters/2021/09/15/#c-lightning-4599
