---
title: 'Bulletin Hebdomadaire Bitcoin Optech #325'
permalink: /fr/newsletters/2024/10/18/
name: 2024-10-18-newsletter-fr
slug: 2024-10-18-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine examine les résumés de certains des sujets discutés lors d'une récente
réunion de développeurs LN. Il contient également nos sections régulières avec des descriptions des
changements apportés aux clients et services populaires, des annonces de nouvelles versions et de
candidats à la version, et des résumés des changements notables apportés aux logiciels
d'infrastructure Bitcoin populaires.

## Nouvelles

- **Notes du Sommet LN 2024 :** Olaoluwa Osuntokun a [publié][osuntokun summary] sur Delving Bitcoin
  un résumé de ses [notes][osuntokun notes] (avec des commentaires supplémentaires) d'une récente
  conférence de développeurs LN. Certains des sujets discutés comprenaient :

  - **Transactions d'engagement de version 3 :** les développeurs ont discuté de l'utilisation de
	  [nouvelles fonctionnalités P2P][bcc28 guide], incluant les transactions [TRUC][topic v3 transaction
    relay] et les sorties [P2A][topic ephemeral anchors], pour améliorer la sécurité des transactions
    d'engagement LN qui peuvent être utilisées pour fermer un canal unilatéralement. La discussion s'est
    concentrée sur divers compromis de conception.

  - **PTLCs :** bien que proposés depuis longtemps comme une amélioration de la confidentialité pour
    LN, ainsi que potentiellement utiles à d'autres fins telles que les [transactions sans
    blocage][topic redundant overpayments], des recherches récentes sur les compromis de diverses
    implémentations possibles de [PTLC][topic ptlc] ont été discutées (voir le [Bulletin #268][news268
    ptlc]). Un focus particulier a été mis sur la construction de l'[adaptateur de signature][topic
    adaptor signatures] (par exemple, en utilisant multisig scripté versus [MuSig2][topic musig] sans
    script) et son effet sur le protocole d'engagement (voir point suivant).

  - **Protocole de mise à jour d'état :** une proposition a été discutée pour convertir le protocole
    de mise à jour d'état actuel de LN, permettant à chaque partie de proposer une mise à jour à tout
    moment, pour permettre uniquement à une partie à la fois de proposer des mises à jour (voir les
    Bulletins [#120][news120 simcom] et [#261][news261 simcom]). Permettre à chaque partie de proposer
    des mises à jour peut entraîner des propositions simultanées, ce
    qui est difficile à conceptualiser et peut conduire à des fermetures forcées accidentelles du canal.
    L'alternative est que seulement une partie soit en charge à la fois, par exemple, Alice est
    initialement la seule autorisée à proposer des mises à jour d'état ; si elle n'a rien à proposer,
    elle peut informer Bob qu'il est en charge. Lorsque Bob a fini de proposer des mises à jour, il peut
    transférer le contrôle à Alice. Cela simplifie la conceptualisation du protocole, élimine les
    problèmes liés aux propositions simultanées et facilite également le rejet de toute proposition
    indésirable par la partie non contrôlante. Le nouveau protocole basé sur des tours fonctionnerait
    également bien avec les adaptateurs de signature basés sur MuSig2.

  - **SuperScalar :** le développeur d'une proposition de construction d'[usines à canaux][topic
    channel factories] pour les utilisateurs finaux a présenté sa proposition et
    sollicité des retours. Optech publiera une description plus détaillée de [SuperScalar][zmnscpxj
    superscalar] dans un bulletin futur.

  - **Mise à niveau du gossip :** Les développeurs ont discuté des mises à jour du [protocole Gossip
    du LN][topic channel announcements]. Ces mises à jour sont nécessaires pour supporter de nouveaux types
    de transactions de financement, comme pour les [canaux taproot simples][topic simple taproot channels],
    mais peuvent aussi ajouter un support pour d'autres fonctionnalités. L'une des nouvelles fonctionnalités
    discutées consistait à inclure dans les messages d'annonce de canal une preuve SPV (ou un engagement
    envers une preuve SPV) afin de permettre aux clients légers de vérifier qu'une transaction de financement
    (ou une transaction de parrainage) a été incluse dans un bloc à un moment ou à un autre.
  - **Recherche sur les limites fondamentales de la distribution:**  Des recherches ont été présentées sur
    les flux de paiement qui ne peuvent pas aboutir en raison des limites du réseau (par exemple, des canaux
    à capacité insuffisante) ; voir le [Bulletin #309][news309 feasible]. Si un paiement LN est irréalisable,
    l'émetteur et le récepteur peuvent toujours utiliser un paiement onchain. Il est donc possible de calculer
    le débit maximal (paiements par seconde) du système combiné Bitcoin et LN en divisant le taux maximal
    onchain par le taux de paiements LN infaisables. En utilisant cette mesure approximative, pour atteindre
    un maximum d'environ 47 000 paiements par seconde, le taux d'infaisabilité doit être inférieur à 0,29 %.
    Deux techniques ont été examinées pour réduire le taux d'infaisabilité : (1) les canaux virtuels ou réels
    qui impliquent plus de deux parties, car plus de parties implique plus de fonds pour le transfert et plus
    de fonds pour le transfert augmente le taux de faisabilité ; et (2) les canaux de crédit où les parties
    qui se font confiance peuvent transférer des paiements entre elles sans la capacité d'exécuter ces
    paiements onchain---avec tous les autres utilisateurs recevant toujours des paiements sans confiance.

  Osuntokun a encouragé les autres participants à apporter des corrections ou des compléments au fil de discussion.

## Modifications apportées aux services et aux logiciels clients

*Dans cette rubrique mensuelle, nous mettons en lumière des mises à jour intéressantes des
portefeuilles et services Bitcoin.*

- **Coinbase ajoute le support d'envoi taproot :**
  La plateforme d'échange Coinbase [supporte maintenant][coinbase post] les retraits des utilisateurs (envoi) vers
  des adresses taproot [bech32m][topic bech32].

- **Sortie du portefeuille Dana :**
  [Dana wallet][dana wallet github] est un portefeuille pour [paiements silencieux][topic silent
  payments] axé sur le cas d'utilisation des dons. Les développeurs recommandent d'utiliser
  [signet][topic signet] et gèrent également un [faucet signet][dana wallet faucet].

- **Sortie du client léger Kyoto BIP157/158 :**
  [Kyoto][kyoto github] est un client léger en Rust utilisant [les filtres de blocs compacts][topic
  compact block filters] destiné aux développeurs de portefeuilles.

- **Lancement de DLC Markets sur le réseau principal :**
  La plateforme basée sur [DLC][topic dlc] [a annoncé][dlc markets blog] la disponibilité sur le
  réseau principal de son service de trading non-custodial.

- **Annonce du portefeuille Ashigaru :**
  Ashigaru est un fork du projet Samourai Wallet et l'[annonce][ashigaru blog] a listé des
  améliorations au [batching][scaling payment batching], support [RBF][topic rbf], et [estimation des
  frais][topic fee estimation].

- **Annonce du protocole DATUM :**
  Le [protocole de minage DATUM][datum docs] permet aux mineurs de construire des blocs candidats dans
  le cadre d'une configuration de [minage en pool][topic pooled mining], similaire au protocole
  Stratum v2.

- **Annonce de l'implémentation de Bark Ark :** L'équipe Second a [annoncé][bark blog]
  l'implémentation de [Bark][bark codeberg] du protocole [Ark][topic ark] et a [démontré][bark demo]
  des transactions Ark en direct sur le mainnet.

- **Sortie de Phoenix v2.4.0 et phoenixd v0.4.0 :**
  Les versions [Phoenix v2.4.0][phoenix v2.4.0] et [phoenixd v0.4.0][] ajoutent le support pour la
  proposition de financement à la volée [BLIP36][blip36] et d'autres fonctionnalités de liquidité
  (voir le [Podcast #323][pod323 eclair]).

## Mises à jour et versions candidates

*Nouvelles versions et candidats à la version pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les candidats
à la version.*

- [BDK 1.0.0-beta.5][] est un candidat à la sortie (RC) de cette bibliothèque pour la construction
  de portefeuilles et d'autres applications activées par Bitcoin. Ce dernier RC "active RBF par défaut
  et met à jour le client bdk_esplora pour réessayer les requêtes serveur qui échouent en raison de la
  limitation du taux. Le paquet `bdk_electrum` offre maintenant également une fonctionnalité
  use-openssl."

## Changements notables dans le code et la documentation

_Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration de Bitcoin (BIPs)][bips
repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Inquisition Bitcoin][bitcoin
inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #30955][] introduit deux nouvelles méthodes à l'interface `Mining` (voir le Bulletin
  [#310][news310 mining]), conformément aux exigences pour [Stratum V2][topic pooled mining]. La
  méthode `submitSolution()` permet aux mineurs de soumettre une solution de bloc plus efficacement en
  ne nécessitant que le nonce, le timestamp, les champs de version, et la transaction coinbase, au
  lieu du bloc entier. De plus, `getCoinbaseMerklePath()` est introduit pour construire le champ du
  chemin merkle requis dans le message `NewTemplate`. Cette PR réinstaure également
  `BlockMerkleBranch`, qui avait été retiré précédemment dans [Bitcoin Core #13191][].

- [Eclair #2927][] ajoute l'application des taux de frais recommandés (voir le Bulletin
  [#323][news323 fees]) pour le financement à la volée (voir le Bulletin [#323][news323 fly]), en
  rejetant les messages `open_channel2` et `splice_init` qui utilisent un taux de frais inférieur à la
  valeur recommandée.

- [Eclair #2922][] supprime le support pour le [splicing][topic splicing] sans quiescence du canal
  (voir le Bulletin [#309][news309 quiescence]), pour se conformer au dernier protocole de splicing tel
  que proposé dans [BOLTs #1160][], qui exige que les nœuds utilisent le protocole de quiescence
  pendant le splicing. Auparavant, le splicing était
  autorisé sous un mécanisme moins formel, où les messages de raccordement étaient permis si les
  engagements étaient déjà en repos, agissant comme une version simplifiée de la quiescence des
  canaux.

- [LDK #3235][] ajoute un champ `last_local_balance_msats` à l'événement `ChannelForceClosed`, qui
  donne le solde local d'un nœud en millisatoshis (msats) juste avant que le canal ne soit fermé de
  force, permettant aux utilisateurs de savoir combien de msats ils ont perdus à cause de l'arrondi.

- [LND #8183][] ajoute le champ optionnel `CloseTxInputs` à la structure `chanbackup.Single` dans le
  fichier de [sauvegarde de canal statique][topic static channel backups] (SCB), pour stocker les
  entrées nécessaires à générer des transactions de fermeture forcée. Cela permet aux utilisateurs de
  récupérer manuellement des fonds lorsque un pair est hors ligne en utilisant la commande `chantools
  scbforceclose` comme une option de récupération de dernier recours. Cependant, les utilisateurs
  doivent faire preuve d'une extrême prudence car cette fonctionnalité pourrait entraîner la perte de
  fonds si le canal a été mis à jour depuis la création de la sauvegarde. De plus, la PR introduit la
  méthode `ManualUpdate`, qui mettra à jour les sauvegardes de canal chaque fois que LND s'éteint.

- [Rust Bitcoin #3450][] ajoute v3 comme une nouvelle variante de la version de transaction, suivant
  l'acceptation par Bitcoin Core des transactions [Topologically Restricted Until Confirmation
  (TRUC)][topic v3 transaction relay] comme standard (voir le Bulletin [#307][news307 truc]).

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30955,2927,2922,3235,8183,3450,13191,1160" %}
[BDK 1.0.0-beta.5]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.5
[osuntokun summary]: https://delvingbitcoin.org/t/ln-summit-2024-notes-summary-commentary/1198
[osuntokun notes]: https://docs.google.com/document/d/1erQfnZjjfRBSSwo_QWiKiCZP5UQ-MR53ZWs4zIAVcqs/edit?tab=t.0#heading=h.chk08ds793ll
[news268 ptlc]: /fr/newsletters/2023/09/13/#changements-de-messagerie-ln-pour-les-ptlc
[news120 simcom]: /en/newsletters/2020/10/21/#simplified-htlc-negotiation
[news261 simcom]: /fr/newsletters/2023/07/26/#engagements-simplifies
[zmnscpxj superscalar]: https://delvingbitcoin.org/t/superscalar-laddered-timeout-tree-structured-decker-wattenhofer-factories/1143
[news309 feasible]: /fr/newsletters/2024/06/28/#estimation-de-la-probabilite-qu-un-paiement-ln-soit-realisable
[bcc28 guide]: /fr/bitcoin-core-28-wallet-integration-guide/
[coinbase post]: https://x.com/CoinbaseAssets/status/1843712761391399318
[dana wallet github]: https://github.com/cygnet3/danawallet
[dana wallet faucet]: https://silentpayments.dev/
[saving satoshi editor]: https://script.savingsatoshi.com/
[kyoto github]: https://github.com/rustaceanrob/kyoto
[dlc markets blog]: https://blog.dlcmarkets.com/dlc-markets-reshaping-bitcoin-trading/
[ashigaru blog]: https://ashigaru.rs/news/release-wallet-v1-0-0/
[datum docs]: https://ocean.xyz/docs/datum
[bark blog]: https://blog.second.tech/ark-on-bitcoin-is-here/
[bark codeberg]: https://codeberg.org/ark-bitcoin/bark
[bark demo]: https://blog.second.tech/demoing-the-first-ark-transactions-on-bitcoin-mainnet/
[phoenix v2.4.0]: https://github.com/ACINQ/phoenix/releases/tag/android-v2.4.0
[phoenixd v0.4.0]: https://github.com/ACINQ/phoenixd/releases/tag/v0.4.0
[blip36]: https://github.com/lightning/blips/pull/36
[pod323 eclair]: /en/podcast/2024/10/08/#eclair-2848-transcript
[news310 mining]:/fr/newsletters/2024/07/05/#bitcoin-core-30200
[news323 fees]: /fr/newsletters/2024/10/04/#eclair-2860
[news323 fly]: /fr/newsletters/2024/10/04/#eclair-2861
[news309 quiescence]:/fr/newsletters/2024/06/28/#bolts-869
[news307 truc]: /fr/newsletters/2024/06/14/#bitcoin-core-29496
