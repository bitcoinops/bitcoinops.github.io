---
title: 'Bulletin Hebdomadaire Bitcoin Optech #219'
permalink: /fr/newsletters/2022/09/28/
name: 2022-09-28-newsletter-fr
slug: 2022-09-28-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
La newsletter de cette semaine décrit une proposition visant à permettre
aux nœuds LN d'annoncer des taux de frais dépendant de la capacité et annonce
un fork logiciel de Bitcoin Core axé sur le test de changements majeurs
du protocole sur signet. Vous trouverez également nos sections habituelles
avec des résumés des principales questions et réponses du Bitcoin Stack
Exchange, des annonces de nouvelles mises à jour et release candidate,
du protocole sur signet.  Vous trouverez également nos sections habituelles
avec des résumés des questions et réponses principales du Bitcoin Stack
Exchange, des annonces de nouvelles versions et de release candidates,
et des descriptions de changements notables dans les principaux logiciels
d'infrastructure Bitcoin.

## Nouvelles

- **Fees Ratecards:** Lisa Neigut [a postée][neigut ratecards]
  sur la liste de diffusion de Lightning-Dev une proposition de *fee ratecards*
  qui permettrait à un noeud d'annoncer quatre niveaux de frais de transactions.
  Par exemple, un paiement qui laisse à un canal moins de 25 % de sa
  capacité sortante disponible pour transmettre les paiements suivants devra
  payer proportionellement plus qu'un paiement qui laisse 75 % de sa capacité
  de sortie disponible.

  Le développeur ZmnSCPxj [a décrit][zmnscpxj ratecards] une façon simple
  d'utiliser les ratecards, "vous pouvez modéliser une carte tarifaire
  comme quatre canaux distincts entre les deux mêmes nœuds, avec des coûts
  différents pour chacun. Si le chemin au coût le plus bas échoue, il suffit
  d'essayer une autre route qui peut avoir plus de sauts mais un coût
  effectif plus faible, ou bien essayer le même canal avec un coût plus élevé."
  La proposition prévoit également des redevances négatives. Par exemple,
  une chaîne pourrait subventionner les paiements qui lui sont transmis
  lorsqu'il a plus de 75 % de capacité sortante en ajoutant 1 satoshi pour
  chaque tranche de 1 000 satoshis de valeur de paiement. Les frais négatifs
  pourraient être utilisés par les marchands pour inciter les autres à restaurer
  la capacité entrante des canaux fréquemment utilisés pour recevoir des paiements.

  Neigut note que certains nœuds ajustent déjà leurs tarifs en fonction de la
  capacité des canaux, et que les fee ratecards constitueraient un moyen plus
  efficace pour les opérateurs de nœuds de communiquer leurs intentions au réseau
  que d'annoncer fréquemment de nouveaux taux de frais via le gossip de LN.

- **Implémentation de Bitcoin conçue pour tester les soft forks sur signet:**
  Anthony Towns [a posté][towns bi] sur la liste de diffusion Bitcoin-Dev une
  description de fork de Bitcoin Core sur laquelle il travaille qui pourrait seulement
  s'appliquer par défaut sur [signet][topic signet] et qui appliquera des règles
  pour les propositions de soft fork avec des spécifications et des implémentations
  de haute qualité. Cela devrait permettre aux utilisateurs d'expérimenter plus
  facilement la modification proposée, notamment en comparant directement les
  modifications entre elles (ex. comparer [OP_CHECKTEMPLATEVERIFY][topic
  op_checktemplateverify] à [SIGHASH_ANYPREVOUT][topic sighash_anyprevout]).
  Towns prévoit également d'inclure les changements majeurs proposés à la politique
  de relai des transactions (tel que [package relay][topic package relay]).

  Towns cherche à obtenir des critiques constructives sur l'idée de cette nouvelle
  mise en œuvre de tests, appelée [Bitcoin Inquisition][], ainsi qu'une
  relecture des [pull requests][bi prs] ajoutées aux paramètres initiaux du
  soft forks.

## Selection de Q&R du Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est une des principales places pour les
contributeurs d'Optech pour trouver les réponses à leurs questions---ou lorsque nous
avons quelques instants pour aider les utilisateurs curieux ou confus. Dans cette
chronique mensuelle, nous mettons en avant certaines des questions et réponses les
plus postées depuis notre dernière édition.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Est-il possible de déterminer si un portefeuille HD a été utilisé pour créer une transaction donnée ?]({{bse}}115311)
  Pieter Wuille souligne que, bien qu'il ne soit pas possible d'identifier les UTXO
  créés à l'aide d'un [portefeuille HD][topic bip32], d'autres données onchain peuvent
  être utilisées pour identifier le logiciel du portefeuille, notamment les types
  d'entrées utilisées, les types de sorties créées, l'ordre des entrées et des sorties
  dans la transaction, l'algorithme de [selection des pièces][topic coin selection]
  et l'utilisation de [timelocks][topic timelocks].

- [Pourquoi y a-t-il un écart de 5 jours entre le bloc de genèse et le bloc 1 ?]({{bse}}115344)
  Murch note que l'écart dans la chronologie pourrait s'expliquer par le fait que le
  bloc genesis a un objectif de difficulté plus élevé que nécessaire, que Satoshi a
  fixé l'horodatage du bloc dans le passé, ou le [logiciel d'origine de Bitcoin
  attendait][github jrubin annotated] pour un pair avant de commencer à miner.

