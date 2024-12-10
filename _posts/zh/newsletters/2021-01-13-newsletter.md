---
title: 'Bitcoin Optech Newsletter #131'
permalink: /zh/newsletters/2021/01/13/
name: 2021-01-13-newsletter-zh
slug: 2021-01-13-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了一个新的比特币 P2P 协议消息的提议、一个针对 Bech32 修改地址格式的 BIP，以及一个关于防止在提议的双向资助 LN 通道中进行 UTXO 探测的想法。同时，还包括我们常规的内容：Bitcoin Core PR 审查俱乐部会议摘要、发布与候选发布列表以及对流行比特币基础设施软件的值得注意的更改的描述。

## 新闻

- **<!--proposed-disabletx-message-->****提议的 `disabletx` 消息：** 2012 年，发布了 [BIP37][]，为轻量级客户端提供了请求对等方在客户端加载[布隆过滤器][topic transaction bloom filtering]前不向其转发任何未确认交易的能力。Bitcoin Core 后来通过其带宽节约的 `-blocksonly` 模式重新利用了这一机制，使节点请求其对等方完全不发送任何未确认交易。去年，默认配置的 Bitcoin Core 开始建立一些仅用于区块中继的连接，这是在不显著增加带宽或减少隐私的情况下，提高[隔离攻击][topic eclipse attacks]抵抗能力的高效方式（见 [Newsletter #63][news63 bcc15759]）。然而，用于抑制交易转发的 BIP37 机制允许发起节点在任何时候请求完整交易转发。交易转发会消耗节点资源，例如内存和带宽，因此节点需要根据每个基于 BIP37 的低带宽区块中继连接可能突然变为完整交易转发连接的假设来设置其连接限制。

  本周，Suhas Daftuar 在 Bitcoin-Dev 邮件列表中[发布了][daftuar disabletx]一个新的 BIP 提议，提出 `disabletx` 消息。这条消息可在连接协商期间发送。了解该消息的对等方并按照 BIP 的所有建议实现的节点，不会向请求 `disabletx` 的节点发送任何交易公告，也不会向其请求任何交易。此外，也不会发送某些其他的 gossip 消息，例如用于 IP 地址公告的 `addr` 消息。`disabletx` 的协商在连接的整个生命周期内有效，这允许对禁用转发的连接使用不同的限制，例如接受超过当前 125 个连接上限的额外连接。

- **<!--bech32m-->****Bech32m：** Pieter Wuille 在 Bitcoin-Dev 邮件列表中[发布了][wuille bech32m post]一个 [BIP 草案][bech32m bip]，提议了一种修改版的 [Bech32][topic bech32] 地址编码。这种编码增加了检测意外添加或移除字符的可能性。如果该提案未发现问题，预计 Bech32m 地址将用于 [Taproot][topic taproot] 地址以及未来可能的新脚本升级。实现对 Bech32m 地址支付支持的钱包和服务将自动支持支付所有这些未来的改进（详情见 [Newsletter #45][news45 bech32 upgrade]）。

- **<!--ln-dual-funding-anti-utxo-probing-->****LN 双向资助防 UTXO 探测：** LN 的长期目标之一是双向资助，即可以通过发起通道的节点和接收请求的对等方的资金开设新通道。这将允许在通道完全打开后，支付可以向任意方向流动。在发起方能够签署双向资助交易之前，他们需要了解其他方想要添加到交易中的所有 UTXO 的身份（outpoint）。这带来了一个风险，即滥用者可能试图与许多不同的用户发起双向资助通道，获取其 UTXO，然后拒绝签署资助交易，从而在没有成本的情况下损害这些用户的隐私。

  本周，Lloyd Fournier 在 Lightning-Dev 邮件列表中[发布了][fournier podle]一份关于应对该问题的两个先前提案的评估：[一个][zmn podle]使用离散对数等价性证明（PoDLE，见 [Newsletter #83][news83 podle]），[另一个][darosior sighash]则使用带有 `SIGHASH_SINGLE|SIGHASH_ANYONECANPAY` 的双向资助交易的半签名方式。Fournier 扩展了先前的半签名提案，并提出了一个等效有效但更简单的新提案。新提案要求发起方创建并签署（但不广播）一笔将其 UTXO 转回给自己的交易。他们将此交易交给另一方作为诚意证明——如果发起方后来未能签署实际的资助交易，应答方可以广播诚意交易，从而强制发起方支付一笔链上费用。Fournier 在他的帖子末尾总结了不同方法之间的权衡。

## Bitcoin Core PR 审查俱乐部

*在本月的栏目中，我们总结了一次最近的 [Bitcoin Core PR 审查俱乐部][Bitcoin Core PR Review Club]会议，突出一些重要问题和答案。点击下面的问题可以查看会议中答案的摘要。*

[增加节点驱逐逻辑的单元测试][review club #20477]是一个由匿名贡献者 practicalswift 提交的 PR ([#20477][Bitcoin Core #20477])，旨在改进 Bitcoin Core 的节点驱逐逻辑的测试覆盖率，特别是当节点的入站连接插槽已满时。需要小心以避免因该逻辑暴露节点于攻击者触发的网络分区中。

大部分讨论集中在理解 Bitcoin Core 的节点驱逐逻辑上。

{% include functions/details-list.md
  q0="**<!--q0-->**入站或出站节点选择：哪一个是我们抵御隔离攻击的主要防御措施？"
  a0="出站节点选择，因为攻击者对我们选择哪些出站节点的影响小于我们接受的入站连接。入站节点驱逐是第二层保护——而且并非所有节点都允许入站连接。"
  a0link="https://bitcoincore.reviews/20477#l-77"

  q1="**<!--q1-->**为什么 Bitcoin Core 会驱逐入站连接？"
  a1="为了为网络中的诚实节点腾出入站插槽，以便新节点可以与它们建立良好的出站连接。否则，不诚实的节点可以更容易通过占用尽可能多的入站插槽和为新节点的出站连接提供服务来攻击新节点。"
  a1link="https://bitcoincore.reviews/20477#l-66"

  q2="**<!--q2-->**当需要释放一个插槽时，Bitcoin Core 如何决定驱逐哪个入站节点？"
  a2="最多 28 个节点根据一些难以伪造的标准（如低延迟、网络组、提供新颖的有效交易和区块等）受到保护。剩下的节点中，连接时间最长的一半受到保护，包括一些 Onion 节点。在剩下的节点中，选择网络组中连接数最多的组的最年轻成员断开连接。攻击者必须在所有这些特性上同时优于诚实节点，才能分区一个节点。"
  a2link="https://bitcoincore.reviews/20477#l-83"
%}

## 发布与候选发布

*流行比特币基础设施项目的新发布和候选发布版本。请考虑升级到新版本或帮助测试候选发布版本。*

- [Bitcoin Core 0.21.0rc5][Bitcoin Core 0.21.0] 是这个全节点实现及其相关钱包和其他软件的下一个主要版本的候选发布（RC）。Jarol Rodriguez 编写了一份 [RC 测试指南][RC testing guide]，描述了该版本中的主要变化并建议了如何帮助测试。

- [LND 0.12.0-beta.rc5][LND 0.12.0-beta] 是这个闪电网络节点的下一个主要版本的最新候选发布。它使 [锚定输出][topic anchor outputs] 成为承诺交易的默认设置，并在其 [瞭望塔][topic watchtowers] 实现中增加了对锚定输出的支持，从而降低成本并提高安全性。该版本还增加了对创建和签署 [PSBT][topic psbt] 的通用支持，并包括一些错误修复。

## 值得注意的代码和文档更改

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[比特币改进提案 (BIPs)][bips repo]和[闪电网络规范 (BOLTs)][bolts repo] 的值得注意的更改。*

- [Bitcoin Core #18077][] 添加了对一种常见的自动端口转发协议 [NAT-PMP][rfc 6886]（网络地址转换端口映射协议）的支持。通过 `-natpmp` 配置参数启动的监听 Bitcoin 客户端将自动在支持 NAT-PMP 的路由器上打开监听端口。NAT-PMP 的支持与现有的 UPnP（通用即插即用）支持并行添加，而后者由于多次安全问题，在 Bitcoin Core 0.11.1 中默认被禁用。与 UPnP 不同，NAT-PMP 使用固定大小的 UDP 数据包而非 XML 解析，因此被认为[风险较低][laanwj natpmp]。此更改还传递性地增加了对 [PCP][rfc 6887]（端口控制协议）的支持，这是 NAT-PMP 的向后兼容继任者。

- [Bitcoin Core #19055][] 添加了 [MuHash 算法][MuHash algorithm]，以便未来的 PR 可以用它实现计划中的功能。如 [Newsletter 123][muhash review club] 所述，MuHash 是一种滚动哈希算法，可用于计算一组对象的哈希摘要，并在添加或移除项目时高效更新。这是 2017 年 [Pieter Wuille 提出的想法][muhash mailing list]的复兴，用于计算完整 UTXO 集的摘要，并在 [Bitcoin Core #10434][] 中首次实现。对于有兴趣跟踪为 UTXO 集统计创建索引进度的人，meta PR [Bitcoin Core #18000][] 记录了该项目的进展和未来步骤。

- [C-Lightning #4320][] 在 `invoice` RPC 中添加了一个 `cltv` 参数，允许用户和插件设置生成发票的 `min_final_cltv_expiry` 字段。

- [C-Lightning #4303][] 更新了 `hsmtool`，使其从标准输入（stdin）接收密码，并开始忽略命令行中提供的任何密码。

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
