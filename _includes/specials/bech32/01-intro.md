Bech32 native segwit addresses were first publicly [proposed][bech32
proposed] almost exactly two years ago, becoming the [BIP173][]
standard.  This was followed by the segwit soft fork's lock-in on 24
August 2017.  Yet, seventeen months after lock-in, some popular wallets
and services still don't support sending bitcoins to bech32 addresses.
Developers of other wallets and services are tired of waiting and want
to default to receiving payments to bech32 addresses so that they can
achieve additional fee savings and improved privacy.  Bitcoin Optech
would like to help this process along so, from now until the two-year
anniversary of segwit lock-in, each of our newsletters will include a
short section with resources to help get bech32 sending support fully
deployed.

Note, we are only directly advocating bech32 **sending** support.  This
allows the people you pay to use segwit but doesn't require you to
implement segwit yourself.  (If you want to use segwit yourself to save
fees or access its other benefits, that's great!  We just encourage you
to implement bech32 sending support first so that the people you pay can
begin taking advantage of it immediately while you upgrade the rest of
your code and infrastructure to fully support segwit.)  To that end,
this week's section focuses on showing exactly how small the differences
are between sending to a legacy address and sending to a bech32 address.

### Sending to a legacy address

For a P2PKH legacy address that you already support such as
1B6FkNg199ZbPJWG5zjEiDekrCc2P7MVyC, your base58check library will decode
that to a 20-byte commitment:

     6eafa604a503a0bb445ad1f6daa80f162b5605d6

This commitment is inserted into a scriptPubKey template:

<pre>OP_DUP OP_HASH160 OP_PUSH20 <b>6eafa604a503a0bb445ad1f6daa80f162b5605d6</b> OP_EQUALVERIFY OP_CHECKSIG</pre>

Converting the opcodes to hex, this looks like:

    76a9146eafa604a503a0bb445ad1f6daa80f162b5605d688ac

This is inserted into the scriptPubKey part of an output that also
includes the length of the script (25 bytes) and the amount being paid:

<pre>     amount                           scriptPubKey
|--------------|  |------------------------------------------------|
00e1f5050000000019<b>76a9146eafa604a503a0bb445ad1f6daa80f162b5605d688ac</b>
                |
    size: 0x19 -> 25 bytes</pre>

This output can then be added to the transaction, which is then signed
and broadcast.

### Sending to a bech32 address

For an equivalent bech32 P2WPKH address such as
bc1qd6h6vp99qwstk3z668md42q0zc44vpwkk824zh, you can use one of the
[reference libraries][bech32 ref libs] to decode the address to a pair
of values:

    0 6eafa604a503a0bb445ad1f6daa80f162b5605d6

These two values are also inserted into a scriptPubKey template.  The
first value is the witness script version byte that's used to add a
value to the stack using one of the opcodes from `OP_0` to `OP_16`.
The second is the commitment that's also pushed onto the stack:

<pre><b>OP_0</b> OP_PUSH20 <b>6eafa604a503a0bb445ad1f6daa80f162b5605d6</b></pre>

Converting the opcodes to hex, this looks like:

    00146eafa604a503a0bb445ad1f6daa80f162b5605d6

Then, just as before, this is inserted into the scriptPubKey part of an
output:

<pre>     amount                        scriptPubKey
|--------------|  |------------------------------------------|
00e1f5050000000016<b>00146eafa604a503a0bb445ad1f6daa80f162b5605d6</b>
                |
    size: 0x16 -> 22 bytes</pre>

The output is added to the transaction.  The transaction is then signed
and broadcast.

For bech32 P2WSH (the segwit equivalent of P2SH) or for future segwit
witness versions, you don't need to do anything special.  The witness
script version may be a different number, requiring you to use the
corresponding `OP_0` to `OP_16` opcode, and the commitment may be a
different length (from 2 to 40 bytes), but nothing else about the output
changes.  Because length variations are allowed, ensure your fee
estimation software considers the actual size of the scriptPubKey rather
than using a constant someone previously calculated based on P2PKH or
P2SH sizes.

What you see above is the entire change you need to make on
the backend of your software in order to enable sending to bech32
addresses.  For most platforms, it should be a very easy change.  See
[BIP173][] and the [reference implementations][bech32 ref libs] for a
set of test vectors you can use to ensure your implementation works
correctly.

[bech32 proposed]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2017-March/013749.html
[bech32 ref libs]: https://github.com/sipa/bech32/tree/master/ref
