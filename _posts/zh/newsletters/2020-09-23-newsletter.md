---
title: 'Bitcoin Optech Newsletter #116'
permalink: /zh/newsletters/2020/09/23/
name: 2020-09-23-newsletter-zh
slug: 2020-09-23-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了启用一种新型手续费追加方式的软分叉提案，并总结了对永远无法花费的脚本的研究——这些脚本之所以无法花费，是因为它们要求同时满足时间锁和高度锁。此外，还包括我们常规的栏目：服务和客户端软件更新摘要、新发布与候选发布列表，以及热门比特币基础设施软件的变更。

## 行动项

*本周无。*

## 新闻

- **<!--transaction-fee-sponsorship-->****交易手续费赞助：** Jeremy Rubin 向 Bitcoin-Dev 邮件列表[发布][rubin sponsor bumping]了一项提案，建议通过软分叉添加一种新的手续费追加机制，相比现行的[手续费替换（RBF）][topic rbf]和子为父付（[CPFP][topic cpfp]）方法，这种机制可能更不容易被滥用。[交易钉住][topic transaction pinning]以及针对现有体系的其他滥用手段，都可以用来攻击合约协议。这些问题催生了[锚定输出][topic anchor outputs]之类的部分解决方案，但这类方案只适用于特定协议（例如双方 LN 通道），难以推广开来，因而多少有些不尽人意。

  在共识层，Rubin 提议允许交易可选择包含一个特殊的最终输出，该输出承诺一个或多个其他未确认交易的 txid。带有此特殊输出的交易称为*赞助交易*，它只能在其*赞助*的每笔交易也被包含在同一个区块中时才算有效。这意味着，矿工如果想拿到赞助交易的高费率，就有动力去确认那些低费率的被赞助交易。除了这个特殊的赞助输出之外，赞助交易就是普通的比特币交易。

  在控制内存池接收和交易中继的规则（*策略层*）方面，Rubin 提议了一组简单的更改，允许任何人赞助当前在内存池中的任意交易，或者用一笔做同样承诺、但费率更高的替代交易来替换现有的赞助交易。其目的是确保：只要赞助交易遵守规则并支付足够高的费率，就能在网络中传播，而不会撞上钉住或其他攻击。

  Rubin 的提案附有一个[参考实现][rubin refimpl]，并讨论了设计上的取舍与前向兼容性。截至本文发布时，邮件列表上的评论对 Rubin 的工作表示赞赏，但也指出了两个重要的麻烦：

  - **<!--floating-payments-still-pinnable-->****浮动支付仍可能被钉住：**Antoine Riard [指出][riard heavyweight tx]，即使按修改后的提案允许赞助特定输入（[提案的更改][harding sponsor outpoints]），恶意对手方仍可以把某个用 `SIGHASH_SINGLE` 签名的特定输入（例如最新 LN 协议中的 HTLC，或 [eltoo][topic eltoo] 的状态交易）放进一笔最大尺寸的交易里，从而钉住该输入。

  - **<!--breaks-reorg-safety-guarantee-->****破坏了重组安全保障：**Suhas Daftuar [提醒][daftuar principle]读者注意比特币设计中的一条根本原则。正如中本聪[所写][nakamoto later block]：“在区块链重组……的情况下，交易需要能够进入后续区块。”而赞助交易只有在与其所赞助的交易处于同一区块时才有效，这就违反了这一原则。

  在本文发布前几小时，该提案仍在被热烈讨论。我们会在今后的期刊中总结任何新的值得注意的讨论。

