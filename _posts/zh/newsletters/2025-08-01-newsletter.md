---
title: 'Bitcoin Optech Newsletter #365'
permalink: /zh/newsletters/2025/08/01/
name: 2025-08-01-newsletter-zh
slug: 2025-08-01-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的新闻部分总结了致密区块中继预填充的测试结果，并链接到了一个基于交易池的手续费估算代码库。此外是我们的常规栏目：总结关于比特币共识规则变更的讨论、软件新版本和测试版本的发行公告，以及流行的比特币基础设施软件的变更介绍。

## 新闻

- **<!--testing-compact-block-prefilling-->致密区块预填充测试**：David Gumberg 在 Delving Bitcoin 论坛的一个关于 “致密区块（compact block）” 重构效率的帖子（周报 [#315][news315 cb] 和 [#339][news339 cb] 曾介绍）中[回复][gumberg prefilling]了他从[致密区块中继][topic compact block relay] *预填充* 测试中得到的结果 —— 预填充指的是，当一个节点认为其对等节点可能还不知晓下一个区块将包含的交易时，就抢先把这些交易转发给他们。Gumberg 的帖子非常详细，并且链接了一个 Jupyter 笔记，所以其他人也能自己做实验。要点包括：

  * 在不考虑网络流量时，一个确定要预填充什么交易的简单规则可以将区块重新构造的成功率从 62% 提高到大约 98% 。

  * 在考虑网络流量时，一些预填充可能会导致额外的通信轮次 —— 这就打消了所有的好处，而且可能会稍微削弱性能。不过，可以通过构造许多预填充来避免这个问题，从而将重新构造的成功率提高到 93%，并且还可以进一步提升。

- **<!--mempoolbased-fee-estimation-library-->基于交易池的手续费估计器代码库**：Lauren Shareshian 在 Delving Bitcoin 论坛中[发帖][shareshian estimation]宣布了一个由 Block 开发的[手续费估算器][topic fee estimation]代码库。与别的一些手续费估计工具不同的是，该代码库只使用进入一个节点的交易池的交易流作为估计的基础。帖子比较了该库（Augur）和多个手续费估计服务，发现 Augur 的失手概率较低（即，超过 85% 的交易在其预计的时间窗口内确认），而且平均高估概率也较低（即，平均来说，交易只比必要水平多付了 16%）。

  Abrbakar Sadiq Ismail [回复][ismail estimation]了这个帖子，并且在 Augur 代码库中打开了一个信息沟通 [issue][augur #3]，用于检验该库所用的部分假设。

## 共识变更

*这个月度栏目会总结关于变更比特币共识规则的提议和讨论。*

- **<!--migration-from-quantumvulnerable-outputs-->从量子脆弱的输出迁移**：Jameson Lopp 在 Bitcoin-Dev 邮件组中[发帖][lopp qmig]，提出了一个分成三个步骤、逐渐取消[量子脆弱输出][topic quantum resistance]的提议。

  * 在 [BIP360][] 量子抗性签名方案（或替代性方案）激活共识的三年之后，激活一个软分叉，从此拒绝支付到量子脆弱地址的交易。只能支付给量子抗性输出。

  * 再过两年，激活第二个软分叉，拒绝从量子敏感地址花费的交易。任何留在量子脆弱输出中的资金，从此都将不可再花费。

  * 可选，在不确定的未来，再激活一次共识变更，允许量子脆弱输出中的资金使用一种量子抗性证据方案来花费（[周报 #361][news361 pqcr] 提出了一个例子）。

  该帖子的大部分内容是重复此前关于何以在量子计算机足够快之前就必须阻止人们从量子敏感的输出中花费的讨论（详见 [周报 #348][news348 destroy]）。双方都提出了合理的论证，我们希望辩论能够继续。

- **<!--taproot-native-op-templatehash-proposal-->****Taproot 原生的 `OP_TEMPLATEHASH` 提议**：Greg Sanders 在 Bitcoin-Dev 邮件组中[发布][sanders th]了一个向 [tapscript][topic tapscript] 添加三个操作码的提议。其中两个是此前已被提议的 [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] 和 `OP_INTERNALKEY`（详见 [周报 #285][news285 ik]）。最后一个是 `OP_TEMPLATEHASH`，是 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] 的 Taproot 原生变种；作者指出原版与变种有以下区别：

  * 不改动传统（隔离见证前）脚本。此前关于这一抉择的讨论见[周报 #361][news361 ctvlegacy]。

  * 被哈希的数据（以及哈希的顺序）非常类似于为在 [taproot][topic taproot] 承诺的签名而哈希的数据，简化了任何已经支持 taproot 的软件的实现。

  * 它会承诺 taproot 附言（[annex][topic annex]），而 `OP_CTV` 不会。它的一种用法是，可以用来保证一些数据会作为交易的一部分，比如用在合约式协议中、允许对手方从旧状态的发布中复原的数据。

  * 它重新定义了一种 `OP_SUCCESSx` 操作码，而不是一种 `OP_NOPx` 操作码。重新定义 `OP_NOPx` 操作码的软分叉必然是 `VERIFY` 操作码，在执行失败时就将交易标记为无效。而重新定义 `OP_SUCCESSx` 操作码的软分叉可以直接在执行后在堆栈中放置 `1`（表示成功）或者 `0`（表示失败）；这让它们在一些情形下可以直接使用，而重新定义的 `OP_NOPx` 则必须用 `OP_IF` 语句这样的条件来封装。

  * “它防止了与 …… `scriptSig` 一起造成的惊吓”（详见[周报 #361][news361 bitvm]）

  Brandon Black 在[回复][black th]中将该提议与他早先的 LNHANCE 捆绑提议（详见[周报 #285][news285 ik]）相比较，发现两者在绝大部分方面是类型的，虽然他指出，该提议在 *拥堵控制*（一种形式的推迟[支付批量处理][topic payment batching]）用法中链上空间效率较差。

- **<!--proposal-to-allow-longer-relative-timelocks-->允许更长时间的相对时间锁**：开发者 Pyth 在 Delving Bitcoin 论坛中[发帖][pyth timelock]建议允许 [BIP68][] 相对时间锁的最大长度从当前的 1 年延长到大约 10 年。这将需要一次软分叉，还要在交易输入的 *sequence* 字段使用额外的一个比特。

  Fabian Jahr [回复][jahr timelock]了让[时间锁][topic timelocks]变得太长可能导致资金损失的顾虑，比如，因为量子计算机的开发（或者，我们补充一句，因为上文所述的 Jameson Lopp 的量子抵抗协议的开发）。Steven Roose [指出][roose timelock]，长时间时间锁已经能够使用其它时间锁机制来做到了（比如，使用预签名交易和 [BIP65 CLTV][bip65]）。而 Pyth 补充说，它们的目标用途是一条钱包复原路径：长时间锁只会在主要路径变得不可用时派上用场，此时，另一种结局只剩资金永久丢失了。

- **<!--security-against-quantum-computers-with-taproot-as-a-commitment-scheme-->****使用 taproot 作为一种承诺方案，安全抵抗量子计算机**：Tim Ruffing 的[帖子][ruffing qtr]链接了一篇他撰写的[论文][ruffing paper]，分析了 [taproot][topic taproot] 承诺抵抗量子计算机篡改的安全性。他检验了 [tapscript][topic tapscript] 的 taproot 承诺是否还能继续持有像对抗传统计算机那样的 *绑定* 和 *隐藏* 属性。他的结论是：

  > 量子攻击者需要执行至少 2^81 次 SHA256 求值，才能以 1/2 的概率创建一个 Taproot 输出、并用意料之外的默克尔根来打开这个输出。如果攻击者的量子计算机的 SHA256 计算的最长序列限制在 2^20 ，那么 TA 需要至少 2^92 台这样的机器，才能让成功率达到 1/2 。

  如果 taproot 承诺可以抵抗量子计算机的篡改，那么只需禁用 taproot 密钥花费、向 [tapscript][topic tapscript] 添加抗量子签名检查操作码，就可以向比特币添加量子抗性。Ethan Heilma 在 Bitcoin-Dev 邮件组中发布的[帖子][heilman bip360]，对 [BIP360][] “支付到量子抗性哈希值” 的最新更新，作出的正是这样的变更。

## 新版本和候选版本

*流行的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本，或帮助测试候选版本。*

- [Bitcoin Core 29.1rc1][] 是这个主流的全节点软件的维护版本的候选发行。

## 重要的代码和说明书变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Bitcoin Core #29954][] 通过加入两个转发策略字段到其响应对象中，延申了 `getmempoolinfo` RPC：`permitbaremultisig`（节点是否转发裸多签名输出）和 `maxdatacarriersite`（交易池中一笔交易的 OP_RETURN 输出可允许的合并最大字节量）。其他策略标签，比如 [`fullrbf`][topic rbf] 和 `minrelaytxfee`，已经暴露了，所以添加的字段实现了完整的转发策略快照。

- [Bitcoin Core #33004][] 默认启用 `-natpmp` 选项，允许通过 “端口控制协议（[PCP][pcp]）” 的自动端口转发，并带有 “NAT 端口映射协议（59）”的后备机制（详见周报[#323][news323 natpmp]）。在支持 PCP 或 NAT-PMP 的路由器背后的监听节点，都可访问，无需手动配置。

- [LDK #3246][] 允许使用 offer 的 `signing_pubkey` 作为目的地、不使用[盲化路径][topic rv routing]来创建 [ BOLT12 Offer][topic offers] 和退款。`create_offer_builder` 和 `create_refund_builder` 函数现在将盲化路径的创建委托给 `MessageRouter::create_blinded_paths`；在其中，调用者可以通过传入 `DefaultMessageRouter` 来生成一条紧凑的路径、传入 `NodeIdMessageRouter` 来生成全长度的公钥路径，或传入 `NodeIdMessageRouter` 来生成空路径。

- [LDK #3892][] 将 [BOLT12][topic offers] 发票的默克尔树签名公开暴露，允许开发者构建命令行工具或其他软件来验证签名和重新创建发票。这项 PR 还添加了一个 `OfferId` 字段到 BOLT12 发票中，以跟踪源头 offer 。

- [LDK #3662][] 实现了 [BLIPs #55][]，也被称作 “LSPS05”，它定义了客户端如何通过一个端点（endpoint）来注册 webhook，从而可以接收来自一个 LSP 的通知。这个 API 暴露了额外的端点，让客户端可以列出所有的 webhook 注册，还可以移除具体的一个。在接收[异步支付][topic async payments]时，获得通知到客户端来说很有用。

{% include references.md %}
{% include linkers/issues.md v=2 issues="29954,33004,3246,3892,3662,55" %}
[bitcoin core 29.1rc1]: https://bitcoincore.org/bin/bitcoin-core-29.1/
[augur #3]: https://github.com/block/bitcoin-augur/issues/3
[news315 cb]: /zh/newsletters/2024/08/09/#statistics-on-compact-block-reconstruction
[news339 cb]: /zh/newsletters/2025/01/31/#updated-stats-on-compact-block-reconstruction
[gumberg prefilling]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/34
[shareshian estimation]: https://delvingbitcoin.org/t/augur-block-s-open-source-bitcoin-fee-estimation-library/1848/
[ismail estimation]: https://delvingbitcoin.org/t/augur-block-s-open-source-bitcoin-fee-estimation-library/1848/2
[news361 pqcr]: /zh/newsletters/2025/07/04/#commit-reveal-function-for-post-quantum-recovery
[sanders th]: https://mailing-list.bitcoindevs.xyz/bitcoindev/26b96fb1-d916-474a-bd23-920becc3412cn@googlegroups.com/
[news285 ik]: /zh/newsletters/2024/01/17/#lnhance
[news361 ctvlegacy]: /zh/newsletters/2025/07/04/#concerns-and-alternatives-to-legacy-support
[pyth timelock]: https://delvingbitcoin.org/t/exploring-extended-relative-timelocks/1818/
[jahr timelock]: https://delvingbitcoin.org/t/exploring-extended-relative-timelocks/1818/2
[roose timelock]: https://delvingbitcoin.org/t/exploring-extended-relative-timelocks/1818/3
[ruffing qtr]: https://mailing-list.bitcoindevs.xyz/bitcoindev/bee6b897379b9ae0c3d48f53d40a6d70fe7915f0.camel@real-or-random.org/
[ruffing paper]: https://eprint.iacr.org/2025/1307
[heilman bip360]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAEM=y+W=rtU2PLmHve6pUVkMQQmqT67KOg=9hp5oMspuHrgMow@mail.gmail.com/
[lopp qmig]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CADL_X_fpv-aXBxX+eJ_EVTirkAJGyPRUNqOCYdz5um8zu6ma5Q@mail.gmail.com/
[news348 destroy]: /zh/newsletters/2025/04/04/#should-vulnerable-bitcoins-be-destroyed
[black th]: https://mailing-list.bitcoindevs.xyz/bitcoindev/aG9FEHF1lZlK6d0E@console/
[news361 bitvm]: /zh/newsletters/2025/07/04/#continued-discussion-about-ctv-csfs-advantages-for-bitvm
[news323 natpmp]: /zh/newsletters/2024/10/04/#bitcoin-core-30043
[pcp]: https://datatracker.ietf.org/doc/html/rfc6887
[natpmp]: https://datatracker.ietf.org/doc/html/rfc6886
