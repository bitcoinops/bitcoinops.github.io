---
title: 'Bitcoin Optech Newsletter #148'
permalink: /zh/newsletters/2021/05/12/
name: 2021-05-12-newsletter-zh
slug: 2021-05-12-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 介绍一项安全披露：它会影响依赖 BIP125 某种选择性手续费替换行为的协议。此外还包括我们的固定栏目：Bitcoin Core PR 审查俱乐部会议总结、新软件发布与候选发布公告，以及热门比特币基础设施软件值得注意的代码与文档变更。

## 新闻

- **<!--cve-2021-31876-discrepancy-between-bip125-and-bitcoin-core-implementation-->****CVE-2021-31876：BIP125 与 Bitcoin Core 实现之间的差异：**
  [BIP125][] 关于选择性手续费替换（[RBF][topic rbf]）的规范指出，一笔未确认的父交易如果发出可被替换的信号，那么花费该父交易输出的任意子交易也会通过推断继承而同样可被替换。本周，Antoine Riard 在 Bitcoin-Dev 邮件列表中[公开][riard cve-2021-31876]了他此前私下报告的发现：Bitcoin Core 并未实现这一行为。不过，子交易如果自身明确发出可替换信号，仍有可能被替换；如果其父交易被替换，它也可能被从内存池中驱逐。

  Riard 分析了无法使用继承式可替换性可能对当前及提案中的各种协议造成的影响。只有 LN 似乎会受影响，而且仅体现为一种已有的攻击（参见 [Newsletter #95][news95 atomicity attack]）在使用[交易钉住][topic transaction pinning]时成本更低。各 LN 实现正在陆续部署的[锚定输出][topic anchor outputs]将会消除实施这种钉住的可能。

  截至撰写本文时，邮件列表上尚未对该问题进行任何实质性讨论。

- **<!--call-for-brink-grant-applications-->****Brink 资助申请征集：**
  Bitcoin Optech 鼓励任何为开源比特币或闪电网络项目做出贡献的工程师在 5 月 17 日截止日期前[申请 Brink 资助][brink grant application]。初次资助期限为一年，允许开发者在世界任何地方全职投入到开源项目中。

## Bitcoin Core PR 审查俱乐部

*在本月度栏目中，我们总结了最近一次 [Bitcoin Core PR 审查俱乐部][Bitcoin Core PR Review Club]会议，并重点介绍了其中的一些重要问答。点击下方任意问题可查看会议中的回答概述。*

[介绍节点重广播模块][review club #21061] 是一个由 Amiti Uttarwar 发起的 PR（[#21061][Bitcoin Core #21061]），它继续了重广播项目的工作（参见之前的 Newsletter [#64][rebroadcast 1]、[#96][rebroadcast 2]、[#129][rebroadcast 3] 和 [#142][rebroadcast 4]），该项目此前也在审查俱乐部 [#16698][review club #16698] 与 [#18038][review club #18038] 中讨论过，目标是让节点对钱包交易的重广播行为与其他对等节点的交易重广播行为无法区分。

本次审查俱乐部的讨论聚焦于当前的交易行为和提议的变更：

{% include functions/details-list.md
  q0="**<!--q0-->**为什么我们可能需要重广播一笔交易？"
  a0="当我们的交易没能传播出去（也许当时我们的节点离线），或者看起来已被网络中其他节点的内存池丢弃时。"
  a0link="https://bitcoincore.reviews/21061#l-39"

  q1="**<!--q1-->**节点为什么会从它的内存池中丢弃一笔交易？"
  a1="除被打包进区块之外，一笔交易还可能在 14 天后过期；也可能被手续费更高的交易挤出节点有限的内存池（默认大小 300 MiB）；还可能通过 [BIP125][] 的选择性手续费替换（[RBF][topic rbf]）被替换；若与之冲突的交易被打包进区块，它会被移除；此外，如果它所在的区块后来被重组掉，节点在[更新内存池][UpdateMempoolForReorg]时会尝试把它重新加回去，以在重组之后保持一致。"
  a1link="https://bitcoincore.reviews/21061#l-53"

  q2="**<!--q2-->**每个钱包自行重广播它的交易，这种现有行为可能出现什么问题？"
  a2="这会带来隐私泄露的风险，可能把 IP 地址与钱包地址关联起来，因为根据当前的重广播行为，如果一个节点多次广播同一笔交易，实际上就会暗示这笔交易来自它自己的钱包。"
  a2link="https://bitcoincore.reviews/21061#l-58"

  q3="**<!--q3-->**矿工在什么情况下会排除内存池中已有的交易？"
  a3="当矿工因为手续费低而把它降了优先级、还没看到这笔交易、通过 RBF 把它从自己的内存池中移除、对它进行了审查，或者挖出了一个空区块时。"

  q4="**<!--q4-->**矿工在什么情况下会包含不在我们内存池中的交易？"
  a4="当矿工手动提高了这笔交易的优先级（例如作为商业服务）、在我们节点之前就收到了它，或该交易与我们内存池中的另一笔交易冲突、但在矿工的内存池中并不冲突时。"

  q5="**<!--q5-->**正在审议的提案将如何决定要重广播哪些交易？"
  a5="它建议每出现一个新区块就执行一次：凡费率高于某个估算值、存在时间至少 30 分钟、累计重广播不超过 6 次、且距上次重广播至少 4 小时的交易都在重广播之列，但总量最多占一个区块可容纳交易数的 3/4。"
  a5link="https://bitcoincore.reviews/21061#l-63"

  q6="**<!--q6-->**为什么交易被移出我们的内存池后，我们仍可能想在重广播尝试跟踪器里保留这笔交易？"
  a6="共识规则变更之后，网络上可能还有未升级的节点在重广播不符合新共识规则的交易。把这些交易留在重广播尝试跟踪器里，可以避免这些节点把同一笔交易重广播太多次（90 天内最多 6 次），也能让这些交易最终过期。"
  a6link="https://bitcoincore.reviews/21061#l-178"

  q7="**<!--q7-->**在什么情况下我们会从重广播尝试跟踪器里移除某笔交易？"
  a7="当这笔交易被确认、被 [RBF][topic rbf] 替换，或与某个被打包进区块的交易发生冲突时。"
  a7link="https://bitcoincore.reviews/21061#l-199"

  q8="**<!--q8-->**重广播所用的最低费率是如何估算的？为什么不直接用上一个已挖出区块里的最低费率？"
  a8="重广播的费率下限每分钟估算一次：从内存池中组装一个区块，模拟交易被纳入下一个将要挖出的区块。这种做法优于直接使用上一个已挖出区块的最低费率，因为它是基于不断变化的环境对近期未来作出估算，而不是依据过去。"
  a8link="https://bitcoincore.reviews/21061#l-227"
%}

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [Rust-Lightning 0.0.14][Rust-Lightning 0.0.14] 是一个新版本，使 Rust-Lightning 更好地兼容来自 Electrum 风格服务器的数据，新增了更多配置选项，并改进了与闪电网络规范的兼容性，此外还包括其他一些错误修复和改进。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo] 和 [闪电网络规范（BOLTs）][bolts repo] 中值得注意的变更。*

- [Bitcoin Core #20867][Bitcoin Core #20867] 将多重签名[输出脚本描述符（descriptor）][topic descriptors]中可包含、并可用于 `addmultisigaddress` 和 `createmultisig` RPC 的密钥数量从 16 个增加到 20 个。提高后的上限只能用于 P2WSH 输出。P2SH 输出受限于 520 字节的脚本大小，最多只能容纳 15 个压缩公钥。

- [Bitcoin Core GUI #125][Bitcoin Core GUI #125] 允许用户在首次启动的介绍对话框中调整自动修剪（autoprune）的区块空间大小，不必再沿用默认值。同时还改进了对修剪式存储工作方式的说明，明确指出必须先下载并处理完整区块链，但之后会逐步丢弃旧数据，以保持较低的磁盘占用。

- [C-Lightning #4489][C-Lightning #4489] 添加了一个名为 `funder` 的插件，用于配置响应收到的通道开启请求时的[双向资助][topic dual funding]出资行为。用户可以设置出资策略（百分比匹配、当前可用资金百分比或固定额度）、一个低于该额度就不再进行双向资助的钱包保留金额、对单笔通道开启请求的最大出资额等。

  这个 PR 是实现 C-Lightning 节点间实验性双向资助支持的最后一步。由此产生的交互式交易构建协议和通道建立 v2 协议，仍在公开的 [BOLTs #851][BOLTs #851] PR 中标准化。

- [C-Lightning #4496][C-Lightning #4496] 让插件可以注册自己打算发布通知的主题。其他插件可以订阅这些主题以接收相应通知。
  C-Lightning 本身已有若干内置主题，但这个已合并的 PR 允许插件作者为自己想要使用的任何新主题类别创建和消费通知。

- [Rust Bitcoin #589][Rust Bitcoin #589] 启动了对 [taproot][topic taproot] 及 [schnorr 签名][topic schnorr signatures] 的支持工作。现有的 ECDSA 支持被移到一个新模块中，但仍以原有的名称对外导出，以保持 API 兼容性。新增的 `util::schnorr` 模块提供了对 [BIP340][] schnorr 密钥编码的支持。Issue [#588][rust bitcoin #588] 用于跟踪 taproot 兼容性的完整实现。

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
