{% assign input_base58check_address = "1B6FkNg199ZbPJWG5zjEiDekrCc2P7MVyC" %}
{% assign input_bech32_address = "bc1qd6h6vp99qwstk3z668md42q0zc44vpwkk824zh" %}

在 segwit 激活之前，开发者们讨论了用于原生 segwit 地址的格式，一些开发者建议这是一个让地址更易于阅读和抄写的机会。开发者 Gregory Maxwell 通过[请求][maxwell phone]其他开发者打电话给他并尝试成功地通过电话传达一个混合大小写的旧式 base58check 地址，有效地指出了这一点。如果在传达过程中仅有一个字符的沟通错误——甚至只是该字符是大写还是小写——双方都需要回头仔细寻找错误。

[BIP173][] bech32 地址能够解决这两个问题。它们只使用一种大小写（大多数情况下首选小写，但对于 QR 码可以使用大写以[提高效率][bech32 qr code section]），并且它们使用错误校正码作为校验和，因此可以[帮助用户查找错误][bech32 ecc section]，同时确保绝大多数情况下能够捕捉到输入错误。

然而，随着钱包和服务考虑升级以支持 bech32 发送和接收，我们认为值得提醒那些犹豫不决的实现者这一 bech32 地址的关键用户受益特性——因此我们已经自动化了 Maxwell 旧电话测试的一部分，以便您私下评估转录旧式和原生 segwit 地址的相对难度。

如果您点击以下链接（在新标签页中打开），您会找到两个支付相同哈希值的地址录音。您可以将这些地址输入到下面的相应框中，如果您输入任何错误字符（区分大小写），该框将立即变红。注意：为了提高准确性并消除与地域特定字母发音相关的问题，我们使用音标字母表读取文件中的每个字母，例如 `Alfa` 代表 *A*；`bravo` 代表 *B* 等。

<noscript><p><b>注意：</b>推荐启用 JavaScript ——如果您希望输入框在输入错字时自动变红，您需要启用 JavaScript。然而，如果您禁用了 JS——很好！——我们建议您正常输入内容，然后使用鼠标高亮显示整个段落。在这个句子结尾之后的通常不可见的白色文本中有两个地址；当您高亮显示该段落（改变其背景颜色）时，它们应该会变得可见，以便您可以手动将它们与您的输入进行比较：<span class="spoiler">{{input_base58check_address}} 和 {{input_bech32_address}}。</span></p></noscript>

[base58check 和 bech32 地址的录音（1 分 33 秒）][bech32 audio]

**旧式 base58check 地址：**

<input type="text" class="addrInput" id="{{input_base58check_address}}" oninput="validateAddress('{{input_base58check_address}}')">

**原生 segwit bech32 地址：**

<input type="text" class="addrInput" id="{{input_bech32_address}}" oninput="validateAddress('{{input_bech32_address}}')">

如果您发现 bech32 地址更容易准确地转录，那么这意味着 bech32 的设计者成功实现了他们对新地址格式的目标之一。发现 bech32 这一优势的用户更可能在需要读取或抄写地址的情况下使用 bech32 地址，因此如果您的软件或服务支持发送到 bech32 地址，他们更可能使用您的软件或服务。

[bech32 audio]: /img/posts/2019-06-base58-vs-bech32-audio.ogg
[maxwell phone]: http://www.erisian.com.au/meetbot/bitcoin-core-dev/2016/bitcoin-core-dev.2016-03-10-18.59.log.html#l-59
[bech32 qr code section]: /zh/bech32-sending-support/#使用-bech32-地址创建更高效的二维码
[bech32 ecc section]: /zh/bech32-sending-support/#查找-bech32-地址中的拼写错误

<script>
function validateAddress(instance) {
  // 将输入字段的当前值加上 ^ 作为正则表达式
  var userAddress = '^' + document.getElementById(instance).value;
  // 将其编译成正则表达式
  var matchRegex = new RegExp(userAddress);
  // 清除旧样式
  document.getElementById(instance).classList.remove("redbg")
  // 如果错误，设置红色背景
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
