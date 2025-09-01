---
title: 'Bitcoin Optech Newsletter #366'
permalink: /zh/newsletters/2025/08/08/
name: 2025-08-08-newsletter-zh
slug: 2025-08-08-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报公布了 Utreexo 的草案 BIP，总结了关于降低最低交易中继费率的持续讨论，并描述了一个允许节点共享其区块模板以缓解不同交易池策略问题的提案。此外还包括我们的常规部分：总结了 Bitcoin Core PR 审核俱乐部会议、新版本和候选版本的公告，以及对热门比特币基础设施项目的重大变更介绍。我们还包括了对上周周报的更正和对读者的推荐。

## 新闻

- **<!--draft-bips-proposed-for-utreexo-->****为 Utreexo 提出的草案 BIP：** Calvin Kim 在 Bitcoin-Dev 邮件列表上[发布][kim bips]了他与 Tadge Dryja 和 Davidson Souza 共同撰写的关于 [Utreexo][topic utreexo] 验证模型的三个草案 BIP。[第一个 BIP][ubip1] 指定了 Utreexo 累加器的结构，它允许节点在“仅几千字节”的空间内存储对完整 UTXO 集的易于更新的承诺。[第二个 BIP][ubip2] 指定了全节点如何使用累加器而不是传统的已花费交易输出集（STXO，在早期 Bitcoin Core 和当前 libbitcoin 中使用）或未花费交易输出集（UTXO，在当前 Bitcoin Core 中使用）来验证新区块和交易。[第三个 BIP][ubip3] 指定了对比特币 P2P 协议的更改，以允许传输 Utreexo 验证所需的额外数据。

  作者正在寻求概念性审核，并将根据进一步的发展更新草案 BIP。

