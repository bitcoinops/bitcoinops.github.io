---
title: 'Bulletin Hebdomadaire Bitcoin Optech #391'
permalink: /fr/newsletters/2026/02/06/
name: 2026-02-06-newsletter-fr
slug: 2026-02-06-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
La newsletter de cette semaine inclut des liens vers des travaux sur une base de données UTXO
parallélisée en temps constant, résume un nouveau langage de haut niveau pour écrire du Bitcoin
Script, et décrit une idée pour atténuer les attaques par poussière.
Sont également incluses nos sections régulières résumant les récentes discussions sur
la modification des règles de consensus de Bitcoin, annonçant des mises à jour et des versions candidates,
et décrivant les changements notables dans les projets d'infrastructure Bitcoin populaires.

## Nouvelles

- **Une base de données UTXO parallélisée en temps constant** : Toby Sharp a [publié][hornet del]
	sur Delving Bitcoin à propos de son dernier projet, une base de données UTXO personnalisée,
	hautement parallélisée, avec des requêtes en temps constant, appelée Hornet UTXO(1). Il s'agit d'un
	nouveau composant additionnel de [Hornet Node][hornet website], un client Bitcoin expérimental axé
	sur la fourniture d'une spécification exécutable minimale des règles de consensus de Bitcoin. Cette
	nouvelle base de données vise à améliorer le Téléchargement Initial de Bloc (IBD) grâce à une
	architecture sans verrou, hautement concurrente.

	Le code est écrit en C++23 moderne, sans dépendances externes. Pour optimiser la vitesse, des
	tableaux triés et des [arbres LSM][lsmt wiki] ont été préférés aux [tables de hachage][hash map
	wiki]. Les opérations, telles que l'ajout, la requête et la récupération, sont exécutées de manière
	concurrente, et les blocs sont traités hors ordre à leur arrivée, avec des dépendances de données
	résolues automatiquement. Le code n'est pas encore disponible publiquement.

	Sharp a fourni un benchmark pour évaluer les capacités de son logiciel. Pour re-valider toute la
	chaîne principale, Bitcoin Core v30 a pris 167 minutes (sans validation de script ou de signature),
	tandis que Hornet UTXO(1) a pris 15 minutes pour compléter la validation. Les tests ont été
	effectués sur un ordinateur de 32 cœurs, avec 128 Go de RAM et 1 To de stockage.

	Dans la discussion qui a suivi, d'autres développeurs ont suggéré à Sharp de comparer les
	performances avec [libbitcoin][libbitcoin gh], connu pour fournir un IBD très efficace.

- **Bithoven : Un langage impératif formellement vérifié pour Bitcoin Script :** Hyunhum Cho a
	[écrit][delving hc bithoven] sur Delving Bitcoin à propos de son [travail][arxiv hc bithoven] sur
	Bithoven qui est une alternative à [miniscript][topic miniscript]. Contrairement au langage
	prédicatif de miniscript pour exprimer les satisfactions possibles d'un script de verrouillage,
	Bithoven utilise une syntaxe plus familière de la famille C avec `if`, `else`, `verify`, et `return`
	comme opérations principales. Le compilateur gère toute la gestion de la pile et fait des garanties
	similaires à celles du compilateur miniscript concernant la nécessité d'au moins une signature sur
	tous les chemins et similaires. Comme miniscript, il peut cibler différentes versions de Script.

