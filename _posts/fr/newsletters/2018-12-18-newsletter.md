---
title: 'Bulletin Hebdomadaire Bitcoin Optech #26'
permalink: /fr/newsletters/2018/12/18/
name: 2018-12-18-newsletter-fr
slug: 2018-12-18-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit la nouvelle bibliothèque libminisketch pour une réconciliation d'ensembles efficace en bande passante,
renvoie vers un e-mail au sujet des plans Schnorr/Taproot, et mentionne une prochaine réunion de spécification du protocole LN. Sont
également inclus une liste de changements de code notables survenus la semaine passée dans des projets populaires d'infrastructure Bitcoin.

## Actions à entreprendre

- **Aidez à tester Bitcoin Core 0.17.1RC1 :** la première version candidate de cette [version de maintenance][maintenance release] a été
  [téléversée][V0.17.1rc1]. Les tests par les entreprises et les utilisateurs individuels, à la fois du daemon et de l'interface graphique,
  sont grandement appréciés et contribuent à garantir une version de la plus haute qualité.

## Nouvelles

- **Bibliothèque Minisketch publiée :** les développeurs Bitcoin Pieter Wuille, Gregory Maxwell et Gleb Naumenko ont mené des
  recherches sur le [relais optimisé des transactions][] tel que décrit dans la section Nouvelles du [Bulletin #9][]. L'un des résultats de
  cette recherche est une nouvelle bibliothèque autonome qu'ils ont publiée, [libminisketch][], qui permet de transférer les différences
  entre deux ensembles d'informations avec une taille approximativement égale, en octets, à celle des différences attendues elles-mêmes.
  Cela peut ne pas sembler passionnant---l'outil `rsync` fait cela depuis plus de deux décennies---mais libminisketch permet de transférer
  les différences *sans savoir à l'avance ce qu'elles sont.*

  Par exemple, Alice a les éléments 1, 2 et 3. Bob a les éléments 1 et 3. Bien qu'aucun des deux ne sache quels éléments l'autre possède,
  Alice peut envoyer à Bob un *sketch* de la taille d'un seul élément qui contient suffisamment d'informations pour qu'il reconstruise
  l'élément 2. Si Bob a à la place les éléments 1 et 2 (mais pas 3), le même sketch exact lui permet de reconstruire l'élément 3.
  Alternativement, si Bob envoie à Alice un sketch basé sur son ensemble de deux éléments tandis qu'Alice a son ensemble de trois éléments,
  elle peut déterminer quel élément manque à Bob et le lui envoyer directement.

  Ces sketches peuvent fournir une nouvelle manière puissante d'optimiser le relais des transactions non confirmées pour le réseau P2P de
  Bitcoin. Le mécanisme actuel basé sur le gossip fait que chaque nœud reçoit ou envoie des identifiants de 32 octets pour chaque
  transaction à chacun de ses pairs. Par exemple, si vous avez 100 pairs, vous envoyez ou recevez 3200 octets d'annonces, plus les
  surcharges, pour ce qui n'est (en moyenne) qu'une transaction de 400 octets. Une première estimation utilisant un [simulateur][naumenko
  relay simulator] indique que la combinaison de sketches avec des identifiants de transaction raccourcis (pour le relais seulement)
  pourrait réduire la bande passante totale de propagation des transactions par un facteur de 44x. Les sketches ont également le potentiel
  de fournir d'autres fonctionnalités souhaitables---par exemple, le développeur du protocole LN Rusty Russell a lancé un [fil][ln
  minisketch] sur la liste de diffusion Lightning-Dev à propos de leur utilisation pour l'envoi des mises à jour de table de routage LN.

- **Description de ce qui pourrait être inclus dans un soft fork Schnorr/Taproot :** le développeur du protocole Bitcoin Anthony Towns
  a [publié][towns schnorr taproot] un e-mail bien rédigé décrivant ce qui, selon lui, devrait être inclus dans un soft fork qui ajoute le
  schéma de signature Schnorr ainsi qu'un MAST de style Taproot à Bitcoin. Il ne s'agit pas d'une proposition formelle, mais c'est similaire
  aux opinions que nous avons entendues d'autres développeurs et cela devrait donc fournir un bon aperçu de la réflexion actuelle.

