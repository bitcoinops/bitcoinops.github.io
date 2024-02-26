---
title: 'Bitcoin Optech Newsletter #283'
permalink: /zh/newsletters/2024/01/03/
name: 2024-01-03-newsletter-zh
slug: 2024-01-03-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报分享了对 LND 过往版本漏洞的披露，总结了一项关于依赖于手续费的时间锁的提议，介绍了一个使用交易族群来优化手续费估计的想法，讨论了如何在描述符中指定不可花费的密钥，估计了在 v3 交易转发提议中发动钉死攻击的代价，提及了一项还在提议阶段、允许描述符被包含在 PSBT 中的 BIP，介绍了一个可以跟 MATT 提议一起使用来证明某个程序被正确执行的工具，检视了一项允许多位成员从一个资金池 UTXO 中高效退出的提议，并指出了人们为 Bitcoin Core 提交的新的选币策略。此外是我们常规栏目：软件的新版本和候选版本的发布公告，以及热门比特币基础设施的重大变更介绍。

## 新闻

- **<!--disclosure-of-past-lnd-vulnerabilities-->LND 过往漏洞的披露**：Niklas Gögge 在 Delving Bitcoin 论坛中[公布][gogge lndvuln]了两个他之前[尽责披露][topic responsible disclosures]了的漏洞，这些披露也促使了 LND 发布修复版本。使用 LND 0.15.0 以及更新版本的用户将不受影响；而使用更老版本 LND 的用户则应考虑立即升级，因为这些漏洞和其它已知的漏洞会影响更老的版本。简而言之，这两个现在公开的漏洞是：

    - 一种 DoS 漏洞，可能导致 LND 用尽内存然后宕机。如果 LND 停止运行，它就无法广播时间敏感型交易，这可能会导致资金损失。
    - 一种审查漏洞，允许一个攻击者阻止一个 LND 节点从网络中了解目标通道的更新。攻击者可以利用这点来误导受害者节点，使之为自己的支付选择特定的路径，从而给予攻击者更多的转发费用，以及关于受害者节点的支付的更多信息。

  Gögge 在两年以前初次披露给 LND 开发者，而且包含修复的 LND 版本已经放出长达 18 个月。Optech 尚未了解到有任何用户受到了这两个漏洞的影响。

- **<!--feedependent-timelocks-->依赖于手续费的时间锁**：John Law 在 Bitcoin-Dev 和 Lightning-Dev 邮件组中[提出][law fdt]了一种初步的软分叉提议，该提议将允许交易的[时间锁][topic timelocks]仅在区块的手续费率中值低于用户所选的水平时才解锁（过期）。举个例子，Alice 希望把钱放到跟 Bob 的一条支付通道中，但她也希望如果 Bob 不能响应，自己就能收到退款。所以她给了 Bob 一个选项，可以随时取走她支付给 Bob 的任意资金；但也给了她自己一个选项，可以在时间锁过期之后获得退款。随着时间锁过期的临近，Bob 尝试取走自己的资金，但当前的手续费率远远高于他和 Alice 在启用这个合约时候的估计。Bob 无法让领取自己的资金的交易得到确认，要么因为他不够钱来支付手续费，要么手续费率已经高到连创建申领资金的交易都不可能了。在当前的比特币协议中，Bob 无法行动，就会让 Alice 可以启动退款。而有了 Law 的提议，时间锁会阻止 Alice 启动退款，使之一直推迟到连续多个块的手续费率中值低于 Alice 和 Bob 在合约中的指定值的时候。这将保证 Bob 有机会让自己的交易在可接受的费率中得到确认。

  Law 指出，这解决了[闪电网络论文原本][original Lightning Network paper]所提到的一项关于 *强制过期洪水* 的长期困扰：可能有太多的通道同时关闭、因此区块空间不足以使他们全部能在时间锁过期之前得到确认，从而导致一部分用户损失资金。有了依赖于手续费的时间锁，关闭通道的用户可以直接提高手续费率到超过费率时间锁中指定的数值，而时间锁会一直推迟解锁，直到手续费率降低到足够低的数值、所有支付这个数值的交易都得到确认。当前的每条闪电通道只拥有两个用户，但在 “[通道工厂][topic channel factories]” 和 [joinpools][topic joinpools] 提议的构造中，将有超过两位用户分享同一个 UTXO，因此更容易受到强制过期洪水的影响，这个解决方案将显著增强它们的安全性。Law 还指出，至少在某一些构造中，拥有退款条件的一方（例如，前面例子中的 Alice）是在手续费上涨中最不利的一方，因为他们的资金要在合约中锁定，直至手续费降低。而依赖于手续费的时间锁将给予这一方额外的激励，以保持较低费率的方式行动，例如，不在短时间内关闭大量通道。

  依赖于手续费的时间锁的实现细节应该让它易于被合约参与者选择使用，并尽可能减少全节点为了验证它们而需存储的额外信息量。

  这个提议得到了少量讨论，回复者们建议在 [taproot][topic taproot] annex 中[存储][riard fdt]费率时间锁的参数、让区块[承诺][boris fdt]自己的费率中值以支持轻客户端，以及关于升级过的剪枝节点可以支持这个分叉的[细节][harding pruned]。Law 还跟[其他人][evo fdt]辩论了矿工接受协议外手续费 —— 用户以常规的交易手续费机制之外的方式支付，以确认交易（例如，直接给某个矿工支付）—— 的影响。

