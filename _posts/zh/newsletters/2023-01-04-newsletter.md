---
title: 'Bitcoin Optech Newsletter #232'
permalink: /zh/newsletters/2023/01/04/
name: 2023-01-04-newsletter-zh
slug: 2023-01-04-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报包括警告 Bitcoin Knots 的用户有关发布签名密钥的泄漏、宣布发布 Bitcoin Core 的两个软件 fork，并总结了有关手续费替换政策的持续讨论。此外还包括我们的常规部分，新软件版本和候选版本的公告以及对流行的比特币基础设施软件的重大变更的描述。

## 新闻

- **Bitcoin Knots 签名密钥泄露：**Bitcoin Knots 全节点实现的维护者宣称他们用于签署 Knots 发布的 PGP 密钥遭到泄露。他们说，“在这个问题得到解决之前，不要下载和信任 Bitcoin Knots。如果你在过去的几个月里已经这样做了，请考虑现在就关闭该系统。”
  <!-- https://web.archive.org/web/20230103220745/https://twitter.com/LukeDashjr/status/1609763079423655938 -->
  其他全节点实现不受影响。


- **Bitcoin Core 的软件 fork：**上个月在 Bitcoin Core 上有两个补丁集发布：

    - *Bitcoin Inquisition：*Anthony Towns 在 Bitcoin-Dev 邮件列表[公布了][towns bci] [Bitcoin Inquisition][] 的一个版本，Bitcoin Core 的一个软件 fork，是在默认 [signet][topic signet] 上测试提议的软分叉和其他重要的协议更改。该版本包含对 [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] 和 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] 提案的支持。 Towns 的电子邮件还有对参与 signet 测试者有用的其他信息。

    - *全面 RBF 节点：* Peter Todd [公告了][todd rbf node] Bitcoin Core 24.0.1 上的一个补丁。该补丁在向其他节点公告其网络地址时会设置一个[全面 RBF 服务位（bit）][full-RBF service bit]，尽管当前的生效条件只是在节点配置启用 `mempoolfullrbf` 时。Peter Todd 指出，另一个全节点实现 Bitcoin Knots 也会公告其服务位，尽管它不包含专门连接到那些会公告其支持全面 RBF 的节点的代码。该补丁基于 Bitcoin Core PR [#25600][bitcoin core #25600]。


- **<!--continued-rbf-discussion-->对 RBF 的持续讨论：**在关于在主网上启用[全面 RBF][topic rbf] 的持续讨论中，上个月在邮件列表上有几场同时进行的讨论：

    - *<!--full-rbf-nodes-->全面 RBF 节点：*Peter Todd 探测了那些宣称他们正在运行 Bitcoin Core 24.x 并接受 IPv4 地址上入站连接的全节点。他[发现][todd probe]大约有 17% 的人中继了一个全面的 RBF 替换：一个交易替换了一个不包含 [BIP125][] 信号的交易。这表明这些节点在 `mempoolfullrbf` 配置选项设置为 `true` 的情况下运行，即使该选项默认为 `false`。

    - *重新考虑 RBF-FSS：* Daniel Lipshitz 在 Bitcoin-Dev 邮件列表中[发表了][lipshitz fss]一种名为 First Seen Safe (FSS) 的交易替换的想法，其中替换将支付给原输出不少于原始交易的金额，以确保不能用替换机制从接收者窃取到原始交易。Yuval Kogman [回复][kogman fss]了一个 2015 年 Peter Todd 发布的相同想法的[早期版本][rbf-fss]的链接。在[后续][todd fss]回复中，Todd 描述了该想法比选用或全面 RBF 更不受欢迎的几个方面。

    - *<!--full-rbf-motivation-->全面 RBF 的动机：*Anthony Towns 在一个关于不同团体执行全面 RBF 动机的讨论主题帖下进行了[回复][towns rbfm]。Towns 分析了经济理性在矿工交易选择的背景下意味着什么、不意味着什么。优化短期利润的矿工自然会更喜欢全面 RBF。然而，Towns 指出，对挖矿设备进行长期投资的矿工可能更愿意优化多个区块的手续费收入，这种情况下就不一定会倾向于全面 RBF。他提出了三种可能的场景以供考虑。

## 新版本和候选版本

*热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Eclair 0.8.0][] 是这个流行的闪电网络节点实现的主要版本发布。该版本增加了对[零确认通道][topic zero-conf channels]和短通道标识符 (SCID) 别名的支持。有关这些功能和其他更改的更多信息，请参阅其[发行说明][eclair 0.8 rn]。

- [LDK 0.0.113][] 是这个用于构建支持闪电网络的钱包和应用的库的新版本。

- [BDK 0.26.0-rc.2][] 是这个用于构建钱包的库的候选发布版本。

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo] 和 [Lightning BOLTs][bolts repo]。*

