---
title: 'Bulletin Hebdomadaire Bitcoin Optech #369'
permalink: /fr/newsletters/2025/08/29/
name: 2025-08-29-newsletter-fr
slug: 2025-08-29-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine partage une mise à jour sur le fuzzing différentiel des
implémentations de Bitcoin et LN et propose des liens vers un nouveau papier sur les verrous
chiffrés pour les contrats de calcul responsables.
Sont également incluses nos sections régulières résumant les récentes questions et réponses de Bitcoin
Stack Exchange, annoncant de nouvelles versions et des candidats à la publication, ainsi que les
résumés des modifications notables apportées aux logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

- **Mise à jour sur le fuzzing différentiel des implémentations de Bitcoin et LN :**
  Bruno Garcia a [publié][garcia fuzz] sur Delving Bitcoin pour décrire
  les progrès récents et les accomplissements de [bitcoinfuzz][], une bibliothèque et
  des données associées pour le [fuzz testing][] de logiciels et
  bibliothèques basés sur Bitcoin. Les accomplissements incluent la découverte de "plus de 35 bugs
  dans des projets tels que btcd, rust-bitcoin, rust-miniscript, Embit, Bitcoin
  Core, Core Lightning, [et] LND." La découverte de divergences entre les implémentations LN n'a pas
  seulement révélé des bugs mais a également conduit à des clarifications de la spécification LN. Les
  développeurs de projets Bitcoin sont encouragés à envisager de rendre leur logiciel une cible prise
  en charge par bitcoinfuzz.

