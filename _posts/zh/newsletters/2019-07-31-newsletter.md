---
title: 'Bitcoin Optech Newsletter #57'
permalink: /zh/newsletters/2019/07/31/
name: 2019-07-31-newsletter-zh
slug: 2019-07-31-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 介绍了用于 JoinMarket 风格去中心化 coinjoin 的忠诚债券（fidelity bond），提到一个为 BIP322 signmessage 支持而开的 PR（其中包括为 bech32 地址签名的能力），并总结了一场关于布隆过滤器的讨论。此外，还包括我们常规的 bech32 发送支持部分、Bitcoin Stack Exchange 热门问答，以及流行比特币基础设施项目中值得注意的变更。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- **<!--help-test-bitcoin-core-0-18-1-release-candidates-->****帮助测试 Bitcoin Core 0.18.1 候选版本：** 这个即将发布的维护版本修复了几个错误，这些错误影响了部分 RPC 命令，并在某些情况下导致 CPU 使用率不必要地升高。我们鼓励生产环境用户测试当前的[候选版本][core rc]，以确保其按预期运行。

## 新闻

- **<!--fidelity-bonds-for-improved-sybil-resistance-->****用于提升 Sybil 抵抗能力的忠诚债券：** JoinMarket 开发者 Chris Belcher 在 Bitcoin-Dev 邮件列表上[发帖][fidelity coinjoin]，讨论一个此前已知、且影响去中心化 coinjoin 实现的问题可以如何解决。JoinMarket 的用户可以扮演 *makers*（公布自己愿意参与 coinjoin 的人）或 *takers*（向自己选定的 maker 发起混币的人）。单个 [Sybil 攻击者][sybil attack]可以冒充足够多的不同 maker，使自己的一个或多个马甲在几乎每次 coinjoin 中都被选中，从而有能力消除或显著削弱混币带来的隐私收益。

  Belcher 提出，maker 可以通过销毁（“焚烧”）比特币，或把比特币时间锁定很长一段时间，来创建一个持久的密码学身份。与这些付出相对应，maker 还会有一个公钥，可用来为其在 JoinMarket 中的临时身份签名。然后，taker 会按各 maker 付出的多少（由公式计算）加权，在合格的 maker 中随机挑选 coinjoin 对象。

  好的一面是，这将要求攻击者付出大量比特币，或放弃出售比特币的能力，从而使 Sybil 攻击代价更高。不利的一面是，诚实的 maker 很可能会为 coinjoin 收取更高的费用，以补偿自己的付出，这会推高 JoinMarket coinjoin 的成本。