- **<!--cluster-fee-estimation-->族群手续费估计**：Abubakar Sadiq Ismail 在 Delving Bitcoin 中[分享][ismail cluster]了使用一些工具以及来自 “[族群交易池][topic cluster mempool]” 设计的启发来优化 Bitcoin Core 的手续费估计的想法。当前 Bitcoin Core 中的手续费估计算法跟踪一笔交易从进入本地交易池到获得确认之间的区块数量。在确认发生时，该交易的手续费率就用来更新一笔使用相近费率的交易能够多快获得确认的预测。

  在这个方法中，为了估计手续费率，Bitcoin Core 会忽略一些交易，同时另一些可能会被重复统计。这是 [CPFP][topic cpfp] —— 子交易（以及其它后代交易）激励矿工来确认其父交易（以及其它祖先交易）所带来的一个后果。子交易自身可能会有高手续费率，但当它们的手续费和其祖先的手续费被一起考虑时，整体手续费率可能会显著较低，导致它们需要花比预期更长的时间来确认。为了防止造成对合理手续费的过高估计，Bitcoin Core 不会使用任何在进入本地交易池时有未确认父交易的交易的手续费率更新估计。相应地，一笔父交易可能自身手续费率低，但同时也考虑其后代的手续费时，整体手续费率可能会显著较高，导致它们的确认速度快于预期。Bitcoin Core 的手续费估计不能对冲这种影响。

  族群交易池的设计将把相关的交易放在一起，并支持将它们切分成一起挖出时有利可图的小群。Ismail 建议跟踪小群的费率，而不是单笔交易的费率（虽然某个群可能只有一笔交易）。如果一个小群得到确认，手续费估计就使用这个小群的费率（而非单笔交易的费率）来更新。

  这个提议收到了许多回复，开发者们讨论了更新算法需要考虑的细节。

- **<!--how-to-specify-unspendable-keys-in-descriptors-->如何在描述符中指明无法花费的密钥**：Salvatore Ingala 在 Delving Bitcoin 中开启了一项[讨论][ingala undesc]，关于如何允许[描述符][topic descriptors]，尤其是 [taproot][topic taproot] 输出的描述符，指明某个公钥是未知私钥的（因此无法用它来花费的）。一个重要的背景是，有时候你会希望发给某个 taproot 输出的资金只能被脚本路径花费。为此，密钥路径必须设置成一个无法花费的公钥。

  Ingala 介绍了在描述符中使用不可花费的密钥所面临的几个挑战，以及多个具有不同取舍的解决方案提议。Pieter Wuille 总结了几段他近期关于描述符的私人讨论，包括一个关于不可花费的密钥的[具体][wuille undesc2]想法。Josie Baker 询问了为什么不可花费密钥不能是一种常量值（例如 BIP341 中的 NUMS 点）的详情；如果是常量值，那么每个人都可以立即知道那是一个不可花费的公钥，对一些协议（比如 “[静默支付][topic silent payments]”）来说，可能会有一些好处。Ingla 回复 Baker 道，“这是指纹的一种形式。如果你 想要/需要，你总是可以揭晓这个信息，但如果标准可以不强迫你这样做，那是一件好事。”Wuille 进一步回复了一个用于生成证明的算法。截至本刊撰写之时，在该讨论的最后一个跟帖中，Ingala 指出，与不可花费的密钥相关的指定策略的部分工作，可以在描述符和 [BIP388][] 钱包策略之间分工。

