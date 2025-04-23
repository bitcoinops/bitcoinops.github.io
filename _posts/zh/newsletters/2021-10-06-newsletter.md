---
title: 'Bitcoin Optech Newsletter #169'
permalink: /zh/newsletters/2021/10/06/
name: 2021-10-06-newsletter-zh
slug: 2021-10-06-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本期周报总结了比特币添加交易继承标识符的提案，并包含常规章节：关于为 taproot 做准备的进展、新版本与候选版本信息，以及主流比特币基础设施软件的显著变更摘要。

## 新闻

- ​**<!--proposal-for-transaction-heritage-identifiers-->**​**交易继承标识符提案：​**​
  匿名开发者 John Law 向 Bitcoin-Dev 和 Lightning-Dev 邮件列表提交了一篇[帖子][rubin-law iids]，提议通过软分叉添加*继承标识符（IID）*。该标识符允许引用交易输入的祖先交易 txid 及其输出位置。例如 `0123...cdef:0:1` 表示当前交易输入正在花费 txid `0123...cdef` 第一个输出的第二个子项。这使得多方协议参与者无需预先知晓生成特定输出的交易 txid，即可创建该输出的消费签名。

  该方案与拟议的 [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] 软分叉实现的*浮动交易*方案形成对比。[eltoo][topic eltoo] 协议描述的浮动交易允许参与者在满足输出脚本条件的前提下，无需知晓 txid 即可创建签名。

  Law 在一份长达 66 页的[论文][law iids]中描述了 IID 实现的四种协议，包括替代 eltoo 和[通道工厂][topic channel factories]的方案，以及简化[瞭望塔][topic watchtowers]设计的思路。Anthony Towns [建议][towns iids] IID 的功能可通过 anyprevout 模拟实现，但 Law [反驳][law nosim]了该模拟可能性。

  由于部分参与者不愿使用邮件列表，讨论进展受阻。若后续讨论恢复，我们将在未来周报中总结重要更新。

## 准备 Taproot #16：输出关联

*本系列文章每周更新，帮助开发者和服务提供商为即将在区块高度 {{site.trb}} 激活的 taproot 做准备。[系列入口][series preparing for taproot]*

{% include specials/taproot/zh/15-output-linking.md %}

## 发布与候选发布

*主流比特币基础设施项目的新版本与候选版本。建议升级至新版本或协助测试候选版本。*

- [LND 0.13.3-beta][] 是修复资金丢失漏洞 [CVE-2021-41593][] 的安全版本。发布说明还包含无法立即升级节点的缓解措施建议。

## 显著代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]的显著变更。*

- [Bitcoin Core GUI #416][] 新增「启用 RPC 服务器」复选框，允许用户开关 Bitcoin Core 的 RPC 服务器（需重启生效）。

  {:.center}
  ![启用 RPC 服务器配置选项的截图](/img/posts/2021-10-gui-rpc-server.png)

- [Bitcoin Core #20591][] 修改钱包时间计算逻辑，在重新扫描历史区块时仅使用区块时间戳。使用 `rescanblockchain` RPC 手动触发重扫描的用户和应用将不再看到交易被错误标记为扫描时间而非确认时间，消除了常见的混淆来源。

- [Bitcoin Core #22722][] 更新 `estimatesmartfee` RPC，使其仅返回高于配置值与动态最低交易转发手续费的费率。例如若估算值为 1 sat/vbyte、配置值为 2 sat/vbyte、动态最低值升至 3 sat/vbyte，则返回 3 sat/vbyte。

- [Bitcoin Core #17526][] 新增[单次随机抽取][srd review club]（SRD）算法作为第三种[币选择][topic coin selection]策略。钱包现会从分支定界（BnB）、背包算法和 SRD 算法中获取结果，并采用此前描述的[浪费启发式][news165 waste]选择最优方案。

  基于约 8,000 笔支付的模拟显示，SRD 算法的加入使总手续费降低 6%，无找零交易比例从 5.4% 提升至 9.0%。无找零输出可降低交易重量与手续费、减少 UTXO 池规模、节省后续花费成本，并提升隐私性。

- [Bitcoin Core #23061][] 修复 `-persistmempool` 配置项，此前无参数时（默认启用）关闭节点不会持久化内存池。现使用该选项即可持久化（默认仍保持启用状态）。

- [Bitcoin Core #23065][] 实现钱包 UTXO 锁的持久化存储。通过 `lockunspent` RPC 的 `persistent` 参数可将锁定偏好保存至磁盘，GUI 也会自动持久化用户选择的锁定。该功能可用于防止[低价值垃圾输出][topic output linking]的消费，或避免损害隐私的输出使用。

- [C-Lightning #4806][] 新增节点费率设置变更后 10 分钟的默认延迟执行机制。这确保新费率在网络传播后再拒绝不符合新费率的支付。

- [Eclair #1900][] 与 [Rust-Lightning #1065][] 实现 [BOLTs #894][]，强制要求承诺交易仅使用隔离见证输出。该限制使得闪电网络程序可采用更低的[粉尘限制][topic uneconomical outputs]（在低费率时减少通道强制关闭的矿工费损失）。

- [LND #5699][] 新增可删除支付记录的 `deletepayments` 命令。默认仅允许删除失败的支付，成功支付需额外标志才可删除。

- [LND #5366][] 初步支持 PostgreSQL 作为数据库后端。相比现有 bbolt 后端，PostgreSQL 支持多服务器复制、实时数据库压缩、处理更大数据集，并提供更细粒度的锁模型以改善 I/O 锁争用。

- [Rust Bitcoin #563][] 新增对 [P2TR][topic taproot] 输出 [bech32m][topic bech32] 地址的支持。

- [Rust Bitcoin #644][] 新增对 [tapscript][topic tapscript] 新操作码 `OP_CHECKMULTISIGADD` 和 `OP_SUCCESSx` 的支持。

- [BDK #376][] 新增对 sqlite 数据库后端的支持。

{% include references.md %}
{% include linkers/issues.md issues="416,20591,22722,17526,23061,23065,4806,1900,1065,894,5699,5366,563,644,376" %}
[news165 waste]: /zh/newsletters/2021/09/08/#bitcoin-core-22009
[srd review club]: https://bitcoincore.reviews/17526
[rubin-law iids]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-September/019470.html
[law iids]: https://github.com/JohnLaw2/btc-iids/raw/main/iids14.pdf
[towns iids]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-September/019471.html
[law nosim]: https://github.com/JohnLaw2/btc-iids/blob/main/response_to_towns_20210918_113740.txt
[CVE-2021-41593]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-October/003257.html
[lnd 0.13.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.13.3-beta
[series preparing for taproot]: /zh/preparing-for-taproot/
