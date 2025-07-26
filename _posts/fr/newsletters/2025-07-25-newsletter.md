---
title: 'Bulletin Hebdomadaire Bitcoin Optech #364'
permalink: /fr/newsletters/2025/07/25/
name: 2025-07-25-newsletter-fr
slug: 2025-07-25-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
La newsletter de cette semaine résume une vulnérabilité affectant d'anciennes versions de LND,
décrit une idée pour améliorer la confidentialité lors de l'utilisation de services de
co-signataires, et examine l'impact du passage à des algorithmes de signature résistants aux
quantiques sur les portefeuilles HD, le multisig sans script, et les paiements silencieux.
Sont également incluses nos sections régulières résumant les récentes questions et réponses de Bitcoin
Stack Exchange, annoncant de nouvelles versions et des candidats à la publication, ainsi que les
résumés des modifications notables apportées aux logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

- **Vulnérabilité de DoS du filtre de gossip de LND :** Matt Morehouse a [publié][morehouse gosvuln]
  sur Delving Bitcoin concernant une vulnérabilité affectant les versions passées de LND qu'il avait
  précédemment [divulguée de manière responsable][topic responsible disclosures]. Un attaquant
  pourrait demander à répétition des messages de l'historique de gossip à un nœud LND jusqu'à ce qu'il
  manque de mémoire et se coupe. La vulnérabilité a été corrigée dans LND 0.18.3, publié en
  septembre 2024.

- **Rétention du code de chaîne pour les scripts multisig :** Jurvis Tan a [posté][tan ccw] sur
  Delving Bitcoin à propos de recherches qu'il a effectuées avec Jesse Posner pour améliorer la
  confidentialité et la sécurité de la garde collaborative multisig. Dans un service de garde
  collaborative typique, un multisig 2-sur-3 peut être utilisé avec les trois clés étant :

  - Une _clé chaude utilisateur_ qui est stockée sur un appareil connecté au réseau et signe les
    transactions pour l'utilisateur (soit manuellement, soit par automatisation logicielle).

  - Une clé chaude du fournisseur qui est stockée sur un appareil connecté au réseau séparé sous le
    contrôle exclusif du fournisseur. La clé ne signe les transactions selon une politique précédemment
    définie par l'utilisateur, comme permettant seulement des dépenses jusqu'à _x_ BTC par jour.

  - Une _clé froide utilisateur_ qui est stockée hors ligne et est utilisée seulement si la clé chaude
    de l'utilisateur est perdue ou si le fournisseur cesse de signer les transactions autorisées.

  Bien que la configuration ci-dessus puisse fournir un renforcement significatif de la sécurité, la
  méthode de configuration presque toujours utilisée implique que l'utilisateur partage avec le
  fournisseur les [clés publiques étendues BIP32][topic bip32] pour les portefeuilles chaud et froid
  de l'utilisateur. Cela permet au fournisseur de détecter tous les fonds reçus par le portefeuille de
  l'utilisateur et de suivre toutes les dépenses de ces fonds même si l'utilisateur dépense sans
  l'assistance du fournisseur. Plusieurs moyens de mitiger cette perte de confidentialité ont été
  précédemment décrits, mais ils sont soit incompatibles avec l'utilisation typique (par exemple, en
  utilisant des tapleaves distinctes) soit complexes (par exemple, nécessitant [MPC][]). Tan et
  Posner décrivent une alternative simple :

  - Le fournisseur génère la moitié d'une clé étendue HD BIP32 (juste la partie clé). Ils donnent la
    clé publique à l'utilisateur.

  - L'utilisateur génère l'autre moitié (le code de chaîne). Ils gardent cela privé.

  Lors de la réception de fonds, l'utilisateur peut combiner les deux moitiés pour créer une clé
  publique étendue (xpub) puis dériver des adresses multisig comme d'habitude. Le fournisseur ne
  connaissant pas le code de chaîne, il est empêché de dériver l'xpub ou de découvrir l'adresse.

  Lors de la dépense de fonds, l'utilisateur peut dériver du code de chaîne avec
  l'ajustement nécessaire que le fournisseur doit combiner avec sa clé privée pour créer une signature
  valide. Ils partagent simplement cet ajustement avec le fournisseur. Le fournisseur ne peut rien
  apprendre de l'ajustement, sauf qu'il est valide pour dépenser depuis le scriptPubKey spécifique qui
  a reçu des fonds.

  Certains fournisseurs peuvent exiger que la sortie de monnaie rendue d'une transaction de dépense
  renvoie l'argent au même modèle de script. Le post de Tan décrit comment cela peut être facilement
  accompli.

