---
title: 'Bulletin Bitcoin Optech #180: Spécial Bilan 2021'
permalink: /fr/newsletters/2021/12/22/
name: 2021-12-22-newsletter-fr
slug: 2021-12-22-newsletter-fr
type: newsletter
layout: newsletter
lang: fr

excerpt: >
  Cette édition spéciale du bulletin Optech résume les principaux
  développements de Bitcoin au cours de l'année 2021.
---

{{page.excerpt}} Ceci est la suite de nos résumés de [2018][2018
summary], [2019][2019 summary], et [2020][2020 summary].

## Sommaire

* Janvier
  * [Signet dans Bitcoin Core](#signet)
  * [Adresses Bech32m](#bech32m)
  * [Protocole de messages et d'offres en oignon](#offers)
* Février
  * [Création et vérification plus rapides des signatures](#safegcd)
  * [Attaques par brouillage de canaux](#jamming)
* Mars
  * [Risques liés au calcul quantique](#quantum)
* Avril
  * [Paiements atomiques par trajets multiples LN](#amp)
* Mai
  * [Divergence sur l'option de remplacement de frais de BIP125](#bip125)
  * [Double canaux financés](#dual-funding)
* Juin
  * [Construction de blocs basée sur un ensemble de candidats](#csb)
  * [Transaction par défaut de remplacement des frais](#default-rbf)
  * [Acceptation des paquets Mempool et relais des paquets](#mpa)
  * [LN avance rapidement pour la vitesse et la réception hors ligne](#ff)
* Juillet
  * [Annonces de liquidité LN](#liq-ads)
  * [Descripteurs de script de sortie](#descriptors)
  * [Ouverture d'un canal zéro-conf](#zeroconfchan)
  * [SIGHASH_ANYPREVOUT](#anyprevout)
* Août
  * [Bons de fidélité](#fibonds)
  * [Détermination du chemin LN](#pathfinding)
* Septembre
  * [OP_TAPLEAF_UPDATE_VERIFY](#tluv)
* Octobre
  * [Identifiants de l'héritage des transactions](#txhids)
  * [PTLC et transfert rapide LN](#ptlcsx)
* Novembre
  * [Sommet des développeurs LN](#lnsummit)
* Décembre
  * [Suppression avancée des frais](#bumping)
* Synthèses en vedette
  * [Taproot](#taproot)
  * [Mise à jour des principaux projets d'infrastructure](#releases)
  * [Bitcoin Optech](#optech)

## Janvier

{:#signet}
Après des années de discussion, le mois de janvier a vu la première
[publication][bcc21] d'une version de Bitcoin Core supportant les [signets][topic signet],
après le [support][cl#2816] de C-Lightning et le [support][lnd#5025] de LND.
Les signets sont des réseaux de test que chacun peut utiliser pour
simuler le réseau principal de Bitcoin (mainnet), tel qu'il existe
aujourd'hui ou tel qu'il pourrait exister avec certains changements
(comme l'activation d'un embranchement convergent). La plupart des
logiciels qui mettent en œuvre des signets prennent également en charge
un signet par défaut qui constitue un moyen particulièrement pratique
pour que les logiciels développés par différentes équipes soient testés
dans un environnement sûr, aussi proche que possible de celui qu'ils
rencontreront lorsque de l'argent réel sera en jeu. L'ajout de
réorganisations délibérées de la chaîne de blocs au réseau de signets
par défaut de Bitcoin Core, afin d'aider les développeurs à tester leurs
logiciels face à cette catégorie de problèmes, a également été
[discuté][signet reorgs] cette année.

{:#bech32m}
Un projet de BIP pour [bech32m][topic bech32] a également été [annoncé][bech32 bip]
en janvier. Les adresses bech32m sont une légère modification des adresses
bech32 qui les rendent sûres pour une utilisation avec [taproot][topic taproot]
et les futures extensions du protocole. Plus tard dans l'année, une
[page Wiki Bitcoin][bech32m page] a été mise à jour pour suivre l'adoption
des adresses bech32m par les portefeuilles et les services.

{:#offers}
Une autre [première version][cl 0.9.3] d'un nouveau protocole était les
[messages en oignon][topic onion messages] et le [protocole d'offres][topic offers].
Les messages en oignon permettent à un nœud LN d'envoyer un message à
un autre nœud d'une manière qui minimise la surcharge par rapport à l'envoi
de messages basés sur le [HTLC][topic htlc]. Les offres utilisent les
messages en oignon pour permettre à un nœud d'*offrir* de payer un autre nœud,
permettant au nœud récepteur de renvoyer une facture détaillée et d'autres
informations nécessaires. Les messages en oignon et les offres resteront
des projets de spécifications jusqu'à la fin de l'année, mais ils feront
l'objet de développements supplémentaires, notamment une proposition visant
à les utiliser pour [réduire l'impact des paiements bloqués][offers stuck].

## Février

{:#safegcd}
Les contributeurs de Bitcoin [ont fait][safegcd blog] le point sur l'état
des recherches concernant un algorithme amélioré de création et de
vérification des signatures, puis ont utilisé leurs recherches pour
produire une variante comportant des améliorations supplémentaires.
Lorsqu'il a été implémenté dans libsecp256k1 ([1][secp831], [2][secp906])
et [plus tard][bcc21573] dans Bitcoin Core, il a permis de réduire
le temps nécessaire à la vérification des signatures d'environ 10 %---une
amélioration significative pour la vérification des quelque milliards
de signatures de la chaîne de blocs de Bitcoin. Plusieurs cryptographes
ont travaillé pour s'assurer que ce changement était mathématiquement
solide et sûr à utiliser. Cette modification permet également d'accélérer
considérablement la création de signatures sécurisées sur des dispositifs
de signature matériels de faible puissance.

{:#jamming}
[Attaques par brouillage de canaux][topic channel jamming attacks], un problème
connu de LN depuis 2015, a fait l'objet de discussions continues tout
au long de l'année, avec une [variété][jam1] de [possibilités][jam2] et
de solutions  [discutées][jam3]. Malheureusement, aucune solution largement
acceptée n'a été trouvée et le problème n'a pas été atténué à la fin de l'année.

{:.center}
![Illustration of jamming attacks](/img/posts/2020-12-ln-jamming-attacks.png)

## Mars

{:#quantum}
D'importantes [discussions][quant] en mars ont été consacrées à l'analyse
du risque d'attaques d'ordinateurs quantiques sur Bitcoin, en particulier
pour le cas où taproot s'activerait et deviendrait largement utilisé.
L'une des caractéristiques originales de Bitcoin, le hachage de la clé
publique---vraisemblablement ajouté pour raccourcir les adresses Bitcoin---a
également rendu plus difficile le vol de fonds d'un nombre limité d'utilisateurs
en cas d'avancée majeure et soudaine de l'informatique quantique.
[Taproot][topic taproot] ne fournit pas cette fonctionnalité et au moins
un développeur s'est inquiété du fait que cela créait un risque déraisonnable.
Un grand nombre de contre-arguments ont été présentés et le soutien de
la communauté pour taproot semble être inchangé.

<div markdown="1" class="callout" id="taproot">
### Sommaire 2021<br>Activiation de Taproot

Fin 2020, une implémentation de l'embranchement convergent [taproot][topic taproot]
contenant le support des [signatures de schnorr][topic schnorr signatures] et
[tapscript][topic tapscript] avait été [fusionnée][bcc#19953] dans Bitcoin Core.
Ceci a largement achevé le travail des développeurs de protocoles ; il
appartient maintenant à la communauté d'activer taproot si elle le souhaite,
et aux développeurs de portefeuilles de commencer à le prendre en charge,
ainsi que les technologies connexes comme les adresses [bech32m][topic bech32].

{% comment %}<!-- comments in bold text below tweak auto-anchors to prevent ID conflicts -->{% endcomment %}

- **Janvier<!--taproot-->** a commencé avec la [sortie][bcc21] de Bitcoin
  Core 0.21.0, qui était la première version à prendre en charge les [signets][topic signet],
  y compris le signet par défaut où taproot avait été activé---donnant aux
  utilisateurs et aux développeurs un endroit facile pour commencer les tests.

- **Février<!--taproot-->** a vu la [première][tapa1] des [nombreuses][tapa2]
[réunions][tapa3] prévues dans le canal IRC `##taproot-activation`, qui allait
devenir le principal centre de discussion entre les développeurs, les utilisateurs
et les mineurs sur la façon d'activer taproot.

- **Mars<!--taproot-->** a commencé avec de nombreux participants à la
  discussion qui ont provisoirement accepté d'[essayer][speedy trial] une
  approche d'activation particulière appelée *speedy trial*, qui a été
  conçue pour recueillir un retour d'information rapide de la part des mineurs,
  mais aussi pour donner aux utilisateurs suffisamment de temps pour
  mettre à jour leur logiciel pour l'application de taproot. Speedy trial
  est ensuite devenu le [mécanisme][topic soft fork activation] utilisé
  pour activer taproot.

    Alors que des discussions sur l'activation étaient en cours,
    une dernière [discussion][quant] a porté sur l'une de ses décisions
    de conception, l'utilisation de clés publiques nues, qui, selon certains,
    pourrait accroître le risque de vol des fonds des utilisateurs par
    les futurs ordinateurs quantiques. De nombreux développeurs ont fait
    valoir que ces inquiétudes étaient injustifiées ou, du moins, exagérées.

    En mars également, Bitcoin Core a fusionné la prise en charge du [BIP350][],
    ce qui lui permet de payer les adresses [bech32m][topic bech32]. Cette légère
    variation des adresses bech32 qui sont utilisées pour les paiements
    aux adresses de la version originale de segwit corrige un bogue qui
    aurait pu faire perdre de l'argent aux utilisateurs de taproot dans
    certains cas très rares.  (Les sorties segwit originales créées à partir
    des adresses bech32 sont sûres et non affectées par le bogue).

  {% comment %}
  /en/newsletters/2021/03/03/#rust-lightning-794
  /en/newsletters/2021/03/10/#documenting-the-intention-to-use-and-build-upon-taproot
  /en/newsletters/2021/03/24/#discussion-of-quantum-computer-attacks-on-taproot
  /en/newsletters/2021/03/24/#bitcoin-core-20861
  /en/newsletters/2021/03/31/#should-block-height-or-mtp-or-a-mixture-of-both-be-used-in-a-soft-fork-activation-mechanism
  {% endcomment %}

- **Avril<!--taproot-->** a presque vu les progrès de l'activation dérailler
  alors que les développeurs du protocole et certains utilisateurs [débattaient][tapa4]
  des mérites de deux versions légèrement différentes du mécanisme d'activation
  de speedy trial. Cependant, les auteurs des différentes implémentations
  des deux versions différentes sont parvenus à un [compromis][bcc#21377] qui
  a permis la publication d'une [version][bcctap] de Bitcoin Core avec un mécanisme
  et des paramètres d'activation.

- **Mai<!--taproot-->** C'est à ce moment-là que les mineurs ont été
  [capables][signal able] de [commencer][signal began] à signaler qu'ils
  étaient prêts à appliquer taproot et qu'un site Web permettant de suivre
  la progression de la signalisation est devenu [populaire][taproot.watch].

- **Juin<!--taproot-->** a vu les mineurs [verouiller taproot][lockin],
  s'engageant à appliquer son activation environ six mois plus tard au bloc {{site.trb}}.
  Cela signifie qu'il était [temps][rb#589] pour les [développeurs de portefeuilles][bcc#22051]
  et les [autres développeurs d'infrastructures][bolts#672] de [mettre][cl#4591]
  plus d'[attention][bcc#21365] à [adapter][rb#601] leur [logiciel][p2trhd]
  pour taproot, [ce que][bcc#22154] beaucoup d'entre eux [ont fait][bcc#22166].
  De plus, une [proposition][nsequence default] a été faite pour permettre
  aux portefeuilles taproot onchain de contribuer facilement à la
  confidentialité des portefeuilles utilisant divers protocoles contractuels
  comme LN et [coinswaps][topic coinswap]. Optech a également [commencé][p4tr begins]
  sa série [Preparing for Taproot][p4tr].

- **Juillet<!--taproot-->** a rencontré une [page][page bech32m] du Bitcoin Wiki
  consacrée au suivi du support du format d'adresse bech32m nécessaire aux
  portefeuilles pour pouvoir utiliser taproot après son activation.
  De nombreux développeurs de portefeuilles et de services se sont montrés
  à la hauteur de la situation et ont assuré qu'ils seraient prêts à permettre
  à quiconque d'utiliser taproot dès son activation.  D'autres
  [propositions d'embranchement convergent][bip118 update] ont été mises à jour
  pour utiliser taproot ou [tirer les leçons][bip119 update] de son activation.

- **Août<!--taproot-->** a été tranquille pour le développement de taproot,
  bien que quelques [documentations][reuse risks] liées à taproot ont été écrites.

- **Septembre<!--taproot-->** a vu le logiciel pour les commerçants open source
  le plus populaire de Bitcoin ajouter le [support][btcpay taproot] pour taproot
  avant son activation prévue. Il a également vu la [proposition][op_tluv] d'un
  nouvel opcode qui ferait un usage particulier des fonctionnalités de taproot
  pour permettre des [conditions de dépense][topic covenants] basées sur des scripts.

- **Octobre<!--taproot-->** a commencé avec une [activité][rb#644] de développement
  [renouvelée][rb#563] alors que l'activation de taproot [approchait][testing taproot].
  Le BIP de Taproot a été mis à jour avec des [vecteurs de test étendus][]
  pour aider les développeurs de portefeuilles et d'infrastructures à vérifier
  leurs implémentations.

- **Novembre<!--taproot-->** a célébré [l'activation de taproot][].
  Il y a eu une certaine confusion au départ, car les mineurs du bloc {{site.trb}}
  et de plusieurs blocs ultérieurs n'ont pas inclus de transactions de dépense
  avec taproot. Cependant, grâce au travail de plusieurs développeurs
  et administrateurs de pools de minage, la plupart des blocs minés
  les jours suivants étaient prêts à contenir des transactions de type
  taproot-spending. [Développement][nov cs] et [test][cbf verification]
  du logiciel [taproot-ready][dec cs] [ont suivis][rb#691].

- **Decembre<!--taproot-->** a vu Bitcoin Core fusionner une PR qui permettrait
  aux [portefeuilles avec descripteurs][topic descriptors] de créer des adresses
  [bech32m][topic bech32] pour recevoir des paiements taproot. Les développeurs
  de LN ont également discuté de l'utilisation des fonctionnalités de taproot.

Malgré des complications dans le choix du mécanisme d'activation de taproot
et une légère confusion immédiatement après son activation, les dernières étapes
de l'ajout à Bitcoin du support de l'embranchement convergent taproot semblent
s'être bien déroulées. Ce n'est pas la fin de l'histoire pour taproot. Optech
s'attend à continuer à passer beaucoup de temps à écrire à son sujet dans les
années à venir, alors que les développeurs de portefeuilles et d'infrastructures
commencent à utiliser ses nombreuses fonctionnalités.

</div>

## Avril

{:#amp}
LND a ajouté le [support][lnd#5709] en avril pour effectuer des Paiements
Atomiques à Multiples Chemins ([AMP][topic amp]), également appelés
originellement AMPs car ils sont décrits plus tôt que les
[Paiements Simplifiés à Multiples Chemins][topic multipath payments] (SMP)
que toutes les implémentations majeures de LN supportent actuellement.
Les AMP ont un avantage en matière de confidentialité par rapport aux SMP
et garantissent également que le récepteur a reçu l'ensemble des fonds avant
de finaliser le paiement.  Leur inconvénient est qu'ils ne produisent pas
de preuve cryptographique du paiement. LND les a implémentés pour les utiliser
avec les [paiements spontanés][topic spontaneous payments] qui, fondamentalement,
ne peuvent pas fournir de preuve de paiement, éliminant ainsi le seul
inconvénient significatif des AMP.

## Mai

{:#bip125}
Une divergence entre les spécifications du [BIP125][] de remplacement
des transactions [topic rbf] et la mise en œuvre dans Bitcoin Core a été
[divulguée][bip125 discrep] en mai. Cela n'a pas mis de bitcoins en danger,
pour autant que nous le sachions, mais cela a donné lieu à plusieurs
discussions sur les risques encourus par les utilisateurs de protocoles
contractuels (tels que LN) en raison du comportement inattendu du
relais de transaction.

{:#dual-funding}
En mai également, le projet C-Lightning a [fusionné][cl#4489] un plugin
pour la gestion des [canaux à financement bipartite][topic dual funding]---des
canaux où les deux parties peuvent fournir un certain montant du financement
initial. En plus du travail antérieur sur le financement bipartite [fusionné][cl#4410]
cette année, cela permet à la partie qui initie l'ouverture du canal
non seulement de dépenser les fonds par le canal mais aussi de les recevoir
dans l'état initial du canal. Cette capacité initiale à recevoir des fonds
rend le financement bipartite particulièrement utile pour les commerçants
dont l'utilisation principale de LN est de recevoir des paiements
au lieu de les envoyer.

<div markdown="1" class="callout" id="releases">
### Sommaire 2021<br>Mises à jour et version candidate

- [Eclair 0.5.0][] a ajouté la prise en charge d'un mode cluster évolutif
  (voir [Bulletin d'information n°128][news128 akka]), les chiens de garde
  de la chaîne de blocs ([Bulletin d'information #123][news123 watchdog]),
  et des modules d'accrcoche supplémentaires.

- [Bitcoin Core 0.21.0][] comprenait le support des nouveaux services
  Tor onion utilisant les [messages d'annonce d'adresse version 2][topic addr v2],
  la possibilité optionnelle de servir les [filtres de bloc compact][topic compact block filters],
  et le support des [signets][topic signet] (y compris le signet
  par défaut qui a [taproot][topic taproot] activé). Il offre également
  un support expérimental pour les portefeuilles qui utilisent nativement
  les [descripteurs de script de sortie][topic descriptors].

- [Rust Bitcoin 0.26.0][] comprend la prise en charge du signet,
  des messages d'annonce d'adresse de la version 2 et des améliorations
  de la gestion des [PSBT][topic psbt].

- [LND 0.12.0-beta][] ajoutz le support pour l'utilisation de [tours de guet][topic watchtowers]
  avec des [sorties d'ancrage][topic anchor outputs] et ajout d'une
  nouvelle sous-commande de portefeuille `psbt` pour travailler
  avec [PSBT][topic psbt].

- [HWI 2.0.0][] contient le support pour le multisig sur le BitBox02,
  une documentation améliorée, et le support pour payer les sorties
  `OP_RETURN` avec un Trezor.

- [C-Lightning 0.10.0][] contenait un certain nombre d'améliorations
  de son API et un support expérimental pour le [financement bipartite][topic dual funding].

- [BTCPay Server 1.1.0][] a inclus la prise en charge de [Lightning Loop][news53 lightning loop],
  ajouté [WebAuthN/FIDO2][fido2 website] comme option d'authentification
  à deux facteurs, apporté diverses améliorations à l'interface
  utilisateur et marqué le passage à l'utilisation de la numérotation
  de [versions sémantiques][semantic versioning website] pour les 
  prochaines mises à jour.

- [Eclair 0.6.0][] contient plusieurs améliorations qui renforcent
  la sécurité et la confidentialité des utilisateurs. Elle assure
  également la compatibilité avec les futurs logiciels susceptibles
  d'utiliser les adresses [bech32m][topic bech32].

- [LND 0.13.0-beta][] amélioration de la gestion des feerates en faisant
  des [sorties d'ancrage][topic anchor outputs] le format de transaction
  d'engagement par défaut, ajout de la prise en charge de l'utilisation
  d'un nœud complet Bitcoin élagué, autorisation de la réception et de
  l'envoi de paiements à l'aide des Chemins Multiples Atomiques ([AMP][topic amp]),
  et augmentation des capacités [PSBT][topic psbt] de LND.

- [Bitcoin Core 22.0][] a inclus la prise en charge des connexions [I2P][topic anonymity networks],
  a supprimé la prise en charge des connexions [version 2 de Tor][topic anonymity networks],
  et a amélioré la prise en charge des [portefeuilles matériels][topic hwi].

- [BDK 0.12.0][] a ajouté la possibilité de stocker des données en utilisant Sqlite.

- [LND 0.14.0][] Parmi les nouveautés, citons une protection supplémentaire
  contre les [attaques d'éclipse][topic eclipse attacks] (voir le [bulletin
  d'information n° 164][news164 ping]), la prise en charge des bases de données
  distantes ([bulletin d'information n° 157][news157 db]), une recherche de
  chemin plus rapide ([bulletin d'information n° 170][news170 path]), des
  améliorations pour les utilisateurs de Lightning Pool ([bulletin d'information
  n° 172][news172 pool]) et des factures réutilisables [AMP][topic amp]
  ([bulletin d'information n° 173] [news173 amp]).

- [BDK 0.14.0][] simplifie l'ajout d'une sortie `OP_RETURN` à une transaction
  et contient des améliorations pour l'envoi de paiements aux adresses
  [bech32m][topic bech32] pour taproot.

</div>

## Juin

{:#csb}
Une nouvelle [analyse][csb] discutée en juin décrit une autre façon
pour les mineurs de sélectionner les transactions qu'ils souhaitent
inclure dans les blocs qu'ils créent. La nouvelle méthode devrait
augmenter légèrement les revenus des mineurs à court terme. À long terme,
si cette technique est adoptée par les mineurs, les portefeuilles qui
en ont connaissance pourront collaborer lors de l'utilisation de
[CPFP][topic cpfp] pour augmenter les frais d'une transaction, ce qui augmentera l'efficacité
de cette technique.

{:#default-rbf}
Une autre tentative pour rendre le remplacement des frais plus efficace
a été une [proposition][rbf default] pour permettre à toute transaction
non confirmée d'être [remplacée avec des frais plus élevés][topic rbf] (RBF) dans
Bitcoin Core---et pas seulement celles qui ont choisi d'autoriser le
remplacement en utilisant [BIP125][]. Cela pourrait aider à résoudre
certains problèmes liés au remplacement des frais dans les protocoles
multipartites et également améliorer la confidentialité en permettant
à davantage de transactions d'utiliser des paramètres uniformes. En ce
qui concerne la confidentialité, une [proposition][nseq default] distincte
a suggéré que les portefeuilles créant des dépenses taproot définissent
une valeur nSequence par défaut même s'ils n'ont pas besoin des fonctionnalités
offertes par les valeurs de séquence appliquées par consensus du [BIP68][] ;
cela permettrait aux transactions créées par des logiciels qui ont besoin
d'utiliser BIP68 de se fondre dans les transactions plus courantes.
Aucune des deux propositions n'a semblé faire beaucoup de progrès
malgré quelques objections significatives.

{:#mpa}
Le mois de juin a également vu la fusion de la [première PR][bcc#20833]
d'une série mettant en œuvre [l'acceptation des paquets mempool][mpa ml]
dans Bitcoin Core, la première étape vers le relais de paquets.
Le [relais de paquets][topic package relay] permettra aux nœuds
de relais et aux mineurs de traiter des paquets de transactions
liées comme s'il s'agissait d'une seule transaction à des fins de
taux de frais. Un paquet pourrait contenir une transaction parent
avec un faible taux de frais et une transaction enfant avec un taux
de frais élevé ; la rentabilité de l'exploitation de la transaction
enfant inciterait les mineurs à exploiter également la transaction parent.
Bien que le minage de paquets ait été [implémenté][bitcoin core #7600]
dans Bitcoin Core depuis 2016, il n'y avait jusqu'à présent aucun moyen
pour les nœuds de relayer les transactions sous forme de paquets,
ce qui signifie que les transactions parentales à faible taux de frais
pourraient ne pas atteindre les mineurs pendant les périodes à haut
taux de frais, même si elles ont des enfants à haut taux de frais.
Cela rend [la suppression de frais CPFP][topic cpfp] peu fiable pour
les protocoles de contrat utilisant des transactions présignées, comme LN.
Le relais de paquet espère résoudre ce problème de sécurité clé.

{:#ff}
Une idée initialement proposée en 2019 pour LN a connu un regain de vie en juin.
L'idée originale de [fast forward][ff orig] décrivait comment un porte-monnaie LN
pouvait recevoir ou relayer un paiement avec moins d'allers-retours sur le réseau,
réduisant ainsi la bande passante du réseau et la latence du paiement.
L'idée a été [élargie][ff expanded] cette année pour décrire comment un
porte-monnaie LN pourrait recevoir plusieurs paiements sans apporter sa clé
de signature en ligne pour chaque paiement, ce qui facilite le maintien
de cette clé de signature sécurisée.

## Juillet

{:#liq-ads}
Après des années de discussion et de développement, la première
implémentation d'un système décentralisé d'annonces de liquidité
a été [fusionnée][cl#4639] dans une implémentation LN. La proposition
d'[annonce de liquidité][bolts #878] encore à l'état de projet
permet à un noeud d'utiliser le protocole de commérage LN pour
annoncer sa volonté de louer ses fonds pour une période de temps,
donnant aux autres noeuds la possibilité d'acheter une capacité
entrante qui leur permet de recevoir des paiements instantanés.
Un nœud qui voit l'annonce peut simultanément payer et recevoir
la capacité entrante en utilisant l'ouverture d'un canal à
[financement double][topic dual funding]. Bien qu'il n'y ait aucun
moyen d'imposer que le nœud annonceur achemine effectivement les paiements,
la proposition intègre une proposition antérieure (également
[utilisée ultérieurement][lnd#5709] dans Lightning Pool) qui empêche
l'annonceur d'utiliser son argent à d'autres fins jusqu'à la fin de
la période de location convenue. Cela signifie que le refus d'acheminer
les paiements n'apporterait aucun avantage mais priverait le nœud
annonceur de la possibilité de gagner des frais d'acheminement.

{:#descriptors}
Trois ans après avoir été [proposé pour la première fois][descriptor gist]
pour Bitcoin Core, des [projets de BIP][descriptor bips1] ont été
[créés][descriptor bips2] pour les [descripteurs de script de sortie][topic descriptors].
Les descripteurs sont des chaînes de caractères qui contiennent toutes
les informations nécessaires pour permettre à un portefeuille ou à un
autre programme de suivre les paiements effectués ou dépensés à partir
d'un script particulier ou d'un ensemble de scripts apparentés (c'est-à-dire
une adresse ou un ensemble d'adresses apparentées, comme dans un
[portefeuille HD][topic bip32]). Les descripteurs se combinent bien avec
[miniscript][topic miniscript] en permettant à un porte-monnaie de gérer
le suivi et la signature pour une plus grande variété de scripts.
Ils se combinent également bien avec [PSBT][topic psbt] pour permettre
au porte-monnaie de déterminer les clés qu'il contrôle dans un script multisig.
À la fin de l'année, Bitcoin Core a fait des portefeuilles basés sur
des descripteurs son paramétrage par [défaut][descriptor default] pour
les portefeuilles nouvellement créés.

{:#zeroconfchan}
Une façon courante d'ouvrir des canaux LN qui n'avaient jamais fait partie
du protocole LN a commencé à être [spécifiée][0conf channels] en juillet.
Les ouvertures de canaux 0-conf, également appelés *canaux turbo*, sont
de nouveaux canaux à financement unique où le financeur donne une partie
ou la totalité de ses fonds initiaux à la partie acceptante. Ces fonds ne
sont pas sécurisés tant que la transaction d'ouverture de canal n'a pas reçu
un nombre suffisant de confirmations, de sorte qu'il n'y a aucun risque que
l'accepteur dépense une partie de ces fonds à travers le financeur en
utilisant le protocole standard LN.  Par exemple, Alice a plusieurs BTC
sur un compte chez le dépositaire de Bob. Alice demande à Bob d'ouvrir un
nouveau canal en lui versant 1,0 BTC. Parce que Bob a confiance en lui pour
ne pas dépenser deux fois le canal qu'il vient d'ouvrir, il peut permettre
à Alice d'envoyer 0,1 BTC par son nœud à un tiers Carol avant même que la
transaction d'ouverture du canal n'ait reçu une seule confirmation.
La spécification du comportement devrait contribuer à améliorer
l'interopérabilité entre les nœuds LN et les marchands qui offrent ce service.

{:.center}
![Zero-conf channel illustration](/img/posts/2021-07-zeroconf-channels.png)

{:#anyprevout}
Deux propositions connexes de nouveaux types de hachage de signature
(sighash) ont été [combinées][sighash combo] dans le [BIP118][].
`SIGHASH_NOINPUT`, proposé en 2017 et partiellement basé sur des
propositions précédentes remontant à une décennie, a été remplacé par
[`SIGHASH_ANYPREVOUT` et `SIGHASH_ANYPREVOUTANYSCRIPT`][topic sighash_anyprevout]
d'abord [proposé][anyprevout proposed] en 2019. Les nouveaux types
de sighash permettront aux protocoles hors chaîne tels que LN et
les [coffres][topic vaults] de réduire le nombre d'états intermédiaires
qu'ils doivent conserver, ce qui réduira considérablement les besoins
de stockage et la complexité. Pour les protocoles multipartites,
les avantages peuvent être encore plus importants en éliminant le nombre
d'états différents qui doivent être générés en premier lieu.

## Août

{:#fibonds}
Les bons de fidélité sont une idée [décrite][wiki contract] au moins
depuis 2010 pour verrouiller les bitcoins pendant une période de temps
afin de créer un coût pour les mauvais comportements dans les systèmes tiers.
Comme les bitcoins ne peuvent pas être réutilisés avant l'expiration
du verrouillage, les utilisateurs de l'autre système qui sont bannis
ou autrement pénalisés pendant la période de verrouillage ne peuvent pas
utiliser les mêmes bitcoins pour créer une nouvelle identité virtuelle.
En août, JoinMarket a mis en [production][fi bonds] la première utilisation
à grande échelle et décentralisée des bons de fidélité. Quelques jours
après le lancement, plus de 50 BTC avaient été verrouillés (d'une valeur
de plus de 2 millions de dollars américains à l'époque).

{:#pathfinding}
Une nouvelle variante du chemin d'accès pour LN a été [discutée][0base]
en août. Les partisans de cette technique pensaient qu'elle serait plus
efficace si les nœuds d'acheminement ne facturaient qu'un pourcentage
du montant acheminé sans facturer un minimum de *frais de base* sur
chaque paiement.  D'autres étaient d'un avis différent. D'ici la fin
de l'année, une [variation][cl#4771] de cette technique sera implémentée
dans C-Lightning.

<div markdown="1" class="callout" id="optech">
### Sommaire 2021<br>Bitcoin Optech

Au cours de la quatrième année d'Optech, nous avons publié 51 [bulletins][]
hebdomadaires, ajouté 30 nouvelles pages à notre [index des sujets][],
publié un [article de blog][additive batching] et rédigé (avec l'aide
de [deux][zmn guest] invités [de renom][darosior guest]) une série de
21 articles sur la [préparation pour taproot][p4tr]. Au total, Optech
a publié plus de 80 000 mots sur la recherche et le développement
du logiciel Bitcoin cette année, soit l'équivalent approximatif d'un
livre de 250 pages. <!-- wc -w _posts/en/newsletters/2021-*
_includes/specials/taproot/en/* -->

</div>

## Septembre

{:#tluv}
Les développeurs de Bitcoin ont longtemps discuté de la possibilité
d'envoyer des bitcoins à un script qui pourrait limiter les autres
scripts susceptibles de recevoir ultérieurement ces bitcoins, un mécanisme
appelé [conditions de dépense][topic covenants]. Par exemple, Alice
reçoit des bitcoins dans un script qui peut être dépensé par son
portefeuille chaud---mais seulement en les envoyant à un second script
qui retarde toute dépense ultérieure par son portefeuille chaud.
Pendant ce délai, son portefeuille froid peut réclamer les fonds.
S'il ne le fait pas, et que le délai est passé, le portefeuille chaud
d'Alice peut dépenser les fonds librement. En septembre, un nouvel
opcode `OP_TAPLEAF_UPDATE_VERIFY` a été [proposé][op_tluv] pour créer
ce genre de conditions de dépense d'une manière qui tire un avantage
particulier de la capacité de taproot à dépenser des fonds en utilisant
soit juste une signature (dépense par keypath) ou un arbre de scripts
[MAST-like][topic mast] (dépense par scriptpath). Le nouvel opcode serait
particulièrement utile pour créer des [joinpools][topic joinpools] qui
pourraient augmenter considérablement la confidentialité en permettant
à plusieurs utilisateurs de partager facilement et en toute confiance
la propriété d'un UTXO.

## Octobre

{:#txhids}
En octobre, les développeurs de Bitcoin ont discuté d'une nouvelle façon
pour une transaction d'[identifier][heritage identifiers] quel ensemble
de bitcoins elle voulait dépenser. Actuellement, les bitcoins sont
identifiés par leur emplacement dans la transaction qui les a dépensés
en dernier ; par exemple "transaction foo, sortie zéro". Une nouvelle
proposition permettrait d'identifier les bitcoins à l'aide d'une transaction
précédente qui les a dépensés ainsi que de leur position dans la hiérarchie
descendante et de leur emplacement ; par exemple, "transaction bar's
second enfant, sorite zero". Il a été suggéré que cela offrirait des
avantages pour des conceptions telles que [eltoo][topic eltoo], [usines à canaux][topic channel factories],
et [watchtowers][topic watchtowers], qui bénéficient toutes de
protocoles de contrat tels que LN.

{:#ptlcsx}
En octobre également, une combinaison d'idées existantes pour améliorer LN
a été regroupée dans une [proposition unique][ptlcs extreme] qui
apporterait certains des avantages d'eltoo, mais sans nécessiter
l'embranchement convergent [SIGHASH_ANYPREVOUT][topic sighash_anyprevout]
ou tout autre changement de consensus. La proposition réduirait la latence
des paiements à une vitesse proche de celle à laquelle les données peuvent
voyager dans un sens entre tous les nœuds de routage sur un chemin particulier.
Elle augmenterait également la résilience en permettant à un nœud de
sauvegarder toutes les informations dont il a besoin au moment de la création
d'un canal et d'obtenir toute autre information dans la plupart des cas
lors d'une restauration des données. Il permettrait également de recevoir
des paiements avec une clé hors ligne, ce qui permettrait aux nœuds marchands
en particulier de limiter la durée d'utilisation de leurs clés par
les ordinateurs en ligne.

## Novembre

{:#lnsummit}
Les développeurs de LN ont tenu le premier sommet général de LN
[depuis 2018][2018 ln summit] et ont [discuté][2021 ln summit]
de sujets tels que l'utilisation de [taproot][topic taproot] dans LN,
notamment les [PTLCs][topic ptlc], [MuSig2][topic musig] pour les
[multisignatures][topic multisignature], et [eltoo][topic eltoo] ;
déplacement de la discussion sur les spécifications de l'IRC vers
les chats vidéo ; modifications du modèle de spécification BOLTs
actuel ; [messages en oignons][topic onion messages] et [offres][topic offers] ;
[paiements sans blocage][] ; [attaques par brouillage de canal][topic channel jamming attacks]
et diverses atténuations ; et [routage par trampoline][topic trampoline payments].

## Decembre

{:#bumping}
Pour les transactions onchain à signature unique, l'augmentation des
frais d'une transaction pour encourager les mineurs à la confirmer
plus tôt est une opération relativement simple. Mais pour les protocoles
de contrat tels que LN et [les coffres-forts][topic vaults], tous
les signataires qui ont autorisé une dépense ne sont pas forcément
disponibles lorsque la hausse des frais est nécessaire. Pire encore,
les protocoles contractuels exigent souvent que certaines transactions
soient confirmées avant une date limite, sans quoi un utilisateur honnête
pourrait perdre de l'argent. Le mois de décembre a vu la [publication][fee bump research]
d'une recherche liée au choix de mécanismes efficaces de répercussion
des frais pour les protocoles de contrat, ce qui a contribué à stimuler
la discussion sur les solutions à cet important problème à long terme.

## Conclusion

Nous avons tenté quelque chose de nouveau dans le résumé de cette année :
décrire deux douzaines de développements notables en 2021 sans mentionner
le nom d'un seul contributeur. Nous sommes redevables à tous ces contributeurs
et souhaitons vivement qu'ils soient crédités pour leur incroyable travail,
mais nous voulons également reconnaître tous les contributeurs que nous
ne mentionnions pas normalement.

Ce sont les personnes qui passent des heures à réviser le code, qui écrivent
des tests pour un comportement établi afin de s'assurer qu'il ne change pas
de manière inattendue, qui s'efforcent de déboguer de mystérieux problèmes
pour les résoudre avant que l'argent ne soit mis en danger, ou qui travaillent
sur une centaine d'autres tâches qui ne feraient la une que si elles
n'étaient pas effectuées.

Ce dernier bulletin de 2021 leur est dédié. Nous ne disposons pas d'un moyen
facile de dresser une liste des noms de ces contributeurs méconnus.
Au lieu de cela, nous avons omis tous les noms de ce bulletin pour souligner
que le développement de Bitcoin est un travail d'équipe où certains des travaux
les plus importants sont effectués par des personnes dont les noms n'ont
jamais paru dans aucun numéro de ce bulletin.

Nous les remercions, ainsi que tous les contributeurs à Bitcoin en 2021.
Nous sommes impatients de de voir quels nouveaux développements passionnants
ils apporteront en 2022.

*Le bulletin Optech reprendra son rythme de publication habituel du
mercredi le 5 janvier.*

{% include references.md %}
{% include linkers/issues.md issues="878,7600" %}
[2018 summary]: /en/newsletters/2018/12/28/
[2019 summary]: /en/newsletters/2019/12/28/
[2020 summary]: /en/newsletters/2020/12/23/
[cl 0.9.3]: /en/newsletters/2021/01/27/#c-lightning-0-9-3
[safegcd blog]: /en/newsletters/2021/02/17/#faster-signature-operations
[secp831]: /en/newsletters/2021/03/24/#libsecp256k1-831
[secp906]: /en/newsletters/2021/04/28/#libsecp256k1-906
[bcc21573]: /en/newsletters/2021/06/16/#bitcoin-core-21573
[bcc21]: /en/newsletters/2021/01/20/#bitcoin-core-0-21-0
[cl#2816]: /en/newsletters/2019/07/24/#c-lightning-2816
[jam1]: /en/newsletters/2021/02/17/#renewed-discussion-about-bidirectional-upfront-ln-fees
[jam2]: /en/newsletters/2021/10/20/#lowering-the-cost-of-probing-to-make-attacks-more-expensive
[jam3]: /en/newsletters/2021/11/10/#ln-summit-2021-notes
[quant]: /en/newsletters/2021/03/24/#discussion-of-quantum-computer-attacks-on-taproot
[tapa1]: /en/newsletters/2021/01/27/#scheduled-meeting-to-discuss-taproot-activation
[tapa2]: /en/newsletters/2021/02/10/#taproot-activation-meeting-summary-and-follow-up
[tapa3]: /en/newsletters/2021/02/24/#taproot-activation-discussion
[tapa4]: /en/newsletters/2021/04/14/#taproot-activation-discussion
[bcctap]: /en/newsletters/2021/04/21/#taproot-activation-release-candidate
[speedy trial]: /en/newsletters/2021/03/10/#taproot-activation-discussion
[bcc#21377]: /en/newsletters/2021/04/21/#bitcoin-core-21377
[signal began]: /en/newsletters/2021/05/05/#miners-encouraged-to-start-signaling-for-taproot
[signal able]: /en/newsletters/2021/05/05/#bips-1104
[taproot.watch]: /en/newsletters/2021/05/26/#how-can-i-follow-the-progress-of-miner-signaling-for-taproot-activation
[rb#589]: /en/newsletters/2021/05/12/#rust-bitcoin-589
[bolts#672]: /en/newsletters/2021/06/02/#bolts-672
[bcc#22051]: /en/newsletters/2021/06/09/#bitcoin-core-22051
[lockin]: /en/newsletters/2021/06/16/#taproot-locked-in
[nsequence default]: /en/newsletters/2021/06/16/#bip-proposed-for-wallets-to-set-nsequence-by-default-on-taproot-transactions
[cl#4591]: /en/newsletters/2021/06/16/#c-lightning-4591
[p4tr]: /en/preparing-for-taproot/
[bcc#21365]: /en/newsletters/2021/06/23/#bitcoin-core-21365
[rb#601]: /en/newsletters/2021/06/23/#rust-bitcoin-601
[p2trhd]: /en/newsletters/2021/06/30/#key-derivation-path-for-single-sig-p2tr
[bcc#22154]: /en/newsletters/2021/06/30/#bitcoin-core-22154
[bcc#22166]: /en/newsletters/2021/06/30/#bitcoin-core-22166
[p4tr begins]: /en/newsletters/2021/06/23/#preparing-for-taproot-1-bech32m-sending-support
[bech32m page]: /en/newsletters/2021/07/14/#tracking-bech32m-support
[bip118 update]: /en/newsletters/2021/07/14/#bips-943
[bip119 update]: /en/newsletters/2021/11/10/#bips-1215
[reuse risks]: /en/newsletters/2021/08/25/#are-there-risks-to-using-the-same-private-key-for-both-ecdsa-and-schnorr-signatures
[btcpay taproot]: /en/newsletters/2021/09/15/#btcpay-server-2830
[op_tluv]: /en/newsletters/2021/09/15/#covenant-opcode-proposal
[rb#563]: /en/newsletters/2021/10/06/#rust-bitcoin-563
[rb#644]: /en/newsletters/2021/10/06/#rust-bitcoin-644
[testing taproot]: /en/newsletters/2021/10/20/#testing-taproot
[vecteurs de test étendus]: /en/newsletters/2021/11/03/#taproot-test-vectors
[l'activation de taproot]: /en/newsletters/2021/11/17/#taproot-activated
[rb#691]: /en/newsletters/2021/11/17/#rust-bitcoin-691
[cbf verification]: /en/newsletters/2021/11/10/#additional-compact-block-filter-verification
[lnd#5709]: /en/newsletters/2021/10/27/#lnd-5709
[bitcoin core 0.21.0]: /en/newsletters/2021/01/20/#bitcoin-core-0-21-0
[eclair 0.5.0]: /en/newsletters/2021/01/06/#eclair-0-5-0
[rust bitcoin 0.26.0]: /en/newsletters/2021/01/20/#rust-bitcoin-0-26-0
[lnd 0.12.0-beta]: /en/newsletters/2021/01/27/#lnd-0-12-0-beta
[hwi 2.0.0]: /en/newsletters/2021/03/17/#hwi-2-0-0
[c-lightning 0.10.0]: /en/newsletters/2021/04/07/#c-lightning-0-10-0
[btcpay server 1.1.0]: /en/newsletters/2021/05/05/#btcpay-1-1-0
[eclair 0.6.0]: /en/newsletters/2021/05/26/#eclair-0-6-0
[lnd 0.13.0-beta]: /en/newsletters/2021/06/23/#lnd-0-13-0-beta
[bitcoin core 22.0]: /en/newsletters/2021/09/15/#bitcoin-core-22-0
[bdk 0.12.0]: /en/newsletters/2021/10/20/#bdk-0-12-0
[lnd 0.14.0]: /en/newsletters/2021/11/24/#lnd-0-14-0-beta
[bdk 0.14.0]: /en/newsletters/2021/12/08/#bdk-0-14-0
[csb]: /en/newsletters/2021/06/02/#candidate-set-based-csb-block-template-construction
[rbf default]: /en/newsletters/2021/06/23/#allowing-transaction-replacement-by-default
[nseq default]: /en/newsletters/2021/06/16/#bip-proposed-for-wallets-to-set-nsequence-by-default-on-taproot-transactions
[bcc#20833]: /en/newsletters/2021/06/02/#bitcoin-core-20833
[ff expanded]: /en/newsletters/2021/06/09/#receiving-ln-payments-with-a-mostly-offline-private-key
[cl#4639]: /en/newsletters/2021/07/28/#c-lightning-4639
[descriptor bips1]: /en/newsletters/2021/07/07/#bips-for-output-script-descriptors
[descriptor bips2]: /en/newsletters/2021/09/08/#bips-1143
[descriptor default]: /en/newsletters/2021/10/27/#bitcoin-core-23002
[descriptor gist]: https://gist.github.com/sipa/e3d23d498c430bb601c5bca83523fa82/
[0conf channels]: /en/newsletters/2021/07/07/#zero-conf-channel-opens
[sighash combo]: /en/newsletters/2021/07/14/#bips-943
[fi bonds]: /en/newsletters/2021/08/11/#implementation-of-fidelity-bonds
[0base]: /en/newsletters/2021/08/25/#zero-base-fee-ln-discussion
[bulletins]: /en/newsletters/
[index des sujets]: /en/topics/
[additive batching]: /en/cardcoins-rbf-batching/
[zmn guest]: /en/newsletters/2021/09/01/#preparing-for-taproot-11-ln-with-taproot
[darosior guest]: /en/newsletters/2021/09/08/#preparing-for-taproot-12-vaults-with-taproot
[heritage identifiers]: /en/newsletters/2021/10/06/#proposal-for-transaction-heritage-identifiers
[ptlcs extreme]: /en/newsletters/2021/10/13/#multiple-proposed-ln-improvements
[lnd#5709]: /en/newsletters/2021/10/27/#lnd-5709
[2018 ln summit]: /en/newsletters/2018/11/20/#feature-news-lightning-network-protocol-11-goals
[2021 ln summit]: /en/newsletters/2021/11/10/#ln-summit-2021-notes
[paiements sans blocage]: /en/newsletters/2019/07/03/#stuckless-payments
[bcc#19953]: /en/newsletters/2020/10/21/#bitcoin-core-19953
[lnd#5025]: /en/newsletters/2021/06/02/#lnd-5025
[signet reorgs]: /en/newsletters/2021/09/15/#signet-reorg-discussion
[bech32 bip]: /en/newsletters/2021/01/13/#bech32m
[offers stuck]: /en/newsletters/2021/04/21/#using-ln-offers-to-partly-address-stuck-payments
[news128 akka]: /en/newsletters/2020/12/16/#eclair-1566
[news123 watchdog]: /en/newsletters/2020/11/11/#eclair-1545
[news53 lightning loop]: /en/newsletters/2019/07/03/#lightning-loop-supports-user-loop-ins
[semantic versioning website]: https://semver.org/
[fido2 website]: https://fidoalliance.org/fido2/fido2-web-authentication-webauthn/
[news164 ping]: /en/newsletters/2021/09/01/#lnd-5621
[news157 db]: /en/newsletters/2021/07/14/#lnd-5447
[news170 path]: /en/newsletters/2021/10/13/#lnd-5642
[news172 pool]: /en/newsletters/2021/10/27/#lnd-5709
[news173 amp]: /en/newsletters/2021/11/03/#lnd-5803
[bcc#22364]: /en/newsletters/2021/12/01/#bitcoin-core-22364
[ln ptlcs]: /en/newsletters/2021/12/15/#preparing-ln-for-ptlcs
[anyprevout proposed]: /en/newsletters/2019/05/21/#proposed-anyprevout-sighash-modes
[cl#4489]: /en/newsletters/2021/05/12/#c-lightning-4489
[cl#4410]: /en/newsletters/2021/03/17/#c-lightning-4404
[bip125 discrep]: /en/newsletters/2021/05/12/#cve-2021-31876-discrepancy-between-bip125-and-bitcoin-core-implementation
[wiki contract]: https://en.bitcoin.it/wiki/Contract#Example_1:_Providing_a_deposit
[cl#4771]: /en/newsletters/2021/10/27/#c-lightning-4771
[fee bump research]: /en/newsletters/2021/12/08/#fee-bumping-research
[nov cs]: /en/newsletters/2021/11/17/#changes-to-services-and-client-software
[dec cs]: /en/newsletters/2021/12/15/#changes-to-services-and-client-software
[mpa ml]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-September/019464.html
[ff orig]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-April/001986.html
[2020 conclusion]: /en/newsletters/2020/12/23/#conclusion
