bip-taproot 和 bip-tapscript 对已经实现 Bech32 发送支持或计划实现的人员意味着什么？特别是，如果您尚未实现 Segwit 发送支持，是否应等待新功能激活后再实现？在本周的章节中，我们将展示为何您不应等待，以及现在实现发送支持将来不会增加额外工作量的原因。

Segwit 和 Bech32 的设计者对未来协议改进有一个大致的想法，因此他们设计了 Segwit scriptPubKeys 和 Bech32 地址格式，以便与这些预期的改进向前兼容。例如，支持 Taproot 的地址可能如下所示：

```text
bc1pqzkqvpm76ewe20lcacq740p054at9sv7vxs0jn2u0r90af0k63332hva8pt
```

您会注意到它看起来就像您见过的其他 Bech32 地址——因为它确实如此。您可以使用我们在 [Newsletter #40][] 中提供的相同代码（使用 Bech32 参考库的 Python）来解码它。

```python
>> import segwit_addr
>> address='bc1pqzkqvpm76ewe20lcacq740p054at9sv7vxs0jn2u0r90af0k63332hva8pt'
>> witver, witprog = segwit_addr.decode('bc', address)
>> witver
1
>> bytes(witprog).hex()
'00ac06077ed65d953ff8ee01eabc2fa57ab2c19e61a0f94d5c78cafea5f6d46315'
```

与我们在以前的 Newsletters 中显示的解码 Bech32 地址的区别在于，这个假设的 Taproot 地址使用 `1` 的见证版本，而不是 `0`（意味着 scriptPubKey 将以 `OP_1` 开头，而不是 `OP_0`），并且见证程序比 P2WSH 见证程序长一个字节。然而，如果您只是支出，这些对您的软件来说并不重要。我们可以使用 [Newsletter #40][news40 bech32] 中的相同示例代码来创建适合您支付的 scriptPubKey：

```python
>> bytes([witver + 0x50 if witver else 0, len(witprog)] + witprog).hex()
'512100ac06077ed65d953ff8ee01eabc2fa57ab2c19e61a0f94d5c78cafea5f6d46315'
```

这意味着任何以 Newsletter #40 中描述的通用方式实现 Bech32 支持的人都不需要做任何特殊的事情来支持未来的脚本升级。简而言之，您现在提供 Bech32 发送支持的工作将来在比特币协议的预期变化部署时无需重复。

[news40 bech32]: /zh/newsletters/2019/04/02/#bitcoin-core-schedules-switch-to-default-bech32-receiving-addresses
