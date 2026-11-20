---
title: 'Bitcoin Optech Newsletter #51'
permalink: /zh/newsletters/2019/06/19/
name: 2019-06-19-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
slug: 2019-06-19-newsletter-zh
---
本周的 Newsletter 呼吁大家参与测试 LND 与 C-Lightning 的候选版本，介绍如何用 ECDH 实现无需协调的 LN 支付，概述一项在 LN 路由回复中加入延迟信息的提议，并摘述前不久在阿姆斯特丹举行的“Breaking Bitcoin”会议上几场有趣的演讲。常规章节照旧包括 bech32 发送支持，以及热门比特币基础设施项目中的值得注意的变更。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- **<!--help-test-c-lightning-and-lnd-rcs-->****帮助测试 C-Lightning 和 LND 的候选版本：** [C-Lightning][cl rc] 和 [LND][lnd rc] 都在测试下一个版本的候选版本（RC）。鼓励这两个程序的经验用户帮助测试 RC，以便在最终发布前识别并修复任何剩余的错误。

## 新闻

- **<!--using-ecdh-for-uncoordinated-ln-payments-->****使用 ECDH 实现无需协调的 LN 支付：** Stephan Snigirev 在一个[帖子][snigirev post]里向 LN 开发邮件列表提出了两个想法。第一个想法是复用协议中已有的部分来实现*自发支付*，即 Alice 无需向 Bob 索取发票就能付款。正如 [Newsletter #30][] 所述，目前为 LND 提出的做法是：Alice 选一个原像，用 Bob 的密钥加密，塞进 LN 路由数据包里一段本来不用的位置，同时支付该原像的哈希。Bob 收到加密的原像后将其解密并释放出来，从而领取这笔付款。

  Snigirev 的想法省掉了“把加密后的原像一路路由过去”这一步。他指出，从 Alice 到 Bob 路由一笔支付，本身已要求双方拥有同一个共享秘密（用椭圆曲线迪菲-赫尔曼（ECDH）派生）。把这个秘密哈希一次，就得到一个双方都知道的唯一原像；再把这个原像哈希一次，就是支付哈希。用这套机制时，只要 Bob 收到一笔付给某个哈希的付款、而他自己并没有为该哈希创建过发票，他就直接算出该会话共享秘密的双重哈希，看是否对得上。若对得上，他再生成那次单次哈希并领取付款。C-Lightning 开发者 Christian Decker 已编写了一个[概念验证][decker spontaneous]补丁和插件，用于 C-Lightning 实现这一功能。

  Snigirev 的第二个想法让离线设备（比如自动售货机）能生成一张独一无二的 LN 发票，在线用户付款后，由另一个懂得如何生成原像的在线节点代表该离线设备领取付款。这样付款方就会收到原像作为付款凭据，再把凭据出示给离线设备，换取对方承诺的商品或服务——比如从自动售货机拿一罐饮料。这同样使用了通过 ECDH 派生的共享秘密——但在这种情况下，秘密是在生成发票的离线设备和最终接收支付的在线节点之间共享的。有关协议详情，请参见 Snigirev 的帖子。

- **<!--authenticating-messages-about-ln-delays-->****对 LN 延迟消息进行认证：** LN 中一笔支付失败时，发起支付的节点往往能从造成这次失败的两个节点之一收到一条经过认证的消息。这允许支付节点将这两个节点之间的通道标记为不可靠，并在未来支付中选择其他通道。但 LND 开发者 Joost Jager 在 LN 开发邮件列表中[指出][jager delays]，“非理想支付尝试也可能是成功的支付，只是接收成功消息的时间过长。”他提议每个节点在将消息传递回支付节点时，向消息中添加两个时间戳，一个是节点提议路由支付的时间戳，另一个是节点得知支付失败或成功的时间戳。这将使支付节点能够确定支付路由过程中延迟发生的位置，并在未来避免这些通道。

  为防止路径上的某些节点对其他节点撒谎，他建议用消息认证码保护错误消息和时间戳。这也可以防止中间节点损坏来自端点节点的加密错误消息。

  Jager 的提案还讨论了如何在当前路由协议中实现这种类型的系统，以及如何解决与路由隐私相关的担忧。到目前为止，这一提案在邮件列表中已引起了适度的积极讨论。

## Breaking Bitcoin

[Breaking Bitcoin][bb website] 是一个比特币技术会议，上周末在阿姆斯特丹举行。比特币协议开发者和应用工程师都有很多人到场。[周六][bb sat video]和[周日][bb sun video]的视频已发布，比特币开发者 Bryan Bishop (kanzure) 也提供了几份[演讲记录][bb transcripts]。

以下演讲可能会特别引起 Bitcoin Optech Newsletter 读者的兴趣：

- **<!--breaking-bitcoin-privacy-->**[**破解比特币隐私**][bb belcher video] - coinjoin 实现 Joinmarket 的创建者 [Chris Belcher][] 概述了比特币的隐私现状。Belcher 之前写过一篇关于隐私的[文献综述][belcher privacy review]，在这场通俗易懂的演讲里，他涉及了综述中的许多主题。他首先解释了为什么隐私在比特币中很重要，描述了链分析公司用于链接比特币地址和交易的一些常用启发法，并演示了 coinjoin 和 payjoin 如何打破这些启发法、挫败链分析。最后他谈到，像 LN 这样的二层技术能把泄露隐私的数据从区块链上移走，因而有望改善隐私。（[演讲记录][bb belcher transcript]）。

- **<!--bitcoin-build-system-security-->**[**比特币构建系统的安全性**][bb dong video] - Chaincode Labs 工程师 [Carl Dong][] 用一段预先录制的演讲介绍了 Bitcoin Core 的构建安全，随后通过视频连线回答观众提问。他的演讲回应了这样一个问题：“如果我从 bitcoincore.org 下载一个 Bitcoin Core 可执行文件，我怎么知道自己运行的到底是什么代码？”Bitcoin Core 项目目前用可复现的 [gitian][] 构建来保证编译出的二进制文件确实对应那份源代码，但 Dong 解释说_光有可复现性还不够_——如果可复现构建所用的工具链本身依赖预编译的二进制文件，那么这些工具链二进制就可能已被攻破，并被用来在最终编译产物中神不知鬼不觉地植入恶意代码。Dong 接着介绍了_可复现_且_可自举_的构建：把工具链中用到的预编译二进制减少到最低限度；他还汇报了自己把 [guix][]（读作“geeks”）构建引入 Bitcoin Core、以尽量减少对构建工具链之信任的进展。（[演讲记录][bb dong transcript]）。

- **<!--secure-protocols-on-bip-taproot-->**[**bip-taproot 上的安全协议**][bb nick video] - Blockstream 工程师 [Jonas Nick][] 更新了他和同事们使用 schnorr 签名和 taproot 结构构建安全协议的一些工作进展。他首先解释了提议的 [bip-taproot][] 如何工作（[更多背景信息][bg taproot]），然后解释了使用 schnorr/taproot 构建协议时的一些实际考虑：不能通过 nonce 偏差泄露私钥的外部签名器、使用 MuSig 进行的密钥聚合和门限签名，以及盲 schnorr 签名。随着 schnorr/taproot 提案的发展并（可能）接近激活，希望利用该提案提供的新功能的公司需要考虑构建安全产品和协议的这些实际方面。（[演讲记录][bb nick transcript]）。

- **<!--extracting-seeds-from-hardware-wallets-->**[**从硬件钱包中提取种子**][bb guillemet video] - Ledger CSO [Charles Guillemet][] 做了一场令人大开眼界的演讲，讲的是市面上好几款硬件钱包的安全问题。他既谈到了自己和团队此前已经公开的漏洞，也谈到了一些新的漏洞——为了保护用户，他没有公开具体手法。这些攻击综合运用了物理接触、侧信道，以及利用不安全的密码学实现等手段。对任何从事硬件钱包相关工作、或者用硬件钱包保护自己比特币的人来说，这场演讲都值得一听。（[演讲记录][bb guillemet transcript]）。

- **<!--cryptographic-vulnerabilities-in-threshold-wallets-->**[**门限钱包中的密码学漏洞**][bb shlomovits video] - schnorr 签名的最受期待的方面之一是实现密钥聚合和门限签名方案的能力。使用目前在比特币中使用的 ECDSA 签名算法也可以实现类似的方案（尽管实现起来复杂得多）。ZenGo 联合创始人 [Omer Shlomovits][] 介绍了其中一些 ECDSA 密钥聚合和门限签名方案，并展示了由于在优化算法时的错误假设，这些方案的许多实现包含了漏洞。（无演讲记录可用）。

## Bech32 发送支持

*这是 [bech32 系列][bech32 series] 24 周中的第 14 周，该系列讲的是如何让你付款的对象享受到 segwit 的全部好处。*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/zh/14-security.md %}

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和[比特币改进提案（BIPs）][bips repo]中的值得注意的变更。*

