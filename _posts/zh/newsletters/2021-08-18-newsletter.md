---
title: 'Bitcoin Optech Newsletter #162'
permalink: /zh/newsletters/2021/08/18/
name: 2021-08-18-newsletter-zh
slug: 2021-08-18-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了关于粉尘限制的讨论，并包括我们的常规栏目：服务和客户端软件的变更、如何为 Taproot 做准备、新版本与候选版本，以及热门比特币基础设施软件值得注意的变更。

## 新闻

- **<!--dust-limit-discussion-->****粉尘限制讨论：**
  Bitcoin Core 及其他节点软件默认拒绝中继或挖出任何输出值低于某个金额的交易，这一下限就是[粉尘限制][topic uneconomical outputs]（具体金额因输出类型而异）。这让用户更难创建*非经济性输出*——即花费它所需的手续费高于它本身价值的 UTXO。

  本周，Jeremy Rubin 在 Bitcoin-Dev 邮件列表中[发表][rubin dust]了支持移除粉尘限制的五点理由，并表示他认为该限制的目的是防止“垃圾交易”和“[粉尘指纹攻击][topic output linking]”。其他人对此[作出了回复][corallo dust]，提出了[反对意见][harding dust]，并指出该限制的存在并非为了防止垃圾交易，而是为了防止用户创建自己永远没有经济动机去花费的 UTXO，从而长期浪费全节点的资源。部分讨论还[描述][riard dust]了粉尘限制与非经济性输出对闪电网络的[影响][towns dust]。

  截至本文撰写时，似乎不太可能达成任何共识。至少在短期内，我们预计粉尘限制仍会保留。

## 服务和客户端软件的变更

*在本月栏目中，我们重点介绍 Bitcoin 钱包与服务的一些有趣更新。*

- **<!--spark-lightning-wallet-adds-bolt12-support-->****Spark Lightning Wallet 添加 BOLT12 支持：**
  [Spark][spark github] 的 [v0.3.0rc 版本][spark v0.3.0rc]加入了对 BOLT12 [offers][topic offers] 的部分支持。

- **<!--blockstream-announces-non-custodial-ln-cloud-service-greenlight-->****Blockstream 宣布非托管的闪电网络云服务 Greenlight：**
  在最近的[博客文章][blockstream blog greenlight]中，Blockstream 介绍了其托管式云上 C-Lightning 节点服务，该服务把节点的运行（由 Blockstream 负责）与节点所持资金的控制权（归用户所有）分离开来。[Sphinx][sphinx website] 和 [Lastbit][lastbit website] 目前都在使用 Greenlight 服务。

- **<!--bitgo-announces-native-segwit-change-outputs-->****BitGo 宣布采用原生 segwit 找零输出：**
  在 segwit 采用率跨过 75% 里程碑之后，[BitGo 的博客文章][bitgo blog segwit change]宣布其默认找零输出将从 P2SH 封装切换为[原生 segwit][topic bech32] 输出。

- **<!--blockstream-green-desktop-0-1-10-released-->****Blockstream Green 桌面端 0.1.10 发布：**
  [0.1.10 版本][blockstream green desktop 0.1.10] 新增了默认使用 segwit 的单签钱包，并加入手动[选币][topic coin selection]功能。

## 准备 Taproot #9：签名适配器

*关于开发者和服务提供商如何为即将在区块高度 {{site.trb}} 激活的 Taproot 做准备的[系列][series preparing for taproot]文章。*

{% include specials/taproot/zh/08-signature-adaptors.md %}

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [Bitcoin Core 22.0rc2][bitcoin core 22.0] 是该全节点实现及其配套钱包和其他软件下一个主要版本的候选版本。这个新版本的主要变更包括：支持 [I2P][topic anonymity networks] 连接、移除对[版本 2 Tor][topic anonymity networks] 连接的支持，以及加强对硬件钱包的支持。

- [Bitcoin Core 0.21.2rc1][bitcoin core 0.21.2] 是 Bitcoin Core 一个维护版本的候选版本，包含多项错误修复和若干小改进。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]的值得注意的变更。*

