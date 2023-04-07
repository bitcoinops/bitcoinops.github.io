---
title: 'Bulletin Hebdomadaire Bitcoin Optech #245'
permalink: /fr/newsletters/2023/04/05/
name: 2023-04-05-newsletter-fr
slug: 2023-04-05-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume une idée pour les preuves de responsabilité
des tours de contrôle et comprend nos sections habituelles avec des annonces de nouvelles
versions et de candidats à la publication, ainsi que des descriptions des principaux
changements apportés aux logiciels d'infrastructure Bitcoin les plus répandus.

## Nouvelles

- **Preuves de responsabilité de la tour de contrôle :** Sergi Delgado Segura a
  [posté][segura watchtowers post] sur la liste de diffusion Lightning-Dev
  la semaine dernière pour demander des comptes aux [tours de contrôle][topic watchtowers]
  qui n'ont pas réagi à des violations de protocole qu'ils étaient capables
  de détecter. Par exemple, Alice fournit à une tour de contrôle des données pour
  détecter et répondre à la confirmation d'un ancien état du canal LN;
  plus tard, cet état est confirmé mais la tour de contrôle ne répond pas. Alice
  aimerait pouvoir tenir l'opérateur de la tour de contrôle pour responsable en
  prouvant publiquement qu'il n'a pas réagi de manière appropriée.

    Le principe de base serait qu'une tour de contrôle dispose d'une clé publique
    bien connue et qu'elle utilise la clé privée correspondante pour générer
    une signature pour toutes les données de détection d'infraction qu'elle
    accepte. Alice pourrait alors publier les données et la signature après
    une infraction non résolue pour prouver que la tour de contrôle a failli à sa
    responsabilité. Toutefois, Delgado a fait remarquer que la responsabilité
    pratique n'est pas aussi simple :

    - *Exigences de stockage des données :* le mécanisme ci-dessus nécessiterait
      qu'Alice stocke une signature supplémentaire chaque fois qu'elle envoie à
      la tour de guet de nouvelles données de détection de violation, ce qui peut
      être très fréquent pour un canal LN actif.

    - *Pas de possibilité de suppression :* le mécanisme ci-dessus nécessite
      potentiellement à la tour de contrôle de stocker les données de détection
      de violation à perpétuité. Les tours de contrôle peuvent ne vouloir stocker
      des données que pour une période limitée, par exemple, elles peuvent accepter
      un paiement pour une période particulière.


    Delgado suggère que les accumulateurs cryptographiques offrent une solution pratique
    à ces deux problèmes. Les accumulateurs permettent de prouver de manière compacte
    qu'un élément particulier fait partie d'un grand ensemble d'éléments et permettent
    également d'ajouter de nouveaux éléments à l'ensemble sans reconstruire toute la
    structure de données. Certains accumulateurs permettent de supprimer des éléments
    de l'ensemble sans reconstruire.  Dans un [gist][segura watchtowers gist], Delgado
    décrit plusieurs constructions d'accumulateurs différentes à considérer.

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets d’infrastructure
Bitcoin. Veuillez envisager de passer aux nouvelles versions ou d’aider à tester
les versions candidates.*

- [LND v0.16.0-beta][] est une nouvelle version majeure de cette implémentation populaire
  de Lightning Network. Ces [notes de version][lnd rn] mentionnent de nombreuses nouvelles
  fonctionnalités, corrections de bogues et améliorations des performances.

- [BDK 1.0.0-alpha.0][] est une version de test des principaux changements apportés à BDK
  décrits dans le [Bulletin #243][news243 bdk]. Les développeurs de projets dérivés sont
  encouragés à commencer les tests d'intégration.

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], et
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Core Lightning #5967][] ajoute un RPC `listclosedchannels` qui fournit des données sur
  les canaux fermés du nœud, y compris la cause de la fermeture du canal. Les informations
  sur les anciens pairs sont également conservées maintenant.

