---
title: 'Bulletin Hebdomadaire Bitcoin Optech #337'
permalink: /fr/newsletters/2025/01/17/
name: 2025-01-17-newsletter-fr
slug: 2025-01-17-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume la discussion continue sur la récompense des mineurs de pool
avec des parts d'ecash échangeables et décrit une nouvelle proposition pour permettre la résolution
offchain des DLC. Sont également incluses nos sections régulières
annoncant des mises à jour et des versions candidates, et résumant les changements notables
dans les principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Discussion continue sur la récompense des mineurs de pool avec des parts d'ecash échangeables :**
  La [discussion][ecash tides] s'est poursuivie depuis notre [résumé précédent][news304 ecashtides]
  d'un fil de discussion sur Delving Bitcoin concernant le paiement des [mineurs de pool][topic pooled
  mining] avec de l'ecash pour chaque part qu'ils soumettent. Auparavant, Matt Corallo [avait
  demandé][corallo whyecash] pourquoi un pool mettrait en œuvre le code supplémentaire et la
  comptabilité nécessaires pour gérer des parts d'ecash échangeables lorsqu'ils pourraient simplement
  payer les mineurs en utilisant une monnaie ecash normale (ou via LN). David Caseria [a
  répondu][caseria pplns] que dans certains schémas _pay per last N shares_ ([PPLNS][topic pplns]),
  tels que [TIDES][recap291 tides], un mineur pourrait devoir attendre que le pool trouve plusieurs
  blocs, ce qui pourrait prendre des jours ou des semaines pour un petit pool. Au lieu d'attendre, un
  mineur avec des parts d'ecash pourrait immédiatement les vendre sur un marché ouvert (sans divulguer
  au pool ou à un tiers quoi que ce soit sur leur identité, pas même une identité éphémère utilisée
  lors de l'exploitation minière).

  Caseria a également noté que les pools miniers existants trouvent financièrement difficile de
  soutenir le schéma _full paid per share_ ([FPPS][topic fpps]) où un mineur est payé
  proportionnellement à la récompense totale du bloc (subvention plus frais de transaction) lorsqu'ils
  créent une part. Il n'a pas élaboré, mais nous comprenons le problème comme étant la variance des
  frais obligeant les pools à conserver de grandes réserves. Par exemple, si un mineur de pool
  contrôle 1% de la puissance de hachage et crée des parts sur un modèle avec environ 1 000 BTC en
  frais et 3 BTC en subvention, il serait dû par son pool environ 10 BTC. Cependant, si le pool ne
  mine pas ce bloc et, lorsqu'ils minent un bloc, les frais sont de retour à une fraction de la
  récompense du bloc, le pool pourrait n'avoir que 3 BTC au total à répartir entre tous ses mineurs,
  l'obligeant à payer à partir de ses réserves. Si cela arrive trop souvent, les réserves du pool
  seront épuisées et il fera faillite. Les pools abordent ce problème de diverses manières, y compris
  en utilisant [des proxies pour les frais réels][news304 fpps proxy].

  Le développeur vnprc [a décrit][vnprc ehash] la solution qu'il a [développée][hashpool] qui se
  concentre sur les parts d'ecash reçues dans le schéma de paiement PPLNS. Il pense que cela pourrait
  être particulièrement utile pour lancer de nouveaux pools : actuellement, le premier mineur à
  rejoindre un pool subit la même haute variance que l'exploitation minière en solo, donc typiquement
  les seules personnes qui peuvent démarrer un pool sont les grands mineurs existants ou ceux prêts à
  louer une puissance de calcul (hashrate) significative. Cependant, avec les parts ecash PPLNS, vnprc
  pense qu'un pool pourrait se lancer en tant que client d'un pool plus grand, de sorte que même le
  premier mineur à rejoindre le nouveau pool recevrait une variance plus faible que celle du minage
  solo. Le pool intermédiaire pourrait alors vendre les parts ecash qu'il gagne pour financer le
  schéma de paiement qu'il choisit de payer à ses mineurs. Une fois que le pool intermédiaire a acquis
  une quantité significative de hashrate, il aurait également un levier pour négocier avec les pools
  plus grands sur la création de modèles de blocs alternatifs qui conviennent à ses mineurs.

