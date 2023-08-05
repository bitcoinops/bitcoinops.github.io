---
title: 'Bulletin Hebdomadaire Bitcoin Optech #258'
permalink: /fr/newsletters/2023/07/05/
name: 2023-07-05-newsletter-fr
slug: 2023-07-05-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Cette semaine, notre bulletin hebdomadaire comprend une autre contribution de notre série limitée sur la politique
du mempool, ainsi que nos sections habituelles annonçant les nouvelles versions et les versions candidates, et
décrivant les changements apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

_Aucune nouvelle significative n'a été trouvée cette semaine dans les listes de diffusion Bitcoin-Dev et Lightning-Dev._

## En attente de confirmation #8 : La politique comme interface

_Une [série hebdomadaire limitée][policy series] sur le relais des transactions, l'inclusion dans le mempool et la sélection
des transactions minières---y compris pourquoi Bitcoin Core a une politique plus restrictive que celle autorisée par consensus
et comment les portefeuilles peuvent utiliser cette politique de la manière la plus efficace._

{% include specials/policy/en/08-interface.md %} {% assign timestamp="0:30" %}

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les projets d'infrastructure Bitcoin populaires. Veuillez envisager de passer
à de nouvelles versions ou d'aider à tester les versions candidates.*

- [Core Lightning 23.05.2][] est une version de maintenance de ce logiciel de nœud LN qui contient plusieurs corrections de
bugs qui peuvent affecter les utilisateurs en production. {% assign timestamp="10:27" %}

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo],
[Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Interface de portefeuille matériel
(HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo], [Propositions
d'amélioration de Bitcoin (BIP)][bips repo], [Lightning BOLTs][bolts repo], et [Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #24914][] charge les enregistrements de la base de données du portefeuille par type au lieu de parcourir toute
la base de données deux fois pour détecter les dépendances. Certains portefeuilles avec des enregistrements corrompus peuvent ne
plus se charger après cette modification, mais ils peuvent être chargés avec une version précédente de Bitcoin Core et transférés
vers un nouveau portefeuille. {% assign timestamp="22:03" %}

- [Bitcoin Core #27896][] supprime la fonctionnalité expérimentale de sandbox d'appel système (syscall) (voir
[Bulletin #170][news170 syscall]). Un [problème connexe][Bitcoin Core #24771] et les commentaires qui ont suivi soulignent les
inconvénients de cette fonctionnalité, notamment la maintenabilité (à la fois de la liste blanche des appels système et de la prise
en charge du système d'exploitation), les alternatives mieux prises en charge et les considérations sur le fait de savoir si le
sandboxing des appels système devrait être la responsabilité de Bitcoin Core. {% assign timestamp="24:47" %}

- [Core Lightning #6334][] met à jour et étend le support expérimental de CLN pour les [sorties d'ancrage][topic anchor outputs]
(voir [Bulletin #111][news111 cln anchor] pour la mise en œuvre initiale de CLN). Certaines des mises à jour de cette PR incluent
le support expérimental des ancres [HTLC][topic htlc] sans frais et l'ajout de vérifications configurables pour s'assurer que le
nœud dispose au moins du montant minimum de fonds d'urgence dont il a besoin pour exploiter un canal d'ancrage. {% assign timestamp="27:51" %}

- [BIPs #1452][] met à jour la spécification [BIP329][] pour un format d'exportation d'étiquettes de
[portefeuille][topic wallet labels] avec une nouvelle balise facultative `spendable` qui indique si la sortie associée doit être
dépensable par le portefeuille. De nombreux portefeuilles mettent en œuvre des fonctionnalités de _contrôle des pièces_ qui
permettent à un utilisateur de dire à l'algorithme de [sélection des pièces][topic coin selection] de ne pas dépenser certaines
sorties, telles que les sorties qui pourraient réduire la confidentialité de l'utilisateur. {% assign timestamp="31:08" %}

- [BIPs #1354][] ajoute [BIP389][] pour les [descripteurs][topic descriptors] de chemin de dérivation multiples décrits dans
[Bulletin #211][news211 desc]. Il permet à un seul descripteur de spécifier deux chemins BIP32 liés pour la génération de clés
HD---le premier chemin pour les paiements entrants et le deuxième chemin pour les paiements internes du portefeuille (comme le
changement). {% assign timestamp="33:55" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="24914,27896,6334,1452,1354,24771" %}
[policy series]: /fr/blog/waiting-for-confirmation/
[news111 cln anchor]: /en/newsletters/2020/08/19/#c-lightning-3830
[news211 desc]: /en/newsletters/2022/08/03/#multiple-derivation-path-descriptors
[core lightning 23.05.2]: https://github.com/ElementsProject/lightning/releases/tag/v23.05.2
[news170 syscall]: /en/newsletters/2021/10/13/#bitcoin-core-20487