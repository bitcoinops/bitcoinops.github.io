---
title: 'Bulletin Hebdomadaire Bitcoin Optech #281'
permalink: /fr/newsletters/2023/12/13/
name: 2023-12-13-newsletter-fr
slug: 2023-12-13-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume une discussion sur le griefing des annonces de liquidité et inclut nos sections régulières
concernant les questions et réponses populaires sur le Bitcoin Stack Exchange, les nouvelles versions et
les versions candidates, et les changements apportés aux principaux logiciels
de l'infrastructure Bitcoin.

## Nouvelles

- **Discussion sur le griefing des annonces de liquidité :** Bastien Teinturier a [posté][teinturier liqad] sur la liste de diffusion
  Lightning-Dev à propos d'un problème potentiel avec les timelocks sur les [canaux à financement double][topic dual funding] créés à
  partir des [annonces de liquidité][topic liquidity advertisements]. Cela a également été mentionné précédemment dans le [Récapitulatif
  n°279][recap279 liqad]. Par exemple, Alice annonce qu'elle est prête, moyennant des frais, à engager 10 000 sats de ses fonds dans un
  canal pendant 28 jours. Le timelock de 28 jours empêche Alice de simplement fermer le canal après avoir reçu le paiement et d'utiliser
  ses fonds à d'autres fins.

  Poursuivant l'exemple, Bob ouvre le canal avec une contribution supplémentaire de 100 000 000 sats (1 BTC) de ses fonds. Il envoie
  ensuite presque tous ses fonds à travers le canal. Maintenant, le solde d'Alice dans le canal n'est pas de 10 000 sats pour lesquels
  elle a reçu des frais, mais presque 10 000 fois plus élevé que cette somme. Si Bob est malveillant, il n'autorisera pas ces fonds à
  se déplacer à nouveau avant l'expiration du timelock de 28 jours auquel Alice s'est engagée.

  Une atténuation suggérée par Teinturier et discutée par lui-même et d'autres consistait à n'appliquer le timelock qu'à la
  contribution de liquidité (par exemple, seulement les 10 000 sats d'Alice). Cela introduit des complexités et des inefficacités,
  bien que cela puisse résoudre le problème. Une alternative proposée par Teinturier était simplement de supprimer le timelock (ou de
  le rendre facultatif) et de laisser les acheteurs de liquidité prendre le risque que les fournisseurs puissent fermer les canaux
  peu de temps après avoir reçu leurs frais de liquidité. Si les canaux ouverts via des annonces de liquidité génèrent généralement
  des revenus de frais de transfert importants, il y aurait une incitation à les maintenir ouverts.

## Modifications apportées aux services et aux logiciels clients

*Dans cette rubrique mensuelle, nous mettons en évidence les mises à jour
intéressantes des portefeuilles et services Bitcoin.*

- **Lancement d'un pool de minage Stratum v2 :**
  [DEMAND][demand website] est un pool de minage construit à partir de l'[implémentation de référence Stratum v2][news247 sri]
  permettant initialement le minage en solo, avec le minage en pool prévu pour l'avenir.

- **Annonce de l'outil de simulation du réseau Bitcoin warnet :**
  Le [logiciel warnet][warnet github] permet de spécifier des topologies de nœuds, d'exécuter des scénarios scriptés sur ce réseau et
  de surveiller et analyser les comportements qui en résultent.

- **Publication d'un client Payjoin pour Bitcoin Core :**
  Le [payjoin-cli][] est un projet en Rust qui ajoute des fonctionnalités d'envoi et de réception de [payjoin][topic payjoin] en ligne
  de commande pour Bitcoin Core.

- **Appel aux horodatages d'arrivée des blocs par la communauté :**
  Un contributeur au référentiel [Bitcoin Block Arrival Time Dataset][block arrival github] a appelé les opérateurs de nœuds à soumettre
  leurs horodatages d'arrivée de bloc à des fins de recherche. Il existe un référentiel similaire pour collecter des [données sur les
  blocs obsolètes][stale block github].

