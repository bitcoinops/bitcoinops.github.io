正如[上周所述][bech32 easy]，实现 segwit 仅花费应当是容易的。然而我们怀疑一些管理者可能会想知道是否有足够多人使用 segwit 来证明他们的团队值得在此方面花费开发精力。本周，我们查看了追踪各种 segwit 采用统计数据的网站，以便你可以决定它是否足够流行，以至于你的钱包或服务如果不支持它会成为异类。

Optech 在我们的[仪表盘][optech dashboard]上追踪 segwit 使用的统计数据；另一个追踪相关统计数据的网站是 [P2SH.info][]。我们看到平均每个区块大约有 200 个输出被发送到原生 segwit 地址 (bech32)。这些输出随后在大约 10% 的比特币交易中被花费。使得涉及原生 segwit 地址的支付比几乎所有的山寨币都更受欢迎。

![Optech 仪表盘 segwit 使用统计数据的截图](/img/posts/2019-03-segwit-usage.png)

然而，许多钱包想要使用 segwit 但仍需要处理尚未支持 bech32 发送的服务。这些钱包可以生成一个引用其 segwit 详细信息的 P2SH 地址，这比使用 bech32 效率低，但比不使用 segwit 效率高。由于这些是普通的 P2SH 地址，仅通过查看交易输出我们无法判断哪些 P2SH 地址是预 segwit 的 P2SH 输出，哪些包含嵌套 segwit 承诺，因此我们不知道支付到嵌套 segwit 地址的实际数量。然而，当这些输出之一被花费时，花费者会揭示该输出是否是 segwit。上述统计网站报告，目前大约 37% 的交易包含至少一个嵌套 segwit 输出的花费。这对应于平均每个区块大约 1,400 个输出。

任何支持 P2SH 嵌套 segwit 地址的钱包也可能支持 bech32 原生地址，因此当前由希望利用 bech32 发送支持的钱包进行的交易数量超过 45% 且在不断增加。

为了进一步评估 segwit 的流行度，你可能还想知道哪些值得注意的比特币钱包和服务支持它。为此，我们推荐社区维护的比特币 Wiki 上的 [bech32 adoption][] 页面或由 BRD 钱包维护的 [when segwit][] 页面。

统计数据和兼容性数据显示 segwit 已经得到了良好的支持并且经常使用，但仍有一些值得注意的迟缓者尚未提供支持。我们希望我们的活动和其他社区努力将帮助说服这些迟缓者赶上 bech32 发送支持，以便所有希望利用原生 segwit 的钱包可以在接下来的几个月中做到这一点。

[bech32 easy]: /zh/newsletters/2019/03/19/#bech32-发送支持
[optech dashboard]: https://dashboard.bitcoinops.org/
[p2sh.info]: https://p2sh.info/
[bech32 adoption]: https://en.bitcoin.it/wiki/Bech32_adoption
[when segwit]: https://whensegwit.com/
