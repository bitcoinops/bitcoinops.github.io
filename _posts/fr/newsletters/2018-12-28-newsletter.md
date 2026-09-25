---
title: 'Bulletin Hebdomadaire Bitcoin Optech #27'
permalink: /fr/newsletters/2018/12/28/
name: 2018-12-28-newsletter-fr
slug: 2018-12-28-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine est une édition spéciale de fin d'année résumant les développements notables de Bitcoin pendant toute l'année
2018. Malgré la longueur étendue de ce bulletin, nous regrettons qu'il ne couvre qu'une infime fraction du travail réalisé dans des dizaines
de projets open source par des centaines de contributeurs. Sans ces contributions de bas niveau, les idées de haut niveau décrites dans ce
bulletin ne seraient que des mots vides, et nous adressons donc nos plus sincères remerciements à tous ceux d'entre vous qui ont contribué
au développement de Bitcoin cette année.

## Janvier

Des centaines de canaux Lightning Network (LN) étaient ouverts sur testnet avant le début de l'année, mais janvier 2018 a vu quelques
entreprises et utilisateurs commencer à utiliser les paiements LN avec de vrais bitcoins sur mainnet. Les pionniers ont étiqueté leurs
propres actions comme *#reckless,* mais cela n'a guère empêché d'autres expérimentateurs de mettre de l'argent réel en risque sur ce réseau
de paiement naissant.

Ce mois-ci a également vu la publication du protocole interactif de signature multipartite [muSig][] basé sur Schnorr par Gregory Maxwell,
Andrew Poelstra, Yannick Seurin, et Pieter Wuille. Celui-ci fournit la même sécurité que le multisig actuel de Bitcoin, mais peut souvent
réduire la quantité de données de transaction requise à une seule clé publique et signature d'apparence normale. Cela réduit non seulement
la surcharge et les coûts, mais augmente aussi la confidentialité en faisant paraître les transactions multisig de base identiques aux
transactions à signature unique.

<div markdown="1" class="xoverflow shrink80">

| | Script de réception | Données de dépense | |-|-|-| | **Signature unique, Script actuel (P2PK)** | `<pubkey> OP_CHECKSIG` | `<signature>`
| | **Multisig nu, Script actuel** | `2 <pubkey> <pubkey> <pubkey> 3 OP_CHECKMULTISIG` | `OP_0 <signature> <signature>` | | **Multisig,
muSig[^fn-opcodes]** | `<pubkey> OP_CHECKSIG` | `<signature>` |

</div>

