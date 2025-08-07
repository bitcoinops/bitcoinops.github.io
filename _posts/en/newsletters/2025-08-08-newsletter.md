---
title: 'Bitcoin Optech Newsletter #366'
permalink: /en/newsletters/2025/08/08/
name: 2025-08-08-newsletter
slug: 2025-08-08-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces draft BIPs for Utreexo, summarizes
continued discussion about lowering the minimum transaction relay
feerate, and describes a proposal to allow nodes to share their block
templates to mitigate problems with divergent mempool policies.  Also
included are our regular sections summarizing a Bitcoin Core PR Review
Club meeting, announcing new releases and release candidates, and
describing notable changes to popular Bitcoin infrastructure projects.
We also include a correction to last week's newsletter and a
recommendation to readers.

## News

- **Draft BIPs proposed for Utreexo:** Calvin Kim [posted][kim bips] to
  the Bitcoin-Dev mailing list to announce three draft BIPs co-authored
  by him along with Tadge Dryja and Davidson Souza about the
  [Utreexo][topic utreexo] validation model.  The [first BIP][ubip1]
  specifies the structure of the Utreexo accumulator, which allows a
  node to store an easily updated commitment to the full UTXO set in as
  little as "just a few kilobytes". The [second BIP][ubip2] specifies
  how a full node can validate new blocks and transactions using the
  accumulator rather than a traditional set of spent transaction outputs
  (STXOs, used in early Bitcoin Core and current libbitcoin) or unspent
  transaction outputs (UTXOs, used in current Bitcoin Core).  The [third
  BIP][ubip3] specifies the changes to the Bitcoin P2P protocol that
  allow transferring the additional data need for Utreexo validation.

  The authors are seeking conceptual review and will be updating the
  draft BIPs based on further developments.

- **Continued discussion about lowering the minimum relay feerate:**
  Gloria Zhao [posted][zhao minfee] to Delving Bitcoin about lowering
  the [default minimum relay feerate][topic default minimum transaction
  relay feerates] by 90% to 0.1 sat/vbyte.  She encouraged conceptual
  discussion about the idea and how it might affect other software.  For
  concerns specific to Bitcoin Core, she linked to a [pull
  request][bitcoin core #33106].

- **Peer block template sharing to mitigate problems with divergent mempool policies:**
  Anthony Towns [posted][towns tempshare] to Delving Bitcoin to suggest
  full node peers occasionally send each other their current template
  for the next block using [compact block relay][topic compact block
  relay] encoding.  The receiving peer could then request any
  transactions from the template that it was missing, either adding them
  to the local mempool or storing them in a cache.  This would allow
  peers with divergent mempool policies to share transactions despite
  their differences.  It provides an alternative to a previous proposal
  that suggested using _weak blocks_ (see [Newsletter #299][news299 weak
  blocks]).  Towns published a [proof-of-concept implementation][towns
  tempshare poc].

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review
Club][] meeting, highlighting some of the important questions and
answers.  Click on a question below to see a summary of the answer from
the meeting.*

[Add exportwatchonlywallet RPC to export a watchonly version of a
wallet][review club 32489] is a PR by [achow101][gh achow101] that
reduces the amount of manual work required to create a watch-only
wallet. Before this change, users had to do that by typing or
scripting `importdescriptors` RPC calls, copying address labels, etc.

Besides public [descriptors][topic descriptors], the
export also contains:
- caches containing derived xpubs when necessary, e.g., in case of
  hardened derivation paths
- address book entries, wallet flags and user labels
- all historical wallet transactions so rescans are unnecessary

The exported wallet database can then be imported with the
`restorewallet` RPC.


