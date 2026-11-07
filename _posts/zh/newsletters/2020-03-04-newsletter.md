---
title: 'Bitcoin Optech Newsletter #87'
permalink: /zh/newsletters/2020/03/04/
name: 2020-03-04-newsletter-zh
slug: 2020-03-04-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了对 BIP340 Schnorr 密钥和签名的一项提议更新，就改进全节点启动时功能协商的提议征求意见，探讨了标准化一种防止硬件钱包利用有偏的 nonce 泄露私钥的做法，并链接到一篇分析，说明要让 Taproot 安全，哈希函数必须具备哪些属性。此外还有我们的常规部分：发布公告，以及热门比特币基础设施项目的值得注意的变更。

## 行动项

*本周无。*

## 新闻

- **<!--updates-to-bip340-schnorr-keys-and-signatures-->****BIP340 Schnorr 密钥和签名的更新：**正如之前在 Newsletter #84 的两项内容中提到的（[1][news83 safety]、[2][news83 tiebreaker]），已提议对 [BIP340][] Schnorr 签名进行多项更新（这些更新也会影响 [BIP341][] Taproot）。Pieter Wuille [建议][wuille update]更改 [BIP340][] 中该使用哪一种公钥变体，新的选择方式改为依据密钥是否为偶数。此外，nonce 的推荐生成流程也已更改：在生成 nonce 时纳入公钥，在有独立生成的随机数可用时将其纳入，并在 nonce 生成算法中增加一步，用该随机数来混淆私钥，以保护密钥免受[差分功耗分析][differential power analysis]攻击。

  由于其中一些更改影响重大，BIP340 中带标签哈希所用的标签也已更改，从而确保任何针对早期草案编写的代码，在提议的修订版本下生成的签名都会验证失败。Wuille 请求社区就这些更改提供反馈。

- **<!--improving-feature-negotiation-between-full-nodes-at-startup-->****改进全节点启动时的功能协商：** Suhas Daftuar [请求反馈][daftuar wtxid]，讨论一项提议：在节点与新对等节点建立连接的流程中插入一条消息。这条新消息可以让节点更容易协商自己希望从对等节点接收哪些功能。<!-- A challenge here is that previous versions of Bitcoin Core would terminate a new connection if certain messages didn't appear in a particular order, and it's into this strict sequence that Daftuar wants to insert a new message.-->该提议确实递增了 P2P 协议版本以提供向后兼容性，但 Daftuar 希望了解全节点维护者的看法：插入协商消息是否会引发问题。如果你知道任何问题，请在讨论帖中回复。

  *更正 (2020-12-16)：上述段落已编辑，删除了有关在版本协商期间插入消息存在向后兼容性问题的错误说法。原文以 HTML 注释形式保留。*

- **<!--proposal-to-standardize-an-exfiltration-resistant-nonce-protocol-->****提议标准化一套防止数据外泄的 nonce 协议：** Stepan Snigirev 在 Bitcoin-Dev 邮件列表中[发起][snigirev nonce]讨论，议题是标准化一套协议，防止硬件钱包利用有偏的 nonce 泄露用户的私钥。针对此类攻击，一种[此前提出过][sign to contract]的防御机制是使用*签名到合约协议*，验证签名是否绑定了由硬件钱包所连主机或移动设备选定的随机数。libsecp256k1 的开发者已经在开发一个 API，既能[启用通用的签名到合约][secp s2c]，也能在此基础上构建[防止数据外泄的 nonce 能力][secp nonce]。Snigirev 的邮件描述了当前首选的协议，以及如何把它扩展到多台计算机和部分签名比特币交易（[PSBT][topic psbt]）上。

- **<!--taproot-in-the-generic-group-model-->****通用群模型下的 Taproot：** Lloyd Fournier 两周前发布了他为 Financial Cryptography 会议准备的[海报][fournier poster]，其中描述了要在 Taproot 中使用的哈希函数必须具备哪些属性，Taproot 才是安全的。这扩展了 Andrew Poelstra 此前的一项[证明][poelstra proof]，该证明的假设更宽泛，即假定哈希函数充当[随机预言机][random oracle]。我们鼓励评估 Taproot 密码学安全性的人阅读 Poelstra 的证明和 Fournier 的海报。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [LND 0.9.1][] 是一个新的次要版本发布，不含任何新功能，但修复了若干缺陷，其中包括一个可能导致“节点之间错误地强制关闭”的缺陷。

- [Bitcoin Core 0.19.1][]（候选发布）

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo] 和 [闪电网络 BOLT 规范][bolts repo] 中的值得注意的变更。*

