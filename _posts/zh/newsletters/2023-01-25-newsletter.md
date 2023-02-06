---
title: 'Bitcoin Optech Newsletter #235'
permalink: /zh/newsletters/2023/01/25/
name: 2023-01-25-newsletter
slug: 2023-01-25-newsletter
type: newsletter
layout: newsletter
lang: zh
---

本周的周报总结了一份比较 “临时锚点（ephemeral anchors）” 提议与曾经的 `SIGHASH_GROUP` 提议的分析性提议，并传达了请求研究员们研究如何为闪电网络 “异步支付（async payment）” 创建支付证据的呼吁。此外还有我们的常规栏目：Bitcoin Stack Exchange 上的热门问答总结；流行的比特币基础设施软件的显著变更简介。

## 新闻

- **<!--ephemeral-anchors-compared-to-sighashgroup-->对比临时锚点和 `SIGHASH_GROUP`**：Anthony Towns 在 Bitcoin-Dev 邮件组中[发帖][towns e-vs-shg]，给出了一项对最近的[临时锚点][topic ephemeral anchors]提议和以往的 [`SIGHASH_GROUP` 提议][`sighash_group` proposal] 的比较性分析。`SIGHASH_GROUP` 允许一个输入指定自己花费到哪几个输出，不同的输入可以指明不同的输出，只要互不重叠即可。在两个乃至多个输入使用预签名交易的时候，这个特性将极大地便利于为交易添加手续费。这些交易的预先签名特性，使其有可能需要在需要上链时、手续费率变得更明确时添加手续费，而现有的 `SIGHASH_ANYONECANPAY` 和  `SIGHASH_SINGLE` 标签在多输入交易中都不够灵活，因为它们只能覆盖单个输入或者单个输出。

    临时锚点提议近似于 “[手续费赞助][topic fee sponsorship]” 提议，让任何人都能利用 “[CPFP][topic cpfp]（子为父偿）” 方法为交易追加手续费。因此被追加手续费的交易本身可以不携带交易费。因为任何人都可以使用临时锚点为一笔交易追加手续费，所以这种机制也可以用来为多输入的预签名交易支付手续费（而这就是 `SIGHASH_GROUP` 的目标。
    
    `SIGHASH_GROUP` 依然拥有两大优势：其一，它允许[组合][topic payment batching]多笔互无关联的预签名交易，这可以在整体上缩减交易的体积、降低用户的开销并提供网络的吞吐量。其次，它不需要子交易，所以可以进一步降低开销和提高容量。
    
    Towns 的结论是：临时锚点提议依赖于[v3 交易转发策略][topic v3 transaction relay]，捕捉到了`SIGHASH_GROUP` 的绝大部分好处，并且显然比 `SIGHASH_GROUP` 更易于进入生产环境，因为后者还需要软分叉共识变更。

- **<!--request-for-proof-that-an-async-payment-was-accepted-->呼吁为送达的异步支付提供支付证明**：Valentine Wallact [发帖][wallace pop]到 Lightning-Dev 邮件组中，呼吁研究者们探索如何让发起[异步支付][topic async payments]的付款方能够收到支付证据。在传统的闪电支付中，收款方先创建一个秘密值，并用哈希函数取得该秘密指的摘要；该摘要会放在一个签好名的发票中，交给支付者；支付者使用 “哈希时间锁合约（[HTLC][topic htlc]）” 为任何能够揭晓那个秘密指的人支付。而揭开的秘密值就证明了支付者已经为签名发票中的摘要支付过了。

    相反，异步支付会在接受者离线时送达，所以他们没法揭晓秘密值，因此也无法在当前的闪电网络模式中产生支付证据。Wallace 请呼吁研究者们探索如何让异步支付获得支付证据，不论是在当前的基于 HTLC 的系统中，还是在为了升级为 “点时间锁合约（[PTLCs][topic ptlc]）” 的系统中。

