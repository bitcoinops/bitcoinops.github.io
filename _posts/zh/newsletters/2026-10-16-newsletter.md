---
title: 'Bitcoin Optech 周报 #427'
permalink: /zh/newsletters/2026/10/16/
name: 2026-10-16-newsletter-zh
slug: 2026-10-16-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报总结了旧版 Eclair 中两个拒绝服务漏洞的披露，并介绍了一项在闪电通道内运行复杂多轮合约的方案。此外还包括我们的常规栏目：新版本和候选版本的公告，以及流行比特币基础设施软件的重大变更。

## 新闻

- **<!--disclosure-of-two-dos-vulnerabilities-fixed-in-eclair-v0-14-1-->****Eclair v0.14.1 修复的两个 DoS 漏洞的披露：** Erick Cestari 在 Delving Bitcoin 上[发帖][ec eclair dos]，[负责任地披露][topic responsible disclosures]了 Eclair v0.14.0 及更早版本在开通道流程中的两个拒绝服务（DoS）漏洞。两者都已在 [Eclair #3324][] 中修复，并随 7 月发布的 [v0.14.1][news416 eclair 0.14.1] 推出，仍在运行旧版的用户应当升级。

  第一个漏洞由 Matt Morehouse 使用其模糊测试工具 [smite][smite repo] 发现，是检查重复 `temporary_channel_id` 时的一处竞争条件。Eclair 在接受 `open_channel` 消息之前，会检查该 ID 是否已被使用，但直到后续步骤才记录新通道。因此，攻击者接连快速发送多条相同的 `open_channel` 消息，就可能让其中两条通过检查。随后，Eclair 会为同一个 ID 创建两份通道状态，第二份替换了第一份，留下一份无法访问的通道状态，直到对等节点断开连接前，它都会占用约 25 kB 的内存。反复执行这种攻击，每秒会泄漏约 1 MB 内存，直到节点耗尽内存，或将全部 CPU 时间都花在垃圾回收上。

  第二个漏洞由 Cestari 发现，可以绕过 Eclair 对注资交易尚未确认的待处理通道数量的限制。重复检查只查看临时 ID，因此攻击者可以开始开启一条通道，再将该通道最终的 `channel_id` 用作下一条 `open_channel` 的 `temporary_channel_id`。限制器会将复用的 ID 计数两次，而当新通道获得最终 ID 时，又会移除两个条目。这样，待处理通道可以无限增长，但计数始终不超过二。每条待处理通道都保存一份对等节点的 `init` 功能副本；只需在很高的位置设置一个未知的奇数功能位，就能让这份副本膨胀到约 65 kB。在 Cestari 的测试中，一条没有任何链上开销的连接，就能在约 48 分钟内耗尽节点的 4 GB 内存。由于待处理通道会写入数据库，节点每次重启都会再次崩溃，直到提高内存上限，或手动删除相应的数据库记录。

  在回答一个问题时，Morehouse 指出，Phoenix 等以 Eclair 节点为 LSP 的移动钱包不受影响，因为 ACINQ 几个月前就已为自己的节点打上补丁。

- **<!--offchain-contracts-in-lightning-channels-->****闪电通道中的链下合约：** Adam Gibson 在 Bitcoin-Dev 邮件列表上[发帖][lngap ml]，介绍了名为 LN-GAP 的协议提案，可以在闪电通道内运行复杂、多轮的双方合约，同时只需固定数量的交易，就能在链上解决争议。为了展示这个提案，Gibson 实现了一款由赢家拿走整个彩池的国际象棋游戏；他认为，国际象棋很难在链上运行，很适合用作例子。这项提案已有[代码仓库][lngap repo]和[论文][lngap paper]可供查阅。

  Alice 和 Bob 两名玩家商定一套规则，然后各自走棋。发生争议时，Alice 可以在链上强制执行这些规则。不过，Gibson 指出，闪电网络可以针对已发布的状态强制执行规则，却无法在对手方拖延或停止响应时做到这一点。为此，他引入了见证委员会（venue），其成员负责证明一条已签名的消息（例如国际象棋中的一步棋及其签名）是否在某个截止时间之前发布。委员会只需证明发布时间是否符合要求，无需判断消息内容。发生争议时，Alice 会发布一笔交易，声称 Bob 没有发布任何事件；Bob 随后可以发布第二笔交易，包含反驳证据（自己走的棋和委员会的见证）；最后，Alice 可以发布反证，说明 Bob 的反驳因该事件不符合规则而不成立。

  在 Gibson 的提案中，见证委员会从不持有用户资金。它还避免依赖 FROST 式的门限签名，以便将欺诈责任明确归于作恶的成员。为此，见证使用各成员各自的“单比特签名（one-bit signatures）”，并通过 `OP_CHECKSIGADD` 检查。成员通过手续费获得激励，这些手续费借助[适配器签名][topic adaptor signatures]在通道上原子支付。不过，这个构造依赖诚实多数假设。如果委员会中超过一半的成员与参与合约的一方串通，资金就可能被盗。

  除了游戏，可能的应用还包括存储证明合约：提供方若未能响应挑战，就会失去保证金；以及链下争议解决，其作用类似于 [BitVMX][topic acc] 式零知识验证器在链上所做的工作。

## 版本和候选版本

_流行比特币基础设施项目的新版本和候选版本。请考虑升级到新版本，或帮助测试候选版本。_

- [Bitcoin Core 32.0rc4][] 是这一主流全节点实现下一个主版本的候选版本。已有一份[测试指南][bcc32 testing]可供参考。

## 重大的代码和文档变更

_以下是来自 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期重大变更。_

- [Eclair #3396][]、[#3397][eclair #3397] 和 [#3400][eclair #3400] 修复了恶意通道对等节点在[拼接][topic splicing]期间，阻止 Eclair 在链上兑现 [HTLC][topic htlc] 的几种方式（见[周报 #423][news423 eclair splice]）。此前，对等节点可以选择很远的绝对锁定时间、添加带有[相对时间锁][topic timelocks]的输入、提供非标准见证、超过标准交易重量限制，或将已签名交易的费率设得过低，让 Eclair 签署一笔无法及时发布的拼接交易。第一个 PR 增加了针对这些情况的检查。第二个 PR 让 Eclair 重试因与未确认交易冲突而被拒绝的承诺交易和[惩罚交易][topic ln-penalty]，因为对等节点日后可能通过双花该未确认交易的某个其他输入，用 [RBF][topic rbf] 替换它。这项重试修复也适用于通道注资交易尚未确认的情况，包括[零确认通道][topic zero-conf channels]。第三个 PR 修复了另一处恢复机制的缺口：如果 Eclair 已用某个拼接变体对应的承诺交易强制关闭通道，而同一次拼接的另一个 RBF 替换版本随后确认，Eclair 现在会识别注资交易已经改变，并广播花费已确认拼接输出的承诺交易。此前，资金可能一直被锁定，HTLC 也无法在链上兑现。

- [Eclair #3399][] 和 [#3394][eclair #3394] 修复了[即时（on-the-fly）注资][topic jit channels]可能让 Eclair 向下游对等节点付款，却没有收取对应入站 [HTLC][topic htlc] 的两种情况（见[周报 #419][news419 eclair funding]）。此前，在 Eclair 停止跟踪一笔已过期的支付之后，新支付可以复用它的支付哈希。如果下游对等节点随后在链上兑现了原来的出站 HTLC、揭示了原像，Eclair 就可能错误地兑现新支付的入站 HTLC，而非原来的入站 HTLC，让原来的入站 HTLC 超时，Eclair 却收不到款。第一个 PR 现在会检查一次结算是否属于目前跟踪的支付；如果不是，就用结算中保留的入站 HTLC 详情，兑现正确的 HTLC。第二个 PR 确保获得注资的支付只经由购买了流动性的那条通道转发。此前，Eclair 可能通过与同一对等节点的另一条通道转发，却在到期时向上游返回失败之前，只检查获得注资的通道，尽管另一条通道上的出站 HTLC 仍可兑现。

- [Eclair #3395][] 修复了一个 bug：花费者可以构造带有有效 HMAC 的畸形支付洋葱包，让入站 [HTLC][topic htlc] 一直无法完成处理。花费者可以将逐跳载荷长度编码为大于数据包实际容量的值，同时仍提供有效的 HMAC。此前，Eclair 在提取下一个 HMAC 之前没有验证这个长度，导致未捕获的异常。中继器随后会恢复运行，却没有让该 HTLC 失败；畸形数据包还可能阻止重启后的 HTLC 清理流程初始化。现在，Eclair 会检查逐跳载荷及其 HMAC 是否能容纳在数据包内。如果不能，Eclair 就返回 `InvalidOnionVersion`，让正常的失败处理得以继续。

- [Eclair #3401][] 修复了一个可能让转发节点在断连后损失资金的 bug。Eclair 会保存兑现或拒绝 [HTLC][topic htlc] 的指令，直到相应的通道更新完成签名，以便在重连后重试。此前，如果一项兑现更新已经提出、但尚未签名，Eclair 会拒绝重复或冲突的指令，却同时安排删除原先保存的指令。如果通道在签名前断开，未签名的更新会被丢弃，也就没有指令可以用来重新执行兑现。这样，即使出站 HTLC 已经兑现，入站 HTLC 仍可能超时。现在，Eclair 会保留原先的指令，直到结算更新完成签名。

- [LDK #5080][] 修复了一个 bug：在合作关闭通道期间重启，可能阻止待处理的 [HTLC][topic htlc] 向上游对等节点返回失败。此前，LDK 重启时，会将正在合作关闭的通道排除在处理 HTLC 所用的查找表之外，尽管这些通道仍可能有尚未解决的支付。因此，当下游对等节点让一个 HTLC 失败时，LDK 可能误以为上游通道不存在，并丢弃失败响应。LDK 还可能丢弃等待洋葱解码的入站 HTLC。这可能让 HTLC 一直无法完成处理，直到上游对等节点在到期时强制关闭通道。现在，LDK 在恢复处理现有 HTLC 所需的信息时，也会包括正在关闭的通道。

- [LDK #5087][] 修复了通过使用虚假跳点（dummy hops）的[盲化路径][topic rv routing]发送[洋葱消息][topic onion messages]时的一处潜在隐私泄露（见[周报 #370][news370 dummy hops]）。虚假跳点是由接收者处理的额外加密层，用来掩盖其在路径中的位置。此前，转发跳点会拒绝包含消息内容 TLV 记录的中间洋葱层，但虚假跳点会接受它们。恶意发送方可以在不同的非最终层插入这些记录，并观察最终消息是否产生响应，从而可能发现实际转发在哪里结束、虚假跳点从哪里开始。现在，LDK 也会在虚假跳点拒绝消息内容记录。

- [LND #11068][] 修复了 [Taproot Assets][topic client-side validation] 所用实验性 taproot 覆盖层通道中，缺少辅助 [HTLC][topic htlc] 签名检查的问题（见[周报 #324][news324 overlay]）。在这些通道中，Taproot Assets 签名器（`tapd`）会在常规比特币签名之外，为每个非[粉尘][topic uneconomical outputs] HTLC 提供一个额外的签名条目。此前，如果对等节点发送的承诺包含所需的比特币签名，却省略了部分或全部辅助 HTLC 签名条目，接收方 LND 节点仍会错误地接受它。如果通道后来被强制关闭，缺失的签名可能让受影响的资产 HTLC 无法在链上完成处理。现在，LND 会验证收到的辅助签名条目数量，是否与非粉尘 HTLC 的数量一致。如果不一致，LND 会拒绝该承诺，并强制关闭通道。

- [Rust Bitcoin #6956][] 为传统签名和 segwit v0 签名哈希所用的脚本数据引入了 `ScriptCode` 类型，这些数据可能与被花费的完整脚本不同。按照 [BIP143][]，如果 P2WSH 脚本包含 [OP_CODESEPARATOR][topic OP_CODESEPARATOR]，签名哈希会排除签名检查前最后执行的分隔符及其之前的全部内容，同时保留之后的所有分隔符。此前，`p2wsh_signature_hash` 接受一个见证脚本，可能让调用者对完整脚本作哈希，生成无效签名。现在，这个 API 接受 `ScriptCode`，但调用者仍须自行确定最后执行的分隔符，并截短脚本。这个 PR 还增加了 `P2wpkhScriptCode`，它以固定大小、无需内存分配的形式，表示签署 P2WPKH 输入所用的标准脚本。

- [BDK #2319][] 修复了一个 bug：如果一笔交易在重组后又被挖入相同高度的区块，使用 Electrum 后端的钱包可能丢失对该交易确认状态的跟踪。BDK 可能在缓存中保留被替换区块的区块头，未能识别这笔交易在替代区块中的确认，从而错误地将其显示为未确认。修复后，同步期间会用新获取的区块头刷新缓存，单区块重组后也不例外。

{% include snippets/recap-ad.md when="2026-10-20 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3324,3396,3397,3400,3399,3394,3395,3401,5080,5087,11068,6956,2319" %}

[ec eclair dos]: https://delvingbitcoin.org/t/disclosure-dos-vulnerabilities-fixed-in-eclair-v0-14-1/2928
[news416 eclair 0.14.1]: /zh/newsletters/2026/07/31/#eclair-0-14-1
[smite repo]: https://github.com/lnfuzz/smite
[lngap ml]: https://groups.google.com/g/bitcoindev/c/pjv6bL_42kg
[lngap repo]: https://github.com/AdamISZ/ln-gap
[lngap paper]: https://github.com/AdamISZ/ln-gap/blob/master/docs/paper/lngap-short.pdf
[Bitcoin Core 32.0rc4]: https://bitcoincore.org/bin/bitcoin-core-32.0/test.rc4/
[bcc32 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/32.0-Release-Candidate-Testing-Guide
[LDK #5080]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5080
[LDK #5087]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5087
[news324 overlay]: /zh/newsletters/2024/10/11/#lnd-8960
[news370 dummy hops]: /zh/newsletters/2025/09/05/#ldk-3726
[news423 eclair splice]: /zh/newsletters/2026/09/18/#eclair-3376
[news419 eclair funding]: /zh/newsletters/2026/08/21/#eclair-3351
