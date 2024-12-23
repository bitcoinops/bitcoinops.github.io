---
title: 'Bitcoin Optech Newsletter #333'
permalink: /zh/newsletters/2024/12/13/
name: 2024-12-13-newsletter-zh
slug: 2024-12-13-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报描述了一个可能从各种闪电网络实现的旧版本中窃取资金的漏洞，宣布了一个影响 Wasabi 及相关软件去匿名化的漏洞，总结了关于闪电网络通道耗尽的讨论，链接了一个关于特定限制条款提案的意见调查，描述了两种基于激励的伪限制条款，并引用了定期举行的 Bitcoin Core 开发者会议的总结。此外还包括我们的常规栏目，总结了 Bitcoin Core PR 审核俱乐部会议，列出了服务和客户端软件的变更，链接到了 Bitcoin Stack Exchange 上的热门问答，宣布了新版本和候选版本，并描述了流行的比特币基础设施软件的重要变更。

## 新闻

- **<!--vulnerability-allowing-theft-from-ln-channels-with-miner-assistance-->矿工协助下从闪电网络通道中窃取的漏洞：**
  David Harding 在 Delving Bitcoin 上[宣布][harding irrev]了他今年早些时候[负责任地披露][topic responsible disclosures]的一个漏洞。使用默认设置的老版本 Eclair、LDK 和 LND 允许开启通道的一方窃取高达 98% 的通道价值。使用非默认的 `--ignore-fee-limits` 配置选项的 Core Lightning 仍然会受影响；该选项的文档已经表明它是危险的。

  该公告还描述了该漏洞的两个不太严重的变体。上述所有闪电网络实现都试图缓解这些额外风险，但完整的解决方案还需要等待[交易包中继][topic package relay]、[通道升级][topic channel commitment upgrades]和相关项目的额外工作。

  该漏洞利用了闪电网络协议允许旧通道状态承诺比付费方在最新状态中控制的更多链上手续费的特点。例如，在 Mallory 控制通道余额 99% 的状态下，她将整体余额的 98% 用于[内生][topic fee sourcing]手续费。然后她创建一个新状态，只支付最低手续费，并将通道余额的 99% 转给 Bob。通过亲自挖出支付 98% 手续费的旧状态，她可以为自己获取这些手续费——将 Bob 预期能收到的 99% 实际减少到 2%。Mallory 可以使用这种方法同时从每个区块中约 3,000 个通道（每个通道可能由不同的受害者控制）中窃取资金，如果平均通道价值约为 1,000 美元，则每个区块可以窃取约 300 万美元。

  在损失资金前就发现攻击的用户无法通过关闭他们的闪电网络节点来保护自己，因为 Mallory 可能已经创建了必要的状态。即使受害者试图在最新状态下强制关闭他们的通道（例如，Bob 控制通道价值的 99% 的情况），Mallory 也可以通过牺牲自己 1% 的通道价值来导致他们损失 98% 的通道价值。

  能导致最严重情况的漏洞已经修复，较轻微的变体也得到部分缓解，方法是限制可以用于手续费的最大通道价值。由于仍然允许早期状态的手续费高于付费方在后期状态中控制的金额，一些盗窃仍然可能发生——但金额是有限的。完整的解决方案需要等待完全[外生][topic fee sourcing]手续费来源的改进（例如所有状态支付相同的承诺交易手续费），这依赖于比特币 P2P 协议中用于 [CPFP][topic cpfp] 手续费提升的健壮的交易包中继和闪电网络的通道承诺交易升级。

