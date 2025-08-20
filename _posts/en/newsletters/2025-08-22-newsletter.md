---
title: 'Bitcoin Optech Newsletter #368'
permalink: /en/newsletters/2025/08/22/
name: 2025-08-22-newsletter
slug: 2025-08-22-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a draft BIP for block template sharing
between full nodes and announces a library that allows trusted
delegation of script evaluation (including for features not available in
Bitcoin's native scripting languages).  Also included are our regular
sections describing recent updates to services and client software,
announcing new releases and release candidates, and summarizing notable
changes to popular Bitcoin infrastructure software.

## News

- **Draft BIP for block template sharing:** Anthony Towns [posted][towns
  bipshare] to the Bitcoin-Dev mailing list the [draft][towns bipdraft]
  of a BIP for how nodes can communicate to their peers the transactions
  they would attempt to mine in their next block (see [Newsletter
  #366][news366 templshare]).  This allows the node to share
  transactions it will accept via its mempool and mining policy that its
  peers might normally reject by their own policy, allowing those peers
  to cache those transactions in case they are mined (which improves
  [compact block relay][topic compact block relay] effectiveness).  The
  transactions in a node's block template are usually the most
  profitable unconfirmed transactions known to that node, so peers that
  previously rejected those transactions for policy reasons might also
  find them worthy of additional consideration.

  The protocol specified in the draft BIP is simple.  Shortly after a
  connection with a peer is initiated, the node sends a `sendtemplate`
  message indicating to the peer that it is willing to send block
  templates.  At any later time, the peer can request a template with a
  `gettemplate` message.  In response to the request, the node replies
  with a `template` message that contains a list of short transaction
  identifiers using the same format as a [BIP152][] compact block
  message.  The peer can then request any transactions it wants by
  including the short identifier in a `sendtransactions` message (also
  as in BIP152).  The draft BIP allows templates to be up to slightly
  more than twice the size of the current maximum block weight limit.

  A Delving Bitcoin [thread][delshare] about template sharing saw
  additional discussion this week about how to improve the bandwidth
  efficiency of the proposal.  Ideas discussed included only sending
  only the [difference][towns templdiff] since the previous template (an
  estimated 90% bandwidth savings), using a [set reconciliation][jahr
  templerlay] protocol such as that enabled by [minisketch][topic
  minisketch] (allowing much larger templates to be shared efficiently),
  and using Golomb-Rice [encoding][wuille templgr] on the templates
  similar to [compact block filters][topic compact block filters] (an
  estimated 25% efficiency).

- **Trusted delegation of script evaluation:** Josh Doman [posted][doman
  tee] to Delving Bitcoin about a library he's written that uses a
  _trusted execution environment_ ([TEE][]) that will only sign a
  [taproot][topic taproot] keypath spend if the transaction containing
  that spend satisfies a script.  The script can contain opcodes that
  are not currently active on Bitcoin today or a completely different
  form of script (e.g.  [Simplicity][topic simplicity] or [bll][topic
  bll]).

  This approach requires those receiving funds to the script to trust
  the TEE---both that it will still be available to sign in the future
  and that it will only sign a spend that satisfies its encumbrance
  script---but it allows rapid experimentation with proposed new
  features for Bitcoin with actual monetary value.  To reduce trust in
  the TEE remaining available, a backup spend path can be included; for
  example, a [timelocked][topic timelocks] path that allows a participant
  to unilaterally spend their funds a year after entrusting them to the
  TEE.

  The library is designed for use with the Amazon Web Services (AWS)
  Nitro enclave.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

FIXME:bitschmidty

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [LND v0.19.3-beta][] is a release candidate for a maintenance
  version for this popular LN node implementation containing "important
  bug fixes".  Most notably, "an optional migration [...] lowers disk
  and memory requirements for nodes significantly."

- [Bitcoin Core 29.1rc1][] is a release candidate for a maintenance
  version of the predominant full node software.

- [Core Lightning v25.09rc2][] is a release candidate for a new major
  version of this popular LN node implementation.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #32896][] wallet, rpc: add v3 transaction creation and wallet support

- [Bitcoin Core #33106][] policy: lower the default blockmintxfee, incrementalrelayfee, minrelaytxfee

- [Core Lightning #8467][] xpay: add option to pay bip353.

- [Core Lightning #8354][] xpay: add `pay_part_start` and `pay_part_end` notifications.

- [Eclair #3103][] Simple taproot channels

- [Eclair #3134][] Use actual CLTV delta for reputation

- [LDK #3897][] adi2011/peer-storage/serialise-deserialise

{% include snippets/recap-ad.md when="2025-08-26 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32896,33106,8467,8354,3103,3134,3897" %}
[bitcoin core 29.1rc1]: https://bitcoincore.org/bin/bitcoin-core-29.1/
[lnd v0.19.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.3-beta
[core lightning v25.09rc2]: https://github.com/ElementsProject/lightning/releases/tag/v25.09rc2
[towns bipshare]: https://mailing-list.bitcoindevs.xyz/bitcoindev/aJvZwR_bPeT4LaH6@erisian.com.au/
[towns bipdraft]: https://github.com/ajtowns/bips/blob/202508-sendtemplate/bip-ajtowns-sendtemplate.md
[news366 templshare]: /en/newsletters/2025/08/08/#peer-block-template-sharing-to-mitigate-problems-with-divergent-mempool-policies
[delshare]: https://delvingbitcoin.org/t/sharing-block-templates/1906/13
[towns templdiff]: https://delvingbitcoin.org/t/sharing-block-templates/1906/7
[jahr templerlay]: https://delvingbitcoin.org/t/sharing-block-templates/1906/6
[wuille templgr]: https://delvingbitcoin.org/t/sharing-block-templates/1906/9
[doman tee]: https://delvingbitcoin.org/t/confidential-script-emulate-soft-forks-using-stateless-tees/1918/
[tee]: https://en.wikipedia.org/wiki/Trusted_execution_environment
