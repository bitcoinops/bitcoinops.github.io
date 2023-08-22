---
title: 'Bitcoin Optech Newsletter #264'
permalink: /zh/newsletters/2023/08/16/
name: 2023-08-16-newsletter-zh
slug: 2023-08-16-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报总结了一段在 “静默支付” 地址中添加过期时间的讨论，并概述了 “免服务器 payjoin” 的 BIP 草案。一份贡献给我们的田野调查（field report）介绍了一种基于 MuSig2 的钱包对无脚本式多签名输出的实现和部署情况。此外就是我们的常规栏目：软件的新版本和候选版本的发布公告、热门的比特币基础设施谢幕的重大变更介绍。

## 新闻

- **<!--adding-expiration-metadata-to-silent-payment-addresses-->为静默支付地址添加过期时间**：Peter Todd 在 Bitcoin-Dev 邮件组中[发帖][todd expire]，建议为[静默支付][topic silent payments]的地址增加一个用户自选的过期日。不像常规的比特币地址，如果多次接收支付会导致 “[输出关联][topic output linking]”，静默支付的地址在每次正确使用时都会产生一个唯一的输出脚本。在收款方无法或者不便于在每次支付时都给支付方一个不同的常规地址时，静默支付可以显著提高隐私性。

    Peter Tode 指出，为所有地址提供过期时间都是可取的：在某些情况下，大部分用户都会停止使用一个钱包。按照预期，常规地址只会被使用一次，所以过期时间就不那么要紧；但预期会被重复使用的静默支付，就让过期标记变得更加重要。他建议，要么在地址中加入一个 2 字节的过期时间字段，以支持从当前开始计算，最长可达 180 年的过期时间；要么加入一个 3 字节的字段，从而支持从当前开始计算，最长可达 45000 年的过期时间。

    这个建议在邮件组中得到了少量的讨论，但截至本刊撰写之时，还没有明确的解决。{% assign timestamp="0:51" %}

- **<!--serverless-payjoin-->免服务器的 payjoin**：Dan Gould 在邮件组中[发帖][gould spj]出示了 *免服务器 pajoin*（详见[周报 #236][news236 spj]）的一份 [BIP 草案][spj bip]。就其自身而言，由 [BIP78][] 定义的 [payjoin][topic payjoin] 预期收款方会运行一个服务器，以安全地接收由支付方提供的 [LDK][ldk repo]。Gould 提出了一种异步中继模式，一开始，收款方使用一个 [BIP21][] URI 来指明转发服务器和自己希望用来接收 payjoin 支付的对称加密密钥。支付方会使用这个密钥来加密自己的交易的一个 PSBT，然后发送给接收者指定的中继。接收者会下载这个 PSBT、解密它，然后给它添加签好名的输入，再发回给中继。支付者下载回传的 PSBT、解密它、确保它是正确的，然后签名并广播到比特币网络中。

    在一个[回复][gibson spj]中，Adam Gibson 警告了在 BIP21 URI 中包含加密密钥的危险性，以及用户的隐私性风险：中继可以把收款方和发送方的 IP 地址，跟会话结束时相邻时间段内广播到网络中的交易的集合关联起来。Gould [随后修改了][gould spj2]这份提案，以尝试解决 Gibson 对加密密钥的顾虑。

    我们期待看到关于这份协议的进一步讨论。{% assign timestamp="14:28" %}

## 田野调查：实现 MuSig2

{% include articles/zh/bitgo-musig2.md extrah="#" %} {% assign timestamp="33:10" %}

## 新版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本，或帮助测试候选版本。*

- [Core Lightning 23.08rc2][] 是这个热门的闪电节点实现的新一个大版本的候选。{% assign timestamp="44:40" %}

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo] 和 [Bitcoin Inquisition][bitcoin inquisition repo]*。

- [Bitcoin Core #27213][] 帮助 Bitcoin Core 创建和维护通往更多样的网络中的对等节点的连接，从而减低某些情况下遭遇 “[日蚀攻击][topic eclipse attacks]” 的风险。日蚀攻击指的是，一个节点被不诚实的对等节点包围、完全无法连接到任何一个诚实的对等节点，不诚实的对等节点给他的区块可以跟网络上的其他人看到的都不一样。这种攻击可以用来让受害者节点相信某一笔交易已经得到确认（即使网络上的其他人都不同意），从而欺骗节点运营者已经完成了支付（实际上这些钱他永远花不出去）。提高连接的多样性，可以帮助阻止意外的网络分割 —— 一小部分节点被隔离在网络主流之外，因此无法收到最新区块。

    这个已经合并的 PR 尝试在每一种可以触达的网络中开启至少一个对等连接，而且会防止任意网络上的唯一对等节点被自动断开。{% assign timestamp="45:46" %}

- [Bitcoin Core #28008][] 添加了加密和解密的惯例，计划用于实现由 [BIP324][] 说明的 “[v2 transport protocol][topic v2 P2P transport]”。添加了下列加密算法和类（引用自 PR）：

    - “来自 RFC8439 章节 2.8 的 ChaCha20Poly1305 AEAD（带身份的加密法）”

    - “如 BIP324 所定义的【前向保密型】FSChaCha20 流密码，一个围绕 ChaCha20 的密钥轮换（rekeying）封装器”

    - “如 BIP324 所定义的 FSChaCha20Poly1305 AEAD，一个围绕 ChaCha20Poly1305 的密钥轮换封装器”

    - “一个 BIP324Cipher 类，封装了 BIP324 数据包编码所需的密钥协商（key agreement）、密钥派生、流密码，以及 AEAD”

  {% assign timestamp="50:29" %}

- [LDK #2308][] 允许支付发送者在自己的支付中包含定制化的 标签-长度-数值（TLV）记录，接收者可以使用 LDK 或者兼容的实现从支付中抽取出来。这可以让使用支付发送定制化数据和元数据变得更容易。{% assign timestamp="55:15" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="27213,28008,2308" %}
[todd expire]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021849.html
[gould spj]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021868.html
[spj bip]: https://github.com/bitcoin/bips/pull/1483
[gibson spj]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021872.html
[gould spj2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021880.html
[news236 spj]: /en/newsletters/2023/02/01/#serverless-payjoin-proposal
[core lightning 23.08rc2]: https://github.com/ElementsProject/lightning/releases/tag/v23.08rc2
