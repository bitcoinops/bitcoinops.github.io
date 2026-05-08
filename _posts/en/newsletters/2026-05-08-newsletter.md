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

<script>
(function () {
  var DELAY = 2500;
  var FADE  = 600;

  var style = document.createElement('style');
  style.textContent =
    '#nl404 { font-family: serif; text-align: center; padding: 2em 0; }' +
    '#nl404 h1 { font-weight: normal; font-size: 1.5em; margin-bottom: 0.5em; }' +
    '#nl404 hr { border: 1px solid #000; margin: 0.5em 0; }' +
    '.nl404-hide { display: none !important; }' +
    '@keyframes nl404fi { from { opacity: 0; } to { opacity: 1; } }' +
    '.nl404-show { animation: nl404fi ' + FADE + 'ms ease forwards; }';
  (document.head || document.documentElement).appendChild(style);

  document.addEventListener('DOMContentLoaded', function () {
    if (sessionStorage.getItem('nl404shown')) return;
    sessionStorage.setItem('nl404shown', '1');

    var wrap = document.querySelector('.post-content');
    if (!wrap) return;

    var kids = Array.prototype.slice.call(wrap.children);
    kids.forEach(function (el) { el.classList.add('nl404-hide'); });

    var box = document.createElement('div');
    box.id = 'nl404';
    box.innerHTML =
      '<h1>Newsletter Not Found</h1>' +
      '<p>:)</p>';
    wrap.insertBefore(box, wrap.firstChild);

    setTimeout(function () {
      box.remove();
      kids.forEach(function (el) {
        el.classList.remove('nl404-hide');
        el.classList.add('nl404-show');
      });
    }, DELAY);
  });
}());
</script>

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

- [Bitcoin Core #33796][] adds `btck_check_transaction()` to the
  `libbitcoinkernel` C API (see [Newsletter #380][news380 kernel]) for running
  context-free, consensus-level checks on a transaction's structure. This
  includes rejecting empty input or output lists, invalid coinbase scriptSig
  lengths, duplicate inputs, null prevouts in non-coinbase transactions, and
  output values outside the valid money range, without requiring chainstate, the
  UTXO set, or script verification.

- [Bitcoin Core #21283][] implements [BIP370][] [PSBTv2][topic psbt] support,
  while maintaining backwards compatibility with PSBTv0. PSBTv2 stores
  transaction construction data, such as version, locktime, inputs, outputs, and
  transaction modifiability, directly in PSBT fields, instead of requiring a
  complete unsigned transaction.

- [BIPs #2150][] adds [BIP451][], a specification for a Dust UTXO Disposal
  Protocol, which defines a standard for wallets to safely dispose of unwanted
  [dust][topic uneconomical outputs] UTXOs by spending them to a single
  zero-value `OP_RETURN` output, with the entire input value paid as transaction
  fees. The protocol includes privacy-preserving construction rules, such as
  per-address disposal of confirmed dust UTXOs, and `ALL|ANYONECANPAY`
  signatures that allow unrelated dust-disposal transactions found in the
  mempool to be batched through [RBF][topic rbf].

- [Eclair #3144][] updates [simple taproot channels][topic simple taproot
  channels] to use the official feature bit and enables them by default, without
  support yet for announcing those channels. Test vectors are added to align
  with the BOLTs specification and LND's implementation (see [Newsletter
  #401][news401 lnd]).

- [Eclair #2887][] adds support for the official [splicing][topic splicing]
  protocol merged into the BOLTs specification (see [Newsletter #398][news398
  splicing]), while maintaining backwards compatibility with Eclair's earlier
  experimental splicing implementation.

- [LDK #4592][] starts checking if a node has sufficient reserves before opening
  new [zero-fee commitment][topic v3 commitments] (0FC) channels by counting
  them as [anchor][topic anchor outputs] channels. Previously, LDK's reserve
  check only counted channels that used the older `anchors_zero_fee_htlc_tx`
  feature, allowing a node to open more 0FC channels than its wallet could
  safely fee bump during simultaneous force closes.

- [LND #9153][] adds a `source_pub_key` field to the `Route` proto message to
  construct and deserialize routes from the perspective of a node other than the
  local node. If no source is provided, LND continues to use the local node as
  before.

- [Rust Bitcoin #5835][] adds a constructor for `V1MessageHeader` that computes
  the four-byte payload checksum used in Bitcoin's P2P message header. This
  simplifies constructing network messages by allowing callers to build the
  header for a serialized payload and command before sending the message over
  the network.

- [BOLTs #995][] adds an extension BOLT for [simple taproot channels][topic
  simple taproot channels], assigning feature bits 80/81. The specification
  defines a minimal [taproot][topic taproot]-based channel type that uses a
  P2TR funding output with [MuSig2][topic musig] key aggregation, taproot
  commitment and HTLC scripts, and new TLV fields for exchanging MuSig2 partial
  signatures and nonces during channel opening, commitment updates, cooperative
  closes, and reconnection. The nonce fields in `revoke_and_ack` and
  `channel_reestablish` are keyed by funding txid to support multiple active
  commitment transactions, such as during [splicing][topic splicing]. The
  extension intentionally excludes gossip changes, so [announced taproot
  channels][topic channel announcements] remain future work.

- [BOLTs #1228][] specifies [zero-fee commitment][topic v3 commitments] (0FC)
  channels and assigns feature bits 40/41. For this channel type,
  `feerate_per_kw` is set to 0, commitment and [HTLC][topic htlc] transactions
  use [v3 transaction relay][topic v3 transaction relay] (TRUC), and
  mining fees are provided by child transactions using [CPFP][topic cpfp].
  Commitment transactions include a shared [pay-to-anchor (P2A)][topic
  ephemeral anchors] output funded from trimmed outputs and rounded-down
  millisatoshis, capped at 240 sats, allowing the parent commitment transaction
  to pay no direct fee in most cases. The specification also limits the maximum
  number of HTLCs to 114 for this channel type due to TRUC's 10 kvB transaction
  size limit.

- [BOLTs #1327][] updates the [RBF][topic rbf] feerate bump rule to ensure
  compliance with [BIP125][] replacement rules at low feerates. Instead of
  applying only the existing 25/24 feerate multiplier, the specification now
  requires the replacement feerate to increase by the larger of two values: the
  multiplier or an additional 25 sat/kw. This matches the behavior of LDK
  covered in [Newsletter #400][news400 rbf].

{% include snippets/recap-ad.md when="2026-05-12 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33796,21283,2150,3144,2887,4592,9153,5835,995,1228,1327" %}
[fing del]: https://delvingbitcoin.org/t/fingerprinting-nodes-possible-solutions/2466
[news360 fing]: /en/newsletters/2025/06/27/#fingerprinting-nodes-using-addr-messages
[fing gh]: https://github.com/naiyoma/bitcoin/pull/16
[jit del]: https://delvingbitcoin.org/t/proposal-public-fraud-proofs-for-just-in-time-channels/2451
[jit paper gist]: https://gist.github.com/ecdsa/dfa2d76a5fe845fd283c01b5ed12d274
[news380 kernel]: /en/newsletters/2025/11/14/#bitcoin-core-30595
[news398 splicing]: /en/newsletters/2026/03/27/#bolts-1160
[news400 rbf]: /en/newsletters/2026/04/10/#ldk-4494
[news401 lnd]: /en/newsletters/2026/04/17/#lnd-9985