---
title: 'Bitcoin Optech Newsletter #120'
permalink: /zh/newsletters/2020/10/21/
name: 2020-10-21-newsletter-zh
slug: 2020-10-21-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 概述了新发表的 MuSig2 论文，汇总关于 LN 前置手续费的更多讨论，并介绍一个简化 LN 支付管理的提案。此外，常规部分还包括客户端与服务值得注意的改进总结、发布与候选发布的公告，以及热门比特币基础设施软件的变更。

## 行动项

*本周无。*

## 新闻

- **<!--musig2-paper-published-->****MuSig2 论文发布：** Jonas Nick、Tim Ruffing 和 Yannick Seurin 发布了 [MuSig2 论文][musig 2 paper]，描述了一种新的 [MuSig][topic musig] 签名方案变体，该方案采用了两轮签名协议。

  MuSig 是一种签名方案，允许多个签名者由各自的私钥推导出一个聚合公钥，然后协作生成该公钥的单一有效签名。聚合公钥和签名与其他任何 [schnorr][topic schnorr signatures] 公钥和签名都无法区分。

  MuSig 的原始版本需要三轮签名协议：首先，共同签名者交换对 nonce 值的承诺，然后交换 nonce 值本身，最后交换部分签名。没有这三轮协议，攻击者就能在多个并发的签名会话中与诚实的签名者交互，从而拿到该诚实签名者本不愿签署的消息的签名。

  使用确定性 nonce 在单一签名者的方案中非常常见，但在多个签名者参与的方案中并不安全，正如[最早的 MuSig 博客文章][musig blog post unsafe deterministic nonce]所述。提前预计算 nonce 并在密钥设置时交换它们同样不安全，正如 Jonas Nick 的[博客文章][unsafe nonce sharing]所述。不过，预先计算 nonce 并提前交换 nonce 承诺*确实*是安全的，这相当于把三轮中的一轮移到密钥设置阶段。

  移除交换 nonce 承诺这一要求一直是活跃的研究方向。上个月发表的 [MuSig-DN 论文][musig-dn]展示了如何去掉 nonce 承诺交换：由签名者的公钥和消息确定性地推导出 nonce，并随 nonce 一并提供一个非交互式零知识证明，证明该 nonce 确实是确定性生成的。这样就去掉了交换 nonce 承诺的要求，代价是签名运算更昂贵。

  新的 MuSig2 方案实现了无需零知识证明的简单两轮签名协议。更重要的是，第一轮（nonce 交换）可以在密钥设置时完成，从而支持以下两种变体：

  - 交互式设置（密钥设置和 nonce 交换）和非交互式签名

  - 非交互式设置（从公钥计算地址）和交互式签名（nonce 交换后交换部分签名）

  非交互式签名变体对冷存储方案和离线签名者特别有用，对 LN 等离链合约协议也有帮助——此时可在通道建立时交换 nonce。

- **<!--more-ln-upfront-fees-discussion-->****更多关于 LN 前置手续费的讨论：** 在[上周的讨论][news119 upfront]之后，Joost Jager 在 Lightning-Dev 邮件列表中请开发者再次[考虑][jager hold fees]如何为尝试路由支付收取手续费——即使尝试失败也必须支付的手续费。这有助于缓解两类问题：一是可能让节点赚不到路由手续费的*堵塞攻击*，二是让第三方得以追踪他人通道余额的*探测攻击*。遗憾的是，开发者尚未找到一种令人满意、又无需信任第三方的方式来收取前置手续费，因此近期讨论集中在基于信任的方法上；这类方法涉及的手续费可能小到用户可以接受。

  遗憾的是，本周讨论的所有方法似乎都没有得到广泛认可。有几位开发者担心，这些方法可能被滥用来惩罚小型的诚实节点。另一些开发者指出，不收前置手续费的替代做法是更加依赖声誉——这很可能让较大的节点获得不成比例的好处。我们相信开发者会继续处理这个重要问题，未来的 Newsletter 也将报道任何值得注意的进展。