- **<!--pr-opened-for-bip322-generic-signed-message-format-->****BIP322 通用签名消息格式的 PR：** Kalle Alm 向 Bitcoin Core 提交了一个[PR][Bitcoin Core #16440]，其中实现了 [BIP322][]，并更新 `signmessage`、`signmessagewithprivkey` 和 `verifymessage` 这三个 RPC：除传统的 P2PKH 地址外，还支持为 P2WPKH 和 P2SH-P2WPKH 地址签名。该 PR 目前正在征求反馈和概念性审查。尽管这个 PR 只提供了 BIP322 支持的基本实现，但后续扩展可以让 Bitcoin Core 为任何可花费脚本签名和验证消息，而且这种支持可以方便地升级，以适应未来脚本语言的变化，比如 [taproot][bip-taproot]。希望其他钱包也能考虑自行实现 BIP322，从而提供灵活且向前兼容的消息签名支持。请参阅 Optech 之前的 [bech32 部分][signmessage bech32]，我们曾在那里感叹缺少 BIP322 的实现。

  根据对该 PR 的早期反馈，BIP322 也已更新：用传统的 P2PKH 密钥签名和验证消息时，沿用旧的 signmessage 格式。这让 BIP322 工具能够完全向后兼容现有的、已被广泛实现的 signmessage 标准（该标准只支持 P2PKH）。

- **<!--bloom-filter-discussion-->****布隆过滤器讨论：** 在[上周的 Newsletter][Newsletter #56] 的 *值得注意的变更* 部分，我们提到了一个已合并的 [PR][Bitcoin Core #16152]，它禁用了 Bitcoin Core 默认配置中的布隆过滤器。该 PR 的作者在 Bitcoin-Dev 邮件列表上[公布][bloom announce]了这一尚未发布的改动，有几个人回复提出了疑问或担忧。讨论的一些要点包括：

  - **<!--no-urgent-action-required-->***无需紧急行动：* 截至本文写作时，接受入站连接的节点（监听节点）中有超过 20% 运行着一年以上的 Bitcoin Core 版本，[据 BitNodes 统计][bitnodes dashboard]。至少 5% 运行的版本已超过两年。照此推算到未来，到 2022 年初，仍会有超过 500 个监听节点提供布隆过滤器。因此，即使不再采取任何行动，钱包开发者可能仍有相当长的时间来调整自己的程序。

  - **<!--spies-likely-to-run-their-own-nodes-->***间谍可能会运行自己的节点：* 除了那些尚未升级的节点之外，区块链分析公司也可能继续运行自己的节点，在未来继续提供布隆过滤器，以便从钱包那里收集统计信息——这些钱包的过滤器会[泄露信息][filter privacy]，暴露出其中包含哪些地址。

  - **<!--dns-seeds-can-return-only-nodes-signaling-bip111-->***DNS 种子可以只返回表示支持 BIP111 的节点：* 大多数 P2P 轻钱包会向一个或多个 Bitcoin DNS 种子（DNS seeds）查询可用的节点列表。有些种子允许按节点所配置的服务位来筛选返回哪些节点[^dns-query]，而表示支持布隆过滤器的服务位由 [BIP111][] 规定。

  - **<!--bip157-would-use-more-bandwidth-than-bip37-->***BIP157 会比 BIP37 占用更多带宽：* 有人提出，一些使用 [BIP37][] 布隆过滤器的用户无法改用 [BIP157][] 紧凑区块过滤器，因为后者占用的带宽更高。Optech 在 [Newsletter #43][] 中简要考察过过滤器大小，发现过滤器本身每月不到 100 MB。客户端还需要下载匹配的区块，所需数量取决于它的活跃程度（对典型用户而言，大约每发送或接收一笔交易对应一个区块；大多数区块大小不足 2 MB）。会有多少用户因必须下载这么多数据而受到明显影响，目前还不清楚。

  - **<!--interested-parties-can-run-their-own-nodes-->***感兴趣的人可以自己运行节点：* 对 Bitcoin Core 的这项改动只是默认禁止提供布隆过滤器服务，并没有移除该功能。依赖布隆过滤器支持的钱包作者可以自行运行自己的节点，也不难做到；他们还可以尝试说服其他不担心 DoS 漏洞的节点运营者把该配置选项设为 true，例如 `peerbloomfilters=1`。

## Bech32 发送支持

*这是共 24 周的[系列][bech32 series]中的第 20 周，目的是让你支付的对象也能获得隔离见证的全部好处。*

{% include specials/bech32/zh/20-percentage-loss.md %}

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们有点空闲时帮助好奇或困惑用户的地方。在本月栏目中，我们精选自上次更新以来得票最高的一些问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--why-does-the-importmulti-rpc-not-support-zpub-and-ypub-->**[为什么 `importmulti` RPC 不支持 zpub 和 ypub？]({{bse}}89261) Fontaine 问为什么 Bitcoin Core 的 `importmulti` RPC 支持 xpub 公钥派生格式，但不支持 ypub 或 zpub 格式。Pieter Wuille 解释说 xpub 格式由 BIP32 规定，用来生成当时最常见的 P2PKH 地址类型。Pieter 接着说明，Bitcoin Core 的[输出脚本描述符][descriptor]是生成地址的一种更可持续的做法。

- **<!--is-bitcoin-pow-actually-sha256-merkle-tree-generation-->**[比特币的 PoW 实际上是 SHA256 加 Merkle 树生成吗？]({{bse}}89296) 用户 ascendzor 想知道矿工在 PoW 挖矿中需要重新计算 Merkle 根会有什么后果，以及为什么 nonce 不能增加到 64 位。Pieter Wuille 解释说，不仅计算 Merkle 根的开销可以忽略不计，而且增大 nonce 还需要硬分叉。

- **<!--what-is-the-difference-between-bytes-and-virtual-bytes-vbytes-->**[字节和虚拟字节（vbytes）之间有什么区别？]({{bse}}89385) Ugam Kamat 和 Murch 指出了虚拟大小（vsize，以 vbytes 为单位）与大小（以字节为单位）的差异，进而解释了区块权重上限和隔离见证折扣。

- **<!--to-what-extent-does-asymmetric-cryptography-secure-bitcoin-transactions-->**[非对称加密在多大程度上保障比特币交易安全？]({{bse}}89262) RedGrittyBrick 和 Pieter Wuille 解释说，虽然比特币并不是靠非对称加密来防止漏洞或攻击的，但它正是让个人的币不被他人取走的机制。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的变更。*

- [BIPs #800][] 更新了 [BIP174][]，指出只有当钱包认为某个签名哈希（sighash）类型能提供可接受的安全性时，才可以使用部分签名比特币交易（PSBT）中请求的该 sighash 类型签名。处理常见交易类型的大多数钱包应当拒绝 `SIGHASH_ALL` 以外的任何类型。

- [BIPs #766][] 为在[Newsletter #37][]中描述的 `addr` v2 提议分配了 [BIP155][]。此提案将允许节点相互分享它们的 Tor 隐藏服务（onion）版本 3 地址，并提供与其他网络地址协议的兼容性。

- [BIPs #643][] 新增了关于盲合并挖矿的 [BIP301][]，该主题此前在 2017 年底的 Bitcoin-Dev 邮件列表中[讨论过][drivechain discussion]。盲合并挖矿意在配合一种称为“drivechain”的去中心化侧链使用。与其他去中心化侧链提案类似，drivechain 只具备 SPV 安全性，这意味着算力足够的矿工可以从侧链用户那里偷走资金。

- [C-Lightning #2842][] 在从通道对等节点收到“同步错误”时，会尝试重连，而不是让通道失败。这是有意偏离[闪电网络规范][bolt1 error]的决定，因为 LND 节点似乎经常产生这个错误，而 C-Lightning 维护者担心，如果 C-Lightning 如实地让通道失败，“照这个速度，我们就有把网络一分为二的风险”。

## 脚注

[^dns-query]:
    例如，下面我们向一个种子节点查询那些启用了完整链历史（`NODE_NETWORK`）和布隆过滤器支持（`NODE_BLOOM`）服务位的节点：

    ```text
    $ python3
    >>> NODE_NETWORK = 1 << 0  ## 原始比特币 0.1 协议
    >>> NODE_BLOOM = 1 << 2    ## BIP111
    >>> hex(NODE_NETWORK | NODE_BLOOM)
    '0x5'

    $ dig x5.seed.bitcoin.sipa.be
    [...]

    ;; ANSWER SECTION:
    x5.seed.bitcoin.sipa.be. 3118	IN	A	84.77.52.0
    x5.seed.bitcoin.sipa.be. 3118	IN	A	165.227.110.22
    x5.seed.bitcoin.sipa.be. 3118	IN	A	52.163.63.49
    [...]
    ```

{% include linkers/issues.md issues="800,766,2842,643,16440,16152" %}
[bech32 series]: /zh/bech32-sending-support/
[bolt1 error]: https://github.com/lightningnetwork/lightning-rfc/blob/master/01-messaging.md#requirements-2
[drivechain discussion]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2017-December/015339.html
[core rc]: https://bitcoincore.org/bin/bitcoin-core-0.18.1/
[fidelity coinjoin]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-July/017169.html
[bitnodes dashboard]: https://bitnodes.io/
[sybil attack]: https://en.wikipedia.org/wiki/Sybil_attack
[bloom announce]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-July/017145.html
[signmessage bech32]: /zh/bech32-sending-support/#消息签名支持
[filter privacy]: https://jonasnick.github.io/blog/2015/02/12/privacy-in-bitcoinj/
[newsletter #43]: /zh/newsletters/2019/04/23/#basic-bip158-support-merged-in-bitcoin-core
[newsletter #56]: /zh/newsletters/2019/07/24/#bitcoin-core-16152
[newsletter #37]: /zh/newsletters/2019/03/12/#version-2-addr-message-proposed
[descriptor]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
