---
title: "Bitcoin Optech Newsletter #20"
permalink: /zh/newsletters/2018/11/06/
name: 2018-11-06-newsletter-zh
slug: 2018-11-06-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的 Newsletter 包含一个关于 C 语言实现的 bech32 地址解码的安全通知、分析了短暂减少的 segwit 区块数量、一个关于未来闪电网络（Lightning Network）支付特性的有趣讨论链接，以及在流行的比特币基础设施项目中一些值得注意的（Notable）代码变动。

## 行动项

- **<!--bech32-security-update-for-c-implementation-->****Bech32 安全更新用于 C 语言实现：**如果你使用的是 C 语言的 bech32 地址解码的[参考实现][bech32 c]，你需要[更新][bech32 patch]来修复一个潜在的溢出漏洞。其他参考实现不受影响；详细信息请参见下面的新闻部分。

## 新闻

- **<!--temporary-reduction-in-segwit-block-production-->****临时减少 segwit 区块产出：** Optech 调查了关于一个挖矿池停止产生包含 segwit 交易的区块的报道。我们发现 segwit 区块的数量在 10 月 20 日左右突然减少，并在几天前开始回升至正常水平。

    ![最近几周包含 segwit 交易的区块百分比](/img/posts/segwit-blocks-2018-11.png)

    这种突然的减少和回升可能是由一个小的配置错误引起的简单解释。默认情况下，Bitcoin Core 不产生包含 segwit 的区块，以保持与旧的 pre-segwit 挖矿软件的 [getblocktemplate][rpc getblocktemplate]（GBT）兼容性。当矿工更改软件或配置时，很容易忘记传递启用 segwit 的额外标志。为了说明这个错误有多容易犯，下面的示例调用了 GBT 的默认参数和其 segwit 参数——然后通过每个区块模板可以赚取的总潜在区块奖励（补贴 + 费用）来比较结果。

    ```bash
    $ ## GBT 默认参数
    $ bitcoin-cli getblocktemplate | jq '.coinbasevalue / 1e8'
    12.54348709

    $ ## GBT 启用 segwit
    $ bitcoin-cli getblocktemplate '{"rules": ["segwit"]}' | jq '.coinbasevalue / 1e8'
    12.56368175
    ```

    如您所见，如果这些示例区块模板中的一个被挖出，启用 segwit 的矿工将比非 segwit 矿工赚取更多的收入。尽管由于目前几乎为空的内存池，这在绝对数值上是一个小的差异（大约 0.02 BTC 或 100 美元），但从相对数值来看，包含 segwit 的示例区块模板比仅限旧版的模板收取的费用收入几乎多出 50%。由于预期挖矿将是一个利润微薄的商品服务，这似乎是足够的激励让矿工创建包含 segwit 的区块——并且随着越来越多的用户转向使用 segwit、区块补贴减少，以及可能的费用增加，这将变得更加重要。

    [Bitcoin Core 0.17.0.1][] 更新了 bitcoind 的内置 GBT 文档，提到需要启用 segwit，并且在开发者讨论中已经提议在未来的某个版本中默认启用 segwit GBT（但仍然提供向后兼容的选项来禁用它）。

- **<!--overflow-bug-in-reference-c-language-bech32-implementation-->****参考 C 语言 bech32 实现的溢出漏洞：** Trezor [公开披露][bech32 overflow blog]了他们在 C 编程语言的 bech32 地址函数的[参考实现][bech32 c]中发现的一个漏洞。已经发布了一个[补丁][bech32 patch]来修复这个漏洞。该漏洞不影响其他用其他编程语言编写的[参考实现][bech32 refs]的用户（[来源][achow bech32]）。

    当 Trezor 负责任地向多个其他项目披露这个漏洞时，他们从 Ledger 那里得知 [trezor-crypto][] 库中存在另一个漏洞，该库用于 Bitcoin Cash 风格的地址，这些地址与比特币 bech32 地址使用相同的基本结构。也为此发布了一个[补丁][cashaddr patch]。

- **<!--discussion-about-improving-lightning-payments-->****关于改进闪电网络支付的讨论：**在闪电网络（LN）协议开发者之间即将进行的会议之前，Rusty Russell 开启了一个[讨论][ln bolt11 ss]，关于他认为可能通过在 [Newsletter #16][] 中描述的无脚本脚本解决的两个问题。

    1. 一个发票最多只能支付一次。能够让多人支付同一个发票会很好，例如一个静态的捐赠发票或每月的重复支付。

    2. 协议不提供特定支出者的支付证明。您可以证明特定发票已经支付，并且该发票可以承诺应该支付它的人的身份，但是支付者和帮助将支付路由到接收者的节点都拥有关于支付的相同数据，因此他们中的任何一个都可以声称自己发送了支付。

[Newsletter #16]: /zh/newsletters/2018/10/09/

## Optech 推荐

如果你正在寻找有关闪电网络的更多新闻，可以查看 Rene Pickhardt 的新周刊，其中收集了关于 LN 以及人们正在使用它构建的内容的最佳推文。在 Twitter 上关注 [@renepickhardt][] 获取最新消息，并查看之前发布的期刊：[1][lwil41]、[2][lwil42] 和 [3][lwil43]。

## 值得注意的代码变更

本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-lightning][c-lightning repo] 和 [libsecp256k1][libsecp256k1 repo] 中的值得注意的代码变更。

- [Bitcoin Core #14454][] 为 [importmulti][rpc importmulti] RPC 增加了对 segwit 地址和脚本（P2WPKH、P2WSH 和包装 segwit 的 P2SH）的支持。新的 `witnessscript` 参数对 segwit 扮演的角色与 P2SH 的 `redeemscript` 参数相同。同时，[getaddressinfo][rpc getaddressinfo] RPC 添加了一个 `solvable` 参数，让用户知道钱包是否知道 P2SH 或 P2WSH 地址的 `redeemScript` 或 `witnessScript`，即它是否知道如何创建一个用于支付发送到该地址的付款的未签名输入。

- [LND #2027][] 添加了一个配置选项，允许节点拒绝以初始“推送”资金的方式开启新通道。这解决了商家偶尔遇到的一个问题，即不熟练的用户收到一个 [BOLT11][] 发票，需要支付一定金额，意识到他们没有开启通道，因此手动开启一个通道并进行了发票金额的初始支付。这种手动发起的支付与唯一的发票无关，因此用户不会收到他们试图购买的产品或服务，商家需要手动退款（如果他们能够退款）。通过这个 PR 提供的新配置选项，商家将能够自动阻止用户犯这种错误。

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
[bech32 refs]: //github.com/sipa/bech32/tree/master/ref/
[trezor-crypto]: https://github.com/trezor/trezor-crypto/
[cashaddr patch]: https://github.com/trezor/trezor-crypto/commit/2bbbc3e15573294c6dd0273d2a8542ba42507eb0
[ln bolt11 ss]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001489.html