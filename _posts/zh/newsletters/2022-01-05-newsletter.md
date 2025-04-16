---
title: 'Bitcoin Optech Newsletter #181'
permalink: /zh/newsletters/2022/01/05/
name: 2022-01-05-newsletter-zh
slug: 2022-01-05-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周 Newsletter 描述了一项逐步实施全量手续费替换（RBF）的替代提案，并宣布将召开系列会议评审拟议的 `OP_CHECKTEMPLATEVERIFY` 软分叉。还包括我们的常规栏目：新版本发布公告、候选版本发布以及热门比特币基础设施项目的重大变更摘要。


## 新闻

- ​**​<!--brief-full-rbf-then-opt-in-rbf-->​**​**​先全量 RBF 后选择性 RBF：​**​ Jeremy Rubin [回复][rubin rbf]了早期 Bitcoin-Dev 邮件列表中关于在 Bitcoin Core 中启用全量 [RBF][topic rbf] 的讨论（详见 [Newsletter #154][news154 rbf]）。当前，任何符合 [BIP125][] 信号的交易都可被更高费率交易替换（存在部分限制）。先前提案建议最终允许替换任何交易（"全量 RBF"）——而不仅限于设置了选择性替换信号的交易。部分商家表示希望中继节点尽可能提高替换难度（至少可选），以便他们能继续接受未确认交易来兑换低成本商品服务。

  Rubin 的替代方案仍鼓励转向全量 RBF，但建议分阶段实施：节点首次收到交易后的 *n* 秒内允许全量 RBF，*n* 秒后则维持现有的 BIP125 选择性信号机制。这使得商家在 *n* 秒后仍可按现有模式接受未确认交易。更重要的是，依赖可替换性保障安全的协议将无需担心非选择性信号交易——只要协议节点或瞭望塔能在首次知晓交易后的 *n* 秒内及时响应。

- ​**​<!--bip119-ctv-review-workshops-->​**​**​BIP119 CTV 评审研讨会：​**​ Jeremy Rubin 在 Bitcoin-Dev 邮件列表[宣布][rubin ctv-review]，将主持系列会议讨论 [BIP119][] 的 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] 规范及其网络部署方案。首次会议将于 UTC 时间 1 月 11 日 20:00 在 Libera.Chat 的 [##ctv-bip-review][] 频道举行，此后每两周同一时间持续召开。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选版本。请考虑升级至新版本或协助测试候选版本。*

- [Rust-Lightning 0.0.104][] 是该 LN 节点库的最新版本，包含多项 API 改进。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]的重大变更。*

