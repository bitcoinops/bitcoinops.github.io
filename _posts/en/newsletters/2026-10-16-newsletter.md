---
title: 'Bitcoin Optech Newsletter #427'
permalink: /en/newsletters/2026/10/16/
name: 2026-10-16-newsletter
slug: 2026-10-16-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes the disclosure of two denial-of-service
vulnerabilities in older versions of Eclair and describes a proposed scheme for
running complex multi-round contracts inside Lightning channels. Also included
are our regular sections announcing new releases and release candidates and
describing notable changes to popular Bitcoin infrastructure software.

## News

- **Disclosure of two DoS vulnerabilities fixed in Eclair v0.14.1**: Erick
  Cestari [posted][ec eclair dos] to Delving Bitcoin the [responsible
  disclosure][topic responsible disclosures] of two denial-of-service (DoS)
  vulnerabilities in the channel opening process of Eclair v0.14.0 and earlier.
  Both were fixed in [Eclair #3324][] and released in [v0.14.1][news416 eclair
  0.14.1] in July, and users running an older version should upgrade.

  The first, found by Matt Morehouse with his [smite][smite repo] fuzzer, is a
  race condition in a duplicate `temporary_channel_id` check. Eclair checked
  whether the ID was already in use before accepting an `open_channel` message,
  but did not record the new channel until a later step, so an attacker sending
  several identical `open_channel` messages in quick succession could get two
  past the check. Eclair then created two channel states for one ID, and the
  second replaced the first, leaving an unreachable channel state that held
  about 25 kB of memory until the peer disconnected. Repeating the attack leaked
  about 1 MB per second until the node ran out of memory or spent all of its CPU
  on garbage collection.

  The second, found by Cestari, bypasses Eclair's limit on the number of pending
  channels whose funding transaction has not confirmed. The duplicate check only
  looked at temporary IDs, so an attacker could start opening a channel, then
  reuse that channel's final `channel_id` as the `temporary_channel_id` of the
  next `open_channel`. The limiter counted the reused ID twice and dropped both
  entries once the new channel received its final ID, so its count never rose
  above two while the number of pending channels grew without bound. Each
  pending channel stores a copy of the peer's `init` features, and setting a
  single unknown odd feature bit at a very high position inflated that copy to
  about 65 kB. In Cestari's test, one connection with no onchain cost exhausted
  a node's 4 GB of memory in about 48 minutes. Because pending channels are
  written to the database, the node crashed again on every restart until its
  memory limit was raised or the rows were deleted by hand.

  Replying to a question, Morehouse noted that mobile wallets that use an Eclair
  node as their LSP, such as Phoenix, are unaffected because ACINQ patched its
  nodes months ago.

