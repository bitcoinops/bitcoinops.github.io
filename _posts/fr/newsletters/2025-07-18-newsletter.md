---
title: 'Bulletin Hebdomadaire Bitcoin Optech #363'
permalink: /fr/newsletters/2025/07/18/
name: 2025-07-18-newsletter-fr
slug: 2025-07-18-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
La newsletter de cette semaine inclut nos
sections régulières résumant les changements récents apportés aux clients et services, les
annonces de nouvelles versions et de candidats à la publication, et les résumés des modifications
notables apportées aux logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

_Aucune nouvelle significative cette semaine n'a été trouvée dans nos [sources][]._

## Changements dans les services et logiciels clients

*Dans cette rubrique mensuelle, nous mettons en lumière des mises à jour intéressantes des
portefeuilles et services Bitcoin.*

- **Floresta v0.8.0 lancé :**
  La version [Floresta v0.8.0][floresta v0.8.0] de ce nœud [Utreexo][topic utreexo] ajoute le support
  pour le [transport P2P version 2 (BIP324)][topic v2 p2p transport], [testnet4][topic testnet], des
  métriques et une surveillance améliorées, parmi d'autres fonctionnalités et corrections de bugs.

- **RGB v0.12 annoncé :**
  Le [billet de blog][rgb blog] RGB v0.12 annonce la sortie de la couche de consensus de RBG pour les
  contrats intelligents [validés côté client][topic client-side validation] de RGB sur le testnet et
  le mainnet de Bitcoin.

- **Dispositif de signature FROST disponible :**
  Les dispositifs de signature [Frostsnap][frostsnap website] prennent en charge la [signature à seuil][topic
  threshold signature]k-de-n utilisant le protocole FROST, avec seulement une signature unique sur la chaîne.

- **Gemini ajoute le support de taproot :**
  Gemini Exchange et Gemini Custody ajoutent le support pour l'envoi (retrait) vers des adresses
  [taproot][topic taproot].

- **Electrum 4.6.0 lancé :**
  [Electrum 4.6.0][electrum 4.6.0] ajoute le support pour les [échanges sous-marins][topic submarine
  swaps] utilisant nostr pour la découvrabilité.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates._

