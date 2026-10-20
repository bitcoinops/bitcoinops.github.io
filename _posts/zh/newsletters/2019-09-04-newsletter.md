---
title: 'Bitcoin Optech Newsletter #62'
permalink: /zh/newsletters/2019/09/04/
name: 2019-09-04-newsletter-zh
slug: 2019-09-04-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 转达了一则针对 LN 实现的安全公告，介绍了一个非交互式 coinjoin 提案，并提及热门比特币基础设施项目的若干变化。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- **<!--upgrade-ln-implementations-->****升级 LN 实现：** 一个或多个定于本月底披露的问题会影响较旧的 LN 实现。如果你使用以下任一软件版本，[强烈建议][cve ln]升级到更新的版本：

  - C-Lightning < 0.7.1
  - LND < 0.7
  - Eclair <= 0.3

## 新闻

- **<!--snicker-proposed-->****SNICKER 提案：** Adam Gibson 在 Bitcoin-Dev 邮件列表上[发帖][snicker email]，提出了一个[提案][snicker]：*Simple Non-Interactive Coinjoin with Keys for Encryption Reused*（SNICKER），这是一种让钱包分两步、以非交互方式创建 coinjoin 的方法：*提议者步骤*（proposer step）与*接收者步骤*（receiver step）。在提议者步骤中，Alice 的钱包利用区块链和 UTXO 集，找出她知道（或能推断出）所有者公钥的 UTXO。她从中挑选一个价值小于自己钱包所控金额的 UTXO，在该 UTXO 和她钱包的 UTXO 之间构造一笔提议的 coinjoin，产生三个输出：

  1. 给 Alice 的 coinjoin 输出

  2. 给所选 UTXO 所有者 Bob 的 coinjoin 输出。两个 coinjoin 输出金额相同，使查看区块链的第三方无法区分二者

  3. 返回给 Alice 的找零输出，退还她超出 coinjoin 金额的那部分资金

  已有交易历史的地址不能重复使用，否则 coinjoin 的隐私优势就会丧失，因此 Alice 为自己的两个输出生成新的唯一地址。然而在这个非交互式协议中，Bob 无法告诉 Alice 该为他的输出使用哪个地址。于是 Alice 可以用 Bob 的公钥做一次[椭圆曲线 Diffie-Hellman][ECDH]（ECDH）密钥协商，推导出一个共享秘密，Bob 同样能从 Alice 的公钥推导出它。有了这个共享秘密和 Bob 的公钥，Alice 就能构造出一个只有 Bob 能为之签名的新公钥。她用这个新公钥为 Bob 的 coinjoin 输出生成新地址。除 Alice 和 Bob 之外，没人能看出这些地址的差别，从而保障 coinjoin 的隐私。

  在掌握输入和输出信息后，Alice 会创建一笔 [BIP174][] 部分签名比特币交易（PSBT），其中包含为她那个（或那些）UTXO 提供的签名。然后她可以把这笔 PSBT 上传到一台公共服务器（还可以加密，使只有 Bob 能解密）。至此，SNICKER 的提议者步骤完成。

  如果 Bob 愿意参与该方案，他的钱包就可以开始接收者步骤：定期查询那台服务器，看是否有像 Alice 这样的人给他发来了提议的 PSBT。如果有，Bob 就可以检查这笔 PSBT 确认无误，补上自己 UTXO 的签名使其最终化，再广播交易，完成这次 coinjoin。

  该提案的主要优势在于 Alice 和 Bob 之间无需任何交互。两人各自独立执行自己的步骤，也不必局限于只把对方当作潜在合作对象。Alice 可以零成本地创建任意数量的提案（只占用服务器存储空间），Bob 则可以通过各种服务器收到来自不同人的多份提案，从中挑选自己中意的一份（也可以一份都不选）。任何一方也可以随时正常花费自己的 UTXO，这会让所有待处理的提案自动失效，且不会造成任何损害。PSBT 可以通过任何不要求用户表明身份的渠道交换，例如经由 Tor 上的普通 FTP 服务器，因此任何人都能轻松架设一台 SNICKER 交换服务器。

  该提案的主要缺点在于，它要求提议者（Alice）知道收款方（Bob）的公钥。如今几乎所有交易输出都支付给不直接包含公钥的地址，不过如果提议的 [taproot][bip-taproot] 软分叉获得激活并得到广泛采用，这种情况可能会改变。在此之前，SNICKER 提案建议扫描那些已在区块链上暴露公钥的重复使用地址，或者改用创建该 UTXO 的交易输入中的公钥。关于该提案更详细的介绍，请参见 [Gibson 的博客文章][snicker blog]。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]中值得注意的变更。*

- [C-Lightning #3002][] 做了几处小改动，以符合 LN 规范近期的更新，其中包括按[上周的 Newsletter][bolts608] 所述、由 [BOLT4][] 移除 `final_expiry_too_soon` 错误消息的更新。

- [Eclair #899][] 按 [BOLTs #557][] 的提议实现了扩展查询，允许 LN 节点只请求在某个时间之后到达的 gossip 更新，或校验和与该节点已见过的那些不同的更新。

- [Eclair #954][] 添加了一个同步白名单。如果为空，节点将与任何对等方同步其 gossip 存储。如果不为空，节点将仅与指定的对等方同步。

{% include linkers/issues.md issues="3002,899,557,954" %}

[cve ln]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-August/002130.html
[bolts608]: /zh/newsletters/2019/08/28/#bolts-608
[bolts]: https://github.com/lightningnetwork/lightning-rfc/
[snicker]: https://gist.github.com/AdamISZ/2c13fb5819bd469ca318156e2cf25d79
[ecdh]: https://en.wikipedia.org/wiki/Elliptic-curve_Diffie–Hellman
[snicker email]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-September/017283.html
[snicker blog]: https://joinmarket.me/blog/blog/snicker/
