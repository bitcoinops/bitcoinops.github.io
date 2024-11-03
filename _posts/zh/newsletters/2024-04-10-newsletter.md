---
title: 'Bitcoin Optech Newsletter #297'
permalink: /zh/newsletters/2024/04/10/
name: 2024-04-10-newsletter-zh
slug: 2024-04-10-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报公布了一种用于实验合约协议的新的领域专用语言，总结了关于修改 BIP 编辑职责的讨论，并介绍了重置和修改 testnet 的建议。此外，我们的常规栏目还包括 Bitcoin Core PR 审核俱乐部的会议总结、新版本和候选版本的公告以及对流行的比特币基础软件的显著变化的描述。

## 新闻

- **用于合约实验的 DSL：** Kulpreet Singh 在 Delving Bitcoin 上[发布了][singh dsl]他正在为比特币开发的一种领域专用语言（DSL）。该语言可以轻松指定合约协议中应执行的操作。这样就可以很容易地在测试环境中快速执行合约，以确保其行为符合预期，从而快速迭代合约的新创意，并为以后开发成熟的软件提供一个基线。

  Robin Linus 在[回复][linus dsl]中提供了一个类似项目的链接，该项目允许使用高级语言描述合同协议，并将其编译为执行该协议所需的操作和底层代码。这项工作是作为增强 [BitVM][topic acc] 的一部分而进行的。

- **更新 BIP2：** Tim Ruffing 在 Bitcoin-Dev 邮件列表中[发布了][ruffing bip2]关于更新 [BIP2][] 的帖子，其中规定了当前添加新 BIP 和更新现有 BIP 的流程。Ruffing 和其他人提到了当前流程的几个问题，包括：

    - *<!--editorial-evaluation-and-discretion-->编辑评估和自由裁量权：* 应要求 BIP 编辑花费多少精力来确保新 BIP 是具有高质量并专注在比特币上的？另外，他们应该有多大的自由裁量权来拒绝新的 BIP？Ruffing 和其他一些人提到，他们更倾向于尽量减少编辑要求和特权，也许 BIP 编辑只需要防止系统性滥用（如大量的垃圾信息）。当然 BIP 编辑和其他社区成员一样，可以自愿对他们认为有趣的任何 BIP 提议提出改进建议。

    - *<!--licensing-->许可证：* 某些允许使用的 BIP 许可证是为软件设计的，对文档可能没有意义。

    - *<!--Comments-->评论：* 与 BIP1 相比，BIP2 试图为每个 BIP 提供一个社区反馈场所。但这一做法并未得到广泛应用，其结果也引起了争议。

  在撰写本文时，更新 BIP2 的想法仍在讨论之中。

  在一个单独但相关的讨论中，[上周周报][news296 editors]中提到的新 BIP 编辑的提名和宣传工作已[延长][erhardt editors]至 4 月 19 日星期五 UTC 当天结束。希望新编辑能在下周一当天结束前获得合并访问权限。

- **<!--discussion-about-resetting-and-modifying-testnet-->关于重置和修改 testnet 的讨论：** Jameson Lopp 在 Bitcoin-Dev 邮件列表中[发布了][lopp testnet]关于当前公共比特币测试网（testnet3）的问题，建议重启测试网，并可能会使用另一套特殊情况的共识规则。

  之前版本的 testnet 不得不重启，因为有些人开始给 testnet 币赋予经济价值，导致想要进行实际测试的人很难免费获得这些币。Lopp 提供了这种情况再次发生的证据，还描述了由于利用 testnet 的自定义难度调整算法而导致的众所周知的区块泛滥问题。多位参与者讨论了为解决这一问题及其他问题而对 testnet 进行修改的可能性，但至少有一位受访者[倾向于][kim testnet]允许这些问题继续存在，因为这样可以进行有趣的测试。

## Bitcoin Core PR 审核俱乐部

*在这个月度部分，我们总结了 [Bitcoin Core PR 审核俱乐部][Bitcoin Core PR Review Club]会议，重点介绍了一些重要的问题和答案。单击下面的问题以查看会议答案的总结。*

[在脚本解释器中执行 64 位算术运算代码][review club 29221]是 Chris Stewart (GitHub Christewart)提交的一个 PR，它引入了新的运算代码，允许用户在比特币脚本中对更大的（64 位）操作数进行算术运算，而目前允许的是 32 位。

