---
title: 'Bulletin Hebdomadaire Bitcoin Optech #10'
permalink: /fr/newsletters/2018/08/28/
name: 2018-08-28-newsletter-fr
slug: 2018-08-28-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine comprend des informations sur la première version candidate publiée pour Bitcoin Core, des nouvelles sur le
chiffrement du protocole P2P BIP151 et un potentiel futur soft fork, les principales questions et réponses de Bitcoin Stack Exchange, ainsi
que quelques fusions notables dans des projets populaires d'infrastructure Bitcoin.

## Éléments d'action

- **Prévoyez du temps pour tester Bitcoin Core 0.17RC2 :** Bitcoin Core a téléversé les [binaires][bcc 0.17] de la version candidate (RC) 2
  de 0.17. Les tests sont grandement appréciés et peuvent aider à assurer la qualité de la version finale.

## Nouvelles

- **PR ouverte pour le support initial de BIP151 :** Jonas Schnelli a ouvert une pull request pour Bitcoin Core fournissant une
  [implémentation initiale][Bitcoin Core #14032] du chiffrement [BIP151][] pour le protocole réseau pair-à-pair. Il dispose également d'une
  [ébauche mise à jour][bip151 update] de la spécification BIP151 qui intègre les changements qu'il a apportés au développement de
  l'implémentation. Si elle est acceptée, cela permettra aux nœuds complets comme aux clients légers de communiquer des blocs, transactions
  et messages de contrôle sans que les FAI puissent espionner les connexions, ce qui peut rendre plus difficile de déterminer quel programme
  est à l'origine d'une transaction (surtout en combinaison avec la protection existante de Bitcoin Core pour l'origine des transactions ou
  de futures propositions telles que le [protocole Dandelion][dandelion protocol]).

  Schnelli travaille également avec d'autres développeurs pour implémenter et tester le [protocole d'échange de clés NewHope][newhope], qui
  est considéré comme résistant aux attaques par ordinateurs quantiques, de sorte qu'un espion qui enregistre aujourd'hui les communications
  entre deux pairs ne pourra pas déchiffrer ces données dans un futur où il possédera un ordinateur quantique rapide.

- **Demandes de solutions par soft fork à l'attaque time warp :** Les blocs Bitcoin incluent l'heure à laquelle le bloc a supposément été
  créé par un mineur. Ces horodatages sont utilisés pour ajuster la difficulté du minage des blocs afin qu'un bloc soit produit en moyenne
  toutes les 10 minutes. Cependant, l'attaque time warp permet à des mineurs représentant une grande fraction du taux de hachage du réseau
  de mentir de façon répétée sur le moment où les blocs ont été créés sur une longue période afin d'abaisser la difficulté même lorsque les
  blocs sont produits plus fréquemment qu'une fois toutes les 10 minutes.

  Gregory Maxwell a [demandé][timewarp maxwell] sur la liste de diffusion de développement du protocole Bitcoin des propositions de
  solutions par soft fork à cette attaque avant de proposer sa propre solution. Jusqu'à présent, Johnson Lau a [proposé][timewarp lau] une
  technique.

  Note : toute personne surveillant la chaîne de blocs pour ce type d'attaque disposerait d'au moins un mois de préavis avant qu'un dommage
  significatif ne soit causé. Pour cette raison, et parce qu'il existe plusieurs méthodes connues pour contrer l'attaque (avec divers
  compromis), corriger l'attaque time warp n'a jamais été considéré comme urgent. Cependant, si le risque de cette attaque peut être atténué
  totalement ou partiellement par un soft fork non controversé, ce serait certainement appréciable.

## Questions et réponses sélectionnées de Bitcoin Stack Exchange

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech cherchent des réponses à leurs
questions---ou quand nous avons quelques moments libres pour aider les utilisateurs curieux ou confus. Dans cette rubrique mensuelle, nous
mettons en lumière certaines des questions et réponses les mieux votées postées depuis notre dernière mise à jour.*

- [Peut-on payer 0 bitcoin ?][bse 78355] Andrew Chow explique que non seulement il est possible de payer un montant de valeur nulle vers une
  adresse ou un autre script, mais qu'il est également possible de dépenser une sortie de valeur nulle---mais seulement si vous trouvez un
  mineur qui n'utilise pas les paramètres par défaut de Bitcoin Core.

- [Peut-on créer une preuve SPV de l'absence d'une transaction ?][bse 77764] La Vérification Simplifiée des Paiements (SPV) utilise un arbre
  de merkle pour prouver qu'une transaction existe dans un bloc qui lui-même appartient à la meilleure chaîne de blocs---la chaîne de blocs
  avec la plus grande preuve de travail. Mais pourrait-on créer l'inverse ? Pourrait-on prouver qu'une transaction n'est pas dans un bloc
  particulier ni dans aucun bloc de la meilleure chaîne de blocs ?

  Gregory Maxwell explique que c'est possible, et que cela impliquerait également l'utilisation d'arbres de merkle, mais que cela
  nécessiterait probablement des preuves à divulgation nulle de connaissance (ZKP) coûteuses en calcul (mais efficaces en bande passante).