- **<!--deanonymization-vulnerability-affecting-wasabi-and-related-software-->****影响 Wasabi 和相关软件的去匿名化漏洞：**
  GingerWallet 的开发者[披露][drkgry deanon]了一种 [coinjoin][topic coinjoin] 协调者可以用来阻止用户在 coinjoin 交易期间保护隐私的方法。Bitcoin Magazine 记者 Shinobi [报道][shinobi deanon]说，该漏洞最初是由 Yuval Kogman 在 2021 年发现的，并与其他几个问题一起[报告][wasabi #5439]给了 Wasabi 开发团队。Optech 自 2022 年年中就知道 Kogman 对已部署的 Wasabi 版本有严重的未解决问题，但我们忽视了进一步调查；我们为此向他和 Wasabi 用户道歉。

- **<!--insights-into-channel-depletion-->对通道耗尽的见解：** René Pickhardt 在 Delving Bitcoin 上[发帖][pickhardt deplete]并与 Christian Decker 一起[参与][dd deplete]了一个关于他对支付通道网络（即闪电网络）数学基础研究的 Optech Deep Dive。他的 Delving Bitcoin 帖子特别关注了一个发现：如果路径被使用得足够多，网络中循环路径上的某些通道最终会耗尽。当一个通道实际上完全耗尽时，意味着它无法在耗尽的方向上转发额外的支付，循环路径（环）就会断开。随着网络图中的每个环相继断开，网络收敛到一个没有环的剩余图（生成树）。这重现了研究员 Gregorio Guidi 的[先前结果][guidi spanning]，尽管 Pickhardt 是从不同的方法得出的，并且似乎也在 Anastasios Sidiropoulos 的未发表研究中得到证实。

  ![循环、耗尽和剩余生成树的示例](/img/posts/2024-12-depletion.png)

  这个结果提供的最显著见解可能是，即使在没有源节点（即净支出者）和汇入节点（即净接收者）的循环经济体中，也会发生广泛的通道耗尽。如果闪电网络用于每一笔支付——客户对商家、商家对商家和商家对员工——它仍然会收敛到一个生成树。

  目前还不清楚节点是否希望他们的通道成为剩余生成树的一部分。一方面，该树代表了仍然能够转发支付的网络的最后部分——相当于一个中心辐射型拓扑——因此可能可以在剩余通道上收取高额转发费用。另一方面，剩余通道是在所有其他通道已经收取费用到耗尽之后剩下的。

  虽然转发费用更高的通道不太可能耗尽（在其他条件相同的情况下），但同一环路中其他通道的属性会很可能使得本通道流动性耗尽，这使得节点运营者仅通过控制其自身转发费用来试图防止耗尽变得具有挑战性。

  容量更高的通道也比容量较低的通道更不可能耗尽。这似乎很明显，但仔细考虑其原因会得出关于 k>2 多方链下协议的一个令人惊讶的见解。容量更高的通道支持参与者之间更多的财富分配，因此当等效支付通过容量较低的通道会耗尽一方的余额时，通过它的支付仍然是可行的。对于两个参与者，如在当前一代闪电网络通道中，每增加一个聪的容量将使财富分配范围增加一。然而，在[通道工厂][topic channel factories]和其他允许资金在 _k_ 方之间链下移动的多方构造中，每增加一个聪的容量将为 _k_ 方中的每一方增加财富分配范围——指数级地增加可行支付的数量并降低耗尽的风险。

  考虑当前闪电网络的一个例子，其中 Alice 与 Bob 和 Carol 有通道，他们之间也有一个通道：{AB, AC, BC}。每个通道的容量为 1 BTC。在这种配置中，Alice 可以控制（因此可以发送或接收）的最大值是 2 BTC。Bob 和 Carol 也适用相同的限制。如果使用总计 3 BTC 在通道工厂中重新创建所有三个通道，这些限制也会适用；但是，如果工厂保持运行，所有三方之间的链下状态更新可以将 Bob 和 Carol 之间的通道归零，允许 Alice 控制最多 3 BTC（因此她可以发送或接收最多 3 BTC）。后续的状态更新可以为 Bob 和 Carol 做同样的事情，也允许他们发送或接收最多 3 BTC。这种使用多方链下协议允许相同数量的资本为每个参与者提供更高容量的通道，这些通道不太可能耗尽。更少的耗尽和可行支付范围的扩大对应于闪电网络更高的最大吞吐量，正如 Pickhardt 之前写过的（参见周报 [#309][news309 feasible] 和 [#325][news325 feasible]）。

  在他的帖子和 Optech Deep Dive 讨论中，Pickhardt 寻求数据（例如来自大型 LSP）来帮助验证模拟结果。

- **<!--poll-of-opinions-about-covenant-proposals-->限制条款提案意见调查：** /dev/fd0 在比特币开发邮件列表中[发布][fd0 poll]了一个链接，指向关于一部分筛选出的[限制条款][topic covenants]提案的[公开调查][wiki poll]。Yuval Kogman [指出][kogman poll]，开发者被要求评估每个提案的“技术优点”和他们对其“社区支持的基于直觉的意见”，但由于调查的选项有限，开发者无法表达这两者的所有可能组合。Jonas Nick [要求][nick poll]“将技术评估与社区支持分开”，Anthony Towns [建议][towns poll]简单地询问开发者是否对每个提案有任何未解决的问题。Nick 和 Towns 分别建议开发者链接支持其观点的证据和论据。

  尽管讨论突出了调查的缺陷，但对某些提案表现出更多支持可能有助于限制条款研究人员收敛到一个供更广泛社区审查的想法的简短清单。

- **<!--incentive-based-pseudo-covenants-->基于激励的伪限制条款：** Jeremy Rubin 在比特币开发邮件列表中[发布][rubin unfed]了一个链接，指向他撰写的关于谕言机辅助[限制条款][topic covenants]的[论文][rubin unfed paper]。该模型涉及两个谕言机：一个_限制条款谕言机_和一个_完整性预言机_。限制条款谕言机将资金放在一个忠诚保证金中，并同意只签署基于返回成功的程序的交易。完整性预言机可以使用[可问责计算][topic acc]来证明为未返回成功的程序创建了签名，从而从保证金中没收资金。如果发生欺诈，无法保证因限制条款谕言机的欺骗而损失资金的用户能够收回损失的资金。

  Ethan Heilman 在比特币开发邮件列表中独立地[发布][heilman slash]了一个不同的构造，允许任何人使用欺诈证明来惩罚不正确的签名。然而，在这种情况下，资金不是被没收而是被销毁。这确保了欺诈签名者受到惩罚，但阻止了受害者收回他们损失的价值。

- **<!--bitcoin-core-developer-meeting-summaries-->****Bitcoin Core 开发者会议总结：** Bitcoin Core 的很多开发者在 10 月份进行了面对面会议，现在已经[发布][coredev notes]了几份会议记录。讨论主题包括[添加 payjoin 支持][adding payjoin support]、创建[多个相互通信的二进制文件][multiple binaries]、[挖矿接口][mining interface]和 [Stratum v2 支持][stratum v2 support]、改进的[基准测试][benchmarking]和[火焰图][flamegraphs]、[libbitcoinkernel 的 API][api for libbitcoinkernel]、防止[区块停滞][block stalling]、受 Core Lightning 启发的 [RPC 代码][rpc code]改进、恢复 [erlay 开发][development of erlay]以及[思考限制条款][contemplating covenants]。

## Bitcoin Core PR 审核俱乐部

*在这个月度栏目中，我们总结了最近的一次[Bitcoin Core PR 审核俱乐部][Bitcoin Core PR Review
Club]会议，重点介绍了一些重要的问题和答案。点击下面的问题可以查看会议中的答案摘要。*

[追踪和使用所有潜在对等节点进行孤儿交易解析][review club 31397]是由 [glozow][gh glozow] 提出的 PR，通过让节点向所有对等节点而不是仅向宣布孤儿交易的对等节点请求缺失的祖先交易来提高孤儿交易解析的可靠性。它通过引入 `m_orphan_resolution_tracker` 来负责记住哪些对等节点是孤儿交易解析的候选者，并安排何时发出孤儿交易解析请求。这种方法旨在节省带宽，不易受到审查，并在对等节点之间进行负载均衡。

{% include functions/details-list.md
  q0="<!--what-is-orphan-resolution-->什么是孤儿交易解析？"
  a0="当一个交易要花费的至少一笔交易在节点中并不存在时，这笔交易就被称为孤儿交易。孤儿交易解析是试图找到这些缺失交易的过程。"
  a0link="https://bitcoincore.reviews/31397#l-23"

  q1="<!--prior-to-this-pr-what-are-the-steps-for-orphan-resolution-starting-from-when-we-notice-that-the-transaction-has-missing-inputs-->在这个 PR 之前，当我们注意到交易有缺失的输入时，孤儿交易解析的步骤是什么？"
  a1="当节点收到孤儿交易时，它会向发来这笔孤儿交易的同一个对等节点请求其父交易。虽然其他对等节点不会被主动查询，但仍可能向我们发送父交易，例如当他们通过 INV 消息宣布它时，或当他们发送另一个具有相同缺失父交易的孤儿交易时。"
  a1link="https://bitcoincore.reviews/31397#l-29"

  q2="<!--what-are-the-ways-we-may-fail-to-resolve-an-orphan-with-the-peer-we-request-its-parents-from-what-are-some-reasons-this-may-happen-honest-or-otherwise-->在我们请求其父交易的对等节点的情况下，还可能有哪些无法解析孤儿交易的方式？这可能发生的原因有哪些，无论其诚实与否？"
  a2="诚实的对等节点可能只是断开连接，或者可能已经从其交易池中驱逐了父交易。恶意对等节点可能只是不响应请求，或者可能发送具有被篡改的、无效见证数据的父交易，这导致父交易具有预期的 txid 但验证失败。"
  a2link="https://bitcoincore.reviews/31397#l-49"

  q3="<!--how-could-an-attacker-prevent-a-node-from-downloading-a-1p1c-package-by-exploiting-today-s-orphan-resolution-behavior-->攻击者如何通过利用当前的孤儿交易解析行为来阻止节点下载 1p1c 包？"
  a3="攻击者可以主动公告一个被篡改的孤儿交易（见上一个问题）。一旦被篡改的孤儿交易被接受到孤儿池中，诚实的孤儿交易将不再被接受，因为它具有相同的 txid。这会阻止这个包被中继。或者，攻击者可以用孤儿交易淹没节点。由于孤儿池的大小有限，并且交易是随机驱逐的，这将影响节点下载 1p1c 包的能力。"
  a3link="https://bitcoincore.reviews/31397#l-64"

  q4="<!--what-is-the-pr-s-solution-to-the-problem-in-the-previous-question-->此 PR 对上一个问题中的问题提出了什么解决方案？"
  a4="不是将孤儿交易的缺失父交易添加到交易请求跟踪器中，而是将孤儿交易添加到新引入的 `m_orphan_resolution_tracker` 中。这个孤儿交易解析跟踪器安排何时应该从不同的对等节点请求父交易，然后将这些请求添加到常规交易请求跟踪器中。与会者建议并讨论了一种不需要额外 `m_orphan_resolution_tracker` 的替代方法，作者将进一步研究这种方法。"
  a4link="https://bitcoincore.reviews/31397#l-81"

  q5="<!--in-this-pr-which-peers-do-we-identify-as-potential-candidates-for-orphan-resolution-and-why-->在这个 PR 中，我们将哪些对等节点识别为孤儿交易解析的潜在候选者，为什么？"
  a5="所有公告了后来被证明是孤儿交易的对等节点都被标记为孤儿交易解析的潜在候选者。"
  a5link="https://bitcoincore.reviews/31397#l-127"

  q6="<!--what-does-the-node-do-if-a-peer-announces-a-transaction-that-is-currently-a-to-be-resolved-orphan-->如果一个对等节点宣布了一个当前是待解析孤儿交易的交易，节点会做什么？"
  a6="不是将交易添加到 m_txrequest 跟踪器中，而是将该对等节点添加为孤儿交易解析候选者。这有助于防止之前问题中描述的关于 1p1c 包审查的攻击。"
  a6link="https://bitcoincore.reviews/31397#l-148"

  q7="<!--why-might-we-prefer-to-resolve-orphans-with-outbound-peers-over-inbound-peers-->为什么我们可能更倾向于使用出站对等节点而不是入站对等节点来解析孤儿交易？"
  a7="出站对等节点是由节点选择的，因此被认为更值得信任。虽然出站对等节点可能是恶意的，但至少它们不太可能专门针对你的节点。"
  a7link="https://bitcoincore.reviews/31397#l-251"
%}

## 服务和客户端软件变更

*在这个月度专题中，我们重点介绍比特币钱包和服务的有趣更新。*

- **<!--java-based-hwi-released-->****基于 Java 的 HWI 发布：**
  [Lark App][larkapp github] 是一个用于与硬件签名设备交互的命令行应用程序。它使用 [Lark Java 库][lark github]，这是 [HWI][topic hwi] 的 Java 编程语言移植版本。

- **<!--saving-satoshi-bitcoin-development-education-game-announced-->****Saving Satoshi 比特币开发教育游戏宣布：**
  [Saving Satoshi][saving satoshi website] 网站为比特币开发新手提供互动教育练习。

- **<!--neovim-bitcoin-script-plugin-->****Neovim 比特币脚本插件：**
  [Bitcoin script hints][bsh github] Neovim 的 Rust 插件在编辑器中显示比特币脚本的每个操作的堆栈状态。

- **<!--proton-wallet-adds-rbf-->****Proton 钱包添加 RBF：**
  Proton 钱包用户现在可以使用 [RBF][topic rbf] 来[提升他们的交易手续费][proton blog]。

## 来自 Bitcoin Stack Exchange 的精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找答案的首选之一，也是我们有空闲时帮助好奇或困惑用户的地方。在这个月度专题中，我们重点介绍自上次更新以来发布的一些投票最高的问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--how-long-does-bitcoin-core-store-forked-chains-->Bitcoin Core 存储分叉链多长时间？]({{bse}}124973)
  Pieter Wuille 解释说，除了运行在修剪模式下的 Bitcoin Core 节点外，节点下载的区块，无论是否在主链上，都会无限期存储。

- [<!--what-is-the-point-of-solo-mining-pools-->独自挖矿池的意义是什么？]({{bse}}124926)
  Murch 概述了为什么比特币矿工可能会使用不向其参与者分配挖矿奖励的挖矿池，即_独自挖矿池_。

- [<!--is-there-a-point-to-using-p2tr-over-p2wsh-if-i-only-want-to-use-the-script-path-->如果我只想使用脚本路径，使用 P2TR 而不是 P2WSH 有意义吗？]({{bse}}124888)
  Vojtěch Strnad 指出了使用 P2WSH 的潜在成本节省，但也指出了其他 [P2TR][topic taproot] 的好处，包括隐私、使用脚本树和 [PTLC][topic ptlc] 的可用性。

## 发布和发布候选

*新版本和发布候选版本的流行比特币基础设施项目。请考虑升级到新版本或帮助测试发布候选版本。*

- [Core Lightning 24.11][] 是这个流行的闪电网络实现的下一个主要版本的发布。它包含一个用于使用高级路由选择进行支付的实验性新插件；默认启用了支付和接收 [offer][topic offers] 的支付；添加了多个[通道拼接][topic splicing]的改进，以及其他几个功能和错误修复。

- [BTCPay Server 2.0.4][] 是这个支付处理软件的一个发布版本，包括多个新功能、改进和错误修复。

- [LND 0.18.4-beta.rc2][] 是这个流行的闪电网络实现的小版本的发布候选版本。

- [Bitcoin Core 28.1RC1][] 是这个占主导地位的全节点实现的维护版本的发布候选版本。

- [BDK 1.0.0-beta.6][] 是这个用于构建比特币钱包和其他启用比特币功能的应用程序的库在 `bdk_wallet` 1.0.0 发布之前的最后一个计划的测试版本。

## 重要代码和文档变更

_本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、
[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。_

- [Bitcoin Core #31096][] 通过更改 `AcceptPackage` 函数的逻辑并放宽对 `submitpackage` 的检查，移除了对 `submitpackage` RPC 命令（参见[周报 #272][news272 submitpackage]）的限制，该限制不允许包含单个交易的包。虽然单个交易在技术上不符合[交易包中继][topic package relay]规范下的包的资格，但没有理由阻止用户使用此命令提交符合网络政策的交易。

- [Bitcoin Core #31175][] 从 `submitblock` RPC 命令和 `bitcoin-chainstate.cpp` 中移除了冗余的预检查，这些预检查验证区块是否包含 coinbase 交易或是重复的，因为这些检查已经在 `ProcessNewBlock` 中完成。这一变更统一了各个接口的行为，如挖矿 IPC（参见[周报 #323][news323 ipc]）和 `net_processing`，为 [libbitcoinkernel][libbitcoinkernel project] API 项目做准备。此外，使用 `submitblock` 提交的重复区块现在即使之前被修剪，也会保留其数据，并且当区块文件被选择进行修剪时最终会被再次修剪，以与 `getblockfrompeer` 的行为保持一致。

- [Bitcoin Core #31112][] 扩展了 `CCheckQueue` 功能，以改进多线程脚本验证条件下的脚本错误日志记录。以前，由于线程之间信息传输有限，详细的错误报告仅在使用 `par=1`（单线程脚本验证）时可用。此外，日志记录现在包括有关哪个交易输入出现脚本错误以及花费了哪个 UTXO 的详细信息。

- [LDK #3446][] 添加了在 [BOLT12][topic offers] 发票上包含[蹦床支付][topic trampoline payments]标志的支持。这并不提供使用蹦床路由或提供蹦床路由服务的完整支持，但为未来的功能奠定了基础。蹦床支付支持是 LDK 计划部署的一种[异步支付][topic async payments]类型的先决条件。

- [Rust Bitcoin #3682][] 添加了几个工具来使 `hashes`、`io`、`primitives` 和 `units` crates 的公共 API 接口更稳定，如预生成的 API 文本文件、使用 `cargo check-api` 生成这些文本文件的脚本、轻松查询这些 API 文本文件的脚本，以及比较 API 代码及其相应文本文件以轻松检测意外 API 变更的 CI 作业。这个 PR 还更新了文档，概述了对贡献开发者的期待：当他们更新这些 crates 的 API 端点时，必须运行文本文件生成脚本。

- [BTCPay Server #5743][] 为多重签名和只读钱包引入了“待处理交易”的概念，这是一个不需要立即签名的 [PSBT][topic psbt]。交易在签名者上线并提供签名时收集签名，当有足够的签名时就会广播。这个 PR 还自动标记交易为完成，当它们被签名者签名并从链上移除时，当关联的 UTXOs 被花费时，允许可选的过期时间以避免过时的费率。这个系统允许支付处理器为等待签名的支付创建待处理交易，并在支付变化且签名未收集时取消或替换待处理交易。这个系统还可以扩展到在创建待处理交易时向签名者发送电子邮件，以提醒他们上线。

- [BDK #1756][] 添加了一个异常，以防止 `fetch_prev_txout` 尝试查询 coinbase 交易的 prevouts，因为它们没有。以前，这种行为导致 `bdk_electrum` 崩溃，同步或完整扫描过程失败。

- [BIPs #1535][] 合并了 [BIP348][] 用于指定 [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] 操作码的规范，该操作码允许检查签名是否对任意消息签名。它将签名、消息和公钥放在堆栈上，签名必须匹配公钥和消息。该提案是众多[限制条款][topic covenants]提案之一。

- [BOLTs #1180][] 更新了 [BOLT12][topic offers] 以指定在发票请求中包含 [BIP353][] 人类可读的比特币支付说明的选项（见[周报 #290][news290 omdns]）。 [BLIPs #48][] 更新了 [BLIP32][]（见[周报 #306][news306 blip32]）以引用对 [BOLT12][topic offers] 的更新。

## 节日快乐！

这是 Bitcoin Optech 的最后一个常规周报。在周五，12 月 20 日，我们将发布第七个年度回顾周报。常规出版将在周五，1 月 3 日恢复。

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 15:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31096,31175,31112,3446,3682,5743,1756,1535,1180,48" %}
[core lightning 24.11]: https://github.com/ElementsProject/lightning/releases/tag/v24.11
[lnd 0.18.4-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.4-beta.rc2
[eclair v0.11.0]: https://github.com/ACINQ/eclair/releases/tag/v0.11.0
[ldk v0.0.125]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.125
[bitcoin core 28.1RC1]: https://bitcoincore.org/bin/bitcoin-core-28.1/
[harding irrev]: https://delvingbitcoin.org/t/disclosure-irrevocable-fees-stealing-from-ln-using-revoked-commitment-transactions/1314
[pickhardt deplete]: https://delvingbitcoin.org/t/channel-depletion-ln-topology-cycles-and-rational-behavior-of-nodes/1259/6
[guidi spanning]: https://diyhpl.us/~bryan/irc/bitcoin/bitcoin-dev/linuxfoundation-pipermail/lightning-dev/2019-August/002115.txt
[news309 feasible]: /zh/newsletters/2024/06/28/#estimating-the-likelihood-that-an-ln-payment-is-feasible-ln
[news325 feasible]: /zh/newsletters/2024/10/18/#research-on-fundamental-delivery-limits
[fd0 poll]: https://gnusha.org/pi/bitcoindev/028c0197-5c45-4929-83a9-cfe7c87d17f4n@googlegroups.com/
[wiki poll]: https://en.bitcoin.it/wiki/Covenants_support
[kogman poll]: https://gnusha.org/pi/bitcoindev/CAAQdECALHHysr4PNRGXcFMCk5AjRDYgquUUUvuvwHGoeJDgZJA@mail.gmail.com/
[nick poll]: https://gnusha.org/pi/bitcoindev/941b8c22-0b2c-4734-af87-00f034d79e2e@gmail.com/
[towns poll]: https://gnusha.org/pi/bitcoindev/Z1dPfjDwioa%2FDXzp@erisian.com.au/
[rubin unfed]: https://gnusha.org/pi/bitcoindev/30440182-3d70-48c5-a01d-fad3c1e8048en@googlegroups.com/
[rubin unfed paper]: https://rubin.io/public/pdfs/unfedcovenants.pdf
[heilman slash]: https://gnusha.org/pi/bitcoindev/CAEM=y+V_jUoupVRBPqwzOQaUVNdJj5uJy3LK9JjD7ixuCYEt-A@mail.gmail.com/
[drkgry deanon]: https://github.com/GingerPrivacy/GingerWallet/discussions/116
[shinobi deanon]: https://bitcoinmagazine.com/technical/wabisabi-deanonymization-vulnerability-disclosed
[wasabi #5439]: https://github.com/WalletWasabi/WalletWasabi/issues/5439
[adding payjoin support]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/payjoin
[multiple binaries]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/multiprocess-binaries
[mining interface]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/mining-interface
[stratum v2 support]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/stratumv2
[benchmarking]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/leveldb
[flamegraphs]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/flamegraphs
[api for libbitcoinkernel]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/kernel
[block stalling]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/block-stalling
[rpc code]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/rpc-discussion
[development of erlay]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/erlay
[contemplating covenants]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/covenants
[coredev notes]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10
[dd deplete]: /en/podcast/2024/12/12/
[bdk 1.0.0-beta.6]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.6
[btcpay server 2.0.4]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.0.4
[larkapp github]: https://github.com/sparrowwallet/larkapp
[lark github]: https://github.com/sparrowwallet/lark
[saving satoshi website]: https://savingsatoshi.com/
[bsh github]: https://github.com/taproot-wizards/bitcoin-script-hints.nvim
[proton blog]: https://proton.me/support/speed-up-bitcoin-transactions
[news272 submitpackage]: /zh/newsletters/2023/10/11/#bitcoin-core-27609
[news323 ipc]: /zh/newsletters/2024/10/04/#bitcoin-core-30510
[libbitcoinkernel project]: https://github.com/bitcoin/bitcoin/issues/24303
[news290 omdns]: /zh/newsletters/2024/02/21/#dns-based-human-readable-bitcoin-payment-dns
[news306 blip32]: /zh/newsletters/2024/06/07/#blips-32
[review club 31397]: https://bitcoincore.reviews/31397
[gh glozow]: https://github.com/glozow
