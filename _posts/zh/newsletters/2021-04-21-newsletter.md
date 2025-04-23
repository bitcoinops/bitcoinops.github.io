---
title: 'Bitcoin Optech Newsletter #145'
permalink: /zh/newsletters/2021/04/21/
name: 2021-04-21-newsletter-zh
slug: 2021-04-21-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了激活 taproot 的进展，概述了对 LN offers 的更新，以部分解决卡住的支付问题，传达了对 LND 中锚定输出的反馈请求，并宣布了 Sapio 智能合约开发工具包的公开发布。此外，还包括我们的定期栏目，概述了流行客户端和服务的更改、新版本发布与候选发布，以及流行的比特币基础设施软件的值得注意的更改。

## 新闻

- **<!--taproot-activation-release-candidate-->****Taproot 激活候选发布：** 自从我们在[上周的 Newsletter][news144 activation] 中关于 [taproot][topic taproot] 激活的更新以来，Bitcoin Core 项目已经合并了一个实现[快速测试][news139 speedy trial]激活机制的[拉取请求][Bitcoin Core #21377]和一个包含激活参数的[第二个 PR][Bitcoin Core #21686]。这些 PR 及其他几个 PR 目前是 Bitcoin Core 0.21.1 的第一个 Release Candidate (RC) 的一部分。预计在本 Newsletter 发布后，测试和其他质量保证任务将至少持续几天。有关更多详细信息，请参阅下面的 RC 和合并摘要部分。

- **<!--using-ln-offers-to-partly-address-stuck-payments-->****使用 LN offers 部分解决卡住的支付问题：** 在某些情况下，尝试支付 LN 发票可能导致支付长时间卡住。在故障解决之前，请求第二个发票以进行第二次支付尝试可能会导致双重支付。

  本周，Rusty Russell [在][russell invoice cancel] Lightning-Dev 邮件列表上发布了对他提议的[报价][topic offers]规范的更改，允许支付接收方承诺一个新的发票，以取代之前的发票。如果支出者支付了第二个发票，仍然存在双重支付的风险，但接收方在 offer 上的签名结合了 LN 内在的支付证明，将允许支出者在两次支付都被接受的情况下证明接收方存在欺骗行为。当向具有良好声誉的接收方（如流行的企业）支付时，这可能足以消除卡住的支付作为一个主要问题。

  对 offers 规范的更新还允许接收方表明他们已收到支付，问题出在下游节点。在这种情况下，支出者和接收方的资金都是完全安全的，唯一的后果是支出者需要等待一段时间才能重新使用他们的特定支付槽位（[HTLC][topic htlc] 槽位）。这种交互式沟通的能力是 offers 相较于普通发票的明显优势。

- **<!--using-anchor-outputs-by-default-in-lnd-->****LND 默认使用锚定输出：** Olaoluwa Osuntokun [在][osuntokun anchor] LND 工程邮件列表上发布了他希望下一个主要版本的 LND 默认使用[锚定输出][topic anchor outputs]的愿望。锚定输出将允许关闭通道的未确认 LN 承诺交易通过 [CPFP][topic cpfp] 进行手续费提升。不幸的是，LN 模型中的 CPFP 手续费提升存在一些挑战：

  - **<!--not-always-optional-->***并非总是可选的：* 对于常规的链上交易，许多用户可以选择等待更长时间以确认他们的交易，作为手续费提升的替代方案。对于 LN，有时等待不是一个选项——需要在几个小时内提交手续费提升，否则资金可能会丢失。

  - **<!--timelocked-outputs-->***时间锁定输出：* 对于大多数常规链上支付，想要进行 CPFP 提升的用户可以使用他们希望提升的交易中的输出所存储的资金来支付手续费提升。在 LN 的情况下，这些资金直到通道关闭在链上完全结算后才可用。这意味着用户需要使用一个单独的 UTXO 来支付手续费。

  为了解决上述两个问题，LND 要求锚定输出的用户在任何时候通道打开时，其钱包中至少保留一个合理价值的已确认 UTXO。这确保了在必要时他们可以进行 CPFP 手续费提升，但也带来了一些后果，例如在仍有至少一个通道打开的情况下，无法花费你最后的链上资金（甚至无法开设新通道）。

  Osuntokun 的请求是，基于 LND 构建的钱包或服务应让开发团队知道上述任何问题，或与锚定输出相关的任何其他问题，是否会导致严重问题。尽管这个问题特定于 LND，但答案可能会影响所有 LN 节点。

- **<!--sapio-public-launch-->****Sapio 公开发布：** Jeremy Rubin [在][rubin sapio] Bitcoin-Dev 邮件列表上发布了公告，宣布他已经发布了 Sapio 智能合约开发工具包，这是一个基于 Rust 的库和相关工具，可以用于创建可通过 Bitcoin Script 表达的智能合约。该语言最初设计用于利用 Rubin 提议的 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] 操作码（`OP_CTV`），但它可以使用可信的签名预言机模拟该操作码以及比特币的其他潜在功能，如 taproot。除了 Sapio 库，发布还包含了详尽的文档和一个实验性的前端。

