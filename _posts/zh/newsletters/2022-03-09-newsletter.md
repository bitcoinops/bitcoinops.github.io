---
title: 'Bitcoin Optech Newsletter #190'
permalink: /zh/newsletters/2022/03/09/
name: 2022-03-09-newsletter-zh
slug: 2022-03-09-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了关于未来软分叉应该在多大程度上提升 Bitcoin Script 与 Tapscript 语言表达能力的多方面讨论，并总结了一项向洋葱消息转发带宽收费的提议。文末照例包含 Bitcoin Core PR 审查俱乐部会议摘要、新版软件发布与候选发布公告，以及对流行比特币基础设施项目“值得注意的”代码与文档变更的介绍。

## News

- **<!--limiting-script-language-expressiveness-->****限制 Script 语言表达能力：**
  在 Bitcoin-Dev 邮件列表上，由于向 Script 提议新增 `OP_TXHASH` 或 `OP_TX` 操作码（见 Newsletter [#185][news185 optxhash] 与 [#187][news187 optx]），衍生出了若干子讨论。Jeremy Rubin [指出][rubin recurse]，这些提议（可能再结合如 [OP_CAT 操作码][OP_CAT]等其他操作码提案）或将允许创建递归[契约][topic covenants]——也就是随后重花这些比特币或与其合并的任何比特币时，交易都必须永久满足的条件。[有人][harding recurse]询问是否有人担心在比特币中允许递归契约，下面总结了一些最“值得注意的”担忧：

  - **<!--gradual-loss-of-censorship-resistance-->***渐进式丧失抗审查性：* 贡献者 Shinobi [重申][shinobi recurse]他在 [Newsletter #157][news157 csfs] 中提出过的担忧，即递归契约可能让强大的第三方控制其当前掌握的任意币后续的花费。例如，政府可以（通过立法）要求其公民只接受政府之后可没收的币（由比特币共识规则强制实施）。

    对 Shinobi 帖子的[回复][aj reply]以及另一位开发者的[回应][darosior reply]呼应了[一年前][harding altcoin]的论点：用户切换到具有同样第三方控制要求的替代加密货币（altcoin）或类似侧链的结构，同样也可能导致抗审查性的逐步丧失。

  - **<!--encouraging-unnecessary-computation-->***鼓励不必要的计算：* 开发者 James O'Beirne [表达][obeirne reply]了担忧，认为过度提升 Bitcoin Script 或 [Tapscript][topic tapscript] 的表达能力，会鼓励创建包含多于花费授权所必需操作的脚本。理想情况下，任何 UTXO（币）今天都可以用一条简洁的证明来花费，例如 64 字节的 [schnorr 签名][topic schnorr signatures]。比特币已允许更复杂的脚本来创建合约，如多签合约与 LN 之类协议，但这种能力也可能被滥用于在脚本中加入并非合约必要的操作。例如，比特币过去曾因被精心设计以重复消耗大量 CPU 或内存的交易而面临[拒绝服务风险][cve-2013-2292]。O'Beirne 担心增加表达能力既可能产生新的 DoS 向量，也可能导致程序员编写未优化、消耗节点资源超出必要的脚本。

  - **<!--introduction-of-turing-completeness-->***引入图灵完备性：* 开发者 ZmnSCPxj [批评][zmn turing]允许创建*故意*递归契约的操作码，也可能导致*意外*创建递归契约。投入递归契约的资金，无论故意还是意外，都再也无法与普通比特币完全同质化。ZmnSCPxj 将此担忧置于[图灵完备性][turing completeness]与[停机问题][halting problem]的语境下阐述。

  - **<!--enablement-of-drivechains-->***促成 drivechain：* 在前述图灵完备性的论点基础上，ZmnSCPxj 进一步[主张][zmn drivechains]，提升 Script 表达能力还会促成类似 [BIP300][] 所述的[侧链][topic sidechains]（drivechains）的实现，而多位 Bitcoin 开发者曾[指出][towns drivechains]这可能导致用户资金损失或抗审查性下降。如果比特币经济体中不够多的节点选择运行全节点并强制执行 drivechain 规则，那么 drivechain 用户可能丢失资金；但若经济体中大部分节点都选择执行 drivechain 规则，则其他想保持共识的用户就得验证该 drivechain 的全部数据，事实上在未经过显式软分叉修改比特币规则的情况下，把 drivechain 纳入了比特币。

    该子话题展开了长时间讨论，产生了一个[衍生线程][drivechains vs ln]，比较在多数算力试图窃币时 drivechain 与 LN 的安全性。

- **<!--paying-for-onion-messages-->****为洋葱消息付费：**
  Olaoluwa Osuntokun 本周在 Lightning-Dev 邮件列表[发帖][osuntokun bandwidth]，讨论让节点为其发送[洋葱消息][topic onion messages]所用带宽付费的可能性。此前提议的洋葱消息协议允许一个节点沿 LN 路径向另一节点发送消息，而无需使用 [HTLC][topic htlc]。与基于 keysend 的 HTLC 消息相比，洋葱消息的主要优势在于无需临时锁定比特币，从而更省成本且更灵活（例如即便双方之间没有通道，也能发送洋葱消息）。然而发送洋葱消息没有直接的经济成本，也令一些开发者担心其被用于在 LN 上免费转发流量，增加运营 LN 节点的开销，并激励大量节点关闭洋葱消息转发功能。如果洋葱消息被用于节点之间的重要通信（如[报价][topic offers]提案），此问题尤为严重。

  Osuntokun 提议节点可预付其希望使用的洋葱消息带宽。例如，Alice 想通过 Bob 与 Carol 向 Zed 转发 10 kB 数据，她首先使用[AMP][topic amp] 向 Bob 与 Carol 预付各自按节点公布费率计的至少 10 kB 带宽费。在支付时，Alice 向他们各注册一个唯一会话 ID，并在请求他们转发的加密消息中包含该 ID。如果 Alice 预付金额足以覆盖消息带宽消耗，Bob 与 Carol 就会协助把消息转发给 Zed。

  Rusty Russell[回复][russell reply]并提出数点批评，主要包括：

  - **<!--htlcs-are-already-currently-free-->***HTLC 当前已基本免费：* 针对“洋葱消息免费转发”担忧的主要反驳是，使用 HTLC 本就可以在 LN 上几乎免费转发流量。[^htlcs-essentially-free] 但尚不确定这种情况能否永久维持——许多修复[通道阻塞攻击][topic channel jamming attacks]的提案都建议对失败的 HTLC 收费，而这正是目前可用于免费传输数据的手段。

  - **<!--session-identifiers-reduce-privacy-->***会话标识符削弱隐私：* 在前述例子中，Alice 在 Bob 与 Carol 处注册的会话 ID 让两者可以知道哪些消息源自同一用户。若无会话 ID，他们无法分辨消息是否来自同一用户，或是来自多位使用同一路径片段的不同用户。Russell 指出，他在洋葱消息研究过程中考虑过盲化令牌，但担心“很快会变得复杂”。

  Russell 因此建议，仅对节点转发的洋葱消息数量进行速率限制（针对不同类别的对等体设定不同上限）。

## Bitcoin Core PR Review Club

*在本月度板块中，我们总结一次最近的 [Bitcoin Core PR Review Club][] 会议，突出其中的重要问答。点击下面的问题可查看会议答案摘要。*

[向监听非默认端口的节点建立 p2p 连接][reviews 23542] 是 Vasil Dimov 的一个 PR，用于移除在出站节点选择中对 8333 端口的优待。参与者讨论了 Bitcoin Core 的自动连接行为、没有默认端口的网络优势，以及避开特定端口的理由。

{% include functions/details-list.md
  q0="<!--q0-->默认端口 8333 获得优待的历史原因是什么？"
  a0="该行为自始即存在，但中本聪的动机尚不确定。常见传闻称此举可避免通过 gossip 地址来利用比特币网络对某服务发起 DoS，但这并非真实的历史原因。另一种说法是，默认端口有助于防止攻击者仅用一个 IP 地址配合多个端口（即我们现在所说的 [eclipse 攻击][topic eclipse attacks]）就控制节点的 IP 地址表和 P2P 连接。"
  a0link="https://bitcoincore.reviews/23542#l-43"

  q1="<!--q1-->移除端口 8333 的优待有什么好处？"
  a1="最初用于过滤并存储潜在对等体 IP 地址的方法并不如今日这般复杂；我们现在按地址的 netgroup、AS、来源对等体等限制存储的 IP 数量，也对处理和转发的地址总量进行速率限制。鉴于对地址管理器（addrman）和地址转发所做的这些改进，该优待对防止 eclipse 与 DoS 攻击几乎已无影响。此外，偏好默认端口意味着几乎不会连接到监听非默认端口的节点。这也是一个隐私泄露点，本地网络管理员只需监测 8333 端口即可轻松识别比特币流量。若某政府想要封禁比特币，要求 ISP 记录或阻止单一端口的流量，比监测所有连接数据来识别比特币流量要容易得多。"
  a1link="https://bitcoincore.reviews/23542#l-72"

  q2="<!--q2-->在此次修改前，自动连接确实会倾向跳过非默认端口，但并非绝对不连。在哪些情况下节点仍会连接此类对等体？"
  a2="在自动连接逻辑中，节点会尝试随机选取地址管理器中的地址进行连接。如果 50 次尝试均未成功，它就会开始考虑非默认端口的地址。有参与者指出，功能测试中的节点也不使用默认端口，但随后有人指出这些连接是人工手动建立的，而非自动出站连接。"
  a2link="https://bitcoincore.reviews/23542#l-123"

  q3="<!--q3-->合并该 PR 后，默认端口仍在 Bitcoin Core 中扮演什么角色？"
  a3="当未指定端口时，会使用默认端口。这对 DNS 种子尤为重要，新节点需通过它们来为地址管理器引导地址。若要彻底移除“默认端口”概念，则需寻找替代方案，因为 DNS 旨在把域名解析为 IP 地址，而非提供服务的地址与端口。"
  a3link="https://bitcoincore.reviews/23542#l-137"

  q4="<!--q4-->为什么允许调用方向 CServiceHash 传入 salt，并在提交 [d0abce9][salt commit] 中以 CServiceHash(0, 0) 初始化？"
  a4="节点大约每 24 小时公告自己的地址，每个节点还会 gossip 所获传闻地址，帮助网络发现新对等体。该代码使用 IP 地址与当前时间的哈希，随机挑选一到两个对等体转发最近接收的地址。但我们不希望仅通过多次发送同一地址就能提升其传播概率，因此大家使用相同的 salt (0, 0) 与按天取整的时间戳。"
  a4link="https://bitcoincore.reviews/23542#l-197"
%}

## 发布与候选发布

*流行比特币基础设施项目的新版本与候选版本。请考虑升级到新版本，或帮助测试候选版本。*

- [LDK 0.0.105][] 新增对幻影节点支付的支持（见 [Newsletter #188][news188 phantom]）以及更好的概率付款路径寻找（见 [Newsletter #186][news186 pp]），同时还带来多项其他功能与缺陷修复（包括[两个潜在的 DoS 漏洞][rl dos]）。

## “值得注意的”代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]中的“值得注意的”变更。*

- [Bitcoin Core #23542][] 移除了 Bitcoin Core 仅连接至默认端口（主网 8333）的偏好。现在，Bitcoin Core 会连接除少数被其他服务占用的端口外的任何端口。8333 仍是 Bitcoin Core 本地绑定的默认端口，因此仅当节点修改默认端口时，才会公告自己接受其他端口的连接。关于此变更的更多信息，可参阅本期 Newsletter 前文 *Bitcoin Core PR 审查俱乐部* 的摘要。

- [BDK #537][] 将钱包地址缓存重构为公共方法。此前，确保钱包内部数据库已加载并缓存地址只能通过内部函数实现——这意味着离线钱包无法保证数据库已经加载地址。此补丁使离线钱包用于多签签名以及验证找零地址等场景成为可能。相关地，[BDK #522][] 添加了内部地址 API，方便应用创建将一个输出拆分成多个小输出的交易。

## 脚注

[^htlcs-essentially-free]:
    当用户 Alice 通过路由节点 Bob 与 Carol 把基于 HTLC 的 keysend 消息转发给用户 Zed 时，Alice 可构造一个没有已知先像的哈希，使 HTLC 注定失败，从而 Bob 与 Carol 都拿不到钱。Alice 发送此类消息所承担的唯一成本，是她（若由她创建）创建通道的费用及随后关闭通道（若由她承担）时的费用——再加上如果攻击者盗取其 LN 热钱包私钥或其他可能危及通道的数据的风险。对于一个安全且无漏洞、有长期通道的节点而言，这些成本应当基本为零，因此基于 HTLC 的 keysend 消息当前可视作免费。

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