- [Est-il possible de régler RBF toujours actif dans bitcoind ?]({{bse}}115360)
  Michael Folkson et Murch expliquent les options de configuration de `walletrbf`
  et énumèrent une série de changements connexes impliquant l'utilisation par
  défaut de [RBF][topic rbf] dans le GUI, l'utilisation par défaut de RBF dans les RPC,
  et l'utilsation de [`mempoolfullrbf`][news208 mempoolfullrbf] pour autoriser les
  remplacements sans signalement.

- [Pourquoi aurais-je besoin de bannir les noeuds de pairs du réseau Bitcoin ?]({{bse}}115183)
  Au contraire de [découragé un pair][bitcoin 23.x banman], l'utilisateur RedGrittyBrick
  explique qu'un opérateur de noeuds peut choisir de refuser manuellement un pair en
  utilisant le RPC [`setban`][setban rpc] si celui-ci a un mauvais comportement, est suspecté d'être malicieux,
  d'être un noeud de surveillance, ou faisant partie d'un fournisseur de cloud, entre autres raisons.

## Mises à jour et release candidates

*Nouvelles mises à jour et release candidates des principaux logiciels d'infrastructure Bitcoin.
Prévoyez s'il vous plait de vous mettre à jour à la nouvelle version ou d'aider à tester les pré-versions.*

- [Core Lightning 0.12.1][] est une mise à jour de maintenance contenant plusieurs corrections de bugs.

- [Bitcoin Core 0.24.0 RC1][] est la première release candidate de la prochaine version de l'implémentation
  de nœuds complets la plus largement utilisée sur le réseau.

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], et [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #26116][] autorise le RPC `importmulti` pour importer
  les éléments en lecture seule, même si le portefeuille utilise des clés privées chiffrées.
  Cela correspond au comportement de l'ancien RPC `importaddress`.

- [Core Lightning #5594][] apporte plusieurs modifications, notamment
  l'ajout et la mise à jour de plusieurs API, pour permettre au plugin
  `autoclean` de supprimer les anciennes factures, les anciens paiements
  et les paiements transférés.

- [Core Lightning #5315][] permet à l'utilisateur de choisir la
  *channel reserve* pour un canal particulier. La réserve est le
  montant qu'un nœud n'acceptera normalement pas d'un pair du canal dans
  le cadre d'un paiement ou d'un transfert. Si le pair tente ensuite de
  tricher, le nœud honnête peut dépenser la réserve. Core Lightning
  propose par défaut une réserve de canal de 1% du solde du canal,
  pénalisant de ce montant tout pair qui tente de tricher.

  Cette introduction de PR permet à l'utilisateur de réduire la réserve
  d'un canal spécifique, y compris de la réduire à zéro. Bien que cela
  puisse être dangereux---plus la réserve est faible, moins il y a de
  pénalités pour la tricherie---cela peut être utile dans certaines
  situations. En particulier, la mise à zéro de la réserve peut permettre
  à l'homologue distant de dépenser tous ses fonds, vidant ainsi son canal.

- [Rust Bitcoin #1258][] ajoute une méthode pour comparer deux locktimes afin
  de déterminer si l'un satisfait l'autre. Comme décrit dans les commentaires
  du code, "Un temps de verrouillage ne peut être satisfait que par n blocs
  minés ou n secondes écoulées. Si vous avez deux temps de verrouillage
  (même unité), alors le plus grand temps de verrouillage satisfait implique
  (dans un sens mathématique) que le plus petit est aussi satisfait. Cette
  fonction est utile si vous souhaitez vérifier un temps de verrouillage par
  rapport à d'autres verrous, par exemple en filtrant les verrous qui ne
  peuvent pas être satisfaits. Elle peut également être utilisée pour supprimer
  la plus petite valeur de deux opérations `OP_CHECKLOCKTIMEVERIFY` dans une
  branche du script."

{% include references.md %}
{% include linkers/issues.md v=2 issues="26116,5594,5315,1258" %}
[bitcoin core 0.24.0 rc1]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[Core Lightning 0.12.1]: https://github.com/ElementsProject/lightning/releases/tag/v0.12.1
[bitcoin inquisition]: https://github.com/bitcoin-inquisition/bitcoin/
[bi prs]: https://github.com/bitcoin-inquisition/bitcoin/pulls
[neigut ratecards]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-September/003685.html
[zmnscpxj ratecards]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-September/003688.html
[towns bi]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-September/020921.html
[github jrubin annotated]: https://github.com/JeremyRubin/satoshis-version/blob/master/src/main.cpp#L2255
[news208 mempoolfullrbf]: /en/newsletters/2022/07/13/#bitcoin-core-25353
[bitcoin 23.x banman]: https://github.com/bitcoin/bitcoin/blob/23.x/src/banman.h#L28
[setban rpc]: https://github.com/bitcoin/bitcoin/blob/97f865bb76a9c9e8e42e4ee1227615c9c30889a6/src/rpc/net.cpp#L675
