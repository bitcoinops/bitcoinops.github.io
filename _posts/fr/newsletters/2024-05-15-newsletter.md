---
title: 'Bulletin Hebdomadaire Bitcoin Optech #302'
permalink: /fr/newsletters/2024/05/15/
name: 2024-05-15-newsletter-fr
slug: 2024-05-15-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine annonce la sortie en bêta d'un nœud complet supportant utreexo et
résume deux extensions proposées au BIP119 `OP_CHECKTEMPLATEVERIFY`. Elle inclut également nos
sections habituelles annonçant les nouvelles versions et les versions candidates, ainsi que la
description des modifications notables apportées aux logiciels d'infrastructure Bitcoin populaires.

## Actualités

- **Sortie de la bêta de utreexod :** Calvin Kim a [publié][kim utreexo] sur la liste de diffusion
  Bitcoin-Dev pour annoncer la sortie en bêta de utreexod, un nœud complet avec support pour
  [utreexo][topic utreexo]. Utreexo permet à un nœud de stocker un petit engagement sur l'état de
  l'ensemble UTXO plutôt que l'ensemble complet lui-même ; par exemple, un engagement minimal peut
  être de 32 octets et l'ensemble complet actuel est d'environ 12 Go, rendant l'engagement environ un
  milliard de fois plus petit. Pour réduire la bande passante, utreexo peut stocker des engagements
  supplémentaires, augmentant son utilisation de l'espace disque, mais en gardant toujours son état de
  chaîne environ un million de fois plus petit qu'un nœud complet traditionnel. Un nœud utreexo qui
  élaguerait également les anciens blocs pourrait fonctionner avec une petite quantité constante
  d'espace disque, tandis que même les nœuds complets élagués peuvent voir leur état de chaîne
  dépasser la capacité de stockage d'un appareil.

  Les notes de version publiées par Kim indiquent que le nœud est compatible avec les portefeuilles
  basés sur [BDK][bdk repo], ainsi que de nombreux autres portefeuilles grâce à la prise en charge d'
  [Electrum personal server][]. Le nœud prend en charge le relais de transactions avec des extensions
  au protocole réseau P2P permettant la transmission des preuves utreexo. Les nœuds utreexo
  _réguliers_ et _ponts_ sont pris en charge ; les nœuds utreexo réguliers utilisent l'engagement
  utreexo pour économiser de l'espace disque ; les nœuds ponts stockent l'état UTXO complet plus des
  données supplémentaires et peuvent attacher des preuves utreexo aux blocs et transactions créés par
  des nœuds et portefeuilles qui ne supportent pas encore utreexo.

  Utreexo ne nécessite pas de changements de consensus et les nœuds utreexo n'interfèrent pas avec les
  nœuds non-utreexo, bien que les nœuds utreexo réguliers ne puissent se connecter qu'avec d'autres
  nœuds utreexo réguliers et ponts.

  Kim inclut plusieurs avertissements dans son annonce : "le code et le protocole ne sont pas revus
  par des pairs [...] il y aura des changements majeurs [...] utreexod est basé sur [btcd][] [qui peut
  avoir] des incompatibilités de consensus".

