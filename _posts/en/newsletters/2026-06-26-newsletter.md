---
title: 'Bitcoin Optech Newsletter #411'
permalink: /en/newsletters/2026/06/26/
name: 2026-06-26-newsletter
slug: 2026-06-26-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes the responsible disclosure of a
denial-of-service vulnerability that affected older versions of LND. Also
included are our regular sections with selected questions and answers from the
Bitcoin Stack Exchange, announcements of new releases and release candidates,
and descriptions of notable changes to popular Bitcoin infrastructure software.

## News

- **LND zero-timestamp gossip DoS disclosure:** Nishant Bansal [posted][lnd
  gossip dos delving] to Delving Bitcoin disclosing a denial-of-service
  vulnerability he discovered through state-machine fuzzing of LND's gossip
  handling. Versions of LND prior to v0.20.1-beta could be crashed by a
  `channel_update` or `node_announcement` gossip message carrying a timestamp of
  zero. Although [BOLT7][] requires `channel_update` timestamps to be greater
  than zero, it does not specify how nodes should handle messages that violate
  that rule, and LND's handling of the value led to a crash.

  When a vulnerable node tried to process one of these zero-timestamp messages,
  an internal bookkeeping error left a data structure in an invalid state,
  causing a runtime panic that terminated the node. An attacker could trigger
  the bug by broadcasting announcements for either a real public channel or a
  synthetic channel created by funding a 2-of-2 output the attacker controls,
  the latter being cheaper to repeat without running a Lightning node.

  The vulnerability was [responsibly disclosed][topic responsible disclosures],
  confirmed independently by Matt Morehouse, and fixed in [LND
  0.20.1-beta][news393 lnd 0201] by rejecting gossip messages with a zero
  timestamp at parse time, before they reach the vulnerable code.

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Is it a bug that `OP_IF` is part of the tapscript opcodes?]({{bse}}130785)
  Antoine Poinsot explains that while any spending policy can be expressed as
  one [taproot][topic taproot] leaf per path, that is not always the most
  efficient encoding. Depending on the number of paths and how often each is
  used, an `OP_IF` inside a single [tapscript][topic tapscript] leaf can produce
  smaller spends than splitting paths across leaves or switching to P2WSH.

- [Why would forbidding `OP_IF` in tapscript be a problem?]({{bse}}130815)
  Murch notes that because a taproot output commits to its leaf scripts as a
  hash, it is impossible to know which existing UTXOs rely on `OP_IF`, such as
  [miniscript][topic miniscript]-based degrading multisig wallets. Users with such
  setups could unwittingly lock up funds received after activation if those
  spending paths were no longer valid.

- [Does a softfork always succeed?]({{bse}}130775)
  Murch walks through a scenario where a [soft fork][topic soft fork activation]
  using mandatory signaling is supported by only a minority of hashrate,
  showing that the signaling chain falls behind on proof of work and stalls
  rather than forcing the rest of the network to adopt the new rules.

- [How to set up Bitcoin Core to mine a valid block after the BIP110 activation in August 2026?]({{bse}}130770)
  Antoine Poinsot notes that Bitcoin Core does not enforce the BIP110
  rules and has no feature to build a block template that excludes the
  transactions BIP110 treats as invalid. A node operator wanting to mine
  BIP110-compliant blocks would need to select transactions with external block
  template building software or could mine empty blocks.

- [Are BIP110 blocks on a branch with lower difficulty valid?]({{bse}}130827)
  Pieter Wuille distinguishes a chain being valid from being active. Each
  branch's difficulty adjustment depends only on its own blocks, so a potentially-slower
  BIP110 branch is still valid to nodes following the current rules, but they
  will never make it their active chain unless it accumulates more total proof
  of work than the main chain.

- [What is the story behind Bitcoin test networks?]({{bse}}130806)
  Murch and Antoine Poinsot trace the history of [testnet][topic testnet] from
  testnet1 through the proposed testnet5, including the repeated resets after
  each network was monetized and the 20-minute difficulty exception that led to
  testnet3's recurring block storms (see [Newsletter #311][news311 block storm]).

- [Why was `-datacarriersize` redefined in 2022, and why was the 2023 proposal to expand it not merged?]({{bse}}128027)
  Revisiting a question first answered last year, Murch adds a complementary
  answer documenting that the `datacarrier` and `datacarriersize` options have
  referred only to `OP_RETURN` outputs since their introduction in Bitcoin Core
  0.10.0, citing the original code and release notes.

- [Are chains of 26 unconfirmed transactions prohibited by the wallet in Bitcoin Core 31.0?]({{bse}}130777)
  Pol Espinasa clarifies that the mempool itself permits longer chains under the
  new [cluster mempool][topic cluster mempool] limits, but the Bitcoin Core
  wallet still enforces a 25-transaction limit during coin selection, so longer
  chains must be built without the wallet.

- [Are there changes in Bitcoin Core 29.0 that affect memory usage?]({{bse}}127887)
  Antoine Poinsot clarifies that the apparent increase is a reporting artifact
  rather than higher process memory use. Bitcoin Core 29.0 lets its chainstate
  database cache more data when free memory is available, and that cache is
  released when other processes need the memory.