{:#taproot} S'appuyant sur l'idée que muSig, ou quelque chose de similaire, pourrait devenir possible dans Bitcoin, Maxwell a ensuite décrit
[Taproot][]---une puissante optimisation pour les Merklized Alternative Script Trees[^fn-mast] ([MAST][]). Tout comme muSig permet au
multisig de base de ressembler à une signature unique, Taproot permet même au script Bitcoin le plus complexe possible de ressembler à une
signature unique si ses participants coopèrent entre eux (mais s'ils ne le font pas, ils reçoivent tout de même la sécurité complète de leur
script choisi). Cela fournit à un ensemble encore plus large d'utilisateurs une surcharge réduite, des coûts réduits, et une confidentialité
accrue.

<div markdown="1" class="xoverflow shrink80">

| | Script de réception | Données de dépense | |-|-|-| | **Utilisateur unique, Script actuel (P2PK)** | `<pubkey> OP_CHECKSIG` |
`<signature>` | | **Utilisateurs coopérants, propositions MAST antérieures[^fn-harding-mast]** | `<hash> OP_MAST` | `<signature> <<pubkey> OP_CHECKSIG> <hash> <flags>` | | **Utilisateurs coopérants, Taproot[^fn-opcodes]** | `<pubkey> OP_CHECKSIG` | `<signature>` |

</div>

## Février

Comme si les avantages potentiels de Taproot ne suffisaient pas, février a vu Gregory Maxwell décrire une construction de celui-ci appelée
[Graftroot][] qui permettrait aux personnes actuellement autorisées à dépenser une pièce de créer des ensembles supplémentaires de
conditions permettant de dépenser la pièce---sans créer une nouvelle transaction. À tout moment, n'importe lequel des ensembles autorisés de
conditions pourrait être utilisé pour dépenser les pièces. Par exemple, si une pièce peut actuellement être dépensée par accord entre Alice
et Bob (multisig 2-sur-2), ils pourraient tous deux convenir de permettre qu'elle soit dépensée par n'importe quels deux parmi Alice, Bob,
ou leur avocat Charlie (multisig 2-sur-3)---et ils pourraient faire ce choix des années après avoir reçu la pièce pour la première fois sans
créer de nouvelle transaction. Cela pourrait encore accroître l'efficacité et la confidentialité, en particulier pour certains protocoles de
contrats hors chaîne.

{:#multipath-payments} Pendant ce temps, les développeurs du protocole LN Olaoluwa Osuntokun et Conner Fromknecht ont décrit une [nouvelle
façon d'effectuer des paiements multipath sur LN][ln multipath]. Les paiements multipath sont des paiements dont les parties sont réparties
sur plusieurs canaux---par exemple, Alice peut envoyer une partie d'un paiement à Zed via son canal avec Bob et une partie via son canal
avec Charlie.

<div markdown="1" class="xoverflow shrink80">

| Chemin unique | Multipath | |-|-| | Alice → Bob → Zed | Alice → {Bob, Charlie} → Zed |

</div>

Les auteurs ont noté que LN fournit un support natif pour les paiements multipath en utilisant la même préimage d'engagement (hashlock) pour
chaque partie du paiement, mais que l'utilisation de ce mécanisme permet à des tiers de détecter qu'ils traitent différentes parties du même
paiement. Ils ont ensuite décrit un protocole plus complexe qui pourrait empêcher cette corrélation et potentiellement fournir d'autres
avantages. Que la méthode plus simple ou la méthode plus complexe soit utilisée, l'une ou l'autre pourrait améliorer de manière
significative l'utilisabilité de LN en supprimant la contrainte selon laquelle un utilisateur doit avoir un seul canal avec suffisamment de
fonds pour effectuer un paiement. Par exemple, dans le protocole actuel, si Alice a deux canaux ayant chacun un peu plus de 100 $
disponibles, elle ne peut envoyer en toute sécurité à Zed qu'un maximum de 100 $ dans un seul paiement. Avec un paiement multipath, Alice
peut envoyer 200 $ en répartissant le paiement sur les deux canaux.

Février s'est terminé avec un peu de parallélisme historique. Un des premiers contributeurs à Bitcoin et la première personne connue à avoir
acheté une pizza avec Bitcoin, Laszlo Hanyecz, a [acheté][offchain pizza] deux pizzas en utilisant LN pour 6,49 mBTC---un prix bien plus bas
en termes de BTC que les 10 millions de mBTC qu'il a [payés][onchain pizza] pour deux pizzas en mai 2010.

## Mars

De nombreux utilisateurs de Bitcoin connaissent la possibilité de créer des messages signés correspondant à leurs adresses Bitcoin. Il
n'existe actuellement aucune méthode standard pour faire cela avec des adresses P2SH ou segwit. Une discussion en mars finirait par se
transformer en [BIP322][], une proposition visant à créer un format générique capable de créer une preuve de signature pour tout script
Bitcoin dépensable.

<div markdown="1" class="callout">

### sommaire 2018<br>Principales versions de projets d'infrastructure populaires

- [Bitcoin Core 0.16][] publié en février incluait un support par défaut dans le portefeuille pour recevoir vers des adresses segwit, le
  support de [BIP159][] pour permettre aux nœuds élagués de signaler leur volonté de servir des blocs récents, et un certain nombre
  d'améliorations de performance.

- [LND 0.4-beta][] publié en mars fut la première version de LND visant le support du mainnet. Elle prenait aussi en charge l'utilisation de
  Bitcoin Core comme backend, l'utilisation de Tor pour les connexions, et de nombreuses autres fonctionnalités.

- [C-Lightning 0.6][] publié en juin a réduit les besoins en ressources, fourni un portefeuille intégré, et ajouté le support de Tor.

- [LND 0.5-beta][] publié en septembre incluait de nombreux changements axés sur le fait de rendre le système beaucoup plus fiable. Il a
  également supprimé l'exigence pour les backends de nœuds complets de conserver un index des transactions, améliorant les performances et
  réduisant les besoins en espace disque.

- [Bitcoin Core 0.17][] publié en octobre incluait l'évitement partiel facultatif de dépenses, la capacité de créer et charger dynamiquement
  des portefeuilles, et le support de transactions Bitcoin partiellement signées [BIP174][] pour la communication entre programmes Bitcoin.

</div>

## Avril

Les développeurs du protocole LN Christian Decker, Rusty Russell, et Olaoluwa Osuntokun ont annoncé [Eltoo][], un mécanisme d'application
alternatif proposé pour LN. Le mécanisme actuel ([LN-penalty][]) exige de rendre les mises à jour précédentes de solde hors chaîne
dangereuses afin que les utilisateurs n'essaient pas de les mettre onchain. Le mécanisme Eltoo permet la dépense onchain de mises à jour
précédentes de solde vers des mises à jour de solde ultérieures dans une fenêtre de temps limitée. En fonctionnement normal, les parties
publieraient normalement simplement le solde final du canal onchain, mais même si une partie publiait un ancien solde, sa contrepartie du
canal pourrait simplement publier une seconde transaction le corrigeant vers le solde final. Aucune des parties ne perdrait quoi que ce soit
sauf les frais de transaction qu'elles ont payés.

L'avantage d'Eltoo est que le logiciel utilisateur n'a pas besoin de gérer les données qui rendent dangereuses les mises à jour antérieures
de solde. Cela simplifie les sauvegardes et réduit les risques associés à la perte de données---mais peut-être plus important encore, cela
rend beaucoup plus facile et plus efficace sur le plan computationnel l'ouverture de canaux de paiement entre de nombreux utilisateurs dans
une seule transaction onchain. Cela pose les bases d'autres propositions telles que les [Channel Factories][] qui pourraient rendre les
canaux LN 10x ou plus efficaces dans leurs opérations onchain.

{:#sighash_noinput} Eltoo nécessite un soft fork pour ajouter un nouveau hash de signature optionnel, [BIP118][]
SIGHASH_NOINPUT_UNSAFE.[^fn-unsafe] Cela permettrait à une signature autorisant la dépense d'un UTXO d'indiquer que la signature ne
s'applique pas seulement à cet UTXO mais à n'importe quel UTXO qui pourrait être dépensé par une signature provenant de la même clé privée.
De plus, le mécanisme de publication d'Eltoo [pourrait ne pas être fiable et sûr][eltoo pinning] parce que les politiques actuelles de
relais des nœuds permettent l'[épinglage de transaction][]. Malgré cela, les développeurs de protocole semblent optimistes quant à la
proposition et beaucoup espèrent que la fonctionnalité noinput pourra faire partie d'une éventuelle future proposition de soft fork Schnorr
et Taproot.

## Mai

<div id="dandelion" markdown="1">

Un [brouillon de BIP][BIP156] pour le protocole Dandelion a été publié sur la liste de diffusion Bitcoin-Dev en mai. Dandelion peut relayer des
transactions de manière privée de sorte que l'adresse IP du dépensier ne puisse pas être déterminée de manière fiable. Cela fonctionne même
sans utiliser une méthode comme Tor, et Dandelion peut être combiné avec Tor pour diminuer davantage le risque d'un compromis de
confidentialité. Dandelion à lui seul ne bénéficie pleinement qu'aux utilisateurs de nœuds complets qui relaient (et non aux clients légers
P2P[^fn-dandelion-lite]) et il doit être combiné avec une certaine forme de chiffrement pour empêcher les FAI de pouvoir identifier les
dépensiers.

Cependant, Dandelion dépend en partie du fait que les nœuds de relais prétendent n'avoir jamais vu une transaction qu'ils avaient auparavant
aidé à relayer. Cela rend les nœuds vulnérables à des attaques par déni de service qui peuvent gaspiller la bande passante et la mémoire du
nœud---des problèmes que les développeurs sont toujours en train de [travailler à résoudre][daftuar dandelion] avant d'adopter ce protocole.

</div>

<div markdown="1" class="callout">

### Sommaire 2018<br>Conférences techniques notables et autres événements

- [BPASE][bpase], janvier, Stanford University
- [Bitcoin Core developers meetup NYC][coredevtech nyc], mars, New York City ([transcripts][coredevtech ts])
- [L2 Summit][], mai, Boston
- [Building on Bitcoin][], juillet, Lisbonne ([transcripts][bob ts])
- [Edge Dev++][], octobre, Tokyo ([videos][edge dev vids], [transcripts][edge dev ts])
- [Scaling Bitcoin Conference][], octobre, Tokyo. ([videos][scaling bitcoin vids], [transcripts][scaling bitcoin ts])
- [Bitcoin Core developers meetup Tokyo][coredevtech tokyo], octobre, Tokyo ([transcripts][coredevtech ts])
- [Chaincode Lightning Residency][], octobre, New York City ([videos][ln residency vids])
- [Lightning protocol development summit][], novembre, Adelaide

</div>

## Juin

En juin, Matt Corallo a annoncé publiquement un projet sur lequel il travaillait depuis un certain temps : un nouveau protocole de
communication entre un serveur de pool de minage et les mineurs individuels, puis jusqu'aux ASICs effectuant réellement le travail. Nommé
[BetterHash][], le protocole sépare les paiements du pool de la sélection des transactions. Une illustration de l'importance de cela est
apparue plus tard dans l'année lorsque plusieurs pools de minage traditionnels ont [menacé][bitcoin.com forced bch mining] de rediriger leur
puissance de hachage Bitcoin pour travailler sur une altcoin---ce à quoi les mineurs utilisant BetterHash auraient pu résister
automatiquement. Corallo a fourni BetterHash avec à la fois un [brouillon de BIP][betterhash] et une [implémentation fonctionnelle][betterhash
implementation] qui inclut une compatibilité rétroactive avec le protocole de communication de minage prédominant Stratum.

{:#cve-2017-12842} Au même moment, une [vulnérabilité][sdl fake spv proof] connue depuis longtemps de certains développeurs du protocole
Bitcoin a été divulguée publiquement sans le vouloir. [CVE-2017-12842][] permet de créer une preuve SPV pour une transaction qui n'existe
pas en fabriquant spécialement une vraie transaction de 64 octets qui est confirmée dans un bloc. De nombreux portefeuilles légers qui
dépendent de preuves SPV restent vulnérables encore aujourd'hui, mais le coût estimé de l'attaque est plus élevé que l'attaque originale
contre les portefeuilles faisant confiance au SPV décrite par Nakamoto dans la section 8 du [white paper Bitcoin][bitcoin.pdf] de 2009, donc
les clients légers ne semblent pas être significativement moins sûrs qu'auparavant. Pour d'autres cas où des preuves SPV sont utilisées en
conjonction avec un nœud complet, comme lorsqu'elles sont utilisées avec des sidechains fédérées, Bitcoin Core a modifié ses RPC pour
effectuer des vérifications supplémentaires ou fournir des informations additionnelles qui atténuent complètement la vulnérabilité (voir les
PR [#13451][Bitcoin Core #13451] et [#13452][Bitcoin Core #13452]).

Du côté amusant, le site web [satoshis.place][] de Lightning K0ala a connu une popularité soudaine en tant qu'endroit divertissant où
dépenser de vrais bitcoins avec LN. Des centaines d'utilisateurs ont payé un satoshi par pixel pour peindre tout ce qu'ils voulaient sur la
toile partagée, offrant une démonstration en direct étonnamment efficace de la rapidité et de la commodité des paiements LN.

## Juillet

Après plus d'un an de [préavis][alert retirement alert], juillet a commencé par la [publication][alert key release] de la clé privée
précédemment utilisée pour signer les messages d'alerte diffusés à travers le réseau P2P de Bitcoin. Les messages d'alerte ne se
contentaient pas d'avertir les utilisateurs de problèmes mais donnaient aussi, dans certaines anciennes versions du logiciel, à ceux
disposant de la clé d'alerte la capacité de stopper effectivement tout commerce sur le réseau Bitcoin---une centralisation du pouvoir
préoccupante pour un réseau décentralisé. Les détails de multiples vulnérabilités de déni de service contre d'anciens nœuds qui pouvaient
être exécutées avec la clé d'alerte ont été publiés en même temps que la clé.

Dans les nouvelles positives, Pieter Wuille a publié un [brouillon de BIP][schnorr bip] définissant un schéma de signature basé sur Schnorr
avec pour objectif de permettre à chacun de discuter---et, espérons-le, de se mettre d'accord---sur la manière dont cet aspect de l'ajout de
Schnorr à Bitcoin fonctionnerait pendant que d'autres détails d'un possible soft fork sont encore en cours d'élaboration. Le format proposé
serait entièrement compatible avec les clés privées et publiques bitcoin existantes, de sorte que les portefeuilles HD ne devraient pas
avoir besoin de générer de nouvelles graines de récupération. Les signatures seraient environ 10 % plus petites, augmentant légèrement la
capacité onchain. Les signatures pourraient aussi être vérifiées par lots environ 2x plus rapidement qu'elles ne pourraient être vérifiées
individuellement, même en parallèle, accélérant principalement la vérification des blocs pour les nœuds en cours de rattrapage.

Le schéma de signature est compatible avec le protocole muSig décrit en janvier (ou des protocoles similaires) et englobe donc ses avantages
en matière d'efficacité et de confidentialité accrues. L'utilisation de Schnorr simplifie aussi la mise en œuvre de techniques telles que
Taproot, Graftroot, des canaux de paiement plus privés pour LN, des atomic swaps plus privés entre chaînes, des atomic swaps plus privés sur
la même chaîne (permettant une amélioration du coinjoin), et d'autres avancées qui améliorent l'efficacité, la confidentialité, ou les deux.

<div id="p2ep" markdown="1">

Pendant ce temps, des participants à une table ronde sur la confidentialité ont décrit une méthode appelée Pay-to-EndPoint ([P2EP][]) qui
peut améliorer de manière significative la résistance des portefeuilles à l'analyse de la chaîne de blocs en appliquant une forme limitée de
coinjoin aux paiements interactifs. Une [forme simplifiée][bustapay] de la proposition a également été décrite. Le protocole fonctionne en
faisant en sorte que le destinataire d'une transaction mélange une partie de ses bitcoins existants dans la transaction, empêchant un
observateur extérieur de pouvoir supposer automatiquement que toutes les entrées d'une transaction proviennent de la même personne. Plus il
y a de personnes qui utilisent cette technique, moins l'hypothèse d'association des entrées devient fiable---améliorant la confidentialité
pour tous les utilisateurs de Bitcoin, pas seulement pour les personnes qui utilisent P2EP.

{% capture today-private %}Entrées:<br> Alice (2 BTC)<br> Alice (2 BTC)<br><br>Sorties:<br> Monnaie d'Alice (1 BTC)<br> Revenu de Bob (3 BTC){% endcapture %}
{% capture today-public %}Entrées:<br> Dépensier (2 BTC)<br> Dépensier (2 BTC)<br><br>Sorties:<br> Dépensier ou Récepteur (1 BTC)<br>Dépensier ou Récepteur (3 BTC){% endcapture %}
{% capture p2ep-private %}Entrées:<br> Alice (2 BTC)<br> Alice (2 BTC)<br> Bob (3 BTC)<br><br>Sorties:<br> Monnaie d'Alice (1 BTC)<br> Revenu & monnaie de Bob (6 BTC){% endcapture %}
{% capture p2ep-public %}Entrées:<br> Dépensier ou Récepteur (2 BTC)<br> Dépensier ou Récepteur (2 BTC)<br> Dépensier ou Récepteur (3 BTC)<br><br>Sorties:<br> Dépensier ou Récepteur (1 BTC)<br>& Dépensier ou Récepteur (6 BTC){% endcapture %}

</div>

<div markdown="1" class="xoverflow shrink80">

| | Ce qu'Alice et Bob savent | Ce que le réseau voit | |-|-|-| | **Norme actuelle** | {{today-private}} | {{today-public}} | | **Avec
P2EP** | {{p2ep-private}} | {{p2ep-public}} |

</div>

## Août

Un effort de long terme visant à apporter le chiffrement au protocole réseau de Bitcoin a connu de nouveaux développements en août avec
l'ouverture d'une [PR][bitcoin core #14032] vers Bitcoin Core et la publication d'un [BIP151 révisé][BIP151]. Le chiffrement des
communications est déjà possible (et recommandé) via Tor---qui peut fournir d'autres avantages---mais activer le chiffrement par défaut
pourrait aider à protéger un plus grand nombre d'utilisateurs contre l'écoute de leurs FAI.

{:#countersign} Séparément, Pieter Wuille travaille sur un [document en brouillon][untrackable auth] depuis février, basé sur un protocole
qu'il, Gregory Maxwell, et d'autres développent afin de permettre une authentification optionnelle au-dessus du chiffrement. Similaire à
[BIP150][], cela faciliterait l'établissement sécurisé de nœuds sur liste blanche à travers Internet ou de portefeuilles légers liés à des
nœuds de confiance. Il est notable que l'idée actuelle pour cela est de permettre l'authentification sans révéler l'identité à des tiers
afin que les nœuds sur des réseaux d'anonymat (comme Tor) ou les nœuds qui ont simplement changé d'adresse IP ne puissent pas voir leur
identité réseau suivie. Bien que Wuille ait découvert des défauts dans sa proposition initialement documentée, celle-ci a été mise à jour au
fur et à mesure de l'avancement des recherches sur le développement du protocole.

<div markdown="1" class="callout">

### sommaire 2018<br>Bitcoin Optech

Après avoir lancé [Optech][] en mai, nous avons inscrit 15 entreprises comme membres, organisé deux [ateliers][optech workshops], produit 28
bulletins hebdomadaires, construit un tableau de bord, et pris un bon départ sur un livre consacré aux techniques de passage à l'échelle
déployables individuellement. Pour en savoir plus sur ce que nous avons accompli en 2018 et ce que nous avons prévu pour 2019, veuillez
consulter notre court [rapport annuel][optech annual report].

</div>

## Septembre

La grande nouvelle de septembre a été la découverte, la [divulgation][core dup post], la correction, et l'analyse de la vulnérabilité
[CVE-2018-17144][] des entrées dupliquées dans les versions non corrigées de Bitcoin Core 0.14.0 à 0.16.2. La vulnérabilité permettait à un
mineur de créer un bloc qui dépensait les mêmes bitcoins plus d'une fois, permettant une inflation inattendue de la quantité de monnaie
bitcoin. Cela a ensuite été exploité sur testnet (temporairement), démontrant la vulnérabilité mais sans mettre de vrais bitcoins en danger.
Il n'existe aucune preuve que quiconque ait tenté l'attaque contre le mainnet Bitcoin. Toute personne utilisant une version publiée de
Bitcoin Core 0.16.3 ou ultérieure n'est plus en danger.

De tels problèmes ne peuvent finalement être évités qu'en augmentant la quantité de revue et de tests automatisés que reçoivent les
changements de code---et pour cela, Bitcoin a besoin de plus de relecteurs, de plus d'auteurs de tests, et de plus d'organisations engagées
à embaucher ou parrainer de tels contributeurs.

## Octobre

La cinquième [Scaling Bitcoin conference][] au début d'octobre a à la fois introduit de nouvelles idées pour l'avenir de Bitcoin et affiné
des idées existantes. Lors d'événements associés, des [présentations immédiatement pratiques][edge dev++] se sont concentrées sur la
sécurité des plateformes d'échange, la sécurité des portefeuilles, et la gestion sûre des réorganisations et des forks de la chaîne de
blocs. Les développeurs de Bitcoin Core ont aussi [tenu des réunions][coredevtech tokyo] pour donner à chaque développeur l'occasion de
discuter de ses initiatives en cours avec d'autres développeurs.

{:#splicing} Séparément, le développeur du protocole LN Rusty Russell a proposé une méthode pour le [splicing][], qui permet aux
utilisateurs d'ajouter ou de soustraire des fonds d'un canal sans interrompre les paiements dans ce canal. Cela aide particulièrement les
portefeuilles à cacher à leurs utilisateurs les détails techniques de la gestion des soldes. Par exemple, le portefeuille d'Alice peut
automatiquement payer Bob hors chaîne ou onchain depuis le même canal de paiement---hors chaîne en utilisant LN via ce canal de paiement ou
onchain en utilisant un splice out (retrait) depuis ce canal de paiement.

<div markdown="1" class="callout">

### sommaire 2018<br>Nouvelles solutions d'infrastructure open source

- [Electrs][] publié en juillet fournit une réimplémentation efficace d'un serveur de recherche de transactions de type Electrum écrit dans
  le langage de programmation Rust. Les besoins en ressources sont significativement plus faibles que pour les alternatives. Les serveurs de
  type Electrum fournissent le backend de nombreux portefeuilles et de quelques autres services.

- [Subzero][] publié en octobre par Square fournit une suite d'outils et de documentation à utiliser avec un Hardware Security Module (HSM)
  pour la gestion des clés. Il est conçu pour aider les plateformes d'échange et autres dépositaires de bitcoins à stocker leurs bitcoins de
  manière sécurisée.

- [Esplora][] publié en décembre par Blockstream fournit le code frontend et backend pour un explorateur de blocs. Basé en partie sur
  Electrs, il prend en charge mainnet, testnet, et la sidechain Liquid.

</div>

## Novembre

Les développeurs du protocole LN se sont réunis en novembre pour décider quels changements adopter pour la future spécification du protocole
Lightning Network 1.1. Les [changements acceptés][ln1.1 changes] sont fortement axés sur des améliorations d'utilisabilité. Deux
changements, les paiements multipath (décrits ci-dessus en février) et le Splicing (octobre), peuvent ensemble permettre aux portefeuilles
de presque complètement cacher aux utilisateurs la complexité de la gestion des soldes de canaux. Par exemple, en un clic (idéalement),
Alice peut payer Bob jusqu'à presque l'intégralité de son solde de portefeuille à partir de n'importe quelle combinaison de ses canaux,
qu'elle le paie hors chaîne ou onchain.

Parmi les autres changements acceptés figurent l'augmentation de la capacité maximale des canaux, les canaux financés par les deux parties
qui peuvent aider les entreprises à améliorer leur expérience utilisateur LN, et les destinations cachées qui peuvent aider des nœuds à
rester cachés même lorsqu'ils routent des paiements pour des dépensiers arbitraires non fiables. Ces sujets et beaucoup d'autres ont été
[discutés][ln list november] durant ce mois le plus chargé de tous les temps sur la liste de diffusion Lightning-Dev.

L'un des changements souhaités nécessite une dérogation à la politique de relais de Bitcoin Core. Les développeurs LN aimeraient que les
paiements hors chaîne s'engagent sur un montant minimum de frais onchain pendant que le canal est utilisé. Quand le canal est fermé, ils
veulent utiliser l'augmentation des frais pour fixer les frais à un montant approprié aux conditions actuelles du réseau. Cela est rendu
difficile par une partie du code de Bitcoin Core destiné à prévenir les attaques par déni de service qui malheureusement rendent
l'augmentation des frais peu fiable dans des cas adversariaux, mais le développeur de protocole Matt Corallo a [proposé][cpfp carve out] une
nouvelle règle qui pourrait permettre en toute sécurité l'augmentation des frais dans le cas de paiements LN à deux parties.

## Décembre

{:#libminisketch} Pieter Wuille, Gregory Maxwell, et Gleb Naumenko ont étudié comment réduire la quantité de données utilisée pour relayer
les transactions Bitcoin. Leur résultat initial est [libminisketch][], une bibliothèque qui permet à un utilisateur disposant d'un ensemble
d'éléments (par ex. {1, 2, 3}) d'envoyer efficacement les éléments manquants à un autre utilisateur qui ne possède qu'une partie de cet
ensemble (par ex. {1, 3}). Aucun changement au consensus Bitcoin n'est requis pour cela---c'est simplement une manière différente de
transmettre la même information. Si elle est implémentée pour le relais, elle peut réduire la bande passante globale des nœuds (pour un cas
typique) de [40 % à 80 %][wuille minisketch savings]. Elle maintient aussi une faible bande passante à mesure que le nombre de connexions
augmente, permettant potentiellement aux nœuds d'établir beaucoup plus de connexions avec leurs pairs afin d'améliorer la robustesse du
réseau de relais P2P.

Enfin, alors que 2018 touchait à sa fin, les développeurs continuaient de discuter de la manière dont les signatures Schnorr, Taproot MAST,
SIGHASH_NOINPUT_UNSAFE, et d'autres changements pourraient être intégrés ensemble dans une proposition concrète de soft fork. Le développeur
de protocole Anthony Towns a [résumé][schnorr and more] de manière concise ce qui pourrait être contenu dans une proposition si elle était
publiée aujourd'hui.

<div markdown="1" class="callout">

### sommaire 2018<br>Utilisation des techniques de réduction des frais

![Graphique de l'utilisation des clés publiques compressées, segwit, du regroupement de paiements et du RBF opt-in en
2018](/img/posts/2018-12-overall.png)

Nous avons examiné diverses [techniques de réduction des frais de transaction][] dont l'utilisation peut être facilement suivie en examinant
les transactions confirmées.

- **Clés publiques compressées** économisent 32 octets par utilisation et sont largement utilisées [depuis 2012][Bitcoin Core 0.6]. Le
  nombre d'entrées utilisant des clés publiques compressées est passé d'environ 96 % en janvier à 98 % en décembre.

- **Dépenses segwit** réduisent l'effet de la taille du témoin sur les frais jusqu'à 75 %, selon la manière dont segwit est utilisé (voir le
  graphique suivant). Le nombre d' entrées utilisant segwit est passé d'environ 10 % en janv. à 38 % en déc.

- **Paiements groupés** répartissent la taille et la surcharge en frais de la dépense d'une entrée ou d'un ensemble d'entrées sur un plus
  grand nombre de sorties, ce qui en fait un excellent moyen pour les dépensiers à haute fréquence comme les plateformes d'échange
  d'[économiser jusqu'à 80 % sur les frais][payment batching]. Le nombre de transactions dépensant vers trois sorties ou plus a oscillé
  autour de 11 % toute l'année. Remarque : cette heuristique compte également les transactions coinjoin et d'autres techniques qui ne sont
  pas strictement du regroupement de paiements.

- **RBF opt-in** (Replace-by-Fee) permet une augmentation efficace des frais afin que les dépensiers puissent commencer par payer des frais
  faibles puis augmenter leur enchère plus tard. Les transactions signalant RBF sont passées d'environ 4 % en janv. à 6 % en déc.

![Graphique de l'utilisation de segwit encapsulé et natif en 2018](/img/posts/2018-12-segwit.png)

Il existe deux classes de dépenses segwit :

- **Encapsulé** segwit place le mécanisme d'extension à l'intérieur d'un script P2SH rétrocompatible, le rendant compatible avec presque
  tous les logiciels mais ne lui permettant pas d'atteindre sa pleine efficacité. Le nombre d'entrées utilisant segwit encapsulé est passé
  d'environ 10 % en janv. à 33 % en déc.

- **Natif** segwit est plus efficace mais n'est compatible qu'avec les portefeuilles qui prennent en charge l'envoi vers des adresses
  segwit. Le nombre d' entrées segwit natives est passé de presque 0 % en janv. à environ 5 % en déc.

![Graphique des changements de l'ensemble UTXO par bloc en 2018](/img/posts/2018-12-utxo.png)

Une dernière technique de réduction des frais que nous avons étudiée était la variation par bloc de la taille de l'ensemble des Unconfirmed
Transaction Outputs (UTXOs). Les diminutions indiquent la [consolidation][towns consolidation] de bitcoins en pièces plus grosses qui
pourront être dépensées plus efficacement plus tard. Au total, la taille de l'ensemble UTXO a diminué d'environ 12 millions d'entrées cette
année.

![Graphique de la taille des blocs en pourcentage de la taille maximale de bloc autorisée](/img/posts/2018-12-weight.png)

Dans l'ensemble, la quantité moyenne d'espace de bloc utilisée cette année s'est rarement approchée du maximum autorisé par le protocole,
mais elle semblait augmenter vers ce maximum jusqu'au début décembre. Si cette tendance revient et que les blocs redeviennent régulièrement
pleins en 2019---comme ils l'étaient en 2017---les frais sont susceptibles d'augmenter et les portefeuilles et entreprises qui implémentent
des techniques de réduction des frais pourraient être en mesure d'offrir à leurs utilisateurs des coûts sensiblement inférieurs à ceux des
concurrents qui n'ont pas optimisé.

*Les données de tous les graphiques ci-dessus sont constituées de valeurs collectées depuis l'intérieur de chaque bloc, lissées à l'aide
d'une moyenne mobile simple sur 1 000 blocs. Les blocs vides (ceux avec seulement une transaction de génération) ont été exclus de
l'analyse. La plupart des statistiques ci-dessus peuvent être obtenues depuis le tableau de bord Optech, qui est mis à jour après chaque
bloc. Remarque : après le 1er janvier 2019, nous mettrons à jour les graphiques de cet article afin de refléter l'ensemble de 2018, à quel
point cette phrase sera supprimée.* </div>

## Conclusion

Nous entendons parfois des personnes demander des feuilles de route pour le futur développement de Bitcoin, mais regarder en arrière sur les
développements de 2018 montre clairement à quel point la publication d'un tel document serait vaine. Beaucoup des développements décrits
ci-dessus sont des choses dont nous doutons que même le développeur de protocole le plus avancé aurait pu les prédire il y a seulement un
an. En conséquence, nous n'avons aucune idée de ce que 2019 réserve exactement au développement de Bitcoin---mais nous avons hâte de le
découvrir.

*Le bulletin Optech reviendra à son calendrier habituel de publication le mardi, le 8 janvier. Vous pouvez [vous abonner par e-mail][optech
les bulletins] ou suivre notre [flux RSS][RSS feed].*

## Footnotes

[^fn-dandelion-lite]: Les clients légers utilisant le réseau P2P de Bitcoin ne relaient pas les transactions pour d'autres
utilisateurs---ils n'envoient que leurs propres transactions. Cela signifie que toute transaction envoyée depuis un client léger P2P peut
être associée à l'identité réseau du client (par ex. adresse IP). Dandelion n'est qu'un protocole de routage et ne peut donc pas éliminer
cette fuite de confidentialité. À la place, les clients légers P2P devraient toujours envoyer les transactions en utilisant un réseau
d'anonymat tel que Tor (et devraient utiliser une identité réseau jetable différente pour chaque transaction de dépense).

[^fn-opcodes]: Une proposition de signature Schnorr pourrait ne pas utiliser les mêmes opcodes que le Script actuel, mais la signature
unique, le multisig utilisant quelque chose comme muSig, et le MAST coopératif utilisant quelque chose comme Taproot pourraient tous
utiliser le même format.

[^fn-mast]: Aussi appelés *Merklized Abstract Syntax Trees* car l'idée originale de Russell O'Connor combinait la structure d'engagement
cryptographique des arbres de Merkle avec la technique d'analyse de langage de programmation des arbres syntaxiques abstraits afin de
fournir une méthode pour s'engager de manière compacte sur un script complexe dont les éléments et résultats provenant de différentes
branches pouvaient être combinés. Des simplifications ultérieures de cette idée ont supprimé ce potentiel de combinaison et donc les
propositions récentes sont différentes des arbres syntaxiques abstraits, amenant O'Connor et d'autres à déconseiller l'utilisation du terme
original pour la nouvelle idée. Pourtant l'abréviation "MAST" a été utilisée pour désigner la technique de base depuis [au moins 2013][todd
mast], et nous avons donc choisi d'adopter le rétroacronyme [proposé][mast backronym] par Anthony Towns, *Merklized Alternative Script
Trees*.

[^fn-unsafe]: [BIP118][] SIGHASH_NOINPUT_UNSAFE reçoit l'appellation unsafe parce qu'une utilisation naïve de celui-ci pourrait permettre la
perte de fonds. Par exemple, Alice reçoit 1 BTC sur l'une de ses adresses. Elle utilise ensuite noinput lorsqu'elle signe une dépense de ces
fonds à Bob. Plus tard, Alice reçoit encore 1 BTC à la même adresse. Cela permet à la signature de la transaction précédente d'être
réutilisée pour envoyer les nouveaux 1 BTC d'Alice à Bob. Le co-auteur du BIP118 Christian Decker a [accepté][decker unsafe] d'étiqueter
l'opcode comme *unsafe* afin d'encourager les développeurs à se renseigner sur ce problème de sécurité avant d'utiliser l'indicateur. Un
programme bien conçu peut utiliser noinput en toute sécurité en faisant attention à ce qu'il signe et aux adresses qu'il expose aux
utilisateurs pour recevoir des paiements.

[^fn-harding-mast]: Cet exemple ne correspond à aucune proposition MAST spécifique mais fournit plutôt une vue simple des données minimales
nécessaires pour que MAST fonctionne. Pour les propositions réelles, veuillez consulter les BIPs [114][BIP114], [116][BIP116], et
[117][BIP117].

{% include linkers/issues.md issues="13451,13452,14032" %}
{% include references.md %}

[alert key release]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-July/016189.html
[alert retirement alert]: https://bitcoin.org/en/alert/2016-11-01-alert-retirement
[betterhash]: https://github.com/TheBlueMatt/bips/blob/master/bip-XXXX.mediawiki
[betterhash implementation]: https://github.com/TheBlueMatt/mining-proxy
[bitcoin core 0.16]: https://bitcoincore.org/en/releases/0.16.0/
[bitcoin core 0.17]: https://bitcoincore.org/en/releases/0.17.0/
[bob ts]: https://diyhpl.us/wiki/transcripts/building-on-bitcoin/2018/
[bpase]: https://cyber.stanford.edu/bpase18
[building on bitcoin]: https://building-on-bitcoin.com/
[bustapay]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016340.html
[chaincode lightning residency]: https://lightningresidency.com/
[channel factories]: https://www.tik.ee.ethz.ch/file/a20a865ce40d40c8f942cf206a7cba96/Scalable_Funding_Of_Blockchain_Micropayment_Networks.pdf
[c-lightning 0.6]: https://github.com/ElementsProject/lightning/releases/tag/v0.6
[coredevtech nyc]: https://coredev.tech/2018_newyork.html
[coredevtech tokyo]: https://coredev.tech/2018_tokyo.html
[coredevtech ts]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/
[core dup post]: https://bitcoincore.org/en/2018/09/20/notice/
[cpfp carve out]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-November/016518.html
[edge dev++]: https://keio-devplusplus-2018.bitcoinedge.org/
[edge dev ts]: http://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/edgedevplusplus/
[edge dev vids]: https://www.youtube.com/channel/UCywSzGiWWcUG1gTp45YdPUQ/videos
[electrs]: https://github.com/romanz/electrs
[eltoo]: https://blockstream.com/eltoo.pdf
[eltoo pinning]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-June/001316.html
[esplora]: https://blockstream.com/2018/12/06/esplora-source-announcement/
[graftroot]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-February/015700.html
[l2 summit]: https://medium.com/mit-media-lab-digital-currency-initiative/the-importance-of-layer-2-105189f72102
[lightning protocol development summit]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001569.html
[ln1.1 changes]: https://github.com/lightningnetwork/lightning-rfc/wiki/Lightning-Specification-1.1-Proposal-States
[lnd 0.4-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.4-beta
[lnd 0.5-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.5-beta
[ln list november]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/thread.html
[ln multipath]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-February/000993.html
[ln-penalty]: https://lightning.network/lightning-network-paper.pdf
[ln residency vids]: https://lightningresidency.com/#videos
[mast]: https://bitcointechtalk.com/what-is-a-bitcoin-merklized-abstract-syntax-tree-mast-33fdf2da5e2f
[musig]: https://www.blockstream.com/2018/01/23/musig-key-aggregation-schnorr-signatures/
[offchain pizza]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-February/001044.html
[onchain pizza]: https://en.bitcoin.it/wiki/Laszlo_Hanyecz
[optech]: /
[optech annual report]: /en/2018-optech-annual-report/
[optech les bulletins]: /fr/newsletters/
[optech workshops]: /en/workshops/
[p2ep]: https://blockstream.com/2018/08/08/improving-privacy-using-pay-to-endpoint/
[satoshis.place]: https://satoshis.place/
[scaling bitcoin conference]: https://tokyo2018.scalingbitcoin.org/
[scaling bitcoin ts]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/
[scaling bitcoin vids]: https://tokyo2018.scalingbitcoin.org/#remote-participation
[schnorr and more]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-December/016556.html
[schnorr bip]: https://github.com/sipa/bips/blob/bip-schnorr/bip-schnorr.mediawiki
[sdl fake spv proof]: https://bitslog.wordpress.com/2018/06/09/leaf-node-weakness-in-bitcoin-merkle-tree-design/
[splicing]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-October/001434.html
[subzero]: https://medium.com/square-corner-blog/open-sourcing-subzero-ee9e3e071827
[taproot]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-January/015614.html
[épinglage de transaction]: https://bitcoin.stackexchange.com/questions/80803/what-is-meant-by-transaction-pinning/80804#80804
[untrackable auth]: https://gist.github.com/sipa/d7dcaae0419f10e5be0270fada84c20b
[mast backronym]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-November/016500.html
[todd mast]: https://bitcointalk.org/index.php?topic=255145.msg2757327#msg2757327
[daftuar dandelion]: https://bitcoin.stackexchange.com/a/81504/26940
[bitcoin.com forced bch mining]: https://www.reddit.com/r/Bitcoin/comments/9x2jub/warning_if_you_have_any_bitcoin_hashing_power/
[wuille minisketch savings]: https://twitter.com/pwuille/status/1075460072786935808
[decker unsafe]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-July/016193.html
[bitcoin core 0.6]: https://bitcoin.org/en/release/v0.6.0
[techniques de réduction des frais de transaction]: https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees
[payment batching]: https://bitcointechtalk.com/saving-up-to-80-on-bitcoin-transaction-fees-by-batching-payments-4147ab7009fb
[towns consolidation]: /en/xapo-utxo-consolidation/
[cve-2017-12842]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2017-12842
[cve-2018-17144]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2018-17144