- **Offchain contracts in Lightning channels**: Adam Gibson [posted][lngap ml]
  to the Bitcoin-Dev mailing list about a proposal for protocol,
  called LN-GAP, to run complex, multi-round, two-party contracts inside a
  Lightning channel while settling disputes onchain in a constant number of
  transactions. In order to showcase the proposal, Gibson implemented a game
  of chess, which he deems a good example of a game that is difficult to run
  onchain, in which the winner takes the whole pot. Both a [repository][lngap repo]
  and a [paper][lngap paper] for the proposal are available.

  Two players, Alice and Bob, agree on a certain set of rules. Each player makes
  their own moves. In case of a dispute, Alice can enforce the rules onchain.
  However, Gibson notes that Lightning can enforce rules about a published state,
  but it cannot do so in case a counterparty stalls or stops responding.
  To address this issue, Gibson introduces a venue, a committee of members whose
  role is to attest whether a signed message (a move in a chess game and its
  signature) was published before a certain deadline or not. The venue only needs
  to attest the timeliness of the publication, not the content of the message.
  In case of a dispute, Alice posts a transaction claiming that no event was
  published by Bob; in turn, Bob can post a second transaction containing a
  rebuttal (his move and the venue's attestation); finally, Alice can post a
  disproof, stating that Bob's rebuttal doesn't stand due to the event not being
  compliant with the rules.

  In Gibson's proposal, the venue never holds users' funds. Moreover, it avoids
  relying on FROST-style threshold signature in order to make fraud attributable
  only to malicious members. To do so, attestation is done through per-member
  "one-bit signatures" checked using `OP_CHECKSIGADD`. Members are incentivized
  by fees paid atomically over channels using [adaptors][topic adaptor signatures].
  However, the construction relies on an honest-majority assumption. If more than
  half of the members of the venue collude with one of the parties involved, funds
  can be stolen.

  Other than games, possible applications include proof-of-storage
  contracts, where a provider forfeits a bond for failing to respond to a
  challenge, and offchain dispute resolution similar to what
  [BitVMX][topic acc]-style zero-knowledge verifiers do onchain.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Bitcoin Core 32.0rc4][] is a release candidate for the next major version of
  the predominant full node implementation. A [testing guide][bcc32 testing] is
  available.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Eclair #3396][], [#3397][eclair #3397], and [#3400][eclair #3400] fix
  several ways a malicious channel peer could prevent Eclair from enforcing
  [HTLCs][topic htlc] onchain during [splicing][topic splicing] (see
  [Newsletter #423][news423 eclair splice]). Previously, a peer could make
  Eclair sign a splice transaction that could not be published promptly by
  choosing a distant absolute locktime, adding inputs with [relative
  timelocks][topic timelocks], providing nonstandard witnesses, exceeding the
  standard transaction weight limit, or setting the signed transaction's
  feerate too low. The first PR adds checks for these cases. The second makes
  Eclair retry commitment and [penalty transactions][topic ln-penalty] that
  were rejected by a conflicting unconfirmed transaction, as the peer may later
  replace that transaction through [RBF][topic rbf] by double-spending one of
  its other inputs. The retry fix also applies when the channel's funding
  transaction is unconfirmed, including [zero-conf channels][topic zero-conf
  channels]. The third fixes another recovery gap: if an RBF replacement of a
  splice confirms after Eclair force-closes using a commitment for a sibling
  attempt, Eclair now recognizes that the funding transaction has changed and
  broadcasts a commitment transaction that spends the confirmed splice output.
  Previously, funds could remain locked and HTLCs unenforced.

- [Eclair #3399][] and [#3394][eclair #3394] fix two ways [on-the-fly
  funding][topic jit channels] could leave Eclair paying a downstream peer
  without collecting the corresponding incoming [HTLC][topic htlc] (see
  [Newsletter #419][news419 eclair funding]). Previously, after Eclair stopped
  tracking an expired payment, a new payment could reuse its payment hash. If
  the downstream peer then claimed the original outgoing HTLC onchain,
  revealing the preimage, Eclair could mistakenly fulfill the newer payment's
  incoming HTLCs instead of the original ones, allowing the original incoming
  HTLCs to time out without paying Eclair. The first PR now checks if a
  settlement belongs to the currently tracked payment and, if not, it uses the
  incoming HTLC details retained with the settlement to fulfill the correct
  HTLCs. The second PR ensures that funded payments are only forwarded over the
  channel where liquidity was purchased. Previously, Eclair could forward over
  another channel with the same peer, but would only check the funded channel
  before failing upstream at expiry, even though the outgoing HTLC on the other
  channel remained claimable.

- [Eclair #3395][] fixes a bug where a spender could construct a malformed
  payment onion packet with a valid HMAC that left an incoming [HTLC][topic
  htlc] unresolved. The spender could encode a per-hop payload length larger
  than the packet's actual capacity while still providing a valid HMAC.
  Previously, Eclair did not validate the length before extracting the next
  HMAC, causing an uncaught exception. The relayer would then resume without
  failing the HTLC, and the malformed packet could also prevent HTLC cleanup
  from initializing after a restart. Now, Eclair checks that the per-hop
  payload, including its HMAC, fits within the packet. If it does not, Eclair
  returns `InvalidOnionVersion`, allowing normal failure handling.

- [Eclair #3401][] fixes a bug that could cause a forwarding node to lose funds
  after a disconnection. Eclair stores instructions to fulfill or fail
  [HTLCs][topic htlc] until the corresponding channel updates are signed,
  allowing them to be retried after reconnection. Previously, if a duplicate or
  conflicting instruction was rejected because a fulfillment had already been
  proposed but not signed, Eclair scheduled the deletion of the original stored
  instruction. If the channel disconnected before signing, the unsigned update
  was discarded, leaving no instruction to replay the fulfillment. The incoming
  HTLC could then time out even though the outgoing HTLC had already been
  fulfilled. Eclair now retains the original instruction until the settlement
  is signed.

- [LDK #5080][] fixes a bug where restarting during cooperative channel close
  could prevent pending [HTLCs][topic htlc] from being failed back to their
  upstream peer. Previously, when LDK restarted, it excluded channels
  undergoing cooperative close from the lookup used to process HTLCs, even
  though those channels could still have unresolved payments. Consequently,
  when a downstream peer failed an HTLC, LDK could mistakenly treat the
  upstream channel as nonexistent and discard the failure. LDK could also drop
  incoming HTLCs awaiting onion decoding. This could leave HTLCs unresolved
  until the upstream peer force-closed the channel at expiry. LDK now includes
  channels undergoing shutdown when restoring the information needed to resolve
  existing HTLCs.

- [LDK #5087][] fixes a potential privacy leak in [onion messages][topic onion
  messages] sent over [blinded paths][topic rv routing] that use dummy hops
  (see [Newsletter #370][news370 dummy hops]). Dummy hops are additional
  encrypted layers that the recipient processes to obscure its position in the
  path. Previously, forwarding hops rejected intermediate onion layers
  containing message-content TLV records, but dummy hops accepted them. A
  malicious sender could insert these records at different, nonfinal layers and
  observe whether the final message produced a response, potentially revealing
  where the actual forwarding ended and the dummy hops began. LDK now rejects
  message-content records at dummy hops as well.

- [LND #11068][] fixes a missing check for auxiliary [HTLC][topic htlc]
  signatures on experimental taproot overlay channels used for [Taproot
  Assets][topic client-side validation] (see [Newsletter #324][news324
  overlay]). In these channels, a Taproot Assets signer (`tapd`) provides an
  additional signature entry for each non-[dust][topic uneconomical outputs]
  HTLC alongside the usual Bitcoin signatures. Previously, if a peer sent a
  commitment containing the required Bitcoin signatures but omitted some or all
  of the auxiliary HTLC signature entries, the receiving LND node would
  incorrectly accept it. If the channel is later force-closed, the missing
  signatures could prevent the affected asset HTLCs from being resolved
  onchain. LND now verifies that the number of received auxiliary signature
  entries matches the number of non-dust HTLCs. If they differ, LND rejects the
  commitment and force-closes the channel.

- [Rust Bitcoin #6956][] introduces a `ScriptCode` type for the script data
  used in legacy and segwit v0 signature hashing, which may differ from the
  full script being spent. According to [BIP143][], when a P2WSH script
  contains [OP_CODESEPARATOR][topic OP_CODESEPARATOR], signature hashing
  excludes everything up to and including the last separator executed before
  the signature check, while retaining any subsequent separators. Previously,
  `p2wsh_signature_hash` accepted a witness script, which could lead callers to
  hash the complete script and produce an invalid signature. The API now
  accepts `ScriptCode`, but callers must still identify the last executed
  separator and shorten the script themselves. The PR also adds
  `P2wpkhScriptCode`, a fixed-size, allocation-free representation of the
  standard script used to sign P2WPKH inputs.

- [BDK #2319][] fixes a bug where an Electrum-backed wallet could lose track of
  a transaction's confirmation after a reorg if the same transaction was mined
  again at the same height. BDK could retain the displaced block's header in
  its cache and fail to recognize the transaction's confirmation in the
  replacement block, incorrectly showing it as unconfirmed. The fix refreshes
  the header cache with newly fetched block headers during synchronization,
  including after a one-block reorg.

{% include snippets/recap-ad.md when="2026-10-20 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3324,3396,3397,3400,3399,3394,3395,3401,5080,5087,11068,6956,2319" %}

[ec eclair dos]: https://delvingbitcoin.org/t/disclosure-dos-vulnerabilities-fixed-in-eclair-v0-14-1/2928
[news416 eclair 0.14.1]: /en/newsletters/2026/07/31/#eclair-0-14-1
[smite repo]: https://github.com/lnfuzz/smite
[lngap ml]: https://groups.google.com/g/bitcoindev/c/pjv6bL_42kg
[lngap repo]: https://github.com/AdamISZ/ln-gap
[lngap paper]: https://github.com/AdamISZ/ln-gap/blob/master/docs/paper/lngap-short.pdf
[Bitcoin Core 32.0rc4]: https://bitcoincore.org/bin/bitcoin-core-32.0/test.rc4/
[bcc32 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/32.0-Release-Candidate-Testing-Guide
[LDK #5080]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5080
[LDK #5087]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5087
[news324 overlay]: /en/newsletters/2024/10/11/#lnd-8960
[news370 dummy hops]: /en/newsletters/2025/09/05/#ldk-3726
[news423 eclair splice]: /en/newsletters/2026/09/18/#eclair-3376
[news419 eclair funding]: /en/newsletters/2026/08/21/#eclair-3351
