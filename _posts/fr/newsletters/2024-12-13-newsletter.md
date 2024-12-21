---
title: 'Bulletin Hebdomadaire Bitcoin Optech #333'
permalink: /fr/newsletters/2024/12/13/
name: 2024-12-13-newsletter-fr
slug: 2024-12-13-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit une vulnérabilité qui permettait le vol dans d'anciennes
versions de diverses implémentations du LN, annonce une vulnérabilité de désanonymisation affectant
Wasabi et des logiciels associés, résume un post et une discussion sur l'épuisement des canaux LN,
renvoie à un sondage pour recueillir des avis sur des propositions de covenant sélectionnées, décrit
deux types de pseudo-covenants basés sur des incitations, et fait référence à des résumés de la
réunion périodique en personne des développeurs de Bitcoin Core. Sont également incluses nos
sections régulières résumant une réunion du Bitcoin Core PR Review Club, listant les changements
dans les services et les logiciels clients, liant aux questions et réponses populaires de Bitcoin
Stack Exchange, annoncant des mises à jour et des versions candidates et présentant les changements
apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Vulnérabilité permettant le vol dans les canaux LN avec l'aide d'un mineur :**
  David Harding a [annoncé][harding irrev] à Delving Bitcoin une
  vulnérabilité qu'il avait [divulguée de manière responsable][topic responsible
  disclosures] plus tôt dans l'année. Les anciennes versions d'Eclair, LDK, et
  LND avec les paramètres par défaut permettaient à la partie qui ouvrait un canal
  de voler jusqu'à 98% de la valeur du canal. Core Lightning reste affecté si
  l'option de configuration qui n'est pas par défaut `--ignore-fee-limits` est utilisée ;
  la documentation de cette option indique déjà qu'elle est dangereuse.

  L'annonce a également décrit deux variantes moins graves de la vulnérabilité.
  Toutes les implémentations LN mentionnées ci-dessus tentent d'atténuer ces
  risques supplémentaires, mais une solution complète attend des travaux supplémentaires sur
  [le relais de paquets][topic package relay], [les mises à niveau de canal][topic channel
  commitment upgrades], et des projets connexes.

  La vulnérabilité tire parti du protocole LN permettant à un ancien
  état du canal de s'engager sur plus de frais onchain que la
  partie payant les frais ne contrôle dans l'état le plus récent. Par exemple, dans un
  état où Mallory contrôle 99% du solde du canal, elle dédie 98%
  du solde total aux frais [endogènes][topic fee sourcing]. Elle crée ensuite
  un nouvel état qui ne paie que des frais minimaux et transfère 99% du
  solde du canal du côté de Bob. En minant personnellement l'ancien état
  qui paie 98% en frais, elle peut capturer ces frais pour
  elle-même—réduisant la valeur maximale que Bob peut recevoir onchain de son
  99% attendu à un réel 2%. Mallory peut utiliser cette méthode pour
  voler simultanément dans environ 3 000 canaux par bloc (chaque
  canal pouvant être contrôlé par une victime différente), permettant le vol
  d'environ 3 millions de dollars USD par bloc si la valeur moyenne du canal est
  d'environ 1 000 USD.

  Les utilisateurs qui auraient pris conscience de l'attaque avant de perdre leurs fonds n'auraient
  pas pu se protéger en fermant leurs nœuds LN, car Mallory aurait déjà pu créer les états
  nécessaires. Même si les victimes tentaient de fermer de force leurs canaux dans leur dernier
  état (par exemple, où Bob contrôle 99% de la valeur du canal), Mallory pourrait
  leur faire perdre 98% de la valeur du canal en sacrifiant 1% de la valeur du canal elle-même.

  La vulnérabilité la plus grave a été corrigée, et les variantes moins graves
  partiellement atténuées, en limitant le montant maximum de la valeur du canal qui
  peut être dédié aux frais. Comme les frais dans un état antérieur ont toujours la possibilité d'être
  plus élevés que le montant que la partie payante contrôle dans un état ultérieur, le vol est
  encore possible---mais le montant est limité. Une solution complète attend des améliorations dans la
  source de frais totalement [exogène][topic fee sourcing] (comme tous les états payant le même frais
  de transaction d'engagement), ce qui dépend d'un relais de paquet robuste pour le bumping de frais
  [CPFP][topic cpfp] dans le protocole P2P de Bitcoin et des mises à niveau de transaction
  d'engagement de canal pour LN.

- **Vulnérabilité de désanonymisation affectant Wasabi et les logiciels associés :** un développeur
  de GingerWallet a [divulgué][drkgry deanon] une méthode qu'un coordinateur de [coinjoin][topic
  coinjoin] pourrait utiliser pour empêcher les utilisateurs de gagner en confidentialité lors d'un
  coinjoin. Le journaliste de Bitcoin Magazine, Shinobi, [rapporte][shinobi deanon] que la
  vulnérabilité a été initialement découverte en 2021 par Yuval Kogman et [signalée][wasabi #5439] à
  l'équipe de développement de Wasabi avec plusieurs autres problèmes. Optech est conscient depuis
  mi-2022 que Kogman avait de sérieuses préoccupations non résolues avec les versions déployées de
  Wasabi, mais nous avons négligé d'enquêter davantage ; nous présentons nos excuses auprès de lui et des
  utilisateurs de Wasabi pour notre échec.

- **Aperçus sur l'épuisement des canaux :** René Pickhardt a [posté][pickhardt deplete] sur Delving
  Bitcoin et a [participé][dd deplete], avec Christian Decker, à un Optech Deep Dive sur ses
  recherches dans les fondements mathématiques des réseaux de canaux de paiement (notamment LN). Un
  point particulier de son post sur Delving Bitcoin était la découverte que certains canaux dans des
  chemins circulaires sur le réseau finiraient par s'épuiser si le chemin était suffisamment utilisé.
  Lorsqu'un canal est effectivement complètement épuisé, signifiant qu'il ne peut pas transmettre de
  paiements supplémentaires dans la direction épuisée, le chemin circulaire (cycle) est rompu. À
  mesure que chaque cycle dans le graphe du réseau est successivement rompu, le réseau converge vers
  un graphe résiduel qui n'a pas de cycles (une arborescence). Cela réplique un [résultat
  antérieur][guidi spanning] du chercheur Gregorio Guidi, bien que Pickhardt soit arrivé à ce résultat
  par une approche différente, et semble également être confirmé dans des recherches non publiées par
  Anastasios Sidiropoulos.

  ![Exemple de cycles, d'épuisement et d'une arborescence résiduelle](/img/posts/2024-12-depletion.png)

  L'aperçu le plus notable fourni par ce résultat est peut-être que l'épuisement généralisé des canaux
  se produit même dans une économie circulaire où il n'y a pas de nœuds sources (c'est-à-dire, les
  dépensiers nets) et de nœuds d'arrivée (c'est-à-dire, les receveurs nets). Si LN était utilisé pour
  chaque paiement---du client à l'entreprise, de l'entreprise à l'entreprise, et de l'entreprise au
  travailleur---il convergerait toujours vers une arborescence.

  On ignore si les nœuds voudraient que leurs canaux fassent partie de l'arborescence
  résiduelle ou non. D'une part, cet arbre représente la dernière partie du réseau qui serait encore
  capable de transmettre des paiements---c'est équivalent à une topologie en étoile---donc il peut
  être possible de facturer des frais de transfert élevés à travers les canaux résiduels. D'autre
  part, les canaux résiduels sont ce qui reste après que tous les autres canaux aient déjà collecté
  des frais jusqu'à l'épuisement.

  Bien qu'un canal avec des frais de transfert plus élevés soit moins susceptible d'être
  épuisé (toutes choses étant égales par ailleurs), les propriétés des autres canaux dans les
  mêmes cycles influencent fortement la probabilité d'épuisement, rendant difficile pour un opérateur
  de nœud de tenter d'utiliser le contrôle de ses frais de transfert seuls pour prévenir cet épuisement.

  Les canaux de plus grande capacité sont également moins susceptibles de s'épuiser que les canaux de
  capacité inférieure. Cela semble évident, mais une considération attentive de la raison pour
  laquelle cela est vrai révèle un aperçu surprenant sur les protocoles offchain multiparties de k>2.
  Un canal de plus grande capacité supporte un plus grand nombre de distributions de richesse entre
  ses participants, donc les paiements à travers celui-ci restent faisables quand des paiements
  équivalents à travers des canaux de capacité inférieure épuiseraient le solde d'une partie. Pour
  deux participants, comme dans les canaux LN de génération actuelle, chaque satoshi supplémentaire
  donné à la capacité augmentera d'un la plage de la distribution de richesse. Cependant, dans les
  [usines à canaux][topic channel factories] et autres constructions multipartites qui permettent aux
  fonds de se déplacer offchain entre _k_ parties, chaque satoshi supplémentaire donné à la
  capacité augmente la plage des distributions de richesse de un _pour chacune des k
  parties_---augmentant exponentiellement le nombre de paiements faisables et réduisant le risque
  d'épuisement.

  Considérez un exemple du LN actuel où Alice a des canaux avec Bob et Carol, qui ont également un
  canal entre eux : {AB, AC, BC}. Chaque canal a une capacité de 1 BTC. Dans cette configuration, la
  valeur maximale qu'Alice peut contrôler (et donc envoyer ou recevoir) est de 2 BTC. La même limite
  s'applique à Bob et Carol. Ces limites s'appliqueraient également si le total de 3 BTC était utilisé
  pour recréer les trois canaux dans une usine à canaux ; cependant, si l'usine restait
  opérationnelle, une mise à jour de l'état offchain entre les trois parties pourrait annuler le
  canal entre Bob et Carol, permettant à Alice de contrôler jusqu'à 3 BTC (et donc elle pourrait
  envoyer ou recevoir jusqu'à 3 BTC). Une mise à jour d'état subséquente pourrait faire de même pour
  Bob et Carol, leur permettant également d'envoyer ou de recevoir jusqu'à 3 BTC. L'utilisation de
  protocoles offchain multiparties permet à la même quantité de capital de donner à chaque
  participant l'accès à des canaux de plus grande capacité qui sont moins susceptibles de s'épuiser.
  Moins d'épuisements et une gamme élargie de paiements faisables correspondent à un débit maximal
  plus élevé de LN, comme Pickhardt l'a écrit auparavant (voir les Bulletins [#309][news309 feasible] et
  [#325][news325 feasible]).

  Dans son post et la discussion approfondie d'Optech, Pickhardt a recherché des données (par exemple,
  de grands LSP) qui pourraient être utilisées pour aider à valider les simulations de résultats.

