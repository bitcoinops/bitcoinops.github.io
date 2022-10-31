---
title: 'Bitcoin Optech Newsletter #222'
permalink: /zh/newsletters/2022/10/19/
name: 2022-10-19-newsletter-zh
slug: 2022-10-19-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报描述了上周影响了 BTCD 和 LND 的区块解析错误，总结了与费用替换相关的计划中的 Bitcoin Core 功能更改的讨论，概述了有关比特币上有效性 rollup 的研究，分享了有关 MuSig2 的 BIP 草案中的漏洞的公告，检查了一项提案，以减少比特币核心将中继的未确认交易的最小规模，并链接到对比特币的第 2 版加密传输协议 BIP324 提案的更新。此外还包括我们的常规栏目，其中包含对服务和客户端软件更改的总结、新版本和候选版本的公告，以及对流行的比特币基础设施项目中值得注意的合并的描述。

## 新闻

- **影响 BTCD 和 LND 的区块解析错误：** 10 月 9 日，[user][brqgoo] 使用 [taproot][topic taproot] 创建了一笔[交易][big msig]，其见证人包含近千个签名。共识规则对 Taproot 见证数据的大小没有任何直接限制。这是在 taproot 的开发过程中讨论的一个设计元素（参见 [Newsletter #65][news65 tapscript limits]）。

    这个大型见证交易被确认后不久，用户开始报告 BTCD 全节点实现和 LND 闪电网络实现未能提供 Bitcoin Core 全节点可用的最新区块数据。对于 BTCD 节点，这意味着最近确认的交易仍被报告为未确认。对于 LND，这意味着最近已准备好可用的新通道并未被报告为完全开放。

    BTCD 和 LND 的开发人员修复了被 LND 作为库使用的 BTCD 代码中的问题，并迅速发布了 [LND][lnd 0.15.2-beta] 的新版本（如[上周的周报][news221 lnd]所描述) 和 [BTCD][btcd 0.23.2]。 BTCD 和 LND 的所有用户都应该升级。

    在用户升级他们的软件之前，他们将遭受上述缺乏确认的问题，并且还可能容易受到多种攻击。其中一些攻击需要获得比较显著的哈希率（这将使哈希率变得昂贵，并且最好在该情况下变得不实用）。其他攻击，尤其是针对 LND 用户的攻击，要求攻击者冒着在通道中损失部分资金的风险，这也有望起到足够的威慑作用。我们再次建议升级。此外，我们建议使用任何比特币软件的任何人都订阅所使用软件的开发团队的安全公告。

    在上述披露之后，Loki Verloren Bitcoin-Dev 邮件列表中[发帖][verloren limits]，建议将直接限制添加到 taproot 的见证人大小。 Greg Sanders [回复][sanders limits]指出，现在增加限制不仅会增加代码的复杂性，而且如果人们已经收到需要大量见证人才能花费的脚本的比特币，可能导致人们资金丢失。

