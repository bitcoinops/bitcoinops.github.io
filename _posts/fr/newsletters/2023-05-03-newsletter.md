---
title: 'Bulletin Hebdomadaire Bitcoin Optech #249'
permalink: /fr/newsletters/2023/05/03/
name: 2023-05-03-newsletter-fr
slug: 2023-05-03-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume une analyse de l'utilisation d'une
conception de dépense flexible (covenant) pour réimplémenter la proposition `OP_VAULT`,
résume un post sur la sécurité des adaptateurs de signature, et relaie une
annonce d'emploi qui pourrait être particulièrement intéressante pour
certains lecteurs. Vous y trouverez également nos sections régulières
décrivant les nouvelles versions, les versions candidates et les changements
notables apportés aux logiciels d'infrastructure Bitcoin les plus répandus.

## Nouvelles

- **Coffres-forts basés sur MATT :** Salvatore Ingala [a posté][ingala vaults]
  sur la liste de diffusion Bitcoin-Dev une implémentation approximative d'un
  [coffre-fort][topic vaults] avec un comportement similaire aux récentes
  propositions OP_VAULT (voir [Newsletter #234][news234 op_vault]) mais qui
  est plutôt basé sur la proposition Merklize All The Things (MATT) d'Ingala
  (voir [Newsletter #226][news226 matt]). MATT permettrait la création de
  contrats très flexibles sur Bitcoin grâce à l'embranchement convergent de
  quelques opcodes [covenant][topic covenants] très simples.

    Dans le billet de cette semaine, Ingala a cherché à démontrer que MATT
    ne serait pas seulement très flexible, mais qu'il serait également efficace
    et facile à utiliser dans les modèles de transaction qui pourraient un
    jour être utilisés fréquemment. Comme dans les versions récentes de la
    proposition `OP_VAULT`, Ingala s'appuie sur la proposition [BIP119][]
    pour [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV). En
    utilisant deux opcodes supplémentaires proposés (et en reconnaissant
    qu'ils ne couvrent pas entièrement tout ce qui est nécessaire), il
    fournit un ensemble de fonctionnalités qui est presque équivalent à
    `OP_VAULT`. La seule omission notable est "une option pour ajouter une
    sortie supplémentaire qui est renvoyée vers le même coffre-fort".

    À l'heure où nous écrivons ces lignes, le message d'Ingala n'a pas
    reçu de réponse directe, mais il y a eu une [discussion continue][halseth matt]
    sur sa proposition originale pour MATT et sa capacité à permettre
    la vérification de l'exécution d'un programme (essentiellement)
    arbitrairement complexe.

- **Analyse de la sécurité de l'adaptateur de signature :** Adam Gibson
  a [posté][gibson adaptors] sur la liste de diffusion Bitcoin-Dev une
  analyse de la sécurité des [adaptateurs de signature][topic adaptor signatures],
  en particulier sur la façon dont ils interagissent avec les protocoles
  [multisignature][topic multisignature] tels que [MuSig][topic musig]
  où plusieurs parties doivent travailler ensemble en toute confiance
  pour créer des adaptateurs. Il est prévu d'utiliser les adaptateurs
  de signature pour mettre à jour le LN à court terme afin d'utiliser
  les [PTLC][topic ptlc] pour améliorer l'efficacité et la confidentialité.
  Il est également prévu de les utiliser dans un certain nombre d'autres
  protocoles, principalement pour améliorer l'efficacité, la confidentialité
  ou les deux. Ils représentent l'un des éléments de base les plus puissants
  pour les protocoles nouveaux et améliorés de Bitcoin, de sorte qu'une
  analyse minutieuse de leurs propriétés de sécurité est essentielle pour
  s'assurer qu'ils sont utilisés correctement. Gibson s'appuie sur l'analyse
  précédente de Lloyd Fournier et d'autres (voir [Bulletin #129][news129 adaptors]),
  mais il note également les domaines qui nécessitent une analyse plus
  approfondie et demande une révision de ses propres contributions.

- **Opportunité d'emploi pour les champions de projets :** Steve Lee,
  de l'organisation Spiral qui accorde des subventions, a [posté][lee hiring]
  sur la liste de diffusion Bitcoin-Dev pour demander à des contributeurs
  Bitcoin très expérimentés de postuler à un poste rémunéré à temps plein
  pour défendre des projets inter-équipes qui apporteront des améliorations
  significatives à l'évolutivité, à la sécurité, à la confidentialité et
  à la flexibilité à long terme de Bitcoin. Voir son message pour plus
  de détails.

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets d’infrastructure
Bitcoin. Veuillez envisager de passer aux nouvelles versions ou d’aider à tester
les versions candidates.*

- [LND v0.16.2-beta][] est une version mineure de cette implémentation de LN
  qui inclut plusieurs corrections de bogues pour les "régressions de performance
  introduites dans la version mineure précédente".

- [Core Lightning 23.05rc2][] est une version candidate de la prochaine
  version de l'implémentation du LN.

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], et
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #25158][] ajoute un champ `abandoned` aux réponses
  détaillées des transactions des RPCs `gettransaction`, `listtransactions`,
  et `listsinceblock` indiquant quelles transactions ont été marquées comme
  [abandonnées][abandonransaction rpc].

- [Bitcoin Core #26933][] réintroduit l'exigence que chaque transaction
  respecte le taux de frais minimum de relais du nœud (`-minrelaytxfee`)
  afin d'être acceptée dans le mempool, même lorsqu'elle est évaluée en
  tant que paquet. La validation des paquets permet toujours de faire
  passer une transaction en dessous du feerate minimum dynamique du mempool.
  Cette politique a été réintroduite pour éviter le risque que des
  transactions à tarif zéro perdent leur descendant à tarif élevé dans
  le cas d'un remplacement. Elle pourra être inversée dans le futur si
  une méthode résistante aux DoS pour empêcher de telles transactions
  est trouvée, par exemple à travers une restriction de la topologie
  des paquets comme v3 ou une modification du processus d'éviction
  du mempool.

- [Bitcoin Core #25325][] introduit une ressource mémoire basée sur un
  pool pour le cache des UTXO. La nouvelle structure de données pré-attribue
  et gère un plus grand pool de mémoire pour suivre les UTXO au lieu d'allouer
  et de libérer de la mémoire pour chaque UTXO individuellement. Les
  consultations d'UTXO représentent une part importante des accès à la
  mémoire, en particulier pendant l'IBD. Les analyses comparatives indiquent
  que la réindexation est accélérée de plus de 20 % grâce à la gestion plus
  efficace de la mémoire.

- [Bitcoin Core #25939][] permet aux nœuds avec l'index de transaction
  optionnel activé de rechercher cet index lors de l'utilisation de la
  RPC `utxoupdatepsbt` pour mettre à jour un [PSBT][topic psbt] avec des
  informations sur les sorties de transaction qu'il dépense. Lorsque la
  RPC a été mise en œuvre pour la première fois en 2019 (voir [Bulletin #34][news34 psbt]),
  deux types de sorties étaient courants sur le réseau : les sorties legacy
  et les sorties segwit v0. Chaque dépense d'une sortie ancienne dans une
  PSBT doit inclure une copie complète de la transaction qui contenait
  cette sortie afin qu'un signataire puisse vérifier le montant de cette
  sortie. Créer une dépense sans vérifier le montant de la sortie dépensée
  peut conduire le dépenseur à surpayer massivement les frais de transaction,
  d'où l'importance de la vérification.

  Chaque dépense d'une sortie segwit v0 s'engage sur son montant afin
  de permettre aux PSBT d'inclure uniquement la clé scriptPubKey et le
  montant de la sortie plutôt que l'ensemble de la transaction précédente.
  On pensait ainsi éliminer la nécessité d'inclure la totalité de la
  transaction. Puisque chaque sortie de transaction non dépensée pour
  chaque transaction confirmée est stockée dans l'ensemble UTXO de Bitcoin
  Core, la RPC `utxoupdatepsbt` peut ajouter la clé de script et le montant
  nécessaires à n'importe quelle PSBT dépensant une UTXO. La RPC `utxoupdatepsbt`
  recherchait également auparavant des UTXO dans le mempool du nœud local
  pour permettre aux utilisateurs de dépenser les résultats de transactions
  non confirmées.

  Cependant, après que `utxoupdatepsbt` a été ajouté à Bitcoin Core, plusieurs
  dispositifs de signature matérielle ont commencé à exiger que même les spends
  des sorties segwit v0 incluent des transactions complètes afin d'éviter une
  variante de surpaiement de frais qui pourrait résulter d'un utilisateur signant
  apparemment deux fois la même transaction (voir [Bulletin #101][news101 overpayment]).
  Cela a renforcé la nécessité de pouvoir inclure des transactions complètes
  dans un PSBT.

  Ce PR fusionné recherchera dans l'index des transactions (s'il est activé)
  et dans le mempool du nœud local les transactions complètes, et les inclura
  dans le PSBT si nécessaire. Si une transaction complète n'est pas trouvée,
  l'ensemble UTXO sera utilisé pour les dépenses des sorties segwit. Notez
  que Taproot (segwit v1) élimine le problème de surpaiement pour la plupart
  ""des transactions qui dépensent au moins une sortie taproot, nous nous
  attendons donc à ce que les futures mises à jour des dispositifs de signature
  matérielle cessent d'exiger des transactions complètes dans ce cas.

- [LDK #2222][] permet de mettre à jour les informations relatives à un canal
  à l'aide d'un message transmis par les nœuds impliqués dans ce canal sans
  vérifier que le canal correspond à un UTXO. Les messages Gossip LN ne devraient
  être acceptés que s'ils appartiennent à un canal avec un UTXO prouvé car c'est
  l'une des façons dont LN est conçu pour prévenir les attaques par déni de
  service (DoS), mais certains nœuds LN n'auront pas la capacité de rechercher
  des UTXO et peuvent avoir d'autres méthodes pour prévenir les attaques par
  déni de service. Ce PR fusionné leur permet d'utiliser plus facilement les
  informations sans source de données UTXO.

- [LDK #2208][] ajoute la rediffusion des transactions et l'augmentation
  des frais pour les [HTLC][topic htlc] non résolus dans les canaux qui
  ont été fermés de force. Cela permet de remédier à certaines [attaques
  par épinglage][topic transaction pinning] et d'assurer la fiabilité.
  Voir également le [bulletin d'information n° 243][news243 rebroadcast] dans
  lequel LND a ajouté sa propre interface de rediffusion et le [bulletin
  d'information de la semaine dernière][news247 rebroadcast] dans lequel
  CLN a amélioré sa propre logique.

{% include references.md %}
{% include linkers/issues.md v=2 issues="25158,26933,25325,2222,2208,25939" %}
[Core Lightning 23.05rc2]: https://github.com/ElementsProject/lightning/releases/tag/v23.05rc2
[lnd v0.16.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.2-beta
[news101 overpayment]: /en/newsletters/2020/06/10/#fee-overpayment-attack-on-multi-input-segwit-transactions
[news129 adaptors]: /en/newsletters/2020/12/23/#ptlcs
[news243 rebroadcast]: /fr/newsletters/2023/03/22/#lnd-7448
[news247 rebroadcast]: /fr/newsletters/2023/04/19/#core-lightning-6120
[ingala vaults]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021588.html
[news226 matt]: /fr/newsletters/2022/11/16/#contrats-intelligents-generaux-en-bitcoin-via-des-clauses-restrictives
[news234 op_vault]: /fr/newsletters/2023/01/18/#proposition-de-nouveaux-opcodes-specifiques-aux-coffre-forts
[halseth matt]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021593.html
[gibson adaptors]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021594.html
[lee hiring]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021589.html
[news34 psbt]: /en/newsletters/2019/02/19/#bitcoin-core-13932
[abandontransaction rpc]: https://developer.bitcoin.org/reference/rpc/abandontransaction.html