- **Sondage d'opinions sur les propositions de covenant :** /dev/fd0 a [publié][fd0 poll] sur la
  liste de diffusion Bitcoin-Dev un lien vers un [sondage public][wiki poll] des opinions des
  développeurs sur les propositions de [covenant][topic covenants] sélectionnées. Yuval Kogman a
  [noté][kogman poll] que les développeurs étaient invités à évaluer à la fois le "mérite technique de
  [chaque] proposition" et leur "opinion basée sur le sentiment concernant le soutien de la communauté"
  pour celle-ci, mais sans que les développeurs puissent exprimer toutes les combinaisons possibles
  des deux à travers les options limitées du sondage. Jonas Nick a [demandé][nick poll] "de séparer
  les évaluations techniques issues du soutien communautaire," et Anthony Towns [a suggéré][towns poll] de
  simplement demander aux développeurs s'ils avaient des préoccupations non résolues concernant chaque
  proposition. Nick et Towns ont recommandé séparément aux développeurs de lier des preuves et des
  arguments soutenant leurs opinions.

  Bien que la discussion ait mis en évidence des défauts dans le sondage, une démonstration de plus de
  soutien pour certaines propositions par rapport à d'autres pourrait aider les chercheurs en covenant
  à converger vers une courte liste d'idées pour que la communauté plus large puisse les examiner.

