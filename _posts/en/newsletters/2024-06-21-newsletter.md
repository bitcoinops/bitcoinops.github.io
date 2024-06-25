---
title: 'Bitcoin Optech Newsletter #308'
permalink: /en/newsletters/2024/06/21/
name: 2024-06-21-newsletter
slug: 2024-06-21-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces the disclosure of a vulnerability
affecting old versions of LND and summarizes continued discussion about
PSBTs for silent payments.  Also included are our regular sections
describing recent changes to services and client software, announcing
new releases and release candidates, and summarizing notable changes to
popular Bitcoin infrastructure software.

## News

- **Disclosure of vulnerability affecting old versions of LND:** Matt
  Morehouse [posted][morehouse onion] to Delving Bitcoin the disclosure of a
  vulnerability affecting versions of LND before 0.17.0.  LN relays
  payment instructions and [onion messages][topic onion messages] using
  onion-encrypted packets that contain multiple encrypted payloads.
  Each payload is prefixed by its length, which [since 2019][news58
  variable onions] has been [allowed][bolt4] to be any size up to 1,300
  bytes for payments.  Onion messages, which were introduced later, may
  be up to 32,768 bytes.  However, the payload size prefix uses a data
  type that allows indicating a size up to 2<sup>64</sup> bytes.

  LND accepted a payload's indicated size up to 4 gigabytes and would
  allocate that amount of memory before further processing the payload.
  This is enough to exhaust the memory of some LND nodes, resulting in them
  crashing or being terminated by the operating system, and it could be
  used to crash nodes that have more memory by sending multiple onion
  packets constructed this way.  A crashed LN node cannot send
  time-sensitive transactions that may be necessary to protect its funds,
  potentially leading to funds being stolen.

  The vulnerability was fixed by reducing the maximum memory allocation
  to 65,536 bytes.

  Anyone operating an LND node should upgrade to version 0.17.0 or
  above.  Upgrading to the latest version (0.18.0 at the time of
  writing) is always recommended. {% assign timestamp="0:54" %}

- **Continued discussion of PSBTs for silent payments:** several
  developers have been discussing adding support for coordinating the
  sending of [silent payments][topic silent payments] using [PSBTs][topic
  psbt].  Since our [previous summary][news304 sp-psbt], the discussion has
  focused on using a technique where each signer generates an _ECDH
  share_ and a compact proof that they generated their share correctly.
  These are added to the input section of the PSBT.  When shares from
  all signers are received, they are combined with the receiver's silent
  payment scan key to produce the actual key placed in the output script
  (or multiple keys with multiple output scripts if multiple silent
  payments are being made in the same transaction).

  After the transaction's output scripts are known, each signer
  re-processes the PSBT to add their signatures.  This results in a
  two-round process for the complete signing of the PSBT (in addition to any
  other rounds required by other protocols, such as [MuSig2][topic
  musig]).  However, if there's only one signer for the entire
  transaction (e.g. the PSBT is being sent to a single hardware signing
  device), the signing process can be completed in a single round.

  All active participants in the discussion at the time of writing seem
  roughly agreed on this approach, although discussion of edge cases is
  continuing. {% assign timestamp="7:32" %}

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Casa adds descriptor support:**
  In a [blog post][casa blog], multisig service provider Casa announced support
  for [output script descriptors][topic descriptors]. {% assign timestamp="10:55" %}

- **Specter-DIY v1.9.0 released:**
  The [v1.9.0][specter-diy v1.9.0] release adds support for taproot [miniscript][topic
  miniscript] and a [BIP85][] app, among other changes. {% assign timestamp="40:52" %}

- **Constant-time analysis tool cargo-checkct announced:**
  A Ledger [blog post][ledger cargo-checkct blog] announced
  [cargo-checkct][cargo-checkct github], a tool that evaluates whether Rust
  cryptographic libraries run in constant time to avoid [timing
  attacks][topic side channels]. {% assign timestamp="41:26" %}

- **Jade adds miniscript support:**
  The Jade hardware signing device firmware [now supports][jade tweet] miniscript. {% assign timestamp="43:15" %}

- **Ark implementation announced:**
  Ark Labs [announced][ark labs blog] a few initiatives around the [Ark
  protocol][topic ark] including an [Ark implementation][ark github] and
  [developer resources][ark developer hub]. {% assign timestamp="45:32" %}

- **Volt Wallet beta announced:**
  [Volt Wallet][volt github] supports descriptors, [taproot][topic taproot],
  [PSBTs][topic psbt], and other BIPs, plus Lightning. {% assign timestamp="46:42" %}

- **Joinstr adds electrum support:**
  [Coinjoin][topic coinjoin] software [joinstr][news214 joinstr] added an [electrum
  plugin][joinstr blog]. {% assign timestamp="47:20" %}

- **Bitkit v1.0.1 released:**
  Bitkit [announced][bitkit blog] its self-custodial Bitcoin and Lightning
  mobile apps moved out of beta and are available on mobile app stores. {% assign timestamp="47:50" %}

