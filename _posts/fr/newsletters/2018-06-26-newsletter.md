---
title: 'Bulletin Hebdomadaire Bitcoin Optech #1'
permalink: /fr/newsletters/2018/06/26/
name: 2018-06-26-newsletter-fr
slug: 2018-06-26-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
version: 1
excerpt: Announces a pending vulnerability disclosure for older Bitcoin Core releases, links to a PR about improved coin selection, and discusses dynamic wallet loading and unloading in Bitcoin Core multiwallet mode.
---
## Bienvenue

Bienvenue dans le premier bulletin du groupe Bitcoin Optech ! En tant que membre de notre nouvelle organisation, vous pouvez vous attendre à
recevoir régulièrement de notre part des bulletins couvrant le développement open source de Bitcoin et les nouvelles du protocole, les
annonces d’Optech, ainsi que des études de cas d’entreprises membres. Nous prévoyons de publier ces bulletins sur notre site web.

Nous espérons que vous trouverez ce bulletin utile. Nous le créons pour vous, alors n’hésitez pas à nous contacter si vous avez des retours,
qu’il s’agisse de sujets supplémentaires que vous aimeriez nous voir couvrir ou d’améliorations à ce que nous incluons déjà.

Un rappel aux entreprises qui ne sont pas encore devenues membres officiels. Nous vous demandons de verser une contribution nominale de 5
000 $ pour nous aider à financer nos dépenses.

## Premier atelier Optech !

Le groupe Bitcoin Optech organise le premier d’une série d’ateliers qui se tiendra **le 17 juillet à San Francisco**. Square a gracieusement
proposé d’accueillir l’atelier de l’après-midi, et nous aurons ensuite un dîner de groupe. Les participants seront 1 à 2 ingénieurs
d’entreprises Bitcoin de la région de la baie de San Francisco. Nous aurons des discussions en table ronde couvrant 3 sujets :

- Les meilleures pratiques de sélection de pièces ;
- Les meilleures pratiques d’estimation des frais, de RBF et de CPFP ;
- La communauté et la communication Optech - optimiser Optech pour les besoins des entreprises.

Nous prévoyons d’organiser des ateliers similaires dans d’autres régions en fonction de la demande des entreprises membres d’Optech. Si cela
vous semble intéressant, n’hésitez pas à nous contacter et à nous faire savoir ce que vous aimeriez voir.

## Nouvelles Open Source

Un thème récurrent que nous avons entendu lors de notre premier travail de sensibilisation auprès des entreprises Bitcoin est le désir
d’améliorer la communication avec la communauté open source. À cette fin, dans chaque bulletin, nous prévoyons de fournir un résumé des
actions pertinentes à entreprendre, des éléments de tableau de bord et des nouvelles de la communauté open source Bitcoin au sens large.

### Actions à entreprendre

- **Divulgation en attente d’une vulnérabilité DoS pour Bitcoin Core 0.12.0 et versions antérieures. Les altcoins peuvent être affectés.**
  Comme [annoncé][alert announcement] en novembre 2016, les développeurs de Bitcoin Core prévoient de publier la clé privée que Satoshi
  Nakamoto a créée en 2010 pour signer les alertes réseau. Cette clé peut être détournée pour créer une condition de mémoire insuffisante
  (OOM) dans Bitcoin 0.3.9 à Bitcoin Core 0.12.0, ce qui entraînera le plantage de ces nœuds (mais aucune attaque entraînant une perte
  d’argent n’a été divulguée). De nombreux altcoins ont été forkés à partir de code antérieur à 0.12.0 et peuvent être vulnérables aux mêmes
  attaques, mais ils utilisent des clés différentes et l’attaque ne peut donc pas être exploitée à moins que ces clés ne soient également
  mal utilisées.

  Les actions recommandées sont (1) de vérifier votre infrastructure pour repérer les nœuds Bitcoin 0.12.0 ou antérieurs et les mettre à
  niveau si possible (cela inclut les anciennes versions de Bitcoin XT, Bitcoin Classic et Bitcoin Unlimited) ; (2) de vérifier votre
  infrastructure pour repérer les nœuds d’altcoins basés sur Bitcoin Core 0.12.0 ou antérieur et soit les mettre à niveau, soit les placer
  derrière un proxy qui filtre les messages d’alerte du protocole pair-à-pair. Si vous dépendez absolument de nœuds antérieurs à 0.12.0,
  veuillez en informer immédiatement un développeur Bitcoin Core ou votre contact Optech.

[alert announcement]: https://bitcoin.org/en/alert/2016-11-01-alert-retirement

