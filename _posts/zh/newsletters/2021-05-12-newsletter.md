---
title: 'Bitcoin Optech Newsletter #148'
permalink: /zh/newsletters/2021/05/12/
name: 2021-05-12-newsletter-zh
slug: 2021-05-12-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了一个安全披露问题，该问题会影响依赖于特定 BIP125 可选 RBF（Replace By Fee）行为的协议，同时包含我们的常规栏目：Bitcoin Core PR 审查俱乐部会议总结、新的软件发布与候选发布公告以及对热门比特币基础设施软件值得注意的更改的描述。

## 新闻

- **<!--cve-2021-31876-discrepancy-between-bip125-and-bitcoin-core-implementation-->****CVE-2021-31876：BIP125 与 Bitcoin Core 实现之间的差异：**
  [BIP125][] 对可选 RBF（Replace By Fee）[topic rbf] 的规范指出，如果一个未确认的父交易信号表明它可以被替换，那么花费该父交易输出的任意子交易也可以通过推断继承的方式被替换。然而，本周 Antoine Riard 在 Bitcoin-Dev 邮件列表中[发布了][riard cve-2021-31876]他此前私下报告的完整披露，指出 Bitcoin Core 并未实现该行为。尽管如此，如果子交易本身明确表明它可以被替换，或者当父交易被替换后子交易从内存池中被驱逐，那么这些子交易仍然可以被替换。

  Riard 分析了无法使用继承式可替换机制可能对当前及提案中的各种协议造成的影响。只有 LN 似乎会受影响，并且仅体现为一种已知攻击（参见 [Newsletter #95][news95 atomicity attack] 中描述的使用[交易固定][topic transaction pinning]的方法）成本更低。各 LN 实现正在逐步部署的[锚定输出][topic anchor outputs] 将会杜绝这一固定方式。

  截至撰写本文时，邮件列表上尚未对该问题进行任何实质性讨论。

- **<!--call-for-brink-grant-applications-->****Brink 资助申请征集：**
  Bitcoin Optech 鼓励任何为开源比特币或闪电网络项目做出贡献的工程师在 5 月 17 日截止日期前[申请 Brink 资助][brink grant application]。初次资助期限为一年，允许开发者在世界任何地方全职投入到开源项目中。

## Bitcoin Core PR 审查俱乐部

*在本月度栏目中，我们总结了最近一次 [Bitcoin Core PR 审查俱乐部][Bitcoin Core PR Review Club]会议，并重点介绍了其中的一些重要问答。点击下方任意问题可查看会议中的回答概述。*

[介绍节点重广播模块][review club #21061] 是一个由 Amiti Uttarwar 发起的 PR（[#21061][Bitcoin Core #21061]），它继续了重广播项目的工作（参见之前的 Newsletter [#64][rebroadcast 1]、[#96][rebroadcast 2]、[#129][rebroadcast 3] 和 [#142][rebroadcast 4]），该项目此前也在审查俱乐部 [#16698][review club #16698] 与 [#18038][review club #18038] 中讨论过，目标是让节点对钱包交易的重广播行为与对其他节点交易的重广播行为无法区分。

本次审查俱乐部的讨论聚焦于当前的交易行为及提议中的更改：

{% include functions/details-list.md
  q0="**<!--q0-->**为什么我们可能需要重广播一笔交易？"
  a0="当我们的交易没有被传播出去（也许节点当时处于离线状态），或者似乎已被其他节点的内存池丢弃时（如从网络中消失），我们会想要重广播这笔交易。"
  a0link="https://bitcoincore.reviews/21061#l-39"

  q1="**<!--q1-->**节点为什么会从它的内存池中丢弃一笔交易？"
  a1="除被打包进区块之外，一笔交易可能在 14 天后过期、也可能因更高手续费的交易而挤掉（默认内存池大小 300 MiB）、还可能被基于 [BIP125][] 可选 RBF（Replace By Fee）（RBF（Replace By Fee）[topic rbf]）的机制所替换、或当与之冲突的交易被包含进区块后而被移除；此外，如果交易被打包进某个区块而该区块后来发生重组而失效（reorg），节点在[更新内存池][UpdateMempoolForReorg]时会尝试重新添加这笔交易以保证内存池数据一致。"
  a1link="https://bitcoincore.reviews/21061#l-53"

  q2="**<!--q2-->**每个钱包自行重广播它的交易，这种现有行为可能出现什么问题？"
  a2="这会带来隐私泄露的风险，可能把 IP 地址与钱包地址关联起来。因为根据当前的重广播行为，如果一个节点多次广播同一笔交易，实际上就会暗示这笔交易来自它自己的钱包。"
  a2link="https://bitcoincore.reviews/21061#l-58"

  q3="**<!--q3-->**矿工在什么情况下会排除内存池中已有的交易？"
  a3="例如当矿工因为手续费过低而降低了这笔交易的优先级、矿工还未收到该交易、矿工已基于 RBF（Replace By Fee）将其从内存池中移除、对其进行审查、或是挖出了一个空区块时。"

  q4="**<!--q4-->**矿工在什么情况下会包含不在我们内存池中的交易？"
  a4="例如矿工主动提升了这笔交易的优先级（例如作为一种商业服务）、矿工在我们节点之前收到了这笔交易、或该交易与我们内存池中的另一笔交易冲突但对矿工而言并不冲突时。"

  q5="**<!--q5-->**正在审议的提案将如何决定要重广播哪些交易？"
  a5="它建议在每个新区块出现时，重广播那些手续费率高于某个估算值的交易，这些交易需满足以下条件：已存在至少 30 分钟、已重广播次数不超过 6 次并且距离上次重广播至少间隔 4 小时，且从符合这些条件的交易中最多挑选 3/4 的交易进行重广播。"
  a5link="https://bitcoincore.reviews/21061#l-63"

  q6="**<!--q6-->**为什么在交易被移出我们的内存池后，我们仍可能想在重广播尝试跟踪器里保留这笔交易？"
  a6="当出现共识规则更改时，网络上可能还存在未升级的节点会重广播不符合新共识规则的交易。若在重广播尝试跟踪器里保留这些交易，那么对于这些节点而言，它们对这类交易的重广播总次数仍会受到限制（在 90 天内最多重广播 6 次），并且在到期后可让这类交易失效。"
  a6link="https://bitcoincore.reviews/21061#l-178"

  q7="**<!--q7-->**在什么情况下我们会从重广播尝试跟踪器里移除某笔交易？"
  a7="当这笔交易被确认、被 RBF（Replace By Fee）[topic rbf] 替换，或者与某个被打包进区块的交易冲突时，就会被移除。"
  a7link="https://bitcoincore.reviews/21061#l-199"

  q8="**<!--q8-->**重广播所使用的最低手续费率是如何估算的？为什么不直接用上一个被挖出区块里的最低手续费率？"
  a8="重广播的最低手续费率大约每分钟计算一次，通过从内存池中模拟组建下一个将被挖出的区块得出。这比单纯使用上一个已挖出区块的最低手续费率更好，因为它基于近期的交易环境和对未来的预估，而不是基于过去。"
  a8link="https://bitcoincore.reviews/21061#l-227"
%}

## 发布与候选发布

*针对热门比特币基础设施项目的新发布版本或候选版本。请考虑升级至新版本或协助测试候选版本。*

- **<!--n3-->**[Rust-Lightning 0.0.14][Rust-Lightning 0.0.14] 是一个新版本，使 Rust-Lightning 更好地兼容来自 Electrum 风格服务器的数据，新增了更多配置选项，并改进了与闪电网络规范的兼容性，此外还包括其他一些错误修复和改进。

## 值得注意的代码和文档更改

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo] 和 [闪电网络规范（BOLTs）][bolts repo] 中值得注意的更改。*

- [Bitcoin Core #20867][Bitcoin Core #20867] 将可被包含在多签[描述符][topic descriptors]并可用于 `addmultisigaddress` 和 `createmultisig` RPC 中的密钥数量从 16 个增加到 20 个。只有在 P2WSH 输出类型中才能使用此扩大后的限制。P2SH 输出受限于 520 字节的脚本大小，只能容纳 15 个压缩公钥。

- [Bitcoin Core GUI #125][Bitcoin Core GUI #125] 允许用户在引导对话框中更改自动修剪区块所占用的空间大小（默认为一个固定值）。同时还改进了对修剪存储工作方式的描述，明确指出下载并处理完整区块链后，未来会丢弃部分数据以保持较低的磁盘使用量。

- [C-Lightning #4489][C-Lightning #4489] 添加了一个名为 `funder` 的插件，用于配置响应传入通道开启请求时的[双向资助][topic dual funding]出资行为。用户可以设置出资策略（百分比匹配、当前可用资金百分比或固定额度）、一个低于该额度就不再进行双向资助的钱包保留金额、对单笔通道开启请求的最大出资额等。

  该 PR 标志着 C-Lightning 节点间实验性双向资助功能已实现的最后一步。围绕这项工作的交互式交易构建与通道建立 v2 协议目前仍在 [BOLTs #851][BOLTs #851] 中公开标准化讨论。

- [C-Lightning #4496][C-Lightning #4496] 为插件添加了注册通知主题的能力。其他插件可以订阅这些主题以接收相应通知。
  C-Lightning 本身已经有一些内置主题，但该合并的 PR 允许插件作者为任何想要使用的新主题类别创建和消费通知。

- [Rust Bitcoin #589][Rust Bitcoin #589] 开始了对 [taproot][topic taproot] 及 [schnorr 签名][topic schnorr signatures] 的支持。现有的 ECDSA 支持被移动到一个新的模块中，但依旧以之前的名称对外暴露，以保持 API 兼容性。一个新的 `util::schnorr` 模块则为 [BIP340][] 提供 schnorr 密钥编码支持。Issue [#588][rust bitcoin #588] 将用于追踪对 taproot 完整实现的后续工作。

{% include references.md %}
{% include linkers/issues.md issues="20867,125,4489,4496,589,588,21061,16698,18038,851" %}
[riard cve-2021-31876]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-May/018893.html
[news95 atomicity attack]: /zh/newsletters/2020/04/29/#new-attack-against-ln-payment-atomicity
[rust-lightning 0.0.14]: https://github.com/rust-bitcoin/rust-lightning/releases/tag/v0.0.14
[rebroadcast 1]: /zh/newsletters/2019/09/18/#bitcoin-core-rebroadcasting-logic
[rebroadcast 2]: /zh/newsletters/2020/05/06/#bitcoin-core-18038
[rebroadcast 3]: /zh/newsletters/2020/12/23/#transaction-origin-privacy
[rebroadcast 4]: /zh/newsletters/2021/03/31/#will-nodes-with-a-larger-than-default-mempool-retransmit-transactions-that-have-been-dropped-from-smaller-mempools
[UpdateMempoolForReorg]: https://github.com/bitcoin/bitcoin/blob/e175a20769/src/validation.cpp#L357
[brink grant application]: https://brink.homerun.co/grants
