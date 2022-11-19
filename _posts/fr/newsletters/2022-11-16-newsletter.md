---
title: 'Bitcoin Optech Newsletter #226'
permalink: /fr/newsletters/2022/11/16/
name: 2022-11-16-newsletter-fr
slug: 2022-11-16-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
La newsletter de cette semaine décrit une proposition visant à permettre
la mise en place de contrats intelligents généralisés sur Bitcoin et
résume un article sur la lutte contre les attaques de brouillage des canaux LN.
Sont également incluses nos sections régulières avec des résumés des
modifications apportées aux services et aux logiciels clients, des annonces
de nouvelles versions et de release candidate, et des descriptions d'ajout
sur les projets d'infrastructure Bitcoin populaires.

## Nouvelles

- **Contrats intelligents généraux en bitcoin via des clauses restrictives :** Salvatore Ingala
  [a posté][ingala matt] à la liste de diffusion Bitcoin-Dev une proposition
  pour un nouveau type de [clauses de dépense][topic covenants] (requiert
  un soft fork) qui permettrait d'utiliser des [arbres de merkle][] pour créer
  des contrats intelligents capables de transporter un état d'une transaction
  onchain à une autre. Pour reprendre un exemple tiré du post d'Ingala, deux
  utilisateurs pourraient parier sur une partie d'échecs où le contrat pourrait
  contenir les règles du jeu et l'état pourrait contenir les positions de
  toutes les pièces sur le plateau, avec la possibilité de mettre à jour cet
  état par chaque transaction en ligne.  Bien entendu, un contrat bien conçu
  permettrait de jouer le jeu hors ligne, seule la transaction de règlement à la
  fin du jeu étant mise en ligne (ou peut-être même en restant hors chaîne si
  le jeu est joué dans une autre construction hors chaîne, comme un canal de
  paiement).

    Ingala explique comment le travail pourrait aider à la conception des
    [joinpools][topic joinpools], optimistic rollups (voir la [Newsletter #222][news222
    rollup]), et d'autres constructions avec état.

