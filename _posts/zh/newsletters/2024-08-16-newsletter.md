---
title: 'Bitcoin Optech Newsletter #316'
permalink: /zh/newsletters/2024/08/16/
name: 2024-08-16-newsletter-zh
slug: 2024-08-16-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的新闻部分介绍了一种新的时间扭曲攻击，对新的 testnet4 尤其重要；还总结了关于缓解洋葱消息 DoS 顾虑的提议的讨论、为一项允许闪电支付者有选择地公开身份的提议寻求反馈，并宣布了 Bitcoin Core 编译系统的一个重大变更，该变更可能影响下游的开发者和集成软件。此外是我们的常规栏目：软件新版本和候选版本的发布公告，以及热门的比特币基础设施软件的重大变更介绍。

## 新闻

- **<!--new-time-warp-vulnerability-in-testnet4-->****在 testnet4 中发现的新的时间扭曲漏洞**：Mark “Murch” Erhardt 在 Delving Bitcoin 论坛中[发帖][erhardt warp]介绍了一种由开发者 Zawy [发现][zawy comment]的攻击，用于爆破 [testnet4][topic testnet] 的新的难度调整算法。Tesenet4 应用了一种来自主网 “[共识清理][topic consensus cleanup]” 软分叉提议的解决方案，意图阻止 “[时间扭曲攻击][topic time warp]”。但是，Zawy 介绍了一种类似于时间扭曲的攻击，在新规则下也可以使用，可将挖矿难度降低到正常数值的 1/16 。Erhardt 延伸了 Zawy 的攻击，可以将难度降低到允许的最小值。我们将多种相关的攻击简化介绍如下：

  比特币的区块是随机产出的，而出块的 “难度” 被有意设计成每 2016 个区块就 *重新校准*，以保证出块的平均间隔在大约 10 分钟。下面的简化图展示了区块以恒定的速度产生时是什么样子，假定每 5 个区块就重新校准一次（为了让图示更加清楚而缩短了调整周期）：

  ![Illustration of honest mining with a constant hashrate (simplified)](/img/posts/2024-time-warp/reg-blocks.png)

  一个不诚实的矿工（或一群不诚实的串谋矿工），如果掌握了稍微超过整个网络 50% 的出块算力，就可以审查由其它诚实矿工（总算力稍低与 50%）产生的区块。这在一开始会自然导致平均而言 20 分钟才能产生一个区块。而在这种模式持续了 2016 个区块之后，难度会调整成原来的 1/2，从而让主网的出块速度恢复，恢复成平均每 10 分钟产生 1 个区块：

  ![Illustration of block censorship by an attacker with slightly more than 50% of total network hashrate (simplified)](/img/posts/2024-time-warp/50p-attack.png)

  当不诚实的矿工使用自己的算力优势来强迫绝大多数区块使用可允许的最小数值的时间戳时，就构成了一种时间扭曲攻击。在每一个难度调整周期（2106 个区块）的末尾，他们可以将区块头中的时间戳推进到[实际经过][wall time]攻击后的时间，从而让生成区块的时间看起来比其实际花费的时间要长，从而在下一个周期中降低难度。

  ![Illustration of a classic time warp attack (simplified)](/img/posts/2024-time-warp/classic-time-warp.png)

  应用在 testnet4 上的[新规则][testnet4 rule]通过防止新周期的第一个区块的时间戳比上一个区块（也即上一个难度调整周期的最后一个区块）更早来阻止这种攻击。

  就像原本的时间扭曲攻击，Erhardt 的 Zawy 攻击改进版会以最低限度逐步推进大部分区块的时间戳。但是，在每 3 个难度调整中期的前 2 个周期中，攻击者会大幅推进该周期最后一个区块的时间戳（并因此推进下一个周期的第一个区块的时间戳）。如此一来，每过一个周期，难度就会以可允许的最大幅度降低一次（变成当前数值的 1/4）。而在第 3 个周期中，攻击者先为所有区块（以及下一个周期的第一个区块）使用可允许的最小时间戳，从而让难度以最大幅度提高（变成当前的 4 倍）。换句话说，难度先变成了攻击开始前难度的 1/4，然后是 1/16，最后提高到开始前难度的 1/4：

  ![Illustration of Erhardt's version of Zawy's new time warp attack (simplified)](/img/posts/2024-time-warp/new-time-warp.png)

  这种三周期的循环可以无限重复，每循环一次就将难度减低到原来的 1/4，最终降低到允许矿工[每秒生产 6 个区块][erhardt se]的水平。

  为了在一个难度调整周期中将难度降低到 1/4，攻击者矿工需要将调整难度的区块的时间戳设置成当前周期开头区块的 8 周之后。要在攻击开始阶段连续两次这样做，最终就需要将一些区块的时间戳设置到 16 周之后。全节点不会接受本地时间未来两个小时之后的区块，这会在长达 8 周（在第一组区块）和 16 周（第二组区块）的时间里阻止恶意区块被接受。在攻击者矿工等待自己的区块被接受的时间里，他们可以用更低的难度创建额外的区块。在攻击者准备攻击的 16 周的时间里，任何由诚实矿工创建的区块都会在开始接受恶意区块之后被重组、分叉出去；这会让这段时间内确认的所有交易都要么回到未确认状态，要么因与当前区块链冲突而无效。

  Erhardt 建议使用软分叉来解决这种攻击：要求一个难度调整周期的最后一个区块的时间戳晚于该周期第一个区块的时间戳。Zawy 提出了多种解决方案，包括禁止区块时间戳倒拨（这可能会带来一些问题，当某些矿工在节点们强制执行的两小时规则附近创建区块的时候），或者，至少禁止区块时间戳倒拨超过 2 个小时。

  总的来说，在主网上，这种时间扭曲攻击类似于原版的攻击，在于它也要求控制挖矿设备、它可以被提前侦测到、它对用户带来的后果，以及可以解决它们的软分叉的相对简洁性。它需要攻击者控制至少超过 50% 的挖矿算力达一个月以上，同时可能会向用户暴露出攻击正在蓄力的信号，要指望用户完全不在意，这在主网上是非常难的。如 Zawy [指出][zawy testnet risk] 的，这种攻击在测试网上会容易得多：少量前沿的挖矿设备就足以在测试网上获得 50% 的挖矿算力，然后悄悄建立攻势。理论上来说，随后，攻击者就可以每天制造出超过 50 万个区块。除非使用软分叉来阻止这种攻击，只有愿意为测试网投入更多算力的人才能阻止攻击者。

  截至本文撰写之时，拟议的解决方案之间的取舍还在讨论中。

