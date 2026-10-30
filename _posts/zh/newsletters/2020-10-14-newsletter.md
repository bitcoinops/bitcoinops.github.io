---
title: 'Bitcoin Optech Newsletter #119'
permalink: /zh/newsletters/2020/10/14/
name: 2020-10-14-newsletter-zh
slug: 2020-10-14-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 转达一项针对 LND 用户的安全警告，总结关于闪电网络前置手续费的讨论，介绍一个关于为 taproot 更新 bech32 地址的邮件列表讨论帖，并链接一份关于保护闪电网络支付替代方案的更新提案。此外，我们的常规部分还包括 Bitcoin Core PR 审查俱乐部会议总结、发布与候选发布，以及热门比特币基础设施软件的值得注意的变更。

## 行动项

- **<!--upgrade-lnd-to-0-11-x-->****升级 LND 至 0.11.x：** LND 开发团队在 Lightning-Dev 和 LND Engineering 邮件列表上发布[公告][lnd warning]，提醒用户：2020 年 10 月 20 日将按计划公开影响 LND 0.10.x 及更早版本的漏洞。团队“强烈建议社区尽快升级至 LND 0.11.0 或更高版本”。（注：邮件列表存档软件会略微改动公告的文本，因此想验证公告 PGP 签名的人应按[附加步骤][lnd pgp]操作。）

## 新闻

