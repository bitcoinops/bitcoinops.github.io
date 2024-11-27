---
title: 'Bitcoin Optech Newsletter #116'
permalink: /zh/newsletters/2020/09/23/
name: 2020-09-23-newsletter-zh
slug: 2020-09-23-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了启用新型手续费提升的软分叉提案，并总结了对永远无法花费的脚本的研究，这些脚本因需要同时满足时间锁和高度锁而无法花费。此外，还包括我们常规的服务和客户端软件更新摘要、新的发布和候选发布列表，以及流行比特币基础设施软件的更改。

## 行动项

*本周无。*

## 新闻

- **<!--transaction-fee-sponsorship-->****交易费用赞助：** Jeremy Rubin 向 Bitcoin-Dev 邮件列表[发布][rubin sponsor bumping]了一项提案，建议通过软分叉添加一种新的手续费提升机制，相较于当前的手续费替代（[RBF][topic rbf]）和子付父（[CPFP][topic cpfp]）方法，该机制可能更不易被滥用。[交易固定][topic transaction pinning]及现有系统中的其他滥用方式可用于攻击合约协议。这些问题促成了如[锚定输出][topic anchor outputs]之类的部分解决方案，但这些方案仅适用于特定协议（如双方的 LN 通道），难以推广，因此不够理想。

  在共识层，Rubin 提议允许交易可选择包含一个特殊的最终输出，该输出承诺一个或多个其他未确认交易的 txid。带有此特殊输出的交易称为*赞助交易*，它只能在其*赞助*的每笔交易也被包含在同一个区块中时才算有效。这意味着希望获得赞助交易高手续费率的矿工将被激励确认低手续费率的赞助交易。除了其特殊的赞助输出，赞助交易是普通的比特币交易。

  在控制内存池接收和交易中继的规则（*策略层*）方面，Rubin 提议了一组简单的更改，允许任何人赞助当前在内存池中的任意交易，或用具有相同承诺且更高手续费率的替代赞助交易替换现有赞助交易。其目的是确保只要赞助交易遵守规则且支付足够高的手续费率，就能在不受固定或其他攻击影响的情况下在网络中传播。

  Rubin 的提案附有一个[参考实现][rubin refimpl]，并讨论了设计权衡和前向兼容性。截止本文发布时，邮件列表中的评论对 Rubin 的工作表示赞赏，但也指出了两点重要复杂性：

  - **<!--floating-payments-still-pinnable-->**浮动支付仍然可能被固定： Antoine Riard [指出][riard heavyweight tx]，即便提案修改为允许赞助特定输入（[更改提案][harding sponsor outpoints]），恶意对手方仍可通过在最大尺寸交易中包含一个使用 `SIGHASH_SINGLE` 签名的特定输入（例如最新 LN 协议中的 HTLC 或 [eltoo][topic eltoo] 状态交易）来固定该输入。

  - **<!--breaks-reorg-safety-guarantee-->**打破了重组安全保障： Suhas Daftuar [提醒][daftuar principle]读者比特币设计的一个基本原则。中本聪曾[写道][nakamoto later block]，“在区块链重组的情况下，交易需要能够进入后续区块中。”然而，赞助交易只能在与其赞助的交易同一区块中才算有效，违反了此原则。

  本提案仍在积极讨论中，我们将在未来期刊中总结任何新的显著讨论。

