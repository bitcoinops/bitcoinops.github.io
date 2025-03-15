---
title: 'Bitcoin Optech Newsletter #171'
permalink: /zh/newsletters/2021/10/20/
name: 2021-10-20-newsletter-zh
slug: 2021-10-20-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报概述了关于向频繁离线的闪电网络（LN）节点支付的讨论主题，描述了旨在降低闪电网络支付路径探测成本以提高特定攻击实施成本的提案集，并提供了在 signet 和 testnet 上创建 Taproot 交易的操作指南链接。同时包含常规栏目：近期客户端和服务更新、新版本与候选版本发布，以及主流比特币基础设施软件的显著变更。


## 新闻

- ​**<!--paying-offline-ln-nodes-->****向离线闪电网络节点支付：​** Matt Corallo 在 Lightning-Dev 邮件列表发起了一个[讨论][corallo mobile]，探讨如何让频繁离线的闪电网络节点（例如移动设备上的节点）无需托管方案或长期锁定通道流动性即可接收支付。Corallo 认为一旦闪电网络[升级][zmn taproot]支持 [PTLCs][topic ptlc]，即可通过不可信第三方实现合理解决方案，但他也在寻求其他替代方案建议，以在 PTLC 支持之前部署。

- ​**<!--lowering-the-cost-of-probing-to-make-attacks-more-expensive-->****通过降低探测成本提高攻击成本：​** 开发者 ZmnSCPxj 和 Joost Jager 在几周内分别提出了[相似][zmn prop]的[提案][jager prop]，旨在消除支付路径探测需要锁定资金的要求。两项提案均建议将此作为添加预支付路由费（upfront routing fees）的第一步——即使支付失败也会产生费用。预付费是应对[通道阻塞攻击][topic channel jamming attacks]的缓解措施之一。

  当前闪电网络节点可通过发送必然失败的支付来探测路径。例如 Alice 生成一个使用未知原像的 [HTLC][topic htlc]，通过 Bob 和 Charlie 路由至 Zed。由于 Zed 未知原像，即使作为最终接收方也必须拒绝该支付。若 Alice 收到 Zed 节点的拒绝信息，则说明 Bob 和 Charlie 的通道有足够资金向 Zed 支付，从而可立即发送实际支付（失败仅可能因流动性变化）。Alice 使用必然失败的探测支付优势在于可并行探测多条路径并使用最先成功的路径，减少整体支付时间。主要缺点在于每次探测会暂时锁定 Alice 和中继节点（如 Bob 和 Charlie）的资金——并行探测长路径可能锁定支付金额的 100 倍以上。次要缺点是此类探测可能导致不必要的单边通道关闭及链上费用。

  ZmnSCPxj 和 Jager 提议允许发送无需 HTLC、临时锁定比特币或引发通道关闭的特殊探测消息。该消息基本可免费发送（ZmnSCPxj 的提案包含防 DoS 洪泛攻击措施）。

  若免费探测确实能帮助节点找到高可靠路径，两位提案者认为开发者和用户应更愿意接受预付费机制（支付失败时产生小额成本）。这种诚实用户偶尔的小额成本将成为恶意节点大规模阻塞攻击的巨额成本，从而降低攻击风险（并为路由节点运营商在遭受持续攻击时部署额外资金提供补偿）。

  截至发稿时，该提案已引发适度讨论。

- ​**<!--testing-taproot-->****测试 Taproot：​** 针对 Bitcoin-Dev 邮件列表的[请求][schildbach taproot wallet]，Anthony Towns 提供了在 Bitcoin Core 上为 [signet][topic signet] 或 testnet 创建 [bech32m][topic bech32] 地址的[分步指南][towns taproot wallet]。该指南可能比 Optech [此前提供][p4tr signet]的更适合开发者测试 taproot。

## 服务和客户端软件的更改

*本栏目每月精选比特币钱包和服务的有趣更新。*

- ​**<!--zeus-wallet-adds-ln-features-->**​**Zeus 钱包新增闪电网络功能：​**
  移动端比特币和闪电网络钱包 Zeus 在 [v0.6.0-alpha3][zeus v0.6.0-alpha3] 版本中新增对[原子化多路径支付（AMP）][topic amp]、[闪电网络地址][news167 lightning addresses]和[币控制][topic coin selection]功能的支持。

- ​**<!--sparrow-adds-coinjoin-support-->**​**Sparrow 新增 Coinjoin 支持：​**
  [Sparrow 1.5.0][] 通过集成 Samourai 的 [Whirlpool][whirlpool] 新增 [Coinjoin][topic coinjoin] 功能。

- ​**<!--joinmarket-fixes-a-critical-bug-for-makers-and-adds-rbf-support-->**​**JoinMarket 修复做市商关键漏洞并支持 RBF：​**
  [JoinMarket 0.9.3][joinmarket 0.9.3] 修复了做市商的关键漏洞，建议所有做市商升级。0.9.2 版本默认在 UI 中使用[保真债券][news161 fidelity bonds]并支持对非 Coinjoin 交易使用 [RBF（费用替换）][topic rbf]。