- **<!--research-into-conflicts-between-timelocks-and-heightlocks-->****对时间锁和高度锁冲突的研究：** Blockstream 工程博客的一篇[文章][blockstream post]描述了比特币不同类型的时间锁（timelock）与区块高度锁（heightlock）之间的相互作用。自比特币最初发布以来，所有交易都有 `nLockTime` 字段。一个在区块 31,000（2009 年 12 月）激活的软分叉开始[把][time-height-lock fork]这个字段与区块头的显式时间字段及其隐含高度（自创世区块以来的区块数）相比较。只有当区块内每一笔交易都符合以下两条规则时，该区块才有效：[^final-sequence]

  - 如果交易的 nLockTime 低于 5 亿，则它必须低于该区块的高度。

  - 如果交易的 nLockTime 等于或高于 5 亿，
    则它必须低于区块头的时间（以 [epoch time][] 表示）。

  把单个 nLockTime 字段用于两种不同目的，这种复用很高效，但也带来一个显而易见的推论：一笔交易只能使用高度锁或时间锁，不能两者兼用。

  数年后，2015 年 12 月激活的 [BIP65][] 软分叉增加了 `OP_CHECKLOCKTIMEVERIFY`（CLTV）操作码，它把自身参数与花费交易的 nLockTime 字段作比较，比较方式与 nLockTime 字段同所在区块高度或时间字段的比较方式相同。这让脚本可以阻止别人在某个未来的高度或时间到来之前花掉支付给它的资金。然而，Blockstream 的文章解释说，这同时还有一个不那么显而易见的推论：可以构造出一个永远无法花费的脚本，因为它要求同时使用高度锁和时间锁。例如，向下面这个脚本的支付就永远无法花费：

  ```
  1 OP_CLTV OP_DROP 500000001 OP_CLTV
  ```

  第一个条件允许花费交易被打包进区块 1 或更晚的区块，也就是 2009 年 1 月初之后的任何区块；第二个条件允许它被打包进 1985 年 11 月初之后的任何区块。今天这两个条件都成立——但用交易里唯一的 nLockTime 字段，它们无法同时被满足。文章指出，当一笔交易有多个输入、每个输入各有自己的脚本时，也会遇到同样的问题。例如：

  ```
  Input 0:
    1 OP_CLTV

  Input 1:
    500000001 OP_CLTV
  ```

  同样的问题也适用于用 [BIP68][] 序列号和 [BIP112][] `OP_CHECKSEQUENCEVERIFY` 操作码创建的相对时间锁和相对高度锁。

  文章指出，[Miniscript][topic miniscript] 编译器已更新，以尽可能处理这些可能的冲突。当满足某个脚本的某一种或多种方式中存在相互冲突的锁时，它会识别出来并返回警告。由于存在冲突，它也无法给出该脚本的完整分析。此外，策略语言的编译器现在会在混用时间锁和高度锁的策略上刻意报错，例如 `thresh(3,after(1),after(500000001),pk(A))`。注意：截至本文撰写时，这一更改只是 Rust 版 Miniscript 库的一个[待合并 PR][rust-miniscript #121]，尚未传播到 [miniscript][miniscript demo] 或 [minsc][] 的在线演示。

## 服务和客户端软件的变更

*在本月栏目中，我们重点介绍 Bitcoin 钱包与服务的一些有趣更新。*

- **<!--swan-supports-sending-to-bech32-addresses-->****Swan 支持向 bech32 地址发送：**
  Swan 通过其托管方 Prime Trust，现在[支持提款到 bech32 地址][swan bech32 send]。

- **<!--ledger-live-adds-manual-coin-selection-support-->****Ledger Live 增加手动选币支持：**
  Ledger Live 从先进先出（FIFO）的 UTXO 选择模式转变，现在还支持[手动选币][ledger coin control article]，可用于提升隐私或减少手续费。

- **<!--sparrow-wallet-announced-->****Sparrow 钱包公布：**
  [Sparrow 钱包][sparrow twitter thread]是一款新的桌面钱包，支持单签或多重签名地址、PSBT、硬件钱包和[选币][topic coin selection]。

- **<!--joinmarket-0-7-0-adds-bip78-psbt-->****JoinMarket 0.7.0 添加 BIP78 与 PSBT 支持：**
  [JoinMarket 0.7.0][joinmarket 0.7.0] 包含对 [BIP78 payjoin][topic payjoin] 支付的支持。此外还添加了 [PSBT][topic psbt] 支持，以便利这一实现。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [LND 0.11.1-beta.rc4][lnd 0.11.1-beta] 是一个次要版本的候选发布版本。其发布说明把自己的更改概括为：“若干可靠性改进、一些 macaroon [认证令牌]升级，以及一项让我们这版[锚点承诺][topic anchor outputs]符合规范的更改。”

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]中值得注意的更改。*

