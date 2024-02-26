---
title: 'Bitcoin Optech Newsletter #268'
permalink: /zh/newsletters/2023/09/13/
name: 2023-09-13-newsletter-zh
slug: 2023-09-13-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报链接到了 taproot assets 相关的草案规范，并总结了 LN 的几种另类消息协议，这些协议可以帮助启用 PTLC。此外还有我们的常规部分：其中包括 Bitcoin Core PR 审核俱乐部会议的总结、新版本和候选版本的公告，以及对热门比特币基础设施项目的重大变更介绍。

## 新闻

- **taproot assets 规范：** Olaoluwa Osuntokun 分别在 Bitcoin-Dev 和 Lightning-Dev 邮件列表上发布了 _Taproot Assets_ 相关的[客户端验证协议][topic client-side validation]。在 Bitcoin-Dev 邮件列表中，他[宣布了][osuntokun bips]七个 BIP 草案————比使用 _Taro_ 这个名称的初始公告(见[周报 #195][news195 taro])所预期的多一个。在 Lightning-Dev 邮件列表中，他[宣布了][osuntokun blip post]一份使用 LN 花费和接收 taproot 资产的 [BLIP 草案][osuntokun blip]，该协议将基于计划在 LND 0.17.0-beta 版本中发布的“简单的 taproot 通道” 的实验性功能。

    请注意，尽管其名称为 Taproot Assets，但它不是比特币协议的一部分，也不会以任何方式更改共识协议。它利用现有功能为选择使用其客户端协议的用户提供新功能。

    截至撰写本文时，这些规范在邮件列表上还没有收到任何讨论。

- **支持 PTLC 的 LN 消息变更：** 随着第一个实验性支持使用 [P2TR][topic taproot] 和 [MuSig2][topic musig] 通道的 LN 实现即将发布，Greg anders 在 Lightning-Dev 邮件列表上[发布了][sanders post]以前讨论过的几种 LN 消息变更的[总结][sanders ptlc]，这些消息旨在支持使用 [PTLCs][topic ptlc] 来代替 [HTLCs][topic htlc] 发送支付。对于大多数方法，消息的变更似乎都不大且不具侵入性，但我们注意到，大多数实现可能会继续使用一组消息来处理传统的 HTLC 转发，同时还提供升级的消息来支持 PTLC 转发，从而创建两个不同的路径，需要并发地进行维护，直到淘汰HTLC。如果一些实现在消息标准化之前添加了实验性 PTLC 支持，那么实现甚至可能需要同时支持三种或更多不同的协议，这对所有人都很不利。

    截止本文撰写时，Sanders 的总结尚未收到任何评论。

## Bitcoin Core PR 审核俱乐部

*在这个月度部分，我们总结了 [Bitcoin Core PR 审核俱乐部][Bitcoin Core PR Review Club]会议，重点介绍了一些重要的问题和答案。单击下面的问题以查看会议答案的总结。*

[Transport abstraction][review club 28165] 是 Pieter Wuille（sipa）最近合并的PR，它引入了_传输_抽象（接口类）。此类的具体派生将（每个对等节点）连接（已序列化的）的发送和接收消息转换为有线格式。这可以被认为是实现更深层次的序列化和反序列化。这些类不执行实际的发送和接收。

PR 从 `Transport` 类派生出两个具体类：`V1Transport` (我们现在拥有的)和 `V2Transport` (线路上加密的)。这个 PR 是 [BIP324][topic v2 p2p transport]_版本 2 P2P 加密传输协议_[项目][v2 p2p tracking pr]的一部分。

{% include functions/details-list.md
  q0="[*net*][net] 和 [*net_processing*][net_processing] 之间有什么区别？"
  a0="*Net* 位于网络堆栈的底部，处理对等节点之间的低级通信，而 *net_processing* 构建在 *net* 层之上，处理来自 *net* 层的消息的处理和验证。"
  a0link="https://bitcoincore.reviews/28165#l-22"

  q1="更具体地说，列出我们与 *net_processing* 相关联的类或函数的示例，相比之下，也列出与 *net* 相关联的？"
  a1="*net_processing*: `PeerManager`，`ProcessMessage`。
      *net*: `CNode`，`ReceiveMsgBytes`， `CConnMan`。"
  a1link="https://bitcoincore.reviews/28165#l-25"

  q2="BIP324 是否需要更改 *net* 层，*net_processing* 层，或是两者都需要？它会影响规则或共识吗？"
  a2="这些变化只会发生在 *net* 层；它们不影响共识。"
  a2link="https://bitcoincore.reviews/28165#l-37"

  q3="有哪些实现漏洞可能导致此 PR 成为（意外）共识更改的例子？"
  a3="将最大消息大小限制为小于 4MB 的漏洞，会导致节点拒绝其他节点认为有效的块；区块反序列化中的漏洞，会导致节点拒绝经过共识验证的区块。"
  a3link="https://bitcoincore.reviews/28165#l-45"

  q4="`CNetMsgMaker` 和 `Transport` 都“序列化”消息。他们所做的有什么区别？"
  a4="`CNetMsgMaker` 将数据结构序列化为字节；`Transport` 接收这些字节，添加（序列化）区块头，然后实际发送它。"
  a4link="https://bitcoincore.reviews/28165#l-60"

  q5="在将应用程序对象如 `CTransactionRef` (transaction) 转换为字节/网络数据包的过程中，会发生什么？在此过程中，它会变成哪些数据结构？"
  a5="`msgMaker.Make()` 通过调用 `SerializeTransaction()` 来序列化 `CTransactionRef` 消息，然后 `PushMessage()` 将序列化的消息放入 `vSendMsg` 队列中，然后 `SocketSendData()` 添加一个区块头/checksum(在此 PR 更改之后)，并要求传输以发送下一个数据包，最后调用 `m_sock->Send()`。"
  a5link="https://bitcoincore.reviews/28165#l-83"

  q6="通过线路发送的 `sendtxrcncl` 消息有多少字节(以 [Erlay][topic erlay] 中使用的该消息为简单示例)?"
  a6="36 字节：区块头为 24 字节（magic 4 字节，command 12 字节，消息大小 4 字节，checksum 4 字节），然后 12 字节用于负载（version 4 字节，salt 8 字节）。"
  a6link="https://bitcoincore.reviews/28165#l-86"

  q7="在 `PushMessage()` 返回后，我们是否已经将与此消息对应的字节发送给对等方（是/否/也许）？为什么？"
  a7="一切皆有可能。**是的**：我们(*net_processing*)无需执行任何其他操作即可发送消息。
      **否**：在函数返回时，接收方极不可能收到它。
      **也许**：如果所有队列都是空的，它将进入内核套接字层，但如果某些队列不是，那么它仍将等待这些队列在到达操作系统之前进一步排出。"
  a7link="https://bitcoincore.reviews/28165#l-112"

  q8="哪些线程访问 `CNode::vSendMsg`？"
  a8="`ThreadMessageHandler`，如果消息是同步发送的（“乐观地”）；`ThreadSocketHandler`，如果消息被排队并稍后提取和发送。"
  a8link="https://bitcoincore.reviews/28165#l-120"
%}

## 版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [LND v0.17.0-beta.rc2][]是这个热门的 LN 节点实现的下一个主要版本的候选版本。此版本计划的一项主要新实验功能（可能会从测试中受益）是对“简单的 taproot 通道”的支持。

## 重大的代码和文档变更

*本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo] 和
[Bitcoin Inquisition][bitcoin inquisition repo]。*

- [Bitcoin Core #26567][] 更新钱包以估算[描述符][topic descriptors]中签名输入的重量，而不是进行签名试运行。即使对于更复杂的 [miniscript][topic miniscript] 描述符，这种方法也会成功，其中试运行方法是不够的。

{% include references.md %}
{% include linkers/issues.md v=2 issues="26567" %}
[LND v0.17.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.0-beta.rc2
[net]: https://github.com/bitcoin/bitcoin/blob/master/src/net.h
[net_processing]: https://github.com/bitcoin/bitcoin/blob/master/src/net_processing.h
[news195 taro]: /en/newsletters/2022/04/13/#transferable-token-scheme
[osuntokun bips]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-September/021938.html
[osuntokun blip post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004089.html
[osuntokun blip]: https://github.com/lightning/blips/pull/29
[review club 28165]: https://bitcoincore.reviews/28165
[sanders post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004088.html
[sanders ptlc]: https://gist.github.com/instagibbs/1d02d0251640c250ceea1c66665ec163
[v2 p2p tracking pr]: https://github.com/bitcoin/bitcoin/issues/27634
