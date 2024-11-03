---
title: 'Bulletin Hebdomadaire Bitcoin Optech #292'
permalink: /fr/newsletters/2024/03/06/
name: 2024-03-06-newsletter-fr
slug: 2024-03-06-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume une discussion sur la mise à jour de la spécification pour les
URI `bitcoin:` de BIP21, décrit une proposition pour gérer plusieurs sessions de signature MuSig2
concurrentes avec un minimum d'état, renvoie à un fil de discussion sur l'ajout d'éditeurs pour le
dépôt des BIPs, et discute d'un ensemble d'outils permettant de porter rapidement le projet GitHub
de Bitcoin Core vers un projet GitLab auto-hébergé. Sont également incluses nos sections habituelles avec
des annonces de mises à jour et versions candidates, ainsi que les changements
apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Mise à jour des URI `bitcoin:` de BIP21 :** Josie Baker a [posté][baker bip21] sur Delving
  Bitcoin pour discuter des utilisations prévues par les spécifications des URI [BIP21][],
  de leur utilisation réelle aujourd'hui, et de leurs utilisions possibles à l'avenir. La
  spécification exige que le corps immédiatement après le deux-points soit une adresse Bitcoin P2PKH
  classique, par exemple `bitcoin:1BoB...`. Après le corps, des paramètres supplémentaires peuvent
  être passés en utilisant le codage de requête HTTP, y compris des adresses pour des formats
  d'adresse non classiques. Par exemple, une adresse bech32m pourrait être
  `bitcoin:1Bob...?bech32m=bc1pbob...`. Cependant, cela est significativement différent de la manière
  dont les URI `bitcoin:` sont utilisées. Des adresses non-P2PKH sont souvent utilisées comme corps et
  parfois le corps est laissé vide par des logiciels qui souhaitent uniquement recevoir des paiements
  via un protocole de paiement alternatif. De plus, Baker note que les URI `bitcoin:` sont de plus en
  plus utilisées pour transmettre des identifiants persistants respectueux de la vie privée, tels que
  ceux pour les [paiements silencieux][topic silent payments] et les [offres][topic offers].

  Comme discuté dans le fil, une amélioration pourrait être que le créateur de l'URI spécifie toutes
  les méthodes de paiement qu'ils prennent en charge en utilisant des paramètres nus, par exemple :
  `bitcoin:?bc1q...&sp1q...`. Celui qui effectue la dépense (et qui est généralement responsable du paiement des frais)
  pourrait alors choisir sa méthode de paiement préférée dans la liste. Bien que certains points
  techniques mineurs soient encore discutés au moment de la rédaction de cet article, aucune critique majeure de
  cette approche n'a été publiée.

- **PSBT pour plusieurs sessions de signature MuSig2 concurrentes :** Salvatore Ingala a
  [posté][ingala musig2] sur Delving Bitcoin à propos de la minimisation de la quantité d'état
  nécessaire pour effectuer plusieurs sessions de signature [MuSig2][topic musig] en parallèle. En
  utilisant l'algorithme de signature décrit dans [BIP327][], un groupe de co-signataires devra
  temporairement stocker une quantité de données qui augmente linéairement pour chaque entrée
  supplémentaire qu'ils veulent ajouter à une transaction qu'ils créent. Avec de nombreux dispositifs
  de signature matérielle limités dans la quantité de stockage disponible, il serait très utile de
  minimiser la quantité d'état requise (sans réduire la sécurité).

  Ingala propose de générer un seul objet d'état pour un [PSBT][topic psbt] entier, puis de dériver de
  manière déterministe l'état par entrée à partir de celui-ci d'une manière qui rend toujours le
  résultat indiscernable à partir d'un aléatoire. De cette manière, la quantité d'état qu'un signataire
  doit stocker reste constante, peu importe le nombre d'entrées qu'une transaction possède.

  Dans une [réponse][scott musig2], le développeur Christopher Scott a noté que [BitEscrow][] utilise
  déjà un mécanisme similaire.

- **Discussion sur l'ajout de plus d'éditeurs BIP :** Ava Chow [a posté][chow bips] sur la liste de
  diffusion Bitcoin-Dev pour suggérer l'ajout d'éditeurs BIP pour aider l'éditeur actuel. L'éditeur
  actuel, Luke Dashjr, [dit][dashjr backlogged] qu'il est surchargé et a demandé de l'aide. Chow a
  suggéré deux contributeurs experts bien connus pour devenir éditeurs, ce qui semblait avoir du
  soutien. Il a également été discuté si les éditeurs supplémentaires devraient avoir la capacité
  d'attribuer des numéros BIP. Aucune résolution claire n'a été atteinte à ce jour.

- **Sauvegarde GitLab pour le projet GitHub de Bitcoin Core :** Fabian Jahr [a posté][jahr gitlab]
  sur Delving Bitcoin concernant le maintien d'une sauvegarde du compte GitHub du projet Bitcoin Core
  sur une instance GitLab auto-hébergée. Au cas où le projet devrait quitter GitHub soudainement, cela
  rendrait tous les problèmes existants et les demandes de PR accessibles sur GitLab dans un court
  laps de temps, permettant de continuer le travail avec seulement une brève interruption. Jahr a
  fourni un aperçu du projet sur GitLab et prévoit de continuer les sauvegardes pour permettre de
  passer rapidement à GitLab si nécessaire. Son post n'a reçu aucun commentaire à ce jour, mais nous
  le remercions de rendre une transition potentielle aussi facile que possible.

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets
d'infrastructure Bitcoin. Veuillez envisager de passer aux nouvelles
versions ou d'aider à tester les versions candidates.*

