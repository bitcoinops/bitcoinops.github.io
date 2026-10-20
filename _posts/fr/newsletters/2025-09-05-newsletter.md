---
title: 'Bulletin Hebdomadaire Bitcoin Optech #370'
permalink: /fr/newsletters/2025/09/05/
name: 2025-09-05-newsletter-fr
slug: 2025-09-05-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine inclut nos sections régulières résumant les récentes discussions sur
la modification des règles de consensus de Bitcoin, annonçant des mises à jour et des versions candidates,
et décrivant les changements notables dans les projets d'infrastructure Bitcoin populaires.

## Nouvelles

_Aucune nouvelle significative n'a été trouvée cette semaine dans aucune de nos [sources][optech
sources]._

## Modification du consensus

_Une nouvelle section mensuelle résumant les propositions et discussions sur la modification des
règles de consensus de Bitcoin._

- **Détails sur la conception de Simplicity :** Russell O'Connor a fait trois publications
  ([1][sim1], [2][sim2], [3][sim3]) jusqu'à présent sur Delving Bitcoin à propos de "la philosophie et
  la conception du langage [Simplicity][topic simplicity]." Les posts examinent "les trois formes
  principales de composition pour transformer des opérations basiques en opérations complexes," "le
  système de types de Simplicity, les combinateurs, et les expressions basiques," et "comment
  construire des opérations logiques à partir de bits [...jusqu'à...] des opérations cryptographiques,
  telles que SHA-256 et la validation de signature Schnorr, en utilisant juste nos combinateurs
  computationnels de Simplicity."

  Le post le plus récent indique que d'autres entrées dans la série sont attendues.

- **Brouillon de BIP pour ajouter des opérations sur courbes elliptiques à tapscript :** Olaoluwa
  Osuntokun a [publié][osuntokun ec] sur la liste de diffusion Bitcoin-Dev un lien vers un [brouillon
  de BIP][osuntokun bip] pour ajouter plusieurs opcodes à [tapscript][topic tapscript] qui permettront
  d'effectuer des opérations sur courbes elliptiques sur la pile d'évaluation du script. Les opcodes
  sont destinés à être utilisés en combinaison avec des opcodes d'introspection pour créer ou
  améliorer les protocoles de [covenant][topic covenants] en plus d'autres avancées.

  Jeremy Rubin a [répondu][rubin ec1] pour suggérer des opcodes supplémentaires pour activer des
  fonctionnalités supplémentaires, ainsi que [d'autres opcodes][rubin ec2] qui rendraient plus
  pratique l'utilisation de certaines fonctionnalités fournies par la proposition de base.

- **Brouillon de BIP pour OP_TWEAKADD :** Jeremy Rubin a [publié][rubin ta1] sur la liste de
  diffusion Bitcoin-Dev un lien vers un [brouillon de BIP][rubin bip] pour ajouter `OP_TWEAKADD` à
  [tapscript][topic tapscript]. Il a séparément [publié][rubin ta2] des exemples notables de scripts
  rendus possibles par l'ajout de l'opcode, qui incluent un script pour révéler une modification de
  [taproot][topic taproot], une preuve de l'ordre de signature d'une transaction (par exemple, Alice
  doit avoir signé avant Bob), et la [délégation de signature][topic signer delegation].

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates._

- [Core Lightning v25.09][] est une version d'une nouvelle version majeure de cette implémentation
  populaire de nœud LN. Elle ajoute le support à la commande `xpay` pour payer les adresses [BIP353][]
  et les [offres][topic offers] simples, offre un meilleur support de comptabilité, fournit une
  meilleure gestion des dépendances des plugins, et inclut d'autres nouvelles fonctionnalités.
  et corrections de bugs.

- [Bitcoin Core 29.1rc2][] est un candidat à la version pour une version de maintenance du logiciel
  de nœud complet prédominant.

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [Serveur
BTCPay][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration de Bitcoin (BIPs)][bips
repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Inquisition Bitcoin][bitcoin
inquisition repo], et [BINANAs][binana repo]._

- [LDK #3726][] ajoute le support pour les sauts fictifs sur les [chemins aveuglés][topic rv
  routing], permettant aux récepteurs d'ajouter des sauts arbitraires qui ne servent aucun but de
  routage mais agissent comme leurres. Un nombre aléatoire de sauts fictifs est ajouté à chaque fois,
  mais est limité à 10 comme défini par `MAX_DUMMY_HOPS_COUNT`. L'ajout de sauts supplémentaires rend
  significativement plus difficile la détermination de la distance ou de l'identité du nœud récepteur.

- [LDK #4019][] intègre le [splicing][topic splicing] avec le [protocole de quiescence][topic
  channel commitment upgrades] en exigeant un état de canal quiescent avant d'initialiser une
  transaction de splicing, comme le mandate la spécification.

- [LND #9455][] ajoute le support pour associer un nom de domaine DNS valide à l'adresse IP et à la
  clé publique d'un nœud Lightning dans son message d'annonce, comme le permet la spécification et
  supporté par d'autres implémentations telles qu'Eclair et Core Lightning (voir les Bulletins
  [#212][news212 dns], [#214][news214 dns], et [#178][news178 dns]).

- [LND #10103][] introduit une nouvelle option `gossip.peer-msg-rate-bytes` (par défaut 51200), qui
  limite la bande passante sortante utilisée par chaque pair pour les [messages de gossip][topic
  channel announcements] sortants. Cette valeur limite la vitesse moyenne de la bande passante en
  octets par seconde, et si un pair la dépasse, LND commencera à mettre en file d'attente et à
  retarder les messages envoyés à ce pair. Cette nouvelle option empêche un seul pair de consommer
  toute la bande passante globale définie par `gossip.msg-rate-bytes` introduite dans [LND #10096][].
  Voir les Bulletins [#366][news366 gossip] et [#369][news369 gossip] pour les travaux liés de LND
  sur la gestion des ressources des demandes de gossip.

- [HWI #795][] ajoute le support pour le BitBox02 Nova en mettant à jour la bibliothèque `bitbox02`
  à la version 7.0.0. Il effectue également plusieurs mises à jour de CI.

{% include snippets/recap-ad.md when="2025-09-09 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3726,4019,9455,10103,795,10096" %}
[bitcoin core 29.1rc2]: https://bitcoincore.org/bin/bitcoin-core-29.1/
[core lightning v25.09]: https://github.com/ElementsProject/lightning/releases/tag/v25.09
[sim1]: https://delvingbitcoin.org/t/delving-simplicity-part-three-fundamental-ways-of-combining-computations/1902
[sim2]: https://delvingbitcoin.org/t/delving-simplicity-part-combinator-completeness-of-simplicity/1935
[sim3]: https://delvingbitcoin.org/t/delving-simplicity-part-building-data-types/1956
[osuntokun ec]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAO3Pvs-Cwj=5vJgBfDqZGtvmoYPMrpKYFAYHRb_EqJ5i0PG0cA@mail.gmail.com/
[osuntokun bip]: https://github.com/bitcoin/bips/pull/1945
[rubin ec1]: https://mailing-list.bitcoindevs.xyz/bitcoindev/f118d974-8fd5-42b8-9105-57e215d8a14an@googlegroups.com/
[rubin ec2]: https://mailing-list.bitcoindevs.xyz/bitcoindev/1c2539ba-d937-4a0f-b50a-5b16809322a8n@googlegroups.com/
[rubin ta1]: https://mailing-list.bitcoindevs.xyz/bitcoindev/bc9ff794-b11e-47bc-8840-55b2bae22cf0n@googlegroups.com/
[rubin ta2]: https://mailing-list.bitcoindevs.xyz/bitcoindev/c51c489c-9417-4a60-b642-f819ccb07b15n@googlegroups.com/
[rubin bip]: https://github.com/bitcoin/bips/pull/1944
[news212 dns]: /en/newsletters/2022/08/10/#bolts-911
[news214 dns]: /en/newsletters/2022/08/24/#eclair-2234
[news178 dns]: /en/newsletters/2021/12/08/#c-lightning-4829
[news366 gossip]: /fr/newsletters/2025/08/08/#lnd-10097
[news369 gossip]: /fr/newsletters/2025/08/29/#lnd-10102
