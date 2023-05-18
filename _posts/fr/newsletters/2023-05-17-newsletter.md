---
title: 'Bulletin Hebdomadaire Optech #251'
permalink: /fr/newsletters/2023/05/17/
name: 2023-05-17-newsletter-fr
slug: 2023-05-17-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
La publication de cette semaine décrit une proposition pour commencer
à testerla reconnaissance HTLC, transmet une demande de commentaires
sur les spécifications proposées pour les fournisseurs de services
Lightning (LSP), discute des défis liés à l'ouverture de canaux zéro-conf
lors de l'utilisation d'un double financement, examine une suggestion
pour des applications avancées de transactions payjoin, et des liens
vers des résumés d'une récente réunion en présentiel des développeurs
de Bitcoin Core. La lettre d'information de cette semaine contient
également la première partie d'une nouvelle série sur les politiques de
relais de transaction et d'inclusion de mempool, ainsi que nos sections
habituelles annonçant les nouvelles versions et les versions candidates
(y compris une version de sécurité de libsecp256k1) et décrivant les
changements notables apportés aux logiciels d'infrastructure Bitcoin
les plus répandus.

## Nouvelles

- **Test de l'approbation HTLC :** Il y a plusieurs semaines, Carla Kirk-Cohen
  et Clara Shikhelman ont [posté][kcs endorsement] sur la liste de diffusion
  Lightning-Dev à propos des prochaines étapes qu'elles et d'autres ont prévu
  de prendre pour tester l'idée de la validation [HTLC][topic htlc] (voir
  [Newsletter #239][news239 endorsement]) dans le cadre d'une atténuation des
  [attaques de brouillage de canal][topic channel jamming attacks]. Ils ont
  notamment fourni une courte [proposition de spécification] [bolts #1071] qui
  pourrait être déployée en utilisant un flag expérimental, empêchant les
  déploiements d'avoir un effet sur les interactions avec les nœuds
  non-participants.

    Une fois déployée par les expérimentateurs, il devrait être plus facile
    de répondre à l'une des [critiques constructives][decker endorsement] de
    cette idée, à savoir le nombre de paiements transférés qui bénéficieraient
    réellement de ce système. Si les principaux utilisateurs du réseau LN
    s'envoient fréquemment des paiements par les mêmes itinéraires et si le
    système de réputation fonctionne comme prévu, ce réseau central aura plus
    de chances de continuer à fonctionner en cas d'attaque par brouillage des
    canaux. Mais si la plupart des utilisateurs n'envoient que rarement des
    paiements (ou n'envoient que rarement leurs types de paiements les plus
    critiques, tels que les paiements de grande valeur), ils n'auront pas
    assez d'interactions pour construire une réputation, ou les données de
    réputation seront très en retard par rapport à l'état actuel du réseau
    (ce qui les rendra moins utiles ou permettra même d'abuser de la réputation).

- **Demande de commentaires sur les spécifications proposées pour les LSP :** Severin
  Bühler [a posté][buhler lsp] sur la liste de diffusion Lightning-Dev une
  demande de commentaires sur deux spécifications pour l'interopérabilité
  entre les fournisseurs de services Lightning (LSP) et leurs clients
  (généralement des nœuds LN non transmetteurs). La première spécification
  décrit une API permettant à un client d'acheter un canal à un LSP. La seconde
  décrit une API pour la mise en place et la gestion de canaux Just-In-Time (JIT),
  qui sont des canaux qui commencent leur vie en tant que canaux de paiement
  virtuels; lorsque le premier paiement au canal virtuel est reçu, le LSP
  diffuse une transaction qui ancrera le canal sur la chaîne lorsqu'il sera
  confirmé (le transformant en un canal normal).

    Dans une [réponse][zmnscpxj lsp], le développeur ZmnSCPxj s'est prononcé en
    faveur de spécifications ouvertes pour les LSP. Il a fait remarquer qu'elles
    permettent à un client de se connecter facilement à plusieurs LSP, ce qui
    empêchera le verrouillage des fournisseurs et améliorera la protection de la vie privée.

- **Difficultés liées aux canaux "zero-conf" en cas de double financement :** Bastien
  Teinturier a [posté][teinturier 0conf] sur la liste de diffusion Lightning-Dev à
  propos des défis que pose l'autorisation des [canaux zero-conf][topic zero-conf channels]
  lors de l'utilisation du [protocole dual-funding][topic dual funding]. Les canaux
  zéro-conf peuvent être utilisés avant même que la transaction d'ouverture du canal
  ne soit confirmée ; dans certains cas, cela ne nécessite aucune confiance. Les
  canaux à double financement sont des canaux qui ont été créés en utilisant le
  protocole de double financement, ce qui peut inclure des canaux où la transaction
  ouverte contient des contributions des deux parties du canal.

    L'absence de confiance n'est possible que lorsqu'une partie contrôle
    toutes les entrées de la transaction ouverte. Par exemple, Alice crée
    la transaction ouverte, donne à Bob des fonds dans le canal, et Bob
    essaie de dépenser ces fonds par l'intermédiaire d'Alice auprès de
    Carole. Alice peut transmettre le paiement à Carole en toute sécurité,
    car elle sait qu'elle a le contrôle de la transaction ouverte qui finira
    par être confirmée. Mais si Bob a également une entrée dans la transaction
    ouverte, il peut faire confirmer une transaction conflictuelle qui
    empêchera la transaction ouverte d'être confirmée---empêchant ainsi
    Alice d'être indemnisée pour l'argent qu'elle a transmis à Carole.

    Plusieurs idées visant à permettre l'ouverture de canaux à condition zéro
    avec un double financement ont été discutées, bien qu'aucune n'ait semblé
    satisfaisante aux participants au moment de la rédaction de ce document.

- **Applications avancées de payjoin :** Dan Gould a [posté][gould payjoin]
  sur la liste de diffusion Bitcoin-Dev plusieurs suggestions pour utiliser
  le protocole [payjoin][topic payjoin] pour faire plus qu'envoyer ou recevoir
  un simple paiement. Deux des suggestions les plus intéressantes sont des
  versions de [transaction cut-through][], une vieille idée pour améliorer
  la confidentialité, l'évolutivité et réduire les coûts :


    - *Transmission des paiements:* au lieu de payer Bob, Alice paie le vendeur
      de Bob (Carol), réduisant ainsi une dette qu'il lui doit (ou prépayant
      une facture future attendue).

    - *Transmission de paiements par lots:* au lieu de payer Bob, Alice paie
      plusieurs personnes à qui Bob doit de l'argent (ou avec qui il veut établir
      un crédit). L'exemple de Gould considère un échange qui a un flux régulier
      de dépôts et de retraits ; payjoin permet aux retraits d'être payés par
      de nouveaux dépôts lorsque c'est possible.

    Ces deux techniques permettent de réduire ce qui serait au moins deux
    transactions en une seule, ce qui permet d'économiser une quantité
    considérable d'espace dans les blocs. Lorsque le [traitement par
    lots][topic payment batching] est utilisé, les économies d'espace
    peuvent être encore plus importantes. Mieux encore, du point de vue
    du destinataire initial (par exemple Bob), le payeur initial (par
    exemple Alice) peut payer tout ou partie des frais. Au-delà des
    économies d'espace et de frais, le fait de retirer les transactions
    de la chaîne de blocs et de combiner des opérations telles que la
    réception et la dépense rend beaucoup plus difficile pour les
    organisations de surveillance de la chaîne de blocs de tracer de
    manière fiable le flux de fonds.

    À l'heure où nous écrivons ces lignes, le message n'a fait l'objet
    d'aucune discussion sur la liste de diffusion.

