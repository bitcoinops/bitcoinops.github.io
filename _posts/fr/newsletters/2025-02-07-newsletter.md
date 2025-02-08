---
title: 'Bulletin Hebdomadaire Bitcoin Optech #340'
permalink: /fr/newsletters/2025/02/07/
name: 2025-02-07-newsletter-fr
slug: 2025-02-07-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine annonce une correction de vulnérabilité affectant LDK, résume la
discussion sur le gossip à connaissance nulle pour les annonces de canaux LN, décrit la découverte de
recherches antérieures qui peuvent être appliquées à la recherche de linéarisations de clusters
optimales, fournit une mise à jour sur le développement du protocole Erlay pour réduire la bande
passante de relais de transactions, examine les compromis entre différents scripts pour
l'implémentation d'ancres éphémères LN, relaye une proposition pour émuler un opcode `OP_RAND` de
manière à préserver la vie privée sans nécessiter de changements de consensus, et pointe vers une
discussion renouvelée sur l'abaissement du taux de frais minimum pour les transactions.

## Nouvelles

- **Vulnérabilité de fermeture forcée de canal dans LDK :** Matt Morehouse a [publié][morehouse
  forceclose] sur Delving Bitcoin pour annoncer une vulnérabilité affectant LDK qu'il a [divulguée de
  manière responsable][topic responsible disclosures] et qui a été corrigée dans la version 0.1.1 de
  LDK. Similaire à une autre vulnérabilité récemment divulguée par Morehouse dans LDK (voir
  le [Bulletin #339][news339 ldkvuln]), une boucle dans le code de LDK se terminait la première fois
  qu'elle traitait une occurrence inhabituelle, l'empêchant de gérer des occurrences supplémentaires
  du même problème. Dans ce cas, cela pourrait entraîner l'échec de LDK à régler les [HTLCs][topic
  htlc] en attente dans les canaux ouverts, conduisant finalement les contreparties honnêtes à fermer
  de force les canaux afin qu'elles puissent régler les HTLCs onchain.

  Cela ne pourrait probablement pas conduire à un vol direct, mais cela pourrait entraîner le paiement
  par la victime des frais pour les canaux fermés, des frais pour ouvrir de nouveaux canaux, et
  réduire la capacité de la victime à gagner des frais de transfert.

  L'excellent post de Morehouse entre dans les détails supplémentaires et suggère comment éviter les
  futurs bugs provenant de la même cause sous-jacente.

- **Gossip à connaissance nulle pour les annonces de canaux LN :** Johan Halseth a [publié][halseth
  zkgoss] sur Delving Bitcoin avec une extension au protocole proposé d'annonce de canal 1.75 [topic
  channel announcements] qui permettrait à d'autres nœuds de vérifier qu'un canal est soutenu par une
  transaction de financement, prévenant de multiples attaques DoS bon marché, mais sans révéler quelle
  UTXO est la transaction de financement, améliorant ainsi la confidentialité. L'extension de Halseth
  s'appuie sur ses recherches précédentes (voir le [Bulletin #321][news321 zkgoss]) qui utilisent
  [utreexo][topic utreexo] et un système de preuve à connaissance nulle (ZK). Elle serait appliquée aux
  canaux [simple taproot][topic simple taproot channels] basés sur [MuSig2][topic musig].

  La discussion s'est concentrée sur les compromis entre l'idée de Halseth, la continuation de
  l'utilisation de gossip non privé, et les méthodes alternatives pour générer la preuve ZK. Les
  préoccupations incluaient l'assurance que tous les nœuds LN peuvent rapidement vérifier les preuves
  et la complexité du système de preuve et de vérification puisque tous les nœuds LN devront
  l'implémenter.

  La discussion était en cours au moment de la rédaction de ce résumé.