- [What is Bitcoin Core's release schedule?]({{bse}}130817)
  Murch describes that Bitcoin Core releases major versions on a fixed
  schedule in April and October, replacing the previous practice of targeting
  six months after the prior release, where timelines might slip. Minor releases
  continue to ship bug fixes as needed.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [LDK v0.1.10][] is a maintenance release of this library for building
  LN-enabled wallets and applications. It fixes several denial-of-service
  vulnerabilities and a sanitization issue, plus bugs affecting async channel
  monitor persistence, Electrum syncing, [BOLT12 offer][topic offers]
  validation, onion-message handling, [MPP][topic multipath payments]
  [keysend][topic spontaneous payments] [HTLCs][topic htlc], and route-based
  payment sending.

- [LDK v0.2.3][] is a maintenance release of this library for building
  LN-enabled wallets and applications. It fixes several security issues,
  including denial-of-service vulnerabilities, reserve calculation errors for
  anchor channels, and a sanitization issue, along with bugs affecting async
  channel monitor persistence, LSPS handling,
  [zero-fee-commitment channels][topic v3 commitments], BOLT12 offers, onion
  messaging, and rapid gossip sync memory use.

- [BTCPay Server 2.4.0][] is a release of this self-hosted payment processor.
  It adds global search, passkey authentication, guided multisig wallet setup,
  more granular wallet permissions, subscription and point-of-sale improvements,
  wallet transaction search and filtering, plugin ecosystem improvements, and
  updated Lightning support, while removing several deprecated Lightning
  backends.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #35070][] prevents duplicate entries from being added to
  `m_blocks_unlinked`, a validation-internal structure that tracks downloaded
  blocks that cannot yet be connected due to missing earlier block data.
  Previously, a pruned node facing a deep reorg could accidentally add duplicate
  entries to this structure, causing the `ReceivedBlockTransactions()` function
  to reconsider the same block more than once after receiving the missing data
  and re-add it to `setBlockIndexCandidates` after modifying its `nSequenceId`.
  This could corrupt the set's in-memory ordering of candidate chain tips,
  potentially leading to undefined behavior. The PR routes insertions through a
  new `AddUnlinkedBlock()` helper that deduplicates entries and strengthens
  `CheckBlockIndex()` to ensure that no duplicates are present.

- [Bitcoin Core #35182][], [#34411][bitcoin core #34411] replace the
  libevent-based HTTP server, used for RPC and REST, with a new HTTP and
  socket-handling implementation maintained in Bitcoin Core. The new server runs
  its own I/O thread, handles sockets directly, and dispatches accepted requests
  to the existing HTTP worker pool. The follow-up PR removes the remaining
  libevent build, CI, dependencies, and CMake plumbing. These changes continue
  the project's efforts to reduce external dependencies and simplify building
  Bitcoin Core from source.

- [BIPs #2198][] updates [BIP360][], the P2MR proposal (see [Newsletter
  #393][news393 p2mr]), so that anyone who knows and reveals the single leaf in
  a depth-zero script tree can spend the output without that script being
  executed. This intentionally makes one-path P2MR outputs unsafe: once a user
  reveals the leaf in an attempted spend, a miner could use the same revealed
  leaf to spend the output to themselves instead. The change discourages wallets
  from omitting a [post-quantum][topic quantum resistance] or other fallback
  leaf merely to save witness bytes.

- [LDK #4713][] adds denial-of-service hardening for Rapid Gossip Sync (RGS)
  (see [Newsletter #308][news308 rgs]), LDK's format for quickly importing
  Lightning Network gossip data. The documentation now warns that RGS sources
  should be considered semi-trusted, since they can prevent successful
  pathfinding by omitting data and they may also attempt to bloat a client's
  network graph. LDK now rejects snapshots with nonsensical node or channel
  update counts, and skips adding new [channel announcements][topic channel
  announcements] once the graph contains more than ten times the expected number
  of channels.

- [LDK #4684][] fixes a rare async signer and channel monitor ordering bug that
  could cause a duplicate `revoke_and_ack` to be sent after reconnecting.
  Previously, if a signer-unblocked path regenerated and sent an owed
  `revoke_and_ack` while a monitor update was still pending, the
  monitor-restored path could later regenerate the same message, causing the
  peer to reject the duplicate secret and force-close. LDK now clears the
  monitor-pending `revoke_and_ack` flag when the signer-pending path returns a
  `revoke_and_ack`, since that message also satisfies the monitor-pending
  resend.

{% include snippets/recap-ad.md when="2026-06-30 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2198,34411,35070,35182,4684,4713" %}

[news311 block storm]: /en/newsletters/2024/07/12/#bitcoin-core-pr-review-club
[lnd gossip dos delving]: https://delvingbitcoin.org/t/lnd-zero-timestamp-gossip-dos-disclosure/2621
[news393 lnd 0201]: /en/newsletters/2026/02/20/#lnd-0-20-1-beta
[LDK v0.1.10]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.10
[LDK v0.2.3]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.2.3
[BTCPay Server 2.4.0]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.4.0
[news393 p2mr]: /en/newsletters/2026/02/20/#bips-1670
[news308 rgs]: /en/newsletters/2024/06/21/#ldk-3098