- **Verrous chiffrés pour les contrats de calcul responsables :** Liam Eagen
  a [posté][eagen glock] sur la liste de diffusion Bitcoin-Dev à propos d'un
  [papier][eagen paper] qu'il a écrit sur un nouveau mécanisme pour créer
  des [contrats de calcul responsables][topic acc] mais basé sur les [circuits chiffrés][]. Cela
  est similaire (mais distinct) d'autres travaux récents indépendants sur l'utilisation de circuits
  chiffrés pour BitVM (voir le [Bulletin #359][news359 delbrag]). Le post d'Eagen affirme "le premier (à son
  avis) verrou chiffré pratique dont la preuve de fraude est une unique
  signature, ce qui représente une réduction de plus de 550x des données onchain
  comparé à BitVM2." À l'heure actuelle, son post n'a pas reçu de réponses publiques.

## Questions et réponses sélectionnées de Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech
cherchent des réponses à leurs questions---ou quand nous avons quelques moments libres pour aider
les utilisateurs curieux ou confus. Dans cette rubrique mensuelle, nous mettons en lumière certaines
des questions et réponses les mieux votées postées depuis notre dernière mise à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Est-il possible de récupérer une clé privée à partir d'une clé publique agrégée sous de fortes hypothèses ?]({{bse}}127723)
  Pieter Wuille explique les hypothèses de sécurité actuelles et hypothétiques autour
  de [MuSig2][topic musig] des [multisignatures][topic multisignature] sans script.

- [Toutes les adresses taproot sont-elles vulnérables au calcul quantique ?]({{bse}}127660)
  Hugo Nguyen et Murch soulignent que même les sorties [taproot][topic taproot]
  construites pour être dépensées uniquement en utilisant des chemins de script sont vulnérables
  [quantiques][topic quantum resistance]. Murch note ensuite "de façon intéressante, la partie qui
  a déjà ajouté le support pour les transactions de splicing permet aux nœuds du réseau
  Lightning de rajouter ou de retirer des fonds d'un canal Lightning sans avoir à fermer et à rouvrir
  un nouveau canal, rendant ainsi les canaux plus flexibles et moins coûteux à gérer.

- [Pourquoi ne pouvons-nous pas définir la clé d'obfuscation chainstate ?]({{bse}}127814)
  Ava Chow souligne que la clé qui obfusque le contenu sur disque du `blocksdir` (voir le [Bulletin
  #339][news339 blocksxor]) n'est pas la même clé qui obfusque le contenu du `chainstate` (voir
  [Bitcoin Core #6650][]).

- [Est-il possible de révoquer une branche de dépense après une hauteur de bloc ?]({{bse}}127683)
  Antoine Poinsot pointe vers une [réponse précédente]({{bse}}122224) confirmant que les conditions de
  dépense expirantes, ou "inverse timelocks", ne sont pas possibles et peut-être même pas souhaitables.

- [Configurer Bitcoin Core pour utiliser des nœuds onion en plus des nœuds IPv4 et IPv6 ?]({{bse}}127727)
  Pieter Wuille clarifie que la configuration de l'option `onion` s'applique uniquement aux connexions
  de pairs sortantes. Il explique ensuite comment configurer [Tor][topic anonymity networks] et
  `bitcoind` pour les connexions entrantes.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates._

- [Bitcoin Core 29.1rc2][] est un candidat à la sortie pour une version de maintenance du logiciel
  de nœud complet prédominant.

- [Core Lightning v25.09rc4][] est un candidat à la sortie pour une nouvelle version majeure de
  cette implémentation populaire de nœud LN.

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration de Bitcoin (BIPs)][bips
repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Inquisition Bitcoin][bitcoin
inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #31802][] active par défaut la communication inter-processus (IPC) (`ENABLE_IPC`),
  ajoutant les binaires multiprocess `bitcoin-node` et `bitcoin-gui` aux builds de sortie sur tous les
  systèmes sauf Windows. Cela permet à un service de minage externe [Stratum v2][topic pooled mining]
  qui crée, gère et soumet des modèles de blocs d'expérimenter avec la disposition multiprocess sans
  builds personnalisés. Pour plus de contexte sur le projet multiprocess et le binaire `bitcoin-node`,
  voir les Bulletins [#99][news99 ipc], [#147][news147 ipc], [#320][news320 ipc], [#323][news323
  ipc].

- [LDK #3979][] ajoute le support de splice-out, permettant à un nœud LDK d'initier une transaction
  de splice-out, et d'accepter les demandes d'une contrepartie. Ceci complète l'implémentation du
  [splicing][topic splicing] par LDK, comme [LDK #3736][] avait
  déjà ajouté le support de l'ajout de séquence (splice-in). Cette PR ajoute une énumération
  `SpliceContribution` qui couvre les scénarios d'ajout et de retrait de séquence et garantit que les
  valeurs de sortie d'une transaction de retrait de séquence (splice-out) ne dépassent pas le solde du
  canal de l'utilisateur après avoir pris en compte les frais et les exigences de réserve.

- [LND #10102][] ajoute une option `gossip.ban-threshold` (100 est la valeur par défaut, 0 le
  désactive) qui permet aux utilisateurs de configurer le seuil de score à partir duquel un pair est
  banni pour avoir envoyé des messages de [gossip][topic channel announcements] invalides. Le système
  d'exclusion de pairs avait été introduit précédemment et décrit dans le [Bulletin #319][news319 ban].
  Cette PR résout également un problème où des messages d'annonce de nœud et de [canal][topic channel
  announcements] inutiles étaient envoyés en réponse à une demande de requête de gossip en attente.

- [Rust Bitcoin #4907][] introduit le marquage de script en ajoutant un nouveau paramètre générique
  de tag `T` à `Script` et `ScriptBuf`, et définit les alias de type `ScriptPubKey`, `ScriptSig`,
  `RedeemScript`, `WitnessScript`, et `TapScript` qui sont soutenus par un trait `Tag` scellé pour la
  sécurité des rôles à la compilation.

{% include snippets/recap-ad.md when="2025-09-02 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31802,3979,10102,4907,6650,3736" %}
[bitcoin core 29.1rc2]: https://bitcoincore.org/bin/bitcoin-core-29.1/
[core lightning v25.09rc4]: https://github.com/ElementsProject/lightning/releases/tag/v25.09rc4
[garcia fuzz]: https://delvingbitcoin.org/t/the-state-of-bitcoinfuzz/1946
[bitcoinfuzz]: https://github.com/bitcoinfuzz
[fuzz testing]: https://en.wikipedia.org/wiki/Fuzzing
[eagen glock]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Aq_-LHZtVdSN5nODCryicX2u_X1yAQYurf9UDZXDILq6s4grUOYienc4HH2xFnAohA69I_BzgRCSKdW9OSVlSU9d1HYZLrK7MS_7wdNsLmo=@protonmail.com/
[eagen paper]: https://eprint.iacr.org/2025/1485
[circuits chiffrés]: https://en.wikipedia.org/wiki/Garbled_circuit
[news359 delbrag]: /fr/newsletters/2025/06/20/#ameliorations-des-contrats-de-style-bitvm
[news339 blocksxor]: /fr/newsletters/2025/01/31/#comment-fonctionne-l-interrupteur-blocksxor-qui-obscurcit-les-fichiers-blocks-dat
[news99 ipc]: /en/newsletters/2020/05/27/#bitcoin-core-18677
[news147 ipc]: /en/newsletters/2021/05/05/#bitcoin-core-19160
[news320 ipc]: /fr/newsletters/2024/09/13/#bitcoin-core-30509
[news323 ipc]: /fr/newsletters/2024/10/04/#bitcoin-core-30510
[news319 ban]: /fr/newsletters/2024/09/06/#lnd-9009