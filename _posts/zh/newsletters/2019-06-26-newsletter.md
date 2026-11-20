---
title: 'Bitcoin Optech Newsletter #52'
permalink: /zh/newsletters/2019/06/26/
name: 2019-06-26-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
slug: 2019-06-26-newsletter-zh
---
本周的 Newsletter 预告了旧版本 Bitcoin Core 中若干轻微漏洞即将公开，建议继续测试 LN 软件的候选版本，并介绍一种让 Bitcoin Core 节点稍微更难被 日食攻击的设想。常规章节照旧包括 bech32 发送支持、Stack Exchange 热门问答，以及热门比特币基础设施项目中的值得注意的变更。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- **<!--update-bitcoin-core-to-at-least-0-17-1-->****将 Bitcoin Core 更新至至少 0.17.1 版本：**两个影响旧版本 Bitcoin Core 的轻微漏洞预计将在 8 月 1 日左右被披露。这两个漏洞都不影响 0.17.1 版本（2018 年 12 月 25 日发布）或之后的版本。我们对 Bitcoin Core 贡献者 practicalswift 提供漏洞报告表示感谢。

- **<!--help-test-c-lightning-and-lnd-rcs-->****帮助测试 C-Lightning 和 LND 的候选版本：**[C-Lightning][cl rc] 和 [LND][lnd rc] 都在为其下一个版本测试候选版本（RC）。鼓励有经验的用户帮助测试这些 RC，以便在最终发布前识别并修复任何剩余的错误。

## 新闻

- **<!--differentiating-peers-based-on-asn-instead-of-address-prefix-->****按 ASN 而非地址前缀来区分对等节点：**一场 [日食攻击][eclipse attack]能让全节点与任何一个诚实节点都建立不起连接，从而使攻击者能够防止该节点了解拥有最多工作量证明的区块链或广播时间敏感的交易。为了帮助防止 日食攻击，Bitcoin Core 全节点通常会将其八个外发连接分配给 IP 地址在前 16 位（即 /16）上不同的节点。许多 ISP 仅在少数不同的 /16 范围内拥有 IP 地址，或者将地址分配给客户的方式使得客户难以选择他们获得的前缀，这使得攻击者更难获得大量多样化的 IP 地址来执行 日食攻击。

  然而，一些大型 ISP，如云计算运营商，管理着多个使用不同 IP 范围的设施，这使得客户更容易获得来自多个前缀的地址。对此问题的一个可能解决方案是跟踪哪些 IP 地址由哪些 ISP 控制，然后将节点的外发连接按 ISP 分配，而不论它们使用什么地址。例如，这可能能够将所有来自 Amazon AWS 的 IP 地址分组在一起，无论客户使用哪个区域的服务器。

  ISP 到 IP 地址的信息可以从整个互联网的路由表中获得。不幸的是，这些表的大小超过 1 GB——对于全节点来说，实在太大而无法实用地包含在内。Pieter Wuille 正在研究一种紧凑的编码方式，只包含识别不同 ISP 所需的信息（使用 ISP 的自治系统编号，ASN）。Wuille 的表将额外的存储需求减少到约 1 MB。在本周的 Bitcoin Core 开发者 [IRC 会议][core dev meeting] 上，Wuille 和 Matt Corallo 询问 1 MB 的额外数据是否足够小，可以随 Bitcoin Core 一起分发，以改善其确保与不同网络上的节点连接的能力。会议参与者表示支持这一想法，并花时间讨论了一些实现细节。基于这些反馈，我们预计这一想法会有进一步的发展。

## Bech32 发送支持

