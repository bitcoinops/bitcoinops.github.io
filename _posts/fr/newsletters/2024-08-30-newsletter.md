---
title: 'Bulletin Hebdomadaire Bitcoin Optech #318'
permalink: /fr/newsletters/2024/08/30/
name: 2024-08-30-newsletter-fr
slug: 2024-08-30-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine annonce une nouvelle liste de diffusion pour discuter du minage de
Bitcoin. Sont également incluses nos
rubriques habituelles avec des questions et réponses populaires
de la communauté Bitcoin Stack Exchange, des annonces de nouvelles versions et de
versions candidates, ainsi que les changements apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Nouvelle liste de diffusion pour le développement du minage de Bitcoin :** Jay Beddict a
  [annoncé][beddict mining-dev] une nouvelle liste de diffusion pour "discuter des mises à jour de la
  technologie de minage de Bitcoin émergente ainsi que des impacts des changements de logiciels ou de
  protocole liés au Bitcoin sur le minage."

  Mark "Murch" Erhardt a [posté][erhardt warp] sur la liste pour demander si la correction du [time
  warp][topic time warp] déployée sur [testnet4][topic testnet] pourrait conduire les mineurs à créer
  des blocs invalides si la même correction était déployée sur le mainnet (comme partie d'un [soft
  fork de nettoyage][topic consensus cleanup]). Mike Schmidt a [référé][schmidt oblivious] les
  lecteurs de la liste à une [discussion][towns oblivious] sur la liste de diffusion Bitcoin-Dev
  concernant les [parts à considérer][topic block withholding] (voir le [Bulletin #315][news315
  oblivious]).

## Questions et réponses sélectionnées de Bitcoin Stack Exchange

*[Le Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs
d'Optech cherchent des réponses à leurs questions - ou quand nous avons quelques moments libres pour
aider les utilisateurs curieux ou confus. Dans cette rubrique mensuelle, nous mettons en lumière
certaines des questions et réponses les plus votées depuis notre dernière mise à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Un bloc compact BIP152 peut-il être envoyé avant validation par un nœud qui ne connaît pas toutes les transactions ?]({{bse}}123858)
  Antoine Poinsot souligne que transmettre des [blocs compacts][topic compact block relay] avant de
  valider que toutes les transactions incluses sont engagées par l'en-tête du bloc serait un vecteur
  de déni de service.

- [Segwit (BIP141) a-t-il éliminé tous les problèmes de malléabilité des txid énumérés dans le BIP62 ?]({{bse}}124074)
  Vojtěch Strnad explique diverses manières dont les txid peuvent être malleabilisés, comment segwit a
  abordé la malleabilité, ce qu'est la malleabilité non intentionnelle, et une demande de modification
  liée à la politique.

- [Pourquoi les points de contrôle sont-ils encore dans la base de code en 2024 ?]({{bse}}123768)
  Lightlike note qu'avec l'ajout de la ["Headers Presync"][news216 headers presync], la base de code
  de Bitcoin Core n'a pas de besoins _connus_ pour les points de contrôle, mais souligne qu'il peut y
  avoir des vecteurs d'attaque _inconnus_ contre lesquels les points de contrôle protègent.

- [Bulletproof++ comme ZKP générique à la manière des SNARKs ?]({{bse}}119556)
  Liam Eagen détaille le type d'argument succinct non interactif de connaissance (SNARKs) actuellement
  utilisé et comment les bulletproofs, [BitVM][topic acc], et
  [OP_CAT][topic op_cat] pourrait être utilisé pour vérifier de telles preuves dans Bitcoin Script.

- [Comment OP_CAT peut-il être utilisé pour implémenter des covenants supplémentaires ?]({{bse}}123829)
  Brandon - Rearden décrit comment l'opcode OP_CAT proposé pourrait fournir
  une fonctionnalité de [covenant][topic covenants] aux scripts Bitcoin.

- [Pourquoi certaines adresses bitcoin bech32 contiennent-elles un grand nombre de 'q' ?]({{bse}}123902)
  Vojtěch Strnad révèle que le protocole OLGA encode des données arbitraires dans
  les sorties P2WSH avec une partie du schéma nécessitant un remplissage de 0 (0 est codé comme 'q'
  dans [bech32][topic bech32]).

- [Comment fonctionne une caution de signature 0-conf ?]({{bse}}124022)
  Matt Black explique comment les fonds verrouillés dans un covenant basé sur OP_CAT pourraient
  fournir des incitations pour que les dépensiers n'augmentent pas les frais de leurs
  transactions par [RBF][topic rbf], augmentant potentiellement l'acceptation des transactions sans confirmation.