- [Eclair v0.10.0][] est une nouvelle version majeure de cette implémentation de nœud LN. Elle
  "ajoute un support officiel pour la [fonction de double-financement][topic dual funding], une
  implémentation à jour de BOLT12 des [offres][topic offers], et un prototype de [splicing][topic
  splicing] entièrement fonctionnel" en plus de "diverses améliorations des frais on-chain, plus
  d'options de configuration, des améliorations de performance et diverses corrections de bugs
  mineurs".

- [Bitcoin Core 26.1rc1][] est une version candidate pour une version de maintenance de cette
  implémentation de nœud complet prédominante.

## Changements notables dans le code et la documentation

_Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core
lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust
Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo], [Propositions
d'Amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Inquisition
Bitcoin][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #29412][] ajoute du code qui vérifie chaque manière connue de prendre un bloc
  valide, de le muter et de produire un bloc alternatif qui est invalide mais a le même hash d'en-tête
  de bloc. Les blocs mutés ont causé plusieurs vulnérabilités dans le passé. En 2012, et à nouveau en
  2017, le rejet en cache par Bitcoin Core des blocs invalides signifiait qu'un attaquant pouvait
  prendre un nouveau bloc valide, le muter en un bloc invalide et le soumettre au nœud d'une victime;
  ce nœud le rejetterait comme invalide et n'accepterait pas plus tard la forme valide du bloc
  (jusqu'à ce que le nœud soit redémarré), le détachant de la meilleure chaîne de blocs et permettant
  à l'attaquant de réaliser un type d'[attaque éclipse][topic eclipse attacks] ; voir le [Bulletin
  #37][news37 invalid] pour plus de détails. Plus récemment, lorsque Bitcoin Core demandait un bloc à
  un pair, un autre pair pouvait envoyer un bloc muté qui amènerait Bitcoin Core à arrêter d'attendre
  le bloc du premier pair ; une correction pour cela a été décrite dans le [Bulletin #251][news251
  block].

  Le code ajouté dans cette PR permet de vérifier rapidement si un bloc nouvellement reçu contient
  l'un des types de mutations connus qui le rend invalide. Si c'est le cas, le bloc muté peut être
  rejeté dès le début, en espérant empêcher quoi que ce soit à son sujet d'être mis en cache ou
  utilisé pour empêcher le traitement correct d'une version valide du bloc qui sera reçue plus tard.

- [Eclair #2829][] permet aux plugins de définir une politique de contribution à l'ouverture d'un
  [canal à double financement][topic dual funding]. Par défaut, Eclair ne contribue pas à l'ouverture
  d'un canal à double financement. Ce PR permet aux plugins de outrepasser cette politique et de décider
  quelle part des fonds de l'opérateur de nœud doit être versée à un nouveau canal.

- [LND #8378][] apporte plusieurs améliorations aux fonctionnalités de [sélection de pièces][topic
  coin selection] de LND, y compris permettre aux utilisateurs de choisir leur stratégie de sélection
  de pièces et également permettre à un utilisateur de spécifier certains inputs qui doivent être
  inclus dans une transaction mais permettant à la stratégie de sélection de pièces de trouver tous
  les inputs supplémentaires nécessaires.

- [BIPs #1421][] ajoute [BIP345][] pour l'opcode `OP_VAULT` et les changements de consensus associés
  qui, s'ils sont activés dans un soft fork, ajouteraient un support pour les [coffre-forts][topic vaults].
  Contrairement aux coffre-forts possibles aujourd'hui avec des transactions pré-signées, les coffre-forts BIP345
  ne sont pas vulnérables aux attaques de substitution de transactions de dernière minute. Les coffre-forts
  BIP345 permettent également des opérations [groupées][topic payment batching] qui les rendent plus
  efficaces que la plupart des designs proposés qui utilisent seulement des mécanismes de
  [covenant][topic covenants] plus génériques.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29412,2829,8378,1421" %}
[jahr gitlab]: https://delvingbitcoin.org/t/gitlab-backups-for-bitcoin-core-repository/624
[ingala musig2]: https://delvingbitcoin.org/t/state-minimization-in-musig2-signing-sessions/626
[scott musig2]: https://delvingbitcoin.org/t/state-minimization-in-musig2-signing-sessions/626/2
[baker bip21]: https://delvingbitcoin.org/t/revisiting-bip21/630
[bitescrow]: https://github.com/BitEscrow/escrow-core
[chow bips]: https://gnusha.org/pi/bitcoindev/2092f7ff-4860-47f8-ba1a-c9d97927551e@achow101.com/
[dashjr backlogged]: https://twitter.com/LukeDashjr/status/1761127972302459000
[news37 invalid]: /en/newsletters/2019/03/12/#bitcoin-core-vulnerability-disclosure
[news251 block]: /fr/newsletters/2023/05/17/#bitcoin-core-27608
[eclair v0.10.0]: https://github.com/ACINQ/eclair/releases/tag/v0.10.0
[bitcoin core 26.1rc1]: https://bitcoincore.org/bin/bitcoin-core-26.1/
