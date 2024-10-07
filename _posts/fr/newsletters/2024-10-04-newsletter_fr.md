---
title: 'Bulletin Hebdomadaire Bitcoin Optech #323'
permalink: /fr/newsletters/2024/10/04/
name: 2024-10-04-newsletter-fr
slug: 2024-10-04-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine annonce une divulgation de sécurité planifiée et sont également incluses
nos sections habituelles avec
des annonces de mises à jour et versions candidates, ainsi que les changements
apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Divulgation de sécurité btcd imminente :** Antoine Poinsot a [publié][poinsot btcd] sur Delving
  Bitcoin un message annonçant la divulgation prévue le 10 octobre d'un bug de consensus affectant le nœud
  complet btcd. En utilisant les données d'une enquête approximative sur les nœuds complets actifs,
  Poinsot estime qu'il y a environ 36 nœuds btcd qui sont vulnérables (bien que 20 de ces nœuds soient
  également vulnérables à une vulnérabilité de consensus déjà divulguée, voir le [Bulletin
  #286][news286 btcd vuln]). Dans une [réponse][osuntokun btcd], le mainteneur de btcd, Olaoluwa
  Osuntokun, a confirmé l'existence de la vulnérabilité et le fait qu'elle a été corrigée dans la
  version 0.24.2 de btcd. Toute personne utilisant une version antérieure de btcd est encouragée à
  mettre à niveau vers la [dernière version][btcd v0.24.2], qui avait déjà été annoncée comme critique
  pour la sécurité.

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les candidats
à la version.*

- [Bitcoin Core 28.0][] est la dernière version majeure de l'implémentation de nœud complet
  prédominante. C'est la première version à inclure le support pour [testnet4][topic testnet], le
  relais de paquets opportuniste un-parent-un-enfant (1p1c) [package relay][topic package relay], le
  relais par défaut de transactions opt-in topologiquement restreintes jusqu'à confirmation
  ([TRUC][topic v3 transaction relay]), le relais par défaut de transactions [pay-to-anchor][topic
  ephemeral anchors], le relais limité de paquets [RBF][topic rbf], et le [full-RBF][topic rbf] par
  défaut. Les paramètres par défaut pour [assumeUTXO][topic assumeutxo] ont été ajoutés, permettant
  l'utilisation de la RPC `loadtxoutset` avec un ensemble UTXO téléchargé en dehors du réseau Bitcoin
  (par exemple, via un torrent). La version inclut également de nombreuses autres améliorations et
  corrections de bugs, comme décrit dans ses [notes de version][bcc 28.0 rn].

- [BDK 1.0.0-beta.5][] est un candidat à la version (RC) de cette bibliothèque pour construire des
  portefeuilles et d'autres applications activées par Bitcoin. Ce dernier RC "active RBF par défaut,
  met à jour le client bdk_esplora pour réessayer les requêtes au serveur qui échouent en raison de la
  limitation du taux. Le paquet `bdk_electrum` offre maintenant également une fonctionnalité
  use-openssl."

### Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #30043][] introduit une implémentation intégrée du [Port Control Protocol
  (PCP)][rfcpcp] pour supporter le pinholing IPv6, permettant aux nœuds de devenir accessibles sans
  configuration manuelle sur le routeur. Cette mise à jour remplace la dépendance existante
  `libnatpmp` pour le mappage de port IPv4 par PCP, tout en mettant en place un mécanisme de secours
  vers le [NAT Port Mapping Protocol (NAT-PMP)][rfcnatpmp]. Bien que la fonctionnalité PCP / NAT-PMP
  soit désactivée par défaut, cela pourrait changer dans les futures versions. Voir le Bulletin
  [#131][news131 natpmp].

- [Bitcoin Core #30510][] ajoute un wrapper de communication inter-processus (IPC) à l'interface
  `Mining` (Voir le Bulletin [#310][news310 stratumv2]) pour permettre à un processus de minage
  [Stratum v2][topic pooled mining] séparé de créer, gérer et soumettre des modèles de blocs en se
  connectant et en contrôlant le processus `bitcoin-node` (voir le Bulletin [#320][news320 stratumv2]).

- [Bitcoin Core #30409][] étend l'interface `Mining` avec une nouvelle méthode `waitTipChanged()` qui
  détecte l'arrivée d'un nouveau bloc puis envoie de nouveaux modèles de blocs aux clients connectés.
  Les méthodes RPC `waitfornewblock`, `waitforblock` et `waitforblockheight` ont été refactorisées
  pour l'utiliser.

- [Core Lightning #7644][] ajoute une commande `nodeid` à l'utilitaire `hsmtool` qui retourne
  l'identifiant du nœud pour un fichier de sauvegarde `hsm_secret` donné, afin d'associer la
  sauvegarde à son nœud spécifique et d'éviter la confusion avec d'autres nœuds.

- [Eclair #2848][] implémente des [publicités de liquidité][topic liquidity advertisements]
  extensibles comme spécifié dans les propositons [BOLTs #1153][], ce qui permet aux vendeurs d'annoncer
  les taux auxquels ils sont prêts à vendre de la liquidité aux acheteurs dans leur message
  `node_announcement`, puis les acheteurs peuvent se connecter et demander de la liquidité. Cela peut
  être utilisé lors de la création d'un [canal à double financement][topic dual funding], ou lors de
  l'ajout de liquidité supplémentaire à un canal existant via [splicing][topic splicing].

- [Eclair #2860][] ajoute un message `recommended_feerates` optionnel pour que les nœuds informent
  leurs pairs des taux de frais acceptables qu'ils souhaitent utiliser pour financer les transactions
  de canal. Si un nœud rejette les demandes de financement d'un pair, le pair comprendra que cela
  était dû aux taux de frais.

- [Eclair #2861][] met en œuvre le financement à la volée tel que spécifié dans [BLIPs #36][],
  permettant aux clients sans liquidité entrante suffisante de demander de la liquidité supplémentaire
  à un pair via le protocole de [publicités de liquidité][topic liquidity advertisements] (voir PR
  ci-dessus) afin de recevoir un paiement. Le vendeur de liquidité couvre les frais de transaction onchain
  pour la transaction de [canal à double financement][topic dual funding] ou de [splicing][topic
  splicing], mais est ensuite payé par l'acheteur lorsque le
  paiement est acheminé. Si le montant n'est pas suffisamment élevé pour couvrir les frais onchain
  nécessaires pour que la transaction soit confirmée, le vendeur peut effectuer une double dépense pour
  utiliser sa liquidité ailleurs.

- [Eclair #2875][] implémente les crédits de frais de financement comme spécifié dans [BLIPs #41][],
  permettant aux clients de financement à la volée (voir PR ci-dessus) d'accepter des paiements qui
  sont trop petits pour couvrir les frais onchain pour un canal. Une fois que des crédits de frais
  suffisants ont été accumulés, une transaction onchain telle qu'un financement de canal ou
  un [splicing][topic splicing] est créée en utilisant les crédits de frais. Les clients comptent sur les
  fournisseurs de liquidité pour honorer les crédits de frais dans les transactions futures.

- [LDK #3303][] ajoute un nouveau `PaymentId` pour les paiements entrants afin d'améliorer la
  gestion des événements idempotents. Cela permet aux utilisateurs de vérifier facilement si un
  événement a déjà été traité lors de la relecture des événements pendant les redémarrages de nœud. Le
  risque de traitement en double qui était possible en se fiant au `PaymentHash` est éliminé. Le
  `PaymentId` est un code d'authentification de message basé sur le hachage (HMAC) de l'identifiant du
  canal [HTLC][topic htlc] et des paires d'identifiants HTLC inclus dans le paiement.

- [BDK #1616][] signale par défaut l'opt-in [RBF][topic rbf] dans la classe `TxBuilder`. L'appelant
  peut désactiver le signal en changeant le numéro de séquence.

- [BIPs #1600][] apporte plusieurs changements à la spécification [BIP85][], y compris la
  spécification que `drng_reader.read` (responsable de la lecture des nombres aléatoires) est une
  fonction de première classe plutôt qu'une évaluation. Cette mise à jour clarifie également la
  gestion du boutisme, ajoute le support pour [testnet][topic testnet], inclut une nouvelle
  implémentation de référence en Python, clarifie qu'un portefeuille de seeds de [portefeuille
  HD][topic bip32] utilise les bits les plus significatifs pour le format d'importation de
  portefeuille (WIF), ajoute le code de langue portugaise, et corrige les vecteurs de test. Enfin, un
  nouveau champion pour la spécification BIP a été désigné.

- [BOLTs #798][] fusionne la spécification du protocole [offres][topic offers] qui introduit
  [BOLT12][], et apporte également plusieurs mises à jour à [BOLT1][] et [BOLT4][].

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30043,30510,7644,2875,2861,2860,2848,3303,1616,1600,798,30409,1153,36,41" %}
[BDK 1.0.0-beta.5]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.5
[bitcoin core 28.0]: https://bitcoincore.org/bin/bitcoin-core-28.0/
[poinsot btcd]: https://delvingbitcoin.org/t/non-disclosure-of-a-consensus-bug-in-btcd/1177
[osuntokun btcd]: https://delvingbitcoin.org/t/non-disclosure-of-a-consensus-bug-in-btcd/1177/3
[news286 btcd vuln]: /fr/newsletters/2024/01/24/#divulgation-de-la-defaillance-de-consensus-corrigee-dans-btcd
[btcd v0.24.2]: https://github.com/btcsuite/btcd/releases/tag/v0.24.2
[bcc 28.0 rn]: https://github.com/bitcoin/bitcoin/blob/5de225f5c145368f70cb5f870933bcf9df6b92c8/doc/release-notes.md
[rfcpcp]: https://datatracker.ietf.org/doc/html/rfc6887
[rfcnatpmp]: https://datatracker.ietf.org/doc/html/rfc6886
[news131 natpmp]: /en/newsletters/2021/01/13/#bitcoin-core-18077
[news310 stratumv2]: /fr/newsletters/2024/07/05/#bitcoin-core-30200
[news320 stratumv2]: /fr/newsletters/2024/09/13/#bitcoin-core-30509
