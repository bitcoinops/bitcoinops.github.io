---
title: 'Bitcoin Optech Newsletter #212'
permalink: /zh/newsletters/2022/08/10/
name: 2022-08-10-newsletter-zh
slug: 2022-08-10-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报总结了关于降低 Bitcoin Core 和其他节点的默认最低交易中继费率的讨论。此外还有我们的常规部分，其中包括 Bitcoin Core PR 审核俱乐部的摘要、新版本和候选版本的公告，以及流行的比特币基础设施软件的重大变更总结。

## 新闻

- **<!--lowering-the-default-minimum-transaction-relay-feerate-->降低默认的最低交易中继费率：** Bitcoin Core 只中继那些按照[每 vbyte 最少 1 satoshi 的费率][topic default minimum transaction relay feerates]（1 sat/vbyte）支付的单个未确认交易。如果一个节点的内存池中填满了最低费率为 1 sat/vbyte 的交易，则需要支付更高的费率。支付较低费率的交易仍然可以被矿工包含在区块中，并且这些区块将被转发。其他节点软件实施了类似的策略。

    过去曾讨论过降低默认最低费用（参见 [Newsletter #3][news3 min]），但[尚未合并][bitcoin core #13922]到 Bitcoin Core。在过去的几周里，这个话题有了更多新的[讨论][chauhan min]：

    - *<!--individual-change-effectiveness-->单个变更的有效性：*[一些][vjudeu min]人[辩论][todd min]单个节点运营商改变其策略的有效性如何。

    - *<!--past-failures-->过去的失败：*讨论[提到][harding min]之前降低默认费率的尝试曾被更低的费率所阻碍。低费率也降低了几次小规模拒绝服务 (DoS) 攻击的成本。

    - *<!--alternative-relay-criteria-->备选的中继标准：*[建议][todd min2]违反某些默认标准（例如默认最低费率）的交易可以改为满足一些单独的、使 DoS 攻击成本变高标准——例如，将少量的 hashcash 式的工作量证明提交到待中继的交易上。

    在编写本文时，这些讨论还没有得出明确的结论。

## Bitcoin Core PR 审核俱乐部

*在这个每月一次的栏目中，我们会总结最近的一期 [Bitcoin Core PR 审核俱乐部][Bitcoin Core PR Review Club]会议，提炼出一些重要的问题和答案。点击下方的问题描述，就可以看到来自会议的答案。*

[从 ArgsManager 解耦验证缓存的初始化][review club 25527]是 Carl Dong 提交的一个 PR。它将节点配置逻辑与签名和脚本缓存的初始化分开，是 [libbitcoinkernel 项目][libbitcoinkernel project]的一部分。

{% include functions/details-list.md
  q0="<!--what-does-the-argsmanager-do-why-or-why-not-should-it-belong-in-src-kernel-versus-src-node-->`ArgsManager` 是做什么的？它为什么应该或不应该属于在 `src/kernel` 或 `src/node`？"
  a0="ArgsManager 是一个用于处理配置选项（`bitcoin.conf` 和命令行参数）的全局数据结构。虽然共识引擎可能包含可参数化的值（即缓存的大小），但节点不需要保留此数据结构以达成共识。作为 Bitcoin Core 中特定的功能，处理这些配置选项的代码属于在 `src/node`。"
  a0link="https://bitcoincore.reviews/25527#l-35"

  q1="<!--what-are-the-validation-caches-why-would-they-belong-in-src-kernel-versus-src-node-->什么是验证缓存？为什么它们属于 `src/kernel` 而不是 `src/node`？"
  a1="当一个新块到达时，验证中计算成本最高的部分是对其交易的脚本（即签名）验证。由于拥有内存池的节点通常已经看到并验证了这些交易，因此通过缓存（成功）脚本和签名验证，可显着提高区块验证性能。这些缓存在逻辑上是共识引擎的一部分，因为对共识很关键的区块验证代码需要它们。因此，这些缓存属于 `src/kernel`。"
  a1link="https://bitcoincore.reviews/25527#l-45"

  q2="<!--what-does-it-mean-for-something-to-be-consensus-critical-if-it-isn-t-a-consensus-rule-does-src-consensus-contain-all-the-consensus-critical-code-->一个事物是共识关键的但它本身并不是一个共识规则，会是什么意思？`src/consensus` 包含了所有对共识关键的代码么？"
  a2="参与者一致认为签名验证执行共识规则，而缓存不会。但是，如果缓存代码中有 bug 导致存储了无效的签名，则节点将不再执行共识规则。因此，签名缓存是被认为对共识关键的。共识代码实际上目前并不存在于 `src/kernel` 或 `src/consensus`；许多共识规则和共识关键代码存在于 `validation.cpp`。"
  a2link="https://bitcoincore.reviews/25527#l-61"

  q3="<!--what-tools-do-you-use-for-code-archeology-to-understand-the-background-of-why-a-value-exists-->你会用什么工具来进行“代码考古”以理解一个值为什么会存在的背景？"
  a3="参与者列出了几个命令和工具，包括 `git blame`、`git log`、在拉取请求页面中输入提交哈希、查看文件时使用 Github 的 `Blame` 按钮以及使用 Github 搜索栏。"
  a3link="https://bitcoincore.reviews/25527#l-132"

  q4="<!--this-pr-changes-the-type-of-signature-cache-bytes-and-script-execution-cache-bytes-from-int64-t-to-size-t-what-is-the-difference-between-int64-t-uint64-t-and-size-t-and-why-should-a-size-t-hold-these-values-->此 PR 将 `signature_cache_bytes` 和 `script_execution_cache_bytes` 的类型从 `int64_t` 修改为 `size_t`。`int64_t`、`uint64_t` 和 `size_t` 有哪些区别？为什么一个 `size_t` 类型的变量应当来保存这些值？"
  a4="`int64_t` 和 `uint64_t` 类型在所有平台和编译器中都是 64 位的（分别为有符号和无符号）。`size_t` 类型是一种无符号整形，一定能保存内存中任何对象的长度（以字节为单位）数据；其大小取决于系统。因此，`size_t` 非常适合这些将缓存大小保存为字节数量的变量。"
  a4link="https://bitcoincore.reviews/25527#l-163"
%}

## 软件的新版本和候选版本

*流行比特币基础设施项目的新版本和候选版本。请考虑升级到最新版本或帮助测试候选版本。*

- [Core Lightning 0.12.0rc1][] 是这个流行的闪电网络节点实现的下一个主要版本的候选版本。

## 重大代码及文档变更

*本周内，[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo] 和 [Lightning BOLTs][bolts repo] 出现的重大变更。*

- [Bitcoin Core #25610][] 默认设置启动选项 `-walletrbf` 并为 `createrawtransaction` 和 `createpsbt` RPC 默认使用 `replaceable` 选项。默认情况下，通过 GUI 创建的事务已经选用 [RBF][topic rbf]。这是在 [Newsletter #208][news208 core RBF] 中提到的更新之后，使节点运营商能够将其节点的交易替换行为从默认的选用 RBF (BIP125) 切换到完整的 RBF。在 2017 年，在 [Bitcoin Core #9527][] 中有提出过默认选用 RPC。那时候主要的反对意见是当时的新颖性、无法碰撞交易以及 GUI 没有禁用 RBF 的功能——这些在此之后都已得到解决。

- [Bitcoin Core #24584][] 修复[选币算法][topic coin selection]以更倾向于由单一输出类型组成的输入集。这解决了混合类型输入集会揭示先前交易的输出变化的场景问题。它遵循了一个相关的隐私改进，以[始终将零钱类型匹配][#23789]到一个收款人的输出（请参阅 [Newsletter #181][news181 change matching])。

- [Core Lightning #5071][] 添加了一个记账插件，可通过运行该插件的节点提供对比特币移动的会计记录，还具有跟踪费用支出的能力。合并的 PR 包括几个新的 RPC 命令。

- [BDK #645][] 添加了一种方法来指定要签名的 [taproot][topic taproot] 花费路径。以前，BDK 会在可能的情况下为密钥路径的花费签名，并为它持有密钥的任何脚本路径的叶子节点签名。

- [BOLTs #911][] 为闪电网络节点增加了一个功能，可公告已解析为 IP 地址的 DNS 主机名。有关此想法的先前讨论在 [Newsletter #167][news167 ln dns] 中提到过。

{% include references.md %}
{% include linkers/issues.md v=2 issues="25610,24584,5071,645,911,13922,9527" %}
[core lightning 0.12.0rc1]: https://github.com/ElementsProject/lightning/releases/tag/v0.12.0rc1
[news208 core RBF]: /zh/newsletters/2022/07/13/#bitcoin-core-25353
[news167 ln dns]: /en/newsletters/2021/09/22/#dns-records-for-ln-nodes
[news181 change matching]: /en/newsletters/2022/01/05/#bitcoin-core-23789
[chauhan min]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020784.html
[todd min]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020800.html
[vjudeu min]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-August/020821.html
[harding min]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020808.html
[todd min2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-August/020815.html
[news3 min]: /en/newsletters/2018/07/10/#discussion-min-fee-discussion-about-minimum-relay-fee
[#23789]: https://github.com/bitcoin/bitcoin/issues/23789
[review club 25527]: https://bitcoincore.reviews/25527
[libbitcoinkernel project]: https://github.com/bitcoin/bitcoin/issues/24303
[`ArgsManager`]: https://github.com/bitcoin/bitcoin/blob/5871b5b5ab57a0caf9b7514eb162c491c83281d5/src/util/system.h#L172
