---
title: 'Bitcoin Optech Newsletter #143'
permalink: /zh/newsletters/2021/04/07/
name: 2021-04-07-newsletter-zh
slug: 2021-04-07-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 包含我们的固定栏目：新版本与候选发布的公告，以及热门比特币基础设施项目值得注意的代码与文档变更。

## 新闻

*本周无值得报道的新闻。*

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [C-Lightning 0.10.0][C-Lightning 0.10.0] 是该闪电网络节点软件的最新主要版本。它对其 API 做了多项增强，并包含对[双向资助][topic dual funding] 的实验性支持。

- [BTCPay 1.0.7.2][BTCPay 1.0.7.2] 修复了在上周安全发布后发现的一些小问题。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]中值得注意的变更。*

- [Bitcoin Core #20286][] 从 `gettxout`、`getrawtransaction`、`decoderawtransaction`、`decodescript`、`gettransaction` 这些 RPC 方法的响应中，以及从 `/rest/tx`、`/rest/getutxos`、`/rest/block` 这些 REST 端点中移除了 `addresses` 和 `reqSigs` 字段。当存在明确定义的地址时，响应中改为包含可选字段 `address`。这些已弃用的字段此前用于裸多重签名（bare multisig）场景，而这类用法在当今网络中已无实质用途。在 Bitcoin Core 23.0 移除该选项之前，这些已弃用的字段仍可通过配置选项 `-deprecatedrpc=addresses` 输出。

- [Bitcoin Core #20197][] 通过更新入站对等节点的剔除逻辑，改善了对等节点连接的多样性，以保护运行时间最长的 onion 对等节点。它还为当前的剔除保护逻辑补充了单元测试。由于 onion 对等节点的延迟通常高于 IPv4 和 IPv6 对等节点，它们按剔除标准一直处于劣势，导致用户提交了[多个][Bitcoin Core #11537][问题][Bitcoin Core #19500]。[最初的应对措施][news114 core19670]是为本地主机对等节点预留槽位，以此作为 onion 对等节点的替代。后来又增加了[对入站 onion 连接的显式检测][news118 core19991]。

采用更新后的逻辑，一半的保护槽位会分配给 onion 与本地主机对等节点，其中 onion 对等节点优先于本地主机对等节点。Bitcoin Core 现已支持 I2P 隐私网络（参见 [Newsletter #139][news139 i2p]），下一步是把剔除保护扩展到 I2P 对等节点，因为它们的延迟通常高于 onion 对等节点。

- [Eclair #1750][] 移除了对 Electrum 的支持以及相应的 10,000 行代码。Electrum 此前曾被 Eclair 用于移动端钱包。不过，现在推荐移动端钱包使用新的实现 [Eclair-kmp][eclair-kmp github]，因此 Eclair 已不再需要支持 Electrum。

- [Eclair #1751][] 为 `payinvoice` 命令添加了一个 `blocking` 选项，使 `payinvoice` 调用会阻塞到支付完成。此前，用户不得不低效地轮询 `getsentinfo` API，才能知道支付何时完成。


{% include references.md %}
{% include linkers/issues.md issues="20286,20197,1750,1751,19500,11537,19670,19991" %}
[c-lightning 0.10.0]: https://github.com/ElementsProject/lightning/releases/tag/v0.10.0
[btcpay 1.0.7.2]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.0.7.2
[news139 i2p]: /zh/newsletters/2021/03/10/#bitcoin-core-20685
[news114 core19670]: /zh/newsletters/2020/09/09/#bitcoin-core-19670
[news118 core19991]: /zh/newsletters/2020/10/07/#bitcoin-core-19991
[eclair-kmp github]: https://github.com/ACINQ/eclair-kmp
