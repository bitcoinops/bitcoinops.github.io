---
title: 'Bitcoin Optech Newsletter #126'
permalink: /zh/newsletters/2020/12/02/
name: 2020-12-02-newsletter-zh
slug: 2020-12-02-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了一个关于在闪电网络（LN）中使用保证债券来防止拒绝服务攻击的提案，总结了一个解决可能影响使用锚定输出的 LN 通道的手续费盗窃攻击的拉取请求，并链接到一个关于 miniscript 的提议规范。此外，还包括我们常规的发布、候选发布以及流行比特币基础设施软件中最近代码更改的部分。

## 行动项

*本周无。*

## 新闻

- **<!--fidelity-bonds-for-ln-routing-->****闪电网络路由的保证债券：** Gleb Naumenko 和 Antoine Riard 在 Lightning-Dev 邮件列表中[发表了][gnar post]一项提案，建议使用*权益证明证书*（即保证债券的另一种称呼）来防止一种[首次在 2015 年描述的][russell loop]通道阻塞攻击。这类攻击中，恶意用户通过一系列通道向自己或同伙发送支付，然后延迟接受或拒绝支付。在支付最终超时之前，用于路由支付的每个通道都无法将这些资金用于路由其他用户的支付。由于一条路由可能穿过十多个通道，这意味着攻击者控制的每一个比特币可以阻止十多个比特币（属于诚实节点）的正常路由。

  之前针对该问题（及相关问题）提出的解决方案主要涉及预付手续费，可参见 Newsletter [#72][news72 upfront]、[#86][news86 upfront]、[#119][news119 upfront]、[#120][news120 upfront] 和 [#122][news122 upfront]。本周，Naumenko 和 Riard 提议让每笔支付包括一个证明其支付者控制一定数量比特币的证据。每个路由节点可以公开宣布其政策，例如 Alice 的节点可以宣布，它将为任何能证明其控制至少 1.00 BTC 的用户路由最多 0.01 BTC 的支付。这将允许他人通过 Alice 的节点进行支付，但限制他们能够占用的资金量。

  邮件中提到，实施该想法需要进行大量工作，包括开发隐私保护的加密证明。截至撰写时，该想法的讨论仍在进行中。

- **<!--proposed-intermediate-solution-for-ln-sighash-single-fee-theft-->****针对 LN `SIGHASH_SINGLE` 手续费盗窃的中间解决方案提议：** 如 [Newsletter #115][news115 siphoning] 中描述，LN 规范最近的一次更新（尚未广泛部署）可能使攻击者能够窃取分配给 LN 支付（HTLCs）链上手续费的一部分。这是由于使用 [sighash 标志][sighash flag] `SIGHASH_SINGLE|SIGHASH_ANYONECANPAY` 签名消费 HTLCs 所造成的。

  针对该问题的首选解决方案是根本不在 HTLCs 中包括任何手续费，从而消除窃取手续费的可能性，并让希望领取 HTLC 的一方负责支付任何必要的手续费。然而，这需要对 LN 规范进行额外更改，并被所有[锚定输出][topic anchor outputs]实现所采纳。在此之前，Johan Halseth 本周在 Lightning-Dev 邮件列表中[发布了][halseth post]一个针对 LND 的[拉取请求][LND #4795]，仅在对方可窃取的最大手续费总额（包括所有先前已接受的待处理支付）低于*通道储备金*时才接受支付。通道储备金是为了防止旧状态被广播而在每个通道的一侧保留的最低金额。这并未完全消除问题，但确实显著限制了可能的最大损失。缺点是，价值较小的通道（因此储备金较少）将被限制同时转发少量 HTLC。Halseth 的拉取请求试图通过不请求超过 10 sat/vbyte 的费率增加来缓解这一问题，从而保持 HTLC 手续费较低，使得多个 HTLC 的手续费总额不太可能超过储备金。

- **<!--formal-specification-of-miniscript-->****miniscript 的正式规范：** Dmitry Petukhov [发布了][petukhov post]一份基于其他开发者文档的 [miniscript][topic miniscript] [正式规范][miniscript spec]。这有助于测试实现或未来扩展 miniscript。

## 发布与候选发布

*流行比特币基础设施项目的新版本和候选发布。请考虑升级到新版本或协助测试候选版本。*

- [HWI 1.2.1][] 是一个维护版本，提供对最新 Ledger 固件版本的兼容性，并改进了对 BitBox02 的兼容性。
- [Rust-Lightning 0.0.12][] 是一个更新了多个 API 的版本，使其更易于使用，并新增了“测试版状态”的 C/C++ 绑定（参见 [Newsletter #115][news115 rl bindings]）。
- [Bitcoin Core 0.21.0rc2][Bitcoin Core 0.21.0] 是该全节点实现及其相关钱包和其他软件下一个主要版本的候选发布。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo] 中的值得注意的更改。*

- [LND #4752][] 防止节点在没有[支付秘密][payment secret] 的情况下释放本地支付 preimage。支付秘密包含在不可用于透传支付的字段中。该补丁需要在 LND 生成的发票中添加支付秘密。支付秘密是[多路径支付][topic multipath payments]的一部分，要求其能够为透传支付提供额外的保护，防止[不当的 preimage 揭露][CVE-2020-26896]，如 [Newsletter #121][news121 preimage] 和 [#122][news122 preimage] 中所述。

{% include references.md %}
{% include linkers/issues.md issues="4752,4795" %}
[hwi 1.2.1]: https://github.com/bitcoin-core/HWI/releases/tag/1.2.1
[rust-lightning 0.0.12]: https://github.com/rust-bitcoin/rust-lightning/releases/tag/v0.0.12
[bitcoin core 0.21.0]: https://bitcoincore.org/bin/bitcoin-core-0.21.0/
[gnar post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-November/002884.html
[russell loop]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2015-August/000135.html
[news115 siphoning]: /zh/newsletters/2020/09/16/#stealing-onchain-fees-from-ln-htlcs
[sighash flag]: https://btcinformation.org/en/developer-guide#signature-hash-types
[halseth post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-November/002882.html
[petukhov post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-November/018281.html
[miniscript spec]: https://github.com/dgpv/miniscript-alloy-spec
[news115 rl bindings]: /zh/newsletters/2020/09/16/#rust-lightning-618
[news72 upfront]: /zh/newsletters/2019/11/13/#ln-up-front-payments
[news86 upfront]: /zh/newsletters/2020/02/26/#reverse-up-front-payments
[news119 upfront]: /zh/newsletters/2020/10/14/#ln-upfront-payments
[news120 upfront]: /zh/newsletters/2020/10/21/#more-ln-upfront-fees-discussion
[news122 upfront]: /zh/newsletters/2020/11/04/#bi-directional-upfront-fees-for-ln
[CVE-2020-26896]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-26896
[news121 preimage]: /zh/newsletters/2020/10/28/#cve-2020-26896-improper-preimage-revelation
[news122 preimage]: /zh/newsletters/2020/11/04/#c-lightning-4162
[payment secret]: https://github.com/lightningnetwork/lightning-rfc/commit/5776d2a7
