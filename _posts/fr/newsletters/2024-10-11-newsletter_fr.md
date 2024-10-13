---
title: 'Bulletin Hebdomadaire Bitcoin Optech #324'
permalink: /fr/newsletters/2024/10/11/
name: 2024-10-11-newsletter-fr
slug: 2024-10-11-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine annonce trois vulnérabilités affectant les anciennes versions du nœud
complet Bitcoin Core, annonce une vulnérabilité distincte affectant les anciennes versions du nœud
complet btcd, et inclut un lien vers la contribution d'un guide Optech décrivant comment utiliser plusieurs nouvelles
fonctionnalités du réseau P2P ajoutées dans Bitcoin Core 28.0. Sont également inclus nos sections
habituelles avec le résumé d'une réunion du Bitcoin Core PR Review Club,
l'annonce des mises à jour et des versions candidates, et présente les changements
apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Divulgation de vulnérabilités affectant les versions de Bitcoin Core antérieures à 25.0 :**
  Niklas Gögge a [posté][gogge corevuln] sur la liste de diffusion Bitcoin-Dev
  des liens vers les annonces de trois vulnérabilités affectant les versions
  de Bitcoin Core qui sont obsolètes depuis au moins avril 2024.

  - [CVE-2024-35202 vulnérabilité de crash à distance][] : un attaquant peut envoyer
    un message de [bloc compact][topic compact block relay] conçu délibérément
    pour faire échouer la reconstruction du bloc. Les échecs de reconstruction
    se produisent parfois même dans l'utilisation honnête du protocole, dans ce cas
    le nœud récepteur demande le bloc complet.

    Cependant, au lieu de répondre avec un bloc complet, l'attaquant pourrait
    envoyer un second message de bloc compact pour le même en-tête de bloc.
    Avant Bitcoin Core 25.0, cela provoquerait le crash du nœud, car le
    code était conçu pour empêcher le code de reconstruction de bloc compact
    de s'exécuter plus d'une fois sur la même session de bloc compact.

    Cette vulnérabilité facilement exploitable aurait pu être utilisée pour faire crasher
    n'importe quel nœud Bitcoin Core, ce qui pourrait être utilisé comme partie d'autres
    attaques pour voler de l'argent aux utilisateurs. Par exemple, un nœud Bitcoin Core crashé
    serait incapable d'alerter un nœud LN connecté qu'une contrepartie de canal tentait de voler
    des fonds.

    La vulnérabilité a été découverte, [divulguée de manière responsable][topic
    responsible disclosures], et corrigée par Niklas Gögge, avec la
    [correction][bitcoin core #26898] publiée dans Bitcoin Core 25.0.

  - [DoS par ensembles d'inventaire importants][] : pour chacun de ses pairs, un nœud Bitcoin Core
    conserve une liste de transactions à envoyer à ce pair. Les
    transactions dans la liste sont triées en fonction de leurs frais et
    de leurs relations les unes avec les autres dans le but de s'assurer que les
    meilleures transactions sont relayées rapidement et de rendre plus difficile l'exploration
    de la topologie du réseau de relais

    Cependant, lors d'une vague d'activité réseau en mai 2023, plusieurs
    utilisateurs ont commencé à remarquer que leurs nœuds utilisaient une quantité excessive de CPU.
    Le développeur 0xB10C a déterminé que le CPU était consommé par la fonction de tri. Le développeur
    Anthony Towns a enquêté davantage et a [corrigé][bitcoin core #27610] le problème en
    s'assurant que les transactions quittaient la file d'attente à un taux variable qui augmente
    pendant les périodes de forte demande. La correction a été publiée dans Bitcoin Core
    25.0.

  - [Attaque de propagation lente de bloc][] : avant Bitcoin Core 25.0, un
    bloc invalide venant d'un attaquant pouvait empêcher Bitcoin Core de
    continuer à traiter un bloc valide avec la même en-tête provenant de pairs honnêtes.
    Cela a particulièrement affecté la reconstruction de blocs compacts lorsque des transactions
    supplémentaires devaient être demandées : un nœud arrêterait d'attendre les transactions s'il
    recevait un bloc invalide d'un pair différent. Même si les transactions étaient reçues plus tard, le
    nœud les ignorerait.

    Après que Bitcoin Core ait rejeté le bloc invalide (et possiblement déconnecté le pair qui l'avait
    envoyé), il recommencerait à tenter de demander le bloc à d'autres pairs. Plusieurs pairs attaquants
    pourraient le maintenir dans ce cycle pendant une période prolongée. Des pairs défectueux qui
    n'auraient pas été conçus comme des attaquants pourraient déclencher le même comportement
    accidentellement.

    Le problème a été découvert après que plusieurs développeurs, y compris William Casarin et ghost43,
    aient signalé des problèmes avec leurs nœuds. Plusieurs autres développeurs ont enquêté, avec Suhas
    Daftuar isolant cette vulnérabilité. Daftuar a également [corrigé][bitcoin core #27608] cela en
    empêchant tout pair d'affecter l'état de téléchargement des autres pairs, sauf dans le cas où un
    bloc a passé la validation et a été stocké sur disque. La correction a été incluse dans Bitcoin Core 25.0.

- **CVE-2024-38365 échec de consensus btcd :** comme annoncé dans [la newsletter de la semaine
  dernière][news323 btcd], Antoine Poinsot et Niklas Gögge [ont révélé][pg btcd] une vulnérabilité
  d'échec de consensus affectant le nœud complet btcd. Dans les transactions Bitcoin traditionnelles,
  les signatures sont stockées dans le champ du script de signature. Cependant, les signatures
  s'engagent également sur le champ du script de signature. Il n'est pas possible pour une signature
  de s'engager sur elle-même, donc les signataires s'engagent sur toutes les données du champ du
  script de signature à l'exception de la signature. Les vérificateurs doivent en conséquence retirer
  la signature avant de vérifier l'exactitude de l'engagement de la signature.

  La fonction de Bitcoin Core pour retirer les signatures, `FindAndDelete`, ne supprime que les
  correspondances exactes de la signature du script de signature. La fonction implémentée par btcd,
  `removeOpcodeByData` supprimait _toute_ donnée dans le script de signature qui contenait la
  signature. Cela pourrait être utilisé pour amener btcd à supprimer plus de données du script de
  signature que Bitcoin Core ne le ferait avant de vérifier respectivement l'engagement, conduisant un
  programme à considérer l'engagement valide et l'autre invalide. Toute transaction contenant un
  engagement invalide est invalide et tout bloc contenant une transaction invalide est invalide,
  permettant de briser le consensus entre Bitcoin Core et btcd. Les nœuds qui sortent du consensus
  peuvent être trompés en acceptant des transactions invalides et peuvent ne pas voir les dernières
  transactions que le reste du réseau considère comme confirmées, ce qui peut entraîner une perte
  significative d'argent.

  La divulgation responsable de Poinsot et Gögge a permis aux mainteneurs de btcd de corriger
  discrètement la vulnérabilité et de sortir la version 0.24.2 avec la correction il y a environ trois
  mois.

- **Guide pour les portefeuilles utilisant Bitcoin Core 28.0 :** Comme mentionné dans [le bulletin
  de la semaine dernière][news323 bcc28], la version 28.0 de Bitcoin Core nouvellement publiée
  contient plusieurs nouvelles fonctionnalités pour le réseau P2P, incluant le [relais de paquets][topic
  package relay] un parent un enfant (1P1C), le relai de transaction topologiquement restreint jusqu'à
  confirmation ([TRUC][topic v3 transaction relay]), le [package RBF][topic rbf] et
  l'[éviction de la fratrie][topic kindred rbf], et un type standard de script de sortie pay-to-anchor
  ([P2A][topic ephemeral anchors]). Ces nouvelles fonctionnalités peuvent améliorer significativement
  la sécurité et la fiabilité pour plusieurs cas d'utilisation courants.

  Gregory Sanders a écrit un [guide][sanders guide] pour Optech destiné
  aux développeurs de portefeuilles et d'autres logiciels qui utilisent Bitcoin Core pour
  créer ou diffuser des transactions. Le guide explique l'utilisation de
  plusieurs fonctionnalités et décrit comment ces fonctionnalités peuvent être utiles
  pour plusieurs protocoles, y compris les paiements simples et le bumping de frais RBF,
  les engagements LN et [HTLCs][topic htlc], [Ark][topic ark], et le [splicing LN][topic splicing].

## Bitcoin Core PR Review Club

*Dans cette section mensuelle, nous résumons une réunion récente du [Bitcoin Core PR Review
Club][], en soulignant certaines des questions et réponses importantes. Cliquez sur une question
ci-dessous pour voir un résumé de la réponse de
la réunion.*

[L'ajout de getorphantxs][review club 30793] est une PR par [tdb3][gh tdb3] qui
ajoute une nouvelle méthode RPC expérimentale nommée `getorphantxs`. Puisqu'elle est
principalement destinée aux développeurs, elle est cachée. Cette nouvelle méthode
fournit à l'appelant une liste de toutes les transactions orphelines actuelles,
ce qui peut être utile lors de la vérification des comportements/scénarios orphelins (par exemple,
dans les tests fonctionnels comme `p2p_orphan_handling.py`) ou pour fournir
des données supplémentaires pour des statistiques/visualisations.

{% include functions/details-list.md
  q0="Qu'est-ce qu'une transaction orpheline ? À quel moment les transactions entrent-elles dans l'orphelinat ?"
  a0="Une transaction orpheline est une transaction dont les entrées font référence à des transactions
  parentes inconnues ou manquantes. Les transactions entrent dans l'orphelinat lorsqu'elles sont reçues
  d'un pair mais échouent à la validation avec `TX_MISSING_INPUTS` dans `ProcessMessage`."
  a0link="https://bitcoincore.reviews/30793#l-16"
  q1="Quelle commande peut-on exécuter pour obtenir une liste des RPC disponibles ?"
  a1="`bitcoin-cli help` fournit une liste des RPC disponibles. Note : puisque
  `getorphantxs` est [marqué comme caché][gh getorphantxs hidden] en tant que RPC pour développeurs
  seulement, il n'apparaîtra pas dans cette liste."
  a1link="https://bitcoincore.reviews/30793#l-26"
  q2="Si un RPC a un argument non-string, doit-on faire quelque chose de spécial pour le gérer ?"
  a2="Les arguments RPC non-string doivent être ajoutés à la liste `vRPCConvertParams`
  dans `src/rpc/client.cpp` pour assurer une conversion de type appropriée."
  a2link="https://bitcoincore.reviews/30793#l-72"
  q3="Quelle est la taille maximale du résultat de ce RPC ? Y a-t-il une limite au nombre d'orphelins conservés ?
  Y a-t-il une limite à la durée pendant laquelle les orphelins peuvent rester dans l'orphelinat ?"
  a3="Le nombre maximum d'orphelins est de 100
  (`DEFAULT_MAX_ORPHAN_TRANSACTIONS`). À `verbosity=0`, chaque txid est une
  valeur binaire de 32 octets, mais lorsqu'elle est codée en hexadécimal pour le résultat JSON-RPC,
  elle devient une chaîne de 64 caractères (puisque chaque octet est représenté par deux
  Caractères hexadécimaux). Cela signifie que la taille maximale du résultat est d'environ 6,4 kB (100
  txids * 64 octets).<br><br>
  À `verbosity=2`, la transaction encodée en hexadécimal est de loin le champ le plus volumineux dans
  le résultat, donc pour simplifier, nous ignorerons les autres champs dans ce calcul. La taille
  maximale sérialisée d'une transaction peut atteindre 400 kB (dans le cas extrême et impossible où
  elle ne consisterait qu'en des données de témoin), ou 800 kB une fois encodée en hexadécimal. Par
  conséquent, la taille maximale du résultat est d'environ 80 MB (100 transactions * 800 kB).<br><br>
  Les orphelins sont limités dans le temps et sont supprimés après 20 minutes, comme défini par
  `ORPHAN_TX_EXPIRE_TIME`."
  a3link="https://bitcoincore.reviews/30793#l-94"
  q4="Depuis quand existe-t-il une taille maximale d'orphelinat?"
  a4="La variable `MAX_ORPHAN_TRANSACTIONS` a été introduite dès 2012, dans le commit [142e604][gh commit 142e604]."
  a4link="https://bitcoincore.reviews/30793#l-105"
  q5="En utilisant le RPC `getorphantxs`, pourrions-nous savoir combien de temps une transaction a été
  dans l'orphelinat? Si oui, comment feriez-vous?"
  a5="Oui, en utilisant `verbosity=1`, vous pouvez obtenir le timestamp d'expiration de chaque
  transaction orpheline. Soustraire le `ORPHAN_TX_EXPIRE_TIME` (c'est-à-dire 20 minutes) donne le
  moment d'insertion."
  a5link="https://bitcoincore.reviews/30793#l-128"
  q6="En utilisant le RPC `getorphantxs`, pourrions-nous savoir quels sont les entrées d'une
  transaction orpheline? Si oui, comment feriez-vous?"
  a6="Oui, avec `verbosity=2`, le RPC retourne l'hexadécimal brut de la transaction, qui peut être
  décodé en utilisant `decoderawtransaction` pour révéler ses entrées."
  a6link="https://bitcoincore.reviews/30793#l-140"
%}

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates.*

- [Bitcoin Inquisition 28.0][] est la dernière sortie de ce [signet][topic signet] full node conçu
  pour expérimenter avec des propositions de soft forks et d'autres changements majeurs de protocole. La
  version mise à jour est basée sur la récente sortie de Bitcoin Core 28.0.

- [BDK 1.0.0-beta.5][] est un candidat à la sortie (Release Candidate, RC) de cette bibliothèque pour construire des
  portefeuilles et d'autres applications activées par Bitcoin. Ce dernier RC "active RBF par défaut,
  met à jour le client bdk_esplora pour réessayer les requêtes serveur qui échouent en raison de la
  limitation du taux. Le paquet `bdk_electrum` offre désormais également une fonctionnalité
  use-openssl."

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet
_Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPayServer][btcpay server repo],
[BDK][bdk repo], [Propositions d'Amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts
repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], et
[BINANAs][binana repo]._

- [Core Lightning #7494][] introduit une durée de vie de 2 heures pour `channel_hints`, permettant
  de réutiliser les informations de routage apprises lors d'un paiement pour des tentatives futures
  afin d'éviter des tentatives inutiles. Les canaux qui étaient considérés comme indisponibles seront
  progressivement restaurés et deviendront pleinement disponibles après 2 heures, pour garantir que
  des informations obsolètes ne causent pas l'omission de routes qui auraient pu se rétablir depuis.

- [Core Lightning #7539][] ajoute une commande RPC `getemergencyrecoverdata` pour récupérer et
  retourner les données du fichier `emergency.recover`. Cela permettra aux développeurs utilisant
  l'API d'ajouter une fonctionnalité de sauvegarde de portefeuille à leurs applications.

- [LDK #3179][] introduit de nouveaux [messages onion][topic onion messages] `DNSSECQuery` et `DNSSECProof`,
  et un `DNSResolverMessageHandler` pour gérer ces messages comme la fonctionnalité
  principale pour implémenter [BLIP32][]. Cette PR ajoute également un `OMNameResolver` qui vérifie
  les preuves DNSSEC et les transforme en [offres][topic offers]. Voir le Bulletin [#306][news306
  blip32].

- [LND #8960][] implémente une fonctionnalité de canal personnalisé en ajoutant une superposition
  taproot comme un nouveau type de canal expérimental, qui est identique à un [canal taproot
  simple][topic simple taproot channels] mais engage des métadonnées supplémentaires dans les feuilles
  [tapscript][topic tapscript] pour les scripts de canal. La machine d'état principale du canal et la
  base de données sont mises à jour pour traiter et stocker les feuilles tapscript personnalisées. Une
  option de configuration `TaprootOverlayChans` doit être définie pour activer le support des canaux de
  superposition taproot. L'initiative des canaux personnalisés améliore le support de LND pour [les
  actifs taproot][topic client-side validation]. Voir le Bulletin [#322][news322 customchans].

- [Libsecp256k1 #1479][] ajoute un module [MuSig2][topic musig] pour un schéma multisig compatible
  avec [BIP340][] tel que spécifié dans [BIP327][]. Ce module est presque identique à celui implémenté
  dans [secp256k1-zkp][zkpmusig2], mais présente quelques changements mineurs, tels que la suppression
  du support pour les [signatures adaptatives][topic adaptor signatures] pour le rendre non expérimental.

- [Rust Bitcoin #2945][] introduit le support pour [testnet4][topic testnet] en ajoutant
  l'énumération `TestNetVersion`, en refactorisant le code, et en incluant les paramètres nécessaires
  et les constantes de la blockchain pour testnet4.

- [BIPs #1674][] revient sur les modifications de la spécification [BIP85][]
  décrites dans le [Bulletin #323][news323 bip85]. Les changements ont rompu
  la compatibilité avec les versions déployées du protocole. La discussion sur
  la PR a soutenu la création d'un nouveau BIP pour les changements majeurs.

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="7494,7539,3179,8960,1479,2945,1674,26898,27610,27608" %}
[BDK 1.0.0-beta.5]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.5
[news323 bip85]: /fr/newsletters/2024/10/04/#bips-1600
[sanders guide]: /en/bitcoin-core-28-wallet-integration-guide/
[gogge corevuln]: https://mailing-list.bitcoindevs.xyz/bitcoindev/2df30c0a-3911-46ed-b8fc-d87528c68465n@googlegroups.com/
[CVE-2024-35202 vulnérabilité de crash à distance]: https://bitcoincore.org/fr/2024/10/08/reveler-blocktxn-crash/
[DoS par ensembles d'inventaire importants]: https://bitcoincore.org/fr/2024/10/08/reveler-large-inv-to-send/
[Attaque de propagation lente de bloc]: https://bitcoincore.org/fr/2024/10/08/reveler-mutated-blocks-hindering-propagation/
[news323 btcd]: /fr/newsletters/2024/10/04/#divulgation-de-securite-btcd-imminente
[pg btcd]: https://delvingbitcoin.org/t/cve-2024-38365-public-disclosure-btcd-findanddelete-bug/1184
[news323 bcc28]: /fr/newsletters/2024/10/04/#bitcoin-core-28-0
[bitcoin inquisition 28.0]: https://github.com/bitcoin-inquisition/bitcoin/releases/tag/v28.0-inq
[review club 30793]: https://bitcoincore.reviews/30793
[gh tdb3]: https://github.com/tdb3
[gh getorphantxs hidden]: https://github.com/bitcoin/bitcoin/blob/a9f6a57b6918b2f92c7d6662e8f5892bf57cc127/src/rpc/mempool.cpp#L1131
[gh commit 142e604]: https://github.com/bitcoin/bitcoin/commit/142e604184e3ab6dcbe02cebcbe08e5623182b81
[news306 blip32]: /fr/newsletters/2024/06/07/#blips-32
[news322 customchans]: /fr/newsletters/2024/09/27/#lnd-9095
[zkpmusig2]: https://github.com/BlockstreamResearch/secp256k1-zkp