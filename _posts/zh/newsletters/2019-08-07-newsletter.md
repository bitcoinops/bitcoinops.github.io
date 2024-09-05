---
title: 'Bitcoin Optech Newsletter #58'
permalink: /zh/newsletters/2019/08/07/
name: 2019-08-07-newsletter-zh
slug: 2019-08-07-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 公告了 Bitcoin Core 0.18.1 的维护版本发布，总结了关于 BIP174 扩展的讨论，并提到了一项关于 LN 蹦床支付的提案。本周的 *bech32 sending support* 部分由 BRD 贡献了一个特别的案例研究，而 *值得注意的更改* 部分则重点介绍了几项可能的重要开发。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- **<!--upgrade-to-bitcoin-core-0-18-1-when-binaries-are-released-->****在发布二进制文件时升级到 Bitcoin Core 0.18.1：** 该维护版本已经[打上标签][bitcoin core 0.18.1 tag]，预计几天内会将二进制文件上传到 [bitcoincore.org][bitcoin core 0.18.1 binaries]。此版本提供了多个错误修复和其他改进，建议在二进制文件可用时进行升级。

## 新闻

- **<!--bip174-extensibility-->****BIP174 的可扩展性：** 部分签名的比特币交易 (PSBT) 规范的作者 Andrew Chow [提出了][psbt extensions]一些用于广泛采用的小改动：

  - **<!--reserved-types-for-proprietary-use-->***为专有用途保留类型：* 一些应用程序已经在 PSBT 中包含了未在 [BIP174][] 中指定的数据。提议为私有 PSBT 扩展保留一个类型字节或一组类型字节，类似于为私有网络保留的 IP 地址范围。本周的讨论特别关注了这种机制的具体构建。

  - **<!--global-version-number-->***全局版本号：* 虽然设计 PSBT 增强功能的目标是向后兼容，但 Chow 提议向 PSBT 添加一个版本字节，以指示它们使用的最先进功能，以便旧的解析器可以检测它们是否收到可能无法理解的 PSBT。没有明确版本号的 PSBT 将被视为使用版本 0。

  - **<!--multi-byte-types-->***多字节类型：* 为了支持更多类型，提出了多字节类型的建议。邮件列表讨论似乎支持使用与比特币协议中相同的 CompactSize 无符号整数。

- **<!--trampoline-payments-->****蹦床支付：** Bastien Teinturier 在 BOLTs 仓库中开启了一个[拉取请求][trampoline pr]，并在 Lightning-Dev 邮件列表中发起了[讨论][trampoline discussion]，讨论向协议添加对蹦床支付的支持，正如在 [Newsletter #40][news40 trampoline payments] 中描述的那样，付款方将付款发送到一个中间节点，该节点计算路径到另一个中间节点（以增加隐私）或接收节点。这对不想跟踪 gossip 流量的低带宽 LN 客户端（例如移动设备）非常有利，因为它们只知道如何路由到少数节点。发送蹦床支付将需要多个节点之间的协调，因此应在闪电网络规范中进行记录。

## Bech32 发送支持

*第 24 周中的第 21 周[系列][bech32 series]，关于允许你支付的对象访问 segwit 的所有优势。*

{% include specials/bech32/zh/21-brd.md %}

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的更改。*

- [Bitcoin Core #15911][] 更改了 `walletcreatefundedpsbt`，使其在钱包配置为使用 RBF（替换手续费）的情况下，信号 [BIP125][] RBF。

- [Bitcoin Core #16394][] 更改了 `createwallet` RPC，使其在传递空字符串作为密码参数时，创建一个未加密的钱包（并打印警告）。

- [LND #3184][] 为 LND 添加了一个瞭望塔客户端子服务器，取代了最近版本中添加的私有瞭望塔实现。

- [LND #3164][] 创建了一个新数据库，存储过去 1,000 笔支付的信息。（默认设置为 1,000，可以更改。）这旨在与 LND 的任务控制功能一起使用，该功能尝试更好地利用过去支付尝试（尤其是失败）的信息，以便为后续支付选择更好的路由。在首次升级到包含此更改的版本时，将从 LND 的低级 HTLC 追踪数据库中填充有关以前支付的详细信息。

- [LND #3359][] 添加了一个 `ignore-historical-filters` 配置选项，该选项将使 LND 忽略来自对等方发送的 `gossip_timestamp_filter`。该过滤器允许对等方请求在较早日期范围内会进行 gossip 的所有公告。通过忽略该过滤器的请求，LND 使用较少的内存和带宽。该忽略选项当前默认设置为 False，因此默认的 LND 行为没有变化，但提交评论指出，“未来计划将其默认设置为 True。”

- [C-Lightning #2771][] 允许插件指示它们是否可以在运行时启动和停止，而不仅仅是在初始化时启动和关闭。此信息由一个新的 `plugin` 命令使用，允许用户执行这些运行时的启动和停止。

- [C-Lightning #2892][] 现在总是从 Lightning 配置目录运行插件，减少了不同安装之间的不一致性，并使插件能够在该目录中存储和访问数据。

- [C-Lightning #2799][] 为插件提供了新的 `forward_event` 通知，当 HTLC 已被提供、结算、双方失败或本地失败（单方面）时通知。此外，该 PR 还扩展了 `listforwards` RPC，添加了一个 `payment_hash` 字段，以便用户找到有关 HTLC 的其他信息。

- [C-Lightning #2885][] 在启动时将与通道对等方的重连间隔开，以减少流量激增导致 C-Lightning 在与对等方连接后重新建立通道所需时间超过 30 秒的可能性。这是导致 LND 发送同步错误消息的问题，正如[上周的 Newsletter][news57 sync error] 所述。

- [BOLTs #619][] 添加了对 LN 洋葱路由中可变大小负载的支持。结合三周前合并到规范中的类型-长度-值（TLV）编码字段（见 [Newsletter #55][tlv merge]），这使得在中继支付的加密数据包中放入额外数据变得更加容易，从而实现了多个功能的添加（包括本周 Newsletter 中讨论的蹦床支付）。

{% include linkers/issues.md issues="15911,16394,3184,3164,3359,2892,2799,2885,2771,619" %}
[bech32 series]: /zh/bech32-sending-support/
[bitcoin core 0.18.1 tag]: https://github.com/bitcoin/bitcoin/releases/tag/v0.18.1
[bitcoin core 0.18.1 binaries]: https://bitcoincore.org/bin/bitcoin-core-0.18.1/
[news40 trampoline payments]: /zh/newsletters/2019/04/02/#trampoline-payments-for-ln
[news57 sync error]: /zh/newsletters/2019/07/31/#c-lightning-2842
[psbt extensions]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-July/017188.html
[trampoline pr]: https://github.com/lightningnetwork/lightning-rfc/pull/654
[trampoline discussion]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-August/002100.html
[tlv merge]: /zh/newsletters/2019/07/17/#bolts-607
