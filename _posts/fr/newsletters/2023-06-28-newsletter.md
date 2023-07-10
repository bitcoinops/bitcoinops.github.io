---
title: 'Bulletin hebdomadaire Bitcoin Optech #257'
permalink: /fr/newsletters/2023/06/28/
name: 2023-06-28-newsletter-fr
slug: 2023-06-28-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume une idée pour empêcher l'épinglage des
transactions coinjoin et décrit une proposition pour utiliser de manière
spéculative les changements de consensus espérés. Vous y trouverez également
une nouvelle contribution à notre série hebdomadaire limitée sur la politique
de mempool, ainsi que nos sections régulières concernant les questions et
réponses populaires sur le Bitcoin Stack Exchange, les nouvelles versions et
les versions candidates, et les changements apportés aux principaux logiciels
de l'infrastructure Bitcoin.

## Nouvelles

- **Prévenir l'épinglage des coinjoin avec le relais de transaction v3 :** Greg
  Sanders a [posté][sanders v3cj] sur la liste de diffusion Bitcoin-Dev une
  description de la manière dont les [règles de relais de transaction v3][topic v3 transaction relay]
  proposées pourraient permettre de créer une transaction multipartite de type
  [coinjoin][topic coinjoin] qui ne serait pas vulnérable à l'[épinglage de transaction][topic transaction pinning].
  Le problème spécifique de l'épinglage est que l'un des participants à une coinjoin
  peut utiliser sa contribution à la transaction pour créer une transaction conflictuelle
  qui empêche la transaction coinjoin de se confirmer.

    Sanders propose que les transactions de type coinjoin puissent éviter
    ce problème en demandant à chaque participant de dépenser initialement
    ses bitcoins dans un script qui ne peut être dépensé que par une signature
    de tous les participants au coinjoin ou par le seul participant après
    l'expiration d'un timelock. Par ailleurs, dans le cas d'un coinjoin coordonné,
    le coordinateur et le participant doivent signer ensemble (ou le participant
    seul après l'expiration du timelock).

    Jusqu'à l'expiration du délai, le participant doit maintenant obtenir
    des autres parties ou du coordinateur qu'ils cosignent toute transaction
    conflictuelle, ce qu'ils ne feront probablement pas, à moins que la
    signature ne soit dans l'intérêt de tous les participants (par exemple,
    un [fee bump][topic rbf]). {% assign timestamp="16:08" %}

- **Spéculer en utilisant les changements de consensus espérés :** Robin Linus
  a [posté][linus spec] sur la liste de diffusion Bitcoin-Dev une idée pour
  dépenser de l'argent dans un fragment de script qui ne peut pas être exécuté
  pendant une longue période (par exemple 20 ans). Si ce fragment de script est
  interprété selon les règles actuelles de consensus, il permettra aux mineurs
  dans 20 ans de réclamer tous les fonds qui lui ont été versés. Toutefois, le
  fragment est conçu de manière à ce qu'une mise à jour des règles de consensus
  lui donne une signification différente. Linus donne l'exemple d'un opcode
  `OP_ZKP_VERIFY` qui, s'il est ajouté à Bitcoin, permettra à toute personne
  fournissant une preuve de zéro connaissance (ZKP) pour un programme avec un
  hachage particulier de réclamer les fonds.

    Cela pourrait permettre aux gens de dépenser aujourd'hui des BTC dans
    l'un de ces scripts et d'utiliser la preuve de cette dépense pour recevoir
    un montant équivalent de BTC sur une [sidechain][topic sidechains] ou une
    chaîne alternative, appelée _one-way peg_. Les BTC sur l'autre chaîne peuvent
    être dépensés de manière répétée pendant 20 ans, jusqu'à ce que le timelock
    du script expire. Ensuite, le propriétaire actuel des BTC sur l'autre chaîne
    pourrait générer une preuve ZKP qu'il les possède et utiliser cette preuve
    pour retirer le dépôt bloqué sur le réseau principal de Bitcoin, créant ainsi
    un _two-way peg_. Avec une bonne conception du programme de vérification, le
    retrait serait simple et flexible, ce qui permettrait des retraits fongibles.

    Les auteurs notent que toute personne qui bénéficierait de cette construction
    (par exemple, qui reçoit des BTC sur une autre chaîne) fait en fait le pari que
    les règles de consensus de Bitcoin seront modifiées (par exemple, `OP_ZKP_VERIFY`
    sera ajouté). Cela les incite à plaider en faveur du changement, mais en incitant
    fortement certains utilisateurs à changer le système, d'autres utilisateurs pourraient
    avoir l'impression d'être contraints. L'idée n'a fait l'objet d'aucune discussion
    sur la liste de diffusion au moment de la rédaction de ce document. {% assign timestamp="1:33" %}

## En attente de confirmation #7 : Ressources du réseau

