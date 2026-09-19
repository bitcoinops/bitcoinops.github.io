---
title: 'Bulletin Hebdomadaire Bitcoin Optech #21'
permalink: /fr/newsletters/2018/11/13/
name: 2018-11-13-newsletter-fr
slug: 2018-11-13-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume quelques discussions sur la liste de diffusion Lightning-Dev, suggère une opportunité de développer un
nouvel outil que certains utilisateurs trouveraient utile, et fournit des résumés et des liens vers certaines des présentations de la
récente résidence Chaincode sur les applications Lightning. Plusieurs changements notables dans le code de projets populaires
d'infrastructure Bitcoin sont également décrits.

## Action items

Aucun cette semaine.

## Nouvelles

- **Activité autour du sommet des développeurs LN et de la liste de diffusion :** avant, pendant et après une réunion planifiée entre
  développeurs du protocole Lightning Network, la [Lightning-Dev mailing list][] a connu une poussée de nouvelles propositions et de
  discussions au sujet de propositions antérieures. Voici quelques points saillants :

  - **Publicité de la liquidité des nœuds :** Lisa Neigut [propose][neigut liquidity] de permettre aux nœuds LN d'annoncer qu'ils sont
    disposés à fournir de la capacité entrante en échange d'un certain niveau de frais. Les commerçants ont besoin que leurs canaux de
    paiement disposent de capacité entrante afin de pouvoir recevoir des paiements hors chaîne sécurisés de la part de leurs clients---les
    alternatives actuelles consistent soit à obliger certains de leurs clients à attendre plusieurs confirmations sur chaîne pour ouvrir un
    nouveau canal, soit à conclure manuellement des accords de liquidité de canaux avec d'autres commerçants. Bien que résoudre ce problème
    serait très avantageux pour l'adoption de LN par les commerçants, cela pose certains défis techniques que les participants à la
    discussion tentent de résoudre à la fois dans ce fil et dans un [fil connexe][zmn liquidity].

  - **Rendre le sondage de chemins plus pratique :** Anthony Towns [propose][probe cancel] une méthode permettant à tous les nœuds le long
    d'un chemin d'oublier un paiement de faible valeur si l'un des nœuds sur ce chemin est hors ligne. Cela réduit les ressources requises
    dans le cas d'un échec de routage par un nœud qui sonde de manière proactive ses chemins de paiement disponibles afin de déterminer
    lesquels sont les plus rapides et les plus fiables pour envoyer des paiements.

- **Opportunité disponible pour fournir des fonctions utilitaires en dehors de Bitcoin Core :** l'interface RPC de Bitcoin Core fournit
  actuellement plus de 100 méthodes et il y a souvent des propositions pour en ajouter encore davantage pour des fonctions utilitaires qui
  ne nécessitent pas d'accéder à l'état interne du nœud ou du portefeuille. Lors de la [réunion][core dev meeting] IRC des développeurs de
  la semaine dernière, les membres du projet ont réaffirmé leur engagement à ne pas fournir de nouvelles fonctions utilitaires pour des
  choses qui peuvent tout aussi facilement être réalisées en dehors de Bitcoin Core et qui ne sont pas liées aux flux de travail habituels
  des utilisateurs. Cela aidera à maintenir le projet concentré sur ses principaux objectifs.

  Cela offre une belle opportunité à un développeur indépendant ou à un autre tiers de créer un projet séparé pour une bibliothèque, un
  programme local ou une interface RPC qui fournisse une interface stable vers des fonctions utilitaires qui fonctionnent bien en
  conjonction avec Bitcoin Core, et qui offre peut-être même certaines des fonctions utilitaires que Bitcoin Core prend déjà en charge pour
  les utilisateurs n'exécutant pas de nœud. Certaines idées sur la façon d'implémenter un tel outil ont été discutées à la fois pendant et
  [après][core dev log] la réunion.

## Vidéos de la résidence sur les applications Lightning

