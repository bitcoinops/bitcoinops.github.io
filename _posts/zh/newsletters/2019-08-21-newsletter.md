---
title: 'Bitcoin Optech Newsletter #60'
permalink: /zh/newsletters/2019/08/21/
name: 2019-08-21-newsletter-zh
slug: 2019-08-21-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 指出 Bitcoin Core 共识逻辑的一处改动，并宣布 Optech 网站上一个用于追踪不同钱包和服务技术采用情况的新功能。此外，还包括我们常规的 bech32 发送支持部分，以及流行比特币基础设施项目中值得注意的变更。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- **<!--upgrade-to-c-lightning-0-7-2-1-->****升级到 C-Lightning 0.7.2.1：** 此[版本][cl release]包含若干错误修复，以及插件管理方面的新功能，并支持仍在开发中的测试网替代方案 signet。

## 新闻

- **<!--hardcoded-previous-soft-fork-activation-blocks-->****硬编码此前两次软分叉的激活区块高度：** 此前两次软分叉激活时所在区块的高度，现已被硬编码到 Bitcoin Core 中，作为这两次分叉激活的判定依据。这意味着任何回溯到这些区块之前的区块链重组，都可能让带有此硬编码的节点与不带此硬编码的节点之间发生链分裂。不过，这样的重组所需的工作量证明大致相当于（写作本文时）所有活跃比特币矿工一年的总产出，因此这被认为极不可能发生；而且这种情况本身就说明存在一种无论如何都会让共识无法形成的威胁。这次硬编码与几年前 [BIP90][] 的硬编码类似，简化了 Bitcoin Core 的共识代码。更多信息请参见[邮件列表帖子][buried post]或 [PR #16060][Bitcoin Core #16060]。

- **<!--new-optech-compatibility-matrix-->****新的 Optech 兼容性矩阵：** Optech 网站上的一个[新功能][compatibility matrix]展示哪些钱包和服务支持某些推荐功能，目前包括需主动启用的手续费替换（RBF）和隔离见证（今后计划加入更多比较项）。该矩阵旨在帮助开发者了解各项功能的支持程度，并从早期采用者的设计中学习。详情请参见我们的[公告帖子][compat announce]。

## Bech32 发送支持

*这是共 24 周的[系列][bech32 series]中的第 23 周，目的是让你支付的对象也能获得隔离见证的全部好处。*

本周 Newsletter 的*新闻*部分介绍了 Optech 网站上的新功能。{% include specials/bech32/zh/23-compat.md %}

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的变更。*

- [Bitcoin Core #16248][] 扩展了 Bitcoin Core 的白名单配置选项，允许指定应向不同 IP 地址或地址段提供哪些服务。例如，这项改动的动机之一是：即使布隆过滤器默认被禁用，也能向特定的对等节点（比如用户自己的轻量钱包）提供布隆过滤器。这可以通过 `-whitelist=bloomfilter@1.2.3.4/32` 实现。如果只给出 IP 地址（即没有指定任何权限），行为与之前相同。

- [Bitcoin Core #16383][] 修改了接受 `include_watchonly` 参数的 RPC 命令：对于禁用了私钥的钱包（即只能作为仅观察钱包使用），该参数会自动设为 True。这样就能确保仅观察地址的结果也被包含在返回结果中。

- [Bitcoin Core #15986][] 扩展了 [Newsletter #34][news34 pr15368] 中介绍的 `getdescriptorinfo` RPC，新增 `checksum` 字段。该 RPC 原本就会为任何未带校验和的输出脚本描述符补上校验和，但它同时也会规范化描述符：移除私钥，并做出用户可能不想要的其他改动。此次合并新增的字段则原样返回用户所提供描述符的校验和。按[输出脚本描述符][output script descriptor]文档所述，描述符的校验和跟在字符串末尾的 `#` 字符之后。

- [Bitcoin Core #16060][] 加入了此前软分叉的硬编码区块高度，如[新闻部分所述][hc heights]。

- [LND #3391][] 对失败的支付总是返回相同的错误消息，以免泄露发票是否存在。关于这一信息泄露的更多细节见 [BOLTs #516][]，另一处相关的泄露见 [BOLTs #608][]。

- [LND #3355][] 扩展了 `GetInfo` RPC，新增 `SyncedToGraph` 布尔字段，表示节点是否认为自己已掌握最新的 gossip 信息，从而能高效地为支付选择路由。

{% include linkers/issues.md issues="16248,16383,15986,3391,516,608,3355,16060" %}
[bech32 series]: /zh/bech32-sending-support/
[buried post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-August/017266.html
[compat announce]: /zh/2019-compatibility-matrix/
[news34 pr15368]: /zh/newsletters/2019/02/19/#bitcoin-core-15368
[hc heights]: #hardcoded-previous-soft-fork-activation-blocks
[cl release]: https://github.com/ElementsProject/lightning/releases/tag/v0.7.2.1
[output script descriptor]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
