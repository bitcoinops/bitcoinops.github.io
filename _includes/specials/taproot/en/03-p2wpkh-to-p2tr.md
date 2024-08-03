{% auto_anchor %}
For wallets that already support receiving and spending v0 segwit P2WPKH
outputs, upgrading to v1 segwit P2TR for single-sig should be easy.
Here are the main steps:

- **Use a new BIP32 key derivation path:** you don't need to change your
  [BIP32][] Hierarchical Deterministic (HD) code and your users don't
  need to change their seeds.[^electrum-segwit]  However, you are
  strongly encouraged to use a new derivation path for your P2TR public
  keys (such as defined by [BIP86][]); if you don't do this, there's a
  [possible attack][bip340 alt signing] that can occur if you use the
  same keys with both ECDSA and [schnorr signatures][topic schnorr
  signatures].

- **Tweak your public key by its hash:** although technically not
  required for single-sig, especially when all your keys are derived
  from a randomly-chosen BIP32 seed, BIP341 [recommends][bip341 cite22]
  having your key commit to an unspendable scripthash tree.  This is as
  simple as using an Elliptic Curve addition operation that sums your
  public key with the curve point of that key's hash.  Advantages of
  complying with this recommendation are that you'll be able to use the
  same code if you later add scriptless [multisignature][topic
  multisignature] support or if you add support for [`tr()`
  descriptors][].

- **Create your addresses and monitor for them:** use [bech32m][topic
  bech32] to create your addresses.  Payments will be sent to the
  scriptPubKey `OP_1 <tweaked_pubkey>`.  You can scan for transactions
  paying the script using whatever method you use to scan for v0 segwit
  addresses like P2WPKH.

- **Creating a spending transaction:** all the non-witness fields for
  taproot are the same as for P2WPKH, so you don't need to worry about
  changes to the transaction serialization.

- **Create a signature message:** this is a commitment to the data from
  the spending transaction.  Most of the data is the same as what you
  sign for a P2WPKH transaction, but the order of the fields is
  [changed][BIP341 sigmsg] and a few extra things are signed.
  Implementing this is just a matter of serializing and hashing
  various data, so writing the code should be easy.

- **Sign a hash of the signature message:** there are different ways to
  create schnorr signatures.  The best is not to "roll your own crypto"
  but instead to use the function from a well-reviewed library you
  trust.  But if you can't do that for some reason, [BIP340][] provides
  an algorithm that should be straightforward to implement if you
  already have available the primitives for making ECDSA signatures.
  When you have your signature, put it in the witness data for your
  input and send your spending transaction.

Even before taproot activates at block {{site.trb}}, you can test your
code using testnet, the public default [signet][topic signet], or Bitcoin Core's private
regtest mode.  If you add taproot support to your open source wallet, we
encourage you to add a link to the PR(s) implementing it on the [taproot
uses][wiki taproot uses] and [bech32m adoption][wiki bech32 adoption]
pages of the Bitcoin Wiki so other developers can learn from your code.

[^electrum-segwit]:
    When Electrum upgraded to segwit v0, it required anyone who wanted
    to receive to bech32 addresses generate new seeds.  This was not
    technically required but it allowed the authors of Electrum to
    introduce some new [features][electrum seeds] into their custom seed
    derivation method.  One of those features was ability for a seed
    version number to specify which scripts a seed is meant to be used
    with.  This allows safe deprecation of old scripts (e.g., a future a
    version of Electrum may be released that no longer supports
    receiving to legacy P2PKH addresses).

    Around the same time the Electrum developers were deploying their
    versioned seeds, Bitcoin Core developers began using [output script
    descriptors][topic descriptors] to solve the same problem of
    allowing script deprecation (in addition to solving other problems).
    The following table compares Electrum's versioned seeds and Bitcoin
    Core's descriptors to the *implicit scripts* method previously used
    by both wallets and still in common use among most other wallets.

    <table>
    <tr>
    <th>Script management</th>
    <th>Initial backup</th>
    <th>Introducing new scripts</th>
    <th>Scanning (bandwidth/CPU cost)</th>
    <th>Deprecating scripts</th>
    </tr>

    <tr>
    <th markdown="1">

    Implicit scripts (e.g. [BIP44][])

    </th>
    <td>Seed words</td>
    <td>Automatic (no user action required)</td>
    <td>Must scan for all supported scripts, O(n)</td>
    <td>No way to warn users that they're using unsupported scripts</td>
    </tr>

    <tr>
    <th>Explicit scripts (versioned seeds)</th>
    <td>Seed words (includes version bits)</td>
    <td>User must backup new seed; funds are either partitioned into two
    separate wallets or user must send funds from the old wallet to the new</td>
    <td>Only scans for a single script template, O(1)</td>
    <td>Users warned about unsupported scripts</td>
    </tr>

    <tr>
    <th markdown="1">

    Explicit scripts ([descriptors][topic descriptors])

    </th>
    <td>Seed words and descriptor</td>
    <td>User must back up the new descriptor</td>
    <td>Only scans for the script templates that were actually used, O(n); n=1 for a new wallet</td>
    <td>Users warned about unsupported scripts</td>
    </tr>
    </table>

{% include linkers/issues.md issues="" %}
[electrum seeds]: https://electrum.readthedocs.io/en/latest/seedphrase.html#motivation
[bip340 alt signing]: https://github.com/bitcoin/bips/blob/master/bip-0340.mediawiki#alternative-signing
[bip341 cite22]: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki#cite_note-22
[`tr()` descriptors]: /en/preparing-for-taproot/#taproot-descriptors
[bip341 sigmsg]: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki#common-signature-message
[wiki bech32 adoption]: https://en.bitcoin.it/wiki/Bech32_adoption
[wiki taproot uses]: https://en.bitcoin.it/wiki/Taproot_Uses
{% endauto_anchor %}
