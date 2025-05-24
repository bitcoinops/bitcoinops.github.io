---
title: 'Bulletin Hebdomadaire Bitcoin Optech #353'
permalink: /fr/newsletters/2025/05/09/
name: 2025-05-09-newsletter-fr
slug: 2025-05-09-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit une vulnérabilité théorique de défaillance de consensus
récemment découverte et renvoie à une proposition pour éviter la réutilisation des chemins de
portefeuille BIP32. Sont également incluses nos sections régulières résumant une
réunion du Bitcoin Core PR Review Club, annonçant des mises à jour et des versions candidates,
et décrivant les changements notables dans les projets d'infrastructure Bitcoin populaires.

## Nouvelles

- **Vulnérabilité de défaillance de consensus BIP30 :** Ruben Somsen a [posté][somsen bip30] sur la
  liste de diffusion Bitcoin-Dev à propos d'une défaillance de consensus théorique qui pourrait
  survenir maintenant que les points de contrôle ont été retirés de Bitcoin Core (voir le [Bulletin
  #346][news346 checkpoints]). En bref, les transactions coinbase des blocs 91722 et 91812 sont
  [dupliquées][topic duplicate transactions] dans les blocs 91880 et 91842. [BIP30][] spécifie que ces
  deux derniers blocs devraient être traités de la manière dont la version historique de Bitcoin Core
  les a traités en 2010, c'est-à-dire en écrasant les entrées coinbase antérieures dans l'ensemble
  UTXO avec les duplicatas ultérieurs. Cependant, Somsen note qu'un réordonnancement de l'un ou des
  deux blocs ultérieurs résulterait dans le retrait de l'entrée dupliquée (ou des entrées) de
  l'ensemble UTXO, le laissant également dépourvu des entrées antérieures en raison de l'écrasement.
  Mais, un nœud nouvellement démarré qui n'a jamais vu les transactions dupliquées aurait toujours les
  transactions antérieures, lui donnant un ensemble UTXO différent qui pourrait entraîner une
  défaillance de consensus si l'une des deux transactions est dépensée.

  Ce n'était pas un problème lorsque Bitcoin Core avait des points de contrôle car ils exigeaient que
  les quatre blocs mentionnés ci-dessus fassent partie de la meilleure blockchain. Ce n'est pas
  vraiment un problème maintenant, sauf dans un cas théorique où le mécanisme de sécurité de preuve de
  travail de Bitcoin se brise. Plusieurs solutions possibles ont été discutées, telles que coder en
  dur une logique de cas spéciaux supplémentaires pour ces deux exceptions.

- **Éviter la réutilisation du chemin BIP32 :** Kevin Loaec a [posté][loaec bip32reuse] sur Delving
  Bitcoin pour discuter des options permettant d'éviter que le même chemin de portefeuille
  [BIP32][topic bip32] soit utilisé avec différents portefeuilles, ce qui pourrait conduire à une
  perte de confidentialité en raison du [lien de sortie][topic output linking] et une perte théorique
  de sécurité (par exemple, en raison de [l'informatique quantique][topic quantum resistance]). Il a
  suggéré trois approches possibles : utiliser un chemin aléatoire, utiliser un chemin basé sur la
  date de création du portefeuille, et utiliser un chemin basé sur un compteur incrémentiel. Il a
  recommandé l'approche basée sur la date de création.

  Il a également recommandé d'abandonner la plupart des éléments de chemin [BIP48][] comme inutiles en
  raison de l'utilisation de plus en plus répandue des portefeuilles avec des [descripteurs][topic
  descriptors], en particulier pour les portefeuilles multisig et les portefeuilles à script complexe.
  Cependant, Salvatore Ingala a [répondu][ingala bip48] pour suggérer de conserver la partie _type de
  monnaie_ du chemin BIP48 car elle aide à garantir que les clés utilisées avec différentes
  cryptomonnaies sont conservées séparées, ce qui est appliqué par certains dispositifs de signature
  matérielle.

## Bitcoin Core PR Review Club

*Dans cette section mensuelle, nous résumons une récente réunion du [Bitcoin Core PR Review Club][],
mettant en lumière certaines des questions importantes et des réponses. Cliquez
sur une question ci-dessous pour voir un résumé de la réponse donnée lors de la réunion.*

[L'ajout d'un exécutable wrapper bitcoin][review club 31375] est une PR par [ryanofsky][gh
ryanofsky] qui introduit un nouveau binaire `bitcoin` qui peut être utilisé pour découvrir et lancer
les différents binaires de Bitcoin Core.

Bitcoin Core v29 a été livré avec 7 binaires (par exemple, `bitcoind`, `bitcoin-qt` et
`bitcoin-cli`), mais ce nombre devrait [augmenter][Bitcoin Core #30983] à l'avenir lorsque les
binaires [multiprocess][multiprocess design] seront également distribués. Le nouveau wrapper
`bitcoin` mappe les commandes (par exemple, `gui`) au bon binaire monolithique (`bitcoin-qt`) ou
multiprocessus (`bitcoin-gui`). En plus de la découvrabilité, le wrapper offre également une
compatibilité vers l'avant, de sorte que les binaires peuvent être réorganisés sans que l'interface
utilisateur ne change.

Avec cette PR, un utilisateur peut lancer Bitcoin Core avec `bitcoin daemon` ou `bitcoin gui`.
Lancer directement les binaires `bitcoind` ou `bitcoin-qt` reste possible et n'est pas affecté par
cette PR.

{% include functions/details-list.md
  q0="D'après le problème #30983, quatre stratégies de wrapper ont été listées. Quels inconvénients
  spécifiques de l'approche « side-binaries » cette PR aborde-t-elle ?"
  a0="L'approche des side-binaries supposée par cette PR implique de libérer les nouveaux binaires
  multiprocessus aux côtés des binaires monolithiques existants. Avec autant de binaires, cela peut
  être déroutant pour les utilisateurs de trouver et de comprendre le binaire dont ils ont besoin pour
  leur objectif. Cette PR élimine une grande partie de la confusion en fournissant un point d'entrée
  unique, avec un aperçu des options et une chaîne d'aide. Un examinateur a suggéré l'ajout d'une
  recherche floue pour faciliter encore plus cela."
  a0link="https://bitcoincore.reviews/31375#l-40"
  q1="`GetExePath()` n'utilise pas `readlink(\"/proc/self/exe\")` sur Linux même si cela serait plus
  direct. Quels avantages l'implémentation actuelle offre-t-elle ? Quels cas particuliers
  pourrait-elle manquer ?"
  a1="Il peut y avoir d'autres plateformes non-Windows qui n'ont pas le système de fichiers proc. À
  part cela, ni l'auteur ni les invités n'ont pu identifier d'inconvénients à l'utilisation de
  procfs."
  a1link="https://bitcoincore.reviews/31375#l-71"
  q2="Dans `ExecCommand`, expliquez le but du booléen `fallback_os_search`. Dans quelles circonstances
  vaut-il mieux éviter de laisser l'OS rechercher le binaire sur le `PATH` ?"
  a2="Si cela semble que l'exécutable wrapper a été invoqué par chemin (par exemple,
  \"/build/bin/bitcoin\") plutôt que par recherche (par exemple, \"bitcoin\"), il est supposé que
  l'utilisateur utilise une construction locale et `fallback_os_search` est défini sur `false`. Ce
  booléen est introduit pour éviter de mélanger involontairement des binaires de différentes sources.
  Par exemple, si l'utilisateur n'a pas construit localement `gui`, alors `/build/bin/bitcoin gui` ne
  devrait pas retomber sur le `bitcoin-gui` installé sur le système. L'auteur envisage de supprimer
  entièrement la recherche `PATH`, et les retours des utilisateurs seraient utiles."
  a2link="https://bitcoincore.reviews/31375#l-75"
  q3="Le wrapper ne recherche `${prefix}/libexec` que lorsqu'il détecte qu'il est exécuté depuis un
  répertoire `bin/` installé. Pourquoi ne pas toujours rechercher `libexec` ?"
  a3="Le wrapper doit être prudent quant aux chemins qu'il tente d'exécuter, et encourager les
  dispositions standard `PREFIX/{bin,libexec}`, et non encourager les wrapper à créer des
  dispositions non standard ou à fonctionner lorsque les binaires sont arrangés de manières
  inattendues."
  a3link="https://bitcoincore.reviews/31375#l-75"
  q4="La PR ajoute une exemption dans `security-check.py` parce que le wrapper ne contient pas
  d'appels `glibc` fortifiés. Pourquoi ne les contient-il pas, et l'ajout d'un simple `printf` à
  `bitcoin.cpp` briserait-il les constructions reproductibles sous les règles actuelles ?"
  a4="Le binaire du wrapper est si simple qu'il ne contient aucun appel pouvant être fortifié. S'il en
  contient à l'avenir, l'exemption dans security-check.py peut être retirée."
  a4link="https://bitcoincore.reviews/31375#l-117"
%}

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates._

- [LND 0.19.0-beta.rc4][] est un candidat à la sortie pour ce nœud LN populaire. L'une des
  principales améliorations qui pourrait probablement nécessiter des tests est le nouveau bumping de
  frais basé sur RBF pour les fermetures coopératives.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [Serveur
BTCPay][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration de Bitcoin (BIPs)][bips
repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Inquisition Bitcoin][bitcoin
inquisition repo], et [BINANAs][binana repo]._

- [Core Lightning #8227][] ajoute des plugins `lsps-client` et `lsps-service` basés sur Rust qui
  implémentent un protocole de communication entre les nœuds LSP et leurs clients, en utilisant un
  format JSON-RPC sur les messages peer-to-peer [BOLT8][], comme spécifié dans [BLIP50][] (voir
  le Bulletin [#335][news335 blip50]). Cela pose les bases pour l'implémentation des demandes de
  liquidité entrantes comme spécifié dans [BLIP51][], et de [canaux JIT][topic jit channels] comme
  spécifié dans [BLIP52][].

- [Core Lightning #8162][] met à jour la gestion des ouvertures de canaux en attente initiées par
  les pairs en les conservant indéfiniment, jusqu'à une limite des 100 plus récents. Auparavant, les
  ouvertures de canaux non confirmées étaient oubliées après 2016 blocs. De plus, les canaux fermés
  sont maintenant conservés en mémoire pour permettre à un nœud de répondre à un message
  `channel_reestablish` d'un pair.

- [Core Lightning #8166][] améliore la commande RPC `wait` en remplaçant son unique objet `details`
  par des objets spécifiques aux sous-systèmes : `invoices`,
  `forwards`, `sendpays` et [`htlcs`][topic htlc]. De plus, la commande RPC `listhtlcs` prend
  désormais en charge la pagination via les nouveaux champs `created_index` et `updated_index` ainsi
  que les paramètres `index`, `start` et `end`.

- [Core Lightning #8237][] ajoute un paramètre `short_channel_id` à la commande RPC
  `listpeerchannels` pour retourner uniquement un canal spécifique, s'il est fourni.

- [LDK #3700][] ajoute un nouveau champ `failure_reason` à l'événement `HTLCHandlingFailed` pour
  fournir des informations supplémentaires sur la raison de l'échec du [HTLC][topic htlc], et si la
  cause était locale ou en aval. Le champ `failed_next_destination` est renommé en `failure_type` et
  la variante `UnknownNextHop` est dépréciée, remplacée par la plus générale `InvalidForward`.

- [Rust Bitcoin #4387][] refactorise la gestion des erreurs [BIP32][topic bip32] en remplaçant le
  seul `bip32::Error` par des énumérations séparées pour la dérivation, le numéro/chemin de l'enfant
  et l'analyse de la clé étendue. Cette PR introduit également une nouvelle variante
  `DerivationError::MaximumDepthExceeded` pour les chemins dépassant 256 niveaux. Ces changements
  d'API rompent la compatibilité ascendante.

- [BIPs #1835][] met à jour [BIP48][] (voir le Bulletin [#135][news135 bip48]) pour réserver la
  valeur de type de script 3 pour les dérivations [taproot][topic taproot] (P2TR) dans les
  portefeuilles multisig déterministes avec le préfixe m/48', en plus des types de script P2SH-P2WSH
  (1′) et P2WSH (2′) existants.

- [BIPs #1800][] fusionne [BIP54][], qui spécifie la proposition de soft fork de nettoyage du
  consensus [topic consensus cleanup] pour corriger un certain nombre de vulnérabilités de longue date
  dans le protocole Bitcoin. Voir le Bulletin [#348][news348 cleanup] pour une description détaillée de
  ce BIP.

- [BOLTs #1245][] renforce [BOLT11][] en interdisant les encodages de longueur non minimale dans les
  factures : les champs d'expiration (x), le [délai d'expiration CLTV][topic cltv expiry delta] pour
  le dernier saut (c) et les bits de fonctionnalité (9) doivent être sérialisés en longueur minimale
  sans zéros initiaux, et les lecteurs devraient rejeter toute facture contenant des zéros initiaux.
  Ce changement a été motivé par des tests de fuzzing qui ont détecté que lorsque LDK resérialise des
  factures non minimales en minimales (en supprimant les zéros supplémentaires), cela provoque l'échec
  de la validation de la signature ECDSA de la facture.

{% include snippets/recap-ad.md when="2025-05-13 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="8227,8162,8166,8237,3700,4387,1835,1800,1245,50,51,52,30983" %}
[lnd 0.19.0-beta.rc4]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc4
[wuille clustrade]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303/68
[somsen bip30]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAPv7TjZTWhgzzdps3vb0YoU3EYJwThDFhNLkf4XmmdfhbORTaw@mail.gmail.com/
[loaec bip32reuse]: https://delvingbitcoin.org/t/avoiding-xpub-derivation-reuse-across-wallets-in-a-ux-friendly-manner/1644
[ingala bip48]: https://delvingbitcoin.org/t/avoiding-xpub-derivation-reuse-across-wallets-in-a-ux-friendly-manner/1644/3
[news346 checkpoints]: /fr/newsletters/2025/03/21/#bitcoin-core-31649
[news335 blip50]: /fr/newsletters/2025/01/03/#blips-52
[news135 bip48]: /en/newsletters/2021/07/28/#bips-1072
[news348 cleanup]: /fr/newsletters/2025/04/04/#brouillon-de-bip-publie-pour-le-nettoyage-du-consensus
[review club 31375]: https://bitcoincore.reviews/31375
[gh ryanofsky]: https://github.com/ryanofsky
[multiprocess design]: https://github.com/bitcoin/bitcoin/blob/master/doc/design/multiprocess.md
