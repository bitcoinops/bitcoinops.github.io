---
title: 'Bitcoin Optech Newsletter #159'
permalink: /zh/newsletters/2021/07/28/
name: 2021-07-28-newsletter-zh
slug: 2021-07-28-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 包括我们的常规栏目：过去一个月 Bitcoin Stack Exchange 上的最佳问答、关于为 Taproot 做准备的最新专栏、新软件发布与候选版本列表，以及对热门比特币基础设施软件值得注意的变更的介绍。

## 新闻

*本周无重大新闻。*

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们有点空闲时帮助好奇或困惑用户的地方。在本月栏目中，我们精选自上次更新以来得票最高的一些问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--what-is-this-unusual-transaction-in-the-bitcoin-blockchain-->**[比特币区块链中的这笔异常交易是什么？]({{bse}}107603)
  Murch 描述了在[区块浏览器][topic block explorers]中标记为“UNKNOWN”的输出。该输出是一个 segwit v1 输出，其公钥是人为构造的。正如 0xb10c 指出的那样，2019 年创建该输出的这笔交易，目的是测试 [Optech 兼容性矩阵][compat matrix] 对 segwit v1 的支持。正如之前警告的（参见 [Newsletter #158][news158 taproot]），在 taproot 激活之前，P2TR 输出属于“任何人都可花费”的类型，0xb10c 在[博客文章][0xB10C blog]中对此做了演示和详细说明。

- **<!--what-are-miners-signalling-for-when-the-block-header-nversion-field-ends-in-4-i-e-0x3fffe004-->**[当区块头的 nVersion 字段以 4 结尾（例如 0x3fffe004）时，矿工在信号什么？]({{bse}}107443)
  在研究 ASICBoost 的显式形式时，用户 shikaridota 发现最近挖掘的区块在 `nVersion` 字段中设置了 bit 2。Andrew Chow 指出，[Taproot][topic taproot] 使用 bit 2 作为激活信号，具体规定在 [BIP341 的部署][bip341 deployment]部分。

- **<!--where-can-i-find-bitcoin-s-alpha-version-with-15-minute-block-time-intervals-->**[我在哪里可以找到区块时间间隔为 15 分钟的比特币 Alpha 版本？]({{bse}}107407)
  Andrew Chow 指出了一段据称出自中本聪的[源代码][bitcointalk 15min]，其中包含 15 分钟的区块时间以及 30 天的难度调整周期。

- **<!--what-s-the-purpose-of-using-guix-within-gitian-doesn-t-that-reintroduce-dependencies-and-security-concerns-->**[在 Gitian 中使用 Guix 的目的是什么？这是否会重新引入依赖性和安全问题？]({{bse}}107638)
  Andrew Chow 和 fanquake 介绍了可重复构建的好处，包括使用 [Gitian 构建][github gitian builds]和[基于 Guix 的可引导构建][github contrib guix]，并讨论了它们的结合使用。

- **<!--why-are-there-several-round-number-transactions-with-no-change-->**[为什么有几笔整数金额的交易没有找零？]({{bse}}107418)
  Shm 询问了一系列相关交易，这些交易有多个输入，但仅有一个无找零的整数金额输出。Murch 在回答中描述了[避免找零][bitcoin wiki change avoidance]的概念，尤其是在拥有大量 UTXO 的钱包中。避免找零可以减少交易大小、降低未来手续费、整合 UTXO，并提高隐私性。

## 准备 Taproot #6：在使用中学习 Taproot

*关于开发者与服务提供商如何为即将在区块高度 {{site.trb}} 激活的 Taproot 做准备的[系列][series preparing for taproot]周更文章。*

{% include specials/taproot/zh/05-taproot-notebooks.md %}

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [Rust Bitcoin 0.27.0][]（Bech32m 支持）是一个新发布的版本。尤其值得注意的是，它新增了处理 [bech32m][topic bech32] 地址的支持。

- [C-Lightning 0.10.1rc1][C-Lightning 0.10.1] 是一次升级的候选版本，包含许多新功能、若干错误修复，以及若干处对仍在开发中的协议的更新（包括[双向资助][topic dual funding]和[offers][topic offers]）。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]的值得注意的变更。*

