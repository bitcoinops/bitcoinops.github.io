---
title: 'Bitcoin Optech Newsletter #120'
permalink: /zh/newsletters/2020/10/21/
name: 2020-10-21-newsletter-zh
slug: 2020-10-21-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 提供了新的 MuSig2 论文概述，汇总了关于 LN 预付费的进一步讨论，并描述了一个简化 LN 支付管理的提案。此外，还包括常规部分：客户端和服务的显著改进总结、发布与候选发布的公告，以及对流行比特币基础设施软件的更改。

## 行动项

*本周无。*

## 新闻

- **<!--musig2-paper-published-->****MuSig2 论文发布：** Jonas Nick、Tim Ruffing 和 Yannick Seurin 发布了 [MuSig2 论文][musig 2 paper]，描述了一种新的 [MuSig][topic musig] 签名方案变体，该方案采用了两轮签名协议。

  MuSig 是一种签名方案，允许多个签名者通过各自的私钥创建一个聚合公钥，然后协作生成该公钥的单一有效签名。聚合公钥和签名与任何其他 [Schnorr][topic schnorr signatures] 公钥和签名在外观上是无法区分的。

  MuSig 的原始版本需要三轮签名协议：首先，共签名者交换 nonce 值的承诺，然后交换 nonce 值，最后交换部分签名。没有这三轮协议，攻击者可能会在多个并发签名会话中与诚实的签名者交互，获取该诚实签名者不愿签署的消息的签名。

  使用确定性 nonce 在单一签名方案中很常见，但在多签名方案中是不安全的，正如[原始 MuSig 博客文章][musig blog post unsafe deterministic nonce]中描述的那样。提前预计算 nonce 并在密钥设置时交换它们也是不安全的，正如 Jonas Nick 的[博客文章][unsafe nonce sharing]中所述。然而，将 nonce 提前计算并在早期交换 nonce 承诺是安全的，这将三轮中的一轮移到密钥设置阶段。

  移除交换 nonce 承诺的要求一直是一个活跃的研究领域，上个月发布的 [MuSig-DN 论文][musig-dn]展示了如何通过使用签名者的公钥和消息来确定性地生成 nonce 并提供一个非交互式零知识证明，从而移除 nonce 承诺交换的需求，代价是签名操作的成本增加。

  新的 MuSig2 方案实现了无需零知识证明的简单两轮签名协议。更重要的是，第一轮（nonce 交换）可以在密钥设置时完成，从而支持以下两种变体：

  - 交互式设置（密钥设置和 nonce 交换）和非交互式签名

  - 非交互式设置（从公钥计算地址）和交互式签名（nonce 交换后交换部分签名）

  非交互式签名变体对冷存储方案和离线签名者特别有用，也对 LN 等离链合同协议有帮助，nonce 可以在通道设置时交换。

- **<!--more-ln-upfront-fees-discussion-->****LN 预付费讨论更新：** 在[上周的讨论][news119 upfront]之后，Joost Jager 在 Lightning-Dev 邮件列表中要求开发者再次[考虑][jager hold fees]如何收取路由支付尝试的费用——即使尝试失败也要支付的费用。这可能有助于缓解阻止节点赚取路由费的“阻塞攻击”和允许第三方追踪他人通道余额的“探测攻击”。不幸的是，开发者尚未找到无需信任的方式来收取预付费用，因此近期的讨论集中在可能涉及微小费用的信任基础方法上，希望用户可以接受这些小额费用。

  不幸的是，本周讨论的所有方法似乎都未能获得广泛认可。几位开发者表达了对方法可能被滥用以惩罚小型诚实节点的担忧。其他开发者指出，预付费的替代方案是依赖声誉系统——这可能会不成比例地使大型节点受益。我们相信开发者将继续研究这一重要问题，并将在未来的 Newsletter 中报告任何值得注意的进展。

