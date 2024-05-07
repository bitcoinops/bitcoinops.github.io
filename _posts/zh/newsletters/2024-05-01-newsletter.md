---
title: 'Bitcoin Optech Newsletter #300'
permalink: /zh/newsletters/2024/05/01/
name: 2024-05-01-newsletter-zh
slug: 2024-05-01-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报总结了一个在公钥内嵌入承诺的类 CTV 的提案，研究了对 Alloy 的合约协议的分析，宣布了比特币开发者被捕的消息，并链接到了 CoreDev.tech 开发者见面会的总结。此外，还包括我们的常规部分：新版本和候选版本的发布公告，并总结流行的比特币基础软件的显著变化。

## 新闻

- **类 CTV 的爆破密钥的提议：** Tadge Dryja 在 Delving Bitcoin 上[发布了][dryja
  exploding] 一个符合 OP_CHECKTEMPLATEVERIFY (CTV) 核心思路的更高效版本的提议。通过 CTV，Alice 可以支付到类似于以下的输出：

  ```text
  OP_CTV <hash>
  ```

  哈希摘要的原像是对交易关键部分的承诺，最主要的是每个输出的金额及脚本。例如：

  ```text
  hash(
    2 BTC to KeyB,
    3 BTC to KeyC,
    4 BTC to KeyD
  )
  ```

  如果 `OP_CTV` 操作码在与这些参数完全匹配的交易中执行，它就会成功执行。这意味着 Alice 在一个交易中的输出可以在第二个交易中使用，而不需要额外的签名或任何其他数据，只要第二个交易与 Alice 的预期相符。

  Dryja 提出了另一种方法。Alice 支付到一个公钥（类似于 [taproot][topic taproot] 输出，但采用不同的 segwit 版本）。公钥是由一个或多个真正公钥的 [MuSig2][topic musig] 聚合加上对每个公钥的调整构建而成的，每个公钥都安全地承诺了一个金额。例如（改编自 Dryja 的帖子）：

  ```text
  musig2(
    KeyB + hash(2 BTC, KeyB)*G,
    KeyC + hash(3 BTC, KeyC)*G,
    KeyD + hash(4 BTC, KeyD)*G
  )
  ```

  如果一笔交易支付给隐含公钥的金额与指定金额完全一致，则该交易有效。在这种情况下无需签名。这比在 taproot 中使用 CTV 节省了一些空间，其最少约 16 vbytes<!-- 对于 CTV，内部密钥需要揭示（约 8 vbytes），且 CTV tapscript 需要揭示（约 8 vbytes） -->。与裸脚本（即直接放在输出脚本中）中的 CTV 相比，似乎使用的空间差不多。

  在 taproot 中使用 CTV 时，可以把所有参与方共同商定的 keypath 花费作为执行 CTV 的替代方案，允许各方更改资金去向。对控制 KeyB、KeyC、KeyD 的人来说，爆破密钥也可以实现同样的效果。无论哪种方式，效率都是一样的。

  Dryja 写道，爆破密钥“提供了 OP_CTV 的基本功能，同时节省了几个字节的见证数据。就其本身而言，它可能并不那么吸引人，但我想把它放在那里，因为作为更复杂的限制条款结构的一部分，它可能会是一个有用的原语”。

