---
title: 'Bulletin Hebdomadaire Bitcoin Optech #388'
permalink: /fr/newsletters/2026/01/16/
name: 2026-01-16-newsletter-fr
slug: 2026-01-16-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
La newsletter de cette semaine propose un lien vers une discussion sur le test de mutation
incrémentiel dans Bitcoin Core et annonce le déploiement d'un nouveau processus BIP.
Sont également incluses nos sections régulières résumant les annonces de nouvelles versions
et de candidats à la publication, et les résumés des modifications notables apportées
aux logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

- **Un aperçu du test de mutation incrémentiel dans Bitcoin Core** : Bruno Garcia a 
	[publié][mutant post] sur Delving Bitcoin à propos de son travail actuel sur l'amélioration du
	[test de mutation][news320 mutant] dans Bitcoin Core. Le test de mutation est une technique qui permet aux
	développeurs d'évaluer l'efficacité de leurs tests en ajoutant intentionnellement des bugs
	systémiques, appelés mutants, dans la base de code. Si un test échoue, le mutant est considéré comme
	"tué", signalant que le test est capable de détecter la faute ; sinon, il survit, révélant un
	problème potentiel dans le test.

	Le test de mutation a fourni des résultats significatifs, conduisant à l'ouverture de PR pour
	aborder certains mutants signalés. Cependant, le processus est intensif en ressources, prenant plus
	de 30 heures pour se compléter sur un sous-ensemble de la base de code. C'est la raison pour
	laquelle Garcia se concentre actuellement sur le test de mutation incrémentiel, une technique qui
	applique le test de mutation progressivement, en se concentrant uniquement sur les parties de la
	base de code qui ont changé depuis la dernière analyse. Bien que l'approche soit plus rapide, elle
	prend encore trop de temps.

	Ainsi, Garcia travaille à améliorer l'efficacité du test de mutation incrémentiel de Bitcoin Core,
	suivant un [article][mutant google] de Google. L'approche est basée sur les principes suivants :

	- Éviter les mauvais mutants, tels que ceux syntaxiquement différents du programme original mais
		sémantiquement identiques. Cela signifie ceux qui se comporteront toujours de la même manière, quel
		que soit l'input.

	- Collecter les retours des développeurs pour affiner la génération de mutants, pour comprendre où
		les mutations ont tendance à fournir des résultats non utiles.

	- Ne rapporter qu'un nombre limité de mutants non tués (7, selon la recherche de Google), pour ne
		pas submerger les développeurs avec des mutants potentiellement peu informatifs.

	Garcia a testé son approche sur huit PR différents, recueillant des retours et suggérant des
	changements pour aborder les mutants.

	Pour conclure, Garcia a demandé aux contributeurs de Bitcoin Core de le notifier sur leurs PR s'ils
	souhaitaient un test de mutation et de rapporter des retours sur les mutants fournis.

- **Processus BIP mis à jour** : Après plus de [deux mois][bip3 motion to activate] de
	[discussion][bip3 follow-up to motion] sur la liste de diffusion et un autre tour
	d'[amendements][bips #2051] à la proposition, il est devenu clair cette semaine que BIP3 avait
	atteint un consensus général. Avec le déploiement de BIP3 mercredi, il a remplacé BIP2 comme ligne
	directrice pour le processus BIP. Bien que de grandes parties du processus BIP restent inchangées,
	BIP3 introduit plusieurs simplifications et améliorations.

	Parmi d'autres changements, le système de commentaires est supprimé, le nombre de statuts BIP est
	réduit de neuf (Brouillon, Proposé, Actif, Final, Rejeté, Différé, Retiré, Remplacé et Obsolète) à
	quatre (Brouillon, Complet, Déployé et Fermé), les en-têtes de préambule sont mis à jour, le
	Le type Standards Track est remplacé par le type Specification, et certaines décisions précédemment
	requises des éditeurs BIP sont réattribuées aux auteurs de BIP ou aux lecteurs.

	Un [aperçu de tous les changements][bip2to3] peut être trouvé dans BIP3.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates._

