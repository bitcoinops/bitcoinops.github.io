---
title: 'Bulletin Hebdomadaire Bitcoin Optech #400'
permalink: /fr/newsletters/2026/04/10/
name: 2026-04-10-newsletter-fr
slug: 2026-04-10-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine comprend nos rubriques habituelles résumant une réunion du Bitcoin Core PR Review Club et décrivant les
changements notables apportés aux projets d'infrastructure Bitcoin populaires.

## Nouvelles

*Aucune nouvelle significative cette semaine n'a été trouvée dans nos [sources][].*

## Bitcoin Core PR Review Club
*Dans cette section mensuelle, nous résumons une récente réunion du [Bitcoin Core PR Review Club][].*

[Testing Bitcoin Core 31.0 Release Candidates][review club v31-rc-testing] était une réunion du review club qui n'examinait pas une PR
particulière, mais constituait plutôt un effort de test en groupe.

Avant chaque [version majeure de Bitcoin Core][], des tests approfondis par la communauté sont considérés comme essentiels. Pour cette
raison, un bénévole rédige un guide de test pour une version candidate afin que le plus grand nombre possible de personnes puissent tester
de manière productive sans avoir à déterminer indépendamment ce qui est nouveau ou a changé dans la version, et à réinventer les différentes
étapes de configuration nécessaires pour tester ces fonctionnalités ou changements.

Les tests peuvent être difficiles car lorsqu'on rencontre un comportement inattendu, il est souvent difficile de savoir s'il est dû à un
véritable bogue ou si le testeur commet une erreur. Signaler aux développeurs des bogues qui n'en sont pas fait perdre leur temps. Pour
atténuer ces problèmes et promouvoir les efforts de test, une réunion du Review Club est organisée pour une version candidate particulière.

