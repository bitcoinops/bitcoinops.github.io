---
title: 'Bulletin Hebdomadaire Bitcoin Optech #30'
permalink: /fr/newsletters/2019/01/22/
name: 2019-01-22-newsletter-fr
slug: 2019-01-22-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit une fonctionnalité LN proposée pour permettre d'effectuer des paiements spontanés et fournit notre plus
longue liste à ce jour de changements notables dans des projets populaires d'infrastructure Bitcoin.

## Nouvelles

- **PR ouverte pour les paiements LN spontanés :** le développeur du protocole LN Olaoluwa Osuntokun a ouvert une [pull request][spontaneous
  payments] pour permettre à un nœud LN d'envoyer un paiement à un autre nœud sans d'abord recevoir une facture. Cela tire parti du routage
  en oignon de LN, semblable à celui de Tor, en permettant à un dépensier de choisir une préimage, de la chiffrer de sorte que seul le nœud
  du destinataire puisse la déchiffrer, puis d'acheminer un paiement via LN comme d'habitude en utilisant le hachage de la préimage. Lorsque
  le paiement atteint le destinataire, celui-ci déchiffre la préimage et la divulgue aux nœuds de routage afin de réclamer le paiement.

  Les paiements spontanés aident dans les cas où les utilisateurs veulent simplement faire un suivi ad hoc des paiements ; par exemple, vous
  initiez un retrait de 10 mBTC depuis une plateforme d'échange et soit 10 mBTC apparaissent dans votre solde en quelques instants, soit
  vous contactez le support. Ou vous publiez simplement les informations de votre nœud et les utilisateurs peuvent vous envoyer des dons
  sans avoir à obtenir d'abord une facture. Pour suivre des paiements spécifiques, les utilisateurs devraient toutefois continuer à générer
  des factures qui peuvent être associées de manière unique à des commandes particulières ou à d'autres paiements attendus.

  La pull request d'Osuntokun pour LND est encore marquée comme un travail en cours au moment de la rédaction, nous ne savons donc pas
  encore quand cette fonctionnalité deviendra généralement disponible pour les utilisateurs de LND ni si d'autres implémentations LN
  fourniront également la même fonctionnalité d'une manière compatible.

## Optech recommande

Si vous préférez écouter de l'audio plutôt que lire le bulletin hebdomadaire d'Optech, Max Hillebrand de World Crypto Network a enregistré
des lectures de chaque bulletin à ce jour---offrant jusqu'à présent un total de plus de 6 heures de nouvelles techniques sur Bitcoin.
L'audio et la vidéo sont disponibles sur [YouTube][wcn optech playlist], et l'audio seul est également disponible sous forme de podcast via
[iTunes][wcn itunes] et [acast][wcn acast]. Optech remercie Max de s'être porté volontaire pour effectuer les lectures et de si bien les
réaliser. Nous encourageons toute personne qui préférerait recevoir le bulletin sous forme vidéo ou audio à suivre Max pour les prochaines
lectures.

## Changements notables dans le code

*Changements notables dans le code cette semaine dans [Bitcoin Core][bitcoin core repo], [LND][lnd repo], [C-Lightning][c-lightning repo],
[Eclair][eclair repo], et [libsecp256k1][libsecp256k1 repo].*

- [Bitcoin Core #14941][] rend synchrone la RPC `unloadwallet`. Elle ne retournera désormais qu'une fois le portefeuille spécifié
  complètement déchargé.

- [Bitcoin Core #14982][] ajoute une nouvelle RPC `getrpcinfo` qui fournit des informations sur l'interface RPC. Pour le moment, elle
  retourne un tableau `active_commands` listant toutes les RPC qui n'ont pas encore renvoyé de résultat.

- [LND #2448][] ajoute une watchtower autonome, lui permettant de « négocier des sessions avec des clients, accepter des mises à jour d'état
  pour des sessions actives, surveiller la chaîne pour des violations correspondant à des indices de violation connus, [et] publier des
  transactions de justice reconstruites pour le compte des clients de la tour. » Il s'agit de l'un des derniers éléments d'une
  implémentation initiale de watchtower qui peut aider à protéger les nœuds LN hors ligne contre le vol de leurs fonds---une fonctionnalité
  importante pour rendre LN suffisamment mature pour un usage général.

- [LND #2439][] ajoute la politique par défaut pour la watchtower, comme l'autorisation pour la tour de gérer un maximum de 1 024 mises à
  jour d'un client dans une seule session, l'autorisation pour la watchtower de recevoir une récompense de 1 % de la capacité du canal si la
  tour finit par défendre le canal, et la définition du taux de frais onchain par défaut pour les transactions de justice (transactions de
  remédiation de violation).

- [LND #2198][] donne à la RPC `sendcoins` un nouveau paramètre `sweepall` qui dépensera tous les bitcoins du portefeuille vers l'adresse
  spécifiée sans que l'utilisateur ait à préciser manuellement le montant.

- [C-Lightning #2232][] étend la commande `listpeers` avec un nouveau champ `funding_allocation_msat` qui renvoie les montants initialement
  placés dans un canal par chaque pair.

- [C-Lightning #2234][] étend la RPC `listchannels` pour accepter un paramètre `source` permettant de filtrer par identifiant de nœud. La
  même pull request fait également en sorte que la RPC `invoice` inclue des indications de route pour les canaux privés si vous n'avez aucun
  canal public, à moins que vous ne définissiez aussi le nouveau paramètre `exposeprivatechannels` à false. Les indications de route
  suggèrent une partie d'un chemin de routage au dépensier afin qu'il puisse envoyer des paiements via des nœuds qu'il ne connaissait pas
  auparavant.

- [C-Lightning #2249][] active à nouveau les plugins par défaut sur C-Lightning, mais une note est ajoutée à leur documentation indiquant
  que l'API est toujours « en développement actif ».

- [C-Lightning #2215][] ajoute une bibliothèque libplugin qui fournit une API de plugins en langage C.

- [C-Lightning #2237][] donne aux plugins la capacité d'enregistrer des hooks pour certains événements qui peuvent modifier la façon dont le
  processus principal gère ces événements. Un exemple donné dans le code est un plugin qui empêche le nœud LN de s'engager sur un paiement
  tant qu'une sauvegarde d'informations importantes concernant ce paiement n'a pas été effectuée.

- [Eclair #762][] ajoute un sondage limité. Le sondage dans LN consiste à envoyer un paiement invalide à un nœud et à attendre qu'il renvoie
  une erreur. Si le nœud ne renvoie pas d'erreur, cela signifie probablement que lui ou un autre nœud le long d'un chemin de paiement vers
  lui est hors ligne et incapable de traiter des paiements. Comme la sonde était un paiement invalide qui ne peut jamais être encaissé, le
  nœud émetteur peut immédiatement le traiter comme un paiement expiré sans risque de perte. Cette mise à jour d'Eclair permet uniquement de
  sonder les pairs directs d'un nœud---les nœuds avec lesquels Eclair a un canal ouvert.

{% include references.md %}
{% include linkers/issues.md issues="14941,14982,2448,2439,2198,2232,2234,2249,2215,2237,762" %}
[spontaneous payments]: https://github.com/lightningnetwork/lnd/pull/2455
[wcn optech playlist]: https://www.youtube.com/playlist?list=PLPj3KCksGbSY9pV6EI5zkHcut5UTCs1cp
[wcn itunes]: https://itunes.apple.com/us/podcast/the-world-crypto-network-podcast/id825708806
[wcn acast]: https://play.acast.com/s/world-crypto-network
