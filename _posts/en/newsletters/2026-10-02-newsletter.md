---
title: 'Bitcoin Optech Newsletter #425'
permalink: /en/newsletters/2026/10/02/
name: 2026-10-02-newsletter
slug: 2026-10-02-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes the responsible disclosure of two
denial-of-service vulnerabilities affecting older versions of Eclair and
describes a proposal for synchronizing wallet labels between devices
through an untrusted store. Also included are our regular sections summarizing
proposals and discussion about changing Bitcoin's consensus rules, announcing
new releases and release candidates, and describing notable changes to popular
Bitcoin infrastructure software.

## News

- **Disclosure of two DoS vulnerabilities in Eclair**: Matt Morehouse
  [posted][mm eclair dos] to Delving Bitcoin the [responsible
  disclosure][topic responsible disclosures] of two denial-of-service (DoS)
  vulnerabilities affecting Eclair v0.13.1 and earlier. Both were fixed in
  [Eclair v0.14.0][news407 eclair], released in May, and users still running
  an older version should upgrade. Each attack requires only a completed
  [BOLT8][] handshake, not a channel.

  The first vulnerability is in feature bit parsing. Eclair parsed the
  feature bits in an `init` message one at a time, allocating several
  objects per bit, so a single maximum-length `init` message allocated and
  discarded about 300 MB of memory and occupied a parsing thread for up to
  300 ms. In Morehouse's tests, an attacker with a few dozen connections
  repeating that message disconnected all of the node's peers within a minute
  and exhausted its memory within five. Morehouse found the bug with
  [smite][smite repo], his LN fuzzer, using its most basic test, which sends
  raw bytes as a single message and checks that the target still answers a
  `ping` promptly. The fix was merged in March as part of [Eclair #3264][], a
  refactoring of feature parsing that did not mention the vulnerability.

  The second vulnerability is in gossip queries. [BOLT7][] removed the zlib
  encoding for `query_short_channel_ids` messages in April 2022, and Eclair stopped
  sending it the same month but continued to accept it. The zlib decompression
  had no output limit, so a 64 kB message could inflate to 64 MB and about 17
  million objects, and a flood of such messages took a node offline within
  seconds. Morehouse found it after the first bug by using an LLM to search the
  Eclair codebase for other places where a peer could impose far more work on
  the node than it spends itself. The fix is [Eclair #3263][].

- **Proposal for wallet label synchronization**: Jakub [posted][label sync ml]
  to the Bitcoin-Dev mailing list to gauge interest in standardizing
  synchronization of [wallet labels][topic wallet labels] between wallets
  through a shared, untrusted store before writing a specification. Although
  [BIP329][] standardized a label export format (see [Newsletter #215][news215
  label]), moving labels between wallets that use the same
  [descriptor][topic descriptors], such as a coordinator and a watch-only
  wallet, remains a manual export and import cycle, so coin selection decisions
  are made without the associated labels.

  Under the proposal, wallets derive a storage location and encryption keys
  from a canonical form of the descriptor, without any private keys, so
  wallets sharing a descriptor find the same data with no configuration.
  Unmodified BIP329 records travel inside an authenticated encryption
  envelope. Each record is stored with the time it was written, so when two
  wallets change the same label, the most recent change takes precedence.
  Because BIP329 has no way to delete a label, a deletion is recorded as a
  marker that removes the label from other wallets. Jakub proposes Nostr as
  the reference transport, but the protocol only requires a service that can
  store and return data. The Bitcoin Safe wallet already synchronizes labels
  this way over Nostr. Jakub asked whether encryption keys should derive from
  the descriptor, which lets a wallet restore its labels from the descriptor
  alone but exposes them to anyone who has held the xpubs, or from a separate
  secret. He also asked whether to use one shared keypair across devices or
  per-device pairing, and how to define the canonical descriptor form.

  Craig Raw replied that label synchronization should be part of a broader
  inter-wallet communication specification, which should include other use cases
  such as [PSBTs][topic psbt], multisig setups, and payment confirmations.
  He also pushed back on the use of Nostr as the reference transport protocol,
  since exchange of financial data should optimize for privacy, rather than
  censorship resistance, and noted that he is working on a BIP for canonical
  output descriptors.

## Changing consensus

_A monthly section summarizing proposals and discussion about changing
Bitcoin's consensus rules._

FIXME:bitschmidty

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

FIXME:Gustavojfe

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

FIXME:Gustavojfe

{% include snippets/recap-ad.md when="2026-10-06 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="" %}

[mm eclair dos]: https://delvingbitcoin.org/t/disclosure-dos-vulnerabilities-fixed-in-eclair-v0-14-0/2914
[news407 eclair]: /en/newsletters/2026/05/29/#eclair-v0-14-0
[smite repo]: https://github.com/lnfuzz/smite
[label sync ml]: https://groups.google.com/g/bitcoindev/c/p6UUOdGi9YI
[news215 label]: /en/newsletters/2022/08/31/#wallet-label-export-format
