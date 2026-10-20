---
title: 'Bitcoin Optech Newsletter #182'
permalink: /zh/newsletters/2022/01/12/
name: 2022-01-12-newsletter-zh
slug: 2022-01-12-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周 Newsletter 阐述了一项在比特币中增设账户用于支付交易手续费的构想，并包含常规栏目：Bitcoin Core PR 审查俱乐部会议摘要，以及热门比特币基础设施项目的值得注意的变更说明。

## 新闻

- ​**​<!--fee-accounts-->​**​**​手续费账户：​**​ Jeremy Rubin 在 Bitcoin-Dev 邮件列表[发布][rubin feea]了一项软分叉的初步构想，它可以让 LN 等合约协议中使用的预签名交易（presigned transaction）更容易追加手续费。此构想由他在 [Newsletter #116][news116 sponsorship] 中描述的交易赞助（transaction sponsorship）思路发展而来。

  手续费账户的基本思路是：用户可以创建一笔交易，把比特币存入一个由升级后全节点追踪的账户，这些节点理解新的共识规则。当用户随后想为某笔交易追加手续费时，可以签署一条短消息，内容包含他想支付的金额以及该交易的 txid。升级后的全节点会允许任何同时包含该交易和该签名消息的区块，把签名的手续费金额支付给该区块的矿工。

  Rubin 认为，这样可以消除[子为父付（CPFP）][topic cpfp] 和 [RBF][topic rbf] 手续费追加在合约协议中遇到的许多问题，尤其是两个或更多用户共享某个 UTXO 所有权的情形；也包括其他一些情况：由于使用了预签名交易，当初签名时根本无法知道当前的网络费率。

## Bitcoin Core PR 审查俱乐部

*在这个每月栏目中，我们总结近期一次 [Bitcoin Core PR 审查俱乐部][Bitcoin Core PR Review Club] 会议，重点介绍其中一些重要的问题与解答。点击下面的问题，可查看会议对该问题的回答摘要。*

[Erlay 支持信令][reviews 23443] 是 Gleb Naumenko 提交的一个 PR，为 p2p 代码加入交易协调协商。它是一系列为 Bitcoin Core 添加 [Erlay][topic erlay] 支持的 PR 之一。本次审查会议讨论了协调握手协议，并权衡了把大型项目拆分成较小单元的利弊。

{% include functions/details-list.md
  q0="<!--q0-->拆分 PR 有何益处？是否存在弊端？"
  a0="把大型 PR 拆成较小的块，有助于在合并前对 PR 进行更聚焦、更彻底的审查，也不必要求审查者一次面对庞大的变更集；同时还能降低因 GitHub 扩展性问题而遇到审查障碍的几率。没有争议的机械性代码可以更快合并，有争议的部分则可以留出更多时间讨论。然而，除非审查者在概念上认可整个变更集，否则他们只能信任作者正把他们带往正确的方向。此外，由于合并不是原子性的，作者需要确保中间状态既不是不安全的，也不是无意义的，例如在节点实际还无法进行协调时就宣告支持 Erlay。"
  a0link="https://bitcoincore.reviews/23443#l-29"

  q1="<!--q1-->节点何时宣告支持协调协议？"
  a1="只有当这条连接上的交易中继处于开启状态时，节点才应向对等节点发送 `sendrecon`：即节点未处于 blocksonly 模式、这不是一条仅中继区块的连接，且对等节点没有发送 `fRelay=false`。对等节点还必须支持见证交易标识符（wtxid）中继，因为用于交易协调的概要（sketch）是基于交易的 wtxid 构建的。"
  a1link="https://bitcoincore.reviews/23443#l-51"

  q2="<!--q2-->完整的握手和协调注册流程是怎样的？"
  a2="在发送 `version` 消息之后、发送 `verack` 消息之前，双方各自发送一条 `sendrecon` 消息，其中包含诸如本地生成的盐值等信息。没有强制的顺序；任一方都可以先发送。如果节点发送并收到了一条有效的 `sendrecon` 消息，它就应当为该对等节点初始化协调状态。"
  a2link="https://bitcoincore.reviews/23443#l-63"

  q3="<!--q3-->为何 Erlay 不包含 p2p 协议版本号的升级？"
  a3="要让功能正常工作，并不需要新的协议版本；使用 Erlay 的节点不会与现有协议不兼容。不认识 `sendrecon` 等 Erlay 消息的旧节点会直接忽略它们，仍能正常运作。"
  a3link="https://bitcoincore.reviews/23443#l-78"

  q4="<!--q4-->为什么要为每条连接在本地生成盐值？它是如何生成的？"
  a4="一条连接的协调盐值由双方各自本地生成的盐值组合而成，用于为每笔交易生成短 ID（shortid）。用于短 ID 的加盐哈希函数旨在高效地生成紧凑 ID，但如果攻击者能控制盐值，它并不保证能抵御碰撞。当双方都参与生成盐值时，任何第三方都无法控制盐值。在本地，每条连接都会生成新的盐值，这样节点就无法通过这种方式被指纹识别。"
  a4link="https://bitcoincore.reviews/23443#l-93"
%}

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]的值得注意的变更。*