- [Bitcoin Core #26265][] 将交易中继策略中允许的最小非见证序列化交易大小从 82 字节放宽到 65 字节。例如，具有单个输入和单个 4 字节 OP_RETURN 填充输出的交易，以前会因为太小而被拒绝；现在可以被节点的交易池接受并中继。有关此更改的背景信息和动机，请参阅 [Newsletter #222][min relay size ml]。

- [Bitcoin Core #21576][] 允许使用外部签名者（例如 [HWI][topic hwi]）的钱包在 GUI 中使用 [opt-in RBF][topic rbf]和在使用 `bumpfee` RPC 时增加费用。

- [Bitcoin Core #24865][] 允许在已剪除旧区块的节点上恢复钱包备份，只要该节点仍然拥有创建钱包后生成的所有区块。这些区块仍然需要，这样 Bitcoin Core 便可以扫描它们以查找影响钱包余额的任何交易。而 Bitcoin Core 能够确定钱包的年龄，是因为它的备份包含了钱包的创建日期。

- [Bitcoin Core #23319][] 更新 `getrawtransaction` RPC 以在 `verbose` 参数设置为 `2` 时提供额外信息。附加信息包括交易支付的费用以及有关先前交易的每个输出（“prevouts”）的信息，这些输出被用作此交易的输入。有关用于检索信息的方法的详细信息，请参阅 [Newsletter #172][news172 prevout]。

- [Bitcoin Core #26628][] 开始拒绝包含多个相同参数名称的 RPC 请求。以前，守护进程将带有重复参数的请求视为只有重复参数中的最后一个，例如 `{"foo"="bar", "foo"="baz"}` 被视为 `{"foo"="baz"}`。现在请求将失败。而当使用带有命名参数的 `bitcoin-cli` 时，行为没有改变：不会拒绝使用相同名称的多个参数，但只会发送重复参数的最后一个。

- [Eclair #2464][] 添加了在远端对方节点准备好处理付款时触发事件的功能。这在[异步付款][topic async payments]的情况中特别有用。在该情况下，本地节点可为远端对方节点暂停处理付款，等对方节点连接（或重新连接）后发送付款。

- [Eclair #2482][] 允许使用[盲化路径][topic rv routing]发送付款。这些路径的最后几跳由接收方选择。接收方使用洋葱加密来混淆跳转的详细信息，然后将加密数据连同盲化路径上第一个节点的身份一起提供给支付方。然后，支付方构建到第一个节点的支付路径和加密的详细信息，供最后几个节点运营商解密并用于将支付转发给接收方。这允许接收方接受付款而无需向支出方透露其节点或通道的身份，从而提高隐私性。

- [LND #2208][] 开始根据通道的最大容量相较于要花费的金额来选择不同的支付路径。当要发送的数量接近通道的容量时，该通道被选为路径的可能性就会降低。这与 Core Lightning 和 LDK 中已经使用的寻路代码大致相似。

- [LDK #1738][] 和 [#1908][ldk #1908] 提供了处理[要约（offers）][topic offers]的附加功能。

- [Rust Bitcoin #1467][] 添加了计算交易输入和输出[重量单位（weight units）][weight units]大小的方法。

- [Rust Bitcoin #1330][] 删除了 `PackedLockTime` 类型，要求下游代码改用基本相同的 `absolute::LockTime` 类型。任何人修改代码都可能需要研究这两种类型之间的区别：`PackedLockTime` 提供了一个 `Ord` 特性，但 `absolute::LockTime` 没有（尽管在包含该类型的交易的 `Ord` 中会考虑到锁定时间）。

- [BTCPay Server #4411][] 更新使用 Core Lightning 22.11（参见 [Newsletter #229][news229 cln]）。任何人想要将订单描述的哈希值放入 [BOLT11][] 发票都不再需要使用 `invoiceWithDescriptionHash` 插件，而是可以设置 `description` 字段并启用 `descriptionHashOnly` 选项。

{% include references.md %}
{% include linkers/issues.md v=2 issues="26265,21576,24865,23319,26628,2464,2482,2208,1738,1908,1467,1330,4411,25600" %}
[news172 prevout]: /en/newsletters/2021/10/27/#bitcoin-core-22918
[weight units]: https://en.bitcoin.it/wiki/Weight_units
[towns bci]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021275.html
[bitcoin inquisition]: https://github.com/bitcoin-inquisition/bitcoin
[todd probe]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021296.html
[lipshitz fss]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021272.html
[kogman fss]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021274.html
[todd fss]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021286.html
[rbf-fss]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2015-May/008248.html
[towns rbfm]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021276.html
[todd rbf node]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021270.html
[news229 cln]: /zh/newsletters/2022/12/07/#core-lightning-22-11
[full-rbf service bit]: https://github.com/petertodd/bitcoin/commit/c15b8d70778238abfa751e4216a97140be6369af
[eclair 0.8.0]: https://github.com/ACINQ/eclair/releases/tag/v0.8.0
[eclair 0.8 rn]: https://github.com/ACINQ/eclair/blob/master/docs/release-notes/eclair-v0.8.0.md
[ldk 0.0.113]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.113
[bdk 0.26.0-rc.2]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.26.0-rc.2
[min relay size ml]: /zh/newsletters/2022/10/19/#minimum-relayable-transaction-size