- **Découverte de recherches antérieures pour trouver une linéarisation optimale des clusters :**
  Stefan Richter a [publié][richter cluster] sur Delving Bitcoin à propos d'un
  article de recherche de 1989, il a découvert qu'il existe un algorithme éprouvé qui peut
  être utilisé pour trouver efficacement le sous-ensemble de transactions avec le taux de frais le
  plus élevé qui sera topologiquement valide si le sous-ensemble est inclus dans un bloc. Il a
  également trouvé une [implémentation en C++][mincut impl] de plusieurs algorithmes pour des
  problèmes similaires qui "sont censés être encore plus rapides en pratique".

  Les travaux antérieurs sur le [regroupement du pool de mémoire][topic cluster mempool] se sont
  concentrés sur la facilitation et l'accélération de la comparaison entre différentes linéarisations
  afin que la meilleure puisse être utilisée. Cela permettrait d'utiliser un algorithme rapide pour
  linéariser immédiatement un cluster, avec un algorithme plus lent mais plus optimal pouvant
  fonctionner sur des cycles CPU disponibles. Cependant, si l'algorithme de 1989 pour le _problème de
  fermeture à ratio maximum_, ou un autre algorithme pour ce problème, peut fonctionner assez
  rapidement, il pourrait être utilisé tout le temps. Mais, même s'il était modérément lent, il
  pourrait encore être utilisé comme l'algorithme qui fonctionne sur des cycles CPU disponibles.

  Pieter Wuille a [répondu][wuille cluster] avec enthousiasme et plusieurs questions de suivi. Il a
  également [décrit][wuille sp cl] un nouvel algorithme de linéarisation de cluster que le groupe de
  travail sur le pool de mémoire de cluster a développé sur la base d'une discussion lors de la
  semaine de recherche sur Bitcoin avec Dongning Guo et Aviv Zohar. Il convertit le problème en un qui
  peut être abordé en utilisant la [programmation linéaire][] et semble être rapide, facile à
  implémenter et produit une linéarisation optimale---s'il se termine. Cependant, une preuve est
  nécessaire pour montrer qu'il se terminera (et dans un délai raisonnable).

  Bien que non directement lié à Bitcoin, nous avons trouvé intéressante la [description][richter
  deepseek] de Richter sur la manière dont il a trouvé l'article de 1989 en utilisant le raisonnement
  LLM de DeepSeek.

  Au moment de la rédaction, la discussion était en cours et des articles supplémentaires sur le
  domaine du problème étaient explorés. Richter a écrit : "Il semble que notre problème, ou plutôt, sa
  solution généralisée qui est appelée _source-sink-monotone parametric min-cut_ a des applications
  dans quelque chose appelé agrégation de polygones pour la simplification de carte et d'autres sujets
  en vision par ordinateur."

- **Mise à jour sur Erlay :** Sergi Delgado a fait plusieurs publications sur Delving Bitcoin
  concernant son travail au cours de l'année passée sur l'implémentation d'[Erlay][topic erlay] pour
  Bitcoin Core. Il commence par un [aperçu][delgado erlay] de la manière dont la diffusion de
  transactions existante (appelée _fanout_) fonctionne et comment Erlay propose de changer cela. Il
  note que du fanout est attendu même dans un réseau où chaque nœud prend en charge Erlay, car "le
  fanout est plus efficace et considérablement plus rapide que la réconciliation d'ensemble, à
  condition que le nœud récepteur ne connaisse pas la transaction annoncée."

  L'utilisation d'un mélange de fanout et de réconciliation nécessite de choisir quand utiliser chaque
  méthode et avec quels pairs les utiliser, donc ses recherches se sont concentrées sur la prise des
  choix optimaux :

  - [Filtrage basé sur la connaissance de la transaction][sd1] examine si un nœud doit inclure un pair
    dans ses plans pour diffuser une transaction même s'il sait que ce pair possède déjà la transaction.
    Par exemple, notre nœud a dix pairs ; trois de ces pairs ont déjà annoncé une
    transaction vers nous. Si nous voulons choisir aléatoirement trois pairs pour propager davantage
    cette transaction, devrions-nous sélectionner parmi les dix pairs ou juste parmi les sept pairs qui
    ne nous ont pas encore annoncé la transaction ? De manière surprenante, les résultats de simulation
    montrent qu'"il n'y a pas de différence significative entre [les options]". Delgado explore ce
    résultat surprenant et conclut que tous les pairs devraient être considérés (c'est-à-dire, aucun
    filtrage ne devrait être effectué).

  - [Quand sélectionner les pairs candidats pour le fanout][sd2] examine quand un nœud devrait choisir
    quels pairs recevront une transaction de fanout (le reste utilisant la réconciliation Erlay). Deux
    options sont considérées : peu après qu'un nœud valide une nouvelle transaction et la mette en file
    d'attente pour la relayer, et quand il est temps pour cette transaction d'être relayée (les nœuds ne
    relayent pas immédiatement les transactions : ils attendent un petit laps de temps aléatoire pour
    rendre plus difficile la sonde du réseau topologie et deviner quel nœud est à l'rigine une transaction,
    ce qui serait mauvais pour la confidentialité). Encore une fois, les résultats de simulation
    montrent qu'"il n'y a pas de différences significatives", bien que les "résultats peuvent varier
    [...] dans des réseaux avec un support [Erlay] partiel".

  - [Combien de pairs devraient recevoir un fanout][sd3] examine le taux de fanout. Un taux plus élevé
    accélère la propagation de la transaction mais réduit les économies de bande passante. Outre le test
    du taux de fanout, Delgado a également testé l'augmentation du nombre de pairs sortants, car c'est
    l'un des objectifs de l'adoption d'Erlay. La simulation montre que l'approche Erlay actuelle a
    réduit la bande passante d'environ 35% en utilisant les limites actuelles de pairs sortants (8
    pairs), et 45% en utilisant 12 pairs sortants. Cependant, la latence de la transaction est augmentée
    d'environ 240%. De nombreux autres compromis sont graphiqués dans le post. En plus des résultats
    étant utiles pour choisir les paramètres actuels, Delgado note qu'ils seront utiles pour évaluer des
    algorithmes de fanout alternatifs qui pourraient être capables de faire de meilleurs compromis.

  - [Définir le taux de fanout en fonction de la manière dont une transaction a été reçue][sd4]
    examine si le taux de fanout devrait être ajusté en fonction de si une transaction a été reçue pour
    la première fois via fanout ou réconciliation. De plus, s'il devrait être ajusté, quel taux ajusté
    devrait être utilisé ? L'idée est que le fanout est plus rapide et plus efficace lorsqu'une nouvelle
    transaction commence à être relayée à travers le réseau, mais cela conduit à une bande passante
    gaspillée après qu'une transaction a déjà atteint la plupart des nœuds. Il n'y a aucun moyen pour un
    nœud de déterminer directement combien d'autres nœuds ont déjà vu une transaction, mais si le pair
    qui lui a envoyé une transaction pour la première fois a utilisé le fanout plutôt que d'attendre la
    prochaine réconciliation programmée, alors il est plus probable que la transaction est dans les
    premiers stades de la propagation. Ces données peuvent être utilisées pour augmenter modérément le
    propre taux de fanout du nœud pour cette transaction afin de l'aider à se propager plus rapidement.
    Delgado a simulé l'idée et a trouvé un ratio de fanout modifié qui diminue le temps de propagation
    de 18% avec seulement une augmentation de 6,5% de la bande passante par rapport au résultat de
    contrôle qui utilise le même taux de fanout pour toutes les transactions.

