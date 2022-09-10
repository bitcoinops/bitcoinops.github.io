---
title: 'Bitcoin Optech Newsletter #216'
permalink: /fr/newsletters/2022/09/07/
name: 2022-09-07-newsletter-fr
slug: 2022-09-07-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Cette semaine au sommaire de cette newsletter, plusieurs changements notable au populaire logiciel de l'infrastructure Bitcoin.

## Nouvelles

*Pas de nouvelles signifiantes cette semaine.*

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #25717][] Ajout d'une étape de pré-synchronisation des entêtes (Headers Presync) durant 
  le téléchargement initial des blocs (Initial Block Download - IBD) afin de prévenir 
  d'une attaque par déni de service (DoS) ainsi qu'une étape vers la suppression 
  des points de contrôle. Les noeuds utilisent la pré-synchronisation pour vérifier 
  que la chaîne d'en-têtes d'un pair a suffisament travaillé avant de la stocker 
  de manière permanente.

  Au cours de l'IBD, un pair malicieux pourrait essayer de bloquer le process de synchronisation,
  injecter des blocs qui ne sont pas de la chaîne la plus longue, ou simplement épuiser 
  les ressources du noeud. Ainsi, bien que la vitesse de synchronisation et l'usage 
  de la bande passante soient des préoccupations importantes pendant l'IBD, un objectif 
  principal de conception est d'éviter l'attaque par déni de service (DoS). Depuis la version v0.10.0, 
  le noeud Bitcoin Core synchronise d'abord la premiere en-tête de block avant de télécharger 
  les données du bloc et rejète les en-têtes qui ne respectent pas un ensemble de points de contrôle. 
  Au lieu d'utiliser les valeurs codées en dur, cette nouvelle conception utilise les propriétes 
  inhérentes de résistance à l'attaque de déni de service du schéma de la preuve de travail 
  (Proof of Work - PoW) pour réduire la quantité de mémoire allouée avant de trouver 
  la chaine principale. 

  Avec ces changements, les noeuds téléchargent deux fois les en-têtes durant la synchronisation 
  de l'en-tête intiale: une première fois pour vérifier l'en-tête de la preuve de travail 
  (sans la stocker) jusqu'à ce que le travail accumulé rencontre un seuil prédéterminé, 
  puis une seconde passe pour les mémoriser. Afin de prévenir qu'un attaquant envoie la chaine principale 
  lors de la pré-synchronisation et ensuite une différente, une chaine malicieuse lors du re-téléchargement,
  le noeud stocke les engagements envers la chaîne d'en-têtes pendant la pré-synchronisation. 

- [Bitcoin Core #25355][] Ajout du support pour la transition, un adresse temporaire I2P seulement quand la 
  sortie [I2P connections][topic anonymity networks] est autorisée. Dans I2P, celui qui reçoit apprend l'adresse I2P de la connexion de l'initateur. 
  les noeuds I2P non listés utiliseront maintenant par défaut les adresses I2P temporaires lorsqu'ils établissent des connexions sortantes. 

- [BDK #689][] ajout d'une méthode `allow_dust` autorisant un portefeuille à créer une transaction qui viole 
  la limite de poussière [dust limit][topic uneconomical outputs]. Bitcoin Core et les autres noeuds utilisant le même réglage ne relaieront plus les transactions non confirmées sans que toutes les sorties 
  (excepté `OP_RETURN`) ne reçoivent plus de satoshis que la limite de poussières. 
  BDK empêche généralement les utilisateurs de créer de telles transactions non relayables en appliquant la limite de poussière sur les transactions qu'elle crée, mais cette nouvelle option permet d'ignorer cette politique. L'auteur du PR mentionne qu'ils l'utilisent pour tester leur portefeuille.  

- [BDK #682][] ajoute des capacités de signature pour les dispositifs de signature matérielle utilisant 
  [HWI][topic hwi] et la librairie [rust-hwi][rust-hwi github]. Le PR introduit également un émulateur de périphérique Ledger pour les tests.

{% include references.md %}
{% include linkers/issues.md v=2 issues="25717,25355,689,682" %}
[rust-hwi github]: https://github.com/bitcoindevkit/rust-hwi
