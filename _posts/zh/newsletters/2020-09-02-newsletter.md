---
title: 'Bitcoin Optech Newsletter #113'
permalink: /zh/newsletters/2020/09/02/
name: 2020-09-02-newsletter-zh
slug: 2020-09-02-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了关于 LN 承诺交易构建方式的提议变更，总结了关于默认 signet 的讨论，并链接到 LN 临时信任通道的标准化提案。此外，还包括我们常规的最近转录的演讲和对话、发布与候选发布，以及流行比特币基础设施项目的显著更改。

## 行动项

*本周无。*

## 新闻

- **<!--witness-asymmetric-payment-channels-->****见证不对称支付通道：** Lloyd Fournier 本周在 Lightning-Dev 邮件列表中[发布][witness asymmetric payment channels]了一个提议，建议对 LN 承诺交易的创建方式进行更改并请求反馈。目前，通道内支付是通过构建两笔互相冲突的交易来完成的，即比特币的共识规则只允许其中一笔交易被包含在区块链中。这些交易包含相同的两个输出并具有相同的两个金额——一个支付给 Alice，一个支付给 Bob——但脚本略有不同。

  ![不对称 LN 承诺](/img/posts/2020-09-ln-commitment-asymmetric.dot.png)

  Alice 的脚本允许她单方面关闭通道，但如果 Bob 知道一个 Alice 之前创建的撤销密钥，则可以花费她的资金。类似地，如果 Bob 单方面关闭通道，Alice 也可以使用一个他创建的撤销密钥花费他的资金。向对手方提供一个允许他们花费自己资金的私钥，使得可以有效地“撤销”旧的通道状态，从而激励用户在关闭通道时发布最新的未撤销的通道状态。

  Fournier 本周提出的建议是仅创建一个 Alice 和 Bob 共享的承诺交易。在创建该交易时，Alice 创建两个花费她输出所需的私钥，并将对应的公钥给到 Bob。然后，Bob 给 Alice 一个[适配签名][topic adaptor signatures]，用于承诺交易中 2-of-2 多签支出的一半；如果该签名将泄露 Alice 的一个私钥给 Bob，则适配签名才能转换为 Bob 的签名。Alice 创建的另一个私钥是撤销私钥，如果她想撤销此通道状态并更改为更晚的状态，则将该密钥提供给 Bob。类似地，Bob 生成自己的密钥并接收 Alice 的适配签名。

  ![对称 LN 承诺](/img/posts/2020-09-ln-commitment-symmetric.dot.png)

  这样，即使承诺交易对于双方而言是相同的，双方在单方面关闭通道时所使用的签名（称为“见证”）仍会有所不同。如果通道在旧状态下关闭，签名的差异将使未关闭通道的一方能够创建并广播一个惩罚交易。否则，如果通道在最新状态下关闭，双方都将获得各自的资金，就像当前 LN 的运作一样。

  该提案还建议使用相同的方案从哈希时间锁合约（HTLCs）过渡到点时间锁合约（[PTLCs][news92 ptlcs]），这是过去多个 LN 贡献者支持的一个目标。

  该方法的优点在于可能需要更少的私有数据存储（尽管这[存在争议][zmn reply]），使单方面关闭的链上交易体积更小，并为使用 PTLCs 描述了一条途径，这将为 LN 用户提供更多对抗路由节点监控的隐私，并使协议更接近将来能利用 [Schnorr 签名][topic schnorr signatures]带来优势的状态。

- **<!--default-signet-discussion-->****默认 signet 讨论：** Michael Folkson 在 Bitcoin-Dev 邮件列表中[发布][default signet post]了一个关于是否应有一个默认 [signet][topic signet] 的问题，类似于比特币现有的默认测试网。Signet 是一种测试网络，其中有效区块必须由一个或多个受信任的密钥签名；这使其比完全去中心化的测试网络更适合用于测试，因为去中心化的网络经常遭遇破坏性攻击。[BIP325][] 描述了 signet 协议，任何人都可以创建自己的 signet，但社区希望在 Bitcoin Core（以及可能的其他软件）中包含一个默认的 signet，用户可以通过一个简单的配置选项启用。Folkson 的第一个问题是是否有人对此有异议。

  如果确实要有一个默认的 signet，Folkson 提出了一些关于其管理的问题。例如，谁应该控制其签名密钥？应该有多少个密钥？在什么情况下应重置默认 signet？什么时候应由受信任的 signet 区块签名者来实现主网比特币的共识更改？

  欢迎任何有兴趣帮助回答这些问题的人参与讨论。

