{:.post-meta}
*by [Philip Glazman][], Engineer at [River Financial][]*

*River Financial​ is a challenger financial institution specializing in Bitcoin
financial services. River Financial’s flagship product, a Bitcoin brokerage,
provides retail investors with a high-touch platform to buy and sell Bitcoin.*

River Financial leverages two technologies in its wallet software: [Partially
Signed Bitcoin Transactions (PSBTs)][topic psbt] and [Output Script
Descriptors][topic descriptors]. The decision to incorporate these standards has
introduced greater flexibility and interoperability in River’s wallet operations.

The decision to bring PSBTs into the wallet stack was influenced by the concept
of treating key signers as interfaces. PSBT is a format for signers described in
[BIP174][] authored by Andrew Chow. Before this standard, there had been no
standardized format to describe an unsigned transaction. As a consequence, each
signer used vendor-specific formats which could not interoperate. By conforming
to the PSBT standard, the wallet infrastructure can avoid vendor lock-in, reduce
the attack surface in the signer logic, and have better guarantees about the
transaction being created by the wallet. The standard has also made
multisignature scripts safer to use, therefore significantly improving security
without a notable increase in operational expense.

The decision to implement Output Script Descriptors in the wallet software has
greatly reduced the complexity in wallet operations and has improved flexibility
in the feature set. Descriptors is a language for describing scripts that was
authored by Pieter Wuille and used in Bitcoin Core. In River’s wallet software,
the descriptor language is leveraged in several places from wallet creation to
address generation. Before descriptors, there had been no interoperable way for
wallets to import useful information about the scripts they used. By using
script descriptors, River’s wallet is able to reduce the necessary information
needed to start watching a script, address, or set of keys. Each wallet within
the wallet software has an associated descriptor with which scripts can be
created. This has two immediate benefits:

1. **The wallet software is able to watch cold wallets using descriptors and
   subsequently derive new addresses.** In our flagship brokerage product, River
   clients can create fresh deposit addresses to deposit Bitcoin directly to a
   secure cold multisignature wallet.
2. **Creating and importing new wallets is easy because the descriptor language
   is able to define desired scripts.** River is able to maintain many wallets
   with different scripts and as a result have separate security models for each
   wallet. A P2WSH multi-signature descriptor is used for the cold wallet and a
   P2WPKH descriptor for the hot (client withdrawal) wallet. Separate wallets
   allow River to keep the absolute minimum Bitcoin in the hot wallet (to
   minimize risk) and better manage the UTXO pool to service withdrawals.

The decision to use both descriptors and the PSBT standard has so far been
rewarding because of the flexibility and interoperability. This foundation will
help River Financial scale its wallet infrastructure.

{% include references.md %}
[Philip Glazman]: https://github.com/philipglazman
[River Financial]: https://river.com/
[topic psbt]: /en/topics/psbt/
[topic descriptors]: /en/topics/output-script-descriptors/