- **Discussion sur les atténuations des attaques par poussière** : Bubb1es a [publié][dust attacks
	del] sur Delving Bitcoin à propos d'une manière de se débarrasser des [attaques par poussière][topic
	output linking] dans les portefeuilles onchain. Une attaque par poussière se produit lorsque un
	adversaire envoie des UTXO de poussière à toutes les adresses anonymes dont ils souhaitent
	avoir des informations ou suivre. En espérant que certains seront dépensés involontairement avec un UTXO non lié.

	La manière dont _la plupart_ des portefeuilles choisissent de gérer cela aujourd'hui est d'empêcher
	la dépense des UTXOs poussière en les marquant comme tels dans le client du portefeuille. Cela peut
	devenir un problème à l'avenir si l'utilisateur restaure à partir de clés et que le nouveau client
	du portefeuille ne sait pas que ces UTXOs sont marqués et "débloque" les UTXOs poussière pour être
	dépensés. Bubb1es suggère une autre manière de prévenir cette attaque par UTXO poussière en créant
	une transaction avec l'UTXO poussière qui utilise le montant entier et a une sortie `OP_RETURN` la
	rendant prouvée comme non dépensable. Cela est possible parce que Bitcoin Core v30.0 a un taux de
	frais minimum de relais plus bas (0.1 sats/vbyte).

	Il liste ensuite quelques risques liés à l'implémentation d'un portefeuille qui gère les UTXOs
	poussière de cette manière.

	1. Problèmes d'empreinte digitale si seulement quelques portefeuilles implémentent ceci.

	2. Si plusieurs UTXOs poussière sont diffusés en même temps, alors il peut y avoir corrélation.

	3. Il pourrait être nécessaire de rediffuser si les taux de frais augmentent.

	4. Cela peut être déroutant de signer pour des UTXOs poussière dans des configurations multi-sig et
		 de signature matérielle.

	AJ Towns a mentionné que la taille minimum de relais est de 65 octets et explique qu'utiliser
	ANYONECANPAY|ALL avec un OP_RETURN de 3 octets le rendrait plus efficace.

	Bubb1es fournit ensuite un outil expérimental [ddust][ddust tool] pour démontrer comment cela
	serait réalisé.

## Modification du consensus

_Une nouvelle section mensuelle résumant les propositions et discussions sur la modification des
règles de consensus de Bitcoin._

- **SHRINCS: signatures post-quantiques étatiques de 324 octets avec sauvegardes statiques :**
	Suite à [Hash-based Signature Schemes for Bitcoin][news386 jn hash], Jonas Nick [a détaillé][delving
	jn shrings] sur Delving Bitcoin un algorithme de signature spécifique basé sur le hachage [résistant
	aux quantiques][topic quantum resistance] avec des propriétés potentiellement utiles pour une
	utilisation dans Bitcoin.

	Dans le document, il y avait une discussion sur les compromis entre les signatures basées sur le
	hachage étatiques et non étatiques, où les signatures étatiques peuvent avoir un coût
	significativement réduit au détriment de schémas de sauvegarde complexes. SHRINCS offre un compromis
	où une signature étatique est utilisée lorsque la fidélité de la clé+état peut être connue avec
	certitude, mais revient à une signature non étatique à un coût plus élevé s'il y a un doute que
	l'état est valide.

	Les deux schémas choisis pour SHRINCS sont SPHINCS+ pour la signature non étatique et Unbalanced
	XMSS pour la signature étatique. La clé publique postée dans le script de sortie est un hachage des
	clés étatiques et non étatiques. Parce que ces schémas de signature basés sur le hachage retournent
	la clé publique de signature comme partie de la vérification, le signataire fournit la clé publique
	inutilisée avec leur signature et le vérificateur vérifie que la clé publique retournée se hache
	avec la clé publique fournie à la clé spécifiée dans le script de verrouillage. Le schéma Unbalanced
	XMSS est choisi pour optimiser les cas où relativement peu de signatures sont nécessaires d'une clé.

- **Abordant les points restants sur BIP54 :** Antoine Poinsot [a écrit][ml ap gcc]
	gcc] à propos des points restants de discussion pour le [consensus cleanup soft fork][topic
	consensus cleanup].

	La première discussion porte sur la proposition d'exiger que le `nLockTime` de la transaction
	coinbase soit fixé à un de moins que la hauteur du bloc. Ici, la discussion se concentre sur le fait
	de savoir si ce changement restreint inutilement la capacité des puces de minage à utiliser ce champ
	comme un nonce supplémentaire alors que les futurs mineurs manquent d'espace nonce dans les champs
	version, timestamp et nonce existants. Plusieurs intervenants ont mentionné que le champ `nLockTime`
	a déjà des sémantiques de consensus imposées et n'est donc pas un bon candidat pour un roulement de
	nonce supplémentaire. Diverses propositions pour un espace nonce alternatif ont été faites, incluant
	des bits de version supplémentaires et une sortie `OP_RETURN` séparée.

	L'autre changement discuté est la proposition de rendre invalides en consensus les transactions de
	64 octets non-témoins. Ces transactions sont également restreintes par la politique de relais par
	défaut, mais un changement de consensus protégerait les clients légers SPV (ou autres similaires)
	contre certaines attaques. Plusieurs intervenants se sont demandé si ce changement en vaut la peine,
	étant donné que d'autres atténuations existent, et il introduit un écart de validité potentiellement
	surprenant pour certains types de transactions (par exemple, [CPFPs][topic cpfp] pour certains
	protocoles).

