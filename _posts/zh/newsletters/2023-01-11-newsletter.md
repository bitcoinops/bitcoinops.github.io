---
title: 'Bitcoin Optech Newsletter #233'
permalink: /zh/newsletters/2023/01/11/
name: 2023-01-11-newsletter
slug: 2023-01-11-newsletter
type: newsletter
layout: newsletter
lang: zh
---
本周的周报介绍了一种让离线的闪电节点也能在链上接收资金、且这些资金无需额外的时延就可以在链下使用的想法。此外还有我们的常规部分：软件的新版本和候选版本的总结；热门的比特币基础设施项目的重大变更介绍。

## 新闻

- **<!--noninteractive-ln-channel-open-commitments-->非交互的闪电通道开启承诺**：开发者 ZmnSCPxj 和 Jesse Posner 在闪电网络开发者邮件组中[发帖][zp potentiam]，提出了一种开启闪电通道的新技术；他们称之为 “*swap-in-ptentiam*”。现有的开启闪电通道的方法要求两位参与者在资金存入通道之前签名一笔退款交易。为了创建退款，需要知晓注资行为的细节，所以现有的闪电通道开启技术需要交互：注资者需要告诉对手方他们准备提供的资金；对手方需要创建和签名一笔退款交易；然后注资者需要签名并广播一笔注资交易。

    这种提议的作者们指出，现在的技术对一些钱包软件来说是很成问题的，尤其是在移动设备上运行的钱包，它们也许会离线、做不到随时响应。对于这些钱包，创建一个应急的在线地址，用于在他们的闪电节点无法响应时接收资金，是合理的。当这个钱包下一次上线时，他们可以使用这笔链上资产来开设一条新的闪电通道。但是，新的闪电通道需要得到合理深度的区块确认（例如 6 个区块），然后对手方（未投入资金的一方）才可以安全、免信任地转发注资方的支付。这意味着，这样的手机钱包的用户，如果在自己的节点离线时收到了支付，就需要在上线后再等待 6 个区块才能使用这笔资金发起新的闪电支付。
    
    因此，作者们提出了另一种办法：用户 Alice 提前选择一个对手方（Bob），这个对手方是 Alice 认为可以做到全时段响应的（例如，某个闪电网络服务供应商）。Alice 和 Bob 合作创建一个链上地址，其资金可以用 Alice 的签名，加上 Bob 的签名来花费；也可以由 Alice 在几周的时间锁（比如 6000 个区块）过期后独自花费，[例如][potentiam minsc]：

    ```hack
    pk(A) && (pk(B) || older(6000))
    ```
    
    这个地址可以从 Alice 离线开始持续积累资金。在这些支付的时间锁到期之前，任何花费资金的尝试都必须得到 Bob 的支持。只要 Bob 仅在 Alice 也签名一次花费操作的时候签名，Bob 就可以确定 Alice 无法在时间锁过期之前花费这些资金。Alice 的花费变成无效操作的唯一可能是，早先给她的支付被重复花费掉了。只要这些支付在 Alice 上线并发起花费操作之前得到了足够多的区块确认，重复花费就是不可能的。
    
    这使得 Alice 可以在钱包离线时接收支付、在支付获得至少 6 次区块确认（但少于 6000 次确认）后立即跟 Bob 联合签名开启一条闪电通道，因为 Bob 知道她没法重复花费这笔资金。甚至在通道创建交易得到区块确认之前，Bob 就可以安全且免信任地转发 Alice 的支付。或者，如果 Alice 和 Bob 双方都已经有闪电通道了（不论是彼此开设的还是跟其他人开设的），Bob 可以给 Alice 发送一笔闪电支付，她若要拿走就得使用链上资金给 Bob 支付。此外，如果 Alice 的钱包回到链上时，她决定在链上做一笔常规的支付，她只需要联系 Bob 的钱包要求一同签名即可。在最糟糕的情况下，假如 Bob 不合作，Alice 也只需等待几周，就可以花自己的钱，Bob 是拦不住的。
    
    除了让离线的钱包可以接收闪电网络的资金，作者们还介绍了这种想法可以跟 “[异步支付][topic async payments]” 结合的做法，由此，闪电网络服务商可以提前准备好通道再平衡操作，当离线的客户端回到线上时，这些再平衡操作可以立即生效、无需等待（从用户的角度看是这样）。举个例子，如果 Carol 给 Alice 发送了一笔 async 闪电支付，并且金额大于 Alice 当前在通道中的可用容量，Bob 可以发送支付到脚本  `pk(B) && (pk(A) || older(6000))` 中。这种另类的脚本改变了 Alice 和 Bob 的角色。如果 Bob 的支付在 Alice 下次上线之前得到了足够多的区块确认，Alice 可以立即将这笔支付更新为一条新的闪电通道，然后让 Bob 通过新的通道转发异步支付、保持闪电网络的通常的安全属性和免信任性。
    
    截至本稿撰写之时，这个想法在邮件组中收到了一定数量的讨论，还有几个评论尝试搞清楚这个想法的一些侧面，至少一条[评论][fournier potentiam]强烈支持整个概念。

## 新版本与候选版本

*热门的比特币基础设施项目的新版本与候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [BDK 0.26.0][] 是这个用于开发钱包的工具库的新版本。
- [HWI 2.2.0-rc1][] 是一个候选版本，这个软件让软件钱包可以跟硬件签名设备交互。

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo] 和 [Lightning BOLTs][bolts repo]。*

- [Eclair #2455][] 再洋葱失败消息中实现了对可选的 类型-长度-数值（TLV）流的支持（这个特性[刚刚由][bolts #1021] BOLT 04 引入）。TLV 流运行节点返回额外的关于路由失败的细节，并且可能用于已经提出的“[详尽报错][news224 fat]” 方案，进一步解决错误归因上的问题。

{% include references.md %}
{% include linkers/issues.md v=2 issues="2455,1021" %}

[bdk 0.26.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.26.0
[hwi 2.2.0-rc1]: https://github.com/bitcoin-core/HWI/releases/tag/2.2.0-rc.1
[zp potentiam]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-January/003810.html
[potentiam minsc]: https://min.sc/#c=pk%28A%29%20%26%26%20%28pk%28B%29%20%7C%7C%20older%286000%29%29
[fournier potentiam]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-January/003813.html
[news224 fat]: /en/newsletters/2022/11/02/#ln-routing-failure-attribution
