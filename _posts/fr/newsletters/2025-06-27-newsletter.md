---
title: 'Bulletin Hebdomadaire Bitcoin Optech #360'
permalink: /fr/newsletters/2025/06/27/
name: 2025-06-27-newsletter-fr
slug: 2025-06-27-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
La newsletter de cette semaine résume une recherche sur l'identification des nœuds complets en
utilisant les messages du protocole P2P et sollicite des retours sur la possibilité de supprimer le
support de `H` dans les chemins BIP32 dans la spécification BIP380 des descripteurs.
Sont également incluses nos sections régulières résumant les récentes questions et réponses de Bitcoin
Stack Exchange, annoncant de nouvelles versions et des candidats à la publication, ainsi que les résumés
des modifications notables apportées aux logiciels d'infrastructure Bitcoin populaires.

## Actualités

- **Identification des nœuds utilisant les messages `addr` :** Daniela Brozzoni a [publié][brozzoni
  addr] sur Delving Bitcoin à propos d'une recherche qu'elle a menée avec le développeur Naiyoma pour
  identifier le même nœud sur plusieurs réseaux en utilisant les messages `addr` qu'il envoie. Les
  nœuds envoient des messages `addr` (adresse) du protocole P2P à leurs pairs pour faire la publicité
  d'autres nœuds potentiels, permettant aux pairs de se trouver les uns les autres en utilisant un
  système de diffusion décentralisé. Cependant, Brozzoni et Naiyoma ont réussi à identifier des nœuds
  individuels en utilisant des détails de leurs messages d'adresse spécifiques, leur permettant
  d'identifier le même nœud fonctionnant sur plusieurs réseaux (tels que IPv4 et [Tor][topic anonymity
  networks]).

  Les chercheurs suggèrent deux atténuations possibles : supprimer les horodatages des messages
  d'adresse ou, si les horodatages sont conservés, les randomiser légèrement pour les rendre moins
  spécifiques à des nœuds particuliers.