- **La recherche indique que les primitives Bitcoin communes sont compatibles avec les algorithmes de signature résistants aux quantiques :**
  Jesse Posner a [posté][posner qc] sur Delving Bitcoin plusieurs liens vers des articles de recherche
  qui indiquent que les algorithmes de signature [résistants aux quantiques][topic quantum resistance]
  fournissent des primitives comparables à celles actuellement utilisées dans Bitcoin pour les
  [portefeuilles HD BIP32][topic bip32], les [adresses de paiement silencieuses][topic silent
  payments], les [multisignatures sans script][topic multisignature], et les [signatures de seuil sans
  script][topic threshold signature].

## Questions et réponses sélectionnées de Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech
cherchent des réponses à leurs questions - ou quand nous avons quelques moments libres pour aider
les utilisateurs curieux ou confus. Dans cette rubrique mensuelle, nous mettons en lumière certaines
des questions et réponses les mieux votées postées depuis notre dernière mise à jour.*


{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}


- [Comment Bitcoin Core gère-t-il les réorganisations de chaîne de plus de 10 blocs ?]({{bse}}127512)
  TheCharlatan lie au code de Bitcoin Core qui gère les réorganisations de chaîne en ne réajoutant
  qu'un maximum de 10 blocs de transactions au mempool.

- [Avantages d'un dispositif de signature par rapport à un disque crypté ?]({{bse}}127596)
  RedGrittyBrick souligne que les données sur un disque crypté peuvent être extraites tandis que le
  disque est déchiffré alors que les dispositifs de signature matérielle sont conçus pour empêcher
  cette attaque d'extraction de données.

- [Dépenser une sortie taproot via le keypath et le scriptpath ?]({{bse}}127601)
  Antoine Poinsot détaille comment l'utilisation d'arbres de Merkle, d'ajustements de clé et de
  tapscript permet d'atteindre les capacités de dépense de taproot via le keypath et le
  scriptpath.

## Mises à jour et versions candidates

_Nouvelles mises-à-jours et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles mises-à-jour ou d'aider à tester les versions candidates._

- [Libsecp256k1 v0.7.0][] est une sortie de cette bibliothèque contenant des primitives
  cryptographiques compatibles avec Bitcoin. Elle contient quelques petits changements qui rompent la
  compatibilité API/ABI avec les versions précédentes.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core
lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust
Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo], [Propositions
d'Amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo] et [BINANAs][binana
repo]._

