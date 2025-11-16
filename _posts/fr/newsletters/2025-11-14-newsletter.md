---
title: 'Bulletin Hebdomadaire Bitcoin Optech #380'
permalink: /fr/newsletters/2025/11/14/
name: 2025-11-14-newsletter-fr
slug: 2025-11-14-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine inclut nos sections régulières résumant les changements récents
apportés aux clients et services, les annonces de nouvelles versions et de candidats à la publication,
et les résumés des modifications notables apportées aux logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

_Aucune nouvelle significative n'a été trouvée cette semaine dans aucune de nos [sources][optech sources]._

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates._

- [LND 0.20.0-beta.rc4][] est un candidat à la sortie pour une nouvelle version de cette
	implémentation populaire de nœud LN qui introduit de multiples corrections de bugs, un nouveau type
	noopAdd [HTLC][topic htlc], le support pour les adresses de secours [P2TR][topic taproot] sur les
	factures BOLT11, et de nombreuses additions et améliorations pour RPC et `lncli`. Voir les [notes de version][].

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [Serveur
BTCPay][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration de Bitcoin (BIPs)][bips
repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Inquisition Bitcoin][bitcoin
inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #30595][] introduit un en-tête C qui sert d'API pour `libbitcoinkernel` (voir
	le Bulletin [#191][news191 lib], [#198][news198 lib], [#367][news367 lib]), permettant aux projets
	externes d'interfacer avec la logique de validation de blocs et d'état de chaîne de Bitcoin Core via
	une bibliothèque C réutilisable. Actuellement, elle est limitée aux opérations sur les blocs et a
	une parité de fonctionnalités avec le désormais obsolète `libbitcoin-consensus` (voir le [Bulletin
	#288][news288 lib]). Les cas d'utilisation de `libbitcoinkernel` incluent des implémentations
	alternatives de nœuds, un constructeur d'index de serveur Electrum, un scanner de [paiements
	silencieux][topic silent payments], un outil d'analyse de blocs, et un accélérateur de validation de
	scripts, entre autres.

- [Bitcoin Core #33443][] réduit la journalisation excessive lors de la relecture des blocs après un
	redémarrage qui a interrompu une réindexation. Désormais, il émet un message pour la gamme complète
	des blocs en cours de traitement, ainsi que des journaux de progression supplémentaires tous les 10
	000 blocs, plutôt qu'un journal par bloc.

- [Core Lightning #8656][] fait de [P2TR][topic taproot] l'adresse par défaut lors de l'utilisation
	de l'endpoint `newaddr` sans spécifier un type d'adresse, remplaçant P2WPSH.

- [Core Lightning #8671][] ajoute un champ `invoice_msat` au hook `htlc_accepted`, permettant aux
	plugins de remplacer le montant effectif de la facture lors des vérifications de paiement.
	Spécifiquement, il utilise le montant du [HTLC][topic htlc] lorsqu'il diffère
	du montant de la facture. Cela est utile dans les cas où un LSP facture des frais pour transmettre
	un HTLC.

- [LDK #4204][] permet aux pairs d'annuler un [splice][topic splicing] sans devoir fermer le canal
	de force, tant que cela se produit avant l'échange des signatures. Auparavant, tout `tx_abort`
	pendant la négociation du splice déclenchait inutilement une fermeture forcée ; désormais, cela ne
	se produit qu'après l'échange des signatures.

- [BIPs #2022][] met à jour [BIP3][] (voir le [Bulletin #344][news344 bip3]) pour clarifier comment
	les numéros BIP sont attribués. "Un numéro peut être considéré comme attribué uniquement après avoir
	été annoncé publiquement dans la PR par un éditeur BIP." Les annonces sur les réseaux
	sociaux ou une entrée provisoire dans les notes internes de l'éditeur ne devraient pas constituer
	une attribution.

{% include snippets/recap-ad.md when="2025-11-18 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30595,33443,8656,8671,4204,2022" %}
[LND 0.20.0-beta.rc4]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.0-beta.rc4
[release notes]: https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/release-notes-0.20.0.md
[news191 lib]: /en/newsletters/2022/03/16/#bitcoin-core-24304
[news198 lib]: /en/newsletters/2022/05/04/#bitcoin-core-24322
[news367 lib]: /fr/newsletters/2025/08/15/#bitcoin-core-33077
[news288 lib]: /fr/newsletters/2024/02/07/#bitcoin-core-29189
[news344 bip3]: /fr/newsletters/2025/03/07/#bips-1712