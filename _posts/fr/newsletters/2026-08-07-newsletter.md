---
title: 'Bulletin Hebdomadaire Bitcoin Optech #417'
permalink: /fr/newsletters/2026/08/07/
name: 2026-08-07-newsletter-fr
slug: 2026-08-07-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit une ébauche de BIP pour relayer les pointes de blocs périmées entre pairs. Sont également incluses nos
sections régulières résumant les propositions et discussions sur la modification des règles de consensus de Bitcoin, annonçant de nouvelles
versions et versions candidates, et décrivant des changements notables dans des logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

- **Ébauche de BIP pour le relais des pointes périmées** : Ram et w0xlt ont [publié][stale tip ml] sur la liste de diffusion Bitcoin-Dev à
  propos de la proposition d'un message P2P optionnel pour relayer les pointes périmées entre pairs. Actuellement, le taux de blocs périmés
  est une métrique difficile à surveiller, puisque les blocs périmés cessent de se propager dès que la chaîne gagnante est relayée.
  Cependant, c'est un signal utile pour vérifier l'état de santé du réseau. Des changements dans le taux de blocs périmés peuvent révéler
  des goulots d'étranglement de validation ou de relais, des partitions réseau, ou un comportement de [minage égoïste][topic selfish
  mining].

  Le [BIP][stale tip bip] proposé définit un nouveau message, appelé `staletip`, pour annoncer aux pairs les pointes récentes de chaînes
  périmées. Le message lui-même contient la hauteur de bloc à laquelle une branche périmée diverge (le point de bifurcation), un vecteur
  contenant les en-têtes de blocs appartenant à la branche périmée, et un drapeau signalant la volonté de servir les données de ces blocs.
  Un nœud ne devrait envoyer ce message qu'après la négociation [BIP434][] avec ses pairs (voir le [Bulletin #386][news386 bip434]).

  Les auteurs attendent les retours d'autres développeurs. En attendant, une [preuve de concept][stale tip poc] pour la proposition est déjà
  disponible.

## Modification du consensus

_Une nouvelle section mensuelle résumant les propositions et discussions sur la modification des règles de consensus de Bitcoin._

