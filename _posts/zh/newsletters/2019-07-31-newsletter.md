---
title: 'Bitcoin Optech Newsletter #57'
permalink: /zh/newsletters/2019/07/31/
name: 2019-07-31-newsletter-zh
slug: 2019-07-31-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了用于 JoinMarket 风格去中心化 CoinJoin 的 Fidelity Bonds，提到了一个用于 BIP322 signmessage 支持的 PR（包括对 bech32 地址的签名能力），并总结了关于布隆过滤器的讨论。还包括我们常规的关于 bech32 支持、Bitcoin Stack Exchange 精选问答以及值得注意的比特币基础设施项目的变更内容。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- **<!--help-test-bitcoin-core-0-18-1-release-candidates-->****帮助测试 Bitcoin Core 0.18.1 候选版本：**即将发布的这个维护版本修复了影响某些 RPC 命令的多个 bug，并在某些情况下导致 CPU 使用率不必要地高。建议生产环境用户测试当前的[候选版本][core rc]，以确保其按预期运行。

## 新闻

- **<!--fidelity-bonds-for-improved-sybil-resistance-->****用于改善 Sybil 抵抗性的 Fidelity Bonds：**JoinMarket 开发者 Chris Belcher 在 Bitcoin-Dev 邮件列表中[发布][fidelity coinjoin]了关于解决去中心化 CoinJoin 实现中已知问题的可能解决方案。JoinMarket 的用户可以作为 *makers*（广告参与 CoinJoin 的意愿者）或 *takers*（选择 makers 进行混币的人）进行操作。一个单一的 [Sybil 攻击者][sybil attack]可能冒充足够多的不同 makers，以至于在几乎每次 CoinJoin 中都能选择到一个或多个他们的马甲，从而能够消除或显著减少 CoinJoin 的隐私收益。

  Belcher 提出，makers 可以通过销毁（“焚烧”）比特币或长时间锁定比特币来创建持久的加密身份。这些牺牲将伴随着一个公钥，makers 可以使用它来签署其在 JoinMarket 中的临时身份。然后，takers 会随机选择符合条件的 makers 进行 CoinJoin，选择权重根据他们牺牲的大小（由公式决定）来计算。

  好处是，这将要求攻击者牺牲大量的比特币或出售比特币的能力，从而使 Sybil 攻击变得更加昂贵。不利的一面是，诚实的 makers 可能会为 CoinJoin 收取更多费用，以补偿他们的牺牲，从而增加 JoinMarket CoinJoin 的成本。

