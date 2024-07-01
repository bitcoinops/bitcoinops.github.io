---
title: 'Bitcoin Optech Newsletter #307'
permalink: /zh/newsletters/2024/06/14/
name: 2024-06-14-newsletter-zh
slug: 2024-06-14-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的新闻部分宣布了一个为抗量子计算的比特币地址格式而提议的 BIP 草案，此外是我们的常规栏目：最近一次 Bitcoin Core PR 审核俱乐部的总结，新版本和候选版本的公告，还有比特币基础设施项目的显著变更介绍。

## 新闻

- **<!--draft-bip-for-quantumsafe-address-format-->抗量子计算的地址格式草案 BIP**：开发者 Hunter Beast 在 Delving Bitcoin 论坛和邮件组中[发帖][beast post]，列出了一个分配隔离见证 v3 地址以使用一种[抗量子计算][topic quantum resistance]的签名算法的 [“草稿” BIP][quantum draft]。这个 BIP 草案描述了问题所在，还给出了几种可供选择的算法以及预期的链上开销。算法的选择和具体的实现细节留给了未来的讨论，因为也需要额外的 BIP 来完全实现为比特币添加完整的量子计算抗性的愿景。

## Bitcoin Core PR 审核俱乐部

*在这个月度栏目中，我们总结最近一次 [Bitcoin Core PR 审核俱乐部][Bitcoin Core PR Review Club] 会议，举出一些重要的问题和回答。点击问题描述，可以见到会上答案的总结。*

“[接着执行未完成的重新索引时，不再重复清空索引][review club 30132]” 是 [TheCharlatan][gh thecharlatan] 提出的一些 PR，可以在用户运行重新索引（reindex）时中断又重启时优化启动时间。

Bitcoin Core 实现了 5 种索引。UTXO 集和区块索引是必需的，而交易索引、[致密区块过滤器][topic compact block filters]索引和 coinstats 索引是可选的。在运行 `-reindex`，所有的索引都会清空并重新构造。这个过程可能会花很长时间，而且并不能保证在节点（出于任何理由）停止运行之前完成。

因为节点需要一个最新的 UTXO 集和区块索引，重新索引的状态会持久化到硬盘。而在启动重新索引时，会打上一个[标记][reindex flag set]，这个标记一直到重新索引结束才会取消。这样一来，在节点启动时，它就能检测到自己需要继续重新编制索引，即使用户没有在启动选项中提供这个标记。

