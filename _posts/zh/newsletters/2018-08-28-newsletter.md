---
title: 'Bitcoin Optech Newsletter #10'
permalink: /zh/newsletters/2018/08/28/
name: 2018-08-28-newsletter-zh
slug: 2018-08-28-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的 Newsletter 包括有关 Bitcoin Core 首次发布候选版本的信息、关于 BIP151 P2P 协议加密和潜在的未来软分叉的消息、来自 Bitcoin Stack Exchange 的热门问题及其答案，以及在流行的 Bitcoin 基础设施项目中一些值得注意的合并。

## 行动项

- **<!--allocate-time-to-test-bitcoin-core-0-17rc2-->****安排时间测试 Bitcoin Core 0.17 RC2：** Bitcoin Core 已经上传了 0.17 候选版本（RC）2 的[二进制文件][bcc 0.17]。我们非常欢迎你参与测试，这有助于保证最终版本的质量。

## 新闻

- **<!--pr-opened-for-initial-bip151-support-->****已提交初始 BIP151 支持的 PR：** Jonas Schnelli 向 Bitcoin Core 提交了一个 PR，为点对点网络协议提供了 [BIP151][] 加密的[初始实现][Bitcoin Core #14032]。他还维护了一份更新后的 BIP151 规范[草案][bip151 update]，其中包含他在开发实现过程中所做的改动。如果该 PR 被接受，全节点和轻量级客户端就能在 ISP 无法窃听连接的情况下交换区块、交易和控制消息，从而让别人更难判断某笔交易源自哪个程序（尤其是再结合 Bitcoin Core 现有的交易来源保护，或[蒲公英协议][Dandelion protocol]这类未来提案）。

    Schnelli 还在与其他开发者合作实现并测试 [NewHope 密钥交换协议][newhope]。该协议被认为能抵御量子计算机攻击，这样一来，即使有人在今天录下两个对等节点之间的通信，将来拥有快速量子计算机也无法解密这些数据。

- **<!--requests-for-soft-fork-solutions-to-the-time-warp-attack-->****征集针对时间扭曲攻击的软分叉方案：** 比特币区块中包含矿工声称的区块创建时间。这些时间戳用于调整挖矿难度，使区块平均每 10 分钟产生一个。然而，时间扭曲攻击让掌握网络大部分哈希率的矿工可以在很长一段时间里持续谎报区块创建时间，从而在区块产出频率高于每 10 分钟一个的情况下仍然降低难度。

    Gregory Maxwell 在 Bitcoin 协议开发邮件列表上[征集][timewarp maxwell]针对该攻击的软分叉方案，希望在自己提出方案之前先听听其他人的想法。到目前为止，Johnson Lau 已经[提出][timewarp lau]了一种技术。

    注意：任何人只要在监控区块链上的这类攻击，都能在出现重大损害之前至少提前一个月发现。出于这一原因，同时也因为已有多种已知的应对方法（各有不同权衡），修复时间扭曲攻击从未被视为紧急事项。不过，如果攻击风险可以靠一个无争议的软分叉完全或部分缓解，那自然是好事。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们有点空闲时帮忙回答他人问题的地方。在本月栏目中，我们精选自上次更新以来得票最高的一些问题和回答。*

- **<!--can-you-pay-0-bitcoins-->**[你可以支付 0 个比特币吗？][bse 78355] Andrew Chow 解释说，你不仅可以向一个地址或其他脚本支付零值金额，还可以花费零值输出——但前提是你找到一个不使用 Bitcoin Core 默认设置的矿工。

- **<!--can-you-create-an-spv-proof-of-the-absence-of-a-transaction-->**[你能创建一个不存在交易的 SPV 证明吗？][bse 77764] 简化支付验证（SPV, Simplified Payment Verification）使用默克尔树（Merkle tree）来证明某笔交易存在于某个区块中，而该区块本身属于最佳区块链——即工作量证明最多的区块链。但你能做反向操作吗？你能证明某笔交易不在某个特定的区块中，或者不在最佳区块链的任何区块中吗？

    Gregory Maxwell 解释说这也有可能，同样要用到默克尔树，但很可能需要计算开销很大（带宽占用却很少）的零知识证明（ZKPs, Zero-Knowledge Proofs）。

- **<!--can-you-convert-a-p2pkh-address-to-p2sh-or-segwit-->**[你能将 P2PKH 地址转换为 P2SH 或 segwit 吗？][bse 72775] **不要这样做。**
  Pieter Wuille 解释了为什么这是一个非常糟糕的主意，并且很可能导致资金丢失。注意：这是一个较早的回答，本月因一些用户试图将其他人的地址转换为 segwit 并因此丢失资金而受到更多关注。

## 值得注意的提交

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo] 和 [C-lightning][core lightning repo] 中值得注意的提交。提醒：Bitcoin Core 的新合并都进入主开发分支，不太可能成为即将发布的 0.17 版本的一部分——你大概要等到约六个月后的 0.18 版本。*

