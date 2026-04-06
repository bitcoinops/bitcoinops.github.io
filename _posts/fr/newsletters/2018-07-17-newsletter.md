---
title: 'Bulletin Hebdomadaire Bitcoin Optech #4'
permalink: /fr/newsletters/2018/07/17/
name: 2018-07-17-newsletter-fr
slug: 2018-07-17-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
version: 1
---
Le bulletin de cette semaine inclut des nouvelles et des points d'action à propos d'un gel des fonctionnalités pour la prochaine version
majeure de Bitcoin Core, de l'augmentation des frais de transaction, d'un probable renommage du drapeau proposé `SIGHASH_NOINPUT`, et de
plusieurs fusions récentes notables dans Bitcoin Core.

## Points d'action

- Dernière chance de plaider en faveur de toute nouvelle fonctionnalité presque prête afin qu'elle soit incluse dans Bitcoin Core 0.17, dont
  la sortie est attendue en août ou en septembre. La date de gel des fonctionnalités mentionnée dans le [bulletin #3][] a été repoussée
  d'une semaine au 23 juillet.

## Éléments du tableau de bord

- **Frais de transaction en hausse :** pour les transactions visant une confirmation dans les 12 blocs ou moins, les [frais recommandés][]
  ont augmenté jusqu'à 3x par rapport à la même période la semaine dernière. Les nœuds avec les paramètres par défaut ont encore largement
  de la place dans leurs mempools, donc la tendance pourrait rapidement s'inverser. Il est recommandé d'être prudent avec les transactions
  de consolidation à bas coût jusqu'à ce que les taux de frais baissent à nouveau, sauf si vous pouvez potentiellement attendre plusieurs
  semaines pour que la transaction de consolidation soit confirmée.

## Nouvelles

- **Discussion sur les groupes de sélection de pièces :** cette semaine, la discussion a porté sur la PR Bitcoin Core [#12257][], qui ajoute
  au portefeuille une option entraînant la dépense de chaque sortie payée à la même adresse dès qu'une seule de ces sorties est dépensée.
  L'une des motivations de cette PR est d'améliorer la confidentialité, car sinon dépenser plusieurs sorties reçues à la même adresse dans
  des transactions différentes créera un lien réduisant la confidentialité entre ces transactions. Mais cette option consolide aussi
  automatiquement les entrées, ce qui peut être particulièrement intéressant pour les entreprises Bitcoin qui reçoivent fréquemment
  plusieurs paiements à la même adresse.

- **Poursuite de la discussion sur les signatures Schnorr :** aucun défaut n'a été identifié avec la proposition de BIP [décrite][schnorr feature]
  dans le bulletin de la semaine dernière, mais deux développeurs ont proposé des optimisations, [dont l'une][multiparty signatures] s'est
  heurtée à des considérations de sécurité et [dont une autre][rearrange schnorr] ne sera probablement pas ajoutée car sa légère
  optimisation se fait au prix de la suppression d'une autre légère optimisation.

- **Nommage de `SIGHASH_NOINPUT` :** [BIP118][] décrit un nouveau drapeau facultatif de hachage de signature (sighash) qui n'identifie pas
  quel ensemble de bitcoins il dépense. Le principal élément utilisé pour déterminer si la dépense est valide est de savoir si le script de
  signature (witness) remplit toutes les conditions du script de clé publique (encumbrance).

  Par exemple, dans le protocole de contrat intelligent [Eltoo][] visant à améliorer le Lightning Network (LN), Alice et Bob signent chaque
  changement de solde dans un canal de paiement avec ce nouveau drapeau sighash afin que, lorsqu'ils veulent fermer le canal, l'un ou
  l'autre puisse utiliser la transaction avec le solde final pour dépenser depuis la transaction avec le solde initial.

  Cependant, une utilisation naïve de ce nouveau drapeau sighash peut causer une perte inattendue de fonds. Par exemple, Alice reçoit des
  bitcoins à une adresse particulière ; elle dépense ensuite ces bitcoins à Bob en utilisant le nouveau drapeau sighash. Plus tard, Alice
  reçoit davantage de bitcoins à la même adresse---Bob peut maintenant voler ces bitcoins en réutilisant la même signature qu'Alice a
  utilisée auparavant. Notez que cela n'affecte que les personnes utilisant le nouveau drapeau sighash ; cela n'affecte pas les transactions
  sans rapport.

  La [discussion][unsafe sighash] cette semaine sur les listes de diffusion bitcoin-dev et lightning-dev portait sur le nom à donner au
  drapeau sighash afin que les développeurs ne l'utilisent pas accidentellement sans se rendre compte de ses dangers. Un consensus
  approximatif semble s'être formé autour du nom `SIGHASH_NOINPUT_UNSAFE`.

## Fusions notables dans Bitcoin Core

- **<!--n-->[#13072][] :** le RPC `createmultisig` peut désormais créer des adresses segwit encapsulées dans P2SH et des adresses segwit
  natives.

- **<!--n-->[#13543][] :** ajout de la prise en charge de l'architecture CPU RISC-V.

- **<!--n-->[#13386][] :** nouvelles fonctions SHA256 spécialisées qui tirent parti des extensions CPU et de la connaissance d'entrées de
  données spécifiques utilisées par Bitcoin Core (comme le cas très courant où les données d'entrée font exactement 64 octets, comme c'est
  le cas pour chaque calcul dans un arbre de Merkle Bitcoin). Cela peut fournir jusqu'à un gain de vitesse de 9x par rapport à Bitcoin Core
  0.16.x dans les cas où le nouveau code s'applique et est pris en charge par le CPU de l'utilisateur. Le code aide principalement à
  accélérer la validation des blocs, à la fois des blocs historiques durant la synchronisation initiale et des nouveaux blocs pendant le
  fonctionnement normal.

- **<!--n-->[#13452][] :** le RPC `verifytxoutproof` n'est plus vulnérable à une [attaque coûteuse particulière][tx-as-internal-node] contre
  les preuves SPV divulguée publiquement au début de juin. L'attaque était considérée comme peu probable étant donné que des attaques bien
  moins coûteuses et d'une efficacité à peu près égale sont bien connues. Voir également la PR fusionnée [#13451][] qui ajoute au RPC
  `getblock` des informations supplémentaires pouvant être utilisées pour contrer l'attaque. Rien de tout cela n'atténue l'attaque pour les
  clients SPV réels.

- **<!--n-->[#13570][] :** nouveau RPC `getzmqnotifications` qui « renvoie des informations sur tous les points de terminaison de
  notification ZMQ actifs. Cela est utile pour les logiciels qui se superposent à bitcoind. »

- **<!--n-->[#13096][] :** augmentation de la taille maximale des transactions qui seront relayées par défaut de 99 999 vbytes à 100 000
  vbytes.

[bulletin #3]: /fr/newsletters/2018/07/10/
[frais recommandés]: https://p2sh.info/dashboard/db/fee-estimation?orgId=1&from=now-7d&to=now&var-source=bitcoind
[multiparty signatures]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-July/016215.html
[rearrange schnorr]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-July/016211.html
[BIP118]: https://github.com/bitcoin/bips/blob/master/bip-0118.mediawiki
[eltoo]: https://blockstream.com/eltoo.pdf
[unsafe sighash]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-July/016187.html
[popular twitter thread]: https://twitter.com/orionwl/status/1014829318986436608
[schnorr feature]: /fr/newsletter/2018/07/10/#nouvelle-en-vedette-proposition-de-bip-pour-les-signatures-schnorr
[#12257]: https://github.com/bitcoin/bitcoin/pull/12257
[#13072]: https://github.com/bitcoin/bitcoin/pull/13072
[#13543]: https://github.com/bitcoin/bitcoin/pull/13543
[#13386]: https://github.com/bitcoin/bitcoin/pull/13386
[#13452]: https://github.com/bitcoin/bitcoin/pull/13452
[#13451]: https://github.com/bitcoin/bitcoin/pull/13451
[#13570]: https://github.com/bitcoin/bitcoin/pull/13570
[#13096]: https://github.com/bitcoin/bitcoin/pull/13096
[tx-as-internal-node]: https://bitslog.wordpress.com/2018/06/09/leaf-node-weakness-in-bitcoin-merkle-tree-design/
[musig]: https://eprint.iacr.org/2018/068
