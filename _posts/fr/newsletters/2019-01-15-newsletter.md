---
title: 'Bulletin Hebdomadaire Bitcoin Optech #29'
permalink: /fr/newsletters/2019/01/15/
name: 2019-01-15-newsletter-fr
slug: 2019-01-15-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine annonce une mise à niveau de sécurité pour C-Lightning, décrit un article et des recherches supplémentaires sur
des portefeuilles qui ont accidentellement révélé leurs clés privées, et liste certains changements notables de code dans des projets
populaires d'infrastructure Bitcoin.

## Action requise

- **Mettre à niveau vers C-Lightning 0.6.3 :** cette [version][cl 0.6.3] corrige une vulnérabilité de DoS à distance qui pouvait être
  utilisée pour faire planter des nœuds C-Lightning et potentiellement voler de l'argent. Voir la section *changements notables dans le
  code* ci-dessous pour plus de détails. Cette version inclut également d'autres corrections de bugs moins critiques et de nouvelles
  fonctionnalités.

## Nouvelles

- **Découverte de nonces de signature faibles :** un [article][weak nonces] en prépublication par les chercheurs Joachim Breitner et Nadia
  Heninger décrit comment ils ont découvert des centaines de clés privées Bitcoin en recherchant des signatures générées à l'aide de nonces
  avec moins que l'entropie attendue de 256 bits. Une [archéologie du code][gmaxwell bitcore] indépendante par Gregory Maxwell indique que
  le principal coupable était probablement le logiciel BitPay Bitcore qui a introduit un bug vers juillet 2014 et publié un correctif
  environ un mois plus tard. (Remarque : BitPay Bitcore n'est pas lié à Bitcoin Core.) À partir de là, le bug s'est propagé à des logiciels
  tels que BitPay Copay qui dépendaient de Bitcore. Environ 97 % des signatures défectueuses trouvées dans l'article sont compatibles avec
  l'hypothèse de Maxwell sur Copay, et l'article fournit des explications plausibles pour la plupart des 3 % restants de signatures,
  indiquant que les utilisateurs de portefeuilles modernes sont probablement en sécurité à condition de ne pas continuer à utiliser des
  adresses dont ils ont dépensé les bitcoins à l'aide d'anciens programmes vulnérables.

  Si vous avez déjà utilisé une version affectée de Bitcore (0.1.28 à 0.1.35), Copay (0.4.1 à 0.4.3), ou un autre logiciel vulnérable, vous
  devriez créer un nouveau fichier portefeuille, envoyer tous vos fonds depuis l'ancien fichier portefeuille vers une adresse du nouveau
  portefeuille, et cesser d'utiliser le fichier portefeuille précédent. Lors de la conception d'un logiciel qui signe des transactions
  Bitcoin, vous devriez préférer utiliser des implémentations évaluées par les pairs qui génèrent les nonces de signature de manière
  déterministe, telles que [libsecp256k1][] qui implémente [RFC6979][].

  La méthode d'analyse rapide employée par les auteurs de l'article tirait avantage des utilisateurs qui réutilisaient des adresses, mais
  même les clés d'adresses qui n'ont pas été réutilisées sont vulnérables à une attaque si la génération des nonces est biaisée ou trop
  faible. Cela peut se produire soit en utilisant la même méthode pour des clés qui ont été utilisées plusieurs fois (p. ex. pour
  Replace-By-Fee), soit simplement par force brute en utilisant les méthodes [baby-step giant-step][] ou [Pollard's Rho][].

## Changements notables dans le code

*Changements notables dans le code cette semaine dans [Bitcoin Core][bitcoin core repo], [LND][lnd repo], [C-Lightning][c-lightning repo],
[Eclair][eclair repo], et [libsecp256k1][libsecp256k1 repo].*

- [Bitcoin Core #15039][] désactive la protection anti-fee-sniping basée sur nLockTime si le bloc le plus récent vu par le nœud avait un
  horodatage datant de huit heures ou plus. La protection anti-fee-sniping tente d'égaliser les avantages entre les mineurs honnêtes qui se
  contentent d'étendre la chaîne de blocs et les mineurs malhonnêtes qui créent des bifurcations de chaîne dans le but de voler des frais
  aux mineurs honnêtes. Cependant, lors de l'utilisation de la protection anti-fee-sniping, les nœuds qui ont été hors ligne pendant un
  certain temps ne savent pas quel bloc se trouve à l'extrémité de la chaîne et pourraient donc créer hors ligne plusieurs transactions qui
  utiliseraient toutes la même très ancienne valeur nLockTime, reliant ainsi ces transactions entre elles dans l'analyse de la chaîne de
  blocs. Cette fusion corrige le problème en désactivant la fonctionnalité si un nœud reste hors ligne trop longtemps.

- [C-Lightning #2214][] corrige un bug de plantage à distance qui pouvait conduire à une perte de fonds. **Il est conseillé à tous les
  utilisateurs de mettre à niveau vers la version 0.6.3 pour obtenir un correctif pour ce problème.**

  La vulnérabilité permettait à un pair de faire planter votre nœud C-Lightning en essayant de vous faire accepter un paiement avec un
  timelock plus court que ce que votre nœud autorise. Si un nœud planté reste arrêté trop longtemps, il est possible pour un attaquant de
  lui voler des fonds s'il avait auparavant ouvert un canal avec ce nœud. Notez cependant que l'attaquant doit risquer son propre argent
  pour tenter l'attaque, et les nœuds peuvent donc prétendre être hors ligne afin de prendre de l'argent à n'importe quels attaquants---ce
  qui, espère-t-on, représente un risque suffisant pour décourager la plupart des attaques.

- [C-Lightning #2230][] met à jour la sortie "channel" du RPC `listpeers` afin d'inclure un drapeau `private` indiquant si le canal est
  annoncé aux pairs ou non.

- [C-Lightning #2244][] désactive les plugins par défaut mais ajoute une option de configuration `--enable-plugins` pour les activer au
  démarrage. Les plugins pourraient être réactivés par défaut dans une prochaine version lorsque l'API complète des plugins aura été
  implémentée.

- [Eclair #797][] modifie la manière dont les routes de paiement sont calculées. Auparavant, les routes étaient calculées du payeur vers le
  destinataire ; elles sont maintenant calculées du destinataire vers le payeur. Cela corrige un problème où le nœud calculait
  incorrectement les frais.

{% include references.md %}
{% include linkers/issues.md issues="15039,2214,2230,2244,797" %}
[gmaxwell bitcore]: https://bitcoin.stackexchange.com/questions/83559/what-is-the-origin-of-insecure-64-bit-nonces-in-signatures-in-the-bitcoin-chain/
[weak nonces]: https://eprint.iacr.org/2019/023.pdf
[RFC6979]: https://tools.ietf.org/html/rfc6979
[cl 0.6.3]: https://github.com/ElementsProject/lightning/releases/tag/v0.6.3
[baby-step giant-step]: https://en.wikipedia.org/wiki/Baby-step_giant-step
[pollard's rho]: https://en.wikipedia.org/wiki/Pollard%27s_rho_algorithm
