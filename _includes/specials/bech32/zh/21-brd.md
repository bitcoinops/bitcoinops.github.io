{% auto_anchor %}
*以下案例研究由 Optech 成员公司 [BRD][] 提供，描述了他们在为其钱包实现 bech32 和其他 segwit 技术时的经验。*

我们于 2018 年 1 月开始在 BRD 钱包中实现 bech32 支持，在 [breadwallet-core][] 中[添加了 bech32 解码和编码支持][brd pr1]。breadwallet-core 是一个 MIT 许可的跨平台 C 库，无需外部依赖。我们所有的软件都尽可能避免第三方库的依赖，目前只使用 Pieter Wuille 的 [libsecp256k1][]. 最小化依赖是高安全性加密项目的典型做法。对于 bech32 的实现，我们发现 [BIP173][] 文档非常完善，因此没有遇到复杂的具体问题。

2018 年 3 月，breadwallet-core [更新][brd pr2]以自动解析作为比特币地址提供的任何内容，判断它是传统 P2PKH、传统 P2SH 还是 segwit bech32，并自动为每种情况生成相应的 scriptPubKey。这使得 BRD 开始支持向 bech32 地址发送比特币。最终在 2018 年 10 月，我们在整个库的后端和移动应用前端实现了完整的 segwit 支持，允许用户开始接收 bech32 地址，同时将所有找零地址默认设置为 bech32。

我们从未实现对 P2SH 封装的 segwit 地址的接收支持，而是直接使用 bech32。这是为了更好地优化 BRD 用于扫描影响用户钱包交易的布隆过滤器机制。为了允许用户跟踪他们何时收到付款，布隆过滤器会与 scriptPubKey 中的每个数据元素进行匹配。对于给定的公钥，scriptPubKey 中的数据元素在传统 P2PKH 和原生 segwit (bech32) P2WPKH 中是相同的。以下是 Optech [之前使用的][identical spk data]一个示例：

- 地址 1B6FkNg199ZbPJWG5zjEiDekrCc2P7MVyC 的传统 P2PKH scriptPubKey：

  <pre>OP_DUP OP_HASH160 OP_PUSH20 <b>6eafa604a503a0bb445ad1f6daa80f162b5605d6</b> OP_EQUALVERIFY OP_CHECKSIG</pre>

- 地址 bc1qd6h6vp99qwstk3z668md42q0zc44vpwkk824zh 的原生 segwit (bech32) P2WPKH scriptPubKey：

  <pre>OP_0 OP_PUSH20 <b>6eafa604a503a0bb445ad1f6daa80f162b5605d6</b></pre>

由于针对给定元素的布隆过滤器将匹配同一公钥的 P2PKH 和 P2WPKH 地址，BRD 能够以零额外开销的方式扫描这两种支付类型。这也使得实现更加简洁，不会增加提供布隆过滤器服务的公共节点的资源使用。这对于使用其他类型扫描的钱包和服务来说，可能也是一种有价值的优化，因为这可能比 [BIP84][] 推荐的单独 HD 派生路径产生更少的开销。

由 bech32 地址生成的 scriptPubKey 长度各不相同，这会影响需要支付的交易费金额。比特币的手续费计算非常复杂——有时费率在 24 小时内会猛增几个数量级——但这在 segwit 之前已经是事实，所以我们以前花了很多时间在手续费计算上，并使其尽可能灵活。这意味着由 bech32 地址生成的 scriptPubKey 大小的变化不会对 BRD 造成影响。

我们希望今天的应用程序能够适应未来，因此代码支持发送到未来的 segwit 版本（请参阅 [Optech 的描述][bech32 future]）。这意味着，例如，如果比特币用户选择通过软分叉更改共识规则，BRD 将自动支持支付到 [taproot][bip-taproot] 地址。

一旦真正的势头建立起来，且大多数其他钱包和服务支持发送到 bech32 地址，BRD 的 bech32 接收支持将作为默认设置推广给我们的所有用户。为准备这一过渡，尽可能多的公司和服务自愿支持 bech32 发送能力非常重要。为了推动采用，我们创建了 [WhenSegwit][] 网站并成为 Optech 成员公司。我们希望其他钱包和服务在手续费相对较低时尽快实现完整的 segwit 支持。

[BRD]: https://brd.com/
[brd pr1]: https://github.com/breadwallet/breadwallet-core/commit/2b17fe44619442c31f8a47c175f84b8992933346
[brd pr2]: https://github.com/breadwallet/breadwallet-core/commit/fd0abb92b07e41429e1170fb56716965cc7b64ab
[breadwallet-core]: https://github.com/breadwallet/breadwallet-core/
[identical spk data]: /zh/bech32-sending-support/#bech32-发送支持介绍
[bech32 future]: /zh/bech32-sending-support/#自动-bech32-支持未来的软分叉
[whensegwit]: https://whensegwit.com/
{% endauto_anchor %}
