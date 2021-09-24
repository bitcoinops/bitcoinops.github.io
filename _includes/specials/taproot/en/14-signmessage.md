Since the activation of segwit over four years ago, there's been no
widely accepted way to create signed text messages for [bech32 or
bech32m][topic bech32] addresses.  Arguably, that means we can now
assume that widespread message signing support must not be very
important to users or developers, otherwise more work would've been
dedicated to it.  But it still feels like Bitcoin wallet software has
regressed since the days when everyone used legacy addresses and could
easily trade signed messages.

The [generic signmessage][topic generic signmessage] solution we wrote
about two years ago in our [bech32 spending support][bech32ss signmessage]
series has floundered, not even being adopted by Bitcoin Core despite
occasional updates of its protocol documentation, [BIP322][] (see
Newsletters [#118][news118 virttx] and [#130][news130 inconclusive]).
Despite that, we're unaware of any better alternative, and so BIP322
should still be the preferred choice of any developer who wants to add
signmessage support to their P2TR wallet.

If implemented, generic signmessage will allow signing messages for P2TR
outputs that are truly single-sig, which use [multisignatures][topic
multisignature], or which use any [tapscript][topic tapscript].  It will
also provide backwards compatibility with all legacy and bech32 addresses
as well as forward compatibility with the types of changes currently
envisioned for the near future (some of which we'll preview in a future
*preparing for taproot* column).  Applications with access to the full
UTXO set (e.g.  via a full node) can also use BIP322 to generate and
validate [reserve proofs][bip322 reserve proofs], providing evidence
that the signer controlled a certain amount of bitcoin at a certain time.

It should be very easy to implement support for creating generic signed
messages.  BIP322 uses a technique called *virtual transactions*.  A
first virtual transaction is created to be deliberately invalid by
attempting to spend from a non-existent previous transaction (one whose
txid is all zeroes). This first transaction pays the address (script)
the user wants to sign for and contains a hash commitment to the desired
message. A second transaction spends the output of the first
transaction---if the signatures and other data for that spend could be a
valid transaction, then the message is considered signed (although the
second virtual transaction still can’t be included onchain because it
spends from an invalid previous transaction).

Verifying generic signed messages is harder for many wallets.  To be
able to fully verify *any* BIP322 message requires implementing
essentially all of Bitcoin's consensus rules.  Most wallets don't do
that, so BIP322 allows them to return an "inconclusive" state when they
can't fully verify a script.  In practice, and especially with taproot's
encouragement of keypath spends, that may be rare.  Any wallet that
implements just a few of the most popular script types will be able to
verify signed messages for over 99% of all UTXOs.

Generic signmessage support would be a useful addition to Bitcoin.
Although we can't ignore the lack of attention paid to it in the past
several years, we do encourage wallet developers reading this to
consider adding experimental support for it to your programs.  It's an
easy way to give users back a feature they've been missing for several
years now. If you are either a developer working on BIP322 or related reserve proof
implementation or a service provider that would find such features useful, feel
free to reach out to [info@bitcoinops.org][optech email] to coordinate efforts.

[reserve proofs]: https://github.com/bitcoin/bips/blob/master/bip-0322.mediawiki#full-proof-of-funds
[bech32ss signmessage]: /en/bech32-sending-support/#message-signing-support
[bip322 reserve proofs]: https://github.com/bitcoin/bips/blob/master/bip-0322.mediawiki#full-proof-of-funds
[news118 virttx]: /en/newsletters/2020/10/07/#alternative-to-bip322-generic-signmessage
[news130 inconclusive]: /en/newsletters/2021/01/06/#proposed-updates-to-generic-signmessage
