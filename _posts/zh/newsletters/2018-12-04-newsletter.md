---
title: "Bitcoin Optech Newsletter #24"
permalink: /zh/newsletters/2018/12/04/
name: 2018-12-04-newsletter-zh
slug: 2018-12-04-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了一项调整 Bitcoin Core 相关交易转发策略的提案，以帮助简化 LN 支付的链上费用，提到了即将举行的 LN 协议会议，并简要描述了一个新的 LND 版本和 Bitcoin Core 维护版本的工作。

## 行动项

- **<!--maintenance-release-->**Bitcoin Core 正在准备即将发布的[维护版本][maintenance release] 0.17.1。维护版本包括错误修复和次要功能的回溯移植。任何打算采用此版本的人都被鼓励查看[回溯修复列表][0.17.1 milestone] 并在发布候选版本可用时帮助测试。

## 新闻

- **<!--cpfp-carve-out-->****CPFP carve-out：** 为了花费比特币，你收到这些比特币的交易必须在你的花费交易之前的某个地方被添加到区块链中。这种添加可以在之前的区块中，也可以在与花费交易相同的区块中较早的地方。这一协议要求意味着，高手续费率的花费交易可以通过匀手续费给父交易，使其未确认的父交易变得有利可图，即使该父交易的手续费率较低。这被称为子支付父（CPFP）。

  CPFP 甚至适用于多个后代交易，但需要考虑的关系越多，节点创建最有利可图的块模板以供矿工使用的时间就越长。出于这个原因，Bitcoin Core 限制[^fn-cpfp-limits]了相关交易的最大数量和大小。对于用户自己提高交易费用，这些限制足够高，通常不会引起问题。但是，对于使用多方协议的用户，恶意对手可以利用这些限制，防止诚实用户提高交易费用。这对于依赖时间锁的协议（如 LN）来说可能是一个重大问题——如果交易在时间锁过期之前没有确认，对手方可以收回他们之前支付的一部分或全部资金。

  为了解决这个问题，Matt Corallo [建议][carve out thread]对 CPFP 政策进行修改，以 carve-out（预留）一些空间用于一个在内存池中只有一个祖先的小交易（它的所有其他祖先必须已经在区块链中）。这伴随着[上周 Newsletter][last week's newsletter] *新闻*部分中描述的 LN 提案，其中 LN 将大部分忽略链上费用（除了合作关闭通道）并使用 CPFP 提高费用来选择关闭通道时的费用——简化复杂性并提高安全性。然而，为了使这对 LN 安全，不管费用多高，节点还需要支持转发包含低手续费率祖先和高手续费率后代的交易包，以避免节点自动拒绝先前的交易，认为它们太便宜，从而看不到后续的费用增加。虽然 carve-out 政策可能很容易实现，但交易包转发已经讨论了很长时间，还没有正式指定或实现。

- **<!--organization-of-ln-1-1-specification-effort-->****LN 1.1 规范工作的组织：** 尽管 LN 协议开发人员决定了[哪些工作][ln1.1 accepted proposals]是他们希望在下一个通用协议主要版本中进行的，但他们仍在制定和达成对这些协议的确切规范的共识。Rusty Russell 正在组织会议，以帮助加速规范过程，并开始了一个[线程][ln spec meetings]，征求关于使用什么媒介进行会议（Google Hangout、IRC 会议、其他方式）以及如何使会议更正式的反馈。建议任何计划参与这一过程的人至少关注这个线程。

- **<!--releases-->****发布：**[LND 0.5.1][] 作为一个新的次要版本发布，特别关注其对 Neutrino 的支持，Neutrino 是一种轻量级钱包（SPV）模式，LND 可以使用它在不直接使用全节点的情况下进行 LN 支付。此版本还修复了 btcwallet 后端用户的一个记账错误，其中并非所有对自己的找零支付都反映在显示的余额中。升级后，将对区块链进行重新扫描，以恢复缺失的记账信息，并显示正确的余额。没有资金存在风险，只是没有正确追踪。

  Bitcoin Core 项目计划很快开始标记[维护版本][maintenance release] 0.17.1 的发布候选版本。预计这将解决一些最近 Linux 发行版上的构建系统不兼容性错误，并修复其他[小问题][0.17.1 milestone]。

[LND 0.5.1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.5.1-beta

## 值得注意的代码更改

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-lightning][core lightning repo] 和 [libsecp256k1][libsecp256k1 repo] 中值得注意的代码更改。*

- [LND #1937][] 将最新的通道重新建立消息存储在节点的数据库中，以便在通道关闭后也能重新发送。这提高了节点从连接问题和部分数据丢失中恢复的机会。

- [Bitcoin Core #14477][] 向 `getaddressinfo`、`listunspent` 和 `scantxoutset` RPC 添加了一个新的 `desc` 字段，提供每个地址的[输出脚本描述符][output script descriptors]，当钱包有足够的信息认为该地址是*可解的*时。一个地址是可解的，当一个程序知道其 scriptPubKey、可选的赎回脚本和可选的见证脚本，以便程序生成一个未签名的输入来花费发送到该地址的资金。一个新的 `solvable` 字段被添加到 `getaddressinfo` RPC 中，以独立指示钱包知道如何解决该地址。

  新的 `desc` 字段目前预期不会特别有用，因为它们目前只能与 `scantxoutset` RPC 一起使用，但它们将提供一种紧凑的方式，提供使地址可解的所有必要信息，以供未来和升级的 Bitcoin Core RPC 使用，例如用于离线/在线（冷/热）钱包、多重签名钱包、coinjoin 实现和其他情况。

- [LND #2081][] 添加了允许签署一些输入由 LND 控制的交易模板的 RPC。尽管这个特定工具镜像了 `lnwallet.Signer` 服务已经提供的功能，但启用这个新服务的方法使开发人员可以通过 LND 提供的 gRPCs 扩展本地机器或甚至远程服务上其他代码提供的 gRPCs。计划在不久的将来使用这种机制提供几个额外的新服务。

## 脚注

[^fn-cpfp-limits]:
    Bitcoin Core 的祖先和后代深度限制：

    ```text
    $ bitcoind -help-debug | grep -A3 -- -limit
      -limitancestorcount=<n>
           如果内存池中的祖先数量为 <n> 或更多，则不接受交易（默认：25）

      -limitancestorsize=<n>
           如果包含所有内存池祖先的交易大小超过 <n> KB，则不接受交易（默认：101）

      -limitdescendantcount=<n>
           如果任何祖先有 <n> 或更多的内存池后代，则不接受交易（默认：25）

      -limitdescendantsize=<n>
           如果任何祖先的内存池后代超过 <n> KB，则不接受交易（默认：101）。
    ```

{% include references.md %}
{% include linkers/issues.md issues="1937,14477,2081" %}

[maintenance release]: https://bitcoincore.org/en/lifecycle/#maintenance-releases
[last week's newsletter]: /zh/newsletters/2018/11/27/#simplified-fee-bumping-for-ln
[carve out thread]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-November/016518.html
[ln1.1 accepted proposals]: https://github.com/lightningnetwork/lightning-rfc/wiki/Lightning-Specification-1.1-Proposal-States
[ln spec meetings]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001673.html
[0.17.1 milestone]: https://github.com/bitcoin/bitcoin/milestone/39?closed=1
[output script descriptors]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
