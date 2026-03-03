---
title: 'Bulletin Hebdomadaire Bitcoin Optech #392'
permalink: /fr/newsletters/2026/02/13/
name: 2026-02-13-newsletter-fr
slug: 2026-02-13-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume la discussion sur l'amélioration de la performance de balayage
silencieux des paiements dans le pire des cas et décrit une idée permettant d'activer de nombreuses
conditions de dépense avec une seule clé.
Sont également incluses nos sections régulières résumant les annonces de nouvelles versions
et de candidats à la publication, et les résumés des modifications notables apportées
aux logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

- **Proposition pour limiter le nombre de destinataires de paiement silencieux par groupe** :
  Sebastian Falbesoner a [posté][kmax mailing list] sur la liste de diffusion Bitcoin-Dev la
  découverte et l'atténuation d'une attaque théorique sur les destinataires de [paiement
  silencieux][topic silent payments]. L'attaque se produit lorsqu'un adversaire construit une
  transaction avec un grand nombre de sorties taproot (23255 sorties max par bloc selon les règles de
  consensus actuelles) qui ciblent toutes la même entité. S'il n'y avait pas de limite sur la taille
  du groupe, le traitement prendrait plusieurs minutes, au lieu de dizaines de secondes.

  Cela a motivé une atténuation pour ajouter un nouveau paramètre, `K_max`, qui limite le nombre de
  destinataires par groupe dans une seule transaction. En théorie, ce changement ne serait pas
  rétrocompatible, mais en pratique, aucun des portefeuilles de paiement silencieux existants ne
  devrait être affecté pour un `K_max` suffisamment élevé. Falbesoner propose un `K_max=1000`.

  Falbesoner cherche des retours ou des préoccupations concernant la restriction proposée. Il note
  également que la plupart des développeurs de portefeuilles de paiement silencieux ont été notifiés
  et sont au courant du problème.

- **BLISK, Logique de circuit Booléen Intégrée dans la Clé Unique** : Oleksandr Kurbatov a
  [posté][blisk del] sur Delving Bitcoin à propos de BLISK, un protocole conçu pour exprimer des
  politiques d'autorisation complexes en utilisant la logique booléenne. BLISK tente de répondre aux
  limitations des politiques de dépense actuelles. Par exemple, des protocoles comme [MuSig2][topic
  musig], bien qu'efficaces et préservant la vie privée, ne peuvent exprimer que la cardinalité
  (k-de-n) mais ne peuvent pas identifier "qui" peut dépenser.

  BLISK crée un circuit booléen simple AND/OR, mappant des portes logiques à des techniques
  cryptographiques bien connues. En particulier, les portes AND sont obtenues en appliquant une
  configuration de multisignature n-de-n, dans laquelle chaque participant doit contribuer avec une
  signature valide. D'autre part, les portes OR sont obtenues en tirant parti des protocoles d'accord
  de clé, tels que [ECDH][ecdh wiki], dans lesquels tout participant peut dériver un secret partagé en
  utilisant sa clé privée et la clé publique de l'autre participant. Il applique également une [preuve
  de connaissance zéro non interactive][nizk wiki] pour rendre la résolution du circuit vérifiable et
  pour empêcher la tricherie.
  BLISK résout le circuit en une seule clé de vérification de signature. Cela signifie qu'une seule
  signature [Schnorr][topic schnorr signatures] doit être vérifiée contre une clé publique.

  Un autre avantage important de BLISK par rapport à d'autres approches est l'élimination du besoin de
  générer une nouvelle paire de clés. En fait, cela permet de connecter une clé existante à l'instance
  de signature spécifique.

  Kurbatov a fourni un [proof-of-concept][blisk gh] pour le protocole, bien qu'il ait déclaré que le
  cadre n'a pas encore atteint la maturité de production.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates._

