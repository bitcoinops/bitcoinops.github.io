---
title: 'Bitcoin Optech Newsletter #292'
permalink: /zh/newsletters/2024/03/06/
name: 2024-03-06-newsletter-zh
slug: 2024-03-06-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报总结了关于更新 BIP21 `bitcoin:` URI 规范的讨论，介绍了一项在同时运行多个 MuSig2 签名会话时尽可能降低状态负担（state）的提议，链接了一个为 BIP 仓库增加编辑的帖子，还讨论一组可以将 Bitcoin Core Github 项目快速移植到自托管的 GitLab 项目的工具。此外是我们的常规栏目：软件的新版本和候选版本公告，近期热门比特币基础设施软件的重大变更介绍。

## 新闻

- **<!--updating-bip21-bitcoin-uris-->更新 BIP21 `bitcoin:` URI**：Josie Baker 在 Delving Bitcoin 论坛中[发帖][baker bip21]，讨论了 [BIP21][] 的规范用法、在当前的实际场景中的用法，以及未来还可考虑的用法。规范要求冒号之后的主体是一个传统的 P2PKH 比特币地址，例如，`bitcoin:1BoB...`。在主体之后，可以使用 HTTP 查询编码传入额外的参数，包括非传统格式的地址。例如，可以这样传入一个 bech32m 地址：`bitcoin:1Bob...?bech32m=bc1pbob...`。然而，这个今天 `bitcoin:` URI 的真正用法大相径庭。非 P2PKH 的地址通常作为主体，而且有时候，主体会留空，在软件只想使用其它支付协议来收取支付的时候。此外，Baker 指出，`bitcoin:` URI 日渐被用户传递隐私保护型的持久标识符，例如使用 “[静默支付][topic silent payments]” 和 “[要约][topic offers]” 协议的标识符。

    该贴还讨论了，可以应用的一项优化是让 URI 的创建者使用裸参数来指定自身所支持的所有支付手段，例如：`bitcoin:?bc1q...&sp1q...`。花费者（通常要负责支付手续费）可以从列表中选择自己偏好的支付手段。虽然截至本刊撰写之时，少数技术细节仍在讨论中，被提议的这个方法没有遇到重大批评。

- **<!--psbts-for-multiple-concurrent-musig2-signing-sessions-->为多个并存的 MuSig2 签名会话设计 PSBT**：Salvatore Ingala 在 Delving Bitcoin 论坛中[发帖][ingala musig2]，讨论了在并行执行多个 [MuSig2][topic musig] 签名会话时，如何尽可能减少需要维护的状态规模。使用 [BIP327][] 所描述的算法，一组联合签名人需要临时存储一些数据，数据规模会随他们想要给要创建的交易加入的输入的数量呈线性增长。许多硬件签名设备都只有少量的存储空间，（在不牺牲安全性的前提下）尽可能减少需要临时存储的数据（称为 “状态”）的规模是非常有用的。

    Ingala 提议为一个完整的 PSBT 创建一个状态对象，然后从中确定性地派生出每一个输入的状态，并且应该让结果与随机结果无法区分。这样一个签名器需要存储的状态就是一个常量，无论一笔交易有多少输入。

    在一个[回复][scott musig2]中，开发者 Christopher Scott 指出，[BitEscrow][] 已经使用了一套类似的机制。

- **<!--discussion-about-adding-more-bip-editors-->关于增加更多 BIP 编辑的讨论**：Ava Chow 在 Bitcoin-Dev 邮件组中[发帖][chow bips]建议增加 BIP 编辑，以帮助现任的编辑。现任的唯一编辑是 Luke Dashjr，他曾[表示][dashjr backlogged]自己已经挤压了一些工作，需要帮助。Chow 提名了两位著名的专家贡献者担任编辑，他们似乎已经得到支持。此外，人们还讨论了补充的编辑应否能够分配 BIP 编号。在本刊撰写之时，尚未有明确的结果。

