---
title: 'Bitcoin Optech Newsletter #87'
permalink: /zh/newsletters/2020/03/04/
name: 2020-03-04-newsletter-zh
slug: 2020-03-04-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了对 BIP340 Schnorr 密钥和签名的一个提议更新，征求对改进全节点启动时功能协商提议的反馈，分析了一种防止硬件钱包使用损坏的 nonce 泄露私钥的标准化方法，并链接到对保证 Taproot 安全的哈希函数所需属性的分析。同时，还包括我们的常规部分：发布公告和热门比特币基础设施项目的值得注意的更改。

## 行动项

*本周无。*

## 新闻

- **<!--updates-to-bip340-schnorr-keys-and-signatures-->****BIP340 Schnorr 密钥和签名的更新：**正如之前在 Newsletter #84 的两项内容中提到的 ([1][news83 safety], [2][news83 tiebreaker])，已提议对 [BIP340][] Schnorr 签名进行多项更新（这些更新也会影响 [BIP341][] Taproot）。Pieter Wuille [建议][wuille update] 更改 [BIP340][] 中应使用的公钥变体，新选择将基于密钥的偶数性。此外，生成 nonce 的推荐流程也已更改，包括在生成 nonce 时包含公钥、在可用时加入独立生成的随机数，并在 nonce 生成算法中增加一个步骤，使用随机数来混淆私钥，以保护密钥免受[差分功率分析][differential power analysis]攻击。

  由于这些更改的重大意义，BIP340 中标记哈希的标签已更改，确保针对早期草案编写的任何代码在拟议的修订版本下生成的签名将无法通过验证。Wuille 请求社区对这些更改提供反馈。

- **<!--improving-feature-negotiation-between-full-nodes-at-startup-->****改进全节点启动时的功能协商：**Suhas Daftuar [请求反馈][daftuar wtxid]，讨论在节点与新对等节点建立连接的过程中插入一个消息的提议。新消息将使节点更容易协商其希望从对等节点接收的功能。<!--a-challenge-here-is-that-previous-versions-of-bitcoin-core-would-terminate-a-new-connection-if-certain-messages-didn't-appear-in-a-particular-order,-and-it's-into-this-strict-sequence-that-daftuar-wants-to-insert-a-new-message-->该提议通过增加 P2P 协议版本以提供向后兼容性，但 Daftuar 正在寻求全节点维护者的反馈，了解插入协商消息是否会导致任何问题。如果你发现任何问题，请在讨论中回复。

  *更正 (2020-12-16)：上述段落已编辑，删除了有关在版本协商期间插入消息存在向后兼容性问题的错误说法。原文以 HTML 注释形式保留。*

- **<!--proposal-to-standardize-an-exfiltration-resistant-nonce-protocol-->****标准化防止数据泄露的 nonce 协议的提议：**Stepan Snigirev 在 Bitcoin-Dev 邮件列表中[发起][snigirev nonce]关于标准化一种防止硬件钱包使用偏差 nonce 泄露用户私钥的协议的讨论。一种[之前提出的][sign to contract]防御此类攻击的机制是使用*签名到合约协议*来验证签名是否承诺了由硬件钱包的主机计算机或移动设备选择的随机数。libsecp256k1 的开发者已经在开发一个 API，以支持[通用签名到合约][secp s2c]并基于此构建[防数据泄露的 nonce 功能][secp nonce]。Snigirev 的邮件描述了当前首选的协议及其如何扩展到多台计算机和部分签名的比特币交易（[PSBTs][topic psbt]）。

- **<!--taproot-in-the-generic-group-model-->****通用群模型中的 Taproot：**Lloyd Fournier 发布了他在两周前的金融密码学会议上展示的[海报][fournier poster]，描述了使用 Taproot 时，为了保证其安全性，所需哈希函数必须具备的属性。这扩展了 Andrew Poelstra 之前的一项[证明][poelstra proof]，该证明更广泛地假设了哈希函数作为[随机预言机][random oracle]。那些评估 Taproot 加密安全性的人士被鼓励查看 Poelstra 的证明和 Fournier 的海报。

## 发布与候选发布

*热门比特币基础设施的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [LND 0.9.1][] 是一个新的小版本更新，未包含新功能，但修复了多个漏洞，包括一个可能导致“节点之间错误强制关闭”的问题。

- [Bitcoin Core 0.19.1][]（候选发布）

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo] 和 [闪电网络规范][bolts repo] 中的值得注意的更改。*

- [Bitcoin Core #17985][] 移除了原本应该从白名单对等节点中中继交易的无效代码，即使这些交易会被 mempool 拒绝。该功能在 Bitcoin Core 0.13.0 中停止工作，但不清楚这是有意为之还是意外。

- [Bitcoin Core #17264][] 更改了创建或处理部分签名比特币交易（[PSBTs][topic psbt]）的 RPC 默认设置，以包含任何已知的 [BIP32][] HD 钱包派生路径。这允许后续处理 PSBT 的其他钱包使用该信息来选择适当的签名密钥，或验证找零输出是否支付到正确的地址。那些希望保持派生路径私密性的人可以使用 `bip32_derivs` 参数来禁用共享。

- [C-Lightning #3490][] 增加了一个 `getsharedsecret` RPC，它将通过本地节点的私钥和用户指定的公钥组合来导出共享密钥。该共享密钥与 LN 协议中导出的其他共享密钥相同（ECDH 结果的 SHA256 摘要），这可能与其他程序使用椭圆曲线密码学（如 [ECIES][]）导出的共享密钥不同。这个 RPC 对于希望与其他 LN 节点加密通信的插件很有用。

- [Eclair #1307][] 更新了 Eclair 使用的打包脚本，生成包含使用该软件所需全部内容的 zip 文件。这种新方法使得 Eclair GUI 除核心库外也可以进行可重复构建（我们在 [Newsletter #83][news83 eclair determ] 中报道过）。[可重复构建][topic reproducible builds] 帮助用户确保他们运行的软件基于公开审核过的源代码。

- [Libsecp256k1 #710][] 对库进行了细微调整以帮助测试。其中一个更改使得一个[函数][secp256k1_ecdh] 现在只返回 `0` 或 `1`，不再像之前那样返回多个值（与其文档行为不符）。至少有一个其他库[使用][rust-secp256k1 ecdh ret]了旧行为，并且在 #secp256k1 IRC 聊天室中[提到][ruffing concern]了其他程序或库可能也在使用旧的未建议行为。如果你的程序使用了 `secp256k1_ecdh` 函数，请考虑查看[该 PR 的讨论][710 comment]及相关的 [rust-secp256k1 issue][rust-secp256k1 #196]。

- [BIPs #886][] 更新了 [BIP340][] Schnorr 签名，提出两项建议：（1）在随机数生成器可用时，在 nonce 计算中加入熵；（2）在将签名分发给外部程序之前，验证软件生成的签名是否有效，至少在额外的计算和延迟不是负担的情况下。这两个步骤有助于确保攻击者无法通过获取使用重复 nonce 的无效签名来恢复用户的私钥；有关攻击详情，请参见 [Newsletter #83][news83 safety]。有关 BIP340 的其他拟议更改，请参见本周 Newsletter 中的[新闻项目][bip340 update]。

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
