---
title: 'Bitcoin Optech Newsletter #344'
permalink: /zh/newsletters/2025/03/07/
name: 2025-03-07-newsletter-zh
slug: 2025-03-07-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的新闻部分披露了一个影响旧版本 LND 的漏洞，并总结了关于 Bitcoin Core 项目性质的讨论。此外是我们的常规栏目：与共识变更相关的通道的介绍、软件的新版本和候选版本发行公告，以及热门的比特币基础设施软件的重大变更的总结。

## 新闻

- **<!--disclosure-of-fixed-lnd-vulnerability-allowing-theft-->** **（已修复的）允许盗取的 LND 漏洞曝光**：Matt Morehouse 在 Delving Bitcoin 论坛中[发帖][morehouse failback]宣布他[尽责披露][topic responsible disclosures]了一项影响 0.18 以前版本的 LND 的漏洞。建议读者升级到 0.18 乃至（最好是）[最新版本][lnd current]。在此漏洞中，与受害者节点共享一条通道的攻击者可以一定程度上导致受害者节点在特定时间点重启，从而诱骗受害者的 LND 软件为同一个 HTLC 支付又退款， 攻击者凭此可以盗走通道中几乎所有资金。

  More House 指出，其它闪电节点实现都独立发现并修复了该漏洞，最早的可追溯到 2018 年（详见[周报 #17][news17 cln2000]），但闪电网络规范并没有指明正确的动作（甚至可能要求了不正确的动作）。他还[开启了一项 PR][bolts #1233]来更新闪电网络规范。

- **<!--discussion-about-bitcoin-cores-priorities-->** **关于 Bitcoin Core 性质的讨论**：Antoine Poinsot 撰写了多篇博文来讨论 Bitcoin Core 项目的未来；这些文章被 Delving Bitcoin 论坛的一篇[帖子][poinsot pri]引用了。在 Antoine 的[第一篇][poinsot pri1]文章中，Poinsot 讲解了设定长期目标的好处，以及临时抱佛脚的代价。而在[第二篇][poinsot pri2]文章中，他主张 “Bitcoin Core 项目应该成为比特币网络的强壮骨架，并在保护 Bitcoin Core 软件的安全和实现新特性以加强和提升比特币网络之间取得平衡。”在他的[第三篇][poinsot pri3]文章中，他建议将现有的项目分切成三个项目：节点、钱包和 GUI（图形操作界面）。得益于 “多线程” 子项目的持续努力（详见[周报 #39][news39 multiprocess]，那是 2019 年，我们第一次提到这个子项目），这一目标已经触手可及。

  Anthony Towns [询问][towns pri] 多线程是否真的允许三者在实质上分类，因为每一个组件都依然是紧密关联的。许多对一个项目的变更也要求变更其它项目。不过，如果能将当前不需要节点接入的特性移到一个库或者一套工具中（并使之能够独立得到维护），那会是显然的好事。他也介绍了当前一些用户使用节点的方式：他们会使用一些中间件，以便自己的钱包软件能够连接到自己的节点、让后者来提供区块链索引（一般来说是[某种个人区块浏览器][topic block explorers]） —— 这是以往 Bitcoin Core 项目已经拒绝直接包含在其节点模块的特性。最后，他[指出][towns pri2]，“对我来说，提供钱包特性（在很大程度上）以及 GUI（在稍弱的程度上）是一种让我们保持诚实、忠于‘比特币会被一群去中心化的极客们使用’ 的原则，而不是让比特币成为只有大鳄或者想搞一笔大投资的老牌企业才能使用的东西。”

  David Harding 表达了对将 Bitcoin Core 主项目重新定位成仅关注共识代码和 P2P 转发的[担忧][harding pri]：普通用户会更难使用全节点来验证自己的钱包入账交易。他询问 Poinsot 和其他贡献者是否考虑过转移重点为让普通用户更易于使用 Bitcoin Core。他介绍了全节点验证的威力：运行自己的全节点来验证绝大部分链上经济活动的用户有能力定义比特币的共识规则。他举出的例子是，哪怕网络所执行的规则仅仅变更 30 分钟，也足以导致比特币的神圣特性遭到政治上的永久破坏，比如 2100 万 BTC 的限制。他认为，比起代表自己的客户运行节点的组织，普通用户会更加看重比特币的属性。Harding 主张，如果 Bitcoin Core 的开发者们重视当前的共识规则，那么，让普通用户能够更容易地验证自己钱包的交易，就跟防止和消除可能导致严重漏洞的 bug（安全性）一样重要。

## 共识变更

*在这个月度栏目中，我们会总结关于变更比特币公式规则的提议和讨论。*

- **<!--bitcoin-forking-guide-->比特币分叉指南**：Anthony Towns 在 Delving Bitcoin 中[发布][towns bfg]了一份关于如何为变更比特币共识规则的想法建立社区共识的指南。他将社会共识的建立分成四个阶段 —— 研究和开发、关键用户探究、行业评估和投资者审核。然后，他简要介绍了最终在比特币软件中激活变更的技术步骤。

  他的帖子指出，“本文只是一份关于合作式路径的指南，这就是说，你提出了一项变更，可以让每个用户都得到好处，并且最终每个人都或多或少同意这项变更对每个人都好。” 他也警告，“这只是非常简略的指南。”

- **<!--update-on-bip360-paytoquantumresistanthash-p2qrh-->** **BIP360 支付到抗量子哈希值（P2QRH）的更新**：开发者 Hunter Beast 在 Bitcoin-Dev 邮件组中[发布][beast p2qrh]了一份更新，关于他为 [BIP360][] 做的关于[量子安全][topic quantum resistance]的研究。他修改了自己提议使用的量子安全算法的列表，并寻找某人能够来领衔开发一种 “支付到 taproot 哈希值（P2TRH）” 方案（详见[周报 #141][news141 p2trh]），并正在考虑将目标设为与比特币当前相同的安全级别（NIST II），而不是需要更多区块空间和 CPU 验证时间的更高级别（NIST V）。他的帖子获得了少许回复。

- **<!--private-block-template-marketplace-to-prevent-centralizing-mev-->为防止中心化的 MEV 而设计隐私的区块模板市场**：Corallo 和开发者 7d5x9 在 Delving Bitcoin 中[讨论][c7 mev]关于允许各方在公开市场中为矿工区块模板内的选定空间竞标的想法。比如，“我将支付 X 比特币来包含交易 Y，只要该交易排在所有跟 Z 所确定的智能合约交互的交易的前面。” 这是比特币上的交易创建者已经希望在许多协议上看到的功能，比如某些 [染色币协议][topic client-side validation]，而且可能会在未来变得更受欢迎，因为还会有新协议出现（包括要求特定的[限制条款][topic covenants]的提议）。

  如果区块模板内优先交易排序的服务不是由减少信任需求的公开市场提供的，那么它就有可能由较大的矿工来提供，他们会跟多种协议的用户竞争。这将要求矿工获得大量的资本和技术机密，可能会导致他们赚得比没有这些资本的较小矿工高得多的收益。这会导致挖矿中心化，而且让大矿工可以更容易地审查比特币交易。

  这些开发者们提议，让矿工可以在盲化的区块模板上挖矿，模板中全部交易都不向矿工揭晓，直至矿工提供足够多的工作量证明、能够广播该区块，从而减少所需的信任因素。这些开发者提出了两种能够实现这一特性而不需要共识变更的机制：

  - **<!--trusted-block-templates-->受信任的区块模板**：一个矿工连接到一个市场，选择自己想要包含在一个区块中的投标，然后请求市场构造出区块模板。市场会响应以一个区块头、coinbase 交易和部分默克尔分支，让这个矿工可以为这个模板生成工作量证明（但不知道其具体内容）。如果这个矿工产生了符合网络 *难度* 的工作量证明，就把区块头和 coinbase 交易提交给市场，市场会验证工作量证明，然后添加到区块模板中，然后广播完整的交易。市场可能会包含一笔交易，给挖矿的矿工支付，或者可能会稍晚另外给矿工支付。

  - **<!--trusted-execution-environments-->受信任的执行环境（TEE）**：矿工获得一个带有 [TEE][] 安全飞地的设备，连接到市场、选择自己想要包含在区块中的投标，然后获得这些投标中的交易的加密形式，密钥是 TEE 的飞地密钥。区块模板会在 TEE 中构造，然后 TEE 会给主管操作系统提供区块头、coinbase 交易以及部分默克尔分支。如果生成了目标工作量证明，矿工就会将工作量证明提供给 TEE，后者验证它，然后返回完整的解密的区块模板，让矿工可以添加区块头并广播出去。同样地，区块模板中可能包含一笔来自市场的给矿工的支付，或者市场可能会另外支付给矿工。

  两种方法都在实质上要求存在多个相互竞争的市场；提议还指出，预期一些社区成员和组织会以非盈利形式运行市场，以保护去中心化、防止一家受信任的市场独大。

## 新版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Core Lightning 25.02][] 是这个热门的闪电节点实现的下一个主要版本的一个发行。它包含了对[对等节点存储][topic peer storage]协议的支持（用于存储加密的惩罚交易，可以检索出来，也可以解密后提供一种类型的[瞭望塔][topic watchtowers]），还有其它提升和 bug 修复。

## 重大的代码和说明书变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Eclair #3019][] 修改了节点的动作，在通道对手发起单方退出的情形中，偏向在交易池中看到的对方的承诺交易，而不是广播己方的承诺交易。以往，节点会广播己方的承诺交易，可能会导致两笔交易间的赛跑。偏向对方的承诺交易对己方也有好处，因为这避免了己方的 `OP_CHECKSEQUENCEVERIFY`（CSV）[时间锁][topic timelocks]延迟，并且不再需要从己方节点发出额外的交易来解决等待中的 [HTLCs][topic htlc] 。

- [Eclair #3016][] 加入了在 “[简单 taproot 通道][topic simple taproot channels]” 中创建闪电交易的底层方法，而不变更任何功能。这些方法是使用 [miniscript][topic miniscript] 创建出来的，并且跟在 [BOLTs #995][] 规范中列举出来的不同。

- [LDK #3342][] 添加了一种 `RouteParametersConfig` 构造体，让用户能够为 [BOLT12][topic offers] 发票支付定制路由参数。以往受制于 `max_total_routing_fee_msat`，新的构造体包含了 [`max_total_cltv_expiry_delta`][topic cltv expiry delta]、`max_path_count` 和 `max_channel_saturation_power_of_half`。这一变更让 [BOLT12][] 的参数设定跟 [BOLT11][] 的一致。

- [Rust Bitcoin #4114][] 将见证以外的交易体积的下限从 85 字节降低到 65 字节，跟 Bitcoin Core 的策略保持一致（详见周报 [#222][news222 minsize] 和 [#232][news232 minsize]）。这一变更允许更小的交易得到传播，比如那些只有一个输入和一个 `OP_RETURN` 输出的。

- [Rust Bitcoin #4111][] 加入对新的 [P2A][topic ephemeral anchors] 标准输出类型的支持（在 Bitcoin Core 中由 28.0 引入，详见[#315][news315 p2a]）。

- [BIPs #1758][] 更新了 [BIP374][]，将消息字段的内容合并到了 `rand` 的计算中；该 BIP 定义了 “离散对数等式证据（[DLEQ][topic dleq]）”（详见周报 [#335][news335 dleq]）。这一变更防止了如果两个证据基于相同的 `a`、`b` 和 `g` 构造，但使用不同的消息和一个全部为 0 的 `r`，从而泄露 `a`（私钥）的情形。

- [BIPs #1750][] 更新了 [BIP329][]，添加了跟地址、交易和输出相关的可选字段，还包含了一项 JSON 类型修复。该 BIP 定义了一种导出[钱包标签][topic wallet labels]的格式。

- [BIPs #1712][] 和 [BIPs #1771][] 添加了 [BIP3][]，替代了 [BIP2][] 并对 BIP 流程做了多项更新。变更内容包括减少状态字段的值（从 9 个减少到 4 个）、允许处在 “Draft（草案）” 状态的 BIP 在长达一年时间里没有进展（作者也不确认持续工作）之后被任何人标记为 “Closed（关闭）”、防止 BIP 无限期处于 “Complete（完成）” 状态、支持持续更新、将部分编辑决定从 BIP 编辑重新分配给作者（或者库的观众）、取消评论系统，并要求 BIP 被讨论才能获得编号，还对 BIP 的格式和序言作了多项更新。

{% include references.md %}
{% include linkers/issues.md v=2 issues="3019,3016,3342,4114,4111,1758,1750,1712,1771,1233,995" %}
[Core Lightning 25.02]: https://github.com/ElementsProject/lightning/releases/tag/v25.02
[news39 multiprocess]: /zh/newsletters/2019/03/26/#bitcoin-core-10973
[news141 p2trh]: /zh/newsletters/2021/03/24/#we-could-add-a-hash-style-address-after-taproot-is-activated
[poinsot pri]: https://delvingbitcoin.org/t/antoine-poinsot-on-bitcoin-cores-priorities/1470/
[poinsot pri1]: https://antoinep.com/posts/core_project_direction/
[poinsot pri2]: https://antoinep.com/posts/stating_the_obvious/
[poinsot pri3]: https://antoinep.com/posts/bitcoin_core_scope/
[towns pri]: https://delvingbitcoin.org/t/antoine-poinsot-on-bitcoin-cores-priorities/1470/3
[towns pri2]: https://delvingbitcoin.org/t/antoine-poinsot-on-bitcoin-cores-priorities/1470/15
[harding pri]: https://delvingbitcoin.org/t/antoine-poinsot-on-bitcoin-cores-priorities/1470/10
[towns bfg]: https://delvingbitcoin.org/t/bitcoin-forking-guide/1451
[beast p2qrh]: https://mailing-list.bitcoindevs.xyz/bitcoindev/8797807d-e017-44e2-b419-803291779007n@googlegroups.com/
[c7 mev]: https://delvingbitcoin.org/t/best-worst-case-mevil-response/1465
[tee]: https://zh.wikipedia.org/wiki/%E5%8F%AF%E4%BF%A1%E5%9F%B7%E8%A1%8C%E7%92%B0%E5%A2%83
[news17 cln2000]: /zh/newsletters/2018/10/16/#c-lightning-2000
[morehouse failback]: https://delvingbitcoin.org/t/disclosure-lnd-excessive-failback-exploit/1493
[lnd current]: https://github.com/lightningnetwork/lnd/releases
[news222 minsize]: /zh/newsletters/2022/10/19/#minimum-relayable-transaction-size
[news232 minsize]: /zh/newsletters/2023/01/04/#bitcoin-core-26265
[news315 p2a]: /zh/newsletters/2024/08/09/#bitcoin-core-30352
[news335 dleq]: /zh/newsletters/2025/01/03/#bips-1689
