---
title: 'Bulletin Hebdomadaire Bitcoin Optech #25'
permalink: /fr/newsletters/2018/12/11/
name: 2018-12-11-newsletter-fr
slug: 2018-12-11-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine suggère d'aider à tester une version candidate de maintenance de Bitcoin Core, fournit un lien vers un
explorateur de blocs moderne dont le code a été publié en open source, et décrit brièvement une suggestion pour que les hachages de
signature couvrent optionnellement la taille des transactions. Les changements de code notables apportés au cours de la semaine passée à des
projets d'infrastructure populaires sont également décrits.

## Actions requises

- **Aidez à tester Bitcoin Core 0.17.1RC1 :** la première version candidate de cette [version de maintenance][maintenance release] a été [mise en
  ligne][V0.17.1rc1]. Les tests par les entreprises et les utilisateurs individuels, à la fois du daemon et de l'interface graphique, sont
  grandement appréciés et aident à garantir une version de la plus haute qualité.

## Nouvelles

- **Explorateur de blocs moderne publié en open source :** après avoir récemment [annoncé][explorer announce] un nouveau site web
  d'explorateur de blocs, Blockstream a annoncé la [publication open source][explorer code announce] de son code backend et frontend. Le
  code prend en charge le réseau principal de Bitcoin, le réseau de test de Bitcoin et la sidechain Liquid.

  Bien que les explorateurs de blocs soient un pilier des applications web Bitcoin depuis 2010, nous notons que la méthode utilisée par les
  explorateurs de blocs consistant à maintenir plusieurs index sur l'ensemble des données de la chaîne de blocs présente intrinsèquement une
  mauvaise caractéristique de scalabilité---leur coût augmente au fil du temps à mesure que la chaîne de blocs grandit---et qu'il est donc
  généralement déconseillé de construire des logiciels ou services qui dépendent de votre propre explorateur de blocs. Faire confiance à
  l'explorateur de blocs de quelqu'un d'autre (ce qui est une mesure courante de réduction des coûts lorsque l'indexation des données par
  vous-même devient trop coûteuse) introduit une confiance envers un tiers dans le logiciel Bitcoin, augmente la centralisation et diminue
  la confidentialité. Si possible, il est préférable de construire des logiciels et des services d'une manière qui ne nécessite pas les
  types de recherches rapides et arbitraires que les explorateurs de blocs rendent pratiques.

  Cela dit, le nouvel explorateur open source semble être assez efficace par rapport aux alternatives open source antérieures telles que
  BitPay Insight. Il inclut également des fonctionnalités modernes (comme la prise en charge des adresses bech32) et un très beau thème par
  défaut.

- **Options de sighash pour couvrir le poids des transactions :** dans le cadre de la discussion sur les hachages de signature décrite
  dans la section *Nouvelles* du [bulletin #23][], Russell O'Connor a [proposé][weight sighash] qu'il devrait exister une capacité
  optionnelle permettant aux signatures de transaction de s'engager sur le poids (la taille) de la transaction. Cela atténue un problème
  perçu avec certains scripts avancés où il pourrait être possible pour une contrepartie ou un tiers d'ajouter des données supplémentaires à
  une transaction, réduisant son taux de frais et la rendant probablement plus longue à confirmer.

## Changements notables dans le code

*Changements de code notables cette semaine dans [Bitcoin Core][bitcoin core repo], [LND][lnd repo], [C-lightning][core lightning repo] et
[libsecp256k1][libsecp256k1 repo].*

- [LND #2007][] ajoute une nouvelle option de configuration `MaxBackoff` qui permet de modifier la durée maximale pendant laquelle le nœud
  attendra avant d'abandonner ses tentatives de reconnexion à l'un de ses pairs persistants. Le même algorithme actuel de backoff
  exponentiel sera utilisé jusqu'à ce que le maximum soit atteint.

- [LND #2006][] facilite l'utilisation du moteur de recommandation d'autopilot avec des moteurs de recommandation alternatifs. La méthode
  actuelle renvoie simplement une liste de pairs avec lesquels il est recommandé d'ouvrir de nouveaux canaux. La nouvelle méthode permet de
  spécifier quelles données considérer et renvoie une liste de nœuds notés par l'algorithme (des scores plus élevés étant meilleurs). Les
  moteurs de recommandation alternatifs peuvent renvoyer leurs propres recommandations notées, et l'utilisateur (ou son logiciel) peut
  décider comment agréger ou utiliser autrement les scores pour décider effectivement quels nœuds devraient recevoir des tentatives
  d'ouverture de canal.

- [C-Lightning #2123][] ajoute un nouveau RPC `check` qui vérifie si un appel RPC utilise des paramètres valides sans exécuter l'appel.

- [C-Lightning #2127][] ajoute une nouvelle option de configuration `--plugin-dir` qui chargera les plugins dans le répertoire indiqué. Le
  paramètre peut être passé plusieurs fois pour différents répertoires. Une option `--plugin` permet également de charger des plugins
  individuels.

- [C-Lightning #2121][] permet aux plugins d'ajouter de nouvelles méthodes JSON-RPC. Pour l'utilisateur, celles-ci ne sembleront pas
  différentes des méthodes intégrées, y compris en apparaissant dans la liste des méthodes prises en charge renvoyée par le RPC `help`.

- [C-Lightning #2147][] ajoute un nouveau paramètre `announce` au RPC `fundchannel` qui permet de marquer le canal comme privé, ce qui
  signifie qu'il ne sera pas annoncé publiquement au réseau. Par défaut, les canaux sont publics.

{% include references.md %}
{% include linkers/issues.md issues="2007,2006,2123,2127,2121,2147" %}

[V0.17.1rc1]: https://bitcoincore.org/bin/bitcoin-core-0.17.1/
[maintenance release]: https://bitcoincore.org/en/lifecycle/#maintenance-releases
[explorer announce]: https://blockstream.com/2018/11/06/explorer-launch/
[explorer code announce]: https://blockstream.com/2018/12/06/esplora-source-announcement/
[weight sighash]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-December/016534.html
[bulletin #23]: /en/newsletters/2018/11/27/#sighash-updates