- **<!--v3-transaction-pinning-costs-->V3 交易的钉死攻击成本**：Peter Todd 在 Bitcoin-Dev 邮件组中[提出][todd v3]了一项对提议中的 “[v3 交易转发][topic v3 transaction relay]” 策略的分析，该提议本身旨在解决合约式协议（例如闪电通道）中的 “[交易钉死][topic transaction pinning]” 攻击。举个例子，Bob 和 Mallory 可能共享一个闪电通道。Bob 希望关闭通道，所以他广播自己的最新承诺交易，加上一笔较小的子交易，以通过 [CPFP][topic cpfp] 为承诺交易贡献手续费，两笔交易的总体积是 500 vbyte。Mallory 在 P2P 网络中侦测到 Bob 的交易之后，就赶在这笔交易到达矿工之前，先发布自己的承诺交易，加上一笔非常大的子交易，两笔交易的总体积高达 10 0000 vbyte，而整体手续费率低于 Bob 的交易。在 Bitcoin Core 当前的默认转发策略和当前的 “[交易包转发][topic package relay]” 提议下，根据 [BIP125][] 规则 #3，Bob 可以尝试[替代][topic rbf] Mallory 的两笔交易。如果 Bob 一开始使用的手续费率是 10 聪/vbyte（总计是 5000 聪），而 Mallory 的竞争交易的费率是 5 聪/vbyte（总计是 50 0000 聪），Bob 将需要在他的替换交易中支付 100 倍以上的手续费（相比于他本来想要支付的数额）。如果这超过了 Bob 愿意支付的数额，Mallory 的体积较大但费率较低的交易可能一直不会得到确认，直到一个关键的时间锁过期，然后 Mallory 就可以光明正大地偷盗属于 Bob 的资金。

  在 v3 交易转发提议中，规则允许一笔交易自选适用 v3 策略，最多仅有一笔未确认的子交易会被转发、存储在交易池中并被同意遵守 v3 策略的节点挖出。如 Peter Todd 在他的文章中指出的，v3 交易转发提议仍将允许 Mallory 将 Bob 的成本提高至其原本愿意支付的数值的 1.5 倍。回复者大多同意，在对手方有恶意的时候，存在 Bob 可能需要支付更多的风险，但他们也指出，这个倍数比起 Bob 在当前转发规则下可能要多付的 100 倍（甚至更多）要好得多了。

  人们还在对话中讨论了 v3 转发规则、“[一次性锚点][topic ephemeral anchors]” 的规范，以及如何将它们跟当前可用的 [CPFP carve-out][topic cpfp carve out] 及 “[锚点输出][topic anchor outputs]” 相比较。

- **<!--descriptors-in-psbt-draft-bip-->关于 PSBT 中的描述符的 BIP 草案**：SeedHammer 团队在 Bitcoin-Dev 邮件组中 [公开][seedhammer descpsbt]了一份 BIP 草案，提议在 [PSBTs][topic psbt] 中包含[描述符][topic descriptors]。主要的目标用途似乎是将描述符封装成 PSBT 格式，以在钱包间传输，因为他们提议的标准允许 PSBT 在封装了一个描述符的时候省略交易数据。这可能会方便一个软件钱包将输出的信息传输给一个硬件签名器，或者在多签名联盟中让多个钱包可以传输他们想要创建的输出的信息。截至本刊撰写之时，这个 BIP 草案还没有在邮件组中收到任何回复，虽然在 11 月发布的关于其前身的[帖子][seedhammer descpsbt2]收到了[反馈][black descpsbt]。

