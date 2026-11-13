---
title: 'Bitcoin Optech Newsletter #58'
permalink: /zh/newsletters/2019/08/07/
name: 2019-08-07-newsletter-zh
slug: 2019-08-07-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 宣布 Bitcoin Core 0.18.1 维护版本发布，总结了一场关于 BIP174 扩展的讨论，并提到一项关于 LN 蹦床支付的提案。本周的 *bech32 发送支持* 部分刊载了由 BRD 贡献的一个特别案例研究，*值得注意的变更* 部分则重点介绍了几项可能意义重大的进展。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- **<!--upgrade-to-bitcoin-core-0-18-1-when-binaries-are-released-->****在发布二进制文件时升级到 Bitcoin Core 0.18.1：** 该维护版本已经[打上标签][bitcoin core 0.18.1 tag]，预计几天内会将二进制文件上传到 [bitcoincore.org][bitcoin core 0.18.1 binaries]。此版本修复了多个错误，并带来其他改进。建议在二进制文件可用后升级。

## 新闻

- **<!--bip174-extensibility-->****BIP174 的可扩展性：** 部分签名比特币交易（PSBT）规范的作者 Andrew Chow [提出了][psbt extensions]一些供普遍采用的小改动：

  - **<!--reserved-types-for-proprietary-use-->***为专有用途保留类型：* 有些应用已经在用 [BIP174][] 未规定的类型往 PSBT 里塞数据。提案建议为私有 PSBT 扩展保留一个类型字节或一段类型字节，类似给私有网络保留的 IP 地址范围。这种机制具体怎么构造，是本周讨论的一个重点。

  - **<!--global-version-number-->***全局版本号：* 设计 PSBT 增强功能的目标是保持向后兼容，即便如此，Chow 仍提议给 PSBT 加一个版本字节，用来标明它用到了其中最高级的功能，好让旧版解析器能发现拿到的 PSBT 自己可能看不懂。没有明确版本号的 PSBT 被视为版本 0。

  - **<!--multi-byte-types-->***多字节类型：* 为了容纳更多类型，有人提议采用多字节类型。邮件列表上的讨论似乎倾向于使用与比特币协议中相同的 CompactSize 无符号整数。

- **<!--trampoline-payments-->****蹦床支付：** Bastien Teinturier 在 BOLTs 仓库中提交了一个[PR][trampoline pr]，并在 Lightning-Dev 邮件列表上发起[讨论][trampoline discussion]，议题是让协议支持 [Newsletter #40][news40 trampoline payments] 中介绍过的蹦床支付：付款方把支付发给一个中间节点，由该节点计算路径，或通往另一个中间节点（以保护隐私），或直接通向收款节点。这对不想跟进 gossip 流量的低带宽 LN 客户端（例如移动设备）非常有利，因为它们只知道如何路由到少数几个节点。发送蹦床支付需要多个节点之间相互协调，因此应写入闪电网络规范。

## Bech32 发送支持

*这是共 24 周的[系列][bech32 series]中的第 21 周，目的是让你支付的对象也能获得隔离见证的全部好处。*

{% include specials/bech32/zh/21-brd.md %}

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo] 中值得注意的变更。*

- [Bitcoin Core #15911][] 修改了 `walletcreatefundedpsbt`：当钱包配置为使用 RBF（配置选项 `walletrbf`）时，该 RPC 会按 [BIP125][] 手续费替换（RBF）进行标记。

- [Bitcoin Core #16394][] 更改了 `createwallet` RPC，使其在传递空字符串作为密码参数时，创建一个未加密的钱包（并打印警告）。

- [LND #3184][] 为 LND 添加了一个瞭望塔客户端子服务器，取代了最近版本中添加的私有瞭望塔实现。

- [LND #3164][] 新建了一个数据库，用来存放过去 1,000 笔支付的信息。（默认的 1,000 可以更改。）它供 LND 的任务控制（Mission Control）功能使用，该功能会尽量利用过去支付尝试（尤其是失败）的信息，为后续支付选择更好的路由。在首次升级到包含此改动的版本时，会从 LND 底层的 HTLC 跟踪数据库把以往支付的详情填充到这个新数据库中。

- [LND #3359][] 新增 `ignore-historical-filters` 配置选项，让 LND 忽略对等节点发来的 `gossip_timestamp_filter`。该过滤器允许对等节点请求此前某个时间段内本会通过 gossip 传播的全部公告。忽略这类过滤器请求后，LND 占用的内存和带宽都会减少。该忽略选项目前默认为 False，因此 LND 的默认行为没有变化，但一条提交注释指出：“未来计划将其默认值改为 True。”

- [C-Lightning #2771][] 允许插件表明自己能否在运行时启动和停止，而不只是在初始化时启动、在关闭时停止。一个新的 `plugin` 命令会用到这一信息，让用户可以在运行时执行这些停止和启动操作。

- [C-Lightning #2892][] 现在总是从 Lightning 配置目录运行插件，减少了不同安装之间的不一致性，并使插件能够在该目录中存储和访问数据。

- [C-Lightning #2799][] 为插件新增 `forward_event` 通知：当某个 HTLC 被提供、被结算、双方均失败或在本地（单方面）失败时，插件会收到提醒。此外，该 PR 还扩展了 `listforwards` RPC，加入 `payment_hash` 字段，让用户可以查到与该 HTLC 有关的更多信息。

- [C-Lightning #2885][] 在启动时把对通道对等节点的重连在时间上错开，以降低一种可能：流量激增导致 C-Lightning 连上对等节点后要花 30 秒以上才能重建通道。这正是[上周的 Newsletter][news57 sync error] 中描述的那个导致 LND 发送同步错误消息的问题。

- [BOLTs #619][] 增加了对 LN 洋葱路由中可变长度负载的支持。它与三周前合并进规范的类型-长度-值（TLV）编码字段（见 [Newsletter #55][tlv merge]）相结合，使得在中继支付的加密数据包中放入额外数据容易得多，从而为增加多项功能创造了条件（包括本周 Newsletter 前面讨论的蹦床支付）。

{% include linkers/issues.md issues="15911,16394,3184,3164,3359,2892,2799,2885,2771,619" %}
[bech32 series]: /zh/bech32-sending-support/
[bitcoin core 0.18.1 tag]: https://github.com/bitcoin/bitcoin/releases/tag/v0.18.1
[bitcoin core 0.18.1 binaries]: https://bitcoincore.org/bin/bitcoin-core-0.18.1/
[news40 trampoline payments]: /zh/newsletters/2019/04/02/#trampoline-payments-for-ln
[news57 sync error]: /zh/newsletters/2019/07/31/#c-lightning-2842
[psbt extensions]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-July/017188.html
[trampoline pr]: https://github.com/lightningnetwork/lightning-rfc/pull/654
[trampoline discussion]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-August/002100.html
[tlv merge]: /zh/newsletters/2019/07/17/#bolts-607
