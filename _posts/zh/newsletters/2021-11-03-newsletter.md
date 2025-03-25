---
title: 'Bitcoin Optech Newsletter #173'
permalink: /zh/newsletters/2021/11/03/
name: 2021-11-03-newsletter-zh
slug: 2021-11-03-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周 Newsletter 总结了有关直接向矿工提交交易的讨论，提供了钱包实现应参考的 taproot 测试向量集，并包含我们关于准备 taproot、新版本发布与候选版本、以及热门比特币基础设施项目值得注意的变更的常规板块。

## 新闻

- ​**<!--submitting-transactions-directly-to-miners-->**​**向矿工直接提交交易：​**
  Lisa Neigut 在 Bitcoin-Dev 邮件列表中发起[讨论][neigut relay]，探讨是否废除 P2P 交易中继网络并让用户直接向矿工提交交易。提议的潜在优势包括降低带宽需求、提升隐私性、简化[替换手续费（RBF）][topic rbf]和[子为父付费（CPFP）][topic cpfp]的规则复杂性，以及改善下一区块手续费率的沟通机制。然而，多位参与者提出异议：

  - ​​**<!--bandwidth-requirements-->****带宽需求：​** 多个回复指出，自 2016 年起使用的[致密区块中继][topic compact block relay]协议，已使得节点在区块中包含未确认交易时无需重复接收该交易，且带宽开销极低。未来升级方案如[Erlay][topic erlay]将进一步降低未确认交易中继的带宽消耗。

  - ​**<!--improved-privacy-->**​**隐私提升：​** 尽管仅向矿工提交交易可在交易确认前隐藏其公开可见性，但 Pieter Wuille [指出][wuille relay]，这也赋予矿工特权化的网络视角。公众透明性似乎更为可取。

  - ​**<!--rbf-cpfp-and-package-complexity-->**​**RBF、CPFP 及规则复杂性：​** 节点运营商确实比矿工更关注资源浪费型攻击，但 Gloria Zhao [强调][zhao relay]，这更多是程度问题。大规模的同类型攻击仍会影响矿工，因此矿工仍需采取与节点类似的防御措施。

  - ​**<!--feerate-communication-->**​**手续费率沟通：​** Bitcoin Core 当前手续费率估算基于观察未确认交易的确认时长。此方法虽滞后于实时费率信息，但 Pieter Wuille [建议][wuille relay]，可通过[弱区块][topic weak blocks]广播等已有提案改进。弱区块验证门槛低于有效工作量证明区块，能更及时反映矿工当前处理的交易。

  此外，现有系统的优势也得到强调：

  - ​**<!--miner-anonymity-->**​**矿工匿名性：​** ZmnSCPxj [指出][zmnscpxj relay]，当前网络中超过 5 万个节点均可传播交易，矿工仅需匿名运行一个节点即可获取所需信息。若强制要求矿工维持持久身份（即便使用 Tor 等匿名网络），将更容易被识别并胁迫实施交易审查。

  - ​**<!--censorship-resistance-->**​**抗审查性：​** Pieter Wuille [强调][wuille relay]，现有系统允许用户自由搭建节点连接矿机开始挖矿。而转向直接提交交易需要新矿工主动公开节点接收交易，这可能面临审查与[女巫攻击][sybil attacks]难题。

  - ​​**<!--centralization-resistance-->****去中心化维持：​** Wuille 指出，直接提交模式下提交交易的成本与各矿工算力无关，但收益与算力正相关。这将导致钱包倾向仅向少数大型矿池提交交易，加剧中心化。

- ​**<!--taproot-test-vectors-->** ​**Taproot 测试向量集：​**
  Pieter Wuille 向 Bitcoin-Dev 邮件列表[发布][wuille test]其提议加入 [BIP341][][taproot][topic taproot] 规范的[测试向量][bips #1225]。这些向量重点关注“钱包实现，涵盖从密钥/脚本计算默克尔根/调整量/脚本公钥、密钥路径支出的签名消息/签名哈希/签名计算，以及脚本路径支出的控制区块计算”。

  对于希望在[激活后][p4tr waiting]尽快支持 taproot 的开发者，这些测试向量尤为有用。

## 准备 Taproot #20：激活时会发生什么？

*关于开发者和服务提供商如何为即将在区块高度 {{site.trb}} 激活的 taproot 做准备的[系列][series preparing for taproot]周更。*

{% include specials/taproot/zh/20-activation.md %}

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选版本。请考虑升级至新版本或协助测试候选版本。*

- [Bitcoin Core 0.20.2][] 是 Bitcoin Core 前分支的维护版本，[包含][bcc0.20.2 rn]次要功能更新与漏洞修复。

- [C-Lightning 0.10.2rc2][] 是候选版本，[包含][decker tweet]对[不经济输出漏洞][news170 unec bug]的修复、优化数据库体积及提升 `pay` 命令效率（详见下文*重大变更*章节）。

## 值得注意的代码和文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]的显著变更。*

- [Bitcoin Core #23306][] 支持地址管理器为单个 IP 配置多端口。Bitcoin Core 历来固定使用 8333 端口并优先连接该端口地址。此举不仅有助于防止利用比特币节点实施对非比特币服务的 DoS 攻击，也为未来实现更统一的地址处理奠定基础。

- [C-Lightning #4837][] 新增 `--max-dust-htlc-exposure-msat` 配置选项，限制待处理 HTLC 中低于粉尘限额的总额。详见我们[早前][news162 mdhemsat]对 Rust-Lightning 同类选项的报道。

- [Eclair #1982][] 引入新的日志文件记录需操作员干预的重要通知。配套说明指出应监控 `notifications.log` 文件。

- [LND #5803][] 允许向同一[原子多路径支付（AMP）][topic multipath payments]发票发起多次[自发支付][topic spontaneous payments]，无需支付方重复操作。该功能为 AMP 独有，现有[简化多路径支付][topic multipath payments]实现无法支持。

- [BTCPay Server #2897][] 新增支持 [LNURL-Pay][] 支付方式，同时支持[闪电地址][news167 lightning addresses]。

{% include references.md %}
{% include linkers/issues.md issues="23306,4837,1982,5803,2897,1225" %}
[c-lightning 0.10.2rc2]: https://github.com/ElementsProject/lightning/releases/tag/v0.10.2rc2
[neigut relay]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-October/019572.html
[wuille relay]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-October/019578.html
[zhao relay]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-October/019579.html
[zmnscpxj relay]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-October/019573.html
[sybil attacks]: https://en.wikipedia.org/wiki/Sybil_attack
[decker tweet]: https://twitter.com/Snyke/status/1452260691939938312
[news170 unec bug]: /zh/newsletters/2021/10/13/#ln-spend-to-fees-cve
[bitcoin core 0.20.2]: https://bitcoincore.org/bin/bitcoin-core-0.20.2/
[bcc0.20.2 rn]: https://bitcoincore.org/en/releases/0.20.2/
[wuille test]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-November/019587.html
[p4tr waiting]: /zh/preparing-for-taproot/#我们为什么要等待
[LNURL-Pay]: https://github.com/fiatjaf/lnurl-rfc/blob/luds/06.md
[news167 lightning addresses]: /zh/newsletters/2021/09/22/#lightning-address-identifiers-announced
[news162 mdhemsat]: /zh/newsletters/2021/08/18/#rust-lightning-1009
[series preparing for taproot]: /zh/preparing-for-taproot/
