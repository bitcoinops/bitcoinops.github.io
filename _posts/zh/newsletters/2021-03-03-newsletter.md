---
title: 'Bitcoin Optech Newsletter #138'
permalink: /zh/newsletters/2021/03/03/
name: 2021-03-03-newsletter-zh
slug: 2021-03-03-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了希望替代 BIP70 支付协议部分功能的相关讨论，并总结了为 Discreet Log Contracts（DLCs）交换欺诈证明进行标准化的方法提议。还包括我们定期的部分，介绍新的软件发布、可用的候选发布以及对流行比特币基础设施软件中值得注意的更改。

## 新闻

- **<!--discussion-about-a-bip70-replacement-->****关于 BIP70 替代方案的讨论：** Thomas Voegtlin 在 Bitcoin-Dev 邮件列表上发起了一个[话题][voegtlin bip70 alt]，讨论对 [BIP70][] 支付协议部分功能（特别是接收已签名支付请求的能力）进行替代的方案。Voegtlin 希望能够证明他支付的地址确实是由收款方（例如交易所）提供的地址。Charles Hill 和 Andrew Kozlik 分别回复了他们正在研究的协议。Hill 的[方案][hill scheme]旨在与 [LNURL][] 一起使用，但可以重新用于 Voegtlin 的预期用例。Kozlik 的[方案][kozlik scheme]在精神上更接近 BIP70，但不再使用 [X.509 证书][X.509 certificates]，并为基于交易所的币种互换（例如 BTC 与其他币种的互换）添加了新特性。

- **<!--fraud-proofs-in-the-v0-discreet-log-contract-dlc-specification-->****v0 版 Discreet Log Contract (DLC) 规范中的欺诈证明：** Thibaut Le Guilly 在 DLC-dev 邮件列表上[发起讨论][le guilly post]，讨论在 [DLCv0 欺诈证明][dlcv0 fraud proofs]目标中包含欺诈证明。讨论了两种类型的欺诈：

  - **<!--equivocation-->***多重证明（equivocation）：* 当预言机（oracle）为同一事件多次签名，从而产生相互冲突的结果。多重证明可由软件自动验证，无需第三方信任。

  - **<!--lying-->***撒谎（lying）：* 当预言机为用户明知错误的结果签名。这几乎总是依赖于用户合约软件无法获取的证据，因此这种欺诈证明必须由用户手动验证，用户需要将原始合约与预言机签名的结果进行比较。

  参与讨论的人员似乎都倾向于提供多重证明，但有人担心这对 v0 规范来说工作量太大。作为中间解决方案，有人建议先专注于撒谎证明。当这些证明的格式确定后，软件就可以针对同一预言机和事件使用两份独立证明来构建多重证明。

  关于撒谎证明的一个担忧是，用户可能会被假证明垃圾信息轰炸，迫使用户要么浪费时间验证假的欺诈证明，要么完全放弃检查欺诈证明。反对意见包括可以从链上交易中获取证明的一部分（这需要有人支付链上费用），以及用户可以选择他们从哪里下载欺诈证明，倾向于从以传播准确信息而闻名的来源获取。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo] 中的值得注意的更改。*

