---
title: 'Bitcoin Optech Dashboard'
permalink: /zh/dashboard-announcement/
name: 2018-09-04-dashboard-announcement-zh
slug: 2018-09-04-dashboard-announcement-zh
type: posts
layout: post
lang: zh
version: 1
excerpt: >
  介绍 Bitcoin Optech Dashboard，其中包含有关合并、支付批处理、RBF，隔离见证采用等实时更新的统计数据。
---

{:.post-meta}
*由 [Marcin Jachymiak](https://github.com/marcinja) 撰写<br>Bitcoin Optech 的实习生*

这个夏天，我作为 [Bitcoin Optech](/) 的一名实习生，致力于一个比特币指标仪表盘的开发。在这篇文章中，我将描述仪表盘的目的以及其实现方式。

Optech 仪表盘的目标是展示一系列关于如何有效利用区块空间的指标。重要的指标是那些显示活动的指标，例如：
 - **<!--batching-->**[批处理](https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#Payment_batching)： 将本可以作为多个不同交易的输出合并到一个交易中
 - **<!--consolidations-->**[合并](https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#Consolidation)：在低费用时期将多个 UTXO 合并为一个 UTXO，以避免将来支付更高的费用
 - 粉尘创建：在不同的费率下，创建的 UTXO 花费成本高于其价值
 - 隔离见证采用：创建和从隔离见证输出中花费

该仪表盘已经上线，正在 [dashboard.bitcoinops.org](https://dashboard.bitcoinops.org) 显示这些统计数据及更多信息。

用于仪表盘的数据集也以 JSON 文件的目录形式保存，每晚更新。您可以从我们的 [S3 bucket](http://dashboard.dataset.s3.us-east-2.amazonaws.com/backups/bitcoinops-dataset.tar.gz) 下载压缩的数据集。如果您只想要特定区块的 JSON 文件，可以在 `http://dashboard.dataset.s3.us-east-2.amazonaws.com/blocks/BLOCK_NUMBER.json` 获取。如果您愿意使用自己的全节点重新创建数据（这可能需要几天时间），您可以使用 [github.com/bitcoinops/btc-dashboard](https://github.com/bitcoinops/btc-dashboard) 中带有说明的代码。

同一存储库中提供了[带有添加字段解释的示例 JSON 文件](https://github.com/bitcoinops/btc-dashboard/blob/master/STATS_TRACKED.md)。

## 实现
本文的其余部分将围绕我构建仪表盘的经历。开始时，我查看了类似 BlockSci 的现有区块链分析工具。尽管 BlockSci 运行得相当不错，但它有一个长时间的设置过程，我还希望能够分析正在确认的区块。在使用 BlockSci 的过程中，我发现编写类似于[他们生产的演示中的查询](https://citp.github.io/BlockSci/demo.html)非常容易，这些查询只需要几分钟就能返回结果。使用 BlockSci 的主要缺点是其解析器预处理区块链数据需要很长时间，但一旦完成，它的表现相当好。

在探索这些选项之后，我决定我可能可以通过从 bitcoind 的 RPC 获取大部分仪表盘所需的统计数据。我编写了一些简单的代码（使用 btcd 的 RPC 客户端），通过`getblock`和`getrawtransaction` RPC 从每笔交易中获取我所需的统计数据。对于较小的区块，这段代码运行得相当好，但当我尝试使用它获取较新区块的统计数据时——这些区块通常包含超过一千笔交易——我很快注意到了一个问题。我的代码对区块中的每个交易输入都调用了`getrawtransaction`。让 bitcoind 对每个区块进行成千上万次 RPC 会很快变得不可行，并且花费了很长时间。

代码大致如下：
```
block, err := rpcclient.GetBlock(blockHash)
for _, tx := range block.Transactions {
    for _, input := range tx.TxIn {
        analyzeInput(input)

        prevTx := rpcclient.GetRawTransaction(input.PreviousOutPoint.Hash)
        analyzePrevOut(input, prevTx)
    }

    for _, output := range tx.TxOut {
        analyzeOutput(output)
    }
}
```

然后我开始查看`getblockstats` RPC以获取一些额外的统计数据，同时我试图找到解决这个问题的方法。[`getblockstats` 是 bitcoind 中的一个新 RPC](https://github.com/bitcoin/bitcoin/pull/10757)，预计将在 Bitcoin Core 0.17 中发布。它为任何给定的区块提供了几个有用的统计数据。例如，仪表盘使用它来展示不断变化的费率、UTXO 集合大小的变化，以及每个区块的输入、输出和交易数量。

在查看 RPC 代码时，我意识到 RPC 实现中的主循环与我的代码中的主循环非常相似。两者都遍历区块中的所有交易，并在迭代其输入和输出时收集统计数据。主要区别在于我的代码有成千上万次 RPC 的额外开销。因此，与其处理许多 RPC 的开销，不如修改这一个 RPC，从单个 RPC 中获取区块所需的所有内容。

我修改了 bitcoind 中的`getblockstats`以获取以下统计数据：
- 表示选择加入替代费率（RBF）的交易数量

    ![rbf](/img/posts/dashboard-announcement/rbf-graph.png)

- 花费或创建不同类型隔离见证输出的交易数量（以及在适用的情况下的输入/输出数量）：P2SH-Nested 和 Native（Bech32）变体的 P2WPKH 和 P2WSH

    ![segwit](/img/posts/dashboard-announcement/segwit-example-graph.png)

- 合并指标：将许多 UTXO 合并为一个交易输出的交易数量，以及合并的总输出数量。使用的启发式方法是“多对一”交易：一笔交易至少有 3 个输入和 1 个输出。

    ![mto](/img/posts/dashboard-announcement/mto-consolidations.png)

- 批处理指标：具有许多输出的交易，按输出数量的不同范围分组（受 [P2SH.info](https://p2sh.info/dashboard/db/batching?orgId=1) 图表的启发）。

    ![batching](/img/posts/dashboard-announcement/batching.png)

- 粉尘创建：在几种不同的费率下，将被认为是粉尘输出的新 UTXO 数量。
    ![dust](/img/posts/dashboard-announcement/dust.png)

对`getblockstats`进行的这些额外统计数据的补丁[可公开访问](https:///github.com/bitcoinops/bitcoin/tree/expand-getblockstats)。为了方便，我还[修补了 btcd 的 RPC 客户端](https://github.com/bitcoinops/btcd/tree/dashboard-rpc)，以允许在我编写的代码中使用`getblockstats`。

### 高效使用 bitcoind RPC
使用 `getblockstats` RPC 从比特币的整个历史数据中获取信息仍然可能非常慢！在我的桌面上运行从所有区块回填数据的代码，获取所有数据将需要数周时间。在对 bitcoind 进行性能分析时，它响应 `getblockstats` RPC，我们看到，正如预期的那样，其大部分时间都用于从 tx_index 中检索交易，因此我们配置 bitcoind 以更好地处理所有这些数据库读取操作：

- 首先，我们将 `dbcache` 选项增加到约 2GB。由于在 RPC 中完成的大部分工作只是读取区块和交易的数据库，所以这是非常有用的。
- 其次，我们使用 `noconnect` 和 `nolisten` 关闭了节点的网络连接。没有任何网络连接，一个完整节点除了响应 RPCs 外真的没有什么其他工作要做。

最后一个性能改进只是使用更好的硬件。我一直在我的桌面上运行仪表盘回填程序，我的所有区块数据都存储在 HDD 上。在将其运行在带有 SSD 的服务器上后，数据库读取速度大大加快，因此回填过程花费的时间大大减少。平均来说，它每 0.6 秒处理一个区块。交易较少的小区块甚至用时更短。有了这套设置，回填只需几天时间。

现在历史数据已经收集完毕，相同的设置用于对即将到来的区块进行实时分析。在这种情况下（完整节点必须在线并处理区块），使用 `getblockstats` 获取结果仍然只需 1-3 秒。

### 数据库
我们如何处理从 `getblockstats` 获取的所有数据？

首先，我们从统计数据 “X” 和 “Y” 中衍生出一些额外的统计数据，如 “X 中的 Y 百分比”，以方便使用（bitcoind 的补丁没有包含这些数据，是为了给用户提供不包含它们的选择，因为它们很容易计算）。然后，我们将结果存储为一个 JSON 文件，并存入数据库。这是在一个使用上述描述的修改过的 btcd RPC 客户端的程序中完成的。为了在我们的网站上制作图表，我们使用了 Grafana，这是一个创建仪表盘和可视化的工具，它可以查询这个数据库。

我最初使用的数据库是 InfluxDB。我选择它是因为它似乎很受 Grafana 仪表盘的欢迎，而且易于使用和设置。不幸的是，我很快就在使用它时遇到了一些问题。InfluxDB 喜欢使用大量内存，加载完整数据集时大约需要 14GB。如果你投入更好的硬件，这个问题会小一些。即便有了更好的硬件，我们仍然遇到了查询时间慢的问题。在尝试调整设置后，我找不到一个方法来大幅改善这种情况。

在仪表盘中，我们希望能够显示历史趋势，这意味着要进行可能需要数年数据的查询。这些查询特别慢，经常需要超过 60 秒才能完成。在尝试了 InfluxDB 的许多不同设置后，我决定尝试一个不同的数据库并比较性能。免责声明：我真的不太懂如何使用 InfluxDB，或多或少是使用了默认设置并在这里那里做了一些更改。我会说，对于较小时间尺度的查询，InfluxDB 工作得很好。

#### Postgres 最棒
我查看了其他人用于 Grafana 仪表盘的数据库，Postgres 也相当常见。它在其他环境下也有良好的数据库声誉。还有大量的 Go 包实现了 Postgres 驱动程序，这很有帮助，因为我是用 Go 编写收集统计数据的程序的。我基本上是随机选择了 go-pg 作为 Postgres 驱动程序。它一开始就能正常工作，所以我就继续使用它了。

使用 go-pg，您可以基于类型的定义来定义一个表模式，并且甚至可以通过在 Go 中标记相关的结构字段来添加约束，如 `notnull`。要插入数据库，您只需传入一个指向您选择的结构的指针，它就会被插入。

```
// 表设置示例
model := interface{}((*DashboardDataV2)(nil))
err = db.CreateTable(model, &orm.CreateTableOptions{
        Temp:        false,
        IfNotExists: true,
})
...
// 插入示例
err := worker.pgClient.Insert(&data.DashboardDataRow)
```

此时，我花在从 InfluxDB 中提取信息上的时间比插入到 Postgres 中的时间还要多。一旦切换到 Postgres 完成，仪表盘上的图表在 Grafana 中加载速度就快多了。

## 结果
您可以使用 Bitcoin Optech 仪表盘查看这些统计数据作为比特币整个历史的历史趋势，以及随着新区块被确认的实时数据。所有这些都可以在我们的仪表盘 [dashboard.bitcoinops.org](https://dashboard.bitcoinops.org) 上实时查看！