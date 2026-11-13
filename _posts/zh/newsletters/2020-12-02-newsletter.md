---
title: 'Bitcoin Optech Newsletter #126'
permalink: /zh/newsletters/2020/12/02/
name: 2020-12-02-newsletter-zh
slug: 2020-12-02-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 介绍了一项在闪电网络（LN）上使用忠诚债券（fidelity bonds）来防止拒绝服务攻击的提案，总结了一个解决手续费盗窃攻击的拉取请求，该攻击可能影响使用锚定输出的 LN 通道；此外还链接到一份 miniscript 的提议规范。文中还包括我们常规的发布与候选发布栏目，以及热门比特币基础设施软件中近期代码变更的栏目。

## 行动项

*本周无。*

## 新闻

- **<!--fidelity-bonds-for-ln-routing-->****用于 LN 路由的忠诚债券：** Gleb Naumenko 和 Antoine Riard 在 Lightning-Dev 邮件列表中[发表了][gnar post]一项提案，建议使用*质押证书*（即忠诚债券的另一种称呼）来防止一种[首次在 2015 年描述的][russell loop]通道堵塞攻击。这类攻击中，恶意用户通过一系列通道向自己或同伙发送支付，然后延迟接受或拒绝该支付。在支付最终超时之前，用于路由这笔支付的每个通道都无法再把这些资金用于路由其他用户的支付。由于一条路由可能穿过十多个通道，这意味着攻击者每控制一个比特币，就能让属于诚实节点的十多个比特币无法用于诚实的路由。

  此前针对该问题（以及相关问题）提出的解决方案，大多涉及预付手续费，可参见 Newsletter [#72][news72 upfront]、[#86][news86 upfront]、[#119][news119 upfront]、[#120][news120 upfront] 和 [#122][news122 upfront]。本周，Naumenko 和 Riard 提议让每笔支付都带上一个证明，证明其付款方控制着一定数量的比特币。每个路由节点随后可以公开宣布自己的政策：在见到一定权益价值的证明时，愿意路由多少价值。例如，Alice 的节点可以宣布，对于任何能证明自己控制至少 1.00 BTC 的人，它愿意为其路由最高 0.01 BTC 的支付。这样，别人可以经由 Alice 的节点路由支付，但能占用她多少资金是有限制的。

  邮件列表帖子也明确指出，实现这一想法还需要做大量工作，包括开发一种保护隐私的密码学证明。截至本文撰写时，该想法的讨论仍在进行中。

- **<!--proposed-intermediate-solution-for-ln-sighash-single-fee-theft-->****针对 LN `SIGHASH_SINGLE` 手续费盗窃的中间方案提议：** 如 [Newsletter #115][news115 siphoning] 中所述，LN 规范最近的一次更新（尚未广泛部署）使得攻击者有可能窃取原本分配给 LN 支付（HTLC）链上手续费的那部分比特币。这是因为花费 HTLC 时所用的签名采用了 [sighash 标志][sighash flag] `SIGHASH_SINGLE|SIGHASH_ANYONECANPAY`。

  针对该问题的首选解决方案是根本不在 HTLC 中放入任何手续费，从而消除窃取手续费的可能，并由想要领取 HTLC 的一方负责支付所需的任何手续费。然而，这需要对 LN 规范再作一处修改，而该修改需得到所有[锚定输出][topic anchor outputs]实现的采纳。在此之前，Johan Halseth 本周在 Lightning-Dev 邮件列表中[发布了][halseth post]一个针对 LND 的[拉取请求][LND #4795]：只有当对方从这笔支付（以及此前已接受的所有待处理支付）中可窃取的最大手续费金额低于*通道储备金*时，才会接受该支付。通道储备金是通道每一侧都必须保留的最低金额，以便在旧状态被广播时用作罚金。这并未完全消除问题，但确实显著限制了可能的最大损失。缺点是，价值较少的通道（因而储备金也较少）将只能同时转发少量 HTLC。Halseth 的拉取请求试图通过不请求将费率提高到 10 sat/vbyte 以上来缓解这个问题，从而让 HTLC 手续费保持较低，使多个 HTLC 的手续费合计不太可能超过储备金。

- **<!--formal-specification-of-miniscript-->****miniscript 的正式规范：** Dmitry Petukhov [发布了][petukhov post]一份基于其他开发者所写文档的 [miniscript][topic miniscript] [正式规范][miniscript spec]。这有助于测试实现，或在未来扩展 miniscript。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [HWI 1.2.1][] 是一个维护版本，可兼容较新版本的 Ledger 固件，并改进了与 BitBox02 的兼容性。
- [Rust-Lightning 0.0.12][] 是一个更新了多个 API 的版本，使其更易于使用，并新增了“测试版状态”的 C/C++ 绑定（参见 [Newsletter #115][news115 rl bindings]）。
- [Bitcoin Core 0.21.0rc2][Bitcoin Core 0.21.0] 是该全节点实现及其配套钱包等软件的下一个主要版本的候选发布。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中值得注意的变更。*

- [LND #4752][] 防止节点在没有[支付秘密][payment secret]的情况下释放本地的支付原像，该支付秘密位于一个透传支付无法使用的字段中。此补丁需要在 LND 生成的发票中加入支付秘密。支付秘密是作为[多路径支付][topic multipath payments]的一部分引入的，强制要求它可为透传支付提供额外保护，防止[不当的原像泄露][CVE-2020-26896]，如 [Newsletter #121][news121 preimage] 和 [#122][news122 preimage] 中所述。

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
