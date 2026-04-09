---
title: 'Bulletin Hebdomadaire Bitcoin Optech #9'
permalink: /fr/newsletters/2018/08/21/
name: 2018-08-21-newsletter-fr
slug: 2018-08-21-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine comprend une demande d'aide pour tester la prochaine version de Bitcoin Core, de brèves descriptions de projets
sur lesquels travaillent les contributeurs de Bitcoin Core, et une liste des fusions notables de la semaine passée.

## Action items

- **Consacrez du temps à tester les versions candidates de Bitcoin Core 0.17 :** dans les prochains jours, Bitcoin Core commencera à publier
  des Release Candidates (RCs) pour la version 0.17.0. Les organisations et les utilisateurs individuels prévoyant d'utiliser la 0.17 sont
  encouragés à tester les RCs afin de s'assurer qu'elles contiennent toutes les fonctionnalités dont vous avez besoin et qu'elles n'ont
  aucun bug qui affecterait votre fonctionnement. Il y a souvent plusieurs RCs pour une version majeure comme celle-ci, mais chaque RC peut
  théoriquement être la dernière RC, nous vous encourageons donc à tester aussi tôt que possible.

## Nouvelles

Aucune nouvelle significative n'a été publiée sur les listes de diffusion bitcoin-dev ou lightning-dev la semaine dernière, donc les
nouvelles de cette semaine se concentrent sur certains projets discutés lors de la réunion hebdomadaire de Bitcoin Core.

Le projet Bitcoin Core, comme la plupart des projets de logiciels libres et open source, est organisé de bas en haut, chaque contributeur
travaillant sur les choses qu'il juge importantes plutôt que de haut en bas avec des dirigeants de projet orientant le travail, donc il
arrive parfois---comme ce fut le cas la semaine dernière---que les développeurs résument brièvement entre eux ce sur quoi ils travaillent
pour l'avenir. Il est possible que certaines de ces initiatives échouent, mais il est également possible que certaines deviennent de futures
parties de Bitcoin Core. Voici un résumé des projets discutés :

- **Chiffrement du protocole P2P** sur lequel travaille Jonas Schnelli avec un accent à court terme sur le chiffrement non authentifié dans
  le style de [BIP151][] (mais peut-être en utilisant un mécanisme différent de celui décrit dans ce BIP). L'authentification des pairs (par
  ex. [BIP150][]) est probablement plus lointaine car une critique à son encontre est que la manière la plus simple de l'implémenter permet
  d'identifier facilement certains pairs et de réduire la confidentialité---un mécanisme plus avancé est donc souhaité pour les cas qui en
  ont besoin.

- **Améliorations des descripteurs de scripts de sortie** sur lesquelles travaille Pieter Wuille. L'idée de base a été décrite dans le
  [Bulletin #5][news5 news] mais Wuille étudie l'ajout de la prise en charge de constructions imbriquées et à seuil, par ex. : « importer
  `and(xpub/...,or(xpub/...,xpub/...))` dans votre portefeuille comme chaîne en watch-only par exemple et obtenir un [PSBT][BIP174] pour le
  signer. » Cela faciliterait l'ajout de la prise en charge des portefeuilles matériels à Bitcoin Core. La prise en charge serait également
  compatible avec les timelocks et hashlocks pour une utilisation avec des portefeuilles compatibles LN (matériels ou logiciels).

- **Prise en charge de RISC-V** sur laquelle travaille Wladimir van der Laan. Il s'agit d'une architecture CPU qui gagne rapidement en
  popularité comme concurrent potentiel des chipsets basés sur ARM, en particulier parmi les amateurs car la conception du CPU est open
  source. Un projet de plusieurs développeurs, dont Van der Laan, vise à terme à fournir des hachages générés de manière déterministe des
  binaires de Bitcoin Core produits en utilisant une compilation croisée RISC-V afin de s'assurer que des problèmes connus et des portes
  dérobées dans les chipsets x86_64 prédominants ne sont pas utilisés pour compromettre les builds binaires de Bitcoin Core. Van der Laan a
  connu plusieurs succès récents et a démarré « probablement le premier nœud bitcoin RISC-V au monde », qui a déjà synchronisé une partie de
  la chaîne.

- **Protocole de réconciliation d'ensembles efficace en bande passante pour les transactions** sur lequel travaillent Gregory Maxwell, Gleb
  Naumenko et Pieter Wuille. Cela pourrait permettre à un nœud qui a de nouvelles transactions dans son mempool d'informer un pair de ces
  transactions en communiquant une quantité de données « égale à la taille attendue des différences elles-mêmes ». Ceci est à comparer au
  protocole actuel où les nœuds communiquent l'existence d'une transaction en envoyant à leurs pairs son hachage de 32 octets. Les nœuds
  bien connectés peuvent recevoir ou envoyer plus d'une centaine de ces notifications pour chaque transaction de taille médiane de 224
  octets qu'ils traitent, ce qui entraîne un gaspillage significatif de la bande passante des nœuds de longue durée de vie (jusqu'à 90 %
  [selon][nmnkgl relay] les mesures de Naumenko, bien que des améliorations récentes de Bitcoin Core aient pu réduire ce chiffre). Maxwell
  travaille également à rendre possible pour un nœud nouvellement démarré (ou déconnecté depuis longtemps) de synchroniser efficacement la
  partie à frais élevés de son mempool depuis ses pairs en utilisant ce même mécanisme de base.

