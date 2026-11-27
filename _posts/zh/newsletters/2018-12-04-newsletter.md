---
title: "Bitcoin Optech Newsletter #24"
permalink: /zh/newsletters/2018/12/04/
name: 2018-12-04-newsletter-zh
slug: 2018-12-04-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了一项调整 Bitcoin Core 相关交易中继策略的提案，以帮助简化 LN 支付的链上手续费；提到了即将举行的 LN 协议会议；并简述了一个新的 LND 版本，以及 Bitcoin Core 维护版本的相关工作。

## 行动项

- **<!--maintenance-release-->**Bitcoin Core 正在准备即将发布的[维护版本][maintenance release] 0.17.1。维护版本包括错误修复和次要功能的回溯移植。我们鼓励任何打算采用此版本的人查看[回溯修复列表][0.17.1 milestone]，并在发布候选版本可用时帮助测试。

## 新闻

- **<!--cpfp-carve-out-->****CPFP 豁免（carve-out）：** 为了花费比特币，你收到这些比特币的那笔交易必须在你的花费交易之前出现在区块链上。它可以在之前的区块中，也可以和花费交易在同一个区块中但排在前面。这一协议要求意味着，高费率的花费交易可以通过费率平均，让打包其未确认的父交易变得有利可图，即使该父交易的费率很低。这就是子为父付（CPFP）。

  CPFP 甚至适用于多笔后代交易，但需要考虑的关系越多，节点为矿工创建最有利可图的区块模板所需的时间就越长。出于这个原因，Bitcoin Core 限制[^fn-cpfp-limits]了相关交易的最大数量和大小。对于给自己的交易做手续费追加的用户，这些限制足够高，通常不会引起问题。但是，对于使用多方协议的用户，恶意对手可以利用这些限制，阻止诚实用户做手续费追加。对于依赖时间锁的协议（如 LN）来说，这可能是一个重大问题——如果交易在时间锁过期之前没有确认，对手方就可以收回他们之前支付的一部分或全部资金。

  为了解决这个问题，Matt Corallo [建议][carve out thread]修改 CPFP 政策，留出（carve-out）一些空间，供一个在内存池中只有一个祖先的小交易使用（它的其他祖先必须都已经在区块链中）。这与[上周 Newsletter][last week's newsletter] *新闻*部分描述的 LN 提案相配套：该提案中 LN 基本忽略链上手续费（合作关闭通道除外），并在通道关闭时用 CPFP 手续费追加来决定手续费，从而降低复杂性、提高安全性。然而，要让这在无论手续费多高的情况下都对 LN 安全，节点还需要支持中继这样的交易包：其中既包含低费率的祖先，也包含高费率的后代，以免节点因为先前的交易太便宜而自动拒绝它们，从而看不到后续的手续费追加。虽然 carve-out 政策大概不难实现，但交易包中继已经讨论了很长时间，至今尚未正式规定或实现。

- **<!--organization-of-ln-1-1-specification-effort-->****LN 1.1 规范工作的组织：** 尽管 LN 协议开发者已经决定了[要做哪些工作][ln1.1 accepted proposals]来推进通用协议的下一个主要版本，但他们仍在制定这些协议的确切规范，并努力就此达成一致。Rusty Russell 正在组织会议以加快规范制定过程，并开了一个[讨论帖][ln spec meetings]，征求反馈：会议用什么媒介（Google Hangout、IRC 会议或其他方式），以及会议开到多正式。建议任何计划参与这一过程的人至少关注这个讨论帖。

- **<!--releases-->****发布：**[LND 0.5.1][] 作为一个新的次要版本发布，尤其侧重改进对 Neutrino 的支持。Neutrino 是一种轻量级钱包（SPV）模式，LND 可以用它进行 LN 支付，而不必直接使用全节点。此版本还修复了 btcwallet 后端用户的一个记账错误：支付给自己的找零可能没有全部反映在显示的余额中。升级后会对区块链做一次重新扫描，以恢复缺失的记账信息，并显示正确的余额。没有资金面临风险，只是记录不正确。

  Bitcoin Core 项目计划很快开始标记[维护版本][maintenance release] 0.17.1 的发布候选版本。预计这将解决近期 Linux 发行版上由构建系统不兼容导致的一些错误，并修复其他[小问题][0.17.1 milestone]。

[LND 0.5.1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.5.1-beta

## 值得注意的代码变更

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-lightning][core lightning repo] 和 [libsecp256k1][libsecp256k1 repo] 中值得注意的代码变更。*

- [LND #1937][] 将最近的通道重建消息存储在节点的数据库中，以便在通道关闭之后也能重新发送。这提高了节点在连接问题叠加部分数据丢失时恢复的机会。

- [Bitcoin Core #14477][] 给 `getaddressinfo`、`listunspent` 和 `scantxoutset` RPC 新增了 `desc` 字段：当钱包掌握的信息足以认定某个地址是*可解的*（solvable）时，该字段会给出这个地址对应的[输出脚本描述符][output script descriptors]。所谓地址可解，是指某个程序对该地址的 scriptPubKey、可选的 redeemScript 和可选的 witnessScript 了解得足够多，足以生成一个未签名的输入，来花费发送到该地址的资金。`getaddressinfo` RPC 还新增了 `solvable` 字段，用来单独表明钱包知道如何解出该地址。

  预计新的 `desc` 字段眼下不会特别有用，因为目前只有 `scantxoutset` RPC 能用它；但它能用一种紧凑的方式，提供让地址可解所需的全部信息，供 Bitcoin Core 未来新增和升级的 RPC 使用，例如离线/在线（冷/热）钱包之间的交互、多重签名钱包、coinjoin 实现以及其他场景。

- [LND #2081][] 新增了若干 RPC，可用于签署部分输入由 LND 控制的交易模板。尽管这一工具的功能与 `lnwallet.Signer` 服务已有的功能相同，但启用这项新服务的机制，使开发者可以用本地机器上、甚至远程服务上其他代码提供的 gRPC，来扩展通过 LND 提供的 RPC（gRPC）。近期还计划基于这一机制再增加几项新服务。

## 脚注

[^fn-cpfp-limits]:
    Bitcoin Core 的祖先和后代深度限制：

    ```text
    $ bitcoind -help-debug | grep -A3 -- -limit
      -limitancestorcount=<n>
           Do not accept transactions if number of in-mempool ancestors is <n> or
           more (default: 25)

      -limitancestorsize=<n>
           Do not accept transactions whose size with all in-mempool ancestors
           exceeds <n> kilobytes (default: 101)

      -limitdescendantcount=<n>
           Do not accept transactions if any ancestor would have <n> or more
           in-mempool descendants (default: 25)

      -limitdescendantsize=<n>
           Do not accept transactions if any ancestor would have more than <n>
           kilobytes of in-mempool descendants (default: 101).
    ```

{% include references.md %}
{% include linkers/issues.md issues="1937,14477,2081" %}

[maintenance release]: https://bitcoincore.org/en/lifecycle/#maintenance-releases
[last week's newsletter]: /zh/newsletters/2018/11/27/#simplified-fee-bumping-for-ln
[carve out thread]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-November/016518.html
[ln1.1 accepted proposals]: https://github.com/lightningnetwork/lightning-rfc/wiki/Lightning-Specification-1.1-Proposal-States
[ln spec meetings]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001673.html
[0.17.1 milestone]: https://github.com/bitcoin/bitcoin/milestone/39?closed=1
[output script descriptors]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
