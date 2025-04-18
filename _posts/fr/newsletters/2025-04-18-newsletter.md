---
title: 'Bulletin Hebdomadaire Bitcoin Optech #350'
permalink: /fr/newsletters/2025/04/18/
name: 2025-04-18-newsletter
slug: 2025-04-18-newsletter
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine inclut nos sections régulières décrivant les récents
changements apportés aux services et aux logiciels clients, les annonces de mises à jour
et des versions candidates, ainsi que les descriptions des changements notables apportés
aux logiciels d'infrastructure Bitcoin populaires. Un correctif concernant certains
détails de notre histoire de la semaine dernière à propos de SwiftSync est également inclus.

## Nouvelles

*Aucune nouvelle significative cette semaine n'a été trouvée dans aucune de nos [sources][].*

## Changements dans les services et les logiciels clients

*Dans cette rubrique mensuelle, nous mettons en lumière des mises à jour intéressantes des
portefeuilles Bitcoin et des services.*

- **Version 28.1.knots20250305 de Bitcoin Knots publiée :**
  Cette version de Bitcoin Knots [release][knots 28.1] inclut le support pour [signer
  des messages][topic generic signmessage] pour une adresse segwit ou taproot ainsi
  que la vérification des messages signés [BIP137][], [BIP322][], et Electrum, parmi d'autres
  changements.

- **Explorateur PSBTv2 annoncé :**
  [L'explorateur Bitcoin PSBTv2][bip370 website] inspecte les [PSBTs][topic psbt] encodés
  en utilisant le format de données version 2.

- **LNbits v1.0.0 publié :**
  Le logiciel [LNbits][lnbits github] fournit la comptabilité et des fonctionnalités supplémentaires
  sur une variété de portefeuilles sous-jacents du Lightning Network.

- **Le projet Open Source Mempool® v3.2.0 publié :**
  La [version v3.2.0][mempool 3.2.0] ajoute le support pour les [transactions v3][topic
  v3 transaction relay], les sorties d'ancrage, la diffusion de [paquets 1P1C][topic
  package relay], la visualisation des jobs de pool de minage Stratum, et d'autres fonctionnalités.

- **Bibliothèque MPC de Coinbase publiée :**
  Le projet [Coinbase MPC][coinbase mpc blog] est une [bibliothèque C++][coinbase mpc
  github] pour sécuriser les clés utilisées dans les schémas de calcul multipartite (MPC), incluant
  une implémentation personnalisée de secp256k1.

- **Outil de liquidité pour le Lightning Network publié :**
  [Hydrus][hydrus github] utilise l'état du réseau LN, incluant les performances passées,
  pour ouvrir et fermer automatiquement des canaux Lightning pour LND. Il
  supporte également le [regroupement][topic payment batching].

- **Service de Stockage Versionné annoncé :**
  Le cadre [Versioned Storage Service (VSS)][vss blog] est une solution de stockage cloud open-source
  pour les données d'état de portefeuille Lightning et Bitcoin, se concentrant sur
  les portefeuilles non-custodial.

- **Outil de fuzz testing pour les nœuds Bitcoin :**
  [Fuzzamoto][fuzzamoto github] est un cadre utilisant le fuzz testing pour trouver
  des bugs dans différentes implémentations du protocole Bitcoin à travers des
  interfaces externes comme P2P et RPC.

- **Composants du Bitcoin Control Board open-sourcés :**
  Braiins [a annoncé][braiins tweet] la disponibilité en open-source de certains des
  composants matériels et logiciels de leur BCB100 de contrôle de minage.

## Mises à jour et versions candidates

_Nouvelles versions et candidats à la version finale pour les projets d'infrastructure Bitcoin
populaires. Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester
les candidats à la version finale._

- [Bitcoin Core 29.0][] est la dernière version majeure du nœud complet prédominant du réseau. Ses
  [notes de version][bcc rn] décrivent plusieurs améliorations significatives : le remplacement de la
  fonctionnalité UPnP par défaut désactivée (responsable en partie de plusieurs vulnérabilités de
  sécurité passées) par une option NAT-PMP (également désactivée par défaut), l'amélioration de la
  récupération des parents de transactions orphelines qui peut augmenter la fiabilité du support
  actuel de [relais de paquets][topic package relay] de Bitcoin Core, un peu plus d'espace dans les
  modèles de blocs par défaut (potentiellement améliorant les revenus des mineurs), des améliorations
  pour éviter les [timewarps][topic time warp] accidentels pour les mineurs qui pourraient
  accidentellement entraîner une perte de revenus si les timewarps sont interdits dans un [soft fork
  futur][topic consensus cleanup], et une migration du système de construction d'autotools à cmake.

- [LND 0.19.0-beta.rc2][] est un candidat à la version pour ce nœud LN populaire. L'une des
  principales améliorations qui pourrait probablement nécessiter des tests est le nouveau bumping de
  frais basé sur RBF pour les fermetures coopératives.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration de Bitcoin (BIPs)][bips
repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Inquisition Bitcoin][bitcoin
inquisition repo], et [BINANAs][binana repo]._

