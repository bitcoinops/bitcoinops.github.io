---
title: 宣布兼容性矩阵
permalink: /zh/2019-compatibility-matrix/
name: 2019-08-20-compatibility-matrix-zh
type: posts
layout: post
lang: zh
slug: 2019-08-20-compatibility-matrix-zh

excerpt: >
  宣布 Bitcoin Optech 网站上的新兼容性矩阵，提供不同钱包和服务对扩容技术的支持文档。

auto_id: false
---
{% include references.md %}

今天我们很高兴宣布 Bitcoin Optech 网站上新增了一个[兼容性矩阵][compatibility]。该兼容性矩阵提供：

1. 钱包和服务对不同扩容技术支持的汇总表。
2. 每个评估钱包和服务的详细描述和可用性截图。

在首次上线时，我们包含了对 [segwit 地址][compatibility segwit]和 [RBF][compatibility rbf] 采用情况的评估。

## Segwit 地址

对 Bech32 采用情况的分析部分受到了 BRD 的[whensegwit.com][when segwit website]工作和 Bitcoin Core GitHub 问题[“何时将 bech32 设为默认地址类型？”][bitcoin github issue #15560]的推动，开发者在其中讨论了是否应根据更广泛的比特币钱包对 Bech32 地址的发送支持，将 Bitcoin Core 的钱包默认设置为 Bech32 接收地址。

我们收集的 Segwit 地址测试信息包括：

- 接收支持
  - 钱包是否允许创建 P2SH 包裹的 Segwit 地址？
  - 钱包是否允许创建 Bech32 Segwit 地址？
  - 默认接收地址类型是什么？
- 发送支持
  - 钱包能否发送到 P2WPKH 地址？
  - 钱包能否发送到 P2WSH 地址？
  - 钱包是否使用 Bech32 找零地址？

## RBF

对生态系统中 RBF 采用情况的初步分析需求来自 Optech 成员公司。这些公司对于实施 RBF 持谨慎态度，因为他们不确定其他钱包对 RBF 的支持情况如何。

在编写了[RBF 分析的汇总报告][rbf report]之后，我们希望提供一个更深入的资源来共享底层数据，这促使我们开始开发一个网站来展示这些信息。

我们收集的 RBF 测试信息包括：

- 接收支持
  - 接收到的交易是否在交易列表中标记为可替换？
  - 接收到的交易是否在交易详情中标记为可替换？
  - 传入交易通知是否显示交易已标记 RBF？
  - 在交易被替换后，交易列表中显示的是原交易还是替换后的交易？
- 发送支持
  - 钱包是否允许发送 BIP125 可选 RBF 交易？
  - 发送的交易是否在交易列表中标记为可替换？
  - 发送的交易是否在交易详情中标记为可替换？
  - 在发送的交易被替换后，交易列表中显示的是原交易还是替换后的交易？

我们希望汇总数据能够提供比特币生态系统中技术采用情况的良好概览。同时，我们也希望每个钱包或服务的更详细截图能从可用性角度展示这些技术的部署情况。

我们计划在未来添加更多的钱包或服务，以及附加的评估指标到矩阵中。我们[欢迎贡献][optech contributions]，以便添加钱包或服务、更新测试版本或添加更多的可用性截图或视频。

如果您有任何建议，认为有其他有价值的评估指标或希望未来能评估的比特币服务，请通过 [info@bitcoinops.org][optech email] 与我们联系。

[compatibility]: /en/compatibility/
[compatibility segwit]: /en/compatibility/#segwit-addresses
[compatibility rbf]: /en/compatibility/#replace-by-fee-rbf
[when segwit website]: http://whensegwit.com
[bitcoin github issue #15560]: https://github.com/bitcoin/bitcoin/issues/15560
[rbf report]: /en/rbf-in-the-wild/
[optech contributions]: https://github.com/bitcoinops/bitcoinops.github.io/blob/master/CONTRIBUTING.md