- **用 Alloy 分析合约协议：** Dmitry Petukhov 在 Delving Bitcoin 上[发布了][petukhov alloy]他使用 [Alloy][] 规范语言为[周报 #291][news291 catvault]中描述的基于 `OP_CAT` 的简单保险库创建的[规范][petukhov spec]。Petukhov 使用 Alloy [找到][petukhov mods]了一些有用的修改，并强调了任何实现者都应遵守的重要约束。我们建议任何对合约协议的形式化建模感兴趣的人阅读他的文章和他大量的文档规范。

- **<!--arrests-of-bitcoin-developers-->比特币开发者被捕：**正如其他渠道的广泛报道，根据美国执法部门的指控，Samourai 隐私增强型比特币钱包的两名开发者上周因其软件被捕。随后，另外两家公司宣布，由于法律风险，他们打算停止为美国客户提供服务。

  Optech 的专长是撰写有关比特币技术的文章，因此我们计划将有关这一法律状况的报道留给其他出版物——但我们敦促任何希望比特币成功的人，尤其是那些在美国或与美国居民有联系的人，随时了解情况，并考虑在有机会时提供支持。

- **CoreDev.tech Berlin 活动：**上个月，很多 Bitcoin Core 贡献者在柏林见面，举行了定期的 [CoreDev.tech][] 活动。与会者提供了活动上部分环节的[抄录][coredev xs]。演讲、代码审阅、工作组以及其他环节。涵盖的主题包括：

  - ASMap 研究发现
  - assumeUTXO 主网成熟度
  - BTC Lisp
  - CMake
  - 族群交易池
  - 选币算法
  - 跨输入的签名聚合
  - 当前网络上的垃圾数据
  - 费用预计
  - 综合的 BIP 讨论
  - 大范围内的共识清理
  - GUI 讨论
  - 古旧钱包实现的移除
  - libbitcoinkernel
  - MuSig2
  - P2P 监控
  - 回顾包中继
  - 私密交易的广播
  - 审阅当前的 GitHub Issues
  - 审阅当前的 GitHub PRs
  - signet/testnet4
  - 静默支付
  - Stratum v2 模板提供者
  - warnet
  - 弱区块

## 版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Bitcoin Inquisition 25.2][] 是这个实验性全节点的最新版本，设计为在 [signet][topic signet] 上测试协议变更。最新版本增加了对 Signet 上 [OP_CAT][topic op_cat] 的支持。

- [LND v0.18.0-beta.rc1][] 是这个流行的闪电网络节点下一个主要版本的候选发布版。

## 重大的代码和文档变更

_本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。_

- [Bitcoin Core #27679][] 允许使用 [ZMQ][] 分发器发送的通知发布到 Unix 域套接字。此前（可能是在无意中）可以通过传递一个配置选项来支持此功能，但没有记录在案。[Bitcoin Core #22087][] 使配置选项解析更严格，使得 Bitcoin Core 27.0 无法再支持这项未记录的功能支持。这[影响了 LND][gugger zmq]，也可能影响了其他程序。本 PR 使该选项得到正式支持，并稍微修改了其语义，使其与 Bitcoin Core 中的其他 Unix 套接字选项保持一致，例如[周报 #294][news294 sockets] 中描述的更改。

- [Core Lightning #7240][] 增加了对从比特币 P2P 网络检索所需区块的支持，如果本地比特币节点已修剪了这些区块。如果 CLN 节点需要一个已被本地 `bitcoind` 修剪的区块，它将调用 Bitcoin Core RPC `getblockfrompeer` 向对等节点请求。如果区块被成功检索到，Bitcoin Core 会通过将其连接到它所保存的区块头（即使是被修剪过的区块）来鉴证它，并将其保存在本地，可使用标准的区块检索 RPC 来检索它。

- [Eclair #2851][] 开始依赖于 Bitcoin Core 26.1 或更高版本，并删除了可感知祖先的注资的代码。取而代之的是，升级后它可以使用 Bitcoin Core 新的原生代码，旨在补偿任何 _手续费赤字_（见[周报 #269][news269 fee deficit]）。

- [LND #8147][]、[#8422][lnd #8422]、[#8423][lnd #8423]、[#8148][lnd #8148]、[#8667][lnd #8667] 和 [#8674][lnd #8674] 用新的实现替换了 LND 的旧的清扫器，可以广播结算交易和其他需要有效手续费追加的交易。新旧实现接受几乎相同的参数，如交易必须确认的截止日期、要使用的起始费率，新实现还增加了一个 `budget`，即支付的最大手续费。新的实现提供了更多的可配置性，编写测试更容易，同时使用 [CPFP][topic cpfp] 和 [RBF][topic rbf] 手续费追加（在适当的时候分别使用），更好地批量提升手续费以节省手续费，并且只在每个区块更新手续费，而不是每 30 秒更新一次。

- [LND #8627][] 现在默认拒绝用户请求对通道设置进行的更改。这些更改需要支付高于零的 _入站转发手续费_。例如，假设 Alice 想通过 Bob 将一笔付款转发给 Carol。默认情况下，Bob 不能再使用新增加的 LND 功能来要求 Alice 支付额外的入站转发手续费（参见[周报 #297][news297 inbound]）。这一新的默认设置确保 Bob 的节点与不支持入站转发手续费的节点（几乎是目前所有的闪电网络节点）保持兼容。Bob 可以用 `accept-positive-inbound-fees` LND 配置设置覆盖默认设置，从而不向后兼容；或者，他也可以提高出站转发手续费给到 Carol，然后使用负的入站转发手续费为不是来自 Alice 的付款提供折扣，从而在向后兼容的同时达到预期效果。

- [Libsecp256k1 #1058][] 更改了用于生成公钥和签名的算法。旧算法和新算法都在恒定时间内运行，以避免产生[侧信道][topic side channels]计时漏洞。新算法的基准测试表明，其速度提高了约 12%。该 PR 的审阅者之一在一个[短篇博文][stratospher comb]中介绍了新算法的工作原理。

- [BIPs #1382][] 将 [BIP331][] 分配给[祖先包中继][topic package relay]提案。

- [BIPs #1068][] 交换了第 1 版 [BIP47][] 可重复使用支付码中的两个参数，以匹配 Samourai 钱包中的实现。该 BIP 中还添加了有关可重复使用支付码后续版本信息的详细信息。请注意，Samourai 对 BIP47 的最早实现是在几年前，在上周合并之前，该 PR 已开放三年多。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="27679,7240,2851,22087,8147,8422,8423,8148,8667,8627,1058,1382,1068,8674" %}
[gugger zmq]: https://github.com/lightningnetwork/lnd/pull/8664#issuecomment-2065802617
[news269 fee deficit]: /zh/newsletters/2023/09/20/#bitcoin-core-26152
[news 297 inbound]: /zh/newsletters/2024/04/10/#lnd-6703
[stratospher comb]: https://github.com/stratospher/blogosphere/blob/main/sdmc.md
[petukhov alloy]: https://delvingbitcoin.org/t/analyzing-simple-vault-covenant-with-alloy/819
[petukhov mods]: https://delvingbitcoin.org/t/basic-vault-prototype-using-op-cat/576/16
[petukhov spec]: https://gist.github.com/dgpv/514134c9727653b64d675d7513f983dd
[alloy]: https://en.wikipedia.org/wiki/Alloy_(specification_language)
[dryja exploding]: https://delvingbitcoin.org/t/exploding-keys-covenant-construction/832
[zmq]: https://zh.wikipedia.org/wiki/ZeroMQ
[news291 catvault]: /zh/newsletters/2024/02/28/#simple-vault-prototype-using-op-cat-op-cat
[news297 inbound]: /zh/newsletters/2024/04/10/#lnd-6703
[news294 sockets]: /zh/newsletters/2024/03/20/#bitcoin-core-27375
[bitcoin inquisition 25.2]: https://github.com/bitcoin-inquisition/bitcoin/releases/tag/v25.2-inq
[lnd v0.18.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.0-beta.rc1
[coredev.tech]: https://coredev.tech/
[coredev xs]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-04/
