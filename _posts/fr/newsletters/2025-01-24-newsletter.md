---
title: 'Bulletin Hebdomadaire Bitcoin Optech #338'
permalink: /fr/newsletters/2025/01/24/
name: 2025-01-24-newsletter-fr
slug: 2025-01-24-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine annonce une ébauche de BIP pour référencer des clés non dépensables
dans les descripteurs, examine comment les implémentations utilisent PSBTv2, et corrige en détail
notre description de la semaine dernière d'un nouveau protocole DLC offchain.
Il contient également nos sections régulières avec des descriptions des
changements apportés aux clients et services populaires, des annonces de nouvelles versions et de
candidats à la version, et des résumés des changements notables apportés aux logiciels
d'infrastructure Bitcoin populaires.

## Nouvelles

- **Ébauche de BIP pour les clés non dépensables dans les descripteurs :** Andrew Toth a posté sur
  [Delving Bitcoin][toth unspendable delv] et la [liste de diffusion Bitcoin-Dev][toth unspendable ml]
  une [ébauche de BIP][bips #1746] pour référencer des clés vérifiablement non dépensables dans les
  [descripteurs][topic descriptors]. Cela fait suite à une discussion précédente (voir le [Bulletin
  #283][news283 unspendable]). Utiliser une clé vérifiablement non dépensable, également appelée point
  _nothing up my sleeve_ (NUMS), est particulièrement pertinent pour la clé interne [taproot][topic
  taproot]. S'il n'est pas possible de créer une dépense par keypath à l'aide de la clé interne,
  seule une dépense par scriptpath à l'aide d'une tapleaf est possible. (par
  exemple, en utilisant un [tapscript][topic tapscript]).

  Au moment de la rédaction, une discussion active a lieu sur le [PR][bips #1746] du BIP en avant projet.

- **Tests d'intégration PSBTv2 :** Sjors Provoost a [posté][provoost psbtv2] sur la liste de
  diffusion Bitcoin-Dev pour demander des logiciels ayant implémenté le support pour la version 2 des
  [PSBTs][topic psbt] (voir le [Bulletin #141][news141 psbtv2]) afin d'aider à tester un [PR][bitcoin
  core #21283] ajoutant son support à Bitcoin Core. Une liste mise à jour des logiciels l'utilisant
  peut être [trouvée][bse psbtv2] sur Bitcoin Stack Exchange. Nous avons trouvé deux réponses
  intéressantes :

- **PSBTv2 Merklisé :** Salvatore Ingala [explique][ingala psbtv2] que l'application Bitcoin Ledger
  convertit les champs d'un PSBTv2 en un arbre de Merkle et envoie initialement uniquement la racine à
  un dispositif de signature matériel Ledger. Lorsque des champs spécifiques sont nécessaires, ils
  sont envoyés avec la preuve de Merkle appropriée. Cela permet au dispositif de travailler en toute
  sécurité avec chaque morceau d'information indépendamment sans avoir à stocker l'ensemble du PSBT
  dans sa mémoire limitée. Cela est possible avec PSBTv2 car il a déjà les parties de la transaction
  non signée séparées en champs distincts ; pour le format PSBT original (v0), cela nécessitait un
  traitement supplémentaire.

- **Paiements silencieux PSBTv2 :** Le [BIP352][] spécifiant les [paiements silencieux][topic silent
  payments] dépend explicitement de la spécification [BIP370][] de PSBTv2.  Andrew Toth [explique][toth
  psbtv2] que les paiements silencieux ont besoin du champ `PSBT_OUT_SCRIPT` de v2 car le script de
  sortie à utiliser ne peut pas être connu pour les paiements silencieux tant que tous les signataires
  n'ont pas traité la PSBT.

- **Correction à propos des DLC offchain :** dans notre description des DLC offchain dans [le
  bulletin de la semaine dernière][news337 dlc], nous avons confondu le [nouveau schéma][conduition
  factories] proposé par le développeur conduition avec les schémas de [DLC][topic dlc] offchain
  précédemment publiés et implémentés. Il y a une différence significative et intéressante :

  - Le protocole _DLC channels_ mentionné dans les Bulletins [#174][news174 channels] et
    [#260][news260 channels] utilise un mécanisme similaire à [LN-Penalty][topic ln-penalty]
    commit-and-revoke où les parties _s'engagent_ sur un nouvel état en le signant puis _révoquent_
    l'ancien état en libérant un secret qui permet à leur version privée de l'ancien état d'être
    complètement dépensée par leur contrepartie si elle est publiée sur la chaîne. Cela permet de
    renouveler un DLC par interaction entre les parties. Par exemple, Alice et Bob font ce qui suit :

    1. S'accordent immédiatement sur un DLC pour le prix BTCUSD dans un mois.

    2. Trois semaines plus tard, s'accordent sur un DLC pour le prix BTCUSD dans deux mois et révoquent
       le DLC précédent.

    - Le nouveau protocole _DLC factories_ révoque automatiquement la capacité des deux parties à
      publier des états onchain au moment où le contrat arrive à maturité en permettant à toute
      attestation d'oracle pour le contrat de servir de secret qui permet à un état privé d'être
      complètement dépensé par une contrepartie s'il est publié onchain. En effet, cela annule
      automatiquement les anciens états, ce qui permet de signer des DLC successifs au début de la factory
      sans aucune interaction supplémentaire requise. Par exemple, Alice et Bob font ce qui suit :

    1. S'accordent immédiatement sur un DLC pour le prix BTCUSD dans un mois.

    2. S'accordent également immédiatement sur un DLC pour le prix BTCUSD dans deux mois avec un
       [timelock][topic timelocks] qui empêche sa publication jusqu'à un mois à partir de maintenant. Ils
       peuvent répéter cela pour le troisième mois, le quatrième, etc...

  Dans le protocole DLC channels, Alice et Bob ne peuvent pas créer le deuxième contrat tant qu'ils ne
  sont pas prêts à révoquer le premier contrat, ce qui nécessite une interaction entre eux à ce
  moment-là. Dans le protocole DLC factories, tous les contrats peuvent être créés au moment de la
  création de la factory et aucune interaction supplémentaire n'est requise ; cependant, l'une ou
  l'autre partie peut toujours interrompre une série de contrats en allant onchain avec la
  version actuellement sûre et publiable.

  Si les participants à la factory sont capables d'interagir après l'établissement du contrat, ils
  peuvent le prolonger, mais ils ne peuvent pas décider d'utiliser un contrat différent ou des oracles
  différents avant que tous les contrats précédemment signés aient atteint leur maturité (à moins
  d'aller onchain). Bien qu'il soit peut-être possible d'éliminer cet inconvénient, c'est
  actuellement le compromis pour la réduction de l'interactivité par rapport au protocole DLC
  channels, qui permet des changements de contrat arbitraires à tout moment par révocation mutuelle.

  Nous remercions conduition de nous avoir informés de notre erreur dans le bulletin de la semaine
  dernière et d'avoir patiemment [répondu][conduition reply] à nos questions.

## Modifications apportées aux services et aux logiciels clients

*Dans cette rubrique mensuelle, nous mettons en lumière des mises à jour intéressantes des
portefeuilles et services Bitcoin.*

- **Bull Bitcoin Mobile Wallet ajoute payjoin :**
  Bull Bitcoin [a annoncé][bull bitcoin blog] la prise en charge de l'envoi et la réception pour
  [payjoin][topic payjoin] tel que décrit dans la [proposition][BIPs #1483] BIP77 Payjoin Version 2:
  Serverless Payjoin specification.

- **Bitcoin Keeper ajoute le support de miniscript :**
  Bitcoin Keeper [a annoncé][bitcoin keeper twitter] le support pour [miniscript][topic miniscript]
  dans la [version 1.3.0][bitcoin keeper v1.3.0].

- **Nunchuk ajoute les fonctionnalités MuSig2 pour taproot :**
  Nunchuk [a annoncé][nunchuk blog] un support bêta pour [MuSig2][topic musig] pour les dépenses
  [multisignature][topic multisignature] avec [taproot][topic taproot] ainsi que l'utilisation d'un
  arbre de chemins de script MuSig2 afin d'atteindre des dépenses à seuil [threshold][topic threshold
  signature] de type k-de-n.

- **Annonce du dispositif de signature Jade Plus :**
  Le dispositif de signature matériel [Jade Plus][blockstream blog] inclut [des capacités de signature
  résistantes à l'exfiltration][topic exfiltration-resistant signing] et des fonctionnalités
  déconnectées, parmi d'autres caractéristiques.

- **Sortie de Coinswap v0.1.0 :**
  [Coinswap v0.1.0][coinswap v0.1.0] est un logiciel bêta qui s'appuie sur une
  [spécification][coinswap spec] protocolaire formalisée [coinswap][topic coinswap], prend en charge
  [testnet4][topic testnet], et inclut des applications en ligne de commande pour interagir avec le
  protocole.

- **Sortie de Bitcoin Safe 1.0.0 :**
  Le logiciel de portefeuille de bureau [Bitcoin Safe][bitcoin safe website] prend en charge une
  variété de dispositifs de signature matérielle avec la [version 1.0.0][bitcoin safe 1.0.0].

- **Démonstration de la politique de Bitcoin Core 28.0 :**
  Super Testnet [a annoncé][zero fee sn] un site web [Zero fee playground][zero fee website] qui
  démontre les [fonctionnalités de politique de mempool][28.0 guide] de la version Bitcoin Core 28.0.

- **Sortie de Rust-payjoin 0.21.0 :**
  La version [rust-payjoin 0.21.0][rust-payjoin 0.21.0] ajoute des capacités de [transaction
  cut-through][] (voir le [Podcast #282][pod282 payjoin]).

- **PeerSwap v4.0rc1 :**
  Le logiciel de liquidité de canal Lightning PeerSwap a publié [v4.0rc1][peerswap v4.0rc1] qui
  comprend des mises à niveau du protocole. La [FAQ PeerSwap][peerswap faq] explique en quoi PeerSwap
  diffère des [submarine swaps][topic submarine swaps], [splicing][topic splicing], et [annonces de
  liquidité][topic liquidity advertisements].

- **Prototype Joinpool utilisant CTV :**
  La preuve de concept [ctv payment pool][ctv payment pool github] utilise la proposition d'opcode
  [OP_CHECKTEMPLATEVERIFY (CTV)][topic op_checktemplateverify] pour créer un [joinpool][topic joinpools].

- **Annonce de la bibliothèque Rust joinstr :**
  La bibliothèque expérimentale [rust library][rust joinstr github] met en œuvre le protocole
  [coinjoin][topic coinjoin].

- **Annonce du pont Strata :**
  Le [pont Strata][strata blog] est un pont basé sur [BitVM2][topic acc] pour
  transférer des bitcoins vers et depuis une [sidechain][topic sidechains], dans ce cas
  un rollup de validité (voir le [Bulletin #222][news222 validity rollups]).

## Mises à jour et versions candidates

_Nouvelles versions et candidats à la version pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les candidats
à la version._

- [BTCPay Server 2.0.6][] contient un "correctif de sécurité pour les commerçants utilisant
  les remboursements/paiements tirés onchain avec des processeurs de paiement automatisés." Sont
  également inclus plusieurs nouvelles fonctionnalités et corrections de bugs.

## Changements notables dans le code et la documentation

_Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi
repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration de Bitcoin (BIPs)][bips
repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Inquisition Bitcoin][bitcoin inquisition
repo], et [BINANAs][binana repo]._

- [Bitcoin Core #31397][] améliore le [processus de résolution des orphelins][news333 prclub] en
  suivant et en utilisant tous les pairs potentiels pouvant fournir les transactions parentes manquantes.
  Auparavant, le processus de résolution dépendait uniquement du pair qui avait initialement
  fourni la transaction orpheline. Si le pair ne répondait pas ou renvoyait un
  message `notfound`, il n'y avait pas de mécanisme de réessai, entraînant probablement
  des échecs de téléchargement de la transaction. La nouvelle approche tente de télécharger la
  transaction parente de tous les pairs candidats tout en maintenant l'efficacité de la bande
  passante, la résistance à la censure et un équilibrage de charge efficace. C'est
  particulièrement bénéfique pour le relais de paquets un-parent un-enfant (1p1c) [package
  relay][topic package relay], et cela prépare le terrain pour le relais de paquets d'ancêtres initié par le
  récepteur de [BIP331][].

- [Eclair #2896][] permet de stocker la signature partielle d’un pair [MuSig2][topic musig] au lieu
  d’une signature multisig traditionnelle 2-sur-2, comme
  prérequis pour une future mise en œuvre de [canaux taproot simples][topic
  simple taproot channels]. Stocker cela permet à un nœud de diffuser unilatéralement
  une transaction d'engagement lorsque nécessaire.

- [LDK #3408][] introduit des utilitaires pour créer des factures statiques et leurs
  [offres][topic offers] correspondantes dans le `ChannelManager`, pour supporter
  les [paiements asynchrones][topic async payments] dans [BOLT12][] tel que spécifié dans [BOLTs
  #1149][]. Contrairement à l'utilitaire de création d'offre régulier, qui nécessite que le
  destinataire soit en ligne pour servir les demandes de facture, le nouvel utilitaire accommode
  les destinataires qui sont fréquemment hors ligne. Cette PR ajoute également les tests manquants
  pour le paiement de factures statiques (voir le Bulletin [#321][news321 async]), et assure
  que les demandes de facture sont récupérables lorsque le destinataire se reconnecte en ligne.

- [LND #9405][] rend le paramètre `ProofMatureDelta` configurable, ce qui détermine le nombre de
  confirmations nécessaires avant qu'une [annonce de canal][topic channel announcements] soit traitée
  dans le réseau de gossip. La valeur par défaut est de 6.

{% include snippets/recap-ad.md when="2025-01-28 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1746,21283,31397,2896,3408,9405,1149,1483" %}
[news337 dlc]: /fr/newsletters/2025/01/17/#dlc-offchain
[conduition factories]: https://conduition.io/scriptless/dlc-factory/
[conduition reply]: https://mailmanlists.org/pipermail/dlc-dev/2025-January/000193.html
[news174 channels]: /en/newsletters/2021/11/10/#dlcs-over-ln
[news260 channels]: /fr/newsletters/2023/07/19/#le-portefeuille-10101-beta-teste-la-mise-en-commun-des-fonds-entre-les-ln-et-les-dlc
[condution reply]: https://mailmanlists.org/pipermail/dlc-dev/2025-January/000193.html
[news283 unspendable]: /fr/newsletters/2024/01/03/#comment-specifier-des-cles-non-depensables-dans-les-descripteurs
[toth unspendable delv]: https://delvingbitcoin.org/t/unspendable-keys-in-descriptors/304/31
[toth unspendable ml]: https://mailing-list.bitcoindevs.xyz/bitcoindev/a594150d-fd61-42f5-91cd-51ea32ba2b2cn@googlegroups.com/
[news141 psbtv2]: /en/newsletters/2021/03/24/#bips-1059
[provoost psbtv2]: https://mailing-list.bitcoindevs.xyz/bitcoindev/6FDAD97F-7C5F-474B-9EE6-82092C9073C5@sprovoost.nl/
[bse psbtv2]: https://bitcoin.stackexchange.com/a/125393/21052
[ingala psbtv2]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAMhCMoGONKFok_SuZkic+T=yoWZs5eeVxtwJL6Ei=yysvA8rrg@mail.gmail.com/
[toth psbtv2]: https://mailing-list.bitcoindevs.xyz/bitcoindev/30737859-573e-40ea-9619-1d18c2a6b0f4n@googlegroups.com/
[btcpay server 2.0.6]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.0.6
[news321 async]: /fr/newsletters/2024/09/20/#ldk-3140
[news333 prclub]: /fr/newsletters/2024/12/13/#bitcoin-core-pr-review-club
[bull bitcoin blog]: https://www.bullbitcoin.com/blog/bull-bitcoin-wallet-payjoin
[bitcoin keeper twitter]: https://x.com/bitcoinKeeper_/status/1866147392892080186
[bitcoin keeper v1.3.0]: https://github.com/bithyve/bitcoin-keeper/releases/tag/v1.3.0
[nunchuk blog]: https://nunchuk.io/blog/taproot-multisig
[blockstream blog]: https://blog.blockstream.com/introducing-the-all-new-blockstream-jade-plus-simple-enough-for-beginners-advanced-enough-for-cypherpunks/
[coinswap v0.1.0]: https://github.com/citadel-tech/coinswap/releases/tag/v0.1.0
[coinswap spec]: https://github.com/citadel-tech/Coinswap-Protocol-Specification
[bitcoin safe website]: https://bitcoin-safe.org/en/
[bitcoin safe 1.0.0]: https://github.com/andreasgriffin/bitcoin-safe
[zero fee sn]: https://stacker.news/items/805544
[zero fee website]: https://supertestnet.github.io/zero_fee_playground/
[28.0 guide]: /en/bitcoin-core-28-wallet-integration-guide/
[rust-payjoin 0.21.0]: https://github.com/payjoin/rust-payjoin/releases/tag/payjoin-0.21.0
[transaction cut-through]: https://bitcointalk.org/index.php?topic=281848.0
[pod282 payjoin]: /en/podcast/2023/12/21/#payjoin-transcript
[peerswap v4.0rc1]: https://github.com/ElementsProject/peerswap/releases/tag/v4.0rc1
[peerswap faq]: https://github.com/ElementsProject/peerswap?tab=readme-ov-file#faq
[ctv payment pool github]: https://github.com/stutxo/op_ctv_payment_pool
[rust joinstr github]: https://github.com/pythcoiner/joinstr
[strata blog]: https://www.alpenlabs.io/blog/introducing-the-strata-bridge
[news222 validity rollups]: /fr/newsletters/2022/10/19/#recherche-sur-les-rollups-de-validite
