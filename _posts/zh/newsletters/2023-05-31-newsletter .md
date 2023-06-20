---
title: 'Bitcoin Optech Newsletter #253'
permalink: /zh/newsletters/2023/05/31/
name: 2023-05-31-newsletter-zh
slug: 2023-05-31-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报描述了一个新的管理型 joinpool 协议的提案，并总结了使用 Nostr 协议中继交易的想法。还包括我们关于交易池子规则限定系列的另一个条目，加上我们的常规部分总结了发布到 Bitcoin Stack Exchange 的重要问题和答案，列出了新的软件版本和候选版本，并描述了热门比特币基础设施项目的重大变更介绍。

## 新闻

- **管理型 joinpool 协议的提案：** 本周，Burak Keceli 在 Bitcoin-Dev 邮件列表上[发布了][keceli ark] Ark 的想法，这是一种新的[joinpool][topic joinpools]式协议，比特币的所有者可以选择使用交易对手作为特定时间段内所有交易的共同签署人。所有者可以在时间锁到期后单方面撤回他们在链上的比特币，或者在时间锁到期之前立即将比特币以无需信任的方式转移到交易对手方。

    与任何比特币用户一样，交易对手可以随时广播仅花费自己资金的链上交易。如果该交易的输出被用作将资金从所有者转移到交易对手的链下交易的输入，则除非链上交易在合理的时间内确认，否则链下转移将无效。在这种情况下，交易对手在收到已签名的链下交易之前不会签署他们的链上交易。这提供了从所有者到交易对手的无信任单跳、单向原子传输协议。Keceli 描述了这种原子传输协议的三种用途：

    - *<!--mixing-coins-->混币：* joinpool 中的多个用户都可以在交易对手的合作下，将他们当前的链下价值原子互换为等量的新链下价值。这可以快速执行，因为链上组件的故障只会取消互换，将所有资金返回到它们开始的地方。类似于一些现有的[coinjoin][topic coinjoin]实现所使用的盲化协议可以防止任何用户或交易对手确定哪个用户最终获得了哪些比特币。

    - *<!--making-internal-transfers-->进行内部转账：* 一个用户可以将他们的链下资金转移到具有相同交易对手的另一个用户。原子性确保收款人会得到他们的钱或付款方会收到退款。对于不信任支付方和交易对手方的接收方，他们需要等待与常规链上交易一样多的确认。

        Keceli 和一位评论员[链接到][keceli reply0] [之前的][harding reply0]研究，该研究描述了如何通过将零确认支付与诚实保证金配对来使得零确认支付与双花交易变得不经济，任何观察到双花交易的两个版本的矿工都可以申领诚实保证金。这可能允许收款人在几秒钟内接受付款，即使他们不信任任何其他人。

    - *<!--paying-ln-invoices-->支付 LN 发票：* 如果交易对手知道秘密值，用户可以快速承诺将其链下资金支付给交易对手，从而允许用户通过交易对手支付 LN 类型的[HTLC][topic HTLC]发票。

        与内部转账的问题类似，用户无法无需信任地接收资金，因此他们不应在付款收到足够数量的确认或由他们认为有说服力的诚实保证金担保之前透露秘密值。

    Keceli 说，目前可以使用 joinpool 成员之间的频繁交互在比特币上实施基础协议。如果有一个[限制条款][topic covenants]提案，比如：[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]、[SIGHASH_ANYPREVOUT][topic sighash_anyprevout]或者[OP_CAT + OP_CHECKSIGFROMSTACK][topic op_checksigfromstack]被实施，joinpool 的成员将只需要在参与 coinjoin、付款或刷新其链下资金的时间锁时与交易对手进行交互。

    每个 coinjoin、支付或刷新都需要在链上交易中发布承诺，尽管基本上无限数量的操作都可以捆绑在同一个小交易中。为了让操作能够快速完成，Keceli 建议大约每五秒进行一次链上交易，这样用户就不需要等待超过这个时间。每笔交易都是独立的，也就不可能在不破坏承诺或需要前几轮涉及的所有用户的参与下，通过使用[手续费替换][topic rbf]来合并来自多个交易的承诺。因此，一个交易对手每年可能需要确认超过 630 万笔交易，尽管单笔交易都相当小。

    在邮件列表中发布的有关协议的评论包括：

    - *<!--a-request-for-more-documentation-->更多文件的请求：* [至少][stone reply]有两位[受访者][dryja reply]要求提供有关系统如何工作的额外文件，因为邮件列表中提供的高级描述很难分析。此后，Keceli 开始发布[规范草案][arc specs]。

    - *担心与 LN 相比接收速度较慢：* [有几个][dryja reply]人[指出][harding reply1]，在最初的设计中，无法在不等待足够数量的确认的情况下从 joinpool（链上或者链下）获得无需信任的支付。这可能需要数小时，而目前许多 LN 付款不到一秒即可完成。即使有诚实保证金，LN 的平均速度也会更快。

    - *<!--concern-that-the-onchain-footprint-is-high-->担心链上占用空间很大：* 一个[回复][jk_14]指出，每五秒进行一次交易，大约 200 个这样的交易对手将消耗每个区块的整个空间。另一个[回复][harding reply0]假设交易对手的每笔链上交易的大小大致相当于 LN 通道开放或合作关闭交易的大小，因此拥有 100 万用户的交易对手每年创建 630 万笔链上交易将使用相当于每个用户每年平均打开或关闭 6.3 个通道的空间；因此，LN 的链上成本可能低于使用这种交易对手，直到它达到大规模采用。

    - *<!--concern-about-a-large-hot-wallet-and-the-capital-costs-->对大型热钱包和资本成本的担忧：* 一个[回复][harding reply0]考虑到，交易对手需要保持一定数量的比特币（可能在热钱包中）以应对用户在不久的将来可能花费的金额。在当前的设计方案下，在花费一段时间后，交易对手可能需要等待长达 28 天才能收回他们的比特币。如果交易对手对其资本收取了每年 1.5% 的低利率，那么每次涉及交易对手的交易（包括coinjoin、内部转账和LN支付）的金额上将相当于 0.125% 的费用。相比之下，撰写时可获得的[公共统计数据][1ml stats](由1ML收集)显示，LN 转账每跳中位数费率为 0.0026％，几乎低了 50 倍。

    列表上的几条评论也对这个提议感到兴奋，并期待看到 Keceli 和其他人探索管理型 joinpools 的设计空间。{% assign timestamp="1:46" %}

