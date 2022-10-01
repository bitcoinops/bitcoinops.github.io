---
title: 'Bitcoin Optech Newsletter #218'
permalink: /fr/newsletters/2022/09/21/
name: 2022-09-21-newsletter-fr
slug: 2022-09-21-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Cette semaine la newsletter résume une discussion à propos de l'utilisation
de `SIGHASH_ANYPREVOUT` pour reproduire des aspects des chaines dérivées.
Sont inclus aussi nos sections habituelles abordant les derniers changements
notables apportés aux principaux projets d'infrastructures Bitcoin.

## Nouvelles

- **Créer des drivechains avec APO et une installation en confiance:** Jeremy Rubin
  [a posté][rubin apodc] sur la liste de diffusion Bitcoin-Dev la description
  d'une procédure pour une installation en confiance qui pourrait être combinée avec
  la proposition d'opcode [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] pour implémenter
  un comportement similaire à celui proposé par les [drivechains][topic sidechains].
  Les drivechains sont un type de chaines dérivées où les mineurs sont normalement
  responsables pour garder en sécurité les fonds (en contraste avec les noeuds complets
  qui sont responsables pour sécuriser les fonds sur la chaine principale Bitcoin).
  Les mineurs qui tentent de voler les fonds des drivechains doivent diffuser leurs
  intentions malveillantes plusieurs jours ou semaines à l'avance, donnant aux utilisateurs
  un chance de changer les noeuds complets pour faire appliquer les règles de la sidechain.
  Les drivechains ont été proposées au départ pour  une inclusion au sein de Bitcoin comme
  un soft fork (voir les BIPs [300][bip300] et [301][bip301]), mais un précédent
  post dans la liste de diffusion (voir la [Newsletter #190][news190 dc]) décrit
  comment d'autres propositions plus souples ont étés soumises au language de programmation
  de contrat de Bitcoin pouvant aussi autoriser une implémentation des drivechains.

    Dans ces commentaires durant la semaine, Rubin a décrit une autre manière dont les drivechains
    pourraient être implémentées en utilisant une proposition supplémentaire au language de
    programmation de contrat de Bitcoin, dans ce cas en utilisant `SIGHASH_ANYPREVOUT` (APO)
    comme dans le [BIP118][].  La description des drivechains basée sur APO ont plusieurs
    inconvénients par rapport au BIP300 mais offre peut-être des avantages similaires
    et un comportement suffisant pour que APO puisse être considéré pour activer les drivechains,
    pendant que certains le considèrent comme un bénéfice, d'autres au contraire y voient un problème.

## Changements dans les logiciels et services

*Dans cette rubrique mensuelle, nous soulignons les mises à jours des portefeuilles et
services de Bitcoin.*

- **Le projet Mempool lance un explorateur Lightning Network:**
  Le tableau de bord open source [Lightning de Mempool][mempool lightning] montre les
  statistiques agrégées, aussi bien au niveau du réseau que celles individuelles, des données
  de liquidité et de connectivité des noeuds.

- **le logiciel fédéré Fedimint ajoute Lightning:**
  Dans un récent [article de blog][blockstream blog fedimint], Blockstream présente
  les évolutions du projet fédéré d'e-cash Chaumian [Fedimint][], incluant
  le support du Lightning Network. Le projet a aussi [annoncé][fedimint signet tweet]
  qu'un [signet public][topic signet] et un faucet sont disponibles.

- **Le portefeuille Bitpay améliore le support de RBF:**
  Bitpay [améliore][bitpay 12051] le support [existant][bitpay 11935] pour
  envoyer des transactions [RBF][topic rbf] en gérant mieux les sauts de
  transactions avec des receveurs multiples.

- **Le portefeuille Lightning Mutiny annonce:**
  Mutiny (précédemment pLN), un portefeuille Lightning centré sur la vie privée, utilisera
  pour chaque canal des noeuds séparés, comme [annoncé][mutiny wallet].

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], et [Lightning BOLTs][bolts repo].*

- [Core Lightning #5581][] ajoute un nouveau topic de notification d'événement
  "block_added". Les plugins dédiés à la publication reçoivent une notification chaque fois
  qu'un nouveau bloc est reçu par bitcoind.

- [Eclair #2418][] et [#2408][eclair #2408] ajoutent un support pour recevoir
  les paiements envoyés avec des [routes cachées][topic rv routing].  Un émetteur
  qui crée un paiement caché ne fournit pas l'identité du noeud recevant le paiement.
  Cette façon de faire améliore la vie privée, spécialement quand elle est
  utilisée avec [les canaux non annoncés][topic unannounced channels].

- [Eclair #2416][] ajoute le support pour les requêtes de reception des paiements utilisant
  le protocole [offers][topic offers] comme défini dans la [proposition BOLT12][proposed bolt12].
  Le récent ajout du support de réception des paiements cachés est ici utilisé
  (voir la précédente liste des items pour Eclair #2418).

- [LND #6335][] ajoute une API `TrackPayments` qui autorise la souscrption à
  un flux de toutes les tentatives locales de paiement. Comme décrit dans la description du PR,
  cela peut être utilisé pour collecter les informations statisques à propos des
  paiements pour aider à un meilleur envoi et routage des paiements dans le futur, ainsi que
  pour les performances des [routages par rebonds][topic trampoline payments].

- [LDK #1706][] ajoute un support pour l'utilisation des [compact block filters][topic
  compact block filters] comme spécifié dans le [BIP158][] pour télécharger
  les transactions confirmées.  Lorsqu'utilisé, si le filtre indique que le bloc doit contenir
  des transactions affectant le portefeuille, le bloc complet qui peut aller jusqu'à 4 megabytes
  est téléchargé.  S'il est certain que le bloc ne contient aucune transaction affectant le
  portefeuille, aucune donnée additionnelle n'est téléchargée.

{% include references.md %}
{% include linkers/issues.md v=2 issues="5581,2418,2408,2416,6335,1706" %}
[rubin apodc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-September/020919.html
[news190 dc]: /en/newsletters/2022/03/09/#enablement-of-drivechains
[proposed bolt12]: https://github.com/rustyrussell/lightning-rfc/blob/guilt/offers/12-offer-encoding.md
[mempool lightning]: https://mempool.space/lightning
[blockstream blog fedimint]: https://blog.blockstream.com/fedimint-update/
[bitpay 12051]: https://github.com/bitpay/wallet/pull/12051
[bitpay 11935]: https://github.com/bitpay/wallet/pull/11935
[mutiny wallet]: https://bc1984.com/make-lightning-payments-private-again/
[Fedimint]: https://github.com/fedimint/fedimint
[fedimint signet tweet]: https://twitter.com/EricSirion/status/1572329210727010307
