---
title: 'Bitcoin Optech Newsletter #85'
permalink: /zh/newsletters/2020/02/19/
name: 2020-02-19-newsletter-zh
slug: 2020-02-19-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 宣布 C-Lightning 0.8.1 发布，请求协助测试 Bitcoin Core 的一个维护版本，总结一场关于 taproot 与分别实现 MAST、schnorr 签名的讨论，介绍在 LN 通道构建中使用 PoDLE 的新想法，并重点介绍针对未公布 LN 通道的隐私增强支付工作所带来的一项新影响。此外还有关于热门服务、客户端软件和基础设施项目值得注意的变更的常规栏目。

## 行动项

- **<!--upgrade-to-c-lightning-0-8-1-->****升级到 C-Lightning 0.8.1：** 此次[发布][cl 0.8.1]增加了多个新特性（包括下文*值得注意的变更*部分中描述的那些），并带来多项错误修复。详细更新列表请参见 [changelog][cl changelog]。

- **<!--help-test-bitcoin-core-0-19-1rc2-->****协助测试 Bitcoin Core 0.19.1rc2：** 即将发布的这一维护[版本][bitcoin core 0.19.1]包含多项错误修复。我们鼓励有经验的用户帮助测试是否存在回归或其他意外行为。

## 新闻

- **<!--discussion-about-taproot-versus-alternatives-->****关于 taproot 与替代方案的讨论：** 一群希望保持匿名的开发者（下文称 Anon）写了一篇[批评文章][anon reflowed]，把 taproot 与在比特币中分别实现 MAST 和 schnorr 签名的其他方案作了比较。Anon 在批评结尾提出五个问题，下面我们就用这五个问题来组织对其疑虑以及几位比特币贡献者回复的总结。

  1. {:#tap1} Anon 问道：“taproot 真的比分别使用 MAST 和 schnorr 更隐私吗？与分别实现相比，匿名集的实际收益是什么？”

     Anthony Towns [回复][towns tap]：“是的（更隐私），前提是单公钥单签名仍是一种常见的授权模式。”Towns 说明，单签花费目前占全部交易输出的 57% 以上（考虑到 P2SH 包装的 P2WPKH 被频繁使用，实际可能更多）。如果 schnorr 可用，能用单签的人只会更多，因为 schnorr 简化了交互式 n-of-n 多重签名、交互式 k-of-n 门限签名和适配器签名（无脚本脚本）的使用，而这些在链上看起来都像单签花费。

     然而，随着越来越多人转向多重签名和高级合约，有越来越多的实际用例在大多数时候只需一个签名就能满足，但有时仍要用到脚本。如果只有 MAST 而没有 taproot，这些用例就不得不始终使用 MAST。MAST 也能用于单签花费，但相比纯粹的单签构造，它需要更大的交易和更多手续费，所以单签用户多半不会用 MAST。这样一来，在链上分析者眼里，用 MAST 的花费和不用 MAST 的花费之间就会出现一道清晰的分界。

     taproot 通过允许廉价的单签花费消除了这道分界：这些花费在外观上与那些能用单签、但也备有备用脚本的用户的花费完全一样（不过真的用备用脚本去花费时，在链上是可识别的）。只要确实存在这样一群人——他们有时用单个签名花费，有时用脚本花费——taproot 就能形成比分别实现 MAST 和 schnorr 更大的匿名集。

  2. {:#tap2} Anon 问道：“taproot 真的比分别使用 MAST 和 schnorr 更便宜吗？”在该邮件较靠前的部分，Anon 声称 taproot 在密钥路径花费上比 MAST+schnorr 省 67 字节，但在脚本路径花费上要多 67 字节。

     Towns 指出 Anon 的计算里有一个冗余数据字段，并说明在脚本路径花费的情况下，taproot 实际上只多出约 33 字节，这使得成本与收益的权衡不对称地偏向 taproot。David Harding [指出][harding tap]，多出来的这点体积（相当于 8.25 vbyte）相对于用脚本路径花费一个 UTXO 时需要提供的其他所有数据（例如 41 vbyte 的输入数据、16 vbyte 的签名或各种大小的其他见证、一个或多个 8 vbyte 的默克尔节点，以及要执行的脚本）来说相当小。

  3. {:#tap3} Anon 问道：“考虑到引入了新的密码学，taproot 是否比分别实现 MAST 和 schnorr 风险更大？”

     Towns 回复说，他“不这么认为；这两者的大部分风险都在于能否把细节做对。……大部分复杂的密码学部分都在应用层：[MuSig][topic musig]、门限签名、适配器签名、无脚本脚本等。”他还给想深入了解的人列了几份资料（[1][taplearn1]、[2][taplearn2]、[3][taplearn3]）。

  4. {:#tap4} Anon 问道：“我们能不能省掉 [Nothing Up My Sleeve]<!-- prevent link --> [NUMS][] 点这一要求，直接检查它是不是一个哈希根？”这项要求是指：钱包要创建并在之后公布一个 taproot 内部密钥，即便那只是个随机曲线点，因为钱包压根没打算用密钥路径花费。Anon 实质上是建议允许付款方跳过公布内部密钥，直接进入脚本路径验证。

     Towns 回复：“那会大幅缩小匿名集。”原因在于，没有内部密钥会在花费时暴露出付款方从未打算使用密钥路径花费，从而把他们的花费和其他本来可以用密钥路径的花费区分开。Towns 还指出，不公布内部密钥只能省下 8 vbyte。

     Jonas Nick 和 Jeremy Rubin 各自给出了分析。Nick [总结][nick tap]：“（因为）比特币里的匿名集是永久的，而软件的部署时间往往比任何人预想的都长……现实中 taproot 优于（Anon 所提议的）那个优化。”Rubin [得出相反的结论][rubin tap]，更倾向于 Anon 的提议或他自己提出的替代方案（后者仍会导致同样的隐私损失）。

  5. {:#tap5} Anon 问道：“一股脑把一堆功能塞进比特币，这种开发模式对比特币开发有好处吗？”

     Towns 回复说，“把这些特定改动捆绑在一起（带来了）taproot 的优势”——在密钥路径或脚本路径花费之间自由选择的灵活性，“密钥路径与不使用 taproot 相比没有任何额外成本”，“如果你最终用不到脚本路径，把脚本路径加进去也不会带来额外成本”，以及“如果你能在链下交互式验证脚本条件，你就随时可以使用密钥路径”。

    讨论没有得出明确结论。今后若有值得注意的新进展，我们会在之后的 Newsletter 中报道。

- **<!--using-podle-in-ln-->****在 LN 中使用 PoDLE：** 如 [Newsletter #83][news83 interactive] 所述，LN 开发者正在为交互式构建注资交易制定协议，这是迈向双向资助支付通道和[通道拼接][topic splicing]的一步。双向资助通道建立过程中的一个问题是：有人可以提议与你开一个通道，得知你的一个或多个 UTXO，然后在签署交易、支付任何手续费之前放弃整个流程。针对这个问题，一个建议的解决办法是要求开通道的提议中包含离散对数等价证明（[PoDLE][]），JoinMarket 正是用它来避免同类的零成本 UTXO 泄露攻击。

  本周，Lisa Neigut 发表了她对把 PoDLE 用于交互式注资的[分析][neigut podle1]。她还另外[描述][neigut podle2]了一种攻击：不诚实的 Mallory 等诚实的 Alice 提交 PoDLE，然后拿它让其他节点把 Alice 列入黑名单。Neigut 提出了一个缓解办法，但 JoinMarket 开发者 Adam Gibson [提出][gibson podle]了一个更紧凑的替代缓解方案。Gibson 的做法要求 PoDLE 承诺到预期接收它的那个节点，从而防止它被恶意拿到其他节点上重复使用。Gibson 还讲述了 JoinMarket 采用 PoDLE 时的一些设计取舍，并就 LN 开发者如何针对 LN 自身的独特约束做出不同的权衡提出了建议。

- **<!--decoy-nodes-and-lightweight-rendez-vous-routing-->****诱饵节点与轻量级会合路由：** Bastien Teinturier 此前[发帖][teinturier delink]，讨论如何切断 [BOLT11][] 发票中包含的数据与将接收这笔支付的通道的注资交易之间的联系（见 [Newsletter #82][news82 unannounced]）。经过进一步讨论和完善，Teinturier [指出][teinturier rv]，他的方案有一个副作用，可能顺带实现便捷的会合路由——一种隐私增强的支付路由方式，收款节点与付款节点双方都无法得知对方网络身份的任何信息。更多信息请参见 [Teinturier 关于该方案的文档][rv gist]，阅读 [Newsletter #22][news22 rv] 中关于会合路由的既往讨论，并查看周一 LN 开发者[规范会议][spec meet]上关于该话题的讨论。

## 服务和客户端软件的变更

*在本月栏目中，我们重点介绍 Bitcoin 钱包与服务的一些有趣更新。*

- **<!--btcpay-vault-using-hwi-for-signing-->****BTCPay Vault 使用 HWI 签名：** [BTCPay Vault][btcpay vault blog] 是一个桌面应用，通过 [HWI][topic hwi] 协调与多种硬件钱包之间的交易签名。虽然 BTCPay Vault 是 BTCPay Server 团队开发的，但该软件可以被改用于其他应用。

- **<!--ckbunker-using-psbts-for-an-hsm-->****CKBunker 用 PSBT 驱动 HSM：** [CKBunker][coinkite bunker] 允许用户为一台在线的、启用了 Tor 的 Coldcard 硬件钱包配置基于规则的支出条件。这样 Coldcard 就起到了 HSM（硬件安全模块）的作用，为通过 Tor 隐藏服务送达的[部分签名比特币交易][topic psbt]（PSBT）签名。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络 BOLT][bolts repo] 中值得注意的变更。*

- [Bitcoin Core #18104][] 在 Bitcoin Core 的发布流程中不再支持为 Linux 构建 32 位 x86 二进制文件。对应的 Windows 32 位二进制文件几个月前就已移除（见 [Newsletter #46][news46 win32]）。32 位 Linux 二进制文件仍会在 Bitcoin Core 的持续集成测试中构建，用户也仍可自行构建，但由于使用量小、缺少开发者动手测试，项目已不再分发这些二进制文件。

- [C-Lightning #3488][] 把 C-Lightning 请求比特币数据的方式标准化，使 C-Lightning 可以跑在 Bitcoin Core 之外的其他后端上。这个 PR 属于一个更大的项目，目的是让 C-Lightning 与比特币后端的交互方式更自由，正如 [C-Lightning #3354][] 所提议的那样。保持后端交互的通用性，可以让插件发起标准 RPC 调用、把多个 RPC 组合成更抽象的方法，甚至创建通知。虽然通过 `bitcoin-cli` 与 `bitcoind` 交互仍是默认方式，但这个项目正努力为移动端集成打开可能性（参见 [C-Lightning #3484][]），或让那些只是[偶尔上线做通道管理和监控][remyers twitter]的用户可以共用一个 [esplora][esplora] 实例这类[区块浏览器][topic block explorers]。

- [C-Lightning #3500][] 针对一个可能让通道卡死、双方都无法向对方发送资金的问题，实现了一个简单的解决办法。[卡住资金问题][bolts #728]出现在某笔支付会导致为通道出资的一方所需承担的价值超过其当前余额之时。例如，Alice 出资开了通道，并把自己的全部可用余额付给 Bob。此时 Alice 无法再支出（这在预期之内），但 Bob 也无法付给 Alice，因为那需要增大承诺交易及其对应手续费的规模——而这些手续费要由出资方 Alice 承担。于是通道两个方向都用不了了。C-Lightning 合并的改动只是简单地限制用户（在作为出资方时）花光自己的全部可用余额，作为一个有效的短期修补。[C-Lightning #3501][] 中还提出了另一种解决方案，但它要等所有 LN 实现维护者进一步讨论后再定。

- [C-Lightning #3489][] 允许把多个插件挂到 `htlc_accepted` 插件钩子上，并计划今后允许把多个插件挂到其他钩子上。对于 `htlc_accepted` 钩子，这使得插件可以拒绝该 HTLC、了结该 HTLC（即返回原像以领取相应支付），或者把该 HTLC 交给挂在这个钩子上的下一个插件。

- [C-Lightning #3477][] 允许插件注册特性标志，这些标志会随节点的 [BOLT1][bolt1 init] `init` 消息、[BOLT7][bolt7 node announce] `node_announcement` 消息，或 [BOLT11][bolt11 featurebits] 发票的 feature bits 字段（字段 `9`）一起发出。这让插件可以向其他程序表明，自己的节点能够处理所公布的那些特性。

- [Libsecp256k1 #682][] 移除了 Java 原生接口（JNI）绑定，理由是“（这些）JNI 绑定需要多得多的工作才能继续对 Java 开发者有用，而 libsecp 的维护者和常规贡献者对 Java 并不太熟悉。”该 PR 指出，据知 ACINQ 在其项目中使用了这些绑定，并自行维护了这个库的一个[分叉][acinq libsecp]。

{% include references.md %}
{% include linkers/issues.md issues="18104,3488,3354,3484,3500,3489,3477,682,728,3501" %}
[bitcoin core 0.19.1]: https://bitcoincore.org/bin/bitcoin-core-0.19.1/
[cl 0.8.1]: https://github.com/ElementsProject/lightning/releases/tag/v0.8.1
[news83 interactive]: /zh/newsletters/2020/02/05/#interactive-construction-of-ln-funding-transactions
[podle]: /zh/newsletters/2020/02/05/#podle
[news82 unannounced]: /zh/newsletters/2020/01/29/#breaking-the-link-between-utxos-and-unannounced-channels
[news22 rv]: /zh/newsletters/2018/11/20/#hidden-destinations
[news46 win32]: /zh/newsletters/2019/05/14/#bitcoin-core-15939
[anon reflowed]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-February/017618.html
[towns tap]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-February/017622.html
[harding tap]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-February/017621.html
[taplearn1]: https://github.com/bitcoin-core/secp256k1/pull/558
[taplearn2]: https://github.com/apoelstra/taproot
[taplearn3]: https://github.com/ajtowns/taproot-review
[nick tap]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-February/017625.html
[rubin tap]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-February/017629.html
[neigut podle1]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-February/002516.html
[neigut podle2]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-February/002517.html
[gibson podle]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-February/002522.html
[teinturier delink]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-January/002435.html
[teinturier rv]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-February/002519.html
[rv gist]: https://gist.github.com/t-bast/9972bfe9523bb18395bdedb8dc691faf
[acinq libsecp]: https://github.com/ACINQ/secp256k1/tree/jni-embed/src/java
[bolt1 init]: https://github.com/lightningnetwork/lightning-rfc/blob/master/01-messaging.md#the-init-message
[bolt7 node announce]: https://github.com/lightningnetwork/lightning-rfc/blob/master/07-routing-gossip.md#the-node_announcement-message
[bolt11 featurebits]: https://github.com/lightningnetwork/lightning-rfc/blob/master/11-payment-encoding.md#feature-bits
[nums]: https://en.wikipedia.org/wiki/Nothing-up-my-sleeve_number
[spec meet]: http://www.erisian.com.au/meetbot/lightning-dev/2020/lightning-dev.2020-02-17-19.06.log.html#l-239
[cl changelog]: https://github.com/ElementsProject/lightning/blob/v0.8.1/CHANGELOG.md#081---2020-02-12-channel-to-the-moon
[esplora]: https://github.com/blockstream/esplora
[remyers twitter]: https://twitter.com/remyers_/status/1226838752267468800
[btcpay vault blog]: https://blog.btcpayserver.org/btcpay-vault/
[coinkite bunker]: http://ckbunker.com/
