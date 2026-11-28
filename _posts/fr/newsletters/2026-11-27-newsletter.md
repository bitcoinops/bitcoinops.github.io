---
title: 'Bulletin Hebdomadaire Bitcoin Optech #433'
permalink: /fr/newsletters/2026/11/27/
name: 2026-11-27-newsletter-fr
slug: 2026-11-27-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit une vulnérabilité affectant les anciennes versions de Bitcoin Core, résume la divulgation d'une
vulnérabilité de déni de service dans Core Lightning, et relaie une discussion sur le renouvellement de l'équipe des éditeurs BIP. Sont
également incluses nos sections régulières avec des questions et réponses sélectionnées de Bitcoin Stack Exchange, des annonces de nouvelles
versions et de versions candidates, ainsi que des descriptions de changements notables dans des logiciels d'infrastructure Bitcoin
populaires.

## Nouvelles

- **Divulgation d'une vulnérabilité de sévérité moyenne dans Bitcoin Core :** Greg Sanders a [publié][sanders adv ml] sur la liste de
  diffusion Bitcoin-Dev un avis de sécurité [security advisory][core orphan inv stall] de Bitcoin Core pour une vulnérabilité qui permettait
  à un pair d'empêcher temporairement un nœud de traiter des blocs et des transactions. Elle affecte toutes les versions 29.x, les 30.x
  avant [30.5][core 30.5], et les 31.x avant [31.3][core 31.3]. La version 32.1 inclut déjà le correctif. La série 29.x a atteint sa fin de
  vie et ne recevra pas de correctif, ses utilisateurs doivent donc passer à une version maintenue.

  Bitcoin Core stocke les transactions dont il n'a pas encore vu les parents, appelées orphelines. Depuis 29.0, chaque fois qu'un pair
  annonçait le wtxid d'une orpheline stockée, le nœud vérifiait chacun des parents de cette orpheline dans son mempool et dans ses filtres
  de transactions récemment vues. Un message `inv` peut contenir jusqu'à 50 000 annonces, et les doublons n'étaient pas ignorés. Un
  attaquant pouvait envoyer une orpheline avec des milliers de parents manquants, suivie de messages `inv` répétant son wtxid 50 000 fois.
  Selon l'avis, chacun de ces messages bloquait le nœud pendant plus d'une douzaine de secondes, pendant lesquelles il ne traitait aucun
  message d'autres pairs, y compris les blocs. [Bitcoin Core
  #35878][] traite désormais chaque transaction annoncée une seule fois par message
  `inv`.

  La vulnérabilité a été découverte en juillet par Project Loupe, [divulguée de manière responsable][topic responsible disclosures] par
  Sanders, et signalée indépendamment par stutxo en août. Parce qu'elle a été classée comme facilement découvrable (voir le [Bulletin
  #429][news429 policy]), l'avis a été publié en même temps que 30.5 et 31.3.

