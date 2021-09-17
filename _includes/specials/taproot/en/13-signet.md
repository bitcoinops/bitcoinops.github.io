Although you [can't safely use taproot before block
{{site.trb}}][taproot safety] on mainnet, you can use taproot today with
either testnet or signet.  Compared to creating a local test network
with Bitcoin Core's regtest mode, as done in the [Optech taproot
workbooks][], using testnet or signet makes it easier to test how your
wallet interacts with other people's wallets.

In this post, we'll receive and spend a taproot transaction using
Bitcoin Core's built-in wallet on [signet][topic signet].  You should be able to adapt
these instructions for testing receives and spends between your own
wallet and Bitcoin Core.

Although it's technically possible to receive and spend taproot
transactions using the built-in wallet in Bitcoin Core 22.0, we
recommend that you instead build Bitcoin Core pull request
[#22364][bitcoin core #22364], which makes taproot the default for
[descriptor][topic descriptors] wallets.  Once built, start signet:

```text
$ bitcoind -signet -daemon
```

If this is your first time using signet, you'll need to sync its block
chain.  That currently includes less than 200 MB of data and can finish
syncing in as little as a minute.  You can monitor sync progress using
the `getblockchaininfo` RPC.  After syncing, create a descriptor wallet:

```text
$ bitcoin-cli -signet -named createwallet wallet_name=p4tr descriptors=true load_on_startup=true
{
  "name": "p4tr",
  "warning": "Wallet is an experimental descriptor wallet"
}
```

Now you can create a bech32m address:

```
$ bitcoin-cli -named -signet getnewaddress address_type=bech32m
tb1p6h5fuzmnvpdthf5shf0qqjzwy7wsqc5rhmgq2ks9xrak4ry6mtrscsqvzp
```

With this address, you can request funds from the [signet faucet][].
You'll then need to wait for a
confirmation, which will take the same variable amount of time you'd
expect on mainnet (typically up to 30 minutes, but sometimes longer).
If you look at the transaction, you'll notice the P2TR script you
created.

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

You can then create a second bech32m address and send the funds there to
test spending.

```text
$ bitcoin-cli -named -signet getnewaddress address_type=bech32m
tb1p53qvqxja52ge4a7dlcng6qsqggdd85fydxs4f5s3s4ndd2yrn6ns0r6uhx
$ bitcoin-cli -named -signet sendtoaddress address=tb1p53qvqxja52ge4a7dlcng6qsqggdd85fydxs4f5s3s4ndd2yrn6ns0r6uhx amount=0.00099
24083fdac05edc9dbe0bb836272601c8893e705a2b046f97193550a30d880a0c
```

For this spend, we can look at one of the inputs and see that its
witness contains nothing but a single 64-byte signature. That's
[smaller][p2tr vs p2wpkh] in vbytes than the witness which would’ve been
required if this was a P2WPKH spend or any other type of older Bitcoin
spend.


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

By playing around with the above commands, you should find it easy to
receive and spend money using taproot with any wallet that supports signet.

{% include linkers/issues.md issues="22364" %}
[taproot safety]: /en/preparing-for-taproot/#why-are-we-waiting
[optech taproot workbooks]: /en/preparing-for-taproot/#learn-taproot-by-using-it
[p2tr vs p2wpkh]: /en/preparing-for-taproot/#is-taproot-even-worth-it-for-single-sig
[signet faucet]: https://signetfaucet.com/
