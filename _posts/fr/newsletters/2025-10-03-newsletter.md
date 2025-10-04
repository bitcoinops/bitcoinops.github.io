---
title: 'Bulletin Hebdomadaire Bitcoin Optech #374'
permalink: /fr/newsletters/2025/10/03/
name: 2025-10-03-newsletter-fr
slug: 2025-10-03-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine inclut nos sections régulières résumant les récentes discussions sur
la modification des règles de consensus de Bitcoin, annonçant des mises à jour et des versions candidates,
et décrivant les changements notables dans les projets d'infrastructure Bitcoin populaires.

## Nouvelles

_Aucune nouvelle significative n'a été trouvée cette semaine dans aucune de nos [sources][optech
sources]._

## Modification du consensus

_Une nouvelle section mensuelle résumant les propositions et discussions sur la modification des
règles de consensus de Bitcoin._

- **Brouillons de BIP pour la Restauration de Script :** Rusty Russell a posté sur la liste de
	diffusion Bitcoin-Dev un [résumé][rr0] et quatre BIP ([1][rr1], [2][rr2], [3][rr3], [4][rr4]) à
	différents stades de brouillon relatifs à une proposition pour restaurer les capacités de Script
	dans une nouvelle version de [tapscript][topic tapscript]. Russell a précédemment [parlé][rr atx] et
	[écrit][rr blog] à propos de ces idées. Brièvement, cette proposition vise à restaurer une
	programmabilité améliorée (incluant la fonctionnalité de [covenant][topic covenants]) à Bitcoin tout
	en évitant certains compromis nécessaires dans des propositions à portée plus limitée.

	- _Budget varops pour la contrainte d'exécution de script :_ Le [premier BIP][rr1] est assez complet
		et propose d'attribuer une métrique de coût à presque toutes les opérations de Script, similaire au
		budget sigops de SegWit. Pour la plupart des opérations dans Script, le coût est basé sur le nombre
		d'octets écrits dans la RAM du nœud pendant l'exécution de l'opcode par une implémentation naïve.
		Contrairement au budget sigops, le coût de chaque opcode dépend de la taille de ses entrées---d'où
		le nom "varops". Avec ce modèle de coût unifié, de nombreuses limites actuellement utilisées pour
		protéger les nœuds d'un coût excessif de validation de Script peuvent être augmentées au point
		qu'elles sont impossibles ou presque impossibles à atteindre dans des scripts pratiques.

	- _Restauration des fonctionnalités de script désactivées (tapscript v2) :_ Le [deuxième BIP][rr2]
		est également assez complet (à part une implémentation de référence) et détaille la restauration des
		opcodes [retirés][misc changes] de Script en 2010, comme requis pour protéger le réseau Bitcoin d'un
		coût excessif de validation de Script. Avec le budget varops en place, tous ces opcodes (ou des
		versions mises à jour d'entre eux) peuvent être restaurés, les limites peuvent être augmentées, et
		les nombres peuvent être de longueur arbitraire.

	- _OP_TX :_ Le [troisième BIP][rr3] est une proposition pour un nouvel opcode d'introspection
		générale. `OP_TX` permet à l'appelant d'obtenir presque n'importe quel élément ou éléments de la
		transaction dans la pile de script. En fournissant un accès direct à la transaction dépensière, cet
		opcode permet toute fonctionnalité de covenant possible avec des opcodes tels que `OP_TEMPLATEHASH`
		ou [`OP_CHECKTEMPLATEVERIFY`][topic op_checktemplateverify].

	- _Nouveaux opcodes pour tapscript v2 :_ Le [dernier BIP][rr4] propose de nouveaux opcodes qui
		complètent la fonctionnalité qui manquait ou n'était pas nécessaire lorsque Bitcoin a été lancé pour
		la première fois. Par exemple, ajouter la capacité de manipuler les taptrees et les sorties taproot
		n'était pas nécessaire au lancement de Bitcoin.
		Mais dans un monde avec Script restauré, il est logique d'avoir également ces
		capacités. Brandon Black [a noté][bb1] une omission dans les opcodes spécifiés nécessaires pour
		construire entièrement les sorties taproot. Deux des opcodes proposés semblent probablement
		nécessiter leurs propres BIPs complets : `OP_MULTI` et `OP_SEGMENT`.

	`OP_MULTI` modifie l'opcode suivant pour qu'il opère sur plus que son nombre standard d'éléments de
	pile, permettant (par exemple) à un script d'additionner un nombre variable d'éléments. Cela évite
	le besoin d'une construction de boucle dans Script ou d'un style de vérification différée `OP_VAULT`
	tout en permettant le contrôle du flux de valeur et une logique similaire.

	`OP_SEGMENT` (s'il est présent) modifie le comportement de `OP_SUCCESS` de sorte que, au lieu que
	tout le script réussisse si un `OP_SUCCESS` est présent, seul le segment réussit (limité par le
	début du script, `OP_SEGMENT`, ..., et la fin du script). Cela permet la possibilité de scripts avec
	un préfixe requis, incluant `OP_SEGMENT`, et un suffixe non fiable.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates._

- [Bitcoin Core 30.0rc2][] est un candidat à la sortie pour la prochaine version majeure de ce
	logiciel de nœud de vérification complète. Veuillez consulter le [guide de test du candidat à la
	sortie de la version 30][bcc30 testing].

- [bdk-wallet 2.2.0][] est une sortie mineure de cette bibliothèque utilisée pour construire des
	applications de portefeuille qui introduit une nouvelle fonctionnalité retournant des événements
	lors de l'application d'une mise à jour, de nouvelles installations de test pour la persistance des
	tests, et des améliorations de la documentation.

- [LND v0.20.0-beta.rc1][] est un candidat à la sortie pour une nouvelle version de cette
	implémentation de nœud LN populaire qui introduit de multiples corrections de bugs, la persistance
	des paramètres d'annonce de nœud à travers les redémarrages, un nouveau type [HTLC][topic htlc]
	`noopAdd`, le support pour les adresses de secours [P2TR][topic taproot] sur les factures
	[BOLT11][], et un point de terminaison expérimental `XFindBaseLocalChanAlias`, parmi de nombreux
	autres changements.

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core
lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust
Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Propositions
d'Amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips
repo], [Inquisition Bitcoin][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #33229][] implémente la sélection automatique de multiprocessus pour la
	communication inter-processus (IPC) (voir le [Bulletin #369][news369 ipc]), permettant aux
	utilisateurs de sauter la spécification de l'option de démarrage `-m` lorsque des arguments IPC sont
	passés ou des configurations IPC sont définies. Ce changement simplifie l'intégration de Bitcoin
	Core avec un service de minage [Stratum v2][topic pooled mining] externe qui crée, gère et soumet
	des modèles de blocs.

- [Bitcoin Core #33446][] corrige un bug introduit lorsque le champ `target` a été ajouté aux
	réponses des commandes `getblock` et `getblockheader` (voir le [Bulletin #339][news339 target]). Au
	lieu de toujours retourner incorrectement la cible du sommet de la chaîne, il retourne maintenant la
	cible du bloc demandé.

- [LDK #3838][] ajoute le support pour le modèle `client_trusts_lsp` pour les [canaux JIT][topic jit
	channels], tel que spécifié dans [BLIP52][] (LSPS2) (voir le [Bulletin #335][news335 blip]), en plus
	de déjà supporter le modèle `lsp_trusts_client`. Avec le nouveau modèle, le LSP ne diffusera pas la
	transaction de financement onchain jusqu'à ce que le destinataire révèle le préimage requis
	pour réclamer le [HTLC][topic htlc].

- [LDK #4098][] met à jour l'implémentation du TLV `next_funding` dans le flux `channel_reestablish`
	pour les transactions de [splicing][topic splicing], afin de s'aligner sur le changement de
	spécification proposé dans [BOLTs #1289][]. Ce PR suit le travail récent sur `channel_reestablish`
	couvert dans le [Bulletin #371][news371 splicing].

- [LDK #4106][] corrige une condition de concurrence dans laquelle un [HTLC][topic htlc] détenu par
	un LSP au nom d'un destinataire de [paiement asynchrone][topic async payments] échouait à être
	libéré parce que le LSP ne pouvait pas le localiser. Cela se produisait lorsque le LSP recevait le
	[message onion][topic onion messages] `release_held_htlc` (voir les Bulletins [#372][news372 async] et
	[#373][news373 async]) avant que le HTLC ne soit déplacé de la carte de pré-décodage à la carte
	`pending_intercepted_htlcs`. LDK vérifie maintenant les deux cartes, plutôt que juste la dernière,
	pour s'assurer que le HTLC est trouvé et libéré correctement.

- [LDK #4096][] change la file d'attente de diffusion [gossip][topic channel announcements] sortante
	par pair d'une limite de 24 messages à une limite de taille de 128 Ko. Si le nombre total d'octets
	actuellement en file d'attente pour un pair donné dépasse cette limite, les nouvelles diffusions de
	gossip à ce pair sont ignorées jusqu'à ce que la file se vide. Cette nouvelle limite réduit
	considérablement les transmissions manquées et est particulièrement pertinente car les messages
	varient en taille.

- [LND #10133][] ajoute le point de terminaison RPC expérimental `XFindBaseLocalChanAlias`, qui
	retourne un SCID de base pour un alias SCID spécifié (voir le [Bulletin #203][news203 alias]). Ce PR
	étend également le gestionnaire d'alias pour persister la cartographie inverse lorsque des alias
	sont créés, permettant le nouveau point de terminaison.

- [BDK #2029][] introduit la structure `CanonicalView`, qui effectue une fois pour toutes la
	canonicalisation du `TxGraph` d'un portefeuille à un chaintip donné. Cette capture instantanée
	alimente toutes les requêtes subséquentes, éliminant le besoin de re-canonicalisation à chaque
	appel. Les méthodes qui nécessitaient une canonicalisation ont maintenant des équivalents
	`CanonicalView`, et les méthodes `TxGraph` qui prenaient un `ChainOracle` faillible sont supprimées.
	Voir les Bulletins [#335][news335 txgraph] et [#346][news346 txgraph] pour les travaux de
	canonicalisation précédents sur BDK.

- Les [BIPs #1911][] marquent le [BIP21][] comme remplacé par le [BIP321][] et mettent à jour le
	statut du [BIP321][] de `Brouillon` à `Proposé`. Le [BIP321][] propose un schéma d'URI moderne pour
	décrire les instructions de paiement en bitcoin, voir le [Bulletin #352][news352 bip321] pour plus
	de détails.

{% include snippets/recap-ad.md when="2025-10-07 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33229,33446,3838,4098,4106,4096,10133,2029,1911,1289" %}
[rr0]: https://gnusha.org/pi/bitcoindev/877bxknwk6.fsf@rustcorp.com.au/
[rr1]: https://gnusha.org/pi/bitcoindev/874isonniq.fsf@rustcorp.com.au/
[rr2]: https://gnusha.org/pi/bitcoindev/871pnsnnhh.fsf@rustcorp.com.au/
[rr3]: https://gnusha.org/pi/bitcoindev/87y0q0m8vz.fsf@rustcorp.com.au/
[rr4]: https://gnusha.org/pi/bitcoindev/87tt0om8uz.fsf@rustcorp.com.au/
[rr atx]: https://www.youtube.com/watch?v=rSp8918HLnA
[rr blog]: https://rusty.ozlabs.org/2024/01/19/the-great-opcode-restoration.html
[bb1]: https://gnusha.org/pi/bitcoindev/aNsORZGVc-1_-z1W@console/
[misc changes]: https://github.com/bitcoin/bitcoin/commit/6ac7f9f144757f5f1a049c059351b978f83d1476
[bitcoin core 30.0rc2]: https://bitcoincore.org/bin/bitcoin-core-30.0/
[bcc30 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/30.0-Release-Candidate-Testing-Guide/
[bdk-wallet 2.2.0]: https://github.com/bitcoindevkit/bdk_wallet/releases/tag/wallet-2.2.0
[LND v0.20.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.0-beta.rc1
[news369 ipc]: /fr/newsletters/2025/08/29/#bitcoin-core-31802
[news339 target]: /fr/newsletters/2025/01/31/#bitcoin-core-31583
[news335 blip]: /fr/newsletters/2025/01/03/#blips-54
[news371 splicing]: /fr/newsletters/2025/09/12/#ldk-3886
[news372 async]: /fr/newsletters/2025/09/19/#ldk-4045
[news373 async]: /fr/newsletters/2025/09/26/#ldk-4046
[news203 alias]: /fr/newsletters/2022/06/08/#bolts-910
[news335 txgraph]: /fr/newsletters/2025/01/03/#bdk-1670
[news346 txgraph]: /fr/newsletters/2025/03/21/#bdk-1839
[news352 bip321]: /fr/newsletters/2025/05/02/#bips-1555