- **Pseudo-covenants basés sur des incitations :** Jeremy Rubin [a posté][rubin unfed] sur la liste
  de diffusion Bitcoin-Dev un lien vers un [document][rubin unfed paper] qu'il a rédigé sur les
  covenants assistés par oracle. Le modèle implique deux oracles : un _oracle de covenant_ et un
  _oracle d'intégrité_. L'oracle de covenant place des fonds dans un bon de fidélité et accepte de
  signer uniquement les transactions basées sur un programme renvoyant un succès. L'oracle d'intégrité
  peut saisir des fonds d'un bon en utilisant le [calcul responsable][topic acc] pour prouver qu'une
  signature a été créée pour un programme qui n'a pas renvoyé de succès. En cas de fraude, il n'y a
  aucune garantie qu'un utilisateur ayant perdu de l'argent à cause de la tromperie de l'oracle de
  covenant récupérera les fonds perdus.

  Ethan Heilman a indépendamment [posté][heilman slash] sur la liste de diffusion Bitcoin-Dev une
  construction différente qui permet à quiconque d'utiliser une preuve de fraude pour punir une
  signature incorrecte. Cependant, dans ce cas, les fonds ne sont pas saisis mais détruits. Cela
  assure que le signataire frauduleux est puni mais empêche les victimes de récupérer leur valeur
  perdue.

