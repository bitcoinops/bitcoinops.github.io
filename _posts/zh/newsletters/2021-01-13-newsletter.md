---
title: 'Bitcoin Optech Newsletter #131'
permalink: /zh/newsletters/2021/01/13/
name: 2021-01-13-newsletter-zh
slug: 2021-01-13-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了一个新的比特币 P2P 协议消息提议、一份关于 bech32 修改版地址格式的 BIP，以及一个防止在提议的双向资助 LN 通道中进行 UTXO 探测的想法。此外，还包括我们常规的栏目：Bitcoin Core PR 审查俱乐部会议摘要、发布与候选发布列表，以及热门比特币基础设施软件值得注意的变更介绍。

## 新闻

- **<!--proposed-disabletx-message-->****提议的 `disabletx` 消息：** 2012 年发布的 [BIP37][] 让轻量级客户端能够请求对等节点在客户端加载[布隆过滤器][topic transaction bloom filtering]之前，不要向它中继任何未确认交易。Bitcoin Core [后来][bitcoin core #6993]把这套机制复用到节省带宽的 `-blocksonly` 模式中：节点请求对等节点完全不发送任何未确认交易。去年，Bitcoin Core 在默认设置下开始建立少量仅中继区块的连接，作为提高[日食攻击][topic eclipse attacks]抵抗能力的高效手段，同时不会显著增加带宽或降低隐私（见 [Newsletter #63][news63 bcc15759]）。然而，用来抑制交易中继的 BIP37 机制允许发起节点随时请求完整的交易中继。交易中继会消耗内存、带宽等节点资源，因此节点在设置连接上限时，必须假设每一条基于 BIP37 的低带宽仅中继区块连接都可能突然变成完整的交易中继连接。

  本周，Suhas Daftuar 在 Bitcoin-Dev 邮件列表中[发布][daftuar disabletx]了一份新的 BIP 提议，提出可在连接协商期间发送的 `disabletx` 消息。理解该消息、并落实该 BIP 全部建议的对等节点，不会向请求 `disabletx` 的节点发送任何交易公告，也不会向该节点请求任何交易；它也不会发送另一些 gossip 消息，例如用于公布 IP 地址的 `addr` 消息。`disabletx` 的协商结果在连接的整个生命周期内有效，这让对等节点可以对禁用中继的连接采用不同的限制，例如在现有 125 个连接上限之外再多接受一些连接。

- **<!--bech32m-->****bech32m：** Pieter Wuille 在 Bitcoin-Dev 邮件列表中[发布][wuille bech32m post]了一份 [BIP 草案][bech32m bip]，提出一种修改版的 [bech32][topic bech32] 地址编码，提高了检出这类 *bech32m* 地址中意外增加或删除字符的几率。如果该提案没有发现问题，预计 bech32m 地址将用于 [taproot][topic taproot] 地址，也可能用于未来新的脚本升级。实现向 bech32m 地址付款支持的钱包和服务，将自动支持向所有这些未来改进的地址付款（详情见 [Newsletter #45][news45 bech32 upgrade]）。

- **<!--ln-dual-funding-anti-utxo-probing-->****LN 双向资助防 UTXO 探测：** LN 的一个长期目标是双向资助，即用发起通道的节点和收到请求的对等方双方的资金来开设新通道。这样一来，通道完全打开后，支付就可以朝任一方向流动。在发起方签署双向资助交易之前，它需要知道另一方想加入该交易的全部 UTXO 的标识（outpoint）。这就带来一种风险：滥用者可能与许多不同用户发起双向资助通道，摸清他们的 UTXO，然后拒绝签署注资交易——在自身毫无成本的情况下损害这些用户的隐私。

  本周，Lloyd Fournier 在 Lightning-Dev 邮件列表中[发布][fournier podle]了对以往两个应对方案的评估：[一个][zmn podle]使用离散对数等价性证明（PoDLE，见 [Newsletter #83][news83 podle]），[另一个][darosior sighash]使用带 `SIGHASH_SINGLE|SIGHASH_ANYONECANPAY` 半签名的双向资助交易。Fournier 扩展了先前的半签名提案，然后提出了自己的方案：效果相当，但更简单。新方案让发起方创建并签署（但不广播）一笔把自己的 UTXO 花回给自己的交易，再把这笔交易交给另一方作为诚信证明——如果发起方后来不肯签署真正的注资交易，应答方就可以广播这笔诚信交易，迫使发起方支付一笔链上手续费。Fournier 在帖子末尾总结了各种方法之间的权衡。

## Bitcoin Core PR 审查俱乐部

*在本月度栏目中，我们总结最近一次 [Bitcoin Core PR 审查俱乐部][Bitcoin Core PR Review Club]会议，重点介绍一些重要的问题和答案。点击下面的问题可以查看会议中答案的摘要。*

[为节点驱逐逻辑添加单元测试][review club #20477]是匿名贡献者 practicalswift 提交的一个 PR（[#20477][Bitcoin Core #20477]），旨在提高 Bitcoin Core 在节点入站连接槽位已满时驱逐对等节点逻辑的测试覆盖率。必须小心，避免这套逻辑使节点暴露在攻击者触发的网络分区之下。

大部分讨论集中在理解 Bitcoin Core 的对等节点驱逐逻辑上。

{% include functions/details-list.md
  q0="**<!--q0-->**入站还是出站对等节点选择：哪一个是抵御日食攻击的主要防线？"
  a0="出站对等节点选择，因为相比我们接受的入站连接，攻击者对我们选择哪些出站对等节点的影响力更小。驱逐入站对等节点是第二层保护——而且并非所有节点都接受入站连接。"
  a0link="https://bitcoincore.reviews/20477#l-77"

  q1="**<!--q1-->**Bitcoin Core 为什么要驱逐入站连接？"
  a1="为了让网络中的诚实对等节点有空出的入站槽位，使新节点能够与它们建立良好的出站连接。否则，不诚实的节点就更容易攻击新节点：它们既可以为新节点的出站连接提供服务，又尽可能多地占满入站槽位。"
  a1link="https://bitcoincore.reviews/20477#l-66"

  q2="**<!--q2-->**需要腾出一个槽位时，Bitcoin Core 如何决定驱逐哪个入站对等节点？"
  a2="最多有 28 个对等节点会依据一些难以伪造的标准受到保护，例如低延迟、网络组、提供新颖的有效交易和区块等。剩余节点中连接时间最长的一半也受到保护，其中包括一些洋葱节点。在剩余的节点里，连接数最多的那个网络组中最年轻的成员会被选来断开。攻击者必须在所有这些特征上同时优于诚实节点，才可能对某个节点实施分区。"
  a2link="https://bitcoincore.reviews/20477#l-83"
%}

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [Bitcoin Core 0.21.0rc5][Bitcoin Core 0.21.0] 是该全节点实现及其配套钱包等软件的下一个主要版本的候选发布（RC）。Jarol Rodriguez 编写了一份 [RC 测试指南][RC testing guide]，介绍该版本中的主要变更，并建议你如何协助测试。

- [LND 0.12.0-beta.rc5][LND 0.12.0-beta] 是该 LN 节点下一个主要版本的最新候选发布。它让[锚定输出][topic anchor outputs]成为承诺交易的默认配置，并在其[瞭望塔][topic watchtowers]实现中加入对锚定输出的支持，从而降低成本、提高安全性。该版本还增加了创建和签署[部分签名比特币交易（PSBT）][topic psbt]的通用支持，并包含若干错误修复。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[比特币改进提案 (BIPs)][bips repo]和[闪电网络规范 (BOLTs)][bolts repo]中值得注意的变更。*

- [Bitcoin Core #18077][] 增加了对一种常见自动端口转发协议 [NAT-PMP][rfc 6886]（网络地址转换端口映射协议）的支持。用 `-natpmp` 配置参数启动的监听型 Bitcoin 客户端，会自动在支持 NAT-PMP 的路由器上打开监听端口。NAT-PMP 支持与现有的 UPnP（通用即插即用）支持并行加入，而后者在出现多起安全问题后已于 Bitcoin Core 0.11.1 中默认禁用。与 UPnP 不同，NAT-PMP 使用固定大小的 UDP 数据包，而不是解析 XML，因此被认为[风险较低][laanwj natpmp]。此变更还间接增加了对 [PCP][rfc 6887]（端口控制协议）的支持，它是 NAT-PMP 的向后兼容后继者。

- [Bitcoin Core #19055][] 加入了 [MuHash 算法][MuHash algorithm]，以便未来的 PR 把它用于计划中的功能。如 [Newsletter 123][muhash review club] 所述，MuHash 是一种滚动哈希算法，可用来计算一组对象的哈希摘要，并在增删条目时高效更新。这是对“用 MuHash 计算完整 UTXO 集摘要”这一想法的复兴；该想法最早由 [Pieter Wuille 在 2017 年提出][muhash mailing list]，并在 [Bitcoin Core #10434][] 中实现。对于有兴趣跟踪“为 UTXO 集统计信息创建索引”进展的人——该索引让验证 [assumeUTXO][topic assumeutxo] 归档更容易——总括 PR [Bitcoin Core #18000][] 记录了该项目的进展和后续步骤。

- [C-Lightning #4320][] 为 `invoice` RPC 添加了一个 `cltv` 参数，让用户和插件可以设置所生成发票的 `min_final_cltv_expiry` 字段。

- [C-Lightning #4303][] 更新了 `hsmtool`，改为从标准输入（stdin）读取口令，并开始忽略命令行中提供的任何口令。

{% include references.md %}
{% include linkers/issues.md issues="18077,19055,4320,4303,6993,20477,18000,10434" %}
[bitcoin core 0.21.0]: https://bitcoincore.org/bin/bitcoin-core-0.21.0/
[lnd 0.12.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.12.0-beta.rc5
[news63 bcc15759]: /zh/newsletters/2019/09/11/#bitcoin-core-15759
[daftuar disabletx]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-January/018340.html
[rfc 6886]: https://tools.ietf.org/html/rfc6886
[rfc 6887]: https://tools.ietf.org/html/rfc6887
[laanwj natpmp]: https://github.com/bitcoin/bitcoin/issues/11902#issue-282227529
[wuille bech32m post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-January/018338.html
[bech32m bip]: https://github.com/sipa/bips/blob/bip-bech32m/bip-bech32m.mediawiki
[news83 podle]: /zh/newsletters/2020/02/05/#podle
[zmn podle]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-January/002476.html
[darosior sighash]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-January/002475.html
[fournier podle]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-January/002929.html
[news45 bech32 upgrade]: /zh/bech32-sending-support/#自动-bech32-支持未来的软分叉
[rc testing guide]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/0.21-Release-Candidate-Testing-Guide
[muhash review club]: /zh/newsletters/2020/11/11/#bitcoin-core-pr-审查俱乐部
[muhash mailing list]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2017-May/014337.html
[muhash algorithm]: https://cseweb.ucsd.edu/~mihir/papers/inchash.pdf
