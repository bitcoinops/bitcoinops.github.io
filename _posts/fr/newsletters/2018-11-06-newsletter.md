---
title: 'Bulletin Hebdomadaire Bitcoin Optech #20'
permalink: /fr/newsletters/2018/11/06/
name: 2018-11-06-newsletter-fr
slug: 2018-11-06-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine contient un avis de sécurité concernant l'implémentation C du décodage d'adresses bech32, une analyse d'une
réduction temporaire du nombre de blocs segwit, un lien vers une discussion intéressante sur de futures fonctionnalités pour les paiements
LN, ainsi que quelques changements de code notables dans des projets populaires d'infrastructure Bitcoin.

## Éléments d'action

- **Mise à jour de sécurité Bech32 pour l'implémentation C :** si vous utilisez l'[implémentation de référence][bech32 c] du décodage
  d'adresses bech32 pour le langage de programmation C, vous devez la [mettre à jour][bech32 patch] pour corriger un bug potentiel de
  dépassement. Les autres implémentations de référence ne sont pas affectées ; voir la section Nouvelles ci-dessous pour les détails.

## Nouvelles

- **Réduction temporaire de la production de blocs segwit :** Optech a enquêté sur des signalements indiquant qu'un pool de minage avait
  cessé de produire des blocs incluant des transactions segwit. Nous avons constaté que le nombre de blocs segwit a diminué soudainement
  autour du 20 octobre et a commencé à remonter vers la normale il y a quelques jours.

  ![Pourcentage de blocs incluant des transactions segwit, dernières plusieurs semaines](/img/posts/segwit-blocks-2018-11.png)

  Une explication simple de cette diminution soudaine puis de cette remontée pourrait être une mauvaise configuration mineure. Par défaut,
  Bitcoin Core ne produit pas de blocs incluant segwit afin de maintenir la compatibilité de [getblocktemplate][rpc getblocktemplate] (GBT)
  avec les anciens logiciels de minage pré-segwit. Lorsque les mineurs changent leur logiciel ou leur configuration, il est facile d'oublier
  de passer l'indicateur supplémentaire pour activer segwit. Pour illustrer à quel point il est facile de faire cette erreur, l'exemple
  ci-dessous appelle GBT avec son paramètre par défaut et son paramètre segwit---puis compare les résultats par la récompense totale
  potentielle de bloc (subvention + frais) que chaque modèle de bloc pourrait rapporter.

  ```bash
  $ ## GBT with default parameters
  $ bitcoin-cli getblocktemplate | jq '.coinbasevalue / 1e8'
  12.54348709

  $ ## GBT with segwit enabled
  $ bitcoin-cli getblocktemplate '{"rules": ["segwit"]}' | jq '.coinbasevalue / 1e8'
  12.56368175
  ```

  Comme vous pouvez le voir, un mineur qui avait activé segwit aurait gagné plus de revenus qu'un mineur non-segwit si l'un de ces modèles
  de bloc d'exemple avait été miné. Bien qu'il s'agisse d'une petite différence en termes absolus en raison de mempools actuellement presque
  vides (environ 0,02 BTC ou 100 $ USD), en termes relatifs le modèle de bloc d'exemple incluant segwit reçoit presque 50 % de revenus de
  frais en plus que le modèle ne contenant que du legacy. Comme le minage est censé être un service de commodité avec de faibles marges
  bénéficiaires, cela semble être une incitation suffisante pour amener les mineurs à créer des blocs incluant segwit---et cela ne fera que
  devenir plus important à l'avenir à mesure que davantage d'utilisateurs adopteront segwit, que la subvention de bloc diminuera, et que
  peut-être les frais augmenteront.

  [Bitcoin Core 0.17.0.1][] a mis à jour la documentation intégrée de bitcoind pour GBT afin de mentionner la nécessité d'activer segwit, et
  il a été proposé dans une discussion entre développeurs d'activer GBT segwit par défaut dans une future version (tout en fournissant
  toujours une option rétrocompatible pour le désactiver).

- **Bug de dépassement dans l'implémentation bech32 de référence en langage C :** Trezor a [divulgué publiquement][bech32 overflow blog] un
  bug qu'ils ont découvert dans l'[implémentation de référence][bech32 c] de la fonction d'adresses bech32 pour le langage de programmation
  C. Un [correctif][bech32 patch] a été publié pour corriger le bug. Le bug n'affecte pas les utilisateurs des autres [implémentations de
  référence][bech32 refs] écrites dans d'autres langages de programmation ([source][achow bech32]).

  Comme Trezor a divulgué le bug de manière responsable à plusieurs autres projets, ils ont appris de Ledger l'existence d'un bug
  supplémentaire dans la bibliothèque [trezor-crypto][] pour les adresses de style Bitcoin Cash qui utilisent la même structure de base que
  les adresses bech32 de Bitcoin. Un [correctif][cashaddr patch] pour cela a également été publié.

