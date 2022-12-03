---
title: 'Bitcoin Optech Newsletter #228'
permalink: /fr/newsletters/2022/11/30/
name: 2022-11-30-newsletter-fr
slug: 2022-11-30-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
La lettre d'information de cette semaine décrit une proposition visant à
permettre d'atténuer les attaques par brouillage de LN en utilisant des
jetons de réputation. sont également inclus les résumés des modifications
apportées aux services et aux logiciels clients, des annonces de nouvelles
versions et de versions candidates, et des descriptions d'ajout sur les
projets d'infrastructure Bitcoin populaires.

## Nouvelles

- **Proposition de références de réputation pour atténuer les attaques de brouillage LN :**
  Antoine Riard [a posté][riard credentials] sur la liste de diffusion de
  Lightning-Dev une [proposition][riard proposal] pour un nouveau système
  de réputation basé sur les références pour aider à empêcher les attaquants
  de bloquer temporairement les créneaux de paiement ([HTLC][topic htlc]) ou
  la valeur, empêchant ainsi les utilisateurs honnêtes de pouvoir envoyer des
  paiements---un problème appelé [attaque par brouillage de canal][topic channel jamming attacks].

    Dans le réseau LN actuel, les emprunteurs choisissent un chemin entre leur
    nœud et le nœud récepteur sur plusieurs canaux exploités par des nœuds de
    transfert indépendants. Ils créent un ensemble d'instructions sans confiance
    qui décrivent où chaque nœud de transmission doit relayer le paiement, en
    cryptant ces instructions afin que chaque nœud ne reçoive que les informations
    minimales dont il a besoin pour faire son travail.

    Riard propose que chaque nœud de transmission n'accepte les instructions de
    relais que si elles comprennent un ou plusieurs jetons d'authentification qui
    ont été précédemment émis par ce nœud de transmission. Les justificatifs
    comprennent une [signature aveugle][] qui empêche le nœud de transmission de
    déterminer directement quel nœud a émis le justificatif (empêchant le nœud de
    transmission de connaître l'identité réseau de l'expéditeur).  Chaque nœud peut
    émettre des lettres de créance selon sa propre politique, bien que Riard suggère
    plusieurs méthodes de distribution :

    - *paiement initial :* si le nœud d'Alice veut faire transiter des
      paiements par le nœud de Bob, son nœud utilise d'abord LN pour
      acheter une créance à Bob.

    - *Réussite précédente :* si un paiement qu'Alice a envoyé par le
      biais du nœud de Bob est accepté par le destinataire final, le
      nœud de Bob peut renvoyer un jeton de créance au nœud d'Alice---ou
      même plus de jetons que ceux utilisés précédemment, ce qui permet
      au nœud d'Alice d'envoyer une valeur supplémentaire par le biais
      du nœud de Bob à l'avenir.

    - *UTXO ownership proofs or other alternatives:* although not
      necessary for Riard's initial proposal, some forwarding nodes may
      experiment with giving credentials to everyone who proves they own
      a Bitcoin UTXO, perhaps with modifiers that give older or
      higher-value UTXOs more credential tokens than newer or
      lower-value UTXOs.  Any other criteria can be used as each
      forwarding node chooses for itself how to distribute its
      credential tokens.

    Clara Shikhelman, whose own co-authored proposal partly based on
    local reputation was described in [Newsletter #226][news226 jam],
    replied to [ask][shikelman credentials] whether credential tokens
    were transferable between users and whether that could lead to the
    creation of a market for tokens.  She also asked how they would work
    with [blinded paths][topic rv routing] where a spending node
    wouldn't know the full path to the receiving node.

    Riard [replied][riard double spend] that it would be difficult to
    redistribute credential tokens and create a market for them because
    any transfer would require trust.  For example, if Bob's node
    issues a new credential to Alice, who then tries to sell the
    credential to Carol, there's no trustless way for Alice to prove she
    won't try to use the token herself even after Carol has paid her.

    For blinded paths, [it appears][harding paths] the receiver can
    provide any necessary credentials in an encrypted form without
    introducing a secondary vulnerability.

    Additional feedback for the proposals was received on its related
    [pull request][bolts #1043].

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND 0.15.5-beta.rc2][] is a release candidate for a maintenance
  release of LND.  It contains only minor bug fixes according to its
  planned release notes.

- [Core Lightning 22.11rc3][] is a release candidate for the next major
  version of CLN.  It'll also be the first release to use a new version
  numbering scheme, although CLN releases continue to use [semantic
  versioning][].

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Core Lightning #5727][] begins deprecating numeric JSON request IDs
  in favor of IDs using the string type.  [Documentation][cln json ids]
  is added describing the benefit of string IDs and how to get the most
  out of creating and interpreting them.

- [Eclair #2499][] allows specifying a blinded route to use when using a
  [BOLT12 offer][topic offers] to request payment.  The route may
  include a route leading up to the user's node plus additional hops
  going past it.  The hops going past the node won't be used, but they
  will make it harder for the spender to determine how many hops the
  receiver is from the last non-blinded forwarding node in the route.

- [LND #7122][] adds support to `lncli` for processing binary [PSBT][topic
  psbt] files. [BIP174][] specifies that PSBTs may be encoded either as plain
  text Base64 or binary in a file. Prior, LND already supported importing
  Base64-encoded PSBTs either as plain text or from file.

- [LDK #1852][] accepts a feerate increase proposed by a channel peer
  even if that feerate isn't high enough to safely keep the channel
  open at present.  Even if the new feerate isn't entirely safe, its
  higher value means it's safer than what the node had before, so it's
  better to accept it than try to close the channel with its existing
  lower feerate.  A future change to LDK may close channels with
  feerates that are too low, and work on proposals like [package
  relay][topic package relay] may make [anchor outputs][topic anchor
  outputs] or similar techniques adaptable enough to eliminate concerns
  about present feerates.

- [Libsecp256k1 #993][] includes in the default build options the
  modules for extrakeys (functions for working with x-only pubkeys),
  [ECDH][], and [schnorr signatures][topic schnorr signatures].  The
  module for reconstructing a public key from a signature is still not
  built by default "because we don't recommend ECDSA recovery for new
  protocols. In particular, the recovery API is prone to misuse: It
  invites the caller to forget to check the public key (and the
  verification function always returns 1)."

{% include references.md %}
{% include linkers/issues.md v=2 issues="5727,2499,7122,1852,993,1043" %}
[bitcoin core 24.0]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[bcc 24.0 rn]: https://github.com/bitcoin/bitcoin/blob/0ee1cfe94a1b735edc2581a05c4b12f8340ff609/doc/release-notes.md
[news222 rbf]: /fr/newsletters/2022/10/19/#option-de-remplacement-de-transaction
[news223 rbf]: /fr/newsletters/2022/10/26/#poursuite-de-la-discussion-sur-le-full-rbf
[news224 rbf]: /fr/newsletters/2022/11/02/#coherence-mempool
[lnd 0.15.5-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.5-beta.rc2
[core lightning 22.11rc3]: https://github.com/ElementsProject/lightning/releases/tag/v22.11rc3
[cln json ids]: https://github.com/rustyrussell/lightning/blob/a25c5d14fe986b67178988e6ebb79610672cc829/doc/lightningd-rpc.7.md#json-ids
[riard credentials]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-November/003754.html
[riard proposal]: https://github.com/lightning/bolts/blob/80214c83190836c4f7699af9e8920769607f1a00/www-reputation-credentials-protocol.md
[blind signature]: https://en.wikipedia.org/wiki/Blind_signature
[news226 jam]: /fr/newsletters/2022/11/16/#document-sur-les-attaques-par-brouillage-de-canaux
[shikelman credentials]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-November/003755.html
[riard double spend]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-November/003765.html
[harding paths]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-November/003767.html
[ecdh]: https://en.wikipedia.org/wiki/Elliptic-curve_Diffie%E2%80%93Hellman
[semantic versioning]: https://semver.org/spec/v2.0.0.html
