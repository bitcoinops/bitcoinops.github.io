从预计在 11 月到来的区块高度 {{site.trb}} 开始，比特币用户将能够安全地接收发送到 taproot 地址的付款。考虑到用户对 taproot 的期待，以及钱包开发者有 5 个月的时间来实现对 taproot 的支持，Optech 预计到时会有数个流行的钱包允许用户在第一时间生成 taproot 地址。

这意味着任何会向用户提供的地址发送比特币的钱包或服务，都需要在区块高度 {{site.trb}} 前支持发送至 taproot 地址，否则可能会让用户感到困惑并失望。Pay to TapRoot（P2TR）地址使用了 [bech32m][topic bech32]（参见 [BIP350][]），它与 [BIP173][] 用于 segwit v0 P2WPKH 和 P2WSH 地址的 bech32 算法略有不同。bech32m 在校验和函数中使用 `0x2bc830a3` 常量，而传统 bech32 则使用 `0x01`。

只需改变这一常量即可为校验 bech32m 校验和提供支持，但在处理现有 P2WPKH 和 P2WSH 地址时仍要使用原始常量。也就是说，代码需要先在不验证校验和的情况下解析地址，判断它是 v0 segwit（bech32）还是 v1+ segwit（bech32m），然后再使用对应的常量来验证校验和。更多示例可参考 [bech32#56][bech32#56]，它更新了 C、C++、JS 和 Python 的 bech32 参考实现。如果代码已经使用了参考库，可以更新至该仓库的最新版本，但要注意其中部分 API 发生了小幅更改。BIP350 和参考实现提供的测试向量，所有 bech32m 实现都应当进行使用以验证正确性。

虽然在区块高度 {{site.trb}} 之前向 taproot 地址*接收*付款并不安全，但向这些地址*发送*付款对于付款方而言并不会造成任何问题。自 Bitcoin Core 0.19（2019 年 11 月发布）起，Bitcoin Core 就开始支持传播和挖矿包含 taproot 输出的交易。Optech 鼓励各钱包和服务的开发者现在就着手实现对 bech32m taproot 地址付款的支持，而不要等到 taproot 激活后再做准备。

[bech32#56]: https://github.com/sipa/bech32/pull/56
