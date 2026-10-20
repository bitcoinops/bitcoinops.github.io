---
title: 'Bitcoin Optech Newsletter #77'
permalink: /zh/newsletters/2019/12/18/
name: 2019-12-18-newsletter-zh
slug: 2019-12-18-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 宣布 LND 0.8.2-beta 发布，邀请大家帮助测试最新的 C-Lightning 候选发布版本，讨论 LN 各实现对基础多路径支付的广泛支持，介绍 bech32 错误检测可靠性的最新进展，汇总拟议的 `OP_CHECKTEMPLATEVERIFY` 操作码的更新，并给出一个关于日食攻击如何影响 LN 通道的讨论链接。此外还有固定栏目：热门比特币基础设施项目的值得注意的变更、服务和客户端软件的变更，以及 Bitcoin Stack Exchange 精选问答。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- **<!--upgrade-to-lnd-0-8-2-beta-->****升级到 LND 0.8.2-beta：** 该[版本][lnd 0.8.2-beta] 包含了若干错误修复和小的用户体验改进，最显著的是静态通道备份的恢复改进。

- **<!--help-test-c-lightning-0-8-0-rc-->****帮助测试 C-Lightning 0.8.0 RC：** 下一个版本的 C-Lightning 的[候选发布版本][cl 0.8.0] 已将默认网络切换为主网而非测试网（见 [Newsletter #75][news75 cl mainnet]），并增加了对基础多路径支付的支持（下文将介绍），还有许多其他功能和错误修复。

- **<!--review-bech32-action-plan-->****审查 bech32 行动计划：** 如下文[所述][bech32 news]，Pieter Wuille 建议把所有 bech32 地址限制为 20 字节或 32 字节的见证程序，以防因涉及以 `p` 结尾的地址的抄录错误而造成资金损失。这条规则已经适用于 P2WPKH 和 P2WSH 所用的 v0 segwit 地址，因此这次变更只是把它扩展到目前预留给未来升级的 v1 及以上地址（例如提议的 [taproot][topic taproot]）。这要求已经实现 bech32 发送支持的钱包和服务升级代码，不过改动应该很小；例如，[Python 参考实现][bech32 python]大概只需这样改：

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

  如果你对这项建议的变更有任何问题或疑虑，请回复下文 *新闻* 部分链接的邮件列表帖子。

## 新闻

- **<!--ln-implementations-add-multipath-payment-support-->****LN 各实现加入多路径支付支持：** 经过大量讨论和开发，Optech 跟踪的三个 LN 实现现已全部加入对[多路径支付][topic multipath payments]的基础支持（合并：[C-Lightning][mpp cl]、[Eclair][mpp eclair]、[LND][mpp lnd]）。多路径支付由多笔经不同路径路由的 LN 支付组成，收款方可以同时领取这些支付。这让用户能在同一笔总支付中花出或接收自己多个通道里的资金，是 LN 可用性的一次重大提升。这一升级意味着付款方尤其不必再过多担心自己在某个通道里有多少余额，因为可以跨所有通道花出全部可用余额（仍受其他 LN 限制约束）。

- **<!--analysis-of-bech32-error-detection-->****bech32 错误检测分析：** Pieter Wuille 向 Bitcoin-Dev 邮件列表发送了一封[邮件][wuille bech32 post]，跟进此前 Newsletter 中描述过的 bech32 可延展性问题（[#72][news72 bech32]、[#74][news74 bech32]、[#76][news76 bech32]）：在 bech32 字符串末尾的 `p` 字符之前，可以添加或删除任意数量的 `q` 字符。Wuille 的[分析][wuille bech32 analysis]表明，这是 bech32 预期错误检测特性中唯一的例外，并且“只需更改 bech32 中的一个常量就能解决该问题”。

  Wuille 计划修订 [BIP173][] 来描述这一弱点，提议把现有 bech32 地址的用途限制为 20 字节或 32 字节的见证程序载荷，并为非比特币用途、以及将来需要使用 20 或 32 字节以外见证程序的情况，定义一个改用另一常量的 bech32 变体。

- **<!--proposed-changes-to-bip-ctv-->****拟议的 bip-ctv 变更：** Jeremy Rubin [建议][rubin ctv update]对拟议软分叉新增的操作码 `OP_CHECKTEMPLATEVERIFY`（CTV）做若干修改。最值得注意的是，这些修改将移除“CTV 所用模板不能通过比特币脚本从其他数据派生”这一限制。此次更新简化了 [Newsletter #75][news75 ctv] 中讨论的脚本语言改动。据我们所知，这些更新都没有以会显著影响此前所述用例的方式改变 CTV 的行为（不过，若你发现有根本性的变化，欢迎在邮件列表上讨论）。

- **<!--discussion-of-eclipse-attacks-on-ln-nodes-->****LN 节点日食攻击的讨论：** Antoine Riard 向 Lightning-Dev 邮件列表[发帖][riard eclipse]，描述了 LN 用户遭遇日食攻击、且攻击者延迟区块中继时可能实施的两种攻击。所谓日食攻击，是指全节点或轻量客户端的所有连接都被同一个攻击者控制——当攻击者是 ISP，或攻击者控制了用户的路由器时，这种情况很容易发生。这样一来，攻击者就能完全控制节点或客户端收发的数据。第一种攻击中，日食攻击者可以发送一笔已撤销的承诺交易，而诚实用户来不及得知并提交相应的惩罚交易，从而让攻击者从诚实用户那里窃取资金。第二种攻击中，攻击者让诚实用户意识不到自己需要广播最新的承诺交易（因为其中一个或多个 HTLC 即将到期）——这样攻击者就能在该 HTLC 到期后窃取其中的资金。

  Riard 的帖子以及 [Matt Corallo][corallo eclipse] 和 [ZmnSCPxj][zmn eclipse] 的回复，讨论了为增强全节点和轻量客户端抗日食攻击能力而过去和当前所做的工作。想进一步了解日食攻击及其缓解措施的读者，也强烈推荐阅读 Bitcoin Core 审查俱乐部上周的[会议记录和日志][review club notes]，他们在其中深入讨论了这一主题。

## 服务和客户端软件的变更

*在本月栏目中，我们重点介绍 Bitcoin 钱包与服务的一些有趣更新。*

- **<!--bitfinex-supports-ln-deposits-and-withdrawals-->****Bitfinex 支持 LN 存取款：** 在[最近的博客文章][bitfinex ln blog]中，Bitfinex 宣布其交易所已支持闪电网络。Bitfinex 用户现在既能用 LN 存款，也能用 LN 取款。

- **<!--bitmex-research-launches-an-ln-penalty-transaction-tracker-->****BitMEX Research 推出 LN 惩罚交易追踪器：** 在 [BitMEX Research 发布的文章][bitmex ln penalty blog]中，开源工具 ForkMonitor 现在会[列出闪电网络的惩罚交易][fork monitor lightning]。该工具还监控多种比特币实现和版本上的 chaintips，用来检测分叉。

- **<!--bitmex-bech32-send-support-->****BitMEX 支持 bech32 发送：** 在[最近的博客文章][bitmex bech32 blog]中，BitMEX 宣布其交易所已支持发送到原生 bech32 地址。文章还概述了他们计划把自家钱包从 P2SH 地址迁移到 P2SH 封装的 segwit 地址。

- **<!--unchained-capital-open-sources-caravan-a-multisig-coordinator-->****Unchained Capital 开源多重签名协调器 Caravan：** 通过一篇[博客文章和演示视频][unchained caravan blog]，Unchained Capital 开源了他们的[多重签名协调器 Caravan][unchained caravan github]。Caravan 是一个无状态 Web 应用，可以借助多种外部密钥库创建多重签名地址并从其花费。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们有点空闲时帮助好奇或困惑用户的地方。在本月栏目中，我们精选自上次更新以来得票最高的一些问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--what-is-the-rationale-for-the-lightning-network-s-path-length-limit-20-hops-->**[Lightning 网络路径长度限制（20 跳）的理由是什么？]({{bse}}92073)： Sergei Tikhomirov 询问了 BOLT4 的 20 跳限制，并比较了 Tor 的洋葱路由与 LN 的 Sphinx。Rene Pickhardt 概述了两种协议的不同之处，以及现行限制背后的动机：让 TCP/IP 数据包保持较小，以及 LN 是小直径网络的假设。

- **<!--is-there-a-way-to-allow-use-of-unconfirmed-rbf-outputs-in-transaction-building-->**[是否有办法在构建交易时使用未确认的 RBF 输出？]({{bse}}92164)： G. Maxwell 指出，对于来自标记支持自愿启用手续费替换（RBF）的交易的输出，Bitcoin Core 的处理方式与来自未标记支持 RBF 的交易的输出完全相同。Bitcoin Core 对某个输出的处理方式，取决于包含该输出的交易是否已确认，以及该交易是否由用户自己的 Bitcoin Core 钱包创建。

- **<!--what-is-the-max-allowed-depth-for-bip32-derivation-paths-->**[BIP32 派生路径允许的最大深度是多少？]({{bse}}92056)： Andrew Chow 解释道，由于 BIP32 为深度字段分配了一个字节，因此派生路径中最多可以有 256 个元素。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中值得注意的变更。*

- [Bitcoin Core #17678][] 增加了对 [S390X][] 和 64 位 [POWER][] CPU 架构的编译支持。

- [Bitcoin Core #12763][] 添加了 RPC 白名单功能，允许你限制特定用户可以运行的 RPC。默认情况下，任何已认证的用户都可以运行任何命令，但新的配置选项 `rpcwhitelist` 和 `rpcwhitelistdefault` 可用于配置哪些用户可以访问哪些 RPC。

- [C-Lightning #3309][] 增加了对多路径支付的支持，正如上文*新闻*部分中[描述][mpp deployed]的那样。

- [LND #3697][] 把新通道的默认最小 HTLC 值设为 1 millisatoshis（msat），低于此前 1,000 msat 的默认值。HTLC 的最小值在通道打开后就无法更改，因此这项变更让采用该设置的通道可以接受低于 1 聪的支付。[编辑：本段的先前版本错误地声称新最小值为 0 msat；正确值为 1 msat。]

- [LND #3785][] 基本修复了 [Newsletter #74][news74 c-lightning-3264] 中提到的问题：C-Lightning 和 LND 对同一种消息使用不同格式，导致解析错误和连接断开。

- [LND #3702][] 扩展了 `closechannel` RPC，新增 `delivery_address` 参数，可用于在请求双方共同关闭通道时把资金发送到指定地址。如果用户此前启用了[上周 Newsletter][news76 upfront shutdown] 中描述的预先关闭脚本功能，这个参数就不起作用了。

- [LND #3415][] 允许通过多路径支付来结算发票，为 LND 中基础多路径支付支持补上了最后一块必需代码（参见上文 *新闻* 部分对多路径支付的[介绍][mpp deployed]）。

- [BOLTs #643][] 加入了基础多路径支付支持，正如上文*新闻*部分[所述][mpp deployed]。这实现了[主要目标][news22 multipath]之一——该目标在一年前的闪电规范 1.1 会议上设定，用以[显著改善 LN 钱包的用户体验][news22 ux]。

## 假期发布安排

我们不会在 12 月 25 日或 1 月 1 日发布 Newsletter。作为替代，我们将在 12 月 28 日星期六发布第二份年度回顾特别报告。常规 Newsletter 将于 1 月 8 日星期三恢复发布。

节日快乐！

{% include linkers/issues.md issues="17678,12763,3309,3697,3785,3702,3415,643" %}
[lnd 0.8.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.8.2-beta
[wuille bech32 post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-December/017521.html
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
[riard eclipse]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-December/002369.html
[corallo eclipse]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-December/002370.html
[zmn eclipse]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-December/002372.html
[mpp deployed]: #ln-implementations-add-multipath-payment-support
[news74 c-lightning-3264]: /zh/newsletters/2019/11/27/#c-lightning-3264
[news76 upfront shutdown]: /zh/newsletters/2019/12/11/#lnd-3655
[rubin ctv update]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-December/017525.html
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
