---
title: 'Bitcoin Optech Newsletter #144'
permalink: /zh/newsletters/2021/04/14/
name: 2021-04-14-newsletter-zh
slug: 2021-04-14-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了近期在激活 taproot 的代码方面取得的进展，并包含我们的固定栏目：最近一次 [Bitcoin Core PR 审查俱乐部][Bitcoin Core PR Review Club]会议的介绍，以及热门比特币基础设施软件值得注意的代码与文档变更。

## 新闻

- **<!--taproot-activation-discussion-->****Taproot 激活讨论：** 自我们在 [Newsletter #139][news139 activation] 中上次介绍 [taproot][topic taproot] 软分叉的[激活方法][topic soft fork activation]讨论以来，Speedy Trial 提案成了关注激活议题的人士的焦点。人们为它的两个变体开了 PR：[PR#21377][Bitcoin Core #21377] 使用 [BIP9][] 的一个变体，[PR#21392][Bitcoin Core #21392] 使用后来成为 [BIP8][] 一部分的一项改动。这两个 PR 的主要技术区别在于它们如何指定起点和终点。PR#21377 使用[MTP][]（Median Time Past，过去中位时间），PR#21392 使用当前区块的高度。

  MTP 在比特币主网（mainnet）及其各种测试网络（如 testnet、默认的 [signet][topic signet] 以及各种独立的 signet）之间通常大致一致。因此，即使这些网络的区块高度相差悬殊，也能共享同一套激活参数，从而尽量减少让这些网络的用户跟上主网共识变更所需的工作。

  不幸的是，MTP 很容易被少数矿工小幅操纵，也能被多数算力大幅操纵。在区块链重组期间，MTP 甚至可能意外回退到更早的时间。相比之下，高度只有在极端重组中才可能下降。[^height-decreasing]这通常让审查者可以做一个简化假设：高度只会增加；因此基于高度的激活机制比基于 MTP 的机制更容易分析。

  两种提案之间的这些权衡，加上其他一些顾虑，造成了僵局。一些开发者认为，正是这一僵局使两个 PR 都无法获得更多审查，更无法让其中之一最终合并进 Bitcoin Core。两个 PR 的作者达成折中方案后，僵局得以化解，激活讨论中的部分参与者对此表示满意：

  1. 用 MTP 确定节点开始统计为软分叉发出信号的区块的时间，统计从开始时间之后的下一个 2,016 个区块的难度调整周期之初启动。这与 [BIP9][] versionbits 和 [BIP148][] UASF 为它们协助激活的软分叉开始统计区块的方式相同。

  2. 同样用 MTP 确定节点停止统计尚未锁定的软分叉信号区块的时间。不过与 BIP9 不同的是，MTP 的停止时间只在执行过统计的难度调整周期结束时检查。这样就消除了激活尝试直接从*已开始*跳到*失败*的可能，简化了分析，并保证矿工至少有一个完整的 2,016 个区块的周期可以发出激活信号。

  3. 使用高度作为最小激活参数。这进一步简化了分析，并且仍然与允许多个测试网络共享激活参数的目标兼容。即使这些网络上的高度可能不同，它们都可以使用 `0` 的最小激活高度在 MTP 定义的窗口内激活。

  尽管一些讨论参与者对折中方案表示不满，但它的[实现][Bitcoin Core #21377]现已获得 Bitcoin Core 十多位活跃贡献者，以及另外两个全节点实现（btcd 和 libbitcoin）维护者的审查或支持表态。我们希望这股激活 taproot 的势头能够延续，也希望能在此后的 Newsletter 中报告更多进展。

## Bitcoin Core PR 审查俱乐部

*在这个每月栏目中，我们总结了最近的一次 [Bitcoin Core PR 审查俱乐部][Bitcoin Core PR Review Club]会议，重点介绍了一些重要的问题和答案。点击下面的问题即可查看会议中答案的摘要。*

[引入 deploymentstatus][review club #19438] 是 Anthony Towns 提交的一个 PR（[#19438][Bitcoin Core #19438]），它提出三个辅助函数，使未来的部署更容易被埋藏，而无需改动所有检查软分叉激活状态的代码路径：`DeploymentEnabled` 用于测试某个部署是否可以处于活跃状态，`DeploymentActiveAt` 用于检查某个部署是否应在给定区块中强制执行，`DeploymentActiveAfter` 用于判断某个部署是否应在下一个区块中强制执行。这三个函数同时适用于埋藏部署和版本位部署。

本次审查俱乐部的讨论集中在理解这一改动及其潜在好处上。

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

  q3="**<!--q3-->**如果 taproot 软分叉被激活，之后我们又想埋藏这种激活方法，那么在合并此 PR 的前提下，需要对 Bitcoin Core 做哪些改动？"
  a3="与当前代码相比，主要改动会大大简化：把 `DEPLOYMENT_TAPROOT` 一行从 `DeploymentPos` 枚举器移到 `BuriedDeployment` 枚举器中。最重要的是，[不需要改动任何验证逻辑][burying taproot]。"
  a3link="https://bitcoincore.reviews/19438#l-227"
%}

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]中值得注意的变更。*

- [Bitcoin Core #21594][] 为 `getnodeaddresses` RPC 添加了 `network` 字段，以帮助识别各种网络（即 IPv4、IPv6、I2P、onion）上的节点。作者还提议，这为未来的 `getnodeaddresses` 补丁奠定了基础，该补丁将接受特定网络的参数，并仅返回该网络中的地址。

- [Bitcoin Core #21166][] 改进了 `signrawtransactionwithwallet` RPC，使它能够为这样的交易中的输入签名：该交易里还有其他不属于钱包的已签名输入。[此前][Bitcoin Core #21151]，如果传给该 RPC 的交易含有不属于钱包的已签名输入，返回交易中这些输入的见证会被破坏。为含有其他已签名输入的交易签名，在很多场景下都很有用，包括[添加输入/输出以提高交易手续费][Bitcoin Core #21151]。

- [LND #5108][] 增加了使用低级 `sendtoroute` RPC 进行自发[原子多路径支付][topic multipath payments]（也称为 *Original AMPs*）的支持。原始 AMP 本质上就是非交互式（或自发）的，因为所有原像都由付款方选定。由付款方选择原像也是 keysend 风格[自发支付][topic spontaneous payments]的一部分，这类支付此前已被用于单路径的自发支付。预计后续 PR 会让更上层的 `sendpayment` RPC 也能发起自发多路径支付。

- [LND #5047][] 允许钱包导入 [BIP32][] 扩展公钥（xpub），并用它们接收发往 LND 链上钱包的支付。结合 LND 最近更新的对[部分签名比特币交易（PSBT）][topic psbt]的支持（参见 [Newsletter #118][news118 lnd4389]），LND 现在可以作为其非通道资金的只读钱包来运行。例如，Alice 可以导入她冷钱包的 xpub，用 LND 提供给她的地址向该钱包存入资金，请求 LND 开启一个通道，再用冷钱包签署开启该通道的 PSBT，之后通道关闭时让 LND 自动把资金存回她的冷钱包。最后这一步——把已关闭通道的资金存回冷钱包——可能需要额外的操作，尤其是在非合作关闭通道的情况下；但这些改动让 LND 距离与支持 PSBT 的冷钱包和硬件钱包完全互操作已经不远。

## 脚注

[^height-decreasing]:
    如果区块链上的每个区块都具有相同的单块工作量证明（PoW），那么累积 PoW 最多的有效链也就是最长的链——即最新区块高度为迄今所见最高的那条链。然而每 2,016 个区块，比特币协议会调整新区块需要包含的 PoW 数量，增加或减少需要证明的工作量，以尽量把出块的平均间隔维持在 10 分钟左右。这意味着区块较少的链也可能比区块较多的链拥有更多 PoW。

    比特币用户使用拥有最多 PoW 的链——而不是最多区块的链——来确定他们是否已收到资金。当用户看到该链的一个有效变体，其中一些末尾区块被不同的区块替换时，如果该重组链包含比他们当前链更多的 PoW，他们会使用该*重组*链。因为重组链可能包含更少的区块，尽管具有更多的累积 PoW，链的高度可能会下降。

    尽管这是一个理论上的隐患，但通常并不构成实际问题。只有当重组跨越至少一个*难度调整*边界（即一组 2,016 个区块与另一组 2,016 个区块之间）时，高度才可能下降。它还需要一次涉及大量区块的重组，或者所需 PoW 数量近期发生过重大变化（意味着算力近期大幅上升或下降，或存在矿工可观察到的操纵）。就 [BIP8][] 而言，我们认为一次使高度下降的重组，在激活期间对用户的影响不会比一次更常见的重组更大。

{% include references.md %}
{% include linkers/issues.md issues="21594,21166,5108,5047,21377,21392,19438,21151" %}
[news118 lnd4389]: /zh/newsletters/2020/10/07/#lnd-4389
[news139 activation]: /zh/newsletters/2021/03/10/#taproot-activation-discussion
[mtp]: https://bitcoin.stackexchange.com/a/67622/21052
[easier burying]: https://github.com/bitcoin/bitcoin/pull/11398#issuecomment-335599326
[burying taproot]: https://bitcoincore.reviews/19438#l-230
[Bitcoin Core PR Review Club]: https://bitcoincore.reviews/