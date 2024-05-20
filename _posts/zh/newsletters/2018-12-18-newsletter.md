---
title: "Bitcoin Optech Newsletter #26"
permalink: /zh/newsletters/2018/12/18/
name: 2018-12-18-newsletter-zh
slug: 2018-12-18-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了用于带宽高效集和解的新 libminisketch 库，链接到关于 Schnorr/Taproot 计划的电子邮件，并提到即将召开的 LN 协议规范会议。还包括过去一周来自流行的比特币基础设施项目的几个值得注意的代码更改。

## 行动项

- **<!--help-test-bitcoin-core-0-17-1rc1-->****帮助测试 Bitcoin Core 0.17.1RC1：** 该[维护版本][maintenance release]的第一个候选版本已被[上传][V0.17.1rc1]。企业和个人用户对守护程序和 GUI 的测试非常受欢迎，并有助于确保高质量的发布。

## 新闻

- **<!--minisketch-library-released-->****Minisketch 库发布：** 比特币开发人员 Pieter Wuille、Gregory Maxwell 和 Gleb Naumenko 一直在研究[优化的交易中继][optimized transaction relay]，如 [Newsletter #9][] 的新闻部分所述。这项研究的一个结果是他们发布了一个新的独立库，[libminisketch][]，它允许在大约预期差异本身的字节大小内传输两个信息集之间的差异。这可能听起来不令人兴奋——`rsync` 工具已经这样做了超过二十年——但 libminisketch 允许在不知道差异是什么的情况下传输它们。

  例如，Alice 有元素 1、2 和 3。Bob 有元素 1 和 3。尽管双方都不知道对方有哪些元素，Alice 可以发送一个大小为单个元素的*草图*给 Bob，该草图包含足够的信息让他重建元素 2。如果 Bob 拥有元素 1 和 2（没有 3），相同的草图可以让他重建元素 3。或者，如果 Bob 向 Alice 发送一个基于他两个元素集的草图，而 Alice 有她的三个元素集，她可以确定 Bob 缺少哪个元素并直接发送给他。

  这些草图可以为比特币 P2P 网络的未确认交易中继提供一种强大的新优化方式。当前的 gossip 机制让每个节点为其每个对等节点接收或发送每个交易的 32 字节标识符。例如，如果你有 100 个对等节点，你会发送或接收 3200 字节的公告，加上开销，对于一个平均仅 400 字节的交易。使用[模拟器][naumenko relay simulator]进行的早期估算表明，结合仅用于中继的缩短交易标识符的草图可以将总交易传播带宽减少 44 倍。草图还具有提供其他期望特性的潜力——例如，LN 协议开发人员 Rusty Russell 在 Lightning-Dev 邮件列表上发起了一个[线程][ln minisketch]，讨论使用它们发送 LN 路由表更新。

- **<!--description-about-what-might-be-included-in-a-schnorr-taproot-soft-fork-->****关于 Schnorr/Taproot 软分叉可能包含内容的描述：** 比特币协议开发人员 Anthony Towns 发布[发布][towns schnorr taproot]了一封电子邮件，详细描述了他认为应该包含在一个增加 Schnorr 签名方案和 Taproot 风格 MAST 的软分叉中的内容。这不是正式提案，但它类似于我们从其他开发人员那里听到的意见，因此应该提供当前思路的良好概述。

- **<!--ln-protocol-irc-meeting-->****LN 协议 IRC 会议：** LN 的协议开发人员同意在收到一些开发人员的请求后，将他们定期举行的 LN 规范开发会议从 Google Hangout 转为 IRC 会议。[下次会议][ln irc meeting]将于 1 月 8 日星期二 19:00（UTC）举行。

## 值得注意的代码更改

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-lightning][core lightning repo] 和 [libsecp256k1][libsecp256k1 repo] 中值得注意的代码更改。*

- [Bitcoin Core #14573][] 将 Bitcoin-Qt GUI 中打开单独对话框的各种杂项选项移动到一个新的顶级菜单项*窗口*，希望使这些选项更容易找到和使用。

- [LND #1984][] 添加了一个新的 `listunspent` RPC，列出钱包的每个未花费输出。它可以接受两个参数：（1）未花费输出必须具有的最小确认次数或（2）它可以具有的最大确认次数。最小值可以设置为 `0` 以打印未确认的输出。

- [LND #2039][] 增加了获取自动驾驶仪功能状态的能力，并允许在程序运行时启用或禁用它。自动驾驶仪是软件在用户首次连接到 LN 或需要额外支出能力时自动建议新通道打开的能力。

- [C-Lightning #2155][] 默认禁用[Newsletter #10][] 值得注意的提交中描述的 `option_data_loss_protect` 功能。该功能无法可靠工作，因此它将仅为选择加入实验功能的用户启用。

- [C-Lightning #2154][] 现在允许插件发送将被写入 lightningd 日志文件的日志通知。

- [C-Lightning #2161][] 添加了一个小型 Python 库和框架，可用于编写插件。它提供了类似于流行的 [flask][] 库的[功能装饰器][function decorators]，可用于将函数标记为提供特定插件接口，并且此信息会自动用于生成插件清单。示例 `helloworld.py` 插件已更新以使用该库，其大小减少了 75%（从 111 行到 28 行）。

## 假期出版安排

由于假期原因，Optech Newsletter 将不会在 12 月 25 日或 1 月 1 日发布 Newsletter。相反，我们将在 12 月 28 日星期五发布一份特别的年度回顾 Newsletter，并将于 1 月 8 日星期二恢复常规的周二发布计划。


{% include references.md %}
{% include linkers/issues.md issues="1984,2039,2324,14573,2155,2154,2132,2161" %}
[V0.17.1rc1]: https://bitcoincore.org/bin/bitcoin-core-0.17.1/
[maintenance release]: https://bitcoincore.org/en/lifecycle/#maintenance-releases
[maxwell-todd por]: https://web.archive.org/web/20170928054354/https://iwilcox.me.uk/2014/proving-bitcoin-reserves
[boneh-et-al por]: http://www.jbonneau.com/doc/DBBCB15-CCS-provisions.pdf
[towns schnorr taproot]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-December/016556.html
[ln irc meeting]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-December/001737.html
[function decorators]: https://www.thecodeship.com/patterns/guide-to-python-function-decorators/
[flask]: http://flask.pocoo.org/
[ln minisketch]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-December/001741.html
[optimized transaction relay]: http://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2018-10-08-efficient-p2p-transaction-relay/
[naumenko relay simulator]: https://github.com/naumenkogs/Bitcoin-Simulator
[newsletter #9]: /zh/newsletters/2018/08/21/#bandwidth-efficient-set-reconciliation-protocol-for-transactions
[newsletter #10]: /zh/newsletters/2018/08/28/#c-lightning-1854