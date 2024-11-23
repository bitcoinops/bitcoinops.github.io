---
title: 'Bulletin Hebdomadaire Bitcoin Optech #330'
permalink: /fr/newsletters/2024/11/22/
name: 2024-11-22-newsletter-fr
slug: 2024-11-22-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume une proposition de modification de la spécification de LN pour
permettre des usines de canaux modulables, renvoie à un rapport et à un nouveau site web pour
examiner les transactions sur le signet par défaut utilisant des propositions de soft forks, décrit une
mise à jour de la proposition de soft fork multi-parties LNHANCE, et discute d'un document sur les
covenants basés sur la rectification plutôt que sur des changements de consensus. Sont également inclus nos
sections habituelles annoncant les mises à jour avec les versions candidates, et présente les changements
apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Usines de canaux modulables :** ZmnSCPxj a [posté][zmnscpxj plug] sur Delving Bitcoin une
  proposition pour apporter un petit ensemble de modifications à la spécification [BOLT][bolts repo]
  afin de permettre aux logiciels LN existants de gérer des canaux de paiement [LN-Penalty][topic
  ln-penalty] au sein d'une [usine de canaux][topic channel factories] en utilisant un plugin
  logiciel. Les modifications de spécification permettraient au gestionnaire de l'usine (par exemple,
  un fournisseur de services Lightning, LSP) d'envoyer des messages à un nœud LN qui seraient transmis
  à un plugin d'usine local. De nombreuses opérations d'usine seraient similaires aux opérations de
  [splicing][topic splicing], permettant au plugin de réutiliser une quantité significative de code.
  Les opérations de canal LN-Penalty au sein d'une usine seraient similaires aux [canaux
  zero-conf][topic zero-conf channels], ils pourraient donc également réutiliser le code existant.

  La conception de ZmnSCPxj est axée sur les usines de style SuperScalar (voir le [Bulletin
  #327][news327 superscalar]) mais serait probablement compatible avec d'autres styles d'usine (et
  possiblement d'autres protocoles de contrat multiparte). Rene Pickhardt a [répondu][pickhardt plug]
  pour demander des modifications de spécification supplémentaires qui pourraient permettre
  d'[annoncer][topic channel announcements] les canaux au sein des usines, mais ZmnSCPxj a
  [dit][zmnscpxj plug2] qu'il n'avait délibérément pas considéré ces aspects dans sa conception afin
  de permettre à la modification de spécification d'être adoptée le plus rapidement possible.

- **Rapport d'activité Signet :** Anthony Towns a [posté][towns signet] sur Delving Bitcoin un
  résumé de l'activité sur le [signet][topic signet] par défaut lié aux proposition de soft forks
  disponibles via [Bitcoin Inquisition][bitcoin inquisition repo]. Le post examine l'utilisation de
  [SIGHASH_ANYPREVOUT][topic sighash_anyprevout], y compris les tests de [LN-Symmetry][topic eltoo] et
  l'émulation de [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]. Il examine ensuite
  directement l'utilisation de `OP_CHECKTEMPLATEVERIFY`, y compris ce qui sont probablement plusieurs
  constructions différentes de [coffre-forts][topic vaults] et quelques transactions porteuses de données.
  Enfin, le post examine l'utilisation de [OP_CAT][topic op_cat], y compris pour un faucet de preuve
  de travail (voir le [Bulletin #306][news306 powfaucet]), un possible coffre-fort ou autre [covenant][topic
  covenants], et la vérification d'une preuve à connaissance nulle [STARK][].
  Vojtěch Strnad a [répondu][strnad i.o] qu'il a été inspiré par le post de Towns pour créer un site
  web qui répertorie "[chaque transaction][inquisition.observer] effectuée sur le signet Bitcoin qui
  utilise l'un des soft forks déployés."

- **Mise à jour de la proposition LNHANCE :** Moonsettler a [publié][moonsettler paircommit delving]
  sur Delving Bitcoin et [également][moonsettler paircommit list] sur la liste de diffusion
  Bitcoin-Dev une proposition pour un nouvel opcode, `OP_PAIRCOMMIT`, à ajouter à la proposition de
  soft fork LNHANCE qui inclut [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] et
  [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack]. Le nouvel opcode permet de faire un engagement
  de hachage sur une paire d'éléments ; cela est similaire à ce qui pourrait être réalisé en utilisant
  l'opcode de concaténation proposé [OP_CAT][topic op_cat] ou les opcodes de hachage en flux tels que
  ceux [disponibles][streaming sha] dans les [sidechains][topic sidechains] basées sur Elements mais
  est délibérément limité pour éviter de permettre des [covenants][topic covenants] récursifs.

  Moonsettler a également [discuté][moonsettler other lnhance] sur la liste de diffusion d'autres
  petites modifications potentielles à la proposition LNHANCE.

- **Covenants basés sur la rectification plutôt que sur des changements de consensus :** Ethan Heilman a
  [publié][heilman collider] sur la liste de diffusion Bitcoin-Dev le résumé d'un [article][hklp
  collider] qu'il a coécrit avec Victor Kolobov, Avihu Levy, et Andrew Poelstra. L'article décrit
  comment les [covenants][topic covenants] peuvent être créés facilement sans changements de
  consensus, bien que les dépenses de ces covenants nécessiteraient des transactions non standard et
  des millions (ou milliards) de dollars en matériel spécialisé et en électricité. Heilman note qu'une
  application du travail est de permettre aux utilisateurs aujourd'hui d'inclure facilement un chemin
  de dépense taproot de secours qui peut être utilisé en toute sécurité si une [résistance
  quantique][topic quantum resistance] est soudainement nécessaire et que les opérations de signature
  à courbe elliptique sur Bitcoin sont désactivées.

## Changements notables dans le code et la documentation

*Dans cette rubrique mensuelle, nous mettons en lumière des mises à jour intéressantes des
portefeuilles et services Bitcoin.*

- **Annonce du protocole de seconde couche Spark :**
  [Spark][spark website] est un protocole offchain, semblable à [statechain][topic statechains],
  qui prend en charge le Lightning Network.

- **Annonce du portefeuille Unify :**
  [Unify][unify github] est un portefeuille compatible [BIP78][] [payjoin][topic payjoin] qui utilise
  Bitcoin Core et coordonne les [PSBTs][topic psbt] via NOSTR.

- **Lancement de bitcoinutils.dev :**
  Le site [bitcoinutils.dev][] propose une variété d'utilitaires Bitcoin incluant le débogage de
  scripts ainsi que diverses fonctions de codage et de hachage.

- **Disponibilité du Great Restored Script Interpreter :**
  Le [Great Restored Script Interpreter][greatrsi github] est un interpréteur expérimental pour la
  proposition [Great Script Restoration][gsr youtube].

## Changements notables dans le code et la documentation

_Changes récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core
lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware WalletInterface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin
Improvement Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips
repo], [Bitcoin Inquisition][bitcoin inquisition repo] et [BINANAs][binana repo]._

- [Bitcoin Core #30666][] ajoute la fonction `RecalculateBestHeader()` pour recalculer le meilleur
  en-tête en itérant sur l'index des blocs, ce qui est automatiquement déclenché lorsque les commandes
  RPC `invalidateblock` et `reconsiderblock` sont utilisées, ou lorsque des en-têtes valides dans
  l'index des blocs sont ultérieurement trouvés invalides lors de la validation complète. Cela corrige
  un problème où la valeur était incorrectement définie après ces événements. Cette PR marque
  également les en-têtes qui se prolongent à partir d'un bloc invalide comme `BLOCK_FAILED_CHILD`, les
  empêchant d'être considérés pour `m_best_header`.

- [Bitcoin Core #30239][] rend les [sorties de poussière éphémère][topic ephemeral
  anchors] standard, permettant aux transactions sans frais avec une sortie de [poussière][topic uneconomical
  outputs] d'apparaître dans le mempool, à condition qu'elles soient dépensées simultanément dans un
  [package][topic package relay] de transaction. Ce changement améliore l'utilisabilité de
  constructions avancées telles que les sorties avec connecteur, les ancres avec clé et sans clé ([P2A][topic
  ephemeral anchors]), qui peuvent bénéficier de l'extension de protocoles tels que LN, [Ark][topic
  ark], [arbres de timeout][topic timeout trees], [BitVM2][topic acc], et d'autres. Cette mise à jour
  s'appuie sur des fonctionnalités existantes telles que les relais 1P1C, les transactions
  [TRUC][topic v3 transaction relay] et [l'éviction de fratrie][topic kindred rbf] (voir le [Bulletin
  #328][news328 ephemeral]).

- [Core Lightning #7833][] active par défaut le protocole des [offres][topic offers], retirant son
  statut expérimental précédent. Cela fait suite à la fusion de sa PR dans le dépôt BOLTs (voir
  le [Bulletin #323][news323 offers]).

- [Core Lightning #7799][] introduit le plugin `xpay` pour envoyer des paiements en construisant des
  [paiements multipath][topic multipath payments] optimaux, en utilisant le plugin `askrene` (voir
  le [Bulletin #316][news316 askrene]) et la commande RPC `injectpaymentonion`. Il prend en charge le
  paiement des factures [BOLT11][] et [BOLT12][topic offers], la définition des durées de réessai et
  des délais de paiement, l'ajout de données de routage à travers les couches, et la réalisation de
  paiements partiels pour des contributions multi-parties sur une seule facture. Ce plugin est plus
  simple et plus sophistiqué que l'ancien plugin ‘pay’, mais n'a pas toutes ses fonctionnalités.

- [Core Lightning #7800][] ajoute une nouvelle commande RPC `listaddresses` qui retourne une liste
  de toutes les adresses bitcoin qui ont été générées par le nœud CLN. Cette PR définit également
  [P2TR][topic taproot] comme le type de script par défaut pour les dépenses [de sortie d'ancrage][topic
  anchor outputs] et pour les adresses de changement de fermeture unilatérale.

- [Core Lightning #7102][] étend la commande `generatehsm` pour exécuter
  non-interactivement avec des options de ligne de commande. Auparavant, vous ne pouviez générer un
  secret de Module de Sécurité Matérielle (HSM) qu'à travers un processus interactif au terminal, donc
  ce changement est particulièrement utile pour les installations automatisées.

- [Core Lightning #7604][] ajoute les commandes RPC `bkpr-editdescriptionbypaymentid` et
  `bkpr-editdescriptionbyoutpoint` au plugin de comptabilité, qui mettent à jour ou définissent la
  description sur les événements correspondant à l'identifiant de paiement ou à point se sortie
  respectivement.

- [Core Lightning #6980][] introduit une nouvelle commande `splice` qui prend soit un payload JSON
  soit un script de splice qui définit des actions de [splicing][topic splicing] complexes et liées,
  et combine toutes ces opérations multi-canaux en une seule transaction. Cette PR ajoute également la
  commande RPC `addpsbtinput` qui permet aux utilisateurs d'ajouter directement des entrées à un
  [PSBT][topic psbt], et ajoute les commandes RPC `stfu_channels` et `abort_channels` qui permettent
  aux utilisateurs de mettre en pause l'activité des canaux ou d'abandonner plusieurs canaux pour
  activer les [mises à niveau de l'engagement des canaux][topic channel commitment upgrades], ce qui
  est crucial lors de l'exécution d'actions de splice complexes.

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 15:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30666,30239,7833,7799,7800,7102,7604,6980,3283" %}
[zmnscpxj plug]: https://delvingbitcoin.org/t/pluggable-channel-factories/1252/
[news327 superscalar]: /fr/newsletters/2024/11/01/#fabriques-de-canaux-avec-arbre-de-timeout
[pickhardt plug]: https://delvingbitcoin.org/t/pluggable-channel-factories/1252/2
[zmnscpxj plug2]: https://delvingbitcoin.org/t/pluggable-channel-factories/1252/3
[towns signet]: https://delvingbitcoin.org/t/ctv-apo-cat-activity-on-signet/1257
[news306 powfaucet]: /fr/newsletters/2024/06/07/#script-op-cat-pour-valider-la-preuve-de-travail
[stark]: https://en.wikipedia.org/wiki/Non-interactive_zero-knowledge_proof
[moonsettler paircommit delving]: https://delvingbitcoin.org/t/op-paircommit-as-a-candidate-for-addition-to-lnhance/1216
[moonsettler paircommit list]: mailto:bitcoindev@mailing-list.bitcoindevs.xyz
[streaming sha]: https://github.com/ElementsProject/elements/blob/011feab4c45d6e23985dbd68294e6aeb5a7c0237/doc/tapscript_opcodes.md#new-opcodes-for-additional-functionality
[moonsettler other lnhance]: https://mailing-list.bitcoindevs.xyz/bitcoindev/ZzZziZOy4IrTNbNG@console/[heilman collider]:
https://mailing-list.bitcoindevs.xyz/bitcoindev/CAEM=y+W2jyFoJAq9XrE9whQ7EZG4HRST01TucWHJtBhQiRTSNQ@mail.gmail.com/
[hklp collider]: https://eprint.iacr.org/2024/1802
[strnad i.o]: https://delvingbitcoin.org/t/ctv-apo-cat-activity-on-signet/1257/4
[inquisition.observer]: https://inquisition.observer/
[news323 offers]: /fr/newsletters/2024/10/04/#bolts-798
[news316 askrene]: /fr/newsletters/2024/08/16/#core-lightning-7517
[news328 ephemeral]: /en/newsletters/2024/11/08/#bitcoin-core-pr-review-club
[spark website]: https://www.spark.info/
[unify github]: https://github.com/Fonta1n3/Unify-Wallet
[bitcoinutils.dev]: https://bitcoinutils.dev/
[greatrsi github]: https://github.com/jonasnick/GreatRSI
[gsr youtube]: https://www.youtube.com/watch?v=rSp8918HLnA