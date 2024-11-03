---
title: 'Bitcoin Optech Newsletter #305'
permalink: /zh/newsletters/2024/05/31/
name: 2024-05-31-newsletter-zh
slug: 2024-05-31-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报描述了一个用于静默支付的轻客户端协议提案，总结了两个新的 taproot 描述符提案，并链接到关于是否应在软分叉中添加具有重叠功能的操作码的讨论。此外还有我们的常规部分：其中包括 Bitcoin Stack Exchange 的精选问答、新版本和候选版本的公告，以及对热门比特币基础设施项目的重大变更介绍。

## 新闻

- **<!--Light-client-protocol-for-silent-payments-->用于静默支付的轻客户端协议：** Setor Blagogee 在 Delving Bitcoin 上[发布了][blagogee lcsp]了一份协议草案，描述了一种帮助轻量客户端接收[静默支付][topic silent payments] (SPs)的协议。通过添加一些密码原语，任何钱包软件都能够发送静默支付，但接收静默支付不仅需要这些原语，还需要访问每个兼容 SP 的链上交易信息。这对于已经处理每个链上交易的全节点（如 Bitcoin Core）来说很容易，但对于通常试图最小化请求的交易数据量的轻量客户端来说需要额外的功能。

  基本协议是由服务提供商构建一个针对每个区块的公钥索引，这些公钥可以与 SP 一起使用。客户端下载该索引和相应区块的[致密区块过滤器][topic compact block filters]。客户端计算每个密钥（或一组密钥）的本地调整值，并确定区块过滤器是否包含支付到其相应调整密钥的交易。如果包含，他们下载额外的区块级数据，以了解他们收到了多少付款以及如何以后花费这笔款项。

- **<!--Raw-taproot-descriptors-->原始 taproot 描述符：** Oghenovo Usiwoma 在 Delving Bitcoin 上[发布了][usiwoma descriptors]两个新的用于构建 [taproot][topic taproot] 花费条件的[描述符][topic descriptors]提案：

  - `rawnode(<hash>)` 接受 merkle 树节点的哈希值，无论是内部节点还是叶子节点。这使得钱包或其他扫描程序在不知道确切的 tapscripts 的情况下找到特定的输出脚本。在大多数情况下，这对于接收资金是不安全的————未知脚本可能不可花费或允许第三方花费资金————但在某些协议中是安全的。

    Anthony Towns 举了一个[例子][towns descriptors]，说明 Alice 希望 Bob 能继承她的钱；对于她的花费路径，她只给 Bob 原始节点哈希；对于他的继承路径，她给他一个模板化的描述符（可能包括一个时间锁，防止他在一段时间内花费）。这对 Bob 来说是安全的，因为钱不是他的，而且对 Alice 的隐私有好处，因为她不需要提前向 Bob 透露她的其他花费条件（尽管 Bob 可能会从 Alice 的链上交易中得知这些条件）。

  - `rawleaf(<script>,[version])` 类似于现有的用于包含无法用模板化描述符表达的脚本的 `raw` 描述符。其主要区别在于它包括了指出与 [BIP342][] 中指定的 [tapscript][topic tapscript] 默认值不同的 tapleaf 版本的能力。

  Usiwoma 的帖子提供了一个示例，并链接到之前的讨论和他创建的[参考实现][usiwoma poc]。

- **<!--Should-overlapping-soft-fork-proposals-be-considered-mutually-exclusive-->应该认为重叠的软分叉提案是相互排斥的吗？**
  Pierre Rochard [提问][rochard exclusive]，是否应认为在相似成本下能提供许多相同特性的软分叉提案是相互排斥的，是否有必要激活多个提案，让开发者使用他们偏爱的替代方案。

  Anthony Towns [回复][towns exclusive]了多个点，包括表示仅重叠特性本身不是问题，但如果没有人使用这些特性是因为每个人都喜欢替代方案，这可能会产生几个问题。他建议任何支持特定提案的人在预生产软件中测试其特性以了解它们，特别是与可以添加到比特币的其他方式进行比较。