- **Document sur les attaques par brouillage de canaux :** Clara Shikhelman et Sergei
  Tikhomirov [ont posté][st unjam post] sur la liste de diffusion du Lightning-Dev
  la synthèse d'un [papier][st unjam paper] ils ont écrit sur des solutions pour
  des [attaques par brouillage de canaux][topic channel jamming attacks].
  Ces attaques, décrites pour la première fois en 2015, peuvent rendre un grand
  nombre de canaux inutilisables pendant de longues périodes à un coût négligeable
  pour un attaquant.

    Les auteurs divisent les attaques par brouillage en deux types. Le premier est
    le "brouillage lent", qui consiste à rendre indisponibles pendant de longues
    périodes les canaux limités ou les fonds destinés à l'acheminement des paiements,
    ce qui se produit rarement lors de paiements légitimes. Le second type est le
    *brouillage rapide*, où les créneaux et les fonds ne sont bloqués que brièvement
    ---ce qui arrive souvent avec les paiements normaux, ce qui rend le brouillage
    rapide potentiellement plus difficile à atténuer.

    Ils suggèrent deux solutions:

    - *Frais inconditionnels* (identiques aux *frais initiaux* décrits dans les
      bulletins d'information précédents), où un certain montant de frais est payé
      aux nœuds de transmission même si un paiement n'atteint pas le destinataire.
      Les auteurs proposent à la fois une commission initiale *base* indépendante
      du montant du paiement et une commission *proportionnelle* qui augmente avec
      le montant du paiement. Ces deux frais distincts concernent respectivement
      le brouillage des créneaux HTLC et le brouillage des liquidités. Les frais
      peuvent être très faibles car ils sont uniquement destinés à empêcher le
      brouillage rapide, qui nécessite de fréquents renvois de faux paiements qui
      devraient chacun payer des frais initiaux supplémentaires, ce qui augmente
      le coût pour l'attaquant.

    - *Réputation locale avec transmission,* où chaque nœud conserverait des
      statistiques sur chacun de ses pairs concernant le temps pendant lequel
      les paiements transférés restent en attente et les frais de transfert perçus.
      Si le temps par frais d'un pair est élevé, il considère ce pair comme à haut
      risque et ne lui permet d'utiliser qu'un nombre limité de créneaux et de
      fonds du nœud local. Dans le cas contraire, il considère que ce pair présente
      un risque faible.

        Lorsqu'un nœud reçoit un paiement transféré d'un pair qu'il considère à faible
        risque, il vérifie si ce pair a marqué le paiement comme étant également à
        faible risque. Si le noeud de transfert en amont et le paiement sont tous deux
        à faible risque, il autorise le paiement à utiliser tout créneau et fonds
        disponibles.

    Le document a fait l'objet de quelques discussions sur la liste de diffusion,
    la méthode de réputation locale proposée ayant été particulièrement appréciée.

## Changements dans les services et les logiciels clients

*Dans cette rubrique mensuelle, nous mettons en avant les mises à jour intéressantes
des portefeuilles et services Bitcoin.*


- **Sparrow 1.7.0 publié :**
  [Sparrow 1.7.0][sparrow 1.7.0] ajoute le support pour le [Replace-By-Fee (RBF)][topic rbf]
  en activant la fonction d'annulation de transaction parmi d'autres mises à jour.

- **Blixt Wallet ajoute le support de taproot :**
  [Blixt Wallet v0.6.0][blixt v0.6.0] ajoute le support d'envoyer et recevoir pour
  les adresses [taproot][topic taproot].

- **Specter-DIY v1.8.0 publié :**
  [Specter-DIY v1.8.0][] supporte maintenant les [constructions reproductibles][topic reproducible
  builds] et la prise en charge des dépenses liées au cheminement [taproot][topic taproot].

- **Trezor Suite ajoute des fonctions de contrôle des pièces :**
  Dans un [recent artcile de blog][trezor coin control], Trezor a annoncè que Trezor
  Suite supporte maintenant la fonction de [contrôle des pièces][topic coin selection].

- **Strike ajoute le support pour l'envoi avec taproot :**
  le portefeuille Strike's autorisa maintenant à envoyer avec des adresses [bech32m][topic bech32].

- **Lancement de la bourse Kollider avec le support de Lightning :**
  Kollider [a annoncé][kollider launch] une plateforme d'échange avec des dépôts LN et
  des possibilités de retrait basé sur un porte-monnaie Lightning dans un navigateur.

## Mises à jour et Release candidate

*Nouvelles versions et release candidate pour les principaux projets d'infrastructure Bitcoin.
Veuillez envisager de passer aux nouvelles versions ou d'aider à tester les release candidate.*

- [Bitcoin Core 24.0 RC4][] est une release candidate pour la prochaine version
  de l'implémentation de nœud complet la plus utilisée du réseau.
  Un [guide de test][bcc testing] est disponible.

  **Avertissement :** cette release candidate inclut l'option de configuration
  `mempoolfullrbf`qui, selon plusieurs développeurs de protocoles et
  d'applications, pourrait entraîner des problèmes pour les services marchands,
  comme décrit dans les newsletters[#222][news222 rbf] et [#223][news223 rbf].
  Il pourrait aussi  causer des problèmes pour le relai de transaction comme
  décrit dans la [Newsletter #224][news224 rbf].

- [LND 0.15.5-beta.rc1][] est une release candidate pour une version de maintenance
  de LND. Elle ne contient que des corrections de bogues mineurs selon les notes
  de version prévues.

## Changements principaux dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], et [Lightning BOLTs][bolts repo].*

- [Core Lightning #5681][] ajoute la possibilité de filtrer la sortie JSON d'un RPC
  du côté du serveur. Le filtrage côté serveur permet d'éviter l'envoi de données
  indésirables lors de l'utilisation d'une connexion distante à bande passante limitée.
  À l'avenir, certains RPC pourront éviter de calculer les données filtrées, ce qui
  leur permettra de revenir plus tôt. Le filtrage n'est pas garanti pour tous les RPC,
  notamment ceux fournis par les plugins. Lorsque le filtrage n'est pas disponible,
  la sortie complète non filtrée sera retournée. Pour plus d'informations, voir
  l'ajout à la [documentation][cln filter doc].

- [Core Lightning #5698][] met à jour le mode développeur expérimental pour permettre
  la réception de messages d'erreur de n'importe quelle taille, enveloppés comme
  des oignons. BOLT2 recommande actuellement des erreurs de 256 octets, mais n'interdit
  pas les messages d'erreurs plus longs et [BOLTs #1021][] est ouvert pour encourager
  l'utilisation de messages d'erreurs de 1024 octets encodés en utilisant la sémantique
  moderne Type-Length-Value (TLV) de LN.

- [Core Lightning #5647][] ajoute le gestionnaire de plugins reckless. Le gestionnaire
  de plugins peut être utilisé pour installer des plugins CLN par nom à partir du dépôt
  `lightningd/plugins`. Le gestionnaire de plugins installe automatiquement les
  dépendances et vérifie l'installation. Il peut également être utilisé pour activer
  et désactiver les plugins ainsi que pour faire persister l'état des plugins dans un
  fichier de configuration.

- [LDK #1796][] met à jour `Confirm::get_relevant_txids()` pour retourner non seulement
  les txids mais aussi les hashs des blocs contenant les transactions référencées.
  Cela permet à une application de niveau supérieur de déterminer plus facilement quand
  une réorganisation de la chaîne de blocs peut avoir modifié la profondeur de
  confirmation d'une transaction. Si le hachage de bloc pour un txid donné change,
  alors une réorganisation a eu lieu.

- [BOLTs #1031][] permet à un expéditeur de payer à un destinataire un peu plus que
  le montant demandé lorsqu'il utilise des [paiements par trajets multiples simplifiés]
  [topic multipath payments]. Cela peut être nécessaire dans le cas où les chemins de
  paiement choisis utilisent des canaux avec un montant minimum routable. Par exemple,
  Alice veut diviser un total de 900 sat en deux parties, mais les deux voies qu'elle
  choisit exigent des montants minimums de 500 sat. Avec ce changement de spécification,
  elle peut maintenant envoyer deux paiements de 500 sats, en choisissant de surpayer un
  total de 100 sats afin d'utiliser son chemin préféré.

{% include references.md %}
{% include linkers/issues.md v=2 issues="5681,5698,5647,1796,1031,1021" %}
[bitcoin core 24.0 rc4]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[lnd 0.15.5-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.5-beta.rc1
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/24.0-Release-Candidate-Testing-Guide
[news222 rbf]: /fr/newsletters/2022/10/19/#option-de-remplacement-de-transaction
[news223 rbf]: /fr/newsletters/2022/10/26/#poursuite-de-la-discussion-sur-le-full-rbf
[news224 rbf]: /fr/newsletters/2022/11/02/#coherence-mempool
[cln filter doc]: https://github.com/rustyrussell/lightning/blob/a6f38a2c1a47c5497178c199691047320f2c55bc/doc/lightningd-rpc.7.md#field-filtering
[ingala matt]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-November/021182.html
[merkle trees]: https://en.wikipedia.org/wiki/Merkle_tree
[news222 rollup]: /fr/newsletters/2022/10/19/#recherche-sur-les-rollups-de-validite
[st unjam post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-November/003740.html
[st unjam paper]: https://raw.githubusercontent.com/s-tikhomirov/ln-jamming-simulator/master/unjamming-lightning.pdf
[sparrow 1.7.0]: https://github.com/sparrowwallet/sparrow/releases/tag/1.7.0
[blixt v0.6.0]: https://github.com/hsjoberg/blixt-wallet/releases/tag/v0.6.0
[Specter-DIY v1.8.0]: https://github.com/cryptoadvance/specter-diy/releases/tag/v1.8.0
[trezor coin control]: https://blog.trezor.io/coin-control-in-trezor-suite-92f3455fd706
[kollider launch]: https://blog.kollider.xyz/announcing-kolliders-launch/
