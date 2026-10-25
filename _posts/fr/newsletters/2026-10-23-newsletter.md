---
title: 'Bulletin Hebdomadaire Bitcoin Optech #428'
permalink: /fr/newsletters/2026/10/23/
name: 2026-10-23-newsletter-fr
slug: 2026-10-23-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit une conception pour une couche 2 à émetteur unique dont les utilisateurs peuvent récupérer leurs
bitcoins onchain sans la coopération de l'émetteur et résume une proposition visant à inclure des préimages de hachage dans les descripteurs
de script de sortie. Sont également incluses nos rubriques régulières décrivant les changements récents dans les services et logiciels
clients, annonçant de nouvelles versions et versions candidates, et décrivant des changements notables dans les logiciels populaires
d'infrastructure Bitcoin.

## Nouvelles

- **Sorties à confiance minimisée depuis une couche 2 à émetteur unique :** Adam Gibson a [publié][lichen ml] sur la liste de diffusion
  Bitcoin-Dev un [article][lichen paper] et du [code][lichen repo] de preuve de concept pour Lichen, une conception dans laquelle un
  émetteur unique, que Gibson appelle un hub, crée des jetons échangeables un-pour-un contre des bitcoins sur un registre de couche 2 opéré
  par un serveur appelé le séquenceur. Chaque utilisateur détient un contrat 2-sur-2 avec le hub qui lui permet de récupérer ses jetons même
  si le hub refuse ou est hors ligne, de sorte que les utilisateurs font confiance au séquenceur pour exécuter honnêtement le registre, mais
  pas au hub pour leur rendre leurs bitcoins. La conception s'appuie sur LN-GAP (voir le [Bulletin #427][news427 lngap]) mais remplace son
  comité d'attestation à majorité honnête par un litige réglé entièrement onchain.

  Chaque utilisateur verrouille des bitcoins dans sa propre sortie 2-sur-2 avec le hub et reçoit le même montant de jetons sur le registre
  de couche 2, où les utilisateurs se paient entre eux sans toucher à la chaîne. Pour sortir, un utilisateur rend des jetons au hub et
  récupère des bitcoins depuis sa propre sortie. Comme cette sortie est la seule sur laquelle un utilisateur peut tirer, le hub verrouille
  également une partie de ses propres bitcoins dans chaque sortie jusqu'à un plafond négocié, comme la liquidité entrante LN, afin que
  l'utilisateur puisse récupérer les jetons reçus d'autres personnes. Les jetons reçus au-delà du plafond ne sont récupérables qu'à la
  discrétion du hub.

  Dans le cas coopératif, le hub signe simplement un règlement de la sortie payant l'utilisateur. S'il refuse ou ne répond pas,
  l'utilisateur génère une preuve Groth16 que le séquenceur a signé un état enregistrant les jetons retournés. Comme Script ne peut pas
  vérifier une telle preuve, l'utilisateur affirme à la place sur la chaine qu'un programme de vérification fixe l'accepte, et si le hub conteste
  cela, des transactions [BitVMX][topic acc] présignées réduisent le désaccord à une seule étape d'exécution que Script peut vérifier.
  Chaque partie verrouille une réserve qu'elle perd en cas de perte d'un litige, ce qui dissuade les fausses affirmations et les refus.
  Gibson reconnaît qu'un séquenceur qui omet le retour d'un utilisateur, ou signe un état qu'il n'a jamais atteint valablement, peut
  toujours faire perdre des fonds à l'utilisateur ou au hub, et il mentionne comme travaux futurs des preuves de validité et un comité de
  séquenceurs.