- **Extensions BIP119 pour des hachages plus petits et des engagements de données arbitraires :**
  Jeremy Rubin a [publié][rubin bip119e] sur la liste de diffusion Bitcoin-Dev une [proposition de
  BIP][bip119e] pour étendre le [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] proposé
  (`OP_CTV`) avec deux fonctionnalités supplémentaires :

  - *Support pour les hachages HASH160 :* ce sont les digests de hachage utilisés pour les adresses
    P2PKH, P2SH et P2WPKH. Ils font 20 octets comparés aux digests de hachage de 32 octets utilisés
    dans la proposition de base [BIP119][]. En
    protocoles multipartites naïfs, une [attaque par collision][] contre un hash de 20 octets peut être
    réalisée en environ 2<sup>80</sup> opérations de force brute, ce qui est à la portée d'un attaquant
    très motivé. Pour cette raison, les opcodes modernes de Bitcoin utilisent généralement des digests
    de hash de 32 octets. Cependant, la sécurité dans les protocoles unipartites ou les protocoles
    multipartites bien conçus utilisant des hashes de 20 octets peut être augmentée pour rendre le
    compromis peu probable en moins d'environ 2<sup>160</sup> opérations de force brute, permettant à
    ces protocoles d'économiser environ 12 octets par digest. Un cas où cela pourrait être utile est
    dans les implémentations du protocole [eltoo][topic eltoo] (voir le [Bulletin #284][news284 eltoo]).

  - *Support pour des engagements supplémentaires :* `OP_CTV` ne réussit que s'il est exécuté dans une
    transaction qui contient des entrées et des sorties qui hashent à la même valeur qu'un digest de
    hash fourni. L'une de ces sorties pourrait être une sortie `OP_RETURN` qui s'engage sur certaines
    données que le créateur du script souhaite publier sur la blockchain, telles que les données
    nécessaires pour récupérer l'état du canal LN à partir d'une sauvegarde. Cependant, placer des
    données dans le champ témoin serait nettement moins coûteux. La mise à jour de
    `OP_CTV` proposée permet au créateur du script d'exiger qu'un élément supplémentaire de données de la pile
    témoin soit inclus lorsque les entrées et les sorties sont hashées. Ces données seront vérifiées
    contre le digest de hash fourni par le créateur du script. Cela garantit que les données sont
    publiées sur la blockchain avec une utilisation minimale du poids du bloc.

  La proposition n'a reçu aucune discussion sur la liste de diffusion à ce jour.

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets d’infrastructure
Bitcoin. Veuillez envisager de passer aux nouvelles versions ou d’aider à tester
les versions candidates.*

- [LDK v0.0.123][] est une sortie de cette bibliothèque populaire pour la construction
  d'applications compatibles LN. Elle comprend une mise à jour de ses paramètres pour les [HTLCs
   coupés][topic trimmed htlc], des améliorations du support des [offres][topic offers], et de
   nombreuses autres améliorations.

- [LND v0.18.0-beta.rc2][] est un candidat à la sortie pour la prochaine version majeure de ce nœud
  LN populaire.

## Changements notables dans le code et la documentation

_Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration de Bitcoin (BIPs)][bips
repo], [Lightning BOLTs][bolts repo], [Inquisition Bitcoin][bitcoin inquisition repo], et
[BINANAs][binana repo]._

