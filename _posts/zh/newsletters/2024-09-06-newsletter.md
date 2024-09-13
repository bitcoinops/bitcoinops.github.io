---
title: 'Bitcoin Optech Newsletter #319'
permalink: /zh/newsletters/2024/09/06/
name: 2024-09-06-newsletter-zh
slug: 2024-09-06-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的新闻部分总结了一个让 Stratum v2 矿池矿工可以根据自己的份额所对应的区块模板中的手续费收到补贴的提议，还宣布了一项研究提议中的 `OP_CAT` 操作码的研究基金，并介绍了关于要不要用软分叉缓解默克尔树漏洞的讨论。此外是我们的常规栏目：软件的新版本和候选版本发行公告，还有热门的比特币基础设施软件的显著变更。

## 新闻

- **<!--stratum-v2-extension-for-fee-revenue-sharing-->****用于手续费收益分成的 Stratum v2 插件**：Filippo Merli 在 Delving Bitcoin 论坛中[发布][merli stratumfees]了 [Stratum v2][topic pooled mining] 矿池协议的一个插件，在 *池内份额（share）* 内包含了矿工自选的交易时，可以跟踪其中包含的手续费数量。这可以用来调整矿池支付给矿工的手续费，选出了更高手续费率交易的矿工就可以得到更多。

  Merli 链接了一篇他联合撰写的[论文][merli paper]，研究了基于矿工自选的交易而支付不同报酬所面临的挑战。这篇论文提出了一种方案，兼容于 *按最后 N 个份额付酬（PPLNS）* 矿池方案。他也链接了该方案的两种开发中的实现。

- **<!--opcat-research-fund-->****OP_CAT 研究基金**：Victor Kolobov 在 Bitcoin-Dev 邮件组中[宣布][kolobov cat]了 100 万美元的研究基金，用于研究给比特币加入 [`OP_CAT`][topic op_cat] 操作码的软分叉提议。“研究方向包括但不限于：在比特币上激活 `OP_CAT` 实现的安全影响、比特币上基于 `OP_CAT` 的计算和锁定脚本逻辑、利用比特币 `OP_CAT` 的应用和协议，以及与 `OP_CAT` 及其影响相关的广泛研究。”提交截止日期是 2025 年 1 月 1 日。