## 服务和客户端软件的更改

*在这个每月栏目中，我们重点介绍比特币钱包和服务的有趣更新。*

- **<!--specter-v1-3-0-released-->****Specter v1.3.0 发布：**
  [Specter v1.3.0][] 包含了额外的 RBF 支持、从应用程序内部设置 Bitcoin Core、HWI 2 支持，以及使用 [mempool.space][news132 mempool.space] 作为[区块浏览器][topic block explorers]和手续费估算的选项。

- **<!--specter-diy-v1-5-0-->****Specter-DIY v1.5.0：**
  硬件钱包固件 Specter-DIY [发布][specter-diy github] v1.5.0，增加了自定义 SIGHASH 标志支持和完整的[描述符][topic descriptors]支持，包括 [miniscript][topic miniscript]。

- **<!--bluewallet-v6-0-7-adds-message-signing-->****BlueWallet v6.0.7 添加消息签名功能：**
  [BlueWallet v6.0.7][bluewallet v6.0.7] 允许用户使用比特币地址签名和验证消息，以及其他功能和修复。

- **<!--azteco-announces-lightning-support-->****Azteco 宣布支持闪电网络：**
  比特币代金券公司 Azteco [宣布][azteco lightning blog]支持通过闪电网络兑换购买的比特币。

## 发布与候选发布

*流行的比特币基础设施项目的新版本发布与候选发布。请考虑升级到新版本或协助测试候选发布。*

- [Bitcoin Core 0.21.1rc1][Bitcoin Core 0.21.1] 是一个 Bitcoin Core 版本的候选发布，如果激活，将强制执行提议的 [taproot][topic taproot] 软分叉规则，该软分叉使用 [schnorr 签名][topic schnorr signatures]并允许使用 [tapscript][topic tapscript]。这些分别由 BIPs [341][BIP341]、[340][BIP340] 和 [342][BIP342] 规定。此外，还包括使用 [BIP350][] 规定的 [bech32m][topic bech32] 地址支付的能力，尽管在主网上向这些地址支付的比特币在使用这些地址的软分叉（如 taproot）激活之前不会是安全的。该版本还包括错误修复和小幅改进。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]中发生的值得注意的更改。*