- **Résumés des réunions des développeurs de Bitcoin Core :** de nombreux développeurs de Bitcoin
  Core se sont rencontrés en personne en octobre, et plusieurs notes de la réunion ont maintenant été
  [publiées][coredev notes]. Les sujets de discussion incluaient l'[ajout du support payjoin][], la
  création de [plusieurs binaires][] qui communiquent entre eux, une [interface de minage][] et le
  support de [Stratum v2][], l'amélioration du [benchmarking][] et des [flamegraphs][], une [API pour
  libbitcoinkernel][], la prévention du [blocage des blocs][], des améliorations au [code RPC][]
  inspirées par Core Lightning, la reprise du [développement d'erlay][], et la [contemplation des
  covenants][].

## Bitcoin Core PR Review Club

*Dans cette section mensuelle, nous résumons une réunion récente du [Bitcoin Core PR Review
Club][], en soulignant certaines des questions et réponses importantes. Cliquez sur une question
ci-dessous pour voir un résumé de la réponse de
la réunion.*

[Suivre et utiliser tous les pairs potentiels pour la résolution d'orphelins][review club 31397] est
une PR par [glozow][gh glozow] qui améliore la fiabilité de la résolution d'orphelins en permettant
au nœud de demander les ancêtres manquants à tous les pairs au lieu de juste celui qui a annoncé
l'orphelin. Elle le fait en introduisant `m_orphan_resolution_tracker` qui est responsable de se
souvenir quels pairs sont candidats pour la résolution d'orphelins et de planifier quand faire des
demandes de résolution d'orphelins. L'approche est conçue pour être efficace en termes de bande
passante, pour ne pas être vulnérable à la censure, et pour équilibrer la charge entre les pairs.

{% include functions/details-list.md
  q0="Qu'est-ce que la résolution d'orphelins ?"
  a0="Une transaction est considérée comme orpheline lorsque le nœud n'a pas au moins une des
  transactions dont l'orphelin dépense. La résolution d'orphelins est le processus d'essayer de
  trouver ces transactions manquantes."
  a0link="https://bitcoincore.reviews/31397#l-23"

  q1="Avant cette PR, quelles sont les étapes pour la résolution d'orphelins, à partir du moment où
  nous remarquons que la transaction a des entrées manquantes ?"
  a1="Lorsqu'un nœud reçoit une transaction orpheline, il demandera la transaction parente au même
  pair qui a envoyé l'orpheline. Les autres pairs ne sont pas activement interrogés, mais peuvent
  toujours nous envoyer le parent, par exemple lorsqu'ils l'annoncent via un message INV, ou
  lorsqu'ils envoient une autre orpheline avec le même parent manquant."
  a1link="https://bitcoincore.reviews/31397#l-29"

  q2="Quelles sont les manières dont nous pouvons échouer à résoudre un orphelin avec le pair auprès
  duquel nous demandons ses parents ? Quelles sont certaines raisons pour lesquelles cela peut se
  produire, honnêtes ou non ?"
  a2="Un pair honnête peut simplement avoir été déconnecté, ou il peut avoir évincé le parent de sa
  mempool. Un pair malveillant peut simplement ne pas répondre à la demande, ou il peut envoyer un
  parent avec des données de témoin altérées, invalides, ce qui entraîne l'échec de la validation du
  parent tout en ayant l'ID de transaction attendu."
  a2link="https://bitcoincore.reviews/31397#l-49"

  q3="Comment un attaquant peut-il empêcher un nœud de télécharger un package 1p1c en exploitant le
  comportement actuel de résolution d'orphelins ?"
  a3="Un attaquant peut annoncer une orpheline altérée non sollicitée (voir question précédente). Une
  fois que la transaction orpheline altérée est acceptée dans l'orphelinat, la transaction orpheline
  honnête ne sera plus acceptée car elle a le même txid. Cela empêche le package d'être relayé.
  Alternativement, un attaquant pourrait inonder un nœud de transactions orphelines. Étant donné que
  l'orphelinat est limité en taille, et que les transactions sont évincées aléatoirement, cela
  affectera la capacité d'un nœud à télécharger des packages 1p1c."
  a3link="https://bitcoincore.reviews/31397#l-64"

  q4="Quelle est la solution de la PR au problème posé dans la question précédente ?"
  a4="Au lieu d'ajouter le parent manquant de l'orphelin au suivi de demande de transaction, la
  transaction orpheline est ajoutée au `m_orphan_resolution_tracker` nouvellement introduit. Ce suivi
  de résolution d'orphelins planifie quand la transaction parente devrait être demandée à différents
  pairs, puis ajoute ces demandes au suivi de demande de transaction régulier. Les participants ont
  suggéré et discuté d'une approche alternative qui ne nécessite pas un `m_orphan_resolution_tracker`
  supplémentaire, et cette approche sera étudiée plus avant par l'auteur."
  a4link="https://bitcoincore.reviews/31397#l-81"

  q5="Dans cette PR, quels pairs identifions-nous comme candidats potentiels pour la résolution
  d'orphelins, et pourquoi ?"
  a5="Tous les pairs qui ont annoncé une transaction qui s'est avérée être une transaction orpheline
  sont marqués comme candidats potentiels pour la résolution d'orphelins."
  a5link="https://bitcoincore.reviews/31397#l-127"

  q6="Que fait le nœud si un pair annonce une transaction qui est actuellement un orphelin à résoudre ?"
  a6="Au lieu d'ajouter la transaction au suivi m_txrequest, le pair est ajouté comme candidat à la
  résolution d'orphelins. Cela aide à prévenir des attaques telles que décrites dans la question
  précédente concernant la censure de package 1p1c."
  a6link="https://bitcoincore.reviews/31397#l-148"

  q7="Pourquoi pourrait-on préférer résoudre les orphelins avec des pairs sortants plutôt qu'entrants ?"
  a7="Les pairs sortants sont sélectionnés par le nœud et sont donc considérés comme plus fiables.
  Bien que les pairs sortants puissent être malveillants, ils sont au moins beaucoup moins
  susceptibles de cibler spécifiquement votre nœud."
  a7link="https://bitcoincore.reviews/31397#l-251"
%}

## Changements dans les services et logiciels clients

*Dans cette rubrique mensuelle, nous mettons en lumière des mises à jour intéressantes des
portefeuilles Bitcoin et des services.*

- **HWI basé sur Java publié :**
  [Lark App][larkapp github] est une application en ligne de commande pour interagir avec
  des dispositifs de signature matérielle. Elle utilise la [bibliothèque Java Lark][lark github], un
  portage de [HWI][topic hwi] pour le langage de programmation Java.

- **Jeu éducatif sur le développement Bitcoin Saving Satoshi annoncé :**
  Le site web [Saving Satoshi][saving satoshi website] propose des exercices éducatifs interactifs
  pour ceux qui sont nouveaux dans le développement Bitcoin.

- **Plugin Neovim pour le script Bitcoin :**
  Le plugin Neovim [Bitcoin script hints][bsh github] pour Rust affiche les états de la pile de script
  Bitcoin pour chaque opération dans l'éditeur.

- **Proton Wallet ajoute RBF :**
  Les utilisateurs de Proton Wallet peuvent maintenant par [RBF][topic rbf] augmenter les frais de [leurs
  transactions][proton blog].

## Questions et réponses sélectionnées de Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech
cherchent des réponses à leurs questions - ou quand nous avons quelques moments libres pour aider
les utilisateurs curieux ou confus. Dans cette rubrique mensuelle, nous mettons en lumière certaines
des questions et réponses les plus votées publiées depuis notre dernière mise à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Combien de temps Bitcoin Core stocke-t-il les chaînes forkées ?]({{bse}}124973)
  Pieter Wuille explique qu'à l'exception des nœuds Bitcoin Core fonctionnant en mode élagué, les
  blocs qu'un nœud télécharge, qu'ils soient dans la chaîne principale ou non, sont stockés
  indéfiniment.

