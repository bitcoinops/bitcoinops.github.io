---
title: 'Bulletin Hebdomadaire Optech #382'
permalink: /fr/newsletters/2025/11/28/
name: 2025-11-28-newsletter-fr
slug: 2025-11-28-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---

Le bulletin de cette semaine fournit une mise à jour sur les discussions concernant la
reconstruction de blocs compacts et relaye un appel à activer le BIP3.
Sont également incluses nos sections régulières résumant les récentes questions et réponses de Bitcoin
Stack Exchange, annoncant de nouvelles versions et des candidats à la publication, ainsi que les
résumés des modifications notables apportées aux logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

- **Statistiques sur les mises à jour de reconstruction de blocs compacts :** 0xB10C a publié une
	mise à jour sur [Delving Bitcoin][0xb10c delving] concernant ses statistiques autour de la
	reconstruction de blocs compacts (voir les Bulletins [#315][news315 cb] et [#339][news339 cb]). 0xB10C
	a fourni trois mises à jour autour de son analyse de reconstruction de blocs compacts :

	- Il a commencé à suivre la taille moyenne des transactions demandées en kB en réponse à [un retour
		précédent][news365 cb] de David Gumberg.

	- Il a mis à jour l'un de ses nœuds pour inclure les paramètres `minrelayfee` plus bas de [Bitcoin
		Core #33106][news368 minrelay]. Après la mise à jour, il a constaté que les taux de reconstruction
		de blocs s'étaient considérablement améliorés pour ce nœud. Il a également observé une amélioration
		de la taille moyenne des transactions demandées en kB.

	- Il a ensuite basculé ses autres nœuds pour fonctionner avec le `minrelayfee` réduit, ce qui a
		causé la plupart des nœuds à avoir un taux de reconstruction plus élevé et à demander moins de
		données à leurs pairs. Il [mentionne également][0xb10c third update] qu'en rétrospective, il aurait
		été préférable de ne pas avoir mis à jour tous les nœuds et d'en avoir gardé certains sur la version
		29, ce qui aurait facilité la comparaison entre les versions de nœuds et les paramètres.

	Dans l'ensemble, la réduction du `minrelayfee` a amélioré les taux de reconstruction de blocs de ses
	nœuds et réduit la quantité de données demandées à ses pairs.

- **Motion pour activer le BIP3** : Murch a [publié][murch ml] sur la liste de diffusion Bitcoin-Dev
	une motion formelle pour activer le [BIP3][] (voir le [Bulletin #341][news341 bip3]). L'objectif de
	cette proposition d'amélioration est de fournir de nouvelles directives pour préparer de nouveaux
	BIPs, remplaçant ainsi le processus actuel [BIP2][].

	Selon l'auteur, la proposition, qui est en statut "Proposé" depuis plus de 7 mois, n'a pas
	d'objections non adressées et une liste croissante de contributeurs a laissé un ACK sur [BIPs
	#1820][]. Ainsi, suivant la procédure exprimée par BIP2 pour activer les Process BIPs, il a accordé
	4 semaines, jusqu'au 2025-12-02, pour évaluer la proposition, ACK le PR, ou exprimer des
	préoccupations et soulever des objections. Après cette date, le BIP3 remplacera le BIP2 comme
	processus BIP.

	Quelques objections mineures ont été soulevées dans le fil de discussion, principalement concernant
	l'utilisation d'outils AI/LLM dans le processus de soumission des BIPs (voir le [Bulletin
	#378][news378 bips2006]), que l'auteur est en train d'adresser. Nous invitons les lecteurs d'Optech
	à se familiariser avec la proposition et à fournir leurs retours.

## Questions et réponses sélectionnées de Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech
cherchent des réponses à leurs questions---ou quand nous avons quelques moments libres pour aider
les utilisateurs curieux ou confus. Dans cette rubrique mensuelle, nous mettons en lumière certaines
des questions et réponses les mieux votées postées depuis notre dernière mise à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Les nœuds élagués stockent-ils les inscriptions de témoins ?]({{bse}}129197)
	Murch explique que les nœuds élagués conservent toutes les données de bloc, y compris les données de
	témoin, jusqu'à ce que les anciens blocs soient finalement écartés. Il continue en détaillant les
	compromis de l'utilisation d'OP_RETURN par rapport au schéma d'inscription.

- [Augmentation de la probabilité de collisions de hachage de blocs lorsque la difficulté est trop élevée]({{bse}}129265)
	Vojtěch Strnad note l'extrême improbabilité d'une collision de hachage de bloc (à moins que SHA256
	ne soit compromis) et continue en expliquant pourquoi le hachage d'un en-tête de bloc sert
	d'identifiants de bloc.

- [Quel est le but du premier octet 0x04 dans toutes les clés publiques et privées étendues?]({{bse}}129178)
	Pieter Wuille souligne que ces préfixes 0x04 sont simplement une coïncidence basée sur leurs
	encodages Base58 cibles respectifs.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates._

- [LND v0.20.0-beta][] est une sortie majeure de cette implémentation populaire de nœud LN qui
	introduit de multiples corrections de bugs, un nouveau type noopAdd [HTLC][topic htlc], le support
	pour les adresses de secours [P2TR][topic taproot] sur les factures [BOLT11][], et de nombreuses
	additions et améliorations aux RPC et `lncli`. Voir les [notes de version][lnd notes] pour plus de
	détails.

- [Core Lightning v25.12rc1][] est un candidat à la sortie d'une nouvelle version de cette
	implémentation majeure de nœud LN qui ajoute des phrases secrètes mnémoniques [BIP39][] comme
	nouvelle méthode de sauvegarde, des améliorations à `xpay`, la commande RPC `askrene-bias-node` pour
	favoriser ou défavoriser tous les canaux d'un pair, le sous-système `networkevents` pour accéder à
	des informations sur les pairs, et les options `experimental-lsps-client` et
	`experimental-lsps2-service` pour le support expérimental des [canaux JIT][topic jit channels].

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core
lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust
Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo], [Propositions
d'Amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips
repo], [Inquisition Bitcoin][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #33872][] supprime l'option précédemment obsolète `-maxorphantx`
	d'option de démarrage (voir le [Bulletin #364][news364 orphan]).
	Son utilisation entraîne un échec au démarrage.

- [Bitcoin Core #33629][] complète l'implémentation du [mempool en cluster][topic cluster mempool] en
	partitionnant le mempool en clusters limités par défaut à 101 kvB et 64 transactions chacun. Chaque
	cluster est linéarisé en morceaux ordonnés par frais (groupements de sous-clusters triés par taux de
	frais), de sorte que les morceaux à frais plus élevés sont sélectionnés en premier pour l'inclusion
	dans un modèle de bloc, et les morceaux à frais les plus bas sont évincés en premier lorsque le
	mempool est plein. Ce PR supprime la règle [CPFP carve out][topic cpfp carve out] et les limites
	ancêtre/descendant, et met à jour le relai de transactions pour prioriser les morceaux à frais plus
	élevés. Enfin, il met à jour les règles [RBF][topic rbf] en supprimant la restriction selon laquelle
	les remplacements ne peuvent pas introduire de nouvelles entrées non confirmées, change la règle de
	taux de frais pour exiger que le diagramme de taux de frais global du cluster s'améliore, et
	remplace la limite de conflits directs par une limite de clusters en conflit direct.

- [Core Lightning #8677][] améliore considérablement la performance des grands nœuds en limitant le
	nombre de commandes RPC et de plugins traitées à la fois, en réduisant les transactions de base de
	données inutiles pour les commandes en lecture seule, et en restructurant les requêtes de base de
	données pour gérer des millions d'événements `chainmoves`/`channelmoves` plus efficacement. Le PR
	introduit également une option `filters` pour les hooks `rpc_command` ou `custommsg`, permettant à
	des plugins comme `xpay`, `commando`, et `chanbackup` de s'inscrire uniquement pour des invocations
	spécifiques.

- [Core Lightning #8546][] ajoute une option `withhold` (faux par défaut) à `fundchannel_complete`
	qui retarde la diffusion d'une transaction de financement de canal jusqu'à ce que `sendpsbt` soit
	appelé ou que le canal soit fermé. Cela permet aux LSP de reporter l'ouverture d'un canal jusqu'à ce
	qu'un utilisateur fournisse suffisamment de fonds pour couvrir les frais de réseau. Cela est
	nécessaire pour activer le mode `client-trusts-lsp` dans [JIT channels][topic jit channels].

- [Core Lightning #8682][] met à jour la manière dont les [chemins aveuglés][topic rv routing] sont
	construits en exigeant que les pairs aient la fonctionnalité [`option_onion_messages`][topic onion
	messages] activée, en plus de l'`option_route_blinding`, même si la spécification n'exige pas la
	première. Cela résout un problème dans lequel un nœud LND sans la fonctionnalité activée échouerait
	à transmettre un paiement [BOLT12][topic offers].

- [LDK #4197][] met en cache les deux points d'engagement les plus récemment révoqués dans
	`ChannelManager` pour répondre au message de `channel_reestablish` d'un pair après une reconnexion.
	Cela évite de récupérer les points auprès d'un signataire potentiellement distant et de mettre en
	pause la machine d'état lorsque la contrepartie est au plus à une hauteur d'engagement précédente.
	Si un pair présente un état différent, le signataire valide le point d'engagement, et LDK plante
	si l'état est valide, soit force la fermeture du canal si c'est invalide. Pour les mises à jour
	précédentes de LDK sur `channel_reestablish`, voir les Bulletins [#335][news335 ldk],
	[#371][news371 ldk], et [#374][news374 ldk].

- [LDK #4234][] ajoute le script de rachat de financement à `ChannelDetails` et l'événement
	`ChannelPending`, permettant au portefeuille on-chain de LDK de reconstruire le `TxOut`
	d'un canal et d'estimer précisément le taux de frais lors de la construction d'une transaction de
	[splice-in][topic splicing].

- [LDK #4148][] ajoute le support pour [testnet4][topic testnet] en mettant à jour la dépendance
	`rust-bitcoin` à la version 0.32.4 (Voir le [Bulletin #324][news324 testnet]) et en exigeant cela
	comme la version minimale prise en charge pour les crates `lightning` et `lightning-invoice`.

- [BDK #2027][] ajoute une méthode `list_ordered_canonical_txs` à `TxGraph`, qui retourne des
	transactions canoniques dans un ordre topologique, où les transactions parentes apparaissent
	toujours avant leurs enfants. Les méthodes existantes `list_canonical_txs` et
	`try_list_canonical_txs` sont dépréciées en faveur de la nouvelle variante ordonnée. Voir les
	Bulletins [#335][news335 txgraph], [#346][news346 txgraph] et [#374][news374 txgraph] pour les
	travaux de canonicalisation précédents sur BDK.

{% include snippets/recap-ad.md when="2025-12-02 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1820,33872,33629,8677,8546,8682,4197,4234,4148,2027" %}
[0xb10c delving]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/35
[news365 cb]: /fr/newsletters/2025/08/01/#test-du-preremplissage-de-bloc-compact
[news339 cb]: /fr/newsletters/2025/01/31/#statistiques-mises-a-jour-sur-la-reconstruction-de-blocs-compacts
[news315 cb]: /fr/newsletters/2024/08/09/#statistiques-sur-la-reconstruction-de-blocs-compacts
[david delving post]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/34
[news368 minrelay]: /fr/newsletters/2025/08/22/#bitcoin-core-33106
[0xb10c third update]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/44
[murch ml]: https://groups.google.com/g/bitcoindev/c/j4_toD-ofEc
[news341 bip3]: /fr/newsletters/2025/02/14/#proposition-mise-a-jour-pour-le-processus-bip-mis-a-jour
[news378 bips2006]: /fr/newsletters/2025/10/31/#bips-2006
[LND v0.20.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.0-beta
[lnd notes]: https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/release-notes-0.20.0.md
[Core Lightning v25.12rc1]: https://github.com/ElementsProject/lightning/releases/tag/v25.12rc1
[news364 orphan]: /fr/newsletters/2025/07/25/#bitcoin-core-31829
[news335 ldk]: /fr/newsletters/2025/01/03/#ldk-3365
[news374 ldk]: /fr/newsletters/2025/10/03/#ldk-4098
[news371 ldk]: /fr/newsletters/2025/09/12/#ldk-3886
[news324 testnet]: /fr/newsletters/2024/10/11/#rust-bitcoin-2945
[news335 txgraph]: /fr/newsletters/2025/01/03/#bdk-1670
[news346 txgraph]: /fr/newsletters/2025/03/21/#bdk-1839
[news374 txgraph]: /fr/newsletters/2025/10/03/#bdk-2029