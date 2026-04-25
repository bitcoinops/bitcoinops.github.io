---
title: 'Bulletin Hebdomadaire Bitcoin Optech #15'
permalink: /fr/newsletters/2018/10/02/
name: 2018-10-02-newsletter-fr
slug: 2018-10-02-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine comprend un avis concernant la sortie imminente de Bitcoin Core 0.17, des liens vers les versions rétroportées
de Bitcoin Core 0.15 et 0.14 pour corriger le bug d'entrées dupliquées CVE-2018-17144 pour les utilisateurs incapables d'exécuter des
versions plus récentes, une brève description d'une scission de chaîne sur testnet, et des liens vers des fusions notables dans des projets
d'infrastructure Bitcoin.

## Action à mener

- **Mettez à niveau vers Bitcoin Core 0.17 :** la nouvelle version a été taguée et plusieurs personnes ont commencé à reproduire des builds
  du logiciel, donc les binaires et l'annonce officielle de sortie devraient vraisemblablement devenir disponibles mardi ou mercredi sur
  [BitcoinCore.org][]. L'annonce inclura une copie des notes de version détaillant les principaux changements apportés au logiciel depuis la
  version 0.16.0.

## Nouvelles

- **Bitcoin Core [0.15.2][] et [0.14.3][] publiés :** bien que le code source ait été disponible pour ces anciennes branches depuis
  l'annonce publique du bug d'entrées dupliquées [CVE-2018-17144][], obtenir suffisamment de personnes pour certifier un build reproductible
  a nécessité plus de temps avant que les [binaires][bcco /bin] puissent être mis à disposition.

- **Bug d'entrées dupliquées CVE-2018-17144 exploité sur testnet :** jeudi dernier, un bloc a été créé sur testnet contenant une transaction
  qui dépensait la même entrée deux fois. Comme prévu, les nœuds considérés comme vulnérables au bug ont accepté le bloc et tous les autres
  nœuds l'ont rejeté, conduisant à une défaillance du consensus (scission de chaîne) où la chaîne ayant la plus grande preuve de travail
  contenait les entrées dupliquées et une chaîne plus faible n'en contenait pas.

  Finalement, la chaîne sans les entrées dupliquées a accumulé davantage de preuve de travail et les nœuds vulnérables ont tenté de basculer
  vers elle. Cela a amené les nœuds vulnérables à tenter de réajouter l'entrée dupliquée à la base de données UTXO deux fois, déclenchant un
  assert et provoquant leur arrêt. Lors du redémarrage, les opérateurs des nœuds vulnérables ont dû déclencher manuellement une longue
  procédure de réindexation pour corriger les incohérences de la base de données de leurs nœuds. (Cet effet secondaire de la récupération
  après une scission de chaîne avec entrées dupliquées était déjà connu des développeurs.)

  Les nœuds mis à niveau vers Bitcoin Core 0.16.3, 0.17.0RC4, ou exécutant un autre logiciel qui n'était pas vulnérable n'ont signalé aucun
  problème. Cependant, de nombreux explorateurs de blocs avec un mode testnet ont bien accepté le bloc vulnérable, rappelant aux
  utilisateurs qu'ils doivent être prudents lorsqu'ils utilisent des tiers pour déterminer si des transactions sont valides ou non.

## Changements notables dans le code

*Changements notables dans le code cette semaine dans [Bitcoin Core][bitcoin core repo], [LND][lnd repo], et [C-lightning][core lightning
repo].*

- [Bitcoin Core #14305][] : après la découverte de quelques cas où des tests basés sur Python réussissaient incorrectement en raison de
  l'utilisation de variables mal nommées, une liste blanche de noms de variables a été implémentée en utilisant la fonctionnalité
  `__slots__` de Python 3 pour les classes.

- [LND #1987][] : la RPC `NewWitnessAddress` a été supprimée et la RPC `NewAddress` ne prend désormais en charge que la génération
  d'adresses pour P2SH-encapsulé P2WKH et P2WPKH natif.

- [C-Lightning #1982][] : la RPC `invoice` implémente désormais [RouteBoost][] en incluant un paramètre `r` [BOLT11][] dans la facture qui
  fournit des informations de routage au payeur pour un canal déjà ouvert ayant la capacité de prendre en charge le paiement de la facture.
  Ce paramètre était à l'origine destiné à aider à la prise en charge des routes privées, mais il peut aussi être utilisé de cette manière
  pour prendre en charge des nœuds qui ne souhaitent plus accepter de nouveaux canaux entrants. Alternativement, si aucun canal disponible
  ne peut prendre en charge le paiement de la facture, C-Lightning émettra un avertissement.

{% include references.md %}
{% include linkers/issues.md issues="14305,1987,1982" %}

[0.16.3]: https://bitcoincore.org/en/2018/09/18/release-0.16.3/
[0.15.2]: https://github.com/bitcoin/bitcoin/releases/tag/v0.15.2
[0.14.3]: https://github.com/bitcoin/bitcoin/releases/tag/v0.14.3
[cve-2018-17144]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2018-17144
[bcc 0.17]: https://bitcoincore.org/bin/bitcoin-core-0.17.0/
[bcco /bin]: https://bitcoincore.org/bin/
[routeboost]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-September/001417.html