- **Réunion IRC du protocole LN :** les développeurs du protocole LN ont convenu d'essayer de convertir leur réunion périodique de
  développement de la spécification LN, d'un Google Hangout en une réunion IRC, après avoir reçu des demandes de plusieurs développeurs. La
  [prochaine réunion][ln irc meeting] aura lieu le mardi 8 janvier, à 19:00 (UTC).

## Changements notables dans le code

*Changements notables dans le code cette semaine dans [Bitcoin Core][bitcoin core repo], [LND][lnd repo], [C-lightning][core lightning repo]
et [libsecp256k1][libsecp256k1 repo].*

- [Bitcoin Core #14573][] déplace diverses options diverses qui ouvraient des boîtes de dialogue séparées dans l'interface graphique
  Bitcoin-Qt vers un nouvel élément de menu de premier niveau intitulé *Window*, ce qui, espérons-le, rendra ces options plus faciles à
  trouver et à utiliser.

- [LND #1984][] ajoute un nouveau RPC `listunspent` qui liste chacune des sorties non dépensées du portefeuille. Il peut prendre deux
  paramètres : (1) le nombre minimum de confirmations que la sortie non dépensée doit avoir ou (2) le nombre maximum qu'elle peut
  avoir. Le minimum peut être défini à `0` pour afficher les sorties non confirmées.

- [LND #2039][] ajoute la capacité d'obtenir l'état de la fonctionnalité autopilot ainsi que de permettre son activation ou sa désactivation
  pendant l'exécution du programme. Autopilot est la capacité du logiciel à suggérer automatiquement de nouveaux canaux à ouvrir lorsqu'un
  utilisateur se connecte pour la première fois à LN ou souhaite une capacité de dépense supplémentaire.

- [C-Lightning #2155][] désactive par défaut la fonctionnalité `option_data_loss_protect` décrite dans les commits notables du [bulletin
  #10][]. La fonctionnalité ne fonctionnait pas de manière fiable, elle ne sera donc activée que pour les utilisateurs qui choisissent
  d'activer les fonctionnalités expérimentales.

- [C-Lightning #2154][] permet désormais aux plugins d'envoyer des notifications de journal qui seront écrites dans les fichiers journaux de
  lightningd.

- [C-Lightning #2161][] ajoute une petite bibliothèque Python et un framework qui peuvent être utilisés pour écrire des plugins. Ils
  fournissent des [décorateurs de fonction][] similaires à ceux utilisés par la bibliothèque populaire [flask][], qui peuvent être utilisés
  pour marquer des fonctions comme fournissant des interfaces de plugin particulières, et ces informations sont automatiquement utilisées
  pour générer un manifeste de plugin. L'exemple de plugin `helloworld.py` a été mis à jour pour utiliser cette bibliothèque, réduisant sa
  taille de 75 % (de 111 lignes à 28).

## Calendrier de publication des fêtes

En raison des fêtes, le Bulletin Optech ne publiera pas de bulletins les 25 décembre et 1er janvier. À la place, nous publierons un bulletin
spécial de rétrospective annuelle le vendredi 28 décembre, et nous reprendrons notre calendrier habituel de publication le mardi à partir du
8 janvier.

{% include references.md %}
{% include linkers/issues.md issues="1984,2039,2324,14573,2155,2154,2132,2161" %}
[V0.17.1rc1]: https://bitcoincore.org/bin/bitcoin-core-0.17.1/
[maintenance release]: https://bitcoincore.org/en/lifecycle/#maintenance-releases
[maxwell-todd por]: https://web.archive.org/web/20170928054354/https://iwilcox.me.uk/2014/proving-bitcoin-reserves
[boneh-et-al por]: http://www.jbonneau.com/doc/DBBCB15-CCS-provisions.pdf
[towns schnorr taproot]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-December/016556.html
[ln irc meeting]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-December/001737.html
[décorateurs de fonction]: https://www.thecodeship.com/patterns/guide-to-python-function-decorators/
[flask]: http://flask.pocoo.org/
[ln minisketch]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-December/001741.html
[relais optimisé des transactions]: http://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2018-10-08-efficient-p2p-transaction-relay/
[naumenko relay simulator]: https://github.com/naumenkogs/Bitcoin-Simulator
[bulletin #9]: /fr/newsletters/2018/08/21/#protocole-de-reconciliation-d-ensembles-efficace-en-bande-passante-pour-les-transactions
[bulletin #10]: /fr/newsletters/2018/08/28/#c-lightning-1854
