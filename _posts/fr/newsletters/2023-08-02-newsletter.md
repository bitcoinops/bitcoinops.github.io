---
title: 'Bulletin Hebdomadaire Bitcoin Optech #262'
permalink: /fr/newsletters/2023/08/02/
name: 2023-08-02-newsletter-fr
slug: 2023-08-02-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine propose des liens vers les transcriptions des récentes réunions de spécification du LN et
résume une discussion sur la sécurité de la signature aveugle MuSig2. Il comprend également nos sections habituelles avec
des descriptions des nouvelles versions et versions candidates ainsi que les changements apportés aux principaux logiciels
d'infrastructure Bitcoin.

## Nouvelles

- **Transcriptions des réunions périodiques de spécification du LN :** Carla Kirk-Cohen a [publié][kc scripts] sur la liste de
  diffusion Lightning-Dev pour annoncer que les dernières réunions en visioconférence visant à discuter des modifications de la
  spécification du LN ont été transcrites. Les transcriptions sont maintenant [disponibles][btcscripts spec] sur Bitcoin
  Transcripts. Dans une actualité connexe, comme discuté il y a quelques semaines lors de la conférence des développeurs LN en
  personne, le salon de discussion IRC `#lightning-dev` sur le réseau [Libera.chat][] a connu une activité renouvelée
  significative pour les discussions liées au LN. {% assign timestamp="1:13" %}

- **Sécurité de la signature aveugle MuSig2 :** Tom Trevethan a [publié][trevethan blind] sur la liste de diffusion Bitcoin-Dev
  pour demander une revue d'un protocole cryptographique prévu dans le cadre d'un déploiement de [statechains][topic statechains].
  L'objectif était de déployer un service qui utiliserait sa clé privée pour créer une signature partielle [MuSig2][topic musig]
  sans obtenir aucune connaissance sur ce qu'elle signait ou comment sa signature partielle était utilisée. Le signataire aveugle
  se contenterait de signaler combien de signatures il avait créé avec une clé particulière.

    La discussion sur la liste a examinée les écueils de diverses constructions liées au problème spécifique et encore plus généralisée de [la signature aveugle schnorr][generalized blind schnorr]. Il a également été mentionné un [gist][somsen gist]
    d'il y a un an de Ruben Somsen sur un protocole de 1996 pour l'échange de clés [Diffie-Hellman (DH)][dhke] aveugle, qui peut
    être utilisé pour des ecash aveugles. [Lucre][] et [Minicash][] sont des implémentations antérieures de ce schéma sans rapport
    avec Bitcoin, et [Cashu][] est une implémentation liée à Minicash qui intègre également le support de Bitcoin et du LN.
    Toute personne intéressée par la cryptographie peut trouver le fil intéressant pour sa discussion sur les techniques
    cryptographiques. {% assign timestamp="5:07" %}

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets d’infrastructure
Bitcoin. Veuillez envisager de passer aux nouvelles versions ou d’aider à tester
les versions candidates.*

- [BTCPay Server 1.11.1][] est la dernière version de ce processeur de paiement auto-hébergé. La série de versions 1.11.x comprend
  des améliorations de la génération de factures, des mises à niveau supplémentaires du processus de paiement et de nouvelles
  fonctionnalités pour le terminal de point de vente. {% assign timestamp="24:30" %}

## Modifications de code et de documentation notables