- **Civkit alpha announced:**
  [Civkit][civkit tweet] is a P2P trading marketplace built on nostr and the Lightning Network. {% assign timestamp="48:20" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 26.2rc1][] is a release candidate for a maintenance
  version of Bitcoin Core for users who cannot upgrade to the latest
  [27.1 release][bcc 27.1]. {% assign timestamp="49:01" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #29325][] begins storing transaction versions as
  unsigned integers.  Since the original version of Bitcoin 0.1, they
  were stored as signed integers.  The [BIP68][] soft fork began treating
  them as unsigned integers, but at least one Bitcoin re-implementation
  failed to reproduce this behavior, leading to a possible consensus
  failure (see [Newsletter #286][news286 btcd]).  By always storing and
  using transaction versions using unsigned integers, it is hoped that
  any future Bitcoin implementations based on reading Bitcoin Core's
  code will use the correct type. {% assign timestamp="50:11" %}

- [Eclair #2867][] defines a new type of `EncodedNodeId` to be assigned for
  mobile wallets in a [blinded path][topic rv routing]. This allows a wallet
  provider to be notified that the next node is a mobile device, enabling them
  to account for mobile-specific conditions. {% assign timestamp="52:04" %}

- [LND #8730][] introduces a RPC command `lncli wallet estimatefee` which
  receives a confirmation target as input and returns a [fee estimation][topic fee estimation] for
  on-chain transactions in both sat/kw (satoshis per kilo-weight unit) and
  sat/vbyte. {% assign timestamp="52:33" %}

- [LDK #3098][] updates LDK's Rapid Gossip Sync (RGS) to v2, which extends v1 by
  adding additional fields in the serialized structure. These new fields include
  a byte indicating the number of default node features, an array of node
  features, and supplemental feature or socket address information following
  each node public key. This update is distinct from the proposed [BOLT7][] gossip update
  similarly referred to as gossip v2. {% assign timestamp="28:14" %}

- [LDK #3078][] adds support for asynchronous payment of [BOLT12][topic offers]
  invoices by generating an `InvoiceReceived` event upon reception if the
  configuration option `manually_handle_bolt12_invoices` is set. A new command
  `send_payment_for_bolt12_invoice` is exposed on `ChannelManager` to pay the
  invoice.  This can allow code to evaluate an invoice before deciding
  whether to pay or reject it. {% assign timestamp="32:35" %}

- [LDK #3082][] introduces BOLT12 static invoice (reusable payment request)
  support by adding an encoding and parsing interface, and builder methods to
  construct a BOLT12 static invoice as a response to `InvoiceRequest` from an
  [offer][topic offers]. {% assign timestamp="33:53" %}

- [LDK #3103][] begins using a performance scorer in benchmarks based on
  frequent [probes][topic payment probes] of actual payment paths.  The
  hope is that this results in more realistic benchmarks. {% assign timestamp="35:18" %}

- [LDK #3037][] begins force closing channels if their feerate is stale
  and too low.  LDK continuously keeps track of the lowest acceptable
  feerate its [estimator][topic fee estimation] returned in the past
  day.  Each block, LDK will close any channel that pays a feerate below
  that past-day minimum.  The goal is "to ensure that channel feerates
  are always sufficient to get our commitment transaction confirmed
  on-chain if we need to force close". {% assign timestamp="38:07" %}

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2867,8730,3098,3078,3082,3103,3037,29325" %}
[news304 sp-psbt]: /en/newsletters/2024/05/24/#discussion-about-psbts-for-silent-payments
[news58 variable onions]: /en/newsletters/2019/08/07/#bolts-619
[morehouse onion]: https://delvingbitcoin.org/t/dos-disclosure-lnd-onion-bomb/979
[bcc 27.1]: /en/newsletters/2024/06/14/#bitcoin-core-27-1
[bitcoin core 26.2rc1]: https://bitcoincore.org/bin/bitcoin-core-26.2/
[news286 btcd]: /en/newsletters/2024/01/24/#disclosure-of-fixed-consensus-failure-in-btcd
[casa blog]: https://blog.casa.io/introducing-wallet-descriptors/
[specter-diy v1.9.0]: https://github.com/cryptoadvance/specter-diy/releases/tag/v1.9.0
[cargo-checkct github]: https://github.com/Ledger-Donjon/cargo-checkct
[ledger cargo-checkct blog]: https://www.ledger.com/blog-cargo-checkct-our-home-made-tool-guarding-against-timing-attacks-is-now-open-source
[jade tweet]: https://x.com/BlockstreamJade/status/1790587478287814859
[ark labs blog]: https://blog.arklabs.to/introducing-ark-labs-a-new-venture-to-bring-seamless-and-scalable-payments-to-bitcoin-811388c0001b
[ark github]: https://github.com/ark-network/ark/
[ark developer hub]: https://arkdev.info/docs/
[volt github]: https://github.com/Zero-1729/volt
[news214 joinstr]: /en/newsletters/2022/08/24/#proof-of-concept-coinjoin-implementation-joinstr
[joinstr blog]: https://uncensoredtech.substack.com/p/tutorial-electrum-plugin-for-joinstr
[bitkit blog]: https://blog.bitkit.to/synonym-officially-launches-the-bitkit-wallet-on-app-stores-9de547708d4e
[civkit tweet]: https://x.com/gregory_nico/status/1800818359946154471
