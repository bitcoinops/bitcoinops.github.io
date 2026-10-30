---
title: 'Bitcoin Optech Newsletter #181'
permalink: /zh/newsletters/2022/01/05/
name: 2022-01-05-newsletter-zh
slug: 2022-01-05-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周 Newsletter 描述了一项逐步引入全量手续费替换（RBF）的替代提案，并宣布将召开系列会议评审拟议的 `OP_CHECKTEMPLATEVERIFY` 软分叉。还包括我们的常规栏目：新版本与候选版本发布，以及热门比特币基础设施项目的值得注意的变更摘要。


## 新闻

- ​**​<!--brief-full-rbf-then-opt-in-rbf-->​**​**​先短暂全量 RBF，再自愿启用 RBF：​**​ Jeremy Rubin [回复][rubin rbf]了早期 Bitcoin-Dev 邮件列表中关于在 Bitcoin Core 中启用全量 [RBF][topic rbf] 的讨论（详见 [Newsletter #154][news154 rbf]）。当前，任何按 [BIP125][] 发出信号的交易都可以被费率更高的替代交易替换（存在一些限制）。先前的提案建议最终允许替换任何交易（“全量 RBF”）——而不仅仅是那些设置了自愿启用信号、表示希望可被替换的交易。一些商家表示，他们希望中继节点把可替换性尽可能地变难（至少应提供这样的选项），这样他们就能立即接受未确认交易，以换取低成本的商品和服务。

  Rubin 的替代方案仍鼓励转向全量 RBF，但建议分阶段实施：节点首次收到一笔交易后的 *n* 秒内，允许对该交易做全量 RBF；*n* 秒之后，BIP125 的自愿启用标志与现在一样生效。这样，商家在 *n* 秒过去之后仍能像现在一样接受未确认交易。更重要的是，只要协议节点或瞭望塔能在首次得知某笔交易后 *n* 秒的几分之一时间内作出响应，那些依靠可替换性来保障安全的协议就不必再担心非自愿启用的交易。

- ​**​<!--bip119-ctv-review-workshops-->​**​**​BIP119 CTV 评审工作坊：​**​ Jeremy Rubin 在 Bitcoin-Dev 邮件列表[宣布][rubin ctv-review]，他将主持一系列定期会议，讨论 [BIP119][] 中 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] 的规范，包括它可以在网络上如何部署。首次会议将于 1 月 11 日（周二）UTC 时间 20:00 在 Libera.Chat 的 [##ctv-bip-review][] 频道举行。此后每两周在同一时间无限期举行。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [Rust-Lightning 0.0.104][] 是该 LN 节点库的最新版本，包含多项 API 改进。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo] 的值得注意的变更。*

- [Bitcoin Core #23789][] 让新创建的找零输出始终匹配目标地址的输出类型，同时在可能时仍优先创建 [P2TR][topic taproot] 找零。这个 PR 针对的是一个[隐私问题][tr output linking]：早期采用 taproot 的用户在向传统地址付款时，其找零输出很容易被识别出来。

- [Bitcoin Core #23711][] 记录了 Bitcoin Core 在接收和中继未确认交易方面*策略*的若干方面。对于需要依赖接收和中继行为的钱包和合约协议作者来说，这份文档可能特别有用。

- [Bitcoin Core #17631][] 新增提供[紧凑区块过滤器][topic compact block filters]的 REST 端点（需节点启用过滤器和 REST 功能）。

- [Bitcoin Core #22674][] 新增交易包验证逻辑，可针对节点中继策略进行测试。交易包指一个子交易及其所有未确认父交易。后续拉取请求预计将扩展验证逻辑以支持[子为父付（CPFP）][topic cpfp] 和 [RBF][topic rbf]。

  未来的某个后续 PR 可能会新增一种方法，允许对等节点向本地节点提交交易包，并用现在已有的逻辑进行验证。这将实现[交易包中继][topic package relay]，增强 LN 等合约协议的可靠性和安全性。该 PR 还新增了[文档][package doc]说明交易包验证规则。

[package doc]: https://github.com/glozow/bitcoin/blob/046e8ff264be6b888c0f9a9d822e32aa74e19b78/doc/policy/packages.md

- [Bitcoin Core #23718][] 新增支持保留并展示 [PSBT][topic psbt] 中包含的哈希和原像。用于 [HTLC][topic htlc] 或其他合约协议基本构件的 PSBT 可能包含某个哈希，而该哈希的原像为 PSBT 的某位*更新者*或*签名者*所知。为了生成所需的最终交易，可能需要提供这个原像。这个 PR 让 Bitcoin Core 更接近于能够有效参与这类交易的创建、管理和最终确定。如果 Bitcoin Core 采纳对 [miniscript][topic miniscript] 的支持，预计还会有更多改进。

- [Bitcoin Core #17034][] 新增支持版本 2 的 PSBT（见 [Newsletter #128][news128 psbt]）以及更多 PSBT 字段，包括 [Newsletter #72][news72 psbt] 中描述的专有 PSBT 扩展字段。Bitcoin Core 并不理解这些专有扩展，但今后会在它处理的 PSBT 中保留它们，并在 `decodepsbt` RPC 的结果中展示。

- [Bitcoin Core #23113][] 更新 `createmultisig` 和 `addmultisig` RPC，当用户请求使用[非压缩公钥][uncompressed public key]创建隔离见证多重签名地址时返回警告字段。自 segwit 最初实现以来，Bitcoin Core 默认既不中继也不打包那些花费带非压缩公钥的 segwit 输入的未确认交易，因此任何用非压缩密钥创建地址的用户都可能无法花费发往该地址的资金。正因如此，这些 RPC 从不为非压缩密钥创建 [bech32][topic bech32] 地址——它们改为创建传统（base58check）地址。新增的警告字段应当能帮助这类用户理解，为什么自己得到的地址类型与请求的不一样。

- [Bitcoin Core GUI #459][] 更新地址生成对话框，使其除原有地址类型之外还能创建 bech32m 地址。

  {:.center}
  ![地址选择器截图](/img/posts/2022-01-core-gui-address-picker.png)

- [Eclair #2090][] 通过 `max-per-peer-per-second` 配置项新增对[洋葱消息][topic onion messages]的速率限制支持。

- [Eclair #2104][] 新增一条日志消息：当本地节点当前可在链上立即花费的余额低于预估金额时，就向节点运营者发出警告——这笔预估金额是使用 [CPFP 手续费追加][topic cpfp]配合[锚定输出][topic anchor outputs]及时关闭通道所必需的。自行选择储备金取值的 LN 开发者或运营者，不妨把 Eclair 给出的估算与 LND [中][news113 lnd4908] [所用][news149 lnd5274]的估算做个比较。

- [Eclair #2099][] 新增 `onion-messages` 配置项，可选值包括：不中继[洋葱消息][topic onion messages]（仍允许收发）、中继所有消息（包括需新建连接的情况）、仅通过现有连接中继。

- [Libsecp256k1 #964][] 制定了 libsecp256k1 库的发布流程与版本管理方案。

- [Rust Bitcoin #681][] 新增对 [BIP371][] [PSBT][topic psbt] [taproot][topic taproot] 扩展字段的支持。

- [Rust-Lightning #1177][] 让 Rust-Lightning 自身不再需要存储上层钱包应用想要接收的支付信息，而是把关于支付的关键信息加密后编码进[支付密钥][topic payment secrets]。收到支付时，解密后的支付密钥中的明文信息被用来推导出[支付原像][payment preimage]，用以满足保护该笔支付 [HTLC][topic htlc] 的 [payment hash][]。

  这是对 [Newsletter #168][news168 stateless] 中所描述想法的一个简化实现。其他 LN 实现可能会存储发票相关信息（例如商户记账软件提供的一个任意订单标识符），而 Rust-Lightning 绕开了这一点：它作为一个库，期望被直接集成到一个上层应用中，因此把支付请求细节的管理交给上层应用。

- [HWI #545][]、[#546][HWI #546] 和 [#547][HWI #547] 新增对 [taproot][topic taproot] 的支持，具体包括启用对 `tr()` [描述符][topic descriptors]的支持、支持 [BIP371][] 的 taproot [PSBT][topic psbt] 字段，以及在底层硬件签名设备支持时支持 taproot 脚本的 [bech32m][topic bech32] 地址。请注意，就这些 PR 而言，对于某些确实支持 taproot 的签名设备固件，HWI 尚未完全支持，因此这些设备上还未启用 taproot 支持。

- [BIPs #1126][] 新增了关于*光学工作量证明*（OPoW）的 [BIP52][]，这是一项拟议的比特币硬分叉变更，据称它会改变矿机（资本支出）与电力及运营成本（运营支出）之间的成本划分。这一想法此前在 Bitcoin-Dev 邮件列表上[讨论][opow ml]过，既有支持者也有反对者。

{% include references.md %}
{% include linkers/issues.md issues="23789,23711,17631,22674,23718,17034,23113,459,2090,2104,2099,964,681,1177,545,546,547,1126,912" %}
[opow ml]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-May/018951.html
[##ctv-bip-review]: https://web.libera.chat/?channels=##ctv-bip-review
[rust-lightning 0.0.104]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.104
[rubin rbf]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-December/019696.html
[rubin ctv-review]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-December/019719.html
[news154 rbf]: /zh/newsletters/2021/06/23/#allowing-transaction-replacement-by-default
[news128 psbt]: /zh/newsletters/2020/12/16/#new-psbt-version-proposed
[news72 psbt]: /zh/newsletters/2019/11/13/#bips-849
[tr output linking]: /zh/preparing-for-taproot/#输出关联
[uncompressed public key]: https://btcinformation.org/en/developer-guide#public-key-formats
[payment preimage]: https://github.com/lightning/bolts/blob/master/00-introduction.md#payment-preimage
[payment hash]: https://github.com/lightning/bolts/blob/master/00-introduction.md#Payment-hash
[news168 stateless]: /zh/newsletters/2021/09/29/#stateless-ln-invoice-generation
[news113 lnd4908]: /zh/newsletters/2021/01/27/#lnd-4908
[news149 lnd5274]: /zh/newsletters/2021/05/19/#lnd-5274
