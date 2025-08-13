---
title: 'Bulletin Hebdomadaire Bitcoin Optech #366'
permalink: /fr/newsletters/2025/08/08/
name: 2025-08-08-newsletter-fr
slug: 2025-08-08-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine annonce des BIPs en version draft pour Utreexo, résume la discussion
continue sur la baisse du taux minimal de frais de transaction pour la diffusion, et décrit une
proposition permettant aux nœuds de partager leurs modèles de bloc pour atténuer les problèmes liés
aux politiques divergentes de mempool. Sont également incluses nos sections régulières résumant une
réunion du Bitcoin Core PR Review Club, annonçant des mises à jour et des versions candidates,
et décrivant les changements notables dans les projets d'infrastructure Bitcoin populaires. Nous
incluons aussi une correction à la newsletter de la semaine dernière et une recommandation pour nos
lecteurs.

## Nouvelles

- **BIPs en version draft proposés pour Utreexo :** Calvin Kim a [publié][kim bips] sur la liste de
  diffusion Bitcoin-Dev pour annoncer trois BIPs en version draft co-écrits par lui-même avec Tadge
  Dryja et Davidson Souza sur le modèle de validation [Utreexo][topic utreexo]. Le [premier
  BIP][ubip1] spécifie la structure de l'accumulateur Utreexo, qui permet à un nœud de stocker un
  engagement facilement mis à jour pour l'ensemble complet des UTXO en "juste quelques kilo-octets".
  Le [deuxième BIP][ubip2] spécifie comment un nœud complet peut valider de nouveaux blocs et
  transactions en utilisant l'accumulateur plutôt qu'un ensemble traditionnel de sorties de
  transactions dépensées (STXOs, utilisées dans les premières versions de Bitcoin Core et actuellement
  dans libbitcoin) ou de sorties de transactions non dépensées (UTXOs, utilisées dans la version
  actuelle de Bitcoin Core). Le [troisième BIP][ubip3] spécifie les changements au protocole P2P
  Bitcoin qui permettent de transférer les données supplémentaires nécessaires pour la validation
  Utreexo.

  Les auteurs recherchent une revue conceptuelle et mettront à jour les BIPs en version draft basés
  sur les développements futurs.

- **Discussion continue sur la baisse du taux minimal de frais de diffusion :** Gloria Zhao a
  [posté][zhao minfee] sur Delving Bitcoin à propos de la baisse du [taux minimal de frais de
  diffusion par défaut][topic default minimum transaction relay feerates] de 90% à 0.1 sat/vbyte. Elle
  a encouragé une discussion conceptuelle sur l'idée et son impact potentiel sur d'autres logiciels.
  Pour les préoccupations spécifiques à Bitcoin Core, elle a renvoyé à une [PR][bitcoin
  core #33106].

- **Partage de modèle de bloc entre pairs pour atténuer les problèmes liés aux politiques de mempool divergentes :**
  Anthony Towns a [posté][towns tempshare] sur Delving Bitcoin pour suggérer que les
  pairs de nœuds complets s'envoient occasionnellement leur modèle actuel pour le prochain bloc en
  utilisant l'encodage [compact block relay][topic compact block relay]. Le pair récepteur pourrait
  alors demander toutes les transactions du modèle qu'il lui manque, les ajoutant soit au mempool
  local soit les stockant dans un cache. Cela permettrait aux pairs avec des politiques de mempool
  divergentes de partager des transactions malgré leurs différences. Cela offre une alternative à une
  proposition précédente qui suggérait l'utilisation de _weak blocks_ (voir le [Bulletin #299][news299
  weak blocks]). Towns a publié une [implémentation de preuve de concept][towns tempshare poc].

## Bitcoin Core PR Review Club

*Dans cette section mensuelle, nous résumons une récente réunion du [Bitcoin Core PR Review Club][],
en soulignant certaines des questions et réponses importantes. Cliquez sur une question ci-dessous
pour voir un résumé de la réponse de la réunion.*

