---
title: 'Bulletin Hebdomadaire Bitcoin Optech #41'
permalink: /fr/newsletters/2019/04/09/
name: 2019-04-09-newsletter-fr
slug: 2019-04-09-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine demande des tests pour les versions candidates de Bitcoin Core et LND, décrit une discussion à propos des
instantanés UTXO pour une synchronisation initiale rapide des nœuds, et fournit la couverture habituelle du support d'envoi bech32 et des
fusions notables dans les projets d'infrastructure Bitcoin populaires.

{% include references.md %}

## Mesures à prendre

- **Aidez à tester Bitcoin Core 0.18.0 RC3 :** La troisième Release Candidate (RC) de la prochaine version majeure de Bitcoin Core a été
  [publiée][0.18.0]. Il s'agit peut-être de la version de test finale, nous encourageons donc les organisations et les utilisateurs experts
  à la tester rapidement s'ils veulent s'assurer que d'éventuelles régressions soient détectées avant la publication. Veuillez utiliser [ce
  ticket][Bitcoin Core #15555] pour signaler vos retours.

- **Aidez à tester LND 0.6-beta RC3 :** les première, deuxième et troisième RC de la prochaine version majeure de LND ont été [publiées][lnd
  releases] cette semaine. Les tests par les organisations et les utilisateurs expérimentés de LN sont encouragés afin de détecter toute
  régression ou tout problème sérieux qui pourrait affecter les utilisateurs de la version finale. [Ouvrez un nouveau ticket][lnd issue] si
  vous découvrez des problèmes.

## Nouvelles

- **Discussion à propos d'un mécanisme assumed-valid pour les instantanés UTXO :** Lorsque les développeurs de Bitcoin Core préparent une
  nouvelle version majeure, un développeur sélectionne le hachage d'un bloc récent de la meilleure chaîne de blocs. D'autres contributeurs
  bien connus vérifient leurs nœuds personnels et s'assurent que ce hachage fait bien partie de la meilleure chaîne de blocs, puis ajoutent
  ce hachage au logiciel comme bloc « assumed valid ». Lorsque de nouveaux utilisateurs démarrent Bitcoin Core pour la première fois, le
  programme choisit alors par défaut[^full-chain-verification] de sauter l'évaluation des scripts dans toutes les transactions incluses dans
  les blocs précédant le bloc assumed valid. Le programme continue néanmoins à suivre les changements de propriété des bitcoins produits par
  chaque transaction dans un index appelé l'ensemble des Unspent Transaction Output (UTXO). Bien que l'examen de chaque changement
  historique de propriété prenne toujours du temps, le simple fait d'ignorer la vérification des scripts réduit le temps de synchronisation
  initiale d'environ 80% selon des [tests][0.14 tests]. Gregory Maxwell, qui a [implémenté la fonctionnalité assumed valid][Bitcoin Core
  #9484], a soutenu que « Parce que la validité de l'historique d'une chaîne est un simple fait objectif, il est [facile] de revoir ce
  paramètre. »

  Cette semaine, James O'Beirne a lancé un [fil][assumeutxo thread] sur la liste de diffusion Bitcoin-Dev à propos du fait de prendre un
  hachage de l'ensemble UTXO à un bloc particulier, de faire vérifier par plusieurs contributeurs bien connus qu'ils obtiennent le même
  hachage, puis de faire en sorte que les nœuds Bitcoin Core fraîchement installés utilisent par défaut ce hachage pour télécharger
  exactement le même ensemble UTXO. Cela permettrait à un nœud tout juste démarré de sauter non seulement les scripts mais aussi toutes les
  données de la chaîne de blocs précédant le bloc assumed valid, réduisant peut-être les besoins en temps pour démarrer un nœud aujourd'hui
  de 95 % ou plus (et certainement davantage à mesure que la chaîne de blocs continue de croître). La vérification des anciens blocs et
  transactions pourrait ensuite être effectuée en arrière-plan après que l'utilisateur ait déjà commencé à utiliser son nœud, lui donnant
  finalement la même sécurité qu'un utilisateur ayant désactivé cette fonctionnalité. C'est une vieille idée et cela fait partie de la
  motivation pour la recherche sur d'autres techniques telles que les [engagements UTXO rapidement actualisables][fast updatable UTXO commitments] et les [sauvegardes
  automatiques de levelDB][automatic leveldb backups].

  La discussion a principalement porté sur la question de savoir si c'était ou non une bonne idée. Les arguments en sa faveur incluent le
  fait qu'elle rend le démarrage d'un nouveau nœud bien plus simple et qu'elle ne semble pas modifier le modèle de confiance pour quiconque
  fait déjà confiance à la revue par les pairs de son équipe de développement. Les arguments contre incluent la crainte que des
  synchronisations initiales rapides avec un ensemble UTXO assumed valid ne masquent le fait que les augmentations de taille des blocs
  rendent une synchronisation initiale complète depuis zéro beaucoup plus coûteuse ; si la taille des blocs augmentait trop, il pourrait
  devenir impossible pour quiconque disposant de moyens modestes de jamais vérifier sans confiance l'état UTXO de Bitcoin, forçant les
  nouveaux utilisateurs à faire confiance aux utilisateurs existants.