- **Discussion sur l'amélioration des paiements Lightning :** en amont d'une prochaine réunion entre développeurs du protocole LN, Rusty
  Russell a lancé une [discussion][ln bolt11 ss] à propos de deux problèmes qui, selon lui, pourraient potentiellement être résolus en
  utilisant des scriptless scripts tels que décrits dans le [Bulletin #16][le bulletin #16].

  1. Une facture ne peut être payée qu'une seule fois au maximum. Il serait bien que plusieurs personnes puissent payer la même facture,
     comme une facture de don statique ou un paiement récurrent mensuel.

  2. Le protocole ne fournit pas de preuve de paiement par un dépensier particulier. Vous pouvez prouver qu'une facture particulière a été
     payée, et cette facture pourrait engager l'identité de la personne qui était censée la payer, mais le dépensier comme les nœuds qui
     aident à acheminer le paiement vers le destinataire ont tous les mêmes données sur le paiement, de sorte que n'importe lequel d'entre
     eux pourrait prétendre avoir envoyé le paiement lui-même.

## Optech recommande

Si vous cherchez davantage de nouvelles sur Lightning, consultez la nouvelle collection hebdomadaire de Rene Pickhardt des meilleurs tweets
sur LN et de ce que les gens construisent avec lui. Suivez [@renepickhardt][] sur Twitter pour obtenir les dernières nouvelles et consultez
les numéros déjà publiés : [1][lwil41], [2][lwil42], et [3][lwil43].

## Changements notables dans le code

*Changements de code notables cette semaine dans [Bitcoin Core][bitcoin core repo], [LND][lnd repo], [C-lightning][core lightning repo], et
[libsecp256k1][libsecp256k1 repo].*

- [Bitcoin Core #14454][] ajoute la prise en charge au RPC [importmulti][rpc importmulti] des adresses et scripts segwit (P2WPKH, P2WSH et
  segwit encapsulé dans P2SH). Un nouveau paramètre `witnessscript` remplit le même rôle pour segwit que le paramètre `redeemscript` pour
  P2SH. De plus, un paramètre `solvable` est ajouté au RPC [getaddressinfo][rpc getaddressinfo] pour indiquer à l'utilisateur si le
  portefeuille connaît le redeemScript ou le witnessScript pour une adresse P2SH ou P2WSH, c.-à-d. s'il sait comment créer une entrée non
  signée pour dépenser les paiements envoyés à cette adresse.

- [LND #2027][] ajoute une option de configuration qui permet à un nœud de rejeter l'ouverture de nouveaux canaux avec une « poussée »
  initiale de fonds. Cela élimine un problème occasionnel que voient les commerçants lorsque des utilisateurs inexpérimentés reçoivent une
  facture [BOLT11][] pour un certain montant d'argent, se rendent compte qu'ils n'ont pas de canal ouvert, puis ouvrent manuellement un
  canal avec un paiement initial du montant de la facture. Ce paiement émis manuellement n'est pas associé à la facture unique, de sorte que
  l'utilisateur ne reçoit pas le produit ou le service qu'il a tenté d'acheter et le commerçant doit émettre manuellement un remboursement
  (s'il le peut). Les commerçants qui activent la nouvelle option de configuration fournie par cette PR pourront automatiquement empêcher
  les utilisateurs de faire cette erreur.

- [C-Lightning #2061][] corrige le bug de dépassement dans le décodage bech32 tel que décrit dans la section *Nouvelles*.

{% include references.md %}
{% include linkers/issues.md issues="14454,2027,2061" %}

[achow bech32]: https://twitter.com/achow101/status/1058370040368644097
[@renepickhardt]: https://twitter.com/renepickhardt
[lwil41]: https://twitter.com/i/moments/1051149970026442753
[lwil42]: https://twitter.com/i/moments/1051399582662443009
[lwil43]: https://twitter.com/i/moments/1055475460816228354

[bech32 c]: https://github.com/sipa/bech32/tree/master/ref/c
[bech32 patch]: https://github.com/sipa/bech32/commit/2b0aac650ce560fb2b2a2bebeacaa5c87d7e5938
[Bitcoin Core 0.17.0.1]: https://bitcoincore.org/en/releases/0.17.0.1/
[bech32 overflow blog]: https://blog.trezor.io/details-about-the-security-updates-in-trezor-one-firmware-1-7-1-5c34278425d8
[bech32 refs]: https://github.com/sipa/bech32/tree/master/ref/
[trezor-crypto]: https://github.com/trezor/trezor-crypto/
[cashaddr patch]: https://github.com/trezor/trezor-crypto/commit/2bbbc3e15573294c6dd0273d2a8542ba42507eb0
[ln bolt11 ss]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001489.html
[le bulletin #16]: /fr/newsletters/2018/10/09/#ecdsa-multipartite-pour-des-canaux-de-paiement-lightning-network-sans-script
[output script descriptor]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