_Une [série][policy series] hebdomadaire limitée sur le relais de transaction,
l'inclusion dans le mempool et la sélection des transactions minières---y compris
pourquoi Bitcoin Core a une politique plus restrictive que celle permise par le
consensus et comment les portefeuilles peuvent utiliser cette politique de la
manière la plus efficace._

{% include specials/policy/en/07-network-resources.md %} {% assign timestamp="24:46" %}

## Sélection de Q&R du Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs
d'Optech cherchent des réponses à leurs questions---ou lorsque nous avons quelques moments
libres pour aider les utilisateurs curieux ou confus. Dans cette rubrique mensuelle, nous
mettons en avant certaines des questions et réponses les plus appréciées, postées depuis
notre dernière mise à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Pourquoi les nœuds Bitcoin acceptent-ils des blocs contenant autant de transactions exclues ?]({{bse}}118707)
  L'utilisateur commstark se demande pourquoi un nœud accepte un bloc de mineurs
  qui exclut les transactions prévues pour ce bloc selon le [modèle de bloc][reference getblocktemplate]
  de ce nœud. Il existe divers [outils][miningpool observer] qui [montrent][mempool space]
  les blocs prévus par rapport aux blocs réels. Pieter Wuille souligne qu'en raison de la
  variance inhérente aux [mempools][waiting for confirmation 1] des différents nœuds liée
  à la propagation des transactions, il n'est pas possible d'établir une règle de consensus
  imposant le contenu des blocs. {% assign timestamp="57:38" %}

- [Pourquoi tout le monde prétend-il que les fourches souples restreignent l'ensemble des règles existantes ?]({{bse}}118642)
  Pieter Wuille utilise les règles ajoutées lors des [activations][topic soft fork activation]
  des soft fork [taproot][topic taproot] et [segwit][topic segwit] comme exemples
  de renforcement des règles de consensus :

  - taproot a ajouté l'exigence que les dépenses de sortie `OP_1 <32 bytes>` (taproot)
    adhèrent aux règles de consensus de taproot.
  - segwit a ajouté l'exigence que `OP_{0..16} <2..40 bytes>` (segwit) adhèrent aux
    règles de consensus segwit et exigent également des données témoins vides pour
    les sorties pré-segwit. {% assign timestamp="1:05:28" %}

- [Pourquoi la limite par défaut du canal LN est-elle fixée à 16777215 sats ?]({{bse}}118709)
  Vojtěch Strnad explique l'histoire de la limite de 2^24 satoshi et la motivation
  pour les grands canaux (wumbo). Il renvoie également au [thème des grands canaux][topic large channels]
  d'Optech pour plus d'informations. {% assign timestamp="1:07:47" %}

- [Pourquoi Bitcoin Core utilise-t-il le score de l'ancêtre au lieu du taux de frais de l'ancêtre pour sélectionner les transactions ?]({{bse}}118611)
  Sdaftuar explique que l'optimisation des performances est la raison pour laquelle
  l'algorithme de sélection des transactions du modèle de bloc minier utilise à la fois
  le taux de frais  d'ancêtres et le score d'ancêtres. (Voir
  [En attente de confirmation n° 2 : Incitations][waiting for confirmation 2]). {% assign timestamp="1:10:28" %}

- [Comment le protocole Lightning multipart payments (MPP) définit-il les montants par part ?]({{bse}}117405)
  Rene Pickhardt souligne que [les paiements par trajets multiples][topic multipath payments]
  n'ont pas de taille de part spécifiée par le protocole ou d'algorithme pour choisir la taille
  de la part et indique quelques recherches pertinentes sur le fractionnement des paiements. {% assign timestamp="1:14:15" %}

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets d’infrastructure Bitcoin.
 Veuillez envisager de passer aux nouvelles versions ou d’aider à tester les versions candidates.*

- [BTCPay Server 1.10.3][] est la dernière version de ce logiciel de traitement de paiement
  auto-hébergé. Consultez leur [billet de blog][btcpay 1.10] pour une visite des principales
  fonctionnalités de la branche 1.10. {% assign timestamp="1:16:08" %}

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], et
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Core Lightning #6303][] ajoute une nouvelle RPC `setconfig` qui permet
  de changer certaines options de configuration sans redémarrer le démon. {% assign timestamp="1:21:14" %}

