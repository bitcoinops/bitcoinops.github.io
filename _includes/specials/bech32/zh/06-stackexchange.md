{% auto_anchor %}
本周我们来看一些来自 Bitcoin Stack Exchange 的[最高票数 bech32 问题和答案][top bech32 qa]。这些问题和答案涵盖了自 bech32 大约两年前首次发布以来的所有内容。

{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--will-a-schnorr-soft-fork-introduce-a-new-address-format-->**[Schnorr 软分叉是否会引入新的地址格式？]({{bse}}82952)
  尽管升级到 bech32 发送支持应该很容易，但你可能不希望为 Bitcoin 的下一个升级或之后的升级重复这项工作。Pieter Wuille 通过解释如何在使用基于 Schnorr 的公钥和签名时仍然使用 bech32 地址来回答这个问题。（Optech 将在未来的部分中更详细地讨论这个问题。）

- **<!--is-it-safe-to-translate-a-bech32-p2wpkh-address-into-a-legacy-p2pkh-address-->**[将 bech32 P2WPKH 地址转换为传统 P2PKH 地址是否安全？]({{bse}}62207)
  如果你阅读了 [Newsletter #38][bech32 easy]，你会注意到对于相同的底层公钥，P2WPKH 和 P2PKH 地址之间的区别仅在于 scriptPubKey 中的几个字符，使得可以自动将一个转换为另一个。Andrew Chow 和其附带评论的答案解释了为什么这是一个糟糕的主意，可能会导致用户丢失资金。

- **<!--why-does-the-bech32-decode-function-require-specifying-the-address-s-human-readable-part-hrp-instead-of-extracting-it-automatically-->**[为什么 bech32 解码函数需要指定地址的可读部分 (HRP) 而不是自动提取？]({{bse}}83454)
  HRP 由一个 `1` 与地址的其他部分分开，所以解码器似乎可以自己忽略该部分。Pieter Wuille 解释说，使用预期的 HRP 调用解码器可以确保你不会意外地将 bitcoin 支付到一个用于测试网、莱特币或其他网络的地址。Gregory Maxwell 还纠正了提问者的另一个假设。

- **<!--what-block-explorers-recognize-bech32-addresses-->**[哪些区块浏览器识别 bech32 地址？]({{bse}}66458)
  在 bech32 首次提出两年多后以及该问题首次被提出一年后，几个流行的区块浏览器仍然不支持 bech32 地址的搜索或显示。这个问题的答案建议任何想了解各种区块浏览器 bech32 支持状态的人应该查看 [bech32 采用][bech32 adoption] Bitcoin Wiki 页面。

[bech32 easy]: /zh/newsletters/2019/03/19/#bech32-发送支持
[top bech32 qa]: https://bitcoin.stackexchange.com/search?tab=votes&q=bech32
[bech32 adoption]: https://en.bitcoin.it/wiki/Bech32_adoption
{% endauto_anchor %}