- [Bitcoin Core #22387][] 把每个对等节点可处理的地址公告平均数量限制为每 10 秒 1 个。超出限制的地址将被忽略。可以把对等节点加入白名单，允许其超出这一限制；节点明确向对等节点请求的地址公告也不计入限制。据估计，该限制约为当前 Bitcoin Core 节点公告地址速率的四倍。

- [C-Lightning #4669][] 修复了其[闪电网络 offers][topic offers]解析和验证逻辑中的多个错误。此外，如果用户尝试创建相同参数的新 offers，系统将返回先前创建但尚未过期的 offers；这对默认不设置到期日期的 offers 尤为有用。

- [C-Lightning #4639][] 新增对 [BOLTs #878][] 提案中流动性广告的实验性支持。节点可借助闪电网络 gossip 协议，广播自己愿意在一段时间内出租资金的意向，使其他节点能够购买入站容量，从而即时收到支付。看到广告的节点可以通过一次[双向资助][topic dual funding]的通道开通，同时完成付款并获得入站容量。虽然无法强制广告节点真的去路由支付，但该提案纳入了另一项早期[提案][zmn liquidity providers]（[Lightning Pool][] 也计划<!-- [1] -->采用），使广告方在约定的租赁期满之前无法将资金挪作他用。因此，拒绝路由只会让它失去赚取路由手续费的机会。下表对比了流动性广告与 [Newsletter #123][news123 lightning pool] 中所述的 Lightning Pool 市场：

  <!-- [1]: 参见 "Service-Level Based Lifetime Enforcement"
  https://lightning.engineering/posts/2020-11-02-pool-deep-dive/ -->

  <table>
    <tr>
     <th></th>
     <th>Lightning Pool</th>
     <th>流动性广告</th>
    </tr>

    <tr>
     <th>上架控制</th>
     <td>中心化：可筛选高质量列表，但也存在审查风险</td>
     <td>去中心化：无法审查列表，但用户需自行调研租赁方</td>
    </tr>

    <tr>
     <th>许可协议</th>
     <td>客户端开源，服务端专有，协议开放</td>
     <td>全部开源</td>
    </tr>

    <tr>
     <th>价格信息</th>
     <td>实际成交价通过公开拍卖结果可见</td>
     <td>广告价通过 gossip 网络公开可见</td>
    </tr>

    <tr>
     <th markdown="span">

     第三方购买流动性（“[侧车通道][sidecar channels]”）

     </th>
     <td>支持，Alice 可支付 Bob 以开通与 Carol 的通道</td>
     <td markdown="span">

     [可能支持]({{bse}}107786)

     </td>
    </tr>

  </table>

- [BIPs #1072][] 合并了信息类提案 [BIP48][]——“多重签名钱包的多脚本层级”。该文档描述了参与多重签名方案的钱包所使用的一套已被广泛部署的派生标准，其基础是 `m/48'` 前缀，并详细说明了该方案采用的六个派生层级。

- [BIPs #1139][] 添加了 [BIP371][]，其中规定了在 [taproot][topic taproot] 交易中使用[部分签名比特币交易（PSBT）][topic psbt]（包括[版本 0][BIP174]和[版本 2][BIP370]）所需的新字段。此前的讨论见 [Newsletter #155][news155 tr psbts]。

## 致谢与更正

我们最初对 Bitcoin Core PR #22387 的描述错误地声称新速率限制比测得速率高 40 倍。正确数据应为 4 倍。感谢 Amiti Uttarwar 指出此错误。

{% include references.md %}
{% include linkers/issues.md issues="22387,4669,4639,878,1072,1139" %}
[C-Lightning 0.10.1]: https://github.com/ElementsProject/lightning/releases/tag/v0.10.1rc1
[rust bitcoin 0.27.0]: https://github.com/rust-bitcoin/rust-bitcoin/releases/tag/0.27.0
[sidecar channels]: https://lightning.engineering/posts/2021-05-26-sidecar-channels/
[news123 lightning pool]: /zh/newsletters/2020/11/11/#incoming-channel-marketplace
[news155 tr psbts]: /zh/newsletters/2021/06/30/#psbt-extensions-for-taproot
[zmn liquidity providers]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001555.html
[lightning pool]: https://lightning.engineering/posts/2020-11-02-pool-deep-dive/
[compat matrix]: /en/compatibility/
[news158 taproot]: /zh/newsletters/2021/07/21/#准备-taproot-5我们为什么要等待
[0xB10C blog]: https://b10c.me/blog/007-spending-p2tr-pre-activation/
[bip341 deployment]: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki#deployment
[bitcointalk 15min]: https://bitcointalk.org/index.php?topic=382374.msg4108739#msg4108739
[bitcoin wiki change avoidance]: https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#Change_avoidance
[github gitian builds]: https://github.com/bitcoin-core/docs/blob/master/gitian-building.md
[github contrib guix]: https://github.com/bitcoin/bitcoin/blob/master/contrib/guix/README.md
[series preparing for taproot]: /zh/preparing-for-taproot/
