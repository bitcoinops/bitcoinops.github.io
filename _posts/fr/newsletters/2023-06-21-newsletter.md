---
title: 'Bulletin Hebdomadaire Bitcoin Optech #256'
permalink: /fr/newsletters/2023/06/21/
name: 2023-06-21-newsletter-fr
slug: 2023-06-21-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume une discussion sur l'extension des factures BOLT11 pour demander deux paiements.
Vous y trouverez également une autre contribution à notre série hebdomadaire limitée sur la politique de mempool, ainsi
que nos sections régulières décrivant les mises à jour des clients et des services, les nouvelles versions et les
versions candidates, ainsi que les changements apportés aux principaux logiciels d'infrastructure Bitcoin.


## Nouvelles

- **Proposition d'extension des factures BOLT11 pour demander deux paiements :** Thomas Voegtlin a [posté][v 2p] sur la
  liste de diffusion de Lightning-Dev pour suggérer que les factures [BOLT11][] soient étendues pour permettre optionnellement
  à un destinataire de demander deux paiements séparés à un utilisateur, avec chaque paiement ayant un secret et un montant
  séparés. Voegtlin explique comment cela pourrait être utile à la fois pour les [submarine swaps][topic submarine swaps] et
  les [canaux JIT][topic jit channels] :

  - *Les swaps sous-marins*, où le paiement d'une facture LN offchain permet de recevoir des fonds onchain (les swaps
    sous-marins peuvent également fonctionner dans l'autre sens, de onchain à offchain, mais cela n'est pas discuté ici).
    Le bénéficiaire onchain choisit un secret et le payeur offchain paie un [HTLC][topic htlc] au hash de ce secret, qui
    est acheminé par LN à un fournisseur de services d'échange sous-marin. Le fournisseur de services reçoit un HTLC offchain
    pour ce secret et crée une transaction onchain en payant ce HTLC. Lorsque l'utilisateur est convaincu que la transaction
    onchain est sécurisée, il divulgue le secret pour régler le HTLC onchain, ce qui permet au prestataire de services de
    régler le HTLC offchain (et tous les paiements transmis sur le LN qui dépendent également du même secret).

    Toutefois, si le destinataire ne divulgue pas son secret, le prestataire de services ne recevra aucune compensation
    et devra dépenser la sortie onchain qu'il vient de créer, ce qui implique des coûts pour aucun gain. Pour éviter cet
    abus, les services d'échange sous-marin existants exigent que le créditeur paie une redevance en utilisant le LN avant
    que le service ne crée une transaction onchain (le service peut éventuellement rembourser une partie ou la
    totalité de cette redevance si la HTLC onchain est réglée). Les frais initiaux et l'échange sous-marin portent
    sur des montants différents et doivent être réglés à des moments différents, de sorte qu'ils doivent utiliser des
    secrets différents. Une facture BOLT11 actuelle ne peut contenir qu'un seul engagement pour un secret et un seul
    montant, de sorte que tout portefeuille effectuant des échanges sous-marins doit être programmé pour gérer
    l'interaction avec le serveur ou nécessite que l'expéditeur et le destinataire complètent un flux de travail
    en plusieurs étapes.

  - *Les canaux JIT (Just-in-Time)*, où un utilisateur sans canaux (ou sans liquidité) crée un canal virtuel avec un
    fournisseur de services ; lorsque le premier paiement de ce canal virtuel arrive, le fournisseur de services crée
    une transaction onchain qui finance le canal et contient ce paiement. Comme pour tout HTLC LN, le paiement offchain
    est effectué selon un secret que seul le destinataire (l'utilisateur) connaît. Si l'utilisateur est convaincu que
    la transaction de financement du canal JIT est sécurisée, il divulgue le secret pour réclamer le paiement.

    Cependant, si l'utilisateur ne divulgue pas son secret, le fournisseur de services ne recevra aucune compensation
    et pourrait avoir des coûts onchain sans le moindre gain. Thomas Voegtlin pense que les fournisseurs de services de canaux JIT
    existants évitent ce problème en demandant à l'utilisateur de divulguer son secret avant que la transaction de
    financement ne soit sécurisée, ce qui, selon lui, peut créer des problèmes juridiques et empêcher les portefeuilles
    non hébergés d'offrir un service similaire.

  Il suggère qu'autoriser une facture BOLT11 à contenir deux engagements distincts en matière de secrets,
  chacun pour un montant différent, permettra d'utiliser un secret et un montant pour une commission initiale destinée à
  payer les coûts de transaction onchain et l'autre secret et montant pour le swap sous-marin ou le financement du
  canal JIT proprement dit. La proposition a reçu plusieurs commentaires, nous en résumons quelques-uns :

  - *Une logique dédiée est nécessaire pour les échanges sous-marins :* Olaoluwa Osuntokun [note][o 2p] que le destinataire
    d'un swap sous-marin doit créer un secret, le distribuer, puis effectuer un paiement onchain. Le moyen le plus économique
    de régler ce paiement est d'interagir avec le fournisseur de services d'échange. Si l'émetteur et le récepteur interagissent
    de toute façon avec le fournisseur de services, comme c'est souvent le cas dans certaines implémentations existantes où
    l'émetteur et le récepteur sont la même entité, ils n'ont pas besoin de communiquer des informations supplémentaires à
    l'aide d'une facture. Voegtlin [a répondu][v 2p2] qu'un logiciel dédié peut gérer l'interaction, éliminant le besoin
    d'une logique supplémentaire dans le portefeuille offchain qui paie les fonds et le portefeuille onchain qui reçoit les
    fonds---mais cela n'est possible que si le portefeuille LN peut payer deux secrets et montants distincts dans la même facture.

  - *ossification de BOLT11 :* Matt Corallo [répond][c 2p] qu'il n'a pas encore été possible de faire en sorte que toutes les
    implémentations LN mettent à jour leur support BOLT11 pour supporter les factures qui ne contiennent pas de montant
    (pour permettre les [paiements spontanés][topic spontaneous payments]), donc il ne pense pas que l'ajout d'un champ
    supplémentaire soit une approche pratique pour le moment. Bastien Teinturier fait un [commentaire similaire][t 2p],
    suggérant d'ajouter un support aux [offres][topic offers] à la place. Voegtlin [n'est pas d'accord][v 2p3] et pense
    que l'ajout d'un soutien est pratique.

  - *Alternative au splice-out :* Corallo demande également pourquoi le protocole devrait être modifié pour supporter les
    submarine swaps si [splice outs][topic splicing] devient disponible. Cela n'a pas été mentionné dans le fil de discussion,
   les swaps sous-marins et les splice outs permettent tous deux de déplacer des fonds offchain vers une sortie
    onchain---mais les splice outs peuvent être plus efficaces onchain et ne sont pas vulnérables aux problèmes de frais non
    compensés. Voegtlin répond que les échanges sous-marins permettent à un utilisateur de LN d'augmenter sa capacité à
    recevoir de nouveaux paiements LN, ce qui n'est pas le cas du splicing.

  La discussion semblait être en cours au moment de la rédaction du présent document.

## En attente de confirmation #6 : Cohérence des politiques

Une [série][policy series] hebdomadaire limitée sur les relais de transaction, l'inclusion dans le mempool et la sélection des
transactions de minage, y compris pourquoi Bitcoin Core a une politique plus restrictive que celle permise par le consensus et
comment les portefeuilles peuvent utiliser cette politique de la manière la plus efficace possible.

{% include specials/policy/fr/06-consistence.md %}

## Modifications apportées aux services et aux logiciels clients

*Dans cette rubrique mensuelle, nous mettons en évidence les mises à jour
intéressantes des portefeuilles et services Bitcoin.*

- **Les bibliothèques Greenlight sont en source ouverte :**
  Le fournisseur de services de nœuds CLN non privatifs [Greenlight][news162 greenlight] a [annoncé][decker twitter] un
  [dépôt][github greenlight] de bibliothèques client et de liaisons linguistiques ainsi qu'un
  [guide du cadre de test][greenlight testing].

- **Débogueur pour Tapscript Tapsim :**
  [Tapsim][github tapsim] est un outil de débogage de l'exécution des scripts (voir [Bulletin #254][news254 tapsim]) et de
  visualisation pour [tapscript][topic tapscript] utilisant btcd.

- **Annonce de Bitcoin Keeper 1.0.4 :**
  [Bitcoin Keeper][] est un portefeuille mobile qui supporte le multisig, les supports de signature matériels, [BIP85][],
  et avec la dernière version, [coinjoin][topic coinjoin] qui utilise le [protocole Whirlpool][gitlab whirlpool].

- **Annonce du portefeuille lightning EttaWallet :**
  Le portefeuille mobile [EttaWallet][github ettawallet] a été récemment [annoncé][ettawallet blog] avec des fonctionnalités
  Lightning activées par LDK et une forte orientation vers la facilité d'utilisation inspirée par la conception de référence
  du [portefeuille de dépenses quotidiennes][bitcoin design guide] de la Bitcoin Design Community.

- **Annonce d'un PoC de synchronisation d'en-tête de bloc basé sur zkSNARK :**
  [BTC Warp][github btc warp] est une preuve de concept de synchronisation de client léger utilisant les zkSNARKs pour prouver
  et vérifier une chaîne d'en-têtes de blocs Bitcoin. Un [billet de blog][btc warp blog] fournit des détails sur les approches
  adoptées.

- **Lancement de lnprototest v0.0.4 :**
  Le projet [lnprototest][github lnprototest] est une suite de tests pour LN comprenant "un ensemble d'aides au test écrits
  en Python3, conçus pour faciliter l'écriture de nouveaux tests lorsque vous proposez des changements au protocole du réseau
  Lightning, ainsi que pour tester les implémentations existantes".

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets d’infrastructure
Bitcoin. Veuillez envisager de passer aux nouvelles versions ou d’aider à tester
les versions candidates.*

- [Eclair v0.9.0][] est une nouvelle version de cette implémentation du LN qui "contient beaucoup de travail préparatoire pour
  des fonctionnalités importantes (et complexes) : [dual-funding][topic dual funding], [splicing][topic splicing] et les
  [offres BOLT12][topic offers]". Ces fonctionnalités sont pour l'instant expérimentales. La version "rend les plugins plus
  puissants, introduit des mesures d'atténuation contre divers types de déni de service et améliore les performances dans de
  nombreux domaines du code de base".

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], et
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [LDK #2294][] ajoute la prise en charge de la réponse aux [messages en oignons][topic onion messages] et rapproche LDK de la
  prise en charge complète des [offres][topic offers].

- [LDK #2156][] ajoute la prise en charge des [paiements keyend][topic spontaneous payments] qui utilisent les
  [paiements simplifiés par trajets multiples][topic multipath payments]. LDK prenait auparavant en charge ces deux technologies,
  mais uniquement lorsqu'elles étaient utilisées séparément. Les paiements par trajets multiples doivent utiliser des
  [secrets de paiement][topic payment secrets] mais LDK rejetait auparavant les paiements par keyend avec des secrets de paiement.
  Des erreurs descriptives, une option de configuration et un avertissement sur la rétrogradation ont donc été ajoutés pour
  atténuer tout problème potentiel.

{% include references.md %}
{% include linkers/issues.md v=2 issues="2294,2156" %}
[policy series]: /fr/blog/waiting-for-confirmation/
[v 2p]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/003977.html
[o 2p]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/003978.html
[v 2p2]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/003979.html
[c 2p]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/003980.html
[t 2p]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/003982.html
[v 2p3]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/003981.html
[eclair v0.9.0]: https://github.com/ACINQ/eclair/releases/tag/v0.9.0
[news162 greenlight]: /en/newsletters/2021/08/18/#blockstream-announces-non-custodial-ln-cloud-service-greenlight
[decker twitter]: https://twitter.com/Snyke/status/1666096470884515840
[github greenlight]: https://github.com/Blockstream/greenlight
[greenlight testing]: https://blockstream.github.io/greenlight/tutorials/testing/
[github tapsim]: https://github.com/halseth/tapsim
[news254 tapsim]: /fr/newsletters/2023/06/07/#utilisation-de-matt-pour-repliquer-ctv-et-gerer-les-joinpools
[Bitcoin Keeper]: https://bitcoinkeeper.app/
[gitlab whirlpool]: https://code.samourai.io/whirlpool/whirlpool-protocol
[github ettawallet]: https://github.com/EttaWallet/EttaWallet
[ettawallet blog]: https://rukundo.mataroa.blog/blog/introducing-ettawallet/
[bitcoin design guide]: https://bitcoin.design/guide/daily-spending-wallet/
[github btc warp]: https://github.com/succinctlabs/btc-warp
[btc warp blog]: https://blog.succinct.xyz/blog/btc-warp
[github lnprototest]: https://github.com/rustyrussell/lnprototest
