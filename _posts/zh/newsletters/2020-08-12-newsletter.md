---
title: 'Bitcoin Optech Newsletter #110'
permalink: /zh/newsletters/2020/08/12/
name: 2020-08-12-newsletter-zh
slug: 2020-08-12-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了关于 `SIGHASH_ANYPREVOUT` 和 eltoo 的讨论，包含一份实地报告，展示了如何通过 segwit 和批量处理节省 57,000 BTC 的交易费用，并提供了我们的常规板块，包括 Bitcoin Core PR 审查俱乐部会议的摘要、发布与候选发布，以及受欢迎的比特币基础设施项目的显著变更。

## 行动项

*本周无。*

## 新闻

- **<!--discussion-about-eltoo-and-sighash_anyprevout-->****关于 eltoo 和 `SIGHASH_ANYPREVOUT` 的讨论：** Richard Myers [恢复][myers anyprevout]了关于 [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] 的讨论，并提供了一张详细的图表，展示了如何在 [eltoo][topic eltoo] 中使用它的两种[签名哈希][signature hash] (sighash)类型。他还提出了几个关于如何最小化创建 eltoo 状态更新所需网络往返次数的问题。ZmnSCPxj 对这些问题进行了[回答][zmnscpxj reply]，同时还引发了在 eltoo 语境下针对 LN 支付原子性攻击的[第二次讨论][corallo relay]。

  eltoo 相较于目前使用的 LN 惩罚机制的优势在于，当旧的 eltoo 通道状态发布到链上时，不会阻止最终通道状态的发布。这通过使用 `SIGHASH_ANYPREVOUT` 来签名得以实现，从而使最终状态的签名可以花费来自初始状态、倒数第二个状态或任何中间状态的比特币。然而，交易仍然需要识别它们试图花费的状态（先前的输出）。

  eltoo 机制的一个问题是，攻击者和诚实用户都可能试图从同一个先前状态花费。矿工和中继节点的内存池中只会保留其中一个交易，攻击者可能有方法确保所有人保留的是旧状态的交易。另一个问题是，攻击者可能会诱使诚实用户从中继节点未见过的状态进行花费，因此中继节点可能会拒绝未确认交易，因为其父交易不可用。虽然这些问题都不会阻止最终状态最终被确认上链，但它们可以用于 [交易固定][topic transaction pinning]，以防止诚实用户的时间敏感交易及时确认。这些问题类似于在 [Newsletter #95][news95 ln atomicity] 中描述的 LN 支付原子性攻击。一种提议的缓解方法是设置专用节点（可能是 LN 路由软件的一部分），这些节点可以识别 eltoo 的使用，并利用其对协议的了解告知矿工哪个交易最有利可图。

## 实地报告：如何通过 segwit 和批量处理节省 5 亿美元的手续费

{% include articles/zh/veriphi-segwit-batching.md %}

## Bitcoin Core PR 审查俱乐部

*在这一月度板块中，我们总结了一次最近的 [Bitcoin Core PR 审查俱乐部][Bitcoin Core PR Review Club]会议，重点介绍了一些重要的问题和答案。点击下面的问题可以查看会议中的答案摘要。*

[实现 ADDRv2 支持（BIP155 的一部分）][review club #19031] 是 Vasil Dimov 提出的一个 PR
（[#19031][Bitcoin Core #19031]），旨在实现 [BIP155][] 中的 `addrv2` P2P 消息。

讨论涉及了当前 Bitcoin Core 中的 `addr` 消息、BIP155 中的 `addrv2` 消息、如何在 P2P 网络上信号支持 `addrv2`，以及 Bitcoin 网络升级到 Tor v3 的必要性。Tor v2 将于九月中旬开始弃用！

{% include functions/details-list.md
  q0="**<!--q0-->**Bitcoin Core 如何处理网络地址？"
  a0="Bitcoin Core 目前将所有对等地址视为在[单一][19031 single]类 IPv6 空间中。IPv4 和 Tor v2 地址被序列化为 [16 字节][19031 fake]，编码为来自特定 IPv6 网络的“假”IPv6 地址。例如，Tor v2 地址使用 [“onioncat” IPv6 范围][19031 onioncat] 进行持久化。IPv6 的 16 字节最大长度越来越限制 Bitcoin 节点可以连接的端点。"
  a0link="https://bitcoincore.reviews/19031#l-35"

  q1="**<!--q1-->**如何存储对等地址？"
  a1="地址以 16 字节格式保存在 `peers.dat` 文件中，这与 IPv6 地址的长度相对应；较小的 IPv4 和 Tor v2 地址因此被[填充][19031 padded] 以适应。这份文件可以更新以处理更大的地址，并在保持向后兼容性的同时进行。"
  a1link="https://bitcoincore.reviews/19031#l-82"

  q2="**<!--q2-->**BIP155 和 `addrv2` 消息是什么？"
  a2="[BIP155 `addrv2`][BIP155] 是 Wladimir J. van der Laan 于 2019 年初提出的新 P2P 消息格式，用于传播大于 16 字节且最多可达 512 字节的可变长度节点地址，并为不同的网络提供独立的地址空间。`addrv2` 将使 Bitcoin Core 能够使用 [下一代 Onion 服务][19031 nextgen]（Tor v3）和 [I2P (隐形互联网项目)][19031 i2p]，以及其他具有较长端点地址的网络，这些地址无法适应当前 `addr` 消息的 16 字节/128 位限制。"

  q3="**<!--q3-->**预计如何信号支持 `addrv2`？"
  a3="最有可能的是在 [握手或之后][19031 handshake] 通过对等节点之间的 `sendaddrv2` 消息，而不是通过最初提议的协议版本升级或新的网络服务位。"
  a3link="https://bitcoincore.reviews/19031#l-99"

  q4="**<!--q4-->**Tor v3 对比特币的重要性是什么？"
  a4="Tor v2 计划于 2020 年 9 月 15 日 [弃用][19031 v2 deprecate]，并于 2021 年 7 月 15 日废弃（[时间表][19031 v2 schedule]）。Tor v3 提供了更好的安全性和隐私性，因为它使用更长的 56 字符地址。因此，在比特币网络上使用 Tor v3 需要实现 BIP155 `addrv2`。"
  a4link="https://bitcoincore.reviews/19031#l-203"

  q5="**<!--q5-->**近期是否需要另一个升级，也就是 `addrv3`？"
  a5="在一段时间内不需要。`addrv2` 的唯一限制是地址不超过 512 字节。任何未来的格式，只要在这个大小范围内，包括可变长度的路由描述，都应该得到支持。"
  a5link="https://bitcoincore.reviews/19031#l-253"
%}

## 发布与候选发布

*受欢迎的比特币基础设施项目的新发布与候选发布。请考虑升级到新版本或帮助测试候选版本。*

- [LND 0.11.0-beta.rc2][lnd 0.11.0-beta] 是该项目下一个主要版本的候选发布版本。它允许接受[大通道][topic large channels]（默认情况下关闭），并包含了许多可能对高级用户感兴趣的后端功能改进（详见[发行说明][lnd 0.11.0-beta]）。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的变更。*

- [Bitcoin Core #18991][] 更改了 Bitcoin Core 对其对等节点 `getaddr` 请求的响应方式。比特币节点可以通过两种方式了解它们可以连接的新对等节点。首先，每个节点会定期向其对等节点宣布自己的网络地址。这些对等节点将地址重新宣布给它们自己的部分对等节点，后者再向它们的对等节点重新宣布，依此类推，使地址在整个网络中传播。其次，节点可以使用 `getaddr` 消息明确请求来自对等节点的地址。为了防止对等节点了解其地址管理器中的所有地址，Bitcoin Core 只在收到 `getaddr` 消息时提供其中一部分地址，并且只响应来自每个对等节点的一条 `getaddr` 消息。然而，攻击者仍然可以通过多次连接到该对等节点并在每个连接上发送 `getaddr` 消息来了解其所知的所有地址。攻击者可能会利用这些信息对对等节点进行指纹识别或推断网络拓扑。为防止这种情况，此 PR 更改了 Bitcoin Core 的行为，将对 `getaddr` 请求的响应缓存，并在 24 小时滚动窗口内对所有请求地址的对等节点提供相同的响应。

- [Bitcoin Core #19620][] 阻止 Bitcoin Core 重新下载试图花费非标准 UTXO 的未确认 segwit 交易。非标准 UTXO 是指使用当前不推荐的功能的 UTXO，例如在网络通过软分叉如 [taproot][topic taproot] 之前使用的 v1 segwit 输出。这有助于解决在 [Newsletter #108][news108 wtxid] 中描述的关于 taproot 激活的潜在问题：没有为软分叉升级的节点不会接受未确认的 taproot 交易，因此它们可能会一次又一次地下载并拒绝同样的未确认 taproot 交易。运行此补丁的节点不会出现这种情况，从而使该补丁的回溯移植成为[回溯移植 wtxid 中继功能][Bitcoin Core #19606]的一种替代方案，该功能也可以防止这种带宽浪费。

- [C-Lightning #3909][] 更新了 `listpays` RPC，现在返回一个新的 `created_at` 字段，其中包含一个时间戳，指示首次部分支付的创建时间。

- [Eclair #1499][] 添加了新的 `signmessage` 和 `verifymessage` 命令，分别使用您的 LN 节点的公钥签署消息并使用已知的节点公钥验证消息。测试表明，这些新命令与 [LND][LND #192] 和 [C-Lightning][news69 signcheck rpc] 中现有的消息签名和验证命令兼容，不同之处在于 Eclair 的签名以十六进制编码而不是 zbase32。

{% include references.md %}
{% include linkers/issues.md issues="18991,19620,3909,1499,19031,19606,192" %}
[lnd 0.11.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.11.0-beta.rc2
[news69 signcheck rpc]: /zh/newsletters/2019/10/23/#c-lightning-3150
[news95 ln atomicity]: /zh/newsletters/2020/04/29/#new-attack-against-ln-payment-atomicity
[myers anyprevout]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-August/018069.html
[zmnscpxj reply]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-August/018071.html
[corallo relay]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-August/018072.html
[news108 wtxid]: /zh/newsletters/2020/07/29/#bitcoin-core-18044
[signature hash]: https://btcinformation.org/en/developer-guide#signature-hash-types
[19031 single]: https://bitcoincore.reviews/19031#l-49
[19031 fake]: https://bitcoincore.reviews/19031#l-88
[19031 onioncat]: https://bitcoincore.reviews/19031#l-89
[19031 padded]: https://bitcoincore.reviews/19031#l-68
[BIP155]: https://github.com/bitcoin/bips/blob/master/bip-0155.mediawiki
[19031 nextgen]: https://trac.torproject.org/projects/tor/wiki/doc/NextGenOnions
[19031 i2p]: https://geti2p.net
[19031 handshake]: https://bitcoincore.reviews/19031#l-121
[19031 v2 deprecate]: https://lists.torproject.org/pipermail/tor-dev/2020-June/014365.html
[19031 v2 schedule]: https://blog.torproject.org/v2-deprecation-timeline
[hwi]: https://github.com/bitcoin-core/HWI
