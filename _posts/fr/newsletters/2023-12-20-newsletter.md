---
title: 'Bulletin Hebdomadaire Bitcoin Optech #282: Revue Spéciale Année 2023'
permalink: /fr/newsletters/2023/12/20/
name: 2023-12-20-newsletter-fr
slug: 2023-12-20-newsletter-fr
type: newsletter
layout: newsletter
lang: fr

excerpt : >
  Cette édition spéciale de la lettre d'information Optech résume les faits marquants de l'évolution du bitcoin pendant toute l'année 2023.
---
{{page.excerpt}} C'est la suite de nos résumés de [2018][yirs 2018], [2019][yirs 2019], [2020][yirs 2020], [2021][yirs 2021] et
[2022][yirs 2022].

## Sommaire

* Janvier
  * [Inquisition Bitcoin](#inquisition)
  * [Swap-in-potentiam](#potentiam)
  * [Format d'exportation d'étiquettes de portefeuille BIP329](#bip329)
* Février
  * [Ordinaux et inscriptions](#ordinals)
  * [Bitcoin Search, ChatBTC et TL;DR](#chatbtc)
  * [Sauvegardes de stockage pair à pair](#peer-storage)
  * [Qualité de service LN](#ln-qos)
  * [Endossement HTLC](#htlc-endorsement)
  * [Codex32](#codex32)
* Mars
  * [Canaux hiérarchiques](#mpchan)
* Avril
  * [Preuves de responsabilité des watchtowers](#watchaccount)
  * [Route aveugle](#route-blinding)
  * [MuSig2](#musig2)
  * [RGB et Taproot Assets](#clientvalidation)
  * [Splicing de canal](#splicing)
* Mai
  * [Spécifications LSP](#lspspec)
  * [Payjoin](#payjoin)
  * [Ark](#ark)
* Juin
  * [Paiements silencieux](#silentpayments)
* Juillet
  * [Validating Lightning Signer](#vls)
  * [Réunion des développeurs LN](#ln-meeting)
* Août
  * [Messages Onion](#onion-messages)
  * [Preuves de sauvegarde obsolètes](#backup-proofs)
  * [Canaux taproot simples](#tapchan)
* Septembre
  * [Transactions Bitcoin compressées](#compressed-txes)
* Octobre
  * [Basculement et division des paiements](#pss)
  * [Sidepools](#sidepools)
  * [AssumeUTXO](#assumeutxo)
  * [Transport P2P version 2](#p2pv2)
  * [Miniscript](#miniscript)
  * [Compression d'état et BitVM](#statebitvm)
* Novembre
  * [Offres](#offers)
  * [Publicités de liquidité](#liqad)
* Décembre
  * [Mempool en cluster](#clustermempool)
  * [Warnet](#warnet)
* Résumés en vedette
  * [Propositions de soft fork](#softforks)
  * [Divulgations de sécurité](#security)
  * [Mises à jour majeures des principaux projets d'insfrastructure](#releases)
  * [Bitcoin Optech](#optech)

## Janvier

{:#inquisition}
Anthony Towns a [annoncé][jan inquisition] Bitcoin Inquisition, un fork logiciel de Bitcoin Core conçu pour être utilisé sur le signet
par défaut afin de tester les propositions de soft fork et autres changements de protocole importants.
À la fin de l'année, il prenait en charge : [SIGHASH_ANYPREVOUT][topic sighash_anyprevout],
[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify], et les bases des [ancres éphémères][topic ephemeral anchors], avec des PR
ouvertes dans son référentiel pour ajouter le support de [OP_CAT][], `OP_VAULT`, et la [restriction contre les transactions de 64
octets][topic consensus cleanup].

{:#potentiam}
ZmnSCPxj et Jesse Posner ont [proposé][jan potentiam] _swap-in-potentiam_, une méthode non interactive pour ouvrir des canaux du réseau
Lightning, en répondant aux défis auxquels sont confrontés les portefeuilles souvent hors ligne, comme ceux des appareils mobiles.
Un client peut recevoir des fonds dans une transaction on-chain tout en étant hors ligne. La transaction peut recevoir suffisamment de
confirmations pour qu'il soit immédiatement sûr d'ouvrir un canal avec un pair pré-sélectionné lorsque le client revient en ligne---sans
avoir à faire confiance à ce pair. Quelques mois seulement après la proposition, au moins un portefeuille LN populaire <!-- Phoenix -->
utilisait une implémentation de cette méthode.

{:#bip329}
Un format standard pour l'exportation et l'importation des [étiquettes de portefeuille][topic wallet labels] a été [assigné][jan bip329]
à l'identifiant [BIP329][]. Non seulement cette norme facilite la sauvegarde des données importantes du portefeuille qui ne peuvent pas
être récupérées à partir d'une [graine BIP32][topic bip32], mais elle facilite également la copie des métadonnées de transaction dans
des programmes non liés aux portefeuilles, tels que des logiciels de comptabilité. À la fin de l'année, plusieurs portefeuilles avaient
mis en œuvre l'exportation BIP329.

## Février

{:#ordinals}
Février a vu le [début][feb ord1] d'une [discussion][feb ord2] qui se poursuivrait tout au long de l'année sur les Ordinaux et les
Inscriptions, deux protocoles liés permettant d'associer du sens et des données aux sorties de transaction. Andrew Poelstra a résumé la
position de nombreux développeurs de protocoles : "il n'y a pas de moyen sensé d'empêcher les gens de stocker des données arbitraires
dans les témoins sans inciter à un comportement encore pire et/ou enfreindre des cas d'utilisation légitimes." Étant donné que la méthode
utilisée par les Inscriptions permet de stocker de grandes quantités de données, Christopher Allen a suggéré d'augmenter la limite de
83 octets de stockage de données dans Bitcoin Core pour les sorties préfixées par `OP_RETURN` ; une proposition qui a également été
[avancée][aug opreturn] par Peter Todd plus tard dans l'année.

{:#chatbtc}
BitcoinSearch.xyz a été [lancé][feb bitcoinsearch] tôt dans l'année, fournissant un moteur de recherche pour la documentation technique
et les discussions sur Bitcoin. À la fin de l'année, le site proposait une [interface de chat][chatbtc] et des [résumés][tldr] des
discussions récentes.

{:#peer-storage}
Core Lightning a [ajouté][feb storage] un support expérimental pour les sauvegardes de stockage entre pairs, qui permettent à un nœud
de stocker un petit fichier de sauvegarde chiffré pour ses pairs. Si un pair a besoin de se reconnecter ultérieurement, peut-être après
une perte de données, il peut demander le fichier de sauvegarde. Le pair peut utiliser une clé dérivée de sa graine de portefeuille pour
déchiffrer le fichier et utiliser son contenu pour récupérer l'état le plus récent de tous ses canaux.

{:#ln-qos}
Joost Jager a [proposé][feb lnflag] un indicateur de "haute disponibilité" pour les canaux LN, permettant au canal de signaler qu'il
offre un acheminement de paiement fiable. Christian Decker a souligné les défis liés à la création de systèmes de réputation, tels que
les rencontres peu fréquentes entre nœuds. Une approche alternative précédemment proposée a également été mentionnée :
[trop-perçu avec recouvrement][topic redundant overpayments] (précédemment appelés boomerang ou trop-perçus remboursables), où les
paiements sont divisés et envoyés via plusieurs canaux, réduisant la dépendance aux canaux très disponibles.

{:#htlc-endorsement}
Les idées d'un [document][jamming paper] publié l'année dernière ont été particulièrement
au centre des efforts de 2023 pour atténuer les [attaques de brouillage de canal LN][topic channel jamming attacks]. En février, Carla
Kirk-Cohen et Clara Shikhelman, co-auteures du document,
ont [sollicité][feb htlcendo] des commentaires sur les paramètres à utiliser lors de la mise en œuvre de
[l'approbation HTLC][topic htlc endorsement]. En avril, elles ont [publié][apr htlcendo] une spécification provisoire
pour leurs plans de test. En juillet, l'idée et la proposition ont été [discutées][jul htlcendo] lors de la réunion de développement LN,
ce qui a conduit à un échange sur la liste de diffusion concernant une [approche alternative][aug antidos] visant à faire en sorte que
les coûts supportés à la fois par les attaquants et les utilisateurs honnêtes reflètent les coûts sous-jacents supportés par les
opérateurs de nœuds fournissant le service ; de cette façon, un opérateur de nœud qui réalise un retour raisonnable en fournissant des
services aux utilisateurs honnêtes continuera à réaliser des retours raisonnables si les attaquants commencent à utiliser ces services.
En août, il a été [annoncé][aug htlcendo] que les développeurs associés à Eclair, Core Lightning et LND mettaient tous en œuvre des
parties du protocole d'approbation HTLC afin de commencer à collecter des données y relatives.

{:#codex32}
Russell O'Connor et Andrew Poelstra ont [proposé][feb codex32] un nouveau BIP pour sauvegarder et restaurer les graines [BIP32][] appelé
[codex32][topic codex32]. Similaire à SLIP39, il permet de créer plusieurs parts en utilisant le schéma de partage de secret de Shamir
avec des exigences de seuil configurables. Un attaquant qui obtient moins que le nombre de parts requis n'apprendra rien sur la graine.
Contrairement aux autres codes de récupération qui utilisent une liste de mots, codex32 utilise le même alphabet que les adresses
[bech32][topic bech32]. Le principal avantage de codex32 par rapport aux schémas existants est sa capacité à effectuer toutes les
opérations manuellement à l'aide d'un stylo, d'un papier, d'instructions et de découpages en papier, y compris la génération d'une graine
encodée (avec des dés), sa protection par une somme de contrôle, la création de parts avec somme de contrôle, la vérification des sommes
de contrôle et la récupération de la graine. Cela permet aux utilisateurs de vérifier périodiquement l'intégrité des parts individuelles
sans avoir recours à des dispositifs informatiques de confiance.

## Mars

{:#mpchan}
En mars, le développeur pseudonyme John Law a [publié][mar mpchan] un
document décrivant une façon de créer une hiérarchie de canaux pour plusieurs
utilisateurs à partir d'une seule transaction sur la chaîne. La conception permet
à tous les utilisateurs en ligne de dépenser leurs fonds même lorsque certains de leurs contreparties de canal sont hors ligne, ce qui
n'est pas actuellement possible dans LN. Cette optimisation permettrait aux utilisateurs toujours en ligne d'utiliser leur capital de
manière plus efficace, réduisant ainsi probablement les coûts pour les autres utilisateurs de LN. La proposition dépend du protocole de
pénalité réglable de Law, qui n'a connu aucun développement logiciel public depuis sa proposition en 2022.

![Protocole de pénalité réglable](/img/posts/2023-03-tunable-commitment.dot.png)

<div markdown="1" class="callout" id="softforks">

### Résumé 2023<br>Propositions de soft fork

Une [proposition][jan op_vault] pour un nouvel opcode `OP_VAULT` a été publiée en Janvier par James O'Beirne, suivi en
[février][feb op_vault] par un projet de BIP pour l'Inquisition Bitcoin. Cela a été suivi quelques semaines plus tard par une
[proposition][feb op_vault2] pour une conception alternative de `OP_VAULT` par Gregory Sanders.

La proposition "merklize all the things" (MATT), décrite pour la première fois l'année dernière, a connu une activité cette année.
Salvatore Ingala a [montré][may matt] comment elle pourrait fournir la plupart des fonctionnalités des opcodes `OP_VAULT` proposés.
Johan Torås Halseth a ensuite [démontré][jun matt] comment l'un des opcodes de la proposition MATT pouvait reproduire les fonctions
clés de l'opcode proposé `OP_CHECKTEMPLATEVERIFY`, bien que la version MATT soit moins efficace en termes d'espace. Halseth en a
également profité pour présenter aux lecteurs un outil qu'il avait développé, [tapsim][], qui permet de déboguer les transactions
Bitcoin et les [tapscript][topic tapscript].

En [j]uin][jun specsf], Robin Linus a décrit comment les utilisateurs pouvaient verrouiller des fonds aujourd'hui, les utiliser sur
une sidechain pendant longtemps, puis permettre aux destinataires des fonds sur la sidechain de les retirer efficacement sur Bitcoin
ultérieurement---mais seulement si les utilisateurs de Bitcoin décident finalement de modifier les règles de consensus d'une
certaine manière.
Cela pourrait permettre aux utilisateurs désireux de prendre un risque financier de commencer immédiatement à utiliser leurs fonds avec
les nouvelles fonctionnalités de consensus qu'ils désirent, tout en offrant un moyen de faire revenir ces fonds plus tard sur le mainnet
de Bitcoin.

En août, Brandon Black a [proposé][aug combo] une version de `OP_TXHASH` combinée avec [`OP_CHECKSIGFROMSTACK`][topic
op_checksigfromstack] qui fournirait la plupart des fonctionnalités de [`OP_CHECKTEMPLATEVERIFY`][topic op_checktemplateverify] (CTV) et
[`SIGHASH_ANYPREVOUT`][topic sighash_anyprevout] (APO) sans coût supplémentaire important sur la chaîne par rapport à ces propositions
individuelles.

En septembre, John Law a [suggéré][sep lnscale] d'améliorer la scalabilité de LN en utilisant des covenants. Il utilise une construction
similaire aux [channel factories][topic channel factories] et au protocole Ark proposé pour potentiellement financer des millions de
canaux off-chain, qui peuvent être récupérés par le financeur de l'usine après expiration, les utilisateurs retirant leurs fonds via
LN au préalable. Ce modèle permet de déplacer des fonds entre les usines sans interaction de l'utilisateur, réduisant ainsi le risque
de congestion de dernière minute sur la chaîne et les frais de transaction. Anthony Towns a soulevé des préoccupations concernant le
problème de _forced expiration flood_, où l'échec d'un grand utilisateur pourrait entraîner de nombreuses transactions on-chain
simultanément. Law a répondu en précisant qu'il travaille sur une solution pour retarder l'expiration pendant les périodes de frais de
transaction élevés.

Octobre a commencé avec Steven Roose [publiant][oct txhash] un projet de BIP pour un nouvel opcode OP_TXHASH. L'idée de l'opcode a déjà
été discutée, mais c'est la première spécification de l'idée. En plus de décrire précisément le fonctionnement de l'opcode, il a examiné
certains inconvénients, tels que la possibilité pour les nœuds complets de devoir hasher plusieurs mégaoctets de données à chaque
invocation de l'opcode. Le projet de BIP comprenait une implémentation d'exemple de l'opcode.

Également en octobre, Rusty Russell a [étudié][oct generic] les covenants génériques avec des modifications minimales du langage de
script de Bitcoin et Ethan Heilman a [publié][oct op_cat] un projet de BIP visant à ajouter un opcode [OP_CAT][op_cat] qui permettrait
de concaténer deux éléments de la pile. La discussion sur ces deux sujets se [poursuivra][nov cov] jusqu'en novembre.

Avant la fin de l'année, Johan Torås Halseth [suggérerait][nov htlcagg] que des soft forks de style covenant pourraient permettre
l'agrégation de plusieurs [HTLCs][topic htlc] en une seule sortie qui pourrait être dépensée en une seule fois si une partie connaissait
toutes les préimages. Si une partie ne connaissait que certaines des préimages, elle pourrait réclamer uniquement celles-ci, puis le
solde restant pourrait être remboursé à l'autre partie. Cela serait plus efficace on-chain et pourrait rendre plus difficile la
réalisation de certains types d'[attaques par brouillage de canal][topic channel jamming attacks].

</div>
## Avril

{:#watchaccount}
Sergi Delgado Segura [a proposé][apr watchtower] un mécanisme de responsabilité pour les [watchtowers][topic watchtowers] dans les cas
où ils ne répondent pas aux violations de protocole qu'ils étaient capables de détecter. Par exemple, Alice fournit à une watchtower des
données pour détecter et répondre à la confirmation d'un ancien état de canal LN ; plus tard, cet état est confirmé mais la watchtower
ne répond pas. Alice souhaite pouvoir tenir l'opérateur de la watchtower responsable en prouvant publiquement qu'il n'a pas répondu de
manière appropriée. Delgado suggère un mécanisme basé sur des accumulateurs cryptographiques que les watchtowers peuvent utiliser pour
créer des engagements et que les utilisateurs peuvent ensuite utiliser pour produire des preuves de responsabilité en cas de violation.

{:#route-blinding}
[Routage aveugle][topic rv routing], décrit pour la première fois trois ans auparavant, a été [ajouté][apr blinding] à la spécification LN
en avril. Il permet à un destinataire de fournir à celui qui dépense l'identifiant d'un nœud de routage particulier et un chemin chiffré en
oignon de ce nœud jusqu'au nœud du destinataire. L'émetteur transmet un paiement et les informations de chemin chiffré au nœud de
routage sélectionné ; le nœud de routage déchiffre les informations pour le prochain saut ; ce prochain saut déchiffre le saut suivant ;
et ainsi de suite, jusqu'à ce que le paiement arrive au nœud du destinataire sans que l'émetteur ni aucun des nœuds de routage ne
sachent (avec certitude) quel nœud appartenait au destinataire. Cela améliore considérablement la confidentialité de la réception
d'argent via LN.

{:#musig2}
[BIP327][] a été [attribué][apr musig2] au protocole [MuSig2][topic musig] pour la création de [multisignatures sans script][topic
multisignature] en avril. Ce protocole serait mis en œuvre dans plusieurs programmes et systèmes au cours de l'année, notamment le RPC
[signrpc][apr signrpc] de LND <!-- sic -->, le service [Loop][apr loop] de Lightning Lab, le service de [multisignature][apr bitgo] de
BitGo, les [canaux taproot simples expérimentaux][apr taproot channels] de LND, et un [projet de BIP][apr musig2 psbt] pour étendre les
[PSBT][topic psbt].

{:#clientvalidation}
Maxim Orlovsky a [annoncé][apr rgb] la sortie de RGB v0.10 en avril, une nouvelle version de ce protocole permettant la création et le
transfert de jetons (entre autres choses) à l'aide de contrats définis et [validés][topic client-side validation] off-chain. Les
modifications de l'état du contrat (par exemple, les transferts) sont associées aux transactions on-chain sont effectuées de manière à
ne pas utiliser d'espace supplémentaire dans les blocs par rapport à une transaction typique et à garder toutes les informations sur
l'état du contrat (y compris son existence) complètement privées vis-à-vis des tiers. Plus tard dans l'année, le protocole Taproot
Assets, qui est en partie dérivé de RGB, a publié des [spécifications][sept tapassets] destinées à devenir des BIP.

{:#splicing}
En avril, il y a également eu d'importantes [discussions][apr splicing] sur le protocole proposé pour le [splicing][topic splicing],
qui permet aux nœuds de continuer à utiliser un canal tout en ajoutant ou en retirant des fonds. Cela est particulièrement utile pour
conserver des fonds dans un canal tout en permettant des paiements instantanés on-chain à partir de ce solde, ce qui permet à une
interface utilisateur de portefeuille d'afficher aux utilisateurs un solde unique à partir duquel ils peuvent effectuer des paiements
on-chain ou off-chain. À la fin de l'année, Core Lightning et Eclair prendraient tous deux en charge le "splicing".

![Splicing](/img/posts/2023-04-splicing1.dot.png)

## Mai

{:#lspspec}
Un ensemble de spécifications préliminaires pour les fournisseurs de services Lightning (LSP) a été publié en [mai][may lsp]. Les normes
facilitent la connexion d'un client à plusieurs LSP, ce qui évite le verrouillage du fournisseur et améliore la confidentialité. La
première spécification publiée décrit une API permettant à un client d'acheter un canal auprès d'un LSP, ce qui permet d'obtenir une
fonctionnalité similaire aux [publicités de liquidité][topic liquidity advertisements]. La deuxième décrit une API pour la configuration
et la gestion des canaux [just-in-time (JIT)][topic jit channels].

{:#payjoin}
Dan Gould a consacré une partie importante de l'année à l'amélioration du protocole [payjoin][topic payjoin], une technique améliorant
la confidentialité qui rend beaucoup plus difficile pour une tierce partie d'associer de manière fiable les entrées et les sorties d'une
transaction avec l'émetteur ou le destinataire. En février, il a [proposé][feb payjoin] un protocole payjoin sans serveur qui peut être
utilisé même si le destinataire n'exploite pas de serveur HTTPS toujours actif sur une interface réseau publique. En mai, il a
[discuté][may payjoin] de plusieurs applications avancées utilisant payjoin, notamment des variations de "payment cut-through".
Par exemple, au lieu qu'Alice paie Bob, Alice paie plutôt le fournisseur de Bob (Carol), réduisant ainsi une dette qu'il lui doit
(ou prépayant une facture future attendue)---cela permet d'économiser de l'espace dans les blocs et améliore encore la confidentialité
par rapport à un payjoin standard. En août, il a publié un [projet de BIP][aug payjoin] pour un payjoin sans serveur qui ne nécessite
pas que l'émetteur et le destinataire soient en ligne en même temps (bien que chacun d'eux devra se connecter au moins une fois après
l'initiation de la transaction avant qu'elle ne puisse être diffusée). Tout au long de l'année, il a été l'un des principaux
contributeurs au [kit de développement payjoin][jul pdk] (PDK) ainsi qu'au projet [payjoin-cli][dec payjoin] qui fournit une extension
pour créer des "payjoins" avec Bitcoin Core.

{:#ark}
Burak Keceli a [proposé][may ark] un nouveau protocole de type [joinpool][topic joinpools] appelé Ark, où les propriétaires de Bitcoin
peuvent choisir d'utiliser une contrepartie comme co-signataire sur toutes les transactions pendant une certaine période de temps.
Les propriétaires peuvent soit retirer leurs bitcoins on-chain après l'expiration du verrouillage temporel, soit les transférer off-chain
instantanément et de manière fiable à la contrepartie avant l'expiration du verrouillage temporel. Le protocole fournit un
protocole de transfert atomique sans confiance à un seul saut et à une seule direction, du propriétaire à la contrepartie, pour diverses
utilisations telles que le mélange de pièces, les transferts internes et le paiement des factures LN. Des préoccupations ont été
soulevées concernant l'empreinte élevée sur la chaîne et la nécessité pour l'opérateur de conserver une grande quantité de fonds dans
un portefeuille chaud par rapport à LN. Cependant, plusieurs développeurs sont restés enthousiastes à propos du protocole proposé et
de son potentiel à offrir une expérience simple et sans confiance à ses utilisateurs.

## Juin

{:#silentpayments}
Josie Baker et Ruben Somsen ont [publié][jun sp] un projet de BIP pour les [paiements silencieux][topic silent payments], un type de
code de paiement réutilisable qui produira une adresse unique on-chain à chaque utilisation, empêchant la [liaison des
sorties][topic output linking]. La liaison des sorties peut réduire considérablement la confidentialité des utilisateurs (y compris
les utilisateurs qui ne sont pas directement impliqués dans une transaction). Le projet détaille les avantages de la proposition,
ses compromis et comment le logiciel peut l'utiliser efficacement. Des travaux en cours pour implémenter des paiements silencieux
pour Bitcoin Core ont également été [discutés][aug sp] lors d'une réunion du Bitcoin Core PR Review Club.

<div markdown="1" class="callout" id="security">

### Résumé 2023<br>Vulnérabilités de sécurité

Optech a signalé trois vulnérabilités de sécurité importantes cette année :

- [Vulnérabilité Milk Sad dans Libbitcoin `bx`][aug milksad] : un manque d'entropie largement non documenté dans une commande suggérée
  pour la création de portefeuilles a finalement conduit au vol d'un nombre important de bitcoins dans plusieurs portefeuilles.

- [Attaque de déni de service contre les nœuds LN][aug fundingdos] : une attaque de déni de service a été découverte en privé et
  [signalée de manière responsable][topic responsible disclosures] par Matt Morehouse. Tous les nœuds concernés ont pu se mettre
  à jour et, à l'heure actuelle, nous ne sommes pas au courant de l'exploitation de la vulnérabilité.

- [Attaque de remplacement cyclique contre les HTLC][oct cycling] : une attaque de vol de fonds contre les [HTLC][topic htlc] utilisés
  dans LN et éventuellement d'autres protocoles a été découverte en privé et signalée de manière responsable par Antoine Riard. Toutes
  les implémentations LN suivies par Optech ont déployé des mesures d'atténuation, bien que l'efficacité de ces mesures ait fait l'objet
  de discussions et d'autres mesures d'atténuation aient été proposées.

</div>

## Juillet

{:#vls}
Le projet Validating Lightning Signer (VLS) a publié sa première version bêta en [juillet][jul vls]. Le projet permet la séparation
d'un nœud LN des clés qui contrôlent ses fonds. Un nœud LN fonctionnant avec VLS routera les demandes de signature vers un dispositif
de signature distant au lieu des clés locales. La version bêta prend en charge CLN et LDK, les règles de validation de la couche 1 et
de la couche 2, les capacités de sauvegarde et de récupération, et fournit une implémentation de référence.

{:#ln-meeting}
[Une réunion][jul summit] de développeurs LN qui s'est tenue en juillet a abordé divers sujets, notamment la confirmation fiable des
transactions au niveau de base, les canaux [taproot][topic taproot] et [MuSig2][topic musig], les annonces de canal mises à jour, les
[PTLC][topic ptlc] et [les paiements en trop redondants][topic redundant overpayments], les propositions d'atténuation des [attaques
de blocage de canal[topic channel jamming attacks], les engagements simplifiés et le processus de spécification. D'autres discussions
LN ont eu lieu à la même époque incluant un [netoyage][jul cleanup] des specifications LN pour supprimer des fonctionnalités
inutiliséeset un [protocole simplifié][jul lnclose] pour fermer les canaux.

## Août

{:#onion-messages}
Le support des [messages onion][topic onion messages] a été ajouté à la spécification LN en août. Les messages onion permettent d'envoyer
des messages unidirectionnels à travers le réseau. Comme les paiements ([HTLC][topic htlc]), les messages utilisent un chiffrement en
onion de sorte que chaque nœud de transfert ne sait pas de quel pair il a reçu le message et quel pair devrait recevoir le message
ensuite. Les charges utiles des messages sont également chiffrées de sorte que seul le destinataire final puisse les lire. Les messages
en onion utilisent des [chemins aveugles][topic rv routing], qui ont été ajoutés à la spécification LN en avril, et les messages en
onion sont eux-mêmes utilisés par la propostion de [protocole des offres][topic offers].

{:#backup-proofs}
Thomas Voegtlin a [proposé][aug fraud] un protocole qui permettrait de pénaliser les fournisseurs qui proposent des états de sauvegarde
obsolètes aux utilisateurs. Ce service implique un mécanisme simple où un utilisateur, Alice, sauvegarde des données avec un numéro
de version et une signature auprès de Bob. Bob ajoute un nonce et s'engage à conserver les données complètes avec une signature
horodatée. Si Bob fournit des données obsolètes, Alice peut générer une preuve de fraude montrant que Bob a précédemment signé un
numéro de version supérieur. Ce mécanisme n'est pas spécifique à Bitcoin, mais l'incorporation de certaines opcodes Bitcoin pourrait
permettre son utilisation on-chain. Dans un canal du Lightning Network (LN), cela permettrait à Alice de réclamer tous les fonds du
canal si Bob fournissait une sauvegarde obsolète, réduisant ainsi le risque que Bob trompe Alice et lui vole son solde. La proposition
a suscité d'importantes discussions. Peter Todd a souligné sa polyvalence au-delà du LN et a suggéré un mécanisme plus simple sans
preuves de fraude, tandis que Ghost43 a souligné l'importance de telles preuves lorsqu'il s'agit de pairs anonymes.

{:#tapchan}
LND a ajouté un [support expérimental][aug lnd taproot] pour les "canaux taproot simples", permettant aux transactions de financement et
d'engagement du LN d'utiliser [P2TR][topic taproot] avec le support de la [multisignature sans script][topic multisignature] de
[MuSig2][topic musig] lorsque les deux parties coopèrent. Cela réduit le poids des transactions et améliore la confidentialité lorsque
les canaux sont fermés de manière coopérative. LND continue d'utiliser exclusivement les [HTLC][topic htlc], permettant aux paiements
commençant dans un canal taproot d'être transférés à travers d'autres nœuds LN qui ne prennent pas en charge les canaux taproot.

## Septembre

{:#compressed-txes}
En septembre, Tom Briar a [publié][sept compress] une spécification et une implémentation préliminaires des transactions Bitcoin
compressées. La proposition aborde le défi de la compression des données uniformément distribuées dans les transactions Bitcoin en
remplaçant les représentations entières par des entiers de longueur variable, en utilisant la hauteur et l'emplacement du bloc pour
référencer les transactions au lieu de leur txid de sortie, et en omettant les clés publiques des transactions P2WPKH. Bien que le
format compressé permette de gagner de l'espace, le convertir en un format utilisable nécessite plus de CPU, de mémoire et d'E/S que
le traitement des transactions sérialisées régulières, ce qui est un compromis acceptable dans des situations telles que la diffusion
par satellite ou le transfert stéganographique.

<div markdown="1" class="callout" id="releases">

### Résumé 2023<br>Mises à jour majeures des principaux projets d'infrastructure

- [Eclair 0.8.0][jan eclair] a ajouté la prise en charge des [canaux sans confirmation][topic zero-conf channels] et des alias
  d'identifiant de canal court (SCID).

- [HWI 2.2.0][jan hwi] a ajouté la prise en charge des dépenses de chemin de clé [P2TR][topic taproot] utilisant le dispositif de
  signature matérielle BitBox02.

- [Core Lightning 23.02][mar cln] a ajouté la prise en charge expérimentale du stockage des données de sauvegarde par les pairs et a
  mis à jour la prise en charge expérimentale du [financement double][topic dual funding] et des [offres][topic offers].

- [Rust Bitcoin 0.30.0][mar rb] a apporté un grand nombre de modifications à l'API, ainsi que l'annonce d'un nouveau site web.

- [LND v0.16.0-beta][apr lnd] a fourni une nouvelle version majeure de cette implémentation LN populaire.

- [Libsecp256k1 0.3.1][apr secp] a corrigé un problème lié au code qui aurait dû s'exécuter en temps constant mais ne l'a pas fait
  lorsqu'il était compilé avec Clang version 14 ou supérieure.

- [LDK 0.0.115][apr ldk] a inclus davantage de prise en charge du protocole expérimental des [offres][topic offers] et a amélioré la
  sécurité et la confidentialité.

- [Core Lightning 23.05][may cln] a inclus la prise en charge des [paiements masqués][topic rv routing], des [PSBT][topic psbt] de
  version 2 et d'une gestion des frais de transaction plus flexible.

- [Bitcoin Core 25.0][may bcc] a ajouté un nouveau RPC `scanblocks`, simplifié l'utilisation de `bitcoin-cli`, ajouté la prise en charge
  de [miniscript][topic miniscript] au RPC `finalizepsbt`, réduit l'utilisation de mémoire par défaut avec l'option de configuration
  `blocksonly` et accéléré les rescans de portefeuille lorsque les [filtres de bloc compacts][topic compact block filters] sont activés.

- [Eclair v0.9.0][jun eclair] était une version qui "contient beaucoup de travaux préparatoires pour des fonctionnalités Lightning
  importantes (et complexes) : [financement double][topic dual funding], [splicing][topic splicing] et [offres][topic offers] BOLT12".

- [HWI 2.3.0][jul hwi] a ajouté la prise en charge des appareils DIY Jade et un binaire pour exécuter le programme principal hwi sur du
  matériel Apple Silicon avec MacOS 12.0+.

- [LDK 0.0.116][jul ldk] a inclus la prise en charge des [sorties d'ancrage][topic anchor outputs] et des [paiements multipath][topic
  multipath payments] avec [keysend][topic spontaneous payments].

- [BTCPay Server 1.11.x][aug btcpay] a inclus des améliorations pour les rapports de facturation, des mises à niveau supplémentaires du
  processus de paiement et de nouvelles fonctionnalités pour le terminal de point de vente.

- [BDK 0.28.1][aug bdk] a ajouté un modèle pour utiliser les chemins de dérivation [BIP86][] pour [P2TR][topic taproot] dans les
  [descripteurs][topic descriptors].

- [Core Lightning 23.08][aug cln] a inclus la possibilité de modifier plusieurs paramètres de configuration sans redémarrer le nœud,
  la prise en charge du format de sauvegarde et de restauration de la graine [codex32][topic codex32], un nouveau plugin expérimental
  pour une meilleure recherche de chemin de paiement, la prise en charge expérimentale du [splicing][topic splicing] et la possibilité
  de payer des factures générées localement.

- [Libsecp256k1 0.4.0][sep secp] a ajouté un module avec une implémentation de l'encodage ElligatorSwift, qui serait ensuite utilisé
  pour le [protocole de transport P2P v2][topic v2 p2p transport].

- [LND v0.17.0-beta][oct lnd] a inclus une prise en charge expérimentale des "canaux taproot simples", ce qui permet d'utiliser des
  [canaux non annoncés][topic unannounced channels] financés on-chain à l'aide d'une sortie [P2TR][topic taproot]. Il s'agit de la
  première étape vers l'ajout d'autres fonctionnalités aux canaux LND, telles que la prise en charge des actifs Taproot et des
  [PTLC][topic ptlc]. La version inclut également une amélioration significative des performances pour les utilisateurs du backend
  Neutrino, qui utilise des [filtres de bloc compacts][topic compact block filters], ainsi que des améliorations de la fonctionnalité
  de [watchtower][topic watchtowers] intégrée à LND.

- [LDK 0.0.117][oct ldk] a inclus des correctifs de bugs de sécurité liés aux fonctionnalités de [sortie d'ancrage][topic anchor outputs]
  incluses dans la version précédente. La version a également amélioré la recherche de chemin, amélioré la prise en charge des
  [watchtowers][topic watchtowers] et activé le [financement par lots][topic payment batching] de nouveaux canaux.

- [LDK 0.0.118][nov ldk] a inclus une prise en charge expérimentale partielle du protocole des [offres][topic offers].

- [Core Lightning 23.11][nov cln] a offert une flexibilité supplémentaire au mécanisme d'authentification _rune_, amélioré la
  vérification des sauvegardes et ajouté de nouvelles fonctionnalités pour les plugins.

- [Bitcoin Core 26.0][dec bcc] a inclus une prise en charge expérimentale du [protocole de transport de la version 2][topic v2 p2p
  transport], la prise en charge de [Taproot][topic taproot] dans [Miniscript][topic miniscript], de nouvelles RPC pour travailler
  avec les états pour [assumeUTXO][topic assumeutxo], et une RPC expérimentale pour soumettre des [paquets de transactions][topic
  package relay] au mempool du nœud local.

</div>

## Octobre

{:#pss}
Gijs van Dam a publié des [résultats de recherche et du code][oct pss] sur le _payment splitting and switching_ (PSS). Son code permet
aux nœuds de diviser les [paiements entrants en plusieurs parties][topic multipath payments], qui peuvent emprunter des itinéraires
différents avant d'atteindre le destinataire final. Par exemple, un paiement d'Alice à Bob pourrait être partiellement acheminé par
Carol. Cette technique entrave considérablement les attaques de découverte de solde, où les attaquants sondent les soldes des canaux
pour suivre les paiements à travers le réseau. La recherche de Van Dam a montré une diminution de 62% des informations obtenues par
les attaquants grâce à PSS. De plus, PSS offre une augmentation du débit du réseau Lightning et peut aider à atténuer les [attaques
de saturation des canaux][topic channel jamming attacks].

{:#sidepools}
Le développeur ZmnSCPxj a proposé un concept appelé [sidepools][oct sidepool] qui vise à améliorer la gestion de la liquidité de LN.
Les sidepools impliquent que plusieurs nœuds de transfert déposent des fonds dans un contrat d'état multiparty hors chaîne similaire
aux canaux LN. Cela permet de redistribuer les fonds entre les participants hors chaîne. Par exemple, si Alice, Bob et Carol commencent
chacun avec 1 BTC, l'état peut être mis à jour de sorte qu'Alice ait 2 BTC, Bob 0 BTC et Carol 1 BTC. Les participants continueraient à
utiliser et à annoncer des canaux LN réguliers, et si ces canaux devenaient déséquilibrés, un rebalancement peut être effectué via un
échange entre pairs hors chaîne dans le contrat d'état. Cette méthode est privée pour les participants, nécessite moins d'espace sur
la chaîne et élimine probablement les frais de rebalancement hors chaîne, améliorant ainsi le potentiel de revenus pour les nœuds de
transfert et la fiabilité des paiements LN. Cependant, cela nécessite un contrat d'état multipartie, qui n'a pas été testé en production.
ZmnSCPxj suggère de s'appuyer sur [LN-Symmetry][topic eltoo] ou les canaux de paiement duplex, qui ont tous deux des avantages et des
inconvénients.

{:#assumeutxo}
En octobre, la première phase du projet [assumeUTXO][topic assumeutxo] a été achevée, contenant tous les changements restants nécessaires
pour utiliser un état instantané assumedvalid et effectuer une synchronisation complète en arrière-plan. Il permet de charger des
instantanés UTXO via une RPC. Bien que l'ensemble de fonctionnalités ne soit pas encore directement utilisable par les utilisateurs
inexpérimentés, cette fusion marque la culmination d'un effort de plusieurs années. Le projet, proposé en 2018 et formalisé en 2019,
améliorera considérablement l'expérience utilisateur des nouveaux nœuds complets qui rejoignent le réseau.

{:#p2pv2}
En octobre, le projet Bitcoin Core a également [réalisé][oct p2pv2] l'ajout de la prise en charge du [transport P2P chiffré de version
2][topic v2 p2p transport] tel que spécifié dans [BIP324][]. La fonctionnalité est actuellement désactivée par défaut, mais peut être
activée en utilisant l'option `-v2transport`. Le transport chiffré contribue à améliorer la confidentialité des utilisateurs de Bitcoin
en empêchant les observateurs passifs (comme les fournisseurs d'accès Internet) de déterminer directement quelles transactions les nœuds
relaient à leurs pairs. Il est également possible d'utiliser le transport chiffré pour détecter les observateurs actifs de l'homme du
milieu en comparant les identifiants de session. À l'avenir, l'ajout d'[autres fonctionnalités][topic countersign] pourrait permettre
à un client léger de se connecter en toute sécurité à un nœud de confiance via une connexion P2P chiffrée.

{:#miniscript}
Le support des descripteurs Miniscript a connu plusieurs améliorations supplémentaires dans Bitcoin Core tout au long de l'année. En
février, il a été [possible][feb miniscript] de créer des descripteurs Miniscript pour les scripts de sortie P2WSH. En octobre, le
support de Miniscript a été [mis à jour][oct miniscript] pour prendre en charge Taproot, y compris les descripteurs Miniscript pour
Tapscript.

{:#statebitvm}
Une méthode de compression d'état dans Bitcoin utilisant des preuves de validité à connaissance nulle a été [décrite][may state] par
Robin Linus et Lukas George en mai. Cela réduit considérablement la quantité d'état qu'un client doit télécharger pour vérifier de
manière fiable les opérations futures dans un système, par exemple en démarrant un nouveau nœud complet avec seulement une preuve de
validité relativement petite plutôt qu'en validant chaque transaction déjà confirmée sur la chaîne de blocs. En octobre, Robin Linus a
[présenté][oct bitvm] BitVM, une méthode permettant de payer des bitcoins en fonction de l'exécution réussie d'un programme arbitraire,
sans nécessiter de changement de consensus dans Bitcoin. BitVM nécessite un échange de données off-chain substantiel, mais n'a besoin
que d'une seule transaction on-chain pour parvenir à un accord, ou d'un petit nombre de transactions on-chain en cas de litige. BitVM
rend possible la création de contrats sans confiance complexes même dans des scénarios adverses, ce qui a attiré l'attention de
plusieurs développeurs.

## Novembre

{:#offers}
Avec la spécification finale des [chemins aveugles][topic rv routing] et [messages en onion][topic onion messages], et leur mise en œuvre
dans plusieurs nœuds LN populaires, ont permis de réaliser des progrès significatifs cette année dans le développement du [protocole des
offres][topic offers] qui en dépend. Les offres permettent à un portefeuille du destinataire de générer une _offre_ courte qui peut être
partagée avec le portefeuille de celui qui dépense. Le portefeuille de l'émetteur peut ainsi utiliser l'offre pour contacter le portefeuille du
destinataire via le protocole LN afin de demander une facture spécifique, qu'il peut ensuite payer de la manière habituelle. Cela permet
la création d'offres réutilisables qui peuvent chacune produire une facture différente, des factures qui peuvent être mises à jour avec
des informations actuelles (par exemple, le taux de change) juste quelques secondes avant leur paiement, et des offres qui peuvent être
payées plusieurs fois par le même portefeuille (par exemple, un abonnement), entre autres fonctionnalités. Les implémentations
expérimentales existantes des offres dans [Core Lightning][feb cln offers] et [Eclair][feb eclair offers] ont été mises à jour au cours
de l'année, et le support des offres a été ajouté à [LDK][sept ldk offers]. De plus, en novembre, une [discussion][nov offers] a eu lieu
sur la création d'une version mise à jour des adresses Lightning compatible avec les offres.

{:#liqad}
En novembre, une [mise à jour][nov liqad] de la spécification des [annonces de liquidité][topic liquidity advertisements] a également été
réalisée, permettant à un nœud d'annoncer qu'il est prêt à contribuer une partie de ses fonds à un nouveau [canal à financement
double][topic dual funding] en échange d'une commission, ce qui permet au nœud demandeur de commencer rapidement à recevoir des paiements
LN entrants. Les mises à jour étaient principalement mineures, bien qu'une discussion [se soit poursuivie][dec liqad] en décembre sur la
question de savoir si les canaux créés à partir d'une annonce de liquidité devraient contenir un verrouillage temporel. Un verrouillage
temporel pourrait donner une assurance basée sur des incitations à l'acheteur qu'il recevrait effectivement la liquidité pour laquelle
il a payé, mais le verrouillage temporel pourrait également être utilisé par un acheteur malveillant ou peu prévenant pour bloquer une
quantité excessive du capital du fournisseur.

<div markdown="1" class="callout" id="optech">

### Résumé 2023<br>Bitcoin Optech

{% comment %}<!-- commands to help me create this summary for next year

wc -w _posts/en/newsletters/2023-* _includes/specials/policy/en/*
(1 book page = 350 words)

git log --diff-filter=A --since='1 year ago' --name-only --pretty=format: _topics/en | sort -u | wc -l

wget https://anchor.fm/s/d9918154/podcast/rss
# use vim to delete all podcasts before this year
grep duration rss | sed 's!^.*>\([0-9].*\):..</.*$!\1!' | sed 's/:/ * 60 + /' | bc -l | numsum | echo $(cat) / 60 | bc -l
-->{% endcomment %}

<style>
#optech ul {
    max-width: 800px;
    display: flex;
    flex-wrap: wrap;
    list-style: none;
    padding: 0;
    margin: 0;
    justify-content: center;
}

#optech li {
    flex: 1 0 180px;
    max-width: 180px;
    box-sizing: border-box;
    padding: 5px; /* Adjust as needed */
    margin: 5px; /* Adjust as needed */
    /* Additional styling here */
}

@media (max-width: 720px) {
#optech li {        flex-basis: calc(50% - 10px); /* 2 colonnes */
    }
}

@media (max-width: 360px) {
    #optech li {
        flex-basis: calc(100% - 10px); /* 1 colonne */
    }
}
</style>

Au cours de la sixième année d'Optech, nous avons publié 51 [bulletin][newsletters] hebdomadaires,
une série en 10 parties sur [la politique du mempool][policy series] et
ajouté 15 nouvelles pages à notre [index des sujets][topics index]. Au total, Optech
a publié plus de 86 000 mots en anglais sur la recherche et le développement de logiciels Bitcoin cette année, l'équivalent approximatif
d'un livre de 250 pages.

De plus, chaque bulletin de cette année était accompagnée d'un [podcast][podcast],
totalisant plus de 50 heures sous forme audio et 450 000 mots sous forme de transcription. De nombreux contributeurs majeurs de Bitcoin
ont été invités à l'émission---certains d'entre eux à plusieurs reprises---avec un total de 62 invités uniques différents en 2023 :

- Abubakar Ismail
- Adam Gibson
- Alekos Filini
- Alex Myers
- Anthony Towns
- Antoine Poinsot
- Armin Sabouri
- Bastien Teinturier
- Brandon Black
- Burak Keceli
- Calvin Kim
- Carla Kirk-Cohen
- Christian Decker
- Clara Shikhelman
- Dan Gould
- Dave Harding
- Dusty Daemon
- Eduardo Quintana
- Ethan Heilman
- Fabian Jahr
- Gijs van Dam
- Gloria Zhao
- Gregory Sanders
- Henrik Skogstrøm
- Jack Ronaldi
- James O’Beirne
- Jesse Posner
- Johan Torås Halseth
- Joost Jager
- Josie Baker
- Ken Sedgwick
- Larry Ruane
- Lisa Neigut
- Lukas George
- Martin Zumsande
- Matt Corallo
- Matthew Zipkin
- Max Edwards
- Maxim Orlovsky
- Nick Farrow
- Niklas Gögge
- Olaoluwa Osuntokun
- Pavlenex
- Peter Todd
- Pieter Wuille
- Robin Linus
- Ruben Somsen
- Russell O’Connor
- Salvatore Ingala
- Sergi Delgado Segura
- Severin Bühler
- Steve Lee
- Steven Roose
- Thomas Hartman
- Thomas Voegtlin
- Tom Briar
- Tom Trevethan
- Valentine Wallace
- Vivek Kasarabada
- Will Clark
- Yuval Kogman
- ZmnSCPxj

Optech a également publié deux rapports de terrain proposés par la communauté des entreprises : l'un de Brandon Black de BitGo sur
[la mise en œuvre de MuSig2][implementing MuSig2] pour réduire les coûts de transaction et améliorer la confidentialité, et un deuxième
rapport d'Antoine Poinsot de Wizardsardine sur [la création de logiciels avec miniscript][building software with miniscript].

[implementing MuSig2]: /fr/bitgo-musig2/
[building software with miniscript]: /fr/wizardsardine-miniscript/

</div>

## Décembre

{:#clustermempool}
Plusieurs développeurs de Bitcoin Core ont [commencé][may cluster] à travailler sur une nouvelle conception de
[mempool en cluster][topic cluster mempool] pour simplifier les opérations du mempool tout en maintenant l'ordre des transactions
nécessaire, où les transactions parent doivent être confirmées avant leurs transactions sont regroupées en clusters, puis divisées en
morceaux triés par taux de frais, en veillant à ce que les morceaux à taux de frais élevés soient confirmés en premier. Cela permet de
créer des modèles de blocs en choisissant simplement les morceaux à taux de frais les plus élevés dans le mempool, et d'éviter les
transactions en abandonnant les morceaux à taux de frais les plus bas. Cela corrige certains comportements indésirables existants
(par exemple, lorsque les mineurs peuvent perdre des revenus de frais en raison d'évictions sous-optimales) et pourrait améliorer
d'autres aspects de la gestion du mempool et de la transmission des transactions à l'avenir. Les archives de leurs discussions ont été
[publiées][dec cluster] début décembre.

{:#warnet}
En décembre, un nouvel outil permettant de lancer un grand nombre de nœuds Bitcoin avec un ensemble défini de connexions entre eux
(généralement sur un réseau de test) a été [annoncé][dec warnet announce] publiquement. Il peut être utilisé pour tester des
comportements difficiles à reproduire avec un petit nombre de nœuds ou qui causeraient des problèmes sur les réseaux publics, tels que
des attaques connues et la propagation d'informations inutiles. Un [exemple public][dec zipkin warnet] d'utilisation de l'outil était
la mesure de la consommation de mémoire de Bitcoin Core avant et après une modification proposée.

*Nous remercions tous les contributeurs de Bitcoin mentionnés ci-dessus, ainsi que les nombreux autres dont le travail était tout aussi
important, pour une autre année incroyable de développement de Bitcoin. La newsletter Optech reprendra sa publication régulière le
mercredi 3 janvier.*

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="" %}
[apr bitgo]: /fr/bitgo-musig2/
[apr blinding]: /fr/newsletters/2023/04/05/#bolts-765
[apr htlcendo]: /fr/newsletters/2023/05/17/#test-de-l-approbation-htlc
[apr ldk]: /fr/newsletters/2023/04/26/#ldk-0-0-115
[apr lnd]: /fr/newsletters/2023/04/05/#lnd-v0-16-0-beta
[apr loop]: /fr/newsletters/2023/05/24/#lightning-loop-est-par-defaut-musig2
[apr musig2 psbt]: /fr/newsletters/2023/10/18/#proposition-de-bip-pour-les-champs-musig2-dans-les-psbt
[apr musig2]: /fr/newsletters/2023/04/12/#bips-1372
[apr rgb]: /fr/newsletters/2023/04/19/#mise-a-jour-rgb
[apr secp]: /fr/newsletters/2023/04/12/#libsecp256k1-0-3-1
[apr signrpc]: /fr/newsletters/2023/02/15/#lnd-7171
[apr splicing]: /fr/newsletters/2023/04/12/#discussions-sur-les-specifications-du-splicing
[apr taproot channels]: /fr/newsletters/2023/08/30/#lnd-7904
[apr watchtower]: /fr/newsletters/2023/04/05/#preuves-de-responsabilite-de-la-tour-de-controle
[aug antidos]: /fr/newsletters/2023/08/09/#philosophie-de-conception-de-la-protection-contre-les-attaques-par-deni-de-service-dos
[aug bdk]: /fr/newsletters/2023/08/09/#bdk-0-28-1
[aug btcpay]: /fr/newsletters/2023/08/02/#btcpay-server-1-11-1
[aug cln]: /fr/newsletters/2023/08/30/#core-lightning-23-08
[aug combo]: /fr/newsletters/2023/08/30/#synthese-de-covenants-utilisant-txhash-et-csfs
[aug fraud]: /fr/newsletters/2023/08/23/#preuves-de-fraude-pour-les-sauvegardes-obsoletes
[aug fundingdos]: /fr/newsletters/2023/08/30/#divulgation-d-une-vulnerabilite-passee-de-ln-liee-au-financement-fictif
[aug htlcendo]: /fr/newsletters/2023/08/09/#tests-d-approbation-htlc-et-collecte-de-donnees
[aug lnd taproot]: /fr/newsletters/2023/08/30/#lnd-7904
[aug milksad]: /fr/newsletters/2023/08/09/#divulgation-de-securite-de-libbitcoin-bitcoin-explorer
[aug onion]: /fr/newsletters/2023/08/09/#bolts-759
[aug opreturn]: /fr/newsletters/2023/08/09/#proposition-de-modifications-de-la-politique-de-relais-par-defaut-de-bitcoin-core
[aug payjoin]: /fr/newsletters/2023/08/16/#payjoin-sans-serveur
[aug sp]: /fr/newsletters/2023/08/09/#bitcoin-core-pr-review-club
[chatbtc]: https://chat.bitcoinsearch.xyz/
[dec bcc]: /fr/newsletters/2023/12/06/#bitcoin-core-26-0
[dec cluster]: /fr/newsletters/2023/12/06/#discussion-sur-le-cluster-mempool
[dec liqad]: /fr/newsletters/2023/12/13/#discussion-sur-le-griefing-des-annonces-de-liquidite
[dec payjoin]: /fr/newsletters/2023/12/13/#publication-d-un-client-payjoin-pour-bitcoin-core
[dec warnet announce]: /fr/newsletters/2023/12/13/#annonce-de-l-outil-de-simulation-du-reseau-bitcoin-warnet
[dec zipkin warnet]: /fr/newsletters/2023/12/06/#test-avec-warnet
[feb bitcoinsearch]: /fr/newsletters/2023/02/15/#bitcoinsearch-xyz
[feb cln offers]: /fr/newsletters/2023/02/08/#core-lightning-5892
[feb codex32]: /fr/newsletters/2023/02/22/#proposition-de-bip-pour-le-systeme-d-encodage-des-semences-codex32
[feb eclair offers]: /fr/newsletters/2023/02/22/#eclair-2479
[feb htlcendo]: /fr/newsletters/2023/02/22/#feedback-demande-sur-la-notation-de-bon-voisinage-des-ln
[feb lnflag]: /fr/newsletters/2023/02/22/#indicateur-de-qualite-de-service-ln
[feb miniscript]: /fr/newsletters/2023/02/22/#bitcoin-core-24149
[feb op_vault2]: /fr/newsletters/2023/03/08/#conception-alternative-pour-op-vault
[feb op_vault]: /fr/newsletters/2023/02/22/#projet-de-bip-pour-op-vault
[feb ord1]: /fr/newsletters/2023/02/08/#discussion-sur-le-stockage-des-donnees-dans-la-chaine-de-blocs
[feb ord2]: /fr/newsletters/2023/02/15/#poursuite-de-la-discussion-sur-le-stockage-des-donnees-de-la-chaine-de-blocs
[feb payjoin]: /fr/newsletters/2023/02/01/#proposition-de-payjoin-sans-serveur
[feb storage]: /fr/newsletters/2023/02/15/#core-lightning-5361
[jamming paper]: /fr/newsletters/2022/11/16/#document-sur-les-attaques-par-brouillage-de-canaux
[jan bip329]: /fr/newsletters/2023/01/25/#bips-1383
[jan eclair]: /fr/newsletters/2023/01/04/#eclair-0-8-0
[jan hwi]: /fr/newsletters/2023/01/18/#hwi-2-2-0
[jan inquisition]: /fr/newsletters/2023/01/04/#bitcoin-inquisition
[jan op_vault]: /fr/newsletters/2023/01/18/#proposition-de-nouveaux-opcodes-specifiques-aux-coffre-forts
[jan potentiam]: /fr/newsletters/2023/01/11/#engagements-d-ouvertures-non-interactifs-du-canal-ln
[jul cleanup]: /fr/newsletters/2023/07/12/#proposition-de-nettoyage-de-la-specification-ln
[jul htlcendo]: /fr/newsletters/2023/07/26/#propositions-d-attenuation-des-attaques-de-saturation-des-canaux
[jul hwi]: /fr/newsletters/2023/07/26/#hwi-2-3-0
[jul ldk]: /fr/newsletters/2023/07/26/#ldk-0-0-116
[jul lnclose]: /fr/newsletters/2023/07/26/#protocole-de-fermeture-ln-simplifie
[jul pdk]: /fr/newsletters/2023/07/19/#payjoin-sdk-annonce
[jul summit]: /fr/newsletters/2023/07/26/#notes-du-sommet-ln
[jul vls]: /fr/newsletters/2023/07/19/#annonce-de-la-version-beta-de-validating-lightning-signer-vls
[jun eclair]: /fr/newsletters/2023/06/21/#eclair-v0-9-0
[jun matt]: /fr/newsletters/2023/06/07/#utilisation-de-matt-pour-repliquer-ctv-et-gerer-les-joinpools
[jun sp]: /fr/newsletters/2023/06/14/#projet-de-bip-pour-les-paiements-silencieux
[jun specsf]: /fr/newsletters/2023/06/28/#speculer-en-utilisant-les-changements-de-consensus-esperes
[mar cln]: /fr/newsletters/2023/03/08/#core-lightning-23-02
[mar mpchan]: /fr/newsletters/2023/03/29/#prevenir-les-pertes-de-capitaux-grace-aux-usines-a-canaux-channel-factories-et-aux-canaux-multipartites
[mar rb]: /fr/newsletters/2023/03/29/#rust-bitcoin-0-30-0
[may ark]: /fr/newsletters/2023/05/31/#proposition-d-un-protocole-de-gestion-des-joinpool
[may bcc]: /fr/newsletters/2023/05/31/#bitcoin-core-25-0
[may cln]: /fr/newsletters/2023/05/24/#core-lightning-23-05
[may cluster]: /fr/newsletters/2023/05/17/#mempool-clustering
[may lsp]: /fr/newsletters/2023/05/17/#demande-de-commentaires-sur-les-specifications-proposees-pour-les-lsp
[may matt]: /fr/newsletters/2023/05/03/#coffres-forts-bases-sur-matt
[may payjoin]: /fr/newsletters/2023/05/17/#applications-avancees-de-payjoin
[may state]: /fr/newsletters/2023/05/24/#compression-d-etats-avec-preuves-de-validite-a-connaissance-nulle
[newsletters]: /fr/newsletters/
[nov cln]: /fr/newsletters/2023/11/29/#core-lightning-23-11
[nov cov]: /fr/newsletters/2023/11/01/#poursuite-des-discussions-sur-les-modifications-de-script
[nov htlcagg]: /fr/newsletters/2023/11/08/#agregation-htlc-avec-des-covenants
[nov ldk]: /fr/newsletters/2023/11/01/#ldk-0-0-118
[nov liqad]: /fr/newsletters/2023/11/29/#mise-a-jour-de-la-specification-des-annonces-de-liquidite
[nov offers]: /fr/newsletters/2023/11/22/#adresses-ln-compatibles-avec-les-offres
[oct assumeutxo]: /fr/newsletters/2023/10/11/#bitcoin-core-27596
[oct bitvm]: /fr/newsletters/2023/10/18/#paiements-conditionnels-a-une-computation-arbitraire
[oct cycling]: /fr/newsletters/2023/10/25/#vulnerabilite-de-remplacement-cyclique-contre-les-htlc
[oct generic]: /fr/newsletters/2023/10/25/#recherche-sur-les-conventions-generiques-avec-des-modifications-minimales-du-langage-script
[oct ldk]: /fr/newsletters/2023/10/11/#ldk-0-0-117
[oct lnd]: /fr/newsletters/2023/10/04/#lnd-v0-17-0-beta
[oct miniscript]: /fr/newsletters/2023/10/18/#bitcoin-core-27255
[oct op_cat]: /fr/newsletters/2023/10/25/#proposition-de-bip-pour-op-cat
[oct p2pv2]: /fr/newsletters/2023/10/11/#bitcoin-core-28331
[oct pss]: /fr/newsletters/2023/10/04/#division-et-commutation-des-paiements
[oct sidepool]: /fr/newsletters/2023/10/04/#liquidite-mutualisee-pour-ln
[oct txhash]: /fr/newsletters/2023/10/11/#specification-pour-op-txhash-proposee
[policy series]: /fr/blog//waiting-for-confirmation/
[sep lnscale]: /fr/newsletters/2023/09/27/#utilisation-de-covenants-pour-ameliorer-la-scalabilite-de-ln
[sep secp]: /fr/newsletters/2023/09/06/#libsecp256k1-0-4-0
[sept compress]: /fr/newsletters/2023/09/06/#compression-des-transactions-bitcoin
[sept ldk offers]: /fr/newsletters/2023/09/20/#ldk-2371
[sept tapassets]: /fr/newsletters/2023/09/13/#specifications-pour-les-actifs-taproot
[tapsim]: /fr/newsletters/2023/06/21/#debogueur-pour-tapscript-tapsim
[tldr]: https://tldr.bitcoinsearch.xyz/
[topics index]: /en/topics/
[yirs 2018]: /en/newsletters/2018/12/28/
[yirs 2019]: /en/newsletters/2019/12/28/
[yirs 2020]: /fr/newsletters/2020/12/23/
[yirs 2021]: /fr/newsletters/2021/12/22/
[yirs 2022]: /fr/newsletters/2022/12/21/
