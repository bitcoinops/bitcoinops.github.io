---
title: 'Bulletin Hebdomadaire Bitcoin Optech #295'
permalink: /fr/newsletters/2024/03/27/
name: 2024-03-27-newsletter-fr
slug: 2024-03-27-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine annonce la divulgation d'une attaque gaspillant de la bande passante
affectant Bitcoin Core et les nœuds associés, décrit plusieurs améliorations à l'idée de parrainage
des frais de transaction, et résume une discussion sur l'utilisation des données en temps réel du
mempool pour améliorer l'estimation du taux de frais de Bitcoin Core. Sont également incluses nos
rubriques habituelles avec des questions et réponses populaires
de la communauté Bitcoin Stack Exchange, des annonces de nouvelles versions et
versions candidates, ainsi que les changements apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Divulgation de l'attaque de relais gratuit :** une attaque gaspillant de la bande passante a été
  [décrite][todd free relay] sur la liste de diffusion Bitcoin-Dev. En résumé, Mallory diffuse une
  version d'une transaction à Alice et une version différente de la transaction à Bob. Les
  transactions sont conçues de sorte que Bob n'acceptera pas la version d'Alice comme un remplacement
  [RBF][topic rbf] et Alice n'acceptera pas la version de Bob. Mallory envoie ensuite à Alice un
  remplacement qu'elle acceptera mais pas Bob. Alice relaie le remplacement à Bob, consommant leur
  bande passante mutuelle, mais Bob le rejette, résultant en un gaspillage de la bande passante de
  relais (appelé [relais gratuit][topic free relay]). Mallory peut répéter cela plusieurs fois jusqu'à
  ce qu'une transaction soit finalement confirmée, chaque cycle voyant Alice accepter le remplacement,
  utiliser de la bande passante pour l'envoyer à Bob, et Bob le rejeter. L'effet de l'attaque peut
  être multiplié par Alice ayant plusieurs pairs de type Bob qui rejettent tous les remplacements et
  Mallory envoyant plusieurs transactions spécialement construites de ce type en parallèle.

  L'attaque est limitée par les coûts de frais que Mallory paiera lorsque une version de ses
  transactions sera finalement confirmée, bien que la description de l'attaque note que cela peut être
  essentiellement nul si Mallory prévoyait de toute façon d'envoyer une transaction. La quantité
  maximale de bande passante qui peut être gaspillée est limitée par les limites de relais de
  transaction existantes de Bitcoin Core, bien qu'il soit possible que la réalisation de cette attaque
  de nombreuses fois en parallèle puisse retarder la propagation de transactions légitimes non confirmées.

  La description mentionne également un autre type bien connu de gaspillage de bande passante de nœud,
  où un utilisateur diffuse un ensemble de transactions volumineuses et travaille ensuite avec un
  mineur pour créer un bloc qui contient une transaction relativement petite qui entre en conflit avec
  toutes les transactions relayées. Par exemple, une transaction de 29 000 vbytes pourrait retirer
  environ 200 mégaoctets de transactions de la mempool de chaque nœud complet relayant. La description
  soutient que l'existence d'attaques permettant de gaspiller de la bande passante signifie qu'il
  devrait être raisonnable de permettre volontairement une certaine quantité de relais gratuit, comme
  en activant des propositions telles que le remplacement par taux de frais (voir le [Bulletin
  #288][news288 rbfr]).

- **Améliorations du parrainage des frais de transaction :** Martin Habovštiak a [posté][habovstiak
  boost] sur la liste de diffusion Bitcoin-Dev une idée permettant à une transaction de booster la
  priorité d'une transaction non liée. Fabian Jahr a [noté][jahr boost] que le fondamental
  de l'idée semble être très similaire au [parrainage des frais de transaction][topic fee sponsorship],
  qui a été proposé en 2020 par Jeremy Rubin (voir le [Bulletin #116][news116 sponsor]). Dans la
  proposition originale de Rubin, la _transaction de parrainage_ s'engageait envers les _transactions
  boostées_ en utilisant un script de sortie de valeur nulle, ce qui utilise environ <!-- 8 + 1 + 1 +
  32 (nAmount + taille sPK + OP_VER + txid); je dis "environ" car il a également été discuté
  d'utiliser un engagement d'outpoint --> 42 vbytes pour un seul parrainage et environ 32 octets pour
  chaque parrainage supplémentaire. Dans la version de Habovštiak, la transaction de parrainage
  s'engage envers la transaction boostée en utilisant l'[annexe taproot][topic annex], ce qui
  utilise environ <!-- 32 / 4; pourrait avoir un surcoût de codage et pourrait également finir par
  utiliser un outpoint à la place --> 8 vbytes pour un seul parrainage et 8 vbytes pour chaque
  parrainage supplémentaire.

  Après avoir entendu parler de l'idée de Habovštiak, David Harding [a posté][harding sponsor] sur
  Delving Bitcoin une amélioration de l'efficacité qu'il et Rubin avaient précédemment développée en
  janvier. La transaction de parrainage s'engage envers la transaction boostée en utilisant le message
  d'engagement de signature, qui n'est jamais publié on-chain, donc aucun espace de bloc n'est
  utilisé pour un seul engagement. Pour permettre cela, la transaction de parrainage doit apparaître
  dans les blocs et les messages de [relais de paquets][topic package relay] immédiatement après la
  transaction boostée, permettant aux vérificateurs de nœuds complets d'inférer le txid de la
  transaction boostée lorsqu'ils vérifient la transaction de parrainage.

  Pour les cas où un bloc peut contenir plusieurs transactions de parrainage qui s'engagent chacune
  envers certaines des mêmes transactions boostées, il n'est pas possible de simplement avoir une
  série de transactions boostées apparaissant immédiatement avant leurs parrains, donc des engagements
  entièrement inférables ne sont pas une option. Harding décrit une alternative simple qui n'utilise
  que 0.5 vbytes par transaction boostée ; Anthony Towns [améliore][towns sponsor] cela avec une
  version qui n'utiliserait jamais plus de 0.5 vbytes par boost et utiliserait moins d'espace dans la
  plupart des cas.

  Habovštiak et Harding notent tous deux le potentiel pour l'externalisation : quiconque prévoit de
  diffuser une transaction de toute façon (ou qui a une transaction non confirmée qu'il est prêt à
  mettre à jour avec [RBF][topic rbf]) peut augmenter son taux de frais et booster une autre
  transaction à un coût insignifiant de 0.5 vbytes ou moins par boost ; pour comparaison, 0.5 vbytes
  représente environ 0.3% d'une transaction P2TR à 1 entrée, 2 sorties. Malheureusement, ils
  avertissent tous les deux qu'il n'y a pas de moyen pratique de payer sans confiance un tiers pour un
  boost ; cependant, Habovštiak souligne que quiconque paie via LN recevrait [une preuve de
  paiement][topic proof of payment] et pourrait donc potentiellement prouver une tromperie.

  Towns note en outre que les parrains semblent compatibles avec la conception proposée pour [le pool
  de mémoire tampon en cluster][topic cluster mempool], que les versions les plus efficaces de
  parrainage présentent quelques défis légers pour la mise en cache de la validité des transactions,
  et conclut avec un tableau montrant l'espace de bloc relatif consommé par diverses techniques
  actuelles et proposées de hausse des frais. À 0.5 vbytes ou moins par boost, les versions les plus
  efficaces de parrainage des frais est seulement surpassée par les 0.0 vbytes
  utilisés dans le meilleur cas avec RBF et en payant les mineurs [hors bande][topic out-of-band
  fees]. Parce que le parrainage des frais permet une augmentation dynamique des frais et est presque
  aussi efficace que de payer les mineurs hors bande, cela pourrait résoudre une préoccupation majeure
  avec les protocoles qui dépendent des [frais exogènes][topic fee sourcing].

  Dans une [discussion continue][daftuar sponsor] peu avant la publication de ce bulletin, Suhas
  Daftuar a exprimé des préoccupations selon lesquelles les sponsors pourraient introduire des
  problèmes qui ne sont pas facilement adressés par le cluster de mempool et qui pourraient créer des
  problèmes pour les utilisateurs qui n'avaient pas besoin de sponsors, indiquant que le parrainage
  (s'il est jamais ajouté à Bitcoin) devrait seulement être disponible pour les transactions qui
  choisissent de l'autoriser.

- **Estimation du taux de frais basée sur le Mempool :** Abubakar Sadiq Ismail a [posté][ismail
  fees] sur Delving Bitcoin concernant l'amélioration de l'estimation du taux de frais de Bitcoin Core
  en utilisant les données du mempool local d'un nœud. Actuellement, Bitcoin Core génère des
  estimations en enregistrant la hauteur de bloc lorsque chaque transaction non confirmée est reçue,
  la hauteur de bloc lorsqu'elle est confirmée, et son taux de frais. Lorsque toutes ces informations
  sont connues, la différence entre la hauteur de réception et la hauteur de confirmation est utilisée
  pour mettre à jour une moyenne mobile pondérée exponentiellement pour un seau qui représente une
  gamme de taux de frais. Par exemple, une transaction qui prend 100 blocs pour être confirmée avec un
  taux de frais de 1.1 sat/vbyte sera incorporée dans la moyenne pour le seau de 1 sat/vbyte.

  Un avantage de cette approche est sa résistance à la manipulation : toutes les transactions doivent
  être à la fois relayées (ce qui signifie qu'elles sont disponibles pour tous les mineurs) et
  confirmées (ce qui signifie qu'elles ne peuvent pas violer les règles de consensus). Un inconvénient
  est qu'elle ne se met à jour qu'une fois par bloc et peut être très en retard par rapport à d'autres
  estimations qui utilisent des informations en temps réel du mempool.

  Ismail a repris une [discussion précédente][bitcoin core #27995] sur l'incorporation des données du
  mempool dans les estimations de taux de frais, écrit un code préliminaire, et réalisé une analyse
  montrant comment l'algorithme actuel et un nouvel algorithme se comparent (sans inclure certaines
  vérifications de sécurité). Une [réponse][harding fees] au fil de discussion a également fait
  référence à [des recherches précédentes][alm fees] sur ce sujet par Kalle Alm et a mené à une
  discussion sur le fait de savoir si les informations du mempool devraient être utilisées pour à la
  fois augmenter et diminuer les estimations de taux de frais, ou si elles devraient seulement être
  utilisées pour diminuer les estimations. L'avantage de faire les deux est que cela rend globalement
  les estimations plus utiles ; l'avantage de ne diminuer les estimations qu'en utilisant les données
  du mempool (tout en augmentant les estimations uniquement à l'aide de l'estimation basée sur la
  confirmation existante) est que cela pourrait être plus résistant à la manipulation et aux boucles
  de rétroaction positives.

  La discussion était en cours au moment de la rédaction de ce texte.

## Questions et réponses sélectionnées de Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech cherchent des réponses à leurs
  questions, ou lorsque nous avons quelques moments libres pour aider les utilisateurs curieux ou confus. Dans cette rubrique
  mensuelle, nous mettons en évidence certaines des questions et réponses les plus votées publiées depuis notre dernière mise
  à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aa
nswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Quels sont les risques de l'exécution d'un nœud pré-SegWit (0.12.1)?]({{bse}}122211)
  Michael Folkson, Vojtěch Strnad et Murch énumèrent les inconvénients de l'exécution de Bitcoin Core
  0.12.1 pour un utilisateur individuel, incluant un risque plus élevé d'accepter une transaction ou
  un bloc invalide, une vulnérabilité accrue aux attaques de double dépense, une plus grande
  dépendance envers les autres pour effectuer une validation de consensus mise à jour, une validation
  de bloc beaucoup plus lente, l'absence de nombreuses améliorations de performance, l'incapacité
  d'utiliser [compact block relay][topic compact block relay], ne pas relayer environ 95% des
  transactions non confirmées actuelles, une [estimation de frais][topic fee
  estimation] moins précise, et une vulnérabilité aux problèmes de sécurité corrigés dans les versions
  précédentes. Les utilisateurs de portefeuille de la version 0.12.1 manqueraient également les
  développements autour de [miniscript][topic miniscript], les portefeuilles [descriptor][topic
  descriptors], et les économies de frais ainsi que les capacités de script supplémentaires activées
  par [segwit][topic segwit], [taproot][topic taproot], et les [signatures schnorr][topic schnorr
  signatures]. Les effets sur le réseau Bitcoin si Bitcoin Core 0.12.1 était plus largement adopté
  pourraient inclure : une plus grande chance que des blocs invalides soient acceptés par le réseau et
  le risque de reorg associé, une pression vers la centralisation des mineurs due au risque accru de
  blocs obsolètes, et des récompenses de minage diminuées pour les mineurs utilisant cette version.

- [Quand est-ce que OP_RETURN est moins cher que OP_FALSE OP_IF?]({{bse}}122321)
  Vojtěch Strnad détaille les surcoûts associés à l'incorporation de données basée sur `OP_RETURN` et
  l'incorporation basée sur `OP_FALSE` `OP_IF`, concluant que "`OP_RETURN` est moins cher pour des
  données de moins de 143 octets".

- [Pourquoi BIP-340 utilise-t-il secp256k1?]({{bse}}122268)
  Pieter Wuille explique la raison du choix de secp256k1 plutôt qu'Ed25519 pour les signatures schnorr
  de [BIP340][], notant la "réutilisabilité de l'infrastructure existante de dérivation de clé" et le
  "fait de ne pas changer les hypothèses de sécurité" comme raisons de ce choix.

- [Quels critères Bitcoin Core utilise-t-il pour créer des modèles de blocs?]({{bse}}122216)
  Murch explique l'algorithme actuel de Bitcoin Core basé sur le taux de frais de l'ensemble des
  ancêtres pour la sélection des transactions pour un candidat de bloc et mentionne le travail en
  cours sur le [memool en cluster][topic cluster mempool] qui offre diverses améliorations.

- [Comment fonctionne le champ initialblockdownload dans le RPC getblockchaininfo?]({{bse}}122169)
  Pieter Wuille note les deux conditions qui doivent se produire après le démarrage du nœud pour que
  `initialblockdownload` devienne faux :

  1. "La chaîne actuellement active a au moins autant de travail cumulatif (PoW) que la constante
     codée en dur dans le logiciel"
  2. "Le timestamp du sommet actuellement actif n'est pas plus ancien que 24 heures"

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets d’infrastructure
Bitcoin. Veuillez envisager de passer aux nouvelles versions ou d’aider à tester
les versions candidates.*

- [Bitcoin Core 26.1rc2][] est un candidat à la sortie pour une version de maintenance de
  l'implémentation de nœud complet prédominante du réseau.

- [Bitcoin Core 27.0rc1][] est un candidat à la sortie pour la prochaine version majeure de
  l'implémentation de nœud complet prédominante du réseau.
  Voici un bref aperçu des [sujets de test suggérés][bcc testing] et une réunion programmée du
  [Bitcoin Core PR Review Club][] dédiée aux tests aujourd'hui (27 mars) à 15:00 UTC.

## Changements notables dans le code et la documentation

_Modifications notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core
lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust
Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo], [Propositions
d'Amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Inquisition
Bitcoin][bitcoin inquisition repo], et [BINANAs][binana repo]._

*Note : les commits sur Bitcoin Core mentionnés ci-dessous s'appliquent à sa branche de
développement principale et donc ces changements ne seront probablement pas publiés avant environ
six mois après la sortie de la version à venir 27.*

- [Bitcoin Core #28950][] met à jour le RPC `submitpackage` avec des arguments pour `maxfeerate` et
  `maxburnamount` qui termineront l'appel en échec si le package fourni a un taux de frais agrégé
  au-dessus du maximum indiqué ou envoie plus que le montant indiqué à un modèle bien connu pour une
  sortie non dépensable.

- [LND #8418][] commence à interroger son client du protocole Bitcoin connecté pour les valeurs
  `feefilter` [BIP130][] de ses pairs de nœuds complets. Le message `feefilter` permet à un nœud
  d'informer ses pairs connectés du taux de frais minimum qu'il acceptera pour relayer une
  transaction. LND utilisera désormais cette information pour éviter d'envoyer des transactions avec
  un taux de frais trop bas. Seules les valeurs `feefilter` des pairs sortants sont utilisées, car ce
  sont les pairs auxquels le nœud de l'utilisateur a choisi de se connecter et ils sont donc moins
  susceptibles d'être contrôlés par des attaquants que les pairs entrants qui ont demandé une
  connexion.

- [LDK #2756][] ajoute la prise en charge pour inclure un paquet de [routage trampoline][topic
  trampoline payments] dans ses messages. Cela ne fournit pas un support complet pour utiliser le
  routage trampoline ou fournir des services de routage trampoline, mais cela facilite l'utilisation
  d'autres codes pour accomplir cela avec LDK.

- [LDK #2935][] commence à prendre en charge l'envoi de [paiements keysend][topic spontaneous
  payments] vers des [chemins masqués][topic rv routing]. Les paiements keysend sont des paiements
  inconditionnels envoyés sans facture. Les chemins masqués cachent les derniers sauts du chemin de
  paiement au dépensier. Les chemins masqués sont généralement encodés dans une facture, donc ils ne
  sont généralement pas combinés avec des paiements keysend, mais ils peuvent avoir du sens lorsqu'un
  fournisseur de services Lightning (LSP) ou un autre nœud souhaite fournir une facture générique pour
  un destinataire particulier sans révéler l'ID du nœud du destinataire.

- [LDK #2419][] ajoute une machine à états pour gérer la [construction de transaction
  interactive][topic dual funding], une dépendance pour les canaux à double financement et
  le [splicing][topic splicing].

- [Rust Bitcoin #2549][] apporte divers changements aux API pour travailler avec des [verrouillages
  temporels relatifs][topic timelocks].

- [BTCPay Server #5852][] ajoute le support pour le scan des codes QR animés BBQr (voir le [Bulletin
  #281][news281 bbqr]) pour les [PSBT][topic psbt].

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28950,8418,2756,2935,2419,2549,5852,27995" %}
[bitcoin core 26.1rc2]: https://bitcoincore.org/bin/bitcoin-core-26.1/
[Bitcoin Core 27.0rc1]: https://bitcoincore.org/bin/bitcoin-core-27.0/test.rc1/
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/27.0-Release-Candidate-Testing-Guide
[news281 bbqr]: /fr/newsletters/2023/12/13/#annonce-du-schema-d-encodage-bbqr
[todd free relay]: https://gnusha.org/pi/bitcoindev/Zfg%2F6IZyA%2FiInyMx@petertodd.org/
[news288 rbfr]: /fr/newsletters/2024/02/07/#proposition-de-remplacement-par-feerate-pour-echapper-au-pinning
[habovstiak boost]: https://gnusha.org/pi/bitcoindev/CALkkCJZWBTmWX_K0+ERTs2_r0w8nVK1uN44u-sz5Hbb-SbjVYw@mail.gmail.com/
[jahr boost]: https://gnusha.org/pi/bitcoindev/45ghFIBR0JCc4INUWdZcZV6ibkcoofy4MoQP_rQnjcA4YYaznwtzSIP98QvIOjtcnIdRQRt3jCTB419zFa7ZNnorT8Xz--CH4ccFCDv9tv4=@protonmail.com/
[harding sponsor]: https://delvingbitcoin.org/t/improving-transaction-sponsor-blockspace-efficiency/696
[news116 sponsor]: /en/newsletters/2020/09/23/#transaction-fee-sponsorship
[towns sponsor]: https://delvingbitcoin.org/t/improving-transaction-sponsor-blockspace-efficiency/696/5
[ismail fees]: https://delvingbitcoin.org/t/mempool-based-fee-estimation-on-bitcoin-core/703
[harding fees]: https://delvingbitcoin.org/t/mempool-based-fee-estimation-on-bitcoin-core/703/2
[alm fees]: https://scalingbitcoin.org/stanford2017/Day2/Scaling-2017-Optimizing-fee-estimation-via-the-mempool-state.pdf
[daftuar sponsor]: https://delvingbitcoin.org/t/improving-transaction-sponsor-blockspace-efficiency/696/6
