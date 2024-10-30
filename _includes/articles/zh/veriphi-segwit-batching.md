{:.post-meta}
*作者：[Gustavo Flores Echaiz][]，[Veriphi][] 产品经理*

手续费优化可以通过多种技术实现，从隔离见证、交易批处理、RBF（Replace By Fee）到手续费估算。对于后两种技术——RBF 和手续费估算——要精确计算节省的交易手续费是相当困难的，但由于隔离见证和批处理的改进是可测量的，因此可以将它们的收益建模到假设场景中。

在我们的报告中，我们想要对比目前的部分采用情况，模拟全网完全采用原生隔离见证（P2WPKH 或 P2WSH）和交易批处理的情况。我们希望确定可以节省的交易手续费总额，这一数据随时间的变化，以及其对区块空间和区块权重的影响。

我们对交易批处理的建模基于 David A. Harding 的[公式][harding batching formula]，用于检测交易是否花费了它在同一区块中收到的比特币。如果是这样，这些交易在理论上是可以进行批处理的，并且交易权重可以减小。在将所有潜在可批处理的交易合并后，我们将假设区块的大小与实际区块大小进行对比。从这里我们可以计算节省的字节数及其所代表的节省百分比。最后，如果我们取每个区块的大小，减去区块头和矿工的 coinbase 交易的大小，我们可以将节省的大小除以这个新数值。我们得到的百分比是完全采用情况下可能节省的手续费的近似值。我们用于分析数据和计算潜在节省的代码在[这里][veriphi batching repo]。

对于隔离见证，我们分析了从 2017 年 8 月 24 日隔离见证激活日（区块 481,825）到 2020 年 6 月 30 日（区块 637,090）的数据。我们的方法是遍历每笔交易的每个输入，如果该输入不是原生隔离见证，则计算它如果是原生隔离见证所节省的权重，这可以指示我们能够节省的手续费总量。最后，我们收集了每个区块的实际区块权重和区块手续费，并通过汇总每笔交易的结果收集了我们模型的潜在区块权重和潜在区块手续费。我们使用的代码库可以在[这里][veriphi segwit repo]找到。

__主要收获__

假设比特币价格为 9,250 美元（在报告发布时是正确的）：

- 从 2012 年 1 月到 2020 年 6 月（区块 637,090），共支付了 211,000 BTC 的手续费给矿工，总金额约为 20 亿美元。
- 在此期间的总节省量达到将近 58,000 BTC，金额约为 5.3 亿美元。这相当于交易手续费总额的约 27.36%。
- 如果所有比特币用户都使用了交易批处理，他们可以节省超过 21,000 BTC，相当于节省 10% 或约 2 亿美元。
- 从 2017 年 8 月 24 日到 2020 年 6 月 30 日，如果所有比特币用户都使用原生隔离见证（bech32），可以节省约 37,000 BTC，相比于实际支付的超过 97,000 BTC 的手续费，这相当于节省 38% 或约 3.4 亿美元。
- 通过采用隔离见证和批处理等优化的手续费管理技术所带来的优势在高交易活动期间最为显著。在 8 年 6 个月的分析期间，大部分可能的节省都集中在几个关键月份内。

阅读[我们的完整报告][veriphi segwit batching full report]，了解手续费节省随时间的变化情况。

{% include references.md %}
[Gustavo Flores Echaiz]: https://twitter.com/GustavoJ_Flores
[Veriphi]: https://veriphi.io/
[veriphi segwit batching full report]: https://veriphi.io/segwitbatchingcasestudy.pdf
[harding batching formula]: https://github.com/harding/ref-payment-batching
[veriphi batching repo]: https://github.com/Gfloresechaiz/ref-payment-batching
[veriphi segwit repo]: https://github.com/Gfloresechaiz/all_transactions_segwit
