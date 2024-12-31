---
title: 'Bitcoin Optech Newsletter #152'
permalink: /zh/newsletters/2021/06/09/
name: 2021-06-09-newsletter-zh
slug: 2021-06-09-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了一个提案，允许闪电网络（LN）节点无需始终在线保管其私钥就能接收付款。此外，还包含我们常规的 Bitcoin Core PR 审查俱乐部会议摘要，以及关于新软件版本与候选发布的公告，以及对常用比特币基础设施软件中值得注意的变更描述。

## News

- **<!--receiving-ln-payments-with-a-mostly-offline-private-key-->****使用大部分离线私钥接收闪电网络支付：**2019 年，开发者 ZmnSCPxj [提出][zmn ff]了一种替代方案，用来打包等待中的 LN 支付（[HTLCs][topic htlc]），从而减少接收支付所需的网络带宽和延迟。最近，Lloyd Fournier 进一步指出，这个想法或许也能让节点在无需上线其私钥的情况下接收多笔闪电网络付款。该方案存在一些局限：

  - 如果需要发起惩罚交易（penalty transaction），节点依然需要使用其私钥。
  - 节点在未使用私钥的情况下接收的付款越多，当通道被单方面关闭时就需要支付更多的链上费用。
  - 接收节点会失去隐私——它的直接对等节点能够确定它是最终的收款方，而不仅仅是一个路由节点。然而，对于某些不路由付款的终端用户节点而言，这一点本就可能十分明显。

  在上述限制下，这一想法看起来仍然可行，其变体也在本周的邮件列表上引发了[讨论][zmn revive]；ZmnSCPxj 提供了一份清晰的[展示材料][zmn preso]。随后 Fournier [提出][fournier asym]了改进方案。

  若要实现该想法，需要在 LN 协议层面进行多处重大修改，因此短期或中期内用户不太可能用上。但任何想要尽量减少 LN 接收节点在线保管密钥需求的人都可以考虑研究该方案。

## Bitcoin Core PR 审查俱乐部

*在本月度栏目中，我们总结了近期一次 [Bitcoin Core PR 审查俱乐部][Bitcoin Core PR Review Club] 会议的主要内容，并突出其中一些重要问答。点击下方某个问题，可查看该会议对答案的概要。*

[修剪 g_chainman 在辅助模块中的使用][review club #21767] 是一个由 Carl Dong 提出的重构拉取请求（[#21767][Bitcoin Core #21767]），其目标是为去全局化 `g_chainman` 迈出第一步，以实现共识引擎的模块化。这将分离各组件，并实现更加针对性的测试。更长期的目标是将共识引擎与非共识代码彻底分离。

本次审查俱乐部在深入探讨代码改动前，首先讨论了以下一些通用问题：

{% include functions/details-list.md
  q0="**<!--q0-->**这个拉取请求是一次重构，不应改变任何功能行为。我们可以通过哪些方式来验证这一点？"
  a0="仔细审阅代码、运行测试、增加测试覆盖率、插入断言或自定义日志记录、使用 `--enable-debug` 编译、在应用更改后运行 bitcoind 并使用 GDB 或 LLDB 等调试器单步跟踪代码。"
  a0link="https://bitcoincore.reviews/21767#l-53"

  q1="**<!--q1-->**该拉取请求属于更大项目的一部分，旨在将 Bitcoin Core 的共识引擎模块化并进行分离。这样做有哪些好处？"
  a1="这能让我们更容易理解、维护、配置和测试代码，并通过提供一个最小化的 API 来增强安全性与可维护性，还可以通过配置选项来传递非全局化数据。我们能够为不同组件构造可变的参数，从而在不同配置下更好地掌控对它们的测试。"
  a1link="https://bitcoincore.reviews/21767#l-63"

  q2="**<!--q2-->**`ChainstateManager` 的职责是什么？"
  a2="[`ChainstateManager`][ChainstateManager] 类为创建并与一个或两个链状态进行交互提供接口：一个是初始区块下载（IBD），另一个是可选的快照。"
  a2link="https://bitcoincore.reviews/21767#l-117"

  q3="**<!--q3-->**`CChainState` 的作用是什么？"
  a3="[`CChainState`][CChainState] 类存储当前最优链，并提供用于更新我们本地链状态信息的 API。"
  a3link="https://bitcoincore.reviews/21767#l-174"

  q4="**<!--q4-->**`CChain` 类是什么？"
  a4="[`CChain`][CChain] 类是一个内存中索引的区块链结构，包含一个 [区块索引指针的向量][cchain vectors]。"
  a4link="https://bitcoincore.reviews/21767#l-120"

  q5="**<!--q5-->**`BlockManager` 的职责是什么？"
  a5="[`BlockManager`][BlockManager] 类维护了存储在 `m_block_index` 中的区块树，用于查找工作量最高的链尖端。"
  a5link="https://bitcoincore.reviews/21767#l-121"

  q6="**<!--q6-->**`cs_main` 是什么？"
  a6="`cs_main` 是一个互斥锁，用于保护与验证相关的数据（当然，目前也保护很多其他内容）。名字来自 [*critical section main*][csmain1]，因为它保护 `main.cpp` 中的数据，而现在位于 `validation.cpp` 和 `net_processing.cpp` 的代码[以前都在名为 `main.cpp` 的单个文件里][csmain2]。"
  a6link="https://bitcoincore.reviews/21767#l-202"

  q7="**<!--q7-->**从概念上讲，当我们提到代码库中的“validation”部分时，包含哪些内容？"
  a7="“Validation” 负责存储并维护我们对区块链及其关联 UTXO 集的最佳视图，同时也提供将未确认交易提交至内存池的接口。"
  a7link="https://bitcoincore.reviews/21767#l-228"
%}

## 发布与候选发布

*适用于常用比特币基础设施项目的新版本与候选发布版本。请考虑升级到新版本，或协助测试候选发布版本。*

- [LND 0.13.0-beta.rc5][LND 0.13.0-beta]
  这是一个候选发布版本，允许使用修剪过的比特币完整节点，以及使用原子多路径支付（Atomic MultiPath，简称 [AMP][topic multipath payments]）接收和发送付款，并增强了其 [PSBT][topic psbt] 功能，还包含其他改进及错误修复。

## 值得注意的代码和文档更改

*以下是本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]中的值得注意的更改：*

