---
title: 'Bulletin Hebdomadaire Optech Newsletter #267'
permalink: /fr/newsletters/2023/09/06/
name: 2023-09-06-newsletter-fr
slug: 2023-09-06-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Cette semaine, la newsletter s'intéresse à une nouvelle technique de compression des transactions Bitcoin et à une proposition de
co-signature améliorée pour la confidentialité des transactions. Elle inclut également nos sections régulières annonçant les
nouvelles versions de logiciels et les versions candidates, et décrivant les principaux changements apportés aux logiciels
d'infrastructure Bitcoin les plus répandus.

## Nouvelles

- **Compression des transactions Bitcoin :** Tom Briar a [publié][briar compress] sur la liste de diffusion Bitcoin-Dev une
  [spécification préliminaire][compress spec] et une [proposition d'implémentation][compress impl] de la compression des
  transactions Bitcoin. Les transactions plus petites seraient plus pratiques à relayer via des supports à bande passante limitée,
  tels que par satellite ou par stéganographie (par exemple, en encodant une transaction dans une image bitmap). Les algorithmes de
  compression traditionnels exploitent le fait que certains éléments de la plupart des données structurées sont plus
  fréquent que d'autres. Cependant, les transactions Bitcoin typiques sont principalement composées d'éléments
  uniformes---des données qui semblent aléatoires---comme des clés publiques et des hachages.

  La proposition de Briar aborde cette question en utilisant plusieurs approches :

  - Pour les parties d'une transaction où un entier est actuellement représenté par 4 octets (par exemple, la version de la
    transaction et l'index du point de sortie), ceux-ci sont remplacés par un entier de longueur variable pouvant être aussi
    petit que 2 bits.

  - Les 32 octets uniformément distribués du point de sortie txid dans chaque entrée sont remplacés par une référence à
    l'emplacement de cette transaction dans la chaîne de blocs en utilisant sa hauteur de bloc et son emplacement dans le bloc,
    par exemple `123456` et `789` indiqueraient la 789e transaction dans le bloc 123 456. Étant donné que le bloc à une hauteur
    particulière peut changer en raison d'une réorganisation de la chaîne de blocs (rompant la référence et rendant impossible
    la décompression de la transaction), cette méthode est utilisée uniquement lorsque la transaction référencée a au moins
    100 confirmations.

  - Pour les transactions P2WPKH où la structure du témoin doit inclure une signature ainsi qu'une clé publique de 33 octets,
    la clé publique est omise et une technique de reconstruction à partir de la signature est utilisée.

   D'autres techniques sont utilisées pour économiser quelques octets supplémentaires dans les transactions typiques.
   L'inconvénient général de la proposition est que la conversion d'une transaction compressée en quelque chose que les nœuds
   complets et autres logiciels peuvent utiliser nécessite plus de CPU, de mémoire et d'E/S que le traitement d'une transaction
   sérialisée régulière. Cela signifie que les connexions à haut débit continueront probablement d'utiliser le format de
   transaction régulier et seules les transmissions à faible bande passante utiliseront des transactions compressées.

   L'idée a suscité une quantité modérée de discussion, principalement autour de propositions visant à économiser une petite quantité
   d'espace supplémentaire par entrée.

