---
title: 'Bitcoin Optech Newsletter #156'
permalink: /zh/newsletters/2021/07/07/
name: 2021-07-07-newsletter-zh
slug: 2021-07-07-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了一组用于输出脚本描述符的比特币改进提案（BIPs），总结了一个关于为闪电网络协议扩展和应用互操作性创建标准文档集的提案，并讨论了对预先信任的零确认通道开启进行标准化支持。还包括我们常规的部分，介绍了如何为 taproot 做准备、发布与候选发布，以及对常用比特币基础设施项目的值得注意的更改。

## 新闻

- **<!--bips-for-output-script-descriptors-->****关于输出脚本描述符的比特币改进提案（BIPs）：** Andrew Chow [发布][chow descriptors post] 到 Bitcoin-Dev 邮件列表，提出了一组提案 BIPs，用于对[输出脚本描述符][topic descriptors]进行标准化。一个核心 BIP 提供了描述符所用到的一般语义和主要元素。另有六个 BIP 描述了扩展函数，例如 `pkh()`、`wpkh()` 和 `tr()`，它们使用传入参数填充脚本模板。多个 BIP 的方式允许开发者自行选择想要实现的描述符功能，例如较新的钱包可能永远不会实现传统的 `pkh()` 描述符。

  描述符最初是在 Bitcoin Core 中实现的，过去一年里被更多项目采用。随着钱包开始探索 [taproot][topic taproot] 所带来的灵活性，以及类似 [miniscript][topic miniscript] 这样的工具简化使用灵活脚本的能力，它们有望在未来被大幅使用。

   {% comment %}<!-- Gentry uses a lowercase leading character (bLIPs).  I
  asked in IRC why, but unless there's a *really* compelling reason, I'd
  prefer to capitalize.  I won't die on this hill, but I'm willing to lose
  a little blood to prevent terms like iPhone that are super annoying to use
  at the beginning of a sentence. -harding -->{% endcomment %}

- **<!--blips-->****BLIPs：** Ryan Gentry [发起][gentry blips]了一个针对闪电网络开发者邮件列表的提案，提出建立一系列 Bitcoin Lightning Improvement Proposals（BLIPs）的想法，用于描述闪电网络扩展及应用的文档，这些文档可通过互操作性标准带来收益。René Pickhardt 链接到了他在 2018 年提出的一个几乎[相同的提案][pickhardt lips]。

  在讨论中，该想法似乎得到了广泛支持，但也有[担忧][teinturier blips]提出：这并不能真正解决将这些标准合并进基础 BOLTs 文档的障碍——这个障碍是资深开发者由于时间不足无法审核众多社区提案。如果未经充分审查就合并 BLIPs，则可能包含漏洞，或者难以获得多个利益相关方的广泛支持，导致各项目采用相互竞争的标准而出现分裂。然而，非主流协议已经在被创建，大多数讨论参与者都认为，如果能提供一个众所周知的存档来发布有关这些协议的文档，主要是有益的。

- **<!--zero-conf-channel-opens-->****零确认通道开启：** Rusty Russell 在闪电网络开发者邮件列表中发起了一项[讨论][russell zeroconf]，探讨对零确认通道（也被称作 *turbo channels*）的标准化处理。它们指的是新的单向资助通道，在这里通道出资方会将部分或全部初始资金给到接收方。除非通道开启交易获得足够的确认，否则这些资金并不安全，因此接收方使用标准的闪电网络协议将其中一部分资金花给出资方并无风险。

  例如，Alice 在 Bob 的托管交易所账户中有数个 BTC。Alice 请求 Bob 开一个新通道并支付给她 1.0 BTC。因为 Bob 自己不会双花他刚刚开启的通道，所以他可以允许 Alice 在通道开启交易尚未得到任何确认之前，就通过他的节点向第三方 Carol 支付 0.1 BTC。

  {:.center}
  ![零确认通道插图](/img/posts/2021-07-zeroconf-channels.png)

  一些闪电网络实现已经以非标准方式支持了这种想法，而所有讨论参与者似乎都倾向于对其进行标准化。截至撰写时，仍在讨论使用的具体细节。

## 为 taproot 做准备 #3：taproot 描述符

*每周一篇的[系列][series preparing for taproot]文章，讲述开发者和服务提供商如何为将在区块高度 {{site.trb}} 激活的 taproot 做好准备。*

{% include specials/taproot/zh/02-descriptors.md %}

## 发布与候选发布

*面向主流比特币基础设施项目的新发布与候选发布版本。请考虑升级到新版本或帮助测试候选发布版本。*

- [LND 0.13.1-beta.rc1][LND 0.13.1-beta] 是一个维护版本，为 0.13.0-beta 中引入的功能带来了一些小改进和错误修复。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]中的一些值得注意的更改：*

- [Bitcoin Core #19651][] 允许钱包密钥管理器更新已有的[描述符][topic descriptors]。这让钱包用户可使用 `importdescriptors` 钱包 RPC 编辑标签、扩展描述符范围、重新激活失效描述符以及进行其他更新。

- [C-Lightning #4610][] 新增了一个 `--experimental-accept-extra-tlv-types` 命令行选项，使用户可指定一些偶数类型的 TLV 列表，以供 `lightningd` 交由插件处理。此前，`lightningd` 会将所有未知的偶数类型 TLV 消息视为无效。此更改允许插件定义并处理 `lightningd` 未知的自定义 TLV 类型。

- [Eclair #1854][] 新增了对来自其他节点（如已[近期实现][news136 c-lightning 4364]警告消息类型的 C-Lightning）发送的[警告消息][bolts #834]进行解码和记录日志的支持。

- [BIPs #1137][] 新增了 [BIP86][]，该提案建议使用一种针对单密钥 P2TR 输出的密钥派生方案。该 BIP 已在[上周的 newsletter][bip-taproot-bip44 desc] 中做了简要介绍。

- [BIPs #1134][] 更新了 BIP155，用于指示在任何软件能够理解[版本 2 addr 消息][topic addr v2]时，都应当发送 `sendaddr2` P2P 功能谈判消息，即便在程序并不一定希望接收 `addr` 消息的情况下也是如此。

{% include references.md %}
{% include linkers/issues.md issues="19651,4610,1854,1137,1134,834" %}
[LND 0.13.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.13.1-beta.rc1
[chow descriptors post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-June/019151.html
[news34 descriptor checksums]: /zh/newsletters/2019/02/19/#bitcoin-core-15368
[gentry blips]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-June/003086.html
[pickhardt lips]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-June/003088.html
[teinturier blips]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-July/003093.html
[russell zeroconf]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-June/003074.html
[news136 c-lightning 4364]: /zh/newsletters/2021/02/17/#c-lightning-4364
[bip86]: https://github.com/bitcoin/bips/blob/master/bip-0086.mediawiki
[bip-taproot-bip44 desc]: /zh/newsletters/2021/06/30/#key-derivation-path-for-single-sig-p2tr
