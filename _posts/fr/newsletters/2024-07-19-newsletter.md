---
title: 'Bulletin Hebdomadaire Bitcoin Optech #312'
permalink: /fr/newsletters/2024/07/19/
name: 2024-07-19-newsletter-fr
slug: 2024-07-19-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit un protocole de génération de clés distribué pour le schéma de
signature limitée sans script FROST et renvoie à une introduction complète à la linéarisation de
clusters. Nous incluons également nos sections régulières décrivant les mises à jour des clients et des services,
les nouvelles versions et les versions candidates, ainsi que les changements
apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Protocole de génération de clés distribué pour FROST :** Tim Ruffing et Jonas Nick ont
  [publié][ruffing nick post] sur la liste de diffusion Bitcoin-Dev un [brouillon de BIP][chilldkg
  bip] avec une [référence d'implémentation][chilldkg ref] de ChillDKG, un protocole pour générer de
  manière sécurisée des clés à utiliser avec les [signatures limitées sans script][topic threshold
  signature] de style [FROST][] compatibles avec les [signatures schnorr][topic schnorr signatures] de
  Bitcoin.

  Les signatures limitées sans script sont compatibles avec la création de `n` clés, dont n'importe
  quelles `t` peuvent être utilisées coopérativement pour créer une signature valide. Par exemple, un
  schéma 2-sur-3 crée trois clés, dont deux quelconques peuvent produire une signature valide. Étant
  _sans script_, le schéma repose entièrement sur des opérations externes au consensus et à la
  blockchain, contrairement aux opérations de signature limitée scriptées intégrées de Bitcoin (par
  exemple, en utilisant `OP_CHECKMULTISIG`).

  De manière similaire à la génération d'une clé privée Bitcoin régulière, chaque personne créant une
  clé pour les signatures limitées sans script doit générer un nombre grand et aléatoire sans divulguer
  ce nombre à quiconque d'autre. Cependant, chaque personne doit également distribuer des parts
  dérivées de ce nombre aux autres utilisateurs afin qu'un nombre limité d'entre eux puisse créer une
  signature si cette clé est indisponible. Chaque utilisateur doit vérifier que les informations qu'il
  a reçues de chaque autre utilisateur ont été générées correctement. Plusieurs protocoles de
  génération de clés pour effectuer ces étapes existent, mais ils supposent que les utilisateurs
  générant les clés ont accès à un canal de communication qui est chiffré et authentifié entre des
  paires individuelles d'utilisateurs et qui permet également une diffusion authentifiée et
  incensurable de chaque utilisateur vers tous les autres utilisateurs. Le protocole ChillDKG combine
  un algorithme de génération de clés bien connu pour FROST avec des primitives cryptographiques
  modernes supplémentaires et des algorithmes simples pour fournir la communication sécurisée,
  authentifiée et prouvée incensurable nécessaire.

  Le chiffrement et l'authentification entre les participants commencent par un échange [elliptic
  curve diffie-hellman][ecdh] (ECDH). La preuve de non-censure est créée par chaque participant en
  utilisant sa clé de base pour signer un transcript de la session depuis son début jusqu'à la
  production de la clé publique limitée sans script (qui est la fin de la session). Avant d'accepter la
  clé publique limitée comme correcte, chaque participant vérifie le transcript de session signé de
  chaque autre participant.

  L'objectif est de fournir un protocole entièrement généralisé qui est utilisable dans tous les cas
  où les gens veulent générer des clés pour des signatures limitées sans script basées sur FROST. De
  plus, le protocole aide à simplifier les sauvegardes : tout ce dont un utilisateur a besoin est sa
  graine privée et certaines données de récupération qui ne sont pas sensibles à la sécurité (mais qui
  ont des implications sur la vie privée). Dans un [message de suivi][nick follow-up], Jonas Nick a
  mentionné qu'ils envisagent d'étendre le protocole pour chiffrer les données de récupération avec
  une clé dérivée de la graine, de sorte que la seule donnée que l'utilisateur doit garder privée soit
  sa graine.

- **Introduction à la linéarisation des clusters :** Pieter Wuille a [publié][wuille cluster] sur
  Delving Bitcoin une description détaillée de toutes les parties principales de la linéarisation des
  clusters, la base pour un [mempool en cluster][topic cluster mempool]. Les précédents bulletins d'Optech
  ont tenté d'introduire le sujet à mesure que ses concepts clés étaient développés et publiés, mais
  cette vue d'ensemble est beaucoup plus complète. Elle guide les lecteurs dans un ordre <!-- linéaire
  :-) --> des concepts fondamentaux aux algorithmes spécifiques mis en œuvre. Elle se termine par des
  liens vers plusieurs pull requests de Bitcoin Core qui implémentent des parties du mempool en cluster.

## Modifications apportées aux services et aux logiciels clients

*Dans cette rubrique mensuelle, nous mettons en lumière des mises à jour intéressantes des
portefeuilles et services Bitcoin.*

