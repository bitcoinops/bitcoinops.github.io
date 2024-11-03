---
title: 'Bitcoin Optech Newsletter #286'
permalink: /en/newsletters/2024/01/24/
name: 2024-01-24-newsletter
slug: 2024-01-24-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces a fixed consensus failure in older
versions of btcd, describes proposed changes to LN for v3 transaction
relay and ephemeral anchors, and announces a new repository for
Bitcoin-related specifications.  Also included are our regular sections
describing updates to services and client software, announcing new
releases and release candidates, and summarizing notable changes to
popular Bitcoin infrastructure software.

## News

- **Disclosure of fixed consensus failure in btcd:** Niklas Gögge
  used Delving Bitcoin to [announce][gogge btcd] a consensus failure in
  older versions of btcd that he had previously [responsibly
  disclosed][topic responsible disclosures].  Relative [timelocks][topic timelocks] were
  [added to Bitcoin][topic soft fork activation] in a soft fork by adding consensus-enforced meaning
  to transaction input sequence numbers.  To ensure any presigned
  transactions created before the fork would not be made invalid, the
  relative time locks only apply to transactions with version numbers 2
  and higher, allowing transactions with the original default of version
  1 to remain valid with any inputs.  However, in the original Bitcoin
  software, version numbers are signed integers, meaning negative
  versions are possible.  The _reference implementation_ section of
  [BIP68][] notes that "version 2 and
  higher" is meant to apply to the version number [cast][] from a signed
  integer into an unsigned integer, ensuring that the rules apply to any
  transaction that isn't version 0 or 1.

  Gögge discovered that btcd did not implement this conversion from
  signed to unsigned integers, so it was possible to construct a
  transaction with a negative version number which Bitcoin Core would
  require to follow the BIP68 rules but btcd would not.  In that case,
  one node could reject the transaction (and any block that contained
  it) and the other node could accept it (and its block), leading to a
  chain split.  An attacker could use this to trick the operator of a
  btcd node (or software connected to a btcd node) into accepting
  invalid bitcoins.

  The bug was privately disclosed to the btcd maintainers who fixed it
  in the recent v0.24.0 release.  Anyone using btcd for consensus
  enforcement is strongly urged to upgrade.  Additionally, Chris
  Stewart [replied][stewart bitcoin-s] to the Delving Bitcoin thread
  with a patch for the same failure in the bitcoin-s library.  Authors
  of any code that might be used to validate BIP68 relative locktimes
  are urged to check the code for the same flaw. {% assign timestamp="1:33" %}