- **<!--verification-of-arbitrary-programs-using-proposed-opcode-from-matt-->使用来自 MATT 的提议操作码，验证任意程序**：Johan Torås Halseth 在 Delving Bitcoin 论坛中[公开][halseth ccv]了 “elftrace”，这是一个概念验证程序，它可以使用来自 [MATT][] 软分叉提议的  `OP_CHECKCONTRACTVERIFY` 操作码，允许合约协议中的一方在某个任意程序成功执行时领取资金。它在概念上跟 BitVM（见[周报 #273][news273 bitvm]）相似，但其比特币实现更为简单，因为使用了一个专为程序执行验证而设计的操作码。Elftrace 可以解决使用 Linux 的 [ELF][] 格式、为 RISC-V 架构编译的程序，几乎任何程序员都能轻易创建这样的程序，所以 elftrace 非常通用。截至本刊撰写之时，该帖还没有收到任何回复。

- **<!--pool-exit-payment-batching-with-delegation-using-fraud-proofs-->使用欺诈证明和委托，实现资金池退出支付的批量处理**：Salvatore Ingala 在 Delving Bitcoin 论坛中[提出][ingala exit]了一项提议，可以优化多名用户共享一个 UTXO 的多方合约（例如 [joinpool][topic joinpools] 和[通道工厂][topic channel factories]）时部分用户同时希望退出合约、而其他用户没有响应（无论有意还是无意）的情形。构造这类协议的标准方法是给予每一位用户一笔链下交易，他们可以在想要退出时广播到网络中。这意味着，即使在最好的情况下，如果 5 名用户想要退出，也需要每个人都广播一笔单独的交易，而这些交易将至少有一个输入和一个输出 —— 总共是 5 个输入和 5 个输出。Ingala 提出这些用户可以一起使用一笔交易来退出，那就只有 1 个输入和 5 个输出，从而他们可以获得标准的[支付批量处理][topic payment batching]在交易体积上的节约，节约大概 50%。

  在复杂且拥有大量用户的多方合约中，链上交易的节约可以显著大于 50%。更好的是，如果这 5 名活跃的用户只想把资金转移到一个新的、只有他们几个人的共享 UTXO 中，那么交易就只需要 1 个输入和 1 个输出，节约大概 80% 的交易体积（假定 5 名用户退出）；如果是 100 名用户退出，那节约高达 99%。这种巨大的节约，对于大量用户从一个合约转移资金到另一个合约的场景可能是非常关键的，因为有时候手续费会高涨，而许多用户在一个合约中只有相对较少的余额。举个例子，100 名用户，每人只拥有 1 0000 聪的余额（在撰写本刊之时，大概是 4 美元）；如果他们每人都需要支付手续费以退出合约、进入一个新合约，那么即使花费交易的体积小到 100 vbyte（已经不太可能了），100 聪/vbyte 的费率也会耗尽他们每个人的余额。但如果他们可以一起用 200 vbyte 的交易移动总计 100 0000 聪，即使手续费率是 100 聪/vbyte，每个用户也只需要支付 200 聪（只占他们余额的 2%）。

  这样的支付批量处理是通过让多方合约协议中的其中一个参与者构造共享资金的一笔支出到由其它活跃参与者同意的输出，来实现的。合约允许这么做 —— 前提是这个构造交易的一方发行一个债券，如果有人能证明他们错误地花费了共享资金，那他们的债券就会被没收；债券的金额应该远大于他们能够从不正当支出中获得的利益。如果没人在给定时间内生成欺诈证据、证明这个构造交易的参与者行事不当，那么债券会退回给这个构造方。Ingala 大致描述了这个特性如何通过 [OP_CAT][]、`OP_CHECKCONTRACTVERIFY` 以及来自 [MATT][] 软分叉提议的数量内省添加到多方合约协议中，同时他指出，如果还有 [OP_CSFS][topic op_checksigfromstack]、[tapscript][topic tapscript] 中还有 64 位的代数操作符，那会更加容易。

  截至本刊撰写之时，这个想法收到了少量讨论。

- **<!--new-coin-selection-strategies-->新的选币策略**：Mark Erhardt 在 Delving Bitcoin 中[发帖][erhardt coin]讨论了 Bitcoin Core 的[钱币选择][topic coin selection]策略可能面临的罕见情形，并为解决这些罕见情形提出了两种新的策略：在高费率时期尝试减少在钱包交易中使用的输入的数量。他也总结了 Bitcoin Core 的所有策略的好处和缺点，包括已经实现的以及他所提议的，并提供了他使用不同算法所运行的模拟的多个结果。对 Bitcoin Core 来说，最终的目标是泛用地选出一组输入，可以使得长期来看手续费占 UTXO 价值的占比最小，同时避免在高费率时期创建不必要的大体积交易。

## 新版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Core Lightning 23.11.2][] 是一个 bug 修复版本，帮助确保 LND 节点可以给 Core Lightning 用户所创建的发票支付。见下文的 “重大变更” 部分关于 Core Lightning #6957 的描述，以了解更多细节。

- [Libsecp256k1 0.4.1][] 是一个小版本，“稍微提高了 ECDH 操作的速度，并大大加强了许多库函数在使用 x86_64 默认配置时候的性能。”

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo] 和 [Bitcoin Inquisition][bitcoin inquisition repo]。*

