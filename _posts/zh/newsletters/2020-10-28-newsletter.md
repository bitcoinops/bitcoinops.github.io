---
title: 'Bitcoin Optech Newsletter #121'
permalink: /zh/newsletters/2020/10/28/
name: 2020-10-28-newsletter-zh
slug: 2020-10-28-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了 LND 中两个漏洞的披露，并包含了我们的常规部分：Bitcoin Stack Exchange 的热门问题和答案摘要、发布与候选发布的公告，以及对流行比特币基础设施软件的更改描述。

## 行动项

- **<!--ensure-lnd-nodes-are-upgraded-to-0-11-->****确保 LND 节点已升级到 0.11+：** 正如 [Newsletter #119][news119 lnd] 中所警告的，旧版本 LND 的两个漏洞的完整披露现已公开。两个漏洞都可能导致受影响的 LN 节点的资金被盗，因此强烈建议立即升级到 LND 0.11.0-beta 或 LND 0.11.1-beta。其他 LN 实现不受所述漏洞的影响。

## 新闻

- **<!--full-disclosures-of-recent-lnd-vulnerabilities-->****最近 LND 漏洞的完整披露：** 本周，LND 共同维护者 Conner Fromknecht 和漏洞发现者 Antoine Riard 在 Lightning-Dev 邮件列表中完整披露了影响 LND 的两个漏洞。

  - **<!--cve-2020-26895-acceptance-of-non-standard-signatures-->****[CVE-2020-26895][] 接受非标准签名：** 在某些情况下，LND 会接受一个 Bitcoin Core 默认不会中继或挖矿的交易签名。当包含不可中继签名的交易未能确认时，时间锁最终会到期，攻击者能够窃取之前支付给易受攻击用户的资金。

    这是因为比特币的 ECDSA 签名中的 *S* 值在椭圆曲线上无论是高值还是低值都是有效的（与所有此类曲线一样，曲线是对称的）。在 segwit 出现之前，反转一个 *S* 值（任何人都可以对任何有效签名进行此操作[^invert]）会更改交易的 txid，这是所谓的*交易易变性*。在一个大型比特币交易所因未正确处理被篡改的 txid 而损失资金之后，[Bitcoin Core 0.11.1][] 版本发布，制定了一个不中继或挖矿曲线高侧 *S* 值交易的政策——任何想要利用这种易变性的人都需要找到使用替代软件挖矿的矿工。尽管 segwit 消除了仅花费 segwit UTXO 的交易的此类 txid 易变性，但该政策仍适用于所有交易，以防止带宽浪费和其他不便。

    在 LND 的开发中，实现了两种不同的签名处理方法。在大多数情况下，LND 确保仅发送可中继的低 *S* 签名。然而，Riard 发现，LND 会接受高 *S* 值作为成功支付，最终允许攻击者取回之前已结算的支付。

    因为任何人都可以反转任何有效签名，LND 被修补以允许其将任何不可中继的高 *S* 签名转换为可中继的低 *S* 签名。这意味着任何被攻击的 LND 节点在支付成功之前升级，都应该能够保住其资金。[BOLTs #807][] 提议更新 LN 规范，自动关闭任何一方尝试使用高 *S* 签名的通道（现代比特币软件不应生成高 *S* 签名），Fromknecht 表示 LND 计划实现该提案。

    详细信息，请参见来自 [Riard][riard5] 和 [Fromknecht][fromknecht5] 的电子邮件。

  - **<!--cve-2020-26896-improper-preimage-revelation-->****[CVE-2020-26896][] 不正确的 preimage 揭露：** LND 可能会被诱骗在收到预期支付之前泄露 [HTLC][topic htlc] preimage，从而导致路由它的节点窃取支付。

    假设 Alice 想通过 Mallory 路由支付给 Bob：

    ```
    Alice → Mallory → Bob
      （计划路由）
    ```

    Alice 首先给 Mallory 一个 HTLC。Mallory 还不能领取这笔钱，因为她不知道其 hashlock 的 preimage。然而，Mallory 猜测 Bob 是预期的接收者——所以他知道 preimage。于是 Mallory 不将 Alice 的支付路由给 Bob，而是创建一个相同 hashlock 的新最小支付，并通过 Bob 和第三方（Carol）回路由回自己。

    ```
    Mallory → Bob → Carol → Mallory
        （第二条支付路由）
    ```

    尽管 Mallory 创建了这笔第二支付，她无法完成它，因为她不知道 hashlock 的 preimage。相反，她在第二笔支付仍在待处理时关闭了与 Bob 的通道。由于 LND 的一个错误，Bob 会使用 Alice 支付中的 preimage 来结算 Mallory 路由到他节点的支付。Bob 获得了 Mallory 支付的路由费，但也泄露了 Alice 通过 Mallory 路由的 HTLC 的 preimage。通过 preimage，Mallory 可以领取这笔支付的全额，而无需将任何部分转给 Bob。此外，Alice 收到加密的支付证明，尽管支付实际上被盗。

    LND 的设计试图通过将支付 preimage 和路由 preimage 分开存储来防止此问题，但添加了一些查询两个数据库的代码，造成了 Riard 发现的错误。

    Fromknecht 和 Riard 都指出，如果所有 LN 实现几乎一年前添加的[支付秘密功能][payment secrets feature]已成为所有发票的强制性要求，则本次攻击本可避免。此功能旨在防止隐私降低的探测，尤其是[多路径支付][topic multipath payments]，通过防止接收方在支付不包含发票中的随机数时透露支付 preimage。在这种情况下，如果该功能强制执行，Mallory 将不知道支付秘密，因此即使代码有漏洞也无法引诱 Bob 透露 preimage。Fromknecht 指出，“即将发布的 LND v0.12.0-beta 版本可能会默认要求支付秘密。我们也欢迎其他实现做同样的更改。”

    第二组电子邮件来自 [Riard][riard6] 和 [Fromknecht][fromknecht6]，详细描述了此问题。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选之地——或当我们有空时帮助有好奇心或困惑的用户。在本月的特刊中，我们重点介绍了自上次更新以来发布的部分高票问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--why-is-the-bitcoin-core-wallet-database-moving-from-berkeley-db-to-sqlite-->**[为什么 Bitcoin Core 钱包数据库从 Berkeley DB 移至 SQLite？]({{bse}}99620)
  Michael Folkson 引用 Andrew Chow 的[博客文章][achow wallet blog post]，包括 SQLite 的优点、Berkeley DB 的缺点，以及从传统钱包迁移到[描述符][topic descriptors]钱包的更宏观[时间表][wallet proposed timeline]。

- **<!--what-are-merklized-alternative-script-trees-->**[什么是 Merklized Alternative Script Trees？]({{bse}}99539)
  Murch 和 Michael Folkson 描述了比特币中 [MAST][topic mast] 讨论的历史，Merklized 抽象语法树与 Merklized 替代脚本树的差异，以及其与 taproot 的 [BIP341][] 提案的关系。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的更改。*

- [Bitcoin Core #20198][] 在 `bitcoin-wallet` 工具的 `info` 命令输出中添加了三个新字段。新增的“Name”、“Format”和“Descriptors”字段分别代表钱包的名称、钱包数据库格式（bdb 或 [sqlite][news120 sqlite]），以及钱包是否为[描述符][topic descriptors]钱包。

- [C-Lightning #4046][] 添加了命令发送通知以指示命令进度的功能。为向后兼容，此功能为可选。一个示例用例是[原始问题][orig_issue]，该问题推动了此次更改。

- [C-Lightning #4139][] 使用新的 `commitment_feerate` 参数更新了 `multifundchannel` RPC，该参数用于设置通道中承诺交易的初始费率。之前，资金交易和初始承诺交易使用相同的费率。新选项允许用户支付较高的费率以快速打开通道，而无需在承诺交易中支付相同的高费率。这在使用[锚定输出][topic anchor outputs]时特别有用，允许承诺交易支付较低费率，必要时可以使用 [CPFP][topic cpfp] 提高费用。

- [Eclair #1575][] 添加了一个 `override-feerate-tolerance` 设置，允许指定节点容忍特定对等方创建的承诺交易费率的范围，过低以至于不能快速确认或过高而不合理。PR 建议此功能可用于维持与可信对等方的低费率通道。

- [BIPs #1003][] 更新了 [BIP322][] 对[通用消息签名协议][topic generic signmessage]的规范，放弃了自定义签名协议，转而使用虚拟交易，这些交易可以通过已经接受 PSBT 或原始比特币交易的许多比特币钱包进行签名。构造虚拟交易的方式确保其不能花费比特币，但确实对所需的消息进行了承诺。参见 [Newsletter #118][news118 signmessage] 中关于提议更改的摘要。

## 脚注

[^invert]:
    如果一个高 *S* 值的坐标为 (x,y)，那么低 *S* 值为 (x,-y)。对于比特币的 secp256k1 曲线，它是一个定义在素数域上的曲线，其中所有点都是无符号的，因此不能简单地取负值，需要从曲线的阶数中减去高 *S* 值的 *y* 坐标。正如 [BIP146][] 所述：“`S' = 0xFFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFE BAAEDCE6 AF48A03B BFD25E8C D0364141 - S`”。 <!-- skip-duplicate-words-test -->

{% include references.md %}
{% include linkers/issues.md issues="20198,4046,4139,1575,1003,807" %}
[news119 lnd]: /zh/newsletters/2020/10/14/#upgrade-lnd-to-0-11-x
[CVE-2020-26895]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-26895
[CVE-2020-26896]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-26896
[bitcoin core 0.11.1]: https://bitcoin.org/en/release/v0.11.1#test-for-lows-signatures-before-relaying
[riard5]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-October/002859.html
[fromknecht5]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-October/002858.html
[riard6]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-October/002855.html
[fromknecht6]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-October/002857.html
[payment secrets feature]: https://github.com/lightningnetwork/lightning-rfc/commit/5776d2a7
[news118 signmessage]: /zh/newsletters/2020/10/07/#alternative-to-bip322-generic-signmessage
[achow wallet blog post]: https://achow101.com/2020/10/0.21-wallets
[wallet proposed timeline]: https://github.com/bitcoin/bitcoin/issues/20160
[news120 sqlite]: /zh/newsletters/2020/10/21/#bitcoin-core-19077
[orig_issue]: https://github.com/ElementsProject/lightning/issues/3925