- **Proposed changes to LN for v3 relay and ephemeral anchors:** Bastien
  Teinturier [posted][teinturier v3] to Delving Bitcoin to describe the
  changes he thinks should be made to the LN specification to make
  effective use of [v3 transaction relay][topic v3 transaction relay]
  and [ephemeral anchors][topic ephemeral anchors].  The changes appear
  simple:

  - *Anchor swap:* the commitment transaction's two current [anchor outputs][topic
    anchor outputs] used to guarantee the ability to [CPFP fee bump][topic cpfp]
    under the [CPFP carve out][topic cpfp carve out] policy are removed
    and one ephemeral anchor is added in their place.

  - *Reducing delays:* the extra 1-block delays on the commitment transaction are removed.
    They were added to ensure that CPFP carve out would always work but are
    not necessary under the v3 relay policy.

  - *Trimming redirect:* instead of spending the value of all [trimmed HTLCs][topic trimmed
    htlc] to fees in the commitment transaction, the combined value is
    added to the value of the anchor output, ensuring the extra fees are
    used to guarantee confirmation of both the commitment and the ephemeral anchor
    (see [last week's newsletter][news285 mev] for discussion).

  - *Other changes:* some other minor changes and simplifications are made.

  The subsequent discussion examined several interesting consequences of
  the proposed changes, including:

  - *Reduced UTXO requirements:* ensuring the correct channel state goes onchain becomes easier
    thanks to the removal of the extra 1-block delay.  If a faulty party
    broadcasts a revoked commitment transaction, the other party can use
    their main output from that commitment to CPFP fee bump that revoked
    commitment.  They don't need to keep a separate confirmed UTXO for
    that purpose.  For this to be safe, the party must keep a sufficient
    reserve balance, as the 1% minimum specified in [BOLT2][] may not be
    enough to cover fees.  For a non-forwarding node that keeps a
    sufficient reserve, the only time they need a separate UTXO for
    security reasons is when they want to accept an incoming payment.

  - *Imbued v3 logic:* In response to concerns voiced in the LN spec meeting that it may
    take a long time for LN to design, implement, and deploy these changes,
    Gregory Sanders [proposed][sanders transition] an
    intermediate stage with temporary special treatment of transactions
    that look like current anchors-style LN commitment transactions,
    allowing Bitcoin Core to deploy cluster mempool without being blocked by LN development.  When
    they've been widely deployed and all LN implementations have
    upgraded to using v3, the temporary special rules can be dropped.

  - *Request for max child size:* the draft proposal for v3 relay sets
    the size of an unconfirmed transaction's child to 1,000 vbytes.  The
    larger this size, the more an honest user will need to pay to
    overcome a [transaction pin][topic transaction pinning] (see
    [Newsletter #283][news283 v3pin]).  The smaller the size, the fewer
    inputs an honest user can use to contribute fees. {% assign timestamp="13:40" %}

- **New documentation repository:** Anthony Towns [posted][towns binana]
  to the Bitcoin-Dev mailing list to announce a new repository for
  protocol specifications, _Bitcoin Inquisition Numbers And Names
  Authority_ ([BINANA][binana repo]).  Four specifications are available
  in the repository at the time of writing: {% assign timestamp="29:56" %}

  - [BIN24-1][] `OP_CAT` by Ethan Heilman and Armin Sabouri.  See
    the description of their soft fork proposal in [Newsletter
    #274][news274 cat].

  - [BIN24-2][] Heretical Deployments by Anthony Towns, describing the
    use of [Bitcoin Inquisition][bitcoin inquisition repo] for
    proposed soft forks and other changes on the default [signet][topic signet].  See
    the extended description in [Newsletter #232][news232 inqui].

  - [BIN24-3][] `OP_CHECKSIGFROMSTACK` by Brandon Black, specifying
    this [long-proposed idea][topic OP_CHECKSIGFROMSTACK].  See [last
    week's newsletter][news285 lnhance] for Black's proposal to
    include this opcode as part of the LNHANCE soft fork bundle.

  - [BIN24-4][] `OP_INTERNALKEY` by Brandon Black, specifying an
    opcode for retrieving the taproot internal key from the script
    interpreter.  This was also described in last week's newsletter as
    part of the LNHANCE soft fork bundle.

  Bitcoin Optech has added the BINANA repository to the list of
  documentation sources we monitor for updates, which also includes
  BIPs, BOLTs, and BLIPs.  Future updates may be found in the section
  for _notable code and documentation changes_.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Envoy 1.5 released:**
  [Envoy 1.5][] adds support for [taproot][topic taproot] sending and receiving and
  changes the way [uneconomical outputs][topic uneconomical outputs] are
  handled in addition to bugfixes and [other updates][envoy blog]. {% assign timestamp="45:41" %}

- **Liana v4.0 released:**
  [Liana v4.0][] was [released][liana blog] and includes support for [RBF fee
  bumping][topic rbf], transaction canceling using RBF, automatic [coin
  selection][topic coin selection], and hardware signing device address
  verification. {% assign timestamp="46:39" %}

- **Mercury Layer announced:**
  [Mercury Layer][] is an [implementation][mercury layer github] of
  [statechains][topic statechains] that uses a [variation][mercury blind musig]
  of the [MuSig2][topic musig] protocol to achieve blinded signing by the
  statechain operator. {% assign timestamp="47:46" %}

- **AQUA wallet announced:**
  [AQUA wallet][] is an [open source][aqua github] mobile wallet that supports
  Bitcoin, Lightning, and the Liquid [sidechain][topic sidechains]. {% assign timestamp="57:18" %}

- **Samourai Wallet announces atomic swap feature:**
  The [cross-chain atomic swap][samourai gitlab swap] feature, based on previous
 [research][samourai gitlab comit], allows peer-to-peer coin swaps between the Bitcoin and Monero chains. {% assign timestamp="57:49" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LDK 0.0.120][] is a security release of this library for building
  LN-enabled applications.  It "fixes a denial-of-service vulnerability
  which is reachable from untrusted input from peers if the
  `UserConfig::manually_accept_inbound_channels` option is enabled."
  Several other bug fixes and minor improvements are also included. {% assign timestamp="58:37" %}

- [HWI 2.4.0-rc1][] is a release candidate for the next version of this
  package providing a common interface to multiple different hardware
  signing devices. {% assign timestamp="59:11" %}

## Notable code and documentation changes

*Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #29239][] updates the `addnode` RPC to connect using the
  [v2 transport protocol][topic v2 p2p transport] when the
  `-v2transport` configuration setting is enabled. {% assign timestamp="59:37" %}

- [Eclair #2810][] allows the onion-encrypted information for
  [trampoline routing][topic trampoline payments] to use more than 400
  bytes, with the maximum size now being the 1,300 byte maximum from
  [BOLT4][].  Trampoline routing that requires less than 400 bytes is
  padded to 400 bytes. {% assign timestamp="1:02:16" %}

- [LDK #2791][], [#2801][ldk #2801], and [#2812][ldk #2812] complete
  adding support for [route blinding][topic rv routing] and begins
  advertising the feature bit for it. {% assign timestamp="1:05:32" %}

- [Rust Bitcoin #2230][] adds a function for calculating the _effective
  value_ of an input, which is its value minus the cost to spend it. {% assign timestamp="1:07:43" %}

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29239,2810,2791,2801,2812,2230" %}
[teinturier v3]: https://delvingbitcoin.org/t/lightning-transactions-with-v3-and-ephemeral-anchors/418/
[towns binana]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2024-January/022289.html
[sanders transition]: https://delvingbitcoin.org/t/lightning-transactions-with-v3-and-ephemeral-anchors/418/2
[news283 v3pin]: /en/newsletters/2024/01/03/#v3-transaction-pinning-costs
[news274 cat]: /en/newsletters/2023/10/25/#proposed-bip-for-op-cat
[news232 inqui]: /en/newsletters/2023/01/04/#bitcoin-inquisition
[news285 mev]: /en/newsletters/2024/01/17/#discussion-of-miner-extractable-value-mev-in-non-zero-ephemeral-anchors
[news285 lnhance]: /en/newsletters/2024/01/17/#new-lnhance-combination-soft-fork-proposed
[stewart bitcoin-s]: https://delvingbitcoin.org/t/disclosure-btcd-consensus-bugs-due-to-usage-of-signed-transaction-version/455/2
[gogge btcd]: https://delvingbitcoin.org/t/disclosure-btcd-consensus-bugs-due-to-usage-of-signed-transaction-version/455
[hwi 2.4.0-rc1]: https://github.com/bitcoin-core/HWI/releases/tag/2.4.0-rc.1
[ldk 0.0.120]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.120
[cast]: https://en.wikipedia.org/wiki/Type_conversion#Explicit_type_conversion
[Envoy 1.5]: https://github.com/Foundation-Devices/envoy/releases/tag/v1.5.1
[envoy blog]: https://foundationdevices.com/2024/01/envoy-version-1-5-1-is-now-live/
[Liana v4.0]: https://github.com/wizardsardine/liana/releases/tag/v4.0
[liana blog]: https://www.wizardsardine.com/blog/liana-4.0-release/
[Mercury Layer]: https://mercurylayer.com/
[mercury blind musig]: https://github.com/commerceblock/mercurylayer/blob/dev/docs/blind_musig.md
[mercury layer github]: https://github.com/commerceblock/mercurylayer/tree/dev/docs
[AQUA Wallet]: https://aquawallet.io/
[aqua github]: https://github.com/AquaWallet/aqua-wallet
[samourai gitlab swap]: https://code.samourai.io/wallet/comit-swaps-java/-/blob/master/docs/SWAPS.md
[samourai gitlab comit]: https://code.samourai.io/wallet/comit-swaps-java/-/blob/master/docs/files/Atomic_Swaps_between_Bitcoin_and_Monero-COMIT.pdf
