---
title: 'Bulletin Hebdomadaire Bitcoin Optech #2'
permalink: /fr/newsletters/2018/07/03/
name: 2018-07-03-newsletter-fr
slug: 2018-07-03-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
version: 1
excerpt: Continued discussion over graftroot safety, BIP174 Partially Signed Bitcoin Transactions (PSBT) officially marked as proposed, and discussion of Dandelion transaction relay.

---
### Désabonnement

Nous sommes passés à une nouvelle plateforme pour distribuer le bulletin de cette semaine. Si vous n'êtes pas intéressé par la réception de
mises à jour hebdomadaires sur ce qui se passe dans la communauté open source Bitcoin, veuillez cliquer sur le lien de désabonnement au bas
de cet e-mail.

N'hésitez pas à nous contacter à [info@bitcoinops.org](mailto:info@bitcoinops.org) si vous avez des questions ou des commentaires sur ce que
nous faisons !

## Bienvenue

Bienvenue dans le deuxième bulletin du groupe Bitcoin Optech ! En tant que membre de notre nouvelle organisation, vous pouvez vous attendre
à recevoir régulièrement de notre part des bulletins couvrant le développement open source Bitcoin et les actualités du protocole, les
annonces d'Optech, ainsi que des études de cas d'entreprises membres. Ces bulletins sont également disponibles sur [notre site web][newsletter page].

Comme toujours, n'hésitez pas à nous contacter si vous avez des retours ou des commentaires sur ce bulletin.

Un rappel aux entreprises qui ne sont pas encore devenues membres officiels. Nous vous demandons de verser une contribution symbolique de 5
000 $ pour aider à financer nos dépenses.

[newsletter page]]: /fr/newsletters/

## Premier atelier Optech !

Comme annoncé précédemment, le groupe Bitcoin Optech organise son premier atelier **le 17 juillet à San Francisco**. Les participants seront
1 à 2 ingénieurs d'entreprises Bitcoin de la région de la baie de San Francisco. Nous aurons des discussions en table ronde couvrant 3
sujets :

- Meilleures pratiques de sélection des pièces ;
- Meilleures pratiques d'estimation des frais, RBF, CPFP ;
- Communauté et communication Optech - optimiser Optech pour les besoins des entreprises.

Veuillez nous contacter si vous souhaitez participer à cet atelier ou à de futurs ateliers dans d'autres régions.

## Nouvelles Open Source

Un résumé des actions pertinentes, des éléments du tableau de bord et des nouvelles de l'ensemble de la communauté open source Bitcoin.

### Actions

Pas de nouvelles actions, mais il est toujours recommandé d'assurer le suivi des éléments suivants précédemment publiés.

