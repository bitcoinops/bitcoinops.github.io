---
title: 'Bulletin Hebdomadaire Bitcoin Optech #300'
permalink: /fr/newsletters/2024/05/01/
name: 2024-05-01-newsletter-fr
slug: 2024-05-01-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume une proposition similaire à CTV qui utilise des engagements
intégrés dans les clés publiques, examine l'analyse d'un protocole de contrat avec Alloy, annonce
les arrestations de développeurs Bitcoin, et renvoie à des résumés d'une rencontre de développeurs
CoreDev.tech. Sont également incluses nos sections habituelles avec
des annonces de mises à jour et versions candidates, ainsi que les changements
apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Proposition de clés explosives similaire à CTV :** Tadge Dryja a [posté][dryja exploding] sur
  Delving Bitcoin une proposition pour une version légèrement plus efficace de l'idée principale de
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV). Avec CTV, Alice peut payer vers une
  sortie comme :

  ```text
  OP_CTV <hash>
  ```

  La préimage pour le digest du hash est un engagement sur les parties clés d'une transaction, plus particulièrement
  le montant de chaque sortie et le script à payer pour chacune. Par exemple :

  ```text
  hash(
    2 BTC à KeyB,
    3 BTC à KeyC,
    4 BTC à KeyD
  )
  ```

  L'opcode `OP_CTV` réussira s'il est exécuté dans une transaction qui correspond exactement à ces
  paramètres. Cela signifie que la sortie d'Alice dans une transaction peut être dépensée dans une
  seconde transaction sans nécessiter de signature supplémentaire ou d'autres données, tant que cette
  seconde transaction correspond à ce qu'Alice attendait.

  Dryja suggère une méthode alternative. Alice paie vers une clé publique (similaire à une sortie
  [taproot][topic taproot] mais avec une version segwit différente). La clé publique est construite à
  partir d'une agrégation [MuSig2][topic musig] d'une ou plusieurs clés publiques réelles plus une
  modification pour chaque clé qui s'engage de manière sécurisée sur un montant. Par exemple (adapté
  du post de Dryja) :

  ```text
  musig2(
    KeyB + hash(2 BTC, KeyB)*G,
    KeyC + hash(3 BTC, KeyC)*G,
    KeyD + hash(4 BTC, KeyD)*G
  )
  ```

  Une transaction sera valide si elle paie les clés publiques sous-jacentes exactement dans les
  montants spécifiés. Aucune signature n'est requise dans ce cas. Cela économise un peu d'espace par
  rapport à CTV dans taproot, un minimum d'environ 16 vbytes. Cela semble utiliser à peu près la même
  quantité d'espace par rapport à CTV dans un script nu (c'est-à-dire, placé directement dans un
  script de sortie).

  Lorsque CTV est utilisé dans taproot, une dépense de chemin de clé mutuellement convenue par toutes
  les parties impliquées peut être fournie comme alternative à l'exécution du CTV, permettant aux
  parties de changer la destination des fonds. Les clés explosives permettent la même chose par les
  personnes qui contrôlent KeyB, KeyC, KeyD. L'efficacité est la même dans les deux cas.

  Dryja écrit que les clés explosives "offrent la fonctionnalité de base de
  OP_CTV, tout en économisant quelques octets de données de témoin. En soi, ce n'est peut-être pas si
  convaincant, mais je voulais le mettre en avant car cela pourrait être une primitive utile dans le
  cadre d'une construction de covenant plus complexe."

