---
title: 'Bitcoin Optech Newsletter #34'
permalink: /en/newsletters/2019/02/19/
name: 2019-02-19-newsletter
slug: 2019-02-19-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a discussion about output tagging for
BIP118 SIGHASH_NOINPUT_UNSAFE, announces merges that will make it
possible to pair Bitcoin Core's built-in wallet in watching-only mode
with a hardware wallet, and describes the completion of the feature
freeze for the next Bitcoin Core release.  Also summarized are numerous
code and documentation changes in popular Bitcoin infrastructure
projects.

## Action items

None this week.

## News

- **Discussion about tagging outputs to enable restricted features on
  spending:** The [BIP118][] SIGHASH_NOINPUT_UNSAFE (noinput) proposal
  allows the person generating a signature that authorizes the spend of
  one UTXO to optionally allow that signature to be reused ("replayed")
  for spending other UTXOs sent to the same public key.  This enables
  new features when used with protocols such as payment channels that all
  contain the same public keys (see the proposed [Eltoo][] layer for
  LN), but it also makes possible *replay attacks* that can result in a
  loss of money when users reuse addresses.  For example:
  Alice uses a coin she previously received to one of her
  addresses and signs a spend to Bob using SIGHASH_NOINPUT_UNSAFE.
  Later someone else pays money to that same address of Alice's
  intending to send her some more money.  Bob (or anyone else) can
  now send that output to Bob
  by replaying Alice's earlier
  signature.

    One way to help avoid such accidents is simply by appending "UNSAFE" to
    the name of the feature, encouraging developers to learn about the
    protocol's nuances before they implement it in their tools.
    However, some developers have been looking for additional ways to
    prevent problems.  In December, Johnson Lau [proposed][lau output
    tagging] only allowing noinput to be used if the output being spent
    had been specially tagged at its creation to allow the use of
    noinput.  This would only allow the feature to be used when both the
    spender and receiver agreed (as in the case of a payment channel),
    preventing any miscommunications or misunderstandings from ending in
    loss of funds.

    Renewed discussion [last week][nick output tagging] and this week
    saw analysis of the impact this would have on proposed layer two
    protocols such as Eltoo and [Channel Factories][].  Although tagging
    increases complexity, the general opinion seems
    to be that it doesn't fundamentally increase the cost or reduce the
    effectiveness of the described proposals, although it could make
    them a bit less private.

- **Bitcoin Core preliminary hardware wallet support:** after months of
  incremental improvements, this week saw the merge of the final set of
  PRs needed for Bitcoin Core's master development branch to support
  receiving and sending transactions in conjunction with a hardware
  wallet via the [Hardware Wallet Interaction][HWI] (HWI) tool.  HWI is
  part of the Bitcoin Core project, but is not yet distributed with the
  Bitcoin Core software and is currently only accessible from the command
  line. It provides a solid
  foundation upon which to build tools that can make it easy to use an
  external keystore with Bitcoin Core's native wallet and full
  verification node.  Note also that it is already possible to
  connect a hardware wallet to an Electrum wallet connected to your full
  node using [Electrum Personal Server][].

    Organizations using advanced security techniques such as Hardware
    Security Modules (HSMs), cold wallets, and multisig may want to
    investigate the design of HWI and how it interacts with Bitcoin Core
    using [output script descriptors][descriptor] and [BIP174][] PSBTs.
    These next-generation encodings of key and transaction data (and
    metadata), along with other advances such as the [miniscript][]
    policy language, make it easier than ever to build and operate
    secure bitcoin storage solutions that interact with a full node for
    verification.