- **<!--simplified-htlc-negotiation-->****简化 HTLC 协商：** Rusty Russell 在 Lightning-Dev 邮件列表中[发布][russell simplified]有关简化 LN 通道中支付创建和解决的提案。目前，通道双方都可以提议转发或结算支付，这需要在离链承诺交易中创建或移除一个 [HTLC][topic htlc]。有时双方会同时提议更改，从而出现冲突的承诺交易。如果允许对承诺交易格式和设置进行动态更改（参见 [Newsletter #108][news108 upgrade commitment]），这些潜在冲突可能会变得更加复杂。一种消除该复杂性的提案是仅在所有 HTLC 已解决并通道处于空闲状态时才允许动态更改——这提高了安全性，但限制性较大。

  Russell 本周提出的提案是仅允许通道中的一方提出 HTLC 更改。这消除了冲突提案的风险，但将平均网络通信开销增加了半个往返（假设每方提出的 HTLC 更改次数相等）。提出更改的责任可以根据需要从一方转移到另一方，允许各方在不同时间提出通道更新。

  截至撰写本文时，该提案仅收到少量来自其他 LN 实现维护者的讨论，因此其未来尚不确定。

## 服务和客户端软件的更改

*在本月的特刊中，我们重点介绍了比特币钱包和服务的有趣更新。*

- **<!--bluewallet-adds-payjoin-->****BlueWallet 添加 Payjoin：**
  [Payjoin][topic payjoin] 支持（BIP78）已在 BlueWallet 的最新 [v5.6.1 版本][bluewallet payjoin]中上线，支持桌面和移动端。

- **<!--bitfinex-supports-wumbo-channels-->****Bitfinex 支持 wumbo 通道：**
  作为[闪电网络的早期支持者][news77 bitfinex lightning]，Bitfinex 现在已[增加][bitfinex wumbo blog]通过 [wumbo（大容量）LN 通道][topic large channels]存取大额比特币的功能。

- **<!--esplora-c-lightning-plugin-released-->****Esplora C-Lightning 插件发布：**
  Luca Vaccaro 发布了[初版][github esplora clnd plugin] Esplora C-Lightning 插件，用于从[区块浏览器][topic block explorers]而非本地 `bitcoind` 节点中提取比特币数据。

- **<!--coinfloor-supports-bech32-->****Coinfloor 支持 bech32：**
  Coinfloor 在最近宣布支持 bech32 提现（发送）后，现在也宣布[支持 bech32 存款（接收）][coinfloor bech32 blog]。

- **<!--bisq-supports-bech32-->****Bisq 支持 bech32：**
  点对点比特币交易软件 Bisq 在最新的 [1.4.1 版本][bisq bech32]中实现了 bech32 发送和接收支持。

- **<!--unchained-capital-supports-psbt-->****Unchained Capital 支持 PSBT：**
  在[博客文章][unchained capital psbt blog]中，Unchained 介绍了他们对 [PSBT][topic psbt] 和 Coldcard 硬件钱包的支持。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的更改。*

- [Bitcoin Core #19953][] 实现了 [Schnorr 签名验证][topic schnorr signatures]（[BIP340][]）、[Taproot][topic taproot] 验证（[BIP341][]）和 [Tapscript][topic tapscript] 验证（[BIP342][]）。新的软分叉规则目前仅在私有测试模式（"regtest"）下使用；它们尚未在主网、测试网或默认 signet 上执行。计划在 Bitcoin Core 0.21.0 中发布代码，然后准备后续版本（例如 0.21.1），当检测到激活信号时即可开始执行软分叉的新规则。使用何种特定的激活信号仍在 [##taproot-activation][] IRC 聊天室中讨论（[日志][##taproot-activation logs]）。

  {% comment %}<!-- $ git diff 450d2b2371...865d2c37e2 | grep '^+' \
                      | grep -v '^+$' | grep -v '^+ */[/*]' | grep -v '^+ *\*' \
                      | grep -v '^+++' | wc -l
                    512
  -->{% endcomment %}

  该代码[包含][sipa summary]大约 [700 行][sipa consensus]与共识相关的更改（500 行除去注释和空白）和 [2,100 行][sipa tests]的测试。超过 30 人直接审查了此 PR 及其[前身][Bitcoin Core #17977]，许多人参与了相关研究、BIPs、libsecp256k1 的相关代码以及系统其他部分的开发和审查。虽然仍有更多工作要做，但代码的正确审查可以说是最关键的一步——因此，我们向所有帮助实现这一里程碑的人致以最深切的感谢。

- [Bitcoin Core #19988][] 重新设计了 Bitcoin Core 请求其节点对等方的交易逻辑。PR 描述的主要更改包括：Bitcoin Core 现在更倾向于请求来自*出站对等方*的交易，即由本地节点打开连接的对等方；Bitcoin Core 现在将请求无限数量的交易，而不是在 100 笔交易后停止（尽管响应较慢的对等方不会被优先考虑）；Bitcoin Core 不会像之前那样跟踪大量未决的交易请求，因为之前的限制被认为过多。此更改还大大提高了代码的可读性和测试交易请求逻辑按预期工作的能力。此测试可能有助于减少漏洞被用于时间敏感交易（如 LN 和许多其他合同协议）用户的风险。

- [Bitcoin Core #19077][] 为钱包记录添加了一个新的 SQLite 数据库后端。与现有的 Berkeley DB 数据库后端不同，SQLite 旨在并经过测试能够抗击崩溃和断电带来的损坏。在即将发布的 v0.21 版本中，旧版钱包将继续使用 Berkeley DB 后端，而[新引入的描述符钱包][news96 descriptor wallets]将默认使用此新的 SQLite 后端。正在 [Bitcoin Core #20160][] 中讨论开发迁移路径和弃用旧版钱包及 Berkeley DB 钱包后端的初步时间表。

- [Bitcoin Core #19770][] 废弃了 `getpeerinfo` RPC 返回的 `whitelisted` 字段，该字段以前因更细粒度的权限而扩展（参见 [Newsletter #60][news60 permissions]）。`whitelisted` 计划在 v0.21 中弃用并在 v0.22 中删除。

- [Bitcoin Core #17428][] 在关闭时写入一个文件，记录节点的两个仅区块中继的出站对等方的网络地址。节点下一次启动时，会读取此文件并尝试重新连接到相同的两个对等方。这可以防止攻击者利用节点重启触发对等方的完全更换，这可能会被用于 [eclipse 攻击][topic eclipse attacks]，该攻击可能会欺骗节点接受无效的比特币。

- [LND #4688][] 添加了一个新的 `--duration` 参数，可用于指示 LND 何时停止进一步的支付尝试。默认值仍为 60 秒。

- [Libsecp256k1 #830][] 启用 GLV 端同态，这允许在验证签名时最多减少 33% 的操作（请参阅 PR 中的[实际性能测试结果][o'beirne bitcoinperf]）。该 PR 还移除了无端同态操作的较慢代码，因为 GLV 技术的专利已过期（见 [Newsletter #117][news117 glv]）。该 PR 还实现了独立的 `memcmp`（内存比较）函数，以避免使用 GCC 内部版本带来的问题（见 [Newsletter #117][news117 memcmp] 的另一节）。这些更改随后被[拉取][Bitcoin Core #20147]到 Bitcoin Core 中。

{% include references.md %}
{% include linkers/issues.md issues="19953,17977,19988,19077,19770,17428,4688,830,20147,20160" %}
[sipa summary]: https://github.com/bitcoin/bitcoin/pull/19953#issuecomment-691815830
[sipa consensus]: https://github.com/bitcoin/bitcoin/compare/450d2b2371...865d2c37e2
[sipa tests]: https://github.com/bitcoin/bitcoin/compare/206fb180ec...0e2a5e448f426219a6464b9aaadcc715534114e6
[o'beirne bitcoinperf]: https://github.com/bitcoin/bitcoin/pull/20147#issuecomment-711051877
[news108 upgrade commitment]: /en/newsletters/2020/07/29/#upgrading-channel-commitment-formats
[news117 glv]: /en/newsletters/2020/09/30/#us-patent-7-110-538-has-expired
[news117 memcmp]: /en/newsletters/2020/09/30/#discussion-about-compiler-bugs
[news119 upfront]: /en/newsletters/2020/10/14/#ln-upfront-payments
[jager hold fees]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-October/002826.html
[russell simplified]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-October/002831.html
[##taproot-activation]: https://webchat.freenode.net/##taproot-activation
[##taproot-activation logs]: http://gnusha.org/taproot-activation/
[musig 2 paper]: https://eprint.iacr.org/2020/1261
[musig blog post unsafe deterministic nonce]: https://blockstream.com/2019/02/18/en-musig-a-new-multisignature-standard/#uniform-randomness
[unsafe nonce sharing]: /en/newsletters/2019/11/27/#schnorr-taproot-updates
[musig-dn]: https://medium.com/blockstream/musig-dn-schnorr-multisignatures-with-verifiably-deterministic-nonces-27424b5df9d6
[composable musig in ln]: /en/newsletters/2019/12/04/#composable-musig
[news60 permissions]: /en/newsletters/2019/08/21/#bitcoin-core-16248
[bluewallet payjoin]: https://github.com/BlueWallet/BlueWallet/releases/tag/v5.6.1
[news77 bitfinex lightning]: /en/newsletters/2019/12/18/#bitfinex-supports-ln-deposits-and-withdrawals
[bitfinex wumbo blog]: https://blog.bitfinex.com/trading/bitfinex-supports-the-lightning-networks-wumbo-channels/
[github esplora clnd plugin]: https://github.com/lvaccaro/esplora_clnd_plugin/releases/tag/v0.1
[coinfloor bech32 blog]: https://coinfloor.co.uk/hodl/2020/10/09/upgrades-to-btc-deposits/
[bisq bech32]: https://github.com/bisq-network/bisq/releases/tag/v1.4.1
[unchained capital psbt blog]: https://unchained-capital.com/blog/now-coldcard/
[news96 descriptor wallets]: /en/newsletters/2020/05/06/#bitcoin-core-16528
