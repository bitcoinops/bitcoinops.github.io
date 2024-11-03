---
title: 'Bitcoin Optech Newsletter #95'
permalink: /zh/newsletters/2020/04/29/
name: 2020-04-29-newsletter-zh
slug: 2020-04-29-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了一个影响闪电网络（LN）支付安全的问题披露，并宣布了一个新的预签名保险库提案。此外，还包括我们常规部分的 Bitcoin Stack Exchange 精选问答、发布与候选发布的公告，以及热门比特币基础设施项目中的值得注意的代码更改描述。

## 行动项

- **<!--review-the-disclosure-of-a-potential-ln-issue-->****审查潜在 LN 问题的披露**：如下面的*新闻*部分所述，本周的一项公开披露描述了一种从 LN 节点中窃取资金的新方法。该问题与现有的、已知的费用管理问题部分重叠。我们目前所知这一问题尚未被利用，因为过去两年中几乎所有的链上交易即便仅支付默认的最低中继费用率，也能相对快速地确认。如果费用率在一段时间内显著上升，这些问题将变得更为严重。有关详细信息，请参阅我们在*新闻*部分中的解释，并在担心此问题可能影响您的通道时，联系您的 LN 软件供应商。

## 新闻

- **<!--new-attack-against-ln-payment-atomicity-->****针对 LN 支付原子性的新攻击**：Matt Corallo 在 [Lightning-Dev][corallo thread ld] 和 [Bitcoin-Dev][corallo thread bd] 邮件列表中启动了一个线程，披露了在讨论允许 LN 承诺交易通过[锚定输出][topic anchor outputs]使用 [CPFP][topic cpfp] 费用提升时发现的攻击。[BOLTs #688] 中对此进行了讨论。我们将通过一个扩展示例来描述此次攻击：Alice 使用 LN 通道向 Bob 发送了一个哈希时间锁定合约（HTLC），该合约旨在以下两种方式之一结算：

  - 如果 Bob 披露了 `<hash>` 的原像，他可以花费 Alice 的 1 BTC
  - 否则，80 个区块后，Alice 可以将这 1 BTC 退回给自己

  Alice 还告知 Bob，她的支付目的是支付给 Mallory，因此 Bob 使用他与 Mallory 的通道向她发送了一个相关的 HTLC：

  - 如果 Mallory 披露了 `<hash>` 的原像，她可以花费 Bob 的 1 BTC（在此示例中忽略了路由费用）
  - 否则，40 个区块后，Bob 可以将这 1 BTC 退回给自己

  尽管上述 HTLC 通常是离线创建并结算的，每个参与者也都有一个*承诺交易*，他们可以用它将 HTLC 承诺上链。一个单独的链上*结算交易*可以满足 HTLC 的任一条件。

  例如，Mallory 可以发布承诺交易，然后创建一个结算交易，提供原像并索取 Bob 的 1 BTC。如果 Bob 在 Alice-Bob 合约的 80 个区块超时之前看到 Mallory 的原像结算交易，他可以提取该原像并用它索取 Alice 的 1 BTC（无论是链上还是链下）。或者，如果 Bob 没有看到原像结算交易，他可以在 40 个区块后创建自己的退款结算交易，收回他的 1 BTC，同时也可以启动 Alice 的 1 BTC 的退款（同样，无论是链上还是链下）。在任何情况下，这都使所有人遵守其合约的意图。

  不幸的是，据本周披露，Mallory 似乎有办法通过阻止 Bob 了解原像并阻止他发送退款结算交易来规避这一过程。

  - **<!--preimage-denial-->****原像拒绝**：Mallory 可以通过给她的原像结算交易设置一个较低的费用率来阻止 Bob 获悉该原像，使其无法快速确认。如果 Bob 仅在区块链中查找原像，他将不会在未确认的情况下看到 Mallory 的交易。

  - **<!--refund-denial-->****退款拒绝**：Mallory 先前广播的原像结算交易可以阻止矿工和比特币中继节点接受 Bob 后来广播的退款结算交易，因为这两个交易*冲突*，即它们都花费了同一个输入（在承诺交易中创建的 UTXO）。理论上，Bob 的退款结算交易将支付更高的费用率，从而可以通过 [RBF][topic rbf] 替换 Mallory 的原像结算交易，但实际上，Mallory 可以使用各种[交易固定][topic transaction pinning]技术来阻止这种替换。

  由于 Bob 被阻止获知原像结算交易或确认他的退款结算交易，Alice 可以在 Alice-Bob HTLC 的 80 个区块超时到期后收回她提供给 Bob 的 1 BTC。而当 Mallory 的原像结算交易最终确认时，Mallory 可以获得 Bob 提供的 1 BTC，这让 Bob 损失了 1 BTC。

  该线程中考虑了几种解决方案，但都存在问题或涉及重大权衡：

  - **<!--require-a-mempool-->****要求内存池**：Bob 可以使用比特币全节点来监控比特币 P2P 中继网络并获悉 Mallory 的结算交易。一些 LN 节点如 Eclair 已经这样做了，并且这看起来是一个[合理的额外负担][osuntokun reasonable]，因为问题仅直接影响路由节点（如 Bob）。仅为自己发送或接收支付的节点只会间接受到影响，[^non-routing-issues]因此日常用户仍然可以在移动设备上运行轻量级 LN 客户端。不幸的是，即使在一切正常的情况下，不同全节点接收到的交易也可能不同。更糟糕的是，攻击者如 Mallory 可以使用技术[向不同的对等方发送不同的冲突交易][corallo mempool not guaranteed]（例如，将固定的原像结算交易发送给已知矿工，但将另一笔不涉及结算的交易发送给非矿工的中继节点）。

  - **<!--beg-or-pay-for-preimages-->****请求或支付原像**：中继网络可以向交易提交者如 Bob 提供[关于冲突的相关信息][harding reject]，这样他们就不需要自己持续监控中继。这个方案仍然面临像 Mallory 这样的恶意行为者使用[定向中继][corallo targeted relay]向矿工和非矿工发送不同交易的问题。此外，Bob 可能可以[支付][harding pay]矿工或其他第三方节点以获得所需的原像，尽管这需要一些人运行额外的软件，并且[在某些闪电网络协议的提议升级部署后可能并不那么容易][zmn ptlcs]。

  - **<!--settlement-transaction-anchor-outputs-->****结算交易锚定输出**：链上结算交易可以重新设计为将其价值支付给[锚定输出][topic anchor outputs]，以便通过 [CPFP 分离][topic cpfp carve out]进行 [CPFP 费用提升][topic cpfp]。这将要求这些交易更大（增加链上费用）且预签名（减少灵活性）。这仅直接影响在支付未完成时单方面关闭的通道，而这种情况本身就会显著增加链上成本，因此用户会尽量避免这一情况。然而，提高链上执行成本也提高了无需信任地通过 LN 发送支付的最低实际金额。尽管存在这些挑战，截至本文撰写时，这仍然是最受欢迎的解决方案。

  Corallo 将此标记为一个严重问题，但指出其后果类似于另一个已知的问题，即 LN 链上交易的费用管理问题。现有问题（在 [Newsletter #78][news78 anchor outputs] 中描述）是承诺交易的费用率是在签署交易时设定的，这可能是交易广播到比特币中继节点之前的几天或几周。如果自交易上次签署以来，下一几个区块包含交易所需的最低费用率显著增加，那么承诺交易可能在 Alice 能够从 Bob 那里收回资金之前无法确认，从而再次为 Bob 创造了既支付给 Mallory 又退款给 Alice 的机会。（开发人员正在修复此问题时发现了新问题。[^package-relay]）

  到目前为止，我们尚未意识到 LN 中由于链上费用管理问题造成的实际损失，这可能部分归因于过去两年中几乎没有持续足够长时间的大费用峰值，足以显著延迟先前可接受费用率的交易确认。好运不会无限期地持续下去，因此这个新问题为 LN 开发人员提供了一个额外的理由来优先实施改进的链上费用管理。在此期间，担心攻击的节点运营者可能希望增加其 [cltv_expiry_delta][] 以便为原像结算交易提供更多的确认时间。当前流行 LN 节点的默认值为：C-Lightning 为 [14][cl ced]，LND 为 [40][lnd ced]，Rust-Lightning 为 [72][rl ced]，Eclair 为 [144][eclair ced]。请注意，增加该值会使您的通道对支付者的吸引力下降，因为更高的值会增加等待支付结算的正常最坏情况时间。

- **<!--multiparty-vault-architecture-->****多方保险库架构**：Antoine “Darosior” Poinsot [宣布][darosior revault]了一个基于与[上周 Newsletter][news94 bishop vault] 提到的相同预签名交易概念的保险库[约束][topic covenants]原型的演示实现。这个新实现被命名为 *Revault*，重点是使用多重签名安全性存储多个方共享的资金。该协议允许部分参与方通过确认信标交易来启动提款过程；如果保险库的其他参与方对提款有异议，他们有机会广播第二笔交易，将资金退回保险库中的紧急地址。如果在规定时间内没有异议，则另一笔交易可以完成资金的提款。Poinsot 正在征求对该提案的反馈。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者们寻找问题答案的首选之地，或者在有空的时候帮助好奇或困惑的用户。在这个月度特色部分中，我们重点介绍自上次更新以来发布的部分高票问题与回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{%
endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--what-are-the-potential-attacks-against-ecdsa-that-would-be-possible-if-we-used-raw-public-keys-as-addresses-->**[如果我们将原始公钥用作地址，可能会对 ECDSA 发起哪些潜在攻击？]({{bse}}95123)
  Pieter Wuille 总结了使用公钥哈希而非公钥作为地址的理由，即这可以减缓具有量子计算能力的攻击者。他接着列举了为什么这一假设的理由可能被夸大，并可能给人一种虚假的安全感。

- **<!--what-is-meant-by-default-ancestor-limit-in-child-pays-for-parent-->**[在子支付父（CPFP）中，DEFAULT_ANCESTOR_LIMIT 是什么意思？]({{bse}}95473)
  用户 anu 提问关于 Bitcoin Core 中的 [DEFAULT_ANCESTOR_LIMIT][bitcoin core default ancestor limit] 与 [子支付父（CPFP）][topic cpfp] 费用提升技术的关系。Murch 指出这个默认策略有助于防止垃圾攻击，并给出了几个确定祖先交易数量的例子。

- **<!--how-is-simplicity-better-suited-for-static-analysis-compared-to-script-->**[与 Script 相比，Simplicity 如何更适合静态分析？]({{bse}}95332)
  [Simplicity 白皮书][simplicity] 的作者 Russell O'Connor 描述了与 Simplicity 语言相比，静态分析比特币 Script 程序的挑战。

## 发布与候选发布

*受欢迎的比特币基础设施项目的新版本与候选发布版本。请考虑升级到新版本或帮助测试候选发布版本。*

- [Bitcoin Core 0.20.0rc1][bitcoin core 0.20.0] 是下一个主要版本的候选发布。
- [LND 0.10.0-beta.rc6][lnd 0.10.0-beta] 允许测试 LND 的下一个主要版本。
- [C-Lightning 0.8.2-rc3][c-lightning 0.8.2] 是 C-Lightning 下一个版本的最新候选发布。

## 值得注意的代码和文档更改

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Rust-Lightning][rust-lightning repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中值得注意的更改。*

*注意：下面提到的 Bitcoin Core 提交适用于其主开发分支，因此这些更改可能不会在即将发布的 0.20 版本之前发布，预计大约在 0.20 版本发布后六个月的 0.21 版本中。*

- [Bitcoin Core #15761][] 添加了一个 `upgradewallet` RPC，取消了启动时升级的旧方法，从而允许用户在加载钱包时解锁并升级到[分层确定性（HD）][Hierarchical Deterministic ref]。该功能还兼容[多钱包][multi-wallet]，因为它在 RPC 指定的单个钱包上运行。

- [Bitcoin Core #17509][] 允许钱包 GUI 将[部分签名比特币交易][topic psbt]（PSBT）保存到文件，并从文件加载 PSBT。保存功能适用于禁用私钥的钱包，此前 Bitcoin Core 会自动将 PSBT 复制到剪贴板（请参阅 Newsletters [#74][news74 core psbt] 和 [#82][news82 core psbt] 中描述的 PR）。加载 PSBT 时，如果所有签名都可用，它将提供最终确定和广播交易的选项；否则，PSBT 将被复制到剪贴板，供单独的用户操作进行签名（例如，使用 GUI 控制台的 RPC 或使用诸如 [HWI][topic hwi] 等独立工具）。预计后续 PR 将添加在 GUI 中签名 PSBT 的功能。

## 特别感谢

我们感谢 Antoine Riard、ZmnSCPxj 和 Matt Corallo 审阅了本期 Newsletter 的草稿，并帮助我们理解 LN 原子性问题的细节。任何剩余的错误均由 Newsletter 作者负责。

## 脚注
[^package-relay]:
    处理 LN 中任意费用率的最终解决方案还取决于比特币全节点能够执行[包中继][Bitcoin Core #14895]，这是一个长期讨论但从未完全实施的功能。目前，LN 承诺交易通常只需[稍微支付更高][corallo slightly higher]的费用率，以避免需要包中继。

[^non-routing-issues]:
    虽然目前已知唯一直接窃取资金的方法是通过滥用路由节点（如 Alice→Bob→Mallory 中的 Bob），但当对支付者（如 Alice→Mallory 中的 Alice）执行相同的延迟原像结算和阻止退款结算的攻击时，可能会产生一个“支付失败”的错误，从而导致用户在未意识到第一次支付尚未撤销的情况下发起第二次支付。这种[间接攻击][corallo send twice] 或许可以通过警告用户支付卡住——而不是失败——并且发送额外的支付可能会导致损失来解决。

{% include references.md %}
{% include linkers/issues.md issues="688,15761,17509,14895" %}
[bitcoin core 0.20.0]: https://bitcoincore.org/bin/bitcoin-core-0.20.0
[Hierarchical Deterministic ref]: https://bitcoin.org/en/glossary/hd-protocol
[multi-wallet]: https://bitcoin.org/en/release/v0.15.0.1#multi-wallet-support
[lnd 0.10.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.10.0-beta.rc6
[c-lightning 0.8.2]: https://github.com/ElementsProject/lightning/releases/tag/v0.8.2rc3
[news78 anchor outputs]: /zh/newsletters/2019/12/28/#anchor-outputs
[corallo thread bd]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-April/017757.html
[corallo thread ld]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-April/002639.html
[harding reject]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-April/002650.html
[corallo targeted relay]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-April/002652.html
[harding pay]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-April/002664.html
[zmn ptlcs]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-April/002667.html
[osuntokun reasonable]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-April/002641.html
[corallo mempool not guaranteed]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-April/002648.html
[darosior revault]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-April/017793.html
[news94 bishop vault]: /zh/newsletters/2020/04/22/#vaults-prototype
[cltv_expiry_delta]: https://github.com/lightningnetwork/lightning-rfc/blob/master/02-peer-protocol.md#cltv_expiry_delta-selection
[cl ced]: https://github.com/ElementsProject/lightning/blob/10f47b41fa3192638442ef04d816380950cc32c9/lightningd/options.c#L630
[eclair ced]: https://github.com/ACINQ/eclair/blob/19975d3d8128705b92811ce0bc7a3881ecaf99dd/eclair-core/src/main/resources/reference.conf#L61
[lnd ced]: https://github.com/lightningnetwork/lnd/blob/0cf63ae8981a1041dd7b9f217dcc2158a28247d3/chainregistry.go#L64
[rl ced]: https://github.com/rust-bitcoin/rust-lightning/blob/12e2a81e1daf635578e1cfdd7de55324ed04bd48/lightning/src/ln/channelmanager.rs#L430
[corallo slightly higher]: https://github.com/bitcoinops/bitcoinops.github.io/pull/394#discussion_r416014263
[corallo send twice]: https://github.com/bitcoinops/bitcoinops.github.io/pull/394#discussion_r416099907
[simplicity]: https://blockstream.com/simplicity.pdf
[bitcoin core default ancestor limit]: https://github.com/bitcoin/bitcoin/blob/9fac600ababd8edefbe053a7edcd0e178f069f84/src/validation.h#L56
[news74 core psbt]: /zh/newsletters/2019/11/27/#bitcoin-core-16944
[news82 core psbt]: /zh/newsletters/2020/01/29/#bitcoin-core-17492