- [Eclair #2701][] commence l'enregistrement à la fois au moment où un
  [HTLC][topic htlc] offert est reçu et au moment où il est réglé. Cela
  permet de savoir combien de temps le HTLC a été en attente du point de
  vue du nœud. Si de nombreux HTLC, ou quelques HTLC de grande valeur,
  sont en attente pendant de longues périodes, cela peut indiquer qu'une
  [attaque par brouillage de canal][topic channel jamming attacks] est en
  cours. Le suivi de la durée des HTLC permet de détecter de telles attaques
  et peut contribuer à les atténuer. {% assign timestamp="1:22:21" %}

- [Eclair #2696][] modifie la façon dont Eclair permet aux utilisateurs de
  configurer les taux de frais à utiliser. Auparavant, les utilisateurs pouvaient
  spécifier la vitesse à utiliser avec un _block target_, par exemple, un
  réglage de "6" signifiait qu'Eclair essaierait de faire confirmer une
  transaction dans un délai de six blocs. Désormais, Eclair accepte les
  termes "lent", "moyen" et "rapide", qu'il traduit en taux de frais spécifiques
  à l'aide de constantes ou de cibles de blocs. {% assign timestamp="1:25:03" %}

- [LND #7710][] ajoute la possibilité pour les plugins (ou le démon lui-même)
  de récupérer les données reçues plus tôt dans un HTLC. Ceci est nécessaire pour
  le [route aveugle][topic rv routing] et peut être utilisé par diverses contre-mesures
  de [brouillage de canal][topic channel jamming attacks], parmi d'autres idées
  pour de futures fonctionnalités. {% assign timestamp="1:26:51" %}

- [LDK #2368][] permet d'accepter de nouveaux canaux créés par un pair qui utilise
  des [sorties d'ancrage][topic anchor outputs] mais exige que le programme de contrôle
  choisisse délibérément d'accepter chaque nouveau canal. En effet, pour régler correctement
  un canal d'ancrage, l'utilisateur doit avoir accès à un ou plusieurs UTXO de valeur suffisante.
  LDK, en tant que bibliothèque ignorant quels UTXOs non-LN le portefeuille de l'utilisateur
  contrôle, utilise cette requête pour donner au programme de contrôle une chance de vérifier
  qu'il a les UTXOs nécessaires. {% assign timestamp="1:27:43" %}

- [LDK #2367][] rend les [canaux d'ancrage][topic anchor outputs] accessibles aux consommateurs
  réguliers de l'API. {% assign timestamp="1:33:34" %}

- [LDK #2319][] permet à un pair de créer un HTLC qui s'engage à payer moins que le montant que
  le contributeur original a dit devoir être payé, ce qui permet au pair de garder la différence
  pour lui-même en tant que frais supplémentaires. Ceci est utile pour la création de [JIT channels][topic jit channels]
  où un pair reçoit un HTLC pour un destinataire qui n'a pas encore de canal. Le pair crée une
  transaction onchain qui finance le canal et s'engage dans le HTLC au sein de ce canal---mais
  il encourt des frais de transaction supplémentaires en créant cette transaction onchain. En prenant
  des frais supplémentaires, il est compensé pour ses coûts si le destinataire accepte le nouveau canal
  et règle le HTLC à temps. {% assign timestamp="1:34:40" %}

- [LDK #2120][] ajoute la prise en charge de la recherche d'un itinéraire vers un destinataire
  qui utilise des [chemins aveugles][topic rv routing]. {% assign timestamp="1:37:09" %}

- [LDK #2089][] ajoute un gestionnaire d'événement qui permet aux portefeuilles de déclencher
  facilement les [HTLC][topic htlc] qui doivent être réglés onchain. {% assign timestamp="1:38:12" %}

- [LDK #2077][] remanie une grande partie du code pour faciliter l'ajout ultérieur de la prise
  en charge des [canaux à double financement][topic dual funding]. {% assign timestamp="1:39:08" %}

- [Libsecp256k1 #1129][] implémente la technique [ElligatorSwift][ElligatorSwift paper] pour introduire
  un encodage de clé publique de 64 octets qui est informatiquement indiscernable des données aléatoires.
  Le module `ellswift` fournit des fonctions pour encoder et décoder les clés publiques dans le nouveau
  format ainsi que des fonctions de commodité pour générer de nouvelles clés uniformément aléatoires et
  effectuer un échange de clés Diffie-Hellman à courbe elliptique (ECDH) sur les clés encodées ellswift.
  L'ECDH basé sur ellswift doit être utilisé pour établir des connexions pour le protocole [transport P2P
  chiffré version 2] [topic v2 p2p transport] ([BIP324][]). {% assign timestamp="1:40:37" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="6303,2701,2696,7710,2368,2367,2319,2120,2089,2077,1129" %}
[policy series]: /en/blog/waiting-for-confirmation/
[sanders v3cj]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021780.html
[linus spec]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021781.html
[BTCPay Server 1.10.3]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.10.3
[btcpay 1.10]: https://blog.btcpayserver.org/btcpay-server-1-10-0/
[miningpool observer]: https://miningpool.observer/template-and-block
[mempool space]: https://mempool.space/graphs/mining/block-health
[waiting for confirmation 1]: /fr/newsletters/2023/05/17/#en-attente-de-confirmation-1--pourquoi-avons-nous-un-mempool-
[reference getblocktemplate]: https://developer.bitcoin.org/reference/rpc/getblocktemplate.html
[waiting for confirmation 2]: /fr/newsletters/2023/05/24/#en-attente-de-confirmation-2--mesures-dincitation
[ElligatorSwift paper]: https://eprint.iacr.org/2022/759