- **<!--onion-message-dos-risk-discussion-->洋葱消息拒绝服务式攻击风险讨论**：Gijs van Dam 在 Delving Bitcoin 论坛中[讨论][vandam onion]了研究员 Amin Bashiri 和 Majid Khabbazian 最近出版的一篇[论文][bk onion]，有关 “[洋葱消息][topic onion messages]”。两位研究员指出，每一条洋葱消息都可能经过许多节点（根据 van Dam 的计算，是 481 跳）来转发，这可能会浪费所有这些节点的带宽。他们介绍了集中降低带宽滥用风险的方法，包括为每多一跳就要求一个指数增量的 PoW 的智能模式，这会让更短的路径在计算上更便宜，而更长的路径更贵。

  Matt Corallo 建议先尝试以前被提议的一个想法（详见[周报 #207][news207 onion]），为发送太多洋葱消息的节点提供反压力，然后再尝试更复杂的方案。

- **<!--optional-identification-and-authentication-of-ln-payers-->闪电支付者的可选身份和鉴别**：Bastien Teinturier 在 Delving Bitcoin 论坛中[提议][teinturier auth]，让闪电网络的花费者可以选择包含关于他们支付的额外数据，从而让接收者可以识别这些支付来自一个已知的联系人。举个例子，如果 Alice 生成了一个 [offer][topic offers]，Bob 用它来给 Alice 支付，那么她可能希望得到支付来自 Bob（而非冒充 Bob 的第三方）的密码学证据。Offer 被射击场默认隐藏花费者和接收者的身份，所以需要额外的机制来启用这种可选的身份和鉴别。

  Teinturier 先介绍了一种可选的 *联系人公钥* 分发机制，Bob 可以用它来暴露一个公钥给 Alice。然后，Teinturier 介绍了三种候选方案，用于让 Bob 可选地签名自己给 Alice 的支付。只要 Bob 使用了这样的机制，Alice 的闪电钱包就能识别这个签名来自 Bob，然后显示信息给 Alice。在无法鉴别的支付中，由花费者设定的字段（例如自由形式的 `payer_note` 字段）可以被标记为不受信任的，以劝阻用户依赖于其中提供的信息。

  请求对使用何种密码学方法的反馈，同时，Teinturier 计划为选定的方法放出 [BLIP42][blips #42] 作为规范。

- **<!--bitcoin-core-switch-to-cmake-build-system-->****Bitcoin Core 切换到 CMake 编译系统**：Cory Fields 在 Bitcoin-Dev 邮件组中[宣布][fields cmake] Bitcoin Core 即将从 GNU autotools 编译系统切换成 CMake 编译系统；这是由 Hennadii Stepanov 领导的，Michael Ford 贡献了 bug 修复和现代化的部分，亦有其他开发者（包括 Fields 自己）的审核和贡献。这应该不会影响任何使用来自 BitcoinCore.org 所发行的预编译二进制文件的用户 —— 我们估计绝大部分用户都使用这一选择。但是，自己编译二进制文件以测试或定制化的开发者和集成者可能受到影响 —— 尤其是使用不常用平台或不常用编译配置的人。

  Fields 的邮件为预判的问题提供了答案，并请求任何自己编译 Bitcoin Core 的人测试 [PR #30454][bitcoin core #30454] 并报告问题。这一 PR 预计回在未来几周内合并，并预期在版本 29 中发布（当前时间的 7 个月之后）。你越早测试，Bitcoin Core 的开发者就拥有越多时间来修复问题（在版本 29 发布之前）—— 可以提高他们阻止你所用的发行版代码出现问题的概率。

## 新版本和候选版本

*热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本，或帮助测试候选版本。*

- [BDK 1.0.0-beta.1][] 是这个用于开发钱包和其它比特币嵌入式应用的的库的候选版本。最初的 `bdk` Rust crate 已经重命名为 `bdk_wallet`，更低层级的模块已经被抽取成独立的 create，包括 `bdk_chain`、`bdk_electrum`、`bdk_esplora`，以及 `bdk_bitcoind_rpc`。这个 `bkd_wallet` crate 是 “第一个能够提供稳定的 1.0.0 API 的版本”。

- [Core Lightning 24.08rc2][] 是这个热门的闪电节点实现的下一个主要版本的候选版本。

- [LND v0.18.3-beta.rc1][] 是这个热门的闪电节点实现的一个小的 bug 修复版本的候选版本。

## 重大的代码和说明书变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Bitcoin Core #29519][] 会在加载一个 [assumeUTXO][topic assumeutxo] 快照之后重设 `pindexLastCommonBlock` 的数值，从而节点会优先下载快照中的最新区块之后的区块。这修复了一个 bug：节点会在加载快照之前使用从现有的对等节点处获得的信息来设定 `pindexLastCommonBlock`，然后会从老得多的区块开始下载。虽然较老的区块也需要下载（在 assumeUTXO 的后台验证阶段），但更新的区块应得到优先级，这样用户就能看到他们的最新交易有没有得到确认。

- [Bitcoin Core #30598][] 从 [assumeUTXO][topic assumeutxo] 快照文件的元数据中移除了区块高度，因为在预先整理过（pre-sanitized）的不受信任的文件中，区块高度不是唯一的标识符（与保存的区块哈希值相比）。节点依然可以从其它内部源处获得区块高度。

- [Bitcoin Core #28280][] 为剪枝节点优化了 “初始化区块下载（IBD）” 的性能：在剪枝刷新（prune flushes）期间，不再清空 UTXO 缓存。这是通过专门跟踪 “脏” 的缓存条目 —— 自上一次写入数据库以来变更过的条目 ） 来实现的。这让一个节点在剪枝刷新期间可以避免不必要地扫描整个缓存，而可以专注在脏条目中。这一优化让剪枝节点的 IBD 可以加速高达 32%（使用高 `dbcache`（缓存）设定 ），在默认设定中，也可以加速 9% 。详见周报 [#304][news304 cache]。

- [Bitcoin Core #28052][] 在创建 `blocksdir *.dat` 文件时添加 [XOR][] 编码，作为一种防止反病毒类软件无意或意外造成数据损坏的预防机制。这可以被禁用，而且不能防止故意的数据损坏攻击。在 `chainstate` 文件上，这一机制在 2015 年 9 月的 [Bitcoin Core #6650][] 上就实现了；2023 年 11 月 的 [#28207][bitcoin core #28207] 对交易池也实现了相同的机制（详见 [周报 #277][news277 bcc28207]）。

- [Core Lightning #7528][] 为时间不敏感的单方面通道关闭交易的清扫交易调整了[手续费率估计][topic fee estimation]，按照 2016 个区块（大约 2 周）的绝对截止时间来增加手续费。以前，手续费率被设置成意在 300 个区块内得到确认，但这有时会导致交易因为[交易转发门槛费率][topic default minimum transaction relay feerates]而受到阻塞，最终无限期推迟。

- [Core Lightning #7533][] 更新了内部的资金移动通知和交易簿记，以正确地统计 “[拼接交易][topic splicing]” 的注资输出的花费。以前，它们不会被记录下来，也不会被跟踪。

- [Core Lightning #7517][] 引入了 `askrene`，一种新的实验性插件和 API 基础设施，使用基于 `renepay` 插件（一种优化的 Pickhart Payments 实现）（详见周报 [#263][news263 renepay]）的最小成本寻路。`getroutes` RPC 命令允许指定持久的通道容量和传输信息（例如 “[盲化路径][topic rv routing]” 和路径提示），然后返回一组可能的路径，以及它们的预计成功概率。添加了多个 RPC 命令来管理分层的路由数据，可以添加通道、操作通道数据、从路线中排除节点、检查分层数据，以及管理正在发生的支付尝试。

- [LND #8955][]为 `sendcoins` 命令添加了一个可选的 `utxo` 字段（以及对应于 `SendCoinsRequest` RPC 命令的 `Outpoints` 字段），来简化[选币][topic coin selection]的用户体验，只需一步就可完成。以前，用户必须走完一个多步骤的流程，包括选币、手续费估计、[PSBT][topic psbt] 注资、PSBT 补完，以及交易广播。

- [LND #8886][] 通过反转寻路过程，在 `BuildRoute` 功能中支持 “[入站路由手续费][topic inbound forwarding fees]”，现在是以从接收者回溯到发送者的方式计算，这可以更准确地计算多跳的手续费。关于入站路由手续费，详见周报 [#297][news297 inboundfees]。

- [LND #8967][] 添加了一种新的连线消息类型 `Stfu`（SomeThing Fundamental is Underway，更根本的东西正在发生） ，用于在初始化[协议升级][topic channel commitment upgrades]之前锁定通道状态。这种 `Stfu` 消息类型包含了通道 id、初始化标签以及用于未来插件的额外数据的字段。这是 Quiescence 协议实现的一部分（详见周报 [#309][news309 quiescence]）。

- [LDK #3215][] 检查一笔交易至少有 65 字节长，以防范一种针对轻客户端 SPV 钱包的[不太可能发生且成本高昂的攻击][spv attack]：为一笔假的 64 字节的交易制作一个有效的 SPV 证据，可以匹配默克尔树上一个内部节点的哈希值。详见 “[默克尔树的漏洞][topic merkle tree vulnerabilities]”。

- [BLIPs #27][] 添加了 BLIP04，作为一种实验性的 “[HTLC 背书][topic htlc endorsement]” 信号协议提议的规范，该提议可以部分缓解网络中的 “[通道阻塞攻击][topic channel jamming attacks]”。该规范列举了实验性的倍数 TLV 数值、部署方法，以及何时结束实验状态（将 HTLC 背书协议合并到 BOLT）。

{% include references.md %}
{% include linkers/issues.md v=2 issues="29519,30598,28280,28052,7528,7533,7517,8955,8886,8967,3215,1658,27,30454,42,6650,28207" %}
[BDK 1.0.0-beta.1]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.1
[erhardt se]: https://bitcoin.stackexchange.com/a/123700
[erhardt warp]: https://delvingbitcoin.org/t/zawy-s-alternating-timestamp-attack/1062
[zawy comment]: https://github.com/bitcoin/bitcoin/pull/29775#issuecomment-2276135560
[wall time]: https://en.wikipedia.org/wiki/Elapsed_real_time
[testnet4 rule]: https://github.com/bitcoin/bips/blob/master/bip-0094.mediawiki#time-warp-fix
[news36 warp rule]: /zh/newsletters/2019/03/05/#时间扭曲攻击
[zawy testnet risk]: https://delvingbitcoin.org/t/zawy-s-alternating-timestamp-attack/1062/5
[vandam onion]: https://delvingbitcoin.org/t/onion-messaging-dos-threat-mitigations/1058
[bk onion]: https://fc24.ifca.ai/preproceedings/104.pdf
[news207 onion]: /zh/newsletters/2022/07/06/#onion-message-rate-limiting
[teinturier auth]: https://delvingbitcoin.org/t/bolt-12-trusted-contacts/1046
[fields cmake]: https://mailing-list.bitcoindevs.xyz/bitcoindev/6cfd5a56-84b4-4cbc-a211-dd34b8942f77n@googlegroups.com/
[Core Lightning 24.08rc2]: https://github.com/ElementsProject/lightning/releases/tag/v24.08rc2
[LND v0.18.3-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.3-beta.rc1
[news304 cache]: /zh/newsletters/2024/05/24/#bitcoin-core-28233
[news263 renepay]: /zh/newsletters/2023/08/09/#core-lightning-6376
[news309 quiescence]: /zh/newsletters/2024/06/28/#bolts-869
[spv attack]: https://web.archive.org/web/20240329003521/https://bitslog.com/2018/06/09/leaf-node-weakness-in-bitcoin-merkle-tree-design/
[news297 inboundfees]: /zh/newsletters/2024/04/10/#lnd-6703
[news277 bcc28207]: /zh/newsletters/2023/11/15/#bitcoin-core-28207
[xor]: https://zh.wikipedia.org/wiki/%E4%B8%80%E6%AC%A1%E6%80%A7%E5%AF%86%E7%A2%BC%E6%9C%AC
