---
title: 'Bitcoin Optech Newsletter #188'
permalink: /zh/newsletters/2022/02/23/
name: 2022-02-23-newsletter-zh
slug: 2022-02-23-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周 Newsletter 总结了关于手续费追加与交易手续费赞助的讨论，描述了一项更新版 LN gossip 线路协议的提案，并宣传了一个用于测试 `OP_CHECKTEMPLATEVERIFY` 的 signet。此外，我们照例收录了 Bitcoin Stack Exchange 精选问答以及值得注意的比特币基础设施项目变更说明。

## 新闻

- **<!--fee-bumping-and-transaction-fee-sponsorship-->****手续费追加与交易手续费赞助：** 继几周前启动的 replace-by-fee（RBF）讨论（参见 [Newsletter #186][news186 rbf]）之后，本周 James O'Beirne [发起][obeirne bump]了关于手续费追加的讨论。O'Beirne 特别担心，一些正在被提议的交易中继策略变更会使用户和钱包开发者更难使用手续费追加。作为替代，他希望重新审视[交易手续费赞助][topic fee sponsorship]（此前在 [Newsletter #116][news116 sponsorship] 中介绍过）。

  这些想法在邮件列表上引发了大量讨论，许多回复提到了实现手续费赞助所面临的挑战。

- **<!--updated-ln-gossip-proposal-->****更新版 LN gossip 提案：** Rusty Russell 在 Lightning-Dev 邮件列表上[发布][russell gossip] 了一份详细提案，提出一套新的 LN gossip 消息，类似于他 2019 年在 [Newsletter #55][news55 gossip] 中描述的提案。新提案使用 [BIP340][] 形式的 [schnorr 签名][topic schnorr signatures]以及[仅 x 坐标公钥][news72 xonly]，并在现有 LN gossip 协议基础上做了许多简化。该协议用于广播可用于路由的公共通道信息；更新后的协议设计旨在最大化效率，尤其是在与类似 [erlay][topic erlay] 的基于 [minisketch][topic minisketch] 的高效 gossip 协议结合使用时。

- **<!--ctv-signet-->****CTV signet：** Jeremy Rubin [发布][rubin ctv signet]了启用 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] 的 [signet][topic signet] 参数和代码。这简化了对该提议 opcode 的公开实验，并使不同软件之间的兼容性测试更加容易。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是许多 Optech 贡献者寻找答案的首选之地——或在我们有空时帮助好奇或困惑用户的场所。在这一月度专栏中，我们重点介绍自上次更新以来获得高票的部分问答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--will-a-post-subsidy-block-with-no-transactions-include-a-coinbase-transaction-->**[补贴结束且无交易的区块是否仍会包含 coinbase 交易？]({{bse}}112193)
  Pieter Wuille 解释，每个区块都必须包含 coinbase 交易，而每笔交易必须至少包含一个输入和一个输出，因此即使一个区块没有区块奖励（无手续费且无补贴），仍需至少有一个零值输出。

- **<!--how-can-the-genesis-block-contain-arbitrary-data-on-it-if-the-script-is-invalid-->**[如果脚本无效，创世区块如何能包含任意数据？]({{bse}}112439)
  Pieter Wuille 列举了创世区块 coinbase 中 “Chancellor...” 文本推送有效的原因。首先，[创世区块][bitcoin se 13122]在定义上就是有效的；其次，coinbase 输入脚本从不执行；第三，对于非 taproot 输入，执行后栈中只剩一个元素的要求仅是策略规则，而非共识规则；最后，该策略规则仅适用于输入脚本与对应输出脚本共同执行后的最终栈，而 coinbase 交易的输入没有对应输出脚本，因此该策略不适用。Wuille 还指出，创世区块不可花费的原因与此讨论无关，而在于最初的 Bitcoin 软件[未将创世区块][bitcoin github genesis]写入其内部数据库。

- **<!--what-is-a-feeler-connection-when-is-it-used-->**[什么是 Feeler 连接？何时使用？]({{bse}}112247)
  用户 vnprc 解释了 Bitcoin Core 的 [feeler 连接][chaincode p2p]的作用。它是一条临时的出站连接，区别于默认的 8 条出站连接和 2 条仅区块出站连接。Feeler 连接用于测试来自 gossip 网络的潜在新节点，以及测试之前无法连接、但可能被逐出的节点。

- **<!--are-op-return-transactions-not-stored-in-chainstate-database-->**[OP_RETURN 交易不会存储在 chainstate 数据库中吗？]({{bse}}112312)
  Antoine Poinsot 指出，由于 `OP_RETURN` 输出是[不可花费的][bitcoin github unspendable]，因此不会存储在 [chainstate 目录][bitcoin docs data]中。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]中的值得注意的变更：*

- [Bitcoin Core #24307][] 为 `getwalletinfo` RPC 的结果对象扩展了 `external_signer` 字段。该字段指示钱包是否配置为使用外部签名器，例如硬件签名设备。

- [C-Lightning #5010][] 新增语言绑定生成工具 `MsgGen` 以及 Rust RPC 客户端 `cln-rpc`。`MsgGen` 解析 C-Lightning 的 JSON-RPC 架构，并生成 `cln-rpc` 使用的 Rust 绑定，以正确调用 C-Lightning 的 JSON-RPC 接口。

- [LDK #1199][] 添加了对 “phantom node payments” 的支持，即由多个节点中的任意一个接收的支付，可用于负载均衡。这需要创建带有 [BOLT11][] 路径提示的 LN 发票，这些提示指向同一个不存在的（“phantom”）节点。在每条路径中，到达 phantom 节点之前的最后一跳是真实节点，它知道 phantom 节点的密钥，可用于解密并重建[无状态发票][topic stateless invoices]（参见 [Newsletter #181][news181 rl1177]），从而接受该支付的 [HTLC][topic htlc]。

  {:.center}
  ![phantom 节点路径提示示意图](/img/posts/2022-02-phantom-node-payments.dot.png)

{% include references.md %}
{% include linkers/issues.md v=1 issues="24307,5010,1199," %}
[news186 rbf]: /zh/newsletters/2022/02/09/#discussion-about-rbf-policy
[obeirne bump]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019879.html
[news116 sponsorship]: /zh/newsletters/2020/09/23/#transaction-fee-sponsorship
[russell gossip]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-February/003470.html
[news72 xonly]: /zh/newsletters/2019/11/13/#taproot-review-discussion-and-related-information
[news55 gossip]: /zh/newsletters/2019/07/17/#gossip-update-proposal
[rubin ctv signet]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019925.html
[news181 rl1177]: /zh/newsletters/2022/01/05/#rust-lightning-1177
[bitcoin se 13122]: https://bitcoin.stackexchange.com/a/13123/87121
[bitcoin github genesis]: https://github.com/bitcoin/bitcoin/blob/9546a977d354b2ec6cd8455538e68fe4ba343a44/src/main.cpp#L1668
[chaincode p2p]: https://residency.chaincode.com/presentations/bitcoin/ethan_heilman_p2p.pdf#page=18
[bitcoin github unspendable]: https://github.com/bitcoin/bitcoin/blob/280a7777d3a368101d667a80ebc536e95abb2f8c/src/script/script.h#L539-L547
[bitcoin docs data]: https://github.com/bitcoin/bitcoin/blob/master/doc/files.md#data-directory-layout