- [Eclair #2566][] ajoute le support pour accepter des offres. Les offres doivent être
  enregistrées par un plugin qui fournit un gestionnaire pour répondre aux demandes de
  facturation liées à l'offre et accepter ou rejeter les paiements à cette facture. Eclair
  s'assure que les demandes et les paiements respectent les exigences du protocole---le
  gestionnaire n'a qu'à décider si l'article ou le service acheté peut être fourni. Cela
  permet au code pour la maréchalerie (transformation de données structurées d'un format
  à l'autre) des offres de devenir arbitrairement complexe sans affecter la logique
  interne d'Eclair.

- [LDK #2062][] implemente [BOLTs #1031][] (voir le [Bulletin
  #226][news226 bolts1031]), [#1032][bolts #1032] (voir le  [Bulletin
  #225][news225 bolts1032]), et [#1040][bolts #1040], autorise
  l'identification du destinataire ultime d'un paiement ([HTLC][topic
  htlc]) d'accepter un montant plus élevé que celui qu'ils ont demandé
  et avec un délai d'expiration plus long que celui qu'ils ont demandé.
  Il est donc plus difficile pour un nœud de transfert d'utiliser une
  légère modification des paramètres du paiement pour déterminer que le
  prochain saut est le destinataire. Le PR fusionné permet également à un
  émetteur de payer à un destinataire un montant légèrement supérieur à
  celui demandé lors de l'utilisation de [paiements simplifiés par trajets
  multiples][topic multipath payments]. Cela présente l'avantage
  susmentionné et peut également s'avérer nécessaire dans le cas où les
  voies de paiement choisies utilisent des canaux avec un montant minimum
  acheminable. Par exemple, Alice souhaite diviser un total de 900 sat en
  deux parties, mais les deux chemins qu'elle choisit exigent des montants
  minimums de 500 sat. Avec ce changement de spécification, elle peut
  maintenant envoyer deux paiements de 500 sat, en choisissant de surpayer
  d'un total de 100 sat afin d'utiliser la voie qu'elle préfère.

- [LDK #2125][] ajoute des fonctions d'aide pour déterminer le délai
  d'expiration d'une facture.

- [BTCPay Server #4826][] permet aux services accrocheurs de créer et de
  récupérer des factures [LNURL][]. Ceci a été fait pour ajouter la prise
  en charge des zaps NIP-57 aux fonctions d'adresse éclair de BTCPay Server.

- [BTCPay Server #4782][] ajoute la [preuve de paiement][topic proof of payment]
  sur la page de réception de chaque paiement. Pour les paiements onchain,
  la preuve est l'ID de la transaction. Pour les paiements LN, la preuve
  est la pré-image du [HTLC][topic htlc].

- [BTCPay Server #4799][] ajoute la possibilité d'exporter des [étiquettes
  de portefeuilles][topic wallet labels] pour les transactions dans le format
  spécifié par [BIP329][]. Les prochains PR pourront ajouter la possibilité
  d'exporter d'autres données de portefeuille, telles que les étiquettes d'adresses.

- [BOLTs #765][] ajoute la [dissimulation d'itinéraire][topic rv routing]
  à la spécification LN. La dissimulation d'itinéraire, que nous avons décrite
  pour la première fois dans le [Bulletin #85][news85 blinding], permet à un
  nœud de recevoir un paiement ou un [message oignon][topic onion messages]
  sans révéler son identifiant de nœud à l'auteur ou à l'expéditeur du paiement
  ou du message. Aucune autre information directement identifiable ne doit être
  révélée. La dissimulation d'itinéraire permet au destinataire de choisir les
  derniers sauts par lesquels le paiement ou le message sera acheminé. Ces étapes
  sont cryptées en oignon comme les informations d'acheminement habituelles et
  sont fournies à l'auteur ou à l'expéditeur qui les utilise pour envoyer un
  paiement au premier des sauts. Ce dernier entame le processus de décryptage
  du saut suivant, lui transmet le paiement, lui demande de décrypter le saut
  suivant, etc., jusqu'à ce que le destinataire accepte le paiement sans que
  son nœud ne soit divulgué à l'auteur ou à l'expéditeur du message.

{% include references.md %}
{% include linkers/issues.md v=2 issues="5967,2566,2062,1031,1032,1040,2125,4826,4782,4799,765" %}
[lnd v0.16.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.0-beta
[bdk 1.0.0-alpha.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-alpha.0
[segura watchtowers post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-March/003892.html
[segura watchtowers gist]: https://gist.github.com/sr-gi/f91f007fc8d871ea96ead9b27feec3d5
[news85 blinding]: /en/newsletters/2020/02/19/#decoy-nodes-and-lightweight-rendez-vous-routing
[news226 bolts1031]: /fr/newsletters/2022/11/16/#bolts-1031
[news225 bolts1032]: /fr/newsletters/2022/11/09/#bolts-1032
[news243 bdk]: /fr/newsletters/2023/03/22/#bdk-793
[lnd rn]: https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/release-notes-0.16.0.md
[lnurl]: https://github.com/lnurl/luds