- **Bitcoin Core freeze week:** as [scheduled][Bitcoin Core #14438],
  the project has stopped accepting features for the upcoming release of
  major version 0.18.  As often happens, this was preceded by a week or
  so of active last-minute review and merging of new features, which is
  reflected in the long list of changes in this week's *notable changes*
  section below.  The next two weeks will focus on developer testing and
  bug fixes, followed by the issuance of Release Candidates (RCs) for
  user testing.  The RC cycle for a major release usually lasts two to
  four weeks before a final release.

    Related, the project prefers to merge major new features early in a
    new development cycle so that they get as much additional developer testing
    as possible.  After the 0.18 branch is created around March
    1st, anyone who wants to see a feature in 0.19 (estimated release
    October 2019) would be advised to either try to open a PR for it
    within the next two months or to assist in reviewing an existing PR
    for that feature.  Some notable existing PRs that need more review
    or development include support for BIP156 Dandelion
    [privacy-enhanced transaction relay][Bitcoin Core #13947], BIP151
    [encrypted P2P connections][Bitcoin Core #14032], BIP157/158
    [compact block filters][Bitcoin Core #14121], simplified
    [reproducible builds][Bitcoin Core #15277] using GNU Guix, improved
    support for [external signers][Bitcoin Core #14912] (e.g. hardware
    wallets), [separating the wallet from the node][Bitcoin Core
    #10973], and allowing [RBF on any transaction][Bitcoin Core #10823]
    after it's been in the mempool for more than a few hours.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],
[libsecp256k1][libsecp256k1 repo], and [Bitcoin Improvement Proposals
(BIPs)][bips repo].*

- [Bitcoin Core #15368][] adds support for checksums to output script
  descriptors.  [Descriptors][descriptor] are used to monitor for
  received payments and generate new addresses, so checksums improve
  safety by preventing copying errors that could cause money to go
  missing or be sent to an unspendable address.  A `#` character is
  added to the descriptor grammar for separating the descriptor from its
  8-character checksum, e.g.  `wpkh(031234...cdef)#012345678` (see
  footnote[^fn-example] for an extended example). All Bitcoin Core RPCs
  that return descriptors now include a checksum.  RPCs that aren't
  particularly at risk of losing money don't require that input include
  the checksum, but RPCs that are safety critical, such as
  `deriveaddress` and `importmulti`, are updated to require users
  provide the checksum.  Finally, a new `getdescriptorinfo` RPC is added
  that accepts a descriptor and returns a normalized form of it
  containing a checksum along with some other information about it.

- [Bitcoin Core #13932][] adds three new RPCs for managing PSBTs:
  `utxoupdatepsbt` searches the set of Unspent Transaction Outputs
  (UTXOs) to find the outputs being spent by the partial transaction.
  If any of those outputs paid a native segwit address, it adds the
  details of that output to a field in the PSBT.  This information is
  required by PSBT signers because the [BIP143][] signature format for
  segwit requires the signing of information that is not
  directly contained in the spending transaction or derivable from the
  signer's private key, such as the value of the output being spent.
  `joinpsbts` combines the inputs from multiple PSBTs into a single
  PSBT.  `analyzepsbt` examines a PSBT and prints the next step the user
  needs to take towards finalizing it.

- [Bitcoin Core #14075][] adds a `keypool` parameter to the
  `importmulti` RPC that allows imported public keys to be added to the
  keypool---the list of keys that are used to create new receiving and
  change addresses.  The option is only available for wallets that have
  private keys disabled (see [PR#9662][Bitcoin Core #9662] described in
  [Newsletter #5][]).  This allows a user of a cold wallet or a hardware
  wallet to import their public keys into a watching-only Bitcoin Core
  wallet and then receive payments normally.  When attempting to spend
  payments, the wallet can generate an unsigned transaction---including
  a change address---using a [BIP174][] PSBT and send that to a tool
  such as [HWI][] that will connect to the external wallet for review
  and signing.

- [Bitcoin Core #14021][] changes the `importmulti` RPC to store any key
  origin metadata included as part of an [output script
  descriptor][descriptor].  The [key origin information][] specifies what HD
  seed and derivation path was used to generate a public key.  When key
  origin metadata is available in the wallet, any PSBTs generated by the
  wallet will include that data to allow hardware wallets or other
  programs to locate the private keys needed to sign the PSBT.
  See the footnote[^fn-example] for an example of key origin information
  in a descriptor.

- [Bitcoin Core #14481][] updates the `listunspent`,
  `signrawtransactionwithkey`, and `signrawtransactionwithwallet` RPCs
  to each contain a new `witnessScript` field.  The first RPC returns
  the witnessScript and the other two can accept it as input.
  Previously Bitcoin Core overloaded the existing P2SH `redeemScript`
  fields for segwit witnessScripts, but this can be especially confusing
  in the case of P2SH-wrapped segwit.  This change makes it clear what
  data goes where.

- [Bitcoin Core #15063][] allows the wallet to fallback on [BIP21][] parsing
  of a `bitcoin:` URI if [BIP70][] support has been disabled.  As
  specified by [BIP72][], the `bitcoin:` URI was extended in a
  backwards-compatible way to contain an additional `r=` parameter
  containing the BIP70 URL.  This was done to allow services already
  using BIP21 URIs to upgrade to supporting BIP70 without losing
  existing users.  However, now that many wallets are services are
  deprecating their BIP70 support, the same mechanism can be used in
  reverse so that services that previously supported BIP70 can allow
  their non-BIP70 users to continue to get payment details by just
  clicking on a `bitcoin:` link.

- [Bitcoin Core #15153][] adds a GUI menu to open a wallet and
  [#15195][Bitcoin Core #15195] adds a menu to close a wallet.  This
  makes it much easier to use Bitcoin Core's multiwallet mode from the
  GUI, although it's not yet possible to create a wallet from the GUI
  without using the debug console (that todo is the final item on the
  [dynamic wallet checklist][Bitcoin Core #13059]).

- [Eclair #862][] now supports payment requests (invoices) in all
  uppercase as well as all lowercase.  Mixed case is not permitted, as
  per the [BOLT11][] specification (which bases the invoice format on
  [BIP173][] bech32).

- [BIPs #760][] updates [BIP158][] compact block filters to add
  additional test vectors for correct processing of data carrier outputs
  (`OP_RETURN` outputs).

## Footnotes

[^fn-example]:
    An current example of the descriptor format with key origin
    information and an error-detecting checksum:

        $ bitcoin-cli getaddressinfo bc1qsksdpqqmsyk9654puz259y0r84afzkyqdfspvc | jq .desc
        "wpkh([f6bb4c63/0'/0'/21']034ed70f273611a3f21b205c9151836d6fa9051f74f6e6bbff67238c9ebc7d04f6)#mtdep7g7"

    Parsing this, we see the following:

    - The address is a Witness Public Key Hash `wpkh()`, otherwise known
      as P2WPKH.  Descriptors can succinctly describe all common uses of
      P2PKH, P2SH, P2WPKH, P2WSH, and nested segwit.

    - The [key origin][key origin information] is described between the square brackets `[]`.

        - `f6bb4c63` is a fingerprint that identifies the key at the
          root of the path provided.  The fingerprint is the first 32
          bits of its `ripemd(sha256())` hash as [defined by
          BIP32][bip32 keyid].  This makes it easy for tools, such as
          those used with PSBTs, to work with multisig scripts and other
          cases where you have multiple signing devices using different
          keys.

        - `/0'/0'/21'` is the HD key path, corresponding to
          `m/0'/0'/21'` in standard [BIP32][] notation.  This allows a
          wallet that doesn't have all of its public keys precomputed to
          know which private key it needs to generate in order to
          produce the signature.  (Bitcoin Core precomputes its public
          keys and so usually doesn't need this information when used as
          a cold wallet---but hardware wallets with minimal storage and
          computational speed need HD path information in order to work
          efficiently.)

    - The actual public key used to generate the P2WPKH key hash is
      `034ed7...04f6`

    - A checksum following a `#` protects the descriptor string against
      typos on import, `mtdep7g7`

{% include references.md %}
{% include linkers/issues.md issues="14438,13947,14032,14121,15277,14912,10973,10823,15368,13932,14075,9662,14021,14481,15063,15153,15195,13059,862,760" %}
[bip32 keyid]: https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#key-identifiers
[eltoo]: https://blockstream.com/eltoo.pdf
[lau output tagging]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-December/016549.html
[nick output tagging]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-February/016667.html
[channel factories]: https://www.tik.ee.ethz.ch/file/a20a865ce40d40c8f942cf206a7cba96/Scalable_Funding_Of_Blockchain_Micropayment_Networks%20(1).pdf
[electrum personal server]: https://github.com/chris-belcher/electrum-personal-server
[key origin information]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md#key-origin-identification