- **<!--gitlab-backup-for-bitcoin-core-github-project-->给 Bitcoin Core GitHub 项目设置 GitLab 备份**：Fabian Jahr 在 Delving Bitcoin 邮件组中[发帖][jahr gitlab]介绍了在一个自主托管的 GitLab 实例中维护 Bitcoin Core 项目的 Github 账户的一个备份的做法。在项目需要突然离开 GitHub 的时候，这可以让所有现有的 Issue 和 PR 都可以在短时间内在 GitLab 上恢复访问，从而所有工作都可以在短暂中止之后继续。Jahr 提供了 GitLab 上的项目的一个预览，并且计划保持备份，以允许在有需要的时候可以快速迁移到 GitLab。在本刊撰写之时，他的帖子还没有收到任何评论，但我们感谢他让这样可能出现的迁徙变得极为容易。

## 新版本和候选版本

*热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本，或帮助测试候选版本。*

- [Eclair v0.10.0][] 是这个闪电节点实现的一个新的大版本。它 “正式支持 ‘[双向注资][topic dual funding]’ 特性，实现了最新的 BOLT12 [要约][topic offers] 协议，以及一个完全可用的 ‘[通道拼接][topic splicing]’ 原型”，还有 “多项链上手续费优化，更多的配置选项、性能强化措施以及多项 bug 修复”。

- [Bitcoin Core 26.1rc1][] 是这个主流全节点实现的维护版本的一个候选更新。

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Bitcoin Core #29412][] 增加了代码，可以检查已知所有取一个有效区块、改变它、产生另一个拥有相同区块头哈希值但无效的区块的方法。以前，遭篡改的区块会导致许多漏洞。在 2012 年（以及 2017 年），Bitcoin Core 对无效区块的缓存拒绝策略使得攻击者可以先取得一个有效区块，篡改它以获得一个无效区块，然后将无效区块发给受害者节点；受害者节点会拒绝该无效区块，但也不会再接受该区块的有效形式（直到节点重新启动）；这就把受害者节点从最重区块链中分叉了出去，从而攻击者可以执行一种形式的 “[日蚀攻击][topic eclipse attacks]”；阅读[周报 #37][news37 invalid]可了解更多细节。

- [Eclair #2829][] 允许插件设定为[双向注资的通道开启操作][topic dual funding]贡献资金的策略。默认情况下，Eclair 不会在双向注资时贡献资金。这个 PR 允许插件覆盖这个策略、决定节点运营者的多少资金可以用来创建新通道。

- [LND #8378][] 为 LND 的[选币][topic coin selection]特性增加了多项优化，包括：允许用户选择自己的选币策略，还允许用户指定某些输入必须进入一笔交易，同时选币策略可以增加别的输入。

- [BIPs #1421][] 为 `OP_VAULT` 操作码和相关的共识变更加入了 [BIP345][]；这些变更一旦以软分叉激活，就可以为 “[保险柜][topic vaults]” 合约增加支持。不像当前能够用预签名交易实现的保险柜合约，BIP345 保险柜不会遭遇 “最后时分交易替换” 攻击。BIP345 保险柜也允许[限制条款][topic covenants]操作，这让它比大部分提议中的、仅使用更通用的[限制条款][topic covenants]机制的设计更加高效。

{% include references.md %}
{% include linkers/issues.md v=2 issues="29412,2829,8378,1421" %}
[jahr gitlab]: https://delvingbitcoin.org/t/gitlab-backups-for-bitcoin-core-repository/624
[ingala musig2]: https://delvingbitcoin.org/t/state-minimization-in-musig2-signing-sessions/626
[scott musig2]: https://delvingbitcoin.org/t/state-minimization-in-musig2-signing-sessions/626/2
[baker bip21]: https://delvingbitcoin.org/t/revisiting-bip21/630
[bitescrow]: https://github.com/BitEscrow/escrow-core
[chow bips]: https://gnusha.org/pi/bitcoindev/2092f7ff-4860-47f8-ba1a-c9d97927551e@achow101.com/
[dashjr backlogged]: https://twitter.com/LukeDashjr/status/1761127972302459000
[news37 invalid]: /en/newsletters/2019/03/12/#bitcoin-core-vulnerability-disclosure
[news251 block]: /zh/newsletters/2023/05/17/#bitcoin-core-27608
[eclair v0.10.0]: https://github.com/ACINQ/eclair/releases/tag/v0.10.0
[bitcoin core 26.1rc1]: https://bitcoincore.org/bin/bitcoin-core-26.1/
