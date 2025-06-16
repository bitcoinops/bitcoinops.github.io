---
title: 'Bitcoin Optech Newsletter #195'
permalink: /zh/newsletters/2022/04/13/
name: 2022-04-13-newsletter-zh
slug: 2022-04-13-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周 Newsletter 描述了一种在比特币交易和 LN 支付中转移非比特币代币的协议，并链接到了一个关于 MuSig2 多签名协议的拟议 BIP。我们的常规栏目还包括一场 Bitcoin Core PR 审查俱乐部会议的摘要、最新的软件发布与候选发布公告，以及流行比特币基础设施软件值得注意的变更说明。

## 新闻

- **<!--transferable-token-scheme-->****可转移代币方案：**
  Olaoluwa Osuntokun [发布][osuntokun taro]到 Bitcoin-Dev 和 Lightning-Dev 邮件列表，提出了一组 *Taro* 协议的 BIP 草案，该协议允许用户在比特币区块链上记录非比特币代币的创建与转移。例如，Alice 可以发行 100 枚代币，向 Bob 转移 50 枚，而 Bob 又可以用其中 25 枚代币与 Carol 交换 10 BTC。该思路与此前在比特币上实现的方案类似，但在细节上有所不同，例如复用了 [taproot][topic taproot] 的若干设计元素以减少需要编写的新代码量，并通过使用 merkle 树来减少证明某些操作已发生时需传输的数据量。

  Taro [旨在][gentry taro]与 LN 配合，用于可路由的链下转移。与此前在 LN 上进行跨资产转移的方案相似，仅用于路由支付的中间节点无需了解 Taro 协议或所转移资产的细节——它们只需像处理其他 LN 支付一样传递 BTC 即可。

  该想法本周在邮件列表上获得了适度的讨论。

- **<!--musig2-proposed-bip-->****MuSig2 提案 BIP：**
  Jonas Nick、Tim Ruffing 和 Elliott Jin [发布][nick musig2]了一个[拟议的 BIP][musig2 bip]至 Bitcoin-Dev 邮件列表，介绍了 [MuSig2][topic musig] 这一[多签名][topic multisignature]协议，用于创建公钥与签名。多个由不同方或软件控制的私钥可以使用 MuSig2 衍生聚合公钥，而无需各方之间共享任何私密信息。随后，也可以生成聚合签名，同样无需共享私密信息。对于第三方来说，聚合公钥与聚合签名看起来就像普通公钥与 [schnorr 签名][topic schnorr signatures]，因此不会泄露参与聚合的方数或私钥数量，相比链上多签在隐私性上具有优势。

  MuSig2 在几乎所有设想的应用中都优于最初的 MuSig 提案（现称 *MuSig1*）。与替代方案 MuSig-DN（deterministic nonce）相比，MuSig2 更易于实现，但二者之间存在一些取舍，应用开发者在选择协议时可能希望加以权衡。

## Bitcoin Core PR 审查俱乐部

*在本月栏目中，我们总结最近一次 [Bitcoin Core PR Review Club][] 会议，突出一些重要的问答。点击下面的问题可查看会议回答的摘要。*

[通过发送额外的 getheaders 消息防止区块索引指纹识别][reviews 24571] 是 Niklas Gögge 的一个拉取请求，旨在防止通过区块索引对节点进行指纹识别。

{% include functions/details-list.md

  q0="<!--q0-->区块索引是什么，它有什么用途？"
  a0="区块索引是在内存中的一个索引，用于查找区块头以及磁盘上区块数据的位置。它可能会保留多条分支（即包含过时区块头）的区块“树”，以便在发生重组时能够适应。"
  a0link="https://bitcoincore.reviews/24571#l-17"

  q1="<!--q1-->我们应不应该在区块索引中保留过时区块？为什么？"
  a1="当存在多条分支时，保留它们的索引可以使节点在最多工作量链发生变化时迅速切换分支。一些与会者指出，保留非常旧的过时区块可能意义不大，因为发生重组的概率极低。然而，这些区块头占用的存储空间非常小，并且因为节点在存储之前会检查工作量证明，所以攻击者若想通过发送有效工作量证明的过时区块头来耗尽节点资源，其成本会非常高。"
  a1link="https://bitcoincore.reviews/24571#l-68"

  q2="<!--q2-->描述一种利用节点区块索引进行指纹识别的攻击。"
  a2="在 IBD（初始区块下载）期间，节点只会请求并下载属于其在初始区块头同步过程中了解到的最多工作量链的区块。因此，其区块索引中的过时区块通常是在 IBD 之后挖出的，但这可能自然变化，也可能被拥有大量旧过时区块头的攻击者操纵。攻击者若持有包含区块头 H 和 H+1 的过时分支，可以向节点发送 H+1。若节点在其区块索引中没有 H，它会通过 `getdata` 消息请求 H；如果已经拥有 H，则不会请求。"
  a2link="https://bitcoincore.reviews/24571#l-75"

  q3="<!--q3-->为何防止节点指纹识别很重要？"
  a3="节点运营者可能采取多种技术来隐藏其节点的 IP 地址，例如使用 Tor。然而，如果攻击者能够将同一节点在 IPv4 和 Tor 网络上的地址相关联，这些隐私收益就会被削弱或抵消。如果一个节点仅运行在 Tor 上，指纹识别也可能被用来将属于同一节点的多个 Tor 地址关联起来，或在节点切换到 IPv4 时识别该节点。"
  a3link="https://bitcoincore.reviews/24571#l-84"
%}

