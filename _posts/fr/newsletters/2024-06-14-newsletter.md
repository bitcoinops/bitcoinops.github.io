---
title: 'Bulletin Hebdomadaire Bitcoin Optech #307'
permalink: /fr/newsletters/2024/06/14/
name: 2024-06-14-newsletter-fr
slug: 2024-06-14-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine annonce une proposition de BIP pour un format d'adresse Bitcoin résistant
aux quantiques et sont
également incluses nos sections habituelles avec le résumé d'une réunion du Bitcoin Core PR Review Club,
des annonces de mises à jour et versions candidates, ainsi que les changements
apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **proposition de BIP pour un format d'adresse résistant aux quantiques :** le développeur Hunter Beast
  a [publié][beast post] à la fois sur Delving Bitcoin et sur la liste de diffusion une [propositon de
  BIP][quantum draft] pour attribuer des adresses segwit version 3 à un algorithme de
  signature [résistant aux quantiques][topic quantum resistance]. La proposition de BIP décrit le problème
  et renvoie à plusieurs algorithmes potentiels ainsi qu'à leur taille prévue sur la chaîne. Le choix
  des algorithmes et les détails spécifiques de mise en œuvre sont laissés à de futures discussions,
  tout comme les BIP supplémentaires nécessaires pour ajouter une
  résistance complète aux quantiques à Bitcoin.

## Bitcoin Core PR Review Club

*Dans cette section mensuelle, nous résumons une récente réunion du
[Bitcoin Core PR Review Club][] en soulignant certaines des questions
et réponses importantes. Cliquez sur une question ci-dessous pour voir
un résumé de la réponse de la réunion.*

[Ne pas effacer à nouveau les index lors de la continuation d'un réindex précédent][review club
30132] est un PR de [TheCharlatan][gh thecharlatan] qui peut améliorer le temps de démarrage lorsque
l'utilisateur redémarre son nœud avant qu'un réindex en cours ne soit terminé.

Bitcoin Core implémente cinq index. L'ensemble UTXO et l'index des blocs sont requis, tandis que
l'index des transactions, l'index de [filtre de bloc compact][topic compact block filters] et
l'index des statistiques des pièces sont optionnels. Lors de l'exécution avec `-reindex`, tous les
index sont effacés et reconstruits. Ce processus peut prendre un certain temps, et il n'est pas
garanti qu'il se termine avant que le nœud ne soit arrêté pour une raison quelconque.

Étant donné que le nœud a besoin d'un ensemble UTXO et d'un index des blocs à jour, le statut de
réindexation est conservé sur le disque. Lorsqu'un réindex est commencé, un drapeau est
[défini][reindex flag set], et il ne sera désactivé que lorsque le réindex sera terminé. De cette
façon, lorsque le nœud démarre, il peut détecter qu'il doit continuer le réindex, même si
l'utilisateur n'a pas fourni le drapeau comme option de démarrage.

Lors du redémarrage (sans `-reindex`) après un réindex inachevé, les index requis sont préservés et
continueront d'être reconstruits. Avant [Bitcoin Core #30132][], les index optionnels seraient
effacés une seconde fois. [Bitcoin Core #30132][] peut rendre le démarrage du nœud plus efficace en
évitant l'effacement des index optionnels lorsque cela n'est pas nécessaire.

{% include functions/details-list.md
  q0="Quel est le changement de comportement introduit par ce PR ?"
  a0="Le comportement est modifié de trois manières. Premièrement, conformément à l'objectif de ce PR,
  les index optionnels ne sont plus effacés à nouveau lorsque le nœud est redémarré avant que le
  réindexage soit terminé. Cela aligne le comportement d'effacement des index optionnels avec celui
  des index requis. Deuxièmement, lorsqu'un utilisateur demande un réindex via l'interface graphique,
  cette demande n'est plus ignorée, inversant ainsi un bug subtil introduit dans [b47bd95][gh
  b47bd95]. Troisièmement, la ligne dans le log \"Initializing databases...\\n\" est retirée."
  a0link="https://bitcoincore.reviews/30132#l-19"

  q1="Quelles sont les deux façons dont un index optionnel peut traiter les nouveaux blocs ?"
  a1="Lorsqu'un index optionnel est initialisé, il vérifie si son bloc le plus élevé
  est le même que le chaintip courant. Si ce n'est pas le cas, il traitera d'abord tous
  les blocs manquants avec une synchronisation en arrière-plan, via `BaseIndex::StartBackgroundSync()`.
  Lorsque l'index rattrape le chaintip, il traite tous les autres blocs à travers l'interface
  de validation en utilisant `ValidationSignals::BlockConnected`."
  a1link="https://bitcoincore.reviews/30132#l-52"

  q2="Comment cette PR affecte-t-elle la logique des index optionnels qui traitent les nouveaux blocs ?"
  a2="Avant cette PR, l'effacement des index optionnels sans effacer l'état de la chaîne
  signifie que ces index seront considérés comme désynchronisés. Comme indiqué dans la question
  précédente, cela signifie qu'ils effectueront d'abord une synchronisation en arrière-plan avant
  de passer à l'interface de validation. Avec cette PR, les index optionnels restent synchronisés
  avec l'état de la chaîne, et donc aucune synchronisation en arrière-plan n'est nécessaire.
  Remarque : la synchronisation en arrière-plan ne commence qu'une fois la réindexation terminée,
  alors que le traitement des événements de validation se fait en parallèle."
  a2link="https://bitcoincore.reviews/30132#l-70"
%}

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets
d'infrastructure Bitcoin. Veuillez envisager de passer aux nouvelles
versions ou d'aider à tester les versions candidates.*