- [Bitcoin Core #23789][] 确保新创建的找零输出始终匹配目标地址类型，同时优先创建 [P2TR][topic taproot] 找零。该拉取请求解决了早期 Taproot 采用者的找零输出易被识别的[隐私问题][tr output linking]。

- [Bitcoin Core #23711][] 新增了 Bitcoin Core 关于未确认交易接收与中继的*策略*文档。该文档对需要依赖交易接收和中继行为的钱包及合约协议开发者尤其有用。

- [Bitcoin Core #17631][] 新增提供[致密区块过滤器][topic compact block filters]的 REST 端点（需节点启用过滤器和 REST 功能）。

- [Bitcoin Core #22674][] 新增交易包验证逻辑，可针对节点中继策略进行测试。交易包指一个子交易及其所有未确认父交易。后续拉取请求预计将扩展验证逻辑以支持 [CPFP][topic cpfp] 和 [RBF][topic rbf]。

  未来的拉取请求可能新增允许节点提交交易包至本地节点的功能，使用现有验证逻辑实现[包中继][topic package relay]，从而增强闪电网络等合约协议的可靠性与安全性。该拉取请求还新增了[文档][package doc]说明包验证规则。

[package doc]: https://github.com/glozow/bitcoin/blob/046e8ff264be6b888c0f9a9d822e32aa74e19b78/doc/policy/packages.md

- [Bitcoin Core #23718][] 新增支持在 [PSBT][topic psbt] 中保留并展示哈希值及其原像。用于 [HTLC][topic htlc] 或其他合约协议的 PSBT 可能包含需要原像才能生成最终交易的哈希值。此变更使 Bitcoin Core 能更有效地参与此类交易的创建与管理，未来若支持 [miniscript][topic miniscript] 将进一步提升功能。

- [Bitcoin Core #17034][] 新增支持 PSBT v2（参见 [Newsletter #128][news128 psbt]）及更多 PSBT 字段，包括 [Newsletter #72][news72 psbt] 描述的专有扩展字段。Bitcoin Core 虽不解析专有扩展，但会保留处理过的 PSBT 中的这些字段，并在 `decodepsbt` RPC 结果中展示。

- [Bitcoin Core #23113][] 更新 `createmultisig` 和 `addmultisig` RPC，当用户请求使用[非压缩公钥][uncompressed public key]创建隔离见证多签地址时返回警告字段。自隔离见证实施以来，Bitcoin Core 默认不中继或打包含非压缩公钥的隔离见证输入交易，因此使用非压缩密钥创建地址可能导致资金无法花费。这些 RPC 始终不为非压缩密钥创建 [bech32][topic bech32] 地址，而是生成传统（base58check）地址。新增警告字段可帮助用户理解地址类型差异的原因。

- [Bitcoin Core GUI #459][] 在地址生成对话框中新增创建 bech32m 地址的功能。

  {:.center}
  ![地址选择器截图](/img/posts/2022-01-core-gui-address-picker.png)

- [Eclair #2090][] 通过 `max-per-peer-per-second` 配置项新增对[洋葱消息][topic onion messages]的速率限制支持。

- [Eclair #2104][] 新增当日均可花费链上余额低于使用 [CPFP 费用追加][topic cpfp]配合[锚定输出][topic anchor outputs]及时关闭通道所需预估金额时的预警日志。闪电网络开发者或自设储备金的操作者可参考该预估与 LND 的[相关][news113 lnd4908] [实现][news149 lnd5274]。

- [Eclair #2099][] 新增 `onion-messages` 配置项，可选值包括：不中继[洋葱消息][topic onion messages]（仍允许收发）、中继所有消息（包括需新建连接的情况）、仅通过现有连接中继。

- [Libsecp256k1 #964][] 制定了 libsecp256k1 库的发布流程与版本管理方案。

- [Rust Bitcoin #681][] 新增对 [BIP371][] [PSBT][topic psbt] [taproot][topic taproot] 扩展字段的支持。

- [Rust-Lightning #1177][] 移除了 Rust-Lightning 存储收款信息的需求，改为将关键支付信息加密后编码至[支付密钥][topic payment secrets]。收款时解密支付密钥，使用明文信息推导出满足 [payment hash][] 的[支付原像][payment preimage]，保障 [HTLC][topic htlc] 支付安全。

  该方案是 [Newsletter #168][news168 stateless] 所述无状态收款理念的简化实现。其他闪电网络实现可能存储发票信息（如商户系统提供的订单 ID），而作为库的 Rust-Lightning 通过与上层应用深度集成，将支付请求管理交由应用处理。

- [HWI #545][]、[#546][HWI #546] 和 [#547][HWI #547] 新增对 [taproot][topic taproot] 的支持，包括启用 `tr()` [描述符][topic descriptors]、支持 BIP371 taproot [PSBT][topic psbt] 字段，以及在硬件设备支持时启用 taproot 脚本的 [bech32m][topic bech32] 地址。需注意当前 HWI 对部分支持 taproot 的硬件固件尚未完全兼容。

- [BIPs #1126][] 新增关于*光学工作量证明（OPoW）*的 [BIP52][]，该硬分叉提案旨在调整矿机资本支出与电力运维支出的成本比例。该方案曾于 Bitcoin-Dev 邮件列表[讨论][opow ml]，存在支持与反对意见。

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
