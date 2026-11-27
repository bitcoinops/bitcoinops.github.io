---
title: 'Bitcoin Optech Newsletter #156'
permalink: /zh/newsletters/2021/07/07/
name: 2021-07-07-newsletter-zh
slug: 2021-07-07-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了一组用于输出脚本描述符的比特币改进提案（BIPs），总结了一个关于为闪电网络协议扩展和应用互操作性创建标准文档集的提案，并讨论了对预先信任的零确认通道开启进行标准化支持。还包括我们常规的栏目：如何为 taproot 做准备、发布与候选发布，以及热门比特币基础设施项目的值得注意的变更。

## 新闻

- **<!--bips-for-output-script-descriptors-->****关于输出脚本描述符的比特币改进提案（BIPs）：** Andrew Chow 在 Bitcoin-Dev 邮件列表上[发布][chow descriptors post]了一组提案 BIP，用于对[输出脚本描述符][topic descriptors]进行标准化。其中一份核心 BIP 规定了描述符所使用的一般语义和主要元素。另有六份 BIP 描述扩展函数，例如 `pkh()`、`wpkh()` 和 `tr()`，它们用各自收到的参数填充脚本模板。拆成多份 BIP 的做法，让开发者可以自行选择要实现哪些描述符功能，例如较新的钱包可能永远不会实现传统的 `pkh()` 描述符。

  描述符最初是为 Bitcoin Core 实现的，过去一年里被越来越多其他项目采用。随着钱包开始探索 [taproot][topic taproot] 带来的灵活性，以及借助 [miniscript][topic miniscript] 这类工具简化访问灵活脚本的能力，描述符的使用量有望显著增长。

- **<!--blips-->****BLIPs：** Ryan Gentry 在 Lightning-Dev 邮件列表上[发布][gentry blips]了一项提案，建议建立一套 Bitcoin Lightning Improvement Proposals（BLIPs）文档集，用来描述闪电网络的扩展与应用——这些内容将因互操作性标准而受益。René Pickhardt 则链接到他在 2018 年提出的一个几乎[相同的提案][pickhardt lips]。

  在讨论中，这一想法似乎得到了广泛支持，但也有人[担忧][teinturier blips]：它并不能真正解决把这些标准并入基础 BOLTs 文档的障碍——该障碍在于经验丰富的开发者没有足够时间审阅大量社区提案。如果 BLIPs 未经充分审查就被合并，它们含有 bug、或无法获得多个利益相关方广泛支持的可能性就会上升，最终导致不同项目采用相互竞争的标准而出现分裂。尽管如此，非主线的协议已经在不断出现，而多数讨论参与者似乎都认为，提供一个广为人知的归档处、用来发布这些协议的文档，总体上是有益的。

- **<!--zero-conf-channel-opens-->****零确认通道开启：** Rusty Russell 在 Lightning-Dev 邮件列表上发起了一项[讨论][russell zeroconf]，探讨如何把零确认通道（也被称作 *turbo channels*）的处理标准化。这类通道是新的单方出资通道，其中出资方会把部分或全部初始资金交给接收方。在通道开启交易获得足够确认之前，这些资金并不安全，因此接收方用标准闪电网络协议把其中一部分资金再花回给出资方是没有风险的。

  例如，Alice 在 Bob 的托管交易所账户里存有几个 BTC。Alice 请 Bob 开一个新通道并向她支付 1.0 BTC。因为 Bob 相信自己不会双花他刚开的这个通道，所以即使通道开启交易连一个确认都还没有，他也可以允许 Alice 通过他的节点向第三方 Carol 发送 0.1 BTC。

  {:.center}
  ![零确认通道插图](/img/posts/2021-07-zeroconf-channels.png)

  一些闪电网络实现已经以非标准化的方式支持这一想法，所有讨论参与者似乎都倾向于把它标准化。截至撰写本文时，具体采用哪些细节仍在讨论中。

## 准备 Taproot #3：taproot 描述符

*每周一篇的[系列][series preparing for taproot]文章，讲述开发者和服务提供商如何为将在区块高度 {{site.trb}} 激活的 taproot 做好准备。*

{% include specials/taproot/zh/02-descriptors.md %}

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [LND 0.13.1-beta.rc1][LND 0.13.1-beta] 是一个维护版本，为 0.13.0-beta 中引入的功能带来了一些小幅改进和错误修复。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]的值得注意的变更：*

- [Bitcoin Core #19651][] 允许钱包密钥管理器更新已有的[描述符][topic descriptors]。这让钱包用户可以使用 `importdescriptors` 钱包 RPC 编辑标签、扩展描述符范围、重新激活已失效的描述符，以及做其他更新。

- [C-Lightning #4610][] 新增了一个 `--experimental-accept-extra-tlv-types` 命令行选项，让用户可以指定一组偶数编号的 TLV 类型，由 `lightningd` 透传给插件处理。此前，`lightningd` 会把所有未知的偶数编号类型 TLV 消息视为无效。这一改动让插件可以定义并处理 `lightningd` 未知的自定义 TLV 类型。

- [Eclair #1854][] 新增了对[警告消息][bolts #834]进行解码和记录日志的支持，这类消息来自 C-Lightning 等[近期实现了][news136 c-lightning 4364]警告消息类型的对等节点。

- [BIPs #1137][] 新增了 [BIP86][]，该提案为单密钥 P2TR 输出提出了一种密钥派生方案。该 BIP 已在[上周的 Newsletter][bip-taproot-bip44 desc] 中做过简要介绍。

- [BIPs #1134][] 更新了 BIP155，指出只要某个软件程序能够理解[版本 2 addr 消息][topic addr v2]，就应当发送 `sendaddr2` 这一 P2P 功能协商消息，包括程序并不一定希望接收 `addr` 消息的情形。

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
[series preparing for taproot]: /zh/preparing-for-taproot/
