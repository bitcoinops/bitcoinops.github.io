---
title: 'Bulletin Hebdomadaire Bitcoin Optech #3'
permalink: /fr/newsletter/2018/07/10/
name: 2018-07-10-newsletter-fr
slug: 2018-07-10-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
version: 1
---
Le bulletin de cette semaine comprend des nouvelles et des points d'action à propos des frais minimums et de la prochaine version de Bitcoin
Core, un article spécial sur une proposition de signature Schnorr, et un compte-rendu de la récente conférence Building on Bitcoin à
Lisbonne.

## Points d'action

- Les frais minimums de relais de Bitcoin Core pourraient être réduits dans la prochaine version majeure. Assurez-vous que votre logiciel ne
  fait pas d'hypothèses dangereuses sur 1 satoshi par vbyte comme étant le plancher le plus bas possible. Voir la section *Nouvelles*
  ci-dessous pour plus d'informations.

- Assurez-vous que votre logiciel de calcul de taille de transaction pour les frais dynamiques calcule précisément la taille des signatures
  ou, au minimum, utilise une hypothèse pessimiste selon laquelle les signatures Bitcoin font 72 octets. Voir la section *Nouvelles*
  ci-dessous pour plus d'informations.

- Comme les bulletins précédents avaient annoncé que cela se produirait, la clé d'alerte Bitcoin a été [publiée][alert released] avec la
  divulgation de vulnérabilités affectant Bitcoin Core 0.12.0 et les versions antérieures. Les altcoins peuvent être affectés. Si vous
  n'avez pas encore vérifié votre infrastructure à la recherche de services affectés, il est conseillé de le faire maintenant. Voir le
  [bulletin #1][] pour plus de détails

[alert released]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-July/016189.html
[le bulletin #1]: /en/newsletter/2018/06/26/

## Éléments du tableau de bord

- **Les frais de transaction restent très bas :** au moment de la rédaction, les estimations de frais pour une confirmation 2 blocs ou plus
  dans le futur restent à peu près au niveau des frais minimums de relais par défaut de Bitcoin Core. C'est un bon moment pour [consolider
  des entrées][consolidate inputs].

[consolidate inputs]: https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#Consolidation

- **Reprise de la production de blocs :** suite aux nouvelles de la semaine dernière concernant les inondations en Chine affectant les
  opérations des mineurs, la production de blocs Bitcoin semble être revenue au niveau attendu d'environ un bloc toutes les 10 minutes.

## Nouvelle en vedette : proposition de BIP pour les signatures Schnorr

Dans un [message][schnorr post] sur la liste de diffusion bitcoin-dev, Pieter Wuille a soumis un [brouillon de spécification][schnorr draft]
pour un format de signature basé sur Schnorr. L'objectif de la spécification est, espérons-le, d'obtenir l'accord de tous sur l'apparence
des signatures Schnorr sur Bitcoin avant que le travail ne commence sur un véritable soft fork, donc le BIP ne propose pas de nouveaux
opcodes spécifiques, de drapeaux de témoin segwit, de méthode d'activation du soft fork, ni de tout autre élément nécessaire pour faire de
ce changement une partie des règles de consensus de Bitcoin. Cependant, il est possible de dire ce que ce format de signature fournira s'il
devient la forme de signature Schnorr adoptée par Bitcoin.

[schnorr post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-July/016203.html
[schnorr draft]: https://github.com/sipa/bips/blob/bip-schnorr/bip-schnorr.mediawiki

1. Compatibilité totale avec les clés privées et les clés publiques Bitcoin existantes, ce qui signifie que les portefeuilles HD existants
   qui se mettent à niveau n'auront pas besoin de générer de nouvelles graines de récupération.

2. Des signatures environ 10 % plus petites, offrant une légère augmentation de la capacité de la chaîne de blocs à mesure que Schnorr est
   adopté.

3. Vérification par lot des signatures offrant une accélération d'environ 2x par rapport à la vérification individuelle pour un bloc rempli
   de signatures Schnorr. Cela affecte principalement les nœuds effectuant leur synchronisation initiale ou rattrapant leur retard après
   avoir été hors ligne.

4. Compression complète et confidentialité significativement améliorée pour les cas d'usage multisig, mais avec interaction requise : un
   nombre illimité de participants peut créer une seule clé publique de 33 octets et une signature de 64 octets à partir de la combinaison
   de leurs clés publiques individuelles et signatures, en utilisant un multisig sécurisé avec la même efficacité que la signature simple et
   en augmentant leur confidentialité en faisant ressembler le multisig à une signature simple. Cependant, le schéma exige une interaction
   en plusieurs étapes entre les portefeuilles participant au multisig, à la fois pour créer la clé publique et la signature.

5. Cas d'usage supplémentaires axés sur la confidentialité. Les exemples incluent une confidentialité accrue pour le Lightning Network (LN),
   des échanges atomiques plus privés (soit inter-chaînes lorsque les deux chaînes prennent en charge Schnorr, soit sur la même chaîne dans
   le cadre d'un protocole de mixage de coins), et des [oracles de signature privés][dlc] complets (des services qui attendent qu'un
   événement se produise dans la vie réelle, comme l'équipe qui gagne la coupe du monde, puis fournissent une signature s'engageant sur ce
   résultat, permettant par exemple à Alice et Bob de régler un pari onchain ou dans un canal LN). Beaucoup de ces cas améliorent également
   l'efficacité par rapport aux alternatives qui utilisent le script Bitcoin actuel.

[dlc]: https://adiabat.github.io/dlc.pdf

Un point notable absent de la proposition BIP est une méthode d'agrégation de signatures entre plusieurs entrées d'une même transaction.
C'était une fonctionnalité souhaitée qui pourrait permettre aux transactions de consolidation, aux coinjoins, et à d'autres transactions
avec beaucoup d'entrées d'être bien plus efficaces qu'elles ne le sont actuellement. Mais, comme le note l'auteur de la proposition : « Avec
l'émergence de tant d'idées pour améliorer l'exécution des scripts de Bitcoin (MAST, Taproot, Graftroot, nouveaux modes sighash, schémas de
multisignature, ...) il y a tout simplement trop à faire pour tout faire d'un coup. Puisque l'agrégation interagit vraiment avec toutes les
autres choses, il semble préférable de la poursuivre plus tard. » ([source][pwuille comment])

[pwuille comment]: https://www.reddit.com/r/Bitcoin/comments/8wmj5b/pieter_wuille_submits_schnorr_signatures_bip/e1wwriq/

## Nouvelles

- **[Discussion][min fee discussion] sur les frais minimums de relais :** il y a plusieurs années, lorsque le prix du Bitcoin représentait
  une fraction de sa valeur actuelle en USD, Bitcoin Core a fixé les frais minimums de relais à 1 satoshi par byte (maintenant vbyte). Avec
  l'augmentation des prix et d'autres changements du réseau, plusieurs développeurs ont discuté de la baisse des frais minimums de relais.
  Gregory Maxwell prévoit d'ouvrir une pull request sur Bitcoin Core qui pourrait à peu près diviser la valeur par deux (bien que le montant
  exact n'ait pas encore été déterminé).

  Cela pourrait être inclus dans la prochaine version majeure de Bitcoin Core. Si c'est le cas, cela signifiera que vous pourrez peut-être
  créer des transactions de consolidation moins coûteuses une fois que le changement aura été bien déployé. Cependant, cela signifie aussi
  que si vous ne mettez pas à niveau les nœuds que vous utilisez pour détecter les transactions non confirmées, ils pourraient ne pas voir
  les transactions non confirmées avec de faibles taux de frais à moins que vous ne changiez les valeurs par défaut. Cela pourrait affecter
  les informations que vous affichez à vos utilisateurs. Ces nœuds continueront quand même à voir toutes les transactions confirmées dans
  des blocs valides.

  Notez que pour réduire les frais minimums de relais dans Bitcoin Core en dessous de leur valeur par défaut, vous devez modifier deux
  paramètres. Sont indiqués ci-dessous les deux paramètres avec leurs valeurs par défaut dans Bitcoin Core 0.16.1 ; pour réduire les
  valeurs, modifiez-les tous les deux à la même valeur, mais sachez que les réduire trop fortement (peut-être à moins de 1/10e de la valeur
  par défaut) vous expose à des attaques gaspillantes en bande passante et réduit l'efficacité des blocs compacts BIP152 pour votre nœud.

  ```
  minrelaytxfee=0.00001000
  incrementalrelayfee=0.00001000
  ```

  Si votre organisation produit des logiciels pour utilisateurs finaux, vous souhaiterez peut-être vous assurer qu'ils fonctionnent avec des
  transactions et des estimations de frais définies en dessous de la valeur de 1 satoshi par byte. Veuillez contacter Optech si vous avez
  besoin de plus d'informations sur les frais minimums de relais.

[min fee discussion]: http://www.erisian.com.au/meetbot/bitcoin-core-dev/2018/bitcoin-core-dev.2018-07-05-19.22.log.html#l-24

- **Transactions non relayables :** au moins deux grands services ont été identifiés comme créant des transactions avec des taux de frais
  inférieurs au minimum actuel en raison d'une mauvaise compréhension de la taille maximale d'une signature Bitcoin, qui est de 72 octets.
  Les signatures Bitcoin varient en taille, avec la moitié de toutes les signatures générées aléatoirement qui font 72 octets, légèrement
  moins de la moitié qui font 71 octets, et le faible reste qui fait 70 octets ou moins.

  On peut supposer que les développeurs de certains logiciels ont regardé une signature choisie aléatoirement, ont vu qu'elle faisait 71
  octets, et ont supposé que toutes les signatures feraient 71 octets. Cependant, lorsque le logiciel génère une signature de 72 octets,
  cela rend la taille réelle de la transaction supérieure d'un octet par signature à la taille estimée, ce qui fait que les frais payés par
  octet sont légèrement plus bas que prévu.

  Cela ne causait pas de problèmes significatifs lorsque les estimations de frais étaient élevées, mais maintenant que les estimations de
  frais sont proches des frais minimums de relais par défaut de 1 satoshi par byte, toute transaction créée avec des frais légèrement
  inférieurs à cette valeur pourrait ne pas être relayée aux mineurs et donc rester non confirmée indéfiniment.

  Il est recommandé aux organisations de vérifier leur logiciel afin de s'assurer qu'il fait, au minimum, l'hypothèse pessimiste de
  signatures de 72 octets.

- **Gel imminent des fonctionnalités de Bitcoin Core 0.17 :** la semaine prochaine, les développeurs [prévoient][#12624] d'arrêter de
  fusionner de nouvelles fonctionnalités pour la prochaine version majeure de Bitcoin Core. Les fonctionnalités déjà présentes seront
  davantage testées et documentées, les traductions seront mises à jour, et les autres parties du processus de publication seront suivies.
  Si votre organisation dépendra d'une fonctionnalité dans les six prochains mois, c'est peut-être votre dernière chance de vous assurer
  qu'elle fera partie de 0.17. Les fonctionnalités actuellement non encore fusionnées mais susceptibles d'être ajoutées à Bitcoin Core
  0.17.0 incluent :

  - la RPC `scantxoutset` qui permet de rechercher dans l'ensemble des sorties de transaction non dépensées des adresses ou des scripts.
    Destinée à être utilisée avec le balayage d'adresses, par exemple pour trouver des fonds que vous possédez et les ramener dans l'un de
    vos portefeuilles actuels.

  - la prise en charge de [BIP174][] Partially Signed Bitcoin Transactions (PSBT), un protocole d'échange d'informations sur les
    transactions Bitcoin entre portefeuilles afin de faciliter une meilleure interopérabilité entre portefeuilles multisig, portefeuilles
    chauds/froids, coinjoins, et autres portefeuilles coopérants.

  - [Envoi différé des transactions par groupe réseau][#13298], une proposition qui, espère-t-on, rendra plus difficile pour les nœuds
    espions de déterminer quel client a diffusé une transaction en premier (indiquant qu'il pourrait s'agir du dépensier).

[#12624]: https://github.com/bitcoin/bitcoin/issues/12624
[BIP174]: https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki
[#13298]: https://github.com/bitcoin/bitcoin/issues/13298

- **Réimplémentation efficace d'Electrum Server :** dans une annonce sur la liste de diffusion bitcoin-dev cette semaine, il a été affirmé
  qu'une réimplémentation d'Electrum server en Rust est beaucoup plus efficace que la version Python. Optech n'a effectué aucun test à ce
  sujet et ne peut pas le confirmer, mais Electrum server est connu pour être utilisé par plusieurs entreprises Bitcoin à la fois en interne
  et hébergé pour le compte de leurs clients, donc certains lecteurs de ce bulletin pourraient souhaiter examiner cela.

## Building on Bitcoin

[**Building on Bitcoin**][bob website] était une conférence sur la technologie Bitcoin qui s'est tenue à Lisbonne la semaine dernière. Elle
a été bien fréquentée par les développeurs du protocole Bitcoin ainsi que par des ingénieurs d'applications. Une [vidéo][bob video] est
disponible, ainsi que plusieurs [transcriptions][bob transcripts] du développeur Bitcoin Bryan Bishop (kanzure).

[bob website]: https://building-on-bitcoin.com/
[bob video]: https://www.youtube.com/watch?v=XORDEX-RrAI
[bob transcripts]: http://diyhpl.us/wiki/transcripts/building-on-bitcoin/2018/

Les conférences suivantes peuvent présenter un intérêt particulier pour les entreprises Bitcoin Optech :

- [**Adoption marchande**][bitrefill video] - [Sergej Kotliar][sergej], PDG de Bitrefill, a donné un témoignage personnel sur le pic du
  marché des frais de la fin de l'année dernière, sur d'importantes considérations UX pour les paiements Bitcoin et Lightning, et sur les
  expériences de Bitrefill dans l'intégration de Lightning. Cette conférence était fascinante en raison des données empiriques du monde réel
  que Sergej a partagées et de son expérience directe des frais, de la mise à l'échelle et de Lightning.

[bitrefill video]: https://www.youtube.com/watch?v=Cpid31c6HZc&feature=youtu.be&t=8m49s
[sergej]: https://twitter.com/ziggamon

- [**Concevoir des portefeuilles Lightning pour les utilisateurs de Bitcoin**][lightning ux video] - [Patrícia Estevão][patricia] a donné
  une conférence sur les considérations UX lorsqu'on étend des portefeuilles Bitcoin pour prendre en charge les paiements Lightning. Une
  conférence intéressante pour toute entreprise qui commence à intégrer les paiements Lightning dans un produit Bitcoin existant.

[lightning ux video]: https://www.youtube.com/watch?v=XORDEX-RrAI&feature=youtu.be&t=6042
[patricia]: https://twitter.com/patestevao

- [**Signatures aveugles dans les Scriptless Scripts**][blind signatures video] - [Jonas Nick][jonas] a parlé de l'utilisation des
  signatures Schnorr comme base pour réaliser des coinswaps aveugles (où un serveur ne peut pas relier les coins) ou pour échanger des «
  ecash tokens » sur Bitcoin ou Lightning, entre autres choses. Cette conférence présente une réflexion de pointe sur ce qui est possible
  avec les scriptless scripts et les idées présentées sont encore loin d'être implémentables sur Bitcoin. Cependant, il est intéressant de
  voir certaines des nouvelles applications qui seront rendues possibles par l'adoption des signatures Schnorr dans Bitcoin.

[blind signatures video]: https://www.youtube.com/watch?v=XORDEX-RrAI&feature=youtu.be&t=25479
[jonas]: https://twitter.com/n1ckler

- [**Histoire de LN**][ln video] - [Fabrice Drouin][fabrice] a présenté une histoire du développement du Lightning Network. Beaucoup de
  contexte intéressant pour toute personne prévoyant d'intégrer et d'utiliser les paiements Lightning.

[ln video]: https://www.youtube.com/watch?time_continue=2881&v=Cpid31c6HZc
[fabrice]: https://twitter.com/acinq_co

- [**CoinJoinXT ... et autres techniques pour des transferts déniables**][coinjoin video] - [Adam Gibson][adam] a parlé de CoinJoinXT, une
  méthode pour améliorer la confidentialité dans Bitcoin en mélangeant les paiements et en brisant l'analyse du graphe des transactions. De
  nombreux portefeuilles prévoient d'implémenter une forme de CoinJoin, donc les ingénieurs Bitcoin devraient être au moins familiers avec
  les concepts de haut niveau.

[coinjoin video]: https://www.youtube.com/watch?v=XORDEX-RrAI&feature=youtu.be&t=23359
[adam]: https://twitter.com/waxwing__