- **DLC offchain :** un développeur a [publié][conduition offchain] sur la liste de diffusion
  DLC-dev à propos d'un protocole de contrat qui permet une dépense offchain de la transaction de
  financement signée par les deux parties pour créer plusieurs [DLCs][topic dlc]. Après que le DLC
  offchain a été réglé (par exemple, toutes les signatures d'oracle requises ont été obtenues), une
  nouvelle dépense offchain peut être signée par les deux parties pour réallouer les fonds selon la
  résolution du contrat. Une troisième dépense alternative peut ensuite allouer les fonds à de
  nouveaux DLCs.

  Les réponses de Kulpreet Singh et Philipp Hoenisch ont fait référence à des recherches et
  développements antérieurs de cette idée de base, y compris des approches qui permettent d'utiliser
  le même pool de fonds à la fois pour les DLCs offchain et pour LN (voir les Bulletins
  [#174][news174 dlc-ln] et [#260][news260 dlc]). Une [réponse][conduition offchain2] de conduition a
  décrit la principale différence de sa proposition par rapport aux propositions précédentes.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates._

- [LDK v0.1][] est une sortie importante de cette bibliothèque pour la construction de portefeuilles
  et d'applications compatibles LN. Les nouvelles fonctionnalités incluent "le support pour les deux
  côtés des protocoles de négociation d'ouverture de canal LSPS, [...] inclut le support pour la
  résolution de noms lisibles par l'homme [BIP353][], [et une réduction des] coûts de frais onchain
  lors de la résolution de plusieurs HTLCs pour une fermeture forcée de canal."

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core
lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust
Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Propositions
d'Amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips
repo], [Inquisition Bitcoin][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Eclair #2936][] introduit un délai de 12 blocs avant de marquer un canal comme fermé après que sa
  sortie de financement a été dépensée pour permettre la propagation d'une mise à jour [splice][topic
  splicing] (voir le Bulletin [#214][news214 splicing] et la description de la motivation par un
  développeur d'Eclair [tbast splice]). Les canaux dépensés sont temporairement suivis dans une
  nouvelle carte `spentChannels`, où ils sont soit retirés après 12 blocs, soit mis à jour en tant que
  canaux épissés. Lorsqu'une épissure se produit, l'identifiant court du canal parent (SCID), la capacité
  et les limites de solde sont mis à jour au lieu de créer un nouveau canal.

- [Rust Bitcoin #3792][] ajoute la capacité d'encoder et de décoder les messages de transport P2P v2
  de [BIP324][] (voir le Bulletin [#306][news306 v2]). Cela est réalisé en ajoutant une structure
  `V2NetworkMessage`, qui enveloppe l'énumération originale `NetworkMessage` et fournit l'encodage et
  le décodage v2.

- [BDK #1789][] met à jour la version de transaction par défaut de 1 à 2 pour améliorer la
  confidentialité du portefeuille. Avant cela, les portefeuilles BDK étaient plus identifiables du
  fait que seulement 15% du réseau utilisait la version 1. De plus, la version 2 est requise pour une
  future mise en œuvre du mécanisme anti fee sniping basé sur nSequence de [BIP326][] pour les
  transactions [taproot][topic taproot].

- [BIPs #1687][] fusionne [BIP375][] pour spécifier l'envoi de [paiements silencieux][topic silent
  payments] en utilisant les [PSBTs][topic psbt]. S'il y a plusieurs signataires indépendants, une preuve
  [DLEQ][topic dleq] est requise pour permettre à tous les signataires de prouver aux co-signataires
  que leur signature ne dépense pas les fonds de manière abusive, sans révéler leur clé privée (voir
  le [Bulletin #335][news335 dleq] et le [Recap #327][recap327 dleq]).

- [BIPs #1396][] met à jour la spécification [payjoin][topic payjoin] de [BIP78][] pour s'aligner
  sur la spécification [PSBT][topic psbt] de [BIP174][], résolvant un conflit précédent. Dans BIP78,
  un receveur supprimait auparavant les données UTXO après avoir complété ses entrées, même si
  l'expéditeur avait besoin des données. Avec cette mise à jour, les données UTXO sont désormais
  conservées.

{% include snippets/recap-ad.md when="2025-01-21 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3792,1789,1687,1396,2936" %}
[ldk v0.1]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1
[news174 dlc-ln]: /en/newsletters/2021/11/10/#dlcs-over-ln
[news260 dlc]: /fr/newsletters/2023/07/19/#le-portefeuille-10101-beta-teste-la-mise-en-commun-des-fonds-entre-les-ln-et-les-dlc
[ecash tides]: https://delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870
[news304 ecashtides]: /fr/newsletters/2024/05/24/#defis-dans-la-recompense-des-mineurs-de-pool
[corallo whyecash]: https://delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870/27
[caseria pplns]: https://delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870/29
[recap291 tides]: /en/podcast/2024/02/29/#how-does-ocean-s-tides-payout-scheme-work-transcript
[vnprc ehash]: https://delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870/32
[hashpool]: https://github.com/vnprc/hashpool
[conduition offchain]: https://mailmanlists.org/pipermail/dlc-dev/2025-January/000186.html
[news304 fpps proxy]: /fr/newsletters/2024/05/24/#pay-per-share-pps
[tbast splice]: https://github.com/ACINQ/eclair/pull/2936#issuecomment-2595930679
[conduition offchain2]: https://mailmanlists.org/pipermail/dlc-dev/2025-January/000189.html
[news214 splicing]: /en/newsletters/2022/08/24/#bolts-1004
[news306 v2]: /fr/newsletters/2024/06/07/#rust-bitcoin-2644
[news335 dleq]: /fr/newsletters/2025/01/03/#bips-1689
[recap327 dleq]: /fr/podcast/2024/11/05/#draft-bip-for-dleq-proofs
