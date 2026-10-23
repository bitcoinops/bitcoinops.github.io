---
title: 'Bitcoin Optech Newsletter #171'
permalink: /zh/newsletters/2021/10/20/
name: 2021-10-20-newsletter-zh
slug: 2021-10-20-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本期 Newsletter 概述了关于向频繁离线的 LN 节点支付的讨论帖，描述了旨在降低 LN 支付路径探测成本、让某些攻击变得更昂贵的提案集，并提供了在 signet 和 testnet 上创建 taproot 交易的操作指南链接。同时包含常规栏目：近期客户端与服务变更、新版本与候选发布，以及主流比特币基础设施软件的值得注意的变更。

## 新闻

- **<!--paying-offline-ln-nodes-->****向离线 LN 节点支付：** Matt Corallo 在 Lightning-Dev 邮件列表发起了一个[讨论帖][corallo mobile]，集思广益探讨如何让频繁离线的 LN 节点（例如移动设备上的节点）无需托管方案、也无需长期锁定通道流动性即可接收支付。Corallo 认为，一旦 LN [升级][zmn taproot]支持 [PTLCs][topic ptlc]，就可以借助不可信的第三方得到相当不错的解决方案；但他同时也在征集其他替代方案的建议，这些方案甚至可以赶在 PTLC 支持加入之前部署。

- **<!--lowering-the-cost-of-probing-to-make-attacks-more-expensive-->****降低探测成本，让攻击更昂贵：** 相隔几周，开发者 ZmnSCPxj 和 Joost Jager 各自提出了[大体相似][zmn prop]的[提案][jager prop]，要取消探测支付路径时必须锁定资金这一要求。两份提案都把这一点当作给网络引入预付费路由费（upfront routing fees）的第一步——即使支付尝试失败，这笔费用也要让付款方掏钱。预付费是针对[通道堵塞攻击][topic channel jamming attacks]的建议缓解措施之一。

  目前，LN 节点可以发送必定会失败的支付来探测支付路径。例如，Alice 生成一个 [HTLC][topic htlc]，它支付的原像无人知晓，再让这笔支付经 Bob 和 Charlie 路由到 Zed。由于 Zed 不知道这个支付原像，尽管这笔支付表明他本应是最终接收方，他也只能拒绝它。如果 Alice 收到 Zed 节点的拒绝消息，她就知道 Bob 和 Charlie 在各自通道里的资金足以支付给 Zed，于是她可以立刻针对 Zed 的拒绝发送一笔真正有很大成功概率的支付（唯一与流动性有关的失败原因，就是 Bob 或 Charlie 的余额在此期间发生了变化）。对 Alice 来说，先用一个必定失败的探测，好处在于她可以并行探测多条路径，并采用最先成功的那条，从而缩短整体支付时间。主要缺点是，每次探测都会暂时锁定属于 Alice 以及 Bob、Charlie 这类中间节点的资金；如果 Alice 并行探测好几条长路径，很容易就锁定高达支付金额 100 倍甚至更多的资金。次要缺点是，这类支付路径探测有时会导致不必要的单边通道关闭，以及由此产生的链上手续费。

  ZmnSCPxj 和 Jager 提议允许发送一条特殊的探测消息，无需使用 HTLC、无需临时锁定比特币，也不必冒通道失败的风险。这条消息基本上可以免费发送，不过 ZmnSCPxj 的提案确实建议了一些缓解措施，以避免拒绝服务洪泛攻击。

  如果免费探测真的能让付款节点找到在大多数时候都可靠的路径，ZmnSCPxj 和 Jager 认为，开发者和用户就不该那么抵触支付预付费——这种费用只在支付失败的少数情况下才会让用户付出代价。诚实用户偶尔付出的小额成本，对于实施大规模堵塞攻击的恶意节点来说会变成一笔巨大的必然成本，从而降低这类攻击发生的风险（并且，如果持续攻击真的发生，也能补偿路由节点运营商为改善网络而投入的额外资金）。

  截至撰稿时，这个想法获得的讨论并不多。

- **<!--testing-taproot-->****测试 taproot：** 针对 Bitcoin-Dev 邮件列表上的一个[请求][schildbach taproot wallet]，Anthony Towns 提供了[分步指南][towns taproot wallet]，说明如何在 [signet][topic signet] 或 testnet 上用 Bitcoin Core 创建一个 [bech32m][topic bech32] 地址来做测试。对测试 taproot 的开发者来说，这些说明可能比 Optech [此前提供][p4tr signet]的更好用。

## 服务和客户端软件的变更

*在本月栏目中，我们重点介绍 Bitcoin 钱包与服务的一些有趣更新。*

