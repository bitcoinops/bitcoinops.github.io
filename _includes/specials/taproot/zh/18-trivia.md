{% auto_anchor %}

- ​**<!--what-is-a-taproot-->**​**什么是 Taproot？** 维基百科[解释][wikipedia taproot]："主根（taproot）是一种大型、中心化且占主导地位的根系，其他根须从其侧面生长。典型的主根较为笔直粗壮、呈锥形且垂直向下生长。某些植物（如胡萝卜）的主根作为储存器官高度发达，已被培育为蔬菜。"

  这与比特币有何关联？

  - "我一直认为这个名字源于'接入默克尔根（taps into the Merkle root）'，但实际并不清楚 Gregory Maxwell 的命名思路。" ——Pieter Wuille（[来源][wuille taproot name]）

  - "我最初不得不查阅这个词的含义；但将其理解为密钥路径是'主根'，因为这是可食用的部分（用于制作胡萝卜汤），而默克尔化的脚本则是其他次要根须（希望被忽略）。" ——Anthony Towns（[来源][towns taproot name]）

  - "该名称源自对蒲公英主根般粗壮中心树干的视觉化想象——该技术的主要价值在于假设存在一条高概率路径（其他为杂乱次要路径）。此外，'taproot' 的双关含义也贴切，因为其通过根部的隐藏承诺来验证脚本路径支付。

    [...] 可惜，将带有排序内部节点的哈希树称为'myrtle 树'（取自桃金娘科，含茶树等）并未流行，尽管其发音类似'merkle'且有数学排列特性。" ——Gregory Maxwell（[来源][maxwell taproot name]）

- ​**<!--schnorr-signatures-predate-ecdsa-->**​**Schnorr 签名早于 ECDSA：​** 尽管我们将 [schnorr 签名][topic schnorr signatures] 视为比特币原始 ECDSA 签名的升级（因其更易实现密码学技巧），但 schnorr 签名算法其实早于 ECDSA 所基于的 DSA 算法。事实上，DSA 的创建部分是为了规避 Claus Peter Schnorr 的 [schnorr 签名专利][schnorr patent]，但 Schnorr 仍[声称][schnorr letter]"我的专利适用于各类离散对数签名实现，包括 Nyberg-Rueppel 和 DSA"。目前无法院支持此主张，且其专利已于 2011 年过期。

- ​**<!--unsure-what-name-to-use-->**​**命名争议：​** 在比特币采用 schnorr 签名的早期，曾有[建议][dryja bn sigs]避免使用 Schnorr 之名，因其专利阻碍了该密码学技术的普及。Pieter Wuille [解释][wuille dls]："我们曾考虑将 [BIP340][] 命名为'DLS'（离散对数签名），但最终因 Schnorr 之名已被广泛讨论而未采纳。"

- ​**<!--schnorr-signatures-for-twisted-edwards-curves-->**​**扭曲爱德华曲线的 Schnorr 签名：​** 2011 年发布的 [EdDSA][] 方案将 schnorr 签名应用于椭圆曲线，现已成为多项标准的基础。虽然未用于比特币共识层，但 Optech 追踪的多个比特币代码库中可见其相关引用。


- ​**<!--pay-to-contract-->**​**支付到合约：​** Ilja Gerhardt 和 Timo Hanke 在 2013 年圣何塞比特币大会上提出的[协议][gh p2c]， <!-- source: Wuille; I found some independent confirmation in dead links on Google -harding -->允许支付承诺至合约哈希。持有合约和防攻击随机数的任何人都可验证该承诺，但对他人而言该支付与普通比特币支付无异。

  2014 年[侧链论文][sidechains.pdf]中的改进版 P2C 额外承诺原始公钥。Taproot 采用相同结构，但其承诺对象为接收方设定的链上花费条件（而非链下合约条款）。

- ​**<!--a-good-morning-->**​**灵感诞生地：​** 使脚本支付与公钥支付在链上表现相同的 P2C 创意，由 Andrew Poelstra 和 Gregory Maxwell 于 2018 年 1 月 22 日在加利福尼亚州洛斯阿尔托斯的 "A Good Morning" 餐厅构思。Pieter Wuille 回忆："这个想法在我暂时离开餐桌时诞生... !$%@" [原文如此]

- ​**<!--x-2-5-years-in-1-5-days-->**​**2.5 年浓缩至 1.5 天：​** 确定 [bech32m][topic bech32] 的最佳常数消耗了[约][wuille matrix elimination] 2.5 年 CPU 时间，最终借 Gregory Maxwell 的 CPU 集群在 1.5 天内完成计算。

*感谢 Anthony Towns、Gregory Maxwell、Jonas Nick、Pieter Wuille 和 Tim Ruffing 为本栏目提供的见解。文中错误由作者负责。*

{% endauto_anchor %}

[wikipedia taproot]: https://en.wikipedia.org/wiki/Taproot
[dryja bn sigs]: https://diyhpl.us/wiki/transcripts/discreet-log-contracts/
[bitcoin.pdf]: https://www.opencrypto.org/bitcoin.pdf
[schnorr patent]: https://patents.google.com/patent/US4995082
[ed25519]: https://ed25519.cr.yp.to/ed25519-20110926.pdf
[eddsa]: https://en.wikipedia.org/wiki/EdDSA
[gh p2c]: https://arxiv.org/abs/1212.3257
[sidechains.pdf]: https://www.blockstream.com/sidechains.pdf
[wuille matrix elimination]: https://twitter.com/pwuille/status/1335761447884713985
[wuille dls]: https://github.com/bitcoinops/bitcoinops.github.io/pull/667#discussion_r731372937
[wuille taproot name]: https://github.com/bitcoinops/bitcoinops.github.io/pull/667#discussion_r731371163
[towns taproot name]: https://github.com/bitcoinops/bitcoinops.github.io/pull/667#discussion_r731523855
[schnorr letter]: https://web.archive.org/web/19991117143502/http://grouper.ieee.org/groups/1363/letters/SchnorrMar98.html
[maxwell taproot name]: https://github.com/bitcoinops/bitcoinops.github.io/pull/667#discussion_r732189216