- **<!--continued-discussion-about-lowering-the-minimum-relay-feerate-->关于降低最低中继费率的持续讨论：** Gloria Zhao 在 Delving Bitcoin 上[发布][zhao minfee]了关于将[默认最低中继费率][topic default minimum transaction relay feerates]降低 90% 至 0.1 sat/vbyte 的讨论。她鼓励就这个想法以及它可能如何影响其他软件进行概念性讨论。对于 Bitcoin Core 的具体关注，她链接到了一个 [PR][bitcoin core #33106]。

- **<!--peer-block-template-sharing-to-mitigate-problems-with-divergent-mempool-policies-->对等节点区块模板共享以缓解不同交易池策略的问题：** Anthony Towns 在 Delving Bitcoin 上[发布][towns tempshare]建议全节点对等节点偶尔使用[致密区块中继][topic compact block relay]编码向彼此发送其下一个区块的最新模板。接收对等节点随后可以请求模板中缺失的任何交易，要么将它们添加到本地交易池，要么将它们存储在缓存中。这将允许具有不同交易池策略的对等节点尽管存在差异仍能共享交易。它为之前建议使用_弱区块_的提案提供了替代方案（参见[周报 #299][news299 weak blocks]）。Towns 发布了一个[概念验证实现][towns tempshare poc]。

## Bitcoin Core PR 审核俱乐部

*在这个月度栏目中，我们总结了最近的 [Bitcoin Core PR 审核俱乐部][Bitcoin Core PR Review Club]会议，重点介绍了一些重要的问题和答案。点击下面的问题可以看到会议中答案的总结。*

[添加 exportwatchonlywallet RPC 以导出钱包的仅观察版本][review club 32489]是 [achow101][gh achow101] 的一个 PR，它减少了创建仅观察钱包所需的手动工作量。在此更改之前，用户必须通过输入或脚本化 `importdescriptors` RPC 调用、复制地址标签等来完成此操作。

除了公共[描述符][topic descriptors]外，导出还包含：
- 必要时包含派生 xpub 的缓存，例如在强化派生路径的情况下
- 地址簿条目、钱包标志和用户标签
- 所有历史钱包交易，因此无需重新扫描

然后可以使用 `restorewallet` RPC 导入导出的钱包数据库。

{% include functions/details-list.md
  q0="<!--why-can-t-the-existing-isrange-issingletype-information-tell-us-whether-a-descriptor-can-be-expanded-on-the-watch-only-side-explain-the-logic-behind-canselfexpand-for-a-a-hardened-wpkh-xpub-0h-path-and-b-a-pkh-pubkey-descriptor-->为什么现有的 `IsRange()`/`IsSingleType()` 信息不能告诉我们描述符是否可以在仅观察端扩展？解释 `CanSelfExpand()` 对于 a）强化 `wpkh(xpub/0h/*)` 路径和 b）`pkh(pubkey)` 描述符的逻辑。"
  a0="`IsRange()` 和 `IsSingleType()` 不足够，因为它们不检查强化派生，这需要仅观察钱包中不可用的私钥。添加了 `CanSelfExpand()` 来递归搜索强化路径；如果找到一个，它返回 `false`，表示必须为仅观察钱包导出预填充的缓存以派生地址。`pkh(pubkey)` 描述符不带有范围且没有派生，因此它总是可以自扩展。"
  a0link="https://bitcoincore.reviews/32489#l-27"

  q1="<!--exportwatchonlywallet-only-copies-the-descriptor-cache-if-desc-canselfexpand-what-exactly-is-stored-in-that-cache-how-could-an-incomplete-cache-affect-address-derivation-on-the-watch-only-wallet-->`ExportWatchOnlyWallet` 只有在 `!desc->CanSelfExpand()` 时才复制描述符缓存。该缓存中确切存储了什么？不完整的缓存如何影响仅观察钱包上的地址派生？"
  a1="缓存存储具有强化派生路径的描述符的 `CExtPubKey` 对象，这些对象在支出钱包上预派生。如果此缓存不完整，仅观察钱包无法派生缺失的地址，因为它缺乏必要的私钥。这将导致它无法看到发送到这些地址的交易，从而导致余额不正确。"
  a1link="https://bitcoincore.reviews/32489#l-52"

  q2="<!--the-exporter-sets-create-flags-getwalletflags-wallet-flag-disable-private-keys-why-is-it-important-to-preserve-the-original-flags-e-g-avoid-reuse-instead-of-clearing-everything-and-starting-fresh-->导出器设置 `create_flags = GetWalletFlags() | WALLET_FLAG_DISABLE_PRIVATE_KEYS`。为什么要保留原始标志（例如 `AVOID_REUSE`）而不是清除所有内容并重新开始？"
  a2="保留标志确保支出钱包和仅观察钱包之间的行为一致性。例如，`AVOID_REUSE` 标志影响哪些币被认为可用于支出。不保留它会导致仅观察钱包报告与主钱包不同的可用余额，从而导致用户困惑。"
  a2link="https://bitcoincore.reviews/32489#l-68"

  q3="<!--why-does-the-exporter-read-the-locator-from-the-source-wallet-and-write-it-verbatim-into-the-new-wallet-instead-of-letting-the-new-wallet-start-from-block-0-->为什么导出器从源钱包读取定位器并将其逐字写入新钱包，而不是让新钱包从区块 0 开始？"
  a3="复制区块定位器是为了告诉新的仅观察钱包从哪里恢复扫描区块链以寻找新交易，防止需要完整重新扫描。"
  a3link="https://bitcoincore.reviews/32489#l-93"

  q4="<!--consider-a-multisig-descriptor-wsh-multi-2-xpub1-xpub2-if-one-cosigner-exports-a-watch-only-wallet-and-shares-it-with-a-third-party-what-new-information-does-that-third-party-learn-compared-to-just-giving-them-the-descriptor-strings-->考虑多重签名描述符 `wsh(multi(2,xpub1,xpub2))`。如果一个共同签名者导出仅观察钱包并与第三方共享，与仅给他们描述符字符串相比，该第三方学到了什么新信息？"
  a4="仅观察钱包数据包括额外的元数据，如地址簿、钱包标志和币控制标签。对于具有强化派生的钱包，第三方只能通过仅观察钱包导出获得有关历史和未来交易的信息。"
  a4link="https://bitcoincore.reviews/32489#l-100"

  q5="<!--in-wallet-exported-watchonly-py-why-does-the-test-call-wallet-keypoolrefill-100-before-checking-spendability-across-the-online-offline-pair-->在 `wallet_exported_watchonly.py` 中，为什么测试在检查在线/离线对之间的可支出性之前调用 `wallet.keypoolrefill(100)`？"
  a5="`keypoolrefill(100)` 调用强制离线（支出）钱包为其强化描述符预派生 100 个密钥，填充其缓存。然后将此缓存包含在导出中，允许在线仅观察钱包生成这 100 个地址。它还确保离线钱包在收到要签名的 PSBT 时会识别这些地址。"
  a5link="https://bitcoincore.reviews/32489#l-122"
%}


## Optech 推荐

[Bitcoin++ Insider][] 已开始发布由读者资助的关于比特币技术主题的新闻。他们的两个免费周报，_Last Week in Bitcoin_ 和 _This Week in Bitcoin Core_，对 Optech 周报的常规读者可能特别有趣。

## 新版本和候选版本

*热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [LND v0.19.3-beta.rc1][] 是这个热门闪电网络节点实现的维护版本的候选版本，包含“重要的错误修复”。最值得注意的是，“一个可选的迁移[...]显著降低了节点的磁盘和内存需求。”

- [BTCPay Server 2.2.0][] 是这个热门自托管支付解决方案的发布版本。它添加了对钱包策略和 [miniscript][topic miniscript] 的支持，提供了对交易费用管理和监控的额外支持，并包括其他几个新改进和错误修复。

- [Bitcoin Core 29.1rc1][] 是主流全节点软件维护版本的候选版本。

## 重大的代码和文档变更

*本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals（BIPs）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Bitcoin Core #32941][] 通过在超出限制时启用孤儿池的自动修剪，完成了对 `TxOrphanage` 的全面改革（参见[周报 #364][news364 orphan]）。它为 `maxorphantx` 用户添加了警告，告知他们该选项已过时。此 PR 巩固了机会性一父一子（1p1c）[包中继][topic package relay]。

- [Bitcoin Core #31385][] 放宽了 `submitpackage` RPC 的 `package-not-child-with-unconfirmed-parents` 规则，以改进 1p1c [包中继][topic package relay]的使用。包不再需要包含已在节点交易池中的父交易。

- [Bitcoin Core #31244][] 实现了 [BIP390][] 中定义的 [MuSig2][topic musig] [描述符][topic descriptors]的解析，这是从具有 MuSig2 聚合密钥的 [taproot][topic taproot] 地址接收和支出输入所必需的。

- [Bitcoin Core #30635][] 开始在帮助命令响应中显示 `waitfornewblock`、`waitforblock` 和 `waitforblockheight` RPC，表明它们是为普通用户设计的。此 PR 还向 `waitfornewblock` RPC 添加了一个可选的 `current_tip` 参数，通过指定当前链尖端的区块哈希来缓解竞争条件。

- [Bitcoin Core #28944][] 通过在未指定时添加偏移量为随机小数值的[锁定时间][topic timelocks]，为使用 `send` 和 `sendall` RPC 命令发送的交易添加了反[费用狙击][topic fee sniping]保护。

- [Eclair #3133][] 将其 [HTLC 背书][topic htlc endorsement]本地对等节点声誉系统（参见[周报 #363][news363 reputation]）扩展到对传出对等节点进行评分，就像对传入对等节点一样。Eclair 现在在转发 HTLC 时会考虑双向的良好声誉，但尚未实施惩罚。对传出对等节点进行评分对于防止沉没攻击（参见[周报 #322][news322 sink]）是必要的，这是一种特定类型的[通道阻塞攻击][topic channel jamming attacks]。

- [LND #10097][] 为积压的[gossip][topic channel announcements]请求（`GossipTimestampRange`）引入了异步的、每个对等节点的队列，以消除对等节点一次发送太多请求时的死锁风险。如果对等节点在前一个请求完成之前发送请求，额外的消息会被静默丢弃。添加了新的 `gossip.filter-concurrency` 设置（默认为 5）来限制所有对等节点的并发工作者数量。PR 还添加了解释所有流言速率限制配置设置如何工作的文档。

- [LND #9625][] 添加了 `deletecanceledinvoice` RPC 命令（及其 `lncli` 等效命令），允许用户通过提供支付哈希来删除已取消的 [BOLT11][] 发票（参见[周报 #33][news33 canceled]）。

- [Rust Bitcoin #4730][] 为[最终警报][final alert]消息添加了 `Alert` 类型包装器，该消息通知运行易受攻击的 Bitcoin Core 版本（0.12.1 之前）的对等节点其警报系统不安全。中本聪引入了警报系统来通知用户重要的网络事件，但它在版本 0.12.1 中已经[退役][retired]了，只留下了最终警报消息。

- [BLIPs #55][] 添加了 [BLIP55][] 来指定移动客户端如何通过端点注册 webhook 以从 LSP 接收推送通知。此协议对于客户端在接收[异步支付][topic async payments]时获得通知很有用，最近在 LDK 中实现了（参见[周报 #365][news365 webhook]）。

## 更正

在[上周的周报][news365 p2qrh]中，我们错误地描述了 [BIP360][]（_支付到抗量子哈希_）的更新版本“完全做出了” Tim Ruffing 在其[最近论文][ruffing paper]中显示安全的更改。BIP360 实际做的是将对基于 SHA256 的默克尔根（加上密钥路径替代选项）的椭圆曲线承诺替换为直接对默克尔根的 SHA256 承诺。Ruffing 的论文显示，如果将抗量子签名方案添加到 [tapscript][topic tapscript] 语言中并禁用密钥路径支出，taproot 在当前使用中是安全的。BIP360 实际要求钱包升级到 taproot 的变体（尽管是一个微不足道的变异），从其变体中消除密钥路径机制，并描述了向其 tapleaf 中使用的脚本语言添加量子抗性签名方案。虽然 Ruffing 的论文不适用于 BIP360 中提出的 taproot 变体，但这个变体的安全性（视作一种承诺时）直接来自默克尔树的安全性。

我们为错误道歉，并感谢 Tim Ruffing 通知我们的错误。

{% include references.md %}
{% include linkers/issues.md v=2 issues="33106,32941,31385,31244,30635,28944,3133,10097,9625,4730,55" %}
[bitcoin core 29.1rc1]: https://bitcoincore.org/bin/bitcoin-core-29.1/
[bitcoin++ insider]: https://insider.btcpp.dev/
[news365 p2qrh]: /zh/newsletters/2025/08/01/#security-against-quantum-computers-with-taproot-as-a-commitment-scheme
[zhao minfee]: https://delvingbitcoin.org/t/changing-the-minimum-relay-feerate/1886/
[towns tempshare]: https://delvingbitcoin.org/t/sharing-block-templates/1906
[towns tempshare poc]: https://github.com/ajtowns/bitcoin/commit/ee12518a4a5e8932175ee57c8f1ad116f675d089
[news299 weak blocks]: /zh/newsletters/2024/04/24/#weak-blocks-proof-of-concept-implementation
[ruffing paper]: https://eprint.iacr.org/2025/1307
[kim bips]: https://mailing-list.bitcoindevs.xyz/bitcoindev/3452b63c-ff2b-4dd9-90ee-83fd9cedcf4an@googlegroups.com/
[ubip1]: https://github.com/utreexo/biptreexo/blob/7ae65222ba82423c1a3f2edd6396c0e32679aa37/utreexo-accumulator-bip.md
[ubip2]: https://github.com/utreexo/biptreexo/blob/7ae65222ba82423c1a3f2edd6396c0e32679aa37/utreexo-validation-bip.md
[ubip3]: https://github.com/utreexo/biptreexo/blob/7ae65222ba82423c1a3f2edd6396c0e32679aa37/utreexo-p2p-bip.md
[btcpay server 2.2.0]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.2.0
[lnd v0.19.3-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.3-beta.rc1
[review club 32489]: https://bitcoincore.reviews/32489
[gh achow101]: https://github.com/achow101
[news363 reputation]: /zh/newsletters/2025/07/18/#eclair-2716
[news322 sink]: /zh/newsletters/2024/09/27/#hybrid-jamming-mitigation-testing-and-changes
[news33 canceled]: /zh/newsletters/2019/02/12/#lnd-2457
[final alert]: https://bitcoin.org/en/release/v0.14.0#final-alert
[retired]: https://bitcoin.org/en/alert/2016-11-01-alert-retirement#updates
[news365 webhook]: /zh/newsletters/2025/08/01/#ldk-3662
[news364 orphan]: /zh/newsletters/2025/07/25/#bitcoin-core-31829
