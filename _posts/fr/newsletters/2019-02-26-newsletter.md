---
title: 'Bulletin Hebdomadaire Bitcoin Optech #35'
permalink: /fr/newsletters/2019/02/26/
name: 2019-02-26-newsletter-fr
slug: 2019-02-26-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit la disponibilité d'un fork de libsecp256k1 implémentant des signatures compatibles BIP-Schnorr, liste
des questions et réponses populaires de février sur Bitcoin Stack Exchange, et décrit des fusions notables dans des projets populaires
d'infrastructure Bitcoin.

## Éléments d'action

Aucun cette semaine.

## Nouvelles

- **Fork de libsecp256k1 prêt pour Schnorr disponible :** Le cryptographe de Blockstream Andrew Poelstra a [annoncé][schnorr
  libsecp256k1-zkp] que la bibliothèque [libsecp256k1-zkp][] utilisée dans les sidechains basées sur [Elements Project][] (telles que
  [Liquid][]) prend désormais en charge des signatures compatibles [BIP-Schnorr][] dans une variété de configurations :

  - Clés publiques simples et signatures simples de base. Celles-ci sont presque identiques à l'utilisation de l'algorithme ECDSA actuel de
    Bitcoin, bien que les signatures soient sérialisées en utilisant environ huit octets de moins et puissent être efficacement vérifiées
    par lots.

  - [MuSig][] pour les signatures multipartites. Sur la chaîne, elles paraissent identiques à des clés publiques et signatures simples, mais
    les clés publiques et les signatures sont générées par un ensemble de clés privées à l'aide d'un protocole en plusieurs étapes. Alors
    que le multisig utilisant le Script Bitcoin actuel nécessite *n* clés publiques et *k* signatures pour la sécurité d'un multisig
    k-sur-n, MuSig peut fournir la même sécurité en utilisant seulement une clé publique et une signature---réduisant l'espace dans la
    chaîne de blocs, améliorant l'efficacité de la vérification, augmentant la confidentialité, et permettant des ensembles de signataires
    bien plus grands que ceux pris en charge par les limites actuelles de taille en octets et d'opérations de signature du Script Bitcoin.
    Mais il présente deux inconvénients : l'augmentation de la confidentialité détruit aussi la responsabilité prouvable---il n'y a aucun
    moyen de savoir quels signataires autorisés particuliers faisaient partie du sous-ensemble qui a créé une signature---et le protocole en
    plusieurs étapes exige une gestion particulièrement prudente des nonces secrets afin d'éviter de révéler accidentellement des clés
    privées. En réponse au second problème, le message de Poelstra détaille comment libsecp256k1-zkp tente de minimiser le risque d'échecs
    liés aux nonces et laisse entrevoir la possibilité de solutions encore meilleures à l'avenir.

  - Signatures adaptatrices pour des scripts sans script. En utilisant un protocole en plusieurs étapes, Alice peut prouver à Bob que sa
    signature finale pour dépenser un certain paiement lui révélera une valeur qui satisfera une certaine condition spécifiée. Par exemple,
    cette valeur pourrait être une autre signature qui permettra à Bob lui-même de réclamer un certain autre paiement, tel qu'un échange
    atomique ou un engagement de paiement LN. Pour tous ceux autres qu'Alice et Bob, la signature n'est qu'une autre signature valide sans
    signification particulière. Cela peut souvent améliorer la confidentialité et l'efficacité des parties onchain des protocoles en
    supprimant le besoin d'inclure des données spéciales onchain, comme l'utilisation actuelle de hachages et de hashlocks dans les échanges
    atomiques et les engagements de paiement LN.

  La bibliothèque mise à jour ne rend pas ces fonctionnalités disponibles sur les sidechains à elle seule, mais elle fournit bien le code
  sur lequel la génération et la vérification des signatures peuvent être effectuées---permettant aux développeurs de construire les outils
  nécessaires pour mettre en production des systèmes basés sur Schnorr. Il est espéré que le code recevra une revue supplémentaire et sera
  porté dans la bibliothèque [libsecp256k1][] en amont pour un usage éventuel dans Bitcoin Core lié à une proposition de soft fork. Pour en
  savoir plus, lisez le [billet de blog][schnorr libsecp256k1-zkp] ou la [documentation développeur][schnorr docs].