- **CISA pour les dépenses keypath taproot (BIP460)** : Fabian Jahr a [publié][fj ml cisa] sur la liste de diffusion Bitcoin-Dev une ébauche
  de BIP460 ([BIPs #2212][]) pour l'[agrégation de signatures inter-entrées (CISA)][topic cisa] à l'échelle de la transaction pour les
  dépenses keypath de style [taproot][topic taproot]. La proposition introduit une nouvelle version de témoin (v2) dont les dépenses keypath
  reproduisent [BIP341][] sauf que le témoin de chaque entrée commence par un octet marqueur sélectionnant une demi-agrégation (BIP458/[BIPs
  #2205][]), une agrégation complète (BIP459/[BIPs #2210][]), ou un refus explicite transportant une signature [schnorr][topic schnorr
  signatures] standard [BIP340][]. La demi-agrégation compresse de manière non interactive de nombreuses signatures de 64 octets à 32 octets
  chacune plus une unique partie agrégée de 32 octets (voir le [Bulletin #208][news208 halfagg]) ; l'agrégation complète les réduit à une
  seule signature agrégée de 64 octets avec une signature interactive (voir le [Bulletin #415][news415 dahlias]). Les dépenses scriptpath
  suivent BIP341/BIP342 sans changement et ne sont pas agrégées, préservant le chemin de mise à niveau `OP_SUCCESS`. Les signatures dans le
  schéma proposé s'engagent sur le mode d'agrégation, de sorte que l'agrégation est optionnelle : des tiers ne peuvent pas intégrer une
  signature ayant refusé dans un groupe de demi-agrégation. Jahr note que la version de témoin entre en conflit avec [BIP360][] (P2MR) ; des
  examinateurs (y compris Mark Erhardt) s'attendent à ce que la proposition qui s'active en premier prenne la prochaine version libre.

  Conduition a [demandé][c ml cisa] comment CISA s'articule avec la migration [post-quantique][topic quantum resistance] : l'agrégation
  nécessite des clés publiques EC nues pour la vérification, donc associer CISA avec [P2TRv2][news403 pqout] maximise les économies de frais
  (aussi peu que 1 octet de témoin par entrée entièrement agrégée) mais hérite du problème de calendrier de désactivation de l'EC de P2TRv2,
  tandis que hacher la clé (P2MR ou P2TRH) coûte approximativement 32 à 65 unités de poids par entrée et réduit les économies. Jahr a
  [répondu][fj ml cisa conduition] que le cadre marqueur/groupe au niveau de la transaction devrait se généraliser à de futurs schémas
  agrégeables et qu'une variante de CISA avec hachage masquant la clé pourrait être spécifiée comme un type de sortie séparé partageant
  l'essentiel de la logique. Adam Gibson (waxwing) a [remis en question][ag ml cisa] la limite d'un seul groupe par schéma lorsque plusieurs
  utilisateurs souhaitent chacun une agrégation complète de seulement leurs propres entrées au sein d'une transaction partagée. Jahr a
  [répondu][fj ml cisa waxwing] que plusieurs groupes restent envisageables si les examinateurs voient des cas d'usage concrets.

- **Engagement segwit vers des données de témoin post-quantiques** : Pieter Wuille a [publié][pw delving pqwit] sur Delving Bitcoin une
  conception permettant d'attacher des données de témoin [post-quantiques][topic quantum resistance] sans répéter tous les coûts de
  déploiement de [segwit][topic segwit]. Une seconde zone de témoin naïve nécessiterait un nouvel identifiant de transaction (`pqwtxid`), un
  engagement coinbase vers ces identifiants, des changements de la pile de minage, et une logique P2P suivant trois identifiants.
  L'alternative de Wuille engage les données de témoin étendues de chaque entrée depuis le témoin actuel de l'entrée, de sorte que le wtxid
  couvre les données supplémentaires. Une version détaillée introduit des « styles » de témoin par entrée (0 = segwit, 1 = pqdata, 2+ pour
  de futures extensions), chacun avec sa propre extension P2P et sa propre fonction de poids. Les styles non pris en charge peuvent être
  représentés par un engagement valide de style 0 pour la compatibilité avec les nœuds non mis à niveau. Anthony Towns a comparé les styles
  à des formules distinctes de poids d'autorisation, a suggéré des engagements fondés sur l'annexe afin que des assertions de type locktime
  restent disponibles sans les données supplémentaires, et a soutenu que la capacité réservée aux signatures post-quantiques devrait rester
  inutilisable pour des données ordinaires afin que les blocs d'avant le Q-day ne gonflent pas vers une cible plus grande. Wuille a convenu
  qu'introduire un style reste encore une mise à niveau combinée de soft fork, de stockage et de P2P, mais sans nouvel identifiant de
  transaction.

- **Discussion sur les types de sortie PQC** : Pieter Wuille a [ouvert][pw delving pqout] un fil Delving Bitcoin pour centraliser la
  discussion sur les types de sortie [post-quantiques][topic quantum resistance]. Il a dressé un tableau des candidats, dont [BIP360][]
  (P2MR), [P2TRv2][news403 pqout], P2TRH (semblable à taproot avec une clé de sortie hachée et récupération de clé publique, voir le
  [Bulletin #412][news412 pkr]), et P2QR (P2MR avec les opcodes EC désactivés dès le départ), ainsi que des variations de ceux-ci. Sa
  préférence actuelle est de déployer à la fois P2TRv2 (avec [tripwire/verrouillage des mineurs][news412 p2xx] et un [opcode PQC fondé sur
  le hachage][news386 jn hash]) pour une migration facile avant le Q-day qui conserve le profil de frais actuel, et un type à plus long
  terme fondé sur P2MR avec un nouveau style de témoin afin que les coûts EC et PQC puissent être tarifés indépendamment après la migration.
  Des mesures sur regtest par jeanpablojp ont [montré][jp delving pqout] que les dépenses BIP360 nécessitent ~96 lignes de delta de
  consensus par rapport à la machinerie taproot existante, avec une feuille schnorr de profondeur 1 environ 32 octets plus légère que le
  scriptpath P2TR équivalent. Conduition a noté que la proposition CISA de Jahr (ci-dessus) rend P2TRv2+CISA extrêmement attractif pour une
  migration volontaire, mais augmente les enjeux d'un soft fork ultérieur désactivant l'EC, et a indiqué que l'agrégation PQ-SNARK à
  l'échelle du bloc de signatures fondées sur le hachage constitue une piste de recherche qui pourrait rendre les dépenses post-quantiques
  compétitives en frais.

- **Expiration de transaction déclenchée par entrée** : Josh Doman a [publié][jd delving expire htlc] sur Delving Bitcoin une construction
  pour faire expirer les [HTLC][topic htlc] sans [relais gratuit][topic free relay], puis l'a généralisée dans un suivi sur l'[expiration de
  transaction déclenchée par entrée][jd delving input expiry]. Les propositions d'expiration absolue telles que [`OP_EXPIRE`][news274
  expire] de Peter Todd rendent invalide plus tard une transaction valide, permettant un spam de relais bon marché à moins que la politique
  n'exige des frais proches du prochain bloc. L'approche de Doman fait au contraire expirer une dépense lorsque la transaction créant l'UTXO
  qu'elle dépense a été confirmée trop tard : si le `nSequence` de [BIP68][] impose un verrou temporel relatif fondé sur la hauteur R et que
  le bit 21 est positionné, l'entrée échoue à la validation à moins que `nLockTime` ne soit fondé sur la hauteur et au moins égal à la
  hauteur minimale d'inclusion BIP68. Comme un parent miné ne peut pas devenir invalide sans réorganisation profonde, un enfant valide une
  fois ne peut pas expirer dans des conditions normales de progression, ce qui élimine le relais gratuit. Les cas d'usage comprennent le
  transfert HTLC sans mempool (surveillance du préimage via le chainstate plutôt que le mempool local, utile pour les nœuds à faible bande
  passante ou de type [Utreexo][topic utreexo]) et des [timelocks][topic timelocks] relatifs pseudo contractuels pour [LN-Symmetry][topic
  eltoo]. Des modifications complémentaires facultatives imposent le bit 21 dans `OP_CSV` et ajoutent un opcode d'introspection tapscript
  `OP_LOCKTIME` afin que les scripts puissent exiger un locktime maximal. Anthony Towns a comparé l'idée à l'introspection de hauteur de
  pièce via `OP_TX` et a mis en doute la nécessité du délai minimal de 100 blocs (choisi pour correspondre à la maturité des coinbase et à
  la proposition de Todd) ; Doman a ensuite convenu qu'un délai bien plus faible pourrait suffire et a reformulé la primitive comme une
  manière pour les utilisateurs d'affirmer « maintenant » (confirmations d'entrée par `nLockTime`) qui peut également accroître le coût des
  réorganisations profondes après la subvention.

- **Récupération quantique en couches des adresses hachées** : Shinobi a [publié][shinobi ml qr] sur la liste de diffusion Bitcoin-Dev et a
  [cross-posté][shinobi delving qr] sur Delving Bitcoin un plan de récupération en couches pour les pièces sécurisées par des types
  d'adresses hachées (P2PKH, P2SH, P2WPKH, P2WSH, et constructions analogues) si les dépenses secp256k1 étaient plus tard restreintes en
  raison de l'existence d'un [ordinateur quantique cryptographiquement pertinent][topic quantum resistance]. Aucun mécanisme de récupération
  unique ne couvre toutes les méthodes de génération de clés : les preuves hiérarchiques [BIP32][] (récemment [démontrées][news403
  pqrecovery] par Osuntokun) manquent les clés non hiérarchiques ; les attestations horodatées avec état avant l'échéance ne couvrent pas
  les utilisateurs inactifs ; et la migration commit-reveal échoue lorsque les clés publiques sont déjà exposées. Permettre à n'importe
  quelle méthode de récupération d'autoriser une dépense après la désactivation de secp256k1 couvrirait, sous l'hypothèse que les clés
  publiques et les scriptpaths internes restent secrets, essentiellement tous les détenteurs d'adresses hachées qui contrôlent encore leurs
  clés. Pour faciliter cela à l'avenir, Shinobi suggère que les portefeuilles utilisent de nouveaux chemins de dérivation et des requêtes de
  solde par adresse de style Electrum afin d'éviter de divulguer des xpub aux fournisseurs de services. Conduition a reformulé la
  récupération comme l'authentification d'asymétries de connaissance existantes dont un attaquant quantique ne dispose pas : les scripts
  hachés et les seeds BIP32 sont de telles asymétries. Il a souligné que certains UTXOs (notamment de nombreuses premières pièces P2PK)
  n'ont pas une telle asymétrie, de sorte qu'une action avant l'échéance pour en créer une est le seul moyen de distinguer leurs
  propriétaires d'un attaquant. Il a également noté que les clés internes taproot peuvent servir d'asymétrie de connaissance pour la
  récupération keypath P2TR, séparément de la superposition des adresses hachées.

- **Ébauche de BIP Segregated Data (SegData)** : MrHash a [publié][mh delving segdata] sur Delving Bitcoin des ébauches de BIP
  complémentaires pour Segregated Data, un soft fork qui ajouterait une région de bloc élagable et isolée des scripts pour transporter des
  données arbitraires. Les entrées seraient engagées via une racine de merkle coinbase (de style [BIP141][]) , comptées avec la remise
  witness, et liées aux transactions par des sorties de référence witness v2 non dépensables de valeur zéro exclues de l'ensemble UTXO.
  Aucun opcode ne peut lire le contenu des entrées, ce qui les maintient élagables et incapables de conditionner des dépenses, et au-delà
  d'une fenêtre de rétention les nœuds pourraient valider à partir de la seule sérialisation de base. L'objectif est de donner aux données
  que les scripts n'ont pas besoin d'évaluer (blobs d'application, attestations) un foyer structurel afin qu'elles quittent `OP_RETURN` et
  le bourrage de witness, sans modifier ces vecteurs existants. Antoine Poinsot et Pieter Wuille ont soutenu que si les nœuds complets n'ont
  pas besoin de conserver la charge utile pour accepter un bloc, alors les données ne font pas partie du consensus de Bitcoin dans un sens
  significatif et reviennent à payer des frais pour gonfler le poids. Mark Erhardt a demandé pourquoi les intégrateurs préféreraient une
  disponibilité réduite au même coût que des données witness. Après qu'Anthony Towns a décrit les risques de réorganisation issus de règles
  de présence dépendantes de la profondeur, MrHash s'est réorienté vers une vérification de consensus du seul poids/longueur engagé, avec
  validation de la charge utile en tant que politique. L'ébauche reste ouverte ; l'allocation de version witness entre aussi en conflit avec
  les discussions BIP360 et BIP460 ci-dessus.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires. Veuillez envisager de mettre à niveau vers
les nouvelles versions ou d'aider à tester les versions candidates._

- [Libsecp256k1 0.8.0][] est une version de cette bibliothèque pour les opérations cryptographiques liées à Bitcoin. Elle ajoute le module
  [silent payments][topic silent payments] [BIP352][] décrit dans le [Bulletin #415][news415 silent], permet aux applications de fournir des
  implémentations de compression SHA256 optimisées matériellement comme décrit dans le [Bulletin #396][news396 sha256], et améliore
  l'arithmétique de champ 64 bits, produisant des accélérations de vérification de signatures allant jusqu'à environ 11 % dans certaines
  compilations GCC et MSVC. Elle retire également les symboles obsolètes `secp256k1_schnorrsig_sign` et `secp256k1_context_no_precomp`.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning
BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #35501][] met à jour le portefeuille afin de stocker plusieurs variantes witness de la même transaction. Auparavant, une
  fois que le portefeuille connaissait une transaction avec un txid donné, il ignorait généralement une autre transaction avec le même txid
  mais un wtxid différent. Désormais, le portefeuille stocke chaque variante dans un enregistrement de base de données `wtxvariant` distinct
  et en sélectionne une comme canonique. La préférence est donnée à une variante confirmée, sinon à une variante contenant des données
  witness puis à une variante avec le poids le plus faible. La variante canonique reste dans l'enregistrement `tx` existant. Les RPC
  `gettransaction`, `listtransactions`, et `listsinceblock` signalent désormais les variantes non canoniques dans un nouveau champ
  `alternate_wtxids`. Voir les Bulletins [#193][news193 wtxid] et [#304][news304 wtxid] pour des références précédentes aux transactions
  ayant le même txid mais des wtxid différents.

- [Core Lightning #9298][] fait progresser la migration vers `bwatch`, un plugin expérimental de surveillance de blockchain destiné à
  déplacer l'interrogation des blocs et le filtrage des transactions hors de `lightningd`. Cette PR déplace le suivi des transactions du
  portefeuille et des UTXO vers ce système en ajoutant les tables `our_outputs` et `our_txs`, en les remplissant à partir des tables
  existantes du portefeuille, et en basculant les lectures du portefeuille vers les nouvelles tables. Avec `--experimental-bwatch` activé,
  les surveillances de scriptPubKey détectent quand des fonds sont reçus et les surveillances d'outpoint détectent quand des sorties du
  portefeuille sont dépensées, y compris la gestion des réorganisations. Les écritures sont temporairement dupliquées dans les tables
  historiques `outputs` et `transactions` pour permettre aux utilisateurs de rétrograder sans avoir besoin de rescanner.

- [Core Lightning #9353][] fait en sorte que `sendpay` renvoie une erreur RPC lorsque la charge utile combinée par saut pour une route
  fournie ne peut pas tenir dans le champ `hop_payloads` de 1 300 octets d'un paquet onion défini par [BOLT4][]. Auparavant, la construction
  de l'onion renvoyait un résultat nul que `sendpay` transmettait sans vérification au code d'envoi, provoquant un plantage de `lightningd`.
  Ce problème a été observé avec une route de 25 sauts générée par un plugin de rééquilibrage. Cependant, la limite réelle de route dépend
  de la taille des charges utiles encodées pour chaque saut plutôt que du seul nombre de sauts.

- [Eclair #3336][] empêche que des messages de règlement [HTLC][topic htlc] en double reçus d'un pair soient ajoutés plusieurs fois aux
  changements de commitment distant proposés. Auparavant, un pair ou une file locale de messages pouvait livrer plus d'une fois le même
  message `update_fulfill_htlc`, `update_fail_htlc`, ou `update_fail_malformed_htlc`, amenant Eclair à stocker des changements de commitment
  en double et potentiellement à forcer la fermeture du canal lorsque les pairs échangeaient ensuite des messages `commit_sig`.

- [LND #10942][] ajoute la prise en charge du transfert d'un [HTLC][topic htlc] sur un [chemin de paiement aveuglé][topic rv routing]
  lorsque les données chiffrées du destinataire identifient le saut suivant en utilisant `next_node_id` plutôt que `short_channel_id`
  (SCID). Ce problème a été observé dans un paiement [BOLT12][topic offers] de Core Lightning, où LND était le nœud d'introduction dans le
  chemin aveuglé du destinataire. CLN utilisait la forme `next_node_id` permise par [BOLT4][], mais le code de transfert HTLC de LND
  exigeait un SCID, ce qui faisait échouer le paiement. LND résout désormais l'identifiant de nœud vers l'un de ses canaux utilisables avec
  ce pair en utilisant sa logique existante de transfert non strict, qui prend également en charge les canaux privés et alias.

- [LND #10992][] borne la mémoire utilisée lors de la synchronisation des [annonces de canaux][topic channel announcements] en limitant le
  nombre de short channel IDs (SCIDs) acceptés dans la réponse `reply_channel_range` de [BOLT7][] à une requête `query_channel_range`.
  Auparavant, des réponses compressées pouvaient amener LND à décoder et mettre en mémoire tampon un nombre imprévisible de SCIDs à travers
  un ou plusieurs messages `reply_channel_range`. Désormais, LND accepte un maximum de 100 000 SCIDs par message et 100 000 SCIDs au total
  pour une seule requête.

- [Rust Bitcoin #6364][] ajoute la prise en charge de l'encodage et du décodage P2P pour les messages `feature` de [BIP434][] (voir les
  Bulletins [#386][news386 bip434] et [#390][news390 bip434]), à la suite de l'implémentation antérieure de Bitcoin Core (voir le [Bulletin
  #410][news410 bip434]). Il ajoute la version de protocole `70017`, la variante `feature` de `NetworkMessage`, tout en appliquant les
  limites de taille de BIP434 sur les identifiants de fonctionnalité et les données. Cette mise à jour fournit l'infrastructure de messages,
  mais n'implémente pas la logique de négociation des fonctionnalités entre pairs.

- [Rust Bitcoin #6642][] applique une limite de taille de 4 Mo à chaque élément witness de transaction. Cette limite est dérivée de la
  limite de bloc de quatre millions d'unités de poids de [BIP141][], puisqu'un élément witness plus grand que cette taille ne tiendrait pas
  dans un bloc valide. Auparavant, lors du décodage d'une transaction, Rust Bitcoin n'appliquait cette limite qu'au premier élément witness,
  réinitialisant ensuite à une limite par défaut plus grande de 32 Mio pour les éléments suivants. Cela pouvait permettre qu'un élément
  surdimensionné soit accepté lors du décodage, laissant le witness dans un état incohérent susceptible de provoquer une panic lorsqu'il
  était plus tard interprété comme une dépense [taproot][topic taproot]. Cela suit le durcissement antérieur de l'allocation mémoire du
  décodage witness décrit dans le [Bulletin #410][news410 witness].

- [BTCPay Server #7491][] corrige un contournement de l'authentification à deux facteurs (2FA) dans le gestionnaire d'authentification de
  l'API Greenfield. Bien que le gestionnaire d'authentification vérifiait la 2FA FIDO2 (voir le [Bulletin #146][news146 btcpay mfa]), il ne
  vérifiait pas la 2FA par mot de passe à usage unique basé sur le temps (TOTP). Cela permettait à des comptes protégés par TOTP d'accéder à
  l'API sans fournir leur 2FA. Le gestionnaire rejette désormais cette forme d'authentification dès qu'un second facteur est activé.

- [BTCPay Server #7488][] améliore la compatibilité de signature [PSBT][topic psbt] en ajoutant `witness_utxo` aux entrées [segwit][topic
  segwit] lorsque le PSBT contient déjà la transaction précédente correspondante dans `non_witness_utxo`. Cela résout un problème avec des
  dispositifs de signature tels que le Blockstream Jade lorsqu'ils sont utilisés avec des versions plus récentes de [HWI][topic hwi], tout
  en conservant le `non_witness_utxo` existant. La PR corrige également un problème avec des transactions multisig en attente dont le statut
  de signature stocké était devenu obsolète. BTCPay Server recalcule désormais leur progression de signature lorsqu'elles sont chargées et
  les marque comme `Signed` lorsqu'un nombre suffisant de signatures est présent et que le PSBT peut être finalisé avec succès.

{% include snippets/recap-ad.md when="2026-08-11 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2212,2205,2210,35501,9298,9353,3336,10942,10992,6364,6642,7491,7488" %}

[stale tip ml]: https://groups.google.com/g/bitcoindev/c/AwOPNxF15mU
[stale tip bip]: https://github.com/pseudoramdom/bips/blob/staletip-bip-draft/bip-staletip.md
[stale tip poc]: https://github.com/w0xlt/bitcoin/tree/staletip-v4

[fj ml cisa]: https://groups.google.com/g/bitcoindev/c/1XH6sBLWZuA
[c ml cisa]: https://groups.google.com/g/bitcoindev/c/1XH6sBLWZuA/m/V6PZL7bGAwAJ
[fj ml cisa conduition]: https://groups.google.com/g/bitcoindev/c/1XH6sBLWZuA/m/kF-RpqEgBAAJ
[ag ml cisa]: https://groups.google.com/g/bitcoindev/c/1XH6sBLWZuA/m/-zRSmrFZGQAJ
[fj ml cisa waxwing]: https://groups.google.com/g/bitcoindev/c/1XH6sBLWZuA/m/oOQ7TIEVAgAJ
[news208 halfagg]: /en/newsletters/2022/07/13/#half-aggregation-of-bip340-signatures
[news415 dahlias]: /fr/newsletters/2026/07/24/#projet-de-bip-pour-l-agregation-complete-des-signatures-bip340
[news403 pqout]: /fr/newsletters/2026/05/01/#discussion-d-un-type-de-sortie-post-quantique
[pw delving pqwit]: https://delvingbitcoin.org/t/segwit-commitment-to-post-quantum-witness-data/2702
[pw delving pqout]: https://delvingbitcoin.org/t/pqc-output-type-discussion/2749
[jp delving pqout]: https://delvingbitcoin.org/t/pqc-output-type-discussion/2749/3
[news412 pkr]: /fr/newsletters/2026/07/03/#recuperation-de-cle-publique-pour-les-feuilles-ec-de-p2mr
[news412 p2xx]: /fr/newsletters/2026/07/03/#declencher-la-desactivation-d-ec-par-une-depense-vers-un-point-nums-ou-par-une-majorite-de-hashrate
[news386 jn hash]: /fr/newsletters/2026/01/02/#signatures-basees-sur-le-hachage-pour-le-futur-post-quantique-de-bitcoin
[jd delving expire htlc]: https://delvingbitcoin.org/t/expiring-htlcs-without-free-relay/2663
[jd delving input expiry]: https://delvingbitcoin.org/t/input-triggered-transaction-expiry/2667
[news274 expire]: /fr/newsletters/2023/10/25/#op-expire
[shinobi ml qr]: https://groups.google.com/g/bitcoindev/c/gtxpSxgG7E4
[shinobi delving qr]: https://delvingbitcoin.org/t/post-quantum-recovery-of-hashed-addresses-with-no-confiscatory-risk/2714
[news403 pqrecovery]: /fr/newsletters/2026/05/01/#recuperation-post-quantique-bip86-a-l-aide-de-preuves-zk-stark-de-seeds-bip32
[mh delving segdata]: https://delvingbitcoin.org/t/bip-draft-segregated-data-a-prunable-script-isolated-block-region-for-data-carriage/2641
[news193 wtxid]: /en/newsletters/2022/03/30/#transaction-witness-replacement
[news304 wtxid]: /fr/newsletters/2024/05/24/#bitcoin-core-30000
[news386 bip434]: /fr/newsletters/2026/01/02/#negociation-de-fonctionnalites-entre-pairs
[news390 bip434]: /fr/newsletters/2026/01/30/#bips-2076
[news410 bip434]: /fr/newsletters/2026/06/19/#bitcoin-core-35221
[news410 witness]: /fr/newsletters/2026/06/19/#rust-bitcoin-6321
[news146 btcpay mfa]: /en/newsletters/2021/04/28/#btcpay-server-2356
[Libsecp256k1 0.8.0]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.8.0
[news415 silent]: /fr/newsletters/2026/07/24/#libsecp256k1-1765
[news396 sha256]: /fr/newsletters/2026/03/13/#libsecp256k1-1777
