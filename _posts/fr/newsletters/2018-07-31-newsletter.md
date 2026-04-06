---
title: 'Bulletin Hebdomadaire Bitcoin Optech #6'
permalink: /fr/newsletters/2018/07/31/
name: 2018-07-31-newsletter-fr
slug: 2018-07-31-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine comprend le tableau de bord habituel et les actions à entreprendre, un article de fond du développeur Anthony
Towns sur la consolidation de quatre millions d'UTXO chez Xapo, des nouvelles à propos de possibles mises à niveau du système de script de
Bitcoin, des liens vers quelques questions et réponses très plébiscitées sur Bitcoin Stack Exchange, ainsi que quelques commits notables
dans les branches de développement des projets Bitcoin Core, Lightning Network Daemon (LND) et C-lightning.

## Action items

- **Bitcoin Core 0.16.2 released:** une version mineure qui apporte des corrections de bugs et de petites améliorations. Si vous utilisez
  les RPC [abandontransaction][rpc abandontransaction] ou [verifytxoutproof][rpc verifytxoutproof], vous devriez tout particulièrement
  envisager une mise à niveau. Sinon, nous vous recommandons d'examiner les [notes de version][bitcoin core 0.16.2] pour les autres
  changements qui pourraient affecter votre activité et de mettre à niveau lorsque cela vous convient.

## Dashboard items

- **Frais toujours bas :** le taux de hachage a augmenté la difficulté de plus de 14 % durant la période de réajustement de 2 016 blocs qui
  s'est terminée dimanche, donnant un temps moyen entre les blocs de 8 minutes et 41 secondes. Cela a aidé à absorber la charge
  transactionnelle accrue due à la spéculation sur les prix de la semaine passée. Immédiatement après un réajustement de difficulté, le
  temps moyen entre les blocs est rétabli à 10 minutes.

  Alors que nous passons du calme habituel des transactions du week-end à la nouvelle semaine, il existe une possibilité d'augmentation
  rapide des estimations de frais de transaction. Nous recommandons de faire preuve de prudence lors de l'envoi de grosses transactions à
  faibles frais telles que les consolidations jusqu'à se rapprocher du week-end, quand le volume de transactions commence à nouveau à
  diminuer.

## Rapport de terrain : Consolidation de 4 millions d'UTXO chez Xapo