- [Quel est l'intérêt des pools de minage solo ?]({{bse}}124926)
  Murch explique pourquoi un mineur Bitcoin pourrait utiliser un pool de minage qui ne divise pas les
  récompenses de minage entre ses participants, un _pool de minage solo_.

- [Y a-t-il un intérêt à utiliser P2TR plutôt que P2WSH si je veux seulement utiliser le chemin de script ?]({{bse}}124888)
  Vojtěch Strnad note les économies potentielles lors de l'utilisation de P2WSH mais souligne d'autres
  avantages de [P2TR][topic taproot], y compris la confidentialité, l'utilisation d'un arbre de
  scripts, et la disponibilité des [PTLCs][topic ptlc].

## Mises à jour et versions candidates

_Nouvelles mises-à-jours et candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles mises-à-jour ou d'aider à tester les versions candidates._

- [Core Lightning 24.11][] est une version de la prochaine version majeure de cette implémentation
  populaire du LN. Elle contient un nouveau plugin expérimental pour effectuer des paiements utilisant
  une sélection de route avancée; payer et recevoir des paiements pour [les offres][topic offers] est
  activé par défaut ; et de multiples améliorations ont été ajoutées au [splicing][topic splicing], en plus
  de plusieurs autres fonctionnalités et corrections de bugs.

- [BTCPay Server 2.0.4][] est une version de ce logiciel de traitement de paiements qui inclut de
  multiples nouvelles fonctionnalités, améliorations et corrections de bugs.

- [LND 0.18.4-beta.rc2][] est une version candidate pour une mise à jour mineure de cette populaire
  implémentation de LN.

- [Bitcoin Core 28.1RC1][] est une version candidate pour une mise à jour de maintenance de
  l'implémentation de nœud complet prédominante.

- [BDK 1.0.0-beta.6][] est la dernière version bêta planifiée de cette bibliothèque pour la
  construction de portefeuilles Bitcoin et d'autres applications activées par Bitcoin avant la sortie
  de `bdk_wallet` 1.0.0.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo],
[Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin
inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #31096][] supprime les restrictions sur la commande RPC `submitpackage` (voir
  le [Bulletin #272][news272 submitpackage]) qui interdisaient les paquets contenant uniquement une
  seule transaction en changeant la logique de la fonction `AcceptPackage` et en assouplissant les
  vérifications sur `submitpackage`. Bien qu'une transaction unique ne se qualifie pas techniquement
  comme un paquet sous la spécification du [relai de paquet][topic package relay], il n'y a aucune raison
  d'empêcher les utilisateurs de soumettre des transactions qui respectent les politiques du réseau en
  utilisant cette commande.

- [Bitcoin Core #31175][] supprime les pré-vérifications redondantes de la commande RPC
  `submitblock` et de `bitcoin-chainstate.cpp` qui valident si un bloc contient une transaction
  coinbase ou est un doublon, car ces vérifications sont déjà effectuées dans `ProcessNewBlock`. Ce
  changement standardise le comportement à travers les interfaces, telles que l'IPC de minage (voir
  le [Bulletin #323][news323 ipc]) et `net_processing`, pour préparer Bitcoin Core pour le projet d'API
  [libbitcoinkernel][libbitcoinkernel project]. De plus, les blocs doublons soumis avec `submitblock`
  conserveront désormais leurs données même si elles ont été précédemment élaguées et les données
  seront à nouveau élaguées lorsque le fichier de bloc est sélectionné pour l'élagage, pour être
  cohérent avec le comportement de `getblockfrompeer`.

- [Bitcoin Core #31112][] étend la fonctionnalité `CCheckQueue` pour améliorer la journalisation des
  erreurs de script pendant les conditions de validation de script multi-threadées. Auparavant, un
  rapport d'erreur détaillé n'était disponible qu'en exécutant avec `par=1` (validation de script en
  mono-thread) en raison du transfert d'informations limité entre les threads. De plus, la
  journalisation inclut maintenant des détails sur quelle entrée de transaction avait l'erreur de
  script et quel UTXO a été dépensé.

- [LDK #3446][] ajoute le support pour inclure un drapeau de [paiement trampoline][topic trampoline
  payments] sur les factures [BOLT12][topic offers]. Cela ne fournit pas un support complet pour
  l'utilisation du routage trampoline ou la fourniture d'un service de routage trampoline, mais sert à
  poser les bases pour des fonctionnalités futures. Le support pour les paiements trampoline est une
  condition préalable pour un type de [paiements asynchrones][topic async payments] que LDK prévoit de
  déployer.

- [Rust Bitcoin #3682][] ajoute plusieurs outils pour stabiliser l'interface de l'API publique pour
  les paquets `hashes`, `io`, `primitives` et `units` telles que des fichiers texte d'API pré-générés,
  un script qui génère ces fichiers texte en utilisant `cargo check-api`, un script qui interroge
  facilement ces fichiers texte d'API, et un travail CI qui compare le code de l'API et son fichier
  texte correspondant pour détecter facilement les changements non intentionnels de l'API. Cette PR
  met également à jour la documentation pour définir les attentes pour les développeurs contributeurs:
  lorsqu'ils mettent à jour un point de terminaison de l'API de ces paquets, ils doivent exécuter le
  script de génération de fichier texte.

- [BTCPay Server #5743][] introduit le concept de "transaction en attente" pour les portefeuilles
  multisig et en observation seule, qui est un [PSBT][topic psbt] qui ne nécessite pas de signature
  immédiate. La transaction collecte les signatures au fur et à mesure que les signataires se
  connectent et les fournissent, et lorsqu'il y a suffisamment de signatures, elle est diffusée. Cette
  PR marque également automatiquement les transactions comme complètes lorsqu'elles sont signées offchain,
  invalide les transactions en attente lorsque les UTXOs associés sont dépensés ailleurs, et
  permet des temps d'expiration optionnels pour éviter des taux de frais obsolètes. Ce système permet
  à un processeur de paiement de créer des transactions en attente pour des paiements en attente de
  signatures et d'annuler ou de remplacer des transactions en attente par des versions mises à jour si
  les paiements changent et que les signatures n'ont pas été collectées. La fonctionnalité activée
  était jugée possible uniquement avec des portefeuilles chauds. Ce système peut être étendu pour
  envoyer des emails lorsqu'une transaction en attente est créée pour alerter les signataires de se
  connecter.

- [BDK #1756][] ajoute une exception à `fetch_prev_txout` pour l'empêcher d'essayer de requérir les
  prevouts (sorties des transactions précédentes) des transactions coinbase, puisqu'elles n'en ont
  pas. Auparavant, ce comportement causait un crash de `bdk_electrum` et l'échec du processus de
  synchronisation ou de scan complet.

- [BIPs #1535][] fusionne [BIP348][] pour la spécification de l'opcode [OP_CHECKSIGFROMSTACK][topic
  op_checksigfromstack], qui permet de vérifier si une signature signe un message arbitraire. Il met
  une signature, un message et une clé publique sur la pile, et la signature doit correspondre à la
  fois à la clé publique et au message. C'est l'une des nombreuses propositions de [covenants][topic
  covenants].

- [BOLTs #1180][] met à jour [BOLT12][topic offers] pour spécifier l'inclusion optionnelle des
  instructions de paiement Bitcoin lisibles par l'homme [BIP353][] dans la demande de facture (voir
  le [Bulletin #290][news290 omdns]). [BLIPs #48][] met à jour [BLIP32][] (voir le [Bulletin
  #306][news306 blip32]) pour référencer la mise à jour de [BOLT12][].

## Joyeuses fêtes !

Ceci est le dernier bulletin régulier de Bitcoin Optech de l'année. Le vendredi 20 décembre,
nous publierons notre septième revue annuelle.
La publication régulière reprendra le vendredi 3 janvier.

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 15:30"
%}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31096,31175,31112,3446,3682,5743,1756,1535,1180,48" %}
[core lightning 24.11]: https://github.com/ElementsProject/lightning/releases/tag/v24.11
[lnd 0.18.4-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.4-beta.rc2
[eclair v0.11.0]: https://github.com/ACINQ/eclair/releases/tag/v0.11.0
[ldk v0.0.125]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.125
[bitcoin core 28.1RC1]: https://bitcoincore.org/bin/bitcoin-core-28.1/
[harding irrev]: https://delvingbitcoin.org/t/disclosure-irrevocable-fees-stealing-from-ln-using-revoked-commitment-transactions/1314
[pickhardt deplete]: https://delvingbitcoin.org/t/channel-depletion-ln-topology-cycles-and-rational-behavior-of-nodes/1259/6
[guidi spanning]: https://diyhpl.us/~bryan/irc/bitcoin/bitcoin-dev/linuxfoundation-pipermail/lightning-dev/2019-August/002115.txt
[news309 feasible]: /fr/newsletters/2024/06/28/#estimation-de-la-probabilite-qu-un-paiement-ln-soit-realisable
[news325 feasible]: /fr/newsletters/2024/10/18/#recherche-sur-les-limites-fondamentales-de-la-distribution
[fd0 poll]: https://gnusha.org/pi/bitcoindev/028c0197-5c45-4929-83a9-cfe7c87d17f4n@googlegroups.com/
[wiki poll]: https://en.bitcoin.it/wiki/Covenants_support
[kogman poll]: https://gnusha.org/pi/bitcoindev/CAAQdECALHHysr4PNRGXcFMCk5AjRDYgquUUUvuvwHGoeJDgZJA@mail.gmail.com/
[nick poll]: https://gnusha.org/pi/bitcoindev/941b8c22-0b2c-4734-af87-00f034d79e2e@gmail.com/
[towns poll]: https://gnusha.org/pi/bitcoindev/Z1dPfjDwioa%2FDXzp@erisian.com.au/
[rubin unfed]: https://gnusha.org/pi/bitcoindev/30440182-3d70-48c5-a01d-fad3c1e8048en@googlegroups.com/
[rubin unfed paper]: https://rubin.io/public/pdfs/unfedcovenants.pdf
[heilman slash]: https://gnusha.org/pi/bitcoindev/CAEM=y+V_jUoupVRBPqwzOQaUVNdJj5uJy3LK9JjD7ixuCYEt-A@mail.gmail.com/
[drkgry deanon]: https://github.com/GingerPrivacy/GingerWallet/discussions/116
[shinobi deanon]: https://bitcoinmagazine.com/technical/wabisabi-deanonymization-vulnerability-disclosed
[wasabi #5439]: https://github.com/WalletWasabi/WalletWasabi/issues/5439
[ajout du support payjoin]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/payjoin
[plusieurs binaires]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/multiprocess-binaries
[interface de minage]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/mining-interface
[stratum v2]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/stratumv2
[benchmarking]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/leveldb
[flamegraphs]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/flamegraphs
[API pour libbitcoinkernel]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/kernel
[blocage des blocs]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/block-stalling
[code RPC]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/rpc-discussion
[développement d'erlay]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/erlay
[contemplation des covenants]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/covenants
[coredev notes]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10
[dd deplete]: /en/podcast/2024/12/12/
[bdk 1.0.0-beta.6]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.6
[btcpay server 2.0.4]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.0.4
[larkapp github]: https://github.com/sparrowwallet/larkapp
[lark github]: https://github.com/sparrowwallet/lark
[saving satoshi website]: https://savingsatoshi.com/
[bsh github]: https://github.com/taproot-wizards/bitcoin-script-hints.nvim
[proton blog]: https://proton.me/support/speed-up-bitcoin-transactions
[news272 submitpackage]: /fr/newsletters/2023/10/11/#bitcoin-core-27609
[news323 ipc]: /fr/newsletters/2024/10/04/#bitcoin-core-30510
[libbitcoinkernel project]: https://github.com/bitcoin/bitcoin/issues/24303
[news290 omdns]: /en/newsletters/2024/02/21/#dns-based-human-readable-bitcoin-payment-instructions
[news306 blip32]: /fr/newsletters/2024/06/07/#blips-32
[review club 31397]: https://bitcoincore.reviews/31397
[gh glozow]: https://github.com/glozow