- **Analyse d'un protocole de contrat avec Alloy :** Dmitry Petukhov a [publié][petukhov alloy] sur
  Delving Bitcoin une [spécification][petukhov spec] qu'il a créée en utilisant le langage de
  spécification [Alloy][] pour le simple coffre-fort basé sur `OP_CAT` décrit dans le [Bulletin
  #291][news291 catvault]. Petukhov a utilisé Alloy pour [trouver][petukhov mods] plusieurs
  modifications utiles et pour souligner des contraintes importantes que tout potentiel implémenteur
  devrait observer. Nous recommandons à quiconque s'intéresse à la modélisation formelle des
  protocoles de contrat de lire son post et sa spécification largement documentée.

- **Arrestations de développeurs Bitcoin :** comme largement rapporté ailleurs, deux développeurs du
  portefeuille Bitcoin Samourai, axé sur la confidentialité, ont été arrêtés la semaine dernière en
  relation avec leur logiciel, sur la base d'accusations des forces de l'ordre américaines. Par la
  suite, deux autres entreprises ont annoncé leur intention de cesser de servir les clients américains
  en raison des risques juridiques.

  La spécialité d'Optech est d'écrire sur la technologie Bitcoin, donc nous prévoyons de laisser la
  couverture de cette situation juridique à d'autres publications---mais nous exhortons quiconque
  s'intéresse au succès de Bitcoin, en particulier aux États-Unis, de
  rester informé et à envisagez d’offrir votre soutien lorsque des opportunités se présentent.

- **Événement CoreDev.tech à Berlin :** de nombreux contributeurs de Bitcoin Core se sont rencontrés
  en personne pour un événement périodique [CoreDev.tech][] le mois dernier à Berlin.
  Des [transcriptions][coredev xs] de certaines des sessions de l'événement ont été fournies par les
  participants. Présentations, revues de code, groupes de travail, ou autres sessions couvertes, parmi
  d'autres sujets :

  - Résultats de recherche ASMap
  - Préparation de assumeUTXO pour Mainnet
  - BTC Lisp
  - CMake
  - cluster mempool
  - sélection de pièces
  - agrégation de signature inter-entrées
  - spam réseau actuel
  - estimation des frais
  - discussion générale BIP
  - grand nettoyage du consensus
  - discussions GUI
  - suppression du portefeuille legacy
  - libbitcoinkernel
  - MuSig2
  - surveillance P2P
  - révision du relai de paquets
  - diffusion de transactions privées
  - révision des problèmes GitHub actuels
  - révision des PR GitHub actuelles
  - signet/testnet4
  - paiements silencieux
  - fournisseur de modèle Stratum v2
  - warnet
  - blocs faibles

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets
d'infrastructure Bitcoin. Veuillez envisager de passer aux nouvelles
versions ou d'aider à tester les versions candidates.*

- [Bitcoin Inquisition 25.2][] est la dernière version de ce nœud complet expérimental conçu pour
  tester les changements de protocole sur [signet][topic signet]. La dernière version ajoute le
  support pour [OP_CAT][topic op_cat] sur signet.

- [LND v0.18.0-beta.rc1][] est un candidat à la version pour la prochaine version majeure de ce
  populaire nœud LN.

### Changements notables dans le code et la documentation

_Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core
lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust
Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Propositions
d'Amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Inquisition
Bitcoin][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #27679][] permet aux notifications envoyées en utilisant le dispatcher [ZMQ][]
  d'être publiées sur un socket de domaine Unix. Cela était auparavant possible (peut-être
  involontairement) en passant une option de configuration d'une manière qui n'était pas documentée.

