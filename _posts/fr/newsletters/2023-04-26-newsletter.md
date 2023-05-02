---
title: 'Bulletin Hebdomadaire Bitcoin Optech #248'
permalink: /fr/newsletters/2023/04/26/
name: 2023-04-26-newsletter-fr
slug: 2023-04-26-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine relaie une demande de commentaires sur une
proposition visant à supprimer la prise en charge du message du protocole
P2P BIP35 `mempool` dans Bitcoin Core et comprend nos sections habituelles
avec des résumés des principales questions et réponses du Bitcoin Stack Exchange,
des annonces de nouvelles mises à jour et de versions candidates, ainsi que
des résumés des principaux changements apportés aux logiciels d'infrastructure
Bitcoin les plus répandus.


## Nouvelles

- **Proposition de suppression du message P2P `mempool` du BIP35 :** Will Clark
  a [posté][clark mempool] sur la liste de diffusion Bitcoin-Dev à propos d'un
  [PR][bitcoin core #27426] qu'il a ouvert pour supprimer le support du message
  P2P `mempool` spécifié à l'origine dans [BIP35][]. Dans son implémentation
  originale, un nœud recevant un message `mempool` répondait au pair demandeur
  avec un message `inv` contenant les txids de toutes les transactions dans son
  mempool. Son homologue pouvait alors envoyer un message normal `getdata`
  contenant les txids de toutes les transactions qu'il souhaitait recevoir.
  Le BIP décrit trois motivations pour ce message : les diagnostics de réseau,
  permettre aux clients légers d'interroger les transactions non confirmées,
  et permettre aux mineurs qui ont récemment redémarré de connaître les
  transactions non confirmées (à l'époque, Bitcoin Core ne sauvegardait pas
  son mempool dans un stockage persistant lors de l'arrêt).

    Cependant, diverses techniques de réduction de la confidentialité ont été
    développées par la suite pour faciliter la détermination du nœud qui a diffusé
    la première transaction en abusant du message `mempool` ou de la possibilité
    d'utiliser `getdata` pour demander n'importe quelle transaction du mempool.
    Pour améliorer la [confidentialité de l'origine de la transaction][topic
    transaction origin privacy], Bitcoin Core a ensuite supprimé la possibilité
    de demander des transactions non annoncées à d'autres nœuds et a limité le
    message `mempool` à une utilisation avec des [filtres de bloom de transaction][topic
    transaction bloom filtering] (comme spécifié dans [BIP37][]) pour les clients légers.
    Plus tard encore, Bitcoin Core a désactivé par défaut le support du filtre bloom
    (voir [Bulletin #56][news56 bloom]), ne l'autorisant qu'à être utilisé avec des
    pairs configurés avec l'option `-whitelist` (voir [Bulletin #60][news60 bloom]);
    cela rend effectivement le `mempool` de BIP35 également désactivé par défaut.

    Le PR de Clark sur Bitcoin Core a reçu le soutien du projet, bien que certains
    partisans pensent que les filtres Bloom de BIP37 devraient être supprimés en
    premier. Sur la liste de diffusion, la seule [réponse][harding mempool] à ce
    jour note que les clients légers qui se connectent à leur propre nœud de confiance
    peuvent actuellement utiliser BIP35 et BIP37 pour se renseigner sur les transactions
    non confirmées d'une manière beaucoup plus efficace en termes de bande passante que
    toute autre méthode actuellement facilement disponible dans Bitcoin Core. Le
    répondant a suggéré que Bitcoin Core fournisse un mécanisme alternatif avant de
    supprimer l'interface actuelle.

    Toute personne utilisant le message BIP35 `mempool` à quelque fin que ce soit est
    priée de nous faire part de ses commentaires. Vous pouvez répondre soit au message
    de la liste de diffusion, soit au PR dont le lien figure ci-dessus.

## Selection de Q&R du Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits
où les collaborateurs d'Optech cherchent des réponses à leurs questions---ou
lorsque nous avons quelques moments libres pour aider les utilisateurs
curieux ou confus. Dans cette rubrique mensuelle, nous mettons en avant
certaines des questions et réponses les plus votées depuis notre dernière mise à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Combien de sigops y a-t-il dans le bloc invalide 783426 ?]({{bse}}117837)
  Vojtěch Strnad a fourni un script qui parcourt toutes les transactions d'un bloc
  et compte les [sigops]({{bse}}117359) et note qu'il y avait 80 003 sigops dans le bloc,
  ce qui le rend [invalide][max sigops].

- [Comment un adversaire pourrait-il augmenter jusqu'à 500 fois les frais requis pour remplacer une transaction ?]({{bse}}117734)
  En se référant à un projet de BIP pour les [ancrages éphémères][topic ephemeral
  anchors], Michael Folkson demande comment l'augmentation de 500 fois des frais
  requis pour le remplacement d'une transaction pourrait se produire. Antoine
  Poinsot donne un exemple de la manière dont un attaquant pourrait utiliser les
  règles d'augmentation des frais [Replace-By-Fee (RBF)][topic rbf] pour exiger
  des transactions de remplacement supplémentaires qu'elles paient des frais
  beaucoup plus élevés.

- [Meilleures pratiques avec plusieurs CPFP et CPFP + RBF ?]({{bse}}117877)
  Sdaftuar explique les considérations relatives à l'utilisation des techniques
  d'augmentation des frais RBF et [Child Pays For Parent (CPFP)][topic cpfp]
  dans le cas où une première tentative d'augmentation des frais CPFP n'a pas
  réussi à offrir un taux suffisant pour que la transaction initiale soit confirmée.

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets d’infrastructure
Bitcoin. Veuillez envisager de passer aux nouvelles versions ou d’aider à tester
les versions candidates.*

- [LDK 0.0.115][] est une version de cette bibliothèque permettant de créer
  des portefeuilles et des applications compatibles avec le LN. Elle inclut
  plusieurs nouvelles fonctionnalités et corrections de bugs, notamment une
  meilleure prise en charge du protocole expérimental [offers][topic offers]
  et une amélioration de la sécurité et de la confidentialité.

- [LND v0.16.1-beta][] est une version mineure de cette implémentation de LN
  qui inclut plusieurs corrections de bogues et d'autres améliorations. Les
  notes de version indiquent que le delta de CLTV par défaut a été augmenté
  de 40 blocs à 80 blocs (voir [Bulletin #40][news40 cltv] où nous avons
  couvert un changement précédent dans le delta de la CLTV par défaut du LND).

- [Core Lightning 23.05rc1][] est une version candidate pour la prochaine
  version de l'implémentation du LN.

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], et
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [LND #7564][] permet maintenant aux utilisateurs d'un backend qui fournit
  un accès au mempool de surveiller les transactions non confirmées contenant
  des pré-images pour les HTLC dans les canaux du nœud. Cela permet au nœud
  de résoudre les HTLC plus rapidement qu'en attendant que ces transactions
  soient confirmées.

- [LND #6903][] met à jour le RPC `openchannel` avec une nouvelle option `fundmax`
qui allouera tous les fonds du canal vers un nouveau canal, à l'exception de
tout montant qui doit être conservé dans la chaîne pour ajouter des frais aux
canaux utilisant [anchor outputs][topic anchor outputs].

- [LDK #2198][] augmente le temps d'attente de LDK avant d'envoyer un message
  au gossip annonçant qu'un canal est hors service (par exemple, parce que le
  pair distant n'est pas disponible). Auparavant, LDK annonçait qu'un canal
  était hors service au bout d'une minute environ. D'autres nœuds LN attendent
  plus longtemps et une [proposition][bolts #1059] pour la mise à jour du
  protocole du gossip LN suggère de remplacer les champs d'horodatage par des
  hauteurs de blocs au lieu de [Unix epoch time][], ce qui ne permettrait de
  mettre à jour un message du gossip qu'une fois par bloc (approximativement
  toutes les 10 minutes en moyenne). Bien que le PR note que l'envoi de mises
  à jour plus lentes implique des compromis, il met à jour LDK pour qu'il
  attende environ 10 minutes avant de diffuser un message de désactivation
  de canal.

- [Bitcoin Inquisition #23][] ajoute une partie du support pour les [ancrages
éphémères][topic ephemeral anchors]. Elle ne prend pas en charge le [relais de
transaction v3][topic v3 transaction relay], dont dépendent les ancrages éphémères
pour mettre fin aux [attaques par épinglage de transaction][topic transaction pinning].

{% include references.md %}
{% include linkers/issues.md v=2 issues="7564,6903,2198,1059,23,27426" %}
[Core Lightning 23.05rc1]: https://github.com/ElementsProject/lightning/releases/tag/v23.05rc1
[news56 bloom]: /en/newsletters/2019/07/24/#bitcoin-core-16152
[news60 bloom]: /en/newsletters/2019/08/21/#bitcoin-core-16248
[clark mempool]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021562.html
[harding mempool]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021563.html
[unix epoch time]: https://en.wikipedia.org/wiki/Unix_time
[ldk 0.0.115]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.115
[lnd v0.16.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.1-beta
[news40 cltv]: /en/newsletters/2019/04/02/#lnd-2759
[max sigops]: https://github.com/bitcoin/bitcoin/blob/e9262ea32a6e1d364fb7974844fadc36f931f8c6/src/consensus/consensus.h#L17
