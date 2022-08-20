---
title: 'Bitcoin Optech Newsletter #213'
permalink: /zh/newsletters/2022/08/17/
name: 2022-08-17-newsletter-zh
slug: 2022-08-17-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报介绍了可用于优化谨慎日志合约（DLC）且无需改变比特币共识的 BLS 签名，此外还有我们的常规部分：软件的新版本和候选版本、流行的比特币基础设施软件的重大变更。

## 新闻

- **<!--using-bitcoincompatible-bls-signatures-for-dlcs-->使用兼容比特币的 BLS 签名来优化 DLC**：谨慎日志合约允许使用一个已知的受信任第三方作为断言机来见证一些数据。信任这个断言机的个体可以在合约中使用这些见证消息（attestation），既不必告知这个断言机存在这个合约，也不必公开合约的内容。[使用 DLC 还有别的一些好处][topic dlc]。DLC 构想最初提议的是使用 [Schnorr 签名][topic schnorr signatures] 签名的一个特性，但后来被开发成使用更通用的[适配器签名][topic adaptor signatures]。

  本周，Lloyd Fournier 在 DLC-Dev 邮件组中[发帖][fournier dlc-dev]讨论了让断言机使用 Boneh-Lynn-Shacham（[BLS][]）签名来制作见证消息的好处。比特币本身不支持 BLS 签名，所以要加入 BLS 签名还需要一次软分叉，但 Fournier 链接了一篇由他联合撰写的[论文][fournier et al]，描述了如何从一个 BLS 签名中安全地抽取出信息并在兼容比特币的适配器签名中使用，这样就无需改变比特币的共识。

  然后，Fournier 也谈到了使用基于 BLS 的见证消息的许多好处。最重要的好处是，它将允许 “无状态” 的断言机，参加合约（且非断言机）的各方可以私下约定他们想让断言机见证的信息，例如，已知该断言机可以运行某种编程语言，于是指定一个使用该种语言编写的程序。然后各方可以根据合约的结果议定资金的分配，无需通知那个断言机。等到需要结算合约的时候，各方可以自己运行那个程序，如果他们能对结果达成一致，就可以合作结算该合约，无需动用断言机。若他们无法达成一致，任何一方都可以将该程序发送给断言机（也许还要附带一小笔服务费），然后接收一条对该程序源代码和运行它所返回的值的 BLS 见证消息。然后，这条见证消息可以转化成可以在链上结算 DLC 的签名。就像当前的 DLC 合约一样，这个断言机不会知道哪一笔链上交易是依据其 BLS 签名得到实施的。这种模式支持使用多个断言机，也可以使用门限配置（例如 5-of-10，10 个断言机里面有 5 个得到一致结果即可执行）。

  这份帖子充分说明了无状态断言机对比现有 DLC 断言机的优势，因为在当前模式下，在合约创建时就需要知道断言机可能会怎么做。截至本周报撰写之时，该帖子尚未收到其他 DLC 贡献者的回应。

## 新版本和候选版本

*热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Rust Bitcoin 0.29][] 是一个大版本更新。它的[更新日志][rb29 rn]指出该版本包含了破坏性的 API 更新，但也加入了大量新功能和 bug 修复，包括对 “[致密区块中继][topic compact block relay]” 数据结构（[BIP152][]）的支持，以及对 [taproot][topic taproot] 和 [PSBT][topic psbt] 支持的优化。
- [Core Lightning 0.12.0rc2][] 是这个流行的闪电网络节点实现的下一个大版本的候选版本。

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo] 和 [Lightning BOLTs][bolts repo]。*

