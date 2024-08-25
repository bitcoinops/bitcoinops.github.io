---
title: 'Bitcoin Optech Newsletter #52'
permalink: /zh/newsletters/2019/06/26/
name: 2019-06-26-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
slug: 2019-06-26-newsletter-zh
---
本周的 Newsletter 宣布了即将披露的旧版本 Bitcoin Core 中的轻微漏洞，建议继续测试闪电网络（LN）软件的候选版本（RC），并描述了一种使 Bitcoin Core 节点更能抵抗 eclipse 攻击的提议。此外，还包括了关于 bech32 发送支持、热门的 Stack Exchange 话题以及值得注意的比特币基础设施项目更改的常规部分。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- **<!--update-bitcoin-core-to-at-least-0-17-1-->****将 Bitcoin Core 更新至至少 0.17.1 版本：**两个影响旧版本 Bitcoin Core 的轻微漏洞预计将在 8 月 1 日左右被披露。这两个漏洞都不影响 0.17.1 版本（2018 年 12 月 25 日发布）或之后的版本。我们对 Bitcoin Core 贡献者 practicalswift 提供漏洞报告表示感谢。

- **<!--help-test-c-lightning-and-lnd-rcs-->****帮助测试 C-Lightning 和 LND 的候选版本：**[C-Lightning][cl rc] 和 [LND][lnd rc] 都在为其下一个版本测试候选版本（RC）。鼓励有经验的用户帮助测试这些 RC，以便在最终发布前识别并修复任何剩余的错误。

## 新闻

- **<!--differentiating-peers-based-on-asn-instead-of-address-prefix-->****基于 ASN 而非地址前缀来区分节点：**一场 [eclipse 攻击][eclipse attack]会阻止全节点与任何一个诚实节点建立连接，从而使攻击者能够防止该节点了解拥有最多工作量证明的区块链或广播时间敏感的交易。为了帮助防止 eclipse 攻击，Bitcoin Core 全节点通常会将其八个外发连接分配给 IP 地址在前 16 位（即 /16）上不同的节点。许多 ISP 仅在少数不同的 /16 范围内拥有 IP 地址，或者将地址分配给客户的方式使得客户难以选择他们获得的前缀，这使得攻击者更难获得大量多样化的 IP 地址来执行 eclipse 攻击。

  然而，一些大型 ISP，如云计算运营商，管理着多个使用不同 IP 范围的设施，这使得客户更容易获得来自多个前缀的地址。对此问题的一个可能解决方案是跟踪哪些 IP 地址由哪些 ISP 控制，然后将节点的外发连接按 ISP 分配，而不论它们使用什么地址。例如，这可能能够将所有来自 Amazon AWS 的 IP 地址分组在一起，无论客户使用哪个区域的服务器。

  ISP 到 IP 地址的信息可以从整个互联网的路由表中获得。不幸的是，这些表的大小超过 1 GB——对于全节点来说，实在太大而无法实用地包含在内。Pieter Wuille 正在研究一种紧凑的编码方式，只包含识别不同 ISP 所需的信息（使用 ISP 的自治系统编号，ASN）。Wuille 的表将额外的存储需求减少到约 1 MB。在本周的 Bitcoin Core 开发者 [IRC 会议][core dev meeting] 上，Wuille 和 Matt Corallo 询问 1 MB 的额外数据是否足够小，可以随 Bitcoin Core 一起分发，以改善其确保与不同网络上的节点连接的能力。会议参与者表示支持这一想法，并花时间讨论了一些实现细节。基于这些反馈，我们预计这一想法会有进一步的发展。

## Bech32 发送支持

