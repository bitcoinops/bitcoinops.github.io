---
title: 'Bitcoin Optech Newsletter #332'
permalink: /zh/newsletters/2024/12/06/
name: 2024-12-06-newsletter-zh
slug: 2024-12-06-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报宣布了一项关于交易审查漏洞的披露，并总结了有关共识清理软分叉提案的讨论。此外，还包括我们常规的部分：新版本和候选版本的公告，以及对热门比特币基础设施项目的重大变更介绍。

## 新闻

- **交易审查漏洞：** Antoine Riard 在 Bitcoin-Dev 邮件列表中[发布][riard censor] 了一种方法，该方法可以阻止节点广播属于连接钱包的交易。如果该钱包属于用户的闪电网络（LN）节点，则攻击者可以通过这种方式阻止用户在超时到期前确保他们应得的资金，从而让对手方窃取这些资金。

  这种攻击有两个版本，均利用了 Bitcoin Core 内部与其在特定时间段内广播或接受未确认交易数量的最大限制有关的机制。这些限制是为了防止对节点的过度负担或拒绝服务攻击。

  第一种攻击方式，被 Riard 称为 _“高溢出（high overflow）”_，利用了 Bitcoin Core 每次仅向其对等节点广播最多 1000 个未确认交易的限制。如果有超过 1000 笔交易排队等待发送，则优先广播手续费率最高的交易。发送完一批广播后，Bitcoin Core 会等待，直到其最近的平均广播速率降至每秒七笔交易。

  如果这 1000 笔初始广播中的交易手续费率均高于受害者希望广播的交易，而攻击者继续以每秒至少七笔交易的速率发送高手续费交易，那么攻击者可以无限期阻止广播。大多数针对 LN 的攻击需要延迟交易广播约 32 个区块（Core Lightning 默认设置）到 140 个区块（Eclair 默认设置），按照 10 sats/vbytes 的手续费率计算，攻击成本在 1.3 BTC（约 130000 美元）到 5.9 BTC（约 590000 美元）之间。不过，Riard 指出，精明的攻击者如果与其他中继节点或大型矿工直接连接，可能显著降低这些成本。

  第二种攻击方式，被称为 _“低溢出”（low overflow）”_，利用了 Bitcoin Core 拒绝将其未请求交易的队列增长到超过每个对等节点 5000 笔的限制。攻击者向受害者发送大量手续费率最低的交易；受害者将这些交易广播给其诚实的对等节点，这些节点会将交易公告排队；此后，它们会定期尝试清空队列，但随着未处理的公告积累，达到 5000 笔的上限后，对等节点将忽略新的公告。如果此时受害者的合法交易被公告，对等节点也会忽略它。这种攻击的成本显著低于高溢出变体，因为攻击者的垃圾交易可以支付最低中继手续费，但攻击可能不如高溢出可靠，因此攻击者可能因未成功盗窃而损失手续费。

  从简单的层面来看，这些攻击似乎并不令人担忧。很少有支付通道的未完成支付金额会高于攻击成本。Riard 建议高价值 LN 通道的用户运行额外的完整节点，包括那些不接受入站连接并使用 _仅区块模式_ 的节点，以确保它们只中继本地钱包提交的未确认交易。一些更复杂的攻击可能降低成本，或者使用同一批垃圾交易同时攻击多个 LN 通道，这可能会影响价值较低的通道。Riard 提出了一些 LN 实现的缓解措施，并将可能处理该问题的 Bitcoin Core P2P 中继协议变更留待日后讨论。

  _注：_ 由于我们在本周周报发布前不久才得知此漏洞披露，若以上描述存在任何错误，我们深表歉意。

