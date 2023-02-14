---
title: 'Bitcoin Optech Newsletter #236'
permalink: /zh/newsletters/2023/02/01/
name: 2023-02-01-newsletter-zh
slug: 2023-02-01-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报总结了 serverless payjoin 的提案，并描述了一个支持闪电网络异步支付的支付证明的想法。此外还包括我们的常规部分，其中描述了流行的比特币基础设施软件的显着变化。

## 新闻

- **<!--serverless-payjoin-proposal-->Serverless payjoin 提案：** Dan Gould 在 Bitcoin-Dev 邮件列表中[提交了][gould payjoin]一个提案和 serverless 版本的 [BIP78][]，即 [payjoin][topic payjoin] 协议的[概念证明实现][payjoin impl]。

    在没有 payjoin 的情况下，典型的比特币支付只包括来自消费者的输入，使得交易监控组织要采用[共同输入所有权启发式][common input ownership heuristic]方法，假设交易中的所有输入都属于同一个钱包。Payjoin 通过允许接收方为支付提供输入来打破这种启发式假设。这为 payjoin 的用户提供了即时的隐私改进，并通过降低启发式算法的可靠性来普遍提高所有比特币用户的隐私。

    然而，payjoin 不像典型的比特币支付那样灵活。大多数典型的付款可以在接收者离线时发送，但 payjoin 要求接收者在线以提供和签署他们的输入。现有的 payjoin 协议还要求接收方在消费者可访问的网络地址上接受 HTTP 请求，这通常是通过接收方在包含 payjoin 兼容软件的公共 IP 地址上运行网络服务器来实现的。正如 [Newsletter #132][news132 payjoin] 中提到的，增加 payjoin 使用的一个建议是在常见的终端用户钱包之间允许 payjoin 更多在 P2P 基础层上进行。

    Gould 建议在与 payjoin 兼容的钱包中构建一个轻量级 HTTP 服务器。该服务器具有[噪声协议][noise protocol]加密支持以及使用 [TURN 协议][TURN protocol]遍历 [NAT][] 的能力。这将允许两个钱包在创建 payjoin 支付所需的短暂时间内进行交互通信，而不需要一个长期的网络服务器。尽管 Gould 确实建议调研 [nostr 协议][nostr protocol]以在未来的提案中启用“异步 payjoin”，但目前不允许在接收方离线时创建 payjoin。

    截至撰写本文时，邮件列表中还没有对该提案的回复发布。

- **<!--ln-async-proof-of-payment-->闪电网络异步支付证明：**如[上周周报][news235 async] 中所述，LN 开发人员正在寻找一种发送[异步支付][topic async payments]的方法，该方法可为消费者提供他们向接收者付款的证明。异步支付允许支付者（Alice）通过一系列正常的转发跃点向接收者（Bob）发送闪电网络支付——包括闪电服务提供商（LSP）。如果他临时离线，它将为鲍勃保持住支付。当 Bob 通知 LSP 他已恢复在线时，LSP 才会开始将剩余的付款转发给 Bob。

    在当前基于 [HTLC][topic htlc] 的闪电网络中，这种方法的一个挑战是，如果 Bob 离线，他无法向 Alice 提供引用他选择的秘密的特定付款发票。Alice 可以选择她自己的秘密并将其包含在她发送给 Bob 的异步支付中——这称为 [keysend][topic spontaneous payments] 支付——但由于 Alice 一直都知道 keysend 秘密，她不能用她自己的知识作为给 Bob 付款的证明。或者，Bob 可以预先生成几张标准发票并将它们交给他的 LSP；LSP 可以将它们分发给像 Alice 这样的潜在消费者。当 Bob 最终接受付款时，支付这些发票将生成付款证明，但这将允许 LSP 将同一张发票分发给多个消费者，导致他们都支付相同的秘密。当 LSP 因 Bob 接受了第一笔付款而得知秘密时，LSP 将能够窃取剩余付款的付款给重复使用的发票——这使得 HTLC 的预生成发票解决方案仅在 Bob 信任他的 LSP的情况下才是安全的。

    本周，Anthony Towns [提出][towns async]了一个基于[签名适配器][topic adaptor signatures]的解决方案。这将依赖于闪电网络的计划升级，以便使用 [PTLC][topic ptlc]。Bob 会预先生成一系列签名 nonce 并将它们交给他的 LSP。 LSP 会给 Alice 一个签名 nonce，Alice 会选择一条消息作为她的付款证明（例如“Alice paid Bob 1000 sats at 2023-02-01 12:34:56Z”），然后使用 Bob 的 nonce 和她的消息为她的 PTLC 生成签名适配器。当 Bob 重新上线时，LSP 将付款转发给他。Bob 验证 nonce 之前没有被使用过、付款在其他方面是有效的并且签名适配器数学计算也是有效的，那么他将同意该消息；然后他将接受付款。而当 Alice 最终收到结算的 PTLC 时，她将获得对她所选消息进行承诺的 Bob 的签名。

    Towns 的解决方案涉及 LSP 从 Bob 接收预生成的发票——这类似于 HTLC 的不安全/可信解决方案，但 PTLC 签名适配器解决方案是安全且无需信任的，因为来自不同消费者（如 Alice）的每次付款都使用不同的 PTLC 公钥点和 Bob 能够防止 nonce 重用。每个 PTLC 点都是不同的，因为它源自每个消费者选择的唯一消息。 Bob 能够通过在他接受每笔付款之前检查 nonce 重用来防止 nonce 被重复使用。

    在他的帖子中，Towns [引用了][towns sa1]两个[之前][towns sa2]他写的关于使用签名适配器的 LN 付款证明邮件列表帖子。截至撰写本文时，邮件列表中还没有对该想法的回复发布。

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]和 [Lightning BOLTs][bolts repo]。*

