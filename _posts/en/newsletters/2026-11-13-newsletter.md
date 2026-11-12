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

{% include snippets/recap-ad.md when="2026-11-17 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33504,33395,32646" %}

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
