---
title: 'Bitcoin Optech Newsletter #211'
permalink: /zh/newsletters/2022/08/03/
name: 2022-08-03-newsletter-zh
slug: 2022-08-03-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报介绍了一个允许在单个输出脚本描述符容纳多个派生路径的提案。此外还有我们的常规栏目：热门的比特币基础设施项目的重大变更。

## 新闻

- **<!--multiple-derivation-path-descriptors-->多个派生路径的描述符**：Andrew Chow 在 Bitcoin-Dev 邮件组中[发帖][chow desc]提出了一个 [BIP 草案][bip-multipath-descs]，让单个描述符可以指定两个相关的 [BIP32][] 路径用于[层级确定式（HD）密钥生成][topic bip32]。第一个路径用于生成接收支付的地址；第二个路径用于钱包内部的支付，也就是在花费 UTXO 之后接收找零。

  如 BIP32 [所指定的][bip32 wallet layout]，大部分钱包都使用相互隔离的路径来生成外部地址和内部地址，以加强隐私性。一个用于接收支付的外部路径也许可以跟不那么值得信赖的设备分享，比如上载到网络服务器以接收支付。只用于找零的内部路径可能仅在需要动用私钥时才会用上，所以它可以获得跟私钥相同的安全性。如果举例所言的网站服务器被攻破了、外部地址遭到泄露，攻击者将知晓用户什么时候收到了钱、收到了多少、什么时候想发起一笔支付 —— 但他们并不一定能知道多少资金被发回给了用户自己，也并不必然能知道用户完全由找零输出所形成的支付。

  [Pavol Rusnak][rusnak desc] 和 [Craig Raw][raw desc] 的回复暗示 Trezor Wallet 和 Sparrow Wallet 已经支持了 Chow 所提出的方案。Rusnak 还提问单个描述符是否能描述超过两条相关的路径。Dmitry Petukhov [指出][petukhov desc]只有内部和外部路径是今天广泛使用的做法，记录额外路径的能力对现有的钱包来说并没有明确的用处。而且可能会产生互操作性问题。他建议将该 BIP 限制在两条路径上，并等待想要加入更多路径的人自己来撰写相应的 BIP。

## 重大的代码和文献变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo] 和 [Lightning BOLTs][bolts repo]。*

- [Core Lightning #5441][] 升级了 `hsmtool`，使之更容易检查 [HD 种子][topic bip32]的 [BIP39][] 口令；CLN 的内部钱包会使用这样的种子。

- [Eclair #2253][] 增加了对 [BOLTs #765][] 所说明的 “[盲化支付][topic rv routing]” 的支持（详见[周报 #187][news178 eclair 2061]）。

- [LDK #1519][] 也在 `channel_update` 消息中增加了 `htlc_maximum_mast` 字段；如果 [BOLTs #996][] 进入了闪电网络规范，这将成为必须。该变更的 PR 给出的理由是简化消息分析。

- [Rust Bitcoin #994][] 增加了一个 `LockTime` 类型，可以跟 nLockTime 和 [BIP65][] `OP_CHECKLOCKTIME` 字段一起使用。比特币中的时间锁字段可以使用区块高度，也可以使用 [Unix 时间][Unix epoch time]。

- [Rust Bitcoin #1088][] 加入了 [BIP152][] 所定义的 “[致密区块][topic compact block relay]” 所需的结构，以及一种从常规区块创建一个致密区块的方法。致密区块允许一个节点告知其对等节点一个区块中包含了哪些交易，且不用发送这些交易的完整备份。如果一个对等节点以前收到并存储了这些交易（在这些交易还未确认的时候），TA 就不需要再次下载，可以节省带宽并加速新区块的转发。

{% include references.md %}
{% include linkers/issues.md v=2 issues="5441,2253,1519,994,1088,996,765" %}
[bip32 wallet layout]: https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#specification-wallet-structure
[chow desc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020791.html
[bip-multipath-descs]: https://github.com/achow101/bips/blob/bip-multipath-descs/bip-multipath-descs.mediawiki
[rusnak desc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020792.html
[raw desc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020799.html
[petukhov desc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020804.html
[unix epoch time]: https://en.wikipedia.org/wiki/Unix_time
[news178 eclair 2061]: /en/newsletters/2021/12/08/#eclair-2061