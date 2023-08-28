---
title: 'Bulletin Hebdomadaire Newsletter #265'
permalink: /fr/newsletters/2023/08/23/
name: 2023-08-23-newsletter-fr
slug: 2023-08-23-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Cette semaine, le bulletin décrit les preuves de fraude pour les sauvegardes obsolètes et comprend nos sections régulières décrivant
les mises à jour des clients et des services, les nouvelles versions et les versions candidates, ainsi que les changements apportés
aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Preuves de fraude pour les sauvegardes obsolètes :** Thomas Voegtlin a [posté][voegtlin backups] sur la liste de diffusion
  Lightning-Dev l'idée d'un service qui pourrait être pénalisé s'il fournissait à un utilisateur une version obsolète de
  l'état de sauvegarde de l'utilisateur, à l'exception de la version la plus récente. Le mécanisme de base est simple :

    - Alice a des données qu'elle souhaite sauvegarder. Elle inclut un numéro de version dans les données, crée une signature
      pour les données et donne à Bob à la fois les données et sa signature.

    - Immédiatement après avoir reçu les données d'Alice, Bob lui envoie une signature qui s'engage à la fois sur le numéro de
      version de ses données et sur l'heure actuelle.

    - Plus tard, Alice met à jour les données, incrémente le numéro de version et fournit à Bob les données mises à jour et sa
      signature pour celles-ci. Bob renvoie une signature pour un engagement sur le nouveau numéro (plus élevé) de version avec
      le nouvel horaire actuel (plus élevé). Ils répètent cette étape plusieurs fois.

    - Enfin Alice demande ses données afin de tester Bob. Bob lui envoie une version des données et sa signature lui
      permettant de prouver qu'il s'agit réellement de ses données. Il lui envoie également une autre signature qui s'engage sur
      le numéro de version dans les données et l'heure actuelle.

    - Si Bob était malhonnête et a envoyé à Alice d'anciennes données avec un ancien numéro de version, Alice peut générer une
      _preuve de fraude_ : elle peut montrer que Bob a précédemment signé un numéro de version supérieur avec une heure antérieure
      à l'engagement de signature qu'il vient de lui fournir.

  Jusqu'à présent, il n'y a rien de spécifique à Bitcoin dans ce mécanisme de génération de preuves de fraude de l'état le plus
  récent. Cependant, Thomas Voegtlin a noté que si les opcodes [OP_CHECKSIGFROMSTACK (CSFS) et OP_CAT][topic op_checksigfromstack]
  étaient ajoutés à Bitcoin lors d'une soft fork, il serait possible d'utiliser la preuve de fraude on-chain.

  Par exemple, Alice et Bob partagent un canal LN qui inclut une condition [taproot][topic taproot] supplémentaire qui permet à
  Alice de dépenser tous les fonds du canal si elle peut fournir ce type de preuve de fraude. Le fonctionnement normal du canal
  inclurait simplement une étape supplémentaire : après chaque mise à jour du canal, Alice donne à Bob une signature sur l'état
  actuel (qui inclut un numéro d'état). Ensuite, chaque fois qu'Alice se reconnecte à Bob de manière organique, elle demande la
  dernière sauvegarde et utilise le mécanisme ci-dessus pour vérifier son intégrité. Si Bob fournit une sauvegarde obsolète,
  Alice utilise la preuve de fraude et la condition de dépense CSFS pour dépenser l'intégralité du solde du canal.

  Ce mécanisme augmente la sécurité d'Alice quand elle utilise un état fourni par Bob en tant qu'état de canal le plus récent dans les cas où
  Alice a réellement perdu des données. Dans la conception actuelle du canal LN (LN-Penalty), si Bob trompe Alice en utilisant un
  ancien état, Bob pourra voler l'intégralité de son solde dans ce canal. Même avec des améliorations proposées comme
  [LN-Symmetry][topic eltoo], Alice en utilisant un ancien état pourrait permettre à Bob de lui voler des fonds. La possibilité de
  pénaliser financièrement Bob pour avoir mal représenté le dernier état diminue probablement le risque qu'il mente à Alice.

  La proposition a suscité une quantité significative de discussions :

  <!-- J'ai déjà confirmé que "ghost43" (tout en minuscules) est la façon dont ils aimeraient être attribués -->

  - Peter Todd [a noté][todd backups1] que le mécanisme de base est générique. Il n'est pas spécifique à LN et peut être utile dans
    une variété de protocoles. Il [note également][todd backups2] qu'un mécanisme plus simple consiste pour Alice à télécharger
    simplement le dernier état de Bob à chaque fois qu'elle se reconnecte à lui de manière organique, sans preuves de fraude
    impliquées. S'il lui fournit un ancien état, elle clôt le canal avec lui, lui refusant ainsi tout autre frais de transfert
    qu'il gagnerait grâce à ses paiements futurs. Cela ressemble beaucoup à la version du [stockage entre pairs][topic peer storage]
    décrite dans [BOLTs #881][], la version expérimentalement mise en œuvre dans Core Lightning plus tôt cette année (voir le
    [Bulletin #238][news238 peer storage]), et (selon un [message][teinturier backups] de Bastien Teinturier) une version du schéma
    mise en œuvre dans le portefeuille Phoenix pour LN.

  - Une [réponse][ghost43 backups] de ghost43 explique que les preuves de fraude entraînant des pénalités financières sont un outil
    puissant pour un client stockant des données avec des pairs anonymes. Un service populaire et important pourrait se soucier
    suffisamment de sa réputation pour éviter de mentir à ses clients, mais les pairs anonymes n'ont aucune réputation à perdre.
    Ghost43 suggère également une modification du protocole pour le rendre symétrique, de sorte qu'en plus d'Alice stockant son état
    avec Bob (et Bob étant pénalisé pour mentir), Bob pourrait stocker son état avec Alice et elle pourrait être pénalisée pour
    mentir.

      Voegtlin a étendu cette idée pour [mettre en garde][voegtlin backups2] que les fournisseurs de logiciels de portefeuille ont
      un besoin important d'une bonne réputation et qu'ils perdent en réputation lorsque leurs utilisateurs perdent des fonds, même
      si le logiciel fonctionne aussi bien que possible. En tant que développeur de logiciels de portefeuille, il est donc très
      important pour lui de minimiser le risque qu'un pair anonyme puisse voler un utilisateur d'Electrum qui utilise un mécanisme
      comme les sauvegardes entre pairs.

Il n'y a pas eu de résolution claire à la discussion.

## Modifications apportées aux services et aux logiciels clients

*Dans cette rubrique mensuelle, nous mettons en évidence les mises à jour
intéressantes des portefeuilles et services Bitcoin.*

- **Appel à commentaires sur l'évolutivité de Lightning :**
  [Scaling Lightning][] est une boîte à outils de test pour le Lightning
  Network sur regtest et signet. Le projet vise à fournir des outils pour tester différentes implémentations de LN dans une variété
  de configurations et de scénarios. Le projet a fourni une récente [mise à jour vidéo][sl twitter update] pour la communauté. Les
  développeurs, chercheurs et opérateurs d'infrastructure LN sont encouragés à [fournir des commentaires][sl tg].

- **Sortie de Torq v1.0 :**
  [Torq][torq github], un logiciel de gestion de nœuds LN destiné aux utilisateurs professionnels, a
  [annoncé][torq blog] une version v1.0 incluant des fonctionnalités de Lightning Service Provider (LSP), des flux de travaux
  d'automatisation et des fonctionnalités avancées pour les grands opérateurs de nœuds.

- **Blixt Wallet v0.6.8 publié :**
  La [version v0.6.8][blixt v0.6.8] inclut la prise en charge des [factures en attente][topic
  hold invoices] et des [canaux sans confirmation][topic zero-conf channels], entre autres améliorations.

- **Sparrow 1.7.8 publié :**
  Sparrow [1.7.8][sparrow 1.7.8] a ajouté la prise en charge de la [BIP322][] [signature de message][topic generic
  signmessage], y compris les adresses P2TR, et a apporté diverses améliorations aux fonctionnalités de [RBF][topic rbf] et de
  [CPFP][topic cpfp] pour augmenter les frais.

- **Prototype de mineur ASIC open source bitaxeUltra :**
  Le [bitaxeUltra][github bitaxeUltra] est un mineur open source utilisant un
  circuit intégré spécifique à une application (ASIC) basé sur du matériel de minage commercial existant.

- **Annonce du logiciel FROST Frostsnap :**
  L'équipe a [annoncé][frostsnap blog] sa vision de la [construction][frostsnap github] sur le schéma de
  [signature seuil][topic threshold signature] FROST en utilisant une implémentation expérimentale de FROST,
  [secp256kfun][secp256kfun github].

- **Annonce de la bibliothèque Libfloresta :**
  S'appuyant sur les travaux précédents du nœud [Floresta][news247 floresta] alimenté par [utreexo][topic utreexo],
  [Libfloresta][libfloresta blog] est une bibliothèque Rust permettant d'ajouter des fonctionnalités de nœud Bitcoin basées
  sur utreexo aux applications.

- **Wasabi Wallet 2.0.4 publié :**
  Wasabi [2.0.4][wasabi 2.0.4] ajoute des fonctionnalités pour augmenter les frais avec [RBF][topic rbf] ou [CPFP][topic cpfp],
  des améliorations de [coinjoin][topic coinjoin], un chargement plus rapide du portefeuille, des améliorations RPC et d'autres
  améliorations et corrections de bugs.

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets d’infrastructure
Bitcoin. Veuillez envisager de passer aux nouvelles versions ou d’aider à tester
les versions candidates.*

- [Core Lightning 23.08rc3][] est une version candidate pour la prochaine
  version majeure de cette implémentation populaire de nœud LN.

- [HWI 2.3.1][] est une version mineure de cette boîte à outils pour travailler avec
  des appareils de signature matérielle.

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Interface de portefeuille
matériel (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [Serveur BTCPay
][btcpay server repo], [BDK][bdk repo], [Propositions d'amélioration Bitcoin (BIPs)][bips repo], [BOLTs Lightning][bolts repo], et
[Inquisition Bitcoin][bitcoin inquisition repo].*

- [Bitcoin Core #27981][] corrige un bogue qui aurait pu empêcher deux nœuds de recevoir des données l'un de l'autre. Si le
  noeud d'Alice avait beaucoup de données en attente à envoyer au nœud de Bob, elle essaierait d'envoyer ces données avant
  d'accepter de nouvelles données de Bob. Si Bob avait également beaucoup de données en attente à envoyer au nœud d'Alice, il
  n'accepterait également pas de nouvelles données d'Alice. Cela pourrait conduire à ce que ni l'un ni l'autre ne tentent de
  recevoir des données de l'autre indéfiniment. Le problème a été découvert à l'origine dans le [Projet Elements][].

- [BOLTs #919][] met à jour la spécification LN pour suggérer que les nœuds arrêtent d'accepter des HTLCs réduits au-delà d'une
  certaine valeur. Un HTLC réduit est un paiement transférable qui n'est pas ajouté en tant que sortie à la transaction
  d'engagement du canal. Au lieu de cela, un montant égal à la valeur du HTLC réduit est alloué aux frais de transaction. Cela
  permet d'utiliser LN pour transférer des paiements qui seraient [non rentables][topic uneconomical outputs] onchain.
  Cependant, si le canal doit être fermé alors que des HTLC réduits sont en attente, un nœud n'a aucun moyen de récupérer ces
  fonds, il est donc logique de limiter l'exposition du nœud à ce type de perte. Voir également nos descriptions des différentes
  implémentations ajoutant cette limite : LDK dans le [Bulletin #162][news162 trim], Eclair dans le [Bulletin #171][news171 trim],
  et Core Lightning dans le [Bulletin #173][news173 trim], ainsi que le [Bulletin #170][news170 trim] pour une préoccupation de
  sécurité connexe.

- [Rust Bitcoin #1990][] permet en option de compiler `bitcoin_hashes` avec des implémentations plus lentes de SHA256, SHA512 et
  RIPEMD160 qui sont également environ deux fois plus petites, ce qui les rend probablement meilleures pour les applications sur
  des appareils intégrés qui n'ont pas besoin d'effectuer des hachages fréquents.

- [Rust Bitcoin #1962][] ajoute la possibilité d'utiliser des opérations SHA256 optimisées par matériel sur les architectures x86
  compatibles.

- [BIPs #1485][] apporte plusieurs mises à jour à la spécification [BIP300][] des [drivechains][topic sidechains]. Le principal
  changement semble être une redéfinition de `OP_NOP5` dans certains contextes en `OP_DRIVECHAIN`.

{% include references.md %}
{% include linkers/issues.md v=2 issues="27460,27981,919,1990,1962,1485,881" %}
[core lightning 23.08rc3]: https://github.com/ElementsProject/lightning/releases/tag/v23.08rc3
[news238 peer storage]: /fr/newsletters/2023/02/15/#core-lightning-5361
[news162 trim]: /en/newsletters/2021/08/18/#rust-lightning-1009
[news171 trim]: /en/newsletters/2021/10/20/#eclair-1985
[news173 trim]: /en/newsletters/2021/11/03/#c-lightning-4837
[news170 trim]: /en/newsletters/2021/10/13/#ln-spend-to-fees-cve
[Projet Elements]: https://elementsproject.org/
[voegtlin backups]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004043.html
[todd backups1]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004046.html
[todd backups2]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004044.html
[teinturier backups]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004045.html
[ghost43 backups]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004052.html
[voegtlin backups2]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004055.html
[hwi 2.3.1]: https://github.com/bitcoin-core/HWI/releases/tag/2.3.1
[Scaling Lightning]: https://github.com/scaling-lightning/scaling-lightning
[sl twitter update]: https://twitter.com/max_blue__/status/1681781001373065216
[sl tg]: https://t.me/+AytRsS0QKH5mMzM8
[torq github]: https://github.com/lncapital/torq
[torq blog]: https://ln.capital/articles/announcing-torq-V1.0
[blixt v0.6.8]: https://github.com/hsjoberg/blixt-wallet/releases
[sparrow 1.7.8]: https://github.com/sparrowwallet/sparrow/releases/tag/1.7.8
[github bitaxeUltra]: https://github.com/skot/bitaxe/tree/ultra
[frostsnap blog]: https://frostsnap.com/introducing-frostsnap.html
[frostsnap github]: https://github.com/frostsnap/frostsnap
[secp256kfun github]: https://github.com/LLFourn/secp256kfun
[news247 floresta]: /fr/newsletters/2023/04/19/#annonce-du-serveur-electrum-base-sur-utreexo
[libfloresta blog]: https://blog.dlsouza.lol/2023/07/07/libfloresta.html
[wasabi 2.0.4]: https://github.com/zkSNACKs/WalletWasabi/releases/tag/v2.0.4
