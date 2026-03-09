---
title: 'Bulletin Hebdomadaire Bitcoin Optech #395'
permalink: /fr/newsletters/2026/03/06/
name: 2026-03-06-newsletter-fr
slug: 2026-03-06-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
La newsletter de cette semaine décrit une norme pour la vérification des VTXOs à travers différentes implémentations d'Ark et renvoie à un projet de BIP pour l'expansion de l'espace nonce utilisable par les mineurs dans le champ `nVersion` de l'en-tête de bloc.
Sont également incluses nos sections régulières résumant les récentes discussions sur
la modification des règles de consensus de Bitcoin, annonçant des mises à jour et des versions candidates,
et décrivant les changements notables dans les projets d'infrastructure Bitcoin populaires.


## Nouvelles

- **Une norme pour la vérification VTXO sans état** : Jgmcalpine a [posté][vpack del] sur Delving Bitcoin à propos de sa proposition pour V-PACK,
  une norme de vérification [VTXO][topic ark] sans état, qui vise à fournir un mécanisme pour vérifier et visualiser de manière indépendante les VTXOs
  dans l'écosystème Ark. L'objectif est de développer un vérificateur léger capable de fonctionner sur des environnements embarqués,
  tels que les portefeuilles matériels, pour permettre l'audit de l'état hors chaîne et maintenir une sauvegarde indépendante des données requises
  pour une sortie unilatérale.

  En particulier, V-PACK vérifie qu'un chemin de sortie unilatérale existe, en vérifiant que le chemin merkle mène à une ancre valide sur la chaîne
  et que les préimages de transaction correspondent aux signatures. Cependant, le PDG de Second, Steven Roose, a souligné que l'exclusivité
  du chemin (c'est-à-dire la vérification que le fournisseur de service Ark (ASP) n'a pas introduit de porte dérobée) n'est pas vérifiée,
  à quoi Jgmcalpine a répondu que le sujet serait donné à la plus haute priorité dans la feuille de route.

  En raison de différences significatives entre les implémentations d'Ark (spécifiquement, Arkade et Bark), V-PACK propose
  un schéma Minimal Viable VTXO (MVV) pour permettre la traduction du "dialecte" d'une implémentation vers un format neutre commun,
  sans que l'environnement embarqué ait besoin d'importer toute la base de code spécifique de l'implémentation.

  L'implémentation de V-PACK, [libvpack-rs][vpack gh], est open-source, et un [outil en direct][vpack tool] pour visualiser les VTXOs est disponible pour les tests.

- **Projet de BIP pour l'expansion de l'espace nonce `nVersion` pour les mineurs** : Matt Corallo a [posté][mailing list nversion] sur la liste de diffusion
  Bitcoin-Dev un projet de BIP pour augmenter le nombre de bits disponibles dans l'espace nonce de `nVersion` pour les mineurs de 16 à 24.
  Cela permettrait plus de candidats de bloc possibles pour le minage uniquement d'en-tête sans avoir à recourir à la rotation de `nTime`
  plus souvent qu'une fois par seconde et remplacerait [BIP320][BIP 320].

  La motivation pour ce changement est que le BIP320 avait précédemment défini 16 bits de `nVersion` comme espace nonce supplémentaire,
  mais il s'avère que les dispositifs de minage ont commencé à utiliser 7 bits de `nTime` pour un espace nonce supplémentaire.
  Étant donné l'utilité limitée des bits supplémentaires de `nVersion` pour l'utilisation dans la signalisation de soft fork, ce projet de BIP
  suggère d'utiliser certains de ces bits de signalisation pour étendre l'espace nonce supplémentaire de `nVersion`.

  La raison derrière cela est que fournir un espace nonce supplémentaire pour que les ASICs puissent rouler sans avoir besoin
  de travail frais du contrôleur peut simplifier la conception des ASIC et il est préférable de le faire dans `nVersion` au lieu de `nTime`, qui
  peut fausser les horodatages des blocs.

## Modification du consensus

_Une nouvelle section mensuelle résumant les propositions et discussions sur la modification des
règles de consensus de Bitcoin._

