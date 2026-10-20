---
title: 'Bulletin Hebdomadaire Bitcoin Optech #416'
permalink: /fr/newsletters/2026/07/31/
name: 2026-07-31-newsletter-fr
slug: 2026-07-31-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine avertit d'une vulnérabilité grave affectant les portefeuilles générés par les dispositifs de signature
COLDCARD, résume la divulgation de deux vulnérabilités de déni de service dans Core Lightning, et décrit une preuve de concept pour une
preuve de réserves à divulgation nulle de connaissance. Sont également incluses nos sections régulières avec une sélection de questions et
réponses de Bitcoin Stack Exchange, des annonces de nouvelles versions et versions candidates, et des descriptions de changements notables
dans des logiciels populaires d'infrastructure Bitcoin.

## Mesures à prendre

- **Déplacez les fonds sécurisés par des clés générées par COLDCARD :** si vous avez utilisé un COLDCARD Mk3 pour générer un portefeuille,
  tous les fonds reçus par ce portefeuille risquent d'être volés et devraient être déplacés avec précaution vers un portefeuille non affecté
  dès que possible. Les portefeuilles générés par d'autres modèles COLDCARD peuvent également être affectés. Voir la section Nouvelles
  ci-dessous pour plus de détails.

## Nouvelles

- **Les portefeuilles générés par COLDCARD risquent le vol** : Le 30 juillet 2026, certains utilisateurs de Bitcoin ont découvert que les
  fonds de leurs portefeuilles COLDCARD avaient été volés dans une série de transactions inattendues le 29 juillet. Au cours de la journée,
  un bogue a été identifié dans le micrologiciel du COLDCARD Mk3 qui fait que les portefeuilles sont générés avec une entropie insuffisante.
  Au moment de la rédaction, les pertes estimées dépassent 1 000 BTC, un chiffre qui pourrait continuer à augmenter à mesure que la
  situation évolue.

  Un [avis de sécurité][coinkite advisory] de Coinkite a identifié les portefeuilles générés par COLDCARD Mk3 avec la version de
  micrologiciel 4.0.1 (mars 2021) ou ultérieure, y compris la dernière version publiée, comme vulnérables au vol, sauf si la seed a été
  créée avec une entropie externe suffisante (comme 50 lancers de dés privés ou plus) ou si le portefeuille était en plus protégé par une
  phrase de passe robuste. L'avis identifie également les seeds générées par les micrologiciels Mk4 et Mk5 avant la version 5.6.0 et le
  micrologiciel Q avant la version 1.5.0Q comme affectées.

  Dans un [document de contexte technique][coinkite backgrounder] de suivi, Coinkite attribue le bogue à une modification de code de 2021
  qui a involontairement redirigé la génération de seed vers un PRNG logiciel, initialisé à partir de valeurs uniques prévisibles propres à
  l'appareil, au lieu du générateur matériel de nombres aléatoires de l'appareil. Les seeds générées par un Mk3 affecté sans lancers de dés
  supplémentaires n'ont qu'environ 40 bits d'entropie effective au lieu des 128 prévus. Les seeds des appareils affectés Mk4, Mk5 et Q sont
  plus difficiles à attaquer parce qu'une sortie d'un élément sécurisé y est également mélangée, bien qu'une [analyse][block analysis] de
  Block, réalisée avec des chercheurs anonymes et divulguée en coordination avec Coinkite, ait constaté que seuls 32 bits de cette entropie
  atteignent l'état du PRNG, laissant ces seeds toujours bien en dessous du niveau de sécurité prévu.

  Plusieurs développeurs ont pu immédiatement reproduire l'attaque avec l'assistance de modèles d'IA de pointe, de sorte qu'il faut supposer
  que la vulnérabilité fait l'objet d'une exploitation active. L'analyse de Block identifie en outre le plus ancien COLDCARD Mk2 exécutant
  un micrologiciel 4.x comme affecté au même degré que le Mk3, et note que d'autres secrets générés aléatoirement, comme les clés privées de
  paper wallets et les seeds éphémères, sont également affectés.

  Il s'agit d'une situation évolutive, et des informations supplémentaires sont susceptibles d'émerger après la publication de ce bulletin.
  Les lecteurs devraient surveiller [le blog de Coinkite][coinkite blog] et d'autres sources pour des mises à jour. Bitcoin Optech
  recommande aux utilisateurs de COLDCARD dont les portefeuilles peuvent être affectés déplacent leurs fonds avec précaution vers un
  portefeuille non affecté dès que possible. Les seeds générées sur un appareil affecté sans lancers de dés supplémentaires devraient être
  considérées comme compromises. Les utilisateurs d'appareils Mk4, Mk5 et Q devraient mettre à niveau vers un micrologiciel corrigé avant de
  générer de nouveaux portefeuilles. Une mise à niveau seule ne rend pas une seed existante sûre.

