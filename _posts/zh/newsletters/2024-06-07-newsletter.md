---
title: 'Bitcoin Optech Newsletter #306'
permalink: /zh/newsletters/2024/06/07/
name: 2024-06-07-newsletter-zh
slug: 2024-06-07-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报宣布了即将披露的影响旧版 Bitcoin Core 的漏洞，描述了新版测试网的 BIP 草案，总结了基于函数加密的限制条款提案，检查了在比特币脚本中执行 64 位算术的更新，链接到使用 `OP_CAT` 操作码验证签名的工作量证明脚本，并探讨了 `bitcoin:` URI 的 BIP21 规范的一项更新提案。此外，还包括常规版块，用于发布新版本和候选版本，以及介绍热门比特币基础设施软件的重大变更。

## 新闻

- **<!--upcoming-disclosure-of-vulnerabilities-affecting-old-versions-of-bitcoin-core-->****即将披露的影响旧版 Bitcoin Core 的漏洞：**
  Bitcoin Core 项目的几位成员在 IRC 上[讨论了][irc disclose]披露影响旧版 Bitcoin Core 漏洞的[拟议策略][disclosure policy]。对于低严重性漏洞，将在消除（或有效缓解）该漏洞的 Bitcoin Core 版本首次发布的约两周后披露详细信息。对于大多数其他漏洞，将在受该漏洞影响的 Bitcoin Core 最后一个版本停止维护（即发布后约一年半）后披露详细信息。对于罕见的严重漏洞，Bitcoin Core 安全团队成员将私下讨论最合适的披露时间。

  在进一步讨论该策略后，该项目计划开始披露影响 Bitcoin Core 24.x 及更低版本的漏洞。**强烈建议**所有用户和管理员在接下来的两周内升级到 Bitcoin Core 25.0 或更高版本。尽可能使用最新版本始终是最理想的选择，无论是绝对最新版本（截至撰写本文时为 27.0）还是特定版本系列中的最新版本（例如 25.x 版本系列的 25.2 或 26.x 版本系列的 26.1）。

  如我们一直以来的策略，Optech 将总结所有影响我们关注的基础设施项目（包括 Bitcoin Core）的重大安全漏洞。

