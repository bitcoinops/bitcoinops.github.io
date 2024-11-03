---
title: 'Bitcoin Optech Newsletter #62'
permalink: /zh/newsletters/2019/09/04/
name: 2019-09-04-newsletter-zh
slug: 2019-09-04-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 传达了有关 LN 实现的安全公告，描述了一个非交互式 Coinjoin 提案，并指出了一些流行的比特币基础设施项目的变化。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- **<!--upgrade-ln-implementations-->****升级 LN 实现：** 定于本月底披露的一个或多个问题会影响较旧的 LN 实现。如果您使用以下软件版本，[强烈建议][cve ln]升级到更新版本：

  - C-Lightning < 0.7.1
  - LND < 0.7
  - Eclair <= 0.3

## 新闻

- **<!--snicker-proposed-->****SNICKER 提案：** Adam Gibson 在 Bitcoin-Dev 邮件列表上发布了一个[提案][snicker email]，描述了 *Simple Non-Interactive Coinjoin with Keys for Encryption Reused*（SNICKER），这是一种允许钱包通过两个步骤非交互式创建 Coinjoin 的方法：*提议者步骤* 和 *接收者步骤*。在提议者步骤中，Alice 的钱包使用区块链和 UTXO 集找到她知道（或可以推断）拥有者公钥的 UTXO。她选择其中一个 UTXO，其价值小于她钱包控制的金额，并创建一个包含该 UTXO 和她钱包的 UTXO 的提议 Coinjoin，生成三个输出：

  1. 给 Alice 的 Coinjoin 输出

  2. 给所选 UTXO 拥有者 Bob 的 Coinjoin 输出。两个 Coinjoin 输出支付相同的金额，使其在第三方观察区块链时不可区分

  3. 返回给 Alice 的找零输出，返还超过 Coinjoin 金额的任何资金

  已有交易历史的地址不能重复使用，否则 Coinjoin 的隐私效益将丧失，因此 Alice 为她的两个输出生成新的唯一地址。然而，在这个非交互式协议中，Bob 无法告诉 Alice 应该为他的输出使用哪些地址。相反，Alice 可以使用 Bob 的公钥和[椭圆曲线 Diffie-Hellman][ECDH]（ECDH）推导出一个 Bob 也能从 Alice 的公钥推导出的共享密钥。使用该共享密钥和 Bob 的公钥，Alice 能够创建一个只有 Bob 能签署的新公钥。这个新公钥用于为 Bob 的 Coinjoin 输出创建新地址。除了 Alice 和 Bob 之外，没有人能区分这些地址，确保 Coinjoin 的隐私性。

  有了关于输入和输出的信息，Alice 创建了一个 [BIP174][] 部分签名的比特币交易（PSBT），其中包含她的 UTXO 或 UTXOs 的签名。然后她可以将此 PSBT 上传到一个公共服务器（并且可以对其进行加密，使只有 Bob 能解密）。这完成了 SNICKER 的提议者步骤。

  如果 Bob 参与该方案，他的钱包可以通过定期检查服务器来查看是否有像 Alice 这样的人向他发送了提议的 PSBT。如果是，Bob 可以评估 PSBT 以确保其正确性，添加他 UTXO 的签名以完成交易，并广播该交易以完成 Coinjoin。

  该提案的主要优势在于 Alice 和 Bob 之间不需要互动。他们各自独立完成自己的步骤，并且不受限于将对方作为潜在合作伙伴。Alice 可以创建任意数量的提案，而无需任何成本（除了服务器存储空间），Bob 可以通过各种服务器接收来自不同人的多个提案，选择他喜欢的提案（或者根本不选择）。任何一方也可以随时正常花费他们的 UTXO，自动使任何未完成的提案失效，且不会造成任何损害。PSBT 可以通过任何不要求用户识别自己的媒介进行交换，例如通过 Tor 上的简单 FTP 服务器，使任何人都能轻松托管 SNICKER 交换服务器。

  该提案的主要缺点在于提议者（Alice）需要知道接收者（Bob）的公钥。如今，几乎所有交易输出都支付给不直接包含公钥的地址，尽管如果提议的 [taproot][bip-taproot] 软分叉被激活并广泛采用，这种情况可能会改变。在此期间，SNICKER 提案建议扫描区块链上已公开公钥的重复使用地址，或者使用创建 UTXO 的交易输入中的公钥。有关该提案的详细概述，请参见 [Gibson 的博客文章][snicker blog]。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的更改。*

- [C-Lightning #3002][] 进行了几个小的更改，以符合 LN 规范的最新更新，包括 [BOLT4][] 更新，移除了 `final_expiry_too_soon` 错误消息，正如[上周的 Newsletter][bolts608] 所描述的。

- [Eclair #899][] 实现了 [BOLTs #557][] 提出的扩展查询，允许 LN 节点仅请求在某个时间之后到达的 gossip 更新，或者具有不同校验和的更新。

- [Eclair #954][] 添加了一个同步白名单。如果为空，节点将与任何对等方同步其 gossip 存储。如果不为空，节点将仅与指定的对等方同步。

{% include linkers/issues.md issues="3002,899,557,954" %}

[cve ln]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-August/002130.html
[bolts608]: /zh/newsletters/2019/08/28/#bolts-608
[bolts]: https://github.com/lightningnetwork/lightning-rfc/
[snicker]: https://gist.github.com/AdamISZ/2c13fb5819bd469ca318156e2cf25d79
[ecdh]: https://en.wikipedia.org/wiki/Elliptic-curve_Diffie–Hellman
[snicker email]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-September/017283.html
[snicker blog]: https://joinmarket.me/blog/blog/snicker/
