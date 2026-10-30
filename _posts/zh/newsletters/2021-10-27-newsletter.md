---
title: 'Bitcoin Optech Newsletter #172'
permalink: /zh/newsletters/2021/10/27/
name: 2021-10-27-newsletter-zh
slug: 2021-10-27-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本期 Newsletter 包含常规栏目：Bitcoin Stack Exchange 精选问答摘要、taproot 激活准备信息、新版本与候选发布列表，以及主流比特币基础设施项目的值得注意的变更说明。

## 新闻

*本周无重大新闻。*

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们有点空闲时帮助好奇或困惑用户的地方。在本月栏目中，我们精选自上次更新以来得票最高的一些问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--where-to-find-the-exact-number-of-hashes-required-to-mine-most-recent-block-->**[如何获取挖出最新区块所需的精确哈希次数？]({{bse}}110330)
  Pieter Wuille 指出，虽然一个区块尝试了多少次哈希并不会公开，但用 4,295,032,833 乘以该区块的[难度值][wiki difficulty]，就能简单地估算出解决一个区块所需的预期哈希次数。

- **<!--using-a-2-of-3-taproot-keypath-with-schnorr-signatures-->**[在 taproot 密钥路径中使用 2-of-3 的 schnorr 签名？]({{bse}}110249)
  Pieter Wuille 提到，尽管 [BIP340][] 要求 1 个密钥和 1 个签名，但仍可使用 [FROST][frost whitepaper] 等[阈值签名][topic threshold signature]方案、[MuSig][topic musig] 等[多重签名][topic multisignature]方案，以及其他方案。

- **<!--why-coinbase-maturity-is-defined-to-be-100-and-not-50-->**[为何 coinbase 成熟度设定为 100 而非 50？]({{bse}}110085)
  用户 liorko 询问，比特币的 [coinbase 成熟度][se coinbase maturity]期限为什么选择常数 100 而不是 50。回答指出，这一选择没有给出解释，而且可能是随意的。

- **<!--why-does-bitcoin-use-double-hashing-so-often-->**[为何比特币频繁使用双重哈希？]({{bse}}110065)
  Pieter Wuille 列举了比特币最初在哪里使用双重 SHA256 与 SHA256+RIPEMD160 两种双重哈希方案，指出哪些新特性沿用了同样的方案，并推测中本聪当初是误用这些双重哈希方案来缓解某些攻击。

## 准备 Taproot #19：未来的共识变更

*本[系列][series preparing for taproot]每周一篇，讨论开发者和服务提供商如何为 taproot 即将在区块高度 {{site.trb}} 激活做好准备。*

{% include specials/taproot/zh/19-future.md %}

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [Rust-Lightning 0.0.102][] 发布，包含多项 API 改进并修复了与 LND 节点建立通道的缺陷。

- [C-Lightning 0.10.2rc1][] 是候选发布，[包含][decker tweet] [不经济输出安全问题][news170 unec bug]的修复、更小的数据库体积，以及 `pay` 命令有效性的提升（详见下文*值得注意的变更*）。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]的值得注意的变更。*

- [Bitcoin Core #23002][] 在创建新钱包时把[输出脚本描述符（descriptor）][topic descriptors]钱包设为默认。基于描述符的钱包最早在 [Bitcoin Core PR #16528][optech pr16528] 中引入。目前有一项[长期计划][Bitcoin Core #20160]，要把所有钱包都迁移为基于描述符的形式，并最终停止支持传统钱包。

- [Bitcoin Core #22918][] 扩展 `getblock` RPC 和 `/rest/block/` 端点，新增详细级别 `3`，其中包含区块内每一笔被花费的、先前创建的输出（“prevout”）的信息。

  当一个区块创建新的未花费交易输出（UTXO）时，Bitcoin Core 会把它存入数据库。之后有交易试图花费该 UTXO 时，Bitcoin Core 会从数据库中取回它，并验证这次花费满足所有必需条件（例如为正确的公钥提供了有效签名）。如果区块中的每一笔花费都有效，Bitcoin Core 就会把这些 prevout 条目从 UTXO 数据库移入一个 *undo* 文件；若该区块日后在重组中被移出链，可以用这个文件把 UTXO 数据库恢复到先前的状态。

  这个 PR 会从 undo 文件中取回这些 prevout，并把它们纳入实际包含在区块中、或由区块内容计算得出的信息。对于需要 prevout 数据的用户和应用来说，这比直接查找每一笔先前交易及其输出要快得多，也方便得多。启用了修剪的完整节点会删除较旧的 undo 文件，因此对这些区块将无法使用新的详细级别 3。

- [C-Lightning #4771][] 更新 `pay` 命令，在其他条件相同时，优先选择包含资金总额较大（通道容量较大）通道的路径。通道中的资金总额是公开信息；不公开的是通道每个方向各有多少可用资金。不过，如果两条通道处于任意状态的概率[相同][prob path]，那么容量较大的通道比容量较小的通道更有可能处理得了该笔支付的金额。

- [C-Lightning #4685][] 基于 [BOLTs #891][] 中的草案规范，新增了一种实验性的 [websocket][] 传输方式。这让 C-Lightning（以及其他支持同一协议的 LN 实现）可以公布一个用于与对等节点通信的替代端口。底层的 LN 通信协议保持不变，只是改用二进制 websocket 帧而不是纯 TCP/IP 来传输。

- [Eclair #1969][] 为 `findroute*` 这组 API 调用新增了若干参数：`ignoreNodeIDs`、`ignoreChannelIDs` 和 `maxFeeMsat`。它还新增了 `full` 格式，用于返回关于所找到路由的全部已知信息。

- [LND #5709][]（原为 [#5549][lnd #5549]）新增一种承诺交易格式，供支持 Lightning Pool 的节点之间使用（参见 [Newsletter #123][news123 pool]），而目前这类节点只有 LND。新格式会阻止出租通道的节点在租期结束前在链上动用其资金。这就激励它们在租期内保持通道开放，以便用自己的资金（流动性）赚取路由费。通道打开期间，承诺交易的格式只有通道的两个直接对等节点看得到，因此无论采用哪种格式，都不会影响网络上的其他节点。

- [LND #5346][] 支持 LND 节点与其对等节点交换自定义消息——即类型标识符高于 32,767 的消息。PR 中给出了若干自定义消息的用途建议。`lncli` 命令也做了更新，以简化发送和监听对等节点自定义消息的操作。

- [LND #5689][] 允许 LND 节点把所有私钥操作委托给一个远程的、大部分时间离线的“签名器”节点。详细文档见[此处][lnd remote signing]。

- [BTCPay Server #2517][] 新增通过闪电网络发放付款或退款的功能。管理员可以输入要支付的金额，接收方随后填入自己的节点信息，就能收到这笔付款。

- [HWI #497][] 向使用 Trezor 固件的设备发送额外信息，使其能够验证某个找零地址属于某个多重签名联盟。否则 Trezor 会把找零显示为一笔单独的支付，需要用户手动核对自己的找零地址是否正确。


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
