---
title: 'Bitcoin Optech Newsletter #60'
permalink: /zh/newsletters/2019/08/21/
name: 2019-08-21-newsletter-zh
slug: 2019-08-21-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 记录了 Bitcoin Core 共识逻辑的变化，并宣布了 Optech 网站上用于追踪不同钱包和服务之间技术采用情况的新功能。此外，还包括我们常规的关于 Bech32 发送支持和流行比特币基础设施项目值得注意的变更部分。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- **<!--upgrade-to-c-lightning-0-7-2-1-->****升级到 C-Lightning 0.7.2.1：**此[版本][cl release]包含若干错误修复以及插件管理的新功能，并支持正在开发的测试网替代方案 Signet。

## 新闻

- **<!--hardcoded-previous-soft-fork-activation-blocks-->****硬编码先前软分叉激活的区块高度：**两个先前软分叉激活的区块高度现已被硬编码到 Bitcoin Core 中，作为这些分叉激活的时间点。这意味着任何超出这些区块的区块链重组都可能在具有此硬编码的节点与没有此硬编码的节点之间产生链分裂。然而，这样的重组需要的工作量证明大致等于当前所有活跃比特币矿工一年的总产出（以撰写时为准），因此被认为极不可能发生，并且即使发生也意味着一种可能阻碍共识形成的威胁。此次硬编码与几年前 [BIP90][] 硬编码类似，简化了 Bitcoin Core 的共识代码。有关更多信息，请参见[邮件列表帖子][buried post]或 [PR #16060][Bitcoin Core #16060]。

- **<!--new-optech-compatibility-matrix-->****新的 Optech 兼容性矩阵：**Optech 网站上的一个[新功能][compatibility matrix]显示了哪些钱包和服务支持某些推荐功能，目前包括可选的 Replace-by-Fee (RBF) 和 Segwit（未来计划添加更多比较）。该矩阵旨在帮助开发者评估功能支持的程度，并从早期采用者的设计中学习。详情请参见我们的[公告帖子][compat announce]。

## Bech32 发送支持

*这是关于让您支付的人能够访问 Segwit 全部优势的[系列][bech32 series]中的第 23 周，共 24 周。*

本周 Newsletter 的*新闻*部分介绍了 Optech 网站上的新功能。{% include specials/bech32/zh/23-compat.md %}

## 值得注意的代码和文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的变更。*

- [Bitcoin Core #16248][] 扩展了 Bitcoin Core 中的白名单配置选项，允许指定应向哪些 IP 地址或范围提供哪些服务。例如，此更改的动机是允许向特定的节点（如用户自己的轻量钱包）提供布隆过滤器，即使过滤器默认被禁用。这可以通过 `-whitelist=bloomfilter@1.2.3.4/32` 来实现。如果仅提供 IP 地址（即没有指定权限），行为与之前相同。

- [Bitcoin Core #16383][] 更改了接受 `include_watchonly` 参数的 RPC 命令，使其在禁用私钥的钱包（即仅作为观察钱包有用的钱包）中自动设置为 True。这确保了观察地址的结果包含在返回结果中。

- [Bitcoin Core #15986][] 扩展了 [Newsletter #34][news34 pr15368] 中描述的 `getdescriptorinfo` RPC，新增了 `checksum` 字段。此 RPC 已经会为任何不包含校验和的描述符添加校验和，但它也会通过移除私钥和其他用户可能不想要的更改来标准化描述符。此次合并新增的字段返回用户提供的描述符的校验和。描述符校验和遵循[输出脚本描述符][output script descriptor] 文档中描述的 `#` 字符后的格式。

- [Bitcoin Core #16060][] 添加了先前软分叉的硬编码区块高度，详情请参见[新闻部分描述][hc heights]。

- [LND #3391][] 总是返回相同的错误消息以避免泄露发票是否存在。有关信息泄露的更多详情，请参见 [BOLTs #516][] 和相关的 [BOLTs #608][]。

- [LND #3355][] 扩展了 `GetInfo` RPC，增加了一个 `SyncedToGraph` 布尔值，用于指示节点是否认为自己拥有最新的 gossip 信息，以便高效地进行支付路由。

{% include linkers/issues.md issues="16248,16383,15986,3391,516,608,3355,16060" %}
[bech32 series]: /zh/bech32-sending-support/
[buried post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-August/017266.html
[compat announce]: /zh/2019-compatibility-matrix/
[news34 pr15368]: /zh/newsletters/2019/02/19/#bitcoin-core-15368
[hc heights]: #hardcoded-previous-soft-fork-activation-blocks
[cl release]: https://github.com/ElementsProject/lightning/releases/tag/v0.7.2.1
[output script descriptor]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
