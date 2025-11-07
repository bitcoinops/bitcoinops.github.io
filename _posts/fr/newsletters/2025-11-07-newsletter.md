---
title: 'Bulletin Hebdomadaire Bitcoin Optech #379'
permalink: /fr/newsletters/2025/11/07/
name: 2025-11-07-newsletter-fr
slug: 2025-11-07-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine partage une analyse comparant la performance historique
des bibliothèques OpenSSL et libsecp256k1.
Sont également incluses nos sections régulières résumant les récentes discussions sur
la modification des règles de consensus de Bitcoin, annonçant des mises à jour et des versions candidates,
et décrivant les changements notables dans les projets d'infrastructure Bitcoin populaires.

## Nouvelles

- **Comparaison de la performance de la validation de signature ECDSA dans OpenSSL vs. libsecp256k1 :**
  Sebastian Falbesoner a [posté sur Delving][sebastion delving]
  une comparaison de la performance de la validation de signature ECDSA entre OpenSSL
  et libsecp256k1 au cours de la dernière décennie. Il mentionne que ce sera le 10ème
  anniversaire du passage de Bitcoin Core d'OpenSSL à libsecp256k1, et voulait
  imaginer une situation hypothétique dans laquelle Bitcoin Core n'aurait jamais changé.

  Dès le début, lorsque le changement a eu lieu, libsecp256k1 était 2,5 - 5,5 fois
  plus rapide qu'OpenSSL. Néanmoins, OpenSSL aurait pu s'améliorer au fil des ans,
  il était donc intéressant de tester pour voir comment il se comparait au cours de la décennie.

  La méthodologie consistait en trois étapes (analyser la clé publique compressée, analyser
  la signature encodée DER, vérifier la signature ECDSA) qui pouvaient être testées en utilisant
  des fonctions dans les deux bibliothèques. Un benchmark a été réalisé avec une liste de paires de
  clés pseudo-aléatoires. Il a exécuté le benchmark sur trois machines distinctes et a fourni un
  graphique en barres. Le graphique montrait qu'au fil des ans, libsecp256k1 s'était considérablement
  amélioré. Signifiant une amélioration d'environ ~28% de bc-0.19 à bc-0.20 et une autre
  amélioration d'environ ~30% de bc-0.20 à bc-22.0 tandis qu'OpenSSL était resté le même.

  Sebastian conclut qu'en dehors de l'écosystème Bitcoin, la courbe secp256k1 n'est
  pas si pertinente et ne compte pas comme un citoyen de première classe, ce qui
  justifierait les heures de travail pour l'améliorer. Il encourage également les lecteurs à essayer
  de reproduire ses résultats et à signaler tout problème avec sa méthodologie ou
  des différences trouvées dans leurs propres résultats. Le [code source][libsecp benchmark
  code] est disponible sur GitHub.

## Modification du consensus

_Une nouvelle section mensuelle résumant les propositions et discussions sur la modification des
règles de consensus de Bitcoin._