- [Bitcoin Core #23882][] 更新了 `validation.cpp` 中关于 testnet3 运行的文档说明。

  在比特币最早的版本中，交易的内容可能完全相同，因此 txid 会冲突。这种重复问题尤其容易出现在币基交易上：每个币基交易的输入和输出组成有一部分是相同的，其余部分则完全由区块模板的创建者决定。主网区块链上存在两笔重复的币基交易，分别位于高度 91,842 和 91,880。它们与之前的币基交易完全相同，在被花费之前就覆盖了已有的币基输出，使可用总供应量减少了 100 BTC。这些事件促使 [BIP30][] 出台，禁止重复交易。BIP30 的强制执行是这样[实现][bip30-impl]的：对每笔交易检查其 txid 是否已经存在未花费输出。后来引入的 [BIP34][] 要求把区块高度作为币基交易 scriptSig 的第一项，从而有效防止了重复问题。由于高度是唯一的，币基交易的内容在不同高度上不再可能相同，这也就归纳性地防止了后代交易出现同样问题，因而不再需要额外检查重复。

  后来人们发现 [BIP34][] 存在缺陷：在它引入之前，就已经存在一些币基交易，其内容恰好符合未来某些区块高度的模式。矿工最早能够制造出违反 BIP30 的碰撞的区块高度是 1,983,702，我们预计主网要到 2040 年之后才会达到这一高度。然而 testnet3 在此期间已经超过了 1,983,702 的高度。因此 Bitcoin Core 回退为对 testnet 的每一笔交易都执行未花费交易重复检查。

- [Eclair #2117][] 新增对[洋葱消息][topic onion messages]回复处理的支持，为后续实现 [offers 协议][topic offers]做准备。

- [LND #5964][] 新增 `leaseoutput` RPC，用于告知钱包在指定时间段内不要花费指定的 UTXO。这与其他钱包软件提供的 RPC 类似，例如 Bitcoin Core 的 `lockunspent`。

- [BOLTs #912][] 为 [BOLT11][] 发票新增一个可选字段，用于承载接收方提供的元数据。如果发票中使用该字段，付款节点可能需要在它通过网络路由给接收方的支付消息中包含这些元数据。接收方随后可以在处理支付时使用这些元数据，例如最初提出的用途——利用这些信息实现[无状态发票][topic stateless invoices]（参见 [Newsletter #168][news168 stateless]）。

- [BOLTs #950][] 为 [BOLT1][] 引入向后兼容的警告消息，并放宽了发送致命错误的要求，从而避免不必要的通道关闭。这是迈向更标准化、更丰富的错误信息的第一步。更多讨论见 [BOLTs #834][] 以及 Carla Kirk-Cohen 发到 Lightning-dev 邮件列表的[帖子][Error Codes for LN]（参见 [Newsletter #136][news136 warning post]）。

{% include references.md %}
{% include linkers/issues.md issues="23882,2117,5964,912,950,834,23443" %}
[rubin feea]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019724.html
[news116 sponsorship]: /zh/newsletters/2020/09/23/#transaction-fee-sponsorship
[news168 stateless]: /zh/newsletters/2021/09/29/#stateless-ln-invoice-generation
[reviews 23443]: https://bitcoincore.reviews/23443
[Error Codes for LN]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-February/002964.html
[news136 warning post]: /zh/newsletters/2021/02/17/#c-lightning-4364
[bip30-impl]: https://github.com/bitcoin/bitcoin/pull/915/files
