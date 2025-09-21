---
title: 'Bulletin Hebdomadaire 
Bitcoin Optech #372'
permalink: /fr/newsletters/2025/09/19/
name: 2025-09-19-newsletter-fr
slug: 2025-09-19-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume une proposition visant à améliorer les surpaiements redondants
sur LN et renvoie à une discussion sur les attaques de partitionnement potentielles contre les nœuds
complets. Sont également incluses nos sections régulières résumant les changements récents apportés aux clients et services, les
annonces de nouvelles versions et de candidats à la publication, et les résumés des modifications
notables apportées aux logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

- **Surpaiements redondants financés par LSP :** le développeur ZmnSCPxj
  [a posté][zmnscpxj lspstuck] sur Delving Bitcoin une proposition permettant
  aux LSP (Lightning Service Providers) de fournir le financement (liquidité) supplémentaire requis
  pour les [surpaiements redondants][topic redundant overpayments]. Dans les
  propositions originales pour les surpaiements redondants, Alice paie Zed en
  envoyant plusieurs paiements par plusieurs itinéraires de manière à ce que seul
  Zed puisse réclamer l'un des paiements ; le reste des paiements est
  remboursé à Alice. L'avantage de cette approche est que les premières
  tentatives de paiement pour atteindre Zed peuvent réussir tandis que d'autres tentatives
  sont encore en cours dans le réseau, augmentant la vitesse des paiements
  sur LN.

  Les inconvénients de cette approche sont qu'Alice doit avoir un capital
  supplémentaire (liquidité) pour effectuer les paiements redondants, Alice doit rester en ligne
  jusqu'à ce que le surpaiement redondant soit complet, et tout paiement qui devient
  bloqué empêche Alice de pouvoir dépenser cet argent jusqu'à ce que la
  tentative de paiement expire (jusqu'à deux semaines avec les paramètres
  couramment utilisés).

  La proposition de ZmnSCPxj permet à Alice de payer uniquement le montant réel du
  paiement (plus les frais) et ses fournisseurs de services Lightning (LSP) fournissent la
  liquidité pour envoyer les paiements redondants, offrant l'avantage de vitesse des surpaiements
  redondants sans exiger qu'elle ait
  une liquidité supplémentaire, que ce soit brièvement ou jusqu'à l'expiration. Les LSP peuvent
  également finaliser le paiement alors qu'Alice est hors ligne, donc le paiement
  peut être complété même si Alice a une mauvaise connectivité.

  Les inconvénients de la nouvelle proposition sont qu'Alice perd une partie de sa vie privée
  vis-à-vis de ses LSP et que la proposition nécessite plusieurs changements dans le protocole LN
  en plus du support pour les surpaiements redondants.

