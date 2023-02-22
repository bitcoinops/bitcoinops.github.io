---
title: 'Bitcoin Optech Newsletter #237'
permalink: /zh/newsletters/2023/02/08/
name: 2023-02-08-newsletter-zh
slug: 2023-02-08-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报总结了关于在交易的 witness 字段存放数据的讨论，并援引了关于缓解闪电通道阻塞攻击的讨论的总结。此外就是我们的常规栏目：Bitcoin Core PR 审核俱乐部会议的总结，以及热门的比特币基础设施软件的重大变更简介。

## 新闻

- **<!--discussion-about-storing-data-in-the-block-chain-->关于在区块链中存储数据的讨论**：一个新项目的用户最近开始通过隔离见证 v1（[taproot][topic taproot]）输入的 witness 字段向区块链存储大量数据。Robert Dickinson 在 Bitcoin-Dev 邮件组中[发帖][dickinson ordinal]询问，是否应该施加一种体积限制，以阻遏这种利用区块链的方式。

  Andrew Poelstra [回复][poelstra ordinal] 称没有实质有效的办法能阻止这样的数据存储。向 witness 字段添加新的限制以阻止不受欢迎的数据存储，将削弱人们讨论过的 taproot 设计的许多好处（见[周报 #65][news65 tapscript]）；而且有可能只会导致数据以别的方式存入区块链。这些其它方式可能让存储数据的代价更高 —— 但可能不会大到足以阻止这样的行为 —— 而且他们可能会给传统的比特币用户带来新的问题。

  截至本刊发稿之时，关于这个主题还有许多仍在进行的讨论。我们会在下周的周报中提供新的消息。

- **<!--summary-of-call-about-mitigating-ln-jamming-->关于缓解闪电通道阻塞攻击的线上会议的总结**：Carla Kirk-Cohen 和 Clara Shikhelman 在 Lightning-Dev 邮件组中[总结][ckccs jamming]了近期一场关于[通道阻塞攻击][topic channel jamming attacks]可行解决方案的视频会议。得到讨论的主题包括通道状态更新机制的取舍、近期一篇论文提出的一种简单的预付费用的方法（见[周报 #226][news226 jam]）、CircuitBreaker 软件（见[周报 #230][news230 jam]）、声誉凭证的进展（见[周报 #228][news228 jam]），以及来自闪电网络服务供应商（LSP）规范工作组的工作成果。请浏览邮件组帖子和这份[转写稿][jam xs]，以了解更多内容。

  视频会议计划每两周举行一次；请关注 Lightning-Dev 邮件组以获得会议的消息。

## Bitcoin Core PR 审核俱乐部

*在这个月度栏目中，我们会总结最新一期 [Bitcoin Core PR 审核俱乐部][Bitcoin Core PR Review Club] 会议，列出一些重要的问题和回答。点击问题，即可了解会议上总结的答案。*

“[按网络和表格跟踪 AddrMan，优化添加固定种子节点的精确性][review club 26847]” 是 Martin Zumsande 提交的一项 PR，联合作者还有 Amiti Uttarwar。这个 PR 让 Bitcoin Core 客户端在特定情况下可以更可靠地发现可以主动连接的节点（outbound peers）。这是通过加强 `AddrMan`（对等节点地址管理器）来实现的：区分不同网络的地址条目的数量、标记 “已尝试” 和 “未尝试” 类型，从而更好地利用固定的种子节点。这是提升主动连接选择能力的大方向上的第一步。

{% include functions/details-list.md
  q0="<!--when-is-a-network-considered-reachable-->什么时候一个网络会被认为是可访问的？"
  a0="除非我们很确定不能访问，不然我们总会假设一个网络是可以访问的；又或者，当我们的使用了 `-onlynet=` 配置了一个乃至多个 *其它*网络时，就只有这些网络会被认为是可以访问的（即使其它网络在实际上可以访问）。"
  a0link="https://bitcoincore.reviews/26847#l-22"

  q1="<!--how-is-an-address-received-over-the-p2p-network-treated-depending-on-whether-the-address-s-network-is-reachable-vs-non-reachable-do-we-store-it-add-it-to-addrman-and-or-forward-it-to-peers-->为什么通过 P2P 网络接收地址时会取决于地址所在的网络可访问还是不可访问呢？我们会存储它（添加到 `AddrMan`）以及/或者转发它给其他对等节点吗？"
  a1="如果它所在的网络是可访问的，我们会将这个地址转发给两个随机选择的对等节点，不然我们转发给 1 个或 2 个节点（1 跟 2 是随机选择的）。我们只会在相关网络可访问时存储地址。"
  a1link="https://bitcoincore.reviews/26847#l-51"

  q2="<!--how-can-a-node-currently-get-stuck-with-only-unreachable-addresses-in-addrman-finding-no-outbound-peers-how-does-this-pr-fix-it-->什么时候，节点会在 `AddrMan` 中只有不可访问的地址（没有可以主动连接的对等节点）时卡住呢？这个 PR 怎么修复它？"
  a2=" 如果 `-onlynet` 配置改变了，就会这样。举个例子，假设节点一直都使用 `-onlynet=onion` 配置，所以它的 `AddrMan` 是没有 I2P 地址的。然后，这个节点又使用 `-onlynet=i2p` 配置重启了（就会卡住）。固定的种子节点中有一些 I2P 地址，但如果没有这个 PR，节点就不能使用这些信息，因为 `AddrMan` 没有 *完全* 清空（还有以前存储的一些洋葱地址）。有了这个 PR，启动代码将添加一些固定的 I2P 地址，因为 `AddrMan` 没有包含这种（现在可以访问的）网络类型的地址。"
  a2link="https://bitcoincore.reviews/26847#l-98"

  q3="<!--when-an-address-we-d-like-to-add-to-addrman-collides-with-an-existing-address-what-happens-is-the-existing-address-always-dropped-in-favor-of-the-new-address-->如果我们想要向 `AddrMan` 添加的一个地址跟已有的一个地址相冲突，那会怎么样？已有的地址一定会被抛弃吗？"
  a3="不一定，一般来说已有的地址会被保留下来，除非已有的地址被认为是 “糟糕” 的（见`AddrInfo::IsTerrible()`）。"
  a3link="https://bitcoincore.reviews/26847#l-100"

  q4="<!--why-would-it-be-beneficial-to-have-an-outbound-connection-to-each-reachable-network-at-all-times-->为什么对每一个可访问的网络建立一个主动连接总是好事？"
  a4="一个自利的理由是，这将让你的节点更难以被[日蚀攻击][topic eclipse attacks]，因为攻击者将需要在多个网络中运行节点。而非自利的理由是，这可以帮助整个网络，避免因为网络分割出而出现的链分裂。如果一半的节点（包括矿工）都使用 `-onlynet=x`，而另一边节点（包括矿工）都使用 `-onlynet=y`，那么这两条链就可能会分裂。不过，即使没有这个 PR，节点运营者也可以手动为每一种可访问的网络添加一个连接，办法是使用 `-addnode` 配置选项或者 `addnode` RPC。"
  a4link="https://bitcoincore.reviews/26847#l-114"

  q5="<!--why-is-the-current-logic-in-threadopenconnections-even-with-the-pr-insufficient-to-guarantee-that-the-node-has-an-outbound-connection-to-each-reachable-network-at-all-times-->为什么当前的 `ThreadOpenConnections()` 逻辑，即使加上这个 PR，也不足以保证节点总是能为每一个可访问的网络建立主动连接？"
  a5="这个 PR 无法 *保证* 可以对等节点会在可访问的网络中形成特定分布。举个例子，如果你在 `AddrMan` 中保存了 1 万个 clearnet 地址，但只保存了 50 个 I2P 地址，那很用可能你的对等节点全部都位于 clearnet 上（不论是 IPv4 还是 IPv6）。"
  a5link="https://bitcoincore.reviews/26847#l-123"

  q6="<!--what-would-be-the-next-steps-towards-this-goal-see-the-previous-question-after-this-pr-->这个 PR 之后，实现这些目标的下一步是什么？"
  a6="计划中的下一步是为发起连接的程序添加逻辑，尝试为每一种可访问的网络添加至少一个连接。附带链接所示的 PR 已在准备中。"
  a6link="https://bitcoincore.reviews/26847#l-144"
%}

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo] 和 [Lightning BOLTs][bolts repo]。*

- [Bitcoin Core #25880][] 让初始化同步期间的断连超时变成自适应的。Bitcoin Core 在初始化同步期间会并行向多个对等节点请求区块。如果某个对等节点非常慢，慢到同步的节点因此止步不前，Bitcoin Core 会在超时之后断开这个失速的对等节点。在某些情况下，这可能会让低带宽的节点在接收大体积区块时接连断开多个对等节点。这次的代码变更修改了节点的行为，使之动态地调整超时时间：每次因为没有收到区块而断开一个对等节点连接时，就增加超时时间；而在重新开始获得区块之后，超时的时间逐块缩减。

- [Core Lightning #5679][] 提供了一个插件，在 CLN 的列表命令中运行 SQL 查询。这个补丁还可以更优雅地处理已弃用的模块，因为它可以忽视任何在自己发布（被 [Core Lightning #5867][] 引入）之前已经弃用的东西。

- [Core Lightning #5821][] 添加了 `preapproveinvoice`（预先许可的发票）和 `preapprovekeysend`（预先许可的 keysend）RPC，允许调用者发送一个 [BOLT11][] 发票或者 [keysend][topic spontaneous payments] 支付细节给 Core Lightning 的签名模块（`hasmd`）以验证这个模块愿意签名这笔支付。对于一些应用 —— 比如可以花费资金的速度有限制的应用 —— 来说，请求预先许可会比直接尝试支付然后处理失败要更加简单。

- [Core Lightning #5849][] 对后台作了变更，允许节点处理超过 10 万个对等节点（同时跟每个对等节点都可以建立一个通道）。虽然在生产环境中有这样的需求的节点从目前来看还不太可能出现 —— 因为光开设这么多通道就要用掉十几个区块 —— 测试这样的行为可以保证开发者制作性能优化措施。

- [Core Lightning #5892][] 升级了 CLN的 [offers][topic offers] 协议实现，依据是一位开发 Eclair 的相应实现的开发者所作的兼容性测试。

- [Eclair #2565][] 现在要求关闭的通道将资金发送到一个新的链上地址，而不是一个在通道创建时就准备好的地址。这可能会减少[输出关联][topic output linking]，从而提高用户的隐私性。这个策略的一个例外是，当用户启用了闪电协议选项 `upfront-shutdown-script`，这是一种在通道注资时发送给通道对手的请求，要求仅使用该时刻指定的接收地址（详见[Newsletter #158][news158 upfront]）。

- [LND #7252][] 增加了使用 Sqlite 作为 LND 数据库后端的支持。当前仅有全新的 LND 实例可使用这种功能，因为还没有可以迁移现有数据库的代码。

- [LND #6527][] 增加了可以加密服务端的硬盘 TLS 密钥的功能。LND 使用 TLS 密钥来验证远程控制连接的身份，即运行 API。这个 TLS 密钥将使用节点的钱包数据加密，所以解锁钱包也将解锁这个 TLS 密钥。发送和接收支付已经要求解锁钱包。

{% include references.md %}
{% include linkers/issues.md v=2 issues="25880,5679,5867,5821,5849,5892,2565,7252,6527" %}
[news158 upfront]: /en/newsletters/2021/07/21/#eclair-1846
[dickinson ordinal]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-January/021370.html
[poelstra ordinal]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-January/021372.html
[news65 tapscript]: /en/newsletters/2019/09/25/#tapscript-resource-limits
[ckccs jamming]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-January/003834.html
[news226 jam]: /zh/newsletters/2022/11/16/#paper-about-channel-jamming-attacks
[news230 jam]: /zh/newsletters/2022/12/14/#local-jamming-to-prevent-remote-jamming
[news228 jam]: /zh/newsletters/2022/11/30/#reputation-credentials-proposal-to-mitigate-ln-jamming-attacks
[jam xs]: https://github.com/ClaraShk/LNJamming/blob/main/meeting-transcripts/23-01-23-transcript.md
[review club 26847]: https://bitcoincore.reviews/26847
