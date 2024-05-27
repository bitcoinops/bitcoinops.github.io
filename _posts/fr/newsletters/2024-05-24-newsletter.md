---
title: 'Bulletin Hebdomadaire Bitcoin Optech #304'
permalink: /fr/newsletters/2024/05/24/
name: 2024-05-24-newsletter-fr
slug: 2024-05-24-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume une analyse de plusieurs propositions pour améliorer les
canaux LN sans les fermer et les rouvrir, discute des défis pour assurer une rémunération appropriée
des mineurs de pool, renvoie à une discussion sur l'utilisation sécurisée des PSBT pour communiquer
des informations relatives aux paiements silencieux, annonce une proposition de BIP pour miniscript,
et résume une proposition d'utilisation de rééquilibrages fréquents d'un canal LN pour simuler un
contrat à terme sur les prix. Nous incluons également nos sections régulières décrivant les mises à jour
des clients et des services, les nouvelles versions et les versions candidates, ainsi que les changements
apportés aux principaux logiciels d'infrastructure Bitcoin.

## Actualités

- **Amélioration des canaux LN existants :** Carla Kirk-Cohen a [publié][kc upchan] sur Delving
  Bitcoin un résumé et une analyse des propositions existantes pour améliorer les canaux LN existants
  afin de supporter de nouvelles fonctionnalités. Elle examine une variété de cas différents, tels que :

  - *Changement de paramètres :* actuellement, certains paramètres du canal sont négociés entre les
    parties et ne peuvent pas être modifiés pendant la durée de vie du canal. Les mises à jour des
    paramètres permettraient une renégociation ultérieure. Par exemple, les nœuds pourraient vouloir
    changer le nombre de satoshis à partir duquel ils commencent à [réduire les HTLCs][topic trimmed
    htlc] ou la quantité de réserve de canal qu'ils attendent de leur contrepartie pour décourager la
    fermeture dans un état ancien.

  - *Mise à jour des engagements :* Les _transactions d'engagement_ LN permettent à un individu de
    mettre l'état actuel du canal onchain. Les [mises à jour d'engagement][topic channel
    commitment upgrades] peuvent permettre de passer aux [sorties d'ancrage][topic anchor outputs] et
    aux [transactions v3][topic v3 transaction relay] dans les canaux basés sur P2WSH, et pour les
    [canaux taproot simples][topic simple taproot channels] de passer à l'utilisation des [PTLC][topic
    ptlc].

  - *Remplacement du financement :* Les canaux LN sont ancrés onchain dans une _transaction de
    financement_, dont la sortie est dépensée offchain à plusieurs reprises comme la transaction
    d'engagement. À l'origine, toutes les transactions de financement LN utilisaient une sortie P2WSH ;
    cependant, les nouvelles fonctionnalités telles que les [PTLC][topic ptlc] nécessitent que les
    transactions de financement utilisent des sorties P2TR.

  Kirk-Cohen compare trois idées précédemment proposées pour l'amélioration des canaux :

  - *Engagements dynamiques :* comme décrit dans une [spécification provisoire][BOLTs #1117], cela
    permet de changer presque tous les paramètres du canal et offre également un chemin généralisé pour
    améliorer les transactions de financement et d'engagement en utilisant une nouvelle transaction
    "coup d'envoi".

  - *Épissure pour améliorer :* cette idée permet une [transaction d'épissure][topic splicing] qui
    mettrait déjà nécessairement à jour le financement d'un canal onchain pour changer le type de
    financement utilisé ainsi que, éventuellement, son format de transaction d'engagement. Elle ne
    traite pas directement du changement des paramètres du canal.

  - *Mise à niveau lors de la reconnexion :* également décrite dans une [spécification
    provisoire][bolts #868], cela permet de changer de nombreux paramètres du canal chaque fois que deux
    nœuds rétablissent une connexion de données. Elle ne traite pas directement des mises à niveau des
    transactions de financement et d'engagement.

  Avec toutes les options présentées, Kirk-Cohen les compare dans un tableau
  énumérant leurs coûts onchain, avantages et inconvénients ; elle les compare également aux coûts
  onchain de ne pas effectuer de mises à niveau. Elle tire plusieurs conclusions, dont : "Je pense
  qu'il est judicieux de commencer à travailler sur les mises à niveau des paramètres et des
  engagements via les [engagements dynamiques][bolts #1117], indépendamment de la manière dont nous
  choisissons de procéder à la mise à niveau vers les canaux taproot. Cela nous donne la possibilité
  de passer aux canaux `option_zero_fee_htlc_tx` anchor, et fournit un mécanisme de mise à niveau du
  format d'engagement qui peut être utilisé pour nous amener aux canaux V3 (une fois spécifiés)."

- **Défis dans la récompense des mineurs de pool :** Ethan Tuttle [a posté][tuttle poolcash] sur
  Delving Bitcoin pour suggérer que les [pools de minage][topic pooled mining] pourraient récompenser
  les mineurs avec des jetons [ecash][topic ecash] proportionnels au nombre de parts qu'ils ont
  minées. Les mineurs pourraient alors immédiatement vendre ou transférer les jetons, ou ils
  pourraient attendre que le pool mine un bloc, moment auquel le pool échangerait les jetons contre
  des satoshis.

  Des critiques et des suggestions sur l'idée ont été publiées. Nous avons trouvé particulièrement
  perspicace une [réponse][corallo pooldelay] de Matt Corallo où il décrit un problème sous-jacent :
  il n'existe pas de méthodes de paiement standardisées mises en œuvre par les grands pools qui
  permettent aux mineurs de pool de calculer leurs paiements sur de courts intervalles. Deux types de
  paiement couramment utilisés sont :

  - *Pay per share (PPS) :* cela paie un mineur proportionnellement à la quantité de travail qu'ils
    ont contribué même si un bloc n'est pas trouvé. Calculer le paiement proportionnel pour la
    subvention de bloc est facile, mais le calculer pour les frais de transaction est plus compliqué.
    Corallo note que la plupart des pools semblent utiliser une moyenne des frais collectés pendant la
    journée où la part a été créée, ce qui signifie que le montant payé par part ne peut pas être
    calculé jusqu'à un jour après que la part a été extraite. De plus, de nombreux pools peuvent ajuster
    les moyennes des frais d'une manière qui varie selon le pool.

  - *Pay per last n shares (PPLNS) :* récompense les mineurs pour les parts trouvées près du moment où
    le pool trouve un bloc. Cependant, un mineur ne peut être sûr qu'un pool a trouvé un bloc que s'il
    l'a trouvé lui-même. Il n'y a aucun moyen (à court terme) pour un mineur typique de savoir que le
    pool lui fournit un paiement correct.

  Ce manque d'information signifie que les mineurs ne passeront pas rapidement à un autre pool si leur
  pool principal commence à les tromper sur les paiements. [Stratum v2][topic pooled mining] ne résout
  pas cela, bien que les pools honnêtes puissent utiliser un message standardisé pour dire aux mineurs
  qu'ils vont cesser de payer pour de nouvelles parts. Corallo renvoie à une [proposition][corallo sv2
  proposal] pour Stratum v2 permettant aux mineurs de vérifier que toutes leurs parts sont prises en
  compte dans les paiements, ce qui peut au moins permettre aux mineurs de détecter s'ils ne sont pas
  payés correctement après une période plus longue (heures à jours).

  La discussion était en cours au moment de la rédaction.

- **Discussion sur les PSBT pour les paiements silencieux :** Josie Baker [a lancé][baker psbtsp]
  une discussion sur Delving Bitcoin à propos des extensions [PSBT][topic psbt] pour les [paiements
  silencieux][topic silent payments].
  (SPs), citant une [spécification préliminaire][toth psbtsp] par Andrew Toth. Les PSBT
  pour les SP ont deux aspects :

  - **Paiement aux adresses SP :** le script de sortie réel placé dans une transaction dépend à la
    fois de l'adresse de paiement silencieux et des entrées dans la transaction. Tout changement apporté
    aux entrées dans un PSBT peut potentiellement rendre une sortie SP non dépensable par le logiciel de
    portefeuille standard, donc une validation supplémentaire du PSBT est requise. Certains types
    d'entrées ne peuvent pas être utilisés avec les SP, ce qui nécessite également une validation.

    Pour les types d'entrées qui peuvent être utilisés, la logique de dépense consciente des SP
    nécessite la clé privée pour ces entrées, qui peut ne pas être disponible pour un portefeuille
    logiciel lorsque la clé sous-jacente est stockée dans un dispositif de signature matériel. Baker
    décrit un schéma qui pourrait permettre à un dépensier de créer un script de sortie SP sans la clé
    privée, mais cela a le potentiel de divulguer une clé privée, donc il se peut qu'il ne soit pas mis
    en œuvre dans les dispositifs de signature matériel.

  - **Dépense des sorties SP précédemment reçues :** Les PSBT devront inclure le secret partagé qui
    est utilisé comme ajustement de la clé de dépense. Cela peut être juste un champ supplémentaire dans
    le PSBT.

  La discussion était en cours au moment de la rédaction.

- **Proposition de BIP miniscript :** Ava Chow [a posté][chow miniscript] sur la liste de diffusion
  Bitcoin-Dev un [BIP préliminaire][chow bip] pour [miniscript][topic miniscript], un langage qui peut
  être converti en Bitcoin Script mais qui permet la composition, le templating et une analyse
  définitive. Le BIP préliminaire est dérivé du site web de longue date de miniscript et devrait
  correspondre aux implémentations existantes de miniscript tant pour le script témoin P2WSH que pour
  le [tapscript][topic tapscript] P2TR.

- **Ancrage de la valeur des canaux :** Tony Klausing [a posté][klausing stable] sur Delving Bitcoin
  une proposition, avec du [code][klausing code] fonctionnel, pour des _canaux stables_. Imaginez
  qu'Alice souhaite conserver une quantité de bitcoin équivalente à 1 000 USD. Bob est prêt à garantir
  cela, soit parce qu'il s'attend à ce que le BTC augmente en valeur, soit parce qu'Alice lui paie une
  prime (ou les deux). Ils ouvrent un canal LN ensemble et, chaque minute, ils effectuent les actions
  suivantes :

  - Ils vérifient tous les deux les mêmes sources de prix BTC/USD.

  - Si la valeur du BTC augmente, Alice réduit son solde en bitcoin jusqu'à ce qu'il soit égal en
    valeur à 1 000 USD, transférant l'excédent à Bob.

  - Si la valeur du BTC baisse, Bob envoie suffisamment de BTC à Alice jusqu'à ce que son solde en
    bitcoin soit de nouveau égal en valeur à 1 000 USD.

  L'objectif est que le rééquilibrage se produise assez fréquemment pour que chaque changement de prix
  soit inférieur au coût pour la partie désavantagée de fermer le canal, les encourageant à simplement
  payer et continuer la relation.

  Klausing suggère que certains traders pourraient trouver cette relation minimalement fiable
  préférable aux marchés à terme en dépôt. Il suggère également que cela pourrait être utilisé comme
  base pour une banque qui émet des [ecash][topic ecash] libellés en dollars. Le schéma fonctionnerait
  pour tout actif pour lequel un prix de marché pourrait être déterminé.

## Modifications apportées aux services et aux logiciels clients
*Dans cette rubrique mensuelle, nous mettons en lumière des mises à jour intéressantes concernant
les portefeuilles et services Bitcoin.*

- **Ressources de paiements silencieux :**
  Plusieurs ressources de paiements silencieux ont été annoncées, incluant un site d'information
  [silentpayments.xyz][sp website], [deux][bi ts sp] bibliothèques TypeScript [libraries][bw ts sp],
  un backend basé sur Go [gh blindbitd], un [portefeuille web][gh silentium], et [plus encore][sp
  website devs]. La prudence est recommandée car la plupart des logiciels sont nouveaux, en version
  bêta ou en cours de développement.

- **Cake Wallet intègre les paiements silencieux :**
  [Cake Wallet][cake wallet website] a récemment [annoncé][cake wallet announcement] que leur dernière
  version bêta prend en charge les paiements silencieux.

- **Preuve de concept de coinjoin sans coordinateur :**
  [Emessbee][gh emessbee] est un projet de preuve de concept visant à créer des transactions
  [coinjoin][topic coinjoin] sans coordinateur central.

- **OCEAN ajoute le support de BOLT12 :**
  La pool de minage OCEAN utilise un [message signé][topic generic signmessage] pour associer une
  adresse Bitcoin à une [offre BOLT12][topic offers] dans le cadre de leur configuration de [paiement
  Lightning][ocean docs].

- **Coinbase ajoute le support Lightning :**
  Utilisant l'infrastructure Lightning de [Lightspark][lightspark website], [Coinbase a
  ajouté][coinbase blog] le support des dépôts et retraits Lightning.

- **Annonce d'outils d'escrow Bitcoin :**
  L'équipe de [BitEscrow][bitescrow website] a annoncé un ensemble d'[outils pour
  développeurs][bitescrow docs] pour la mise en œuvre d'escrow Bitcoin non-custodial.

- **Appel de Block pour les retours de la communauté minière :**
  Dans une [mise à jour][block blog] sur leur progression de puce 3nm, Block recherche des retours de
  la communauté minière concernant les fonctionnalités logicielles du matériel de minage, la
  maintenance et d'autres questions.

- **Lancement du tracker de portefeuille Sentrum :**
  [Sentrum][gh sentrum] est un portefeuille en lecture seule qui prend en charge une variété de canaux
  de notification.

- **Stack Wallet ajoute le support FROST :**
  [Stack Wallet v2.0.0][gh stack wallet] ajoute le support [seuil de déclenchement][topic threshold
  signature] du multisig FROST en utilisant la bibliothèque Modular FROST Rust.

- **Outil d'annonce de transactions annoncé :**
  [Pushtx][gh pushtx] est un simple programme Rust qui diffuse des transactions directement sur le
  réseau P2P Bitcoin.

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets d’infrastructure
Bitcoin. Veuillez envisager de passer aux nouvelles versions ou d’aider à tester
les versions candidates.*

- [Bitcoin Inquisition 27.0][] est la dernière version majeure de ce fork de Bitcoin Core conçu pour
  tester les soft forks et autres changements majeurs de protocole sur [signet][topic signet]. une nouveauté
  dans cette version est l'application de [OP_CAT][] comme spécifié dans [BIN24-1][] et [BIP347][].
  Également inclus "une nouvelle sous-commande `evalscript` pour `bitcoin-util` qui peut être
  utilisée pour tester le comportement des opcodes de script". Le support a été supprimé pour
  `annexdatacarrier` et les [ancres éphémères][topic ephemeral anchors] (voir les Bulletins
  [#244][news244 annex] et [#248][news248 ephemeral]).

- [LND v0.18.0-beta.rc2][] est un candidat à la version pour la prochaine majeure
  version de cette implémentation populaire de nœud LN.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core
lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust
Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo], [Propositions
d'Amélioration de Bitcoin (BIPs)][bips repo], [Éclairs Lightning (BOLTs)][bolts repo], [Inquisition
Bitcoin][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #27101][] introduit le support pour les requêtes et réponses de serveur JSON-RPC
  2.0. Les changements notables sont que le serveur retourne toujours HTTP 200 "OK" sauf s'il y a une
  erreur HTTP ou une requête malformée, il retourne soit des champs d'erreur soit des champs de
  résultat mais jamais les deux, et les requêtes simples et en lot aboutissent au même comportement de
  gestion des erreurs. Si la version 2.0 n'est pas spécifiée dans le corps de la requête, le protocole
  JSON-RPC 1.1 hérité est utilisé.

- [Bitcoin Core #30000][] permet à plusieurs transactions avec le même `txid` de coexister dans
  `TxOrphanage` en les indexant par `wtxid` au lieu de `txid`. L'orphelinat est une zone de mise en
  atttente de taille limitée que Bitcoin Core utilise pour stocker les transactions qui référencent les
  txids des transactions parentes auxquelles Bitcoin Core n'a pas actuellement accès.
  Si une transaction parente avec le txid est reçue, l'enfant peut alors être traité. L'[acceptation
  opportuniste de paquet][topic package relay] de paquets 1-parent-1-enfant (1p1c) envoie
  d'abord une transaction enfant, s'attendant à ce qu'elle soit stockée dans l'orphelinat, puis envoie
  le parent, permettant ainsi de considérer leur taux de frais agrégé.

  Cependant, lorsque l'acceptation opportuniste 1p1c a été fusionnée (voir le [Bulletin #301][news301
  bcc28970]), il était connu qu'un attaquant pourrait empêcher un utilisateur honnête d'utiliser la
  fonctionnalité en soumettant préventivement une version d'une transaction enfant avec des données de
  témoin invalides. Cette transaction enfant malformée aurait le même txid qu'un enfant honnête mais
  échouerait à la validation lorsque son parent serait reçu, empêchant l'enfant de contribuer au taux
  de frais du paquet [CPFP][topic cpfp] nécessaire pour que l'acceptation du paquet fonctionne.

  Comme les transactions dans l'orphelinat étaient indexées par txid avant ce PR, la première version
  d'une transaction avec un txid particulier serait celle stockée dans l'orphelinat, donc un attaquant
  qui pourrait soumettre des transactions plus rapidement et plus fréquemment qu'un utilisateur
  honnête pourrait bloquer l'utilisateur honnête indéfiniment. Après ce PR, plusieurs transactions
  avec le même txid peuvent être acceptées, chacune avec des données de témoin différentes (et donc un
  wtxid différent). Lorsqu'une transaction parente est reçue, le nœud aura suffisamment d'informations
  pour éliminer toute transaction enfant malformée puis effectuer l'acceptation de paquet 1p1c
  attendue sur un enfant valide. Ce PR a été précédemment discuté dans le résumé du PR Review Club
  dans le [Bulletin #301][news301 prclub].

- [Bitcoin Core #28233][] s'appuie sur [#17487][bitcoin core #17487] pour supprimer la vidange
  périodique du cache des pièces chaudes (UTXO) toutes les 24 heures. Avant #17487, des vidanges
  fréquentes sur le disque réduisaient le risque qu'un crash de nœud ou de matériel nécessite une
  longue procédure de réindexation. Après #17487, de nouveaux UTXO peuvent être écrits sur le disque
  sans vider le cache mémoire, bien que le cache doive toujours être vidé lorsqu'il approche de
  l'espace mémoire maximum alloué. Un cache chaud permet presque de doubler la vitesse de validation
  des blocs sur un nœud avec les paramètres de cache par défaut, avec des performances encore
  améliorées disponibles sur les nœuds qui allouent de la mémoire supplémentaire au cache.

- [Core Lightning #7304][] ajoute un flux de réponse aux `invoice_requests` de style [offres][topic
  offers] lorsqu'il ne peut pas trouver un chemin vers le nœud `reply_path`. Le `connectd` de CLN
  ouvrira une connexion TCP/IP transitoire avec le nœud demandeur pour livrer un [message onion][topic
  onion messages] contenant une facture. Cette PR améliore l'interopérabilité de Core Lightning avec
  LDK et permet également l'utilisation de messages onion même lorsque seulement quelques nœuds les
  prennent en charge (voir le [Bulletin #283][news283 ldk2723]).

- [Core Lightning #7063][] met à jour le multiplicateur de marge de sécurité de taux de frais pour
  ajuster dynamiquement les augmentations de frais probables. Le multiplicateur essaie de garantir que
  les transactions de canal paient suffisamment de taux de frais pour être confirmées, soit
  directement (pour les transactions qui ne peuvent pas être augmentées en frais) soit par le biais de
  l'augmentation des frais. Le multiplicateur commence maintenant à 2x les [estimations de taux de
  frais][topic fee estimation] actuelles pour les taux bas (1 sat/vbyte) et diminue progressivement à
  1.1x à mesure que les taux de frais approchent du `maxfeerate` quotidien élevé.

- [Rust Bitcoin #2740][] ajoute une méthode `from_next_work_required` à l'API `pow` (preuve de
  travail) qui prend un `CompactTarget` (représentant la cible de difficulté précédente), un
  `timespan` (la différence de temps entre les blocs actuels et précédents), et un objet de paramètres
  réseau `Params`. Elle retourne un nouveau `CompactTarget` représentant la prochaine cible de
  difficulté. L'algorithme implémenté dans cette fonction est basé sur l'implémentation de Bitcoin
  Core trouvée dans le fichier `pow.cpp`.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when="2024-05-27 14:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="27101,30000,28233,7304,7063,2740,1117,868,17487" %}
[lnd v0.18.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.0-beta.rc2
[kc upchan]: https://delvingbitcoin.org/t/upgrading-existing-lightning-channels/881
[tuttle poolcash]: https://delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870
[corallo pooldelay]: https://delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870/14
[corallo sv2 proposal]: https://github.com/stratum-mining/sv2-spec/discussions/76#discussioncomment-9472619
[baker psbtsp]: https://delvingbitcoin.org/t/bip352-psbt-support/877
[toth psbtsp]: https://gist.github.com/andrewtoth/dc26f683010cd53aca8e477504c49260
[chow miniscript]: https://mailing-list.bitcoindevs.xyz/bitcoindev/0be34bd2-637b-44b1-a0d5-e0ad5812d505@achow101.com/
[chow bip]: https://github.com/achow101/bips/blob/miniscript/bip-miniscript.md
[klausing stable]: https://delvingbitcoin.org/t/stable-channels-peer-to-peer-dollar-balances-on-lightning/875
[klausing code]: https://github.com/toneloc/stable-channels/
[news244 annex]: /fr/newsletters/2023/03/29/#bitcoin-inquisition-22
[news248 ephemeral]: /fr/newsletters/2023/04/26/#bitcoin-inquisition-23
[Bitcoin Inquisition 27.0]: https://github.com/bitcoin-inquisition/bitcoin/releases/tag/v27.0-inq
[news301 prclub]: /fr/newsletters/2024/05/08/#bitcoin-core-pr-review-club
[news301 bcc28970]: /fr/newsletters/2024/05/08/#bitcoin-core-28970
[news283 ldk2723]: /fr/newsletters/2024/01/03/#ldk-2723
[sp website]: https://silentpayments.xyz/
[bi ts sp]: https://github.com/Bitshala-Incubator/silent-pay
[bw ts sp]: https://github.com/BlueWallet/SilentPayments
[gh blindbitd]: https://github.com/setavenger/blindbitd
[gh silentium]: https://github.com/louisinger/silentium
[sp website devs]: https://silentpayments.xyz/docs/developers/
[cake wallet website]: https://cakewallet.com/
[cake wallet announcement]: https://twitter.com/cakewallet/status/1791500775262437396
[gh emessbee]: https://github.com/supertestnet/coinjoin-workshop
[coinbase blog]: https://www.coinbase.com/blog/coinbase-integrates-bitcoins-lightning-network-in-partnership-with
[lightspark website]: https://www.lightspark.com/
[block blog]: https://www.mining.build/latest-updates-3nm-system/
[gh sentrum]: https://github.com/sommerfelddev/sentrum
[ocean docs]: https://ocean.xyz/docs/lightning
[bitescrow website]: https://www.bitescrow.app/
[bitescrow docs]: https://www.bitescrow.app/dev
[gh stack wallet]: https://github.com/cypherstack/stack_wallet/releases/tag/build_222
[gh pushtx]: https://github.com/alfred-hodler/pushtx