*这是 [bech32 系列][bech32 series] 24 周中的第 15 周，该系列讲的是如何让你付款的对象享受到 segwit 的全部好处。*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/zh/15-data-entry.md %}

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们有点空闲时帮助好奇或困惑用户的地方。在本月栏目中，我们精选自上次更新以来得票最高的一些问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{%
endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--how-can-i-mitigate-concerns-around-the-gap-limit-->**[如何化解对地址间隙限制的顾虑？]({{bse}}88128) Enrique 问到，使用 HD 钱包时若超出地址间隙限制（gap limit），会不会有资金损失的风险。Andrew Chow 和 Bitcoin Holder 解释说，超出间隙限制本身不会造成资金损失，但在从备份恢复钱包、或在钱包之外生成地址时，应当把这个限制考虑进去。

- **<!--how-do-bitcoin-nodes-update-the-utxo-set-when-their-latest-blocks-are-replaced-->**[当节点的最新区块被替换时，比特币节点如何更新 UTXO 集？]({{bse}}87991) Pieter Wuille 说明了 "[undo files][]"（撤销文件）如何在区块重组后用于更新 UTXO 集。

- **<!--is-there-a-reason-why-bitcoin-core-does-not-implement-bip39-->**[为什么 Bitcoin Core 没有实现 BIP39？]({{bse}}88237) Andrew Chow 解释了 Bitcoin Core 当前钱包结构加上对 [BIP39][] 中使用 PBKDF2 的安全性担忧，构成了其实现的障碍。

- **<!--is-a-signature-private-key-required-to-accept-payment-over-lightning-network-->**[接受闪电网络支付是否需要签名/私钥？]({{bse}}88201) Yuya Ogawa 想知道，能不能不把私钥放在线上就接受闪电网络支付。Rene Pickhardt 指出，[BOLT11][] 不仅要求签署发票，而且通道的更新也需要签名，因此需要私钥。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和[比特币改进提案（BIPs）][bips repo]中的值得注意的变更。*

- [Bitcoin Core #13756][] 新增 `setwalletflag` RPC，可用于切换钱包的各项标志，其中包括新标志 `avoid_reuse`：启用后，钱包不会花掉“付给某个它此前已经用于花费的地址”的比特币。这可防止区块链分析者借重复使用花费地址，把多笔花费关联到同一个钱包——这种侵犯隐私的手法常借助[粉尘攻击][dust attacks]来实施。新标志默认关闭；启用后可与 [Newsletter #6][] 中介绍的 `avoidpartialspends` 配置选项配合，确保到目前为止付给同一地址的比特币被一次性全部花掉，不会剩下一点留在余额里、非得传特殊选项才能花。

- [Bitcoin Core #15651][] 使 Bitcoin Core 在 Tor 上监听时始终绑定到默认端口（例如主网的 8333 端口），即使它配置为在正常明网流量上监听其他端口。先前的行为是在所有接口上监听自定义端口，这使得任何使用自定义比特币端口的 Tor 节点的明网身份很容易被发现。

- [Bitcoin Core #16171][] 移除了 `mempoolreplacement` 配置选项。该选项配置节点是否根据 [BIP125][] 自愿启用的 RBF 规则接受将交易替换到其内存池中。该选项是在 0.12 发布周期的[最后时刻][Bitcoin Core #7386]添加的，开发者们[认为][sdaftuar rbf]，这几乎从来不是矿工或节点运营者想要的东西——对矿工来说它会降低盈利，而对节点运营者来说，即使自己不喜欢自愿启用的 RBF，禁用这个选项也会让他们收不到关于交易替换的警告。不喜欢 RBF 的用户最好忽略那些自愿启用 RBF 的交易，直到它们被确认（如 [BIP125][bip125 recv wallet policy] 中所述）。据信目前几乎所有节点都在用默认设置，而近期唯一已知启用过该选项的矿工也确认，那是他们那边的配置失误。既然无人使用，也没有理由推荐别人使用，该选项就被移除了。

- [Bitcoin Core #16026][] 让 `createmultisig` 和 `addmultisigaddress` RPC 在用到的公钥中包含[未压缩公钥][uncompressed pubkeys]时，一律返回传统的 P2SH 多重签名地址。按 [BIP143][] 的规定，未压缩公钥不得用于当前版本的 segwit（版本 0）。Bitcoin Core 不会中继那些用未压缩公钥花费 segwit 输出的交易，而且未来的软分叉还可能让这类输出永久无法花费。

{% include linkers/issues.md issues="13756,15651,16171,7386,16026" %}
[bech32 series]: /zh/bech32-sending-support/
[bip125 recv wallet policy]: https://github.com/bitcoin/bips/blob/master/bip-0125.mediawiki#receiving-wallet-policy
[dust attacks]: {{bse}}81509
[cl rc]: https://github.com/ElementsProject/lightning/tags
[lnd rc]: https://github.com/LightningNetwork/lnd/releases
[sdaftuar rbf]: https://github.com/bitcoin/bitcoin/pull/16171#issuecomment-500393271
[uncompressed pubkeys]: https://btcinformation.org/en/developer-guide#public-key-formats
[undo files]: https://en.bitcoin.it/wiki/Data_directory#locks_subdirectory
[vulnerabilities announce]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-June/017040.html
[eclipse attack]: https://eprint.iacr.org/2015/263.pdf
[core dev meeting]: http://www.erisian.com.au/meetbot/bitcoin-core-dev/2019/bitcoin-core-dev.2019-06-20-19.01.log.html#l-36
[newsletter #6]: /zh/newsletters/2018/07/31/#bitcoin-core-12257
