---
title: 'Bitcoin Optech Newsletter #317'
permalink: /zh/newsletters/2024/08/23/
name: 2024-08-23-newsletter-zh
slug: 2024-08-23-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报总结了有关反渗透协议的讨论，该协议只需在钱包和签名设备之间进行一轮往返通信。此外还有我们的常规部分：服务和客户端的更新，新版本和候选版本的公告，以及对热门比特币基础设施项目的重大变更介绍。

## 新闻

- **<!--simple(but imperfect)-anti-exfiltration-protocol-->简单（但不完美）的反渗透协议：** 开发者 Moonsettler 在 Delving Bitcoin 上[发布了][moonsettler exfil1]一篇描述[反渗透][topic exfiltration-resistant signing]协议的文章。相似的协议之前也有提到过(见周报[#87][news87 exfil]和[#88][news88 exfil])，其中 Pieter Wuille [引用了][wuille exfil1] Gregory Maxwell 在[2014年发布的][maxwell exfil]已知首次描述反渗透技术的帖子。

  该协议使用了签署到合约（sign-to-contract）协议，允许软件钱包向硬件签名设备选择的 nonce 贡献熵，从而使软件钱包可以在稍后验证这些熵是否被使用。签署到合约是[支付到合约（pay-to-contract）][topic p2c]的变体：在支付到合约中，接收方的公钥会被调整；而在签署到合约中，支出方的签名 nonce 会被调整。

  与在 BitBox02 和 Jade 硬件签名设备上实现的协议相比(见[周报#136][news136 exfil])，该协议的优势在于只需钱包和硬件签名设备之间进行一轮往返通信。这一轮往返可以与单签名或脚本多签名交易所需的其他步骤相结合，这意味着该技术不会影响用户的工作流程。当前部署的技术同样基于“签署到合约”，但需要两轮往返通信；对于今天的大多数用户来说，这已经超过了所需的次数，尽管对于那些升级到使用[无脚本多重签名][topic multisignature]和[无脚本门限签名][topic threshold signature]，可能本身就需要多次往返通信。对于那些直接将签名设备连接到计算机或使用像蓝牙这样的交互式无线通信协议的用户来说，往返次数并不重要。但对于那些希望保持设备气隙隔离（airgapped）的用户来说，每次往返都需要手动干预两次————当频繁签名或使用多个设备进行脚本多签名时，这很快会变得令人烦恼。

  该协议的缺点在 Maxwell 的原始描述中提到，“它留下一条通过研磨的[旁路][topic side channels]，这种旁路的成本随着每一额外比特的增加呈指数级增长[...]但它消除了在单个签名中泄露所有内容的明显且非常强大的攻击。这显然不太好，但它只是一个两步协议，因此许多不会考虑使用对策的地方可以将其作为协议规范的一部分免费采用。”

  该协议明显优于不使用任何反渗透措施的情况，Pieter Wuille [指出][wuille exfil2]，这可能是单轮签名中最好的反渗透措施。然而，Wuille 建议使用已经部署的两轮反渗透协议，以防止即使是基于研磨的渗透。

  撰写本文时，讨论仍在进行中。

## 服务和客户端软件变更

*在这个月度栏目中，我们会标出比特币钱包和服务的有趣更新。*

- **<!--proton-wallet-announced-->****Proton Wallet 宣布：**
  Proton [宣布][proton blog]其[开源][proton github]的 Proton Wallet，支持多个钱包、[bech32][topic bech32]、[批量][topic payment batching]发送、[BIP39][]助记词和与其电子邮件服务的集成。

- **<!--cpunet-testnet-announced-->****CPUNet testnet 宣布：**
  来自 [braidpool][braidpool github] 矿[池][topic pooled mining]项目的贡献者[宣布了][cpunet post] [CPUNet][cpunet github] testnet。CPUNet 使用经过修改的工作量证明算法，旨在排除 ASIC 矿工，以实现比 [testnet][topic testnet] 更一致的区块率。

- **<!--lightning.pub-launches-->****Lightning.Pub 启动：**
  [Lightning.Pub][lightningpub github] 为 LND 提供节点管理功能，允许共享访问和协调通道流动性，使用 nostr 进行加密通信和基于密钥的账户身份验证。

- **<!--taproot-assets-v0.4.0-alpha-released-->****Taproot Assets v0.4.0-alpha 发布：**
  [v0.4.0-alpha][taproot assets v0.4.0] 版本支持在主网上使用 [Taproot Assets][topic client-side validation]协议进行链上资产发行、使用 [PSBT][topic psbt] 进行原子互换以及通过闪电网络路由资产。

- **<!--stratum v2-benchmarking-tool-released-->****Stratum v2 基准测试工具发布：**
  初始 [0.1.0 版本][sbm 0.1.0]支持在不同的挖矿场景中测试、报告和比较 Stratum v1 和 Stratum v2[协议][topic pooled mining]的性能。

- **<!--stark-verification-poc-on-signet-->****STARK 验证 PoC 在 signet 上运行：**
  StarkWare [宣布][starkware tweet]在 [signet][topic signet] 测试网络上使用 [OP_CAT][topic op_cat] 操作码验证了一个零知识证明的 [STARK 验证器][bcs github](见 [周报#304][news304 inquisition])。

- **<!--seedsigner-0.8.0-released-->****SeedSigner 0.8.0 发布：**
  比特币硬件签名设备项目 [SeedSigner][seedsigner website] 在[0.8.0][seedsigner 0.8.0]版本中增加了 P2PKH 和 P2SH 多重签名的签名功能，增加了对 [PSBT][topic psbt]的支持，并默认启用了[taproot][topic taproot] 支持。

- **<!--floresta-0.6.0-released-->****Floresta 0.6.0 发布：**
  在[0.6.0][floresta 0.6.0]版本中，Floresta 增加了对[致密区块过滤器][topic compact block filters]、signet 上的欺诈证明以及 [`florestad`][floresta blog]（一个可供现有钱包或客户端应用程序集成的守护进程）的支持。

## 版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Core Lightning 24.08rc2][] 是这种热门的 LN 节点实现的下一个主要版本的候选版本。

- [LND v0.18.3-beta.rc1][] 是这种热门的 LN 节点实现的一个次要错误修复版本的候选版本。

## 重大的代码和文档变更

_本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。_

- [Bitcoin Core #28553][] 为主网区块 840,000 添加了 [assumeUTXO][topic assumeutxo] 快照参数：其区块哈希、到该区块的交易数量以及到该区块的 UTXO 集合的序列化 SHA256 哈希。这是在多个贡献者进行测试之后进行的，测试表明，他们可以使用预期的 SHA256 校验和生成相同的[快照文件][snapshot file]，并且在加载时，快照工作良好。

- [Bitcoin Core #30246][] 为 `asmap-tool` 实用程序引入了 `diff_addrs` 子命令，允许用户比较两个[自治系统][auto sys] (ASMaps)映射并计算有多少节点网络地址已重新分配到不同的自治系统编号(ASN)。这种功能量化了 ASMap 随时间的退化，这是最终在 Bitcoin Core 版本中发布预计算 ASMap 的重要一步，并进一步增强 Bitcoin Core 抵御[日蚀攻击][topic eclipse attacks]的能力。见周报[#290][news290 asmap]。

- [Bitcoin Core GUI #824][] 将 `Migrate Wallet` 菜单项从单个操作更改为菜单列表，允许用户迁移钱包目录中的任何传统钱包，包括不可加载的钱包。此更改为可能的未来做准备，即传统钱包可能无法再在 Bitcoin Core 中加载，[描述符][topic descriptors]钱包将成为默认值。在选择要迁移的钱包时，GUI 会提示用户输入钱包的密码（如果有的话）。

- [Core Lightning #7540][] 通过在 `renepay` 插件中(见周报[#263][news263 renepay])添加一个常数乘数，改进了计算通过通道成功路由的概率的公式，该常数乘数表示网络中随机选择的通道至少能够转发 1 msat 的概率。默认值设置为 0.98，但在进一步测试后可能会更改。

- [Core Lightning #7403][] 向 `renepay` 插件添加了通道过滤支付修改器，禁用具有非常低 `max_htlc` 的通道。这可以在将来扩展以过滤掉由于其他原因（例如高基本费用、低容量和高延迟）不理想的通道。此外，还添加了一个新的 `exclude` 命令行选项，以手动禁用节点或通道。

- [LND #8943][] 向代码库引入了 [Alloy][alloy model] 模型，从一个初始的 Alloy 模型开始，用于[线性费用函数][lnd linear]费用提升机制，其灵感来自于修复漏洞的[LND #8751][]。Alloy 提供了一种轻量级的形式方法，用于验证系统组件的正确性，从而更容易在初始实现过程中发现错误。Alloy 没有像成熟的形式化方法那样试图证明模型总是正确的，而是对一组有界参数和迭代的输入进行操作，并试图找到给定断言的反例，并伴随着一个漂亮的可视化工具。模型还可用于指定 P2P 系统中的协议，因此特别适合闪电网络。

- [BDK #1478][] 对 `bdk_chain` 的 `FullScanRequest` 和 `SyncRequest` 请求结构进行了多项更改：使用生成器模式将请求的构建与消化分离，使 `chain_tip` 参数可选，以允许用户选择不更新 `LocalChain`(对于那些使用 `bdk_esplora` 而不使用 `LocalChain` 的用户非常有用)，并改进了检查同步进度的人机工程学。此外，`bdk_esplora` crate 进行了优化，通过始终将先前的交易输出添加到 `TxGraph` 更新中，并通过使用 `/tx/:txid` 端点减少 API 调用次数。

- [BDK #1533][] 通过添加 `Wallet::create_single` 方法启用了对单一[描述符][topic descriptors]钱包的支持，撤销了之前的更新，该更新曾要求 `Wallet` 结构需要一个内部的(找零)描述符。之前更改的原因是为了在依赖公共 Electrum 或 Esplora 服务器时保护用户的找零地址隐私，但现在为了包含所有用例，决定撤销这一更改。

- [BOLTs #1182][] 改进了[BOLT4][]规范中[路径盲化][topic rv routing]和[洋葱消息][topic onion messages]部分的清晰度和完整性，具体更改如下：将路径盲化部分上移一级以强调其在支付中的适用性(而不仅仅是洋葱消息)，提供了更多 `blinded_path` 类型及其要求的具体细节，扩展了编写者责任的描述，将读者部分拆分为 `blinded_path` 和 `encrypted_recipient_data` 的独立部分，改进了 `blinded_path` 的概念解释，增加了使用虚拟跳点的建议，将 `onionmsg_hop` 重命名为 `blinded_path_hop`，并做了其他澄清性更改。

- [BLIPs #39][] 为[BOLT11][] 发票添加了 [BLIP39][]，用于传达支付接收者节点[盲化路径][topic rv routing]的可选字段 `b`。此功能已在 LND 中实现(见周报[#315][news315 blinded])，旨在在全网广泛部署[要约（offers）][topic offers]协议之前使用。

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28553,30246,824,7540,7403,8943,1478,1533,1182,39,8751" %}
[Core Lightning 24.08rc2]: https://github.com/ElementsProject/lightning/releases/tag/v24.08rc2
[LND v0.18.3-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.3-beta.rc1
[moonsettler exfil1]: https://delvingbitcoin.org/t/non-interactive-anti-exfil-airgap-compatible/1081
[wuille exfil1]: https://delvingbitcoin.org/t/non-interactive-anti-exfil-airgap-compatible/1081/3
[wuille exfil2]: https://delvingbitcoin.org/t/non-interactive-anti-exfil-airgap-compatible/1081/7
[news87 exfil]: /en/newsletters/2020/03/04/#proposal-to-standardize-an-exfiltration-resistant-nonce-protocol
[news88 exfil]: /en/newsletters/2020/03/11/#exfiltration-resistant-nonce-protocols
[maxwell exfil]: https://bitcointalk.org/index.php?topic=893898.msg9861102#msg9861102
[news136 exfil]: /en/newsletters/2021/02/17/#anti-exfiltration
[proton blog]: https://proton.me/blog/proton-wallet-launch
[proton github]: https://github.com/protonwallet/
[braidpool github]: https://github.com/braidpool/braidpool
[cpunet post]: https://x.com/BobMcElrath/status/1823370268728873411
[cpunet github]: https://github.com/braidpool/bitcoin/blob/cpunet/contrib/cpunet/README.md
[lightningpub github]: https://github.com/shocknet/Lightning.Pub
[taproot assets v0.4.0]: https://github.com/lightninglabs/taproot-assets/releases/tag/v0.4.0
[sbm 0.1.0]: https://github.com/stratum-mining/benchmarking-tool/releases/tag/0.1.0
[starkware tweet]: https://x.com/StarkWareLtd/status/1813929304209723700
[bcs github]: https://github.com/Bitcoin-Wildlife-Sanctuary/bitcoin-circle-stark
[news304 inquisition]: /zh/newsletters/2024/05/24/#bitcoin-inquisition-27-0
[seedsigner website]: https://seedsigner.com/
[seedsigner 0.8.0]: https://github.com/SeedSigner/seedsigner/releases/tag/0.8.0
[floresta 0.6.0]: https://github.com/vinteumorg/Floresta/releases/tag/0.6.0
[floresta blog]: https://medium.com/vinteum-org/floresta-update-simplifying-bitcoin-node-integration-for-wallets-6886ea7c975c
[auto sys]: https://en.wikipedia.org/wiki/Autonomous_system_(Internet)
[news290 asmap]: /zh/newsletters/2024/02/21/#improved-reproducible-asmap-creation-process-asmap
[news263 renepay]: /zh/newsletters/2023/08/09/#core-lightning-6376
[alloy model]: https://alloytools.org/about.html
[lnd linear]: https://github.com/lightningnetwork/lnd/blob/b7c59b36a74975c4e710a02ea42959053735402e/sweep/fee_function.go#L66-L109
[news315 blinded]: /zh/newsletters/2024/08/09/#lnd-8735
[snapshot file]: magnet:?xt=urn:btih:596c26cc709e213fdfec997183ff67067241440c&dn=utxo-840000.dat&tr=udp%3A%2F%2Ftracker.bitcoin.sprovoost.nl%3A6969
