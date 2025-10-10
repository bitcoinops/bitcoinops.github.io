---
title: 'Bulletin Hebdomadaire Bitcoin Optech #375'
permalink: /fr/newsletters/2025/10/10/
name: 2025-10-10-newsletter-fr
slug: 2025-10-10-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit une recherche sur les compromis entre l'usabilité et la
sécurité dans les signatures à seuil, résume une approche pour convertir des signatures à seuil
imbriquées en un seul groupe de signature, et examine dans quelle mesure les données pourraient être
intégrées dans l'ensemble UTXO sous un ensemble restrictif de règles.
Sont également incluses nos sections régulières résumant une
réunion du Bitcoin Core PR Review Club, annonçant des mises à jour et des versions candidates,
et décrivant les changements notables dans les projets d'infrastructure Bitcoin populaires.

## Nouvelles

- **Signatures à Seuil Optimal**: Sindura Saraswathi a [publié][sindura post] une recherche,
	co-écrite avec Korok Ray, sur Delving Bitcoin concernant la détermination du seuil optimal pour un
	schéma de [multisignature][topic multisignature]. Dans cette recherche, les paramètres d'usabilité
	et de sécurité sont explorés, ainsi que leur relation et comment cela affecte le seuil que
	l'utilisateur devrait sélectionner. En définissant p(τ) et q(τ) puis en les combinant en une
	solution en forme fermée, ils tracent l'écart entre sécurité et usabilité.

	Saraswathi explore également l'utilisation de [signatures à seuil][topic threshold signature]
	dégradantes où les premières étapes utilisent des seuils plus élevés, qui diminuent progressivement
	dans les étapes ultérieures. Cela signifie qu'avec le temps, l'attaquant obtient plus d'accès pour
	prendre les fonds. Elle dit aussi qu'en utilisant [taproot][topic taproot], il peut y avoir de
	nouvelles possibilités à débloquer avec celles-ci à travers les taptrees et des contrats plus
	complexes, incluant les [timelocks][topic timelocks] et les signatures multiples.