- **<!--pr-opened-for-bip322-generic-signed-message-format-->****为 BIP322 通用签名消息格式开启的 PR：**Kalle Alm 向 Bitcoin Core 提交了一个[PR][Bitcoin Core #16440]，实现了 [BIP322][]，更新了 `signmessage`、`signmessagewithprivkey` 和 `verifymessage` RPC，以支持对 P2WPKH 和 P2SH-P2WPKH 地址的签名，除了传统的 P2PKH 地址之外。该 PR 目前正在寻求反馈和概念性审查。尽管此 PR 仅提供了 BIP322 支持的基本实现，未来的扩展可以让 Bitcoin Core 对任何可消费的脚本进行消息签名和验证，并且这种支持可以轻松升级以适应未来脚本语言的变化，如 [taproot][bip-taproot]。希望其他钱包也能考虑实现 BIP322，以提供灵活的前向兼容的消息签名支持。请参阅 Optech 之前的 [bech32 部分][signmessage bech32]，我们曾遗憾地提到缺乏 BIP322 的实现。

  基于对该 PR 的早期反馈，BIP322 还进行了更新，以便使用传统 P2PKH 密钥签名和验证消息时使用旧的 signmessage 格式。这使得 BIP322 工具能够完全向后兼容现有的、广泛实施的 signmessage 标准（该标准仅支持 P2PKH）。

- **<!--bloom-filter-discussion-->****布隆过滤器讨论：**在[上周 Newsletter][Newsletter #56] 的 *值得注意的变更* 部分中，我们提到了一个已合并的 [PR][Bitcoin Core #16152]，该 PR 禁用了 Bitcoin Core 默认配置中的布隆过滤器。PR 的作者在 Bitcoin-Dev 邮件列表中[宣布][bloom announce]了这一未发布的更改，几个人对此发表了问题或担忧。讨论的一些要点包括：

  - **<!--no-urgent-action-required-->***无需紧急行动：*截至撰写本文时，接受入站连接的节点（监听节点）中有超过 20% 运行的是一年以上的 Bitcoin Core 版本 [根据 BitNodes 数据][bitnodes dashboard]。至少 5% 运行的是两年以上的版本。推断到未来，这意味着到 2022 年初，仍将有超过 500 个监听节点提供布隆过滤器支持。因此，即使不采取进一步行动，钱包开发者可能仍有足够的时间来调整他们的程序。

  - **<!--spies-likely-to-run-their-own-nodes-->***间谍可能会运行自己的节点：*除了未升级的节点之外，区块链分析公司可能会继续运行自己的节点，以在未来提供布隆过滤器支持，从而收集钱包的统计数据，这些数据的过滤器[泄露信息][filter privacy]关于它们包含的地址。

  - **<!--dns-seeds-can-return-only-nodes-signaling-bip111-->** *DNS seeds 只能返回信号 BIP111 的节点：*大多数 P2P 轻钱包会查询一个或多个比特币 DNS seeds 以获取要使用的节点列表。一些 seeds 允许根据节点配置的服务比特来筛选返回的节点[^dns-query]，其中支持布隆过滤器的服务位由 [BIP111][] 指定。

  - **<!--bip157-would-use-more-bandwidth-than-bip37-->***BIP157 将使用比 BIP37 更多的带宽：*有人建议，一些使用 [BIP37][]布隆过滤器的用户将无法切换到 [BIP157][] 致密区块过滤器，因为后者的带宽使用更高。Optech 在 [Newsletter #43][] 中简要调查了过滤器大小，发现过滤器本身每月使用不到 100 MB。客户端还需要下载匹配的区块，这将根据其活动而有所不同（对于典型用户来说，大约每个发送或接收的交易对应一个区块；大多数区块小于 2 MB）。目前尚不清楚有多少用户会因必须下载这些数据量而受到显著影响。

  - **<!--interested-parties-can-run-their-own-nodes-->***感兴趣的方可以运行自己的节点：*对 Bitcoin Core 的更改只是默认禁用布隆过滤器服务。它并没有移除这个功能。依赖布隆过滤器支持的钱包的作者可以轻松地操作自己的节点，他们也可以尝试说服其他不担心 DoS 漏洞的节点操作员将配置选项设置为 true，例如 `peerbloomfilters=1`。

## Bech32 发送支持

*在[系列][bech32 series]中的第 20 周，讨论如何让你支付的人获得 segwit 的所有好处。*

{% include specials/bech32/zh/20-percentage-loss.md %}

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选之一——或者在我们有空闲时间时帮助好奇或困惑的用户。在这个每月特刊中，我们精选自上次更新以来的一些最高票问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--why-does-the-importmulti-rpc-not-support-zpub-and-ypub-->**[为什么 `importmulti` RPC 不支持 zpub 和 ypub？]({{bse}}89261) Fontaine 问为什么 Bitcoin Core 的 `importmulti` RPC 支持 xpub 公钥派生格式，但不支持 ypub 或 zpub 格式。Pieter Wuille 解释说 xpub 格式是在 BIP32 中指定的，并用于生成当时最常见的 P2PKH 地址类型。Pieter 继续描述 Bitcoin Core 的[输出脚本描述符][descriptor]是生成地址的更可持续方法。

- **<!--is-bitcoin-pow-actually-sha256-merkle-tree-generation-->**[比特币的 PoW 实际上是 SHA256 加 Merkle 树生成吗？]({{bse}}89296) 用户 ascendzor 对矿工在 PoW 挖矿中需要重新计算 Merkle 根的后果感到疑惑，并且为什么 nonce 不能增加到 64 位。Pieter Wuille 解释说，不仅计算 Merkle 根的开销可以忽略不计，而且增加 nonce 大小将需要硬分叉。

- **<!--what-is-the-difference-between-bytes-and-virtual-bytes-vbytes-->**[字节和虚拟字节（vbytes）之间有什么区别？]({{bse}}89385) Ugam Kamat 和 Murch 指出了虚拟大小（vsize，以 vbytes 为单位）和大小（以字节为单位）之间的差异，并继续解释了区块重量限制和 segwit 折扣。

- **<!--to-what-extent-does-asymmetric-cryptography-secure-bitcoin-transactions-->**[非对称加密在多大程度上保障比特币交易安全？]({{bse}}89262) RedGrittyBrick 和 Pieter Wuille 解释说，尽管非对称加密并未用于防止比特币中的漏洞或攻击，但它是保障个人资金不被他人窃取的机制。

## 值得注意的代码和文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的变更。*

- [BIPs #800][] 更新了 [BIP174][]，指出钱包只能使用在部分签名比特币交易（PSBT）中请求的签名哈希（sighash）类型进行签名，前提是钱包认为该 sighash 类型提供了可接受的安全性。处理常见交易类型的大多数钱包应该拒绝 `SIGHASH_ALL` 之外的任何东西。

- [BIPs #766][] 为在[Newsletter #37][]中描述的 `addr` v2 提议分配了 [BIP155][]。此提案将允许节点相互分享它们的 Tor 隐藏服务（onion）版本 3 地址，并提供与其他网络地址协议的兼容性。

- [BIPs #643][] 添加了 [BIP301][]，讨论了盲合并挖矿，此前曾在 2017 年底的 Bitcoin-Dev 邮件列表中[讨论过][drivechain discussion]。盲合并挖矿旨在与称为“Drivechains”的去中心化侧链一起使用。与其他去中心化侧链提议类似，Drivechains 具有 SPV 安全性，这意味着拥有足够算力的矿工能够从侧链用户那里窃取资金。

- [C-Lightning #2842][] 当从通道对等节点收到“同步错误”时触发重连尝试，而不是导致通道失败。这是有意偏离[闪电网络规范][bolt1 error]的决定，因为 LND 节点似乎经常生成此错误，而 C-Lightning 维护者担心，如果 C-Lightning 按照规定的速率正确地导致通道失败，我们有可能导致网络分裂。

## 脚注

[^dns-query]:
    例如，我们在此查询一个具有完整链历史记录（`NODE_NETWORK`）和布隆过滤器支持（`NODE_BLOOM`）的服务位启用节点的 seed：

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
[drivechain discussion]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2017-December/015339.html
[core rc]: https://bitcoincore.org/bin/bitcoin-core-0.18.1/
[fidelity coinjoin]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-July/017169.html
[bitnodes dashboard]: https://bitnodes.earn.com/dashboard/
[sybil attack]: https://en.wikipedia.org/wiki/Sybil_attack
[bloom announce]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-July/017145.html
[signmessage bech32]: /zh/bech32-sending-support/#消息签名支持
[filter privacy]: https://jonasnick.github.io/blog/2015/02/12/privacy-in-bitcoinj/
[newsletter #43]: /zh/newsletters/2019/04/23/#basic-bip158-support-merged-in-bitcoin-core
[newsletter #56]: /zh/newsletters/2019/07/24/#bitcoin-core-16152
[newsletter #37]: /zh/newsletters/2019/03/12/#version-2-addr-message-proposed
[descriptor]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