{% include functions/details-list.md
  q0="Why can’t the existing `IsRange()`/`IsSingleType()` information tell
  us whether a descriptor can be expanded on the watch-only side?
  Explain the logic behind `CanSelfExpand()` for a) a hardened
  `wpkh(xpub/0h/*)` path and b) a `pkh(pubkey)` descriptor."
  a0="`IsRange()` and `IsSingleType()` were insufficient because they
  don't check for hardened derivation, which requires private keys
  unavailable in a watch-only wallet. `CanSelfExpand()` was added to
  recursively search for hardened paths; if it finds one, it returns
  `false`, signaling that a pre-populated cache must be exported for the
  watch-only wallet to derive addresses. A `pkh(pubkey)` descriptor is
  not ranged and has no derivation, so it can always self-expand."
  a0link="https://bitcoincore.reviews/32489#l-27"

  q1="`ExportWatchOnlyWallet` only copies the descriptor cache if
  `!desc->CanSelfExpand()`. What exactly is stored in that cache? How
  could an incomplete cache affect address derivation on the watch-only
  wallet?"
  a1="The cache stores `CExtPubKey` objects for descriptors with
  hardened derivation paths, which are pre-derived on the spending
  wallet. If this cache is incomplete, the watch-only wallet cannot
  derive the missing addresses because it lacks the necessary private
  keys. This would cause it to fail to see transactions sent to those
  addresses, leading to an incorrect balance."
  a1link="https://bitcoincore.reviews/32489#l-52"

  q2="The exporter sets `create_flags = GetWalletFlags() |
  WALLET_FLAG_DISABLE_PRIVATE_KEYS`. Why is it important to preserve the
  original flags (e.g. `AVOID_REUSE`) instead of clearing everything and
  starting fresh?"
  a2="Preserving flags ensures behavioral consistency between the
  spending and watch-only wallets. For example, the `AVOID_REUSE` flag
  affects which coins are considered available for spending. Not
  preserving it would cause the watch-only wallet to report a different
  available balance than the main wallet, leading to user confusion."
  a2link="https://bitcoincore.reviews/32489#l-68"

  q3="Why does the exporter read the locator from the source wallet and
  write it verbatim into the new wallet instead of letting the new
  wallet start from block 0?"
  a3="The block locator is copied to tell the new watch-only wallet
  where to resume scanning the blockchain for new transactions,
  preventing the need for a complete rescan."
  a3link="https://bitcoincore.reviews/32489#l-93"

  q4="Consider a multisig descriptor `wsh(multi(2,xpub1,xpub2))`. If one
  cosigner exports a watch-only wallet and shares it with a third party,
  what new information does that third party learn compared to just
  giving them the descriptor strings?"
  a4="The watch-only wallet data includes additional metadata such as
  address book, wallet flags and coin-control labels. For wallets with
  hardened derivation, the third party can only get information about
  historical and future transactions through the watch-only wallet
  export."
  a4link="https://bitcoincore.reviews/32489#l-100"

  q5="In `wallet_exported_watchonly.py`, why does the test call
  `wallet.keypoolrefill(100)` before checking spendability across the
  online/offline pair?"
  a5="The `keypoolrefill(100)` call forces the offline (spending) wallet
  to pre-derive 100 keys for its hardened descriptors, populating its
  cache. This cache is then included in the export, allowing the online
  watch-only wallet to generate those 100 addresses. It also ensures the
  offline wallet will recognize these addresses when it receives a PSBT
  to sign."
  a5link="https://bitcoincore.reviews/32489#l-122"
%}

## Optech recommends

[Bitcoin++ Insider][] has begun publishing reader-funded news about
technical Bitcoin topics.  Two of their free weekly newsletters, _Last
Week in Bitcoin_ and _This Week in Bitcoin Core_, may be especially
interesting to regular readers of the Optech newsletter.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [LND v0.19.3-beta.rc1][] is a release candidate for a maintenance version for this popular LN
  node implementation containing "important bug fixes".  Most notably,
  "an optional migration [...] lowers disk and memory requirements for
  nodes significantly."

- [BTCPay Server 2.2.0][] is a release of this popular self-hosted payment
  solution.  It adds support for wallet policies and [miniscript][topic
  miniscript], provides additional support for transaction fee
  management and monitoring, and includes several other new improvements
  and bug fixes.

- [Bitcoin Core 29.1rc1][] is a release candidate for a maintenance
  version of the predominant full node software.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #32941][] completes the overhaul of `TxOrphanage` (see
  [Newsletter #364][news364 orphan]) by enabling automatic trimming of the
  orphanage whenever its limits are exceeded.
  It adds a warning for `maxorphantx` users to inform them that it is obsolete.
  This PR solidifies opportunistic
  one-parent-one-child (1p1c) [package relay][topic package relay].

- [Bitcoin Core #31385][] relaxes the
  `package-not-child-with-unconfirmed-parents` rule of the `submitpackage` RPC
  to improve 1p1c [package relay][topic package relay] usage. Packages
  no longer need to include the parents that are already in the node's mempool.

- [Bitcoin Core #31244][] implements the parsing of [MuSig2][topic musig]
  [descriptors][topic descriptors] as defined in [BIP390][], which is required
  for receiving and spending inputs from [taproot][topic taproot] addresses with
  MuSig2 aggregate keys.

- [Bitcoin Core #30635][] begins displaying the `waitfornewblock`,
  `waitforblock`, and `waitforblockheight` RPCs in the help command
  response, indicating that they're meant for regular users.  This PR
  also adds an optional `current_tip` argument to the `waitfornewblock`
  RPC, to mitigate against race conditions by specifying the block hash
  of the current chain tip.

- [Bitcoin Core #28944][] adds anti-[fee sniping][topic fee sniping] protection
  to transactions sent with the `send` and `sendall` RPC commands by adding a
  random tip-relative [locktime][topic timelocks] if one is not already
  specified.

- [Eclair #3133][] extends its [HTLC endorsement][topic htlc endorsement] local
  peer-reputation system (see [Newsletter #363][news363 reputation]) to score the
  reputation of outgoing peers, just like for incoming peers. Eclair now would
  consider a good reputation in both directions when forwarding an HTLC, but
  doesn’t implement penalties yet. Scoring outgoing peers is necessary to
  prevent sink attacks (see [Newsletter #322][news322 sink]), a specific type of
  [channel jamming attack][topic channel jamming attacks].

- [LND #10097][] introduces an asynchronous, per-peer queue for backlog
  [gossip][topic channel announcements] requests (`GossipTimestampRange`) to
  eliminate the risk of deadlocks when a peer sends too many requests at once.
  If a peer sends a request before the previous one finishes, the additional
  message is quietly dropped. A new `gossip.filter-concurrency` setting (default
  5) is added to limit the number of concurrent workers across all peers. The PR
  also adds documentation explaining how all gossip rate limit configuration
  settings work.

- [LND #9625][] adds a `deletecanceledinvoice` RPC command (and its `lncli`
  equivalent) that allows users to remove canceled [BOLT11][] invoices (see
  [Newsletter #33][news33 canceled]) by providing their payment hash.

- [Rust Bitcoin #4730][] adds an `Alert` type wrapper for the [final alert][]
  message that notifies peers running a vulnerable version of Bitcoin Core
  (before 0.12.1) that their alert system is insecure. Satoshi introduced the
  alert system to notify users of significant network events, but it was
  [retired][] in version 0.12.1, except for the final alert message.

- [BLIPs #55][] adds [BLIP55][] to specify how mobile clients can register for
  webhooks via an endpoint to receive push notifications from an LSP. This
  protocol is useful for clients to get notified when receiving an [async
  payment][topic async payments], and was recently implemented in LDK (See
  [Newsletter #365][news365 webhook]).

## Correction

In [last week's newsletter][news365 p2qrh], we incorrectly described the
updated version of [BIP360][], _pay to quantum-resistant hash_, as
"making exactly the change" that Tim Ruffing showed was secure in his
[recent paper][ruffing paper].  What BIP360 actually does is replace the elliptic
curve commitment to a SHA256-based merkle root (plus a keypath
alternative) with a SHA256 commitment directly to the merkle root.  Ruffing's paper showed that
taproot, as currently used, is secure if a quantum-resistant signature
scheme were added to the [tapscript][topic tapscript] language and
keypath spends were disabled.  BIP360 instead requires that wallets upgrade
to a variant on taproot (albeit, a trivial variant), eliminates the
keypath mechanism from its variant, and describes the addition of a
quantum-resistant signature scheme to the scripting language used in its
tapleaves.  Although Ruffing's paper does not apply to the variant of
taproot proposed in BIP360, the security of this variant (when viewed as
a commitment) follows immediately from the security of the merkle tree.

We apologize for the error and thank Tim Ruffing for notifying us about
our mistake.

{% include snippets/recap-ad.md when="2025-08-12 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33106,32941,31385,31244,30635,28944,3133,10097,9625,4730,55" %}
[bitcoin core 29.1rc1]: https://bitcoincore.org/bin/bitcoin-core-29.1/
[bitcoin++ insider]: https://insider.btcpp.dev/
[news365 p2qrh]: /en/newsletters/2025/08/01/#security-against-quantum-computers-with-taproot-as-a-commitment-scheme
[zhao minfee]: https://delvingbitcoin.org/t/changing-the-minimum-relay-feerate/1886/
[towns tempshare]: https://delvingbitcoin.org/t/sharing-block-templates/1906
[towns tempshare poc]: https://github.com/ajtowns/bitcoin/commit/ee12518a4a5e8932175ee57c8f1ad116f675d089
[news299 weak blocks]: /en/newsletters/2024/04/24/#weak-blocks-proof-of-concept-implementation
[ruffing paper]: https://eprint.iacr.org/2025/1307
[kim bips]: https://mailing-list.bitcoindevs.xyz/bitcoindev/3452b63c-ff2b-4dd9-90ee-83fd9cedcf4an@googlegroups.com/
[ubip1]: https://github.com/utreexo/biptreexo/blob/7ae65222ba82423c1a3f2edd6396c0e32679aa37/utreexo-accumulator-bip.md
[ubip2]: https://github.com/utreexo/biptreexo/blob/7ae65222ba82423c1a3f2edd6396c0e32679aa37/utreexo-validation-bip.md
[ubip3]: https://github.com/utreexo/biptreexo/blob/7ae65222ba82423c1a3f2edd6396c0e32679aa37/utreexo-p2p-bip.md
[btcpay server 2.2.0]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.2.0
[lnd v0.19.3-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.3-beta.rc1
[review club 32489]: https://bitcoincore.reviews/32489
[gh achow101]: https://github.com/achow101
[news363 reputation]: /en/newsletters/2025/07/18/#eclair-2716
[news322 sink]: /en/newsletters/2024/09/27/#hybrid-jamming-mitigation-testing-and-changes
[news33 canceled]: /en/newsletters/2019/02/12/#lnd-2457
[final alert]: https://bitcoin.org/en/release/v0.14.0#final-alert
[retired]: https://bitcoin.org/en/alert/2016-11-01-alert-retirement#updates
[news365 webhook]: /en/newsletters/2025/08/01/#ldk-3662
[news364 orphan]: /en/newsletters/2025/07/25/#bitcoin-core-31829