- **通过 Nostr 进行交易中继：** Joost Jager 在 Bitcoin-Dev 邮件列表上[发帖][jager nostr]，请求对 Ben Carman 使用 [Nostr][]协议中继交易的想法提供反馈，这些交易可能无法在提供中继服务的比特币全节点的 P2P 网络上很好地传播。

    特别是，Jager研究了使用 Nostr 中继交易包的可能性，例如通过将其与支付足够高的费用以补偿其祖先的费用不足的后代交易捆绑在一起，以低于最低接受值的费率中继祖先交易。这使得 [CPFP][topic cpfp]费用提升更加可靠和高效，这是 Bitcoin Core 开发人员一直致力于为比特币 P2P 网络实现的一项称为[包中继][topic package relay]的功能。审查包中继的设计和实现的一个挑战是确保新的中继方法不会针对单个节点和矿工（或通常对网络）创建任何新的拒绝服务（DoS）漏洞。

    Jager指出，Nostr 中继有能力轻松使用来自P2P中继网络的替代类型的 DoS 保护，例如需要少量付款来中继交易。他建议，即使恶意交易或包可能导致浪费少量节点资源，允许包中继或其他替代事务的中继也会变得切实并可行。

    Jager 的帖子中链接了一个指向他演示该功能的[视频][jager video]。截至撰写本文时，他的帖子只收到了一些回复，尽管它们都是积极的。{% assign timestamp="40:38" %}

## 等待确认#3：竞价区块空间

