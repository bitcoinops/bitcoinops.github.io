---
title: 'Bulletin Hebdomadaire Bitcoin Optech #5'
permalink: /fr/newsletters/2018/07/24/
name: 2018-07-24-newsletter-fr
slug: 2018-07-24-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
version: 1
---
Le bulletin de cette semaine comprend des informations sur un nouveau langage pour décrire les scripts de sortie, une mise à jour sur la
prise en charge par Bitcoin Core des transactions Bitcoin partiellement signées, ainsi que des nouvelles sur plusieurs autres fusions
notables dans Bitcoin Core.

## Éléments d'action

- [Bitcoin Core 0.16.2RC2][] publié pour tests en préparation d'une version de maintenance qui fournira des corrections de bogues et des
  rétroportages. Les tests par la communauté sont grandement appréciés. Notez qu'il n'y a pas eu de RC1 en raison d'un problème de
  métadonnées détecté durant le processus de publication.

## Éléments du tableau de bord

- Les frais de transaction sont plus bas qu'à la même période la semaine dernière. Toute personne qui peut attendre 12 blocs ou plus pour
  une confirmation peut raisonnablement payer le taux de frais minimum par défaut. C'est un bon moment pour [consolider des UTXOs][].

- Le nombre de [sorties segwit natives][p2shinfo bech32] avait augmenté régulièrement au fil du temps, mais a chuté d'environ 400 000 (80 %)
  cette semaine, possiblement en raison de la consolidation d'UTXOs par une plateforme d'échange. Le nombre moyen de nouvelles sorties
  segwit natives créées par heure reste relativement constant, ce qui n'indique aucune baisse évidente de l'adoption.

## Nouvelles

- **Bitcoin Optech annoncé publiquement :** nous avons reçu une excellente couverture dans [Bitcoin Magazine][announce bmag],
  [Coindesk][announce cdesk], et plusieurs autres publications. Cela n'aurait pas été possible sans le soutien de nos sponsors fondateurs et
  entreprises membres. Merci !

- **Premier atelier Optech tenu à San Francisco :** comme [annoncé précédemment][workshop announce], nous avons tenu notre premier atelier à
  San Francisco la semaine dernière. Il y avait 14 ingénieurs d'entreprises de la Bay Area et de projets open source présents, et nous avons
  eu d'excellentes discussions sur la sélection de pièces, le remplacement par frais et le child-pays-for-parent. Merci à Square pour
  l'accueil et à Coinbase pour l'aide à l'organisation.

  Si vous travaillez dans une entreprise membre et avez des demandes ou suggestions pour de futurs événements Optech (qu'il s'agisse du
  lieu, du site, des dates, du format, des sujets, ou de toute autre chose), veuillez nous contacter. Nous sommes là pour aider nos
  entreprises membres !

- **RPC de sélection de pièces peu probable :** lors de la [réunion hebdomadaire][bcc meeting 7/19] de Bitcoin Core, Andrew Chow a soulevé
  la possibilité de créer une RPC qui permettrait aux utilisateurs de fournir des informations sur une transaction qu'ils souhaitent créer,
  y compris une liste des entrées disponibles, et de recevoir en retour une liste des entrées qui seraient sélectionnées par l'algorithme de
  sélection de pièces du portefeuille Bitcoin Core.

  Les participants à la réunion étaient pour la plupart opposés à la fourniture de cette fonctionnalité, suggérant qu'il vaudrait mieux
  qu'il s'agisse d'une bibliothèque et que le travail récent et en cours de Bitcoin Core visant à encapsuler son code de sélection de pièces
  simplifierait le développement d'une bibliothèque tierce plus tard. Une opposition particulière à l'idée était qu'elle pourrait réduire le
  rythme de développement pour les utilisateurs directs du portefeuille Bitcoin Core ; comme l'a dit Gregory Maxwell, « La pression pour
  maintenir une interface stable vers [la sélection de pièces] serait nuisible au projet. [...] Je ne veux pas entendre "nous ne pouvons pas
  implémenter la fonctionnalité de confidentialité X parce que cela casserait l'interface [de sélection de pièces]". »

