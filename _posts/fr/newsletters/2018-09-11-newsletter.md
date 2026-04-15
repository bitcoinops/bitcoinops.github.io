---
title: 'Bulletin Hebdomadaire Bitcoin Optech #12'
permalink: /fr/newsletters/2018/09/11/
name: 2018-09-11-newsletter-fr
slug: 2018-09-11-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine fait référence à une discussion sur le chiffrement BIP151 pour le protocole réseau pair à pair, fournit une
mise à jour sur la compatibilité entre Bitcoin et le projet de spécification W3C Web Payments, et décrit brièvement quelques fusions
notables dans des projets populaires d'infrastructure Bitcoin.

## Actions requises

- **Allouer du temps pour tester Bitcoin Core 0.17RC3 :** Bitcoin Core a téléversé des [binaires][bcc 0.17] pour la version candidate (RC) 3
  de 0.17. Les tests sont grandement appréciés et peuvent aider à assurer la qualité de la version finale.

- Les plans pour le deuxième [atelier][workshop] Optech progressent, avec la date et le lieu confirmés à Paris les 12 et 13 novembre. La
  liste provisoire des sujets est :
    - Replace-by-fee contre child-pays-for-parent comme techniques de remplacement de frais
    - Transactions Bitcoin partiellement signées (BIP 174)
    - Descripteurs de scripts de sortie pour l'interopérabilité des portefeuilles (gist)
    - Intégration de portefeuilles Lightning et applications pour les plateformes d'échange
    - Approches de sélection et de consolidation des pièces

  **Les entreprises membres qui souhaiteraient envoyer des ingénieurs à l'atelier devraient [envoyer un courriel à Optech][optech email]**.

## Nouvelles

- **Discussion BIP151 :** comme mentionné dans le [Bulletin #10][news10 news], Jonas Schnelli a [proposé][schnelli bip151] une version
  préliminaire mise à jour du chiffrement [BIP151][] pour le protocole réseau pair à pair. Le cryptographe Tim Ruffing a fourni une
  [critique constructive][ruffing bip151] du projet sur la liste de diffusion Bitcoin-Dev cette semaine, qui a également reçu des
  réfutations tout aussi constructives de la part de Schnelli et Gregory Maxwell. Ces messages peuvent être intéressants à lire pour toute
  personne se demandant pourquoi certains choix cryptographiques ont été faits dans le protocole, comme l'utilisation de l'échange de clés
  NewHope résistant à l'informatique quantique.

- **Mise à jour du groupe de travail W3C Web Payments :** le développeur du Lightning Network Christian Decker est membre de ce groupe qui
  tente de créer des standards pour les paiements sur le web. Dans une [réponse][decker w3c] envoyée à la liste de diffusion Lightning-Dev,
  Decker explique pourquoi il pense que la version préliminaire actuelle de la spécification sera fondamentalement compatible à la fois avec
  les paiements vers des adresses Bitcoin et les paiements Lightning Network. Le projet attribue même explicitement le code de devise XBT à
  Bitcoin.

## Fusions notables

*Fusions notables cette semaine dans [Bitcoin Core][bitcoin core repo], [LND][lnd repo] et [C-lightning][core lightning repo]. Rappel : les
nouvelles fusions dans Bitcoin Core sont faites sur sa branche de développement master et ont peu de chance de faire partie de la prochaine
version 0.17---vous devrez probablement attendre la version 0.18 dans environ six mois à partir de maintenant.*

- [Bitcoin Core #12775][] ajoute la prise en charge de RapidCheck (une réimplémentation de [QuickCheck][]) à Bitcoin Core, fournissant une
  suite de tests basée sur les propriétés qui génère ses propres tests à partir de ce que les programmeurs lui indiquent être les propriétés
  d'une fonction (par ex. ce qu'elle accepte en entrée et renvoie en sortie).

- [Bitcoin Core #12490][] supprime la RPC `signrawtransaction` de la branche de développement master. Cette RPC est étiquetée comme obsolète
  dans la prochaine version 0.17 et les utilisateurs sont encouragés à utiliser la RPC `signrawtransactionwithkey` lorsqu'ils fournissent
  leur propre clé privée pour la signature, ou la RPC `signrawtransactionwithwallet` lorsqu'ils veulent que le portefeuille intégré
  fournisse automatiquement la clé privée.

- [Bitcoin Core #14096][] fournit une [documentation pour les descripteurs de scripts de sortie][] qui sont utilisés dans la nouvelle RPC
  `scantxoutset` de Bitcoin Core 0.17 et dont l'utilisation est prévue pour d'autres interactions avec le portefeuille à l'avenir.

- **LND** a effectué près de 30 fusions la semaine passée, dont beaucoup ont apporté de petites améliorations ou corrections de bugs à sa
  fonctionnalité d'autopilotage---sa capacité à permettre aux utilisateurs de choisir d'ouvrir automatiquement de nouveaux canaux avec des
  pairs sélectionnés automatiquement. Plusieurs fusions ont également mis à jour les versions des bibliothèques dont LND dépend.

- [C-Lightning #1899][] a ajouté plusieurs centaines de lignes de documentation à son dépôt cette semaine, pour la plupart de la
  documentation de code en ligne ou des mises à jour de fichiers dans son [répertoire /doc][c-lightning docs].

{% include references.md %}
{% include linkers/issues.md issues="12775,12490,14096,1899" %}

[bcc 0.17]: https://bitcoincore.org/bin/bitcoin-core-0.17.0/
[workshop]: /en/workshops
[documentation for output script descriptors]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
[news10 news]: /fr/newsletters/2018/08/28/#pr-ouverte-pour-le-support-initial-de-bip151
[decker w3c]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-August/001404.html
[schnelli bip151]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-September/016355.html
[ruffing bip151]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-September/016372.html
[quickcheck]: https://en.wikipedia.org/wiki/QuickCheck
[c-lightning docs]: https://github.com/ElementsProject/lightning/tree/master/doc
