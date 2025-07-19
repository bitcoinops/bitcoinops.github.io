---
title: 'Bitcoin Optech Newsletter #361'
permalink: /zh/newsletters/2025/07/04/
name: 2025-07-04-newsletter-zh
slug: 2025-07-04-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报描述了一个提案，建议将用于洋葱消息中继的网络连接和对等节点管理与用于闪电网络中 HTLC 中继的分开。此外，还包括我们常规的部分，摘要了关于改变比特币共识的讨论，并列出了最近对流行比特币基础设施软件的更改。

## 新闻

- **<!--separating-onion-message-relay-from-htlc-relay-->****将洋葱消息中继与 HTLC 中继分开：** Olaluwa Osuntokun 在 Delving Bitcoin 上[发布][osuntokun onion]了关于允许节点使用不同的连接来中继[洋葱消息][topic onion messages]而不是用于中继[HTLC][topic htlc]的建议。虽然目前可能已经可以使用不同的连接，例如在直接中继的情况下（参见周报 [#283][news283 oniondirect]和 [#304][news304 onionreply]），Osuntokun 建议始终可以选择使用不同的连接，允许节点为洋葱消息拥有一组不同的对等节点，而不是用于中继支付的对等节点。他为这种替代方法提供了几个支持论点：它更清晰地分离了关注点，节点可以以更低的成本支持更高密度的洋葱消息对等节点，而不是通道对等节点（因为通道需要花费资金来创建），分离可能允许部署隐私改进的密钥轮换，并且分离可能允许洋葱消息的更快传递，因为不会被 HTLC 承诺通信协议阻塞。Osuntokun 提供了关于提议协议的具体细节。

  几位回复的开发者担心洋葱消息网络如何允许节点被过多的对等节点淹没。在当前的洋葱消息实现中，每个节点通常只与其通道合作伙伴保持连接。创建用于资助通道的 UTXO 需要花费资金（链上费用和机会成本），并且是节点和通道合作伙伴独有的；简而言之，它是 1 UTXO 对 1 连接。即使洋葱消息连接必须由链上资金支持，单个 UTXO 也可以用于与每个公共闪电网络节点建立连接：1 UTXO 对数千连接。

  尽管至少有一位回复者支持 Osuntokun 的提议，但到目前为止，几位回复者提到对拒绝服务风险的担忧。讨论在撰写本文时仍在进行中。

## 改变共识

_每月一节，摘要关于改变比特币共识规则的提案和讨论。_

- **<!--ctv-csfs-advantages-for-ptlcs-->****CTV+CSFS 对 PTLC 的优势：** 开发者继续之前的讨论（参见[周报 #348][news348 ctvstep]），关于[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV)、[OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] (CSFS) 或两者结合对各种已部署和设想协议的好处。特别感兴趣的是，Gregory Sanders [写道][sanders ptlc]，CTV+CSFS “将加速[闪电网络]更新到[PTLCs][topic ptlc]，即使 [LN-Symmetry][topic eltoo] 本身未被采用。可重新绑定的签名在堆叠协议时可以不那么头疼。” Sjors Provoost [询问][provoost ptlc]了细节，Sanders [回复][sanders ptlc2]并附上了他之前关于 LN 消息为 PTLCs 修改的研究的[链接][sanders gist]（参见[周报 #268][news268 ptlc]），并补充说“在今天的协议上实现 PTLCs 并非不可能，但有了可重新绑定的签名，它就变得简单得多。”

  Anthony Towns 还[提到][towns ptlc]，“还缺乏工具/标准化来结合[多重签名][topic musig] 2-of-2 进行 PTLC 揭示（这在链上会很高效），甚至是一般的交易签名（即 `x CHECKSIGVERIFY y CHECKSIG`）。[...] 这需要 musig2 的适配器签名支持，而这不在规范中，并且已从 secp256k1 实现中[移除][libsecp256k1 #1479]。以较低效率作为单独的适配器签名也可以工作，但即使是普通的适配器签名对于 [schnorr 签名][topic schnorr signatures]在 secp256k1 中也不可用。这些也没有包括在更实验性的 secp256k1-zkp 项目中。[...] 如果工具准备就绪，我可以看到 PTLC 支持被添加[...] 但我不认为有人觉得这会是一个高优先级事项，而去投入工作来使加密内容标准化和完善。[...] 如果 [CAT][topic op_cat]+CSFS 可用，就能避免工具问题，成本仅与链上效率有关。[...] 仅有 CSFS 可用时，你仍然会遇到类似的工具问题，因为你需要使用适配器签名来防止你的对手为签名选择不同的 R 值。这些问题与 Gregory Sanders 上述描述的更新复杂性和对等协议更新无关。”

- **<!--vault-output-script-descriptor-->****保险库输出脚本描述符：** Sjors Provoost [发布][provoost ctvdesc]到 Delving Bitcoin，讨论如何使用[保险库][topic vaults]的钱包恢复信息可以使用[输出脚本描述符][topic descriptors]来指定。特别是，他重点讨论了基于 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV) 的保险库，例如 James O'Beirne 的[simple-ctv-vault][] 概念验证实现（参见[周报 #191][news191 simple-ctv-vault]）。

  Provoost 引用了 Salvatore Ingala 在之前讨论中的[评论][ingala vaultdesc]，他说：“我的总体看法是，描述符不是用于这个目的的正确工具”——Sanket Kanjalkar 在当前讨论帖中[同意][kanjalkar vaultdesc1]这一观点，但[找到了][kanjalkar vaultdesc2]一个潜在的解决方法。Kanjalkar 描述了一种变体 CTV 基础的保险库，其中资金被存入一个更典型的描述符，然后从那里转移到 CTV 保险库。这避免了可能导致不熟练的用户丢失资金的情况，并且还允许创建一个假设所有支付给典型描述符的资金都使用相同设置每次转移到保险库的描述符。这将允许 CTV 保险库描述符简洁而完整，而无需对描述符语言进行任何修改。

- **<!--continued-discussion-about-ctv-csfs-advantages-for-bitvm-->****关于 CTV+CSFS 对 BitVM 优势的持续讨论：** 开发者继续之前的讨论（参见[周报 #354][news354 bitvm]），关于[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV) 和[OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] (CSFS) 操作码如何“将 [BitVM] 交易大小减少约 10 倍”并允许非交互式的 peg-ins。Anthony Towns [识别][towns ctvbitvm]了原始提议合约中的一个漏洞；他和其他几位开发者描述了解决方法。额外的讨论着眼于使用提议的 [OP_TXHASH][] 操作码相较于 CTV 的优势。Chris Stewart 使用 Bitcoin Core 的测试软件[实现][stewart ctvimp]了一些讨论的想法，验证了讨论的那些部分并为审阅者提供了具体示例。

- **<!--open-letter-about-ctv-and-csfs-->****关于 CTV 和 CSFS 的公开信：** James O'Beirne [发布][obeirne letter]了一封公开信给 Bitcoin-Dev 邮件列表，由 66 人（截至撰写本文时）签署，其中许多人是比特币相关项目的贡献者。信中“要求 Bitcoin Core 贡献者在接下来的六个月内优先审核和整合 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV) 和 [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] (CSFS)。” 该讨论包含超过 60 条回复。一些技术亮点包括：

  - *<!--concerns-and-alternatives-to-legacy-support-->**对遗留支持的担忧和替代方案：* [BIP119][] 指定了 CTV 用于见证脚本 v1（[tapscript][topic tapscript]）和遗留脚本。Gregory Sanders [写道][sanders legacy]，“遗留脚本支持[...]显著增加了审核面，没有已知的能力增益，也没有已知的协议节省。” O'Beirne [回复][obeirne legacy]，遗留脚本支持在某些情况下可以节省大约 8 vbytes，但 Sanders [链接][sanders p2ctv]到他之前的 pay-to-CTV (P2CTV) 提议和概念验证实现，使这种节省在见证脚本中可用。

  - *<!--limits-of-ctv-only-vault-support-->**仅 CTV 保险库支持的限制：* 签署者 Jameson Lopp [指出][lopp ctvvaults]，他“最感兴趣的是[保险库][topic vaults]，”开始了一场关于 CTV 保险库将提供的属性集、它们与今天使用预签名交易可部署的保险库的比较，以及它们是否在安全性上提供了有意义的改进（尤其是与需要额外共识更改的更高级保险库相比）的讨论。该讨论的关键要点包括：

    - *<!--address-reuse-danger-->**地址重用的危险：* 预签名和 CTV 保险库都必须防止用户重用保险库地址，否则资金可能会丢失。可以通过两步保险库程序来实现这一点，要求两次链上交易将资金存入保险库。需要额外共识更改的更高级保险库不会有这个问题，允许即使是重用地址的存款（尽管这当然会[降低隐私][topic output linking]）。

    - *<!--theft-of-staged-funds-->**分阶段资金的盗窃：* 预签名和 CTV 保险库都允许授权取款的盗窃。例如，保险库用户 Bob 想要支付 1 BTC 给 Alice。使用预签名和 CTV 保险库，Bob 使用以下程序：

      - 从他的保险库中提取 1 BTC（加上可能的费用）到一个临时等待地址。

      - 等待保险库定义的时间。

      - 转账 1 BTC 给 Alice。

      如果 Mallory 窃取了 Bob 等待地址的密钥，她可以在取款完成后但在转账给 Alice 确认之前窃取 1 BTC。然而，即使 Mallory 也窃取了取款密钥，她也无法窃取保险库中剩余的资金，因为 Bob 可以中断任何待处理的取款并将资金重定向到由超安全密钥（或密钥）保护的_安全地址_。

      更高级的保险库不需要该等待步骤：Bob 的取款只能去 Alice 或安全地址。这防止了 Mallory 能够在取款和支出步骤之间窃取资金。

    - *<!--key-deletion-->**密钥删除：* CTV 基础保险库相对于预签名保险库的一个优势是，它们不需要删除私钥以确保预签名交易集是唯一可用的支出选项。然而，Gregory Maxwell [指出][maxwell autodelete]，设计软件以在签署交易后立即删除密钥而不向用户暴露私钥是简单的。目前没有已知的硬件签名设备直接支持这一点，尽管至少有一个设备通过手动用户干预支持这一点——但同样，（据我们所知）即使是测试目前也没有硬件支持 CTV。更高级的保险库将共享 CTV 的无密钥优势，但也需要集成到软件和硬件中。

    - *<!--static-state-->**静态状态：* 基于 CTV 的保险库相对于预签名保险库的一个声称的优势是，可能可以从静态备份中计算出恢复钱包所需的所有信息，例如[输出脚本描述符][topic descriptors]。然而，已经有关于预签名保险库的工作，也允许通过在链上交易中存储预签名状态的非确定性部分来实现静态备份（参见[周报 #255][news255 presig vault state]）。Optech 认为更高级的保险库也可以从静态状态恢复，但我们在截稿时尚未验证这一点。

  - *<!responses-from-bitcoin-core-contributors-->**来自 Bitcoin Core 贡献者的回复：* 截至撰写本文时，Optech 识别的四位目前活跃的 Bitcoin Core 贡献者在邮件列表中回复了这封信。他们说：

    - [Gregory Sanders][sanders ctvcom]：“这封信向技术社区征求反馈意见，而这是我的反馈意见。未部署的 BIP 多年来没有收到任何更新，通常不是提案健康的标志，当然也不是拒绝来自密切关注的人的技术建议的论据。我拒绝这种框架，它是将对该提案的更改门槛提高到仅存明显的破坏，并且我显然拒绝对 BIP119 的时间限制。我仍然认为 CTV（再次在能力意义上）+ CSFS 值得考虑，但这种方式肯定会让它失败。”

    - [Anthony Towns][towns ctvcom]：“从我的角度来看，CTV 讨论丢失了一些重要步骤，取而代之的是倡导者一直试图使用公众压力强迫采用‘加速时间表’，至少在过去三年中一直如此。我试图帮助 CTV 倡导者们采用我认为他们遗失的步骤，但这主要带来的是沉默或侮辱，而不是任何建设性的东西。至少从我的角度来看，这只是创造了激励问题，而不是解决它们。”

    - [Antoine Poinsot][poinsot ctvcom]：“这封信的效果是，正如预期的那样，在推进这个提案（或更广泛的能力捆绑）方面造成了重大挫折。我不确定我们如何从中反弹，但这必然涉及到有人要站出来，实际做出回应社区的技术反馈并展示（真实的）用例。前进的道路必须是通过在强有力的客观、技术论据的基础上建立共识。不是一群人表示兴趣，而没有人站出来帮助提案向前推进。”

    - [Sjors Provoost][provoost ctvcom]：“让我也谈谈我自己的动机。保险库似乎是提案启用的唯一功能，我个人认为重要到值得为之工作。[...] 直到最近，我似乎认为保险库的势头在于 OP_VAULT，而这反过来又需要 OP_CTV。但单一目的的操作码并不理想，所以这个项目似乎没有进展。[...] 相反，我不反对 CTV + CSFS；我没有看到它们有害的论据。由于几乎没有 MeVil 潜力，我也可以想象其他开发者小心地开发和推出这些更改。我只会关注这个过程。我_会_反对的是像共同签署人 Paul Sztorc 提议的基于 Python 的替代实现和激活客户端。”

  - *<!--signatory-statements-->**签署者声明：* 信的签署者在后续声明中也澄清了他们的意图：

    - [James O'Beirne][obeirne ctvcom]：“每个签署者都明确希望看到 CTV+CSFS 的将被审核、整合和激活计划。”

    - [Andrew Poelstra][poelstra ctvcom]：“该封信的早期草案确实要求实际整合甚至激活，但我没有签署任何这些早期草案。在用语被减弱为关于优先级和计划（并且是一个‘礼貌的请求’而不是某种要求）时，我才签署的。”

    - [Steven Roose][roose ctvcom]：“[这封信]只是要求 Core 贡献者以某种紧迫性将此提案列入议程。没有威胁，没有严厉的话。鉴于到目前为止只有少数 Core 贡献者参与了其他地方的提案对话，这似乎是一个合适的下一步，以传达我们希望 Core 贡献者在此对话中提供他们的立场。我强烈反对涉及独立激活客户端的方法，我认为这封电子邮件的情感与希望 Core 参与任何协议升级部署的偏好一致。”

    - [Harsha Goli][goli ctvcom]：“大多数人签署是因为他们真的不知道下一步应该是什么，而交易承诺的压力如此之大，以至于一个糟糕的选择（签署信）比不作为更优。在信件发出前的对话中（由我的行业调查促成），我只收到许多签署者对信的责备。我实际上不知道有任何一个人明确认为这是一个好主意。即便如此，他们还是签了名。这其中暗藏玄机。”

- **<!--op-cat-enables-winternitz-signatures-->****OP_CAT 启用 Winternitz 签名：** 开发者 Conduition 在 Bitcoin-Dev 邮件列表上[发布][conduition winternitz]了一个[原型实现][conduition impl]，使用提议的 [OP_CAT][topic op_cat] 操作码和其他脚本指令，允许使用 Winternitz 协议的[量子抗性][topic quantum resistance]签名由共识逻辑验证。Conduition 的实现需要近 8,000 字节的密钥、签名和脚本（大部分受见证折扣影响，减少链上重量到约 2,000 vbytes）。这比 Jeremy Rubin 之前提议的另一个基于 `OP_CAT` 的量子抗性[Lamport 签名][Lamport signature]方案小约 8,000 vbytes。

- **<!--commit-reveal-function-for-post-quantum-recovery-->****用于后量子恢复的承诺/揭示功能：** Tadge Dryja 在 Bitcoin-Dev 邮件列表上[发布][dryja fawkes]了一种方法，允许个人使用[对量子脆弱][topic quantum resistance]的签名算法花费 UTXO，即使快速量子计算机会允许重定向（窃取）任何尝试花费的输出。这需要一个软分叉，并且是 Tim Ruffing 之前提议的变体（参见[周报 #348][news348 fawkes]）。

  在 Dryja 的方案中，花费者创建了对三部分数据的承诺：

  1. 控制资金的私钥对应的公钥的哈希，`h(pubkey)`。这被称为_地址标识符_。

  2. 公钥和花费者想要最终广播的交易的 txid 的哈希，`h(pubkey, txid)`。这被称为_序列依赖证明_。

  3. 最终交易的 txid。这被称为_承诺 txid_。

  这些信息都没有揭示底层公钥，在这个方案中，假设只有控制 UTXO 的人知道。

  三部分承诺使用量子安全算法广播在交易中，例如作为 `OP_RETURN` 输出。在这一点上，攻击者可以尝试使用相同的地址标识符但不同的承诺 txid 广播他们自己的承诺，将资金转移到攻击者的钱包。然而，攻击者无法生成有效的序列依赖证明，因为他们不知道底层公钥。这对全验证节点来说不会立即显而易见，但在 UTXO 所有者揭示公钥后，他们将能够拒绝攻击者的承诺。

  在承诺确认到适当深度后，花费者揭示与承诺 txid 匹配的完整交易。全节点验证公钥与地址标识符匹配，并且结合 txid，它与序列依赖证明匹配。此刻，全节点移除该地址标识符的除了最早（最深确认）的承诺以外的其他承诺。只有第一个确认的 txid 对于该地址标识符具有有效的序列依赖证明可以解析为确认交易。

  Dryja 详细介绍了如何将此方案作为软分叉部署，如何将承诺字节减少一半，以及今天的用户和软件可以做些什么来准备使用此方案——以及此方案对使用脚本和[无脚本多重签名][topic multisignature]的用户的限制。

- **<!--op-txhash-variant-with-support-for-transaction-sponsorship-->****支持交易赞助的 OP_TXHASH 变体：** Steven Roose 在 Delving Bitcoin 上[发布][roose txsighash]了一个名为 `TXSIGHASH` 的 `OP_TXHASH` 变体，扩展了 64 字节的 [schnorr 签名][topic schnorr signatures]，附加字节以指示签名承诺的交易字段（或相关交易）。除了 `OP_TXHASH` 先前提议的承诺字段外，Roose 指出签名可以使用一种高效的[交易赞助][topic fee sponsorship]形式承诺到区块中的早期交易（参见[周报 #295][news295 sponsor]）。然后他分析了这种机制相对于现有 [CPFP][topic cpfp] 和之前的赞助提议的链上成本，得出结论：“使用 [`TXSIGHASH`] 堆叠，每个堆叠交易的虚拟字节成本甚至可以低于没有赞助的原始成本[...]此外，所有输入都是‘简单’的密钥花费，这意味着如果 [CISA][topic cisa] 被部署，它们可以被聚合。”

  截至撰写本文时，帖子尚未收到任何公开回复。

## 重要代码和文档更改

_[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案 (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]中的重要近期更改。_

- [Bitcoin Core #32540][] 引入了 `/rest/spenttxouts/BLOCKHASH` REST 端点，返回指定区块的已花费交易输出（prevouts）列表，主要以紧凑的二进制（.bin）格式，但也有 .json 和 .hex 变体。虽然以前可以使用 `/rest/block/BLOCKHASH.json` 端点做到这一点，但新端点通过消除 JSON 序列化开销提高了外部索引器的性能。

- [Bitcoin Core #32638][] 添加了验证，以确保从磁盘读取的任何区块与预期的区块哈希匹配，捕捉可能以前未被注意到的比特腐败和索引混淆。由于在 [Bitcoin Core #32487][] 中引入的头哈希缓存，这个额外的检查几乎没有开销。

- [Bitcoin Core #32819][] 和 [#32530][Bitcoin Core #32530] 将 `-maxmempool` 和 `-dbcache` 启动参数的最大值分别设置为 500 MB 和 1 GB，在 32 位系统上。由于该架构的总 RAM 限制为 4 GB，高于新限制的值可能导致内存不足（OOM）事件。

- [LDK #3618][] 实现了[异步支付][topic async payments]的客户端逻辑，允许离线接收节点与始终在线的辅助 LSP 节点预先安排 [BOLT12 offer][topic offers]和静态发票。PR 在 `ChannelManager` 中引入了一个异步接收 offer 的缓存，构建、存储和持久化要约和发票。它还定义了与 LSP 通信所需的新洋葱消息和钩子，并通过 `OffersMessageFlow` 线程化状态机。

{% include snippets/recap-ad.md when="2025-07-08 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32540,32638,32819,3618,1479,32487,32530" %}
[news255 presig vault state]: /zh/newsletters/2023/06/14/#discussion-about-the-taproot-annex-taproot-annex
[news348 ctvstep]: /zh/newsletters/2025/04/04/#ctv-csfs-benefits
[news268 ptlc]: /zh/newsletters/2023/09/13/#ptlc-ln
[news191 simple-ctv-vault]: /zh/newsletters/2022/03/16/#continued-ctv-discussion
[news354 bitvm]: /zh/newsletters/2025/05/16/#description-of-benefits-to-bitvm-from-op-ctv-and-op-csfs
[rubin lamport]: https://gnusha.org/pi/bitcoindev/CAD5xwhgzR8e5r1e4H-5EH2mSsE1V39dd06+TgYniFnXFSBqLxw@mail.gmail.com/
[osuntokun onion]: https://delvingbitcoin.org/t/reimagining-onion-messages-as-an-overlay-layer/1799/
[news283 oniondirect]: /zh/newsletters/2024/01/03/#ldk-2723
[news304 onionreply]: /zh/newsletters/2024/05/24/#core-lightning-7304
[sanders ptlc]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/7
[provoost ptlc]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/80
[sanders ptlc2]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/81
[sanders gist]: https://gist.github.com/instagibbs/1d02d0251640c250ceea1c66665ec163
[towns ptlc]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/82
[provoost ctvdesc]: https://delvingbitcoin.org/t/ctv-vault-output-descriptor/1766/
[simple-ctv-vault]: https://github.com/jamesob/simple-ctv-vault
[ingala vaultdesc]: https://github.com/bitcoin/bips/pull/1793#issuecomment-2749295131
[kanjalkar vaultdesc1]: https://delvingbitcoin.org/t/ctv-vault-output-descriptor/1766/3
[kanjalkar vaultdesc2]: https://delvingbitcoin.org/t/ctv-vault-output-descriptor/1766/9
[towns ctvbitvm]: https://delvingbitcoin.org/t/how-ctv-csfs-improves-bitvm-bridges/1591/8
[op_txhash]: /zh/newsletters/2022/02/02/#composable-alternatives-to-ctv-and-apo
[stewart ctvimp]: https://delvingbitcoin.org/t/how-ctv-csfs-improves-bitvm-bridges/1591/25
[obeirne letter]: https://mailing-list.bitcoindevs.xyz/bitcoindev/a86c2737-db79-4f54-9c1d-51beeb765163n@googlegroups.com/
[sanders legacy]: https://mailing-list.bitcoindevs.xyz/bitcoindev/b17d0544-d292-4b4d-98c6-fa8dc4ef573cn@googlegroups.com/
[obeirne legacy]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAPfvXfKEgA0RCvxR=mP70sfvpzTphTZGidy=JuSK8f1WnM9xYA@mail.gmail.com/
[sanders p2ctv]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/72?u=harding
[lopp ctvvaults]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CADL_X_fxwKLdst9tYQqabUsJgu47xhCbwpmyq97ZB-SLWQC9Xw@mail.gmail.com/
[maxwell autodelete]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAAS2fgSmmDmEhi3y39MgQj+pKCbksMoVmV_SgQmqMOqfWY_QLg@mail.gmail.com/
[sanders ctvcom]: https://groups.google.com/g/bitcoindev/c/KJF6A55DPJ8/m/XVhyLCJiBQAJ
[towns ctvcom]: https://mailing-list.bitcoindevs.xyz/bitcoindev/aEu8CqGH0lX5cBRD@erisian.com.au/
[poinsot ctvcom]: https://mailing-list.bitcoindevs.xyz/bitcoindev/GLGZ3rEDfqaW8jAfIA6ac78uQzjEdYQaJf3ER9gd4e-wBXsiS2NK0wAj8LWK8VHf7w6Zru3IKbtDU5NM102jD8wMjjw8y7FmiDtQIy9U7Y4=@protonmail.com/
[provoost ctvcom]: https://mailing-list.bitcoindevs.xyz/bitcoindev/0B7CEBEE-FB2B-41CF-9347-B9C1C246B94D@sprovoost.nl/
[obeirne ctvcom]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAPfvXfLc5-=UVpcvYrC=VP7rLRroFviLTjPQfeqMQesjziL=CQ@mail.gmail.com/
[poelstra ctvcom]: https://mailing-list.bitcoindevs.xyz/bitcoindev/aEsvtpiLWoDsfZrN@mail.wpsoftware.net/
[roose ctvcom]: https://mailing-list.bitcoindevs.xyz/bitcoindev/035f8b9c-9711-4edb-9d01-bef4a96320e1@roose.io/
[goli ctvcom]: https://mailing-list.bitcoindevs.xyz/bitcoindev/mc0q6r14.59407778-1eb1-4e57-bcf2-c781d6f70b01@we.are.superhuman.com/
[conduition winternitz]: https://mailing-list.bitcoindevs.xyz/bitcoindev/uCSokD_EM3XBQBiVIEeju5mPOy2OU-TTAQaavyo0Zs8s2GhAdokhJXLFpcBpG9cKF03dNZfq2kqO-PpxXouSIHsDosjYhdBGkFArC5yIHU0=@proton.me/
[conduition impl]: https://gist.github.com/conduition/c6fd78e90c21f669fad7e3b5fe113182
[lamport signature]: https://en.wikipedia.org/wiki/Lamport_signature
[dryja fawkes]: https://mailing-list.bitcoindevs.xyz/bitcoindev/cc2f8908-f6fa-45aa-93d7-6f926f9ba627n@googlegroups.com/
[news348 fawkes]: /zh/newsletters/2025/04/04/#securely-proving-utxo-ownership-by-revealing-a-sha256-preimage
[roose txsighash]: https://delvingbitcoin.org/t/jit-fees-with-txhash-comparing-options-for-sponsorring-and-stacking/1760
[news295 sponsor]: /zh/newsletters/2024/03/27/#transaction-fee-sponsorship-improvements
