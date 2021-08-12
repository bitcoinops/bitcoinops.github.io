---
title: 'Bitcoin Optech Newsletter #102'
permalink: /en/newsletters/2020/06/17/
name: 2020-06-17-newsletter
slug: 2020-06-17-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes the CoinPool payment pool proposal and
the WabiSabi coordinated coinjoin protocol.  Also included are our
regular sections with notable changes to services, client software, and
infrastructure software.

## Action items

*None this week.*

## News

- **CoinPool generalized privacy for identifiable onchain protocols:**
  Antoine Riard and Gleb Naumenko [posted][coinpool post] to the
  Bitcoin-Dev mailing list about payment pools, a technique for
  improving privacy against third-party block chain surveillance by
  allowing several users to trustlessly share control over a single
  UTXO.  Compared to previous designs for payment pools (such as
  [joinpool][]), the CoinPool design focuses on allowing participants to
  make offchain commitments to transactions between the members of the
  pool.  Using [taproot][topic taproot], this allows the cooperating
  participants to operate protocols such as LN or [vaults][topic vaults]
  using UTXOs that are indistinguishable from single-key UTXOs,
  improving both participant privacy and onchain scalability.  In that
  sense, the protocol acts as a sort of generalized [channel
  factory][topic channel factories] that applies not just to LN but to
  many protocols that create onchain transactions with unique
  fingerprints.

    The authors outline how CoinPool could work using existing features
    of Bitcoin plus taproot, [SIGHASH_NOINPUT][topic sighash_anyprevout], and the ability to use
    a delete-only accumulator via Bitcoin Script (e.g. a merkle tree;
    perhaps something like the proposed [BIP116][]
    `OP_MERKLEBRANCHVERIFY`).  They don't appear to be advocating a
    specific design but instead want to start a discussion about how
    CoinPool or something like it could provide a generalized mechanism
    that wallets use by default to eliminate the onchain footprint of
    various current and proposed multi-user protocols.

- **WabiSabi coordinated coinjoins with arbitrary output values:** in
  the [coinjoin][topic coinjoin] protocol, a group of users
  collaboratively create a transaction template that spends some of
  their existing UTXOs (inputs) to a new set of UTXOs (outputs).  The
  way this transaction template is created has implications for the
  privacy provided by the coinjoin, and different implementations
  use different methods:

    <!-- Taker creates tx template, see discussion between harding and
    waxwing: http://gnusha.org/joinmarket/2020-06-14.log -->

    - [Joinmarket][] has two types of users: those who pay to coinjoin
      (*market takers*) and those who are paid for allowing their UTXOs to
      be used (*market makers*).  To create a coinjoin, takers
      contact several makers, collect their input and output
      information, and create the transaction template.  This gives the
      taker knowledge of which inputs fund which outputs for all
      participants in the coinjoin, but it also ensures that each maker
      only has knowledge about which of their own inputs funds which of
      their own outputs.  The taker directly gains the privacy benefits of
      the coinjoin and the makers directly gain income for providing
      liquidity.  If the taker preserves their own individual privacy, the makers
      also indirectly gain increased privacy against third party block
      chain surveillance.  Makers who want guarantees about their privacy
      can always operate as takers for a few rounds of mixing.

        <!-- Quotes from joinmarket README.md:
          - "Ability to spend directly, or with coinjoin"
          - "Can specify exact amount of coinjoin (figures from 0.01 to 30.0 btc"
        -->

        This model gives takers a lot of flexibility with their own
        inputs and outputs to the transaction template.  For example, a
        taker can choose the amounts of the coinjoin they want to create
        or can spend their money to a third party as part of a coinjoin.

    - [Wasabi][] uses a centralized coordinator who organizes every
      coinjoin made using that software.  To prevent that coordinator
      from learning which inputs fund which outputs, users anonymously
      commit to the outputs they want to create, receiving a [chaumian
      blinded signature][] over the commitment.  Later, each user connects
      under another anonymous identity and submits each output along with
      its unblinded signature.  The signature provably came from the coordinator
      but the unblinded signature can't be connected to the specific
      user who received the blinded signature.  This allows constructing the
      transaction template without the coordinator learning which inputs
      funded which outputs.

        Because the coordinator is unable to view the output at the time
        it creates its blinded signature, it can't allow a user to
        specify an arbitrary amount or the user could attempt to receive
        more money than they contributed to the coinjoin.  This isn't a
        security risk---the other participants will refuse to sign any
        malformed transaction---but such a failure requires restarting
        the protocol.  If arbitrary amounts were allowed, the blinding
        would prevent identification of the lying user and make it
        impossible to ban them from future rounds, allowing an unlimited
        DoS of the protocol.  Instead, Wasabi requires that all outputs
        either belong to a small set of allowed sizes (e.g. 0.1 BTC, 0.2
        BTC, 0.4 BTC, etc) or be an unblinded change output.  This
        limits the ability to use Wasabi with user-specified amounts or
        for making payments with arbitrary amounts.

    This week, several contributors to Wasabi [posted][wabisabi post]
    to the Bitcoin-Dev mailing list about a new
    protocol they call WabiSabi that conceptually extends their existing protocol
    with a technique adapted from [confidential transactions][].  This allows a
    client to create a commitment to arbitrary output amounts and---without
    revealing the amounts---prove that each amount is individually
    within a specified range (e.g. 0.0001 BTC to 21 million BTC) and
    that they collectively sum to a specified value.  The coordinator
    uses this specified value to verify that the sum of the outputs the
    client wants to create is equal to the sum of the inputs provided by
    the client (minus fees).  The coordinator can then provide an
    anonymous credential for each output that allows the
    client to later anonymously submit the output to the
    coordinator for inclusion in the transaction template.

    Software that implements the protocol will be able to create
    coordinated coinjoins that
    allow the clients to select their output amounts, facilitating
    experiments with non-equal value coinjoins (see [Newsletter
    #79][news79 unequal coinjoin]) and payments made within a coinjoin
    (either to third parties not participating in the coinjoin or to
    parties within a coinjoin).

    The proposed protocol contains a significant number of differences
    from Wasabi's current protocol (such as replacing blind signatures
    with keyed-verification anonymous credentials), so its authors are
    seeking review, criticism, and suggestions about how the protocol
    can be used most effectively.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Caravan adds HD wallet support, coin control, and hardware wallet test suite:**
  In addition to single address multisig coordination, Caravan now supports HD
  wallet multisig coordination and coin control features. Unchained Capital, the creators of Caravan,
  also [announced][unchained caravan blog] a test suite for testing hardware
  wallet interactions within a web browser and Trezor multisig address confirmation.

- **Bitpay's Copay and Bitcore projects support native segwit:**
  Bitpay's [Copay wallet][copay segwit] and backend [Bitcore service][bitcore
  segwit] both now support receiving to, and spending from, native segwit outputs.

