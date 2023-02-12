---
title: 'Bulletin Hebdomadaire Bitcoin Optech #235'
permalink: /fr/newsletters/2023/01/25/
name: 2023-01-25-newsletter-fr
slug: 2023-01-25-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume une analyse comparant les propositions
pour des ancrages éphémères à `SIGHASH_GROUP` et relaie une demande pour
que les chercheurs étudient comment créer une preuve qu'un paiement
asynchrone LN a été accepté. Vous trouverez également nos sections
habituelles avec des résumés des principales questions et réponses
sur le Bitcoin Stack Exchange et des descriptions des changements
notables apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Ancrages éphémères par rapport à `SIGHASH_GROUP` :** Anthony Towns
  a [posté][towns e-vs-shg] sur la liste de diffusion Bitcoin-Dev une
  analyse comparant la récente proposition d'[ancrages éphémères][topic
  ephemeral anchors] à une plus ancienne proposition [`SIGHASH_GROUP`][].
  `SIGHASH_GROUP` permet à une entrée de spécifier les sorties qu'elle
  autorise, avec différentes entrées dans une transaction pouvant spécifier
  différentes sorties tant qu'elles ne se chevauchent pas. Cela peut
  être particulièrement utile pour ajouter des frais aux transactions
  dans les protocoles de contrat où deux entrées ou plus sont utilisées
  avec des transactions présignées. La nature présignée de ces transactions
  implique que les frais peuvent être ajoutés plus tard lorsqu'un taux
  approprié est connu, et les drapeaux existants `SIGHASH_ANYONECANPAY`
  et `SIGHASH_SINGLE` ne sont pas assez flexibles pour les transactions
  à entrées multiples car ils ne s'engagent que sur une seule entrée
  ou sortie.

    Les ancrages éphémères, similaires aux [parrainages de frais][topic
    fee sponsorship], permettent à n'importe qui de faire payer une
    transaction [CPFP][topic cpfp]. La transaction faisant l'objet
    de la demande de remboursement est autorisée à ne pas contenir
    de frais. Puisque n'importe qui peut faire payer une transaction
    en utilisant des ancrages éphémères, ce mécanisme peut également
    être utilisé pour payer des frais pour les transactions présignées
    à entrées multiples qui sont une cible pour `SIGHASH_GROUP`.

    `SIGHASH_GROUP` présenterait encore deux avantages : premièrement,
    il pourrait permettre le [traitement par lots][topic payment batching]
    de multiples transactions présignées non liées, ce qui pourrait
    réduire la surcharge de la taille des transactions, réduisant ainsi
    les coûts pour l'utilisateur et augmentant la capacité du réseau.
    Deuxièmement, elle ne nécessite pas de transaction enfant, ce qui
    réduirait encore les coûts et augmenterait la capacité.

    Towns conclut en notant que l'ancrage éphémère, avec sa dépendance
    à l'égard du [relais de transaction v3][topic v3 transaction relay],
    reprend la plupart des avantages de `SIGHASH_GROUP` et offre l'avantage
    significatif d'être beaucoup plus facile à mettre en production que
    le changement de consensus par embranchement convergent de `SIGHASH_GROUP`.

- **Demande de preuve qu'un paiement asynchrone a été accepté :** Valentine
  Wallace a [posté][wallace pop] sur la liste de diffusion Lightning-Dev une
  demande pour que les chercheurs étudient comment une personne effectuant
  un [paiement asynchrone][topic async payments] pourrait recevoir la preuve
  qu'elle a payé. Pour les paiements LN traditionnels, le destinataire génère
  un secret qui est digéré par une fonction de hachage ; ce condensé est
  remis à l'expéditeur dans une facture signée ; l'expéditeur utilise un
  [HTLC][topic htlc] pour payer toute personne qui divulgue le secret original.
  Ce secret divulgué prouve que l'expéditeur a payé le condensé contenu
  dans la facture signée.

  En revanche, les paiements asynchrones sont acceptés lorsque le récepteur
  est hors ligne, ils ne peuvent donc pas révéler un secret, ce qui empêche
  la création d'une preuve de paiement dans le modèle actuel de LN. Wallace
  demande aux chercheurs d'étudier comment obtenir une preuve de paiement
  pour les paiements asynchrones, soit dans le système HTLC actuel de LN,
  soit dans une future mise à niveau vers [PTLC][topic ptlc].

## Questions et réponses sélectionnées dans Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les
collaborateurs d'Optech cherchent des réponses à leurs questions---ou lorsque
nous avons quelques moments libres pour aider les utilisateurs curieux ou confus.
Dans cette rubrique mensuelle, nous mettons en évidence certaines des questions
et réponses les plus votées postées depuis notre dernière mise à jour*.

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Les clés de signature de Bitcoin Core ont été retirées du dépôt. Quel est le nouveau processus ?]({{bse}}116649)
  Andrew Chow explique que si les clés de signature ont été [supprimées][remove builder keys]
  du dépôt Bitcoin Core, il existe désormais une liste de clés sur le dépôt [guix.sigs][guix.sigs
  repo] qui héberge les attestations de construction [guix][topic reproducible builds].

