---
title: 'Bulletin Hebdomadaire Bitcoin Optech #377'
permalink: /fr/newsletters/2025/10/24/
name: 2025-10-24-newsletter-fr
slug: 2025-10-24-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume une idée d'utilisation du cluster mempool pour détecter les
augmentations du taux de frais des modèles de blocs et partage une mise à jour sur les résultats de
simulation de la mitigation du brouillage de canaux.
Sont également incluses nos sections régulières résumant les récentes discussions sur
la modification des règles de consensus de Bitcoin, annonçant des mises à jour et des versions candidates,
et décrivant les changements notables dans les projets d'infrastructure Bitcoin populaires.

## Nouvelles

- **Détection des augmentations du taux de frais des modèles de blocs en utilisant le cluster
	mempool :** Abubakar Sadiq Ismail a récemment [publié][ismail post] sur Delving Bitcoin à propos de
	la possibilité de suivre l'augmentation potentielle des frais à partir de chaque mise à jour du
	mempool pour fournir un nouveau modèle de bloc aux mineurs uniquement lorsque l'amélioration du taux
	de frais le justifie. Cette approche réduirait le nombre de constructions de modèles de blocs
	redondantes, qui peuvent retarder le traitement et la transmission des transactions aux pairs. La
	proposition tire parti du [mempool en cluster][topic cluster mempool] pour évaluer si une amélioration
	du taux de frais est disponible sans reconstruire le modèle de bloc.

	Lorsqu'une nouvelle transaction entre dans le mempool, elle se connecte à zéro ou plusieurs clusters
	existants déclenchant la re-linéarisation (voir le Bulletin [#312][news312 lin] pour plus
	d'informations sur la linéarisation) des clusters affectés pour produire des diagrammes de taux de
	frais avant (pré-mise à jour) et après (post-mise à jour) la mise à jour. Le diagramme ancien
	identifie les blocs potentiels à évincer du modèle de bloc, tandis que le nouveau diagramme
	identifie les blocs à haut taux de frais pour une addition potentielle. Le système suit ensuite un
	processus en 4 étapes pour simuler l'impact :

	1. Éviction : Retirer les blocs correspondants d'une copie du modèle, en mettant à jour les frais
		 modifiés et les tailles.

	2. Fusion Naïve : Ajouter de manière gourmande les blocs candidats tout en respectant les limites de
	   poids du bloc pour estimer les gains de frais potentiels (ΔF).

	3. Fusion Itérative : Si l'estimation naïve est non concluante, utiliser une simulation plus
	   détaillée pour affiner ΔF.

	4. Décision : Comparer ΔF à un seuil ; si cela dépasse le seuil, reconstruire le modèle de bloc et
	   l'envoyer aux mineurs. Sinon, passer pour éviter des calculs inutiles.

	La proposition actuelle est encore en phase de discussion, sans prototype disponible.

- **Résultats de simulation de la mitigation du brouillage de canaux et mises à jour :** Carla
	Kirk-Cohen, en collaboration avec Clara Shikhelman et elnosh, a [publié][carla post] sur Delving
	Bitcoin à propos de leurs résultats de simulation et des mises à jour avec l'algorithme de
	réputation pour leur [proposition de mitigation du brouillage de canaux][channel jamming bolt].
	Quelques changements notables sont que la réputation est suivie pour les canaux sortants, et les
	ressources sont limitées sur les canaux entrants. Bitcoin Optech a précédemment couvert les
	[attaques de brouillage de canaux lightning][topic channel jamming attacks] et un précédent post
	[Delving Bitcoin][carla earlier delving post] de Carla. Lisez ces posts pour obtenir une
	compréhension de base du brouillage de canaux lightning.

	Dans cette dernière mise à jour, ils ont utilisé leur simulateur pour exécuter à la fois les
	[attaques de ressources][resource attacks] et les [attaques de saturation][sink attacks]. Ils ont trouvé
	que, avec les nouvelles mises à jour, la protection contre les attaques de ressources reste intacte,
	et avec les attaques par saturation, les nœuds attaquants seront rapidement coupés lorsqu'ils se
	comportent mal. Il est à noter que si un attaquant construit une réputation puis cible une chaîne de
	nœuds, seul le dernier nœud est compensé. Mais il y a un coût significatif pour un attaquant à
	cibler plusieurs nœuds.

	La conclusion de l'article est que la mitigation des [attaques par brouillage de canal][topic
	channel jamming attacks] a atteint un point où elle est suffisamment efficace et encourage les
	lecteurs à essayer leur simulateur pour tester les attaques.

## Changements dans les services et logiciels clients

*Dans cette rubrique mensuelle, nous mettons en lumière des mises à jour intéressantes des
portefeuilles et services Bitcoin.*

- **Lancement du portefeuille BULL :**
	Le portefeuille mobile open source [BULL][bull blog] est construit sur BDK et prend en charge les
	[descriptors][topic descriptors], [l'étiquetage][topic wallet labels], et la sélection de pièces,
	Lightning, [payjoin][topic payjoin], Liquid, les portefeuilles matériels, et les portefeuilles en
	lecture seule, parmi d'autres fonctionnalités.

- **Sortie de Sparrow 2.3.0 :**
	[Sparrow 2.3.0][sparrow github] ajoute le support pour l'envoi à des adresses de [paiement
	silencieux][topic silent payments] et les instructions de paiement Bitcoin lisibles par l'homme
	[BIP353][], parmi d'autres fonctionnalités et corrections de bugs.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates._

- [Core Lightning 25.09.1][] est une version de maintenance pour la version majeure actuelle de ce
	nœud LN populaire qui inclut plusieurs corrections de bugs.

- [Bitcoin Core 28.3][] est une version de maintenance pour la série de versions précédente de
	l'implémentation de nœud complet prédominante. Elle contient plusieurs corrections de bugs, et
	inclut également les nouveaux paramètres par défaut pour `blockmintxfee`, `incrementalrelayfee`, et
	`minrelaytxfee`.

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core
lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust
Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo], [Propositions
d'Amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips
repo], [Inquisition Bitcoin][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #33157][] optimise l'utilisation de la mémoire dans le [mempool en cluster][topic cluster
	mempool] en introduisant un type `SingletonClusterImpl` pour les clusters à transaction unique et en
	compactant plusieurs internes de `TxGraph`. Cette PR ajoute également une fonction
	`GetMainMemoryUsage()` pour estimer l'utilisation de la mémoire de `TxGraph`.