- [Bitcoin Core #32521][] rend les transactions héritées avec plus de 2500 opérations de signature
  (sigops) non standard en préparation pour une potentielle mise à niveau de [soft fork de nettoyage
  de consensus][topic consensus cleanup] qui imposerait la limite au niveau du consensus. Si le soft
  fork avait lieu sans ce changement, les mineurs qui ne mettent pas à jour pourraient devenir des
  cibles d'attaques DoS triviales. Voir le Bulletin [#340][news340 sigops] pour plus de détails sur
  la limite des sigops d'entrée héritée.

- [Bitcoin Core #31829][] ajoute des limites de ressources au gestionnaire de transactions
  orphelines, `TxOrphanage` (Voir le Bulletin [#304][news304 orphan]), pour préserver le [relais de
  paquets][topic package relay] opportuniste un-parent-un-enfant (1p1c) face aux
  attaques de spam DoS. Quatre limites sont imposées : un plafond global de 3 000 annonces orphelines
  (pour minimiser le coût en CPU et en latence), un plafond d'annonces orphelines par pair
  proportionnel, une réservation de poids par pair de 24 × 400 kWU, et un plafond de mémoire global
  variable. Lorsqu'une limite est dépassée, le nœud évince l'annonce orpheline la plus ancienne du
  pair qui a utilisé le plus de CPU ou de mémoire par rapport à son allocation (score Peer DoS le plus
  élevé). La PR supprime également l'option `‑maxorphantxs` (par défaut 100), dont la politique
  d'éviction d'annonces aléatoires permettait aux attaquants de remplacer l'ensemble des orphelins et
  de rendre le relais [1p1c][1p1c relay] inutile. Voir également le Bulletin [#362][news362 orphan].

- [LDK #3801][] étend les [échecs attribuables][topic attributable failures] au chemin de réussite
  de paiement en enregistrant combien de temps un nœud détient un [HTLC][topic htlc] et en propageant
  ces valeurs de temps de détention en amont dans la charge utile d'attribution. Auparavant, LDK ne
  suivait les temps de détention que pour les paiements échoués (voir le Bulletin [#349][news349
  attributable]).

- [LDK #3842][] étend sa machine d'état de [construction de transaction interactive][topic dual
  funding] (Voir le Bulletin [#295][news295 dual]) pour gérer la coordination de signature pour les
  entrées partagées dans les transactions de [splicing][topic splicing]. Le champ `prevtx` du message
  `TxAddInput` est rendu optionnel pour réduire l'utilisation de la mémoire et simplifier la
  validation.

- [BIPs #1890][] change le paramètre séparateur de `+` à `-` dans [BIP77][] parce que certaines
  bibliothèques URI HTML 2.0 traitent `+` comme s'il s'agissait d'un espace blanc. De plus, les
  paramètres de fragment doivent maintenant être ordonnés lexicographiquement, plutôt qu'à l'envers,
  pour simplifier le protocole [payjoin][topic payjoin] asynchrone.

- [BOLTs #1232][] rend le champ `channel_type` (voir le Bulletin [#165][news165 type]) obligatoire
  lors de l'ouverture d'un canal car chaque implémentation l'impose. Cette PR met également à jour
  [BOLT9][] en ajoutant un nouveau type de contexte `T` pour les fonctionnalités qui peuvent être
  incluses dans le champ `channel_type`.

{% include snippets/recap-ad.md when="2025-07-29 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32521,31829,3801,3842,1890,1232" %}
[morehouse gosvuln]: https://delvingbitcoin.org/t/disclosure-lnd-gossip-timestamp-filter-dos/1859
[tan ccw]: https://delvingbitcoin.org/t/chain-code-delegation-private-access-control-for-bitcoin-keys/1837
[mpc]: https://en.wikipedia.org/wiki/Secure_multi-party_computation
[posner qc]: https://delvingbitcoin.org/t/post-quantum-hd-wallets-silent-payments-key-aggregation-and-threshold-signatures/1854
[Libsecp256k1 v0.7.0]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.7.0
[news340 sigops]: /fr/newsletters/2025/02/07/#introduire-une-limite-de-sigops-pour-les-entrees-legacy
[news304 orphan]: /fr/newsletters/2024/05/24/#bitcoin-core-30000
[1p1c relay]: /en/bitcoin-core-28-wallet-integration-guide/#one-parent-one-child-1p1c-relay
[news349 attributable]: /fr/newsletters/2025/04/11/#ldk-2256
[news295 dual]: /fr/newsletters/2024/03/27/#ldk-2419
[news165 type]: /en/newsletters/2021/09/08/#bolts-880
[news362 orphan]: /fr/newsletters/2025/07/11/#bitcoin-core-pr-review-club