- [LND v0.19.2-beta][] est la sortie d'une version de maintenance de ce nœud LN populaire. Elle
  contient des corrections de bugs importants et des améliorations de performance.

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration de Bitcoin (BIPs)][bips
repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Inquisition Bitcoin][bitcoin
inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #32604][] limite le taux de journalisation inconditionnelle sur disque tel que pour
  `LogPrintf`, `LogInfo`, `LogWarning` et `LogError` pour atténuer le remplissage du disque et les
  attaques en attribuant à chaque source un quota de 1 Mo par heure. Toutes les lignes de journal sont
  préfixées d'un astérisque (*) lorsque la localisation d'une source est supprimée.
  Les sorties console, les journaux avec un argument de catégorie explicite et les messages
  `UpdateTip` Initial Block Download (IBD) sont exemptés des limites de taux. Lorsque le
  quota est réinitialisé, Core affiche le nombre d'octets qui ont été supprimés.

- [Bitcoin Core #32618][] supprime l'option `include_watchonly` et ses
  variantes, ainsi que le champ `iswatchonly` de tous les RPCs du portefeuille car
  les portefeuilles [descriptor][topic descriptors] ne supportent pas la combinaison des descripteurs
  watch-only et dépensables. Auparavant, les utilisateurs pouvaient importer une adresse ou
  un script watch-only dans un portefeuille de dépenses legacy. Cependant, les portefeuilles legacy
  ont maintenant été supprimés.

- [Bitcoin Core #31553][] ajoute la gestion des réorganisations de blocs au projet [cluster
  mempool][topic cluster mempool] en introduisant la fonction `TxGraph::Trim()`.
  Lorsqu'une réorganisation réintroduit des transactions précédemment confirmées dans le mempool et
  que le cluster combiné résultant dépasse les limites de nombre ou de poids de cluster, `Trim()`
  construit une linéarisation rudimentaire, ordonnée par frais, respectant les dépendances. Si l'ajout
  d'une transaction devait dépasser une limite, cette transaction et tous ses descendants sont
  supprimés.

- [Core Lightning #7725][] ajoute une visionneuse de journaux JavaScript légère qui charge
  les fichiers de journal CLN dans un navigateur et permet aux utilisateurs de filtrer les messages
  par daemon, type, canal, ou regex. Cet outil ajoute un surcroît minimal de maintenance au dépôt
  tout en améliorant l'expérience de débogage pour les développeurs et les opérateurs de nœuds.

- [Eclair #2716][] implémente un système de réputation locale pour les pairs pour [HTLC
  endorsement][topic htlc endorsement] qui suit les frais de routage gagnés par
  chaque pair entrant par rapport aux frais qui auraient dû être gagnés en fonction de la
  liquidité et des emplacements [HTLC][topic htlc] utilisés. Les paiements réussis résultent en un
  score parfait, les paiements échoués le diminuent, et les HTLC qui restent en attente au-delà
  du seuil configuré sont fortement pénalisés. Lors du transfert, le nœud
  inclut son score de pair actuel dans l'endorsement TLV `update_add_htlc` (voir
  le Bulletin [#315][news315 htlc]). Les opérateurs peuvent ajuster la dégradation de la réputation
  (`half-life`), le seuil de paiement bloqué (`max-relay-duration`), le poids de la pénalité pour les
  HTLC bloqués (`pending-multiplier`), ou simplement désactiver le
  système de réputation entièrement dans la configuration. Cette PR collecte principalement
  des données pour améliorer la recherche sur les [attaques de blocage de canal][topic channel jamming
  attacks] et n'implémente pas encore de pénalités.

- [LDK #3628][] implémente la logique côté serveur pour les [paiements asynchrones][topic
  async payments], permettant à un nœud LSP de fournir des factures statiques [BOLT12][topic offers]
  au nom d'un destinataire souvent hors ligne. Le nœud LSP peut accepter
  les messages `ServeStaticInvoice` du destinataire, stocker les factures statiques fournies, et
  répondre aux demandes de facture du payeur en recherchant et en retournant
  la facture mise en cache via les [chemins aveuglés][topic rv routing].

- [LDK #3890][] change la manière dont il évalue les routes dans son algorithme de recherche de
  chemin en considérant le coût total divisé par la limite de montant du canal (coût par sat de capacité
  utilisable) au lieu de considérer uniquement le coût total brut. Cela biaise la
  sélection vers des routes de plus grande capacité et réduit l'utilisation excessive de le sharding
  [MPP][topic multipath payments], résultant en un taux de succès de paiement plus élevé. Bien
  que le changement pénalise excessivement les petits canaux, ce compromis est préférable au sharding
  excessif précédent.

- [LND #10001][] active le protocole de quiescence en production (voir le Bulletin [#332][news332
  quiescence]) et ajoute une nouvelle valeur de configuration `--htlcswitch.quiescencetimeout`, qui
  spécifie la durée maximale pendant laquelle un canal peut être quiescent. La valeur assure que les
  protocoles dépendants, tels que les [engagements dynamiques][topic channel commitment upgrades], se
  terminent dans la période de timeout. La valeur par défaut est de 60 secondes, et la valeur minimale
  est de 30 secondes.

{% include snippets/recap-ad.md when="2025-07-22 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32604,32618,31553,7725,2716,3628,3890,10001" %}
[LND v0.19.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.2-beta
[sources]: /en/internal/sources/
[floresta v0.8.0]: https://github.com/vinteumorg/Floresta/releases/tag/v0.8.0
[rgb blog]: https://rgb.tech/blog/release-v0-12-consensus/
[frostsnap website]: https://frostsnap.com/
[electrum 4.6.0]: https://github.com/spesmilo/electrum/releases/tag/4.6.0
[news315 htlc]: /fr/newsletters/2024/08/09/#eclair-2884
[news332 quiescence]: /fr/newsletters/2024/12/06/#lnd-8270
