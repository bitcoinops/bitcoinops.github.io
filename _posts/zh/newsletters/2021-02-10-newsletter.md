---
title: 'Bitcoin Optech Newsletter #135'
permalink: /zh/newsletters/2021/02/10/
name: 2021-02-10-newsletter-zh
slug: 2021-02-10-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 链接到上周 taproot 激活会议的摘要，并宣布下周还有一场预定会议；此外还介绍了谨慎日志合约（DLC）的最新进展，以及一个专门讨论它的新邮件列表。本期同样包含我们的固定栏目：一场 Bitcoin Core PR 审查俱乐部会议的摘要、各发布与候选发布的说明，以及热门比特币基础设施项目的值得注意的变更列表。

## 新闻

- **<!--taproot-activation-meeting-summary-and-follow-up-->****taproot 激活会议摘要及后续：** Michael Folkson 发布了一篇[摘要][folkson1]，介绍了那场讨论 taproot 激活方法的预定会议（参见 [Newsletter #133][news133 taproot meeting]）。参与者似乎支持采用 [BIP8][] 激活机制：最早的允许激活时间约为首个包含激活代码的 Bitcoin Core 发布版本之后两个月，该初始部署最晚允许的激活时间则约为此后一年。

  更具争议的是 `LockinOnTimeout`（LOT）参数是否应默认为 *true*（要求矿工最终要么表态支持新规则，要么承担链分裂的风险），还是 *false*（允许矿工随意表态而不立即承担后果，不过一些用户之后仍可选择启用 `LOT=true`）。Folkson 在邮件列表上撰写了[第二篇帖子][folkson2]，总结了他所见到的支持这两种选项的论点，并宣布将于 2 月 16 日 19:00 UTC 在 Freenode 的 ##taproot-activation 频道举行后续会议，讨论这些问题（以及一些争议较小的问题）。

- **<!--new-mailing-list-for-discreet-log-contracts-->****谨慎日志合约的新邮件列表：** Nadav Kohen [宣布][kohen post]创建了一个[新邮件列表][dlc list]，用于讨论与谨慎日志合约（DLC）相关的主题。他还总结了 DLC 当前的开发状况，包括多个相互兼容的实现、对 ECDSA [签名适配器][topic adaptor signatures]的使用、针对数值结果的有效压缩算法，以及对预言机 k-of-n 门限签名的支持——“甚至支持预言机之间允许存在一定界限差异的数值情形”。

## Bitcoin Core PR 审查俱乐部

*在这个每月栏目中，我们总结最近一次 [Bitcoin Core PR 审查俱乐部][]会议，重点介绍其中的一些重要问题和答案。点击下面的问题，即可查看会议中答案的摘要。*

[只支持带见证的紧凑区块][review club #20799]是 John Newbery 提出的一个 PR（[#20799][Bitcoin Core #20799]），建议[移除对非 segwit 版本][nonsegwit]的 [BIP152][] 紧凑区块的支持。

审查俱乐部的讨论重点是理解紧凑区块、高带宽与低带宽模式，以及版本的使用与兼容性，之后才深入代码中的变更。

{% include functions/details-list.md
  q0="**<!--q0-->**紧凑区块是什么？"
  a0="紧凑区块由 [BIP152][] 规定，是一种通过比特币点对点网络中继区块、同时减少带宽占用的方式。它利用了一个事实：在交易传播过程中，对等节点已经见过所接收区块中包含的大部分交易。紧凑区块可以在高带宽模式或低带宽模式下中继。以高带宽模式中继时，紧凑区块还能加快区块传播速度。"

  q1="**<!--q1-->**紧凑区块要正常工作需要什么条件？"
  a1="接收方必须有一个内存池，其中包含很可能被打包进该区块的交易。因此，紧凑区块只适用于中继处于或接近区块链顶端的区块。对于较旧的区块，接收方的内存池中没有相应交易，需要用 `getblocktxn` 消息去请求。在这种情况下，直接请求完整区块反而更高效。"

  q2="**<!--q2-->**紧凑区块如何节省带宽？"
  a2="紧凑区块不使用完整的交易 ID，而是包含较短的 ID；短 ID 体积更小，但足以唯一标识一笔交易。收到紧凑区块的节点会把每个短 ID 与内存池中的交易逐一匹配，从而重建完整区块。这大大减少了中继区块所需的带宽。"
  a2link="https://bitcoincore.reviews/20799#l-90"

  q3="**<!--q3-->**“高带宽”模式和“低带宽”模式有什么区别？"
  a3="在高带宽模式下，紧凑区块是未经请求就发送的，用更高的带宽占用换取更低的延迟；而在低带宽模式下，只有在收到 `inv` 或 `headers` 消息之后，才会按请求发送。在高带宽模式下，紧凑区块消息可以在完全验证之前中继，只要求中继前区块头有效。"
  a3link="https://bitcoincore.reviews/20799#l-156"

  q4="**<!--q4-->**我们如何选择哪些对等节点处于高带宽模式？"
  a4="我们会选出最近向我们发送过新的有效区块的[最多三个对等节点][three]。这段逻辑位于网络处理函数 `MaybeSetPeerAsAnnouncingHeaderAndIDs` 中。"
  a4link="https://bitcoincore.reviews/20799#l-219"

  q5="**<!--q5-->**为什么我们可以停止支持版本 1 的紧凑区块？"
  a5="BIP152 支持两个版本：版本 1（不含见证）和版本 2（含见证）。重建 segwit 区块必须使用版本 2。segwit 已于 2017 年 8 月激活，因此再向对等节点提供版本 1 这种前 segwit 时代的紧凑区块已没有用处；没有见证，对等节点无法验证区块是否遵循共识规则。"
  a5link="https://bitcoincore.reviews/20799#l-104"

  q6="**<!--q6-->**实际要怎么做才能放弃对版本 1 的支持？"
  a6="忽略版本等于 1 的传入 `sendcmpct` 消息，不再发送表明支持版本 1 的 `sendcmpct` 消息，只向 `NODE_WITNESS` 对等节点发送 `sendcmpct` 消息，并用带见证序列化的区块和交易来响应 `sendcmpct` 和 `blocktxn` 消息。"
%}

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [LND 0.12.1-beta.rc1][] 是 LND 一个维护版本的候选发布。它修复了一个可能导致通道意外关闭的边缘情况，以及一个可能让某些支付无谓失败的 bug，此外还有一些小改进和错误修复。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]中值得注意的变更。*

- [Bitcoin Core #19509][] 增加了节点之间按对等节点进行的消息捕获，以及从这些日志生成 JSON 输出的能力。使用新引入的命令行参数 `-capturemessages`，节点发送或接收的每条消息都会被记录下来。具备类似功能的工具[由来已久][bitcoin dissector]，但这一新增功能提供了原生的替代方案，替代那些维护不那么积极的选项。

- [Bitcoin Core #20764][] 为 `bitcoin-cli -netinfo` 生成的输出增加了更多信息。新增的细节包括对等节点的类型（例如全量中继或仅区块）、手动添加的对等节点数量、使用 [BIP152][] “高带宽”（更快）区块中继模式的对等节点，以及使用 [I2P][] 匿名网络的对等节点（相关工作正在[另一个 PR][bitcoin core #20685] 中进行）。

- [Rust-Lightning #774][] 增加了从 Bitcoin Core 的 REST 和 RPC 接口获取区块和区块头的支持。此外还提供了一个 `BlockSource` 接口，可通过扩展支持自定义数据源。

- [HWI #433][] 增加了对签署带 OP_RETURN 输出的部分签名比特币交易（PSBT）的支持。

- [BIPs #1021][] 更新了 [BIP8][] 软分叉激活机制，改变了那些选择强制执行 *超时锁定*（lockin on timeout）功能的节点的行为。此前，这些节点会拒绝在强制激活期内任何未表态支持激活的区块。此次更改后，节点会容忍仍能保证激活的最大数量的未表态区块。这减少了可能被无谓拒绝的区块数量，也降低了矿工与节点运营者之间产生误解的可能。

- [BIPs #1020][] 更新了 BIP8，现在在*已锁定*期间不再需要表态，因为借助[最近新增的][BIPs #950]*必须表态*期间内的强制表态，已经可以确保激活。

- [BIPs #1048][] 重写了 [BIP322][] 提案的大部分内容。该提案针对[通用消息签名][topic generic signmessage]，几周前已在邮件列表中提出（参见 [Newsletter #130][news130 bip322]）。这些更改允许未实现全套检查的钱包，对那些使用了它们无法理解的脚本的签名返回“无法确定”（inconclusive）状态。它还澄清了实现说明，并从签名序列化中移除了不必要的数据。

- [BIPs #1056][] 增加了 [BIP350][]，其中包含修改后的 bech32（bech32m）的规范，正如之前在邮件列表中讨论的那样（参见 [Newsletter #131][news131 bech32m]）。这一修改后的 [bech32][topic bech32] 地址版本（源自 [BIP173][]）将适用于计划中的 taproot 地址，以及后续使用 segwit 见证脚本的改进。

- [BIPs #988][] 更新了 [BIP174][] 中关于 [PSBT][topic psbt] 的规范，要求以*创建者*角色运行的程序初始化空的输出字段，这与现有的初始化空输入字段的要求类似。既有的 PSBT 创建者（例如 Bitcoin Core）早已这样做。

- [BIPs #1055][] 更新了 [BIP174][]，澄清了专有扩展的格式，为字段表增加了说明各字段如何适用于不同 PSBT 版本的行，并将该 BIP 就原始版本 0 的 PSBT 而言标记为最终版。

- [BIPs #1040][] 更新了 [BIP85][] 规范，该规范用于从超级 [BIP32][] 密钥链创建密钥和密钥链。这些更新描述了如何使用超级密钥链，为基于 RSA 的 PGP 签名创建密钥，此类签名可以加载到与 GPG 兼容的智能卡上。

- [BIPs #1054][] 更新了 [BIP141][] 中关于 segwit 共识变更的规范，以澄清在使用 `OP_CHECKMULTISIG` 和 `OP_CHECKMULTISIGVERIFY` 时，签名操作（sigops）数量是如何计算的。此前的文本称其计数方式与使用 P2SH 时相同，但此次更新描述了其中不直观的细节：“当公钥总数为 1 到 16 个时，CHECKMULTISIG 分别计为 1 到 16 个 sigops；当公钥总数为 17 到 20 个时，计为 20 个 sigops。”

- [BIPs #1047][] 更新了 [BIP39][] 规范，该规范用于从短语确定性地生成 [BIP32][] 种子，并新增警告：非英文单词列表并未得到广泛支持，因此不建议在实现中使用。

{% include references.md %}
{% include linkers/issues.md issues="433,19509,1021,1020,20764,1048,1056,988,1040,1054,1047,774,950,20685,1055,20799" %}
[LND 0.12.1-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.12.1-beta.rc1
[folkson1]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-February/018379.html
[folkson2]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-February/018380.html
[news133 taproot meeting]: /zh/newsletters/2021/01/27/#scheduled-meeting-to-discuss-taproot-activation
[kohen post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-January/018372.html
[dlc list]: https://mailmanlists.org/mailman/listinfo/dlc-dev
[i2p]: https://en.wikipedia.org/wiki/I2P
[news131 bech32m]: /zh/newsletters/2021/01/13/#bech32m
[news130 bip322]: /zh/newsletters/2021/01/06/#proposed-updates-to-generic-signmessage
[bitcoin dissector]: https://en.bitcoinwiki.org/wiki/Bitcoin_Dissector
[nonsegwit]: https://bitcoincore.reviews/20799#l-197
[unsolicited]: https://bitcoincore.reviews/20799#l-156
[three]: https://bitcoincore.reviews/20799#l-159
