---
title: 'Bitcoin Optech Newsletter #114'
permalink: /zh/newsletters/2020/09/09/
name: 2020-09-09-newsletter-zh
slug: 2020-09-09-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了关于让 coinswap 可路由的协议的持续讨论，并包含我们常规的栏目：Bitcoin Core PR 审查俱乐部会议摘要，以及热门比特币基础设施项目的值得注意的变更。

## 行动项

*本周无。*

## 新闻

- **<!--continued-coinswap-discussion-->****持续的 coinswap 讨论：** 在 Bitcoin-Dev 邮件列表上两周前那场讨论（见 [Newsletter #112][news112 coinswap]）[继续][belcher coinswap]进行的过程中，几位贡献者设计并分析了针对一项提议的路由式 coinswap 协议的潜在攻击。提出的攻击有：

  - **<!--costless-old-state-theft-->****无成本旧状态盗窃：**一次 coinswap 之后，发起方已经能够花费一个与最初不同的 UTXO，此时他们可能会试图花掉自己旧的 UTXO（该 UTXO 现在归对手方所有）。如果对手方或其[瞭望塔][topic watchtowers]代理在监控区块链，这次尝试就会失败——但攻击者不会为此付出任何代价。

  - **<!--costless-scorched-earth-->****无成本焦土策略：**如果参与方预先签署一组相互冲突的替代交易（这些交易表明支持自愿启用的[手续费替换（RBF）][topic rbf]），从而让手续费追加成为可能，那么对手方在收完自己的新 UTXO 之后，就可能广播其中手续费最高的那笔替代交易。这不会给他们带来收益，但高额手续费会从诚实方 UTXO 的价值中扣除，所以攻击者没有任何成本。

  - **<!--costless-pinning-theft-->****无成本钉住盗窃：**与上述类似，如果同一笔交易存在费率不同的多个版本，攻击方对手可以先广播低费率版本，再用[交易钉住][topic transaction pinning]手法让它无法实际完成手续费追加。如果攻击得手，攻击者就能花掉受害者的资金；如果没得手，只要他们本来就打算发送那些用于钉住的交易（例如本来就打算整理 UTXO），可能也不会多花什么成本。

  讨论中提出了几种可能的解决方案。最有希望的[方案][belcher collateral]是：要求任何花掉 coinswap UTXO 的人，都把自己另一个 UTXO 的一部分价值用于支付手续费。这种*抵押支付*可以消除上述攻击的无成本特性。要彻底解决这些攻击，可能还需要一些与时间锁相关的其他更改，例如使用 1 个区块的相对时间锁（`1 OP_CSV`）来防止钉住。

  这场讨论不仅有助于改进一个增强隐私的 coinswap 协议，至少还有一位参与者[指出][zmnscpxj ln]，讨论中的一些见解也可能适用于其他协议，例如 LN。

## Bitcoin Core PR 审查俱乐部

*在此每月专栏中，我们总结了一次最近的 [Bitcoin Core PR 审查俱乐部][Bitcoin Core PR Review Club] 会议，重点介绍了一些重要的问答。点击下面的问题查看会议中的答案摘要。*

[将荒谬手续费检查从内存池委托给客户端][review club #19339]是 Gloria Zhao 提出的一个 PR（[#19339][Bitcoin Core #19339]），它提出了 [Bitcoin Core #15810][] 的一个更新版本。该 PR 为需要强制执行最大费率的客户端添加了单独的手续费检查逻辑，随后从 `AcceptToMemoryPool` 中移除了 `nAbsurdFee` 逻辑。

审查俱乐部的讨论先涉及一般概念，然后才深入到更技术性的细节。

{% include functions/details-list.md
  q0="`validation.cpp` 中的 `AcceptToMemoryPool` (ATMP) 函数的作用是什么？"
  a0="ATMP 是 Bitcoin Core 用来判断交易是否可包含在内存池中的函数。除执行共识规则外，ATMP 还应用节点的策略规则。"
  a0link="https://bitcoincore.reviews/19339#l-55"

  q1="**<!--q1-->**什么是“策略”？"
  a1="策略通常定义为每个节点的网络交易规则。它不包括共识规则和终端用户客户端（如钱包）的偏好。"
  a1link="https://bitcoincore.reviews/19339#l-281"

  q2="**<!--q2-->**`nAbsurdFee` 参数（荒谬手续费）有什么作用？"
  a2="`nAbsurdFee` 仅用于本地提交的交易，例如通过节点的 RPC 接口和钱包发起的交易。当节点接收到来自网络的交易（大多数 ATMP 调用的情况）时，它会将 `nAbsurdFee` 设置为空值。"
  a2link="https://bitcoincore.reviews/19339#l-85"

  q3="**<!--q3-->**`nAbsurdFee` 是策略的一部分还是客户端偏好？"
  a3="参与者认为 `nAbsurdFee` 是钱包偏好，而不是策略，因为它不会由 Bitcoin Core 在 P2P 网络上强制执行，[ATMP 应该给出一致的结果][review club client]，无论交易的来源是哪个客户端。"
  a3link="https://bitcoincore.reviews/19339#l-91"

  q4="**<!--q4-->**为什么 `testmempoolaccept` RPC 接受的 JSON 数组最多只能包含一笔原始交易？"
  a4="人们希望 Bitcoin Core 将来能在不更改接口的情况下，通过单个 RPC 测试*多笔*交易，前提是[交易包中继][topic package relay]和交易包内存池接收功能得以实现。"
  a4link="https://bitcoincore.reviews/19339#l-115"
%}

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]中值得注意的更改。*

- [Bitcoin Core #19405][] 向 `bitcoin-cli -getinfo` 和 `getnetworkinfo` RPC 添加了入站和出站连接计数。

- [Bitcoin Core #19670][] 为仅中继区块（block-relay-only）的对等节点和本机（localhost）对等节点保留入站连接槽位。这一更改源自一位用户发现活跃的入站 Tor 连接数量会随时间推移而减少。其原因是存在一种无意的偏差：当 Bitcoin Core 的连接槽位占满时，本机对等节点被驱逐的概率会更高。由于入站 Tor 连接被视作本机对等节点，为本机对等节点保留槽位就能改善 Tor 对等节点的连通性。对仅中继区块的对等节点也做了类似保留——它们处于不利地位，但能提供抵御[日食攻击][topic eclipse attacks]的保护。

- [Bitcoin Core #14687][] 更新了 ZMQ 事件通知服务，以允许创建启用 [TCP 保活][TCP keepalive]的连接（套接字），从而帮助保持连接畅通，尤其是当连接通过路由器或防火墙等设备时。这在使用 ZMQ 监控有时很罕见的事件时尤为有用，例如两次新区块通知之间相隔超过 30 分钟的时候。

- [Bitcoin Core #19671][] 移除了 `-zapwallettxes` 配置选项，该选项会删除钱包中的未确认交易，从而允许用户使用相同的输入创建并广播替代交易。该功能早已被 `abandontransaction` RPC（或 GUI 中对应的上下文菜单选项）取代，它们各自都能让用户从钱包中移除特定的未确认交易。

- [Bitcoin Core #18244][] 更新了 `fundrawtransaction` 和 `walletcreatefundedpsbt` RPC 的 `lockunspents` 参数，使得除钱包自己自动选出的 UTXO 之外，也会锁定用户指定的 UTXO（输入）。在钱包重启或手动解锁之前，被锁定的 UTXO 不会被钱包自动选中用于其他交易的花费；这可以防止用户意外创建多笔花费相同 UTXO 的冲突交易。

- [LND #4463][] 添加了创建仅具有访问由创建该令牌的管理员指定的 API 集权限的认证令牌（“macaroons”）的功能。这提供了比 LND 现有的基于类别的权限系统更细化的访问控制（见 [Newsletter #82][news82 lnd acl]）。此外，还新增了一个 `listpermissions` API，用于列出可用的 API 及其所需的访问权限。

- [BIPs #983][] 更新了 [BIP325][] 中对 [signet 协议][topic signet]的定义，以记录提议的 Bitcoin Core [实现][bitcoin core #18267]中的一个现有功能：若挑战仅为 `OP_TRUE`（或其他在空见证上必定成功的内容），则无需在区块的 币基交易中包含 signet 承诺。

- [HWI #363][] 增加了对 BitBox02 硬件钱包的支持。初始支持只允许为单签脚本签名，但计划支持多重签名。据 PR 评论所述，这是首次出现由制造商自己出面贡献、为 HWI 增加新设备支持的合并。

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