- [Bitcoin Core #26471][] 当用户打开 `-blocksonly` 模式时，将默认交易池容量（从 300MB）减少到 5MB。由于未使用的交易池内存与 dbcache 共享，此更改还减少了 `-blocksonly` 模式下的默认 dbcache 大小。用户仍然可以使用 `-maxmempool` 选项配置更大的交易池容量。

- [Bitcoin Core #23395][] 向 `bitcoind` 中添加了一个 `-shutdownnotify` 配置选项，它在 `bitcoind` 正常关闭时执行自定义用户命令（该命令不会在程序崩溃时执行）。

- [Eclair #2573][] 开始接受 [keysend][topic spontaneous payments]不包含[支付秘密][topic payment secrets]的付款，即使 Eclair 宣传说支付秘密是强制性的。根据 pull request 的描述，LND 和 Core Lightning 都可在没有支付秘密的情况下发起 keysend 支付。支付秘密旨在支持[多路径支付][topic multipath payments]，因此 Eclair 将其留给其他节点来实现，以确保它们仅发送单路径的 keysend 支付。

- [Eclair #2574][] 与上述 pull request 相关，停止在其发送的 keysend 付款中包含支付秘密。根据 pull request 描述，LND 拒绝包含支付秘密的 keysend 支付，即使在 keysend 的 [BLIP3][] 规范中没有描述。

- [Eclair #2540][] 对 Eclair 如何存储有关资金和承诺交易的数据进行了一些更改，以准备之后添加对[通道拼接][topic splicing]的支持。请参阅 [#2584][eclair #2584] 以了解当前的 pull request 草案。该请求将添加实验性的通道拼接支持。

- [LND #7231][] 给 `lncli` 添加 RPC 和选项以签署和验证消息。对于 P2PKH，该格式与 2011 年首次添加到 Bitcoin Core `signmessage` 的 RPC 兼容。对 P2WPKH 和 P2SH-P2WPKH（也称为嵌套 P2PKH 或 NP2PKH）将使用相同的格式。此格式预期签名将采用 ECDSA 格式并且验证需要从签名中导出公钥。对于通常与 [schnorr 签名][topic schnorr signatures]一起使用的 P2TR 地址。如果使用比特币的 schnorr 签名算法，则无法从签名中导出公钥。相反，ECDSA 签名是为 P2TR 地址所生成和验证的。

    注意：Optech 通常[建议反对][p4tr new hd] ECDSA 签名函数使用那些原计划用于 schnorr 签名的密钥。但 LND 开发人员已采取[额外的预防措施][osuntokun sigs]以避免出现问题。

- [LDK #1878][] 添加了设置每次付款（而不是全局）`min_final_cltv_expiry` 值的功能。该值决定了接收方在到期前要求付款的最大区块数。标准默认值为 18 个块，但接收方可以通过在 [BOLT11][] 发票中设置参数来请求更多时间。

    为了让 LDK 结合其独特的[无状态发票][topic stateless invoices]实现来支持该特性，LDK 将该值编码到消费者要强制发送的[支付秘密][topic payment secrets]中。它提供 12 位的到期值，允许最多 4,096 个区块（约 4 周）到期。

- [LDK #1860][] 添加了对使用[锚点输出][topic anchor outputs]的通道的支持。

{% include references.md %}
{% include linkers/issues.md v=2 issues="26471,23395,2573,2574,2584,2540,1878,1860,7231" %}
[common input ownership heuristic]: https://en.bitcoin.it/wiki/Privacy#Common-input-ownership_heuristic
[news132 payjoin]: /en/newsletters/2021/01/20/#payjoin-adoption
[gould payjoin]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-January/021364.html
[payjoin impl]: https://github.com/chaincase-app/payjoin/pull/21
[noise protocol]: http://www.noiseprotocol.org/
[turn protocol]: https://en.wikipedia.org/wiki/Traversal_Using_Relays_around_NAT
[nat]: https://en.wikipedia.org/wiki/Network_address_translation
[nostr protocol]: https://github.com/nostr-protocol/nostr
[news235 async]: /zh/newsletters/2023/01/25/#request-for-proof-that-an-async-payment-was-accepted
[towns async]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-January/003831.html
[towns sa1]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-February/001034.html
[towns sa2]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001490.html
[osuntokun sigs]: https://github.com/lightningnetwork/lnd/pull/7231#issuecomment-1407138812
[p4tr new hd]: /en/preparing-for-taproot/#use-a-new-bip32-key-derivation-path