- **Bitcoin Core [0.16.1 released][] :** contient un correctif pour un cas pouvant entraîner une perte monétaire pour les mineurs dans des
  situations supposées assez rares. Corrige également une attaque DoS qui affectait principalement les nouveaux nœuds et inclut un
  changement de politique de relais en prévision d’un éventuel futur soft fork dans plus d’un an. La mise à niveau est recommandée pour tous
  les utilisateurs et fortement recommandée pour les mineurs.

[0.16.1 released]: https://bitcoincore.org/en/2018/06/15/release-0.16.1/

- **La liste de diffusion bitcoin-dev change d’hébergeur :** si vous êtes abonné à la [liste de diffusion publique Bitcoin
  Development][mailing list], notez qu’une annonce sera bientôt publiée au sujet d’un changement de nom de domaine. On ne sait pas encore si
  une action de la part des utilisateurs sera nécessaire en dehors d’adresser les e-mails à un nom de domaine différent, bien qu’un
  changement d’hébergeur il y a trois ans ait exigé que tous les membres se réabonnent.

[mailing list]: https://groups.google.com/g/bitcoindev/

### Éléments du tableau de bord

- **Augmentation des frais de transaction :** on pensait qu’un pic des frais de transaction observé au début de la semaine dernière était
  lié au piratage de Bithumb, à la fois par le déplacement des fonds volés par l’attaquant et par le déplacement de leurs fonds par d’autres
  personnes en réponse à l’évolution rapide des taux de change. À la date de cet e-mail, les transactions à faibles frais sont toujours
  confirmées en quelques blocs, ce qui en fait un bon moment pour les transactions de consolidation.

### Nouvelles

- **Nouveau format de sauvegarde et de récupération pour les éléments de clés privées :** plusieurs développeurs travaillent sur un nouvel
  encodage pour les clés privées Bitcoin, les clés publiques et privées étendues de portefeuilles HD, et les graines de portefeuilles HD. Le
  format est vaguement basé sur le format bech32 utilisé pour les adresses segwit natives. L’encodage est [activement développé][bech32x]
  sur la liste de diffusion bitcoin-dev et la participation est encouragée pour toute entreprise qui gère des éléments de clés privées dans
  ses propres sauvegardes (par ex. sauvegardes de portefeuilles papier) ou fournit de tels services à des clients (par ex. balayage de
  fonds).

[bech32x]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-June/016065.html

- **Simulations de sélection de pièces :** la prochaine version 0.17.0 de Bitcoin Core implémente un algorithme de sélection de pièces
  beaucoup plus efficace basé sur l’[algorithme Branch and Bound][branch and bound paper] de Mark Erhardt. Les contributeurs exécutent
  actuellement des simulations visant à identifier une stratégie de repli appropriée lorsque cette stratégie idéale ne fonctionne pas. Si
  votre organisation utilise Bitcoin Core pour optimiser la sélection de pièces afin de minimiser les frais, il peut être utile de suivre ou
  de contribuer à la PR Bitcoin Core [#13307][pr 13307].

[branch and bound paper]: http://murch.one/wp-content/uploads/2016/11/erhardt2016coinselection.pdf
[pr 13307]: https://github.com/bitcoin/bitcoin/pull/13307

- **Discussion sur [BIP174][] :** la [discussion][bip174 discussion] sur la liste de diffusion se poursuit autour de cette proposition de
  BIP pour une norme industrielle destinée à faciliter la communication entre portefeuilles dans le cas des portefeuilles en ligne/hors
  ligne (chaud/froid), des portefeuilles logiciels/matériels et des portefeuilles multisig. Cependant, des changements significatifs de la
  proposition rencontrent désormais une résistance, de sorte que la finalisation pourrait être proche. Si votre organisation produit ou fait
  un usage critique de l’un des portefeuilles interopérables mentionnés ci-dessus, vous pourriez souhaiter évaluer la proposition actuelle
  dès que possible avant sa finalisation.

[BIP174]: https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki
[BIP174 discussion]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-June/016121.html

- **Chargement dynamique de portefeuilles dans Bitcoin Core :** la dernière PR a été fusionnée pour un nouvel ensemble de RPC dans Bitcoin
  Core conçus pour lui permettre de créer dynamiquement de nouveaux portefeuilles en mode multiwallet, de les charger et de les décharger.
  Si votre organisation gère des transactions depuis Bitcoin Core (ou souhaite le faire), cela peut rendre beaucoup plus facile la
  segmentation de vos portefeuilles (par ex. séparer les dépôts clients des fonds de l’entreprise, ou les fonds du portefeuille chaud des
  fonds froids en mode watch-only). Du code de préproduction est disponible sur la branche git master de Bitcoin Core en utilisant les RPC
  `createwallet`, `loadwallet` et `unloadwallet`.