*关于允许您支付的对象访问 Segwit 所有优势的[系列][bech32 series]的第 15 周。*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/zh/15-data-entry.md %}

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者们寻找问题答案的首选之地——或者当我们有空闲时间帮助好奇或困惑的用户时。在这个每月特色中，我们会重点介绍自上次更新以来一些投票数最高的问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{%
endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--how-can-i-mitigate-concerns-around-the-gap-limit-->**[如何缓解关于间隔限制的担忧？]({{bse}}88128) Enrique 询问使用 HD 钱包并超过地址间隔限制时的潜在资金损失。Andrew Chow 和 Bitcoin Holder 解释说，虽然超过间隔限制不会导致资金损失，但在从备份恢复或生成钱包外的地址时，应考虑该限制。

- **<!--how-do-bitcoin-nodes-update-the-utxo-set-when-their-latest-blocks-are-replaced-->**[当节点的最新区块被替换时，比特币节点如何更新 UTXO 集？]({{bse}}87991) Pieter Wuille 描述了 "[undo files][] 如何在区块重组后用于更新 UTXO 集。"

- **<!--is-there-a-reason-why-bitcoin-core-does-not-implement-bip39-->**[为什么 Bitcoin Core 没有实现 BIP39？]({{bse}}88237) Andrew Chow 解释了 Bitcoin Core 当前钱包结构加上对 [BIP39][] 中使用 PBKDF2 的安全性担忧，构成了其实现的障碍。

- **<!--is-a-signature-private-key-required-to-accept-payment-over-lightning-network-->**[接受闪电网络支付是否需要签名/私钥？]({{bse}}88201) Yuya Ogawa 询问是否可以在不在线保存私钥的情况下接受闪电网络支付。Rene Pickhardt 指出，[BOLT11][] 不仅要求签署发票，而且通道的更新也需要签名，因此需要私钥。

## 值得注意的代码和文档更改

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和 [比特币改进提案（BIPs）][bips repo] 的值得注意的更改。*

- [Bitcoin Core #13756][] 添加了一个 `setwalletflag` RPC，可用于切换钱包标志，包括一个新的 `avoid_reuse` 标志（启用时）将防止钱包使用已用于支付的地址接收比特币。这可以防止区块链分析人员通过地址重复使用来关联多个支付，从而攻击隐私——这种攻击通常使用[粉尘攻击][dust attacks]来实现。这个新标志默认是禁用的，但启用后，可以与 [Newsletter #6][] 中描述的 `avoidpartialspends` 配置选项结合使用，以确保到目前为止接收到同一地址的所有比特币在同一时间被花费，确保没有余额剩余，这需要通过传递特殊选项才能花费。

- [Bitcoin Core #15651][] 使 Bitcoin Core 在 Tor 上监听时始终绑定到默认端口（例如主网的 8333 端口），即使它配置为在正常明网流量上监听其他端口。先前的行为是在所有接口上监听自定义端口，这使得任何使用自定义比特币端口的 Tor 节点的明网身份很容易被发现。

- [Bitcoin Core #16171][] 移除了 `mempoolreplacement` 配置选项。该选项配置节点是否根据 [BIP125][] 的选择性 RBF 规则接受将交易替换到其内存池中。该选项是在 0.12 发布周期的[最后时刻][Bitcoin Core #7386]添加的，开发者们[认为][sdaftuar rbf]这几乎不是矿工或节点操作员想要的——因为矿工这样做会降低他们的盈利能力，而节点操作员即使不喜欢选择性 RBF，禁用此选项也会阻止他们收到替换的警告。不喜欢 RBF 的用户最好忽略那些选择 RBF 的交易，直到它们被确认（如 [BIP125][bip125 recv wallet policy] 中所述）。据信几乎所有节点目前都使用默认选项，而最近唯一已知使用该选项的矿工也确认这是一个配置错误，因此由于缺乏使用和没有理由推荐使用，该选项被移除。

- [Bitcoin Core #16026][] 使 `createmultisig` 和 `addmultisigaddress` RPC 始终返回一个传统的 P2SH 多签地址，如果使用的任何公钥是[未压缩公钥][uncompressed pubkeys]。根据 [BIP143][]，未压缩公钥不得用于当前版本的 segwit（版本 0）。Bitcoin Core 不会中继使用未压缩公钥的 segwit 输出的支付，并且未来的软分叉可能会使它们永久不可花费。

{% include linkers/issues.md issues="13756,15651,16171,7386,16026" %}
[bech32 series]: /zh/bech32-sending-support/
[bip125 recv wallet policy]: https://github.com/bitcoin/bips/blob/master/bip-0125.mediawiki#receiving-wallet-policy
[dust attacks]: {{bse}}81509
[cl rc]: https://github.com/ElementsProject/lightning/tags
[lnd rc]: https://github.com/LightningNetwork/lnd/releases
[sdaftuar rbf]: https://github.com/bitcoin/bitcoin/pull/16171#issuecomment-500393271
[uncompressed pubkeys]: https://btcinformation.org/en/developer-guide#public-key-formats
[undo files]: https://en.bitcoin.it/wiki/Data_directory#locks_subdirectory
[vulnerabilities announce]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-June/017040.html
[eclipse attack]: https://eprint.iacr.org/2015/263.pdf
[core dev meeting]: http://www.erisian.com.au/meetbot/bitcoin-core-dev/2019/bitcoin-core-dev.2019-06-20-19.01.log.html#l-36
[newsletter #6]: /zh/newsletters/2018/07/31/#bitcoin-core-12257
