---
title: 'Bulletin Hebdomadaire Bitcoin Optech #343'
permalink: /fr/newsletters/2025/02/28/
name: 2025-02-28-newsletter-fr
slug: 2025-02-28-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume un article qui évoque la possibilité pour les nœuds complets d'ignorer
les transactions qui sont relayées sans avoir été demandées au préalable. Sont également incluses
nos sections régulières avec les questions et réponses populaires du Bitcoin Stack Exchange, les
annonces de nouvelles versions et de candidats à la publication, et les résumés des modifications
notables apportées aux logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

- **Ignorer les transactions non sollicitées :** Antoine Riard a [posté][riard unsol] sur
  Bitcoin-Dev deux BIPs provisoires qui permettraient à un nœud de signaler qu'il n'acceptera plus les
  messages `tx` qu'il n'a pas demandés au préalable avec un message `inv`, appelées _transactions non
  sollicitées_. Riard avait précédemment proposé l'idée générale en 2021 (voir le [Bulletin
  #136][news136 unsol]). Le premier BIP proposé ajoute un mécanisme permettant aux nœuds de signaler
  leurs capacités et préférences de relais de transactions ; le deuxième BIP proposé utilise ce
  mécanisme de signalisation pour indiquer que le nœud ignorera les transactions non sollicitées.

  Cette proposition présente plusieurs avantages mineurs, comme discuté dans une [PR Bitcoin
  Core][bitcoin core #30572], mais elle entre en conflit avec la conception de certains
  clients légers plus anciens et pourrait empêcher les utilisateurs de ce logiciel de pouvoir diffuser
  leurs transactions, donc un déploiement soigneux pourrait être nécessaire. Bien que Riard ait ouvert
  la PR susmentionnée, il l'a fermée ensuite après avoir indiqué qu'il prévoyait de
  travailler sur sa propre implémentation de nœud complet basée sur libbitcoinkernel. Il a également
  indiqué que la proposition pourrait aider à adresser certaines attaques qu'il a récemment divulguées
  (voir le [Bulletin #332][news332 txcen]).

## Questions et réponses sélectionnées du Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech
cherchent des réponses à leurs questions---ou quand nous avons quelques moments libres pour aider
les utilisateurs curieux ou confus. Dans cette rubrique mensuelle, nous mettons en lumière certaines
des questions et réponses les mieux votées publiées depuis notre dernière mise à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Quelle est la raison d'être de la configuration du RPC loadtxsoutset ?]({{bse}}125627)
  Pieter Wuille explique pourquoi la valeur de [assumeUTXO][topic assumeUTXO] pour représenter
  l'ensemble UTXO est codée en dur à une hauteur de bloc particulière, les moyens de distribuer les
  instantanés assumeUTXO à l'avenir, et les avantages de assumeUTXO par rapport à la simple copie des
  magasins de données internes de Bitcoin Core.

- [Y a-t-il des classes d'attaques de pinning que la règle RBF #3 rend impossibles ?]({{bse}}125461)
  Murch souligne que la règle [RBF][topic rbf] #3 n'est pas destinée à prévenir les attaques de
  [pinning][topic transaction pinning] et aborde la [politique de remplacement][bitcoin core
  replacements] de Bitcoin Core.

- [Valeurs de locktime inattendues]({{bse}}125562)
  L'utilisateur polespinasa liste les différentes raisons pour lesquelles Bitcoin Core définit des
  valeurs de [nLockTime][topic timelocks] spécifiques : à `block_height` pour éviter le [fee sniping][topic fee
  sniping], une valeur aléatoire inférieure à la hauteur du bloc 10% du temps pour la confidentialité,
  ou 0 si la blockchain n'est pas à jour.

- [Pourquoi est-il nécessaire de révéler un bit dans un script path spend et de vérifier qu'il correspond à la parité de la coordonnée Y de Q ?]({{bse}}125502)
  Pieter Wuille explique la [rationale de BIP341][bip341 rationale] pour maintenir la vérification de
  la parité de la coordonnée Y pendant les dépenses de script path [taproot][topic taproot] afin de
  permettre l'ajout potentiel futur de la fonctionnalité de validation en lot.

- [Pourquoi Bitcoin Core utilise-t-il des points de contrôle et non le bloc assumevalid ?]({{bse}}125626)
  Pieter Wuille détaille une histoire des points de contrôle dans Bitcoin Core et à quel but ils ont
  servi, et pointe vers une PR ouverte et une discussion sur [la suppression des points de
  contrôle][Bitcoin Core #31649].

- [Comment Bitcoin Core gère-t-il les longs reorgs ?]({{bse}}105525)
  Pieter Wuille décrit comment Bitcoin Core gère les réorganisations de la blockchain, en faisant remarquer
  qu'une différence dans les réorganisations plus importants est que "le retour de transactions au pool de mémoire
  n'est pas effectué".

- [Quelle est la définition de discard feerate ?]({{bse}}125623)
  Murch définit le discard feerate comme le feerate maximum pour jeter le changement et résume le code
  pour calculer le discard feerate comme "le feerate cible de 1000 blocs recadré à 3–10 ṩ/vB s'il sort
  de cette plage".

- [Politique au compilateur miniscript]({{bse}}125406)
  Brunoerg note que le portefeuille Liana utilise le langage de politique et pointe vers les
  bibliothèques [sipa/miniscript][miniscript github] et [rust-miniscript][rust-miniscript github]
  comme exemples de compilateurs de politique.

## Mises à jour et versions candidates

_Nouvelles mises-à-jours et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles mises-à-jour ou d'aider à tester les versions candidates._

- [Core Lightning 25.02rc3][] est un candidat à la sortie pour la prochaine version majeure de ce
  nœud LN populaire.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core
lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust
Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Propositions
d'Amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips
repo], [Inquisition Bitcoin][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Core Lightning #8116][] change le traitement des négociations de fermeture de canal interrompues
  pour réessayer le processus même s'il n'est pas nécessaire. Cela corrige un problème où un nœud
  manquant le message `CLOSING_SIGNED` de son pair obtient une erreur lors de la reconnexion et
  diffuse une transaction de fermeture unilatérale. Pendant ce temps,
  le pair, déjà dans l'état `CLOSINGD_COMPLETE`, a diffusé la transaction de clôture mutuelle, ce qui
  pourrait entraîner une course entre les deux transactions. Cette correction permet de continuer la
  renégociation jusqu'à ce que la transaction de clôture mutuelle soit confirmée.

- [Core Lightning #8095][] ajoute un drapeau `transient` à la commande `setconfig` (voir le Bulletin
  [#257][news257 setconfig]), introduisant des variables de configuration dynamiques qui sont
  appliquées temporairement sans modifier le fichier de configuration. Ces modifications sont
  réinitialisés au redémarrage.

- [Core Lightning #7772][] ajoute un crochet `commitment_revocation` au plugin `chanbackup` qui met
  à jour le fichier `emergency.recover` (voir le Bulletin [#324][news324 emergency]) chaque fois qu'un
  ouveau secret de révocation est reçu. Cela permet aux utilisateurs de diffuser une transaction de
  pénalité lors du balayage des fonds en utilisant `emergency.recover` si le pair a publié un état
  révoqué obsolète. Cette PR étend le format SCB [static channel backup][topic static channel backups]
  et met à jour le plugin `chanbackup` pour sérialiser à la fois les nouveaux formats et les formats
  hérités.

- [Core Lightning #8094][] introduit une variable `xpay-slow-mode` configurable à l'exécution pour
  le plugin `xpay` (voir le Bulletin [#330][news330 xpay]), qui retarde le retour de succès ou d'échec
  jusqu'à ce que toutes les parties d'un paiement [multipath payments][topic multipath payments] (MPP)
  soient résolues. Sans ce paramètre, un statut d'échec pourrait être renvoyé même si certains
  [HTLCs][topic htlc] sont encore en attente. Si un utilisateur réessaie et paie avec succès la
  facture depuis un autre nœud, un surpaiement pourrait se produire si le HTLC en attente est
  également réglé.

- [Eclair #2993][] permet au destinataire de payer les frais associés à la partie [aveuglée][topic rv
  routing] d'un chemin de paiement, tandis que l'expéditeur couvre les frais pour la partie non
  aveuglée. Auparavant, l'expéditeur payait tous les frais, ce qui pourrait lui permettre d'inférer et
  potentiellement de dévoiler le chemin.

- [LND #9491][] ajoute la prise en charge des fermetures de canaux coopératives lorsqu'il y a des
  [HTLCs][topic htlc] actifs en utilisant la commande `lncli closechannel`. Lorsqu'initiée, LND
  arrêtera le canal pour empêcher la création de nouveaux HTLCs et attendra que tous les HTLCs
  existants soient résolus avant de commencer le processus de négociation. Les utilisateurs doivent
  définir le paramètre `no_wait` pour activer ce comportement ; sinon, un message d'erreur les
  invitera à le spécifier. Cette PR assure également que le paramètre `max_fee_rate` est appliqué pour
  les deux parties lorsqu'une fermeture de canal coopérative est initiée ; auparavant, il était
  uniquement appliqué à la partie distante.

{% include snippets/recap-ad.md when="2025-03-04 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30572,8116,8095,7772,8094,2993,9491,31649" %}
[riard unsol]: https://mailing-list.bitcoindevs.xyz/bitcoindev/e98ec3a3-b88b-4616-8f46-58353703d206n@googlegroups.com/
[news136 unsol]: /en/newsletters/2021/02/17/#proposal-to-stop-processing-unsolicited-transactions
[news332 txcen]: /fr/newsletters/2024/12/06/#vulnerabilite-de-censure-de-transaction
[Core Lightning 25.02rc3]: https://github.com/ElementsProject/lightning/releases/tag/v25.02rc3
[news257 setconfig]: /fr/newsletters/2023/06/28/#core-lightning-6303
[news324 emergency]: /fr/newsletters/2024/10/11/#core-lightning-7539
[news330 xpay]: /fr/newsletters/2024/11/22/#core-lightning-7799
[bitcoin core replacements]: https://github.com/bitcoin/bitcoin/blob/master/doc/policy/mempool-replacements.md#current-replace-by-fee-policy
[bip341 rationale]: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki#cite_note-10
[miniscript github]: https://github.com/sipa/miniscript
[rust-miniscript github]: https://github.com/rust-bitcoin/rust-miniscript
