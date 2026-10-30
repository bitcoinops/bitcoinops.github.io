---
title: 'Bitcoin Optech Newsletter #190'
permalink: /zh/newsletters/2022/03/09/
name: 2022-03-09-newsletter-zh
slug: 2022-03-09-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了关于未来软分叉应该在多大程度上提升 Bitcoin Script 与 Tapscript 语言表达能力的多方面讨论，并总结了一项向洋葱消息转发带宽收费的提议。文末照例包含 Bitcoin Core PR 审查俱乐部会议摘要、新版软件发布与候选发布公告，以及对流行比特币基础设施项目中值得注意的代码与文档变更的介绍。

## 新闻

- **<!--limiting-script-language-expressiveness-->****限制 Script 语言表达能力：**
  在 Bitcoin-Dev 邮件列表上，围绕向 Script 提议新增 `OP_TXHASH` 或 `OP_TX` 操作码（见 Newsletter [#185][news185 optxhash] 与 [#187][news187 optx]），衍生出了若干子讨论。Jeremy Rubin [指出][rubin recurse]，这些提议（可能再结合如 [OP_CAT 操作码][OP_CAT]等其他操作码提案）或将允许创建递归[契约][topic covenants]——即在每一笔重花这些比特币、或重花与其合并的任何比特币的交易中都必须永久满足的条件。有人[询问][harding recurse]大家是否担心在比特币中允许递归契约，下面概述了其中几项最值得关注的担忧：

  - **<!--gradual-loss-of-censorship-resistance-->***渐进式丧失抗审查性：* 贡献者 Shinobi [重申][shinobi recurse]他在 [Newsletter #157][news157 csfs] 中提出过的担忧，即递归契约会让强大的第三方得以控制某一实体当前所持任意币的后续花费。例如，政府可以（通过立法）要求其公民只接受政府之后可没收的币（由比特币共识规则强制实施）。

    对 Shinobi 帖子的[回复][aj reply]与[回应][darosior reply]都呼应了[一年前][harding altcoin]的论点：用户切换到具有同样第三方控制要求的替代加密货币（altcoin）或类似侧链的结构，同样也可能导致抗审查性的逐步丧失。

  - **<!--encouraging-unnecessary-computation-->***鼓励不必要的计算：* 开发者 James O'Beirne [表达][obeirne reply]了担忧，认为给 Bitcoin Script 或 [tapscript][topic tapscript] 增加过多表达能力，会鼓励人们创建这样的脚本：其操作数量超过证明“某个获授权花费该币的人确实选择花费这笔钱”所必需的最小数量。理想情况下，今天任何 UTXO（币）都可以用一份简洁的证明来花费，例如 64 字节的 [schnorr 签名][topic schnorr signatures]。比特币已经允许用更复杂的脚本来创建合约，例如多重签名合约和 LN 之类协议，但这种能力可能被滥用，在脚本中加入并非执行合约条款所必需的操作。例如，比特币过去曾面临[拒绝服务攻击][cve-2013-2292]的风险，攻击来自经过特殊设计的交易，这些交易反复执行需要消耗大量 CPU 或内存的操作。O'Beirne 担心，提升表达能力既可能产生新的 DoS 向量，也可能导致程序员编写未优化的脚本，消耗超出必要的节点资源。

  - **<!--introduction-of-turing-completeness-->***引入图灵完备性：* 开发者 ZmnSCPxj [批评][zmn turing]说，允许创建*有意为之的*递归契约的操作码，同样也会让人*无意间*造出递归契约。投入递归契约的资金，无论出于故意还是意外，都再也无法与普通比特币完全可互换（fungible）。ZmnSCPxj 将这一担忧放在[图灵完备性][turing completeness]与[停机问题][halting problem]的语境下阐述。

  - **<!--enablement-of-drivechains-->***促成 drivechain：* 在前述图灵完备性的论点基础上，ZmnSCPxj 进一步[主张][zmn drivechains]，提升 Script 表达能力还会使 [drivechain][topic sidechains] 得以实现，其原理与 [BIP300][] 所述类似，而多位 Bitcoin 开发者曾[指出][towns drivechains]这可能导致用户资金损失或抗审查性下降。如果比特币经济中选择运行全节点、强制执行该 drivechain 规则的参与者不够多，drivechain 用户就可能丢失资金；但若经济中有相当大一部分参与者确实选择执行该 drivechain 的规则，其他想留在共识之中的用户就必须验证该 drivechain 的全部数据——这实际上就在从未有过显式软分叉决定修改比特币规则的情况下，把该 drivechain 变成了比特币的一部分。

    这个子话题引发了长时间的讨论，并产生了一个[衍生讨论帖][drivechains vs ln]，比较在占多数的挖矿算力试图窃取比特币时，drivechain 与 LN 的安全性。

- **<!--paying-for-onion-messages-->****为洋葱消息付费：**
  Olaoluwa Osuntokun 本周在 Lightning-Dev 邮件列表[发帖][osuntokun bandwidth]，讨论让节点为其发送[洋葱消息][topic onion messages]所用带宽付费的可能性。此前提议的洋葱消息协议允许一个节点沿 LN 路径向另一节点发送消息，而无需使用 [HTLC][topic htlc]。对于 keysend 式消息，洋葱消息相较 HTLC 的主要优势在于无需临时锁定任何比特币，因而更省成本、也更灵活（例如即便双方之间没有通道，也能发送洋葱消息）。然而发送洋葱消息没有直接的经济成本，也令一些开发者担心它会被用来在 LN 上免费转发流量，增加运营 LN 节点的开销，并激励大量节点关闭洋葱消息转发功能。如果洋葱消息被用于节点之间的重要通信（例如为 [offers][topic offers] 提议的用法），此问题尤为严重。

  Osuntokun 提议，节点可以预付其希望使用的洋葱消息带宽。例如，Alice 想通过 Bob 与 Carol 向 Zed 转发 10 kB 数据，她先使用 [AMP][topic amp] 按 Bob 与 Carol 各自节点公布的消息中继费率，向他们支付至少 10 kB 带宽的费用。支付时，Alice 在他们各自处登记一个唯一的会话 ID，并在请求他们转发的加密消息中包含该 ID。如果 Alice 支付的金额足以覆盖其消息所用的带宽，Bob 与 Carol 就会参与把消息转发给 Zed。

  Rusty Russell [回复][russell reply]并提出数点批评，主要包括：

  - **<!--htlcs-are-already-currently-free-->***HTLC 目前本就免费：* 针对“洋葱消息免费转发”担忧的主要反驳一直是：目前已经可以用 HTLC 在 LN 上几乎免费地转发流量。[^htlcs-essentially-free] 但尚不确定这种情况能否永久维持——许多修复[通道堵塞攻击][topic channel jamming attacks]的提案都建议对失败的 HTLC 收费，而目前正是靠这些失败的 HTLC 才能免费传输数据。

  - **<!--session-identifiers-reduce-privacy-->***会话标识符削弱隐私：* 在前述例子中，Alice 在 Bob 与 Carol 处注册的会话 ID 让两者可以知道哪些消息源自同一用户。若无会话 ID，他们无法分辨消息是否来自同一用户，或是来自多位使用同一路径片段的不同用户。Russell 指出，他在洋葱消息研究过程中考虑过盲化令牌，但担心“很快会变得复杂”。

  Russell 转而建议，直接对节点转发的洋葱消息数量做速率限制（不同类别的对等节点适用不同上限）。

## Bitcoin Core PR 审查俱乐部

*在本月度栏目中，我们总结最近一次 [Bitcoin Core PR Review Club][] 会议，突出其中的重要问答。点击下面的问题可查看会议答案摘要。*

[向监听非默认端口的节点建立 p2p 连接][reviews 23542] 是 Vasil Dimov 的一个 PR，用于移除在选择出站对等节点时对 8333 端口的优待。参与者讨论了 Bitcoin Core 的自动连接行为、没有默认端口的网络有何好处，以及避开某些端口的理由。

{% include functions/details-list.md
  q0="<!--q0-->默认端口 8333 获得优待的历史原因是什么？"
  a0="该行为自始即存在，但中本聪的动机尚不确定。常见传闻称，此举可防止他人通过广播某服务的地址、借比特币网络对该服务发起 DoS 攻击，但这并非真实的历史原因。另一种传说是，默认端口有助于防止攻击者仅用一个 IP 地址配合多个端口（即我们现在所说的 [日食攻击][topic eclipse attacks]）就占据节点的 IP 地址表，从而控制 P2P 连接。"
  a0link="https://bitcoincore.reviews/23542#l-43"

  q1="<!--q1-->移除端口 8333 的优待有什么好处？"
  a1="最初用于过滤并存储潜在对等节点 IP 地址的方法并不如今日这般复杂；我们现在按地址的 netgroup、AS、来源对等节点等限制存储的 IP 数量，也会对处理和中继的地址总量做速率限制。鉴于地址管理器（addrman）与地址中继已有这些改进，该优待对防止 eclipse 与 DoS 攻击几乎已无影响。此外，偏好默认端口意味着几乎不会连接到监听非默认端口的节点。这还构成一处隐私泄露，本地网络管理员只需查看 8333 端口就能轻松识别比特币流量。若某政府想要封禁比特币，只要指示 ISP 记录和/或封锁单一端口的流量，远比监控所有连接上收发的数据来识别比特币流量容易得多。"
  a1link="https://bitcoincore.reviews/23542#l-72"

  q2="<!--q2-->在此次修改前，自动连接监听非默认端口的对等节点虽不被鼓励，但并非不可能。在哪些情况下节点仍会连接这类对等节点？"
  a2="在自动连接逻辑中，节点会尝试连接从地址管理器中随机选取的地址。如果 50 次尝试均未成功，它就会开始考虑非默认端口的地址。有参与者指出，功能测试中的节点也不使用默认端口，但随后有人指出，这些节点是通过手动连接连上的，而非自动出站连接。"
  a2link="https://bitcoincore.reviews/23542#l-123"

  q3="<!--q3-->合并该 PR 后，默认端口仍在 Bitcoin Core 中扮演什么角色？"
  a3="当未指定端口时，会使用默认端口。这对 DNS 种子尤为重要，新节点需通过它们来为地址管理器引导地址。若要彻底移除“默认端口”概念，则需寻找替代方案，因为 DNS 旨在把域名解析为 IP 地址，而非提供服务的地址与端口。"
  a3link="https://bitcoincore.reviews/23542#l-137"

  q4="<!--q4-->为什么允许调用方向 CServiceHash 传入 salt，并在提交 [d0abce9][salt commit] 中以 CServiceHash(0, 0) 初始化？"
  a4="节点大约每 24 小时公告一次自己的地址，每个节点还会 gossip 所获传闻地址，帮助网络中的节点发现新的对等节点。这段代码使用 IP 地址与当前时间的哈希，随机挑出一两个对等节点，把最近收到的地址中继给它们。但我们不希望只要多次发送同一地址就能提升其传播概率，因此使用相同的 salt (0, 0)，时间戳粒度为一天。"
  a4link="https://bitcoincore.reviews/23542#l-197"
%}

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [LDK 0.0.105][] 新增对幻影节点支付的支持（见 [Newsletter #188][news188 phantom]）以及更好的概率支付寻路（见 [Newsletter #186][news186 pp]），此外还带来多项其他功能与缺陷修复（包括[两个潜在的 DoS 漏洞][rl dos]）。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]中值得注意的变更。*

- [Bitcoin Core #23542][] 移除了 Bitcoin Core 仅连接默认比特币端口（主网为 8333）对等节点的偏好。现在，除了几十个已知被其他服务使用的端口之外，Bitcoin Core 会与任何端口上的对等节点建立连接。8333 仍是 Bitcoin Core 在本地绑定的默认端口，因此只有覆盖了默认值的节点才会公告自己接受其他端口的连接。关于此变更的更多信息，可参阅本期 Newsletter 前文 *Bitcoin Core PR 审查俱乐部* 的摘要。

- [BDK #537][] 将钱包地址缓存重构为公共方法。此前，确保钱包内部数据库已加载并缓存地址只能通过内部函数实现——这意味着离线钱包无法保证数据库已经加载地址。此补丁使离线钱包用于多重签名签名以及验证找零地址等场景成为可能。相关地，[BDK #522][] 添加了内部地址 API，方便应用创建将一个输出拆分成多个小输出的交易。

## 脚注

[^htlcs-essentially-free]:
    当用户 Alice 通过路由节点 Bob 与 Carol 把基于 HTLC 的 keysend 消息转发给用户 Zed 时，Alice 可以构造一个没有已知原像的哈希，保证该 HTLC 必然失败，从而 Bob 与 Carol 都拿不到钱。Alice 发送这类消息所承担的唯一成本，是创建通道的费用（若通道由她创建）以及事后关闭通道的费用（若关闭费用由她承担）——此外还有一项风险：攻击者可能窃取她 LN 热钱包的私钥，或窃取其他任何可能危及她 LN 通道的数据。对于一个安全、无漏洞且通道长期存在的节点来说，这些成本应当基本为零，因此基于 HTLC 的 keysend 消息目前可以视作免费。

{% include references.md %}
{% include linkers/issues.md v=1 issues="23542,522,537" %}
[ldk 0.0.105]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.105#security
[news185 optxhash]: /zh/newsletters/2022/02/02/#composable-alternatives-to-ctv-and-apo
[news187 optx]: /zh/newsletters/2022/02/16/#simplified-alternative-to-op-txhash
[rubin recurse]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019872.html
[shinobi recurse]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019891.html
[news157 csfs]: /zh/newsletters/2021/07/14/#request-for-op-checksigfromstack-design-suggestions
[darosior reply]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019892.html
[aj reply]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019923.html
[harding altcoin]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-July/019203.html
[obeirne reply]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019890.html
[cve-2013-2292]: /en/topics/cve/#CVE-2013-2292
[zmn turing]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019928.html
[zmn drivechains]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019976.html
[turing completeness]: https://en.wikipedia.org/wiki/Turing_completeness
[halting problem]: https://en.wikipedia.org/wiki/Halting_problem
[towns drivechains]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019984.html
[drivechains vs ln]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019991.html
[osuntokun bandwidth]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-February/003498.html
[russell reply]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-February/003499.html
[harding recurse]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019885.html
[rl dos]: https://github.com/lightningdevkit/rust-lightning/blob/main/CHANGELOG.md#security
[news188 phantom]: /zh/newsletters/2022/02/23/#ldk-1199
[news186 pp]: /zh/newsletters/2022/02/09/#ldk-1227
[salt commit]: https://github.com/bitcoin-core-review-club/bitcoin/commit/d0abce9a50dd4f507e3a30348eabffb7552471d5
[reviews 23542]: https://bitcoincore.reviews/23542
