---
title: 'Bitcoin Optech Newsletter #277'
permalink: /fr/newsletters/2023/11/15/
name: 2023-11-15-newsletter-fr
slug: 2023-11-15-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit une mise à jour de la proposition sur les points d'ancrage éphémères et fournit un rapport
d'une contribution de terrain sur Miniscript par un développeur travaillant chez Wizardsardine. Sont également incluses nos sections
régulières avec des annonces de mises à jour et versions candidates, ainsi que les changements apportés aux principaux logiciels
d'infrastructure Bitcoin.

## Nouvelles

- **Élimination de la malléabilité des dépenses d'ancrage éphémère :** Gregory Sanders a [publié][sanders mal] sur le forum Delving
  Bitcoin une modification de la proposition concernant les [points d'ancrage éphémères][topic ephemeral anchors]. Cette proposition
  permettrait aux transactions d'inclure une sortie de valeur nulle avec un script de sortie pouvant être dépensé par n'importe qui.
  Comme n'importe qui peut dépenser la sortie, n'importe qui peut augmenter les frais de transaction [CPFP][topic cpfp] de la transaction
  qui a créé la sortie. Cela est pratique pour les protocoles de contrat multipartite tels que LN, où les transactions sont souvent
  signées avant qu'il soit possible de prédire avec précision le taux de frais qu'elles doivent payer. Les points d'ancrage éphémères
  permettent à n'importe quelle partie du contrat d'ajouter autant de frais qu'elle estime nécessaire. Si une autre partie, ou tout autre
  utilisateur pour une raison quelconque, souhaite ajouter des frais plus élevés, elle peut [remplacer][topic rbf] l'augmentation des
  frais CPFP par sa propre augmentation des frais CPFP à un taux plus élevé.

  Le script anyone-can-spend proposé est un script de sortie composé de l'équivalent
  de `OP_TRUE`, qui peut être dépensé par une entrée avec un script d'entrée vide. Comme l'a publié Sanders cette semaine, l'utilisation
  d'un script de sortie hérité signifie que la transaction enfant qui le dépense a un txid malléable, c'est-à-dire que n'importe quel
  mineur peut ajouter des données au script d'entrée pour modifier le txid de la transaction enfant. Il est donc déconseillé
  d'utiliser la transaction enfant pour autre chose que l'augmentation des frais, car même si elle est confirmée, elle peut être
  confirmée avec un txid différent qui invalide toutes les transactions petites-filles.

  Sanders suggère plutôt d'utiliser l'un des scripts de sortie qui avaient été réservés pour les futures mises à niveau de SegWit.
  Cela consomme légèrement plus d'espace dans le bloc---quatre octets pour SegWit contre un octet pour `OP_TRUE` nu---mais élimine tout
  problème concernant la malléabilité de la transaction. Après quelques discussions sur le fil, Sanders a proposé plus tard
  d'offrir les deux options : une version `OP_TRUE` pour ceux qui ne se soucient pas de la malléabilité et qui veulent minimiser la
  taille de la transaction, ainsi qu'une version SegWit légèrement plus grande mais qui n'autorise pas la mutation de la transaction
  enfant. Les discussions supplémentaires sur le fil se sont concentrées sur le choix des octets supplémentaires pour l'approche SegWit
  afin de créer une adresse [bech32m mémorable][topic bech32].

## Rapport de terrain : Un voyage avec Miniscript

{% include articles/fr/wizardsardine-miniscript.md %}

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets
d'infrastructure Bitcoin. Veuillez envisager de passer aux nouvelles
versions ou d'aider à tester les versions candidates.*

- [LND 0.17.1-beta][] est une version de maintenance de cette implémentation de nœud LN qui comprend plusieurs corrections de bugs et
  améliorations mineures.

- [Bitcoin Core 26.0rc2][] est une version candidate pour la prochaine version majeure de l'implémentation principale du nœud complet.
  Il existe un [guide de test][26.0 testing] et une réunion prévue du [Bitcoin Core PR Review Club][] dédiée aux tests le 15 novembre 2023.

- [Core Lightning 23.11rc1][] est une version candidate pour la prochaine version majeure de cette implémentation de nœud LN.

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Interface de portefeuille matériel (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo], [Propositions d'amélioration de Bitcoin
(BIP)][bips repo], [Lightning BOLTs][bolts repo] et [Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #28207][] met à jour la façon dont le mempool est stocké sur le disque (ce qui se produit normalement lors de l'arrêt du
  nœud, mais peut également être déclenché par l'API `savemempool`). Auparavant, il était stocké dans une sérialisation simple des données
  sous-jacentes. Maintenant, cette structure sérialisée est XORée par une valeur aléatoire générée indépendamment par chaque nœud,
  obfusquant les données. Elle est XORée par la même valeur lors du chargement pour supprimer l'obscurcissement. L'obscurcissement empêche
  quelqu'un de pouvoir mettre certaines données dans une transaction pour obtenir une séquence particulière d'octets dans les données
  du mempool enregistrées, ce qui pourrait amener des programmes tels que les scanners de virus à signaler les données du mempool
  enregistrées comme dangereuses. La même méthode était précédemment appliquée au stockage de l'ensemble UTXO dans
  [PR #6650][bitcoin core #6650]. Tout logiciel qui a besoin de lire les données du mempool à partir du disque devrait pouvoir appliquer
  facilement lui-même l'opération XOR, ou utiliser le paramètre de configuration `-persistmempoolv1` pour demander l'enregistrement dans
  le format non obscurci. Notez qu'on prévoit de supprimer le paramètre de configuration de compatibilité ascendante dans une version
  future.

- [LDK #2715][] permet à un nœud d'accepter facultativement une valeur [HTLC][topic htlc] plus petite que celle censée être livrée.
  Cela est utile lorsque le pair amont paie le nœud via un nouveau [canal JIT][topic jit channels], ce qui coûte au pair amont des
  frais de transaction on-chain qu'il déduira s'il le souhaite du montant de l'HTLC payé au nœud. Voir [Newsletter #257][news257 jitfee] pour
  l'implémentation précédente de la partie amont de cette fonctionnalité dans LDK.

{% include snippets/recap-ad.md when="2023-11-16 15:00" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28207,6650,2715" %}
[bitcoin core 26.0rc2]: https://bitcoincore.org/bin/bitcoin-core-26.0/
[26.0 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/26.0-Release-Candidate-Testing-Guide
[core lightning 23.11rc1]: https://github.com/ElementsProject/lightning/releases/tag/v23.11rc1
[lnd 0.17.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.1-beta
[sanders mal]: https://delvingbitcoin.org/t/segwit-ephemeral-anchors/160
[news257 jitfee]: /fr/newsletters/2023/06/28/#ldk-2319