{% comment %}<!-- I didn't notice anything interesting in LND this week -harding -->{% endcomment %}

- [Bitcoin Core #12254][] 添加了让 Bitcoin Core 生成 [BIP158][] 紧凑区块过滤器所需的函数。这段代码目前尚未被 Bitcoin Core 使用，但预计未来的工作会利用这些函数提供两项功能：

    1. [BIP157][] 支持：通过点对点（P2P）网络协议向轻客户端发送过滤器。这能让 P2P 轻钱包在查找包含影响自身钱包的交易的区块时，比目前使用 BIP37 布隆过滤器的方式私密得多。

    2. 让 Bitcoin Core 内置钱包的重扫更快。偶尔，Bitcoin Core 用户需要重扫区块链，检查是否有历史交易影响过自己的钱包——例如导入新的私钥、公钥或地址时。即使在现代桌面设备上，这目前也要花一个多小时，但拥有本地 BIP157 过滤器的用户能以快得多的速度完成重扫，并且仍享有[信息论意义上的完美隐私][information theoretic perfect privacy]（轻客户端则不具备这一点）。

- [Bitcoin Core #12676][] 在 `getrawmempool`、`getmempoolentry`、`getmempoolancestors` 和 `getmempooldescendants` RPC 的结果中新增了一个字段，用来显示某笔交易是否选择发出信号，表明其付款方希望它被另一笔花费其中任一相同输入、手续费更高的交易替代，如 [BIP125][] 所述。

- [C-Lightning #1874][] 为 0.6.1 版打上了首个发布候选版本的标签。

- [C-Lightning #1870][] 减少了把 1,000 个重量单位称作“sipa”的地方，并开始改用更被广泛接受的术语“kiloweights”（kw）。

  该 PR 还改进了多处费用处理逻辑：既涉及打开和关闭通道的链上交易（这类交易的手续费估算由 C-Lightning 外包给 Bitcoin Core），也涉及支付通道内的费用。

- [C-Lightning #1854][] 实现了 [BOLT2][] 的额外部分，特别是与 `option_data_loss_protect` 字段相关，以改善处理节点似乎丢失了关键数据（即承诺值）的情况，或者远程节点发送的承诺数据无效并可能故意撒谎的情况。

---

{% include references.md %}
{% include linkers/issues.md issues="14032,12254,12676,1874,1870,1854" %}

[dandelion protocol]: https://arxiv.org/abs/1701.04439
[bcc 0.17]: https://bitcoincore.org/bin/bitcoin-core-0.17.0/
[timewarp maxwell]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016316.html
[timewarp lau]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016320.html
[BOLT2]: https://github.com/lightningnetwork/lightning-rfc/blob/master/02-peer-protocol.md
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}
[bse 78355]: {{bse}}78355
[bse 77764]: {{bse}}77764
[bse 72775]: {{bse}}72775
[information theoretic perfect privacy]: https://en.wikipedia.org/wiki/Information-theoretic_security
[bip151 update]: https://gist.github.com/jonasschnelli/c530ea8421b8d0e80c51486325587c52
[newhope]: https://newhopecrypto.org/
