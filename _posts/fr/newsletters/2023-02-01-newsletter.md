---
title: 'Bulletin Hebdomadaire Bitcoin Optech #236'
permalink: /fr/newsletters/2023/02/01/
name: 2023-02-01-newsletter-fr
slug: 2023-02-01-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume une proposition de payjoin sans serveur
et décrit une idée pour autoriser la preuve de paiement pour les paiements
asynchrones LN. Vous trouverez également notre section habituelle avec des
descriptions des changements notables apportés aux principaux logiciels
d'infrastructure Bitcoin.

## Nouvelles

- **Proposition de payjoin sans serveur :** Dan Gould a [posté][gould payjoin]
  sur la liste de diffusion Bitcoin-Dev une proposition et [une implémentation
  de preuve de concept][payjoin impl] pour une version sans serveur de
  [BIP78][], le protocole [payjoin][topic payjoin].

  Sans payjoin, un paiement Bitcoin typique n'inclut que les entrées de
  l'expéditeur, ce qui conduit les organisations de surveillance des
  transactions à adopter l'[heuristique de propriété des entrées communes][],
  selon laquelle elles supposent que toutes les entrées d'une transaction
  appartiennent au même portefeuille. Payjoin brise cette heuristique en
  permettant au destinataire de contribuer au paiement. Cela apporte une
  amélioration immédiate de la confidentialité aux utilisateurs de Payjoin
  et, de manière générale, améliore la confidentialité de tous les
  utilisateurs de Bitcoin en rendant l'heuristique moins fiable.

  Cependant, payjoin n'est pas aussi flexible que les paiements Bitcoin
  classiques. La plupart des paiements typiques peuvent être envoyés
  lorsque le destinataire est hors ligne, mais payjoin exige que le
  destinataire soit en ligne pour contribuer et signer pour ses entrées.
  Le protocole payjoin existant exige également que le destinataire
  accepte les requêtes HTTP à une adresse réseau accessible à l'expéditeur,
  ce qui est généralement réalisé par le destinataire qui exécute un
  serveur Web sur une adresse IP publique contenant un logiciel compatible
  avec payjoin. Comme mentionné dans le [bulletin n°132][news132 payjoin],
  une suggestion pour augmenter l'utilisation de payjoin serait d'autoriser
  payjoin sur une base plus P2P entre les portefeuilles typiques des
  utilisateurs finaux.

  Gould suggère d'intégrer aux portefeuilles compatibles avec payjoin un
  serveur HTTP léger prenant en charge le cryptage par le [protocole de
  bruits][] et permettant d'utiliser le [protocole TURN][] pour traverser
  le [NAT][]. Cela permettrait à deux portefeuilles de communiquer de
  manière interactive pendant la brève période nécessaire pour créer un
  paiement payjoin, sans avoir besoin d'un serveur web à long terme.
  Cela ne permet pas de créer des payjoins lorsque le récepteur est
  hors ligne, bien que Gould suggère d'étudier le [protocole nostr][]
  pour de futures propositions visant à permettre un "payjoin asynchrone".

  Au moment où nous écrivons ces lignes, aucune réponse à la proposition
  n'a été postée sur la liste de diffusion.