- [Bitcoin Core 30.2][] est une sortie de maintenance qui corrige un bug où le répertoire `wallets`
	entier pouvait être accidentellement supprimé lors de la migration d'un portefeuille hérité anonyme
	(voir le Bulletin [#387][news387 wallet]). Il inclut quelques autres améliorations et corrections ;
	voir les [notes de version][] pour tous les détails.

- [BTCPay Server 2.3.3][] est une sortie mineure de cette solution de paiement auto-hébergée qui
	introduit le support des transactions de portefeuille froid via l'API `Greenfield` (voir
	ci-dessous), supprime les sources de taux de change basées sur CoinGecko, et inclut plusieurs
	corrections de bugs.

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration de Bitcoin (BIPs)][bips
repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin
inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #33819][] introduit une nouvelle méthode `getCoinbaseTx()` sur l'interface `Mining`
	(voir le [Bulletin #310][news310 mining]) pour retourner une structure contenant tous les champs dont
	les clients ont besoin pour construire une transaction coinbase. La méthode existante
	`getCoinbaseTx()`, qui retournait à la place une transaction fictive sérialisée que les clients
	devaient analyser et manipuler, est renommée en `getCoinbaseRawTx()` et est dépréciée aux côtés de
	`getCoinbaseCommitment()`, et `getWitnessCommitmentIndex()`.

- [Bitcoin Core #29415][] ajoute une nouvelle option booléenne `privatebroadcast` pour diffuser des
	transactions via des connexions [Tor][topic anonymity networks] ou I2P de courte durée, ou via le
	proxy Tor vers des pairs IPv4/IPv6, lors de l'utilisation du RPC `sendrawtransaction`. Cette
	approche protège la vie privée de l'initiateur de la transaction en masquant leur adresse IP et en
	utilisant des connexions séparées pour chaque transaction pour empêcher la corrélation.

- [Core Lightning #8830][] ajoute une commande `getsecret` à l'utilitaire `hsmtool` (voir le
	[Bulletin #73][news73 hsmtool]) qui remplace la commande existante `getsecretcodex` avec un
	support supplémentaire pour la récupération de nœuds créés après les changements introduits dans
	la v25.12 (voir le [Bulletin #383][news383 bip39]). La nouvelle commande produit la phrase de semence
	mnémonique [BIP39][] pour un fichier `hsm_secret` donné pour les nouveaux nœuds, et conserve la
	fonctionnalité de sortie de la chaine
	`Codex32` pour les nœuds hérités. Le plugin `recover` est mis à jour pour accepter les
	mnémoniques.

- [Eclair #3233][] commence à utiliser les taux de frais par défaut configurés lorsque Bitcoin Core
	échoue à estimer les frais sur [testnet3][topic testnet] ou testnet4 en raison de données de bloc
	insuffisantes. Les taux de frais par défaut sont mis à jour pour mieux correspondre aux valeurs
	actuelles.

- [Eclair #3237][] retravaille les événements du cycle de vie du canal pour être compatible avec le
	[splicing][topic splicing] et cohérent avec [zero-conf][topic zero-conf channels] en ajoutant les
	suivants : `channel-confirmed`, qui signale que la transaction de financement ou le splice a été
	confirmé, et `channel-ready`, qui signale que le canal est prêt pour les paiements. L'événement
	`channel-opened` est supprimé.

- [LDK #4232][] ajoute le support pour le signal expérimental `accountable`, qui remplace le [HTLC
	endorsement][topic htlc endorsement], comme proposé dans [BLIPs #67][] et [BOLTs #1280][]. LDK
	définit maintenant des signaux comptables de valeur zéro sur ses propres paiements et sur les
	transferts sans signal, et copie la valeur comptable entrante vers les transferts sortants
	lorsqu'elle est présente. Cela suit des changements similaires dans Eclair et LND (voir le [Bulletin
	#387][news387 accountable]).

- [LND #10296][] ajoute un champ `inputs` à la commande RPC `EstimateFee` permettant aux
	utilisateurs d'obtenir une [estimation des frais][topic fee estimation] pour une transaction en
	utilisant des entrées spécifiques au lieu de laisser le portefeuille les sélectionner
	automatiquement.

- [BTCPay Server #7068][] ajoute le support pour les transactions de portefeuille froid via l'API
	`Greenfield`, permettant aux utilisateurs de générer des [PSBTs][topic psbt] non signés et de
	diffuser des transactions signées extérieurement via un nouveau point de terminaison. Cette
	fonctionnalité offre une plus grande sécurité dans les environnements automatisés et permet des
	configurations qui répondent à des exigences de conformité réglementaire plus élevées.

- [BIPs #1982][] ajoute [BIP433][] pour spécifier le type de sortie standard [Pay-to-Anchor
	(P2A)][topic ephemeral anchors] et rend la dépense de ce type de sortie standard.

{% include snippets/recap-ad.md when="2026-01-20 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33819,29415,8830,3233,3237,4232,67,1280,10296,7068,1982,2051" %}
[mutant post]: https://delvingbitcoin.org/t/incremental-mutation-testing-in-the-bitcoin-core/2197
[news320 mutant]:/en/newsletters/2024/09/13/#mutation-testing-for-bitcoin-core
[mutant google]: https://research.google/pubs/state-of-mutation-testing-at-google/
[Bitcoin Core 30.2]: https://bitcoincore.org/bin/bitcoin-core-30.2/
[notes de version]: https://bitcoincore.org/en/releases/30.2/
[BTCPay Server 2.3.3]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.3.3
[news387 wallet]: /en/newsletters/2026/01/09/#bitcoin-core-34156
[news310 mining]: /en/newsletters/2024/07/05/#bitcoin-core-30200
[news73 hsmtool]: /en/newsletters/2019/11/20/#c-lightning-3186
[news383 bip39]: /en/newsletters/2025/12/05/#core-lightning-v25-12
[news387 accountable]: /en/newsletters/2026/01/09/#eclair-3217
[bip2to3]: https://github.com/bitcoin/bips/blob/master/bip-0003.md#changes-from-bip2
[bip3 motion to activate]: https://gnusha.org/pi/bitcoindev/205b3532-ccc1-4b2f-964f-264fc6e0e70b@murch.one/
[bip3 follow-up to motion]: https://gnusha.org/pi/bitcoindev/1d76a085-deff-4df2-8a82-f8bd984fac27@murch.one/
