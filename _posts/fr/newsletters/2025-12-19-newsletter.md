---
title: 'Bulletin Hebdomadaire Bitcoin Optech #385 : Revue Spéciale Année 2025'
permalink: /fr/newsletters/2025/12/19/
name: 2025-12-19-newsletter-fr
slug: 2025-12-19-newsletter-fr
type: newsletter
layout: newsletter
lang: fr

extrait: >
Le huitième numéro spécial annuel Bilan de l'année de Bitcoin Optech résume les développements
notables survenus dans Bitcoin au cours de l'année 2025.
---

{{page.excerpt}} C'est la suite de nos résumés de [2018][yirs 2018],
[2019][yirs 2019], [2020][yirs 2020], [2021][yirs 2021], [2022][yirs 2022],
[2023][yirs 2023], et [2024][yirs 2024].

## Contenus

* Janvier
  * [Mise à jour du brouillon ChillDKG](#chilldkg)
  * [DLCs offchain](#offchaindlcs)
  * [Reconstructions de blocs compacts](#compactblockstats)
* Février
  * [Mise à jour d'Erlay](#erlay)
  * [Scripts d'ancrage éphémères LN](#lneas)
  * [Paiements probabilistes](#probpayments)
* Mars
  * [Guide de Forking Bitcoin](#forkingguide)
  * [Marché privé de modèles de blocs pour prévenir la centralisation du MEV](#templatemarketplace)
  * [Frais d'avance et de maintien LN utilisant des sorties brûlables](#lnupfrontfees)
* Avril
  * [Accélération SwiftSync pour le téléchargement initial de bloc](#swiftsync)
  * [Signatures agrégées interactives DahLIAS](#dahlias)
* Mai
  * [Mempool en cluster](#clustermempool)
  * [Augmentation ou suppression de la limite de taille OP_RETURN de Bitcoin Core](#opreturn)
* Juin
  * [Calcul du seuil de danger du minage égoïste](#selfishmining)
  * [Empreintage de nœuds utilisant des messages addr](#fingerprinting)
  * [Verrous brouillés](#garbledlocks)
* Juillet
  * [Délégation de code chaîne](#ccdelegation)
* Août
  * [Brouillons BIP Utreexo](#utreexo)
  * [Réduction du taux minimal de frais de relais](#minfeerate)
  * [Partage de modèles de blocs entre pairs](#templatesharing)
  * [Fuzzing différentiel des implémentations de Bitcoin et LN](#fuzzing)
* Septembre
  * [Détails sur la conception de Simplicity](#simplicity)
  * [Attaques de partitionnement et d'éclipse utilisant l'interception BGP](#eclipseattacks)
* Octobre
  * [Discussions sur les données arbitraires](#arbdata)
  * [Résultats de simulation et mises à jour sur l'atténuation du brouillage de canaux](#channeljamming)
* Novembre
  * [Comparaison de la performance de la validation de signature ECDSA dans OpenSSL vs. libsecp256k1](#secpperformance)
  * [Modélisation des taux de blocs obsolètes par délai de propagation et centralisation du minage](#stalerates)
  * [BIP3 et le processus BIP](#bip3)
  * [Introduction de l'API C de Bitcoin Kernel](#kernelapi)
* Décembre
  * [Épissage](#lnsplicing)
* Résumés en vedette
  * [Vulnérabilités](#vulns)
  * [Quantique](#quantum)
  * [Propositions de soft fork](#softforks)
  * [Stratum v2](#stratumv2)
  * [Principales versions de projets d'infrastructure populaires](#releases)
  * [Bitcoin Optech](#optech)

---

## Janvier

{:#chilldkg}

- **Brouillon mis à jour de ChillDKG :** Tim Ruffing et Jonas Nick
  [ont mis à jour][news335 chilldkg] leur travail sur un protocole de génération de clés distribué
  (DKG) pour utilisation avec le schéma de [signature à seuil][topic threshold signature] FROST.
  ChillDKG vise à fournir des fonctionnalités de récupération similaires aux
  portefeuilles descripteurs existants.

{:#offchaindlcs}

- **DLC offchain :** Le développeur Conduition [a posté à propos][news offchain dlc] d'un nouveau
  mécanisme de DLC ([contrat à log discret][topic dlc]) offchain qui permet aux participants de
  collaborer à la création et à l'extension d'une usine de DLC, ce qui permet des DLC itératifs qui se
  poursuivent jusqu'à ce qu'une partie choisisse de résoudre onchain. Cela contraste avec [les
  travaux antérieurs][news dlc channels] sur les DLC offchain qui nécessitaient une interaction à
  chaque renouvellement du contrat.

{:#compactblockstats}

- **Reconstructions de blocs compacts :** Janvier a également vu le premier de plusieurs éléments en
  2025 qui ont revisité [les recherches précédentes][news315 compact blocks] sur l'efficacité avec
  laquelle les nœuds Bitcoin reconstruisent des blocs en utilisant [le relais de blocs compacts][topic
  compact block relay] (BIP152), en mettant à jour les mesures précédentes et en explorant des
  raffinements potentiels. Les statistiques mises à jour [publiées en janvier][news339 compact blocks]
  ont montré que lorsque les mémoires tampons sont pleines, les nœuds doivent plus fréquemment
  demander des transactions manquantes. Une mauvaise résolution des orphelins a été identifiée comme
  une cause possible, avec [quelques améliorations][news 338] déjà réalisées.

  Plus tard dans l'année, une analyse a examiné si [les stratégies de préremplissage de blocs
  compacts][news365 compact blocks] pourraient améliorer davantage le succès de la reconstruction. Les
  tests ont suggéré que le préremplissage sélectif de transactions susceptibles de manquer dans les
  mémoires tampons des pairs pourrait réduire les demandes de secours avec seulement des compromis
  modestes en termes de bande passante. Des recherches ultérieures ont ajouté ces mesures
  supplémentaires et mis à jour [les mesures de reconstruction dans le monde réel][news382 compact
  blocks] avant et après les changements apportés aux [taux minimum de frais de relais des nœuds de
  surveillance](#minfeerate), montrant que les nœuds avec un `minrelayfee` plus bas ont un taux de
  reconstruction plus élevé. L'auteur a également [posté][news368 monitoring] sur l'architecture
  derrière son projet de surveillance.

## Février

{:#erlay}

- **Mise à jour d'Erlay :** Sergi Delgado a fait [plusieurs posts][erlay optech posts] cette année
  sur son travail et ses progrès dans l'implémentation d'[Erlay][erlay] dans Bitcoin Core. Dans le
  premier post, il a donné un aperçu de la proposition Erlay et de la manière dont le mécanisme actuel
  de relais de transactions ("fanout") fonctionne. Dans ces posts, il a discuté de différents
  résultats qu'il a trouvés lors du développement d'Erlay, comme le fait que [le filtrage basé sur la
  connaissance des transactions][erlay knowledge] n'était pas aussi impactant que prévu. Il a
  également expérimenté avec la sélection de [combien de pairs devraient recevoir un fanout][erlay
  fanout amount], découvrant qu'il y avait une économie de bande passante de 35% avec 8 pairs sortants
  et de 45% avec 12 pairs sortants, mais a également trouvé une augmentation de 240% de la latence.
  Dans deux autres expériences, il a déterminé le [taux de fanout basé sur la manière dont une
  transaction était reçue][erlay transaction received] et [quand sélectionner un candidat
  pair erlay][erlay candidate peers]. Ces expériences, combinant le fanout et la réconciliation,
  l'ont aidé à déterminer quand utiliser chaque méthode.

- **Scripts d'ancrage éphémères LN :** Après plusieurs mises à jour des politiques de mempool dans
  Bitcoin Core 28.0, la discussion a commencé en février autour des choix de conception pour les
  [ancrages éphémères][topic ephemeral anchors] dans les transactions d'engagement LN. Les
  contributeurs ont [examiné][news340 lneas] quelles constructions de scripts devraient être utilisées
  comme l'un des outputs des transactions d'engagement basées sur [TRUC][topic v3 transaction relay]
  en remplacement des [ancrages existants][topic anchor outputs].

  Les compromis incluaient comment différents scripts affectent le bumping de frais [CPFP][topic
  cpfp], le poids de la transaction, et la capacité à dépenser ou à jeter en toute sécurité les
  sorites d'ancrage lorsqu'ils ne sont plus nécessaires. La [discussion continue][news341 lneas] a mis
  en évidence les interactions avec la politique de mempool et les hypothèses de sécurité de Lightning.

- **Paiements probabilistes :** Oleksandr Kurbatov a lancé une
  [discussion][delving random] sur Delving Bitcoin sur les méthodes de production de résultats
  aléatoires à partir de scripts Bitcoin. La méthode [originale][ok random] utilise des preuves à
  divulgation nulle de connaissance dans un arrangement challenger/vérificateur et dispose maintenant
  d'un [concept prouvé publié][random poc]. D'autres méthodes ont été discutées,
  [incluant une][waxwing random] exploitation de la structure arborescente de
  taproot, et une [méthode][rl random] qui scripte le XOR de bits
  représentés par une séquence de différentes fonctions de hachage pour produire directement
  une chaîne de bits imprévisible. Il y a eu [discussion][dh random] sur le fait que
  de tels résultats de transactions aléatoires pourraient être utilisés pour produire des
  HTLCs probabilistes comme alternative aux [HTLCs réduits][topic trimmed htlc] pour de petits
  montants dans LN.

<div markdown="1" class="callout" id="vulns">

## Résumé 2025 : Divulgations de vulnérabilités

En 2025, Optech a résumé plus d'une douzaine de divulgations de vulnérabilités.
Les rapports de vulnérabilité aident les développeurs et les utilisateurs à apprendre des erreurs passées,
et les [divulgations responsables][topic responsible disclosures] garantissent que les correctifs sont
publiés avant que les vulnérabilités puissent être exploitées.

_Note : Optech ne publie les noms des découvreurs de vulnérabilités que si nous pensons
qu'ils ont fait un effort raisonnable pour minimiser le risque de préjudice pour les utilisateurs.
Nous remercions toutes les personnes mentionnées dans cette section pour leur perspicacité et leur préoccupation
claire pour la sécurité des utilisateurs._

Début janvier, Yuval Kogman a [divulgué publiquement][news335 coinjoin] plusieurs
faiblesses de déanonymisation de longue date dans les protocoles de [coinjoin][topic
coinjoin] centralisés utilisés par les versions actuelles de Wasabi et Ginger, ainsi que dans
les versions passées de Samourai, Sparrow et Trezor Suite. Si exploitées, un
coordinateur centralisé pourrait lier les entrées d'un utilisateur à ses sorties, enlevant
effectivement les avantages de confidentialité attendus du coinjoin. Une vulnérabilité similaire a
également été signalée fin 2024 (voir le [Bulletin #333][news333 coinjoin]).

Fin janvier, Matt Morehouse a [annoncé][news339 ldk] la divulgation responsable d'une vulnérabilité
dans le traitement des réclamations de LDK lors de fermetures unilatérales
avec de nombreux [HTLCs][topic htlc] en attente. LDK visait à réduire les frais en regroupant
plusieurs résolutions HTLC ; cependant, si des conflits survenaient avec des confirmations de
transactions provenant d'un contrepartie de canal, LDK pourrait ne pas mettre à jour tous les lots
affectés, conduisant à des fonds bloqués et même à un risque de vol. Ce problème a été résolu dans
LDK 0.1.

Cette même semaine, Antoine Riard a [révélé][news339 cycling] une vulnérabilité supplémentaire
utilisant l'attaque de [replacement cyclique][topic replacement cycling]. Un attaquant pourrait
l'exploiter en [épinglant][topic transaction pinning] une transaction non confirmée de la victime,
en recevant et ne propageant pas les remplacements de frais de la victime, puis en minant
sélectivement la version à frais les plus élevés de la victime. Ce scénario nécessitait des
conditions rares et serait difficile à maintenir sans être détecté.

En février, Morehouse a [révélé][news340 htlcbug] une seconde vulnérabilité LDK : si de nombreux
HTLC avaient le même montant et le même hash de paiement, LDK échouerait à régler tous les HTLC sauf
un, conduisant les contreparties honnêtes à forcer la fermeture des canaux. Bien que cela n'ait pas
permis de vol direct, cela a résulté en des frais supplémentaires et une réduction des revenus de
routage jusqu'à ce que le bug soit corrigé dans LDK 0.1.1 (voir le Bulletin [#340][news340 htlcfix]).

En mars, Morehouse a [annoncé][news344 lnd] la divulgation responsable d'une vulnérabilité LND
corrigée dans les versions antérieures à 0.18 : un attaquant avec un canal vers la victime pourrait
amener LND à payer et rembourser le même HTLC s'il pouvait également d'une manière ou d'une autre
provoquer le redémarrage du nœud de la victime. Cela permettrait à l'attaquant de voler presque la
totalité de la valeur du canal. La divulgation a également mis en évidence des lacunes dans la
spécification Lightning, qui ont été corrigées plus tard (voir le [Bulletin #346][news346 bolts]).

En mai, Ruben Somsen a [décrit][news353 bip30] un cas limite théorique de défaillance de consensus
lié au traitement historique par BIP30 des transactions coinbase en [doublons][topic duplicate
transactions]. Avec les points de contrôle retirés de Bitcoin Core (voir le [Bulletin #346][news346
checkpoints]), une réorganisation extrême des blocs jusqu'au bloc 91,842 pourrait laisser les nœuds
avec des ensembles UTXO différents, selon qu'ils aient observé ou non les coinbases doublons.
Plusieurs solutions ont été discutées, telles que l'ajout de logique spéciale pour ces deux
exceptions ; cependant, cela n'était pas considéré comme une menace réaliste.

Également en mai, Antoine Poinsot a [annoncé][news354 32bit] la divulgation responsable d'une
vulnérabilité de faible gravité affectant les versions de Bitcoin Core antérieures à 29.0 où des
publicités d'adresses excessives pourraient déborder un identifiant 32 bits et faire planter le
nœud. Des atténuations antérieures avaient déjà rendu l'exploitation pratiquement lente sous les
limites de pairs par défaut (voir les Bulletins [#159][news159 32bit] et [#314][news314 32bit]), et le
problème a été entièrement résolu en passant à des identifiants 64 bits dans Bitcoin Core 29.0.

En juillet, Morehouse a [annoncé][news364 lnd] la divulgation responsable d'un problème de déni de
service LND dans lequel un attaquant pourrait demander à plusieurs reprises des messages d'historiques
[gossip][topic channel announcements] jusqu'à ce que le nœud épuise sa mémoire et
plante. Ce bug a été corrigé dans LND 0.18.3 (voir le [Bulletin #319][news319 lnd]). En septembre,
Morehouse a [révélé][news373 eclair] une vulnérabilité dans les anciennes versions d'Eclair : un
attaquant pourrait diffuser une ancienne transaction d'engagement pour voler tous les fonds actuels
d'un canal, et Eclair l'ignorerait. La correction d'Eclair était accompagnée d'une mesure plus une
suite de tests complète destinée à détecter des problèmes potentiels similaires.
En octobre, Poinsot a [publié][news378 four] quatre vulnérabilités de Bitcoin Core de faible
gravité, divulguées de manière responsable, couvrant deux bugs de remplissage de disque, un crash à
distance hautement improbable affectant les systèmes 32 bits, et un problème de DoS CPU dans le
traitement des transactions non confirmées. Ces problèmes ont été partiellement résolus dans la
version 29.1 et entièrement résolus dans la version 30.0, voir les Bulletins [#361][news361 four],
[#363][news363 four], et [#367][news367 four] pour quelques-unes des corrections.

En décembre, Bruno Garcia a [divulgué][news383 nbitcoin] une défaillance théorique du consensus dans
la bibliothèque NBitcoin liée à `OP_NIP` qui pourrait déclencher une exception dans un cas limite
spécifique de pile en pleine capacité. Elle a été découverte en utilisant le fuzzing différentiel et
rapidement corrigée. Aucun nœud complet n'est connu pour utiliser NBitcoin, il n'y avait donc aucun
risque pratique de division de chaîne résultant de la divulgation.

En décembre, Morehouse a également [divulgué][news384 lnd] trois vulnérabilités critiques dans LND
incluant deux vulnérabilités de vol de fonds et une vulnérabilité de déni de service.

</div>

## Mars

- **Guide de Forking Bitcoin :** Anthony Towns a posté sur Delving Bitcoin [un guide][news344 fork
  guide] sur comment construire un consensus communautaire pour les changements dans les règles de
  consensus de Bitcoin. Selon Towns, le processus d'établissement du consensus peut être divisé en
  quatre étapes : [recherche et développement][fork guide red], [exploration par les utilisateurs
  avancés][fork guide pue], [évaluation par l'industrie][fork guide ie], et [révision par les
  investisseurs][fork guide ir]. Cependant, Towns a averti les lecteurs que le guide vise à être
  seulement une procédure de haut niveau, et qu'il pourrait fonctionner uniquement dans un
  environnement coopératif.

- **Marché privé de templates de blocs pour prévenir la centralisation du MEV :** Les développeurs
  Matt Corallo et 7d5x9 ont posté sur Delving Bitcoin [une proposition][news344 template mrkt] qui
  pourrait aider à prévenir un futur dans lequel existe MEVil, une forme de valeur extractible par les
  mineurs (MEV) menant à la centralisation du minage, et prolifère sur Bitcoin. La proposition, appelée
  [MEVpool][mevpool gh], permettrait aux parties d'enchérir sur des marchés publics pour un espace
  sélectionné dans les templates de blocs des mineurs (par exemple, "Je paierai X [BTC] pour inclure
  la transaction Y tant qu'elle vient avant toute autre transaction qui interagit avec le contrat
  intelligent identifié par Z").

  Bien que les services d'ordonnancement préférentiel des transactions dans les templates de blocs
  soient attendus pour être fournis uniquement par de grands mineurs, menant à la centralisation, un
  marché public réduit en confiance permettrait à tout mineur de travailler sur des templates de blocs
  aveuglés, dont les transactions complètes ne sont pas révélées aux mineurs jusqu'à ce qu'ils aient
  produit suffisamment de preuve de travail pour publier le bloc. Les auteurs ont averti que cette
  proposition nécessiterait plusieurs marchés concurrent afin de préserver la décentralisation
  contre la dominance d'un seul marché de confiance.

- **Frais initiaux et de maintien sur LN utilisant des sorties brûlables :** John Law a proposé [une
  solution][news 347 ln fees] aux [attaques de blocage de canal][topic channel jamming attacks], une
  faiblesse dans le protocole du Lightning Network qui permet à un attaquant d'empêcher sans coût les
  autres nœuds d'utiliser leurs fonds. La proposition résume un [document][ln fees paper] qu'il a
  écrit sur la possibilité des nœuds Lightning pour charger deux types supplémentaires de frais pour
  le transfert de paiements, un frais initial et un frais de rétention. Le dépensier final paierait le
  premier pour compenser les nœuds de transfert pour l'utilisation temporaire d'un emplacement
  [HTLC][topic htlc], tandis que le dernier serait payé par tout nœud qui retarde le règlement d'un HTLC,
  avec le montant des frais augmentant avec la durée du retard.

## Avril

{:#swiftsync}

- **Accélerateur SwiftSync pour le téléchargement initial de bloc :** Sebastian Falbesoner a
  [publié][news349 swiftsync] sur Delving Bitcoin une implémentation exemple et les résultats d'une
  accélération de plus de 5x du _téléchargement initial de bloc_ (IBD) grâce à SwiftSync, une idée
  initialement [proposée][swiftsync ruben gh] par Ruben Somsen.

  L'accélération est réalisée pendant l'IBD en ajoutant uniquement les pièces à l'ensemble UTXO
  lorsqu'elles seront encore dans l'ensemble UTXO à la fin de l'IBD. Cette connaissance de l'état
  final de l'ensemble UTXO est compactement encodée dans un fichier d'indices pré-généré, minimement
  fiable. En plus de minimiser la surcharge des opérations sur l'état de la chaîne, SwiftSync permet
  d'autres améliorations de performance en autorisant la validation parallèle des blocs.

  Le travail sur une implémentation en Rust a été [annoncé][swiftsync rust impl] en septembre.

{:#dahlias}

- **Signatures agrégées interactives DahLIAS :** En avril, Jonas Nick, Tim Ruffing et Yannick Seurin
ont [annoncé][news351 dahlias] à la liste de diffusion Bitcoin-Dev leur [document DahLIAS][dahlias
paper], le premier schéma de signature agrégée interactive de 64 octets compatible avec les
primitives cryptographiques déjà utilisées dans Bitcoin. Les signatures agrégées sont la condition
cryptographique pour l'[agrégation de signature inter-entrées][topic cisa] (CISA), une
fonctionnalité proposée pour Bitcoin qui pourrait réduire la taille des transactions avec plusieurs
entrées, réduisant ainsi le coût de nombreux types de dépenses, [coinjoins][topic coinjoin] et
[payjoins][topic payjoin] inclus.

<div markdown="1" class="callout" id="quantum">

## Résumé 2025 : Quantum

Avec l'attention accrue sur le potentiel d'un futur ordinateur [quantique][topic quantum resistance]
pour affaiblir ou briser l'hypothèse de dureté du logarithme discret de courbe elliptique (ECDL) sur
laquelle Bitcoin repose pour prouver la propriété des pièces, plusieurs conversations et
propositions ont été avancées tout au long de l'année pour discuter et atténuer l'impact d'un tel
développement.

Clara Shikhelman et Anthony Milton ont [publié][news357 quantum report] un document couvrant les
impacts de l'informatique quantique sur Bitcoin et esquissant des stratégies d'atténuation
potentielles.

[BIP360][] a été [mis à jour][news bip360 update] et a reçu son numéro BIP. Cette proposition a
suscité de l'intérêt à la fois comme un premier pas vers le renforcement quantique de Bitcoin et une
optimisation pour les cas d'utilisation de taproot qui ne nécessitent pas de clé interne. [La
recherche][news365 quantum taproot] plus tard dans l'année a confirmé la sécurité de ces engagements
taproot contre la manipulation par des ordinateurs quantiques. Vers la fin de l'année, la
proposition a été renommée en P2TSH (pay to tapscript hash) au lieu du nom précédent P2QRH (pay to
quantum resistant hash), reflétant sa portée réduite et sa généralité accrue.

Jesse Posner a [mis en évidence les recherches existantes][news364 quantum primatives] qui
indique que les primitives Bitcoin existantes telles que les portefeuilles déterministes
hiérarchiques (HD), les [paiements silencieux][topic silent payments], l'agrégation de clés et les
[signatures seuils][topic threshold signature] pourraient être compatibles avec certains des
algorithmes de signature résistants aux quantiques fréquemment référencés.

Augustin Cruz a [proposé][news qr cruz] un BIP pour détruire avec certitude les pièces vulnérables
aux quantiques. Par la suite, Jameson Lopp a [lancé une discussion][news qr lopp1] sur la manière
dont les pièces vulnérables aux quantiques devraient être traitées, ce qui a mené à plusieurs idées
allant de laisser l'adversaire quantique les avoir à les détruire. Lopp a plus tard [proposé][news
qr lopp2] une [séquence concrète de soft forks][BIPs #1895] que Bitcoin pourrait implémenter,
commençant bien avant qu'un Ordinateur Quantique Cryptographiquement Pertinent (CRQC) soit développé
pour atténuer progressivement la menace d'un adversaire quantique soudainement capable d'accéder à
de nombreuses pièces, tout en permettant aux détenteurs de sécuriser leurs pièces.

Deux propositions ([1][news qr sha], [2][news qr cr]) ont été faites pour permettre à la plupart des
pièces existantes d'être sécurisées d'une manière qui pourrait être récupérée dans l'événement où
Bitcoin désactiverait les dépenses vulnérables aux quantiques à un moment ultérieur. Brièvement, la
séquence d'événements théorisée est 0) les détenteurs de bitcoin s'assurent que leurs portefeuilles
actuels ont un secret haché requis pour un certain chemin de dépense 1) un CRQC est montré comme
imminent, 2) Bitcoin désactive les signatures de courbe elliptique, 3) Bitcoin active un schéma de
signature sécurisé quantique, 4) Bitcoin active l'une de ces propositions permettant aux détenteurs
préparés de réclamer leurs pièces vulnérables aux quantiques. Selon l'implémentation exacte,
n'importe quel type d'adresse (y compris P2TR avec un scriptpath) pourrait tirer avantage de ces
méthodes.

Le développeur Conduition a démontré que [`OP_CAT`][BIP347] peut être utilisé pour implémenter des
signatures Winternitz, qui fournissent une vérification de signature résistante aux quantiques à un
coût d'environ 2000 vbytes par entrée. Cela coûte moins cher que les signatures précédemment [proposées][rubin
lamport] basées sur `OP_CAT` [Lamport][lamport].

Matt Corallo a commencé une [discussion][news qr corallo] autour de l'idée générale d'ajouter un
opcode de vérification de signature résistant aux quantiques à [tapscript][topic tapscript]. Plus
tard, Abdelhamid Bakhta a [proposé][abdel stark] la vérification native STARK comme un tel opcode,
et Conduition a [écrit][conduition sphincs] sur leur travail d'optimisation des signatures
quantiques résistantes SLH-DSA (SPHINCS) comme une autre option. Tout opcode de vérification de
signature résistant aux quantiques incluant `OP_CAT` ajouté à tapscript pourrait être combiné avec
[BIP360][] pour durcir complètement les sorties Bitcoin contre les quantiques.

Tadge Dryja a [proposé][news qr agg] une manière dont Bitcoin pourrait implémenter l'agrégation de
signature inter-entrées générale qui atténuerait partiellement la grande taille des signatures
post-quantiques.

À la fin de l'année, Mikhail Kudinov et Jonas Nick ont [publié][nick paper tweet] un
[document][hash-based signature schemes] qui fournit un aperçu des schémas de signature basés sur le
hachage et discute de la manière dont ceux-ci pourraient être adaptés aux besoins de Bitcoin.

</div>

## Mai

{:#clustermempool}

- **Cluster mempool :** Au début de l'année, Stefan Richter a suscité l'enthousiasme en
  [découvrant][news340 richter ggt] qu'un algorithme efficace pour le
  le problème de _maximum-ratio closure_ issu d'un article de recherche de 1989 pourrait être appliqué
  à la linéarisation des clusters. Pieter Wuille enquêtait déjà sur une approche de programmation
  linéaire comme amélioration potentielle par rapport à la recherche initiale de l'ensemble des
  candidats et a intégré l'exploration de l'approche basée sur la coupe minimale comme une troisième
  option dans sa recherche. Un peu plus tard, Wuille a guidé le Bitcoin Core PR Review Club à travers
  la nouvelle classe `TxGraph` qui distille les transactions pour ne conserver que le poids, les frais
  et les relations pour une interaction efficace avec le graphe du mempool. En mai, Wuille a publié
  des benchmarks favorables et décrit les [compromis][news352 wuille linearization techniques] des trois
  approches de linéarisation des clusters, déterminant que les deux approches avancées étaient bien
  plus efficaces que la simple recherche de l'ensemble des candidats, mais que son algorithme de
  linéarisation de forêt couvrante basé sur la programmation linéaire serait plus pratique que
  l'approche basée sur la coupe minimale. À l'automne, Abubakar Sadiq Ismail [a décrit][news377 ismail
  template improvement] comment le mempool des clusters pourrait être utilisé pour suivre quand le
  contenu du mempool s'était considérablement amélioré par rapport à un modèle de bloc précédent. Vers
  la fin de l'année, l'implémentation du mempool des clusters a été [achevée][news382 cluster mempool
  completed], la préparant à être publiée avec Bitcoin Core 31.0. Le travail pour remplacer
  l'algorithme de linéarisation de recherche de l'ensemble des candidats initiaux par l'algorithme de
  linéarisation de forêt couvrante est en cours.

{:#opreturn}

- **Augmenter ou supprimer la limite de politique OP_RETURN de Bitcoin Core :** En avril, les
  développeurs de protocole ont découvert que les limites de politique de sortie OP_RETURN
  provoquaient un mal incitatif à intégrer des données dans les sorties de paiement sous certaines
  circonstances. En plus de l'observation que les motivations originales pour la politique avaient été
  dépassées par le réseau, cela a incité une proposition pour supprimer les limites de politique du
  mempool OP_RETURN. Cette proposition a déclenché un chaud [débat][news352 OR debate] sur
  l'efficacité de la politique du mempool, le but de Bitcoin, et la responsabilité des développeurs de
  Bitcoin de réguler ou de s'abstenir de réguler l'utilisation de Bitcoin. Les contributeurs de
  Bitcoin Core ont argué que les incitations économiques rendaient peu probable que les sorties
  OP_RETURN voient un usage drastiquement plus important et ont considéré le changement comme la
  correction du bug d'incitation. Les critiques ont interprété la suppression des limites comme une
  approbation de l'intégration de données, mais ont également convenu que cela est économiquement peu
  attrayant pour être utilisé de cette manière. Finalement, la version Bitcoin Core 30.0 a été livrée
  avec une [politique mise à jour][Bitcoin Core #32406], pour permettre plusieurs sorties OP_RETURN et
  supprimer la limite de politique sur la taille pour les scripts de sortie OP_RETURN. Après la
  sortie, plusieurs propositions de soft fork ont été mises en avant, proposant de [limiter
  l'intégration de données](#arbdata) au niveau du consensus.

## Juin

{:#selfishmining}

- **Calculer le seuil de danger du minage égoïste :** Antoine Poinsot a fourni une [explication
  approfondie][news358 selfish miner] des mathématiques derrière l'[attaque de minage égoïste][topic
  selfish mining], basée sur le [papier][selfish miner paper] de 2013 qui a donné son nom à cette
  exploit. Poinsot s'est concentré sur la reproduction d'une des conclusions du papier, prouvant qu'un
  mineur malhonnête contrôlant 33% du hashrate total du réseau peut devenir marginalement plus
  rentable que les autres mineurs en retardant sélectivement l'annonce
  de certains des nouveaux blocs qu'il trouve.

{:#fingerprinting}

- **Empreintes digitales des nœuds utilisant les messages addr :** Les développeurs Daniela Brozzoni
  et Naiyoma ont présenté les [résultats][news360 fingerprinting] de leur recherche sur les empreintes
  digitales, qui se concentrait sur l'identification du même nœud sur plusieurs réseaux en utilisant
  les messages `addr`, envoyés par les nœuds, à travers le protocole P2P, pour annoncer d'autres pairs
  potentiels. Brozzoni et Naiyoma ont réussi à identifier les nœuds individuellement en utilisant les
  détails de leurs messages d'adresse spécifiques, leur permettant d'identifier le même nœud
  fonctionnant sur plusieurs réseaux (tels que IPv4 et [Tor][topic anonymity networks]). Les
  chercheurs ont suggéré deux atténuations possibles : soit supprimer entièrement les horodatages des
  messages d'adresse, soit les randomiser légèrement pour les rendre moins spécifiques à des nœuds
  particuliers.

{:#garbledlocks}

- **Verrous embrouillés :** En juin, Robin Linus a présenté [une proposition][news359 bitvm3] pour
  améliorer les contrats de style [BitVM][topic acc], basée sur une [idée][delbrag rubin] de Jeremy
  Rubin. La nouvelle approche tire parti des [circuits embrouillés][garbled circuits wiki], un
  primitif cryptographique qui rend la vérification SNARK onchain mille fois plus efficace que
  l'implémentation BitVM2, promettant une réduction significative de la quantité d'espace onchain
  nécessaire. Cependant, cela nécessite une configuration offchain de plusieurs téraoctets.

  Plus tard, en août, Liam Eagen a [posté][news369 eagen] sur la liste de diffusion Bitcoin-Dev à
  propos de son [article][eagen paper] décrivant un nouveau mécanisme pour créer des [contrats de
  calcul responsables][topic acc] basés sur des circuits embrouillés, appelé Glock (verrous
  embrouillés). Bien que l'approche soit similaire, la recherche d'Eagen est indépendante de celle de
  Linus. Selon Eagen, Glock permet une réduction de 550x des données onchain par rapport à BitVM2.

<div markdown="1" class="callout" id="softforks">

## Résumé 2025 : Propositions de soft fork

Cette année a vu une multitude de discussions autour des propositions de soft fork, allant de celles
à portée limitée et à impact minimal, à celles à portée large et puissante.

- *Modèles de transaction :* Plusieurs ensembles de soft fork ont été discutés autour des modèles de
  transaction. Avec une portée et une capacité similaires, il y a CTV+CSFS ([BIP119][]+[BIP348][]) et
  le [paquet de signature réaffectable natif de taproot][news thikcs] ([`OP_TEMPLATEHASH`][BIPs
  #1974]+[BIP348][]+[BIP349][]). Ces propositions représentent l'amélioration minimale de la capacité
  pour le Script Bitcoin pour permettre à la fois des signatures réaffectables (signatures qui ne
  s'engagent pas à dépenser un UTXO spécifique), et un pré-engagement à dépenser un UTXO pour une
  transaction suivante spécifique (parfois appelé un [covenant][topic covenants] d'égalité). Si
  activées, elles permettraient [LN-Symmetry][ctv csfs symmetry] et les [coffre-forts simple CTV][ctv vaults],
  [réduire les exigences de signature DLC][ctv dlcs], [réduire l'interactivité pour les Arks][ctv csfs
  arks], [simplifier les PTLCs][ctv csfs ptlcs], et plus. Une différence entre ces propositions est
  que `OP_TEMPLATEHASH` ne peut pas
  être utilisé dans le [BitVM sibling hack][ctv csfs bitvm] où CTV peut, parce que `OP_TEMPLATEHASH`
  ne s'engage pas sur les `scriptSigs`.

  En incluant [OP_CHECKSIGFROMSTACK][topic OP_CHECKSIGFROMSTACK], ces propositions permettent
  également des engagements multiples (s'engager sur plusieurs valeurs liées et optionnellement
  ordonnées dans un script de verrouillage ou de dépense) similaires aux arbres de Merkle grâce au
  [Key Laddering][rubin key ladder]. La proposition mise à jour de [LNHANCE][lnhance update] inclut
  `OP_PAIRCOMMIT` ([BIPs #1699][]) pour permettre des engagements multiples sans la taille de script
  supplémentaire et le coût de validation requis pour le Key Laddering. Les engagements multiples sont
  utiles dans LN-Symmetry, les délégations complexes, et plus encore.

  Certains développeurs [ont exprimé leur frustration][ctv csfs letter] concernant (de leur point de
  vue) la lente progression vers un soft fork, mais le volume de discussion autour de cette catégorie
  de proposition suggère que l'intérêt et l'enthousiasme restent élevés.

- *Nettoyage du consensus :* La proposition de [nettoyage du consensus][topic consensus cleanup] a
  été [mise à jour][gcc update] sur la base des retours et des recherches supplémentaires, un
  [brouillon de BIP][gcc bip] a été publié et fusionné en tant que [BIP54][] et inclut maintenant [une
  implémentation et des vecteurs de test][gcc impl tests]. Plus tôt cette année, il y a eu
  [discussion][transitory cleanups] sur le fait que de tels nettoyages devraient être rendus
  temporaires en cas de confiscation involontaire, mais la nécessité de réévaluer un tel [soft fork
  temporaire][topic transitory soft forks] à chaque expiration rend ces soft forks temporaires moins
  attrayants.

- *Propositions d'opcode :* En plus des propositions d'opcode groupées discutées ci-dessus,
  plusieurs autres opcodes individuels de Script ont été proposés ou affinés en 2025.

  `OP_CHECKCONTRACTVERIFY` (CCV) est devenu [BIP443][] avec des sémantiques [affinées][ccv semantics],
  en particulier concernant le flux de fonds. CCV permet des [coffre-forts][topic vaults] de sécurité
  réactive, et un large éventail d'autres contrats en contraignant le `scriptPubKey` et le montant
  d'une entrée ou sortie de certaines manières. La proposition `OP_VAULT` a été [retirée][vault
  withdrawn] en faveur de CCV. Pour plus d'informations sur les applications de CCV, voir [l'entrée du
  topic d'Optech][topic MATT].

  Un ensemble d'opcodes arithmétiques de 64 bits a été [proposé][64bit bip]. Les opérations
  mathématiques actuelles de Bitcoin ne sont (surprenamment) pas capables d'opérer sur la gamme
  complète des montants d'entrée et de sortie de Bitcoin. Combinées avec d'autres opcodes pour accéder
  et/ou contraindre les montants d'entrée/sortie, ces opérations arithmétiques étendues pourraient
  permettre de nouvelles fonctionnalités de portefeuille Bitcoin.

  Une [variante proposée][txhash sponsors] de [`OP_TXHASH`][txhash] permettrait le [parrainage de
  transactions][topic fee sponsorship].

  Les développeurs ont proposé deux options pour donner à Script des opérations cryptographiques sur
  courbes elliptiques autres que `OP_CHECKSIG` et les opérations liées. L'une [propose][tweakadd]
  `OP_TWEAKADD` pour permettre de construire des `scriptPubKeys` taproot. L'autre [propose][ecmath]
  des opcodes de courbe elliptique plus granulaires, tels que `EC_POINT_ADD`, motivés par une
  fonctionnalité similaire, mais avec des
  applications plus larges, telles que de nouvelles vérifications de signature ou des fonctionnalités
  de multisignature. Combiner l'une de ces propositions avec `OP_TXHASH` et l'arithmétique 64 bits (ou
  des opcodes similaires) permettrait une fonctionnalité similaire à CCV.

- *Restauration de Script :* Une série de quatre BIPs a été [publiée][gsr bips] pour le projet de
  Restauration de Script. Les changements de Script et les opcodes proposés dans ces quatre BIPs
  permettraient toute la fonctionnalité proposée dans les propositions d'opcode précédentes tout en
  permettant une plus grande expressivité de script.

</div>

## Juillet

{:#ccdelegation}

- **Délégation de code chaîne :** Jurvis Tan a [publié][jt delegation] sur son travail avec Jesse
  Posner sur une méthode (désormais appelée [Délégation de Code Chaîne][BIPs #2004]/BIP89) pour la
  garde collaborative où le client, plutôt que le fournisseur de garde collaborative partiellement
  fiable, génère (et garde privé) le code chaîne [BIP32][] pour dériver les clés enfant de la clé de
  signature du fournisseur. De cette manière, le fournisseur ne peut pas dériver l'arbre complet des
  clés du client. La méthode peut être utilisée soit de manière aveugle (pour une confidentialité
  complète tout en tirant parti de la sécurité de la clé du fournisseur) soit de manière non aveugle
  (permettant au fournisseur d'appliquer une politique au prix de la révélation des transactions
  spécifiques signées au fournisseur).

## Août

{:#utreexo}

- **Brouillons de BIP Utreexo :** Calvin Kim, Tadge Dryja et Davidson Souza ont co-écrit [trois
  brouillons de BIP][news366 utreexo] pour une alternative à la conservation de l'ensemble complet des
  UTXO, appelée [Utreexo][topic utreexo], qui permet aux nœuds d'obtenir et de vérifier des
  informations sur les UTXOs dépensés dans une transaction. La proposition utilise une forêt d'arbres
  de Merkle pour accumuler des références à chaque UTXO, permettant aux nœuds d'éviter de stocker les
  sorties.

  Depuis août, la proposition a reçu des retours, et les BIPs ont été numérotés :

  * *[BIP181][bip181 utreexo]* : Décrit l'accumulateur Utreexo et ses opérations.

  * *[BIP182][bip182 utreexo]* : Définit les règles pour valider les blocs et les transactions en
  utilisant l'accumulateur Utreexo.

  * *[BIP183][bip183 utreexo]* : Définit les changements nécessaires pour que les nœuds puissent
  échanger une preuve d'inclusion, confirmant les UTXOs dépensés.

{:#minfeerate}

- **Abaissement du taux de frais minimum de relais :** Après que la réduction du taux de frais
  minimum de relais des transactions ait été [discutée plusieurs fois][news340 lowering feerates] au
  cours des dernières années, fin juin, certains mineurs ont soudainement commencé à inclure des
  transactions payant moins que le taux de frais minimum de relais par défaut de 1 sat/vbyte dans
  leurs blocs. À la fin du mois de juillet, [85% du hashrate][mononautical 85] avait adopté des taux
  de frais minimums plus bas et les transactions à faible taux de frais se propageaient organiquement
  (bien que de manière peu fiable) sur le réseau en raison de la configuration manuelle de limites
  inférieures par les opérateurs de nœuds. À la mi-août, [plus de 30% des transactions
  confirmées][mononautical 32] payaient des taux de frais inférieurs à 1 sat/vbyte. Les développeurs
  du protocole Bitcoin ont observé que le taux élevé de transactions à faible taux de frais manquantes
  [provoquait une diminution des taux de reconstruction de blocs compacts]][0xb10c delving]
  et fait une [proposition][news366 lower feerate] d'ajustement du taux minimal de relais par
  défaut. La version 29.1 de Bitcoin Core a réduit le taux minimal de relais par défaut à 0,1 
  sat/vbyte au début de septembre.

{:#templatesharing}

- **Partage de modèles de blocs entre pairs :** Anthony Towns a proposé une [méthode][news366 templ
  share] pour améliorer l'efficacité de la reconstruction de blocs compacts dans un environnement où
  les politiques de mempool des pairs divergent. La proposition permettrait aux nœuds complets
  d'envoyer des modèles de blocs à leurs pairs, qui à leur tour, mettraient en cache ces transactions
  qui seraient autrement rejetées par leurs politiques de mempool. Le modèle fourni contient des
  identifiants de transaction encodés dans le même format utilisé par le [relai de blocs
  compacts][topic compact block relay].

  Plus tard, en août, Towns a ouvert un [BIPs #1937][] pour [discuter formellement de la
  proposition][news368 templ share] de partage de modèles de blocs. Au cours de la discussion,
  plusieurs développeurs ont exprimé des préoccupations concernant la vie privée et le potentiel de
  fingerprinting des nœuds. En octobre, Towns a décidé de [déplacer le brouillon][news376 templ share]
  vers le dépôt [Bitcoin Inquisition Numbers and Names Authority][binana repo] (BINANA) pour aborder
  ces considérations et affiner le document. Le brouillon a reçu le code [BIN-2025-0002][bin].

{:#fuzzing}

- **Fuzzing différentiel des implémentations de Bitcoin et LN :** Bruno Garcia a donné une mise à
  jour sur les [progrès et résultats][news369 fuzz] obtenus par [bitcoinfuzz][], une bibliothèque pour
  effectuer des tests de fuzzing sur les implémentations et bibliothèques de Bitcoin et Lightning. En
  utilisant la bibliothèque, les développeurs ont signalé plus de 35 bugs dans des projets liés à
  Bitcoin, tels que btcd, rust-bitcoin, rust-miniscript, LND, et plus encore.

  Garcia a également souligné l'importance du fuzzing différentiel dans l'écosystème. Les développeurs
  sont capables de découvrir des bugs dans des projets qui n'implémentent pas du tout le fuzzing, de
  repérer des divergences entre les implémentations de Bitcoin, et de trouver des lacunes dans les
  spécifications de Lightning.

  Enfin, Garcia a encouragé les mainteneurs à intégrer davantage de projets dans bitcoinfuzz, en
  élargissant le support pour le fuzzing différentiel, et a fourni des orientations possibles pour le
  développement futur du projet.

<div markdown="1" class="callout" id="stratumv2">

## Résumé 2025 : Stratum v2

[Stratum v2][topic pooled mining] est un protocole de minage conçu pour remplacer le protocole
Stratum original utilisé entre les mineurs et les pools de minage. L'un de ses principaux avantages
est qu'il peut permettre aux membres individuels du pool de choisir quelles transactions inclure
dans leurs blocs, améliorant la résistance à la censure de Bitcoin en distribuant la sélection des
transactions à de nombreux mineurs indépendants.

Tout au long de 2025, Bitcoin Core a reçu plusieurs mises à jour pour mieux soutenir les
implémentations de Stratum v2. Certaines améliorations plus tôt dans l'année étaient concentrées sur
les RPCs de minage, [les mettant à jour][news339 sv2fields] avec les champs `nBits`, `target`, et
`next`, utiles pour construire et valider des modèles de blocs.

Le travail le plus significatif s'est concentré sur l'interface de communication inter-processus
(IPC) expérimentale de Bitcoin Core, qui permet à un service Stratum v2 externe d'interagir avec la
validation de blocs de Bitcoin Core sans utiliser l'interface JSON-RPC plus lente. Une nouvelle
méthode [`waitNext()`][news346 waitnext] a été introduite à l'interface `BlockTemplate` qui retourne
un nouveau modèle uniquement lorsque le sommet de la chaîne change ou lorsque les frais de mempool
augmentent significativement, réduisant les recalculs inutiles de
génération de modèles. [`checkBlock`][news360 checkblock] a ensuite été ajouté, permettant aux pools
de valider les modèles fournis par les mineurs via IPC. IPC a également été [activé][news369 ipc]
par défaut, et le nouveau `bitcoin-node` ainsi que d'autres binaires multiprocessus ont été ajoutés
aux versions de publication. Un exécutable wrapper `bitcoin` a été [ajouté][news357 wrapper] pour
découvrir facilement et lancer un nombre croissant de binaires, et une mise à jour a
[implémenté][news374 ipcauto] la sélection automatique du multiprocessus, éliminant le besoin du
drapeau de démarrage `-m`. Les améliorations de l'IPC de cette année ont été conclues par [la
réduction de la consommation CPU][news377 ipclog] pour la journalisation multiprocessus et [en
assurant][news381 witness] que les blocs soumis via IPC ont leur engagement de témoin revalidé.

[Bitcoin Core 30.0][news376 30], sorti en octobre, était la première version à inclure l'interface
expérimentale de minage IPC, précédemment [introduite][news323 miningipc] l'année dernière.

En juin, StarkWare a [démontré][news359 starkware] un client Stratum v2 modifié utilisant des
preuves STARK pour prouver que les frais d'un bloc appartiennent à un modèle valide sans révéler les
transactions du bloc. Deux nouvelles pool de minage basées sur Stratum v2 ont également été
lancées : [Hashpool][news346 hashpool], qui représente les parts de minage sous forme de jetons
[ecash][topic ecash], et [DMND][news346 dmnd], qui est passé du minage solo au minage en pool.

</div>

## Septembre

- **Détails sur la conception de Simplicity :** Après la sortie de [Simplicity][topic simplicity]
  sur le Liquid Network, Russell O'Connor a fait trois publications sur Delving Bitcoin pour discuter
  de la [philosophie et de la conception][simplicity 370] derrière le langage :

  * *[Partie I][simplicity I post]* examine les trois principales formes de composition pour
    transformer des opérations basiques en opérations complexes.

  * *[Partie II][simplicity II post]* plonge dans les combinatoires du système de types de Simplicity
    et les expressions de base.

  * *[Partie III][simplicity III post]* explique comment construire des opérations logiques à partir
    de bits jusqu'aux opérations cryptographiques en utilisant uniquement des combinatoires de calcul de
    Simplicity.

  Depuis septembre, deux autres publications ont été publiées sur Delving Bitcoin, [Partie
  IV][simplicity IV post], discutant des effets de bord, et [Partie V][simplicity V post], traitant
  des programmes et des adresses.

- **Partitionnement et attaques par éclipse utilisant l'interception BGP :** Cedarctic a
  [publié][Cedarctic post] sur Delving Bitcoin à propos des failles dans le Protocole de Passerelle
  Frontière (BGP) qui pourraient être utilisées pour empêcher les nœuds complets de pouvoir se
  connecter à des pairs honnêtes, permettant potentiellement des partitions de réseau ou des [attaques
  par éclipse][eclipse attack]. Plusieurs atténuations ont été décrites par Cedarctic, avec d'autres
  développeurs dans la discussion décrivant d'autres atténuations et moyens de surveiller l'attaque.

<div markdown="1" class="callout" id="releases">

## Résumé 2025 : Principales sorties de projets d'infrastructure populaires

- [BDK wallet-1.0.0][] a marqué la première sortie majeure de cette bibliothèque, où le crate `bdk`
  original a été renommé en `bdk_wallet` avec une API stable et des modules de couche inférieure ont
  été extraits dans leurs propres crates.

- [LDK v0.1][] a ajouté le support pour les deux côtés des protocoles de négociation d'ouverture de
  canal LSPS, [BIP353][] de résolution de noms lisibles par l'homme, et réduit les coûts de frais onchain
  lors de la résolution de multiples [HTLCs][topic htlc] pour une fermeture forcée de canal unique.

- [Core Lightning 25.02][] a ajouté le support pour le [stockage de pairs][topic peer storage],
  désactivé par défaut.

- [Eclair v0.12.0][] a ajouté le support pour la création et la gestion des [offres BOLT12][topic
  offers], un nouveau protocole de fermeture de canal qui supporte [RBF][topic rbf], et le support
  pour le stockage de petites quantités de données pour les pairs à travers le [stockage de pairs][topic
  peer storage].

- [BTCPay Server 2.1.0][] a ajouté plusieurs améliorations pour [RBF][topic rbf] et [CPFP][topic
  cpfp] pour l'augmentation des frais, un meilleur flux pour multisig lorsque tous les signataires
  utilisent BTCPay Server, et a effectué quelques changements majeurs pour les utilisateurs de
  certains altcoins.

- [Bitcoin Core 29.0][] a remplacé la fonctionnalité UPnP (responsable en partie de plusieurs
  vulnérabilités de sécurité passées) par une option NAT-PMP, amélioré la récupération des parents de
  transactions orphelines pour le [relai de paquets][topic package relay], amélioré l'évitement de
  [timewarp][topic time warp] pour les mineurs, et migré le système de construction de `automake` à
  `cmake`.

- [LND 0.19.0-beta][] a ajouté un nouveau bumping de frais basé sur RBF pour les fermetures
  coopératives.

- [Core Lightning 25.05][] a introduit un support expérimental pour le [splicing][topic splicing]
  compatible avec Eclair, et activé le stockage de pairs par défaut.

- [BTCPay Server 2.2.0][] a ajouté le support pour les politiques de portefeuille et
  [miniscript][topic miniscript].

- [Core Lightning v25.09][] a ajouté le support à la commande `xpay` pour payer les adresses
  [BIP353][] et les [offres][topic offers].

- [Eclair v0.13.0][] a introduit une mise en œuvre initiale de [canaux simple taproot][topic simple
  taproot channels], des améliorations au [splicing][topic splicing] basées sur les mises à jour
  récentes des spécifications, et un meilleur support BOLT12.

- [Bitcoin Inquisition 29.1][] a ajouté le support pour `OP_INTERNALKEY`, un opcode faisant partie
  de plusieurs propositions de [covenants][topic covenants].

- [Bitcoin Core 30.0][] a rendu standard plusieurs sorties de porteur de données (OP_RETURN),
  augmenté la `datacarriersize` par défaut à 100 000, fixé un [taux de frais minimum de relais par
  défaut][topic default minimum transaction relay feerates] de 0.1 sat/vbyte, ajouté une interface de
  minage IPC expérimentale pour les intégrations [Stratum v2][topic pooled mining], et retiré le
  support pour la création ou le chargement de portefeuilles hérités. Les portefeuilles hérités
  peuvent être migrés vers le format de portefeuille [descripteur][topic descriptors].

- [Core Lightning v25.12][] a ajouté les phrases de semence mnémonique [BIP39][] comme nouvelle
  méthode de sauvegarde par défaut et un support expérimental pour les [canaux JIT][topic jit channels].

- [LDK 0.2][] a ajouté le support pour le [splicing][topic splicing] (expérimental), servant et payant
  des factures statiques pour les [paiements asynchrones][topic async payments], et des canaux d'[engagement
  sans frais][topic v3 commitments] utilisant les [ancres éphémères][topic ephemeral anchors].

</div>

## Octobre

{:#arbdata}

- **Discussions sur les données arbitraires :** La conversation en octobre a revisité
  des questions de longue date sur l'intégration de données arbitraires dans les transactions Bitcoin
  et les limites de l'utilisation de l'ensemble UTXO à cet effet. [Une analyse][news375
  arb data] a examiné les contraintes théoriques sur le stockage des données dans les UTXOs, même
  sous un ensemble restrictif de règles de transaction Bitcoin.

  Les [discussions][news379 arb data] subséquentes tout au long de l'année
  se sont concentrées sur la question de savoir si les restrictions de consensus sur les transactions
  portant des données devraient être considérées.

{:#channeljamming}

- **Résultats de simulation et mises à jour sur l'atténuation du brouillage de canal :** Carla
  Kirk-Cohen, en collaboration avec Clara Shikhelman et elnosh, a publié les
  [résultats de la simulation de brouillage de Lightning][channel jamming results] pour leur
  algorithme de réputation mis à jour. Les mises à jour comprenaient le suivi de la réputation pour
  les canaux sortants et le suivi des limitations de ressources des canaux entrants. Avec
  ces nouvelles mises à jour, ils ont trouvé que cela protège toujours contre
  les attaques de [ressources][channel jamming resource] et de [puits][channel jamming sink].
  Après ce cycle de mises à jour et de simulations, ils estiment que l'atténuation des
  attaques de brouillage de canal a atteint un point où elle est suffisante pour une mise en œuvre.

## Novembre

{:#secpperformance}

- **Comparaison de la performance de la validation de signature ECDSA dans OpenSSL vs. libsecp256k1 :**
  Dix ans après que Bitcoin Core soit passé d'OpenSSL à libsecp256k1, Sebastian
  Falbesoner a [publié][openssl vs libsecp256k1] une analyse comparative de la performance
  des deux bibliothèques cryptographiques pour la validation de signature.
  Libsecp256k1 a été créé en 2015 spécifiquement pour Bitcoin Core, et était
  déjà entre 2,5 et 5,5 fois plus rapide à l'époque. Falbesoner a trouvé que l'écart
  s'est depuis élargi à plus de 8x, car libsecp256k1 a continué à s'améliorer tandis
  que la performance de secp256k1 d'OpenSSL est restée statique, ce qui n'est pas surprenant étant
  donné la pertinence limitée de la courbe en dehors de Bitcoin.

  Dans la discussion, le créateur de libsecp256k1, Pieter Wuille, note que les
  benchmarks ont des biais inhérents : toutes les versions ont été testées sur du matériel moderne
  et des compilateurs, mais les optimisations historiques ciblaient le matériel et
  les compilateurs qui existaient à l'époque.

{:#stalerates}

- **Modélisation des taux d'obsolescence par délai de propagation et centralisation de l'exploitation minière :**
  Antoine Poinsot a [publié][Antoine post] sur Delving Bitcoin en analysant comment les délais de
  propagation des blocs avantagent systématiquement les mineurs plus importants. Il a modélisé deux
  scénarios dans lesquels le bloc A devient obsolète. Dans le premier, un bloc concurrent B est
  trouvé avant A et se propage en premier. Dans le second, B est trouvé peu après
  A, mais le même mineur trouve également le bloc suivant. Le premier scénario est plus
  probable, suggérant que les mineurs bénéficient plus d'entendre rapidement les blocs des autres
  que de diffuser les leurs.

  Poinsot a montré que les taux d'obsolescence augmentent avec le délai de propagation et
  affectent de manière disproportionnée les mineurs plus petits. Il a trouvé qu'avec un délai de
  propagation de 10 secondes, une opération de 5 EH/s générant 91 millions de dollars annuellement
  pourrait gagner environ 100 000 dollars
  de revenus supplémentaires en se connectant au plus grand pool plutôt qu'au plus petit. Étant donné
  que l'exploitation minière fonctionne avec des marges réduites, de petites différences de revenus
  peuvent se traduire par des impacts significatifs sur les profits.

{:#bip3}

- **BIP3 et le processus BIP :** En 2025, le travail sur une proposition de mise à jour du processus
  BIP a avancé de manière significative. BIP3 a été [attribué][news341 bip3 assigned] d'un numéro en
  janvier, publié en février, et est passé à l'état Proposé en avril. Une révision supplémentaire a
  été suivie de quelques mises à jour, dans lesquelles les Expressions de Licence SPDX ont été
  introduites, certains en-têtes de Préambule ont été mis à jour, et plusieurs clarifications ont été
  intégrées dans les propositions. En novembre, Murch a [proposé d'activer][news382 motion to activate
  bip3] la proposition, en demandant aux lecteurs de revoir la proposition dans les quatre semaines
  suivantes et de commenter si BIP3 devrait être activé. Une série de révisions subséquentes a résulté
  en quelques améliorations supplémentaires et la révocation de directives controversées interdisant
  l'utilisation des LLMs dans la rédaction des BIPs. Alors que l'année se termine, toutes les
  révisions ont été prises en compte, et BIP3 est [à la recherche d'un consensus général][bip3
  feedback addressed] pour une nouvelle activation.

{:#kernelapi}

- **Introduction de l'API C au noyau Bitcoin :** [Bitcoin Core #30595][news380 kernel] a introduit
  un en-tête C qui sert d'API pour [`bitcoinkernel`][Bitcoin Core #27587], permettant aux projets
  externes d'interfacer avec la logique de validation des blocs et l'état de la chaîne de Bitcoin Core
  via une bibliothèque C réutilisable. Actuellement, elle est limitée aux opérations sur les blocs et
  possède une parité de fonctionnalités avec le désormais obsolète `libbitcoin-consensus` (voir
  le [Bulletin #288][news288 lib]).

  Les cas d'utilisation pour `bitcoinkernel` incluent des implémentations alternatives de nœuds, un
  constructeur d'index de serveur Electrum, un scanner de [paiements silencieux][topic silent
  payments], un outil d'analyse de blocs, et un accélérateur de validation de scripts, entre autres.
  Plusieurs liaisons linguistiques sont en développement, y compris pour [Rust][kernel rust],
  [Go][kernel go], [JDK][kernel jdk], [C#][kernel csharp], et [Python][kernel python].

<div markdown="1" class="callout" id="optech">

## Résumé 2025 : Bitcoin Optech

Pour la huitième année d'Optech, nous avons publié 50 [bulletins] hebdomadaires et ce spécial
Revue de l'Année. Au total, Optech a publié plus de 80 000 mots en anglais sur la recherche et le
développement logiciel Bitcoin cette année, l'équivalent approximatif d'un livre de 225 pages.

Chaque bulletin et article de blog a été traduit en chinois, en français et en japonais, avec
d'autres langues également traduites, pour un total de plus de 150 traductions en 2025.

De plus, chaque bulletin de cette année a été accompagnée d'un épisode de [podcast], totalisant
plus de 60 heures sous forme audio et plus de 500 000 mots sous forme de transcript. De nombreux
contributeurs de premier plan de Bitcoin ont été invités à l'émission, certains à plus d'un épisode,
avec un total de 75 invités uniques en 2025 :

- 0xB10C
- Abubakar Sadiq Ismail (x3)
- Alejandro De La Torre
- Alex Myers
- Andrew Toth
- Anthony Towns
- Antoine Poinsot (x5)
- Bastien Teinturier (x3)
- Bob McElrath
- Bram Cohen
- Brandon Black
- Bruno Garcia
- Bryan Bishop
- Carla Kirk-Cohen (x2)
- Chris Stewart
- Christian Kümmerle
- Clara Shikhelman
- Constantine Doumanidis
- Dan Gould
- Daniela Brozzoni (x2)
- Daniel Roberts
- Davidson Souza
- David Gumberg
- Elias Rohrer
- Eugene Siegel (x2)
- Francesco Madonna
- Gloria Zhao (x2)
- Gregory Sanders (x2)
- Hunter Beast
- Jameson Lopp (x2)
- Jan B
- Jeremy Rubin (x2)
- Jesse Posner
- Johan Halseth
- Jonas Nick (x4)
- Joost Jager (x2)
- Jose SK
- Josh Doman (x2)
- Julian
- Lauren Shareshian
- Liam Eagen
- Marco De Leon
- Matt Corallo
- Matt Morehouse (x7)
- Moonsettler
- Naiyoma
- Niklas Gögge
- Olaoluwa Osuntokun
- Oleksandr Kurbatov
- Peter Todd
- Pieter Wuille
- PortlandHODL
- Rene Pickhardt
- Robin Linus (x3)
- Rodolfo Novak
- Ruben Somsen (x2)
- Russell O’Connor
- Salvatore Ingala (x4)
- Sanket Kanjalkar
- Sebastian Falbesoner (x2)
- Sergi Delgado
- Sindura Saraswathi (x2)
- Sjors Provoost (x2)
- Steve Myers
- Steven Roose (x3)
- Stéphan Vuylsteke (x2)
- supertestnet
- Tadge Dryja (x3)
- TheCharlatan (x2)
- Tim Ruffing
- vnprc
- Vojtěch Strnad
- Yong Yu
- Yuval Kogman
- ZmnSCPxj (x3)

Optech a eu la chance et la gratitude de recevoir une autre contribution de 20 000 USD de la part de
la [Human Rights Foundation][]. Les fonds seront utilisés pour payer l'hébergement web, les services
de messagerie, les transcriptions de podcasts et d'autres dépenses qui nous permettent de continuer
et d'améliorer notre livraison de contenu technique à la communauté Bitcoin.

### Un remerciement spécial

Après avoir contribué en tant qu'auteur principal pour 376 bulletins Bitcoin Optech consécutifs,
Dave Harding a pris du recul par rapport à ses contributions régulières cette année. Nous ne pouvons
pas assez remercier Harding pour avoir ancré le bulletin pendant huit ans et pour toute l'éducation,
l'élucidation et la compréhension de Bitcoin qu'il a apportées à la communauté. Nous lui sommes
éternellement reconnaissants et lui souhaitons tout le meilleur.

</div>

## Décembre

- **Splicing :** En décembre, [LDK 0.2][] a été publié avec un support expérimental du
  [splicing][topic splicing], rendant la fonctionnalité disponible sur trois principales
  implémentations de Lightning : LDK, Eclair et Core Lightning. Le splicing permet aux nœuds d'ajouter
  ou de retirer des fonds d'un canal sans le fermer.

  Cela a conclu une année de progrès significatifs vers la fonctionnalité de splicing de LN. Eclair a
  ajouté [le support du splicing sur les canaux publics][news340 eclairsplice] en février et [le
  splicing dans les canaux taproot simples][news368 eclairtaproot] en août. Pendant ce temps, Core
  Lightning a [finalisé][news355 clnsplice] l'interopérabilité avec Eclair en mai et l'a expédié dans
  [Core Lightning 25.05][news359 cln2505].

  Tout au long de l'année, toutes les pièces nécessaires pour l'implémentation de LDK ont été
  ajouté, incluant le [support de l'épissure][news369 ldksplice] en août, [intégrant][news370
  ldkquiesce] l'épissure avec le protocole de quiescence en septembre, et expédiant de nombreux
  raffinements supplémentaires avant la sortie de la version 0.2.

  Les équipes de mise en œuvre ont également coordonné sur les détails de la spécification, tels que
  l'augmentation du délai avant de marquer un canal comme fermé pour permettre la propagation de
  l'épissure (augmenté de 12 à [72 blocs][news359 eclairdelay] par [BOLTs #1270][]) et la [logique de
  reconnexion][news381 clnreconnect] pour l'état de l'épissure synchronisé par [BOLTs #1289][].

  Cependant, la principale [spécification de l'épissure][bolts #1160] reste non fusionnée à la fin de
  l'année, avec des mises à jour toujours attendues et des problèmes de compatibilité croisée
  continuant à être résolus.

*Nous remercions tous les contributeurs Bitcoin mentionnés ci-dessus, ainsi que les nombreux autres
dont le travail était tout aussi important, pour une autre année incroyable de développement
Bitcoin. La bulletin Optech reprendra sa publication régulière le vendredi à partir du 2 janvier.*

<style>
#optech ul {
  max-width: 800px;
  display: flex;
  flex-wrap: wrap;
  list-style: none;
  padding: 0;
  margin: 0;
  justify-content: center;
}

#optech li {
  flex: 1 0 220px;
  max-width: 220px;
  box-sizing: border-box;
  padding: 5px;
  margin: 5px;
}

@media (max-width: 720px) {
  #optech li {
    flex-basis: calc(50% - 10px);
  }
}

@media (max-width: 360px) {
  #optech li {
    flex-basis: calc(100% - 10px);
  }
}
</style>

{% include snippets/recap-ad.md when="2025-12-23 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1699,1895,1974,2004,27587,33629,1937,32406" %}
[index des sujets]: /en/topics/
[yirs 2018]: /en/newsletters/2018/12/28/
[yirs 2019]: /fr/newsletters/2019/12/28/
[yirs 2020]: /fr/newsletters/2020/12/23/
[yirs 2021]: /fr/newsletters/2021/12/22/
[yirs 2022]: /fr/newsletters/2022/12/21/
[yirs 2023]: /fr/newsletters/2023/12/20/
[yirs 2024]: /fr/newsletters/2024/12/20/

[bulletins]: /fr/newsletters/
[Human Rights Foundation]: https://hrf.org
[openssl vs libsecp256k1]: /en/newsletters/2025/11/07/#comparing-performance-of-ecdsa-signature-validation-in-openssl-vs-libsecp256k1
[channel jamming results]: /en/newsletters/2025/10/24/#channel-jamming-mitigation-simulation-results-and-updates
[channel jamming resource]: https://delvingbitcoin.org/t/hybrid-jamming-mitigation-results-and-updates/1147#p-3212-resource-attacks-3
[channel jamming sink]: https://delvingbitcoin.org/t/hybrid-jamming-mitigation-results-and-updates/1147#p-3212-manipulation-sink-attack-9
[channel jamming attack]: /en/topics/channel-jamming-attacks/
[erlay optech posts]: /en/newsletters/2025/02/07/#erlay-update
[erlay]: /en/topics/erlay/
[erlay knowledge]: https://delvingbitcoin.org/t/erlay-filter-fanout-candidates-based-on-transaction-knowledge/1416
[erlay fanout amount]: https://delvingbitcoin.org/t/erlay-find-acceptable-target-number-of-peers-to-fanout-to/1420
[erlay transaction received]: https://delvingbitcoin.org/t/erlay-define-fanout-rate-based-on-the-transaction-reception-method/1422
[erlay candidate peers]: https://delvingbitcoin.org/t/erlay-select-fanout-candidates-at-relay-time-instead-of-at-relay-scheduling-time/1418
[news358 selfish miner]: /en/newsletters/2025/06/13/#calculating-the-selfish-mining-danger-threshold
[selfish miner paper]: https://arxiv.org/pdf/1311.0243
[news360 fingerprinting]: /en/newsletters/2025/06/27/#fingerprinting-nodes-using-addr-messages
[news359 bitvm3]: /en/newsletters/2025/06/20/#improvements-to-bitvm-style-contracts
[delbrag rubin]: https://rubin.io/bitcoin/2025/04/04/delbrag/
[garbled circuits wiki]: https://en.wikipedia.org/wiki/Garbled_circuit
[news369 eagen]: /en/newsletters/2025/08/29/#garbled-locks-for-accountable-computing-contracts
[eagen paper]: https://eprint.iacr.org/2025/1485
[news351 dahlias]: /en/newsletters/2025/04/25/#interactive-aggregate-signatures-compatible-with-secp256k1
[dahlias paper]: https://eprint.iacr.org/2025/692.pdf
[news344 fork guide]: /en/newsletters/2025/03/07/#bitcoin-forking-guide
[fork guide red]: https://ajtowns.github.io/bfg/research.html
[fork guide pue]: https://ajtowns.github.io/bfg/power.html
[fork guide ie]: https://ajtowns.github.io/bfg/industry.html
[fork guide ir]: https://ajtowns.github.io/bfg/investor.html
[news344 template mrkt]: /en/newsletters/2025/03/07/#private-block-template-marketplace-to-prevent-centralizing-mev
[mevpool gh]: https://github.com/mevpool/mevpool/blob/0550f5d85e4023ff8ac7da5193973355b855bcc8/mevpool-marketplace.md
[news 347 ln fees]: /en/newsletters/2025/03/28/#ln-upfront-and-hold-fees-using-burnable-outputs
[ln fees paper]: https://github.com/JohnLaw2/ln-spam-prevention
[news349 swiftsync]: /en/newsletters/2025/04/11/#swiftsync-speedup-for-initial-block-download
[swiftsync ruben gh]: https://gist.github.com/RubenSomsen/a61a37d14182ccd78760e477c78133cd
[swiftsync rust impl]: https://delvingbitcoin.org/t/swiftsync-speeding-up-ibd-with-pre-generated-hints-poc/1562/18
[news288 lib]: /en/newsletters/2024/02/07/#bitcoin-core-29189
[kernel rust]: https://github.com/sedited/rust-bitcoinkernel
[kernel go]: https://github.com/stringintech/go-bitcoinkernel
[kernel jdk]: https://github.com/yuvicc/bitcoinkernel-jdk
[kernel csharp]: https://github.com/janb84/BitcoinKernel.NET
[kernel python]: https://github.com/stickies-v/py-bitcoinkernel
[gcc update]: /en/newsletters/2025/02/07/#updates-to-cleanup-soft-fork-proposal
[gcc bip]: /en/newsletters/2025/04/04/#draft-bip-published-for-consensus-cleanup
[news thikcs]: /en/newsletters/2025/08/01/#taproot-native-op-templatehash-proposal
[ctv csfs symmetry]: /en/newsletters/2025/04/04/#ln-symmetry
[ctv csfs arks]: /en/newsletters/2025/04/04/#ark
[ctv vaults]: /en/newsletters/2025/04/04/#vaults
[ctv dlcs]: /en/newsletters/2025/04/04/#dlcs
[lnhance update]: /en/newsletters/2025/12/05/#lnhance-soft-fork
[rubin key ladder]: https://rubin.io/bitcoin/2024/12/02/csfs-ctv-rekey-symmetry/
[ctv csfs ptlcs]: /en/newsletters/2025/07/04/#ctv-csfs-advantages-for-ptlcs
[ctv csfs bitvm]: /en/newsletters/2025/05/16/#description-of-benefits-to-bitvm-from-op-ctv-and-op-csfs
[ctv csfs letter]: /en/newsletters/2025/07/04/#open-letter-about-ctv-and-csfs
[gcc impl tests]: /en/newsletters/2025/11/07/#bip54-implementation-and-test-vectors
[ccv bip]: /en/newsletters/2025/05/30/#bips-1793
[ccv semantics]: /en/newsletters/2025/04/04/#op-checkcontractverify-semantics
[vault withdrawn]: /en/newsletters/2025/05/16/#bips-1848
[64bit bip]: /en/newsletters/2025/05/16/#proposed-bip-for-64-bit-arithmetic-in-script
[txhash sponsors]: /en/newsletters/2025/07/04/#op-txhash-variant-with-support-for-transaction-sponsorship
[txhash]: /en/newsletters/2022/02/02/#composable-alternatives-to-ctv-and-apo
[tweakadd]: /en/newsletters/2025/09/05/#draft-bip-for-adding-elliptic-curve-operations-to-tapscript
[ecmath]: /en/newsletters/2025/09/05/#draft-bip-for-adding-elliptic-curve-operations-to-tapscript
[gsr bips]: /en/newsletters/2025/10/03/#draft-bips-for-script-restoration
[transitory cleanups]: /en/newsletters/2025/01/03/#transitory-soft-forks-for-cleanup-soft-forks
[simplicity 370]: /en/newsletters/2025/09/05/#details-about-the-design-of-simplicity
[simplicity I post]: https://delvingbitcoin.org/t/delving-simplicity-part-three-fundamental-ways-of-combining-computations/1902
[simplicity II post]: https://delvingbitcoin.org/t/delving-simplicity-part-combinator-completeness-of-simplicity/1935
[simplicity III post]: https://delvingbitcoin.org/t/delving-simplicity-part-building-data-types/1956
[simplicity IV post]: https://delvingbitcoin.org/t/delving-simplicity-part-two-side-effects/2091
[simplicity V post]: https://delvingbitcoin.org/t/delving-simplicity-part-programs-and-addresses/2113
[news339 sv2fields]: /en/newsletters/2025/01/31/#bitcoin-core-31583
[news346 waitnext]: /en/newsletters/2025/03/21/#bitcoin-core-31283
[news360 checkblock]: /en/newsletters/2025/06/27/#bitcoin-core-31981
[news359 starkware]: /en/newsletters/2025/06/20/#stratum-v2-stark-proof-demo
[news369 ipc]: /en/newsletters/2025/08/29/#bitcoin-core-31802
[news374 ipcauto]: /en/newsletters/2025/10/03/#bitcoin-core-33229
[news376 30]: /en/newsletters/2025/10/17/#bitcoin-core-30-0
[news377 ipclog]: /en/newsletters/2025/10/24/#bitcoin-core-33517
[news381 witness]: /en/newsletters/2025/11/21/#bitcoin-core-33745
[news346 hashpool]: /en/newsletters/2025/03/21/#hashpool-v0-1-tagged
[news323 miningipc]: /en/newsletters/2024/10/04/#bitcoin-core-30510
[news340 richter ggt]: /en/newsletters/2025/02/07/#discovery-of-previous-research-for-finding-optimal-cluster-linearization
[news341 pr-review-club txgraph]: /en/newsletters/2025/02/14/#bitcoin-core-pr-review-club
[news352 wuille linearization techniques]: /en/newsletters/2025/05/02/#comparison-of-cluster-linearization-techniques
[news377 ismail template improvement]: /en/newsletters/2025/10/24/#detecting-block-template-feerate-increases-using-cluster-mempool
[news382 cluster mempool completed]: /en/newsletters/2025/11/28/#bitcoin-core-33629
[news bip360 update]: /en/newsletters/2025/03/07/#update-on-bip360-pay-to-quantum-resistant-hash-p2qrh
[news qr sha]: /en/newsletters/2025/04/04/#securely-proving-utxo-ownership-by-revealing-a-sha256-preimage
[news qr cr]: /en/newsletters/2025/07/04/#commit-reveal-function-for-post-quantum-recovery
[news qr lopp1]: /en/newsletters/2025/04/04/#should-vulnerable-bitcoins-be-destroyed
[news qr lopp2]: /en/newsletters/2025/08/01/#migration-from-quantum-vulnerable-outputs
[news qr cruz]: /en/newsletters/2025/04/04/#draft-bip-for-destroying-quantum-insecure-bitcoins
[news qr corallo]: /en/newsletters/2025/01/03/#quantum-computer-upgrade-path
[rubin lamport]: https://gnusha.org/pi/bitcoindev/CAD5xwhgzR8e5r1e4H-5EH2mSsE1V39dd06+TgYniFnXFSBqLxw@mail.gmail.com/
[lamport]: https://en.wikipedia.org/wiki/Lamport_signature
[conduition sphincs]: /en/newsletters/2025/12/05/#slh-dsa-sphincs-post-quantum-signature-optimizations
[abdel stark]: /en/newsletters/2025/11/07/#native-stark-proof-verification-in-bitcoin-script
[news364 quantum primatives]: /en/newsletters/2025/07/25/#research-indicates-common-bitcoin-primitives-are-compatible-with-quantum-resistant-signature-algorithms
[news365 quantum taproot]: /en/newsletters/2025/08/01/#security-against-quantum-computers-with-taproot-as-a-commitment-scheme
[news357 quantum report]: /en/newsletters/2025/06/06/#quantum-computing-report
[news qr agg]: /en/newsletters/2025/11/07/#post-quantum-signature-aggregation
[nick paper tweet]: https://x.com/n1ckler/status/1998407064213704724
[hash-based signature schemes]: https://eprint.iacr.org/2025/2203.pdf
[news335 chilldkg]: /en/newsletters/2025/01/03/#updated-chilldkg-draft
[news offchain dlc]: /en/newsletters/2025/01/24/#correction-about-offchain-dlcs
[news dlc channels]: /en/newsletters/2023/07/19/#wallet-10101-beta-testing-pooling-funds-between-ln-and-dlcs
[Cedarctic post]: /en/newsletters/2025/09/19/#partitioning-and-eclipse-attacks-using-bgp-interception
[eclipse attack]: /en/topics/eclipse-attacks/
[Antoine post]: /en/newsletters/2025/11/21/#modeling-stale-rates-by-propagation-delay-and-mining-centralization
[news340 lowering feerates]: /en/newsletters/2025/02/07/#discussion-about-lowering-the-minimum-transaction-relay-feerate
[mononautical 85]: https://x.com/mononautical/status/1949452588992414140
[mononautical 32]: https://x.com/mononautical/status/1958559008698085551
[news366 lower feerate]: /en/newsletters/2025/08/08/#continued-discussion-about-lowering-the-minimum-relay-feerate
[news315 compact blocks]: /en/newsletters/2024/08/09/#statistics-on-compact-block-reconstruction
[news339 compact blocks]: /en/newsletters/2025/01/31/#updated-stats-on-compact-block-reconstruction
[news365 compact blocks]: /en/newsletters/2025/08/01/#testing-compact-block-prefilling
[news382 compact blocks]: /en/newsletters/2025/11/28/#stats-on-compact-block-reconstructions-updates
[news368 monitoring]: /en/newsletters/2025/08/22/#peer-observer-tooling-and-call-to-action
[28.0 wallet guide]: /en/bitcoin-core-28-wallet-integration-guide/
[news340 lneas]: /en/newsletters/2025/02/07/#tradeoffs-in-ln-ephemeral-anchor-scripts
[news341 lneas]: /en/newsletters/2025/02/14/#continued-discussion-about-ephemeral-anchor-scripts-for-ln
[news380 kernel]: /en/newsletters/2025/11/14/#bitcoin-core-30595
[news357 wrapper]: /en/newsletters/2025/06/06/#bitcoin-core-31375
[news346 dmnd]: /en/newsletters/2025/03/21/#dmnd-launching-pooled-mining
[news341 bip3 assigned]: /en/newsletters/2025/02/14/#updated-proposal-for-updated-bip-process
[news382 motion to activate bip3]: /en/newsletters/2025/11/28/#motion-to-activate-bip3
[bip3 feedback addressed]: https://groups.google.com/g/bitcoindev/c/j4_toD-ofEc/m/8HTeL2_iAQAJ
[delving random]: https://delvingbitcoin.org/t/emulating-op-rand/1409
[random poc]: https://github.com/distributed-lab/op_rand
[waxwing random]: /en/newsletters/2025/02/14/#suggested
[ok random]: /en/newsletters/2025/02/07/#emulating-op-rand
[rl random]: /en/newsletters/2025/03/14/#probabilistic-payments-using-different-hash-functions-as-an-xor-function
[dh random]: /en/newsletters/2025/02/14/#asked
[jt delegation]: /en/newsletters/2025/07/25/#chain-code-withholding-for-multisig-scripts
[news335 coinjoin]: /en/newsletters/2025/01/03/#deanonymization-attacks-against-centralized-coinjoin
[news333 coinjoin]: /en/newsletters/2024/12/13/#deanonymization-vulnerability-affecting-wasabi-and-related-software
[news340 htlcbug]: /en/newsletters/2025/02/07/#channel-force-closure-vulnerability-in-ldk
[news340 htlcfix]: /en/newsletters/2025/02/07/#ldk-3556
[news339 ldk]: /en/newsletters/2025/01/31/#vulnerability-in-ldk-claim-processing
[news339 cycling]: /en/newsletters/2025/01/31/#replacement-cycling-attacks-with-miner-exploitation
[news346 bolts]: /en/newsletters/2025/03/21/#bolts-1233
[news344 lnd]: /en/newsletters/2025/03/07/#disclosure-of-fixed-lnd-vulnerability-allowing-theft
[news346 checkpoints]: /en/newsletters/2025/03/21/#bitcoin-core-31649
[news353 bip30]: /en/newsletters/2025/05/09/#bip30-consensus-failure-vulnerability
[news354 32bit]: /en/newsletters/2025/05/16/#vulnerability-disclosure-affecting-old-versions-of-bitcoin-core
[news364 lnd]: /en/newsletters/2025/07/25/#lnd-gossip-filter-dos-vulnerability
[news319 lnd]: /en/newsletters/2024/09/06/#lnd-9009
[news159 32bit]: /en/newsletters/2021/07/28/#bitcoin-core-22387
[news314 32bit]: /en/newsletters/2024/08/02/#remote-crash-by-sending-excessive-addr-messages
[news373 eclair]: /en/newsletters/2025/09/26/#eclair-vulnerability
[news378 four]: /en/newsletters/2025/10/31/#disclosure-of-four-low-severity-vulnerabilities-in-bitcoin-core
[news361 four]: /en/newsletters/2025/07/04/#bitcoin-core-32819
[news363 four]: /en/newsletters/2025/07/18/#bitcoin-core-32604
[news367 four]: /en/newsletters/2025/08/15/#bitcoin-core-33050
[news383 nbitcoin]: /en/newsletters/2025/12/05/#consensus-bug-in-nbitcoin-library
[news384 lnd]: /en/newsletters/2025/12/12/#critical-vulnerabilities-fixed-in-lnd-0-19-0
[bdk wallet-1.0.0]: /en/newsletters/2025/01/03/#bdk-wallet-1-0-0
[ldk v0.1]: /en/newsletters/2025/01/17/#ldk-v0-1
[core lightning 25.02]: /en/newsletters/2025/03/07/#core-lightning-25-02
[eclair v0.12.0]: /en/newsletters/2025/03/14/#eclair-v0-12-0
[btcpay server 2.1.0]: /en/newsletters/2025/04/11/#btcpay-server-2-1-0
[bitcoin core 29.0]: /en/newsletters/2025/04/18/#bitcoin-core-29-0
[lnd 0.19.0-beta]: /en/newsletters/2025/05/23/#lnd-0-19-0-beta
[core lightning 25.05]: /en/newsletters/2025/06/20/#core-lightning-25-05
[btcpay server 2.2.0]: /en/newsletters/2025/08/08/#btcpay-server-2-2-0
[core lightning v25.09]: /en/newsletters/2025/09/05/#core-lightning-v25-09
[eclair v0.13.0]: /en/newsletters/2025/09/12/#eclair-v0-13-0
[bitcoin inquisition 29.1]: /en/newsletters/2025/10/10/#bitcoin-inquisition-29-1
[bitcoin core 30.0]: /en/newsletters/2025/10/17/#bitcoin-core-30-0
[core lightning v25.12]: /en/newsletters/2025/12/05/#core-lightning-v25-12
[ldk 0.2]: /en/newsletters/2025/12/05/#ldk-0-2
[news340 eclairsplice]: /en/newsletters/2025/02/07/#eclair-2968
[news368 eclairtaproot]: /en/newsletters/2025/08/22/#eclair-3103
[news355 clnsplice]: /en/newsletters/2025/05/23/#core-lightning-8021
[news359 cln2505]: /en/newsletters/2025/06/20/#core-lightning-25-05
[news369 ldksplice]: /en/newsletters/2025/08/29/#ldk-3979
[news370 ldkquiesce]: /en/newsletters/2025/09/05/#ldk-4019
[news359 eclairdelay]: /en/newsletters/2025/06/20/#eclair-3110
[news381 clnreconnect]: /en/newsletters/2025/11/21/#core-lightning-8646
[bolts #1270]: https://github.com/lightning/bolts/pull/1270
[bolts #1289]: https://github.com/lightning/bolts/pull/1289
[bolts #1160]: https://github.com/lightning/bolts/pull/1160
[news366 utreexo]: /en/newsletters/2025/08/08/#draft-bips-proposed-for-utreexo
[bip181 utreexo]: https://github.com/utreexo/biptreexo/blob/main/bip-0181.md
[bip182 utreexo]: https://github.com/utreexo/biptreexo/blob/main/bip-0182.md
[bip183 utreexo]: https://github.com/utreexo/biptreexo/blob/main/bip-0183.md
[news366 templ share]: /en/newsletters/2025/08/08/#peer-block-template-sharing-to-mitigate-problems-with-divergent-mempool-policies
[news368 templ share]: /en/newsletters/2025/08/22/#draft-bip-for-block-template-sharing
[news376 templ share]: /en/newsletters/2025/10/17/#continued-discussion-of-block-template-sharing
[binana repo]: https://github.com/bitcoin-inquisition/binana
[bin]: https://github.com/bitcoin-inquisition/binana/blob/master/2025/BIN-2025-0002.md
[news369 fuzz]: /en/newsletters/2025/08/29/#update-on-differential-fuzzing-of-bitcoin-and-ln-implementations
[bitcoinfuzz]: https://github.com/bitcoinfuzz/bitcoinfuzz
[news375 arb data]: /en/newsletters/2025/10/10/#theoretical-limitations-on-embedding-data-in-the-utxo-set
[news379 arb data]: /en/newsletters/2025/11/07/#multiple-discussions-about-restricting-data
[news 338]: /en/newsletters/2025/01/24/#bitcoin-core-31397
[news352 OR debate]: /en/newsletters/2025/05/02/#increasing-or-removing-bitcoin-core-s-op-return-size-limit
[0xb10c delving]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/35