- **Syntaxe de descripteur pour les préimages de hachage :** João Dias a [publié][desc del] sur Delving Bitcoin une proposition visant à
  étendre [BIP379][] pour ajouter à [miniscript][topic miniscript] une forme privée pour les fragments de hachage. À ce jour, il n'existe
  aucun moyen de fournir directement une préimage au portefeuille de Bitcoin Core pour dépenser des fonds qui en nécessitent une afin de
  satisfaire une condition de dépense. Il n'est possible de la fournir qu'au moyen d'outils externes dans l'un des champs de hachage
  [PSBT][topic psbt] (par ex. `PSBT_IN_SHA256`). L'auteur a noté que cette proposition ne couvre que les préimages déjà connues lors de la
  création d'un descripteur, et non celles apprises au moment de la dépense, comme dans un [HTLC][topic htlc].

  Dias a expliqué que la préimage devrait être traitée davantage comme une clé que comme une signature, mettant en évidence une incohérence
  dans le modèle des [descripteurs][topic descriptors]. Son idée vise à permettre à un portefeuille d'importer un secret depuis un
  descripteur et de construire et signer une transaction directement. Pour ce faire, l'auteur a proposé une syntaxe spécifique pour le
  descripteur (par ex. `sha256(preimage(HEX))`) et un ensemble de contraintes, comme le besoin d'un marqueur spécifique au lieu
  d'hexadécimal brut, une taille fixe de 32 octets pour tous les fragments de hachage, et l'exigence de traiter la préimage comme tout autre
  secret, avec sauvegardes, chiffrement, et sans jamais l'afficher dans la chaîne publique du descripteur.

  Avant de procéder à la formalisation de la proposition, Dias a souligné certains points ouverts qui doivent être traités, tels que la
  syntaxe que le marqueur devrait avoir, s'il faut amender BIP379 ou rédiger un nouveau BIP, s'il est nécessaire d'ajouter un appel RPC pour
  que Bitcoin Core gère les préimages, si les dispositifs matériels de signature devraient gérer les secrets de préimage ou si cela devrait
  rester réservé aux portefeuilles logiciels, et s'il existe un intérêt à dériver de manière déterministe des préimages à partir du matériel
  de clé.

## Changements dans les services et logiciels clients

*Dans cette rubrique mensuelle, nous mettons en lumière des mises à jour intéressantes des portefeuilles et services Bitcoin.*

- **Publication d'Ibis Wallet v5.0-beta :** [Ibis Wallet v5.0-beta][ibis v5.0] (voir le [Bulletin #406][news406 ibis]) ajoute la prise en
  charge d'[Ark][topic ark] construite sur Bark, des sorties unilatérales du [statechain][topic statechains] Spark, et la réception vers des
  adresses de [silent payment][topic silent payments].

