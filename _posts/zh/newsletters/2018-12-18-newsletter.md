---
title: "Bitcoin Optech Newsletter #26"
permalink: /zh/newsletters/2018/12/18/
name: 2018-12-18-newsletter-zh
slug: 2018-12-18-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 介绍了用于带宽高效集合协调（set reconciliation）的新库 libminisketch，给出了关于 Schnorr/Taproot 计划的一封电子邮件的链接，并提到即将召开的 LN 协议规范会议。文中还包括一份过去一周热门比特币基础设施项目中值得注意的代码变更清单。

## 行动项

- **<!--help-test-bitcoin-core-0-17-1rc1-->****帮助测试 Bitcoin Core 0.17.1RC1：** 这个[维护版本][maintenance release]的第一个候选发布已经[上传][V0.17.1rc1]。我们非常欢迎企业和个人用户测试守护进程和 GUI，这有助于确保发布质量达到最高。

## 新闻

- **<!--minisketch-library-released-->****Minisketch 库发布：** 比特币开发者 Pieter Wuille、Gregory Maxwell 和 Gleb Naumenko 一直在研究[优化的交易中继][optimized transaction relay]，如 [Newsletter #9][] 的新闻部分所述。这项研究的一个成果，是他们发布了一个新的独立库 [libminisketch][]：它能在两组信息之间传输差异，而传输量约为这些差异本身预期的字节数。这听起来也许不算令人兴奋——`rsync` 工具已经这样做了二十多年——但 libminisketch 传输差异时*无需事先知道差异是什么*。

  举例来说，Alice 有元素 1、2 和 3，Bob 有元素 1 和 3。尽管双方都不知道对方有哪些元素，Alice 仍可以给 Bob 发送一个大小相当于单个元素的*草图*（sketch），其中包含足够的信息，让他重建出元素 2。如果 Bob 的元素换成 1 和 2（没有 3），完全相同的草图又能让他重建出元素 3。或者，Bob 用自己的两个元素发送一个草图给 Alice，而 Alice 拥有三个元素的集合，她就能确定 Bob 缺的是哪个元素，并直接发给他。

  这些草图可以为比特币 P2P 网络的未确认交易中继提供一种强大的新优化方式。当前的流言（gossip）机制下，每个节点要为它的每个对等节点接收或发送每笔交易的 32 字节标识符。例如你有 100 个对等节点，那么你收发的公告就是 3200 字节，还要加上额外开销，而对应的交易平均只有 400 字节。用[模拟器][naumenko relay simulator]做出的早期估算表明，把草图与缩短的交易标识符（仅用于中继）结合起来，可将交易传播的总带宽缩减到原来的 1/44。草图还有望带来其他有用的特性——例如 LN 协议开发者 Rusty Russell 在 Lightning-Dev 邮件列表上开了一个[讨论帖][ln minisketch]，讨论用草图来发送 LN 路由表更新。

- **<!--description-about-what-might-be-included-in-a-schnorr-taproot-soft-fork-->****关于 Schnorr/Taproot 软分叉可能包含哪些内容的描述：** 比特币协议开发者 Anthony Towns [发表][towns schnorr taproot]了一封写得很好的电子邮件，描述了他认为为比特币增加 Schnorr 签名方案和 Taproot 风格 MAST 的软分叉中应当包含哪些内容。这不是正式提案，但与其他开发者表达的意见相近，因此应该能很好地概括当前的思路。

- **<!--ln-protocol-irc-meeting-->****LN 协议 IRC 会议：** 在收到多位开发者的请求后，LN 协议开发者同意把他们定期举行的 LN 规范制定会议从 Google Hangout 改为 IRC 会议。[下次会议][ln irc meeting]将于 1 月 8 日星期二 19:00（UTC）举行。

## 值得注意的代码变更

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-lightning][core lightning repo] 和 [libsecp256k1][libsecp256k1 repo] 中值得注意的代码变更。*

- [Bitcoin Core #14573][] 把 Bitcoin-Qt GUI 中会打开独立对话框的各种杂项选项，移到一个名为*窗口*（Window）的新顶级菜单项下，希望让这些选项更容易找到和使用。

- [LND #1984][] 新增 `listunspent` RPC，列出钱包的每个未花费输出。它可以接受两个参数：（1）未花费输出必须具有的最小确认次数，或（2）它可以具有的最大确认次数。把最小值设为 `0` 可以列出未确认的输出。

- [LND #2039][] 增加了获取自动巡航（autopilot）功能状态的能力，并允许在程序运行期间启用或禁用它。自动巡航是指软件在用户首次接入 LN 或需要更多支付能力时，自动建议打开新通道的功能。

- [C-Lightning #2155][] 默认禁用[Newsletter #10][] 值得注意的提交中描述的 `option_data_loss_protect` 功能。该功能无法可靠工作，因此只会对自愿启用实验功能的用户开启。

- [C-Lightning #2154][] 现在允许插件发送将被写入 lightningd 日志文件的日志通知。

- [C-Lightning #2161][] 新增了一个小型 Python 库和框架，可用于编写插件。它提供的[函数装饰器][function decorators]与流行的 [flask][] 库类似，可用来把函数标记为提供某个特定的插件接口，这些信息会自动用于生成插件清单（manifest）。示例插件 `helloworld.py` 已改为使用该库，体积缩小了 75%（从 111 行减到 28 行）。

## 假期发布安排

由于假期原因，Optech Newsletter 将不会在 12 月 25 日或 1 月 1 日发布 Newsletter。取而代之的是，我们将在 12 月 28 日星期五发布一份特别的年度回顾 Newsletter，并从 1 月 8 日起恢复常规的周二发布计划。


{% include references.md %}
{% include linkers/issues.md issues="1984,2039,2324,14573,2155,2154,2132,2161" %}
[V0.17.1rc1]: https://bitcoincore.org/bin/bitcoin-core-0.17.1/
[maintenance release]: https://bitcoincore.org/en/lifecycle/#maintenance-releases
[maxwell-todd por]: https://web.archive.org/web/20170928054354/https://iwilcox.me.uk/2014/proving-bitcoin-reserves
[boneh-et-al por]: http://www.jbonneau.com/doc/DBBCB15-CCS-provisions.pdf
[towns schnorr taproot]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-December/016556.html
[ln irc meeting]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-December/001737.html
[function decorators]: https://www.thecodeship.com/patterns/guide-to-python-function-decorators/
[flask]: http://flask.pocoo.org/
[ln minisketch]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-December/001741.html
[optimized transaction relay]: http://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2018-10-08-efficient-p2p-transaction-relay/
[naumenko relay simulator]: https://github.com/naumenkogs/Bitcoin-Simulator
[newsletter #9]: /zh/newsletters/2018/08/21/#bandwidth-efficient-set-reconciliation-protocol-for-transactions
[newsletter #10]: /zh/newsletters/2018/08/28/#c-lightning-1854