{% auto_anchor %}
*The following case study contributed by Optech member company [BRD][]
describes what they learned implementing bech32 and other segwit
technology for their wallet.*

We began implementing bech32 support in BRD wallet in January 2018 with the
[addition of bech32 decoding and encoding support][brd pr1] to
[breadwallet-core][], an MIT-licensed cross-platform C library
with no external dependencies.  All of our software avoids
third-party library dependencies as much as possible, with it currently
using only Pieter Wuille's [libsecp256k1][].  Minimizing dependencies is
typical for a high-security crypto project. For the bech32
implementation, we found that bech32's [BIP173][] is pretty well
documented, so there were no specific issues that were complex to
deal with.

In March 2018, breadwallet-core was [updated][brd pr2] to automatically parse
anything provided as a Bitcoin address to determine whether it was a
legacy P2PKH, legacy P2SH, or segwit bech32 and to automatically
generate the appropriate scriptPubKey in each case.  This allowed BRD to
begin sending to bech32 addresses.  Finally in October 2018, we
implemented full segwit support across the library backend and mobile
app frontends, allowing users to begin receiving to bech32 addresses and
making the default that all change addresses were now bech32.

One thing we never implemented was support for receiving to
P2SH-wrapped segwit addresses, instead going straight to bech32.  This
was a deliberate design optimization to make the best use of the bloom
filter mechanism BRD uses to scan for transactions affecting user
wallets.  To allow users to track when they've been paid, bloom filters
are matched against each data element in a scriptPubKey.  For a given
public key, the data element in the scriptPubKey is identical for both
legacy P2PKH and native segwit (bech32) P2WPKH.  Here's an example
[previously used][identical spk data] by Optech:

- Legacy P2PKH scriptPubKey for address 1B6FkNg199ZbPJWG5zjEiDekrCc2P7MVyC:

  <pre>OP_DUP OP_HASH160 OP_PUSH20 <b>6eafa604a503a0bb445ad1f6daa80f162b5605d6</b> OP_EQUALVERIFY OP_CHECKSIG</pre>

- Native segwit (bech32) P2WPKH scriptPubKey for address bc1qd6h6vp99qwstk3z668md42q0zc44vpwkk824zh:

  <pre>OP_0 OP_PUSH20 <b>6eafa604a503a0bb445ad1f6daa80f162b5605d6</b></pre>

Because a bloom filter for a given element will match both P2PKH and
P2WPKH addresses for the same public key, BRD is able to scan for either
type of payment with zero additional overhead.  It also makes the
implementation much cleaner and doesn't increase the resource use of
public nodes that serve bloom filters.  This may be a worthwhile
optimization for wallets and services using other types of scanning as
well, as it may produce less overhead than the separate HD derivation
path recommended by [BIP84][].

ScriptPubKeys generated from bech32 addresses vary in length, affecting
the amount of transaction fee that needs to be paid.
Fee calculation on Bitcoin is hideous---feerates spike multiple
orders of magnitude in a 24 hour period sometimes---but that was already
true before segwit so we previously spent a lot of time on fee
calculation and made it as flexible as possible.  That means
the variability in size of scriptPubKeys
generated from bech32 addresses doesn't change anything for BRD.

We want today's app to be future-proof so the code supports
sending to future segwit versions (see [Optech's description][bech32
future]).  That means, for example, BRD will support paying to
[taproot][bip-taproot] addresses automatically if Bitcoin users choose
to make that soft fork change to the consensus rules.

Once real momentum is established and most other wallets and services
support sending to bech32 addresses, BRD's bech32 receiving support will
be rolled out to our entire user base as the default setting.  In
preparation of this transition, it is important to get as many companies
and services as possible to voluntarily start supporting bech32 sending
capability.  To help encourage adoption, we created the [WhenSegwit][]
website and became a member company of Optech.  We hope that other wallets
and services will make their own transitions to full segwit support soon while
fees are still relatively low.

[BRD]: https://brd.com/
[brd pr1]: https://github.com/breadwallet/breadwallet-core/commit/2b17fe44619442c31f8a47c175f84b8992933346
[brd pr2]: https://github.com/breadwallet/breadwallet-core/commit/fd0abb92b07e41429e1170fb56716965cc7b64ab
[breadwallet-core]: https://github.com/breadwallet/breadwallet-core/
[identical spk data]: /en/bech32-sending-support/#sending-to-a-legacy-address
[bech32 future]: /en/bech32-sending-support/#automatic-bech32-support-for-future-soft-forks
[whensegwit]: https://whensegwit.com/
{% endauto_anchor %}
