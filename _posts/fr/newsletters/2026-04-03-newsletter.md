---
title: 'Bulletin Hebdomadaire Bitcoin Optech #399'
permalink: /fr/newsletters/2026/04/03/
name: 2026-04-03-newsletter-fr
slug: 2026-04-03-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit comment l'empreinte des portefeuilles peut nuire à la confidentialité de payjoin et résume une
proposition de format de métadonnées pour la sauvegarde de portefeuilles. Sont également incluses nos rubriques habituelles résumant les
propositions et discussions sur la modification des règles de consensus de Bitcoin, annonçant de nouvelles versions et versions candidates,
et décrivant les changements notables apportés aux logiciels populaires d'infrastructure Bitcoin.

## Nouvelles

- **Risques de l'empreinte des portefeuilles pour la confidentialité de payjoin** : Armin Sabouri a [posté][topic payjoin fingerprinting]
  sur Delving Bitcoin comment des différences dans les implémentations de payjoin permettent de prendre l'empreinte des transactions
  [payjoin][topic payjoin] et peuvent nuire à la confidentialité de payjoin.

  Sabouri indique que les transactions payjoin devraient paraître indiscernables de transactions standard à partie unique. Cependant, il
  peut y avoir des artefacts de transactions collaboratives :

  - Intra-transaction

    - Partitionner les entrées et sorties par propriétaire au sein d'une même transaction.

    - Différences dans l'encodage des entrées.

    - Longueur des entrées en octets.

  - Inter-transaction

    - Rétrospective : chaque entrée a été créée par une transaction antérieure qui porte sa propre empreinte.

    - Prospective : chaque sortie peut être dépensée dans une transaction future, révélant des empreintes.

  Il a ensuite examiné trois implémentations de payjoin : Samourai, la démo PDK, et Cake Wallet (envoyant vers Bull Bitcoin Mobile). Dans
  chacun de ces exemples, il trouve quelques divergences qui permettent de prendre l'empreinte de ces implémentations. Cela inclut, sans s'y
  limiter :

  - Différences dans les signatures d'entrée encodées.

  - L'octet SIGHASH_ALL inclus dans une entrée mais pas dans l'autre.

  - Attribution de la valeur des sorties.

  Sabouri conclut que, si certaines de ces empreintes de portefeuille sont triviales à éliminer, d'autres sont intrinsèques à un choix de
  conception particulier du portefeuille. Les développeurs de portefeuilles devraient être conscients de ces fuites potentielles de
  confidentialité lors de l'implémentation de payjoin dans leurs portefeuilles.

