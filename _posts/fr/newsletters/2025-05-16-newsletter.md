---
title: 'Bulletin Hebdomadaire Bitcoin Optech #354'
permalink: /fr/newsletters/2025/05/16/
name: 2025-05-16-newsletter-fr
slug: 2025-05-16-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit une vulnérabilité corrigée affectant les anciennes versions de
Bitcoin Core. Sont également incluses nos sections régulières résumant les récentes discussions sur
la modification des règles de consensus de Bitcoin, annonçant des mises à jour et des versions candidates,
et décrivant les changements notables dans les projets d'infrastructure Bitcoin populaires.

## Nouvelles

- **Divulgation de vulnérabilité affectant les anciennes versions de Bitcoin Core :**
  Antoine Poinsot a [publié][poinsot addrvuln] sur la liste de diffusion Bitcoin-Dev pour annoncer une
  vulnérabilité affectant les versions de Bitcoin Core antérieures à 29.0. La vulnérabilité a été
  initialement [divulguée de manière responsable][topic responsible disclosures] par Eugene Siegel
  avec une autre vulnérabilité étroitement liée décrite dans le [Bulletin #314][news314 excess
  addr]. Un attaquant pourrait envoyer un nombre excessif d'avertissement d'adresse de nœud pour forcer un
  identifiant 32 bits à déborder, entraînant un crash du nœud. Cela a été partiellement atténué en
  limitant le nombre de mises à jour à une par pair toutes les dix secondes, ce qui, pour la limite
  par défaut d'environ 125 pairs, empêcherait le débordement à moins que le nœud ne soit
  continuellement attaqué pendant plus de 10 ans. La vulnérabilité a été complètement corrigée en
  utilisant des identifiants 64 bits, à partir de la version de Bitcoin Core 29.0 sortie le mois
  dernier.

## Changement de consensus

_Une section mensuelle résumant les propositions et discussions sur le changement des règles de
consensus de Bitcoin._

