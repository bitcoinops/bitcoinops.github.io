---
title: 'Bulletin Hebdomadaire Bitcoin Optech #19'
permalink: /fr/newsletters/2018/10/30/
name: 2018-10-30-newsletter-fr
slug: 2018-10-30-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine suggère une mise à jour pour les utilisateurs de C-Lightning, décrit une discussion sur l'ordonnancement
déterministe des entrées/sorties de BIP69 sur la liste de diffusion, note que la prise en charge publique d'ASICBoost est disponible pour
les mineurs utilisant des Antminer S9, et fournit des liens vers des ressources à propos à la fois de la solution de stockage à froid
multisig basée sur HSM Subzero publiée en open source par Square et de la récente Lightning Network Residency et Hackday à New York. Sont
également inclus une sélection récente de questions-réponses de Bitcoin Stack Exchange et des descriptions de changements notables dans le
code de projets populaires d'infrastructure Bitcoin.

## Action items

- **Mettez à jour vers [C-Lightning 0.6.2][] :** corrige un bug où le nœud envoyait à ses pairs un nombre excessif d'annonces de mise à jour
  à propos de canaux morts.

## Nouvelles

- **Discussion sur [BIP69][] :** ce BIP de 2015 adopté par plusieurs portefeuilles notables spécifie une méthode optionnelle pour ordonner
  de façon déterministe les entrées et sorties au sein d'une transaction sur la base du contenu public de la transaction. Cependant,
  d'autres portefeuilles ne l'ont pas adopté (ou l'ont même rejeté comme inadapté à l'adoption), menant peut-être à une situation du « pire
  des deux mondes » où les portefeuilles utilisant BIP69 peuvent être identifiés assez facilement et où les portefeuilles n'utilisant pas
  BIP69 peuvent également être plus faciles à identifier par négation.

  Dans ce [fil][bip69 thread] sur la liste de diffusion Bitcoin-Dev, Ryan Havar suggère qu'une raison pour laquelle les auteurs de
  portefeuilles aiment BIP69 est que son ordonnancement déterministe rend simple et rapide pour leurs tests de s'assurer qu'ils n'ont
  divulgué aucune information à propos de la source de leurs entrées ou de la destination de leurs sorties (par ex. dans certains anciens
  portefeuilles, la première sortie allait toujours au destinataire et la seconde sortie était toujours la monnaie---rendant le suivi des
  pièces trivial). Havar suggère ensuite un ordonnancement déterministe alternatif fondé sur des informations privées qui seraient
  disponibles pour la suite de tests mais non exposées par les portefeuilles en production, permettant aux développeurs qui veulent
  contrecarrer l'analyse de la chaîne de blocs---tout en ayant aussi des tests simples et rapides---de s'éloigner de BIP69.

- **Prise en charge d'ASICBoost manifeste pour les mineurs S9 :** la prise en charge de cette fonctionnalité améliorant l'efficacité a été
  annoncée cette semaine à la fois par [Bitmain][bitmain oab] et [Braiins][braiins oab]. ASICBoost tire parti du fait que l'algorithme
  SHA256 utilisé dans le minage de Bitcoin découpe d'abord l'en-tête de bloc de 80 octets en segments de 64 octets. Si un mineur peut
  trouver plusieurs en-têtes de blocs proposés où le premier segment de 64 octets est différent mais où le début du segment suivant de 64
  octets est identique, alors il peut essayer différentes combinaisons du premier segment et du second segment afin de réduire le nombre
  total d'opérations de hachage qu'il doit effectuer pour trouver un bloc valide. Les premières estimations indiquent une amélioration de 10
  % (ou peut-être davantage) sur le matériel Antminer S9 existant.

  La forme manifeste d'ASICBoost modifie le champ versionbits dans l'en-tête de bloc, ce qui peut amener des programmes comme Bitcoin Core à
  afficher un avertissement tel que « 13 of last 100 blocks have unexpected version ». Certains mineurs ASICBoost ont volontairement
  restreint leur plage modifiée de versionbits à celle définie par [BIP320][], donnant aux futurs programmes l'option d'ignorer ces bits
  pour la signalisation de mise à niveau.

- **Solution de stockage à froid multisig basée sur HSM publiée en open source :** [Square][] a publié le code et la documentation de la
  solution de stockage à froid qu'ils ont mise en œuvre pour protéger les dépôts des clients, ainsi qu'un outil CLI pour auditer les soldes
  de portefeuilles HD à des moments arbitraires dans le temps. Optech n'a pas évalué leur solution, mais nous pouvons recommander aux
  parties intéressées de lire l'excellent [article de blog][subzero blog] de Square et de visiter les dépôts de la solution de stockage à
  froid [Subzero][] et de l'outil d'audit [Beancounter][].

