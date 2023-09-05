---
title: 'Bulletin Hebdomadaire Bitcoin Optech #266'
permalink: /fr/newsletters/2023/08/30/
name: 2023-08-30-newsletter-fr
slug: 2023-08-30-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine relaie la divulgation responsable d'une vulnérabilité affectant d'anciennes implémentations de LN
et évoque une synthèse des propositions d'opcodes pour les covenants. Sont également incluses nos sections
régulières concernant les questions et réponses populaires sur le Bitcoin Stack Exchange, les nouvelles versions et
les versions candidates, et les changements apportés aux principaux logiciels de l'infrastructure Bitcoin.

## Nouvelles

- **Divulgation d'une vulnérabilité passée de LN liée au financement fictif :** Matt Morehouse [a publié][morehouse dos] sur la
  liste de diffusion Lighting-Dev le résumé d'une vulnérabilité qu'il avait précédemment [divulguée de manière responsable][topic
  responsible disclosures] et qui est maintenant résolue dans les dernières versions de toutes les implémentations LN populaires.
  Pour comprendre la vulnérabilité, imaginez que Bob exécute un nœud LN. Il reçoit une demande du nœud de Mallory pour ouvrir un
  nouveau canal et ils passent par le processus d'ouverture du canal jusqu'à l'étape où Mallory est censé diffuser une transaction
  qui finance le canal. Pour pouvoir utiliser ultérieurement ce canal, Bob doit stocker un certain état qui lui est lié et
  commencer à scanner de nouveaux blocs pour que la transaction soit suffisamment confirmée. Si Mallory ne diffuse jamais la
  transaction, les ressources de stockage et de numérisation de Bob sont gaspillées. Si Mallory répète le processus des milliers
  ou des millions de fois, cela pourrait gaspiller les ressources de Bob au point où son nœud LN ne peut plus rien faire---y compris
  effectuer des opérations sensibles au facteur temps nécessaires pour éviter la perte d'argent.

    Dans les tests de Morehouse sur ses propres nœuds, il a pu causer des problèmes importants avec Core Lightning, Eclair, LDK et
    LND, y compris deux cas qui (selon nous) pourraient probablement entraîner une perte de fonds parmi de nombreux nœuds. La
    [description complète][morehouse post] de Morehouse renvoie aux PR où le problème a été résolu (ce qui inclut les PR couverts
    dans les bulletins [#237][news237 dos] et [#240][news240 dos]) et liste les versions LN qui ont résolu la vulnérabilité :

    - Core Lightning 23.02
    - Eclair 0.9.0
    - LDK 0.0.114
    - LND 0.16.0

    Il y a eu des discussions de suivi sur la liste de diffusion et sur [IRC][stateless funding].

- **Synthèse de covenants utilisant `TXHASH` et `CSFS` :** Brandon Black [a publié][black mashup] sur la liste de diffusion
  Bitcoin-Dev une proposition pour une version de `OP_TXHASH` (voir [Bulletin #185][news185 txhash]) combinée avec
  [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] qui fournirait la plupart des fonctionnalités de
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV) et de [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] (APO) sans coût
  supplémentaire important par rapport à ces propositions individuelles. Bien que la proposition soit indépendante, une partie de
  la motivation pour la créer était de "clarifier notre réflexion sur [CTV et APO] individuellement et ensemble, et potentiellement
  de progresser vers un consensus sur une voie permettant [...] des façons étonnantes d'utiliser le bitcoin à l'avenir".

    La proposition a suscité des discussions sur la liste de diffusion, avec des [révisions supplémentaires][delv mashup] publiées
    et discutées sur le forum Delving Bitcoin.

## Sélection de Q&R du Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs
d'Optech cherchent des réponses à leurs questions---ou lorsque nous avons quelques moments
libres pour aider les utilisateurs curieux ou confus. Dans cette rubrique mensuelle, nous
mettons en avant certaines des questions et réponses les plus appréciées, postées depuis
notre dernière mise à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Y a-t-il un incitatif économique à passer de P2WPKH à P2TR ?]({{bse}}119301)
  Murch explique les modèles d'utilisation courants des portefeuilles tout en comparant les poids des entrées et des sorties
  de transaction pour les types de sortie P2WPKH et [P2TR][topic taproot]. Il conclut en disant : "Dans l'ensemble, vous
  économiseriez jusqu'à 15,4 % de frais de transaction en utilisant P2TR au lieu de P2WPKH. Si vous effectuez beaucoup plus
  de petits paiements que vous ne recevez de paiements, vous pourriez économiser jusqu'à 1,5 % en restant sur P2WPKH."

- [Quelle est la structure du paquet chiffré BIP324 ?]({{bse}}119369)
  Pieter Wuille décrit la structure du paquet réseau pour le [transport P2P de version 2][topic v2 p2p transport] tel que proposé
  dans [BIP324][] avec un suivi des progrès dans [Bitcoin Core #27634][].

- [Quel est le taux de faux positifs pour les filtres de bloc compacts ?]({{bse}}119142)
  Murch répond à partir de la section sur la sélection des paramètres des [filtres de bloc][bip158 filters] de [BIP158][] qui note
  un taux de faux positifs pour les [filtres de bloc compacts][topic compact block filters] de 1/784931, l'équivalent d'un bloc
  toutes les 8 semaines pour un portefeuille surveillant environ 1000 scripts de sortie.

- [Quels opcodes font partie de la proposition MATT ?]({{bse}}119239)
  Salvatoshi explique sa proposition Merkleize All The Things ([MATT][merkle.fun]) (voir les bulletins [#226][news226 matt],
  [#249][news249 matt] et [#254][news254 matt]), y compris ses opcodes actuellement proposés :
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify], OP_CHECKCONTRACTVERIFY et [OP_CAT][].

- [Existe-t-il un dernier bloc Bitcoin bien défini ?]({{bse}}119223)
  RedGrittyBrick et Pieter Wuille soulignent qu'il n'y a pas de limite de hauteur de bloc, mais les règles de consensus actuelles
  n'autorisent pas un nouveau bloc au-delà de la limite de temps non signée sur 32 bits de Bitcoin en l'an 2106. Les valeurs de
  [nLockTime][topic timelocks] des transactions ont la même [limite de temps]({{bse}}110666).

- [Pourquoi les mineurs définissent-ils le locktime dans les transactions coinbase ?]({{bse}}110474)
  Bordalix répond à une question ouverte depuis longtemps sur le fait que les mineurs utilisent apparemment le champ locktime de
  la transaction coinbase pour communiquer quelque chose. Un opérateur de pool de minage a expliqué qu'ils "réutilisent ces 4
  octets pour stocker les données de session de strate afin de permettre une reconnexion plus rapide" et a poursuivi en
  [détaillant le schéma][twitter satofishi].

- [Pourquoi Bitcoin Core n'utilise-t-il pas de hasard auxiliaire lors de l'exécution de signatures Schnorr ?]({{bse}}119042)
  Matthew Leon demande pourquoi [BIP340][] recommande d'utiliser un hasard auxiliaire lors de la génération d'un nonce de
  [signature schnorr][topic schnorr signatures] pour se protéger contre les attaques [par canaux latéraux][topic side channels],
  alors que Bitcoin Core ne fournit pas de hasard auxiliaire dans sa mise en œuvre. Andrew Chow répond que l'implémentation
  actuelle est toujours sûre et qu'aucune demande de fusion n'a été ouverte pour prendre en compte cette recommandation.

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets d’infrastructure Bitcoin.
 Veuillez envisager de passer aux nouvelles versions ou d’aider à tester les versions candidates.*

- [Core Lightning 23.08][] est la dernière version majeure de cette implémentation populaire de nœud LN. Les nouvelles
  fonctionnalités incluent la possibilité de modifier plusieurs paramètres de configuration du nœud sans redémarrer celui-ci,
  la prise en charge de la sauvegarde et de la restauration des [semences][topic bip32] au format [Codex32][topic codex32], un
  nouveau plugin expérimental pour améliorer la recherche de chemin de paiement, la prise en charge expérimentale du
  [splicing][topic splicing] et la possibilité de payer des factures générées localement, parmi de nombreuses autres nouvelles
  fonctionnalités et corrections de bugs.

- [LND v0.17.0-beta.rc1][] est un candidat à la prochaine version majeure de cette implémentation populaire de nœud LN. Une
  nouvelle fonctionnalité expérimentale majeure prévue pour cette version, qui pourrait bénéficier de tests, est la prise en
  charge des "canaux taproot simples" tels que décrits dans la PR LND #7904, dans la section des _changements notables_.

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration Bitcoin (BIPs)][bips repo], [BOLTs Lightning][bolts repo] et [Inquisition Bitcoin][bitcoin inquisition repo].*

- [Bitcoin Core #27460][] ajoute une nouvelle RPC `importmempool`. La RPC chargera un fichier `mempool.dat` et tentera d'ajouter
  les transactions chargées à sa mempool.

- [LDK #2248][] fournit un système intégré que les projets dérivés de LDK peuvent utiliser pour suivre les UTXO référencés dans
  les messages de gossip. Les nœuds LN qui traitent les messages de gossip ne doivent accepter que les messages signés par une
  clé associée à un UTXO, sinon ils peuvent être contraints de traiter et de relayer des messages indésirables, ou de tenter de
  transférer des paiements sur des canaux inexistants (ce qui échouera toujours). Le nouveau `UtxoSource` intégré fonctionne
  pour les nœuds LN connectés à un Bitcoin Core local.

- [LDK #2337][] facilite l'utilisation de LDK pour construire des [watchtowers][topic watchtowers] qui fonctionnent de manière
  indépendante du portefeuille de l'utilisateur mais peuvent recevoir des transactions de pénalité LN chiffrées depuis le nœud
  de l'utilisateur. Une tour de guet peut ensuite extraire des informations de chaque transaction dans les nouveaux blocs et
  utiliser ces informations pour tenter de décrypter les données précédemment reçues. Si le décryptage réussit, la tour de guet
  peut diffuser la transaction de pénalité décryptée. Cela protège l'utilisateur contre la publication d'un état de canal révoqué
  par la contrepartie lorsque l'utilisateur est indisponible.

- [LDK #2411][] et [#2412][ldk #2412] ajoutent une API pour construire des chemins de paiement pour les
  [paiements aveugles][topic rv routing]. Les PR aident à séparer le code de LDK pour les [messages oignon][topic onion messages]
  (qui utilisent des chemins aveugles) des chemins aveugles eux-mêmes. Un suivi dans [#2413][ldk #2413] ajoutera en fait la prise
  en charge de l'aveuglement des itinéraires.

- [LDK #2507][] ajoute une solution de contournement pour un problème de longue date dans une autre implémentation qui entraîne des
  fermetures de canal forcées inutiles.

- [LDK #2478][] ajoute un événement qui fournit des informations sur un [HTLC][topic htlc] transféré qui a maintenant été réglé,
  y compris le canal d'origine, le montant du HTLC et le montant des frais collectés.

- [LND #7904][] ajoute une prise en charge expérimentale des "canaux taproot simples", permettant aux transactions de financement
  et d'engagement LN d'utiliser [P2TR][topic taproot] avec prise en charge de la signature [MuSig2][topic musig] sans script
  [multisignature][topic multisignature] lorsque les deux parties coopèrent. Cela réduit l'espace de poids des transactions et
  améliore la confidentialité lorsque les canaux sont fermés de manière coopérative. LND continue d'utiliser exclusivement des
  [HTLC][topic htlc], permettant aux paiements commençant dans un canal taproot de continuer à être transférés via d'autres nœuds
  LN qui ne prennent pas en charge les canaux taproot.

    <!-- Les PR liées suivantes ont des titres "1/x", "2/x", etc. Je les ai listées dans cet ordre plutôt que par numéro de PR -->
    Ce PR comprend 134 validations qui ont été précédemment fusionnées dans une branche d'essai à partir des PR suivants : [#7332][lnd #7332], [#7333][lnd #7333], [#7331][lnd #7331], [#7340][lnd #7340], [#7344][lnd #7344], [#7345][lnd #7345], [#7346][lnd #7346], [#7347][lnd #7347] et [#7472][lnd #7472].

{% include references.md %}
{% include linkers/issues.md v=2 issues="27460,2466,2248,2337,2411,2412,2413,2507,2478,7904,7332,7333,7331,7340,7344,7345,7346,7347,7472,27634" %}
[LND v0.17.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.0-beta.rc1
[core lightning 23.08]: https://github.com/ElementsProject/lightning/releases/tag/v23.08
[delv mashup]: https://delvingbitcoin.org/t/combined-ctv-apo-into-minimal-txhash-csfs/60/6
[morehouse dos]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004064.html
[morehouse post]: https://morehouse.github.io/lightning/fake-channel-dos/
[news237 dos]: /fr/newsletters/2023/02/08/#core-lightning-5849
[news240 dos]: /fr/newsletters/2023/03/01/#ldk-1988
[black mashup]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021907.html
[news185 txhash]: /en/newsletters/2022/02/02/#composable-alternatives-to-ctv-and-apo
[stateless funding]: https://gnusha.org/lightning-dev/2023-08-27.log
[bip158 filters]: https://github.com/bitcoin/bips/blob/master/bip-0158.mediawiki#block-filters
[merkle.fun]: https://merkle.fun/
[news254 matt]: /fr/newsletters/2023/06/07/#utilisation-de-matt-pour-repliquer-ctv-et-gerer-les-joinpools
[news249 matt]: /fr/newsletters/2023/05/03/#coffres-forts-bases-sur-matt
[news226 matt]: /fr/newsletters/2022/11/16/#contrats-intelligents-generaux-en-bitcoin-via-des-clauses-restrictives
[twitter satofishi]: https://twitter.com/satofishi/status/1693537663985361038
