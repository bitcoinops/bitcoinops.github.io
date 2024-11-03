---
title: 'Bulletin Hebdomadaire Bitcoin Optech #303'
permalink: /fr/newsletters/2024/05/17/
name: 2024-05-17-newsletter-fr
slug: 2024-05-17-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume un nouveau schéma pour les jetons d'utilisation anonymes qui
pourraient être utilisés pour les annonces de canaux LN et plusieurs autres protocoles de
coordination résistants aux attaques Sybil, inclut des liens vers des discussions sur un nouveau
schéma de division de phrase de semence BIP39, annonce une alternative à BitVM pour vérifier
l'exécution réussie de programmes arbitraires dans des protocoles de contrat interactifs, et
rapporte des suggestions pour la mise à jour du processus BIP.

## Actualités

- **Jetons d'utilisation anonymes :** Adam Gibson a [publié][gibson autct] sur Delving Bitcoin un
  schéma qu'il a développé permettant à quiconque pouvant [dépenser par chemin de clé][topic taproot]
  un UTXO de prouver qu'il pourrait le dépenser sans révéler quel UTXO il s'agit. Cela fait suite aux
  travaux précédents de Gibson sur le développement de mécanismes anti-Sybil [PoDLE][news85 podle]
  (utilisé dans l'implémentation [coinjoin][topic coinjoin] de Joinmarket) et [RIDDLE][news205 riddle].

  Une utilisation qu'il décrit est l'annonce de canaux LN. Chaque nœud LN annonce ses canaux aux
  autres nœuds LN afin qu'ils puissent trouver des chemins pour acheminer les fonds à travers le
  réseau. Une grande partie de ces informations sur les canaux est stockée en mémoire et les annonces
  sont souvent rediffusées pour s'assurer qu'elles atteignent autant de nœuds que possible. Si un
  attaquant pouvait annoncer facilement de faux canaux, il pourrait gaspiller une quantité excessive
  de mémoire et de bande passante des nœuds honnêtes, en plus de perturber la recherche de chemin. Les
  nœuds LN traitent cela aujourd'hui en acceptant uniquement les annonces qui sont signées par une clé
  appartenant à un UTXO valide. Cela nécessite que les co-propriétaires du canal identifient l'UTXO
  spécifique qu'ils co-détiennent, ce qui peut associer ces fonds à d'autres transactions en chaîne
  passées ou futures qu'ils créent (ou conduire à une association inexacte).

  Avec le schéma de Gibson, appelé jetons d'utilisation anonymes avec arbres courbes (autct), les
  co-propriétaires du canal pourraient signer un message sans révéler leur UTXO. Un attaquant sans
  UTXO ne pourrait pas créer de signature valide. Un attaquant qui possède un UTXO pourrait créer une
  signature valide, mais il devrait conserver autant d'argent dans cet UTXO qu'un nœud LN devrait
  conserver dans un canal, limitant ainsi le pire cas de toute attaque. Voir le [Bulletin #261][news261
  lngossip] pour une discussion précédente sur la dissociation des [annonces de canal][topic channel
  announcements] d'UTXOs particuliers.

  Gibson décrit également plusieurs autres façons d'utiliser les autct. Un mécanisme de
  base pour accomplir ce type de confidentialité, les signatures en anneau, est connu depuis
  longtemps, mais Gibson utilise une nouvelle construction cryptographique ([arbres courbes][])
  pour rendre les preuves plus compactes et plus rapides à vérifier. Il fait également en sorte que
  chaque preuve s'engage privément sur la clé utilisée afin qu'un seul UTXO ne puisse pas être utilisé
  pour créer un nombre illimité de signatures valides.

  En plus de publier le [code][autct repo], Gibson a également publié un
  preuve de concept sur le [forum][hodlboard] qui nécessite de fournir une preuve automatique pour
  s'inscrire, offrant un environnement où chacun est reconnu comme détenteur de bitcoins mais sans
  avoir à fournir d'informations d'identification sur eux-mêmes ou leurs bitcoins.

- **Fractionnement de phrase de semence BIP39 :** Rama Gan [a posté][gan penlock] sur la liste de
  diffusion Bitcoin-Dev un lien vers un [ensemble d'outils][penlock website] qu'ils ont développé pour
  générer et fractionner une phrase de semence [BIP39][] sans utiliser d'équipement informatique
  électronique (sauf pour imprimer les instructions et les modèles). Cela est similaire à
  [codex32][topic codex32] mais fonctionne sur des mots de semence BIP39 qui sont compatibles avec
  presque tous les dispositifs de signature matérielle actuels et de nombreux portefeuilles logiciels.

  Andrew Poelstra, co-auteur de codex32, [a répondu][poelstra penlock1] avec plusieurs commentaires et
  suggestions. Sans essayer les deux schémas---ce qui prendrait plusieurs heures
  pour chacun---l'ensemble exact des compromis n'est pas clair. Cependant, les deux
  semblent offrir les mêmes capacités fondamentales : des instructions pour générer une seed de
  manière sécurisée hors ligne ; la capacité de diviser la seed en plusieurs parts en utilisant [le
  partage secret de Shamir][sss]; la capacité de reconstituer les parts en la seed originale; et la
  capacité de vérifier les sommes de contrôle sur les parts et la seed originale, permettant aux
  utilisateurs de détecter la corruption des données tôt lorsque les données originales pourraient
  encore être récupérables.

- **Alternative à BitVM :** Sergio Demian Lerner et plusieurs co-auteurs [ont posté][lerner bitvmx]
  sur la liste de diffusion Bitcoin-Dev à propos d'une nouvelle architecture de CPU virtuel basée en
  partie sur les idées derrière [BitVM][topic acc]. Le but de leur projet, BitVMX, est de pouvoir
  prouver efficacement l'exécution correcte de tout programme qui peut être compilé pour fonctionner
  sur une architecture CPU établie, telle que [RISC-V][]. Comme BitVM, BitVMX ne nécessite aucun
  changement de consensus, mais il nécessite qu'une ou plusieurs parties désignées agissent en tant
  que vérificateur de confiance. Cela signifie que plusieurs utilisateurs participant de manière
  interactive à un protocole de contrat peuvent empêcher une ou plusieurs des parties de retirer de
  l'argent du contrat à moins que cette partie n'exécute avec succès un programme arbitraire spécifié
  par le contrat.

  Lerner renvoie à un [document][bitvmx paper] sur BitVMX qui le compare à BitVM original (voir
  le [Bulletin #273][news273 bitvm]) et aux détails limités disponibles sur les projets de suivi des
  développeurs de BitVM original. Un [site web][bitvmx website] accompagnateur fournit des
  informations supplémentaires sous une forme légèrement moins technique.

- **Discussion continue sur la mise à jour de BIP2 :** Mark "Murch" Erhardt [a continué][erhardt
  bip2] la discussion sur la liste de diffusion Bitcoin-Dev concernant la mise à jour de [BIP2][], qui
  est le document qui décrit actuellement le processus des propositions d'amélioration de Bitcoin
  (BIP). Son email décrit plusieurs problèmes, suggère des solutions pour beaucoup d'entre eux, et
  sollicite des retours sur ses suggestions ainsi que des propositions de solutions pour les problèmes
  restants. Pour les discussions précédentes sur la mise à jour de BIP2, voir le [Bulletin #297][news297 bip2].

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets
d'infrastructure Bitcoin. Veuillez envisager de passer aux nouvelles
versions ou d'aider à tester les versions candidates.*

- [LND v0.18.0-beta.rc2][] est un candidat à la version pour la prochaine version majeure de cette
  implémentation populaire de nœud LN.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core
lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust
Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Propositions
d'Amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Inquisition
Bitcoin][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Core Lightning #7190][] ajoute un décalage supplémentaire (appelé `chainlag`) dans le calcul du
  timelock [HTLC][topic htlc]. Cela permet aux HTLCs de cibler la hauteur actuelle du bloc au lieu du
  bloc le plus récent que le nœud LN a traité (sa hauteur de synchronisation). Cela rend sûr pour un
  nœud d'envoyer des paiements pendant le processus de synchronisation de la blockchain.

- [LDK #2973][] implémente le support pour `OnionMessenger` afin d'intercepter les [messages
  en onion][topic onion messages] au nom des pairs hors ligne. Il génère des événements lors de
  l'interception de messages et lorsque le pair revient en ligne pour la transmission. Les
  utilisateurs doivent maintenir une _liste d'autorisation_ pour stocker uniquement les messages pour
  les pairs pertinents. C'est un pas vers le support des [paiements asynchrones][topic async payments]
  à travers `held_htlc_available` de [BOLTs #989][]. Dans ce protocole, Alice veut payer Carol à travers
  Bob, mais Alice ne sait pas si Carol est en ligne. Alice envoie un message onion à Bob ; Bob retient
  le message jusqu'à ce que Carol soit en ligne ; Carol ouvre le message, qui lui dit de demander un
  paiement à Alice (ou au fournisseur de services Lightning d'Alice) ; Carol demande le paiement et
  Alice l'envoie de manière normale.

- [LDK #2907][] étend la gestion de `OnionMessage` pour accepter une entrée `Responder` optionnelle
  et retourner un objet `ResponseInstructions` qui indique comment la réponse au message doit être
  gérée. Ce changement permet des réponses de messagerie onion asynchrones et ouvre la porte à des
  mécanismes de réponse plus complexes, tels que ceux qui pourraient être nécessaires pour les
  [paiements asynchrones][topic async payments].

- [BDK #1403][] met à jour le crate `bdk_electrum` pour utiliser de nouvelles structures de
  synchronisation/scan complet introduites dans [BDK #1413][], une liste chaînée `CheckPoint`
  consultable avec [BDK #1369][], et des transactions clonables à faible coût dans des pointeurs `Arc` du [BDK
  #1373][]. Ce changement améliore la performance de
  portefeuilles scannant les données de transaction via un serveur de style Electrum. Il est désormais
  également possible de récupérer des `TxOut`s pour permettre le calcul des frais sur les transactions
  reçues d'un portefeuille externe.

- [BIPs #1458][] ajoute [BIP352][] qui propose des [paiements silencieux][topic silent payments], un
  protocole pour des adresses de paiement réutilisables qui génèrent une adresse unique sur la chaîne
  à chaque utilisation. Le projet de BIP a été discuté pour la première fois dans le [Bulletin
  #255][news255 bip352].

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when="2024-05-21 14:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="7190,2973,2907,1403,1458,989,1413,1369,1373" %}
[lnd v0.18.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.0-beta.rc2
[gibson autct]: https://delvingbitcoin.org/t/anonymous-usage-tokens-from-curve-trees-or-autct/862/
[news261 lngossip]: /fr/newsletters/2023/07/26/#annonces-de-canaux-mises-a-jour
[news205 riddle]: /en/newsletters/2022/06/22/#new-riddle-anti-sybil-method
[news85 podle]: /en/newsletters/2020/02/19/#using-podle-in-ln
[arbres courbes]: https://eprint.iacr.org/2022/756
[autct repo]: https://github.com/AdamISZ/aut-ct
[hodlboard]: https://hodlboard.org/
[gan penlock]: https://mailing-list.bitcoindevs.xyz/bitcoindev/9bt6npqSdpuYOcaDySZDvBOwXVq_v70FBnIseMT6AXNZ4V9HylyubEaGU0S8K5TMckXTcUqQIv-FN-QLIZjj8hJbzfB9ja9S8gxKTaQ2FfM=@proton.me/
[penlock website]: https://beta.penlock.io/
[poelstra penlock1]: https://mailing-list.bitcoindevs.xyz/bitcoindev/ZkIYXs7PgbjazVFk@camus/
[sss]: https://en.m.wikipedia.org/wiki/Shamir%27s_secret_sharing
[lerner bitvmx]: https://mailing-list.bitcoindevs.xyz/bitcoindev/5189939b-baaf-4366-92a7-3f3334a742fdn@googlegroups.com/
[risc-v]: https://en.wikipedia.org/wiki/RISC-V
[bitvmx paper]: https://bitvmx.org/files/bitvmx-whitepaper.pdf
[news273 bitvm]: /fr/newsletters/2023/10/18/#paiements-conditionnels-a-une-computation-arbitraire
[bitvmx website]: https://bitvmx.org/
[erhardt bip2]: https://mailing-list.bitcoindevs.xyz/bitcoindev/0bc47189-f9a6-400b-823c-442974c848d5@murch.one/
[news297 bip2]: /fr/newsletters/2024/04/10/#mise-a-jour-de-bip2
[news255 bip352]: /fr/newsletters/2023/06/14/#projet-de-bip-pour-les-paiements-silencieux
