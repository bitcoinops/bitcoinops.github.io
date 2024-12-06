---
title: 'Bulletin Hebdomadaire Bitcoin Optech #332'
permalink: /fr/newsletters/2024/12/06/
name: 2024-12-06-newsletter-fr
slug: 2024-12-06-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine annonce la divulgation d'une vulnérabilité de censure de transaction
et résume les discussions concernant la proposition de soft fork de nettoyage du consensus. Sont
également incluses nos sections régulières avec
les annonces de nouvelles versions de logiciels et les descriptions des changements notables
apportés aux logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

- **Vulnérabilité de censure de transaction :** Antoine Riard a [posté][riard censor] sur la liste
  de diffusion Bitcoin-Dev à propos d'une méthode permettant d'empêcher un nœud de diffuser une
  transaction appartenant à un portefeuille connecté. Si le portefeuille connecté appartient au nœud
  LN de l'utilisateur, l'attaque peut être utilisée pour empêcher l'utilisateur de sécuriser les fonds
  qui lui sont dus avant l'expiration d'un délai, permettant ainsi à sa contrepartie de voler les
  fonds.

  Il existe deux versions de l'attaque, toutes deux tirant parti des limites au sein de Bitcoin Core
  liées au nombre maximum de transactions non confirmées qu'il diffusera ou acceptera dans un certain
  laps de temps. Ces limites l'empêchent de placer un fardeau excessif sur ses pairs ou d'être attaqué
  par déni de service.

  La première version de l'attaque, appelée _débordement élevé_ par Riard, tire parti du fait que
  Bitcoin Core ne diffuse qu'un maximum de 1 000 annonces de transactions non confirmées à la fois à
  ses pairs. Si plus de 1 000 transactions sont en file d'attente pour être transmises, les
  transactions avec le taux de frais le plus élevé sont annoncées en premier. Après avoir envoyé un
  lot d'annonces, Bitcoin Core attendra d'envoyer plus de transactions jusqu'à ce que son taux moyen
  récent d'annonces soit de sept transactions par seconde.

  Si les 1 000 annonces initiales paient un taux de frais plus élevé que la transaction que la victime
  souhaite diffuser, et si un attaquant continue d'envoyer au nœud victime au moins sept transactions
  par seconde au-dessus de ce taux de frais, l'attaquant peut empêcher la diffusion indéfiniment. La
  plupart des attaques sur LN nécessiteront de retarder la diffusion entre 32 blocs (défauts de Core
  Lightning) et 140 blocs (défauts d'Eclair), ce qui à 10 sats/vbyte coûterait entre 1,3 BTC (130 000
  USD) et 5,9 BTC (590 000 USD), bien que Riard note qu'un attaquant prudent, bien connecté à d'autres
  nœuds de relais (ou directement à de grands mineurs), pourrait être en mesure de réduire
  considérablement ces coûts.

  La seconde version de l'attaque, appelée _débordement faible_ par Riard, tire parti du refus de
  Bitcoin Core de laisser sa file d'attente de transactions non demandées dépasser 5 000 par pair.
  L'attaquant envoie à la victime un grand nombre de transactions au taux de frais minimum ; la
  victime annonce celles-ci à ses pairs honnêtes et les pairs mettent les annonces en file d'attente ;
  périodiquement, ils tentent de vider la file d'attente en demandant les transactions mais un déficit
  se construit jusqu'à atteindre la limite de 5 000 annonces. À ce moment, les pairs ignorent d'autres
  annonces jusqu'à ce que la file d'attente se soit partiellement vidée. Si la transaction honnête de
  la victime est annoncée pendant ce temps, les pairs l'ignoreront. Cette attaque peut être
  significativement moins coûteuse que la variante de débordement élevé car les transactions inutiles
  de l'attaquant peuvent payer le frais minimum de relais de transaction. Cependant, l'attaque peut
  être plus complexe à exécuter et moins fiable, dans ce cas l'attaquant perd l'argent dépensé en frais
  sans rien gagner du vol.

  Dans leur forme la plus simple, les attaques ne semblent pas préoccupantes. Très peu de canaux sont
  susceptibles d'avoir des paiements en attente dépassant le coût de l'attaque. Riard recommande aux
  utilisateurs de canaux LN de grande valeur d'opérer des nœuds complets supplémentaires, y compris
  ceux qui n'acceptent pas de connexions entrantes et qui utilisent le _mode blocks only_ pour
  s'assurer qu'ils ne relayent que les transactions non confirmées soumises par un portefeuille local.
  Des attaques plus sophistiquées qui réduisent les coûts, ou des attaques qui utilisent le même
  ensemble de transactions inutiles pour attaquer plusieurs canaux LN simultanément, pourraient
  affecter même les canaux de moindre valeur. Riard suggère plusieurs atténuations pour les
  implémentations LN et laisse pour une discussion ultérieure les changements possibles au protocole
  de relais P2P de Bitcoin Core qui pourraient aborder le problème.

  _Note aux lecteurs :_ nous nous excusons s'il y a des erreurs dans la description ci-dessus ; nous
  avons seulement appris la divulgation peu de temps avant de publier le bulletin de cette semaine.

