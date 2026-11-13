---
title: 'Bitcoin Optech Newsletter #44'
permalink: /zh/newsletters/2019/04/30/
name: 2019-04-30-newsletter-zh
slug: 2019-04-30-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 又赶上新闻清淡的一周，但仍照例保留了 bech32 发送支持、Bitcoin Stack Exchange 精选问答，以及热门比特币基础设施项目中值得注意的变更这几个栏目。

{% include references.md %}

## 行动项

*截至写作时没有行动项。* 注意：如果 Bitcoin Core 发布团队确信上周分发的第四个[候选版本][0.18.0]中没有发现阻塞性问题，他们打算在本期 Newsletter 发布前后为 0.18.0 的正式版本打标签。若果真如此，我们会在下周的 Newsletter 中详细介绍这次发布。但如果你打算升级，也不必等我们——关于新版本你需要知道的一切都写在它的发行说明里；这些说明会随各平台（例如 [BitcoinCore.org][]）上的发布公告一并发布或给出链接。

## 新闻

*本周无新闻。希望大家享受一个美好的春天、秋天或旱季。*

## Bech32 发送支持

*第 7 周，共 24 周。在 2019 年 8 月 24 日 segwit 软分叉锁定满两周年之前，Optech Newsletter 每周都会包含这一栏目，提供信息帮助开发者和组织实现 bech32 发送支持——也就是能够向原生 segwit 地址付款。你[不需要自己实现 segwit][bech32 series]，但你付款的对象却能享受到 segwit 带来的种种好处。*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/zh/07-altbech32.md %}

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们有点空闲时帮助好奇或困惑用户的地方。在本月栏目中，我们精选自上次更新以来得票最高的一些问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{%
endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--do-htlcs-work-for-micropayments-->**[“HTLC 适用于小额支付吗？”]({{bse}}85650) David Harding 和 Gregory Maxwell 都指出，在支付被路由的过程中，某个输出的金额小到无法在链上花费，这本身就有风险。少于 546 聪的小额支付不会由 Bitcoin 网络中继。目前的缓解办法是让 LN 暂时把这类小额支付转为矿工手续费、而不是留作输出，其依据是博弈论：如果攻击者偷不到钱，就不会花钱去攻击。

- **<!--how-was-the-dust-limit-of-546-satoshis-was-chosen-why-not-550-satoshis-->**[546 聪的尘埃限制是怎么定下来的？为什么不是 550 聪？]({{bse}}86068) Bitcoin Core 的交易中继策略把 546 聪定为输出的最小金额，这个数字看着有些奇怪。Raghav Sood 解释说，546 是创建并花费一个 P2PKH 输出所需最低成本的三倍，并引用了 [2013 年的一次讨论][dust convo]。

- **<!--history-of-transactions-in-lightning-network-->**[闪电网络中的交易历史。]({{bse}}85901) 一位 LN 初学者问：用户在 LN 上进行的交易历史该如何保存？付款方又如何拿到付款证明？Mark H 回复说，LN 钱包需要为用户保存交易历史，并清楚地解释了提供给付款方的付款哈希如何最终引出付款原像的揭示，而该原像可作为付款证明。

- **<!--how-can-my-private-key-be-revealed-if-i-use-the-same-nonce-while-generating-the-signature-->**[如果在生成签名时使用相同的随机数，我的私钥怎么会暴露？]({{bse}}85638) Pieter Wuille 给出了详尽的回答：如果你熟悉公钥密码学所用的数学，就能看到他如何说明在这种情况下私钥是怎样泄露的。

- **<!--why-do-lightning-invoices-expire-->**[为什么闪电网络发票会过期？]({{bse}}85981) Rene Pickhardt 猜测，主要原因可能是收款量很大而存储能力相对有限的接收方会把存储或内存用尽。他给出的另一个原因是：如果一笔支付始终没有发起或完成，设个过期时间可以有个了结，不必一直悬着。David Harding 指出，传统企业会在发票上标明有效期，以免日后还要按当初报出的价格交货。

- **<!--are-there-still-miners-or-mining-pools-which-refuse-to-implement-segwit-->**[是否仍有矿工或矿池拒绝实现 SegWit？]({{bse}}86208) Mark Erhardt 给出了详尽的分析，说明答案基本上是“否”。过去一年的非空区块中，只有 0.03% 不含 SegWit 交易；而挖出这少数区块的两家主要矿工已在 2019 年证明，他们也在挖包含 SegWit 交易的区块。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和[比特币改进提案（BIPs）][bips repo] 中值得注意的变更。注意：除非另有说明，文中描述的 Bitcoin Core 合并都发生在它的 master 开发分支上；其中一些也可能被向后移植到待发布的版本。*

- [Bitcoin Core #14039][] 使 Bitcoin Core 拒绝两类交易：通过 RPC 提交的，以及通过 P2P 网络收到的——只要它们使用了 segwit 风格的扩展交易编码，却又不包含任何 segwit 输入。扩展交易编码包含 segwit 标记、segwit 标志和见证数据字段。传统输入中的签名并不承诺这些字段，因此在一笔完全由传统输入组成的交易里加上这些字段，只会造成（少量）带宽浪费。正因如此，[BIP144][] 规定不需要扩展格式的交易应使用传统格式。以前 Bitcoin Core 会接受格式不正确的交易，并在计算大小（权重）或中继给其他节点之前剥离掉不必要的 segwit 专属部分，将其规范化；现在它会直接拒绝接受格式不当的交易。

- [Bitcoin Core #15846][] 更新了节点：只要交易中有任一输出付款给 segwit 地址版本 1 至 16（这些版本预留给未来的协议升级），就接受该交易进入内存池，用于中继和打包。此前这类交易会被拒绝。在用户通过软分叉赋予这类地址特殊含义之前（类似 segwit 版本 0 地址对 P2WPKH 和 P2WSH 的特殊含义），发往未来版本地址的资金都不安全（任何矿工都能花掉）。这意味着如今不应有人使用版本 1 以上的地址。不过，如果有人真的创建了这样的地址，并让支持 segwit 的钱包或服务向它付款，这项改动能确保该交易像其他交易一样被中继和打包。（本 Newsletter 日后某一期的*bech32 发送支持*栏目会进一步深入讨论未来 segwit 版本的地址。）

- [Eclair #950][] 不再在每次节点断线时都发送通道禁用更新，而只在有人请求通过某个节点已断线的通道路由支付时才发送。这样就避免向网络通告那些根本没人想用的通道。该 PR 还对节点处理网络 gossip 的方式做了其他几处小改动，旨在减少不必要的流量。

{% include linkers/issues.md issues="14039,15846,950" %}
[0.18.0]: https://bitcoincore.org/bin/bitcoin-core-0.18.0/
[dust convo]: https://github.com/bitcoin/bitcoin/pull/2577#issuecomment-17738577
[bitcoincore.org]: https://bitcoincore.org/
[bech32 series]: /zh/bech32-sending-support/
[output script descriptors]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