这一变化与一些现有的允许交易内省的软分叉建议（如 [OP_TLUV][ml OP_TLUV]）相结合，将允许用户根据交易的聪计价输出值构建脚本逻辑，而这些输出值很容易溢出 32 位整数。

关于该方法的讨论仍在进行中，例如是升级现有的操作码还是引入新的操作码（如 `OP_ADD64`）。

了解更多信息，请参阅（WIP）[BIP][bip 64bit arithmetic]，以及 DelvingBitcoin 论坛上的[讨论][delving 64bit arithmetic]。

{% include functions/details-list.md q0="`CScriptNum` `nMaxNumSize` 参数有什么作用？" a0="表示正在求值的 `CScriptNum` 堆栈元素的最大大小（以字节为单位）。默认设置为 4 字节" a0link="https://bitcoincore.reviews/29221#l-34"

  q1="哪 2 个操作码接受 5 字节的数字输入？"
  a1="`OP_CHECKSEQUENCEVERIFY` 和 `OP_CHECKLOCKTIMEVERIFY` 使用有符号整数表示时间戳。如果使用 4 个字节，则允许的日期上限范围为 2038 年。因此，这两个基于时间的操作码接受 5 字节输入。[代码中][docs 5byte carveout]记录了这一点。"
  a1link="https://bitcoincore.reviews/29221#l-45"

  q2="为什么要在 `CScriptNum` 中引入 `fRequireMinimal` 标志？"
  a2="`CScriptNum` 的编码长度可变，如 [BIP62][]（规则 4）所述，这就给熔融性带来了机会。例如，零可以编码为 `OP_0`、`0x00`、`0x0000`…… [Bitcoin Core #5065][] 在标准交易中解决了这一问题，[要求][doc SCRIPT_VERIFY_MINIMALDATA]数据推入和表示数字的堆栈元素使用最小表示法。" a2link="https://bitcoincore.reviews/29221#l-57"

  q3="此 RP 中的熔融性实现是否安全？为什么？"
  a3="目前的实现方法要求对 64 位操作码的操作数采用固定长度的 8 字节表示法，以防止填充零的熔融性。这样做的理由是简化执行逻辑，但代价是增加了对区块空间的使用。作者还探索了在[不同分支][64bit arith cscriptnum]中使用 `CScriptNum` 可变编码的方法。"
  a3link="https://bitcoincore.reviews/29221#l-67" %}

## 版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [HWI 3.0.0][] 是该软件包的下一版本发布，为多种不同的硬件签名设备提供了通用接口。此版本中唯一的重大变化是不再自动检测模拟硬件钱包；详情请参见下文对 [HWI #729][] 的详细描述。

