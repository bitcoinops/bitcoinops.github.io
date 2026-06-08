---
title: 'Bitcoin Optech 周报 #405'
permalink: /zh/newsletters/2026/05/15/
name: 2026-05-15-newsletter-zh
slug: 2026-05-15-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报披露了一项负责任公开的漏洞：拥有足够工作量证明的攻击者可能利用它使 Bitcoin Core 节点崩溃；此外还介绍了一项通过 P2P 网络共享 UTXO 集的 BIP 草案提案。此外还包括我们的常规栏目：新候选版本的公告，以及流行比特币基础设施软件的重大变更介绍。

## 新闻

- **<!--bitcoin-core-script-interpreter-remote-crash-disclosure-->****Bitcoin Core 脚本解释器远程崩溃漏洞披露：** Niklas Gögge 在 Bitcoin-Dev 邮件列表上[发帖][topic cve mailing list]，披露了 [CVE-2024-52911][topic cve disclosure]。该漏洞影响 0.14.0 之后、29.0 之前的 Bitcoin Core 版本。在 0.14.0 版本（2017 年 3 月发布）之后，验证一个特制的区块可能导致节点访问此前已释放的内存。在验证过程中，用于检查交易输入的数据会被缓存。该 bug 源于并行脚本验证期间对象生命周期的顺序问题：缓存的预计算交易数据可能在后台脚本检查线程完成之前就被释放。对于特制的无效区块，这些数据可能在后台线程仍访问它们时就被销毁。

  拥有足够工作量证明的攻击者可以利用这种特制的无效区块使受害者节点崩溃。由于 use-after-free 这类 bug 的特性，理论上也有可能在受害者节点上执行远程代码，但考虑到需要精心构造区块才能做到这一点，实际发起这种攻击的可能性很低。

  该漏洞由 Cory Fields 发现并进行了[负责任披露][topic responsible disclosures]，他还提供了概念验证和建议的缓解措施。该问题已在 Bitcoin Core 29.0 中修复。

