---
title: 'Bulletin Hebdomadaire Bitcoin Optech #407'
permalink: /fr/newsletters/2026/05/29/
name: 2026-05-29-newsletter-fr
slug: 2026-05-29-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine annonce la divulgation responsable d'une vulnérabilité qui permettait à un pair distant de faire planter des
nœuds Core Lightning et renvoie vers des transcriptions d'une récente réunion des développeurs de Bitcoin Core. Sont également incluses nos
sections régulières annonçant de nouvelles versions et versions candidates et décrivant des changements notables dans des logiciels
populaires de l'infrastructure Bitcoin.

## Nouvelles

- **Divulgation d'un DoS par assertion dans Core Lightning :** Chandra Pratap a [publié][cln dos delving] sur Delving Bitcoin la divulgation
  d'une vulnérabilité de déni de service découverte lors d'un stage Summer of Bitcoin
  2025. La vulnérabilité affectait les nœuds Core Lightning qui acceptent des canaux entrants.

  Lors de la poignée de main d'ouverture de canal, un pair distant envoie un message contenant le txid de la transaction de financement
  proposée. Core Lightning effectuait une vérification par assertion exigeant un txid non nul. Lorsqu'un pair envoyait à la place un txid
  entièrement nul, l'assertion échouait et faisait planter le nœud. Comme n'importe quel pair peut initier une poignée de main d'ouverture
  de canal et envoyer le message malveillant, cela permettait à un attaquant distant de faire planter de manière fiable tout nœud vulnérable
  qui acceptait des canaux entrants.

  La vulnérabilité a été [divulguée de manière responsable][topic responsible disclosures] et découverte grâce au fuzzing. Au moment du
  rapport, Rusty Russell travaillait indépendamment sur un bogue de plantage distinct et son correctif a également résolu incidemment cette
  vulnérabilité. La vulnérabilité a été corrigée dans [Core Lightning 26.04][news402 cln2604].

- **Transcriptions de la réunion des développeurs de Bitcoin Core :** de nombreux développeurs de Bitcoin Core se sont rencontrés en
  personne en mai, et les transcriptions de la réunion ont été [publiées][coredev 2026-05]. Les sujets comprenaient [SwiftSync][coredev
  swiftsync], le [mempool post-cluster][coredev post-cluster], une [refonte d'Erlay][coredev erlay], le [relay de paquets][coredev pkg
  relay], les [silent payments][coredev silent payments], le [TCP hole punching][coredev tcp holepunch] (voir le [Bulletin #406][news406 tcp
  holepunch]), la [diffusion privée][coredev private broadcast], une [bibliothèque cryptographique moderne][coredev modern crypto] et les
  [tests par mutation][coredev mutation testing], entre autres.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires. Veuillez envisager de mettre à niveau vers
les nouvelles versions ou d'aider à tester les versions candidates._

- [Eclair v0.14.0][] est la dernière version de cette implémentation populaire de nœud LN. Elle inclut les versions finales du
  [splicing][topic splicing], des [canaux taproot simples][topic simple taproot channels] et des [engagements sans frais][topic v3
  commitments], supprime la prise en charge des canaux non-[anchor output][topic anchor outputs], et ajoute un score de pairs expérimental
  pour l'optimisation de la liquidité et du routage.

- [Core Lightning 26.06rc2][] est une version candidate pour la prochaine version majeure de ce nœud LN populaire qui inclut de nouvelles
  RPC `graceful`, `sendamount` et `xkeysend`, commence le cycle de dépréciation de `pay` en faveur de `xpay`, et ajoute la prise en charge
  RPC de preuve du payeur pour [BOLT12][topic offers].

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning
BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo] et [BINANAs][binana repo]._

