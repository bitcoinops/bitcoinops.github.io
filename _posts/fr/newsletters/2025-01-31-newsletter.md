---
title: 'Bulletin Hebdomadaire Bitcoin Optech #339'
permalink: /fr/newsletters/2025/01/31/
name: 2025-01-31-newsletter-fr
slug: 2025-01-31-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit une vulnérabilité affectant les anciennes versions de LDK,
examine un aspect nouvellement révélé d'une vulnérabilité initialement publiée en 2023, et résume la
discussion renouvelée sur les statistiques de reconstruction de blocs compacts.
Sont également incluses nos rubriques habituelles avec des questions et réponses populaires
de la communauté Bitcoin Stack Exchange, des annonces de nouvelles versions et de
versions candidates, ainsi que les changements apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Vulnérabilité dans le traitement des réclamations LDK :** Matt Morehouse a [publié][morehouse
  ldkclaim] sur Delving Bitcoin pour divulguer une vulnérabilité affectant LDK qu'il a [divulguée de
  manière responsable][topic responsible disclosures] et qui a été corrigée dans la version 0.1 de
  LDK. Lorsqu'un canal est fermé unilatéralement avec plusieurs [HTLCs][topic htlc] en attente, LDK
  tentera de résoudre autant de HTLCs que possible dans la même transaction pour économiser sur les
  frais de transaction. Cependant, si la contrepartie du canal parvient à confirmer l'un des HTLCs
  groupés en premier, cela _entrera en conflit_ avec la transaction groupée et la rendra invalide.
  Dans ce cas, LDK créerait correctement une transaction groupée mise à jour avec le conflit supprimé.
  Malheureusement, si la transaction de la contrepartie entre en conflit avec plusieurs lots séparés,
  LDK mettrait à jour incorrectement seulement le premier lot. Les lots restants ne pourraient pas
  être confirmés.

  Les nœuds doivent résoudre leurs HTLCs avant une date limite, sinon la contrepartie peut récupérer
  ses fonds. Un [timelock][topic timelocks] empêche la contrepartie de dépenser les HTLCs avant leurs
  échéances individuelles. La plupart des anciennes versions de LDK plaçaient ces HTLCs dans un lot
  séparé qu'elles s'assuraient de confirmer avant que la contrepartie puisse confirmer une transaction
  en conflit, garantissant qu'aucun fonds ne pouvait être volé. Pour les HTLCs qui ne permettaient pas
  le vol de fonds, mais que la contrepartie pouvait résoudre immédiatement, il y avait un risque que
  la contrepartie puisse causer le blocage des fonds. Morehouse écrit que cela peut être corrigé en
  "passant à la version 0.1 de LDK et en rejouant la séquence de transactions d'engagement et de HTLC
  qui ont conduit au blocage."

  Cependant, le candidat à la version LDK 0.1-beta a changé sa logique (voir le [Bulletin #335][news335
  ldk3340]) et a commencé à regrouper tous les types de HTLCs ensemble, ce qui pourrait permettre à un
  attaquant de créer un conflit avec un HTLC à timelock. Si la résolution de ce HTLC restait bloquée
  après l'expiration du timelock, un vol était possible. Passer à la version de sortie de LDK 0.1
  corrige également cette forme de vulnérabilité.

  Le post de Morehouse fournit des détails supplémentaires et discute des moyens possibles de prévenir
  les futures vulnérabilités découlant de la même cause racine.

- **Attaques de remplacement cyclique avec exploitation des mineurs :** Antoine Riard a
  [publié][riard minecycle] sur la liste de diffusion Bitcoin-Dev pour divulguer une vulnérabilité
  supplémentaire possible avec l'attaque de [remplacement cyclique][topic replacement cycling] qu'il
  avait initialement rendue publique et divulgué en 2023 (voir le [Bulletin #274][news274 cycle]).
  En bref :

  1. Bob diffuse une transaction payant Mallory (et possiblement d'autres
     personnes).

  2. Mallory [bloque][topic transaction pinning] la transaction de Bob.

  3. Bob ne réalise pas qu'il a été bloqué et augmente les frais (en utilisant
     soit [RBF][topic rbf] soit [CPFP][topic cpfp]).

  4. Comme la transaction originale de Bob a été bloquée, son augmentation de frais
     ne se propage pas. Cependant, Mallory la reçoit d'une manière ou d'une autre. Les étapes 3
     et 4 peuvent se répéter plusieurs fois pour
     augmenter considérablement les frais de Bob.

  5. Mallory mine l'augmentation de frais la plus élevée de Bob, que personne d'autre n'essaie
     de miner parce qu'elle ne s'est pas propagée. Cela permet à Mallory de gagner
     plus de frais que les autres mineurs.

  6. Mallory peut maintenant utiliser le remplacement cyclique pour déplacer son blocage de
     transaction vers une autre transaction et répéter l'attaque (éventuellement avec une
     victime différente) sans allouer de fonds supplémentaires, rendant l'attaque économiquement
     efficace.

  Nous ne considérons pas la vulnérabilité comme un risque significatif.
  Exploiter la vulnérabilité nécessite des circonstances spécifiques qui
  pourraient être rares et peuvent entraîner une perte d'argent pour l'attaquant s'ils évaluent mal
  les conditions du réseau. Si un attaquant exploitait régulièrement
  la vulnérabilité, nous croyons que leur comportement serait détecté
  par les membres de la communauté qui construisent et utilisent des [outils de surveillance
  de blocs][miningpool.observer].

