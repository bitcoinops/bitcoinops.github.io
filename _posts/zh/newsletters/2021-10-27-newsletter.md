---
title: 'Bitcoin Optech Newsletter #172'
permalink: /zh/newsletters/2021/10/27/
name: 2021-10-27-newsletter-zh
slug: 2021-10-27-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报包含常规栏目：比特币 Stack Exchange 精选问答摘要、Taproot 激活准备指南、新版本与候选版本列表，以及主流比特币基础设施项目的显著变更说明。

## 新闻

*本周无重大新闻。*

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻求答案的首选之地——亦是我们抽空解答用户疑问的去处。本栏目每月精选自上次更新以来获票最高的问题与答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- ​**<!--where-to-find-the-exact-number-of-hashes-required-to-mine-most-recent-block-->**[如何获取最新区块的精确哈希计算次数？]({{bse}}110330)
  Pieter Wuille 指出，虽然区块的实际哈希尝试次数未公开，但使用难度值乘以 4,295,032,833 的公式可估算预期哈希次数。

- ​**<!--using-a-2-of-3-taproot-keypath-with-schnorr-signatures-->**[如何在 Taproot 密钥路径中使用 2/3 Schnorr 多签？]({{bse}}110249)
  Pieter Wuille 提到，尽管 [BIP340][] 要求单密钥单签名，但仍可使用 [FROST][frost whitepaper] 等[阈值签名][topic threshold signature]方案或 [MuSig][topic musig] 等[多签][topic multisignature]方案。

- ​**<!--why-coinbase-maturity-is-defined-to-be-100-and-not-50-->**[为何 coinbase 成熟度设定为 100 而非 50？]({{bse}}110085)
  用户 liorko 询问比特币 [coinbase 成熟度][se coinbase maturity]设定为 100 的原因。答案指出该选择可能具有未解释的任意性。

- ​**<!--why-does-bitcoin-use-double-hashing-so-often-->**[为何比特币频繁使用双重哈希？]({{bse}}110065)
  Pieter Wuille 列举了比特币初期采用 SHA256 双重哈希与 SHA256+RIPEMD160 组合的场景，推测中本聪可能误用这些方案以防御特定攻击。

## 准备 Taproot #19：未来的共识变化

*每周[系列][series preparing for taproot]，介绍开发者和服务提供商如何为即将在区块高度 {{site.trb}} 激活的 taproot 做准备。*

{% include specials/taproot/zh/19-future.md %}

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选版本。请考虑升级或协助测试候选版本。*

- [Rust-Lightning 0.0.102][] 发布，包含多项 API 改进并修复了与 LND 节点建立通道的缺陷。

- [C-Lightning 0.10.2rc1][] 候选版本[包含][decker tweet] [不经济输出安全漏洞][news170 unec bug]修复、数据库体积优化及 `pay` 命令效率提升（详见下文*显著变更*）。

## 值得注意的代码和文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案 (BIPs)][bips repo]和[闪电网络规范（BOLTs）][bolts repo]的显著变更。*

- [Bitcoin Core #23002][] 将[描述符][topic descriptors]钱包设为新建钱包的默认类型。描述符钱包首次引入于 [Bitcoin Core PR #16528][optech pr16528]，长期计划将[迁移所有钱包][Bitcoin Core #20160]并逐步弃用传统钱包。

- [Bitcoin Core #22918][] 扩展 `getblock` RPC 和 `/rest/block/` 端点，新增详细级别 `3`，包含区块中每个已花费输出的完整信息（"prevout"）。该功能通过解析撤销文件快速获取历史输出数据，但启用修剪的节点无法查询旧区块的此类信息。

- [C-Lightning #4771][] 优化 `pay` 命令，优先选择通道容量大的路径（假设通道状态概率均等时，大容量通道更可能承载大额支付）。

- [C-Lightning #4685][] 基于 [BOLTs #891][] 草案规范新增实验性 [websocket][] 传输层，允许节点通过替代端口进行对等通信（底层协议不变，仅改用二进制 websocket 帧）。

- [Eclair #1969][] 扩展 `findroute*` API，新增 `ignoreNodeIDs`、`ignoreChannelIDs`、`maxFeeMsat` 参数，并支持返回完整路由信息的 `full` 格式。

- [LND #5709][]（原 [#5549][lnd #5549]）为支持 Lightning Pool 的节点（目前仅 LND）新增承诺交易格式，防止通道出租方在租期内链上动用资金，激励其保持通道开放以赚取路由费（仅影响直接对等节点）。

- [LND #5346][] 支持节点间交换自定义消息（类型标识符高于 32,757），并更新 `lncli` 命令简化收发操作。

- [LND #5689][] 允许 LND 节点将私钥操作委托至远程离线「签名器」节点，[详细文档][lnd remote signing]已发布。

- [BTCPay Server #2517][] 新增通过闪电网络发放付款或退款功能，管理员可输入金额，接收方提供节点信息即可收款。

- [HWI #497][] 为 Trezor 设备提供额外信息验证多签联盟的找零地址，避免用户手动校验。


{% include references.md %}
{% include linkers/issues.md issues="23002,22918,4771,4685,1969,5709,5549,5346,5689,2517,497,891,20160" %}
[rust-lightning 0.0.102]: https://github.com/rust-bitcoin/rust-lightning/releases/tag/v0.0.102
[c-lightning 0.10.2rc1]: https://github.com/ElementsProject/lightning/releases/tag/v0.10.2rc1
[news123 pool]: /zh/newsletters/2020/11/11/#incoming-channel-marketplace
[websocket]: https://en.wikipedia.org/wiki/WebSocket
[prob path]: /zh/newsletters/2021/03/31/#paper-on-probabilistic-path-selection
[news170 unec bug]: /zh/newsletters/2021/10/13/#ln-spend-to-fees-cve
[decker tweet]: https://twitter.com/Snyke/status/1452260691939938312
[wiki difficulty]: https://en.bitcoin.it/wiki/Difficulty
[se coinbase maturity]: https://bitcoin.stackexchange.com/a/1992/87121
[frost whitepaper]: https://eprint.iacr.org/2020/852.pdf
[lnd remote signing]: https://github.com/guggero/lnd/blob/d43854aa34ca0c2d0dfa12b06f299def39b512fb/docs/remote-signing.md
[optech pr16528]: /zh/newsletters/2020/05/06/#bitcoin-core-16528
[series preparing for taproot]: /zh/preparing-for-taproot/
