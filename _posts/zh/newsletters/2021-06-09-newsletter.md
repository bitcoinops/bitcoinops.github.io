---
title: 'Bitcoin Optech Newsletter #152'
permalink: /zh/newsletters/2021/06/09/
name: 2021-06-09-newsletter-zh
slug: 2021-06-09-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了一个提案，让闪电网络（LN）节点无需始终把私钥保持在线就能接收付款。此外，还包含我们常规的 Bitcoin Core PR 审查俱乐部会议摘要，以及关于新软件版本与候选发布的公告，以及对热门比特币基础设施软件值得注意的变更的描述。

## 新闻

- **<!--receiving-ln-payments-with-a-mostly-offline-private-key-->****使用大部分离线私钥接收闪电网络支付：**2019 年，开发者 ZmnSCPxj [提出][zmn ff]了一种替代方案，用来封装待处理的 LN 支付（[HTLC][topic htlc]），从而减少接收一笔支付所需的网络带宽和延迟。最近，Lloyd Fournier 提出，这个想法或许也能让节点无需私钥保持在线，就能接受多笔传入的 LN 付款。该方案确实有一些缺点：

  - 如果需要发送惩罚交易（penalty transaction），节点依然需要使用其私钥。

  - 节点在未使用私钥的情况下接收的付款越多，当通道被单方面关闭时就需要支付越多的链上手续费。

  - 接收节点会失去隐私——它的直接对等节点能够确定它是最终的收款方，而不仅仅是一个路由节点。不过，对于某些不路由付款的终端用户节点而言，这一点本就可能十分明显。

  在这些限制范围内，这一想法看起来仍然可行，其变体也在本周的邮件列表上引发了[讨论][zmn revive]；ZmnSCPxj 准备了一份清晰的[演示文稿][zmn preso]。随后 Fournier [提出][fournier asym]了对该想法的改进。

  实现该想法需要在 LN 协议层面进行多处重大修改，因此无论短期还是中期，用户都不太可能用上它。不过，任何想要尽量减少 LN 接收节点在线保管密钥需求的人，都不妨研究一下这个想法。

## Bitcoin Core PR 审查俱乐部

*在本月度栏目中，我们总结了近期一次 [Bitcoin Core PR 审查俱乐部][Bitcoin Core PR Review Club] 会议的主要内容，并突出其中一些重要问答。点击下方某个问题，可查看该会议对答案的概要。*

[精简 g_chainman 在辅助模块中的使用][review club #21767] 是由 Carl Dong 提出的一个重构 PR（[#21767][Bitcoin Core #21767]），它属于一个更大项目的一部分，该项目要把 `g_chainman` 去全局化，作为实现共识引擎模块化的第一步。这将解耦各组件，并使测试更有针对性。更长期的目标是把共识引擎与非共识代码彻底分离。

本次审查俱乐部在深入探讨代码改动前，首先讨论了以下一些通用问题：

{% include functions/details-list.md
  q0="**<!--q0-->**这个 PR 是一次重构，不应改变任何功能行为。我们可以通过哪些方式来验证这一点？"
  a0="仔细审阅代码、运行测试、增加测试覆盖率、插入断言或自定义日志记录、使用 `--enable-debug` 编译、在应用更改后运行 bitcoind 并使用 GDB 或 LLDB 等调试器单步跟踪代码。"
  a0link="https://bitcoincore.reviews/21767#l-53"

  q1="**<!--q1-->**该 PR 属于一个更大项目的一部分，旨在把 Bitcoin Core 的共识引擎模块化并分离出去。这样做有哪些好处？"
  a1="这能让我们更容易理解、维护、配置和测试代码。它可以对外提供一个最小化的 API，以兼顾安全性与可维护性，并通过配置选项传入非全局数据。我们还可以用不同的参数来构造组件，从而更好地控制在不同配置下对这些对象的测试。"
  a1link="https://bitcoincore.reviews/21767#l-63"

  q2="**<!--q2-->**`ChainstateManager` 的职责是什么？"
  a2="[`ChainstateManager`][ChainstateManager] 类为创建并与一个或两个链状态进行交互提供接口：一个是初始区块下载（IBD），另一个是可选的快照。"
  a2link="https://bitcoincore.reviews/21767#l-117"

  q3="**<!--q3-->**`CChainState` 的作用是什么？"
  a3="[`CChainState`][CChainState] 类存储当前最优链，并提供用于更新我们本地链状态信息的 API。"
  a3link="https://bitcoincore.reviews/21767#l-174"

  q4="**<!--q4-->**`CChain` 类是什么？"
  a4="[`CChain`][CChain] 类是一个在内存中建立索引的区块序列，内部包含一个[区块索引指针的向量][cchain vectors]。"
  a4link="https://bitcoincore.reviews/21767#l-120"

  q5="**<!--q5-->**`BlockManager` 的职责是什么？"
  a5="[`BlockManager`][BlockManager] 类维护 `m_block_index` 中存储的区块树，并借助它定位工作量最大的链尖。"
  a5link="https://bitcoincore.reviews/21767#l-121"

  q6="**<!--q6-->**`cs_main` 是什么？"
  a6="`cs_main` 是一个互斥锁，用于保护与验证相关的数据（目前也保护很多其他内容）。这个名字来自 [*critical section main*][csmain1]，因为它保护的是 `main.cpp` 中的数据；而现在位于 `validation.cpp` 和 `net_processing.cpp` 的代码[以前都放在名为 `main.cpp` 的同一个文件里][csmain2]。"
  a6link="https://bitcoincore.reviews/21767#l-202"

  q7="**<!--q7-->**从概念上讲，当我们提到代码库中的“validation”部分时，包含哪些内容？"
  a7="“Validation” 负责存储并维护我们对区块链及其关联 UTXO 集的最佳视图，同时也提供将未确认交易提交至内存池的接口。"
  a7link="https://bitcoincore.reviews/21767#l-228"
%}

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [LND 0.13.0-beta.rc5][LND 0.13.0-beta]
  这是一个候选发布版本，增加了对使用修剪过的比特币全节点的支持，允许使用原子多路径支付（Atomic MultiPath，简称 [AMP][topic multipath payments]）接收和发送付款，并增强了其[部分签名比特币交易（PSBT）][topic psbt]功能，还包含其他改进及错误修复。

## 值得注意的代码与文档变更

*以下是本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]的值得注意的变更：*

