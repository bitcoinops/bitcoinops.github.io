---
title: 'Bitcoin Optech Newsletter #114'
permalink: /zh/newsletters/2020/09/09/
name: 2020-09-09-newsletter-zh
slug: 2020-09-09-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了关于可路由的 Coinswap 协议的持续讨论，并包含我们常规的 Bitcoin Core PR 审查俱乐部会议摘要以及流行比特币基础设施项目的显著更改。

## 行动项

*本周无。*

## 新闻

- **<!--continued-coinswap-discussion-->****持续的 Coinswap 讨论：** 在 Bitcoin-Dev 邮件列表上（见 [Newsletter #112][news112 coinswap]）[继续][belcher coinswap]的讨论中，几位贡献者开发并分析了针对提议的路由化 Coinswap 协议的潜在攻击。提议的攻击包括：

  - **<!--costless-old-state-theft-->**无成本旧状态盗窃： 在 Coinswap 后，当发起方可以花费与他们最初不同的 UTXO 时，他们可能会尝试花费旧的 UTXO（此 UTXO 现属于对手方）。如果对手方或其[瞭望塔][topic watchtowers]代理在监控区块链，此操作将失败——但此尝试对攻击者没有成本。

  - **<!--costless-scorched-earth-->**无成本焦土策略： 如果通过参与方预先签署一组冲突的替代交易实现费用提升，并表示支持选择性[手续费替代 (RBF)][topic rbf]，则对手方可以在接收新 UTXO 后广播最高费用替代交易。这不会为他们带来收益，但高费用将从诚实方的 UTXO 中扣除，因此对攻击者没有成本。

  -**<!--costless-pinning-theft-->**无成本固定盗窃： 与上述类似，如果存在不同费率的多版本交易，攻击对手方可以广播低费率版本，然后使用[交易固定][topic transaction pinning]方法，使费用提升变得不切实际。如果攻击成功，攻击者可以花费受害者的资金；如果失败，对攻击者也无额外成本（例如，他们本已计划发送用于固定的交易，如出于合并 UTXO 的目的）。

  讨论中提出了几种潜在的解决方案。最有希望的[解决方案][belcher collateral]是要求任何花费 Coinswap UTXO 的人将其其他 UTXO 的一部分价值用于交易费用。这种*抵押支付*将消除上述攻击的无成本特性。完全解决这些攻击可能还需要与时间锁相关的其他更改，例如使用 1 区块的相对时间锁（`1 OP_CSV`）来防止固定。

  此讨论不仅有助于改进隐私增强型 Coinswap 协议，至少有一位参与者[指出][zmnscpxj ln]，讨论中一些见解也可能适用于其他协议，如闪电网络。

## Bitcoin Core PR 审查俱乐部

*在此每月专栏中，我们总结了一次最近的 [Bitcoin Core PR 审查俱乐部][Bitcoin Core PR Review Club] 会议，重点介绍了一些重要的问答。点击下面的问题查看会议中的答案摘要。*

[将荒谬费用检查从内存池委托到客户端][review club #19339]是 Gloria Zhao 提出的一个 PR（[#19339][Bitcoin Core #19339]），建议更新 [Bitcoin Core #15810][]。它为需要实施最大手续费率的客户端添加了独立的费用检查逻辑，并从 `AcceptToMemoryPool` 中移除了 `nAbsurdFee` 逻辑。

审查俱乐部的讨论涵盖了总体概念，然后深入探讨了更技术性的内容。

{% include functions/details-list.md
  q0="`validation.cpp` 中的 `AcceptToMemoryPool` (ATMP) 函数的作用是什么？"
  a0="ATMP 是 Bitcoin Core 用来判断交易是否可包含在内存池中的函数。除执行共识规则外，ATMP 还应用节点的策略规则。"
  a0link="https://bitcoincore.reviews/19339#l-55"

  q1="**<!--q1-->**什么是“策略”？"
  a1="策略通常定义为每个节点的网络交易规则。它不包括共识规则和终端用户客户端（如钱包）的偏好。"
  a1link="https://bitcoincore.reviews/19339#l-281"

  q2="**<!--q2-->**`nAbsurdFee` 参数（荒谬费用）有什么作用？"
  a2="`nAbsurdFee` 仅用于本地提交的交易，例如通过节点的 RPC 接口和钱包发起的交易。当节点接收到来自网络的交易（大多数 ATMP 调用的情况）时，它会将 `nAbsurdFee` 设置为空值。"
  a2link="https://bitcoincore.reviews/19339#l-85"

  q3="**<!--q3-->**`nAbsurdFee` 是策略的一部分还是客户端偏好？"
  a3="参与者认为 `nAbsurdfFee` 是钱包偏好，而不是策略，因为它不会由 Bitcoin Core 在 P2P 网络上强制执行，[ATMP 应该给出一致的结果][review club client]，无论交易的来源是哪个客户端。"
  a3link="https://bitcoincore.reviews/19339#l-91"

  q4="**<!--q4-->**为什么 `testmempoolaccept` RPC 接受的 JSON 数组最多只能包含一个原始交易？"
  a4="希望 Bitcoin Core 将来能够在不更改接口的情况下通过单个 RPC 测试多个交易，前提是[包中继][topic package relay]和包内存池接收功能得以实现。"
  a4link="https://bitcoincore.reviews/19339#l-115"
%}

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]中值得注意的更改。*

- [Bitcoin Core #19405][] 向 `bitcoin-cli -getinfo` 和 `getnetworkinfo` RPC 添加了入站和出站连接计数。

- [Bitcoin Core #19670][] 为仅限区块中继和本地主机的对等方保留了入站连接槽位。此更改源于一位用户注意到随着时间推移，活跃的入站 Tor 连接数量减少。这种情况是由于一种无意的偏差导致，当 Bitcoin Core 的连接槽位满时，本地主机对等方被更容易清除。由于入站 Tor 连接视为本地主机对等方，保留本地主机对等方槽位可以改善 Tor 对等方的连接性。类似的保留也适用于仅限区块中继的对等方，这些对等方虽然处于不利地位但能够提供防止[日蚀攻击][topic eclipse attacks]的保护。

- [Bitcoin Core #14687][] 更新了 ZMQ 事件通知服务，以允许创建启用 [TCP 保活][TCP keepalive]的连接（套接字），从而帮助保持连接畅通，尤其是当连接通过路由器或防火墙等设备时。这在使用 ZMQ 监控有时稀有的事件时尤为有用，例如当新的区块通知之间超过 30 分钟时。

- [Bitcoin Core #19671][] 移除了 `-zapwallettxes` 配置选项，该选项会删除钱包中的未确认交易，从而允许用户使用相同的输入创建并广播替代交易。该功能早已被 `abandontransaction` RPC（或 GUI 中的等效上下文菜单选项）取代，允许用户从钱包中移除特定的未确认交易。

- [Bitcoin Core #18244][] 更新了 `fundrawtransaction` 和 `walletcreatefundedpsbt` RPC 中的 `lockunspents` 参数，以便锁定用户指定的 UTXO（输入）以及钱包自动选择的 UTXO。锁定的 UTXO 在钱包重启或手动解锁前不会被自动选择用于其他交易，从而防止用户意外创建多个冲突的交易，花费相同的 UTXO。

- [LND #4463][] 添加了创建仅具有访问管理员指定 API 集权限的认证令牌（“macaroons”）的功能。这提供了比 LND 现有的基于类别的权限系统更细化的访问控制（见 [Newsletter #82][news82 lnd acl]）。此外，还新增了一个 `listpermissions` API，用于列出可用的 API 及其所需的访问权限。

- [BIPs #983][] 更新了 [BIP325][] 中对 [signet 协议][topic signet]的定义，以记录提议的 Bitcoin Core [实现][bitcoin core #18267]中的一个现有功能：若挑战仅为 `OP_TRUE`（或其他在空见证上必定成功的内容），则无需在区块的 coinbase 交易中包含 signet 承诺。

- [HWI #363][] 增加了对 BitBox02 硬件钱包的支持。初始支持仅限单签脚本，但计划增加多签支持。据 PR 评论，这是首次由制造商代表提交的 HWI 对新设备的支持合并。

{% include references.md %}
{% include linkers/issues.md issues="19405,19670,14687,19671,18244,4463,983,363,18267,19339,15810" %}
[tcp keepalive]: https://tldp.org/HOWTO/TCP-Keepalive-HOWTO/overview.html
[news112 coinswap]: /zh/newsletters/2020/08/26/#discussion-about-routed-coinswaps
[belcher collateral]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-September/018151.html
[zmnscpxj ln]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-September/018160.html
[belcher coinswap]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-August/018080.html
[news82 lnd acl]: /zh/newsletters/2020/01/29/#upgrade-to-lnd-0-9-0-beta
[review club client]: https://bitcoincore.reviews/19339#l-104
[hwi]: https://github.com/bitcoin-core/HWI
