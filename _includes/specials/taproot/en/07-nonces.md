In [last week's column][p4tr multisignatures], we wrote about
[multisignatures][topic multisignature] and gave an example using
[MuSig2][topic musig].  Our description appears to have been technically
correct, but several cryptographers who contributed to MuSig2
[worried][secp256k1 log] that the way we suggested using it was
dangerous.  We [updated][optech #622] our description to address their
immediate concerns and then began researching the issue more thoroughly.
In this post, we'll look at what we learned may be the greatest
challenge for safely implementing multisignatures: avoiding nonce reuse.

To validate a signature in Bitcoin, you fill out a publicly known
equation with the signature, the message that was signed (e.g. a
transaction), your public key, and a public nonce.  It's only possible
for you to balance that equation if you know your private key and
the private form of the nonce.  Thus anyone seeing such a balanced
equation considers the signature for that message and public key to be
valid.

The motivation for including the signature and the message in the
equation is obvious.  The public key is a stand-in for your private
key.  What's the public nonce for?  If it wasn't there, every other
value in the equation except for your private key would be known,
meaning we could use basic algebra to solve for that single unknown
value.  But algebra can't solve for two unknown values, so the private
form of the nonce serves to keep your private key secret.  And, just as
your public key is a stand-in for your private key in the signature
equation, the public form of the nonce stands in for its private form.

Nonces in this context are not only *numbers used once* but numbers that
**must** only ever be used once.  If you reuse the same nonce with two
different signatures, the two signature equations can be combined, the
nonce can be canceled out, and someone can again solve for the only
remaining unknown value---your private key.  If you use [BIP32][]
standard derivation (non-hardened derivation), which likely nearly all
multisignature wallets will do, then the revelation of one private key
means the reveal of every other private key in the same BIP32 path (and
possibly in other paths as well).  That means a multisignature wallet
which has received bitcoins to a hundred different addresses will have
every one of those addresses compromised for the signer who reuses even
a single nonce.

Single-sig wallets, or those using script-based multisig, can use a
simple trick to avoid reusing nonces: they make their nonce dependent on
the message they're signing.  If there's any change to the message, the
nonce changes, and so they never reuse a nonce.

Multisignatures can't use this trick.  They require each cosigner
contribute not just a partial signature but also a partial public nonce.
The partial public nonces are combined together to produce an aggregated
public nonce which is included with the message to sign.

That means it's not safe to use the same partial nonce more than once
even if the transaction stays the same.  If, the second time you sign, one
of your cosigners changed their partial nonce (changing the aggregated
nonce), your second partial signature will effectively be for a
different message.  That reveals your private key.
Since it's impossibly circular for every party to make their
private nonce dependent on all the other party's partial public nonces,
there's no simple trick to avoid nonce reuse in multisignatures.

At first glance, this doesn't seem like a big problem.  Just have
signers generate a new random nonce each time they need to sign
something.  This is harder to get right than it sounds---since at least
[2012][tcatm post], people have been finding bitcoin-losing bugs in
wallets that depended on generating random nonces.

But even if a wallet does generate high-quality random nonces, it has to
ensure each nonce is only used a maximum of a single time.  That can be
a real challenge.  In the original version of our column last week, we
described a MuSig2-compatible cold wallet or hardware signing device
that would create a large number of nonces on its first run.  The wallet
or device would then need to ensure each of those nonces was never used
with more than one partial signature.  Although that sounds
simple---just increment a counter each time a nonce is used---it can be
a real challenge when dealing with all the ways software and hardware
can fail by accident, not to mention how they can be affected by
external and possibly malicious intervention.

Perhaps the easiest way for a wallet to reduce its risk of nonce reuse
is to store nonces for as short a time as possible.  Our example from
last week suggested storing nonces for months or years, which not only
creates a lot of opportunity for something to go wrong but also requires
recording nonces to a persistent storage medium which may be backed up and
restored or otherwise put into an unexpected state.  An alternative way
to use MuSig2 would be to only create nonces on demand, such as when a
[PSBT][topic psbt] is received.  The nonces could be kept in volatile
memory for the short time they were needed and so be automatically
destroyed (made unreusable) in several cases of the unexpected
happening, such as a software crash or a loss of power.

Still, the cryptographers working on this problem seem very concerned
about the lack of foolproof way to prevent nonce reuse in the original
MuSig protocol (MuSig1) and MuSig2.  MuSig-DN (deterministic nonce) does
offer a solution, but it's complex and slow (an alpha implementation
takes almost a second to create a nonce proof on a 2.9 GHz Intel i7;
it's unknown to us how long that might take on a 16 MHz hardware signing
device with a much less sophisticated processor).

Our advice to anyone implementing multisignature signing is to consider
stopping by the [#secp256k1][] IRC room or another place where Bitcoin
cryptographers congregate and describe your plans before you make any
major investments of time or resources.

[secp256k1 log]: https://gnusha.org/secp256k1/2021-08-04.log
[tcatm post]: https://web.archive.org/web/20160308014317/http://www.nilsschneider.net/2013/01/28/recovering-bitcoin-private-keys.html
[#secp256k1]: https://web.libera.chat/?channels=#secp256k1
[p4tr multisignatures]: /en/preparing-for-taproot/#multisignature-overview
[optech #622]: https://github.com/bitcoinops/bitcoinops.github.io/pull/622
