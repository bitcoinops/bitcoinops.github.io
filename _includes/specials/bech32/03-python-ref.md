In a [previous week][bech32 easy], we discussed how small the
differences are between creating the output for a legacy address versus
a native segwit address.  In that section we simply pointed you towards
the [bech32 reference libraries][] and told you that you'd get two
values back.  In this week, we walkthrough the exact steps of using the
Python reference library so you can see how little work this is.  We
start by importing the library:

```python3
>>> import segwit_addr
```

Bech32 addresses have a Human-Readable Part (HRP) that indicates what
network the address is for.  These are the first few characters of the
address and are separated from the data part of the address by the
delimiter `1`.  For example, Bitcoin testnet uses `tb` and an example
testnet address is tb1q3w[...]g7a.  We'll set the Bitcoin mainnet HRP of
`bc` in our code so that we can later ensure that the addresses we parse
are for the network we expect.

```python3
>>> HRP='bc'
```

Finally, we have a few addresses we want to check---one that should work
and two that should fail.  (See [BIP173][] for a complete set of
[reference test vectors][bip173 test vectors].)

```python3
>>> good_address='bc1qd6h6vp99qwstk3z668md42q0zc44vpwkk824zh'
>>> typo_address='bc1qd6h6vp99qwstk3z669md42q0zc44vpwkk824zh'
>>> wrong_network_address='tb1q3wrc5yq9c300jxlfeg7ae76tk9gsx044ucyg7a'
```

Now we can simply attempt to decode each of these addresses

```python3
>>> segwit_addr.decode(HRP, good_address)
(0, [110, 175, 166, 4, 165, 3, 160, 187, 68, 90, 209,
     246, 218, 168, 15, 22, 43, 86, 5, 214])

>>> segwit_addr.decode(HRP, typo_address)
(None, None)

>>> segwit_addr.decode(HRP, wrong_network_address)
(None, None)
```

If we get back a None for the first value (the witness version), the
address is invalid on our chosen network.  If that happens, you want to throw an
exception up the stack so that whatever process is interfacing with the
user can get them to provide you with a correct address.  If you
actually get a number and an array, the decode succeeded, the checksum
was valid, and the length was within the allowed range.

The witness version must be a number between 0 and 16, so you'll want to
check that (e.g. `0 <= x <= 16`) and then convert it into the
corresponding opcodes `OP_0` through `OP_16`.  For `OP_0`, this is 0x00;
for `OP_1` through `OP_16`, this is 0x51 through 0x60.  You then need to
add a push byte for the data depending on its length (0x02 through 0x28
for 2 to 40 bytes), and then append the data as a series of bytes.
Pieter Wuille's [code][segwit addr to bytes] does this quite succinctly:

```python3
>>> witver, witprog = segwit_addr.decode(HRP, good_address)
>>> bytes([witver + 0x50 if witver else 0, len(witprog)] + witprog).hex()
'00146eafa604a503a0bb445ad1f6daa80f162b5605d6'
```

That's your entire scriptPubKey.  You can use that in the output of a
transaction and send it.  Note that bech32 scriptPubKeys can vary in
size from 4 to 42 vbytes, so you need to consider the actual size of the
scriptPubKey in your fee estimation code.

Your code doesn't need to be written in Python.  Reference libraries
are also provided for C, C++, Go, Haskell, JavaScript, Ruby, and Rust.
Further, [BIP173][] describes bech32 well enough that any decent
programmer should be able to implement it from scratch in their preferred
language without requiring anything beyond what most programming
languages provide in their builtins and standard library.

**Other bech32 sending support updates:** BitGo [announced][bitgo
segwit] that their API now supports sending to bech32 addresses; see
their announcement for additional details about bech32 receiving support.
The Gemini exchange also [apparently][gemini reddit] added bech32
sending support this week, and users report that Gemini defaults to accepting
deposits to bech32 addresses as well.

[bech32 easy]: {{news38}}#bech32-sending-support
[bech32 reference libraries]: https://github.com/sipa/bech32/tree/master/ref
[segwit addr to bytes]: https://github.com/sipa/bech32/blob/master/ref/python/tests.py#L30
[bitgo segwit]: https://blog.bitgo.com/native-segwit-addresses-via-bitgos-api-4946f2007be9
[gemini reddit]: https://www.reddit.com/r/Bitcoin/comments/b66n0v/psa_gemini_is_full_on_with_native_segwit_and_uses/
[bip173 test vectors]: https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki#Test_vectors
