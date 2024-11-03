---
title: 'Bulletin Hebdomadaire Bitcoin Optech #319'
permalink: /fr/newsletters/2024/09/06/
name: 2024-09-06-newsletter-fr
slug: 2024-09-06-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume une proposition permettant aux mineurs de pool Stratum v2 de
recevoir une compensation pour les frais de transaction contenus dans les modèles de blocs qu'ils
transforment en parts, annonce un fond de recherche enquêtant sur la proposition de l'opcode `OP_CAT`, et
décrit une discussion sur la mitigation des vulnérabilités des arbres de Merkle avec ou sans un soft
fork. Nous incluons également nos sections habituelles qui annoncent
de nouvelles versions et des versions candidates, et décrivent les changements notables apportés aux
principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Extension Stratum v2 pour le partage des revenus de frais :** Filippo Merli a [publié][merli
  stratumfees] sur Delving Bitcoin un article sur une extension à [Stratum v2][topic pooled mining] qui
  permettra de suivre le montant des frais inclus dans les _parts_ lorsque les parts contiennent des
  transactions sélectionnées par un mineur individuel. Cela peut être utilisé pour ajuster le montant
  payé au mineur par la pool, avec les mineurs sélectionnant des transactions à taux de frais plus
  élevés étant plus rémunérés.

  Merli renvoie à un [document][merli paper] dont il est co-auteur et qui examine certains des défis liés au paiement de montants
  différents à différents mineurs en fonction des transactions qu'ils sélectionnent. Le
  document suggère un schéma compatible avec un schéma de paiement de minage en pool _pay per last N
  shares_ (PPLNS). Son article renvoie à deux implémentations du schéma en cours.

- **Fonds de recherche OP_CAT :** Victor Kolobov a [posté][kolobov cat] sur la liste de diffusion
  Bitcoin-Dev pour annoncer un fonds de 1 million de dollars pour de la recherche sur une proposition de
  soft fork pour ajouter un opcode [`OP_CAT`][topic op_cat]. "Les sujets d'intérêt incluent,
  sans toutefois s'y limiter : les implications sur la sécurité liés à l'activation de `OP_CAT` sur Bitcoin, le calcul
  basé sur `OP_CAT` et la logique des scripts de verrouillage sur Bitcoin, les applications et
  protocoles utilisant `OP_CAT` sur Bitcoin, et la recherche générale liée à `OP_CAT` et son impact."
  Les soumissions doivent être envoyées avant le 1er janvier 2025.