[Ajouter l'exportwatchonlywallet RPC pour exporter une version watch-only d'un portefeuille][review
club 32489] est une PR par [achow101][gh achow101] qui réduit la quantité de travail manuel
nécessaire pour créer un portefeuille watch-only. Avant ce changement, les utilisateurs devaient le
faire en tapant ou en scriptant des appels RPC `importdescriptors`, en copiant des étiquettes
d'adresse, etc.

Outre les [descriptors][topic descriptors] publics, l'exportation contient également :
- des caches contenant des xpubs dérivés lorsque nécessaire, par exemple, en cas de chemins de
  dérivation durcis
- des entrées de carnet d'adresses, des drapeaux de portefeuille et des étiquettes utilisateur
- toutes les transactions historiques du portefeuille afin que les rescans ne soient pas nécessaires

La base de données du portefeuille exporté peut ensuite être importée avec le RPC `restorewallet`.


{% include functions/details-list.md
  q0="Pourquoi les informations existantes `IsRange()`/`IsSingleType()` ne peuvent-elles pas nous dire
  si un descripteur peut être étendu du côté watch-only ? Expliquez la logique derrière
  `CanSelfExpand()` pour a) un chemin `wpkh(xpub/0h/*)` durci et b) un descripteur `pkh(pubkey)`."
  a0="`IsRange()` et `IsSingleType()` étaient insuffisants car ils ne vérifient pas la dérivation
  durcie, qui nécessite des clés privées indisponibles dans un portefeuille watch-only.
  `CanSelfExpand()` a été ajouté pour rechercher de manière récursive des chemins durcis ; s'il en
  trouve un, il retourne `false`, signalant qu'un cache pré-rempli doit être exporté pour que le
  portefeuille watch-only puisse dériver des adresses. Un descripteur `pkh(pubkey)` n'est pas étendu
  et n'a pas de dérivation, donc il peut toujours s'auto-étendre."
  a0link="https://bitcoincore.reviews/32489#l-27"

  q1="`ExportWatchOnlyWallet` ne copie le cache du descripteur que si `!desc->CanSelfExpand()`. Que
  contient exactement ce cache ? Comment un cache incomplet pourrait-il affecter la dérivation
  d'adresse sur le portefeuille watch-only ?"
  a1="Le cache stocke des objets `CExtPubKey` pour les descripteurs avec des chemins de dérivation
  durcis, qui sont pré-dérivés sur le portefeuille dépensier. Si ce cache est incomplet, le
  portefeuille watch-only ne peut pas dériver les adresses manquantes car il manque les clés privées
  nécessaires. Cela l'empêcherait de voir les transactions envoyées à ces adresses, conduisant à un
  solde incorrect."
  a1link="https://bitcoincore.reviews/32489#l-52"

  q2="L'exportateur définit `create_flags = GetWalletFlags() | WALLET_FLAG_DISABLE_PRIVATE_KEYS`.
  Pourquoi est-il important de préserver les drapeaux originaux (par exemple, `AVOID_REUSE`) au lieu
  de tout effacer et de recommencer à zéro ?"
  a2="Préserver les drapeaux assure une cohérence comportementale entre les portefeuilles dépensier et
  watch-only. Par exemple, le drapeau `AVOID_REUSE` affecte quelles pièces sont considérées
  disponibles pour dépenser. Ne pas le préserver ferait que le portefeuille watch-only signalerait un
  solde disponible différent de celui du portefeuille principal, conduisant à une confusion pour
  l'utilisateur."
  a2link="https://bitcoincore.reviews/32489#l-68"

  q3="Pourquoi l'exportateur lit-il le localisateur depuis le portefeuille source et
  le copie-t-il tel quel dans le nouveau portefeuille au lieu de laisser le nouveau
  portefeuille démarrer à partir du bloc 0 ?"
  a3="Le localisateur de bloc est copié afin d'indiquer au nouveau portefeuille en lecture seule
  où reprendre l'analyse de la blockchain pour les nouvelles transactions,
  évitant ainsi la nécessité d'une nouvelle analyse complète."
  a3link="https://bitcoincore.reviews/32489#l-93"

  q4="Considérons un descripteur multisig `wsh(multi(2,xpub1,xpub2))`. Si l'un des
  cosignataires exporte un portefeuille en lecture seule et le partage avec un tiers,
  quelles nouvelles informations ce tiers obtient-il par rapport au simple fait de
  lui fournir les chaînes de descripteurs ?"
  a4="Les données du portefeuille en lecture seule comprennent des métadonnées supplémentaires telles que le
  carnet d'adresses, les indicateurs du portefeuille et les étiquettes de contrôle des pièces. Pour les portefeuilles avec une
  dérivation renforcée, le tiers ne peut obtenir que des informations sur les
  transactions historiques et futures via l'exportation du portefeuille en lecture seule."
  a4link="https://bitcoincore.reviews/32489#l-100"

  q5="Dans `wallet_exported_watchonly.py`, pourquoi le test appelle-t-il
  `wallet.keypoolrefill(100)` avant de vérifier la dépensabilité sur la
  paire en ligne/hors ligne ?"
  a5="L'appel `keypoolrefill(100)` force le portefeuille hors ligne (de dépense)
  à dériver au préalable 100 clés pour ses descripteurs renforcés, remplissant ainsi son
  cache. Ce cache est ensuite inclus dans l'exportation, ce qui permet au portefeuille en ligne
  en lecture seule de générer ces 100 adresses. Il garantit également que le
  portefeuille hors ligne reconnaîtra ces adresses lorsqu'il recevra un PSBT à signer."
  a5link="https://bitcoincore.reviews/32489#l-122"