- **<!--mitigating-merkle-tree-vulnerabilities-->缓解默克尔树漏洞**：在 Delving Bitcoin 论坛关于[“共识清理” 软分叉提议][topic consensus cleanup]（详见[周报 #296][news296 cleanup]）的帖子中，Eric Voskuil [请求][voskuil spv]根据最近 Bitcoin-Dev 邮件组中的[讨论][voskuil spv dev]更新版本。尤其是，他说，“没有理由采用让 64 字节的交易统统无效的提议”，依据是他的论证：在保护全节点免受像 CVE-2012-2459 这样的[默克尔树漏洞][topic merkle tree vulnerabilities]时，禁止 64 字节的交易与其它无需共识变更就能执行的检查相比，没有性能上的提升（而且，实际上，这些检查已经在服役了）。共识清理提议的组织者 Antoine Poinsot 似乎[同意][poinsot cache]这个全节点视角：“我最初提到的，让 64 字节的交易无效有助于在更早阶段捕捉到区块故障的论述是不正确的。”

  但是，Poinsot 和其他人之前提议禁用 64 字节交易是为了保护验证默克尔证据的软件免受 CVE-2017-12842 漏洞。这一漏洞影响的是使用初版[比特币论文][Bitcoin paper]所述 *简易支付验证*（SPV）技术的轻钱包。它也会影响执行 SPV 的[侧链][topic sidechains]，并且可能影响一些需要软分叉激活的[限制条款][topic covenants]提议。

  自 CVE-2017-12842 公开以来，众所周知，让验证者额外检查区块的 coinbase 交易（在默克尔树上）的深度，SPV 就可以变得更安全。Voskuil 估计，对现在的典型区块而言，验证每个区块将需要额外 576 字节（平均而言） —— 稍微提高了带宽需求。Poinsot [总结][poinsot spv]了相关的论述，而且 Aothony Towns [延伸][towns depth]了关于执行额外深度验证的复杂性的论证。

  Voskuil 也链接了 Sergio Demian Lerner 之前对另一个软分叉共识变更的[建议][lerner commitment]，让区块头承诺自身的默克尔树的深度。这也将抵抗 CVE-2017-12842 漏洞，而且无需禁止 64 字节的交易，并让 SPV 证据的效率提升到最高。

  截至本刊撰写之时，讨论还在继续。

## 新版本和候选版本

*热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本，或帮助测试候选版本。*

- [Core Lightning 24.08][] 是这个热门的闪电节点实现的主要版本，包含了新特性和 bug 修复。

- [LDK 0.0.124][] 是这个开发闪电网络赋能应用的库的最新版本。

- [LND v0.18.3-beta.rc2][] 是这个热门的闪电节点实现的一个小的 bug 修复版本的候选发行版。

- [BDK 1.0.0-beta.2][] 是这个用于开发钱包和其它比特币赋能应用的库的候选版本。最初的 Rust 库 `bdk` 以及重命名为 `bkd_wallet`，而且更底层的模块已经抽取成为独立的库，包括 `bdk_chain`、`bdk_electrum`、`bdk_esplora` 和 `bdk_bitcoind_rpc`。`bdk_wallet` 库是 “可以提供稳定 1.0.0 API 的第一个版本”。

- [Bitcoin Core 28.0rc1][] 是这个主流全节点实现的下一个主要版本的候选发行版。配有一套[测试指南][bcc testing]。

## 重要的代码和文档变更

*本周出现重要变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 。*

*注：下文提到的 Bitcoin Core 的代码提交会应用在其主开发分支上，所以这些变更可能要等到六个月后、版本 28 发行时才会启用。*

- [Bitcoin Core #30454][] 和 [#30664][bitcoin core #30664] 相应添加了一种基于 CMake 的编译系统（详见[周报 #316][news316 cmake]），并移除了之前基于 autotools 的编译系统。亦见 后续 RP：[#30779][bitcoin core #30779]、[#30785][bitcoin core #30785]、[#30763][bitcoin core #30763]、[#30777][bitcoin core #30777]、[#30752][bitcoin core #30752]、[#30753][bitcoin core #30753]、[#30754][bitcoin core #30754]、[#30749][bitcoin core #30749]、[#30653][bitcoin core #30653]、[#30739][bitcoin core #30739]、[#30740][bitcoin core #30740]、[#30744][bitcoin core #30744]、[#30734][bitcoin core #30734]、[#30738][bitcoin core #30738]、[#30731][bitcoin core #30731]、[#30508][bitcoin core #30508]、[#30729][bitcoin core #30729] 和 [#30712][bitcoin core #30712] 。

- [Bitcoin Core #22838][] 实现了多派生路径的[描述符][topic descriptors]（[BIP389][]），让一个描述符字符串可以指定两种相关的派生路径，第一种由于接收支付，第二种用于内部支付（例如找零）。详见周报 [#211][news211 bip389] 和 [#258][news258 bip389]。

- [Eclair #2865][] 增加了通过尝试连接其最后一个已知 IP、推送手机通知来唤醒断连的移动端对等节点的功能。这在[异步支付][topic async payments]的流程中是非常有用的：本地节点可以扣住一笔支付（或者一条[洋葱消息][topic onion messages]），在对等节点回到线上时，再发送过去。详见周报 [#232][news232 async]。

- [LND #9009][] 引入了一种禁止对等节点发送无效通道宣告的机制，这样的无效通道包括：已经被花费掉的、没有注资交易的，以及带有无效注资输出的。遭到禁令的对等节点会基于不同关系，得到不同待遇：

  - 如果本地节点跟遭到禁令的对等节点没有共享的通道，那么本地节点就会断开连接。

  - 如果有共享的通道，则本地节点会在 48 小时内忽略对方的所有通道宣告。

- [LDK #3268][] 添加了 `ConfirmationTarget::MaximumFeeEstimate`，以在检查对手方费率时候的[粉尘][topic uneconomical outputs]计算使用一种更保守的[手续费估计][topic fee estimation]方法，从而避免因为突然的手续费飙升而不必要地强制关闭通道。这一 PR 也将 `ConfirmationTarget::MaximumFeeEstimate` 切分成了 `UrgentOnChainSweep` 和 `NonUrgentOnChainSweep`，以区分时间敏感的（例如 [HTLCs][topic htlc] 即将过期的）和不紧急的强制关闭操作。

- [HWI #742][]为 Trezor Safe 5 硬件签名设备添加了支持。

- [BIPs #1657][] 为[PSBT][topic psbt]添加了一种新的标准字段，以支持使用 [BIP353][] 中的 [DNSSEC][dnssec] 证据。外部设备（比如硬件签名器）可以先检查 PSBT 输出，以获得 [RFC 9102][rfc9102] 格式的证据，这将施加时间约束，保证只会收到有效的证据。详见周报 [#307][news307 bip353]。


{% include references.md %}
{% include linkers/issues.md v=2 issues="30454,30664,30779,30785,30763,30777,30752,30753,30754,30749,30653,30739,30740,30744,30734,30738,30731,30508,30729,30712,22838,2865,9009,3268,742,1657" %}
[Core Lightning 24.08]: https://github.com/ElementsProject/lightning/releases/tag/v24.08
[LND v0.18.3-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.3-beta.rc2
[BDK 1.0.0-beta.2]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.2
[bitcoin core 28.0rc1]: https://bitcoincore.org/bin/bitcoin-core-28.0/
[voskuil spv]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/28
[voskuil spv dev]: https://mailing-list.bitcoindevs.xyz/bitcoindev/72e83c31-408f-4c13-bff5-bf0789302e23n@googlegroups.com/
[poinsot cache]: https://mailing-list.bitcoindevs.xyz/bitcoindev/wg_er0zMhAF9ERoYXmxI6aB7rc97Cum6PQj4UOELapsHVBBVWktFeOZT7sHDlyrXwJ5o5s9iMb2LW2Od-qacywsh-86p5Q7dP3XjWASXcMw=@protonmail.com/
[bitcoin paper]: https://bitcoincore.org/bitcoin.pdf
[poinsot spv]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/41
[lerner commitment]: https://bitslog.com/2018/06/09/leaf-node-weakness-in-bitcoin-merkle-tree-design/
[towns depth]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/43
[merli stratumfees]: https://delvingbitcoin.org/t/pplns-with-job-declaration/1099
[merli paper]: https://github.com/demand-open-source/pplns-with-job-declaration/blob/bd7258db08e843a5d3732bec225644eda6923e48/pplns-with-job-declaration.pdf
[kolobov cat]: https://mailing-list.bitcoindevs.xyz/bitcoindev/04b61777-7f9a-4714-b3f2-422f99e54f87n@googlegroups.com/
[news296 cleanup]: /zh/newsletters/2024/04/03/#revisiting-consensus-cleanup
[news316 cmake]: /zh/newsletters/2024/08/16/#bitcoin-core-switch-to-cmake-build-system
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Candidate-Testing-Guide
[ldk 0.0.124]: https://github.com/lightningdevkit/rust-lightning/releases
[news211 bip389]: /zh/newsletters/2022/08/03/#multiple-derivation-path-descriptors
[news258 bip389]: /zh/newsletters/2023/07/05/#bips-1354
[news232 async]: /zh/newsletters/2023/01/04/#eclair-2464
[dnssec]: https://zh.wikipedia.org/wiki/%E5%9F%9F%E5%90%8D%E7%B3%BB%E7%BB%9F%E5%AE%89%E5%85%A8%E6%89%A9%E5%B1%95
[rfc9102]: https://datatracker.ietf.org/doc/html/rfc9102
[news307 bip353]: /zh/newsletters/2024/06/14/#bips-1551
