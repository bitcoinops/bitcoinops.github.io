---
title: 'Bulletin Hebdomadaire Bitcoin Optech #7'
permalink: /fr/newsletters/2018/08/07/
name: 2018-08-07-newsletter-fr
slug: 2018-08-07-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine comprend le tableau de bord habituel et les éléments d'action, un lien vers une discussion sur des contrats
Bitcoin généralisés sur le Lightning Network, une brève description d'une bibliothèque récemment annoncée pour des signatures BLS améliorant
la scalabilité, ainsi que quelques commits notables des projets Bitcoin Core, LND et C-Lightning.

## Éléments d'action

- Optech a commencé à planifier son premier atelier européen, qui devrait avoir lieu à Paris courant novembre. Si des entreprises membres
  qui pensent pouvoir y assister ont des sujets qu'elles souhaitent discuter, veuillez [envoyer un email à Optech][optech email]. Plus
  d'informations sur l'atelier seront publiées dans quelques semaines.

## Éléments du tableau de bord

{% assign img1_label = "Transactions signalant l'opt-in RBF, août 2017 - août 2018" %}

- Les [frais de transaction restent très bas][fee metrics] : toute personne pouvant attendre 10 blocs ou plus pour une confirmation peut
  raisonnablement payer le taux de frais minimum par défaut. C'est le bon moment pour [consolider des UTXOs][consolidate info].

- L'adoption de l'opt-in RBF reste assez faible, mais a sensiblement augmenté au cours de l'année passée, passant de 1,5 % à 5,7 % des
  transactions. Ces données proviennent du tableau de bord bêta d'Optech, que nous encourageons chacun à essayer et au sujet duquel nous
  invitons à nous faire des retours !

  ![{{img1_label}}](/img/posts/rbf.png) *{{img1_label}}, source : tableau de bord Optech*

## Nouvelles

- **Discussion sur des contrats arbitraires sur LN :** un [fil][contract thread] sur la liste de diffusion de développement du Lightning
  Network (LN) la semaine dernière a décrit les principes de base permettant d'exécuter des contrats Bitcoin arbitraires dans un canal de
  paiement. Au lieu d'un contrat indépendant qui se résout à True pour être une transaction valide, ce contrat exact est inclus dans un
  paiement LN et doit renvoyer true pour que la transaction de paiement intra-canal soit valide. Tout le reste dans le contrat arbitraire
  ainsi que dans le paiement LN peut rester identique, avec quelques exceptions spécifiques discutées dans ce fil lancé par le chercheur
  pseudonyme averti ZmnSCPxj.