- **<!--research-into-conflicts-between-timelocks-and-heightlocks-->****对时间锁和高度锁冲突的研究：** Blockstream 工程博客的一篇[文章][blockstream post]描述了比特币时间锁（timelocks）和区块高度锁（heightlocks）之间的相互作用。自比特币初始发布以来，所有交易都有一个 `nLockTime` 字段。一个在区块 31,000（2009 年 12 月）激活的软分叉开始[将][time-height-lock fork]此字段与区块头的显式时间字段及其隐含高度（自创世区块以来的区块数）进行比较。区块仅在其所有交易符合以下两条规则时有效：[^final-sequence]

  - 如果交易的 nLockTime 低于 5 亿，则它必须低于区块高度。

  - 如果交易的 nLockTime 等于或高于 5 亿，则它必须低于区块头的时间（以 [epoch time][] 表示）。

  通过一个字段同时用于高度锁和时间锁的这种复用很有效，但也意味着一个交易只能使用高度锁或时间锁，而不能同时使用。

  数年后，2015 年 12 月激活的 [BIP65][] 软分叉增加了 `OP_CHECKLOCKTIMEVERIFY` (CLTV) 操作码，该操作码将其参数与支出交易的 nLockTime 字段进行比较，方式与 nLockTime 字段对包含区块的高度或时间字段的比较方式相同。这使得脚本可以防止其接收的资金在某个未来高度或时间之前被花费。然而，Blockstream 的文章解释说，这也带来了一个非显而易见的结果，即可以创建一个无法花费的脚本，因为它要求同时使用高度锁和时间锁。例如，以下脚本中的支付永远无法花费：

  ```
  1 OP_CLTV OP_DROP 500000001 OP_CLTV
  ```

  第一个条件允许支出交易包含在区块 1 或更高区块中（即 2009 年 1 月之后的任意区块），而第二个条件允许其包含在 1985 年 11 月之后的任何区块中。两个条件今天均为真，但无法使用交易的单一 nLockTime 字段同时满足。文章指出，当交易有多个输入且每个输入包含自己的脚本时，也会出现同样的问题。例如：

  ```
  输入 0：
    1 OP_CLTV

  输入 1：
    500000001 OP_CLTV
  ```

  此问题还适用于通过 [BIP68][] 序列号和 [BIP112][] `OP_CHECKSEQUENCEVERIFY` 操作码创建的相对时间锁和相对高度锁。

  文章指出，[Miniscript][topic miniscript] 编译器已更新，以尽量处理这些可能的冲突。它将识别满足脚本的一种或多种方式是否包含冲突的锁，并返回警告。由于存在冲突，它还无法提供脚本的完整分析。此外，策略语言的编译器现在会在混合时间锁和高度锁的策略（如 `thresh(3,after(1),after(500000001),pk(A))`）上故意失败。注意：在撰写本文时，此更改仅是 Rust 版 Miniscript 库的一个[待定 PR][rust-miniscript #121]，尚未传播到在线的 [miniscript][miniscript demo] 或 [minsc][] 演示。

## 服务和客户端软件的更改

*在此每月专栏中，我们关注比特币钱包和服务的有趣更新。*

- **<!--swan-supports-sending-to-bech32-addresses-->****Swan 支持发送至 Bech32 地址：**
  Swan 通过其托管方 Prime Trust，现在[支持向 Bech32 地址][swan bech32 send]提款。

- **<!--ledger-live-adds-manual-coin-selection-support-->****Ledger Live 添加手动币选择支持：**
  从先进先出 UTXO 选择模型升级，Ledger Live 现支持[手动币选择][ledger coin control article]，可用于隐私或手续费最小化。

- **<!--sparrow-wallet-announced-->****Sparrow 钱包发布：**
  [Sparrow 钱包][sparrow twitter thread]是一款新桌面钱包，支持单签或多重签名地址、PSBT、硬件钱包和[币选择][topic coin selection]。

- **<!--joinmarket-0-7-0-adds-bip78-psbt-->****JoinMarket 0.7.0 添加 BIP78 和 PSBT 支持：**
  [JoinMarket 0.7.0][joinmarket 0.7.0] 包含 [BIP78 PayJoin][topic payjoin] 支付支持。同时添加了 [PSBT][topic psbt] 支持以便实现。

## 发布与候选发布

*流行比特币基础设施项目的新发布和候选发布。请考虑升级到新版本或帮助测试候选版本。*

- [LND 0.11.1-beta.rc4][lnd 0.11.1-beta] 是一个小版本候选版本。发布说明总结了其更改，包括“一些可靠性改进、Macaroon [认证令牌]升级，以及使我们的锚定承诺版本符合规范的更改”。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]中值得注意的更改。*