- **Extensions aux outils standards pour le support de TEMPLATEHASH-CSFS-IK :**
  Antoine Poinsot a [écrit][ap ml thikcs] sur la liste de diffusion Bitcoin-Dev à propos de son travail préliminaire pour intégrer
  la proposition de soft fork [taproot-native `OP_TEMPLATEHASH`][news365 thikcs] dans [miniscript][topic miniscript] et [PSBTs][topic psbt].

  Les nouveaux opcodes nécessitent une réévaluation des propriétés de miniscript car ils remettent en question l'hypothèse selon laquelle
  les signatures et les engagements de transaction sont toujours réalisés ensemble. Ce travail souligne également les limitations
  de la structure de pile de Script en nécessitant un `OP_SWAP` avant chaque `OP_CHECKSIGFROMSTACK` lorsqu'il est utilisé avec miniscript
  sans autres modifications du système de typage. Étant donné que `OP_CHECKSIGFROMSTACK` prend 3 arguments, avec soit le message, soit la clé,
  ou les deux calculés par d'autres fragments de script, il n'y a pas d'ordre d'arguments clairement supérieur qui évite `OP_SWAP` dans la plupart des cas.

  Les modifications requises pour les PSBTs sont plus simples, principalement un champ par sortie pour mapper les engagements `OP_TEMPLATEHASH`
  à leurs transactions complètes pour vérification par les signataires.

- **Mise à jour Hourglass V2 :** Mike Casey a [posté][mk ml hourglass] une mise à jour sur la liste de diffusion Bitcoin-Dev
  pour le [protocole Hourglass][bip draft hourglass2] afin de mitiger l'impact sur le marché des attaques [quantiques][topic quantum resistance]
  contre certaines pièces perdues. La proposition initiale a été discutée [ici][hb ml hourglass]. Ce soft fork limiterait la valeur totale
  de Bitcoin verrouillé par P2PK qui peut être dépensé dans un seul bloc à 1 sortie dépensée et 1 Bitcoin. Ces valeurs spécifiques
  sont quelque peu arbitraires, mais semblaient pour ceux qui ont répondu représenter un point de Schelling raisonnable pour une telle restriction.
  Ceux qui ont répondu en faveur du changement se sont concentrés sur les conséquences économiques potentielles d'un grand nombre de Bitcoin
  vendus par un adversaire quantique. Ceux qui ont répondu contre ont argumenté que la possession de clés secrètes pour déverrouiller
  certains Bitcoin est la seule manière dont le protocole peut identifier la propriété et que même face à une rupture dans la sécurité cryptographique
  sous-jacente, le protocole ne devrait pas appliquer de restrictions supplémentaires sur la propriété ou le mouvement des pièces.

- **Agilité algorithmique pour Bitcoin :** Ethan Heilman a [écrit][eh ml agility] sur la liste de diffusion Bitcoin-Dev concernant
  le besoin potentiel d'[RFC7696 Cryptographic Algorithm Agility][rfc7696] dans Bitcoin. Heilman propose qu'un algorithme cryptographique
  soit disponible dans les scripts [BIP360][] P2MR qui n'est pas destiné à être dépensé actuellement, mais sert plutôt de solution de secours
  pour faire le pont entre les algorithmes de signature principaux dans l'événement où l'algorithme de signature actuel basé sur secp256k1
  (ou un futur algorithme principal) deviendrait non sécurisé. L'idée centrale est que si Bitcoin prend en charge deux algorithmes
  de signature simultanément, les futures ruptures de l'un ou de l'autre ne doivent pas être aussi critiques que les discussions actuelles
  autour d'une potentielle rupture quantique de secp256k1.

  D'autres développeurs ont répondu avec des discussions sur divers algorithmes de signature de secours potentiels qui seraient peu susceptibles
  de se briser dans l'horizon temporel de 75 ans d'Heilman.

  La question de savoir si BIP360 P2MR, ou quelque chose qui semble plus être un [P2TR][topic taproot] mais opte pour que le keyspend
  soit désactivé plus tard par un soft fork, ce qui est préférable. Dans P2MR, toutes les dépenses sont des dépenses de script avec
  soit un mécanisme de signature primaire à coût inférieur, soit un mécanisme de secours à coût supérieur choisi parmi les feuilles de merkle.
  Dans une variante P2TR, le type de signature primaire est un key spend à coût inférieur jusqu'à ce qu'il soit désactivé en raison d'une faille
  cryptographique et seul le mécanisme de secours doit être une feuille de merkle. Heilman a suggéré que les utilisateurs de stockage à froid
  préféreraient P2MR et que les portefeuilles chauds pourraient facilement passer à un nouveau type de sortie si nécessaire, rendant l'algorithme
  de signature de secours avec script inutile pour les deux principaux types d'utilisateurs.