- [Bitcoin Core #21377][] 添加了 taproot 软分叉的激活机制，[#21686][Bitcoin Core #21686] 添加了激活参数。从 4 月 24 日之后的第一次难度调整开始，矿工将能够在位 2 上信号 Taproot 激活的准备。如果在信号窗口内的一个难度周期的 2016 个区块中有 1815 个（90%）信号准备，则软分叉激活将被锁定。信号窗口在 8 月 11 日之后的第一次难度调整时结束。如果被锁定，taproot 将在区块高度 709632 时激活，预计在 11 月 12 日左右达到该高度。

- [Bitcoin Core #21602][] 为 `listbanned` RPC 更新了两个额外的字段：`ban_duration` 和 `time_remaining`。

- [C-Lightning #4444][] 将 [lnprototest][]（LN 协议测试）添加到 C-Lightning 持续集成（CI）测试的默认目标中，并使开发者更容易从 C-Lightning 的常规构建系统中运行测试。LN 协议测试使得实现能够轻松测试它们是否遵循 [LN 协议规范][LN protocol specification]。

- [LND #4588][] 在找零金额过小时跳过创建找零输出，因为此时找零金额的价值低于花费它所需的成本。

- [LND #5193][] 默认禁用了使用 Neutrino 客户端（实现了[致密区块过滤器][topic compact block filters]协议）的 LND 实例的通道验证。此选项假设从对等方接收到的通道广告是正确的，节省了客户端下载验证这些广告所需的旧区块的时间。这的缺点是使用虚假广告通道进行的支付尝试将失败，浪费时间但不会导致资金损失——对于任何已经选择使用轻量级客户端的人来说，这是一个合理的权衡。这种新的默认行为可以通过使用新的配置选项 `--neutrino.validatechannels=true` 来禁用。

- [LND #5154][] 为使用 LND 与修剪的全节点添加了基本支持，允许 LND 从其他比特币节点外部请求本地节点已删除的区块。然后，LND 可以从区块中提取所需的信息，而无需经过修剪的节点。因为用户自己的全节点之前已经验证了该区块，这不会改变安全模型。

- [LND #5187][] 添加了新的 `channel-commit-interval` 和 `channel-commit-batch-size` 参数，可用于配置 LND 在发送通道状态更新之前的等待时间以及它在一次更新中发送的最大更改数量。这些值越高，繁忙的 LND 节点将越高效，尽管这种效率是以稍高的延迟为代价的。

- [Rust-Lightning #858][] 添加了与 Electrum 风格区块链数据源互操作的内部支持。

- [Rust-Lightning #856][] 更新了它处理资金交易的方式。以前，钱包被要求创建开启新通道的资金交易，并仅将该交易的 txid 提供给 Rust Lightning。现在 Rust Lightning 接受完整的资金交易。类似于最近对 C-Lightning 的更改（参见 [Newsletter #141][news141 cl funding]），这允许 LN 软件在广播之前检查资金交易并确保其正确。

- [HWI #498][] 添加了使用 BitBox02 硬件钱包签署任意比特币风格消息的支持。

- [BTCPay Server #2425][] 添加了支持即使对于未关联 BTCPay 发票的地址，也能接收 [payjoin][topic payjoin] 支付到钱包。

## 脚注

[^height-decreasing]:
    如果区块链上的每个区块都有相同的单独工作量证明（PoW），则具有最多累积 PoW 的有效链也将是最长的链——其最新区块具有迄今为止见过的最高高度。然而，每 2,016 个区块，比特币协议会调整新块需要包含的 PoW 数量，增加或减少需要证明的工作量，试图保持块之间的平均时间约为 10 分钟。这意味着一个拥有较少区块的链可能比一个拥有更多区块的链具有更多的 PoW。

    比特币用户使用拥有最多 PoW 的链——而不是最多区块的链——来确定他们是否已收到资金。当用户看到该链的一个有效变体，其中一些末尾区块被不同的区块替换时，如果该重组链包含比他们当前链更多的 PoW，他们会使用该 *重组* 链。因为重组链可能包含更少的区块，尽管具有更多的累积 PoW，链的高度可能会下降。

    尽管这是一个理论上的担忧，但通常不是一个实际问题。高度下降仅在跨越至少一个 *重定向* 边界（在一组 2,016 个区块和另一组 2,016 个区块之间）的大量区块重组中可能发生。它还需要涉及大量区块的重组或 PoW 要求量的最近重大变化（表示算力的最近重大增加或减少，或矿工的可观察操纵）。在 [BIP8][] 的上下文中，我们认为高度下降的重组在激活期间不会对用户产生比更典型的重组更多的影响。

{% include references.md %}
{% include linkers/issues.md issues="21377,21686,21602,4444,4588,5193,5154,5187,858,856,498,2425" %}
[bitcoin core 0.21.1]: https://bitcoincore.org/bin/bitcoin-core-0.21.1/
[news139 speedy trial]: /zh/newsletters/2021/03/10/#a-short-duration-attempt-at-miner-activation
[russell invoice cancel]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-April/002992.html
[osuntokun anchor]: https://groups.google.com/a/lightning.engineering/g/lnd/c/OuC56qq6IaY
[rubin sapio]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-April/018759.html
[lnprototest]: https://github.com/rustyrussell/lnprototest
[ln protocol specification]: https://github.com/lightningnetwork/lightning-rfc/
[news141 cl funding]: /zh/newsletters/2021/03/24/#c-lightning-4428
[news144 activation]: /zh/newsletters/2021/04/14/#taproot-activation-discussion
[specter v1.3.0]: https://github.com/cryptoadvance/specter-desktop/releases/tag/v1.3.0
[news132 mempool.space]: /zh/newsletters/2021/01/20/#mempool-v2-0-0-released
[specter-diy github]: https://github.com/cryptoadvance/specter-diy/releases
[bluewallet v6.0.7]: https://github.com/BlueWallet/BlueWallet/releases/tag/v6.0.7
[azteco lightning blog]: https://medium.com/@Azteco_/at-azteco-weve-been-experimenting-with-lightning-for-over-a-year-refining-our-thinking-and-user-b9d112cff13c
