{% auto_anchor %}
这个部分标志着 Bech32 系列已过半，因此我们决定在本周介绍一些与 Bech32 相关的趣闻，这些趣闻有趣但不足以独立成段。

- **<!--how-is-bech32-pronounced-->****Bech32 的发音是什么？** 提案的共同作者 Pieter Wuille 使用轻声的“ch”，因此这个词听起来像 [“besh thirty two”][wuille bech32]。这个名字是一个混合词，将地址的纠错编码（BCH）的字母与其数值基（base32）的名称结合起来。将其与轻声“ch”发音，使得 *bech32* 的第一个音节与比特币的传统地址格式 *base58* 相似。我们承认，这种详细解释破坏了这个笑话，但这是一个巧妙而有趣的文字游戏。

- **<!--bch-has-nothing-to-do-with-bitcoin-cash-s-ticker-code-->****BCH 与 Bitcoin Cash 的代码无关：** Bech32 所基于的 BCH 代码名称是 [Bose-Chaudhuri-Hocquenghem][wikipedia bch] 的缩写，Hocquenghem 于 1959 年发明了这种类型的循环码，随后 Bose 和 Ray-Chaudhuri 在 1960 年独立重新发现了它们。此外，Bech32 地址格式在 2017 年 3 月宣布，比后来被称为 Bitcoin Cash 的计划（最初计划使用代码 *BCC*）的[首次计划][first plans]早了三个月。

- **<!--over-ten-cpu-years-consumed-->****消耗超过十年的 CPU 计算时间：** 使用现有的关于 BCH 代码的信息，Bech32 的作者能够找到为比特币地址提供他们所需的最低错误检测能力的代码集。然而，这个集合中有近 16 万个符合条件的代码，作者预计其中有些代码会比其他的更好。为了在其中找到最优的代码，使用了超过 200 个 CPU 核心和[超过 10 年的计算时间][cpu time]。

[wuille bech32]: https://youtu.be/NqiN9VFE4CU?t=1827
[cpu time]: https://youtu.be/NqiN9VFE4CU?t=1329
[wikipedia bch]: https://en.wikipedia.org/wiki/BCH_code
[first plans]:https://blog.bitmain.com/en/uahf-contingency-plan-uasf-bip148/
{% endauto_anchor %}
