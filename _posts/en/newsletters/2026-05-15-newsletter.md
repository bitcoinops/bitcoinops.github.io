---
title: 'Bitcoin Optech Newsletter #405'
permalink: /en/newsletters/2026/05/15/
name: 2026-05-15-newsletter
slug: 2026-05-15-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces the responsible disclosure of a vulnerability
that could allow an attacker with sufficient proof-of-work to crash Bitcoin Core
nodes and describes a draft BIP proposal for sharing the UTXO set over the P2P
network. Also included are our regular sections announcing a new release
candidate and describing notable changes to popular Bitcoin infrastructure
software.

## News

- **Bitcoin Core script interpreter remote crash disclosure:**
  Niklas Gögge [posted][topic cve mailing list] to the Bitcoin-Dev mailing list
  disclosing [CVE-2024-52911][topic cve disclosure], a vulnerability affecting versions of Bitcoin Core
  after version 0.14.0 and before 29.0. After version 0.14.0 (released
  March 2017), validating a specially-crafted block could cause the node to access
  previously freed memory. During validation, data required for
  checking transaction inputs is cached. The bug occurred due to object lifetime
  ordering during parallel script validation, where cached precomputed
  transaction data could be freed before background script-check threads
  completed. For specially-crafted invalid blocks, it was possible for this data
  to be destroyed while it was still being accessed by background threads.

  An attacker with sufficient proof of work could, using the specially-crafted invalid block, crash a
  victim's node. Because of the nature of use-after-free bugs, it is possible
  to perform remote code execution on the victims' nodes, but actually executing
  that attack is unlikely due to the difficulty of crafting a block that achieves it.

  The vulnerability was discovered and [responsibly disclosed][topic responsible disclosures] by Cory Fields, who
  also provided a proof of concept and proposed mitigation. The issue was fixed
  in Bitcoin Core 29.0.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Core Lightning 26.06rc1][] is a release candidate for the next major version
  of this popular LN node which includes new `graceful`, `sendamount`, and
  `xkeysend` RPCs, begins the `pay` deprecation cycle in favor of `xpay`, and
  adds BOLT12 payer-proof RPC support.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #35209][] now constructs the `txsdata` vector before the
  `CCheckQueueControl` object, addressing the root cause of
  [CVE-2024-52911][topic cve disclosure] (see the news section above). Since C++ destroys
  local objects in reverse construction order, this ensures the script-check
  queue is completed before the precomputed transaction data referenced by
  queued `CScriptCheck` objects is destroyed. This prevents early-return
  validation paths from causing background script-check threads to access freed
  memory. This vulnerability was previously fixed in Bitcoin Core 29.0 through
  a covert fix of the early-return behavior (see [Newsletter #333][news333 fix]).

- [BIPs #2116][] publishes [BIP323][], which proposes expanding the number of
  bits available in `nVersion`'s nonce space for miners from 16 to 24,
  superseding [BIP320][]. It reserves bits 5 through 28 for header-only mining
  without relying on rolling `nTime` more often than once per second. See
  [Newsletter #395][news395 nversion] for previous discussion.


- [Core Lightning #9116][] adds experimental support for [BOLT12][topic offers]
  payer proofs, implementing the latest draft proposal from [BOLTs #1295][].
  Payer proofs are a BOLT12 receipt format that allows
  [a payer to prove][topic proof of payment] that they paid an invoice using the
  payment preimage, the invoicing node's signature, and a payer signature from
  `invreq_payer_id`, while allowing selected invoice fields to be omitted for
  privacy. The PR adds common routines for creating and validating payer proofs,
  updates `bolt12-cli`, and adds an experimental `createproof` RPC. The format
  remains experimental and may change.

- [Core Lightning #9110][] deprecates the `pay`, `paystatus`, `keysend`,
  `getroute`, `renepay`, and `renepaystatus` RPCs, with deprecation beginning
  in version 26.06 and removal scheduled for version 27.03. The `xpay` RPC (see
  [Newsletter #330][news330 xpay]) now handles most pay invocations, and an
  `xkeysend` RPC is added to maintain [keysend][topic spontaneous payments]
  functionality. The PR also expands `xpay` with `label` and `localinvreqid`
  parameters, CLTV shadow routing, improved handling of repeated payments, and
  handling of `channel_update` errors. It also updates `getroutes` to return
  clearer per-hop amount, node, and CLTV fields, and updates `sendpay` to accept
  routes using those fields.

- [LDK #4598][] updates `OutputSweeper` to ensure its `pending_sweep` flag is
  cleared even if an in-progress sweep attempt is cancelled before completion.
  The flag prevents concurrent sweep attempts, but if it remained set after a
  cancelled sweep, later attempts would be incorrectly skipped, potentially
  preventing time-sensitive [HTLC][topic htlc] outputs from being claimed until
  the node restarted. The PR now clears the flag using a guard object that runs
  on normal return, error, or cancellation.

- [LDK #4528][] commits BOLT11 `payment_metadata` (see
  [Newsletter #182][news182 metadata]) to the inbound payment HMAC. When
  metadata is included in an invoice, LDK now requires that the final onion
  payload return the same metadata before accepting the payment, preventing
  sender-side modification or omission. In addition, the invoice builder now
  requires payment metadata by default, but users can opt out using
  `optional_payment_metadata()` for compatibility with senders that don't
  support it.

- [LND #10612][] adds graph-based pathfinding for [onion messages][topic onion
  messages], building on earlier forwarding support (see
  [Newsletter #396][news396 onion]). LND can now find a route to a destination
  through nodes that advertise onion message support using feature bits 38/39.
  Since onion messages are not payments, the search does not consider liquidity
  or fees.

- [BTCPay Server #7354][] fixes a hot wallet key exposure issue introduced after
  [BTCPay Server #7329][] added granular wallet permissions. Users with
  wallet-signing permission, but not permission to view the wallet seed or modify
  store settings, could be exposed to derived hot wallet private keys during
  [PSBT][topic psbt] signing. The PR introduces a `HotwalletSafe` helper to
  centralize hot-wallet access, separates permission to sign from permission to
  view seed material, and updates signing flows to use the hot wallet
  server-side without returning private signing keys through HTTP form fields.

- [BDK #2195][] fixes syncing from Electrum servers when a transaction's first
  output isn't indexed, such as an `OP_RETURN` output. Previously,
  `BdkElectrumClient::populate_with_txids` queried confirmation history using
  the first output's script, which could return an empty history. BDK now uses
  the first indexed output script, or falls back to an input's previous output
  script if none of the outputs are indexed.

- [Bitcoin Inquisition #100][] implements [BIP446][]'s `OP_TEMPLATEHASH` opcode
  for testing proposed consensus changes on [signet][topic signet].
  `OP_TEMPLATEHASH` is a [tapscript][topic tapscript] opcode that pushes a hash
  of the spending transaction onto the stack (see
  [Newsletter #397][news397 templatehash]). The PR also adds an extensive test
  framework.

- [BINANAs #20][] assigns BIN-2026-0002 to a future Bitcoin Inquisition
  implementation of [BIP443][]'s [OP_CHECKCONTRACTVERIFY][topic matt] (OP_CCV)
  opcode. See Newsletters [#348][news348 op_ccv] and [#356][news356 op_ccv] for
  previous discussion of this proposed [covenant][topic covenants].

{% include snippets/recap-ad.md when="2026-05-19 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2137,20,100,1295,2116,2141,2155,2195,4528,4598,7329,7354,9110,9116,10612,35209" %}
[topic cve mailing list]: https://groups.google.com/g/bitcoindev/c/e1UEdViSYkU
[topic cve disclosure]: https://bitcoincore.org/en/2026/05/05/disclose-cve-2024-52911/
[Core Lightning 26.06rc1]: https://github.com/ElementsProject/lightning/releases/tag/v26.06rc1
[news333 fix]: /en/newsletters/2024/12/13/#bitcoin-core-31112
[news330 xpay]: /en/newsletters/2024/11/22/#core-lightning-7799
[news182 metadata]: /en/newsletters/2022/01/12/#bolts-912
[news396 onion]: /en/newsletters/2026/03/13/#lnd-10089
[news395 nversion]: /en/newsletters/2026/03/06/#draft-bip-for-expanded-nversion-nonce-space-for-miners
[news397 templatehash]: /en/newsletters/2026/03/20/#bips-1974
[news348 op_ccv]: /en/newsletters/2025/04/04/#op-checkcontractverify-semantics
[news356 op_ccv]: /en/newsletters/2025/05/30/#bips-1793