- [Bitcoin Core #22051][]
  为 Bitcoin Core 钱包导入 [taproot][topic taproot] 输出的[描述符][topic descriptors]提供了支持。有了这个 PR，钱包用户就能接收发送到 taproot 输出的资金；它也是另一个[开放中的 PR][Bitcoin Core #21365] 的前置条件，那个 PR 将完整支持用户向 taproot 输出收款、以及从 taproot 输出花费。

- [Bitcoin Core #22050][]
  移除了对第 2 版 Tor 洋葱服务（隐藏服务）的支持。第 2 版服务已被弃用，Tor 项目已宣布它们将在 9 月变得无法访问。Bitcoin Core 已支持第 3 版洋葱服务（参见 [Newsletter #132][news132 v3onion]）。

- [Bitcoin Core #22095][]
  添加了一个测试，用于检查 Bitcoin Core 派生 [BIP32][] 私钥的过程。Bitcoin Core 一直都能正确派生这些密钥，但最近[发现][btcd issue]，其他一些钱包因为未对长度不足 32 字节的扩展私钥（xpriv）做填充，导致每 128 个密钥中略多于 1 个被错误派生。这不会直接造成资金损失或安全性下降，但会给两类用户带来麻烦：在一个钱包中创建 HD 钱包种子、再导入另一个钱包的用户，以及创建多重签名钱包的用户。本 PR 中实现的测试向量也[添加][bips #1030]到了 BIP32 中，以帮助未来的钱包作者避开这一问题。

- [C-Lightning #4532][]
  添加了实验性支持，可以[升级某个通道][bolts #868]——也就是重建最新的承诺交易（commitment transaction），使其能纳入新功能或结构变动，例如改用 [taproot][topic taproot]。该协议先请求进入[静止期][bolts #869]，也就是约定在静止期结束前双方都不再发送任何新的状态更新。在这段时间里，节点协商并实施它们想要的改动。最后，通道恢复到完整运行状态。C-Lightning 目前放在连接重建期间执行这一过程，此时通道已经处于被迫停摆的状态。各种通道升级提案曾在 [Newsletter #108][news108 channel upgrades] 中讨论过，而这个 PR 的作者想要这一特性，部分原因是为了推进 [Newsletter #109][news109 simplified htlc] 中所述的“简化 HTLC 协商”。这个 PR 允许把旧通道升级到支持 `option_static_remotekey`，C-Lightning 早在 2019 年就加入了对它的支持，参见 [Newsletter #64][news64 static remotekey]。

- [LND #5336][]
  用户现在可以通过指定新的 payment secret，以非交互的方式重复使用 [AMP][topic multipath payments] 发票。为便于上述重复使用机制，LND 创建的 AMP 发票默认过期时间也提高到了 30 天。

- [BTCPay Server #2474][]
  新增了通过发送假事件来测试 webhook 的功能：这些事件包含全部常规字段，但数据是虚构的。这与 Stripe、Coinbase Commerce 等中心化托管的比特币支付处理平台所提供的测试功能类似。

{% include references.md %}
{% include linkers/issues.md issues="22051,22050,22095,4532,869,5336,2474,1030,868,21767,21365" %}
[LND 0.13.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.13.0-beta.rc5
[news64 static remotekey]: /zh/newsletters/2019/09/18/#c-lightning-3010
[news108 channel upgrades]: /zh/newsletters/2020/07/29/#upgrading-channel-commitment-formats
[news109 simplified htlc]: /zh/newsletters/2020/10/21/#simplified-htlc-negotiation
[zmn ff]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-April/001986.html
[zmn revive]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-May/003038.html
[zmn preso]: https://zmnscpxj.github.io/offchain/2021-06-fast-forwards.odp
[fournier asym]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-June/003045.html
[btcd issue]: https://github.com/btcsuite/btcutil/issues/172
[news132 v3onion]: /zh/newsletters/2021/01/20/#bitcoin-core-0-21-0
[cchain vectors]: https://bitcoincore.reviews/21767#l-196
[csmain1]: https://bitcoincore.reviews/21767#l-216
[csmain2]: https://bitcoincore.reviews/21767#l-213
[ChainstateManager]: https://github.com/bitcoin/bitcoin/blob/7a799c9/src/validation.h#L759
[CChainState]: https://github.com/bitcoin/bitcoin/blob/7a799c9/src/validation.h#L502
[CChain]: https://github.com/bitcoin/bitcoin/blob/7a799c9/src/chain.h#L391
[BlockManager]: https://github.com/bitcoin/bitcoin/blob/7a799c9/src/validation.h#L343
