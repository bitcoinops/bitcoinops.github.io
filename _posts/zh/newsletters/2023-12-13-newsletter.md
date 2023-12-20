---
title: 'Bitcoin Optech Newsletter #281'
permalink: /zh/newsletters/2023/12/13/
name: 2023-12-13-newsletter-zh
slug: 2023-12-13-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报总结了关于流动性广告骚扰（griefing）问题的讨论，并包括了我们的常规栏目，描述服务和客户端软件的变化，总结了 Bitcoin Stack Exchange 的热门问题和答案、新的软件版本和候选版本公告以及检视流行的比特币基础架构软件的最新变化。

## 新闻

- **<!--discussion-about-griefing-liquidity-ads-->讨论对流动性广告的骚扰问题：** Bastien Teinturier 在 Lightning-Dev 邮件列表中[发布][teinturier liqad]了关于由[流动性广告][topic liquidity advertisements]给[双向注资通道][topic dual funding]上的时间锁带来的潜在问题。
之前在 [#279 回顾][recap279 liqad]中也提到过这个问题。例如，Alice 在广告中表示，只要支付一定的费用，她愿意向某通道投入 10,000 sats 的资金，为期 28 天。28 天的时间限制防止 Alice 在收到付款后直接关闭通道，将资金用于其他用途。

    继续上面的例子，Bob 打开通道，额外注入 100,000,000 sats（1 BTC）的资金。然后，他将几乎全部的资金都通过这个通道发送出去。现在，Alice 在通道中的余额不是她赚取手续费的那 10,000 sats 了——而是这个数额的近 10,000 倍。如果 Bob 是恶意的，他不会允许这些资金再次流动，直到 Alice 承诺的 28 天时间锁定到期。

    由 Teinturier 提出并由他和其他人讨论过的一种缓解方法是，只对流动性贡献（例如，只对 Alice 的 10,000 sats）实施时间锁定。这虽然可以解决问题，但会带来复杂性并降低效率。Teinturier 提出的一个替代方案是干脆放弃时间锁（或将其作为可选项），让流动性购买者承担提供者可能在收到流动性费用后不久就关闭通道的风险。如果通过流动性广告开通的通道通常能带来可观的转发费收入，那么提供者就会有保持通道畅通的动力。

## 服务和客户端软件的改变

*在这个月度栏目中，我们将列举比特币钱包和服务的有趣升级*。

- **使用 Stratum v2 的矿池启动：**
  [DEMAND][demand website] 是在 [Stratum v2 参考实现][news247 sri]基础上建立的矿池，最初允许单人挖矿，未来计划建立矿池挖矿。

- **比特币网络模拟工具 warnet 发布：**
  [warnet 软件][warnet github]可指定节点拓扑结构，在网络中运行[脚本化场景][warnet scenarios]，并[监控][warnet monitoring]和分析由此产生的行为。

- **Bitcoin Core 的 Payjoin 客户端发布：**
  [payjoin-cli][] 是一个 rust 项目，它为 Bitcoin Core 添加了在命令行中进行 [payjoin][topic payjoin] 发送和接收的功能。

- **<!--call-for-community-block-arrival-timestamps-->向社区征集区块到达时间戳：**
  “[比特币区块到达时间数据集][block arrival github]” 资源库的一位贡献者[呼吁][b10c tweet]节点操作员提交他们的区块到达时间戳，以供研究。此外还有一个类似的资源库用于收集[旁支区块数据][stale block github]。

- **Envoy 1.4 发布：**
  比特币钱包 Envoy 的 [1.4 版本][envoy v1.4.0]增加了[钱币控制][topic coin selection]和[钱包标签][topic wallet labels]（[BIP329][] 即将推出）等功能。

- **BBQr 编码方案发布：**
  该[方案][bbqr github]可有效地将较大的文件（如 [PSBT][topic psbt]）编码成动画 QR 系列，用于物理隔离钱包的配置。

- **Zeus v0.8.0 发布：**
  [v0.8.0][zeus v0.8.0] 版包含一个嵌入式 LND 节点、额外的[零配置通道][topic zero-conf channels]的支持和简单 taproot 通道的支持，以及其他改动。

## Bitcoin Stack Exchange 的精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 的贡献者寻找答案的首选之地 —— 也是他们有闲暇时会帮助好奇和困惑的用户的地方。在这个月度栏目中，我们会挑出自上次出刊以来新出现的高票问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aa
nswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [CPFP 费用调整的相关规则有哪些？]({{bse}}120853)
  Pieter Wuille 指出，[RBF][topic rbf] 费用调整技术有一系列相关的政策规则，而 [CPFP][topic cpfp] 费用调整技术则没有额外的政策规则。

- [RBF 替换掉的交易总数是如何计算出来的？]({{bse}}120823)
  Murch 和 Pieter Wuille 结合 [BIP125][] 第 5 条规则：“将被替换的原始交易及其将被驱逐出交易池的后代交易总数不得超过 100 个”，举例说明了 RBF 替换。读者可能还会对“[添加 BIP-125 第 5 条规则的测试案例与默认交易池][review club 25228] PR 审核俱乐部会议”感兴趣。

- [存在哪些类型的 RBF，Bitcoin Core 默认支持并使用哪一种？]({{bse}}120749)
  Murch 提供了一些 Bitcoin Core 的交易替换历史，也提供了在一个[相关问题]({{bse}}120773)中关于 RBF 替换规则的总结，并链接到 Bitcoin Core 的[交易池替换][bitcoin core mempool replacements]文档和一位开发者对 [RBF 的改进意见][glozow rbf improvements]。

- [<!--what-is-the-block-1-983-702-problem-->1,983,702 区块的问题是什么？]({{bse}}120834)
  Antoine Poinsot 概述了导致 [BIP30][] 限制重复 txids 和 [BIP34][] 强制在 coinbase 字段中包含当前区块高度的问题。然后他指出，有许多区块的随机 coinbase 字段内容恰好与后一个区块的强制高度前缀相匹配。1,983,702 区块是第一个实际上有可能重复前一个区块的 coinbase 交易的区块。在一个[相关问题]({{bse}}120836)中，Murch 和 Antoine Poinsot 对这种可能性进行了更详细的评估。另请参阅[第 182 期周报][news182 block1983702]。

- [<!--what-are-hash-functions-used-for-in-bitcoin-->比特币中的哈希函数有哪些用途？]({{bse}}120418)
  Pieter Wuille 列举了三十多种不同的情况，涉及共识规则、点对点协议、钱包和节点实现细节，其中使用了不少于 10 种不同的哈希函数。

## 新版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [LND 0.17.3-beta][] 是一个包含多个错误修复的版本，也包括降低与 Bitcoin Core 后端一起使用时的内存开销。

## 重要的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo] 和 [Bitcoin Inquisition][bitcoin inquisition repo]*。

- [LDK #2685][] 增加了从 Electrum 型服务器获取区块链数据的功能。

- [Libsecp256k1 #1446][] 删除了项目中的一些 x86_64 汇编代码，转而使用一直用于其他平台的现有 C 语言代码。汇编代码在几年前经过人工优化以提高性能，但与此同时，编译器也得到了改进，现在最新版本的 GCC 和 LLVM (clang) 都能生成性能更高的代码。

- [BTCPay Server #5389][] 添加了对 [BIP129][] 安全多重签名钱包设置的支持（参见[第 136 期周报][news136 bip129]）。这允许 BTCPay 服务器与多个软件钱包和硬件签名设备进行交互，作为简单协调的多签设置程序的一部分。

- [BTCPay Server #5490][] 默认开始使用来自 mempool.space 的[费用估算][ms fee api]，并将来自本地 Bitcoin Core 节点的费用估算作为后备选择。在 PR 上发表评论的开发者指出，他们认为 Bitcoin Core 的手续费估算无法快速响应本地 mempool 的变化。之前关于提高费用估算准确性所面临挑战的相关讨论，请参阅 [Bitcoin Core #27995][]。

## 节日快乐！

这是 Bitcoin Optech 今年的最后一期常规周报。12 月 20 日星期三，我们将发布第六期年度回顾周报。1 月 3 日（星期三）将恢复常规发布。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2685,5389,5490,1446,27995" %}
[LND 0.17.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.3-beta
[teinturier liqad]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-December/004227.html
[ms fee api]: https://mempool.space/docs/api/rest#get-recommended-fees
[mempool.space]: https://mempool.space/
[news136 bip129]: /en/newsletters/2021/02/17/#securely-setting-up-multisig-wallets
[recap279 liqad]: /en/podcast/2023/11/30/#update-to-the-liquidity-ads-specification-transcript
[news182 block1983702]: /en/newsletters/2022/01/12/#bitcoin-core-23882
[demand website]: https://dmnd.work/
[news247 sri]: /zh/newsletters/2023/04/19/#stratum-v2
[warnet github]: https://github.com/bitcoin-dev-project/warnet
[warnet scenarios]: https://github.com/bitcoin-dev-project/warnet/blob/main/docs/scenarios.md
[warnet monitoring]: https://github.com/bitcoin-dev-project/warnet/blob/main/docs/monitoring.md
[payjoin-cli]: https://github.com/payjoin/rust-payjoin/tree/master/payjoin-cli
[block arrival github]: https://github.com/bitcoin-data/block-arrival-times
[b10c tweet]: https://twitter.com/0xb10c/status/1732826609260872161
[stale block github]: https://github.com/bitcoin-data/stale-blocks
[envoy v1.4.0]: https://github.com/Foundation-Devices/envoy/releases/tag/v1.4.0
[bbqr github]: https://github.com/coinkite/BBQr
[zeus v0.8.0]: https://github.com/ZeusLN/zeus/releases/tag/v0.8.0
[review club 25228]: https://bitcoincore.reviews/25228
[bitcoin core mempool replacements]: https://github.com/bitcoin/bitcoin/blob/master/doc/policy/mempool-replacements.md
[glozow rbf improvements]: https://gist.github.com/glozow/25d9662c52453bd08b4b4b1d3783b9ff
