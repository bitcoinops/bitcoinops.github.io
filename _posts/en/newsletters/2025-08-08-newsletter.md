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

FIXME:stickies-v

{% include functions/details-list.md
  q0="FIXME"
  a0="FIXME"
  a0link="https://bitcoincore.reviews/31829#l-12FIXME"
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

- [Bitcoin Core #32941][] p2p: TxOrphanage revamp cleanups

- [Bitcoin Core #31385][] package validation: relax the package-not-child-with-unconfirmed-parents rule

- [Bitcoin Core #31244][] descriptors: MuSig2

- [Bitcoin Core #30635][] rpc: add optional blockhash to waitfornewblock, unhide wait methods in help

- [Bitcoin Core #28944][] wallet, rpc: add anti-fee-sniping to `send` and `sendall`

- [Eclair #3133][] Add outgoing reputation

- [LND #10097][] Roasbeef/gossip-block-fix

- [LND #9625][] Add deletecanceledinvoice RPC call

- [Rust Bitcoin #4730][] p2p: Add formal `Alert` type

- [BLIPs #55][] Webhook Registration (LSPS5) (#55)

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
