---
title: 'Bulletin Hebdomadaire Bitcoin Optech #0'
permalink: /fr/newsletters/2018/06/08/
name: 2018-06-08-newsletter-fr
slug: 2018-06-08-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
version: 1
excerpt: Un numéro d'essai de la newsletter d'Optech, comprenant des informations sur l'opcode `OP_CODESEPARATOR`, le protocole de minage BetterHash et les filtres de blocs compacts BIP157/158.
---
**Ce bulletin du 8 juin 2018 était un essai de prévisualisation du bulletin Optech.**

*Nouvelles techniques sur Bitcoin du vendredi dernier à ce jeudi, du 1er juin au 7 juin.*

## Résumé

Une nouvelle version de maintenance de Bitcoin Core arrive bientôt avec un changement de politique de relais, le taux de hachage a augmenté
rapidement donc cela pourrait être un bon moment pour envoyer des transactions à faibles frais, les fournisseurs de portefeuilles peuvent
vouloir étudier la proposition [BIP174][BIP174] avant qu'elle ne soit entièrement implémentée, les filtres pour clients légers P2P font
l'objet de nombreuses discussions, des retours sont demandés sur des propositions visant à modifier la sérialisation des clés privées et la
manière dont les pools de minage communiquent avec leurs hacheurs, et Bitcoin Core fusionne une optimisation pour construire des arbres de
Merkle jusqu'à environ 7x plus vite.

[BIP174]: https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki

## Points d'action clés

- **Vérifier l'utilisation de l'opcode `CodeSeparator` :** Bitcoin Core 0.16.1, dont la sortie est attendue d'ici environ la semaine
  prochaine, ne [relaiera plus][standardness_rules] les transactions legacy (non-segwit) utilisant cet opcode. Autant que les contributeurs
  de Bitcoin Core le sachent, personne n'utilise cet opcode, mais si votre organisation l'utilise ou prévoit de l'utiliser, vous devriez
  immédiatement [contacter un développeur du protocole][contact_dev] ou un membre de l'équipe Optech dès que possible afin de les en
  informer. En fin de compte, il est possible que cet opcode soit supprimé du protocole Bitcoin pour les transactions legacy via un soft
  fork.

[contact_dev]: https://bitcoincore.org/en/contact/
[standardness_rules]: https://github.com/bitcoin/bitcoin/pull/11423

- **[Tester les versions candidates][rc] pour Bitcoin Core version 0.16.1.** RC1 est disponible maintenant ; RC2 sera probablement
  disponible sous peu. Cette version contiendra des corrections de bugs particulièrement importantes pour les mineurs. Il n'y a pas de
  changements majeurs pour les dépensiers-récepteurs et les fournisseurs d'API, mais ils peuvent bénéficier de corrections de bugs.

[rc]: https://bitcoincore.org/bin/bitcoin-core-0.16.1/

## Mises à jour du tableau de bord

- **Augmentation du taux de hachage :** la difficulté de minage a augmenté de presque 15 % cette semaine et les moyennes à plus court terme
  du taux de hachage du réseau montrent une croissance continue. Cela signifie que les blocs sont produits plus fréquemment que la normale
  et cela maintiendra probablement les frais de transaction bas tant que la tendance se poursuivra. C'est un bon moment pour [consolider des
  sorties de transaction][consolidate] ou autrement envoyer des transactions à faibles frais.

[consolidate]: https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#Consolidation

- **Transactions à très faibles frais :** une augmentation du nombre de transactions à très faibles frais payant moins de 10 nanobitcoins
  par vbyte a été observée sur des nœuds avec une politique d'acceptation des transactions non par défaut (la politique par défaut consiste
  à rejeter les transactions payant moins de 10 nBTC/vbyte). Cela peut indiquer des portefeuilles mal configurés payant des frais trop
  faibles, ou cela peut indiquer que certains dépensiers pensent qu'il s'agit d'une stratégie viable pour économiser sur les frais. Il peut
  être utile d'expérimenter pour déterminer si ces frais extrêmement faibles peuvent être utilisés pour des consolidations et d'autres
  transferts intraportefeuille non sensibles au temps.