- **Envoy 1.4 publié :**
  La version 1.4 du portefeuille Bitcoin Envoy ajoute notamment la [gestion des pièces][topic coin selection] et l'[étiquetage des
  portefeuilles][topic wallet labels] (BIP329 à venir), ainsi que d'autres fonctionnalités.

- **Annonce du schéma d'encodage BBQr :**
  Le [schéma][bbqr github] peut encoder efficacement des fichiers plus volumineux, tels que des [PSBT][topic psbt], en une série de
  QR animés pour une utilisation dans des configurations de portefeuille hors ligne.

- **Zeus v0.8.0 publié :**
  La version v0.8.0 de Zeus contient un nœud LND intégré, un support supplémentaire pour les [canaux zero conf][topic zero-conf channels]
  et les canaux taproot simples, entre autres modifications.

## Sélection de Q&R du Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs
d'Optech cherchent des réponses à leurs questions---ou lorsque nous avons quelques moments
libres pour aider les utilisateurs curieux ou confus. Dans cette rubrique mensuelle, nous
mettons en avant certaines des questions et réponses les plus appréciées, postées depuis
notre dernière mise à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aa
nswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Quelles sont toutes les règles liées à l'augmentation des frais CPFP ?]({{bse}}120853)
  Pieter Wuille souligne que contrairement à la technique d'augmentation des frais [RBF][topic rbf] qui a une liste de règles de
  politique associées, la technique d'augmentation des frais [CPFP][topic cpfp] n'a pas de règles de politique supplémentaires.

- [Comment est calculé le nombre total de transactions de remplacement RBF ?]({{bse}}120823)
  Murch et Pieter Wuille présentent quelques exemples de remplacements RBF dans le contexte de la règle 5 de [BIP125][] : "Le nombre
  de transactions d'origine à remplacer et de leurs transactions descendantes qui seront supprimées de la mempool ne doit pas dépasser
  un total de 100 transactions". Les lecteurs peuvent également être intéressés par la [réunion du PR Review Club][review club 25228]
  sur l'ajout du test de cas de la règle 5 de BIP-125 avec la mempool par défaut.

- [Quels types de RBF existent et lequel Bitcoin Core prend-il en charge et utilise-t-il par défaut ?]({{bse}}120749)
  Murch fournit une partie de l'historique des remplacements de transactions de Bitcoin Core et, dans une [question
  connexe]({{bse}}120773), un résumé des règles de remplacement RBF et des liens vers la documentation de Bitcoin Core sur les
  [remplacements de mempool][bitcoin core mempool replacements] et les idées d'un développeur pour [améliorer le
  RBF][glozow rbf improvements].

