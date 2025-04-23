---
title: 'Bitcoin Optech Newsletter #135'
permalink: /zh/newsletters/2021/02/10/
name: 2021-02-10-newsletter-zh
slug: 2021-02-10-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 链接到了上周 Taproot 激活会议的摘要，并宣布了下周另一个预定会议。此外，它还描述了离散对数合约（Discreet Log Contracts）方面的最新进展以及一个用于讨论它们的新邮件列表。还包括我们常规的部分，涵盖了 Bitcoin Core PR Review Club 会议的摘要、发布及候选发布的描述，以及对流行的比特币基础设施项目中值得注意的更改的列表。

## News

- **<!--taproot-activation-meeting-summary-and-follow-up-->****Taproot激活会议摘要及后续：** Michael Folkson 发布了一个[摘要][folkson1]，总结了计划中的会议，讨论 Taproot 激活方法（参见 [Newsletter #133][news133 taproot meeting]）。参与者似乎支持使用[BIP8][]激活机制，最早允许的激活时间是在包含激活代码的 Bitcoin Core 首次发布约两个月后，初始部署的最晚允许激活时间约为一年后。

  更具争议的是`LockinOnTimeout`（LOT）参数是否应默认设置为*true*（要求矿工最终支持新规则，否则面临链分裂风险）或*false*（允许矿工自由信号而不立即产生后果，尽管一些用户可能选择稍后启用`LOT=true`）。Folkson在邮件列表中撰写了[第二篇帖子][folkson2]，总结了他所见的两种不同选项的论点，并宣布将在2月16日19:00 UTC在Freenode ##taproot-activation频道举行后续会议，讨论这些问题（以及一些较不具争议的问题）。

- **<!--new-mailing-list-for-discreet-log-contracts-->****离散对数合约新邮件列表：** Nadav Kohen [宣布][kohen post]创建了一个[新邮件列表][dlc list]，用于讨论与离散对数合约（DLCs）相关的主题。他还总结了 DLCs 当前的开发状态，包括多个兼容的实现、使用 ECDSA [签名适配器][topic adaptor signatures]、依赖于数值结果的有效压缩算法，以及支持来自预言机的 k-of-n 门限签名“甚至支持预言机之间允许存在一些有界差异的数值情况”。

## Bitcoin Core PR Review Club

*在本月的部分中，我们总结了最近的 [Bitcoin Core PR Review Club][] 会议，重点介绍了一些重要的问题和答案。点击下面的问题以查看会议中答案的摘要。*

[只支持带见证的致密区块][review club #20799]是 John Newbery 提出的一个 PR（[#20799][Bitcoin Core #20799]），建议[移除对非 Segwit 版本][nonsegwit]的 [BIP152][] 致密区块的支持。

审查俱乐部的讨论重点是理解致密区块、高带宽与低带宽模式以及版本使用和兼容性，然后再深入代码的更改。

{% include functions/details-list.md
  q0="**<!--q0-->**致密区块是什么？"
  a0="致密区块，详见 [BIP152][]，是一种通过比特币点对点网络中继区块以减少带宽使用的方法。它们利用了这样一个事实：在交易传播过程中，对等节点已经见过接收区块中大部分包含的交易。致密区块可以在高带宽模式或低带宽模式下中继。在高带宽模式下中继时，致密区块还可以加快区块传播速度。"

  q1="**<!--q1-->**致密区块工作需要什么？"
  a1="接收方必须拥有包含可能被包含在区块中的交易的内存池。因此，致密区块仅适用于在区块链尖端或附近中继区块。对于较旧的区块，接收方的内存池中不会有这些交易，需要使用 `getblocktxn` 消息请求它们。在这种情况下，直接请求完整区块更高效。"

  q2="**<!--q2-->**致密区块如何节省带宽？"
  a2="致密区块不使用完整的交易ID，而是包含更小的短 ID，这些 ID 尺寸较小但足以唯一标识交易。接收致密区块的节点会将每个短 ID 与其内存池中的交易匹配，以重建完整区块。这大大减少了区块中继的带宽。"
  a2link="https://bitcoincore.reviews/20799#l-90"

  q3="**<!--q3-->**“高带宽”模式和“低带宽”模式有什么区别？"
  a3="在高带宽模式下，致密区块是未经请求地发送的，用更高的带宽使用换取更低的延迟，而在低带宽模式下，致密区块仅在收到 `inv` 或 `headers` 消息后按请求发送。在高带宽模式下，致密区块消息可以在完全验证之前中继，只需区块头有效即可中继。"
  a3link="https://bitcoincore.reviews/20799#l-156"

  q4="**<!--q4-->**我们如何选择哪些对等节点处于高带宽模式？"
  a4="我们选择最近发送给我们的一个新颖有效区块的[最多三个对等节点][three]。这逻辑在网络处理函数 `MaybeSetPeerAsAnnouncingHeaderAndIDs` 中。"
  a4link="https://bitcoincore.reviews/20799#l-219"

  q5="**<!--q5-->**为什么我们可以停止支持版本1的致密区块？"
  a5="BIP152支持两个版本：版本 1（无见证）和版本 2（有见证）。版本2是重建 Segwit 区块所必需的。Segwit 在 2017 年 8 月被激活，因此向对等节点提供版本 1 的预 Segwit 致密区块已不再有用；没有见证，对等节点无法验证区块是否遵循共识规则。"
  a5link="https://bitcoincore.reviews/20799#l-104"

  q6="**<!--q6-->**实际上，如何放弃对版本1的支持？"
  a6="通过忽略版本等于 1 的传入 `sendcmpct` 消息，不再发送信号支持版本1的 `sendcmpct` 消息，仅向 `NODE_WITNESS` 对等节点发送 `sendcmpct` 消息，并使用见证序列化的区块和交易响应 `sendcmpct` 和 `blocktxn` 消息。"
%}

## 发布与候选发布

*流行的比特币基础设施项目的新发布与候选发布。请考虑升级到新版本或协助测试候选发布。*

- [LND 0.12.1-beta.rc1][] 是LND维护版本的候选发布。它修复了可能导致意外通道关闭的边缘案例和可能导致某些支付不必要失败的错误，以及一些其他的小改进和错误修复。

## 重要的代码和文档更改

*本周在[Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案(BIPs)][bips repo]和[闪电网络规范（BOLTs）][bolts repo]中的重要更改。*

- [Bitcoin Core #19509][] 增加了节点之间的每对每个对等节点的消息捕获，以及从这些日志中生成 JSON 输出的能力。使用新引入的命令行参数 `-capturemessages`，节点发送或接收的任何消息都会被记录下来。有一个[长期历史][bitcoin dissector]拥有类似功能的工具，但这一新增功能提供了一个原生的替代方案，替代了维护较少的选项。

- [Bitcoin Core #20764][] 为使用 `bitcoin-cli -netinfo` 生成的输出增加了额外的信息。新增的细节包括对等节点类型（例如全量中继或仅区块）、手动添加的对等节点数量、使用 [BIP152][] “高带宽”（更快）区块中继模式的对等节点，以及任何使用 [I2P][] 匿名网络的对等节点（正在[另一个PR][bitcoin core #20685]中进行工作）。

- [Rust-Lightning #774][] 增加了从 Bitcoin Core 的 REST 和 RPC 接口获取区块和区块头的支持。此外，提供了一个 `BlockSource` 接口，并且可以扩展以支持自定义来源。

- [HWI #433][] 增加了使用 OP_RETURN 输出签署部分签名的比特币交易（PSBTs）的支持。

- [BIPs #1021][] 更新了 [BIP8][] 软分叉激活机制，改变了选择强制执行 *LockinOnTimeout*（LOT）功能的节点的行为。此前，这些节点会拒绝在强制激活期间未信号激活的任何区块。此更改后，节点将容忍最多可能的非信号区块数量，仍然保证激活。这减少了可能被不必要拒绝的区块数量，并降低了矿工与节点运营者之间误沟通的潜在可能性。

- [BIPs #1020][] 更新了 BIP8，现在在*已锁定*期间不再需要信号激活，因为可以通过[最近添加的][BIPs #950] *必须信号*期间的必要信号激活来确保激活。

- [BIPs #1048][] 重写了大部分 [BIP322][] 提案，关于[通用消息签名][topic generic signmessage]，该提案几周前在邮件列表上提出（参见 [Newsletter #130][news130 bip322]）。这些更改允许未实现完整检查集的钱包对于使用它们不理解的脚本的签名返回“无法确定”状态。它还澄清了实现说明，并从签名序列化中移除了不必要的数据。

- [BIPs #1056][] 增加了 [BIP350][]，其中包含修改后的 bech32（bech32m）的规范，正如之前在邮件列表中讨论的那样（参见 [Newsletter #131][news131 bech32m]）。这个修改后的 [bech32][topic bech32] 地址版本（来自 [BIP173][]）将应用于计划中的taproot地址以及后续使用segwit见证脚本的改进。

- [BIPs #988][] 更新了 [BIP174][] 规范，针对 [PSBTs][topic psbt]，要求在*创建者*角色中运行的程序初始化空的输出字段，类似于现有的初始化空输入字段的要求。现有的PSBT创建者，如 Bitcoin Core，已经在这样做。

- [BIPs #1055][] 更新了 [BIP174][]，以澄清专有扩展的格式，扩展了字段表，增加了说明它们如何应用于不同版本 PSBT 的行，并将该BIP标记为关于原始版本0 PSBT的最终版本。

- [BIPs #1040][] 更新了 [BIP85][] 规范，用于从超级 [BIP32][] 密钥链创建密钥和密钥链。这些更新描述了如何使用超级密钥链为基于 RSA 的 PGP 签名创建密钥，这些签名可以加载到与 GPG 兼容的智能卡上。

- [BIPs #1054][] 更新了 [BIP141][] 关于 segwit 共识变更的规范，以澄清在使用 `OP_CHECKMULTISIG` 和 `OP_CHECKMULTISIGVERIFY` 时，签名操作数（sigops）的计数方式。文本之前提到它们的计数方式与使用 P2SH 时相同，但此次更新描述了不直观的具体情况：“对于1到16个公钥的总数，CHECKMULTISIG 分别计为 1 到 16 个 sigops，对于 17 到 20 个公钥的总数，计为 20 个 sigops。”

- [BIPs #1047][] 更新了 [BIP39][] 规范，用于从短语确定性生成 [BIP32][] 种子，新增了一个警告，指出不推荐实施使用非英文单词列表，因为它们的支持不广泛。

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