- [Pourquoi signet n'utilise-t-il pas un préfixe bech32 unique ?]({{bse}}116630)
  Casey Rodarmor se demande pourquoi testnet et [signet][topic signet] utilisent le
  [préfixe d'adresse][wiki address prefixes] `tb1`. Kalle, l'un des auteurs de [BIP325][],
  explique que si signet utilisait initialement un préfixe d'adresse différent, on a pensé
  qu'utiliser le même préfixe simplifierait l'utilisation de ce réseau de test alternatif.

- [Stockage arbitraire de données dans les témoins ?]({{bse}}116875)
  RedGrittyBrick signale [l'une des nombreuses] [large witness tx] transactions P2TR récentes
  contenant une grande quantité de données de témoins. D'autres utilisateurs soulignent que le
  projet Ordinals fournit un service permettant d'inclure des données arbitraires, comme [une
  image][ordinals example] dans la transaction ci-dessus, dans une transaction Bitcoin
  utilisant le témoin.

- [Pourquoi le temps de blocage est-il défini au niveau de la transaction alors que la séquence est définie au niveau de l'entrée ?]({{bse}}116706)
  RedGrittyBrick fournit un contexte historique pour `nSequence` et `nLockTime` tandis que Pieter Wuille
  explique l'évolution de la signification de ces champs [timelock][topic timelocks] au fil du temps.

- [Signatures BLS contre Schnorr]({{bse}}116551)
  Pieter Wuille compare les hypothèses cryptographiques entre les signatures BLS et
  [schnorr][topic schnorr signatures], commente les temps de vérification, et note
  les complications autour des [multisignatures][topic multisignature] BLS et le
  manque de support pour les [signatures adaptatrices][topic adaptor signatures].

- [Pourquoi exactement ajouter plus de divisibilité au bitcoin nécessiterait un hard fork ?]({{bse}}116584)
  Pieter Wuille explique 4 méthodes d'embranchement convergent qui pourraient permettre
  de diviser les transactions en sous-satoshi :

  1. Une méthode d'[embranchement convergent forcé][] avec des changements de règles
     par consensus exigeant que toutes les nouvelles transactions soient conformes aux nouvelles règles.
  2. Un bloc d'extension unidirectionnel qui sépare les transactions suivant
     les nouvelles règles, de façon similaire au point 1 ci-dessus, mais permettant
     également aux transactions anciennes de se dérouler dans le respect des règles.
  3. Un bloc d'extension à double sens, similaire au point 2 ci-dessus, mais permettant
     aux pièces qui suivent le nouveau côté de revenir sur le côté hérité.
  4. Une méthode qui utilise les règles de consensus actuelles mais tronque
     les montants des sous-satoshi pour les anciens nœuds en stockant ces
     montants ailleurs dans la transaction.

## Principaux changements apportés au code et à la documentation

*Principaux changements cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], et [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #26325][] améliore les résultats de la commande de
  recherche `scanblocks` en supprimant les faux positifs lors d'un
  second passage. `scanblocks` peut être utilisé pour trouver des
  blocs contenant des transactions pertinentes à un ensemble fourni
  de descripteurs. Puisque le balayage contre les filtres peut
  faussement indiquer certains blocs qui ne contiennent pas réellement
  de transactions pertinentes, ce PR valide chaque hit dans une autre
  passe pour voir si les blocs correspondent réellement aux descripteurs
  passés avant de fournir les résultats à l'appelant. Pour des raisons
  de performance, la deuxième passe doit être activée en appelant
  le RPC avec l'option `filter_false_positives`.

- [Libsecp256k1 #1192][] met à jour les tests exhaustifs de la bibliothèque.
  En changeant le paramètre `B` de la courbe secp256k1 de `7` à un autre nombre,
  il est possible de trouver différents groupes de courbes compatibles avec
  libsecp256k1 mais qui sont beaucoup plus petits que l'ordre de secp256k1
  d'environ 2<sup>256</sup >. Sur ces minuscules groupes inutiles pour la
  cryptographie sécurisée, il est possible de tester la logique libsecp256k1
  de manière exhaustive sur toutes les signatures possibles. Ce PR a ajouté
  un groupe de taille 7 en plus des tailles existantes 13 et 199, bien que
  les cryptographes aient d'abord dû comprendre les propriétés algébriques
  particulières qui faisaient que l'algorithme de recherche naïf pour de
  tels groupes ne réussissait pas toujours auparavant. La taille 13 reste
  la valeur par défaut.

- [BIPs #1383][] attribue [BIP329][] à la proposition d'un format d'exportation
  d'étiquette de portefeuille standard. Depuis la proposition originale (voir le
  [Bulletin #215][news215 labels]), la principale différence est un interrupteur
  au format de données de CSV à JSON.

{% include references.md %}
{% include linkers/issues.md v=2 issues="26325,1383,1192" %}
[news215 labels]: /en/newsletters/2022/08/31/#wallet-label-export-format
[towns e-vs-shg]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-January/021334.html
[`sighash_group`]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-July/019243.html
[wallace pop]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-January/003820.html
[embranchement convergent forcé]: https://petertodd.org/2016/forced-soft-forks
[remove builder keys]: https://github.com/bitcoin/bitcoin/commit/296e88225096125b08665b97715c5b8ebb1d28ec
[guix.sigs repo]: https://github.com/bitcoin-core/guix.sigs/tree/main/builder-keys
[wiki address prefixes]: https://en.bitcoin.it/wiki/List_of_address_prefixes
[large witness tx]: https://blockstream.info/tx/a6628f32a5b41b359cfe4ab038ff7c4279118ff601b9eca85eca8a64763db40c?expand
[ordinals example]: https://ordinals.com/tx/a6628f32a5b41b359cfe4ab038ff7c4279118ff601b9eca85eca8a64763db40c
