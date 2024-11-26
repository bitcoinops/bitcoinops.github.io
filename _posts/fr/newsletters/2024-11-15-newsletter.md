---
title: 'Bulletin Hebdomadaire Bitcoin Optech #329'
permalink: /fr/newsletters/2024/11/15/
name: 2024-11-15-newsletter-fr
slug: 2024-11-15-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume un nouveau protocole de résolution de paiement offchain et
inclut des liens vers des articles sur le potentiel de suivi et de censure des paiements LN au
niveau de la couche IP. Sont également inclus les annonces de nouvelles mises à jour et versions candidates
(incluant des mises à jour critiques de sécurité pour BTCPay Server) et des descriptions de changements
apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Protocole de résolution de paiement offchain basé sur MAD (OPR) :** John Law a [publié][law
  opr] sur Delving Bitcoin la description d'un protocole de micropaiement qui exige que les deux
  participants contribuent à une caution qui peut être effectivement détruite à tout moment par l'un
  ou l'autre des participants. Cela crée une incitation pour les deux parties à s'apaiser mutuellement
  ou à risquer la destruction mutuellement assurée (MAD) des fonds cautionnés.

  Cela diffère de l'idéal d'un _protocole sans confiance_ où seul le parti en faute perd des fonds en
  cas de violation du protocole. Cependant, en pratique, les protocoles sans confiance déployés comme
  LN exigent souvent que la partie conforme paie des frais de transaction onchain pour récupérer ses
  fonds d'une violation. Law utilise ce fait pour argumenter certains des avantages d'un protocole
  basé sur MAD :

  - En cas de destruction de fonds, il utilise beaucoup moins d'espace sur la blockchain que
    l'exécution de contrat sans confiance, améliorant la scalabilité.

  - Étant basé sur l'apaisement des contreparties plutôt que sur un consensus global, le protocole
    basé sur MAD peut imposer des expirations aussi courtes qu'une fraction de seconde plutôt qu'un
    minimum d'au moins plusieurs blocs. Law donne l'exemple d'une résolution de paiement garantie
    (succès ou échec) en moins de dix secondes comparé à LN qui nécessite actuellement jusqu'à deux
    semaines dans le pire des cas pour régler un paiement.

  - En cas de panne de communication prolongée entre deux contreparties, le protocole basé sur MAD ne
    nécessite pas que l'une ou l'autre des parties mette des données onchain (et les deux parties sont
    incitées à ne pas le faire, car elles perdraient leur part du dépôt de caution). Dans un protocole
    comme [LN-Penalty][topic ln-penalty], les [HTLCs][topic htlc] en attente dans un canal doivent être
    réglés onchain avant une date limite si la communication est interrompue.

  Law souligne que cela peut rendre l'OPR beaucoup plus efficace à l'intérieur d'une [usine de
  canaux][topic channel factories], [arbre de timeout][topic timeout trees], ou autre structure
  imbriquée qui idéalement garderait les portions imbriquées offchain.

  Matt Morehouse a [répondu][morehouse opr] que l'apaisement peut logiquement conduire à un vol lent.
  Par exemple, Mallory prétend que Bob a échoué dans une opération qui vaut 5% de la caution ; Bob
  n'est pas sûr d'avoir échoué, mais payer Mallory 5% est mieux que de perdre ses 50% de la caution,
  donc il acquiesce ; Mallory répète. Ce problème est aggravé par l'incapacité à prouver la faute dans
  les réseaux de communication typiques : si Mallory et Bob perdent le contact assez longtemps pour
  qu'une défaillance se produise, ils peuvent se blâmer mutuellement, résultant en MAD. Morehouse note
  également que l'OPR nécessite de réserver plus de fonds utilisateurs pour les dépôts de caution, ce qui peut
  dégrader l'UX---les utilisateurs sont déjà confus aujourd'hui à propos de la [BOLT2][] _réserve de
  canal_ qui les empêche de dépenser plus de 99% du solde du canal.

  La discussion était en cours au moment de la rédaction.

