我们从钱包提供商那里听说，他们对默认接收 bech32 地址的犹豫原因之一是担心会显著增加客户支持请求。尽管如此，一些钱包已经默认使用 bech32 地址，其他一些钱包也计划很快开始使用，例如 [Bitcoin Core][core bech32 plan]。

我们向包括 BitGo、BRD、Conio、Electrum 和 Gemini 在内的多家服务商征求了关于使用 bech32 地址对客户支持负担的意见。大多数服务商报告称问题很少（“没有支持请求”和“没有太多困惑”）。

有一家服务商表示：“与比特币地址相关的客户支持票增加了 50%，但票数绝对数量如此之小，可能无法给出太多意义。在 Bech32 出现之前或之后，这个话题的票数从来都不多，所以不确定这是否是让交易所转换的一个重要论点。相反，我可能建议关注费用问题，如果你使用的是旧的钱包实现，费用确实可能会累积。”

Electrum 也确实看到了一些公开的报告，例如[“奇怪的地址”]和[“Localbitcoins 不支持发送到 bech32”]。

尽管结论尚不明确，但令人欣慰的是，选择支持接收 bech32 地址的服务并没有对其客户支持团队产生负面影响。上面关于考虑费用节省的建议可能远远超过了这些担忧，并且与 Bitcoin Optech 的[指导][save money with bech32]一致。鉴于少数负面报告和支持接收 bech32 地址的钱包和服务可以显著节省费用，可能是时候让更多的钱包开始将 bech32 作为默认地址格式。如果这种情况发生，那么其他钱包和服务支持发送到 bech32 地址将变得更加重要。

[core bech32 plan]: /zh/newsletters/2019/04/02/#新闻
["strange addresses"]: https://github.com/spesmilo/electrum/issues/5382
["localbitcoins does not support sending to bech32"]: https://github.com/spesmilo/electrum/issues/5371
[save money with bech32]: /zh/bech32-sending-support/#使用原生-segwit-节省费用
