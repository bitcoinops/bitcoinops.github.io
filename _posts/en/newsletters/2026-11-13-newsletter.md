---
title: 'Bitcoin Optech Newsletter #431'
permalink: /en/newsletters/2026/11/13/
name: 2026-11-13-newsletter
slug: 2026-11-13-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter links to draft BIPs for exfiltration-resistant signing,
summarizes the disclosure of three vulnerabilities affecting older versions of
Bitcoin Core, announces a plan for mining the testnet5 genesis block, and
describes an investigation into degraded compact block reconstruction. Also
included are our regular sections announcing new releases and release
candidates and describing notable changes to popular Bitcoin infrastructure
software.

## News

- **Draft BIPs for anti-exfil signing:** Connor Avila [posted][anti ex ml]
  to the Bitcoin-Dev mailing list about a proposal to standardize
  [exfiltration-resistant signing][topic exfiltration-resistant signing]
  for hardware devices. Since the nonce is chosen by the signing device,
  a compromised device may be able to leak its seed. The proposal introduces
  the possibility for the host to contribute to the nonce generation, a
  technique already used by several manufacturers but never standardized
  (see [Newsletter #136][news136 anti ex]). This is not the first time
  this topic has been discussed: Stepan Snigirev made a first proposal in 2020
  to standardize exfiltration-resistant signing (see
  [Newsletter #87][news87 anti ex]), Pieter Wuille provided an overview of
  the different techniques available (see [Newsletter #88][news88 anti ex]),
  Moonsettler proposed an anti-exfiltration protocol in 2024 (see
  [Newsletter #317][news317 anti ex]), and the recently-merged [BIP461][]
  provides a way to identify possible attempts to leak key material by a
  signing device (see [Newsletter #424][news424 bip461]).

  Avila's proposal comes with two draft BIPs. [The first one][anti ex bip]
  covers anti-exfil signing for [schnorr][topic schnorr signatures] and
  ECDSA signatures, defining a two-round protocol in which a host provides
  its own randomness for nonce generation and checks that the signing device
  has actually used it. [The second draft][anti ex psbt] adds three dedicated
  per-input fields to [PSBTs][topic psbt] in order to run the anti-exfil protocol.
  The proposal also comes with test vectors, a reference implementation in Python, and
  a C module for libsecp256k1.

  Avila noted that Sjors Provoost had already published an
  [experimental draft][anti ex sjors] covering single-signer taproot key-path signing.
  According to the author, Provoost plans to align his implementations with Avila's
  specification. Finally, Avila requested feedback and reviews from other developers, since
  his proposal had not received any audit on the cryptography.

- **Disclosure of three vulnerabilities in Bitcoin Core:** Antoine Poinsot
  [posted][poinsot adv ml] to the Bitcoin-Dev mailing list three Bitcoin Core
  security advisories, one high-severity and two medium-severity, for
  vulnerabilities that were fixed in Bitcoin Core 29.2 and 30.0. According to
  the [disclosure policy][disc pol] (see [Newsletter #306][news306
  disclosures]), medium and high severity vulnerabilities are disclosed two
  weeks after the last affected release reaches end of life, which the 29.x
  series did on October 27. The three disclosed vulnerabilities are the
  following:

  - [Block template creation halted by TRUC sibling eviction during reorg][CVE-2025-62861]:
    This high-severity bug only affected nodes used for mining, leaving them
    unable to create block templates after certain reorgs until they were
    restarted. [TRUC][topic v3 transaction relay] sibling eviction still ran
    when transactions from disconnected blocks re-entered the mempool, which
    could evict a transaction while leaving its descendants behind. The bug
    affected versions 28.0 through 29.1. It was [disclosed responsibly][topic
    responsible disclosures] by Niklas Gögge in September 2025 and fixed by
    Greg Sanders in [Bitcoin Core #33504][] (see [Newsletter #375][news375
    truc]).

  - [Inbound Tor connections wrongly receive `-whitelist` permissions][CVE-2025-62860]:
    This medium-severity bug would lift DoS limits and privacy-leak mitigations
    for every inbound [Tor][topic anonymity networks] peer on nodes whose
    `-whitelist` range included the address of their Tor daemon, a
    configuration used by thousands of reachable nodes. The bug was disclosed
    responsibly by Martin Zumsande and Antoine Poinsot in September 2025 and
    fixed by Zumsande in [Bitcoin Core #33395][].

  - [Block processing stall via witness malleation][CVE-2025-62859]: This
    medium-severity bug would allow a peer that was first to announce a
    [compact block][topic compact block relay] to stall a node's processing of
    that block for up to 10 minutes, and to repeat the stall indefinitely under
    some conditions. The bug was disclosed responsibly by Eugene Siegel in
    April 2025 and fixed by Greg Sanders in [Bitcoin Core #32646][].

  Fixes for the first two vulnerabilities were also included in Bitcoin Core
  28.3. All of the affected release series have now reached end of life, so
  anyone still running one should upgrade to a maintained release.

- **Testnet5 genesis block to be mined:** Anthony Towns [posted][towns tn5]
  to the Bitcoin-Dev mailing list a plan to mine the genesis block of
  [testnet5][topic testnet], the proposed replacement for testnet4 specified
  in [BIP95][] (see Newsletters [#409][news409 testnet5] and [#412][news412
  bip95]). Mining is set to begin once mainnet reaches its next difficulty
  adjustment at block 975,744, expected on November 13. The genesis block
  will commit to a mainnet block hash at or after that height, so nobody can
  mine testnet5 blocks in advance. Because testnet5's minimum difficulty is
  about a million times higher than testnet4's (to prevent large numbers of
  blocks from being mined quickly after launch, before difficulty adjusts),
  mining the first blocks requires ASICs, and Towns [described][towns tn5
  gist] a public pool that anyone can point hashrate at so that developers
  have no head start.

  After the genesis block is mined, its values will replace the placeholders in
  BIP95. Towns noted that node software will still need testnet5 parameters and
  BIP54 [consensus cleanup][topic consensus cleanup] logic, plus DNS seeds,
  faucets, and explorers, before the network is ready for general use.

FIXME:bitschmidty

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [LDK v0.3-rc4][] is the fourth release candidate for the next major version
  of this library for building LN-enabled wallets and applications, following
  the candidate described in [Newsletter #426][news426 ldk rc]. Developers
  should review the [API and backwards-compatibility changes][ldk 0.3 notes]
  before testing, including the invalidation of previously issued [BOLT11][]
  invoices containing payment metadata.

- [LDK v0.2.8][] and [v0.1.14][ldk v0.1.14] are security releases for the 0.2
  and 0.1 branches of this library, respectively. Both fix vulnerabilities that
  could lead to a loss of funds or a DoS attack, as well as the
  cooperative-close issues described below and a route-hint handling issue.
  Version 0.2.8 also fixes a fee overpayment vulnerability affecting payments
  of static [BOLT12][] invoices and DoS vulnerabilities affecting LSPS2 services.

- [LND v0.21.8-beta][] and [v0.20.8-beta][lnd v0.20.8-beta] are maintenance
  releases of this LN node implementation. Both include the AMP recovery,
  channel funding, restored-channel force-close, and confirmation-hint fixes
  described below. They also address recovery of forwarded HTLCs across link
  reconnections and include sweeper and channel state fixes.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #36142][] fixes command injection through the [Tor][topic
  anonymity networks] control endpoint. An attacker controlling or
  impersonating that endpoint could return a malicious onion service private
  key. Bitcoin Core would then save and reuse the key, allowing the attacker to
  inject additional Tor control commands or arguments. Bitcoin Core now
  validates keys before saving or reusing them and checks returned onion
  service IDs. If an existing cached key fails validation, the onion service
  will be unavailable. Deleting the cached key and restarting will generate a
  new onion address.

- [BIPs #2251][] adds [BIP394][], a draft specification for the `rawtr()`
  output script descriptor previously discussed in [Newsletter #419][news419
  rawtr]. Unlike `tr()`, which derives a [taproot][topic taproot] output key
  from an internal key and an optional script tree, `rawtr()` takes the output
  key directly without applying a tweak. This allows a wallet to describe an
  output without knowing its internal structure. However, a `rawtr()`
  [descriptor][topic descriptors] does not prove that other spending paths are
  absent. Therefore, software importing one from an untrusted source should
  warn users of the possibility of hidden scriptpaths. Bitcoin Core has
  supported this descriptor since version 24.0 (see [Newsletter #213][news213
  rawtr]).

- [BIPs #2347][] updates [BIP95][], the draft specification for
  [testnet5][topic testnet] (see [Newsletter #412][news412 bip95]), to make its
  proposed genesis block easier to mine using [pool infrastructure][topic
  pooled mining] (see the [news item above](#testnet5-genesis-block-to-be-mined)).
  The commitment to a recent mainnet block hash shifts from a public-key field
  in the coinbase output to readable text in the coinbase input script. The
  output uses `OP_RETURN` instead, which explicitly marks it as unspendable and
  provides eight bytes of extra nonce space. The draft also allows miners to
  vary the block version, expanding the available mining search space. The
  example genesis block remains a placeholder.

- [BIPs #2342][] clarifies [BIP34][]'s encoding of the block height at the
  start of the coinbase input script for chains that enforce the rule
  immediately after genesis, such as [signet][topic signet] and
  [testnet4][topic testnet]. Heights 1 to 16 must use the single-byte opcodes
  `OP_1` through `OP_16`, without a length prefix. The earlier wording could be
  interpreted as requiring a length-prefixed number. This clarification aligns
  with the existing behavior of Bitcoin Core. It also notes that the coinbase
  input script must still contain at least two bytes, so the height opcode
  alone is insufficient (see [Newsletter #406][news406 coinbase]).

- [Core Lightning #9610][] fixes a peer-triggered crash caused by an oversized
  [HTLC][topic htlc] amount. This crash could be triggered by a channel peer
  proposing an HTLC with a bogus amount of at least about 92 million BTC,
  setting the amount field's highest bit. The value could then be interpreted
  as negative during a signed balance check, bypassing the check for sufficient
  funds. Subsequent commitment transaction construction triggered an assertion
  and terminated `channeld`, the affected channel's subprocess. Now, CLN
  rejects amounts above the [BOLT1][] ceiling of 21 million BTC, expressed in
  millisatoshis, before performing the balance arithmetic.

- [LDK #5507][] and [#5532][ldk #5532] fix cooperative-close bugs that could
  combine signatures for different transactions. The first ensures that LDK
  signs the peer's proposed transaction, instead of reusing a cached signature
  from a different closing transaction just because the proposed fee matches.
  The second PR clears the pending signing state when a peer disconnects after
  an async signer was unavailable, preventing an old peer signature from being
  combined with a new local proposal after reconnection. Previously, in both
  cases, LDK could submit an invalid closing transaction for broadcast while
  treating the channel as closed, leaving behind funds that required recovery.

- [LND #11492][] fixes onchain recovery of received atomic multipath payments
  ([AMP][topic amp]) after a force close. Previously, LND could fail to find
  the preimage needed to claim an outstanding [HTLC][topic htlc], even though
  it had already recorded the payment as settled. LND incorrectly checked for
  an invoice-level preimage instead of the preimage stored for the individual
  AMP HTLC. It now retrieves that HTLC's preimage. The PR also prevents expiry
  checks intended for new payments from rejecting previously recorded
  spontaneous AMP and [keysend][topic spontaneous payments] HTLCs when they are
  processed again during recovery (see [Newsletter #412][news412 cltv] for
  earlier coverage of LND's expiry checks).

- [LND #11479][] fixes the handling of errors when publishing a [transaction
  that opens multiple channels][topic payment batching] (see [Newsletter
  #166][news166 batch]). Previously, an error during broadcast caused LND to
  abandon the pending channels and release their reserved wallet inputs, even
  if the transaction had reached the network and could still confirm. Now, LND
  keeps the pending channels' state once publication is attempted, preserving
  the information needed to monitor the transaction and recover the channels.
  If the transaction can't confirm, the retained pending channels require
  manual cleanup.

- [LND #11340][] and [#11374][lnd #11374] extend LND's experimental [BOLT12
  offers][topic offers] support (see [Newsletter #424][news424 bolt12]) with
  offer creation and invoice request handling. The first PR adds a handler that
  validates requests against stored offers and replies with signed invoices.
  The second PR connects the handler to incoming [onion messages][topic onion
  messages] and adds the `CreateOffer` RPC and the `lncli createoffer` command.
  However, the handler does not yet retain the invoice state needed to settle
  payments against the invoices it issues. The feature is only available in
  development builds and requires additional configuration.

- [LND #11480][] fixes a crash when attempting to force close a channel
  restored from a [static channel backup][topic static channel backups]. Such a
  backup does not contain a usable local commitment transaction; recovery
  requires the counterparty to publish its commitment. Previously, the
  force-close path checked for local data loss but not the restored-channel
  status, allowing it to access a missing commitment transaction and panic. LND
  now rejects that local force-close attempt and handles the unavailable
  transaction safely, including when resuming an interrupted close after
  restart.

- [LND #11481][] fixes how LND caches the starting block height for scans that
  check whether a transaction has confirmed. Previously, an attacker could
  propose a fake channel funding output with the txid of a revoked commitment
  transaction and a different output script. Since LND cached scan starting
  heights by txid alone, the fake funding request shared its cache entry with
  the request tracking the revoked commitment. The unmatched funding request
  could advance the starting height past the revoked transaction's confirmation
  block, causing a later scan to miss it. This could delay LND's detection of
  the revoked commitment and its [penalty transaction][topic ln-penalty]. LND
  now stores separate starting heights for each txid and output script. The
  issue affects historical scans, including those used by Neutrino and by
  Bitcoin Core without a transaction index.

{% include snippets/recap-ad.md when="2026-11-17 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33504,33395,32646,36142,2251,2347,2342,9610,11492,11479,11340,11374,11480,11481,5507,5532" %}

[anti ex ml]: https://groups.google.com/g/bitcoindev/c/cB37_jChkEI/m/3paRGQ_IBgAJ
[news136 anti ex]: /en/newsletters/2021/02/17/#anti-exfiltration
[anti ex bip]: https://github.com/AvilaLabs/anti-exfil/blob/main/spec/bip-anti-exfil.md
[anti ex psbt]: https://github.com/AvilaLabs/anti-exfil/blob/main/spec/bip-anti-exfil-psbt.md
[news87 anti ex]: /en/newsletters/2020/03/04/#proposal-to-standardize-an-exfiltration-resistant-nonce-protocol
[news88 anti ex]: /en/newsletters/2020/03/11/#exfiltration-resistant-nonce-protocols
[news317 anti ex]: /en/newsletters/2024/08/23/#simple-but-imperfect-anti-exfiltration-protocol
[news424 bip461]: /en/newsletters/2026/09/25/#bips-2224
[anti ex sjors]: https://github.com/Sjors/bips/pull/2/
[poinsot adv ml]: https://groups.google.com/g/bitcoindev/c/tOLTRSOz87k/m/7eiOFoHIAQAJ
[disc pol]: https://bitcoincore.org/en/security-advisories/
[news306 disclosures]: /en/newsletters/2024/06/07/#upcoming-disclosure-of-vulnerabilities-affecting-old-versions-of-bitcoin-core
[CVE-2025-62861]: https://bitcoincore.org/en/2026/11/10/disclose-cve-2025-62861/
[CVE-2025-62860]: https://bitcoincore.org/en/2026/11/10/disclose-cve-2025-62860/
[CVE-2025-62859]: https://bitcoincore.org/en/2026/11/10/disclose-cve-2025-62859/
[news375 truc]: /en/newsletters/2025/10/10/#bitcoin-core-33504
[towns tn5]: https://groups.google.com/g/bitcoindev/c/DmFiHeo-xRw/m/YI3cpl5vAQAJ
[towns tn5 gist]: https://gist.github.com/ajtowns/ebb148819c6028387271e6f0dce5e1da
[news409 testnet5]: /en/newsletters/2026/06/12/#draft-bip-for-testnet5
[news412 bip95]: /en/newsletters/2026/07/03/#bips-2196

[LDK v0.3-rc4]: https://github.com/lightningdevkit/rust-lightning/tree/v0.3-rc4
[ldk 0.3 notes]: https://github.com/lightningdevkit/rust-lightning/blob/v0.3-rc4/CHANGELOG.md
[LDK v0.2.8]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.2.8
[ldk v0.1.14]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.14
[LND v0.21.8-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.21.8-beta
[lnd v0.20.8-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.8-beta
[LDK #5507]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5507
[LDK #5532]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5532
[news426 ldk rc]: /en/newsletters/2026/10/09/#ldk-v0-3-rc3
[news412 cltv]: /en/newsletters/2026/07/03/#lnd-10927
[news166 batch]: /en/newsletters/2021/09/15/#lnd-5356
[news424 bolt12]: /en/newsletters/2026/09/25/#lnd-11146
[news419 rawtr]: /en/newsletters/2026/08/21/#draft-bip-for-rawtr-output-script-descriptor
[news213 rawtr]: /en/newsletters/2022/08/17/#bitcoin-core-23480
[news406 coinbase]: /en/newsletters/2026/05/22/#bitcoin-core-34860
