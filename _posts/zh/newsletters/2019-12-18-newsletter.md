---
title: 'Bitcoin Optech Newsletter #77'
permalink: /zh/newsletters/2019/12/18/
name: 2019-12-18-newsletter-zh
slug: 2019-12-18-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 宣布了 LND 0.8.2-beta 的发布，呼吁帮助测试最新的 C-Lightning 候选发布版本，讨论了 LN 中对基础多路径支付的广泛支持，提供了关于 bech32 错误检测可靠性的更新，汇总了提议的 `OP_CHECKTEMPLATEVERIFY` 操作码的更新，并链接了一场关于日蚀攻击对 LN 通道影响的讨论。此外，我们还包括了定期的有关受欢迎的比特币基础设施项目、服务和客户端软件的更改，以及 Bitcoin Stack Exchange 精选问答部分。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- **<!--upgrade-to-lnd-0-8-2-beta-->****升级到 LND 0.8.2-beta：** 该[版本][lnd 0.8.2-beta] 包含了若干错误修复和小的用户体验改进，最显著的是静态通道备份的恢复改进。

- **<!--help-test-c-lightning-0-8-0-rc-->****帮助测试 C-Lightning 0.8.0 RC：** 下一个版本的 C-Lightning 的[候选发布版本][cl 0.8.0] 已将默认网络切换为主网而非测试网（见 [Newsletter #75][news75 cl mainnet]），并增加了对基础多路径支付的支持（下文将介绍），还有许多其他功能和错误修复。

- **<!--review-bech32-action-plan-->****审查 bech32 行动计划：** 如下文[描述][bech32 news]，Pieter Wuille 建议将所有 bech32 地址限制为 20 字节或 32 字节的见证程序，以防止因涉及以 `p` 结尾的地址的抄录错误导致的资金损失。此规则已经适用于用于 P2WPKH 和 P2WSH 的 v0 segwit 地址，因此此更改只是将其扩展到 v1 及以上的保留用于未来升级的地址（如提议的 [taproot][topic taproot]）。这将需要已实现 bech32 发送支持的钱包和服务升级其代码，但应当只需要非常小的改动；例如，对于 [Python 参考实现][bech32 python]，可能看起来像这样：

  ```diff
    --- a/ref/python/segwit_addr.py
    +++ b/ref/python/segwit_addr.py
    @@ -110,7 +110,7 @@ def decode(hrp, addr):
             return (None, None)
         if data[0] > 16:
             return (None, None)
    -    if data[0] == 0 and len(decoded) != 20 and len(decoded) != 32:
    +    if len(decoded) != 20 and len(decoded) != 32:
             return (None, None)
         return (data[0], decoded)
  ```

  如果你对该建议更改有任何问题或疑虑，请回复下文 *新闻* 部分链接的邮件列表帖子。

## 新闻

- **<!--ln-implementations-add-multipath-payment-support-->****LN 实现增加多路径支付支持：** 在大量讨论和开发之后，Optech 跟踪的所有三个 LN 实现现在都增加了对[多路径支付][topic multipath payments]的基础支持（合并：[C-Lightning][mpp cl]、[Eclair][mpp eclair]、[LND][mpp lnd]）。多路径支付由多个 LN 支付组成，这些支付通过不同路径路由，接收者可以同时领取这些支付。这极大提升了 LN 的可用性，允许用户在同一个总体支付中使用多个通道的资金。此升级意味着支出者不再需要过多担心每个特定通道中的余额，因为他们可以跨所有通道发送其全部可用余额（受其他 LN 限制的影响）。

- **<!--analysis-of-bech32-error-detection-->****bech32 错误检测分析：** Pieter Wuille 向 Bitcoin-Dev 邮件列表发送了一封[邮件][wuille bech32 post]，跟进了之前 Newsletter 中描述的 bech32 易变性问题（[#72][news72 bech32]、[#74][news74 bech32]、[#76][news76 bech32]），即在 bech32 字符串末尾的 `p` 字符前可以随意添加或删除任意数量的 `q` 字符。Wuille 的[分析][wuille bech32 analysis]显示这是 bech32 错误检测属性的唯一例外，“更改 bech32 中的一个常量即可解决该问题。”

  Wuille 计划修订 [BIP173][] 以描述该弱点，提议将现有的 bech32 地址使用限制为 20 字节或 32 字节的见证程序有效载荷，并为非比特币使用和未来可能需要 20 字节或 32 字节以外见证程序的情况定义一个修改后的 bech32 版本。

- **<!--proposed-changes-to-bip-ctv-->****提议的 bip-ctv 变更：** Jeremy Rubin [建议][rubin ctv update] 对提议的软分叉新增操作码 `OP_CHECKTEMPLATEVERIFY` (CTV) 进行若干修改。最显著的是，修改将移除 CTV 模板不能通过比特币脚本从其他数据派生的限制。此更新简化了 [Newsletter #75][news75 ctv] 中讨论的脚本语言修改。据我们所知，这些更新不会对 CTV 的行为产生任何重大影响，也不会对先前描述的用例有显著影响（但我们鼓励任何发现根本性变化的人在邮件列表中进行讨论）。

- **<!--discussion-of-eclipse-attacks-on-ln-nodes-->****LN 节点的日蚀攻击讨论：** Antoine Riard 向 Lightning-Dev 邮件列表[发布][riard eclipse] 了两种针对 LN 用户的攻击描述，当用户遭遇日蚀攻击且攻击者延迟中继区块时，这些攻击可能发生。日蚀攻击是指全节点或轻量客户端的所有连接都被单个攻击者控制，这在攻击者是 ISP 或者攻击者控制了用户的路由器时很容易发生。这样攻击者就可以完全控制节点或客户端发送或接收的数据。在第一次攻击中，日蚀攻击者可以发送已撤销的承诺交易，而诚实的用户在得知此消息前无法提交相应的惩罚交易，从而允许攻击者窃取诚实用户的资金。在第二次攻击中，攻击者阻止诚实的用户意识到需要广播最新的承诺交易，因为其 HTLC 即将到期——这使攻击者可以在 HTLC 到期后窃取资金。

  Riard 的帖子以及 [Matt Corallo][corallo eclipse] 和 [ZmnSCPxj][zmn eclipse] 的回复讨论了过去和现在的工作，以提高全节点和轻量客户端抵御日蚀攻击的能力。对于有兴趣深入了解日蚀攻击及其缓解措施的读者，强烈建议阅读 Bitcoin Core 审查俱乐部上周的[会议记录和日志][review club notes]，他们深入讨论了这一主题。

## 服务和客户端软件的变更

*在这个月度专栏中，我们重点介绍比特币钱包和服务的有趣更新。*

- **<!--bitfinex-supports-ln-deposits-and-withdrawals-->****Bitfinex 支持 LN 存取款：** 在[最近的博客文章][bitfinex ln blog]中，Bitfinex 宣布他们的交易所支持闪电网络。Bitfinex 的用户现在可以使用 LN 存取款资金。

- **<!--bitmex-research-launches-an-ln-penalty-transaction-tracker-->****BitMEX Research 推出了 LN 惩罚交易追踪器：** 在 [BitMEX Research 发布的文章][bitmex ln penalty blog]中，开源工具 ForkMonitor 现在[列出了闪电网络的惩罚交易][fork monitor lightning]。该工具还通过监控不同比特币实现和版本的 chaintips 来检测分叉。

- **<!--bitmex-bech32-send-support-->****BitMEX 支持 bech32 发送：** 在[最近的博客文章][bitmex bech32 blog]中，BitMEX 宣布他们的交易所支持发送到本机 bech32 地址。文章还概述了他们计划将其钱包从 P2SH 迁移到 P2SH 封装的 segwit 地址。

- **<!--unchained-capital-open-sources-caravan-a-multisig-coordinator-->****Unchained Capital 开源了多重签名协调器 Caravan：** 通过一篇[博客文章和演示视频][unchained caravan blog]，Unchained Capital 开源了他们的[多重签名协调器 Caravan][unchained caravan github]。Caravan 是一个无状态的 Web 应用程序，支持使用各种外部密钥库创建和消费多重签名地址。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选平台之一——或者当我们有空时，帮助那些好奇或困惑的用户。在这个月度专栏中，我们重点介绍了自上次更新以来发布的最高票问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--what-is-the-rationale-for-the-lightning-network-s-path-length-limit-20-hops-->**[Lightning 网络路径长度限制（20 跳）的理由是什么？]({{bse}}92073)： Sergei Tikhomirov 询问了 BOLT4 的 20 跳限制，并比较了 Tor 的洋葱路由与 LN 的 Sphinx。Rene Pickhardt 概述了协议的不同之处以及当前限制的动机：保持 TCP/IP 包的大小以及 LN 作为小直径网络的假设。

- **<!--is-there-a-way-to-allow-use-of-unconfirmed-rbf-outputs-in-transaction-building-->**[是否有办法在构建交易时使用未确认的 RBF 输出？]({{bse}}92164)： G. Maxwell 指出，Bitcoin Core 对标记为可选择 RBF 的交易输出的处理方式与不标记为 RBF 的交易输出相同。Bitcoin Core 对输出的处理方式取决于包含该输出的交易是否已确认，以及交易是否由用户的 Bitcoin Core 钱包创建。

- **<!--what-is-the-max-allowed-depth-for-bip32-derivation-paths-->**[BIP32 派生路径允许的最大深度是多少？]({{bse}}92056)： Andrew Chow 解释道，由于 BIP32 为深度字段分配了一个字节，因此派生路径中最多可以有 256 个元素。

## 值得注意的代码和文档更改

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的更改。*

- [Bitcoin Core #17678][] 增加了对 [S390X][] 和 64 位 [POWER][] CPU 架构的编译支持。

- [Bitcoin Core #12763][] 添加了 RPC 白名单功能，允许你限制特定用户可以运行的 RPC。默认情况下，任何已认证的用户都可以运行任何命令，但新的配置选项 `rpcwhitelist` 和 `rpcwhitelistdefault` 可用于配置哪些用户可以访问哪些 RPC。

- [C-Lightning #3309][] 增加了对多路径支付的支持，正如上文*新闻*部分中[描述][mpp deployed]的那样。

- [LND #3697][] 将新通道的默认最小 HTLC 值设置为 1 millisatoshis (msat)，低于之前的默认值 1,000 msat。HTLC 的最小值在通道打开后无法更改，因此此更改允许使用此设置的通道接受亚聪支付。[编辑：该段的先前版本错误地声称新最小值为 0 msat；正确值应为 1 msat。]

- [LND #3785][] 基本修复了 [Newsletter #74][news74 c-lightning-3264] 中提到的问题，即 C-Lightning 和 LND 对相同消息使用不同格式，导致解析错误和断开连接。

- [LND #3702][] 扩展了 `closechannel` RPC，增加了一个 `delivery_address` 参数，可以用来请求共同关闭通道并将资金发送到指定地址。如果用户之前启用了[上周的 Newsletter][news76 upfront shutdown] 中描述的前置关闭脚本功能，该方法将无法使用。

- [LND #3415][] 允许通过多路径支付结算发票，增加了 LND 中对基础多路径支付支持所需的最终代码（参见上文 *新闻* 部分中关于多路径支付的[描述][mpp deployed]）。

- [BOLTs #643][] 增加了基础多路径支付支持，正如上文*新闻*部分中[描述][mpp deployed]的那样。这实现了在一年前的闪电规范 1.1 会议期间设定的[主要目标][news22 multipath]之一，以帮助[显著改善 LN 钱包用户体验][news22 ux]。

## 节假日出版安排

我们将不会在 12 月 25 日或 1 月 1 日发布 Newsletter。相反，我们将在 12 月 28 日星期六发布第二期年度回顾特别报告。常规 Newsletter 将于 1 月 8 日星期三恢复发布。

节日快乐！

{% include linkers/issues.md issues="17678,12763,3309,3697,3785,3702,3415,643" %}
[lnd 0.8.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.8.2-beta
[wuille bech32 post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-December/017521.html
[wuille bech32 analysis]: https://gist.github.com/sipa/a9845b37c1b298a7301c33a04090b2eb
[news75 cl mainnet]: /zh/newsletters/2019/12/04/#c-lightning-3268
[news72 bech32]: /zh/newsletters/2019/11/13/#taproot-review-discussion-and-related-information
[news74 bech32]: /zh/newsletters/2019/11/27/#how-does-the-bech32-length-extension-mutation-weakness-work
[news76 bech32]: /zh/newsletters/2019/12/11/#lnd-3767
[news75 ctv]: /zh/newsletters/2019/12/04/#op-checktemplateverify-ctv
[news22 multipath]: /zh/newsletters/2018/11/20/#multi-path-payments
[news22 ux]: /zh/newsletters/2018/11/20/#multipath-splicing-ux
[power]: https://en.wikipedia.org/wiki/IBM_POWER_instruction_set_architecture
[s390x]: https://en.wikipedia.org/wiki/Linux_on_IBM_Z
[cl 0.8.0]: https://github.com/ElementsProject/lightning/releases/tag/v0.8.0rc2
[riard eclipse]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-December/002369.html
[corallo eclipse]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-December/002370.html
[zmn eclipse]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-December/002372.html
[mpp deployed]: #ln-implementations-add-multipath-payment-support
[news74 c-lightning-3264]: /zh/newsletters/2019/11/27/#c-lightning-3264
[news76 upfront shutdown]: /zh/newsletters/2019/12/11/#lnd-3655
[rubin ctv update]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-December/017525.html
[bitfinex ln blog]: https://www.bitfinex.com/posts/440
[bitmex bech32 blog]: https://blog.bitmex.com/bitmex-enables-bech32-sending-support/
[bitmex ln penalty blog]: https://blog.bitmex.com/lightning-network-part-5-bitmex-research-launches-penalty-transaction-alert-system/
[fork monitor lightning]: https://forkmonitor.info/lightning
[unchained caravan blog]: https://www.unchained-capital.com/blog/the-caravan-arrives/
[unchained caravan github]: https://github.com/unchained-capital/caravan
[bech32 news]: #analysis-of-bech32-error-detection
[bech32 python]: https://github.com/sipa/bech32/tree/master/ref/python
[mpp cl]: #c-lightning-3309
[mpp eclair]: /zh/newsletters/2019/11/20/#eclair-1153
[mpp lnd]: #lnd-3415
[review club notes]: https://bitcoincore.reviews/16702.html
