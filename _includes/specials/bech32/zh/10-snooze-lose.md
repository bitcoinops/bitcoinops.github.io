到目前为止，在我们鼓励钱包和服务支持发送到 Bech32 原生 Segwit 地址的系列文章中，我们几乎完全专注于技术信息。今天，这部分内容表达了一个观点：你延迟实现 Bech32 发送支持的时间越长，一些用户和潜在用户对你的软件或服务的评价就会越差。

> "他们只能支付到传统地址。"<br>
> "哦。那我们找一个支持当前技术的服务吧。"

仅支持传统地址的服务很可能会向用户传达出一个信号，即在维护其比特币集成方面付出的开发努力最少。我们预计，这会向用户传递出与2019年一个充满 Shockwave/Adobe Flash 元素并声称在 Internet Explorer 7 中最佳浏览的网站相同的信息（或参考 Gregory Maxwell 写的更具[想象力的比较][nullc bank analogy]）。

Bech32 发送并不是一些仍需测试的实验性新技术——原生 Segwit 未花费输出目前持有[超过 200,000 个比特币][over 200,000 bitcoins]. Bech32 发送也是易于实现的（参见 Newsletter [#38][news38 bech32] 和 [#40][news40 bech32]）。最重要的是，随着越来越多的钱包和服务默认升级为 Bech32 *接收*，不提供发送支持的服务将显得落后。

如果你还没有实现 Bech32 发送支持，我们建议你在 2019 年 8 月 24 日之前尝试实现（Segwit 激活的两周年）。不久之后，Bitcoin Core 的下一个版本预计将在其 GUI 和可能的 API 方法中默认使用 Bech32 接收地址（参见 Newsletter [#40][Newsletter #40 bech32] 和 [#42][Newsletter #42 bech32]）。我们预计其他钱包也会这样做——除了那些已经默认 Bech32（甚至是唯一支持的地址格式）的钱包。

[nullc bank analogy]: https://old.reddit.com/r/Bitcoin/comments/9iw1p2/hey_guys_its_time_to_make_bech32_standard_on/e6onq8t/
[over 200,000 bitcoins]: https://p2sh.info/dashboard/db/p2wpkh-statistics?orgId=1
[news38 bech32]: /zh/newsletters/2019/03/19/#bech32-发送支持
[news40 bech32]: /zh/newsletters/2019/04/02/#bech32-发送支持
[newsletter #40 bech32]: /zh/newsletters/2019/04/02/#bitcoin-core-schedules-switch-to-default-bech32-receiving-addresses
[newsletter #42 bech32]: /zh/newsletters/2019/04/16/#bitcoin-core-15711
