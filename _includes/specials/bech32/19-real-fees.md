As of this writing, the price of bitcoin in national currencies has been
rapidly increasing over the past few months.
Significant changes to
the bitcoin price are notable in the context of bech32 because
transaction fees are paid in bitcoin terms rather than dollar terms.
That means the real cost to send a transaction is expected to increase
in correspondence with bitcoin prices even if feerates stay the same.

We've previously discussed [how much users and services can save][bech32 savings
segment] by switching to native segwit (bech32) addresses, but we've
only described that in terms of vbyte and percentage savings.  In this
bech32 sending support section, we look at the savings in real terms.

The lowest practical fee is 0.00000001 BTC/vbyte.  The highest typical fees
seen to date were around 0.00001000 BTC/vbyte in December 2017 and January 2018.
For that range, the following charts show the amount of money that may be saved for
users of two common transaction templates, single-sig and 2-of-3
multisig:

![Single-sig legacy P2PKH versus segwit P2WPKH](/img/posts/2019-07-real-cost-p2pkh-p2wpkh.png)

![2-of-3 multisig legacy P2SH versus segwit P2WSH](/img/posts/2019-07-real-cost-p2sh-p2wsh.png)

For users of legacy transactions with other transaction templates,
you may be able to learn roughly how much you will save in percentage
terms by pasting in the txid of a typical transaction you sent into
information sites such as an Esplora
block explorer like [Blockstream.info][].  You can multiply that
percentage by the vbyte size of your transaction to see how many vbytes
you'd save.  Note that using a third-party service reveals to them that
you have an interest in that transaction, possibly significantly
reducing your privacy.  You can privately get the approximate vbyte
savings by examining a typical transaction of
yours.[^measure-scriptsigs]  When you know how many vbytes you'll save,
you can calculate the amount of your savings in another currency by
multiplying the saved vbytes by your expected feerate in BTC/vbyte and
your expected price per bitcoin, e.g.  `saved_vbytes * feerate * price`.

If users of native segwit begin to save tens or hundreds of dollars per
transaction, we expect there to be increased competitive pressure for
high-frequency spenders such as exchanges to migrate to only accepting
deposits using bech32 addresses.  Given that a very large percentage of
daily Bitcoin transactions are deposits to exchanges, we would then
expect wallets and services that don't provide bech32 sending support to
quickly fall out of favor with users.

[bech32 savings segment]: /en/bech32-sending-support/#fee-savings-with-native-segwit
[transactionfee.info]: https://transactionfee.info/
[blockstream.info]: https://blockstream.info/

[^measure-scriptsigs]:
    1. Use a tool to parse the transaction. Bitcoin Core comes bundled with
       a tool called `bitcoin-tx` that can do this for you. Run
       `bitcoin-tx -json <hex_serialized_tx>`

    2. Add up the total size of all scriptSigs. `bitcoin-tx` outputs the hex
       of each scriptSig. Halve the length of this hex string to get the
       size of the scriptSig.

    3. Multiply the size of scriptSigs that value by 0.75 to get vbytes
       saved.