- **Divulgation d'une vulnérabilité DoS dans CLN :** Nishant Bansal a [publié][cln vuln del] sur Delving Bitcoin la [divulgation
  responsable][topic responsible disclosures] d'une vulnérabilité de déni de service (DoS) dans Core Lightning (CLN) affectant les versions
  [0.12.0][cln 0.12.0] (août 2022) à [26.06.7][cln 26.06.7] (août 2026), qui permettait à un attaquant de faire planter de façon répétée le
  nœud d'une victime. Le bogue ne donnait à un attaquant aucun accès direct aux fonds, mais faire planter continuellement un nœud pouvait
  mettre les fonds de ses canaux en danger. Il est recommandé aux utilisateurs de mettre immédiatement à niveau vers la dernière version. La
  vulnérabilité a été corrigée dans la version 26.06.8 de CLN (voir le [Bulletin #424][news424 cln rel]).

  La vulnérabilité était liée au fait que plus d'un canal v1 partageait le même `channel_id`. Un pair malveillant pouvait ouvrir un canal en
  fournissant l'outpoint de financement d'un autre canal. Comme `channel_id` est dérivé de cet outpoint, conformément à [BOLT2][], deux
  canaux avaient alors des ID correspondants. CLN exécute un sous-démon `channeld` pour chaque canal, tandis que `connectd` route les
  messages vers le bon sous-démon en fonction de leur `channel_id`. Comme CLN suppose l'unicité de `channel_id`, les collisions provoquaient
  le plantage du nœud.

  Il y avait deux façons pour un pair malveillant de faire planter le nœud, l'une pendant la reconnexion, détectée à l'aide de [smite][gh
  smite], un framework de fuzzing par instantanés pour les implémentations du Lightning Network, et l'autre lors de la fermeture du canal,
  trouvée par le développeur Eugene Siegel :

  - Lorsqu'un pair se reconnecte, le démon principal, `lightningd`, démarre les sous-démons `channeld` et les transmet à `connectd`. À la
    première recherche de `channel_id`, tout fonctionnait bien. Cependant, à la deuxième requête, un `assert` prouvant que la connexion
    n'était pas déjà active interrompait `connectd`, faisant tomber le nœud. Comme les deux canaux étaient toujours présents dans la base de
    données après un redémarrage, une nouvelle tentative de reconnexion faisait à nouveau planter le nœud.

  - CLN conserve en mémoire les canaux précédemment fermés dans une table de hachage indexée par `channel_id`. Un attaquant fermant un canal
    avec le même `channel_id` que celui d'un canal déjà fermé déclenchait l'échec d'une assertion vérifiant qu'aucun doublon n'était ajouté
    à la table. Contrairement à la première variante, le nœud plante alors à chaque redémarrage sans autre action de l'attaquant, jusqu'à ce
    qu'il soit mis à niveau. Ce vecteur d'attaque spécifique n'affectait que les versions [25.05][cln 25.05] et supérieures.

- **Discussion sur le renouvellement des éditeurs BIP :** Mark "Murch" Erhardt a [publié][erhardt bip editors] sur la liste de diffusion
  Bitcoin-Dev pour remettre en avant sa proposition d'avril de renouveler l'équipe des éditeurs BIP (voir les Bulletins [#299][news299 bip
  editors] et [#418][news418 bip editors] pour la couverture précédente de l'ensemble des éditeurs), en citant un arriéré de soumissions en
  attente d'examen par les éditeurs dans le [dépôt BIPs][bips repo]. Il a décrit deux options, ajouter des éditeurs actifs ou abaisser les
  exigences afin que les éditeurs ne vérifient que le format des nouvelles soumissions, et a fortement préféré renouveler l'équipe avec
  trois éditeurs contribuant tous régulièrement. Il a ajouté que des volontaires réticents à un engagement sans limite de durée pouvaient
  proposer de servir pour une durée limitée, par exemple 12 à 24 mois. À la suite de la publication, plusieurs personnes se sont portées
  volontaires, et l'éditeur actuel Olaoluwa Osuntokun a indiqué qu'il prévoyait de se retirer à la fin de l'année. La discussion était
  toujours en cours au moment de la rédaction.

## Questions et réponses sélectionnées de Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech cherchent des réponses à leurs
questions---ou quand nous avons quelques moments libres pour aider les utilisateurs curieux ou confus. Dans cette rubrique mensuelle, nous
mettons en lumière certaines des questions et réponses les mieux votées postées depuis notre dernière mise à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Pourquoi une politique valide avec rust-miniscript provoque-t-elle une erreur de compilation sur le site de sipa ?]({{bse}}131089) Pieter Wuille explique que
  son site de compilation de politiques [miniscript][topic miniscript] n'accepte des noms symboliques que pour les clés, pas pour les
  préimages de hachage, et n'autorise pas les scripts malléables (voir Le [Bulletin #230][news230 malleable]). Une branche de la politique
  de la personne posant la question pouvait être satisfaite en révélant simplement une préimage après 144 blocs, ce qui est intrinsèquement
  malléable car cela n'implique aucune signature.

- [Comment réparer des données d'annulation corrompues (somme de contrôle de rev*.dat incorrecte) sans réindexation complète ?]({{bse}}131107) P22 décrit la reconstruction
  d'enregistrements d'annulation endommagés sur un nœud avec `-txindex`. Les données d'annulation d'un bloc sont la liste des sorties
  dépensées par ses entrées, donc chaque enregistrement peut être reconstruit octet pour octet et réécrit à sa place. `-reindex-chainstate`
  n'aide pas car Bitcoin Core n'écrit les données d'annulation pour un bloc que s'il n'a pas encore de position d'annulation.

- [Pourquoi aucun opcode Bitcoin ne place-t-il sur la pile des données sur la transaction qui dépense les fonds ?]({{bse}}131130) LearnBitcoin répond qu'un soft fork
  redéfinissant un opcode `OP_NOP` peut seulement rendre les scripts invalides, puisqu'en laissant une valeur sur la pile, cela amènerait
  les anciens et les nouveaux nœuds à ne pas être d'accord sur la validité. C'est pourquoi la proposition [OP_CHECKTEMPLATEVERIFY][topic
  op_checktemplateverify] ne fait que vérifier. [Tapscript][topic tapscript] a ajouté des opcodes `OP_SUCCESSx` qui peuvent aussi écrire sur
  la pile (voir le [Bulletin #416][news416 success]), et les propositions de [covenant][topic covenants] `OP_TXHASH` et `OP_TEMPLATEHASH`
  sont définies sur eux.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires. Veuillez envisager de mettre à niveau vers
les nouvelles versions ou d'aider à tester les versions candidates._

- [Bitcoin Core 31.3][] et [30.5][Bitcoin Core 30.5] sont des versions de maintenance de l'implémentation de nœud complet prédominante. Les
  deux corrigent la vulnérabilité DoS décrite ci-dessus.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning
BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #36387][] déprécie la RPC `encryptwallet`, qui chiffre un portefeuille existant non chiffré. La RPC exige désormais que
  Bitcoin Core soit démarré avec l'option `-deprecatedrpc=encryptwallet` et sa suppression est prévue dans une future version majeure.
  Chiffrer un portefeuille existant ne peut pas garantir la suppression du disque des données de clé privée non chiffrées. Cela peut aussi
  générer une nouvelle [graine][topic bip32], de sorte que d'anciennes sauvegardes pourraient ne pas permettre de récupérer les fonds
  envoyés à des adresses nouvellement générées. Les utilisateurs souhaitant chiffrer leur portefeuille devraient plutôt créer un
  portefeuille chiffré en fournissant l'argument `passphrase` à `createwallet` (voir le [Bulletin #47][news47 createwallet]). Les
  portefeuilles chiffrés existants restent pris en charge.

- [BIPs #2301][] ajoute l'ébauche [BIP333][], qui permet aux pairs utilisant le [transport P2P v2][topic v2 p2p transport] de choisir leurs
  propres identifiants de type de message sortant sur un octet (voir le [Bulletin #426][news426 aliases]). [BIP324][] attribue actuellement
  des identifiants sur un octet au moyen d'une table fixe, ce qui exige une coordination pour ajouter de nouvelles entrées. Le message
  proposé `set324alias` permet à chaque pair d'annoncer ses propres alias après que l'autre pair a annoncé sa prise en charge via
  [BIP434][].

- [Core Lightning #9718][] corrige un bogue où un appel RPC `gettxout` échoué de Bitcoin Core pouvait être interprété à tort comme une
  sortie dépensée ou absente. Cela pouvait se produire lorsque Bitcoin Core était inaccessible ou encore en cours de démarrage. Pendant
  l'ouverture de canal avec financement externe (voir le [Bulletin #51][news51 external funding]), la RPC `fundchannel_cancel` pouvait
  oublier un canal dont la transaction de financement avait déjà été diffusée. Le plugin `bcli` réessaie désormais les échecs temporaires de
  connexion et de démarrage, et signale les appels infructueux comme des erreurs. Seule une réponse réussie indiquant l'absence de sortie
  non dépensée à l'outpoint demandé est considérée comme une preuve qu'une sortie est indisponible.

- [LDK #5663][] corrige une perte potentielle de fonds relayés lors de la sauvegarde asynchrone de l'état de récupération de canal. Après la
  fermeture forcée d'un pair de canal entrant, une mise à jour peut enregistrer en mémoire une préimage d'[HTLC][topic htlc] mais renvoyer
  une erreur lors de la tentative de modification de l'état d'engagement du canal fermé. LDK diffuse également une transaction de
  réclamation pour l'HTLC entrant. Auparavant, LDK commençait à persister ces informations sur le disque, mais il ne suivait pas l'écriture
  comme en attente à cause de l'erreur. Une écriture distincte enregistrant la fermeture du canal pouvait se terminer en premier, amenant
  LDK à considérer à tort la préimage comme sauvegardée en toute sécurité et à permettre au canal sortant de supprimer sa copie. Si le nœud
  tombait en panne avant que la préimage ne soit sauvegardée et si la transaction de réclamation ne parvenait pas à se confirmer avant
  l'expiration, il pouvait perdre le paiement entrant après avoir payé l'HTLC sortant. LDK persiste et suit désormais ces mises à jour
  jusqu'à ce que leurs écritures soient terminées.

- [LDK #5678][] corrige la [cible de frais][topic fee estimation] utilisée pour les [transactions de pénalité][topic ln-penalty] lorsqu'un
  pair diffuse une transaction d'engagement révoquée. Auparavant, LDK ne sélectionnait une cible urgente que si les derniers engagements
  contenaient des [HTLC][topic htlc] en attente (voir le [Bulletin
  #319][news319 targets]), sans vérifier séparément si l'engagement onchain
  était révoqué. Sous une pression soutenue sur les frais, la pénalité pouvait rester non confirmée malgré des [augmentations de
  frais][topic rbf] jusqu'à l'expiration des [timelocks][topic timelocks] du pair, permettant au pair de dépenser les fonds révoqués. LDK
  utilise désormais sa cible urgente de balayage onchain chaque fois qu'il identifie un engagement onchain de contrepartie comme révoqué.

- [LND #11607][] corrige les estimations de poids pour les [transactions de pénalité][topic ln-penalty] dépensant des sorties d'[HTLC][topic
  htlc] issues d'engagements révoqués de la contrepartie. Auparavant, LND construisait correctement le témoin de pénalité mais estimait sa
  taille comme s'il dépensait un HTLC de sa propre transaction d'engagement. La pénalité dépensait en réalité une sortie de l'engagement du
  pair, dont le script HTLC pouvait être plus gros, entraînant une sous-estimation du poids. Lors du ciblage du [feerate minimum de
  relais][topic default minimum transaction relay feerates], cela pouvait produire des frais insuffisants et un rejet par le mempool. LND
  fait désormais correspondre les estimations aux scripts dépensés, y compris les octets de script supplémentaires utilisés par les [canaux
  anchor][topic anchor outputs].

- [LND #11247][] corrige des analyses historiques de chaîne qui pouvaient manquer des confirmations ou des dépenses, laissant des canaux
  bloqués à l'ouverture ou à la fermeture. LND partage les analyses entre les requêtes surveillant la même transaction ou sortie.
  Auparavant, si la première requête commençait l'analyse trop tard, une requête ultérieure spécifiant une hauteur de bloc de départ plus
  ancienne pouvait réutiliser cette analyse sans vérifier les blocs antérieurs manquants. Les hauteurs de départ mises en cache pouvaient
  préserver cette omission au fil des redémarrages. LND analyse désormais les plages manquantes et enregistre leurs hauteurs de départ avec
  la progression mise en cache. Cela complète le correctif de clé de cache dans le [Bulletin
  #431][news431 hints]. Les canaux restant bloqués après la mise à niveau peuvent nécessiter
  de redémarrer LND une fois avec l'option `--height-hint-cache-query-disable`, puis de la retirer après récupération.

- [LND #11268][] corrige un bogue de persistance qui pouvait causer une fermeture forcée inutile après une déconnexion. Cela pouvait se
  produire lorsque le nœud initiateur local envoyait une mise à jour de frais sur un canal où il n'avait pas encore révoqué un engagement et
  recevait l'accusé de réception du pair sans sauvegarder la modification sur disque. Si la connexion tombait alors avant que LND ne reçoive
  la signature du prochain engagement du pair, il pouvait reconstruire l'engagement avec les anciens frais et rejeter la signature valide.
  Le correctif supprime un retour anticipé dans la mise à jour de base de données qui empêchait la sauvegarde des mises à jour locales
  accusées de réception.

- [Rust Bitcoin #7160][] ajoute la prise en charge de [testnet5][topic testnet] ([BIP95][]), y compris la valeur `TestnetVersion::V5`, le
  bloc genesis, l'identifiant de chaîne, les paramètres de preuve de travail et la magie des messages réseau. Il met également à jour
  l'analyse du réseau et la gestion des adresses pour reconnaître testnet5. Les paramètres du genesis ont été couverts dans le [Bulletin
  #432][news432 testnet5].

- [BTCPay Server #7846][] ajoute la prise en charge de la connexion à Core Lightning 24.11 ou ultérieur via son service `clnrest` intégré
  (voir le [Bulletin
  #262][news262 clnrest]) en utilisant des runes, des identifiants qui restreignent les
  commandes autorisées. Cela permet à une connexion de créer et surveiller des factures sans autorisation d'envoyer des paiements. Les
  connexions directes existantes à l'interface RPC de Core Lightning restent prises en charge. La mise à jour de dépendance modifie aussi la
  gestion des certificats : les options de chaîne de connexion `allowinsecure`, `certthumbprint`, et `certfilepath` sont désormais ignorées.
  Les opérateurs utilisant des nœuds Lightning externes avec des certificats auto-signés doivent configurer la confiance dans
  l'environnement exécutant BTCPay Server.

- [BTCPay Server #7850][] et [#7851][btcpay server #7851] corrigent des états de paiement Lightning incorrects. Le premier met à jour
  l'adaptateur LNDhub pour préserver les erreurs de paiement renvoyées dans des réponses HTTP 200. Auparavant, elles pouvaient être ignorées
  et un paiement échoué pouvait être signalé comme payé. Les erreurs connues prouvant que l'appel actuel n'a rien envoyé sont désormais
  signalées comme des échecs ; les résultats ambigus restent inconnus. Le second marque un paiement comme terminé lorsqu'une recherche de
  paiement confirme le succès après que l'opération d'envoi a renvoyé une erreur, préservant ainsi la [preuve de paiement][topic proof of
  payment].

{% include snippets/recap-ad.md when="2026-12-01 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="35878,36387,2301,9718,5663,5678,11607,11247,11268,7160,7846,7850,7851" %}
[sanders adv ml]: https://groups.google.com/g/bitcoindev/c/lFzWO5W9pBE
[core orphan inv stall]: https://bitcoincore.org/en/2026/11/20/disclose-orphan-inv-stall/
[core 31.3]: https://bitcoincore.org/en/2026/11/20/release-31.3/
[core 30.5]: https://bitcoincore.org/en/2026/11/20/release-30.5/
[news429 policy]: /fr/newsletters/2026/10/30/#mise-a-jour-de-la-politique-de-securite-de-bitcoin-core
[cln vuln del]: https://delvingbitcoin.org/t/disclosure-dos-vulnerability-fixed-in-core-lightning-v26-06-8/3072
[cln 0.12.0]: https://github.com/ElementsProject/lightning/releases/tag/v0.12.0
[cln 26.06.7]: https://github.com/ElementsProject/lightning/releases/tag/v26.06.7
[news424 cln rel]: /fr/newsletters/2026/09/25/#core-lightning-26-06-8
[gh smite]: https://github.com/lnfuzz/smite
[cln 25.05]: https://github.com/ElementsProject/lightning/releases/tag/v25.05
[erhardt bip editors]: https://groups.google.com/g/bitcoindev/c/zCmHEGbCADQ/m/0nXgyto-AQAJ
[news299 bip editors]: /fr/newsletters/2024/04/24/#mise-a-jour-des-editeurs-bip
[news418 bip editors]: /fr/newsletters/2026/08/14/#bips-2248
[news230 malleable]: /fr/newsletters/2022/12/14/#quand-une-solution-miniscript-est-elle-malleable
[news416 success]: /fr/newsletters/2026/07/31/#la-reservation-op-successx-dans-bip342-a-t-elle-ete-concue-avec-des-familles-d-opcodes-specifiques-a-l-esprit
[Bitcoin Core 31.3]: https://bitcoincore.org/bin/bitcoin-core-31.3/
[Bitcoin Core 30.5]: https://bitcoincore.org/bin/bitcoin-core-30.5/
[LDK #5663]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5663
[LDK #5678]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5678
[news47 createwallet]: /en/newsletters/2019/05/21/#bitcoin-core-15006
[news426 aliases]: /fr/newsletters/2026/10/09/#identifiants-dynamiques-de-type-de-message-sur-un-octet-pour-bip324
[news51 external funding]: /en/newsletters/2019/06/19/#c-lightning-2672
[news319 targets]: /fr/newsletters/2024/09/06/#ldk-3268
[news431 hints]: /fr/newsletters/2026/11/13/#lnd-11481
[news432 testnet5]: /fr/newsletters/2026/11/20/#bips-2356
[news262 clnrest]: /fr/newsletters/2023/08/02/#core-lightning-6389