- **持续讨论共识清理软分叉提案：**
  Antoine Poinsot 在现有的 Delving Bitcoin 主题中继续[讨论了][poinsot time warp][共识清理 ][topic consensus cleanup] 软分叉提案。除了已经提议修复的经典[时间扭曲漏洞(time warp)][topic time warp]外，他还建议包括修复最近发现的 Zawy-Murch 时间扭曲漏洞(见[周报 #316][news316 time warp])。他支持 Mark “Murch” Erhardt 最初提出的修复方法：“要求同一难度调整周期 _N_ 的最后一个区块的时间戳必须高于该周期 _N_ 的第一个区块的时间戳”。

  Anthony Towns 则更[支持][towns time warp] Zawy 提出的另一种解决方案，该方案禁止任何区块声称其产生时间早于之前任何区块的时间超过两小时。Zawy [指出][zawy time warp]，他的“每个区块”解决方案会增加运行过时软件的矿工损失金钱的风险，但也会使时间戳在其他用途上的准确性更高，如[时间锁][topic timelocks]。

  此外，Poinsot 分别在 [Delving Bitcoin][poinsot duptx delv] 和 [Bitcoin-Dev 邮件列表][poinsot duptx ml]中征求了关于防止区块 1983702 和之后的一些区块[重复][topic duplicate transactions]之前的 coinbase 交易（可能导致资金损失和攻击向量）的解决方案反馈。提出了四种解决方案，所有这些方案仅直接影响矿工，因此尤其需要[矿工的反馈][mining-dev]。

## 版本和候选版本

_热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。_

- [Eclair v0.11.0][] 是热门的 LN 节点实现的最新版本。此版本“添加了对 BOLT12 [要约（offers）][topic offers]的官方支持，并在流动性管理功能([通道拼接][topic splicing]、[流动性广告][topic liquidity advertisements]和[“空中加油”注资（on-the-fly）][topic jit channels])方面取得了进展。” 此外，该版本停止接受新的非[锚点通道][topic anchor outputs]，还包括了一些优化和错误修复。

- [LDK v0.0.125][] 是用于构建支持 LN 应用程序的库的最新版本，其中包含多个错误修复。

- [Core Lightning 24.11rc3][]是热门 LN 实现的下一个主要版本的候选版本。

- [LND 0.18.4-beta.rc1][] 是热门 LN 实现的一个小版本候选版本。

- [Bitcoin Core 28.1RC1][] 是主流全节点实现的一个维护版本候选版本。

## 重大的代码和文档变更

_本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。_

- [Bitcoin Core #30708][] 新增了 `getdescriptoractivity` RPC 命令，可在指定的区块哈希集合中检索与[描述符][topic descriptors]关联的所有交易。这使得钱包能够以无状态的方式与 Bitcoin Core 交互。此命令与 `scanblocks` (见 [周报 #222][news222 scanblocks])结合使用时特别有用，后者用于识别包含与描述符关联的交易的区块哈希集合。

- [Core Lightning #7832][] 开始从[锚点输出][topic anchor outputs]中支出（从 2016 个区块目标开始，逐渐减少到 12 个区块，大约两周），即使对于非紧急单边关闭交易。广播时间戳会被追踪，以确保重启后行为的一致性。此前，这些交易默认不从锚点输出中支出，这使得手动创建支出变得困难，也无法使用[CPFP][topic cpfp]来提升锚点支出的手续费。

- [LND #8270][] 实现了 [BOLT2][] 中指定的通道静止协议(见[周报 #309][news309 quiescence])，这是[动态承诺][topic channel commitment upgrades] 和 [通道拼接][topic splicing]的前置条件。该协议允许节点响应对等方的静止请求，并通过新的 `ChannelUpdateHandler` 操作启动该过程。此外，此 PR 增加了一个可配置的超时机制，用于在对等节点在静止状态中长时间未解决时断开连接。

- [LND #8390][] 引入了对在 `update_add_htlc` 消息中设置和转发实验性 [HTLC 背书][topic htlc endorsement]信号字段的支持，旨在研究防止[通道堵塞攻击][topic channel jamming attacks]。如果节点收到带有信号字段的 HTLC，它将按原样转发；否则，将默认设置为零。此功能默认启用，但可以禁用。

- [BIPs #1534][] 合并了 [BIP349][]，该提案定义了 `OP_INTERNALKEY` 的规范。这是一种新的仅限于 [tapscript][topic tapscript] 的操作码，用于将 Taproot 内部密钥推送到堆栈上。脚本的作者需要在付款到某个输出之前知道内部密钥，因此这是将内部密钥直接包含在脚本中的一种替代方案。它每次使用可节省 8 个 vbytes，同时提高脚本的可复用性(见 [周报 #285][news285 bip349])。


{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30708,7832,8270,8390,1534" %}
[core lightning 24.11rc3]: https://github.com/ElementsProject/lightning/releases/tag/v24.11rc3
[lnd 0.18.4-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.4-beta.rc1
[news316 time warp]: /zh/newsletters/2024/08/16/#new-time-warp-vulnerability-in-testnet4
[poinsot time warp]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/53
[towns time warp]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/54
[zawy time warp]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/55
[poinsot duptx delv]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/51
[poinsot duptx ml]: https://groups.google.com/g/bitcoindev/c/KRwDa8aX3to
[mining-dev]: https://groups.google.com/g/bitcoinminingdev/c/qyrPzU1WKSI
[eclair v0.11.0]: https://github.com/ACINQ/eclair/releases/tag/v0.11.0
[ldk v0.0.125]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.125
[bitcoin core 28.1RC1]: https://bitcoincore.org/bin/bitcoin-core-28.1/
[riard censor]: https://groups.google.com/g/bitcoindev/c/GuS36ldye7s
[news222 scanblocks]: /zh/newsletters/2022/10/19/#bitcoin-core-23549
[news309 quiescence]: /zh/newsletters/2024/06/28/#bolts-869
[news285 bip349]: /zh/newsletters/2024/01/17/#new-lnhance-combination-soft-fork-proposed