%}

## Optech recommande

[Bitcoin++ Insider][] a commencé à publier des nouvelles financées par les lecteurs sur des sujets
techniques liés à Bitcoin. Deux de leurs bulletins hebdomadaires gratuits, _Last Week in Bitcoin_ et
_This Week in Bitcoin Core_, pourraient particulièrement intéresser les lecteurs réguliers de la
newsletter Optech.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates._

- [LND v0.19.3-beta.rc1][] est un candidat à la sortie pour une version de maintenance de cette
  implémentation populaire de nœud LN contenant "des corrections de bugs importants". Plus
  notablement, "une migration optionnelle [...] réduit significativement les besoins en disque et en
  mémoire pour les nœuds."

- [BTCPay Server 2.2.0][] est une sortie de cette solution de paiement auto-hébergée populaire. Elle
  ajoute le support pour les politiques de portefeuille et [miniscript][topic miniscript], fournit un
  support supplémentaire pour la gestion et le suivi des frais de transaction, et inclut plusieurs
  autres nouvelles améliorations et corrections de bugs.

- [Bitcoin Core 29.1rc1][] est un candidat à la sortie pour une version de maintenance du logiciel
  de nœud complet prédominant.

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration de Bitcoin (BIPs)][bips
repo], [Lightning BOLTs][bolts repo],_
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo].

- [Bitcoin Core #32941][] complète la révision de `TxOrphanage` (voir le [Bulletin #364][news364
  orphan]) en activant la réduction automatique de l'orphelinat lorsque ses limites sont dépassées. Il
  ajoute un avertissement pour les utilisateurs de `maxorphantx` pour les informer qu'il est obsolète.
  Ce PR consolide le relais de paquets opportuniste un-parent-un-enfant (1p1c) [package relay][topic
  package relay].

- [Bitcoin Core #31385][] assouplit la règle `package-not-child-with-unconfirmed-parents` de la RPC
  `submitpackage` pour améliorer l'utilisation du relais de paquets 1p1c [package relay][topic package
  relay]. Les paquets n'ont plus besoin d'inclure les parents qui sont déjà dans le mempool du nœud.

