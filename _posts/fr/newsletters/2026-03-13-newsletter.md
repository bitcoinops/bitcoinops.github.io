---
title: 'Bulletin Hebdomadaire Bitcoin Optech #396'
permalink: /fr/newsletters/2026/03/13/
name: 2026-03-13-newsletter-fr
slug: 2026-03-13-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
La newsletter de cette semaine décrit une fonction de hachage résistante aux collisions utilisant
le Script Bitcoin et résume la discussion continue sur l'analyse du trafic du Lightning Network.
Sont également incluses nos sections régulières résumant les annonces de nouvelles versions
et de candidats à la publication, et les résumés des modifications notables apportées
aux logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

- **Fonction de hachage résistante aux collisions pour le Script Bitcoin** : Robin Linus
  a [posté][bino del] sur Delving Bitcoin à propos de Binohash, une nouvelle fonction de hachage résistante aux collisions
  utilisant le Script Bitcoin. Dans le [document][bino paper] qu'il a partagé, Linus affirme que
  Binohash permet une introspection limitée des transactions sans nécessiter de nouveaux changements de consensus.
  Cela permet, à son tour, à des protocoles comme les ponts [BitVM][topic acc] avec
  des fonctionnalités de type [covenant][topic covenants] pour une introspection sans confiance, sans avoir besoin de
  se fier à des oracles de confiance.

  La fonction de hachage proposée dérive indirectement un digest de transaction suivant un
  processus en deux étapes :

  - Fixer les champs de la transaction : Les champs de la transaction sont liés en exigeant d'un dépensier
    de résoudre plusieurs énigmes de signature, chacune demandant `W1` bits de travail, rendant
    la modification non autorisée coûteuse en termes de calcul.

  - Dérivation du hachage : Le hachage est calculé en exploitant le comportement de
    `FindAndDelete` dans l'ancien `OP_CHECKMULTISIG`. Un pool de nonces est initialisé
    avec `n` signatures. Un dépensier produit un sous-ensemble avec `t` signatures, qui sont
    retirées du pool en utilisant `FindAndDelete`, puis calcule un sighash des
    signatures restantes. Le processus est répété jusqu'à ce qu'un sighash produise une signature d'énigme
    correspondant aux exigences. Le digest résultant, le Binohash, sera composé des indices `t` du sous-ensemble gagnant.

  Le digest de sortie a trois propriétés pertinentes pour les applications Bitcoin : il
  peut être extrait et vérifié entièrement au sein du Script Bitcoin ; il fournit
  environ 84 bits de résistance aux collisions ; et il est [signable par Lamport][lamport wiki],
  permettant de s'engager à l'intérieur d'un programme BitVM. Ensemble, ces
  propriétés signifient que les développeurs peuvent construire des protocoles qui raisonnent sur
  les données de transaction onchain aujourd'hui, en utilisant uniquement les primitives de script existantes.

- **Discussion continue sur l'outil d'analyse de trafic Gossip Observer** : En novembre, Jonathan
  Harvey-Buschel a [annoncé][news 381 gossip observer] Gossip Observer, un outil
  pour collecter le trafic de gossip LN et calculer des métriques pour évaluer le remplacement
  du flooding de messages par un protocole basé sur la réconciliation d'ensembles.

  Depuis, Rusty Russell et d'autres ont [rejoint la discussion][gossip observer
  delving] sur la meilleure manière de transmettre les esquisses. Russell a suggéré des
  améliorations de codage pour l'efficacité, y compris l'omission du tour de `GETDATA` en
  utilisant le suffixe du numéro de bloc comme clé d'ensemble pour un message, évitant un
  échange de demande/réponse inutile lorsque le récepteur peut déjà inférer le
  contexte de bloc pertinent.

  En réponse, Harvey-Buschel a [mis à jour][gossip observer github] sa version de
  Gossip Observer qui fonctionne et continue de collecter des données. Il
  a [posté][gossip observer update] une analyse des messages moyens quotidiens, un modèle de
  communautés détectées, et des retards de propagation.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates._