- [Bitcoin Core #22051][]
  为 Bitcoin Core 钱包导入 [taproot][topic taproot] 输出的[描述符][topic descriptors]提供了支持。通过该改动，钱包用户可以接收发送至 taproot 输出的资金，这是另一个[开放中的拉取请求][Bitcoin Core #21365]的前置条件，该拉取请求将实现从生成到支出 taproot 输出的完整功能。

- [Bitcoin Core #22050][]
  移除了对第 2 版 Tor 洋葱服务（隐藏服务）的支持。第 2 版服务已被弃用，Tor 项目方宣布它们将在今年 9 月起无法再访问。Bitcoin Core 已支持第 3 版洋葱服务（具体内容参见 [Newsletter #132][news132 v3onion]）。

- [Bitcoin Core #22095][]
  添加了一个测试，用于检查 Bitcoin Core 派生 [BIP32][] 私钥的过程。虽然 Bitcoin Core 始终正确派生这些密钥，但最近[发现][btcd issue]有部分其他钱包在处理长度不足 32 字节的扩展私钥（xpriv）时未做填充，从而在派生少量（大约 1/128）密钥时会出现偏差。该问题并不会直接导致资金丢失或安全性下降，但会给以下场景带来隐患：用户在一个钱包中创建 HD 钱包种子并导入到另一个钱包，或构建多重签名钱包。本次 PR 中实现的测试向量也[添加][bips #1030]到了 BIP32 中，旨在帮助未来的钱包作者避免此问题。

- [C-Lightning #4532][]
  添加了实验性功能，支持[升级某个通道][bolts #868]——也就是重建最新承诺交易（commitment transaction）以整合新的功能或结构变动，例如改用 [taproot][topic taproot]。该过程从请求 [quiescence][bolts #869] 开始，也就是双方同意在暂停期间不发送任何新的状态更新，然后在此阶段里协商并应用各自想实现的更改，最后恢复通道的完整运行。当前 C-Lightning 在连接重新建立期间（当通道已被迫暂停时）执行这一过程。社区对通道升级方案也有过多次讨论（参见 [Newsletter #108][news108 channel upgrades]），本次 PR 的作者想借此特性继续推进 “[简化 HTLC 协商][news109 simplified htlc]” 中所述的工作。该 PR 允许把旧通道升级为支持 `option_static_remotekey`，这是 C-Lightning 在 2019 年加入的功能，详见 [Newsletter #64][news64 static remotekey]。

- [LND #5336][]
  用户现在可以通过指定新的支付 secret（payment secret），在无需额外交互的情况下重新使用 [AMP][topic multipath payments] 发票。为了支持此类重复使用机制，LND 为 AMP 发票设置的默认过期时间也提升至 30 天。

- [BTCPay Server #2474][]
  新增了用于测试 Webhooks 的功能，会发送包含所有常规字段但填充虚拟数据的测试事件。该功能与部分中心化比特币支付处理平台（例如 Stripe、Coinbase Commerce 等）的测试功能类似。

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
