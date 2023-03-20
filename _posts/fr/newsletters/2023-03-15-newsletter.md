---
title: 'Bulletin hebdomadaire Bitcoin Optech #242'
permalink: /fr/newsletters/2023/03/15/
name: 2023-03-15-newsletter-fr
slug: 2023-03-15-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
La lettre d'information de cette semaine relaie l'annonce d'un bit de service
utilisé pour tester Utreexo, propose des liens vers plusieurs nouvelles versions
de logiciels et versions candidates, et décrit un PR fusionnée à Bitcoin Core.

## Nouvelles

- **Service bit for Utreexo:** Calvin Kim a [posté][kim utreexo] sur la
  liste de diffusion Bitcoin-Dev que le logiciel actuellement conçu pour
  l'expérimentation sur signet et testnet utilisera le service de protocole
  P2P bit 24. Le logiciel expérimental prend en charge [Utreexo][topic utreexo],
  un protocole permettant la vérification complète des transactions par des
  nœuds qui ne stockent pas de copie de l'ensemble UTXO, ce qui permet d'économiser
  jusqu'à 5 Go d'espace disque par rapport à un nœud complet moderne de Bitcoin Core
  (sans réduction de la sécurité). Un nœud Utreexo doit recevoir des données
  supplémentaires lorsqu'il reçoit une transaction non confirmée (ou un bloc
  plein de transactions confirmées), le bit de service aidera donc un nœud à
  trouver des pairs capables de fournir les données supplémentaires.

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets d’infrastructure
Bitcoin. Veuillez envisager de passer aux nouvelles versions ou d’aider à tester
les versions candidates.*

- [Core Lightning v23.02.2][] est une version de maintenance de ce logiciel
  de nœud LN. Elle annule une modification de la RPC `pay` qui a causé des
  problèmes à d'autres logiciels et inclut plusieurs autres changements.

- [Libsecp256k1 0.3.0][] cette bibliothèque cryptographique. Elle inclut
  un changement d'API qui rompt la compatibilité ABI.

- [LND v0.16.0-beta.rc3][] est une version candidate pour une nouvelle
  version majeure de cette implémentation populaire de LN.

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], et [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #25740][] permet à un nœud utilisant [assumeUTXO][topic assumeutxo] de vérifier
  tous les blocs et toutes les transactions sur la meilleure chaîne de blocs jusqu'à ce qu'il
  atteigne le bloc où l'état assumeUTXO prétend avoir été généré, en construisant un ensemble
  UTXO (chainstate) à partir de ce bloc. Si cet état de chaîne est égal à l'état assumeUTXO
  téléchargé lors du premier démarrage du nœud, l'état est entièrement validé. Le nœud a validé
  chaque bloc de la meilleure chaîne de blocs, comme tout autre nœud complet, mais dans un ordre
  différent de celui d'un nœud standard. L'état de chaîne spécial utilisé pour effectuer la
  vérification des blocs plus anciens est supprimé au prochain démarrage du nœud, ce qui libère
  de l'espace disque. D'autres parties du [projet assumeUTXO][] doivent encore être fusionnées
  avant qu'il ne soit utilisable.

{% include references.md %}
{% include linkers/issues.md v=2 issues="25740" %}
[lnd v0.16.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.0-beta.rc3
[libsecp256k1 0.3.0]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.3.0
[core lightning v23.02.2]: https://github.com/ElementsProject/lightning/releases/tag/v23.02.2
[kim utreexo]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-March/021515.html
[projet assumeutxo]: https://github.com/bitcoin/bitcoin/projects/11