## Mises à jour et versions candidates

*Nouvelles mises à jour et versions candidates à la sortie pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de passer aux nouvelles versions ou d'aider à tester
les versions candidates.*

- [Core Lightning 24.08rc2][] est une mise-à-jour candidate pour la prochaine version majeure
  de cette implémentation populaire de nœud LN.

- [LND v0.18.3-beta.rc1][] est une mise-a-jour candidate pour une version mineure de correction de bugs
  de cette implémentation populaire de nœud LN.

- [BDK 1.0.0-beta.2][] est une mise-a-jour candidate pour cette bibliothèque pour
  la construction de portefeuilles et d'autres applications activées par Bitcoin. Le paquet `bdk`
  original a été renommé en `bdk_wallet` et les modules de couche inférieure ont été extraits dans leurs
  propres paquets de codes, y compris `bdk_chain`, `bdk_electrum`, `bdk_esplora`, et `bdk_bitcoind_rpc`.
  Le paquet `bdk_wallet` "est la première version à offrir une API stable 1.0.0."

- [Bitcoin Core 28.0rc1][] est une mise-a-jour candidate pour la prochaine version majeure
  de l'implémentation de nœud complet prédominante. Un [guide de test][bcc testing] est en
  préparation.

## Changements notables de code et de documentation

Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], et [BINANAs][binana repo]._

- [LDK #3263][] simplifie la manière dont il gère les réponses aux [messages onion][topic onion messages]
  en supprimant le paramètre de type de message de la structure `ResponseInstruction`,
  et en introduisant un nouveau enum `MessageSendInstructions` basé sur
  la mise à jour de `ResponseInstruction`, qui peut gérer à la fois les chemins de réponse
  [aveuglés][topic rv routing] et non aveuglés. La méthode `send_onion_message` utilise maintenant
  `MessageSendInstructions`, permettant aux utilisateurs de spécifier des chemins de réponse sans
  avoir à résoudre eux-mêmes le routage. Une nouvelle option, `MessageSendInstructions::ForReply`,
  permet aux gestionnaires de messages d'envoyer des réponses plus tard sans créer de dépendances
  circulaires dans le code. Voir le Bulletin [#303][news303 onion].

- [LDK #3247][] déprécie la méthode `AvailableBalances::balance_msat` au profit de la méthode
  `ChannelMonitor::get_claimable_balances`, qui offre une approche plus directe et précise pour
  obtenir le solde d'un canal. La logique de la méthode dépréciée est désormais obsolète car elle
  était initialement conçue pour gérer les problèmes de sous-flux potentiels lorsque les soldes
  incluaient des HTLCs en attente (ceux qui pourraient être inversés plus tard).

- [BDK #1569][] ajoute la paquet `bdk_core` et y déplace certains types de `bdk_chain` : `BlockId`,
  `ConfirmationBlockTime`, `CheckPoint`, `CheckPointIter`, `tx_graph::Update` et `spk_client`. Les
  sources de chaînes `bdk_esplora`, `bdk_electrum` et `bdk_bitcoind_rpc` ont été modifiées pour
  dépendre uniquement de `bdk_core`. Ces changements ont été effectués pour permettre un remaniement
  plus rapide sur `bdk_chain`.

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3263,3247,1569" %}
[Core Lightning 24.08rc2]: https://github.com/ElementsProject/lightning/releases/tag/v24.08rc2
[LND v0.18.3-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.3-beta.rc1
[BDK 1.0.0-beta.2]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.2
[bitcoin core 28.0rc1]: https://bitcoincore.org/bin/bitcoin-core-28.0/
[news315 oblivious]: /fr/newsletters/2024/08/09/#attaques-de-retention-de-blocs-et-solutions-potentielles
[beddict mining-dev]: https://groups.google.com/g/bitcoinminingdev/c/97fkfVmHWYU
[erhardt warp]: https://groups.google.com/g/bitcoinminingdev/c/jjkbeODskIk
[schmidt oblivious]: https://groups.google.com/g/bitcoinminingdev/c/npitVsP9KNo
[towns oblivious]: https://groups.google.com/g/bitcoindev/c/1tDke1a2e_Q
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Candidate-Testing-Guide
[news216 headers presync]: /fr/newsletters/2022/09/07/#bitcoin-core-25717
[news303 onion]: /fr/newsletters/2024/05/17/#ldk-2907