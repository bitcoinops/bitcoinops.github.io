---
title: 'Bitcoin Optech Newsletter #153'
permalink: /zh/newsletters/2021/06/16/
name: 2021-06-16-newsletter-zh
slug: 2021-06-16-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 庆祝了 taproot 软分叉的锁定，介绍了一份 BIP 草案——它通过变换实现防止手续费狙击（fee sniping）时所使用的字段来改善交易隐私，还刊载了一篇讨论把手续费替换（RBF）与批量支付结合使用之挑战的文章。此外，我们也照例带来了新软件版本与候选发布的公告，以及热门比特币基础设施软件的值得注意的变更。

## 新闻

- **<!--taproot-locked-in-->****🟩  Taproot 已锁定：** [taproot][topic taproot] 软分叉以及 BIPs [340][bip340]、[341][bip341]、[342][bip342] 中规定的相关改动，已在上周末由发信号的矿工锁定。taproot 将在区块 709,632 之后可以安全使用，该区块预计出现在 11 月上旬或中旬。这段延迟让用户有时间把节点升级到会强制执行 taproot 规则的发行版本（例如 Bitcoin Core 0.21.1 或更高版本），从而确保在区块 709,632 之后收到的、发往 taproot 脚本的资金，即使矿工出了问题也是安全的。

  我们鼓励开发者[开始实现 taproot][taproot uses]，以便在激活完成后就能立刻用上更高的效率、隐私性与可替代性。

  正在庆祝 taproot 锁定的读者，或许也想读一读开发者 Pieter Wuille 关于 taproot 起源与历史的[一段简短推文串][wuille taproot]。

- **<!--bip-proposed-for-wallets-to-set-nsequence-by-default-on-taproot-transactions-->****提议为钱包在 taproot 交易中默认设置 nSequence：**
  Chris Belcher 在 Bitcoin-Dev 邮件列表[提交][belcher post]了一份 BIP 草案，建议钱包用另一种方式实现[防止手续费狙击][topic fee sniping]。这一替代方案可以增强单签用户、[多重签名（multisignature）][topic multisignature]用户，以及某些合约协议的用户（例如启用 taproot 的闪电网络或高级 [coinswap][topic coinswap]）所发交易的隐私性与可替代性。

  手续费狙击是指某些矿工试图相互窃取手续费，这会减少用于保障 Bitcoin 安全的工作量证明，并限制用户依赖确认数的能力；防止手续费狙击就是一些钱包为阻遏这种行为而采用的技术。目前所有实现防止手续费狙击的钱包都使用 nLockTime 高度锁，但用 [BIP68][] 的 nSequence 高度锁也能实现同样的保护。这样做在防止手续费狙击上并不会更有效，但它给了普通钱包一个充分理由，把 nSequence 值设为某些基于多重签名的合约协议（例如 coinswap 方案和启用 taproot 的闪电网络）所要求的相同数值。这有助于让普通钱包的交易看起来像合约协议的交易，反之亦然。

  Belcher 的提案建议，当两种方式都可用时，钱包以 50% 的概率随机选用 nLockTime 或 nSequence。总体而言，如果该提案得到实施，使用常规单签交易或不复杂多重签名的用户就能与合约协议的用户合流，共同提升彼此的隐私性与可替代性。

## 实地报告：使用 RBF 和批量添加

{% include articles/zh/cardcoins-rbf-batching.md %}

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [Rust Bitcoin 0.26.2][]
  这是该项目最新的小版本更新。与上一个主要版本相比，其中包含若干 API 改进与错误修复，详情可参阅 [changelog][rb changelog]。

- [Rust-Lightning 0.0.98][]
  小版本更新，包含若干改进与错误修复。<!-- there's no release notes or
  changelog I can see, so not much to say here. -->

- [LND 0.13.0-beta.rc5][LND 0.13.0-beta]
  这是一个候选发布版本，增加了对修剪过的比特币全节点的支持，允许使用原子多路径支付（Atomic MultiPath，简称 [AMP][topic multipath payments]）接收和发送付款，并提升了其[部分签名比特币交易（PSBT）][topic psbt]功能，还包含其他改进及错误修复。

## 值得注意的代码与文档变更

*以下是本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]的值得注意的变更：*

- [Bitcoin Core GUI #4][]
  为通过 GUI 使用 [硬件钱包接口（HWI）][topic hwi] 外部签名器提供了初步支持。在该功能完善后，用户将能够直接在 Bitcoin Core GUI 中使用其兼容 HWI 的硬件钱包。

  {:.center}
  ![HWI 路径配置选项界面截图](/img/posts/2021-06-gui-hwi.png)

- [Bitcoin Core #21573][]
  更新了 Bitcoin Core 中使用的 libsecp256k1 版本。其中最值得注意的更改是引入了之前在 Newsletter [#136][news136 safegcd] 和 [#146][news146 safegcd] 中提到的优化模逆代码。根据该拉取请求中公布的性能评估数据，这项更新为旧区块验证带来了约 10% 的速度提升。

- [C-Lightning #4591][]
  添加了对解析 [bech32m][topic bech32] 地址的支持。对于已经协商启用 `option_shutdown_anysegwit` 功能的节点，C-Lightning 现在允许它把任意 v1+ 原生 segwit 地址指定为关闭通道或提现的目标地址。

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
