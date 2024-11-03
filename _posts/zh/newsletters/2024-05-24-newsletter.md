---
title: 'Bitcoin Optech Newsletter #304'
permalink: /zh/newsletters/2024/05/24/
name: 2024-05-24-newsletter-zh
slug: 2024-05-24-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报总结了一项对多种无需先关再开就可升级闪电通道的提议的分析，讨论了保证参加矿池的矿工得到合理支付的困难，还链接了一份关于安全使用 PSBT 以沟通 “静默支付（silent payment）” 相关信息的讨论，公布了为 miniscript 提出的一个 BIP，还总结了一个使用频繁再平衡的闪电通道来模拟一种期货合约的提议。此外是我们的常规栏目：服务和客户端软件的变更总结、软件新版本和候选版本的公告，还总结了热门比特币基础设施软件的值得关注的更新。

## 新闻

- **<!--upgrading-existing-ln-channels-->升级现有的闪电通道**：Carla Kirk-Cohen 在 Delving Bitcoin 论坛上[提出][kc upchan]了一份总结，分析了几项旨在升级既有闪电通道以支持新特性的提议。她考量了多种情形，例如：

  - *<!--changing-parameters-->改变参数*：目前，部分通道设定是由双方提前商定的，在通道的整个生命历程中都不能更改。参数更新功能将允许双方在后续时间里重新谈判。举个例子，节点可能希望改变他们开始[修剪 HTLC][topic trimmed htlc] 的金额门槛，或者是为了反激励对手使用旧状态关闭通道而要求对手保留的通道余额。
  - *<!--updating-commitments-->更新承诺交易形式*：闪电通道内的 *承诺交易* 允许参与者将最新的通道状态发布的链上。而[承诺交易形式更新][topic channel commitment upgrades]功能允许双方在基于 P2WSH 的通道中切换成使用 “[锚点输出][topic anchor outputs]” 和 “[v3 交易][topic v3 transaction relay]”、在 “[简单 taproot 通道][topic simple taproot channels]” 中切换成使用 “点时间锁合约（[PTLC][topic ptlc]）”。
  - *<!--replacing-funding-->替换注资输出*：闪电通道是以一笔 *注资交易* 的形式锚定在链上的，这笔交易的输出会在链下被承诺交易反复花费。一开始，所有的闪电注资交易都使用 P2WSH 输出；但是，更新的特性，例如 [PTLC][topic ptlc]，需要切换成使用 P2TR 输出。

  Kirk-Cohen 对比三种此前出现的升级通道的想法：

  - *<!--dynamic-commitments-->动态承诺交易*：如其[规范草案][BOLTs #1117]所述，该提议允许改变几乎所有的通道参数，并且通过一种新的 “kickoff” 交易提供了更新注资输出和承诺交易类型的通用路径。
  - *<!--splice-to-upgrade-->以拼接来升级*：这个想法允许一笔 “[通道拼接交易][topic splicing]”（它本就必然要更新一条通道的注资输出）来改变注资输出的类型，以及（可选）承诺交易的形式。它并不能直接处理改变参数的需要。
  - *<!--upgrade-on-re-establish-->在重建中升级*：也有自己的[规范草案][bolts #868]，该提议允许双方在重新建立数据连接的时候改变许多通道参数。也并不直接处理更新注资输出和承诺交易形式的需要。

  展示完所有的选择之后，Kirk-Cohen 在一张表格中对比了它们的链上开销、优点和缺点；她也对比了不使用任何此类方案的链上开销。她给出了一些结论，包括：“我认为，明智的做法是现在开始开发 ‘[动态承诺交易][bolts #1117]’ 技术以更新参数和承诺交易的格式，但使之独立于升级到 taproot 通道的方法选择。因为它会给我们升级到 `option_zero_fee_htlc_tx` 锚点通道的办法，也提供了一种承诺交易格式的升级机制，可以用来升级到 V3 通道（只要后者形成了规范）。”

- **<!--challenges-in-rewarding-pool-miners-->保证参与矿池的矿工得到合理支付的挑战**：Ethan Tuttle 在 Delving Bitcoin 论坛中[发帖][tuttle poolcash]指出[矿池][topic pooled mining]可以按照挖矿份额的比例用 [ecash][topic ecash] token 来奖励参与的矿工。然后矿工可以立即卖出或转移这些 token，或者可以等待矿池挖出区块，到某个时间点矿池会用聪来交换这些 token。

  对这个想法的批评和建议都出现了。我们发现尤有启发性的是 Matt Corallo 的[回复][corallo pooldelay]，他指出了一个底层问题：大型矿池所实现的标准化支付方法不允许矿工在短的时间间隔内计算自己应得的收益。两种常见的计酬方法是：

  - *<!--pay-per-share-pps-->按份额支付（PPS）*：这会按照矿工贡献的工作量向矿工支付，即使还没有找到区块。为区块补贴计算成比例的报酬是容易的，但为交易手续费计算合理的报酬就更难。Corallo 指出，大部分矿池似乎都使用这些挖矿份额在一天内收到的手续费作为平均值，也就是说，一个份额的报酬至少要在该份额挖出之后的一天之后才能计算出来。此外，许多矿池可能会使用自己的方法来调整手续费平均数。
  - *<!--pay-per-last-n-shares-pplns-->按最后 n 个份额支付（PPLNS）*：按照矿工在临近矿池挖出区块的时间贡献的份额来计算报酬。但是，一个矿工只有在自己挖出一个区块时，才能确切地知晓矿池一定挖出了一个区块。一个普通矿工（在短期内）没有办法知道矿池派发的是正确的收益。

  信息的缺乏使得矿工无法快速切换到另一个矿池，即使他们的主要矿池已经开始欺骗他们。[Stratum v2][topic pooled mining] 也不能解决这个问题，虽然正直的矿池可以使用一种标准化的消息来告知矿工他们将停止得到支付。Corallo 链接了一个给 Startum V2 的[提议][corallo sv2 proposal]，允许矿工验证他们所有的份额都计算进了报酬中，从而至少矿工可以在一个稍长的时间（几小时到几天）之后检测出自己没有得到正确的支付。

  截至本刊出版之时，讨论还在继续。

- **<!--discussion-about-psbts-for-silent-payments-->用于静默支付的 PSBT 的讨论**：Josie Baker 在 Delving Bitcoin 论坛中[开启][baker psbtsp]了一个关于为[静默支付][topic silent payments]设计 [PSBT][topic psbt] 插件的讨论，还引用了 Andrew Toth 撰写的一份[规范草案][toth psbtsp]。用于静默支付的 PSBT 有两个方面：

  - **<!--spending-to-sp-addresses-->花费到静默支付地址**：真正放到交易中的输出脚本取决于静默支付地址以及交易的输入。PSBT 中的任何输入的变更都有可能导致一个静默支付输出无法被标准钱包软件花费，所以需要额外的 PSBT 验证。一些输入类型无法使用静默支付，这也需要验证。

    至于可以使用的输入类型，感知静默支付的花费逻辑需要这些输入的私钥，但软件钱包可能无法得到它，因为它存放在一个硬件签名设备中。Baker 描述了一种方案，允许花费者无需私钥就能创建一个静默支付输出脚本，但它可能会泄露一个私钥，所以可能不会在硬件签名器中得到实现。

  - **<!--spending-previously-received-sp-outputs-->花费以往收到的静默支付输出**：PSBT 将需要包含用来调整花费密钥的共享秘密值。可以通过增设一个 PSBT 字段来实现。

  截至本刊出版之时，讨论还在继续。

- **<!--proposed-miniscript-bip-->Miniscript BIP 面世**：Ava Chow 在 Bitcoin-Dev 邮件组中[提出][chow miniscript]了关于 [miniscript][topic miniscript] 的一份 [BIP 草案][chow bip]。Miniscript 这种语言的代码可以转换成 Bitcoin Script 代码，但允许组合、模板化和确定性分析。这份 BIP 草案派生自 miniscript 的长期存在的网站，而且应该跟现有的 miniscript 实现相对应，包括用在 P2WSH 见证脚本和用在 P2TR [tapscript][topic tapscript] 中的实现。

- **<!--channel-value-pegging-->通道价值挂钩**：Tony Klausing 在 Delving Bitcoin 论坛中[发布][klausing stable]了关于 “*稳定通道（stable channel）*” 的一份提议和工作[代码][klausing code]。假设 Alice 希望保留等价于 1000 美元的比特币。Bob 也有意提供这种保障，可能因为他预期比特币会升值，也可能因为 Alice 愿意支付一个溢价（也可能两者都用）。他们一起开设了一条闪电通道，而且，每一分钟，他们都会执行以下操作：

  - 双方都检查同一个 BTC/USD 价格信息源。
  - 如果 BTC 的价格提升，Alice 就减少自己在通道中的比特币余额，直至其余额价值等于 1000 美元，减少的这部分余额会转移给 Bob。
  - 如果 BTC 的价格下降，Bob 就将足量的 BTC 转移给 Alice，直至 Alice 在通道中的余额的价值等于 1000 美元。

  这种方案的设计目标是让再平衡频繁发生，从而每一次价格变动都低于利益暂时受损的一方关闭通道的代价，鼓励他们爽快地支付并维持这种合作关系。

  Klasuing 认为，一些交易员会认同这种信任最小化的关系比托管式的期权市场要好。他也认为，这可以作为发行以美元计价的 [ecash][topic ecash] 的银行的基础。这个方案可以适用于任何能够确定市场价格的资产。

## 服务和客户端软件的变更

*在这个月度栏目中，我们点出比特币钱包和服务的有趣升级。*

- **<!--silent-payment-resources-->关于静默支付的资源**：多项关于[静默支付][topic silent payments]的资源发布了，包括一个信息网站 [silentpayments.xyz][sp website]、[两个][bi ts sp] TypeScript [库][bw ts sp]、一个[基于 Go 语言的后端][gh blindbitd]、一个[网页版钱包][gh silentium]，[等等][sp website devs]。因为绝大部分软件都是新开发的，还未成熟，请谨慎使用。

- **<!--cake-wallet-adds-silent-payments-->Cake Wallet 加入静默支付**：[Cake Wallet][cake wallet website]最近[宣布][cake wallet announcement]他们的最新 beta 版本支持了静默支付。

- **<!--coordinatorless-coinjoin-poc-->无需协调员的 coinjoin 概念验证**：[Emessbee][gh emessbee] 是一个概念验证项目，可用来创建 [coinjoin][topic coinjoin] 交易，而无需引入一个中心协调员。

- **<!--ocean-adds-bolt12-support-->OCEAN 矿池添加 BOLT12 支持**：OCEAN 矿池使用一种[签名消息][topic generic signmessage]将一个比特币地址与一个 [BOLT12 offer][topic offers] 关联起来，作为他们的[闪电网络付酬][ocean docs]方式的一部分。

- **<!--coinbase-adds-lightning-support-->Coinbase 添加闪电网络支持**：使用来自 [Lightspark][lightspark website] 的基础设施，[Coinbase 交易所添加了闪电网络][coinbase blog]存取款支持。

- **<!--bitcoin-escrow-tooling-announced-->比特币保管合约工具链发布**：[BitEscrow][bitescrow website]团队退出了一组[开发者工具][bitescrow docs]，用于实现非托管的比特币保管合约（escrow）。

- **<!--blocks-call-for-mining-community-feedback-->Block 请求挖矿社区的反馈**：在[播报][block blog]他们的 3 纳米芯片的进展时，Block 请求挖矿社区给予对他们的硬件软件特性、维护状况和其它问题的反馈。

- **<!--sentrum-wallet-tracker-released-->Sentrum 钱包跟踪器发布**：[Sentrum][gh sentrum] 是一种观察钱包，支持一系列的通知信道。

- **<!--stack-wallet-adds-frost-support-->Stack Wallet 加入 FROST 支持**：[Stack Wallet v2.0.0][gh stack wallet] 使用 Rust 库 Modular FROST 添加了对 FROST（一种 Schnorr [门限][topic threshold signature]多签名技术）的支持。

- **<!--transaction-broadcast-tool-announced-->交易广播工具发布**：[Pushtx][gh pushtx] 是一个简单的 Rust 程序，可以将交易直接广播到比特币点对点网络中。

## 新版本和候选版本

*热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Bitcoin Inquisition 27.0][] 是这个 Bitcoin Core 复刻的最新的大版本，它是专门用于在[signet][topic signet]上测试软分叉和其它重大协议变更的。本版本的新特性是在 signet 上强制执行由 [BIN24-1][] 和 [BIP347][] 指定的[OP_CAT][]。此外，“`bitcoin-util` 包含了一个新的子命令 `evalscript`，可以用来测试脚本操作码的动作”。已经放弃对 `annexdatacarrier` 和伪装的 “[临时锚点][topic ephemeral anchors]” 的支持（见周报 [#244][news244 annex] 和 [#248][news248 ephemeral]）。

- [LND v0.18.0-beta.rc2][] 是这个热门的闪电节点实现的下一个大版本的候选发布。

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Bitcoin Core #27101][] 引入了对 JSON-RPC 2.0 请求和服务端响应的支持。重大变更是，服务端将总是返回 HTTP 200 "OK"，除非出现了 HTTP 错误或者请求的格式不对，那么会返回错误或者结果字段（但不会同时返回两者）；而且无论是单个请求还是批量请求，结果都是相同的错误处理动作。如果请求主体中没有指定使用 2.0 版本，则会使用传统的 JSON-RPC 1.1 协议。

- [Bitcoin Core #30000][] 允许多笔拥有相同 `txid` 的交易在 `TxOrphanage`（孤儿交易区）中共存，并使用 `wtxid` 而非 `txid` 来索引它们。“孤儿交易区” 是一个空间有限的集结区域，Bitcoin Core 用来存储无法访问到其引用的父交易的交易。如果拥有匹配 txid 的父交易到达，则子交易会随之得到处理。伺机的 1 父 1 子（1p1c）[交易包接纳][topic package relay]会先发送一笔子交易，期望它被存储在孤儿交易区，然后再发送父交易 —— 这就使得接收节点会考虑它们的整体手续费率。

  不过，在伺机 1p1c 特性被合并的时候（见[周报 #301][news301 bcc28970]），已知攻击者可以通过抢先发送带有无效见证数据的子交易版本来阻止诚实用户使用这个特性。这笔畸形的子交易具有跟诚实子交易相同的 txid，但在父交易到达时，将无法通过验证，从而阻止子交易贡献出让交易包接纳策略正常工作所需的 [CPFP][topic cpfp] 交易包费率。

  因为孤儿交易区中的交易在此 PR 之前是以 txid 来索引的，所以具备特定 txid 的交易的第一个到达的版本会被存储在孤儿交易区中，所以攻击者可以通过更快、更频繁地发送交易来无限期阻止诚实用户发送交易。而在此 PR 之后，孤儿交易区可以接纳多笔具有相同 txid 的交易，只要它们有不同的见证数据（因此 wtxid 不同）。在收到它们的父交易之后，节点将具有足够多的信息来抛弃畸形的子交易，然后对有效的子交易执行预期的 1p1c 交易包接纳策略。这个 PR 之前也在 PR 审核俱乐部中讨论了，总结见 [周报 #301][news301 prclub]。

- [Bitcoin Core #28233][] 在 [#17487][bitcoin core #17487] 基础上开发，移除了对热资金（UTXO）缓存的定期刷写（原为每 24 小时刷写（flush）一次）。在 #17487 以前，频繁刷写到磁盘减少了节点或硬件崩溃后需要长时间重新编制索引的风险。而在 #17487 以后，新的 UTXO 将写入磁盘而不清空内存缓存 —— 虽然缓存依然需要在临近饱和（占满分配好的内存空间）时清空。热缓存让使用默认缓存设置的节点的区块验证速度提高了几乎一倍，甚至在给缓存分配了额外内存空间的节点上还有进一步的性能提升。

- [Core Lightning #7304][] 添加了一个对 [offers][topic offers] 风格的 `invoice_requests` 的回复流程，在它无法找到通往 `reply_path` 节点的路径时触发。CLN 的 `connected` 将开启一个瞬时的 TCP/IP 连接到请求节点，然后交付一条包含了一个发票的[洋葱消息][topic onion messages]。这个 PR 提升了 Core Lightning 与 LDK 的互操作性，并且允许在仅有少量节点支持洋葱消息时也能使用它（见[周报 #283][news283 ldk2723]）。

- [Core Lightning #7063][] 更新了手续费率安全边际倍增器，以动态调整手续费、应对可能出现的费率提升。这个倍增器尝试保证通道交易会支付足以让自身得到确认的手续费，无论是直接方式（有些交易毕竟无法追加手续费）还是通过手续费追加。现在这个倍增器将在手续费率较低（比如 1 聪/vbyte）时以当前[手续费估计][topic fee estimation]的 2 倍起步，然后在费率接近日均高点 `maxfeerate` 时逐步降低到 1.1 倍。

- [Rust Bitcoin #2740][] 为 `pow`（工作量证明）API 加入了一个 `from_next_work_required` 方法，它取一个 `CompactTarget`（代表以前的难度目标）、一个 `timespan`（当前与上一个区块的时间间隔）以及一个 `Params` 网络参数对象为输入。然后它会返回一个新的 `CompactTarget` 数值，表示下一个难度目标。这个函数所实现的算法基于 Bitcoin Core 的实现，可以在 `pow.cpp` 文件中找到。


{% include references.md %}
{% include linkers/issues.md v=2 issues="27101,30000,28233,7304,7063,2740,1117,868,17487" %}
[lnd v0.18.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.0-beta.rc2
[kc upchan]: https://delvingbitcoin.org/t/upgrading-existing-lightning-channels/881
[tuttle poolcash]: https://delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870
[corallo pooldelay]: https://delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870/14
[corallo sv2 proposal]: https://github.com/stratum-mining/sv2-spec/discussions/76#discussioncomment-9472619
[baker psbtsp]: https://delvingbitcoin.org/t/bip352-psbt-support/877
[toth psbtsp]: https://gist.github.com/andrewtoth/dc26f683010cd53aca8e477504c49260
[chow miniscript]: https://mailing-list.bitcoindevs.xyz/bitcoindev/0be34bd2-637b-44b1-a0d5-e0ad5812d505@achow101.com/
[chow bip]: https://github.com/achow101/bips/blob/miniscript/bip-miniscript.md
[klausing stable]: https://delvingbitcoin.org/t/stable-channels-peer-to-peer-dollar-balances-on-lightning/875
[klausing code]: https://github.com/toneloc/stable-channels/
[news244 annex]: /zh/newsletters/2023/03/29/#bitcoin-inquisition-22
[news248 ephemeral]: /zh/newsletters/2023/04/26/#bitcoin-inquisition-23
[Bitcoin Inquisition 27.0]: https://github.com/bitcoin-inquisition/bitcoin/releases/tag/v27.0-inq
[news301 prclub]: /zh/newsletters/2024/05/08/#bitcoin-core-pr-审核俱乐部
[news301 bcc28970]: /zh/newsletters/2024/05/08/#bitcoin-core-28970
[news283 ldk2723]: /zh/newsletters/2024/01/03/#ldk-2723
[sp website]: https://silentpayments.xyz/
[bi ts sp]: https://github.com/Bitshala-Incubator/silent-pay
[bw ts sp]: https://github.com/BlueWallet/SilentPayments
[gh blindbitd]: https://github.com/setavenger/blindbitd
[gh silentium]: https://github.com/louisinger/silentium
[sp website devs]: https://silentpayments.xyz/docs/developers/
[cake wallet website]: https://cakewallet.com/
[cake wallet announcement]: https://twitter.com/cakewallet/status/1791500775262437396
[gh emessbee]: https://github.com/supertestnet/coinjoin-workshop
[coinbase blog]: https://www.coinbase.com/blog/coinbase-integrates-bitcoins-lightning-network-in-partnership-with
[lightspark website]: https://www.lightspark.com/
[block blog]: https://www.mining.build/latest-updates-3nm-system/
[gh sentrum]: https://github.com/sommerfelddev/sentrum
[ocean docs]: https://ocean.xyz/docs/lightning
[bitescrow website]: https://www.bitescrow.app/
[bitescrow docs]: https://www.bitescrow.app/dev
[gh stack wallet]: https://github.com/cypherstack/stack_wallet/releases/tag/build_222
[gh pushtx]: https://github.com/alfred-hodler/pushtx
