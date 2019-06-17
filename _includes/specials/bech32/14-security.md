There's a class of multisig users who not only [save on fees][bech32 fee
savings] by using bech32 addresses but who also receive improved
security against a potential type of attack called a *hash collision.*
This class of users includes many exchanges and other business users.

To provide some background, all common single-sig addresses on Bitcoin
today are the result of a pubkey being turned into a 160-bit RIPEMD160
hash digest.  It's theoretically possible for an attacker to generate a
second pubkey that they control, hash it, and produce the same address.
However, if we assume that the hash function produces perfectly
unpredictable output, then the chance of this happening with a 160-bit
hash function like RIPEMD160 is 1-in-2<sup>160</sup> for each pubkey the
attacker tries.

<!-- $ bitcoin-cli getmininginfo | jq .networkhashps
     65134463000474080000

    log2(65134463000474080000 * 60 * 60 * 5)
    79.95576417220315 -->

For comparison, Bitcoin miners perform 2<sup>80</sup> hashing operations
roughly every 5 hours as of this writing.  The SHA256d hashing operation
miners perform isn't the same as used in this RIPEMD160 collision
attack, so their equipment can't be repurposed for that use, but we can
use this as a reference rate for the number of brute force operations a
real-world system can perform today (at great expense).  At that rate,
an attack that performed the 2<sup>159</sup> operations necessary to
have a 50% chance of succeess would take about 25 million times the
estimated age of the universe so far.  <!-- 2**79 * 5 / 24 / 365.25 /
14e9 / 1e9 -->

However, when multisig addresses are being used, the attacker may be one
of the parties involved in generation of the address and so may be able
to manipulate what address is finally chosen.  For example, Bob sends
his pubkey to Mallory expecting that Mallory will send her pubkey back.
Then he expects they'll each put the pubkeys into a multisig script
template, hash it into an address, and someone will deposit money into
that address.

Mallory instead takes the script template and Bob's pubkey, inserts one
of her pubkeys without telling Bob about it, and hashes it into an
address.  This allows her to see the address Bob will accept before
Mallory has committed to using that pubkey.  Mallory can then compare
this address to a database of addresses generated from scripts that pay
only her.  If there's a match (collision) between two of the addresses,
she sends the pubkey back to Bob, waits for money to be deposited into
the address, and then uses the script from her database to steal the
money.  If there's not a match, Mallory can try again with a different
pubkey over and over until she succeeds (if we assume she has unlimited
time and resources).

Although this seems like the same brute force attack described earlier
with a 1-in-2<sup>160</sup> chance of success per attempt, we have to
consider the size of Mallory's database.  If we imagine the database has
100 addresses, then each different pubkey she tries has a
100-in-2<sup>160</sup> chance of success because it succeeds if it
matches any one of the addresses in Mallory's database.

This type of attack is called a [collision attack][].  There are several
algorithms with different CPU/memory tradeoffs for collision attacks,
but the general rule security researchers follow is that a collision
attack against a perfect hash function reduces its security to the
square root of its number of combinations, i.e. it halves its size in
bits.  That means we can roughly assume that RIPEMD160's security is
reduced to 80 bits---which is the same number of operations we mentioned
Bitcoin miners perform every 5 hours today using currently-existing
technology.  Again Bitcoin mining equipment can't be used for this
attack, and for an attacker to design and build enough custom equipment
to find a collision in five hours might cost them billions of
dollars---but it's a theoretically possible attack that should concern
those storing large values in P2SH, especially as custom hardware gets
faster and cheaper.  It's also possible that there are variations on the
collision attack that are easier and cheaper to execute because of
weaknesses in the RIPEMD160 function.

It is possible to design multisig setup protocols so that they don't
have this problem and so that their collision resistance remains at 160
bits.  However, the developers of segwit [believed][sipa collision
resistance] it was better to use a slightly longer hash function for
segwit's P2SH analog---P2WSH---so that users didn't need to worry about
these cryptographic particulars.  For that reason segwit P2WSH uses the
same SHA256d function used elsewhere in Bitcoin that provides 256-bit
security for single-party cases and 128-bit worst-case security in
multi-party use cases.  To to continue our rough comparison, if we
consider 80 bits to be equivalent to five hours of Bitcoin mining, 128
bits is equivalent to 160 billion years of mining.  <!-- 128-80=48,
2**48 * 5 / 24 / 365 / 1e9 -->

Before we conclude this section, we do want to ensure a few things are
clear:

1. We think it's unlikely that anyone today has the ability to execute
   the attack described (but we can't rule it out as a risk).

2. The attack can only be used at the time addresses are being
   created (although the actual theft could occur a long time
   afterwards).

3. The attack only applies to multi-party multisig addresses.  If you're
   a single party using P2SH multisig with only your own trusted devices
   or you're using P2SH-P2WPKH (single-sig addresses), there's no risk
   to you from this attack.

4. The attack applies to P2SH-wrapped segwit P2WSH addresses as well as
   regular P2SH addresses.  To eliminate the risk, you have to use
   native segwit (bech32) addresses or a secure key exchange protocol.

To summarize, users of multi-party multisig who want the utmost in
security should be migrating to bech32 P2WSH addresses to take advantage
of their extra collision resistance.  As users make that migration,
it'll become even more important for services to ensure they implement
bech32 sending support so that they can send payments to those
security-conscious users.

[bech32 fee savings]: /en/bech32-sending-support/#fee-savings-with-native-segwit
[sipa collision resistance]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2016-January/012205.html
[collision attack]: https://en.wikipedia.org/wiki/Collision_attack