- **<!--ln-upfront-payments-->****闪电网络前置手续费：** 在当前的闪电网络协议中，尝试路由一笔支付可能会把路由节点的部分资金锁定数小时乃至数天。由于只有支付成功才会支付路由手续费，攻击者可以利用故意失败的支付，阻止路由节点靠其存放在通道中的资金赚取收入。一个此前讨论过的选项可能更好地对齐激励：在收到路由请求时就收取一笔不可退还的手续费（参见 [Newsletter #72][news72 upfront payments]）。

  本周在 Lightning-Dev 邮件列表中，一场关于某项小幅协议变更提议的[讨论][teinturier dynamic]转变成了关于前置手续费的对话：

  - **<!--incremental-routing-->***增量路由：* ZmnSCPxj [描述][zmnscpxj tunneling]了一种嵌套的加密隧道协议，其中路由会被逐步建立，付款方可以逐个独立地向每一后继路由跳点付费。这样可以确保路由手续费不会被故意让路由失败的更早跳点窃走。该方法的缺点是会产生大量网络往返，可能让哪怕成功的支付也耗时很久。此外，一个记录消息路由时机和 HTLC 持续时间的监视节点，还能估算出付款方或收款方距自己有多少跳，从而减少用户能从闪电网络获得的隐私。

  - **<!--trusted-upfront-payment-->***可信的前置支付：* Antoine Riard [主张][riard trust]直接支付前置手续费，如果对等方偷走了这笔钱，就降低其评分，让你的路由算法倾向于以后不再使用它们。假设单笔前置手续费远小于对等方在数周或数月路由中能赚到的全部手续费，那么就应当存在诚实行事的激励。

- **<!--bech32-addresses-for-taproot-->****Taproot 的 bech32 地址：** Rusty Russell [重启][russell bech32]了此前关于修改 [BIP173][] 中 [bech32][topic bech32] 地址规则的讨论（参见 [Newsletter #107][news107 bech32]），目的是防止 [bech32 扩展漏洞][bech32 extension bug]影响 [taproot][topic taproot] 用户以及未来类似升级的用户。Russell 提议采用一种向后不兼容的格式，它基于 Pieter Wuille 此前描述的[修订版 bech32 编码方案][wuille new bech32]。这能消除该漏洞，但同时也要求钱包升级，才能向 taproot 用户付款。

  此前提出的[一种替代方案][news107 bech32]是对 bech32 地址长度施加向后兼容的限制。这种方案只能直接保护一类 taproot 用户：他们的付款方已经升级钱包并强制执行新的长度限制。讨论中有人提出，如果在[共识层][harding bech32]或[交易中继策略层][o'connor bech32]这两层之一也强制执行长度限制，就能提供更广泛的安全保障。

  Russell 在帖子结尾指出：“越早对此做出决定，我们就能越早开始为 taproot 时代升级软件。”他尤其希望钱包作者和比特币发送服务的作者提供反馈，因为无论最终决定做何种变更，都需要他们来实现。

- **<!--updated-witness-asymmetric-payment-channel-proposal-->****更新的非对称见证支付通道提案：** Lloyd Fournier [发帖][fournier update]到几周前的一个关于见证非对称支付通道（witness asymmetric payment channels）的讨论帖（参见 [Newsletter #113][news113 witasym]）。该提案的思路是改变闪电网络用户获取证据的方式，这些证据用于证明其通道对手方作弊。目前，证据对每个通道参与者分别放在单独的交易中；Fournier 提议借助[适配器签名][topic adaptor signatures]，把证据放进每个参与者各自的签名（“见证”）中。该方法的优点是它给出的协议更容易与比特币预期中的改进（例如使用与不使用 [MuSig][topic musig] 聚合的 [schnorr 签名][topic schnorr signatures]）以及闪电网络预期中的改进（例如从 [HTLC][topic htlc] 转向 [PTLC][topic ptlc]）相集成。该方法在概念上可能也更简单，有助于吸引更多人对闪电网络的基本操作做安全审查。

  本周，Fournier 链接了其提议协议的[更新版本][fournier v2]。与最初版本的主要区别在于，广播已撤销签名的一方会暴露自己在通道多重签名花费中使用的主私钥。通道的另一方可以用这把密钥结合自己的密钥，立即取走通道内的全部资金。再加上另一项变更<!-- I think it also needs something like Russell's shachain; emailed Fournier 2020-10-11 to confirm -->，这应当能把整个通道的惩罚数据存进很少的几个字节里。

## Bitcoin Core PR 审查俱乐部

*在本月度部分中，我们总结了一次最近的 [Bitcoin Core PR 审查俱乐部][bitcoin core pr review club]会议，突出了一些重要的问题和解答。点击下面的问题以查看会议中的答案摘要。*

[BIP-325: Signet][review club #18267] 是 Kalle Alm 提出的一个 PR（[#18267][Bitcoin Core #18267]），该 PR 实现了一种新的比特币测试网络。此 PR 已被合并（参见 [Newsletter #117][news117 signet]），即将发布的 v0.21 版本将支持 [signet][topic signet]。

审查俱乐部的讨论先覆盖通用概念，再深入到更底层的技术细节。回答出色的参与者获得了 signet 币作为奖励。下面是关于 signet 通用概念的迷你测验：

{% include functions/details-list.md
  q0="**<!--q0-->**Signet 是什么？"
  a0="Signet 由 [BIP325][bip325] 定义，是一种构建稳定、中心化、可自定义的工作量证明网络的机制。它也是一个特定全球测试网的名称。"
  a0link="https://bitcoincore.reviews/18267#l-94"

  q1="**<!--q1-->**Signet 旨在替代现有的比特币测试网络，如 testnet 或 regtest 吗？"
  a1="它们是互补的。Signet 被构想为一种中心化、稳定的改进，用于当前 testnet 不理想的情况。"

  q2="**<!--q2-->**我们在当前 testnet 上遇到哪些问题？"
  a2="testnet 因破坏性的重组、高度不稳定的区块生成以及扭曲的激励模型而不可靠：testnet 币没有价值，但 testnet 挖矿并非免费，且难度还在波动。"
  a2link="https://bitcoincore.reviews/18267#l-149"

  q3="**<!--q3-->**Signet 与 regtest（Bitcoin Core 的回归测试框架）有什么区别？"
  a3="Regtest 是一个沙盒环境，网络拓扑和区块生成完全手动，适合本地测试；但它无许可的特性意味着任何人都能挖矿，因此 regtest 无法稳定地与第三方对等方一起公开使用。Signet 是一个带公共节点的真实网络，适合测试发现对等方、交易选择、交易与区块传播等网络效应。"

  q4="**<!--q4-->**PR 中的默认 signet 挑战脚本是什么？"
  a4="多重签名 1-of-2 地址。可以使用 `-signetchallenge` 配置选项进行修改。"
  a4link="https://bitcoincore.reviews/18267#l-252"

  q5="**<!--q5-->**在 `CreateGenesisBlock()` 方法中，哪个参数决定了难度？"
  a5="难度由 [nBits][] 参数设定，该参数是一个工作量证明目标的自定义压缩表示，其人类可读的形式即为难度。"
  a5link="https://bitcoincore.reviews/18267#l-474"

  q6="**<!--q6-->**Signet 创世区块的难度是否低于主网创世区块的难度？"
  a6="是的，signet 的默认 `nBits` 更高，因此难度目标更低：[主网 1d00ffff，signet 1e0377ae][compare difficulty]。不过，这只是一个最低目标；签名者[可以把它设得更高][signet difficulty]。"
  a6link="https://bitcoincore.reviews/18267#l-481"
%}

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [HWI 1.2.0][] 是一个新发布，增加了对 BitBox02 这一新硬件设备的支持，并包含多个错误修复。

- [Eclair 0.4.2][] 是一个新发布，为 Eclair 插件提供了更多能力，增加了对[锚定输出][topic anchor outputs]的实验性支持，并允许用户发送和接收[自发支付][topic spontaneous payments]。此外还包含若干 API 变更和错误修复。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的变更。*

- [Bitcoin Core #19954][] 完成了 [BIP155][] 的实现，该提案也称 [addr v2][topic addr v2]。我们在 [Newsletter #110][news110 addrv2] 中介绍过，这项升级支持 Tor v3，并使得为 I2P 及其他网络添加支持成为可能——这些网络的端点地址更长，放不进比特币当前 addr 消息的 16 字节/128 位空间。Tor v2 已于 2020 年 9 月[弃用][tor v3 retirement schedule]，并将在 2021 年 7 月被淘汰。

- [Eclair #1537][] 扩展了 `sendtoroute` API 调用，允许用 `--shortChannelIds` 标志为这笔支付指定一组通道 ID。当两个节点之间存在多条通道时，这种对支付更细粒度的控制尤其有用，因为此时仅列出节点 ID 已经不够具体（例如在整合和再平衡通道时）。

{% include references.md %}
{% include linkers/issues.md issues="19954,1537,18267" %}
[hwi 1.2.0]: https://github.com/bitcoin-core/HWI/releases/tag/1.2.0
[eclair 0.4.2]: https://github.com/ACINQ/eclair/releases/tag/v0.4.2
[lnd warning]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-October/002819.html
[lnd pgp]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-October/002822.html
[news72 upfront payments]: /zh/newsletters/2019/11/13/#ln-up-front-payments
[teinturier dynamic]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-October/002803.html
[zmnscpxj tunneling]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-October/002811.html
[riard trust]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-October/002817.html
[russell bech32]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-October/018236.html
[news107 bech32]: /zh/newsletters/2020/07/22/#bech32-address-updates
[bech32 extension bug]: https://github.com/sipa/bech32/issues/51
[harding bech32]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-October/018239.html
[o'connor bech32]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-October/018240.html
[fournier update]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-October/002812.html
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