*Modifications notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo],
[Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPayServer][btcpay server repo], [BDK][bdk repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
et [Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #26467][] permet à l'utilisateur de spécifier quelle sortie d'une transaction est le changement dans `bumpfee`.
  Le portefeuille déduit de la valeur de cette sortie pour ajouter des frais lors de la création de la [transaction de
  remplacement][topic rbf]. Par défaut, le portefeuille tente de détecter automatiquement une sortie de changement et en crée
  une nouvelle s'il échoue à le faire. {% assign timestamp="25:31" %}

- [Core Lightning #6378][] et [#6449][core lightning #6449] marqueront un [HTLC][topic htlc] entrant hors chaîne comme échoué si
  le nœud est incapable (ou refuse en raison des coûts de frais) de temporiser un HTLC correspondant onchain. Par exemple, le nœud
  d'Alice transfère un HTLC au nœud de Bob avec une expiration de 20 blocs et le nœud de Bob transfère un HTLC avec le même hash
  de paiement au nœud de Carol avec une expiration de 10 blocs. Par la suite, le canal entre Bob et Carol est fermé de force
  onchain.

    Après l'expiration de 10 blocs, une situation qui ne devrait pas être courante se produit : le nœud de Bob dépense soit en
    utilisant la condition de remboursement mais la transaction ne se confirme pas, soit il détermine que le coût des frais pour
    réclamer le remboursement est supérieur à la valeur et ne crée pas une dépense. Avant cette PR, le nœud de Bob ne créerait
    pas une annulation offchain du HTLC qu'il a reçu d'Alice car cela permettrait à Alice de garder l'argent qu'elle a transféré
    à Bob et à Carol de réclamer l'argent que Bob lui a transféré, coûtant à Bob le montant du HTLC.

    Cependant, après l'expiration de 20 blocs du HTLC qu'Alice lui a proposé, elle peut forcer la fermeture du canal pour tenter
    de recevoir un remboursement du montant qu'elle a transféré à Bob, et son logiciel peut le faire automatiquement pour empêcher
    Alice de perdre potentiellement l'argent à un nœud en amont d'elle. Mais, si elle force la fermeture du canal, elle pourrait
    se retrouver dans la même position que Bob : elle est soit incapable de réclamer le remboursement, soit n'essaie pas car ce
    n'est pas rentable. Cela signifie qu'un canal utile entre Alice et Bob a été fermé sans aucun gain pour l'un ou l'autre. Ce
    problème pourrait se répéter plusieurs fois pour tous les sauts en amont d'Alice, entraînant une cascade de fermetures de
    canaux indésirables.

    La solution mise en œuvre dans cette PR est que Bob attende aussi longtemps que raisonnable pour réclamer un remboursement
    et, s'il ne se produit pas, crée une annulation offchain du HTLC qu'il a reçu d'Alice, permettant à leur canal de continuer
    à fonctionner même si cela signifie qu'il pourrait perdre le montant du HTLC. {% assign timestamp="27:19" %}

- [Core Lightning #6399][] ajoute la prise en charge de la commande `pay` pour payer les factures créées par le nœud local.
  Cela peut simplifier le code de gestion des comptes pour les logiciels qui appellent CLN en arrière-plan, comme discuté
  dans un récent [thread de la liste de diffusion][fiatjaf custodial]. {% assign timestamp="33:03" %}

- [Core Lightning #6389][] ajoute un service optionnel CLNRest, "un
  plugin Core Lightning léger basé sur Python qui transforme les appels RPC
  en un service REST. En générant des points d'API REST, il permet
  l'exécution des méthodes RPC de Core Lightning en arrière-plan
  et fournit des réponses au format JSON."  Consultez sa
  [documentation][clnrest doc] pour plus de détails. {% assign timestamp="35:48" %}

- [Core Lightning #6403][] et [#6437][core lightning #6437] déplacent le
  mécanisme d'autorisation et d'authentification des runes hors du plugin commando de CLN
  (voir [Newsletter #210][news210 commando]) et dans sa fonctionnalité principale,
  permettant à d'autres plugins de les utiliser. Plusieurs
  commandes liées à la création, la destruction et le renommage des runes sont également
  mises à jour. {% assign timestamp="37:37" %}

- [Core Lightning #6398][] étend le RPC `setchannel` avec une nouvelle
  option `ignorefeelimits` qui ignorera les limites minimales de frais onchain
  pour le canal, permettant à la contrepartie distante du canal de
  définir un taux de frais inférieur au minimum que le nœud local autorisera. Cela peut
  aider à contourner un bug potentiel dans une autre implémentation de nœud LN ou
  peut être utilisé pour éliminer les problèmes de contention de frais dans
  les canaux partiellement fiables. {% assign timestamp="39:52" %}

- [Core Lightning #5492][] ajoute des points de trace définis statiquement au niveau de l'utilisateur
  (User-level Statically Defined Tracepoints - USDT) et les moyens de les utiliser. Cela permet aux utilisateurs de sonder
  le fonctionnement interne de leur nœud à des fins de débogage sans introduire de
  surcharge significative lorsque les points de trace ne sont pas utilisés. Consultez la
  [Newsletter #133][news133 usdt] pour l'inclusion précédente du support USDT
  dans Bitcoin Core. {% assign timestamp="45:52" %}

- [Eclair #2680][] ajoute la prise en charge du protocole de négociation d'état de repos
  requis par le [protocole de fusion][topic splicing] proposé dans [BOLTs #863][]. Le protocole d'état de repos empêche les
  deux nœuds partageant un canal de s'envoyer de nouveaux [HTLCs][topic htlc]
  jusqu'à ce qu'une certaine opération soit terminée, comme la validation des
  paramètres d'une fusion et la signature coopérative de la transaction de fusion onchain
  ou de la transaction de fusion offchain. Un HTLC reçu pendant la négociation
  et la signature de la fusion peuvent invalider les négociations et les signatures précédentes, il est donc plus simple de
  simplement mettre en pause le relais HTLC pendant les quelques allers-retours réseau nécessaires pour obtenir la transaction
  de fusion signée mutuellement. Eclair
  prend déjà en charge la fusion, mais cette modification le rapproche
  de la prise en charge du même protocole de fusion que les autres logiciels de nœud
  utiliseront probablement. {% assign timestamp="51:42" %}

- [LND #7820][] ajoute à RPC `BatchOpenChannel` tous les champs
  disponibles dans le RPC non groupé `OpenChannel`, à l'exception de
  `funding_shim` (pas nécessaire pour les ouvertures groupées) et `fundmax` (vous
  ne pouvez pas donner à un canal tout le solde lors de l'ouverture de plusieurs
  canaux). {% assign timestamp="53:57" %}

- [LND #7516][] étend le RPC `OpenChannel` avec un nouveau paramètre `utxo`
  qui permet de spécifier un ou plusieurs UTXOs du portefeuille.
  qui devrait être utilisé pour financer la nouvelle chaîne. {% assign timestamp="54:57" %}

- [BTCPay Server #5155][] ajoute une page de rapport au back office qui fournit
  des rapports de paiement et de portefeuille onchain, la possibilité d'exporter au format CSV, et est
  extensible par des plugins. {% assign timestamp="57:26" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="863,26467,6378,6449,6399,6389,6403,6437,6398,5492,2680,7820,7516,5155" %}
[clnrest doc]: https://github.com/rustyrussell/lightning/blob/02c2d8a9e3b450ce172e8bc50c855ac2a16f5cac/plugins/clnrest/README.md
[news133 usdt]: /en/newsletters/2021/01/27/#bitcoin-core-19866
[kc scripts]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-July/004025.html
[btcscripts spec]: https://btctranscripts.com/lightning-specification/
[libera.chat]: https://libera.chat/
[trevethan blind]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-July/021792.html
[generalized blind schnorr]: https://gist.github.com/moonsettler/05f5948291ba8dba63a3985b786233bb
[somsen gist]: https://gist.github.com/RubenSomsen/be7a4760dd4596d06963d67baf140406
[lucre]: https://github.com/benlaurie/lucre
[minicash]: https://github.com/phyro/minicash
[cashu]: https://github.com/cashubtc/cashu
[fiatjaf custodial]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-July/004008.html
[news210 commando]: /en/newsletters/2022/07/27/#core-lightning-5370
[dhke]: https://fr.wikipedia.org/wiki/%C3%89change_de_cl%C3%A9s_de_Diffie-Hellman
[btcpay server 1.11.1]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.11.1