- **Aplatir certaines signatures à seuil imbriquées :** ZmnSCPxj a [posté][zmnscpxj flat] sur
	Delving Bitcoin pour décrire comment éviter d'utiliser des [signatures schnorr][topic schnorr
	signatures] imbriquées dans certains cas qui n'ont pas été prouvés sûrs. Par exemple, Alice peut
	vouloir entrer dans un contrat avec un groupe composé de Bob, Carol et Dan. Toutes transactions
	doivent être approuvées par Alice et au moins deux parmi Bob, Carol et Dan. En théorie, cela
	pourrait être fait avec une [multisignature][topic multisignature] (par ex. [MuSig][topic musig]) où
	Alice fournit une signature partielle et une [signature à seuil][topic threshold signature] (par ex.
	FROST) est utilisée pour générer la signature partielle de Bob, Carol et Dan. Cependant, ZmnSCPxj
	écrit que "actuellement, nous n'avons pas de preuve que FROST-dans-MuSig est sûr". Au lieu de cela,
	ZmnSCPxj note que cet exemple peut être satisfait en utilisant uniquement des signatures à seuil :
	Alice reçoit plusieurs parts---assez pour qu'elle puisse empêcher un quorum, mais pas assez pour
	qu'elle puisse signer unilatéralement ; les autres signataires reçoivent chacun une part.

	Les utilisations décrites de cela incluent les statechains multi-opérateurs, les utilisateurs de LN
	qui souhaitent utiliser plusieurs dispositifs de signature, et la proposition de [surpaiements
	redondants][topic redundant overpayments] améliorée par LSP de ZmnSCPxj (voir le [Bulletin
	#372][news372 lspover]).

- **Limitations théoriques sur l'incorporation de données dans l'ensemble UTXO :** Adam "Waxwing"
	Gibson a lancé une [discussion][gibson embed] sur la liste de diffusion concernant la mesure dans
	laquelle les données pourraient être incorporées dans l'ensemble UTXO sous un ensemble restrictif de
	règles pour les transactions Bitcoin. La principale nouvelle règle, que Gibson décrit comme
	"effroyable", serait d'exiger que chaque sortie [P2TR][topic taproot] soit accompagnée d'une
	signature prouvant que la sortie pourrait être dépensée. Gibson tente de prouver qu'il n'y a que
	trois façons de contourner cette règle pour permettre à des données arbitraires de se faire passer
	pour une clé publique :

	1. La version de Bitcoin des [signatures schnorr][topic schnorr signatures] est défectueuse, par
		exemple basée sur une hypothèse erronée. Ce n'est clairement pas le cas actuellement.

	2. Une petite quantité de données arbitraires pourrait être incorporée en broyant la clé publique
		(c'est-à-dire, générer de nombreuses clés privées différentes, dériver la clé publique
		correspondante pour chacune, et écarter toutes les clés privées dont les clés publiques ne
		contiennent pas les données arbitraires souhaitées encodées d'une manière qui peut être extraite.
		Pour inclure _n_ bits de données arbitraires dans l'ensemble UTXO de cette manière, il faut environ
		2<sup>n</sup> opérations de force brute, ce qui est impraticable pour plus de quelques dizaines de
		bits (quelques octets) par sortie).

	3. Utiliser une clé privée qui peut facilement être calculée par des tiers, une forme de
		"divulgation de votre clé privée".

	Dans le troisième cas, divulguer votre clé privée pourrait permettre à un tiers de dépenser la
	sortie, en la retirant de l'ensemble UTXO. Cependant, plusieurs réponses à la discussion ont noté
	des moyens qui pourraient permettre de contourner cela dans un système sophistiqué comme Bitcoin.
	Une [réponse][towns embed] d'Anthony Towns a ajouté, "une fois que vous rendez le système
	programmable de manière intéressante, je pense que vous obtenez immédiatement la possibilité
	d'incorporer des données, et ensuite c'est juste une question de compromis entre le taux d'encodage
	optimal et la facilité d'identification de vos transactions. Forcer les données à être cachées au
	prix de les rendre moins efficaces laisse juste moins de ressources disponibles aux autres
	utilisateurs du système, ce qui ne me semble pas être un avantage de quelque manière que ce soit."

## Bitcoin Core PR Review Club

*Dans cette section mensuelle, nous résumons une récente réunion du [Bitcoin Core PR Review Club][],
en soulignant certaines des questions et réponses importantes. Cliquez sur une question ci-dessous
pour voir un résumé de la réponse de la réunion.*

[Compact block harness][review club 33300] est un PR de [Crypt-iQ][gh crypt-iq] qui augmente la
couverture du [test de fuzz][fuzz readme] en ajoutant un harnais de test pour la logique de [relais
de blocs compacts][topic compact block relay]. Le fuzzing est une technique de test qui fournit des
entrées quasi aléatoires au code pour découvrir des bugs et des comportements inattendus.

Le PR introduit également une nouvelle option de démarrage réservée aux tests `-fuzzcopydatadir`
pour augmenter la performance d'exécution du harnais de test.
Pourquoi un pair choisirait-il d'avoir une bande passante élevée ou faible ? Plus généralement,
pourquoi un pair choisirait-il d'être à haute ou basse bande passante ?

{% include functions/details-list.md
	a0="Pour un pair à haute bande passante, un bloc compact est transmis sans annonce et avant que la
	validation soit complétée. Cela augmente considérablement la vitesse de propagation des blocs. Pour
	réduire la surcharge de bande passante, un nœud sélectionne seulement jusqu'à 3 pairs pour envoyer
	des blocs compacts en mode haute bande passante. Ce mode n'est pas spécifiquement testé par la cible
	de fuzz `cmpctblock`."
	a0link="https://bitcoincore.reviews/33300#l-66"
	q1="Regardez `create_block` dans le harnais. Combien de transactions les blocs générés
	contiennent-ils, et d'où viennent-elles ? Quels scénarios de bloc compact pourraient être manqués
	avec seulement quelques transactions dans un bloc ?"
	a1="Les blocs générés contiennent 1-3 transactions : une transaction coinbase (toujours présente),
	éventuellement une transaction du mempool, et éventuellement une transaction hors mempool. Étant
	donné que les blocs sont limités à quelques transactions, certains scénarios peuvent être manqués,
	comme le test de la gestion des collisions d'ID courts qui devient plus probable avec de nombreuses
	transactions. Les participants du club de révision ont suggéré d'augmenter le nombre de transactions
	pour améliorer la couverture."
	a1link="https://bitcoincore.reviews/33300#l-132"
	q2="Le commit [ed813c4][review-club ed813c4] trie `m_dirty_blockindex` par hash de bloc au lieu de
	l'adresse du pointeur. Quel non-déterminisme cela corrige-t-il ? L'auteur [note][q1 note] que cela
	ralentit le code de production sans avantage pour la production. Pourquoi
	[`EnableFuzzDeterminism()`][code enablefuzzdeterminism] ne peut-il pas être utilisé ici ? Comment
	pensez-vous que ce non-déterminisme devrait être géré au mieux (si ce n'est pas de la manière dont
	le PR le fait actuellement) ?"
	a2="L'ensemble `m_dirty_blockindex` est trié par adresses mémoire des pointeurs, qui diffèrent entre
	les exécutions, causant un comportement non déterministe. La correction fournit un ordre de tri
	déterministe en utilisant le hash du bloc à la place. Une solution à l'exécution comme
	`EnableFuzzDeterminism()` ne peut pas être utilisée parce que le comparateur pour un `std::set` est
	une propriété de son type au moment de la compilation et ne peut pas être changé à l'exécution.
	Comme ce non-déterminisme affecte le chemin d'exécution, il induit en erreur l'analyse de couverture
	de code du fuzzer à chaque insertion dans l'ensemble. L'auteur du PR suggère [le livre blanc
	afl-fuzz][afl fuzz] comme lecture recommandée pour comprendre comment fonctionne le retour
	d'information sur la couverture avec le fuzzing."
	a2link="https://bitcoincore.reviews/33300#l-147"
%}

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates._

- [Bitcoin Inquisition 29.1][] est une sortie de ce nœud complet [signet][topic signet] conçu pour
	expérimenter avec des soft forks proposés et d'autres changements majeurs de protocole. Il inclut le
	nouveau [frais de relais minimum par défaut][topic default minimum transaction relay feerates] (0.1
	sat/vb) introduit dans Bitcoin Core 29.1, les limites `datacarrier` plus grandes attendues dans
	Bitcoin Core 30.0, le support pour `OP_INTERNALKEY` (voir les Bulletins [#285][news285 internal] et [#332][news332
	internal]), et nouvelle infrastructure interne pour le support de nouveaux soft forks.

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo],
[Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin
inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #33453][] annule la dépréciation des options de configuration `datacarrier` et
	`datacarriersize` car de nombreux utilisateurs souhaitent continuer à utiliser ces options, le plan
	de dépréciation était flou, et il y a peu d'inconvénients à retirer la dépréciation. Voir les
	Bulletins [#352][news352 data] et [#358][news358 data] pour un contexte supplémentaire sur ce
	sujet.

- [Bitcoin Core #33504][] saute l'application des vérifications [TRUC][topic v3 transaction relay]
	pendant une réorganisation de bloc lorsque les transactions confirmées réintègrent le mempool, même
	si elles violent les contraintes topologiques TRUC. Auparavant, l'application de ces vérifications
	évinçait par erreur de nombreuses transactions.

- [Core Lightning #8563][] retarde la suppression des anciens [HTLCs][topic htlc] jusqu'à ce qu'un
	nœud soit redémarré, plutôt que de les supprimer lorsqu'un canal est fermé et oublié. Cela améliore
	la performance en évitant une pause inutile qui arrête tous les autres processus CLN. Cette PR met
	également à jour le RPC `listhtlcs` pour exclure les HTLCs des canaux fermés.

- [Core Lightning #8523][] supprime le champ `blinding` précédemment déprécié et désactivé du RPC
	`decode` et du hook `onion_message_recv`, car il a été remplacé par `first_path_key`. Les options
	`experimental-quiesce` et `experimental-offers` sont également supprimées, car ces fonctionnalités
	sont désormais par défaut.

- [Core Lightning #8398][] ajoute une commande RPC `cancelrecurringinvoice` aux offres récurrentes
	expérimentales [BOLT12][] [offers][topic offers], permettant à un payeur de signaler à un receveur
	d'arrêter d'attendre d'autres demandes de facture de cette série. Plusieurs autres mises à jour sont
	faites pour s'aligner sur les derniers changements de spécification dans [BOLTs #1240][].

- [LDK #4120][] efface l'état de financement interactif lorsqu'une négociation de [splice][topic
	splicing] échoue avant la phase de signature, si un pair se déconnecte ou envoie `tx_abort`,
	permettant de réessayer le splice proprement. Si un `tx_abort` est reçu après que les pairs ont
	commencé à échanger des `tx_signatures`, LDK le traite comme une erreur de protocole et ferme le
	canal.

- [LND #10254][] déprécie le support pour les services onion [Tor][topic anonymity networks] v2, qui
	seront retirés dans la prochaine version 0.21.0. La configuration de l'option `tor.v2` est désormais
	cachée ; les utilisateurs devraient utiliser Tor v3 à la place.

{% include snippets/recap-ad.md when="2025-10-14 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33453,33504,8563,8523,8398,4120,10254,1240" %}
[sindura post]: https://delvingbitcoin.org/t/optimal-threshold-signatures-in-bitcoin/2023
[Bitcoin Inquisition 29.1]: https://github.com/bitcoin-inquisition/bitcoin/releases/tag/v29.1-inq
[news285 internal]: /fr/newsletters/2024/01/17/#nouvelle-proposition-de-soft-fork-combinant-lnhance
[news332 internal]: /fr/newsletters/2024/12/06/#bips-1534
[news352 data]: /fr/newsletters/2025/05/02/#augmentation-ou-suppression-de-la-limite-de-taille-op-return-de-bitcoin-core
[news358 data]: /fr/newsletters/2025/06/13/#bitcoin-core-32406
[review club 33300]: https://bitcoincore.reviews/33300
[gh crypt-iq]: https://github.com/crypt-iq
[fuzz readme]: https://github.com/bitcoin/bitcoin/blob/master/doc/fuzzing.md
[review-club ed813c4]: https://github.com/bitcoin-core-review-club/bitcoin/commit/ed813c48f826d083becf93c741b483774c850c86
[q1 note]: https://github.com/bitcoin/bitcoin/pull/33300#issuecomment-3308381089
[code enablefuzzdeterminism]: https://github.com/bitcoin/bitcoin/blob/acc7f2a433b131597124ba0fbbe9952c4d36a872/src/util/check.h#L34
[afl fuzz]: https://lcamtuf.coredump.cx/afl/technical_details.txt
[zmnscpxj flat]: https://delvingbitcoin.org/t/flattening-nested-2-of-2-of-a-1-of-1-and-a-k-of-n/2018
[news372 lspover]: /fr/newsletters/2025/09/19/#surpaiements-redondants-finances-par-lsp
[gibson embed]: https://gnusha.org/pi/bitcoindev/0f6c92cc-e922-4d9f-9fdf-69384dcc4086n@googlegroups.com/
[towns embed]: https://gnusha.org/pi/bitcoindev/aOXyvGaKfe7bqTXv@erisian.com.au/
