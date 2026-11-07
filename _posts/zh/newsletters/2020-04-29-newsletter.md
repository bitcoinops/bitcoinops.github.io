---
title: 'Bitcoin Optech Newsletter #95'
permalink: /zh/newsletters/2020/04/29/
name: 2020-04-29-newsletter-zh
slug: 2020-04-29-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了一项影响闪电网络（LN）路由支付安全的问题披露，并宣布了一个新的预签名保险库提案。此外，还包括我们的常设栏目：Bitcoin Stack Exchange 精选问答、发布与候选发布的公告，以及热门比特币基础设施项目中值得注意的代码变更描述。

## 行动项

- **<!--review-the-disclosure-of-a-potential-ln-issue-->****审查潜在 LN 问题的披露**：如下面的*新闻*部分所述，本周的一项公开披露描述了一种从 LN 节点窃取资金的新方法。该问题与一个已知的既有手续费管理问题部分重叠。据我们所知，这个问题尚未被利用，因为过去两年中几乎所有的链上交易即便只支付默认的最低中继费率，也能相对快速地确认。如果费率在较长一段时间内显著上升，这些问题就会变得更加严重。详细信息请参阅我们在*新闻*部分的解释；如果你担心此问题会影响自己的通道，请联系你的 LN 软件供应商。

## 新闻

