---
title: 'Bitcoin Optech Newsletter #143'
permalink: /zh/newsletters/2021/04/07/
name: 2021-04-07-newsletter-zh
slug: 2021-04-07-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 包含定期栏目，其中包括新版本发布与候选发布的公告以及对流行的比特币基础设施项目所做的值得注意的更改。

## 新闻

*本周无值得报道的新闻。*

## 发布与候选发布

- [C-Lightning 0.10.0][C-Lightning 0.10.0] 是该闪电网络节点软件的最新主要版本。它对其 API 进行了多项增强，并包括对[双向资助][topic dual funding] 的实验性支持。

- [BTCPay 1.0.7.2][BTCPay 1.0.7.2] 修复了在上周安全发布后发现的一些小问题。

## 值得注意的代码和文档更改

*本周值得注意的更改发生在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]。*

- [Bitcoin Core #20286][] 从 `gettxout`、`getrawtransaction`、`decoderawtransaction`、`decodescript`、`gettransaction` 这些 RPC 方法的响应中，以及从 `/rest/tx`、`/rest/getutxos`、`/rest/block` 这些 REST 端点中移除了 `addresses` 和 `reqSigs` 字段。当存在明确定义的地址时，响应中现在包括可选字段 `address`。这些已弃用的字段之前用于裸多重签名场景，而这在当今网络中已无实质用途。在 Bitcoin Core 23.0 移除该选项之前，这些已弃用的字段仍可通过配置选项 `-deprecatedrpc=addresses` 输出。

- [Bitcoin Core #20197][] 通过更新入站节点剔除逻辑改善了节点连接的多样性，以保护运行时间最长的 onion 节点。它还为当前的剔除保护逻辑增加了单元测试覆盖率。由于 onion 节点的延迟通常高于 IPv4 和 IPv6 节点，它们在剔除条件下一直处于不利地位，导致用户提交了[多个][Bitcoin Core #11537][问题][Bitcoin Core #19500]。最初的应对措施[news114 core19670] 为本地主机节点预留了插槽，以此作为 onion 节点的代理。后来又添加了[对入站 onion 连接的显式检测][news118 core19991]。

通过更新后的逻辑，一半的保护插槽分配给任何 onion 和本地主机节点，其中 onion 节点优先于本地主机节点。现在 Bitcoin Core 已支持 I2P 隐私网络（参见 [Newsletter #139][news139 i2p]），下一步将是将剔除保护扩展至 I2P 节点，因为它们的延迟通常比 onion 节点更高。

- [Eclair #1750][] 移除了对 Electrum 的支持以及相应的 10,000 行代码。Electrum 先前曾被 Eclair 用于移动端钱包。然而，一个新的实现 [Eclair-kmp][eclair-kmp github] 现在被推荐用于移动端钱包，这使得 Eclair 不再需要对 Electrum 的支持。

- [Eclair #1751][] 为 `payinvoice` 命令添加了一个 `blocking` 选项，使对 `payinvoice` 的调用在支付完成之前处于阻塞状态。此前，用户必须通过低效地轮询 `getsentinfo` API 才能得知支付何时完成。


{% include references.md %}
{% include linkers/issues.md issues="20286,20197,1750,1751,19500,11537,19670,19991" %}
[c-lightning 0.10.0]: https://github.com/ElementsProject/lightning/releases/tag/v0.10.0
[btcpay 1.0.7.2]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.0.7.2
[news139 i2p]: /zh/newsletters/2021/03/10/#bitcoin-core-20685
[news114 core19670]: /zh/newsletters/2020/09/09/#bitcoin-core-19670
[news118 core19991]: /zh/newsletters/2020/10/07/#bitcoin-core-19991
[eclair-kmp github]: https://github.com/ACINQ/eclair-kmp
