---
title: 'Bitcoin Optech Newsletter #119'
permalink: /zh/newsletters/2020/10/14/
name: 2020-10-14-newsletter-zh
slug: 2020-10-14-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 传达了对 LND 用户的安全警告，总结了关于闪电网络前置支付的讨论，描述了邮件列表中的一个关于为 Taproot 更新 Bech32 地址的讨论，并链接了一个用于保护闪电网络支付的替代方案的更新提案。此外，我们的常规部分还包含了 Bitcoin Core PR 审查俱乐部会议的总结、发布与候选发布以及流行比特币基础设施软件的值得注意的更改。

## 行动项

- **<!--upgrade-lnd-to-0-11-x-->****升级 LND 至 0.11.x：** LND 开发团队在 Lightning-Dev 和 LND Engineering 邮件列表中发布了[公告][lnd warning]，警告用户关于 2020 年 10 月 20 日计划披露的影响 LND 0.10.x 及更早版本的漏洞。团队“强烈建议社区尽快升级至 LND 0.11.0 或更高版本”。（注：邮件列表存档软件略微修改了公告的文本，因此想要验证公告 PGP 签名的用户应遵循一些[附加步骤][lnd pgp]。）

## 新闻

- **<!--ln-upfront-payments-->****闪电网络前置支付：** 在当前的闪电网络协议中，尝试路由支付可能会将路由节点的部分资金锁定数小时或数天。由于只有成功支付后才会支付路由费用，攻击者可以设计失败的支付以防止路由节点通过其通道中的资本获得收入。一个先前讨论过的可能更好地对齐激励的选项是在接收到路由请求时收取不可退还的费用（参见 [Newsletter #72][news72 upfront payments]）。

  本周在 Lightning-Dev 邮件列表中，一项[提议的小规模协议更改][teinturier dynamic]的讨论转变为关于前置费用的对话：

  - **<!--incremental-routing-->***增量路由：* ZmnSCPxj [描述][zmnscpxj tunneling]了一种嵌套的加密隧道协议，其中路径将被逐步建立，支付方可以单独支付每个后续的路由跳点。这可以确保路由费用不会被故意导致路由失败的早期跳点窃取。该方法的一个缺点是需要大量的网络往返，这可能使即便是成功的支付也需要较长时间。此外，监视节点可以通过记录消息路由时间和 HTLC 持续时间来估算支付方或接收方距其的跳数，从而降低闪电网络提供的隐私。

  - **<!--trusted-upfront-payment-->***可信的前置支付：* Antoine Riard [建议][riard trust]简单地支付前置费用，并在对等方窃取费用时降低其评分，使路由算法不再优先使用该节点。假设单笔前置费用远小于对等方在几周或几个月的路由中可以获得的总费用，则应该存在诚实行为的激励。

- **<!--bech32-addresses-for-taproot-->****Taproot 的 Bech32 地址：** Rusty Russell [重新讨论][russell bech32]了之前关于修改 [BIP173][] 中 [bech32][topic bech32] 地址规则的讨论，以防止 [bech32 扩展漏洞][bech32 extension bug]影响 [taproot][topic taproot] 和未来的类似升级的用户（参见 [Newsletter #107][news107 bech32]）。Russell 提议使用基于 Pieter Wuille 先前描述的[修订 Bech32 编码方案][wuille new bech32]的向后不兼容格式。此方案可消除该漏洞，但需要钱包升级以便支付 Taproot 用户。

  先前提出的替代方案是对 Bech32 地址长度进行向后兼容的限制。这只能直接保护接收来自已升级其钱包以执行新长度限制的用户支付的 Taproot 用户。在讨论中，建议在[共识层][harding bech32]或[交易中继策略层][o'connor bech32]同时强制执行长度限制，从而提供更广泛的安全性。

  Russell 在帖子末尾指出“越早达成决策，我们就能越早为 Taproot 世界升级软件”。特别希望钱包和比特币支付服务的作者能够反馈，因为将要求他们实施所决定的任何更改。

- **<!--updated-witness-asymmetric-payment-channel-proposal-->****更新的非对称见证支付通道提案：** Lloyd Fournier [回复][fournier update]了几周前关于非对称见证支付通道的讨论（参见 [Newsletter #113][news113 witasym]）。该提案的思想是改变闪电网络用户获得证明其通道对手作弊的证据的方式。目前，每个通道参与者的证据放置在单独的交易中；Fournier 提议通过使用[适配器签名][topic adaptor signatures]将证据放置在每个参与者的单独签名（“见证”）中。此方法的优点是可以提供一个更容易与比特币的预期改进（例如无聚合或有聚合的 [Schnorr 签名][topic schnorr signatures]和 [MuSig][topic musig]）以及闪电网络的预期改进（例如从 [HTLC][topic htlc] 转为 [PTLC][topic ptlc]）集成的协议。该方法也可能在概念上更简单，有助于吸引更多对闪电网络基本操作的安全审查。

  本周，Fournier 链接了其提议协议的[更新版本][fournier v2]。与原始版本的主要区别在于，广播已撤销签名的一方会暴露其在通道多签支出中使用的主私钥。通道的另一方可以使用该密钥与自身的密钥相结合来立即索取通道中的所有资金。与另一项更改一起<!-- 我认为还需要类似于 Russell 的 shachain；2020-10-11 向 Fournier 发送电子邮件以确认 -->，这应允许将整个通道的惩罚数据存储在少量字节中。

## Bitcoin Core PR 审查俱乐部

*在本月度部分中，我们总结了一次最近的 [Bitcoin Core PR 审查俱乐部][bitcoin core pr review club]会议，突出了一些重要的问题和解答。点击下面的问题以查看会议中的答案摘要。*

[BIP-325: Signet][review club #18267] 是 Kalle Alm 提出的一个 PR（[#18267][Bitcoin Core #18267]），该 PR 实现了一种新的比特币测试网络。此 PR 已被合并（参见 [Newsletter #117][news117 signet]），即将发布的 v0.21 版本将支持 [signet][topic signet]。

审查俱乐部的讨论涵盖了通用概念，然后深入到技术细节。提供出色答案的参与者获得了 Signet 币奖励。以下是关于 Signet 概念的迷你测验：

{% include functions/details-list.md
  q0="**<!--q0-->**Signet 是什么？"
  a0="Signet 由 [BIP325][bip325] 定义，是一种构建稳定、集中化和自定义工作量证明网络的机制。它也是一个特定的全球测试网的名称。"
  a0link="https://bitcoincore.reviews/18267#l-94"

  q1="**<!--q1-->**Signet 旨在替代现有的比特币测试网络，如 testnet 或 regtest 吗？"
  a1="它们是互补的。Signet 被设计为一种集中的、稳定的改进，用于当前 testnet 不理想的情况。"

  q2="**<!--q2-->**我们在当前 testnet 上遇到的主要问题是什么？"
  a2="testnet 因为扰乱性的重组、区块生成速度不稳定和不平衡的激励模式而不可靠：testnet 币没有价值，但 testnet 挖矿并非免费，且难度波动较大。"
  a2link="https://bitcoincore.reviews/18267#l-149"

  q3="**<!--q3-->**Signet 与 regtest（Bitcoin Core 的回归测试框架）有什么区别？"
  a3="Regtest 是一个沙盒环境，具有完全手动的网络拓扑和区块生成，适合本地测试，但其无许可的特性（允许任何人挖矿）意味着 regtest 无法稳定地用于与第三方对等方的公开测试。Signet 是一个真实的网络，具有公共节点，适合测试网络效应，如寻找对等方、交易选择、交易和区块传播。"

  q4="**<!--q4-->**PR 中的默认 signet 挑战脚本是什么？"
  a4="多重签名 1-of-2 地址。可以使用 `-signetchallenge` 配置选项进行修改。"
  a4link="https://bitcoincore.reviews/18267#l-252"

  q5="**<!--q5-->**在 `CreateGenesisBlock()` 方法中，哪个参数决定了难度？"
  a5="难度由 [nBits][] 参数设定，该参数是一个工作量证明目标的自定义压缩表示，其人类可读的形式即为难度。"
  a5link="https://bitcoincore.reviews/18267#l-474"

  q6="**<!--q6-->**Signet 创世区块的难度是否低于主网创世区块的难度？"
  a6="是的，signet 有一个较高的默认 `nBits`，因此难度目标较低：[主网 1d00ffff，signet 1e0377ae][compare difficulty]。不过，这只是一个最低目标；签名者[可以设置更高的目标][signet difficulty]。"
  a6link="https://bitcoincore.reviews/18267#l-481"
%}

## 发布与候选发布

*流行的比特币基础设施项目的新版本和候选发布。请考虑升级至新版本或协助测试候选发布版本。*

- [HWI 1.2.0][] 是一个新增支持 BitBox02 硬件设备并包含多个错误修复的新版本。

- [Eclair 0.4.2][] 是一个新版本，为 Eclair 插件提供了更多功能，增加了对[锚定输出][topic anchor outputs]的实验性支持，并允许用户发送和接收[即时支付][topic spontaneous payments]。此外还包含若干 API 更改和错误修复。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的更改。*

- [Bitcoin Core #19954][] 完成了 [BIP155][] 实现，也称为 [addr v2][topic addr v2]。如 [Newsletter #110][news110 addrv2] 中所述，该升级支持 Tor v3，并可添加 I2P 和其他网络的支持，这些网络具有长度较长的端点地址，无法适应比特币当前 addr 消息中的 16 字节/128 位。Tor v2 在 2020 年 9 月[弃用][tor v3 retirement schedule]，并将在 2021 年 7 月被废弃。

- [Eclair #1537][] 扩展了 `sendtoroute` API 调用，允许使用 `--shortChannelIds` 标志指定包含通道 ID 的支付列表。当两个节点之间存在多个通道时，这种更细化的支付控制特别有用，仅列出节点 ID 已不足够（例如在通道整合和重新平衡时）。

{% include references.md %}
{% include linkers/issues.md issues="19954,1537,18267" %}
[hwi 1.2.0]: https://github.com/bitcoin-core/HWI/releases/tag/1.2.0
[eclair 0.4.2]: https://github.com/ACINQ/eclair/releases/tag/v0.4.2
[lnd warning]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-October/002819.html
[lnd pgp]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-October/002822.html
[news72 upfront payments]: /zh/newsletters/2019/11/13/#ln-up-front-payments
[teinturier dynamic]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-October/002803.html
[zmnscpxj tunneling]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-October/002811.html
[riard trust]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-October/002817.html
[russell bech32]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-October/018236.html
[news107 bech32]: /zh/newsletters/2020/07/22/#bech32-address-updates
[bech32 extension bug]: https://github.com/sipa/bech32/issues/51
[harding bech32]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-October/018239.html
[o'connor bech32]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-October/018240.html
[fournier update]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-October/002812.html
[news113 witasym]: /zh/newsletters/2020/09/02/#witness-asymmetric-payment-channels
[fournier v2]: https://github.com/LLFourn/witness-asymmetric-channel
[wuille new bech32]: https://gist.github.com/sipa/a9845b37c1b298a7301c33a04090b2eb#improving-detection-of-insertion-errors
[bip325]: https://github.com/bitcoin/bips/blob/master/bip-0325.mediawiki
[compare difficulty]: https://bitcoincore.reviews/18267#l-478
[signet difficulty]: https://bitcoincore.reviews/18267#l-485
[news117 signet]: /zh/newsletters/2020/09/30/#bitcoin-core-18267
[nbits]: https://btcinformation.org/en/developer-reference#target-nbits
[tor v3 retirement schedule]: https://blog.torproject.org/v2-deprecation-timeline#:~:text=retirement
[news110 addrv2]: /zh/newsletters/2020/08/12/#bitcoin-core-pr-审查俱乐部