- **Projet de BIP pour un format de métadonnées de sauvegarde de portefeuille** : Pythcoiner a [posté][wallet bip ml] sur la liste de
  diffusion Bitcoin-Dev une nouvelle proposition pour une structure commune de métadonnées de sauvegarde de portefeuille. Le projet de BIP,
  disponible dans [BIPs #2130][], spécifie une manière standard de stocker divers types de métadonnées, comme les descripteurs de compte,
  les clés, les [étiquettes][topic wallet labels], les [PSBT][topic psbt], et plus encore, permettant la compatibilité entre différentes
  implémentations de portefeuilles ainsi que des processus de migration et de récupération de portefeuille plus simples. Selon Pythcoiner,
  l'écosystème manque d'une spécification commune et cette proposition vise à combler cette lacune.

  D'un point de vue technique, le format proposé est un fichier texte encodé en UTF-8 contenant un unique objet JSON valide représentant la
  structure de sauvegarde. Le BIP énumère tous les différents champs pouvant être inclus dans l'objet JSON, précise que chacun d'eux est
  optionnel, et note que toute implémentation de portefeuille devrait être libre d'ignorer toute métadonnée jugée inutile.

## Modification du consensus

_Une nouvelle section mensuelle résumant les propositions et discussions sur la modification des règles de consensus de Bitcoin._

- **Compact Isogeny PQC peut remplacer les portefeuilles HD, l'ajustement de clé, les silent payments** : Conduition a [écrit][c delving ibc
  hd] sur Delving Bitcoin à propos de ses recherches sur l'adéquation de la cryptographie basée sur les isogénies (IBC) comme système
  cryptographique [post-quantique][topic quantum resistance] pour Bitcoin. Alors que le problème du logarithme discret sur courbe elliptique
  (ECDLP) pourrait devenir non sécurisé dans un monde post-quantique, il n'y a rien de fondamentalement cassé dans les mathématiques des
  courbes elliptiques en général. Brièvement, une isogénie est une application d'une courbe elliptique vers une autre. L'hypothèse
  cryptographique de l'IBC est qu'il est difficile de calculer l'isogénie entre une courbe elliptique d'un type spécifique et une autre,
  alors qu'il est facile de produire une isogénie et la courbe vers laquelle elle applique depuis une courbe de base. Ainsi, les clés
  secrètes IBC sont des isogénies et les clés publiques sont les courbes obtenues.

  Comme avec les clés secrètes et publiques ECDLP, il est possible de calculer de nouvelles clés secrètes et de nouvelles clés publiques
  indépendamment à partir du même sel (par ex. une étape de [dérivation BIP32][topic bip32]) et que les clés secrètes résultantes signent
  correctement pour les clés publiques résultantes. Conduition appelle cela la « rerandomisation » et cela permet fondamentalement
  [BIP32][], [BIP341][] et [BIP352][] (avec probablement quelques innovations cryptographiques supplémentaires).

  À ce jour, il n'existe pas de protocoles d'agrégation de signatures pour l'IBC comme il en existe pour [MuSig][topic musig] et
  [FROST][topic threshold signature], et conduition lance un appel à l'action aux développeurs Bitcoin et cryptographes pour étudier ce qui
  pourrait être possible.

  Les clés et signatures dans les systèmes cryptographiques IBC connus font environ deux fois la taille des clés dans les systèmes
  cryptographiques dépendant de l'ECDLP. Bien plus petites que dans les systèmes cryptographiques basés sur le hachage ou sur les réseaux
  euclidiens. La vérification est coûteuse même sur des machines de bureau (de l'ordre de 1 milliseconde par vérification), dans la même
  gamme que les systèmes basés sur le hachage et sur les réseaux euclidiens.

- **Le budget varops et la feuille tapscript 0xc2 (alias "Script Restoration") sont les BIP 440 et 441** : Rusty Russell a [écrit][rr ml gsr
  bips] sur la liste de diffusion Bitcoin-Dev que les deux premiers BIP de la Great Script Restoration (ou Grand Script Renaissance) ont été
  soumis pour l'attribution d'un numéro BIP. Ils ont ensuite reçu les numéros BIP 440 et 441 respectivement. [BIP440][news374 varops] permet
  la restauration d'opcodes Script précédemment désactivés en construisant un système de comptabilité du coût de chaque opération qui
  garantit que le pire coût de validation de script au niveau d'un bloc ne peut pas dépasser le coût de validation d'un bloc contenant le
  pire nombre possible d'opérations de signature. [BIP441][news374 c2] décrit la validation d'une nouvelle version de [tapscript][topic
  tapscript] qui restaure les opcodes désactivés par Satoshi en 2010.

- **SHRIMPS : signatures post-quantiques de 2,5 Ko sur plusieurs appareils à état** : Jonas Nick [écrit][jn delving shrimps] sur Delving
  Bitcoin à propos d'une nouvelle construction de signature semi-étatique basée sur le hachage pour un Bitcoin post-quantique. SHRIMPS tire
  parti du fait que les tailles de signature [SPHINCS+][news383 sphincs] évoluent avec le nombre maximal de signatures pour une clé donnée
  qui peuvent être produites tout en conservant un niveau de sécurité donné.

  Semblable au design [SHRINCS][news391 shrincs], une clé SHRIMPS est composée de deux clés hachées ensemble. Dans ce cas, les deux clés
  sont des clés SPHINCS+ sans état, mais avec des jeux de paramètres différents. La première clé n'est sécurisée que pour un petit nombre de
  signatures et est destinée à être utilisée avec la première (ou les quelques premières) signatures de chaque appareil de signature avec
  lequel la clé est utilisée. La seconde clé est sécurisée pour un nombre bien plus important de signatures (effectivement illimité dans un
  contexte Bitcoin) et chaque appareil revient sur cette clé après un certain nombre (potentiellement choisi par l'utilisateur) de
  signatures depuis cet appareil. Il en résulte que, dans le cas d'usage courant de Bitcoin où une clé donnée (dont beaucoup peuvent être
  dérivées d'une seule graine) ne signe qu'un petit nombre de fois, presque toutes les signatures peuvent faire < 2,5 Ko tout en n'ayant
  toujours aucune limite effective sur le nombre total de signatures si une clé finit par être réutilisée de nombreuses fois, au prix de
  signatures plus tardives d'environ 7,5 Ko. SHRIMPS est semi-étatique dans le sens où aucun état global n'a besoin d'être conservé, mais
  chaque appareil de signature doit enregistrer quelques bits d' état pour chaque clé SHRIMPS avec laquelle il signe ((jusqu’à un seul bit
  seulement, si seule la première signature pour chaque couple appareil–clé bénéficie de la signature compacte).

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires. Veuillez envisager de mettre à niveau vers
les nouvelles versions ou d'aider à tester les versions candidates._

- [Bitcoin Core 31.0rc2][] est une version candidate pour la prochaine version majeure de l'implémentation de nœud complet prédominante. Un
  [guide de test][bcc31 testing] est disponible.

- [Core Lightning 26.04rc2][] est la plus récente version candidate pour la prochaine version majeure de ce nœud LN populaire, poursuivant
  les mises à jour du splicing et les corrections de bogues des versions candidates précédentes.

- [BTCPay Server 2.3.7][] est une version mineure de cette solution de paiement auto-hébergée qui fait migrer le projet vers .NET 10, ajoute
  des améliorations au passage en caisse des abonnements et des factures, ainsi que plusieurs autres améliorations et corrections de bogues.
  Les développeurs de plugins devraient suivre le [guide de migration .NET 10][btcpay net10] du projet lors de la mise à jour.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning
BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #32297][] ajoute une option `-ipcconnect` à `bitcoin-cli` afin qu'il puisse se connecter à une instance `bitcoin-node` et la
  contrôler via une communication inter-processus (IPC) sur un socket Unix au lieu de HTTP lorsque Bitcoin Core est compilé avec
  `ENABLE_IPC` et que le nœud est démarré avec `-ipcbind` (voir les bulletins [#320][news320 ipc] et [#369][news369 ipc]). Même lorsque
  `-ipcconnect` est omise, `bitcoin-cli` essaie d'abord l'IPC puis revient à HTTP si l'IPC n'est pas disponible. Cela fait partie du [projet
  de séparation multiprocessus][multiprocess].

- [Bitcoin Core #34379][] corrige un bogue où l'appel RPC `gethdkeys` (voir le [Bulletin #297][news297 rpc]) avec `private=true` échouait si le
  portefeuille contenait un [descripteur][topic descriptors] dont il possédait certaines clés privées mais pas toutes. Semblable au
  correctif pour `listdescriptors` (voir le [Bulletin #389][news389 descriptor]), cette PR renvoie les clés privées disponibles. Appeler
  `gethdkeys private=true` sur un portefeuille strictement en observation seule échoue toujours.

- [Eclair #3269][] ajoute la récupération automatique de liquidité depuis des canaux inactifs. Lorsque le `PeerScorer` détecte que le volume
  total de paiements d'un canal dans les deux directions tombe en dessous de 5 % de sa capacité, il réduit progressivement les [frais de
  relais][topic inbound forwarding fees] jusqu'au minimum configuré. Si les frais sont au minimum depuis au moins cinq jours et que le
  volume n'a toujours pas repris, Eclair ferme le canal lorsqu'il est redondant avec ce pair. Les canaux ne sont fermés que si le nœud
  détient au moins 25 % des fonds et que le solde local dépasse le paramètre existant `localBalanceClosingThreshold`.

- [LDK #4486][] fusionne le point de terminaison `rbf_channel` dans `splice_channel` comme point d'entrée unique à la fois pour les nouveaux
  [splices][topic splicing] et pour l'augmentation de frais d'un splice en cours. Lorsqu'un splice est déjà en cours, le `FundingTemplate`
  renvoyé par `splice_channel` contient `PriorContribution` afin que les utilisateurs puissent [RBF][topic rbf] le splice sans nouvelle
  [sélection de pièces][topic coin selection]. Voir le [Bulletin #397][news397 rbf] pour un comportement RBF de splice connexe.

- [LDK #4428][] ajoute la prise en charge de l'ouverture et de l'acceptation de canaux avec une réserve de canal nulle via une nouvelle
  méthode `create_channel_to_trusted_peer_0reserve` pour les pairs de confiance. Les canaux à réserve nulle permettent à la contrepartie de
  dépenser l'intégralité de son solde on-chain dans le canal. Cela est activé aussi bien pour les canaux utilisant des [anchor
  outputs][topic anchor outputs] que pour les canaux de commitment sans frais (voir le [Bulletin #371][news371 0fc]).

- [LND #9982][], [#10650][lnd #10650] et [#10693][lnd #10693] renforcent la gestion des nonce [MuSig2][topic musig] sur le réseau pour les
  canaux [taproot][topic taproot] : `ChannelReestablish` gagne un champ `LocalNonces` afin que les pairs puissent coordonner plusieurs nonce
  pour les mises à jour liées au [splicing][topic splicing], `lnwire` valide les nonce publics MuSig2 lors du décodage TLV pour les messages
  transportant des nonce, et le décodage de `LocalNoncesData` valide chaque entrée de nonce.

- [LND #10063][] étend le flux de fermeture coopérative [RBF][topic rbf] aux [canaux taproot simples][topic simple taproot channels] en
  utilisant [MuSig2][topic musig]. Les messages wire transportent des champs de nonce et de signature partielle spécifiques à
  [taproot][topic taproot], et la machine à états de fermeture utilise des sessions MuSig2 avec un modèle de nonce juste-à-temps à travers
  `shutdown`, `closing_complete` et `closing_sig` (voir le [Bulletin #347][news347 rbf coop] pour le contexte sur le flux de fermeture
  coopérative RBF).

{% include snippets/recap-ad.md when="2026-04-07 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2130,32297,34379,3269,4486,4428,9982,10650,10693,10063" %}

[topic payjoin]: /en/topics/payjoin/
[topic payjoin fingerprinting]: https://delvingbitcoin.org/t/how-wallet-fingerprints-damage-payjoin-privacy/2354
[c delving ibc hd]: https://delvingbitcoin.org/t/compact-isogeny-pqc-can-replace-hd-wallets-key-tweaking-silent-payments/2324
[rr ml gsr bips]: https://groups.google.com/g/bitcoindev/c/T8k47suwuOM
[news374 varops]: /fr/newsletters/2025/10/03/#brouillons-de-bip-pour-la-restauration-de-script
[news374 c2]: /fr/newsletters/2025/10/03/#brouillons-de-bip-pour-la-restauration-de-script
[jn delving shrimps]: https://delvingbitcoin.org/t/shrimps-2-5-kb-post-quantum-signatures-across-multiple-stateful-devices/2355
[news383 sphincs]: /en/newsletters/2025/12/05/#optimisations-de-signature-post-quantique-slh-dsa-sphincs
[news391 shrincs]: /en/newsletters/2026/02/06/#shrincs-signatures-post-quantiques-etatiques-de-324-octets-avec-sauvegardes-statiques
[wallet bip ml]: https://groups.google.com/g/bitcoindev/c/ylPeOnEIhO8
[news297 rpc]: /fr/newsletters/2024/04/10/#bitcoin-core-29130
[news320 ipc]: /fr/newsletters/2024/09/13/#bitcoin-core-30509
[news347 rbf coop]: /fr/newsletters/2025/03/28/#lnd-8453
[news369 ipc]: /fr/newsletters/2025/08/29/#bitcoin-core-31802
[news371 0fc]: /fr/newsletters/2025/09/12/#ldk-4053
[news389 descriptor]: /fr/newsletters/2026/01/23/#bitcoin-core-32471
[news397 rbf]: /fr/newsletters/2026/03/20/#ldk-4427
[multiprocess]: https://github.com/bitcoin/bitcoin/issues/28722
[bitcoin core 31.0rc2]: https://bitcoincore.org/bin/bitcoin-core-31.0/test.rc2/
[Core Lightning 26.04rc2]: https://github.com/ElementsProject/lightning/releases/tag/v26.04rc2
[BTCPay Server 2.3.7]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.3.7
[bcc31 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/31.0-Release-Candidate-Testing-Guide
[btcpay net10]: https://blog.btcpayserver.org/migrating-to-net10/
