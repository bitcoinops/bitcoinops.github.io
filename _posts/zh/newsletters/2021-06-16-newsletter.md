---
title: 'Bitcoin Optech Newsletter #153'
permalink: /zh/newsletters/2021/06/16/
name: 2021-06-16-newsletter-zh
slug: 2021-06-16-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 庆祝了 taproot 软分叉的锁定，介绍了一份通过改变实现防止 fee sniping 时所使用字段来改善交易隐私的 BIP 草案，并讨论了在结合交易替换（RBF）和批量支付时可能遇到的挑战。此外，我们也照例带来了新软件版本与候选发布的公告，以及常用比特币基础设施软件中的值得注意的更新内容。

## 新闻

- **<!--taproot-locked-in-->****🟩  Taproot 已锁定：** [taproot][topic taproot] 软分叉及其在 BIPs [340][bip340]、[341][bip341]、[342][bip342] 中所指定的相关更改已在上周末由发送信号的矿工锁定。taproot 预计将在区块高度 709,632（大约在 11 月上旬或中旬）之后安全可用。这段延迟使用户有时间升级他们的节点至会强制执行 taproot 规则的发行版本（如 Bitcoin Core 0.21.1 或更高版本），从而确保在区块高度 709,632 之后接收至 taproot 脚本的资金即便在出现矿工问题时也能获得安全保障。

  我们鼓励开发者[开始实现 taproot][taproot uses]，以便在激活完成后立即利用其更高的效率、隐私和可替代性。

  正在庆祝 taproot 锁定的读者也可以阅读开发者 Pieter Wuille 的[一段简短推文][wuille taproot]，了解有关 taproot 起源和历史的介绍。

- **<!--bip-proposed-for-wallets-to-set-nsequence-by-default-on-taproot-transactions-->****提议为钱包在 taproot 交易中默认设置 nSequence：**
  Chris Belcher 在 Bitcoin-Dev 邮件列表[提交][belcher post]了一份 BIP 草案，建议使用一种可替代方式来实现[防止 fee sniping][topic fee sniping]。该替代方案能增强单签用户、[multisignature][topic multisignature] 用户，以及某些使用 taproot 功能的合约协议用户（例如闪电网络或高级 [coinswaps][topic coinswap]）所进行交易的隐私和可替代性。

  防止 fee sniping 是一些钱包为阻止矿工相互窃取费用而采用的技术，这种相互窃取费用的行为会降低保护 Bitcoin 的工作量证明总量，并削弱用户对确认次数的依赖能力。当前所有实现了防止 fee sniping 的钱包都使用 nLockTime 的区块高度锁定，但也可以通过 [BIP68][] 的 nSequence 区块高度锁定实现同样的保护功能。这样做并不会更有效地防止 fee sniping，但它会鼓励普通钱包将其 nSequence 值设置为某些基于多签的合约协议（如 coinswaps 或使用 taproot 的闪电网络）所需的相同数值，从而让普通钱包的交易看起来与这些协议的交易类似，反之亦然。

  Belcher 的提案建议钱包在两种方式都可用时，以 50% 的概率随机选择 nLockTime 或 nSequence。总体而言，如果这一提案被采纳，对于使用常规单签或多签交易的用户以及各种合约协议用户，双方都可通过这种做法共同提升彼此的隐私与可替代性。

## 实地报告: 使用 RBF 和批量添加

{% include articles/zh/cardcoins-rbf-batching.md %}

## 发布与候选发布

*适用于常用比特币基础设施项目的新版本与候选发布版本。请考虑升级到新版本，或协助测试候选发布版本。*

- [Rust Bitcoin 0.26.2][]
  这是该项目最新的小版本更新。与上一个主要版本相比，其中包含若干 API 改进与错误修复，详情可参阅 [changelog][rb changelog]。

- [Rust-Lightning 0.0.98][]
  小版本更新，包含若干改进与错误修复。<!-- 该版本暂无可见的发布说明或 changelog -->

- [LND 0.13.0-beta.rc5][LND 0.13.0-beta]
  这是一个候选发布版本，增加了对修剪过的比特币全节点的支持，允许使用原子多路径支付（Atomic MultiPath，简称 [AMP][topic multipath payments]）接收和发送付款，并提升了其 [PSBT][topic psbt] 功能，还包含其他改进及错误修复。

## 值得注意的代码和文档更改

*以下是本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]中的值得注意的更改：*

- [Bitcoin Core GUI #4][]
  为通过 GUI 使用 [Hardware Wallet Interface (HWI)][topic hwi] 外部签名器提供了初步支持。在该功能完善后，用户将能够直接在 Bitcoin Core GUI 中使用其兼容 HWI 的硬件钱包。

  {:.center}
  ![HWI 路径配置选项界面截图](/img/posts/2021-06-gui-hwi.png)

- [Bitcoin Core #21573][]
  更新了 Bitcoin Core 中使用的 libsecp256k1 版本。其中最值得注意的更改是引入了之前在 Newsletter [#136][news136 safegcd] 和 [#146][news146 safegcd] 中提到的优化模逆代码。根据该拉取请求中公布的性能评估数据，这项更新为旧区块验证带来了约 10% 的速度提升。

- [C-Lightning #4591][]
  添加了对解析 [bech32m][topic bech32] 地址的支持。当节点协商启用 `option_shutdown_anysegwit` 功能后，C-Lightning 现在允许指定任意 v1+ 的原生 segwit 地址作为关闭通道或提现操作时的目标地址。

{% include references.md %}
{% include linkers/issues.md issues="4,21573,4591" %}
[Rust Bitcoin 0.26.2]: https://github.com/rust-bitcoin/rust-bitcoin/releases/tag/0.26.2
[Rust-Lightning 0.0.98]: https://github.com/rust-bitcoin/rust-lightning/releases/tag/v0.0.98
[LND 0.13.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.13.0-beta.rc5
[belcher post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-June/019048.html
[news136 safegcd]: /zh/newsletters/2021/02/17/#faster-signature-operations
[news146 safegcd]: /zh/newsletters/2021/04/28/#libsecp256k1-906
[taproot uses]: https://en.bitcoin.it/wiki/Taproot_Uses
[wuille taproot]: https://twitter.com/pwuille/status/1403725170993336322
[rb changelog]: https://github.com/rust-bitcoin/rust-bitcoin/blob/master/CHANGELOG.md#0262---2021-06-08
