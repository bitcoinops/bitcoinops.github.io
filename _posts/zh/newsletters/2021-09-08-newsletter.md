---
title: 'Bitcoin Optech Newsletter #165'
permalink: /zh/newsletters/2021/09/08/
name: 2021-09-08-newsletter-zh
slug: 2021-09-08-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 介绍了一项关于比特币相关 MIME 类型的提案，并总结了一篇关于新型去中心化矿池设计的论文。此外还有我们的常规栏目：Bitcoin Core PR 审查俱乐部会议总结、如何为 Taproot 做准备、新版本与候选版本，以及热门比特币基础设施项目值得注意的变更。

## 新闻

- **<!--bitcoin-related-mime-types-->****比特币相关 MIME 类型：** Peter Gray [在 Bitcoin-Dev 邮件列表上发帖][gray mime]，讨论向 [IANA][] 注册[部分签名比特币交易（PSBT）][topic psbt]、二进制格式原始交易和 [BIP21][] URI 的 MIME 类型。Andrew Chow [解释][chow mime]说，他此前曾尝试为 PSBT 注册 MIME 类型，但申请被拒。他认为，注册 MIME 类型需要编写 [IETF][] 规范（即 RFC），而推动它成为一份正式文档可能要花很大功夫。Gray 于是[建议][gray bip]，不如创建一个 BIP，用来定义供比特币应用使用的非官方 MIME 类型。

- **<!--braidpool-a-p2pool-alternative-->****Braidpool，P2Pool 的替代方案：** 自 2011 年以来，[P2Pool][] 一直是比特币去中心化矿池挖矿所用的系统。有人在 Bitcoin-Dev 邮件列表上[发布][pool2win post]了一篇新[论文][braidpool paper]，指出它的若干缺陷，并提出另一种去中心化矿池设计，其中有两点明显改进：借助对第三方信任极低的支付通道，更高效地利用区块空间来发放收益；以及更能容忍矿池成员之间的高延迟连接。

## Bitcoin Core PR 审查俱乐部

*在这一月度板块中，我们总结了最近一次 [Bitcoin Core PR 审查俱乐部][Bitcoin Core PR Review Club]会议，重点讨论了其中的一些重要问题和答案。点击以下问题以查看会议中的答案摘要。*

[在仅区块模式下使用传统中继下载区块][review club #22340] 是 Niklas Gögge 提交的 PR，目的是让设置了 `-blocksonly` 配置选项的节点在下载区块时始终使用传统的中继方式。审查俱乐部比较了传统区块下载与 [BIP152][] 风格的[紧凑区块][topic compact block relay]下载，并讨论了为什么仅区块模式的节点不会从后者中受益。

{% include functions/details-list.md

  q0="**<!--q0-->**传统区块中继使用的消息序列是什么？"
  a0="运行 v0.10 及以上版本的节点使用[区块头优先同步][headers first pr]：节点先收到对等节点的 `headers` 消息，其中包含区块头。验证完区块头后，节点向宣布该区块的对等节点发送 `getdata(MSG_BLOCK, blockhash)` 消息来请求完整区块，对等节点则以包含完整区块的 `block` 消息回应。"
  a0link="https://bitcoincore.reviews/22340#l-49"

  q1="**<!--q1-->**BIP152 低带宽紧凑区块中继使用的消息序列是什么？"
  a1="对等节点在连接开始时发送 `sendcmpct`，表示希望使用紧凑区块中继。低带宽紧凑区块中继与传统区块中继非常相似：处理完区块头之后，节点用 `getdata(MSG_CMPCT_BLOCK, blockhash)` 向对等节点请求紧凑区块，并收到 `cmpctblock` 作为回应。节点可以用紧凑区块的短 ID，在自己的内存池和额外交易缓存中查找区块里的交易。若还有交易未知，可以用 `getblocktxn` 向对等节点请求，并收到 `blocktxn` 消息作为回应。"
  a1link="https://bitcoincore.reviews/22340#l-56"

  q2="**<!--q2-->**BIP152 高带宽紧凑区块中继使用的消息序列是什么？"
  a2="节点在建立连接时，可以发送 `hb_mode` 设为 1 的 `sendcmpct`，向对等节点请求高带宽紧凑区块。这意味着对等节点可以直接发送 `cmpctblock`，不必先发送区块头，也不必等待 `getdata` 请求。如有需要，节点可以像低带宽紧凑区块中继那样，用 `getblocktxn` 和 `blocktxn` 请求并下载任何未知的区块交易。"
  a2link="https://bitcoincore.reviews/22340#l-59"

  q3="**<!--q3-->**为什么紧凑区块中继会在区块下载期间浪费仅区块模式节点的带宽？浪费了多少带宽？"
  a3="紧凑区块中继能减少有内存池的节点的带宽占用，因为它们不必重新下载区块中的大部分交易。然而，处于仅区块模式的节点不参与交易中继，内存池通常是空的，因此它们无论如何都要下载全部交易。短 ID、`getblocktxn` 和 `blocktxn` 的开销[合计约每个区块浪费 38kB 带宽][aj calculations]，而 `getblocktxn` 和 `blocktxn` 消息带来的额外往返也延长了下载区块的时间。"
  a3link="https://bitcoincore.reviews/22340#l-82"

  q4="**<!--q4-->**仅区块模式的节点会保留内存池吗？"
  a4="虽然仅区块模式的节点不参与交易中继，但它们仍有内存池，其中可能因几种原因而存有交易。例如，节点原本在正常模式下运行，之后以仅区块模式重启，内存池会在重启后保留下来。此外，通过钱包和客户端接口提交的任何交易，都会借助内存池进行验证和中继。"
  a4link="https://bitcoincore.reviews/22340#l-97"

  q5="**<!--q5-->**仅区块模式与仅区块中继有什么区别？这些改动是否也应适用于仅区块中继连接？"
  a5="仅区块模式是节点层面的设置，而仅区块中继是某条对等连接的属性。节点以仅区块模式启动时，会在版本握手中向所有对等节点发送 `fRelay=false`，并断开任何发送交易相关消息的对等节点。无论是否处于仅区块模式，节点都可能有仅区块中继连接，并在这些连接上忽略传入的交易消息和 `addr` 消息。可见，仅区块中继连接是否存在，与节点的内存池内容、以及能否从紧凑区块消息重建区块无关，因此这些改动不应适用于仅区块中继连接。"
  a5link="https://bitcoincore.reviews/22340#l-111"
%}

## 准备 Taproot #12：配合 Taproot 的保险库

*每周一期的[系列][series preparing for taproot]，介绍开发者与服务提供商如何为 Taproot 在区块高度 {{site.trb}} 的激活做准备。*

{% include specials/taproot/zh/11-vaults-with-taproot.md %}

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [Bitcoin Core 22.0rc3][bitcoin core 22.0] 是该全节点实现及其配套钱包和其他软件下一个主要版本的候选版本。这个新版本的主要变更包括：支持 [I2P][topic anonymity networks] 连接，移除对[版本 2 Tor][topic anonymity networks] 连接的支持，以及加强对硬件钱包的支持。

- [Bitcoin Core 0.21.2rc2][bitcoin core 0.21.2] 是 Bitcoin Core 一个维护版本的候选版本，包含多项错误修复和若干小改进。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]的值得注意的变更。*

