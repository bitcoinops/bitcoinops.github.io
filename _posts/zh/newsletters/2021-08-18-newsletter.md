---
title: 'Bitcoin Optech Newsletter #162'
permalink: /zh/newsletters/2021/08/18/
name: 2021-08-18-newsletter-zh
slug: 2021-08-18-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了关于粉尘限制的讨论，并包括我们的常规栏目，介绍了对服务和客户端软件的更改、如何为 Taproot 做准备、新的发布与候选发布，以及对流行比特币基础设施软件的值得注意的更改。

## 新闻

- **<!--dust-limit-discussion-->****粉尘限制讨论：**
  Bitcoin Core 及其他节点软件默认拒绝中继或挖掘任何输出值低于某个特定金额的交易，这一金额被称为[粉尘限制][topic uneconomical outputs]（具体金额因输出类型而异）。此限制使得用户更难创建*非经济性输出*——即花费其 UTXO 需要支付的手续费高于 UTXO 本身价值的情况。

  本周，Jeremy Rubin 在 Bitcoin-Dev 邮件列表中[发表][rubin dust]了一篇文章，提出了五点理由支持移除粉尘限制，并表示他认为该限制的目的是为了防止“垃圾交易”和“[粉尘指纹攻击][topic output linking]”。其他人对此[作出了回复][corallo dust]，提出了[反对意见][harding dust]，并指出该限制的存在并非为了防止垃圾交易，而是为了防止用户创建 UTXO，而这些 UTXO 由于经济因素将不会被花费，从而永久浪费全节点运营者的资源。此外，部分讨论也[描述][riard dust]了粉尘限制及非经济性输出对闪电网络的[影响][towns dust]。

  截至目前，讨论尚未达成共识。至少在短期内，我们预计粉尘限制仍将保留。

## 服务和客户端软件的更改

*在此月度特辑中，我们重点介绍比特币钱包和服务的有趣更新。*

- **<!--spark-lightning-wallet-adds-bolt12-support-->****Spark Lightning Wallet 添加 BOLT12 支持：**
  [Spark v0.3.0rc 版本][spark v0.3.0rc]为 [Spark][spark github] 增加了对 BOLT12 [offers][topic offers] 的部分支持。

- **<!--blockstream-announces-non-custodial-ln-cloud-service-greenlight-->****Blockstream 宣布去托管的闪电网络云服务 Greenlight：**
  在最近的[博客文章][blockstream blog greenlight]中，Blockstream 介绍了其基于云的 C-Lightning 托管节点服务，该服务将节点的运营（由 Blockstream 负责）与节点所持资金的控制权（由用户掌控）分离。[Sphinx][sphinx website] 和 [Lastbit][lastbit website] 目前均使用 Greenlight 服务。

- **<!--bitgo-announces-native-segwit-change-outputs-->****BitGo 宣布采用原生 SegWit 作为找零地址：**
  鉴于 SegWit 采用率已突破 75% 里程碑，[BitGo 的博客文章][bitgo blog segwit change]宣布默认的找零地址将从 P2SH 封装格式切换为[原生 SegWit][topic bech32] 格式。

- **<!--blockstream-green-desktop-0-1-10-released-->****Blockstream Green 桌面端 0.1.10 版本发布：**
  [0.1.10 版本][blockstream green desktop 0.1.10] 增加了默认采用 SegWit 的单签名钱包，并支持手动 [coin selection][topic coin selection] 功能。

## 准备 Taproot #9：签名适配器

*关于开发者和服务提供商如何为即将在区块高度 {{site.trb}} 激活的 Taproot 做准备的[系列][series preparing for taproot]文章。*

{% include specials/taproot/zh/08-signature-adaptors.md %}

## 发布与候选发布

*流行比特币基础设施项目的新发布和候选发布版本。请考虑升级到新版本或协助测试候选发布版本。*

- [Bitcoin Core 22.0rc2][bitcoin core 22.0] 是该全节点实现及其相关钱包和其他软件的下一个主要版本的候选发布。该版本的主要更改包括支持 [I2P][topic anonymity networks] 连接、移除对[版本 2 Tor][topic anonymity networks] 连接的支持，以及增强对硬件钱包的支持。

- [Bitcoin Core 0.21.2rc1][bitcoin core 0.21.2] 是 Bitcoin Core 的一个维护版本候选发布，包含多个错误修复和小改进。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[Bitcoin 改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]中的值得注意的更改。*

- [Bitcoin Core #22642][] 更新了 Bitcoin Core 22.0 版本的发布流程，将所有[可重复构建][topic reproducible builds]二进制文件的 GPG 签名合并到一个文件中，以便进行批量验证（[示例][gpg batch]）。虽然确定性构建者的签名已经存在多年，但此更改使得这些签名更加易于访问，同时减少了对项目首席维护者签署发布二进制文件的依赖。

- [Bitcoin Core #21800][] 为内存池包接受流程引入了祖先和后代限制。Bitcoin Core 限制其内存池中相关交易的数量，以防止 DoS 攻击并使矿工能够高效构建区块。默认情况下，这些[限制][bitcoin core mempool limits]确保内存池中任何交易及其祖先交易总数不超过 25 笔，或其总重量不超过 101KB。同样的规则适用于交易及其后代交易的组合。

  这些祖先和后代限制在交易被考虑加入内存池时生效。如果添加交易会导致某个限制被超出，则交易将被拒绝。尽管包交易的语义尚未最终确定，[#21800][bitcoin core #21800] 实现了用于验证任意交易包（即同时考虑多个交易加入内存池）的祖先和后代限制检查。内存池包接受功能最初在 [#20833][mempool package test accept] 仅作为测试实现，最终将作为[包中继][topic package relay]的一部分在 P2P 网络中公开。

- [Bitcoin Core #21500][] 更新了 `listdescriptors` RPC，增加了 `private` 参数，当该参数被设置时，该命令将返回每个描述符的私有形式。私有形式包含任何已知的私钥或扩展私钥（xprvs），使得该命令可用于备份钱包。

- [Rust-Lightning #1009][] 添加了 `max_dust_htlc_exposure_msat` 通道配置选项，该选项限制“粉尘 HTLC”（即金额低于[粉尘限制][topic uneconomical outputs]的 HTLC）的总余额。

  该更改是为[提议的][BOLTs #873] `option_dusty_htlcs_uncounted` 功能位做准备，该功能位表示该节点不希望将“粉尘 HTLC”计入 `max_accepted_htlcs`。节点运营者可能希望采用此功能位，因为 `max_accepted_htlcs` 主要用于限制链上交易的潜在大小，以防发生强制关闭，而“粉尘 HTLC”无法在链上被认领，因此不会影响最终交易的大小。

  新增的 `max_dust_htlc_exposure_msat` 通道配置选项确保即使启用了 `option_dusty_htlcs_uncounted`，用户仍可以限制“粉尘 HTLC”的总余额，因为在强制关闭的情况下，这些 HTLC 的余额将作为矿工费用损失。

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