- [Bitcoin Core #33966][] remanie la façon dont il gère les options de modèle de bloc de minage pour l'interface IPC de minage (voir les
  Bulletins [#310][news310 mining] et [#323][news323 mining]). Auparavant, les options de minage au démarrage telles que `blockmaxweight`,
  `blockreservedweight` et `blockmintxfee` étaient gérées séparément des options d'exécution transmises par les clients de minage IPC.
  Désormais, ces options sont analysées dans un objet partagé `BlockCreateOptions` et fusionnées lors de la création ou de la mise à jour
  des modèles de bloc. Les combinaisons invalides, comme un poids de bloc réservé qui dépasse le poids maximal du bloc, sont désormais
  rejetées au lieu d'être silencieusement ajustées à une valeur de plage valide.

- [Bitcoin Core #34917][] cesse de renvoyer le champ déprécié `bip125-replaceable` dans les RPC de transactions du portefeuille
  `listtransactions`, `listsinceblock` et `gettransaction`, bien que les utilisateurs puissent toujours demander le champ avec l'option
  `-deprecatedrpc=bip125`. La PR déprécie également l'option de démarrage `-walletrbf`, qui émet désormais un avertissement et dont la
  suppression est prévue dans la prochaine version. Voir le [Bulletin #403][news403 rbf] pour la suppression précédente de champs liés au
  [RBF][topic rbf].

- [Bitcoin Core #35017][] met à jour le processus de soumission de transactions en [paquet][topic package relay] afin d'empêcher que des
  transactions ultérieures restent dans le mempool après un échec inattendu de validation. Lors de la soumission d'un paquet, les
  transactions sont traitées séquentiellement, permettant aux transactions ultérieures de dépenser des transactions antérieures déjà
  ajoutées au mempool. Auparavant, si une transaction échouait à une vérification tardive de validation (comme une vérification de script de
  consensus), Bitcoin Core ne supprimait que cette transaction. Désormais, il supprime aussi toutes les transactions suivantes du paquet,
  empêchant que des enfants restent dans le mempool après la suppression d'un parent.

- [BIPs #1944][] ajoute [BIP449][], une proposition préliminaire de soft fork pour `OP_TWEAKADD`, un opcode [tapscript][topic tapscript]
  permettant de calculer une clé publique x-only modifiée (voir le [Bulletin
  #370][news370 tweak]). Étant données une clé publique x-only de 32 octets et
  un tweak scalaire de 32 octets, l'opcode empile la clé x-only pour `P + tG`. Cela permettrait aux scripts de vérifier directement des
  relations de modification de clé, rendant possibles des constructions telles que les scripts de révélation de tweak, la preuve de l'ordre
  de signature et les protocoles de [délégation de signature][topic signer delegation].

- [BIPs #2108][] ajoute [BIP450][], Formosa, une spécification préliminaire pour encoder l'entropie de portefeuille compatible [BIP39][]
  sous forme de phrases mnémoniques de type histoire. Au lieu d'utiliser des mots BIP39 aléatoires, Formosa utilise des listes de mots
  définies par thème pour encoder l'entropie, produisant des phrases courtes et structurées. Ces histoires peuvent être redécodées en
  l'entropie originale et converties en une phrase mnémonique BIP39 standard avant la dérivation de la seed, préservant ainsi la
  compatibilité avec BIP39.

- [Eclair #3192][] ajoute une prise en charge expérimentale des canaux à [engagement sans frais][topic v3 commitments] (0FC), conformément à
  la spécification couverte dans le [Bulletin #404][news404 0fc]. La fonctionnalité est désactivée par défaut et peut être activée avec
  `eclair.features.zero_fee_commitments = optional`.

- [LDK #4584][] ajoute des maps `payment_metadata` aux contextes de message aveuglé et de chemin de paiement de [BOLT12][topic offers]. Cela
  ajoute l'infrastructure nécessaire pour transporter des métadonnées du côté du destinataire à travers des [chemins aveuglés][topic rv
  routing] et les récupérer lorsque le paiement est reçu, de manière similaire au `payment_metadata` de [BOLT11][]. La construction d'offres
  avec métadonnées n'est pas encore prise en charge. Les métadonnées sont stockées sous forme de map de clés numériques vers des tableaux
  d'octets, permettant d'attacher plusieurs éléments de données indépendants au même paiement.

- [LDK #4628][] commence à chiffrer `payment_metadata` de [BOLT11][] lors de la création de paiements entrants, en s'appuyant sur
  l'engagement de métadonnées couvert dans le [Bulletin #405][news405 metadata]. Après vérification du paiement, LDK déchiffre les
  métadonnées, permettant aux applications d'accéder aux métadonnées de facture sans les exposer au payeur ni devoir implémenter elles-mêmes
  le chiffrement.

- [LND #10552][] ajoute une synchronisation initiale rapide pour les nœuds LND adossés à [Neutrino][topic compact block filters] en leur
  permettant d'importer des en-têtes de blocs Bitcoin et des filtres compacts préconstruits depuis des fichiers locaux ou des sources
  HTTP(S) avant de reprendre la synchronisation P2P normale. Les nouvelles options `neutrino.blockheaderssource` et
  `neutrino.filterheaderssource` doivent être configurées ensemble. Les en-têtes importés sont validés localement, puis Neutrino récupère
  auprès des pairs du réseau tous les en-têtes postérieurs à la pointe importée.

- [LND #10820][] empêche LND de sélectionner implicitement des [canaux taproot simples][topic simple taproot channels] lors de l'ouverture
  de canaux publics, car les [annonces de canal][topic channel announcements] taproot ne sont pas encore prises en charge. Auparavant, si
  les deux pairs annonçaient la prise en charge de ce type de canal, LND pouvait le sélectionner puis rejeter l'ouverture. Désormais, les
  canaux taproot simples doivent être demandés explicitement, tandis que la négociation implicite peut toujours sélectionner les types de
  canaux hérités, static remote key ou [anchor][topic anchor outputs]. La PR met également à jour `lncli openchannel --channel_type=taproot`
  pour sélectionner le type de canal taproot simple de production.

{% include snippets/recap-ad.md when="2026-06-02 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33966,34917,35017,3192,4584,4628,10552,10820,2108,1944" %}
[cln dos delving]: https://delvingbitcoin.org/t/vulnerability-disclosure-assertion-dos-in-core-lightning/2507
[news402 cln2604]: /fr/newsletters/2026/04/24/#core-lightning-26-04
[coredev 2026-05]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05
[coredev swiftsync]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/swiftsync
[coredev post-cluster]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/post-cluster-mempool
[coredev erlay]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/erlay-redesign
[coredev pkg relay]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/package-relay
[coredev silent payments]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/silent-payments
[coredev tcp holepunch]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/tcp-holepunch
[news406 tcp holepunch]: /en/newsletters/2026/05/22/#tcp-hole-punching-for-bitcoin-nodes-behind-nats
[coredev private broadcast]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/private-broadcast
[coredev modern crypto]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/modern-crypto-library
[coredev mutation testing]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/mutation-testing
[Eclair v0.14.0]: https://github.com/ACINQ/eclair/releases/tag/v0.14.0
[Core Lightning 26.06rc2]: https://github.com/ElementsProject/lightning/releases/tag/v26.06rc2
[news310 mining]: /fr/newsletters/2024/07/05/#bitcoin-core-30200
[news323 mining]: /fr/newsletters/2024/10/04/#bitcoin-core-30510
[news403 rbf]: /fr/newsletters/2026/05/01/#bitcoin-core-34911
[news404 0fc]: /fr/newsletters/2026/05/08/#bolts-1228
[news405 metadata]: /en/newsletters/2026/05/15/#ldk-4528
[news370 tweak]: /fr/newsletters/2025/09/05/#brouillon-de-bip-pour-op-tweakadd