- **Première utilisation des descripteurs de scripts de sortie :** Pieter Wuille a ouvert la PR [#13697][Bitcoin Core #13697] pour Bitcoin
  Core qui implémente son langage des [descripteurs de scripts de sortie][] pour décrire quels scripts de sortie (scriptPubKeys) un
  portefeuille doit surveiller. Cette PR particulière ne s'applique qu'à la RPC récemment ajoutée [`scantxoutset`][Bitcoin Core #12196],
  mais l'objectif ultime de Wuille est d'utiliser ce nouveau langage ailleurs dans l'API et « d'éliminer complètement le besoin d'importer
  des scripts et des clés, et à la place faire en sorte que le portefeuille ne soit qu'une liste de ces descripteurs plus les métadonnées
  associées. »

- **Prise en charge de BIP174 Partially Signed Bitcoin Transaction (PSBT) fusionnée :** cela fournit un format standardisé que plusieurs
  portefeuilles peuvent utiliser pour communiquer des informations sur des transactions qui doivent être signées, afin que des portefeuilles
  chauds puissent obtenir des signatures de portefeuilles froids ou de portefeuilles matériels, que des transactions multisig puissent être
  signées par plusieurs portefeuilles, et que plusieurs portefeuilles puissent créer collaborativement des transactions multipartites telles
  que des CoinJoins. Plusieurs RPC sont ajoutées avec cette fusion : `walletprocesspsbt`, `walletcreatefundedpsbt`, `decodepsbt`,
  `combinepsbt`, `finalizepsbt`, `createpsbt`, et `convertpsbt`. Pour une description complète, voir la PR [#13557][Bitcoin Core #13557].

## Fusions notables dans Bitcoin Core

*Sans inclure celles précédemment discutées dans la section Nouvelles.*

{% comment %}
git log --merges b25a4c2284babdf1e8cf0ec3b1402200dd25f33f..07ce278455757fb46dab95fb9b97a3f6b1b84faf
{% endcomment %}

- [Bitcoin Core #9662][] : De nouveaux portefeuilles peuvent maintenant être créés avec les clés privées désactivées. Cela est
  principalement destiné aux utilisateurs qui veulent utiliser exclusivement leur portefeuille conjointement avec un autre programme ou un
  portefeuille matériel qui stocke les clés privées. Cela pourrait également être utile aux entreprises qui veulent utiliser des
  fonctionnalités de Bitcoin Core (comme la sélection de pièces) en créant un portefeuille, en important leurs adresses (mais pas les clés
  privées), puis en effectuant les actions souhaitées, comme utiliser la RPC [`fundrawtransaction`][rpc fundrawtransaction].

- [Bitcoin Core #12196][] : Nouvelle méthode RPC `scantxoutset` qui permet de rechercher dans l'ensemble des bitcoins dépensables (UTXOs)
  ceux correspondant à une adresse, une clé publique, une clé privée ou un chemin de clé HD. L'utilisation principale attendue de cela est
  le « balayage de fonds » où les transactions correspondant à un ancien portefeuille sont trouvées et transférées vers un nouveau
  portefeuille. Bien que cette RPC soit presque certainement incluse dans Bitcoin Core 0.17, elle sera probablement marquée comme
  expérimentale afin que son API puisse être librement modifiée dans les versions suivantes. Cette API sera probablement mise à jour pour
  prendre en charge les descripteurs de scripts de sortie, ce qui est prévu avant la 0.17.

- [Bitcoin Core #13604][] : Bitcoin-Qt est maintenant compilé par défaut en plus de bitcoind sur les systèmes ARM 32 bits, et devrait être
  distribué par défaut avec les autres binaires pour ce système depuis BitcoinCore.org dans les futures versions. Bitcoin-Qt avec ARM 64
  bits n'est pas encore pris en charge par défaut.

- [Bitcoin Core #13298][] : Le nœud envoie maintenant toutes les annonces ([invs][inv]) pour les nouvelles transactions à tous ses pairs
  entrants en même temps, après un délai aléatoire. Auparavant, Satoshi Nakamoto [a ajouté une fonctionnalité][rand delay] à Bitcoin (le
  logiciel) qui attendait un délai aléatoire différent pour chaque pair avant d'envoyer une annonce afin qu'une transaction se propage dans
  le réseau de manière quelque peu imprévisible, empêchant les nœuds espions de pouvoir supposer que le premier pair dont ils recevaient une
  transaction était probablement le pair qui l'avait créée.

  Cependant, des chercheurs ultérieurs ont réalisé qu'une personne exploitant plusieurs nœuds espions pouvait établir plusieurs connexions à
  chaque nœud afin d'augmenter ses chances d'être la première à recevoir une transaction donnée, permettant à l'espion de deviner à nouveau
  quel nœud avait créé la transaction. Cette fusion améliore la situation en empêchant un espion établissant plusieurs connexions de
  recevoir plus d'informations qu'un espion avec une seule connexion. Les connexions sortantes (qui sont sélectionnées par le nœud lui-même
  selon certaines règles) continuent d'utiliser l'ancien comportement afin que les transactions continuent à se propager de manière
  imprévisible.

  Ce changement pourrait légèrement augmenter le délai de propagation des transactions, bien que les développeurs commentant la PR pensent
  que l'effet sera minime. Il peut également faire en sorte que l'utilisation de la bande passante soit moins uniformément répartie dans le
  temps. Cependant, cela pourrait (en théorie) finir par réduire le nombre de connexions entrantes vers les nœuds mis à niveau, si les nœuds
  espions ne trouvent plus utile d'établir plusieurs connexions, réduisant la bande passante globalement gaspillée.

- [Bitcoin Core #13652][] : La RPC [`abandontransaction`][rpc abandontransaction] a été corrigée pour abandonner toutes les transactions
  descendantes, et pas seulement les enfants.

## À venir

Le bulletin de la semaine prochaine présentera un rapport de terrain d'Anthony Towns, un développeur chez Xapo, sur la manière dont ils ont
consolidé environ 4 millions d'UTXOs pour se préparer à de possibles augmentations futures des frais.

Nous aimons recevoir des contributions au bulletin de la part des entreprises membres. Si vous souhaitez partager vos expériences dans la
mise en œuvre d'une meilleure technologie Bitcoin, veuillez nous contacter !

[bcc meeting 7/19]: https://bitcoincore.org/en/meetings/2018/07/19/
[rand delay]: https://github.com/bitcoin/bitcoin/commit/22f721dbf23cf5ce9e3ded9bcfb65a3894cc0f8c#diff-118fcbaaba162ba17933c7893247df3aR718
[p2shinfo bech32]: https://p2sh.info/dashboard/db/bech32-statistics?orgId=1
[consolider des UTXOs]: https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#Consolidation
[Bitcoin Core 0.16.2rc2]: https://bitcoincore.org/bin/bitcoin-core-0.16.2/test.rc2/
[announce bmag]: https://bitcoinmagazine.com/articles/chaincode-devs-google-alumni-create-industry-group-help-bitcoin-scale/
[announce cdesk]: https://www.coindesk.com/bitcoins-biggest-startups-are-backing-a-new-effort-to-keep-fees-low/
[inv]: https://bitcoin.org/en/developer-reference#inv
[workshop announce]: /fr/newsletters/2018/06/26/#premier-atelier-optech
[descripteurs de scripts de sortie]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md

{% include references.md %}
{% include linkers/issues.md issues="13697,13557,12196,9662,12196,13604,13298,13652" %}
