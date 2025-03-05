尽管你[无法在主网区块 {{site.trb}} 前安全使用 Taproot][taproot safety]，但你现在可以通过 testnet 或 signet 使用 Taproot。与使用 Bitcoin Core 的 regtest 模式创建本地测试网络（如 [Optech Taproot 工作手册][Optech taproot workbooks] 所示）相比，使用 testnet 或 signet 能更方便地测试你的钱包与其他用户钱包的交互。

本文将演示如何在 [signet][topic signet] 上使用 Bitcoin Core 内置钱包接收和花费 Taproot 交易。你可以根据这些指令调整，以测试你的钱包与 Bitcoin Core 之间的收发功能。

虽然 Bitcoin Core 22.0 的内置钱包技术上支持收发 Taproot 交易，但我们建议你编译 Bitcoin Core 的拉取请求 [#22364][bitcoin core #22364]，该请求将 Taproot 设为[描述符][topic descriptors]钱包的默认选项。编译完成后，启动 signet：

```text
$ bitcoind -signet -daemon
```

如果是首次使用 signet，需同步其区块链。当前数据量不足 200 MB，可在约一分钟内完成同步。可通过 `getblockchaininfo` RPC 监控同步进度。同步完成后，创建描述符钱包：

```text
$ bitcoin-cli -signet -named createwallet wallet_name=p4tr descriptors=true load_on_startup=true
{
  "name": "p4tr",
  "warning": "此钱包为实验性描述符钱包"
}
```

现在可生成 bech32m 地址：

```
$ bitcoin-cli -named -signet getnewaddress address_type=bech32m
tb1p6h5fuzmnvpdthf5shf0qqjzwy7wsqc5rhmgq2ks9xrak4ry6mtrscsqvzp
```

使用该地址可从 [signet faucet][] 获取测试币。需等待交易确认，时间与主网类似（通常 30 分钟内，有时更长）。查看交易详情时，会注意到创建的 P2TR 脚本：

```text
$ bitcoin-cli -signet getrawtransaction 688f8c792a7b3d9cb46b95bfa5b10fe458617b758fe4100c5a1b9536bedae4cd true | jq .vout[0]
{
  "value": 0.001,
  "n": 0,
  "scriptPubKey": {
    "asm": "1 d5e89e0b73605abba690ba5e00484e279d006283bed0055a0530fb6a8c9adac7",
    "hex": "5120d5e89e0b73605abba690ba5e00484e279d006283bed0055a0530fb6a8c9adac7",
    "address": "tb1p6h5fuzmnvpdthf5shf0qqjzwy7wsqc5rhmgq2ks9xrak4ry6mtrscsqvzp",
    "type": "witness_v1_taproot"
  }
}
```

接下来可生成第二个 bech32m 地址并发送资金以测试花费功能：

```text
$ bitcoin-cli -named -signet getnewaddress address_type=bech32m
tb1p53qvqxja52ge4a7dlcng6qsqggdd85fydxs4f5s3s4ndd2yrn6ns0r6uhx
$ bitcoin-cli -named -signet sendtoaddress address=tb1p53qvqxja52ge4a7dlcng6qsqggdd85fydxs4f5s3s4ndd2yrn6ns0r6uhx amount=0.00099
24083fdac05edc9dbe0bb836272601c8893e705a2b046f97193550a30d880a0c
```

查看该花费交易的输入部分，可见其见证数据仅包含一个 64 字节的签名。这比 P2WPKH 或其他传统比特币交易所需的见证数据[更精简][p2tr vs p2wpkh]（以虚拟字节计）。

```text
$ bitcoin-cli -signet getrawtransaction 24083fdac05edc9dbe0bb836272601c8893e705a2b046f97193550a30d880a0c true | jq .vin[0]
{
  "txid": "bd6dbd2271a95bce8a806288a751a33fc4cf2c336e52a5b98a5ded432229b6f8",
  "vout": 0,
  "scriptSig": {
    "asm": "",
    "hex": ""
  },
  "txinwitness": [
    "2a926abbc29fba46e0ba9bca45e1e747486dec748df1e07ee8d887e2532eb48e0b0bff511005eeccfe770c0c1bf880d0d06cb42861212832c5f01f7e6c40c3ce"
  ],
  "sequence": 4294967294
}
```

通过实践上述指令，你将能轻松在任何支持 signet 的钱包中测试 Taproot 的收发功能。

{% include linkers/issues.md issues="22364" %}
[taproot safety]: /zh/preparing-for-taproot/#我们为什么要等待
[optech taproot workbooks]: /zh/preparing-for-taproot/#通过使用学习-taproot
[p2tr vs p2wpkh]: /zh/preparing-for-taproot/#taproot-对单签名是否有意义
[signet faucet]: https://signetfaucet.com/
