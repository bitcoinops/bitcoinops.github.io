---
title: 'Bitcoin Optech Newsletter #255'
permalink: /zh/newsletters/2023/06/14/
name: 2023-06-14-newsletter-zh
slug: 2023-06-14-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报总结了关于允许在 taproot 交易的 annex 字段内包含数据、在交易中转发的讨论，以及一份关于 “静默支付” 的 BIP 草案。此外还有我们的 “交易池规则” 限定系列的新一篇文章，以及我们的常规栏目：总结最近一次 Bitcoin Core PR 审核俱乐部会议的成果、软件的新版本和候选版本，以及热门比特币基础设施软件的重要变化。

## 新闻

- **<!--discussion-about-the-taproot-annex-->关于 taproot annex 的讨论**：Joost Jager 在 Bitcoin-Dev 邮件组中[发帖][jager annex]，请求改变 Bitcoin Core 的交易转发和挖矿策略，以允许在 [taproot][topic taproot] 交易的 annex 字段存储任意数据。 这个字段是 taproot 交易的见证数据的一个可选部分。如果这个字段里面有数据，交易和 [tapscript][topic tapscript] 中的签名必须承诺这个数据（使之无法被第三方添加、移除和改变），但当前没有其它得到定义的作用 —— 它是为了未来的协议升级（尤其是软分叉）二保留的。

    虽然之前已经有[提议][riard annex]为 annex 定义一种格式，这些提议并没有得到广泛的接受和实现。Jager 提出了两种格式（[1][jager annex]，以及 [2][jager annex2]），可用于在 annex 内添加任意数据，同时不会显著让后续的标准化工作变得更加复杂（未来的软分叉可能会捆绑这样的标准化工作）。

    Greg Sanders [询问][sanders annex] Jager 具体想在 annex 中存储什么样的数据，并介绍了他自己在使用 Bitcoin inquisition（见[周报 #244][news244 annex]）测试 [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] 提议以及 [LN-Symmetry][topic eltoo] 协议时对 annex 的用法。Sanders 也提出了一个关于 annex 的问题：在一个多方参与的协议（例如 [coinjoin][topic coinjoin]）中，每一个签名者都只承诺自己的签名所在的输入的 annex —— 不包括同一笔交易的其它输入的 annex。这意味着，如果 Alice、Bob 和 Mallory 一起签名了一笔 coinjoin 交易，Alice 和 Bob 无法阻止 Mallory 广播一个携带了更大体积的 annex 的交易版本，从而推迟交易得到确认。因为 Bitcoin Core 和其他全节点目前不会转发包含了 annex 的交易，所以现在这不是一个问题。Jager [回复][jager annex4] 称他希望实现一种不需要软分叉的 “[保险柜][topic vaults]” 合约，要在 annex 里面存储来自一次性密钥的签名；而且他[指出][jager annex3] Bitcoin Core [之前的一些工作][bitcoin core #24007]可能可以解决这个 annex 影响多方协议的问题。

- **<!--draft-bip-for-silent-payments-->静默支付的 BIP 草案**：Josie Baker 和 Ruben Somsen 在 Bitcoin-Dev 邮件组中[发帖][bs sp]出示了一份关于[静默支付][topic silent payments]的 BIP 草案。静默支付是一种可复用的支付码，将为每一次使用生成一个唯一的链上地址，从而阻止[输出关联][topic output linking]。输出关联会显著影响用户的隐私性（包括并不参与这笔交易的用户的隐私性）。这份草案非常详尽，给出了这份提议的好处、牺牲以及软件如何有效使用它的指南。一些富有洞见的评论已经在该 BIP 的 [PR][bips #1458] 中出现。

## 等待确认 #5：用于保护节点资源的规则

*这是一份关于交易转发、交易池接纳和交易挖矿选择的限定[周刊][policy series]，目标是解释为什么 Bitcoin Core 具有比共识规则更严格的交易池规则，以及钱包如何更高效地使用这些规则。*

{% include specials/policy/en/05-dos.md %}

## Bitcoin Core PR 审核俱乐部

*在这个月度栏目中，我们会总结最新的一期 [Bitcoin Core PR 审核俱乐部][Bitcoin Core PR Review Club]会议，举出一些重要的问题和回答。点击下方的问题描述，可以看到会上对该问题的回答总结。*

“[允许白名单中的入站节点在连接满载时更主动地挤出其他对等节点][review club 27600]” 是一个由 Matthew Zipkin（pinheadmz）提出的 PR，提升了节点运营者在特定场合中为自己的节点配置更理想的对等节点的能力。具体来说，即使节点运营者为潜在的入站对等节点（inbound peer）配置了一份白名单（例如，由该节点运营者自己控制的另一个轻节点），那么，在没有这个 PR 的时候，节点也可能会拒绝这个轻节点的连接（这也取决于该节点的对等节点的状态）。

这个 PR 让理想的对等节点更有可能连接到我们的节点。它是通过断开现存的入站对等节点来做到的；而在没有这个 PR 的时候，这些入站对等节点无法断开。

{% include functions/details-list.md
  q0="为什么这个 PR 仅适用于入站的对等节点请求？"
  a0="出站的（outbound）连接是由我们的节点自己 *发起* 的。这个 PR 修改的是我们的节点 *响应* 一个他人发起的连接请求时的行为。出站对等节点也可以断开，但那是通过一个完全独立的算法实现的。"
  a0link="https://bitcoincore.reviews/27600#l-33"

  q1="在调用 `SelectNodeToEvict()` 时，使用 `force` 参数会对结果产生什么影响？"
  a1="指定 `force` 参数为 `trre`，会保证返回一个非 `noban` 入账节点，如果有的话；即使如果不使用 `force`，该节点会被保护、不会被断开。没有这个 PR，函数不会返回一个被保护（不会被断开）的节点。"
  a1link="https://bitcoincore.reviews/27600#l-70"

  q2="这个 PR 会如何改变 `EraseLastKElements()` 的功能签名？"
  a2="这个函数会从一个返回 `void` 的函数，变成返回最后一个从候选断连列表中移除的条目。（这个 “受到保护” 的节点可能也会被断连，如果有必要的话。）但是，作为这次审核俱乐部会议的讨论成果，这个 PR 后续会简化，从而这个函数不会改变。"
  a2link="https://bitcoincore.reviews/27600#l-126"

  q3="`EraseLastKElements` 曾经是一个模板化的函数，但这个 PR 移除了两个模板参数。为什么要这样做呢？这个变更有什么缺点吗？"
  a3="这个函数曾经会，现在（有了这个 PR）也会使用独特的模板参数来调用，所以不需要这个函数是模板话的。这个 PR 对这个函数的变更已经被撤回了，所以它依然是模板化的，因为改变它超出了这个 PR 的范围。"
  a3link="https://bitcoincore.reviews/27600#l-126"

  q4="假设我们向 `SelectNodeToEvict()` 传入了一个有 40 个断连候选的向量。在这个 RP 实施前后，可以保护起来不断连的 Tor 节点的理论上限有变化吗？"
  a4="不论有无这个 PR，都是 40 个节点中的 34 个，假设它们都是入站节点，并且都不是 `noban` 节点的话。"
  a4link="https://bitcoincore.reviews/27600#l-156"
%}

## 新版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Core Lightning 23.05.1][] 是这个闪电节点实现的维护版本。它的更新说明里面说：“这是一个仅仅包含 bug 修复的版本，修复了外部报告的多种宕机情形。建议所有使用 v23.05 的运营者升级到此版本。”

## 重大的代码和说明书变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo] 和 [Bitcoin Inquisition][bitcoin inquisition repo]。*

- [Bitcoin Core #27501][] 添加了一个 `getpriorisisedtransactions` RPC，可以返回由用户使用 `prioritisetransaction` 创建的所有手续费的偏移量（deltas）的表，由 txid 索引。这个表也会指出各交易是否在交易池中。亦见 [周报 #250][news250 getprioritisedtransactions]。
- [Core Lightning #6243][] 升级了 `listconfigs` RPC，将所有的配置信息都放在单个目录中，同时，也会把所有配置选项的状态都传递到插件系统以重启插件。
- [Eclair #2677][] 将默认的 `max_cltv` 参数从 1008 个区块（大概一周）提升到 2016 个区块（大约两周）。这延长了支付超时的时间上限（以区块数量计）。这项变更的动机是为了让网络中的节点可以有更长的尝试支付的时间窗口（`cltv_expiry_delta`），以应对高手续费率的环境。类似的变更已经被 LND 和 CLN [合并][lnd max_cltv]。
- [Rust bitcoin #1890][] 加入了一种方法，可以统计在非 tapscript 脚本中的签名操作（sigop）的数量。单个区块内的签名操作的数量是受到限制的，而且 Bitcoin Core 的挖矿交易选择算法也会将 “签名操作体积比（ratio of sigops per size）” 更高的交易当成更大的交易，实际上就是让它们的手续费率降低。这意味着，交易的创建者使用这种新方法来检查自己所使用的签名操作的数量，会变成一件重要的事。


{% include references.md %}
{% include linkers/issues.md v=2 issues="27501,6243,2677,1890,1458,24007" %}
[policy series]: /en/blog/waiting-for-confirmation/
[jager annex]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021731.html
[riard annex]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/020991.html
[jager annex2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021756.html
[sanders annex]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021736.html
[news244 annex]: /zh/newsletters/2023/03/29/#bitcoin-inquisition-22
[jager annex3]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021743.html
[bs sp]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021750.html
[jager annex4]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021737.html
[Core Lightning 23.05.1]: https://github.com/ElementsProject/lightning/releases/tag/v23.05.1
[review club 27600]: https://bitcoincore.reviews/27600
[news250 getprioritisedtransactions]: /zh/newsletters/2023/05/10/#bitcoin-core-pr-审核俱乐部
[lnd max_cltv]: /en/newsletters/2019/10/23/#lnd-3595
