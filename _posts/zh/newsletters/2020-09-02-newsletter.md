---
title: 'Bitcoin Optech Newsletter #113'
permalink: /zh/newsletters/2020/09/02/
name: 2020-09-02-newsletter-zh
slug: 2020-09-02-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了关于 LN 承诺交易构建方式的提议变更，总结了关于默认 signet 的讨论，并链接到一份把临时信任的 LN 通道标准化的提案。此外，还包括我们常规的栏目：最近转录的演讲与对话、发布与候选发布，以及热门比特币基础设施项目的值得注意的变更。

## 行动项

*本周无。*

## 新闻

- **<!--witness-asymmetric-payment-channels-->****见证不对称支付通道：** Lloyd Fournier 本周在 Lightning-Dev 邮件列表中[发布][witness asymmetric payment channels]了一个提议，建议对 LN 承诺交易的创建方式进行更改并请求反馈。目前，通道内支付是通过构建两笔互相冲突的交易来完成的，即比特币的共识规则只允许其中一笔交易被包含在区块链中。这些交易包含相同的两个输出并具有相同的两个金额——一个支付给 Alice，一个支付给 Bob——但脚本略有不同。

  ![不对称 LN 承诺](/img/posts/2020-09-ln-commitment-asymmetric.dot.png)

  Alice 的脚本允许她单方面关闭通道，但如果 Bob 知道一个 Alice 之前创建的撤销密钥，就有机会花掉她的资金。类似地，如果 Bob 单方面关闭通道，Alice 也能用他创建的一个撤销密钥花掉他的资金。把一把能花掉你的钱的私钥交给对手方，就能有效地*撤销*旧的通道状态，使你有强烈的动机在关闭通道时发布最新的、未撤销的通道状态。

  Fournier 本周提出的建议只是创建一笔由 Alice 和 Bob 共享的承诺交易。创建这笔交易时，Alice 会生成两个花掉自己输出所需的私钥，并把对应的公钥交给 Bob。随后 Bob 给 Alice 一个[适配器签名][topic adaptor signatures]，对应他在承诺交易 2-of-2 多重签名花费中的那一半；只有当这个签名会向 Bob 泄露 Alice 的某个私钥时，该适配器才能转换成 Bob 的签名。Alice 生成的另一个私钥是撤销私钥，如果她想撤销当前通道状态、改用更晚的状态，就把它交给 Bob。类似地，Bob 生成自己的密钥，并从 Alice 那里收到一个适配器签名。

  ![对称 LN 承诺](/img/posts/2020-09-ln-commitment-symmetric.dot.png)

  这样，即使承诺交易对于双方而言是相同的，双方在单方面关闭通道时所使用的签名（称为“见证”）仍会有所不同。如果通道在旧状态下关闭，签名的差异将使未关闭通道的一方能够创建并广播一个惩罚交易。否则，如果通道在最新状态下关闭，双方都将获得各自的资金，就像当前 LN 的运作一样。

  该提案还建议使用基本相同的方案，从哈希时间锁定合约（HTLC）过渡到点时间锁合约（[PTLC][news92 ptlcs]），这也是过去多位 LN 贡献者曾表示支持的目标。

  这种做法的优点在于：它可能减少私有数据的存储量（尽管这[存在争议][zmn reply]），让单方面关闭在链上占用的空间稍微小一些，并且为使用 PTLC 指出了一条路径——这将让 LN 用户在对抗路由节点监控方面获得额外隐私，也会让协议稍微更接近它将来能利用 [schnorr 签名][topic schnorr signatures]优势时的样子。

