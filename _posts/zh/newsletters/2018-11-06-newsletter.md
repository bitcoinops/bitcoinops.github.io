---
title: "Bitcoin Optech Newsletter #20"
permalink: /zh/newsletters/2018/11/06/
name: 2018-11-06-newsletter-zh
slug: 2018-11-06-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的 Newsletter 包含：一则关于 C 语言版 bech32 地址解码实现的安全通知、一篇关于 segwit 区块数量暂时减少的分析、一个关于闪电网络（Lightning Network）支付未来特性的有趣讨论链接，以及若干热门比特币基础设施项目中值得注意的代码变更。

## 行动项

- **<!--bech32-security-update-for-c-implementation-->****C 语言实现的 Bech32 安全更新：** 如果你使用的是 C 语言 bech32 地址解码的[参考实现][bech32 c]，就需要[更新][bech32 patch]以修复一个潜在的溢出 bug。其他参考实现不受影响；详情请参见下面的新闻部分。

## 新闻

- **<!--temporary-reduction-in-segwit-block-production-->****segwit 区块产出暂时减少：** Optech 调查了一些报道，称某个矿池已停止产出包含 segwit 交易的区块。我们发现，segwit 区块的数量在 10 月 20 日前后突然减少，几天前开始回升到正常水平。

    ![最近几周包含 segwit 交易的区块百分比](/img/posts/segwit-blocks-2018-11.png)

    对这种突然的减少与回升，一个简单的解释可能是某处小小的配置错误。默认情况下，Bitcoin Core 不会产出包含 segwit 的区块，以保持 [getblocktemplate][rpc getblocktemplate]（GBT）与 segwit 之前的旧挖矿软件兼容。矿工更换软件或改动配置时，很容易忘记传入启用 segwit 的那个额外标志。为了说明这个错误有多容易犯，下面的例子分别用默认参数和 segwit 参数调用 GBT，再用每个区块模板能赚到的潜在区块奖励总额（补贴 + 手续费）来比较结果。

    ```bash
    $ ## GBT 默认参数
    $ bitcoin-cli getblocktemplate | jq '.coinbasevalue / 1e8'
    12.54348709

    $ ## GBT 启用 segwit
    $ bitcoin-cli getblocktemplate '{"rules": ["segwit"]}' | jq '.coinbasevalue / 1e8'
    12.56368175
    ```

    如你所见，如果上述示例区块模板中的任何一个真被挖出，启用 segwit 的矿工会比不启用 segwit 的矿工赚到更多收入。虽然由于目前内存池几乎是空的，这个差额按绝对值算很小（约 0.02 BTC，即 100 美元），但按相对值算，包含 segwit 的示例区块模板获得的手续费收入比仅支持旧式交易的模板几乎多出 50%。挖矿业预期会是一种利润微薄的大宗商品式服务，因此这似乎已足以激励矿工产出包含 segwit 的区块——而且随着越来越多的用户改用 segwit、区块补贴下降，以及手续费可能上涨，这一点只会越来越重要。

    [Bitcoin Core 0.17.0.1][] 更新了 bitcoind 的内置 GBT 文档，提到需要启用 segwit，并且在开发者讨论中已经提议在未来的某个版本中默认启用 segwit GBT（但仍然提供向后兼容的选项来禁用它）。

- **<!--overflow-bug-in-reference-c-language-bech32-implementation-->****C 语言 bech32 参考实现的溢出 bug：** Trezor [公开披露][bech32 overflow blog]了他们在 C 编程语言的 bech32 地址函数[参考实现][bech32 c]中发现的 bug，并已发布修复该 bug 的[补丁][bech32 patch]。该 bug 不影响其他用不同编程语言编写的[参考实现][bech32 refs]的用户（[来源][achow bech32]）。

    由于 Trezor 负责任地向多个其他项目披露了这个 bug，他们从 Ledger 处得知，[trezor-crypto][] 库中还有一个 bug，涉及 Bitcoin Cash 风格的地址——这类地址与比特币 bech32 地址使用相同的基本结构。针对该问题的[补丁][cashaddr patch]也已发布。