- **<!--transaction-replacement-option-->交易替换选项：**如周报 [#205][news205 rbf] 和 [#208][news208 rbf] 中所述，Bitcoin Core 合并了对{code1}mempoolfullrbf{/code1}配置选项的支持，该选项默认为仅允许 [RBF 替换]的现有 Bitcoin Core 行为包含 [BIP125][] 信号的交易的 [topic rbf]。但是，如果用户将新选项设置为 true，则他们的节点将接受并中继不包含 BIP125 信号的交易的替换，前提是替换交易遵循比特币核心的所有其他替换规则。

    Dario Sneidermanis Bitcoin-Dev 邮件列表[发帖][sne rbf]表示，这个新选项可能会给当前接受未确认交易作为最终交易的服务造成问题。尽管多年来用户可以运行允许无信号*完整*[^full-rbf] 交易替换的非 Bitcoin Core 软件（或 Bitcoin Core 的修订版本），但没有证据表明该软件被广泛使用。 Sneidermanis 认为，在 Bitcoin Core 中引入一个易于访问的选项可能会改变这种情况，这是通过允许足够的用户和矿工启用完整的 RBF 实现的，并使无信号替换变得可靠。更可靠的无信号替换也将更可靠的从接受未经确认的交易作为最终交易的服务中进行窃取，从而要求这些服务改变它们的行为。

    除了描述问题并提供服务如何选择何时接受未经确认的交易的详细描述外，Sneidermanis 还提出了一种替代方法：从即将发布的 Bitcoin Core 版本中删除配置选项，同时在未来某个时刻添加默认启用完整 RBF 的代码。 Anthony Towns [发布了][towns rbf]供考虑的几个选项，并开启了一个 [pull request][bitcoin core #26323]，它是对 Sneidermanis 提案稍作修改后的版本实现。如果 Towns 的 PR 被合并同时以其当前状态发布，该 PR 将从 2023 年 5 月 1 日开始默认启用完整 RBF。反对完整 RBF 的用户仍然可以通过将 `mempoolfullrbf` 选项设置为 false 来阻止其节点参与。

- **有效性 rollup 研究：**John Light 在 Bitcoin-Dev 邮件列表中[发布了][light ml ru]一个他准备的关于有效性 rollup 的[详细研究报告][light ru] 的链接——一种当前状态紧凑地存储在主链上的[侧链][topic sidechains]。侧链的用户可以使用存储在主链上的状态来证明他们控制了多少侧链比特币。通过提交带有有效性证明的主链交易，即使侧链的运行者或矿工试图阻止，用户仍然可以从侧链中提取他们拥有的比特币。

    Light 的研究深入描述了有效性 rollup，研究了如何将对它们的支持添加到比特币中，并检查了它们实施的各种担忧。

- **MuSig2 安全漏洞：** Jonas Nick 在Bitcoin-Dev 邮件列表中[发布][nick musig2]，关于他和其他几个人在一份 [BIP 草案][bips #1372]中记录的 [MuSig2][topic musig] 算法中发现的漏洞。简而言之，如果攻击者知道用户的公钥，协议会有安全问题。对用户将签名的公钥进行调整（例如使用 [BIP32][topic bip32] 扩展公钥）可以操纵用户将使用哪个版本的密钥来签名。

    Jonas Nick 认为该漏洞“应该只适用于相对罕见的情况”，并鼓励任何使用（或即将使用）MuSig2 的人向他和其他作者就该问题取得联系。 MuSig2 的 BIP 草案预计将很快更新以解决该问题。

- **<!--minimum-relayable-transaction-size-->最小可中继交易规模：** Greg Sanders 在 Bitcoin-Dev 邮件列表中[表示][sanders min]，请求 Bitcoin Core 放宽一项让攻击者更难利用 [CVE-2017-12842][] 漏洞的政策。此漏洞允许攻击者将特制的 64 字节交易确认到一个区块中，以欺骗轻量级客户端相信一个或多个不同的任意交易已被确认。例如，无辜用户 Bob 的简化支付验证 (SPV) 钱包可能会显示他已经收到了 100 万个 BTC 付款，并得到了数十次确认，即使从没有过这类付款。

    当该漏洞仅在少数开发人员中私下知晓时，Bitcoin Core 增加了一个限制，以防止中继任何少于 85 字节（不包括见证字节）的交易，这大约是使用标准交易模板可创建的最小的交易大小。这将要求攻击者通过不基于 Bitcoin Core 的软件来挖矿产出他们的交易。后来，[共识清理软分叉提案][topic consensus cleanup]建议通过禁止任何小于 65 字节的交易被包含在新区块中来永久解决该问题。

    Sanders 建议将交易中继策略限制从 85 字节降低到共识清理中建议的 65 字节限制，这可能允许在不改变当前风险状况的情况下进行额外的实验和使用。 Sanders 开启了一个 [pull request][bitcoin core #26265] 以进行此更改。另请参阅[周报 #99][news99 min]，了解与此拟议变更相关的先前讨论。

- **BIP324 更新：** Dhruv M 在 Bitcoin-Dev 邮件列表中[发表][dhruv 324]，对[第 2 版加密 P2P 传输协议][topic v2 p2p transport]的 BIP324 提案几项更新的摘要。这包括重写 [BIP 草案][bips #1378]和发布[各种资源][bip324.com] 以帮助审阅者评估提案，包括一份出色的、涉及多个代码库的[提议代码变更的指南] [bip324 changes]。

    如 BIP 草案的*动机*部分所述，比特币节点的原生加密传输协议可以提高交易公告期间的隐私，防止篡改连接（或至少更容易检测篡改），并让审查 P2P 连接和进行[日蚀攻击][topic eclipse attacks]更加困难。

## 服务与客户端软件变更

*在这个月度专题中，我们重点介绍比特币钱包和服务的有意思的更新。*

- **btcd v0.23.2 发布：**
  btcd v0.23.2（以及 [v0.23.1][btcd 0.23.1]）增加了 [addr v2][topic addr v2] 以及追加对 [PSBTs][topic psbt]、[taproot][topic taproot] 的支持、[MuSig2][topic musig] 以及其他增强和修复。

- **ZEBEDEE 公布托管通道库：**
  在最近一篇的[博文][zbd nbd]中，ZEBEDEE 宣布了一个开源钱包（Open Bitcoin Wallet）、Core Lightning 插件（Poncho）、闪电网络客户端（Cliché）以及专注于支持[托管通道][hosted channels]的闪电网络库（Immortan）。

- **Cashu 上线，支持闪电网络：**
  电子现金软件 [Cashu][cashu github] 作为概念验证钱包上线，支持闪电网络的收款。

- **地址浏览器 Spiral 上线：**
  [Spiral][spiral explorer] 是一个开源公共地址[浏览器][topic block explorers]，它使用密码学技术为查询地址信息的用户提供隐私。

- **BitGo 宣布支持闪电网络：**
  在一篇[博文][bitgo lightning]中，BitGo 描述了其托管闪电网络服务。该服务为其客户运行节点并维护支付通道的流动性。

- **ZeroSync 项目启动：**
  [ZeroSync][zerosync github] 项目正在使用 [Utreexo][topic utreexo] 和 STARK 证明来同步比特币节点，就像在初始块下载 (IBD) 中一样。

## 新版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Bitcoin Core 24.0 RC2][] 是网络中使用最广泛的全节点实现的下一版本的候选版本。[测试指南][bcc testing]已可用。

- [LND 0.15.3-beta][] 是一个小的版本发布，修复了几个错误。

## 重大的代码和文档更新

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo] 和 [Lightning BOLTs][bolts repo]。*

- [Bitcoin Core #23549][] 添加了 `scanblocks` RPC。RPC 仅在维护[致密区块过滤器][topic compact block filters]索引（`-blockfilterindex=1`）的节点上可用。

- [Bitcoin Core #25412][] 添加了一个新的 `/deploymentinfo` REST 端点，其中包含有关软分叉部署的信息，类似于现有的 `getdeploymentinfo` RPC。

- [LND #6956][] 可以设置对来自通道合作方付款的最低通道储备金限制。如果这使得通道合作方的资金金额低于储备金（LND 中默认为 1%），则节点不会接受来自其通道合作方的付款。这样可以确保合作方在尝试关闭处于过时状态的通道时至少需要支付储备金作为罚款。这个合并的 PR 可以降低或提高储备金金额。

- [LND #7004][] 更新了 LND 使用的 BTCD 库的版本，修复了本周报上文描述的安全漏洞。

- [LDK #1625][] 开始跟踪本地节点尝试通过远距离通道进行路由支付的通道流动性信息。本地节点存储有关已成功通过远距离节点路由或明显由于资金不足而失败的付款大小的信息。该信息根据其新旧进行了调整，用作概率寻路的输入（参见[周报 #163][news163 pr]）。

## 脚注

<!-- TODO:harding is 95% sure the below is correct and will delete this
comment when he gets verification from the person he thinks first used
the "full RBF" term.  -->

[^full-rbf]:
    交易替换包含在比特币的第一个版本中，多年来有很多讨论。在此期间，若干用于描述其各个方面的术语都发生了变化，可能会引发混淆。也许最大的混淆源就是“完整 RBF”这个术语，它被用于两个不同的概念：

    - *<!--full-replacement-of-any-->对一个交易任何**部分**的完全替换交易*不同于仅仅添加额外的输入和输出。在启用 RBF 存在争议并且在选择加入的想法提议前的一段时间内，一个[建议][superset rbf]是仅当替换包括所有相同的输出再加上额外的用于支付费用并收取零钱的新的输入和输出，才允许该交易被替换。保持原始输出的要求可以确保该替换仍会付给原来的收款人同样数额的资金。这个想法后来被称为 First Seen Safe（FSS）RBF，是一种*部分*替换。

        与此相比，此时的*完全*替换意味着可以完全改变原交易的任何内容（只要它通过花费至少一个相同的输入的方式与原交易依旧冲突）。这种完全是在 [BIP125][] 的标题——“选择加入完全按费用替换的信号”中所使用的那种完全。

    - *<!--full-replacement-of-->完全替换**任何**交易*不同于仅通过 BIP125 信号来选用支持替换的交易。选用 RBF 作为对那些不想允许 RBF 和认为它是必需或不可避免的两类人群的一种折中方案被提出。然而，在编写本文时，只有少数交易选用 RBF，这可以看作部分采用 RBF。

        相比之下，*完全*采用 RBF 可以通过允许任何未经确认的交易被替换来启用。这种完全是在当前讨论的 Bitcoin Core 中所使用的配置选项 `mempoolfullrbf` 所使用的那种完全。

{% include references.md %}
{% include linkers/issues.md v=2 issues="23549,25412,25667,2448,6956,6972,7004,1625,26323,1372,1378,26265" %}
[bitcoin core 24.0 rc2]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/24.0-Release-Candidate-Testing-Guide
[superset rbf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2013-March/002240.html
[brqgoo]: https://twitter.com/brqgoo/status/1579216353780957185
[big msig]: https://blockstream.info/tx/7393096d97bfee8660f4100ffd61874d62f9a65de9fb6acf740c4c386990ef73?expand
[news65 tapscript limits]: /en/newsletters/2019/09/25/#tapscript-resource-limits
[lnd 0.15.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.2-beta
[news221 lnd]: /en/newsletters/2022/10/12/#lnd-v0-15-2-beta
[btcd 0.23.2]: https://github.com/btcsuite/btcd/releases/tag/v0.23.2
[verloren limits]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/020993.html
[sanders limits]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/020996.html
[news205 rbf]: /en/newsletters/2022/06/22/#full-replace-by-fee
[news208 rbf]: /en/newsletters/2022/07/13/#bitcoin-core-25353
[sne rbf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/020980.html
[towns rbf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021017.html
[light ml ru]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/020998.html
[light ru]: https://bitcoinrollups.org/
[nick musig2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021000.html
[sanders min]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/020995.html
[cve-2017-12842]: /en/topics/cve/#CVE-2017-12842
[news99 min]: /en/newsletters/2020/05/27/#minimum-transaction-size-discussion
[dhruv 324]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/020985.html
[bip324.com]: https://bip324.com
[bip324 changes]: https://bip324.com/sections/code-review/
[news163 pr]: /en/newsletters/2021/08/25/#zero-base-fee-ln-discussion
[lnd 0.15.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.3-beta
[btcd 0.23.1]: https://github.com/btcsuite/btcd/releases/tag/v0.23.1
[zbd nbd]: https://blog.zebedee.io/announcing-nbd/
[hosted channels]: https://fanismichalakis.fr/posts/what-are-hosted-channels/
[cashu github]: https://github.com/callebtc/cashu
[spiral explorer]: https://btc.usespiral.com/
[bitgo lightning]: https://blog.bitgo.com/bitgo-unveils-custodial-lightning-898554d3b749
[zerosync github]: https://github.com/zerosync/zerosync