- [Bitcoin Core #16378][] 为钱包增加了新的 `send` RPC。该新 RPC 旨在提供最大灵活性，包含多个选项，例如多输出（允许[支付批处理][topic payment batching]）、[选币][topic coin selection]、手动或自动费率以及 [PSBT 格式][topic psbt]。该功能旨在统一 `sendtoaddress` 和 `sendmany` RPC 的功能，未来版本中可能会弃用这两个 RPC。完整选项列表见 [RPC 帮助文档][send rpc help]。

- [Bitcoin Core #19643][] 向 `bitcoin-cli` 命令添加了新选项 `-netinfo`，用于显示对等连接仪表盘。此仪表盘为节点运营者提供对等连接细节的鸟瞰视图，例如连接方向、中继类型、网络类别和在线时长。可传入 `0` 到 `4` 的可选参数，以显示不同级别的详细信息。

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

- [Bitcoin Core #15454][] 在程序首次启动时不再创建新钱包。取而代之的是，程序会提示用户要么加载现有钱包，要么创建一个具名的新钱包。早期版本中默认创建的钱包仍会被默认加载，新建的钱包也仍然可以加入启动时自动加载的列表（见 [Newsletter #111][news111 load_on_startup]）。取消默认创建钱包后，用户能更多地接触到自定义钱包的各种选项，例如启用钱包加密、创建仅观察钱包，或创建一个可以直接导入[输出脚本描述符][topic descriptors]的钱包（例如用于多重签名）。

- [Bitcoin Core #19940][] 更新了 `testmempoolaccept` RPC，在交易可以加入内存池的情况下，为结果增加了交易的 vsize 和总手续费两个字段。手续费尤其是一些用户需要的信息：对一笔已在内存池中的交易，这个信息保证可得；而在广播一笔非钱包交易之前，除非按顺序调用若干其他 RPC（例如 `decoderawtransaction` 和 `getrawtransaction`），否则无法在无需信任的情况下取得它。

- [LND #4440][] 记录了本地节点观察到某个对等节点先下线、随后又重新上线的次数，这种行为称为抖动（flapping）。对于频繁抖动的对等节点，节点会限制为其保存的事件记录条数，以免数据库被过多噪声塞满。`listchannels` RPC 也做了更新，会显示每个对等节点的抖动率。

- [LND #4567][] 添加了新的 `--maxchansize` 配置参数，可用于设置新通道中最多能容纳多少钱。既然 LND 已支持[大通道][topic large channels]（见 [Newsletter #107][news107 lnd wumbo]），该设置就能让用户为“万一出问题，单个通道里最多可能损失多少钱”设一个上限。

- [LND #4606][] 和 [#4592][lnd #4592] 提升了 LND 对[锚定输出][topic anchor outputs]做手续费追加的有效性。第一个 PR 计算确认子锚定交易及其父承诺交易所需的费率。第二个 PR 使节点在承诺交易需要于接下来若干区块内确认时，自动进行手续费追加。<!-- 目前为 6 个区块，但在 #4592 的讨论中计划未来使其动态化，因此此处使用“若干区块” -->

## 脚注

[^final-sequence]:
    基于交易 nLockTime 的时间锁和高度锁比这里描述的稍复杂一些，因为还要与交易的一个或多个 nSequence 字段交互。如果所有 nSequence 字段都被设为最大值（`0xffffffff`），那这笔交易就可以被打包进任何区块。关于 nLockTime 与 nSequence（以及签名哈希标志）之间这种交互可能的动机，详见一封[电子邮件][hearn high frequency]，其中引述了据称出自中本聪的话。

    此外，2016 年 7 月激活的 [BIP113][] 软分叉意味着，节点现在把时间锁的值与区块计算出的[过去中位时间][mtp]（MTP）相比较，而不是与区块头中显式写出的时间比较。

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
