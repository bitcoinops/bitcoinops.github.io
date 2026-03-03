---
title: 'Bulletin Hebdomadaire Bitcoin Optech #384'
permalink: /fr/newsletters/2025/12/12/
name: 2025-12-12-newsletter-fr
slug: 2025-12-12-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine révèle des vulnérabilités dans LND et décrit un projet pour exécuter
une machine virtuelle dans un élément sécurisé embarqué. Sont également incluses nos sections
régulières décrivant les changements apportés aux services et aux logiciels clients, résumant les
questions et réponses populaires du Bitcoin Stack Exchange, et examinant les récents changements
apportés aux logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

- **Vulnérabilités critiques corrigées dans LND 0.19.0 :** Matt Morehouse a [publié][morehouse
	delving] sur Delving Bitcoin concernant des vulnérabilités critiques corrigées dans LND 0.19.0. Dans
	cette divulgation, trois vulnérabilités sont mentionnées, incluant une de déni de service (DoS) et
	deux de vol de fonds.

	- *Vulnérabilité de DoS par épuisement de mémoire lors du traitement des messages :* Cette
		[vulnérabilité de DoS][lnd vln1] profitait du fait que LND autorisait autant de pairs qu'il y avait
		de descripteurs de fichiers disponibles. L'attaquant pouvait ouvrir de multiples connexions avec la
		victime et spammer des messages `query_short_channel_ids` de 64 Ko tout en maintenant la connexion
		ouverte jusqu'à ce que LND manque de mémoire. La mitigation pour cette vulnérabilité a été mise en
		œuvre dans LND 0.19.0 le 12 mars 2025.

	- *Perte de fonds due à une nouvelle vulnérabilité de failback excessive :* [Cette attaque][lnd
		vln2] est une variante du [bug de failback excessif][morehouse failback bug], et bien que la
		correction originale pour le bug de failback ait été faite dans LND 0.18.0, une variante mineure
		subsistait lorsque le canal était fermé de force en utilisant l'engagement de LND au lieu de celui
		de l'attaquant. La mitigation pour cette vulnérabilité a été mise en œuvre dans LND 0.19.0 le 20
		mars 2025.

	- *Vulnérabilité de perte de fonds dans le balayage HTLC :* Cette [vulnérabilité de vol de
		fonds][lnd vln3] profitait des faiblesses du système de balayage de LND, permettant à un attaquant
		de bloquer les tentatives de LND de réclamer sur onchain les HTLC expirés. Après avoir bloqué
		pendant 80 blocs, l'attaquant pouvait alors voler essentiellement tout le solde du canal.

	Morehouse incite les utilisateurs à mettre à niveau vers [LND 0.19.0][lnd version] ou une version
	supérieure pour éviter le déni de service et la perte de fonds.

- **Un enclave sécurisé virtualisé pour les dispositifs de signature matérielle :** Salvatoshi a
	[publié][vanadium post] sur Delving Bitcoin à propos de [Vanadium][vanadium github], un enclave
	sécurisé virtualisé pour les dispositifs de signature matérielle. Vanadium est une machine virtuelle
	RISC-V, conçue pour exécuter des applications arbitraires, appelées "V-Apps", dans un élément
	sécurisé embarqué, externalisant les besoins de mémoire et de stockage vers un hôte non fiable.
	Selon Salvatoshi, l'objectif de Vanadium est d'abstraire les complexités du développement embarqué,
	telles que la RAM et le stockage limités, les SDK spécifiques aux fournisseurs, les cycles de
	développement lents et le débogage, pour rendre l'innovation en auto-garde plus rapide, plus ouverte
	et standardisée.

	Salvatoshi note que, d'un point de vue performance, la machine virtuelle exécute uniquement la
	logique métier de l'application, tandis que les opérations lourdes (c.-à-d. la cryptographie)
	s'exécutent de manière native via des ECALLs.
	Bien que le modèle de menace soit le même que pour les portefeuilles matériels existants, Salvatoshi
	souligne que cette approche permet une fuite du schéma d'accès à la mémoire, où l'hôte peut observer
	quelles pages de code et de données sont accédées et quand. Cela est particulièrement important pour
	les développeurs en cryptographie.

	Le projet n'est toujours pas considéré comme prêt pour la production, et il existe certaines
	limitations connues, telles que la performance et l'expérience utilisateur (UX). Cependant,
	Salvatoshi a demandé aux développeurs de l'essayer et de fournir des retours pour établir la feuille
	de route du projet.