- **Preuve de paiement asynchrone LN :** Comme indiqué dans [le bulletin
  de la semaine dernière][news235 async], les développeurs de LN recherchent
  une méthode pour envoyer des [paiements asynchrones][topic async payments]
  qui fournissent à l'expéditeur la preuve qu'il a payé le destinataire.
  Un paiement asynchrone permet à un expéditeur (Alice) d'envoyer un paiement
  LN à un destinataire (Bob) par le biais d'une série normale de sauts
  d'acheminement---y compris un fournisseur de services Lightning (LSP)
  qui conservera le paiement pour Bob s'il est hors ligne à ce moment-là.
  Lorsque Bob informe le LSP qu'il est de nouveau en ligne, le LSP commence
  à transmettre le paiement à Bob.

  Le problème que pose cette approche dans le réseau local LN actuel basé
  sur [HTLC][topic htlc] est que, si Bob est hors ligne, il ne peut pas
  fournir à Alice une facture spécifique au paiement qui fait référence
  à un secret qu'il a choisi. Alice peut choisir son propre secret et
  l'inclure dans le paiement asynchrone qu'elle envoie à Bob---c'est ce
  qu'on appelle un paiement [keysend][topic spontaneous payments]---mais
  comme Alice connaissait le secret du keysend depuis le début, elle ne
  peut pas l'utiliser comme preuve qu'elle a payé Bob.
  Alternativement, Bob pourrait pré-générer plusieurs factures
  standards et les donner à son LSP, qui pourrait les distribuer à des
  acheteurs potentiels comme Alice. Le paiement de ces factures générerait
  une preuve de paiement lorsque Bob l'accepterait finalement,
  mais cela permettrait au LSP de distribuer la même facture à plusieurs
  acheteurs, les amenant tous à payer le même secret. Lorsque le LSP
  apprend le secret après que Bob a accepté le premier de ces
  paiements, il est en mesure de voler les fonds pour le reste des
  paiements de la facture réutilisée---ce qui rend la solution de la
  facture pré-générée pour les HTLC sûre uniquement si Bob fait confiance
  à son LSP.

  Cette semaine, Anthony Towns a [proposé][towns async] une solution
  basée sur les [adaptateurs de signature][topic adaptor signatures].
  Cette solution dépendrait de la mise à niveau prévue de LN pour
  utiliser les [PTLC][topic ptlc]. Bob pré-générerait une série de
  nonces de signature et les donnerait à son LSP. Le LSP donnerait
  un nonce de signature à Alice, Alice choisirait un message pour sa
  preuve de paiement (par exemple "Alice a payé Bob 1000 sats à
  2023-02-01 12:34:56Z"), puis utiliserait le nonce de Bob et son
  message pour générer un adaptateur de signature pour son PTLC.
  Lorsque Bob revient en ligne, le LSP lui transmet le paiement et
  Bob vérifie que le nonce n'a pas été utilisé auparavant, qu'il est
  d'accord avec le message, que le paiement est par ailleurs valide
  et que le calcul de l'adaptateur de signature est valide ; il accepte
  alors le paiement et Alice, lorsqu'elle recevra finalement le PTLC
  réglé, aura une signature de Bob qui s'engage sur le message
  qu'elle a choisi.

  La solution de Towns implique que le LSP reçoive des factures
  pré-générées de Bob---ce qui est similaire à la solution non
  sécurisée/de confiance pour les HTLC, pourtant la solution de
  l'adaptateur de signature PTLC est sécurisée et sans confiance
  car chaque paiement d'un expéditeur différent (comme Alice)
  utilise un point de clé publique PTLC différent et Bob est
  capable d'empêcher la réutilisation des nonces. Chaque point
  PTLC est différent car il dérive d'un message unique sélectionné
  par chaque expéditeur. Bob peut empêcher la réutilisation des
  nonces en vérifiant l'absence de nonces réutilisés avant
  d'accepter chaque paiement.

  Dans son message, Towns [fait référence][towns sa1] à deux messages
  [précédents][towns sa2] de la liste de diffusion qu'il a écrits sur
  la preuve de paiement LN à l'aide d'adaptateurs de signature. Au
  moment où nous écrivons ces lignes, aucune réponse à cette idée n'a
  été postée sur la liste de diffusion.

## Principaux changements de code et de documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], et [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #26471][] réduit la capacité par défaut du mempool à 5 Mo
  (au lieu de 300 Mo) lorsqu'un utilisateur active le mode `-blocksonly`.
  Comme la mémoire inutilisée de mempool est partagée avec dbcache, ce
  changement réduit également la taille par défaut de dbcache en mode
  `-blocksonly`. Les utilisateurs peuvent toujours configurer une plus
  grande capacité de mempool en utilisant l'option `-maxmempool`.

- [Bitcoin Core #23395][] ajoute une option de configuration `-shutdownnotify`
  à `bitcoind` qui exécute une commande utilisateur personnalisée lorsque
  `bitcoind` s'arrête normalement (la commande ne sera pas exécutée
  pendant un crash).

- [Eclair #2573][] commence à accepter les paiements [keysend][topic
  spontaneous payments] qui ne contiennent pas de [paiement secret][topic
  payment secrets] même si Eclair annonce que le secret de paiement
  est obligatoire. Selon la description de la demande de retrait,
  LND et Core Lightning envoient tous deux des paiements par clé
  sans secret de paiement. Les secrets de paiement ont été conçus
  pour supporter les [paiements multipartite][topic multipath payments],
  donc Eclair laisse à ces autres implémentations de nœuds le soin
  de s'assurer qu'ils n'envoient que des paiements par clé de
  répartition à chemin unique.

- [Eclair #2574][], concernant la demande de modification ci-dessus,
  cesse d'inclure les secrets de paiement dans les paiements keysend
  qu'il envoie. Selon la description de la demande de modification,
  le LND rejette les paiements keysend qui contiennent un secret de
  paiement, même si de tels rejets ne sont pas décrits dans la
  spécification [BLIP3][] de keysend.

- [Eclair #2540][] apporte plusieurs changements à la façon dont Eclair
  stocke les données sur les transactions de financement et d'engagement
  en vue de l'ajout ultérieur de la prise en charge de l'[épissurage][topic
  splicing]. Voir [#2584][eclair #2584] pour le projet actuel de demande
  de modification qui ajouterait le support expérimental de l'épissurage.

- [LND #7231][] ajoute des RPC et des options à `lncli` pour signer et
  vérifier les messages. Pour P2PKH, le format est compatible avec le RPC
  `signmessage` ajouté pour la première fois à Bitcoin Core en 2011. Pour
  les P2WPKH et P2SH-P2WPKH (également appelés Nested P2PKH ou NP2PKH),
  le même format est utilisé. Dans ce format, il est prévu que la signature
  soit au format ECDSA et que la vérification nécessite de dériver la clé
  publique de la signature. Pour les adresses P2TR, qui seraient normalement
  utilisées avec les [signatures schnorr][topic schnorr signatures], il
  n'est pas possible de dériver la clé publique de la signature si
  l'algorithme de signature schnorr de Bitcoin est utilisé. À la place,
  des signatures ECDSA sont générées et vérifiées pour les adresses P2TR.

  Note: Optech [déconseille généralement][p4tr new hd] l'utilisation
  de fonctions de signature ECDSA avec des clés destinées à être
  utilisées avec des signatures schnorr, mais les développeurs de LND
  ont pris des [mesures de précaution supplémentaires][osuntokun sigs]
  pour éviter les problèmes.

- [LDK #1878][] ajoute la possibilité de définir une valeur `min_final_cltv_expiry`
  par paiement (plutôt que globale). Cette valeur détermine le nombre maximum
  de blocs dont dispose le destinataire pour réclamer un paiement avant qu'il
  n'expire. La valeur par défaut est de 18 blocs, mais les destinataires
  peuvent demander un délai supplémentaire en définissant un paramètre
  dans une facture [BOLT11][].

  Pour que LDK puisse prendre en charge cette fonctionnalité en combinaison
  avec son implémentation unique des [factures sans état][topic stateless
  invoices], LDK code la valeur dans le [secret de paiement][topic payment
  secrets] que l'expéditeur est obligé d'envoyer. Il fournit 12 bits pour
  la valeur d'expiration, ce qui permet des expirations allant jusqu'à
  4 096 blocs (environ 4 semaines).

- [LDK #1860][] ajoute la prise en charge des canaux utilisant des
  [sorties d'ancrage][topic anchor outputs].

{% include references.md %}
{% include linkers/issues.md v=2 issues="26471,23395,2573,2574,2584,2540,1878,1860,7231" %}
[heuristique de propriété des entrées communes]: https://en.bitcoin.it/wiki/Privacy#Common-input-ownership_heuristic
[news132 payjoin]: /en/newsletters/2021/01/20/#payjoin-adoption
[gould payjoin]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-January/021364.html
[payjoin impl]: https://github.com/chaincase-app/payjoin/pull/21
[protocole de bruits]: http://www.noiseprotocol.org/
[protocole turn]: https://en.wikipedia.org/wiki/Traversal_Using_Relays_around_NAT
[nat]: https://en.wikipedia.org/wiki/Network_address_translation
[protocole nostr]: https://github.com/nostr-protocol/nostr
[news235 async]: /en/newsletters/2023/01/25/#request-for-proof-that-an-async-payment-was-accepted
[towns async]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-January/003831.html
[towns sa1]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-February/001034.html
[towns sa2]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001490.html
[osuntokun sigs]: https://github.com/lightningnetwork/lnd/pull/7231#issuecomment-1407138812
[p4tr new hd]: /en/preparing-for-taproot/#use-a-new-bip32-key-derivation-path
