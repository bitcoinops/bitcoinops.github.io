---
title: 'Bulletin Hebdomadaire Bitcoin Optech #17'
permalink: /fr/newsletters/2018/10/16/
name: 2018-10-16-newsletter-fr
slug: 2018-10-16-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit brièvement une proposition de splice pour les canaux de paiement du Lightning Network, fournit des liens
vers les vidéos et transcriptions des présentations des sessions de formation Edge Dev++, et résume certaines transcriptions réalisées lors
de l'événement CoreDev.tech de la semaine dernière.

## Éléments d'action

Aucun cette semaine.

## Nouvelles

- **Proposition de splice pour les canaux de paiement du Lightning Network :** le splice est une idée permettant aux utilisateurs soit
  d'ajouter soit de retirer des fonds d'un canal de paiement existant sans le délai nécessaire pour fermer et rouvrir un canal entièrement
  nouveau. Rusty Russell a publié une [proposition technique][complex splice] permettant un seul splice à la fois, bien qu'il note que la
  proposition est complexe. René Pickhardt a décrit une [alternative][simpler splice] qui serait probablement plus facile à implémenter et à
  analyser, mais qui pourrait nécessiter davantage de transactions onchain. Il a été suggéré que la solution plus simple mais plus coûteuse
  pourrait être la version 1, et la solution plus complexe mais moins coûteuse pourrait être la version 2.

- **Publications des présentations d'Edge Dev++ :** une série de présentations de deux jours par des contributeurs Bitcoin de premier plan
  destinée aux développeurs a été publiée sous forme de [vidéos][dev vids] et de [transcriptions][dev transcripts]. Les présentations
  couvrent toute la gamme des sujets, de l'introduction à l'avancé. Trois présentations pourraient être particulièrement intéressantes pour
  les membres d'Optech :

  1. *Sécurité des plateformes d'échange* par Warren Togami. Décrit les causes de plusieurs vols majeurs notables sur des plateformes
     d'échange Bitcoin et altcoin et énumère un certain nombre de techniques que les entreprises peuvent utiliser pour réduire leur risque
     de perte. ([Vidéo][warren vid], [transcription][warren transcript])

  2. *Sécurité des portefeuilles, gestion des clés et modules matériels de sécurité (HSM)]* par Bryan Bishop. Suggère des méthodes pour
     diminuer le risque que des clés privées soient volées ou utilisées à mauvais escient. ([Vidéo][kanzure wallet vid],
     [transcription][kanzure wallet transcript])

  3. *Gestion des réorganisations et des forks* par Bryan Bishop. Décrit comment sécuriser vos transactions contre des changements dans la
     chaîne de blocs Bitcoin ou dans les règles de consensus, y compris des suggestions sur la manière de tester vos systèmes.
     ([Vidéo][kanzure reorg vid], [transcription][kanzure reorg transcript])

## CoreDev.tech

CoreDev.tech est un événement sur invitation uniquement pour des contributeurs bien connus de projets d'infrastructure Bitcoin tels que
Bitcoin Core et Lightning Network. Les discussions ne sont pas enregistrées, mais Bryan Bishop rédige utilement des transcriptions
approximatives et non officielles de certaines des discussions pendant les événements. Les courts résumés suivants sont basés sur certaines
des transcriptions de l'événement de la semaine dernière à Tokyo :

- **[Bitcoin Optech][optech transcript] :** Bitcoin Optech est présenté et brièvement discuté, suivi d'une discussion sur les problèmes
  courants que rencontrent les entreprises utilisant Bitcoin lorsqu'elles utilisent Bitcoin Core et d'autres projets d'infrastructure open
  source.