- ​**<!--coldcard-supports-descriptor-based-wallets-->**​**Coldcard 支持描述符钱包：​**
  [Coldcard 4.1.3][coldcard 4.1.3] 现支持 Bitcoin Core 的 `importdescriptors` 命令，实现了[描述符][topic descriptors]钱包和基于 [PSBT][topic psbt] 的工作流。

- ​**<!--simple-bitcoin-wallet-adds-cpfp-rbf-hold-invoices-->**​**Simple Bitcoin Wallet 新增 CPFP、RBF 和 hold invoices：​**
  Simple Bitcoin Wallet（原 Bitcoin Lightning Wallet）在 2.2.14 版本新增 [CPFP][topic cpfp] 和 RBF（手续费提升与取消）功能，并在 [2.2.15][slw 2.2.15] 版本支持 [hold invoices][topic hold invoices]。

- ​**<!--electrs-0-9-0-released-->**​**Electrs 0.9.0 发布：​**
  [Electrs 0.9.0][] 现改用比特币 P2P 协议替代从磁盘或 JSON RPC 读取区块。用户升级时请参考[升级指南][Electrs 0.9.0 upgrading guide]。

## 准备 Taproot #18：琐事

*每周[系列][series preparing for taproot]，介绍开发者和服务提供商如何为即将在区块高度 {{site.trb}} 激活的 taproot 做准备。*

{% include specials/taproot/zh/18-trivia.md %}

## 发布与候选发布

*热门比特币基础设施项目的新版本和候选版本。请考虑升级至新版本或协助测试候选版本。*

- [BDK 0.12.0][] 新增 Sqlite 数据存储支持及其他改进。

## 值得注意的代码和文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案 (BIPs)][bips repo]和[闪电网络规范（BOLTs）][bolts repo]的显著变更。*

- [Bitcoin Core #22863][] 记录了对 P2TR 输出采用与 P2WPKH 输出相同的最小输出金额（"粉尘金额"）294 sat 的决策。尽管花费 P2TR 输出成本更低，但部分开发者[反对][bitcoin core #22779]此时降低粉尘限额。

- [Bitcoin Core #23093][] 新增 `newkeypool` RPC 方法，可将所有预生成地址标记为已使用并生成新地址集。多数用户无需此功能，但该行为会在用户从非 [BIP32][] 钱包升级至 [HD 密钥生成][topic bip32] 时在后台使用。

- [Bitcoin Core #22539][] 将本地节点观察到的替换交易纳入手续费估算。此前因替换交易较少而[未予考虑][bitcoin core #9519]，但目前约 20% 的交易发送 [BIP125][] 替换信号，[日均][0xb10c stats]发生数千次替换。

- [Eclair #1985][] 新增 `max-exposure-satoshis` 配置项，允许用户设置当通道因未解决的[不经济输出][topic uneconomical outputs]被迫关闭时，愿意捐赠给矿工的最大金额。详情参见[上周周报][news170 ln cve]中关于 CVE-2021-41591 的描述。

- [Rust-Lightning #1124][] 扩展了 `get_route` API，新增可避免重用失败路径的参数。后续改进将利用历史路由成功率提升路径质量。

- [BOLTs #894][] 在规范中添加建议检查项。实现这些检查可防止在路由非经济链上支付时向矿工超额捐赠手续费。详见[上周周报][news170 ln cve]关于未实施检查可能引发的问题。


{% include references.md %}
{% include linkers/issues.md issues="22863,23093,22539,4567,1985,1124,894,22779,9519" %}
[corallo mobile]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-October/003307.html
[zmn taproot]: /zh/preparing-for-taproot/#使用-taproot-的闪电网络
[zmn prop]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-September/003256.html
[jager prop]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-October/003314.html
[schildbach taproot wallet]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-October/019532.html
[towns taproot wallet]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-October/019543.html
[p4tr signet]: /zh/preparing-for-taproot/#在-signet-上测试
[news170 ln cve]: /zh/newsletters/2021/10/13/#ln-spend-to-fees-cve
[BDK 0.12.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.12.0
[0xb10c stats]: https://github.com/bitcoin/bitcoin/pull/22539#issuecomment-885763670
[zeus v0.6.0-alpha3]: https://github.com/ZeusLN/zeus/releases/tag/v0.6.0-alpha3
[news167 lightning addresses]: /zh/newsletters/2021/09/22/#lightning-address-identifiers-announced
[sparrow 1.5.0]: https://github.com/sparrowwallet/sparrow/releases/tag/1.5.0
[whirlpool]: https://bitcoiner.guide/whirlpool/
[news161 fidelity bonds]: /zh/newsletters/2021/08/11/#implementation-of-fidelity-bonds
[joinmarket 0.9.3]: https://github.com/JoinMarket-Org/joinmarket-clientserver/releases/tag/v0.9.3
[coldcard 4.1.3]: https://blog.coinkite.com/version-4.1.3-released/
[slw 2.2.15]: https://github.com/btcontract/wallet/releases/tag/2.2.15
[Electrs 0.9.0]: https://github.com/romanz/electrs/releases/tag/v0.9.0
[Electrs 0.9.0 upgrading guide]: https://github.com/romanz/electrs/blob/master/doc/usage.md#important-changes-from-versions-older-than-090
[series preparing for taproot]: /zh/preparing-for-taproot/
