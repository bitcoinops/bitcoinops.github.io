---
title: 'Bulletin Hebdomadaire Bitcoin Optech #264'
permalink: /fr/newsletters/2023/08/16/
name: 2023-08-16-newsletter-fr
slug: 2023-08-16-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de la semaine résume une discussion sur l'ajout de dates d'expiration aux adresses de paiement silencieux et donne
un aperçu d'un projet de BIP pour le payjoin sans serveur. Un rapport de terrain complet décrit la mise en œuvre et le déploiement
d'un portefeuille basé sur MuSig2 pour les multisignatures sans script. Sont également incluses nos sections régulières avec
des annonces de mises à jour et versions candidates, ainsi que les changements apportés aux principaux logiciels
d'infrastructure Bitcoin.

## Nouvelles

- **Ajout de métadonnées d'expiration aux adresses de paiement silencieux :** Peter Todd a [posté][todd expire] sur la liste de
  diffusion Bitcoin-Dev une recommandation visant à ajouter une date d'expiration choisie par l'utilisateur aux adresses pour
  les [paiements silencieux][topic silent payments]. Contrairement aux adresses Bitcoin classiques qui entraînent une
  [liaison de sortie][topic output linking] si elles sont utilisées pour recevoir plusieurs paiements, les adresses pour les
  paiements silencieux entraînent un script de sortie unique à chaque utilisation correcte. Cela peut améliorer considérablement
  la confidentialité lorsqu'il est impossible ou peu pratique pour les destinataires de fournir aux payeurs une adresse
  régulière différente pour chaque paiement séparé.

    Peter Todd note qu'il serait souhaitable que toutes les adresses expirent : à un moment donné, la plupart des utilisateurs
    cesseront d'utiliser un portefeuille. L'utilisation attendue unique des adresses classiques rend l'expiration moins
    préoccupante, mais l'utilisation répétée attendue des paiements silencieux rend plus important qu'ils incluent une durée
    de validité. Il suggère l'inclusion soit d'une durée d'expiration de deux octets dans les adresses qui prendrait en charge
    des dates d'expiration allant jusqu'à 180 ans à partir de maintenant, soit d'une durée de trois octets qui prendrait en
    charge des dates d'expiration allant jusqu'à environ 45 000 ans à partir de maintenant.

    La recommandation a suscité une discussion modérée sur la liste de diffusion, sans résolution claire à l'heure actuelle.

- **Payjoin sans serveur :** Dan Gould a [posté][gould spj] sur la liste de diffusion Bitcoin-Dev un [projet de BIP][spj bip]
  pour le _payjoin sans serveur_ (voir [Newsletter #236][news236 spj]). En soi, [payjoin][topic payjoin] tel que spécifié dans
  [BIP78][] attend que le destinataire exploite un serveur pour accepter en toute sécurité des [PSBT][topic psbt] des payeurs.
  Gould propose un modèle de relais asynchrone qui commencerait par un destinataire utilisant une URI [BIP21][] pour déclarer
  le serveur de relais et la clé de chiffrement symétrique qu'il souhaite utiliser pour recevoir les paiements payjoin. Le
  payeur chiffrerait un PSBT de sa transaction et le soumettrait au relais souhaité par le destinataire. Le destinataire
  téléchargerait le PSBT, le déchiffrerait, y ajouterait une entrée signée, le chiffrerait et le soumettrait de nouveau au relais.
  Le payeur télécharge le PSBT révisé, le déchiffre, s'assure qu'il est correct, le signe et le diffuse sur le réseau Bitcoin.

    Dans une [réponse][gibson spj], Adam Gibson a mis en garde contre le danger d'inclure la clé de chiffrement dans l'URI BIP21
    et le risque pour la confidentialité du relais d'être en mesure de corréler les adresses IP du destinataire et du payeur
    avec l'ensemble des transactions diffusées dans une fenêtre de temps proche de la fin de leur session.
    Gould [a depuis révisé][gould spj2] la proposition dans le but de répondre aux préoccupations de Gibson concernant la clé
    de chiffrement.

    Nous nous attendons à voir une discussion continue sur le protocole.

## Rapport de terrain : Mise en œuvre de MuSig2

{% include articles/bitgo-musig2.md extrah="#" %}

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets
d'infrastructure Bitcoin. Veuillez envisager de passer aux nouvelles
versions ou d'aider à tester les versions candidates.*

- [Core Lightning 23.08rc2][] est un candidat à la prochaine version majeure de cette implémentation populaire de nœud LN.

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Interface de portefeuille matériel (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo], [Propositions d'amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo] et [Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #27213][] aide Bitcoin Core à établir et maintenir des connexions avec des pairs sur un ensemble de réseaux plus
  diversifié, réduisant ainsi le risque d'[attaques d'éclipse][topic eclipse attacks] dans certaines situations. Une attaque
  d'éclipse se produit lorsqu'un nœud est incapable de se connecter à un seul pair honnête, le laissant avec des pairs
  malhonnêtes qui peuvent lui donner un ensemble de blocs différent du reste du réseau. Cela peut être utilisé pour persuader
  le nœud que certaines transactions ont été confirmées même si le reste du réseau est en désaccord, trompant potentiellement
  l'opérateur du nœud en acceptant des bitcoins qu'il ne pourra jamais dépenser. Augmenter la diversité des connexions peut
  également aider à prévenir les partitions accidentelles du réseau où les pairs sur un petit réseau deviennent isolés du
  réseau principal et ne reçoivent donc pas les derniers blocs.

    La validation de la PR tente d'établir une connexion avec au moins un pair sur chaque réseau accessible et empêchera le
    seul pair sur un réseau d'être automatiquement expulsé.

- [Bitcoin Core #28008][] ajoute les routines de chiffrement et de déchiffrement prévues pour la mise en œuvre du [protocole
  de transport v2][topic v2 P2P transport] tel que spécifié dans [BIP324][]. Citant la PR, les chiffres et classes suivants
  sont ajoutés :

    - "Le AEAD ChaCha20Poly1305 de la section 2.8 de la RFC8439"

    - "Le chiffre de flux FSChaCha20 [Forward Secrecy] tel que spécifié dans BIP324, un enrobage de réaffectation autour
      de ChaCha20"

    - "Le AEAD FSChaCha20Poly1305 tel que spécifié dans BIP324, un enrobage de réaffectation autour de ChaCha20Poly1305"

    - "Une classe BIP324Cipher qui encapsule l'accord de clé, la dérivation de clé et les chiffres de flux et AEAD pour le
      codage des paquets BIP324"

- [LDK #2308][] permet à un dépensier d'inclure des enregistrements Tag-Length-Value (TLV) personnalisés dans leurs paiements,
  que les destinataires utilisant LDK ou une implémentation compatible peuvent maintenant extraire du paiement. Cela peut
  faciliter l'envoi de données personnalisées et de métadonnées avec un paiement.

{% include references.md %}
{% include linkers/issues.md v=2 issues="27213,28008,2308" %}
[todd expire]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021849.html
[gould spj]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021868.html
[spj bip]: https://github.com/bitcoin/bips/pull/1483
[gibson spj]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021872.html
[gould spj2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021880.html
[news236 spj]: /fr/newsletters/2023/02/01/#proposition-de-payjoin-sans-serveur
[core lightning 23.08rc2]: https://github.com/ElementsProject/lightning/releases/tag/v23.08rc2