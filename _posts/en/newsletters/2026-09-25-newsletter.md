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

- [Bitcoin Core 32.0rc2][] is a release candidate for the next major version of
  the predominant full node implementation. A [testing guide][bcc32 testing] is
  available.

- [Core Lightning 26.06.8][] is a security release of this popular LN node
  implementation. It includes bug fixes for responsibly reported
  vulnerabilities. The source code is available immediately. However, a few
  tests are temporarily withheld to give users more time to upgrade before
  attackers can easily identify the vulnerabilities. Nodes that have run
  development builds cannot downgrade to this release because their database
  schema is newer. The project strongly recommends upgrading.

- [LDK v0.3-rc2][] is a second release candidate for the next major version of
  this library for building LN-enabled wallets and applications. It adds
  [RBF][topic rbf] fee bumping for pending [splices][topic splicing] and
  support for adding and removing funds in the same splice. It also negotiates
  [anchor channels][topic anchor outputs] by default and requires applications
  to explicitly accept incoming channels. Upgrading invalidates previously
  issued [BOLT11][] invoices containing payment metadata. Developers should
  review the [API and backwards-compatibility changes][ldk 0.3 notes] before
  testing.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #34566][] adds multi-signet data directory support (see
  [Newsletter #412][news412 netmagic]), allowing custom [signets][topic signet]
  to share a base data directory without their chain data conflicting. Each
  custom signet uses a `signet_XXXXXXXX` subdirectory, suffixed by its
  four-byte network identifier derived from the signet challenge. To avoid
  resynchronizing after upgrading, existing custom signet users should manually
  rename their directory to the new format.

- [BIPs #1951][] adds [BIP138][], a specification for a Compact Encryption
  Scheme for Non-seed Wallet Data such as backups of [descriptors][topic
  descriptors] and [BIP388][] wallet policies (see [Newsletter #351][news351
  backup]). The encryption key is derived from the root public keys of the
  descriptor's eligible extended public keys (xpubs), and the backup stores
  recovery data that allows anyone holding one of those keys to decrypt it. A
  cosigner can recover a multisig descriptor from their own seed without
  needing the other cosigners' keys. Since decryption only uses public-key
  material, the payload must exclude private keys. Confidentiality depends on
  the xpubs never being disclosed. Single-signature wallets that send an
  account xpub to a server, such as the Ledger and Trezor desktop apps, would
  let that server decrypt every backup of a multisig reusing that xpub, so the
  BIP recommends building multisigs from accounts, such as BIP48 or BIP87,
  whose xpubs were never shared.

- [BIPs #2224][] adds [BIP461][], which specifies a single deterministic ECDSA
  signing algorithm, ensuring that a given private key and message will always
  produce the same signature. Signers derive nonces with RFC 6979, apply [low-r
  grinding][topic low-r grinding] by retrying with a counter until `r` encodes
  without a leading zero byte, and normalize `s` to its low form. Because the
  output is deterministic, a key holder can load the same key into two independent
  signers, sign the same message, and compare the results. Any difference
  reveals that at least one signer is not following the specification, which
  could indicate an attempt to [leak key material][topic exfiltration-resistant
  signing] through nonce selection, as in
  the Dark Skippy attack (see [Newsletter #315][news315 dark skippy]).

- [Core Lightning #9507][] adds missing feerate bounds and fixes overflows that
  could turn very large fee estimates into near-zero rates or cause the node to
  crash repeatedly. Previously, peer-proposed [splices][topic splicing] and
  [RBF][topic rbf] attempts on [dual-funded][topic dual funding] opens lacked
  an upper feerate bound, while dual-funded opens themselves lacked both lower
  and upper checks. A stored feerate large enough to overflow the next RBF
  feerate calculation, or a stored zero, triggered an assertion in
  `listpeerchannels`. Since plugins call it at startup, the node would crash on
  every restart. The PR adds a 4,000 sat/vB ceiling on peer proposals and
  backend [fee estimates][topic fee estimation], even with
  `--ignore-fee-limits` enabled. It also caps the feerates that CLN proposes
  for its own opens, splices, commitment updates, and RBFs at 400 sat/vB, and
  repairs out-of-range stored feerates on upgrade.

- [Core Lightning #9508][] fixes several [splice][topic splicing] and
  channel-opening issues. Previously, before CLN received the peer's
  `splice_locked`, it could miss a peer's broadcast of a commitment transaction
  for a pending splice. Now, CLN monitors the funding output of every pending
  splice and recognizes the spend. CLN also properly force-closes the channel
  if a peer sends `tx_abort` for a splice after CLN has sent its signatures.
  Previously, the check failed to recognize a splice that had already been
  signed, and the flag indicating that a signature had been sent was not
  preserved across restarts. This caused CLN to accept `tx_abort` without
  force-closing. The PR also rejects a new [dual-funded][topic dual funding]
  open from a peer that already has three ongoing channel-opening negotiations,
  including single-funded ones. Peers that exceed this limit or keep a channel
  quiescent for more than ten minutes are disconnected.

- [Core Lightning #9509][] fixes several issues with onchain channel
  resolution. Previously, CLN could treat a force-close as a cooperative close
  if all its outputs paid to known shutdown scripts. A peer that hadn't
  committed to an upfront shutdown script at channel opening could send a
  `shutdown` message naming the output script of an old revoked commitment as
  its shutdown script, abort the cooperative close, and then broadcast that
  commitment without being penalized. Now, CLN identifies commitment
  transactions by their locktime and sequence encoding before checking outputs.
  The PR also restarts `onchaind` when a watched descendant of a
  still-confirmed commitment transaction is reorg'd, instead of leaving the
  channel unmonitored until the node restarts. CLN now fulfills the
  corresponding unresolved incoming [HTLC][topic htlc] when its preimage is
  learned onchain, even if failure of the outgoing HTLC was pending. Additional
  fixes prevent crashes involving reorged close outputs and onchain payments to
  amountless invoices' fallback addresses.

- [Core Lightning #9510][] and [#9511][core lightning #9511] harden input
  parsing and logging. The first fixes a buffer overflow that could crash
  `connectd` when connecting through a proxy to a node that announced a very
  long DNS hostname. CLN now rejects `dns:` addresses in its own configuration
  that are not valid hostnames at startup, and ignores invalid DNS addresses in
  received node announcements. It also limits JSON nesting to 256 levels and
  REST request bodies to 2 MiB, and fixes a [BOLT12][topic offers] TLV parsing
  bug that lets a malformed message crash CLN. The second PR fixes a stack
  overflow that allowed an unauthenticated REST request with a very large
  parameter to crash the node. It also removes I/O logs from `getlog`, because
  raw RPC and plugin traffic can contain runes (authentication tokens that
  grant restricted RPC access) and other secrets.

- [Core Lightning #9513][] fixes amount validation when `xpay` fetches an
  invoice for a [BOLT12 offer][topic offers]. Previously, it used the fetched
  invoice's amount without checking it against the authorized amount, allowing
  the recipient to request a larger payment. Now, the invoice must either match
  the requested amount or, if no amount was supplied, it must not exceed the
  offer amount. The PR also prevents an [onion message][topic onion messages]
  containing a reply path with no hops, which any node could send, from
  stopping the node. CLN now treats such a path as absent and logs other
  unparsable reply paths instead of terminating the `offers` plugin.

- [LND #11198][] fixes a bug where an entire invoice was canceled due to a
  failed [AMP][topic amp] payment preimage reconstruction. A reusable AMP
  invoice can accept multiple independent payment sets, each consisting of
  several [HTLCs][topic htlc]. Previously, an invalid set could cancel the
  invoice and interfere with other accepted sets, even though the
  reconstruction failure only affected that set. Now, LND fails the arriving
  HTLC and cancels the previously accepted HTLCs belonging to the failing set.
  The invoice remains payable, and other accepted sets can still complete and
  settle.

- [LND #11146][] continues its implementation of [BOLT12 offers][topic offers]
  by adding validated string encoders and decoders for offers, invoice
  requests, and invoices. These combine parsing with the applicable network,
  feature, expiry, and signature checks, building on the signature support
  described in [Newsletter #422][news422 bolt12]. The new
  `ValidateInvoiceForPayment` function also checks an invoice against the
  originating request and the node the payer expected to sign it. A valid
  signature alone is insufficient: a node along a [blinded path][topic rv
  routing] could otherwise return an invoice signed with its own key.

- [LND #11132][] restores [BOLT1][] compliance by replying to every valid
  `ping` admitted by its flood policy. Previously, a separate `pong` limiter
  could silently suppress required replies (see [Newsletter #421][news421
  ping]). LND now uses a single per-peer bucket containing 200 tokens,
  replenished at a rate of 10 per second. Larger requested replies cost more
  tokens; a maximum-size reply costs ten tokens, which preserves the previous
  bandwidth limit. Exhausting the budget disconnects the peer.

{% include snippets/recap-ad.md when="2026-09-29 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="34566,1951,2224,9507,9508,9509,9510,9511,9513,11198,11146,11132" %}

[news418 bip110]: /en/newsletters/2026/08/14/#bips-2225
[pqln del]: https://delvingbitcoin.org/t/pqln-post-quantum-security-for-the-bitcoin-lightning-networks-off-chain-surfaces/2893
[pqln paper]: https://arxiv.org/abs/2609.13781
[pqln repo]: https://github.com/ahmet-kurt/pq-rust-lightning
[news408 pq ln]: /en/newsletters/2026/06/05/#post-quantum-lightning-discussion
[Bitcoin Core 32.0rc2]: https://bitcoincore.org/bin/bitcoin-core-32.0/test.rc2/
[bcc32 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/32.0-Release-Candidate-Testing-Guide
[Core Lightning 26.06.8]: https://github.com/ElementsProject/lightning/releases/tag/v26.06.8
[LDK v0.3-rc2]: https://github.com/lightningdevkit/rust-lightning/tree/v0.3-rc2
[ldk 0.3 notes]: https://github.com/lightningdevkit/rust-lightning/blob/v0.3-rc2/CHANGELOG.md
[news412 netmagic]: /en/newsletters/2026/07/03/#bitcoin-core-35610
[news351 backup]: /en/newsletters/2025/04/25/#standardized-backup-for-wallet-descriptors
[news315 dark skippy]: /en/newsletters/2024/08/09/#faster-seed-exfiltration-attack
[news422 bolt12]: /en/newsletters/2026/09/11/#lnd-11061
[news421 ping]: /en/newsletters/2026/09/04/#lnd-11090
