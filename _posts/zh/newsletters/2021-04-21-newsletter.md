---
title: 'Bitcoin Optech Newsletter #145'
permalink: /zh/newsletters/2021/04/21/
name: 2021-04-21-newsletter-zh
slug: 2021-04-21-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 介绍激活 taproot 的进展，概述 LN offers 的一项更新如何部分缓解卡住的支付，转达一项关于 LND 中锚定输出的意见征集，并宣布 Sapio 智能合约开发工具包公开发布。此外还包括我们的固定栏目：热门客户端与服务变更摘要、新版本与候选发布，以及热门比特币基础设施软件值得注意的代码与文档变更。

## 新闻

- **<!--taproot-activation-release-candidate-->****Taproot 激活候选发布：** 自我们[上期 Newsletter][news144 activation] 介绍 [taproot][topic taproot] 激活进展以来，Bitcoin Core 项目已合并了一个实现 [Speedy Trial][news139 speedy trial] 激活机制的[拉取请求][Bitcoin Core #21377]，以及一个包含激活参数的[第二个 PR][Bitcoin Core #21686]。这些 PR 连同另外几个 PR 目前都属于 Bitcoin Core 0.21.1 的第一个候选发布（RC）。预计在本 Newsletter 发布后，测试和其他质量保证工作至少还会持续几天。详见下文关于候选发布和合并情况的段落。

- **<!--using-ln-offers-to-partly-address-stuck-payments-->****使用 LN offers 部分缓解卡住的支付：** 在某些情况下，尝试支付一笔 LN 发票可能导致支付长时间卡住。在故障解决之前，如果再请求一张新发票进行第二次支付尝试，就可能导致付两次款。

  本周，Rusty Russell [在][russell invoice cancel] Lightning-Dev 邮件列表上发布了对他的[offers][topic offers]提案规范的一项更改，允许支付的接收方承诺一张取代原发票的新发票。如果付款方支付了第二张发票，仍然存在付两次款的风险；但如果两笔支付都被接受，接收方在 offer 上的签名再加上 LN 本身提供的支付证明，可以让付款方证明接收方存在欺骗行为。当收款方是声誉良好的对象（如知名商户）时，这可能足以让卡住的支付不再是一个主要问题。

  对 offers 规范的更新还允许接收方表明自己已收到支付，问题出在下游节点。在这种情况下，付款方和接收方的资金都是完全安全的，唯一的后果是付款方需要等一段时间才能重新使用自己的某个支付槽位（[HTLC][topic htlc] 槽位）。这种交互式沟通的能力是 offers 相对于普通发票的明显优势。

- **<!--using-anchor-outputs-by-default-in-lnd-->****LND 默认使用锚定输出：** Olaoluwa Osuntokun [在][osuntokun anchor] LND 工程邮件列表上表示，他希望 LND 的下一个大版本默认使用[锚定输出][topic anchor outputs]。锚定输出可以让关闭通道的未确认 LN 承诺交易通过[子为父付（CPFP）][topic cpfp]追加手续费。遗憾的是，在 LN 模型下用 CPFP 追加手续费存在一些挑战：

  - **<!--not-always-optional-->***并非总是可选的：* 对于常规的链上交易，许多用户可以选择多等一段时间让交易确认，以此替代手续费追加。对 LN 而言，有时等待并不是选项——必须在数小时内提交手续费追加，否则资金可能损失。

  - **<!--timelocked-outputs-->***时间锁定输出：* 对大多数常规链上支付来说，想做 CPFP 追加的用户可以用自己想追加的那笔交易中自己那个输出里的资金来支付追加的手续费。而在 LN 中，这笔资金要等通道关闭在链上完全结算之后才可用。这意味着用户得用另一个 UTXO 来付手续费。

  为了解决上述两个问题，LND 要求使用锚定输出的用户只要还有通道处于打开状态，就要在钱包里至少保留一个价值合理的已确认 UTXO。这样能确保用户在需要时可以 CPFP 追加手续费，但也带来一些后果，例如只要还有至少一个通道开着，你就无法花掉最后的链上资金（哪怕是为了开一个新通道）。

  Osuntokun 的请求是，基于 LND 构建的钱包或服务应让开发团队知道上述任何问题，或与锚定输出相关的任何其他问题，是否会导致严重问题。尽管这个问题特定于 LND，但答案可能会影响所有 LN 节点。

- **<!--sapio-public-launch-->****Sapio 公开发布：** Jeremy Rubin [在][rubin sapio] Bitcoin-Dev 邮件列表上发帖宣布，他已公开 Sapio 智能合约开发工具包。这是一个基于 Rust 的库及相关工具，可用来创建能用 Bitcoin Script 表达的智能合约。该语言最初是为了利用 Rubin 提议的 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] 操作码（`OP_CTV`）而设计的，但它可以借助一个可信的签名预言机来模拟该操作码，以及 taproot 等比特币其他潜在功能的存在。除 Sapio 库之外，此次发布还包含详尽的文档和一个实验性前端。

## 服务和客户端软件的变更

*在本月栏目中，我们重点介绍 Bitcoin 钱包与服务的一些有趣更新。*