- **Discussion continue sur la proposition de soft fork de nettoyage du consensus :**
  Antoine Poinsot [a posté][poinsot time warp] sur le fil existant Delving Bitcoin à propos de la
  proposition de soft fork de [nettoyage du consensus][topic consensus cleanup]. En plus de la
  correction déjà proposée pour la classique [vulnérabilité time warp][topic time warp], il a
  également proposé d'inclure une correction pour le Zawy-Murch time warp récemment découvert (voir
  le [Bulletin #316][news316 time warp]). Il favorisait une correction initialement proposée par Mark
  "Murch" Erhardt : "exiger que le dernier bloc d'une période de difficulté _N_ ait un horodatage
  supérieur au premier bloc de la même période de difficulté _N_".

  Anthony Towns [favorisait][towns time warp] une solution alternative proposée par Zawy qui
  interdirait à tout bloc de prétendre qu'il a été produit plus de deux heures avant tout bloc
  précédent. Zawy [a noté][zawy time warp] que sa solution pour chaque bloc augmenterait le risque
  pour les mineurs de perdre de l'argent en utilisant un logiciel obsolète mais cela rendrait
  également les horodatages plus précis pour d'autres utilisations, telles que les [timelocks][topic
  timelocks].

  Séparément, à la fois sur [Delving Bitcoin][poinsot duptx delv] et la [liste de diffusion
  Bitcoin-Dev][poinsot duptx ml], Poinsot a cherché des retours sur quelle solution proposée utiliser
  pour empêcher le bloc 1,983,702 et certains blocs ultérieurs de [dupliquer][topic duplicate
  transactions] une transaction coinbase précédente (ce qui pourrait conduire à une perte d'argent et
  à la création d'un vecteur d'attaque). Quatre solutions proposées sont présentées, toutes
  n'affecteraient directement que les mineurs---donc [les retours des mineurs][mining-dev] seraient
  particulièrement appréciés.

## Mises à jour et versions candidates

_Nouvelles mises à jour et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de passer aux nouvelles versions ou d'aider à tester
les versions candidates._

- [Eclair v0.11.0][] est la dernière sortie de cette populaire implémentation de nœud LN. Elle
  "ajoute un support officiel pour les [offres][topic offers] BOLT12 et progresse sur les fonctionnalités
  de gestion de liquidité ([splicing][topic splicing], [annonces de liquidité][topic liquidity
  advertisements], et [financement à la volée][topic jit channels])."
  La version cesse également d'accepter de nouveaux canaux non-[anchor channels][topic anchor
  outputs]. Sont également incluses des optimisations et des corrections de bugs.

- [LDK v0.0.125][] est la dernière version de cette bibliothèque pour le développement
  d'applications compatibles LN. Elle contient plusieurs corrections de bugs.

- [Core Lightning 24.11rc3][] est un candidat à la version pour la prochaine version majeure de
  cette populaire implémentation de LN.

- [LND 0.18.4-beta.rc1][] est un candidat à la version pour une version mineure de cette populaire
  implémentation de LN.

- [Bitcoin Core 28.1RC1][] est un candidat à la version pour une version de maintenance de
  l'implémentation de nœud complet prédominante.