## Bech32 sending support

*Semaine 4 sur 24. Jusqu'au deuxième anniversaire du verrouillage du soft fork segwit le 24 août 2019, le bulletin Optech contiendra cette
section hebdomadaire qui fournit des informations pour aider les développeurs et les organisations à mettre en œuvre le support d'envoi
bech32---la capacité de payer des adresses segwit natives. Cela [ne nécessite pas d'implémenter segwit][bech32 series] vous-même, mais cela
permet aux personnes que vous payez de bénéficier de tous les multiples avantages de segwit.*

{% capture bech32_section %}{% include specials/bech32/04-ecc.md %}{% endcapture %}
{{ bech32_section
  | replace: "/en/newsletters/", "/fr/newsletters/"
  | replace: "/fr/newsletters/2019/04/02/#bech32-sending-support",
             "/fr/newsletters/2019/04/02/#prise-en-charge-de-lenvoi-vers-bech32"
}}

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [LND][lnd repo], [C-Lightning][c-lightning repo],
[Eclair][eclair repo], [libsecp256k1][libsecp256k1 repo], et [Bitcoin Improvement Proposals (BIPs)][bips repo]. Note : toutes les fusions
décrites pour Bitcoin Core et LND concernent leurs branches de développement master ; certaines peuvent aussi être rétroportées vers leurs
versions en attente de publication.*

- [Bitcoin Core #15596][] met à jour la RPC `sendmany` pour supprimer le paramètre `minconf`, qui [ne fonctionnait pas de la manière
  attendue par les gens][sendmany wackiness]. Désormais, les paramètres par défaut du portefeuille sont toujours utilisés. Ces paramètres
  par défaut consistent à ne pas dépenser les sorties reçues d'autres personnes tant qu'elles ne sont pas confirmées et à éventuellement
  permettre de dépenser les sorties de monnaie rendue non confirmées provenant de vous-même selon le paramètre de configuration
  `spendzeroconfchange`. C'est de la même manière que la RPC `sendtoaddress`, plus couramment utilisée, a toujours fonctionné.

- [LND #2885][] modifie la façon dont LND tente de se reconnecter à tous ses pairs lorsqu'il revient en ligne. Auparavant, il tentait
  d'ouvrir des connexions à tous ses pairs persistants d'un seul coup. Désormais, il répartit les connexions sur une fenêtre de 30 secondes
  afin de réduire l'utilisation mémoire de pointe d'environ 20 %. Cela signifie également que les messages envoyés à intervalles réguliers,
  tels que les pings, ne se produisent pas au même moment pour tous les pairs.

- [LND #2740][] implémente un nouveau sous-système de gossiper qui place ses pairs dans deux groupes, gossiper actif ou gossiper passif. Les
  gossipers actifs sont des pairs communiquant selon la manière actuellement normale de partager tout leur état avec votre nœud ; les
  gossipers passifs sont des pairs auxquels vous ne demanderez que des mises à jour spécifiques. Comme la plupart des gossipers actifs vous
  enverront les mêmes mises à jour que tous les autres gossipers, en avoir plus de quelques-uns constitue un gaspillage de votre bande
  passante, donc ce code garantira que vous ayez par défaut 3 gossipers actifs puis placera tous les autres gossipers dans la catégorie
  passive. De plus, le nouveau code essaiera de ne demander des mises à jour qu'à un seul gossiper actif à la fois de façon [round-robin][]
  afin d'éviter de synchroniser les mêmes mises à jour depuis différents nœuds. Dans un test décrit sur la PR, ce changement a réduit la
  quantité de données de gossip demandées de 97,5 %.

- [LND #2313][] implémente du code et des RPC qui permettent aux nœuds LND d'utiliser des sauvegardes statiques de canaux. Cela repose sur
  le protocole Data Loss Protection (DLP) implémenté dans [LND #2370][] pour permettre de sauvegarder un fichier unique contenant tout
  l'état actuel de vos canaux à n'importe quel moment puis d'activer une restauration à partir de ce fichier à n'importe quel moment
  ultérieur afin d'obtenir que votre pair distant vous aide à fermer n'importe lequel de ces canaux dans leur état le plus récent (à
  l'exclusion des paiements routés non finalisés (HTLCs)). Remarque : malgré le terme « statique » dans le nom de cette fonctionnalité, cela
  ne ressemble pas à une sauvegarde unique de portefeuille HD. C'est une sauvegarde qui doit être effectuée au moins aussi souvent qu'à
  chaque fois que vous ouvrez un nouveau canal---mais c'est bien mieux que l'état actuel où vous pourriez ne pouvoir récupérer aucun fonds
  d'aucun de vos canaux si vous perdez des données. D'autres améliorations de la robustesse des sauvegardes sont mentionnées dans la
  description de la PR. Voir la description de LND #2370 dans le [Bulletin #31][le bulletin #31] pour plus de détails sur le fonctionnement de la
  sauvegarde et de la récupération basées sur DLP. L'intégration de cette amélioration majeure des sauvegardes était l'un des principaux
  objectifs de la future version LND 0.6-beta.

- [BIPs #772][] retire [BIP151][] à la demande de son auteur, qui a proposé un schéma alternatif pour le [chiffrement du protocole P2P][p2p protocol encryption].

- [BIPs #756][] assigne [BIP127][] à une spécification pour l'outil de preuve de réserves décrit dans le [Bulletin #33][le bulletin #33]. Le texte
  préliminaire du BIP est fusionné.

## Footnotes

[^full-chain-verification]:
    Le mécanisme assumed valid est activé par défaut mais peut être désactivé en démarrant Bitcoin Core avec le
    paramètre de configuration `assumevalid=0` (ou `noassumevalid`). Cela permettra à votre nœud de vérifier complètement chaque transaction de
    la chaîne de blocs afin de s'assurer qu'elle suit toutes les règles de consensus. Notez que cela n'aura aucun effet sur les blocs que votre
    nœud a déjà traités, donc si vous voulez vérifier les scripts dans les anciens blocs, vous devrez avoir cette option activée dès la première
    fois que vous utiliserez votre nœud ou vous devrez redémarrer Bitcoin Core une fois avec l'option de configuration `reindex-chainstate`.
    Pour les nœuds élagués, la réindexation nécessite de retélécharger tous les blocs élagués.

{% include linkers/issues.md issues="15555,9484,772,756,2313,15596,2885,2740,2370" %}
[0.18.0]: https://bitcoincore.org/bin/bitcoin-core-0.18.0/
[0.14 tests]: https://bitcoincore.org/en/2017/03/08/release-0.14.0/#ibd
[p2p protocol encryption]: https://gist.github.com/jonasschnelli/c530ea8421b8d0e80c51486325587c52
[lnd releases]: https://github.com/lightningnetwork/lnd/releases
[lnd issue]: https://github.com/lightningnetwork/lnd/issues/new
[assumeutxo thread]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-April/016825.html
[fast updatable UTXO commitments]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2017-May/014337.html
[automatic leveldb backups]: https://github.com/bitcoin/bitcoin/issues/8037
[round-robin]: https://en.wikipedia.org/wiki/Round-robin_scheduling
[bitcoin core 0.5.0]: https://bitcoin.org/en/release/v0.5.0
[sendmany wackiness]: https://github.com/bitcoin/bitcoin/pull/15595#issue-260932169
[bech32 series]: /en/bech32-sending-support/
[le bulletin #31]: /fr/newsletters/2019/01/29/#lnd-2370
[le bulletin #33]: /fr/newsletters/2019/02/12/#publication-d-un-outil-pour-generer-et-verifier-des-preuves-de-possession-de-bitcoins