- **Portefeuille Landfall pour les paiements de minage Lightning :** [Landfall][landfall gh] est un portefeuille de preuve de concept,
  montrant l'expérience utilisateur réalisable aujourd'hui, qui dérive à partir d'une seule graine l'adresse de paiement, l'[offre
  BOLT12][topic offers], et la signature [BIP322][topic generic signmessage] que le pool de minage OCEAN exige pour payer les récompenses
  sur LN, en utilisant un nœud hébergé par Lexe (voir le [Bulletin #419][news419 lexe]). Il n'est pas destiné à un usage en production.

- **Publication de rbitcoin 0.8.0 :** [rbitcoin 0.8.0][rbitcoin 0.8.0] est un nœud complet Bitcoin écrit en Rust et construit sur
  rust-bitcoin, décrit comme entièrement écrit par IA, pour les backends de portefeuilles et Lightning, qui remplace l'ensemble UTXO par une
  archive relationnelle, sert des API de type Electrum et Esplora, et utilise exclusivement [BIP324][topic v2 p2p transport].

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires. Veuillez envisager de mettre à niveau vers
les nouvelles versions ou d'aider à tester les versions candidates._

- [Eclair 0.14.4][] et [0.14.5][Eclair 0.14.5] sont des versions de sécurité pour cette implémentation de nœud LN. La version 0.14.4 corrige
  plusieurs problèmes liés au [splicing][topic splicing], au règlement des [HTLC][topic htlc], au [financement à la volée][topic jit
  channels], et à l'analyse des oignons, comme décrit dans le [Bulletin #427][news427 eclair fixes]. Elle rejette également les requêtes
  d'API avec un en-tête `Origin` afin d'empêcher les falsifications de requêtes intersites utilisant des informations d'authentification
  HTTP Basic mises en cache (voir le [Bulletin
  #423][news423 eclair api]). Les intégrations basées sur navigateur doivent
  désormais utiliser leur propre backend pour appeler Eclair. La version 0.14.5 corrige les vulnérabilités de routage trampoline et de
  splicing taproot décrites ci-dessous, et ferme un contournement par dépassement d'entier de la validation de la longueur de la charge
  utile onion couvert dans le [Bulletin
  #427][news427 eclair onion]. Le projet recommande fortement la mise à niveau.

- [BDK chain 0.23.4][] est une version de maintenance des bibliothèques de BDK pour construire des portefeuilles Bitcoin. Elle corrige des
  problèmes de suivi des transactions et d'analyses complètes qui s'arrêtent avant de vérifier toutes les adresses précédemment révélées.
  Des mises à jour associées corrigent la synchronisation RPC de Bitcoin Core après des reorgs et incluent des correctifs Electrum déjà
  couverts pour la [vérification de txid][news403 bdk txid], la [détection de confirmation pour les transactions avec une première sortie
  `OP_RETURN`][news405 bdk opreturn], et le [suivi des confirmations après des reorgs][news427 bdk reorg].

- [LND v0.21.5-beta.rc1][] et [v0.20.6-beta.rc1][LND v0.20.6-beta.rc1] sont des versions candidates pour des versions de maintenance de
  cette implémentation populaire de nœud LN. Les deux incluent la gestion des mises à jour de frais et les limites sur les messages de canal
  décrites dans le [Bulletin
  #418][news418 lnd fees], ainsi que des correctifs pour les taux de frais des
  engagements, l'allocation mémoire excessive lors de l'analyse des enregistrements TLV, et les interblocages de base de données SQL. La
  version 0.21.5 inclut également le correctif auxiliaire de validation de signature [HTLC][topic htlc] pour les canaux [Taproot
  Assets][topic client-side validation] décrit dans le [Bulletin #427][news427 lnd aux], et corrige la synchronisation du portefeuille lors
  des réorganisations de la blockchain.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning
BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Eclair #3409][] corrige une vulnérabilité qui pouvait permettre à un payeur malveillant de voler des fonds à un nœud relayant des
  [paiements trampoline][topic trampoline payments]. Eclair limite désormais le [delta d'expiration CLTV][topic cltv expiry delta] total
  d'une route en aval afin de s'assurer que le HTLC sortant expire avant le HTLC entrant (voir le [Bulletin
  #423][news423 eclair cltv] pour un correctif connexe). Auparavant, lorsque la
  recherche de chemin échouait, Eclair réessayait avec des limites assouplies sur la longueur de route et l'expiration, permettant à un
  payeur de fournir des indications de routage ou des [chemins aveuglés][topic rv routing] avec des deltas d'expiration excessifs. Le payeur
  pouvait alors récupérer onchain le HTLC entrant après son expiration, tandis que le destinataire pouvait toujours réclamer le HTLC
  sortant. Eclair n'assouplit désormais que la limite de longueur de route, préservant l'ordre d'expiration requis.

- [Eclair #3411][] corrige une vulnérabilité qui pouvait permettre à un pair de canal malveillant de voler des fonds en amenant Eclair à
  signer une transaction de [splice][topic splicing] invalide (voir le [Bulletin
  #427][news427 eclair splice] pour des correctifs associés). Lors du splicing
  de [canaux taproot simples][topic simple taproot channels], un pair peut ne fournir que le montant et le script d'une sortie précédente
  d'une entrée au lieu de la transaction complète. Auparavant, Eclair faisait confiance à ces valeurs sans les vérifier. Un pair pouvait
  mentir sur l'un ou l'autre champ, amenant Eclair à signer une transaction de splice qui ne pourrait jamais être confirmée, car les
  signatures taproot s'engagent sur les montants et scripts réels des entrées dépensées. Néanmoins, Eclair traiterait le splice invalide
  comme son état de financement de canal le plus récent. Le pair pourrait alors publier un engagement précédemment signé dépensant la sortie
  de financement précédente et réclamer un [HTLC][topic htlc] sortant en utilisant sa préimage de paiement après que le HTLC entrant
  correspondant d'Eclair ait expiré et ait été remboursé, laissant Eclair incapable de collecter le paiement relayé. Eclair vérifie
  désormais les sorties revendiquées auprès de son backend Bitcoin avant de signer.

- [LDK #5126][] corrige un bogue où des paiements [BOLT12][topic offers] utilisant des [chemins aveuglés][topic rv routing] à un saut
  pouvaient être rejetés parce que leur expiration HTLC était trop courte. Auparavant, LDK ignorait le `cltv_expiry_delta` du chemin parce
  que le nœud d'introduction était aussi le destinataire. Cela négligeait le fait qu'il inclut le [delta CLTV final][topic cltv expiry
  delta] requis par le destinataire. En conséquence, les paiements ne satisfaisaient à l'exigence minimale du destinataire que lorsque le
  décalage CLTV aléatoire de LDK était suffisamment grand. Cela provoquait des échecs intermittents de paiement lors des tests avec Core
  Lightning. LDK inclut désormais le delta annoncé lors de la construction de la route et lors de la vérification de son delta CLTV total
  maximal autorisé.

- [LND #10919][] ajoute un système expérimental de réputation locale pour atténuer les [attaques de bourrage de canaux][topic channel
  jamming attacks], basé sur le schéma proposé de responsabilisation des HTLC (voir les Bulletins [#377][news377 jamming] et [#387][news387
  accountability]), qui remplace l'approche antérieure d'[approbation HTLC][topic htlc endorsement]. Le système note les canaux sortants en
  fonction de l'activité passée de relais et des frais annoncés par le nœud, en pénalisant les [HTLC][topic htlc] responsables qui prennent
  trop de temps à se résoudre. Le système est activé par défaut et journalise si les HTLC seraient admissibles à des ressources protégées,
  sans affecter les décisions de relais. La réputation est réinitialisée au redémarrage.

- [BTCPay Server #7679][] corrige un bogue qui pouvait conduire à des paiements Lightning dupliqués. Auparavant, si un paiement était initié
  et qu'une recherche ultérieure de paiement ne renvoyait aucun résultat, BTCPay Server annulait le paiement et supprimait son hachage de
  paiement enregistré. Cela se produisait même si le paiement avait réussi. En conséquence, un opérateur pouvait émettre un autre paiement
  pour un paiement qui avait déjà réussi. BTCPay Server conserve désormais les paiements en cours et leurs hachages de paiement pour des
  vérifications ultérieures.

- [BTCPay Server #7684][] corrige une élévation de privilèges dans l'autorisation des clés d'API Greenfield. Auparavant, une clé d'API
  limitée à une boutique particulière pouvait exercer des autorisations à l'échelle du serveur ou du compte malgré sa portée limitée. De
  plus, une clé autorisée à créer des clés d'API pour d'autres utilisateurs pouvait aussi accorder des autorisations plus larges que les
  siennes. BTCPay Server applique désormais les portées d'autorisation lors de l'autorisation des requêtes et empêche les clés d'API
  d'accorder des autorisations qu'elles ne possèdent pas. Les clés administrateur existantes non restreintes conservent leurs capacités
  prévues.

- [BDK #2325][] et [#2360][bdk #2360] corrigent deux bogues qui pouvaient amener le portefeuille à signaler une synchronisation réussie sans
  récupérer les données de transaction demandées. Le premier affecte la synchronisation Electrum d'outpoints individuels. Auparavant, BDK
  ignorait toutes les erreurs rencontrées lors de la récupération de leurs transactions, y compris les échecs de connexion et les délais
  d'attente. Cela pouvait faire qu'une sortie dépensée reste classée comme non dépensée. BDK ignore désormais les erreurs du protocole
  Electrum sur ce chemin tout en propageant les autres échecs. La seconde PR corrige `sync` et `full_scan` dans les clients Electrum et
  Esplora. Auparavant, définir `batch_size` d'Electrum ou `parallel_requests` d'Esplora à zéro pouvait silencieusement ignorer les analyses
  ou récupérations de transactions demandées tout en signalant un succès. Les deux clients traitent désormais zéro comme un pour ces
  paramètres.

- [BOLTs #1357][] met à jour [BOLT11][] afin d'exiger que les lecteurs de factures rejettent les factures sauf si elles contiennent
  exactement un champ de hachage de paiement (`p`) et un champ de secret de paiement (`s`). Auparavant, la spécification recommandait que
  les payeurs utilisent le premier champ `p`, tandis que certains parseurs de facture utilisaient le dernier. Cette divergence a été
  [exploitée contre LNP2PBot][lnp2p incident], dont le parseur de facture et le nœud Lightning sélectionnaient des hachages de paiement
  différents. En conséquence, le bot traitait des paiements complétés comme non payés, permettant aux attaquants d'obtenir des paiements
  dupliqués (voir le [Bulletin #425][news425 lnd]).

- [BOLTs #1352][] corrige plusieurs erreurs dans la spécification et les vecteurs de test des [canaux taproot simples][topic simple taproot
  channels] (voir le [Bulletin #404][news404 taproot]). Des erreurs dans la dérivation de la clé de sortie taproot et dans la construction
  du bloc de contrôle pouvaient produire des dépenses invalides si elles étaient implémentées comme précédemment spécifié. La PR précise
  également que les signatures [HTLC][topic htlc] échangées dans `commitment_signed` utilisent `SIGHASH_SINGLE|SIGHASH_ANYONECANPAY` : le
  pair récepteur ajoute `0x83` à la signature de 64 octets lors de la construction du témoin. Lors de la combinaison de transactions de
  second niveau pour l'augmentation de frais, chaque entrée HTLC et sa sortie correspondante doivent occuper des indices correspondants dans
  la transaction combinée. Des corrections supplémentaires couvrent les [chemins de dépense d'anchor][topic anchor outputs], l'encodage et
  la dérivation de nonce [MuSig2][topic musig], ainsi que les vecteurs de test d'engagement local et distant. Ces changements alignent la
  spécification sur les implémentations existantes de LND et Eclair sans modifier le comportement du protocole.

{% include snippets/recap-ad.md when="2026-10-27 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3409,3411,5126,10919,7679,7684,2325,2360,1357,1352" %}

[lichen ml]: https://groups.google.com/g/bitcoindev/c/yZEZ5P1lj5E
[lichen paper]: https://github.com/AdamISZ/lichen/blob/master/papers/lichen-v0.1.pdf
[lichen repo]: https://github.com/AdamISZ/lichen
[news427 lngap]: /fr/newsletters/2026/10/16/#contrats-hors-chaine-dans-les-canaux-lightning
[ibis v5.0]: https://github.com/aeonBTC/IbisWallet/releases/tag/v5.0.1-beta
[news406 ibis]: /fr/newsletters/2026/05/22/#annonce-d-ibis-wallet
[landfall gh]: https://github.com/vincenzopalazzo/landfall
[news419 lexe]: /fr/newsletters/2026/08/21/#lexe-ajoute-des-adresses-lisibles-par-les-humains-et-lnurl-withdraw
[rbitcoin 0.8.0]: https://github.com/reardencode/rbitcoin/releases/tag/v0.8.0
[desc del]: https://delvingbitcoin.org/t/descriptor-syntax-for-hash-preimages/2935
[Eclair 0.14.4]: https://github.com/ACINQ/eclair/releases/tag/v0.14.4
[Eclair 0.14.5]: https://github.com/ACINQ/eclair/releases/tag/v0.14.5
[BDK chain 0.23.4]: https://github.com/bitcoindevkit/bdk/releases/tag/chain-0.23.4
[LDK #5126]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5126
[lnp2p incident]: https://x.com/negrunch/status/2097763741123166576
[news423 eclair api]: /fr/newsletters/2026/09/18/#eclair-3380
[news427 eclair fixes]: /fr/newsletters/2026/10/16/#changements-notables-dans-le-code-et-la-documentation
[news427 eclair onion]: /fr/newsletters/2026/10/16/#eclair-3395
[news403 bdk txid]: /fr/newsletters/2026/05/01/#bdk-2188
[news405 bdk opreturn]: /fr/newsletters/2026/05/15/#bdk-2195
[news427 bdk reorg]: /fr/newsletters/2026/10/16/#bdk-2319
[news423 eclair cltv]: /fr/newsletters/2026/09/18/#eclair-3376
[news427 eclair splice]: /fr/newsletters/2026/10/16/#eclair-3396
[news377 jamming]: /fr/newsletters/2025/10/24/#resultats-de-simulation-de-la-mitigation-du-brouillage-de-canaux-et-mises-a-jour
[news387 accountability]: /fr/newsletters/2026/01/09/#lnd-10367
[news425 lnd]: /fr/newsletters/2026/10/02/#lnd-11190
[news404 taproot]: /fr/newsletters/2026/05/08/#bolts-995
[LND v0.21.5-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.21.5-beta.rc1
[LND v0.20.6-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.6-beta.rc1
[news418 lnd fees]: /fr/newsletters/2026/08/14/#lnd-11023
[news427 lnd aux]: /fr/newsletters/2026/10/16/#lnd-11068