- [Bitcoin Core #23480][] 更新了[输出脚本描述符语言][topic descriptors]，加入了一个 ` rawtr() ` 描绘符；当一个公钥不经调整、直接用在 taproot 输出中时（我们并不推荐这样做，理由见[BIP341][bip341 internal]），或者在内部公钥和脚本路径未知时，可以使用该描述符来指明在 taproot 输出中暴露出来的公钥（这种用法在后面这种情形中可能是不安全的，详见该 PR 的 PR 评论或者文档）。虽然在这些情形中，已经可以使用现有的 ` raw() ` 描述符来指明这样的公钥，但 ` raw() ` 的主要用法是搭配 Bitcoin Core 的 ` scantxoutset ` RPC 方法、扫描本地的 UTXO 数据库；而新的 ` rawtr() ` 可以更方便使用其它已有的描述符字段来关联 taproot 输出的额外信息，例如密钥的来源信息。密钥的来源信息可以暗示使用了另类的密钥生成方案，例如使用递进调整方法来创建[Vanity 地址][]或者[可加强隐私性的合作性调整][reusable taproot addresses]。
- [Bitcoin Core #22751][] 加入了一个  ` simulaterawtransaction ` RPC，可以接受一个未确认交易的数组，返回这些交易将为该钱包增加或减少多少余额。
- [Eclair #2273][] 实现了[他们提议的][bolts #851]交互式注资协议，由此两个闪电节点在开启新的支付通道时可以更密切地合作。实现交互式注资让 Eclair 向支持 “[双向注资][topic dual funding]” 又迈出了一步。双向注资让参与通道的两方都可以向一个新的通道贡献资金。为实现双向注资而作的其它准备工作也将在本周的 [Eclair #2247][] 中合并。
- [Eclair #2361][]  开始要求通道更新信息包含 ` htlc_maximun_msat ` 字段，如 [BOLTs #996][] 所提议的（详见[周报 #211][news211 bolts996]）。
- [LND #6810][] 开始在钱包几乎所有自动生成输出脚本的场合使用 [taproot][topic taproot] 输出来接收支付。此外，[LND #6633][] 实现了对 ` option_any_segwit ` 的支持（详见[周报 #151][news151 any_segwit]），该功能允许使用 taproot 输出从共同关闭的通道中接受资金。
- [LND #6816][] 加入了介绍如何使用 “[零确认通道][topic zero-conf channels]” 的[文档][lnd 0conf]。
- [BDK #640][] 更新了 ` get_balance` 函数，在返回时可以将现有的余额分成四类： ` available ` 表示已确认的可用余额， ` trusted_pending ` 表示未确认但来自本钱包（比如找零）的余额， ` untrusted_pending ` 表示来自其它钱包的未确认余额， ` immature ` 余额表示来自 coinbase（挖矿）交易但还未得到 100 个确认（因此根据比特币的共识规则还无法花费）的余额。

{% include references.md %}
{% include linkers/issues.md v=2 issues="23480,22751,2273,2361,2247,996,6810,6633,6816,640,851" %}

[rust bitcoin 0.29]: https://github.com/rust-bitcoin/rust-bitcoin/releases/tag/0.29.1
[core lightning 0.12.0rc2]: https://github.com/ElementsProject/lightning/releases/tag/v0.12.0rc2
[bls]: https://en.wikipedia.org/wiki/BLS_digital_signature
[fournier dlc-dev]: https://mailmanlists.org/pipermail/dlc-dev/2022-August/000149.html
[fournier et al]: https://eprint.iacr.org/2022/499.pdf
[bip341 internal]: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki#constructing-and-spending-taproot-outputs
[news211 bolts996]: /zh/newsletters/2022/08/03/#ldk-1519
[news151 any_segwit]: /en/newsletters/2021/06/02/#bolts-672
[lnd 0conf]: https://github.com/lightningnetwork/lnd/blob/6c915484ba056870f9ed8b57f043d51f26137507/docs/zero_conf_channels.md
[vanity addresses]: https://en.bitcoin.it/wiki/Vanitygen
[reusable taproot addresses]: https://gist.github.com/Kixunil/0ddb3a9cdec33342b97431e438252c0a
[rb29 rn]: https://github.com/rust-bitcoin/rust-bitcoin/blob/110b5d89630d705e5d5ed0541230923eb4fc600f/CHANGELOG.md#029---2022-07-20-edition-2018-release
