---
title: 'Bitcoin Optech Newsletter #91'
permalink: /zh/newsletters/2020/04/01/
name: 2020-04-01-newsletter-zh
slug: 2020-04-01-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 介绍了一项提案：无需共识变更即可在比特币上部署 statechains；概述了一场关于 schnorr nonce 生成函数的讨论，该函数有助于抵御差分功耗分析；并链接到 BIP322 通用 `signmessage` 的一项提议更新。此外还有我们的常规部分：热门比特币基础设施项目的值得注意的变更。

## 行动项

*本周无。*

## 新闻

- **<!--implementing-statechains-without-schnorr-or-eltoo-->****无需 schnorr 或 eltoo 即可实现 statechains：** statechains 是一种[提议中的][statechain overview]链下系统，允许某个用户（例如 Alice）把花费某个 UTXO 的能力委托给另一个用户（Bob），Bob 还可以再把花费权限转委托给第三个用户（Carol），依此类推。这些链下委托操作都需要与一个受信任的第三方合作才能完成，该第三方只有在与某个被委托的签名者（如此前的受委托人 Alice 或 Bob）串通时才能盗取资金。被委托的签名者始终可以不经受信任第三方许可，直接在链上花费该 UTXO，因此可以说 statechains 需要的信任低于联合[侧链][topic sidechains]。由于任何曾经担任过受委托人的人都能触发链上花费，statechains 采用 [eltoo][topic eltoo] 机制，以确保最新受委托人（Carol）的链上花费能优先于此前受委托人（Alice 和 Bob）的花费——前提是受信任的第三方没有与此前的受委托人串通作弊。

  本周，Tom Trevethan 在 Bitcoin-Dev 邮件列表中[发帖][trevethan statechains]，提出对 statechain 设计的两处修改，使其可以在当前的比特币协议上使用，而不必等待 [schnorr 签名][topic schnorr signatures]和 [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] 这类提议中的软分叉变更：

  1. 用类似[双工微支付通道][duplex micropayment channels]的递减锁定时间替代 eltoo 机制（eltoo 需要 [BIP118][] `SIGHASH_NOINPUT` 或 [bip-anyprevout][] `SIGHASH_ANYPREVOUT`）。例如，当 Alice 获得某个 statechain UTXO 的控制权时，时间锁会阻止她在 30 天内单方面在链上花费它；当 Alice 将 UTXO 转移给 Bob 时，时间锁只限制他 29 天——这使得 Bob 的花费优先于 Alice 的花费。这种做法的不利之处在于，受委托人可能要等很久，才能在不经受信任第三方许可的情况下花掉自己的资金。

  2. 把受信任第三方与当前受委托人之间的 2-of-2 schnorr 多重签名（使用[适配器签名][scriptless scripts]）替换为基于[安全多方计算][mpc]的单签。这种做法的主要缺点是复杂度上升，使安全审查更困难。

  有多人回复了该讨论帖，提出了意见和替代方案。此外还[讨论][patent discussion]了 Trevethan 此前的一项[专利申请][trevethan application]，该专利涉及由受信任第三方通过递减时间锁和多方 ECDSA 保障的链下支付。

- **<!--mitigating-differential-power-analysis-in-schnorr-signatures-->****缓解 schnorr 签名中的差分功耗分析：** Lloyd Fournier 在 Bitcoin-Dev 邮件列表上[发起讨论][fournier dpa]，议题是 [Newsletter #87][news87 bip340 update] 中所述的一项提案：更新 [BIP340][] 中 schnorr 签名的规范，加入一个推荐用的 nonce 生成函数，据称该函数更能抵抗[差分功耗分析][dpa]。功耗分析攻击会监测硬件钱包在生成不同签名时耗用的电量，进而有可能推断出用到了哪个私钥（或泄露足够多的密钥信息，使暴力破解变得可行）。Fournier 质疑：用 xor 运算把私钥与随机数结合，相比更常规的做法——把私钥与随机数一起做哈希——究竟有什么优势。

  BIP340 的合著者 Pieter Wuille [回复][wuille dpa]作了解释：在密钥与签名聚合中，协作各方的私钥之间会建立数学上的关联；如果攻击者本人就是参与协作的一方，他可能把自己掌握的私钥信息，与对其他用户签名生成过程做功耗分析所获得的信息结合起来，从而推断出其他用户的私钥。一般认为，与观察 xor（二进制加法）这类极其简单的函数相比，观察 SHA256 这类相对复杂的哈希函数的功耗会让此类攻击更容易得手。更多信息见 Wuille 链接的他与其他几位比特币密码学家之间的[讨论][nonce function discussion]。

- **<!--proposed-update-to-bip322-generic-signmessage-->****BIP322 通用 `signmessage` 的提议更新：** 几周前，围绕[通用 signmessage][topic generic signmessage]协议的未来展开了一场讨论（见 [Newsletter #88][news88 bip320]）。此后，Karl-Johan Alm [提议][alm bip322 update]做一次简化：移除为不同脚本把多条已签名消息打包在一起的能力，并移除一个未被使用的抽象层，而这一抽象本可以让协议更容易扩展出类似 [BIP127][] 储备证明的功能。欢迎任何对该变更有反馈的人回复邮件列表中的讨论帖，或在[更新草案 BIP 的 PR][BIPs #903] 下留言。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络 BOLT 规范][bolts repo]中的值得注意的变更。*

- [LND #4078][] 添加了 `estimatemode` 配置设置（`CONSERVATIVE` 或 `ECONOMICAL`），用于在从底层 `bitcoind` 后端检索手续费估算时调整估算方式。

{% include references.md %}
{% include linkers/issues.md issues="903,4078,3865" %}
[trevethan statechains]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017714.html
[statechain overview]: https://medium.com/@RubenSomsen/statechains-non-custodial-off-chain-bitcoin-transfer-1ae4845a4a39
[duplex micropayment channels]: https://tik-old.ee.ethz.ch/file//716b955c130e6c703fac336ea17b1670/duplex-micropayment-channels.pdf
[mpc]: https://en.wikipedia.org/wiki/Secure_multi-party_computation
[scriptless scripts]: https://github.com/ElementsProject/scriptless-scripts
[fournier dpa]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017709.html
[wuille dpa]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017711.html
[news87 bip340 update]: /zh/newsletters/2020/03/04/#updates-to-bip340-schnorr-keys-and-signatures
[dpa]: https://en.wikipedia.org/wiki/Power_analysis#Differential_power_analysis
[nonce function discussion]: https://github.com/sipa/bips/issues/195
[alm bip322 update]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017712.html
[news88 bip320]: /zh/newsletters/2020/03/11/#bip322-generic-signmessage-progress-or-perish
[patent note]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017741.html
[patent discussion]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017742.html
[trevethan application]: https://patents.google.com/patent/US20200074464A1