- **Articles sur la censure au niveau IP des paiements LN :** Charmaine Ndolo a [publié][ndolo
  censor] sur Delving Bitcoin des résumés de [deux][atv revelio] récents [articles][nt censor]
  concernant la réduction de la confidentialité des paiements LN et leur censure potentielle. Les
  articles notent que les métadonnées concernant les paquets TCP/IP contenant des messages du
  protocole LN, tels que le nombre de paquets et la quantité totale de données, rendent relativement
  facile de deviner quel type de charge utile ces messages contiennent (par exemple, un nouveau
  [HTLC][topic htlc]). Un attaquant qui contrôle un réseau utilisé par plusieurs nœuds peut être
  capable d'observer le message passant d'un nœud à l'autre. Si l'attaquant contrôle également l'un de
  ces nœuds LN, il apprendra certaines informations sur le message transmis (par exemple, le montant
  du paiement ou le fait qu'il s'agisse d'un [message onion][topic onion messages]). Cela peut être
  utilisé pour empêcher sélectivement certains paiements de réussir, ou même d'échouer
  rapidement---empêchant une nouvelle tentative immédiate et forçant potentiellement la fermeture des
  canaux sur la chaîne.

  Aucune réponse n'a été publiée à ce jour.

## Mises à jour et versions candidates

_Nouvelles versions et version  candidates pour les projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à jour vers les nouvelles versions ou d'aider à tester les versions candidates._

- [BTCPay Server 2.0.3][] et [1.13.7][btcpay server 1.13.7] sont des versions de maintenance qui
  incluent des corrections critiques de sécurité pour les utilisateurs de certains plugins et
  fonctionnalités. Veuillez consulter les notes de version liées pour plus de détails.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration de Bitcoin (BIPs)][bips
repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Inquisition Bitcoin][bitcoin
inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #30592][] supprime l'option de configuration `mempoolfullrbf` qui permettait aux
  utilisateurs de désactiver le [full RBF][topic rbf] et de revenir à l'opt-in RBF. Maintenant que le
  full RBF est largement adopté, il n'y a aucun avantage à le désactiver, donc l'option a été
  supprimée. Le full RBF a été récemment activé par défaut (voir le Bulletin [#315][news315 fullrbf]).

- [Bitcoin Core #30930][] ajoute une colonne de services pairs à la commande `netinfo` et une option
  de filtre `outonly` pour afficher uniquement les connexions sortantes. La nouvelle colonne de
  services de pairs liste les services pris en charge par chaque pair, y compris le full
  données blockchain (n), [filtres bloom][topic transaction bloom filtering] (b), [segwit][topic
  segwit] (w), [filtres compacts][topic compact block filters]
  (c), données blockchain limitées aux derniers 288 blocs (l), [protocole de transport p2p version
  2][topic v2 p2p transport] (2). Des mises à jour de textes d'aide sont également effectuées.

- [LDK #3283][] implémente [BIP353][] en ajoutant un support pour les paiements vers des
  instructions de paiement Bitcoin lisibles par l'homme basées sur DNS qui se résolvent en
  [offres][topic offers] [BOLT12][] comme spécifié dans [BLIP32][]. Une nouvelle méthode
  `pay_for_offer_from_human_readable_name` est ajoutée à `ChannelManager` pour permettre aux
  utilisateurs d'initier des paiements directement vers des HRNs. La PR introduit également un état de
  paiement `AwaitingOffer` pour gérer les résolutions en attente, et un nouveau paquet
  `lightning-dns-resolver` pour gérer les requêtes [BLIP32][]. Voir le Bulletin [#324][news324
  blip32] pour les travaux précédents sur ce sujet.

- [LND #7762][] met à jour plusieurs commandes RPC `lncli` pour répondre avec des messages d'état au
  lieu de renvoyer des réponses vides, afin d'indiquer plus clairement que la commande a été exécutée
  avec succès. Les commandes affectées incluent `wallet releaseoutput`, `wallet accounts import-pubkey`,
  `wallet labeltx`, `sendcustom`, `connect`, `disconnect`, `stop`, `deletepayments`,
  `abandonchannel`, `restorechanbackup`, et `verifychanbackup`.

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 15:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30592,30930,3283,7762" %}
[law opr]: https://delvingbitcoin.org/t/a-fast-scalable-protocol-for-resolving-lightning-payments/1233
[morehouse opr]: https://delvingbitcoin.org/t/a-fast-scalable-protocol-for-resolving-lightning-payments/1233/2
[ndolo censor]: https://delvingbitcoin.org/t/research-paper-on-ln-payment-censorship/1248
[atv revelio]: https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=10190502
[nt censor]: https://drops.dagstuhl.de/storage/00lipics/lipics-vol316-aft2024/LIPIcs.AFT.2024.12/LIPIcs.AFT.2024.12.pdf
[btcpay server 2.0.3]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.0.3
[btcpay server 1.13.7]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.13.7
[news315 fullrbf]: /fr/newsletters/2024/08/09/#bitcoin-core-30493
[news324 blip32]: /fr/newsletters/2024/10/11/#ldk-3179
