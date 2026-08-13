---
title: 'Bitcoin Optech Newsletter #418'
permalink: /en/newsletters/2026/08/14/
name: 2026-08-14-newsletter
slug: 2026-08-14-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposed contract protocol for mitigating
Lightning Network channel jamming, reports on the availability of static Bitcoin
Core binaries for testing, and summarizes a change replacing Bitcoin Core's
per-peer transaction rate-limiting with a global approach. Also included are
our regular sections announcing new releases and release candidates, and
describing notable changes to popular Bitcoin infrastructure software.

## News

- **Conditional message transfer contract to solve jamming**: Antoine Riard
  [posted][chan jam del] to Delving Bitcoin a new approach to mitigate
  [channel jamming][topic channel jamming attacks] on the Lightning Network.
  Jamming is a denial-of-service attack in which the attacker sends
  [HTLCs][topic htlc] or [PTLCs][topic PTLC] and then holds them unresolved,
  tying up the channel liquidity along a route at no cost to itself. Riard's
  proposal makes holding expensive by charging a withhold fee proportional to
  how long a payment is held, converting a currently free attack into a costly
  one.

  The mechanism is a conditional message transfer contract (CMTC) which is a
  Bitcoin Script construction that lets two channel counterparties later prove
  whether a specific message (such as a payment preimage) was exchanged between
  them by a given block height, which Riard treats as a universal clock. The
  parties agree on a temporal window and assign an adaptor point to each point
  in time within it, so the withhold fee can be settled according to when the
  message was delivered. The contract offers three settlement paths:

  - **Message transfer success:** the preimage is delivered from Bob to Alice
    and cryptographically acknowledged, and the two split the withhold fee based
    on delivery time.

  - **Liveness challenge:** if Alice is offline and cannot counter-sign, Bob can
    exit the contract and recover the locked funds minus an equilibrium penalty
    fee.

  - **Message transfer failure:** if Bob is offline or otherwise fails to
    transfer the message, Alice can exit and recover the withhold fee.

  Riard notes that the proposed solution needs further analysis, both of its
  cryptographic correctness and of its incentives, and that it remains open
  whether this approach, or an expansion of it, could solve other types of
  problems in Bitcoin.

- **Static Bitcoin Core binaries available for testing**: Michael Ford
  (fanquake) [posted][fanquake static ml] to the Bitcoin-Dev mailing list
  announcing test builds of static Bitcoin Core release binaries produced
  using the project's existing [Guix][topic reproducible builds]
  infrastructure. Test binaries are available for `bitcoind` and the other
  command-line utilities on x86_64 and aarch64 Linux, with more platforms
  planned. The `bitcoin-qt` GUI binary is unchanged.

  Bitcoin Core's current Linux release binaries are dynamically linked, meaning
  that they contain most of the code they need but depend on the C library
  (glibc) and a few related libraries provided by the user's operating system.
  Those libraries are located and loaded each time the program starts, a
  dependency that carries some risks. The binaries only run on systems that
  provide a compatible glibc (currently version 2.31 or newer), their behavior
  can vary with the host's libraries, and some of the code the node actually
  executes falls outside the binary that reproducible builds allow users to
  verify. A static binary instead includes all of the code it needs, so the same
  verified executable runs the same way on nearly any Linux system, including
  older releases, distributions built on a different C library such as Alpine
  Linux, and minimal container images that ship no system libraries at all. The
  new binaries remain position-independent executables, preserving the ASLR
  exploit mitigation of current releases, and are only about 1 MB larger.

  The mailing list post continues years of work in [Bitcoin Core #25573][],
  which Ford opened in 2022. Progress required changes to the GCC compiler and
  to glibc itself, including fixes to glibc's name resolution code, historically
  the main hazard of statically linking glibc. Some preparatory changes to the
  Guix build process (see [Bitcoin Core #35537][]) have been merged, but the
  main PR remains open and under review. Readers who run Bitcoin Core on Linux
  are encouraged to try the [test binaries][static test bins] and report any
  problems, or successes, to the mailing list or the PR.

- **Replacing per-peer transaction rate-limiting with global rate limits**:
  Anthony Towns [posted][peer queue del] to Delving Bitcoin announcing the merge of
  [Bitcoin Core #34628][], which replaces the per-peer transaction rate-limiting
  with a global approach.

  For each of its peers, a node keeps a queue of the transaction announcements
  it intends to send to that peer, called `m_tx_inventory_to_send`, sorts those
  announcements by ancestor feerate, and sends the best of them first. To limit
  bandwidth and to make it harder to probe the relay topology, a node announces
  no more than about 7 transactions per second to each peer. In normal times
  this rate is enough to drain the queue, but a sudden burst of transactions can
  fill it faster than the limit lets it drain. Because the node re-sorts the
  growing queue on every announcement, this can consume an excessive amount of
  CPU, a denial-of-service (DoS) vector previously described in
  [Newsletter #324][news324 dos].

  Towns' PR replaces the per-peer rate-limiting with a global rate limit, using
  two token buckets that meter total announcements by count (number of
  transactions) and by size (serialized witness size). If there is enough
  capacity, an incoming transaction is relayed immediately, otherwise it is
  added to a single global backlog sorted by feerate and [cluster
  mempool][topic cluster mempool] rules. Transactions selected from that backlog
  are then placed in a small per-peer queue used for privacy batching. Sorting
  one shared backlog instead of a separate queue per peer avoids the repeated
  per-peer sorting that made the original design a DoS vector.

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

{% include snippets/recap-ad.md when="2026-08-18 16:30" %}
{% include references.md %}
[chan jam del]: https://delvingbitcoin.org/t/conditional-message-transfer-contract-to-solve-jamming/2772
[fanquake static ml]: https://groups.google.com/g/bitcoindev/c/UgGHs-_YGvw
[static test bins]: https://github.com/fanquake/bitcoin/releases/tag/static_bitcoind_ff01e5af948d
[peer queue del]: https://delvingbitcoin.org/t/transaction-rate-limiting/2744
[news324 dos]: /en/newsletters/2024/10/11/#dos-from-large-inventory-sets