- **<!--bip-and-experimental-implementation-of-testnet4-->****BIP 和 testnet4 的实验性实施：**
  Fabian Jahr 在 Bitcoin-Dev 邮件列表中[发布][jahr testnet4]了 testnet4 的 [BIP 草案][bips #1601]，testnet4 是 [testnet][topic testnet] 的新版本，旨在解决现有 testnet3 的一些问题（见[第 297 期周报][news297 testnet]）。Jahr 还链接了 Bitcoin Core 的[拉取请求][bitcoin Core #29775]，其中包含了一个建议实现。Testnet4 与 testnet3 有两个显著的不同：

  - *<!--fewer-reversions-to-difficulty-1-->**还原到难度-1的次数减少：* 通过挖出一个时间戳比倒数第二个区块晚 20 分钟以上的极限区块，很容易（无意或故意地）将整个 2016 个区块的周期降低到最低难度（难度-1）。现在，周期难度只能按照主网上的常规方式向下调整——尽管如果时间戳比前一个区块晚20分钟以上，仍然有可能以难度-1 开采新周期中的所有区块（第一个区块除外）。[^testnet-fixup]

  - *<!--time-warp-fixed-->**修复时间扭曲问题：* 在 testnet3（以及主网）上，利用[时间扭曲攻击][topic time warp]，可以在不增加难度的情况下，显著提高出块速度，远超 10 分钟一个区块。Testnet4 现在实现了时间扭曲解决方案，该方案是主网[共识清理][topic consensus cleanup]软分叉的一部分。

  BIP 草案还提到了 testnet4 的一些讨论过但没有采用的补充和备选想法。

- **<!--functional-encryption-covenants-->**函数加密限制条款：** Jeremy Rubin 在 Delving Bitcoin 上[发表][rubin fe post]了[论文][rubin fe paper]，介绍了如何在理论上利用[函数加密][functional encryption]为比特币添加一系列[限制条款][topic covenants]，而无需修改共识。从根本上说，这需要限制条款的用户信任第三方，尽管这种信任可以分散到多方，只需要其中一方在特定时间诚实行事即可。

  本质上讲，函数加密允许创建与特定程序相对应的公钥。满足程序要求的一方将能够创建与公钥相对应的签名（无需知道相应的私钥）。

  Rubin 指出，与现有的限制条款提案相比，这种方案的优势在于所有操作（验证生成的签名除外）都在链下进行，无需在链上发布任何数据（公钥和签名除外）。这总是更加私密，而且通常可以节省空间。通过执行多次签名检查，可以在同一脚本中使用多个限制条款程序。

  除了需要可信设置外，Rubin 还描述了函数加密的另一个主要缺点，即“加密技术不够成熟，目前还无法实际使用”。

- **<!--updates-to-proposed-soft-fork-for-64-bit-arithmetic-->****提议的 64 位算术软分叉的更新：** Chris Stewart 在 Delving Bitcoin 中[发帖][stewart 64bit]宣布更新他之前提出的在比特币脚本中添加 64 位数字处理能力的提案（见第 [285][news285 64bit] 期和第 [290][news290 64bit] 期周报）。主要变化如下：

  - *<!--updating-existing-opcodes-->更新现有操作码：* 无需添加新的操作码，如 `OP_ADD64`，只需更新现有操作码（如 `OP_ADD`）即可对 64 位数字进行操作。由于大数字编码与当前小数字的编码不同，升级后使用大数字的脚本片段可能需要修改；Stewart举了一个例子，`OP_CHECKLOCKTIMEVERIFY` 就需要一个 8 字节的参数，而非 5 字节。

  - *<!--result-includes-a-bool-->结果包括布尔值：* 一个成功的操作不仅会将结果放入堆栈，还会将一个布尔值放入堆栈，来表明操作成功。操作失败的一个常见原因是结果大于 64 位，导致字段溢出。在代码中可以使用 `OP_VERIFY` 来确保操作成功完成。

  Anthony Towns [回复][towns 64bit]主张采用另一种方法，即当发生溢出时，默认操作码会失败，而不是要求脚本额外验证操作是否成功。在那些需要测试一项操作是否会导致溢出的情况下，可以启用新的操作码，例如 `ADD_OF`。

- **<!--op-cat-script-to-validate-proof-of-work-->****`OP_CAT` 脚本用于验证工作量证明：** Anthony Towns 在 Delving Bitcoin 上[发布了][towns powcat]一个 signet 上的脚本，该脚本使用 [OP_CAT][topic op_cat] 允许任何人使用工作量证明（PoW）来花费发送到脚本的钱币。这可以作为一个去中心化的 signet 比特币水龙头：当矿工或用户获得多余的 signet 比特币时，他们将它们发送到这种脚本里。当一个用户想要更多的 signet 比特币时，他们可以在 UTXO 集中搜索支付给脚本的款项、生成 PoW，并创建一笔使用该 PoW 来领取水龙头钱币的交易。

  Towns 的帖子描述了这种脚本以及做出若干设计选择的动机。

- **<!--proposed-update-to-bip21-->****BIP21的拟议更新：** Matt Corallo 在 Bitcoin-Dev 邮件列表中[发布了][corallo bip21]有关更新 `bitcoin:` URI 的 [BIP21][] 规范的内容。正如之前讨论过的（见[第 292 期周报][news292 bip21]），几乎所有比特币钱包对 URI 方案的运用都与规定不同，对发票协议的额外更改可能会导致 BIP21 的使用发生额外变化。该[提案][bips #1555]的主要变化包括：

  - *<!--more-than-base58check-->**不只是 base58check：* BIP21 希望每个比特币地址都使用 base58check 编码，但这仅用于 P2PKH 和 P2SH 输出的旧地址。现代输出使用 [bech32][topic bech32] 和 bech32m。未来的付款将付到[静默付款][topic silent payments]地址和闪电网络[要约][topic offers]协议，这些几乎肯定会用作 BIP21 的携带数据。

  - *<!--empty-body-->空数据体：* BIP21 目前要求在携带数据的数据体部分提供一个比特币地址，并通过查询参数提供额外信息（例如支付金额）。之前的新支付协议（例如 [BIP70 支付协议][topic bip70 payment protocol]）指定了新的查询参数（参见 [BIP72][]），但不了解参数的客户端会回退到使用数据体中的地址。在某些情况下，接收者可能不想使用基本地址类型（base58check、bech32 或 bech32m），例如注重隐私的静默支付用户。建议的更新允许数据体字段为空。

  - *<!--new-query-parameters-->新的查询参数：* 该更新描述了三个新的关键字： `lightning` 用于（目前使用中的）[BOLT11][] 发票、`lno` 用于（提议中的）的闪电网络要约、以及 `sp` 用于（提议中的）静默支付。该更新还描述了未来参数的命名方式。

  Corallo 在他的帖子中指出，这些更改对所有已部署的软件都是安全的，因为钱包会忽略或拒绝任何无法成功解析的 `bitcoin:` URI。

## 新版本和候选版本

*热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Core Lightning 24.05rc2][] 是这款流行的闪电网络节点实现的下一个主要版本的候选发布版本。

- [Bitcoin Core 27.1rc1][] 是这个主流全节点实现的维护版本的候选发布版本。

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*


- [Core Lightning #7252][] 改变了 `lightningd` 的行为，使其在合作关闭通道期间忽略 `ignore_fee_limits` 设置。这解决了当对方是 LDK 节点时，Core Lightning (CLN) 通道开启节点支付过高手续费的问题。在这种情况下，当 LDK 非开启节点（Alice）发起合作通道关闭并开始协商手续费时，CLN 开启节点（Bob）会回应说，由于设置了 `ignore_fee_limits`，手续费可以在 `min_sats` 和 `max_channel_size` 之间。LDK [将会][ldk #1101]“始终选择允许范围内的最高金额”（与BOLTs规范相反），因此 Bob 选择该上限，然后 Alice 接受，导致 Alice 广播的交易手续费明显过高。

- [LDK #2931][] 增强了寻路期间的日志记录功能，以纳入有关直接通道的额外数据，例如这些通道是否缺失、其最小 [HTLC][topic htlc] 值和最大 HTLC 值。新增的日志记录功能旨在通过提供每个通道可用流动性和限制的可见性，更好地解决路由问题。

- [Rust Bitcoin #2644][] 在 `bitcoin_hashes` 组件中添加了 HKDF（HMAC（基于哈希的消息认证码）提取和扩展密钥派生函数），以在 Rust Bitcoin 中实现 [BIP324][]。HKDF 用于以安全、标准化的方式从密钥材料源派生加密密钥。BIP324（也称为 [v2 P2P 传输][topic v2 p2p transport]）是一种允许比特币节点通过加密连接进行通信的方法（在 Bitcoin Core 中默认启用）。

- [BIPs #1541][] 添加了 [BIP431][]，其中包含“在确认前受拓扑限制”（[TRUC][topic v3 transaction relay]）交易（v3 交易）的规范，这些交易是标准交易的一个子集，附加规则旨在允许[交易替换][topic rbf]，同时最大限度地降低克服[交易钉死][topic transaction pinning]攻击的成本。

- [BIPs #1556][] 添加了 [BIP337][]，其中包含_压缩交易_的规范，这是一种序列化协议，用于压缩比特币交易，使其大小最多减少 50%。它们适用于低带宽传输，例如通过卫星、业余无线电或隐写术。提出了两个 RPC 命令：`compressrawtransaction` 和 `decompressrawtransaction`。有关 BIP337 的更详细说明，请参阅周报 [#267][news267 bip337]。

- [BLIPs #32][] 添加了 [BLIP32][]，描述了如何将基于 DNS 的人类可读的比特币支付指令（参见[周报 #290][news290 omdns]）与[洋葱消息][topic onion messages]结合使用，从而将支付发送到 `bob@example.com` 之类的地址。例如，Alice 指示她的闪电网络客户端向 Bob 付款。她的客户端可能无法直接安全解析 DNS 地址，但可以使用洋葱消息与其提供 DNS 解析服务的对等节点之一联系。对等节点检索 `example.com` 上 `bob` 条目的 DNS TXT 记录，并将结果与 [DNSSEC][] 签名一起放入洋葱消息中，回复给 Alice。Alice 验证信息，并使用[要约][topic offers]协议向 Bob 索要发票。

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}

## 脚注

[^testnet-fixup]:
    本段在发布后进行了编辑。感谢Mark “Murch” Erhardt 的[更正][murch correction]。

{% include references.md %}
{% include linkers/issues.md v=2 issues="7252,2931,2644,1541,1556,32,1601,29775,1555,1101" %}
[rubin fe paper]: https://rubin.io/public/pdfs/fedcov.pdf
[core lightning 24.05rc2]: https://github.com/ElementsProject/lightning/releases/tag/v24.05rc2
[news290 omdns]: /zh/newsletters/2024/02/21/#dns-based-human-readable-bitcoin-payment-dns
[dnssec]: https://zh.wikipedia.org/wiki/%E5%9F%9F%E5%90%8D%E7%B3%BB%E7%BB%9F%E5%AE%89%E5%85%A8%E6%89%A9%E5%B1%95
[jahr testnet4]: https://mailing-list.bitcoindevs.xyz/bitcoindev/a6e3VPsXJf9p3gt_FmNF_Up-wrFuNMKTN30-xCSDHBKXzXnSpVflIZIj2NQ8Wos4PhQCzI2mWEMvIms_FAEs7rQdL15MpC_Phmu_fnR9iTg=@protonmail.com/
[news297 testnet]: /zh/newsletters/2024/04/10/#discussion-about-resetting-and-modifying-testnet-testnet
[rubin fe post]: https://delvingbitcoin.org/t/fed-up-covenants/929
[functional encryption]: https://en.wikipedia.org/wiki/Functional_encryption
[stewart 64bit]: https://delvingbitcoin.org/t/64-bit-arithmetic-soft-fork/397/49
[towns 64bit]: https://delvingbitcoin.org/t/64-bit-arithmetic-soft-fork/397/50
[news285 64bit]: /zh/newsletters/2024/01/17/#proposal-for-64-bit-arithmetic-soft-fork-64
[news290 64bit]: /zh/newsletters/2024/02/21/#continued-discussion-about-64-bit-arithmetic-and-op-inout-amount-opcode-64-op-inout-amount
[towns powcat]: https://delvingbitcoin.org/t/proof-of-work-based-signet-faucet/937
[corallo bip21]: https://mailing-list.bitcoindevs.xyz/bitcoindev/93c14d4f-10f3-48af-9756-7e39d61ba3d4@mattcorallo.com/
[news292 bip21]: /zh/newsletters/2024/03/06/#updating-bip21-bitcoin-uris-bip21-bitcoin-uri
[irc disclose]: https://bitcoin-irc.chaincode.com/bitcoin-core-dev/2024-06-06#1031717;
[disclosure policy]: https://gist.github.com/darosior/eb71638f20968f0dc896c4261a127be6
[Bitcoin Core 27.1rc1]: https://bitcoincore.org/bin/bitcoin-core-27.1/
[news289 v3]: /zh/newsletters/2024/02/14/#bitcoin-core-28948
[news296 v3]: /zh/newsletters/2024/04/03/#bitcoin-core-29242
[news305 v3]: /zh/newsletters/2024/05/31/#bitcoin-core-29873
[news267 bip337]: /zh/newsletters/2023/09/06/#bitcoin-transaction-compression
[murch correction]: https://github.com/bitcoinops/bitcoinops.github.io/pull/1714#discussion_r1630230324