## 发布与候选发布

*面向主流比特币基础设施项目的新版本与候选版本。请考虑升级至新版本，或协助测试候选版本。*

- [LDK 0.0.106][LDK 0.0.106] 是这个 LN 节点库的最新发布。该版本增加了对 [BOLTs #910][] 中提出的通道标识 `alias` 字段的支持，LDK 在某些场合利用它来提升隐私，并包含若干其他特性与错误修复。

- [BTCPay Server 1.4.9][BTCPay Server 1.4.9] 是这款流行支付处理软件的最新发布。

- [Bitcoin Core 23.0 RC4][Bitcoin Core 23.0 RC4] 是这一主流全节点软件的候选版本。其[草案发布说明][bcc23 rn]列出了多项改进，鼓励高级用户和系统管理员在最终发布前进行[测试][test guide]。

- [LND 0.14.3-beta.rc1][LND 0.14.3-beta.rc1] 是这款流行 LN 节点软件的候选版本，包含若干错误修复。

- [Core Lightning 0.11.0rc1][Core Lightning 0.11.0rc1] 是这款流行 LN 节点软件的下一主版本候选发布。

## 值得注意的代码与文档修改

*本周在 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]及[闪电网络规范（BOLTs）][bolts repo]中的值得注意的变更。*

- [Bitcoin Core #24152][] 通过引入[包费率][package feerate]并以其替代单笔交易费率，允许在“子交易带未确认父交易”的包中使用 CPFP（Child-Pays-For-Parent）手续费提升。如 [Newsletter #186][news186 package] 所述，这是提升 CPFP 和 RBF（Replace-By-Fee）手续费提升灵活性与可靠性的一系列修改的一部分。该补丁还[首先验证单笔交易][validates individual transactions first]，以避免出现“父为子付费”或“兄弟交易互付费”等与激励不兼容的策略。

- [Bitcoin Core #24098][] 更新了 `/rest/headers/` 与 `/rest/blockfilterheaders/` RPC，使其可使用查询参数（例如 `?count=<count>`）来替代端点参数（例如 `/<count>/`）。文档也已更新，鼓励优先使用查询参数。

- [Bitcoin Core #24147][] 为 [miniscript][topic miniscript] 增加了后端支持。后续的 PR [#24148][bitcoin core #24148] 与 [#24149][bitcoin core #24149] 若被合并，将分别为[输出脚本描述符][topic descriptors]和钱包签名逻辑加入 miniscript 支持。

- [Core Lightning #5165][] 将 C-Lightning 项目更名为 [Core Lightning][core lightning repo]，简称 CLN。

- [Core Lightning #5086][] 增加了在付款中附加 `option_payment_metadata` 发票数据的能力，为[无状态发票][topic stateless invoices]提供了付款方支持；接收方支持尚未在本 PR 中加入 CLN。


{% include references.md %}
{% include linkers/issues.md v=2 issues="24152,24098,24147,24148,24149,5165,5086,910" %}
[bitcoin core 23.0 rc4]: https://bitcoincore.org/bin/bitcoin-core-23.0/
[bcc23 rn]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/23.0-Release-Notes-draft
[test guide]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/23.0-Release-Candidate-Testing-Guide
[lnd 0.14.3-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.14.3-beta.rc1
[core lightning 0.11.0rc1]: https://github.com/ElementsProject/lightning/releases/tag/v0.11.0rc1
[gentry taro]: https://lightning.engineering/posts/2022-4-5-taro-launch/
[osuntokun taro]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-April/003539.html
[nick musig2]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020198.html
[musig2 bip]: https://github.com/jonasnick/bips/blob/musig2/bip-musig2.mediawiki
[ldk 0.0.106]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.106
[btcpay server 1.4.9]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.4.9
[reviews 24571]: https://bitcoincore.reviews/24571
[news186 package]: /zh/newsletters/2021/09/22/#package-mempool-acceptance-and-package-rbf
[package feerate]: https://gist.github.com/glozow/dc4e9d5c5b14ade7cdfac40f43adb18a#fee-related-checks-use-package-feerate
[validates individual transactions first]: https://gist.github.com/glozow/dc4e9d5c5b14ade7cdfac40f43adb18a#always-try-individual-submission-first
