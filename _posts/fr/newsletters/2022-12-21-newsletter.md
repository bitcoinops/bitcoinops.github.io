---
title: 'Bulletin Hebdomadaire Bitcoin Optech #231: Revue Spéciale Année 2022'
permalink: /fr/newsletters/2022/12/21/
name: 2022-12-21-newsletter-fr
slug: 2022-12-21-newsletter-fr
type: newsletter
layout: newsletter
lang: fr

excerpt: >
  Cette édition spéciale de la lettre d'information Optech résume les faits marquants de l'évolution du bitcoin pendant toute l'année 2022.
---
{{page.excerpt}} C'est la suite de nos résumés des années précédentes [2018][yirs
2018], [2019][yirs 2019], [2020][yirs 2020], and [2021][yirs 2021].

## Contenus

* Janvier
  * [factures apatrides](#stateless-invoices)
  * [fond de defense juridique](#defense-fund)
* Fevrier
  * [Parrainage de frais](#fee-sponsorship)
  * [Paiements pour les noeuds fantômes](#phantom-node-payments)
* Mars
  * [Recherche de chemin LN](#ln-pathfinding)
  * [Canaux Zero-conf](#zero-conf-channels)
* Avril
  * [Paiements silencieux](#silent-payments)
  * [Taro](#taro)
  * [Échange de clés à sécurité quantique](#quantum-safe-keys)
* Mai
  * [MuSig2](#musig2)
  * [Relai par paquets](#package-relay)
  * [librairie du noyau Bitcoin](#libbitcoinkernel)
* Juin
  * [Réunion des développeurs du protocole LN](#ln-meet)
* Juillet
  * [Limitation du débit des messages en oigon](#onion-message-limiting)
  * [Descripteurs Miniscript](#miniscript-descriptors)
* Aout
  * [double financement interactif de LN](#dual-funding)
  * [Atténuation des attaques par brouillage des canaux](#jamming)
  * [Signatures BLS pour les DLC](#dlc-bls)
* Septembre
  * [Fiches de tarification des frais](#fee-ratecards)
* Octobre
  * [Version 3 des relais de transaction](#v3-tx-relay)
  * [Paiements asynchrones](#async-payments)
  * [bogues dans l'analyse syntaxique des blocs](#parsing-bugs)
  * [ZK rollups](#zk-rollups)
  * [Protocole de transport crypté version 2](#v2-transport)
  * [Réunion des développeurs du protocole Bitcoin](#core-meet)
* Novembre
  * [Messages d'erreur Fat](#fat-errors)
* Decembre
  * [Modification du protocole LN](#ln-mod)
* Résumés en vedette
  * [Replace-By-Fee](#rbf)
  * [Mises à jour majeures des principaux projets d'insfrastructure](#releases)
  * [Bitcoin Optech](#optech)
  * [Proposition de Soft fork](#softforks)

## Janvier

{:#stateless-invoices}
En janvier, LDK a [fusionné][news181 ldk1177] une implémentation de [factures apatrides][topic stateless invoices],
qui lui permet de générer un nombre infini de factures sans stocker aucune donnée à leur sujet,
sauf si le paiement est réussi. Les factures sans état ont déjà été proposées en septembre 2021
et la mise en œuvre de LDK diffère de la méthode suggérée, bien qu'elle accomplisse le même objectif
et ne nécessite aucun changement du protocole LN. Plus tard dans le mois, une [mise à jour][news182 bolts912]
de la spécification LN a été fusionnée pour permettre d'autres types de factures sans état, avec
un support au moins partiel ajouté à [Eclair][news183 stateless], [Core Lightning][news195 stateless] et [LND][news196 stateless].

{:#defense-fund}
En janvier également, un fond de défense juridique Bitcoin a été [annoncé][news183 defense fund]
par Jack Dorsey, Alex Morcos et Martin White. Il fournit "une entité à but non lucratif
qui vise à minimiser les maux de tête juridiques qui découragent les développeurs de
logiciels de développer activement Bitcoin et les projets connexes."

## Février

{:#fee-sponsorship}
Une [discussion][news182 accounts] en janvier sur la possibilité d'ajouter plus facilement des frais
aux transactions présignées a conduit à une [nouvelle discussion][news188 sponsorship] en février sur
l'idée de Jeremy Rubin de [parrainage des frais de transaction][topic fee sponsorship] de 2020.
Plusieurs obstacles à sa mise en œuvre ont été mentionnés. Bien que la discussion immédiate n'ait pas
beaucoup progressée, une technique permettant d'atteindre des objectifs similaires---mais qui,
contrairement au parrainage, ne nécessitait pas de soft fork---a été [proposée][news231 v3relay] en octobre.

{:#phantom-node-payments}
La prise en charge précoce par LDK des [factures apatrides][topic stateless invoices]
lui a permis d'ajouter une méthode nouvelle et [simple][news188 ldk1199] pour le chargement
équilibrant un nœud LN appelé *paiements de nœuds fantômes*.

{:.center}
![Illustration of phantom node payment path](/img/posts/2022-02-phantom-node-payments.dot.png)

## Mars

{:#ln-pathfinding}
L'algorithme de recherche de route publié pour la première fois en 2021 par René Pickhardt
et Stefan Richter a reçu une [mise à jour][news192 pp] en mars, Pickhardt soulignant une
amélioration rendant l'algorithme bien plus efficace computationnellement parlant.

{:#zero-conf-channels}
Une méthode cohérente pour permettre l'utilisation des [canaux zéro-conf][topic zero-conf
channels] a été [spécifiée][news203 zero-conf] et a commencé à être implémentée, en débutant
par l'[addition][news192 ldk1311] au LDK en mars du champs *alias* pour les identifiants
de canaux (Short Channel Identifier, SCID), suivi par [Eclair][news205 scid], [Core Lightning][news208 scid cln]
et [LND][news208 scid lnd].

{:.center}
![Illustration of zero-conf channels](/img/posts/2021-07-zeroconf-channels.png)

<div markdown="1" class="callout" id="rbf">

### Résumé 2022<br>Replace-By-Fee

Cette année fut aussi le théâtre de nombreuses discussions et d'importantes actions autour
de [Replace By Fee][topic rbf] (RBF). Notre bulletin d'information de janvier [résumait][news181 rbf]
une proposition de Jeremy Rubin d'autoriser le remplacement de n'importe quelle transaction par
une transaction alternative payant plus de frais dans un court laps de temps après que
la transaction originelle ait été prise en compte par un noeud. Passée cette période, les règles existantes
s'appliqueraient, n'autorisant le remplacement que pour des transactions qui signalent
cette possibilité avec [BIP125][]. Ce fonctionnement permettrait aux marchands d'accepter des
transactions non confirmées comme ils le font actuellement, une fois écoulée la période de
remplacement. Plus important encore, cela pourrait permettre aux protocoles qui dépendent
de la substituabilité des transactions pour leur sécurité de ne pas avoir à se soucier des
transactions n'ayant pas optées pour le remplacement (via BIP125) tant qu'un noeud de ce
protocole ou une *watchtower* dispose d'un temps raisonnable pour réagir après avoir eu
connaissance d'une transaction.

A la fin du mois de janvier, Gloria Zhao a entamé une nouvelle discussion à propos de RBF en
[publiant][news186 rbf] une note sur le contexte entourant la politique RBF actuelle, relevant
plusieurs problèmes découverts au cours des dernières années (comme les [attaques par épinglage]
[topic transaction pinning]), examinant comment cette politique affecte les interfaces utilisateurs
des portefeuilles, et décrivant des améliorations potentielles. Au début du mois de mars, Zhao
a poursuivi avec le [résumé][news191 rbf] de deux discussions à propos de RBF entre de nombreux
développeurs, l'une en présentiel et l'autre en ligne.

Egalement en mars, Larry Ruane a soulevé plusieurs [questions][news193 witrep] liées à RBF, concernant
le remplacement des signatures des transactions (les *witnesses*) sans pour autant changer
les parties d'une transaction dont est dérivé l'identifiant de transaction.

En juin, Antoine Riard a [ouvert][news205 rbf] une *pull request* (PR) dans Bitcoin Core pour ajouter
une option de configuration `mempoolfullrbf`. Par défaut, cette option répliquerait le comportenement
actuel de Bitcoin Core, n'autorisant donc le remplacement que pour les transactions contenant le
signal [BIP125][] approprié. Les noeuds configurés avec cette option définie sur sa valeur alternative
accepteraient les transactions de remplacement, même si la transaction remplacée ne signalait pas
sa substituabilité, et ce tant au niveau du relai des transactions que dans les blocs. Riard a
également débuté un fil sur la liste de diffusion Bitcoin-Dev pour discuter de ce changement.
Presque tous les commentaires sur la PR étaient positifs et la plupart des discussions
sur la liste de diffusion concernaient d'autres sujets : c'est donc sans surprise que la pull request
fut [fusionnée][news208 rbf] environ un mois après son ouverture.

En octobre, Bitcoin Core a commencé la distribution des versions admissibles (*release candidates*)
pour la version 24.0, qui serait la première à inclure l'option de configuration `mempoolfullrbf`.
Dario Sneidermanis, voyant les notes de version préliminaires à propos de la nouvelle option,
[posta][news222 rbf] sur la liste de diffusion Bitcoin-Dev que l'activation de l'option par trop
d'utilisateurs et de mineurs rendrait fiable le remplacement de transactions ne signalant pas la
substituabilité. Une fiabilité accrue du remplacement des transactions ne signalant pas leur substituabilité
rendrait également plus fiable le vol de services acceptant les transactions non confirmées comme
finales, requérant de ces services un changement de leur fonctionnement. La discussion s'est [poursuivie][news223 rbf]
la semaine suivante, et celle encore [après][news224 rbf]. Un mois après que Sneidermanis eut soulevé
ses premières inquiétudes sur la liste de diffusion, Suhas Daftuar [résumait][news225 rbf] certains des
arguments contre la nouvelle option et ouvrait une PR pour la retirer de Bitcoin Core.
D'autres PR similaires ont été ouvertes précedemment ou par la suite, mais celle de
Daftuar concentra l'essentiel de la discussion autour du potentiel retrait de l'option.

De nombreux contre-arguments en faveur du maintien de l'option `mempoolfullrbf` furent formulés sous
la PR de Daftuar, comme les témoignages de plusieurs développeurs de
portefeuilles indiquant le cas relativement régulier d'utilisateurs souhaitant remmplacer leur
transaction bien qu'ils n'aient pas signalé la substituabilité via BIP125.

A la fin du mois de novembre, Daftuar avait fermé sa PR et le projet Bitcoin Core avait
publié la version 24.0 du logiciel, avec l'option `mempoolfullrbf`. En décembre, le développeur 0xB10C
[publia][news230 rbf] un site internet pour suivre l'occurence de transactions de remplacement ne
contenant pas le signal de BIP125, indiquant que n'importe quelle transaction de ce type ayant été minée
l'avait probablement été par un mineur ayant activé l'option `mempoolfullrbf` (ou une option similaire dans
un autre logiciel que Bitcoin Core). A la fin de l'année, full-RBF était toujours activement discuté
dans d'autres PR de Bitcoin Core et sur la liste de diffusion.

</div>

## Avril

{:#silent-payments}
En avril, Ruben Somsen a [proposé][news194 sp] l'idée des [paiements silencieux][topic silent payments],
qui permettraient à quelqu'un de payer un identifiant public (une "adresse") sans pour autant utiliser
cet identifiant on-chain. Cela participerait à réduire la [réutilisation d'adresse][topic output linking].
Par exemple, Alice pourrait publier un identifiant public sur son site internet, que Bob serait ensuite
en mesure de transformer en une adresse Bitcoin unique que seule Alice peut dépenser.
Si Carole se rend par la suite sur le site d'Alice et réutilise le même identifiant public, elle
dérivera une adresse différente pour payer Alice, que ni Bob ni aucune autre tierce partie ne pourra
relier à Alice. Par la suite, le développeur W0ltx a proposé une [implémentation][news202 sp] des
*silent payments*  pour Bitcoin Core, y apportant ultérieurement d'importantes [mises à jour][news214 sp].

{:#taro}
Lightning Labs a [annoncé][news195 taro] Taro, une proposition de protocole (basée sur diverses propositions)
permettant de créer et transférer des tokens arbitraires sur la chaîne Bitcoin. L'ambition de Taro
est d'être utilisé conjointement au Lightning Network pour router des transactions *off-chain*
au travers du réseau. Similairement à des propositions antérieures pour des transferts entre différents
actifs au sein du LN, les noeuds intermédiaires qui se contentent de transférer les paiements n'ont pas
besoin d'être conscients du protocole Taro ou des détails des différents actifs transférés---ils se
contentent de transférer des bitcoins en utilisant le même protocole que n'importe quel autre
paiement Lightning.

{:#quantum-safe-keys}
Avril a aussi été l'occasion d'une [discussion][news196 qc] autour de l'échange de clés post-quantique,
permettant aux utilisateurs de recevoir des bitcoins sécurisés par des clés [résistantes][topic quantum resistance]
aux attaques menées par les ordinateurs quantiques rapides qui pourraient exister dans le futur.

## Mai

{:#musig2}
Le protocole [MuSig2][topic musig] pour la création de [multi-signatures schnorr]
[topic multisignature] a connu plusieurs développements en 2022.
Une [proposition de BIP][news195 musig2] a reçu d'importants [retours d'informations][news198
musig2] en Mai. Plus tard, en octobre, Yannick Seurin, Tim
Ruffing, Elliott Jin, and Jonas Nick ont découvert une
[vulnérabilité][news222 musig2] affectant certaines façons dont le protocole pourrait être utilisé.
Les chercheurs ont annoncé qu'ils prévoyaient de corriger cela à l'occasion d'une mise à jour.

{:#package-relay}
Un projet de BIP pour [le relai de paquet][topic package relay] a été
[posté][news201 package relay] par Gloria Zhao en Mai. Le relai de paquet
corrige un problème important avec les variations de frais ["fee bumping" CPFP][topic
cpfp] sur Bitcoin Core où les nœuds individuels n'accepteront une transaction enfant de type "fee-bumping"
que si sa transaction parent paye un taux supérieur au taux minimum dynamique du mempool du nœud.
Cela rend le CPFP insuffisamment fiable pour les protocoles dépendant de transactions présignées,
tels que de nombreux protocoles de contrats (y compris le protocole LN actuel). Le relai des paquets
permet d'évaluer une transaction parent et enfant comme une seule unité,
éliminant le problème---sans pour autant éliminer d'autres problèmes connexes
tels que [l'épinglage des transactions][topic transaction pinning].
Une discussion supplémentaire sur le relai des paquets [s'est produit][news204 package relay]
en Juin.

{:#libbitcoinkernel}
Le mois de mai a également vu la [première fusion][news198 lbk] du projet de bibliothèque
du noyau de Bitcoin (libbitcoinkernel), une tentative de séparer autant que possible le code
de consensus de Bitcoin Core dans une bibliothèque séparée, même si ce code comporte encore
du code non-consensuel. À long terme, l'objectif est de réduire libbitcoinkernel jusqu'à ce
qu'elle ne contienne plus que du code de consensus, ce qui permettra à d'autres projets
d'utiliser facilement ce code ou aux auditeurs d'analyser les modifications apportées à la
logique de consensus de Bitcoin Core. Plusieurs autres PR de libbitcoinkernel seront fusionnés
au cours de l'année.

<div markdown="1" class="callout" id="releases">

### Résumé 2022 <br> Mises à jour majeures des principaux projets d'infrastructure

- [Eclair 0.7.0][news185 eclair] ajout d'un support pour les [sorties
  d'ancrage][topic anchor outputs], relayer [les messages en oignon][topic onion
  messages], et l'utilisation de la base de données PostgreSQL en production.

- [BTCPay Server 1.4][news189 btcpay] ajoute un support pour [la variation des frais
  CPFP][topic cpfp], la possibilité d'utiliser des fonctionnalités supplémentaires des URL LN,
  ainsi que de multiples améliorations de l'interface utilisateur.

- [LDK 0.0.105][news190 ldk] ajoute la prise en charge des paiements fantômes
  et d'une meilleure recherche probabiliste des paiements.

- [BDK 0.17.0][news193 bdk] a facilité la dérivation des adresses,
  même lorsque le portefeuille est hors ligne.

- [Bitcoin Core 23.0][news197 bcc] fournit des portefeuilles [descripteurs]
  [topic descriptors] par défaut pour les nouveaux portefeuilles et permet
  également aux portefeuilles avec descripteurs de prendre facilement en charge
  la réception vers des adresses [bech32m][topic bech32] en utilisant [taproot]
  [topic taproot]. Il a également augmenté sa prise en charge de l'utilisation
  de ports TCP/IP autres que ceux par défaut et a commencé à autoriser
  l'utilisation de la superposition de réseau [CJDNS][].

- [Core Lightning 0.11.0][news197 cln] a ajouté la prise en charge de
  plusieurs canaux actifs vers le même pair et le paiement de
  [factures apatrides][topic stateless invoices].

- [Rust Bitcoin 0.28][news197 rb] ajoute la prise en charge de [taproot][topic taproot]
  et améliore les API connexes, telles que celles de [PSBT][topic psbt].

- [BTCPay Server 1.5.1][news198 btcpay] a ajouté un nouveau tableau de bord sur
  la page principale, une nouvelle fonction de processeurs de transfert, et la
  possibilité de permettre l'approbation automatique des paiements à la demande
  et des remboursements.

- [LDK 0.0.108 et 0.0.107][news205 ldk] a ajouté la prise en charge de [larges canaux]
  [topic large channels] et de [canaux zéro-conf][topic zero-conf channels] en plus
  de fournir un code qui permet aux clients mobiles de synchroniser les informations
  de routage du réseau (gossip) à partir d'un serveur.

- [BDK 0.19.0][news205 bdk] a ajouté la prise en charge expérimentale de [taproot][topic taproot]
  à travers les [descripteurs][topic descriptors], les [PSBT][topic psbt], et d'autres
  sous-systèmes. Il a également ajouté un nouvel algorithme de [sélection de pièces]
  [topic coin selection].

- [LND 0.15.0-beta][news206 lnd] a ajouté la prise en charge des métadonnées de facture
  qui peuvent être utilisées par d'autres programmes (et potentiellement par les futures
  versions de LND) pour les [factures apatrides][topic stateless invoices] et ajoute la
  prise en charge du portefeuille interne pour recevoir et dépenser des bitcoins vers des
  sorties de dépense de clés [P2TR][topic taproot], ainsi que la prise en charge expérimentale
  de [MuSig2][topic musig].

- [Rust Bitcoin 0.29][news213 rb] a ajouté les structures de données de [bloc de relais compact]
  [topic compact block relay] ([BIP152][]) et des améliorations au support de [taproot]
  [topic taproot] et [PSBT][topic psbt].

- [Core Lightning 0.12.0][news214 cln] a ajouté un nouveau module `bookkeeper`,
  un module `commando`, et la prise en charge des [sauvegardes de canaux statiques]
  [topic static channel backups], et a explicitement commencé à permettre aux pairs
  d'ouvrir des [canaux zéro-conf][topic zero-conf channels] avec votre noeud.

- [LND 0.15.1-beta][news215 lnd] a ajouté la prise en charge des [canaux zéro-conf]
  [topic zero-conf channels], des alias de canaux, et a commencé à utiliser les
  adresses [taproot][topic taproot] partout.

- [LDK 0.0.111][news217 ldk] ajoute la prise en charge de la création, de la réception
  et de la transmission de [messages en oignon] [topic onion messages].

- [Core Lightning 22.11][news229 cln] a commencé à utiliser un nouveau schéma
  de numérotation des versions et a ajouté un nouveau gestionnaire de modules.

- [libsecp256k1 0.2.0][news230 libsecp] était la première version balisée de
  cette bibliothèque largement utilisée pour les opérations cryptographiques
  liées à Bitcoin.

- [Bitcoin Core 24.0. 1][news230 bcc] a ajouté une option pour configurer la
  politique [Replace-By-Fee][topic rbf] (RBF) du noeud, un nouveau RPC `sendall`
  pour dépenser facilement tous les fonds d'un portefeuille en une seule transaction,
  un RPC `simulaterawtransaction` qui peut être utilisé pour vérifier comment
  une transaction affectera un portefeuille, et la possibilité de créer des
  [descripteurs][topic descriptors] à surveiller uniquement, contenant des expressions
  [miniscript][topic miniscript] pour améliorer la compatibilité avec d'autres logiciels.

</div>

## Juin

{:#ln-meet}
En juin, les développeurs LN se sont rencontrés [news204 ln] pour discuter de l'avenir
du développement des protocoles. Parmi les sujets abordés, citons les canaux LN basés
sur [taproot][topic taproot], [tapscript][topic tapscript] et [MuSig2][topic musig]
(y compris MuSig2 récursif), la mise à jour du protocole de gossip pour annoncer les
canaux nouveaux et modifiés, les [messages en oignons][topic onion messages], les [chemins aveugles]
[topic rv routing], le sondage et partage d'équilibre, le [routage trampoline][topic trampoline payments],
et les protocoles d'[offres][topic offers] et LNURL.

## Juillet

{:#onion-message-limiting}
En juillet, Bastien Teinturier a [publié][news207 onion] un résumé d'une idée
qu'il attribue à Rusty Russell pour limiter le débit des [messages en oignon]
[topic onion messages] afin d'empêcher les attaques par déni de service.
Cependant, Olaoluwa Osuntokun a suggéré de reconsidérer sa [proposition][news190 onion]
de mars pour empêcher l'abus des messages en oignon en faisant payer le relai
des données. Il semble que la plupart des développeurs participant à la discussion
préfèrent tenter de limiter le débit avant d'ajouter des frais supplémentaires au protocole.

{:#miniscript-descriptors}
Ce mois-ci, Bitcoin Core a également [fusionné un PR][news209 miniscript]
en ajoutant la prise en charge de la surveillance uniquement pour les
[descripteurs de script de sortie][topic descriptors] écrits en [miniscript][topic miniscript].
Un futur PR devrait permettre au portefeuille de créer des signatures pour
les descripteurs de dépenses basés sur miniscript. À mesure que d'autres
portefeuilles et dispositifs de signature mettent en œuvre la prise en charge
de miniscript, il devrait être plus facile de transférer des politiques
entre portefeuilles ou de faire coopérer plusieurs portefeuilles pour dépenser
des bitcoins, par exemple des politiques multi-sig ou des politiques impliquant
différents signataires pour différentes occasions (par exemple, des signataires de secours)

## Août

{:#dual-funding}
En août, Eclair a [fusionné le support][news213 dual funding] pour
le protocole de financement interactif, une dépendance pour le
[protocole de financement double][topic dual funding] qui permet à
l'un (ou aux deux) des deux noeuds de contribuer aux fonds d'un nouveau
canal LN. Plus tard dans le mois, une autre [fusion][news215 dual funding]
a apporté à Eclair un support expérimental pour le double financement.
Un protocole ouvert pour le double financement peut contribuer à garantir
que les commerçants ont accès à des canaux qui leur permettent de recevoir
immédiatement les paiements des clients.

{:#jamming}
Antoine Riard et Gleb Naumenko ont [publiés][news214 jam] un guide sur les
[attaques par brouillage de canaux][topic channel jamming attacks] et proposé
plusieurs ssolutions. Pour chaque canal qu'un attaquant contrôle, il peut rendre
plus d'une douzaine d'autres canaux inutilisables en envoyant des paiements qui
n'aboutissent jamais---ce qui signifie que l'attaquant n'a pas besoin de payer
de coûts directs. Le problème est connu depuis 2015, mais aucune solution proposée
précédemment n'a été largement acceptée. En novembre, Clara Shikhelman et Sergei
Tikhomirov publiaient leur propre [papier][news226 jam] avec une analyse et une
proposition de solution basée sur de petits frais initiaux et des renvois automatisés
basés sur la réputation. Par la suite, Riard a [publié][news228 jam] une solution
alternative impliquant des jetons non négociables spécifiques aux nœuds. En décembre,
Joost Jager [annonce][news230 jam] un utilitaire "simple mais imparfait" qui pourrait
aider les nœuds à atténuer certains problèmes de brouillage sans nécessiter de
modifications du protocole LN.

{:.center}
![Illustration of the two types of channel jamming attacks](/img/posts/2020-12-ln-jamming-attacks.png)

{:#dlc-bls}
Lloyd Fournier a [écrit][news213 bls] sur les avantages des oracles [DLC][topic dlc]
qui font leurs attestations en utilisant des signatures Boneh-Lynn-Shacham ([BLS][]).
Bitcoin ne prend pas en charge les signatures BLS et un soft fork serait nécessaire
pour les ajouter, mais Fournier renvoie à un article qu'il a co-écrit et qui décrit
comment les informations peuvent être extraites en toute sécurité d'une signature BLS
et utilisées avec des [adaptateurs de signature][topic adaptor signatures] compatibles
avec Bitcoin sans aucune modification de Bitcoin. Cela permettrait d'avoir des oracles
"sans état" où les parties à un contrat (mais pas l'oracle) pourraient se mettre d'accord
en privé sur les informations qu'elles veulent que l'oracle atteste, par exemple en
spécifiant un programme écrit dans n'importe quel langage de programmation qu'ils savent
que l'oracle peut exécuter. Ils pourraient ensuite allouer leurs fonds de dépôt conformément
au contrat sans même dire à l'oracle qu'ils prévoyaient de l'utiliser. Au moment de régler
le contrat, chacune des parties pouvait exécuter le programme elle-même et, si elles étaient
toutes d'accord sur le résultat, régler le contrat en coopération sans faire intervenir
l'oracle. Si elles n'étaient pas d'accord, n'importe laquelle d'entre elles pouvait envoyer
le programme à l'oracle (peut-être avec un petit paiement pour son service) et recevoir en
retour une attestation BLS du code source du programme et de la valeur obtenue en l'exécutant.
L'attestation pourrait être transformée en signatures qui permettraient de régler le DLC sur
la chaîne. Comme avec les contrats DLC actuels, l'oracle ne saurait pas quelles transactions
onchain sont basées sur ses signatures BLS.

<div markdown="1" class="callout" id="optech">

### Résumé 2022<br>Bitcoin Optech

Au cours de la cinquième année d'Optech, nous avons publié 51 [bulletins][]
hebdomadaires et ajouté 11 nouvelles pages à notre [index des sujets][].
Au total, Optech a publié plus de 70 000 mots sur la recherche et le
développement du logiciel Bitcoin cette année, soit l'équivalent approximatif
d'un livre de 200 pages. <!-- wc -w
_posts/en/newsletters/2022-* ; a typical book has about 350 words per page -->

</div>

## Septembre

{:#fee-ratecards}
Lisa Neigut a [posté][news219 ratecards] sur la liste de diffusion Lightning-Dev
une proposition de tarification des frais qui permettrait à un nœud d'annoncer
quatre tarifs échelonnés pour les frais de transfert. Une meilleure publicité
des frais d'acheminement, y compris la possibilité de fixer des frais négatifs
dans certains cas, pourrait contribuer à garantir que les nœuds d'acheminement
ont suffisamment de capacité pour relayer les paiements vers leur destination
finale. Le développeur ZmnSCPxj, qui avait [posté]news204 lnfees] sa propre solution
payante pour améliorer le routage plus tôt dans l'année, a décrit une façon simple
d'utiliser les cartes tarifaires : "vous pouvez modéliser une carte tarifaire comme
quatre canaux séparés entre les deux mêmes nœuds, avec des coûts différents pour chacun.
Si le chemin au coût le plus bas échoue, il suffit d'essayer une autre route qui peut
avoir plus de sauts mais un coût effectif plus faible, ou bien essayer le même canal
à un coût plus élevé." Une autre méthode de contrôle des flux de paiement a été
[suggérée][news220 flow control] par René Pickhardt.

## Octobre

{:#v3-tx-relay}
En octobre, Gloria Zhao a [proposé][news220 v3] d'autoriser les transactions
via la version numéro 3 à utiliser un ensemble modifié de politiques
de relais de transaction. Ces politiques sont basées sur l'expérience de
l'utilisation de [CPFP][topic cpfp] et de [RBF][topic rbf], plus des idées
pour les [relais de paquets][topic package relay], et sont conçues pour aider
à prévenir les [attaques par épinglage][topic transaction pinning] contre les
protocoles de contrat à deux parties comme LN---en s'assurant que les utilisateurs
peuvent rapidement obtenir des transactions confirmées pour fermer les canaux,
régler les paiements ([HTLCs][topic htlc]), et appliquer les pénalités pour
mauvais comportement. Greg Sanders [suivra][news223 ephemeral] plus tard dans
le mois avec une proposition supplémentaire pour les *ancres éphémères*, une
forme simplifiée des [sorties ancrées][topic anchor outputs] déjà utilisables
avec la plupart des implémentations de LN.

{:#async-payments}
Eclair a ajouté le [support][news220 async] pour une forme basique de paiements
asynchrones lorsque le [relai par tremplin][topic trampoline payments] est utilisé.
Les paiements asynchrones permettent de payer un nœud hors ligne (comme un
portefeuille mobile) sans confier les fonds à un tiers. Le mécanisme idéal pour
les paiements asynchrones dépend de [PTLC][topic ptlc], mais une implémentation
partielle nécessite simplement qu'un tiers retarde l'envoi des fonds jusqu'à ce
que le nœud hors ligne revienne en ligne. Les nœuds Trampoline peuvent fournir
ce délai et ce PR les utilise donc pour permettre l'expérimentation des paiements
asynchrones.

{:#parsing-bugs}
Le mois d'octobre a également été marqué par le [premier][news222 bug] de deux
bogues d'analyse des blocs qui ont affecté plusieurs applications. Un bogue
déclenché accidentellement dans BTCD l'a empêché, ainsi que le programme en aval
LND, de traiter les derniers blocs. Cela aurait pu conduire les utilisateurs à
perdre des fonds, bien qu'aucun problème de ce type n'ait été signalé. Un
[deuxième][news225 bug] bogue apparenté, cette fois-ci délibérément déclenché,
a de nouveau affecté BTCD et LND, ainsi que les utilisateurs de certaines versions
de Rust-Bitcoin. Là encore, les utilisateurs risquaient de perdre de l'argent,
bien que nous n'ayons pas connaissance d'incidents signalés.

{:#zk-rollups}
John Light a [posté][news222 rollups] un rapport de recherche qu'il a préparé
sur les validity rollups---un type de sidechain où l'état actuel de la sidechain
est stocké de manière compacte sur la chaîne principale. Un propriétaire de bitcoins
de sidechain peut utiliser l'état stocké sur la chaîne principale pour prouver
combien de bitcoins il contrôle dans la sidechain. En soumettant une transaction sur
la chaîne principale avec une preuve de validité, il peut retirer les bitcoins
qu'il possède sur la chaîne latérale, même si les opérateurs ou les mineurs de
la chaîne latérale tentent d'empêcher le retrait. Les recherches de Light décrivent
en profondeur les validity rollups, examinent la manière dont leur prise en charge
pourrait être ajoutée à Bitcoin et étudient les différents problèmes liés à
leur mise en œuvre.

{:#v2-transport}
La proposition de [BIP324][] pour un [protocole de transport P2P v2 crypté][news222 v2trans]
a été mise à jour et discutée sur la liste de diffusion pour la première fois en
trois ans. Le cryptage du transport des transactions non confirmées peut aider
à cacher leur origine aux oreilles indiscrètes qui contrôlent de nombreux relais
Internet (par exemple, les grands FAI et les gouvernements). Il peut également
aider à détecter les falsifications et éventuellement rendre les [attaques par éclipse][topic eclipse attacks]
plus difficiles.

{:#core-meet}
Lors d'une réunion des développeurs du protocole Bitcoin, plusieurs sessions
ont été [transcrites][news223 xscribe] par Bryan Bishop, notamment des discussions
sur [le cryptage du transport][topic v2 p2p transport], les frais de transaction
et [la sécurité économique][topic fee sniping], le schéma FROST [threshold signature][topic threshold signature],
la durabilité de l'utilisation de GitHub pour l'hébergement de discussions sur le
code source et le développement, y compris les spécifications prouvables dans les BIP,
le [relais de paquet][topic package relay] et le [relai de transaction v3][topic v3 transaction relay],
le protocole minier Stratum version 2, et la fusion du code dans Bitcoin Core et
d'autres projets de logiciels libres.

<div markdown="1" class="callout" id="softforks">

### résumé 2022<br>propositions de Soft fork

Le mois de janvier a commencé avec Jeremy Rubin [organisant][news183a ctv]
la première de plusieurs réunions IRC pour examiner et discuter de la proposition
de  soft fork [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV).
Pendant ce temps, Peter Todd a [posté][news183b ctv] plusieurs préoccupations
concernant la proposition sur la liste de diffusion Bitcoin-Dev, en particulier
le fait qu'elle ne semble pas bénéficier à la quasi-totalité des utilisateurs
de Bitcoin, comme il pense que les soft forks précédents l'ont fait.

Lloyd Fournier a [posté][news185 ctv] aux listes de diffusion DLC-Dev et
Bitcoin-Dev sur la façon dont l'opcode CTV pourrait réduire radicalement
le nombre de signatures requises pour créer certains [Discreet Log Contracts][topic dlc]
(DLC), ainsi que le nombre de certaines autres opérations. Jonas Nick a fait
remarquer qu'une optimisation similaire est également possible en utilisant
le mode de hachage de signature proposé [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] (APO).

Russell O'Connor [a proposé][news185 txhash] une alternative au CTV et à
l'APO---un soft fork ajoutant un opcode `OP_TXHASH` et un opcode
[OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] (CSFS). L'opcode TXHASH
spécifie quelles parties d'une transaction de dépense doivent être sérialisées
et hachées, le condensé de hachage étant placé sur la pile d'évaluation pour
que les opcodes suivants puissent l'utiliser. L'opcode CSFS spécifierait une
clé publique et exigerait une signature correspondante sur des données
particulières de la pile---comme le condensé calculé de la transaction créé
par TXHASH. Cela permettrait l'émulation de CTV et APO d'une manière qui
pourrait être plus simple, plus flexible, et plus facile à étendre par
d'autres soft forks ultérieures.

En février, Rusty Russell [proposait][news187 optx] `OP_TX`, une version encore
plus simple de `OP_TXHASH`. Pendant ce temps, Jeremy Rubin [publiait][news188 ctv]
les paramètres et le code d'un [signet][topic signet] avec CTV activé. Cela
simplifie l'expérimentation publique de l'opcode proposé et permet de tester
beaucoup plus facilement la compatibilité entre les différents logiciels qui
utilisent ce code. Toujours en février, le développeur ZmnSCPxj a proposé un
nouvel opcode `OP_EVICT` comme alternative à l'opcode `OP_TAPLEAF_UPDATE_VERIFY`
(TLUV) proposé en 2021. Comme TLUV, EVICT est axé sur les cas d'utilisation où
plus de deux utilisateurs partagent la propriété d'un seul UTXO, comme les
[joinpools][topic joinpools], les [usines à canaux][topic channel factories],
et certaines [conditions de dépenses][topic covenants]. ZmnSCPxj proposera plus
tard un nouvel opcode différent, `OP_FOLD`, comme une construction plus générale
à partir de laquelle un comportement de type EVICT pourrait être construit
(bien que cela nécessiterait d'autres changements dans le langage Script).

En mars, la discussion sur le CTV et les propositions d'opcode plus récentes
ont conduit à une [discussion][news190 recov] sur la limitation de l'expressivité
du langage Script de Bitcoin, principalement pour empêcher les *conditions de
dépenses récursives*---conditions qui devraient être remplies à perpétuité dans chaque
transaction dépensant à nouveau ces bitcoins ou tout autre bitcoin fusionné
avec lui. Les préoccupations concernaient notamment la perte de
résistance à la censure, l'activation de [drivechains][topic sidechains],
l'encouragement de calculs inutiles et la possibilité pour les utilisateurs
de perdre accidentellement des pièces en raison de conditions de dépenses récursives.

Le mois de mars a également été marqué par une autre idée de modification du langage
Script de Bitcoin, cette fois pour permettre aux futures transactions d'opter pour un
langage complètement différent basé sur Lisp. Anthony Towns a [proposé][news191 btc-script]
l'idée et décrit comment elle pourrait être meilleure que Script et qu'un remplacement
proposé précédemment : [Simplicity][topic simplicity].

En avril, Jeremy Rubin a [posté][news197 ctv] sur la liste de diffusion
Bitcoin-Dev son projet de lancer un logiciel qui permettra aux mineurs
de commencer à signaler s'ils ont l'intention d'appliquer les règles [BIP119][]
pour l'opcode CTV proposé. Cela a suscité des discussions sur le CTV et
des propositions similaires, telles que l'APO. Rubin a ensuite annoncé
qu'il ne publierait pas de logiciel compilé pour activer CTV pour le moment,
car lui et d'autres partisans de CTV évaluaient les réactions qu'ils avaient reçues.

En mai, Rusty Russell a [mis à jour][news200 ctv] sa proposition `OP_TX`.
La proposition initiale autorisait les conditions de dépenses récursives,
ce qui a suscité les préoccupations mentionnées plus haut dans cette section.
Au lieu de cela, Russell a proposé une version initiale de TX qui
se limitait à permettre le comportement de CTV, qui avait été spécifiquement
conçu pour empêcher les conditions récursives. Cette nouvelle version de TX
pourrait être mise à jour progressivement à l'avenir pour fournir des
fonctionnalités supplémentaires, ce qui la rendrait plus puissante mais
permettrait également à ces nouvelles fonctionnalités d'être analysées
indépendamment. Une discussion complémentaire en mai a examiné l'opcode
`OP_CAT` (supprimé de Bitcoin en 2010), que certains développeurs suggèrent
occasionnellement d'ajouter à l'avenir.

En septembre, Jeremy Rubin a [décrit][news218 apo] comment une procédure
de configuration en confiance pourrait être combinée avec la fonctionnalité
APO proposée pour mettre en œuvre un comportement similaire à celui proposé
par les [drivechains][topic sidechains]. Empêcher l'implémentation de drivechains
sur Bitcoin était l'une des raisons pour lesquelles le développeur ZmnSCPxj
a suggéré plus tôt dans l'année que les opérateurs de nœuds complets pourraient
vouloir s'opposer aux soft forks qui permettent des conditions de dépense récursives.

En septembre également, Anthony Towns a [annoncé][news219 inquisition]
une implémentation de Bitcoin conçue spécifiquement pour tester les
soft forks sur [signet][topic signet]. Basé sur Bitcoin Core, le code
de Towns appliquera des règles pour les propositions de soft forks avec
des spécifications et des implémentations de haute qualité, ce qui
permettra aux utilisateurs d'expérimenter plus facilement les changements
proposés---y compris en comparant les changements entre eux ou en voyant
comment ils interagissent. Towns prévoit également d'inclure les changements
majeurs proposés à la politique de relais des transactions (tels que le
[relai de paquet][topic package relay]).

En novembre, Salvatore Ingala a [posté][news226 matt] sur la liste de
diffusion Bitcoin-Dev une proposition pour un nouveau type de condition
de dépense (nécessitant un soft fork) qui permettrait d'utiliser des arbres
de merkle pour créer des contrats intelligents qui peuvent transporter
l'état d'une transaction onchain à une autre. Cela serait similaires aux
contrats intelligents utilisés sur d'autres systèmes de cryptomonnaies,
mais serait compatible avec le système existant de Bitcoin basé sur UTXO.

</div>

## Novembre

{:#fat-errors}
Le mois de novembre a vu Joost Jager [mettre à jour][news224 fat] une proposition de 2019
visant à améliorer le signalement des erreurs dans LN en cas d'échec des paiements. L'erreur
signalerait l'identité d'un canal où un paiement n'a pas pu être transmis par un nœud afin
que le payeur puisse éviter d'utiliser les canaux impliquant ce nœud pendant un temps limité.
Plusieurs implémentations de LN ont mis à jour leur code pour prendre en charge la proposition,
même si elles n'ont pas immédiatement commencé à l'utiliser elles-mêmes, notamment [Eclair][news225 fat]
et [Core Lightning][news226 fat].

## Décembre

{:#ln-mod}
En décembre, le développeur de protocole John Law a posté sur la liste d'envoi Lightning-Dev
sa troisième proposition majeure de l'année. Comme ses deux précédentes propositions,
il a suggéré de nouvelles façons dont les transactions hors chaîne de LN pourraient être
conçues pour permettre l'ajout de nouvelles fonctionnalités sans nécessiter de modification
au code de consensus de Bitcoin. Dans l'ensemble, Law a proposé des moyens pour les utilisateurs
occasionnels de LN de [rester hors ligne][news221 ln-mod] pendant plusieurs mois,
[séparer][law tunable] l'exécution de paiements spécifiques de la part du
gestionnaire de tous les fonds réglés afin d'améliorer la compatibilité avec les
[watchtowers][topic watchtowers], et [optimisé][news230 ln-mod] les canaux LN
pour une utilisation en [usines à canaux][topic channel factories] qui
pourrait réduire de manière significative les coûts de l'utilisation du LN sur la chaîne.

*Nous remercions tous les contributeurs de Bitcoin cités ci-dessus, ainsi que les nombreuses personnes dont le travail était tout aussi important, pour une autre année incroyable de développement du bitcoin. La lettre d'information d'Optech reprendra son cours normal de publication dès le mercredi 4 janvier.*

{% include references.md %}
{% include linkers/issues.md v=2 issues="" %}
[bls]: https://en.wikipedia.org/wiki/BLS_digital_signature
[cjdns]: https://github.com/cjdelisle/cjdns
[law tunable]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-October/003732.html
[news181 ldk1177]: /en/newsletters/2022/01/05/#rust-lightning-1177
[news181 rbf]: /en/newsletters/2022/01/05/#brief-full-rbf-then-opt-in-rbf
[news182 accounts]: /en/newsletters/2022/01/12/#fee-accounts
[news182 bolts912]: /en/newsletters/2022/01/12/#bolts-912
[news183a ctv]: /en/newsletters/2022/01/19/#irc-meeting
[news183b ctv]: /en/newsletters/2022/01/19/#mailing-list-discussion
[news183 defense fund]: /en/newsletters/2022/01/19/#bitcoin-and-ln-legal-defense-fund
[news183 stateless]: /en/newsletters/2022/01/19/#eclair-2063
[news185 ctv]: /en/newsletters/2022/02/02/#improving-dlc-efficiency-by-changing-script
[news185 eclair]: /en/newsletters/2022/02/02/#eclair-0-7-0
[news185 txhash]: /en/newsletters/2022/02/02/#composable-alternatives-to-ctv-and-apo
[news186 rbf]: /en/newsletters/2022/02/09/#discussion-about-rbf-policy
[news187 optx]: /en/newsletters/2022/02/16/#simplified-alternative-to-op-txhash
[news188 ctv]: /en/newsletters/2022/02/23/#ctv-signet
[news188 ldk1199]: /en/newsletters/2022/02/23/#ldk-1199
[news188 sponsorship]: /en/newsletters/2022/02/23/#fee-bumping-and-transaction-fee-sponsorship
[news189 btcpay]: /en/newsletters/2022/03/02/#btcpay-server-1-4-6
[news189 evict]: /en/newsletters/2022/03/02/#proposed-opcode-to-simplify-shared-utxo-ownership
[news190 ldk]: /en/newsletters/2022/03/09/#ldk-0-0-105
[news190 onion]: /en/newsletters/2022/03/09/#paying-for-onion-messages
[news190 recov]: /en/newsletters/2022/03/09/#limiting-script-language-expressiveness
[news191 btc-script]: /en/newsletters/2022/03/16/#using-chia-lisp
[news191 fold]: /en/newsletters/2022/03/16/#looping-folding
[news191 rbf]: /en/newsletters/2022/03/16/#ideas-for-improving-rbf-policy
[news192 ldk1311]: /en/newsletters/2022/03/23/#ldk-1311
[news192 pp]: /en/newsletters/2022/03/23/#payment-delivery-algorithm-update
[news193 bdk]: /en/newsletters/2022/03/30/#bdk-0-17-0
[news193 witrep]: /en/newsletters/2022/03/30/#transaction-witness-replacement
[news194 sp]: /en/newsletters/2022/04/06/#delinked-reusable-addresses
[news195 musig2]: /en/newsletters/2022/04/13/#musig2-proposed-bip
[news195 stateless]: /en/newsletters/2022/04/13/#core-lightning-5086
[news195 taro]: /en/newsletters/2022/04/13/#transferable-token-scheme
[news196 qc]: /en/newsletters/2022/04/20/#quantum-safe-key-exchange
[news196 stateless]: /en/newsletters/2022/04/20/#lnd-5810
[news197 bcc]: /en/newsletters/2022/04/27/#bitcoin-core-23-0
[news197 cln]: /en/newsletters/2022/04/27/#core-lightning-0-11-0
[news197 ctv]: /en/newsletters/2022/04/27/#discussion-about-activating-ctv
[news197 rb]: /en/newsletters/2022/04/27/#rust-bitcoin-0-28
[news198 btcpay]: /en/newsletters/2022/05/04/#btcpay-server-1-5-1
[news198 lbk]: /en/newsletters/2022/05/04/#bitcoin-core-24322
[news198 musig2]: /en/newsletters/2022/05/04/#musig2-implementation-notes
[news200 cat]: /en/newsletters/2022/05/18/#when-would-enabling-op-cat-allow-recursive-covenants
[news200 ctv]: /en/newsletters/2022/05/18/#updated-op-tx-proposal
[news201 package relay]: /en/newsletters/2022/05/25/#package-relay-proposal
[news202 sp]: /en/newsletters/2022/06/01/#experimentation-with-silent-payments
[news203 zero-conf]: /en/newsletters/2022/06/08/#bolts-910
[news204 ln]: /en/newsletters/2022/06/15/#summary-of-ln-developer-meeting
[news204 lnfees]: /en/newsletters/2022/06/15/#using-routing-fees-to-signal-liquidity
[news204 package relay]: /en/newsletters/2022/06/15/#continued-package-relay-bip-discussion
[news205 bdk]: /en/newsletters/2022/06/22/#bdk-0-19-0
[news205 ldk]: /en/newsletters/2022/06/22/#ldk-0-0-108
[news205 rbf]: /en/newsletters/2022/06/22/#full-replace-by-fee
[news205 scid]: /en/newsletters/2022/06/22/#eclair-2224
[news206 lnd]: /en/newsletters/2022/06/29/#lnd-0-15-0-beta
[news207 onion]: /en/newsletters/2022/07/06/#onion-message-rate-limiting
[news208 rbf]: /en/newsletters/2022/07/13/#bitcoin-core-25353
[news208 scid cln]: /en/newsletters/2022/07/13/#core-lightning-5275
[news208 scid lnd]: /en/newsletters/2022/07/13/#lnd-5955
[news209 miniscript]: /en/newsletters/2022/07/20/#bitcoin-core-24148
[news213 bls]: /en/newsletters/2022/08/17/#using-bitcoin-compatible-bls-signatures-for-dlcs
[news213 dual funding]: /en/newsletters/2022/08/17/#eclair-2273
[news213 rb]: /en/newsletters/2022/08/17/#rust-bitcoin-0-29
[news214 cln]: /en/newsletters/2022/08/24/#core-lightning-0-12-0
[news214 jam]: /en/newsletters/2022/08/24/#overview-of-channel-jamming-attacks-and-mitigations
[news214 sp]: /en/newsletters/2022/08/24/#updated-silent-payments-pr
[news215 dual funding]: /en/newsletters/2022/08/31/#eclair-2275
[news215 lnd]: /en/newsletters/2022/08/31/#lnd-0-15-1-beta
[news217 ldk]: /fr/newsletters/2022/09/14/#ldk-0-0-111
[news218 apo]: /fr/newsletters/2022/09/21/#creer-des-drivechains-avec-apo-et-une-installation-en-confiance
[news219 inquisition]: /fr/newsletters/2022/09/28/#implementation-de-bitcoin-concue-pour-tester-les-soft-forks-sur-signet
[news219 ratecards]: /fr/newsletters/2022/09/28/#fees-ratecards
[news220 async]: /fr/newsletters/2022/10/05/#eclair-2435
[news220 flow control]: /fr/newsletters/2022/10/05/#ln-flow-control
[news220 v3]: /fr/newsletters/2022/10/05/#proposition-de-nouvelle-politique-de-relai-de-transaction-concue-pour-les-penalites-sur-ln
[news221 ln-mod]: /fr/newsletters/2022/10/12/#ln-avec-une-proposition-de-hors-ligne-long
[news222 bug]: /fr/newsletters/2022/10/19/#bug-d-analyse-de-bloc-affectant-btcd-et-lnd
[news222 musig2]: /fr/newsletters/2022/10/19/#validite-de-la-securite-de-musig2
[news222 rbf]: /fr/newsletters/2022/10/19/#option-de-remplacement-de-transaction
[news222 rollups]: /fr/newsletters/2022/10/19/#recherche-sur-les-rollups-de-validite
[news222 v2trans]: /fr/newsletters/2022/10/19/#mise-a-jour-bip324
[news223 ephemeral]: /fr/newsletters/2022/10/26/#ephemeral-anchors
[news223 rbf]: /fr/newsletters/2022/10/26/#poursuite-de-la-discussion-sur-le-full-rbf
[news223 xscribe]: /fr/newsletters/2022/10/26/#coredev-tech-transcription
[news224 fat]: /fr/newsletters/2022/11/02/#attribution-de-l-echec-du-routage-ln
[news224 rbf]: /fr/newsletters/2022/11/02/#coherence-mempool
[news225 bug]: /fr/newsletters/2022/11/09/#bogue-d-analyse-des-blocs-affectant-plusieurs-logiciels
[news225 fat]: /fr/newsletters/2022/11/09/#eclair-2441
[news225 rbf]: /fr/newsletters/2022/11/09/#poursuite-de-la-discussion-sur-l-activation-de-full-rbf
[news226 fat]: /fr/newsletters/2022/11/16/#core-lightning-5698
[news226 jam]: /fr/newsletters/2022/11/16/#document-sur-les-attaques-par-brouillage-de-canaux
[news226 matt]: /fr/newsletters/2022/11/16/#contrats-intelligents-generaux-en-bitcoin-via-des-clauses-restrictives
[news228 jam]: /fr/newsletters/2022/11/30/#proposition-de-references-de-reputation-pour-attenuer-les-attaques-de-brouillage-ln
[news229 cln]: /fr/newsletters/2022/12/07/#core-lightning-22-11
[news230 bcc]: /fr/newsletters/2022/12/14/#bitcoin-core-24-0-1
[news230 jam]: /fr/newsletters/2022/12/14/#brouillage-local-pour-eviter-le-brouillage-a-distance
[news230 libsecp]: /fr/newsletters/2022/12/14/#libsecp256k1-0-2-0
[news230 ln-mod]: /fr/newsletters/2022/12/14/#proposition-d-optimisation-du-protocole-d-usines-a-canaux-ln
[news230 rbf]: /fr/newsletters/2022/12/14/#suivi-des-remplacements-par-full-rbf
[news231 v3relay]: /fr/newsletters/2022/12/21/#v3-tx-relay
[bulletins]: /fr/newsletters/
[index des sujets]: /en/topics/
[yirs 2018]: /en/newsletters/2018/12/28/
[yirs 2019]: /en/newsletters/2019/12/28/
[yirs 2020]: /fr/newsletters/2020/12/23/
[yirs 2021]: /fr/newsletters/2021/12/22/
