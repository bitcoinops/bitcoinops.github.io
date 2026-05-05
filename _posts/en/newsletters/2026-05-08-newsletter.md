---
title: 'Bitcoin Optech Newsletter #404'
permalink: /en/newsletters/2026/05/08/
name: 2026-05-08-newsletter
slug: 2026-05-08-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes possible solutions to node fingerprinting and
links to discussion of using public fraud proofs to improve incentives around
just-in-time channels. Also included are our regular sections describing notable
changes to popular Bitcoin infrastructure software.

## News

- **Possible solutions to node fingerprinting**: Naiyoma [posted][fing del] to Delving Bitcoin
  about possible solutions to the node fingerprinting issue that uses the `addr` message timestamp to
  identify the same node on multiple networks (see [Newsletter #360][news360 fing]).

  Since the last update, researchers were able to gather more insights on the problem and identify
  new factors to consider. One of the key insights was related to the `AddrMan`, the code structure
  managing the addresses. `AddrMan` considers addresses as stale in case their timestamp is older
  than 30 days, usually due to a peer being offline. Thus, there are two important factors that a
  possible mitigation needs to take into account: refreshing old timestamps to newer ones may cause
  old addresses to be continuously gossiped and making them older may cause them to
  stop being gossiped prematurely.
  These considerations led to discarding some previously considered solutions and provide new ones:

  1. **Simple fuzzing**: Apply random distortion to the address timestamp in a range of
    `[-5, +5] days`. However, the distortion may average out over time.

  2. **Fixed timestamps across networks**: When responding to a request, the real timestamp is
    preserved for the specific network, while on the others the timestamps are set to a randomized
    value in the past. However, old addresses might remain in circulation longer than necessary.

  3. **Fuzzing - Addresses only older**: Make addresses only older, never newer, by applying a random
    distortion in the range `[1, 10] days`. However, addresses may reach the 30-days threshold too
    quickly.

  4. **Fuzzing - Aging-biased timestamp noise**: Apply a random distortion in the range `[-1, +5] days`,
    so as to make addresses mainly older, with only a small chance of becoming newer. However, old
    addresses might remain in circulation longer than necessary.

  5. **Hybrid approach**: The final option is to combine two of the previous approaches together.

  Naiyoma asked for feedback on her work to other developers interested, and
  shared her [PR][fing gh] in which she is testing solution 2.

- **Public fraud proof for just-in-time channels**: Thomas Voegtlin [posted][jit del] to Delving Bitcoin
  about a new proposal for improving the game theory behind [just-in-time (JIT) channels][topic jit channels]
  by using public fraud proofs to demonstrate that an LSP is misbehaving.

  Alice negotiates a JIT channel opening with an LSP, Bob. When Alice needs to receive sats from Carol,
  she creates a preimage. Carol sends an [HTLC][topic htlc] to Bob. Alice discloses the preimage to Bob,
  expecting the LSP to broadcast the channel funding transaction. What happens if Bob claims the HTLC without
  opening the channel with Alice?

  Voegtlin proposes to use the chain as a public arbitration layer. Alice should publish the preimage
  using an `OP_RETURN`, so that disclosure can be verified by anyone and dated to a certain block height.
  On his side, Bob creates a UTXO commitment valid up to a number of blocks `n`. If he spends
  the same UTXOs in a transaction different from the one he committed to, does not broadcast the funding
  transaction, or tries to double-spend it, he would create a fraud proof, damaging his reputation
  as an LSP without requiring other clients to trust Alice.

  Voegtlin provided the full [paper][jit paper gist] containing the in-depth explanation, and invited
  other developers to provide feedback on the proposal.

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

{% include snippets/recap-ad.md when="2026-05-12 16:30" %}
{% include references.md %}
[fing del]: https://delvingbitcoin.org/t/fingerprinting-nodes-possible-solutions/2466
[news360 fing]: /en/newsletters/2025/06/27/#fingerprinting-nodes-using-addr-messages
[fing gh]: https://github.com/naiyoma/bitcoin/pull/16
[jit del]: https://delvingbitcoin.org/t/proposal-public-fraud-proofs-for-just-in-time-channels/2451
[jit paper gist]: https://gist.github.com/ecdsa/dfa2d76a5fe845fd283c01b5ed12d274
