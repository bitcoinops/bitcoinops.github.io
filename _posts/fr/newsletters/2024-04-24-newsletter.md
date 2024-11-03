---
title: 'Bulletin Hebdomadaire Bitcoin Optech #299'
permalink: /fr/newsletters/2024/04/24/
name: 2024-04-24-newsletter-fr
slug: 2024-04-24-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit une proposition pour relayer des blocs faibles afin
d'améliorer la performance des blocs compacts dans un réseau avec plusieurs politiques divergentes
de mempool et annonce l'ajout de cinq éditeurs de BIP. On y trouvera également nos
rubriques habituelles avec des questions et réponses populaires
de la communauté Bitcoin Stack Exchange, des annonces de nouvelles versions et
versions candidates, ainsi que les changements apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Implémentation de preuve de concept pour les blocs faibles :** Greg Sanders a [posté][sanders
  weak] sur Delving Bitcoin à propos de l'utilisation de _blocs faibles_ pour améliorer le relais de
  [blocs compacts][topic compact block relay], particulièrement en présence de politiques divergentes
  pour le relais et le minage de transactions. Un bloc faible est un bloc avec une preuve de travail
  (PoW) insuffisante pour devenir le prochain bloc sur la blockchain mais qui par ailleurs a une
  structure valide et un ensemble de transactions valides. Les mineurs produisent des blocs faibles
  proportionnellement au pourcentage de PoW requis pour chaque bloc faible ; par exemple, les mineurs
  produiront (en moyenne) 9 blocs faibles à 10% du PoW requis pour chaque bloc complet de PoW.

  Les mineurs ne savent pas quand ils produiront un bloc faible. Chaque candidat à un bloc a une
  chance égale d'atteindre le PoW complet, certains de ces candidats devenant des blocs faibles à la
  place. La seule manière de créer un bloc faible est en faisant exactement le même travail nécessaire
  pour produire un bloc complet de PoW, signifiant qu'un bloc faible reflète précisément les
  transactions qu'un mineur tentait de miner au moment où le bloc faible a été créé. Par exemple, la
  seule manière d'inclure une transaction invalide dans un bloc faible est de risquer de créer un bloc
  complet de PoW avec la même transaction invalide---un bloc invalide que les nœuds complets
  rejetteraient et qui empêcherait le mineur de recevoir toute récompense de bloc. Bien sûr, un mineur
  qui ne voudrait pas annoncer quelles transactions il tentait de miner pourrait simplement refuser de
  diffuser ses blocs faibles.

  La haute difficulté de créer un bloc faible à 10% et le coût élevé de créer un bloc faible avec des
  transactions invalides rendent les blocs faibles fortement résistants aux attaques par déni de
  service qui pourraient tenter de gaspiller de grandes quantités de bande passante, de CPU et de
  mémoire des nœuds.

  Comme un bloc faible est juste un bloc régulier avec une PoW légèrement insuffisante, ils sont de la
  même taille que les blocs réguliers. Lorsque le relais de blocs faibles a été décrit pour la
  première fois il y a plus d'une décennie, cela signifiait que relayer des blocs faibles à 10%
  augmenterait la bande passante utilisée par les nœuds pour le relais de blocs jusqu'à 10x.
  Cependant, il y a de nombreuses années, Bitcoin Core a commencé à utiliser le relais de blocs
  compacts qui substitue les transactions dans les blocs avec des identifiants courts, permettant au
  nœud récepteur de ne demander que les transactions qu'il n'a pas précédemment vues. Cela réduit
  typiquement la bande passante requise pour relayer un bloc de plus de 99%. Sanders note que cela
  fonctionnerait tout aussi bien pour les blocs faibles.

  Pour les blocs complets de PoW, le relais de blocs compacts économise non seulement de la bande
  passante mais il aide également les nouveaux blocs à se propager beaucoup plus rapidement. Moins de
  données (moins de transactions complètes) signifient que les blocs peuvent être envoyés et vérifiés
  plus rapidement. Une propagation plus rapide des nouveaux blocs est importante pour la décentralisation du
  minage : un mineur qui trouve un nouveau bloc peut immédiatement commencer à travailler sur un bloc
  successeur, mais les autres mineurs ne peuvent commencer à travailler sur un successeur qu'après
  avoir reçu le nouveau bloc par relais. Cela peut donner un avantage aux grands pools de minage,
  créant un type non intentionnel d'attaque par minage égoïste (voir le [Bulletin #244][news244
  selfish]). Ce problème était courant avant l'introduction du relais de blocs compacts et cela a
  conduit à la centralisation du minage dans de grands pools et à l'utilisation de techniques
  problématiques, telles que le spy-mining qui a résulté dans les [forks de chaîne de juillet 2015][].

  Le relais de blocs compacts ne permet d'économiser de la bande passante et d'accélérer la
  propagation des blocs que lorsqu'un nœud reçoit un nouveau bloc composé principalement de
  transactions qu'il a déjà vues. Mais, Sanders note, certains mineurs créent aujourd'hui des blocs
  avec de nombreuses transactions qui ne sont pas relayées entre les nœuds, réduisant les avantages du
  relais compact et mettant le réseau en risque des problèmes qui existaient avant le relais de blocs
  compacts. Il a proposé le relais de blocs faibles comme solution :

  - Les mineurs qui créent un bloc faible (par exemple, un bloc faible de 10%) le relaieraient de
    manière occasionnelle aux nœuds. Par occasionnellement, nous entendons que le relais serait traité
    comme un trafic réseau P2P régulier, tel que le relais de nouvelles transactions non confirmées,
    plutôt que comme un trafic de haute priorité comme les nouveaux blocs.

  - Les nœuds accepteraient de manière occasionnelle les blocs faibles et les valideraient. La
    validation PoW est triviale et se produirait immédiatement ; ensuite, le bloc faible serait
    temporairement stocké en mémoire pendant que ses transactions seraient validées. Toute nouvelle
    transaction du bloc faible qui passerait les règles de politique de Bitcoin Core serait ajoutée au
    mempool. Celles qui ne passeraient pas seraient stockées dans un cache spécial, similaire aux caches
    existants que Bitcoin Core utilise pour stocker temporairement les transactions qui ne peuvent pas
    être ajoutées au mempool (par exemple, le cache de transactions orphelines).

  - Des blocs faibles supplémentaires reçus plus tard pourraient mettre à jour le mempool et le cache.

  - Lorsqu'un nouveau bloc complet-PoW serait reçu en utilisant le relais de blocs compacts, il
    pourrait être utilisé avec des transactions à la fois du mempool et du cache de blocs faibles,
    minimisant le besoin de temps de relais supplémentaire et de bande passante. Cela pourrait permettre
    à un réseau avec de nombreuses politiques de nœuds et de mineurs divergentes de continuer à
    bénéficier des blocs compacts.

  De plus, Sanders pointe vers une discussion précédente sur les blocs faibles (voir le [Bulletin
  #173][news173 weak]) sur la manière dont les blocs faibles pourraient être utilisés pour aider à
  adresser les [attaques de pinning][topic transaction pinning] et améliorer l'[estimation du taux de
  frais][topic fee estimation]. L'utilisation du relais de blocs faibles a également été mentionnée
  précédemment dans une discussion sur le relais de transactions via le protocole Nostr (voir le
  [Bulletin #253][news253 weak]).

  Sanders a écrit un "[prototype][sanders poc] avec des tests légers pour démontrer
  l'idée de haut niveau". La discussion sur l'idée était en cours au moment de la rédaction.

- **Mise à jour des éditeurs BIP :** après une discussion publique (voir les Bulletins
  [#292][news292 bips], [#296][news296 bips], et [#297][news297 bips]), les contributeurs suivants ont
  été [nommés][chow editors] éditeurs BIP :
  Bryan "Kanzure" Bishop, Jon Atack, Mark "Murch" Erhardt, Olaoluwa "Roasbeef" Osuntokun et Ruben
  Somsen.

## Questions et réponses sélectionnées de Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech cherchent des réponses à leurs
  questions, ou lorsque nous avons quelques moments libres pour aider les utilisateurs curieux ou confus. Dans cette rubrique
  mensuelle, nous mettons en évidence certaines des questions et réponses les plus votées publiées depuis notre dernière mise
  à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aa
nswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Où se trouve exactement le bug de "décalage d'un" dans la difficulté?]({{bse}}20597)
  Antoine Poinsot explique l'erreur de décalage d'un dans le calcul de réajustement de la difficulté
  de Bitcoin qui permet l'[attaque par manipulation temporelle][topic time warp] que la proposition de
  [nettoyage du consensus][topic consensus cleanup] vise à adresser (voir le [Bulletin #296][news296 cc]).

- [En quoi P2TR est-il différent de P2PKH en utilisant des opcodes du point de vue d'un développeur?]({{bse}}122548)
  Murch conclut que l'exemple de script Bitcoin fourni comme script de sortie P2PKH serait non
  standard, plus coûteux que P2TR, mais valide en termes de consensus.

- [Les transactions de remplacement sont-elles plus grandes en taille que leurs prédécesseurs et que les transactions non-RBF?]({{bse}}122473)
  Vojtěch Strnad note que les transactions signalant [RBF][topic rbf] sont de la même taille que les
  transactions ne signalant pas et donne des scénarios où les transactions de remplacement pourraient
  être de la même taille, plus grandes ou plus petites que la transaction originale remplacée.

- [Les signatures Bitcoin sont-elles toujours vulnérables à la réutilisation de nonce?]({{bse}}122621)
  Pieter Wuille confirme que les schémas de signature ECDSA et [schnorr][topic schnorr signatures], y
  compris leurs [variantes multisignatures][topic multisignature], sont vulnérables à la
  [réutilisation de nonce][taproot nonces].

- [Comment les mineurs ajoutent-ils manuellement des transactions à un modèle de bloc?]({{bse}}122725)
  Ava Chow décrit différentes approches qu'un mineur pourrait utiliser pour inclure des transactions
  dans un bloc qui ne seraient autrement pas incluses dans le `getblocktemplate` de Bitcoin Core:

  - utiliser `sendrawtransaction` pour inclure la transaction dans le mempool du mineur puis ajuster
    le [frais absolu perçu][prioritisetransaction fee_delta] de la transaction en utilisant
    `prioritisetransaction`
  - utiliser une implémentation de `getblocktemplate` modifiée ou un logiciel de construction de blocs
    séparé

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets d’infrastructure
Bitcoin. Veuillez envisager de passer aux nouvelles versions ou d’aider à tester
les versions candidates.*

- [LND v0.17.5-beta][] est une version de maintenance qui rend LND compatible avec Bitcoin Core 27.x.

  Comme [signalé][lnd #8571] aux développeurs de LND, les versions antérieures de LND dépendaient
  d'une version plus ancienne de [btcd][] qui avait l'intention de fixer son taux de frais maximum à
  10 millions de sat/kB (équivalent à 0.1 BTC/kB).
  Cependant, Bitcoin Core accepte les taux de frais en BTC/kvB, donc le taux de frais maximum était en
  réalité fixé à 10 millions de BTC/kvB. Bitcoin Core 27.0 a inclus un [PR][bitcoin core #29434] qui
  limitait les taux de frais maximum à 1 BTC/kvB afin de prévenir certains problèmes et sous
  l'hypothèse que quiconque définissant une valeur plus élevée faisait probablement une erreur (s'ils
  voulaient vraiment une valeur maximum plus élevée, ils pourraient simplement définir le paramètre à
  0 pour désactiver la vérification). Dans ce cas, LND (via btcd) faisait effectivement une erreur,
  mais la modification apportée à Bitcoin Core a empêché LND de pouvoir envoyer des transactions
  onchain, ce qui peut être dangereux pour un nœud LN qui a parfois besoin d'envoyer des transactions
  sensibles au temps. Cette version de maintenance fixe correctement la valeur maximum à 0,1 BTC/kvB,
  rendant LND compatible avec les nouvelles versions de Bitcoin Core.

## Changements notables dans le code et la documentation

_Modifications notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [Serveur
BTCPay][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration de Bitcoin (BIPs)][bips
repo], [Lightning BOLTs][bolts repo], [Inquisition Bitcoin][bitcoin inquisition repo], et
[BINANAs][binana repo]._

- [Bitcoin Core #29850][] limite le nombre maximum d'adresses IP acceptées d'une graine DNS
  individuelle à 32 par requête. Lors de la requête DNS sur UDP, la taille maximale du paquet limitait
  le nombre à 33, mais la requête DNS alternative sur TCP peut maintenant retourner un nombre beaucoup
  plus important de résultats. Les nouveaux nœuds se connectent à plusieurs graines DNS pour
  construire un ensemble d'adresses IP. Ils sélectionnent ensuite aléatoirement certaines de ces
  adresses IP et s'y connectent en tant que pairs. Si le nouveau nœud obtient à peu près le même
  nombre d'adresses IP de chaque graine à laquelle il se connecte, alors il est peu probable que tous
  les pairs qu'il sélectionne proviennent du même nœud de graine, ce qui contribue à garantir qu'il a une
  perspective diversifiée sur le réseau et qu'il n'est pas vulnérable aux [attaques par éclipse][topic
  eclipse attacks].

  Cependant, si une graine renvoyait un nombre beaucoup plus important d'adresses IP que toute autre
  graine, il y aurait une probabilité significative que le nouveau nœud sélectionne aléatoirement un
  ensemble d'adresses IP provenant toutes de cette graine. Si la graine était malveillante, cela
  pourrait lui permettre d'isoler le nouveau nœud du réseau honnête. [Les tests][bitcoin core #16070]
  ont montré que toutes les graines à ce moment-là renvoyaient 50 résultats ou moins, même si le
  maximum autorisé était de 256. Ce PR fusionné réduit le nombre maximum à un montant similaire à ce
  que les nœuds de graine renvoient actuellement.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="8571,29434,29850,16070" %}
[sanders weak]: https://delvingbitcoin.org/t/second-look-at-weak-blocks/805
[news173 weak]: /en/newsletters/2021/11/03/#feerate-communication
[news253 weak]: /fr/newsletters/2023/05/31/#relais-de-transaction-sur-nostr
[sanders poc]: https://github.com/instagibbs/bitcoin/commits/2024-03-weakblocks_poc/
[forks de chaîne de juillet 2015]: https://en.bitcoin.it/wiki/July_2015_chain_forks
[selfish mining attack]: https://bitcointalk.org/index.php?topic=324413.msg3476697#msg3476697
[news244 selfish]: /fr/newsletters/2023/03/29/#bitcoin-core-27278
[btcd]: https://github.com/btcsuite/btcd/pull/2142
[chow editors]: https://gnusha.org/pi/bitcoindev/CAMHHROw9mZJRnTbUo76PdqwJU==YJMvd9Qrst+nmyypaedYZgg@mail.gmail.com/T/#m654f52c426bd5696d88668b3bff25197846e14af
[news292 bips]: /fr/newsletters/2024/03/06/#discussion-sur-l-ajout-de-plus-d-editeurs-bip
[news296 bips]: /fr/newsletters/2024/04/03/#choisir-de-nouveaux-editeurs-bip
[news297 bips]: /fr/newsletters/2024/04/10/#mise-a-jour-de-bip2
[LND v0.17.5-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.5-beta
[news296 cc]: /fr/newsletters/2024/04/03/#revisiter-le-nettoyage-du-consensus
[prioritisetransaction fee_delta]: https://developer.bitcoin.org/reference/rpc/prioritisetransaction.html#argument-3-fee-delta
[taproot nonces]: /en/preparing-for-taproot/#multisignature-nonces