- [Bitcoin Core #29675][] introduit le support pour recevoir et dépenser les sorties [taproot][topic
	taproot] contrôlées par l'agrégat [MuSig2][topic musig] pour les clés sur les portefeuilles avec
	des descripteurs `musig(0)` importés [descriptors][topic descriptors].
	Voir le [Bulletin #366][news366 musig2] pour les travaux préparatoires antérieurs.

- [Bitcoin Core #33517][] et [Bitcoin Core #33518][] réduisent la consommation CPU du logging
	multiprocessus en ajoutant des niveaux et catégories de logs, ce qui évite la sérialisation des
	messages de log de communication inter-processus (IPC) écartés. L'auteur a découvert qu'avant ce PR,
	le logging représentait 50% du temps CPU de son application cliente [Stratum v2][topic pooled
	mining] et 10% des processus du nœud Bitcoin. Cela a maintenant chuté à près de zéro pour cent. Voir
	les Bulletins [#323][news323 ipc] et [#369][news369 ipc] pour un contexte supplémentaire.

- [Eclair #2792][] ajoute une nouvelle stratégie de division [MPP][topic multipath payments],
	`max-expected-amount`, qui alloue des parties à travers les routes en prenant en compte la capacité
	de chaque route et la probabilité de succès. Une nouvelle option de configuration
	`mpp.splitting-strategy` est ajoutée avec trois options : `max-expected-amount`, `full-capacity`,
	qui considère uniquement la capacité d'une route, et `randomize` (par défaut), qui rend aléatoire la
	division. Les deux dernières sont déjà accessibles via la config booléenne
	`randomize-route-selection`. Ce PR ajoute l'application des limites maximales [HTLC][topic htlc] sur
	les canaux distants.

- [LDK #4122][] permet de mettre en file d'attente une demande de [splice][topic splicing] tandis
	que le pair est hors ligne, en commençant la négociation lors de la reconnexion. Pour les splices
	[zero-conf][topic zero-conf channels], LDK envoie maintenant un message `splice_locked` au pair
	immédiatement après l'échange des `tx_signatures`. LDK mettra également en file d'attente un splice
	pendant un splice concurrent et tentera de le réaliser dès que l'autre se verrouille.

- [LND #9868][] définit un type `OnionMessage` et ajoute deux nouveaux points de terminaison RPC :
	`SendOnionMessage`, qui envoie un message onion à un pair spécifique, et `SubscribeOnionMessages`,
	qui s'abonne à un flux de messages onion entrants. Ce sont les premières étapes nécessaires pour
	supporter les [BOLT12 offers][topic offers].

- [LND #10273][] corrige un problème où LND se plantait lorsque le sweeper hérité, `utxonursery`,
	tentait de balayer un [HTLC][topic htlc] avec un [locktime][topic timelocks] (indice de hauteur) de
	0. Maintenant, LND balaye avec succès ces HTLC en dérivant l'indice de hauteur de la hauteur de
	fermeture du canal.

{{% include snippets/recap-ad.md when="2025-10-28 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33157,29675,33517,33518,2792,4122,9868,10273" %}
[carla post]: https://delvingbitcoin.org/t/outgoing-reputation-simulation-results-and-updates/2069
[channel jamming bolt]: https://github.com/lightning/bolts/pull/1280
[resource attacks]: https://delvingbitcoin.org/t/hybrid-jamming-mitigation-results-and-updates/1147#p-3212-resource-attacks-3
[sink attacks]: https://delvingbitcoin.org/t/hybrid-jamming-mitigation-results-and-updates/1147#p-3212-manipulation-sink-attack-9
[bull blog]: https://www.bullbitcoin.com/blog/bull-by-bull-bitcoin
[sparrow github]: https://github.com/sparrowwallet/sparrow/releases/tag/2.3.0
[ismail post]: https://delvingbitcoin.org/t/determining-blocktemplate-fee-increase-using-fee-rate-diagram/2052
[carla earlier delving post]: /fr/newsletters/2024/09/27/#tests-et-changements-de-mitigation-du-brouillage-hybride
[Core Lightning 25.09.1]: https://github.com/ElementsProject/lightning/releases/tag/v25.09.1
[Bitcoin Core 28.3]: https://bitcoincore.org/en/2025/10/17/release-28.3/
[news366 musig2]: /fr/newsletters/2025/08/08/#bitcoin-core-31244
[news323 ipc]: /fr/newsletters/2024/10/04/#bitcoin-core-30510
[news369 ipc]: /fr/newsletters/2025/08/29/#bitcoin-core-31802
[news312 lin]: /fr/newsletters/2024/07/19/#introduction-a-la-linearisation-des-clusters