- **Plusieurs discussions sur la restriction des données** : plusieurs conversations
  ont examiné des idées pour changer les limites de divers champs dans le consensus :

  - *Limiter les scriptPubKeys à 520 octets* : PortlandHODL a [posté][ph 520spk post]
    une proposition à la liste de diffusion Bitcoin-Dev cherchant à limiter la
    taille de `scriptPubKey` à 520 octets dans le consensus. De manière similaire au BIP54 de [nettoyage du
    consensus][topic consensus cleanup], cela limiterait le coût maximal de vérification de bloc dans
    les cas limites de scripts hérités. Cela rendrait également
    impossible la création de segments de données contigus plus grands en utilisant `OP_RETURN`.
    Les retours sur l'idée incluaient des objections selon lesquelles ce changement aurait une plus
    grande surface de confiscation pour les anciens protocoles pré-signés par rapport au BIP54
    (qui limite également le coût maximal de vérification de bloc), et que cela fermerait
    certaines voies potentielles de [mise à niveau par soft fork][topic soft fork activation]
    (surtout autour de la [résistance quantique][topic quantum resistance]).

  - *Fork temporaire pour réduire les données* : Dathon Ohm a ouvert une PR (pull
    request) pour les BIPs [BIPs #2017] et a [publié][do post] sur la liste de diffusion Bitcoin-Dev une
    proposition visant à limiter temporairement les manières dont les transactions Bitcoin peuvent être
    utilisées pour encoder des données. Bien que le fork temporaire soit décrit comme [temporaire][topic
    transitory soft forks], la discussion sur la liste de diffusion et la demande de PR critique la
    grande surface de confiscation des changements proposés. De plus, bien qu'un fork temporaire soit
    possible, toute controverse entourant l'expiration du fork temporaire transforme cette expiration en
    un fork dur contentieux. Peter Todd a [illustré][pt post tx] les limites de cette approche en
    encodant le texte du BIP proposé dans une transaction Bitcoin qui serait valide sous les règles de
    consensus proposées.

- **Agrégation de signatures post-quantique** : Tadge Dryja a [publié][td post civ] sur la liste de
  diffusion Bitcoin-Dev une proposition pour un opcode `OP_CHECKINPUTVERIFY` (`OP_CIV`) qui permet à
  un script de verrouillage de s'engager sur un UTXO spécifique dépensé dans la même transaction. Cela
  permet à un groupe d'UTXOs liés d'être dépensés avec une seule autoritsation de signature, similaire en
  effet à [l'agrégation de signatures entre entrées][topic cisa]. Cette approche est plus coûteuse que
  des signatures ECDSA ou [BIP340][] séparées, mais économiserait des vbytes de transaction
  significatifs avec des signatures post-quantiques de plusieurs kilo-octets. `OP_CIV` pourrait
  également être utilisé pour des vérifications génériques d'entrées frères dans des protocoles comme
  [BitVM][topic acc]. D'autres propositions telles que `OP_CHECKCONTRACTVERIFY` pourraient être
  utilisées pour atteindre un schéma de partage de signature similaire en s'engageant sur des
  `scriptPubKeys` frères mais avec des compromis différents (et possiblement pires).

- **Vérification native de preuve STARK dans Bitcoin Script** : Abdelhamid Bakhta a [publié][abdel
  delving] sur Delving Bitcoin une proposition détaillée pour un nouveau opcode [tapscript][topic
  tapscript] `OP_STARK_VERIFY` qui permettrait la vérification d'une variante spécifique de preuve
  STARK dans Bitcoin Script. Cela permettrait d'incorporer la preuve de calculs arbitraires dans
  Bitcoin. L'opcode proposé ne lie pas les preuves à des données spécifiques à Bitcoin, donc les
  preuves sont simplement des preuves vérifiées de quelque calcul qu'elles intègrent elles-mêmes. Ces
  preuves peuvent être liées à des transactions Bitcoin spécifiques en utilisant d'autres méthodes de
  signature. Le post discute de divers cas d'utilisation tels que les [validity rollups][news222
  validity rollups].

- **Implémentation de BIP54 et vecteurs de test** : Antoine Poinsot a [publié][ap bip54 post] sur la
  liste de diffusion Bitcoin-Dev une mise à jour sur son travail de [nettoyage du consensus][topic
  consensus cleanup] sur [BIP54][] (voir le [Bulletin #348][news348 bip54] pour plus de détails). Il a
  ouvert [Bitcoin Inquisition #99][binq bip54 pr], mettant en œuvre les règles de consensus BIP54.
  Cette PR est accompagnée de tests unitaires pour chacune des quatre atténuations, qui peuvent être
  utilisés pour générer des vecteurs de test pour la proposition. De plus, elle contient un harnais de
  fuzzing pour la logique de comptabilité sigop et des tests fonctionnels qui imitent le comportement
  des atténuations dans des situations réalistes, y compris les violations historiques. En outre, un
  [mineur personnalisé][bip54 miner] a été développé pour générer une
  chaîne d'en-tête pleine nécessaire pour les vecteurs de test pour les atténuations nécessitant des blocs du
  réseau principal, tels que les restrictions de timestamp et de coinbase. Enfin, il a ouvert les [BIPs
  #2015][] pour ajouter les vecteurs de test générés à BIP54.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates._

- [Core Lightning 25.09.2][] est une version de maintenance pour la version majeure actuelle de ce
  nœud LN populaire qui inclut plusieurs corrections de bugs liés à `bookkeeper` et à `xpay`, dont
  certains sont résumés dans la section des changements de code et de documentation ci-dessous.

- [LND 0.20.0-beta.rc3][] est un candidat à la sortie pour ce nœud LN populaire. Une amélioration
  qui bénéficierait de tests est la correction du rescannage prématuré du portefeuille.

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core
lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust
Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo], [Propositions
d'Amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips
repo], [Inquisition Bitcoin][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #31645][] augmente la configuration `dbbatchsize` par défaut de 16 MB à 32 MB. Cette
  option détermine la taille du lot utilisée pour vider l'ensemble UTXO mis en cache en mémoire (tel
  que défini par `dbcache`) sur le disque après l'IBD ou un instantané [assumeUTXO][topic assumeutxo].
  Cette mise à jour bénéficie principalement aux disques durs et aux systèmes d'entrée de gamme. Par
  exemple, l'auteur rapporte une amélioration de 30 % du temps de vidage sur un Raspberry Pi avec un
  `dbcache` de 500. Les utilisateurs peuvent remplacer le paramètre par défaut s'ils le souhaitent.

- [Core Lightning #8636][] ajoute une configuration `askrene-timeout` (par défaut 10s) qui fait
  échouer `getroutes` une fois le délai atteint. Lorsque `maxparts` est réglé sur une valeur faible,
  `askrene` (voir le [Bulletin #316][news316 askrene]) peut entrer dans une boucle de réessai sur un
  itinéraire avec une capacité insuffisante. Cette PR désactive l'itinéraire goulot d'étranglement
  dans ce scénario pour assurer une progression.

- [Core Lightning #8639][] met à jour `bcli` pour utiliser `-stdin` lors de l'interface avec
  `bitcoin-cli` pour éviter les limites de taille `argv` (arguments de ligne de commande) dépendantes
  du système d'exploitation. Cette mise à jour résout un problème qui empêchait les utilisateurs de
  construire de grandes transactions (par exemple, [PSBTs][topic psbt] avec 700 entrées). D'autres
  améliorations des performances des grandes transactions ont également été apportées.

- [Core Lightning #8635][] met à jour la gestion du statut de paiement pour ne marquer une partie du
  paiement comme en attente qu'après la création du [HTLC][topic htlc] sortant lors de l'utilisation
  de `xpay` (voir le [Bulletin #330][news330 xpay]) ou
  `injectpaymentonion`. Auparavant, la partie paiement était marquée comme en attente d'abord, et si
  la création du HTLC échouait ensuite, l'élément pouvait rester indéfiniment en attente dans
  `listpays` ou `listsendpays`.

- [Eclair #3209][] ajoute une vérification pour s'assurer que les valeurs de taux de frais de
  routage ne peuvent pas être négatives. Auparavant, définir cette valeur déclenchait une fermeture
  forcée du canal.

- [Eclair #3206][] échoue immédiatement un [HTLC][topic htlc] entrant retenu lorsqu'un achat de
  [publicité de liquidité][topic liquidity advertisements] est abandonné après le début de la
  signature mais avant l'échange des signatures. Auparavant, Eclair ne gérait pas ce cas limite et ne
  faisait échouer le HTLC que peu de temps avant son expiration, immobilisant inutilement les fonds de
  l'expéditeur. Ce changement a été motivé par des cas où des portefeuilles mobiles non malveillants
  se déconnectaient et abandonnaient.

- [Eclair #3210][] met à jour son estimation de poids pour supposer des signatures codées DER de 73
  octets (voir le [Bulletin #6][news6 der]), s'alignant sur la spécification [BOLT3][] et avec d'autres
  implémentations, telles que LDK. Cela garantit que les pairs qui supposent également cette taille ne
  rejettent jamais une tentative de `interactive-tx` d'Eclair en raison d'un sous-paiement des frais.
  Eclair ne génère jamais ces signatures non standard.

- [LDK #4140][] corrige les fermetures forcées prématurées pour les paiements [asynchrones][topic
  async payments] sortants lorsqu'un nœud redémarre. Auparavant, lorsqu'un nœud souvent hors ligne
  revenait en ligne et qu'un [HTLC][topic htlc] sortant était `LATENCY_GRACE_PERIOD_BLOCKS` (3 blocs)
  après son [expiration CLTV][topic cltv expiry delta], LDK procédait à une fermeture forcée
  immédiatement, avant que le nœud puisse se reconnecter et permettre au pair d'échouer le HTLC. Dans
  ce scénario, puisque le nœud ne cherche pas à réclamer un HTLC entrant de manière urgente, LDK
  ajoute une période de grâce de 4 032 blocs après l'expiration CLTV du HTLC avant de procéder à une
  fermeture forcée.

- [LDK #4168][] supprime le drapeau sur `read_event` qui signale la pause de la lecture des messages
  du pair. Cela fait de `send_data` la seule source de vérité pour les signaux de pause/reprise. Cela
  corrige une condition de concurrence où un nœud pourrait recevoir un signal de pause tardif de
  `read_event` après que `send_data` avait déjà repris la lecture. La pause tardive laisserait la
  lecture désactivée indéfiniment jusqu'à ce que le nœud envoie un message à ce pair à nouveau.

- [Rust Bitcoin #5116][] met à jour les réponses de `compute_merkle_root` et `compute_witness_root`
  pour retourner `None` lorsque la liste des transactions contient des doublons adjacents. Cela
  prévient la vulnérabilité de [racine de merkle mutée][topic merkle tree vulnerabilities], CVE
  2012-2459, où un bloc invalide avec une transaction dupliquée peut partager la même racine de merkle
  (et hash de bloc) qu'un bloc valide, conduisant Rust Bitcoin à confondre et rejeter les deux. Cette
  solution est inspirée d'une solution similaire dans Bitcoin Core.

- [BTCPay Server #6922][] introduit `Subscriptions`, à travers lesquelles les commerçants peuvent
  définir des offres et des plans de paiement récurrents ainsi que recruter des utilisateurs via un
  processus de paiement. Le système suit le solde de crédit de chaque abonné, qui est déduit à chaque
  période de facturation. Un portail d'abonné est inclus où les utilisateurs peuvent améliorer ou
  réduire leur plan, voir leurs crédits, l'historique, et
  reçus. Les commerçants peuvent configurer des alertes par email pour notifier les utilisateurs
  lorsqu'un paiement est presque dû. Bien que cela n'introduise pas de prélèvements automatiques, une
  intégration [Nostr Wallet Connect (NWC)][news290 nwc] prévue pourrait rendre cela possible pour
  certains portefeuilles.

{% include snippets/recap-ad.md when="2025-11-11 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2015,2017,31645,8636,8639,8635,3209,3206,3210,4140,4168,5116,6922" %}
[sebastion delving]: https://delvingbitcoin.org/t/comparing-the-performance-of-ecdsa-signature-validation-in-openssl-vs-libsecp256k1-over-the-last-decade/2087
[libsecp benchmark code]: https://github.com/theStack/secp256k1-plugbench
[ph 520spk post]: https://gnusha.org/pi/bitcoindev/6f6b570f-7f9d-40c0-a771-378eb2c0c701n@googlegroups.com/
[do post]: https://gnusha.org/pi/bitcoindev/AWiF9dIo9yjUF9RAs_NLwYdGK11BF8C8oEArR6Cys-rbcZ8_qs3RoJURqK3CqwCCWM_zwGFn5n3RECW_j5hGS01ntGzPLptqcOyOejunYsU=@proton.me/
[pt post tx]: https://gnusha.org/pi/bitcoindev/aP6gYSnte7J86g0p@petertodd.org/
[td post civ]: https://gnusha.org/pi/bitcoindev/05195086-ee52-472c-962d-0df2e0b9dca2n@googlegroups.com/
[abdel delving]: https://delvingbitcoin.org/t/proposal-op-stark-verify-native-stark-proof-verification-in-bitcoin-script/2056
[news222 validity rollups]: /fr/newsletters/2022/10/19/#recherche-sur-les-rollups-de-validite
[ap bip54 post]: https://groups.google.com/g/bitcoindev/c/1XEtmIS_XRc
[news348 bip54]: /fr/newsletters/2025/04/04/#brouillon-de-bip-publie-pour-le-nettoyage-du-consensus
[binq bip54 pr]: https://github.com/bitcoin-inquisition/bitcoin/pull/99
[bip54 miner]: https://github.com/darosior/bitcoin/commits/bip54_miner/
[LND 0.20.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.0-beta.rc3
[Core Lightning 25.09.2]: https://github.com/ElementsProject/lightning/releases/tag/v25.09.2
[news316 askrene]: /fr/newsletters/2024/08/16/#core-lightning-7517
[news330 xpay]: /fr/newsletters/2024/11/22/#core-lightning-7799
[news6 der]: /en/newsletters/2018/07/31/#the-maximum-size-of-a-bitcoin-der-encoded-signature-is
[news290 nwc]: /fr/newsletters/2024/02/21/#annonce-du-protocole-de-coordination-multipartie-nwc
