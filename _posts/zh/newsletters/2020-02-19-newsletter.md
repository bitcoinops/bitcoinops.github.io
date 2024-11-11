---
title: 'Bitcoin Optech Newsletter #85'
permalink: /zh/newsletters/2020/02/19/
name: 2020-02-19-newsletter-zh
slug: 2020-02-19-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 宣布了 C-Lightning 0.8.1 的发布，呼吁协助测试 Bitcoin Core 的维护版本，概述了关于 taproot 与分别实现 MAST 和 schnorr 签名的讨论，总结了在闪电网络通道构建中使用 PoDLEs 的新想法，并重点介绍了隐私增强支付在未公告的闪电网络通道上的新影响。此外，还包括我们常规的有关热门服务、客户端软件和基础设施项目值得注意的变更部分。

## 行动项

- **<!--upgrade-to-c-lightning-0-8-1-->****升级到 C-Lightning 0.8.1：** 此次[发布][cl 0.8.1]增加了多个新特性（包括在下文 *值得注意的变更* 部分中描述的特性），并提供了多项错误修复。详细的更新列表请参见 [changelog][cl changelog]。

- **<!--help-test-bitcoin-core-0-19-1rc2-->****协助测试 Bitcoin Core 0.19.1rc2：** 即将发布的此维护版本 [release][bitcoin core 0.19.1] 包含多项错误修复。我们鼓励有经验的用户协助测试，查找任何回归或其他意外行为。

## 新闻