## Bitcoin Stack Exchange 的精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 的贡献者们寻找答案的首选之地，也是他们有闲暇时会给好奇和困惑的用户帮忙的地方。在这个月度栏目中，我们会列举自上次出刊以来出现的一些高票的问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aa
nswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--what-s-the-smallest-possible-coinbase-transaction-block-size-->最小的 coinbase 交易/区块大小是多少？]({{bse}}122951)
  AAntoine Poinsot 解释了 coinbase 交易的最小限制，并得出当前区块高度下最小的有效比特币区块为 145 字节。

- [<!--understanding-script-s-number-encoding-cscriptnum-->理解脚本的数字编码，CScriptNum]({{bse}}122939)
  Antoine Poinsot 描述了 CScriptNum 如何在比特币的脚本中表示整数，提供了一些编码示例，并给出两个序列化实现的链接。

- [<!--is-there-a-way-to-make-a-btc-wallet-address-public-but-hide-how-many-btc-it-contains-->有没有办法公开 BTC 钱包地址但隐藏其包含的 BTC 数量？]({{bse}}122786)
  Vojtěch Strnad 指出，[静默支付][topic silent payments]的可复用支付地址允许发布一个公开的支付标识符，而观察者无法将支付给该标识符的交易关联起来。

- [<!--testing-increased-feerates-in-regtest-->在 regtest 中测试增加的费率]({{bse}}122837)
  在 regtest 中，Ava Chow 建议使用 Bitcoin Core 的测试框架，并设置 `-maxmempool` 为低值和 `-datacarriersize` 为高值，以帮助模拟高费率环境。

- [<!--why-is-my-p2p-v2-peer-connected-over-a-v1-connection-->为什么我的 P2P_V2 对等节点通过 v1 连接相连]({{bse}}122774)
  Pieter Wuille 推测是过时的对等节点地址信息导致用户看到支持 BIP324 [加密传输][topic v2 p2p transport]的对等节点通过 v1 非加密连接相连。

- [<!--does-a-p2pkh-transaction-send-to-the-hash-of-the-uncompressed-key-or-the-compressed-key-->P2PKH 交易是发送到未压缩公钥的哈希还是压缩公钥的哈希？]({{bse}}122875)
  Pieter Wuille 指出，压缩和未压缩的公钥都可以使用，产生不同的 P2PKH 地址，并补充说，P2WPKH 只允许使用压缩公钥，P2TR 使用[x-only 公钥][topic X-only public keys]。

- [<!--what-are-different-ways-to-broadcast-a-block-to-the-bitcoin-network-->广播区块到比特币网络的不同方式是什么？]({{bse}}122953)
  Pieter Wuille 概述了在 P2P 网络上宣布区块的四种方式：使用[BIP130][]、使用 [BIP152][]、发送[未请求的 `block` 信息][unsolicited `block` messages]以及较旧的 `inv` / `getdata` / `block` 消息流。

## 版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [LND v0.18.0-beta][] 是这个热门的 LN 节点实现的最新主要版本。根据其[发布说明][lnd rn]，添加了对 _入站路由费用_ 的实验性支持(见[周报 #297][news297 inbound])，现已提供[盲化路径][topic rv routing]的路径寻找，[暸望塔][topic watchtowers]现在支持[简单 taproot 通道][topic simple taproot channels]，并简化了发送加密调试信息的流程(见[周报 #285][news285 encdebug])，还增加了许多其他功能并修复了许多错误。

- [Core Lightning 24.05rc2][] 是这个热门的 LN 节点实现的下一个主要版本的候选版本。

## 重大的代码和文档变更

_本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。_