*par [Anthony Towns](https://twitter.com/ajtowns), développeur sur Bitcoin Core chez [Xapo][]*

{% include articles/towns-xapo-consolidation.md hlevel='###' %}

## Nouvelles

- **"Improvements in the Bitcoin Scripting Language" par Pieter Wuille :** une présentation la semaine dernière donnant une vue d'ensemble
  de haut niveau de plusieurs améliorations possibles à court terme pour Bitcoin. Nous recommandons fortement de regarder la [vidéo][sfdev
  video], de consulter les [diapositives][sipa slides], ou de lire la [transcription][kanzure transcript] (avec références) par Bryan
  Bishop---mais si vous êtes trop occupé, voici la conclusion de Wuille : "mon objectif initial ici est les signatures Schnorr et taproot.
  La raison de cette focalisation est que la capacité à faire apparaître n'importe quelle entrée et sortie dans le cas coopératif comme
  identiques est un gain énorme pour le fonctionnement de l'exécution des scripts.

  "Schnorr est nécessaire pour cela car sans lui nous ne pouvons pas encoder plusieurs parties dans une seule clé. Le fait d'avoir plusieurs
  branches là-dedans est un changement relativement simple.

  "Si vous regardez les modifications du consensus nécessaires pour ces choses, c'est en réalité remarquablement faible, quelques dizaines
  de lignes de code. On dirait que la majeure partie de la complexité réside dans l'explication de l'utilité de ces choses et de la manière
  de les utiliser, et non pas tant dans leur impact sur les règles de consensus.

  "Des choses comme l'agrégation, je pense, sont quelque chose qui pourra être fait après que nous aurons exploré diverses options pour des
  améliorations structurelles du langage de script, une fois qu'il sera clair comment la structuration devrait être faite, parce que nous
  apprendrons probablement des déploiements comment ces choses sont utilisées en pratique. C'est ce sur quoi je travaille avec un certain
  nombre de collaborateurs et nous proposerons espérons-le quelque chose bientôt, et c'est la fin de ma présentation."

[sfdev video]: https://www.youtube.com/watch?v=YSUVRj8iznU
[sipa slides]: https://prezi.com/view/YkJwE7LYJzAzJw9g1bWV/
[kanzure transcript]: http://diyhpl.us/wiki/transcripts/sf-bitcoin-meetup/2018-07-09-taproot-schnorr-signatures-and-sighash-noinput-oh-my/

## Questions et réponses sélectionnées de Bitcoin Stack Exchange

{% comment %}<!--
https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech cherchent des réponses à leurs
questions---ou quand nous avons quelques moments libres pour aider à répondre aux questions d'autres personnes. Dans cette nouvelle rubrique
mensuelle, nous mettons en lumière certaines des questions et réponses les mieux votées publiées au cours du mois écoulé.*

- [Schnorr versus ECDSA][bse 77235] : dans cette réponse, le développeur du protocole Bitcoin Pieter Wuille explique certains des principaux
  avantages du schéma de signature Schnorr par rapport au schéma actuel de signature ECDSA de Bitcoin.

- [Why does HD key derivation stop working after a certain index in BIP44 wallets?][bse 76998] : un développeur testant son portefeuille
  constate qu'un paiement envoyé à des indices de clé peu élevés fonctionne comme prévu, mais que les paiements envoyés à des indices plus
  élevés n'apparaissent jamais dans ses portefeuilles. Une réponse de Viktor T. révèle pourquoi.

- [The maximum size of a Bitcoin DER-encoded signature is...][bse 77191] : dans cette réponse, Pieter Wuille fournit les calculs pour
  déterminer la taille d'une signature Bitcoin. Comme mentionné dans le [Bulletin #3][], la taille maximale avec un portefeuille ordinaire
  est de 72 octets---mais Wuille explique comment vous pouvez créer une transaction non standard avec une signature de 73 octets et pourquoi
  vous pourriez penser avoir vu une signature de 74 voire 75 octets.

- [If you can use almost any opcode in P2SH, why can't you use them in scriptPubKeys?][bse 76541] : dans cette réponse, le rédacteur
  technique Bitcoin David A. Harding explique pourquoi les premières versions de Bitcoin restreignaient les types de transactions pouvant
  être envoyées aux "transactions standards" et pourquoi la plupart de ces restrictions sont toujours en place même si presque tous les
  opcodes sont désormais disponibles pour un usage standard via P2SH et segwit P2WSH.

## Changements notables dans le code et la documentation

*Un bref aperçu des fusions et commits récents réalisés dans divers projets Bitcoin open source.*

{% comment %}
bitcoin: git log --merges 07ce278455757fb46dab95fb9b97a3f6b1b84faf..ef4fac0ea5b4891f4529e4b59dfd1f7aeb3009b5 lnd: git log --topo-order -p
271db7d06da3edf696e22109ce0277eaff11cc5e..92b0b10dc75de87be3a9f895c8dfc5a84a2aec7a c-lightning: git log --topo-order -p
d84d358562a3bcdf48856fdea24511907ff53fd9..0b597f671aa31c1c56d32a554fcdf089646fc7c1
{% endcomment %}

- [Bitcoin Core #12257][] : si vous démarrez Bitcoin Core avec l'option `-avoidpartialspends`, le portefeuille dépensera par défaut toutes
  les sorties reçues à la même adresse dès que l'une d'entre elles devrait être dépensée. Cela empêche que deux sorties vers la même adresse
  soient dépensées dans des transactions distinctes, ce qui est une manière courante par laquelle la réutilisation d'adresse réduit la
  confidentialité. L'inconvénient est que cela peut rendre les transactions plus grandes que leur taille minimale nécessaire. Les
  entreprises Bitcoin utilisant le portefeuille intégré de Bitcoin Core et n'ayant pas besoin de cette confidentialité supplémentaire
  peuvent tout de même vouloir activer cette option lorsque les frais sont faibles afin de consolider automatiquement les entrées liées.

- [LND #1617][] : met à jour les estimations de la taille des transactions on-chain afin d'empêcher que des transactions paient
  accidentellement des frais trop faibles et restent bloquées. [Ce commit][lnd ee2f2573c1b1b33288d05ba59a1e8ef9e8fb621c] peut être
  intéressant pour quiconque s'interroge sur la taille des transactions (et des parties de transactions) produites dans le protocole actuel.

- [LND #1531][] : le daemon ne recherche plus les dépenses dans la mempool---il attend d'abord qu'elles fassent partie confirmée d'un bloc.
  Cela permet au même code de fonctionner sur des nœuds complets comme Bitcoin Core et btcd ainsi que sur des clients légers basés sur
  [BIP157][] qui n'ont pas accès aux transactions non confirmées. Cela fait partie de l'effort continu visant à aider les personnes sans
  nœud complet à utiliser LN.

- Dans plusieurs commits, les développeurs de [C-lightning][] ont pour l'essentiel achevé la transition consistant à gérer les fonctions
  liées aux pairs dans `gossipd` vers leur gestion dans `channeld` ou `connectd` selon le cas.

- C-lightning a amélioré sa gestion des secrets afin que les secrets et signatures soient toujours générés et stockés par un daemon séparé
  des parties du système directement connectées au réseau.

{% include references.md %}
{% include linkers/issues.md issues="1617,1531,12257" %}

{% assign bse = "https://bitcoin.stackexchange.com/a/" %}
[bse 77235]: {{bse}}77235
[bse 76998]: {{bse}}76998
[bse 77191]: {{bse}}77191
[bse 76541]: {{bse}}76541

[lnd ee2f2573c1b1b33288d05ba59a1e8ef9e8fb621c]: https://github.com/lightningnetwork/lnd/commit/ee2f2573c1b1b33288d05ba59a1e8ef9e8fb621c
[bulletin #3]: /en/newsletters/2018/07/10/#transaction-fees-remain-very-low
[output script descriptors]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
