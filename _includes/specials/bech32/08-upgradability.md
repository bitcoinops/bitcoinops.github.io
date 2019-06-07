What do bip-taproot and bip-tapscript mean for people who have
implemented bech32 sending support or who are planning to implement it?
In particular, if you haven't implemented segwit sending support yet,
should you wait to implement it until the new features have been
activated?  In this weekly section, we'll show why you shouldn't wait
and how implementing sending support now won't cost you any extra effort
in the future.

The designers of segwit and bech32 had a general idea what future
protocol improvements would look like, so they engineered segwit
scriptPubKeys and the bech32 address format to be forward compatible
with those expected improvements.  For example an address supporting
Taproot might look like this:

```text
bc1pqzkqvpm76ewe20lcacq740p054at9sv7vxs0jn2u0r90af0k63332hva8pt
```

You'll notice that looks just like other bech32 addresses you've
seen---because it is.  You can use the exact same code we provided in
[Newsletter #40][] (using the bech32 reference library for Python) to decode
it.

```python
>> import segwit_addr
>> address='bc1pqzkqvpm76ewe20lcacq740p054at9sv7vxs0jn2u0r90af0k63332hva8pt'
>> witver, witprog = segwit_addr.decode('bc', address)
>> witver
1
>> bytes(witprog).hex()
'00ac06077ed65d953ff8ee01eabc2fa57ab2c19e61a0f94d5c78cafea5f6d46315'
```

The differences here from the decoded bech32 addresses we've shown in
previous newsletters are that this hypothetical Taproot address uses a
witness version of `1` instead of `0` (meaning the scriptPubKey will
start with `OP_1` instead of `OP_0`) and the witness program is one
byte longer than a P2WSH witness program.  However, these don't matter
to your software if you're just spending.  We can use the exact same
example code from [Newsletter #40][news40 bech32] to create the
appropriate scriptPubKey for you to pay:

```python
>> bytes([witver + 0x50 if witver else 0, len(witprog)] + witprog).hex()
'512100ac06077ed65d953ff8ee01eabc2fa57ab2c19e61a0f94d5c78cafea5f6d46315'
```

This means anyone who implements bech32 support in the generic way
described in Newsletter #40 shouldn't need to do anything special in
order to support future script upgrades.  In short, the work you invest
into providing bech32 sending support now is something you won't need to
repeat when future expected changes to the Bitcoin protocol are
deployed.

[news40 bech32]: {{news40}}#bech32-sending-support
