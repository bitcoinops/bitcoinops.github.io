---
title: 'Bitcoin Optech Newsletter #387'
permalink: /zh/newsletters/2026/01/09/
name: 2026-01-09-newsletter-zh
slug: 2026-01-09-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报警告 Bitcoin Core 中的钱包迁移漏洞，总结了一篇关于将 Ark 协议用作闪电网络通道工厂的文章，并链接到静默支付描述符的 BIP 草案。此外还包括我们的常规部分，描述候选发布版本以及热门比特币基础设施软件的重要变更。

## 新闻

- **<!--bitcoin-core-wallet-migration-bug-->****Bitcoin Core 钱包迁移漏洞：** Bitcoin Core 发布了一份关于 30.0 和 30.1 版本中旧版钱包迁移功能漏洞的[通知][bitcoin core notice]。使用 Bitcoin Core 旧版钱包的用户，如果使用未命名的钱包、此前没有将钱包迁移到描述符钱包，并且在这些版本中尝试迁移，如果迁移失败，可能会导致钱包目录被删除，从而可能造成资金损失。钱包用户在 v30.2 发布之前（参见下方的 [Bitcoin Core 30.2rc1](#bitcoin-core-30-2rc1)），不应使用 GUI 或 RPC 尝试钱包迁移。使用旧版钱包迁移以外功能的用户可以继续正常使用这些 Bitcoin Core 版本。

- **<!--using-ark-as-a-channel-factory-->****将 Ark 用作通道工厂：**
  René Pickhardt 在 Delving Bitcoin 上[撰文][rp delving ark cf]讨论了他关于 [Ark][topic ark] 的最佳用例是否可能是作为灵活的[通道工厂][topic channel factories]而非终端用户支付解决方案的讨论和想法。Pickhardt 早期的研究专注于通过[路由][news333 rp routing]和[通道再平衡][news359 rp balance]来优化闪电网络支付成功率的技术。包含闪电网络通道的类 Ark 结构此前已有讨论（[1][optech superscalar]、[2][news169 jl tt]、[3][news270 jl cov]）。

  Pickhardt 的想法聚焦于许多通道所有者可以使用 Ark 的 vTXO 结构批量处理其通道流动性变更（即开启、关闭、拼接），以此大幅降低运营闪电网络的链上成本，代价是在一个通道被放弃到其 Ark 批次完全过期之间需要额外的流动性开销。通过将 Ark 批次用作高效的通道工厂，LSP 可以更高效地为更多终端用户提供流动性，而批次的内置过期机制保证他们可以从闲置通道中回收流动性，而无需进行成本高昂的专门链上强制关闭序列。路由节点也将受益于更高效的通道管理操作，通过使用常规批次在其通道之间转移流动性，而不是单独的拼接操作。

  Greg Sanders [回复][delving ark hark]说他一直在研究类似的可能性，特别是使用 [hArk][sr delving hark] 来促进闪电网络通道状态从一个批次到另一个批次的（大部分）在线转移。hArk 需要 [CTV][topic op_checktemplateverify]、`OP_TEMPLATEHASH` 或类似的操作码。

  Vincenzo Palazzo [回复][delving ark poc]了他实现 Ark 通道工厂的概念验证代码。

- **<!--draft-bip-for-silent-payment-descriptors-->****静默支付描述符的 BIP 草案：** Craig Raw 在 Bitcoin-Dev 邮件列表上[发布][sp ml]了一份 [BIP][BIPs #2047] 草案提案，该提案为[静默支付][topic silent payments]定义了一个新的顶层描述符脚本表达式 `sp()`。根据 Raw 的说法，该描述符提供了一种在输出描述符框架内表示静默支付输出的标准化方式，使钱包能够使用现有的基于描述符的基础设施实现互操作性和恢复。

  `sp()` 表达式接受同一提案中定义的两种新密钥表达式之一作为参数：

  - `spscan1q..`：扫描私钥和花费公钥的 [bech32m][topic bech32] 编码，其中 `q` 字符表示静默支付版本 `0`。

  - `spspend1q..`：扫描私钥和花费私钥的 bech32m 编码，其中 `q` 字符表示静默支付版本 `0`。

  可选地，`sp()` 表达式可以接受 `BIRTHDAY` 作为输入参数，定义为一个正整数，表示应该开始扫描的区块高度（必须 > 842579，即 [BIP352][] 被合并的区块高度），以及零个或多个与钱包一起使用的整数 `LABEL`。

  `sp()` 生成的输出脚本是 BIP352 中指定的 [BIP341][] taproot 输出。

## 发布和候选发布

*热门比特币基础设施项目的新版本和候选发布版本。请考虑升级到新版本或帮助测试候选版本。*

- [Bitcoin Core 30.2rc1][] 是一个次要版本的候选发布版本，修复了（参见 [Bitcoin Core #34156](#bitcoin-core-34156)）在迁移未命名旧版钱包时可能意外删除整个 `wallets` 目录的漏洞（参见[上文](#bitcoin-core-wallet-migration-bug)）。

## 重要代码和文档变更

_本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。_

- [Bitcoin Core #34156][] 和 [Bitcoin Core #34215][] 修复了 30.0 和 30.1 版本中可能意外删除整个 `wallets` 目录的漏洞。当迁移旧版未命名钱包失败时，清理逻辑本应仅删除新创建的[描述符][topic descriptors]钱包目录。然而，由于未命名钱包直接位于顶层钱包目录中，整个目录都被删除了。第二个 PR 解决了 `wallettool` 的 `createfromdump` 命令（参见周报 [#45][news45 wallettool] 和 [#130][news130 createfrom]）在钱包名称为空字符串且转储文件包含校验和错误时的类似问题。这两个修复确保只删除新创建的钱包文件。

- [Bitcoin Core #34085][] 通过将 `FixLinearization()` 的功能集成到 `Linearize()` 中，消除了单独的 `FixLinearization()` 函数；`TxGraph` 现在推迟修复族群直到它们首次重新线性化。由于生成森林线性化（SFL）算法（参见[周报 #386][news386 sfl]）在加载现有线性化时有效地执行了类似的工作，因此减少了对 `PostLinearize` 的调用次数。这是[族群交易池][topic cluster mempool]项目的一部分。

- [Bitcoin Core #34197][] 从 `getpeerinfo` RPC 响应中移除了 `startingheight` 字段，实际上弃用了它。使用配置选项 `deprecatedrpc=startingheight` 可以在响应中保留该字段。`startingheight` 表示连接建立时对等节点自报的链顶高度。此弃用基于对等节点 `VERSION` 消息中报告的起始高度不可靠的考虑。该字段将在下一个主要版本中完全移除。

- [Bitcoin Core #33135][] 在使用包含 `older()` 值（指定[时间锁][topic timelocks]）的 [miniscript][topic miniscript] [描述符][topic descriptors]调用 `importdescriptors` 时添加警告，该值在 [BIP68][]（相对时间锁）和 [BIP112][]（OP_CSV）中没有共识意义。虽然某些协议（如闪电网络）故意使用非标准值来编码额外数据，但这种做法是有风险的，因为该值可能看起来有强时间锁，但实际上并没有延迟。

- [LDK #4213][] 设置了[盲化路径][topic rv routing]默认值：当构建不用于[要约][topic offers]上下文的盲化路径时，它旨在通过使用非紧凑盲化路径并将其填充到四跳（包括接收者）来最大化隐私。当盲化路径用于要约时，通过减少填充并尝试构建紧凑盲化路径来最小化字节大小。

- [Eclair #3217][] 为 [HTLC][topic htlc] 添加了问责信号，取代了实验性的 [HTLC 背书][topic htlc endorsement]信号。这与 [BOLTs #1280][] 中关于[通道阻塞][topic channel jamming attacks]缓解措施的最新规范更新保持一致。新提案将该信号视为稀缺资源的问责标志，表示使用了受保护的 HTLC 容量，并且下游对等节点可以为及时解决负责。

- [LND #10367][] 将 [BLIP4][] 中的实验性 `endorsement` 信号重命名为 `accountable`，以与 [BLIPs #67][] 中的最新提案保持一致，该提案基于提议的 [BOLTs #1280][]。

- [Rust Bitcoin #5450][] 向交易解码器添加验证，以拒绝包含 `null` prevout 的非 coinbase 交易，这是共识规则所要求的。

- [Rust Bitcoin #5434][] 向交易解码器添加验证，拒绝 `scriptSig` 长度超出 2-100 字节范围的 coinbase 交易。

{% include snippets/recap-ad.md when="2026-01-13 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2047,34156,34215,34085,34197,33135,4213,3217,1280,10367,67,5450,5434" %}
[rp delving ark cf]: https://delvingbitcoin.org/t/ark-as-a-channel-factory-compressed-liquidity-management-for-improved-payment-feasibility/2179
[news333 rp routing]: /zh/newsletters/2024/12/13/#insights-into-channel-depletion
[news359 rp balance]: /zh/newsletters/2025/06/20/#channel-rebalancing-research
[optech superscalar]: /en/podcast/2024/10/31/
[news169 jl tt]: /zh/newsletters/2021/10/06/#proposal-for-transaction-heritage-identifiers
[news270 jl cov]: /zh/newsletters/2023/09/27/#using-covenants-to-improve-ln-scalability
[delving ark hark]: https://delvingbitcoin.org/t/ark-as-a-channel-factory-compressed-liquidity-management-for-improved-payment-feasibility/2179/2
[delving ark poc]: https://delvingbitcoin.org/t/ark-as-a-channel-factory-compressed-liquidity-management-for-improved-payment-feasibility/2179/4
[sr delving hark]: https://delvingbitcoin.org/t/evolving-the-ark-protocol-using-ctv-and-csfs/1602
[bitcoin core notice]: https://bitcoincore.org/en/2026/01/05/wallet-migration-bug/
[Bitcoin Core 30.2rc1]: https://bitcoincore.org/bin/bitcoin-core-30.2/test.rc1/
[news45 wallettool]: /zh/newsletters/2019/05/07/#new-wallet-tool
[news130 createfrom]: /zh/newsletters/2021/01/06/#bitcoin-core-19137-adds-dump-and-createfromdump-commands-to-wallet-tool
[news386 sfl]: /zh/newsletters/2026/01/02/#bitcoin-core-32545
[sp ml]:https://groups.google.com/g/bitcoindev/c/bP6ktUyCOJI
