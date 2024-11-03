最近，一位 Optech 贡献者对许多流行的钱包和比特币交易所进行了调查，以了解它们支持哪些技术功能。对于其中一家交易所，他最初记录其支持发送到 bech32 地址，但后来发现其支持并不完全。

问题在于，该交易所支持 P2WPKH bech32 地址（单签名地址），但不支持 P2WSH bech32 地址（多重签名和复杂脚本地址）。另一个问题是，该交易所接受全小写的 bech32 地址，但不接受全大写的 bech32 地址。而另一家交易所则限制了地址表单字段的长度，以至于无法容纳所有有效的 bech32 地址。

考虑到这些问题，我们创建了一个简短的检查清单，用于测试基本的 bech32 发送支持。请仅使用少量比特币执行这些测试，以防万一出现问题时不会造成大的损失。

1. 生成两个自己的地址，一个用于 P2WPKH，另一个用于 P2WSH。例如，使用 Bitcoin Core、[jq][] JSON 解析器和 Bash shell，你可以运行以下命令：

     ```bash
     $ p2wpkh=$( bitcoin-cli getnewaddress "bech32 test" bech32 )
     $ p2wsh=$(
       bitcoin-cli addmultisigaddress 1 \[$(
         bitcoin-cli getaddressinfo $p2wpkh | jq .pubkey
       )\] "bech32 test" bech32 | jq -r .address
     )
     $ echo $p2wpkh $p2wsh
     $ echo $p2wpkh $p2wsh | tr '[a-z]' '[A-Z]'
     ```

2. 使用你的软件或服务的常规支出或提现表单，测试向每个小写地址发送比特币。

3. 使用每个地址的大写形式再次测试（这些对于[二维码][bech32 qr code section]很有用）。

4. 通过检查你用于创建地址的钱包或区块浏览器，确保你收到了资金。如果一切正常，你的软件完全支持当前的 bech32 支付地址。

     如果你使用了临时的 Bitcoin Core 钱包创建了地址，可以等待交易确认后，使用以下命令将所有资金发送到你的常规钱包：`bitcoin-cli sendtoaddress YOUR_ADDRESS $( bitcoin-cli getbalance ) '' '' true`

对于不实际尝试发送资金的单元测试，或在 testnet 或回归测试模式下发送资金的集成测试，BIP173 提供了更全面的[测试向量][bip173 test vectors]。

[jq]: https://stedolan.github.io/jq/
[bech32 qr code section]: /zh/bech32-sending-support/#使用-bech32-地址创建更高效的二维码
[bip173 test vectors]: https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki#Test_vectors