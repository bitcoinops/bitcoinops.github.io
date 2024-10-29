---
title: 'Bitcoin Optech Newsletter #91'
permalink: /zh/newsletters/2020/04/01/
name: 2020-04-01-newsletter-zh
slug: 2020-04-01-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了一个提案，旨在无需共识变更即可在比特币上部署 statechains，概述了关于 schnorr 随机数生成函数的讨论，该函数有助于防止差分功率分析攻击，并链接到 BIP322 通用 `signmessage` 的提议更新。此外，还包括我们关于比特币基础设施项目的定期“值得注意的更改”部分。

## 行动项

*本周无。*

## 新闻

- **<!--implementing-statechains-without-schnorr-or-eltoo-->****无需 schnorr 或 eltoo 的 statechains 实现：** statechains 是一种[提议的][statechain overview]链下系统，允许用户（例如 Alice）将花费某个 UTXO 的能力委托给另一个用户（Bob），然后 Bob 可以进一步将花费权限委托给第三方用户（Carol）等。这些链下委托操作都是通过受信任的第三方合作完成的，除非他们与委托签名者（如之前的委托者 Alice 或 Bob）串通，否则无法窃取资金。委托签名者可以始终无需第三方的许可在链上花费 UTXO，这使得 statechains 的信任要求低于联合[侧链][topic sidechains]。由于曾经的任何委托者都可以触发链上花费，statechains 设计为使用 [eltoo][topic eltoo] 机制，确保最近的委托者（Carol）的链上花费可以优先于之前委托者（Alice 和 Bob）的花费，前提是受信任的第三方没有与之前的委托者串通作弊。

  本周，Tom Trevethan 在 Bitcoin-Dev 邮件列表中[发帖][trevethan statechains]，讨论了两种 statechain 设计的修改，可能允许它在现有的比特币协议下使用，而无需等待提议的软分叉更改，例如 [schnorr 签名][topic schnorr signatures]和 [SIGHASH_ANYPREVOUT][topic sighash_anyprevout]：

  1. 用类似于[双工微支付通道][duplex micropayment channels]的递减锁定时间替代 eltoo 机制（eltoo 需要 [BIP118][] `SIGHASH_NOINPUT` 或 [bip-anyprevout][] `SIGHASH_ANYPREVOUT`）。例如，当 Alice 获得 statechain UTXO 的控制权时，时间锁会阻止她在 30 天内单方面将其链上花费；当 Alice 将 UTXO 转移给 Bob 时，时间锁将限制他 29 天——这使得 Bob 的花费优先于 Alice。此方法的缺点是，委托者可能需要等待较长时间才能无需受信任的第三方许可来花费其资金。

  2. 用[安全多方计算][mpc]的单签替代受信任第三方与当前委托者之间的 2-of-2 schnorr 多重签名（使用[适配签名][scriptless scripts]）。此方法的主要缺点是增加了复杂性，使得安全审查更加困难。

  多位参与者对该帖子进行了回复，提出了评论和建议的替代方案。还[讨论了][patent discussion] Trevethan 之前的一项[专利申请][trevethan application]，该专利与受信任的第三方通过递减时间锁和多方 ECDSA 确保的链下支付有关。

- **<!--mitigating-differential-power-analysis-in-schnorr-signatures-->****缓解 schnorr 签名中的差分功率分析：** Lloyd Fournier 在 Bitcoin-Dev 邮件列表上发起了一场[讨论][fournier dpa]，该讨论涉及在[Newsletter #87][news87 bip340 update]中描述的关于更新 [BIP340][] 规范以推荐一种声称更能抵抗[差分功率分析][dpa]的随机数生成函数的提案。功率分析攻击涉及监控硬件钱包在生成不同签名时使用的电量，以潜在地推测出使用的私钥（或揭示足够的信息使得有效的暴力破解成为可能）。Fournier 质疑通过 xor 操作结合私钥和随机数是否比通过更标准的方法将私钥与随机数进行哈希处理更有效。

  BIP340 的共同作者 Pieter Wuille [回复][wuille dpa]解释道：在密钥和签名聚合中，当多个用户的私钥之间建立了数学关系时，攻击者——如果他是这些合作用户之一——可能能够将其私钥的知识与通过功率分析从其他用户的签名生成中获取的信息结合起来，从而了解其他用户的私钥。据认为，当观察相对复杂的哈希函数（如 SHA256）的功率消耗时，与观察相对简单的 xor（二进制加法）函数相比，此类攻击更容易执行。有关更多信息，Wuille 链接到他与几位比特币密码学家之间的[讨论][nonce function discussion]。

- **<!--proposed-update-to-bip322-generic-signmessage-->****提议更新 BIP322 通用 `signmessage`：** 在几周前发起了一场关于[通用 signmessage][topic generic signmessage]协议未来的讨论之后（见[Newsletter #88][news88 bip320]），Karl-Johan Alm 已[提议][alm bip322 update]简化此协议，移除捆绑多个脚本的已签消息的功能，并删除了一个未使用的抽象，这一抽象本可以更容易地将协议扩展为类似于 [BIP127][] 的储备证明。任何对此更改有反馈的人都被鼓励回复邮件列表线程或[更新草案 BIP 的拉取请求][BIPs #903]。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的更改。*

- [LND #4078][] 添加了 `estimatemode` 配置设置（`CONSERVATIVE` 或 `ECONOMICAL`），用于在从底层 `bitcoind` 后端检索手续费估算时调整估算方式。

{% include references.md %}
{% include linkers/issues.md issues="903,4078,3865" %}
[trevethan statechains]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017714.html
[statechain overview]: https://medium.com/@RubenSomsen/statechains-non-custodial-off-chain-bitcoin-transfer-1ae4845a4a39
[duplex micropayment channels]: https://tik-old.ee.ethz.ch/file//716b955c130e6c703fac336ea17b1670/duplex-micropayment-channels.pdf
[mpc]: https://en.wikipedia.org/wiki/Secure_multi-party_computation
[scriptless scripts]: https://github.com/ElementsProject/scriptless-scripts
[fournier dpa]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017709.html
[wuille dpa]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017711.html
[news87 bip340 update]: /zh/newsletters/2020/03/04/#updates-to-bip340-schnorr-keys-and-signatures
[dpa]: https://en.wikipedia.org/wiki/Power_analysis#Differential_power_analysis
[nonce function discussion]: https://github.com/sipa/bips/issues/195
[alm bip322 update]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017712.html
[news88 bip320]: /zh/newsletters/2020/03/11/#bip322-generic-signmessage-progress-or-perish
[patent note]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017741.html
[patent discussion]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017742.html
[trevethan application]: https://patents.google.com/patent/US20200074464A1