- **<!--standardizing-temporarily-trusted-ln-channels-->****LN 临时信任通道的标准化：** Roei Erez 在 Lightning-Dev 邮件列表中[发布][temporarily trusted channels]了一项提案，建议对 LN 实现中的新通道处理方式进行标准化，当参与者愿意信任未确认的存款交易时。例如，Alice 向 Bob 的已有业务支付以便为她开设通道。在这种情况下，Alice 可能愿意信任 Bob 不会双重花费其存款交易。而且 Bob 也可以安全地接受 Alice 的通道内支付，因为如果存款交易未确认，他可以收回所有资金。

  Erez 指出，几个 LN 实现已允许用户选择信任某些未确认的通道，但不同实现之间在某些方面有所差异，例如在存款交易确认之前使用的 `short_channel_id`（该值通常标识存款交易在区块链中的位置，这不适用于未确认的交易）。

  邮件列表讨论的参与者似乎对该提案表示支持。

## 发布与候选发布

*流行比特币基础设施项目的新发布和候选发布。请考虑升级到新版本或帮助测试候选版本。*

- [btcd 0.21.0-beta][] 已发布。这是自 2019 年 10 月发布 0.20.0-beta 以来的首个重大发布，包含大量改进和漏洞修复。

## 最近转录的演讲和对话

*[Bitcoin Transcripts][] 是比特币技术演讲和讨论的转录之家。在此每月特刊中，我们会突出上个月的一些转录内容。*

- **<!--nix-bitcoin-->****nix-bitcoin：** nixbitcoindev 在 Stephan Livera 播客上讨论了 nix-bitcoin。nix-bitcoin 是一个实验项目，旨在提高比特币和闪电节点安装的安全性。它使用 NixOS 函数式 Linux 发行版，其中升级相当于原子性安装。通过简约、可重复性和隔离性，nix-bitcoin 致力于减少比特币和闪电软件堆栈的攻击面——确保程序在不需要时对其他正在运行的进程一无所知。([转录][nixbitcoin transcript], [音频][nixbitcoin audio])