- [Bitcoin Core #22642][] 更新了 Bitcoin Core 为即将发布的 22.0 版所用的发布流程：把每一位[可重复构建][topic reproducible builds]出这些二进制文件的人的 GPG 签名拼接为单个文件，以便批量验证（[示例][gpg batch]）。确定性构建者的签名已经存在多年，但这一改动应能让这些签名更易获取，同时减少项目对首席维护者签署发布二进制文件这一做法的依赖。

- [Bitcoin Core #21800][] 为内存池接受交易包引入了祖先和后代限制。Bitcoin Core 会限制其内存池中相关交易的数量，以防 DoS 攻击，同时让矿工构建区块时切实可行。默认情况下，这些[限制][bitcoin core mempool limits]确保内存池中的任何交易连同其祖先交易，都不超过 25 笔或 101KvB 的重量。同样的规则也适用于该交易连同其后代交易的组合。

  这些祖先和后代限制在交易被考虑加入内存池时生效。如果加入该交易会导致某一限制被突破，交易就会被拒绝。尽管交易包的语义尚未最终确定，[#21800][bitcoin core #21800] 已实现了对任意交易包（即同时考虑把多笔交易加入内存池）进行祖先和后代限制检查。内存池交易包接受功能最初在 [#20833][mempool package test accept] 中仅供测试之用，最终会作为[交易包中继][topic package relay]的一部分，通过 P2P 网络对外提供。

- [Bitcoin Core #21500][] 更新了 `listdescriptors` RPC，增加了 `private` 参数，当该参数被设置时，该命令将返回每个描述符的私有形式。私有形式包含任何已知的私钥或扩展私钥（xprvs），使得该命令可用于备份钱包。

- [Rust-Lightning #1009][] 新增了 `max_dust_htlc_exposure_msat` 通道配置选项，用于限制处于待处理状态的“粉尘 HTLC”（金额低于[粉尘限制][topic uneconomical outputs]的 HTLC）的总余额。

  该变更是为[拟议的][BOLTs #873] `option_dusty_htlcs_uncounted` 功能位做准备，该功能位表示节点不希望把“粉尘 HTLC”计入 `max_accepted_htlcs`。节点运营者多半会愿意采用这一功能位，因为 `max_accepted_htlcs` 主要用来限制万一发生强制关闭时链上交易的潜在大小，而“粉尘 HTLC”在链上根本无法被认领，永远不会影响最终交易的大小。

  新增的 `max_dust_htlc_exposure_msat` 通道配置选项确保即使启用了 `option_dusty_htlcs_uncounted`，用户仍可限制“粉尘 HTLC”的总余额，因为一旦发生强制关闭，这部分余额会作为手续费付给矿工而损失掉。

{% include references.md %}
{% include linkers/issues.md issues="22642,21800,21500,1009,873" %}
[bitcoin core 22.0]: https://bitcoincore.org/bin/bitcoin-core-22.0/
[bitcoin core 0.21.2]: https://bitcoincore.org/bin/bitcoin-core-0.21.2/
[gpg batch]: https://gist.github.com/harding/78631dbcd65ff4a499e164c4e9dc85d4
[rubin dust]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-August/019307.html
[corallo dust]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-August/019308.html
[harding dust]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-August/019310.html
[riard dust]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-August/019327.html
[towns dust]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-August/019333.html
[bitcoin core mempool limits]: /zh/newsletters/2018/12/04/#fn:fn-cpfp-limits
[mempool package test accept]: /zh/newsletters/2021/06/02/#bitcoin-core-20833
[spark v0.3.0rc]: https://github.com/shesek/spark-wallet/releases/tag/v0.3.0rc
[spark github]: https://github.com/shesek/spark-wallet
[blockstream blog greenlight]: https://blockstream.com/2021/07/21/en-greenlight-by-blockstream-lightning-made-easy/
[sphinx website]: https://sphinx.chat/
[lastbit website]: https://gl.striga.com/
[bitgo blog segwit change]: https://blog.bitgo.com/native-segwit-change-outputs-for-bitcoin-c021406aaae2
[blockstream green desktop 0.1.10]: https://github.com/Blockstream/green_qt/releases/tag/release_0.1.10
[series preparing for taproot]: /zh/preparing-for-taproot/