- [Quel est le problème du bloc 1 983 702 ?]({{bse}}120834)
  Antoine Poinsot donne un aperçu des problèmes qui ont conduit à la restriction des txids en double par [BIP30][] et à l'obligation
  d'inclure le numéro de bloc par [BIP34][] à la hauteur de bloc actuelle dans le champ coinbase. Il souligne ensuite qu'il existe de
  nombreux blocs dont le contenu du champ coinbase correspond par hasard au préfixe de hauteur obligatoire d'un bloc ultérieur. Le bloc
  1 983 702 étant le premier pour lequel il serait pratiquement possible de répéter la transaction coinbase du bloc précédent. Dans une
  [question connexe]({{bse}}120836), Murch et Antoine Poinsot évaluent cette possibilité plus en détail. Voir également le [Bulletin
  #182][news182 block1983702].

- [À quoi servent les fonctions de hachage dans Bitcoin ?]({{bse}}120418)
  Pieter Wuille liste plus de trente instances différentes à travers les règles de consensus,
  le protocole pair-à-pair, les détails de mise en œuvre du portefeuille et du nœud qui utilisent
  pas moins de 10 fonctions de hachage différentes.

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets d’infrastructure Bitcoin.
 Veuillez envisager de passer aux nouvelles versions ou d’aider à tester les versions candidates.*

- [LND 0.17.3-beta][] est une version qui contient plusieurs corrections de bugs,
  y compris une réduction de la mémoire lorsqu'elle est utilisée avec le
  backend Bitcoin Core.

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Interface de portefeuille matériel (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo],
[Propositions d'amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo], et
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [LDK #2685][] ajoute la possibilité d'obtenir des données de chaîne de blocs à partir d'un serveur de style Electrum.

- [Libsecp256k1 #1446][] supprime une partie du code d'assemblage x86_64 du
  projet, en passant à l'utilisation du code en langage C existant qui a toujours
  été utilisé pour d'autres plates-formes. Le code d'assemblage a été optimisé pour des humains
  il y a plusieurs années pour améliorer les performances, mais entre-temps, les compilateurs
  se sont améliorés et les versions récentes de GCC et LLVM (clang) produisent maintenant
  un code encore plus performant.

- [BTCPay Server #5389][] ajoute la prise en charge de la configuration de portefeuille multisig
  sécurisé [BIP129][] (voir le [Bulletin #136][news136 bip129]). Cela permet à permis à
  BTCPay server d'interagir avec plusieurs portefeuilles logiciels et appareils de signature matériels
  dans le cadre d'une procédure simple de configuration multisig coordonnée.

- [BTCPay Server #5490][] commence à utiliser par défaut les [estimations de frais][ms fee api] de
  [mempool.space][] avec une solution de secours sur les estimations de frais du
  nœud local Bitcoin Core. Les développeurs commentant la PR ont noté
  qu'ils estimaient que les estimations de frais de Bitcoin Core ne réagissent pas rapidement aux
  changements dans le mempool local. Pour une discussion précédente sur les défis liés à l'amélioration de l'exactitude de l'estimation
  des frais, voir [Bitcoin Core #27995][].

## Joyeuses fêtes !

Ceci est le dernier bulletin hebdomadaire de Bitcoin Optech de l'année. Le
mercredi 20 décembre, nous publierons notre sixième bulletin annuel rétrospectif.
La publication régulière reprendra le mercredi 3 janvier.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2685,5389,5490,1446,27995" %}
[LND 0.17.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.3-beta
[teinturier liqad]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-December/004227.html
[ms fee api]: https://mempool.space/docs/api/rest#get-recommended-fees
[mempool.space]: https://mempool.space/
[news136 bip129]: /en/newsletters/2021/02/17/#securely-setting-up-multisig-wallets
[recap279 liqad]: /en/podcast/2023/11/30/#update-to-the-liquidity-ads-specification-transcript
[news182 block1983702]: /en/newsletters/2022/01/12/#bitcoin-core-23882
[demand website]: https://dmnd.work/
[news247 sri]: /fr/newsletters/2023/04/19/#annonce-de-la-mise-a-jour-de-la-mise-en-oeuvre-de-reference-de-stratum-v2
[warnet github]: https://github.com/bitcoin-dev-project/warnet
[warnet scenarios]: https://github.com/bitcoin-dev-project/warnet/blob/main/docs/scenarios.md
[warnet monitoring]: https://github.com/bitcoin-dev-project/warnet/blob/main/docs/monitoring.md
[payjoin-cli]: https://github.com/payjoin/rust-payjoin/tree/master/payjoin-cli
[block arrival github]: https://github.com/bitcoin-data/block-arrival-times
[b10c tweet]: https://twitter.com/0xb10c/status/1732826609260872161
[stale block github]: https://github.com/bitcoin-data/stale-blocks
[envoy v1.4.0]: https://github.com/Foundation-Devices/envoy/releases/tag/v1.4.0
[bbqr github]: https://github.com/coinkite/BBQr
[zeus v0.8.0]: https://github.com/ZeusLN/zeus/releases/tag/v0.8.0
[review club 25228]: https://bitcoincore.reviews/25228
[bitcoin core mempool replacements]: https://github.com/bitcoin/bitcoin/blob/master/doc/policy/mempool-replacements.md
[glozow rbf improvements]: https://gist.github.com/glozow/25d9662c52453bd08b4b4b1d3783b9ff
