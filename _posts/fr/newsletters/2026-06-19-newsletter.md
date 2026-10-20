---
title: 'Bulletin Hebdomadaire Bitcoin Optech #410'
permalink: /fr/newsletters/2026/06/19/
name: 2026-06-19-newsletter-fr
slug: 2026-06-19-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume une discussion sur le retrait par les portefeuilles de la signalisation replace-by-fee optionnelle des
transactions qu'ils créent. Sont également incluses nos sections régulières décrivant les changements récents dans les services et logiciels
clients ainsi que les changements notables dans les logiciels populaires d'infrastructure Bitcoin.

## Nouvelles

- **Discussion sur la suppression de la signalisation RBF des transactions de portefeuille** : rkrux a [publié][bip125 ml] sur la liste de
  diffusion Bitcoin-Dev une proposition selon laquelle les portefeuilles cesseraient de signaler [opt-in RBF][topic rbf] dans les
  transactions qu'ils créent. Une transaction signale sa remplaçabilité selon [BIP125][] lorsqu'au moins une de ses entrées définit
  `nSequence` en dessous de `MAX-1` (où `MAX` vaut `0xffffffff`). Ce signal n'affecte plus la possibilité de remplacer une transaction,
  puisque le full RBF est devenu le comportement par défaut (voir le [Bulletin #315][news315 fullrbf]) et que l'option de retrait
  `mempoolfullrbf` a été supprimée (voir le [Bulletin #329][news329 fullrbf]). Les nœuds utilisant la politique par défaut de Bitcoin Core
  remplaceront n'importe quelle transaction quelle que soit la valeur de ses `nSequence`. La signalisation sert désormais principalement à
  identifier l'empreinte du portefeuille qui a créé la transaction, de sorte que le message avançait que les portefeuilles devraient
  converger vers une valeur unique.

  rkrux a ouvert [Bitcoin Core #35405][] pour empêcher le portefeuille Bitcoin Core de signaler par défaut, en utilisant `nSequence =
  MAX-1`, et a demandé aux autres auteurs de portefeuilles sur quelle valeur ils pourraient se standardiser. Murch et le contributeur
  d'Electrum Wallet SomberNight ont souligné que `MAX-2` est déjà la valeur dominante, utilisée par environ 75 % des transactions selon
  [mainnet-observer][bip125 graph] et par presque toutes les transactions d'Electrum Wallet. Étant donné que la plupart des transactions
  signalent encore, faire passer Bitcoin Core à la valeur non signalante `MAX-1` ferait ressortir ses transactions au lieu de les fondre
  dans la masse ; tous deux ont donc préféré converger vers `MAX-2` à la place. rkrux a fermé la PR à la lumière de ces retours.

## Changements dans les services et logiciels clients

*Dans cette rubrique mensuelle, nous mettons en lumière des mises à jour intéressantes des portefeuilles et services Bitcoin.*

- **Sparrow Wallet 2.5.0 ajoute la réception de silent payments :** Sparrow [2.5.0][sparrow 2.5.0] ajoute des portefeuilles de réception
  [silent payments][topic silent payments], y compris des signataires de portefeuilles matériels airgapped, en s'appuyant sur la prise en
  charge de l'envoi ajoutée dans la version 2.3.0 (voir le [Bulletin #377][news377 sparrow]).

- **Bark en ligne sur le mainnet Bitcoin :** Second a [annoncé][bark mainnet] que Bark, son implémentation du protocole [Ark][topic ark],
  fonctionne désormais sur le mainnet Bitcoin, avec un serveur Ark public ainsi que le SDK Bark et le démon `barkd` pour les développeurs.
  Bark avait auparavant été lancé sur signet (voir le [Bulletin #346][news346 bark]).

- **Annonce du portefeuille Ark Arké :** [Arké][arke] est un portefeuille iOS natif intégrant le protocole [Ark][topic ark] avec les
  paiements onchain ([BDK][bdk repo]) et Lightning, affichant les transactions des trois couches dans un historique combiné unique. Il
  fonctionne actuellement sur signet, avec le mainnet à venir.

- **Annonce du portefeuille Ark Noah :** [Noah][noah] est un portefeuille mobile multiplateforme construit sur le protocole [Ark][topic ark]
  avec prise en charge de Lightning et une conception minimisant la confiance. Il est actuellement en bêta.

- **Publication d'Alby Hub v1.23.0 :** Alby Hub [v1.23.0][alby hub v1.23.0] ajoute des [canaux just-in-time][topic jit channels] qui
  s'ouvrent automatiquement pour accepter des paiements entrants ainsi qu'un backend de paiement [Ark][topic ark] expérimental, parmi
  d'autres améliorations.

- **Publication de JoinMarket NG 0.32.0 :** JoinMarket-NG, un fork maintenu par la communauté de l'implémentation [coinjoin][topic
  coinjoin], a [publié][joinmarket 0.32.0] la prise en charge du mempool pour le backend [Neutrino][topic compact block filters] afin que
  les takers puissent vérifier les diffusions des makers, parmi d'autres améliorations de la fidélité des obligations et de la fiabilité.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning
BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #35221][] ajoute la prise en charge du cadre de négociation des fonctionnalités de pair [BIP434][] (voir les Bulletins
  [#386][news386 bip434] et [#390][news390 bip434]). Il ajoute un message P2P `feature` qui peut être échangé entre `version` et `verack`
  pour annoncer des fonctionnalités optionnelles entre pairs, et augmente le numéro de version du protocole P2P à `70017`. Bitcoin Core
  implémente actuellement le mécanisme de négociation, ignore les identifiants de fonctionnalité valides inconnus, et déconnecte les pairs
  qui envoient des messages `feature` mal formés, les envoient après `verack`, ou les envoient sans avoir négocié une version de protocole
  compatible. Il n'annonce pas encore de fonctionnalité optionnelle spécifique.

- [Bitcoin Core #35254][] efface de la mémoire du matériel supplémentaire de dérivation de clés après utilisation. `CHMAC_SHA256` et
  `CHMAC_SHA512` nettoient désormais leurs tampons de pile temporaires `rkey` et `temp` de hachage interne, qui peuvent contenir des données
  dérivées des codes de chaîne [BIP32][topic bip32] ou du matériel de clé HKDF de [BIP324][topic v2 p2p transport]. Le type de `ChainCode` a
  été changé d'un typedef `uint256` vers un type disposant d'un destructeur `memory_cleanse()`, effaçant les codes de chaîne [BIP32][] dans
  les clés étendues et les variables locales lorsque ces objets sont détruits.

- [Bitcoin Core #35498][] corrige une situation de concurrence dans le chemin RPC `FetchBlock` lors de la demande d'un bloc à un pair en
  cours de déconnexion. `FetchBlock` pouvait obtenir une référence de pair valide avant de verrouiller `cs_main`, mais le nettoyage du pair
  pouvait supprimer le `CNodeState` du pair avant que `BlockRequested()` n'enregistre la requête, provoquant un échec d'assertion. Le
  correctif verrouille `cs_main` avant de rechercher le pair, garantissant que l'état du pair ne peut pas être supprimé pendant
  l'enregistrement de la requête de bloc.

- [Eclair #3318][] corrige un cas limite de reconnexion de [splicing][topic splicing] où Eclair pouvait mettre à jour son état local pour
  une transaction de financement de splice nouvellement verrouillée sans envoyer `splice_locked`. Cela pouvait se produire après qu'Eclair
  ait envoyé `channel_reestablish` mais avant qu'il ait reçu le `channel_reestablish` du pair, laissant les pairs désynchronisés sur les
  états de financement qui nécessitent des messages `commit_sig` et provoquant une fermeture forcée. Eclair gère désormais les événements de
  verrouillage de financement pendant la reconnexion et envoie `splice_locked` lorsque nécessaire.

- [LND #10789][] pose les bases de l'implémentation des [offres BOLT12][topic offers] : un paquet codec `bolt12` indépendant du démon avec
  un type de message `Offer` et l'infrastructure TLV `lnwire` associée. Le nouveau codec valide les messages avant l'encodage, maintient un
  décodage bas niveau permissif pour le diagnostic et le fuzzing, et préserve les TLV inconnus dans la plage signée afin que `offer_id`
  reste stable entre le décodage et le réencodage.

- [Rust Bitcoin #6321][] renforce le décodage du témoin [segwit][topic segwit] afin d'empêcher qu'un nombre d'éléments contrôlé par un
  attaquant ne provoque une allocation mémoire excessive. Auparavant, quelques octets d'entrée pouvaient prétendre à une grande pile de
  témoins et forcer une allocation d'environ 16 Mo pour l'espace d'index des témoins. Le nouveau décodeur ajoute les octets de témoin reçus
  à son tampon de contenu et construit l'index des éléments dans `end()` après le décodage des données de témoin, supprimant l'ancien chemin
  d'allocation par lots.

- [LDK #4685][] replace le nonce utilisé pour la vérification des factures [BOLT12][topic offers] dans les métadonnées du payeur de la
  demande de facture ou du remboursement. Le nonce avait auparavant été retiré parce qu'il était aussi stocké dans le `OffersContext` du
  [chemin de réponse aveuglé][topic rv routing], mais cela faisait dépendre la vérification d'une facture d'un état extérieur à la demande
  de facture ou au remboursement eux-mêmes, ce qui est incompatible avec les prochaines [preuves de paiement][topic proof of payment]
  [BOLT12][] (voir le [Bulletin #405][news405 proof]). Les contextes de chemin de réponse des offres sortantes et des remboursements ne
  stockent désormais plus que le `PaymentId` attendu, qui est vérifié par rapport à l'identifiant de paiement récupéré à partir des
  métadonnées du payeur de la facture reçue.

{% include snippets/recap-ad.md when="2026-06-23 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="35405,35221,35254,35498,3318,10789,6321,4685" %}

[bip125 ml]: https://groups.google.com/g/bitcoindev/c/C7zNIk8llew/m/YAdpwe33AgAJ
[bip125 graph]: https://mainnet.observer/charts/transactions-signaling-explicit-rbf/
[news315 fullrbf]: /fr/newsletters/2024/08/09/#bitcoin-core-30493
[news329 fullrbf]: /fr/newsletters/2024/11/15/#bitcoin-core-30592
[sparrow 2.5.0]: https://github.com/sparrowwallet/sparrow/releases/tag/2.5.0
[news377 sparrow]: /fr/newsletters/2025/10/24/#sortie-de-sparrow-2-3-0
[bark mainnet]: https://blog.second.tech/bark-now-on-bitcoin-mainnet/
[arke]: https://github.com/GBKS/arke
[noah]: https://github.com/smolcars/noah
[news346 bark]: /fr/newsletters/2025/03/21/#bark-lance-sur-signet
[alby hub v1.23.0]: https://github.com/getAlby/hub/releases/tag/v1.23.0
[joinmarket 0.32.0]: https://github.com/joinmarket-ng/joinmarket-ng/releases/tag/0.32.0
[news386 bip434]: /fr/newsletters/2026/01/02/#negociation-de-fonctionnalites-entre-pairs
[news390 bip434]: /fr/newsletters/2026/01/30/#bips-2076
[news405 proof]: /fr/newsletters/2026/05/15/#core-lightning-9116
