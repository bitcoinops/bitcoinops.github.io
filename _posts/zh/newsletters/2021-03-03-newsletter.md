---
title: 'Bitcoin Optech Newsletter #138'
permalink: /zh/newsletters/2021/03/03/
name: 2021-03-03-newsletter-zh
slug: 2021-03-03-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 介绍了关于替代 BIP70 支付协议部分功能的相关讨论，并概述了为谨慎日志合约（DLC）的欺诈证明交换制定标准方式的若干提案。此外还包括我们的固定栏目：新软件版本、可用的候选发布，以及热门比特币基础设施软件的值得注意的变更。

## 新闻

- **<!--discussion-about-a-bip70-replacement-->****关于 BIP70 替代方案的讨论：** Thomas Voegtlin 在 Bitcoin-Dev 邮件列表上发起了一个[讨论帖][voegtlin bip70 alt]，讨论如何替代 [BIP70][] 支付协议的部分功能，特别是接收已签名支付请求的能力。Voegtlin 希望能够证明：他支付的地址确实是由收款方（例如交易所）提供给他的地址。Charles Hill 和 Andrew Kozlik 分别回复了他们正在开发的协议。Hill 的[方案][hill scheme]旨在与 [LNURL][] 一起使用，但也可以改用于 Voegtlin 设想的场景。Kozlik 的[方案][kozlik scheme]在思路上更接近 BIP70，但不再使用 [X.509 证书][X.509 certificates]，并为基于交易所的币种互换（例如用 BTC 兑换其他币种，或反向操作）增加了新特性。

- **<!--fraud-proofs-in-the-v0-discreet-log-contract-dlc-specification-->****v0 版谨慎日志合约（DLC）规范中的欺诈证明：** Thibaut Le Guilly 在 DLC-dev 邮件列表上[发起讨论][le guilly post]，讨论在 v0 版 DLC 协调规范中纳入欺诈证明这一[目标][dlcv0 fraud proofs]。讨论涉及两类欺诈：

  - **<!--equivocation-->***模棱两可（equivocation）：* 指预言机（oracle）对同一事件签名多次，产生相互冲突的结果。模棱两可证明可由软件自动验证，无需信任第三方。

  - **<!--lying-->***撒谎（lying）：* 指预言机为用户明知有误的结果签名。这几乎总是依赖用户合约软件无法获取的证据，因此这类欺诈证明必须由用户手动验证，用户可将原始合约与预言机签名的结果进行比较。

  参与讨论的人似乎都倾向于提供模棱两可证明，但也有人担心这对 v0 规范来说工作量太大。作为折中方案，有人建议先专注于撒谎证明。等这类证明的格式确定之后，软件就可以针对同一预言机和同一事件使用两份独立证明，构造出模棱两可证明。

  关于撒谎证明的一项担忧是：用户可能被虚假证明刷屏，不得不浪费时间验证虚假证明，或者干脆放弃核查欺诈证明。反驳意见包括：可以从链上交易中取得证明的一部分（这要求有人支付过链上手续费）；此外，用户可以选择从何处下载欺诈证明，倾向于选择那些以只传播准确信息而著称的来源。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]中值得注意的变更。*

- [Bitcoin Core #16546][] 引入了一个新的签名器接口，允许 Bitcoin Core 通过 [HWI][topic hwi] 或实现了同一接口的其他应用，与外部硬件签名设备交互。

  自 [Bitcoin Core 0.18 版本][hwi release]起，Bitcoin Core 就能通过 HWI 与硬件签名器交互。然而在此 PR 之前，[该过程][hwi old process]需要使用命令行在 Bitcoin Core 和 HWI 之间传递数据。该 PR 让 Bitcoin Core 可以直接与 HWI 通信，从而简化了用户体验。此 PR 还附带了[完整文档][hwi new process]，说明如何配合 HWI 使用新的签名器接口。

  新的签名器接口目前只能通过 RPC 方法访问。一个[草案 PR][signer gui] 为 GUI 增加了对该签名器接口的支持，这样无需使用命令行，就能在 Bitcoin Core 中使用硬件签名器。

- [Rust-Lightning #791][] 增加了在启动时轮询 `BlockSource` 接口以同步区块和区块头的支持，并会在同步过程中检测分叉。正如 [Newsletter #135][news135 blocksource] 中所述，BlockSource 允许软件从标准 Bitcoin Core 兼容节点之外的数据源获取数据，这种冗余有助于防止[日食攻击][topic eclipse attacks]或其他安全问题。

- [Rust-Lightning #794][] 增加了对 [BOLT2][] 中 `option_shutdown_anysegwit` 特性的支持，该特性允许在发起关闭时使用未来的 segwit 版本。如果协商了 `option_shutdown_anysegwit`，通道一方在发送关闭消息以启动关闭时，可以发送用于收款的 scriptpubkey，只要该脚本符合标准的 [BIP141][] 见证程序格式：一个*版本字节*（`OP_1` 到 `OP_16` 的 1 字节 push 指令）后跟一个*见证程序*（2 到 40 字节的字节向量推送）。这些关闭脚本被限制为标准形式，以免手续费高昂的脚本或包含超大脚本的交易因不符合标准而无法传播。由于从 Bitcoin Core 0.19.0.1（2019 年 11 月发布）起，已[可以][0.19.0 segwit]中继发往任意 segwit 脚本的支付，现在把它们[纳入][bolts #672] LN 的标准形式是安全的。

- [HWI #413][]、[#469][hwi #469]、[#463][hwi #463]、[#464][hwi #464]、[#471][hwi #471]、[#468][hwi #468] 和 [#466][hwi #466] 大幅更新并扩充了 HWI 的文档。特别值得注意的变化包括：新增指向 [ReadTheDocs.io][hwi rtd] 上文档的链接、新增和更新的[示例][hwi examples]，以及一份新的[政策][hwi policy]，说明新设备必须满足哪些标准，HWI 才会考虑支持。

- [Rust Bitcoin #573][] 增加了一个新方法 `SigHashType::from_u32_standard`，确保所提供的 sighash 字节是 Bitcoin Core 默认中继和挖出的[标准值][sighash types]之一。每个签名的 sighash 字节指示交易中哪些部分需要签名。比特币的共识规则规定，非标准 sighash 值被视为等同于 `SIGHASH_ALL`，但这类值默认不会被中继或挖出，理论上可被用来欺骗使用链下承诺的软件，使其接受无法强制执行的支付。使用 Rust Bitcoin 的这类软件的开发者，或许应从接受任意共识有效 sighash 字节的 `SigHashType::from_u32` 方法改用这个新方法。

- [BIPs #1069][] 更新了 [BIP8][]，允许配置激活阈值，并根据最近一次 [taproot 激活讨论][news137 taproot activation]，把推荐值从 95% 下调至 90%。

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
