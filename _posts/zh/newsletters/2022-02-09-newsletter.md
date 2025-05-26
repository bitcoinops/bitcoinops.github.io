---
title: 'Bitcoin Optech Newsletter #186'
permalink: /zh/newsletters/2022/02/09/
name: 2022-02-09-newsletter-zh
slug: 2022-02-09-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周 Newsletter 描述了关于修改 Replace-by-Fee（RBF） 交易中继策略的讨论，并照例包含 Bitcoin Core PR 审查俱乐部会议摘要、新版本与候选发布公告，以及流行比特币基础设施项目的值得注意的变更说明。

## 新闻

- **<!--discussion-about-rbf-policy-->****关于 RBF 策略的讨论：**
  Gloria Zhao 在 Bitcoin-Dev 邮件列表发起了[讨论][zhao rbf]，主题为 Replace-by-Fee（RBF） 策略。她的邮件首先回顾了当前策略的背景，列举了多年来发现的若干问题（例如[交易固定][topic transaction pinning]攻击），分析了该策略对钱包用户界面的影响，随后提出了若干可能的改进方案。邮件重点关注基于“下一块模板”上下文来评估交易替换的想法—即矿工在尝试完成工作量证明时会创建并承诺的拟议区块。通过评估替换对下一块模板的影响，矿工能够无需启发式方法就确定替换是否能为其带来更多手续费收入。多位开发者对 Zhao 的总结与提案进行了回复，并提出了额外或替代的修改建议。

  截至撰写本文时，讨论仍在进行中。

## Bitcoin Core PR 审查俱乐部

*在此月度栏目中，我们总结最近一次 [Bitcoin Core PR Review Club][] 会议的要点，并列出部分重要问答。点击下方任意问题可查看会议答案概要。*

[添加用法示例][reviews 748]是 Elichai Turkel 的一个拉取请求，用于为 ECDSA 签名、schnorr 签名以及 ECDH 密钥交换添加用法示例。这是审查俱乐部首次讨论 libsecp256k1 的拉取请求。与会者讨论了高质量随机源的重要性，逐步走查示例代码，并就 libsecp256k1 的一般性问题进行交流。

{% include functions/details-list.md
  q0="<!--q0-->为什么示例代码要展示如何获取随机数？"
  a0="本库中许多密码学方案的安全性依赖于密钥、随机数（nonce）与盐值保持秘密/随机。如果攻击者能够猜测或影响我们的随机数源返回的值，他们就可能伪造签名、获知我们试图保密的信息、猜出密钥等。因此，实现密码学方案的难点往往在于获取随机数。用法示例正是为了突显这一事实。"
  a0link="https://bitcoincore.reviews/libsecp256k1-748#l-99"

  q1="<!--q1-->为用户推荐获取随机数的方法是否合适？"
  a1="libsecp256k1 的主要用户 Bitcoin Core 有自己的随机数算法，综合了操作系统、P2P 网络接收的消息以及其他熵源。对于必须“自备熵源”的其他用户来说，推荐可能会有所帮助，因为可靠的随机数源至关重要，而操作系统文档并不总是清晰。确实存在维护成本，因为推荐可能会随着操作系统支持变化或漏洞披露而过时，但预计这一成本很小，因为相关 API 更新极不频繁。"
  a1link="https://bitcoincore.reviews/libsecp256k1-748#l-120"

  q2="<!--q2-->能否直接跟随 PR 中新增的示例？是否缺少任何内容？"
  a2="与会者分享了编译和运行示例、使用调试器、将示例代码与 Bitcoin Core 用法对比、并为非比特币用户考虑用户体验的经历。
一位与会者指出，在生成 schnorr 签名后未进行验证与 Bitcoin Core 代码及 [BIP340][] 的建议不符。另一位与会者建议在 `secp256k1_ecdsa_sign` 之前演示 `secp256k1_sha256` 的使用，因为忘记对消息进行哈希可能成为潜在的用户陷阱。"
  a2link="https://bitcoincore.reviews/libsecp256k1-748#l-193"

  q3="<!--q3-->如果用户忘记执行诸如签后验证、调用 `seckey_verify` 或随机化上下文等操作，会发生什么？"
  a3="在最坏情况下，如果实现存在缺陷，签名后忘记验证可能导致意外生成无效签名。随机生成密钥后忘记调用 `seckey_verify` 意味着存在（极小的）概率生成无效密钥。随机化上下文旨在防御侧信道攻击——它会对中间值进行盲化，这些中间值不会影响最终结果，但可能被利用以获取操作信息。"
  a3link="https://bitcoincore.reviews/libsecp256k1-748#l-226"
%}

