---
title: 'Bulletin Hebdomadaire Bitcoin Optech #289'
permalink: /fr/newsletters/2024/02/14/
name: 2024-02-14-newsletter-fr
slug: 2024-02-14-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---

Le bulletin de cette semaine résume les idées d'amélioration du relai après le déploiement du mempool en cluster, décrit les résultats
de recherches sur les topologies et les tailles des sorties d'ancrage de style LN en 2023, annonce un nouvel hôte pour la liste de
diffusion Bitcoin-Dev et encourage les lecteurs à célébrer la Journée du logiciel libre en remerciant les contributeurs de logiciels
libres. Nous incluons également nos sections habituelles résumant une réunion du Bitcoin Core PR Review Club et décrivant les changements notables apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Idées d'amélioration du relais après le déploiement du mempool en cluster :**
  Gregory Sanders [a posté][sanders future] sur Delving Bitcoin plusieurs
  idées permettant aux transactions individuelles d'opter pour certaines politiques de mempool après la mise en place complète,
  le test et le déploiement du [mempool en cluster][topic cluster mempool]. Ces améliorations s'appuient sur les fonctionnalités du
  [relais de transaction v3][topic v3 transaction relay] en assouplissant certaines de ses règles qui pourraient ne plus être nécessaires
  et en ajoutant l'exigence qu'une transaction (ou un [paquet][topic package relay] de transactions) paie un taux de frais qui les rendra
  probablement extraites dans le prochain bloc ou les deux prochains blocs.