- [Bitcoin Core #29612][] 更新了通过 `dumptxoutset` RPC 输出的 UTXO 集转储的序列化格式，空间优化了17.4%。现在，`loadtxoutset` RPC 在加载 UTXO 集转储文件时需要新格式；不再支持旧格式。请见周报[#178][news178 txoutset]和[#72][news72 txoutset]以获取以前对 `dumptxoutset` 的参考。

- [Bitcoin Core #27064][] 更改了 Windows 上新安装的默认数据目录，从 `C:\Users\Username\AppData\Roaming\Bitcoin` 更改为 `C:\Users\Username\AppData\Local\Bitcoin`。

- [Bitcoin Core #29873][] 引入了对[拓扑限制直到确认(TRUC)][topic v3 transaction relay]交易 (v3 交易) 的 10 kvB 数据重量限制，以减少对[交易钉死][topic transaction pinning]攻击的缓解成本，提高区块模板构建效率，并对某些数据结构施加更严格的内存限制。v3 交易是一种具有附加规则的标准交易子集，设计用于在最小化克服交易钉死攻击成本的同时允许交易替换。见周报[#289][news289 v3]和[#296][news296 v3]来了解更多关于 v3 交易的信息。

- [Bitcoin Core #30062][] 在 `getrawaddrman` RPC 添加了两个新字段，`mapped_as` 和 `source_mapped_as`，这是一个返回对等节点网络地址信息的命令。新字段返回映射到对等节点及其来源的自治系统号（ASN），以提供哪些 ISP 控制哪些 IP 地址的大致信息，并增强 Bitcoin Core 对[日蚀攻击][topic eclipse attacks]的抵抗力。见周报[#52][news52 asmap]、[#83][news83 asmap]、[#101][news101 asmap]和[#290][news290 asmap]。

- [Bitcoin Core #26606][] 引入了 `BerkeleyRODatabase`，这是一个独立实现的 Berkeley 数据库（BDB）文件解析器，提供对 BDB 文件的只读访问。现在可以在不需要重型 BDB 库的情况下提取传统钱包数据，以简化迁移到[描述符][topic descriptors]钱包。`wallettool` 工具的 `dump` 命令改为使用 `BerkeleyRODatabase`。

- [BOLTs #1092][] 通过删除不再支持和未使用的功能 `initial_routing_sync` 和 `option_anchor_outputs` 来清理闪电网络（LN）规范。现在假定所有节点都具备三个功能：`var_onion_optin` 用于可变大小的[洋葱消息][topic onion messages]，以将任意数据中继到特定跳点，`option_data_loss_protect` 用于节点重新连接时发送其最新通道状态的信息，以及 `option_static_remotekey` 允许节点请求每个通道更新承诺以将节点的非 [HTLC][topic htlc] 资金发送到相同地址。对特定消息请求的`gossip_queries` 功能进行了更改，以便不支持该功能的节点不会被其他节点查询。见周报[#259][news259 cleanup]。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when="2024-06-04 14:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29612,27064,29873,30062,26606,1092" %}
[lnd v0.18.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.0-beta
[blagogee lcsp]: https://delvingbitcoin.org/t/silent-payments-light-client-protocol/891/
[usiwoma descriptors]: https://delvingbitcoin.org/t/tr-rawnode-and-rawleaf-support/901/
[towns descriptors]: https://delvingbitcoin.org/t/tr-rawnode-and-rawleaf-support/901/6
[usiwoma poc]: https://github.com/Eunovo/bitcoin/tree/wip-tr-raw-nodes
[rochard exclusive]:  https://delvingbitcoin.org/t/mutual-exclusiveness-of-op-codes/890/3
[towns exclusive]: https://delvingbitcoin.org/t/mutual-exclusiveness-of-op-codes/890/3
[lnd rn]: https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/release-notes-0.18.0.md
[core lightning 24.05rc2]: https://github.com/ElementsProject/lightning/releases/tag/v24.05rc2
[news297 inbound]: /zh/newsletters/2024/04/10/#lnd-6703
[news285 encdebug]: /zh/newsletters/2024/01/17/#lnd-8188
[unsolicited `block` messages]: https://developer.bitcoin.org/devguide/p2p_network.html#block-broadcasting
[news72 txoutset]: /en/newsletters/2019/11/13/#bitcoin-core-16899
[news178 txoutset]: /en/newsletters/2021/12/08/#bitcoin-core-23155
[news289 v3]: /zh/newsletters/2024/02/14/#bitcoin-core-28948
[news296 v3]: /zh/newsletters/2024/04/03/#bitcoin-core-29242
[news52 asmap]: /en/newsletters/2019/06/26/#differentiating-peers-based-on-asn-instead-of-address-prefix
[news83 asmap]: /en/newsletters/2020/02/05/#bitcoin-core-16702
[news101 asmap]: /en/newsletters/2020/06/10/#bitcoin-core-0-20-0
[news290 asmap]: /zh/newsletters/2024/02/21/#improved-reproducible-asmap-creation-process-asmap
[news259 cleanup]: /zh/newsletters/2023/07/12/#ln
