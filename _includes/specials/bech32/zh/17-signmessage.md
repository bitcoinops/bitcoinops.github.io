正如我们在本系列的前几部分所展示的，bech32 地址几乎在各方面都优于旧式地址——它们允许用户[节省费用][bech32 save fees]、[更容易抄写][bech32 transcribe]、[能够查找地址输入错误][bech32 locate typos]，并且在 QR 码中[更高效][bech32 qr codes]。然而，有一个功能是旧式 P2PKH 地址支持但原生 segwit 钱包并不广泛支持的——消息签名支持。本着完全披露的精神，并希望促使钱包开发者采取行动，我们将仔细审视 bech32 地址支持的这一缺失部分。

作为背景，许多钱包允许使用旧式 P2PKH 地址的用户使用最终与该地址关联的私钥来签署任意文本消息：

    $ bitcoin-cli getnewaddress "" legacy
    125DTdGU5koq3YfAnA5GNqGfC8r1AZR2eh

    $ bitcoin-cli signmessage 125DTdGU5koq3YfAnA5GNqGfC8r1AZR2eh Test
    IJPKKyC/eFmYsUxaJx9yYfnZkm8aTjoN3iv19iZuWx7PUToF53pnQFP4CrMm0HtW1Nn0Jcm95Le/yJeTrxJwgxU=

不幸的是，没有广泛实施的方法来为旧式 P2SH、P2SH 包裹的 segwit 或原生 segwit 地址创建签名消息。在 Bitcoin Core 和许多其他钱包中，尝试使用旧式 P2PKH 地址以外的任何东西都会失败：

    $ bitcoin-cli getnewaddress "" bech32
    bc1qmhtn8x34yq9t7rvw9x6kqx73vutqq2wrxawjc8

    $ bitcoin-cli signmessage bc1qmhtn8x34yq9t7rvw9x6kqx73vutqq2wrxawjc8 Test
    error code: -3
    error message:
    Address does not refer to key

一些钱包确实支持 segwit 地址的消息签名——但不是标准化的方式。例如，[Trezor][trezor segwit signmessage] 和 [Electrum][electrum segwit signmessage] 钱包分别为 P2WPKH 和 P2SH 包裹的 P2WPKH 地址提供消息签名支持。然而，这两种实现是独立完成的，使用略有不同的协议，因此它们[无法验证][trezor electrum incompatible]由另一系统生成的签名。此外，据我们所知，所有钱包使用的算法都不能轻易适应用于多重签名和其他高级限制的 P2SH 和 P2WSH 脚本。这意味着今天的消息签名普遍仅限于单签名地址的用户。

{:#bip322}
有一个提议的标准应允许任何地址类型或脚本用于创建签名消息，即 [BIP322][]。该协议应该甚至能够向前兼容未来的 segwit 版本，如 [bip-taproot][] 和 [bip-tapscript][]（存在一些与时间锁相关的未解决限制）。不幸的是，尽管该提案在一年多前首次提出（见[Newsletter #13][]），但没有任何实现——甚至没有正在审查的提议实现。

这使得 segwit 用户无法享受到与旧式地址用户相同的消息签名支持水平，这可能是一些用户不愿意转向 segwit 地址的原因。除了钱包放弃消息签名支持之外，唯一的解决方案是钱包开发者就一个标准达成一致，然后广泛实施它。

[bech32 save fees]: /zh/bech32-sending-support/#使用原生-segwit-节省费用
[bech32 transcribe]: /zh/bech32-sending-support/#读取和抄录-bech32-地址
[bech32 locate typos]: /zh/bech32-sending-support/#查找-bech32-地址中的拼写错误
[bech32 qr codes]: /zh/bech32-sending-support/#使用-bech32-地址创建更高效的二维码
[trezor segwit signmessage]: https://github.com/trezor/trezor-mcu/issues/169
[electrum segwit signmessage]: https://github.com/spesmilo/electrum/issues/2977
[trezor electrum incompatible]: https://github.com/spesmilo/electrum/issues/3861
[newsletter #13]: /zh/newsletters/2018/09/18/#review-proposed-bip322-for-generic-message-signing
