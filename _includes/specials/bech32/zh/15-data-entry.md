{% assign input_base58check_address = "1B6FkNg199ZbPJWG5zjEiDekrCc2P7MVyC" %}
{% assign input_bech32_address = "bc1qd6h6vp99qwstk3z668md42q0zc44vpwkk824zh" %}

在 Segwit 激活之前，开发者讨论了使用何种格式来表示原生 Segwit 地址，有些开发者建议这是一个让地址更易于阅读和转录的机会。开发者 Gregory Maxwell 有效地表达了这一观点，他[询问][maxwell phone]其他开发者打电话给他，并尝试通过电话成功传达一个混合大小写的传统 base58check 地址。如果在传达过程中仅有一个字符出错——甚至只是那个字符是大写还是小写——双方都需要回过头来仔细查找错误。

[BIP173][] 的 Bech32 地址能够解决这两个问题。它们仅使用单一大小写（通常优先使用小写字母，但在使用二维码时可以使用大写字母以[提高效率][bech32 qr code section]），并且它们使用带有校验码的错误校正码，可以[帮助用户定位错误][bech32 ecc section]，同时确保在绝大多数情况下能够捕捉到输入错误。

然而，随着钱包和服务考虑升级以支持 Bech32 地址的发送和接收，我们认为值得提醒任何犹豫的实施者注意 Bech32 地址的这一关键用户收益功能——因此我们自动化了 Maxwell 旧电话测试的一部分，以便您私下评估转录传统地址和原生 Segwit 地址的相对难度。

如果您点击以下链接（在新标签页中打开），您会发现两个支付相同哈希值的地址的录音。您可以将地址输入到下面相应的框中，如果输入了错误的字符（区分大小写），框会立即变红。注意：为了提高准确性并消除特定语言环境的字母发音问题，我们在文件中使用音标字母读取每个字母，例如 `Alfa` 代表 *A*；`Bravo` 代表 *B*，等等。

<noscript><p><b>注意：</b>建议启用 JavaScript——如果您希望在输入错别字时输入框自动变为红色，您需要启用 JavaScript。然而，如果您禁用了 JavaScript——好样的！——我们建议您像往常一样输入内容，然后使用鼠标突出显示整个段落。在这个句子结束后，在通常不可见的白色文本中有两个地址；当您突出显示该段落（更改其背景颜色）时，它们应该会变得可见，以便您手动将其与输入内容进行比较：<span class="spoiler">{{input_base58check_address}} 和 {{input_bech32_address}}。</span></p></noscript>

[Base58check 和 Bech32 地址的朗读（1 分 33 秒）][bech32 audio]

**传统 base58check 地址：**

<input type="text" class="addrInput" id="{{input_base58check_address}}" oninput="validateAddress('{{input_base58check_address}}')">

**原生 Segwit Bech32 地址：**

<input type="text" class="addrInput" id="{{input_bech32_address}}" oninput="validateAddress('{{input_bech32_address}}')">

如果您发现 Bech32 地址更容易准确转录，这意味着 Bech32 设计者在实现新地址格式的一个目标上取得了成功。发现 Bech32 优势的用户更可能希望在需要读取或转录地址的情况下使用 Bech32 地址，因此如果您的软件或服务支持发送到 Bech32 地址，他们将更倾向于使用它。

[bech32 audio]: /img/posts/2019-06-base58-vs-bech32-audio.ogg
[maxwell phone]: http://www.erisian.com.au/meetbot/bitcoin-core-dev/2016/bitcoin-core-dev.2016-03-10-18.59.log.html#l-59
[bech32 qr code section]: /zh/bech32-sending-support/#使用-bech32-地址创建更高效的二维码
[bech32 ecc section]: /zh/bech32-sending-support/#查找-bech32-地址中的拼写错误

<script>
function validateAddress(instance) {
  // Prefix the input field's current value with a ^ for a regex
  var userAddress = '^' + document.getElementById(instance).value;
  // Compile it into a regex
  var matchRegex = new RegExp(userAddress);
  // Clear the old style
  document.getElementById(instance).classList.remove("redbg")
  // If wrong, set red background
  if (! instance.match(matchRegex)) {
    document.getElementById(instance).classList.add("redbg");
  }
}
</script>

<style>
.addrInput {
  min-width: 30em;
  min-height: 1.5em;
}

.redbg { background-color: pink; }
.spoiler { color: white; }
</style>