- **<!--bip-proposal-for-utxo-set-sharing-over-p2p-network-->****通过 P2P 网络共享 UTXO 集的 BIP 提案：** Fabian Jahr 在 Bitcoin-Dev 邮件列表上[发帖][p2p share ml]，介绍了一份关于通过 P2P 层共享 UTXO 集的 [BIP 草案][BIPs #2137]。该提案的目标是改进 [assumeUTXO][topic assumeutxo] 功能，为新节点提供一种直接从对等节点而非外部来源接收 UTXO 集的方法。具体来说，该提案定义了 P2P 协议的一项扩展，引入了一个新的服务位、四条新的 P2P 消息，以及一个由请求节点已知的 UTXO 集默克尔根，用于验证收到的 UTXO 集是否正确。

  该提案收到了一些反馈。Antoine Riard 提议在当前草案基础上构建 [BIP434][] 所定义的对等节点特性协商机制（见[周报 #386][news386 feat negot]），并提出了关于恶意对等节点转发格式错误 UTXO 集的若干顾虑。Eric Voskuil 则提醒作者注意此类 BIP 的长期风险，因为它可能导致新的提案出现，让矿工对 UTXO 状态作出承诺。Voskuil 认为，这将削弱比特币的安全模型，使新节点转而信任矿工，而不是从创世区块开始验证整条链。

## 版本发布和候选版本

_热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。_

- [Core Lightning 26.06rc1][] 是这个流行闪电网络节点下一个主要版本的候选发布，包含新的 `graceful`、`sendamount` 和 `xkeysend` RPC，开始弃用 `pay` 并转向 `xpay`，同时增加了对 BOLT12 payer-proof RPC 的支持。

## 重大代码和文档变更

_以下是来自 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案 (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期重大变更。_

- [Bitcoin Core #35209][] 现在会在 `CCheckQueueControl` 对象之前构造 `txsdata` 向量，从而解决了 [CVE-2024-52911][topic cve disclosure]（见上文新闻部分）的根本原因。由于 C++ 会按与构造顺序相反的次序销毁局部对象，这可确保脚本检查队列在排队的 `CScriptCheck` 对象所引用的预计算交易数据被销毁前完成处理。这样就能防止验证过程中的提前返回路径导致后台脚本检查线程访问已释放的内存。此前，这一漏洞已通过对提前返回行为的隐蔽修复在 Bitcoin Core 29.0 中被修复（见[周报 #333][news333 fix]）。

- [BIPs #2116][] 发布了 [BIP323][]，提议将 `nVersion` 中供矿工使用的 nonce 空间从 16 位扩展到 24 位，以取代 [BIP320][]。它将第 5 到第 28 位保留给只知区块头的挖矿（header-only mining），从而无需每秒多次滚动 `nTime`。先前讨论见[周报 #395][news395 nversion]。

- [BIPs #2141][] 和 [BIPs #2155][] 修订并扩展了 [BIP322][]。该提案最初于 2018 年提出一种[通用签名消息格式][topic generic signmessage]。此次更新回应了长期存在的开放问题和反馈，补全了所提议的资金证明构造，并添加了一种基于 PSBT 的签名流程。修订版对先前规范作出了破坏性变更，包括给签名增加一个新的可读前缀，以及修改资金证明的签名格式。随着该 BIP 被推进到 Complete 状态并正式向整个生态系统提出以供采纳，还增加了一个基于 btcd 的更完整参考实现和额外测试向量。

- [Core Lightning #9116][] 为 [BOLT12][topic offers] payer proof 添加了实验性支持，实现了 [BOLTs #1295][] 的最新草案提案。Payer proof 是一种 BOLT12 收据格式，允许[付款人证明][topic proof of payment]自己使用支付原像、出票节点的签名以及来自 `invreq_payer_id` 的付款人签名支付了一张发票，同时允许为了隐私省略若干选定的发票字段。该 PR 增加了创建和验证 payer proof 的通用例程，更新了 `bolt12-cli`，并添加了一个实验性的 `createproof` RPC。该格式仍属实验性，未来可能会变动。

- [Core Lightning #9110][] 弃用了 `pay`、`paystatus`、`keysend`、`getroute`、`renepay` 和 `renepaystatus` RPC，从 26.06 版本开始弃用，并计划在 27.03 版本中移除。`xpay` RPC（见[周报 #330][news330 xpay]）现在可处理大多数 pay 调用，同时还新增了 `xkeysend` RPC 来维持 [keysend][topic spontaneous payments] 功能。该 PR 还为 `xpay` 扩展了 `label` 和 `localinvreqid` 参数、CLTV shadow routing、对重复支付的更佳处理，以及对 `channel_update` 错误的处理。它还更新了 `getroutes`，使其返回更清晰的逐跳金额、节点和 CLTV 字段，并更新了 `sendpay` 以接受使用这些字段的路由。

- [LDK #4598][] 更新了 `OutputSweeper`，确保即使某次进行中的 sweep 尝试在完成前被取消，其 `pending_sweep` 标志也会被清除。该标志用于防止并发的 sweep 尝试；但如果在 sweep 被取消后该标志仍保持为已设置状态，后续尝试就会被错误跳过，从而可能导致对时间敏感的 [HTLC][topic htlc] 输出在节点重启前都无法被认领。现在该 PR 使用一个守卫对象来清除该标志，使其在正常返回、出错或取消时都会执行。

- [LDK #4528][] 将 BOLT11 `payment_metadata`（见[周报 #182][news182 metadata]）承诺到入站支付的 HMAC 中。当发票包含 metadata 时，LDK 现在要求最终洋葱载荷在接受支付前返回相同的 metadata，从而防止发送方修改或省略它。此外，发票构造器现在默认要求提供 payment metadata，但用户可以通过 `optional_payment_metadata()` 选择退出，以兼容不支持该特性的发送方。

- [LND #10612][] 为[洋葱消息][topic onion messages]增加了基于图的路径查找功能，建立在更早的转发支持之上（见[周报 #396][news396 onion]）。现在 LND 可以通过那些使用特性位 38/39 广告洋葱消息支持的节点，找到前往目标节点的路由。由于洋葱消息不是支付，该搜索不会考虑流动性或手续费。

- [BTCPay Server #7354][] 修复了一个热钱包密钥暴露问题。该问题是在 [BTCPay Server #7329][] 添加细粒度钱包权限之后引入的。拥有钱包签名权限但无权查看钱包种子或修改商店设置的用户，可能会在 [PSBT][topic psbt] 签名过程中接触到派生出的热钱包私钥。该 PR 引入了一个 `HotwalletSafe` 辅助器，以集中管理热钱包访问；将签名权限与查看种子材料的权限分离；并更新签名流程，改为在服务端使用热钱包，而不是通过 HTTP 表单字段返回私有签名密钥。

- [BDK #2195][] 修复了从 Electrum 服务器同步时的一个问题：当交易的第一个输出没有被索引（例如是一个 `OP_RETURN` 输出）时，同步会失败。此前，`BdkElectrumClient::populate_with_txids` 会使用第一个输出的脚本来查询确认历史，这可能返回空历史记录。现在 BDK 会改用第一个被索引的输出脚本；如果没有任何输出被索引，则回退到某个输入的前序输出脚本。

- [Bitcoin Inquisition #100][] 实现了 [BIP446][] 的 `OP_TEMPLATEHASH` 操作码，用于在 [signet][topic signet] 上测试所提议的共识变更。`OP_TEMPLATEHASH` 是一个 [tapscript][topic tapscript] 操作码，会将花费交易的哈希推入栈中（见[周报 #397][news397 templatehash]）。该 PR 还增加了一套广泛的测试框架。

- [BINANAs #20][] 将 BIN-2026-0002 分配给未来 Bitcoin Inquisition 对 [BIP443][] 的 [OP_CHECKCONTRACTVERIFY][topic matt]（OP_CCV）操作码的实现。关于这一提议中的[限制条款][topic covenants]的先前讨论，见[周报 #348][news348 op_ccv]和[#356][news356 op_ccv]。

{% include snippets/recap-ad.md when="2026-05-19 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2137,20,100,1295,2116,2141,2155,2195,4528,4598,7329,7354,9110,9116,10612,35209" %}
[topic cve mailing list]: https://groups.google.com/g/bitcoindev/c/e1UEdViSYkU
[topic cve disclosure]: https://bitcoincore.org/en/2026/05/05/disclose-cve-2024-52911/
[Core Lightning 26.06rc1]: https://github.com/ElementsProject/lightning/releases/tag/v26.06rc1
[news333 fix]: /zh/newsletters/2024/12/13/#bitcoin-core-31112
[news330 xpay]: /zh/newsletters/2024/11/22/#core-lightning-7799
[news182 metadata]: /zh/newsletters/2022/01/12/#bolts-912
[news396 onion]: /zh/newsletters/2026/03/13/#lnd-10089
[news395 nversion]: /zh/newsletters/2026/03/06/#draft-bip-for-expanded-nversion-nonce-space-for-miners
[news397 templatehash]: /zh/newsletters/2026/03/20/#bips-1974
[news348 op_ccv]: /zh/newsletters/2025/04/04/#op-checkcontractverify-semantics
[news356 op_ccv]: /zh/newsletters/2025/05/30/#bips-1793
[p2p share ml]: https://groups.google.com/g/bitcoindev/c/rThmyI8ZN3Q
[news386 feat negot]: /zh/newsletters/2026/01/02/#peer-feature-negotiation