- **Résumé de la réunion en présentiel des développeurs de Bitcoin Core :** Plusieurs
  développeurs travaillant sur Bitcoin Core se sont récemment réunis pour
  discuter de certains aspects du projet. Les notes de plusieurs discussions
  de cette réunion ont été publiées. Les sujets abordés comprenaient [fuzz
  testing][], [assumeUTXO][], [ASMap][], [silent payments][], [libbitcoinkernel][],
  [refactoring (or not)][], et [package relay][]. Deux autres sujets méritant
  une attention particulière ont également été abordés :


    - [Mempool clustering][] résume une suggestion de refonte significative
      de la manière dont les transactions et leurs métadonnées sont stockées
      dans le mempool de Bitcoin Core. Les notes décrivent un certain nombre
      de problèmes avec la conception actuelle, fournissent une vue d'ensemble
      de la nouvelle conception, et suggèrent certains des défis et des compromis
      impliqués. Une [description][bitcoin core #27677] de la conception et une
      copie des [diapositives][mempool slides] de la présentation ont été
      publiées ultérieurement.

    - La [méta discussion sur le projet][] résume une discussion variée sur les
      objectifs du projet et la façon de les atteindre malgré de nombreux défis,
      internes et externes. Certaines de ces discussions ont déjà conduit à des
      changements expérimentaux dans la gestion du projet, tels qu'une approche
      plus centrée sur le projet pour la prochaine version majeure après la version 25.

## En attente de confirmation #1 : pourquoi avons-nous un mempool ?

_Le premier segment d'une série hebdomadaire limitée sur le relais de transaction,
l'inclusion dans le mempool et la sélection des transactions minières--- y compris
pourquoi Bitcoin Core a une politique plus restrictive que celle permise par le
consensus et comment les portefeuilles peuvent utiliser cette politique de la
manière la plus efficace._

{% include specials/policy/en/01-why-mempool.md %}

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets
d'infrastructure Bitcoin. Veuillez envisager de passer aux nouvelles
versions ou d'aider à tester les versions candidates.*

- [Libsecp256k1 0.3.2][] est une version de sécurité pour les applications
  qui utilisent libsecp pour [ECDH][] et qui peuvent être compilées avec
  GCC version 13 ou supérieure. Comme [décrit par les auteurs][secp ml],
  les nouvelles versions de GCC tentent d'optimiser le code libsecp qui a
  été conçu pour s'exécuter en un temps fixe, rendant possible l'exécution
  d'une [attaque par canal latéral][topic side channels] dans certaines
  circonstances. Il convient de noter que Bitcoin Core n'utilise pas ECDH
  et n'est pas affecté. Des travaux sont en cours pour tenter de détecter
  les modifications futures des compilateurs susceptibles de provoquer des
  problèmes similaires, ce qui permettrait d'effectuer des changements à l'avance.

- [Core Lightning 23.05rc2][] est une version candidate de la prochaine
  version de cette implémentation du LN.

- [Bitcoin Core 23.2rc1][] est une version candidate pour une version
  de maintenance. de maintenance de la version majeure précédente de Bitcoin Core.

- [Bitcoin Core 24.1rc3][] est une version candidate à la maintenance de la
  version actuelle de Bitcoin Core. de maintenance de la version actuelle de Bitcoin Core.

- [Bitcoin Core 25.0rc2][] est une version candidate de la prochaine version majeure de
  version majeure de Bitcoin Core.

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], et
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #26076][] met à jour les méthodes RPC qui montrent les chemins
  de dérivation pour les clés publiques utilisent maintenant `h` au lieu d'un
  simple guillemet `'` pour indiquer une étape de dérivation renforcée. Notez
  que cela modifie la somme de contrôle du descripteur. Lors de la gestion des
  descripteurs avec des clés privées, le même symbole est utilisé que lorsque
  le descripteur a été généré ou importé. Pour les anciens portefeuilles, le
  champ `hdkeypath` dans `getaddressinfo` et le format de sérialisation des
  dumps de portefeuilles restent inchangés.