## Questions et réponses sélectionnées de Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech cherchent des réponses à leurs
questions---ou quand nous avons quelques moments libres pour aider les utilisateurs curieux ou confus. Dans cette rubrique mensuelle, nous
mettons en lumière certaines des questions et réponses les mieux votées postées depuis notre dernière mise à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Pourquoi BIP44 a-t-il des adresses internes et externes ?]({{bse}}84594) Les adresses externes sont celles que vous donnez à d'autres
  personnes pour qu'elles puissent vous payer ; les adresses internes sont celles que vous incluez dans vos propres transactions pour
  recevoir la monnaie. Pieter Wuille explique que [BIP32][], sur lequel [BIP44][] est basé, encourage l'utilisation de chemins de dérivation
  distincts pour ces clés au cas où vous auriez besoin de prouver à un auditeur combien d'argent vous avez reçu, mais pas combien vous avez
  dépensé (ou ce qu'il vous reste). En donnant à l'auditeur la clé publique étendue (xpub) uniquement pour les adresses externes, il peut
  suivre vos paiements reçus sans pour autant recevoir d'information directe sur vos dépenses ou votre solde actuel via les adresses de
  monnaie.

- [Taproot et les scripts sans script utilisent tous deux Schnorr, mais en quoi diffèrent-ils ?]({{bse}}84086) Dans des réponses séparées,
  Gregory Maxwell et Andrew Chow décrivent chacun les différences entre ces deux usages proposés des signatures basées sur Schnorr. Inclut
  également une description des signatures adaptatrices, qui peuvent être utilisées pour améliorer l'efficacité et la confidentialité des
  protocoles de contrats sans confiance.

- [Quelle part du temps de propagation des blocs est utilisée par la vérification ?]({{bse}}84045) Gregory Maxwell explique que c'est
  probablement plus proche de 0 % que de 1 % dans le cas normal, mais que cela peut être bien plus élevé pour un bloc de pire cas qui a été
  spécifiquement construit pour prendre beaucoup de temps à vérifier.

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [LND][lnd repo], [C-Lightning][c-lightning repo],
[Eclair][eclair repo], [libsecp256k1][libsecp256k1 repo], et [Bitcoin Improvement Proposals (BIPs)][bips repo].*

- [Bitcoin Core #15348][] ajoute un document [productivity hints][] décrivant des outils et techniques que les développeurs ont trouvés pour
  améliorer leur efficacité. Bien que certains soient spécifiques au développement de Bitcoin Core et en C++, d'autres s'appliquent plus
  généralement à quiconque développe avec git ou GitHub.

- [C-Lightning #2343][] fournit la documentation existante du projet dans un format plus agréable sur [ReadTheDocs.io][cl rtd].

- [C-Lightning #2353][], [#2360][C-Lightning #2360], et [#2365][C-Lightning #2365] mettent à jour diverses RPC afin qu'elles acceptent
  désormais des valeurs suffixées avec "btc", "sat", ou "msat" pour indiquer la dénomination de la valeur. La valeur "btc" permet jusqu'à 11
  décimales et la valeur "sat" jusqu'à 3 décimales mais, dans les deux cas, les trois dernières de ces positions doivent être des zéros pour
  les opérations onchain où la précision supplémentaire n'est pas prise en charge par le protocole Bitcoin. D'autres RPC renvoient de
  nouveaux champs se terminant par `_msat` qui contiennent toujours la valeur en millisatoshi. Plusieurs modifications de l'API interne sont
  également effectuées.

- [C-Lightning #2380][] exige que les transactions aient au moins une confirmation avant que le portefeuille tente de dépenser leurs
  bitcoins par défaut. Cela corrige un problème où le portefeuille tentait de dépenser ses propres sorties de monnaie non confirmées mais
  ces paiements restaient parfois bloqués parce que les paiements antérieurs n'étaient pas confirmés rapidement. Plusieurs RPC liés aux
  paiements reçoivent un paramètre `minconf` qui vaut par défaut `1` mais peut être défini à `0` pour continuer l'ancien comportement ou
  être défini à une valeur plus élevée si souhaité.

- [Eclair #821][] améliore les heuristiques utilisées pour aider à trouver une bonne route par laquelle envoyer un paiement.

{% include references.md %}
{% include linkers/issues.md issues="15348,2419,2343,2353,2360,2365,2380,821" %}
[schnorr libsecp256k1-zkp]: https://blockstream.com/2019/02/18/musig-a-new-multisignature-standard/
[libsecp256k1-zkp]: https://github.com/ElementsProject/secp256k1-zkp
[cl rtd]: https://lightning.readthedocs.io/
[elements project]: https://elementsproject.org/
[liquid]: https://blockstream.com/liquid/
[schnorr docs]: https://github.com/ElementsProject/secp256k1-zkp/blob/secp256k1-zkp/src/modules/musig/musig.md
[productivity hints]: https://github.com/bitcoin/bitcoin/blob/master/doc/productivity.md
[musig]: https://eprint.iacr.org/2018/068
