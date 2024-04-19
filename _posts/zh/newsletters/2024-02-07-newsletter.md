---
title: 'Bitcoin Optech Newsletter #288'
permalink: /zh/newsletters/2024/02/07/
name: 2024-02-07-newsletter-zh
slug: 2024-02-07-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报公布了 Bitcoin Core 中一个影响 LN 的区块停滞错误的公开披露，转发了对如何安全地开启兼容提议中的 v3 交易拓扑限制的零配置通道的担忧，描述了许多合约协议在允许外部参与方为交易贡献输入时必须遵循的一项规则，总结了关于新的避免交易钉死的交易替换规则提案的多次讨论，并提供了 Bitcoin-Dev 邮件列表的简要更新。

## 新闻

- **公开披露 Bitcoin Core 中影响 LN 的区块停滞漏洞：**
  Eugene Siegel 在 Delving Bitcoin 上[公布][siegel stall]了他在近三年前尽责披露的 Bitcoin Core 中的一个漏洞。Bitcoin Core 22 和更高版本包含对该漏洞的修复，但许多人仍在运行受影响的版本，其中一些用户可能还在运行 LN 实现或其他合约协议软件，这些软件可能容易被该漏洞利用。强烈建议升级到 Bitcoin Core 22 或更高版本。据我们所知，无人因如下所述的攻击而损失资金。

  攻击者找到一个 LN 转发节点，该节点关联到一个运行早于 22 版本的 Bitcoin Core 的 Bitcoin 中继节点。攻击者会和受害者节点之间打开许多个独立连接。然后，攻击者试图以比任何诚实的对等节点更快的速度向受害者传送新发现的区块，导致受害者节点自动将自己所有高带宽的[致密区块中继][topic compact block relay]槽位分配给攻击者控制的对等节点。

  当攻击者控制了受害者比特币节点的很多槽位后，它就会使用它所控制的在受害者任意一边的通道来转发它所创建的支付。例如：

  ```
  攻击者支出方 -> 受害者转发方 -> 攻击者接收方
  ```

  攻击者与矿工合作创建一个区块，以在不中继未确认状态交易的情况下，单方面关闭接收方一侧的通道（只有在攻击那些会监控交易池中交易的 LN 实现时，才需要矿工的协助）。该区块或矿工创建的另一个区块也会通过释放 [HTLC][topic htlc] 原像来索取款项。通常情况下，受害者的比特币节点会看到这个区块，并将该区块交给它的 LN 节点，而 LN 节点会提取原像，使其能够从支出方要求支付金额，让其转发的金额平账。

  然而，在这种情况下，攻击者利用这种已揭示的区块停滞攻击来阻止 Bitcoin Core 节点了解包含原像的区块。这种停滞攻击利用了旧版本 Bitcoin Core 的特性：在向另一个新的对等节点请求区块之前，愿意等待某个对等节点长达 10 分钟来让它传送其所宣称的区块。考虑到区块之间平均间隔 10 分钟，这意味着控制 _x_ 个连接的攻击者可以延迟一个比特币节点接收区块的时间，大约相当于产生 _x_ 个区块所需的时间。如果转发付款必须在 40 个区块内领取，那么控制 50 个连接的攻击者就有明显的机会来阻止比特币节点看到包含原像的区块，直到支出节点能够收到退款。如果出现这种情况，攻击者的支出节点就什么也没支付，而攻击者的接收节点则收到了从受害者节点提取的金额。

  根据 Siegel 的报告，为了防止这种停滞，Bitcoin Core 做了两处改动：

  - [Bitcoin Core #22144][] 随机化了消息处理线程中对等节点的服务顺序。参见[周报 #154][news154 stall]。

  - [Bitcoin Core #22147][] 保留至少一个出站高带宽的致密区块对等节点，即使入站对等节点的表现似乎更好。本地节点会选择出站对等节点，这意味着它们被攻击者控制的可能性较小，所以为了安全起见，至少保留一个出站对等节点是有用的。

- **使用 v3 交易安全地打开零配置通道：**
  Matt Corallo 在 Delving Bitcoin 上[发帖][corallo 0conf]，讨论在使用拟议的 [v3 交易中继政策][topic v3 transaction relay]时，如何安全地允许一个[零配置通道打开][topic zero-conf channels]。零配置通道是新的单一注资通道，注资者将部分或全部初始资金交给接受者。在打开通道的交易收到足够数量的确认之前，这些资金是不安全的，因此接受方使用标准闪电网络协议通过注资方花费部分资金是没有风险的。v3 交易中继政策的最初建议，未确认的 v3 交易在交易池中最多只允许有一个子交易；对此的期望是，如果有必要，单个子交易可以用 [CPFP 手续费追加][topic cpfp]到其父交易上。

  这些 v3 规则与双方都能对打开零配置通道的交易进行手续费追加是不兼容的：创建通道的注资交易是关闭通道的 v3 交易的父交易，也是进行手续费追加的 v3 交易的祖父交易。由于 v3 规则只允许一个父交易和一个子交易，因此如果不修改创建方式，就无法对注资交易进行手续费追加。Bastien Teinturier [指出][teinturier splice]，[拼接][topic splicing]也会遇到类似的问题。

  截至本文撰写之时，提出的主要解决方案似乎是修改注资和拼接交易，以便现在就为 CPFP 手续费追加增加一个额外输出；等待[族群交易池][topic cluster mempool]有望使得 v3 允许更多的自由拓扑结构（即不仅仅是一个父交易、一个子交易）；然后放弃额外输出，转而使用更多自由拓扑结构。

- **在易受 txid 熔融性影响的协议中使用 segwit 验证输入的要求：**
  Bastien Teinturier 在 Delving Bitcoin 上[发帖][teinturier segwit]，描述了一个容易被忽略的要求，即在第三方为交易提供输入的协议中，不同用户为交易提供签名后，其 txid 不能改变。例如，在一个[打开闪电网络双向注资通道][topic dual funding]的交易中，Alice 和 Bob 都可能贡献一笔输入。为了确保在另一方以后不合作的情况下各自收到退款，他们会创建并签名一个花费这笔注资的交易，并将这笔交易保存在链外，除非需要时才上链。在他们都签署了退款交易后，他们都可以安全地签名并广播注资父交易。由于退款子交易取决于注资父交易是否具有预期的 txid，因此只有在不存在 txid 熔融性风险的情况下，这个过程才是安全的。

  segwit 可以防止 txid 的熔融性——但前提是交易的所有输入都使用了之前交易的 segwit 输出。对于 segwit v0 来说，Alice 要确定 Bob 使用的是 segwit v0 输出，唯一的办法就是获取包含 Bob 输出的整个先前交易的副本。如果 Alice 不进行这种检查，Bob 就可以谎称使用的是 segwit 输出，但实际用的是允许他修改 txid 的旧版输出，这样他就可以使退款交易无效，并拒绝向 Alice 返还任何资金，除非 Alice 同意向他支付赎金。

  对 segwit v1（[taproot][topic taproot]）来说，每个 `SIGHASH_ALL` 签名都会直接承诺在交易中花费的每一个前序输出（参见[周报 #97][news97 spk]），因此 Alice 可以要求 Bob 公开他的 scriptPubKey（她无论怎样都可以从 Bob 为创建共享交易而需要公开的其他信息中得知）。Alice 验证 scriptPubKey 使用的是 v0 或 v1 版本的 segwit，并让她的签名承诺它。现在，如果 Bob 撒了谎，实际上有一个非 segwit 输出，Alice 签名所做的承诺就不会有效，所以签名就不会有效，资金交易就不会确认，也就不需要退款了。

  这就产生了依赖于预签名退款的协议必须遵守的两条规则，以确保安全：

  1. 如果你提供了一个输入，并且倾向于提供一个花费 segwit v1 输出的输入，那么你就需要获取交易中所有花费的其他输入的前序输出，验证它们都使用了 segwit scriptPubKeys，并使用你的签名对它们进行承诺。

  2. 如果你没有提供输入，也没有使用 segwit v1 输出，则获取所有输入的完整先前交易，验证它们在此交易中使用的输入都是 segwit 输出，并使用你的签名承诺这些交易。你也可以在所有情况下使用这第二个流程，但在最坏的情况下，它消耗的带宽几乎是第一个流程的 20,000 倍。<!-- ~4,000,000 byte
     transaction divided by ~22 byte P2WPKH scriptPubKey -->

- **<!--proposal-for-replace-by-feerate-to-escape-pinning-->关于通过费率替换来躲避钉死攻击的提议：** Peter Todd 在 Bitcoin-Dev 邮件列表中[提出][todd rbfr]了一套[交易替换][topic rbf]策略，即使现有的手续费替换（RBF）策略不允许交易被替换，也可以使用这套策略。他的提议有两种不同的变体：

  - *<!--pure-replace-by-feerate-pure-rbfr-->纯粹费率替换（纯粹 RBFr）：*当前在交易池中的交易可由另一个冲突的交易所替换。冲突交易支付的费率要高很多（例如，替换交易支付的费率是被替换交易的费率的 2 倍）。

  - *<!--one-shot-replace-by-feerate-one-shot-rbfr-->一次性费率替换（一次性 RBFr）：*当前在交易池中的交易可以被支付稍高费率（例如 1.25 倍）的冲突交易所替换，前提是替换交易的费率也足够高，使其位于交易池的前 ~1,000,000 vbytes（这意味着如果在替换交易被接受后立即产生了一个区块，则该替换交易就会被挖出来）。

  Mark Erhardt 描述了（[1][erhardt rbfr1]，[2][erhardt rbfr2]）如何滥用提议的政策，使得攻击者以最小的代价浪费无限量的节点带宽。Peter Todd 更新了政策来消除这种滥用，但 Gregory Sanders 和 Gloria Zhao 在 [Delving Bitcoin][sz rbfr] 的讨论贴中提出了其他担忧：

  - “在族群交易池实现之前，很难分析上述任何一点。Peter 第一个迭代的想法是错误的，它允许无限制的自由中继。他声称他已经通过对该想法进行热修补并加入额外的 RBF 限制来解决这个问题，但像往常一样，对当前的 RBF 规则进行推理是非常困难的，甚至是不可能的。我认为，在完全放弃免费中继保护的想法之前，最好把精力集中在正确处理 RBF 激励机制上。”—— Sanders

  - “由于族群大小不受限制，到今天为止交易池还不支持计算 ‘矿工分数’ 或激励相容的有效方法。[...] 族群交易池的一个优势是能够在整个交易池中计算矿工分数和激励相容性。同样，v3 的一个优势是，由于拓扑结构受限，能够在族群交易池之前完成这些工作。在人们开始挑战设计和实现族群交易池之前，我一直把 v3 定义为不必实现族群限制的 ‘族群限制’，因为它是使用现有的包限制（祖先=2，后代=2。一旦上升到 3，就又可以拥有无限的族群了）代码化族群限制（count=2）的唯一方法之一。v3 的另一个优点是有助于解除对族群交易池的封锁，在我看来，这一点毋庸置疑。总之，我不认为提议的一次性费率替换方案是可行的（即不存在免费中继问题而且可以准确实现）。”—— Zhao

  截至本文撰写之时，这两个不同的讨论仍未达成一致。Peter Todd 已发布了费率替换规则的实验性[实现][libre relay]。

- **Bitcoin-Dev 邮件列表迁移更新：** 截至本文撰写之时，Bitcoin-Dev 邮件列表已不再接受新邮件。这是将其迁移至不同列表服务器过程的其中一步（见[周报 #276][news276 ml]）。迁移完成后，Optech 将提供最新消息。

## 版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [LND v0.17.4-beta][] 是这个流行的闪电网络节点实现的维护发布。发布说明中写道：“这是一个热修复版本，修复了多个错误：通道打开后一直挂起直至重启、`bitcoind` 使用轮询模式时内存泄漏、剪枝节点同步丢失以及打开 TLS 证书加密时 REST 代理不起作用。”

## 重大的代码和文档变更

_本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana
repo]。_

- [Bitcoin Core #29189][] 弃用了 libconsensus。Libconsensus 试图使 Bitcoin Core 的共识逻辑在其他软件中可用。然而，这个库并没有被大量采用，而且已经成为 Bitcoin Core 的维护负担。我们的计划是 “不将其迁移到 CMake 中，而让它在 v27 中结束。任何剩余的用例都可以在未来由 [libbitcoinkernel][] 处理”。

- [Bitcoin Core #28956][] 删除了 Bitcoin Core 中的校正时间，并在用户的计算机时钟出现与网络其他机器不同步时发出警告。校正时间是根据其对等节点报告的时间对本地节点的时间进行的自动调整。这可以帮助时钟稍有偏差的节点向其对等节点学习，使其避免不必要地拒绝区块，也能给自己生产的区块一个更准确的时间。不过，调整后的时间在过去也导致了一些问题，并没有为当前网络中的节点带来有意义的好处。有关此 PR 的先前报道，请参见[周报 #284][news284 adjtime]。

- [Bitcoin Core #29347][] 默认启用 [v2 P2P 传输][topic v2 p2p transport]。两个都支持 v2 协议的对等节点之间的新连接将启用加密。

- [Core Lightning #6985][] 为 `hsmtool` 添加了一些选项，允许它返回链上钱包的私钥，以便将这些私钥导入另一个钱包。

- [Core Lightning #6904][] 对 CLN 的连接和 gossip 管理代码进行了多种更新。一个用户可见的变化是增加了一些字段，用于指示对等节点与本地节点的最后一次至少持续了一分钟的稳定连接是在什么时候。这样就可以移除连接不稳定的对等节点。

- [Core Lightning #7022][] 从 Core Lightning 的测试基础设施中移除 `lnprototest`。请参阅[周报 #145][news145 lnproto]，了解我们在它们被添加时的描述。

- [Core Lightning #6936][] 添加了基础设施以帮助在弃用中的 CLN 功能。现在，代码中的功能会根据当前程序版本自动默认禁用。只要代码仍然存在，用户仍可强制启用这些功能，即使这些功能已过了指定的弃用版本。这就避免了偶尔出现的问题，即 CLN 功能被报告为已废弃，但在计划移除后的很长一段时间内仍在默认情况下继续运行，这可能会导致用户继续依赖该功能，从而增加实际移除的难度。

- [LND #8345][] 通过调用全节点的 `testmempoolaccept` RPC，在广播事务之前就开始测试交易是否可能被中继。这样，节点就能在向第三方发送任何内容之前检测到交易的潜在问题，从而加快发现问题的速度，并限制错误的潜在危害。Bitcoin Core 及其大多数现代复刻和 btcd 全节点中都有 `testmempoolaccept` RPC 的版本。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29189,28956,29347,6985,6904,7022,6936,7022,6936,8345,22144,22147" %}
[news154 stall]: /en/newsletters/2021/06/23/#bitcoin-core-22144
[news145 lnproto]: /en/newsletters/2021/04/21/#c-lightning-4444
[siegel stall]: https://delvingbitcoin.org/t/block-stalling-issue-in-core-prior-to-v22-0/499/
[corallo 0conf]: https://delvingbitcoin.org/t/0conf-ln-channels-and-v3-anchors/494/
[teinturier splice]: https://delvingbitcoin.org/t/0conf-ln-channels-and-v3-anchors/494/2
[teinturier segwit]: https://delvingbitcoin.org/t/malleability-issues-when-creating-shared-transactions-with-segwit-v0/497
[news97 spk]: /en/newsletters/2020/05/13/#request-for-an-additional-taproot-signature-commitment
[todd rbfr]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2024-January/022298.html
[erhardt rbfr1]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2024-January/022302.html
[erhardt rbfr2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2024-January/022316.html
[sz rbfr]: https://delvingbitcoin.org/t/replace-by-fee-rate-vs-v3/488/
[libre relay]: https://github.com/petertodd/bitcoin/tree/libre-relay-v26.0
[libbitcoinkernel]: https://github.com/bitcoin/bitcoin/issues/27587
[news284 adjtime]: /zh/newsletters/2024/01/10/#bitcoin-core-pr-审核俱乐部
[news276 ml]: /zh/newsletters/2023/11/08/#mailing-list-hosting
[lnd v0.17.4-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.4-beta