## Changements dans les services et les logiciels clients

*Dans cette rubrique mensuelle, nous mettons en lumière des mises à jour intéressantes des
portefeuilles et services Bitcoin.*

- **Outil de visualisation de transactions interactif :**
	[RawBit][rawbit delving] est un outil de visualisation de transactions [basé sur le web][rawbit
	website], [open-source][rawbit github]. Il propose des leçons interactives sur une variété de types
	de transactions avec des plans pour des leçons supplémentaires sur taproot, [PSBTs][topic psbt],
	[HTLCs][topic htlc], [coinjoins][topic coinjoin], et des propositions de covenant.

- **BlueWallet v7.2.2 publié :**
	La [version 7.2.2 de BlueWallet][bluewallet v7.2.2] ajoute le support pour les portefeuilles
	[taproot][topic taproot], incluant l'envoi, la réception, le suivi seulement, le contrôle des
	pièces, et les fonctionnalités de signature avec dispositif matériel.

- **Mises à jour de Stratum v2 :**
	Stratum v2 [v1.6.0][sv2 v1.6.0] réorganise les dépôts Stratum v2, ajoutant un [dépôt sv2-apps et une
	version v.01][sv2-apps] supportant la communication directe avec les nœuds Bitcoin Core 30.0 non
	modifiés utilisant IPC (voir le [Bulletin #369][news369 ipc]). Les versions incluent également des
	outils web pour les [mineurs][sv2 wizard miners] et les [développeurs][sv2 wizard devs] pour les
	tests, parmi d'autres fonctionnalités.

- **Auradine annonce le support de Stratum v2 :**
	Auradine [a annoncé][auradine tweet] le support des fonctionnalités de Stratum v2 dans leurs
	mineurs.

- **LDK Node 0.7.0 publié :**
	[LDK Node 0.7.0][ldk node blog] ajoute un support expérimental pour le [splicing][topic splicing] et le
	support pour servir et payer des factures statiques par [paiements asynchrones][topic async
	payments], parmi d'autres fonctionnalités et corrections de bugs.

- **Librairie Python BIP-329 1.0.0 publiée :**
	La version [1.0.0][bip329 python 1.0.0] de la [Librairie Python BIP-329][news273 329 lib] prend en
	charge les champs supplémentaires de [BIP329][], incluant la validation type et la couverture des
	tests.

- **Bitcoin Safe 1.6.0 publié :**
	La [version 1.6.0][bitcoin safe 1.6.0] ajoute le support pour les [filtres de blocs compacts][topic
	compact block filters] et les [constructions reproductibles][topic reproducible builds].

## Questions et réponses sélectionnées de Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech
cherchent des réponses à leurs questions---ou quand nous avons quelques moments libres pour aider
les utilisateurs curieux ou confus. Dans cette rubrique mensuelle, nous mettons en lumière certaines
des questions et réponses les mieux votées postées depuis notre dernière mise à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Une connexion clearnet à mon nœud Lightning nécessite-t-elle un certificat TLS ?]({{bse}}129303)
	Pieter Wuille souligne que dans LN, les utilisateurs spécifient une clé publique comme partie de la
	connexion à un pair, donc "Il n'est pas nécessaire qu'une tierce partie de confiance atteste de la
	justesse de cette clé publique, car il incombe à l'utilisateur de configurer correctement la clé
	publique".

- [Pourquoi différentes implémentations produisent-elles différentes signatures DER pour la même clé privée et le même hash ?]({{bse}}129270)
	L'utilisateur dave_thompson_085 explique que différentes implémentations peuvent produire
	différentes signatures ECDSA valides parce que l'algorithme est intrinsèquement aléatoire à moins
	que la génération de nonce déterministe RFC 6979 soit utilisée.

- [Pourquoi la valeur `after` de miniscript est-elle limitée à 0x80000000 ?]({{bse}}129253)
	Murch répond que [miniscript][topic miniscript] limite les `after(n)` timelocks basés sur le temps
	CLTV [timelocks][topic timelocks] à un maximum de 2<sup>31</sup> - 1 (représentant un temps dans
	l'année 2038) parce que les entiers du Script Bitcoin sont des valeurs *signées* de 4 octets, tandis
	que les locktimes basés sur la hauteur de bloc peuvent dépasser le seuil de 2038.

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration de Bitcoin (BIPs)][bips
repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin
inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #33528][] empêche le portefeuille de dépenser les sorties de transactions
	[TRUC][topic v3 transaction relay] non confirmées ayant un ancêtre non confirmé, pour se conformer
	aux limites de politique TRUC. Auparavant, le portefeuille pouvait créer de telles transactions,
	mais elles étaient rejetées lors de la diffusion.

- [Bitcoin Core #33723][] retire `dnsseed.bitcoin.dashjr-list-of-p2p-nodes.us` de la liste des
	graines DNS. Les mainteneurs ont trouvé que c'était la seule graine qui omettait les nouvelles
	versions de Bitcoin Core (29 et 30), violant la politique stipulant que "les résultats des graines
	doivent consister exclusivement de nœuds Bitcoin sélectionnés de manière équitable et fonctionnant
	sur le réseau public”.

- [Bitcoin Core #33993][] met à jour le texte d'aide pour l'option `stopatheight`, clarifiant que la
	hauteur cible spécifiée pour arrêter la synchronisation est seulement une estimation et que des
	blocs après cette hauteur peuvent encore être traités pendant l'arrêt.

- [Bitcoin Core #33553][] ajoute un message d'avertissement indiquant une potentielle corruption de
	la base de données lorsque des en-têtes sont reçus pour des blocs qui étaient précédemment marqués
	comme invalide. Cela aide les utilisateurs à réaliser qu'ils pourraient être coincés dans une boucle de
	synchronisation d'en-tête. Cette PR active également un message d'avertissement de détection de fork
	qui était précédemment désactivé pour l'IBD.

- [Eclair #3220][] étend le helper `spendFromChannelAddress` existant aux [canaux taproot][topic
	simple taproot channels], ajoutant un endpoint `spendfromtaprootchanneladdress` qui permet aux
	utilisateurs de dépenser de manière coopérative les UTXOs envoyés accidentellement aux adresses de
	financement de canal [taproot][topic taproot], avec des signatures [MuSig2][topic musig].

- [LDK #4231][] arrête de fermer de force les [canaux zero-conf][topic zero-conf channels]
	lorsqu'une réorganisation de blocs déconfirme la transaction de financement du canal. LDK a un
	mécanisme pour fermer de force les canaux verrouillés qui deviennent non confirmés en raison du
	risque de double dépense. Cependant, le modèle de confiance est différent pour les canaux zero-conf.
	Le changement de SCID est également maintenant correctement géré dans ce cas limite.

- [LND #10396][] renforce l'heuristique du routeur pour détecter les nœuds assistés par LSP : les
	factures avec un nœud de destination public ou dont les sauts de destination de l'indice de route
	sont tous privés sont maintenant traités comme des nœuds normaux, tandis que ceux avec une
	destination privée et au moins un saut de destination public sont classifiés comme soutenus par LSP.
	Auparavant, l'heuristique plus lâche pouvait mal classer les nœuds comme assistés par LSP,
	entraînant plus d'échecs de sondage. Maintenant, lorsqu'un nœud assisté par LSP est détecté, LND
	sonde jusqu'à trois LSP candidats et utilise l'itinéraire le plus défavorable (frais les plus élevés
	et CLTV) pour fournir des estimations de frais conservatrices.

- [BTCPay Server #7022][] introduit une API pour la fonctionnalité `Subscriptions` (voir le [Bulletin
	#379][news379 btcpay]), permettant aux commerçants de créer et de gérer des offres, des plans, des
	abonnés et des checkouts. Environ une douzaine de points de terminaison ont été ajoutés pour chaque
	opération spécifique.

- [Rust Bitcoin #5379][] ajoute une méthode pour construire des adresses [Pay-to-Anchor (P2A)][topic
	ephemeral anchors], pour compléter la méthode existante de vérification des adresses P2A.

- [BIPs #2050][] met à jour [BIP390][], qui spécifie les descripteurs [MuSig2][topic musig], pour
	permettre des expressions de clé `musig()` à l'intérieur d'un `rawtr()` en plus du `tr()` déjà
	autorisé, alignant la description avec les vecteurs de test existants et l'implémentation des
	descripteurs de Bitcoin Core.

## Joyeuses fêtes !

Ceci est le dernier bulletin régulier de Bitcoin Optech de l'année. Le vendredi 19 décembre,
nous publierons notre huitième bulletin de révision annuel. La publication régulière
reprendra le vendredi 2 janvier.

{% include snippets/recap-ad.md when="2025-12-16 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33528,33723,33993,33553,3220,4231,10396,7022,5379,2050" %}
[morehouse delving]: https://delvingbitcoin.org/t/disclosure-critical-vulnerabilities-fixed-in-lnd-0-19-0/2145
[lnd vln1]: https://morehouse.github.io/lightning/lnd-infinite-inbox-dos/
[lnd vln2]: https://morehouse.github.io/lightning/lnd-excessive-failback-exploit-2/
[lnd vln3]: https://morehouse.github.io/lightning/lnd-replacement-stalling-attack/
[lnd version]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta
[morehouse failback bug]: /fr/newsletters/2025/03/07/#divulgation-d-une-vulnerabilite-corrigee-lnd-permettant-le-vol
[vanadium post]: https://delvingbitcoin.org/t/vanadium-a-virtualized-secure-enclave-for-hardware-signing-devices/2142
[vanadium github]: https://github.com/LedgerHQ/vanadium
[rawbit delving]: https://delvingbitcoin.org/t/raw-it-the-visual-raw-transaction-builder-script-debugger/2119
[rawbit github]: https://github.com/rawBit-io/rawbit
[rawbit website]: https://rawbit.io/
[bluewallet v7.2.2]: https://github.com/BlueWallet/BlueWallet/releases/tag/v7.2.2
[sv2 v1.6.0]: https://github.com/stratum-mining/stratum/releases/tag/v1.6.0
[sv2-apps]: https://github.com/stratum-mining/sv2-apps/releases/tag/v0.1.0
[news369 ipc]: /fr/newsletters/2025/08/29/#bitcoin-core-31802
[sv2 wizard miners]: https://stratumprotocol.org/get-started
[sv2 wizard devs]: https://stratumprotocol.org/developers
[auradine tweet]: https://x.com/Auradine_Inc/status/1991159535864803665?s=20
[ldk node blog]: https://newreleases.io/project/github/lightningdevkit/ldk-node/release/v0.7.0
[news273 329 lib]: /fr/newsletters/2023/10/18/#sortie-de-la-bibliotheque-python-bip-329
[bip329 python 1.0.0]: https://github.com/Labelbase/python-bip329/releases/tag/1.0.0
[bitcoin safe 1.6.0]: https://github.com/andreasgriffin/bitcoin-safe/releases/tag/1.6.0
[news379 btcpay]: /fr/newsletters/2025/11/07/#btcpay-server-6922