- **Atténuation des vulnérabilités des arbres de Merkle :** Eric Voskuil a [publié][voskuil spv] sur
  le fil de discussion Delving Bitcoin concernant la [proposition de soft fork de nettoyage du
  consensus][topic consensus cleanup] (voir le [Bulletin #296][news296 cleanup]), une demande de mise à
  jour étant donné la récente [discussion][voskuil spv dev] sur la liste de diffusion Bitcoin-Dev. En
  particulier, il n'a vu "aucune justification pour la propositon d'invalidation des transactions de 64
  octets" basée sur son argument qu'il n'y a pas d'amélioration de performance pour les nœuds complets
  en protégeant contre [les vulnérabilités des arbres de Merkle][topic merkle tree vulnerabilities]
  comme CVE-2012-2459 en interdisant les transactions de 64 octets par rapport à d'autres
  vérifications qui peuvent être effectuées sans un changement de consensus (et, en effet, ces
  vérifications sont effectuées maintenant). Le champion de la proposition de nettoyage du consensus,
  Antoine Poinsot, semblait [être d'accord][poinsot cache] sur cet aspect des nœuds complets :
  "L'avantage que j'ai initialement mentionné sur comment rendre les transactions de 64 octets
  invalides pourrait aider à mettre en cache les échecs de blocs à un stade plus précoce est
  incorrect."
  Cependant, Poinsot et d'autres avaient également précédemment proposé d'interdire les transactions
  de 64 octets pour protéger les logiciels vérifiant les preuves de Merkle contre le CVE-2017-12842.
  Cette vulnérabilité affecte les portefeuilles légers qui utilisent _simplified payment
  verification_ (SPV) comme décrit dans le [document original sur Bitcoin][]. Elle peut également
  affecter les [sidechains][topic sidechains] qui effectuent un SPV et pourrait affecter certaines
  propositions de [covenants][topic covenants] nécessitant l'activation d'un soft fork.

  Depuis la publication du CVE-2017-12842, il est connu que SPV peut être sécurisé par une
  vérification supplémentaire de la profondeur de la transaction coinbase dans un bloc par le
  vérificateur. Voskuil estime que cela nécessiterait en moyenne 576 octets supplémentaires pour les
  blocs modernes typiques---une petite augmentation de la bande passante. Poinsot a [résumé][poinsot
  spv] les arguments et Anthony Towns s'est [étendu][towns depth] sur un argument concernant la complexité
  de l'exécution de la vérification supplémentaire de la profondeur.

  Voskuil a également fait référence à une [suggestion][lerner commitment] précédente de Sergio Demian
  Lerner pour un changement de consensus de soft fork alternatif qui ferait qu'un en-tête de bloc
  s'engage sur la profondeur de son arbre de Merkle. Cela protégerait également contre le
  CVE-2017-12842 sans interdire les transactions de 64 octets et permettrait aux preuves SPV d'être
  maximalement efficaces.

  La discussion était en cours au moment de la rédaction.

## Nouvelles versions et versions candidates

*Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de passer aux nouvelles versions ou d'aider à tester
les versions candidates.*

- [Core Lightning 24.08][] est une version majeure de cette implémentation populaire de nœud LN
  contenant de nouvelles fonctionnalités et corrections de bugs.

- [LDK 0.0.124][] est la dernière version de cette bibliothèque pour construire des applications
  activées par LN.

- [LND v0.18.3-beta.rc2][] est une version candidate pour une version de correction mineure de bug dans cette implémentation populaire du nœud LN.

- [BDK 1.0.0-beta.2][] est une version candidate pour cette bibliothèque de construction de
  portefeuilles et d'autres applications activées par Bitcoin. Le paquet Rust `bdk` original a été
  renommé en `bdk_wallet` et les modules de couche inférieure ont été extraits dans leurs propres
  paquets, incluant `bdk_chain`, `bdk_electrum`, `bdk_esplora`, et `bdk_bitcoind_rpc`. Le paquet
  `bdk_wallet` "est la première version à offrir une API stable 1.0.0."

- [Bitcoin Core 28.0rc1][] est une version candidate pour la prochaine version majeure de
  l'implémentation de nœud complet prédominante. Un [guide de test][bcc testing] est disponible.

## Changements notables dans le code et la documentation

_Changements notables récents dans[Bitcoin Core][bitcoin core repo], [Core Lightning][core
lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Propositions (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo],
[Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

_Note : les commits sur Bitcoin Core mentionnés ci-dessous s'appliquent à sa branche de
développement principale, donc ces changements ne seront probablement pas publiés avant environ six
mois après la sortie de la version à venir 28._

- [Bitcoin Core #30454][] et [#30664][bitcoin core #30664] ajoutent respectivement un système de
  compilation basé sur CMake (voir le [Bulletin #316][news316 cmake]) et suppriment l'ancien système
  de compilation basé sur autotools. Voir également les suivis dans les PRs [#30779][bitcoin core
  #30779], [#30785][bitcoin core #30785], [#30763][bitcoin core #30763], [#30777][bitcoin core
  #30777], [#30752][bitcoin core #30752], [#30753][bitcoin core #30753], [#30754][bitcoin core
  #30754], [#30749][bitcoin core #30749], [#30653][bitcoin core #30653], [#30739][bitcoin core
  #30739], [#30740][bitcoin core #30740], [#30744][bitcoin core #30744], [#30734][bitcoin core
  #30734], [#30738][bitcoin core #30738], [#30731][bitcoin core #30731], [#30508][bitcoin core
  #30508], [#30729][bitcoin core #30729], et [#30712][bitcoin core #30712].

- [Bitcoin Core #22838][] implémente plusieurs chemins de dérivation [descriptors][topic
  descriptors] ([BIP389][]), ce qui permet à une seule chaîne de descripteurs de spécifier deux
  chemins de dérivation liés, le premier pour recevoir des paiements, et le second pour un usage
  interne (tel que pour le change). Voir les Bulletins [#211][news211 bip389] et [#258][news258
  bip389].

- [Eclair #2865][] ajoute la capacité de réveiller un pair mobile déconnecté en tentant de se
  connecter à sa dernière adresse IP connue et de pousser une notification mobile. Cela est
  particulièrement utile dans le contexte des paiements [asynchrones][topic async payments] où le nœud
  local détient un paiement ou un [message onion][topic onion messages] et lorsque le pair se
  reconnecte en ligne, il est livré. Voir le Bulletin [#232][news232 async].

- [LND #9009][] introduit un mécanisme pour bannir les pairs envoyant des annonces de canal
  invalides, telles que des canaux déjà dépensés, sans transaction de financement, ou avec une sortie
  de financement invalide. Les pairs bannis sont traités différemment selon la relation :

  - Pour les pairs bannis sans canal partagé, le nœud se déconnecte d'eux.

  - Pour les pairs bannis avec un canal partagé, le nœud ignore toutes leurs annonces de canal pendant
    48 heures.

- [LDK #3268][] ajoute `ConfirmationTarget::MaximumFeeEstimate` pour une méthode d'[estimation des
  frais][topic fee estimation] plus conservatrice pour les calculs de [poussière][topic uneconomical
  outputs] lors de la vérification des taux de frais de la contrepartie, afin d'éviter les fermetures
  forcées inutiles causées par des pics soudains de frais. Cette PR divise également
  `ConfirmationTarget::OnChainSweep` en `UrgentOnChainSweep` et `NonUrgentOnChainSweep` pour
  distinguer entre les situations sensibles au temps (par exemple, avec expiration des [HTLCs][topic htlc])
  et les fermetures forcées non urgentes.

- [HWI #742][] ajoute le support pour le dispositif de signature matérielle Trezor Safe 5.

- [BIPs #1657][] ajoute un nouveau champ standard aux sorties [PSBT][topic psbt] pour les preuves
  [DNSSEC][dnssec] lors de l'utilisation de [BIP353][]. Les dispositifs externes tels que les
  signataires matériels peuvent examiner les sorties PSBT pour récupérer des preuves formatées selon
  [RFC 9102][rfc9102], qui imposent des contraintes temporelles pour garantir que seules les preuves
  valides sont acceptées. Voir le Bulletin [#307][news307 bip353].

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30454,30664,30779,30785,30763,30777,30752,30753,30754,30749,30653,30739,30740,30744,30734,30738,30731,30508,30729,30712,22838,2865,9009,3268,742,1657" %}
[Core Lightning 24.08]: https://github.com/ElementsProject/lightning/releases/tag/v24.08
[LND v0.18.3-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.3-beta.rc2
[BDK 1.0.0-beta.2]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.2
[bitcoin core 28.0rc1]: https://bitcoincore.org/bin/bitcoin-core-28.0/
[voskuil spv]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/28
[voskuil spv dev]: https://mailing-list.bitcoindevs.xyz/bitcoindev/72e83c31-408f-4c13-bff5-bf0789302e23n@googlegroups.com/
[poinsot cache]: https://mailing-list.bitcoindevs.xyz/bitcoindev/wg_er0zMhAF9ERoYXmxI6aB7rc97Cum6PQj4UOELapsHVBBVWktFeOZT7sHDlyrXwJ5o5s9iMb2LW2Od-qacywsh-86p5Q7dP3XjWASXcMw=@protonmail.com/
[document original sur Bitcoin]: https://bitcoincore.org/bitcoin.pdf
[poinsot spv]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/41
[lerner commitment]: https://bitslog.com/2018/06/09/leaf-node-weakness-in-bitcoin-merkle-tree-design/
[towns depth]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/43
[merli stratumfees]: https://delvingbitcoin.org/t/pplns-with-job-declaration/1099
[merli paper]: https://github.com/demand-open-source/pplns-with-job-declaration/blob/bd7258db08e843a5d3732bec225644eda6923e48/pplns-with-job-declaration.pdf
[kolobov cat]: https://mailing-list.bitcoindevs.xyz/bitcoindev/04b61777-7f9a-4714-b3f2-422f99e54f87n@googlegroups.com/
[news296 cleanup]: /fr/newsletters/2024/04/03/#revisiter-le-nettoyage-du-consensus
[news316 cmake]: /fr/newsletters/2024/08/16/#passage-de-bitcoin-core-au-systeme-de-compilation-cmake
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Candidate-Testing-Guide
[ldk 0.0.124]: https://github.com/lightningdevkit/rust-lightning/releases
[news211 bip389]: /en/newsletters/2022/08/03/#multiple-derivation-path-descriptors
[news258 bip389]: /fr/newsletters/2023/07/05/#bips-1354
[news232 async]: /fr/newsletters/2023/01/04/#eclair-2464
[dnssec]: https://en.wikipedia.org/wiki/Domain_Name_System_Security_Extensions
[rfc9102]: https://datatracker.ietf.org/doc/html/rfc9102
[news307 bip353]: /fr/newsletters/2024/06/14/#bips-1551