- [Bitcoin Core #28349][] 开始要求使用 C++20 兼容的编译器，允许未来的 PR 开始使用 C++20 的特性。如该 PR 描述所指出的，“C++20 允许编写更安全的代码，因为它允许在编译时强制执行更多东西。”

- [Core Lightning #6957][] 修复了一个意外的不兼容问题，该问题导致 LND 用户无法在默认设定下给 Core Lightning 所生成的发票支付。问题的根源是  `min_final_cltv_expiry`，该值指定了一个收款者可以申领一笔支付的最大窗口（以区块数量度量）。[BOLT2][] 建议将这个值默认设为 18，但 LND 使用的值是 9，低于 Core Lightning 默认会接受的值。Core Lighting 现在通过在其发票中包含一个字段，请求将数值设为 18，解决了这个问题。

- [Core Lightning #6869][] 更新了 `listchannels` RPC，不再列出[未公开宣布的通道][topic unannounced channels]。需要这些信息的用户可以使用 `listpeerchannels` RPC。

- [Eclair #2796][] 更新了它对 [logback-classic][] 的依赖，从而修复了一个漏洞。Eclair 并不使用直接受此漏洞影响的特性，但这个更新保证了任何插件或者其它相关的软件可以使用这个特性而不会遭遇漏洞。

- [Eclair #2787][] 将其对从 BitcoinHeaders.net 检索区块头的支持更新到最新的 API。通过 DNS 检索区块头可以帮助节点抵御[日蚀攻击][topic eclipse attacks]。见[周报 #123][news123 headers]以了解 Eclair 最初支持基于 DNS 的区块头检索的描述。其它使用 BitcoinHeaders.net 的软件可能需要尽快升级到这个新的 API。

- [LDK #2781][] 和 [#2688][ldk #2688] 更新对发送和收取 “[盲化支付][topic rv routing]” 的之处，尤其是多跳的盲化路径，同时遵守了[要约][topic offers] 协议的要求：总是包含至少一个盲化的跳。

- [LDK #2723][] 开始支持使用 *直接连接* 发送[洋葱消息][topic onion messages]。在一个发送者无法找出触达接收者的路径、但知道接收者的网络地址（例如，因为接收者是一个公开节点，曾经广播过他们的 IP 地址）的时候，发送者可以跟接收者打开一个直接的对等连接、发送消息，然后选择性地关闭连接。这允许洋葱消息在即使网络中只有少数节点支持它的时候（也就是现在）也能工作良好。

- [BIPs #1504][] 更新了 BIP2，以允许使用 Markdown 语言编写任何 BIP。在此之前，所有的 BIP 都必须使用 Medawiki 语言来编写。

{% include references.md %}
{% include linkers/issues.md v=2 issues="28349,6957,6869,2796,2787,2781,2723,1504,2688" %}
[gogge lndvuln]: https://delvingbitcoin.org/t/denial-of-service-bugs-in-lnds-channel-update-gossip-handling/314/1
[law fdt]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-December/004254.html
[original lightning network paper]: https://lightning.network/lightning-network-paper.pdf
[riard fdt]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-December/004256.html
[boris fdt]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-December/004256.html
[harding pruned]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-December/004256.html
[evo fdt]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-December/004260.html
[ismail cluster]: https://delvingbitcoin.org/t/package-aware-fee-estimator-post-cluster-mempool/312/1
[ingala undesc]: https://delvingbitcoin.org/t/unspendable-keys-in-descriptors/304/1
[wuille undesc]: https://delvingbitcoin.org/t/unspendable-keys-in-descriptors/304/2
[wuille undesc2]: https://gist.github.com/sipa/06c5c844df155d4e5044c2c8cac9c05e#unspendable-keys
[todd v3]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-December/022211.html
[seedhammer descpsbt]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-December/022200.html
[seedhammer descpsbt2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-November/022184.html
[black descpsbt]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-November/022186.html
[halseth ccv]: https://delvingbitcoin.org/t/verification-of-risc-v-execution-using-op-ccv/313
[elftrace]: https://github.com/halseth/elftrace
[matt]: /zh/newsletters/2022/11/16/#general-smart-contracts-in-bitcoin-via-covenants
[news273 bitvm]: /zh/newsletters/2023/10/18/#payments-contingent-on-arbitrary-computation
[elf]: https://en.m.wikipedia.org/wiki/Executable_and_Linkable_Format
[ingala exit]: https://delvingbitcoin.org/t/aggregate-delegated-exit-for-l2-pools/297
[erhardt coin]: https://delvingbitcoin.org/t/gutterguard-and-coingrinder-simulation-results/279/1
[logback-classic]: https://logback.qos.ch/
[news123 headers]: /en/newsletters/2020/11/11/#eclair-1545
[bip388]: https://github.com/bitcoin/bips/pull/1389
[core lightning 23.11.2]: https://github.com/ElementsProject/lightning/releases/tag/v23.11.2
[libsecp256k1 0.4.1]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.4.1