- [Bitcoin Core #15024][] 允许 `importmulti` RPC 使用[输出脚本描述符][output script descriptors]派生特定的私钥，然后导入所得的密钥。

- [Bitcoin Core #15834][] 修复了 [#14897][Bitcoin Core #14897] 中引入的交易中继错误，该错误导致节点有时尽管与其他节点有良好的连接，却停止接收任何新的内存池交易（参见 [Newsletter #43][news43 merges] 了解详细信息和之前的缓解措施，或 [#15776][Bitcoin Core #15776] 了解有关此错误及最初提议的解决方案的优秀描述）。

- [LND #3133][] 添加了对“利他”瞭望塔和客户端的支持。瞭望塔代表当前离线的客户端发送违约补救交易（正义交易），以确保这些客户端的对手方无法窃取任何资金。适合普遍部署的理想瞭望塔，靠“发送补救交易可获适度金钱回报”来形成激励，但管理这种激励会增加复杂性——因此该完整系统的初始版本使用了更简单的利他瞭望塔，这些瞭望塔不会通过协议获得任何奖励，但仍然提供了完整的客户端和服务器组件以实现完全的强制执行。你可以为自己的通道设置一个瞭望塔，或者你可以使用可靠朋友的瞭望塔。LND 的运行时帮助文档中记录了所有必要的配置参数。开发者 Will O'Beirne 还提供了一个[示例教程][watchtower tutorial]，帮你搭好瞭望塔、尝试对一条测试通道发起违约，再观察瞭望塔如何保住该通道的资金。

- [LND #3140][] 让 LND 在用自己一个或多个链上 UTXO 发送清扫交易时，支持 RBF 与子为父付（CPFP）两种手续费追加方式。

- [LND #3134][] 允许用户将 LND 与 [Prometheus][] 监控解决方案集成，以收集统计数据和发送警报。

- [C-Lightning #2672][] 添加了可以使用外部钱包资金开设通道的新 RPC。`fundchannel_start` RPC 启动与指定节点开设新通道，并返回一个 bech32 地址，外部钱包应使用*仅包含 segwit 输入且不广播交易*的方式支付该地址。当该交易已创建时，其序列化形式可以提供给 `fundchannel_complete` RPC 以安全完成通道协商并广播交易。或者，可以调用 `fundchannel_cancel` RPC 以在资金发送前中止通道设置。由于大多数外部钱包会自动广播交易，因此这些选项需要通过配置选项显式启用——但它们使得外部钱包可以更好地直接与 C-Lightning 集成。

- [C-Lightning #2700][] 限制了请求 gossip 的数量，仅从节点的部分对等方请求 gossip。鉴于网络已扩展到数千个对等节点，这也延续了各大 LN 实现共同推进的工作——减少通过 gossip 发送的数据量。

- [C-Lightning #2699][] 为 `fundchannel` RPC 新增 `utxo` 参数，允许用户指定用 C-Lightning 内置钱包中的哪个 UTXO 为新通道注资。

- [C-Lightning #2696][] 添加了一个新的 `listtransactions` RPC 方法，该方法列出了程序创建的所有链上交易及其用途（建通道、单方关闭、双方关闭或防作弊）。此 PR 中的其他更改确保了所有必要数据都存储在数据库中，以提供这些结果。

- [Eclair #1009][] 允许 Eclair 搜索通过 gossip 传播的节点公告，以通过其公钥找到通道对等方的 IP 地址，以防任何对等方断开连接且其 IP 地址发生变化。

- [BIPs #555][] 新增 [BIP136][]，定义用 bech32 编码的区块链内交易位置。例如，链中第一个交易的位置标识符（创世区块的生成交易）是 `tx1:rqqq-qqqq-qmhu-qhp`。这一想法首次在两年前[提议][bech32 pos ref]给 Bitcoin-Dev 邮件列表，建议的使用场景包括识别哪些交易包含对第三方应用程序有用的信息，例如时间戳的去中心化身份引用。

{% include linkers/issues.md issues="15024,2696,1009,15834,3133,3140,3134,2700,2699,555,2672,14897,15776" %}
[bech32 series]: /zh/bech32-sending-support/
[bech32 pos ref]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2017-May/014396.html
[news43 merges]: /zh/newsletters/2019/04/23/#值得注意的代码与文档变更
[cl rc]: https://github.com/ElementsProject/lightning/tags
[lnd rc]: https://github.com/LightningNetwork/lnd/releases
[snigirev post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-June/002009.html
[ecdh]: https://en.wikipedia.org/wiki/Elliptic-curve_Diffie%E2%80%93Hellman
[decker spontaneous]: https://github.com/cdecker/lightning/tree/stepan-pay
[jager delays]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-June/002015.html
[bb website]: https://breaking-bitcoin.com/
[bb sat video]: https://www.youtube.com/watch?v=DKOG0BQMmmg
[bb sun video]: https://www.youtube.com/watch?v=DqhxPWsJFZE
[bb transcripts]: http://diyhpl.us/wiki/transcripts/breaking-bitcoin/2019/
[bb belcher video]: https://youtu.be/DKOG0BQMmmg?t=8266
[Chris Belcher]: https://twitter.com/chris_belcher_
[belcher privacy review]: https://en.bitcoin.it/wiki/Privacy
[bb belcher transcript]: http://diyhpl.us/wiki/transcripts/breaking-bitcoin/2019/breaking-bitcoin-privacy/
[bb dong video]: https://youtu.be/DKOG0BQMmmg?t=19828
[Carl Dong]: https://twitter.com/carl_dong
[gitian]: https://gitian.org/
[guix]: https://www.gnu.org/software/guix/
[bb dong transcript]: http://diyhpl.us/wiki/transcripts/breaking-bitcoin/2019/bitcoin-build-system/
[bb nick video]: https://youtu.be/DKOG0BQMmmg?t=21860
[Jonas Nick]: https://twitter.com/n1ckler
[bg taproot]: /zh/newsletters/2019/05/14/#taproot-和-tapscript-提案-bip-概述
[bb nick transcript]: http://diyhpl.us/wiki/transcripts/breaking-bitcoin/2019/secure-protocols-bip-taproot/
[bb guillemet video]: https://youtu.be/DqhxPWsJFZE?t=9534
[Charles Guillemet]: https://twitter.com/p3b7_
[bb guillemet transcript]: http://diyhpl.us/wiki/transcripts/breaking-bitcoin/2019/extracting-seeds-from-hardware-wallets/
[bb shlomovits video]: https://youtu.be/DqhxPWsJFZE?t=15879
[Omer Shlomovits]: https://twitter.com/OmerShlomovits
[watchtower tutorial]: https://github.com/wbobeirne/watchtower-example
[prometheus]: https://prometheus.io/
[pos ref anchor]: https://github.com/bitcoin/bips/pull/555#issuecomment-315517707
[newsletter #30]: /zh/newsletters/2019/01/22/#pr-opened-for-spontaneous-ln-payments
[output script descriptors]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