- Divulgation en attente d'une vulnérabilité DoS pour Bitcoin Core 0.12.0 et versions antérieures. Les altcoins peuvent être affectés. Voir
  [le bulletin #1][]

- Mettre à niveau vers [Bitcoin Core 0.16.1][], publié le 15 juin 2018. Mise à niveau particulièrement recommandée pour les mineurs. Voir
  [le bulletin #1][]

[Bitcoin Core 0.16.1]: https://bitcoincore.org/en/download/
[le bulletin #1]: /fr/newsletters/2018/06/26/

### Éléments du tableau de bord

- **Les frais de transaction restent très bas :** au moment de la rédaction, les estimations de frais pour une confirmation dans 2 blocs ou
  plus restent à peu près au niveau des frais minimaux de relais par défaut dans Bitcoin Core. C'est un bon moment pour [consolider des
  entrées][].

  **MISE À JOUR (2 juillet)** : Le [taux de hachage du réseau estimé a diminué][hash rate graph] au cours des 3 à 4 derniers jours,
  initialement jusqu'à 10 %, avant de rebondir quelque peu depuis. Certains ont spéculé que des inondations dans le sud-ouest de la Chine
  ont détruit une quantité importante d'équipements de minage. Notez toutefois qu'en raison de la variance naturelle du taux de découverte
  des blocs, il n'est possible de faire qu'une estimation approximative de la quantité actuelle de taux de hachage du réseau sur de courtes
  périodes. Un taux de hachage réseau plus faible implique un rythme plus lent de découverte des blocs, ce qui peut entraîner une congestion
  du mempool et potentiellement des frais plus élevés. Jusqu'à présent, la congestion du mempool ne semble pas avoir augmenté de manière
  significative et les frais restent bas. Cependant, il est recommandé de continuer à surveiller le rythme de découverte des blocs et la
  congestion du mempool avant d'envoyer de grosses transactions.

[consolider des entrées]: https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#Consolidation

[hash rate graph]: https://bitcoinwisdom.com/bitcoin/difficulty

- **Taux élevé de production de blocs sur testnet :** à la fin de la semaine dernière, un mineur a produit un grand nombre de blocs en
  succession rapide sur testnet, parfois plusieurs blocs par seconde, entraînant une dégradation du service chez certains fournisseurs
  testnet. Il s'agit d'un problème récurrent sur testnet qui résulte de l'absence délibérée d'incitation économique à y miner. Si vous avez
  besoin de tester votre logiciel, il est plus fiable de construire votre propre testnet privé en utilisant le [mode regtest][] de Bitcoin
  Core.

[mode regtest]: https://bitcoin.org/en/developer-examples#regtest-mode

### Nouvelles

- **Poursuite de la discussion sur la sûreté de graftroot :** [Graftroot][] est une alternative proposée à adhésion volontaire à
  [taproot][], qui est une proposition d'amélioration de [MAST][], lui-même une proposition d'amélioration du script Bitcoin actuel. MAST améliore
  l'évolutivité, la confidentialité et la fongibilité en permettant que les branches conditionnelles inutilisées dans les scripts Bitcoin
  soient laissées hors de la chaîne de blocs. Taproot améliore encore l'évolutivité, la confidentialité et la fongibilité de MAST en
  permettant même que la branche conditionnelle utilisée dans un script soit laissée hors de la chaîne de blocs dans le cas courant.
  Graftroot améliore la flexibilité et l'évolutivité de taproot en permettant aux participants du script de déléguer leur autorité de
  dépense à d'autres parties, y compris en permettant aux participants existants d'imposer des conditions supplémentaires basées sur des
  scripts aux délégués---le tout hors chaîne et sans réduire les bénéfices d'évolutivité, de confidentialité et de fongibilité.

  Dans une [discussion][graftroot discussion] progressant lentement, les membres de la liste de diffusion bitcoin-dev ont tenté de
  construire une preuve de sécurité formulée de manière informelle selon laquelle l'activation par défaut de la délégation graftroot ne
  réduit pas la sécurité des utilisateurs qui n'en ont pas besoin (par ex. ceux qui veulent simplement utiliser taproot sans délégation ou
  même simplement MAST). Bien qu'un examen par les pairs supplémentaire soit nécessaire, l'effort semble progresser positivement, les
  experts s'accordant actuellement sur le fait qu'il est sûr d'activer graftroot par défaut.

[graftroot]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-February/015700.html
[taproot]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-January/015614.html
[MAST]: https://bitcointechtalk.com/what-is-a-bitcoin-merklized-abstract-syntax-tree-mast-33fdf2da5e2f
[graftroot discussion]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-June/016049.html

- **Discussion sur [BIP174][] :** comme mentionné dans [le bulletin de la semaine dernière][le bulletin #1], la [discussion][bip174
  discussion] sur la liste de diffusion se poursuit autour de cette proposition de BIP pour une norme industrielle visant à faciliter la
  communication entre portefeuilles dans le cas des portefeuilles en ligne/hors ligne (chaud/froid), des portefeuilles logiciels/matériels,
  des portefeuilles multisig et des transactions multi-utilisateurs (par ex. CoinJoin). Cependant, le proposant du BIP a maintenant ouvert
  une [pull request][bip174 update] demandant que le statut du BIP soit changé de "draft" à "proposed". Cela signifie qu'il est peu probable
  qu'il soit modifié à moins qu'un problème important d'implémentation ne soit découvert. Si votre organisation produit ou utilise de
  manière critique l'un des portefeuilles interopérables mentionnés ci-dessus, vous pourriez souhaiter évaluer la proposition actuelle dès
  que possible avant qu'elle ne soit finalisée.

[BIP174]: https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki
[BIP174 update]: https://github.com/bitcoin/bips/pull/694
[BIP174 discussion]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-June/016150.html

- **Relais de transactions [Dandelion][] :** cette proposition d'amélioration de la confidentialité du mode de relais initial des nouvelles
  transactions a été [brièvement discutée][dandelion discussion] cette semaine sur la liste de diffusion bitcoin-dev. La principale
  préoccupation concernait la manière dont il sélectionne les pairs à travers lesquels router les transactions, ce qui pourrait être
  exploité pour réduire temporairement la confidentialité durant le déploiement initial lorsque seuls quelques nœuds prennent en charge
  Dandelion. Deux mesures d'atténuation de ce problème ont été discutées.

[Dandelion]: https://github.com/mablem8/bips/blob/master/bip-dandelion.mediawiki
[dandelion discussion]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-June/016162.html
