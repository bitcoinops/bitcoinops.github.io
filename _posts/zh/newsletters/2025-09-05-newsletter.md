---
title: 'Bitcoin Optech Newsletter #370'
permalink: /zh/newsletters/2025/09/05/
name: 2025-09-05-newsletter-zh
slug: 2025-09-05-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报包括我们的常规栏目：总结关于更改比特币共识规则的讨论、宣布新版本和候选版本，以及描述流行的比特币基础设施软件的显著变更。

## 新闻

_本周在我们的[消息来源][optech sources]中没有发现重大新闻。_

## 共识变更

_一个月度栏目，总结关于更改比特币共识规则的提议和讨论。_

- **<!--details-about-the-design-of-simplicity-->** **关于 Simplicity 设计的详细信息**：Russell O'Connor 在 Delving Bitcoin 上发布了三篇帖子（[1][sim1]、[2][sim2]、[3][sim3]），介绍了“[Simplicity 语言][topic simplicity]的哲学和设计”。这些帖子探讨了“将基本操作转换为复杂操作的三种主要组合形式”、“Simplicity 的类型系统、组合子和基本表达式”，以及“如何从位开始构建逻辑操作[...直到...]加密操作，例如 SHA-256 和 Schnorr 签名验证，仅使用我们的计算 Simplicity 组合子”。

  最新的帖子表明该系列预计还会有更多条目。

- **<!--draft-bip-for-adding-elliptic-curve-operations-to-tapscript-->** **向 tapscript 添加椭圆曲线操作的 BIP 草稿**：Olaoluwa Osuntokun 在 Bitcoin-Dev 邮件列表中[发帖][osuntokun ec]，链接到了一个[BIP 草稿][osuntokun bip]，用于向 [tapscript][topic tapscript] 添加几个操作码，这些操作码将允许在脚本求值堆栈上执行椭圆曲线操作。这些操作码旨在与内省操作码结合使用，以创建或增强[限制条款][topic covenants]协议以及其他进展。

  Jeremy Rubin [回复][rubin ec1]建议添加额外的操作码以启用更多功能，以及[其他操作码][rubin ec2]，这些操作码将使基础提议提供的某些功能使用起来更加方便。

- **<!--draft-bip-for-op-tweakadd-->** **OP_TWEAKADD 的 BIP 草稿**：Jeremy Rubin 在 Bitcoin-Dev 邮件列表中[发帖][rubin ta1]，链接到了一个 [BIP 草稿][rubin bip]，用于将 `OP_TWEAKADD` 添加到 [tapscript][topic tapscript]。他单独[发帖][rubin ta2]介绍了通过添加该操作码启用的脚本的示例，包括揭示 [taproot][topic taproot] 调整的脚本、交易签名顺序证明（例如，Alice 必须在 Bob 之前签名）和[签名委托][topic signer delegation]。

## 发行和候选发行

_流行的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。_

- [Core Lightning v25.09][] 是这个流行的闪电网络节点实现的新主要版本发行。它为 `xpay` 命令添加了对支付 [BIP353][] 地址和简单 [offer][topic offers] 的支持，提供了改进的簿记支持，提供了更好的插件依赖管理，并包含其他新功能和错误修复。

- [Bitcoin Core 29.1rc2][] 是主流全节点软件维护版本的候选发行。

## 显著的代码和文档变更

_本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。_

- [LDK #3726][] 为[盲化路径][topic rv routing]添加了虚拟跳跃支持，使接收者能够添加不起路由作用但充当诱饵的任意跳跃。每次都会添加随机数量的虚拟跳跃，但上限为 10（由 `MAX_DUMMY_HOPS_COUNT` 定义）。添加额外的跳跃使确定到接收者节点的距离和接收者节点的身份变得更加困难。

- [LDK #4019][] 按照规范所要求的，通过在初始化拼接交易之前要求静默通道状态，将[拼接][topic splicing]与[静默协议][topic channel commitment upgrades]集成。

- [LND #9455][] 添加了对在闪电网络节点的公告消息中将有效的 DNS 域名与节点的 IP 地址和公钥关联的支持，这是规范允许的，并且得到了 Eclair 和 Core Lightning 等其他实现的支持（参见周报 [#212][news212 dns]、[#214][news214 dns] 和 [#178][news178 dns]）。

- [LND #10103][] 引入了一个新的 `gossip.peer-msg-rate-bytes` 选项（默认值 51200），它限制了每个对等节点用于出站 [gossip 消息][topic channel announcements]的出站带宽。这个值限制了平均带宽速度（以每秒字节数为单位），如果对等节点超过了这个限制，LND 将开始对发送给该对等节点的消息进行排队和延迟。这个新选项防止单个对等节点消耗由 [LND #10096][] 中引入的 `gossip.msg-rate-bytes` 定义的所有全局带宽。有关 LND 在 gossip 请求资源管理方面的工作，请参见周报 [#366][news366 gossip] 和 [#369][news369 gossip]。

- [HWI #795][] 通过将 `bitbox02` 库更新到版本 7.0.0 来添加对 BitBox02 Nova 的支持。它还进行了几项 CI 更新。

{% include snippets/recap-ad.md when="2025-09-09 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3726,4019,9455,10103,795,10096" %}
[bitcoin core 29.1rc2]: https://bitcoincore.org/bin/bitcoin-core-29.1/
[core lightning v25.09]: https://github.com/ElementsProject/lightning/releases/tag/v25.09
[sim1]: https://delvingbitcoin.org/t/delving-simplicity-part-three-fundamental-ways-of-combining-computations/1902
[sim2]: https://delvingbitcoin.org/t/delving-simplicity-part-combinator-completeness-of-simplicity/1935
[sim3]: https://delvingbitcoin.org/t/delving-simplicity-part-building-data-types/1956
[osuntokun ec]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAO3Pvs-Cwj=5vJgBfDqZGtvmoYPMrpKYFAYHRb_EqJ5i0PG0cA@mail.gmail.com/
[osuntokun bip]: https://github.com/bitcoin/bips/pull/1945
[rubin ec1]: https://mailing-list.bitcoindevs.xyz/bitcoindev/f118d974-8fd5-42b8-9105-57e215d8a14an@googlegroups.com/
[rubin ec2]: https://mailing-list.bitcoindevs.xyz/bitcoindev/1c2539ba-d937-4a0f-b50a-5b16809322a8n@googlegroups.com/
[rubin ta1]: https://mailing-list.bitcoindevs.xyz/bitcoindev/bc9ff794-b11e-47bc-8840-55b2bae22cf0n@googlegroups.com/
[rubin ta2]: https://mailing-list.bitcoindevs.xyz/bitcoindev/c51c489c-9417-4a60-b642-f819ccb07b15n@googlegroups.com/
[rubin bip]: https://github.com/bitcoin/bips/pull/1944
[news212 dns]: /zh/newsletters/2022/08/10/#bolts-911
[news214 dns]: /zh/newsletters/2022/08/24/#eclair-2234
[news178 dns]: /zh/newsletters/2021/12/08/#c-lightning-4829
[news366 gossip]: /zh/newsletters/2025/08/08/#lnd-10097
[news369 gossip]: /zh/newsletters/2025/08/29/#lnd-10102
