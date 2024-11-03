---
title: 'Bulletin Hebdomadaire Optech #278'
permalink: /fr/newsletters/2023/11/22/
name: 2023-11-22-newsletter-fr
slug: 2023-11-22-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---

Le bulletin de cette semaine décrit une proposition visant à permettre la récupération des offres LN en utilisant des adresses DNS
spécifiques similaires aux adresses lightning. Nous incluons également nos sections régulières
décrivant les mises à jour des clients et des services, les nouvelles versions et les versions candidates, ainsi que les changements
apportés aux principaux logiciels d'infrastructure Bitcoin.


## Nouvelles

- **Adresses LN compatibles avec les offres :** Bastien Teinturier a publié un message sur la liste de diffusion Lightning-Dev concernant
  la création d'adresses de style e-mail pour les utilisateurs LN de manière à tirer parti des fonctionnalités du protocole des offres.
  Pour contextualiser, il existe une norme populaire d'adresse lightning basée sur LNURL, qui nécessite de faire fonctionner en
  permanence un serveur HTTP pour associer des adresses de style e-mail à des factures LN. Teinturier note que cela crée plusieurs
  problèmes :

  - _Manque de confidentialité :_ l'opérateur du serveur peut probablement connaître l'adresse IP de l'émetteur et du destinataire.

  - _Risque de vol :_ l'opérateur du serveur peut effectuer une attaque de type "man-in-the-middle" sur les factures pour voler
    des fonds.

  - _Infrastructure et dépendances :_ l'opérateur du serveur doit configurer le DNS et l'hébergement HTTPS, et le logiciel de
    l'émetteur doit pouvoir utiliser le DNS et le HTTPS.

  Teinturier propose trois conceptions basées sur les offres :

  - _Lier les domaines aux nœuds :_ un enregistrement DNS associe un domaine (par exemple, example.com) à un identifiant de nœud LN.
    L'émetteur envoie un message [onion][topic onion messages] à ce nœud pour demander une offre pour le destinataire final (par
    exemple, alice@example.com). Le nœud du domaine répond avec une offre signée par sa clé de nœud, permettant à l'émetteur de
    prouver ultérieurement une fraude s'il a fourni une offre qui ne provenait pas d'Alice. L'émetteur peut maintenant utiliser le
    protocole des offres pour demander une facture à Alice. L'émetteur peut également associer alice@example.com à l'offre, de sorte
    qu'il n'ait pas besoin de contacter le nœud du domaine pour les paiements futurs à Alice. Teinturier note que cette conception
    est extrêmement simple.

  - _Certificats dans les annonces de nœuds :_ le mécanisme existant qu'un nœud LN utilise pour se faire connaître du réseau est
    modifié pour permettre à une annonce de contenir une chaîne de certificats SSL prouvant que (selon une autorité de certification)
    le propriétaire de example.com affirme que ce nœud particulier est contrôlé par alice@example.com. Teinturier note que cela
    nécessiterait que les implémentations LN utilisent une cryptographie compatible avec SSL.

  - _Stocker les offres directement dans le DNS :_ un domaine peut avoir plusieurs enregistrements DNS qui stockent directement des
    offres pour des adresses particulières. Par exemple, un enregistrement DNS `TXT`, `alice._lnaddress.domain.com`, inclut une offre
    pour Alice. Un autre enregistrement, `bob._lnaddress.domain.com`, inclut une offre pour Bob. Teinturier note que cela nécessite
    que le propriétaire du domaine crée un enregistrement DNS par utilisateur (et mette à jour cet enregistrement si l'utilisateur
    doit modifier son offre par défaut).

  Le message a suscité une discussion active. Une suggestion notable était de permettre éventuellement l'utilisation à la fois de la
  première et de la troisième suggestion (les suggestions pour lier les domaines aux nœuds et stocker les offres directement dans le
  DNS).

## Modifications apportées aux services et aux logiciels clients

*Dans cette rubrique mensuelle, nous mettons en évidence les mises à jour
intéressantes des portefeuilles et services Bitcoin.*

- **Sortie de BitMask Wallet 0.6.3 :**
  [BitMask][bitmask website] est un portefeuille basé sur le web et une extension de navigateur pour Bitcoin,
  Lightning, RGB et [payjoin][topic payjoin].