- [Bitcoin Core #22087][] a rendu l'analyse des options de configuration plus stricte, brisant le
  support non documenté dans Bitcoin Core 27.0, ce qui a [affecté LND][gugger zmq] et possiblement
  d'autres programmes. Ce PR rend l'option officiellement prise en charge et modifie légèrement sa
  sémantique pour la rendre cohérente avec d'autres options pour les sockets Unix dans Bitcoin Core,
  comme le changement décrit dans le [Bulletin #294][news294 sockets].

- [Core Lightning #7240][] ajoute un support pour récupérer les blocs nécessaires depuis le réseau
  P2P Bitcoin si le nœud Bitcoin local les a élagués. Si le nœud CLN a besoin d'un bloc qui a été
  élagué par son `bitcoind` local, il appellera le RPC Bitcoin Core `getblockfrompeer` pour le
  demander à un pair. Si le bloc est récupéré avec succès, Bitcoin Core l'authentifie en le connectant
  à l'en-tête qu'il conserve (même pour les blocs élagués) et le sauvegarde localement, où il peut
  être récupéré en utilisant les RPC de récupération de bloc standard.

- [Eclair #2851][] commence à dépendre de Bitcoin Core 26.1 ou supérieur et supprime le code pour le
  financement conscient des ascendants. À la place, la mise à niveau lui permet d'utiliser le nouveau
  code natif de Bitcoin Core qui est conçu pour compenser tout _déficit de frais_ (voir le [Bulletin
#269][news269 fee deficit]).

- [LND #8147][], [#8422][lnd #8422], [#8423][lnd #8423], [#8148][lnd #8148], [#8667][lnd #8667], et
  [#8674][lnd #8674] remplacent l'ancien balayeur de LND par une nouvelle implémentation, permettant
  la diffusion des transactions de règlement et de toutes les transactions nécessaires pour augmenter
  efficacement leurs frais. Les deux implémentations acceptent principalement les mêmes paramètres,
  tels que le délai avant lequel la transaction doit être confirmée et le taux de frais de départ à
  utiliser, avec la nouvelle implémentation ajoutant également un `budget` qui est le montant maximum
  à payer en frais.
  La nouvelle mise en œuvre offre plus de configurabilité, facilite la rédaction de tests, utilise à
  la fois [CPFP][topic cpfp] et [RBF][topic rbf] pour l'augmentation des frais (chacun lorsque c'est
  approprié), améliore le regroupement des augmentations de frais pour économiser sur les coûts, et
  met à jour les taux de frais uniquement à chaque bloc plutôt que toutes les 30 secondes.

- [LND #8627][] est désormais configuré par défaut pour rejeter les modifications demandées par
  l'utilisateur des paramètres de canal qui nécessitent des _frais de transfert entrants_ supérieurs à
  zéro. Par exemple, imaginez qu'Alice souhaite transférer un paiement par l'intermédiaire de Bob à
  Carol. Par défaut, Bob ne peut plus utiliser la fonctionnalité LND nouvellement ajoutée pour les
  frais de transfert entrants (voir le [Bulletin #297][news297 inbound]) pour exiger qu'Alice paie un
  supplément. Ce nouveau paramètre par défaut garantit que le nœud de Bob reste compatible avec les
  nœuds qui ne prennent pas en charge les frais de transfert entrants (ce qui représente actuellement
  presque tous les nœuds LN). Bob peut choisir d'être incompatible avec les versions antérieures en
  outrepassant le paramètre par défaut avec le réglage de configuration LND
  `accept-positive-inbound-fees`, ou il peut éventuellement obtenir le résultat souhaité tout en
  restant compatible avec les versions antérieures en augmentant ses frais de transfert sortants vers
  Carol puis en utilisant des frais de transfert entrants négatifs pour offrir des réductions sur les
  paiements qui n'ont pas leur origine chez Alice.

- [Libsecp256k1 #1058][] change l'algorithme utilisé pour générer les clés publiques et les
  signatures. Les deux algorithmes, l'ancien et le nouveau, fonctionnent en temps constant pour éviter
  de créer des vulnérabilités via des [canaux latéraux][topic side channels] de temporisation. Les
  benchmarks avec le nouvel algorithme montrent qu'il est environ 12% plus rapide. Un [court article
  de blog][stratospher comb] par l'un des relecteurs de la PR décrit le fonctionnement du nouvel
  algorithme.

- [BIPs #1382][] attribue [BIP331][] à la proposition pour [le relais de paquets d'ancêtres][topic
  package relay].

- [BIPs #1068][] échange deux paramètres dans [BIP47][] version 1 des codes de paiement
  réutilisables pour correspondre à une mise en œuvre dans le portefeuille Samourai. Des détails sur
  où trouver des informations pour les versions ultérieures des codes de paiement réutilisables sont
  également ajoutés au BIP. Notez que la mise en œuvre initiale de BIP47 par Samourai a eu lieu il y a
  des années et que cette PR est restée ouverte pendant plus de trois ans avant sa fusion la semaine
  passée.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="27679,7240,2851,22087,8147,8422,8423,8148,8667,8627,1058,1382,1068,8674" %}
[gugger zmq]: https://github.com/lightningnetwork/lnd/pull/8664#issuecomment-2065802617
[news269 fee deficit]: /fr/newsletters/2023/09/20/#bitcoin-core-26152
[news 297 inbound]: /fr/newsletters/2024/04/10/#lnd-6703
[stratospher comb]: https://github.com/stratospher/blogosphere/blob/main/sdmc.md
[petukhov alloy]: https://delvingbitcoin.org/t/analyzing-simple-vault-covenant-with-alloy/819
[petukhov mods]: https://delvingbitcoin.org/t/basic-vault-prototype-using-op-cat/576/16
[petukhov spec]: https://gist.github.com/dgpv/514134c9727653b64d675d7513f983dd
[alloy]: https://fr.wikipedia.org/wiki/Alloy_(langage_de_spécification)
[dryja exploding]: https://delvingbitcoin.org/t/exploding-keys-covenant-construction/832
[zmq]: https://fr.wikipedia.org/wiki/ZeroMQ
[news291 catvault]: /fr/newsletters/2024/02/28/#prototype-simple-de-coffre-fort-utilisant-op-cat
[news297 inbound]: /fr/newsletters/2024/04/10/#lnd-6703
[news294 sockets]: /fr/newsletters/2024/03/20/#bitcoin-core-27375
[Bitcoin Inquisition 25.2]: https://github.com/bitcoin-inquisition/bitcoin/releases/tag/v25.2-inq
[lnd v0.18.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.0-beta.rc1
[coredev.tech]: https://coredev.tech/
[coredev xs]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-04/
