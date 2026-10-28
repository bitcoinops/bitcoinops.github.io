---
title: 'Bitcoin Optech Newsletter #428'
permalink: /en/newsletters/2026/10/23/
name: 2026-10-23-newsletter
slug: 2026-10-23-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a design for a single-issuer layer 2 whose
users can redeem their bitcoin onchain without the issuer's cooperation and
summarizes a proposal for including hash preimages in output script
descriptors. Also included are our regular sections describing recent changes
to services and client software, announcing new releases and release
candidates, and describing notable changes to popular Bitcoin infrastructure
software.

## News

- **Trust-minimized exits from a single-issuer layer 2:** Adam Gibson
  [posted][lichen ml] to the Bitcoin-Dev mailing list a [paper][lichen paper]
  and proof-of-concept [code][lichen repo] for Lichen, a design in which a
  single issuer, which Gibson calls a hub, mints tokens redeemable one-to-one
  for bitcoin on a layer 2 ledger run by a server called the sequencer. Each
  user holds a 2-of-2 contract with the hub that lets them redeem their tokens
  even if the hub refuses or is offline, so users trust the sequencer to run the
  ledger honestly but not the hub to return their bitcoin. The design builds on
  LN-GAP (see [Newsletter #427][news427 lngap]) but replaces its honest-majority
  attestation committee with a dispute settled entirely onchain.

  Each user locks bitcoin in their own 2-of-2 output with the hub and receives
  the same amount of tokens on the layer 2 ledger, where users pay each other
  without touching the chain. To exit, a user hands tokens back to the hub and
  collects bitcoin from their own output. Because that output is the only one a
  user can draw on, the hub also locks some of its own bitcoin in each output up
  to a negotiated cap, like LN inbound liquidity, so that the user can redeem
  tokens received from others. Tokens received beyond the cap are redeemable
  only at the hub's discretion.

  In the cooperative case, the hub simply signs a settlement of the output
  paying the user. If it refuses or does not respond, the user generates a
  Groth16 proof that the sequencer signed a state recording the returned tokens.
  Since Script cannot verify such a proof, the user instead claims onchain that
  a fixed verifier program accepts it, and if the hub disputes that, presigned
  [BitVMX][topic acc] transactions narrow the disagreement to a single execution
  step that Script can check. Each side locks a reserve that it forfeits by
  losing a dispute, deterring false claims and refusals. Gibson acknowledges
  that a sequencer that omits a user's return, or signs a state it never validly
  reached, can still cost the user or the hub funds, and lists validity proofs
  and a committee of sequencers as future work. {% assign timestamp="1:32" %}

- **Descriptor syntax for hash preimages:** João Dias [posted][desc del] to
  Delving Bitcoin a proposal for extending [BIP379][] to add a private form
  for hash fragments to [miniscript][topic miniscript]. As of today, there is
  no way to directly give a preimage to Bitcoin Core's wallet to spend funds
  that need one to satisfy a spending condition. It is only possible to
  provide it through external tools in one of the [PSBT][topic psbt] hash
  fields (e.g. `PSBT_IN_SHA256`). The author noted that this proposal only
  covers the preimages already known when a descriptor is created, not
  those learned at spend time, such as in a [HTLC][topic htlc].

  Dias explained that the preimage should be treated more like a key
  than a signature, highlighting an inconsistency in the
  [descriptor][topic descriptors] model. His idea aims to let a wallet import
  a secret from a descriptor and build and sign a transaction directly.
  To do so, the author proposed a specific syntax for the descriptor (e.g.
  `sha256(preimage(HEX))`) and a set of boundaries, such as the need for
  a specific marker instead of raw hex, a fixed size of 32 bytes for all the
  hash fragments, and the requirement to handle the preimage like any other secret,
  with backups, encryption, and never shown in the public descriptor string.

  Before proceeding to formalize the proposal, Dias highlighted some open
  points that need to be addressed, such as what the marker syntax should be , whether
  to amend BIP379 or draft a new BIP, if it is necessary to add an RPC call for
  Bitcoin Core to manage preimages, whether hardware signing devices should handle
  preimage secrets or this should remain software-wallet-only, and if there is any
  interest in deterministically deriving preimages from key material. {% assign timestamp="18:03" %}

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Ibis Wallet v5.0-beta released:** [Ibis Wallet v5.0-beta][ibis v5.0] (see
  [Newsletter #406][news406 ibis]) adds [Ark][topic ark] support built on Bark,
  unilateral exits from the Spark [statechain][topic statechains], and receiving
  to [silent payment][topic silent payments] addresses. {% assign timestamp="26:31" %}

- **Landfall wallet for Lightning mining payouts:** [Landfall][landfall gh] is a
  proof-of-concept wallet, showing UX achievable today, that derives from a single seed the payout address,
  [BOLT12 offer][topic offers], and [BIP322][topic generic signmessage]
  signature that the OCEAN mining pool requires to pay rewards over LN, using a
  Lexe-hosted node (see [Newsletter #419][news419 lexe]). It is not intended for
  production use. {% assign timestamp="28:57" %}

- **rbitcoin 0.8.0 released:** [rbitcoin 0.8.0][rbitcoin 0.8.0] is a Bitcoin
  full node written in Rust and built on rust-bitcoin, described as entirely AI-written, for wallet and Lightning
  backends that replaces the UTXO set with a relational archive, serves Electrum
  and Esplora-style APIs, and uses [BIP324][topic v2 p2p transport] exclusively. {% assign timestamp="38:44" %}

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Eclair 0.14.4][] and [0.14.5][Eclair 0.14.5] are security releases for this
  LN node implementation. Version 0.14.4 fixes several issues related to
  [splicing][topic splicing], [HTLC][topic htlc] settlement, [on-the-fly
  funding][topic jit channels], and onion parsing, as described in [Newsletter
  #427][news427 eclair fixes]. It also rejects API requests with an `Origin`
  header to prevent cross-site request forgery using cached HTTP Basic
  authentication credentials (see [Newsletter #423][news423 eclair api]).
  Browser-based integrations must now use their own backend to call Eclair.
  Version 0.14.5 fixes the trampoline routing and taproot splicing
  vulnerabilities described below, and closes an integer-overflow bypass of the
  onion payload length validation covered in [Newsletter #427][news427 eclair
  onion]. The project strongly recommends upgrading. {% assign timestamp="43:18" %}

- [BDK chain 0.23.4][] is a maintenance release of BDK's libraries for building
  Bitcoin wallets. It fixes issues with transaction tracking and full scans
  that stop before checking all previously revealed addresses. Accompanying
  updates fix Bitcoin Core RPC synchronization after reorgs and include
  previously covered Electrum fixes for [txid verification][news403 bdk txid],
  [confirmation detection for transactions with an `OP_RETURN` first
  output][news405 bdk opreturn], and [confirmation tracking after
  reorgs][news427 bdk reorg]. {% assign timestamp="45:37" %}

- [LND v0.21.5-beta.rc1][] and [v0.20.6-beta.rc1][LND v0.20.6-beta.rc1] are
  release candidates for maintenance versions of this popular LN node
  implementation. Both include the fee-update handling and channel-message
  limits described in [Newsletter #418][news418 lnd fees], along with fixes for
  commitment feerates, excessive memory allocation when parsing TLV records,
  and SQL database deadlocks. Version 0.21.5 also includes the auxiliary
  [HTLC][topic htlc] signature validation fix for [Taproot Assets][topic
  client-side validation] channels described in [Newsletter #427][news427 lnd
  aux], and fixes wallet synchronization during blockchain reorganizations. {% assign timestamp="47:09" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Eclair #3409][] fixes a vulnerability that could allow a malicious payer to
  steal funds from a node forwarding [trampoline payments][topic trampoline
  payments]. Eclair now limits the total [CLTV expiry delta][topic cltv expiry
  delta] of a downstream route to ensure that the outgoing HTLC expires before
  the incoming HTLC (see [Newsletter #423][news423 eclair cltv] for a related
  fix). Previously, when pathfinding failed, Eclair would retry with relaxed
  limits on route length and expiry, allowing a payer to provide routing hints
  or [blinded paths][topic rv routing] with excessive expiry deltas. The payer
  could then reclaim the incoming HTLC onchain after it expired, while the
  receiver could still claim the outgoing HTLC. Eclair now only relaxes the
  route-length limit, preserving the required expiry ordering. {% assign timestamp="50:16" %}

- [Eclair #3411][] fixes a vulnerability that could allow a malicious channel
  peer to steal funds by making Eclair sign an invalid [splice][topic splicing]
  transaction (see [Newsletter #427][news427 eclair splice] for related fixes).
  When splicing [simple taproot channels][topic simple taproot channels], a
  peer can only provide the amount and script of an input's previous output
  instead of the full transaction. Previously, Eclair trusted these values
  without verifying them. A peer could lie about either field, causing Eclair
  to sign a splice transaction that could never confirm because taproot
  signatures commit to the actual amounts and scripts of the spent inputs.
  Nevertheless, Eclair would treat the invalid splice as its latest channel
  funding state. The peer could then publish a previously signed commitment
  spending the previous funding output and claim an outgoing [HTLC][topic htlc]
  using its payment preimage after Eclair's corresponding incoming HTLC had
  timed out and been refunded, leaving Eclair unable to collect the forwarded
  payment. Eclair now verifies the claimed outputs against its Bitcoin backend
  before signing. {% assign timestamp="52:20" %}

- [LDK #5126][] fixes a bug where [BOLT12][topic offers] payments using one-hop
  [blinded paths][topic rv routing] could be rejected because their HTLC expiry
  was too short. Previously, LDK ignored the path's `cltv_expiry_delta` because
  the introduction node was also the receiver. This overlooked the fact that it
  includes the receiver's required [final CLTV delta][topic cltv expiry delta].
  Consequently, payments only met the receiver's minimum requirement when LDK's
  random CLTV offset was large enough. This caused intermittent payment
  failures when testing against Core Lightning. LDK now includes the advertised
  delta when constructing the route and checking its maximum permitted total
  CLTV delta. {% assign timestamp="55:03" %}

- [LND #10919][] adds an experimental local reputation system to mitigate
  [channel jamming attacks][topic channel jamming attacks], based on the
  proposed HTLC accountability scheme (see Newsletters [#377][news377 jamming]
  and [#387][news387 accountability]), which replaces the earlier [HTLC
  endorsement][topic htlc endorsement] approach. The system scores outgoing
  channels based on past forwarding activity and the node's advertised fees,
  penalizing accountable [HTLCs][topic htlc] that take too long to resolve. The
  system is enabled by default and logs whether HTLCs would qualify for
  protected resources, without affecting forwarding decisions. Reputation
  resets on restart. {% assign timestamp="56:19" %}

- [BTCPay Server #7679][] fixes a bug that could lead to duplicate Lightning
  payouts. Previously, if a payout was initiated and a subsequent payment
  lookup returned no results, BTCPay Server would cancel the payout and discard
  its saved payment hash. This occurred even if the payment had succeeded.
  Consequently, an operator could issue another payout for a payment that had
  already succeeded. BTCPay Server now retains payouts in progress and their
  payment hashes for subsequent checks. {% assign timestamp="1:01:06" %}

- [BTCPay Server #7684][] fixes a privilege escalation in its Greenfield API
  key authorization. Previously, an API key restricted to a particular store
  could exercise server-wide or account-wide permissions despite its limited
  scope. Additionally, a key authorized to create API keys for other users
  could also grant permissions broader than its own. BTCPay Server now enforces
  permission scopes when authorizing requests and prevents API keys from
  granting permissions they do not possess. Existing unrestricted administrator
  keys retain their intended capabilities. {% assign timestamp="1:02:39" %}

- [BDK #2325][] and [#2360][bdk #2360] fix two bugs that could cause the wallet
  to report successful synchronization without retrieving the requested
  transaction data. The first affects Electrum synchronization of individual
  outpoints. Previously, BDK ignored all errors encountered when fetching their
  transactions, including connection failures and timeouts. This could cause a
  spent output to remain classified as unspent. BDK now ignores Electrum
  protocol errors on this path while propagating other failures. The second PR
  fixes `sync` and `full_scan` in the Electrum and Esplora clients. Previously,
  setting Electrum's `batch_size` or Esplora's `parallel_requests` to zero
  could silently skip requested scans or transaction fetches while reporting
  success. Both clients now treat zero as one for these parameters. {% assign timestamp="1:04:18" %}

- [BOLTs #1357][] updates [BOLT11][] to require invoice readers to reject
  invoices unless they contain exactly one payment hash (`p`) and one payment
  secret (`s`) field. Previously, the specification recommended that payers use
  the first `p` field, while some invoice parsers used the last. This
  discrepancy was [exploited against LNP2PBot][lnp2p incident], whose invoice
  parser and Lightning node selected different payment hashes. Consequently,
  the bot treated completed payouts as unpaid, allowing attackers to obtain
  duplicate payouts (see [Newsletter #425][news425 lnd]). {% assign timestamp="1:07:13" %}

- [BOLTs #1352][] corrects several errors in the [simple taproot
  channels][topic simple taproot channels] specification and test vectors (see
  [Newsletter #404][news404 taproot]). Errors in taproot output-key derivation
  and control-block construction could produce invalid spends if implemented as
  previously specified. The PR also clarifies that [HTLC][topic htlc]
  signatures exchanged in `commitment_signed` use
  `SIGHASH_SINGLE|SIGHASH_ANYONECANPAY`: the receiving peer appends `0x83` to
  the 64-byte signature when constructing the witness. When combining
  second-level transactions for fee bumping, each HTLC input and its
  corresponding output must occupy matching indices in the combined
  transaction. Additional corrections cover [anchor spending paths][topic
  anchor outputs], [MuSig2][topic musig] nonce encoding and derivation, and
  local and remote commitment test vectors. These changes align the
  specification with existing LND and Eclair implementations without changing
  protocol behavior. {% assign timestamp="1:10:03" %}

{% include snippets/recap-ad.md when="2026-10-27 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3409,3411,5126,10919,7679,7684,2325,2360,1357,1352" %}

[lichen ml]: https://groups.google.com/g/bitcoindev/c/yZEZ5P1lj5E
[lichen paper]: https://github.com/AdamISZ/lichen/blob/master/papers/lichen-v0.1.pdf
[lichen repo]: https://github.com/AdamISZ/lichen
[news427 lngap]: /en/newsletters/2026/10/16/#offchain-contracts-in-lightning-channels
[ibis v5.0]: https://github.com/aeonBTC/IbisWallet/releases/tag/v5.0.1-beta
[news406 ibis]: /en/newsletters/2026/05/22/#ibis-wallet-announced
[landfall gh]: https://github.com/vincenzopalazzo/landfall
[news419 lexe]: /en/newsletters/2026/08/21/#lexe-adds-human-readable-addresses-and-lnurl-withdraw
[rbitcoin 0.8.0]: https://github.com/reardencode/rbitcoin/releases/tag/v0.8.0
[desc del]: https://delvingbitcoin.org/t/descriptor-syntax-for-hash-preimages/2935
[Eclair 0.14.4]: https://github.com/ACINQ/eclair/releases/tag/v0.14.4
[Eclair 0.14.5]: https://github.com/ACINQ/eclair/releases/tag/v0.14.5
[BDK chain 0.23.4]: https://github.com/bitcoindevkit/bdk/releases/tag/chain-0.23.4
[LDK #5126]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5126
[lnp2p incident]: https://x.com/negrunch/status/2097763741123166576
[news423 eclair api]: /en/newsletters/2026/09/18/#eclair-3380
[news427 eclair fixes]: /en/newsletters/2026/10/16/#notable-code-and-documentation-changes
[news427 eclair onion]: /en/newsletters/2026/10/16/#eclair-3395
[news403 bdk txid]: /en/newsletters/2026/05/01/#bdk-2188
[news405 bdk opreturn]: /en/newsletters/2026/05/15/#bdk-2195
[news427 bdk reorg]: /en/newsletters/2026/10/16/#bdk-2319
[news423 eclair cltv]: /en/newsletters/2026/09/18/#eclair-3376
[news427 eclair splice]: /en/newsletters/2026/10/16/#eclair-3396
[news377 jamming]: /en/newsletters/2025/10/24/#channel-jamming-mitigation-simulation-results-and-updates
[news387 accountability]: /en/newsletters/2026/01/09/#lnd-10367
[news425 lnd]: /en/newsletters/2026/10/02/#lnd-11190
[news404 taproot]: /en/newsletters/2026/05/08/#bolts-995
[LND v0.21.5-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.21.5-beta.rc1
[LND v0.20.6-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.6-beta.rc1
[news418 lnd fees]: /en/newsletters/2026/08/14/#lnd-11023
[news427 lnd aux]: /en/newsletters/2026/10/16/#lnd-11068