- **<!--discussion-about-taproot-versus-alternatives-->关于 taproot 与替代方案的讨论：** 一组希望保持匿名的开发者（我们称之为 Anon）撰写了一篇[批评][anon reflowed]，比较了 taproot 与在比特币中实现 MAST 和 schnorr 签名的替代方案。Anon 在批评结尾提出了五个问题，我们在下面使用这些问题来组织 Anon 的关注点和几位比特币贡献者的回复。

  1. {:#tap1} Anon 问道：“taproot 是否真的比单独使用 MAST 和 schnorr 更隐私？与分别使用它们相比，实际的匿名性集收益是什么？”

     Anthony Towns [回复][towns tap]，“是的【更隐私】，假设单公钥单签名仍然是一种常见的授权模式。”Towns 表明，单签名花费当前占所有交易输出的 57% 以上（考虑到 P2SH 包装的 P2WPKH 的频繁使用，实际可能更多）。如果 schnorr 可用，单签名的用户将增加，因为它简化了交互式 n-of-n 多重签名、交互式 k-of-n 门限签名和自适应签名（无脚本脚本），这些在链上看起来就像是单签名花费。

     然而，随着越来越多的人转向多重签名和高级合约，出现了越来越多的实际用例，这些用例大多数情况下可以通过单个签名来满足，但有时仍然需要使用脚本。如果只有 MAST 而没有 taproot，这些用例就需要始终使用 MAST。MAST 也可以用于单签名花费，但这将需要更大的交易和更高的费用，因此单签名用户可能不会使用 MAST。这将在链上分析中造成使用 MAST 的花费与不使用 MAST 的花费之间的明显区别。

     Taproot 通过允许便宜的单签名花费消除了这一区别，这些花费在外观上与那些能够使用单签名但也有备用脚本的用户的花费相同（虽然实际使用备用脚本进行花费时，在链上是可以识别的）。这创造了一个比单独使用 MAST 和 schnorr 更大的匿名集，只要确实有一群人有时使用单个签名进行花费，而有时使用脚本进行花费。

  2. {:#tap2} Anon 问道：“taproot 是否真的比单独使用 MAST 和 schnorr 更便宜？”在邮件的早些时候，Anon 声称，taproot 在密钥路径花费中比 MAST+schnorr 节省 67 字节，但在脚本路径花费中增加了 67 字节。

     Towns 指出 Anon 计算中的一个冗余数据字段，并表明在脚本路径花费情况下，taproot 实际上只增加了大约 33 字节，使得成本效益分析偏向于 taproot。David Harding [指出][harding tap]，额外的大小（相当于 8.25 个虚拟字节）相对于脚本路径花费者为花费 UTXO 需要提供的所有其他数据（如 41 个虚拟字节的输入数据、16 个虚拟字节的签名或各种大小的其他见证、一个或多个 8 个虚拟字节的默克尔节点以及要执行的脚本）来说是非常小的。

  3. {:#tap3} Anon 问道：“考虑到新的加密技术，taproot 是否比单独使用 MAST 和 schnorr 更有风险？”

     Towns 回复道，“我不这么认为；无论哪种方式，大部分风险都在于细节处理得当。[…] 大多数复杂的加密部分都在应用层： [MuSig][topic musig]、门限签名、自适应签名、无脚本脚本等。” 他还链接了几个学习资源供有兴趣的人进一步了解 ([1][taplearn1], [2][taplearn2], [3][taplearn3])。

  4. {:#tap4} Anon 问道：“我们是否可以不遵循 [Nothing Up My Sleeve]<!-- prevent link --> [NUMS][] 点要求，而能够直接检查它是否是一个哈希根？”这是一个要求，即钱包创建并随后发布一个 taproot 内部密钥，即使它只是一个随机曲线点，因为它们从未打算使用密钥路径花费。Anon 的建议本质上是允许花费者跳过发布内部密钥，直接进行脚本路径验证。

     Towns 回复道，“这会大大减少匿名集。”原因是，在花费时，如果不存在内部密钥，就会揭示花费者从未打算使用密钥路径花费，从而将他们的花费与其他可能使用密钥路径的花费区分开来。Towns 进一步指出，不发布内部密钥只会节省 8 个虚拟字节。

     Jonas Nick 和 Jeremy Rubin 分别提供了他们的分析。Nick [总结][nick tap]，“【因为】比特币中的匿名集是永久性的，软件的部署时间通常比任何人预期的要长[…]现实中 taproot 优于【Anon 提出的】优化。”Rubin [得出相反的结论][rubin tap]，更倾向于 Anon 的提议或他自己的替代方案（这仍然会导致相同的隐私损失）。

  5. {:#tap5} Anon 问道：“将多个功能一次性加入比特币的开发模型是否对比特币开发有益？”

     Towns 回复道，“将这些特定更改捆绑在一起【带来了】taproot 的优势”——在使用密钥路径或脚本路径花费方面的灵活性，“密钥路径的使用与不使用 taproot 相比没有成本”，“如果不使用脚本路径，增加一个脚本路径也没有成本”，并且“如果可以在链下交互式验证脚本条件，则始终可以使用密钥路径”。

    讨论没有得出明显的结论。如果有任何进一步值得注意的发展，我们将在未来的 Newsletter 中进行报道。

- **<!--using-podle-in-ln-->****在闪电网络中使用 PoDLE：** 正如 [Newsletter #83][news83 interactive] 中描述的那样，闪电网络开发者正在努力制定一个用于交互式构建资金交易的协议，作为双向资助支付通道和[通道拼接][topic splicing]的步骤之一。双向资助通道设置的一个问题是，有人可以提议与您开设一个通道，了解您的一个或多个 UTXO，然后在签署交易并支付任何费用之前放弃通道设置过程。对此问题的一个建议解决方案是要求通道开启提议包含离散对数等价证明（[PoDLE][]），JoinMarket 使用该方法来避免同类型的无成本 UTXO 泄露攻击。

  本周，Lisa Neigut 发布了她对 PoDLE 交互式资助想法的[分析][neigut podle1]。她还单独[描述了][neigut podle2]一种攻击，攻击者不诚实的 Mallory 等待诚实的 Alice 提交一个 PoDLE，然后利用该 PoDLE 让其他节点将 Alice 列入黑名单。Neigut 提出了一个缓解方案，但 JoinMarket 开发者 Adam Gibson 提出了一种更简洁的替代缓解方案 [gibson podle]。Gibson 的方法要求 PoDLE 对要接收它的节点进行承诺，从而防止它被恶意地重复使用在其他节点上。Gibson 还描述了 JoinMarket 使用 PoDLE 的一些设计决策，并建议闪电网络开发者可以针对闪电网络自身的独特约束使用不同的权衡。

- **<!--decoy-nodes-and-lightweight-rendez-vous-routing-->****诱饵节点和轻量级会合路由：** Bastien Teinturier 先前[发帖][teinturier delink]，讨论了如何打破 [BOLT11][] 发票中包含的数据与接收付款的通道的资金交易之间的联系（见 [Newsletter #82][news82 unannounced]）。在进一步讨论和改进后，Teinturier [指出][teinturier rv]他的方案的一个副作用可能会启用便捷的会合路由——一种隐私增强的支付路由方式，其中接收节点和支付节点彼此之间都不了解对方的网络身份。更多信息请参见 [Teinturier 的方案文档][rv gist]，阅读 [Newsletter #22][news22 rv] 中关于会合路由的先前讨论，并查看周一闪电网络开发者[规范会议][spec meet]中的相关讨论。

## 服务和客户端软件的更改

*在这一月度特色中，我们重点介绍比特币钱包和服务的有趣更新。*

- **<!--btcpay-vault-using-hwi-for-signing-->****BTCPay Vault 使用 HWI 进行签名：** [BTCPay Vault][btcpay vault blog] 是一个桌面应用程序，它使用 [HWI][topic hwi] 协调与各种硬件钱包的交易签名。虽然 BTCPay Server 创建了 BTCPay Vault，但该软件可以重新用于其他应用程序。

- **<!--ckbunker-using-psbts-for-an-hsm-->****CKBunker 使用 PSBTs 作为 HSM：** [CKBunker][coinkite bunker] 允许用户为在线、通过 Tor 启用的 Coldcard 硬件钱包配置基于规则的支出条件。然后，Coldcard 的功能就类似于一个 HSM（硬件安全模块），签署通过 Tor 隐藏服务传送的 [PSBTs][topic psbt]。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的变更。*

- [Bitcoin Core #18104][] 终止了对 Linux 平台上 32 位 x86 二进制文件构建的支持，作为 Bitcoin Core 发布流程的一部分。对应的 Windows 平台 32 位二进制文件几个月前已经被移除（见 [Newsletter #46][news46 win32]）。32 位 Linux 二进制文件仍然在 Bitcoin Core 的持续集成测试中进行构建，用户仍可以手动构建这些文件，但由于使用较少且缺乏开发者的实际测试，项目已停止分发这些二进制文件。

- [C-Lightning #3488][] 标准化了 C-Lightning 对比特币数据的请求，使得可以在 Bitcoin Core 之外使用其他后端运行 C-Lightning。这个拉取请求是一个更大项目的一部分，旨在允许 C-Lightning 与比特币后端的交互更加灵活，如 [C-Lightning #3354][] 中提出的那样。保持后端交互的通用性，允许插件进行标准 RPC 调用、将 RPC 组合成更抽象的方法，甚至创建通知。尽管通过 `bitcoin-cli` 与 `bitcoind` 的交互仍然是默认设置，但该项目正在努力为移动集成提供更多可能性（参见 [C-Lightning #3484][]）或允许用户共享诸如 [esplora][esplora] 实例的[区块浏览器][topic block explorers]，对于那些可能只是[偶尔上线进行通道管理和监控][remyers twitter]的用户。

- [C-Lightning #3500][] 实现了一个简单的解决方案，用于解决可能导致通道卡住的问题，即双方都无法向对方发送资金。[卡住资金问题][bolts #728] 发生在某次付款会导致资助通道的一方负责支付超出其当前余额的更多价值。例如，Alice 资助了一个通道并将她全部可用余额支付给 Bob。此时，Alice 无法再支付更多资金（这是预期的），但 Bob 也无法向 Alice 付款，因为这需要增加承诺交易及其相应费用的大小——这些费用应由资助者（Alice）支付。这使得通道在两个方向上都无法使用。C-Lightning 的合并简单地限制了用户（当他们是资助者时）不能花费所有可用余额，从而提供了一个有效的短期解决方案。另一个替代解决方案在 [C-Lightning #3501][] 中提出，但它仍在等待所有闪电网络实现的维护者之间的进一步讨论结果。

- [C-Lightning #3489][] 允许多个插件附加到 `htlc_accepted` 插件钩子上，并计划未来允许多个插件附加到其他钩子上。对于 `htlc_accepted` 钩子，这使得插件可以拒绝 HTLC、解决 HTLC（即通过返回原像来索赔任何支付）或将 HTLC 传递给下一个绑定到钩子的插件。

- [C-Lightning #3477][] 允许插件注册将在节点的 [BOLT1][bolt1 init] `init` 消息、[BOLT7][bolt7 node announce] `node_announcement` 消息或 [BOLT11][bolt11 featurebits] 发票的功能位字段（字段 `9`）中发送的功能标志。这使得插件可以向其他程序传达其节点可以处理广告的功能。

- [Libsecp256k1 #682][] 移除了 Java 本地接口（JNI）绑定，原因是，“【这些】JNI 绑定需要更多的工作才能继续对 Java 开发者有用，但 libsecp 的维护者和常规贡献者对 Java 并不熟悉。” 拉取请求指出，ACINQ 已知在其项目中使用这些绑定，并维护了一个库的[分支][acinq libsecp]。

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