- **Proposition de schéma de signature post-quantique Falcon :** Giulio Golinelli a [posté][ml gg
	falcon] sur la liste de diffusion proposant un fork pour activer la vérification de signature Falcon
	sur Bitcoin. L'algorithme Falcon est basé sur la cryptographie sur les réseaux et cherche à être
	normalisé par FIPS comme un algorithme de signature post-quantique. Il nécessite environ 20 fois
	plus d'espace sur la chaîne que les signatures ECDSA tout en étant environ deux fois plus rapide à
	vérifier. Cela en fait l'un des schémas de signature post-quantique les plus petits proposés jusqu'à
	présent pour Bitcoin.

	Conduition a posté certaines limitations de l'algorithme Falcon, surtout concernant la difficulté de
	mettre en œuvre la signature en temps constant. D'autres ont discuté de la question de savoir si un
	algorithme de signature post-quantique pour Bitcoin devrait être conçu en tenant compte de la
	compatibilité future avec STARK/SNARK.

	Note : Bien que le post sur la liste de diffusion le décrive comme un soft fork, il semble être
	implémenté comme une disjonction de jour de drapeau dans le chemin de vérification P2WPKH, ce qui
	serait un hard fork. Un travail supplémentaire serait nécessaire pour développer un client soft fork
	pour cet algorithme.

- **La vérification SLH-DSA peut rivaliser avec ECC :** Conduition a [écrit][ml cond slh-dsa] sur
	son travail en cours de benchmarking de son implémentation de vérification SLH-DSA post-quantique
	contre libsecp256k1. Ses résultats montrent que la vérification SLH-DSA peut rivaliser avec la
	vérification [schnorr][topic schnorr signatures] dans les cas courants.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates._