- **Les limitations de l'agilité cryptographique dans Bitcoin :**
  Pieter Wuille a écrit à la liste de diffusion Bitcoin-Dev sur les limitations de l'agilité cryptographique mentionnée dans l'élément précédent.
  Spécifiquement, parce que Bitcoin, comme tout argent, est basé sur la croyance, si la propriété de Bitcoin est sécurisée par plusieurs systèmes
  cryptographiques, les partisans de chaque schéma veulent que leur schéma soit utilisé universellement et, important, ne veulent pas que d'autres
  schémas soient utilisés car ils affaibliraient l'invariant fondamental de la sécurité de la propriété. Wuille suppose qu'avec le temps,
  les anciens schémas de signature devront être désactivés dans le cadre de la migration d'un schéma à un autre.

  Heilman propose que, parce que le schéma de signature secondaire proposé pour l'agilité algorithmique est beaucoup plus coûteux que le schéma actuel
  (et, espérons-le, un futur schéma primaire), il resterait une sauvegarde et seulement utilisé pour les migrations lorsque le schéma primaire
  a été démontré comme étant suffisamment affaibli, évitant ainsi la nécessité de désactiver le schéma secondaire après chaque migration
  vers un nouveau schéma primaire.

  John Light prend le point de vue opposé à celui de Wuille, affirmant que désactiver les anciens schémas de signature, même non sécurisés,
  est une menace plus grande pour la croyance partagée dans le modèle de propriété de Bitcoin que les pièces encore sécurisées par
  de tels schémas non sécurisés étant revendiquées par celui qui les brise. Affirmant essentiellement que l'aspect le plus important du modèle
  de propriété de Bitcoin est l'indélébilité de la validité de chaque script de verrouillage du moment où il est créé jusqu'à ce qu'il soit dépensé.

  Conduition réfute les préconditions de Wuille en démontrant que (grâce à la flexibilité de Script) les utilisateurs peuvent exiger
  des signatures de plusieurs schémas de signature pour débloquer leurs pièces. Cela permet aux utilisateurs d'exprimer un ensemble plus large
  d'hypothèses de sécurité que celles qui ont donné lieu à la conclusion de Wuille selon laquelle les schémas non sécurisés devraient être désactivés
  et que les utilisateurs de chaque schéma voudraient presque que personne n'utilise les autres.

  La discussion se poursuit avec quelques clarifications mais sans conclusions fermes quant à la manière dont Bitcoin peut pratiquement migrer
  d'un cryptosystème à un autre, que ce soit en réponse à un adversaire quantique ou pour toute autre raison.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates._