- **Attaques de partitionnement et d'éclipse utilisant l'interception BGP :** le développeur
  cedarctic [a posté][cedarctic bgp] sur Delving Bitcoin à propos de l'utilisation des failles
  dans le protocole Border Gateway Protocol (BGP) pour empêcher les nœuds complets de pouvoir
  se connecter à des pairs, ce qui peut être utilisé pour partitionner le réseau
  ou exécuter des [attaques d'éclipse][topic eclipse attacks]. Plusieurs
  atténuations ont été décrites par cedarctic, avec d'autres développeurs dans la
  discussion décrivant d'autres atténuations et des moyens de surveiller l'utilisation
  de l'attaque.

## Changements dans les services et logiciels clients

*Dans cette rubrique mensuelle, nous mettons en lumière des mises à jour intéressantes des
portefeuilles et services Bitcoin.*

- **Outil de preuve de réserve à connaissance nulle :**
  [Zkpoor][zkpoor github] génère une [preuve de réserves][topic proof of reserves]
  utilisant des preuves STARK sans révéler les adresses ou UTXOs du propriétaire.

- **Preuve de concept d'un protocole alternatif de swap sous-marin :**
  Le protocole en preuve de concept [Papa Swap][papa swap github] atteint la fonctionnalité de
  [swap sous-marin][topic submarine swaps] en n'exigeant qu'une transaction au lieu de deux.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates._

- [Bitcoin Core 30.0rc1][] est un candidat à la version pour la prochaine version majeure de ce
  logiciel de nœud de vérification complète.

- [BDK Chain 0.23.2][] est une version de cette bibliothèque pour la construction d'applications de
  portefeuille qui introduit des améliorations dans la gestion des conflits de transactions, redessine
  l'API `FilterIter` pour améliorer les capacités de filtrage [BIP158][], et améliore la gestion des
  ancres et des réorganisations de blocs.

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core
lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust
Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Propositions
d'Amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips
repo], [Inquisition Bitcoin][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #33268][] change la manière dont les transactions sont reconnues comme faisant
  partie du portefeuille d'un utilisateur en supprimant l'exigence que le montant total des entrées
  d'une transaction dépasse zéro sats. Tant qu'une transaction dépense au moins une sortie d'un
  portefeuille, elle sera reconnue comme faisant partie de ce portefeuille. Cela permet aux
  transactions avec des entrées de valeur nulle, telles que dépenser une [ancre éphémère P2A][topic
  ephemeral anchors], d'apparaître dans la liste des transactions d'un utilisateur.

- [Eclair #3157][] met à jour la manière dont il signe et diffuse les transactions d'engagement à
  distance lors d'une reconnexion. Au lieu de renvoyer l'engagement précédemment signé, il signe à
  nouveau avec les derniers nonces de `channel_reestablish`. Les pairs qui n'utilisent pas de nonces
  déterministes dans les [canaux taproot simples][topic simple taproot channels] auront un nouveau nonce
  lors de la reconnexion, rendant la signature d'engagement précédente invalide.

- [LND #9975][] ajoute le support de l'adresse on-chain de secours [P2TR][topic taproot] aux
  factures [BOLT11][], suivant le vecteur de test ajouté dans [BOLTs #1276][]. Les factures BOLT11 ont
  un champ optionnel `f` qui permet aux utilisateurs d'inclure une adresse on-chain de secours au cas
  où un paiement ne pourrait pas être complété sur le LN.

- [LND #9677][] ajoute les champs `ConfirmationsUntilActive` et `ConfirmationHeight` au message de
  réponse `PendingChannel` retourné par la commande RPC `PendingChannels`. Ces champs informent les
  utilisateurs du nombre de confirmations requises pour l'activation du canal et de la hauteur de bloc
  à laquelle la transaction de financement a été confirmée.

- [LDK #4045][] implémente la réception d'un [paiement asynchrone][topic async payments] par un nœud
  LSP en acceptant un [HTLC][topic htlc] entrant au nom d'un destinataire souvent hors ligne, en le
  retenant, et en le libérant au destinataire plus tard lorsqu'il est signalé. Cette PR introduit une
  fonctionnalité expérimentale `HtlcHold`, ajoute un nouveau drapeau `hold_htlc` sur `UpdateAddHtlc`,
  et définit le chemin de libération.

- [LDK #4049][] implémente la transmission des demandes de facture [BOLT12][topic offers] d'un nœud
  LSP à un destinataire en ligne, qui répond ensuite avec une nouvelle facture. Si le destinataire est
  hors ligne, le nœud LSP peut répondre avec une facture de secours, comme permis par l'implémentation
  de la logique côté serveur pour les [paiements asynchrones][topic async payments] (voir le Bulletin
  [#363][news363 async]).

- [BDK #1582][] refactorise les types `CheckPoint`, `LocalChain`, `ChangeSet`, et `spk_client` pour
  être génériques et prendre un payload `T` au lieu d'être fixés aux hashes de blocs. Cela prépare
  `bdk_electrum` à stocker les entêtes de blocs complets dans les points de contrôle, ce qui évite les
  téléchargements répétés d'entêtes et permet les preuves de Merkle mises en cache et le Median Time
  Past (MTP).

- [BDK #2000][] ajoute la gestion des réorganisations de blocs à une structure `FilterIter`
  refactorisée (voir le Bulletin [#339][news339 filters]). Plutôt que de diviser son flux à travers
  plusieurs méthodes, ce PR lie tout à la fonction `next()`, évitant ainsi les risques de timing. Un
  point de contrôle est émis à chaque hauteur de bloc pour s'assurer que le bloc n'est pas obsolète et
  que BDK est sur la chaîne valide. `FilterIter` scanne tous les blocs et récupère ceux contenant des
  transactions pertinentes à une liste de script pubkeys, en utilisant [les filtres de blocs
  compacts][topic compact block filters] comme spécifié dans [BIP158][].

- [BDK #2028][] ajoute un champ de timestamp `last_evicted` à la structure `TxNode` pour indiquer
  quand une transaction a été exclue du mempool après avoir été remplacée par [RBF][topic rbf]. Ce PR
  supprime également la méthode `TxGraph::get_last_evicted` (Voir le Bulletin [#346][news346 evicted])
  car le nouveau champ la remplace.

{% include snippets/recap-ad.md when="2025-09-23 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33268,3157,9975,1276,9677,4045,4049,1582,2000,2028" %}
[bitcoin core 30.0rc1]: https://bitcoincore.org/bin/bitcoin-core-30.0/
[zkpoor github]: https://github.com/AbdelStark/zkpoor
[papa swap github]: https://github.com/supertestnet/papa-swap
[news363 async]: /fr/newsletters/2025/07/18/#ldk-3628
[news339 filters]: /fr/newsletters/2025/01/31/#bdk-1614
[news346 evicted]: /fr/newsletters/2025/03/21/#bdk-1839
[BDK Chain 0.23.2]: https://github.com/bitcoindevkit/bdk/releases/tag/chain-0.23.2
[zmnscpxj lspstuck]: https://delvingbitcoin.org/t/multichannel-and-multiptlc-towards-a-global-high-availability-cp-database-for-bitcoin-payments/1983/
[cedarctic bgp]: https://delvingbitcoin.org/t/eclipsing-bitcoin-nodes-with-bgp-interception-attacks/1965/