- **<!--new-attack-against-ln-payment-atomicity-->****针对 LN 支付原子性的新攻击**：Matt Corallo 在 [Lightning-Dev][corallo thread ld] 和 [Bitcoin-Dev][corallo thread bd] 两个邮件列表上同时发起一个讨论帖，披露了一个在[讨论][BOLTs #688]如何允许 LN 承诺交易通过[锚定输出][topic anchor outputs]进行[子为父付（CPFP）][topic cpfp]手续费追加时发现的攻击。我们用一个更详细的示例来说明这次攻击：Alice 通过 LN 通道向 Bob 发送一份哈希时间锁定合约（HTLC），该合约可按以下两种方式之一结算：

  - 如果 Bob 披露 `<hash>` 的原像，他就能花费 Alice 的 1 BTC
  - 否则，80 个区块后，Alice 可以把这 1 BTC 退回给自己

  Alice 还告诉 Bob，她这笔支付的目标是付给 Mallory，因此 Bob 使用他与 Mallory 的通道，向她发送一份相关的 HTLC：

  - 如果 Mallory 披露 `<hash>` 的原像，她就能花费 Bob 的 1 BTC（本例忽略路由手续费）
  - 否则，40 个区块后，Bob 可以把这 1 BTC 退回给自己

  虽然上述 HTLC 通常在链下创建并结算，但每个参与方还各有一笔*承诺交易*，可用来把 HTLC 承诺放到链上。一笔单独的链上*结算交易*可以满足 HTLC 的任一条件。

  例如，Mallory 可以先发布承诺交易，再创建一笔提供原像的结算交易，索取 Bob 的 1 BTC。如果 Bob 在 Alice-Bob 合约的 80 个区块超时之前看到 Mallory 的原像结算交易，他就能提取该原像，并用它取走 Alice 的 1 BTC（链上或链下均可）。或者，如果 Bob 没有看到原像结算交易，他可以在 40 个区块后创建自己的退款结算交易，收回自己的 1 BTC，从而也能启动对 Alice 那 1 BTC 的退款（同样链上或链下均可）。无论哪种情况，各方最终都仍符合其合约的本意。

  不幸的是，本周披露的情况显示，Mallory 似乎有办法绕过这个过程：既让 Bob 无法获知原像，又让他无法发出退款结算交易。

  - **<!--preimage-denial-->****拒绝披露原像**：Mallory 可以给自己的原像结算交易设一个低费率，让这笔交易无法很快确认，从而让 Bob 无法获知原像。如果 Bob 只在区块链里查找原像，那么只要这笔交易还没确认，他就看不到它。

  - **<!--refund-denial-->****阻止退款**：Mallory 先前广播的原像结算交易，会让矿工和比特币中继节点拒绝接受 Bob 之后广播的退款结算交易，因为这两笔交易*冲突*——它们花费的是同一个输入（承诺交易中创建的一个 UTXO）。理论上，Bob 的退款结算交易会支付更高的费率，因而可以通过 [RBF][topic rbf] 替换掉 Mallory 的原像结算交易；但在实践中，Mallory 可以用各种[交易钉住][topic transaction pinning]手法阻止这种替换发生。

  由于 Bob 既无法获知原像结算交易，也无法让自己的退款结算交易得到确认，因此等 Alice-Bob HTLC 的 80 个区块超时到期后，Alice 就能收回她提供给 Bob 的 1 BTC。而等 Mallory 的原像结算交易最终确认时，Mallory 就得到了 Bob 在 Bob-Mallory HTLC 中许诺给她的那 1 BTC。结果 Bob 比开始时少了 1 BTC。

  讨论帖中考虑了几种解决方案，但都存在问题，或者需要做出重大取舍：

  - **<!--require-a-mempool-->****要求运行内存池**：Bob 可以用一个比特币全节点监控比特币 P2P 中继网络，从而获知 Mallory 的结算交易。Eclair 等一些 LN 节点已经这么做，而且看起来这是[合理的额外负担][osuntokun reasonable]，因为该问题只直接影响路由节点（如 Bob）。只为自己收发支付的节点仅会间接受影响，[^non-routing-issues]因此普通用户仍然可以在移动设备上运行轻量级 LN 客户端。不幸的是，即便一切运转正常，不同全节点收到的交易也未必相同。更糟的是，像 Mallory 这样的攻击者还可以用一些手法[向不同对等节点发送不同的冲突交易][corallo mempool not guaranteed]（例如，把被钉住的原像结算交易发给已知矿工，却把另一笔至少共用其中一个输入的非结算交易发给非矿工的中继节点）。

  - **<!--beg-or-pay-for-preimages-->****求人或付费获取原像**：中继网络可以向 Bob 这样的交易提交者提供[关于冲突的信息][harding reject]，这样他们就不必自己持续监控中继。这个方案仍然面临一个问题：像 Mallory 这样的恶意行为者可以用[定向中继][corallo targeted relay]向矿工和非矿工发送不同的交易。此外，Bob 也许能[付费][harding pay]向矿工或其他第三方节点购买所需的原像，尽管这需要有人运行额外的软件，而且在 LN 协议的一些拟议升级部署之后，[做这件事可能就没那么容易了][zmn ptlcs]。

  - **<!--settlement-transaction-anchor-outputs-->****结算交易的锚定输出**：可以把链上结算交易重新设计成将其价值花到[锚定输出][topic anchor outputs]上，以便通过 [CPFP 豁免（carve-out）][topic cpfp carve out] 进行 [CPFP 手续费追加][topic cpfp]。这要求这些交易体积更大（增加链上手续费），并且要预签名（降低灵活性）。它只会直接影响在支付尚未结算时被单方面关闭的通道，而这种情况本身就会显著抬高链上成本，所以用户本就尽量避免。然而，提高链上执行的成本，也会提高通过 LN 无需信任地发送支付的最低实际金额。尽管有这些挑战，截至本文撰写时，这似乎仍是最受青睐的方案。

  Corallo 将其称为严重问题，但同时指出，它的后果与另一个已知问题相似，即 LN 链上交易的手续费管理问题。那个既有问题（在 [Newsletter #78][news78 anchor outputs] 中描述）是：承诺交易的费率在签署时就已确定，而签署时间可能比广播到比特币中继节点早好几天甚至好几周。如果自该交易上次签署以来，让交易进入接下来几个区块所需的最低费率已显著上升，那么承诺交易可能要等到 Alice 从 Bob 那里收回资金之后才能确认，于是又给 Bob 制造了既付钱给 Mallory、又退款给 Alice 的机会。（开发者正是在着手修复这个既有问题时发现了新问题。[^package-relay]）

  迄今为止，我们尚未听说 LN 中因链上手续费管理问题造成任何真实损失，部分原因可能是过去两年里很少有大幅费率飙升能持续足够长时间，从而显著延迟那些按原先可接受费率发出的交易的确认。好运不会无限期地持续，因此这个新问题又多给 LN 开发者一个理由，去优先实现更好的链上手续费管理。在此期间，担心该攻击的节点运营者不妨提高 [cltv_expiry_delta][]，让原像结算交易有更多时间确认。目前主流 LN 节点的默认值为：C-Lightning [14][cl ced]、LND [40][lnd ced]、Rust-Lightning [72][rl ced]、Eclair [144][eclair ced]。请注意，提高该值会让你的通道对付款方吸引力下降，因为该值越高，支付在最坏情况下等待结算的正常时间就越长。

- **<!--multiparty-vault-architecture-->****多方保险库架构**：Antoine “Darosior” Poinsot [宣布][darosior revault]了一个保险库[契约][topic covenants]原型的演示实现，它基于[上周 Newsletter][news94 bishop vault] 提到的那套预签名交易基本思路。这一新实现名为 *Revault*，重点是用多重签名（multisig）保障多方共享资金的安全存储。该协议允许一部分参与方通过让一笔信标（beacon）交易得到确认来启动提款流程；如果保险库的其他参与方反对提款，他们有机会广播第二笔交易，把资金退回到保险库中的紧急地址。如果在规定时间内没有异议，再由另一笔交易完成提款。Poinsot 正在征求对该提案的反馈。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们有点空闲时帮助好奇或困惑用户的地方。在本月栏目中，我们精选自上次更新以来得票最高的一些问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{%
endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--what-are-the-potential-attacks-against-ecdsa-that-would-be-possible-if-we-used-raw-public-keys-as-addresses-->**[如果我们将原始公钥用作地址，可能会对 ECDSA 发起哪些潜在攻击？]({{bse}}95123)
  Pieter Wuille 在回答中总结了用公钥哈希而非公钥作为地址的理由，即这能拖慢具备量子计算能力的攻击者。他接着列举了若干理由，说明这个说法可能被高估，并会带来虚假的安全感。

- **<!--what-is-meant-by-default-ancestor-limit-in-child-pays-for-parent-->**[在子为父付（CPFP）中，DEFAULT_ANCESTOR_LIMIT 是什么意思？]({{bse}}95473)
  用户 anu 就 Bitcoin Core 中的 [DEFAULT_ANCESTOR_LIMIT][bitcoin core default ancestor limit] 提问，想了解它与 [CPFP][topic cpfp] 手续费追加技术的关系。Murch 指出，这一默认策略有助于防止垃圾攻击，并给出了几个计算祖先交易数量的例子。

- **<!--how-is-simplicity-better-suited-for-static-analysis-compared-to-script-->**[与 Script 相比，Simplicity 如何更适合静态分析？]({{bse}}95332)
  [Simplicity 白皮书][simplicity]的作者 Russell O'Connor 描述了静态分析比特币 Script 程序的难点，并与 Simplicity 语言作了对比。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [Bitcoin Core 0.20.0rc1][bitcoin core 0.20.0] 是 Bitcoin Core 下一个大版本的候选发布。
- [LND 0.10.0-beta.rc6][lnd 0.10.0-beta] 允许测试 LND 的下一个大版本。
- [C-Lightning 0.8.2-rc3][c-lightning 0.8.2] 是 C-Lightning 下一版本的最新候选发布。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Rust-Lightning][rust-lightning repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中值得注意的变更。*

*注意：下面提到的 Bitcoin Core 提交针对其主开发分支，因此这些变更很可能要到 0.21 版才会发布，也就是在即将发布的 0.20 版发布约六个月之后。*

- [Bitcoin Core #15761][] 添加了一个 `upgradewallet` RPC，废弃了启动时升级钱包的旧方式，从而让用户可以在钱包已加载的情况下将其解锁并升级为[分层确定性（HD）][Hierarchical Deterministic ref]钱包。该功能同样兼容[多钱包][multi-wallet]，因为它作用于 RPC 指定的那个钱包。

- [Bitcoin Core #17509][] 允许钱包 GUI 将[部分签名比特币交易][topic psbt]（PSBT）保存到文件，并从文件加载 PSBT。保存功能在禁用私钥的钱包中也可用——此前这类钱包里 Bitcoin Core 会自动把 PSBT 复制到剪贴板（见 Newsletters [#74][news74 core psbt] 和 [#82][news82 core psbt] 中描述的 PR）。加载 PSBT 时，如果所有签名都已具备，程序会询问是否完成交易并广播；否则 PSBT 会被复制到剪贴板，等用户另行操作来签名（例如在 GUI 控制台调用 RPC，或使用 [HWI][topic hwi] 之类的独立工具）。后续 PR 预计会加入在 GUI 中签名 PSBT 的功能。

## 特别感谢

我们感谢 Antoine Riard、ZmnSCPxj 和 Matt Corallo 审阅了本期 Newsletter 的草稿，并帮助我们理解 LN 原子性问题的细节。任何剩余的错误均由 Newsletter 作者负责。

## 脚注
[^package-relay]:
    要应对 LN 中任意波动的费率，最终还取决于比特币全节点能否进行[交易包中继][Bitcoin Core #14895]（package relay）——这是一个讨论已久但从未完整实现的功能。目前，LN 承诺交易通常只需[支付比严格所需稍高][corallo slightly higher]的费率，就能免去对交易包中继的需要。

[^non-routing-issues]:
    虽然目前已知能直接借该攻击窃取资金的唯一方式是通过滥用路由节点（如 Alice→Bob→Mallory 中的 Bob），但当把同样的攻击——延迟原像结算并阻止退款结算——施加于付款方（如 Alice→Mallory 中的 Alice）时，可能会产生“支付失败”的错误提示，让用户在没意识到第一笔支付尚未撤销的情况下又发起第二笔支付。这种[间接攻击][corallo send twice]或许可以通过提醒用户来解决：这笔支付是卡住了，而不是失败了；再发送支付可能造成损失。

{% include references.md %}
{% include linkers/issues.md issues="688,15761,17509,14895" %}
[bitcoin core 0.20.0]: https://bitcoincore.org/bin/bitcoin-core-0.20.0
[Hierarchical Deterministic ref]: https://bitcoin.org/en/glossary/hd-protocol
[multi-wallet]: https://bitcoin.org/en/release/v0.15.0.1#multi-wallet-support
[lnd 0.10.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.10.0-beta.rc6
[c-lightning 0.8.2]: https://github.com/ElementsProject/lightning/releases/tag/v0.8.2rc3
[news78 anchor outputs]: /zh/newsletters/2019/12/28/#anchor-outputs
[corallo thread bd]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-April/017757.html
[corallo thread ld]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-April/002639.html
[harding reject]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-April/002650.html
[corallo targeted relay]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-April/002652.html
[harding pay]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-April/002664.html
[zmn ptlcs]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-April/002667.html
[osuntokun reasonable]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-April/002641.html
[corallo mempool not guaranteed]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-April/002648.html
[darosior revault]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-April/017793.html
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
