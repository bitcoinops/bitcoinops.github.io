---
title: 'Bulletin Hebdomadaire Bitcoin Optech #14'
permalink: /fr/newsletters/2018/09/25/
name: 2018-09-25-newsletter-fr
slug: 2018-09-25-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine comprend des actions à entreprendre et des nouvelles liées à la publication de sécurité de la semaine dernière
de Bitcoin Core 0.16.3 et Bitcoin Core 0.17RC4, des questions et réponses populaires de Bitcoin Stack Exchange au cours du mois écoulé,
ainsi que de courtes descriptions des fusions notables effectuées dans des projets d'infrastructure Bitcoin populaires.

- **Passez à Bitcoin Core 0.16.3 pour corriger CVE-2018-17144 :** comme cela a été largement rapporté tôt vendredi (UTC), la vulnérabilité
  de déni de service décrite dans le bulletin Optech de la semaine dernière est désormais connue pour permettre à des mineurs de tromper les
  systèmes affectés afin qu'ils acceptent des bitcoins invalides.

  Au moment de la rédaction, on pense qu'une majorité des grands services Bitcoin et des mineurs ont effectué la mise à niveau, ce qui
  garantit probablement que tout bloc exploitant le bogue sera rapidement réorganisé hors de la chaîne ayant le plus de preuve de
  travail---réduisant le risque pour les clients SPV et les nœuds non mis à niveau.

  Si vous ne prévoyez pas de mettre à niveau ou si vous utilisez un client SPV, vous devriez envisager d'attendre plus de confirmations que
  vous ne le faites habituellement (30 confirmations---environ 5 heures---sont une [recommandation][reorg risk recommendation] normale dans
  ce type de situation, car cela laisse suffisamment de temps pour que les gens remarquent un problème et publient des avertissements).
  Sinon, la mise à niveau vers l'une des versions suivantes reste fortement recommandée pour tout système, en particulier ceux qui
  manipulent de l'argent :

  * [0.16.3][] (stable actuelle)

  * [0.17.0RC4][bcc 0.17] (version candidate pour la prochaine version majeure)

  * [0.15.2][] (rétroportage vers une ancienne version, peut avoir d'autres problèmes)

  * [0.14.3][] (rétroportage vers une ancienne version, peut avoir d'autres problèmes)

- **Consacrez du temps à tester Bitcoin Core 0.17RC4 :** Bitcoin Core a téléversé des [binaires][bcc 0.17] pour la version candidate (RC) 4
  de 0.17. Les tests sont grandement appréciés et peuvent aider à garantir la qualité de la version finale.

## Nouvelles

- **CVE-2018-17144 :** les divulgations initiales puis ultérieures d'informations sur ce bogue ont été les seules nouvelles significatives
  cette semaine. Pour plus d'informations, nous suggérons de lire les sources suivantes :

  - [Bitcoin Core full disclosure][]

  - [Original confidential report][], maintenant public

  - [Additional technical information][bse 79484] par Andrew Chow (également décrit ci-dessous)

  - [CVE-2018-17144 entry][cve-2018-17144], entrée de la National Vulnerability Database (NVE) en cours de mise à jour par Luke Dashjr

  Nous savons que plusieurs personnes très perspicaces réfléchissent actuellement au bogue, à ses causes ultimes et à d'éventuelles méthodes
  pour réduire le risque de futurs bogues graves. Un lieu particulièrement approprié pour les discussions internes à Bitcoin Core sera les
  réunions [CoreDev.tech][] du 8 au 10 octobre suivant la conférence Scaling Bitcoin de Tokyo. Nous prévoyons de faire un suivi avec des
  liens vers toute conclusion importante qui sera publiée.

  Optech remercie le rapporteur original, Awemany, pour sa divulgation responsable, ainsi que les développeurs suivants qui ont
  immédiatement pris le temps de confirmer rapidement le problème, d'y remédier et d'assurer discrètement une surveillance permanente des
  tentatives d'exploitation du risque d'inflation alors non divulgué : Pieter Wuille, Gregory Maxwell, Wladimir van der Laan, Cory Fields,
  Suhas Daftuar, Alex Morcos et Matt Corallo.

## Questions et réponses sélectionnées de Bitcoin Stack Exchange

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech cherchent des réponses à leurs
questions---ou quand nous avons quelques moments libres pour aider les utilisateurs curieux ou confus. Dans cette rubrique mensuelle, nous
mettons en lumière certaines des questions et réponses les mieux votées postées depuis notre dernière mise à jour.*

- [How does CVE-2018-17144 work?][bse 79484] Andrew Chow fournit une explication détaillée de la façon dont Bitcoin Core peut être planté ou
  amené à accepter plusieurs dépenses de la même entrée dans les versions vulnérables à ce bogue.

- [Why doesn't Bitcoin use UDP instead of TCP?][bse 79175] Gregory Maxwell décrit un cas où un logiciel Bitcoin important utilise déjà UDP,
  puis détaille les raisons pour lesquelles la prise en charge d'UDP n'est pas implémentée dans les logiciels populaires de nœud complet. Il
  conclut par une description de certains avantages potentiels qui pourraient être disponibles si la prise en charge d'UDP était
  implémentée.

- [How likely are you to get blacklisted by an exchange if you use Wasabi wallet's CoinJoin mixing?][bse 78654] L'auteur de Wasabi Wallet,
  Adam Ficsor, explique que rien n'empêche les plateformes d'échange de refuser des fonds mélangés via Wasabi, mais que plusieurs
  fonctionnalités de Wasabi (comme un ensemble d'anonymat requis de 100) peuvent aider à faire en sorte que le blocage des utilisateurs soit
  mauvais pour les affaires. En alternative, il renvoie vers un outil qui pourrait permettre aux utilisateurs de contourner une liste noire
  d'adresses.

- [What's the minimum number for a Bitcoin private key?][bse 79472] Des réponses de Mark Erhardt et Gregory Maxwell ont été fournies à une
  minute d'intervalle, mais une reformulation humoristique de la réponse de Maxwell par Nate Eldredge a plus de votes positifs que l'une ou
  l'autre réponse au moment de la rédaction.

## Commits notables

*Commits notables cette semaine dans [Bitcoin Core][bitcoin core repo], [LND][lnd repo] et [C-lightning][core lightning repo]. Rappel : les
nouvelles fusions dans Bitcoin Core sont effectuées sur sa branche de développement master et il est peu probable qu'elles fassent partie de
la prochaine version 0.17---vous devrez probablement attendre la version 0.18 dans environ six mois.*

- [Bitcoin Core #13152][] : lorsqu'ils sont connectés au réseau pair à pair, les nœuds partagent les adresses IP d'autres nœuds dont ils ont
  entendu parler et ces adresses sont stockées dans une base de données que Bitcoin Core interroge lorsqu'il veut ouvrir une nouvelle
  connexion. Cette PR ajoute une nouvelle commande RPC, `getnodeaddresses`, qui renvoie une ou plusieurs de ces adresses. Cela peut être
  utile en conjonction avec des outils comme [bitcoin-submittx][].

- [LND #1738][] : la logique de validation des mises à jour de canaux a été déplacée vers le paquetage de routage afin qu'elle soit
  disponible à la fois dans le routage (pour gérer les sessions de paiement échouées) et le gossiper (où elle était gérée auparavant). Cela
  corrige le problème [#1707][LND #1707] (et implémente un cas de test pour celui-ci) qui pouvait avoir permis à un nœud de tromper l'un de
  ses pairs pour lui faire croire qu'un pair différent avait eu une défaillance de routage, redirigeant ainsi potentiellement le trafic vers
  le nœud malveillant.

- [C-Lightning #1945][] fournit maintenant un outil `gossipwith` qui vous permet de recevoir le gossip d'un nœud indépendamment de
  lightningd ou même d'envoyer un message au nœud distant. Cet outil est utilisé pour des tests supplémentaires du composant gossip de
  lightningd.

- [C-Lightning #1954][] est maintenant conforme aux mises à jour de [BOLT7][bolt7] en divisant l'ancien champ `flags` du RPC `listchannels`
  en deux nouveaux champs : `message_flags` et `channel_flags`. Les commentaires du code et les références à [BOLT2][] et [BOLT11][] ont
  également été mis à jour.

- [C-Lightning #1905][] a considérablement étendu la documentation dans le code de son module des secrets. La documentation est
  remarquablement bonne (et, par moments, assez humoristique). Voir [hsmd.c][]. Les commentaires du code documentent même d'autres
  commentaires du code :

  ```c
  /*~ You'll find FIXMEs like this scattered through the code.{% comment %}skip-test{% endcomment %}
   * Sometimes they suggest simple improvements which someone like
   * yourself should go ahead an implement.  Sometimes they're deceptive
   * quagmires which will cause you nothing but grief.  You decide! */

   /* FIXME: We should cache these. */{% comment %}skip-test{% endcomment %}
   get_channel_seed(&c->id, c->dbid, &channel_seed);
   derive_funding_key(&channel_seed, &funding_pubkey, &funding_privkey);
  ```

- [C-Lightning #1947][] peut maintenant effectuer plusieurs requêtes en parallèle à bitcoind, accélérant les opérations sur les systèmes
  lents ou sur les nœuds exécutant des opérations de longue durée.

{% include references.md %}
{% include linkers/issues.md issues="13152,1738,1707,1945,1954,1905,1947" %}

{% assign bse = "https://bitcoin.stackexchange.com/a/" %}
[bse 79484]: {{bse}}79484
[bse 79175]: {{bse}}79175
[bse 78654]: {{bse}}78654
[bse 79472]: {{bse}}79472
[0.16.3]: https://bitcoincore.org/en/2018/09/18/release-0.16.3/
[0.15.2]: https://github.com/bitcoin/bitcoin/releases/tag/v0.15.2
[0.14.3]: https://github.com/bitcoin/bitcoin/releases/tag/v0.14.3
[reorg risk recommendation]: https://btcinformation.org/en/you-need-to-know#instant
[bitcoin core full disclosure]: https://bitcoincore.org/en/2018/09/20/notice/
[original confidential report]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-September/016424.html
[cve-2018-17144]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2018-17144
[bcc 0.17]: https://bitcoincore.org/bin/bitcoin-core-0.17.0/
[coredev.tech]: https://coredev.tech/
[hsmd.c]: https://github.com/ElementsProject/lightning/blob/master/hsmd/hsmd.c
[bitcoin-submittx]: https://github.com/laanwj/bitcoin-submittx
