正如我们在本系列早前部分中展示的那样，Bech32 地址在几乎所有方面都优于传统地址——它们允许用户[节省费用][bech32 save fees]、[更容易转录][bech32 transcribe]、[可以定位地址输入错误][bech32 locate typos]，并且在 [QR 码中更高效][bech32 qr codes]。然而，有一个特性是传统 P2PKH 地址支持但原生 Segwit 钱包尚未广泛支持的——消息签名功能。为了全面披露信息，并希望能激励钱包开发者采取行动，我们将探讨 Bech32 地址支持中缺失的这一部分。

作为背景，许多钱包允许用户使用传统的 P2PKH 地址，通过与该地址相关联的私钥签署任意文本消息：

    $ bitcoin-cli getnewaddress "" legacy
    125DTdGU5koq3YfAnA5GNqGfC8r1AZR2eh

    $ bitcoin-cli signmessage 125DTdGU5koq3YfAnA5GNqGfC8r1AZR2eh Test
    IJPKKyC/eFmYsUxaJx9yYfnZkm8aTjoN3iv19iZuWx7PUToF53pnQFP4CrMm0HtW1Nn0Jcm95Le/yJeTrxJwgxU=

不幸的是，目前没有广泛实施的方式可以为传统 P2SH、P2SH 封装的 Segwit 或原生 Segwit 地址创建签名消息。在 Bitcoin Core 和许多其他钱包中，尝试使用除传统 P2PKH 地址以外的任何地址都会失败：

    $ bitcoin-cli getnewaddress "" bech32
    bc1qmhtn8x34yq9t7rvw9x6kqx73vutqq2wrxawjc8

    $ bitcoin-cli signmessage bc1qmhtn8x34yq9t7rvw9x6kqx73vutqq2wrxawjc8 Test
    error code: -3
    error message:
    Address does not refer to key

一些钱包确实支持 Segwit 地址的消息签名——但采用了非标准化的方法。例如，[Trezor][trezor segwit signmessage] 和 [Electrum][electrum segwit signmessage] 钱包分别提供了对 P2WPKH 和 P2SH 封装的 P2WPKH 地址的消息签名支持。然而，这两个实现是独立完成的，并且使用了略有不同的协议，因此它们[无法验证][trezor electrum incompatible]由另一个系统生成的签名。此外，我们所知的所有钱包所使用的算法都无法轻松适配用于多签名和其他高级限制的 P2SH 和 P2WSH 脚本。这意味着目前的消息签名功能普遍仅限于单签名地址的用户。

{:#bip322}
有一个提议的标准应允许任何地址类型或脚本用于创建签名消息，[BIP322][]. 该协议甚至应与未来的 Segwit 版本向前兼容，例如 [bip-taproot][] 和 [bip-tapscript][]（但存在一些与时间锁相关的未解决限制）。不幸的是，尽管该提议在一年多前首次提出（参见 [Newsletter #13][]），但至今仍没有任何实现——甚至没有一个正在审查中的提议实现。

这使得 Segwit 用户无法获得与传统地址用户相同级别的消息签名支持，这可能是某些用户不愿意迁移到 Segwit 地址的原因之一。除了钱包放弃消息签名支持外，唯一的解决方案是钱包开发者就一个标准达成一致并广泛实施该标准。


[bech32 save fees]: /zh/bech32-sending-support/#使用原生-segwit-节省费用
[bech32 transcribe]: /zh/bech32-sending-support/#读取和抄录-bech32-地址
[bech32 locate typos]: /zh/bech32-sending-support/#查找-bech32-地址中的拼写错误
[bech32 qr codes]: /zh/bech32-sending-support/#使用-bech32-地址创建更高效的二维码
[trezor segwit signmessage]: https://github.com/trezor/trezor-mcu/issues/169
[electrum segwit signmessage]: https://github.com/spesmilo/electrum/issues/2977
[trezor electrum incompatible]: https://github.com/spesmilo/electrum/issues/3861
[newsletter #13]: /zh/newsletters/2018/09/18/#review-proposed-bip322-for-generic-message-signing
