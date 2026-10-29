---
title: 'Bitcoin Optech Newsletter #429'
permalink: /en/newsletters/2026/10/30/
name: 2026-10-30-newsletter
slug: 2026-10-30-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a protocol for creating silent payment
transactions from multiparty wallets, summarizes the responsible disclosure of
a denial-of-service vulnerability that affected older versions of Core
Lightning, and explains Bitcoin Core's updated security policy for easily
discoverable vulnerabilities. Also included are our regular sections with
selected questions and answers from the Bitcoin Stack Exchange, announcements
of new releases and release candidates, and descriptions of notable changes to
popular Bitcoin infrastructure software.

## News

- **Silent payments for multiparty wallets**: Oleksandr Kurbatov
  [posted][sp multi del] to Delving Bitcoin to describe a protocol
  to use multiparty inputs in [silent payment][topic silent payments]
  transactions. [BIP352][] does not recommend using that kind of
  input due to lack of a security proof. The protocol allows
  a multiparty sender to compute the ECDH share as a weighted sum of
  the signers' contributions, while providing an aggregated
  [DLEQ][topic dleq] proof, called AggDLEQ, to prove that the ECDH
  share is correctly derived from the input key. The proposal works
  with several multiparty protocols, such as [FROST][BIPs #2070]
  and [MuSig2][topic musig].

  The proposed protocol relies on two rounds. A coordinator provides
  context, containing signer set, signing protocol coefficients and
  tweak, key material, the transaction, and a session ID. During the
  first round, each signer generates two random nonces and sends messages
  needed for AggDLEQ back to the coordinator, such as the ECDH
  share computed from their own key fragment and nonce commitments.
  Those messages are used by the coordinator to compute the combined
  ECDH share and a challenge. During the second round, each signer
  produces a contribution to the proof based on the provided challenge.
  If the responses are correct, the coordinator aggregates all the
  responses into a single proof compatible with [BIP374][].

  Kurbatov stated that the protocol needs no changes to BIP352, BIP374,
  BIP375, or the MuSig2 and FROST signing protocols, and no new PSBT
  fields, because the AggDLEQ messages are exchanged only between the
  signers over the wallet's coordinator channel. He said a paper with
  security proofs is under internal review, but noted that its claim that
  corrupted signers and the coordinator cannot forge a proof or a
  signature relies on an assumption whose hardness is an open question.

- **CLN self-referential channel announcement DoS disclosure:** Nishant
  Bansal [posted][cln selfref dos] to Delving Bitcoin disclosing a
  denial-of-service vulnerability affecting Core Lightning (CLN) versions
  25.02 through 26.04. CLN never checked that the two node IDs in a
  [channel announcement][topic channel announcements] differ, so an
  announcement naming the same node as both endpoints passed validation and
  was written to the on-disk gossip store before being loaded into the
  in-memory channel graph. Loading it added the unknown node twice, which
  tripped a no-duplicates assertion in `gossipd` and crashed the node. The
  stored message then crashed the node again on every restart until the
  operator removed it by hand, which upgrading alone did not do.

  An attacker only needed to fund a 2-of-2 output it controlled and sign the
  announcement with those keys and a fresh node key, so the cost was limited
  to onchain fees. Older CLN releases accept and relay such an announcement
  without crashing, so they could carry it to vulnerable nodes the attacker
  could not reach directly.

  Bansal found the bug with a gossip fuzz target later proposed in [Core
  Lightning #9115][]. It was [responsibly disclosed][topic responsible
  disclosures] in April and fixed in [CLN 26.04.1][cln 26.04.1] (see
  [Newsletter #398][news398 cln 26041]) by [Core Lightning #9082][], which
  rejects any announcement whose `node_id_1` is not strictly less than
  `node_id_2`. [BOLTs #1333][] added the same receiver requirement to
  [BOLT7][], which had only required senders to order the IDs. Operators
  still on an affected version should upgrade to the latest release.

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Why does Bitcoin use both a transaction ID and a witness transaction ID?]({{bse}}131077)
  Pieter Wuille explains that [segwit][topic segwit] moved signatures and
  other malleable data into the witness, which the txid excludes, so that
  presigned chains of unconfirmed transactions keep working. Inputs therefore
  still reference txids. Blocks additionally commit to wtxids so that a node
  handed a block with tampered witness data can reject it permanently rather
  than reprocess every variant a peer offers. [BIP339][] later extended wtxid
  use to transaction relay for similar denial-of-service reasons.

- [How to sign a MuSig with Bitcoin Core]({{bse}}131086) Ava Chow explains
  that [MuSig2][topic musig] signing takes two rounds, so each wallet must
  process the [PSBT][topic psbt] twice. The first pass adds the wallet's public
  nonce and the second, run on the combined PSBT once every nonce is present,
  adds its partial signature, after which `finalizepsbt` produces the
  transaction. The asker published an [example][bc musig2] of creating and
  spending from a MuSig2 address with Bitcoin Core.

- [What changed in Bitcoin P2P protocol version 70017 compared to 70016?]({{bse}}131080)
  Ava Chow explains that [BIP434][] assigns the new version number because it
  introduces a new `feature` message exchanged during the `version` handshake.
  The message itself lets peers announce and negotiate optional features for
  the life of a connection, replacing the historical practice of bumping the
  protocol version or defining a dedicated message for each new feature (see
  [Newsletter #386][news386 bip434]). Bitcoin Core implemented the message and
  the version bump earlier this year (see [Newsletter #410][news410 bip434]),
  and both ship in [Bitcoin Core 32.1][], described below.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Bitcoin Core 32.1][] is the latest major release of the network's
  predominant full node implementation. Version 32.0 was tagged but never fully
  released because of last-minute issues. This release includes the three
  security fixes described below. Other changes include
  mempool-based [fee estimation][topic fee estimation], [PSBT][topic psbt]v2 by
  default, watch-only wallet exports, and faster block validation. Existing
  transaction and transaction-output-spender indexes remain compatible but
  must be rebuilt to save disk space. See the [release notes][bcc32.1 rn] for
  details and upgrade considerations. Versions 29.x and earlier have reached
  the end of their lifecycle and will no longer receive updates.

- [Bitcoin Core 31.2][] is a maintenance release of the predominant
  full-node implementation. It includes the same three security fixes as
  32.1. It also excludes the version bits that [BIP323][] reserves as
  extra nonce space for miners from the [BIP9][] unknown soft fork warning
  (see [Newsletter #409][news409 bip323]), caps the `-privatebroadcast`
  queue at 10,000 transactions, and compacts the chainstate database
  regularly. See the [release notes][bcc31.2 rn] for details.

- [Bitcoin Core 30.4][] is a maintenance release for a previous major
  release series. It includes the same three security fixes as 32.1, the
  BIP323 warning change, and the removal of one DNS seed. See the [release
  notes][bcc30.4 rn] for details.

- [Bitcoin Core 29.5][] is a maintenance release for a previous major
  release series. It includes the same three security fixes as 32.1 and the
  removal of one DNS seed. See the [release notes][bcc29.5 rn] for details.

- [Eclair 0.14.6][] is a security release for this LN node implementation. It
  includes the [splicing][topic splicing] force-close and [on-the-fly
  funding][topic jit channels] fee-tracking fixes described below. The project
  strongly recommends upgrading because malicious peers can exploit some of the
  fixed issues.

- [LND v0.21.5-beta][lnd0215] and [v0.20.6-beta][lnd0206] are maintenance
  releases of this popular LN node implementation, following the release
  candidates covered in [Newsletter #428][news428 releases]. Both
  include the commitment feerate fixes described below, as well as fixes for
  excessive memory allocation when parsing TLV records and SQL database
  deadlocks, and faster startup cleanup on SQL-backed nodes.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #36665][] fixes a [memory-exhaustion vulnerability][core tcp
  oom] that allowed a connected peer to crash nodes running on Windows, macOS,
  or BSD. Although Bitcoin Core pauses reads from a peer when its receive queue
  grows too large, its `select()` socket backend continued monitoring
  exceptional conditions. A peer could send TCP urgent data to trigger further
  reads and bypass the queue limit. Now, exceptional conditions are only
  monitored when reads are enabled for that socket. Linux uses a different
  socket backend and was unaffected.

- [Bitcoin Core #36667][] adds a timeout that disconnects a peer if the node's
  send buffer for that peer exceeds its limit for more than 20 minutes,
  mitigating [unbounded memory growth][core paused send oom]. Bitcoin Core
  continues to queue some transaction announcements even after this limit is
  exceeded. Typically, a ping timeout would eventually disconnect a
  slow-reading peer. However, peers claiming a protocol version predating
  [BIP31][] could avoid this. This would allow a malicious peer to maintain an
  open connection while queued announcements gradually accumulate. The new
  timeout applies regardless of the peer's protocol version. Nodes using the
  `-blocksonly` option were much less affected.

- [Bitcoin Core #36669][] fixes an [undo-file overflow][core undo overflow]
  that could corrupt data needed to disconnect blocks during a reorg. Since
  undo data can exceed the size of its corresponding block data, an undo file
  can exceed 4 GiB and wrap its 32-bit offset, thereby overwriting earlier
  data. A subsequent reorg could stop the node, requiring reindexing with a
  fixed version to recover. The fix increases the file offset size to 64 bits.
  It also uses 64-bit file positioning calls on Windows, where exceeding 2 GiB
  could stop the node even without a reorg. Exploitation requires mining
  thousands of specially constructed blocks. For the corruption case, it also
  requires precisely positioning those blocks within the targeted node's block
  files, followed by a reorg. The disclosure deems this impractical. Nodes on
  32-bit systems or FAT32 block storage are still affected.

- [BIPs #2130][] adds draft [BIP139][], Wallet Metadata Export Format,
  specifying a JSON format for exporting wallet accounts and their [output
  script descriptors][topic descriptors], signer information, [labels][topic
  wallet labels], transactions, coins, and [PSBTs][topic psbt] (see [Newsletter
  #399][news399 metadata]). This format enables the transfer of metadata
  between wallets and the restoration of information that cannot be recovered
  by a seed backup alone. The specification prohibits including spending
  private keys or mnemonic seeds in mainnet exports, so these exports
  complement a separate key backup.

- [Core Lightning #9627][] updates `xpay` to account for [BOLT4][]'s 1,300-byte
  routing information limit for the payment onion before selecting a payment
  route. Previously, pathfinding could succeed, but onion construction could
  fail if the selected path exceeded the limit. This could cause a payment to
  fail even when a shorter path might have worked. `xpay` now calculates the
  available space after accounting for the receiver's final payload or the
  invoice's [blinded path][topic rv routing], then passes a corresponding hop
  limit to askrene through a new `maxhops` parameter on its `getroutes` RPC.
  The pathfinding cost calculation in askrene also adds a penalty for each
  hop to favor shorter routes.

- [Eclair #3417][] and [#3419][eclair #3419] improve force-close handling when
  [splice transactions][topic splicing] remain unconfirmed (see [Newsletter
  #427][news427 eclair splicing]). For non-zero-conf channels, Eclair now
  selects the newest commitment whose funding transaction is confirmed or
  present in its Bitcoin backend's mempool, reevaluating that choice as blocks
  arrive or as splice transactions are published. It also includes unconfirmed
  funding ancestors in anchor [CPFP][topic cpfp] fee calculations and starts
  claiming outputs of non-revoked remote commitments for earlier funding states
  after one confirmation. The new `require-confirmed-inputs-for-splicing`
  setting, enabled by default, requires confirmed inputs from the peer when
  splicing and prevents Eclair from initiating another splice until the
  previous one confirms. The changes also ensure that a previously published
  local commitment is recognized if it confirms after Eclair switches to a
  different commitment. Previously, Eclair could leave its own balance and
  [HTLC][topic htlc] outputs unclaimed.

- [Eclair #3416][] fixes a bug that allowed a peer to repeatedly obtain
  [on-the-fly funding][topic jit channels] without paying the agreed-upon
  [liquidity advertisement][topic liquidity advertisements] fees. Previously, a
  peer could reject the proposed payments intended to cover these fees, yet
  Eclair could still complete the liquidity purchase. Now, Eclair flags
  underpaid purchases and blocks the peer from making further purchases paid
  from future payments (`from_future_htlc`). Settling other parts of a
  [multipath payment][topic multipath payments] does not clear the flag.
  Flagged peers count toward the existing suspicious-peer limit, which disables
  this payment method globally once it is reached. Flags are cleared on
  restart, through operator intervention, or if the funding transaction is
  aborted before publication.

- [LDK #5314][] fixes a privacy leak in [onion message][topic onion messages]
  forwarding that could link an [unannounced channel][topic unannounced
  channels] to its onchain funding output. An attacker could derive a candidate
  short channel ID (SCID) from an output's blockchain location. By connecting
  to both suspected channel endpoints and sending an onion message through them
  back to itself, the attacker could use the SCID to identify the channel
  between them. Receiving the message would confirm the link between the output
  and the nodes. LDK now refuses to resolve real SCIDs for unannounced channels
  when forwarding onion messages. SCID aliases remain usable. This complements
  the HTLC-forwarding privacy protections covered in [Newsletter #426][news426
  ldk5028].

- [LDK #5412][] fixes a denial-of-service bug in its [LSPS2][BLIP52] server for
  [just-in-time channels][topic jit channels]. Previously, a client could
  submit the same request ID repeatedly while the original request remained
  pending. Each duplicate increased the service-wide pending-request counter
  and replaced the stored entry. Reaching the 1,000-request limit caused the
  LSP to reject requests from other clients, despite having far fewer requests
  to process. Duplicate IDs are now rejected without increasing the counter or
  replacing the original request.

- [LND #11164][] advances its gossip-v2 implementation by updating message
  formats to match the latest [taproot gossip proposal][bolts #1059], which
  would allow nodes to [announce and verify taproot channels][topic channel
  announcements]. Signature-exchange messages now include the funding
  transaction ID to distinguish funding attempts in preparation for
  [splicing][topic splicing] and carry separate [MuSig2][topic musig] partial
  signatures for the node and funding keys. The changes also correct the
  encoding of the fee and capacity fields and preserve optional fields
  containing default values. This preserves the signed bytes when messages are
  decoded and re-encoded, thus preventing signature verification failures.

- [LND #11373][] and [#11380][lnd #11380] enforce LND's existing minimum
  commitment feerate of 253 sat/kw consistently during channel opening and fee
  updates. Previously, setting `max-commit-fee-rate-anchors=1` capped the rate
  at 1 sat/vbyte, equivalent to 250 sat/kw, slightly below the minimum. A
  channel could open at that rate, but it could not carry [HTLCs][topic htlc]
  until its initiator increased the rate because subsequent commitment updates
  would reject it. LND now raises locally proposed opening rates to the minimum
  and rejects incoming proposals below it. It also checks incoming and outgoing
  fee updates against the minimum before recording or sending them, instead of
  only rejecting them when signing commitments. LND attempts to raise the
  feerate of existing channels opened below the minimum, but those channels
  remain unable to carry HTLCs if their initiator cannot afford the increase.

- [BTCPay Server #7744][] and [#7748][btcpay server #7748] fix two errors when
  merchants authorize application API keys. Optional permissions that a
  merchant unchecked could still be granted. Additionally, an application could
  request a permission scoped to another store and have that scope used instead
  of the store selected by the merchant. The fixes preserve the merchant's
  permission choices and remove application-supplied store scopes before
  applying the merchant's store selection. These changes affect key issuance,
  following the permission-enforcement fixes covered in [Newsletter
  #428][news428 btcpay7684]. Previously issued keys retain their permissions
  and may need to be revoked if they grant unintended access.

{% include snippets/recap-ad.md when="2026-11-03 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2070,36665,36667,36669,2130,9627,3417,3419,3416,5314,5412,11164,1059,11373,11380,7744,7748,9082,9115,1333" %}

[sp multi del]: https://delvingbitcoin.org/t/silent-payments-for-multiparty-wallets/2960
[Bitcoin Core 32.1]: https://bitcoincore.org/bin/bitcoin-core-32.1/
[bcc32.1 rn]: https://bitcoincore.org/en/releases/32.1/
[Bitcoin Core 31.2]: https://bitcoincore.org/bin/bitcoin-core-31.2/
[bcc31.2 rn]: https://bitcoincore.org/en/releases/31.2/
[news409 bip323]: /en/newsletters/2026/06/12/#bitcoin-core-34779
[Bitcoin Core 30.4]: https://bitcoincore.org/bin/bitcoin-core-30.4/
[bcc30.4 rn]: https://bitcoincore.org/en/releases/30.4/
[Bitcoin Core 29.5]: https://bitcoincore.org/bin/bitcoin-core-29.5/
[bcc29.5 rn]: https://bitcoincore.org/en/releases/29.5/
[Eclair 0.14.6]: https://github.com/ACINQ/eclair/releases/tag/v0.14.6
[lnd0215]: https://github.com/lightningnetwork/lnd/releases/tag/v0.21.5-beta
[lnd0206]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.6-beta
[core tcp oom]: https://bitcoincore.org/en/2026/10/28/disclose-tcp-oom/
[core paused send oom]: https://bitcoincore.org/en/2026/10/28/disclose-fpausesend-oom/
[core undo overflow]: https://bitcoincore.org/en/2026/10/28/disclose-undo-overflow/
[LDK #5314]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5314
[LDK #5412]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5412
[BIP31]: https://github.com/bitcoin/bips/blob/master/bip-0031.mediawiki
[BLIP52]: https://github.com/lightning/blips/blob/master/blip-0052.md
[news399 metadata]: /en/newsletters/2026/04/03/#draft-bip-for-a-wallet-backup-metadata-format
[news428 releases]: /en/newsletters/2026/10/23/#releases-and-release-candidates
[news426 ldk5028]: /en/newsletters/2026/10/09/#ldk-5028
[news428 btcpay7684]: /en/newsletters/2026/10/23/#btcpay-server-7684
[news427 eclair splicing]: /en/newsletters/2026/10/16/#eclair-3396
[cln selfref dos]: https://delvingbitcoin.org/t/cln-self-referential-channel-announcement-dos-disclosure/2974
[cln 26.04.1]: https://github.com/ElementsProject/lightning/releases/tag/v26.04.1
[news398 cln 26041]: /en/newsletters/2026/05/01/#core-lightning-26-04-1
[bc musig2]: https://learningbitcoin.blockchaincommons.com/18_3_Using_Bitcoin_With_MuSig2/
[news386 bip434]: /en/newsletters/2026/01/02/#peer-feature-negotiation
[news410 bip434]: /en/newsletters/2026/06/19/#bitcoin-core-35221
