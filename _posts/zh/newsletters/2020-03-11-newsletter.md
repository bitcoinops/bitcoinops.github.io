---
title: 'Bitcoin Optech Newsletter #88'
permalink: /zh/newsletters/2020/03/11/
name: 2020-03-11-newsletter-zh
slug: 2020-03-11-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 链接了关于防止硬件钱包通过交易签名泄露私密信息的方法描述，提供了 BIP322 通用 `signmessage` 协议的最新进展，并总结了最近一次 Bitcoin Core PR Review Club 会议的内容。此外，还包括我们常规的关于新版本发布和流行的比特币基础设施项目值得注意的合并部分。

## 行动项

*本周无。*

## 新闻

- **<!--exfiltration-resistant-nonce-protocols-->****防止信息外泄的随机数协议：** Pieter Wuille 在 Bitcoin-Dev 邮件列表中发送了一封[邮件][wuille overview]，概述了可以防止硬件钱包或其他离线签名设备通过偏移其在 ECDSA 或 Schnorr 签名中使用的随机数来与第三方通信的技术。邮件内容清晰，信息丰富。任何对安全使用外部签名器感兴趣的人都应该考虑阅读此邮件。

- **<!--bip322-generic-signmessage-progress-or-perish-->****BIP322 通用 `signmessage` 协议——前进还是放弃：** [BIP322][] 的作者 Karl-Johan Alm 指出，他为添加对[通用 `signmessage` 协议][topic generic signmessage]的支持所提交的 PR 已经几个月没有进展。他正在[寻求反馈][alm feedback]——包括“无过滤的批评”，关于是采取不同的方法还是直接放弃该提议。如我们[之前][segwit signmessage]提到的，目前没有被广泛采用的方法来为除传统的 P2PKH 地址外的钱包创建和验证签名消息。如果钱包开发者希望为 P2SH、P2WPKH、P2WSH 以及（如果 Taproot 激活）P2TR 地址启用此功能，建议他们查看 Alm 的邮件并就他们的首选方案提供反馈。

## Bitcoin Core PR 审查俱乐部

[Bitcoin Core PR 审查俱乐部][Bitcoin Core PR Review Club] 是一个每周的 IRC 会议，旨在帮助新的 Bitcoin Core 贡献者学习审查流程。一位经验丰富的 Bitcoin Core 贡献者提供选定 PR 的背景信息，然后在 IRC 上带领大家进行讨论。

Review Club 是学习比特币协议、Bitcoin Core 参考实现以及比特币改进流程的极佳途径。会议记录、问题和讨论日志会发布在网站上，方便那些无法实时参与的人，以及作为希望了解 Bitcoin Core 开发过程的人的永久资源。

在本节中，我们总结了最近一次 Bitcoin Core PR 审查俱乐部会议，重点介绍了一些重要的问答。点击下方的问题可查看会议中的答案摘要。

[尝试在重启期间保留仅区块中继的外部连接][review club 17428] 是 Hennadii Stepanov 提交的一个 PR ([#17428][Bitcoin Core #17428])，该 PR 为 Bitcoin Core 增加了 _锚点连接_ 的概念，即节点在重启之间优先尝试重新连接的对等节点。这些持久连接可以减轻某些类别的[日蚀攻击][topic eclipse attacks]。

讨论首先从建立日蚀攻击的基本概念开始：

{% include functions/details-list.md
  q0="<!--eclipse-attack-->什么是日蚀攻击？"
  a0="日蚀攻击是指当一个节点被所有诚实的对等节点隔离时发生的攻击。"

  q1="<!--eclipse-adversary-->攻击者如何对节点发起日蚀攻击？"
  a1="填满节点的 IP 地址列表，使其只包含攻击者控制的地址，然后迫使节点重启或等待其重启。"

  q2="<!--attacks-->如果一个节点被日蚀攻击，攻击者可以对受害者执行哪些类型的攻击？"
  a2="阻止区块传播、审查交易以及去匿名化交易来源。"
%}

接着分析了 PR 中的变化：

{% include functions/details-list.md
  q0="这个 PR 如何缓解日蚀攻击？"
  a0="通过保存一些已连接的节点（锚点连接）列表，并在重启时重新连接到它们。"

  q1="<!--anchor-peer-->一个对等节点如何成为锚点？"
  a1="该对等节点必须是仅区块中继的对等节点。"
%}

在会议的后半部分，讨论了 PR 中的权衡和设计决策：

{% include functions/details-list.md
  q0="<!--blocks-only-->为什么只使用仅区块中继的对等节点作为锚点？"
  a0="为了使网络拓扑推断更加困难并保护网络隐私。"

  q1="<!--remote-crash-->如果选择了一个能够远程崩溃你节点的锚点会发生什么？"
  a1="恶意对等节点将能够在重启时反复崩溃你的节点。"
%}

几位 Review Club 参与者对该 PR 发表了评论，设计决策的讨论仍在继续。

## 发布和候选发布

*流行的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Bitcoin Core 0.19.1][] 已发布，修复了多个错误；详情见[发布说明][bitcoin core 0.19.1 notes]。

## 值得注意的代码和文档更改

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo] 和 [闪电网络规范][bolts repo] 的值得注意的更改。*

- [Eclair #1323][] 允许节点宣传它们将接受高于之前大约 0.168 BTC 限额的通道开放。这是通过在 `init` 消息中使用新的 `option_support_large_channel` 特性实现的，该特性最近被[添加到 BOLT 9][merged large_channel]。支持大于 0.168 BTC 的通道容量是被非正式称为“wumbo”的功能集的一部分。详情请参见 [Newsletter #22][news22 wumbo]。

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