- **Que se serait-il passé si les règles v3 avaient été appliquées aux sorties d'ancrage il y a un an ?**
  Suhas Daftuar [a posté][daftuar retrospective] sur Delving Bitcoin à propos
  de ses recherches sur l'idée d'appliquer automatiquement la politique de relais de transaction v3 aux transactions de confirmation
  et de modification des frais de style LN [anchors-style][topic anchor outputs] (voir le [Bulletin #286][news286 imbued] pour la
  proposition sous-jacente _imbued v3_). En résumé, il a enregistré 14 124 transactions en 2023 qui ressemblaient à des dépenses
  d'ancrage. Parmi celles-ci :

  - Environ 94% <!-- (14124 - 856) / 14124 --> auraient réussi selon les règles v3.

  - Environ 2,1% <!-- 302/14124 --> avaient plus d'un parent (par exemple, des
    tentatives de dépenses [CPFP][topic cpfp]). Certains portefeuilles LN le
    font pour des raisons d'efficacité lors de la fermeture de plusieurs canaux
    en peu de temps. Ils devraient désactiver ce comportement si les sorties de style ancrage devaient être dotées de propriétés v3.

  - Environ 1,8% <!-- 251/14124 --> n'étaient pas le premier enfant du parent. En utilisant la proposition pour _imbued v3_, le deuxième
    enfant pourrait remplacer le premier enfant dans un [paquet][topic package relay] (voir le [Bulletin #287][news287 kindred]).

  - Environ 1,2% <!-- 175/14124 --> étaient apparemment les petits-enfants de la transaction de confirmation, c'est-à-dire des dépenses
    de la dépense de la sortie d'ancrage. Les portefeuilles LN pourraient le faire pour diverses raisons, de la fermeture de plusieurs
    canaux d'ancrage en séquence à l'ouverture de nouveaux canaux avec leur monnaie rendue lors de la fermeture de l'ancrage. Les
    portefeuilles LN ne pourraient pas utiliser ce comportement si les sorties de style ancrage étaient dotées de propriétés v3.

  - Environ 1,2% <!-- 173 / 14124 --> n'ont jamais été exploitées et n'ont pas été analysées plus en détail.

  - Environ 0,1% <!-- 19/14124 --> ont dépensé une sortie non confirmée non liée, ce qui a entraîné une dépense d'ancrage ayant plus
    d'un parent autorisé. Le développeur Bastien Teinturier pense que cela pourrait être un comportement d'Eclair et note qu'Eclair
    résoudrait automatiquement cette situation même avec son code actuel.

  - Moins de 0,1% <!-- 10/14124 --> étaient supérieures à 1 000 vbytes. Il s'agit également d'un comportement que les portefeuilles LN
    devraient modifier. Les recherches supplémentaires de Daftuar ont montré que presque toutes les dépenses d'ancrage étaient
    inférieures à 500 vbytes, ce qui suggère potentiellement que la limite de taille v3 pourrait être réduite. Cela rendrait moins
    coûteux pour un défenseur de surmonter une tentative d'attaque par [épinglage][topic transaction pinning] contre une dépense
    d'ancrage, mais cela empêcherait également les portefeuilles LN de pouvoir contribuer à des frais à partir de plus de quelques UTXO.
    Teinturier [a noté][teinturier better] que "il est très tentant de réduire la valeur de 1 000 vbytes, mais les données passées ne
    montrent que des tentatives honnêtes (avec très peu de HTLC en attente) car nous n'avons pas encore vu d'attaques généralisées sur
    le réseau, il est donc difficile de déterminer quelle valeur serait 'meilleure'".

  Bien qu'une discussion et une recherche supplémentaires sur ce sujet soient attendues, notre impression à partir des résultats est que
  les portefeuilles LN pourraient avoir besoin de faire quelques petits changements pour mieux se conformer à la sémantique v3 avant que
  Bitcoin Core puisse traiter en toute sécurité les dépenses d'ancrage comme des transactions v3.

- **Changement de la liste de diffusion Bitcoin-Dev** : la liste de diffusion sur le développement du protocole est désormais hébergée
  sur un nouveau serveur avec une nouvelle adresse e-mail. Tous ceux qui souhaitent continuer à recevoir des messages doivent se
  réabonner. Pour plus de détails, consultez le[courriel de migration][] de Bryan Bishop. Pour les discussions passées sur la migration,
  consultez les bulletins [#276][news276 ml] et [#288][news288 ml].

- **Journée J'aime les logiciels libres** : chaque année, le 14 février, des organisations telles que [FSF][] et [FSFE][] encouragent
  les utilisateurs de logiciels libres et open source (FOSS) à "remercier et dire 'Merci !' à toutes les personnes qui maintiennent et
  contribuent aux logiciels libres". Même si vous lisez cette newsletter après le 14 février, nous vous encourageons à prendre un moment
  pour remercier certains de vos contributeurs préférés aux projets Bitcoin FOSS.

## Bitcoin Core PR Review Club

*Dans cette section mensuelle, nous résumons une récente réunion du [Club de révision des PR de Bitcoin Core][Bitcoin Core PR Review Club]
en mettant en évidence certaines des questions et réponses importantes. Cliquez sur
une question ci-dessous pour voir un résumé de la réponse de la réunion.*

[Ajouter les arguments `maxfeerate` et `maxburnamount` à `submitpackage`][review club 28950] est un PR de Greg Sanders (GitHub
instagibbs) qui ajoute des fonctionnalités à l'API `submitpackage` qui est déjà présente dans les API de transaction unique
`sendrawtransaction` et `testmempoolaccept`. Ce PR fait partie du projet plus large de [relais de paquets][topic package relay].
Plus précisément, le PR permet à un soumissionnaire de paquet de spécifier des arguments (mentionnés dans le titre du PR) qui permettent
de vérifier la cohérence des transactions de package demandées pour éviter la perte accidentelle de fonds. La réunion du club de revue
a été organisée par Abubakar Sadiq Ismail (GitHub ismaelsadeeq).

{% include functions/details-list.md
  q0="Pourquoi est-il important d'effectuer ces vérifications sur les packages soumis ?"
  a0="Il est utile pour les utilisateurs de s'assurer que les transactions au sein des packages bénéficient des mêmes mesures de
      sécurité que les transactions individuelles."
  a0link="https://bitcoincore.reviews/28950#l-27"

  q1="Y a-t-il d'autres vérifications importantes à effectuer sur les packages avant qu'ils ne soient acceptés dans le mempool,
      en dehors de `maxburnamount` et `maxfeerate` ?"
  a1="Oui, deux exemples sont la vérification des frais de base et la taille maximale des transactions standard. Il s'agit de
      vérifications peu coûteuses, qui peuvent donc être effectuées rapidement et échouer rapidement si nécessaire."
  a1link="https://bitcoincore.reviews/28950#l-33"

  q2="Les options `maxburnamount` et `maxfeerate` peuvent empêcher une transaction d'entrer dans le mempool et d'être relayée.
      Peut-on considérer ces options comme des règles de politique ? Pourquoi ou pourquoi pas ?"
  a2="Il s'agit de règles de politique ; ces vérifications ne s'appliquent pas aux transactions dans les blocs minés (ce n'est donc pas
      un consensus). Elles n'affectent même pas le relais des transactions entre pairs, seulement les transactions soumises localement
      à l'aide de RPC."
  a2link="https://bitcoincore.reviews/28950#l-47"

  q3="Pourquoi validons-nous `maxfeerate` par rapport au taux de frais modifié plutôt qu'au taux de frais de base ?"
  a3="(Les précédentes réunions du club de revue [24152][review club 24152], [24538][review club 24538] et [27501][review club 27501]
      ont abordé le concept de frais modifiés par rapport aux frais de base.)
      La plupart des participants ont estimé que les frais de base devraient être utilisés à la place des frais modifiés, car
      `sendrawtransaction` et `testmempoolaccept` utilisent les frais de base dans leurs vérifications, ce qui semble plus cohérent.
      Cela peut ne pas faire de différence pratique, car `prioritisetransaction` (qui rend les frais modifiés et les frais de base
      différents) est généralement utilisé uniquement par les mineurs."
  a3link="https://bitcoincore.reviews/28950#l-69"

  q4="Nous validons `maxfeerate` par rapport au taux de frais modifié des transactions individuelles du package, et non par rapport
      au taux de frais du package. Quand cela peut-il être inexact ?"
  a4="Lorsqu'une transaction enfant du package est rejetée parce que son taux de frais modifié dépasse `maxfeerate` individuellement,
      mais pas si elle est vérifiée en tant que package."
  a4link="https://bitcoincore.reviews/28950#l-84"

  q5="Étant donné cette possible inexactitude, pourquoi ne pas vérifier `maxfeerate` par rapport au taux de frais du package ?"
  a5="Parce que cela peut entraîner une autre inexactitude. Supposons que la transaction A ait des frais nuls et que B effectue une CPFP
      (Child Pays For Parent) sur A. Les deux transactions A et B sont physiquement volumineuses, de sorte que ni l'une ni l'autre ne
      dépasse `maxfeerate`. Mais maintenant, une transaction C à frais élevés est ajoutée, qui dépense à la fois A et B. (Il s'agit d'une
      topologie de package autorisée car elle ne comporte que deux niveaux, bien qu'il ait été souligné que l'API `submitpackage`
      n'autorise pas cette topologie.) Dans ce cas, C serait acceptée car une grande partie de ses frais est absorbée par A et B, mais C
      devrait être rejetée."
  a5link="https://bitcoincore.reviews/28950#l-108"

  q6="Pourquoi `maxfeerate` ne peut-il pas être vérifié immédiatement après le décodage, comme c'est le cas pour `maxburnamount` ?"
  a6="Parce que les entrées de transaction ne spécifient pas explicitement le montant de l'entrée ; elles ne peuvent être connues
      qu'après avoir consulté la sortie parente. Le taux de frais nécessite les frais, qui nécessitent les montants d'entrée."
  a6link="https://bitcoincore.reviews/28950#l-141"

  q7="En quoi la vérification de `maxfeerate` dans l'API `testmempoolaccept` diffère-t-elle de celle de l'API `submitpackage` ?
      Pourquoi ne peuvent-elles pas être identiques ?"
  a7="`submitpackage` utilise des frais modifiés tandis que `testmempoolaccept` utilise des frais de base, comme expliqué précédemment.
      De plus, la vérification du taux de frais est effectuée après le traitement du package `testaccept` car les transactions ne sont
      pas ajoutées à la mempool et diffusées après le traitement, nous pouvons donc vérifier en toute sécurité `maxfeerate` et renvoyer
      des messages d'erreur appropriés. La même chose ne peut pas être faite dans `submitpackage` car les transactions du package peuvent
      déjà avoir été acceptées dans la mempool et diffusées aux pairs, rendant la vérification redondante."
  a7link="https://bitcoincore.reviews/28950#l-153"
%}

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Interface Portefeuille
Matériel (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo], [Propositions
d'Amélioration Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo].*

- [Bitcoin Core #28948][] ajoute la prise en charge (mais ne l'active pas) du [relais de transaction de version 3][topic v3 transaction
  relay], permettant à toute transaction de version 3 qui n'a pas de parent non confirmé d'entrer dans la mempool selon les règles
  normales d'acceptation des transactions. La transaction de version 3 peut être [augmentée de frais CPFP][topic cpfp], mais seulement
  si l'enfant fait 1 000 vbytes ou moins. Chaque parent de version 3 ne peut avoir qu'une seule transaction enfant non confirmée dans la
  mempool et chaque enfant ne peut avoir qu'un seul parent non confirmé. Soit le parent, soit la transaction enfant peut toujours être
  [remplacé par des frais][topic rbf]. Les règles s'appliquent uniquement à la politique de relais de Bitcoin Core ; au niveau du
  consensus, les transactions de version 3 sont validées de la même manière que les transactions de version 2 définies dans [BIP68][].
  Les nouvelles règles sont destinées à aider les protocoles de contrat tels que LN à garantir que leurs transactions pré-engagées
  peuvent toujours être confirmées rapidement avec un minimum de frais supplémentaires nécessaires pour échapper aux [attaques de
  blocage de transaction][topic transaction pinning].

- [Core Lightning #6785][] rend les canaux [anchor-style][topic anchor outputs] par défaut sur Bitcoin. Les canaux non-anchor sont
  toujours utilisés pour les canaux sur les [sidechains][topic sidechains] compatibles avec Elements.

- [Eclair #2818][] maximise le nombre d'entrées que le portefeuille Eclair considère comme pouvant être dépensées en toute sécurité en
  détectant certains cas où une transaction non confirmée existante a très peu de chances de devenir confirmée. Eclair utilise le
  portefeuille de Bitcoin Core pour gérer ses UTXO pour les dépenses onchain, y compris pour les transactions de frais. Lorsqu'un UTXO
  contrôlé par le portefeuille est utilisé comme entrée dans une transaction, le portefeuille de Bitcoin Core ne créera pas
  automatiquement d'autres transactions non liées utilisant cette entrée. Cependant, si cette transaction devient non confirmable parce
  qu'une autre entrée dans cette transaction a été dépensée deux fois, le portefeuille de Bitcoin Core permettra automatiquement à l'UTXO
  d'être dépensé dans une autre transaction. Malheureusement, si un parent de la transaction devient non confirmable parce qu'une version
  différente a été confirmée, le portefeuille de Bitcoin Core n'autorisera pas actuellement l'UTXO à être dépensé automatiquement. Eclair
  peut détecter indépendamment une double dépense de la transaction parent et il indiquera maintenant au portefeuille de Bitcoin Core
  d'abandonner la tentative précédente d'Eclair de déverrouiller l'UTXO et de permettre qu'il soit dépensé à nouveau.

- [Eclair #2816][] permet à l'opérateur du nœud de choisir le montant maximum qu'il est prêt à dépenser sur une [sortie d'ancrage][topic
  anchor outputs] pour faire confirmer une transaction d'engagement. Auparavant, Eclair dépensait jusqu'à 5% de la valeur du canal, mais
  cela peut être trop élevé pour les canaux de grande valeur. La nouvelle valeur par défaut d'Eclair est le taux de frais maximal suggéré
  par son estimateur de taux de frais, jusqu'à un total absolu de 10 000 sat. Eclair paiera également jusqu'au montant en jeu des
  [HTLC][topic htlc] expirant bientôt, ce qui peut être supérieur à 10 000 sats.

- [LND #8338][] ajoute des fonctions initiales pour un nouveau protocole de fermeture coopérative des canaux (voir le [Bulletin
  #261][news261 close] et [BOLTs #1096][]).

- [LDK #2856][] met à jour l'implémentation de LDK de [l'occultation de route][topic rv routing] pour s'assurer que le destinataire
  dispose de suffisamment de blocs pour réclamer un paiement. Cela est basé sur une mise à jour de la spécification d'occultation de
  route dans [BOLTs #1131][].

- [LDK #2442][] inclut des détails sur chaque [HTLC][topic htlc] en attente dans les `ChannelDetails`. Cela permet au consommateur de
  l'API de savoir ce qui doit être fait ensuite pour rapprocher le HTLC de son acceptation ou de son rejet.

- [Rust Bitcoin #2451][] supprime l'exigence selon laquelle un chemin de dérivation HD doit commencer par un `m`. Dans [BIP32][], la
  chaîne `m` est une variable représentant la clé privée principale. Lorsqu'on se réfère uniquement à un chemin, le `m` est inutile et
  peut être incorrect dans certains contextes.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28948,6785,2818,2816,8338,2856,2442,2451,1131,1096" %}
[fsfe]: https://fsfe.org/activities/ilovefs/index.en.html
[fsf]: https://www.fsf.org/blogs/community/i-love-free-software-day-is-here-share-your-love-software-and-a-video
[sanders future]: https://delvingbitcoin.org/t/v3-and-some-possible-futures/523
[news261 close]: /fr/newsletters/2023/07/26/#protocole-de-fermeture-ln-simplifie
[teinturier better]: https://delvingbitcoin.org/t/v3-transaction-policy-for-anti-pinning/340/37
[daftuar retrospective]: https://delvingbitcoin.org/t/analysis-of-attempting-to-imbue-ln-commitment-transaction-spends-with-v3-semantics/527/
[news286 imbued]: /fr/newsletters/2024/01/24/#logique-imbriquee-v3
[news287 kindred]: /fr/newsletters/2024/01/31/#remplacement-par-frais-de-parente
[courriel de migration]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2024-February/022327.html
[news276 ml]: /fr/newsletters/2023/11/08/#hebergement-de-la-liste-de-diffusion
[news288 ml]: /fr/newsletters/2024/02/07/#mise-a-jour-de-la-migration-de-la-liste-de-diffusion-bitcoin-dev
[review club 28950]: https://bitcoincore.reviews/28950
[review club 24152]: https://bitcoincore.reviews/24152
[review club 24538]: https://bitcoincore.reviews/24538
[review club 27501]: https://bitcoincore.reviews/27501
