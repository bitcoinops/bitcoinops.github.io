---
title: 'Bulletin Hebdomadaire Bitcoin Optech #344'
permalink: /fr/newsletters/2025/03/07/
name: 2025-03-07-newsletter-fr
slug: 2025-03-07-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine annonce la divulgation d'une vulnérabilité affectant les anciennes
versions de LND et résume une discussion sur les priorités du projet Bitcoin Core. Sont également incluses
nos sections régulières résumant les discussions sur la modification des règles de consensus de
Bitcoin, annonçant de nouvelles versions et versions candidates, et décrivant les changements
notables apportés aux logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

- **Divulgation d'une vulnérabilité corrigée LND permettant le vol :** Matt Morehouse a
  [publié][morehouse failback] sur Delving Bitcoin pour annoncer la [divulgation responsable][topic
  responsible disclosures] d'une vulnérabilité qui affectait les versions de LND antérieures à 0.18.
  Il est recommandé de mettre à niveau vers 0.18 ou, idéalement, vers la [version actuelle][lnd
  current]. Un attaquant qui partage un canal avec un nœud victime et qui peut également amener le
  nœud de la victime à redémarrer à un moment particulier peut tromper LND en payant et en remboursant
  le même HTLC, permettant à l'attaquant de voler presque la totalité de la valeur d'un canal.

  Morehouse note que les autres implémentations de LN ont toutes découvert et corrigé cette
  vulnérabilité indépendamment, y compris dès 2018 (voir le [Bulletin #17][news17 cln2000]), mais la
  spécification LN ne décrit pas le comportement correct (et peut même exiger le comportement
  incorrect). Il a [ouvert une PR][bolts #1233] pour mettre à jour la spécification.

- **Discussion sur les priorités de Bitcoin Core :** plusieurs articles de blog d'Antoine Poinsot
  sur l'avenir du projet Bitcoin Core ont été liés dans un [fil][poinsot pri] sur Delving Bitcoin.
  Dans le [premier][poinsot pri1] article de blog, Poinsot décrit les avantages de la définition
  d'objectifs à long terme et les coûts de la prise de décision ad hoc. Dans le [deuxième][poinsot
  pri2] post, il soutient que "Bitcoin Core devrait être une colonne vertébrale robuste pour le réseau
  Bitcoin, un équilibre entre sécuriser le logiciel Bitcoin Core et implémenter de nouvelles
  fonctionnalités pour renforcer et améliorer le réseau Bitcoin." Dans le [troisième][poinsot pri3]
  post, il recommande de diviser le projet existant en trois projets : un nœud, un portefeuille et une
  interface graphique. Cela est à portée de main aujourd'hui grâce à l'effort de plusieurs années du
  sous-projet multiprocess (voir le [Bulletin #39][news39 multiprocess] pour notre première mention de
  ce sous-projet en 2019).

  Anthony Towns [questionne][towns pri] si le multiprocess permettrait vraiment une séparation
  effective, car les composants individuels resteraient étroitement liés. De nombreux changements à un
  projet nécessiteraient également des modifications aux autres projets. Cependant, ce serait un
  avantage certain de déplacer les fonctionnalités qui n'exigent actuellement pas un nœud vers une
  bibliothèque ou un outil qui peut être maintenu indépendamment. Il décrit également comment
  certaines personnes utilisent aujourd'hui des nœuds avec des intergiciels qui facilitent la
  connexion de leurs portefeuilles à leurs propres nœuds en utilisant des index de blockchain
  (essentiellement [un explorateur de blocs personnel][topic block explorers])---quelque chose que le
  projet Bitcoin Core a précédemment rejeté d'inclure dans son nœud directement.
  Finalement, il [note][towns pri2] que "pour [lui], fournir des fonctionnalités de
  portefeuille (principalement) et une interface graphique (dans une moindre mesure[...]) est une
  manière de rester fidèles au principe selon lequel le bitcoin doit être utilisable par un groupe
  décentralisé de hackers, plutôt que d’être quelque chose que vous pouvez vraiment utiliser seulement
  si vous êtes un gros investisseur ou une entreprise établie prête à faire un gros investissement."

  David Harding exprime [des préoccupations][harding pri] quant au fait de recentrer le projet
  principal uniquement sur le code de consensus et le relais P2P, ce qui rendra plus difficile pour
  les utilisateurs quotidiens l'utilisation d'un nœud complet pour valider leurs propres transactions
  de portefeuille entrantes. Il demande à Poinsot et aux autres contributeurs de considérer plutôt de
  rendre Bitcoin Core plus facile pour les utilisateurs quotidiens. Il décrit la puissance de la
  validation par nœud complet : ceux qui exploitent les nœuds complets qui valident la majorité de
  l'activité économique ont la capacité de définir les règles de consensus de Bitcoin. Dans un
  exemple, il montre que même un changement de 30 minutes dans les règles appliquées pourrait conduire
  à la destruction politiquement permanente de propriétés chéries de Bitcoin, telles que la limite de
  21M BTC. Il croit que les utilisateurs quotidiens sont plus fortement investis dans les propriétés
  de Bitcoin que les organisations qui exploitent des nœuds pour le compte de leurs clients. Si les
  développeurs de Bitcoin Core valorisent les règles de consensus actuelles, Harding soutient que
  rendre facile pour les utilisateurs quotidiens de valider personnellement leurs transactions de
  portefeuille est aussi important pour la sécurité que de prévenir et éliminer les bugs qui
  pourraient conduire à de graves vulnérabilités.

## Changement de consensus

_Une section mensuelle résumant les propositions et discussions sur le changement des règles de
consensus de Bitcoin._

- **Guide de Forking Bitcoin :** Anthony Towns [a annoncé][towns bfg] à Delving Bitcoin un guide sur
  comment construire un consensus communautaire pour des changements aux règles de consensus de
  Bitcoin. Il divise la construction du consensus social en quatre étapes : recherche et
  développement, exploration par les utilisateurs avancés, évaluation par l'industrie, et révision par
  les investisseurs. Il touche ensuite brièvement aux étapes techniques qui viennent à la fin du
  processus pour activer le changement dans le logiciel Bitcoin.

  Son post note que "c’est seulement un guide vers la voie coopérative, où vous faites un changement
  qui améliore la vie de tout le monde, et plus ou moins tout le monde finit par être d'accord que le
  changement rend la vie de tout le monde meilleure." Il avertit également que "c'est aussi seulement
  un guide assez général."

- **Mise à jour sur BIP360 pay-to-quantum-resistant-hash (P2QRH) :** le développeur Hunter Beast [a
  posté][beast p2qrh] une mise à jour sur ses recherches en [résistance quantique][topic quantum
  resistance] pour [BIP360][] à la liste de diffusion Bitcoin-Dev. Il a fait des changements à la
  liste des algorithmes sécurisés quantiques qu'il propose d'utiliser, cherche quelqu'un pour
  devenir le champion du développement d'un schéma pay-to-taproot-hash (P2TRH) (voir le [Bulletin #141][news141
  p2trh]), et envisage de cibler le même niveau de sécurité que celui actuellement fourni par Bitcoin
  (NIST II) plutôt qu'un niveau supérieur (NIST V) qui nécessite plus d'espace de bloc et de temps de
  vérification CPU. Son post a reçu plusieurs réponses.

- **Marché privé de modèles de blocs pour prévenir la centralisation du MEV :** Matt
  Corallo et le développeur 7d5x9 ont [publié][c7 mev] sur Delving Bitcoin concernant la possibilité
  pour les parties de faire des offres sur les marchés publics pour un espace sélectionné au sein des
  modèles de blocs des mineurs. Par exemple, "Je paierai X [BTC] pour inclure la transaction Y tant
  qu'elle précède toute autre transaction qui interagit avec le contrat intelligent identifié par Z".
  C'est quelque chose que les créateurs de transactions sur Bitcoin veulent déjà pour divers
  protocoles, tels que certains [protocoles de pièces colorées][topic client-side validation], et cela
  deviendra probablement encore plus souhaitable à l'avenir à mesure que de nouveaux protocoles sont
  développés (y compris les propositions nécessitant des changements de consensus tels que certains
  [covenants][topic covenants]).

  Si le service de classement préférentiel des transactions au sein des modèles de blocs n'est pas
  fourni par un marché public à confiance réduite, il est probable qu'il sera plutôt fourni par de
  grands mineurs, qui concurrenceront les utilisateurs des divers protocoles. Cela exigera que les
  mineurs obtiennent de grandes quantités de capital et de sophistication technique, les menant
  probablement à réaliser des profits significativement plus élevés que les petits mineurs sans ces
  capacités. Cela centralisera l'exploitation minière et permettra aux grands mineurs de censurer les
  transactions Bitcoin plus facilement.

  Les développeurs proposent de fournir une réduction de la confiance en permettant aux mineurs de
  travailler sur des modèles de blocs aveuglés dont les transactions complètes ne sont pas révélées au
  mineur jusqu'à ce qu'ils aient produit suffisamment de preuve de travail pour publier le bloc. Les
  développeurs proposent deux mécanismes pour atteindre cela sans nécessiter de changements de
  consensus :

  - **Modèles de blocs fiables :** un mineur se connecte à un marché, sélectionne les offres qu'il
    souhaite inclure dans un bloc, et demande au marché de construire un modèle de bloc. Le marché
    répond avec un en-tête de bloc, une transaction coinbase, et une branche de merkle partielle qui
    permettent au mineur de générer la preuve de travail pour ce modèle sans en connaître le contenu
    exact. Si le mineur produit la quantité de preuve de travail _cible_ du réseau, il soumet l'en-tête
    et la transaction coinbase au marché, qui vérifie la preuve de travail, l'ajoute au modèle de bloc,
    et diffuse le bloc. Le marché pourrait inclure une transaction payant le mineur dans le modèle de
    bloc ou il pourrait payer le mineur séparément à un moment ultérieur.

  - **Environnements d'exécution fiables :** les mineurs obtiennent un dispositif avec un enclave
    sécurisée [TEE][], se connectent aux marchés et sélectionnent les offres qu'ils souhaitent inclure
    dans leurs blocs, et reçoivent les transactions de ces offres chiffrées pour la clé d'enclave du
    TEE. Le modèle de bloc est construit au sein du TEE et le TEE fournit au système d'exploitation hôte
    l'en-tête, la transaction coinbase, et la branche de merkle partielle. Si la preuve de travail cible
    est générée, le mineur la fournit au TEE, qui la vérifie et retourne le modèle de bloc déchiffré
    complet pour que le mineur l'ajoute à l'en-tête et le diffuse. Encore une fois, le modèle de bloc
    pourrait inclure une transaction payant le mineur à partir d'un UTXO appartenant au marché ou le
    marché pourrait payer le mineur plus tard.

  Les deux schémas nécessiteraient effectivement plusieurs marchés concurrents, la proposition notant
  que l'attente serait que certains membres de la communauté et organisations exploitent des marchés
  sur une base non lucrative pour aider à préserver la décentralisation contre la domination d'un seul
  marché de confiance.

## Mises à jour et versions candidates

_Nouvelles mises à jour et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de passer aux nouvelles versions ou d'aider à tester
les versions candidates._

- [Core Lightning 25.02][] est une version de la prochaine version majeure de ce nœud LN populaire.
  Il inclut le support pour le [peer storage][topic peer storage] (utilisé pour stocker des transactions
  de pénalité chiffrées qui peuvent être récupérées et déchiffrées pour fournir un type de
  [watchtower][topic watchtowers]) en plus d'autres améliorations et corrections de bugs.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo],
[Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin
inquisition repo], et [BINANAs][binana repo]._

- [Eclair #3019][] modifie le comportement d'un nœud pour favoriser une transaction de commitment à
  distance vue dans le mempool plutôt que de diffuser une locale lors d'une fermeture unilatérale
  initiée par un pair. Auparavant, le nœud diffuserait son engagement local, provoquant
  potentiellement une course entre les deux transactions. Opter pour la transaction de commitment à
  distance est bénéfique pour le nœud local car cela évite les délais de [timelock][topic timelocks] locaux
  `OP_CHECKSEQUENCEVERIFY` (CSV)  et élimine le besoin de transactions supplémentaires du
  nœud local pour résoudre les [HTLCs][topic htlc] en attente.

- [Eclair #3016][] introduit des méthodes de bas niveau pour créer des transactions Lightning dans
  les [canaux simples taproot][topic simple taproot channels], sans apporter de changements fonctionnels.
  Ces méthodes sont générées avec [miniscript][topic miniscript], et diffèrent de celles décrites dans
  la spécification [BOLTs #995][].

- [LDK #3342][] ajoute une structure `RouteParametersConfig` qui permet aux utilisateurs de
  personnaliser les paramètres de routage pour les paiements de factures [BOLT12][topic offers].
  Auparavant limité à `max_total_routing_fee_msat`, la nouvelle structure inclut maintenant
  [`max_total_cltv_expiry_delta`][topic cltv expiry delta], `max_path_count`, et
  `max_channel_saturation_power_of_half`. Ce changement aligne le paramétrage de [BOLT12][] sur celui
  de [BOLT11][].

- [Rust Bitcoin #4114][] réduit la taille minimale des transactions non-witness de 85 octets à 65
  octets, s'alignant sur la politique de Bitcoin Core (voir les Bulletins [#222][news222 minsize] et
  [#232][news232 minsize]). Ce changement permet des transactions plus minimales, telles que celles
  avec une entrée et une sortie `OP_RETURN`.

- [Rust Bitcoin #4111][] ajoute le support pour le nouveau type de sortie standard [P2A][topic
  ephemeral anchors], introduit dans Bitcoin Core 28.0 (voir le Bulletin [#315][news315 p2a]).

- [BIPs #1758][] met à jour [BIP374][], qui définit les Preuves d'Égalité de Logarithme Discret
  ([DLEQ][topic dleq]) (voir le Bulletin [#335][news335 dleq]), en intégrant le champ de message
  dans le calcul de `rand`. Ce changement empêche la fuite potentielle de `a` (la clé privée) qui
  pourrait se produire si deux preuves étaient construites avec les mêmes `a`, `b`, et `g` mais avec
  des messages différents et un `r` entièrement à zéro.

- [BIPs #1750][] met à jour [BIP329][], qui définit un format pour l'exportation des [étiquettes de
  portefeuille][topic wallet labels], en ajoutant des champs optionnels associés aux adresses,
  transactions et sorties. Une correction de type JSON est également incluse.

- [BIPs #1712][] et [BIPs #1771][] ajoutent [BIP3][], remplaçant [BIP2][] en apportant plusieurs
  mises à jour au processus BIP. Les changements incluent la réduction des valeurs du champ de statut
  à quatre (au lieu de neuf), permettant à un BIP en brouillon d'être marqué comme Fermé par n'importe
  qui après un an sans progrès si les auteurs ne confirment pas le travail en cours, permettant aux
  BIPs de rester indéfiniment en statut Complet, permettant des mises à jour continues aux BIPs comme
  celui-ci, réaffectant certaines décisions éditoriales des éditeurs de BIP aux auteurs ou à
  l'audience du dépôt, éliminant le système de commentaires, et exigeant qu'un BIP soit sur le sujet
  pour recevoir un numéro, avec plusieurs mises à jour au format et au préambule du BIP.

{% include snippets/recap-ad.md when="2025-03-11 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3019,3016,3342,4114,4111,1758,1750,1712,1771,1233,995" %}
[Core Lightning 25.02]: https://github.com/ElementsProject/lightning/releases/tag/v25.02
[news39 multiprocess]: /en/newsletters/2019/03/26/#bitcoin-core-10973
[news141 p2trh]: /en/newsletters/2021/03/24/#we-could-add-a-hash-style-address-after-taproot-is-activated
[poinsot pri]: https://delvingbitcoin.org/t/antoine-poinsot-on-bitcoin-cores-priorities/1470/
[poinsot pri1]: https://antoinep.com/posts/core_project_direction/
[poinsot pri2]: https://antoinep.com/posts/stating_the_obvious/
[poinsot pri3]: https://antoinep.com/posts/bitcoin_core_scope/
[towns pri]: https://delvingbitcoin.org/t/antoine-poinsot-on-bitcoin-cores-priorities/1470/3
[towns pri2]: https://delvingbitcoin.org/t/antoine-poinsot-on-bitcoin-cores-priorities/1470/15
[harding pri]: https://delvingbitcoin.org/t/antoine-poinsot-on-bitcoin-cores-priorities/1470/10
[towns bfg]: https://delvingbitcoin.org/t/bitcoin-forking-guide/1451
[beast p2qrh]: https://mailing-list.bitcoindevs.xyz/bitcoindev/8797807d-e017-44e2-b419-803291779007n@googlegroups.com/
[c7 mev]: https://delvingbitcoin.org/t/best-worst-case-mevil-response/1465
[tee]: https://en.wikipedia.org/wiki/Trusted_execution_environment
[news17 cln2000]: /en/newsletters/2018/10/16/#c-lightning-2000
[morehouse failback]: https://delvingbitcoin.org/t/disclosure-lnd-excessive-failback-exploit/1493
[lnd current]: https://github.com/lightningnetwork/lnd/releases
[news222 minsize]: /fr/newsletters/2022/10/19/#taille-minimale-des-transactions-relayables
[news232 minsize]: /fr/newsletters/2023/01/04/#bitcoin-core-26265
[news315 p2a]: /fr/newsletters/2024/08/09/#bitcoin-core-30352
[news335 dleq]: /fr/newsletters/2025/01/03/#bips-1689