- **<!--discussion-about-improving-lightning-payments-->****关于改进闪电网络支付的讨论：** 在 LN 协议开发者即将召开的会议之前，Rusty Russell 发起了一个[讨论][ln bolt11 ss]，涉及他认为可以用 [Newsletter #16][] 中所述的无脚本脚本（scriptless scripts）解决的两个问题。

    1. 一张发票最多只能被支付一次。如果多个人能支付同一张发票就好了，例如静态的捐赠发票或按月定期支付。

    2. 协议不提供“某个特定付款方付了款”的证明。你可以证明某张发票已被支付，而该发票也可以承诺本应付款者的身份，但无论是付款方，还是帮助把支付路由到收款方的节点，都掌握着关于这笔支付的相同数据，因此其中任何一个都可以声称是自己发送的这笔支付。

## Optech 推荐

如果你还想看更多关于闪电网络的新闻，可以关注 Rene Pickhardt 新开设的每周推文精选，其中收集了关于 LN、以及人们正用 LN 构建什么的最佳推文。在 Twitter 上关注 [@renepickhardt][] 即可获取最新消息，也可以翻看此前的几期：[1][lwil41]、[2][lwil42] 和 [3][lwil43]。

## 值得注意的代码变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-lightning][core lightning repo] 和 [libsecp256k1][libsecp256k1 repo] 中值得注意的代码变更。*

- [Bitcoin Core #14454][] 让 [importmulti][rpc importmulti] RPC 支持 segwit 地址和脚本（P2WPKH、P2WSH 以及 P2SH 封装的 segwit）。新的 `witnessscript` 参数在 segwit 中扮演的角色，与 `redeemscript` 参数在 P2SH 中相同。此外，[getaddressinfo][rpc getaddressinfo] RPC 新增了 `solvable` 参数，让用户知道钱包是否知晓某个 P2SH 或 P2WSH 地址对应的 `redeemScript` 或 `witnessScript`，也就是它是否知道如何为花费发送到该地址的资金构造未签名输入。

- [LND #2027][] 添加了一个配置选项，允许节点拒绝以初始“推送”资金的方式开启新通道。这消除了商家偶尔遇到的一个问题：没有经验的用户收到一张金额若干的 [BOLT11][] 发票，发现自己没有已开立的通道，于是手动开通一个通道，并附带一笔等于发票金额的初始付款。这笔手动发起的付款与该唯一发票并无关联，因此用户拿不到本想购买的产品或服务，商家则只能手动退款（如果还能退的话）。启用这个 PR 所提供的新配置选项后，商家就能自动防止用户犯这个错误。

- [C-Lightning #2061][] 修复了如*新闻*部分所述的 bech32 解码溢出漏洞。

{% include references.md %}
{% include linkers/issues.md issues="14454,2027,2061" %}

[achow bech32]: https://twitter.com/achow101/status/1058370040368644097
[@renepickhardt]: https://twitter.com/renepickhardt
[lwil41]: https://twitter.com/i/moments/1051149970026442753
[lwil42]: https://twitter.com/i/moments/1051399582662443009
[lwil43]: https://twitter.com/i/moments/1055475460816228354

[bech32 c]: https://github.com/sipa/bech32/tree/master/ref/c
[bech32 patch]: https://github.com/sipa/bech32/commit/2b0aac650ce560fb2b2a2bebeacaa5c87d7e5938
[Bitcoin Core 0.17.0.1]: https://bitcoincore.org/en/releases/0.17.0.1/
[bech32 overflow blog]: https://blog.trezor.io/details-about-the-security-updates-in-trezor-one-firmware-1-7-1-5c34278425d8
[bech32 refs]: https://github.com/sipa/bech32/tree/master/ref/
[trezor-crypto]: https://github.com/trezor/trezor-crypto/
[cashaddr patch]: https://github.com/trezor/trezor-crypto/commit/2bbbc3e15573294c6dd0273d2a8542ba42507eb0
[ln bolt11 ss]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001489.html
[newsletter #16]: /zh/newsletters/2018/10/09/#多方-ecdsa-用于无脚本的闪电网络支付通道
[output script descriptor]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md