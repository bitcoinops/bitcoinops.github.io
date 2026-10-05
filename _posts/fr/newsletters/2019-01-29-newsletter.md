---
title: 'Bulletin Hebdomadaire Bitcoin Optech #31'
permalink: /fr/newsletters/2019/01/29/
name: 2019-01-29-newsletter-fr
slug: 2019-01-29-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume une publication sur la proposition payjoin améliorant la confidentialité, renvoie vers des questions et
réponses les mieux notées de Bitcoin Stack Exchange, et décrit une nouvelle semaine bien remplie de commits notables dans des projets
populaires d'infrastructure Bitcoin.

## Action items

Aucun cette semaine.

## Nouvelles

- **Publication sur BIP79 (P2EP/payjoin) :** le développeur de Joinmarket Adam (waxwing) Gibson a envoyé une [publication][payjoin post] à
  la liste de diffusion Bitcoin-Dev au sujet de la version simplifiée de la proposition Pay-to-EndPoint (P2EP) décrite dans [BIP79][]. La
  proposition permet à un dépensier onchain d'inclure une entrée de la personne recevant la transaction aux côtés des propres entrées du
  dépensier, empêchant les analystes de la chaîne de blocs de pouvoir raisonnablement supposer que toutes les entrées proviennent de la même
  personne. Cela pourrait rendre l'analyse de la chaîne de blocs significativement moins fiable même si seul un nombre relativement faible
  de personnes utilise effectivement cette fonctionnalité. Voir Le [Bulletin #27][payjoin summary] pour plus de détails.

  Les suggestions de Gibson se concentraient sur la modification de la proposition en se basant sur son expérience d'implémentation d'un
  protocole semblable à P2EP dans la version de développement de Joinmarket, ainsi que sur les retours qu'il a reçus des développeurs de
  Samourai Wallet, qui ont également implémenté une variante du protocole encore en phase de test par les développeurs. L'objectif est
  d'essayer d'amener les deux portefeuilles (et beaucoup d'autres) à utiliser le même protocole, et aussi de le faire prendre en charge par
  des processeurs de paiement tels que BTCPay. Les suggestions sont assez simples :

  - Versionner le protocole afin que les clients de dépense et les serveurs de réception puissent négocier les fonctionnalités du protocole
    qu'ils prennent en charge
  - Renommer le protocole en *payjoin,* car beaucoup de gens ne sont pas tout à fait sûrs de savoir comment l'appeler pour le moment
  - Utiliser les [BIP174][] Partially Signed Bitcoin Transactions (PSBT) pour communiquer les données de transaction et de signature entre
    clients et serveurs
  - Spécifier que les transactions doivent utiliser une courte liste de fonctionnalités de transaction suivant les meilleures pratiques et
    éviter une sélection de pièces à l'apparence inhabituelle afin que les transactions payjoin se fondent dans les transactions normales et
    créent une confusion maximale pour les analystes de la chaîne de blocs

## Questions et réponses sélectionnées de Bitcoin Stack Exchange

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech cherchent des réponses à leurs
questions---ou quand nous avons quelques moments libres pour aider les utilisateurs curieux ou confus. Dans cette rubrique mensuelle, nous
mettons en lumière certaines des questions et réponses les mieux votées postées depuis notre dernière mise à jour.*

- [Comment un nœud LN devrait-il décider quels canaux ouvrir ?]({{bse}}83362) Le développeur du protocole LN et formateur Rene Pickhardt
  décrit plusieurs critères que vous pouvez utiliser pour aider à ouvrir des canaux productifs. Il renvoie aussi vers des discussions
  intéressantes sur l'automatisation de la sélection des canaux en utilisant la fonctionnalité autopilot de LND et son propre plugin pour
  C-Lightning.

- [Si je génère 20 millions d'adresses Bitcoin par heure, combien de temps avant de trouver une collision ?]({{bse}}83818) Un utilisateur
  générant un nombre incroyable d'adresses à l'aide d'un ordinateur avec 32 cœurs et 128 Go de mémoire se demande combien de temps il lui
  faudra avant de créer deux adresses identiques avec des clés privées différentes. La réponse de Pieter Wuille et les commentaires qui la
  suivent décrivent les principes mathématiques impliqués, calculent combien de temps cela prendrait---une réponse donnée en multiples de
  l'âge de l'univers---et anéantissent finalement tout espoir que l'auteur avait de casser bitcoin en soulignant que la méthode de l'auteur
  trouverait presque certainement une collision uniquement entre les propres adresses de l'auteur---laissant les autres utilisateurs sans
  effet.

- [Qu'est-ce qui retarde l'implémentation de BIP156 Dandelion dans Bitcoin Core ?]({{bse}}81503) Dandelion est une [méthode
  proposée][BIP156] pour relayer initialement des transactions nouvellement créées qui peut rendre plus difficile la détermination de
  l'adresse réseau du portefeuille qui a créé la transaction. Cette réponse du développeur Bitcoin Core Suhas Daftuar décrit certains des
  défis auxquels sont confrontés les développeurs de protocoles de relais critiques pour la mission et pourquoi même des idées
  conceptuellement simples comme Dandelion peuvent nécessiter davantage de travail pour être implémentées en toute sécurité que d'autres
  idées qui pourraient aussi améliorer le système (par ex. le chiffrement [BIP151][] ou le relais efficace de [libminisketch][]).

- [Comment utiliser les PSBT BIP174 avec un portefeuille à froid et un portefeuille en observation seule ?]({{bse}}83070) Il est facile de
  configurer deux copies de Bitcoin Core, l'une sur un ordinateur hors ligne comme portefeuille à froid pour stocker les clés privées et
  l'autre sur un ordinateur connecté au réseau pour surveiller le solde du portefeuille et diffuser les transactions. Mais comment
  utiliserait-on réellement les [BIP174][] Partially Signed Bitcoin Transactions (PSBT) pour dépenser de l'argent avec ces deux
  portefeuilles ? L'auteur de BIP174 Andrew Chow l'explique.

- [Pourquoi relayer les transactions de nœud à nœud---pourquoi ne pas les envoyer directement aux mineurs ?]({{bse}}83054) Il semble que le
  réseau Bitcoin pourrait utiliser bien moins de bande passante si tout le monde envoyait ses transactions directement aux mineurs et que
  les nœuds ne distribuaient ensuite que les blocs. Pieter Wuille explique pourquoi ce serait mauvais pour la confidentialité et la santé du
  réseau, ainsi que pourquoi cela n'économiserait même pas tant de bande passante que ça.

- [Pourquoi le fait que des mineurs hachent des nonces arbitraires devrait-il inspirer confiance dans la sécurité des transactions ?]({{bse}}83951)
  Lorsqu'elle est décrite comme un simple jeu de devinettes, la preuve de travail de Bitcoin ne paraît pas très
  convaincante, mais cette réponse de Chytrik, l'un des 30 meilleurs experts de Bitcoin Stack Exchange, fournit une analogie simple qui
  capture l'essence de la preuve de travail et comment elle aide à maintenir la sécurité des transactions Bitcoin.

Optech félicite également et remercie Pieter Wuille, qui ce mois-ci est devenu le [contributeur le mieux noté de tous les temps][top bse]
sur Bitcoin Stack Exchange.

## Changements notables dans le code

*Changements notables dans le code cette semaine dans [Bitcoin Core][bitcoin core repo], [LND][lnd repo], [C-Lightning][c-lightning repo],
[Eclair][eclair repo], et [libsecp256k1][libsecp256k1 repo].*

- [Bitcoin Core #14955][] remplace le générateur de nombres aléatoires (RNG) utilisé, passant d'OpenSSL à l'implémentation propre à Bitcoin
  Core, bien que la sortie RNG recueillie par Bitcoin Core soit fournie à OpenSSL puis relue lorsque le programme a besoin d'un fort
  aléatoire. Cela rapproche un peu Bitcoin Core du moment où il n'aura plus besoin de dépendre d'OpenSSL, car cette dépendance a causé des
  problèmes de sécurité dans le passé. La description de la PR et les modifications de code sont très bien documentées pour toute personne
  préoccupée par la sûreté de ce changement.

- [Bitcoin Core #14353][] ajoute un nouvel appel REST `/rest/blockhashbyheight/` pour récupérer le bloc dans la meilleure chaîne de blocs
  actuelle sur la base de sa hauteur (combien de blocs après le bloc Genesis il se trouve).

- [Bitcoin Core #15193][] règle l'option de configuration `whitelistforcerelay` sur désactivée par défaut. Lorsqu'elle est activée, cette
  option amène un nœud à relayer des transactions provenant de ses pairs et clients mis manuellement sur liste blanche même si ces
  transactions violent la politique du nœud ou les règles du consensus. Cela pourrait amener le nœud relais, plutôt que le nœud ou client
  d'origine, à être banni par ses pairs, il vaut donc mieux que cette option soit désactivée par défaut. Les développeurs demandent
  également à toute personne utilisant cette fonctionnalité de les [contacter][contact core] afin qu'ils sachent qu'il ne s'agit pas d'une
  option inutilisée qui devrait être dépréciée à l'avenir.

- [LND #2314][] ajoute un sous-serveur de notification de chaîne, permettant aux services de recevoir des notifications concernant les
  changements de la meilleure chaîne de blocs---comme lorsque de nouveaux blocs sont reçus, lorsque des transactions sont confirmées, et si
  une entrée a été dépensée ou non.

- [LND #2405][] permet de combiner différentes heuristiques d'autopilot en un score unique pour chaque nœud auquel vous pourriez vous
  connecter. Plus un score est élevé, plus on s'attend à ce que l'ouverture d'un canal vers ce nœud augmente la connectivité de votre nœud
  (selon diverses caractéristiques).

- [LND #2350][] ajoute une option `query` pour l'autopilot qui accepte une liste de nœuds LN et renvoie les scores pour ces nœuds indiquant
  à quel point ils sont de bons candidats pour l'ouverture d'un canal vers eux.

- [LND #2460][] ajoute la prise en charge du champ `max_htlc` dans les mises à jour de canaux. Cette fonctionnalité permet aux clients
  légers et aux nœuds élagués d'apprendre la capacité maximale de routage d'un canal appartenant à un nœud distant sans avoir à rechercher
  la transaction d'ouverture de ce canal dans la chaîne de blocs---ce que les nœuds complets d'archive peuvent faire, mais que les clients
  légers et les nœuds élagués ne peuvent pas faire (pas facilement, en tout cas). Désormais, les nœuds LND annoncent directement cette
  information, ce qui aide non seulement les clients légers et les nœuds élagués, mais permet aussi aux nœuds LN de spécifier une valeur
  inférieure à leur maximum s'ils ne veulent acheminer que des paiements plus petits. À l'avenir, cela pourrait aussi aider à prendre en
  charge les paiements multipath---des paiements qui sont divisés en parties afin que le paiement total puisse être plus grand que la
  capacité du plus petit canal utilisé.

- [LND #2370][] ajoute un nouveau sous-système qui met à jour un fichier `channel.backup` chaque fois qu'un nouveau canal est ouvert ou
  fermé. Les utilisateurs qui sauvegardent ce fichier peuvent exécuter une commande de récupération qui tentera de fermer chaque canal dans
  son état réglé le plus récent après connexion au pair distant de ce canal et initialisation du protocole de protection contre la perte de
  données spécifié dans [BOLT2][].[^fn-data-loss-protect] Les sauvegardes sont chiffrées à l'aide d'une clé de votre trousseau principal
  LND, qui lui-même devrait être chiffré par une phrase de passe forte de votre choix.

- [C-Lightning #2283][] réactive le champ `option_data_loss_protect` de [BOLT2][][^fn-data-loss-protect] après qu'il a été désactivé par
  défaut en décembre (voir la section des changements de code du [Bulletin #26][]).

- [Eclair #784][] envoie les paiements en utilisant le canal avec le solde disponible le plus faible pouvant prendre en charge l'envoi du
  paiement. Cela réserve la valeur dans les canaux de plus grande valeur pour des paiements plus importants qui pourraient venir plus tard.
  (En fin de compte, si le réseau adopte les paiements multipath, la nécessité de conserver au moins un canal avec un solde supérieur au
  plus grand paiement que vous souhaitez envoyer devrait disparaître.)

## Footnotes

[^fn-data-loss-protect]: Le paragraphe final de [BOLT2][] décrit l'option `option_data_loss_protect`. L'idée de base est qu'un nœud ayant
potentiellement perdu une partie de son état peut encourager son pair à initier une fermeture de canal. Puisque le pair possède encore
l'état le plus récent, il devrait fermer le canal en utilisant cet état et permettre aux deux nœuds de recevoir leurs soldes les plus
récents.

    Cette méthode comporte bien un risque---le pair peut deviner que quelque chose ne va pas et tenter de voler des fonds au nœud périmé en
    fermant le canal à l'aide d'un ancien état. Mais le risque est en grande partie atténué par le mécanisme de pénalité LN : si le nœud
    périmé *a bien* une révocation de cet ancien état dans ses sauvegardes, il peut créer une transaction de réparation de rupture
    (transaction de justice) qui saisira tous les fonds du pair menteur de ce canal. En raison de ce risque, les pairs utilisant le
    mécanisme `option_data_loss_protect` sont incités à fermer le canal honnêtement avec l'état le plus récent lorsqu'ils entendent parler
    d'un nœud périmé.

{% include references.md %}
{% include linkers/issues.md issues="14955,14353,15193,2314,2405,2350,2460,2370,2283,784" %}
[top bse]: https://bitcoin.stackexchange.com/users?tab=Reputation&filter=all
[payjoin summary]: /fr/newsletters/2018/12/28/#juillet
[payjoin post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-January/016625.html
[contact core]: https://bitcoincore.org/en/contact/
[bulletin #26]: /fr/newsletters/2018/12/18/#c-lightning-2155
