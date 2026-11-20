---
title: 'Bitcoin Optech Newsletter #178'
permalink: /zh/newsletters/2021/12/08/
name: 2021-12-08-newsletter-zh
slug: 2021-12-08-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周 Newsletter 描述了一篇关于手续费追加（fee bumping）的研究文章，并包含我们的常规栏目：Bitcoin Core PR 审查俱乐部会议总结、比特币软件的最新版本与候选发布，以及主流基础设施项目的值得注意的变更。


## 新闻

- **<!--fee-bumping-research-->****关于手续费追加机制的研究：** Antoine Poinsot 在 Bitcoin-Dev 邮件列表[发布文章][darosior bump]，详细阐述了开发者在选择如何为[保险库][topic vaults]和闪电网络（LN）等合约协议中使用的预签名交易追加手续费时需要考虑的几个问题。Poinsot 特别研究了参与者超过两方的多方协议方案，这类方案无法使用当前的 [CPFP 豁免（carve-out）][topic cpfp carve out] 交易中继策略，因此必须使用可能易受[交易钉住][topic transaction pinning]影响的[交易替换][topic rbf]机制。文章还包含了对前面提到的一些思路进行[研究][revault research]所得到的结果。

  确保手续费追加机制可靠运行是大多数合约协议安全性的必要条件，但目前仍缺乏全面解决方案。相关研究的持续进展令人鼓舞。

## Bitcoin Core PR 审查俱乐部

*在本月的栏目中，我们总结近期 [Bitcoin Core PR 审查俱乐部][Bitcoin Core PR Review Club] 会议内容，重点呈现部分重要问答。点击下方问题可查看会议讨论的答案摘要。*

[Treat taproot as always active][review club #23512] 是 Marco Falke 提出的拉取请求，旨在使花费 [Taproot][topic taproot] 输出的交易成为标准交易，无论 Taproot 的部署状态如何。

{% include functions/details-list.md
  q0="**<!--q0-->**代码库中哪些部分使用 Taproot 部署状态？其中哪些与策略相关？"
  a0="在此 PR 前有 4 个部分：
  [GetBlockScriptFlags()][GetBlockScriptFlags tap]（共识）、
  [AreInputsStandard()][AreInputsStandard tap]（策略）、
  [getblockchaininfo()][getblockchaininfo tap]（RPC）、
  [isTaprootActive()][isTaprootActive tap]（钱包）。"
  a0link="https://bitcoincore.reviews/23512#l-21"

  q1="**<!--q1-->**哪个内存池验证函数会检查交易是否花费了 Taproot 输入？本 PR 如何修改该函数？"
  a1="函数是 [`AreInputsStandard()`][AreInputsStandard def]。本 PR 移除了函数签名中的最后一个参数 `bool taproot_active`，并对 v1 segwit（taproot）的花费一律返回 `true`，无论 taproot 是否已激活。此前，如果该函数发现 taproot 输出而 `taproot_active` 为 false（例如节点仍处于初始区块下载阶段、正在同步 taproot 激活前的区块），它就会返回 false。"
  a1link="https://bitcoincore.reviews/23512#l-40"

  q2="**<!--q2-->**此变更是否存在理论上的问题？钱包用户是否可能损失资金？"
  a2="通过此变更，钱包允许在任何时间导入 Taproot [描述符][topic descriptors]，即使 Taproot 未激活且 v1 segwit 输出可被任何人花费。这意味着用户可能在 Taproot 未激活时接收比特币至 Taproot 输出；如果链发生重组至 709,632 区块之前，矿工（或能确认非标准交易的人）可窃取这些 UTXO。"
  a2link="https://bitcoincore.reviews/23512#l-82"

  q3="**<!--q3-->**理论上，是否存在 Taproot 从未激活或在其他区块高度激活的主网链？"
  a3="两者都有可能。若发生大规模重组（分叉点早于 taproot 锁定），部署流程会重新进行。在这条新链中，如果为 taproot 发信号的区块数始终未达阈值，这条（仍然有效的）链就永远不会激活 taproot。如果阈值在最小激活高度之后、超时之前达到，taproot 也可能在更晚的高度激活。"
  a3link="https://bitcoincore.reviews/23512#l-130"
%}

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [BDK 0.14.0][] 是该钱包开发库的最新版本。它简化了向交易添加 `OP_RETURN` 输出的流程，并改进了向 [bech32m][topic bech32] 地址（用于 [taproot][topic taproot]）发送支付的功能。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo] 的值得注意的变更。*