- **Desktop version of Blockstream Green wallet:**
  Blockstream has released their [Green wallet for desktop][blockstream green desktop blog]
  on macOS, Windows, and Linux. The desktop version supports 2-of-3 and 2-of-2
  multisig wallets as well as Tor and testnet.

- **React native library photon-lib announced:** [Tankred Hase
  shared][photon-lib tweet] a new library, [photon-lib][] for building Bitcoin
  wallet features using React Native. The library supports HD wallets and light client
  functionality but is still under development and not yet production ready.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1 repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

- [BIPs #910][] Assigns [BIP85][] to Ethan Kosakovsky's Deterministic Entropy From
  BIP32 Keychains proposal. BIP85 describes a super-keychain whose child keys
  can be used to create traditional HD keychain seeds. See [Newsletter #93][news93 bip32 keychains]
  for more details on this proposal.

{% include references.md %}
{% include linkers/issues.md issues="910" %}
[coinpool post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-June/017964.html
[joinpool]: https://gist.github.com/harding/a30864d0315a0cebd7de3732f5bd88f0
[joinmarket]: https://github.com/JoinMarket-Org/joinmarket-clientserver
[wasabi]: https://wasabiwallet.io/
[wabisabi post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-June/017969.html
[news79 unequal coinjoin]: /en/newsletters/2020/01/08/#coinjoins-without-equal-value-inputs-or-outputs
[chaumian blinded signature]: https://en.wikipedia.org/wiki/Blind_signature
[confidential transactions]: https://en.bitcoin.it/wiki/Confidential_transactions
[news93 bip32 keychains]: /en/newsletters/2020/04/15/#proposal-for-using-one-bip32-keychain-to-seed-multiple-child-keychains
[unchained caravan blog]: https://unchained-capital.com/blog/gearing-up-the-caravan/
[blockstream green desktop blog]: https://blockstream.com/2020/05/21/en-blockstream-green-now-on-desktop/
[photon-lib tweet]: https://twitter.com/tankredhase/status/1265640624973246465
[photon-lib]: https://github.com/photon-sdk/photon-lib
[copay segwit]: https://github.com/bitpay/copay/pull/10766
[bitcore segwit]: https://github.com/bitpay/bitcore/pull/2418