- **<!--zeus-wallet-adds-ln-features-->****Zeus 钱包新增 LN 功能：**
  移动端比特币与闪电网络钱包 Zeus 在 [v0.6.0-alpha3][zeus v0.6.0-alpha3] 版本中，进一步支持了[原子化多路径支付（AMP）][topic amp]、[Lightning Address][news167 lightning addresses]和[币控制][topic coin selection]等功能。

- **<!--sparrow-adds-coinjoin-support-->****Sparrow 新增 coinjoin 支持：**
  [Sparrow 1.5.0][] 通过与 Samourai 的 [Whirlpool][whirlpool] 集成，新增 [coinjoin][topic coinjoin] 功能。

- **<!--joinmarket-fixes-a-critical-bug-for-makers-and-adds-rbf-support-->****JoinMarket 修复做市商的关键漏洞并支持 RBF：**
  [JoinMarket 0.9.3][joinmarket 0.9.3] 修复了一个影响做市商的关键漏洞，建议所有做市商升级。0.9.2 版本还默认在 UI 中使用[忠诚债券][news161 fidelity bonds]，并支持对非 coinjoin 交易使用[手续费替换（RBF）][topic rbf]。

- **<!--coldcard-supports-descriptor-based-wallets-->****Coldcard 支持描述符钱包：**
  [Coldcard 4.1.3][coldcard 4.1.3] 现在支持 Bitcoin Core 中的 `importdescriptors`，从而可以在 Bitcoin Core 中使用[输出脚本描述符（descriptor）][topic descriptors]钱包与[部分签名比特币交易（PSBT）][topic psbt]工作流。

- **<!--simple-bitcoin-wallet-adds-cpfp-rbf-hold-invoices-->****Simple Bitcoin Wallet 新增 CPFP、RBF 和挂起发票：**
  Simple Bitcoin Wallet（即原 Bitcoin Lightning Wallet）在 2.2.14 版本中新增了[子为父付（CPFP）][topic cpfp] 和 RBF（手续费追加与取消）功能，并在 [2.2.15][slw 2.2.15] 中支持[挂起发票（hold invoice）][topic hold invoices]。

- **<!--electrs-0-9-0-released-->****Electrs 0.9.0 发布：**
  [Electrs 0.9.0][] 现在改用比特币的 P2P 协议，而不再从磁盘或 JSON RPC 读取区块。升级细节请参阅[升级指南][Electrs 0.9.0 upgrading guide]。

## 准备 Taproot #18：冷知识

*本[系列][series preparing for taproot]每周一篇，讨论开发者和服务提供商如何为 taproot 即将在区块高度 {{site.trb}} 激活做好准备。*

{% include specials/taproot/zh/18-trivia.md %}

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [BDK 0.12.0][] 新增 Sqlite 数据存储支持及其他改进。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]的值得注意的变更。*

<!-- we wouldn't normally cover a small code comment like this, but it
seems worth publicizing the decision to use this value -->
- [Bitcoin Core #22863][] 记录了一项决定：P2TR 输出与 P2WPKH 输出采用相同的最小输出金额（“粉尘金额”）294 sat。之所以在花费 P2TR 输出比花费 P2WPKH 输出更省的情况下仍这样做，是因为一些开发者[反对][bitcoin core #22779]此时降低粉尘限额。

- [Bitcoin Core #23093][] 新增 `newkeypool` RPC 方法，会把钱包中所有预生成的地址都标记为已使用，从而生成一组新地址。多数用户永远用不到它，但当用户从较旧的非 [BIP32][] 钱包升级到使用 [HD 密钥生成][topic bip32] 时，这一行为会在后台被用到。

- [Bitcoin Core #22539][] 在生成手续费估算时，会把本地节点看到的替换交易一并考虑进来。在替换交易还很罕见的年代，此前[并未考虑][bitcoin core #9519]这些交易；但如今约有 20% 的交易会发出 [BIP125][] 的自愿启用替换信号，[典型的一天][0xb10c stats]会发生数千次替换。

- [Eclair #1985][] 新增 `max-exposure-satoshis` 配置项，允许用户设置当通道因存在未处理的[不经济支付][topic uneconomical outputs]而被强制关闭时，自己愿意捐给矿工的最大金额。更多信息请参见[上周 Newsletter][news170 ln cve] 中对 CVE-2021-41591 的描述。

- [Rust-Lightning #1124][] 扩展了 `get_route` API，使其可以传入一个额外参数，用来避免重复使用此前失败的路径。计划中的其他改动会让人们更容易利用以往路由的成功与失败经验，来提升后续结果的质量。

- [BOLTs #894][] 在规范中添加了一些建议的检查。各实现可以采纳这些检查，以避免在路由链上不经济的支付时把多余的比特币当作矿工手续费捐出去。若缺少这些检查会出现哪些问题，详见[上周 Newsletter][news170 ln cve]。

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
