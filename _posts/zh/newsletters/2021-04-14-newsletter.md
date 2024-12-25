---
title: 'Bitcoin Optech Newsletter #144'
permalink: /zh/newsletters/2021/04/14/
name: 2021-04-14-newsletter-zh
slug: 2021-04-14-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了最近在激活 taproot 代码方面的进展，并包含我们的定期栏目，其中包括最近一次 [Bitcoin Core PR 审查俱乐部][Bitcoin Core PR Review Club]会议的描述以及对流行的比特币基础设施软件所做的值得注意的更改。

## 新闻

- **<!--taproot-activation-discussion-->****Taproot 激活讨论：** 自从我们在 [Newsletter #139][news139 activation] 中关于 [taproot][topic taproot] 软分叉的[激活方法][topic soft fork activation]讨论的上次更新以来，Speedy Trial 提案成为了那些关注激活的人士的焦点。为此开设了两个变体的 PR：[PR#21377][Bitcoin Core #21377]，使用了 [BIP9][] 的变体，以及 [PR#21392][Bitcoin Core #21392]，使用了成为 [BIP8][] 一部分的修改。这些 PR 之间的主要技术区别在于它们如何指定开始和停止点。PR#21377 使用中位时间过去 ([MTP][]); PR#21392 使用当前区块的高度。

  MTP 通常在比特币主网（mainnet）及其各种测试网络（如 testnet、默认的 [signet][topic signet] 以及各种独立的 signet）之间大致一致。这允许多个网络共享一组激活参数，即使它们的区块高度有很大不同，也能最小化保持这些网络用户与主网共识变化同步的工作量。

  不幸的是，MTP 可以被少数矿工以小方式操纵，也可以被大多数算力以大方式操纵。在区块链重组期间，MTP 甚至可能意外地回退到较早的时间。相比之下，高度只能在极端的重组中减少。[^height-decreasing]这通常允许审查者简化假设，即高度只会增加，从而使基于高度的激活机制比 MTP 机制更易于分析。

  这两种提案之间的权衡，以及其他一些问题，造成了一些开发者认为阻碍了任何一个 PR 获得更多审查并最终合并到 Bitcoin Core 中的僵局。当两份 PR 的作者达成妥协时，这一僵局得到了部分参与激活讨论的人员的满意解决：

  1. 使用 MTP 作为节点开始计数信号软分叉区块的时间，计数从开始时间后的下一个 2,016 区块重定向期开始。这与 [BIP9][] versionbits 和 [BIP148][] UASF 开始计数它们帮助激活的软分叉区块的方式相同。

  2. 还使用 MTP 作为节点停止计数尚未锁定的软分叉信号区块的时间。然而，与 BIP9 不同，MTP 停止时间仅在执行计数的重定向期结束时检查。这消除了激活尝试直接从*已开始*到*失败*的能力，简化了分析，并保证矿工至少有一个完整的 2,016 区块期间可以发出激活信号。

  3. 使用高度作为最小激活参数。这进一步简化了分析，并且仍然与允许多个测试网络共享激活参数的目标兼容。即使这些网络上的高度可能不同，它们都可以使用 `0` 的最小激活高度在 MTP 定义的窗口内激活。

  尽管一些讨论参与者对妥协提案表示不满，但其[实现][Bitcoin Core #21377]现在已获得十多位 Bitcoin Core 的活跃贡献者以及两个其他全节点实现（btcd 和 libbitcoin）的维护者的审查或支持表达。我们希望这种激活 taproot 的势头能继续，并且我们能够在未来的 Newsletter 中报告更多进展。

## Bitcoin Core PR 审查俱乐部

*在这个每月栏目中，我们总结了最近的一次 [Bitcoin Core PR 审查俱乐部][Bitcoin Core PR Review Club]会议，重点介绍了一些重要的问题和答案。点击下面的问题即可查看会议中答案的摘要。*

{% include functions/details-list.md
  q0="**<!--q0-->**[BIP90][] 的埋藏部署（buried deployment）相对于 [BIP9][] 的版本位部署（version bits deployment）有哪些优势？"
  a0="埋藏部署通过用简单的高度检查替代控制执行的测试，简化了部署逻辑，从而减少了与这些共识变更部署相关的技术债务。"
  a0link="https://bitcoincore.reviews/19438#l-132"

  q1="**<!--q1-->**这个 PR 枚举了多少个埋藏部署？"
  a1="五个：coinbase 中的高度、CLTV (`CHECKLOCKTIMEVERIFY`)、严格 DER 签名、CSV (`OP_CHECKSEQUENCEVERIFY`) 和 segwit。它们在 PR 提议的 `BuriedDeployment` 枚举器中列出，见 [src/consensus/params.h#L14-22](https://github.com/bitcoin/bitcoin/blob/e72e062e/src/consensus/params.h#L14-L22)。有人可能会认为[中本聪时代的软分叉](/en/topics/soft-fork-activation/#2009-hardcoded-height-consensus-nlocktime-enforcement)也是被埋藏的。"
  a1link="https://bitcoincore.reviews/19438#l-75"

  q2="**<!--q2-->**当前定义了多少个版本位部署？"
  a2="两个：testdummy 和 schnorr/taproot (BIPs 340-342)，在代码库中枚举于 [src/consensus/params.h#L25-31](https://github.com/bitcoin/bitcoin/blob/e72e062e/src/consensus/params.h#L25-L31)。"
  a2link="https://bitcoincore.reviews/19438#l-96"

  q3="**<!--q3-->**如果 taproot 软分叉被激活，之后我们想要 bury 这种激活方法，如果合并此 PR，需要对 Bitcoin Core 做哪些更改？"
  a3="主要的更改将与当前代码相比大大简化：将 `DEPLOYMENT_TAPROOT` 行从 `DeploymentPos` 枚举器移动到 `BuriedDeployment`。最重要的是，不需要更改任何验证逻辑。[burying taproot]。"
  a3link="https://bitcoincore.reviews/19438#l-227"
%}

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]中发生的值得注意的更改。*

- [Bitcoin Core #21594][] 为 `getnodeaddresses` RPC 添加了 `network` 字段，以帮助识别各种网络（即 IPv4、IPv6、I2P、onion）上的节点。作者还提议，这为未来的 `getnodeaddresses` 补丁奠定了基础，该补丁将接受特定网络的参数，并仅返回该网络中的地址。

- [Bitcoin Core #21166][] 改进了 `signrawtransactionwithwallet` RPC，允许它为交易中其他未由钱包拥有的已签名输入进行签名。[之前][Bitcoin Core #21151]，如果 RPC 接收到一个包含未由钱包拥有的已签名输入的交易，返回的交易中这些输入的见证将被破坏。为包含其他已签名输入的交易签名输入在各种情况下都很有用，包括[添加输入/输出以提高交易费][Bitcoin Core #21151]。

- [LND #5108][] 添加了使用低级 `sendtoroute` RPC 进行自发[原子多路径支付][topic multipath payments]（也称为 *Original AMPs*）的支持。原始 AMP 本质上是非交互式（或自发的），因为支出者选择所有预映像。支出者预映像选择也是 keysend 风格的[自发支付][topic spontaneous payments]的一部分，这些支付已被用于单路径自发支付。预计后续 PR 将使自发多路径支付可用于更高级别的 `sendpayment` RPC。

- [LND #5047][] 允许钱包导入 [BIP32][] 扩展公钥（xpub）并将其用于接收支付到 LND 的链上钱包。结合 LND 最近更新的对 [PSBTs][topic psbt] 的支持（参见 [Newsletter #118][news118 lnd4389]），这允许 LND 作为其非通道资金的只读钱包运行。例如，Alice 可以导入她冷钱包的 xpub，使用 LND 提供的地址向该钱包存款，请求 LND 开通一个通道，用她的冷钱包签署一个 PSBT 来开启该通道，然后在通道关闭时让 LND 自动将资金存回她的冷钱包。最后一部分——将关闭的通道资金存回冷钱包——可能需要额外的步骤，特别是在非合作关闭通道的情况下，但此更改使 LND 大部分接近完全与支持 PSBT 的冷钱包和硬件钱包互操作。

## 脚注

[^height-decreasing]:
    如果区块链上的每个区块都有相同的单独工作量证明（PoW），则具有最多累积 PoW 的有效链也将是最长的链——其最新区块具有迄今为止见过的最高高度。然而，每 2,016 个区块，比特币协议会调整新块需要包含的 PoW 数量，增加或减少需要证明的工作量，试图保持块之间的平均时间约为 10 分钟。这意味着一个拥有较少区块的链可能比一个拥有更多区块的链具有更多的 PoW。

    比特币用户使用拥有最多 PoW 的链——而不是最多区块的链——来确定他们是否已收到资金。当用户看到该链的一个有效变体，其中一些末尾区块被不同的区块替换时，如果该重组链包含比他们当前链更多的 PoW，他们会使用该*重组*链。因为重组链可能包含更少的区块，尽管具有更多的累积 PoW，链的高度可能会下降。

    尽管这是一个理论上的担忧，但通常不是一个实际问题。高度下降仅在跨越至少一个*重定向*边界（在一组 2,016 个区块和另一组 2,016 个区块之间）的大量区块重组中可能发生。它还需要涉及大量区块的重组或 PoW 要求量的最近重大变化（表示算力的最近重大增加或减少，或矿工的可观察操纵）。在 [BIP8][] 的上下文中，我们认为高度下降的重组在激活期间不会对用户产生比更典型的重组更多的影响。

{% include references.md %}
{% include linkers/issues.md issues="21594,21166,5108,5047,21377,21392,19438,21151" %}
[news118 lnd4389]: /zh/newsletters/2020/10/07/#lnd-4389
[news139 activation]: /zh/newsletters/2021/03/10/#taproot-activation-discussion
[mtp]: https://bitcoin.stackexchange.com/a/67622/21052
[easier burying]: https://github.com/bitcoin/bitcoin/pull/11398#issuecomment-335599326
[burying taproot]: https://bitcoincore.reviews/19438#l-230
