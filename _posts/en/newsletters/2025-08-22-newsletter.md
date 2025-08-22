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

- **ZEUS v0.11.3 released:**
  The [v0.11.3][zeus v0.11.3] release includes improvements to peer
  management, [BOLT12][topic offers], and [submarine swap][topic submarine swaps]
  features.

- **Rust Utreexo resources:**
  Abdelhamid Bakhta [posted][abdel tweet] Rust-based resources for
  [Utreexo][topic utreexo], including interactive [educational
  materials][rustreexo webapp] and [WASM bindings][rustreexo wasm].

- **Peer-observer tooling and call to action:**
  0xB10C [posted][b10c blog] about the motivation, architecture, code,
  supporting libraries, and findings of his [peer-observer][peer-observer
  github] project. He seeks to build "A loose, decentralized group of people who
  share the interest of monitoring the Bitcoin Network. A collective to enable
  sharing of ideas, discussion, data, tools, insights, and more."

- **Bitcoin Core Kernel-based node announced:**
  Bitcoin backbone was [announced][bitcoin backbone] as a demonstration of using
  the [Bitcoin Core Kernel][kernel blog] library as the foundation of a Bitcoin node.

- **SimplicityHL released:**
  [SimplicityHL][simplcityhl github] is a Rust-like programming language that
  compiles to the lower-level [Simplicity][simplicity] language [recently
  activated][simplicity post] on Liquid. For further reading, see the [related
  Delving thread][simplicityhl delving].

- **LSP plugin for BTCPay Server:**
  The [LSP plugin][lsp btcpay github] implements client-side features of
  [BLIP51][], the specification for inbound channels, into BTCPay Server.

- **Proto mining hardware and software announced:**
  Proto [announced][proto blog] new Bitcoin mining hardware and open source
  mining software, built with previous [community feedback][news260 mdk].

- **Oracle resolution demo using CSFS:**
  Abdelhamid Bakhta [posted][abdel tweet2] a demonstration of an oracle using
  [CSFS][topic op_checksigfromstack], nostr, and MutinyNet to sign an
  attestation of an event's outcome.

- **Relai adds taproot support:**
  Relai added support for sending to [taproot][topic taproot] addresses.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [LND v0.19.3-beta][] is a release for a maintenance
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

- [Bitcoin Core #32896][] introduces support for creating and spending
  unconfirmed Topologically Restricted Until Confirmation ([TRUC][topic v3
  transaction relay]) transactions by adding a `version` parameter to the
  following RPCs: `createrawtransaction`, `createpsbt`, `send`, `sendall`, and
  `walletcreatefundedpsbt`. The wallet enforces the TRUC transaction
  restrictions for weight limit, sibling conflict, and incompatibility between
  unconfirmed TRUC and non-TRUC transactions.

- [Bitcoin Core #33106][] lowers the default `blockmintxfee` to 1 sat/kvB (the
  minimum possible), and the default [`minrelaytxfee`][topic default minimum
  transaction relay feerates] and `incrementalrelayfee` to 100 sat/kvB (0.1
  sat/vB). While these values can be configured, users are advised to adjust the
  `minrelaytxfee` and `incrementalrelayfee` values together.  Other minimum
  feerates remain unchanged, but the default wallet minimum feerates are
  expected to be lowered in a future version. The motivations for this change
  range from considerable growth in the number of blocks mined with sub 1 sat/vB
  transactions and the number of pools mining these transactions to an increase
  in the Bitcoin exchange rate.

- [Core Lightning #8467][] extends `xpay` (see [Newsletter #330][news330 xpay])
  by adding support for paying [BIP353][] Human Readable Names (HRN) (e.g.
  satoshi@bitcoin.com) and enabling it to pay  [BOLT12 offers][topic offers]
  directly, removing the need to run the `fetchinvoice` command first. Under the
  hood, `xpay` fetches the payment instructions using the `fetchbip353` RPC
  command from the `cln-bip353` plugin introduced in [Core Lightning #8362][].

- [Core Lightning #8354][] starts publishing `pay_part_start` and `pay_part_end`
  event notifications for the status of specific payment parts sent with
  [MPP][topic multipath payments]. The `pay_part_end` notification indicates the
  duration of the payment and whether it was successful or failed. If the
  payment fails, an error message is provided and, if the error onion isn’t
  corrupted, additional information on the failure is given, such as the source
  of the error and the failure code.

- [Eclair #3103][] introduces support for [simple taproot channels][topic simple
  taproot channels], leveraging [MuSig2][topic musig] scriptless
  [multisignature][topic multisignature] signing to reduce transaction weight
  consumption by 15% and improve transaction privacy. Funding transactions and
  cooperative closures are indistinguishable from other [P2TR][topic taproot]
  transactions. This PR also includes support for [dual funding][topic dual
  funding] and [splicing][topic splicing] in simple taproot channels, and
  enables [channel commitment upgrades][topic channel commitment upgrades] to
  the new taproot format during a splice transaction.

- [Eclair #3134][] replaces the penalty weight multiplier for stuck
  [HTLCs][topic htlc] with the [CLTV expiry delta][topic cltv expiry delta] when
  scoring [HTLC endorsement][topic htlc endorsement] peer reputation (see
  [Newsletter #363][news363 reputation]), to better reflect how long a stuck
  HTLC will tie up liquidity. To mitigate the outsized penalty of stuck HTLCs
  with a maximum CLTV expiry delta, this PR adjusts the reputation decay
  parameter (`half-life`) from 15 to 30 days and the stuck payment threshold
  (`max-relay-duration`) from 12 seconds to 5 minutes.

- [LDK #3897][] extends its [peer storage][topic peer storage] implementation by
  detecting lost channel state during backup retrieval, by deserializing the
  peer’s copy and comparing it to the local state.

{% include snippets/recap-ad.md when="2025-08-26 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32896,33106,8467,8354,3103,3134,3897,8362" %}
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
[news330 xpay]: /en/newsletters/2024/11/22/#core-lightning-7799
[news363 reputation]: /en/newsletters/2025/07/18/#eclair-2716
[zeus v0.11.3]: https://github.com/ZeusLN/zeus/releases/tag/v0.11.3
[abdel tweet]: https://x.com/dimahledba/status/1951213485104181669
[rustreexo webapp]: https://rustreexo-playground.starkwarebitcoin.dev/
[rustreexo wasm]: https://github.com/AbdelStark/rustreexo-wasm
[b10c blog]: https://b10c.me/projects/024-peer-observer/
[peer-observer github]: https://github.com/0xB10C/peer-observer
[bitcoin backbone]: https://mailing-list.bitcoindevs.xyz/bitcoindev/9812cde0-7bbb-41a6-8e3b-8a5d446c1b3cn@googlegroups.com
[kernel blog]: https://thecharlatan.ch/Kernel/
[simplcityhl github]: https://github.com/BlockstreamResearch/SimplicityHL
[simplicity]: https://blockstream.com/simplicity.pdf
[simplicityhl delving]: https://delvingbitcoin.org/t/writing-simplicity-programs-with-simplicityhl/1900
[simplicity post]: https://blog.blockstream.com/simplicity-launches-on-liquid-mainnet/
[lsp btcpay github]: https://github.com/MegalithicBTC/BTCPayserver-LSPS1
[proto blog]: https://proto.xyz/blog/posts/proto-rig-and-proto-fleet-a-paradigm-shift
[news260 mdk]: /en/newsletters/2023/07/19/#mining-development-kit-call-for-feedback
[abdel tweet2]: https://x.com/dimahledba/status/1946223544234659877
