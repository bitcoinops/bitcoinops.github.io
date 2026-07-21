---
title: 'Bitcoin Optech 周报 #414'
permalink: /zh/newsletters/2026/07/17/
name: 2026-07-17-newsletter-zh
slug: 2026-07-17-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报介绍了一个将形式化验证应用于比特币协议的新项目。此外还包括我们的常规栏目：宣布新版本与候选版本，并总结流行比特币基础设施软件的重要代码变更。

## 新闻

- **<!--formal-verification-of-the-bitcoin-protocol-->****比特币协议的形式化验证：** Keagan McClelland 在 Bitcoin-Dev 邮件列表和 [Delving Bitcoin][verif del] 上[发帖][verif ml]，介绍他形式化验证比特币协议的工作。形式化验证是一种软件开发实践，目标是使用数学的形式化方法，针对某个规范证明一个系统的正确性。这有望帮助解决围绕比特币共识规则拟议变更的事实争议。Optech 此前也介绍过一个相关项目：为比特币共识规则开发声明式可执行规范（见[周报 #402][news402 hornet]）。

  McClelland 正在开发 [btc-verified][verif gh]，这是一个基于 [Lean4][lean lang] 的验证流程实现。作者给出了一些初步结果，用来展示这种方法的可行性。特别是，他聚焦于比特币计算默克尔根时所使用的算法。该算法包含一个已知缺陷（[CVE-2012-2459][topic cves]），可能导致两份不同的交易列表产生相同的[默克尔根][topic merkle tree vulnerabilities]。Bitcoin Core 构造默克尔根时包含了一项检查，目的是侦测这种熔融。McClelland 使用 btc-verified 形式化证明了：在假设 SHA256 具有抗碰撞性的前提下，这项检查是正确的，而且不存在两份不同的交易列表既能通过该检查、又能生成相同的默克尔根。

  最后，作者请求其他人就该代码仓库及其总体方法提出反馈意见。他也补充了一些免责声明，例如该代码仓库大量使用了 AI，而且该项目目前仍不成熟。

## 版本和候选版本

_流行比特币基础设施项目的新版本和候选版本。请考虑升级到新版本，或帮助测试候选版本。_

- [Bitcoin Core 30.3][] 是这一主流全节点实现的维护版本。它修复了一个 chainstate 数据库问题；该问题可能导致节点在正常运行期间发生过多磁盘读写。此外，它还包含钱包、[PSBT][topic psbt]、[miniscript][topic miniscript]、网络、构建、测试和文档方面的修复。详见其[发布说明][bcc30.3 rn]。

- [Bitcoin Core 29.4][] 是这一主流全节点实现的维护版本。它修复了与 30.3 相同的 chainstate 数据库重写问题，并包含经过挑选的验证、钱包、构建、测试、文档、CI 和兼容性修复。详见其[发布说明][bcc29.4 rn]。

## 重大的代码和文档变更

_以下是来自 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期重大变更。_

- [Bitcoin Core #35295][] 通过并行获取一个区块中各笔交易输入所花费的币，加快了区块验证速度。在验证开始前，Bitcoin Core 会启动多个工作线程，并发取回不同的前序输出，而主线程仍按正常顺序处理区块。新的 `-prevoutfetchthreads` 选项默认使用 8 个工作线程，最多允许 16 个，也可以设为 0 来禁用这项优化。这个变更避免了大量磁盘读取延迟按顺序累积。根据硬件和配置不同，作者的基准测试显示，初始区块下载（IBD）速度可提升到原来的 1.18 倍至 3 倍以上。

- [Bitcoin Core #34897][] 通过跳过某些索引提交，确保可选索引绝不会把状态持久化到领先于 chainstate 最近一次耐久化 UTXO 刷新的位置；只有当索引尖端是最近一次已刷新的 chainstate 区块的祖先时，才允许提交索引。此前，不干净的停机会导致 Bitcoin Core 重启时 chainstate 停在比索引更早的区块，从而在两个数据库之间制造不一致。这对 `coinstatsindex` 尤其麻烦，因为它滚动维护的 [MuHash][news131 muhash] 状态很难在不重新处理相应区块的前提下回退，而这些区块届时又无法从 chainstate 中获得。虽然索引仍可在内存中处理更新的区块，但现在它会等到 chainstate 赶上之后，才把这部分进度保存到磁盘。

- [Bitcoin Core #35406][] 将[私密交易广播][topic transaction origin privacy]跟踪队列限制为 10,000 笔交易（见[周报 #409][news409 privatebroadcast]）。使用这种方法广播的交易，会一直被跟踪，直到节点观察到它们从网络中返回。此前，该跟踪队列的大小没有上限，因此那些因为策略差异而永远不会返回的交易，可能无限积累并无限消耗内存与 CPU。达到上限后，Bitcoin Core 会拒绝新的提交，但不会移除现有条目。用户可以使用 `getprivatebroadcastinfo` 检查该队列，也可以使用 `abortprivatebroadcast` 移除卡住的交易。

- [Bitcoin Core #35380][] 扩展了 `libbitcoinkernel` API（见[周报 #380][news380 kernel]），通过加入 `btck_WitnessStack` 视图以及用于计数、获取和复制其元素的函数，暴露每个交易输入的见证栈和 `scriptSig`。这使外部应用程序——包括[静默支付][topic silent payments]扫描器——可以直接取得保存在 segwit 见证数据或 P2PKH `scriptSig` 中的公钥，而不必另外反序列化原始交易。这些输入公钥是静默支付扫描器判断某笔交易输出是否属于钱包所必需的信息。

- [Bitcoin Core #35568][] 通过禁用可选 `txospenderindex` 的内部 LevelDB Bloom 过滤器，减少了该索引的同步时间和磁盘占用（见[周报 #394][news394 txospender]）。这些过滤器属于数据库查找优化，与 SPV 钱包历史上使用的 [BIP37][] [bloom 过滤器][topic transaction bloom filtering]无关。LevelDB 的 bloom 过滤器实际上从未被查询，只会增加处理和存储开销。在作者的基准测试中，一次完整索引同步从 4 小时 37 分钟缩短到 3 小时 57 分钟，磁盘占用则从 85.0 GiB 降至 80.9 GiB。现有索引仍保持兼容，但若要回收此前生成的过滤器所占空间，则需要重建索引。

- [Bitcoin Core #34538][] 允许通过 `externalip` 选项显式配置的地址具有可被通告的资格，即使 `onlynet` 选项排除了该地址所属的网络。此变更有利于这样一种节点：它通过一种网络自动建立出站连接，却通过另一种网络接收入站连接。例如，一个节点可能仅通过 IPv4 建立出站连接，但同时运行着一个单独配置的 [Tor][topic anonymity networks] onion 服务。此前，Bitcoin Core 会拒绝手动提供的 onion 地址，因为 `onlynet` 选项会把 Tor 标记为不可达。

- [BIPs #2208][] 更新了 [BIP54][] [共识清理][topic consensus cleanup]的论证理由。该提案建议让剥离见证后的 64 字节交易无效，以防它们的哈希值与默克尔内部节点的哈希值混淆。这个 PR 记述了另一项替代提案：保留 64 字节交易的有效性，但拒绝这样的默克尔内部节点——它的两个 32 字节子哈希值连接起来之后，正好构成一笔有效的 64 字节交易（见[周报 #412][news412 merkle64]）。此外，它还纠正了 BIP54 之前的一项说法：默克尔证明验证器永远不需要更新。普通的、非 64 字节交易的证明会自动受到保护；但如果某个验证器接受 64 字节交易的证明，那么在激活后它就需要拒绝这类证明。

- [LND #10962][] 阻止将 [RBF][topic rbf] 合作关闭流程（见[周报 #347][news347 rbf]）用于辅助通道，例如 [Taproot Assets][topic client-side validation] 通道；这类通道的注资输出还承诺了额外的协议状态。LND 此前使用对等节点层级的特性比特来选择 RBF 关闭器，但该关闭器不会调用把资产带入关闭交易所需的辅助钩子。因此，它有可能广播一笔在比特币层面有效、却会破坏资产承诺的交易，并让通道卡在等待关闭状态。

- [LND #10897][] 修复了一个 sweeper 漏洞；该漏洞本可能让辅助通道（例如 [Taproot Assets][topic client-side validation] 通道）中的输入永久搁浅。这类输入可能只有很小的比特币手续费预算，因为它们的大部分价值由覆盖层资产承载，而辅助 sweeper 会为最终的扫出交易补充额外预算。最初，LND 的过滤器只考虑每个输入自身的预算，因此在某次失败的扫出尝试抬高了所需的起始费率后，该输入就可能在未来每一次尝试中都被排除。现在，过滤器在判断某个输入是否负担得起最小中继费和起始费率时，会把辅助预算贡献也计算在内。

- [BINANAs #21][] 为 [BIP442][]（`OP_PAIRCOMMIT` 提案草案，见[周报 #395][news395 paircommit]）分配了 BIN-2025-0003 编号。

{% include snippets/recap-ad.md when="2026-07-21 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="35295,34897,35406,35380,35568,34538,2208,10962,10897,21" %}

[verif ml]: https://groups.google.com/g/bitcoindev/c/OIml9stwbGQ
[verif del]: https://delvingbitcoin.org/t/btc-verified-formalizing-the-bitcoin-protocol/2684
[verif gh]: https://github.com/ProofOfKeags/btc-verified
[lean lang]: https://lean-lang.org/
[news402 hornet]: /zh/newsletters/2026/04/24/#hornet-nodes-declarative-executable-specification-of-bitcoin-consensus-rules
[Bitcoin Core 30.3]: https://bitcoincore.org/bin/bitcoin-core-30.3/
[bcc30.3 rn]: https://bitcoincore.org/en/releases/30.3/
[Bitcoin Core 29.4]: https://bitcoincore.org/bin/bitcoin-core-29.4/
[bcc29.4 rn]: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-29.4.md
[news131 muhash]: /zh/newsletters/2021/01/13/#bitcoin-core-19055
[news380 kernel]: /zh/newsletters/2025/11/14/#bitcoin-core-30595
[news394 txospender]: /zh/newsletters/2026/02/27/#bitcoin-core-24539
[news409 privatebroadcast]: /zh/newsletters/2026/06/12/#bitcoin-core-35410
[news412 merkle64]: /zh/newsletters/2026/07/03/#prohibit-merkle-internal-node-preimages-that-encode-minimal-64-byte-transactions
[news347 rbf]: /zh/newsletters/2025/03/28/#lnd-8453
[news395 paircommit]: /zh/newsletters/2026/03/06/#bips-1699
