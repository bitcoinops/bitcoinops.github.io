---
title: 'Bitcoin Optech Newsletter #121'
permalink: /zh/newsletters/2020/10/28/
name: 2020-10-28-newsletter-zh
slug: 2020-10-28-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 介绍了 LND 中两个漏洞的披露，并包含我们的常规部分：Bitcoin Stack Exchange 的热门问题与回答摘要、发布与候选发布的公告，以及热门比特币基础设施软件变更的介绍。

## 行动项

- **<!--ensure-lnd-nodes-are-upgraded-to-0-11-->****确保 LND 节点已升级到 0.11+：** 正如 [Newsletter #119][news119 lnd] 中所警告的，旧版本 LND 的两个漏洞的完整披露现已公开。两个漏洞都可能导致受影响的 LN 节点的资金被盗，因此强烈建议立即升级到 LND 0.11.0-beta 或 LND 0.11.1-beta。其他 LN 实现不受所述漏洞的影响。

## 新闻

- **<!--full-disclosures-of-recent-lnd-vulnerabilities-->****最近 LND 漏洞的完整披露：** 本周，LND 共同维护者 Conner Fromknecht 和漏洞发现者 Antoine Riard 在 Lightning-Dev 邮件列表中完整披露了影响 LND 的两个漏洞。

  - **<!--cve-2020-26895-acceptance-of-non-standard-signatures-->****[CVE-2020-26895][] 接受非标准签名：** 在某些情况下，LND 会接受一种 Bitcoin Core 默认既不会中继、也不会打包进区块的交易签名。当带有这种无法中继签名的交易迟迟无法确认时，时间锁最终到期，攻击者就能窃取自己此前支付给该漏洞用户的资金。

    这是比特币 ECDSA 签名中 *S* 值在比特币椭圆曲线的高侧与低侧同样有效的后果（与所有此类曲线一样，这条曲线也是对称的）。在 segwit 之前，反转一个 *S* 值——任何人都能对任何有效签名做这件事[^invert]——会改变一笔交易的 txid，这就是所谓的*交易可延展性*。某大型比特币交易所因未正确处理被篡改的 txid 而损失资金后，[Bitcoin Core 0.11.1][] 发布，并附带一项政策：不中继、也不打包 *S* 值位于曲线高侧的交易——这就迫使任何想利用这种可延展性的人去寻找愿意用其他软件挖区块的人。尽管 segwit 只为“仅花费 segwit UTXO”的交易消除了这类 txid 可延展性，该政策仍对所有交易强制执行，以避免带宽浪费和其他麻烦。

    LND 在开发过程中实现了两种不同的签名处理方式。在大多数情况下，LND 都能正确保证只发送可中继的低 *S* 签名。然而 Riard 发现，LND 会把高 *S* 值当作支付成功接受，最终让攻击者能把此前已结算的支付再偷回去。

    由于任何人都能反转任何有效签名，LND 打上了补丁，使其能把任何无法中继的高 *S* 签名转换成可中继的低 *S* 签名。这意味着，任何遭到攻击的 LND 节点，只要在那笔已成功的支付到期之前升级，就应该能保住自己的资金。[BOLTs #807][] 提议更新 LN 规范：只要任何一方尝试使用高 *S* 签名（现代比特币软件都不应生成这种签名），就自动关闭通道。Fromknecht 表示 LND 计划实现这一提案。

    详细信息，请参见来自 [Riard][riard5] 和 [Fromknecht][fromknecht5] 的电子邮件。

  - **<!--cve-2020-26896-improper-preimage-revelation-->****[CVE-2020-26896][] 原像泄露处理不当：** LND 可能被诱骗，在收到预期支付之前就泄露 [HTLC][topic htlc] 的原像，从而使本应路由这笔支付的一个节点得以窃取它。

    设想 Alice 想经由 Mallory 路由一笔支付给 Bob：

    ```
    Alice → Mallory → Bob
      （计划路由）
    ```

    Alice 先给 Mallory 一个 HTLC。Mallory 此时还领不到这笔钱，因为她不知道该哈希锁对应的原像。不过 Mallory 可以猜到 Bob 就是预期的收款方——所以他知道原像。于是 Mallory 不把 Alice 的支付路由给 Bob，而是创建一笔由同一哈希锁保护的最小金额新支付，再经由 Bob 和第三方（Carol）把它路由回自己。

    ```
    Mallory → Bob → Carol → Mallory
        （第二条支付路由）
    ```

    尽管这笔第二支付是 Mallory 自己创建的，她却无法完成它，因为她同样不知道哈希锁的原像。于是她在这笔第二支付仍处于待处理状态时关闭了与 Bob 的通道。由于 LND 的一个缺陷，Bob 会用本该用于 Alice 那笔支付的原像，去结算 Mallory 经由他的节点路由的这笔支付。这样 Bob 赚到了 Mallory 支付的路由手续费，但也把原像泄露给了 Alice 试图经由 Mallory 路由的那笔待处理 HTLC。拿到原像后，Mallory 就能取走那笔支付的全部金额，而无需把其中任何部分转给 Bob。此外，尽管这笔支付实际上已被窃取，Alice 仍会收到密码学的支付证明。

    LND 的设计本想通过把支付原像与路由原像分开存储来防止这一问题，但后来加入的一些代码会同时查询这两个数据库，由此产生了 Riard 发现的缺陷。

    Fromknecht 和 Riard 都指出，如果将近一年前加入所有 LN 实现的[支付秘密功能][payment secrets feature]当初就设为所有发票的必备项，这次攻击本可避免。该功能旨在防止损害隐私的探测，尤其是对[多路径支付][topic multipath payments]的探测：除非支付中包含发票里指定的随机数（nonce），否则接收方不会披露支付原像。如果在这种情况下强制执行了该功能，Mallory 就不会知道支付秘密，即使代码有缺陷也无法诱使 Bob 披露原像。Fromknecht 指出：“即将发布的 LND v0.12.0-beta 版本很可能会默认要求支付秘密。我们也欢迎其他实现这样做。”

    来自 [Riard][riard6] 和 [Fromknecht][fromknecht6] 的第二组电子邮件详细描述了这一问题。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们有点空闲时帮助好奇或困惑用户的地方。在本月栏目中，我们精选自上次更新以来得票最高的一些问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--why-is-the-bitcoin-core-wallet-database-moving-from-berkeley-db-to-sqlite-->**[为什么 Bitcoin Core 钱包数据库从 Berkeley DB 移至 SQLite？]({{bse}}99620)
  Michael Folkson 引用 Andrew Chow 的[博客文章][achow wallet blog post]，其中谈到 SQLite 的优点、Berkeley DB 的缺点，以及从旧版钱包迁移到[输出脚本描述符][topic descriptors]钱包的更大图景下的[拟议时间表][wallet proposed timeline]。

- **<!--what-are-merklized-alternative-script-trees-->**[什么是 Merklized Alternative Script Trees？]({{bse}}99539)
  Murch 和 Michael Folkson 描述了比特币中 [MAST][topic mast] 讨论的历史，Merklized 抽象语法树与 Merklized 替代脚本树的差异，以及其与 taproot 的 [BIP341][] 提案的关系。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的变更。*

- [Bitcoin Core #20198][] 在 `bitcoin-wallet` 工具的 `info` 命令输出中添加了三个新字段。新增的“Name”、“Format”和“Descriptors”字段分别表示钱包的名称、钱包数据库格式（bdb 或 [sqlite][news120 sqlite]），以及该钱包是否为[输出脚本描述符][topic descriptors]钱包。

- [C-Lightning #4046][] 让命令可以发送通知，以指示命令的执行进度。为了向后兼容，该功能需要自愿启用。一个示例用例是推动这项改动的[原始问题][orig_issue]。

- [C-Lightning #4139][] 为 `multifundchannel` RPC 增加了一个新的 `commitment_feerate` 参数，用于设置通道中承诺交易的初始费率。此前，注资交易和初始承诺交易使用同一个费率。这个新选项让用户可以支付较高的费率来快速打开通道，又不必为承诺交易支付同样高的费率。在使用[锚定输出][topic anchor outputs]时这尤其有用：锚定输出允许承诺交易只支付较低的费率，必要时再用[子为父付（CPFP）][topic cpfp]的手续费追加来提高。

- [Eclair #1575][] 增加了一个 `override-feerate-tolerance` 设置，让你可以指定节点能在多大程度上容忍特定对等方创建的承诺交易费率——这些费率可能因过低而无法快速上链确认，也可能因过高而不合理。该 PR 提出，一个用途是与自己信任的对等方维持低费率通道。

- [BIPs #1003][] 更新了 [BIP322][] 中[通用消息签名协议][topic generic signmessage]的规范，弃用自定义签名协议，转而使用虚拟交易；许多已经支持部分签名比特币交易（PSBT）或原始比特币交易的钱包都能签名这些虚拟交易。虚拟交易的构造方式使其无法花费任何比特币，但确实承诺了预期的消息。关于这项变更在最初提出时的摘要，参见 [Newsletter #118][news118 signmessage]。

## 脚注

[^invert]:
    如果一个高 *S* 值的坐标为 (x,y)，那么低 *S* 值就是 (x,-y)。比特币的 secp256k1 曲线定义在素数域上，其中坐标都是无符号数，因此你不能简单地取负值，而要从曲线的阶数中减去高 *S* 值的 *y* 坐标。正如 [BIP146][] 所述：“`S' = 0xFFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFE BAAEDCE6 AF48A03B BFD25E8C D0364141 - S`”。 <!-- skip-duplicate-words-test -->

{% include references.md %}
{% include linkers/issues.md issues="20198,4046,4139,1575,1003,807" %}
[news119 lnd]: /zh/newsletters/2020/10/14/#upgrade-lnd-to-0-11-x
[CVE-2020-26895]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-26895
[CVE-2020-26896]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-26896
[bitcoin core 0.11.1]: https://bitcoin.org/en/release/v0.11.1#test-for-lows-signatures-before-relaying
[riard5]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-October/002859.html
[fromknecht5]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-October/002858.html
[riard6]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-October/002855.html
[fromknecht6]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-October/002857.html
[payment secrets feature]: https://github.com/lightningnetwork/lightning-rfc/commit/5776d2a7
[news118 signmessage]: /zh/newsletters/2020/10/07/#alternative-to-bip322-generic-signmessage
[achow wallet blog post]: https://achow101.com/2020/10/0.21-wallets
[wallet proposed timeline]: https://github.com/bitcoin/bitcoin/issues/20160
[news120 sqlite]: /zh/newsletters/2020/10/21/#bitcoin-core-19077
[orig_issue]: https://github.com/ElementsProject/lightning/issues/3925