- [LDK #3593][] permet aux utilisateurs de fournir une preuve de paiement [BOLT12][topic offers] en
  incluant la facture BOLT12 dans l'événement `PaymentSent` lors de la complétion du paiement. Cela
  est accompli en ajoutant le champ `bolt12` à l'énumération `PendingOutboundPayment::Retryable`, qui
  peut ensuite être attaché à l'événement `PaymentSent`.

- [BOLTs #1242][] rend le [secret de paiement][topic payment secrets] obligatoire pour les paiements
  de factures [BOLT11][] en exigeant des lecteurs (payeurs) d'échouer un paiement si le champ `s`
  (secret de paiement) est absent. Auparavant, la spécification le rendait obligatoire uniquement pour
  les émetteurs (receveurs), et les lecteurs pouvaient ignorer les champs `s` avec des longueurs
  incorrectes (voir le Bulletin [#163][news163 secret]). Cette PR met également à jour la
  fonctionnalité de secret de paiement au statut `ASSUMED` dans [BOLT9][].

## Correction

Le bulletin de la semaine dernière à propos de l'[histoire][news349 ss] sur SwiftSync contenait plusieurs
erreurs et déclarations confuses.

- *Aucun accumulateur cryptographique utilisé :* nous avons décrit SwiftSync comme utilisant un
  accumulateur cryptographique, ce qui est incorrect. Un accumulateur cryptographique permettrait de
  tester si une sortie de transaction individuelle (TXO) faisait partie d'un ensemble. SwiftSync n'a
  pas besoin de faire cela. Au lieu de cela, il ajoute une valeur représentant un TXO à un agrégat
  lorsque le TXO est créé et soustrait la même valeur lorsque le TXO est détruit (dépensé). Après
  En effectuant cette opération pour tous les TXOs qui étaient censés être dépensés avant le bloc
  terminal SwiftSync, le nœud vérifie que l'agrégat est nul, indiquant que tous les TXOs créés ont été
  dépensés plus tard.

- *La validation parallèle des blocs ne nécessite pas assumevalid :* nous avons décrit une manière
  dont la validation parallèle pourrait fonctionner avec SwiftSync, dans laquelle les scripts jusqu'au
  bloc terminal SwiftSync n'étaient pas validés, similaire à la manière dont Bitcoin Core fonctionne
  aujourd'hui pendant la synchronisation initiale avec _assumevalid_. Cependant, les scripts
  précédents pourraient être validés avec SwiftSync, bien que cela nécessiterait probablement des
  modifications au protocole P2P de Bitcoin pour inclure éventuellement des données supplémentaires
  avec les blocs. Les nœuds Bitcoin Core stockent déjà ces données pour tout bloc qu'ils stockent
  également, donc nous ne pensons pas qu'ajouter une extension de message P2P serait difficile si on
  s'attendait à ce qu'un nombre significatif de personnes veuillent utiliser SwiftSync avec
  assumevalid désactivé.

- *La validation parallèle des blocs est pour des raisons différentes de celles d'Utreexo :* nous
  avons écrit que SwiftSync est capable de valider des blocs en parallèle pour des raisons similaires
  à celles d'[Utreexo][topic utreexo], mais ils adoptent des approches différentes. Utreexo valide un
  bloc (ou une série de blocs pour l'efficacité) en commençant par un engagement sur l'ensemble des
  UTXO, en effectuant tous les changements sur l'ensemble des UTXO, et en produisant un engagement sur
  le nouvel ensemble des UTXO. Cela permet de diviser le travail de validation en fonction du nombre
  de threads CPU ; par exemple : un thread valide les premiers mille blocs et un autre thread valide
  les mille blocs suivants. À la fin de la validation, le nœud vérifie que l'engagement à la fin des
  premiers mille blocs est le même que l'engagement avec lequel il a commencé pour les mille blocs
  suivants.

  SwiftSync utilise un état agrégé qui permet de soustraire avant d'ajouter. Imaginez qu'un TXO est
  créé dans le bloc 1 et dépensé dans le bloc 2. Si nous traitons le bloc 2 en premier, nous
  soustrayons la représentation du TXO de l'agrégat. Lorsque nous traitons plus tard le bloc 1, nous
  ajoutons la représentation du TXO à l'agrégat. L'effet net est zéro, ce qui est ce qui est vérifié à
  la fin de la validation SwiftSync.

  Nous nous excusons auprès de nos lecteurs pour nos erreurs et remercions Ruben Somsen de les avoir
  signalées.

{% include snippets/recap-ad.md when="2025-04-22 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3593,1242" %}
[bitcoin core 29.0]: https://bitcoincore.org/bin/bitcoin-core-29.0/
[bcc29 testing guide]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/29.0-Release-Candidate-Testing-Guide
[lnd 0.19.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc2
[sources]: /en/internal/sources/
[news349 ss]: /fr/newsletters/2025/04/11/#acceleration-swiftsync-pour-le-telechargement-initial-des-blocs
[bcc rn]: https://bitcoincore.org/en/releases/29.0/
[knots 28.1]: https://github.com/bitcoinknots/bitcoin/releases/tag/v28.1.knots20250305
[bip370 website]: https://bip370.org/
[lnbits github]: https://github.com/lnbits/lnbits
[mempool 3.2.0]: https://github.com/mempool/mempool/releases/tag/v3.2.0
[coinbase mpc blog]: https://www.coinbase.com/blog/innovation-matters-coinbase-breaks-new-ground-with-mpc-security-technology
[coinbase mpc github]: https://github.com/coinbase/cb-mpc
[hydrus github]: https://github.com/aftermath2/hydrus
[vss blog]: https://lightningdevkit.org/blog/announcing-vss/
[fuzzamoto github]: https://github.com/dergoegge/fuzzamoto
[braiins tweet]: https://x.com/BraiinsMining/status/1904601547855573458
[news163 secret]: /en/newsletters/2021/08/25/#bolts-887
