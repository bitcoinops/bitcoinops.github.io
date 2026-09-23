---
title: 'Bitcoin Optech Newsletter #424'
permalink: /en/newsletters/2026/09/25/
name: 2026-09-25-newsletter
slug: 2026-09-25-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposal for upgrading the offchain
protocols of the Lightning Network to post-quantum security. Also included are
our regular sections with selected questions and answers from the Bitcoin
Stack Exchange, announcements of new releases and release candidates, and
descriptions of notable changes to popular Bitcoin infrastructure software.

## News

- **Proposal for a post-quantum Lightning Network**: Ahmet Kurt [posted][pqln del]
  to Delving Bitcoin about a new proposal for upgrading the offchain surfaces of
  the Lightning Network to be [quantum-secure][topic quantum resistance],
  called PQLN, building on the layer-by-layer analysis covered in [Newsletter #408][news408 pq ln].
  The author and his collaborators also published a [paper][pqln paper]
  on the topic and a working [implementation][pqln repo] based on rust-lightning
  is available for testing.

  Kurt explained how the different layers of the Lightning Network have been
  modified to reach post-quantum (PQ) security. However, he highlighted
  that no modifications were done at those layers that deal with onchain operations,
  since that part would require a consensus change. Here are the main changes:

  - Gossip ([BOLT7][]): PQ keys are distributed directly through the gossip
    itself. The `node_announcement` message carries the node's ML-DSA and ML-KEM
    public keys together with the ML-DSA signature. The `channel_update` message
    carries only the signature. The keys are pinned, so that the node can reject
    any announcement trying to substitute them. The author noted that the
    `channel_announcement` message has not been modified, since the message
    would be half-forgeable due to the fact that two of its four signatures
    are made with the onchain funding keys.
  - Transport ([BOLT8][]): The Noise handshake becomes hybrid using two ML-KEM
    encapsulations. The first one goes to the pinned static key, the other goes
    to new ephemeral key to provide forward secrecy. No in-band negotiation is
    performed, since a PQ attacker could easily forge the involved messages.
  - Invoices ([BOLT11][]): Since a tagged field in an invoice holds at most 639 bytes,
    the ML-DSA-44 signature, which has a size of 2420 bytes, must be split across 4
    different fields.
  - Offers ([BOLT12][]): Since an [offer][topic offers] carries its own anchor,
    the node commits a fresh ML-DSA key for each one of them. Payer checks the
    invoice against that key before any [HTLC][topic htlc] goes out.
  - Onion ([BOLT4][]): Since a ML-KEM ciphertext cannot be put inside an onion
    due to its size, the onion keeps its format, while the Sphinx secret becomes
    hybrid. Ciphertexts are sent together with the onion in the `update_add_htlc`
    message in a list of 20 slots. To prevent a node from deriving the length
    of the route, each unused slot is filled with dummy ciphertext.

  According to Kurt, the real cost of this transition is bandwidth. A node needs
  to download 10 times and store 9 times the data of a simple LN node. On the other
  hand, computation is not an issue. In fact, the most expensive operation, the ML-DSA
  signing, takes only 0.33 ms. The author tested interoperability with classical nodes on
  regtest. Results were positive, with PQLN nodes falling back to the classical
  protocol when a classical node was on the payment route, or failing before
  any HTLC was sent when the require-PQ flag was set.

  Finally, the author presented some open problems, such as pinning, which protects
  only nodes that had met before a cryptographically relevant quantum computer was
  available, the 1,024-byte `MAX_EXCESS_BYTES_FOR_RELAY` limit in rust-lightning which
  prevents non-PQ nodes from relaying PQ gossip, and pending assignment of feature bits and TLV types.

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [What would be a drawback if sum instead of SHA256 of amounts was used in the taproot signature message?]({{bse}}130977)
  User 1uba explains that committing to only the sum of input amounts in a
  [taproot][topic taproot] signature hash (sighash) would still prevent the
  fee-overpayment attack [BIP341][] cites, but the software preparing a
  transaction for a signing device could then swap the amounts between inputs
  as long as the total stayed the same. This impacts offline signers and
  for collaborative transactions, where a signer needs to verify its own
  input's amount.

- [Post-BIP110 fork is it necessary to resync from block 0?]({{bse}}131037)
  Murch expects that a pruned Bitcoin Knots node that enforced BIP110
  rules (see [Newsletter #418][news418 bip110]) still holds the last block
  common to both chains, because few blocks were added to the BIP110 chain
  before the node was last run. Installing Bitcoin Core in its place
  should work, but if the node does not reorganize on its own, he suggests
  trying `reconsiderblock` on the first block the BIP110 node rejected.

- [Can a Bitcoin node build a partial UTXO set from only the most recent blocks and use it to validate new transactions?]({{bse}}131051)
  Pieter Wuille explains that such a node cannot tell whether a missing input
  was already spent or was created in a block it skipped. Because it cannot
  reject any transaction as invalid, the scheme performs no useful validation
  and is equivalent in security to SPV, which relies entirely on proof of
  work.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

FIXME:Gustavojfe

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

{% include snippets/recap-ad.md when="2026-09-29 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="" %}

[news418 bip110]: /en/newsletters/2026/08/14/#bips-2225
[pqln del]: https://delvingbitcoin.org/t/pqln-post-quantum-security-for-the-bitcoin-lightning-networks-off-chain-surfaces/2893
[pqln paper]: https://arxiv.org/abs/2609.13781
[pqln repo]: https://github.com/ahmet-kurt/pq-rust-lightning
[news408 pq ln]: /en/newsletters/2026/06/05/#post-quantum-lightning-discussion