- [Bitcoin Core #27608][] continuera à essayer de télécharger un bloc à partir
  d'un pair même si un autre pair a fourni le bloc. Bitcoin Core continuera à
  essayer de télécharger le bloc à partir des pairs qui prétendent l'avoir
  jusqu'à ce qu'un des blocs reçus ait été écrit sur le disque.

- [LDK #2286][] permet de créer et de signer des [PSBT][topic psbt] pour
  les sorties contrôlées par le portefeuille local.

- [LDK #1794][] commence à ajouter la prise en charge du [double financement][topic
  dual funding], en commençant par les méthodes nécessaires au protocole de
  financement interactif utilisé pour le double financement.

- [Rust Bitcoin #1844][] rend le schéma d'un URI [BIP21][] minuscule, c'est-à-dire
  `bitcoin:`. Bien que la spécification du schéma URI (RFC3986) indique que le
  schéma est insensible à la casse, les tests montrent que certaines plateformes
  n'ouvrent pas l'application assignée à la gestion des URI `bitcoin:` lorsqu'un
  `BITCOIN:` en majuscule est transmis. Il serait préférable que les majuscules
  soient gérées correctement, car cela permet de créer des codes QR plus efficaces
  (voir [Newsletter #46][news46 qr]).

- [Rust Bitcoin #1837][] ajoute une fonction pour générer une nouvelle clé privée,
  simplifiant ce qui nécessitait auparavant plus de code.

- [BOLTs #1075][] met à jour la spécification afin que les nœuds ne se déconnectent
  plus d'un pair après avoir reçu un message d'avertissement de sa part.

{% include references.md %}
{% include linkers/issues.md v=2 issues="26076,27608,2286,1794,1844,1837,1075,1071,27677" %}
[Core Lightning 23.05rc2]: https://github.com/ElementsProject/lightning/releases/tag/v23.05rc2
[bitcoin core 23.2rc1]: https://bitcoincore.org/bin/bitcoin-core-23.2/
[bitcoin core 24.1rc3]: https://bitcoincore.org/bin/bitcoin-core-24.1/
[bitcoin core 25.0rc2]: https://bitcoincore.org/bin/bitcoin-core-25.0/
[news239 endorsement]: /fr/newsletters/2023/02/22/#feedback-demande-sur-la-notation-de-bon-voisinage-des-ln
[fuzz testing]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-27-fuzzing/
[assumeutxo]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-27-assumeutxo/
[asmap]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-27-asmap/
[silent payments]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-26-silent-payments/
[libbitcoinkernel]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-26-libbitcoin-kernel/
[refactoring (or not)]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-25-refactors/
[package relay]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-25-package-relay-primer/
[mempool clustering]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-25-mempool-clustering/
[méta discussion sur le projet]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-26-meta-discussion/
[kcs endorsement]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-April/003918.html
[decker endorsement]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-May/003944.html
[buhler lsp]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-May/003926.html
[zmnscpxj lsp]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-May/003930.html
[teinturier 0conf]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-May/003920.html
[gould payjoin]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021653.html
[transaction cut-through]: https://bitcointalk.org/index.php?topic=281848.0
[news46 qr]: /en/newsletters/2019/05/14/#bech32-sending-support
[mempool slides]: https://github.com/bitcoin/bitcoin/files/11490409/Reinventing.the.Mempool.pdf
[secp ml]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021683.html
[libsecp256k1 0.3.2]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.3.2
[ecdh]: https://en.wikipedia.org/wiki/Elliptic-curve_Diffie%E2%80%93Hellman
