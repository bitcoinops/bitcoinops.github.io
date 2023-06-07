---
title: 'Bitcoin Optech Newsletter #251'
permalink: /zh/newsletters/2023/05/17/
name: 2023-05-17-newsletter-zh
slug: 2023-05-17-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报介绍了一项开始测试 HTLC 背书的提案，征求有关闪电服务提供商（LSP）拟议规范的反馈意见，讨论了在使用双重充值时开放零配置通道的挑战，研究了一种高级 payjoin 交易应用程序的建议，并提供了 Bitcoin Core 开发人员最近的面对面会议摘要的链接。本周的周报还包括了有关交易中继和交易池包容性政策的新系列的第一部分，以及我们定期发布的新版本和候选发布版本（包括 libsecp256k1 的安全版本）的公告，以及描述流行的比特币基础设施软件的显着变化。

## 新闻

- **测试 HTLC 背书：** 几周前，Carla Kirk-Cohen 和 Clara Shikhelman 在 Lightning-Dev 邮件列表上[发布][kcs endorsement]了他们和其他人计划采取的下一步行动，以测试 [HTLC][topic htlc] 背书的想法（请参见 [Newsletter＃239][news239 endorsement]），作为缓解[通道阻塞攻击][topic channel jamming attacks] 的一部分。最值得注意的是，他们提供了一个简短的[提议规范][bolts #1071]，可以使用实验标志进行部署，防止其部署对与非参与节点的交互产生任何影响。

    实验者一旦部署，就应该更容易回答这个想法的[建设性批评][decker endorsement]之一，即实际上有多少转发付款会从该方案中获得提升。如果闪电网络的核心用户经常通过许多相同的路由相互发送支付，并且如果信誉系统按计划运行，那么该核心网络将更有可能在通道阻塞攻击期间保持运行。但是，如果大多数消费者很少发送付款（或者很少发送他们最关键的付款类型，例如大额付款），那么他们将没有足够的互动来建立声誉，或者声誉数据将远远落后于网络的当前状态（使其变得不那么有用，甚至允许滥用声誉）。 {% assign timestamp="1:33" %}

- **请求对 LSP 拟议规范的反馈：**Severin Bühler 在 Lightning-Dev 邮件列表中[发布][buhler lsp]了一个对闪电服务提供商 (LSP) 与其客户（通常是非转发闪电节点）之间互操作性的两项技术规范的反馈请求。第一个规范描述了一个允许客户从 LSP 购买通道的 API。第二个规范描述了一个用于设置和管理即时 (JIT) 通道的 API，这些通道以虚拟支付渠道的形式开始；当收到对虚拟通道的第一笔付款时，LSP 广播一个交易，该交易将在确认后将通道锚定在链上（使其成为常规通道）。

    在[回复][zmnscpxj lsp]中，开发人员 ZmnSCPxj 写到支持 LSP 的开放规范。他指出，它们使客户可以轻松连接到多个 LSP，这将防止供应商锁定并改善隐私。 {% assign timestamp="14:52" %}

- **<!--challenges-with-zero-conf-channels-when-dual-funding-->双重充值对零配置通道的挑战：**Bastien Teinturier 在 Lightning-Dev 邮件列表中[发布][teinturier 0conf]，关于在使用[双重充值协议][topic dual funding]。零配置通道甚至可以在通道打开交易确认之前使用；在某些情况下这是无需信任的。双重充值通道是使用双重充值协议创建的通道，其中可能包括开放交易包含通道双方输入的通道。

    只有当一方控制公开交易的所有输入时，零配置才是无信任的。例如，Alice 创建公开交易，在通道中给 Bob 一些资金，Bob 尝试通过 Alice 将这些资金花给 Carol。 Alice 可以安全地将付款转发给 Carol，因为 Alice 知道她控制着最终被确认的公开交易。但是，如果 Bob 在公开交易中也有输入，他可以获得冲突交易确认，这将阻止公开交易确认——防止 Alice 因她转发给 Carol 的任何钱而得到补偿。

    允许通过双重充值打开零配置通道的几个想法已被讨论，尽管在撰写本文时似乎没有一个令参与者满意。 {% assign timestamp="20:59" %}

- **高级 payjoin 应用：**Dan Gould 在 Bitcoin-Dev 邮件列表中[发布][gould payjoin]了关于使用 [payjoin][topic payjoin] 协议实现不仅仅是发送或接收简单付款的一些建议。我们发现最有趣的两个建议是[交易合并（transaction cut-through）][transaction cut-through]的版本。这是一个改善隐私、提高可扩展性和降低费用成本的老想法：

    - *<!--payment-forwarding-->付款转发：*Alice 不是向 Bob 付款，而是向 Bob 的供应商 (Carol) 付款，从而减少他欠她的债务（或预付预期的未来账单）。

    - *<!--batched-payment-forwarding-->批量付款转发：*Alice 不是向 Bob 付款，而是向 Bob 欠款（或想与之建立信用）的几个人付款。 Gould 的例子考虑了一个有稳定存款和取款流的交易所； payjoin 允许在可能的情况下用新存款支付提款。

    这两种技术都允许将至少两笔交易减少到一笔交易中，从而节省大量的块空间。当使用[批量付款][topic payment batching]时，空间节省可能会更大。从原始接收者（例如 Bob）的角度来看更好，原始支出者（例如 Alice）可能会支付全部或部分费用。除了节省空间和费用之外，从区块链中删除交易并将接收和支出等操作结合起来，使得区块链监控组织更难以可靠地追踪资金流向。

    在撰写本文时，该帖子尚未在邮件列表中收到任何讨论。 {% assign timestamp="24:51" %}

- **Bitcoin Core 开发人员面对面会议摘要：**几位从事 Bitcoin Core 工作的开发人员最近开会讨论了该项目的各个方面。会议期间的几次讨论的笔记已经发表。讨论的主题包括[模糊测试][fuzz testing]、[假设UTXO][assumeUTXO]、[ASMap][]、[静默支付][silent payments]、[libbitcoinkernel][]、[重构（或不重构）][refactoring (or not)]和[包中继][package relay]。还讨论了我们认为值得特别关注的另外两个主题：{% assign timestamp="37:35" %}

    * [交易池聚类][mempool clustering]总结了一项重大重新设计交易及其元数据如何存储在 Bitcoin Core 交易池中的建议。这些说明描述了当前设计的许多问题，提供了新设计的概述，并提出了一些挑战和所涉及的权衡。设计的[描述][bitcoin core #27677]和演示文稿中[幻灯片][mempool slides]的副本随后已发布。

    * [项目元讨论][project meta discussion]总结了关于项目目标的各种讨论，以及如何在面临许多内部和外部挑战的情况下实现这些目标。一些讨论已经导致项目管理的实验性变化，例如在版本 25 之后的下一个主要版本采用更加以项目为中心的方法。

## 等待确认 #1: 我们为什么需要一个交易池？

_关于交易中继、交易池接纳和挖矿交易选择的限定版每周系列内容的第一部分——包括为什么 Bitcoin Core 有着比共识允许的更严格的策略，以及钱包如何最有效地使用该策略。_

{% include specials/policy/zh/01-why-mempool.md %} {% assign timestamp="51:07" %}

## 新版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试旧版本。*

- [Libsecp256k1 0.3.2][] 是针对将 libsecp 用于 [ECDH][] 且可能使用 GCC 13 或更高版本编译的应用程序的安全版本。正如[作者所描述的][secp ml]，新版本的 GCC 试图优化设计为在固定时间内运行的 libsecp 代码，从而在一些特定情况下可以执行[侧信道攻击][topic side channels]。值得注意的是，Bitcoin Core 不使用 ECDH，因此不受影响。目前正在进行的工作是尝试检测未来对编译器的更改何时可能导致类似问题，从而允许提前进行更改。 {% assign timestamp="1:04:21" %}

- [Core Lightning 23.05rc2][] 是此闪电网络实现的下一版本的候选发布版本。 {% assign timestamp="1:05:07" %}

- [Bitcoin Core 23.2rc1][] 是 Bitcoin Core 先前主要版本的维护版本的候选版本。 {% assign timestamp="1:05:20" %}

- [Bitcoin Core 24.1rc3][] 是对 Bitcoin Core 当前版本维护发布的一个候选发布版本。 {% assign timestamp="1:05:20" %}

- [Bitcoin Core 25.0rc2][] 是 Bitcoin Core 下一个主要版本的候选发布版本。 {% assign timestamp="1:05:20" %}

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo] 和 [Bitcoin Inquisition][bitcoin inquisition repo]*。

- [Bitcoin Core #26076][] 更新显示公钥派生路径的 RPC 方法，现在使用 `h` 而不是单引号 `'` 来指示强化的派生步骤。请注意，这会更改描述符校验和。使用私钥处理描述符时，使用与生成或导入描述符时相同的符号。对于老钱包 `getaddressinfo` 中的 `hdkeypath` 字段和钱包转储的序列化格式保持不变。 {% assign timestamp="1:06:10" %}

- [Bitcoin Core #27608][] 将继续尝试从一个对等节点下载一个区块，即使另一个节点提供了该区块。 Bitcoin Core 将继续尝试从声称拥有它的节点下载该区块，直到接收到的其中一个区块已写入磁盘。 {% assign timestamp="1:07:20" %}

- [LDK #2286][] 允许为本地钱包控制的输出创建和签署 [PSBTs][topic psbt]。 {% assign timestamp="1:08:27" %}

- [LDK #1794][] 开始添加对[双重充值][topic dual funding]的支持。该支持从用于双重充值的交互式充值协议所需的方法开始。{% assign timestamp="1:08:47" %}

- [Rust Bitcoin #1844][] 使 [BIP21][] URI 小写的模式，即 `bitcoin:`。尽管 URI 架构规范 (RFC3986) 表示该架构不区分大小写，但测试表明，当传递大写 `BITCOIN:` 的 URI 时，某些平台不会打开那些只处理 `bitcoin:` 的应用。如果能正确处理大写字母会更好，因为它允许创建更有效的 QR 码（参见 [Newsletter #46][news46 qr]）。 {% assign timestamp="1:09:08" %}

- [Rust Bitcoin #1837][] 添加了一个生成新私钥的功能，简化了以前需要更多代码才能完成的工作。 {% assign timestamp="1:11:33" %}

- [BOLTs #1075][] 更新规范，以便节点在收到来自对等节点的警告消息后不应再断开与它的连接。 {% assign timestamp="1:12:04" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="26076,27608,2286,1794,1844,1837,1075,1071,27677" %}
[Core Lightning 23.05rc2]: https://github.com/ElementsProject/lightning/releases/tag/v23.05rc2
[bitcoin core 23.2rc1]: https://bitcoincore.org/bin/bitcoin-core-23.2/
[bitcoin core 24.1rc3]: https://bitcoincore.org/bin/bitcoin-core-24.1/
[bitcoin core 25.0rc2]: https://bitcoincore.org/bin/bitcoin-core-25.0/
[news239 endorsement]: /zh/newsletters/2023/02/22/#feedback-requested-on-ln-good-neighbor-scoring
[fuzz testing]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-27-fuzzing/
[assumeutxo]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-27-assumeutxo/
[asmap]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-27-asmap/
[silent payments]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-26-silent-payments/
[libbitcoinkernel]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-26-libbitcoin-kernel/
[refactoring (or not)]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-25-refactors/
[package relay]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-25-package-relay-primer/
[mempool clustering]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-25-mempool-clustering/
[project meta discussion]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-26-meta-discussion/
[kcs endorsement]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-April/003918.html
[decker endorsement]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-May/003944.html
[buhler lsp]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-May/003926.html
[zmnscpxj lsp]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-May/003930.html
[teinturier 0conf]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-May/003920.html
[gould payjoin]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021653.html
[transaction cut-through]: https://bitcointalk.org/index.php?topic=281848.0
[news46 qr]: /en/newsletters/2019/05/14/#bech32-sending-support
[mempool slides]: https://github.com/bitcoin/bitcoin/files/11490409/Reinventing.the.Mempool.pdf
[secp ml]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021683.html
[libsecp256k1 0.3.2]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.3.2
[ecdh]: https://en.wikipedia.org/wiki/Elliptic-curve_Diffie%E2%80%93Hellman
