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
  writing) is always recommended.

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
  continuing.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

FIXME:bitschmidty

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 26.2rc1][] is a release candidate for a maintenance
  version of Bitcoin Core for users who cannot upgrade to the latest
  [27.1 release][bcc 27.1].

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
  code will use the correct type.

- [LND #8730][] lncli: new command `wallet estimatefeerate`

- [LDK #3098][] Parse v2 gossip (note that this appears to be version 2
  of LDK's custom rapid gossip sync protocol, not the proposed upgrade
  to the BOLT7 gossip standard that is sometimes called "v2 gossip" -harding)

- [LDK #3078][] Asynchronous `Bolt12Invoice` payment

- [LDK #3082][] BOLT 12 static invoice encoding and building

- [LDK #3103][] begins using a performance scorer in benchmarks based on
  frequent [probes][topic payment probes] of actual payment paths.  The
  hope is that this results in more realistic benchmarks.

- [LDK #3037][] begins force closing channels if their feerate is stale
  and too low.  LDK continuously keeps track of the lowest acceptable
  feerate its [estimator][topic fee estimation] returned in the past
  day.  Each block, LDK will close any channel that pays a feerate below
  that past-day minimum.  The goal is "to ensure that channel feerates
  are always sufficient to get our commitment transaction confirmed
  on-chain if we need to force close".

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
