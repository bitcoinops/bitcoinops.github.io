---
title: 'Bitcoin Optech Newsletter #182'
permalink: /zh/newsletters/2022/01/12/
name: 2022-01-12-newsletter-zh
slug: 2022-01-12-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周 Newsletter 阐述了一项在比特币中增设手续费支付账户的构想，并包含常规栏目：Bitcoin Core PR 审查俱乐部会议摘要及热门比特币基础设施项目的重大变更说明。

## 新闻

- ​**​<!--fee-accounts-->​**​**​手续费账户：​**​ Jeremy Rubin 在 Bitcoin-Dev 邮件列表[发布][rubin feea]了一项软分叉构想，旨在简化 LN 等合约协议中预设交易的手续费追加流程。此构想发轫于他在 [Newsletter #116][news116 sponsorship] 提及的交易发起思路。

  基本思路是用户可将比特币存入支持新共识规则的全节点追踪账户。当需要为交易追加手续费时，用户签署包含金额与交易 txid 的短消息。升级节点将允许打包该交易及签名消息的区块矿工收取对应手续费。

  Rubin 认为此方案能规避 [CPFP][topic cpfp] 和 [RBF][topic rbf] 在合约协议中的痛点——尤其当多个用户共享 UTXO 所有权或预设交易因历史签名无法预知当前费率的情形。

## Bitcoin Core PR 审查俱乐部

*本节总结近期 [Bitcoin Core PR 审查俱乐部][Bitcoin Core PR Review Club]会议内容，精编重要问答。点击问题可查看会议讨论摘要。*

[Erlay 协议支持][reviews 23443] 是由 Gleb Naumenko 提交的 PR，旨在优化 P2P 协议的[交易协调][topic erlay]协商机制。审查会议探讨了协调握手协议及拆分大型项目的利弊。

{% include functions/details-list.md
  q0="<!--q0-->拆分 PR 有何益处？是否存在弊端？"
  a0="拆分功能可提升评审专注度，避免大规模变更引发评审瓶颈，同时规避 GitHub 的性能限制。无争议的机械性代码可快速合并，争议部分留出讨论时间。但评审者需信任作者方向正确。此外非原子化合并需确保中间态安全性，例如避免节点声明支持 Erlay 却无法实际协调。"
  a0link="https://bitcoincore.reviews/23443#l-29"

  q1="<!--q1-->节点何时宣告支持协调协议？"
  a1="当连接开启交易中继（非仅区块中继模式）、且对等节点支持 wtxid 中继时才发送 `sendrecon` 消息，因协调依赖交易 wtxid 构建概要。"
  a1link="https://bitcoincore.reviews/23443#l-51"

  q2="<!--q2-->完整的握手和协调注册流程是怎样的？"
  a2="双方在 `version` 消息后、`verack` 前交换含本地随机盐值的 `sendrecon` 消息。顺序不限。双向验证成功后初始化协调状态。"
  a2link="https://bitcoincore.reviews/23443#l-63"

  q3="<!--q3-->为何不升级协议版本号？"
  a3="新旧协议兼容即可，未升级节点会忽略新消息正常运作。"
  a3link="https://bitcoincore.reviews/23443#l-78"

  q4="<!--q4-->为何每连接生成随机盐？如何生成？"
  a4="盐值由双方随机数组合生成，用于创建抗碰撞交易短 ID。本地每连接独立生成避免指纹追踪。"
  a4link="https://bitcoincore.reviews/23443#l-93"
%}

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]的重大变更。*

- [Bitcoin Core #23882][] 更新了 `validation.cpp` 中关于 testnet3 运行的文档说明。

  比特币早期版本中，交易内容可能完全相同从而导致交易 ID（txid）冲突。此类重复问题尤其易发于创币交易——其输入输出的部分构成（如输入 outpoint 全为零）对每个创币交易均相同，其余部分完全由区块模板创建者决定。主网区块链中存在两个重复的创币交易（高度 91,842 和 91,880），它们覆盖了未花费的创币输出，导致总供应量减少 100 BTC。这一事件促使 [BIP30][] 应运而生，禁止重复交易。Bitcoin Core [实现][bip30-impl]了 BIP30 的强制执行机制，通过检查每个交易的 txid 是否已有未花费输出来防止重复。

  后续引入的 [BIP34][] 要求将区块高度作为创币交易 scriptSig 的首项，因高度唯一性有效杜绝了创币交易内容重复，并通过递归作用预防后续交易冲突，从而免除了额外重复检查的需要。该方案后来被发现存在缺陷：在 BIP34 实施前已存在部分创币交易符合未来区块高度模式。主网首个可能违反 BIP30 的碰撞高度预计在 2040 年后的 1,983,702 区块，而 testnet3 当前已超越此高度，故 Bitcoin Core 重新启用了对 testnet 所有交易的未花费重复检查。

- [Eclair #2117][] 新增对[洋葱消息][topic onion messages]回复处理的支持，为后续实现[报价协议][topic offers]做准备。

- [LND #5964][] 新增 `leaseoutput` RPC 指令，允许钱包在指定时间段内锁定特定 UTXO 不被花费。此功能类似于 Bitcoin Core 的 `lockunspent`。

- [BOLTs #912][] 在 [BOLT11][] 发票中新增接收方元数据可选字段。若发票使用该字段，付款节点需在路由信息中携带元数据，供接收方处理支付时使用。此机制可支持[无状态发票][topic stateless invoices]等场景，延续 [Newsletter #168][news168 stateless] 提出的设计思路。

- [BOLTs #950][] 向 [BOLT1][] 引入向后兼容的警告信息机制，降低非必要致命错误触发的通道关闭风险。此为错误代码标准化的第一步，更多讨论详见 [BOLTs #834][] 及 Carla Kirk-Cohen 在 Lightning-dev 邮件列表的[提议][Error Codes for LN]（参见 [Newsletter #136][news136 warning post]）。

{% include references.md %}
{% include linkers/issues.md issues="23882,2117,5964,912,950,834,23443" %}
[rubin feea]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019724.html
[news116 sponsorship]: /zh/newsletters/2020/09/23/#transaction-fee-sponsorship
[news168 stateless]: /zh/newsletters/2021/09/29/#stateless-ln-invoice-generation
[reviews 23443]: https://bitcoincore.reviews/23443
[Error Codes for LN]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-February/002964.html
[news136 warning post]: /zh/newsletters/2021/02/17/#c-lightning-4364
[bip30-impl]: https://github.com/bitcoin/bitcoin/pull/915/files