- **<!--default-signet-discussion-->****默认 signet 讨论：** Michael Folkson 在 Bitcoin-Dev 邮件列表中[发布][default signet post]了一个关于是否应有一个默认 [signet][topic signet] 的问题，类似于比特币现有的默认测试网。Signet 是一类测试网络，其中的有效区块必须由一个或多个受信任的密钥签名；这使它们在测试时比完全去中心化的测试网络更可预测，后者常常遭到恶意破坏。[BIP325][] 描述了 signet 协议，任何人都可以用它创建自己的 signet，但人们[希望][bitcoin core default signet]在 Bitcoin Core（或许还有其他软件）中内置一个默认 signet，让用户只用一个配置选项就能启用。Folkson 提出的第一个问题是，是否有人对此有异议。

  如果确实要有一个默认的 signet，Folkson 提出了一些关于其管理的问题。例如，谁应该控制其签名密钥？应该有多少个密钥？在什么情况下应重置默认 signet？什么时候应由受信任的 signet 区块签名者来实现主网比特币的共识更改？

  欢迎任何有兴趣帮助回答这些问题的人参与讨论。

- **<!--standardizing-temporarily-trusted-ln-channels-->****LN 临时信任通道的标准化：** Roei Erez 在 Lightning-Dev 邮件列表中[发布][temporarily trusted channels]了一项提案，建议把 LN 实现处理新通道的方式标准化：当参与方愿意信任某笔未确认的存款交易时，就按统一方式处理。例如，Alice 付费给 Bob 已运营的业务，让对方为她开一个通道。在这种情况下，Alice 可能愿意信任 Bob 不会双花他的存款交易。Bob 也可以安全地接受 Alice 的通道内支付，因为万一存款交易没有确认，他本来也能拿回全部资金。

  Erez 指出，几个 LN 实现已允许用户选择信任某些未确认的通道，但不同实现之间在某些方面有所差异，例如在存款交易确认之前使用的 `short_channel_id`（该值通常标识存款交易在区块链中的位置，这不适用于未确认的交易）。

  邮件列表讨论的参与者似乎对该提案表示支持。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [btcd 0.21.0-beta][] 现已发布。这是 btcd 自 2019 年 10 月的 0.20.0-beta 以来的首个主要版本，包含大量改进与缺陷修复。

## 最近转录的演讲与对话

*[Bitcoin Transcripts][] 是比特币技术演讲与讨论转录稿的汇集地。在这个月度栏目中，我们会精选介绍上个月的一些转录稿。*

- **<!--nix-bitcoin-->****nix-bitcoin：** nixbitcoindev 在 Stephan Livera 播客上讨论了 nix-bitcoin。nix-bitcoin 是一个实验项目，旨在提高安装比特币节点和闪电网络节点时的安全性。它使用 NixOS 这一函数式 Linux 发行版；由于具备原子性，升级就等同于从头安装。nix-bitcoin 通过极简、可复现和隔离，致力于缩小比特币与闪电网络软件栈的攻击面——确保各程序除非确有必要，否则感知不到其他正在运行的进程。（[转录稿][nixbitcoin transcript]、[音频][nixbitcoin audio]）