- **Routage stem résistant aux DoS pour le protocole Dandelion** sur lequel travaille Suhas Daftuar. Le [protocole Dandelion][] devrait
  rendre extrêmement difficile pour un adversaire de déterminer l'adresse IP de tout programme qui crée une transaction Bitcoin (même s'il
  n'utilise pas Tor), mais la nouvelle méthode de traitement privé pendant un certain temps des transactions non confirmées durant la phase
  « stem » doit être sécurisée contre des attaques qui pourraient gaspiller la bande passante et la mémoire des nœuds.

Pour des détails supplémentaires, veuillez consulter le [journal de conversation][2018-08-16 meeting log].

## Commits notables

*Commits notables cette semaine dans [Bitcoin Core][bitcoin core repo], [LND][lnd repo] et [C-lightning][core lightning repo].*

{% comment %}<!-- IMO, c-lightning only had 6 commits this week, mostly
minor doc updates, so no news for them. I'm still leaving them mentioned above for easy copy/paste next week. -harding -->{% endcomment %}

- Bitcoin Core 0.17 a été branché : cela permet aux développeurs de se concentrer sur la garantie de la stabilité, l'exhaustivité des
  traductions et d'autres fonctionnalités de publication sur cette branche, tandis que le développement de nouvelles fonctionnalités se
  poursuit sur la branche master. Cette section Commits notables se concentre uniquement sur la branche de développement master de chaque
  projet, donc les commits mentionnés à partir de ce point ont beaucoup moins de chances d'être inclus dans la version 0.17 de Bitcoin Core
  et ne devraient pas être attendus avant la version 0.18.

- [Bitcoin Core #13917][] et [Bitcoin Core #13960][] améliorent la gestion des transactions Bitcoin partiellement signées (PSBT) [BIP174][]
  dans des situations ambiguës.

- [Bitcoin Core #11526][] rend beaucoup plus facile la compilation de Bitcoin Core avec Microsoft Visual Studio 2017, y compris la
  possibilité d'utiliser le débogueur Visual Studio.

- [Bitcoin Core #13918][] fournit les taux de frais des 10e, 25e, 50e, 75e et 90e percentiles pour un bloc historique avec la RPC
  `getblockstats` introduite dans la branche de développement master il y a quelques mois.

- [LND #1693][] permet au mécanisme de financement autopilot de LND d'utiliser en option ses propres sorties de monnaie non confirmées pour
  les transactions de financement, lui permettant potentiellement d'ouvrir plusieurs canaux dans le bloc suivant.

  Note : c'était seulement la plus notable de plusieurs améliorations mineures (mais utiles) de la fonctionnalité autopilot fusionnées cette
  semaine.

- [LND #1460][] les commandes payinvoice et sendpayment nécessitent désormais une confirmation supplémentaire, bien que cela puisse être
  contourné avec le paramètre `--force` ou `-f`.

{% include references.md %}
{% include linkers/issues.md issues="13917,11526,13918,1693,1460,13960" %}

[news5 news]: /en/newsletters/2018/07/24/#first-use-of-output-script-descriptors
[protocole dandelion]: https://arxiv.org/abs/1701.04439
[2018-08-16 meeting log]: http://www.erisian.com.au/meetbot/bitcoin-core-dev/2018/bitcoin-core-dev.2018-08-16-19.03.log.html
[nmnkgl relay]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-April/015863.html