- **Co-signature améliorée pour la confidentialité :** Nick Farrow a [publié][farrow cosign] sur la liste de diffusion Bitcoin-Dev
  des informations sur la façon dont un [schéma de signature seuil sans script][topic threshold signature] tel que [FROST][]
  pourrait améliorer la confidentialité des personnes qui utilisent des services de co-signature. Un utilisateur typique d'un
  service de co-signature dispose de plusieurs clés de signature stockées séparément pour des raisons de sécurité ; mais, pour
  simplifier les dépenses normales, ils autorisent également leurs sorties à être dépensées par une combinaison de certaines de
  leurs clés plus une ou plusieurs clés détenues par un ou plusieurs fournisseurs de services qui ne signent qu'après avoir
  authentifié l'utilisateur d'une certaine manière. L'utilisateur peut contourner le fournisseur de services si nécessaire, mais
  le fournisseur de services facilite les opérations dans la plupart des cas.

  Avec des schémas de signature seuil scriptés tels que 2-sur-3 `OP_CHECKMULTISIG`, la clé publique du service doit être
  associée à la sortie dépensée, de sorte que n'importe quel service puisse trouver les transactions qu'il a signée en
  examinant les données onchain, lui permettant d'accumuler des données sur ses utilisateurs. Pire encore, tous les protocoles
  actuellement utilisés que nous connaissons révèlent directement les transactions des utilisateurs au fournisseur de services
  avant la signature, permettant au service de refuser de signer certaines transactions.

  Comme le décrit Farrow, FROST permet de masquer la transaction signée au service à chaque étape du processus, de la
  génération d'un script de sortie, à la signature, à la publication de la transaction entièrement signée. Tout ce que le
  service saura, c'est quand il a signé et toutes les données que l'utilisateur a fournies pour s'authentifier auprès du
  service.

  L'idée a fait l'objet de discussions sur la liste de diffusion.

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets
d'infrastructure Bitcoin. Veuillez envisager de passer aux nouvelles
versions ou d'aider à tester les versions candidates.*

- [Libsecp256k1 0.4.0][] est la dernière version de cette bibliothèque pour les opérations cryptographiques liées à Bitcoin.
  La nouvelle version comprend un module avec une implémentation du codage ElligatorSwift ; consultez le [journal des
  modifications][libsecp cl] du projet pour plus d'informations.

- [LND v0.17.0-beta.rc2][] est un candidat à la version majeure suivante de cette implémentation populaire de nœud LN.
  Une nouvelle fonctionnalité expérimentale majeure prévue pour cette version, qui pourrait bénéficier de tests, est la prise
  en charge des "canaux taproot simples".

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo],
[Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel
(HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo],
[Propositions d'Amélioration de Bitcoin (BIPs)][bips repo], [BOLTs Lightning][bolts repo], et
[Inquisition Bitcoin][bitcoin inquisition repo].*

- [Bitcoin Core #28354][] modifie la valeur par défaut de `-acceptnonstdtxn` à 0 sur le testnet, ce qui est la valeur par défaut
  sur tous les autres réseaux. Ce changement peut aider les applications à éviter de créer des transactions non standard et donc
  rejetées par les nœuds par défaut sur le mainnet.

- [LDK #2468][] permet aux utilisateurs de fournir un `payment_id` qui est chiffré dans le champ de métadonnées d'une demande
  de facture. LDK vérifie les métadonnées des factures reçues et ne paiera que s'il reconnaît l'identifiant et n'a pas déjà payé
  une autre facture pour celui-ci.
  Ce PR fait partie du [travail de LDK][ldk bolt12] visant à mettre en œuvre [BOLT12][topic offers].

{% include references.md %}
{% include linkers/issues.md v=2 issues="28354,2468" %}
[LND v0.17.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.0-beta.rc2[briar compress]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021924.html
[compress spec]: https://github.com/TomBriar/bitcoin/blob/2023-05--tx-compression/doc/compressed_transactions.md
[compress impl]: https://github.com/TomBriar/bitcoin/pull/3
[farrow cosign]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021917.html
[frost]: https://eprint.iacr.org/2020/852
[libsecp cl]: https://github.com/bitcoin-core/secp256k1/blob/master/CHANGELOG.md
[libsecp256k1 0.4.0]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.4.0
[ldk bolt12]: https://github.com/lightningdevkit/rust-lightning/issues/1970

[LND v0.17.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.0-beta.rc2
[briar compress]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021924.html
[compress spec]: https://github.com/TomBriar/bitcoin/blob/2023-05--tx-compression/doc/compressed_transactions.md
[compress impl]: https://github.com/TomBriar/bitcoin/pull/3
[farrow cosign]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021917.html
[frost]: https://eprint.iacr.org/2020/852
[libsecp cl]: https://github.com/bitcoin-core/secp256k1/blob/master/CHANGELOG.md
[libsecp256k1 0.4.0]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.4.0
[ldk bolt12]: https://github.com/lightningdevkit/rust-lightning/issues/1970
