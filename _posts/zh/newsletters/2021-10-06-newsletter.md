---
title: 'Bitcoin Optech Newsletter #169'
permalink: /zh/newsletters/2021/10/06/
name: 2021-10-06-newsletter-zh
slug: 2021-10-06-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本期 Newsletter 总结了为比特币添加交易继承标识符的提案，并包含常规章节：关于为 taproot 做准备的信息、新版本与候选发布列表，以及主流比特币基础设施软件的值得注意的变更摘要。

## 新闻

- **<!--proposal-for-transaction-heritage-identifiers-->****交易继承标识符提案：**
  化名开发者 John Law 撰写的一篇[帖子][rubin-law iids]被提交到 Bitcoin-Dev 与 Lightning-Dev 邮件列表。Law 提议通过软分叉添加*继承标识符（IID）*，使人们可以引用某笔交易祖先的 txid，以及通向当前输入的那些输出的位置。例如 `0123...cdef:0:1` 表示当前交易输入花费的是 txid `0123...cdef` 第一个输出所衍生的第二个子交易。这使得多方协议的参与者即便无法预先知道将创建某个输出的交易的 txid，也能创建花费该输出的签名。

  可与拟议的 [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] 软分叉所实现、并作为 [eltoo][topic eltoo] 协议一部分描述的*浮动交易*方案相比较。浮动交易允许参与者为某个特定输出创建签名而无需知道其 txid，只要他们在其他方面满足该输出脚本中的条件。

  Law 在一份[篇幅很长的论文][law iids]中描述了 IID 能够实现的四种不同协议，包括 eltoo 和[通道工厂][topic channel factories]的替代方案，以及可以简化[瞭望塔][topic watchtowers]设计的想法。Anthony Towns [提出][towns iids] IID 的功能可以用 anyprevout 来模拟，而这仍将是一项新颖的进展，不过 Law 对能否模拟[持不同意见][law nosim]。

  由于并非所有参与者都愿意使用邮件列表，对这些想法的讨论变得复杂。如果邮件列表上的讨论恢复，我们会在将来的 Newsletter 中总结值得注意的进展。

## 准备 Taproot #16：输出关联

*本[系列][series preparing for taproot]每周一篇，讨论开发者和服务提供商如何为 taproot 即将在区块高度 {{site.trb}} 激活做好准备。*

{% include specials/taproot/zh/15-output-linking.md %}

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [LND 0.13.3-beta][] 是修复资金丢失漏洞 [CVE-2021-41593][] 的安全版本。发布说明还包含无法立即升级节点的缓解措施建议。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]的值得注意的变更。*

- [Bitcoin Core GUI #416][] 新增“启用 RPC 服务器”复选框，允许用户开启或关闭 Bitcoin Core 的 RPC 服务器（需重启生效）。

  {:.center}
  ![启用 RPC 服务器配置选项的截图](/img/posts/2021-10-gui-rpc-server.png)

- [Bitcoin Core #20591][] 修改钱包的时间计算逻辑，在重新扫描历史区块中与该钱包相关的交易时仅使用区块时间戳。使用 `rescanblockchain` RPC 手动触发重扫描的用户和应用，将不再看到交易被错误地标记为扫描时间而非确认时间，从而消除了一个偶发的混淆与挫败来源。

- [Bitcoin Core #22722][] 更新 `estimatesmartfee` RPC，使其只返回同时高于配置的最低交易中继手续费与动态最低交易中继手续费的费率。例如，若估算器算出 1 sat/vbyte 的费率、配置值为 2 sat/vbyte、动态最低值已升至 3 sat/vbyte，则返回 3 sat/vbyte。

- [Bitcoin Core #17526][] 新增[单次随机抽取][srd review club]（SRD）算法，作为第三种[选币][topic coin selection]策略。钱包现在会分别从分支定界（BnB）、背包算法和 SRD 算法取得选币结果，再用我们此前描述过的[浪费启发式][news165 waste]，从这三份结果中挑出成本效益最高的一份来为交易提供资金。

  在基于约 8,000 笔支付的模拟中，PR 作者发现加入 SRD 算法后总手续费降低了 6%，无找零交易的比例从 5.4% 上升到 9.0%。不创建找零输出可以降低交易的重量与手续费、缩小钱包的 UTXO 池、省去日后花费该找零输出的成本，并且被认为能改善钱包的隐私。

- [Bitcoin Core #23061][] 修复了 `-persistmempool` 配置项：此前在不带参数时（要真正持久化，得传入 `-persistmempool=1`），关闭节点时不会把内存池持久化到磁盘。现在只写这个选项本身就能持久化内存池（它仍是默认行为，因此本来也不需要显式传入）。

- [Bitcoin Core #23065][] 让钱包的 UTXO 锁定可以持久化到磁盘。Bitcoin Core 钱包允许用户锁定一个或多个 UTXO，以免它们在自动创建的交易中被使用。`lockunspent` RPC 现在包含 `persistent` 参数，可将该偏好保存到磁盘；GUI 也会自动把用户选择的锁定持久化。持久化锁的一个用途是防止花费[低价值的垃圾输出][topic output linking]，或防止花费其他可能损害用户隐私的输出。

- [C-Lightning #4806][] 在用户更改节点费率设置与强制执行新设置之间，新增了 10 分钟的默认延迟。这样，节点关于新费率的公告可以先在网络中传播开，之后才会出现因未按最近上调的费率付费而被拒绝的支付。

- [Eclair #1900][] 与 [Rust-Lightning #1065][] 实现了 [BOLTs #894][]，该规范收紧了 LN 协议，只允许在承诺交易中使用隔离见证输出。实施这一限制后，LN 程序可以采用更低的[粉尘限制][topic uneconomical outputs]，从而在费率较低时减少通道强制关闭过程中可能损失给矿工的资金。

- [LND #5699][] 新增 `deletepayments` 命令，可用于删除支付尝试记录。默认情况下只能删除失败的支付尝试；出于安全考虑，要删除成功的支付尝试必须额外传入一个标志。

- [LND #5366][] 初步支持使用 PostgreSQL 作为数据库后端。与现有的 bbolt 后端相比，PostgreSQL 可以跨多台服务器复制、即时进行数据库压缩、处理更大的数据集，并提供更细粒度的锁模型，可能缓解 I/O 锁争用。

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
