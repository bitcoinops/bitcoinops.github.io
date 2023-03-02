---
title: 'Bulletin hebdomadaire Bitcoin Optech #240'
permalink: /fr/newsletters/2023/03/01/
name: 2023-03-01-newsletter-fr
slug: 2023-03-01-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume une discussion sur le moyen le plus rapide
de vérifier qu'une sauvegarde de graine maîtresse BIP32 n'a probablement pas été
corrompue sans utiliser de dispositifs numériques.  Vous trouverez également nos
sections habituelles avec les annonces des nouvelles versions et des versions
candidates, ainsi que des descriptions des principaux changements apportés aux
logiciels d'infrastructure Bitcoin les plus répandus.

## Nouvelles

- **Sommes de contrôle de sauvegarde des semences plus rapides :** Peter Todd a
[répondu][todd codex32] à la discussion sur un projet de BIP pour Codex32 (voir
[le bulletin de la semaine dernière][news239 codex32]), un schéma qui permet de créer,
vérifier et utiliser des codes de récupération pour une graine [BIP32][topic bip32].
Un avantage particulier de Codex32 par rapport aux systèmes existants est la
possibilité de vérifier l'intégrité des sauvegardes en utilisant simplement
un stylo, du papier, de la documentation et un temps modeste.

    Tel qu'il est conçu, Codex32 fournit des garanties très fortes quant
    à sa capacité à détecter les erreurs dans les sauvegardes. Peter Todd
    a suggéré qu'une méthode beaucoup plus simple serait de générer des
    codes de récupération dont les parties pourraient être additionnées
    pour produire une somme de contrôle. Si la division de la somme de
    contrôle par une constante connue ne produit aucun reste, cela
    permettrait de vérifier l'intégrité de la sauvegarde dans les paramètres
    de l'algorithme de somme de contrôle. Peter Todd a suggéré d'utiliser
    un algorithme offrant une protection d'environ 99,9 % contre les fautes
    de frappe, ce qui, selon lui, serait suffisamment fort, facile à utiliser
    et à mémoriser pour que les gens n'aient pas besoin des documents
    supplémentaires du Codex32.

    Russell O'Connor [a répondu][o'connor codex32] qu'un code de récupération
    Codex32 complet peut être vérifié beaucoup plus rapidement qu'une vérification
    complète si l'utilisateur est prêt à accepter une protection moindre. La
    vérification de seulement deux caractères à la fois garantirait la détection
    de toute erreur d'un seul caractère dans un code de récupération et fournirait
    une protection de 99,9 % contre les autres erreurs de substitution. Le
    processus serait quelque peu similaire à la génération du type de somme
    de contrôle décrit par Peter Todd, même s'il nécessiterait l'utilisation
    d'une table de consultation spéciale que les utilisateurs ordinaires auraient
    peu de chances de mémoriser. Si les vérificateurs étaient disposés à utiliser
    une table de consultation différente chaque fois qu'ils vérifient leur code,
    chaque vérification supplémentaire augmenterait leurs chances de détecter une
    erreur jusqu'à la septième vérification, où ils auraient la même assurance
    que celle qu'ils obtiendraient en effectuant une vérification complète du
    Codex32. Aucune modification n'est nécessaire à Codex32 pour obtenir la
    propriété de vérification rapide de renforcement, bien que la documentation
    de Codex32 doive être mise à jour pour fournir les tables et feuilles de
    calcul nécessaires afin de la rendre utilisable.

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets
d'infrastructure Bitcoin. Veuillez envisager de passer aux nouvelles
versions ou d'aider à tester les versions candidates.*

- [HWI 2.2.1][] est une version de maintenance de cette application
  qui permet aux portefeuilles logiciels de s'interfacer avec des
  dispositifs de signature matériels.

- [Core Lightning 23.02rc3][] est une version candidate pour une nouvelle
  version de maintenance de cette implémentation populaire de LN.

- [lnd v0.16.0-beta.rc1][] est une version candidate pour une nouvelle
  version majeure de cette implémentation populaire de LN.

## Principaux changements de code et de documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], et [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #25943][] ajoute un paramètre au RPC `sendrawtransaction`.
  pour limiter le montant des fonds brûlés par sortie. Si la transaction
  contient une sortie dont le script est heuristiquement considéré comme
  non dépensable (avec un `OP_RETURN`, un opcode invalide, ou dépassant
  la taille maximale du script) et dont la valeur est supérieure à
  `maxburnamount`, elle ne sera pas soumise au mempool. Par défaut,
  le montant est fixé à zéro, ce qui protège les utilisateurs de
  brûler involontairement des fonds.

- [Bitcoin Core #26595][] ajoute les paramètres `wallet_name` et `passphrase`
  au RPC [`migratewallet`][news217 migratewallet] afin de supporter la migration
  des anciens portefeuilles cryptés et des portefeuilles qui ne sont pas
  actuellement chargés dans les portefeuilles [descripteurs][topic descriptors].

- [Bitcoin Core #27068][] met à jour la façon dont Bitcoin Core gère
  la saisie des phrases de passe. Auparavant, une phrase de passe contenant
  un caractère ASCII nul (0x00) était acceptée---mais seule la partie de la
  chaîne jusqu'au premier caractère nul était utilisée dans le processus de
  cryptage du portefeuille. Cela pouvait conduire à un porte-monnaie dont
  la phrase de passe était beaucoup moins sûre que ce à quoi l'utilisateur
  s'attendait. Ce PR utilisera la totalité de la phrase de passe, y compris
  les caractères nuls, pour le cryptage et le décryptage. Si l'utilisateur
  entre une phrase de passe contenant des caractères nuls et ne parvient pas
  à décrypter un portefeuille existant, ce qui indique qu'il a peut-être
  défini une phrase de passe selon l'ancien comportement, il recevra des
  instructions pour contourner le problème.

- [LDK #1988][] ajoute des limites pour les connexions entre pairs et
  les canaux non financés afin de prévenir les attaques par déni de service
  par épuisement des ressources. Les nouvelles limites sont les suivantes :

    - Un maximum de 250 pairs de partage de données qui n'ont pas de canal
      financé avec le nœud local.

    - Un maximum de 50 pairs qui peuvent actuellement essayer d'ouvrir
      un canal avec le nœud local.

    - Un maximum de 4 canaux qui n'ont pas encore été financés à partir
      d'un même pair.

- [LDK #1977][] rend publiques ses structures de sérialisation et d'analyse
  des [offres][topic offers] telles que définies dans [le projet BOLT12][bolts #798].
  LDK ne supporte pas encore les [chemins aveugles][topic rv routing], il ne
  peut donc pas actuellement envoyer ou recevoir des offres directement, mais
  ce PR permet aux développeurs de commencer à les expérimenter.

{% include references.md %}
{% include linkers/issues.md v=2 issues="25943,26595,27068,1988,1977,798" %}
[core lightning 23.02rc3]: https://github.com/ElementsProject/lightning/releases/tag/v23.02rc3
[lnd v0.16.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.0-beta.rc1
[hwi 2.2.1]: https://github.com/bitcoin-core/HWI/releases/tag/2.2.1
[news239 codex32]: /fr/newsletters/2023/02/22/#proposition-de-bip-pour-le-systeme-dencodage-des-semences-codex32
[todd codex32]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021498.html
[o'connor codex32]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021504.html
[news217 migratewallet]: /fr/newsletters/2022/09/14/#bitcoin-core-19602
