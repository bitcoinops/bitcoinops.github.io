---
title: 'Bitcoin Optech Newsletter #189'
permalink: /zh/newsletters/2022/03/02/
name: 2022-03-02-newsletter-zh
slug: 2022-03-02-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周 Newsletter 介绍了新提议的 `OP_EVICT` opcode，并照例附上新版本与候选发布摘要以及值得注意的比特币基础设施软件变更。

## 新闻

- **<!--proposed-opcode-to-simplify-shared-utxo-ownership-->****提议简化共享 UTXO 所有权的 opcode：** 开发者 ZmnSCPxj 在 Bitcoin-Dev 邮件列表[发布][zmnscpxj op_evict]了 `OP_EVICT` opcode 的提案，用以替代[此前提议的][news166 tluv] `OP_TAPLEAF_UPDATE_VERIFY`（TLUV）opcode。与 TLUV 类似，`OP_EVICT` 聚焦于多于两名用户共同拥有单个 UTXO 的场景，例如 [joinpools][topic joinpools]、[channel factories][topic channel factories] 以及某些[契约][topic covenants]。
  为了理解 `OP_EVICT` 的工作方式，设想一个 joinpool，其中单个 UTXO 由 Alice、Bob、Carol 和 Dan 四位用户共同控制。

  目前，这四位用户可以创建一个 P2TR（taproot）输出，其 keypath 花费允许他们使用类似 [MuSig2][topic musig] 的协议，只要所有人共同参与签名即可高效支配该输出。但如果 Dan 离线或作恶，Alice、Bob 与 Carol 想要继续保持 joinpool 的隐私与效率优势，就只能事先与 Dan 准备一棵预签名交易树——并非所有交易都一定要用到，但必须都已准备好才能确保完全的容错能力。

  {:.center}
  [![使用预签名交易在无需信任地退出 joinpool 时所产生的组合爆炸示意图](/img/posts/2022-03-combinatorial-txes.dot.png)](/img/posts/2022-03-combinatorial-txes.dot.png)

  随着共享 UTXO 的用户数量增加，需要创建的预签名交易数量呈组合式激增，使得这种方案极度缺乏可扩展性（仅 10 位用户就需预签超过一百万笔交易）。其他提议的 opcode，如 TLUV 和 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]，可消除这种组合爆炸。`OP_EVICT` 达成了同样目的，并且 ZmnSCPxj 建议在此用例下它相比上述 opcode 可能更优，因为在移除共享 UTXO 成员时所需的链上数据更少。

  如果 `OP_EVICT` 通过软分叉被加入，每位成员可向其他成员共享自己的公钥及其针对某个输出（例如 Alice 1 BTC、Bob 2 BTC 等）所做的签名。在获取所有成员的公钥与签名后，大家即可“无需信任”地构造一个地址，以两种方式花费资金：

  1. 使用前述 taproot keypath 花费；
  2. 使用包含 `OP_EVICT` opcode 的 [tapscript][topic tapscript] scriptpath 花费。

  <br>若要逐出 Dan，opcode 将接收以下参数：

  - **<!--shared-pubkey-->****共享公钥：** 整个群组的共享公钥，可通过对模板的单字节引用进行高效传递；
  - **<!--number-of-evictions-->****逐出数量：** 要创建的 joinpool 退出输出数量（此例为 1）；
  - **<!--eviction-outputs-->****逐出输出：** 针对该输出（即 Dan 的退出输出）提供其索引位置与 Dan 对其的签名。Dan 的公钥与其签名的输出中所用的公钥相同；
  - **<!--unevicted-signature-->****未被逐出者的签名：** 对于共享公钥中扣除逐出输出所用公钥后的公钥，提供一个签名。换言之，由剩余成员（此例中为 Alice、Bob 与 Carol）提供的签名。

  这样，Alice、Bob 与 Carol 可在任何时间创建一笔交易来花费该群组 UTXO，而无需 Dan 的配合：他们在交易中加入 Dan 之前已签名的输出及其签名，再由 Alice、Bob 与 Carol 动态对整笔支出交易进行签名（该签名覆盖他们选择支付的手续费并按其意愿分配剩余资金）。

  截至撰写时，`OP_EVICT` 在邮件列表上获得了适度讨论，尚未出现重大疑虑，但热度似乎与去年 TLUV 提案相仿——均不算高。

## 发布与候选发布

*面向热门比特币基础设施项目的新版本与候选发布。请考虑升级至最新版本或协助测试候选版本。*

- [BTCPay Server 1.4.6][] 是这款支付处理软件的最新发布版本。自 Optech 上次覆盖的版本<!-- 1.4.2 -->以来，新增了对 [CPFP][topic cpfp] 手续费追加的支持、对 LN URL 更多特性的支持，以及多项 UI 改进。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]中的值得注意变更：*

- [HWI #550][] 为 Ledger 硬件签名设备的最新可加载比特币固件提供支持，该固件原生支持版本 2 [部分签名的比特币交易][topic psbt]以及一部分[输出脚本描述符][topic descriptors]。

{% include references.md %}
{% include linkers/issues.md v=1 issues="550" %}
[btcpay server 1.4.6]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.4.6
[zmnscpxj op_evict]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019926.html
[news166 tluv]: /zh/newsletters/2021/09/15/#covenant-opcode-proposal