- [Pouvez-vous convertir une adresse P2PKH en P2SH ou segwit ?][bse 72775] **Ne faites pas ça.** Pieter Wuille explique pourquoi c'est une
  très mauvaise idée et qu'elle aboutira probablement à une perte d'argent. Note : il s'agit d'une réponse plus ancienne qui a reçu
  davantage d'attention ce mois-ci après que certains utilisateurs ont tenté de convertir les adresses d'autres personnes en segwit et ont
  perdu de l'argent en conséquence.

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [LND][lnd repo] et [C-lightning][core lightning repo]. Rappel :
les nouvelles fusions dans Bitcoin Core sont effectuées sur sa branche de développement master et il est peu probable qu'elles fassent
partie de la future version 0.17---vous devrez probablement attendre la version 0.18 dans environ six mois à partir de maintenant.*

{% comment %}<!-- I didn't notice anything interesting in LND this week -harding -->{% endcomment %}

- [Bitcoin Core #12254][] ajoute les fonctions nécessaires pour permettre à Bitcoin Core de générer des filtres compacts de blocs
  [BIP158][]. Ce code n'est actuellement pas utilisé par Bitcoin Core, mais des travaux futurs devraient utiliser ces fonctions pour fournir
  deux fonctionnalités :

  1. le support de [BIP157][] pour l'envoi de filtres aux clients légers via le protocole réseau pair-à-pair (P2P). Cela peut permettre aux
     portefeuilles légers P2P de trouver les blocs contenant des transactions qui affectent leur portefeuille de manière beaucoup plus
     privée qu'il n'est actuellement possible avec les filtres bloom BIP37.

  2. Des rescans plus rapides pour le portefeuille intégré de Bitcoin Core. Occasionnellement, les utilisateurs de Bitcoin Core doivent
     rescanner la chaîne de blocs pour voir si des transactions historiques ont affecté leur portefeuille---par exemple, lorsqu'ils
     importent une nouvelle clé privée, clé publique ou adresse. Cela prend actuellement plus d'une heure même sur des ordinateurs de bureau
     modernes, mais les utilisateurs disposant de filtres BIP157 locaux pourront effectuer le rescan beaucoup plus rapidement et toujours
     avec une [confidentialité parfaite au sens de la théorie de l'information][information theoretic perfect privacy] (ce dont les clients
     légers ne disposent pas).

- [Bitcoin Core #12676][] ajoute un champ aux résultats RPC de `getrawmempool`, `getmempoolentry`, `getmempoolancestors` et
  `getmempooldescendants` pour afficher si une transaction signale explicitement ou non que son dépensier souhaite qu'elle soit remplacée
  par une transaction dépensant l'une quelconque des mêmes entrées avec des frais plus élevés, comme décrit dans [BIP125][].

- [C-Lightning #1874][] a étiqueté sa première version candidate pour la version 0.6.1.

- [C-Lightning #1870][] a réduit le nombre d'endroits où il fait référence à 1 000 unités de poids comme à un « sipa » et a commencé à les
  appeler par le terme plus largement accepté de « kiloweights » (kw).

  La PR a également apporté plusieurs améliorations à sa gestion des frais, tant pour les transactions on-chain d'ouverture et de fermeture
  de canaux où C-Lightning délègue l'estimation des frais à Bitcoin Core, que pour les frais dans les canaux de paiement.

- [C-Lightning #1854][] a implémenté des parties supplémentaires de [BOLT2][], en particulier liées au champ `option_data_loss_protect`,
  afin d'améliorer la gestion des cas où votre nœud semble avoir perdu des données essentielles---une valeur d'engagement---ou lorsque le
  nœud distant envoie des données d'engagement invalides et ment possiblement délibérément.

---
{% include references.md %}
{% include linkers/issues.md issues="14032,12254,12676,1874,1870,1854" %}

[dandelion protocol]: https://arxiv.org/abs/1701.04439
[bcc 0.17]: https://bitcoincore.org/bin/bitcoin-core-0.17.0/
[timewarp maxwell]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016316.html
[timewarp lau]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016320.html
[BOLT2]: https://github.com/lightningnetwork/lightning-rfc/blob/master/02-peer-protocol.md
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}
[bse 78355]: {{bse}}78355
[bse 77764]: {{bse}}77764
[bse 72775]: {{bse}}72775
[information theoretic perfect privacy]: https://en.wikipedia.org/wiki/Information-theoretic_security
[bip151 update]: https://gist.github.com/jonasschnelli/c530ea8421b8d0e80c51486325587c52
[newhope]: https://newhopecrypto.org/