- [Bitcoin Core #16546][] 引入了一个新的签名器接口，允许 Bitcoin Core 通过 [HWI][topic hwi] 或实现相同接口的其他应用与外部硬件签名设备交互。

  自 Bitcoin Core 0.18 版本起，Bitcoin Core 就能够使用 HWI 连接硬件签名器（[参考 HWI 发行版][hwi release]）。然而在此 PR 之前，[该过程][hwi old process]需要使用命令行在 Bitcoin Core 和 HWI 之间传输数据。该 PR 简化了用户体验，使 Bitcoin Core 可以直接与 HWI 通信。此 PR 包含了[完整文档][hwi new process]，说明如何结合 HWI 使用新的签名器接口。

  新的签名器接口目前仅可通过 RPC 方法访问。[一个草案 PR][signer gui] 为 GUI 添加了对签名器接口的支持，从而无需使用命令行就可在 Bitcoin Core 中使用硬件签名器。

- [Rust-Lightning #791][] 在启动时增加了对轮询 `BlockSource` 接口以同步区块和区块头的支持，并在同步中检测分叉。正如在 [Newsletter #135][news135 blocksource] 中所述，BlockSource 允许软件从非标准 Bitcoin Core 节点的数据源获取数据，从而在冗余层面帮助防止[日蚀攻击（eclipse attacks）][topic eclipse attacks]或其他安全问题。

- [Rust-Lightning #794][] 为 [BOLT2][] 的 `option_shutdown_anysegwit` 特性提供支持，该特性在关闭时允许使用未来的 segwit 版本。如果协商了 `option_shutdown_anysegwit`，则通道一方在发送关闭消息以启动关闭时，可发送一个支付用的 scriptpubkey，只要该脚本符合标准的 [BIP141][] 见证程序格式：一个版本字节（`OP_1` 到 `OP_16` 的 1 字节 push 指令）后跟一个见证程序字节向量（长度为 2 到 40 字节的推送）。这些关闭脚本限制为标准格式，以避免由于非标准而无法传播的高费用复杂脚本或超大脚本的交易。由于在 Bitcoin Core 0.19.0.1（2019 年 11 月发布）[可以][0.19.0 segwit]为任何 segwit 脚本转发支付，现在在 LN 的标准格式中安全[包含它们][bolts #672]。

- [HWI #413][]、[#469][hwi #469]、[#463][hwi #463]、[#464][hwi #464]、[#471][hwi #471]、[#468][hwi #468] 和 [#466][hwi #466] 显著更新并扩展了 HWI 的文档。特别值得注意的变化包括在 [ReadTheDocs.io][hwi rtd] 上提供的文档链接、新的和更新的[示例][hwi examples]，以及描述 HWI 考虑支持新设备标准的[政策][hwi policy]。

- [Rust Bitcoin #573][] 增加了一个新的方法 `SigHashType::from_u32_standard`，确保所提供的 sighash 字节是 Bitcoin Core 默认中继和打包的[标准值][sighash types]之一。每个签名的 sighash 字节指示需要签名的交易部分。比特币的共识规则规定非标准 sighash 值被视为等同于 `SIGHASH_ALL`，但由于默认情况下不中继或打包非标准值，理论上可以用来欺骗使用链下承诺的软件，从而接受不可强制执行的支付。使用 Rust Bitcoin 的开发者可能希望从接受任意共识有效 sighash 字节的 `SigHashType::from_u32` 方法转为使用此新方法。

- [BIPs #1069][] 更新了 [BIP8][]，允许配置激活阈值，并基于最近的 [taproot 激活讨论][news137 taproot activation]将推荐值从 95% 降至 90%。

{% include references.md %}
{% include linkers/issues.md issues="16546,573,791,794,413,469,463,464,471,468,466,1069,672" %}
[voegtlin bip70 alt]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-February/018443.html
[lnurl]: https://github.com/fiatjaf/lnurl-rfc
[hill scheme]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-February/018446.html
[kozlik scheme]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-February/018448.html
[le guilly post]: https://mailmanlists.org/pipermail/dlc-dev/2021-February/000020.html
[dlcv0 fraud proofs]: https://github.com/discreetlogcontracts/dlcspecs/blob/master/v0Milestone.md#simple-fraud-proofs-in-progress
[hwi old process]: https://github.com/bitcoin-core/HWI/blob/7b34fc72c5b2c5af216d8b8d5cd2d2c92b6d2457/docs/examples/bitcoin-core-usage.rst
[hwi release]: /zh/newsletters/2019/05/07/#basic-hardware-signer-support-through-independent-tool
[hwi new process]: https://github.com/bitcoin/bitcoin/blob/master/doc/external-signer.md
[signer gui]: https://github.com/bitcoin-core/gui/pull/4
[hwi rtd]: https://hwi.readthedocs.io/en/latest/?badge=latest
[hwi examples]: https://hwi.readthedocs.io/en/latest/examples/index.html
[hwi policy]: https://hwi.readthedocs.io/en/latest/devices/index.html#support-policy
[X.509 certificates]: https://en.wikipedia.org/wiki/X.509
[sighash types]: https://btcinformation.org/en/developer-guide#signature-hash-types
[news137 taproot activation]: /zh/newsletters/2021/02/24/#taproot-activation-discussion
[news135 blocksource]: /zh/newsletters/2021/02/10/#rust-lightning-774
[0.19.0 segwit]: https://bitcoincore.org/en/releases/0.19.0.1/#mempool-and-transaction-relay