Le [guide de test de la version candidate 31.0][31.0 testing] a été rédigé par [svanstaa][gh svanstaa] (voir [Podcast #397][pod397 v31rc1]),
qui a également animé la réunion du review club.

Les participants ont également été encouragés à trouver des idées de test en lisant les [notes de version de la 31.0][31.0 release notes].

Le guide de test couvre le [cluster mempool][topic cluster mempool], y compris de nouveaux RPC et les limites de cluster (voir le [Bulletin
#382][news382 bc33629]), la diffusion privée (voir le [Bulletin
#388][news388 bc29415]), un RPC `getblock` mis à jour avec un nouveau champ `coinbase_tx`
(voir le [Bulletin #394][news394 bc34512]), un nouvel index `txospenderindex` qui suit quelle transaction dépense chaque sortie (voir le [Bulletin
#394][news394 bc24539]), une taille par défaut augmentée de `-dbcache` (voir le [Bulletin #396][news396 bc34692]), des données ASMap intégrées
(voir le [Bulletin #394][news394 bc28792]), et un nouvel endpoint `blockpart` de l'API REST (voir le [Bulletin #386][news386 bc33657]).

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning
BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #33908][] ajoute `btck_check_block_context_free` à l'API C de `libbitcoinkernel` (voir le [Bulletin #380][news380 kernel]) pour
  valider des blocs candidats avec des vérifications indépendantes du contexte : limites de taille/poids des blocs, règles relatives à la
  coinbase, et vérifications par transaction qui ne dépendent ni du chainstate, ni de l'index des blocs, ni de l'ensemble UTXO. Les
  appelants peuvent activer en option la vérification de la preuve de travail et celle de la racine de Merkle dans cet endpoint.

- [Eclair #3283][] ajoute un champ `fee` (en msats) aux réponses au format complet des endpoints `findroute`, `findroutetonode` et
  `findroutebetweennodes` utilisés pour la recherche de chemin. Ce champ fournit le [frais de transfert][topic inbound forwarding fees]
  total de la route, éliminant la nécessité pour les appelants de le calculer manuellement.

- [LDK #4529][] permet aux opérateurs de définir différentes limites pour les canaux annoncés et les [canaux non annoncés][topic unannounced
  channels] lors de la configuration de la valeur totale des [HTLCs][topic htlc] entrants en vol, en pourcentage de la capacité du canal.
  Les valeurs par défaut sont désormais de 25 % pour les canaux annoncés et de 100 % pour les canaux non annoncés.

- [LDK #4494][] met à jour sa logique interne de [RBF][topic rbf] pour garantir la conformité avec les règles de remplacement de [BIP125][]
  à faibles taux de frais. Au lieu de n'appliquer que le multiplicateur de taux de frais 25/24 spécifié dans [BOLT2][], LDK utilise
  désormais la valeur la plus élevée entre ce multiplicateur et 25 sat/kwu supplémentaires. Une clarification connexe de la spécification
  est en cours de discussion dans [BOLTs #1327][].

- [LND #10666][] ajoute un RPC `DeleteForwardingHistory` et une commande `lncli deletefwdhistory`, permettant aux opérateurs de supprimer de
  manière sélective les événements de transfert antérieurs à un horodatage de coupure choisi. Une garde d'âge minimale d'une heure empêche
  la suppression accidentelle de données récentes. Cette fonctionnalité permet aux nœuds de routage de supprimer des enregistrements
  historiques de transfert sans réinitialiser la base de données ni mettre le nœud hors ligne.

- [BIPs #2099][] publie [BIP393][], qui spécifie une syntaxe d'annotation optionnelle pour les [descripteurs][topic descriptors] de scripts
  de sortie, permettant aux portefeuilles de stocker des indications de récupération, comme une hauteur de naissance pour accélérer
  l'analyse du portefeuille (y compris pour l'analyse des [silent payments][topic silent payments]). Voir le [Bulletin
  #394][news394 bip393] pour la couverture initiale de ce BIP avec des détails supplémentaires.

- [BIPs #2118][] publie [BIP440][] et [BIP441][] comme brouillon de BIPs dans la série Great Script Restoration (ou Grand Script
  Renaissance) (voir le [Bulletin #399][news399 bips]). [BIP440][] propose le Varops Budget for Script Runtime Constraint (voir le [Bulletin
  #374][news374 varops]) ; [BIP441][] décrit une nouvelle version de [tapscript][topic tapscript] qui restaure des opcodes désactivés en
  2010 tels que [OP_CAT][topic op_cat] (voir le [Bulletin #374][news374 tapscript]) et limite les coûts d'évaluation des scripts conformément
  au budget varops introduit dans BIP440.

- [BIPs #2134][] met à jour [BIP352][] ([silent payments][topic silent payments]) pour avertir les développeurs de portefeuilles de ne pas
  laisser le filtrage par politique, tel que pour les [dust][topic uneconomical outputs], affecter la poursuite ou non de l'analyse après
  qu'une correspondance a été trouvée. Traiter une sortie filtrée comme s'il n'y avait eu aucune correspondance peut amener le portefeuille
  à arrêter l'analyse prématurément et à manquer des sorties ultérieures du même expéditeur.

{% include snippets/recap-ad.md when="2026-04-14 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33908,3283,4529,4494,10666,2099,2118,2134,1327" %}

[sources]: /en/internal/sources/
[news380 kernel]: /fr/newsletters/2025/11/14/#bitcoin-core-30595
[news394 bip393]: /fr/newsletters/2026/02/27/#brouillon-de-bip-pour-les-annotations-de-descripteur-de-script-de-sortie
[news399 bips]: /fr/newsletters/2026/04/03/#le-budget-varops-et-la-feuille-tapscript-0xc2-alias-script-restoration-sont-les-bip-440-et-441
[news374 varops]: /fr/newsletters/2025/10/03/#mises-à-jour-et-versions-candidates
[news374 tapscript]: /fr/newsletters/2025/10/03/#bitcoin-core-30-0rc2
[BIP393]: https://github.com/bitcoin/bips/blob/master/bip-0393.mediawiki
[BIP440]: https://github.com/bitcoin/bips/blob/master/bip-0440.mediawiki
[BIP441]: https://github.com/bitcoin/bips/blob/master/bip-0441.mediawiki
[review club v31-rc-testing]: https://bitcoincore.reviews/v31-rc-testing
[version majeure de bitcoin core]: https://bitcoincore.org/en/lifecycle/#versioning
[31.0 release notes]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/31.0-Release-Notes-Draft
[31.0 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/31.0-Release-Candidate-Testing-Guide
[gh svanstaa]: https://github.com/svanstaa
[pod397 v31rc1]: /en/podcast/2026/03/24/#bitcoin-core-31-0rc1-transcript
[news382 bc33629]: /fr/newsletters/2025/11/28/#bitcoin-core-33629
[news388 bc29415]: /fr/newsletters/2026/01/16/#bitcoin-core-29415
[news394 bc34512]: /fr/newsletters/2026/02/27/#bitcoin-core-34512
[news394 bc24539]: /fr/newsletters/2026/02/27/#bitcoin-core-24539
[news396 bc34692]: /fr/newsletters/2026/03/13/#bitcoin-core-34692
[news394 bc28792]: /fr/newsletters/2026/02/27/#bitcoin-core-28792
[news386 bc33657]: /fr/newsletters/2026/01/02/#bitcoin-core-33657