- **[Utilisation d'accumulateurs UTXO pour réduire les besoins de stockage de données][utreexo] :** Tadge Dryja décrit le travail qu'il a
  effectué sur des accumulateurs UTXO qui sont similaires dans leur fonction à ceux décrits dans le bulletin de la semaine dernière mais qui
  ont une construction différente basée sur des hachages. Il décrit en outre comment ils pourraient être combinés avec quelque chose comme
  l'idée [UTXO Hash Set (UHO)][UHO] de Cory Fields afin que les nœuds complets stockent des hachages d'UTXO au lieu d'UTXO complets pour
  réduire significativement la quantité de stockage utilisée par les nœuds complets élagués sans nécessairement exiger de modifications des
  règles de consensus.

- **[Descripteurs de script et DESCRIPT][script descriptors and descript] :** la manière rétrocompatible par défaut dont les portefeuilles
  tels que Bitcoin Core surveillent les sorties de transaction qui leur paient "est ambiguë, inflexible et passe mal à l'échelle". Les
  [descripteurs de script de sortie][output script descriptors] sont un langage simple pour décrire des scripts au portefeuille, ce qui
  permet au portefeuille de gérer plus facilement de nombreux cas normaux (y compris les importations de clés privées et publiques étendues
  HD).

  Dans un registre quelque peu lié, DESCRIPT est un langage qui utilise un sous-ensemble du langage complet Bitcoin Script pour faciliter la
  construction de certaines politiques simples. "Nous avons un compilateur DESCRIPT qui prend quelque chose que nous appelons un langage de
  politique (AND, OR, seuil, clé publique, hashlock, timelock) ainsi que des probabilités pour chaque OR afin d'indiquer si c'est 50/50 ou
  si un côté du OR est plus probable que le côté droit, et il trouvera [...] le script optimal dans ce sous-ensemble de script que nous
  avons défini." Par exemple, cela pourrait vous permettre "de faire quelque chose comme un multisig qui après un certain temps se dégrade
  en un multisig plus faible --- comme un 2-sur-3 mais après un an je peux le dépenser avec seulement une de ces clés."

## Changements notables dans le code

*Changements notables dans le code cette semaine dans [Bitcoin Core][bitcoin core repo], [LND][lnd repo] et [C-lightning][core lightning
repo].*

- [LND #1970][] : la méthode RPC AbandonChannel (disponible uniquement dans le mode de débogage développeur) fournit désormais des
  informations supplémentaires lorsque les utilisateurs demandent à leur nœud d'abandonner un canal de paiement (une méthode pouvant
  provoquer une perte monétaire si elle est utilisée sans précaution). Les informations supplémentaires sont suffisantes pour permettre soit
  de redémarrer ultérieurement un canal de paiement ouvert soit de prouver que le programme disposait de suffisamment d'informations pour
  prendre des engagements supplémentaires sur un canal de paiement maintenant fermé.

- [C-Lightning #2000][] : cela fournit un grand nombre de correctifs et d'améliorations liées à la sécurité concernant la manière dont les
  contrats à verrouillage par hachage et délai (HTLC) sont stockés dans la base de données.

{% include references.md %}
{% include linkers/issues.md issues="1970,2000" %}

[complex splice]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-October/001434.html
[simpler splice]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-October/001437.html
[script descriptors and descript]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2018-10-08-script-descriptors/
[utreexo]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2018-10-08-utxo-accumulators-and-utreexo/
[optech transcript]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2018-10-09-bitcoin-optech/
[dev vids]: https://www.youtube.com/channel/UCywSzGiWWcUG1gTp45YdPUQ/videos
[dev transcripts]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/edgedevplusplus/
[warren transcript]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/edgedevplusplus/protecting-yourself-and-your-business/
[warren vid]: https://youtu.be/iPt2ekHoEy8
[kanzure wallet transcript]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/edgedevplusplus/wallet-security/
[kanzure wallet vid]: https://youtu.be/WcOIXsOLJ3w?t=3552
[kanzure reorg transcript]: http://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/edgedevplusplus/reorgs/
[kanzure reorg vid]: https://youtu.be/EUUQbveGF5E?t=4
[UHO]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-May/015967.html
[output script descriptors]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
