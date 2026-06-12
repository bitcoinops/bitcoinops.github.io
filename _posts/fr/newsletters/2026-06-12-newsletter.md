---
title: 'Bulletin Hebdomadaire Bitcoin Optech #409'
permalink: /fr/newsletters/2026/06/12/
name: 2026-06-12-newsletter-fr
slug: 2026-06-12-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit un projet de BIP visant à remplacer le réseau de test testnet4 par un successeur. Sont également
incluses nos sections régulières annonçant de nouvelles versions et versions candidates et décrivant des changements notables dans des
logiciels populaires d'infrastructure Bitcoin.

## Nouvelles

- **Projet de BIP pour testnet5** : Pol Espinasa a [publié][testnet5 ml] sur la liste de diffusion Bitcoin-Dev un [projet de BIP][testnet5
  BIP], coécrit avec Fabian Jahr, pour remplacer [testnet4][topic testnet] par testnet5. La proposition est motivée par la faible fiabilité
  de testnet4, qui découle d'une exploitation soutenue de l'exception de difficulté (également connue sous le nom de règle des 20 minutes).
  Cette règle permet aux mineurs CPU de miner des blocs à la difficulté `1` une fois que 20 minutes se sont écoulées depuis le bloc
  précédent, permettant des « block storms » dans lesquelles un grand nombre de blocs de faible difficulté peuvent être minés en peu de
  temps (voir le [Bulletin #311][news311 block storm]).

  Le projet de BIP propose de supprimer la règle d'exception de difficulté afin que testnet corresponde au comportement de mainnet aussi
  étroitement que possible. Testnet5 suivrait les mêmes règles de consensus que mainnet à l'exception de deux changements : l'activation de
  [BIP54][] (le [soft fork de nettoyage du consensus][topic consensus cleanup]) dès le bloc `1`, et le réglage de la cible maximale de
  preuve de travail à `0x1a0fffff` (une cible maximale plus basse que testnet4, c'est-à-dire une difficulté minimale plus élevée).

  Espinasa a invité d'autres développeurs à donner leur avis sur la proposition. La discussion dans le fil de la liste de diffusion s'est
  concentrée sur l'application de correctifs à testnet4 au lieu d'en lancer un nouveau, sur la possibilité de préminer des pièces de
  testnet, et sur la meilleure difficulté minimale pour le nouveau réseau.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires. Veuillez envisager de mettre à niveau vers
les nouvelles versions ou d'aider à tester les versions candidates._

- [LND 0.21.0-beta][] est une version de la prochaine version majeure de cette implémentation populaire de nœud LN. Elle ajoute le relais de
  base des [messages onion][topic onion messages], des canaux [taproot][topic taproot] simples prêts pour la production avec prise en charge
  des fermetures coopératives [RBF][topic rbf], une protection contre les réorganisations pour les fermetures de canaux, une synchronisation
  initiale plus rapide pour les nœuds basés sur [Neutrino][topic compact block filters], une migration optionnelle du magasin de paiements
  vers SQL natif, ainsi que plusieurs corrections de bugs.

- [Core Lightning 26.06.1][] est une version de maintenance pour la version majeure actuelle de ce nœud LN populaire. Elle corrige un échec
  d'enregistrement du plugin `bwatch` après l'exécution de `make install`.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning
BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #35410][] corrige un bug qui pouvait faire qu'une nouvelle tentative de [diffusion privée de transaction][topic transaction
  origin privacy] se connecte directement à un pair IPv4 ou IPv6 au lieu d'utiliser [Tor ou I2P][topic anonymity networks]. Lorsque
  `sendrawtransaction` était utilisé avec `-privatebroadcast=1` (voir le [Bulletin #388][news388 private broadcast]), Bitcoin Core forçait les
  connexions de diffusion de transactions à passer par un proxy Tor ou I2P. Si l'une de ces connexions tentait le transport v2 [BIP324][]
  mais échouait, elle retentait avec le transport v1. Auparavant, la nouvelle tentative pouvait oublier la redéfinition du proxy de
  diffusion privée sur les nœuds qui établissaient par ailleurs des connexions directes IPv4/IPv6. La redéfinition du proxy est désormais
  stockée et conservée lors des reconnexions de v2 vers v1.

- [Bitcoin Core #34779][] implémente [BIP323][], en réservant les bits 5 à 28 de `nVersion` dans l'en-tête de bloc comme espace d'extranonce
  pour les mineurs (voir le [Bulletin #405][news405 bip323]). Auparavant, ces bits faisaient partie de la plage surveillée par la logique
  d'avertissement des bits de version [BIP9][] pour la signalisation inconnue de soft forks. Bitcoin Core exclut désormais les bits réservés
  par [BIP323][] de cette logique d'avertissement, empêchant les mineurs qui les utilisent pour faire varier le nonce de déclencher des
  avertissements de soft fork inconnu.

- [Bitcoin Core #32150][] réécrit l'algorithme de [branch-and-bound][] de [sélection de pièces][topic coin selection] afin d'éviter de
  revenir sur des parties de l'arbre de recherche qui ne font que reproduire des ensembles d'entrées équivalents. Au lieu de revenir en
  arrière de manière répétée et de retester les mêmes préfixes de sélection, la nouvelle recherche suit le prochain UTXO à essayer, coupe
  les branches qui ne peuvent pas atteindre la cible, passe directement au prochain candidat utile, et ignore les UTXO en double ou plus
  gaspilleurs ayant la même valeur effective. Cela permet au portefeuille d'utiliser son budget d'itération sur un plus grand nombre de
  sélections candidates distinctes.

- [LDK #4647][] cesse d'utiliser des nœuds d'introduction distants pour les [chemins de message aveuglés][topic rv routing] de
  [BOLT12][topic offers] afin d'éviter une incompatibilité avec la prise en charge optionnelle des [messages onion][topic onion messages] de
  LND, qui peut recevoir mais pas relayer de messages provenant de pairs sans canal. LDK utilise désormais le destinataire annoncé lui-même
  comme point d'introduction, améliorant l'interopérabilité mais réduisant la confidentialité du récepteur.

- [BTCPay Server #7218][] ajoute un flux de configuration guidé pour les portefeuilles BTC multisig. Les propriétaires de boutique peuvent
  choisir une politique de signature, inviter les utilisateurs de la boutique à soumettre des clés de signataire manuellement ou via BTCPay
  Server Vault, examiner les adresses générées, et créer le portefeuille une fois les clés nécessaires collectées.

- [BIPs #2186][] met à jour [BIP77][] pour spécifier comment un récepteur [payjoin v2][topic payjoin] répond à un expéditeur compatible
  [BIP78][]. Le chemin de réponse normal de [BIP77][] utilise une clé de réponse fournie par l'expéditeur pour chiffrer la proposition
  [PSBT][topic psbt] et la livrer à une boîte aux lettres de réponse dérivée de l'expéditeur, mais les expéditeurs [BIP78][] ne fournissent
  pas de clés de réponse. À la place, le récepteur écrit le PSBT de proposition encodé en base64 dans la boîte aux lettres du récepteur où
  l'expéditeur a publié le PSBT d'origine. Le récepteur utilise une requête PUT encapsulée dans OHTTP vers le répertoire. Cela documente le
  chemin de réponse rétrocompatible utilisé par les implémentations.

{% include snippets/recap-ad.md when="2026-06-16 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="35410,34779,32150,4647,7218,2186" %}

[testnet5 ml]: https://groups.google.com/g/bitcoindev/c/kGUMTxOvdJA/m/Eyx5FxQeAAAJ
[testnet5 BIP]: https://github.com/bitcoin/bips/pull/2196
[news311 block storm]: /fr/newsletters/2024/07/12/#bitcoin-core-pr-review-club
[LND 0.21.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.21.0-beta
[Core Lightning 26.06.1]: https://github.com/ElementsProject/lightning/releases/tag/v26.06.1
[news388 private broadcast]: /fr/newsletters/2026/01/16/#bitcoin-core-29415
[news405 bip323]: /fr/newsletters/2026/05/15/#bips-2116
[branch-and-bound]: https://en.wikipedia.org/wiki/Branch_and_bound
