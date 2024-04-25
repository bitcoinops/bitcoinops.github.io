---
title: 'Bulletin Hebdomadaire Bitcoin Optech #298'
permalink: /fr/newsletters/2024/04/17/
name: 2024-04-17-newsletter-fr
slug: 2024-04-17-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume une analyse de la manière dont un nœud avec un mempool en
cluster s'est comporté lorsqu'il a été testé avec toutes les transactions observées sur le réseau en 2023.
Nous incluons également nos sections régulières décrivant les mises à jour des clients et des services,
les nouvelles versions et les versions candidates, ainsi que les changements
apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Que se serait-il passé si le mempool en cluster avait été déployé il y a un an ?**
  Suhas Daftuar a [publié][daftuar cluster] sur Delving Bitcoin qu'il avait enregistré chaque transaction
  que son nœud avait reçue en 2023 et les a maintenant exécutées via une version de développement de Bitcoin Core
  avec le [cluster mempool][topic cluster mempool] activé pour quantifier les différences entre la version existante
  et la version de développement. Voilà quelques-unes de ses conclusions :

  - *Le nœud cluster mempool a accepté 0,01 % de transactions en plus :*
    "En 2023, les limites d'ascendants/descendants du nœud de base ont causé le rejet de plus de 46k tx à un moment donné. [...]
    Seulement ~14k transactions ont été rejetées en raison d'une limite de taille de cluster atteinte."
    Environ 10k des transactions rejetées initialement par le nœud cluster mempool (70 % des 14k rejetées)
    auraient été acceptées plus tard si elles avaient été rediffusées après la confirmation de certains
    de leurs ascendants, ce qui est un comportement de portefeuille attendu.

  - *Les différences RBF étaient négligeables :* "Les règles RBF appliquées dans les deux
    simulations sont différentes, mais cela a eu un
    effet négligeable sur les nombres d'acceptation globaux ici." Voir
    ci-dessous pour plus de détails.

  - *Le mempool en cluster était tout aussi bon pour les mineurs que la sélection de transactions traditionnelle :*
    Daftuar a noté qu'actuellement presque chaque transaction finit
    par être incluse dans un bloc, de sorte que la sélection de transactions
    actuelle de Bitcoin Core et la sélection de transactions de pool de mémoire de cluster
    permettraient de capturer le même montant en frais.
    Cependant, dans une analyse dont Daftuar prévient qu'elle surestime probablement
    les résultats, le mempool en cluster a capturé plus de frais que la sélection de transactions
    traditionnelle environ 73 % du temps. La sélection de transactions traditionnelle était
    meilleure environ 8 % du temps. Daftuar a conclu, "Bien qu'on ne puisse pas conclure
    que le mempool en cluster est matériellement meilleur que
    la référence basée sur l'activité du réseau en 2023, il me semble très
    improbable qu'il soit matériellement pire."

  Daftuar a également considéré l'effet du mempool en cluster sur le [remplacement de transaction
  RBF][topic rbf]. Il commence avec un excellent résumé de la
  différence entre le comportement RBF actuel de Bitcoin Core et comment RBF
  fonctionnerait sous mempool en cluster (emphase et liens de l'original) :

  > Les règles RBF du mempool en cluster sont centrées autour de la question de savoir si le
  > [diagramme de taux de frais du mempool s'améliorerait][feerate diagram] après le remplacement,
  > tandis que les règles RBF existantes de Bitcoin Core sont à peu près
  > ce qui est décrit dans le BIP125 et [documenté ici][rbf doc].
  >
  > Contrairement au BIP125, la règle RBF proposée pour le [mempool en cluster] se concentre sur
  > le _résultat_ d'un remplacement. Une tx peut être meilleure en théorie qu'en pratique : peut-être
  > qu'elle "devrait" être acceptée sur la base d'une compréhension théorique de ce qui serait bon pour
  > le mempool, mais si le diagramme de feerate résultant est pire pour une raison quelconque (disons,
  > parce que l'algorithme de linéarisation n'est pas optimal), alors nous rejetterons le remplacement.

  Nous répéterons également sa conclusion de cette section du rapport, que nous estimons avoir été
  bien étayée par les données et l'analyse qu'il a fournies :

  > Globalement, les différences de RBF entre le mempool du cluster et la politique existante étaient
  > minimes. Là où elles différaient, les nouvelles règles de RBF proposées protégeaient largement le
  > mempool contre les remplacements qui n'étaient pas compatibles avec les incitations---un bon
  > changement. Pourtant, il est important d'être également conscient qu'en théorie, nous pourrions voir
  > des remplacements empêchés qui, dans un monde idéal, seraient acceptés [maintenant], parce que
  > parfois, des remplacements apparemment bons peuvent déclencher un comportement sous-optimal, qui
  > était précédemment non détecté (par la politique BIP125) mais serait détecté et empêché dans les
  > nouvelles règles.

  Il n'y avait pas de réponses au post au moment de la rédaction de cet article.

## Modifications apportées aux services et aux logiciels clients

*Dans cette rubrique mensuelle, nous mettons en évidence les mises à jour
intéressantes des portefeuilles et services Bitcoin.*

- **Phoenix pour serveur annoncé :**
  Phoenix Wallet a annoncé un nœud Lightning simplifié, sans interface, [phoenixd][phoenixd github],
  axé sur l'envoi et la réception de paiements. phoenixd cible les développeurs, est basé sur le
  logiciel Phoenix Wallet existant, et automatise la gestion des canaux, des pairs et de la liquidité.

- **Mercury Layer ajoute des échanges Lightning :**
  Le Mercury Layer [statechain][topic statechains] utilise [hold invoices][topic hold invoices] pour
  permettre l'échange d'une pièce statechain contre un paiement Lightning.

- **Implementation de Reference de Stratum V2 en v1.0.0 publiée :**
  La [version 1.0.0][sri blog] "est le résultat d'améliorations dans la spécification Stratum V2 grâce
  à la collaboration du groupe de travail et à des tests rigoureux".

- **Mise à jour des Transactions Teleport :**
  Un fork du [répertoire original des Transactions Teleport][news192 tt] a été [annoncé][tt tweet]
  avec plusieurs mises à jour et améliorations achevées.

- **Bitcoin Keeper v1.2.1 publié :**
  La [version v1.2.1][bitcoin keeper v.1.2.1] ajoute le support pour les portefeuilles [taproot][topic
  taproot].

- **Logiciel de gestion d'étiquettes BIP-329 :**
  La version 2 de [Labelbase][labelbase blog] inclut une option auto-hébergée et des capacités
  d'import/export [BIP329][] parmi d'autres fonctionnalités.

- **Lancement du service de signature Sigbash :**
  Le service de signature [Sigbash][] permet aux utilisateurs d'acheter un xpub à utiliser dans une
  configuration multisig qui ne signera [PSBT][topic psbt] que si certaines conditions spécifiées par
  l'utilisateur (taux de hachage, prix du Bitcoin, solde de l'adresse, après un certain temps) sont
  remplies.

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets d’infrastructure
Bitcoin. Veuillez envisager de passer aux nouvelles versions ou d’aider à tester
les versions candidates.*

- [Bitcoin Core 27.0][] est la sortie de la prochaine version majeure de l'implémentation du nœud
  complet prédominant du réseau. Cette nouvelle version déprécie libbitcoinconsensus (voir les Bulletins
  [#288][news288 libconsensus] et [#297][news297 libconsensus]), active par défaut le transport P2P
  chiffré v2 ([topic v2 p2p transport][topic v2 p2p transport]) (voir le [Bulletin #288][news288 v2
  p2p]), permet l'utilisation d'une politique de transaction ([TRUC][topic v3 transaction relay])
  opt-in topologiquement restreinte jusqu'à confirmation (également appelée _relais de transaction
  v3_) sur les réseaux de test (voir le [Bulletin #289][news289 truc]), et ajoute une nouvelle
  stratégie de sélection de pièces ([coin selection][topic coin selection]) à utiliser lors de taux de
  frais élevés (voir le [Bulletin #290][news290 coingrinder]). Pour une liste complète des changements
  majeurs, veuillez consulter les [notes de version][bcc27 rn].

- [BTCPay Server 1.13.1][] est la dernière version de ce processeur de paiement auto-hébergé. Depuis
  notre dernière couverture d'une mise à jour de BTCPay Server dans le [Bulletin #262][news262 btcpay],
  ils ont rendu les webhooks [plus extensibles][btcpay server #5421], ajouté un support pour
  l'importation de portefeuilles multisig [BIP129][] (voir le [Bulletin #281][news281 bip129]),
  amélioré la flexibilité des plugins et commencé à migrer tout le support des altcoins vers des
  plugins, et ajouté un support pour les [PSBT][topic psbt] encodés BBQr (voir le [Bulletin
  #295][news295 bbqr]), parmi de nombreuses autres nouvelles fonctionnalités et corrections de bugs.

- [LDK 0.0.122][] est la dernière version de cette bibliothèque pour la construction d'applications
  compatibles LN ; elle fait suite à la version [0.0.121][ldk 0.0.121] qui corrige une vulnérabilité
  de déni de service. La dernière version corrige également plusieurs bugs.

## Changements notables dans le code et la documentation

_Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo],
[Lightning BOLTs][bolts repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana
repo]._

- [LDK #2704][] met à jour et étend de manière significative sa documentation sur sa classe
  `ChannelManager`. Le gestionnaire de canaux est "la machine à états des canaux d'un nœud lightning
  et la logique de gestion des paiements, qui facilite l'envoi, le transfert et la réception de
  paiements à travers les canaux lightning."

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2704,5421" %}
[Bitcoin Core 27.0]: https://bitcoincore.org/bin/bitcoin-core-27.0/
[feerate diagram]: https://delvingbitcoin.org/t/mempool-incentive-compatibility/553/1
[rbf doc]: https://github.com/bitcoin/bitcoin/blob/0de63b8b46eff5cda85b4950062703324ba65a80/doc/policy/mempool-replacements.md
[daftuar cluster]: https://delvingbitcoin.org/t/research-into-the-effects-of-a-cluster-size-limited-mempool-in-2023/794
[bcc27 rn]: https://github.com/bitcoin/bitcoin/blob/c7567d9223a927a88173ff04eeb4f54a5c02b43d/doc/release-notes/release-notes-27.0.md
[news288 libconsensus]: /fr/newsletters/2024/02/07/#bitcoin-core-29189
[news297 libconsensus]: /fr/newsletters/2024/04/10/#bitcoin-core-29648
[news288 v2 p2p]: /fr/newsletters/2024/02/07/#bitcoin-core-29347
[news289 truc]: /fr/newsletters/2024/02/14/#bitcoin-core-28948
[news290 coingrinder]: /fr/newsletters/2024/02/21/#bitcoin-core-27877
[news281 bip129]: /fr/newsletters/2023/12/13/#btcpay-server-5389
[news295 bbqr]: /fr/newsletters/2024/03/27/#btcpay-server-5852
[news262 btcpay]: /fr/newsletters/2023/08/02/#btcpay-server-1-11-1
[ldk 0.0.122]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.122
[ldk 0.0.121]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.121
[btcpay server 1.13.1]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.13.1
[phoenixd github]: https://github.com/ACINQ/phoenixd
[sri blog]: https://stratumprotocol.org/blog/sri-1-0-0/
[news192 tt]: /en/newsletters/2022/03/23/#coinswap-implementation-teleport-transactions-announced
[tt tweet]: https://twitter.com/RajarshiMaitra/status/1768623072280809841
[bitcoin keeper v.1.2.1]: https://github.com/bithyve/bitcoin-keeper/releases/tag/v1.2.1
[labelbase blog]: https://labelbase.space/ann-v2/
[Sigbash]: https://sigbash.com/
