---
title: 'Bitcoin Optech Newsletter #216'
permalink: /zh/newsletters/2022/09/07/
name: 2022-09-07-newsletter-zh
slug: 2022-09-07-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报汇总了热门的比特币基础设施软件的一些重大变更。

## News

*本周没有重大新闻。*

## 重大代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo] 和 [Lightning BOLTs][bolts repo]。*

- [Bitcoin Core #25717][] 在初始块下载 (IBD) 期间添加了“区块头预同步”步骤，以有助于防止拒绝服务 (DoS) 攻击并逐步移除检查点。节点使用预同步阶段在永久存储其他节点的区块头之前来验证该链已有足够的工作量。

  在 IBD 期间，敌对节点可能会尝试停止同步过程、提供非最多工作量链条的区块，或者只是简单的耗尽节点的资源。因此，虽然同步速度和带宽使用是 IBD 期间的重点，但主要设计目标是要避免拒绝服务攻击。从 v0.10.0 开始，Bitcoin Coin 的节点在下载区块数据之前首先同步块头，并拒绝那些与一组检查点无关的区块头。这种新设计没有使用硬编码，而是利用工作量证明 (PoW) 固有的抗 DoS 特性来尽可能降低找到主链之前分配的内存量。

  通过这些更改，节点在初始区块头同步期间会下载区块头两次：第一次是验证区块头的 PoW（不存储它们）直到累积的工作量达到预定阈值，然后第二次是存储它们。为了防止攻击者在预同步期间发送主链、然后在重新下载期间又发送不同的恶意链，节点会在预同步期间存储对区块头链条的承诺。

- [Bitcoin Core #25355][] 在仅允许出站 [I2P 连接][topic anonymity networks]时增加了对临时、一次性 I2P 地址的支持。在 I2P 中，接收方会获知连接发起方的 I2P 地址。现在默认情况下，非侦听 I2P 节点在进行出站连接时将使用临时 I2P 地址。

- [BDK #689][] 添加了一个 `allow_dust` 方法。该方法允许钱包创建违反[粉尘限制][topic uneconomical outputs]的交易。Bitcoin Core 和其他使用相同设置的节点不会中继未确认的交易，除非每个输出（除了 `OP_RETURN` ）接收到的金额超过了粉尘限制。BDK 一般会通过对其创建的交易实施灰尘限制来防止用户创建此类不可中继的交易，但这个新选项允许忽略该策略。该 PR 的作者提到他们正在使用该选项来测试他们的钱包。

- [BDK #682][] 使用 [HWI][topic hwi] 和 [rust-hwi][rust-hwi github] 库为硬件签名设备添加签名功能。该 PR 还引入了一个用于测试的 Ledger 设备模拟器。

{% include references.md %}
{% include linkers/issues.md v=2 issues="25717,25355,689,682" %}
[rust-hwi github]: https://github.com/bitcoindevkit/rust-hwi
