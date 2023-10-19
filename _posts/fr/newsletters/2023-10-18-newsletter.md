---
tittle: 'Bulletin Hebdomadaire Bitcoin Optech #273'
permalink: /fr/newsletters/2023/10/18/
name: 2023-10-18-newsletter-fr
slug: 2023-10-18-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine mentionne brièvement une récente divulgation de sécurité affectant les utilisateurs de LN, décrit un
article sur la réalisation de paiements conditionnels au résultat de l'exécution de programmes arbitraires, et annonce une proposition
de BIP visant à ajouter des champs aux PSBT pour MuSig2. Sont également incluses nos sections régulières avec
des annonces de mises à jour et versions candidates, ainsi que les changements apportés aux principaux logiciels
d'infrastructure Bitcoin.

## Nouvelles

- **Divulgation de sécurité concernant LN :** Antoine Riard a [publié][riard cve] sur les listes de diffusion Bitcoin-Dev et
  Lightning-Dev la divulgation complète d'un problème qu'il avait précédemment [signalé de manière responsable][topic responsible
  disclosures] aux développeurs travaillant sur le protocole Bitcoin et diverses implémentations LN populaires. Les versions les plus
  récentes de Core Lightning, Eclair, LDK et LND contiennent toutes des mesures d'atténuation qui rendent l'attaque moins pratique,
  bien qu'elles n'éliminent pas la préoccupation sous-jacente.

    La divulgation a été faite après la date limite habituelle des actualités d'Optech, nous ne pouvons donc fournir que le lien
    ci-dessus dans la newsletter de cette semaine. Nous fournirons un résumé régulier dans la newsletter de la semaine prochaine.
    {% assign timestamp="1:09" %}

- **Paiements conditionnels à une computation arbitraire :** Robin Linus a [publié][linus post] sur la liste de diffusion Bitcoin-Dev
  un [article][linus paper] qu'il a écrit sur _BitVM_, une combinaison de méthodes qui permet de payer des bitcoins à quelqu'un qui
  prouve avec succès qu'un programme arbitraire s'est exécuté correctement. Notamment, cela est possible sur Bitcoin aujourd'hui,
  aucun changement de consensus n'est requis.

    Pour fournir un contexte, une caractéristique bien connue de Bitcoin est d'exiger que quelqu'un satisfasse une expression de
    programmation (appelée _script_) afin de dépenser des bitcoins associés à ce script. Par exemple, un script contenant une clé
    publique qui ne peut être satisfaite que si la clé privée correspondante crée une signature s'engageant à une transaction de
    dépense. Les scripts doivent être écrits dans le langage de Bitcoin (appelé _Script_) pour être appliqués par consensus, mais
    Script est délibérément limité dans sa flexibilité.

    L'article de Linus contourne certaines de ces limites. Si Alice fait confiance à Bob pour agir si un programme est exécuté de
    manière incorrecte, mais ne veut pas lui faire confiance pour autre chose, elle peut payer des fonds à un [taproot][topic
    taproot] qui permettra à Bob de réclamer les fonds s'il démontre qu'Alice n'a pas exécuté correctement un programme arbitraire.
    Si Alice exécute correctement le programme, elle peut dépenser les fonds même si Bob tente de l'en empêcher.

    Pour utiliser un programme arbitraire, il doit être décomposé en une primitive très basique (une [porte NAND][]) et un engagement
    doit être fait pour chaque porte. Cela nécessite l'échange hors chaîne d'une très grande quantité de données, potentiellement
    plusieurs gigaoctets même pour un programme arbitraire assez basique, mais Alice et Bob n'ont besoin que d'une seule transaction
    sur chaîne dans le cas où Bob reconnaît qu'Alice a exécuté correctement le programme. Dans le cas où Bob n'est pas d'accord,
    il devrait être en mesure de démontrer l'échec d'Alice dans un nombre relativement restreint de transactions onchain. Si la
    configuration a été effectuée dans un canal de paiement entre Alice et Bob, plusieurs programmes peuvent être exécutés à la fois
    en parallèle et en séquence sans aucune trace onchain, à l'exception de la configuration du canal et d'une fermeture mutuelle ou
    forcée où Bob tente de démontrer qu'Alice n'a pas suivi correctement la logique du programme arbitraire.

    BitVM peut être appliqué de manière fiable dans des cas où Alice et Bob sont des adversaires naturels, par exemple lorsqu'ils paient
    des fonds à une sortie qui sera payée à celui d'entre eux qui gagne à un jeu d'échecs. Ils peuvent ensuite utiliser deux programmes
    arbitraires (presque identiques), chacun prenant le même ensemble arbitraire de coups d'échecs. Un programme renverra vrai si Alice
    a gagné et l'autre renverra vrai si Bob a gagné. Une partie publiera ensuite onchain la transaction qui affirme que son programme
    s'évalue à vrai (qu'elle a gagné) ; l'autre partie acceptera cette affirmation (reconnaissant la perte des fonds) ou démontrera la
    fraude (recevant les fonds en cas de succès). Dans les cas où Alice et Bob ne seraient pas naturellement des adversaires, Alice peut
    être en mesure de l'inciter à vérifier le calcul correct, par exemple en lui offrant ses fonds si Bob peut prouver qu'elle a échoué
    à calculer correctement.

    L'idée a fait l'objet d'un nombre important de discussions sur la liste de diffusion ainsi que sur Twitter et divers podcasts axés
    sur Bitcoin. Nous prévoyons des discussions continues dans les semaines et les mois à venir. {% assign timestamp="8:15" %}

