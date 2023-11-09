---
title: 'Bulletin Hebdomadaire Bitcoin Optech #275'
permalink: /fr/newsletters/2023/11/01/
name: 2023-11-01-newsletter-fr
slug: 2023-11-01-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine fait suite à plusieurs discussions récentes sur les modifications proposées au langage de script de Bitcoin.
Elle comprend également nos sections habituelles annonçant les nouvelles versions et décrivant les changements importants apportés aux
logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

- **Poursuite des discussions sur les modifications de script :** plusieurs réponses ont été publiées sur la liste de diffusion
  Bitcoin-Dev concernant les discussions que nous avons précédemment couvertes.

    - *Recherche sur les covenants :* Anthony Towns a [répondu][towns cov] à un [message][russell cov] de Rusty Russell que nous avons
      mentionné [la semaine dernière][news274 cov]. Towns compare l'approche de Russell à d'autres approches spécifiquement pour les
      [coffre-forts][topic vaults] basé sur [covenants][topic covenants] et la trouve peu attrayante. Dans une [réponse
      ultérieure][russell cov2], Russell note qu'il existe différents designs pour les coffre-forts et que ceux-ci sont fondamentalement
      moins optimaux que d'autres types de transactions, ce qui implique que l'optimisation n'est pas essentielle pour les utilisateurs
      de coffre-forts. Il soutient que l'approche des coffre-forts du [BIP345][] est plus adaptée à un format d'adresse qu'à un ensemble
      d'opcodes, ce qui signifie que le BIP345 a plus de sens en tant que modèle (comme P2WPKH) conçu pour une fonction spécifique plutôt
      qu'en tant qu'ensemble d'opcodes conçus pour cette fonction spécifique mais qui pourraient interagir de manière imprévue avec le
      reste du script.

      Towns examine également l'utilisation de l'approche de Russell dans le but de permettre en général l'expérimentation et la trouve
      "plus intéressante [...] mais encore assez limitée". Il rappelle aux lecteurs sa proposition précédente de fournir une alternative
      de style Lisp à Bitcoin Script (voir [Newsletter #191][news191 lisp]) et montre comment cela pourrait apporter une flexibilité
      accrue et la possibilité d'effectuer une introspection des transactions lors de l'évaluation des témoins. Il fournit des liens
      vers son code de test et mentionne quelques exemples de jouets qu'il a écrits. Russell répond : "Je pense toujours qu'il y a
      beaucoup de place pour l'amélioration avant un remplacement. Il est difficile de comparer le [S]cript actuel avec une alternative,
      car la plupart des cas intéressants sont impossibles."

      Towns et Russell discutent également brièvement de [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack], en particulier de sa
      capacité à permettre à des données authentifiées provenant d'un oracle d'être placées directement sur une pile d'évaluation.

    - *Proposition OP_CAT :* plusieurs personnes ont répondu au [message][heilman cat] d'Ethan Heilman annonçant une proposition de BIP
      pour [OP_CAT][], que nous avons également mentionné [la semaine dernière][news274 cat].

      Après que plusieurs réponses aient exprimé des inquiétudes quant à savoir si `OP_CAT` serait excessivement limité par la limite
      de 520 octets sur la taille des éléments de la pile, Peter Todd a [décrit][todd 520] une façon d'augmenter cette limite dans une
      future mise à jour logicielle sans utiliser d'opcodes supplémentaires `OP_SUCCESSx`. L'inconvénient est que toutes les utilisations
      de `OP_CAT` avant cette augmentation nécessiteraient l'inclusion d'un petit nombre d'opcodes déjà disponibles supplémentaires dans
      leurs scripts.

      Dans un [article][o'beirne vault] publié avant la réponse similaire d'Anthony Towns à la recherche de Russell sur les covenants,
      James O'Beirne souligne les limitations significatives de l'utilisation de `OP_CAT` pour implémenter des coffres-forts. Il note
      spécifiquement plusieurs fonctionnalités que les versions `OP_CAT` n'ont pas par rapport aux coffres-forts de style BIP345.

{% assign timestamp="0:40" %}

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets d’infrastructure
Bitcoin. Veuillez envisager de passer aux nouvelles versions ou d’aider à tester
les versions candidates.*

- [LDK 0.0.118][] est la dernière version de cette bibliothèque pour la construction d'applications compatibles LN. Elle inclut un
  support expérimental partiel pour le protocole [offers][topic offers], ainsi que d'autres nouvelles fonctionnalités et corrections
  de bugs. {% assign timestamp="14:57" %}

- [Rust Bitcoin 0.31.1][] est la dernière version de cette bibliothèque pour travailler avec les données Bitcoin. Consultez ses [notes
  de version][rb rn] pour une liste des nouvelles fonctionnalités et corrections de bugs. {% assign timestamp="17:35" %}

_Remarque:_ Bitcoin Core 26.0rc1, mentionné dans notre dernière newsletter, est étiqueté mais les binaires n'ont pas été téléchargés
en raison d'un changement d'Apple qui a empêché la création de binaires reproductibles pour macOS. Les développeurs de Bitcoin Core
travaillent sur une solution pour un deuxième candidat à la version.

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], [Lightning BOLTs][bolts repo], et [Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #28685][] corrige un bug dans le calcul du hachage d'un ensemble de UTXO, mentionné dans une [newsletter
  précédente][news274 hash bug]. Il inclut un changement incompatible avec la version précédente de l'API `gettxoutsetinfo`, remplaçant
  la valeur précédente `hash_serialized_2` par `hash_serialized_3`, contenant le hachage corrigé. {% assign timestamp="21:24" %}

- [Bitcoin Core #28651][] permet à [miniscript][topic miniscript] d'estimer plus précisément le nombre maximal d'octets qui devront
  être inclus dans la structure de témoin pour dépenser une sortie [taproot][topic taproot]. Cette amélioration de précision aidera
  le portefeuille de Bitcoin Core à éviter de payer des frais excessifs. {% assign timestamp="22:34" %}

- [Bitcoin Core #28565][] s'appuie sur [#27511][Bitcoin Core #27511] pour ajouter une API `getaddrmaninfo` qui expose les comptes des
  adresses de pairs qui sont soit "nouvelles" soit "essayées", segmentées par réseau (IPv4, IPv6, Tor, I2P, CJDNS). Voir [Newsletter
  #237][news237 pr review] et le [Podcast #237][pod237 pr review] pour plus d'informations concernant la motivation derrière cette
  segmentation. {% assign timestamp="24:57" %}

- [LND #7828][] commence à exiger que les pairs répondent à ses messages de protocole LN `ping` dans un délai raisonnable, sinon ils
  seront déconnectés. Cela permet de garantir que les connexions restent actives (réduisant ainsi les chances qu'une connexion morte
  bloque un paiement et déclenche une fermeture forcée de canal non désirée). Il y a de nombreux avantages supplémentaires aux pings
  et pongs LN : ils peuvent aider à dissimuler le trafic réseau, rendant ainsi plus difficile le suivi des paiements par un observateur
  du réseau (car les paiements, les pings et les pongs sont tous chiffrés) ; ils déclenchent des rotations plus fréquentes des clés
  de chiffrement, comme décrit dans [BOLT1][] ; et LND utilise en particulier les messages `pong` pour aider à prévenir les [attaques
  par éclipse][topic eclipse attacks] (voir [Newsletter #164][news164 pong]). {% assign timestamp="31:01" %}

- [LDK #2660][] donne aux appelants plus de flexibilité sur les frais qu'ils peuvent choisir pour les transactions onchain, y compris
  des paramètres pour payer le minimum absolu, un taux bas qui peut prendre plus d'un jour pour être confirmé, une priorité normale et
  une priorité élevée. {% assign timestamp="33:14" %}

- [BOLTs #1086][] spécifie que les nœuds doivent rejeter (rembourser) un HTLC et renvoyer une erreur `expiry_too_far` si les instructions
  pour créer une demande de [HTLC][topic htlc] transmise demandent au nœud local d'attendre plus de 2 016 blocs avant de pouvoir réclamer
  un remboursement. La réduction de ce paramètre réduit la perte maximale de revenus pour un nœud provenant d'une [attaque de congestion
  de canal particulière][topic channel jamming attacks] ou de [factures en attente de longue date][topic hold invoices]. L'augmentation
  de ce paramètre permet de faire transiter les paiements sur plus de canaux pour le même paramètre de variation HTLC maximal (ou le
  même nombre de sauts pour un paramètre de variation HTLC maximal plus élevé, ce qui peut améliorer la résistance à certaines attaques,
  telles que l'attaque de remplacement cyclique décrite dans [le bulletin de la semaine dernière][news274 cycling]).
  {% assign timestamp="35:02" %}

<div markdown="1" class="callout">
## Vous en voulez plus ?

Pour plus de discussions sur les sujets mentionnés dans cebulletin, rejoignez-nous pour le récapitulatif hebdomadaire de Bitcoin Optech
sur [Twitter Spaces][@bitcoinoptech] à 15h00 UTC le jeudi (le jour suivant la publication de la newsletter). La discussion est également
enregistrée et sera disponible sur notre page de [podcasts][podcast].

</div>

{% include references.md %}
{% include linkers/issues.md v=2 issues="28685,28651,28565,7828,2660,1086,27511" %}
[news164 pong]: /en/newsletters/2021/09/01/#lnd-5621
[towns cov]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022099.html
[russell cov]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022031.html
[news274 cov]: /fr/newsletters/2023/10/25/#recherche-sur-les-conventions-generiques-avec-des-modifications-minimales-du-langage-script
[russell cov2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022103.html
[news191 lisp]: /en/newsletters/2022/03/16/#using-chia-lisp
[heilman cat]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022049.html
[news274 cat]: /fr/newsletters/2023/10/25/#proposition-de-bip-pour-op-cat
[todd 520]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022094.html
[o'beirne vault]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022092.html
[Bitcoin Core 26.0rc1]: https://bitcoincore.org/bin/bitcoin-core-26.0/
[bitcoin core developer wiki]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki
[bitcoin core pr review club]: https://bitcoincore.reviews/#upcoming-meetings
[news274 cycling]: /fr/newsletters/2023/10/25/#vulnerabilite-de-remplacement-cyclique-contre-les-htlc
[ldk 0.0.118]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.118
[rust bitcoin 0.31.1]: https://github.com/rust-bitcoin/rust-bitcoin/releases/tag/bitcoin-0.31.0
[rb rn]: https://github.com/rust-bitcoin/rust-bitcoin/blob/master/bitcoin/CHANGELOG.md#0311---2023-10-18
[news274 hash bug]: /fr/newsletters/2023/10/25/#resume-du-hachage-du-jeu-de-sorties-utxo-de-bitcoin
[news237 pr review]: /fr/newsletters/2023/02/08/#bitcoin-core-pr-review-club
[pod237 pr review]: /en/podcast/2023/02/09/#bitcoin-core-pr-review-club-transcript