- [BDK wallet 3.0.0-rc.1][] est un candidat à la version pour une nouvelle version majeure de cette bibliothèque
  pour la construction d'applications de portefeuille. Les changements majeurs incluent le verrouillage des UTXO
  qui persiste après les redémarrages, des événements de portefeuille structurés retournés lors des mises à jour de la chaîne,
  et l'adoption de `NetworkKind` dans toute l'API pour distinguer le mainnet du testnet. La version ajoute également
  l'import/export du format de portefeuille Caravan (voir le [Bulletin #77][news77 caravan]) et un utilitaire de migration
  pour les bases de données SQLite d'avant la version 1.0.

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration de Bitcoin (BIPs)][bips repo],
[Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Inquisition Bitcoin][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #26988][] met à jour la commande CLI `-addrinfo` (voir le [Bulletin #146][news146 addrinfo])
  pour retourner désormais l'ensemble complet des adresses connues, au lieu d'un sous-ensemble filtré pour la qualité et la récence.
  En interne, le RPC `getaddrmaninfo` (voir le [Bulletin #275][news275 addrmaninfo]) est utilisé au lieu du RPC `getnodeaddresses`
  (voir le [Bulletin #14][news14 rpc]). Le nombre retourné correspond maintenant à l'ensemble non filtré utilisé pour sélectionner
  les pairs sortants.

- [Bitcoin Core #34692][] augmente le `dbcache` par défaut de 450 MiB à 1 GiB sur les systèmes 64 bits avec au moins 4 GiB de RAM,
  revenant à 450 MiB autrement. Ce changement affecte uniquement `bitcoind`; la bibliothèque noyau conserve 450 MiB comme valeur par défaut.

- [LDK #4304][] refactorise le routage [HTLC][topic htlc] pour supporter plusieurs HTLC entrants et sortants par transfert,
  jetant les bases du routage [trampoline][topic trampoline payments]. Contrairement au routage régulier, un nœud trampoline peut agir
  comme un point final [MPP][topic multipath payments] des deux côtés : il accumule les parties HTLC entrantes, trouve des routes
  vers le prochain saut, et divise le transfert en plusieurs HTLC sortants. Une nouvelle variante `HTLCSource::TrampolineForward`
  suit tous les HTLC pour un transfert trampoline. Les réclamations et les échecs sont gérés correctement, et la récupération
  du moniteur de canal est étendue pour reconstruire l'état du transfert trampoline au redémarrage.

- [LDK #4416][] permet à un accepteur de contribuer des fonds lorsque les deux pairs
  tentent d'initier un [splice][topic splicing] simultanément, ajoutant ainsi efficacement un support pour le [dual funding][topic dual funding]
  sur les splices. Lorsque les deux parties initient, un mécanisme de résolution de conflits par [quiescence][topic channel commitment upgrades]
  sélectionne l'un des participants comme initiateur. Auparavant, seul l'initiateur pouvait ajouter des fonds, et l'accepteur devait attendre
  un splice ultérieur pour ajouter les siens. Comme l'accepteur s'était préparé à être l'initiateur, ses frais sont ajustés du tarif initiateur
  (qui couvre les champs de transaction communs) au tarif accepteur. L'API `splice_channel` accepte désormais également un paramètre
  `max_feerate` pour cibler un taux de frais maximum.

- [LND #10089][] ajoute un support de transfert pour les [message en onion][topic onion messages], en s'appuyant sur les types de messages
  et les RPCs du [Bulletin #377][news377 onion]. Il introduit un type de fil `OnionMessagePayload` pour décoder le contenu interne de l'oignon,
  et un acteur par pair qui gère le déchiffrement et les décisions de transfert. Cette fonctionnalité peut être désactivée en utilisant
  le drapeau `--protocol.no-onion-messages`. Cela fait partie de la feuille de route de LND vers le support des [BOLT12 offers][topic offers].

- [Libsecp256k1 #1777][] ajoute une nouvelle API `secp256k1_context_set_sha256_compression()`, qui permet aux applications
  de fournir une fonction de compression SHA256 personnalisée à l'exécution. Cette API permet à des environnements tels que Bitcoin Core,
  qui détectent déjà les caractéristiques du CPU au démarrage, de diriger le hachage de libsecp256k1 à travers un SHA256 accéléré par matériel
  sans recompiler la bibliothèque.

- [BIPs #2047][] publie [BIP392][], qui définit un format de [descripteur][topic descriptors] pour les portefeuilles
  de [silent payment][topic silent payments]. Le nouveau descripteur `sp()` instruit le logiciel de portefeuille sur comment
  scanner et dépenser les sorties de paiement silencieux, qui sont des sorties [P2TR][topic taproot] telles que spécifiées
  dans [BIP352][]. Une forme d'argument d'expression clé unique prend une seule clé [bech32m][topic bech32] : `spscan` qui encode
  la clé privée de scan et la clé publique de dépense pour une observation seulement, ou `spspend` qui encode à la fois les clés privées
  de scan et de dépense. Une forme à deux arguments `sp(KEY,KEY)` prend une clé privée de scan comme première expression et
  une expression de clé de dépense séparée, soit publique soit privée avec un support pour les clés agrégées [MuSig2][topic musig]
  via [BIP390][]. Voir le [Bulletin #387][news387 sp] pour la discussion initiale sur la liste de diffusion.

- [BOLTs #1316][] clarifie que `offer_amount` dans les [BOLT12 offers][topic offers] doit être supérieur à zéro lorsqu'il est présent.
  Les rédacteurs doivent définir le `offer_amount` à une valeur supérieure à zéro, et les lecteurs ne doivent pas répondre aux offres
  où le montant est nul. Des vecteurs de test pour les offres invalides à montant zéro sont ajoutés.

- [BOLTs #1312][] ajoute un vecteur de test pour les offres [BOLT12][topic offers]
  avec un padding [bech32][topic bech32] invalide, précisant que de telles offres doivent être rejetées selon les règles de [BIP173][].
  Ce problème a été découvert grâce au fuzzing différentiel à travers les implémentations de Lightning, qui a révélé que CLN et LDK
  acceptaient des offres avec un padding invalide tandis qu'Eclair et Lightning-KMP les rejetaient correctement.
  Voir le [Bulletin #390][news390 bech32] pour la correction de LDK.

{% include snippets/recap-ad.md when="2026-03-17 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="26988,34692,4304,4416,10089,1777,2047,1316,1312" %}

[bino del]: https://delvingbitcoin.org/t/binohash-introspection-de-transaction-sans-softforks/2288
[bino paper]: https://robinlinus.com/binohash.pdf
[lamport wiki]: https://fr.wikipedia.org/wiki/Signature_de_Lamport
[news146 addrinfo]: /en/newsletters/2021/04/28/#bitcoin-core-21595
[news275 addrmaninfo]: /fr/newsletters/2023/11/01/#bitcoin-core-28565
[news14 rpc]: /en/newsletters/2018/09/25/#bitcoin-core-13152
[news377 onion]: /fr/newsletters/2025/10/24/#lnd-9868
[news387 sp]: /fr/newsletters/2026/01/09/#projet-de-bip-pour-descripteurs-de-paiement-silencieux
[news390 bech32]: /fr/newsletters/2026/01/30/#ldk-4349
[news77 caravan]: /en/newsletters/2019/12/18/#unchained-capital-open-sources-caravan-a-multisig-coordinator
[BDK wallet 3.0.0-rc.1]: https://github.com/bitcoindevkit/bdk_wallet/releases/tag/v3.0.0-rc.1
[gossip observer delving]: https://delvingbitcoin.org/t/gossip-observer-new-project-to-monitor-the-lightning-p2p-network/2105
[gossip observer update]: https://delvingbitcoin.org/t/gossip-observer-new-project-to-monitor-the-lightning-p2p-network/2105/23
[gossip observer github]: https://github.com/jharveyb/gossip_observer
[news 381 gossip observer]: /fr/newsletters/2025/11/21/#outil-d-analyse-du-trafic-gossip-ln-annonce