## Nouvelles

- **Discussion et revue de [BIP174][BIP174] en cours :** ce BIP crée un format standardisé permettant aux portefeuilles de partager de
  manière fiable des informations liées à des transactions non signées et partiellement signées. Il est prévu qu'il soit implémenté dans
  Bitcoin Core et puisse également être implémenté dans d'autres portefeuilles, permettant aux portefeuilles logiciels, portefeuilles
  matériels, et portefeuilles hors ligne (cold) d'interagir facilement entre eux pour les transactions à signature unique comme
  multi-signatures. Ce BIP a le potentiel de devenir une norme de l'industrie et tous les principaux fournisseurs de portefeuilles sont donc
  encouragés à étudier la spécification.

  La [proposition d'implémentation de BIP174][PR12136] avait auparavant été ajoutée à la [file de revue haute priorité][high priority] de
  Bitcoin Core et a suscité d'importantes discussions cette semaine, avec au moins un bug découvert et un développeur du protocole suggérant
  que certaines parties de la proposition peuvent être séparées.

[BIP174]: https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki
[PR12136]: https://github.com/bitcoin/bitcoin/pull/12136
[high priority]: https://github.com/bitcoin/bitcoin/projects/8

- **Filtres de clients légers [BIP157][BIP157]/[BIP158][BIP158] :** ces BIP permettent aux nœuds de créer un index compact des données de
  transaction pour chaque bloc de la chaîne puis d'en distribuer des copies aux clients légers qui les demandent. Le client peut alors
  déterminer en privé si le bloc peut ou non contenir l'une de ses transactions.

  Les données exactes qui devraient être indexées ont été [largement discutées][BIP158 discussion] sur la liste de diffusion cette semaine.
  Cela n'affecte probablement pas directement la plupart des grands récepteurs-dépensiers et services d'API, mais les fournisseurs prévoyant
  de publier des portefeuilles utilisant le protocole réseau pair à pair peuvent vouloir examiner les BIP.

  La PR Bitcoin Core [#13243][PR 13243], fusionnée cette semaine, fait partie d'un effort visant à apporter cette fonctionnalité à Bitcoin
  Core.

[BIP157]: https://github.com/bitcoin/bips/blob/master/bip-0157.mediawiki
[BIP158]: https://github.com/bitcoin/bips/blob/master/bip-0158.mediawiki
[BIP158 discussion]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-June/016057.html
[PR 13243]: https://github.com/bitcoin/bitcoin/pull/13243

- **[BIP proposé][bech32 keys] pour la sérialisation des clés privées et des portefeuilles HD :** actuellement, les clés privées sont
  généralement transmises en utilisant le même encodage que les adresses Bitcoin legacy, et les clés étendues et graines de portefeuilles HD
  sont transmises en utilisant soit le même format, soit l'hexadécimal, soit une phrase mnémonique. Cette nouvelle proposition permettrait
  d'utiliser le format bech32 utilisé pour les adresses segwit natives.

  La [discussion][bech32 keys discussion] s'est concentrée sur la question de savoir s'il fallait ou non utiliser exactement le standard
  bech32 ou une modification de celui-ci qui serait plus résistante aux erreurs de transcription et de perte de données. Les services qui
  prévoient d'accepter ou de distribuer du matériel de clés secrètes peuvent souhaiter contribuer à la revue de la spécification.

[bech32 keys]: https://gist.github.com/jonasschnelli/68a2a5a5a5b796dc9992f432e794d719
[bech32 keys discussion]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-June/016065.html

- **[Protocole de minage BetterHash][BetterHash spec] :** un remplacement proposé pour le protocole de minage Stratum actuellement utilisé
  presque universellement par les pools de minage pour distribuer du travail aux mineurs individuels. La proposition affirme fournir une
  meilleure sécurité pour l'opérateur du pool et permet aux mineurs individuels de sélectionner les transactions qu'ils incluent dans leurs
  blocs, augmentant la résistance de Bitcoin à la censure et rendant aussi possiblement les mineurs utilisant le protocole plus efficaces.
  Le protocole est porté par le développeur et opérateur du [réseau FIBRE][FIBRE] utilisé par presque tous les mineurs.

  Le protocole est en développement semi-privé depuis un certain temps et n'est distribué pour commentaire public que maintenant. Les
  organisations prévoyant de vendre ou d'exploiter du matériel de minage sont encouragées à examiner le protocole, de même que tous les
  groupes ou individus souhaitant des changements aux règles de consensus de Bitcoin afin que le protocole puisse potentiellement être rendu
  compatible à l'avenir avec ces changements. Il n'y a pas encore eu beaucoup de [discussion sur la liste][BetterHash discussion] à propos
  de la proposition.

[BetterHash spec]: https://github.com/TheBlueMatt/bips/blob/betterhash/bip-XXXX.mediawiki
[FIBRE]: http://bitcoinfibre.org/
[BetterHash discussion]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-June/016077.html

## Ce jour-là dans l'historique des commits Bitcoin…

- **<!--n-->2017 :** Andrew Chow a rédigé le commit [ec6902d][commitec6902d] ouvrant la voie à la suppression des dernières parties de la
  fonctionnalité déroutante de « safe mode » ajoutée à Bitcoin 0.3.x après l'[incident de dépassement de valeur][value overflow].

[commitec6902d]: https://github.com/bitcoin/bitcoin/commit/ec6902d0ea2bbe75179684fc71849d5e34647a14
[value overflow]: https://en.bitcoin.it/wiki/Value_overflow_incident

- **<!--n-->2016 :** La PR de Luke Dashjr [#7935][PR7953] a été fusionnée, ajoutant le support des versionbits [BIP9] à l'appel RPC
  GetBlockTemplate, permettant aux mineurs de signaler leur prise en charge de futurs soft forks—comme le soft fork qui a activé [BIP141]
  segregated witness.

[PR7953]: https://github.com/bitcoin/bitcoin/pull/7935
[BIP9]: https://github.com/bitcoin/bips/blob/master/bip-0009.mediawiki
[BIP141]: https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki

- **<!--n-->2015 :** Gavin Andresen a rédigé le commit [65b94545][commit65b94545] afin d'affiner les critères qu'un nœud utilise pour
  détecter qu'il pourrait ne plus recevoir de blocs de la meilleure chaîne de blocs.

[commit65b94545]: https://github.com/bitcoin/bitcoin/commit/65b94545036ae6e38e79e9c7166a3ba1ddb83f66

- **<!--n-->2014 :** Cozz Lovan a rédigé le commit [95a93836][commit95a93836] supprimant une partie legacy de l'interface graphique qui
  supposait que tout frais de transaction inférieur à 0,01 BTC constituait de faibles frais de transaction.

[commit95a93836]: https://github.com/bitcoin/bitcoin/commit/95a93836d8ab3e5f2412503dfafdf54db4f8c1ee

- **<!--n-->2013 :** Wladimir van der Laan a rédigé le commit [3e9c8ba][commit3e9c8ba] corrigeant un bug lié au répertoire de données.

[commit3e9c8ba]: https://github.com/bitcoin/bitcoin/commit/3e9c8bab54371364f8e70c3b44e732c593b43a76

- **<!--n-->2012 :** Luke Dashjr a rédigé plusieurs commits (par ex. [9655d73][commit9655d73]) liés à l'activation du support IPv6.

[commit9655d73]: https://github.com/bitcoin/bitcoin/commit/9655d73f49cd4da189ddb2ed708c26dc4cb3babe

- **<!--n-->2011, 2010, 2009 :** aucun commit daté du 8 juin.
