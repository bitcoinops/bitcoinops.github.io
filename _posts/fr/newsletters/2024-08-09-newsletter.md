---
title: 'Bulletin Hebdomadaire Bitcoin Optech #315'
permalink: /fr/newsletters/2024/08/09/
name: 2024-08-09-newsletter-fr
slug: 2024-08-09-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine annonce l'attaque rapide d'exfiltration de seed Dark Skippy, résume
les discussions sur les attaques de rétention de blocs et les solutions proposées, partage des
statistiques sur la reconstruction de blocs compacts, décrit une attaque de remplacement cyclique
contre les transactions avec des sorties pay-to-anchor, mentionne un nouveau BIP spécifiant la
signature de seuil avec FROST, et relaye une annonce d'une amélioration à Eftrace qui lui permet de
vérifier opportunistement les preuves à divulgation nulle de connaissance en utilisant deux propositions
de soft forks.

## Nouvelles

- **Attaque d'exfiltration de seed plus rapide :** Lloyd Fournier, Nick Farrow et Robin Linus ont
  annoncé [Dark Skippy][], une méthode améliorée pour l'exfiltration de clé à partir d'un dispositif
  de signature Bitcoin qu'ils avaient précédemment [divulguée de manière responsable][topic
  responsible disclosures] à environ 15 différents fabricants de dispositifs de signature matérielle.
  L'_exfiltration de clé_ se produit lorsque le code de signature de transaction crée délibérément ses
  signatures de manière à ce qu'elles fuitent des informations sur le matériel de clé sous-jacent, tel
  qu'une clé privée ou une [seed de portefeuille HD BIP32][topic bip32]. Une fois qu'un attaquant
  obtient la seed d'un utilisateur, il peut voler tous les fonds de l'utilisateur à tout moment (y
  compris les fonds dépensés dans la transaction qui résulte en exfiltration, si l'attaquant agit
  rapidement).

  Les auteurs mentionnent que la meilleure attaque d'exfiltration de clé précédente dont ils ont
  connaissance nécessitait des dizaines de signatures pour exfiltrer un seed BIP32. Avec Dark Skippy,
  ils sont maintenant capables d'exfiltrer un seed en deux signatures, qui peuvent toutes deux
  appartenir à une seule transaction avec deux entrées, signifiant que tous les fonds d'un utilisateur
  peuvent être vulnérables dès l'instant où ils essaient de dépenser une partie de leur argent pour la
  première fois.

  L'exfiltration de clé peut être utilisée par n'importe quelle logique qui crée des signatures, y
  compris les portefeuilles logiciels. Cependant, il est généralement attendu qu'un portefeuille
  logiciel avec un code malveillant transmettra simplement sa seed à l'attaquant via Internet.
  L'exfiltration est principalement considérée comme un risque pour les dispositifs de signature
  matérielle qui n'ont pas d'accès direct à Internet. Un dispositif dont la logique a été corrompue,
  que ce soit par son firmware ou sa logique matérielle, peut maintenant rapidement exfiltrer une seed
  même si le dispositif n'est jamais connecté à un ordinateur (par exemple, toutes les données sont
  transférées à l'aide du NFC, de cartes SD ou de QR codes).

  Les méthodes de réalisation de signatures [résistantes à l'exfiltration][topic
  exfiltration-resistant signing] pour Bitcoin ont été discutées (y compris dans les bulletins
  Optech dès le [Bulletin #87][news87 anti-exfil]) et sont actuellement mises en œuvre dans deux
  dispositifs de signature matérielle dont nous avons connaissance (voir le [Bulletin #136][news136
  anti-exfil]). Cette méthode déployée nécessite un aller-retour supplémentaire de communication avec
  le dispositif de signature matérielle par rapport à la signature single-sig standard, bien que cela
  puisse être moins un inconvénient si les utilisateurs s'habituent à d'autres types de signature,
  tels que les [multisignatures sans script][topic multisignature], qui nécessitent également des
  allers-retours supplémentaires de communication. Des méthodes alternatives de signature résistante à
  l'exfiltration qui offrent différents compromis sont également connus, bien qu'aucun n'ait été implémenté
  dans les dispositifs de signature matériel Bitcoin à notre connaissance.

  Optech recommande à toute personne utilisant des dispositifs de signature matérielle pour protéger
  des sommes d'argent substantielles de se prémunir contre le matériel ou le firmware corrompu, soit
  par l'utilisation de signature résistante à l'exfiltration, soit par l'utilisation de plusieurs
  dispositifs indépendants (par exemple, avec une multisignature scriptée ou sans script, ou une
  signature seuil).

- **Attaques de rétention de blocs et solutions potentielles :**
  Anthony Towns a [posté][towns withholding] sur la liste de diffusion Bitcoin-Dev pour discuter de
  l'[attaque de rétention de bloc][topic block withholding], une attaque connexe de _parts invalides_,
  et des solutions potentielles à ces deux attaques, y compris la désactivation de la sélection de
  travail client dans [Stratum v2][topic pooled mining] et les parts à considérer.

  Les mineurs de pool sont payés pour soumettre des unités de travail, appelées _parts_, chacune étant
  un _bloc candidat_ qui contient une certaine quantité de preuve de travail (PoW). L'attente est
  qu'une portion connue de ces parts contiendra également suffisamment de PoW pour rendre leur bloc
  candidat éligible à l'inclusion dans la blockchain la plus PoW. Par exemple, si la cible de PoW de
  la part est 1/1 000<sup>e</sup> de la cible de PoW du bloc valide, le pool s'attend à payer pour 1
  000 parts pour chaque bloc valide qu'il produit en moyenne. Une attaque classique de rétention de
  bloc se produit lorsque un mineur de pool ne soumet pas la part 1 sur 1 000 qui produit un bloc
  valide mais soumet les 999 autres parts qui ne sont pas des blocs valides. Cela permet au mineur
  d'être payé pour 99,9 % de son travail mais empêche le pool de gagner des revenus de ce mineur.

  Stratum v2 inclut un mode optionnel que les pools peuvent activer pour permettre aux mineurs
  d'inclure un ensemble différent de transactions dans leurs blocs candidats que ce que le pool
  suggère de miner. Le mineur de pool peut même tenter de miner des transactions que le pool n'a pas.
  Cela peut rendre coûteuse pour le pool la validation des parts des mineurs : chaque part peut
  contenir jusqu'à plusieurs mégaoctets de transactions que le pool n'a jamais vues auparavant, toutes
  pouvant être conçues pour être lentes à valider. Cela peut facilement submerger l'infrastructure
  d'un pool, affectant sa capacité à accepter des parts d'utilisateurs honnêtes.

  Les pools peuvent éviter ce problème en validant uniquement la PoW de la part, en sautant la
  validation des transactions, mais cela permet à un mineur de pool de collecter un paiement pour la
  soumission de parts invalides 100 % du temps, ce qui est légèrement pire que les environ 99,9 % du
  temps où ils peuvent collecter un paiement d'une attaque classique de rétention de bloc.

  Cela incite les pools à interdire soit la sélection de transactions par le client, soit à exiger que
  les mineurs de pool utilisent une identité publique persistante (par exemple, un nom validé par une
  documentation délivrée par le gouvernement) afin que les mauvais acteurs puissent être bannis.

  Une solution que Towns propose est que les pools fournissent plusieurs modèles de blocs, permettant
  à chaque mineur de choisir son modèle préféré. Cela est similaire au système existant utilisé par
  [Ocean Pool][]. Les parts soumises sur la base de modèles créés par le pool peuvent être validées
  rapidement et avec un minimum de bande passante. Cela empêche l'attaque de parts invalides qui paie
  100 % mais n'aide pas avec les environ 99,9 % du temps.

  Pour faire face à l'attaque de rétention de blocs, Towns met à jour une idée [initialement
  proposée][rosenfeld pool] par Meni Rosenfeld en 2011 qui décrit comment un hard fork
  conceptuellement simple pourrait empêcher un mineur de pool de savoir si une part particulière avait
  suffisamment de PoW pour être un bloc valide, les rendant des _parts aveugles_. Un attaquant qui ne
  peut pas discriminer entre le PoW de bloc valide et le PoW de part ne peut priver un pool de revenus
  de bloc valide qu'au même taux que l'attaquant se prive de revenus de part. L'approche a des
  inconvénients :

  - *Hard fork visible par SPV :* toutes les propositions de hard fork exigent que tous les nœuds
    complets se mettent à jour. Cependant, de nombreuses propositions (telles que les propositions
    simples d'augmentation de la taille de bloc comme [BIP103][]) ne nécessitent pas de mises à jour des
    clients légers qui utilisent la _validation de paiement simplifiée_ (SPV). Cette proposition change
    la manière dont le champ d'en-tête de bloc est interprété et nécessiterait donc que tous les clients
    légers se mettent également à jour. Towns propose toutefois une alternative qui ne nécessiterait pas
    nécessairement que les clients légers se mettent à jour, mais cela réduirait considérablement leur
    sécurité.

  - *Exige que les mineurs de pool utilisent un modèle privé du pool :* non seulement un modèle serait
    nécessaire pour prévenir l'attaque de 100 % de parts invalides, mais le pool devrait garder ce
    modèle secret des mineurs de pool jusqu'à ce que toutes les parts générées à l'aide de ce modèle
    soient reçues. Le pool pourrait utiliser cela pour tromper les mineurs en produisant du PoW pour des
    transactions auxquelles les mineurs s'opposeraient. Cependant, les modèles expirés pourraient être
    publiés pour permettre l'audit. La plupart des pools modernes génèrent un nouveau modèle toutes les
    quelques secondes, donc tout audit pourrait être effectué en temps quasi réel, empêchant un pool
    malveillant de tromper ses mineurs pendant plus de quelques secondes.

  - *Nécessite la soumission de parts :* l'un des avantages de Stratum v2 (dans certains modes de
    fonctionnement) est qu'un mineur de pool honnête qui trouve un bloc pour le pool peut immédiatement
    le diffuser sur le réseau P2P Bitcoin, permettant sa propagation même avant que la part
    correspondante n'atteigne le serveur du pool. Avec les parts à considérer, la part devrait être reçue
    par le pool et convertie en un bloc complet avant de pouvoir être diffusée.

  Towns conclut en décrivant deux des motivations pour corriger l'attaque de rétention de blocs : cela
  affecte plus les petits pools que les grands pools, et cela coûte presque rien d'attaquer les pools
  qui permettent l'anonymat des mineurs, tandis que les pools qui exigent que les mineurs s'identifient
  peuvent bannir les attaquants connus. Corriger la rétention de blocs pourrait aider le minage de
  Bitcoin à devenir plus anonyme et décentralisé.

- **Statistiques sur la reconstruction de blocs compacts :** le développeur 0xB10C [a posté][0xb10c
  compact] sur Delving Bitcoin concernant la fiabilité récente de la reconstruction de [blocs
  compacts][topic compact block relay]. De nombreux nœuds complets de relais utilisent le relais de
  blocs compacts [BIP152][] depuis que la fonctionnalité a été ajoutée à Bitcoin Core 0.13.0 en 2016.
  Cela permet à deux pairs qui ont déjà partagé certaines transactions non confirmées d'utiliser une
  référence courte à ces transactions lorsqu'elles sont confirmées dans un nouveau bloc plutôt que de
  retransmettre l'intégralité de la transaction. Cela réduit considérablement la bande passante et, ce
  faisant, réduit également la latence, permettant aux nouveaux blocs
  de se propager plus rapidement. Une propagation plus rapide des nouveaux blocs diminue le nombre
  de forks accidentels de la blockchain. Moins de forks réduit la quantité de preuve de travail (PoW)
  qui est gaspillée et réduit le nombre de _courses aux blocs_ qui avantagent les grandes pools de
  minage par rapport aux petites, aidant ainsi à rendre Bitcoin plus sécurisé et plus décentralisé.

  Cependant, parfois les nouveaux blocs incluent des transactions qu'un nœud n'a pas encore vues. Dans
  ce cas, le nœud recevant un bloc compact a généralement besoin de demander ces transactions au pair
  émetteur puis d'attendre que le pair réponde. Cela ralentit la propagation du bloc. Tant qu'un nœud
  n'a pas toutes les transactions d'un bloc, ce bloc ne peut pas être validé ou relayé aux pairs. <!--
  https://bitcoin.stackexchange.com/questions/123858/can-a-bip152-compact-block-be-sent-before-validation-by-a-node-that-doesnt-know
  --> Cela augmente la fréquence des forks accidentels de la blockchain, réduit la sécurité PoW et
  augmente la pression vers la centralisation.

  Pour cette raison, il est utile de surveiller à quelle fréquence les blocs compacts fournissent
  toutes les informations nécessaires pour valider immédiatement un nouveau bloc sans qu'aucune
  transaction supplémentaire ne doive être demandée, appelée une _reconstruction réussie_. Gregory
  Maxwell a [récemment rapporté][maxwell reconstruct] une diminution des reconstructions réussies pour
  les nœuds exécutant Bitcoin Core avec ses paramètres par défaut, surtout par rapport à un nœud
  fonctionnant avec le paramètre de configuration `mempoolfullrbf` activé.

  Le post de cette semaine du développeur 0xB10C a résumé le nombre de reconstructions réussies qu'il
  a observées en utilisant ses propres nœuds avec divers paramètres, avec certaines données remontant
  à environ six mois. Les données récentes sur l'effet de l'activation de `mempoolfullrbf` ne
  remontent qu'à environ une semaine, mais elles correspondent au rapport de Maxwell. Cela a aidé à
  motiver la considération d'une [pull request][bitcoin core #30493] pour activer `mempoolfullrbf` par
  défaut dans une prochaine version de Bitcoin Core.

- **Attaque par cycle de remplacement contre pay-to-anchor :** Peter Todd a [posté][todd cycle] sur
  la liste de diffusion Bitcoin-Dev à propos du type de sortie pay-to-anchor (P2A) qui fait partie de
  la proposition des [ancres éphémères][topic ephemeral anchors]. P2A est une sortie de transaction que
  n'importe qui peut dépenser. Cela peut être utile pour le bumping de frais [CPFP][topic
  cpfp]---surtout dans les protocoles multiparties tels que LN. Cependant, le bumping de frais CPFP dans
  LN est actuellement vulnérable à une contrepartie effectuant une [attaque par cycle de
  remplacement][topic replacement cycling] où la contrepartie malveillante effectue un processus en
  deux étapes. Ils [remplacent][topic rbf] d'abord la version d'une transaction d'un utilisateur
  honnête par la version de la même transaction de la contrepartie. Ils remplacent ensuite le
  remplacement par une transaction sans rapport avec la version de la transaction de l'un ou l'autre
  utilisateur. Lorsqu'un canal LN a des [HTLCs][topic htlc] non résolus, un cycle de remplacement
  réussi peut permettre à la contrepartie de voler la partie honnête.

  En utilisant le type de canal par [sorties d'ancrage][topic anchor outputs] actuel de LN, seule une
  contrepartie peut effectuer une attaque par cycle de remplacement. Cependant, Todd souligne que,
  parce que P2A permet à n'importe qui de dépenser la sortie, n'importe qui peut effectuer une attaque
  par cycle de remplacement contre
  les transactions en utilisant cela. Cependant, seul une contrepartie peut économiquement bénéficier de
  l'attaque, donc il n'y a pas d'incitation directe pour les tiers à attaquer les sorties P2A.
  L'attaque peut être gratuite dans le cas où l'attaquant prévoit de diffuser sa propre transaction à
  un taux de frais supérieur à celui de la dépense P2A de l'utilisateur honnête et que l'attaquant
  complète avec succès le cycle de remplacement sans que son état intermédiaire soit confirmé par les
  mineurs. Toutes les atténuations LN déployées existantes contre les attaques de cycle de
  remplacement (voir le [Bulletin #274][news274 cycle mitigate]) seront également efficaces pour
  vaincre le cyclage de remplacement P2A.

- **Proposition de BIP pour les signatures à seuil sans script :** Sivaram Dhakshinamoorthy [a
  posté][dhakshinamoorthy frost] sur la liste de diffusion Bitcoin-Dev pour annoncer la disponibilité
  d'une proposition de [BIP][frost sign bip] pour créer des [signatures à seuil sans script][topic threshold
  signature] pour l'implémentation de [signatures schnorr][topic schnorr signatures] de Bitcoin. Cela
  permet à un ensemble de signataires qui ont déjà effectué une procédure de configuration (par
  exemple, en utilisant [ChillDKG][news312 chilldkg]) de créer de manière sécurisée des signatures qui
  ne nécessitent l'interaction que d'un sous-ensemble dynamique de ces signataires. Les signatures
  sont indiscernables sur la chaîne des signatures schnorr créées par des utilisateurs à signature
  unique et des utilisateurs de multisignature sans script, améliorant la confidentialité et la
  fongibilité.

- **Vérification optimiste des preuves à connaissance nulle en utilisant CAT, MATT et Elftrace :**
  Johan T. Halseth [a posté][halseth zkelf] sur Delving Bitcoin pour annoncer que son outil,
  [Elftrace][], a maintenant la capacité de vérifier les preuves à connaissance nulle (ZK). Pour que
  cela soit utile onchain, les soft forks proposés [OP_CAT][topic op_cat] et [MATT][topic acc]
  devraient être activés.

## Bitcoin Core PR Review Club

*Dans cette section mensuelle, nous résumons une récente réunion du [Bitcoin Core PR Review Club][],
en mettant en lumière certaines des questions et réponses importantes. Cliquez sur une question
ci-dessous pour voir un résumé de la réponse de la réunion.*

[Add PayToAnchor(P2A), OP_1 <0x4e73>, comme script de sortie standard pour dépenser][review club
30352] est une PR de [instagibbs][gh instagibbs] qui introduit un nouveau type de script de sortie
`TxoutType::ANCHOR`. Les sorties d'ancrage ont un script de sortie `OP_1 <0x4e73>` (résultant en une
adresse [`bc1pfeessrawgf`][mempool bc1pfeessrawgf]). Rendre ces sorties standard facilite la
création et la transmission de transactions qui dépensent à partir d'une sortie d'ancrage.

{% include functions/details-list.md
  q0="Avant que `TxoutType::ANCHOR` soit défini dans cette PR, quel `TxoutType` serait classifié comme
  `scriptPubKey` `OP_1 <0x4e73>` ?"
  a0="Puisqu'il consiste en un opcode de poussée de 1 octet (`OP_1`) et un 2 octet
  poussée de données (`0x4e73`), il s'agit d'une sortie témoin v1 valide. Comme elle ne fait pas 32
  octets, elle ne se qualifie pas comme `WITNESS_V1_TAPROOT`, se classant donc par défaut comme
  `TxoutType::WITNESS_UNKNOWN`."
  a0link="https://bitcoincore.reviews/30352#l-18"

  q1="En se basant sur la réponse à la question précédente, serait-il standard de créer ce type de
  sortie ? Qu'en est-il pour la dépenser ? (Indice : comment [`IsStandard`][gh isstandard] et
  [`AreInputsStandard`][gh areinputsstandard] traitent-ils ce type ?)"
  a1="Puisque `IsStandard` (qui est utilisé pour vérifier les sorties) ne considère que
  `TxoutType::NONSTANDARD` comme non standard, le créer serait standard. Puisque `AreInputsStandard`
  considère qu'une transaction qui dépense depuis un `TxoutType::WITNESS_UNKNOWN` est non standard, il
  ne serait pas standard de le dépenser."
  a1link="https://bitcoincore.reviews/30352#l-24"

  q2="Avant cette PR, avec les paramètres par défaut, quels types de sorties peuvent être _créés_ dans
  une transaction standard ? Est-ce la même chose que les types de scripts qui peuvent être _dépensés_
  dans une transaction standard ?"
  a2="Tous les `TxoutType` définis à l'exception de `TxoutType::NONSTANDARD` peuvent être créés. Tous
  les `TxoutType` définis à l'exception de `TxoutType::NONSTANDARD` et `TxoutType::WITNESS_UNKNOWN`
  sont autorisés à être dépensés (bien qu'il soit impossible de dépenser `TxoutType::NULL_DATA`)."
  a2link="https://bitcoincore.reviews/30352#l-42"

  q3="Définissez _sortie ancrée_, sans mentionner les transactions du réseau Lightning (essayez d'être
  plus général)."
  a3="Une sortie ancrée est une sortie supplémentaire créée sur des transactions pré-signées pour
  permettre l'ajout de frais via CPFP au moment de la diffusion. Voir le [sujet des sorties d'ancrage][topic anchor outputs]
  pour plus d'informations."
  a3link="https://bitcoincore.reviews/30352#l-48"

  q4="Pourquoi la taille du script de sortie d'une sortie ancrée est-elle importante ?"
  a4="Un script de sortie volumineux rend la transaction plus coûteuse à relayer et à prioriser."
  a4link="https://bitcoincore.reviews/30352#l-66"

  q5="Combien de bytes virtuels sont nécessaires pour créer et dépenser une sortie P2A ?"
  a5="Créer une sortie P2A nécessite 13 vbytes. La dépenser nécessite 41 vbytes."
  a5link="https://bitcoincore.reviews/30352#l-120"

  q6="Le 3ème commit [ajoute][gh 30352 3rd commit] `if (prevScript.IsPayToAnchor()) return false` à
  `IsWitnessStandard`. Quelle est son utilité, et pourquoi est-ce nécessaire ?"
  a6="Cela garantit qu'une sortie ancrée ne peut être dépensée sans données de témoin. Cela empêche un
  attaquant de prendre une transaction de dépense honnête, d'y ajouter des données de témoin puis de
  la propager avec des frais absolus plus élevés mais un taux de frais plus bas. Cela forcerait
  l'honnête utilisateur à payer des frais de plus en plus élevés pour le remplacer."
  a6link="https://bitcoincore.reviews/30352#l-154"