- **ZEUS ajoute les offres BOLT12 et le support BIP353 :**
  La version [v0.8.5][zeus v0.8.5] tire parti du service [TwelveCash][twelve cash website] pour
  prendre en charge les [offres][topic offers] et [BIP353][] (voir [Newsletter #307][news307 bip353]).

- **Phoenix ajoute les offres BOLT12 et le support BIP353 :**
  La version [Phoenix 2.3.1][phoenix 2.3.1] a ajouté le support des offres et [Phoenix 2.3.3][phoenix
  2.3.3] a ajouté le support [BIP353][].

- **Stack Wallet ajoute le support RBF et CPFP :**
  La version [v2.1.1][stack wallet v2.1.1] de Stack Wallet a ajouté le support pour l'augmentation des
  frais via [RBF][topic rbf] et [CPFP][topic cpfp] ainsi que le support [Tor][topic anonymity
  networks].

- **BlueWallet ajoute le support de l'envoi de paiements silencieux :**
  Dans la version [v6.6.7][bluewallet v6.6.7], BlueWallet a ajouté la capacité d'envoyer à des
  adresses de [paiements silencieux][topic silent payments].

- **Annonce de BOLT12 Playground :**
  Strike a [annoncé][strike bolt12 playground] un environnement de test pour les offres BOLT12. Le
  projet utilise Docker pour initier et automatiser les portefeuilles, les canaux et les paiements à
  travers différentes implémentations de LN.

- **Annonce du dépôt de test Moosig :**
  Ledger a publié un [dépôt][moosig github] de test basé sur Python pour utiliser [MuSig2][topic
  musig] et [BIP388][] les [politiques de portefeuille pour les portefeuilles descripteurs][news302
  bip388].

- **Outil de visualisation en temps réel de Stratum publié :**
  Le site web [stratum.work][stratum.work], basé sur [des recherches précédentes][b10c nostr], affiche
  en temps réel les messages Stratum d'une variété de pools de minage Bitcoin.
  avec le [code source disponible][stratum work github].

- **BMM 100 Mini Miner annoncé :**
  Le [matériel de minage][braiins mini miner] de Braiins est livré avec un sous-ensemble de
  fonctionnalités [Stratum V2][topic pooled mining] activées par défaut.

- **Coldcard publie une spécification de diffusion de transaction basée sur URL :**
  Le [protocole][pushtx spec] permet la diffusion d'une transaction Bitcoin
  en utilisant une requête HTTP GET et peut être utilisé par des dispositifs de signature matérielle
  basés sur NFC, parmi d'autres cas d'utilisation.

## Changements notables dans le code et la documentation

_Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi
repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration de Bitcoin (BIPs)][bips
repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Inquisition Bitcoin][bitcoin inquisition
repo], et [BINANAs][binana repo]._

- [Bitcoin Core #26596][] utilise la nouvelle base de données en lecture seule pour migrer
  les portefeuilles hérités vers des portefeuilles [descriptor][topic descriptors]. Ce changement
  ne déprécie pas les portefeuilles hérités ou le `BerkeleyDatabase` hérité. Une nouvelle
  classe `LegacyDataSPKM` a été créée contenant uniquement les données essentielles
  et les fonctions nécessaires pour charger un portefeuille hérité en vue de sa migration. Voir le
  Bulletin [#305][news305 bdb] pour une introduction à la `BerkeleyRODatabase`.

- [Core Lightning #7455][] améliore le traitement des [messages onion][topic onion
  messages] par `connectd` en implémentant le transfert via `short_channel_id`
  (SCID) et `node_id` (voir le [Bulletin #307][news307 ldk3080] pour
  une discussion sur un changement similaire dans LDK). Les messages onion sont maintenant
  toujours activés, et les messages entrants sont limités à 4 par seconde.

- [Eclair #2878][] rend les fonctionnalités de [masquage de route][topic rv routing] et de mise en veille
  des canaux optionnelles, puisqu'elles sont maintenant entièrement implémentées et font
  partie de la spécification BOLT (voir les Bulletins [#245][news245 blind] et
  [#309][news309 stfu]). Un nœud Eclair annonce le support de ces
  fonctionnalités à ses pairs, mais la fonction `route_blinding` est désactivée par défaut car il
  ne transférera pas les [paiements aveuglés][topic rv routing] qui n'utilisent pas
  le [trampoline routing][topic trampoline payments].

- [Rust Bitcoin #2646][] introduit de nouveaux inspecteurs pour les structures de script et de
  témoin telles que `redeem_script` pour assurer la conformité avec les règles de [BIP16][];
  concernant les dépenses P2SH, `taproot_control_block`, et `taproot_annex` pour
  assurer la conformité avec les règles [BIP341][] ; et `witness_script` pour garantir que les scripts
  témoins P2WSH respectent les règles [BIP141][]. Voir le Bulletin [#309][news309 p2sh].

- [BDK #1489][] met à jour `bdk_electrum` pour utiliser des preuves de Merkle pour la vérification
  simplifiée des paiements (SPV). Il récupère les preuves de Merkle et les en-têtes de blocs en même
  temps que les transactions, valide que les transactions se trouvent dans des blocs confirmés avant
  d'insérer des ancres, et supprime la gestion des réorganisations de `full_scan`. La PR introduit
  également `ConfirmationBlockTime` comme un nouveau type d'ancre, remplaçant les types précédents.

- [BIPs #1599][] ajoute [BIP46][] pour un schéma de dérivation pour les portefeuilles HD qui créent
  des adresses [verrouillées dans le temps][topic timelocks] utilisées pour les [fidelity
  bonds][news161 fidelity] comme celles utilisées pour le matching de marché [coinjoin][topic
  coinjoin] de style JoinMarket. Les fidelity bonds améliorent la résistance Sybil du protocole en
  créant un système de réputation où les créateurs prouvent leur sacrifice intentionnel de la valeur
  temporelle de l'argent en verrouillant dans le temps des bitcoins.

- [BOLTs #1173][] rend le champ `channel_update` optionnel dans les [messages onion][topic onion
  messages] d'échec. Les nœuds ignorent maintenant ce champ en dehors du paiement actuel pour éviter
  le profilage des expéditeurs de [HTLC][topic htlc]. Le changement vise à décourager les retards de
  paiement dus à des paramètres de canal obsolètes tout en permettant encore aux nœuds avec des
  données de gossip périmées de bénéficier des mises à jour lorsque nécessaire.

- [BLIPs #25][] ajoute une description de comment [BLIP25][] permet le transfert de HTLCs qui sous-paient
  la valeur en onion encodée. Par exemple, Alice fournit une facture lightning à Bob mais elle n'a pas de
  canaux de paiement, donc quand Bob paie, Carol (le LSP d'Alice) crée un canal à la volée. Pour
  permettre à Carol de prendre des frais d'Alice pour couvrir le coût de la commission initiale
  onchain qui crée un [canal JIT][topic jit channels], ce protocole est utilisé, et Alice
  recoit un HTLC qui sous-paie la valeur en onion encodée. Pour une discussion précédente sur une
  mise en œuvre de cela dans LDK, voir le [Bulletin #257][news257 jit htlc].

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="26596,7455,2878,2646,1489,1599,1173,25" %}
[ruffing nick post]: https://mailing-list.bitcoindevs.xyz/bitcoindev/8768422323203aa3a8b280940abd776526fab12e.camel@timruffing.de/T/#u
[chilldkg bip]: https://github.com/BlockstreamResearch/bip-frost-dkg
[chilldkg ref]: https://github.com/BlockstreamResearch/bip-frost-dkg/tree/master/python/chilldkg_ref
[nick follow-up]: https://mailing-list.bitcoindevs.xyz/bitcoindev/7084f935-0201-4909-99ff-c76f83572a7c@gmail.com/
[wuille cluster]: https://delvingbitcoin.org/t/introduction-to-cluster-linearization/1032
[frost]: https://eprint.iacr.org/2020/852.pdf
[ecdh]: https://en.wikipedia.org/wiki/Elliptic-curve_Diffie%E2%80%93Hellman
[zeus v0.8.5]: https://github.com/ZeusLN/zeus/releases/tag/v0.8.5
[twelve cash website]: https://twelve.cash/
[news307 bip353]: /fr/newsletters/2024/06/14/#bips-1551
[phoenix 2.3.1]: https://github.com/ACINQ/phoenix/releases/tag/android-v2.3.1
[phoenix 2.3.3]: https://github.com/ACINQ/phoenix/releases/tag/android-v2.3.3
[stack wallet v2.1.1]: https://github.com/cypherstack/stack_wallet/releases/tag/build_235
[bluewallet v6.6.7]: https://github.com/BlueWallet/BlueWallet/releases/tag/v6.6.7
[strike bolt12 playground]: https://strike.me/blog/bolt12-playground/
[moosig github]: https://github.com/LedgerHQ/moosig
[news302 bip388]: /fr/newsletters/2024/05/15/#bips-1389
[stratum.work]: https://stratum.work/
[stratum work github]: https://github.com/bboerst/stratum-work
[b10c nostr]: https://primal.net/e/note1qckcs4y67eyaawad96j7mxevucgygsfwxg42cvlrs22mxptrg05qtv0jz3
[braiins mini miner]: https://braiins.com/hardware/bmm-100-mini-miner
[pushtx spec]: https://pushtx.org/#url-protocol-spec
[news305 bdb]: /fr/newsletters/2024/05/31/#bitcoin-core-26606
[news309 p2sh]: /fr/newsletters/2024/06/28/#rust-bitcoin-2794
[news161 fidelity]: /en/newsletters/2021/08/11/#implementation-of-fidelity-bonds
[news257 jit htlc]: /fr/newsletters/2023/06/28/#ldk-2319
[news307 ldk3080]: /fr/newsletters/2024/06/14/#ldk-3080
[news245 blind]: /fr/newsletters/2023/04/05/#bolts-765
[news309 stfu]: /fr/newsletters/2024/06/28/#bolts-869