- [Bitcoin Core #16378][] 为钱包增加了新的 `send` RPC。该新 RPC 旨在提供最大灵活性，包含多个选项，例如多输出（允许[支付批处理][topic payment batching]）、[币选择][topic coin selection]、手动或自动手续费率以及 [PSBT 格式][topic psbt]。该功能旨在统一 `sendtoaddress` 和 `sendmany` RPC 的功能，未来版本中可能会弃用这两个 RPC。完整选项列表见 [RPC 帮助文档][send rpc help]。

- [Bitcoin Core #19643][] 向 `bitcoin-cli` 命令添加了新选项 `-netinfo`，用于显示对等连接仪表盘。此仪表盘为节点操作员提供对等连接细节的鸟瞰视图，例如连接方向、转发类型、网络类别和在线时长。可传入 `0` 到 `4` 的可选参数，以显示不同级别的详细信息。

  ```text
  $ watch -n 0.1 ./src/bitcoin-cli -netinfo 3
  Bitcoin Core v0.20.99.0-bf1f913c44 - 70016/Satoshi:0.20.99/

  Peer connections sorted by direction and min ping
  <-> relay   net mping   ping send recv  txn  blk uptime  asmap    id version
   in  full onion                 1    1                0        10206 70015/Satoshi:0.20.1/
   in  full  ipv6   246    246    1    9    0           1  16509 10202 70015/Satoshi:0.19.1/
   in block onion 37686 425955   42   42               25        10143 70015/Satoshi:0.20.1/
  [...]
  out  full  ipv4    94    198    3    1    0  229    956  12998  7809 70015/Satoshi:0.19.0.1/
  out block  ipv6   107    269   64   64              949   5577  7835 70015/Satoshi:0.16.0/
  out  full onion   440   1180    4    4    0         257         9574 70015/Satoshi:0.18.1/
                     ms     ms  sec  sec  min  min    min{% comment %}skip-duplicate-words-test{% endcomment %}

          ipv4    ipv6   onion   total  block-relay
  in         0      17       8      25       2
  out        8       2       8      18       2
  total      8      19      16      43       4

  Local addresses
  [redacted]                                port  8333     score   6401
  [redacted].onion                          port  8333     score   1085
  ```

- [Bitcoin Core #15454][] 启动程序时不再自动创建新钱包。相反，用户被提示要么加载现有钱包，要么创建新命名钱包。早期版本中默认创建的钱包仍会自动加载，新创建的钱包可以添加到启动时加载列表中（参见 [Newsletter #111][news111 load_on_startup]）。通过删除默认钱包创建，用户将更多地了解自定义钱包选项，例如启用钱包加密、创建仅监控钱包或创建支持导入[输出脚本描述符][topic descriptors]的钱包（例如多签名）。

- [Bitcoin Core #19940][] 更新了 `testmempoolaccept` RPC，增加了结果字段以显示交易的虚拟大小（vsize）和总交易费用（若交易可添加至内存池）。特别是费用信息是一些用户所需的，且对于内存池交易来说是可用的，但除非运行一系列其他 RPC（如 `decoderawtransaction` 和 `getrawtransaction`），否则无法在广播非钱包交易前无信任地获得该信息。

- [LND #4440][] 记录本地节点观察到的对等方下线和重新上线次数，称为波动率。节点会限制存储关于频繁波动的对等方的事件记录，以避免填充数据库。`listchannels` RPC 也更新以显示每个对等方的波动率。

- [LND #4567][] 添加了新的 `--maxchansize` 配置参数，允许设置新通道的最大金额限制。现在 LND 支持[大通道][topic large channels]（见 [Newsletter #107][news107 lnd wumbo]），此设置允许用户限制单个通道可能丢失的最大金额。

- [LND #4606][] 和 [#4592][lnd #4592] 改进了 LND 对[锚定输出][topic anchor outputs]的费用提升效果。第一个 PR 计算确认子锚定交易及其父承诺交易所需的费率。第二个 PR 使得当承诺交易需要在接下来的若干区块内确认时自动进行费用提升。<!-- 目前为 6 个区块，但在 #4592 的讨论中计划未来使其动态化，因此此处使用“若干区块” -->

## 注释

[^final-sequence]:
    基于交易 nLockTime 的时间锁和高度锁比此处描述的稍微复杂，因为与交易的一个或多个 nSequence 字段存在交互。如果所有 nSequence 字段都设置为其最大值（`0xffffffff`），则交易可以包含在任何区块中。关于 nLockTime 与 nSequence（以及签名哈希标志）之间交互的可能动机，请参阅一封[电子邮件][hearn high frequency]，其中引用了中本聪的观点。

    此外，2016 年 7 月激活的 [BIP113][] 软分叉意味着节点现在将时间锁值与区块的[过去中位时间][mtp]（MTP）而非其显式头时间进行比较。

{% include references.md %}
{% include linkers/issues.md issues="16378,19643,15454,19940,4440,4567,4606,4592" %}
[lnd 0.11.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.11.1-beta.rc3
[news107 lnd wumbo]: /zh/newsletters/2020/07/22/#lnd-4429
[blockstream post]: https://medium.com/blockstream/dont-mix-your-timelocks-d9939b665094
[hearn high frequency]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2013-April/002417.html
[time-height-lock fork]: https://bitcoin.stackexchange.com/a/99104/21052
[epoch time]: https://en.wikipedia.org/wiki/Unix_time
[rust-miniscript #121]: https://github.com/rust-bitcoin/rust-miniscript/pull/121
[minsc]: https://min.sc/
[rubin sponsor bumping]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-September/018168.html
[rubin refimpl]: https://github.com/bitcoin/bitcoin/compare/master...JeremyRubin:subsidy-tx
[news111 load_on_startup]: /zh/newsletters/2020/08/19/#bitcoin-core-15937
[mtp]: https://bitcoin.stackexchange.com/a/67622/21052
[miniscript demo]: http://bitcoin.sipa.be/miniscript/
[riard heavyweight tx]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-September/018191.html
[harding sponsor outpoints]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-September/018186.html
[daftuar principle]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-September/018195.html
[nakamoto later block]: https://bitcointalk.org/index.php?topic=1786.msg22119#msg22119
[send rpc help]: https://github.com/bitcoin/bitcoin/blob/831b0ecea9156447a2b6a67d28858bc26d302c1c/src/wallet/rpcwallet.cpp#L3876-L3933
[swan bech32 send]: https://twitter.com/SwanBitcoin/status/1301182772015497216
[ledger coin control article]: https://www.ledger.com/coin-control-now-available-in-ledger-live
[sparrow twitter thread]: https://twitter.com/craigraw/status/1301045693814132736
[joinmarket 0.7.0]: https://github.com/JoinMarket-Org/joinmarket-clientserver/blob/master/docs/release-notes/release-notes-0.7.0.md
[hwi]: https://github.com/bitcoin-core/HWI
