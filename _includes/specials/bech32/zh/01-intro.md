Bech32 原生 segwit 地址几乎在两年前首次公开[提议][bech32 proposed]，并成为 [BIP173][] 标准。随后，segwit 软分叉于 2017 年 8 月 24 日锁定。然而，在锁定后十七个月，一些流行的钱包和服务仍然不支持向 bech32 地址发送比特币。其他钱包和服务的开发者已经厌倦了等待，希望默认接收 bech32 地址的付款，以便他们可以实现额外的费用节省和隐私改进。Newsletter 希望帮助这个过程，因此从现在到 segwit 锁定的两周年纪念，每一期的 Newsletter 都将包括一个简短的部分，提供资源以帮助全面部署 bech32 发送支持。

请注意，我们仅直接提倡 bech32 **发送**支持。这允许你支付的对象使用 segwit，但不要求你自己实现 segwit。（如果你想使用 segwit 来节省费用或访问其他好处，那很好！我们只是鼓励你先实现 bech32 发送支持，这样你支付的对象可以立即开始利用它，而你可以在升级其余代码和基础设施以全面支持 segwit 的同时进行。）为此，本周的部分重点展示了发送到传统地址和发送到 bech32 地址之间的差异有多小。

### 发送到传统地址

对于你已经支持的 P2PKH 传统地址，例如 1B6FkNg199ZbPJWG5zjEiDekrCc2P7MVyC，你的 base58check 库会将其解码为一个 20 字节的承诺：

     6eafa604a503a0bb445ad1f6daa80f162b5605d6

这个承诺被插入到一个 scriptPubKey 模板中：

<pre>OP_DUP OP_HASH160 OP_PUSH20 <b>6eafa604a503a0bb445ad1f6daa80f162b5605d6</b> OP_EQUALVERIFY OP_CHECKSIG</pre>

将操作码转换为十六进制，这看起来像：

    76a9146eafa604a503a0bb445ad1f6daa80f162b5605d688ac

这被插入到输出的 scriptPubKey 部分，该部分还包括脚本的长度（25 字节）和支付的金额：

<pre>     amount                           scriptPubKey
|--------------|  |------------------------------------------------|
00e1f5050000000019<b>76a9146eafa604a503a0bb445ad1f6daa80f162b5605d688ac</b>
                |
    size: 0x19 -> 25 bytes</pre>

这个输出可以添加到交易中，然后交易被签名并广播。

### 发送到 bech32 地址

对于等效的 bech32 P2WPKH 地址，例如 bc1qd6h6vp99qwstk3z668md42q0zc44vpwkk824zh，你可以使用其中一个[参考库][bech32 ref libs] 将地址解码为一对值：

    0 6eafa604a503a0bb445ad1f6daa80f162b5605d6

这两个值也被插入到一个 scriptPubKey 模板中。第一个值是见证脚本版本字节，用于使用 `OP_0` 到 `OP_16` 的某个操作码将值添加到堆栈中。第二个值是也被推送到堆栈的承诺：

<pre><b>OP_0</b> OP_PUSH20 <b>6eafa604a503a0bb445ad1f6daa80f162b5605d6</b></pre>

将操作码转换为十六进制，这看起来像：

    00146eafa604a503a0bb445ad1f6daa80f162b5605d6

然后，就像之前一样，这被插入到输出的 scriptPubKey 部分：

<pre>     amount                        scriptPubKey
|--------------|  |------------------------------------------|
00e1f5050000000016<b>00146eafa604a503a0bb445ad1f6daa80f162b5605d6</b>
                |
    size: 0x16 -> 22 bytes</pre>

输出被添加到交易中。交易然后被签名并广播。

对于 bech32 P2WSH（P2SH 的 segwit 等效）或未来的 segwit 见证版本，你不需要做任何特殊的事情。见证脚本版本可能是一个不同的数字，需要你使用相应的 `OP_0` 到 `OP_16` 操作码，承诺可能是不同的长度（从 2 到 40 字节），但输出的其他部分不会改变。由于长度变化是允许的，确保你的费用估算软件考虑到 scriptPubKey 的实际大小，而不是使用以前根据 P2PKH 或 P2SH 大小计算的常数。

以上是你需要在软件后端进行的全部更改，以启用发送到 bech32 地址。对于大多数平台，这应该是一个非常简单的更改。参见 [BIP173][] 和[参考实现][bech32 ref libs]以获取一组测试向量，用于确保你的实现正常工作。

[bech32 proposed]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2017-March/013749.html
[bech32 ref libs]: https://github.com/sipa/bech32/tree/master/ref
