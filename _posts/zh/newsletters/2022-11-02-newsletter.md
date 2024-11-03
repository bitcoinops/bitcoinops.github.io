---
title: 'Bitcoin Optech Newsletter #224'
permalink: /zh/newsletters/2022/11/02/
name: 2022-11-02-newsletter-zh
slug: 2022-11-02-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报描述了关于选择性允许节点启用完全 RBF 的继续讨论，转发对 BIP324 第 2 版加密传输协议的设计元素的反馈请求，总结了将 LN 故障和延迟可靠地归因于特定节点的提案，并给出了关于为现代闪电网络 HTLC 使用锚点输出的替代方案的讨论的链接。此外还包括我们的常规部分，其中包含新软件版本和候选版本的公告——包括 LND 的安全关键更新——以及对流行的比特币基础设施软件的重大变化的描述。

## 新闻

- **<!--mempool-consistency-->交易池的一致性：**Anthony Towns 在 Bitcoin-Dev 邮件列表上发起了一个[讨论][towns consistency]，主要关于更容易配置 Bitcoin Core 的交易中继和交易池接受策略的后果。实现方式例如通过添加 `mempoolfullrbf` Bitcoin Core 开发分支的选项（请参阅周报 [#205][news205 rbf]、[#208][news208 rbf]、[#222][news222 rbf] 和 [#223][news223 rbf]）。他声称“这与 core 过去所做的不同，因为之前我们试图确保新政策对每个人都有利（或尽可能都有利），然后在实现后立即启用它。添加的任何选项以不显着[影响] tx 传播的方式控制资源使用，以允许人们在新行为有争议时恢复到旧行为（例如 -mempoolreplacement=0 选项从 0.12 到 0.18)，并使其更容易测试/调试实现。当我们没有足够的信心来默认打开时而给人们一个新的中继行为让他们可以自由选择，与我所看到的 core 曾采用的方法并不匹配。”

  之后，Towns 考虑这是否是一个新的发展方向：“完全 [RBF][topic RBF] 多年来一直存在争议，但受到开发人员的广泛喜爱 [...] 所以也许这只是一个特例而不是先例，尽管所有关于用户有选择的讨论现在都在进行，但当人们提出其他默认为否的选项时，它们被合并的阻力会大大增加。”但是，在这是一个新方向的假设下他评估了该决定的一些潜在后果：

  - *<!--it-should-be-easier-to-get-default-disabled-alternative-relay-options-merged-->合并默认禁用的替代中继选项应该更容易：*
    如果认为为用户提供更多选项更好，则可以配置中继策略的许多方面。例如，Bitcoin Knots 提供了一个脚本公钥重用（`spkreuse`）选项，用于配置节点拒绝中继任何[重复使用一个地址][topic output linking]的交易。

  - *<!--more-permissive-policies-require-widespread-acceptance-or-better-peering-->更宽松的策略需要广泛接受或更好的对等：*
    Bitcoin Core 的节点在默认情况下会与 8 个对方节点通过出站连接来中继交易，因此需要至少 30% 的网络支持更宽松的策略，节点才有 95% 的机会找到至少一个随机选择的支持相同策略的对方节点。支持策略的节点越少，节点找到支持该策略的对方节点的可能性就越小。

  - *<!--better-peering-involves-tradeoffs-->更好的节点互连涉及到权衡：* 比特币节点可以使用 P2P `addr`、[`addrv2`][topic addr v2] 和 `version` 消息的服务字段来公告其能力，允许具有共同利益的节点找到彼此并形成子网络（称为 *优先互连*）。替代方案是，具有共同利益的全节点运营商可以使用其他软件形成独立的中继网络（例如 LN 节点之间的网络）。即使只有少数节点实施策略，这也可以使中继有效，但实施不常见策略的节点更容易被识别和审查。它还要求矿工加入这些子网络和替代网络，从而提高了挖矿的复杂性和成本。这增加了交易选择的集中化压力，也让审查交易更加容易。

    此外，实施与某些对方节点不同的策略的节点将无法充分利用[致密区块中继][topic compact block relay]和 [erlay][topic erlay] 等技术来最小化延迟和带宽，尽管此时两个节点已有一些相同信息。

  Towns 的帖子收到了许多富有洞见的回应。在撰写本文时，讨论仍在进行中。我们将在下周的周报中提供更新。

- **BIP324 消息标识符：** Pieter Wuille 在 Bitcoin-Dev 邮件列表中[发帖][wuille bip324]来回应[第 2 版本 P2P 加密传输协议][topic v2 p2p transport]（v2 传输）的 [BIP324][bips #1378] 草案规范的更新。为了节省带宽，v2 传输允许将现有协议 12 字节的消息名替换为短至 1 字节的标识符。例如，填充为 12 个字节的 `version` 消息名可以替换为 0x00。然而，较短的消息名会增加在以后向网络添加消息的不同提议之间发生冲突的风险。 Wuille 描述了解决此问题的四种不同方法之间的权衡，并请求社区就该话题发表意见。

- **<!--ln-routing-failure-attribution-->闪电网络路由失败归因：** 闪电网络支付尝试可能最终因多种原因而失败，从最终接收方拒绝释放支付原像到某个路由节点暂时离线。关于哪些节点导致支付失败的信息对支付者在短期内避免使用这些节点进行支付非常有用，但今天的闪电网络协议没有提供路由节点间通信并将该信息传达给支付者的认证方法。

  几年前，Joost Jager 提出了一个解决方案（参见[周报 #51][news51 attrib]），并在当前有了[修改][jager attrib]，包括改进及其他额外细节。该机制将确保识别支付失败的节点对（或早前的失败消息被审查或混淆的节点之一）。 Jager 提议的主要缺点是，如果闪电网络的其他属性保持不变，它将显著增加闪电网络失败交易的洋葱消息的大小（尽管如果闪电网络跳数的最大值降低，则失败交易的洋葱消息大小不需要变那么大）。

  一个替代办法是，Rusty Russell [建议][russell attrib]支付者可以使用类似于[自发支付][topic spontaneous payments]的机制，即使最终支付失败，每个路由节点也会获得一笔报酬。然后，支付者可以通过比较它发送多少聪与收到多少聪来确定在哪一跳支付失败。

- **<!--anchor-outputs-workaround-->锚点输出的变通方法：**Bastien Teinturier 在 Lightning-Dev 邮件列表中[发表了][teinturier fees]一个使用[锚点输出][topic anchor outputs]和每个有不同费率的 [HTLC][topic htlc] 的[提议][bolts #1036]。锚点输出是随着 [CPFP 剥离][topic cpfp carve out]规则的发展而引入的，该规则通过 [CPFP][topic cpfp] 机制，允许闪电网络的两方合约协议中以一种不会[钉死][topic transaction pinning]的方式添加手续费到一个交易里。然而，Teinturier [提示][bolts #845]使用 CPFP 要求每个闪电网络节点保持一个随时可花费的非闪电网络的 UTXO 池。相比之下，预签名具有不同手续费的多个版本的 HTLC，可以让这些手续费直接从 HTLC 的价值中支付——这样就不需要额外管理 UTXO，除非预签名的手续费率都不够高。

  他正在寻求其他闪电网络开发人员的支持，以实现提供多个费率的 HTLC 的想法。撰写本文时，所有的讨论都发生在 Teinturier 的 [PR][bolts #1036] 上。

## 新版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [LND 0.15.4-beta][] 和 [0.14.4-beta][lnd 0.14.4-beta] 是**安全关键**版本，其中包含针对处理最近区块问题的修复。所有用户都应该升级。

- [Bitcoin Core 24.0 RC2][] 是网络中使用最广泛的全节点实现的下一版本的候选版本。[测试指南][bcc testing]已可用。

  **<!--warning-->警告：**这一版软件包含了 `mempoolfullrbf` 配置选项。一些协议和应用程序开发人员认为该配置选项可能会导致商户服务出现问题，如周报 [#222][news222 rbf] 和 [#223][news223 rbf] 中所述。Optech 建议任何可能受影响的服务都评估一下这份请求意见稿，并参与公开讨论。

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo] 和 [Lightning BOLTs][bolts repo]。*

- [Bitcoin Core #23927][] 将剪枝节点上的 `getblockfrompeer` 限制为低于节点当前同步进度的高度。这可以防止因检索未来的区块而导致节点的区块文件不适合修剪的问题。

  Bitcoin Core 以接收到的顺序将区块存储在大约 130 MB 的文件中。修剪将丢弃整个区块文件，但不会丢弃任何包含未被节点同步处理的区块的文件。较小的数据限额加上反复调用 `getblockfrompeer` RPC 可能会导致多个区块文件不适合修剪，并导致修剪后的节点超出其数据限额。

- [Bitcoin Core #25957][] 通过使用[区块过滤索引][topic compact block filters]（如果启用）来跳过不花费或创建与钱包相关的 UTXO 的区块，提高了描述符钱包重新扫描的性能。

- [Bitcoin Core #23578][] 使用 [HWI][topic hwi] 和最近合并的对 [BIP371][] 的支持（参见[周报 #207][news207 bc22558]）以提供对 [taproot][topic taproot] keypath 花费的外部签名支持。

- [Core Lightning #5646][] 更新了[要约][topic offers]的实验性实现，移除了 [x-only 公钥][news72 xonly]（而不是使用包含一个额外的字节的[压缩公钥][compressed pubkeys]）。它还实现了另一个实验性协议[盲化支付][blinded payments]的转发。该 PR 的描述警告说它“不包含盲化支付凭据的生成和实际支付”。

- [LND #6517][] 添加了一个新的 RPC 和事件，允许用户监控收款（[HTLC][topic htlc]）何时被更新的承诺交易完全锁定，以反映出新的通道余额分布。

- [LND #7001][] 向转发历史记录 RPC（`fwdinghistory`）添加了新字段，以标识出哪个通道的合作方将付款（HTLC）转发给我们以及我们将付款转发给哪个合作方。

- [LND #6831][] 更新 HTLC 拦截器实现（参见[周报 #104][news104 intercept]）。如果连接了拦截器的客户端未在合理时间内完成处理，将自动拒绝收款（HTLC）。如果 HTLC 在临近到期前未被接受或拒绝，则通道合作方将需要强制关闭通道以保护其资金。这个合并的 PR 在到期前自动拒绝确保通道保持打开状态。支付者总是可以尝试再次发送付款。

<!-- The commit below appears to be a direct push to LND's master branch -->
- [LND 609cc8b][] 添加了[安全策略][lnd secpol]，包括报告安全漏洞的说明。

- [Rust Bitcoin #957][] 添加了一个用于签名 [PSBTs][topic psbt] 的 API。它暂不支持签名 [taproot][topic taproot] 花费。

- [BDK #779][] 增加了对 ECDSA 签名的[低 r 值研磨][topic low-r grinding]（low-r grinding）的支持，这会使得大约半数的签名减少一个字节的大小。

{% include references.md %}
{% include linkers/issues.md v=2 issues="23927,25957,5646,6517,7001,6831,957,779,1036,845,1378,23578,22558" %}
[bitcoin core 24.0 rc2]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/24.0-Release-Candidate-Testing-Guide
[lnd 609cc8b]: https://github.com/LightningNetwork/lnd/commit/609cc8b883c7e6186e447e8d7e6349688d78d4fd
[lnd secpol]: https://github.com/lightningnetwork/lnd/security/policy
[towns consistency]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021116.html
[news205 rbf]: /zh/newsletters/2022/06/22/#full-replace-by-fee
[news208 rbf]: /zh/newsletters/2022/07/13/#bitcoin-core-25353
[news222 rbf]: /zh/newsletters/2022/10/19/#transaction-replacement-option
[news223 rbf]: /zh/newsletters/2022/10/26/#continued-discussion-about-full-rbf-rbf
[wuille bip324]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021115.html
[news72 xonly]: /en/newsletters/2019/11/13/#x-only-pubkeys
[compressed pubkeys]: https://developer.bitcoin.org/devguide/wallets.html#public-key-formats
[blinded payments]: /en/topics/rendez-vous-routing/
[news104 intercept]: /en/newsletters/2020/07/01/#lnd-4018
[news51 attrib]: /en/newsletters/2019/06/19/#authenticating-messages-about-ln-delays
[jager attrib]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-October/003723.html
[russell attrib]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-October/003727.html
[teinturier fees]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-October/003729.html
[news222 rbf]: /zh/newsletters/2022/10/19/#transaction-replacement-option
[news223 rbf]: /zh/newsletters/2022/10/26/#continued-discussion-about-full-rbf-rbf
[lnd 0.15.4-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.4-beta
[lnd 0.14.4-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.14.5-beta
[news207 bc22558]: /zh/newsletters/2022/07/06/#bitcoin-core-22558