- [Bitcoin Core 29.3][] est une version de maintenance pour la série de versions majeures précédente
  qui inclut plusieurs correctifs de migration de portefeuille (voir le [Bulletin #387][news387
  wallet]), un cache de midstate sighash par entrée qui réduit l'impact du sighashing quadratique dans
  les scripts legacy (voir le Bulletin [#367][news367 sighash]), et la suppression du découragement
  des pairs pour les transactions invalides selon le consensus (voir le Bulletin [#367][news367
  discourage]). Voir les [notes de version][bcc29.3 rn] pour tous les détails.

- [LDK 0.2.2][] est une version de maintenance de cette bibliothèque pour la construction
  d'applications compatibles LN. Elle met à jour le drapeau de fonctionnalité `SplicePrototype` vers
  le bit de fonctionnalité de production (63), corrige un problème où les opérations de persistance
  asynchrones de `ChannelMonitorUpdate` pouvaient se bloquer après des redémarrages et conduire à des
  fermetures forcées, et corrige un échec d'assertion de débogage qui se produisait lors de la
  réception de messages de splicing invalides d'un pair.

- [HWI 3.2.0][] est une version de ce paquet fournissant une interface commune à plusieurs
  dispositifs de signature matérielle. La nouvelle version ajoute le support pour les dispositifs Jade
  Plus et BitBox02 Nova, [testnet4][topic testnet], la signature native [PSBT][topic psbt] pour Jade,
  et les champs PSBT [MuSig2][topic musig] tels que spécifiés dans [BIP373][].

- [Bitcoin Inquisition 29.2][] est une version de ce nœud complet [signet][topic signet] conçu pour
  expérimenter avec des propositions de soft forks et d'autres changements majeurs de protocole. Basée sur
  Bitcoin Core 29.3r2, cette version implémente la proposition [BIP54][] ([nettoyage du
  consensus][topic consensus cleanup]) et désactive [testnet4][topic testnet].

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [Serveur
BTCPay][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration de Bitcoin (BIPs)][bips
repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin
inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #32420][] met à jour l'interface IPC de minage (voir le Bulletin [#310][news310
  mining]) pour arrêter d'inclure un `extraNonce` factice dans le `scriptSig` du coinbase. Une
  nouvelle option `include_dummy_extranonce` est ajoutée à `CreateNewBlock()`, et le chemin de code
  IPC le définit sur `false`. Les clients [Stratum v2][topic pooled mining] ne reçoivent que la
  hauteur requise par le consensus [BIP34][] dans le `scriptSig` et n'ont plus besoin de retirer ou
  d'ignorer les données supplémentaires.

- [Core Lightning #8772][] supprime le support pour le format de paiement onion legacy. Bien que CLN
  ait arrêté de créer des onions legacy en 2022 (voir le [Bulletin #193][news193 legacy]), il a ajouté
  une couche de traduction dans v24.05 pour gérer les quelques oignons hérités restants produits par
  les anciennes versions de LND. Ceux-ci n'ont pas été créés depuis LND v0.18.3, donc le support n'est
  plus nécessaire. Le format hérité a été retiré de la spécification BOLTs
  en 2022 (voir le [Bulletin #220][news220 bolts]).

- [LND #10507][] ajoute un nouveau champ booléen `wallet_synced` à la réponse de l'appel RPC `GetInfo`,
  qui indique si le portefeuille a terminé de se synchroniser avec le sommet actuel de la chaîne.
  Contrairement au champ booléen existant `synced_to_chain`, ce nouveau champ ne nécessite pas que
  le routeur du graphe des canaux (qui valide les [channel announcements][topic channel announcements])
  ou le dispatcheur blockbeat (un sous-système qui coordonne les événements déclenchés par les blocs)
  soient synchronisés avant de renvoyer la valeur vraie.

- [LDK #4387][] change le drapeau de fonctionnalité [splicing][topic splicing] du bit provisoire 155
  au bit de production 63. LDK v0.2 utilisait le bit 155, que Eclair utilise également pour une
  implémentation de splice spécifique à Phoenix, qui prédate et est incompatible avec le brouillon actuel
  de la spécification. Cela a conduit les nœuds Eclair à tenter des splices en utilisant leur
  protocole lors de la connexion aux nœuds LDK, entraînant des échecs de désérialisation et des
  reconnexions.

- [LDK #4355][] ajoute le support pour la signature asynchrone des signatures d'engagement
  échangées pendant les négociations de canaux de [splicing][topic splicing] et [dual-funded][topic dual
  funding]. Lors de la réception de `EcdsaChannelSigner::sign_counterparty_commitment`, le signataire
  asynchrone retourne immédiatement et rappelle via `ChannelManager::signer_unblocked` une fois la signature prête.
  Les canaux à double financement nécessitent encore un travail supplémentaire pour supporter
  pleinement la signature asynchrone.

- [LDK #4354][] rend les canaux avec [anchor outputs][topic anchor outputs]
  la configuration par défaut en réglant l'option de configuration de
  `negotiate_anchors_zero_fee_htlc_tx` à vrai par défaut. L'acceptation automatique des canaux a été
  supprimée, donc toutes les demandes de canaux entrants
  doivent être acceptées manuellement. Cela garantit que le portefeuille a suffisamment
  de fonds onchain pour couvrir les frais en cas de fermeture forcée.

- [LDK #4303][] corrige deux bugs où les [HTLCs][topic htlc] pouvaient être
  doublement transmis après un redémarrage de `ChannelManager` : un où le
  HTLC sortant était encore dans une cellule de rétention (file d'attente interne) mais il était
  manqué, et un autre où il avait déjà été transmis, réglé, et
  retiré du canal sortant, mais la cellule de rétention du côté entrant
  avait encore une résolution pour cela. Cette PR élimine également les oignons HTLC entrants
  une fois qu'ils sont irrévocablement transmis.

- [HWI #784][] ajoute la sérialisation et la désérialisation [PSBT][topic psbt] pour les champs
  [MuSig2][topic musig], incluant les clés publiques des participants, les nonces publics, et les
  signatures partielles pour les entrées et les sorties, comme spécifié dans [BIP327][].

- [BIPs #2092][] attribue un ID de type de message de transport P2P [v2][topic v2 p2p
  transport] d'un octet au message `feature` de [BIP434][],
  et ajoute un fichier auxiliaire à [BIP324][] suivant les attributions d'ID d'un octet à travers les
  BIPs pour aider les développeurs à éviter les conflits. Le fichier
  enregistre également les affectations proposées par [Utreexo][topic utreexo] de BIP183.

- [BIPs #2004][] ajoute [BIP89][] pour la Délégation de Code de Chaîne (voir
  le [Bulletin #364][news364 delegation]), une technique de garde collaborative
  où un délégué retient les codes de chaîne [BIP32][] d'un délégateur, partageant seulement assez
  d'informations avec le délégateur pour
  produire des signatures sans apprendre quelles adresses ont reçu des fonds.

- [BIPs #2017][] ajoute [BIP110][], qui spécifie le Softfork Temporaire de Données Réduites (RDTS),
  une proposition pour restreindre temporairement
  les champs de transaction porteurs de données au niveau du consensus pour
  environ un an. Les règles invalideraient les scriptPubKeys
  dépassant 34 octets (sauf OP_RETURN jusqu'à 83 octets), pushdata et
  les éléments de pile de témoin dépassant 256 octets, dépense de versions de témoin non définies, annexes
  [taproot][topic taproot], blocs de contrôle
  dépassant 257 octets, opcodes `OP_SUCCESS`, et `OP_IF`/`OP_NOTIF` dans
  [tapscripts][topic tapscript]. Les entrées dépensant des UTXOs créés avant
  l'activation sont exemptées. L'activation utilise un déploiement [BIP9][] modifié
  avec un seuil de signalisation des mineurs réduit à 55% et un verrouillage obligatoire par
  environ septembre 2026. Voir le [Bulletin #379][news379 rdts] pour
  une couverture antérieure de cette proposition.

- [Bitcoin Inquisition #99][] ajoute une implémentation des règles de soft fork de [BIP54][]
  [nettoyage du consensus][topic consensus cleanup] sur
  [signet][topic signet]. Les quatre atténuations mises en œuvre sont : des limites sur
  le nombre de sigops hérités potentiellement exécutés par transaction, la
  prévention des attaques de timewarp avec une période de grâce de deux heures (plus
  la prévention des intervalles d'ajustement de difficulté négatifs), le verrouillage temporel
  obligatoire des transactions de coinbase à la hauteur du bloc, et
  l'invalidation des transactions de 64 octets.

{% include snippets/recap-ad.md when="2026-02-17 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32420,8772,10507,4387,4355,4354,4303,784,2092,2004,2017,99" %}
[kmax mailing list]: https://groups.google.com/g/bitcoindev/c/tgcAQVqvzVg
[blisk del]: https://delvingbitcoin.org/t/blisk-boolean-circuit-logic-integrated-into-the-single-key/2217
[ecdh wiki]: https://en.wikipedia.org/wiki/Elliptic-curve_Diffie%E2%80%93Hellman
[nizk wiki]: https://en.wikipedia.org/wiki/Non-interactive_zero-knowledge_proof
[blisk gh]: https://github.com/zero-art-rs/blisk
[Bitcoin Core 29.3]: https://bitcoincore.org/bin/bitcoin-core-29.3/
[bcc29.3 rn]: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-29.3.md
[Bitcoin Inquisition 29.2]: https://github.com/bitcoin-inquisition/bitcoin/releases/tag/v29.2-inq
[HWI 3.2.0]: https://github.com/bitcoin-core/HWI/releases/tag/3.2.0
[LDK 0.2.2]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.2.2
[news387 wallet]: /fr/newsletters/2026/01/09/#bug-de-migration-de-portefeuille-bitcoin-core
[news367 sighash]: /fr/newsletters/2025/08/15/#bitcoin-core-32473
[news367 discourage]: /fr/newsletters/2025/08/15/#bitcoin-core-33050
[news310 mining]: /fr/newsletters/2024/07/05/#bitcoin-core-30200
[news193 legacy]: /en/newsletters/2022/03/30/#c-lightning-5058
[news220 bolts]: /fr/newsletters/2022/10/05/#bolts-962
[news364 delegation]: /fr/newsletters/2025/07/25/#retention-du-code-de-chaine-pour-les-scripts-multisig
[news379 rdts]: /fr/newsletters/2025/11/07/#fork-temporaire-pour-reduire-les-donnees
[BIP89]: https://github.com/bitcoin/bips/blob/master/bip-0089.mediawiki
