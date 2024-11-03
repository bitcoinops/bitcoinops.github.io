在[上周的 Newsletter][Newsletter #40 bech32] 中，我们使用 Python 参考库对 bech32 进行了演示，将一个地址解码为一个 scriptPubKey，您可以支付给该地址。然而，有时用户提供的地址会包含一个拼写错误。我们建议的代码可以检测到拼写错误，确保您不会支付到错误的地址，但 bech32 也可以帮助检测用户拼写错误的位置。本周，我们将使用 [Javascript 示例代码][javascript sample code]来展示这种功能。

该代码使用 Node.js 风格的模块包含语法编写，所以第一步是将其编译为可以在浏览器中使用的代码。为此，我们需要安装一个 [browserify][] 工具：

```bash
sudo apt install node-browserify-lite
```

然后将其编译为一个独立文件：

```bash
browserify-lite ./segwit_addr_ecc.js --outfile bech32-demo.js --standalone segwit_addr_ecc
```

接着将其包含在我们的 HTML 中：

```html
<script src="bech32-demo.js"></script>
```

为了方便，我们已在该 Newsletter 的[网页版][Newsletter #41 bech32] 中包含了该文件，因此您只需打开 Web 浏览器中的开发者控制台，就可以按照本例的其余部分操作。让我们从检查一个有效地址开始。回想一下上周，我们在检查地址时提供了网络标识符（`bc` 表示 Bitcoin 主网）：

```text
>> segwit_addr_ecc.check('bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4', 'bc')
error: null
program: Array(20) [ 117, 30, 118, … ]
version: 0
```

如上所示，就像上周一样，我们得到见证版本和见证程序。版本字段的存在，加上没有错误，表明该程序解码时没有任何校验和失败。

现在我们在上面的地址中替换一个字符，并尝试检查它：

```text
>> segwit_addr_ecc.check('bc1qw508d6qejxtdg4y5r4zarvary0c5xw7kv8f3t4', 'bc')
error: "Invalid"
pos: Array [ 21 ]
```

这次我们得到了错误的描述（地址无效，因为它不匹配其校验和）和一个位置。如果我们将上面的地址逐个字符对齐，可以看到这个“21”标识了特定错误的位置：

```text
                   1x        2x
         0123456789012345678901
>> good='bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4'
>> typo='bc1qw508d6qejxtdg4y5r4zarvary0c5xw7kv8f3t4'
                              ^
```

如果我们对拼写错误的地址进行另一次替换并再次尝试会怎样？

```text
>> segwit_addr_ecc.check('bc1qw508d6qejxtdg4y5r4zarvary0c5yw7kv8f3t4', 'bc')
error: "Invalid"
pos: Array [ 32, 21 ]
```

我们得到两个位置。同样，当我们将这些地址逐个字符对齐，可以看到它识别了两个不正确的字符：

```text
                   1x        2x        3x
         012345678901234567890123456789012
>> good='bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4'
>> typo='bc1qw508d6qejxtdg4y5r4zarvary0c5yw7kv8f3t4'
                              ^          ^
```

Pieter Wuille 的[互动演示][interactive demo] 包含几行额外的代码（在该页面查看源代码以查看该函数），该代码使用拼写错误字符的位置将其以红色突出显示：

![bech32 互动演示的截图，拼写错误的地址位于上方](/img/posts/2019-04-bech32-demo.png)

`check()` 函数能够具体识别的错误数量有限。之后，它仍然可以告诉您地址包含错误，但无法识别地址中的具体位置。在这种情况下，它仍然会返回地址无效，但不会返回位置详细信息：

```text
>> segwit_addr_ecc.check('bc1qw508z6qejxtdg4y5r4zarvary0c5yw7kv8f3t4', 'bc')
error: "Invalid"
pos: null
```

如果地址存在其他问题，`error` 字段将设置为更具描述性的信息，这些信息可能会也可能不会包含错误的位置。例如：

```text
>> segwit_addr_ecc.check('bc1zw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4yolo', 'bc')
error: "Invalid character"
pos: Array [ 43 ]
```

您可以查看[源代码][bech32 errors]以获取完整的错误列表。

尽管我们在这个迷你教程中花了很多时间研究错误，但我们希望展示在基于 Web 的平台上为用户提供 bech32 地址时提供良好互动反馈是多么容易。我们鼓励您玩转[互动演示][interactive demo]，以了解如果您使用这种 bech32 地址功能，您的用户可能会看到什么。

<script src="/misc/bech32-demo.js"></script>
[browserify]: http://browserify.org/
[javascript sample code]: https://github.com/sipa/bech32/tree/master/ecc/javascript
[interactive demo]: http://bitcoin.sipa.be/bech32/demo/demo.html
[bech32 errors]: https://github.com/sipa/bech32/blob/master/ecc/javascript/segwit_addr_ecc.js#L54
[newsletter #40 bech32]: /zh/newsletters/2019/04/02/#bech32-发送支持
[newsletter #41 bech32]: /zh/newsletters/2019/04/09/#bech32-发送支持