- [Bitcoin Core #17985][] 移除了一段死代码，这段代码本应从白名单对等节点中继交易，即使这些交易会被内存池（mempool）拒绝。该功能在 Bitcoin Core 0.13.0 中就已失效，至于这是有意为之还是意外，目前并不清楚。

- [Bitcoin Core #17264][] 更改了创建或处理部分签名比特币交易（[PSBT][topic psbt]）的 RPC 默认设置，以包含任何已知的 [BIP32][] HD 钱包派生路径。这允许后续处理 PSBT 的其他钱包使用该信息来选择适当的签名密钥，或验证找零输出是否支付到正确的地址。那些希望保持派生路径私密性的人可以使用 `bip32_derivs` 参数来禁用共享。

- [C-Lightning #3490][] 新增一个 `getsharedsecret` RPC，它用本地节点的私钥与用户指定的公钥组合，导出一个共享密钥。这个共享密钥的导出方式与 LN 协议中其他共享密钥一致（对 ECDH 结果取 SHA256 摘要），这可能不同于其他程序用椭圆曲线密码学导出共享密钥的方式（例如 ECIES）。对于希望与其他 LN 节点加密通信的插件，这个 RPC 很有用。

- [Eclair #1307][] 更新了 Eclair 使用的打包脚本，生成的 zip 文件包含使用该软件所需的全部内容。这一新方法使 Eclair GUI 也能像核心库一样进行确定性构建（我们在 [Newsletter #83][news83 eclair determ] 中报道过核心库的情况）。[可重复构建][topic reproducible builds]能帮助用户确认自己所运行的软件确实基于经过公开审查的源代码。

- [Libsecp256k1 #710][] 对库做了一些小改动，以便于测试。其中一处改动是：一个[函数][secp256k1_ecdh]原先可能返回一系列取值（与其文档描述的行为不符），现在只会返回 `0` 或 `1`。至少还有一个库[依赖][rust-secp256k1 ecdh ret]旧的返回行为，而且有人在 #secp256k1 IRC 聊天室中[提出担忧][ruffing concern]：其他程序或库可能也在沿用这种本不推荐的旧行为。如果你的程序用到了 `secp256k1_ecdh` 函数，建议看看[该 PR 下的讨论][710 comment]以及相关的 [rust-secp256k1 issue][rust-secp256k1 #196]。

- [BIPs #886][] 为 [BIP340][] Schnorr 签名增加了两项建议：（1）只要有随机数生成器可用，就在 nonce 计算中加入熵；（2）在把软件生成的签名分发给外部程序之前先验证其有效性，至少当额外的计算与延迟不构成负担时要这样做。这两步有助于确保攻击者无法通过获取使用重复 nonce 的无效签名来恢复用户的私钥；攻击细节见 [Newsletter #83][news83 safety]。关于 BIP340 的其他提议更改，请参见本期 Newsletter 上方的[新闻条目][bip340 update]。

{% comment %}<!-- BOLTs #714 merged but reverted -->{% endcomment %}

{% include references.md %}
{% include linkers/issues.md issues="17985,17264,3490,1307,710,886" %}
[bitcoin core 0.19.1]: https://bitcoincore.org/bin/bitcoin-core-0.19.1/
[lnd 0.9.1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.9.1-beta.rc1
[fournier poster]: https://github.com/LLFourn/taproot-ggm/blob/master/main.pdf
[poelstra proof]: https://github.com/apoelstra/taproot/blob/master/main.pdf
[random oracle]: https://en.wikipedia.org/wiki/Random_oracle
[differential power analysis]: https://en.wikipedia.org/wiki/Power_analysis#Differential_power_analysis
[bip-wtxid-relay]: https://github.com/sdaftuar/bips/blob/2020-02-wtxid-relay/bip-wtxid-relay.mediawiki
[news83 safety]: /zh/newsletters/2020/02/05/#safety-concerns-related-to-precomputed-public-keys-used-with-schnorr-signatures
[news83 tiebreaker]: /zh/newsletters/2020/02/05/#alternative-x-only-pubkey-tiebreaker
[wuille update]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-February/017639.html
[daftuar wtxid]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-February/017648.html
[snigirev nonce]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-February/017655.html
[sign to contract]: https://www.wpsoftware.net/andrew/secrets/slides.pdf
[secp s2c]: https://github.com/bitcoin-core/secp256k1/pull/589
[secp nonce]: https://github.com/bitcoin-core/secp256k1/pull/590
[ecdh]: https://en.wikipedia.org/wiki/Elliptic-curve_Diffie–Hellman
[ecies]: https://en.wikipedia.org/wiki/Integrated_Encryption_Scheme
[bip340 update]: #updates-to-bip340-schnorr-keys-and-signatures
[news83 eclair determ]: /zh/newsletters/2020/02/05/#eclair-1295
[secp256k1_ecdh]: https://github.com/bitcoin-core/secp256k1/blob/96d8ccbd16090551aa003bfa4acd108b0496cb89/src/modules/ecdh/main_impl.h#L29-L69
[rust-secp256k1 ecdh ret]: https://github.com/rust-bitcoin/rust-secp256k1/blob/master/src/ecdh.rs#L162
[ruffing concern]: https://gist.githubusercontent.com/harding/603c2b18241bf61bb0bbe7a0383cf1c9/raw/20656e901472f217d1faa381ddda1d11214900da/foo.txt
[710 comment]: https://github.com/bitcoin-core/secp256k1/pull/710#discussion_r370987476
[rust-secp256k1 #196]: https://github.com/rust-bitcoin/rust-secp256k1/issues/196