- **Statistiques mises à jour sur la reconstruction de blocs compacts :** faisant suite à un
  fil de discussion précédent (voir le [Bulletin #315][news315 cb]), le développeur 0xB10C
  a [publié][b10c cb] sur Delving Bitcoin des statistiques mises à jour sur la fréquence à
  laquelle ses nœuds Bitcoin Core devaient demander des transactions supplémentaires
  pour effectuer la reconstruction de [blocs compacts][topic compact block relay].
  Lorsqu'un nœud reçoit un bloc compact, il doit demander
  toute transaction dans ce bloc qu'il n'a pas déjà dans son mempool (ou dans son _extrapool_, qui est
  une réserve spéciale visant
  à aider à la reconstruction de blocs compacts). Cela ralentit considérablement
  la vitesse de propagation des blocs et contribue à la centralisation des mineurs.

  0xB10C a constaté que la fréquence des demandes augmentait significativement à mesure
  que la taille du mempool augmentait. Plusieurs développeurs ont discuté des causes possibles, avec
  des données initiales indiquant que les transactions manquantes
  étaient des _orphelines_--- des transactions enfants de parents inconnus, que Bitcoin
  Core ne stocke que brièvement au cas où leurs parents arriveraient dans un
  court délai. Un meilleur suivi et une demande des parents de transactions orphelines, récemment
  intégrés à Bitcoin Core (voir le [Bulletin #338][news338 orphan]), pourraient aider à améliorer cette situation.

  Les développeurs ont également discuté d'autres solutions possibles. Les nœuds
  ne peuvent pas raisonnablement conserver les transactions orphelines pendant longtemps car un
  attaquant peut les créer gratuitement---mais il pourrait être possible de persister
  un plus grand nombre d'entre elles et d'autres transactions évincées plus longtemps dans
  l'extrapool. La discussion était non concluante au moment de la rédaction.

## Questions et réponses sélectionnées de Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech
cherchent des réponses à leurs questions---ou quand nous avons quelques moments libres pour aider
les utilisateurs curieux ou confus. Dans
cette rubrique mensuelle, nous mettons en lumière certaines des questions et
réponses les plus votées postées depuis notre dernière mise à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Qui utilise ou souhaite utiliser PSBTv2 (BIP370) ?]({{bse}}125384)
  En plus de publier sur la liste de diffusion Bitcoin-Dev (voir le [Bulletin #338][news338 psbtv2]),
  Sjors Provoost a posté sur le Bitcoin Stack Exchange
  à la recherche d'utilisateurs et de potentiels utilisateurs de [PSBTv2][topic psbt]. Les lecteurs
  d'Optech intéressés par [BIP370][] devraient répondre à la question ou au post de la liste de diffusion.

- [Dans le bloc genesis de bitcoin, quelles parties peuvent être remplies arbitrairement ?]({{bse}}125274)
  Pieter Wuille souligne qu'aucun des champs du [bloc genesis][mempool
  genesis block] de Bitcoin n'est soumis aux règles normales de validation des blocs, disant,
  "Littéralement, tous auraient pu avoir n'importe quel contenu. Il ressemble à un bloc
  normal autant que possible, mais cela n'était pas nécessaire".

- [Détection de fermeture forcée de Lightning]({{bse}}122504)
  Sanket1729 et Antoine Poinsot discutent de comment l'explorateur de blocs mempool.space utilise les
  champs [`nLockTime`][topic timelocks] et `nSequence` pour déterminer
  si une transaction est une transaction de fermeture forcée de Lightning.

- [Une transaction formatée segwit avec tous les inputs de type de programme non-témoin est-elle valide ?]({{bse}}125240)
  Pieter Wuille fait la distinction entre [BIP141][], qui spécifie la structure
  et la validité autour des changements de consensus segwit et le calcul des wtxids, et [BIP144][],
  qui spécifie le format de sérialisation pour communiquer les transactions segwit.

- [Question de sécurité P2TR]({{bse}}125334)
  Pieter Wuille cite [BIP341][] qui spécifie [taproot][topic taproot]
  pour expliquer pourquoi une clé publique est directement incluse dans une sortie, et
  les considérations liées au calcul quantique.

- [Qu'est-ce qui est exactement fait aujourd'hui pour rendre Bitcoin "quantum-safe" ?]({{bse}}125171)
  Murch commente l'état actuel des capacités quantiques, les récents
  [schémas de signature post-quantique][topic quantum resistance], et le BIP proposé [QuBit -
  Pay to Quantum Resistant Hash][BIPs #1670].

- [Quels sont les effets néfastes d'un temps inter-bloc plus court ?]({{bse}}125318)
  Pieter Wuille met en évidence l'avantage conféré, en raison du temps de propagation des blocs, à un
  mineur qui vient de trouver un bloc, comment cet avantage est
  amplifié avec des temps de bloc plus courts, et les effets potentiels de cet avantage.

- [Le proof-of-work pourrait-il être utilisé pour remplacer les règles de politique ?]({{bse}}124931)
  Jgmontoya se demande si attacher un proof-of-work aux transactions non standard
  pourrait atteindre des objectifs similaires de [protection des ressources des nœuds][policy series]
  comme la politique de mempool. Antoine Poinsot souligne qu'il y a d'autres objectifs de
  la politique de mempool au-delà de la protection des ressources des nœuds incluant la construction
  efficace de modèles de blocs, décourageant certains types de transactions, et protégeant les
  crochets de mise à niveau de [soft fork][topic soft fork activation].

- [Comment fonctionne MuSig dans les scénarios Bitcoin réels ?]({{bse}}125030)
  Pieter Wuille explique les différences entre les versions de [MuSig][topic musig], mentionne la
  variante de Signature Agrégée Interactive (IAS) de MuSig1 et son interaction avec l'agrégation de
  signature inter-entrées ([CISA][topic cisa]), et parle des [signatures seuil][topic threshold
  signature] avant de répondre à des questions plus détaillées sur les spécifications.

- [Comment fonctionne l'interrupteur -blocksxor qui obscurcit les fichiers blocks.dat ?]({{bse}}125055)
  Vojtěch Strnad décrit l'option `-blocksxor` pour obscurcir les fichiers de données de blocs de
  Bitcoin Core sur le disque (voir le [Bulletin #316][news316 xor]).

- [Comment fonctionne l'attaque par clé associée sur les signatures Schnorr ?]({{bse}}125328)
  Pieter Wuille répond que "l'attaque s'applique lorsque la victime choisit une clé associée, et que
  l'attaquant connaît la relation" et que les clés associées sont extrêmement courantes.

## Mises à jour et versions candidates

_Nouvelles mises à jour et versions candidates à la sortie pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de passer aux nouvelles versions ou d'aider à tester
les versions candidates._

- [LDK v0.1.1][] est une version de sécurité de cette bibliothèque populaire pour la création
  d'applications compatibles LN. Un attaquant prêt à sacrifier au moins 1% des fonds du canal pourrait
  tromper la victime en la poussant à fermer d'autres canaux non liés, ce qui pourrait amener la
  victime à dépenser inutilement de l'argent en frais de transaction. Matt Morehouse, qui a découvert
  la vulnérabilité, a [publié][morehouse ldk-dos] à ce sujet sur Delving Bitcoin; Optech fournira un
  résumé plus détaillé dans le bulletin de la semaine prochaine. La version inclut également des
  mises à jour de l'API et des corrections de bugs.

## Changements de code et de documentation notables

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration de Bitcoin (BIPs)][bips
repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Inquisition Bitcoin][bitcoin
inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #31376][] étend une vérification qui empêche les mineurs de créer des modèles de
  blocs exploitant le bug [timewarp][topic time warp] pour s'appliquer à tous les réseaux, pas
  seulement [testnet4][topic testnet]. Ce changement est en préparation pour un éventuel futur soft
  fork qui corrigerait définitivement le bug timewarp.

- [Bitcoin Core #31583][] met à jour les commandes RPC `getmininginfo`, `getblock`,
  `getblockheader`, `getblockchaininfo` et `getchainstates` pour désormais retourner un champ `nBits`
  (la représentation compacte de la cible de difficulté du bloc) et un champ `target`. De plus,
  `getmininginfo` ajoute un objet `next` qui spécifie la hauteur, `nBits`, la difficulté et la cible
  pour le prochain bloc. Pour dériver et obtenir la cible, ce PR introduit le
  `DeriveTarget()` et les fonctions d'aide `GetTarget()`. Ces changements sont utiles pour la mise en
  œuvre du [Stratum V2][topic pooled mining].

- [Bitcoin Core #31590][] refactorise la méthode `GetPrivKey()` pour vérifier les pubkeys pour les
  deux valeurs de bit de parité lors de la récupération des clés privées pour un [x-only pubkey][topic
  x-only public keys] dans un [descriptor][topic descriptors]. Auparavant, si le pubkey stocké n'avait
  pas le bit de parité correct, la clé privée ne pouvait pas être récupérée et les transactions ne
  pouvaient pas être signées.

- [Eclair #2982][] introduit le paramètre de configuration `lock-utxos-during-funding`, permettant
  aux vendeurs de [publicité de liquidité][topic liquidity advertisements] d'atténuer une attaque de
  griefing de liquidité qui pourrait empêcher les utilisateurs honnêtes d'utiliser leurs UTXOs pendant
  de longues périodes. Le paramètre par défaut est vrai, signifiant que les UTXOs sont verrouillés
  pendant le processus de financement et sont vulnérables à l'abus. Si réglé sur faux, le verrouillage
  des UTXO est désactivé et l'attaque peut être complètement prévenue, mais cela peut affecter
  négativement les pairs honnêtes. Cette PR ajoute également un mécanisme de délai configurable qui
  interrompt automatiquement les canaux entrants si un pair devient non réactif.

- [BDK #1614][] ajoute le support pour l'utilisation des [filtres de blocs compacts][topic compact
  block filters] tel que spécifié dans [BIP158][] pour télécharger les transactions confirmées. Cela
  est réalisé en ajoutant un module BIP158 au paquet `bdk_bitcoind_rpc`, ainsi qu'un nouveau type
  `FilterIter` qui peut être utilisé pour récupérer les blocs contenant des transactions pertinentes à
  une liste de script pubkeys.

- [BOLTs #1110][] fusionne la spécification pour le protocole de [stockage par pair][topic peer
  storage], qui permet aux nœuds de stocker des blobs cryptés jusqu'à 64kB pour les pairs qui les
  demandent, et de facturer pour ce service. Cela a déjà été implémenté dans Core Lightning (voir le
  bulletin [#238][news238 peer]) et Eclair (voir le bulletin [#335][news335 peer]).

{% include snippets/recap-ad.md when="2025-02-04 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31376,31583,31590,2982,1614,1110,1670" %}
[morehouse ldkclaim]: https://delvingbitcoin.org/t/disclosure-ldk-invalid-claims-liquidity-griefing/1400
[news335 ldk3340]: /fr/newsletters/2025/01/03/#ldk-3340
[riard minecycle]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CALZpt+EnDUtfty3X=u2-2c5Q53Guc6aRdx0Z4D75D50ZXjsu2A@mail.gmail.com/
[miningpool.observer]: https://miningpool.observer/template-and-block
[b10c cb]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/5
[news315 cb]: /fr/newsletters/2024/08/09/#statistiques-sur-la-reconstruction-de-blocs-compacts
[news338 orphan]: /fr/newsletters/2025/01/24/#bitcoin-core-31397
[news274 cycle]: /fr/newsletters/2023/10/25/#vulnerabilite-de-remplacement-cyclique-contre-les-htlc
[ldk v0.1.1]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.1
[morehouse ldk-dos]: https://delvingbitcoin.org/t/disclosure-ldk-duplicate-htlc-force-close-griefing/1410
[news281 griefing]: /fr/newsletters/2023/12/13/#discussion-sur-le-griefing-des-annonces-de-liquidite
[news238 peer]: /fr/newsletters/2023/02/15/#core-lightning-5361
[news335 peer]: /fr/newsletters/2025/01/03/#eclair-2888
[news338 psbtv2]: /fr/newsletters/2025/01/24/#tests-d-integration-psbtv2
[mempool genesis block]: https://mempool.space/block/000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f
[policy series]: /fr/blog/waiting-for-confirmation/#ressources-du-réseau
[news316 xor]: /fr/newsletters/2024/08/16/#bitcoin-core-28052
