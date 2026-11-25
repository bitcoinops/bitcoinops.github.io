---
title: 'Bitcoin Optech Newsletter #433'
permalink: /en/newsletters/2026/11/27/
name: 2026-11-27-newsletter
slug: 2026-11-27-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a vulnerability affecting older versions of
Bitcoin Core, summarizes the disclosure of a denial-of-service vulnerability in
Core Lightning, and relays discussion about refreshing the BIP editor team.
Also included are our regular sections with selected questions and answers
from the Bitcoin Stack Exchange, announcements of new releases and release
candidates, and descriptions of notable changes to popular Bitcoin
infrastructure software.

## News

- **Disclosure of a medium-severity vulnerability in Bitcoin Core:** Greg
  Sanders [posted][sanders adv ml] to the Bitcoin-Dev mailing list a Bitcoin
  Core [security advisory][core orphan inv stall] for a vulnerability that
  allowed a peer to temporarily stop a node from processing blocks and
  transactions. It affects all 29.x releases, 30.x before [30.5][core 30.5],
  and 31.x before [31.3][core 31.3]. Version 32.1 already includes the fix.
  The 29.x series has reached end of life and will not receive a fix, so its
  users should upgrade to a maintained release.

  Bitcoin Core stores transactions whose parents it has not yet seen, called
  orphans. Since 29.0, each time a peer announced the wtxid of a stored
  orphan, the node checked every parent of that orphan against its mempool
  and its filters of recently seen transactions. An `inv` message can contain
  up to 50,000 announcements, and duplicates were not skipped. An attacker
  could send an orphan with thousands of missing parents, followed by `inv`
  messages repeating its wtxid 50,000 times. According to the advisory, each
  such message stalled the node for over a dozen seconds, during which it
  processed no messages from other peers, including blocks. [Bitcoin Core
  #35878][] now processes each announced transaction only once per `inv`
  message.

  The vulnerability was discovered in July by Project Loupe, [responsibly
  disclosed][topic responsible disclosures] by Sanders, and independently
  reported by stutxo in August. Because it was classified as easily
  discoverable (see [Newsletter #429][news429 policy]), the advisory was
  published alongside 30.5 and 31.3.

- **Disclosure of a DoS vulnerability in CLN:** Nishant Bansal [posted][cln
  vuln del] to Delving Bitcoin the [responsible disclosure][topic responsible
  disclosures] of a denial-of-service (DoS) vulnerability in Core Lightning
  (CLN) affecting versions [0.12.0][cln 0.12.0] (August 2022) through
  [26.06.7][cln 26.06.7] (August 2026), which allowed an attacker to repeatedly
  crash a victim's node. The bug gave an attacker no direct access to funds,
  but continuously crashing a node could put its channel funds at risk. Users
  are recommended to upgrade to the latest version immediately. The
  vulnerability was fixed in CLN version 26.06.8 (see [Newsletter #424][news424
  cln rel]).

  The vulnerability was related to more than one v1 channel sharing the same
  `channel_id`. A malicious peer could open a channel by providing another
  channel's funding outpoint. Since `channel_id` is derived from that outpoint,
  according to [BOLT2][], two channels would thus have matching IDs. CLN runs a
  `channeld` subdaemon for each channel, while `connectd` routes messages to
  the correct subdaemon based on their `channel_id`. Since CLN assumes the
  uniqueness of `channel_id`, collisions led the node to crash.

  There were two ways a malicious peer could crash the node, one during
  reconnection, detected using [smite][gh smite], a snapshot fuzzing framework
  for Lightning Network implementations, and the other on channel closure,
  found by developer Eugene Siegel:

  - When a peer reconnects, the main daemon, `lightningd`, starts the
    `channeld` subdaemons and hands them to `connectd`. On the first
    `channel_id` lookup everything would work fine. However, on the second
    request an `assert` proving that the connection was not already active
    would abort `connectd`, taking down the node. Since both channels were
    still present in the database after a restart, a new reconnection attempt
    would crash the node again.

  - CLN keeps in memory previously closed channels in a hash table keyed by
    `channel_id`. An attacker closing a channel with the same `channel_id` as
    one already closed would trigger the failure of an assertion checking that
    no duplicates were added to the map. Unlike the first variant, the node
    then crashes on every restart without further action from the attacker,
    until it is upgraded. This specific attack vector affected only versions
    [25.05][cln 25.05] and higher.

FIXME:bitschmidty

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Why does a policy that is valid with rust-miniscript throw a compile error on the sipa site?]({{bse}}131089)
  Pieter Wuille explains that his [miniscript][topic miniscript] policy
  compiler site accepts symbolic names only for keys, not hash preimages, and
  does not allow malleable scripts (see
  [Newsletter #230][news230 malleable]). One branch of the asker's policy
  could be satisfied by just revealing a preimage after 144 blocks, which is
  inherently malleable because it involves no signatures.

- [How can I repair corrupted undo data (rev*.dat checksum mismatch) without a full reindex?]({{bse}}131107)
  P22 describes rebuilding damaged undo records on a node with `-txindex`. A
  block's undo data is the list of outputs its inputs spent, so each record
  can be reconstructed byte for byte and written back in place.
  `-reindex-chainstate` does not help because Bitcoin Core only writes undo
  data for a block that has no undo position yet.

- [Why does no Bitcoin opcode push data about the spending transaction onto the stack?]({{bse}}131130)
  LearnBitcoin answers that a soft fork redefining an `OP_NOP` opcode can
  only make scripts fail, since leaving a value on the stack would cause old
  and new nodes to disagree about validity. That is why the proposed
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] only verifies.
  [Tapscript][topic tapscript] added `OP_SUCCESSx` opcodes that may also
  write to the stack (see [Newsletter #416][news416 success]), and the
  [covenant][topic covenants] proposals `OP_TXHASH` and `OP_TEMPLATEHASH` are
  defined on them.

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

{% include snippets/recap-ad.md when="2026-12-01 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="35878" %}
[sanders adv ml]: https://groups.google.com/g/bitcoindev/c/lFzWO5W9pBE
[core orphan inv stall]: https://bitcoincore.org/en/2026/11/20/disclose-orphan-inv-stall/
[core 31.3]: https://bitcoincore.org/en/2026/11/20/release-31.3/
[core 30.5]: https://bitcoincore.org/en/2026/11/20/release-30.5/
[news429 policy]: /en/newsletters/2026/10/30/#bitcoin-core-security-policy-update
[cln vuln del]: https://delvingbitcoin.org/t/disclosure-dos-vulnerability-fixed-in-core-lightning-v26-06-8/3072
[cln 0.12.0]: https://github.com/ElementsProject/lightning/releases/tag/v0.12.0
[cln 26.06.7]: https://github.com/ElementsProject/lightning/releases/tag/v26.06.7
[news424 cln rel]: /en/newsletters/2026/09/25/#core-lightning-26-06-8
[gh smite]: https://github.com/lnfuzz/smite
[cln 25.05]: https://github.com/ElementsProject/lightning/releases/tag/v25.05
[news230 malleable]: /en/newsletters/2022/12/14/#when-is-a-miniscript-solution-malleable
[news416 success]: /en/newsletters/2026/07/31/#was-the-op-successx-reservation-in-bip342-designed-with-specific-opcode-families-in-mind