## 发布与候选发布

*面向流行比特币基础设施项目的新版本发布与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [LND 0.14.2-beta][LND 0.14.2-beta]是一次维护版本更新，包含若干漏洞修复及少量改进。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]中的值得注意的变更。*

- [Bitcoin Core #23508][Bitcoin Core #23508] 将软分叉部署状态信息从 `getblockchaininfo` 移至新的 `getdeploymentinfo` RPC，同时支持按特定区块高度查询部署状态，而非仅限链尖。
- [Bitcoin Core #21851][Bitcoin Core #21851] 为 arm64-apple-darwin（Apple M1） 平台添加构建支持。随着变更合并，社区可在下一个版本中期待可用的 M1 二进制文件。
- [Bitcoin Core #16795][Bitcoin Core #16795] 更新 `getrawtransaction`、`gettxout`、`decoderawtransaction` 与 `decodescript` RPC，使其在解码任意 scriptPubKey 时返回推断出的[输出脚本描述符][topic descriptors]。
- [LND #6226][LND #6226] 将通过遗留 `SendPayment`、`SendPaymentSync` 与 `QueryRoutes` RPC 创建的 LN 路由支付默认手续费设为 5%。使用新版 `SendPaymentV2` RPC 发送的支付默认手续费为 0%，基本上要求用户显式指定。另一合并的拉取请求 [LND #6234][LND #6234] 将通过遗留 RPC 发送且金额低于 1,000 satoshi 的支付默认手续费设为 100%。
- [LND #6177][LND #6177] 允许 [HTLC][topic HTLC] 拦截器的使用者指定 HTLC 失败的原因，使拦截器在测试 LND 上层软件处理失败情形时更加实用。
- [LDK #1227][LDK #1227] 改进路由查找逻辑，纳入已知的历史支付失败/成功信息。这些信息用于推断通道余额的上限与下限，从而在评估路由时为路由查找逻辑提供更准确的成功概率。这实现了 René Pickhardt 等人在之前多期 Newsletter（包括 [#142][news142 pps]、[#163][news163 pickhardt richter paper] 与 [#172][news172 cl4771]）中提到的部分想法。
- [HWI #549][HWI #549] 添加对 [PSBT][topic psbt] 版本 2 的支持（见 [BIP370][]）。当使用仅原生支持 v0 PSBT 的设备（如现有 Coldcard 硬件签名设备）时，v2 PSBT 会被转换为 v0 PSBT。
- [HWI #544][] 为 Trezor 硬件签名设备添加接收与支出 [taproot][topic taproot] 付款的支持。


{% include references.md %}
{% include linkers/issues.md v=1 issues="23508,21851,16795,6226,6234,6177,1227,549,544" %}
[lnd 0.14.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.14.2-beta
[zhao rbf]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019817.html
[news163 pickhardt richter paper]: /zh/newsletters/2021/08/25/#zero-base-fee-ln-discussion
[news142 pps]: /zh/newsletters/2021/03/31/#paper-on-probabilistic-path-selection
[news172 cl4771]: /zh/newsletters/2021/10/27/#c-lightning-4771
[reviews 748]: https://bitcoincore.reviews/libsecp256k1-748