- [Core Lightning 24.02.2][] 是一个维护版本，它修复了 Core Lightning 和 LDK 在实现闪电网络 gossip 协议的一个特定部分时出现的“[小的不兼容问题][core lightning #7174]”。

- [Bitcoin Core 27.0rc1][] 是网络主流全节点实现的下一个重要版本的候选发布版。我们鼓励测试人员查看[建议测试主题][bcc testing]列表。

## 重大的代码和文档变更

_本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。_

*注意：下面提到的对 Bitcoin Core 的提交适用于其主开发分支，因此这些更改可能要到即将发布的版本 27 发布后大约六个月才会发布。*

- [Bitcoin Core #29648][] 删除了 libconsensus，此前它已被弃用（见[周报 #288][news288 libconsensus]）。Libconsensus 曾试图使 Bitcoin Core 的共识逻辑在其他软件中可用。然而，这个库并没有被大量采用，而且已经成为维护 Bitcoin Core 的负担。

- [Bitcoin Core #29130][] 添加了两个新的 RPC。第一个会根据用户想要的设置为其生成一个[描述符][topic descriptors]，然后将该描述符添加到他们的钱包中。例如，下面的命令将在未支持 [taproot][topic taproot] 的旧钱包中添加对 taproot 的支持：

  ```
  bitcoin-cli --rpcwallet=mywallet createwalletdescriptor bech32m
  ```

  第二个 RPC 是 `gethdkeys`（获取 [HD][topic bip32] 密钥），它将返回钱包使用的每个 xpub 以及（可选地）每个 xpriv。当钱包包含多个 xpub 时，可以在调用 `createwalletdescriptor` 时指明要使用的特定 xpub。

- [LND #8159][] 和 [#8160][lnd #8160] 添加了向[盲化路线][topic rv routing]发送付款的试验性（默认禁用）支持。预计[后续 PR][lnd #8485]将添加针对盲化支付失败的完整错误处理。

- [LND #8515][] 新增了多个 RPC，以接受要使用的[钱币选择策略][topic coin selection]名称。请参见[周报 #292][news292 lndcs]，了解先前 LND 钱币选择灵活性的改进。本 PR 在此基础上构建。

- [LND #6703][] 和 [#6934][lnd #6934] 增加了对入站路由手续费的支持。节点已经可以公布它通过特定出站通道转发付款所要收取的费用。例如，Carol 可能会发布广告，表示只有在付款给她提供其价值 0.1% 的情况下，她才会将这些付款转发给其通道对等节点 Dan。如果这样一来，Carol 转发给 Dan 的每分钟的平均聪数（sats）就会低于 Dan 转发给她的平均金额，最终所有通道余额都会落到 Carol 一方，使 Dan 无法转发更多付款给她，从而降低了他们双方的潜在收入。为了避免出现这种情况，Carol 可能会把转发给 Dan 的出站手续费降低到 0.05%。同样，如果 Carol 向 Dan 收取较低的出站转发手续费，导致她每分钟转发给 Dan 的 sats 多于 Dan 转发给她的，那么所有余额最终可能都会出现在 Dan 的通道上，同样会阻碍更多的转发和收入；在这种情况下，Carol 可以提高她的出站手续费。

  然而，出站手续费只适用于出站通道。Carol 提供的是收取相同的手续费，无论她通过什么通道收到付款；例如，无论她从通道对等节点 Alice 还是 Bob 收到付款，她都收取相同的费率：

  ```
  Alice -> Carol -> Dan
  Bob -> Carol -> Dan
  ```

  这是有道理的，因为基础的闪电网络协议不会因为接收到 Alice 或 Bob 的转发请求而向 Carol 支付费用。Alice 和 Bob 可以为他们的通道向 Carol 设置出站手续费，而这取决于他们设置的手续费是否有助于保持通道的流动性。同样，Carol 也可以调整她向 Alice 和 Bob 的出站手续费（例如，Dan -> Carol -> Bob），以帮助管理流动性。

  不过，Carol 可能希望对影响她的政策有更多的控制权。例如，如果 Alice 的节点管理不善，她可能会频繁地将付款转给 Carol，而后来却没有很多人愿意将付款从 Carol 转给 Alice。这样一来，他们通道中的所有资金最终都会落到 Carol 那边，从而阻止了该方向的进一步支付。在本 PR 之前，Carol 对此无能为力，只能关闭她与 Alice 的通道，以免浪费太多 Carol 的资金价值。

  有了这项 PR，Carol 现在还可以针对每个通道收取特定的_入站转发手续费_。例如，她可以对 Alice 有问题的节点的入站付款收取较高手续费，但对 Bob 高流动性节点的入站支付收取较低手续费。初始入站手续费预计总是负数，以便与不理解入站手续费的旧节点向后兼容；例如，Carol 可能会对 Bob 转发的付款给予 10% 的手续费折扣，而对 Alice 转发的付款给予 0% 的折扣。

  手续费与出站费用同时计算。例如，当 Alice 向 Carol 提出要将一笔付款转发给 Dan 时，Carol 会计算原来的 `dan_outbound` 手续费，计算新的 `alice_inbound` 手续费，并确保转发的付款至少能给她带来两者的总和。否则，她会拒绝 [HTLC][topic htlc]。由于初始入站手续费预计总是负数，不会拒绝任何支付足够出站手续费的付款，但任何现在知道入站手续费的节点都可能获得折扣。

  入站路由费大约三年前首次[提出][bolts #835]，大约两年前在 Lightning-Dev 邮件列表中[讨论][jager inbound]，也大约两年前在 [BLIPs #18][] 草案中记录。自最初提出以来，除闪电网络外，还有一些闪电网络实现的维护者表示反对。一些人[原则上][teinturier bolts835]反对；另一些人则反对它的设计，认为它[过于针对 LND][corallo overly specific]，而不是一种本地且通用的升级，可以立即使用正的入站转发费，而且不需要在全局范围内公布每个通道的额外手续费细节。[BLIPs #22][] 草案提出了另一种方法。据我们所知，只有一个非 LND 实现的维护者[表示][corallo free money]他们将采用 LND 的方法，而且只在提供负入站转发手续费的情况下，因为那是“为我们的用户免费提供资金”。

- [Rust Bitcoin #2652][] 更改了 API 在处理 [PSBT][topic psbt] 时签署 [taproot][topic taproot] 输入时返回的公钥。以前，API 返回签名私钥的公钥。然而，该 PR 指出：“人们通常认为内部密钥是签名的密钥，尽管这在技术上并不正确。我们在 PSBT 中也有内部密钥”。合并此 PR 后，现在的 API 将返回内部密钥。

- [HWI #729][] 停止自动枚举和使用设备模拟器。模拟器主要由 HWI 和硬件钱包的开发者使用，但试图自动检测它们可能会给普通用户带来问题。现在，希望使用模拟器的开发者需要传入一个额外的 `--emulators` 选项。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 16:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="729,29648,29130,8159,8160,8485,8515,6703,6934,835,18,22,2652,7174,5065" %}
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/27.0-Release-Candidate-Testing-Guide
[Bitcoin Core 27.0rc1]: https://bitcoincore.org/bin/bitcoin-core-27.0/test.rc1/
[HWI 3.0.0]: https://github.com/bitcoin-core/HWI/releases/tag/3.0.0
[Core Lightning 24.02.2]: https://github.com/ElementsProject/lightning/releases/tag/v24.02.2
[news292 lndcs]: /zh/newsletters/2024/03/06/#lnd-8378
[news288 libconsensus]: /zh/newsletters/2024/02/07/#bitcoin-core-29189
[teinturier bolts835]: https://github.com/lightning/bolts/issues/835#issuecomment-764779287
[corallo free money]: https://github.com/lightning/blips/pull/18#issuecomment-1304319234
[corallo overly specific]: https://github.com/lightningnetwork/lnd/pull/6703#issuecomment-1374694283
[jager inbound]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-July/003643.html
[singh dsl]: https://delvingbitcoin.org/t/dsl-for-experimenting-with-contracts/748
[linus dsl]: https://delvingbitcoin.org/t/dsl-for-experimenting-with-contracts/748/4
[ruffing bip2]: https://gnusha.org/pi/bitcoindev/59fa94cea6f70e02b1ce0da07ae230670730171c.camel@timruffing.de/
[news296 editors]: /zh/newsletters/2024/04/03/#choosing-new-bip-editors-bip
[erhardt editors]: https://gnusha.org/pi/bitcoindev/c304a456-b15f-4544-8f86-d4a17fb0aa8c@murch.one/
[lopp testnet]: https://gnusha.org/pi/bitcoindev/CADL_X_eXjbRFROuJU0b336vPVy5Q2RJvhcx64NSNPH-3fDCUfw@mail.gmail.com/
[kim testnet]: https://gnusha.org/pi/bitcoindev/950b875a-e430-4bd8-870d-f9a9fab2493an@googlegroups.com/
[review club 29221]: https://bitcoincore.reviews/29221
[delving 64bit arithmetic]: https://delvingbitcoin.org/t/64-bit-arithmetic-soft-fork/397
[bip 64bit arithmetic]: https://github.com/bitcoin/bips/pull/1538
[64bit arith cscriptnum]: https://github.com/Christewart/bitcoin/tree/64bit-arith-cscriptnum
[docs 5byte carveout]: https://github.com/bitcoin/bitcoin/blob/3206e45412ded0e70c1f15ba66c2ba3b4426f27f/src/script/interpreter.cpp#L531-L544
[doc SCRIPT_VERIFY_MINIMALDATA]: https://github.com/bitcoin/bitcoin/blob/3206e45412ded0e70c1f15ba66c2ba3b4426f27f/src/script/interpreter.h#L69-L73
[ml OP_TLUV]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-September/019419.html