- [Bitcoin Core 28.4rc1][] est un candidat à la sortie pour une version de maintenance d'une série de versions majeures précédentes.
  Il contient principalement des corrections de migration de portefeuille et la suppression d'un DNS seed peu fiable.

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],[LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo],
[Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #33616][] ignore la vérification de dépense de [poussière éphémère][topic ephemeral anchors] (`CheckEphemeralSpends`)
  pendant les réorganisations de blocs lorsque les transactions confirmées réintègrent le pool de mémoire. Auparavant, ces transactions
  étaient rejetées par la politique de relais car elles sont ramenées individuellement plutôt qu'en tant que paquet. Cela suit
  le même modèle que [Bitcoin Core #33504][] (voir le [Bulletin #375][news375 truc]), qui ignorait les vérifications de topologie
  [TRUC][topic v3 transaction relay] pendant les réorganisations pour la même raison.

- [Bitcoin Core #34616][] introduit un modèle de coût plus précis pour l'algorithme de [linéarisation en forêt couvrante][topic cluster mempool] (SFL),
  en utilisant des limites de coût pour limiter la quantité de temps CPU dépensé à chercher une linéarisation optimale de chaque cluster.
  Le modèle précédent ne suivait qu'un type d'opération interne, résultant en une faible corrélation entre le coût rapporté et le temps CPU réellement dépensé.
  Le nouveau modèle suit de nombreuses opérations internes avec des poids calibrés à partir de benchmarks sur divers matériels,
  fournissant une approximation bien plus proche du temps réel.

- [Eclair #3256][] ajoute un nouvel événement `ChannelFundingCreated` émis lorsqu'une transaction de financement ou d'[épissure][topic splicing]
  a été signée et est prête à être publiée. Cela est particulièrement utile pour les canaux financés par une seule partie où le côté non financeur
  n'a pas l'opportunité de valider les entrées au préalable et peut vouloir fermer de force avant que le canal ne soit confirmé.

- [Eclair #3258][] ajoute un trait `ValidateInteractiveTxPlugin` qui permet aux plugins d'inspecter et de rejeter les entrées et sorties du pair distant
  dans les transactions interactives avant de signer. Cela s'applique aux ouvertures de canal [à double financement][topic dual funding] et
  aux [épissures][topic splicing], où les deux côtés participent à la construction de la transaction.

- [Eclair #3255][] corrige la sélection automatique du type de canal introduite dans [Eclair #3250][] (voir le [Bulletin #394][news394 eclair3250])
  de sorte qu'elle n'inclut plus `scid_alias` pour les canaux publics. Selon les BOLTs, `scid_alias` est uniquement autorisé pour
  [les canaux privés][topic unannounced channels].

- [LDK #4402][] corrige le minuteur de réclamation HTLC pour utiliser l'expiration CLTV HTLC réelle plutôt que la valeur de la charge utile de l'oignon.
  Pour les paiements [trampoline][topic trampoline payments] où un nœud est à la fois un saut trampoline et le destinataire final,
  l'expiration HTLC réelle est supérieure à ce que l'oignon spécifie, ccar le parcours extérieur du trampoline a ajouté son propre
  [delta CLTV][topic cltv expiry delta]. Utiliser la valeur onion a conduit le nœud à définir une échéance de réclamation plus stricte que nécessaire.

- [LND #10604][] ajoute un backend SQL (SQLite ou Postgres) pour la base de données des paiements sortants de LND, comme alternative
  à l'actuel magasin de clés-valeurs bbolt. Ce PR de consolidation regroupe plusieurs sous-PRs, notamment [#10153][LND #10153] qui a introduit
  une interface de magasin de paiement abstraite, [#9147][LND #9147] qui a implémenté le schéma SQL et le backend principal,
  et [#10485][LND #10485] qui a ajouté une migration de données expérimentale de KV vers SQL. LND a ajouté le support pour PostgreSQL
  dans le [Bulletin #169][news169 lnd-sql] et SQLite dans le [Bulletin #237][news237 lnd-sql].

- [BIPs #1699][] publie [BIP442][] spécifiant `OP_PAIRCOMMIT`, un nouveau opcode [tapscript][topic tapscript] qui retire deux éléments de la pile
  et pousse leur hash SHA256 tagué. Cela fournit une fonctionnalité de multi-engagement similaire à ce que [OP_CAT][topic op_cat] permet
  mais évite d'activer les [covenants][topic covenants] récursifs. `OP_PAIRCOMMIT` fait partie de la proposition de soft fork [LNHANCE][news383 lnhance]
  aux côtés de [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] ([BIP119][]), [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] ([BIP348][]),
  et OP_INTERNALKEY ([BIP349][]). Voir le [Bulletin #330][news330 paircommit] pour la proposition initiale.

- [BIPs #2106][] met à jour [BIP352][] ([paiements silencieux][topic silent payments]) pour introduire une limite de destinataire par groupe
  de `K_max` = 2323, atténuant le temps de scan dans le pire des cas pour des transactions adverses (voir le [Bulletin #392][news392 kmax]).
  Cette limite plafonne le nombre de sorties qu'un scanner doit vérifier par groupe de destinataires au sein d'une seule transaction.
  La valeur était initialement proposée à 1000 mais a été augmentée à 2323 pour correspondre au nombre maximum de sorties [P2TR][topic taproot]
  qui peuvent tenir dans une transaction de taille standard (100 kvB) et pour éviter l'empreinte des transactions de paiement silencieux.

- [BIPs #2068][] publie [BIP128][], qui spécifie un format JSON standard pour stocker les plans de récupération de timelock. Un plan de récupération
  consiste en deux transactions pré-signées pour récupérer les fonds si le propriétaire perd l'accès à son portefeuille : une transaction d'alerte
  qui consolide les UTXOs du portefeuille vers une seule adresse, et une transaction de récupération qui déplace ces fonds vers des portefeuilles
  de secours après un [timelock][topic timelocks] relatif de 2 à 388 jours. Si la transaction d'alerte est diffusée prématurément, le propriétaire
  peut simplement dépenser depuis l'adresse d'alerte pour invalider la récupération.

- [BOLTs #1301][] met à jour la spécification pour recommander un `dust_limit_satoshis` plus élevé pour les canaux [anchor][topic anchor outputs].
  Avec `option_anchors`, les transactions HTLC pré-signées n'ont pas de frais, donc leur coût n'est plus pris en compte dans le calcul de la poussière.
  Ce qui signifie que les sorties HTLC qui passent le contrôle de la poussière peuvent encore être [non économiques][topic uneconomical outputs]
  à réclamer onchain, puisque dépenser celles-ci nécessite une transaction en deuxième étape dont les frais peuvent excéder la valeur de la sortie.
  La spécification recommande maintenant que les nœuds définissent une limite de poussière qui prend en compte le coût de ces transactions en deuxième étape,
  et que les nœuds acceptent des valeurs supérieures aux seuils de poussière standard de Bitcoin Core de leurs pairs.

{% include snippets/recap-ad.md when="2026-03-10 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33616,33504,34616,3256,3258,3255,3250,4402,10604,10153,9147,10485,1699,2106,2068,1301" %}

[vpack del]: https://delvingbitcoin.org/t/stateless-vtxo-verification-decoupling-custody-from-implementation-specific-stacks/2267
[vpack gh]: https://github.com/jgmcalpine/libvpack-rs
[vpack tool]: https://www.vtxopack.org/
[ap ml thikcs]: https://groups.google.com/g/bitcoindev/c/xur01RZM_Zs
[news365 thikcs]: /fr/newsletters/2025/08/01/#proposition-de-op-templatehash-natif-a-taproot
[mk ml hourglass]: https://groups.google.com/g/bitcoindev/c/0E1UyyQIUA0
[bip draft hourglass2]: https://github.com/cryptoquick/bips/blob/hourglass-v2/bip-hourglass-v2.mediawiki
[hb ml hourglass]: https://groups.google.com/g/bitcoindev/c/zmg3U117aNc
[eh ml agility]: https://groups.google.com/g/bitcoindev/c/7jkVS1K9WLo
[rfc7696]: https://datatracker.ietf.org/doc/html/rfc7696
[pw ml agility]: https://groups.google.com/g/bitcoindev/c/O6l3GUvyO7A
[eh ml agility2]: https://groups.google.com/g/bitcoindev/c/O6l3GUvyO7A/m/OXmZ-PnVAwAJ
[jl ml agility]: https://groups.google.com/g/bitcoindev/c/O6l3GUvyO7A/m/5GnsttP2AwAJ
[c ml agility]: https://groups.google.com/g/bitcoindev/c/O6l3GUvyO7A/m/5y9GkeXVBAAJ
[news375 truc]: /fr/newsletters/2025/10/10/#bitcoin-core-33504
[news386 sfl]: /fr/newsletters/2026/01/02/#bitcoin-core-32545
[news394 eclair3250]: /fr/newsletters/2026/02/27/#eclair-3250
[news169 lnd-sql]: /fr/newsletters/2021/10/06/#lnd-5366
[news237 lnd-sql]: /fr/newsletters/2023/02/08/#lnd-7252
[news330 paircommit]: /fr/newsletters/2024/11/22/#mise-a-jour-de-la-proposition-lnhance
[news383 lnhance]: /fr/newsletters/2025/12/05/#soft-fork-lnhance
[news392 kmax]: /fr/newsletters/2026/02/13/#proposition-pour-limiter-le-nombre-de-destinataires-de-paiement-silencieux-par-groupe
[Bitcoin Core 28.4rc1]: https://bitcoincore.org/bin/bitcoin-core-28.4/test.rc1/
[mailing list nversion]: https://groups.google.com/g/bitcoindev/c/fCfbi8hy-AE
[BIP 320]: https://github.com/bitcoin/bips/blob/master/bip-0320.mediawiki