- [LDK 0.1.9][] et [0.2.1][ldk 0.2.1] sont des sorties de maintenance de cette bibliothèque
	populaire pour la construction d'applications compatibles LN. Les deux corrigent un bug où
	`ElectrumSyncClient` échouerait à synchroniser lorsque des transactions non confirmées étaient
	présentes. La version 0.2.1 corrige en outre un problème
	où `splice_channel` n'échoue pas immédiatement lorsque le pair ne prend pas en charge
	[splicing][topic splicing], rend la structure `AttributionData` publique et inclut plusieurs autres
	corrections de bugs.

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration de Bitcoin (BIPs)][bips
repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Inquisition Bitcoin][bitcoin
inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #33604][] corrige le comportement des nœuds [assumeUTXO][topic assumeutxo]. Pendant
	la validation en arrière-plan, le nœud évite de télécharger des blocs de pairs qui n'ont pas le bloc
	instantané dans leur meilleure chaîne parce que le nœud manque des données d'annulation nécessaires
	pour gérer une réorganisation potentielle. Cependant, cette restriction persistait inutilement même
	après que la validation en arrière-plan était terminée, malgré le fait que le nœud pouvait gérer les
	réorganisations. Les nœuds n'appliquent désormais cette restriction que pendant que la validation en
	arrière-plan est en cours.

- [Bitcoin Core #34358][] corrige un bug de portefeuille qui se produisait lors de la suppression de
	transactions via le RPC `removeprunedfunds`. Auparavant, supprimer une transaction marquait toutes
	ses entrées comme à nouveau dépensables, même si le portefeuille contenait une transaction en
	conflit qui dépensait également les mêmes UTXOs.

- [Core Lightning #8824][] ajoute une couche `auto.include_fees` au plugin de recherche de chemin
	`askrene` (voir le [Bulletin #316][news316 askrene]) qui déduit les frais de routage du montant du
	paiement, faisant effectivement payer les frais par le destinataire.

- [Eclair #3244][] ajoute deux événements : `PaymentNotRelayed`, émis lorsqu'un paiement ne pouvait
	pas être relayé au nœud suivant probablement en raison d'une liquidité insuffisante, et
	`OutgoingHtlcNotAdded`, émis lorsqu'un [HTLC][topic htlc] ne pouvait pas être ajouté à un canal
	spécifique. Ces événements aident les opérateurs de nœuds à construire des heuristiques pour
	l'allocation de liquidité, bien que la PR note qu'un seul événement ne devrait pas déclencher
	l'allocation.

- [LDK #4263][] ajoute un paramètre optionnel `custom_tlvs` à l'API `pay_for_bolt11_invoice`,
	permettant aux appelants d'incorporer des métadonnées arbitraires dans l'oignon de paiement. Bien
	que le point de terminaison de bas niveau `send_payment` permettait déjà des valeurs de type
	longueur personnalisées ([TLVs][]) dans les paiements [BOLT11][], cela n'était pas correctement
	exposé sur les points de terminaison de niveau supérieur.

- [LDK #4300][] ajoute un support pour une interception générique [HTLC][topic htlc]
	en s'appuyant sur le mécanisme de maintien HTLC ajouté pour les [paiements
	asynchrones][topic async payments] et en élargissant la capacité précédente, qui interceptait
	uniquement les HTLCs destinés à de faux SCIDs (voir le [Bulletin #230][news230 intercept]). La
	nouvelle mise en œuvre utilise un champ de bits configurable pour intercepter les HTLCs destinés à :
	intercepter les SCIDs (comme avant), les canaux privés hors ligne (utile pour les LSPs pour
	réveiller les clients endormis), les canaux privés en ligne, les canaux publics, et les SCIDs
	inconnus. Cela pose les bases pour supporter LSPS5 (voir le [Bulletin #365][news365 lsps5] pour
	l'implémentation côté client) et d'autres cas d'utilisation LSP.

- [LND #10473][] rend le RPC `SendOnion` (voir le [Bulletin #386][news386 sendonion]) entièrement
	idempotent, permettant aux clients de réessayer en toute sécurité les demandes après des échecs
	réseau sans risquer de paiements en double. Si une demande avec le même `attempt_id` a déjà été
	traitée, le RPC retournera une erreur `DUPLICATE_HTLC`.

- [Rust Bitcoin #5493][] ajoute la capacité d'utiliser des opérations SHA256 optimisées par matériel
	sur des architectures ARM compatibles. Les benchmarks montrent que le hachage est environ cinq fois
	plus rapide pour de grands blocs. Cela complète l'accélération SHA256 existante sur les
	architectures x86 (voir le [Bulletin #265][news265 x86sha]).

{% include snippets/recap-ad.md when="2026-02-10 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33604,34358,8824,3244,4263,4300,10473,5493" %}

[news386 jn hash]: /fr/newsletters/2026/01/02/#signatures-basees-sur-le-hachage-pour-le-futur-post-quantique-de-bitcoin
[delving jn shrings]: https://delvingbitcoin.org/t/shrincs-324-byte-stateful-post-quantum-signatures-with-static-backups/2158
[ml ap gcc]: https://groups.google.com/g/bitcoindev/c/6TTlDwP2OQg
[delving hc bithoven]: https://delvingbitcoin.org/t/bithoven-a-formally-verified-imperative-smart-contract-language-for-bitcoin/2189
[arxiv hc bithoven]: https://arxiv.org/abs/2601.01436
[ml gg falcon]: https://groups.google.com/g/bitcoindev/c/PsClmK4Em1E
[ml cond slh-dsa]: https://groups.google.com/g/bitcoindev/c/8UFkEvfyLwE
[hornet del]: https://delvingbitcoin.org/t/hornet-utxo-1-a-custom-constant-time-highly-parallel-utxo-database/2201
[hornet website]: https://hornetnode.org/overview.html
[lsmt wiki]: https://en.wikipedia.org/wiki/Log-structured_merge-tree
[hash map wiki]: https://en.wikipedia.org/wiki/Hash_table
[libbitcoin gh]: https://github.com/libbitcoin
[dust attacks del]: https://delvingbitcoin.org/t/disposing-of-dust-attack-utxos/2215
[ddust tool]: https://github.com/bubb1es71/ddust
[LDK 0.1.9]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.9
[ldk 0.2.1]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.2.1
[news316 askrene]: /fr/newsletters/2024/08/16/#core-lightning-7517
[TLVs]: https://github.com/lightning/bolts/blob/master/01-messaging.md#type-length-value-format
[news230 intercept]: /fr/newsletters/2022/12/14/#ldk-1835
[news365 lsps5]: /fr/newsletters/2025/08/01/#ldk-3662
[news386 sendonion]: /fr/newsletters/2026/01/02/#lnd-9489
[news265 x86sha]: /fr/newsletters/2023/08/23/#rust-bitcoin-1962