_这是一个关于交易转发、交易池纳入以及挖矿选择的[限定周刊][policy series]——解释了为什么 Bitcoin Core 设置了比共识规则更严格的交易池规则，以及钱包可以如何更高效地使用这些交易池规则。_

{% include specials/policy/zh/03-bidding-for-block-space.md %}
{% assign timestamp="1:00:02" %}

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se]是 Optech 贡献者寻找问题答案或者是我们在空闲时间来帮助好奇或困惑用户的首要场所之一。在这个月度专题中，我们重点介绍了自上次更新以来发布的一些投票最高的问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--testing-pruning-logic-with-bitcoind-->用bitcoind测试修剪逻辑]({{bse}}118159)
  Lightlike 指出了仅调试 `-fastprune` 配置选项，该选项使用较小的块文件和较小的最小修剪高度进行测试。{% assign timestamp="1:12:38" %}

- [<!--whats-the-governing-motivation-for-the-descendent-size-limit-->后代大小限制的管理动机是什么？]({{bse}}118160)
  Sdaftuar解释说，由于挖矿和驱逐算法(见[周报 #252][news252 incentives])都采用二次方程的 O（n²）时间作为祖先或后代数量的因素，因此制定了[保守的规则限制][morcos limits]。{% assign timestamp="1:13:19" %}

- [<!--how-does-it-contribute-to-the-bitcoin-network-when-i-run-a-node-with-a-bigger-than-default-mempool-->当我运行一个交易池大于默认交易池的节点时，它对比特币网络有何贡献？]({{bse}}118137)
  Andrew Chow 和 Murch 指出了大于默认交易池的潜在缺点，包括损害交易再广播的传播和无信号的交易再广播的传播。{% assign timestamp="1:16:48" %}

- [<!--what-is-the-maximum_number-of-inputs-outputs-a-transaction-can-have-->交易可以具有的最大输入/输出数值是多少？]({{bse}}118452)
  Murch 提供了 taproot 激活后的最大输入和输出数值，即，3223 重量单位（P2WPKH）作为输出最大值或 1738 重量单位（P2TR）作为输入最大值。{% assign timestamp="1:21:18" %}

- [<!--can-2-of-3-multisig-funds-be-recovered-without-one-of-the-xpubs-->没有任一公钥的 xpub，可以恢复 2/3 多重签名资金吗？]({{bse}}118201)
  Murch 解释说，对于不使用裸多重签名的多重签名设置，除非以前使用相同的多重签名输出脚本，否则需要所有公钥才能使用。他指出，“多重签名钱包的备份策略必须既保留私钥，又保留输出的条件脚本”，并建议将[描述符][topic descriptors]作为备份条件脚本的方法。{% assign timestamp="1:23:50" %}

## 版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Bitcoin Core 25.0][]是 Bitcoin Core 下一个主要版本。该版本添加了一个新的`scanblocks`RPC，简化了`bitcoin-cli`的使用，为`finalizepsbt`RPC 添加了[miniscript][topic miniscript]支持，使用`blocksonly`配置选项减少了默认内存使用，并在启用[致密区块过滤器][topic compact block filters]时加快了钱包重新扫描的速度——以及许多其他新功能、性能改进和错误修复。有关详细信息，见[版本文档][bcc rn]。{% assign timestamp="1:27:05" %}

## 重大的代码和文档变更：

*本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]和[Bitcoin Inquisition][bitcoin inquisition repo]。*

- [Bitcoin Core #27469][]在使用一个或多个钱包时加速了初始区块下载（IBD）。通过此更改，如果区块是在钱包的出生日期（钱包中记录的创建日期）之后开采的，则只会扫描与特定钱包匹配的交易。 {% assign timestamp="1:30:27" %}

- [Bitcoin Core #27626][]允许要求我们的节点在高带宽模式下提供[致密区块中继][topic compact block relay]的对等方从我们向他们发布的最新块发出最多三个交易请求。即使我们最初没有向它们提供致密区块，我们的节点也会响应请求。这允许从其他对等方之一接收致密区块的对等节点向我们请求任何丢失的交易，如果另一个对等节点没有响应，这可以提供帮助。这可以帮助我们的对等方更快地验证区块，这也可以帮助他们在时间关键型功能（如挖矿）中更快地使用它。{% assign timestamp="1:32:40" %}

- [Bitcoin Core #25796][]添加了一个新的`descriptorprocesspsbt`，可用于更新[PSBT][topic psbt]，这些信息将有助于以后签名或最终确定。提供给 RPC 的[描述符][topic descriptors]将用于从交易池和 UTXO 集中检索信息(并且，如果可用，则在使用`txindex`配置选项启动节点时完成已确认的事务)。然后，检索到的信息将用于填写 PSBT。{% assign timestamp="1:35:24" %}

- [Eclair #2668][]阻止 Eclair 试图支付比成功解析该 HTLC 所获得的价值更多的费用来申领链上 [HTLC][topic htlc]。{% assign timestamp="1:37:17" %}

- [Eclair #2666][]允许接收 [HTLC][topic htlc] 的远程节点接受它，即使接受它需要支付的交易费用会将节点的余额减少到最低通道储备以下。通道储备的存在是为了确保节点在试图关闭处于过时状态的通道时至少会损失少量资金，从而阻止他们盗窃的企图。但是，如果远程节点接受 HTLC，一旦成功，HTLC 将向他们付款，那么无论如何，他们将面临比储备金更多的风险。如果不成功，他们的余额将恢复到之前的金额，该金额将高于储备金。

    这是对资金滞留问题的缓解措施，资金滞留问题发生在一笔付款的手续费承担方需要支付比其当前可用余额更多的价值时，即使他们可能是接收付款的一方，也会发生这种情况。有关此问题的先前讨论，见[周报 #85][news85 stuck funds]. {% assign timestamp="1:39:20" %}

- [BTCPay Server 97e7e][]开始为[payjoin][topic payjoin]支付设置[BIP78][]`minfeerate`(最小费率)参数。另请参阅导致此提交的[错误报告][btcpay server #4689]。{% assign timestamp="1:41:56" %}

- [BIPs #1446][]对比特币相关协议的[schnorr 签名][topic schnorr signatures]的[BIP340][]规范进行了小改动和一些补充。此更改允许对消息进行任意长度的签名；以前版本的 BIP 要求消息正好为 32 个字节。描述对 Libsecp256k1 库的相关更改请见 [周报 #157][news157 libsecp]。此更改对共识应用程序中 BIP340 的使用没有影响，因为与[taproot][topic taproot]和[tapscript][topic tapscript] (分别为，BIPs[341][bip341] and [342][bip342])一起使用的签名使用 32 字节消息。

    新增内容描述了如何有效地使用任意长度的消息，推荐了如何使用散列标记前缀，并提供了在不同域中使用相同的密钥（例如签署交易或签署纯文本消息）时提高安全性的建议。 {% assign timestamp="1:43:15" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="27469,27626,25796,2668,2666,4689,1446" %}
[policy series]: /en/blog/waiting-for-confirmation/
[bitcoin core 25.0]: https://bitcoincore.org/bin/bitcoin-core-25.0/
[1ml stats]: https://1ml.com/statistics
[arc specs]: https://github.com/ark-network/specs
[keceli ark]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021694.html
[keceli reply0]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021720.html
[harding reply0]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021721.html
[harding reply1]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021714.html
[stone reply]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021708.html
[dryja reply]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021713.html
[jk_14]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021717.html
[jager nostr]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021700.html
[jager video]: https://twitter.com/joostjgr/status/1658487013237211155
[news85 stuck funds]: /en/newsletters/2020/02/19/#c-lightning-3500
[btcpay server 97e7e]: https://github.com/btcpayserver/btcpayserver/commit/97e7e60ceae2b73d63054ee38ea54ed265cc5b8e
[news157 libsecp]: /en/newsletters/2021/07/14/#libsecp256k1-844
[bcc rn]: https://bitcoincore.org/en/releases/25.0/
[news252 incentives]: /zh/newsletters/2023/05/24/#等待确认-2激励
[morcos limits]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2015-October/011401.html