- **<!--taproot-activation-->****taproot 激活：** Eric Lombrozo、Luke Dashjr 和 Aaron van Wirdum 讨论了各种 [taproot][topic taproot] 激活提案（见 [Newsletter #107][news107 taproot activation]），并就激活 segwit 软分叉能带来哪些教训（如果有的话）发表了各自的看法。Lombrozo 和 Dashjr 都认为，taproot 激活过程不应拖得太长，对提议代码变更的所有反对意见、批评和审查都应在激活过程开始前完成。因此，他们支持采用单阶段的 [BIP8][] 激活方法，具体参数尚待确定。社区对激活提案的反馈仍在收集中。（[转录稿][activation transcript]、[视频][activation video]）

- **<!--signet-->****Signet：** Kalle Alm 和 AJ Towns 参与了一场关于 [signet][topic signet] 的讨论。讨论探讨了 signet 的设计决策，以及测试网和 regtest 的运作机制。更多细节请参阅[默认 signet 讨论](#default-signet-discussion)这条新闻。（[转录稿][signet transcript]、[视频][signet video]）

- **<!--bitcoin-core-gui-meeting-->****Bitcoin Core GUI 会议：** 一批匿名参与者（包括设计师和开发者）会面讨论了 Bitcoin Core 图形用户界面的现状、可以如何改进，以及改版将受到哪些约束。例如，过去讨论过的一项变更是从 Qt Widgets 迁移到更灵活、更易定制的 Qt QML 框架。（[转录稿][bitcoin core gui transcript]）

- **<!--sydney-meetup-discussion-->****悉尼聚会讨论：** Ruben Somsen 和 Rusty Russell 参与了一场关于状态链、LN 通道升级和 [lnprototest][lnprototest] 的讨论。Somsen 概述了状态链（见 [Newsletter #91][news91 statechains]）如何可能用于换掉你的闪电通道对手方，或者在 DLC（见 [Newsletter #81][news81 dlc]）的情形下，不关闭通道就换掉你仓位的一部分。面对即将到来的各种闪电通道升级提案，参与者推测哪些升级可以使用动态承诺（见 [Newsletter #108][news108 dynamic commitments]），哪些则需要[拼接][topic splicing]。最后，Russell 解释了闪电协议测试套件 lnprototest 如何用来发现现有实现中的缺陷，并在开发新功能时帮助确保各实现之间的互操作性。（[转录稿][sydney transcript]）

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi]、[比特币改进提案（BIPs）][bips repo]和 [闪电网络规范（BOLTs）][bolts repo]中值得注意的更改。*

- [Bitcoin Core #19797][] 违背了中本聪的原始愿景™，移除了对 Bitcoin (Core) 0.2.8 及更早版本所构建 IPv6 地址的一项过时有效性检查。那些早期节点存在一个缺陷，会生成格式错误的地址。这一更改不应对当前的 P2P 网络造成任何影响：受影响的版本无法与当前软件通信，因为 Bitcoin (Core) 0.2.9 为 P2P 消息引入了校验和，而这些校验和后来成为强制要求。

- [Bitcoin Core #19731][] 扩展了 `getpeerinfo` RPC 的输出，新增两个字段：`last_block` 和 `last_transaction`。`last_block` 表示对等节点最近一次向本节点发送一个本节点此前未曾见过、且通过初步有效性检查的区块的时间；`last_transaction` 则是对等节点最近一次向本节点发送、并被本节点接受进内存池的交易的时间。这两个指标都会用于挑选要断开连接的对等节点，因此节点运营者能取到这些值很有用。

- [LND #4527][] 增加了一个新的 `default-remote-max-htlcs` 配置选项，允许用户指定通道中允许存在的未解决 HTLC（支付）的默认最大数量。如果用户需要单方面关闭通道（例如遭遇手续费勒索攻击，见 [Newsletter #103][news103 fee ransom]），这可以尽量减少其需要支付的链上手续费。

- [BIPs #982][] 对 [BIP340][] schnorr 签名做了若干更改（也影响 [BIP341][] taproot）。BIP340 此前曾[更改][pk evenness update]为使用两种不同的决胜规则来表示点的 Y 坐标：签名内的 R 点用平方性，公钥用偶数性。正如[邮件列表所述][r point evenness update]（见 [Newsletter #111][news111 proposed tiebreaker]），本次更新把 R 点也改为使用偶数性，因为实践中并未观察到使用平方性带来的性能提升，而统一的决胜规则能降低复杂度。其他更改包括一些小的修补、澄清和拼写错误修正。

  与[之前的修订][news87 bip 340 updates]类似，BIP340 中带标签哈希（tagged hash）所用的标签也被更改，从而确保为早期草案编写的任何代码所产生的签名，在提议的修订下都无法通过验证。

{% include references.md %}
{% include linkers/issues.md issues="19797,19731,4527,982" %}

[witness asymmetric payment channels]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-August/002785.html
[zmn reply]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-August/002786.html
[default signet post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-August/018145.html
[temporarily trusted channels]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-August/002780.html
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
[pk evenness update]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-February/017639.html
[r point evenness update]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-August/018081.html
[news111 proposed tiebreaker]: /zh/newsletters/2020/08/19/#proposed-uniform-tiebreaker-in-schnorr-signatures
[btcd 0.21.0-beta]: https://github.com/btcsuite/btcd/releases/tag/v0.21.0-beta
[hwi]: https://github.com/bitcoin-core/HWI