- [Bitcoin Core #22009][] 更新了钱包：现在总是同时运行分支限界（BnB）与背包算法来做[选币][topic coin selection]，再用新的*浪费分数*启发式方法比较各结果的成本效益，挑出最优结果。此前，只要找到无需找零的 BnB 结果，就总是优先采用它。

  浪费分数这一启发式方法假设每个输入最终都会以 10 sat/vB 的费率被花费，并且假设找零输出是可以避免的。每个输入的得分，是它在当前费率下的成本与基准费率下的成本之差，因此以低于基准的费率花费输入会降低浪费分数，以更高的费率花费则会提高浪费分数。找零输出总会提高浪费分数，提高的幅度包括创建该找零输出的成本，以及将来花费它所需的成本。

  对于会在不同费率下花费的钱包，这种做法会把一部分输入的使用转移到较低的费率上，从而降低钱包的整体运行成本。区分整合型与节俭型选币行为的基准费率，可以通过新选项 `-consolidatefeerate` 来配置。后续的 PR [Bitcoin Core #17526][] 提议再加一种基于单次随机抽取（Single Random Draw）的选币算法。

- [Eclair #1907][] 更新了它利用区块链看门狗来防止[日食攻击][topic eclipse attacks]的方式（参见 [Newsletter #123][news123 eclair watchdogs]）。当 Tor 可用时，Eclair 现在改用它来联系看门狗（尽可能使用原生 onion 端点）。这应能让上游攻击者更难只针对性地审查看门狗服务提供者。

- [Eclair #1910][] 更新了它使用 Bitcoin Core 的 ZMQ 消息接口的方式，以提高获知新区块的可靠性。其他使用 ZMQ 发现新区块的人或许也值得研究这些改动。

- [BIPs #1143][] 引入了 BIP 380 至 386，用于规范[输出脚本描述符][topic descriptors]。输出脚本描述符是一种简单的语言，包含让钱包或其他程序跟踪发往某个脚本（或某组相关脚本）以及从中花费的支付所需的全部信息。[BIP380][] 描述了它的设计理念、总体结构、共享表达式和校验和。其余 BIP 则逐一规范每种描述符函数，按类别分为：非 segwit（[BIP381][]）、segwit（[BIP382][]）、多重签名（[BIP383][]）、组合输出（[BIP384][]）、原始脚本与地址（[BIP385][]）以及树形（[BIP386][]）描述符。

- [BOLTs #847][] 允许一对通道对等节点协商共同关闭交易应支付多少手续费。此前只会发送一个手续费数值，另一方必须接受或拒绝这个确切的数值。*[编辑：更准确的描述见下周的 Newsletter][news166 fee negotiation]。*

- [BOLTs #880][] 在 `openchannel` 和 `acceptchannel` 消息中新增了 `channel_type` 字段，让发送方可以明确提出与节点公布的功能位所隐含的通道特性不同的要求。这一向后兼容的改动已在 [Eclair #1867][]、[LND #5669][] 中实现，并作为 [C-Lightning #4616][] 的一部分等待合并。

- [BOLTs #824][] 为[锚定输出][topic anchor outputs]通道状态承诺协议增加了一个小变体。在早先的协议中，预签名的 [HTLC][topic htlc] 花费可以包含手续费，但这开启了 [Newsletter #115][news115 anchor fees] 中描述的手续费窃取攻击向量。在这一替代协议中，所有预签名的 HTLC 花费都使用零手续费，因此无法窃取到任何手续费。

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
[series preparing for taproot]: /zh/preparing-for-taproot/