在未完成重新索引时中断然后重新启动（而且没有提供 `-reindex` 启动选项）时，必需的索引会被保留，然后继续重构。在 [Bitcoin Core #30132][] 之前，可选的索引会被再次清空。而 [Bitcoin Core #30132][] 会在没有必要时避免情况可选的索引，从而提供启动的效率。

{% include functions/details-list.md
  q0="<!--what-is-the-behavior-change-introduced-by-this-pr-->这个 PR 引入了什么样的动作变化？"
  a0="程序的动作在三个方面发生了变化。第一，满足了这个 PR 的目标，在重新索引未完成之时再次启动，可选的索引不会被再次清空。这让可选索引的动作与必需索引的动作一致。第二，在用户通过 GUI 请求重新索引时，这个请求不会再被忽略，从而消除了 [b47bd95][gh b47bd95] 引入的一个微小的 bug。第三，移除了 “Initializing databases...（初始化数据库）” 这一行日志。"
  a0link="https://bitcoincore.reviews/30132#l-19"

  q1="<!--what-are-the-two-ways-an-optional-index-can-process-new-blocks-->可选的索引处理新区块的两种方式是什么样的？"
  a1="在初始化了一个可选索引之后，它会检查本地最高的区块与链顶端是否同一。如果并不相同，那么它会先在后台通过 `BaseIndex::StartBackgroundSync()` 同步所有遗漏的区块。当索引追上链顶端的时候，它会使用 `ValidationSignals::BlockConnected` 以调用验证接口、进一步处理区块。"
  a1link="https://bitcoincore.reviews/30132#l-52"

  q2="<!--how-does-this-pr-affect-the-logic-of-optional-indexes-processing-new-blocks-->这个 PR 会改变可选索引处理新区块的方式吗？"
  a2="在这个 PR之前，清空可选索引而不清空链状态（chainstate）的话，这些可选索引会被认为脱离了同步。从上一个问题的答案中可知，这意味着可选索引会先运行后台同步，然后再切换到使用验证接口。而在应用这个 PR 之后，可选索引会跟链状态保持同步，因此不再需要这样的后台同步。注意：后台同步只会在重新索引完成之后启动，而验证事件的处理会并行发生。"
  a2link="https://bitcoincore.reviews/30132#l-70"
%}

## 新版本和候选版本

*热门的比特币基础设施项目的新版版和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Core Lightning 24.05][] 是这个热门的闪电节点实现的下一个大版本。它包含了帮助节点更好地与剪枝全验证节点（pruned full node）一起工作的更新（详见[周报 #300][news300 cln prune]），允许 `check` RPC 方法跟插件一起工作（详见[周报 #302][news302 cln check]），以及稳定性升级（例如周报 [#303][news303 cln chainlag] 和 [#304][news304 cln feemultiplier] 中提到的），允许更可靠地分发[offer][topic offers]发票（详见[周报 #304][news304 cln offers]），还修复了一个在使用 `ignore_fee_limits` 会导致超量支付手续的问题（详见 [周报 #306][news306 cln overpay]）。

- [Bitcoin Core 27.1][] 是这个主流比特币全节点实现的维护版本。它包含了多项 bug 修复。

## 重大的代码和说明书变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Bitcoin Core #29496][] 将 `TX_MAX_STANDARD_VERSION` 提高到 3，意味着 “拓扑受限直至确认（[TRUC][topic v3 transaction relay]）” 交易从此成为标准交易。如果一笔交易的版本号为 3，它就会被当作 [BIP431][] 规范定义下的 TRUC 交易得到处理。当前版本号 `CURRENT_VERSION` 保持为 2，意味着钱包还不会创建 TRUC 交易。

- [Bitcoin Core #28307][] 修复了一个 bug，该 bug 在同时是 P2SH-segwit 和 bech32 的隔离见证赎回脚本上施加了 520 字节的 P2SH 脚本最大体积限制。这个修复使我们可以创建内含超过 15 个公钥的多签名[输出描述符][topic descriptors]（现在允许触及 `OP_CHECKMULTISIG` 的共识限制，20 个公钥），以及这些脚本的签名，还有其它超过 P2SH 限制的后隔离见证赎回脚本。

- [Bitcoin Core #30047][] 重构了 [bech32][topic bech32] 编码方案的模式，将 `charlimit` 从常量 90 改为 `Enum`。这个变更使得更容易支持使用 bech32 编码方案的新地址类型，但不会有跟 [BIP173][] 一样的字符限制。举个例子，为了支持解析 “[静默支付][topic silent payments]” 地址，就需要高达 118 个字符。

- [Bitcoin Core #28979][] 更新了 `sendall` RPC 命令的说明书（详见[周报 #194][news194 sendall]），提到了它除了会花费已经确认的输出，还会花费未确认的找零。在花费未确认的输出时，它会补缴 *手续费赤字（fee deficit）*（详见[TRUC][topic v3 transaction relay]）。*这一条在出版之后有所修正。*[^correction-28979]

- [Eclair #2854][] 和 [LDK #3083][] 实现了 [BOLTs #1163][]，移除了在 [洋葱消息][topic onion messages] 分发失败时调用更新一次通道状态（调用 `channel_update`）的需要。这一要求会帮助攻击者：让一个中继器节点产生分发失败状态，就可以通过 `channel_update` 字段定位相关 [HTLC][topic htlc] 的发送者；这会牺牲发送者的隐私性。

- [LND #8491][] 在 `lncli` RPC 命令 `addinvocie` 和 `addholdinvoice` 中添加了一个 `cltv_expiry` 标记，从而允许用户设定 `min_final_cltv_expiry_delta`（最后一跳的 [CLTV 过期时间差值][topic cltv expiry delta]）。PR 页面未介绍这一变更的动机，但可能是为了响应 LND 最近将其默认值从 9 个区块改为 18 个区块（以符合 [BOLT2][] 规范）（详见[周报 #284][news284 lnd final delta]）。

- [LDK #3080][] 重构了 `MessagerRouter` 的 `create_blinded_path` 命令，使之成为两个方法：一个用于创建紧凑的 “[盲化路径][topic rv routing]”，另一个用于创建常规的盲化路径。这就允许根据调用者的语境相机抉择。紧凑的盲化路径使用短通道标识符（SCID），该标识符引用的是一笔主子交易（或者一条通道的化名），一般是 8 个字节；常规的盲化路径使用公钥（长达 33 字节）来指称一个闪电节点。如果一条通道被关闭了，或者发生了 “[拼接][topic splicing]”，紧凑路径可能会过时，所以它最合适的用途是临时的 QR 码或者字节空间非常宝贵的支付连接。常规路径更适合长期用途，包括基于[洋葱消息][topic onion messages]的 [offer][topic offers]，因为使用公钥作为节点标识符允许转发消息给一个对等节点，即使两者之间不再有通道（洋葱路由的通信并不需要通道）。`ChannelManager` 更新为对临时使用的 [offer][topic offers] 和退款使用紧凑的盲化路径，虽然洋葱消息的回复路径被重构为使用常规的（非紧凑的）盲化路径。

- [BIPs #1551][] 添加了 [BIP353][]，该规范是 DNS 支付指令规范，是一套用于在 DNS 文本（TXT）记录中编码 [BIP21][] URI 的协议。这样做允许直接阅读，而且可以私密地查询这样的记录。举个例子，`example@example.com` 可以解析为一个 DNS 地址，比如 `example.user._bitcoin-payment.example.com`，而访问它会返回一个带有 DNSSEC 签名的、包含一个 BIP21 URI（例如 `bitcoin:bc1qexampleaddress0123456`）的文本记录。阅读[周报 #290][news290 bip353] 可以了解我们以前的介绍。[上周的周报][news306 dns] 还介绍了一个相关的 BLIP 被合并的事情。

## 脚注

[^correction-28979]: 我们的初版对 Bitcoin Core #28979 的介绍声称 `sendall` 花费未确认的找零输出是一个动作变化。感谢 Gustavo Flores 最初的正确描述（这个错误是由本报的编辑引入的），以及 Mark "Murch" Erhardt 报告这个错误。

{% include references.md %}
{% include linkers/issues.md v=2 issues="29496,28307,30047,28979,2854,3083,1163,8491,3080,3072,1551,30132" %}

[beast post]: https://delvingbitcoin.org/t/proposing-a-p2qrh-bip-towards-a-quantum-resistant-soft-fork/956
[quantum draft]: https://github.com/cryptoquick/bips/blob/p2qrh/bip-p2qrh.mediawiki
[core lightning 24.05]: https://github.com/ElementsProject/lightning/releases/tag/v24.05
[Bitcoin Core 27.1]: https://bitcoincore.org/bin/bitcoin-core-27.1/
[news306 cln overpay]: /zh/newsletters/2024/06/07/#core-lightning-7252
[news304 cln feemultiplier]: /zh/newsletters/2024/05/24/#core-lightning-7063
[news304 cln offers]: /zh/newsletters/2024/05/24/#core-lightning-7304
[news303 cln chainlag]: /zh/newsletters/2024/05/17/#core-lightning-7190
[news302 cln check]: /zh/newsletters/2024/05/15/#core-lightning-7111
[news300 cln prune]: /zh/newsletters/2024/05/01/#core-lightning-7240
[review club 30132]: https://bitcoincore.reviews/30132
[gh thecharlatan]: https://github.com/TheCharlatan
[gh b47bd95]: https://github.com/bitcoin/bitcoin/commit/b47bd959207e82555f07e028cc2246943d32d4c3
[reindex flag set]: https://github.com/bitcoin/bitcoin/blob/457e1846d2bf6ef9d54b9ba1a330ba8bbff13091/src/node/blockstorage.cpp#L58
[news198 sendall]: /en/newsletters/2022/04/06/#bitcoin-core-24118
[news290 bip353]: /zh/newsletters/2024/02/21/#dns-based-human-readable-bitcoin-payment-dns
[news194 sendall]: /en/newsletters/2022/04/06/#bitcoin-core-24118
[news269 deficit]: /zh/newsletters/2023/09/20/#bitcoin-core-26152
[news284 lnd final delta]: /zh/newsletters/2024/01/10/#lnd-8308
[news306 dns]: /zh/newsletters/2024/06/07/#blips-32