- [Bitcoin Core #31244][] implémente l'analyse des [descripteurs][topic descriptors] [MuSig2][topic
  musig] tels que définis dans [BIP390][], ce qui est nécessaire pour recevoir et dépenser des entrées
  d'adresses [taproot][topic taproot] avec des clés agrégées MuSig2.

- [Bitcoin Core #30635][] commence à afficher les RPC `waitfornewblock`, `waitforblock`, et
  `waitforblockheight` dans la réponse de la commande d'aide, indiquant qu'ils sont destinés aux
  utilisateurs réguliers. Ce PR ajoute également un argument `current_tip` optionnel à la RPC
  `waitfornewblock`, pour atténuer les conditions de concurrence en spécifiant le hash du bloc de la
  pointe actuelle de la chaîne.

- [Bitcoin Core #28944][] ajoute une protection anti-[fee sniping][topic fee sniping] aux
  transactions envoyées avec les commandes RPC `send` et `sendall` en ajoutant un [locktime][topic
  timelocks] aléatoire relatif au tip si un n'est pas déjà spécifié.

- [Eclair #3133][] étend son système de réputation locale des pairs pour l'[endorsement HTLC][topic
  htlc endorsement] (voir le [Bulletin #363][news363 reputation]) pour évaluer la réputation des pairs
  sortants, tout comme pour les pairs entrants. Eclair considérerait désormais une bonne réputation
  dans les deux directions lors du transfert d'un HTLC, mais n'implémente pas encore de pénalités.
  Évaluer les pairs sortants est nécessaire pour prévenir les attaques par évier (voir le [Bulletin
  #322][news322 sink]), un type spécifique d'[attaque de blocage de canal][topic channel jamming
  attacks].

- [LND #10097][] introduit une file d'attente asynchrone, par pair, pour les demandes de
  [gossip][topic channel announcements] en attente (`GossipTimestampRange`) pour éliminer le risque de
  blocages lorsque un pair envoie trop de demandes à la fois. Si un pair envoie une demande avant que
  la précédente ne soit terminée, le message supplémentaire est discrètement ignoré. Un nouveau
  paramètre `gossip.filter-concurrency` (valeur par défaut 5) est ajouté pour limiter le nombre de
  travailleurs concurrents pour tous les pairs. Le PR ajoute également de la documentation expliquant
  comment fonctionnent tous les paramètres de configuration de limitation de taux pour le gossip.

- [LND #9625][] ajoute une commande RPC `deletecanceledinvoice` (et son équivalent `lncli`) qui
  permet aux utilisateurs de supprimer les factures [BOLT11][] annulées (voir le [Bulletin #33][news33
  canceled]) en fournissant leur hash de paiement.

- [Rust Bitcoin #4730][] ajoute un type `Alert` enveloppe pour l'[alerte finale][]
  message qui notifie les pairs utilisant une version vulnérable de Bitcoin Core (avant la version
  0.12.1) que leur système d'alerte est non sécurisé. Satoshi a introduit le système d'alerte pour
  notifier les utilisateurs d'événements significatifs du réseau, mais il a été [retiré][] dans la
  version 0.12.1, à l'exception du message d'alerte final.

- [BLIPs #55][] ajoute [BLIP55][] pour spécifier comment les clients mobiles peuvent s'inscrire pour
  des webhooks via un point d'accès pour recevoir des notifications push d'un LSP. Ce protocole est
  utile pour les clients afin d'être notifiés lors de la réception d'un [paiement asynchrone][topic
  async payments], et a récemment été implémenté dans LDK (Voir le [Bulletin #365][news365 webhook]).

## Correction

Dans [le bulletin de la semaine dernière][news365 p2qrh], nous avons incorrectement décrit la
version mise à jour de [BIP360][], _pay to quantum-resistant hash_, comme "faisant exactement le
changement" que Tim Ruffing a montré être sécurisé dans son [article récent][ruffing paper]. Ce que
BIP360 fait réellement, c'est remplacer l'engagement de courbe elliptique envers une racine de
merkle basée sur SHA256 (plus une alternative de chemin de clé) par un engagement SHA256 directement
envers la racine de merkle. L'article de Ruffing a montré que taproot, tel qu'utilisé actuellement,
est sécurisé si un schéma de signature résistant aux quantiques était ajouté au langage
[tapscript][topic tapscript] et que les dépenses de chemin de clé étaient désactivées. BIP360 exige
à la place que les portefeuilles passent à une variante de taproot (quoique, une variante triviale),
élimine le mécanisme de chemin de clé de sa variante, et décrit l'ajout d'un schéma de signature
résistant aux quantiques au langage de script utilisé dans ses tapleaves. Bien que l'article de
Ruffing ne s'applique pas à la variante de taproot proposée dans BIP360, la sécurité de cette
variante (vue comme un engagement) découle immédiatement de la sécurité de l'arbre de merkle.

Nous nous excusons pour l'erreur et remercions Tim Ruffing de nous avoir informés de notre erreur.

{% include snippets/recap-ad.md when="2025-08-12 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33106,32941,31385,31244,30635,28944,3133,10097,9625,4730,55" %}
[bitcoin core 29.1rc1]: https://bitcoincore.org/bin/bitcoin-core-29.1/
[bitcoin++ insider]: https://insider.btcpp.dev/
[news365 p2qrh]: /en/newsletters/2025/08/01/#security-against-quantum-computers-with-taproot-as-a-commitment-scheme
[zhao minfee]: https://delvingbitcoin.org/t/changing-the-minimum-relay-feerate/1886/
[towns tempshare]: https://delvingbitcoin.org/t/sharing-block-templates/1906
[towns tempshare poc]: https://github.com/ajtowns/bitcoin/commit/ee12518a4a5e8932175ee57c8f1ad116f675d089
[news299 weak blocks]: /fr/newsletters/2024/04/24/#implementation-de-preuve-de-concept-pour-les-blocs-faibles
[ruffing paper]: https://eprint.iacr.org/2025/1307
[kim bips]: https://mailing-list.bitcoindevs.xyz/bitcoindev/3452b63c-ff2b-4dd9-90ee-83fd9cedcf4an@googlegroups.com/
[ubip1]: https://github.com/utreexo/biptreexo/blob/7ae65222ba82423c1a3f2edd6396c0e32679aa37/utreexo-accumulator-bip.md
[ubip2]: https://github.com/utreexo/biptreexo/blob/7ae65222ba82423c1a3f2edd6396c0e32679aa37/utreexo-validation-bip.md
[ubip3]: https://github.com/utreexo/biptreexo/blob/7ae65222ba82423c1a3f2edd6396c0e32679aa37/utreexo-p2p-bip.md
[btcpay server 2.2.0]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.2.0
[lnd v0.19.3-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.3-beta.rc1
[review club 32489]: https://bitcoincore.reviews/32489
[gh achow101]: https://github.com/achow101
[news363 reputation]: /fr/newsletters/2025/07/18/#eclair-2716
[news322 sink]: /fr/newsletters/2024/09/27/#tests-et-changements-de-mitigation-du-brouillage-hybride
[news33 canceled]: /en/newsletters/2019/02/12/#lnd-2457
[alerte finale]: https://bitcoin.org/en/release/v0.14.0#final-alert
[retiré]: https://bitcoin.org/en/alert/2016-11-01-alert-retirement#updates
[news365 webhook]: /en/newsletters/2025/08/01/#ldk-3662
[news364 orphan]: /fr/newsletters/2025/07/25/#bitcoin-core-31829