- **<!--specter-v1-3-0-released-->****Specter v1.3.0 发布：**
  [Specter v1.3.0][] 包含了额外的 RBF 支持、从应用程序内部设置 Bitcoin Core、HWI 2 支持，以及使用 [mempool.space][news132 mempool.space] 作为[区块浏览器][topic block explorers]和手续费估算的选项。

- **<!--specter-diy-v1-5-0-->****Specter-DIY v1.5.0：**
  硬件钱包固件 Specter-DIY [发布][specter-diy github] v1.5.0，增加了对自定义 SIGHASH 标志的支持，并完整支持[输出脚本描述符（descriptor）][topic descriptors]，包括 [miniscript][topic miniscript]。

- **<!--bluewallet-v6-0-7-adds-message-signing-->****BlueWallet v6.0.7 添加消息签名功能：**
  [BlueWallet v6.0.7][bluewallet v6.0.7] 允许用户使用比特币地址签名和验证消息，此外还包含其他功能与修复。

- **<!--azteco-announces-lightning-support-->****Azteco 宣布支持闪电网络：**
  比特币代金券公司 Azteco [宣布][azteco lightning blog]支持通过闪电网络兑换购买的比特币。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [Bitcoin Core 0.21.1rc1][Bitcoin Core 0.21.1] 是一个 Bitcoin Core 版本的候选发布，如果激活，将强制执行提议的 [taproot][topic taproot] 软分叉规则，该软分叉使用 [schnorr 签名][topic schnorr signatures]并允许使用 [tapscript][topic tapscript]。这些分别由 BIPs [341][BIP341]、[340][BIP340] 和 [342][BIP342] 规定。此外，还包括向 [BIP350][] 规定的 [bech32m][topic bech32] 地址付款的能力，尽管在主网上付给这类地址的比特币，在使用这类地址的软分叉（如 taproot）激活之前并不安全。该版本还包括错误修复和小幅改进。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]中值得注意的变更。*

- [Bitcoin Core #21377][] 添加了 taproot 软分叉的激活机制，[#21686][Bitcoin Core #21686] 添加了激活参数。从 4 月 24 日之后的第一次难度调整开始，矿工将可以在第 2 位上发出准备激活 Taproot 的信号。如果信号窗口内某个难度周期 2016 个区块中有 1815 个（90%）发出准备信号，软分叉就锁定。信号窗口在 8 月 11 日之后的第一次难度调整时结束。如果成功锁定，taproot 将在区块高度 709632 激活，预计在 11 月 12 日左右达到该高度。

- [Bitcoin Core #21602][] 为 `listbanned` RPC 增加了两个字段：`ban_duration` 和 `time_remaining`。

- [C-Lightning #4444][] 将 [lnprototest][]（LN 协议测试）加入 C-Lightning 持续集成（CI）测试的默认目标，并让开发者更容易通过 C-Lightning 常规的构建系统运行这些测试。LN 协议测试让各实现可以方便地检验自己是否遵循 [LN 协议规范][LN protocol specification]。

- [LND #4588][] 在找零金额小到其价值还不及花掉它所需成本时，跳过创建找零输出。

- [LND #5193][] 对使用 Neutrino 客户端（该客户端实现了[紧凑区块过滤器][topic compact block filters]协议）的 LND 实例默认关闭了通道验证。该选项假定从对等节点收到的通道广告是正确的，从而省去客户端为验证这些广告而下载旧区块的麻烦。其缺点是，通过虚假广告的通道发起的支付会失败，既浪费时间又不会造成资金损失——对已经选择使用轻量级客户端的人来说，这是个合理的权衡。这一新的默认行为可以用新配置选项 `--neutrino.validatechannels=true` 关闭。

- [LND #5154][] 添加了让 LND 配合已修剪（pruned）全节点使用的基本支持，允许 LND 向其他比特币节点请求已被本地节点删除的区块。这样 LND 就能从区块中提取所需信息，而不必再经由这个修剪过的节点。由于用户自己的全节点此前已经验证过该区块，这不会改变安全模型。

- [LND #5187][] 增加了新的 `channel-commit-interval` 和 `channel-commit-batch-size` 参数，用于配置 LND 在发送通道状态更新前等待多久，以及一次更新中最多发送多少项变更。这两个值越大，繁忙的 LND 节点效率越高，代价则是延迟略有上升。

- [Rust-Lightning #858][] 增加了与 Electrum 风格区块链数据源互操作的内部支持。

- [Rust-Lightning #856][] 更改了处理注资交易的方式。以前，Rust Lightning 要求钱包创建开启新通道的注资交易，并只把该交易的 txid 交给 Rust Lightning。现在 Rust Lightning 接受完整的注资交易。与最近对 C-Lightning 的更改类似（参见 [Newsletter #141][news141 cl funding]），这让 LN 软件能在广播之前检查注资交易，确保其正确。

- [HWI #498][] 增加了使用 BitBox02 硬件钱包签署任意比特币风格消息的支持。

- [BTCPay Server #2425][] 增加了接收 [payjoin][topic payjoin] 支付的支持，即使地址与 BTCPay 发票无关也能收款。

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