## Changements notables de code et de documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo],
[Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin
inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #30708][] ajoute la commande RPC `getdescriptoractivity` qui récupère toutes les
  transactions associées à un [descriptor][topic descriptors] dans un ensemble spécifié de
  blockhashes, permettant aux portefeuilles d'interagir avec Bitcoin Core de manière sans état. Cette
  commande est particulièrement utile lorsqu'elle est utilisée en conjonction avec `scanblocks` (voir
  le [Bulletin #222][news222 scanblocks]), qui identifie l'ensemble des blockhashes contenant des
  transactions associées à un descriptor.

- [Core Lightning #7832][] dépense à partir des [sorties d'ancrage][topic anchor outputs] même pour les
  transactions de fermeture unilatérale non urgentes, en commençant par un objectif de bloc de 2016
  blocs (environ 2 semaines) et en réduisant progressivement à 12 blocs. Le timestamp de diffusion
  sera suivi pour assurer un comportement cohérent après des redémarrages. Auparavant, ces
  transactions ne dépensaient pas par défaut des sorties d'ancrage, rendant difficile la création
  manuelle d'une dépense et impossible l'utilisation de [CPFP][topic cpfp] pour augmenter les frais de
  la dépense de l'ancrage.

- [LND #8270][] met en œuvre le protocole de quiescence des canaux tel que spécifié dans [BOLT2][]
  (voir le [Bulletin #309][news309 quiescence]), qui est une condition préalable pour les [engagements
  dynamiques][topic channel commitment upgrades] et le [splicing][topic splicing]. Le protocole permet à
  un nœud de répondre à une demande de quiescence d'un pair et d'initier le processus à l'aide de
  nouvelles opérations `ChannelUpdateHandler`. Cette PR ajoute également un mécanisme de timeout
  configurable pour gérer les pairs non réactifs en les déconnectant si l'état quiescent persiste trop
  longtemps sans résolution.

- [LND #8390][] introduit le support pour la configuration et la transmission d'un champ de
  signalisation expérimental [d'approbation HTLC][topic htlc endorsement] dans les messages
  `update_add_htlc`, visant à rechercher la prévention des [attaques de blocage de canal][topic
  channel jamming attacks]. Si un nœud reçoit un HTLC
  avec le champ de signalisation, il transmettra le champ tel quel ; sinon, il définit une valeur par
  défaut de zéro. Cette fonctionnalité est activée par défaut mais peut être désactivée.

- [BIPs #1534][] fusionne [BIP349][] pour la spécification de `OP_INTERNALKEY`, un nouveau opcode
  uniquement pour [tapscript][topic tapscript] qui place la clé interne taproot sur la pile. Les
  auteurs de scripts doivent connaître la clé interne avant de pouvoir payer une sortie, donc c'est
  une alternative à l'inclusion directe de la clé interne dans un script ; cela économise 8 vbytes par
  utilisation et rend les scripts plus réutilisables (voir le [Bulletin #285][news285 bip349]).

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 15:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30708,7832,8270,8390,1534" %}
[core lightning 24.11rc3]: https://github.com/ElementsProject/lightning/releases/tag/v24.11rc3
[lnd 0.18.4-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.4-beta.rc1
[news316 time warp]: /fr/newsletters/2024/08/16/#nouvelle-vulnerabilite-de-manipulation-temporelle-dans-testnet4
[poinsot time warp]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/53
[towns time warp]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/54
[zawy time warp]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/55
[poinsot duptx delv]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/51
[poinsot duptx ml]: https://groups.google.com/g/bitcoindev/c/KRwDa8aX3to
[mining-dev]: https://groups.google.com/g/bitcoinminingdev/c/qyrPzU1WKSI
[eclair v0.11.0]: https://github.com/ACINQ/eclair/releases/tag/v0.11.0
[ldk v0.0.125]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.125
[bitcoin core 28.1RC1]: https://bitcoincore.org/bin/bitcoin-core-28.1/
[riard censor]: https://groups.google.com/g/bitcoindev/c/GuS36ldye7s
[news222 scanblocks]: /fr/newsletters/2022/10/19/#bitcoin-core-23549
[news309 quiescence]: /fr/newsletters/2024/06/28/#bolts-869
[news285 bip349]: /fr/newsletters/2024/01/17/#nouvelle-proposition-de-soft-fork-combinant-lnhance