- **Proposition de BIP pour les champs MuSig2 dans les PSBT :** Andrew Chow [a posté][chow mpsbt] sur la liste de diffusion Bitcoin-Dev
  avec un [projet de BIP][mpsbt-bip], en partie basé sur [un travail antérieur][kanjalkar mpsbt] de Sanket Kanjalkar, pour ajouter
  plusieurs champs à toutes les versions des [PSBT][topic psbt] pour les "clés, les nonces publiques et les signatures partielles
  produites avec [MuSig2][topic musig]".

    Anthony Towns [a demandé][towns mpsbt] si le BIP proposé inclurait également des champs pour les [signatures adaptatives][topic
    adaptor signatures], mais les discussions ultérieures ont indiqué que cela devrait probablement être défini dans un BIP séparé.
    {% assign timestamp="26:44" %}

## Modifications apportées aux services et aux logiciels clients

*Dans cette rubrique mensuelle, nous mettons en évidence les mises à jour
intéressantes des portefeuilles et services Bitcoin.*

- **Sortie de la bibliothèque Python BIP-329 :**
  La [bibliothèque Python BIP-329][] est un ensemble d'outils qui peuvent lire, écrire, chiffrer et déchiffrer des fichiers d'étiquettes
  de portefeuille conformes à [BIP329][]. {% assign timestamp="29:10" %}

- **Annonce de l'outil de test LN Doppler :**
  Récemment [annoncé][doppler announced], [Doppler][] prend en charge la définition de topologies de nœuds Bitcoin et Lightning et
  l'activité de paiement onchain/offchain à l'aide d'un langage spécifique au domaine (DSL) pour tester les implémentations LND, CLN
  et Eclair ensemble. {% assign timestamp="30:19" %}

- **Sortie de Coldcard Mk4 v5.2.0 :**
  Les mises à jour du firmware [incluent][coldcard blog] le support de [BIP370][] pour la version 2 [PSBTs][topic psbt], support
  supplémentaire [BIP39][] et capacités de plusieurs semences. {% assign timestamp="31:54" %}

- **Circuits Tapleaf : une démo de BitVM :**
  [Circuits Tapleaf][] est une implémentation de concept de preuve de circuits Bristol
  utilisant l'approche BitVM décrite précédemment dans le bulletin. {% assign timestamp="32:27" %}