- **Un logiciel utilise-t-il `H` dans les descripteurs ?** Ava Chow a [posté][chow hard] sur la
  liste de diffusion Bitcoin-Dev pour demander si un logiciel génère des descripteurs en utilisant le
  H majuscule pour indiquer une étape de dérivation de clé [BIP32][topic bip32] renforcée. Si ce n'est
  pas le cas, la spécification [BIP380][] des [descripteurs de script de sortie][topic descriptors]
  pourrait être modifiée pour n'autoriser que le h minuscule et `'` pour indiquer le renforcement.
  Chow note que, bien que BIP32 autorise le H majuscule, la spécification BIP380 incluait précédemment
  un test interdisant l'utilisation du H majuscule et que Bitcoin Core n'accepte actuellement pas le H
  majuscule.

## Questions et réponses sélectionnées du Bitcoin Stack Exchange

*[Le Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs
d'Optech cherchent des réponses à leurs questions---ou quand nous avons quelques moments libres pour
aider les utilisateurs curieux ou confus. Dans cette rubrique mensuelle, nous mettons en lumière
certaines des questions et réponses les mieux votées publiées depuis notre dernière mise à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Existe-t-il un moyen de bloquer les nœuds Bitcoin Knots en tant que mes pairs ?]({{bse}}127456)
  Vojtěch Strnad fournit une approche pour bloquer les pairs basée sur les chaînes d'agent utilisateur
  en utilisant deux RPCs de Bitcoin Core mais décourage une telle approche et pointe vers un [problème
  GitHub de Bitcoin Core][Bitcoin Core #30036] avec un découragement similaire.

- [Que fait OP_CAT avec les entiers ?]({{bse}}127436)
  Pieter Wuille explique que les éléments de pile de Bitcoin Script ne contiennent pas d'informations
  sur le type de données et que différents opcodes interprètent les octets des éléments de pile de
  différentes manières.

- [Relais de blocs asynchrone avec Compact Block Relay (BIP152)]({{bse}}127420)
  L'utilisateur bca-0353f40e décrit le traitement des [blocs compacts][topic compact blocks] par
  Bitcoin Core et estime l'impact des transactions manquantes sur la propagation des blocs.

- [Pourquoi les revenus d'un attaquant dans le minage égoïste sont-ils disproportionnés par rapport à sa puissance de hachage ?]({{bse}}53030)
  Antoine Poinsot poursuit sur ce sujet et [une autre]({{bse}}125682) question plus ancienne sur le
  [minage égoïste][topic selfish mining], en soulignant, "L'ajustement de la difficulté ne prend pas
  en compte les blocs obsolètes, ce qui signifie que diminuer le taux de hachage effectif des mineurs
  concurrents augmente les profits d'un mineur (sur une échelle de temps suffisamment longue) autant
  qu'augmenter le sien" (voir le [Bulletin #358][news358 selfish mining]).

## Mises à jour et versions candidates

_Nouvelles mises-à-jours et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles mises-à-jour ou d'aider à tester les versions candidates._

- [Bitcoin Core 28.2][] est une version de maintenance pour la série de versions précédente de
  l'implémentation de nœud complet prédominante. Elle contient de multiples corrections de bugs.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration de Bitcoin (BIPs)][bips
repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Inquisition Bitcoin][bitcoin
inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #31981][] ajoute une méthode `checkBlock` à l'interface de communication
  inter-processus (IPC) `Mining` (voir le Bulletin [#310][news310 ipc]) qui effectue les mêmes
  vérifications de validité que la RPC `getblocktemplate` en mode `proposal`. Cela permet aux pools de
  minage utilisant [Stratum v2][topic pooled mining] de valider les modèles de blocs fournis par les
  mineurs via l'interface IPC plus rapide, plutôt que de sérialiser jusqu'à 4 Mo de JSON via RPC. Les
  vérifications de la preuve de travail et de la racine de Merkle peuvent être désactivées dans les
  options.

- [Eclair #3109][] étend son support des [échecs attribuables][topic attributable failures] (voir
  le Bulletin [#356][news356 failures]) aux [paiements trampoline][topic trampoline payments]. Un nœud
  trampoline maintenant déchiffre et stocke la partie de la charge utile d'attribution qui lui est
  destinée et prépare le reste du blob pour le prochain saut trampoline. Cette PR n'implémente pas la
  transmission des données d'attribution pour les nœuds trampoline, ce qui est prévu dans une PR
  ultérieure.

- [LND #9950][] ajoute un nouveau drapeau `include_auth_proof` aux RPC `DescribeGraph`,
  `GetNodeInfo` et `GetChanInfo` et à leurs commandes `lncli` correspondantes. Inclure ce drapeau
  retourne les signatures d'[annonce de canal][topic channel announcements], permettant la validation
  des détails du canal par des logiciels tiers.

- [LDK #3868][] réduit la précision du temps de maintien [HTLC][topic htlc] pour les charges utiles
  d'[échec attribuable][topic attributable failures] (voir le Bulletin [#349][news349 attributable]).
  de 1 milliseconde à 100 millisecondes, pour atténuer les fuites d'empreintes temporelles. Cela
  aligne LDK avec les dernières mises à jour du brouillon du [BOLTs #1044][].

- [LDK #3873][] augmente le délai pour oublier un Identifiant de Canal Court (SCID) après que son
  financement soit dépensé de 12 à 144 blocs pour permettre la propagation d'une mise à jour de
  [splice][topic splicing]. Cela représente le double du délai de 72 blocs introduit dans [BOLTs
  #1270][] qui a été mis en œuvre par Eclair (voir le Bulletin [#359][news359 eclair]). Cette PR
  implémente également des changements supplémentaires dans le processus d'échange de messages
  `splice_locked`.

- [Libsecp256k1 #1678][] ajoute une bibliothèque d'interface CMake `secp256k1_objs` qui expose tous
  les fichiers objet de la bibliothèque pour permettre aux projets parents, tels que le [projet
  libbitcoinkernel][libbitcoinkernel project] prévu par Bitcoin Core, de lier ces objets directement
  dans leurs propres bibliothèques statiques. Cela résout le problème de l'absence d'un mécanisme
  natif dans CMake pour lier des bibliothèques statiques entre elles et épargne aux utilisateurs en
  aval de fournir leur propre binaire `libsecp256k1`.

- [BIPs #1803][] clarifie la grammaire des [descripteurs][topic descriptors] de [BIP380][] en
  autorisant tous les marqueurs de chemin sécurisé communs, tandis que [#1871][bips #1871],
  [#1867][bips #1867], et [#1866][bips #1866] affinent les descripteurs [MuSig2][topic musig] de
  [BIP390][] en resserrant les règles des chemins de clés, en permettant des clés de participants
  répétées, et en restreignant explicitement les dérivations d'enfants multipath.

{% include snippets/recap-ad.md when="2025-07-01 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31981,3109,9950,3868,3873,1678,1803,1871,1867,1866,30036,1044,1270" %}
[bitcoin core 28.2]: https://bitcoincore.org/bin/bitcoin-core-28.2/
[brozzoni addr]: https://delvingbitcoin.org/t/fingerprinting-nodes-via-addr-requests/1786/
[chow hard]: https://mailing-list.bitcoindevs.xyz/bitcoindev/848d3d4b-94a5-4e7c-b178-62cf5015b65f@achow101.com/T/#u
[news358 selfish mining]: /fr/newsletters/2025/06/13/#calcul-du-seuil-de-danger-du-minage-egoiste
[news310 ipc]: /fr/newsletters/2024/07/05/#bitcoin-core-30200
[news356 failures]: /fr/newsletters/2025/05/30/#eclair-3065
[news349 attributable]: /fr/newsletters/2025/04/11/#ldk-2256
[news359 eclair]: /fr/newsletters/2025/06/20/#eclair-3110
[libbitcoinkernel project]: https://github.com/bitcoin/bitcoin/issues/27587