---
title: 'Bitcoin Optech Newsletter #360'
permalink: /zh/newsletters/2025/06/27/
name: 2025-06-27-newsletter-zh
slug: 2025-06-27-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报总结了关于使用 P2P 协议消息对全节点进行指纹识别的研究，并就可能在 BIP380 描述符规范中移除对 BIP32 路径中 `H` 的支持寻求反馈。此外还包括我们的常规部分：总结了 Bitcoin Stack Exchange 上的热门问答、新版本和候选版本的公告，以及对热门比特币基础设施软件的重大变更介绍。

## 新闻

- **<!--fingerprinting-nodes-using-addr-messages-->****使用 `addr` 消息对节点进行指纹识别：** Daniela Brozzoni 在 Delving Bitcoin 上[发布][brozzoni addr]了她与开发者 Naiyoma 进行的研究，该研究关于使用节点发送的 `addr` 消息在多个网络上识别同一个节点。节点向其对等节点发送 P2P 协议 `addr`（地址）消息来广告其他潜在节点，允许对等节点使用去中心化的 gossip 系统找到彼此。然而，Brozzoni 和 Naiyoma 能够使用其特定地址消息的详细信息对单个节点进行指纹识别，使他们能够识别在多个网络（如 IPv4 和 [Tor][topic anonymity networks]）上运行的同一个节点。

  研究人员建议了两种可能的缓解措施：从地址消息中移除时间戳，或者如果保留时间戳，则稍微随机化它们以使其对特定节点的特异性降低。

- **<!--does-any-software-use-h-in-descriptors-->****是否有软件在描述符中使用 `H`？** Ava Chow 在 Bitcoin-Dev 邮件列表上[发布][chow hard]询问是否有任何软件生成使用大写 H 来表示强化 [BIP32][topic bip32] 密钥派生步骤的描述符。如果没有，[输出脚本描述符][topic descriptors]的 [BIP380][] 规范可能会被修改为只允许使用小写 h 和 `'` 来表示强化。Chow 指出，虽然 BIP32 允许大写 H，但 BIP380 规范之前包含了一个禁止使用大写 H 的测试，并且 Bitcoin Core 目前不接受大写 H。