- **Proposition de BIP pour l'arithmétique 64 bits dans Script :** Chris Stewart a [publié][stewart
  bippost] un [projet de BIP][64bit bip] sur la liste de diffusion Bitcoin-Dev qui propose de mettre à
  niveau les opcodes existants de Bitcoin pour opérer sur des valeurs numériques 64 bits. Cela fait
  suite à ses recherches précédentes (voir les Bulletins [#285][news285 64bit], [#290][news290
  64bit], et [#306][news306 64bit]). Dans un changement par rapport à certaines des discussions
  précédentes, la nouvelle proposition utilise des nombres dans le même format de données compactSize
  actuellement utilisé dans Bitcoin. Des [discussions][stewart inout] connexes supplémentaires ont eu
  lieu dans deux [fils][stewart overflow] sur Delving Bitcoin.

- **Opcodes proposés pour permettre les covenants récursifs via des quines :** Bram Cohen a
  [posté][cohen quine] sur Delving Bitcoin pour suggérer un ensemble d'opcodes simples qui
  permettraient la création de [covenants][topic covenants] récursifs via des scripts
  s'autoreproduisant ([quines][]). Cohen décrit comment les opcodes pourraient être utilisés pour
  créer un [coffre-fort][topic vaults] simple et mentionne un système plus avancé sur lequel il
  travaille.

- **Description des avantages pour BitVM de `OP_CTV` et `OP_CSFS` :** Robin Linus a [posté][linus
  bitvm-sf] sur Delving Bitcoin à propos de plusieurs des améliorations à [BitVM][topic acc] qui
  deviendraient possibles si les [OP_CTV][topic op_checktemplateverify] et [OP_CSFS][topic
  op_checksigfromstack] étaient ajoutés à Bitcoin lors d'un soft fork. Les avantages
  qu'il décrit incluent l'augmentation du nombre d'opérateurs sans inconvénients, "réduisant la taille
  des transactions d'environ 10x" (ce qui réduit les coûts dans le pire des cas), et permettant des
  peg-ins non interactifs pour certains contrats.

## Mises à jour et versions candidates

_Nouvelles sorties et candidats à la sortie pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de passer aux nouvelles sorties ou d'aider à tester les candidats à la sortie._

- [LND 0.19.0-beta.rc4][] est un candidat à la sortie pour ce nœud LN populaire. L'une des
  principales améliorations qui pourrait probablement nécessiter des tests est le nouveau bumping de
  frais basé sur RBF pour les fermetures coopératives.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo],
[Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin
inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #32155][] met à jour le mineur interne pour un [blocage temporel][topic timelocks] des
  transactions coinbase en réglant le champ `nLockTime` à la hauteur du bloc actuel moins un et en
  exigeant que le champ `nSequence` ne soit pas final (pour faire respecter le timelock). Bien que le
  mineur intégré ne soit généralement pas utilisé sur le mainnet, sa mise à jour encourage les pools
  de minage à adopter ces changements tôt dans leur propre logiciel en préparation pour le soft fork
  de [nettoyage du consensus][topic consensus cleanup] proposé dans [BIP54][]. Le timelock des
  transactions coinbase résout la vulnérabilité des [transactions dupliquées][topic duplicate
  transactions] et permettrait de lever les vérifications coûteuses de [BIP30][].

- [Bitcoin Core #28710][] supprime le reste du code, de la documentation et des tests du
  portefeuille legacy. Cela inclut les RPCs uniquement legacy, tels que `importmulti`, `sethdseed`,
  `addmultisigaddress`, `importaddress`, `importpubkey`, `dumpwallet`, `importwallet`, et
  `newkeypool`. Comme dernière étape pour la suppression du portefeuille legacy, la dépendance à
  BerkeleyDB et les fonctions associées sont également supprimées. Cependant, le strict minimum du
  code legacy et un parser BDB indépendant (voir le Bulletin [#305][news305 bdb]) sont conservés afin
  de réaliser la migration du portefeuille vers les portefeuilles avec [descripteurs][topic descriptors].

- [Core Lightning #8272][] désactive la recherche de pairs de secours par DNS seed du daemon de
  connexion `connectd` pour résoudre les problèmes de blocage d'appel causés par des DNS seeds hors
  ligne.

- [LND #8330][] ajoute une petite constante (1/c) au modèle de probabilité bimodal de recherche de
  chemin pour aborder l'instabilité numérique. Dans les cas limites où le calcul échouerait autrement
  en raison d'erreurs d'arrondi et produirait une probabilité nulle, cette régularisation fournit une
  solution de repli en faisant revenir le modèle à une distribution uniforme. Cela résout les bugs de
  normalisation qui se produisent dans des scénarios impliquant de très grands canaux ou des canaux qui
  ne correspondent pas à une distribution bimodale. De plus, le modèle évite désormais les calculs de
  probabilité inutiles et corrige automatiquement les observations de liquidité de canal obsolètes et
  les informations historiques contradictoires.

- [Rust Bitcoin #4458][] remplace la structure `MtpAndHeight` par une paire explicite du `BlockMtp`
  nouvellement ajouté et du `BlockHeight` déjà existant, permettant une meilleure modélisation de la
  hauteur de bloc et des valeurs de Median Time Past (MTP) dans les [timelocks][topic timelocks]
  relatifs. Contrairement à `locktime::absolute::MedianTimePast`, qui est limité à des valeurs
  supérieures à 500 millions (approximativement après 1985), `BlockMtp` peut représenter n'importe
  quel timestamp 32 bits. Cela le rend adapté pour des cas limites théoriques, tels que des chaînes
  avec des timestamps inhabituels. Cette mise à jour introduit également `BlockMtpInterval`, et
  renomme `BlockInterval` en `BlockHeightInterval`.

- [BIPs #1848][] met à jour le statut de [BIP345][] en `Withdrawn`, car l'auteur [croit][obeirne
  vaultwithdraw] que son opcode `OP_VAULT` proposé a été supplanté par
  [`OP_CHECKCONTRACTVERIFY`][topic matt] (OP_CCV), un design de [vault][topic vaults] plus général et
  un nouveau type de [covenant][topic covenants].

- [BIPs #1841][] fusionne [BIP172][], qui propose de définir formellement l'unité de base
  indivisible de Bitcoin comme un “satoshi”, reflétant l'usage répandu actuel et aidant à standardiser
  la terminologie à travers les applications et la documentation.

- [BIPs #1821][] fusionne [BIP177][], qui propose de redéfinir “bitcoin” pour représenter l'unité
  indivisible la plus petite (communément appelée 1 satoshi), plutôt que 100 000 000 unités. La
  proposition argue que l'alignement de la terminologie avec l'unité de base réelle réduirait la
  confusion causée par les conventions décimales arbitraires.

{% include snippets/recap-ad.md when="2025-05-20 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32155,28710,8272,8330,4458,1848,1841,1821" %}
[lnd 0.19.0-beta.rc4]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc4
[news314 excess addr]: /fr/newsletters/2024/08/02/#crash-a-distance-en-envoyant-des-messages-addr-excessifs
[stewart bippost]: https://groups.google.com/g/bitcoindev/c/j1zEky-3QEE
[64bit bip]: https://github.com/Christewart/bips/blob/2025-03-17-64bit-pt2/bip-XXXX.mediawiki
[news285 64bit]: /fr/newsletters/2024/01/17/#proposition-de-soft-fork-pour-l-arithmetique-sur-64-bits
[news290 64bit]: /fr/newsletters/2024/02/21/#discussion-continue-sur-l-arithmetique-64-bits-et-l-opcode-op-inout-amount
[news306 64bit]: /fr/newsletters/2024/06/07/#mises-a-jour-de-la-proposition-de-soft-fork-pour-l-arithmetique-64-bits
[stewart inout]: https://delvingbitcoin.org/t/op-inout-amount/549/4
[stewart overflow]: https://delvingbitcoin.org/t/overflow-handling-in-script/1549
[poinsot addrvuln]: https://mailing-list.bitcoindevs.xyz/bitcoindev/EYvwAFPNEfsQ8cVwiK-8v6ovJU43Vy-ylARiDQ_1XBXAgg_ZqWIpB6m51fAIRtI-rfTmMGvGLrOe5Utl5y9uaHySELpya2ojC7yGsXnP90s=@protonmail.com/
[cohen quine]: https://delvingbitcoin.org/t/a-simple-approach-to-allowing-recursive-covenants-by-enabling-quines/1655/
[linus bitvm-sf]: https://delvingbitcoin.org/t/how-ctv-csfs-improves-bitvm-bridges/1591/
[quines]: https://en.wikipedia.org/wiki/Quine_(computing)
[news305 bdb]: /fr/newsletters/2024/05/31/#bitcoin-core-26606
[obeirne vaultwithdraw]: https://delvingbitcoin.org/t/withdrawing-op-vault-bip-345/1670/