- **Annonce d'une bibliothèque pour les signatures BLS :** le développeur bien connu Bram Cohen a [annoncé][bls announce] un « premier
  brouillon (mais entièrement fonctionnel) de bibliothèque pour faire des [signatures BLS][] basé sur une construction fondée sur [MuSig][]
  ». Ces signatures offrent la plupart des mêmes avantages que les signatures Schnorr tels que décrits dans [la nouvelle en vedette du
  Bulletin #3][#3 schnorr], mais permettent aussi l'agrégation non interactive de signatures, ce qui peut permettre une plus grande
  scalabilité en réduisant la quantité de données de signature dans la chaîne de blocs (possiblement d'un très grand pourcentage) et
  potentiellement améliorer la confidentialité en mettant en œuvre des techniques de coinjoin non interactif comme celles décrites dans le
  [papier Mimblewimble][].

  Les signatures BLS présentent toutefois trois inconvénients qui ont conduit la plupart des développeurs du protocole Bitcoin à se
  concentrer sur les signatures Schnorr à court terme. Le premier est qu'il n'existe pas de méthode connue pour les vérifier aussi vite que
  les signatures Schnorr---et la vitesse de vérification des signatures est également importante pour la scalabilité du réseau.
  Deuxièmement, prouver que les signatures BLS sont sûres nécessite de faire une hypothèse supplémentaire concernant la sécurité d'une
  partie du schéma, hypothèse qui n'est pas nécessaire pour prouver la sécurité du schéma actuel de Bitcoin (ECDSA) ou du schéma proposé
  fondé sur Schnorr. Enfin, les signatures BLS n'existent que depuis environ la moitié du temps des signatures Schnorr, sont encore moins
  couramment utilisées, et ne sont pas réputées avoir reçu autant d'examen par des experts que les signatures Schnorr.

  Malgré cela, cette bibliothèque open source offre aux développeurs un moyen pratique de commencer à expérimenter les signatures BLS et
  même de commencer à les utiliser dans des applications qui n'ont pas besoin d'être aussi sûres que le réseau Bitcoin.

## Commits notables

*Commits notables cette semaine dans [Bitcoin Core][bitcoin core repo], [LND][lnd repo] et [C-lightning][core lightning repo].*

- [Bitcoin Core #13697][] : cette PR de Pieter Wuille mentionnée dans [le Bulletin #5][] pour ajouter la prise en charge des [descripteurs
  de scripts de sortie][] au prochain RPC 0.17 `scantxoutset` a été fusionnée. Ces descripteurs fournissent une manière complète de décrire
  au logiciel quels scripts de sortie vous souhaitez trouver, et il est prévu qu'ils soient adaptés au fil du temps à d'autres parties de
  l'API Bitcoin Core telles que [importprivkey][rpc importprivkey], [importaddress][rpc importaddress], [importpubkey][rpc importpubkey],
  [importmulti][rpc importmulti] et [importwallet][rpc importwallet].

- [Bitcoin Core #13799][] : avant le premier bulletin Optech, une PR avait été fusionnée qui amenait délibérément Bitcoin Core à interrompre
  son démarrage si le fichier de configuration ou les paramètres de lancement contenaient une option que Bitcoin Core ne reconnaissait pas.
  Cela a grandement simplifié le débogage d'erreurs courantes telles que les fautes de frappe---mais cela empêchait aussi les utilisateurs
  de placer dans leur bitcoin.conf des options qui s'appliquaient à des clients tels que `bitcoin-cli`. Cette nouvelle PR supprime l'arrêt
  au démarrage et produit simplement un avertissement. Probablement pour une future version, un mécanisme de compatibilité client sera
  implémenté et l'arrêt au démarrage sera rétabli.

- [LND #1579][] : ceci met à jour les interfaces principales de backend (telles que bitcoind, btcd et neutrino SPV) pour être compatibles
  avec la dernière version (et espérons-le définitive) des filtres compacts de blocs [BIP158][] telle qu'implémentée dans le nœud complet
  btcd, btcwallet et le portefeuille léger Neutrino. Ces filtres permettent à un client de déterminer si un bloc contient probablement ou
  non une transaction qui affecte son portefeuille, de manière similaire aux filtres bloom de [BIP37][], mais beaucoup plus efficacement
  pour le serveur (puisqu'ils n'ont pas besoin de rescanner les anciens blocs) et avec une confidentialité supplémentaire pour le client car
  ils ne donnent pas directement au serveur d'information sur les transactions qui l'intéressent.

- [LND #1543][] : cette PR poursuit le travail en vue de créer des tours de garde LN pouvant assister les clients légers et autres
  programmes qui ne sont pas en ligne, en surveillant les tentatives de vol de canal et en diffusant la transaction présignée de remède à la
  violation de l'utilisateur. Cette PR particulière ajoute des méthodes d'encodage et de chiffrement de la version 0 des tours de garde par
  le cryptographe Conner Fromknecht.

- [C-lightning 55d450ff][] : C-lightning refuse de relayer des paiements lorsque les frais de relais dépassent un certain pourcentage du
  paiement. Cependant, lorsque le montant relayé est minuscule, par exemple l'achat de seulement quelques pixels à 10 nBTC chacun sur
  [Satoshis.Place][], cette règle était toujours déclenchée parce que le plancher minimal de frais représentait toujours un pourcentage
  élevé (par ex. payer 10 nBTC avec des frais minimum de 10 nBTC correspond à 100 % de frais). Cette PR fournit une nouvelle règle qui
  permet aux paiements avec des frais de relais allant jusqu'à 50 nBTC de passer, quel que soit leur pourcentage de frais, et ajoute une
  option afin que les utilisateurs puissent personnaliser cette valeur.

{% include references.md %}
{% include linkers/issues.md issues="13697,13799,1579,1543" %}

[bls announce]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016273.html
[#3 schnorr]: /fr/newsletters/2018/07/10/#nouvelle-en-vedette--proposition-de-bip-pour-les-signatures-schnorr
[musig]: https://blockstream.com/2018/01/23/musig-key-aggregation-schnorr-signatures.html
[signatures bls]: https://en.wikipedia.org/wiki/Boneh%E2%80%93Lynn%E2%80%93Shacham
[papier mimblewimble]: https://scalingbitcoin.org/papers/mimblewimble.txt
[c-lightning 55d450ff]: https://github.com/ElementsProject/lightning/commit/55d450ff00ce80b01c5c64c072a47fea42657673
[satoshis.place]: https://satoshis.place/
[contract thread]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-August/001383.html
[fee metrics]: https://statoshi.info/dashboard/db/fee-estimates
[consolidate info]: https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#Consolidation
[le bulletin #5]: /fr/newsletters/2018/07/24/#premiere-utilisation-des-descripteurs-de-scripts-de-sortie
[descripteurs de scripts de sortie]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
