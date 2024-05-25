{% comment %}<!--
版权归 2018 Anthony Towns 所有
-->{% endcomment %}

正如在 [Newsletter #3][newsletter 3] 中提到的，过去几个月低交易费用的情况成为 UTXO 合并的极佳时机！合并是 [Xapo][Xapo] 为了准备下次费用像 2017 年最后几个月那样激增而进行的各种活动之一。

{% assign img1_label = "Plot of total Bitcoin UXTOs, January - July 2018" %}

{:.center}
![{{img1_label}}](/img/posts/utxo-consolidation-2018.png)<br>
*{{img1_label}},
source: [Statoshi](https://statoshi.info/dashboard/db/unspent-transaction-output-set?panelId=6&fullscreen&from=1514759562608&to=1532039707168)*

[newsletter 3]: /zh/newsletters/2018/07/10/#仪表盘项
[Xapo]: https://www.xapo.com/

UTXO 合并背后的思想本质上是这样的：当你的平均支出付款大于你的平均收入付款（或者当它们相同，但你正在批量支出付款）时，你通常需要合并许多 UTXO 以资助一个支出交易，这会增加你的交易大小，从而增加你支出的费用。通过提前合并 UTXO，你可以提前合并输入（inputs），让你更多地控制大部分费用发生的时间。如果你能在费用低时进行，这让你可以大幅减少这些成本。

例如，如果你将要在 100 s/B（satoshis per byte）的费率下花费 12 个 2-of-3 多签名输入，那么将会花费约360,000聪；而如果你事先在 2 s/B 的费率下合并这些输入，然后在 100 s/B 的费率下花费单一合并后的输入，两次交易的总成本只有约 41,000 聪：即在费用上节省 87%。而且如果费用没有上涨，风险并不大：如果费用一直维持在 2 s/B，如果你进行了整合，那么你会在两次交易中花费 7,900 聪，而如果你什么都不做，只进行一次交易，你将花费 7,200 聪。

合并还提供更新你用于 UTXO 的地址的机会，例如更换密钥、转换到多签名、或转换到 SegWit 或 bech32 地址。而且减少 UTXO 的数量使得运行一个全节点变得更加容易，从而边际性地提高了比特币的去中心化和总体安全性，这总是很好的。

当然，你真正不希望发生的一件事是你的合并交易以某种方式填满了区块链并立即导致费用开始上涨！有两个指标要观察以避免这种风险：一个是 [mempool][mempool] 是否已满（这会导致最低可接受费用上升），另一个是最近区块中有多少空间（这给出了矿工是否会以最低费用接受更多交易的指示）。过去几个月大多数时间这两个指标都非常有希望：mempool 经常接近空，意味着支付低至 1 s/B 的交易已被传播到矿工；许多区块没有被填满，意味着廉价的合并交易将会被合理快速地挖掘，而不是创造积压导致费用上升。

[mempool]: https://statoshi.info/dashboard/db/memory-pool?panelId=1&fullscreen&from=1509458400000&to=1531813659334&theme=dark

我们实际进行合并的方法是有一个脚本，它会选择一组小型 UTXO 并创建一个以 1.01 s/B 的费率将它们支出到单个池地址的合并交易。该脚本逐渐将合并交易输入网络，因此它不会在 mempool 中引起太大的突增，更重要的是我们不会因为费用低和 mempool 已满而冒险让我们的交易被丢弃。当我们对这不会干扰我们的操作感到舒适时，以及在比特币网络总体上看来没有太大负载时，我们手动触发了这个过程。

总的来说，这个过程进行得相当好；我们今年通过这种方式减少了大约 [400 万个 UTXO][4 million UTXOs]，除了一些[担忧的][redditors1] [Reddit 用户][redditors2]，对整个网络的成本以及对我们的成本都非常小。

[4 million UTXOs]: https://www.oxt.me/entity/Xapo
[redditors1]: https://www.reddit.com/r/BitcoinDiscussion/comments/8ocyc9/massive_consolidation_currently_underway/
[redditors2]: https://www.reddit.com/r/Bitcoin/comments/8p3y5b/does_xapo_spamming_the_blockchain/

{{include.hlevel | default: '##'}} 额外资源

- [减少交易费用的技术：合并](https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#Consolidation) - Bitcoin Wiki
- [如何廉价地合并币以减少矿工费用](https://en.bitcoin.it/wiki/How_to_cheaply_consolidate_coins_to_reduce_miner_fees) - Bitcoin Wiki
- [关于使用合并和扇出的最佳实践有哪些？](https://bitgo.freshdesk.com/support/solutions/articles/27000044185-what-are-some-best-practices-regarding-the-usage-of-consolidations-and-fanouts-) - BitGo