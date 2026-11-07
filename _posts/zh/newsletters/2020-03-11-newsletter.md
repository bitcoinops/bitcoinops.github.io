---
title: 'Bitcoin Optech Newsletter #88'
permalink: /zh/newsletters/2020/03/11/
name: 2020-03-11-newsletter-zh
slug: 2020-03-11-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 链接到一篇说明，介绍防止硬件钱包通过交易签名泄露私密信息的方法，并介绍了 BIP322 通用 `signmessage` 协议的最新进展，还总结了最近一次 Bitcoin Core PR Review Club 会议的内容。此外还有我们的常规部分：新发布公告，以及热门比特币基础设施项目的值得注意合并。

## 行动项

*本周无。*

## 新闻

- **<!--exfiltration-resistant-nonce-protocols-->****防止信息外泄的 nonce 协议：** Pieter Wuille 在 Bitcoin-Dev 邮件列表中发送了一封[邮件][wuille overview]，概述了若干技术，可防止硬件钱包或其他离线签名设备通过使其生成的 ECDSA 或 Schnorr 签名中的 nonce 产生偏差，把秘密信息传递给第三方。这封邮件写得清楚，而且信息量很大。任何关心如何安全使用外部签名器的人都值得读一读。

- **<!--bip322-generic-signmessage-progress-or-perish-->****BIP322 通用 `signmessage` 协议——前进还是放弃：** [BIP322][] 作者 Karl-Johan Alm 指出，他为添加对[通用 `signmessage` 协议][topic generic signmessage]的支持而提交的 PR，几个月来一直没能推进到合并。他正在[征求反馈][alm feedback]——包括“不加过滤的批评”，想知道是该换一种做法，还是干脆放弃这个提议。如我们[此前][segwit signmessage]提到的，对于 legacy P2PKH 之外的地址类型，目前还没有被广泛采用的办法让钱包创建和验证签名消息。如果钱包开发者希望为 P2SH、P2WPKH、P2WSH 以及（如果 Taproot 激活）P2TR 地址启用这一能力，建议先读一读 Alm 的邮件，并就自己倾向的推进方式给出反馈。

## Bitcoin Core PR 审查俱乐部

[Bitcoin Core PR 审查俱乐部][Bitcoin Core PR Review Club] 是一个每周的 IRC 会议，旨在帮助新的 Bitcoin Core 贡献者学习审查流程。一位经验丰富的 Bitcoin Core 贡献者提供选定 PR 的背景信息，然后在 IRC 上带领大家进行讨论。

Review Club 是学习比特币协议、Bitcoin Core 参考实现以及对比特币做改动的流程的绝佳途径。会议记录、问题与讨论日志都会发布在网站上，既方便无法实时参会的人，也可作为希望了解 Bitcoin Core 开发流程的人的长期资料。

在本节中，我们总结了最近一次 Bitcoin Core PR 审查俱乐部会议，重点介绍了一些重要的问答。点击下方的问题可查看会议中的答案摘要。

[尝试在重启期间保留仅区块中继的出站连接][review club 17428] 是 Hennadii Stepanov 提交的一个 PR（[#17428][Bitcoin Core #17428]），该 PR 为 Bitcoin Core 引入了 _锚点连接_ 的概念，即节点在重启之间会优先尝试重新连接的对等节点。这类持久连接可以缓解某些类型的[日食攻击][topic eclipse attacks]。

讨论首先梳理了日食攻击的几个基本概念：

{% include functions/details-list.md
  q0="<!--eclipse-attack-->什么是日食攻击？"
  a0="日食攻击是指一个节点被所有诚实的对等节点隔离。"

  q1="<!--eclipse-adversary-->攻击者如何对节点发起日食攻击？"
  a1="用攻击者自己拥有的地址填满节点的 IP 地址列表，然后迫使节点重启，或者等它自行重启。"

  q2="<!--attacks-->如果一个节点被日食攻击，攻击者可以对受害者实施哪些攻击？"
  a2="扣留区块、审查交易，以及去匿名化交易来源。"
%}

接着分析了这个 PR 中的改动：

{% include functions/details-list.md
  q0="这个 PR 如何缓解日食攻击？"
  a0="通过保存一些曾连接过的节点（锚点连接）列表，并在重启时重新连接到它们。"

  q1="<!--anchor-peer-->一个对等节点要满足什么条件才能成为锚点？"
  a1="该对等节点必须是仅区块中继的对等节点。"
%}

在会议后半段，大家讨论了 PR 中的权衡和设计决策：

{% include functions/details-list.md
  q0="<!--blocks-only-->为什么只用仅区块中继的对等节点作为锚点？"
  a0="为了让网络拓扑推断更难，并保护网络隐私。"

  q1="<!--remote-crash-->如果选择了一个能够远程崩溃你节点的锚点会发生什么？"
  a1="恶意对等节点将能够在重启时反复崩溃你的节点。"
%}

几位 Review Club 参与者对该 PR 发表了评论，设计决策的讨论仍在继续。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [Bitcoin Core 0.19.1][] 已发布，修复了若干缺陷；详情见[发布说明][bitcoin core 0.19.1 notes]。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo] 和 [闪电网络 BOLT 规范][bolts repo] 中的值得注意的变更。*

- [Eclair #1323][] 允许节点宣告自己愿意接受金额高于此前约 0.168 BTC 上限的通道开启。做法是在 `init` 消息中使用新增的 `option_support_large_channel` 特性，该特性最近被[加入 BOLT 9][merged large_channel]。支持大于 0.168 BTC 的通道容量，属于被非正式称为“wumbo”的那组功能。详情参见 [Newsletter #22][news22 wumbo]。

{% include references.md %}
{% include linkers/issues.md issues="1323,17428" %}
[bitcoin core 0.19.1]: https://bitcoincore.org/bin/bitcoin-core-0.19.1/
[bitcoin core 0.19.1 notes]: https://bitcoincore.org/en/releases/0.19.1/
[wuille overview]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017667.html
[alm feedback]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017668.html
[segwit signmessage]: /zh/bech32-sending-support/#消息签名支持
[merged large_channel]: /zh/newsletters/2020/02/26/#bolts-596
[news22 wumbo]: /zh/newsletters/2018/11/20/#wumbo
[Bitcoin Core PR Review Club]: https://bitcoincore.reviews
[review club 17428]: https://bitcoincore.reviews/17428