## Bitcoin Stack Exchange 网站的精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 的贡献者们寻找答案的首选之地，也是他们在有闲暇时会帮助好奇和困惑用户的地方。在这个月度栏目中，我们会举出自上次出刊以来的一些高赞问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--bitcoin-core-signing-keys-were-removed-from-repo-what-is-the-new-process-->Bitcoin Core 软件的签名密钥已经从代码库中移除了。那么用户需要使用什么样的新方法来验证软件未遭篡改呢？]({{bse}}116649) Andrew Chow 解释道，虽然签名密钥已经从 Bitcoin Core 代码库中[移除][remove builder keys]了，但现在一个密钥清单放到了 [guix.sigs repository][guix.sigs repo] 中；这是一个存储 [guix][topic reproducible builds] 版本认证的库。
- [<!--why-doesnt-signet-use-a-unique-bech32-prefix-->为什么 signet 不使用一种唯一的 bech32 前缀？]({{bse}}116630) Casey Rodarmor 好奇为什么 testnet（测试网）和[signet][topic signet]（使用签名出块的专门测试网）都使用 `tb1` 作为[地址前缀][wiki address prefixes]。[BIP325][] 的作者之一 Kalle 解释道，虽然 signet 一开始使用了不同的地址前缀，但人们认为使用相同的前缀将简化对这个另类测试网络的使用。
- [<!--arbitrary-data-storage-in-witness-->任意的数据都可以放在输入 witness 中吗？]({{bse}}116875) GedGrittyBrick 指出近期有多笔 P2TR 交易（[其中之一][large witness tx]）都携带了大量的 witness（见证数据）。其他用户指出，Ordinals 项目提供了一项在比特币交易的 witness 字段中加入任意数据的服务，比如上述交易就插入了[这张图片][ordinals example]。
- [<!--why-is-the-locktime-set-at-transaction-level-while-the-sequence-is-set-at-input-level-->为什么时间锁时在交易层面设定的、而 sequence 是在输入层面设定的？]({{bse}}116706) RedGrittyBrick 提供了关于`nSequence` 和 `nLockTime` 字段的早期历史背景，Pieter Wuille 继续解释了这些[timelock][topic timelocks]字段的含义的演化过程。
- [<!--bls-signatures-vs-schnorr-->BLS 签名对比 Schnorr 签名]({{bse}}116551) Piter Wuille 对比了 BLS 签名和 [schnorr][topic schnorr signatures] 签名背后的密码学假设，评论了它们在验证时间上的差异，并指出了围绕 BLS [多签名][topic multisignature]的复杂性以及 BLS 缺乏对[适配器签名][topic adaptor signatures]的支持。
- [<!--why-exactly-would-adding-further-divisibility-to-bitcoin-require-a-hard-fork-->为什么给比特币进一步增加可分割性需要硬分叉？]({{bse}}116584) Pieter Wuille 解释了 4 种可以在交易中启用小于聪的可分割性的软分叉方法：
1. 带有公式规则变更的 [强制软分叉][forced soft fork]，要求所有新交易都兼容新规则。
  2. 单向的扩展区块，将遵循新规则的交易独立出来放在扩展区块中，类似于方法 1。但依然允许传统类型的交易存在。
  3. 双向的扩展区块，类似于方法 2，但允许使用了新规则的资金返回成传统形态。
  4. 依然使用当前的公式规则，但为了兼容旧节点，将小于聪的数额截断、存储在交易的其它部分。

## 重大的文档和代码变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo] 和 [Lightning BOLTs][bolts repo]。*

- [Bitcoin Core #26325][] 优化了 `scanblocks` RPC 方法的结果，它通过二次测试消除了假阳性。`scanblocks` 可以用来发现包含了跟某些描述符相关的交易的区块。因为利用过滤器的扫描可能会错误地给出一些并不包含相关交易的区块，这个 PR 在二次测试中验证一次测试给出的每一个结果，以检查给出的区块是否真的对应于传入的描述符，检查后再输出结果。出于性能上的理由，在调用 RPC 时使用 `filter_false_positive` 标签才会启用二次测试。
- [Libsecp256k1 #1192][] 升级了这个库的全面测试（exhaustive tests）。通过将 secp256k1 曲线的参数 `B` 改为其它数值，有可能发现另一个曲线群，既能兼容 libsecp256k1，但又比 secp256k1 曲线的阶数（大约是 2<sup>256</sup>）小得多。在这些对安全密码学无用的微型群上，可以在每一种可能的签名上全面地测试 libsecp256k1 的逻辑。这个 PR 在现有的大小为 13 和 199 的群以外增加了一个大小为 7 的群，虽然密码学家首先必须弄清楚这些群的朴素代数特性，因为这些特性曾经导致对这些群的简单搜索算法并不总能成功。13 依然是默认的大小。
- [BIPs #1383][] 将 [BIP329][] 定位为一种钱包标签标准导出格式的提案。与原始提议（见[周报 #215][news215 labels]）相比，主要区别在于将数据格式从 CSV 换成了 JSON。

{% include references.md %}
{% include linkers/issues.md v=2 issues="26325,1383,1192" %}

[news215 labels]: /zh/newsletters/2022/08/31/#wallet-label-export-format
[towns e-vs-shg]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-January/021334.html
[`sighash_group` proposal]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-July/019243.html
[wallace pop]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-January/003820.html
[forced soft fork]: https://petertodd.org/2016/forced-soft-forks
[remove builder keys]: https://github.com/bitcoin/bitcoin/commit/296e88225096125b08665b97715c5b8ebb1d28ec
[guix.sigs repo]: https://github.com/bitcoin-core/guix.sigs/tree/main/builder-keys
[wiki address prefixes]: https://en.bitcoin.it/wiki/List_of_address_prefixes
[large witness tx]: https://blockstream.info/tx/a6628f32a5b41b359cfe4ab038ff7c4279118ff601b9eca85eca8a64763db40c?expand
[ordinals example]: https://ordinals.com/tx/a6628f32a5b41b359cfe4ab038ff7c4279118ff601b9eca85eca8a64763db40c
