---
title: 'Bulletin Hebdomadaire Optech #371'
permalink: /fr/newsletters/2025/09/12/
name: 2025-09-12-newsletter-fr
slug: 2025-09-12-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine annonce la disponibilité d'un cahier d'exercices dédié à la
cryptographie prouvable. Sont également incluses nos sections régulières résumant les
changements récents apportés aux clients et services, les annonces de nouvelles versions
et de candidats à la publication, et les résumés des modifications
notables apportées aux logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

- **Cahier d'exercices sur la Cryptographie Prouvable :** Jonas Nick a [publié][nick workbook] sur
	Delving Bitcoin pour annoncer un court cahier d'exercices qu'il a créé pour un événement de quatre
	jours visant à "enseigner aux développeurs les bases de la cryptographie prouvable, [...] comprenant
	des définitions cryptographiques, des propositions, des preuves et des exercices." Le cahier
	d'exercices est disponible en tant que [PDF][workbook pdf] avec une [source][workbook source]
	sous licence libre.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates._

- [Bitcoin Core 29.1][] est la sortie d'une version de maintenance du logiciel de nœud complet
	prédominant.

- [Eclair v0.13.0][] est la sortie de cette implémentation de nœud LN. Sa sortie contient beaucoup
	de refactorisation, une implémentation initiale des canaux taproot, [...] des améliorations au
	splicing basées sur des mises à jour récentes de spécification, et un meilleur support de Bolt 12."
	Les fonctionnalités de canaux taproot et de splicing sont encore en cours de spécification, donc
	elles ne devraient pas être utilisées par les utilisateurs réguliers. Les notes de version
	avertissent également : "Ceci est la dernière sortie d'eclair où les canaux qui n'utilisent pas les
	anchor outputs seront supportés. Si vous avez des canaux qui n'utilisent pas les anchor outputs,
	vous devriez les fermer."

- [Bitcoin Core 30.0rc1][] est une candidate à la sortie pour la prochaine version majeure de ce
	logiciel de nœud de vérification complète.

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration de Bitcoin (BIPs)][bips
repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin
inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #30469][] met à jour les types des valeurs `m_total_prevout_spent_amount`,
	`m_total_new_outputs_ex_coinbase_amount` et `m_total_coinbase_amount` de `CAmount` (64 bits) à
	`arith_uint256` (256 bits) pour prévenir un bug de dépassement de valeur par défaut qui a déjà été
	observé sur le [signet][topic signet]. La nouvelle version de l'index des statistiques de pièces est
	stockée dans `/indexes/coinstatsindex/` et un nœud mis à niveau devra se synchroniser à partir de
	zéro pour reconstruire l'index. L'ancienne version est conservée pour une protection de la rétrogradation,
	mais pourrait être retirée dans une future mise à jour.

- [Eclair #3163][] ajoute un vecteur de test pour s'assurer que la clé publique d'un bénéficiaire
	peut être récupérée à partir d'une facture [BOLT11][] avec une signature high-S, en plus de
	permettre déjà les signatures low-S. Cela s'aligne sur le comportement de libsecp256k1 et la
	proposition [BOLTs #1284][].

- [Eclair #2308][] introduit une nouvelle option `use-past-relay-data` qui, lorsqu'elle est définie
	sur vrai (par défaut faux), utilise une approche probabiliste basée sur l'historique des tentatives
	de paiement passées pour améliorer la recherche de chemin. Cela remplace une méthode antérieure qui
	supposait une uniformité dans les soldes des canaux.

- [Eclair #3021][] permet au non-initiateur d'un [canal à double financement][topic dual funding] de
	[RBF][topic rbf] la transaction de financement, ce qui est déjà autorisé dans les transactions de
	[splicing][topic splicing]. Cependant, une exception s'applique aux transactions d'achat de
	[publicité de liquidité][topic liquidity advertisements]. Cela a été proposé dans [BOLTs #1236][].

- [Eclair #3142][] ajoute un nouveau paramètre `maxClosingFeerateSatByte` à l'endpoint API
	`forceclose` qui remplace la configuration globale de feerate pour les transactions de fermeture
	forcée non urgentes sur une base par canal. Le paramètre global `max-closing-feerate` a été
	introduit dans [Eclair #3097][].

- [LDK #4053][] introduit des canaux d'engagement sans frais en remplaçant les deux sorties d'ancre
	par une sortie [Pay-to-Anchor (P2A)][topic ephemeral anchors] partagée, plafonnée à une valeur de
	240 sats. De plus, il passe les signatures HTLC dans les canaux d'engagement sans frais à
	`SIGHASH_SINGLE|ANYONECANPAY` et augmente les transactions HTLC à [version 3][topic v3 transaction
	relay].

- [LDK #3886][] étend `channel_reestablish` pour le [splicing][topic splicing] avec deux TLVs
	`funding_locked_txid` (ce qu'un nœud a envoyé et reçu en dernier) afin que les pairs puissent
	concilier la transaction de financement active lors de la reconnexion. De plus, il rationalise le
	processus de reconnexion en renvoyant `commitment_signed` avant `tx_signatures`, en gérant
	`splice_locked` de manière implicite, en adoptant `next_funding`, et en demandant des signatures
	d'annonce au besoin.

{% include snippets/recap-ad.md when="2025-09-16 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30469,3163,2308,3021,3142,4053,3886,1284,1236,3097" %}
[bitcoin core 29.1]: https://bitcoincore.org/bin/bitcoin-core-29.1/
[bitcoin core 30.0rc1]: https://bitcoincore.org/bin/bitcoin-core-30.0/
[nick workbook]: https://delvingbitcoin.org/t/provable-cryptography-for-bitcoin-an-introduction-workbook/1974
[workbook pdf]: https://github.com/cryptography-camp/workbook/releases
[workbook source]: https://github.com/cryptography-camp/workbook
[Eclair v0.13.0]: https://github.com/ACINQ/eclair/releases/tag/v0.13.0