- [Bitcoin Core #23155][] 扩展了 `dumptxoutset` RPC 的功能，使其包含链状态快照（UTXO 集）的哈希值及截至该点的总交易数量。这些信息可与链状态一同发布，他人可通过 `gettxoutsetinfo` RPC 验证，从而用于拟议的 [assumeUTXO][topic assumeutxo] 节点启动方案。

- [Bitcoin Core #22513][] 允许 `walletprocesspsbt` 在签名后不完成[部分签名比特币交易（PSBT）][topic psbt]流程。这对复杂脚本很有用，例如一个包含两条路径的 [tapscript][topic tapscript]：一条仅需签名者 Alice 的备用脚本路径，另一条是包含 Alice 在内的多个签名者的常规路径。当 Alice 签名时，最好暂不用备用脚本路径来最终确定 PSBT，而是先构建一个包含 Alice 两个签名的 PSBT，把它交给其他签名者，等待他们签名。在这个场景中，最终采用哪条路径是在所有签名都生成之后才确定的。

- [C-Lightning #4921][] 更新了[洋葱消息][topic onion messages]的实现，以匹配[路由盲化][bolts #765]和[洋葱消息][bolts #759]草案规范的最新修订。

- [C-Lightning #4829][] 新增对 [BOLTs #911][] 中拟议 LN 协议变更的实验性支持，允许节点公布其 DNS 地址而非 IP 地址或 Tor 洋葱服务地址。

- [Eclair #2061][] 新增对[洋葱消息][bolts #759]的初步支持。用户可启用 `option_onion_messages` 功能以中继洋葱消息，并通过 `sendonionmessage` RPC 发送洋葱消息。接收洋葱消息和[路由盲化][bolts #765]功能尚未实现。

- [Eclair #2073][] 新增对 [BOLTs #906][] 草案中可选通道类型协商功能位的支持，与 LND 上周实现的[相同草案功能][news177 lnd6026] 对应。

- [Rust-Lightning #1163][] 允许远端把自己的通道储备金设到低于粉尘限制，甚至可以一路降到零。在最坏的情况下，这使本地节点可以零成本地尝试从一个资金已耗尽一空的通道中窃取资金——不过，如果远端一直在监控自己的通道，这种窃取尝试仍然会失败。默认情况下，多数远端节点会设置一个合理的通道储备金，以此抑制这类尝试；但一些闪电服务提供商（LSP）使用较低或为零的通道储备金，以便为用户提供更好的体验——让用户能花掉通道内 100% 的资金。由于承担风险的只有远端，允许本地节点接受这类通道并没有问题。

{% include references.md %}
{% include linkers/issues.md issues="23155,22513,4921,4829,2061,2073,906,1163,765,759,911,23512" %}
[bdk 0.14.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.14.0
[news177 lnd6026]: /zh/newsletters/2021/12/01/#lnd-6026
[darosior bump]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-November/019614.html
[revault research]: https://github.com/revault/research
[GetBlockScriptFlags tap]: https://github.com/bitcoin/bitcoin/blob/dca9ab48b80ff3a7dbe0ae26964a58e70d570618/src/validation.cpp#L1616
[AreInputsStandard tap]: https://github.com/bitcoin-core-review-club/bitcoin/blob/15d109802ab93b0af9647858c9d8adcd8a2db84a/src/validation.cpp#L726-L729
[getblockchaininfo tap]: https://github.com/bitcoin/bitcoin/blob/dca9ab48b80ff3a7dbe0ae26964a58e70d570618/src/rpc/blockchain.cpp#L1537
[isTaprootActive tap]: https://github.com/bitcoin-core-review-club/bitcoin/blob/15d109802ab93b0af9647858c9d8adcd8a2db84a/src/interfaces/chain.h#L292
[AreInputsStandard def]: https://github.com/bitcoin/bitcoin/blob/dca9ab48b80ff3a7dbe0ae26964a58e70d570618/src/policy/policy.h#L110