Comme indiqué précédemment dans le [bulletin n°19][le bulletin #19], Chaincode Labs a récemment accueilli un [programme de résidence][] de
cinq jours pour le développement d'applications sur le Lightning Network, comprenant des présentations d'experts du domaine. Les vidéos des
[présentations][] et des [démos des résidents][] ont maintenant été mises en ligne, ainsi que les diapositives des présentations des
experts. Les présentations suivantes peuvent présenter un intérêt particulier pour les membres :

- [**The Lightning Protocol - an Application Developers Perspective**][bosworth video] - [Alex Bosworth][bosworth], responsable
  infrastructure chez Lightning Labs, donne une vue d'ensemble complète du protocole Lightning, en expliquant l'ensemble des [BOLTs][], et
  la manière dont ils sont pertinents pour les développeurs construisant au-dessus du protocole. Cette présentation devrait être utile à
  tous les développeurs souhaitant intégrer Lightning dans des produits ou des services.

- [**Lightning ≈ Bitcoin**][decker video] - [Christian Decker][decker], ingénieur Core Tech chez Blockstream, décrit les similitudes et les
  différences entre les paiements Bitcoin et Lightning, en mettant en évidence les cas où les transactions sur chaîne sont plus appropriées
  que celles hors chaîne (et inversement). Il termine par un résumé des améliorations qui pourraient être proposées lors de la réunion de
  novembre 2018 sur le protocole Lightning.

- [**Integrating Lightning into Bitrefill**][camarena video] - [Justin Camarena][camarena], ingénieur infrastructure chez bitrefill,
  explique comment bitrefill a intégré les paiements Lightning dans sa boutique. Bitrefill a été l'un des premiers commerçants Bitcoin à
  commencer à accepter des paiements Lightning sur le réseau principal, et Justin nous montre comment ils ont intégré Lightning dans leur
  infrastructure, ainsi que les défis qu'ils ont rencontrés et surmontés en cours de route. Pour ceux qui s'intéressent à une vue d'ensemble
  de haut niveau de l'expérience de bitrefill avec Lightning, la [présentation de Sergej Kotliar à Building on Bitcoin][kotliar BoB],
  couverte dans le [bulletin n°3][le bulletin #3], présentera également de l'intérêt.

- [**Zap - UX, Design and Product approach**][mallers video] - [Jack Mallers][mallers], fondateur de Zap, explique son approche de la
  conception de produit et de l'expérience utilisateur. Lightning peut potentiellement résoudre de nombreux problèmes d'expérience
  utilisateur associés à l'utilisation de Bitcoin, mais soulève également certains défis d'expérience utilisateur qui lui sont propres. Jack
  explique comment il réfléchit à l'expérience utilisateur dans Zap, les défis UX auxquels il a été confronté en construisant le produit et
  comment il les a résolus.

## Changements notables dans le code

*Changements notables dans le code cette semaine dans [Bitcoin Core][bitcoin core repo], [LND][lnd repo], [C-lightning][core lightning
repo], et [libsecp256k1][libsecp256k1 repo].*

- [Bitcoin Core #14410][] ajoute un champ `ischange` au RPC [getaddressinfo][rpc getaddressinfo] indiquant si le portefeuille a utilisé
  l'adresse dans une sortie de monnaie.

- [Bitcoin Core #14060][] rend configurable le nombre maximal de messages que l'interface [ZeroMQ][] (ZMQ) mettra en file d'attente pour un
  client. La marque de niveau haut (High-Water Mark, HWM) par défaut permet de mettre jusqu'à 1 000 messages en file d'attente avant que
  certains messages ne soient abandonnés. Une nouvelle HWM peut être choisie en définissant l'une des options de configuration suivantes au
  nombre maximal souhaité de messages en file d'attente (ou la taille maximale de la file peut être rendue illimitée en la définissant à
  `0`) : `zmqpubhashtxhwm`, `zmqpubhashblockhwm`, `zmqpubrawblockhwm`, et `zmqpubrawtxhwm`. Plus la taille de la file est grande, plus le
  programme utilisera de mémoire.

- [LND #1782][] ajoute un champ `num_inactive_channels` au RPC `getinfo` contenant le nombre de canaux inactifs du nœud (similaire aux
  décomptes existants des canaux en attente et actifs).

- [LND #1944][] ajoute un champ `pub_key` au RPC `sendtoroute` afin que LND n'ait pas besoin d'obtenir la clé publique depuis une source
  externe. Cela permet d'acheminer des paiements via des canaux privés qui ne sont pas listés sur le réseau public.

{% include references.md %}
{% include linkers/issues.md issues="14410,14060,1782,1944" %}

[lightning-dev mailing list]: https://gnusha.org/url/https://lists.linuxfoundation.org/mailman/listinfo/lightning-dev
[neigut liquidity]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001532.html
[zmn liquidity]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001555.html
[walletless opens]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001539.html
[eltoo protocol]: https://blockstream.com/eltoo.pdf
[probe cancel]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001554.html
[core dev meeting]: http://www.erisian.com.au/meetbot/bitcoin-core-dev/2018/bitcoin-core-dev.2018-11-08-19.00.log.html#l-49
[core dev log]: http://www.erisian.com.au/bitcoin-core-dev/log-2018-11-08.html#l-668
[zeromq]: http://zeromq.org/
[programme de residence]: https://lightningresidency.com
[présentations]: https://lightningresidency.com/#videos
[demos des residents]: https://www.youtube.com/playlist?list=PLpLH33TRghT2jmuP9YQRo-e8gk969Q2F_
[bosworth video]: https://www.youtube.com/watch?v=1R5DNUcCYRg&list=PLpLH33TRghT1SbxinAsNDS6L7RkAjC8ME&index=6&t=0s
[bosworth]: https://twitter.com/alexbosworth
[BOLTs]: https://github.com/lightningnetwork/lightning-rfc
[decker video]: https://www.youtube.com/watch?v=8lMLo-7yF5k&list=PLpLH33TRghT1SbxinAsNDS6L7RkAjC8ME&index=5&t=0s
[decker]: https://twitter.com/Snyke
[camarena video]: https://www.youtube.com/watch?v=RZtx6ZMLDrQ&list=PLpLH33TRghT1SbxinAsNDS6L7RkAjC8ME&index=12&t=0s
[camarena]: https://twitter.com/juscamarena
[kotliar BoB]: https://www.youtube.com/watch?v=Cpid31c6HZc&feature=youtu.be&t=8m49s
[mallers video]: https://www.youtube.com/watch?v=R0C83h-ZM-4&list=PLpLH33TRghT1SbxinAsNDS6L7RkAjC8ME&index=17&t=0s
[mallers]: https://twitter.com/JackMallers
[le bulletin #19]: /fr/newsletters/2018/10/30/#lightning-residency-et-hackday
[le bulletin #3]: /fr/newsletters/2018/07/10/#building-on-bitcoin
[erlay]: https://arxiv.org/pdf/1905.10518.pdf
