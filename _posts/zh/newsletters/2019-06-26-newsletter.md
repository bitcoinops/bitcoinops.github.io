---
title: 'Bitcoin Optech Newsletter #52'
permalink: /zh/newsletters/2019/06/26/
name: 2019-06-26-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
slug: 2019-06-26-newsletter-zh
---
本周的 Newsletter 宣布了即将披露的旧版 Bitcoin Core 小漏洞，建议继续测试 LN 软件的 RC，并描述了一种使 Bitcoin Core 节点更能抵抗攻击的技术。此外，我们还包括了关于 bech32 发送支持、热门 Stack Exchange 话题以及热门比特币基础设施项目的显著变化的常规部分。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- **<!--update-bitcoin-core-to-at-least-0-17-1-->****将 Bitcoin Core 更新到至少 0.17.1 版：** 两个影响旧版 Bitcoin Core 的小漏洞[计划][vulnerabilities announce]在 8 月 1 日左右披露。这两个漏洞均不影响 0.17.1 版（2018 年 12 月 25 日发布）或更高版本。我们对 Bitcoin Core 贡献者 practicalswift 表示感谢，他报告了这些漏洞。

- **<!--help-test-c-lightning-and-lnd-rcs-->****帮助测试 C-Lightning 和 LND 的 RC：**[C-Lightning][cl rc] 和 [LND][lnd rc] 都在为它们的下一个版本测试候选版本（RC）。我们鼓励有经验的用户帮助测试 RC，以便在最终发布之前识别并修复所有剩余的 bug。

## 新闻

- **<!--differentiating-peers-based-on-asn-instead-of-address-prefix-->****基于 ASN 而非地址前缀区分节点：** 一次[攻击][eclipse attack]阻止一个全节点与其他诚实节点建立连接，从而使攻击者能够防止该节点了解最多工作量证明的区块链或广播时间敏感的交易。为了帮助防止攻击，Bitcoin Core 全节点通常将其八个外向连接分配给 IP 地址的前 16 位（即 /16）不同的节点。许多 ISP 只有少量不同 /16 范围的 IP 地址，或者以难以让客户选择前缀的方式分配地址，使攻击者难以获取大量不同 IP 地址来进行攻击。

  然而，一些大型 ISP，如云计算操作，管理着多个使用不同 IP 范围的设施，使客户更容易获取多个前缀的地址。一种可能的解决方案是跟踪哪些 IP 地址由哪些 ISP 控制，然后将节点的外向连接在不同 ISP 之间分配，而不管它们使用的是什么地址。例如，这可能能够将所有来自 Amazon AWS 的 IP 地址分组，无论客户使用哪个地区的服务器。

  ISP 到 IP 地址的信息可以从整个互联网的路由表中获得。不幸的是，这些表格超过 1 GB，大到无法实用地包含在全节点中。Pieter Wuille 一直在研究一种紧凑编码方法，只包含识别 ISP 所需的信息（使用 ISP 的自治系统编号，ASN）。Wuille 的表将额外存储要求减少到约 1 MB。在本周的 Bitcoin Core 开发者 [IRC 会议][core dev meeting]中，Wuille 和 Matt Corallo 问 1 MB 的额外数据是否足够小，能随 Bitcoin Core 分发以改善其确保连接到不同网络上的节点的能力。会议参与者对这个想法表示支持，然后花时间讨论一些实施细节。基于这些反馈，我们预计这个想法会有更多的开发。

## Bech32 发送支持

*关于让你支付的人访问所有 segwit 好处的[系列][bech32 series]的第 15 周。*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/zh/15-data-entry.md %}

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选之一——或者当我们有时间帮助好奇或困惑的用户时。在这个月度特辑中，我们突出了一些自上次更新以来获得最高票数的问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--how-can-i-mitigate-concerns-around-the-gap-limit-->**[如何缓解与 gap limit 相关的担忧？]({{bse}}88128) Enrique 询问使用 HD 钱包并超过地址 gap limit 时的潜在资金损失问题。Andrew Chow 和 Bitcoin Holder 解释说，虽然超过 gap limit 时不会损失资金，但在从备份恢复或生成钱包外的地址时应考虑该限制。

- **<!--how-do-bitcoin-nodes-update-the-utxo-set-when-their-latest-blocks-are-replaced-->**[当最新区块被替换时，比特币节点如何更新 UTXO 集？]({{bse}}87991) Pieter Wuille 描述了 “[undo files][]” 如何在区块重组后更新 UTXO 集。

- **<!--is-there-a-reason-why-bitcoin-core-does-not-implement-bip39-->**[Bitcoin Core 为什么不实现 BIP39？]({{bse}}88237) Andrew Chow 解释了 Bitcoin Core 当前钱包结构以及对 [BIP39][] 使用 PBKDF2 的安全顾虑是其实现的障碍。

- **<!--is-a-signature-private-key-required-to-accept-payment-over-lightning-network-->**[接受闪电网络支付是否需要签名/私钥？]({{bse}}88201) Yuya Ogawa 询问是否有可能在不在线保留私钥的情况下接受闪电支付。Rene Pickhardt 指出，[BOLT11][] 不仅要求签名的发票，而且通道的更新也需要签名，因此需要私钥。

## 值得注意的代码和文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和[比特币改进提案 (BIPs)][bips repo]的值得注意的变化。*

- [Bitcoin Core #13756][] 添加了 `setwalletflag` RPC，可以用来切换钱包的标志，包括新的 `avoid_reuse` 标志（启用时），将防止钱包花费已用于花费的地址接收到的比特币。这可以防止区块链分析师通过花费地址重用来关联同一钱包的多次花费——这是一种通常通过[粉尘攻击][dust attacks]利用的隐私攻击。这个新标志默认禁用，但启用时可以与 [Newsletter #6][] 中描述的 `avoidpartialspends` 配置选项结合使用，确保同一地址收到的所有比特币同时花费，确保没有剩余余额需要通过特殊选项花费。

- [Bitcoin Core #15651][] 使 Bitcoin Core 在 Tor 上监听时总是绑定到默认端口（例如主网的 8333 端口），即使它配置为在普通 clearnet 流量上监听另一个端口。先前的行为是在所有接口上监听自定义端口，这使得很容易找到使用自定义比特币端口的 Tor 节点的 clearnet 身份。

- [Bitcoin Core #16171][] 删除了 `mempoolreplacement` 配置选项。这个选项配置节点是否根据 [BIP125][] 的选择加入 RBF（Replace-by-Fee）规则接受交易替换。这个选项是在 0.12 发布周期的[最后时刻][Bitcoin Core #7386]添加的，开发者们[争论][sdaftuar rbf]它几乎不是矿工或节点操作员想要的——矿工因为它减少了他们的利润，节点操作员因为即使操作员不喜欢选择加入 RBF，禁用这个选项也会阻止他们接收替换警告。不喜欢 RBF 的用户最好忽略选择加入 RBF 的交易，直到它们被确认（如 [BIP125][bip125 recv wallet policy] 中所述）。据信几乎所有节点目前都在使用默认选项，而最近确认使用这个选项的唯一矿工也证实那是他们的配置错误，因此由于缺乏使用和没有理由推荐任何人使用它，这个选项被删除。

- [Bitcoin Core #16026][] 使 `createmultisig` 和 `addmultisigaddress` RPC 在任何公钥使用未压缩公钥时总是返回遗留 P2SH 多重签名地址。根据 [BIP143][]，当前版本的 segwit（版本 0）不应使用未压缩公钥。Bitcoin Core 不会中继使用未压缩公钥的 segwit 输出的花费，而且未来的软分叉可能会使它们永久无法花费。

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