- **Samourai Wallet 0.99.98i publié :**
  La version [0.99.98i][samourai blog] inclut des fonctionnalités supplémentaires de PSBT, d'étiquetage des UTXO
  et d'envoi en lot. {% assign timestamp="34:24" %}

- **Krux : firmware de dispositif de signature :**
  [Krux][krux github] est un projet de firmware open-source pour construire des dispositifs de signature matériels
  en utilisant du matériel courant. {% assign timestamp="35:12" %}

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets
d'infrastructure Bitcoin. Veuillez envisager de passer aux nouvelles
versions ou d'aider à tester les versions candidates.*

- [Bitcoin Core 24.2rc2][] et [Bitcoin Core 25.1rc1][] sont des candidats à la version
  pour les versions de maintenance de Bitcoin Core. {% assign timestamp="36:06" %}

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille
Matériel (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [Serveur BTCPay
][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo], et
[Inquisition Bitcoin][bitcoin inquisition repo].*

- [Bitcoin Core #27255][] porte [miniscript][topic miniscript] vers [tapscript][topic tapscript]. Ce changement de code rend
  miniscript une option pour les [descripteurs de sortie][topic descriptors] P2TR, ajoutant la prise en charge à la fois
  de la surveillance et de la signature des "descripteurs TapMiniscript". Auparavant, miniscript était
  disponible uniquement pour les descripteurs de sortie P2WSH. L'auteur note qu'un nouveau
  fragment `multi_a` est introduit exclusivement pour les descripteurs P2TR qui
  correspond à la sémantique de `multi` dans les descripteurs P2WSH. La discussion sur le
  PR note qu'une grande partie du travail a été consacrée au suivi approprié des
  limites de ressources modifiées pour tapscript. {% assign timestamp="38:07" %}

- [Eclair #2703][] décourage les dépensiers de faire transiter les paiements par
  le nœud local lorsque le solde du nœud est faible et qu'il serait probablement
  nécessaire de rejeter ces paiements. Cela est réalisé en annonçant que le montant HTLC maximum du nœud a été réduit.
  Éviter les paiements rejetés améliore l'expérience des dépensiers et aide à éviter
  que le nœud local ne soit pénalisé par les systèmes de recherche de chemin qui rabaissent
  les nœuds qui n'ont pas réussi à faire transiter un paiement récemment. {% assign timestamp="45:54" %}

- [LND #7267][] rend possible la création de routes vers des
  chemins [aveugles][topic rv routing], rapprochant ainsi LND d'une prise en charge complète
  des paiements aveugles. {% assign timestamp="47:06" %}

- [BDK #1041][] ajoute un module pour obtenir des données sur la chaîne de blocs à partir de Bitcoin Core en utilisant l'interface
  RPC de ce programme. {% assign timestamp="47:39" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="27255,2703,7267,1041" %}
[linus post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/021984.html
[linus paper]: https://bitvm.org/bitvm.pdf
[porte nand]: https://en.wikipedia.org/wiki/NAND_gate
[Bitcoin Core 24.2rc2]: https://bitcoincore.org/bin/bitcoin-core-24.2/
[Bitcoin Core 25.1rc1]: https://bitcoincore.org/bin/bitcoin-core-25.1/
[riard cve]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/021999.html
[mpsbt-bip]: https://github.com/achow101/bips/blob/musig2-psbt/bip-musig2-psbt.mediawiki
[kanjalkar mpsbt]: https://gist.github.com/sanket1729/4b525c6049f4d9e034d27368c49f28a6
[chow mpsbt]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/021988.html
[towns mpsbt]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/021991.html
[bibliothèque Python BIP-329]: https://github.com/Labelbase/python-bip329
[Doppler]: https://github.com/tee8z/doppler
[doppler announced]: https://twitter.com/voltage_cloud/status/1712171748144070863
[coldcard blog]: https://blog.coinkite.com/5.2.0-seed-vault/
[Tapleaf circuits]: https://github.com/supertestnet/tapleaf-circuits
[samourai blog]: https://blog.samourai.is/wallet-update-0-99-98i/
[krux github]: https://github.com/selfcustody/krux