- [Bitcoin Core #29845][] met à jour plusieurs RPCs `get*info` pour changer le champ `warnings`
  d'une chaîne de caractères à un tableau de chaînes afin que plusieurs avertissements puissent être
  retournés au lieu d'un seul.

- [Core Lightning #7111][] rend la commande RPC `check` disponible pour les plugins via l'utilitaire
  libplugin. L'utilisation est également étendue par
  l'activation de `check setconfig` qui valide que les options de configuration seraient acceptées, et
  le `check keysend` existant valide maintenant si hsmd approuverait la transaction. Un message de
  pré-initialisation a été ajouté avec des drapeaux de développement HSM prédéfinis. Pour plus de
  références sur la commande `check`, voir également les Bulletins [#25][news25 cln check] et
  [#47][news47 cln check].

- [Libsecp256k1 #1518][] ajoute une fonction `secp256k1_pubkey_sort` qui trie un ensemble de clés
  publiques dans un ordre canonique. Cela est utile pour [MuSig2][topic musig] et [silent
  payments][topic silent payments], et probablement de nombreux autres protocoles impliquant plusieurs
  clés.

- [Rust Bitcoin #2707][] met à jour l'API pour les hachages étiquetés introduits dans le cadre de
  [taproot][topic taproot] pour s'attendre par défaut aux digests en _ordre de bytes interne_.
  Auparavant, l'API s'attendait à ce que les hachages soient en _ordre de bytes affiché_, qui peut
  maintenant être obtenu avec du code comme `#[hash_newtype(backward)]`. Pour des [raisons
  historiques][mb3e byte order], les txid et les identifiants de bloc apparaissent dans les
  transactions et les blocs dans un ordre de bytes (ordre de bytes interne) mais sont affichés et
  appelés dans les interfaces utilisateur dans l'ordre inverse (ordre de bytes affiché). Cette PR
  essaie de prévenir encore plus de hachages ayant des ordres de bytes différents pour différentes
  circonstances.

- [BIPs #1389][] ajoute [BIP388][] qui décrit "les politiques de portefeuille pour les portefeuilles
  descripteurs", un ensemble de [descripteurs de script de sortie][topic descriptors] modélisés qui
  peuvent être plus faciles à supporter pour un large ensemble de portefeuilles tant dans le code que
  dans leur interface utilisateur. En particulier, les descripteurs peuvent être difficiles à
  implémenter sur des portefeuilles matériels avec des ressources limitées et un espace d'écran
  limité. Les politiques de portefeuille BIP388 permettent aux logiciels et matériels qui y adhèrent
  de faire des hypothèses simplificatrices sur la manière dont les descripteurs seront utilisés ; cela
  minimise la portée des descripteurs, réduisant la quantité de code nécessaire et le nombre de
  détails qui doivent être vérifiés par les utilisateurs. Tout logiciel nécessitant la pleine
  puissance des descripteurs peut toujours les utiliser indépendamment de BIP388. Pour des
  informations supplémentaires, voir le [Bulletin #200][news200 policies].

- [BIPs #1567][] ajoute [BIP387][] avec de nouveaux descripteurs `multi_a()` et `sortedmultia_a()`
  qui fournissent des capacités multisig scriptées dans [tapscript][topic tapscript]. Prenant un
  exemple du BIP, le fragment de descripteur `multi_a(k,KEY_1,KEY_2,...,KEY_n)` produira un script tel
  que `KEY_1 OP_CHECKSIG KEY_2 OP_CHECKSIGADD ... KEY_n OP_CHECKSIGADD OP_k OP_NUMEQUAL`. Voir
  également les Bulletins [#191][news191 multi_a], [#227][news227 multi_a], et [#273][news273 multi_a].

- [BIPs #1525][] ajoute [BIP347][] qui propose un opcode [OP_CAT][topic op_cat] qui pourrait être
  utilisé dans [tapscript][topic tapscript] s'il était [activé][topic soft fork activation] lors d'un
  soft fork. Voir aussi les Bulletins [#274][news274 op_cat], [#275][news275 op_cat] et [#293][news293 op_cat].

## Changements de dates de publication des bulletins

Dans les semaines à venir, Optech expérimentera des dates de publication alternatives. Ne soyez pas
surpris si vous recevez le bulletin quelques jours plus tôt ou plus tard. Pendant la courte
période d'expérimentation, nos bulletins envoyées par email incluront un tracker pour nous aider à
déterminer combien de personnes lisent le bulletin. Vous pouvez empêcher le suivi en désactivant
le chargement des ressources externes avant de lire le bulletin. Si vous désirez encore plus de
confidentialité, nous vous recommandons de vous abonner à notre [flux RSS][] via une connexion Tor
éphémère. Nous nous excusons pour tout désagrément.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1525,1567,1389,2707,1518,7111,29845" %}
[lnd v0.18.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.0-beta.rc2
[mb3e byte order]: https://github.com/bitcoinbook/bitcoinbook/blob/6d1c26e1640ae32b28389d5ae4caf1214c2be7db/ch06_transactions.adoc#internal_and_display_order
[news200 policies]: /en/newsletters/2022/05/18/#adapting-miniscript-and-output-script-descriptors-for-hardware-signing-devices
[news191 multi_a]: /en/newsletters/2022/03/16/#bitcoin-core-24043
[news227 multi_a]: /fr/newsletters/2022/11/23/#comment-puis-je-creer-une-adresse-taproot-multisig
[news273 multi_a]: /fr/newsletters/2023/10/18/#bitcoin-core-27255
[news274 op_cat]: /fr/newsletters/2023/10/25/#proposition-de-bip-pour-op-cat
[news275 op_cat]: /fr/newsletters/2023/11/01/#proposition-op-cat
[news293 op_cat]: /fr/newsletters/2024/03/13/#bitcoin-core-pr-review-club
[kim utreexo]: https://mailing-list.bitcoindevs.xyz/bitcoindev/d5f47120-3397-4f56-93ca-dd310d845f3cn@googlegroups.com/T/#u
[electrum personal server]: https://github.com/chris-belcher/electrum-personal-server
[btcd]: https://github.com/btcsuite/btcd
[rubin bip119e]: https://mailing-list.bitcoindevs.xyz/bitcoindev/35cba1cd-eb67-48d1-9615-e36f2e78d051n@googlegroups.com/T/#u
[bip119e]: https://github.com/bitcoin/bips/pull/1587
[news284 eltoo]: /fr/newsletters/2024/01/10/#ctv
[attaque par collision]: https://en.wikipedia.org/wiki/Collision_attack
[flux rss]: /feed.xml
[ldk v0.0.123]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.123
[news25 cln check]: /en/newsletters/2018/12/11/#c-lightning-2123
[news47 cln check]: /en/newsletters/2019/05/21/#c-lightning-2631