- **Divulgation de deux vulnérabilités DoS dans Core Lightning** : Chandra Pratap a [publié][cln vuln del] sur Delving Bitcoin deux
  vulnérabilités de déni de service (DoS) qu'il a trouvées dans Core Lightning pendant son stage pour le programme [Summer of Bitcoin][sob].
  Plus précisément, ces vulnérabilités auraient permis à un attaquant de faire planter un nœud en épuisant sa mémoire. Les bogues sont liés
  à la machine à états du démon `gossipd`, en particulier à son interface avec le démon `connectd`. Pratap a pu trouver les vulnérabilités
  grâce à son travail sur une nouvelle cible de fuzzing, `fuzz-gossipd-connectd`, qui vise à tester la robustesse de la communication entre
  les deux modules.

  La première vulnérabilité était liée à la file de messages inter-démons, partagée entre les deux démons, dont le but est de stocker tous
  les messages `channel_update` arrivant du réseau. Un attaquant aurait pu inonder le nœud de messages, provoquant une croissance indéfinie
  de la file interne et entraînant la consommation de toute la RAM disponible. Le bogue a été corrigé simplement dans [Core Lightning
  #8376][] en permettant à la file d'abandonner des messages, en ajoutant un point de coupure à 500 000 messages.

  La deuxième vulnérabilité a été découverte en essayant de corriger la première. Elle était notamment liée à la table interne utilisée pour
  suivre les identifiants courts de canaux (SCIDs) inconnus afin d'interroger les pairs sur d'éventuels canaux manquants. Un attaquant
  aurait pu inonder le nœud de faux SCID, provoquant une consommation mémoire toujours croissante. Bien que le bogue n'ait pas été
  précédemment signalé, Rusty Russell travaillait déjà sur un correctif dans [Core Lightning #8903][], qui introduisait un mécanisme
  amélioré de ramasse-miettes pour la table interne.

- **Preuve de concept pour une preuve de réserves à divulgation nulle de connaissance** : fabohax a [publié][zkpoh del] à propos de zkPoH
  ("zero-knowledge proof-of-hodl"), une preuve de concept pour un système non dépositaire de [preuve de réserves][topic proof of reserves]
  pour Bitcoin. Le prototype permet à un utilisateur de prouver qu'il contrôle un ensemble d'UTXOs, dont la valeur combinée est d'au moins
  100 000 000 sats (1 BTC), sans révéler d'informations supplémentaires.

  La preuve de concept prend en entrée un instantané d'UTXO généré hors chaîne, qui est ensuite engagé dans un arbre de Merkle, dont la
  racine devient l'engagement public. Le prouveur sélectionne jusqu'à quatre UTXOs de l'instantané et génère l'entrée témoin pour le circuit
  [Noir][noir lang], qui vérifie que les UTXOs choisies appartiennent bien à l'instantané, que les chemins de Merkle sont valides, et que la
  somme des UTXOs sélectionnées est au moins égale au montant requis. Le vérificateur apprend seulement que le prouveur satisfait à
  l'exigence des 100 000 000 sats.

  Au moment de la rédaction, une étape explicite de liaison à la propriété n'est pas disponible dans la preuve de concept. Cela signifie
  qu'il n'existe aucun moyen de prouver que les UTXOs choisies appartiennent réellement au prouveur. L'auteur travaille actuellement à
  ajouter cette fonctionnalité, soit par une vérification de propriété hors circuit, soit directement à l'intérieur de celui-ci. Le
  prototype est actuellement disponible dans un [dépôt][zkpoh gh] dédié.

## Questions et réponses sélectionnées de Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech cherchent des réponses à leurs
questions---ou quand nous avons quelques moments libres pour aider les utilisateurs curieux ou confus. Dans cette rubrique mensuelle, nous
mettons en lumière certaines des questions et réponses les mieux votées postées depuis notre dernière mise à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Quelle est la définition objective par Bitcoin de la neutralité des transactions ?]({{bse}}130849) Ava Chow présente la neutralité comme
  le fait de savoir si un changement empêche quiconque de continuer à utiliser Bitcoin comme il le fait déjà, par exemple en rendant des
  scripts auparavant dépensables impossibles à dépenser ou en cassant un protocole déployé.

- [Pourquoi l'avantage de décentralisation du BIP110 ne l'emporte-t-il pas sur son impact sur la neutralité des transactions ?]({{bse}}130848)
  Pieter Wuille soutient que l'invalidation de modèles de transactions transportant des données ne réduirait pas les coûts
  des nœuds parce que la limite de poids des blocs borne déjà l'utilisation des ressources, que les octets de stockage de données sont parmi
  les moins coûteux à traiter, et que les modèles interdits seraient simplement remplacés par d'autres transactions.

- [Pourquoi le BIP110 exige-t-il un seuil de signalement de 55 % si ses nœuds rejettent les blocs non signalants ?]({{bse}}130885) Vojtěch
  Strnad explique que le seuil s'applique au signalement volontaire des mineurs avant le début de la période de signalement obligatoire
  (voir le [Bulletin #392][news392 bip110]). Un verrouillage anticipé indique une adhésion plus large et peut
  activer le soft fork plus tôt, mais une fois que le signalement obligatoire commence, les nœuds qui appliquent la règle écartent les blocs
  non signalants.

- [Pourquoi utiliser l'encodage ElligatorSwift dans BIP324 ?]({{bse}}130887) Pieter Wuille explique que l'encodage des clés publiques du
  handshake sous forme d'octets uniformément aléatoires rend l'ensemble du flux d'octets du [transport v2][topic v2 p2p transport]
  pseudo-aléatoire, empêchant l'identification par correspondance de motifs et forçant un pare-feu censeur soit à monter une attaque
  complète de type homme du milieu, soit à fonctionner avec une liste blanche. Cela peut aussi faciliter l'imitation d'autres protocoles.

- [La réservation OP_SUCCESSx dans BIP342 a-t-elle été conçue avec des familles d'opcodes spécifiques à l'esprit ?]({{bse}}130670) Murch
  décrit les opcodes `OP_SUCCESS` comme des crochets génériques de mise à niveau. Puisque n'importe quel `OP_SUCCESS` rend un
  [tapscript][topic tapscript] inconditionnellement valide, un futur soft fork peut en redéfinir un avec un comportement plus restrictif, y
  compris une manipulation de pile que des opcodes `OP_NOP` redéfinis ne pourraient jamais effectuer.

- [Quelle est la différence entre le feerate de long terme et le feerate d'abandon ?]({{bse}}130861) Murch précise que les deux ne sont pas
  interchangeables. Le feerate d'abandon fixe les limites de poussière en dessous desquelles la valeur d'une sortie potentielle de monnaie
  rendue est donnée aux frais, tandis que le feerate de long terme fixe la frontière du portefeuille entre une [sélection de pièces][topic
  coin selection] de consolidation et une sélection économe.

- [Quelle est la méthode la plus rapide pour migrer un portefeuille hérité vers un portefeuille à descripteurs sur un nœud élagué ?]({{bse}}130713)
  Pol Espinasa explique que la migration tente de charger le portefeuille migré, ce qui échoue sur un nœud élagué en
  dessous de la date de naissance du portefeuille. [Bitcoin Core #35266][] (voir le [Bulletin #412][news412 migratewallet]), attendu dans la
  version 32.0, permet de migrer sans charger le portefeuille, bien que le chargement du portefeuille à [descripteurs][topic
  descriptors] migré nécessite toujours un nœud disposant des blocs pertinents.

- [Existe-t-il des données historiques sur les taux de blocs orphelins/périmés pendant les périodes de frais élevés ?]({{bse}}130889) 0xB10C
  renvoie vers le [jeu de données stale-blocks][stale blocks site] maintenu par le projet bitcoin-data, qui trace le taux de blocs périmés
  au fil du temps et fournit les [données brutes][stale blocks repo] pour dériver des métriques personnalisées.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires. Veuillez envisager de mettre à niveau vers
les nouvelles versions ou d'aider à tester les versions candidates._

- [BTCPay Server 2.4.1][] est une version de maintenance pour ce processeur de paiement auto-hébergé. Elle ajoute les importations
  d'étiquettes de portefeuille [BIP329][] (voir le [Bulletin #415][news415 labels]), des commentaires de facture modifiables, et plusieurs autres
  améliorations et corrections de bogues.

- [Eclair 0.14.1][] est une version de maintenance pour cette implémentation de nœud LN. Elle exige désormais Bitcoin Core 31.x, désactive
  une remise expérimentale sur les frais des chemins aveuglés [BOLT12][topic offers] qui ne fonctionnait pas correctement avec les
  [paiements multipath][topic multipath payments], et inclut plusieurs corrections de bogues et améliorations de performance. Les opérateurs
  utilisant des plugins personnalisés de gestion des offese devraient consulter les [notes de version][eclair 0.14.1 notes].

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning
BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #34628][] remplace les files d'attente indépendantes de relais de transactions par pair par des files globales entrantes et
  sortantes contrôlées par des seaux de jetons sur le nombre et la taille sérialisée. Cela réduit le stockage et le tri dupliqués entre les
  pairs, qui contribuaient à un problème d'épuisement du CPU (voir le [Bulletin
  #324][news324 inv]). Le crédit de relais commence à 420 jetons de transaction et 12 Mo,
  se reconstituant à un rythme de 14 transactions et 20 kB/s pour la file d'attente des pairs entrants. Le solde en nombre est plafonné à
  420 jetons, tandis que le solde en taille peut s'accumuler jusqu'à 50 Mo. Le taux de recharge sortant conserve le multiplicateur de 2,5
  fois décrit dans le [Bulletin #373][news373 rate]. Lorsque la demande de relais dépasse le crédit disponible, les transactions sont
  priorisées par score de minage tout en respectant les dépendances. Les transactions sélectionnées entrent ensuite dans de petites files
  par pair, aléatoires. De nouveaux champs `getnetworkinfo` exposent chaque file d'attente et ses soldes de jetons, et l'option
  `-txsendrate` réservée au débogage permet de tester différents débits en nombre.

- [Bitcoin Core #28463][] augmente le nombre maximal par défaut de connexions de 125 à 200 et ajoute l'option `-inboundrelaypercent` (50 par
  défaut), qui fixe le pourcentage maximal d'emplacements entrants que des pairs relayant des transactions peuvent occuper. Avec onze
  emplacements sortants par défaut, 189 emplacements restent disponibles pour les connexions entrantes, dont au plus 94 peuvent être occupés
  par des pairs relayant des transactions avec le réglage par défaut. Cette limite est appliquée après qu'un pair annonce sa préférence de
  relais et est reverifiée si le pair active plus tard le relais de transactions au moyen de messages [BIP37][]. Cela réserve de la capacité
  pour le relais de blocs à faible bande passante et prépare l'ajout de davantage de connexions sortantes dédiées uniquement au relais de
  blocs, afin d'améliorer la résistance aux [attaques eclipse][topic eclipse attacks].

- [Bitcoin Core #32800][] ajoute des champs explicites de taille de transaction [BIP141][] et ajustés par la politique à plusieurs RPC.
  `vsize_bip141` rapporte la taille virtuelle calculée à partir du poids de la transaction, tandis que `vsize_adjusted` rapporte la plus
  grande de cette valeur ou de la taille impliquée par le coût en sigops de la transaction selon la politique configurée `-bytespersigop`.
  La valeur ajustée est utilisée pour la politique du mempool et les calculs de feerate des modèles de blocs. `getmempoolentry`,
  `getrawmempool` en mode verbeux, `testmempoolaccept`, et `submitpackage` rapportent désormais les deux champs. Le champ `vsize` existant,
  qui était documenté comme étant la taille virtuelle BIP141 mais contenait en réalité la valeur ajustée par la politique, est conservé mais
  marqué comme obsolète. De plus, `getrawtransaction` rapporte `vsize_adjusted` lorsque la transaction est dans le mempool, tandis que son
  champ `vsize` existant reste la valeur BIP141. La sortie verbeuse de `getorphantxs` ajoute également le champ explicite `vsize_bip141`.

- [Bitcoin Core #34683][] ajoute une description [OpenRPC 1.4.1][] générée automatiquement de l'interface RPC. Le nouveau RPC `rpc.discover`
  renvoie l'interface publique, tandis que `getopenrpcinfo` peut inclure optionnellement des commandes et arguments cachés. Le document est
  généré à l'exécution à partir des métadonnées `RPCHelpMan` pour tous les RPC enregistrés, et décrit les paramètres des méthodes, les
  valeurs requises et par défaut, les formes des résultats et d'autres détails de l'interface.

- [Bitcoin Core #33014][] corrige la façon dont `descriptorprocesspsbt` (voir le [Bulletin
  #253][news253 descriptorpsbt]) gère un [PSBT][topic psbt] dont les champs de script
  finalisés sont renseignés mais contiennent des signatures invalides. Auparavant, le RPC vérifiait seulement la présence de scripts finaux,
  marquait le PSBT comme complet, et renvoyait une erreur interne lorsque l'extraction de la transaction échouait. Désormais, il vérifie
  chaque entrée avant de signaler l'achèvement, de sorte qu'un PSBT avec une signature invalide renvoie `complete: false` sans transaction
  sérialisée dans le champ `hex`.

- [Eclair #3325][] accepte des [messages onion][topic onion messages] de facture [BOLT12][topic offers] qui incluent un `reply_path`. Un
  bénéficiaire peut attacher un chemin de réponse [aveuglé][topic rv routing] à une facture afin que le payeur puisse renvoyer un
  `invoice_error` s'il considère la facture invalide. Eclair rejetait auparavant cette combinaison, provoquant des problèmes
  d'interopérabilité avec LDK, qui a ajouté des chemins de réponse aux factures (voir le [Bulletin #321][news321 replypath]).

- [BOLTs #1346][] spécifie les preuves de payeur [BOLT12][topic offers], un format de reçu qui permet [à un payeur de prouver][topic proof
  of payment] qu'il a payé une facture en utilisant la préimage de paiement, la signature du nœud émetteur de la facture, et une signature
  du payeur depuis `invreq_payer_id`, tout en permettant que certains champs de la facture soient omis pour des raisons de confidentialité.
  La spécification assigne le préfixe lisible par l'humain `lnp` et ajoute des vecteurs de test de génération et de vérification. Core
  Lightning a implémenté expérimentalement un brouillon antérieur (voir le [Bulletin #405][news405 proof]).

- [BOLTs #1344][] étend le protocole des [échecs attribuables][topic attributable failures] aux paiements réussis en ajoutant une
  `fulfillment_payload` optionnelle à `update_fulfill_htlc`, le message qui renvoie la préimage de paiement et règle un [HTLC][topic htlc].
  Seul un champ de bourrage est défini, donc la PR établit un transport pour de futures données liées au succès, comme des reçus
  [keysend][topic spontaneous payments] signés, sans encore standardiser d'application.

- [BOLTs #1343][] ajoute le bit de fonctionnalité `option_onion_messages_only_channels` pour les nœuds qui n'acceptent les [messages
  onion][topic onion messages] que de pairs ayant un canal. Les nœuds qui n'annoncent pas cette fonctionnalité devraient accepter les
  messages onion de pairs sans canaux, bien qu'ils puissent toujours les limiter en débit ou les abandonner. Cette fonctionnalité permet aux
  expéditeurs d'éviter des chemins de relais connus pour échouer tout en permettant aux opérateurs de réduire leur exposition aux attaques
  de déni de service. Voir le [Bulletin #409][news409 onion] pour un contournement LDK qui traite le comportement de LND consistant à recevoir
  mais ne pas relayer les messages onion de pairs sans canal.

{% include snippets/recap-ad.md when="2026-08-04 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="8376,8903,35266,34628,28463,32800,34683,33014,3325,1346,1344,1343" %}

[news392 bip110]: /fr/newsletters/2026/02/13/#bips-2017
[news412 migratewallet]: /fr/newsletters/2026/07/03/#bitcoin-core-35266
[stale blocks site]: https://bitcoin-data.github.io/stale-blocks/
[stale blocks repo]: https://github.com/bitcoin-data/stale-blocks
[cln vuln del]:https://delvingbitcoin.org/t/vulnerability-disclosure-twin-memory-exhaustion-dos-vulnerabilities-in-core-lightning/2731
[sob]:https://www.summerofbitcoin.org/
[zkpoh del]: https://delvingbitcoin.org/t/zkpoh-zero-knowledge-proof-of-hodl/2699
[noir lang]: https://noir-lang.org/
[zkpoh gh]: https://github.com/fabohax/zkPoH
[BTCPay Server 2.4.1]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.4.1
[Eclair 0.14.1]: https://github.com/ACINQ/eclair/releases/tag/v0.14.1
[eclair 0.14.1 notes]: https://github.com/ACINQ/eclair/blob/v0.14.1/docs/release-notes/eclair-v0.14.1.md
[OpenRPC 1.4.1]: https://spec.open-rpc.org/
[news415 labels]: /fr/newsletters/2026/07/24/#btcpay-server-7457
[news324 inv]: /fr/newsletters/2024/10/11/#dos-par-ensembles-d-inventaire-importants
[news373 rate]: /fr/newsletters/2025/09/26/#bitcoin-core-28592
[news253 descriptorpsbt]: /fr/newsletters/2023/05/31/#bitcoin-core-25796
[news321 replypath]: /fr/newsletters/2024/09/20/#ldk-3163
[news405 proof]: /fr/newsletters/2026/05/15/#core-lightning-9116
[news409 onion]: /fr/newsletters/2026/06/12/#ldk-4647
[coinkite advisory]: https://blog.coinkite.com/coldcard-mk3-seed-generation-warning/
[coinkite blog]: https://blog.coinkite.com/
[coinkite backgrounder]: https://blog.coinkite.com/entropy-technical-backgrounder/
[block analysis]: https://engineering.block.xyz/blog/predictable-rng-fallback-and-32-bit-reseed-in-coldcard-firmware