- **<!--taproot-activation-->****Taproot 激活：** Eric Lombrozo、Luke Dashjr 和 Aaron van Wirdum 讨论了各种 [taproot][topic taproot] 激活提案（见 [Newsletter #107][news107 taproot activation]），并就从 Segwit 软分叉激活中能否得到任何教训分享了各自的看法。Lombrozo 和 Dashjr 都认为 taproot 激活过程不应被拖延，所有反对、批评或对提议代码更改的审查应在开始激活过程前完成。因此，他们支持采用单阶段 [BIP8][] 激活方法，具体参数尚待确定。社区对激活提案的反馈仍在收集中。([转录][activation transcript], [视频][activation video])

- **<!--signet-->****Signet：** Kalle Alm 和 AJ Towns 参与了一场关于 [signet][topic signet] 的讨论。讨论中探索了 signet 的设计决策以及测试网和回归测试网的工作机制。有关详细信息，请参阅[默认 signet 讨论](#默认-signet-讨论)新闻项目。([转录][signet transcript], [视频][signet video])

- **<!--bitcoin-core-gui-meeting-->****Bitcoin Core GUI 会议：** 包括设计师和开发者在内的匿名参与者会面讨论了 Bitcoin Core 图形用户界面的当前状态、改进可能性以及该界面改造所面临的约束。例如，过去讨论过的一个变更是从 Qt Widgets 转向更灵活且易于定制的 Qt QML 框架。([转录][bitcoin core gui transcript]).

- **<!--sydney-meetup-discussion-->****悉尼 Meetup 讨论：** Ruben Somsen 和 Rusty Russell 参与了一场关于状态链、LN 通道升级和 [lnprototest][lnprototest] 的讨论。Somsen 概述了状态链（见 [Newsletter #91][news91 statechains]）如何可能用于替换闪电通道对手方，或者在 DLC 的情况下（见 [Newsletter #81][news81 dlc]）无需关闭通道便交换部分持仓。随着各种提议的闪电通道升级即将到来，参与者推测哪些升级可以使用动态承诺（见 [Newsletter #108][news108 dynamic commitments]），哪些则需要[拼接][topic splicing]。最后，Russell 解释了如何使用闪电协议测试套件 lnprototest 来发现现有实现中的漏洞，并帮助在构建新功能时确保跨实现的互操作性。([转录][sydney transcript]).

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi]、[比特币改进提案（BIPs）][bips repo]和 [闪电网络规范（BOLTs）][bolts repo]中值得注意的更改。*

- [Bitcoin Core #19797][] 违背了中本聪的原始愿景™，移除了对 Bitcoin (Core) 0.2.8 及更早版本构建的 IPv6 地址的过时有效性检查。那些早期节点存在一个导致生成格式错误地址的漏洞。由于受影响的版本无法与当前软件通信，此更改不会影响当前的 P2P 网络，因为比特币 (Core) 0.2.9 引入了 P2P 消息的校验和，且该功能后来成为强制性。

- [Bitcoin Core #19731][] 扩展了 `getpeerinfo` RPC 输出，增加了两个新字段：`last_block` 和 `last_transaction`。`last_block` 表示该节点上次收到且未见过的通过初步有效性检查的区块的时间，`last_transaction` 是该节点上次接收到并接受至内存池的交易的时间。这两个指标用于选择断开连接的对等方，对节点操作员来说很有用。

- [LND #4527][] 增加了一个新的 `default-remote-max-htlcs` 配置选项，允许用户指定通道中未解决的 HTLC（支付）默认最大数量。这可以最小化用户在需要单方面关闭通道时支付的链上费用，例如在手续费勒索攻击时（见 [Newsletter #103][news103 fee ransom]）。

- [BIPs #982][] 添加了对 [BIP340][] Schnorr 签名（也影响 [BIP341][] Taproot）的更改。此前 BIP340 曾[更改][pk evenness update]以使用两种不同的优先选择规则传递点的 Y 坐标：在签名中的 R 点使用平方性，在公钥中使用偶数性。正如[邮件列表中描述的][r point evenness update]（见 [Newsletter #111][news111 proposed tiebreaker]），此更新将 R 点更改为使用偶数性，因为在实际中未观察到使用平方性的性能提升，且一致的优先选择简化了复杂性。其他更改包括小的修正、说明和拼写错误修正。

  类似于[之前的修订][news87 bip 340 updates]，BIP340 中标记哈希的标签已更改，确保为先前草案编写的代码生成的签名将无法在提议的修订下通过验证。

{% include references.md %}
{% include linkers/issues.md issues="19797,19731,4527,982" %}

[witness asymmetric payment channels]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-August/002785.html
[zmn reply]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-August/002786.html
[default signet post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-August/018145.html
[temporarily trusted channels]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-August/002780.html
[bitcoin core default signet]: https://github.com/bitcoin/bitcoin/issues/19787#issuecomment-679836225
[news103 fee ransom]: /zh/newsletters/2020/06/24/#ln-fee-ransom-attack
[news92 ptlcs]: /zh/newsletters/2020/04/08/#work-on-ptlcs-for-ln-using-simplified-ecdsa-adaptor-signatures
[nixbitcoin transcript]: https://diyhpl.us/wiki/transcripts/stephan-livera-podcast/2020-07-26-nix-bitcoin/
[nixbitcoin audio]: https://stephanlivera.com/episode/195/
[news107 taproot activation]: /zh/newsletters/2020/07/22/#taproot-activation-discussions
[activation transcript]: https://diyhpl.us/wiki/transcripts/bitcoin-magazine/2020-08-03-eric-lombrozo-luke-dashjr-taproot-activation/
[activation video]: https://www.youtube.com/watch?v=yQZb0RDyFCQ
[signet transcript]: https://diyhpl.us/wiki/transcripts/london-bitcoin-devs/2020-08-19-socratic-seminar-signet/
[signet video]: https://www.youtube.com/watch?v=b0AiucAuX3E
[bitcoin core gui transcript]: https://diyhpl.us/wiki/transcripts/bitcoin-design/2020-08-20-bitcoin-core-gui/
[news91 statechains]: /zh/newsletters/2020/04/01/#implementing-statechains-without-schnorr-or-eltoo
[news81 dlc]: /zh/newsletters/2020/01/22/#protocol-specification-for-discreet-log-contracts-dlcs
[news108 dynamic commitments]: /zh/newsletters/2020/07/29/#upgrading-channel-commitment-formats
[news87 bip 340 updates]: /zh/newsletters/2020/03/04/#updates-to-bip340-schnorr-keys-and-signatures
[sydney transcript]: https://diyhpl.us/wiki/transcripts/sydney-bitcoin-meetup/2020-08-25-socratic-seminar/
[lnprototest]: https://github.com/rustyrussell/lnprototest
[pk evenness update]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-February/017639.html
[r point evenness update]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-August/018081.html
[news111 proposed tiebreaker]: /zh/newsletters/2020/08/19/#proposed-uniform-tiebreaker-in-schnorr-signatures
[btcd 0.21.0-beta]: https://github.com/btcsuite/btcd/releases/tag/v0.21.0-beta
[hwi]: https://github.com/bitcoin-core/HWI
