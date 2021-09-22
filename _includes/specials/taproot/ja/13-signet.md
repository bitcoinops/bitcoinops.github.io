mainnetで[ブロック{{site.trb}}より前にTaprootを安全に使用することはできませんが][taproot safety]、
今日、testnetまたはsignetのいずれかでTaprootを使用することはできます。
[Optech taproot workbooks][]で行われているように、
Bitcoin Coreのregtestモードでローカルのテストネットワークを作成するのに比べて、
testnetやsignetを使用すると、自分のウォレットが他の人のウォレットとどのように相互作用するか簡単にテストできます。

この記事では、[signet][topic signet]上でBitcoin Coreの内蔵ウォレットを使って、
Taprootトランザクションを受信したり支払いしたります。
自分のウォレットとBitcoin Coreの間で送受信をテストするのに、この手順を利用できます。

技術的には、Bitcoin Core 22.0の内蔵ウォレットを使ってTaprootトランザクションを受信および使用することは可能ですが、
代わりに、[descriptor][topic descriptors]ウォレットのデフォルトをTaprootにした、
Bitcoin CoreのPR [#22364][bitcoin core #22364]をビルドすることをお勧めします。
ビルドし、signetを起動します:

```text
$ bitcoind -signet -daemon
```

初めてsignetを起動する場合は、ブロックチェーンを同期する必要があります。
現在は、200 MB以下のデータで、わずか1分で同期が完了します。
同期の進捗状況は`getblockchaininfo` RPC使って確認できます。
同期後、descriptorウォレットを作成します:

```text
$ bitcoin-cli -signet -named createwallet wallet_name=p4tr descriptors=true load_on_startup=true
{
  "name": "p4tr",
  "warning": "Wallet is an experimental descriptor wallet"
}
```

これで、bech32mアドレスを作成できます:

```
$ bitcoin-cli -named -signet getnewaddress address_type=bech32m
tb1p6h5fuzmnvpdthf5shf0qqjzwy7wsqc5rhmgq2ks9xrak4ry6mtrscsqvzp
```

このアドレスを使って、[signet faucet][]に資金をリクエストできます。
その後、承認を待つ必要がありますが、これにはmainnetと同じように時間がかかります（通常は最大30分、
時にはそれ以上かかることもあります）。
トランザクションが確認できると、作成したP2TRスクリプトが表示されるでしょう。

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

続いて、2つめのbech32mアドレスを作成し、そこに資金を送って支払いをテストできます。

```text
$ bitcoin-cli -named -signet getnewaddress address_type=bech32m
tb1p53qvqxja52ge4a7dlcng6qsqggdd85fydxs4f5s3s4ndd2yrn6ns0r6uhx
$ bitcoin-cli -named -signet sendtoaddress address=tb1p53qvqxja52ge4a7dlcng6qsqggdd85fydxs4f5s3s4ndd2yrn6ns0r6uhx amount=0.00099
24083fdac05edc9dbe0bb836272601c8893e705a2b046f97193550a30d880a0c
```

この支払いについて、インプットの１つを確認すると、そのwitnessには64バイトの署名が1つだけ含まれています。
これはP2WPKHやその他のタイプの古いBitcoinの支払いをした場合に必要とされるwitnessよりもvbyte数が[小さくなっています][p2tr vs p2wpkh]。

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

上記のコマンドをいじってみると、signetに対応しているウォレットでTaprootを使ってお金を受け取ったり、
支払ったりするのが簡単であることが分かります。

{% include linkers/issues.md issues="22364" %}
[taproot safety]: /ja/preparing-for-taproot/#なぜ待つ必要があるのか
[optech taproot workbooks]: /ja/preparing-for-taproot/#taprootを使って学ぶ
[p2tr vs p2wpkh]: /ja/preparing-for-taproot/#taprootはシングルシグでも価値があるか
[signet faucet]: https://signetfaucet.com/
