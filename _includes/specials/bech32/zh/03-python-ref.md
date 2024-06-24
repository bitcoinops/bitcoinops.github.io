在[前几周][bech32 easy]，我们讨论了创建传统地址输出与原生 segwit 地址输出之间的差异有多小。在那一部分中，我们简单地指引你参考 [bech32 参考库][bech32 reference libraries]并告诉你会得到两个值。本周，我们详细演示使用 Python 参考库的确切步骤，以便你可以看到工作量有多小。我们从导入库开始：

```python3
>>> import segwit_addr
```

Bech32 地址有一个可读部分 (HRP)，用于指示地址所属的网络。这些是地址的前几个字符，并由分隔符 `1` 与地址的数据部分分开。例如，比特币测试网使用 `tb`，一个示例测试网地址是 tb1q3w[...]g7a。我们将在代码中设置比特币主网的 HRP `bc`，以便我们可以确保解析的地址属于我们期望的网络。

```python3
>>> HRP='bc'
```

最后，我们有几个要检查的地址——一个应该有效，两个应该无效。（参见 [BIP173][] 以获取完整的[参考测试向量][bip173 test vectors]。）

```python3
>>> good_address='bc1qd6h6vp99qwstk3z668md42q0zc44vpwkk824zh'
>>> typo_address='bc1qd6h6vp99qwstk3z669md42q0zc44vpwkk824zh'
>>> wrong_network_address='tb1q3wrc5yq9c300jxlfeg7ae76tk9gsx044ucyg7a'
```

现在我们可以尝试解码每个地址

```python3
>>> segwit_addr.decode(HRP, good_address)
(0, [110, 175, 166, 4, 165, 3, 160, 187, 68, 90, 209,
     246, 218, 168, 15, 22, 43, 86, 5, 214])

>>> segwit_addr.decode(HRP, typo_address)
(None, None)

>>> segwit_addr.decode(HRP, wrong_network_address)
(None, None)
```

如果我们得到的第一个值（见证版本）是 None，则该地址在我们选择的网络上无效。如果发生这种情况，你需要在堆栈上抛出异常，以便与用户交互的过程可以让他们提供正确的地址。如果你得到一个数字和一个数组，则解码成功，校验和有效，长度在允许范围内。

见证版本必须是 0 到 16 之间的数字，因此你需要检查（例如 `0 <= x <= 16`），然后将其转换为相应的操作码 `OP_0` 到 `OP_16`。对于 `OP_0`，这是 0x00；对于 `OP_1` 到 `OP_16`，这是 0x51 到 0x60。然后你需要根据数据的长度添加一个推字节（2 到 40 字节为 0x02 到 0x28），然后将数据作为字节序列附加。Pieter Wuille 的[代码][segwit addr to bytes]很简洁地完成了这一点：

```python3
>>> witver, witprog = segwit_addr.decode(HRP, good_address)
>>> bytes([witver + 0x50 if witver else 0, len(witprog)] + witprog).hex()
'00146eafa604a503a0bb445ad1f6daa80f162b5605d6'
```

这就是你的完整 scriptPubKey。你可以在交易的输出中使用它并发送它。请注意，bech32 scriptPubKeys 的大小可以从 4 到 42 vbytes 不等，因此你需要在费用估算代码中考虑 scriptPubKey 的实际大小。

你的代码不需要用 Python 编写。参考库也提供了 C、C++、Go、Haskell、JavaScript、Ruby 和 Rust 的版本。此外，[BIP173][] 对 bech32 的描述非常详细，以至于任何优秀的程序员都可以在他们首选的语言中从头实现它，而不需要超出大多数编程语言内置和标准库提供的功能。

**其他 bech32 发送支持更新：** BitGo [宣布][bitgo segwit]他们的 API 现在支持发送到 bech32 地址；请参阅他们的公告以获取有关 bech32 接收支持的更多详细信息。Gemini 交易所本周也[显然][gemini reddit]添加了 bech32 发送支持，并且用户报告称 Gemini 默认接受存款到 bech32 地址。

[bech32 easy]: /zh/newsletters/2019/03/19/#bech32-发送支持
[bech32 reference libraries]: https://github.com/sipa/bech32/tree/master/ref
[segwit addr to bytes]: https://github.com/sipa/bech32/blob/master/ref/python/tests.py#L30
[bitgo segwit]: https://blog.bitgo.com/native-segwit-addresses-via-bitgos-api-4946f2007be9
[gemini reddit]: https://www.reddit.com/r/Bitcoin/comments/b66n0v/psa_gemini_is_full_on_with_native_segwit_and_uses/
[bip173 test vectors]: https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki#Test_vectors
