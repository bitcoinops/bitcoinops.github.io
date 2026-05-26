---
title: 'Bulletin Hebdomadaire Bitcoin Optech #398'
permalink: /fr/newsletters/2026/03/27/
name: 2026-03-27-newsletter-fr
slug: 2026-03-27-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine comprend nos rubriques régulières avec des questions et réponses sélectionnées de Bitcoin Stack Exchange, des
annonces de nouvelles versions et versions candidates, et des descriptions de changements notables dans des logiciels d'infrastructure
Bitcoin populaires.

## Nouvelles

*Aucune nouvelle significative cette semaine n'a été trouvée dans nos [sources][].*

## Questions et réponses sélectionnées de Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech cherchent des réponses à leurs
questions---ou quand nous avons quelques moments libres pour aider les utilisateurs curieux ou confus. Dans cette rubrique mensuelle, nous
mettons en lumière certaines des questions et réponses les mieux votées postées depuis notre dernière mise à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Que signifie « Bitcoin n'utilise pas le chiffrement » ?]({{bse}}130576) Pieter Wuille distingue le chiffrement ayant pour but de
  dissimuler des données à des parties non autorisées (pour lequel l'ECDSA de Bitcoin ne peut pas être utilisée) des signatures numériques
  que Bitcoin utilise pour la vérification et l'authentification.

- [Quand et pourquoi Bitcoin Script est-il passé à une structure commit–reveal ?]({{bse}}130580) L'utilisateur bca-0353f40e explique
  l'évolution depuis l'approche originale de Bitcoin où les utilisateurs payaient directement vers des clés publiques vers P2PKH puis P2SH,
  les approches [segwit][topic segwit] et [taproot][topic taproot], où les conditions de dépense sont engagées dans la sortie et seulement
  révélées lors de la dépense.

- [Est-ce que P2TR-MS (multisig Taproot M-sur-N) divulgue des clés publiques ?]({{bse}}130574) Murch confirme qu'un multisig en scriptpath
  taproot à feuille unique expose toutes les clés publiques éligibles lors de la dépense puisque OP_CHECKSIG et OP_CHECKSIGADD exigent tous
  deux que la clé publique correspondant à la signature soit présente.

- [Est-ce que OP_CHECKSIGFROMSTACK autorise intentionnellement la réutilisation de signatures entre UTXO ?]({{bse}}130598) L'utilisateur
  bca-0353f40e explique que [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] ([BIP348][]) ne lie délibérément pas les signatures à des
  entrées spécifiques, ce qui permet de combiner CSFS avec d'autres opcodes de [convenant][topic covenants] afin de permettre des signatures
  reliables, le mécanisme sous-jacent à [LN-Symmetry][topic eltoo].

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires. Veuillez envisager de mettre à niveau vers
les nouvelles versions ou d'aider à tester les versions candidates._

- [Bitcoin Core 28.4][] est une version de maintenance pour une série précédente de versions majeures de l'implémentation de nœud complet
  prédominante. Elle contient principalement des correctifs de migration de portefeuille et la suppression d'une seed DNS non fiable. Voir
  les [notes de version][bcc 28.4 rn] pour les détails.

- [Core Lightning 26.04rc1][] est une version candidate pour la prochaine version majeure de ce nœud LN populaire qui inclut de nombreuses
  mises à jour de splicing et des corrections de bugs.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning
BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #33259][] ajoute un champ `backgroundvalidation` à la réponse RPC `getblockchaininfo` pour les nœuds utilisant des
  instantanés [assumeUTXO][topic assumeutxo]. Le nouveau champ rapporte la hauteur de l'instantané, la hauteur et le hachage du bloc courant
  pour la validation en arrière-plan, le temps médian, le chainwork, et la progression de la vérification. Auparavant, la réponse de
  `getblockchaininfo` indiquait simplement que la vérification et l'IBD étaient terminés sans aucune information sur la validation en
  arrière-plan.

- [Bitcoin Core #33414][] active les [défenses par preuve de travail][tor pow] Tor pour les services onion créés automatiquement
  lorsqu'elles sont prises en charge par le démon Tor connecté. Lorsqu'un démon Tor dispose d'un port de contrôle accessible et que le
  paramètre `listenonion` de Bitcoin Core est activé (par défaut), il crée automatiquement un service caché. Cela ne s'applique pas aux
  services onion créés manuellement, mais il est suggéré que les utilisateurs ajoutent `HiddenServicePoWDefensesEnabled 1` pour activer les
  défenses par preuve de travail.

- [Bitcoin Core #34846][] ajoute les fonctions `btck_transaction_get_locktime` et `btck_transaction_input_get_sequence` à l'API C de
  `libbitcoinkernel` (voir le [Bulletin #380][news380 kernel]) pour accéder aux champs de [timelock][topic timelocks] : le `nLockTime` d'une
  transaction et le `nSequence` d'une entrée. Cela permet de vérifier des règles de [BIP54][] ([nettoyage du consensus][topic consensus
  cleanup]) telles que les contraintes sur le `nLockTime` des coinbase sans désérialiser manuellement la transaction (d'autres règles de
  BIP54, telles que les limites de sigops, nécessitent toujours un traitement séparé).

- [Core Lightning #8450][] étend le moteur de script de [splice][topic splicing] de CLN pour gérer les splices inter-canaux, les splices
  multi-canaux (plus de trois), et le calcul dynamique des frais. Un problème clé que cela résout est la dépendance circulaire dans
  l'estimation des frais : l'ajout d'entrées de portefeuille augmente le poids de la transaction et donc les frais requis, ce qui peut à son
  tour nécessiter des entrées supplémentaires. Cette infrastructure sous-tend les nouveaux RPC `splicein` et `spliceout`.

- [Core Lightning #8856][] et [#8857][core lightning #8857] ajoutent des commandes RPC `splicein` et `spliceout` pour ajouter des fonds du
  portefeuille interne dans un canal et pour retirer des fonds d'un canal vers le portefeuille interne, une adresse Bitcoin, ou un autre
  canal (effectivement un cross-splice). Les nouvelles commandes évitent aux opérateurs d'avoir à construire manuellement des transactions
  de [splicing][topic splicing] avec le RPC expérimental `dev-splice`.

- [Eclair #3247][] ajoute un système optionnel de notation des pairs qui suit, par pair, les revenus de transfert et le volume de paiements
  au fil du temps. Lorsqu'il est activé, il classe périodiquement les pairs par rentabilité et peut optionnellement financer automatiquement
  des canaux vers les pairs les plus rémunérateurs, fermer automatiquement les canaux improductifs pour récupérer de la liquidité, et
  ajuster automatiquement les frais de relais selon le volume, le tout dans des limites configurables. Les opérateurs peuvent commencer avec
  la visibilité seule avant d'opter pour l'automatisation.

- [LDK #4472][] corrige un scénario potentiel de perte de fonds pendant le financement de canal et le [splicing][topic splicing] où
  `tx_signatures` pouvait être envoyé avant que la signature d'engagement de la contrepartie ne soit durablement persistée. Si la
  transaction est confirmée puis que le nœud plante, il perdrait la capacité de faire respecter son état de canal. Le correctif reporte la
  publication de `tx_signatures` jusqu'à ce que la mise à jour du moniteur correspondante soit terminée.

- [LND #10602][] ajoute un RPC `DeleteAttempts` au sous-système expérimental `switchrpc` (voir le [Bulletin #386][news386 sendonion]) pour
  permettre à des contrôleurs externes de supprimer explicitement les enregistrements d'essais de [HTLC][topic htlc] terminés (réussis ou
  échoués, pas en attente) du magasin d'essais de LND.

- [LND #10481][] ajoute un backend de minage `bitcoind` au framework de tests d'intégration de LND. Auparavant, `lntest` supposait un mineur
  basé sur `btcd` même lors de l'utilisation de `bitcoind` comme backend de chaîne. Ce changement permet aux tests d'exercer des
  comportements qui dépendent de la mempool et de la politique de minage de Bitcoin Core, y compris le [relais de transactions v3][topic v3
  transaction relay] et le [relais de packages][topic package relay].

- [BOLTs #1160][] fusionne le protocole de [splicing][topic splicing] dans la spécification Lightning, remplaçant le brouillon de [BOLTs
  #863][] par des flux mis à jour et des vecteurs de test pour les cas limites qui ont motivé la réécriture (voir [Bulletin #246][news246
  splicing draft] pour la discussion lorsque ce brouillon était en développement actif). Le splicing permet à des pairs d'ajouter ou retirer
  des fonds sans fermer le canal ; la négociation commence depuis un état quiescent ([BOLTs
  #869][], [Bulletin #309][news309 quiescence]). Le texte fusionné de BOLT2 couvre
  la construction interactive de la transaction de splice, la poursuite de l'exploitation du canal pendant qu'un splice n'est pas confirmé,
  le [RBF][topic rbf] des splices en attente, le comportement lors de la reconnexion, `splice_locked` après une profondeur suffisante, et
  des [annonces de canaux][topic channel announcements] mises à jour.

{% include snippets/recap-ad.md when="2026-03-31 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33259,33414,34846,8450,8856,8857,3247,4472,10602,10481,1160,863,869" %}
[sources]: /en/internal/sources/
[Bitcoin Core 28.4]: https://bitcoincore.org/en/2026/03/18/release-28.4/
[bcc 28.4 rn]: https://bitcoincore.org/en/releases/28.4/
[Core Lightning 26.04rc1]: https://github.com/ElementsProject/lightning/releases/tag/v26.04rc1
[tor pow]: https://tpo.pages.torproject.net/onion-services/ecosystem/technology/security/pow/
[news380 kernel]: /fr/newsletters/2025/11/14/#bitcoin-core-30595
[news386 sendonion]: /fr/newsletters/2026/01/02/#lnd-9489
[news246 splicing draft]: /fr/newsletters/2023/04/12/#discussions-sur-les-specifications-du-splicing
[news309 quiescence]: /fr/newsletters/2024/06/28/#bolts-869