- **Annonce du site de documentation des opcodes :**
  Le site [https://opcodeexplained.com/] a récemment été [annoncé][OE tweet]
  et fournit des explications sur de nombreux opcodes de Bitcoin. L'effort est en cours
  et [les contributions sont les bienvenues][OE github].

- **Athena Bitcoin ajoute la prise en charge de Lightning :**
  L'opérateur de distributeur automatique de Bitcoin [a récemment annoncé][athena tweet]
  la prise en charge des paiements Lightning pour les retraits en espèces.

- **Sortie de Blixt v0.6.9 :**
  La version [v0.6.9][blixt v0.6.9] inclut la prise en charge de canaux taproot simples,
  utilise par défaut des adresses de réception [bech32m][topic bech32] et ajoute
  une prise en charge supplémentaire des [canaux zero conf][topic zero-conf channels].

- **Annonce du livre blanc Durabit :**
  Le [livre blanc Durabit][] décrit un protocole utilisant des transactions Bitcoin [timelocked][topic
  timelocks] en conjonction avec une création de monnaie de style chaumien
  pour inciter à la diffusion de gros fichiers.

- **Annonce du livre blanc BitStream :**
  Le [livre blanc BitStream][] présente un [prototype préliminaire][bitstream github]
  de protocole pour l'hébergement et l'échange atomique de contenu numérique contre
  des satoshis en utilisant des verrous temporels et des arbres de Merkle avec vérification et preuves
  de fraude. Pour une discussion antérieure sur les protocoles de transfert de données payantes, voir
  [Newsletter #53][news53 data].

- **Preuves de concept BitVM :**
  Deux preuves de concept basées sur [BitVM][news273 bitvm] ont été publiées, dont
  une [implémente][bitvm tweet blake3] la fonction de hachage [BLAKE3][] et
  [une autre][bitvm techmix poc] qui [implémente][bitvm sha256] SHA256.

- **Bitkit ajoute la prise en charge de l'envoi taproot :**
  [Bitkit][bitkit website], un portefeuille Bitcoin et Lightning mobile, a ajouté
  la prise en charge de l'envoi [taproot][topic taproot] dans la version [v1.0.0-beta.86][bitkit
  v1.0.0-beta.86].

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets d’infrastructure
Bitcoin. Veuillez envisager de passer aux nouvelles versions ou d’aider à tester
les versions candidates.*

- [LND v0.17.2-beta][] est une version de maintenance qui ne comprend qu'un
  petit changement pour corriger le bogue signalé dans [LND #8186][].

- [Bitcoin Core 26.0rc2][] est une version candidate pour la prochaine version majeure
  de l'implémentation principale du nœud complet. Il y a un [guide test en cours][26.0 testing] disponible.

- [Core Lightning 23.11rc3][] est une version candidate pour la prochaine
  version majeure de cette implémentation de nœud LN.

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Interface de portefeuille
matériel (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [Serveur BTCPay
][btcpay server repo], [BDK][bdk repo], [Propositions d'amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo], et
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Core Lightning #6857][] met à jour les noms de plusieurs options de configuration
  utilisées pour l'interface REST afin d'éviter les conflits
  avec le plugin [c-lightning-rest][].

- [Eclair #2752][] permet aux données dans une [offre][topic offers] de faire référence
  à un nœud en utilisant soit sa clé publique, soit l'identité de l'un de ses
  canaux. Une clé publique est le moyen habituel d'identifier un nœud, mais elle
  utilise 33 octets. Un canal peut être identifié à l'aide d'un [BOLT7][] _short
  channel identifier_ (SCID), qui n'utilise que 8 octets. Étant donné que les canaux
  sont partagés par deux nœuds, un bit supplémentaire est ajouté au SCID pour
  identifier spécifiquement l'un des deux nœuds. Comme les offres sont souvent
  utilisées dans des médias à contraintes de taille, les économies d'espace sont toujours intéressantes.

{% include snippets/recap-ad.md when="2023-11-22 15:00" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="6857,2752,8186" %}
[bitcoin core 26.0rc2]: https://bitcoincore.org/bin/bitcoin-core-26.0/
[26.0 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/26.0-Release-Candidate-Testing-Guide
[core lightning 23.11rc3]: https://github.com/ElementsProject/lightning/releases/tag/v23.11rc3
[c-lightning-rest]: https://github.com/Ride-The-Lightning/c-lightning-REST
[teinturier addy]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-November/004204.html
[lnurl]: https://github.com/fiatjaf/lnurl-rfc
[lightning address]: https://lightningaddress.com/
[lnd v0.17.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.2-beta
[bitmask website]: https://bitmask.app/
[https://opcodeexplained.com/]: https://opcodeexplained.com/opcodes/
[OE tweet]: https://twitter.com/thunderB__/status/1722301073585475712
[OE github]: https://github.com/thunderbiscuit/opcode-explained
[athena website]: https://athenabitcoin.com/
[athena tweet]: https://twitter.com/btc_penguin/status/1722008223777964375
[blixt v0.6.9]: https://github.com/hsjoberg/blixt-wallet/releases/tag/v0.6.9
[livre blanc Durabit]: https://github.com/4de67a207019fd4d855ef0a188b4519c/Durabit/blob/main/Durabit%20-%20A%20Bitcoin-native%20Incentive%20Mechanism%20for%20Data%20Distribution.pdf
[livre blanc BitStream]: https://robinlinus.com/bitstream.pdf
[bitstream github]: https://github.com/robinlinus/bitstream
[news273 bitvm]: /fr/newsletters/2023/10/18/#paiements-conditionnels-a-une-computation-arbitraire
[bitvm tweet blake3]: https://twitter.com/robin_linus/status/1721969594686926935
[BLAKE3]: https://fr.wikipedia.org/wiki/BLAKE_(fonction_de_hachage)#BLAKE3
[bitvm techmix poc]: https://techmix.github.io/tapleaf-circuits/
[bitvm sha256]: https://raw.githubusercontent.com/TechMiX/tapleaf-circuits/abc38e880872150ceec08a8b67ac2fddaddd06dc/scripts/circuits/bristol_sha256.js
[bitkit website]: https://bitkit.to/
[bitkit v1.0.0-beta.86]: https://github.com/synonymdev/bitkit/releases/tag/v1.0.0-beta.86
[news53 data]: /en/newsletters/2019/07/03/#standardized-atomic-data-delivery-following-ln-payments