## Bitcoin Stack Exchange 的精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选之地之一，也是我们有闲暇时会给好奇和困惑的用户帮忙的地方。在这个月度栏目中，我们会列举自上次出刊以来出现的一些高票的问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--is-there-any-way-to-block-bitcoin-knots-nodes-as-my-peers-->有什么方法可以阻止 Bitcoin Knots 节点作为我的对等节点吗？]({{bse}}127456)
  Vojtěch Strnad 提供了一种基于用户代理字符串使用两个 Bitcoin Core RPC 阻止对等节点的方法，但不鼓励这种方法，并指向了一个相关的 [Bitcoin Core GitHub issue][Bitcoin Core #30036]，其中也有类似的不鼓励意见。

- [<!--what-does-op-cat-do-with-integers-->OP_CAT 对整数如何操作？]({{bse}}127436)
  Pieter Wuille 解释说 Bitcoin Script 堆栈元素不包含数据类型信息，不同的操作码以不同的方式解释堆栈元素的字节。

- [<!--async-block-relaying-with-compact-block-relay-bip152-->使用致密区块中继的异步区块中继（BIP152）]({{bse}}127420)
  用户 bca-0353f40e 概述了 Bitcoin Core 对[致密区块][topic compact block relay]的处理，并估计了缺失交易对区块传播的影响。

- [<!--why-is-attacker-revenue-in-selfish-mining-disproportional-to-its-hash-power-->为什么自私挖矿中攻击者的收入与其算力不成比例？]({{bse}}53030)
  Antoine Poinsot 跟进了这个和[另一个]({{bse}}125682)较早的[自私挖矿][topic selfish mining]问题，指出“难度调整不考虑陈旧区块，这意味着降低竞争矿工的有效算力会增加矿工的利润（在足够长的时间尺度上），就像增加自己的算力一样”，（参见[周报 #358][news358 selfish mining]）。

## 新版本和候选版本

*热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Bitcoin Core 28.2][] 是主流全节点实现的前一个发布系列的维护版本。它包含多个错误修复。

## 重大的代码和文档变更

*本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals（BIPs）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Bitcoin Core #31981][] 向进程间通信（IPC）`Mining` 接口（参见周报 [#310][news310 ipc]）添加了一个 `checkBlock` 方法，该方法执行与 `proposal` 模式下的 `getblocktemplate` RPC 相同的有效性检查。这使得使用 [Stratum v2][topic pooled mining] 的矿池能够通过更快的 IPC 接口验证矿工提供的区块模板，而不是通过 RPC 序列化多达 4 MB 的 JSON。可以在选项中禁用工作量证明和默克尔根检查。

- [Eclair #3109][] 将其[可归因故障][topic attributable failures]支持（参见周报 [#356][news356 failures]）扩展到[蹦床支付][topic trampoline payments]。蹦床节点现在解密并存储为其准备的归因载荷部分，并为下一个蹦床跳跃准备剩余的数据块。此 PR 不实现蹦床节点的归因数据中继，这预计在后续 PR 中实现。

- [LND #9950][] 向 `DescribeGraph`、`GetNodeInfo` 和 `GetChanInfo` RPC 以及它们对应的 `lncli` 命令添加了一个新的 `include_auth_proof` 标志。包含此标志会返回[通道公告][topic channel announcements]签名，允许第三方软件验证通道详细信息。

- [LDK #3868][] 将[可归因故障][topic attributable failures]（参见周报 [#349][news349 attributable]）载荷的 [HTLC][topic htlc] 持有时间精度从 1 毫秒单位降低到 100 毫秒单位，以减轻时序指纹泄露。这使 LDK 与 [BOLTs #1044][] 草案的最新更新保持一致。

- [LDK #3873][] 将在注资输出被花费后忘记短通道标识符（SCID）的延迟从 12 个区块增加到 144 个区块，以允许[通道拼接][topic splicing]更新的传播。这是 [BOLTs #1270][] 中引入的 72 个区块延迟的两倍，Eclair 已实现该延迟（参见周报 [#359][news359 eclair]）。此 PR 还实现了对 `splice_locked` 消息交换过程的额外更改。

- [Libsecp256k1 #1678][] 添加了一个 `secp256k1_objs` CMake 接口库，该库公开了库的所有目标文件，以允许父项目（如 Bitcoin Core 计划的 [libbitcoinkernel][libbitcoinkernel project]）将这些目标直接链接到它们自己的静态库中。这解决了 CMake 缺乏将静态库链接到另一个静态库的原生机制的问题，并使下游用户免于提供自己的 `libsecp256k1` 二进制文件。

- [BIPs #1803][] 通过允许所有常见的强化路径标记来澄清 [BIP380][] 的[描述符][topic descriptors]语法，而 [#1871][bips #1871]、[#1867][bips #1867] 和 [#1866][bips #1866] 通过收紧密钥路径规则、允许重复参与者密钥和明确限制多路径子派生来完善 [BIP390][] 的 [MuSig2][topic musig] 描述符。

{% include snippets/recap-ad.md when="2025-07-01 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31981,3109,9950,3868,3873,1678,1803,1871,1867,1866,30036,1044,1270" %}
[bitcoin core 28.2]: https://bitcoincore.org/bin/bitcoin-core-28.2/
[brozzoni addr]: https://delvingbitcoin.org/t/fingerprinting-nodes-via-addr-requests/1786/
[chow hard]: https://mailing-list.bitcoindevs.xyz/bitcoindev/848d3d4b-94a5-4e7c-b178-62cf5015b65f@achow101.com/T/#u
[news358 selfish mining]: /zh/newsletters/2025/06/13/#calculating-the-selfish-mining-danger-threshold
[news310 ipc]: /zh/newsletters/2024/07/05/#bitcoin-core-30200
[news356 failures]: /zh/newsletters/2025/05/30/#eclair-3065
[news349 attributable]: /zh/newsletters/2025/04/11/#ldk-2256
[news359 eclair]: /zh/newsletters/2025/06/20/#eclair-3110
[libbitcoinkernel project]: https://github.com/bitcoin/bitcoin/issues/27587