- **Lightning Residency et Hackday :** la semaine dernière, [Chaincode Labs][] a accueilli un programme de cinq jours [Lightning Network
  Residency][] pour aider à intégrer des développeurs à ce protocole naissant. À la suite de cela, Fulmo a organisé son quatrième [Lightning
  Network Hackday][] (en réalité deux jours) également à New York, avec quelques discours, de nombreuses démos et beaucoup de hacking.

  Pierre Rochard a rédigé des résumés de toutes les présentations données lors du programme residency ([jour 1][lr1], [jour 2][lr2],
  [jour 3][lr3], [jour 4][lr4]) et les vidéos des présentations devraient être publiées prochainement. Les vidéos du hackday sont déjà
  disponibles : [jour 1][hd1], [jour 2][hd2].

## Questions et réponses sélectionnées de Bitcoin Stack Exchange

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech cherchent des réponses à leurs
questions---ou quand nous avons quelques moments libres pour aider les utilisateurs curieux ou confus. Dans cette rubrique mensuelle, nous
mettons en lumière certaines des questions et réponses les mieux votées postées depuis notre dernière mise à jour.*

- [Est-ce que l'utilisation du pruning rend la synchronisation initiale du nœud plus rapide ?][bse 79592] L'élagage des blocs après leur
  traitement peut réduire les besoins en espace disque de plus de 97 % à l'heure actuelle, mais accélère-t-il aussi la synchronisation ? Le
  développeur Bitcoin Core Gregory Maxwell répond.

- [Quelqu'un peut-il vous voler en fermant son canal de paiement Lightning Network d'une certaine manière ?][bse 80399] Plusieurs
  différentes façons de fermer un canal de paiement Lightning Network sont décrites, et le développeur C-Lightning Christian Decker explique
  comment un programme suivant le protocole LN protégera votre argent dans chaque cas.

- [Combien d'énergie faut-il pour créer un bloc ?][bse 79691] Nate Eldredge fournit une formule simple et un ensemble de liens vers des
  données que n'importe qui peut utiliser pour estimer la quantité moyenne d'énergie nécessaire pour générer un bloc au niveau de difficulté
  actuel. Pour la difficulté actuelle en utilisant uniquement des Antminer S9 sans ASICBoost, un bloc moyen consomme 841 629 kilowattheures
  (kWh). À une estimation courante de 0,04 $/kWh, cela représente environ 34 000 $ d'électricité---bien en dessous de la subvention de bloc
  actuelle d'environ 80 000 $---mais en utilisant [l'estimation récente d'AJ Towns][towns mining estimate] de 0,16 $/kWh qui inclut des
  coûts au-delà de l'électricité et tente de prendre en compte des primes de risque, le coût estimé d'un bloc est d'environ 135 000 $.

## Notable merges

*Changements notables dans le code cette semaine dans [Bitcoin Core][bitcoin core repo], [LND][lnd repo], [C-lightning][core lightning
repo], et [libsecp256k1][libsecp256k1 repo].*

{% comment %}<!-- no commits to libsecp256k1; one interesting commit
#448 to C-Lightning, but I'm not confident enough of my understanding of
it to write a good description, and I doubt non-LN devs care -->{% endcomment %}

- [Bitcoin Core #14451][] permet de compiler optionnellement Bitcoin-Qt sans prise en charge du protocole de paiement [BIP70][] et ajoute un
  avertissement de dépréciation indiquant que la prise en charge par défaut pourrait être supprimée dans une future version. Le PDG de
  BitPay, qui est le plus grand utilisateur de BIP70 (mais qui veut utiliser une version différente du protocole), a [indiqué][bitpay bip70
  comment] qu'il soutenait la suppression de BIP70 par Bitcoin Core. Les développeurs semblent favorables à la suppression du protocole pour
  des raisons de sécurité et parce que son utilisation est en déclin. La dépendance de BIP70 à OpenSSL a entraîné la publication en urgence
  de [Bitcoin Core 0.9.1][] en 2014 à la suite de la [vulnérabilité Heartbleed][], et il est prévu que sa suppression éliminera le risque de
  vulnérabilités similaires à l'avenir.

- [Bitcoin Core #14296][] supprime la RPC `addwitnessaddress`, devenue obsolète. Cette RPC a été ajoutée dans la version 0.13.0 pour
  permettre de tester segwit sur regtest et testnet avant son activation sur mainnet et son intégration dans le portefeuille. Depuis la
  version 0.16.0, le portefeuille de Bitcoin Core prend en charge l'obtention directe d'adresses en utilisant le mécanisme habituel
  [getnewaddress][rpc getnewaddress].

- [Bitcoin Core #14468][] déprécie la RPC `generate`. Cette méthode génère de nouveaux blocs en mode regtest, mais elle nécessite d'obtenir
  de nouvelles adresses à partir du portefeuille intégré de Bitcoin Core afin de leur verser la [récompense de bloc][term block reward] du
  minage. Une méthode de remplacement, [generatetoaddress][rpc generatetoaddress], a été introduite dans la version 0.13.0, ce qui permet à
  n'importe quel portefeuille regtest de générer une adresse qui recevra la récompense de bloc. Cela fait partie d'un effort continu pour
  permettre au plus grand nombre possible de RPC de fonctionner sans le portefeuille afin d'améliorer la couverture de test des nœuds sans
  portefeuille ainsi que de faciliter une future transition possible vers une séparation complète du portefeuille et du nœud.

- [Bitcoin Core #14150][] ajoute la prise en charge de l'[origine de clé][] aux [descripteurs de scripts de sortie][output script
  descriptors]. En plus de vous permettre de passer un argument supplémentaire à la RPC [scantxoutset][rpc scantxoutset], cela n'ajoute
  actuellement aucune fonctionnalité à Bitcoin Core---mais cela permettra d'utiliser l'origine de clé avec les PSBT [BIP174][] et les
  portefeuilles en surveillance seule lorsque ces parties du logiciel auront été mises à jour pour utiliser des descripteurs. Voir les
  bulletins [#5][le bulletin #5], [#7][le bulletin #7], [#9][le bulletin #9], [#12][le bulletin #12], et [#17][le bulletin #17] pour les
  précédentes discussions sur les descripteurs de scripts de sortie. La prise en charge de l'origine de clé permet d'utiliser des clés
  publiques étendues qui ont été exportées depuis un portefeuille HD utilisant la dérivation renforcée [BIP32][] pour protéger les clés
  privées ancêtres, ce qui aide à rendre les descripteurs de scripts de sortie compatibles avec la plupart des portefeuilles matériels.

- [LND #1981][] garantit que LND ne divulgue pas d'informations à propos de ses pairs qui ne s'annoncent pas comme nœuds publics.

- {:#lnd-1535-1512}
  LND [#1535][LND #1535] et [#1512][LND #1512] ajoutent le protocole de communication côté serveur pour les watchtowers
  ainsi que de nombreux tests vérifiant leur bon fonctionnement. L'utilisation correcte du protocole LN nécessite une surveillance régulière
  des transactions qui sont ajoutées à la chaîne de blocs ; les watchtowers sont donc des serveurs conçus pour aider à défendre les canaux
  de paiement des utilisateurs qui s'attendent à être hors ligne pendant une période prolongée. À ce titre, les watchtowers sont considérées
  comme une fonctionnalité clé pour permettre une adoption plus large de LN par des utilisateurs moins avancés. Cependant, une spécification
  standard pour les watchtowers n'a pas été convenue entre les multiples implémentations de LN, donc LND ne propose cette fonctionnalité que
  pour des tests initiaux et en restreint l'usage au testnet.

{% include references.md %}
{% include linkers/issues.md issues="14451,14296,14468,14150,1981,1535,1512" %}

{% assign bse = "https://bitcoin.stackexchange.com/a/" %}
[bse 79592]: {{bse}}79592
[bse 80399]: {{bse}}80399
[bse 79691]: {{bse}}79691

[hd1]: https://www.youtube.com/watch?v=FGxFd944jMg
[hd2]: https://www.youtube.com/watch?v=o87GVYFvwIk
[lr1]: https://medium.com/@pierre_rochard/day-1-of-the-chaincode-labs-lightning-residency-ab4c29ce2077
[lr2]: https://medium.com/@pierre_rochard/day-2-of-the-chaincode-labs-lightning-residency-669aecab5f16
[lr3]: https://medium.com/@pierre_rochard/day-3-of-the-chaincode-labs-lightning-residency-5a7fad88bc62
[lr4]: https://medium.com/@pierre_rochard/day-4-of-the-chaincode-labs-lightning-residency-f28b046fc1a6
[c-lightning 0.6.2]: https://github.com/ElementsProject/lightning/releases
[bip69 thread]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-October/016457.html
[bitmain oab]: https://blog.bitmain.com/en/new-firmware-activate-overt-asicboost-bm1387-antminer-models/
[braiins oab]: https://twitter.com/braiins_systems/status/1055153228772503553
[subzero blog]: https://medium.com/square-corner-blog/open-sourcing-subzero-ee9e3e071827
[subzero]: https://github.com/square/subzero
[beancounter]: https://github.com/square/beancounter/
[lightning network residency]: https://lightningresidency.com/
[chaincode labs]: https://chaincode.com/
[lightning network hackday]: https://lightninghackday.fulmo.org/
[bitpay bip70 comment]: https://github.com/bitcoin/bitcoin/pull/14451#issuecomment-431496319
[bitcoin core 0.9.1]: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-0.9.1.md
[vulnérabilité Heartbleed]: https://bitcoin.org/en/alert/2014-04-11-heartbleed
[term block reward]: https://btcinformation.org/en/glossary/block-reward
[origine de clé]: https://gist.github.com/sipa/e3d23d498c430bb601c5bca83523fa82#key-origin-identification
[towns mining estimate]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/playing-with-fire-adjusting-bitcoin-block-subsidy/
[square]: https://cash.app/bitcoin
[le bulletin #5]: /fr/newsletters/2018/07/24/#premiere-utilisation-des-descripteurs-de-scripts-de-sortie
[le bulletin #7]: /fr/newsletters/2018/08/07/#bitcoin-core-13697
[le bulletin #9]: /fr/newsletters/2018/08/21/#descripteurs-de-script-et-descript-script-descriptors-and-descript
[le bulletin #12]: /fr/newsletters/2018/09/11/#bitcoin-core-14096
[le bulletin #17]: /fr/newsletters/2018/10/16/#descripteurs-de-script-et-descript
[output script descriptors]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
