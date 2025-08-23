---
title: 'Bulletin Hebdomadaire Bitcoin Optech #367'
permalink: /fr/newsletters/2025/08/15/
name: 2025-08-15-newsletter-fr
slug: 2025-08-15-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine inclut nos sections régulières résumant les
annonces de nouvelles versions et de candidats à la publication, et les résumés des modifications
notables apportées aux logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

_Aucune nouvelle significative n'a été trouvée cette semaine dans aucune de nos [sources][optech
sources]._

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates._

- [LND v0.19.3-beta.rc1][] est un candidat à la sortie pour une version de maintenance pour cette
  implémentation populaire de nœud LN contenant des "corrections de bugs importantes". Plus
  notablement, "une migration optionnelle [...] réduit de manière significative les exigences en
  disque et en mémoire pour les nœuds."

- [Bitcoin Core 29.1rc1][] est un candidat à la sortie pour une version de maintenance du logiciel
  de nœud complet prédominant.

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi
repo], [Rust Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo],
[Propositions d'Amélioration de Bitcoin (BIPs)][bips repo], [BOLTs Lightning][bolts repo],
[BLIPs Lightning][blips repo], [Inquisition Bitcoin][bitcoin inquisition
repo], et [BINANAs][binana repo]._

- [Bitcoin Core #33050][] supprime la découragement des pairs (voir le [Bulletin
  #309][news309 peer]) pour les transactions invalides selon le consensus car sa protection DoS était
  inefficace. Un attaquant pourrait contourner la protection en
  spammant des transactions invalides selon la politique sans pénalité. Cette mise à jour élimine
  le besoin de double validation de script car il n'est plus nécessaire de
  distinguer entre les échecs de consensus et de standard, économisant ainsi des coûts CPU.

- [Bitcoin Core #32473][] introduit un cache par entrée pour la pré-computation de sighash
  à l'interpréteur de script pour les entrées legacy (par exemple, baremultisig),
  P2SH, P2WSH (et par incidence P2WPKH) pour réduire l'impact des attaques de hachage quadratique dans
  les transactions standard. Core met en cache un hash presque fini
  calculé juste avant d'ajouter le byte de sighash pour réduire le hachage répété pour
  les transactions multisig standard et des motifs similaires. Une autre signature dans la
  même entrée avec le même mode de sighash qui s'engage sur la même portion du
  script peut réutiliser la plupart du travail. Il est activé à la fois dans la politique (mempool) et
  la validation de consensus (bloc). Les entrées [Taproot][topic taproot] ont déjà
  ce comportement par défaut, donc cette mise à jour n'a pas besoin d'être appliquée à elles.

- [Bitcoin Core #33077][] crée une bibliothèque statique monolithique
  [`libbitcoinkernel.a`][libbitcoinkernel project] qui regroupe tous les fichiers objet
  de ses dépendances privées dans une seule archive, permettant aux projets en aval
  de se lier juste à ce fichier unique. Voir le [Bulletin #360][news360 kernel]
  pour les travaux préparatoires liés à `libsecp256k1`.

- [Core Lightning #8389][] rend le champ `channel_type` obligatoire lors de l'ouverture
  d'un canal, en accord avec une récente mise à jour de la spécification (voir le [Bulletin
  #364][news364 spec]). Les commandes RPC `fundchannel` et `fundchannel_start`
  indiquent désormais un type de canal avec l'option [canal zero-conf][topic zero-conf
  channels] lorsque un `minimum_depth` nul le suggère.

{% include snippets/recap-ad.md when="2025-08-19 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33050,32473,33077,8389" %}
[bitcoin core 29.1rc1]: https://bitcoincore.org/bin/bitcoin-core-29.1/
[lnd v0.19.3-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.3-beta.rc1
[news309 peer]: /en/newsletters/2024/06/28/#bitcoin-core-29575
[news360 kernel]: /en/newsletters/2025/06/27/#libsecp256k1-1678
[libbitcoinkernel project]: https://github.com/bitcoin/bitcoin/issues/27587
[news364 spec]: /en/newsletters/2025/07/25/#bolts-1232