- **<!--simplified-htlc-negotiation-->****简化 HTLC 协商：** Rusty Russell 在 Lightning-Dev 邮件列表中[发帖][russell simplified]，讨论如何简化 LN 通道中支付的发起与结算流程。目前，通道双方都可以提议转发或结算一笔支付，而这需要在离链承诺交易中创建或移除一个 [HTLC][topic htlc]。有时双方会同时提议变更，于是出现相互冲突的承诺交易。如果允许对承诺交易的格式和设置做动态变更（参见 [Newsletter #108][news108 upgrade commitment]），这些潜在冲突可能更加复杂。有一种消除该复杂性的提案是：仅在所有 HTLC 都已解决、通道处于静默状态时才允许动态变更——这提升了安全性，但比期望的更受限制。

  Russell 本周的提案是只允许通道中的一方提议 HTLC 变更。这消除了冲突提案的风险，但会让平均网络通信开销增加半个往返（假设双方提议的 HTLC 变更数量相同）。提议变更的职责可以根据需要从一方转给另一方，从而让双方在不同时间提议通道更新。

  截至撰写本文时，该提案仅收到少量来自其他 LN 实现维护者的讨论，因此其未来尚不确定。

## 服务和客户端软件的变更

*在本月栏目中，我们重点介绍 Bitcoin 钱包与服务的一些有趣更新。*

- **<!--bluewallet-adds-payjoin-->****BlueWallet 增加 payjoin 支持：**
  BlueWallet 最新的 [v5.6.1 版本][bluewallet payjoin]已加入 [payjoin][topic payjoin] 支持（BIP78），桌面端和移动端均可使用。

- **<!--bitfinex-supports-wumbo-channels-->****Bitfinex 支持 wumbo 通道：**
  作为[闪电网络的早期支持者][news77 bitfinex lightning]，Bitfinex 现在已[增加][bitfinex wumbo blog]通过 [wumbo（大容量）LN 通道][topic large channels]存取大额比特币的功能。

- **<!--esplora-c-lightning-plugin-released-->****Esplora C-Lightning 插件发布：**
  Luca Vaccaro 发布了 [Esplora C-Lightning 插件][github esplora clnd plugin]的初版，该插件从[区块浏览器][topic block explorers]获取比特币数据，而不再依赖本地 `bitcoind` 节点。

- **<!--coinfloor-supports-bech32-->****Coinfloor 支持 bech32：**
  Coinfloor 在最近宣布支持 bech32 提现（发送）后，现在也宣布[支持 bech32 存款（接收）][coinfloor bech32 blog]。

- **<!--bisq-supports-bech32-->****Bisq 支持 bech32：**
  点对点比特币交易软件 Bisq 在最新的 [1.4.1 版本][bisq bech32]中实现了 bech32 发送和接收支持。

- **<!--unchained-capital-supports-psbt-->****Unchained Capital 支持 PSBT：**
  在[博客文章][unchained capital psbt blog]中，Unchained 介绍了他们对[部分签名比特币交易（PSBT）][topic psbt]和 Coldcard 硬件钱包的支持。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的变更。*

- [Bitcoin Core #19953][] 实现了 [schnorr 签名验证][topic schnorr signatures]（[BIP340][]）、[taproot][topic taproot] 验证（[BIP341][]）和 [tapscript][topic tapscript] 验证（[BIP342][]）。新的软分叉规则目前仅在私有测试模式（“regtest”）下使用；在主网、测试网和默认 signet 上都不会强制执行。计划是在 Bitcoin Core 0.21.0 中发布这些代码，然后准备一个后续版本（例如 0.21.1），使其在检测到激活信号后即可开始强制执行软分叉的新规则。具体采用哪一种或哪几种激活信号仍在 [##taproot-activation][] IRC 聊天室中讨论（[日志][##taproot-activation logs]）。

  {% comment %}<!-- $ git diff 450d2b2371...865d2c37e2 | grep '^+' \
                      | grep -v '^+$' | grep -v '^+ */[/*]' | grep -v '^+ *\*' \
                      | grep -v '^+++' | wc -l
                    512
  -->{% endcomment %}

  该代码[包含][sipa summary]约 [700 行][sipa consensus]与共识相关的改动（剔除注释和空白后为 500 行），以及 [2,100 行][sipa tests]测试代码。有 30 多人直接审查了这个 PR 及其[前身][Bitcoin Core #17977]，还有许多人参与开发与审查了底层研究、BIPs、libsecp256k1 中的相关代码以及系统的其他部分。仍有许多工作要做，但让代码得到恰当的审查可以说是最关键的一步——因此我们向所有帮助达成这一里程碑的人致以最诚挚的感谢。

- [Bitcoin Core #19988][] 重新设计了 Bitcoin Core 从对等方请求交易的逻辑。PR 描述中提到的主要变更包括：Bitcoin Core 现在会更强地优先向*出站对等方*（连接由本地节点打开的对等方）请求交易；Bitcoin Core 现在会向某个对等方请求不限数量的交易，而不是请求到 100 笔就停下（不过响应慢的对等方不会被优先考虑）；Bitcoin Core 跟踪的待处理交易请求数量将比以往更少，因为此前的上限被认为设得过高。这项改动还大幅提升了代码的可读性，也提升了测试交易请求逻辑是否按预期工作的能力。这类测试可能有助于降低漏洞被利用来攻击时间敏感交易（例如 LN 及许多其他合约协议）用户的可能性。

- [Bitcoin Core #19077][] 为钱包记录添加了一个新的 SQLite 数据库后端。与现有的 Berkeley DB 数据库后端不同，SQLite 经过专门的设计与测试，能够抵御崩溃和断电造成的数据损坏。在即将发布的 v0.21 版本中，旧版钱包将继续使用 Berkeley DB 后端，而[新引入的输出脚本描述符钱包][news96 descriptor wallets]将默认使用这个新的 SQLite 后端。[Bitcoin Core #20160][] 正在讨论开发迁移路径，以及逐步弃用并移除旧版钱包和 Berkeley DB 钱包后端的初步时间表。

- [Bitcoin Core #19770][] 弃用了 `getpeerinfo` RPC 返回的 `whitelisted` 字段；由于权限控制变得更细粒度，该字段的适用范围此前已被扩展（参见 [Newsletter #60][news60 permissions]）。`whitelisted` 将在 v0.21 中标记为弃用，并计划在 v0.22 中移除。

- [Bitcoin Core #17428][] 在关闭时写入一个文件，记录该节点两个仅做区块中继的出站对等方的网络地址。节点下一次启动时会读取这个文件，并尝试重新连接同样的这两个对等方。这可以防止攻击者利用节点重启来触发对等方完全更换——否则攻击者可以借此实施 [日食攻击][topic eclipse attacks]，可能诱使节点接受无效的比特币。

- [LND #4688][] 添加了一个新的 `--duration` 参数，用于指定多长时间后 LND 停止继续尝试发送某笔支付。默认值仍为 60 秒。

- [Libsecp256k1 #830][] 启用了 GLV 自同态，使得验证签名时最多可减少 33% 的运算量（参见该 PR 中附有[实际性能测试结果][o'beirne bitcoinperf]的评论）。既然 GLV 技术的专利已经过期，就没有理由再使用不带自同态的较慢代码，因此该 PR 将其移除了（见 [Newsletter #117][news117 glv]）。该 PR 还实现了独立的 `memcmp`（内存比较）函数，以避免 GCC 内置版本带来的问题（见 [Newsletter #117][news117 memcmp] 的另一节）。这些改动随后被[合并][Bitcoin Core #20147]到 Bitcoin Core 中。

{% include references.md %}
{% include linkers/issues.md issues="19953,17977,19988,19077,19770,17428,4688,830,20147,20160" %}
[sipa summary]: https://github.com/bitcoin/bitcoin/pull/19953#issuecomment-691815830
[sipa consensus]: https://github.com/bitcoin/bitcoin/compare/450d2b2371...865d2c37e2
[sipa tests]: https://github.com/bitcoin/bitcoin/compare/206fb180ec...0e2a5e448f426219a6464b9aaadcc715534114e6
[o'beirne bitcoinperf]: https://github.com/bitcoin/bitcoin/pull/20147#issuecomment-711051877
[news108 upgrade commitment]: /zh/newsletters/2020/07/29/#upgrading-channel-commitment-formats
[news117 glv]: /zh/newsletters/2020/09/30/#us-patent-7-110-538-has-expired
[news117 memcmp]: /zh/newsletters/2020/09/30/#discussion-about-compiler-bugs
[news119 upfront]: /zh/newsletters/2020/10/14/#ln-upfront-payments
[jager hold fees]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-October/002826.html
[russell simplified]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-October/002831.html
[##taproot-activation]: https://webchat.freenode.net/##taproot-activation
[##taproot-activation logs]: http://gnusha.org/taproot-activation/
[musig 2 paper]: https://eprint.iacr.org/2020/1261
[musig blog post unsafe deterministic nonce]: https://blockstream.com/2019/02/18/en-musig-a-new-multisignature-standard/#uniform-randomness
[unsafe nonce sharing]: /zh/newsletters/2019/11/27/#schnorr-taproot-updates
[musig-dn]: https://medium.com/blockstream/musig-dn-schnorr-multisignatures-with-verifiably-deterministic-nonces-27424b5df9d6
[composable musig in ln]: /zh/newsletters/2019/12/04/#composable-musig
[news60 permissions]: /zh/newsletters/2019/08/21/#bitcoin-core-16248
[bluewallet payjoin]: https://github.com/BlueWallet/BlueWallet/releases/tag/v5.6.1
[news77 bitfinex lightning]: /zh/newsletters/2019/12/18/#bitfinex-supports-ln-deposits-and-withdrawals
[bitfinex wumbo blog]: https://blog.bitfinex.com/trading/bitfinex-supports-the-lightning-networks-wumbo-channels/
[github esplora clnd plugin]: https://github.com/lvaccaro/esplora_clnd_plugin/releases/tag/v0.1
[coinfloor bech32 blog]: https://coinfloor.co.uk/hodl/2020/10/09/upgrades-to-btc-deposits/
[bisq bech32]: https://github.com/bisq-network/bisq/releases/tag/v1.4.1
[unchained capital psbt blog]: https://unchained-capital.com/blog/now-coldcard/
[news96 descriptor wallets]: /zh/newsletters/2020/05/06/#bitcoin-core-16528