%}

## Mises à jour et versions candidates

*Nouvelles versions et mises-à-jour candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles sorties ou d'aider à tester les candidats à
la sortie.*

- [Libsecp256k1 0.5.1][] est une sortie mineure pour cette bibliothèque de fonctions
  cryptographiques liées à Bitcoin. Elle modifie la taille par défaut de la table précalculée pour la
  signature afin de correspondre à la valeur par défaut de Bitcoin Core et ajoute un code exemple pour
  l'échange de clés basé sur ElligatorSwift (qui est le protocole utilisé dans [version 2 du transport
  P2P chiffré][topic v2 p2p transport]).

- [BDK 1.0.0-beta.1][] est un candidat à la sortie pour cette bibliothèque destinée à la
  construction de portefeuilles et d'autres applications activées par Bitcoin. le paquet Rust nommé `bdk`
  a été renommé en `bdk_wallet` et les modules de couche inférieure ont été extraits dans
  leurs propres paquets de code, incluant `bdk_chain`, `bdk_electrum`, `bdk_esplora`, et `bdk_bitcoind_rpc`. Le
  paquet `bdk_wallet` "est la première version à offrir une API stable 1.0.0."

## Changements notables dans le code et la documentation

_Changes récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [Serveur
BTCPay][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration de Bitcoin (BIPs)][bips
repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Inquisition Bitcoin][bitcoin
inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #30493][] active [full RBF][topic rbf] comme paramètre par défaut, tout en laissant
  l'option aux opérateurs de nœuds de revenir à opt-in RBF. Full RBF permet le remplacement de toute
  transaction non confirmée, indépendamment du signal [BIP125][bip125 github]. Cela a été une option
  dans Bitcoin Core depuis juillet 2022 (voir le Bulletin [#208][news208 fullrbf]), mais était
  précédemment désactivé par défaut. Pour les discussions sur le fait de rendre full RBF comme paramètre
  par défaut, voir le Bulletin [#263][news263 fullrbf].

- [Bitcoin Core #30285][] ajoute deux algorithmes clés de [linéarisation en cluster][wuille cluster]
  au projet de [mempool en cluster][topic cluster mempool] : `MergeLinearizations` pour combiner deux
  linéarisations existantes, et `PostLinearize` pour améliorer les linéarisations par un traitement
  supplémentaire. Cette PR s'appuie sur le travail discuté dans le bulletin de la semaine dernière
  [#314][news314 cluster].

- [Bitcoin Core #30352][] introduit un nouveau type de sortie, Pay-To-Anchor (P2A), et
  fait établir sa norme de dépense. Ce type de sortie est sans clé (permettant à quiconque de la
  dépenser) et permet des ancres compactes pour le gonflement des frais [CPFP][topic cpfp] résistantes
  à la malléabilité des txid (voir le [Bulletin #277][news277 p2a]). Combiné avec les transactions
  [TRUC][topic v3 transaction relay], cela fait avancer l'implémentation des [ancres éphémères][topic
  ephemeral anchors] pour remplacer les [sorties d'ancrage][topic anchor outputs] LN basées sur la
  règle de relais [à la découpe CPFP][topic cpfp carve out].

- [Bitcoin Core #29775][] ajoute une option de configuration `testnet4` qui définira le réseau sur
  [testnet4][topic testnet] comme spécifié dans [BIP94][]. Testnet4 inclut la correction de plusieurs
  problèmes avec le précédent testnet3 (voir le [Bulletin #306][news306 testnet]). L'option de
  configuration `testnet` existante de Bitcoin Core qui utilise testnet3 reste disponible mais devrait
  être dépréciée et supprimée dans les versions ultérieures.

- [Core Lightning #7476][] se met à jour avec les dernières propositions de mises à jour de la
  spécification [BOLT12][bolt12 spec] en ajoutant le rejet des chemins aveuglés de longueur zéro dans
  les [offres][topic offers] et les demandes de facture. De plus, cela permet à `offer_issuer_id`
  d'être absent dans les offres avec un chemin aveuglé fourni. Dans de tels cas, la clé utilisée pour
  signer la facture est utilisée comme la clé finale du chemin aveuglé, puisqu'il est sûr de supposer
  que l'émetteur de l'offre a accès à cette clé.

- [Eclair #2884][] implémente [BLIP4][] pour l'[approbation HTLC][topic htlc endorsement], devenant
  la première mise en œuvre LN à le faire, pour atténuer partiellement les [attaques de blocage de
  canal][topic channel jamming attacks] sur le réseau. Cette PR permet la transmission optionnelle des
  valeurs d'approbations entrantes, avec les nœuds relais utilisant leur détermination locale de la
  réputation du pair entrant pour décider s'ils doivent inclure une approbation lors de la transmission
  d'un [HTLC][topic htlc] au prochain saut. Si largement adopté par le réseau, les approbations HTLC
  pourraient recevoir un accès préférentiel aux ressources réseau rares telles que la liquidité et
  emplacements HTLC. Cette mise en œuvre s'appuie sur les travaux précédents d'Eclair discutés dans la
  le Bulletin [#257][news257 eclair].

- [LND #8952][] refactorise le composant `channel` dans `lnwallet` pour utiliser la structure `List` typée,
  dans le cadre d'une série de PR mettant en œuvre les engagements dynamiques, un type de [mise à
  niveau de l'engagement de canal][topic channel commitment upgrades].

- [LND #8735][] ajoute la capacité de générer des factures avec des [chemins aveuglés][topic rv
  routing] en utilisant le drapeau `-blind` dans la commande `addinvoice`. Il permet également le
  paiement de telles factures. Notez que cela est uniquement implémenté pour les factures [BOLT11][],
  car [BOLT12][topic offers] n'est pas encore implémenté dans LND. [LND #8764][] étend la PR précédente
  en permettant l'utilisation de plusieurs chemins aveuglés
  lors du paiement d'une facture, spécifiquement pour effectuer des paiements  multi-chemins ([MPP][topic
  multipath payments]).

- [BIPs #1601][] fusionne [BIP94][] pour introduire testnet4, une nouvelle version de
  [testnet][topic testnet] qui inclut des améliorations des règles de consensus visant à prévenir les
  attaques réseau faciles à réaliser. Tous les précédents soft forks du mainnet sont activés dès le
  bloc de genèse dans testnet4, et le port utilisé est par défaut `48333`. Voir les bulletins
  [#306][news306 testnet4] et [#311][news311 testnet4] pour plus de détails sur comment testnet4
  résout les problèmes qui ont conduit à un comportement problématique avec testnet3.

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30493,30285,30352,30562,7476,2884,8952,8735,8764,1601,29775" %}
[BDK 1.0.0-beta.1]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.1
[libsecp256k1 0.5.1]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.5.1
[news274 cycle mitigate]: /fr/newsletters/2023/10/25/#mesures-d-attenuation-deployees-dans-les-noeuds-ln-pour-le-remplacement-cyclique
[dark skippy]: https://darkskippy.com/
[news87 anti-exfil]: /en/newsletters/2020/03/04/#proposal-to-standardize-an-exfiltration-resistant-nonce-protocol
[news136 anti-exfil]: /en/newsletters/2021/02/17/#anti-exfiltration
[towns withholding]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Zp%2FGADXa8J146Qqn@erisian.com.au/
[0xb10c compact]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052
[maxwell reconstruct]: https://github.com/bitcoin/bitcoin/pull/30493#issuecomment-2260918779
[todd cycle]: https://mailing-list.bitcoindevs.xyz/bitcoindev/ZqyQtNEOZVgTRw2N@petertodd.org/
[dhakshinamoorthy frost]: https://mailing-list.bitcoindevs.xyz/bitcoindev/740e2584-5b6c-47f6-832e-76928bf613efn@googlegroups.com/
[frost sign bip]: https://github.com/siv2r/bip-frost-signing
[halseth zkelf]: https://delvingbitcoin.org/t/optimistic-zk-verification-using-matt/1050
[ocean pool]: https://ocean.xyz/blocktemplate
[rosenfeld pool]: https://bitcoil.co.il/pool_analysis.pdf
[elftrace]: https://github.com/halseth/elftrace
[news306 testnet]: /fr/newsletters/2024/06/07/#bip-et-mise-en-oeuvre-experimentale-de-testnet4
[news312 chilldkg]: /fr/newsletters/2024/07/19/#protocole-de-generation-de-cles-distribue-pour-frost
[bip125 github]: https://github.com/bitcoin/bips/blob/master/bip-0125.mediawiki
[news208 fullrbf]: /en/newsletters/2022/07/13/#bitcoin-core-25353
[news263 fullrbf]: /fr/newsletters/2023/08/09/#full-rbf-par-defaut
[wuille cluster]: https://delvingbitcoin.org/t/introduction-to-cluster-linearization/1032
[news314 cluster]: /fr/newsletters/2024/08/02/#bitcoin-core-30126
[bolt12 spec]: https://github.com/lightning/bolts/pull/798
[news257 eclair]: /fr/newsletters/2023/06/28/#eclair-2701
[news306 testnet4]: /fr/newsletters/2024/06/07/#bip-et-mise-en-oeuvre-experimentale-de-testnet4
[news311 testnet4]: /fr/newsletters/2024/07/12/#bitcoin-core-pr-review-club
[news277 p2a]: /fr/newsletters/2023/11/15/#elimination-de-la-malleabilite-des-depenses-d-ancrage-ephemere
[review club 30352]: https://bitcoincore.reviews/30352
[gh instagibbs]: https://github.com/instagibbs
[mempool bc1pfeessrawgf]: https://mempool.space/address/bc1pfeessrawgf
[gh isstandard]: https://github.com/bitcoin/bitcoin/blob/fa0b5d68823b69f4861b002bbfac2fd36ed46356/src/policy/policy.cpp#L7
[gh areinputsstandard]: https://github.com/bitcoin/bitcoin/blob/fa0b5d68823b69f4861b002bbfac2fd36ed46356/src/policy/policy.cpp#L177
[gh 30352 3rd commit]: https://github.com/bitcoin-core-review-club/bitcoin/commit/ccad5a5728c8916f8cec09e838839775a6026293#diff-ea6d307faa4ec9dfa5abcf6858bc19603079f2b8e110e1d62da4df98f4bdb9c0R228-R232