- **Compromis dans les scripts d'ancrage éphémères de LN :** Bastien Teinturier [a posté][teinturier
  ephanc] sur Delving Bitcoin pour demander des avis
  à propos de quel script d'[ancre éphémère][topic ephemeral anchors] devrait être utilisé comme l'un
  des résultats pour les transactions d'engagement LN basées sur [TRUC][topic v3 transaction relay] en
  remplacement des [ancres de sortie][topic anchor outputs] existantes. Le script utilisé détermine
  qui peut [augmenter les frais CPFP][topic cpfp] de la transaction d'engagement (et sous quelles
  conditions ils peuvent le faire). Il a présenté quatre options :

  - *Utiliser un script pay-to-anchor (P2A) :* cela a une taille minimale onchain mais signifie
    que toute la valeur [HTLC élaguée][topic trimmed htlc] ira probablement aux mineurs (comme c'est le
    cas actuellement).

  - *Utiliser une ancre à clé unique pour un seul participant :* cela peut permettre à un participant
    de réclamer une partie de la valeur HTLC élaguée en acceptant volontairement d'attendre quelques
    dizaines de blocs avant de pouvoir dépenser l'argent qu'ils retirent d'un canal. Quiconque souhaite
    fermer un canal de force doit de toute façon attendre ce délai. Cependant, aucune des parties du
    canal ne peut déléguer le paiement des frais à un tiers sans permettre à ce dernier de voler tous
    leurs fonds du canal. Si vous et votre contrepartie vous disputez pour réclamer la valeur
    excédentaire, elle ira probablement de toute façon aux mineurs.

  - *Utiliser une ancre à clé partagée :* cela permet également de récupérer la valeur HTLC élaguée
    excédentaire et autorise la délégation, mais quiconque reçoit la délégation peut vous concurrencer
    et votre contrepartie pour réclamer la valeur excédentaire. Là encore, en cas de concurrence, toute
    la valeur excédentaire ira probablement aux mineurs.

  - *Utiliser une ancre à double clé :* cela permet à chaque participant de réclamer la valeur HTLC
    élaguée excédentaire sans avoir à attendre des blocs supplémentaires avant de pouvoir dépenser.
    Cependant, cela ne permet pas la délégation. Les deux parties d'un canal peuvent toujours se
    concurrencer.

  Dans les réponses au post, Gregory Sanders [a noté][sanders ephanc] que les différents schémas
  pourraient être utilisés à différents moments. Par exemple, P2A pourrait être utilisé lorsqu'il n'y
  avait pas de HTLC élagués, et l'une des ancres à clé pourrait être utilisée à d'autres moments. Si
  la valeur élaguée était au-dessus du [seuil de poussière][topic uneconomical outputs], cette valeur
  pourrait être ajoutée à la transaction d'engagement LN au lieu d'une sortie d'ancre. De plus, il a
  averti que cela pourrait créer "une nouvelle étrangeté [une] contrepartie pourrait être tentée
  d'augmenter le montant élagué et de le prendre elle-même." David Harding a développé ce thème dans
  un [post ultérieur][harding ephanc].

  Antoine Riard [a averti][riard ephanc] contre l'utilisation de P2A en raison du risque d'encourager
  le [blocage de transaction par les mineurs][topic transaction pinning] (voir le [Bulletin
  #339][news339 pincycle]).

  La discussion était en cours au moment de la rédaction.

- **Émuler OP_RAND :** Oleksandr Kurbatov [a posté][kurbatov rand] sur Delving Bitcoin à propos d'un
  protocole interactif qui permet à deux parties de conclure un contrat qui sera payé d'une manière
  que ni l'une ni l'autre ne peut prévoir, ce qui est fonctionnellement équivalent à aléatoirement.
  [Des travaux antérieurs][dryja pp] sur les _paiements probabilistes_ dans Bitcoin ont utilisé des
  scripts avancés, mais l'approche de Kurbatov utilise des clés publiques spécialement construites.
  qui permet au gagnant de dépenser les fonds contractés. Cela est plus privé et peut permettre une
  plus grande flexibilité.

  Optech n'a pas pu analyser entièrement le protocole, mais nous n'avons pas repéré de problèmes
  évidents. Nous espérons voir une discussion supplémentaire sur l'idée---les paiements probabilistes
  ont de multiples applications, y compris permettre aux utilisateurs d'envoyer des montants onchain
  qui seraient autrement [non économiques][topic uneconomical outputs], comme pour les [HTLCs
  élagués][topic trimmed htlc].

- **Discussion sur la réduction du taux minimum de frais de relais de transaction :**
  Greg Tonoski a [posté][tonoski minrelay] sur la liste de diffusion Bitcoin-Dev concernant la
  réduction du [taux de frais de relais de transaction minimum par défaut][topic default minimum
  transaction relay feerates], un sujet qui a été discuté à plusieurs reprises (et résumé par Optech)
  depuis 2018---plus récemment en 2022 (voir le [Bulletin #212][news212 relay]). À noter, une
  vulnérabilité récemment divulguée (voir le [Bulletin #324][news324 largeinv]) a révélé un problème
  potentiel qui aurait pu affecter les utilisateurs et les mineurs qui avaient réduit ce paramètre par
  le passé. Optech fournira des mises à jour s'il y a une discussion significative ultérieure.

## Changement de consensus

_Une section mensuelle résumant les propositions et discussions sur le changement des règles de
consensus de Bitcoin._

- **Mises à jour de la proposition de soft fork de nettoyage du consensus :** Antoine Poinsot a fait
  plusieurs publications sur le fil Delving Bitcoin concernant le [soft fork de nettoyage du
  consensus][topic consensus cleanup] suggérant des changements de paramètres :

  - [Introduire une limite de sigops pour les entrées legacy][ap1] : dans un fil privé, Poinsot et
    plusieurs autres contributeurs ont tenté de produire un bloc pour regtest qui prendrait le plus de
    temps possible à valider en utilisant les problèmes connus dans la validation des transactions
    legacy (pré-segwit). Après recherche, il a trouvé qu'il pouvait "adapter [le pire bloc] pour qu'il
    soit valide sous les [atténuations initialement proposées][ccbip] en 2019" (voir le [Bulletin
    #36][news36 cc]). Cela le conduit à proposer une atténuation différente : limiter le nombre maximum
    d'opérations de signature (sigops) dans les transactions legacy à 2 500. Chaque exécution de
    `OP_CHECKSIG` compte pour un sigop et chaque exécution de `OP_CHECKMULTISIG` peut compter jusqu'à 20
    sigops (selon le nombre de clés publiques utilisées avec elle). Son analyse montre que cela
    diminuera le temps de validation dans le pire des cas de 97,5%.

    Comme pour tout changement de ce type, il y a un risque de [confiscation accidentelle][topic
    accidental confiscation] en raison de la nouvelle règle rendant les transactions précédemment
    signées invalides. Si vous connaissez quelqu'un qui nécessite des transactions legacy avec plus de 2
    500 opérations de signature unique ou plus de 2 125 clés pour des opérations multisig[^2kmultisig],
    veuillez alerter Poinsot ou d'autres développeurs de protocole.

  - [Augmenter la période de grâce du timewarp à 2 heures][ap2] : auparavant, la proposition de
    nettoyage interdisait au premier bloc d'une nouvelle période de difficulté d'avoir un temps
    d'en-tête de bloc de plus de 600 secondes avant le temps du bloc précédent. Cela signifiait qu'une
    quantité constante de hashrate ne pouvait pas utiliser la vulnérabilité [timewarp][topic time warp]
    pour produire des blocs plus rapidement qu'une fois toutes les 10 minutes.

    Poinsot accepte désormais d'utiliser une période de grâce de 7 200 secondes (2 heures), comme
    initialement proposé par Sjors Provoost, étant beaucoup moins susceptible de conduire à ce qu'un
    mineur produise accidentellement un bloc invalide, bien que cela permette à un attaquant très
    patient contrôlant plus de 50 % du hashrate du réseau d'utiliser l'attaque de timewarp pour réduire
    la difficulté sur une période de mois même si le hashrate réel reste constant ou augmente. Ce serait
    une attaque visiblement publique et le réseau aurait des mois pour réagir. Dans son post, Poinsot
    résume les arguments précédents (voir le [Bulletin #335][news335 cc] pour notre résumé beaucoup moins
    détaillé) et conclut que, "malgré les arguments plutôt faibles en faveur de l'augmentation de la
    période de grâce, le coût d'une telle mesure [n'interdit] pas d'opter pour la prudence."

    Dans un fil de discussion dédié à l'extension de la période de grâce, les développeurs Zawy et
    Pieter Wuille [ont discuté][wuille erlang] comment la période de grâce de 600 secondes, qui
    semblerait permettre de diminuer lentement la difficulté à sa valeur minimale, était en réalité
    suffisante pour empêcher plus d'une petite diminution de difficulté. Spécifiquement, ils ont examiné
    l'impact du bug d'ajustement de difficulté off-by-one de Bitcoin et l'asymétrie de la distribution
    [erlang][] sur le ciblage précis de la difficulté. Zawy a conclu succinctement, "Ce n'est pas qu'un
    ajustement pour à la fois Erlang et le 'trou de 2015' n'est pas nécessaire, c'est que 600 secondes
    avant le bloc précédent n'est pas un mensonge de 600 secondes, c'est un mensonge de 1200 secondes
    parce que nous attendions un horodatage 600 secondes après."

  - [Correction de transaction en double][ap3] : suite à une demande de retour d'information de la
    part des mineurs (voir le [Bulletin #332][news332 cleanup]) concernant les impacts négatifs
    potentiels des solutions de consensus au problème des [transactions en double][topic duplicate
    transactions], Poinsot a sélectionné une solution spécifique à inclure dans la proposition de
    nettoyage : exiger que la hauteur du bloc précédent soit incluse dans le champ de verrouillage
    temporel de chaque transaction coinbase. Cette proposition a deux avantages : elle permet
    [d'extraire][corallo duplocktime] la hauteur du bloc engagé d'un bloc sans avoir à analyser le
    Script et elle permet [de créer][harding duplocktime] une preuve compacte basée sur SHA256 de la
    hauteur du bloc (environ 700 octets dans le pire des cas, bien moins que la preuve de 1 Mo dans le
    pire des cas qui serait nécessaire maintenant sans un système de preuve avancé).

    Ce changement n'affectera pas les utilisateurs réguliers mais nécessitera éventuellement que les
    mineurs mettent à jour le logiciel qu'ils utilisent pour générer des transactions coinbase. Si des
    mineurs ont des préoccupations concernant cette proposition, veuillez contacter Poinsot ou un autre
    développeur de protocole.

  Poinsot a également [publié][ap4] une mise à jour de haut niveau sur son travail et l'état actuel de
  la proposition sur la liste de diffusion Bitcoin-Dev.

- **Demande pour une conception de covenant soutenant Braidpool :** Bob McElrath [a posté][mcelrath
  braidcov] sur Delving Bitcoin demandant aux développeurs travaillant sur des conceptions de
  [covenant][topic covenants] de considérer comment leur proposition préférée, ou une nouvelle
  proposition, pourrait aider à la création d'une [pool de minage][topic pooled mining] décentralisée
  efficace. Le design prototype actuel pour Braidpool utilise une fédération de signataires,
  où les signataires reçoivent des parts de [signature de seuil][topic threshold signature] basées sur
  leur contribution de taux de hachage au pool. Cela permet à un mineur majoritaire (ou à une
  collusion de plusieurs mineurs constituant une majorité) de voler les paiements des mineurs plus
  petits. McElrath préférerait utiliser une covenant qui assure que chaque mineur peut retirer des
  fonds du pool proportionnellement à leurs contributions. Il fournit une liste spécifique d'exigences
  dans le post ; il accueille également une preuve d'impossibilité.

  À l'heure actuelle, il n'y a eu aucune réponse.

- **Sélection transactionnelle déterministe à partir d'un mempool engagé :** un fil de discussion
  d'avril 2024 a reçu une attention renouvelée le mois passé. Auparavant, Bob McElrath [a
  posté][mcelrath dtx] sur le fait d'avoir les mineurs s'engager sur les transactions dans leur
  mempool et ensuite ne leur permettre d'inclure dans leurs blocs que les transactions qui ont été
  sélectionnées de manière déterministe à partir des engagements précédents. Il voit deux applications :

  - _Globalement pour tous les mineurs :_ cela éliminerait le "risque et la responsabilité de la
   sélection des transactions" dans un monde où les mineurs sont souvent de grandes entités
   corporatives qui doivent se conformer aux lois, régulations, et aux conseils des gestionnaires de
   risques.

  - _Localement pour un seul pool :_ cela a la plupart des avantages d'un algorithme déterministe
   global mais ne nécessite aucun changement de consensus pour être mis en œuvre. De plus, cela peut
   économiser une grande quantité de bande passante entre pairs dans un [pool de minage][topic pooled
   mining] décentralisé tel que Braidpool, car l'algorithme détermine quelles transactions un _bloc
   candidat_ doit inclure, donc toute _part_ produite à partir de ce bloc n'a pas besoin de fournir
   explicitement des données de transaction aux pairs du pool.

  Anthony Towns [a décrit][towns dtx] plusieurs problèmes potentiels avec une option de changement de
  consensus global : tout changement dans la sélection des transactions nécessiterait un changement de
  consensus (possiblement un hard fork) et quiconque ayant créé une transaction non standard serait
  incapable de la faire miner même avec la coopération d'un mineur. Les changements de politique
  récents au cours des dernières années qui auraient nécessité un changement de consensus incluent :
  [TRUC][topic v3 transaction relay], les politiques [RBF][topic rbf] mises à jour, et les [ancres
  éphémères][topic ephemeral anchors]. Towns a lié à un [cas bien connu][bitcoin core #26348] où des
  millions de dollars en valeur ont été accidentellement bloqués dans un script non standard, qu'un
  mineur coopératif a pu débloquer.

  Le reste de la discussion s'est concentré sur l'approche locale telle que conçue pour Braidpool. Il
  n'y a eu aucune objection et une discussion supplémentaire sur un sujet concernant un algorithme
  d'ajustement de la difficulté (voir l'élément suivant dans cette section) a montré comment cela
  pourrait être particulièrement utile pour un pool qui crée des blocs à un taux beaucoup plus élevé
  que Bitcoin, où le déterminisme de la sélection des transactions réduit considérablement la bande
  passante, la latence et les coûts de validation.

- **Algorithme d'ajustement de la difficulté rapide pour une blockchain DAG :** le développeur Zawy
  [a posté][zawy daadag] sur Delving Bitcoin à propos d'un [algorithme d'ajustement de la
  difficulté][topic daa] (DAA) pour une blockchain de type graphe acyclique dirigé (DAG). L'algorithme
  a été [conçu][bp pow] pour être utilisé dans le consensus entre pairs de Braidpool (pas dans le
  consensus global de Bitcoin), cependant la discussion a régulièrement touché à des aspects du
  consensus global.
  Dans la blockchain de Bitcoin, chaque bloc s'engage envers un seul parent ; plusieurs blocs enfants
  peuvent s'engager envers le même parent, mais un seul d'entre eux sera considéré comme valide sur la
  _meilleure blockchain_ par un nœud. Dans une blockchain DAG, chaque bloc peut s'engager envers un ou
  plusieurs parents et peut avoir zéro ou plusieurs enfants qui s'engagent envers lui ; la meilleure
  blockchain DAG peut considérer plusieurs blocs de la même génération comme valides.

  ![Illustration d'une blockchain DAG](/img/posts/2025-02-dag-blockchain.dot.png)

  Le DAA proposé cible le nombre moyen de parents dans les 100 derniers blocs valides observés. Si le
  nombre moyen de parents augmente, l'algorithme augmente la difficulté ; s'il y a moins de parents,
  la difficulté diminue. Viser une moyenne de deux parents offre le consensus le plus rapide, selon
  Zawy. Contrairement au DAA de Bitcoin, le DAA proposé n'a pas besoin de prendre en compte le temps ;
  cependant, il nécessite que les pairs ignorent les blocs qui arrivent bien après les autres blocs de
  la même génération. Il n'est pas possible d'atteindre un consensus sur le retard, donc en fin de
  compte, les DAGs avec plus de preuve de travail (PoW) sont préférés à ceux avec moins de PoW ; le
  développeur du DAA, Bob McElrath, a [analysé][mcelrath daa-latency] le problème et une atténuation
  possible.

  Pieter Wuille a [commenté][wuille prior] que la proposition semble similaire à une [idée de
  2012][miller stale] d'Andrew Miller ; Zawy a [convenu][zawy prior] et McElrath [mettra à
  jour][mcelrath prior] son papier avec une citation. Sjors Provoost a [discuté][provoost dag] de la
  complexité de gérer les chaînes DAG dans l'architecture actuelle de Bitcoin Core, mais a noté que
  cela pourrait être plus facile en utilisant libbitcoin et efficace en utilisant [utreexo][topic
  utreexo]. Zawy a [simulé][zawy sim] de manière approfondie le protocole et a indiqué qu'il
  travaillait sur des simulations supplémentaires pour des variantes du protocole afin de trouver le
  meilleur équilibre entre les compromis.

  Le dernier message du fil de discussion a été posté environ un mois avant la rédaction de ce résumé,
  mais nous nous attendons à ce que Zawy et les développeurs de Braidpool continuent d'analyser et
  d'implémenter le protocole.

## Mises à jour et versions candidates

_Nouvelles sorties et candidats à la sortie pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de passer aux nouvelles versions ou d'aider à tester les candidats à la sortie._

- [BDK Wallet 1.1.0][] est une sortie de cette bibliothèque pour la création d'applications
  compatibles Bitcoin. Elle utilise par défaut la version de transaction 2 (améliorant la
  confidentialité en permettant aux transactions BDK de se fondre avec d'autres portefeuilles qui
  doivent utiliser les transactions v2 en raison de leur prise en charge des verrouillages relatifs,
  voir le [Bulletin #337][news337 bdk]). Elle ajoute également le support pour [les filtres de blocs
  compacts][topic compact block filters] (voir le [Bulletin #339][news339 bdk-cpf]), en plus de
  "diverses corrections de bugs et améliorations".

- [LND v0.18.5-beta.rc1][] est un candidat à la sortie pour une version mineure de cette
  implémentation populaire de nœud LN.

### Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],[LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin
Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #21590][] implémente un algorithme de [modular inversion][modularinversion] basé sur
  safegcd pour MuHash3072 (voir les Bulletins [#131][news131 muhash] et [#136][news136 gcd]), basé sur
  l'implémentation de libsecp256k1 tout en ajoutant le support pour les architectures 32 bits et 64
  bits et en se spécialisant pour le module spécifique. Les résultats des benchmarks montrent une
  amélioration de performance d'environ 100× sur x86_64, réduisant le calcul de MuHash de 5.8 ms à 57
  μs, ouvrant la voie à une validation d'état plus efficace.

- [Eclair #2983][] modifie la synchronisation de la table de routage lors de la reconnexion pour
  seulement synchroniser les [annonces de canal][topic channel announcements] avec les principaux
  pairs du nœud (déterminés par la capacité du canal partagé) afin de réduire la surcharge réseau. De
  plus, le comportement par défaut de la liste blanche de synchronisation (voir le Bulletin
  [#62][news62 whitelist]) a été mis à jour : pour désactiver la synchronisation avec les pairs non
  listés, les utilisateurs doivent maintenant définir `router.sync.peer-limit` à 0 (la valeur par
  défaut est 5).

- [Eclair #2968][] ajoute le support pour le [splicing][topic splicing] sur les canaux publics. Une
  fois la transaction de splice confirmée et verrouillée des deux côtés, les nœuds échangent des
  signatures d'annonce puis diffusent un message `channel_announcement` sur le réseau. Récemment,
  Eclair a ajouté le suivi des splices de tiers comme prérequis pour cela (voir le Bulletin
  [#337][news337 splicing]). Ce PR interdit également l'utilisation de `short_channel_id` pour le
  routage sur les canaux privés, privilégiant à la place `scid_alias` pour garantir que l'UTXO du
  canal n'est pas révélé.

- [LDK #3556][] améliore la gestion des [HTLC][topic htlc] en échouant proactivement les HTLCs en
  arrière s'ils sont trop proches de l'expiration avant d'attendre qu'une revendication onchain en
  amont soit confirmée. Auparavant, un nœud retarderait l'échec de l'HTLC en arrière de trois blocs
  supplémentaires pour donner le temps à la revendication de se confirmer. Cependant, ce délai courait
  le risque de fermer de force son canal. De plus, le champ `historical_inbound_htlc_fulfills` est
  supprimé pour nettoyer l'état du canal, et un nouveau `SentHTLCId` est introduit pour éliminer la
  confusion des ID HTLC en double sur les canaux entrants.

- [LND #9456][] ajoute des avertissements de dépréciation aux points de terminaison `SendToRoute`,
  `SendToRouteSync`, `SendPayment`, et `SendPaymentSync` en préparation de leur suppression dans la
  version suivante (0.21). Les utilisateurs sont encouragés à migrer vers les nouvelles méthodes v2
  `SendToRouteV2`, `SendPaymentV2`, `TrackPaymentV2`.

{% include snippets/recap-ad.md when="2025-02-11 15:30" %}

## Notes de bas de page

[^2kmultisig]:
    Dans P2SH et le comptage de sigops d'entrée proposé, un `OP_CHECKMULTISIG`
    avec plus de 16 clés publiques est compté comme 20 sigops, donc quelqu'un
    utilisant `OP_CHECKMULTISIG` 125 fois avec 17 clés chaque fois sera
    compté comme 2 500 sigops.

{% include references.md %}
{% include linkers/issues.md v=2 issues="21590,2983,2968,3556,9456,26348" %}
[dryja pp]: https://docs.google.com/presentation/d/1G4xchDGcO37DJ2lPC_XYyZIUkJc2khnLrCaZXgvDN0U/mobilepresent?pli=1#slide=id.g85f425098_0_219
[morehouse forceclose]: https://delvingbitcoin.org/t/disclosure-ldk-duplicate-htlc-force-close-griefing/1410
[news339 ldkvuln]: /en/newsletters/2025/01/31/#vulnerability-in-ldk-claim-processing
[halseth zkgoss]: https://delvingbitcoin.org/t/zk-gossip-for-lightning-channel-announcements/1407
[news321 zkgoss]: /fr/newsletters/2024/09/20/#prouver-l-inclusion-dans-l-ensemble-utxo-en-connaissance-nulle
[richter cluster]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303/9
[mincut impl]: https://github.com/jonas-sauer/MonotoneParametricMinCut
[wuille cluster]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303/10
[linear programming]: https://en.wikipedia.org/wiki/Linear_programming
[wuille sp cl]: https://delvingbitcoin.org/t/spanning-forest-cluster-linearization/1419
[richter deepseek]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303/15
[delgado erlay]: https://delvingbitcoin.org/t/erlay-overview-and-current-approach/1415
[sd1]: https://delvingbitcoin.org/t/erlay-filter-fanout-candidates-based-on-transaction-knowledge/1416
[sd2]: https://delvingbitcoin.org/t/erlay-select-fanout-candidates-at-relay-time-instead-of-at-relay-scheduling-time/1418
[sd3]: https://delvingbitcoin.org/t/erlay-find-acceptable-target-number-of-peers-to-fanout-to/1420
[teinturier ephanc]: https://delvingbitcoin.org/t/which-ephemeral-anchor-script-should-lightning-use/1412
[sanders ephanc]: https://delvingbitcoin.org/t/which-ephemeral-anchor-script-should-lightning-use/1412/2
[harding ephanc]: https://delvingbitcoin.org/t/which-ephemeral-anchor-script-should-lightning-use/1412/4
[riard ephanc]: https://delvingbitcoin.org/t/which-ephemeral-anchor-script-should-lightning-use/1412/3
[news339 pincycle]: /en/newsletters/2025/01/31/#replacement-cycling-attacks-with-miner-exploitation
[kurbatov rand]: https://delvingbitcoin.org/t/emulating-op-rand/1409
[tonoski minrelay]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAMHHROxVo_7ZRFy+nq_2YzyeYNO1ijR_r7d89bmBWv4f4wb9=g@mail.gmail.com/
[news324 largeinv]: /fr/newsletters/2024/10/11/#dos-par-ensembles-d-inventaire-importants
[news212 relay]: /en/newsletters/2022/08/10/#lowering-the-default-minimum-transaction-relay-feerate
[ap1]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/64
[ap2]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/66
[mcelrath braidcov]: https://delvingbitcoin.org/t/challenge-covenants-for-braidpool/1370/1
[news332 cleanup]: /fr/newsletters/2024/12/06/#discussion-continue-sur-la-proposition-de-soft-fork-de-nettoyage-du-consensus
[harding duplocktime]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/26
[corallo duplocktime]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/25
[ap3]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/65
[mcelrath dtx]: https://delvingbitcoin.org/t/deterministic-tx-selection-for-censorship-resistance/842/
[towns dtx]: https://delvingbitcoin.org/t/deterministic-tx-selection-for-censorship-resistance/842/7
[bp pow]: https://github.com/braidpool/braidpool/blob/6bc7785c7ee61ea1379ae971ecf8ebca1f976332/docs/braid_consensus.md#difficulty-adjustment
[miller stale]: https://bitcointalk.org/index.php?topic=98314.msg1075701#msg1075701
[mcelrath daa-latency]: https://delvingbitcoin.org/t/fastest-possible-pow-via-simple-dag/1331/12
[zawy prior]: https://delvingbitcoin.org/t/fastest-possible-pow-via-simple-dag/1331/9
[mcelrath prior]: https://delvingbitcoin.org/t/fastest-possible-pow-via-simple-dag/1331/8
[zawy sim]: https://delvingbitcoin.org/t/fastest-possible-pow-via-simple-dag/1331/10
[zawy daadag]: https://delvingbitcoin.org/t/fastest-possible-pow-via-simple-dag/1331
[wuille prior]: https://delvingbitcoin.org/t/fastest-possible-pow-via-simple-dag/1331/6
[provoost dag]: https://delvingbitcoin.org/t/fastest-possible-pow-via-simple-dag/1331/13
[ccbip]: https://github.com/TheBlueMatt/bips/blob/7f9670b643b7c943a0cc6d2197d3eabe661050c2/bip-XXXX.mediawiki#specification
[news36 cc]: /en/newsletters/2019/03/05/#prevent-use-of-op-codeseparator-and-findanddelete-in-legacy-transactions
[news335 cc]: /en/newsletters/2025/01/03/#consensus-cleanup-timewarp-grace-period
[wuille erlang]: https://delvingbitcoin.org/t/timewarp-attack-600-second-grace-period/1326/28?u=harding
[erlang]: https://en.wikipedia.org/wiki/Erlang_distribution
[sd4]: https://delvingbitcoin.org/t/erlay-define-fanout-rate-based-on-the-transaction-reception-method/1422
[news136 gcd]: /en/newsletters/2021/02/17/#faster-signature-operations
[news337 bdk]: /fr/newsletters/2025/01/17/#bdk-1789
[news339 bdk-cpf]: /en/newsletters/2025/01/31/#bdk-1614
[bdk wallet 1.1.0]: https://github.com/bitcoindevkit/bdk/releases/tag/wallet-1.1.0
[lnd v0.18.5-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.5-beta.rc1
[ap4]: https://mailing-list.bitcoindevs.xyz/bitcoindev/jiyMlvTX8BnG71f75SqChQZxyhZDQ65kldcugeIDJVJsvK4hadCO3GT46xFc7_cUlWdmOCG0B_WIz0HAO5ZugqYTuX5qxnNLRBn3MopuATI=@protonmail.com/
[modularinversion]: https://en.wikipedia.org/wiki/Modular_multiplicative_inverse
[news131 muhash]: /en/newsletters/2021/01/13/#bitcoin-core-19055
[news62 whitelist]: /en/newsletters/2019/09/04/#eclair-954
[news337 splicing]: /fr/newsletters/2025/01/17/#eclair-2936