- [Core Lightning 24.05][] est une version de la prochaine version majeure de cette implémentation
  populaire de nœud LN. Elle comprend des améliorations qui lui permettent de mieux fonctionner avec
  un nœud complet élagué (voir le [Bulletin #300][news300 cln prune]), permet à la RPC `check` de
  fonctionner avec des plugins (voir le [Bulletin #302][news302 cln check]), des améliorations de
  stabilité (telles que celles décrites dans les Bulletins [#303][news303 cln chainlag] et
  [#304][news304 cln feemultiplier]), permet une livraison plus robuste des factures [d'offre][topic
  offers] (voir le [Bulletin #304][news304 cln offers]), et un correctif pour un problème de
  surpaiement de frais lorsque l'option de configuration `ignore_fee_limits` est utilisée (voir
  le [Bulletin #306][news306 cln overpay]).

- [Bitcoin Core 27.1][] est une version de maintenance de l'implémentation de nœud complet
  prédominante. Elle contient de multiples corrections de bugs.

### Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core
lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust
Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo], [Propositions
d'Amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips
repo], [Inquisition Bitcoin][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #29496][] augmente `TX_MAX_STANDARD_VERSION` à 3, ce qui rend les transactions
  topologiquement restreintes jusqu'à confirmation ([TRUC][topic v3 transaction relay]) standard. Si la
  version d'une transaction est 3, elle sera traitée comme une transaction TRUC comme défini dans la
  spécification [BIP431][]. La `CURRENT_VERSION` reste à 2, ce qui signifie que le portefeuille ne
  créera pas encore de transactions TRUC.

- [Bitcoin Core #28307][] corrige un bug qui imposait la limite de taille maximale de script de 520
  octets P2SH aux scripts de rachat SegWit pour les P2SH-segwit et bech32. Cette correction permet la
  création de [descripteurs de sortie][topic descriptors] multisig impliquant plus de 15 clés
  (permettant maintenant jusqu'à la limite de consensus `OP_CHECKMULTISIG` de 20), y compris la
  signature pour ces scripts, ainsi que d'autres scripts de rachat post-segwit qui dépassent la limite
  P2SH.

- [Bitcoin Core #30047][] refactorise le modèle du schéma d'encodage [bech32][topic bech32]
  `charlimit` d'une constante de 90 à un `Enum`. Ce changement facilite le support de nouveaux types
  d'adresses utilisant le schéma d'encodage bech32 mais n'ayant pas la même limite de caractères que
  [BIP173][] qui a été conçu pour. Par exemple, pour activer l'analyse des adresses de [paiement
  silencieux][topic silent payments], qui nécessitent jusqu'à 118 caractères.

- [Bitcoin Core #28979][] met à jour la documentation de la commande RPC `sendall` (voir le [Bulletin
  #194][news194 sendall]) pour mentionner qu'elle dépense des changements non confirmés en plus des
  sorties confirmées. Si des sorties non confirmées sont dépensées, cela compensera tout _déficit de
  frais_ (voir le [Bulletin #269][news269 deficit]). _Cet élément a été corrigé après
  publication._[^correction-28979]

- [Eclair #2854][] et [LDK #3083][] implémentent [BOLTs #1163][] pour supprimer l'exigence d'une
  `channel_update` lors d'un échec de livraison d'un [message en onion][topic onion messages]. Cette
  exigence facilitait une attaque où un nœud relais générant le statut d'erreur d'échec de livraison
  pouvait identifier l'expéditeur du [HTLC][topic htlc] à travers le champ `channel_update`,
  compromettant ainsi la confidentialité de l'expéditeur.

- [LND #8491][] ajoute un drapeau `cltv_expiry` sur les commandes RPC `lncli` `addinvoice` et
  `addholdinvoice` pour permettre aux utilisateurs de définir le `min_final_cltv_expiry_delta` (le
  [délai d'expiration CLTV][topic cltv expiry delta] pour le dernier saut). Aucune motivation pour le
  changement n'est décrite dans la PR, mais cela pourrait être en réponse à LND
  augmentant récemment son pqrqmètre par défaut de 9 blocs à 18 blocs pour suivre la spécification [BOLT2][] (voir
  le [Bulletin #284][news284 lnd final delta]).

- [LDK #3080][] refactorise la commande `create_blinded_path` de `MessagerRouter` en deux méthodes :
  une pour la création de [chemin aveugle][topic rv routing] compact, et une pour les chemins aveugles
  normaux. Cela permet une optionnalité en fonction du contexte de l'appelant. Les chemins aveugles
  compacts utilisent des identifiants de canaux courts (SCID) qui font référence à une opération de
  financement (ou à un alias de canal) et sont généralement composés de 8 octets ; les chemins aveuglés
  normaux référencent un nœud LN par sa clé publique de 33 octets. Les chemins compacts peuvent
  devenir obsolètes si un canal est fermé ou [splicé][topic splicing], ils sont donc mieux utilisés
  pour les codes QR à court terme ou les liens de paiement où l'espace en octets est précieux. Les
  chemins normaux sont préférables pour les utilisations à long terme, y compris les [messages
  en oignon][topic onion messages] basés sur les [offres][topic offers] où l'utilisation des identifiants de nœud
  peut permettre de transmettre un message à un pair même si le nœud et le pair ne partagent plus de
  canal (puisque les messages en oignon ne nécessitent pas de canaux).
  `ChannelManager` est mis à jour pour utiliser des chemins aveugles compacts pour les [offres][topic
  offers] et remboursements de courte durée, tandis que les chemins de réponse sont refactorisés pour
  utiliser des chemins aveugles normaux (non compacts).

- [BIPs #1551][] ajoute [BIP353][] avec une spécification pour les Instructions de Paiement DNS, un
  protocole pour encoder les URI [BIP21][] dans les enregistrements TXT DNS, pour la lisibilité
  humaine et pour fournir la capacité de requêter de telles résolutions de manière privée. Par
  exemple, `example@example.com` pourrait résoudre à une adresse DNS telle que
  `example.user._bitcoin-payment.example.com`, qui retournera un enregistrement TXT signé DNSSEC
  contenant une URI BIP21 comme `bitcoin:bc1qexampleaddress0123456`. Voir le [Bulletin #290][news290
  bip353] pour notre description précédente et [le bulletin de la semaine dernière][news306 dns]
  pour la fusion d'un BLIP connexe.

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30"
%}
{% include snippets/recap-ad.md when=four_days_after_posting %}

## Notes de bas de page

[^correction-28979]:
Notre description originale de Bitcoin Core #28979 publiée affirmait que `sendall` dépensant un
changement non confirmé était un changement de comportement. Nous remercions Gustavo Flores pour sa
description correcte originale (l'erreur ayant été introduite par l'éditeur du bulletin) et
Mark "Murch" Erhardt pour avoir signalé l'erreur.

{% include references.md %}
{% include linkers/issues.md v=2 issues="29496,28307,30047,28979,2854,3083,1163,8491,3080,3072,1551,30132" %}
[beast post]: https://delvingbitcoin.org/t/proposing-a-p2qrh-bip-towards-a-quantum-resistant-soft-fork/956
[quantum draft]: https://github.com/cryptoquick/bips/blob/p2qrh/bip-p2qrh.mediawiki
[core lightning 24.05]: https://github.com/ElementsProject/lightning/releases/tag/v24.05
[Bitcoin Core 27.1]: https://bitcoincore.org/bin/bitcoin-core-27.1/
[news306 cln overpay]: /fr/newsletters/2024/06/07/#core-lightning-7252
[news304 cln feemultiplier]: /fr/newsletters/2024/05/24/#core-lightning-7063
[news304 cln offers]: /fr/newsletters/2024/05/24/#core-lightning-7304
[news303 cln chainlag]: /fr/newsletters/2024/05/17/#core-lightning-7190
[news302 cln check]: /fr/newsletters/2024/05/15/#core-lightning-7111
[news300 cln prune]: /fr/newsletters/2024/05/01/#core-lightning-7240
[review club 30132]: https://bitcoincore.reviews/30132
[gh thecharlatan]: https://github.com/TheCharlatan
[gh b47bd95]: https://github.com/bitcoin/bitcoin/commit/b47bd959207e82555f07e028cc2246943d32d4c3
[reindex flag set]: https://github.com/bitcoin/bitcoin/blob/457e1846d2bf6ef9d54b9ba1a330ba8bbff13091/src/node/blockstorage.cpp#L58
[news198 sendall]: /en/newsletters/2022/04/06/#bitcoin-core-24118
[news290 bip353]: /fr/newsletters/2024/02/21/#instructions-de-paiement-bitcoin-lisibles-par-l-homme-basees-sur-dns
[news194 sendall]: /en/newsletters/2022/04/06/#bitcoin-core-24118
[news269 deficit]: /fr/newsletters/2023/09/20/#bitcoin-core-26152
[news284 lnd final delta]: /fr/newsletters/2024/01/10/#lnd-8308
[news306 dns]: /fr/newsletters/2024/06/07/#blips-32
